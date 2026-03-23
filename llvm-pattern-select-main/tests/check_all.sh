#!/bin/bash

OPT="/home/xenia/llvm-project/build-clean/bin/opt"
FILECHECK="/home/xenia/llvm-project/build-clean/bin/FileCheck"
PLUGIN="../build/PatternSelectPass.so"

echo "=== Running LLVM PatternSelect Regression Tests ==="

for test_file in ../tests/*.ll; do
    echo -n "Testing $(basename $test_file)... "
 
    $OPT -passes="mem2reg,simplifycfg" -S < "$test_file" > temp_clean.ll 2>/dev/null
    

    $OPT -load-pass-plugin="$PLUGIN" -passes="pattern-select" -S < temp_clean.ll > temp_final.ll 2>/dev/null
    
    if [ ! -s temp_final.ll ]; then
        echo "CRASH 💥"
        rm -f temp_clean.ll temp_final.ll
        continue
    fi

    $FILECHECK "$test_file" < temp_final.ll
    
    if [ $? -eq 0 ]; then
        echo "PASS ✅"
    else
        echo "FAIL ❌"
    fi
done

rm -f temp_clean.ll temp_final.ll