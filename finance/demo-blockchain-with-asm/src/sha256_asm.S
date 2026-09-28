/* Auto-generated from sha256.c via `zig cc -O3 -S` for the ASM demo.
 * Hand-written PoW loop lives in pow_mine.S and calls sha256() below.
 */
	.def	@feat.00;
	.scl	3;
	.type	0;
	.endef
	.globl	@feat.00
@feat.00 = 0
	.file	"sha256.c"
	.def	sha256_init;
	.scl	2;
	.type	32;
	.endef
	.section	.rdata,"dr"
	.p2align	5, 0x0                          # -- Begin function sha256_init
.LCPI0_0:
	.long	1779033703                      # 0x6a09e667
	.long	3144134277                      # 0xbb67ae85
	.long	1013904242                      # 0x3c6ef372
	.long	2773480762                      # 0xa54ff53a
	.long	1359893119                      # 0x510e527f
	.long	2600822924                      # 0x9b05688c
	.long	528734635                       # 0x1f83d9ab
	.long	1541459225                      # 0x5be0cd19
	.text
	.globl	sha256_init
	.p2align	4
sha256_init:                            # @sha256_init
.Lfunc_begin0:
	.cv_func_id 0
	.cv_file	1 "D:\\Playground\\demo-blockchain-with-asm\\src\\sha256.c" "55A2A5620E5A826541490E5EE514F2F0" 1
	.cv_loc	0 1 45 0                        # src/sha256.c:45:0
.seh_proc sha256_init
# %bb.0:
	#DEBUG_VALUE: sha256_init:ctx <- $rcx
	pushq	%rbp
	.seh_pushreg %rbp
	movq	%rsp, %rbp
	.seh_setframe %rbp, 0
	.seh_endprologue
.Ltmp0:
	.cv_loc	0 1 46 0                        # src/sha256.c:46:0
	movl	$0, 104(%rcx)
	.cv_loc	0 1 47 0                        # src/sha256.c:47:0
	movq	$0, (%rcx)
	.cv_loc	0 1 48 0                        # src/sha256.c:48:0
	vmovaps	.LCPI0_0(%rip), %ymm0           # ymm0 = [1779033703,3144134277,1013904242,2773480762,1359893119,2600822924,528734635,1541459225]
	vmovups	%ymm0, 8(%rcx)
	.cv_loc	0 1 52 0                        # src/sha256.c:52:0
	.seh_startepilogue
	popq	%rbp
	.seh_endepilogue
	vzeroupper
	retq
.Ltmp1:
.Lfunc_end0:
	.seh_endproc
                                        # -- End function
	.def	sha256_update;
	.scl	2;
	.type	32;
	.endef
	.globl	sha256_update                   # -- Begin function sha256_update
	.p2align	4
sha256_update:                          # @sha256_update
.Lfunc_begin1:
	.cv_func_id 1
	.cv_loc	1 1 54 0                        # src/sha256.c:54:0
.seh_proc sha256_update
# %bb.0:
	#DEBUG_VALUE: sha256_update:ctx <- $rcx
	#DEBUG_VALUE: sha256_update:data <- $rdx
	#DEBUG_VALUE: sha256_update:len <- $r8
	pushq	%rbp
	.seh_pushreg %rbp
.Ltmp2:
	pushq	%r15
	.seh_pushreg %r15
	pushq	%r14
	.seh_pushreg %r14
	pushq	%rsi
	.seh_pushreg %rsi
	pushq	%rdi
	.seh_pushreg %rdi
	pushq	%rbx
	.seh_pushreg %rbx
	subq	$40, %rsp
	.seh_stackalloc 40
	leaq	32(%rsp), %rbp
	.seh_setframe %rbp, 32
	.seh_endprologue
.Ltmp3:
	#DEBUG_VALUE: i <- 0
	.cv_loc	1 1 55 0                        # src/sha256.c:55:0
	testq	%r8, %r8
	je	.LBB1_5
.Ltmp4:
# %bb.1:
	#DEBUG_VALUE: sha256_update:ctx <- $rcx
	#DEBUG_VALUE: sha256_update:data <- $rdx
	#DEBUG_VALUE: sha256_update:len <- $r8
	#DEBUG_VALUE: i <- 0
	.cv_loc	1 1 56 0                        # src/sha256.c:56:0
	movq	%r8, %rsi
	movq	%rdx, %rdi
	movq	%rcx, %rbx
	leaq	40(%rcx), %r14
.Ltmp5:
	movl	104(%rcx), %eax
	xorl	%r15d, %r15d
	jmp	.LBB1_2
.Ltmp6:
	.p2align	4
.LBB1_4:                                #   in Loop: Header=BB1_2 Depth=1
	#DEBUG_VALUE: sha256_update:ctx <- $rbx
	#DEBUG_VALUE: sha256_update:data <- $rdi
	#DEBUG_VALUE: sha256_update:len <- $rsi
	#DEBUG_VALUE: i <- $r15
	.cv_loc	1 1 55 0                        # src/sha256.c:55:0
	incq	%r15
.Ltmp7:
	#DEBUG_VALUE: i <- $r15
	.cv_loc	1 1 55 0                        # src/sha256.c:55:0
	cmpq	%r15, %rsi
	je	.LBB1_5
.Ltmp8:
.LBB1_2:                                # =>This Inner Loop Header: Depth=1
	#DEBUG_VALUE: sha256_update:ctx <- $rbx
	#DEBUG_VALUE: sha256_update:data <- $rdi
	#DEBUG_VALUE: sha256_update:len <- $rsi
	#DEBUG_VALUE: i <- $r15
	.cv_loc	1 1 56 0                        # src/sha256.c:56:0
	movzbl	(%rdi,%r15), %ecx
	movl	%eax, %eax
	movb	%cl, 40(%rbx,%rax)
	.cv_loc	1 1 57 0                        # src/sha256.c:57:0
	movl	104(%rbx), %eax
	incl	%eax
	movl	%eax, 104(%rbx)
	.cv_loc	1 1 58 0                        # src/sha256.c:58:0
	cmpl	$64, %eax
	jne	.LBB1_4
.Ltmp9:
# %bb.3:                                #   in Loop: Header=BB1_2 Depth=1
	#DEBUG_VALUE: sha256_update:ctx <- $rbx
	#DEBUG_VALUE: sha256_update:data <- $rdi
	#DEBUG_VALUE: sha256_update:len <- $rsi
	#DEBUG_VALUE: i <- $r15
	.cv_loc	1 1 59 0                        # src/sha256.c:59:0
	movq	%rbx, %rcx
	movq	%r14, %rdx
	callq	sha256_transform
	.cv_loc	1 1 60 0                        # src/sha256.c:60:0
	addq	$512, (%rbx)                    # imm = 0x200
	.cv_loc	1 1 61 0                        # src/sha256.c:61:0
	movl	$0, 104(%rbx)
	xorl	%eax, %eax
	jmp	.LBB1_4
.Ltmp10:
.LBB1_5:
	#DEBUG_VALUE: sha256_update:ctx <- [DW_OP_LLVM_entry_value 1] $rcx
	#DEBUG_VALUE: sha256_update:data <- [DW_OP_LLVM_entry_value 1] $rdx
	#DEBUG_VALUE: sha256_update:len <- [DW_OP_LLVM_entry_value 1] $r8
	.cv_loc	1 1 64 0                        # src/sha256.c:64:0
	.seh_startepilogue
	addq	$40, %rsp
	popq	%rbx
	popq	%rdi
	popq	%rsi
	popq	%r14
	popq	%r15
	popq	%rbp
	.seh_endepilogue
	retq
.Ltmp11:
.Lfunc_end1:
	.seh_endproc
                                        # -- End function
	.def	sha256_transform;
	.scl	3;
	.type	32;
	.endef
	.section	.rdata,"dr"
	.p2align	4, 0x0                          # -- Begin function sha256_transform
.LCPI2_0:
	.byte	1                               # 0x1
	.byte	5                               # 0x5
	.byte	9                               # 0x9
	.byte	13                              # 0xd
	.zero	1
	.zero	1
	.zero	1
	.zero	1
	.zero	1
	.zero	1
	.zero	1
	.zero	1
	.zero	1
	.zero	1
	.zero	1
	.zero	1
.LCPI2_1:
	.byte	2                               # 0x2
	.byte	6                               # 0x6
	.byte	10                              # 0xa
	.byte	14                              # 0xe
	.zero	1
	.zero	1
	.zero	1
	.zero	1
	.zero	1
	.zero	1
	.zero	1
	.zero	1
	.zero	1
	.zero	1
	.zero	1
	.zero	1
.LCPI2_2:
	.byte	3                               # 0x3
	.byte	7                               # 0x7
	.byte	11                              # 0xb
	.byte	15                              # 0xf
	.zero	1
	.zero	1
	.zero	1
	.zero	1
	.zero	1
	.zero	1
	.zero	1
	.zero	1
	.zero	1
	.zero	1
	.zero	1
	.zero	1
.LCPI2_3:
	.byte	1                               # 0x1
	.byte	5                               # 0x5
	.byte	9                               # 0x9
	.byte	13                              # 0xd
	.byte	0                               # 0x0
	.byte	0                               # 0x0
	.byte	0                               # 0x0
	.byte	0                               # 0x0
	.byte	0                               # 0x0
	.byte	0                               # 0x0
	.byte	0                               # 0x0
	.byte	0                               # 0x0
	.byte	0                               # 0x0
	.byte	0                               # 0x0
	.byte	0                               # 0x0
	.byte	0                               # 0x0
.LCPI2_4:
	.byte	2                               # 0x2
	.byte	6                               # 0x6
	.byte	10                              # 0xa
	.byte	14                              # 0xe
	.byte	0                               # 0x0
	.byte	0                               # 0x0
	.byte	0                               # 0x0
	.byte	0                               # 0x0
	.byte	0                               # 0x0
	.byte	0                               # 0x0
	.byte	0                               # 0x0
	.byte	0                               # 0x0
	.byte	0                               # 0x0
	.byte	0                               # 0x0
	.byte	0                               # 0x0
	.byte	0                               # 0x0
.LCPI2_5:
	.byte	3                               # 0x3
	.byte	7                               # 0x7
	.byte	11                              # 0xb
	.byte	15                              # 0xf
	.byte	0                               # 0x0
	.byte	0                               # 0x0
	.byte	0                               # 0x0
	.byte	0                               # 0x0
	.byte	0                               # 0x0
	.byte	0                               # 0x0
	.byte	0                               # 0x0
	.byte	0                               # 0x0
	.byte	0                               # 0x0
	.byte	0                               # 0x0
	.byte	0                               # 0x0
	.byte	0                               # 0x0
	.text
	.p2align	4
sha256_transform:                       # @sha256_transform
.Lfunc_begin2:
	.cv_func_id 2
	.cv_loc	2 1 23 0                        # src/sha256.c:23:0
.seh_proc sha256_transform
# %bb.0:
	#DEBUG_VALUE: sha256_transform:ctx <- $rcx
	#DEBUG_VALUE: sha256_transform:data <- $rdx
	pushq	%rbp
	.seh_pushreg %rbp
.Ltmp12:
	pushq	%r15
	.seh_pushreg %r15
	pushq	%r14
	.seh_pushreg %r14
	pushq	%r13
	.seh_pushreg %r13
	pushq	%r12
	.seh_pushreg %r12
	pushq	%rsi
	.seh_pushreg %rsi
	pushq	%rdi
	.seh_pushreg %rdi
	pushq	%rbx
	.seh_pushreg %rbx
	subq	$296, %rsp                      # imm = 0x128
	.seh_stackalloc 296
	leaq	128(%rsp), %rbp
	.seh_setframe %rbp, 128
	vmovaps	%xmm6, 144(%rbp)                # 16-byte Spill
	.seh_savexmm %xmm6, 272
	.seh_endprologue
.Ltmp13:
	#DEBUG_VALUE: sha256_transform:i <- 0
	#DEBUG_VALUE: sha256_transform:j <- 0
	.cv_loc	2 1 26 0                        # src/sha256.c:26:0
	vmovd	.LCPI2_3(%rip), %xmm0           # xmm0 = [1,5,9,13,0,0,0,0,0,0,0,0,0,0,0,0]
	vmovdqu	(%rdx), %xmm1
	vmovdqu	16(%rdx), %xmm2
	vpshufb	%xmm0, %xmm2, %xmm3
	vpshufb	%xmm0, %xmm1, %xmm4
	vpunpckldq	%xmm3, %xmm4, %xmm3     # xmm3 = xmm4[0],xmm3[0],xmm4[1],xmm3[1]
	vmovd	.LCPI2_4(%rip), %xmm4           # xmm4 = [2,6,10,14,0,0,0,0,0,0,0,0,0,0,0,0]
	vpshufb	%xmm4, %xmm2, %xmm5
	vpshufb	%xmm4, %xmm1, %xmm6
	vpunpckldq	%xmm5, %xmm6, %xmm5     # xmm5 = xmm6[0],xmm5[0],xmm6[1],xmm5[1]
	vmovd	.LCPI2_5(%rip), %xmm6           # xmm6 = [3,7,11,15,0,0,0,0,0,0,0,0,0,0,0,0]
	vpshufb	%xmm6, %xmm2, %xmm2
	vpshufb	%xmm6, %xmm1, %xmm1
	vpunpckldq	%xmm2, %xmm1, %xmm1     # xmm1 = xmm1[0],xmm2[0],xmm1[1],xmm2[1]
	vmovdqu	(%rdx), %ymm2
	vpslld	$24, %ymm2, %ymm2
	vpmovzxbd	%xmm3, %ymm3            # ymm3 = xmm3[0],zero,zero,zero,xmm3[1],zero,zero,zero,xmm3[2],zero,zero,zero,xmm3[3],zero,zero,zero,xmm3[4],zero,zero,zero,xmm3[5],zero,zero,zero,xmm3[6],zero,zero,zero,xmm3[7],zero,zero,zero
	vpslld	$16, %ymm3, %ymm3
	vpor	%ymm2, %ymm3, %ymm2
	vpmovzxbd	%xmm5, %ymm3            # ymm3 = xmm5[0],zero,zero,zero,xmm5[1],zero,zero,zero,xmm5[2],zero,zero,zero,xmm5[3],zero,zero,zero,xmm5[4],zero,zero,zero,xmm5[5],zero,zero,zero,xmm5[6],zero,zero,zero,xmm5[7],zero,zero,zero
	vpslld	$8, %ymm3, %ymm3
	vpmovzxbd	%xmm1, %ymm1            # ymm1 = xmm1[0],zero,zero,zero,xmm1[1],zero,zero,zero,xmm1[2],zero,zero,zero,xmm1[3],zero,zero,zero,xmm1[4],zero,zero,zero,xmm1[5],zero,zero,zero,xmm1[6],zero,zero,zero,xmm1[7],zero,zero,zero
	vpor	%ymm1, %ymm3, %ymm1
	vpor	%ymm1, %ymm2, %ymm1
	vmovdqu	%ymm1, -128(%rbp)
	vmovdqu	32(%rdx), %xmm1
	vmovdqu	48(%rdx), %xmm2
	vpshufb	%xmm0, %xmm2, %xmm3
	vpshufb	%xmm0, %xmm1, %xmm0
	vpunpckldq	%xmm3, %xmm0, %xmm0     # xmm0 = xmm0[0],xmm3[0],xmm0[1],xmm3[1]
	vpshufb	%xmm4, %xmm2, %xmm3
	vpshufb	%xmm4, %xmm1, %xmm4
	vpunpckldq	%xmm3, %xmm4, %xmm3     # xmm3 = xmm4[0],xmm3[0],xmm4[1],xmm3[1]
	vpshufb	%xmm6, %xmm2, %xmm2
	vpshufb	%xmm6, %xmm1, %xmm1
	vpunpckldq	%xmm2, %xmm1, %xmm1     # xmm1 = xmm1[0],xmm2[0],xmm1[1],xmm2[1]
	vmovdqu	32(%rdx), %ymm2
	vpslld	$24, %ymm2, %ymm2
	vpmovzxbd	%xmm0, %ymm0            # ymm0 = xmm0[0],zero,zero,zero,xmm0[1],zero,zero,zero,xmm0[2],zero,zero,zero,xmm0[3],zero,zero,zero,xmm0[4],zero,zero,zero,xmm0[5],zero,zero,zero,xmm0[6],zero,zero,zero,xmm0[7],zero,zero,zero
	vpslld	$16, %ymm0, %ymm0
	vpor	%ymm2, %ymm0, %ymm0
	vpmovzxbd	%xmm3, %ymm2            # ymm2 = xmm3[0],zero,zero,zero,xmm3[1],zero,zero,zero,xmm3[2],zero,zero,zero,xmm3[3],zero,zero,zero,xmm3[4],zero,zero,zero,xmm3[5],zero,zero,zero,xmm3[6],zero,zero,zero,xmm3[7],zero,zero,zero
	vpslld	$8, %ymm2, %ymm2
	vpmovzxbd	%xmm1, %ymm1            # ymm1 = xmm1[0],zero,zero,zero,xmm1[1],zero,zero,zero,xmm1[2],zero,zero,zero,xmm1[3],zero,zero,zero,xmm1[4],zero,zero,zero,xmm1[5],zero,zero,zero,xmm1[6],zero,zero,zero,xmm1[7],zero,zero,zero
	vpor	%ymm1, %ymm2, %ymm1
	vpor	%ymm1, %ymm0, %ymm0
	vmovdqu	%ymm0, -96(%rbp)
	movl	$16, %eax
