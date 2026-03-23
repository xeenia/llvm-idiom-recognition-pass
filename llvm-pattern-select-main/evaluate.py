import subprocess
import os

OPT = "./llvm-project/build-clean/bin/opt"
PLUGIN = "./build/PatternSelectPass.so"
TEST_FILE = "./tests/positive_input.ll"

def count_instructions(ir_text):
    lines = ir_text.split('\n')
    count = 0
    for line in lines:
        l = line.strip()
        if l and not any(l.startswith(s) for s in [';', 'define', '}', '!', 'target', 'source', 'declare', 'attributes']):
            count += 1
    return count

def run_command(cmd_list):
    result = subprocess.run(cmd_list, capture_output=True, text=True)
    if result.returncode != 0:
        print(f"Error running command: {' '.join(cmd_list)}")
        print(result.stderr)
        return ""
    return result.stdout

print("=== LLVM Pass Evaluation Script ===")

baseline_ir = run_command([OPT, "-passes=mem2reg,simplifycfg", "-S", TEST_FILE])
base_count = count_instructions(baseline_ir)


with open("temp_base.ll", "w") as f: f.write(baseline_ir)
my_pass_ir = run_command([OPT, "-load-pass-plugin", PLUGIN, "-passes=pattern-select,dce", "-S", "temp_base.ll"])
my_count = count_instructions(my_pass_ir)


ic_ir = run_command([OPT, "-passes=mem2reg,simplifycfg,instcombine", "-S", TEST_FILE])
ic_count = count_instructions(ic_ir)


print("-" * 40)
print(f"{'Pass Strategy':<20} | {'Inst. Count':<12} | {'Reduction':<10}")
print("-" * 40)
print(f"{'Baseline':<20} | {base_count:<12} | {'0.0%':<10}")
print(f"{'PatternSelect+DCE':<20} | {my_count:<12} | {((base_count-my_count)/base_count)*100:>5.1f}%")
print(f"{'InstCombine':<20} | {ic_count:<12} | {((base_count-ic_count)/base_count)*100:>5.1f}%")
print("-" * 40)


print("\n=== Timing for PatternSelect ===")
os.system(f"{OPT} -load-pass-plugin {PLUGIN} -passes='pattern-select' -time-passes {TEST_FILE} -o /dev/null 2>&1 | grep 'PatternSelectPass'")


if os.path.exists("temp_base.ll"): os.remove("temp_base.ll")