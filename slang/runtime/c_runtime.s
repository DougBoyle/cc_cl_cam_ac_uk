	.file	"c_runtime.c"
	.text
	.globl	ARENA_SIZE
	.data
	.align 4
	.type	ARENA_SIZE, @object
	.size	ARENA_SIZE, 4
ARENA_SIZE:
	.long	1024
	.text
	.globl	create_arena
	.type	create_arena, @function
create_arena:
.LFB5:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$32, %rsp
	movl	%edi, -20(%rbp)
	movl	$16, %edi
	call	malloc@PLT
	movq	%rax, -8(%rbp)
	movq	-8(%rbp), %rax
	movl	-20(%rbp), %edx
	movl	%edx, (%rax)
	movq	-8(%rbp), %rax
	movl	$0, 4(%rax)
	movl	-20(%rbp), %eax
	cltq
	salq	$3, %rax
	movq	%rax, %rdi
	call	malloc@PLT
	movq	%rax, %rdx
	movq	-8(%rbp), %rax
	movq	%rdx, 8(%rax)
	movq	-8(%rbp), %rax
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE5:
	.size	create_arena, .-create_arena
	.globl	arena_free
	.type	arena_free, @function
arena_free:
.LFB6:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$16, %rsp
	movq	%rdi, -8(%rbp)
	movq	-8(%rbp), %rax
	movq	8(%rax), %rax
	movq	%rax, %rdi
	call	free@PLT
	movq	-8(%rbp), %rax
	movq	%rax, %rdi
	call	free@PLT
	nop
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE6:
	.size	arena_free, .-arena_free
	.comm	copied,8,8
	.globl	lookup
	.type	lookup, @function
lookup:
.LFB7:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$16, %rsp
	movq	%rdi, -8(%rbp)
	movq	%rsi, -16(%rbp)
	cmpq	$0, -16(%rbp)
	jne	.L5
	movl	$0, %eax
	jmp	.L6
.L5:
	movq	-16(%rbp), %rax
	movq	(%rax), %rax
	cmpq	%rax, -8(%rbp)
	jne	.L7
	movq	-16(%rbp), %rax
	movq	8(%rax), %rax
	jmp	.L6
.L7:
	movq	-16(%rbp), %rax
	movq	16(%rax), %rdx
	movq	-8(%rbp), %rax
	movq	%rdx, %rsi
	movq	%rax, %rdi
	call	lookup
.L6:
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE7:
	.size	lookup, .-lookup
	.globl	cons
	.type	cons, @function
cons:
.LFB8:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$48, %rsp
	movq	%rdi, -24(%rbp)
	movq	%rsi, -32(%rbp)
	movq	%rdx, -40(%rbp)
	movl	$24, %edi
	call	malloc@PLT
	movq	%rax, -8(%rbp)
	movq	-8(%rbp), %rax
	movq	-24(%rbp), %rdx
	movq	%rdx, (%rax)
	movq	-8(%rbp), %rax
	movq	-32(%rbp), %rdx
	movq	%rdx, 8(%rax)
	movq	-8(%rbp), %rax
	movq	-40(%rbp), %rdx
	movq	%rdx, 16(%rax)
	movq	-8(%rbp), %rax
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE8:
	.size	cons, .-cons
	.comm	bottomOfStack,8,8
	.comm	heapBottom,8,8
	.comm	heapTop,8,8
	.section	.rodata
.LC0:
	.string	"Heap copy called"
	.text
	.globl	heapCopy
	.type	heapCopy, @function
