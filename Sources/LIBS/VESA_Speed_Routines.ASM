;#############################################################################

	R_008B:

;#############################################################################

	pusha
	mov	di,4h
loop_r_008b_1:
	xor	dx,dx
	xor	bx,bx
loop_r_008b:
	call	ds: word ptr [set_bank_default]
	mov	ecx,ds: dword ptr [segment_bound]
	shr	ecx,1h
	xor	si,si
	push	es
	pop	ds
	push	cx
	rep	lodsb
	pop	cx
	rep	lodsb
	push	gs
	pop	ds
	add	ds: dword ptr [kb_proc],ebp
	add	bx,bp
	inc	dx
	cmp	bx,256d
	jb	loop_r_008b
	dec	di
	jne	loop_r_008b_1
	clc
	popa
	ret

;#############################################################################

	R_016B:

;#############################################################################

	pusha
	mov	di,4h
loop_r_016b_1:
	xor	dx,dx
	xor	bx,bx
loop_r_016b:
	call	ds: word ptr [set_bank_default]
	mov	ecx,ds: dword ptr [segment_bound]
	shr	ecx,1h
	xor	si,si
	push	es
	pop	ds
	rep	lodsw
	push	gs
	pop	ds
	add	ds: dword ptr [kb_proc],ebp
	add	bx,bp
	inc	dx
	cmp	bx,256d
	jb	loop_r_016b
	dec	di
	jne	loop_r_016b_1
	clc
	popa
	ret

;#############################################################################

	R_032B:

;#############################################################################

	pusha
	mov	di,4h
loop_r_032b_1:
	xor	dx,dx
	xor	bx,bx
loop_r_032b:
	call	ds: word ptr [set_bank_default]
	mov	ecx,ds: dword ptr [segment_bound]
	shr	ecx,2h
	xor	si,si
	push	es
	pop	ds
	rep	lodsd
	push	gs
	pop	ds
	add	ds: dword ptr [kb_proc],ebp
	add	bx,bp
	inc	dx
	cmp	bx,256d
	jb	loop_r_032b
	dec	di
	jne	loop_r_032b_1
	clc
	popa
	ret

;#############################################################################

	R_064B:

;#############################################################################

	test	ds: byte ptr [status_flag_0],FLAG_FPU_PRESENT
	jne	enter_fpu_l_64b
	stc
	ret
enter_fpu_l_64b:
	pusha
	mov	di,4h
loop_r_064b_1:
	xor	dx,dx
	xor	bx,bx
loop_r_064b:
	call	ds: word ptr [set_bank_default]
	mov	ecx,ds: dword ptr [segment_bound]
	shr	ecx,6h
	xor	si,si
	push	es
	pop	ds
	fninit
loop_float_64b:
	fld	ds: qword ptr [si]
	fstp	st(0)
	fld	ds: qword ptr [si + 8h]
	fstp	st(0)
	fld	ds: qword ptr [si + 10h]
	fstp	st(0)
	fld	ds: qword ptr [si + 18h]
	fstp	st(0)
	fld	ds: qword ptr [si + 20h]
	fstp	st(0)
	fld	ds: qword ptr [si + 28h]
	fstp	st(0)
	fld	ds: qword ptr [si + 30h]
	fstp	st(0)
	fld	ds: qword ptr [si + 38h]
	fstp	st(0)
	add	si,40h
	dec	cx
	jne	loop_float_64b
	push	gs
	pop	ds
	add	ds: dword ptr [kb_proc],ebp
	add	bx,bp
	inc	dx
	cmp	bx,256d
	jb	loop_r_064b
	dec	di
	jne	loop_r_064b_1
	clc
	popa
	ret

;#############################################################################

	R_128B:

;#############################################################################

	test	ds: byte ptr [status_flag_0],FLAG_SSE
	jne	enter_sse_l_128b
	stc
	ret
enter_sse_l_128b:
	pusha
	mov	di,4h
loop_r_128b_1:
	xor	dx,dx
	xor	bx,bx
loop_r_128b:
	call	ds: word ptr [set_bank_default]
	mov	ecx,ds: dword ptr [segment_bound]
	shr	ecx,7h
	xor	si,si
	push	es
	pop	ds
loop_sse_128b:
	movaps	xmm0,[si]
	movaps	xmm0,[si + 10h]
	movaps	xmm0,[si + 20h]
	movaps	xmm0,[si + 30h]
	movaps	xmm0,[si + 40h]
	movaps	xmm0,[si + 50h]
	movaps	xmm0,[si + 60h]
	movaps	xmm0,[si + 70h]
	add	si,80h
	dec	cx
	jne	loop_sse_128b
	push	gs
	pop	ds
	add	ds: dword ptr [kb_proc],ebp
	add	bx,bp
	inc	dx
	cmp	bx,256d
	jb	loop_r_128b
	dec	di
	jne	loop_r_128b_1
	clc
	popa
	ret

;#############################################################################

	R_256B:

;#############################################################################

	test	ds: byte ptr [status_flag_2],EXEC_AVX
	jne	no_r_256b_a20
	test	ds: byte ptr [status_flag_2],A20_ENABLED
	je	no_r_256b_a20
	test	ds: byte ptr [status_flag_0],FLAG_AVX
	jne	enter_avx_l_256b
no_r_256b_a20:
	stc
	ret
enter_avx_l_256b:
	pusha
	mov	di,4h
loop_r_256b_1:
	xor	dx,dx
	xor	bx,bx
loop_r_256b:
	call	ds: word ptr [set_bank_default]
	mov	ecx,ds: dword ptr [segment_bound]
	shr	ecx,8h
	mov	si,es
	movzx	esi,si
	shl	esi,4h
	push	dx
	mov	dl,ds: byte ptr [status_flag_0]
	cli
	mov	eax,cr0
	or	al,1h
	mov	cr0,eax
	jmp	$ + 2h
	mov	ax,8h
	mov	ds,ax
	test	esi,1Fh
	je	aligned_256_r
loop_avx_256b_unaligned:
	vmovups	ymm0,[esi]
	vmovups	ymm0,[esi + 20h]
	vmovups	ymm0,[esi + 40h]
	vmovups	ymm0,[esi + 60h]
	vmovups	ymm0,[esi + 80h]
	vmovups	ymm0,[esi + 0A0h]
	vmovups	ymm0,[esi + 0C0h]
	vmovups	ymm0,[esi + 0E0h]
	add	esi,100h
	dec	cx
	jne	loop_avx_256b_unaligned
	jmp	enter_for_fast_avx
aligned_256_r:
	test	dl,FLAG_AVX512
	je	loop_avx_256b
loop_avx_256b_fast:
	vmovntdqa ymm0,[esi]
	vmovntdqa ymm0,[esi + 20h]
	vmovntdqa ymm0,[esi + 40h]
	vmovntdqa ymm0,[esi + 60h]
	vmovntdqa ymm0,[esi + 80h]
	vmovntdqa ymm0,[esi + 0A0h]
	vmovntdqa ymm0,[esi + 0C0h]
	vmovntdqa ymm0,[esi + 0E0h]
	add	esi,100h
	dec	cx
	jne	loop_avx_256b_fast
	jmp	enter_for_fast_avx
loop_avx_256b:
	vmovaps ymm0,[esi]
	vmovaps ymm0,[esi + 20h]
	vmovaps ymm0,[esi + 40h]
	vmovaps ymm0,[esi + 60h]
	vmovaps ymm0,[esi + 80h]
	vmovaps ymm0,[esi + 0A0h]
	vmovaps ymm0,[esi + 0C0h]
	vmovaps ymm0,[esi + 0E0h]
	add	esi,100h
	dec	cx
	jne	loop_avx_256b
enter_for_fast_avx:
	mov	eax,cr0
	and	al,0FEh
	mov	cr0,eax
	push	cs
	push	OFFSET go_real_mode_3
	retf
go_real_mode_3:
	mov	ax,gs
	mov	ds,ax
	sti
	add	ds: dword ptr [kb_proc],ebp
	add	bx,bp
	pop	dx
	inc	dx
	cmp	bx,256d
	jb	loop_r_256b
	dec	di
	jne	loop_r_256b_1
	lfence
	clc
	popa
	ret

;#############################################################################

	R_512B:

;#############################################################################

	test	ds: byte ptr [status_flag_2],EXEC_AVX
	jne	no_r_512b_a20
	test	ds: byte ptr [status_flag_2],A20_ENABLED
	je	no_r_512b_a20
	test	ds: byte ptr [status_flag_0],FLAG_AVX512
	jne	enter_avx_l_512b
no_r_512b_a20:
	stc
	ret
enter_avx_l_512b:
	pusha
	mov	di,4h
loop_r_512b_1:
	xor	dx,dx
	xor	bx,bx
