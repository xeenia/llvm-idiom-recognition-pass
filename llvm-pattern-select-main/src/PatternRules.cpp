#include "PatternRules.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/PatternMatch.h"
#include "llvm/IR/Intrinsics.h"
#include "llvm/Support/MathExtras.h" 
#include "llvm/ADT/Statistic.h" 

#define DEBUG_TYPE "pattern-select" 

STATISTIC(NumRotates, "Number of rotates optimized");
STATISTIC(NumMulPow2, "Number of mul-pow2 optimized"); 
STATISTIC(NumModPow2, "Number of mod-pow2 optimized");
STATISTIC(NumBSwap,   "Number of byte-swaps optimized");
STATISTIC(NumPopCount, "Number of popcounts optimized");

using namespace llvm;
using namespace llvm::PatternMatch;

// ============================================================================
// MATCHERS
// ============================================================================

static std::optional<ModPow2> matchModPow2(Instruction &I) { 
  Value *X = nullptr;
  ConstantInt *CI = nullptr;
  
  if (!match(&I, m_URem(m_Value(X), m_ConstantInt(CI)))) return std::nullopt;
  
  uint64_t div = CI->getZExtValue();
  if (!div || (div & (div - 1))) return std::nullopt; // not power of two
  
  return ModPow2{X, CI, div, div - 1};
}

static std::optional<MulPow2> matchMulPow2(Instruction &I) {
  Value *X = nullptr;
  ConstantInt *CI = nullptr;
  if(!match(&I, m_Mul(m_Value(X), m_ConstantInt(CI)))) return std::nullopt;
  
  uint64_t mul = CI->getZExtValue();
  if (mul == 0 || (mul & (mul - 1)) != 0) return std::nullopt;
  
  uint64_t exp = llvm::countr_zero(mul); 
  
  return MulPow2{X, CI, exp};
}

static std::optional<AbsPattern> matchAbs(Instruction &I) {
  Value *X = nullptr;
  Value *Cond = nullptr, *TrueVal = nullptr, *FalseVal = nullptr;

  if (!match(&I, m_Select(m_Value(Cond), m_Value(TrueVal), m_Value(FalseVal)))) 
    return std::nullopt;

  CmpPredicate Pred; 
  
  if (match(Cond, m_ICmp(Pred, m_Value(X), m_Zero()))) {
    if (Pred == ICmpInst::ICMP_SLT) {
       if (match(TrueVal, m_Neg(m_Specific(X))) && match(FalseVal, m_Specific(X)))
         return AbsPattern{X};
    }
  }
  return std::nullopt;
}

static std::optional<RotatePattern> matchRotate(Instruction &I) {
  Value *LHS, *RHS;

  if (!match(&I, m_Or(m_Value(LHS), m_Value(RHS)))) return std::nullopt;

  Value *X, *Y, *ShAmtL, *ShAmtR;
  ConstantInt *C1, *C2;

  if (match(LHS, m_Shl(m_Value(X), m_ConstantInt(C1))) &&
      match(RHS, m_LShr(m_Value(Y), m_ConstantInt(C2)))) {
    if (isa<Constant>(X)) return std::nullopt;
    if (X != Y) return std::nullopt;
    uint32_t BW = X->getType()->getScalarSizeInBits();
    uint64_t S1 = C1->getZExtValue();
    uint64_t S2 = C2->getZExtValue();

    if (S1 + S2 == BW) {
      return RotatePattern{X, C1}; 
    }
  }
  
  return std::nullopt;
}

static std::optional<BSwapPattern> matchBSwap(Instruction &I) {
  if (!I.getType()->isIntegerTy(32)) return std::nullopt;

  Value *OpA, *OpB, *OpC, *OpD;
  
  if (!match(&I, m_c_Or(m_c_Or(m_c_Or(m_Value(OpA), m_Value(OpB)), m_Value(OpC)), m_Value(OpD)))) {
     return std::nullopt;
  }

  auto matchBytePart = [](Value *V, Value *&Root, uint64_t Mask, uint64_t Shift, bool isLeft) -> bool {
      Value *X;
      ConstantInt *CMask, *CShift;
      if (isLeft) { 
          if (!match(V, m_Shl(m_And(m_Value(X), m_ConstantInt(CMask)), m_ConstantInt(CShift))))
             return false;
      } else {
          if (!match(V, m_LShr(m_And(m_Value(X), m_ConstantInt(CMask)), m_ConstantInt(CShift))))
             return false;
      }
      if (CMask->getZExtValue() != Mask || CShift->getZExtValue() != Shift) return false;

      if (Root == nullptr) Root = X;
      return Root == X;
  };

  Value *Root = nullptr;
  bool found[4] = {false, false, false, false}; 
  
  Value *Parts[4] = {OpA, OpB, OpC, OpD};
  
  for (Value *Part : Parts) {
      if (matchBytePart(Part, Root, 0xFF000000, 24, false)) { found[3] = true; continue; }
      if (matchBytePart(Part, Root, 0x00FF0000, 8, false))  { found[2] = true; continue; }
      if (matchBytePart(Part, Root, 0x0000FF00, 8, true))   { found[1] = true; continue; }
      if (matchBytePart(Part, Root, 0x000000FF, 24, true))  { found[0] = true; continue; }
  }

  if (found[0] && found[1] && found[2] && found[3] && Root) {
      return BSwapPattern{Root};
  }

  return std::nullopt;
}
static std::optional<MinMaxPattern> matchMinMax(Instruction &I) {
  Value *LHS = nullptr, *RHS = nullptr, *Cond = nullptr;
  
  CmpPredicate Pred; 
  
  if (match(&I, m_Select(m_Value(Cond), m_Value(LHS), m_Value(RHS)))) {
    if (match(Cond, m_ICmp(Pred, m_Specific(LHS), m_Specific(RHS)))) {
      bool isMax = (Pred == ICmpInst::ICMP_SGT || Pred == ICmpInst::ICMP_UGT);
      return MinMaxPattern{LHS, RHS, isMax};
    }
    
    if (match(Cond, m_ICmp(Pred, m_Specific(LHS), m_Specific(RHS)))) {
       if (Pred == ICmpInst::ICMP_SLT || Pred == ICmpInst::ICMP_ULT) {
           return MinMaxPattern{LHS, RHS, false}; // isMin
       }
    }
  }
  return std::nullopt;
}