.Ltmp14:
	#DEBUG_VALUE: sha256_transform:i <- [DW_OP_stack_value] 16
	.cv_loc	2 1 29 0                        # src/sha256.c:29:0
	movl	-128(%rbp), %edx
.Ltmp15:
	#DEBUG_VALUE: sha256_transform:data <- [DW_OP_LLVM_entry_value 1] $rdx
	.p2align	4
.LBB2_1:                                # =>This Inner Loop Header: Depth=1
	#DEBUG_VALUE: sha256_transform:ctx <- $rcx
	#DEBUG_VALUE: sha256_transform:data <- [DW_OP_LLVM_entry_value 1] $rdx
	#DEBUG_VALUE: sha256_transform:j <- 0
	#DEBUG_VALUE: sha256_transform:i <- $rax
	movl	-188(%rbp,%rax,4), %r11d
	movl	-136(%rbp,%rax,4), %r8d
	rorxl	$17, %r8d, %r9d
	rorxl	$19, %r8d, %r10d
	xorl	%r9d, %r10d
	shrl	$10, %r8d
	xorl	%r10d, %r8d
	addl	-156(%rbp,%rax,4), %r8d
	rorxl	$7, %r11d, %r9d
	rorxl	$18, %r11d, %r10d
	xorl	%r9d, %r10d
	movl	%r11d, %r9d
	shrl	$3, %r9d
	xorl	%r10d, %r9d
	addl	%edx, %r9d
	addl	%r8d, %r9d
	movl	%r9d, -128(%rbp,%rax,4)
	.cv_loc	2 1 28 0                        # src/sha256.c:28:0
	incq	%rax
.Ltmp16:
	#DEBUG_VALUE: sha256_transform:i <- $rax
	movl	%r11d, %edx
.Ltmp17:
	.cv_loc	2 1 28 0                        # src/sha256.c:28:0
	cmpq	$64, %rax
	jne	.LBB2_1
.Ltmp18:
# %bb.2:
	#DEBUG_VALUE: sha256_transform:ctx <- $rcx
	#DEBUG_VALUE: sha256_transform:data <- [DW_OP_LLVM_entry_value 1] $rdx
	#DEBUG_VALUE: sha256_transform:i <- $rax
	#DEBUG_VALUE: sha256_transform:j <- 0
	#DEBUG_VALUE: sha256_transform:a <- undef
	#DEBUG_VALUE: sha256_transform:b <- undef
	#DEBUG_VALUE: sha256_transform:c <- undef
	.cv_loc	2 1 31 0                        # src/sha256.c:31:0
	vmovdqu	8(%rcx), %xmm1
	movl	8(%rcx), %r9d
	movl	12(%rcx), %r14d
	movl	16(%rcx), %eax
.Ltmp19:
	movl	20(%rcx), %edi
.Ltmp20:
	#DEBUG_VALUE: sha256_transform:d <- undef
	#DEBUG_VALUE: sha256_transform:e <- undef
	#DEBUG_VALUE: sha256_transform:f <- undef
	#DEBUG_VALUE: sha256_transform:g <- undef
	.cv_loc	2 1 32 0                        # src/sha256.c:32:0
	vmovdqu	24(%rcx), %xmm0
	movl	24(%rcx), %r15d
	movl	28(%rcx), %r11d
	movl	32(%rcx), %r13d
	movq	%rcx, 136(%rbp)                 # 8-byte Spill
.Ltmp21:
	#DEBUG_VALUE: sha256_transform:ctx <- [DW_OP_plus_uconst 136] [$rbp+0]
	movl	36(%rcx), %r12d
	xorl	%edx, %edx
.Ltmp22:
	#DEBUG_VALUE: sha256_transform:h <- undef
	#DEBUG_VALUE: sha256_transform:i <- 0
	leaq	k(%rip), %rcx
.Ltmp23:
	.p2align	4
.LBB2_3:                                # =>This Inner Loop Header: Depth=1
	#DEBUG_VALUE: sha256_transform:ctx <- [DW_OP_plus_uconst 136] [$rbp+0]
	#DEBUG_VALUE: sha256_transform:data <- [DW_OP_LLVM_entry_value 1] $rdx
	#DEBUG_VALUE: sha256_transform:j <- 0
	.cv_loc	2 1 35 0                        # src/sha256.c:35:0
	movl	%eax, %ebx
	movl	%r15d, %esi
	movl	%r11d, %r8d
	movl	%r13d, %r10d
	movl	%r14d, %eax
.Ltmp24:
	#DEBUG_VALUE: sha256_transform:a <- $r9d
	#DEBUG_VALUE: sha256_transform:b <- $r14d
	#DEBUG_VALUE: sha256_transform:i <- [DW_OP_consts 4, DW_OP_div, DW_OP_stack_value] $rdx
	#DEBUG_VALUE: sha256_transform:h <- $r12d
	#DEBUG_VALUE: sha256_transform:g <- $r13d
	#DEBUG_VALUE: sha256_transform:f <- $r11d
	#DEBUG_VALUE: sha256_transform:e <- $r15d
	#DEBUG_VALUE: sha256_transform:d <- $edi
	#DEBUG_VALUE: sha256_transform:c <- $ebx
	rorxl	$6, %r15d, %r11d
.Ltmp25:
	#DEBUG_VALUE: sha256_transform:f <- $r8d
	rorxl	$11, %r15d, %r14d
.Ltmp26:
	#DEBUG_VALUE: sha256_transform:b <- $eax
	xorl	%r11d, %r14d
	rorxl	$25, %r15d, %r11d
	xorl	%r14d, %r11d
	movl	%r8d, %r14d
	andl	%r15d, %r14d
	andnl	%r13d, %r15d, %r13d
.Ltmp27:
	#DEBUG_VALUE: sha256_transform:g <- $r10d
	orl	%r14d, %r13d
	addl	%r12d, %r13d
	addl	%r11d, %r13d
	addl	(%rdx,%rcx), %r13d
	movl	%r9d, %r14d
	addl	-128(%rbp,%rdx), %r13d
.Ltmp28:
	#DEBUG_VALUE: sha256_transform:t1 <- $r13d
	.cv_loc	2 1 36 0                        # src/sha256.c:36:0
	rorxl	$2, %r9d, %r9d
.Ltmp29:
	#DEBUG_VALUE: sha256_transform:a <- $r14d
	rorxl	$13, %r14d, %r11d
	xorl	%r9d, %r11d
	rorxl	$22, %r14d, %r15d
.Ltmp30:
	#DEBUG_VALUE: sha256_transform:e <- $esi
	xorl	%r11d, %r15d
	movl	%eax, %r11d
	xorl	%ebx, %r11d
	andl	%r14d, %r11d
	movl	%eax, %r9d
	andl	%ebx, %r9d
	xorl	%r11d, %r9d
	addl	%r15d, %r9d
.Ltmp31:
	#DEBUG_VALUE: sha256_transform:t2 <- $r9d
	#DEBUG_VALUE: sha256_transform:h <- $r10d
	#DEBUG_VALUE: sha256_transform:g <- $r8d
	#DEBUG_VALUE: sha256_transform:f <- $esi
	.cv_loc	2 1 37 0                        # src/sha256.c:37:0
	movl	%edi, %r15d
.Ltmp32:
	#DEBUG_VALUE: sha256_transform:d <- $r15d
	addl	%r13d, %r15d
.Ltmp33:
	#DEBUG_VALUE: sha256_transform:d <- $edi
	#DEBUG_VALUE: sha256_transform:e <- $r15d
	#DEBUG_VALUE: sha256_transform:d <- $ebx
	#DEBUG_VALUE: sha256_transform:c <- $eax
	#DEBUG_VALUE: sha256_transform:b <- $r14d
	.cv_loc	2 1 38 0                        # src/sha256.c:38:0
	addl	%r13d, %r9d
.Ltmp34:
	#DEBUG_VALUE: sha256_transform:a <- $r9d
	#DEBUG_VALUE: sha256_transform:i <- [DW_OP_consts 4, DW_OP_div, DW_OP_consts 1, DW_OP_plus, DW_OP_stack_value] $rdx
	.cv_loc	2 1 34 0                        # src/sha256.c:34:0
	addq	$4, %rdx
.Ltmp35:
	movl	%r10d, %r12d
	movl	%r8d, %r13d
.Ltmp36:
	movl	%esi, %r11d
	movl	%ebx, %edi
	cmpq	$256, %rdx                      # imm = 0x100
	jne	.LBB2_3
.Ltmp37:
# %bb.4:
	#DEBUG_VALUE: sha256_transform:ctx <- [DW_OP_plus_uconst 136] [$rbp+0]
	#DEBUG_VALUE: sha256_transform:data <- [DW_OP_LLVM_entry_value 1] $rdx
	#DEBUG_VALUE: sha256_transform:j <- 0
	#DEBUG_VALUE: sha256_transform:a <- $r9d
	#DEBUG_VALUE: sha256_transform:b <- $r14d
	#DEBUG_VALUE: sha256_transform:c <- $eax
	#DEBUG_VALUE: sha256_transform:d <- $edi
	#DEBUG_VALUE: sha256_transform:e <- $r15d
	#DEBUG_VALUE: sha256_transform:f <- $esi
	#DEBUG_VALUE: sha256_transform:g <- $r13d
	#DEBUG_VALUE: sha256_transform:h <- $r12d
	.cv_loc	2 1 41 0                        # src/sha256.c:41:0
	vmovd	%r9d, %xmm2
	vpinsrd	$1, %r14d, %xmm2, %xmm2
	vpinsrd	$2, %eax, %xmm2, %xmm2
	vpinsrd	$3, %ebx, %xmm2, %xmm2
	vpaddd	%xmm1, %xmm2, %xmm1
	movq	136(%rbp), %rax                 # 8-byte Reload
.Ltmp38:
	vmovdqu	%xmm1, 8(%rax)
	.cv_loc	2 1 42 0                        # src/sha256.c:42:0
	vmovd	%r15d, %xmm1
	vpinsrd	$1, %esi, %xmm1, %xmm1
	vpinsrd	$2, %r8d, %xmm1, %xmm1
	vpinsrd	$3, %r10d, %xmm1, %xmm1
	vpaddd	%xmm0, %xmm1, %xmm0
	vmovdqu	%xmm0, 24(%rax)
	vmovaps	144(%rbp), %xmm6                # 16-byte Reload
	.cv_loc	2 1 43 0                        # src/sha256.c:43:0
	.seh_startepilogue
	addq	$296, %rsp                      # imm = 0x128
	popq	%rbx
	popq	%rdi
.Ltmp39:
	popq	%rsi
.Ltmp40:
	#DEBUG_VALUE: sha256_transform:f <- $r11d
	popq	%r12
.Ltmp41:
	#DEBUG_VALUE: sha256_transform:h <- $r10d
	popq	%r13
.Ltmp42:
	#DEBUG_VALUE: sha256_transform:g <- $r8d
	popq	%r14
.Ltmp43:
	popq	%r15
.Ltmp44:
	popq	%rbp
	.seh_endepilogue
	vzeroupper
	retq
.Ltmp45:
.Lfunc_end2:
	.seh_endproc
                                        # -- End function
	.def	sha256_final;
	.scl	2;
	.type	32;
	.endef
	.globl	sha256_final                    # -- Begin function sha256_final
	.p2align	4
sha256_final:                           # @sha256_final
.Lfunc_begin3:
	.cv_func_id 3
	.cv_loc	3 1 66 0                        # src/sha256.c:66:0
.seh_proc sha256_final
# %bb.0:
	#DEBUG_VALUE: sha256_final:ctx <- $rcx
	#DEBUG_VALUE: sha256_final:hash <- $rdx
	pushq	%rbp
	.seh_pushreg %rbp
	pushq	%rsi
	.seh_pushreg %rsi
	pushq	%rdi
	.seh_pushreg %rdi
	pushq	%rbx
	.seh_pushreg %rbx
	subq	$40, %rsp
	.seh_stackalloc 40
	leaq	32(%rsp), %rbp
	.seh_setframe %rbp, 32
	.seh_endprologue
	movq	%rdx, %rsi
	movq	%rcx, %rdi
.Ltmp46:
	.cv_loc	3 1 67 0                        # src/sha256.c:67:0
	movl	104(%rcx), %eax
.Ltmp47:
	#DEBUG_VALUE: sha256_final:i <- undef
	leaq	40(%rcx), %rbx
	movb	$-128, 40(%rcx,%rax)
.Ltmp48:
	cmpq	$55, %rax
	.cv_loc	3 1 68 0                        # src/sha256.c:68:0
	ja	.LBB3_3
.Ltmp49:
# %bb.1:
	#DEBUG_VALUE: sha256_final:ctx <- $rdi
	#DEBUG_VALUE: sha256_final:hash <- $rsi
	.cv_loc	3 1 70 0                        # src/sha256.c:70:0
	cmpl	$55, %eax
