# LLVM Middle-End Pass for Code Idiom Recognition (MSc Thesis)

This repository contains the source code for my master's thesis. The project implements an out-of-tree LLVM middle-end optimization pass using Modern C++ and the New Pass Manager.

## Overview
The pass identifies unoptimized instruction trees in LLVM IR and replaces them with branchless hardware intrinsics.

### Supported Patterns:
* **Idiom Detection**: Recognizes 7 distinct patterns such as SWAR PopCount, bitwise rotations, byte swaps (bswap), branch-based Min/Max, Absolute Value, and power-of-two multiplication and modulo operations .
* **Analysis**: Uses bottom-up heuristic traversal of **Def-Use chains** to isolate patterns.
* **Transformation**: Replaces detected IR trees with intrinsics (e.g., `ctpop`, `fshl`) using **IRBuilder** and **RAUW**.
* **Results**: Achieved a **52.9% reduction** in static IR instruction count on targeted benchmarks.

## Implementation Details
* **Architecture**: Uses the **CRTP pattern** (`PassInfoMixin`) for compile-time polymorphism and zero runtime overhead.
* **State Management**: Handles analysis invalidation via **PreservedAnalyses**.
* **Compatibility**: Developed for **LLVM 15+**.

## Testing & Validation
* **Regression Suite**: Automated tests using **LLVM FileCheck** and Bash to verify semantic correctness.
* **Benchmarking**: Comparative analysis against `instcombine` to measure IR reduction.
* **Safety**: Validation of edge cases in instruction trees to prevent miscompilations.
