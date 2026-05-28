;#############################################################################

;	DS:SI = LINE struct pointer

	Write_Horizontal_Line:

;#############################################################################

	push	es
	pusha
	mov	es,ds: word ptr [banked_segment]
	cmp	ds: byte ptr [bx].VESA_MODE_PANEL.VIDEO_MODE_MODEL,VESA_MODE_PLANAR
	jne	write_hor_1
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
	mov	bp,ds: word ptr [si].LINE.X_POS
	mov	bx,ds: word ptr [si].LINE.LEN
	add	bx,bp
	push	bx
	push	bp
	shr	bp,3h
	shr	bx,3h
	sub	bx,bp
	jne	multi_byte
	pop	bp
	pop	bx
	mov	cx,bp
	and	cx,7h
	mov	al,0FFh
	shr	al,cl
	mov	cx,bx
	and	cx,7h
	sub	cx,8h
	neg	cx
	mov	ah,0FFh
	shl	ah,cl
	and	al,ah
	mov	ah,es: byte ptr [di]
	mov	es: byte ptr [di],al
	jmp	exit_write_hor_1
multi_byte:
	pop	bp
	mov	cx,bp
	and	cx,7h
	mov	al,0FFh
	shr	al,cl
	mov	ah,es: byte ptr [di]
	stosb
	cmp	di,ds: word ptr [segment_bound]
	jne	no_sb_1
	inc	dx
	call	ds: word ptr [set_bank_default]
no_sb_1:
	cmp	bx,1h
	mov	cx,bx
	pop	bx
	je	two_byte
	dec	cx
	mov	ax,ds: word ptr [segment_bound]
	sub	ax,cx
	cmp	di,ax
	jae	switch_bank_01
	mov	al,0FFh
loop_multi_byte_1:
	mov	ah,es: byte ptr [di]
	stosb
	dec	cx
	jne	loop_multi_byte_1
	jmp	entry_pk_01	
switch_bank_01:
	mov	al,0FFh
loop_multi_byte:
	mov	ah,es: byte ptr [di]
	stosb
	cmp	di,ds: word ptr [segment_bound]
	jne	no_sb_2
	inc	dx
	call	ds: word ptr [set_bank_default]
no_sb_2:
	dec	cx
	jne	loop_multi_byte
entry_pk_01:
	mov	cx,bx
two_byte:
	and	cx,7h
	sub	cx,8h
	neg	cx
	mov	al,0FFh
	shl	al,cl
	mov	ah,es: byte ptr [di]
	stosb
exit_write_hor_1:
	mov	ax,(VGA_MODE_REGISTER SHL 8h) + VGA_MODE_0
	call	Set_GCR
	jmp	exit_write_hor
write_hor_1:
	test	ds: byte ptr [status_flag_2],VESA_MEMORY_MODE
	jne	write_linear_hor_line
	mov	ax,ds: word ptr [si].LINE.Y_POS
	mul	ds: word ptr [current_bpsl]
	mov	cx,ds: word ptr [si].LINE.X_POS
	mov	bp,ds: word ptr [current_bpl]
	imul	cx,bp
	add	ax,cx
	adc	dx,0h
	cmp	ds: word ptr [segment_bound],0h
	je	zero_bound
	push	dx
	push	ax
	pop	eax
	xor	edx,edx
	div	ds: dword ptr [segment_bound]
	xchg	ax,dx
zero_bound:
	mov	di,ax
	call	ds: word ptr [set_bank_default]
	mov	cx,ds: word ptr [si].LINE.LEN
	mov	ax,ds: word ptr [segment_bound]
	mov	si,bp
	imul	si,cx
	sub	ax,si
	cmp	di,ax
	xchg	ax,bp
	jae	loop_pack_hor_line
	dec	ax
	jne	switch_3
	mov	al,ds: byte ptr [foreground_vesa_color]
	mov	ah,al
	push	ax
	push	ax
	pop	eax
	shr	cx,1h
	jc	sw_1
	shr	cx,1h
	jc	sw_2
	rep	stosd
	jmp	exit_write_hor
sw_2:
	rep	stosd
	stosw
	jmp	exit_write_hor
sw_1:
	shr	cx,1h
	jc	sw_3
	rep	stosd
	stosb
	jmp	exit_write_hor
sw_3:
	rep	stosd
	stosw
	stosb
	jmp	exit_write_hor
switch_3:
	dec	ax
	jne	switch_2
	mov	ax,ds: word ptr [foreground_vesa_color]
	push	ax
	push	ax
	pop	eax
	shr	cx,1h
	jc	sw_4
	rep	stosd
	jmp	exit_write_hor
sw_4:
	rep	stosd
	stosw
	jmp	exit_write_hor