loop_r_512b:
	call	ds: word ptr [set_bank_default]
	mov	ecx,ds: dword ptr [segment_bound]
	shr	ecx,9h
	mov	si,es
	movzx	esi,si
	shl	esi,4h
	cli
	mov	eax,cr0
	or	al,1h
	mov	cr0,eax
	jmp	$ + 2h
	mov	ax,8h
	mov	ds,ax
	test	esi,3Fh
	je	loop_avx_512b
loop_avx_512b_unaligned:
	vmovdqu64 zmm0,[esi]
	vmovdqu64 zmm0,[esi + 40h]
	vmovdqu64 zmm0,[esi + 80h]
	vmovdqu64 zmm0,[esi + 0C0h]
	vmovdqu64 zmm0,[esi + 100h]
	vmovdqu64 zmm0,[esi + 140h]
	vmovdqu64 zmm0,[esi + 180h]
	vmovdqu64 zmm0,[esi + 1C0h]
	add	esi,200h
	dec	cx
	jne	loop_avx_512b_unaligned
	jmp	entry_512b_b
loop_avx_512b:
	vmovntdqa zmm0,[esi] 
	vmovntdqa zmm0,[esi + 40h] 
	vmovntdqa zmm0,[esi + 80h] 
	vmovntdqa zmm0,[esi + 0C0h] 
	vmovntdqa zmm0,[esi + 100h] 
	vmovntdqa zmm0,[esi + 140h] 
	vmovntdqa zmm0,[esi + 180h] 
	vmovntdqa zmm0,[esi + 1C0h] 
	add	esi,200h
	dec	cx
	jne	loop_avx_512b
entry_512b_b:
	mov	eax,cr0
	and	al,0FEh
	mov	cr0,eax
	push	cs
	push	OFFSET go_real_mode_1
	retf
go_real_mode_1:
	mov	ax,gs
	mov	ds,ax
	sti
	add	ds: dword ptr [kb_proc],ebp
	add	bx,bp
	inc	dx
	cmp	bx,256d
	jb	loop_r_512b
	dec	di
	jne	loop_r_512b_1
	lfence
	clc
	popa
	ret

;#############################################################################

	W_008B:

;#############################################################################

	pusha
	mov	si,4h
	xor	al,al
loop_w_008b_1:
	xor	dx,dx
	xor	bx,bx
loop_w_008b:
	call	ds: word ptr [set_bank_default]
	mov	ecx,ds: dword ptr [segment_bound]
	shr	ecx,1h
	xor	di,di
	push	cx
	rep	stosb
	pop	cx
	rep	stosb
	add	ds: dword ptr [kb_proc],ebp
	add	bx,bp
	inc	dx
	cmp	bx,256d
	jb	loop_w_008b
	add	al,3Fh
	dec	si
	jne	loop_w_008b_1
	clc
	popa
	ret

;#############################################################################

	W_016B:

;#############################################################################

	pusha
	mov	si,4h
	xor	ax,ax
loop_w_016b_1:
	xor	dx,dx
	xor	bx,bx
loop_w_016b:
	call	ds: word ptr [set_bank_default]
	mov	ecx,ds: dword ptr [segment_bound]
	shr	ecx,1h
	xor	di,di
	rep	stosw
	add	ds: dword ptr [kb_proc],ebp
	add	bx,bp
	inc	dx
	cmp	bx,256d
	jb	loop_w_016b
	add	ax,3F3Fh
	dec	si
	jne	loop_w_016b_1
	clc
	popa
	ret

;#############################################################################

	W_032B:

;#############################################################################

	pusha
	xor	eax,eax
	mov	si,4h
loop_w_032b_1:
	xor	dx,dx
	xor	bx,bx
loop_w_032b:
	call	ds: word ptr [set_bank_default]
	mov	ecx,ds: dword ptr [segment_bound]
	shr	ecx,2h
	xor	di,di
	rep	stosd
	add	ds: dword ptr [kb_proc],ebp
	add	bx,bp
	inc	dx
	cmp	bx,256d
	jb	loop_w_032b
	add	eax,3F3F3F3Fh
	dec	si
	jne	loop_w_032b_1
	clc
	popa
	ret

;#############################################################################

	W_064B:

;#############################################################################

	test	ds: byte ptr [status_flag_0],FLAG_FPU_PRESENT
	jne	enter_fpu_w_64b
	stc
	ret
enter_fpu_w_64b:
	pusha
	mov	cx,2h
	call	Init_Align_Data16
	mov	di,4h
loop_w_064b_1:
	xor	dx,dx
	xor	ax,ax
loop_w_064b:
	call	ds: word ptr [set_bank_default]
	mov	ecx,ds: dword ptr [segment_bound]
	shr	ecx,6h
	xor	si,si
	fninit
	fld	ds: qword ptr [bx]
	push	es
	pop	ds
loopw_float_64b:
	fst	ds: qword ptr [si]
	fst	ds: qword ptr [si + 8h]
	fst	ds: qword ptr [si + 10h]
	fst	ds: qword ptr [si + 18h]
	fst	ds: qword ptr [si + 20h]
	fst	ds: qword ptr [si + 28h]
	fst	ds: qword ptr [si + 30h]
	fst	ds: qword ptr [si + 38h]
	add	si,40h
	dec	cx
	jne	loopw_float_64b
	push	gs
	pop	ds
	add	ds: dword ptr [kb_proc],ebp
	add	ax,bp
	inc	dx
	cmp	ax,256d
	jb	loop_w_064b
	mov	cx,2h
	call	Inc_Aligned_Data16
	dec	di
	jne	loop_w_064b_1
	clc
	popa
	ret

;#############################################################################

	W_128B:

;#############################################################################

	test	ds: byte ptr [status_flag_0],FLAG_SSE
	jne	enter_sse_w_128b
	stc
	ret
enter_sse_w_128b:
	pusha
	mov	cx,4h
	call	Init_Align_Data16
	mov	di,4h
loop_w_128b_1:
	xor	dx,dx
	xor	ax,ax
loop_w_128b:
	call	ds: word ptr [set_bank_default]
	mov	ecx,ds: dword ptr [segment_bound]
	shr	ecx,7h
	xor	si,si
	movaps	xmm0,[bx]
	push	es
	pop	ds
loopw_sse_128b:
	movntps	[si],xmm0
	movntps	[si + 10h],xmm0
	movntps	[si + 20h],xmm0
	movntps	[si + 30h],xmm0
	movntps	[si + 40h],xmm0
	movntps	[si + 50h],xmm0
	movntps	[si + 60h],xmm0
	movntps	[si + 70h],xmm0
	add	si,80h
	dec	cx
	jne	loopw_sse_128b
	push	gs
	pop	ds
	add	ds: dword ptr [kb_proc],ebp
	add	ax,bp
	inc	dx
	cmp	ax,256d
	jb	loop_w_128b
	mov	cx,4h
	call	Inc_Aligned_Data16
	dec	di
	jne	loop_w_128b_1
	sfence
	clc
	popa
	ret
                           
;#############################################################################

	W_256B:

;#############################################################################

	test	ds: byte ptr [status_flag_2],EXEC_AVX
	jne	no_w_256b_a20
	test	ds: byte ptr [status_flag_2],A20_ENABLED
	je	no_w_256b_a20
	test	ds: byte ptr [status_flag_0],FLAG_AVX
	jne	enter_avx_w_256b
no_w_256b_a20:
	stc
	ret
enter_avx_w_256b:
	pusha
	mov	cx,8h
	call	Init_Aligned_Data32
	mov	di,4h
loop_w_256b_1:
	xor	dx,dx
	xor	ax,ax
loop_w_256b:
	call	ds: word ptr [set_bank_default]
	mov	ecx,ds: dword ptr [segment_bound]
	shr	ecx,8h
	mov	si,es
	movzx	esi,si
	shl	esi,4h
	push	ax
	cli
	mov	eax,cr0
	or	al,1h
	mov	cr0,eax
	jmp	$ + 2h
	mov	ax,8h
	mov	ds,ax
	vmovaps ymm0,[ebx]
	test	esi,1Fh
	je	loopw_avx_256b
loopw_avx_256b_unaligned:
	vmovups	[esi],ymm0
	vmovups	[esi + 20h],ymm0
	vmovups	[esi + 40h],ymm0
	vmovups	[esi + 60h],ymm0
	vmovups	[esi + 80h],ymm0
	vmovups	[esi + 0A0h],ymm0
	vmovups	[esi + 0C0h],ymm0
	vmovups	[esi + 0E0h],ymm0
	add	esi,100h
	dec	cx
	jne	loopw_avx_256b_unaligned
	jmp	enter_for_avxw
loopw_avx_256b:
	vmovntdq [esi],ymm0
	vmovntdq [esi + 20h],ymm0
	vmovntdq [esi + 40h],ymm0
	vmovntdq [esi + 60h],ymm0
	vmovntdq [esi + 80h],ymm0
	vmovntdq [esi + 0A0h],ymm0
	vmovntdq [esi + 0C0h],ymm0
	vmovntdq [esi + 0E0h],ymm0
	add	esi,100h
	dec	cx
	jne	loopw_avx_256b