heapCopy:
.LFB9:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$64, %rsp
	movq	%rdi, -40(%rbp)
	movq	%rsi, -48(%rbp)
	movq	%rdx, -56(%rbp)
	leaq	.LC0(%rip), %rdi
	call	puts@PLT
	movq	copied(%rip), %rdx
	movq	-56(%rbp), %rax
	movq	%rdx, %rsi
	movq	%rax, %rdi
	call	lookup
	movq	%rax, -24(%rbp)
	cmpq	$0, -24(%rbp)
	jne	.L11
	movq	-56(%rbp), %rax
	movq	(%rax), %rax
	movq	%rax, -16(%rbp)
	movq	-16(%rbp), %rdx
	movq	-48(%rbp), %rax
	movq	%rdx, %rsi
	movq	%rax, %rdi
	call	alloc
	movq	%rax, -24(%rbp)
	movq	copied(%rip), %rdx
	movq	-24(%rbp), %rcx
	movq	-56(%rbp), %rax
	movq	%rcx, %rsi
	movq	%rax, %rdi
	call	cons
	movq	%rax, copied(%rip)
	movq	-24(%rbp), %rax
	movq	-16(%rbp), %rdx
	movq	%rdx, (%rax)
	movq	$1, -32(%rbp)
	jmp	.L12
.L15:
	movq	-32(%rbp), %rax
	leaq	0(,%rax,8), %rdx
	movq	-56(%rbp), %rax
	addq	%rdx, %rax
	movq	(%rax), %rax
	movq	%rax, -8(%rbp)
	movq	-8(%rbp), %rax
	andl	$1, %eax
	testq	%rax, %rax
	jne	.L13
	movq	-8(%rbp), %rdx
	movq	heapBottom(%rip), %rax
	cmpq	%rax, %rdx
	jb	.L13
	movq	-8(%rbp), %rdx
	movq	heapTop(%rip), %rax
	cmpq	%rax, %rdx
	jnb	.L13
	movq	-8(%rbp), %rdx
	movq	-48(%rbp), %rcx
	movq	-40(%rbp), %rax
	movq	%rcx, %rsi
	movq	%rax, %rdi
	call	heapCopy
	movq	%rax, %rcx
	movq	-32(%rbp), %rax
	leaq	0(,%rax,8), %rdx
	movq	-24(%rbp), %rax
	addq	%rdx, %rax
	movq	%rcx, %rdx
	movq	%rdx, (%rax)
	jmp	.L14
.L13:
	movq	-32(%rbp), %rax
	leaq	0(,%rax,8), %rdx
	movq	-24(%rbp), %rax
	addq	%rax, %rdx
	movq	-8(%rbp), %rax
	movq	%rax, (%rdx)
.L14:
	addq	$1, -32(%rbp)
.L12:
	movq	-32(%rbp), %rax
	cmpq	-16(%rbp), %rax
	jl	.L15
	jmp	.L18
.L11:
	movq	-24(%rbp), %rax
	jmp	.L10
.L18:
.L10:
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE9:
	.size	heapCopy, .-heapCopy
	.comm	copyHeap,8,8
	.section	.rodata
.LC1:
	.string	"gc started"
.LC2:
	.string	"TOS: %p\n"
.LC3:
	.string	"Go to ToS"
.LC4:
	.string	"Gone"
.LC5:
	.string	"Copy pointer"
.LC6:
	.string	"Complete"
	.text
	.globl	garbage_collect
	.type	garbage_collect, @function
garbage_collect:
.LFB10:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$32, %rsp
	movq	%rdi, -24(%rbp)
	leaq	.LC1(%rip), %rdi
	call	puts@PLT
	movq	stdout(%rip), %rax
	movq	%rax, %rdi
	call	fflush@PLT
	movq	$0, copied(%rip)
	movq	copyHeap(%rip), %rax
	movl	$0, 4(%rax)
	movq	-24(%rbp), %rax
	movq	8(%rax), %rax
	movq	%rax, heapBottom(%rip)
	movq	heapBottom(%rip), %rdx
	movq	-24(%rbp), %rax
	movl	(%rax), %eax
	cltq
	salq	$6, %rax
	addq	%rdx, %rax
	movq	%rax, heapTop(%rip)
#APP
# 104 "c_runtime.c" 1
	movq %rbp, %rax;
# 0 "" 2
#NO_APP
	movq	%rax, -16(%rbp)
	movq	-16(%rbp), %rax
	movq	%rax, %rsi
	leaq	.LC2(%rip), %rdi
	movl	$0, %eax
	call	printf@PLT
	jmp	.L20