static std::optional<PopCountPattern> matchPopCount(Instruction &I) {
  Value *Op = nullptr;
  
  if (!match(&I, m_LShr(m_Mul(m_Value(Op), m_SpecificInt(0x01010101)), m_SpecificInt(24)))) {
    return std::nullopt;
  }
  Value *V = nullptr;
  if (!match(Op, m_And(m_Value(V), m_SpecificInt(0x0F0F0F0F)))) {
     return std::nullopt;
  }
  
  Value *Curr = V;
  for (int steps = 0; steps < 10; ++steps) {
      if (isa<Argument>(Curr)) {
          return PopCountPattern{Curr};
      }
      
      if (Instruction *Inst = dyn_cast<Instruction>(Curr)) {
          Curr = Inst->getOperand(0);
      } else {
          break;
      }
  }

  return std::nullopt;
}

// ============================================================================
// REWRITERS
// ============================================================================

static bool rewriteModPow2(Instruction &I, const ModPow2 &P) {
  IRBuilder<> B(&I);
  Value *And = B.CreateAnd(P.X, ConstantInt::get(P.X->getType(), P.mask));
  I.replaceAllUsesWith(And);
  return true;
}

static bool rewriteMulPow2(Instruction &I, const MulPow2 &P) {
  IRBuilder<> B(&I);
  Value *Shl = B.CreateShl(P.X, ConstantInt::get(P.X->getType(), P.exponent));
  I.replaceAllUsesWith(Shl);
  return true;
}

static bool rewriteAbs(Instruction &I, const AbsPattern &P) {
  IRBuilder<> B(&I);
  CallInst *Abs = B.CreateIntrinsic(Intrinsic::abs, {P.X->getType()}, {P.X, B.getInt1(false)});
  I.replaceAllUsesWith(Abs);
  return true;
}

static bool rewriteRotate(Instruction &I, const RotatePattern &P) {
  IRBuilder<> B(&I);
  CallInst *Rot = B.CreateIntrinsic(Intrinsic::fshl, {P.X->getType()}, {P.X, P.X, P.ShAmt});
  NumRotates++; 
  I.replaceAllUsesWith(Rot);
  return true;
}

static bool rewriteBSwap(Instruction &I, const BSwapPattern &P) {
  IRBuilder<> B(&I);
  CallInst *Swap = B.CreateIntrinsic(Intrinsic::bswap, {P.X->getType()}, {P.X});
  
  NumBSwap++; 
  
  I.replaceAllUsesWith(Swap);
  return true;
}

static bool rewriteMinMax(Instruction &I, const MinMaxPattern &P) {
  IRBuilder<> B(&I);
  Intrinsic::ID IID = P.isMax ? Intrinsic::smax : Intrinsic::smin;
  CallInst *Res = B.CreateIntrinsic(IID, {P.LHS->getType()}, {P.LHS, P.RHS});
  I.replaceAllUsesWith(Res);
  return true;
}

static bool rewritePopCount(Instruction &I, const PopCountPattern &P) {
    IRBuilder<> B(&I);
    CallInst *Pop = B.CreateIntrinsic(Intrinsic::ctpop, {P.X->getType()}, {P.X});
    
    NumPopCount++; 
    
    I.replaceAllUsesWith(Pop);
    return true;
}

// ============================================================================
// DISPATCHER
// ============================================================================

bool tryMatchAndRewrite(Instruction &I) {
  if (auto M = matchModPow2(I)) return rewriteModPow2(I, *M);
  if (auto M = matchMulPow2(I)) return rewriteMulPow2(I, *M);
  if (auto A = matchAbs(I))     return rewriteAbs(I, *A);
  if (auto R = matchRotate(I))  return rewriteRotate(I, *R);
  if (auto M = matchMinMax(I))  return rewriteMinMax(I, *M);
   if (auto B = matchBSwap(I))   return rewriteBSwap(I, *B); 
   if (auto P = matchPopCount(I)) return rewritePopCount(I, *P);

  return false;
}