enter_for_avxw:
	mov	eax,cr0
	and	al,0FEh
	mov	cr0,eax
	push	cs
	push	OFFSET go_real_mode_4
	retf
go_real_mode_4:
	mov	ax,gs
	mov	ds,ax
	sti
	pop	ax
	add	ds: dword ptr [kb_proc],ebp
	add	ax,bp
	inc	dx
	cmp	ax,256d
	jb	loop_w_256b
	mov	cx,8h
	call	Inc_Aligned_Data32
	dec	di
	jne	loop_w_256b_1
	sfence
	clc
	popa
	ret

;#############################################################################

	W_512B:

;#############################################################################

	test	ds: byte ptr [status_flag_2],EXEC_AVX
	jne	no_w_512b_a20
	test	ds: byte ptr [status_flag_2],A20_ENABLED
	je	no_w_512b_a20
	test	ds: byte ptr [status_flag_0],FLAG_AVX512
	jne	enter_avx_w_512b
no_w_512b_a20:
	stc
	ret
enter_avx_w_512b:
	pusha
	mov	cx,10h
	call	Init_Aligned_Data32
	mov	di,4h
loop_w_512b_1:
	xor	dx,dx
	xor	ax,ax
loop_w_512b:
	call	ds: word ptr [set_bank_default]
	mov	ecx,ds: dword ptr [segment_bound]
	shr	ecx,9h
	mov	si,es
	movzx	esi,si
	shl	esi,4h
	push	ax
	cli
	mov	eax,cr0
	or	al,1h
	mov	cr0,eax
	jmp	$ + 2h
	mov	ax,8h
	mov	ds,ax
	vmovntdqa zmm0,[ebx]
	test	esi,3Fh
	je	loopw_avx_512b
loopw_avx_512b_unaligned:
	vmovdqu64 [esi],zmm0
	vmovdqu64 [esi + 40h],zmm0
	vmovdqu64 [esi + 80h],zmm0
	vmovdqu64 [esi + 0C0h],zmm0
	vmovdqu64 [esi + 100h],zmm0
	vmovdqu64 [esi + 140h],zmm0
	vmovdqu64 [esi + 180h],zmm0
	vmovdqu64 [esi + 1C0h],zmm0
	add	esi,200h
	dec	cx
	jne	loopw_avx_512b_unaligned
	jmp	entryw_512b_b
loopw_avx_512b:
	vmovntdq [esi],zmm0
	vmovntdq [esi + 40h],zmm0
	vmovntdq [esi + 80h],zmm0
	vmovntdq [esi + 0C0h],zmm0
	vmovntdq [esi + 100h],zmm0
	vmovntdq [esi + 140h],zmm0
	vmovntdq [esi + 180h],zmm0
	vmovntdq [esi + 1C0h],zmm0
	add	esi,200h
	dec	cx
	jne	loopw_avx_512b
entryw_512b_b:
	mov	eax,cr0
	and	al,0FEh
	mov	cr0,eax
	push	cs
	push	OFFSET go_real_mode_2
	retf
go_real_mode_2:
	mov	ax,gs
	mov	ds,ax
	sti
	pop	ax
	add	ds: dword ptr [kb_proc],ebp
	add	ax,bp
	inc	dx
	cmp	ax,256d
	jb	loop_w_512b
	mov	cx,10h
	call	Inc_Aligned_Data32
	dec	di
	jne	loop_w_512b_1
	sfence
	clc
	popa
	ret

;#############################################################################

	R_008L:

;#############################################################################

	pusha
	mov	di,4h
loop_r_008l:
	mov	esi,ds: dword ptr [current_linear_vram_address]
	mov	ecx,262144d
	xor	ax,ax
	mov	ds,ax
	rep	lods ds: byte ptr [esi]
	push	gs
	pop	ds
	dec	di
	jne	loop_r_008l
	add	ds: dword ptr [kb_proc],1024d
	clc
	popa
	ret

;#############################################################################

	R_016L:

;#############################################################################

	pusha
	mov	di,4h
loop_r_016l:
	mov	esi,ds: dword ptr [current_linear_vram_address]
	mov	ecx,131072d
	xor	ax,ax
	mov	ds,ax
	rep	lods ds: word ptr [esi]
	push	gs
	pop	ds
	dec	di
	jne	loop_r_016l
	add	ds: dword ptr [kb_proc],1024d
	clc
	popa
	ret

;#############################################################################

	R_032L:

;#############################################################################

	pusha
	mov	di,4h
loop_r_032l:
	mov	esi,ds: dword ptr [current_linear_vram_address]
	mov	ecx,65536d
	xor	ax,ax
	mov	ds,ax
	rep	lods ds: dword ptr [esi]
	push	gs
	pop	ds
	dec	di
	jne	loop_r_032l
	add	ds: dword ptr [kb_proc],1024d
	clc
	popa
	ret

;#############################################################################

	R_064L:

;#############################################################################

	test	ds: byte ptr [status_flag_0],FLAG_FPU_PRESENT
	jne	enter_fpu_r_64l
	stc
	ret
enter_fpu_r_64l:
	pusha
	mov	di,4h
loop_r_064l:
	mov	esi,ds: dword ptr [current_linear_vram_address]
	mov	cx,4096d
	xor	ax,ax
	mov	ds,ax
	fninit
loop_float_64l:
	fld	ds: qword ptr [esi]
	fstp	st(0)
	fld	ds: qword ptr [esi + 8h]
	fstp	st(0)
	fld	ds: qword ptr [esi + 10h]
	fstp	st(0)
	fld	ds: qword ptr [esi + 18h]
	fstp	st(0)
	fld	ds: qword ptr [esi + 20h]
	fstp	st(0)
	fld	ds: qword ptr [esi + 28h]
	fstp	st(0)
	fld	ds: qword ptr [esi + 30h]
	fstp	st(0)
	fld	ds: qword ptr [esi + 38h]
	fstp	st(0)
	add	esi,40h
	dec	cx
	jne	loop_float_64l
	push	gs
	pop	ds
	dec	di
	jne	loop_r_064l
	add	ds: dword ptr [kb_proc],1024d
	clc
	popa
	ret

;#############################################################################

	R_128L:

;#############################################################################

	test	ds: byte ptr [status_flag_0],FLAG_SSE
	jne	enter_sse_l_128l
	stc
	ret
enter_sse_l_128l:
	pusha
	mov	di,4h
loop_r_128l:
	mov	esi,ds: dword ptr [current_linear_vram_address]
	mov	cx,2048d
	xor	ax,ax
	mov	ds,ax
loop_sse_128l:
	movaps	xmm0,[esi]
	movaps	xmm0,[esi + 10h]
	movaps	xmm0,[esi + 20h]
	movaps	xmm0,[esi + 30h]
	movaps	xmm0,[esi + 40h]
	movaps	xmm0,[esi + 50h]
	movaps	xmm0,[esi + 60h]
	movaps	xmm0,[esi + 70h]
	add	esi,80h
	dec	cx
	jne	loop_sse_128l
	push	gs
	pop	ds
	dec	di
	jne	loop_r_128l
	add	ds: dword ptr [kb_proc],1024d
	clc
	popa
	ret

;#############################################################################

	R_256L:

;#############################################################################

	test	ds: byte ptr [status_flag_2],EXEC_AVX
	jne	no_r_avx_256
	test	ds: byte ptr [status_flag_0],FLAG_AVX
	jne	enter_avx_l_256l
no_r_avx_256:
	stc
	ret
enter_avx_l_256l:
	pusha
	mov	di,4h
loop_r_256l:
	mov	esi,ds: dword ptr [current_linear_vram_address]
	mov	cx,1024d
	mov	dl,ds: byte ptr [status_flag_0]
	cli
	mov	eax,cr0
	or	al,1h
	mov	cr0,eax
	jmp	$ + 2h
	mov	ax,8h
	mov	ds,ax
	test	esi,1Fh
	je	aligned_256_l
loop_avx_256l_unaligned:
	vmovups	ymm0,[esi]
	vmovups	ymm0,[esi + 20h]
	vmovups	ymm0,[esi + 40h]
	vmovups	ymm0,[esi + 60h]
	vmovups	ymm0,[esi + 80h]
	vmovups	ymm0,[esi + 0A0h]
	vmovups	ymm0,[esi + 0C0h]
	vmovups	ymm0,[esi + 0E0h]
	add	esi,100h
	dec	cx
	jne	loop_avx_256l_unaligned
	jmp	enterl_for_fast_avx
aligned_256_l:
	test	dl,FLAG_AVX512
	je	loop_avx_256l