.L22:
	leaq	.LC3(%rip), %rdi
	call	puts@PLT
	movq	stdout(%rip), %rax
	movq	%rax, %rdi
	call	fflush@PLT
	movq	-16(%rbp), %rax
	movq	(%rax), %rax
	movq	%rax, -8(%rbp)
	leaq	.LC4(%rip), %rdi
	call	puts@PLT
	movq	-8(%rbp), %rax
	andl	$1, %eax
	testq	%rax, %rax
	jne	.L21
	movq	-8(%rbp), %rdx
	movq	heapBottom(%rip), %rax
	cmpq	%rax, %rdx
	jb	.L21
	movq	-8(%rbp), %rdx
	movq	heapTop(%rip), %rax
	cmpq	%rax, %rdx
	jnb	.L21
	leaq	.LC5(%rip), %rdi
	call	puts@PLT
	movq	-8(%rbp), %rdx
	movq	copyHeap(%rip), %rcx
	movq	-24(%rbp), %rax
	movq	%rcx, %rsi
	movq	%rax, %rdi
	call	heapCopy
	movq	%rax, %rdx
	movq	-16(%rbp), %rax
	movq	%rdx, (%rax)
.L21:
	subq	$8, -16(%rbp)
.L20:
	movq	bottomOfStack(%rip), %rax
	cmpq	%rax, -16(%rbp)
	ja	.L22
	movl	ARENA_SIZE(%rip), %eax
	cltq
	leaq	0(,%rax,8), %rdx
	movq	copyHeap(%rip), %rax
	movq	8(%rax), %rcx
	movq	-24(%rbp), %rax
	movq	8(%rax), %rax
	movq	%rcx, %rsi
	movq	%rax, %rdi
	call	memcpy@PLT
	movq	copyHeap(%rip), %rax
	movl	4(%rax), %edx
	movq	-24(%rbp), %rax
	movl	%edx, 4(%rax)
	leaq	.LC6(%rip), %rdi
	call	puts@PLT
	movq	stdout(%rip), %rax
	movq	%rax, %rdi
	call	fflush@PLT
	nop
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE10:
	.size	garbage_collect, .-garbage_collect
	.section	.rodata
.LC7:
	.string	"gc called"
.LC8:
	.string	"Returned"
.LC9:
	.string	"heap is at: %p\n"
.LC10:
	.string	"heap space exhausted\n"
.LC11:
	.string	"if done"
	.text
	.globl	alloc
	.type	alloc, @function
alloc:
.LFB11:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$32, %rsp
	movq	%rdi, -24(%rbp)
	movq	%rsi, -32(%rbp)
	movq	-24(%rbp), %rax
	movl	(%rax), %eax
	movslq	%eax, %rdx
	movq	-24(%rbp), %rax
	movl	4(%rax), %eax
	movslq	%eax, %rcx
	movq	-32(%rbp), %rax
	addq	%rcx, %rax
	cmpq	%rax, %rdx
	jge	.L24
	leaq	.LC7(%rip), %rdi
	call	puts@PLT
	movq	stdout(%rip), %rax
	movq	%rax, %rdi
	call	fflush@PLT
	movq	-24(%rbp), %rax
	movq	%rax, %rdi
	call	garbage_collect
	leaq	.LC8(%rip), %rdi
	call	puts@PLT
	movq	stdout(%rip), %rax
	movq	%rax, %rdi
	call	fflush@PLT
	movq	-24(%rbp), %rax
	movq	%rax, %rsi
	leaq	.LC9(%rip), %rdi
	movl	$0, %eax
	call	printf@PLT
	movq	stdout(%rip), %rax
	movq	%rax, %rdi
	call	fflush@PLT
	movq	-24(%rbp), %rax
	movl	(%rax), %eax
	movslq	%eax, %rdx
	movq	-24(%rbp), %rax
	movl	4(%rax), %eax
	movslq	%eax, %rcx
	movq	-32(%rbp), %rax
	addq	%rcx, %rax
	cmpq	%rax, %rdx
	jge	.L25
	movq	stderr(%rip), %rax
	movq	%rax, %rcx
	movl	$21, %edx
	movl	$1, %esi
	leaq	.LC10(%rip), %rdi
	call	fwrite@PLT
	movq	stderr(%rip), %rax
	movq	%rax, %rdi
	call	fflush@PLT
	movl	$1, %edi
	call	exit@PLT