.Ltmp50:
	#DEBUG_VALUE: sha256_final:i <- [DW_OP_plus_uconst 1, DW_OP_stack_value] undef
	je	.LBB3_6
.Ltmp51:
# %bb.2:
	#DEBUG_VALUE: sha256_final:ctx <- $rdi
	#DEBUG_VALUE: sha256_final:hash <- $rsi
	leaq	41(%rdi,%rax), %rcx
	movl	$55, %r8d
	subl	%eax, %r8d
	xorl	%edx, %edx
	callq	memset
.Ltmp52:
	#DEBUG_VALUE: sha256_final:i <- undef
	.cv_loc	3 1 77 0                        # src/sha256.c:77:0
	jmp	.LBB3_6
.Ltmp53:
.LBB3_3:
	#DEBUG_VALUE: sha256_final:ctx <- $rdi
	#DEBUG_VALUE: sha256_final:hash <- $rsi
	.cv_loc	3 1 73 0                        # src/sha256.c:73:0
	movl	%eax, %ecx
	incl	%ecx
	cmpl	$63, %ecx
	ja	.LBB3_5
.Ltmp54:
# %bb.4:
	#DEBUG_VALUE: sha256_final:ctx <- $rdi
	#DEBUG_VALUE: sha256_final:hash <- $rsi
	cltq
	leaq	41(%rdi,%rax), %rcx
	movl	$62, %r8d
	subl	%eax, %r8d
	incq	%r8
	xorl	%edx, %edx
	callq	memset
.Ltmp55:
	#DEBUG_VALUE: sha256_final:i <- undef
.LBB3_5:
	#DEBUG_VALUE: sha256_final:ctx <- $rdi
	#DEBUG_VALUE: sha256_final:hash <- $rsi
	.cv_loc	3 1 74 0                        # src/sha256.c:74:0
	movq	%rdi, %rcx
	movq	%rbx, %rdx
	callq	sha256_transform
	.cv_loc	3 1 75 0                        # src/sha256.c:75:0
	vxorps	%xmm0, %xmm0, %xmm0
	vmovups	%ymm0, 24(%rbx)
	vmovups	%ymm0, (%rbx)
.Ltmp56:
.LBB3_6:
	#DEBUG_VALUE: sha256_final:ctx <- $rdi
	#DEBUG_VALUE: sha256_final:hash <- $rsi
	.cv_loc	3 1 77 0                        # src/sha256.c:77:0
	movl	104(%rdi), %eax
	shlq	$3, %rax
	addq	(%rdi), %rax
	movq	%rax, (%rdi)
	.cv_loc	3 1 78 0                        # src/sha256.c:78:0
	movb	%al, 103(%rdi)
	.cv_loc	3 1 79 0                        # src/sha256.c:79:0
	movb	%ah, 102(%rdi)
	.cv_loc	3 1 80 0                        # src/sha256.c:80:0
	movl	%eax, %ecx
	shrl	$16, %ecx
	movb	%cl, 101(%rdi)
	.cv_loc	3 1 81 0                        # src/sha256.c:81:0
	movl	%eax, %ecx
	shrl	$24, %ecx
	movb	%cl, 100(%rdi)
	.cv_loc	3 1 82 0                        # src/sha256.c:82:0
	movq	%rax, %rcx
	shrq	$32, %rcx
	movb	%cl, 99(%rdi)
	.cv_loc	3 1 83 0                        # src/sha256.c:83:0
	movq	%rax, %rcx
	shrq	$40, %rcx
	movb	%cl, 98(%rdi)
	.cv_loc	3 1 84 0                        # src/sha256.c:84:0
	movq	%rax, %rcx
	shrq	$48, %rcx
	movb	%cl, 97(%rdi)
	.cv_loc	3 1 85 0                        # src/sha256.c:85:0
	shrq	$56, %rax
	movb	%al, 96(%rdi)
	.cv_loc	3 1 86 0                        # src/sha256.c:86:0
	movq	%rdi, %rcx
	movq	%rbx, %rdx
	vzeroupper
	callq	sha256_transform
.Ltmp57:
	#DEBUG_VALUE: sha256_final:i <- 0
	#DEBUG_VALUE: sha256_final:i <- 0
	.cv_loc	3 1 88 0                        # src/sha256.c:88:0
	movzbl	11(%rdi), %eax
	movb	%al, (%rsi)
	.cv_loc	3 1 89 0                        # src/sha256.c:89:0
	movzbl	15(%rdi), %eax
	movb	%al, 4(%rsi)
	.cv_loc	3 1 90 0                        # src/sha256.c:90:0
	movzbl	19(%rdi), %eax
	movb	%al, 8(%rsi)
	.cv_loc	3 1 91 0                        # src/sha256.c:91:0
	movzbl	23(%rdi), %eax
	movb	%al, 12(%rsi)
	.cv_loc	3 1 92 0                        # src/sha256.c:92:0
	movzbl	27(%rdi), %eax
	movb	%al, 16(%rsi)
	.cv_loc	3 1 93 0                        # src/sha256.c:93:0
	movzbl	31(%rdi), %eax
	movb	%al, 20(%rsi)
	.cv_loc	3 1 94 0                        # src/sha256.c:94:0
	movzbl	35(%rdi), %eax
	movb	%al, 24(%rsi)
	.cv_loc	3 1 95 0                        # src/sha256.c:95:0
	movzbl	39(%rdi), %eax
	movb	%al, 28(%rsi)
.Ltmp58:
	#DEBUG_VALUE: sha256_final:i <- 1
	.cv_loc	3 1 88 0                        # src/sha256.c:88:0
	movzbl	10(%rdi), %eax
	movb	%al, 1(%rsi)
	.cv_loc	3 1 89 0                        # src/sha256.c:89:0
	movzbl	14(%rdi), %eax
	movb	%al, 5(%rsi)
	.cv_loc	3 1 90 0                        # src/sha256.c:90:0
	movzbl	18(%rdi), %eax
	movb	%al, 9(%rsi)
	.cv_loc	3 1 91 0                        # src/sha256.c:91:0
	movzbl	22(%rdi), %eax
	movb	%al, 13(%rsi)
	.cv_loc	3 1 92 0                        # src/sha256.c:92:0
	movzbl	26(%rdi), %eax
	movb	%al, 17(%rsi)
	.cv_loc	3 1 93 0                        # src/sha256.c:93:0
	movzbl	30(%rdi), %eax
	movb	%al, 21(%rsi)
	.cv_loc	3 1 94 0                        # src/sha256.c:94:0
	movzbl	34(%rdi), %eax
	movb	%al, 25(%rsi)
	.cv_loc	3 1 95 0                        # src/sha256.c:95:0
	movzbl	38(%rdi), %eax
	movb	%al, 29(%rsi)
.Ltmp59:
	#DEBUG_VALUE: sha256_final:i <- 2
	.cv_loc	3 1 88 0                        # src/sha256.c:88:0
	movzbl	9(%rdi), %eax
	movb	%al, 2(%rsi)
	.cv_loc	3 1 89 0                        # src/sha256.c:89:0
	movzbl	13(%rdi), %eax
	movb	%al, 6(%rsi)
	.cv_loc	3 1 90 0                        # src/sha256.c:90:0
	movzbl	17(%rdi), %eax
	movb	%al, 10(%rsi)
	.cv_loc	3 1 91 0                        # src/sha256.c:91:0
	movzbl	21(%rdi), %eax
	movb	%al, 14(%rsi)
	.cv_loc	3 1 92 0                        # src/sha256.c:92:0
	movzbl	25(%rdi), %eax
	movb	%al, 18(%rsi)
	.cv_loc	3 1 93 0                        # src/sha256.c:93:0
	movzbl	29(%rdi), %eax
	movb	%al, 22(%rsi)
	.cv_loc	3 1 94 0                        # src/sha256.c:94:0
	movzbl	33(%rdi), %eax
	movb	%al, 26(%rsi)
	.cv_loc	3 1 95 0                        # src/sha256.c:95:0
	movzbl	37(%rdi), %eax
	movb	%al, 30(%rsi)
.Ltmp60:
	#DEBUG_VALUE: sha256_final:i <- 3
	.cv_loc	3 1 88 0                        # src/sha256.c:88:0
	movzbl	8(%rdi), %eax
	movb	%al, 3(%rsi)
	.cv_loc	3 1 89 0                        # src/sha256.c:89:0
	movzbl	12(%rdi), %eax
	movb	%al, 7(%rsi)
	.cv_loc	3 1 90 0                        # src/sha256.c:90:0
	movzbl	16(%rdi), %eax
	movb	%al, 11(%rsi)
	.cv_loc	3 1 91 0                        # src/sha256.c:91:0
	movzbl	20(%rdi), %eax
	movb	%al, 15(%rsi)
	.cv_loc	3 1 92 0                        # src/sha256.c:92:0
	movzbl	24(%rdi), %eax
	movb	%al, 19(%rsi)
	.cv_loc	3 1 93 0                        # src/sha256.c:93:0
	movzbl	28(%rdi), %eax
	movb	%al, 23(%rsi)
	.cv_loc	3 1 94 0                        # src/sha256.c:94:0
	movzbl	32(%rdi), %eax
	movb	%al, 27(%rsi)
	.cv_loc	3 1 95 0                        # src/sha256.c:95:0
	movzbl	36(%rdi), %eax
	movb	%al, 31(%rsi)
.Ltmp61:
	#DEBUG_VALUE: sha256_final:i <- 4
	.cv_loc	3 1 97 0                        # src/sha256.c:97:0
	.seh_startepilogue
	addq	$40, %rsp
	popq	%rbx
	popq	%rdi
.Ltmp62:
	#DEBUG_VALUE: sha256_final:ctx <- [DW_OP_LLVM_entry_value 1] $rcx
	popq	%rsi
.Ltmp63:
	#DEBUG_VALUE: sha256_final:hash <- [DW_OP_LLVM_entry_value 1] $rdx
	popq	%rbp
	.seh_endepilogue
	retq
.Ltmp64:
.Lfunc_end3:
	.seh_endproc
                                        # -- End function
	.def	sha256;
	.scl	2;
	.type	32;
	.endef
	.section	.rdata,"dr"
	.p2align	5, 0x0                          # -- Begin function sha256
.LCPI4_0:
	.long	1779033703                      # 0x6a09e667
	.long	3144134277                      # 0xbb67ae85
	.long	1013904242                      # 0x3c6ef372
	.long	2773480762                      # 0xa54ff53a
	.long	1359893119                      # 0x510e527f
	.long	2600822924                      # 0x9b05688c
	.long	528734635                       # 0x1f83d9ab
	.long	1541459225                      # 0x5be0cd19
	.text
	.globl	sha256
	.p2align	4
sha256:                                 # @sha256
.Lfunc_begin4:
	.cv_func_id 4
	.cv_loc	4 1 99 0                        # src/sha256.c:99:0
.seh_proc sha256
# %bb.0:
	#DEBUG_VALUE: sha256:data <- $rcx
	#DEBUG_VALUE: sha256:len <- $rdx
	#DEBUG_VALUE: sha256:hash <- $r8
	pushq	%rbp
	.seh_pushreg %rbp
	pushq	%r15
	.seh_pushreg %r15
	pushq	%r14
	.seh_pushreg %r14
	pushq	%r12
	.seh_pushreg %r12
	pushq	%rsi
	.seh_pushreg %rsi
	pushq	%rdi
	.seh_pushreg %rdi
	pushq	%rbx
	.seh_pushreg %rbx
	subq	$144, %rsp
	.seh_stackalloc 144
	leaq	128(%rsp), %rbp
	.seh_setframe %rbp, 128
	.seh_endprologue
	movq	%r8, %rsi
.Ltmp65:
	#DEBUG_VALUE: sha256:ctx <- [DW_OP_constu 96, DW_OP_minus, DW_OP_deref] $rbp
	#DEBUG_VALUE: sha256_init:ctx <- [DW_OP_constu 96, DW_OP_minus, DW_OP_stack_value] $rbp
	.cv_inline_site_id 5 within 4 inlined_at 1 101 0
	.cv_loc	5 1 46 0                        # src/sha256.c:46:0
	movl	$0, 8(%rbp)
	.cv_loc	5 1 47 0                        # src/sha256.c:47:0
	movq	$0, -96(%rbp)
.Ltmp66:
	#DEBUG_VALUE: sha256:ctx <- [DW_OP_LLVM_fragment 64 32] 1779033703
	#DEBUG_VALUE: sha256:ctx <- [DW_OP_constu 96, DW_OP_minus, DW_OP_deref, DW_OP_LLVM_fragment 0 64] $rbp
	#DEBUG_VALUE: sha256:ctx <- [DW_OP_LLVM_fragment 96 32] -1150833019
	#DEBUG_VALUE: sha256:ctx <- [DW_OP_LLVM_fragment 128 32] 1013904242
	#DEBUG_VALUE: sha256:ctx <- [DW_OP_LLVM_fragment 160 32] -1521486534
	#DEBUG_VALUE: sha256:ctx <- [DW_OP_LLVM_fragment 192 32] 1359893119
	#DEBUG_VALUE: sha256:ctx <- [DW_OP_LLVM_fragment 224 32] -1694144372
	#DEBUG_VALUE: sha256:ctx <- [DW_OP_LLVM_fragment 256 32] 528734635
	#DEBUG_VALUE: sha256:ctx <- [DW_OP_constu 96, DW_OP_minus, DW_OP_plus_uconst 36, DW_OP_deref, DW_OP_LLVM_fragment 288 608] $rbp
	.cv_loc	5 1 48 0                        # src/sha256.c:48:0
	vmovaps	.LCPI4_0(%rip), %ymm0           # ymm0 = [1779033703,3144134277,1013904242,2773480762,1359893119,2600822924,528734635,1541459225]
	vmovups	%ymm0, -88(%rbp)
.Ltmp67:
	#DEBUG_VALUE: sha256:ctx <- [DW_OP_constu 96, DW_OP_minus, DW_OP_plus_uconst 32, DW_OP_deref, DW_OP_LLVM_fragment 256 640] $rbp
	#DEBUG_VALUE: sha256_update:ctx <- [DW_OP_constu 96, DW_OP_minus, DW_OP_stack_value] $rbp
	#DEBUG_VALUE: sha256_update:data <- undef
	#DEBUG_VALUE: sha256_update:len <- $rdx
	#DEBUG_VALUE: i <- 0
	.cv_inline_site_id 6 within 4 inlined_at 1 102 0
	.cv_loc	6 1 55 0                        # src/sha256.c:55:0
	testq	%rdx, %rdx
	je	.LBB4_5