loop_avx_256l_fast:
	vmovntdqa ymm0,[esi]
	vmovntdqa ymm0,[esi + 20h]
	vmovntdqa ymm0,[esi + 40h]
	vmovntdqa ymm0,[esi + 60h]
	vmovntdqa ymm0,[esi + 80h]
	vmovntdqa ymm0,[esi + 0A0h]
	vmovntdqa ymm0,[esi + 0C0h]
	vmovntdqa ymm0,[esi + 0E0h]
	add	esi,100h
	dec	cx
	jne	loop_avx_256l_fast
	jmp	enterl_for_fast_avx
loop_avx_256l:
	vmovaps ymm0,[esi]
	vmovaps ymm0,[esi + 20h]
	vmovaps ymm0,[esi + 40h]
	vmovaps ymm0,[esi + 60h]
	vmovaps ymm0,[esi + 80h]
	vmovaps ymm0,[esi + 0A0h]
	vmovaps ymm0,[esi + 0C0h]
	vmovaps ymm0,[esi + 0E0h]
	add	esi,100h
	dec	cx
	jne	loop_avx_256l
enterl_for_fast_avx:
	mov	eax,cr0
	and	al,0FEh
	mov	cr0,eax
	push	cs
	push	OFFSET go_real_mode_5
	retf
go_real_mode_5:
	mov	ax,gs
	mov	ds,ax
	sti
	dec	di
	jne	loop_r_256l
	add	ds: dword ptr [kb_proc],1024d
	lfence
	clc
	popa
	ret

;#############################################################################

	R_512L:

;#############################################################################

	test	ds: byte ptr [status_flag_2],EXEC_AVX
	jne	no_r_avx_512
	test	ds: byte ptr [status_flag_0],FLAG_AVX512
	jne	enter_avx_l_512l
no_r_avx_512:
	stc
	ret
enter_avx_l_512l:
	pusha
	mov	di,4h
loop_r_512l:
	mov	esi,ds: dword ptr [current_linear_vram_address]
	mov	cx,512d
	cli
	mov	eax,cr0
	or	al,1h
	mov	cr0,eax
	jmp	$ + 2h
	mov	ax,8h
	mov	ds,ax
	test	esi,3Fh
	je	loop_avx_512l
loop_avx_512l_unaligned:
	vmovdqu64 zmm0,[esi]
	vmovdqu64 zmm0,[esi + 40h]
	vmovdqu64 zmm0,[esi + 80h]
	vmovdqu64 zmm0,[esi + 0C0h]
	vmovdqu64 zmm0,[esi + 100h]
	vmovdqu64 zmm0,[esi + 140h]
	vmovdqu64 zmm0,[esi + 180h]
	vmovdqu64 zmm0,[esi + 1C0h]
	add	esi,200h
	dec	cx
	jne	loop_avx_512l_unaligned
	jmp	entry_512b_l
loop_avx_512l:
	vmovntdqa zmm0,[esi] 
	vmovntdqa zmm0,[esi + 40h] 
	vmovntdqa zmm0,[esi + 80h] 
	vmovntdqa zmm0,[esi + 0C0h] 
	vmovntdqa zmm0,[esi + 100h] 
	vmovntdqa zmm0,[esi + 140h] 
	vmovntdqa zmm0,[esi + 180h] 
	vmovntdqa zmm0,[esi + 1C0h] 
	add	esi,200h
	dec	cx
	jne	loop_avx_512l
entry_512b_l:
	mov	eax,cr0
	and	al,0FEh
	mov	cr0,eax
	push	cs
	push	OFFSET go_real_mode_6
	retf
go_real_mode_6:
	mov	ax,gs
	mov	ds,ax
	sti
	dec	di
	jne	loop_r_512l
	add	ds: dword ptr [kb_proc],1024d
	lfence
	clc
	popa
	ret

;#############################################################################

	W_008L:

;#############################################################################

	pusha
	mov	si,4h
	xor	al,al
loop_w_008l:
	mov	edi,ds: dword ptr [current_linear_vram_address]
	mov	ecx,262144d
	push	es
	xor	dx,dx
	mov	es,dx
	rep	stos es: byte ptr [edi]
	pop	es
	add	al,3Fh
	dec	si
	jne	loop_w_008l
	add	ds: dword ptr [kb_proc],1024d
	clc
	popa
	ret

;#############################################################################

	W_016L:

;#############################################################################

	pusha
	mov	si,4h
	xor	ax,ax
loop_w_016l:
	mov	edi,ds: dword ptr [current_linear_vram_address]
	mov	ecx,131072d
	push	es
	xor	dx,dx
	mov	es,dx
	rep	stos es: word ptr [edi]
	pop	es
	add	ax,3F3Fh
	dec	si
	jne	loop_w_016l
	add	ds: dword ptr [kb_proc],1024d
	clc
	popa
	ret

;#############################################################################

	W_032L:

;#############################################################################

	pusha
	mov	si,4h
	xor	eax,eax
loop_w_032l:
	mov	edi,ds: dword ptr [current_linear_vram_address]
	mov	ecx,65536d
	push	es
	xor	dx,dx
	mov	es,dx
	rep	stos es: dword ptr [edi]
	pop	es
	add	eax,3F3F3F3Fh
	dec	si
	jne	loop_w_032l
	add	ds: dword ptr [kb_proc],1024d
	clc
	popa
	ret

;#############################################################################

	W_064L:

;#############################################################################

	test	ds: byte ptr [status_flag_0],FLAG_FPU_PRESENT
	jne	enter_fpu_w_64l
	stc
	ret
enter_fpu_w_64l:
	pusha
	mov	cx,2h
	call	Init_Align_Data16
	mov	di,4h
loop_w_064l:
	mov	esi,ds: dword ptr [current_linear_vram_address]
	mov	cx,4096d
	fninit
	fld	ds: qword ptr [bx]
	xor	ax,ax
	mov	ds,ax
loopw_float_64l:
	fst	ds: qword ptr [esi]
	fst	ds: qword ptr [esi + 8h]
	fst	ds: qword ptr [esi + 10h]
	fst	ds: qword ptr [esi + 18h]
	fst	ds: qword ptr [esi + 20h]
	fst	ds: qword ptr [esi + 28h]
	fst	ds: qword ptr [esi + 30h]
	fst	ds: qword ptr [esi + 38h]
	add	esi,40h
	dec	cx
	jne	loopw_float_64l
	push	gs
	pop	ds
	mov	cx,2h
	call	Inc_Aligned_Data16
	dec	di
	jne	loop_w_064l
	add	ds: dword ptr [kb_proc],1024d
	clc
	popa
	ret

;#############################################################################

	W_128L:

;#############################################################################

	test	ds: byte ptr [status_flag_0],FLAG_SSE
	jne	enter_sse_w_128l
	stc
	ret
enter_sse_w_128l:
	pusha
	mov	cx,4h
	call	Init_Align_Data16
	mov	di,4h
loop_w_128l:
	mov	esi,ds: dword ptr [current_linear_vram_address]
	mov	cx,2048d
	movaps	xmm0,[bx]
	xor	ax,ax
	mov	ds,ax
loopw_sse_128l:
	movntps	[esi],xmm0
	movntps	[esi + 10h],xmm0
	movntps	[esi + 20h],xmm0
	movntps	[esi + 30h],xmm0
	movntps	[esi + 40h],xmm0
	movntps	[esi + 50h],xmm0
	movntps	[esi + 60h],xmm0
	movntps	[esi + 70h],xmm0
	add	esi,80h
	dec	cx
	jne	loopw_sse_128l
	push	gs
	pop	ds
	mov	cx,4h
	call	Inc_Aligned_Data16
	dec	di
	jne	loop_w_128l
	add	ds: dword ptr [kb_proc],1024d
	sfence
	clc
	popa
	ret

;#############################################################################

	W_256L:

;#############################################################################

	test	ds: byte ptr [status_flag_2],EXEC_AVX
	jne	no_w_avx_256
	test	ds: byte ptr [status_flag_0],FLAG_AVX
	jne	enter_avx_w_256l
no_w_avx_256:
	stc
	ret
enter_avx_w_256l:
	pusha
	mov	cx,8h
	call	Init_Aligned_Data32
	mov	di,4h
loop_w_256l:
	mov	esi,ds: dword ptr [current_linear_vram_address]
	mov	cx,1024d
	cli
	mov	eax,cr0
	or	al,1h
	mov	cr0,eax
	jmp	$ + 2h
	mov	ax,8h
	mov	ds,ax
	vmovaps ymm0,[ebx]
	test	esi,1Fh
	je	loopw_avx_256l
