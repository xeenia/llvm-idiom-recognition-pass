#pragma once
#include "llvm/IR/Instructions.h"
#include "llvm/IR/Value.h"
#include <optional>

struct ModPow2 { 
  llvm::Value *X;
  llvm::ConstantInt *CI;
  uint64_t div;
  uint64_t mask;
};

struct PopCountPattern { 
  llvm::Value *X; 
};

struct AbsPattern {
  llvm::Value *X;
};

struct RotatePattern {
  llvm::Value *X;
  llvm::Value *ShAmt;
};

struct MulPow2 { 
  llvm::Value *X;
  llvm::ConstantInt *CI;
  uint64_t exponent;
};

struct BSwapPattern { 
  llvm::Value *X; 
};

struct MinMaxPattern {
  llvm::Value *LHS; 
  llvm::Value *RHS;
  bool isMax;
};

bool tryMatchAndRewrite(llvm::Instruction &I);