.Ltmp68:
# %bb.1:
	#DEBUG_VALUE: sha256:data <- $rcx
	#DEBUG_VALUE: sha256:len <- $rdx
	#DEBUG_VALUE: sha256:hash <- $rsi
	#DEBUG_VALUE: sha256:ctx <- [DW_OP_LLVM_fragment 64 32] 1779033703
	#DEBUG_VALUE: sha256:ctx <- [DW_OP_constu 96, DW_OP_minus, DW_OP_deref, DW_OP_LLVM_fragment 0 64] $rbp
	#DEBUG_VALUE: sha256:ctx <- [DW_OP_LLVM_fragment 96 32] -1150833019
	#DEBUG_VALUE: sha256:ctx <- [DW_OP_LLVM_fragment 128 32] 1013904242
	#DEBUG_VALUE: sha256:ctx <- [DW_OP_LLVM_fragment 160 32] -1521486534
	#DEBUG_VALUE: sha256:ctx <- [DW_OP_LLVM_fragment 192 32] 1359893119
	#DEBUG_VALUE: sha256:ctx <- [DW_OP_LLVM_fragment 224 32] -1694144372
	#DEBUG_VALUE: sha256:ctx <- [DW_OP_constu 96, DW_OP_minus, DW_OP_plus_uconst 32, DW_OP_deref, DW_OP_LLVM_fragment 256 640] $rbp
	#DEBUG_VALUE: sha256_init:ctx <- [DW_OP_constu 96, DW_OP_minus, DW_OP_stack_value] $rbp
	#DEBUG_VALUE: sha256_update:ctx <- [DW_OP_constu 96, DW_OP_minus, DW_OP_stack_value] $rbp
	#DEBUG_VALUE: sha256_update:len <- $rdx
	#DEBUG_VALUE: i <- 0
	movq	%rdx, %rdi
	movq	%rcx, %rbx
	xorl	%eax, %eax
	leaq	-56(%rbp), %r14
	leaq	-96(%rbp), %r15
	xorl	%r12d, %r12d
	jmp	.LBB4_2
.Ltmp69:
	.p2align	4
.LBB4_4:                                #   in Loop: Header=BB4_2 Depth=1
	#DEBUG_VALUE: sha256:data <- $rbx
	#DEBUG_VALUE: sha256:len <- $rdi
	#DEBUG_VALUE: sha256:hash <- $rsi
	#DEBUG_VALUE: sha256:ctx <- [DW_OP_LLVM_fragment 64 32] 1779033703
	#DEBUG_VALUE: sha256:ctx <- [DW_OP_LLVM_fragment 96 32] -1150833019
	#DEBUG_VALUE: sha256:ctx <- [DW_OP_LLVM_fragment 128 32] 1013904242
	#DEBUG_VALUE: sha256:ctx <- [DW_OP_LLVM_fragment 160 32] -1521486534
	#DEBUG_VALUE: sha256:ctx <- [DW_OP_LLVM_fragment 192 32] 1359893119
	#DEBUG_VALUE: sha256:ctx <- [DW_OP_LLVM_fragment 224 32] -1694144372
	#DEBUG_VALUE: sha256:ctx <- [DW_OP_constu 96, DW_OP_minus, DW_OP_plus_uconst 32, DW_OP_deref, DW_OP_LLVM_fragment 256 640] $rbp
	#DEBUG_VALUE: sha256_update:ctx <- [DW_OP_constu 96, DW_OP_minus, DW_OP_stack_value] $rbp
	#DEBUG_VALUE: sha256_update:len <- $rdi
	#DEBUG_VALUE: i <- $r12
	.cv_loc	6 1 55 0                        # src/sha256.c:55:0
	incq	%r12
.Ltmp70:
	#DEBUG_VALUE: i <- $r12
	.cv_loc	6 1 55 0                        # src/sha256.c:55:0
	cmpq	%r12, %rdi
	je	.LBB4_5
.Ltmp71:
.LBB4_2:                                # =>This Inner Loop Header: Depth=1
	#DEBUG_VALUE: sha256:data <- $rbx
	#DEBUG_VALUE: sha256:len <- $rdi
	#DEBUG_VALUE: sha256:hash <- $rsi
	#DEBUG_VALUE: sha256:ctx <- [DW_OP_LLVM_fragment 64 32] 1779033703
	#DEBUG_VALUE: sha256:ctx <- [DW_OP_LLVM_fragment 96 32] -1150833019
	#DEBUG_VALUE: sha256:ctx <- [DW_OP_LLVM_fragment 128 32] 1013904242
	#DEBUG_VALUE: sha256:ctx <- [DW_OP_LLVM_fragment 160 32] -1521486534
	#DEBUG_VALUE: sha256:ctx <- [DW_OP_LLVM_fragment 192 32] 1359893119
	#DEBUG_VALUE: sha256:ctx <- [DW_OP_LLVM_fragment 224 32] -1694144372
	#DEBUG_VALUE: sha256:ctx <- [DW_OP_constu 96, DW_OP_minus, DW_OP_plus_uconst 32, DW_OP_deref, DW_OP_LLVM_fragment 256 640] $rbp
	#DEBUG_VALUE: sha256_update:ctx <- [DW_OP_constu 96, DW_OP_minus, DW_OP_stack_value] $rbp
	#DEBUG_VALUE: sha256_update:len <- $rdi
	#DEBUG_VALUE: i <- $r12
	.cv_loc	6 1 56 0                        # src/sha256.c:56:0
	movzbl	(%rbx,%r12), %ecx
	movl	%eax, %eax
	movb	%cl, -56(%rbp,%rax)
	.cv_loc	6 1 57 0                        # src/sha256.c:57:0
	movl	8(%rbp), %eax
	incl	%eax
	movl	%eax, 8(%rbp)
	#DEBUG_VALUE: sha256:ctx <- [DW_OP_constu 96, DW_OP_minus, DW_OP_plus_uconst 32, DW_OP_deref, DW_OP_LLVM_fragment 256 640] $rbp
	.cv_loc	6 1 58 0                        # src/sha256.c:58:0
	cmpl	$64, %eax
	jne	.LBB4_4
.Ltmp72:
# %bb.3:                                #   in Loop: Header=BB4_2 Depth=1
	#DEBUG_VALUE: sha256:data <- $rbx
	#DEBUG_VALUE: sha256:len <- $rdi
	#DEBUG_VALUE: sha256:hash <- $rsi
	#DEBUG_VALUE: sha256:ctx <- [DW_OP_LLVM_fragment 64 32] 1779033703
	#DEBUG_VALUE: sha256:ctx <- [DW_OP_LLVM_fragment 96 32] -1150833019
	#DEBUG_VALUE: sha256:ctx <- [DW_OP_LLVM_fragment 128 32] 1013904242
	#DEBUG_VALUE: sha256:ctx <- [DW_OP_LLVM_fragment 160 32] -1521486534
	#DEBUG_VALUE: sha256:ctx <- [DW_OP_LLVM_fragment 192 32] 1359893119
	#DEBUG_VALUE: sha256:ctx <- [DW_OP_LLVM_fragment 224 32] -1694144372
	#DEBUG_VALUE: sha256:ctx <- [DW_OP_constu 96, DW_OP_minus, DW_OP_plus_uconst 32, DW_OP_deref, DW_OP_LLVM_fragment 256 640] $rbp
	#DEBUG_VALUE: sha256_update:ctx <- [DW_OP_constu 96, DW_OP_minus, DW_OP_stack_value] $rbp
	#DEBUG_VALUE: sha256_update:len <- $rdi
	#DEBUG_VALUE: i <- $r12
	.cv_loc	6 1 59 0                        # src/sha256.c:59:0
	movq	%r15, %rcx
	movq	%r14, %rdx
	vzeroupper
	callq	sha256_transform
	.cv_loc	6 1 60 0                        # src/sha256.c:60:0
	addq	$512, -96(%rbp)                 # imm = 0x200
.Ltmp73:
	#DEBUG_VALUE: sha256:ctx <- [DW_OP_constu 96, DW_OP_minus, DW_OP_deref, DW_OP_LLVM_fragment 0 64] $rbp
	.cv_loc	6 1 61 0                        # src/sha256.c:61:0
	movl	$0, 8(%rbp)
	xorl	%eax, %eax
.Ltmp74:
	#DEBUG_VALUE: sha256:ctx <- [DW_OP_constu 96, DW_OP_minus, DW_OP_plus_uconst 32, DW_OP_deref, DW_OP_LLVM_fragment 256 640] $rbp
	jmp	.LBB4_4
.Ltmp75:
.LBB4_5:
	#DEBUG_VALUE: sha256:data <- [DW_OP_LLVM_entry_value 1] $rcx
	#DEBUG_VALUE: sha256:len <- [DW_OP_LLVM_entry_value 1] $rdx
	#DEBUG_VALUE: sha256:hash <- $rsi
	#DEBUG_VALUE: sha256:ctx <- [DW_OP_LLVM_fragment 64 32] 1779033703
	#DEBUG_VALUE: sha256:ctx <- [DW_OP_LLVM_fragment 96 32] -1150833019
	#DEBUG_VALUE: sha256:ctx <- [DW_OP_LLVM_fragment 128 32] 1013904242
	#DEBUG_VALUE: sha256:ctx <- [DW_OP_LLVM_fragment 160 32] -1521486534
	#DEBUG_VALUE: sha256:ctx <- [DW_OP_LLVM_fragment 192 32] 1359893119
	#DEBUG_VALUE: sha256:ctx <- [DW_OP_LLVM_fragment 224 32] -1694144372
	#DEBUG_VALUE: sha256:ctx <- [DW_OP_constu 96, DW_OP_minus, DW_OP_plus_uconst 32, DW_OP_deref, DW_OP_LLVM_fragment 256 640] $rbp
	.cv_loc	4 1 103 0                       # src/sha256.c:103:0
	leaq	-96(%rbp), %rcx
	movq	%rsi, %rdx
	vzeroupper
	callq	sha256_final
	.cv_loc	4 1 104 0                       # src/sha256.c:104:0
	nop
	.seh_startepilogue
	addq	$144, %rsp
	popq	%rbx
	popq	%rdi
	popq	%rsi
.Ltmp76:
	#DEBUG_VALUE: sha256:hash <- [DW_OP_LLVM_entry_value 1] $r8
	popq	%r12
	popq	%r14
	popq	%r15
	popq	%rbp
	.seh_endepilogue
	retq
.Ltmp77:
.Lfunc_end4:
	.seh_endproc
                                        # -- End function
	.section	.rdata,"dr"
	.p2align	4, 0x0                          # @k
k:
	.long	1116352408                      # 0x428a2f98
	.long	1899447441                      # 0x71374491
	.long	3049323471                      # 0xb5c0fbcf
	.long	3921009573                      # 0xe9b5dba5
	.long	961987163                       # 0x3956c25b
	.long	1508970993                      # 0x59f111f1
	.long	2453635748                      # 0x923f82a4
	.long	2870763221                      # 0xab1c5ed5
	.long	3624381080                      # 0xd807aa98
	.long	310598401                       # 0x12835b01
	.long	607225278                       # 0x243185be
	.long	1426881987                      # 0x550c7dc3
	.long	1925078388                      # 0x72be5d74
	.long	2162078206                      # 0x80deb1fe
	.long	2614888103                      # 0x9bdc06a7
	.long	3248222580                      # 0xc19bf174
	.long	3835390401                      # 0xe49b69c1
	.long	4022224774                      # 0xefbe4786
	.long	264347078                       # 0xfc19dc6
	.long	604807628                       # 0x240ca1cc
	.long	770255983                       # 0x2de92c6f
	.long	1249150122                      # 0x4a7484aa
	.long	1555081692                      # 0x5cb0a9dc
	.long	1996064986                      # 0x76f988da
	.long	2554220882                      # 0x983e5152
	.long	2821834349                      # 0xa831c66d
	.long	2952996808                      # 0xb00327c8
	.long	3210313671                      # 0xbf597fc7
	.long	3336571891                      # 0xc6e00bf3
	.long	3584528711                      # 0xd5a79147
	.long	113926993                       # 0x6ca6351
	.long	338241895                       # 0x14292967
	.long	666307205                       # 0x27b70a85
	.long	773529912                       # 0x2e1b2138
	.long	1294757372                      # 0x4d2c6dfc
	.long	1396182291                      # 0x53380d13
	.long	1695183700                      # 0x650a7354
	.long	1986661051                      # 0x766a0abb
	.long	2177026350                      # 0x81c2c92e
	.long	2456956037                      # 0x92722c85
	.long	2730485921                      # 0xa2bfe8a1
	.long	2820302411                      # 0xa81a664b
	.long	3259730800                      # 0xc24b8b70
	.long	3345764771                      # 0xc76c51a3
	.long	3516065817                      # 0xd192e819
	.long	3600352804                      # 0xd6990624
	.long	4094571909                      # 0xf40e3585
	.long	275423344                       # 0x106aa070
	.long	430227734                       # 0x19a4c116
	.long	506948616                       # 0x1e376c08
	.long	659060556                       # 0x2748774c
	.long	883997877                       # 0x34b0bcb5
	.long	958139571                       # 0x391c0cb3
	.long	1322822218                      # 0x4ed8aa4a
	.long	1537002063                      # 0x5b9cca4f
	.long	1747873779                      # 0x682e6ff3
	.long	1955562222                      # 0x748f82ee
	.long	2024104815                      # 0x78a5636f
	.long	2227730452                      # 0x84c87814
	.long	2361852424                      # 0x8cc70208
	.long	2428436474                      # 0x90befffa
	.long	2756734187                      # 0xa4506ceb
	.long	3204031479                      # 0xbef9a3f7
	.long	3329325298                      # 0xc67178f2

	.section	.debug$S,"dr"
	.p2align	2, 0x0
	.long	4                               # Debug section magic
	.long	241
	.long	.Ltmp79-.Ltmp78                 # Subsection size
.Ltmp78:
	.short	.Ltmp81-.Ltmp80                 # Record length
.Ltmp80:
	.short	4353                            # Record kind: S_OBJNAME
	.long	0                               # Signature
	.asciz	"C:/Users/nobre/AppData/Local/zig/tmp/ddbb2fcb0f4afbe2-sha256.s" # Object name
	.p2align	2, 0x0
.Ltmp81:
	.short	.Ltmp83-.Ltmp82                 # Record length
.Ltmp82:
	.short	4412                            # Record kind: S_COMPILE3
	.long	0                               # Flags and language
	.short	208                             # CPUType
	.short	21                              # Frontend version
	.short	1
	.short	0
	.short	0
	.short	21010                           # Backend version
	.short	0
	.short	0
	.short	0
	.asciz	"clang version 21.1.0"          # Null-terminated compiler version string
	.p2align	2, 0x0
.Ltmp83:
.Ltmp79:
	.p2align	2, 0x0
	.long	246                             # Inlinee lines subsection
	.long	.Ltmp85-.Ltmp84                 # Subsection size
.Ltmp84:
	.long	0                               # Inlinee lines signature

                                        # Inlined function sha256_init starts at src/sha256.c:45
	.long	4106                            # Type index of inlined function
	.cv_filechecksumoffset	1               # Offset into filechecksum table
	.long	45                              # Starting line number

                                        # Inlined function sha256_update starts at src/sha256.c:54
	.long	4111                            # Type index of inlined function
	.cv_filechecksumoffset	1               # Offset into filechecksum table
	.long	54                              # Starting line number
.Ltmp85:
	.p2align	2, 0x0
	.long	241                             # Symbol subsection for sha256_init
	.long	.Ltmp87-.Ltmp86                 # Subsection size