loopw_avx_256l_unaligned:
	vmovups	[esi],ymm0
	vmovups	[esi + 20h],ymm0
	vmovups	[esi + 40h],ymm0
	vmovups	[esi + 60h],ymm0
	vmovups	[esi + 80h],ymm0
	vmovups	[esi + 0A0h],ymm0
	vmovups	[esi + 0C0h],ymm0
	vmovups	[esi + 0E0h],ymm0
	add	esi,100h
	dec	cx
	jne	loopw_avx_256l_unaligned
	jmp	enterl_for_avxw
loopw_avx_256l:
	vmovntdq [esi],ymm0
	vmovntdq [esi + 20h],ymm0
	vmovntdq [esi + 40h],ymm0
	vmovntdq [esi + 60h],ymm0
	vmovntdq [esi + 80h],ymm0
	vmovntdq [esi + 0A0h],ymm0
	vmovntdq [esi + 0C0h],ymm0
	vmovntdq [esi + 0E0h],ymm0
	add	esi,100h
	dec	cx
	jne	loopw_avx_256l
enterl_for_avxw:
	mov	eax,cr0
	and	al,0FEh
	mov	cr0,eax
	push	cs
	push	OFFSET go_real_mode_7
	retf
go_real_mode_7:
	mov	ax,gs
	mov	ds,ax
	sti
	mov	cx,8h
	call	Inc_Aligned_Data32
	dec	di
	jne	loop_w_256l
	add	ds: dword ptr [kb_proc],1024d
	sfence
	clc
	popa
	ret

;#############################################################################

	W_512L:

;#############################################################################

	test	ds: byte ptr [status_flag_2],EXEC_AVX
	jne	no_w_avx_512
	test	ds: byte ptr [status_flag_0],FLAG_AVX512
	jne	enter_avx_w_512l
no_w_avx_512:
	stc
	ret
enter_avx_w_512l:
	pusha
	mov	cx,10h
	call	Init_Aligned_Data32
	mov	di,4h
loop_w_512l:
	mov	esi,ds: dword ptr [current_linear_vram_address]
	mov	cx,512d
	cli
	mov	eax,cr0
	or	al,1h
	mov	cr0,eax
	jmp	$ + 2h
	mov	ax,8h
	mov	ds,ax
	vmovntdqa zmm0,[ebx]
	test	esi,3Fh
	je	loopw_avx_512l
loopw_avx_512l_unaligned:
	vmovdqu64 [esi],zmm0
	vmovdqu64 [esi + 40h],zmm0
	vmovdqu64 [esi + 80h],zmm0
	vmovdqu64 [esi + 0C0h],zmm0
	vmovdqu64 [esi + 100h],zmm0
	vmovdqu64 [esi + 140h],zmm0
	vmovdqu64 [esi + 180h],zmm0
	vmovdqu64 [esi + 1C0h],zmm0
	add	esi,200h
	dec	cx
	jne	loopw_avx_512l_unaligned
	jmp	entryw_512b_l
loopw_avx_512l:
	vmovntdq [esi],zmm0
	vmovntdq [esi + 40h],zmm0
	vmovntdq [esi + 80h],zmm0
	vmovntdq [esi + 0C0h],zmm0
	vmovntdq [esi + 100h],zmm0
	vmovntdq [esi + 140h],zmm0
	vmovntdq [esi + 180h],zmm0
	vmovntdq [esi + 1C0h],zmm0
	add	esi,200h
	dec	cx
	jne	loopw_avx_512l
entryw_512b_l:
	mov	eax,cr0
	and	al,0FEh
	mov	cr0,eax
	push	cs
	push	OFFSET go_real_mode_8
	retf
go_real_mode_8:
	mov	ax,gs
	mov	ds,ax
	sti
	mov	cx,10h
	call	Inc_Aligned_Data32
	dec	di
	jne	loop_w_512l
	add	ds: dword ptr [kb_proc],1024d
	sfence
	clc
	popa
	ret

;#############################################################################

	Init_Aligned_Data32:

;#############################################################################

	mov	bx,ds
	movzx	ebx,bx
	shl	ebx,4h
	add	ebx,((OFFSET end_data - OFFSET start_data) + 03Fh) AND 0FFFFFFC0h
bx_aligned:
	xor	esi,esi
	mov	ds,si
loop_aligned_data_zero_ebx:
	mov	ds: dword ptr [ebx + esi],3F3F3F3Fh
	add	si,4h
	dec	cx
	jne	loop_aligned_data_zero_ebx
	mov	si,gs
	mov	ds,si
	ret

;#############################################################################

	Inc_Aligned_Data32:

;#############################################################################

	xor	esi,esi
	mov	ds,si
loop_aligned_data_inc_ebx:
	add	ds: dword ptr [ebx + esi],3F3F3F3Fh
	add	si,4h
	dec	cx
	jne	loop_aligned_data_inc_ebx
	mov	si,gs
	mov	ds,si
	ret

;#############################################################################

	Init_Align_Data16:

;#############################################################################

	mov	bx,((OFFSET end_data - OFFSET start_data) + 0Fh) AND 0FFF0h
	xor	si,si
loop_aligned_data_zero_bx:
	mov	ds: dword ptr [bx + si],3F3F3F3Fh
	add	si,4h
	dec	cx
	jne	loop_aligned_data_zero_bx
	ret

;#############################################################################

	Inc_Aligned_Data16:

;#############################################################################

	xor	si,si
loop_aligned_data_inc_bx:
	add	ds: dword ptr [bx + si],3F3F3F3Fh
	add	si,4h
	dec	cx
	jne	loop_aligned_data_inc_bx
	ret

;#############################################################################

	dummy_R_008B:

;#############################################################################

	pusha
	mov	di,4h
dummy_loop_r_008b_1:
	xor	dx,dx
	xor	bx,bx
dummy_loop_r_008b:
	call	ds: word ptr [set_bank_default]
	mov	ecx,ds: dword ptr [segment_bound]
	shr	ecx,1h
	xor	si,si
	push	es
	pop	ds
	push	cx
	pop	cx
	push	gs
	pop	ds
	add	ds: dword ptr [kb_proc],ebp
	add	bx,bp
	inc	dx
	cmp	bx,256d
	jb	dummy_loop_r_008b
	dec	di
	jne	dummy_loop_r_008b_1
	clc
	popa
	ret

;#############################################################################

	dummy_R_016B:

;#############################################################################

	pusha
	mov	di,4h
dummy_loop_r_016b_1:
	xor	dx,dx
	xor	bx,bx
dummy_loop_r_016b:
	call	ds: word ptr [set_bank_default]
	mov	ecx,ds: dword ptr [segment_bound]
	shr	ecx,1h
	xor	si,si
	push	es
	pop	ds
	push	gs
	pop	ds
	add	ds: dword ptr [kb_proc],ebp
	add	bx,bp
	inc	dx
	cmp	bx,256d
	jb	dummy_loop_r_016b
	dec	di
	jne	dummy_loop_r_016b_1
	clc
	popa
	ret

;#############################################################################

	dummy_R_032B:

;#############################################################################

	pusha
	mov	di,4h
dummy_loop_r_032b_1:
	xor	dx,dx
	xor	bx,bx
dummy_loop_r_032b:
	call	ds: word ptr [set_bank_default]
	mov	ecx,ds: dword ptr [segment_bound]
	shr	ecx,2h
	xor	si,si
	push	es
	pop	ds
	push	gs
	pop	ds
	add	ds: dword ptr [kb_proc],ebp
	add	bx,bp
	inc	dx
	cmp	bx,256d
	jb	dummy_loop_r_032b
	dec	di
	jne	dummy_loop_r_032b_1
	clc
	popa
	ret

;#############################################################################

	dummy_R_064B:

;#############################################################################

	test	ds: byte ptr [status_flag_0],FLAG_FPU_PRESENT
	jne	dummy_enter_fpu_l_64b
	stc
	ret
dummy_enter_fpu_l_64b:
	pusha
	mov	di,4h
dummy_loop_r_064b_1:
	xor	dx,dx
	xor	bx,bx
dummy_loop_r_064b:
	call	ds: word ptr [set_bank_default]
	mov	ecx,ds: dword ptr [segment_bound]
	shr	ecx,6h
	xor	si,si
	push	es
	pop	ds
	fninit
dummy_loop_float_64b:
	add	si,40h
	dec	cx
	jne	dummy_loop_float_64b
	push	gs
	pop	ds
	add	ds: dword ptr [kb_proc],ebp
	add	bx,bp
	inc	dx
	cmp	bx,256d
	jb	dummy_loop_r_064b
	dec	di
	jne	dummy_loop_r_064b_1
	clc
	popa
	ret

;#############################################################################

	dummy_R_128B:

;#############################################################################

	test	ds: byte ptr [status_flag_0],FLAG_SSE
	jne	dummy_enter_sse_l_128b
	stc
	ret
dummy_enter_sse_l_128b:
	pusha
	mov	di,4h
dummy_loop_r_128b_1:
	xor	dx,dx
	xor	bx,bx
