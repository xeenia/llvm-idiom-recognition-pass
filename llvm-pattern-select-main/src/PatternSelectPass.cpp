
#include "llvm/IR/PassManager.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/PatternMatch.h"
#include "llvm/IR/Constants.h"
#include "llvm/Passes/PassBuilder.h"
#include "llvm/Passes/PassPlugin.h"
#include "llvm/Support/raw_ostream.h"
#include "PatternRules.h"

using namespace llvm;
using namespace llvm::PatternMatch;

namespace {

struct PatternSelectPass : public PassInfoMixin<PatternSelectPass> {
  PreservedAnalyses run(Function &F, FunctionAnalysisManager &) {
    bool changed = false;

    for (auto &BB : F) {
      for (auto It = BB.begin(), End = BB.end(); It != End; ) {
          Instruction *I = &*It++;
          if(tryMatchAndRewrite(*I)) changed = true;
      }
    }
    return changed ? PreservedAnalyses::none() : PreservedAnalyses::all();
  }
};

} // end anonymous namespace
extern "C" ::llvm::PassPluginLibraryInfo llvmGetPassPluginInfo() {
  return {
    LLVM_PLUGIN_API_VERSION, 
    "PatternSelectPass", 
    LLVM_VERSION_STRING,
    [](llvm::PassBuilder &PB) {
      PB.registerPipelineParsingCallback(
          [](llvm::StringRef Name, llvm::FunctionPassManager &FPM,
             llvm::ArrayRef<llvm::PassBuilder::PipelineElement>) {
            if (Name == "pattern-select") {
              FPM.addPass(PatternSelectPass());
              return true;
            }
            return false;
          });
    }
  };
}