.Ltmp86:
	.short	.Ltmp89-.Ltmp88                 # Record length
.Ltmp88:
	.short	4423                            # Record kind: S_GPROC32_ID
	.long	0                               # PtrParent
	.long	0                               # PtrEnd
	.long	0                               # PtrNext
	.long	.Lfunc_end0-sha256_init         # Code size
	.long	0                               # Offset after prologue
	.long	0                               # Offset before epilogue
	.long	4106                            # Function type index
	.secrel32	sha256_init             # Function section relative address
	.secidx	sha256_init                     # Function section index
	.byte	129                             # Flags
	.asciz	"sha256_init"                   # Function name
	.p2align	2, 0x0
.Ltmp89:
	.short	.Ltmp91-.Ltmp90                 # Record length
.Ltmp90:
	.short	4114                            # Record kind: S_FRAMEPROC
	.long	8                               # FrameSize
	.long	0                               # Padding
	.long	0                               # Offset of padding
	.long	0                               # Bytes of callee saved registers
	.long	0                               # Exception handler offset
	.short	0                               # Exception handler section
	.long	1220608                         # Flags (defines frame register)
	.p2align	2, 0x0
.Ltmp91:
	.short	.Ltmp93-.Ltmp92                 # Record length
.Ltmp92:
	.short	4414                            # Record kind: S_LOCAL
	.long	4097                            # TypeIndex
	.short	1                               # Flags
	.asciz	"ctx"
	.p2align	2, 0x0
.Ltmp93:
	.cv_def_range	 .Lfunc_begin0 .Lfunc_end0, reg, 330
	.short	2                               # Record length
	.short	4431                            # Record kind: S_PROC_ID_END
.Ltmp87:
	.p2align	2, 0x0
	.cv_linetable	0, sha256_init, .Lfunc_end0
	.long	241                             # Symbol subsection for sha256_update
	.long	.Ltmp95-.Ltmp94                 # Subsection size
.Ltmp94:
	.short	.Ltmp97-.Ltmp96                 # Record length
.Ltmp96:
	.short	4423                            # Record kind: S_GPROC32_ID
	.long	0                               # PtrParent
	.long	0                               # PtrEnd
	.long	0                               # PtrNext
	.long	.Lfunc_end1-sha256_update       # Code size
	.long	0                               # Offset after prologue
	.long	0                               # Offset before epilogue
	.long	4111                            # Function type index
	.secrel32	sha256_update           # Function section relative address
	.secidx	sha256_update                   # Function section index
	.byte	129                             # Flags
	.asciz	"sha256_update"                 # Function name
	.p2align	2, 0x0
.Ltmp97:
	.short	.Ltmp99-.Ltmp98                 # Record length
.Ltmp98:
	.short	4114                            # Record kind: S_FRAMEPROC
	.long	48                              # FrameSize
	.long	0                               # Padding
	.long	0                               # Offset of padding
	.long	40                              # Bytes of callee saved registers
	.long	0                               # Exception handler offset
	.short	0                               # Exception handler section
	.long	1220608                         # Flags (defines frame register)
	.p2align	2, 0x0
.Ltmp99:
	.short	.Ltmp101-.Ltmp100               # Record length
.Ltmp100:
	.short	4414                            # Record kind: S_LOCAL
	.long	4097                            # TypeIndex
	.short	1                               # Flags
	.asciz	"ctx"
	.p2align	2, 0x0
.Ltmp101:
	.cv_def_range	 .Lfunc_begin1 .Ltmp6, reg, 330
	.cv_def_range	 .Ltmp6 .Ltmp10, reg, 329
	.short	.Ltmp103-.Ltmp102               # Record length
.Ltmp102:
	.short	4414                            # Record kind: S_LOCAL
	.long	4108                            # TypeIndex
	.short	1                               # Flags
	.asciz	"data"
	.p2align	2, 0x0
.Ltmp103:
	.cv_def_range	 .Lfunc_begin1 .Ltmp6, reg, 331
	.cv_def_range	 .Ltmp6 .Ltmp10, reg, 333
	.short	.Ltmp105-.Ltmp104               # Record length
.Ltmp104:
	.short	4414                            # Record kind: S_LOCAL
	.long	35                              # TypeIndex
	.short	1                               # Flags
	.asciz	"len"
	.p2align	2, 0x0
.Ltmp105:
	.cv_def_range	 .Lfunc_begin1 .Ltmp6, reg, 336
	.cv_def_range	 .Ltmp6 .Ltmp10, reg, 332
	.short	.Ltmp107-.Ltmp106               # Record length
.Ltmp106:
	.short	4355                            # Record kind: S_BLOCK32
	.long	0                               # PtrParent
	.long	0                               # PtrEnd
	.long	.Ltmp10-.Ltmp2                  # Code size
	.secrel32	.Ltmp2                  # Function section relative address
	.secidx	.Lfunc_begin1                   # Function section index
	.byte	0                               # Lexical block name
	.p2align	2, 0x0
.Ltmp107:
	.short	.Ltmp109-.Ltmp108               # Record length
.Ltmp108:
	.short	4359                            # Record kind: S_CONSTANT
	.long	35                              # Type
	.byte	0x00, 0x00                      # Value
	.asciz	"i"                             # Name
	.p2align	2, 0x0
.Ltmp109:
	.short	2                               # Record length
	.short	6                               # Record kind: S_END
	.short	2                               # Record length
	.short	4431                            # Record kind: S_PROC_ID_END
.Ltmp95:
	.p2align	2, 0x0
	.cv_linetable	1, sha256_update, .Lfunc_end1
	.long	241                             # Symbol subsection for sha256_transform
	.long	.Ltmp111-.Ltmp110               # Subsection size
.Ltmp110:
	.short	.Ltmp113-.Ltmp112               # Record length
.Ltmp112:
	.short	4422                            # Record kind: S_LPROC32_ID
	.long	0                               # PtrParent
	.long	0                               # PtrEnd
	.long	0                               # PtrNext
	.long	.Lfunc_end2-sha256_transform    # Code size
	.long	0                               # Offset after prologue
	.long	0                               # Offset before epilogue
	.long	4114                            # Function type index
	.secrel32	sha256_transform        # Function section relative address
	.secidx	sha256_transform                # Function section index
	.byte	129                             # Flags
	.asciz	"sha256_transform"              # Function name
	.p2align	2, 0x0
.Ltmp113:
	.short	.Ltmp115-.Ltmp114               # Record length
.Ltmp114:
	.short	4114                            # Record kind: S_FRAMEPROC
	.long	304                             # FrameSize
	.long	0                               # Padding
	.long	0                               # Offset of padding
	.long	56                              # Bytes of callee saved registers
	.long	0                               # Exception handler offset
	.short	0                               # Exception handler section
	.long	1220608                         # Flags (defines frame register)
	.p2align	2, 0x0
.Ltmp115:
	.short	.Ltmp117-.Ltmp116               # Record length
.Ltmp116:
	.short	4414                            # Record kind: S_LOCAL
	.long	4097                            # TypeIndex
	.short	1                               # Flags
	.asciz	"ctx"
	.p2align	2, 0x0
.Ltmp117:
	.cv_def_range	 .Lfunc_begin2 .Ltmp21, reg, 330
	.cv_def_range	 .Ltmp21 .Lfunc_end2, frame_ptr_rel, 136
	.short	.Ltmp119-.Ltmp118               # Record length
.Ltmp118:
	.short	4414                            # Record kind: S_LOCAL
	.long	4108                            # TypeIndex
	.short	1                               # Flags
	.asciz	"data"
	.p2align	2, 0x0
.Ltmp119:
	.cv_def_range	 .Lfunc_begin2 .Ltmp15, reg, 331
	.short	.Ltmp121-.Ltmp120               # Record length
.Ltmp120:
	.short	4414                            # Record kind: S_LOCAL
	.long	4115                            # TypeIndex
	.short	0                               # Flags
	.asciz	"m"
	.p2align	2, 0x0
.Ltmp121:
	.cv_def_range	 .Ltmp12 .Ltmp45, frame_ptr_rel, -128
	.short	.Ltmp123-.Ltmp122               # Record length
.Ltmp122:
	.short	4359                            # Record kind: S_CONSTANT
	.long	117                             # Type
	.byte	0x00, 0x00                      # Value
	.asciz	"i"                             # Name
	.p2align	2, 0x0
.Ltmp123:
	.short	.Ltmp125-.Ltmp124               # Record length
.Ltmp124:
	.short	4359                            # Record kind: S_CONSTANT
	.long	117                             # Type
	.byte	0x00, 0x00                      # Value
	.asciz	"j"                             # Name
	.p2align	2, 0x0
.Ltmp125:
	.short	.Ltmp127-.Ltmp126               # Record length
.Ltmp126:
	.short	4414                            # Record kind: S_LOCAL
	.long	117                             # TypeIndex
	.short	0                               # Flags
	.asciz	"a"
	.p2align	2, 0x0
.Ltmp127:
	.cv_def_range	 .Ltmp24 .Ltmp29 .Ltmp34 .Lfunc_end2, reg, 361
	.cv_def_range	 .Ltmp29 .Ltmp34, reg, 366
	.short	.Ltmp129-.Ltmp128               # Record length
.Ltmp128:
	.short	4414                            # Record kind: S_LOCAL
	.long	117                             # TypeIndex
	.short	0                               # Flags
	.asciz	"b"
	.p2align	2, 0x0
.Ltmp129:
	.cv_def_range	 .Ltmp24 .Ltmp26 .Ltmp33 .Ltmp43, reg, 366
	.cv_def_range	 .Ltmp26 .Ltmp33, reg, 17
	.short	.Ltmp131-.Ltmp130               # Record length
.Ltmp130:
	.short	4414                            # Record kind: S_LOCAL
	.long	117                             # TypeIndex
	.short	0                               # Flags
	.asciz	"c"
	.p2align	2, 0x0
.Ltmp131:
	.cv_def_range	 .Ltmp24 .Ltmp33, reg, 20
	.cv_def_range	 .Ltmp33 .Ltmp38, reg, 17
	.short	.Ltmp133-.Ltmp132               # Record length
.Ltmp132:
	.short	4414                            # Record kind: S_LOCAL
	.long	117                             # TypeIndex
	.short	0                               # Flags
	.asciz	"d"
	.p2align	2, 0x0
.Ltmp133:
	.cv_def_range	 .Ltmp24 .Ltmp32 .Ltmp33 .Ltmp33 .Ltmp37 .Ltmp39, reg, 24
	.cv_def_range	 .Ltmp32 .Ltmp33, reg, 367
	.cv_def_range	 .Ltmp33 .Ltmp37, reg, 20
	.short	.Ltmp135-.Ltmp134               # Record length
.Ltmp134:
	.short	4414                            # Record kind: S_LOCAL
	.long	117                             # TypeIndex
	.short	0                               # Flags
	.asciz	"e"
	.p2align	2, 0x0
.Ltmp135:
	.cv_def_range	 .Ltmp24 .Ltmp30 .Ltmp33 .Ltmp44, reg, 367
	.cv_def_range	 .Ltmp30 .Ltmp33, reg, 23
	.short	.Ltmp137-.Ltmp136               # Record length
.Ltmp136:
	.short	4414                            # Record kind: S_LOCAL
	.long	117                             # TypeIndex
	.short	0                               # Flags
	.asciz	"f"
	.p2align	2, 0x0
.Ltmp137:
	.cv_def_range	 .Ltmp24 .Ltmp25 .Ltmp40 .Lfunc_end2, reg, 363
	.cv_def_range	 .Ltmp25 .Ltmp31, reg, 360
	.cv_def_range	 .Ltmp31 .Ltmp40, reg, 23
	.short	.Ltmp139-.Ltmp138               # Record length
.Ltmp138:
	.short	4414                            # Record kind: S_LOCAL
	.long	117                             # TypeIndex
	.short	0                               # Flags
	.asciz	"g"
	.p2align	2, 0x0
.Ltmp139:
	.cv_def_range	 .Ltmp24 .Ltmp27 .Ltmp37 .Ltmp42, reg, 365
	.cv_def_range	 .Ltmp27 .Ltmp31, reg, 362
	.cv_def_range	 .Ltmp31 .Ltmp37 .Ltmp42 .Lfunc_end2, reg, 360
	.short	.Ltmp141-.Ltmp140               # Record length
.Ltmp140:
	.short	4414                            # Record kind: S_LOCAL
	.long	117                             # TypeIndex
	.short	0                               # Flags
	.asciz	"h"
	.p2align	2, 0x0
.Ltmp141:
	.cv_def_range	 .Ltmp24 .Ltmp31 .Ltmp37 .Ltmp41, reg, 364
	.cv_def_range	 .Ltmp31 .Ltmp37 .Ltmp41 .Lfunc_end2, reg, 362
	.short	.Ltmp143-.Ltmp142               # Record length
.Ltmp142:
	.short	4414                            # Record kind: S_LOCAL
	.long	117                             # TypeIndex
	.short	0                               # Flags
	.asciz	"t1"
	.p2align	2, 0x0
.Ltmp143:
	.cv_def_range	 .Ltmp28 .Ltmp36, reg, 365
	.short	.Ltmp145-.Ltmp144               # Record length
.Ltmp144:
	.short	4414                            # Record kind: S_LOCAL
	.long	117                             # TypeIndex
	.short	0                               # Flags
	.asciz	"t2"
	.p2align	2, 0x0
.Ltmp145:
	.cv_def_range	 .Ltmp31 .Ltmp34, reg, 361
	.short	2                               # Record length
	.short	4431                            # Record kind: S_PROC_ID_END
.Ltmp111:
	.p2align	2, 0x0
	.cv_linetable	2, sha256_transform, .Lfunc_end2
	.long	241                             # Symbol subsection for sha256_final
	.long	.Ltmp147-.Ltmp146               # Subsection size
.Ltmp146:
	.short	.Ltmp149-.Ltmp148               # Record length
.Ltmp148:
	.short	4423                            # Record kind: S_GPROC32_ID
	.long	0                               # PtrParent
	.long	0                               # PtrEnd
	.long	0                               # PtrNext
	.long	.Lfunc_end3-sha256_final        # Code size
	.long	0                               # Offset after prologue
	.long	0                               # Offset before epilogue
	.long	4118                            # Function type index
	.secrel32	sha256_final            # Function section relative address
	.secidx	sha256_final                    # Function section index
	.byte	129                             # Flags
	.asciz	"sha256_final"                  # Function name
	.p2align	2, 0x0
.Ltmp149:
	.short	.Ltmp151-.Ltmp150               # Record length
.Ltmp150:
	.short	4114                            # Record kind: S_FRAMEPROC
	.long	48                              # FrameSize
	.long	0                               # Padding
	.long	0                               # Offset of padding
	.long	24                              # Bytes of callee saved registers
	.long	0                               # Exception handler offset
	.short	0                               # Exception handler section
	.long	1220608                         # Flags (defines frame register)
	.p2align	2, 0x0
.Ltmp151:
	.short	.Ltmp153-.Ltmp152               # Record length
.Ltmp152:
	.short	4414                            # Record kind: S_LOCAL
	.long	4097                            # TypeIndex
	.short	1                               # Flags
	.asciz	"ctx"
	.p2align	2, 0x0