.L25:
	leaq	.LC11(%rip), %rdi
	call	puts@PLT
	movq	stdout(%rip), %rax
	movq	%rax, %rdi
	call	fflush@PLT
.L24:
	movq	-24(%rbp), %rax
	movq	8(%rax), %rdx
	movq	-24(%rbp), %rax
	movl	4(%rax), %eax
	cltq
	salq	$3, %rax
	addq	%rdx, %rax
	movq	%rax, -8(%rbp)
	movq	-24(%rbp), %rax
	movl	4(%rax), %eax
	movl	%eax, %edx
	movq	-32(%rbp), %rax
	addl	%edx, %eax
	movl	%eax, %edx
	movq	-24(%rbp), %rax
	movl	%edx, 4(%rax)
	movq	-8(%rbp), %rax
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE11:
	.size	alloc, .-alloc
	.section	.rodata
.LC12:
	.string	"> "
.LC13:
	.string	"%ld"
.LC14:
	.string	"stdin died :(\n"
	.text
	.globl	read
	.type	read, @function
read:
.LFB12:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$32, %rsp
	movq	%fs:40, %rax
	movq	%rax, -8(%rbp)
	xorl	%eax, %eax
	movq	$0, -16(%rbp)
	leaq	.LC12(%rip), %rdi
	movl	$0, %eax
	call	printf@PLT
	leaq	-16(%rbp), %rax
	movq	%rax, %rsi
	leaq	.LC13(%rip), %rdi
	movl	$0, %eax
	call	__isoc99_scanf@PLT
	movl	%eax, -20(%rbp)
	cmpl	$-1, -20(%rbp)
	jne	.L28
	movq	stderr(%rip), %rax
	movq	%rax, %rcx
	movl	$14, %edx
	movl	$1, %esi
	leaq	.LC14(%rip), %rdi
	call	fwrite@PLT
	movl	$1, %edi
	call	exit@PLT
.L28:
	movq	-16(%rbp), %rax
	addq	%rax, %rax
	addq	$1, %rax
	movq	-8(%rbp), %rdx
	xorq	%fs:40, %rdx
	je	.L30
	call	__stack_chk_fail@PLT
.L30:
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE12:
	.size	read, .-read
	.section	.rodata
.LC15:
	.string	"%ld\n"
	.text
	.globl	main
	.type	main, @function
main:
.LFB13:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$16, %rsp
#APP
# 189 "c_runtime.c" 1
	movq %rsp, %rax;
# 0 "" 2
#NO_APP
	movq	%rax, bottomOfStack(%rip)
	movl	ARENA_SIZE(%rip), %eax
	movl	%eax, %edi
	call	create_arena
	movq	%rax, -8(%rbp)
	movl	ARENA_SIZE(%rip), %eax
	movl	%eax, %edi
	call	create_arena
	movq	%rax, copyHeap(%rip)
	movq	-8(%rbp), %rax
	movq	%rax, %rdi
	call	giria@PLT
	sarq	%rax
	movq	%rax, %rsi
	leaq	.LC15(%rip), %rdi
	movl	$0, %eax
	call	printf@PLT
	movq	-8(%rbp), %rax
	movq	%rax, %rdi
	call	arena_free
	movl	$0, %eax
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE13:
	.size	main, .-main
	.ident	"GCC: (Ubuntu 7.4.0-1ubuntu1~18.04.1) 7.4.0"
	.section	.note.GNU-stack,"",@progbits
