	.file	"positive_tests.c"
	.text
	.globl	times8                          # -- Begin function times8
	.p2align	4
	.type	times8,@function
times8:                                 # @times8
	.cfi_startproc
# %bb.0:                                # %entry
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
                                        # kill: def $edi killed $edi def $rdi
	leal	(,%rdi,8), %eax
	popq	%rbp
	.cfi_def_cfa %rsp, 8
	retq
.Lfunc_end0:
	.size	times8, .Lfunc_end0-times8
	.cfi_endproc
                                        # -- End function
	.globl	mod32                           # -- Begin function mod32
	.p2align	4
	.type	mod32,@function
mod32:                                  # @mod32
	.cfi_startproc
# %bb.0:                                # %entry
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	movl	%edi, %eax
	andl	$31, %eax
	popq	%rbp
	.cfi_def_cfa %rsp, 8
	retq
.Lfunc_end1:
	.size	mod32, .Lfunc_end1-mod32
	.cfi_endproc
                                        # -- End function
	.globl	test_rotate                     # -- Begin function test_rotate
	.p2align	4
	.type	test_rotate,@function
test_rotate:                            # @test_rotate
	.cfi_startproc
# %bb.0:                                # %entry
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	movl	%edi, %eax
	roll	$8, %eax
	popq	%rbp
	.cfi_def_cfa %rsp, 8
	retq
.Lfunc_end2:
	.size	test_rotate, .Lfunc_end2-test_rotate
	.cfi_endproc
                                        # -- End function
	.globl	test_abs                        # -- Begin function test_abs
	.p2align	4
	.type	test_abs,@function
test_abs:                               # @test_abs
	.cfi_startproc
# %bb.0:                                # %entry
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	movl	%edi, %eax
	negl	%eax
	cmovsl	%edi, %eax
	popq	%rbp
	.cfi_def_cfa %rsp, 8
	retq
.Lfunc_end3:
	.size	test_abs, .Lfunc_end3-test_abs
	.cfi_endproc
                                        # -- End function
	.globl	test_max                        # -- Begin function test_max
	.p2align	4
	.type	test_max,@function
test_max:                               # @test_max
	.cfi_startproc
# %bb.0:                                # %entry
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	movl	%esi, %eax
	cmpl	%esi, %edi
	cmovgl	%edi, %eax
	popq	%rbp
	.cfi_def_cfa %rsp, 8
	retq
.Lfunc_end4:
	.size	test_max, .Lfunc_end4-test_max
	.cfi_endproc
                                        # -- End function
	.globl	test_min                        # -- Begin function test_min
	.p2align	4
	.type	test_min,@function
test_min:                               # @test_min
	.cfi_startproc
# %bb.0:                                # %entry
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	movl	%esi, %eax
	cmpl	%esi, %edi
	cmovll	%edi, %eax
	popq	%rbp
	.cfi_def_cfa %rsp, 8
	retq
.Lfunc_end5:
	.size	test_min, .Lfunc_end5-test_min
	.cfi_endproc
                                        # -- End function
	.globl	test_bswap                      # -- Begin function test_bswap
	.p2align	4
	.type	test_bswap,@function
test_bswap:                             # @test_bswap
	.cfi_startproc
# %bb.0:                                # %entry
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	movl	%edi, %eax
	bswapl	%eax
	popq	%rbp
	.cfi_def_cfa %rsp, 8
	retq
.Lfunc_end6:
	.size	test_bswap, .Lfunc_end6-test_bswap
	.cfi_endproc
                                        # -- End function
	.globl	test_popcount_logic             # -- Begin function test_popcount_logic
	.p2align	4
	.type	test_popcount_logic,@function
test_popcount_logic:                    # @test_popcount_logic
	.cfi_startproc
# %bb.0:                                # %entry
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	movl	%edi, %eax
	shrl	%eax
	andl	$1431655765, %eax               # imm = 0x55555555
	subl	%eax, %edi
	movl	%edi, %eax
	andl	$858993459, %eax                # imm = 0x33333333
	shrl	$2, %edi
	andl	$858993459, %edi                # imm = 0x33333333
	addl	%eax, %edi
	movl	%edi, %eax
	shrl	$4, %eax
	addl	%edi, %eax
	andl	$252645135, %eax                # imm = 0xF0F0F0F
	imull	$16843009, %eax, %eax           # imm = 0x1010101
	shrl	$24, %eax
	popq	%rbp
	.cfi_def_cfa %rsp, 8
	retq
.Lfunc_end7:
	.size	test_popcount_logic, .Lfunc_end7-test_popcount_logic
	.cfi_endproc
                                        # -- End function
	.ident	"clang version 22.0.0git (https://github.com/llvm/llvm-project.git afc83688cfadfb07c1cd9edc4f3c855d7cf4a261)"
	.section	".note.GNU-stack","",@progbits
