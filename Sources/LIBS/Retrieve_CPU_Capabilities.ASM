;#############################################################################

	Retrieve_CPU_Capabilities:

;#############################################################################

	smsw	ax
	test	al,HW_VM86_SMSW
	jne	enter_vm86
	pushfd
	pop	eax
	test	eax,HW_V86
	je	no_virtual_8086
enter_vm86:
	or	ds: byte ptr [status_flag_0],FLAG_V86_ON
enter_fpu_legacy:
	mov     ds: word ptr [fpu_test],55AAh
	fninit
	fnstsw  ds: word ptr [fpu_test]
	cmp	ds: byte ptr [fpu_test],0h
	jne	exit_hw_probe_1
	or	ds: byte ptr [status_flag_0],FLAG_FPU_PRESENT
exit_hw_probe_1:
	ret
no_virtual_8086:
	call	Enable_A20_Line
	mov	ebx,eax
	xor	eax,HW_CPUID_FLAG
	push	eax
	popfd
	pushfd
	pop	eax
	cmp	eax,ebx
	je	enter_fpu_legacy
	or	ds: byte ptr [status_flag_0],FLAG_CPUID
	mov	eax,HW_CPUID_LEAF1
	cpuid
	test	edx,HW_CPUID_FPU_PRESENT
	je	no_cpuid_fpu
	or	ds: byte ptr [status_flag_0],FLAG_FPU_PRESENT
no_cpuid_fpu:
	test	edx,HW_SSE
	je	exit_hw_probe
	mov	eax,cr0
	and	eax, NOT HW_CR0_EM
	or	eax, HW_CR0_MP
	mov	cr0,eax
	mov	eax,cr4
	or	eax,HW_CR4_OSFXSR OR HW_CR4_OSXMMEXCPT
	mov	cr4,eax	
	or	ds: byte ptr [status_flag_0],FLAG_SSE
	and	ecx,HW_XSAVE OR HW_AVX
	cmp	ecx,HW_XSAVE OR HW_AVX
	jne	exit_hw_probe
	mov	eax,cr4
	or	eax,HW_XSAVE_CR4
	mov	cr4,eax
	mov	ecx,HW_XCR0
	xgetbv
	or	eax,HW_XGETBV_X87 OR HW_XGETBV_SSE OR HW_XGETBV_AVX
	xor	edx,edx
	cli
	xsetbv
	sti
	mov	ecx,HW_XCR0
	xgetbv
	and	eax,HW_XGETBV_X87 OR HW_XGETBV_SSE OR HW_XGETBV_AVX
	cmp	eax,HW_XGETBV_X87 OR HW_XGETBV_SSE OR HW_XGETBV_AVX
	jne	exit_hw_probe
	or	ds: byte ptr [status_flag_0],FLAG_AVX
test_avx512:
	xor	eax,eax
	cpuid
	cmp	eax,HW_CPUID_LEAF7
	jb	exit_hw_probe
	mov	eax,HW_CPUID_LEAF7
	xor	ecx,ecx
	cpuid
	test	ebx,HW_AVX512F
	je	exit_hw_probe
	mov	eax,HW_CPUID_XSAVE
	mov	ecx,HW_CPUID_XSAVE_SUBLEAF0
	cpuid
	and	eax,XCR0_AVX512_MASK
	cmp	eax,XCR0_AVX512_MASK
	jne	exit_hw_probe
	cmp	ebx,HW_XSAVE_MIN_SIZE_AVX512F
	jb	exit_hw_probe
	mov	ecx,HW_XCR0
	xgetbv
	test	eax,XCR0_AVX
	je	exit_hw_probe
	or	eax,XCR0_AVX512_MASK
	xor	edx,edx
	cli
	xsetbv
	sti
	mov	ecx,HW_XCR0
	xgetbv
	and	eax,XCR0_AVX512_MASK
	cmp	eax,XCR0_AVX512_MASK
	jne	exit_hw_probe
	or	ds: byte ptr [status_flag_0],FLAG_AVX512
exit_hw_probe:
	ret