switch_2:
	dec	ax
	je	switch_4
	mov	eax,ds: dword ptr [foreground_vesa_color]
	rep	stosd
	jmp	exit_write_hor
switch_4:
	mov	al,ds: byte ptr [foreground_vesa_color]
	mov	ds: byte ptr [foreground_vesa_color + 3h],al
	mov	eax,ds: dword ptr [foreground_vesa_color]
	mov	si,OFFSET dc_24_12_color
	mov	ds: dword ptr [si],eax
	mov	al,ah
	ror	eax,8h
	mov	ds: dword ptr [si + 4h],eax
	mov	al,ah
	ror	eax,8h
	mov	ds: dword ptr [si + 8h],eax
	mov	bl,cl
	shr	cx,2h
	je	loop_pack_hor_line_3
	mov	ax,si
	mov	dx,cx
	xor	ch,ch
loop_pack_hor_line_2:
	mov	si,ax
	mov	cl,3h
	rep	movsd
	dec	dx
	jne	loop_pack_hor_line_2
	mov	si,ax
loop_pack_hor_line_3:
	and	bl,3h
	je	exit_write_hor
loop_pack_hor_line_30:
	movsw
	movsb
	dec	bl
	jne	loop_pack_hor_line_30
	jmp	exit_write_hor
loop_pack_hor_line:
	dec	ax
	jne	loop_pack_hor_line_6
	add	bp,si
	sub	bp,di
	sub	cx,bp
	xchg	cx,bp
	mov	al,ds: byte ptr [foreground_vesa_color]
	mov	ah,al
	push	ax
	push	ax
	pop	eax
	shr	cx,1h
	jc	sw_10
	shr	cx,1h
	jc	sw_20
	rep	stosd
	jmp	next_p_8
sw_20:
	rep	stosd
	stosw
	jmp	next_p_8
sw_10:
	shr	cx,1h
	jc	sw_30
	rep	stosd
	stosb
	jmp	next_p_8
sw_30:
	rep	stosd
	stosw
	stosb
next_p_8:
	inc	dx
	call	ds: word ptr [set_bank_default]
	mov	cx,bp
	shr	cx,1h
	jc	sw_100
	shr	cx,1h
	jc	sw_200
	rep	stosd
	jmp	exit_write_hor
sw_200:
	rep	stosd
	stosw
	jmp	exit_write_hor
sw_100:
	shr	cx,1h
	jc	sw_300
	rep	stosd
	stosb
	jmp	exit_write_hor
sw_300:
	rep	stosd
	stosw
	stosb
	jmp	exit_write_hor
loop_pack_hor_line_6:
	dec	ax
	jne	loop_pack_hor_line_7
	add	bp,si
	sub	bp,di
	shr	bp,1h
	sub	cx,bp
	xchg	cx,bp
	mov	ax,ds: word ptr [foreground_vesa_color]
	push	ax
	push	ax
	pop	eax
	shr	cx,1h
	jc	sw_40
	rep	stosd
	jmp	next_p_9
sw_40:
	rep	stosd
	stosw
next_p_9:
	inc	dx
	call	ds: word ptr [set_bank_default]
	mov	cx,bp
	shr	cx,1h
	jc	sw_400
	rep	stosd
	jmp	exit_write_hor
sw_400:
	rep	stosd
	stosw
	jmp	exit_write_hor
loop_pack_hor_line_7:
	dec	ax
	je	loop_pack_hor_line_8
	add	bp,si
	sub	bp,di
	shr	bp,2h
	sub	cx,bp
	xchg	cx,bp
	mov	eax,ds: dword ptr [foreground_vesa_color]
	rep	stosd
	inc	dx
	call	ds: word ptr [set_bank_default]
	mov	cx,bp
	rep	stosd
	jmp	exit_write_hor
loop_pack_hor_line_8:
	add	bp,si
	mov	al,ds: byte ptr [foreground_vesa_color]
	mov	ds: byte ptr [foreground_vesa_color + 3h],al
	mov	eax,ds: dword ptr [foreground_vesa_color]
	mov	si,OFFSET dc_24_12_color
	mov	ds: dword ptr [si],eax
	mov	al,ah
	ror	eax,8h
	mov	ds: dword ptr [si + 4h],eax
	mov	al,ah
	ror	eax,8h
	mov	ds: dword ptr [si + 8h],eax
	mov	ax,bp
	sub	ax,di
	mov	bx,3h
	xor	dx,dx
	div	bx
	mov	dx,ax
	and	dx,0FFFCh
	add	dx,4h
	sub	dx,cx
	neg	dx
	push	dx
	mov	cx,ax
	mov	bl,cl
	shr	cx,2h
	je	loop_pack_hor_line_31
	mov	ax,si
	mov	dx,cx
	xor	ch,ch