.Ltmp153:
	.cv_def_range	 .Lfunc_begin3 .Ltmp49, reg, 330
	.cv_def_range	 .Ltmp49 .Ltmp62, reg, 333
	.short	.Ltmp155-.Ltmp154               # Record length
.Ltmp154:
	.short	4414                            # Record kind: S_LOCAL
	.long	1568                            # TypeIndex
	.short	1                               # Flags
	.asciz	"hash"
	.p2align	2, 0x0
.Ltmp155:
	.cv_def_range	 .Lfunc_begin3 .Ltmp49, reg, 331
	.cv_def_range	 .Ltmp49 .Ltmp63, reg, 332
	.short	.Ltmp157-.Ltmp156               # Record length
.Ltmp156:
	.short	4359                            # Record kind: S_CONSTANT
	.long	117                             # Type
	.byte	0x04, 0x00                      # Value
	.asciz	"i"                             # Name
	.p2align	2, 0x0
.Ltmp157:
	.short	2                               # Record length
	.short	4431                            # Record kind: S_PROC_ID_END
.Ltmp147:
	.p2align	2, 0x0
	.cv_linetable	3, sha256_final, .Lfunc_end3
	.long	241                             # Symbol subsection for sha256
	.long	.Ltmp159-.Ltmp158               # Subsection size
.Ltmp158:
	.short	.Ltmp161-.Ltmp160               # Record length
.Ltmp160:
	.short	4423                            # Record kind: S_GPROC32_ID
	.long	0                               # PtrParent
	.long	0                               # PtrEnd
	.long	0                               # PtrNext
	.long	.Lfunc_end4-sha256              # Code size
	.long	0                               # Offset after prologue
	.long	0                               # Offset before epilogue
	.long	4121                            # Function type index
	.secrel32	sha256                  # Function section relative address
	.secidx	sha256                          # Function section index
	.byte	129                             # Flags
	.asciz	"sha256"                        # Function name
	.p2align	2, 0x0
.Ltmp161:
	.short	.Ltmp163-.Ltmp162               # Record length
.Ltmp162:
	.short	4114                            # Record kind: S_FRAMEPROC
	.long	152                             # FrameSize
	.long	0                               # Padding
	.long	0                               # Offset of padding
	.long	48                              # Bytes of callee saved registers
	.long	0                               # Exception handler offset
	.short	0                               # Exception handler section
	.long	1220608                         # Flags (defines frame register)
	.p2align	2, 0x0
.Ltmp163:
	.short	.Ltmp165-.Ltmp164               # Record length
.Ltmp164:
	.short	4456                            # Record kind: S_INLINEES
	.long	2                               # Count
	.long	4106                            # Inlinee
	.long	4111                            # Inlinee
	.p2align	2, 0x0
.Ltmp165:
	.short	.Ltmp167-.Ltmp166               # Record length
.Ltmp166:
	.short	4414                            # Record kind: S_LOCAL
	.long	4108                            # TypeIndex
	.short	1                               # Flags
	.asciz	"data"
	.p2align	2, 0x0
.Ltmp167:
	.cv_def_range	 .Lfunc_begin4 .Ltmp69, reg, 330
	.cv_def_range	 .Ltmp69 .Ltmp75, reg, 329
	.short	.Ltmp169-.Ltmp168               # Record length
.Ltmp168:
	.short	4414                            # Record kind: S_LOCAL
	.long	35                              # TypeIndex
	.short	1                               # Flags
	.asciz	"len"
	.p2align	2, 0x0
.Ltmp169:
	.cv_def_range	 .Lfunc_begin4 .Ltmp69, reg, 331
	.cv_def_range	 .Ltmp69 .Ltmp75, reg, 333
	.short	.Ltmp171-.Ltmp170               # Record length
.Ltmp170:
	.short	4414                            # Record kind: S_LOCAL
	.long	1568                            # TypeIndex
	.short	1                               # Flags
	.asciz	"hash"
	.p2align	2, 0x0
.Ltmp171:
	.cv_def_range	 .Lfunc_begin4 .Ltmp68, reg, 336
	.cv_def_range	 .Ltmp68 .Ltmp76, reg, 332
	.short	.Ltmp173-.Ltmp172               # Record length
.Ltmp172:
	.short	4359                            # Record kind: S_CONSTANT
	.long	4096                            # Type
	.byte	0x03, 0x80, 0x8c, 0x68          # Value
	.byte	0x05, 0x9b
	.asciz	"ctx"                           # Name
	.p2align	2, 0x0
.Ltmp173:
	.short	.Ltmp175-.Ltmp174               # Record length
.Ltmp174:
	.short	4429                            # Record kind: S_INLINESITE
	.long	0                               # PtrParent
	.long	0                               # PtrEnd
	.long	4106                            # Inlinee type index
	.cv_inline_linetable	5 1 45 .Lfunc_begin4 .Lfunc_end4
	.p2align	2, 0x0
.Ltmp175:
	.short	.Ltmp177-.Ltmp176               # Record length
.Ltmp176:
	.short	4414                            # Record kind: S_LOCAL
	.long	4097                            # TypeIndex
	.short	257                             # Flags
	.asciz	"ctx"
	.p2align	2, 0x0
.Ltmp177:
	.short	2                               # Record length
	.short	4430                            # Record kind: S_INLINESITE_END
	.short	.Ltmp179-.Ltmp178               # Record length
.Ltmp178:
	.short	4429                            # Record kind: S_INLINESITE
	.long	0                               # PtrParent
	.long	0                               # PtrEnd
	.long	4111                            # Inlinee type index
	.cv_inline_linetable	6 1 54 .Lfunc_begin4 .Lfunc_end4
	.p2align	2, 0x0
.Ltmp179:
	.short	.Ltmp181-.Ltmp180               # Record length
.Ltmp180:
	.short	4414                            # Record kind: S_LOCAL
	.long	4097                            # TypeIndex
	.short	257                             # Flags
	.asciz	"ctx"
	.p2align	2, 0x0
.Ltmp181:
	.short	.Ltmp183-.Ltmp182               # Record length
.Ltmp182:
	.short	4414                            # Record kind: S_LOCAL
	.long	4108                            # TypeIndex
	.short	257                             # Flags
	.asciz	"data"
	.p2align	2, 0x0
.Ltmp183:
	.short	.Ltmp185-.Ltmp184               # Record length
.Ltmp184:
	.short	4414                            # Record kind: S_LOCAL
	.long	35                              # TypeIndex
	.short	1                               # Flags
	.asciz	"len"
	.p2align	2, 0x0
.Ltmp185:
	.cv_def_range	 .Ltmp67 .Ltmp69, reg, 331
	.cv_def_range	 .Ltmp69 .Ltmp75, reg, 333
	.short	.Ltmp187-.Ltmp186               # Record length
.Ltmp186:
	.short	4359                            # Record kind: S_CONSTANT
	.long	35                              # Type
	.byte	0x00, 0x00                      # Value
	.asciz	"i"                             # Name
	.p2align	2, 0x0
.Ltmp187:
	.short	2                               # Record length
	.short	4430                            # Record kind: S_INLINESITE_END
	.short	2                               # Record length
	.short	4431                            # Record kind: S_PROC_ID_END
.Ltmp159:
	.p2align	2, 0x0
	.cv_linetable	4, sha256, .Lfunc_end4
	.long	241                             # Symbol subsection for globals
	.long	.Ltmp189-.Ltmp188               # Subsection size
.Ltmp188:
	.short	.Ltmp191-.Ltmp190               # Record length
.Ltmp190:
	.short	4364                            # Record kind: S_LDATA32
	.long	4123                            # Type
	.secrel32	k                       # DataOffset
	.secidx	k                               # Segment
	.asciz	"k"                             # Name
	.p2align	2, 0x0
.Ltmp191:
.Ltmp189:
	.p2align	2, 0x0
	.long	241
	.long	.Ltmp193-.Ltmp192               # Subsection size
.Ltmp192:
	.short	.Ltmp195-.Ltmp194               # Record length
.Ltmp194:
	.short	4360                            # Record kind: S_UDT
	.long	4103                            # Type
	.asciz	"SHA256_CTX"
	.p2align	2, 0x0
.Ltmp195:
	.short	.Ltmp197-.Ltmp196               # Record length
.Ltmp196:
	.short	4360                            # Record kind: S_UDT
	.long	35                              # Type
	.asciz	"uint64_t"
	.p2align	2, 0x0
.Ltmp197:
	.short	.Ltmp199-.Ltmp198               # Record length
.Ltmp198:
	.short	4360                            # Record kind: S_UDT
	.long	117                             # Type
	.asciz	"uint32_t"
	.p2align	2, 0x0
.Ltmp199:
	.short	.Ltmp201-.Ltmp200               # Record length
.Ltmp200:
	.short	4360                            # Record kind: S_UDT
	.long	32                              # Type
	.asciz	"uint8_t"
	.p2align	2, 0x0
.Ltmp201:
	.short	.Ltmp203-.Ltmp202               # Record length
.Ltmp202:
	.short	4360                            # Record kind: S_UDT
	.long	4103                            # Type
	.asciz	"SHA256_CTX"
	.p2align	2, 0x0
.Ltmp203:
	.short	.Ltmp205-.Ltmp204               # Record length
.Ltmp204:
	.short	4360                            # Record kind: S_UDT
	.long	35                              # Type
	.asciz	"size_t"
	.p2align	2, 0x0
.Ltmp205:
.Ltmp193:
	.p2align	2, 0x0
	.cv_filechecksums                       # File index to string table offset subsection
	.cv_stringtable                         # String table
	.long	241
	.long	.Ltmp207-.Ltmp206               # Subsection size
.Ltmp206:
	.short	.Ltmp209-.Ltmp208               # Record length
.Ltmp208:
	.short	4428                            # Record kind: S_BUILDINFO
	.long	4129                            # LF_BUILDINFO index
	.p2align	2, 0x0