dummy_loop_r_128b:
	call	ds: word ptr [set_bank_default]
	mov	ecx,ds: dword ptr [segment_bound]
	shr	ecx,7h
	xor	si,si
	push	es
	pop	ds
dummy_loop_sse_128b:
	add	si,80h
	dec	cx
	jne	dummy_loop_sse_128b
	push	gs
	pop	ds
	add	ds: dword ptr [kb_proc],ebp
	add	bx,bp
	inc	dx
	cmp	bx,256d
	jb	dummy_loop_r_128b
	dec	di
	jne	dummy_loop_r_128b_1
	clc
	popa
	ret

;#############################################################################

	dummy_R_256B:

;#############################################################################

	test	ds: byte ptr [status_flag_2],EXEC_AVX
	jne	dummy_no_r_256b_a20
	test	ds: byte ptr [status_flag_2],A20_ENABLED
	je	dummy_no_r_256b_a20
	test	ds: byte ptr [status_flag_0],FLAG_AVX
	jne	dummy_enter_avx_l_256b
dummy_no_r_256b_a20:
	stc
	ret
dummy_enter_avx_l_256b:
	pusha
	mov	di,4h
dummy_loop_r_256b_1:
	xor	dx,dx
	xor	bx,bx
dummy_loop_r_256b:
	call	ds: word ptr [set_bank_default]
	mov	ecx,ds: dword ptr [segment_bound]
	shr	ecx,8h
	mov	si,es
	movzx	esi,si
	shl	esi,4h
	push	dx
	mov	dl,ds: byte ptr [status_flag_0]
	cli
	mov	eax,cr0
	or	al,1h
	mov	cr0,eax
	jmp	$ + 2h
	mov	ax,8h
	mov	ds,ax
	test	esi,1Fh
	je	dummy_aligned_256_r
dummy_loop_avx_256b_unaligned:
	add	esi,100h
	dec	cx
	jne	dummy_loop_avx_256b_unaligned
	jmp	dummy_enter_for_fast_avx
dummy_aligned_256_r:
	test	dl,FLAG_AVX512
	je	dummy_loop_avx_256b
dummy_loop_avx_256b_fast:
	add	esi,100h
	dec	cx
	jne	dummy_loop_avx_256b_fast
	jmp	dummy_enter_for_fast_avx
dummy_loop_avx_256b:
	add	esi,100h
	dec	cx
	jne	dummy_loop_avx_256b
dummy_enter_for_fast_avx:
	mov	eax,cr0
	and	al,0FEh
	mov	cr0,eax
	push	cs
	push	OFFSET dummy_go_real_mode_3
	retf
dummy_go_real_mode_3:
	mov	ax,gs
	mov	ds,ax
	sti
	add	ds: dword ptr [kb_proc],ebp
	add	bx,bp
	pop	dx
	inc	dx
	cmp	bx,256d
	jb	dummy_loop_r_256b
	dec	di
	jne	dummy_loop_r_256b_1
	clc
	popa
	ret

;#############################################################################

	dummy_R_512B:

;#############################################################################

	test	ds: byte ptr [status_flag_2],EXEC_AVX
	jne	dummy_no_r_512b_a20
	test	ds: byte ptr [status_flag_2],A20_ENABLED
	je	dummy_no_r_512b_a20
	test	ds: byte ptr [status_flag_0],FLAG_AVX512
	jne	dummy_enter_avx_l_512b
dummy_no_r_512b_a20:
	stc
	ret
dummy_enter_avx_l_512b:
	pusha
	mov	di,4h
dummy_loop_r_512b_1:
	xor	dx,dx
	xor	bx,bx
dummy_loop_r_512b:
	call	ds: word ptr [set_bank_default]
	mov	ecx,ds: dword ptr [segment_bound]
	shr	ecx,9h
	mov	si,es
	movzx	esi,si
	shl	esi,4h
	cli
	mov	eax,cr0
	or	al,1h
	mov	cr0,eax
	jmp	$ + 2h
	mov	ax,8h
	mov	ds,ax
	test	esi,3Fh
	je	dummy_loop_avx_512b
dummy_loop_avx_512b_unaligned:
	add	esi,200h
	dec	cx
	jne	dummy_loop_avx_512b_unaligned
	jmp	dummy_entry_512b_b
dummy_loop_avx_512b:
	add	esi,200h
	dec	cx
	jne	dummy_loop_avx_512b
dummy_entry_512b_b:
	mov	eax,cr0
	and	al,0FEh
	mov	cr0,eax
	push	cs
	push	OFFSET dummy_go_real_mode_1
	retf
dummy_go_real_mode_1:
	mov	ax,gs
	mov	ds,ax
	sti
	add	ds: dword ptr [kb_proc],ebp
	add	bx,bp
	inc	dx
	cmp	bx,256d
	jb	dummy_loop_r_512b
	dec	di
	jne	dummy_loop_r_512b_1
	clc
	popa
	ret

;#############################################################################

	dummy_W_008B:

;#############################################################################

	pusha
	mov	si,4h
	xor	al,al
dummy_loop_w_008b_1:
	xor	dx,dx
	xor	bx,bx
dummy_loop_w_008b:
	call	ds: word ptr [set_bank_default]
	mov	ecx,ds: dword ptr [segment_bound]
	shr	ecx,1h
	xor	di,di
	push	cx
	pop	cx
	add	ds: dword ptr [kb_proc],ebp
	add	bx,bp
	inc	dx
	cmp	bx,256d
	jb	dummy_loop_w_008b
	add	al,3Fh
	dec	si
	jne	dummy_loop_w_008b_1
	clc
	popa
	ret

;#############################################################################

	dummy_W_016B:

;#############################################################################

	pusha
	mov	si,4h
	xor	ax,ax
dummy_loop_w_016b_1:
	xor	dx,dx
	xor	bx,bx
dummy_loop_w_016b:
	call	ds: word ptr [set_bank_default]
	mov	ecx,ds: dword ptr [segment_bound]
	shr	ecx,1h
	xor	di,di
	add	ds: dword ptr [kb_proc],ebp
	add	bx,bp
	inc	dx
	cmp	bx,256d
	jb	dummy_loop_w_016b
	add	ax,3F3Fh
	dec	si
	jne	dummy_loop_w_016b_1
	clc
	popa
	ret

;#############################################################################

	dummy_W_032B:

;#############################################################################

	pusha
	xor	eax,eax
	mov	si,4h
dummy_loop_w_032b_1:
	xor	dx,dx
	xor	bx,bx
dummy_loop_w_032b:
	call	ds: word ptr [set_bank_default]
	mov	ecx,ds: dword ptr [segment_bound]
	shr	ecx,2h
	xor	di,di
	add	ds: dword ptr [kb_proc],ebp
	add	bx,bp
	inc	dx
	cmp	bx,256d
	jb	dummy_loop_w_032b
	add	eax,3F3F3F3Fh
	dec	si
	jne	dummy_loop_w_032b_1
	clc
	popa
	ret

;#############################################################################

	dummy_W_064B:

;#############################################################################

	test	ds: byte ptr [status_flag_0],FLAG_FPU_PRESENT
	jne	dummy_enter_fpu_w_64b
	stc
	ret
dummy_enter_fpu_w_64b:
	pusha
	mov	cx,2h
	call	Init_Align_Data16
	mov	di,4h
dummy_loop_w_064b_1:
	xor	dx,dx
	xor	ax,ax
dummy_loop_w_064b:
	call	ds: word ptr [set_bank_default]
	mov	ecx,ds: dword ptr [segment_bound]
	shr	ecx,6h
	xor	si,si
	fninit
	fld	ds: qword ptr [bx]
	push	es
	pop	ds
dummy_loopw_float_64b:
	add	si,40h
	dec	cx
	jne	dummy_loopw_float_64b
	push	gs
	pop	ds
	add	ds: dword ptr [kb_proc],ebp
	add	ax,bp
	inc	dx
	cmp	ax,256d
	jb	dummy_loop_w_064b
	mov	cx,2h
	call	Inc_Aligned_Data16
	dec	di
	jne	dummy_loop_w_064b_1
	clc
	popa
	ret

;#############################################################################

	dummy_W_128B:

;#############################################################################

	test	ds: byte ptr [status_flag_0],FLAG_SSE
	jne	dummy_enter_sse_w_128b
	stc
	ret
dummy_enter_sse_w_128b:
	pusha
	mov	cx,4h
	call	Init_Align_Data16
	mov	di,4h
dummy_loop_w_128b_1:
	xor	dx,dx
	xor	ax,ax
dummy_loop_w_128b:
	call	ds: word ptr [set_bank_default]
	mov	ecx,ds: dword ptr [segment_bound]
	shr	ecx,7h
	xor	si,si
	movaps	xmm0,[bx]
	push	es
	pop	ds