loop_pack_hor_line_21:
	mov	si,ax
	mov	cl,3h
	rep	movsd
	dec	dx
	jne	loop_pack_hor_line_21
	mov	si,ax
loop_pack_hor_line_31:
	xor	ax,ax
	and	bl,3h
	je	go_bank_24
loop_pack_hor_line_32:
	movsw
	movsb
	inc	ax
	dec	bl
	jne	loop_pack_hor_line_32
go_bank_24:
	mov	cl,3h
loop_bank_24:
	cmp	di,bp
	jne	next_24_pixel
	mov	dx,ds: word ptr [current_bank]
	inc	dx
	call	ds: word ptr [set_bank_default]
next_24_pixel:
	movsb
	dec	cx
	jne	loop_bank_24
	inc	ax
	sub	al,4h
	je	no_extra_bl
	neg	ax
	mov	bl,al
loop_pack_hor_line_3b:
	movsw
	movsb
	dec	bl
	jne	loop_pack_hor_line_3b
no_extra_bl:
	mov	si,OFFSET dc_24_12_color
	pop	cx
	mov	bl,cl
	shr	cx,2h
	je	loop_pack_hor_line_3c
	mov	ax,si
	mov	dx,cx
	xor	ch,ch
loop_pack_hor_line_211:
	mov	si,ax
	mov	cl,3h
	rep	movsd
	dec	dx
	jne	loop_pack_hor_line_211
	mov	si,ax
loop_pack_hor_line_3c:
	and	bl,3h
	je	exit_write_hor
loop_pack_hor_line_322:
	movsw
	movsb
	dec	bl
	jne	loop_pack_hor_line_322
	jmp	exit_write_hor
write_linear_hor_line:
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
	mov	cx,ds: word ptr [si].LINE.LEN
	mov	ax,ds: word ptr [current_bpl]
	dec	ax
	jne	linear_not_8
	mov	al,ds: byte ptr [foreground_vesa_color]
	mov	ah,al
	push	ax
	push	ax
	pop	eax
	shr	cx,1h
	jc	sw_1_l
	shr	cx,1h
	jc	sw_2_l
	rep	stos	es: dword ptr [edi]
	jmp	exit_write_hor
sw_2_l:
	rep	stos	es: dword ptr [edi]
	stos	es: word ptr [edi]
	jmp	exit_write_hor
sw_1_l:
	shr	cx,1h
	jc	sw_3_l
	rep	stos	es: dword ptr [edi]
	stos	es: byte ptr [edi]
	jmp	exit_write_hor
sw_3_l:
	rep	stos	es: dword ptr [edi]
	stos	es: word ptr [edi]
	stos	es: byte ptr [edi]
	jmp	exit_write_hor
linear_not_8:	
	dec	ax
	jne	linear_not_16
	mov	ax,ds: word ptr [foreground_vesa_color]
	push	ax
	push	ax
	pop	eax
	shr	cx,1h
	jc	sw_4_l
	rep	stos	es: dword ptr [edi]
	jmp	exit_write_hor
sw_4_l:
	rep	stos	es: dword ptr [edi]
	stos	es: word ptr [edi]
	jmp	exit_write_hor
linear_not_16:
	dec	ax
	je	linear_24
	mov	eax,ds: dword ptr [foreground_vesa_color]
	rep	stos	es: dword ptr [edi]
	jmp	exit_write_hor
linear_24:
	mov	al,ds: byte ptr [foreground_vesa_color]
	mov	ds: byte ptr [foreground_vesa_color + 3h],al
	mov	eax,ds: dword ptr [foreground_vesa_color]
	mov	si,OFFSET dc_24_12_color
	mov	ds: dword ptr [si],eax
	mov	al,ah
	ror	eax,8h
	mov	ds: dword ptr [si + 4h],eax
	mov	al,ah
	ror	eax,8h
	mov	ds: dword ptr [si + 8h],eax
	mov	bl,cl
	shr	cx,2h
	je	loop_pack_hor_line_3_l
	mov	ax,ds
	movzx	eax,ax
	shl	eax,4h
	movzx	esi,si
	add	esi,eax
	mov	eax,esi
	mov	dx,cx
	xor	ch,ch
loop_pack_hor_line_2_l:
	mov	esi,eax
	mov	cl,3h
	rep	movs es: dword ptr [edi],es: dword ptr [esi]
	dec	dx
	jne	loop_pack_hor_line_2_l
	mov	esi,eax
loop_pack_hor_line_3_l:
	and	bl,3h
	je	exit_write_hor
loop_pack_hor_line_30_l:
	movs es: word ptr [edi],es: word ptr [esi]
	movs es: byte ptr [edi],es: byte ptr [esi]
	dec	bl
	jne	loop_pack_hor_line_30_l
exit_write_hor:
	popa
	pop	es
	ret