.Ltmp209:
.Ltmp207:
	.p2align	2, 0x0
	.section	.debug$T,"dr"
	.p2align	2, 0x0
	.long	4                               # Debug section magic
	# Struct (0x1000)
	.short	0x22                            # Record length
	.short	0x1505                          # Record kind: LF_STRUCTURE
	.short	0x0                             # MemberCount
	.short	0x80                            # Properties ( ForwardReference (0x80) )
	.long	0x0                             # FieldList
	.long	0x0                             # DerivedFrom
	.long	0x0                             # VShape
	.short	0x0                             # SizeOf
	.asciz	"SHA256_CTX"                    # Name
	.byte	243
	.byte	242
	.byte	241
	# Pointer (0x1001)
	.short	0xa                             # Record length
	.short	0x1002                          # Record kind: LF_POINTER
	.long	0x1000                          # PointeeType: SHA256_CTX
	.long	0x1000c                         # Attrs: [ Type: Near64, Mode: Pointer, SizeOf: 8 ]
	# ArgList (0x1002)
	.short	0xa                             # Record length
	.short	0x1201                          # Record kind: LF_ARGLIST
	.long	0x1                             # NumArgs
	.long	0x1001                          # Argument: SHA256_CTX*
	# Procedure (0x1003)
	.short	0xe                             # Record length
	.short	0x1008                          # Record kind: LF_PROCEDURE
	.long	0x3                             # ReturnType: void
	.byte	0x0                             # CallingConvention: NearC
	.byte	0x0                             # FunctionOptions
	.short	0x1                             # NumParameters
	.long	0x1002                          # ArgListType: (SHA256_CTX*)
	# Array (0x1004)
	.short	0xe                             # Record length
	.short	0x1503                          # Record kind: LF_ARRAY
	.long	0x75                            # ElementType: unsigned
	.long	0x23                            # IndexType: unsigned __int64
	.short	0x20                            # SizeOf
	.byte	0                               # Name
	.byte	241
	# Array (0x1005)
	.short	0xe                             # Record length
	.short	0x1503                          # Record kind: LF_ARRAY
	.long	0x20                            # ElementType: unsigned char
	.long	0x23                            # IndexType: unsigned __int64
	.short	0x40                            # SizeOf
	.byte	0                               # Name
	.byte	241
	# FieldList (0x1006)
	.short	0x4a                            # Record length
	.short	0x1203                          # Record kind: LF_FIELDLIST
	.short	0x150d                          # Member kind: DataMember ( LF_MEMBER )
	.short	0x3                             # Attrs: Public
	.long	0x23                            # Type: unsigned __int64
	.short	0x0                             # FieldOffset
	.asciz	"bitlen"                        # Name
	.byte	243
	.byte	242
	.byte	241
	.short	0x150d                          # Member kind: DataMember ( LF_MEMBER )
	.short	0x3                             # Attrs: Public
	.long	0x1004                          # Type
	.short	0x8                             # FieldOffset
	.asciz	"state"                         # Name
	.short	0x150d                          # Member kind: DataMember ( LF_MEMBER )
	.short	0x3                             # Attrs: Public
	.long	0x1005                          # Type
	.short	0x28                            # FieldOffset
	.asciz	"data"                          # Name
	.byte	241
	.short	0x150d                          # Member kind: DataMember ( LF_MEMBER )
	.short	0x3                             # Attrs: Public
	.long	0x75                            # Type: unsigned
	.short	0x68                            # FieldOffset
	.asciz	"datalen"                       # Name
	.byte	242
	.byte	241
	# Struct (0x1007)
	.short	0x22                            # Record length
	.short	0x1505                          # Record kind: LF_STRUCTURE
	.short	0x4                             # MemberCount
	.short	0x0                             # Properties
	.long	0x1006                          # FieldList: <field list>
	.long	0x0                             # DerivedFrom
	.long	0x0                             # VShape
	.short	0x70                            # SizeOf
	.asciz	"SHA256_CTX"                    # Name
	.byte	243
	.byte	242
	.byte	241
	# StringId (0x1008)
	.short	0x3a                            # Record length
	.short	0x1605                          # Record kind: LF_STRING_ID
	.long	0x0                             # Id
	.asciz	"D:\\Playground\\demo-blockchain-with-asm\\src\\sha256.h" # StringData
	# UdtSourceLine (0x1009)
	.short	0xe                             # Record length
	.short	0x1606                          # Record kind: LF_UDT_SRC_LINE
	.long	0x1007                          # UDT: SHA256_CTX
	.long	0x1008                          # SourceFile: D:\Playground\demo-blockchain-with-asm\src\sha256.h
	.long	0x9                             # LineNumber
	# FuncId (0x100A)
	.short	0x16                            # Record length
	.short	0x1601                          # Record kind: LF_FUNC_ID
	.long	0x0                             # ParentScope
	.long	0x1003                          # FunctionType: void (SHA256_CTX*)
	.asciz	"sha256_init"                   # Name
	# Modifier (0x100B)
	.short	0xa                             # Record length
	.short	0x1001                          # Record kind: LF_MODIFIER
	.long	0x20                            # ModifiedType: unsigned char
	.short	0x1                             # Modifiers ( Const (0x1) )
	.byte	242
	.byte	241
	# Pointer (0x100C)
	.short	0xa                             # Record length
	.short	0x1002                          # Record kind: LF_POINTER
	.long	0x100b                          # PointeeType: const unsigned char
	.long	0x1000c                         # Attrs: [ Type: Near64, Mode: Pointer, SizeOf: 8 ]
	# ArgList (0x100D)
	.short	0x12                            # Record length
	.short	0x1201                          # Record kind: LF_ARGLIST
	.long	0x3                             # NumArgs
	.long	0x1001                          # Argument: SHA256_CTX*
	.long	0x100c                          # Argument: const unsigned char*
	.long	0x23                            # Argument: unsigned __int64
	# Procedure (0x100E)
	.short	0xe                             # Record length
	.short	0x1008                          # Record kind: LF_PROCEDURE
	.long	0x3                             # ReturnType: void
	.byte	0x0                             # CallingConvention: NearC
	.byte	0x0                             # FunctionOptions
	.short	0x3                             # NumParameters
	.long	0x100d                          # ArgListType: (SHA256_CTX*, const unsigned char*, unsigned __int64)
	# FuncId (0x100F)
	.short	0x1a                            # Record length
	.short	0x1601                          # Record kind: LF_FUNC_ID
	.long	0x0                             # ParentScope
	.long	0x100e                          # FunctionType: void (SHA256_CTX*, const unsigned char*, unsigned __int64)
	.asciz	"sha256_update"                 # Name
	.byte	242
	.byte	241
	# ArgList (0x1010)
	.short	0xe                             # Record length
	.short	0x1201                          # Record kind: LF_ARGLIST
	.long	0x2                             # NumArgs
	.long	0x1001                          # Argument: SHA256_CTX*
	.long	0x100c                          # Argument: const unsigned char*
	# Procedure (0x1011)
	.short	0xe                             # Record length
	.short	0x1008                          # Record kind: LF_PROCEDURE
	.long	0x3                             # ReturnType: void
	.byte	0x0                             # CallingConvention: NearC
	.byte	0x0                             # FunctionOptions
	.short	0x2                             # NumParameters
	.long	0x1010                          # ArgListType: (SHA256_CTX*, const unsigned char*)
	# FuncId (0x1012)
	.short	0x1e                            # Record length
	.short	0x1601                          # Record kind: LF_FUNC_ID
	.long	0x0                             # ParentScope
	.long	0x1011                          # FunctionType: void (SHA256_CTX*, const unsigned char*)
	.asciz	"sha256_transform"              # Name
	.byte	243
	.byte	242
	.byte	241
	# Array (0x1013)
	.short	0xe                             # Record length
	.short	0x1503                          # Record kind: LF_ARRAY
	.long	0x75                            # ElementType: unsigned
	.long	0x23                            # IndexType: unsigned __int64
	.short	0x100                           # SizeOf
	.byte	0                               # Name
	.byte	241
	# ArgList (0x1014)
	.short	0xe                             # Record length
	.short	0x1201                          # Record kind: LF_ARGLIST
	.long	0x2                             # NumArgs
	.long	0x1001                          # Argument: SHA256_CTX*
	.long	0x620                           # Argument: unsigned char*
	# Procedure (0x1015)
	.short	0xe                             # Record length
	.short	0x1008                          # Record kind: LF_PROCEDURE
	.long	0x3                             # ReturnType: void
	.byte	0x0                             # CallingConvention: NearC
	.byte	0x0                             # FunctionOptions
	.short	0x2                             # NumParameters
	.long	0x1014                          # ArgListType: (SHA256_CTX*, unsigned char*)
	# FuncId (0x1016)
	.short	0x1a                            # Record length
	.short	0x1601                          # Record kind: LF_FUNC_ID
	.long	0x0                             # ParentScope
	.long	0x1015                          # FunctionType: void (SHA256_CTX*, unsigned char*)
	.asciz	"sha256_final"                  # Name
	.byte	243
	.byte	242
	.byte	241
	# ArgList (0x1017)
	.short	0x12                            # Record length
	.short	0x1201                          # Record kind: LF_ARGLIST
	.long	0x3                             # NumArgs
	.long	0x100c                          # Argument: const unsigned char*
	.long	0x23                            # Argument: unsigned __int64
	.long	0x620                           # Argument: unsigned char*
	# Procedure (0x1018)
	.short	0xe                             # Record length
	.short	0x1008                          # Record kind: LF_PROCEDURE
	.long	0x3                             # ReturnType: void
	.byte	0x0                             # CallingConvention: NearC
	.byte	0x0                             # FunctionOptions
	.short	0x3                             # NumParameters
	.long	0x1017                          # ArgListType: (const unsigned char*, unsigned __int64, unsigned char*)
	# FuncId (0x1019)
	.short	0x12                            # Record length
	.short	0x1601                          # Record kind: LF_FUNC_ID
	.long	0x0                             # ParentScope
	.long	0x1018                          # FunctionType: void (const unsigned char*, unsigned __int64, unsigned char*)
	.asciz	"sha256"                        # Name
	.byte	241
	# Modifier (0x101A)
	.short	0xa                             # Record length
	.short	0x1001                          # Record kind: LF_MODIFIER
	.long	0x75                            # ModifiedType: unsigned
	.short	0x1                             # Modifiers ( Const (0x1) )
	.byte	242
	.byte	241
	# Array (0x101B)
	.short	0xe                             # Record length
	.short	0x1503                          # Record kind: LF_ARRAY
	.long	0x101a                          # ElementType: const unsigned
	.long	0x23                            # IndexType: unsigned __int64
	.short	0x100                           # SizeOf
	.byte	0                               # Name
	.byte	241
	# StringId (0x101C)
	.short	0x2e                            # Record length
	.short	0x1605                          # Record kind: LF_STRING_ID
	.long	0x0                             # Id
	.asciz	"D:/Playground/demo-blockchain-with-asm" # StringData
	.byte	241
	# StringId (0x101D)
	.short	0x16                            # Record length
	.short	0x1605                          # Record kind: LF_STRING_ID
	.long	0x0                             # Id
	.asciz	"src/sha256.c"                  # StringData
	.byte	243
	.byte	242
	.byte	241
	# StringId (0x101E)
	.short	0xa                             # Record length
	.short	0x1605                          # Record kind: LF_STRING_ID
	.long	0x0                             # Id
	.byte	0                               # StringData
	.byte	243
	.byte	242
	.byte	241
	# StringId (0x101F)
	.short	0x46                            # Record length
	.short	0x1605                          # Record kind: LF_STRING_ID
	.long	0x0                             # Id
	.asciz	"C:/Users/nobre/AppData/Local/mise/installs/zig/0.16.0/zig.exe" # StringData
	.byte	242
	.byte	241
	# StringId (0x1020)
	.short	0x1f32                          # Record length
	.short	0x1605                          # Record kind: LF_STRING_ID
	.long	0x0                             # Id
	.asciz	"\"-cc1\" \"-triple\" \"x86_64-unknown-windows-gnu\" \"-O2\" \"-S\" \"-disable-free\" \"-clear-ast-before-backend\" \"-disable-llvm-verifier\" \"-discard-value-names\" \"-mrelocation-model\" \"pic\" \"-pic-level\" \"2\" \"-mframe-pointer=all\" \"-fmath-errno\" \"-ffp-contract=on\" \"-fno-rounding-math\" \"-mconstructor-aliases\" \"-mms-bitfields\" \"-funwind-tables=2\" \"-fno-sized-deallocation\" \"-fno-use-init-array\" \"-target-cpu\" \"x86-64\" \"-tune-cpu\" \"generic\" \"-gno-column-info\" \"-gcodeview\" \"-debug-info-kind=constructor\" \"-debugger-tuning=gdb\" \"-fdebug-compilation-dir=D:/Playground/demo-blockchain-with-asm\" \"-fcoverage-compilation-dir=D:/Playground/demo-blockchain-with-asm\" \"-nostdsysteminc\" \"-nobuiltininc\" \"-resource-dir\" \"C:/Users/nobre/AppData/Local/mise/installs/zig/lib/clang/21\" \"-dependency-file\" \"C:\\\\Users\\\\nobre\\\\AppData\\\\Local\\\\zig\\\\tmp\\\\ddbb2fcb0f4afbe2-sha256.s.d\" \"-MT\" \"C:\\\\Users\\\\nobre\\\\AppData\\\\Local\\\\zig\\\\tmp\\\\ddbb2fcb0f4afbe2-sha256.s\" \"-sys-header-deps\" \"-MV\" \"-isystem\" \"C:\\\\Users\\\\nobre\\\\AppData\\\\Local\\\\mise\\\\installs\\\\zig\\\\0.16.0\\\\lib\\\\include\" \"-isystem\" \"C:\\\\Users\\\\nobre\\\\AppData\\\\Local\\\\mise\\\\installs\\\\zig\\\\0.16.0\\\\lib\\\\libc\\\\include\\\\x86_64-windows-gnu\" \"-isystem\" \"C:\\\\Users\\\\nobre\\\\AppData\\\\Local\\\\mise\\\\installs\\\\zig\\\\0.16.0\\\\lib\\\\libc\\\\include\\\\generic-mingw\" \"-isystem\" \"C:\\\\Users\\\\nobre\\\\AppData\\\\Local\\\\mise\\\\installs\\\\zig\\\\0.16.0\\\\lib\\\\libc\\\\include\\\\x86_64-windows-any\" \"-isystem\" \"C:\\\\Users\\\\nobre\\\\AppData\\\\Local\\\\mise\\\\installs\\\\zig\\\\0.16.0\\\\lib\\\\libc\\\\include\\\\any-windows-any\" \"-D\" \"NDEBUG\" \"-D\" \"__MSVCRT_VERSION__=0xE00\" \"-D\" \"_WIN32_WINNT=0x0a00\" \"-I\" \"src\" \"-Wno-pragma-pack\" \"-Werror=date-time\" \"-std=c11\" \"-ferror-limit\" \"19\" \"-fno-use-cxa-atexit\" \"-fgnuc-version=4.2.1\" \"-fskip-odr-check-in-gmf\" \"-exception-model=seh\" \"-fno-spell-checking\" \"-vectorize-loops\" \"-vectorize-slp\" \"-target-cpu\" \"znver3\" \"-target-feature\" \"-16bit-mode\" \"-target-feature\" \"-32bit-mode\" \"-target-feature\" \"+64bit\" \"-target-feature\" \"+adx\" \"-target-feature\" \"+aes\" \"-target-feature\" \"+allow-light-256-bit\" \"-target-feature\" \"-amx-avx512\" \"-target-feature\" \"-amx-bf16\" \"-target-feature\" \"-amx-complex\" \"-target-feature\" \"-amx-fp16\" \"-target-feature\" \"-amx-fp8\" \"-target-feature\" \"-amx-int8\" \"-target-feature\" \"-amx-movrs\" \"-target-feature\" \"-amx-tf32\" \"-target-feature\" \"-amx-tile\" \"-target-feature\" \"-amx-transpose\" \"-target-feature\" \"+avx\" \"-target-feature\" \"-avx10.1-512\" \"-target-feature\" \"-avx10.2-512\" \"-target-feature\" \"+avx2\" \"-target-feature\" \"-avx512bf16\" \"-target-feature\" \"-avx512bitalg\" \"-target-feature\" \"-avx512bw\" \"-target-feature\" \"-avx512cd\" \"-target-feature\" \"-avx512dq\" \"-target-feature\" \"-avx512f\" \"-target-feature\" \"-avx512fp16\" \"-target-feature\" \"-avx512ifma\" \"-target-feature\" \"-avx512vbmi\" \"-target-feature\" \"-avx512vbmi2\" \"-target-feature\" \"-avx512vl\" \"-target-feature\" \"-avx512vnni\" \"-target-feature\" \"-avx512vp2intersect\" \"-target-feature\" \"-avx512vpopcntdq\" \"-target-feature\" \"-avxifma\" \"-target-feature\" \"-avxneconvert\" \"-target-feature\" \"-avxvnni\" \"-target-feature\" \"-avxvnniint16\" \"-target-feature\" \"-avxvnniint8\" \"-target-feature\" \"+bmi\" \"-target-feature\" \"+bmi2\" \"-target-feature\" \"-branch-hint\" \"-target-feature\" \"+branchfusion\" \"-target-feature\" \"-ccmp\" \"-target-feature\" \"-cf\" \"-target-feature\" \"-cldemote\" \"-target-feature\" \"+clflushopt\" \"-target-feature\" \"+clwb\" \"-target-feature\" \"+clzero\" \"-target-feature\" \"+cmov\" \"-target-feature\" \"-cmpccxadd\" \"-target-feature\" \"+crc32\" \"-target-feature\" \"+cx16\" \"-target-feature\" \"+cx8\" \"-target-feature\" \"-egpr\" \"-target-feature\" \"-enqcmd\" \"-target-feature\" \"-ermsb\" \"-target-feature\" \"-evex512\" \"-target-feature\" \"+f16c\" \"-target-feature\" \"-false-deps-getmant\" \"-target-feature\" \"-false-deps-lzcnt-tzcnt\" \"-target-feature\" \"-false-deps-mulc\" \"-target-feature\" \"-false-deps-mullq\" \"-target-feature\" \"-false-deps-perm\" \"-target-feature\" \"-false-deps-popcnt\" \"-target-feature\" \"-false-deps-range\" \"-target-feature\" \"-fast-11bytenop\" \"-target-feature\" \"+fast-15bytenop\" \"-target-feature\" \"-fast-7bytenop\" \"-target-feature\" \"+fast-bextr\" \"-target-feature\" \"-fast-dpwssd\" \"-target-feature\" \"-fast-gather\" \"-target-feature\" \"-fast-hops\" \"-target-feature\" \"+fast-imm16\" \"-target-feature\" \"+fast-lzcnt\" \"-target-feature\" \"+fast-movbe\" \"-target-feature\" \"+fast-scalar-fsqrt\" \"-target-feature\" \"+fast-scalar-shift-masks\" \"-target-feature\" \"-fast-shld-rotate\" \"-target-feature\" \"-fast-variable-crosslane-shuffle\" \"-target-feature\" \"+fast-variable-perlane-shuffle\" \"-target-feature\" \"+fast-vector-fsqrt\" \"-target-feature\" \"-fast-vector-shift-masks\" \"-target-feature\" \"-faster-shift-than-shuffle\" \"-target-feature\" \"+fma\" \"-target-feature\" \"-fma4\" \"-target-feature\" \"+fsgsbase\" \"-target-feature\" \"+fsrm\" \"-target-feature\" \"+fxsr\" \"-target-feature\" \"-gfni\" \"-target-feature\" \"-harden-sls-ijmp\" \"-target-feature\" \"-harden-sls-ret\" \"-target-feature\" \"-hreset\" \"-target-feature\" \"-idivl-to-divb\" \"-target-feature\" \"+idivq-to-divl\" \"-target-feature\" \"-inline-asm-use-gpr32\" \"-target-feature\" \"+invpcid\" \"-target-feature\" \"-kl\" \"-target-feature\" \"-lea-sp\" \"-target-feature\" \"-lea-uses-ag\" \"-target-feature\" \"-lvi-cfi\" \"-target-feature\" \"-lvi-load-hardening\" \"-target-feature\" \"-lwp\" \"-target-feature\" \"+lzcnt\" \"-target-feature\" \"+macrofusion\" \"-target-feature\" \"+mmx\" \"-target-feature\" \"+movbe\" \"-target-feature\" \"-movdir64b\" \"-target-feature\" \"-movdiri\" \"-target-feature\" \"-movrs\" \"-target-feature\" \"+mwaitx\" \"-target-feature\" \"-ndd\" \"-target-feature\" \"-nf\" \"-target-feature\" \"-no-bypass-delay\" \"-target-feature\" \"-no-bypass-delay-blend\" \"-target-feature\" \"-no-bypass-delay-mov\" \"-target-feature\" \"-no-bypass-delay-shuffle\" \"-target-feature\" \"+nopl\" \"-target-feature\" \"-pad-short-functions\" \"-target-feature\" \"+pclmul\" \"-target-feature\" \"-pconfig\" \"-target-feature\" \"-pku\" \"-target-feature\" \"+popcnt\" \"-target-feature\" \"-ppx\" \"-target-feature\" \"-prefer-128-bit\" \"-target-feature\" \"-prefer-256-bit\" \"-target-feature\" \"-prefer-mask-registers\" \"-target-feature\" \"-prefer-movmsk-over-vtest\" \"-target-feature\" \"-prefer-no-gather\" \"-target-feature\" \"-prefer-no-scatter\" \"-target-feature\" \"-prefetchi\" \"-target-feature\" \"+prfchw\" \"-target-feature\" \"-ptwrite\" \"-target-feature\" \"-push2pop2\" \"-target-feature\" \"-raoint\" \"-target-feature\" \"+rdpid\" \"-target-feature\" \"+rdpru\" \"-target-feature\" \"+rdrnd\" \"-target-feature\" \"+rdseed\" \"-target-feature\" \"-retpoline\" \"-target-feature\" \"-retpoline-external-thunk\" \"-target-feature\" \"-retpoline-indirect-branches\" \"-target-feature\" \"-retpoline-indirect-calls\" \"-target-feature\" \"-rtm\" \"-target-feature\" \"+sahf\" \"-target-feature\" \"+sbb-dep-breaking\" \"-target-feature\" \"-serialize\" \"-target-feature\" \"-seses\" \"-target-feature\" \"-sgx\" \"-target-feature\" \"+sha\" \"-target-feature\" \"-sha512\" \"-target-feature\" \"+shstk\" \"-target-feature\" \"-slow-3ops-lea\" \"-target-feature\" \"-slow-incdec\" \"-target-feature\" \"-slow-lea\" \"-target-feature\" \"-slow-pmaddwd\" \"-target-feature\" \"-slow-pmulld\" \"-target-feature\" \"-slow-shld\" \"-target-feature\" \"-slow-two-mem-ops\" \"-target-feature\" \"-slow-unaligned-mem-16\" \"-target-feature\" \"-slow-unaligned-mem-32\" \"-target-feature\" \"-sm3\" \"-target-feature\" \"-sm4\" \"-target-feature\" \"+sse\" \"-target-feature\" \"+sse2\" \"-target-feature\" \"+sse3\" \"-target-feature\" \"+sse4.1\" \"-target-feature\" \"+sse4.2\" \"-target-feature\" \"+sse4a\" \"-target-feature\" \"-sse-unaligned-mem\" \"-target-feature\" \"+ssse3\" \"-target-feature\" \"-tagged-globals\" \"-target-feature\" \"-tbm\" \"-target-feature\" \"-tsxldtrk\" \"-target-feature\" \"-tuning-fast-imm-vector-shift\" \"-target-feature\" \"-uintr\" \"-target-feature\" \"-use-glm-div-sqrt-costs\" \"-target-feature\" \"-use-slm-arith-costs\" \"-target-feature\" \"-usermsr\" \"-target-feature\" \"+vaes\" \"-target-feature\" \"+vpclmulqdq\" \"-target-feature\" \"+vzeroupper\" \"-target-feature\" \"-waitpkg\" \"-target-feature\" \"+wbnoinvd\" \"-target-feature\" \"-widekl\" \"-target-feature\" \"+x87\" \"-target-feature\" \"-xop\" \"-target-feature\" \"+xsave\" \"-target-feature\" \"+xsavec\" \"-target-feature\" \"+xsaveopt\" \"-target-feature\" \"+xsaves\" \"-target-feature\" \"-zu\" \"-faddrsig\" \"-x\" \"c\" \"src/sha256.c\"" # StringData
	# BuildInfo (0x1021)
	.short	0x1a                            # Record length
	.short	0x1603                          # Record kind: LF_BUILDINFO
	.short	0x5                             # NumArgs
	.long	0x101c                          # Argument: D:/Playground/demo-blockchain-with-asm
	.long	0x101f                          # Argument: C:/Users/nobre/AppData/Local/mise/installs/zig/0.16.0/zig.exe
	.long	0x101d                          # Argument: src/sha256.c
	.long	0x101e                          # Argument
	.long	0x1020                          # Argument: "-cc1" "-triple" "x86_64-unknown-windows-gnu" "-O2" "-S" "-disable-free" "-clear-ast-before-backend" "-disable-llvm-verifier" "-discard-value-names" "-mrelocation-model" "pic" "-pic-level" "2" "-mframe-pointer=all" "-fmath-errno" "-ffp-contract=on" "-fno-rounding-math" "-mconstructor-aliases" "-mms-bitfields" "-funwind-tables=2" "-fno-sized-deallocation" "-fno-use-init-array" "-target-cpu" "x86-64" "-tune-cpu" "generic" "-gno-column-info" "-gcodeview" "-debug-info-kind=constructor" "-debugger-tuning=gdb" "-fdebug-compilation-dir=D:/Playground/demo-blockchain-with-asm" "-fcoverage-compilation-dir=D:/Playground/demo-blockchain-with-asm" "-nostdsysteminc" "-nobuiltininc" "-resource-dir" "C:/Users/nobre/AppData/Local/mise/installs/zig/lib/clang/21" "-dependency-file" "C:\\Users\\nobre\\AppData\\Local\\zig\\tmp\\ddbb2fcb0f4afbe2-sha256.s.d" "-MT" "C:\\Users\\nobre\\AppData\\Local\\zig\\tmp\\ddbb2fcb0f4afbe2-sha256.s" "-sys-header-deps" "-MV" "-isystem" "C:\\Users\\nobre\\AppData\\Local\\mise\\installs\\zig\\0.16.0\\lib\\include" "-isystem" "C:\\Users\\nobre\\AppData\\Local\\mise\\installs\\zig\\0.16.0\\lib\\libc\\include\\x86_64-windows-gnu" "-isystem" "C:\\Users\\nobre\\AppData\\Local\\mise\\installs\\zig\\0.16.0\\lib\\libc\\include\\generic-mingw" "-isystem" "C:\\Users\\nobre\\AppData\\Local\\mise\\installs\\zig\\0.16.0\\lib\\libc\\include\\x86_64-windows-any" "-isystem" "C:\\Users\\nobre\\AppData\\Local\\mise\\installs\\zig\\0.16.0\\lib\\libc\\include\\any-windows-any" "-D" "NDEBUG" "-D" "__MSVCRT_VERSION__=0xE00" "-D" "_WIN32_WINNT=0x0a00" "-I" "src" "-Wno-pragma-pack" "-Werror=date-time" "-std=c11" "-ferror-limit" "19" "-fno-use-cxa-atexit" "-fgnuc-version=4.2.1" "-fskip-odr-check-in-gmf" "-exception-model=seh" "-fno-spell-checking" "-vectorize-loops" "-vectorize-slp" "-target-cpu" "znver3" "-target-feature" "-16bit-mode" "-target-feature" "-32bit-mode" "-target-feature" "+64bit" "-target-feature" "+adx" "-target-feature" "+aes" "-target-feature" "+allow-light-256-bit" "-target-feature" "-amx-avx512" "-target-feature" "-amx-bf16" "-target-feature" "-amx-complex" "-target-feature" "-amx-fp16" "-target-feature" "-amx-fp8" "-target-feature" "-amx-int8" "-target-feature" "-amx-movrs" "-target-feature" "-amx-tf32" "-target-feature" "-amx-tile" "-target-feature" "-amx-transpose" "-target-feature" "+avx" "-target-feature" "-avx10.1-512" "-target-feature" "-avx10.2-512" "-target-feature" "+avx2" "-target-feature" "-avx512bf16" "-target-feature" "-avx512bitalg" "-target-feature" "-avx512bw" "-target-feature" "-avx512cd" "-target-feature" "-avx512dq" "-target-feature" "-avx512f" "-target-feature" "-avx512fp16" "-target-feature" "-avx512ifma" "-target-feature" "-avx512vbmi" "-target-feature" "-avx512vbmi2" "-target-feature" "-avx512vl" "-target-feature" "-avx512vnni" "-target-feature" "-avx512vp2intersect" "-target-feature" "-avx512vpopcntdq" "-target-feature" "-avxifma" "-target-feature" "-avxneconvert" "-target-feature" "-avxvnni" "-target-feature" "-avxvnniint16" "-target-feature" "-avxvnniint8" "-target-feature" "+bmi" "-target-feature" "+bmi2" "-target-feature" "-branch-hint" "-target-feature" "+branchfusion" "-target-feature" "-ccmp" "-target-feature" "-cf" "-target-feature" "-cldemote" "-target-feature" "+clflushopt" "-target-feature" "+clwb" "-target-feature" "+clzero" "-target-feature" "+cmov" "-target-feature" "-cmpccxadd" "-target-feature" "+crc32" "-target-feature" "+cx16" "-target-feature" "+cx8" "-target-feature" "-egpr" "-target-feature" "-enqcmd" "-target-feature" "-ermsb" "-target-feature" "-evex512" "-target-feature" "+f16c" "-target-feature" "-false-deps-getmant" "-target-feature" "-false-deps-lzcnt-tzcnt" "-target-feature" "-false-deps-mulc" "-target-feature" "-false-deps-mullq" "-target-feature" "-false-deps-perm" "-target-feature" "-false-deps-popcnt" "-target-feature" "-false-deps-range" "-target-feature" "-fast-11bytenop" "-target-feature" "+fast-15bytenop" "-target-feature" "-fast-7bytenop" "-target-feature" "+fast-bextr" "-target-feature" "-fast-dpwssd" "-target-feature" "-fast-gather" "-target-feature" "-fast-hops" "-target-feature" "+fast-imm16" "-target-feature" "+fast-lzcnt" "-target-feature" "+fast-movbe" "-target-feature" "+fast-scalar-fsqrt" "-target-feature" "+fast-scalar-shift-masks" "-target-feature" "-fast-shld-rotate" "-target-feature" "-fast-variable-crosslane-shuffle" "-target-feature" "+fast-variable-perlane-shuffle" "-target-feature" "+fast-vector-fsqrt" "-target-feature" "-fast-vector-shift-masks" "-target-feature" "-faster-shift-than-shuffle" "-target-feature" "+fma" "-target-feature" "-fma4" "-target-feature" "+fsgsbase" "-target-feature" "+fsrm" "-target-feature" "+fxsr" "-target-feature" "-gfni" "-target-feature" "-harden-sls-ijmp" "-target-feature" "-harden-sls-ret" "-target-feature" "-hreset" "-target-feature" "-idivl-to-divb" "-target-feature" "+idivq-to-divl" "-target-feature" "-inline-asm-use-gpr32" "-target-feature" "+invpcid" "-target-feature" "-kl" "-target-feature" "-lea-sp" "-target-feature" "-lea-uses-ag" "-target-feature" "-lvi-cfi" "-target-feature" "-lvi-load-hardening" "-target-feature" "-lwp" "-target-feature" "+lzcnt" "-target-feature" "+macrofusion" "-target-feature" "+mmx" "-target-feature" "+movbe" "-target-feature" "-movdir64b" "-target-feature" "-movdiri" "-target-feature" "-movrs" "-target-feature" "+mwaitx" "-target-feature" "-ndd" "-target-feature" "-nf" "-target-feature" "-no-bypass-delay" "-target-feature" "-no-bypass-delay-blend" "-target-feature" "-no-bypass-delay-mov" "-target-feature" "-no-bypass-delay-shuffle" "-target-feature" "+nopl" "-target-feature" "-pad-short-functions" "-target-feature" "+pclmul" "-target-feature" "-pconfig" "-target-feature" "-pku" "-target-feature" "+popcnt" "-target-feature" "-ppx" "-target-feature" "-prefer-128-bit" "-target-feature" "-prefer-256-bit" "-target-feature" "-prefer-mask-registers" "-target-feature" "-prefer-movmsk-over-vtest" "-target-feature" "-prefer-no-gather" "-target-feature" "-prefer-no-scatter" "-target-feature" "-prefetchi" "-target-feature" "+prfchw" "-target-feature" "-ptwrite" "-target-feature" "-push2pop2" "-target-feature" "-raoint" "-target-feature" "+rdpid" "-target-feature" "+rdpru" "-target-feature" "+rdrnd" "-target-feature" "+rdseed" "-target-feature" "-retpoline" "-target-feature" "-retpoline-external-thunk" "-target-feature" "-retpoline-indirect-branches" "-target-feature" "-retpoline-indirect-calls" "-target-feature" "-rtm" "-target-feature" "+sahf" "-target-feature" "+sbb-dep-breaking" "-target-feature" "-serialize" "-target-feature" "-seses" "-target-feature" "-sgx" "-target-feature" "+sha" "-target-feature" "-sha512" "-target-feature" "+shstk" "-target-feature" "-slow-3ops-lea" "-target-feature" "-slow-incdec" "-target-feature" "-slow-lea" "-target-feature" "-slow-pmaddwd" "-target-feature" "-slow-pmulld" "-target-feature" "-slow-shld" "-target-feature" "-slow-two-mem-ops" "-target-feature" "-slow-unaligned-mem-16" "-target-feature" "-slow-unaligned-mem-32" "-target-feature" "-sm3" "-target-feature" "-sm4" "-target-feature" "+sse" "-target-feature" "+sse2" "-target-feature" "+sse3" "-target-feature" "+sse4.1" "-target-feature" "+sse4.2" "-target-feature" "+sse4a" "-target-feature" "-sse-unaligned-mem" "-target-feature" "+ssse3" "-target-feature" "-tagged-globals" "-target-feature" "-tbm" "-target-feature" "-tsxldtrk" "-target-feature" "-tuning-fast-imm-vector-shift" "-target-feature" "-uintr" "-target-feature" "-use-glm-div-sqrt-costs" "-target-feature" "-use-slm-arith-costs" "-target-feature" "-usermsr" "-target-feature" "+vaes" "-target-feature" "+vpclmulqdq" "-target-feature" "+vzeroupper" "-target-feature" "-waitpkg" "-target-feature" "+wbnoinvd" "-target-feature" "-widekl" "-target-feature" "+x87" "-target-feature" "-xop" "-target-feature" "+xsave" "-target-feature" "+xsavec" "-target-feature" "+xsaveopt" "-target-feature" "+xsaves" "-target-feature" "-zu" "-faddrsig" "-x" "c" "src/sha256.c"
	.byte	242
	.byte	241
	.addrsig