dummy_loopw_sse_128b:
	add	si,80h
	dec	cx
	jne	dummy_loopw_sse_128b
	push	gs
	pop	ds
	add	ds: dword ptr [kb_proc],ebp
	add	ax,bp
	inc	dx
	cmp	ax,256d
	jb	dummy_loop_w_128b
	mov	cx,4h
	call	Inc_Aligned_Data16
	dec	di
	jne	dummy_loop_w_128b_1
	clc
	popa
	ret
                           
;#############################################################################

	dummy_W_256B:

;#############################################################################

	test	ds: byte ptr [status_flag_2],EXEC_AVX
	jne	dummy_no_w_256b_a20
	test	ds: byte ptr [status_flag_2],A20_ENABLED
	je	dummy_no_w_256b_a20
	test	ds: byte ptr [status_flag_0],FLAG_AVX
	jne	dummy_enter_avx_w_256b
dummy_no_w_256b_a20:
	stc
	ret
dummy_enter_avx_w_256b:
	pusha
	mov	cx,8h
	call	Init_Aligned_Data32
	mov	di,4h
dummy_loop_w_256b_1:
	xor	dx,dx
	xor	ax,ax
dummy_loop_w_256b:
	call	ds: word ptr [set_bank_default]
	mov	ecx,ds: dword ptr [segment_bound]
	shr	ecx,8h
	mov	si,es
	movzx	esi,si
	shl	esi,4h
	push	ax
	cli
	mov	eax,cr0
	or	al,1h
	mov	cr0,eax
	jmp	$ + 2h
	mov	ax,8h
	mov	ds,ax
	vmovaps ymm0,[ebx]
	test	esi,1Fh
	je	dummy_loopw_avx_256b
dummy_loopw_avx_256b_unaligned:
	add	esi,100h
	dec	cx
	jne	dummy_loopw_avx_256b_unaligned
	jmp	dummy_enter_for_avxw
dummy_loopw_avx_256b:
	add	esi,100h
	dec	cx
	jne	dummy_loopw_avx_256b
dummy_enter_for_avxw:
	mov	eax,cr0
	and	al,0FEh
	mov	cr0,eax
	push	cs
	push	OFFSET dummy_go_real_mode_4
	retf
dummy_go_real_mode_4:
	mov	ax,gs
	mov	ds,ax
	sti
	pop	ax
	add	ds: dword ptr [kb_proc],ebp
	add	ax,bp
	inc	dx
	cmp	ax,256d
	jb	dummy_loop_w_256b
	mov	cx,8h
	call	Inc_Aligned_Data32
	dec	di
	jne	dummy_loop_w_256b_1
	clc
	popa
	ret

;#############################################################################

	dummy_W_512B:

;#############################################################################

	test	ds: byte ptr [status_flag_2],EXEC_AVX
	jne	dummy_no_w_512b_a20
	test	ds: byte ptr [status_flag_2],A20_ENABLED
	je	dummy_no_w_512b_a20
	test	ds: byte ptr [status_flag_0],FLAG_AVX512
	jne	dummy_enter_avx_w_512b
dummy_no_w_512b_a20:
	stc
	ret
dummy_enter_avx_w_512b:
	pusha
	mov	cx,10h
	call	Init_Aligned_Data32
	mov	di,4h
dummy_loop_w_512b_1:
	xor	dx,dx
	xor	ax,ax
dummy_loop_w_512b:
	call	ds: word ptr [set_bank_default]
	mov	ecx,ds: dword ptr [segment_bound]
	shr	ecx,9h
	mov	si,es
	movzx	esi,si
	shl	esi,4h
	push	ax
	cli
	mov	eax,cr0
	or	al,1h
	mov	cr0,eax
	jmp	$ + 2h
	mov	ax,8h
	mov	ds,ax
	vmovntdqa zmm0,[ebx]
	test	esi,3Fh
	je	dummy_loopw_avx_512b
dummy_loopw_avx_512b_unaligned:
	add	esi,200h
	dec	cx
	jne	dummy_loopw_avx_512b_unaligned
	jmp	dummy_entryw_512b_b
dummy_loopw_avx_512b:
	add	esi,200h
	dec	cx
	jne	dummy_loopw_avx_512b
dummy_entryw_512b_b:
	mov	eax,cr0
	and	al,0FEh
	mov	cr0,eax
	push	cs
	push	OFFSET dummy_go_real_mode_2
	retf
dummy_go_real_mode_2:
	mov	ax,gs
	mov	ds,ax
	sti
	pop	ax
	add	ds: dword ptr [kb_proc],ebp
	add	ax,bp
	inc	dx
	cmp	ax,256d
	jb	dummy_loop_w_512b
	mov	cx,10h
	call	Inc_Aligned_Data32
	dec	di
	jne	dummy_loop_w_512b_1
	clc
	popa
	ret

;#############################################################################

	dummy_R_008L:

;#############################################################################

	pusha
	mov	di,4h
dummy_loop_r_008l:
	mov	esi,ds: dword ptr [current_linear_vram_address]
	mov	ecx,262144d
	xor	ax,ax
	mov	ds,ax
	push	gs
	pop	ds
	dec	di
	jne	dummy_loop_r_008l
	add	ds: dword ptr [kb_proc],1024d
	clc
	popa
	ret

;#############################################################################

	dummy_R_016L:

;#############################################################################

	pusha
	mov	di,4h
dummy_loop_r_016l:
	mov	esi,ds: dword ptr [current_linear_vram_address]
	mov	ecx,131072d
	xor	ax,ax
	mov	ds,ax
	push	gs
	pop	ds
	dec	di
	jne	dummy_loop_r_016l
	add	ds: dword ptr [kb_proc],1024d
	clc
	popa
	ret

;#############################################################################

	dummy_R_032L:

;#############################################################################

	pusha
	mov	di,4h
dummy_loop_r_032l:
	mov	esi,ds: dword ptr [current_linear_vram_address]
	mov	ecx,65536d
	xor	ax,ax
	mov	ds,ax
	push	gs
	pop	ds
	dec	di
	jne	dummy_loop_r_032l
	add	ds: dword ptr [kb_proc],1024d
	clc
	popa
	ret

;#############################################################################

	dummy_R_064L:

;#############################################################################

	test	ds: byte ptr [status_flag_0],FLAG_FPU_PRESENT
	jne	dummy_enter_fpu_r_64l
	stc
	ret
dummy_enter_fpu_r_64l:
	pusha
	mov	di,4h
dummy_loop_r_064l:
	mov	esi,ds: dword ptr [current_linear_vram_address]
	mov	cx,4096d
	xor	ax,ax
	mov	ds,ax
	fninit
dummy_loop_float_64l:
	add	esi,40h
	dec	cx
	jne	dummy_loop_float_64l
	push	gs
	pop	ds
	dec	di
	jne	dummy_loop_r_064l
	add	ds: dword ptr [kb_proc],1024d
	clc
	popa
	ret

;#############################################################################

	dummy_R_128L:

;#############################################################################

	test	ds: byte ptr [status_flag_0],FLAG_SSE
	jne	dummy_enter_sse_l_128l
	stc
	ret
dummy_enter_sse_l_128l:
	pusha
	mov	di,4h
dummy_loop_r_128l:
	mov	esi,ds: dword ptr [current_linear_vram_address]
	mov	cx,2048d
	xor	ax,ax
	mov	ds,ax
dummy_loop_sse_128l:
	add	esi,80h
	dec	cx
	jne	dummy_loop_sse_128l
	push	gs
	pop	ds
	dec	di
	jne	dummy_loop_r_128l
	add	ds: dword ptr [kb_proc],1024d
	clc
	popa
	ret

;#############################################################################

	dummy_R_256L:

;#############################################################################

	test	ds: byte ptr [status_flag_2],EXEC_AVX
	jne	dummy_no_r_256l_avx
	test	ds: byte ptr [status_flag_0],FLAG_AVX
	jne	dummy_enter_avx_l_256l
dummy_no_r_256l_avx:
	stc
	ret
dummy_enter_avx_l_256l:
	pusha
	mov	di,4h
dummy_loop_r_256l:
	mov	esi,ds: dword ptr [current_linear_vram_address]
	mov	cx,1024d
	mov	dl,ds: byte ptr [status_flag_0]
	cli
	mov	eax,cr0
	or	al,1h
	mov	cr0,eax
	jmp	$ + 2h
	mov	ax,8h
	mov	ds,ax
	test	esi,1Fh
	je	dummy_aligned_256_l
dummy_loop_avx_256l_unaligned:
	add	esi,100h
	dec	cx
	jne	dummy_loop_avx_256l_unaligned
	jmp	dummy_enterl_for_fast_avx
dummy_aligned_256_l:
	test	dl,FLAG_AVX512
	je	dummy_loop_avx_256l
dummy_loop_avx_256l_fast:
	add	esi,100h
	dec	cx
	jne	dummy_loop_avx_256l_fast
	jmp	dummy_enterl_for_fast_avx
