;#############################################################################

;	DS:SI = LINE struct pointer

	Write_Vertical_Line:

;#############################################################################

	push	es
	pusha
	mov	es,ds: word ptr [banked_segment]
	cmp	ds: byte ptr [bx].VESA_MODE_PANEL.VIDEO_MODE_MODEL,VESA_MODE_PLANAR
	jne	write_ver_1
	mov	ax,(VGA_MODE_REGISTER SHL 8h) + VGA_MODE_3
	call	Set_GCR
	mov	ah,VGA_SET_RESET
	mov	al,ds: byte ptr [foreground_vesa_color]
	call	Set_GCR
	mov	ax,(VGA_ENABLE_SET_RESET SHL 8h) + VGA_ALL_BITPLANES
	call	Set_GCR
	mov	ax,ds: word ptr [si].LINE.Y_POS
	mul	ds: word ptr [current_bpsl]
	mov	cx,ds: word ptr [si].LINE.X_POS
	shr	cx,3h
	add	ax,cx
	adc	dx,0h
	push	dx
	push	ax
	pop	eax
	xor	edx,edx
	div	ds: dword ptr [segment_bound]
	mov	di,dx
	xchg	ax,dx
	call	ds: word ptr [set_bank_default]
	mov	cl,ds: byte ptr [si].LINE.X_POS
	and	cl,7h
	mov	al,80h
	shr	al,cl
	mov	cx,ds: word ptr [si].LINE.LEN
	mov	si,ds: word ptr [segment_bound]
	mov	bp,ds: word ptr [current_bpsl]
	sub	si,bp
loop_pack_ver:
	mov	ah,es: byte ptr [di]
	mov	es: byte ptr [di],al
	cmp	di,si
	jb	no_inc_bank_pl_vs
	inc	dx
	call	ds: word ptr [set_bank_default]
no_inc_bank_pl_vs:
	add     di,bp
	dec	cx
	jne	loop_pack_ver
	mov	ax,(VGA_MODE_REGISTER SHL 8h) + VGA_MODE_0
	call	Set_GCR
	jmp	exit_write_ver	
write_ver_1:
	test	ds: byte ptr [status_flag_2],VESA_MEMORY_MODE
	jne	write_linear_ver_line
	mov	ax,ds: word ptr [si].LINE.Y_POS
	mul	ds: word ptr [current_bpsl]
	mov	cx,ds: word ptr [si].LINE.X_POS
	mov	bp,ds: word ptr [current_bpl]
	imul	cx,bp
	add	ax,cx
	adc	dx,0h
	push	dx
	push	ax
	pop	eax
	xor	edx,edx
	div	ds: dword ptr [segment_bound]
	mov	di,dx
	xchg	ax,dx
	call	ds: word ptr [set_bank_default]
	mov	eax,ds: dword ptr [foreground_vesa_color]
	mov	cx,ds: word ptr [si].LINE.LEN
	mov	bx,ds: word ptr [segment_bound]
	mov	bp,ds: word ptr [current_bpsl]
	mov	si,ds: word ptr [current_bpl]
	sub	bx,bp
	dec	si
	jne	no_ver_8
loop_pack_ver_8:
	mov	es: byte ptr [di],al
	cmp	di,bx
	jb	no_add_bank_ver_8
	inc	dx
	call	ds: word ptr [set_bank_default]
no_add_bank_ver_8:
	add     di,bp
	dec	cx
	jne	loop_pack_ver_8
	jmp	exit_write_ver
no_ver_8:
	dec	si
	jne	no_ver_16
loop_pack_ver_16:
	mov	es: word ptr [di],ax
	cmp	di,bx
	jb	no_add_bank_ver_16
	inc	dx
	call	ds: word ptr [set_bank_default]
no_add_bank_ver_16:
	add     di,bp
	dec	cx
	jne	loop_pack_ver_16
	jmp	exit_write_ver
no_ver_16:
	dec	si
	jne	add_bank_ver_32
	add	bx,3h
	sub	bp,3h
loop_pack_ver_24_1:
	mov	eax,ds: dword ptr [foreground_vesa_color]
	mov	si,3h
loop_pack_ver_24:
	stosb
	cmp	di,ds: word ptr [segment_bound]
	jne	no_add_bank_ver_24
	inc	dx
	call	ds: word ptr [set_bank_default]
no_add_bank_ver_24:
	shr	eax,8h
	dec	si
	jne	loop_pack_ver_24
	cmp	di,bx
	jb	no_add_bank_ver_24_1
	inc	dx
	call	ds: word ptr [set_bank_default]
no_add_bank_ver_24_1:
	add     di,bp
	dec	cx
	jne	loop_pack_ver_24_1
	jmp	exit_write_ver
add_bank_ver_32:
	mov	es: dword ptr [di],eax
	cmp	di,bx
	jb	no_add_bank_ver_32
	inc	dx
	call	ds: word ptr [set_bank_default]
no_add_bank_ver_32:
	add     di,bp
	dec	cx
	jne	add_bank_ver_32
	jmp	exit_write_ver
write_linear_ver_line:
	xor	ax,ax
	mov	es,ax
	movzx	edx,ds: word ptr [si].LINE.Y_POS
	movzx	edi,ds: word ptr [current_bpsl]
	imul	edi,edx
	movzx	ecx,ds: word ptr [si].LINE.X_POS
	movzx	ebp,ds: word ptr [current_bpl]
	imul	ecx,ebp
	add	edi,ecx
	add	edi,ds: dword ptr [current_linear_vram_address]
	mov	eax,ds: dword ptr [foreground_vesa_color]
	mov	cx,ds: word ptr [si].LINE.LEN
	movzx	ebp,ds: word ptr [current_bpsl]
	movzx	edx,ds: word ptr [current_bpl]
	sub	ebp,edx
	dec	dx
	jne	not_linear_8
loop_linear_ver_8:
	stos	es: byte ptr [edi]
	add	edi,ebp
	dec	cx
	jne	loop_linear_ver_8
	jmp	exit_write_ver
not_linear_8:
	dec	dx
	jne	not_linear_16
loop_linear_ver_16:
	stos	es: word ptr [edi]
	add	edi,ebp
	dec	cx
	jne	loop_linear_ver_16
	jmp	exit_write_ver
not_linear_16:
	dec	dx
	jne	not_linear_24
	mov	bl,ds: byte ptr [foreground_vesa_color + 2h]
loop_linear_ver_24:
	stos	es: word ptr [edi]
	xchg	ax,bx
	stos	es: byte ptr [edi]
	xchg	ax,bx
	add	edi,ebp
	dec	cx
	jne	loop_linear_ver_24
	jmp	exit_write_ver
not_linear_24:
	stos	es: dword ptr [edi]
	add	edi,ebp
	dec	cx
	jne	not_linear_24
exit_write_ver:
	popa
	pop	es
	ret
