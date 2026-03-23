#include <stdint.h>

// ============================================================================
// 1. negative mulpow2
// ============================================================================

// case: multiplication by non-power-of-2 (7).
// pattern matcher should ignore non-shift-equivalent constants.
int negative_mul_not_pow2(int a) {
    return a * 7;
}

// case: multiplication by 0.
// edge case typically handled by constant folding/simplification. 
// heuristic should avoid lifting to avoid redundant ir complexity.
int negative_mul_zero(int a) {
    return a * 0;
}

// ============================================================================
// 2. negative modpow2 (rem)
// ============================================================================

// case: unsigned modulo by non-power-of-2 (6).
// requires power-of-2 divisor for bitwise-and substitution.
unsigned int negative_urem_not_pow2(unsigned int a) {
    return a % 6;
}

// case: signed modulo by power-of-2.
// restricted to m_urem. srem is excluded due to different negative number 
// semantics in c (rounding toward zero vs floor).
int negative_srem_pow2(int a) {
    return a % 8;
}

// ============================================================================
// 3. negative rotate
// ============================================================================

// case: invalid shift sum (s + (31 - s) != bit_width). 
// does not represent a full 32-bit rotation.
unsigned int negative_rotate_bad_sum(unsigned int x, unsigned int s) {
    return (x << s) | (x >> (31 - s));
}

// case: mismatched operands. 
// source variables (x, y) differ; cannot be coalesced into a single rotate intrinsic.
unsigned int negative_rotate_diff_vars(unsigned int x, unsigned int y, unsigned int s) {
    return (x << s) | (y >> (32 - s));
}

// ============================================================================
// 4. negative abs
// ============================================================================

// case: non-canonical predicate (x > 0). 
// does not match the standard (x < 0) ? -x : x idiom.
int negative_abs_wrong_pred(int x) {
    return (x > 0) ? -x : x;
}

// case: incorrect comparison constant. 
// absolute value lifting requires zero-comparison in the icmpinst.
int negative_abs_wrong_const(int x) {
    return (x < 1) ? -x : x;
}

// ============================================================================
// 5. negative minmax
// ============================================================================

// case: selectinst operand mismatch. 
// result 'c' does not correspond to comparison operands 'a' or 'b'.
int negative_minmax_mismatch(int a, int b, int c) {
    return (a > b) ? a : c;
}

// ============================================================================
// 6. negative bswap
// ============================================================================

// case: partial byte-shift logic. 
// incomplete sequence; does not match the full 32-bit bswap intrinsic signature.
unsigned int negative_bswap_partial(unsigned int a) {
    return (a & 0xFF) << 24;
}