dummy_loop_avx_256l:
	add	esi,100h
	dec	cx
	jne	dummy_loop_avx_256l
dummy_enterl_for_fast_avx:
	mov	eax,cr0
	and	al,0FEh
	mov	cr0,eax
	push	cs
	push	OFFSET dummy_go_real_mode_5
	retf
dummy_go_real_mode_5:
	mov	ax,gs
	mov	ds,ax
	sti
	dec	di
	jne	dummy_loop_r_256l
	add	ds: dword ptr [kb_proc],1024d
	clc
	popa
	ret

;#############################################################################

	dummy_R_512L:

;#############################################################################

	test	ds: byte ptr [status_flag_2],EXEC_AVX
	jne	dummy_no_r_512l_avx
	test	ds: byte ptr [status_flag_0],FLAG_AVX512
	jne	dummy_enter_avx_l_512l
dummy_no_r_512l_avx:
	stc
	ret
dummy_enter_avx_l_512l:
	pusha
	mov	di,4h
dummy_loop_r_512l:
	mov	esi,ds: dword ptr [current_linear_vram_address]
	mov	cx,512d
	cli
	mov	eax,cr0
	or	al,1h
	mov	cr0,eax
	jmp	$ + 2h
	mov	ax,8h
	mov	ds,ax
	test	esi,3Fh
	je	dummy_loop_avx_512l
dummy_loop_avx_512l_unaligned:
	add	esi,200h
	dec	cx
	jne	dummy_loop_avx_512l_unaligned
	jmp	dummy_entry_512b_l
dummy_loop_avx_512l:
	add	esi,200h
	dec	cx
	jne	dummy_loop_avx_512l
dummy_entry_512b_l:
	mov	eax,cr0
	and	al,0FEh
	mov	cr0,eax
	push	cs
	push	OFFSET dummy_go_real_mode_6
	retf
dummy_go_real_mode_6:
	mov	ax,gs
	mov	ds,ax
	sti
	dec	di
	jne	dummy_loop_r_512l
	add	ds: dword ptr [kb_proc],1024d
	clc
	popa
	ret

;#############################################################################

	dummy_W_008L:

;#############################################################################

	pusha
	mov	si,4h
	xor	al,al
dummy_loop_w_008l:
	mov	edi,ds: dword ptr [current_linear_vram_address]
	mov	ecx,262144d
	push	es
	xor	dx,dx
	mov	es,dx
	pop	es
	add	al,3Fh
	dec	si
	jne	dummy_loop_w_008l
	add	ds: dword ptr [kb_proc],1024d
	clc
	popa
	ret

;#############################################################################

	dummy_W_016L:

;#############################################################################

	pusha
	mov	si,4h
	xor	ax,ax
dummy_loop_w_016l:
	mov	edi,ds: dword ptr [current_linear_vram_address]
	mov	ecx,131072d
	push	es
	xor	dx,dx
	mov	es,dx
	pop	es
	add	ax,3F3Fh
	dec	si
	jne	dummy_loop_w_016l
	add	ds: dword ptr [kb_proc],1024d
	clc
	popa
	ret

;#############################################################################

	dummy_W_032L:

;#############################################################################

	pusha
	mov	si,4h
	xor	eax,eax
dummy_loop_w_032l:
	mov	edi,ds: dword ptr [current_linear_vram_address]
	mov	ecx,65536d
	push	es
	xor	dx,dx
	mov	es,dx
	pop	es
	add	eax,3F3F3F3Fh
	dec	si
	jne	dummy_loop_w_032l
	add	ds: dword ptr [kb_proc],1024d
	clc
	popa
	ret

;#############################################################################

	dummy_W_064L:

;#############################################################################

	test	ds: byte ptr [status_flag_0],FLAG_FPU_PRESENT
	jne	dummy_enter_fpu_w_64l
	stc
	ret
dummy_enter_fpu_w_64l:
	pusha
	mov	cx,2h
	call	Init_Align_Data16
	mov	di,4h
dummy_loop_w_064l:
	mov	esi,ds: dword ptr [current_linear_vram_address]
	mov	cx,4096d
	fninit
	fld	ds: qword ptr [bx]
	xor	ax,ax
	mov	ds,ax
dummy_loopw_float_64l:
	add	esi,40h
	dec	cx
	jne	dummy_loopw_float_64l
	push	gs
	pop	ds
	mov	cx,2h
	call	Inc_Aligned_Data16
	dec	di
	jne	dummy_loop_w_064l
	add	ds: dword ptr [kb_proc],1024d
	clc
	popa
	ret

;#############################################################################

	dummy_W_128L:

;#############################################################################

	test	ds: byte ptr [status_flag_0],FLAG_SSE
	jne	dummy_enter_sse_w_128l
	stc
	ret
dummy_enter_sse_w_128l:
	pusha
	mov	cx,4h
	call	Init_Align_Data16
	mov	di,4h
dummy_loop_w_128l:
	mov	esi,ds: dword ptr [current_linear_vram_address]
	mov	cx,2048d
	movaps	xmm0,[bx]
	xor	ax,ax
	mov	ds,ax
dummy_loopw_sse_128l:
	add	esi,80h
	dec	cx
	jne	dummy_loopw_sse_128l
	push	gs
	pop	ds
	mov	cx,4h
	call	Inc_Aligned_Data16
	dec	di
	jne	dummy_loop_w_128l
	add	ds: dword ptr [kb_proc],1024d
	clc
	popa
	ret

;#############################################################################

	dummy_W_256L:

;#############################################################################

	test	ds: byte ptr [status_flag_2],EXEC_AVX
	jne	dummy_no_w_256l_avx
	test	ds: byte ptr [status_flag_0],FLAG_AVX
	jne	dummy_enter_avx_w_256l
dummy_no_w_256l_avx:
	stc
	ret
dummy_enter_avx_w_256l:
	pusha
	mov	cx,8h
	call	Init_Aligned_Data32
	mov	di,4h
dummy_loop_w_256l:
	mov	esi,ds: dword ptr [current_linear_vram_address]
	mov	cx,1024d
	cli
	mov	eax,cr0
	or	al,1h
	mov	cr0,eax
	jmp	$ + 2h
	mov	ax,8h
	mov	ds,ax
	vmovaps ymm0,[ebx]
	test	esi,1Fh
	je	dummy_loopw_avx_256l
dummy_loopw_avx_256l_unaligned:
	add	esi,100h
	dec	cx
	jne	dummy_loopw_avx_256l_unaligned
	jmp	dummy_enterl_for_avxw
dummy_loopw_avx_256l:
	add	esi,100h
	dec	cx
	jne	dummy_loopw_avx_256l
dummy_enterl_for_avxw:
	mov	eax,cr0
	and	al,0FEh
	mov	cr0,eax
	push	cs
	push	OFFSET dummy_go_real_mode_7
	retf
dummy_go_real_mode_7:
	mov	ax,gs
	mov	ds,ax
	sti
	mov	cx,8h
	call	Inc_Aligned_Data32
	dec	di
	jne	dummy_loop_w_256l
	add	ds: dword ptr [kb_proc],1024d
	clc
	popa
	ret

;#############################################################################

	dummy_W_512L:

;#############################################################################

	test	ds: byte ptr [status_flag_2],EXEC_AVX
	jne	dummy_no_w_512l_avx
	test	ds: byte ptr [status_flag_0],FLAG_AVX512
	jne	dummy_enter_avx_w_512l
dummy_no_w_512l_avx:
	stc
	ret
dummy_enter_avx_w_512l:
	pusha
	mov	cx,10h
	call	Init_Aligned_Data32
	mov	di,4h
dummy_loop_w_512l:
	mov	esi,ds: dword ptr [current_linear_vram_address]
	mov	cx,512d
	cli
	mov	eax,cr0
	or	al,1h
	mov	cr0,eax
	jmp	$ + 2h
	mov	ax,8h
	mov	ds,ax
	vmovntdqa zmm0,[ebx]
	test	esi,3Fh
	je	dummy_loopw_avx_512l
dummy_loopw_avx_512l_unaligned:
	add	esi,200h
	dec	cx
	jne	dummy_loopw_avx_512l_unaligned
	jmp	dummy_entryw_512b_l
dummy_loopw_avx_512l:
	add	esi,200h
	dec	cx
	jne	dummy_loopw_avx_512l
dummy_entryw_512b_l:
	mov	eax,cr0
	and	al,0FEh
	mov	cr0,eax
	push	cs
	push	OFFSET dummy_go_real_mode_8
	retf
dummy_go_real_mode_8:
	mov	ax,gs
	mov	ds,ax
	sti
	mov	cx,10h
	call	Inc_Aligned_Data32
	dec	di
	jne	dummy_loop_w_512l
	add	ds: dword ptr [kb_proc],1024d
	clc
	popa
	ret
