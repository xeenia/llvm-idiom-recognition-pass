#include <stdint.h>

// ============================================================================
// 1. mulpow2: multiplication by power of two
// ============================================================================
// expected lowering: shl (shift left)
int times8(int x) {
    return x * 8;
}

// ============================================================================
// 2. modpow2: modulo by power of two
// ============================================================================
// expected lowering: and (bitwise and)
// unsigned type used to ensure m_urem matching without additional logic
unsigned mod32(unsigned x) {
    return x % 32;
}

// ============================================================================
// 3. rotate: circular shift
// ============================================================================
// expected lowering: llvm.fshl (funnel shift left)
unsigned int test_rotate(unsigned int x) {
    // standard c idiom for 32-bit rotate left
    return (x << 8) | (x >> 24); 
}

// ============================================================================
// 4. abs: absolute value
// ============================================================================
// expected lowering: llvm.abs
int test_abs(int x) {
    if (x < 0) {
        return -x;
    }
    return x;
}

// ============================================================================
// 5. minmax: minimum and maximum
// ============================================================================
// expected lowering: llvm.smax and llvm.smin
int test_max(int a, int b) {
    return (a > b) ? a : b;
}

int test_min(int a, int b) {
    return (a < b) ? a : b;
}

// ============================================================================
// 6. bswap: byte swap
// ============================================================================
// expected lowering: llvm.bswap
unsigned int test_bswap(unsigned int x) {
    return ((x & 0xFF000000) >> 24) |
           ((x & 0x00FF0000) >> 8)  |
           ((x & 0x0000FF00) << 8)  |
           ((x & 0x000000FF) << 24);
}

// ============================================================================
// 7. popcount: population count (bit counting)
// ============================================================================
// expected lowering: llvm.ctpop
// swar algorithm pattern for parallel bit counting
int test_popcount_logic(unsigned int i) {
     i = i - ((i >> 1) & 0x55555555);
     i = (i & 0x33333333) + ((i >> 2) & 0x33333333);
     return (((i + (i >> 4)) & 0x0F0F0F0F) * 0x01010101) >> 24;
}