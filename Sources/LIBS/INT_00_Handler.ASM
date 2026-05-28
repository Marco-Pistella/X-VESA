;#############################################################################

	INT_00_Handler:

;#############################################################################

	pushfd
	push	gs
	push	fs
	push	es
	push	ds
	push	esp
	push	ebp
	push	edi
	push	esi
	push	edx
	push	ecx
	push	ebx
	push	eax	
	mov	ax,cs
	add	ax,((OFFSET end_code - OFFSET start_code) + 10Fh) SHR 4h
	mov	ds,ax
	mov	es,ax
	call	Init_X_Vesa
	mov	ds: byte ptr [color_base_mem],INT_OO_COLOR
	CENTER_BOX 50d,18d
	mov	si,OFFSET vga_message_293
	mov	di,OFFSET vga_message_294
	call	Extended_Box
	add	cx,902h
	mov	si,OFFSET vga_message_295
	call	Write_VGA_Message
	add	ch,6h
	mov	ds: word ptr [start_xy],cx
	mov	dx,8h
loop_regs:
	pop	eax
	call	Num_To_Str_Hex8
	call	Next_Line
	dec	dx
	jne	loop_regs
	mov	dx,4h
loop_segs:
	pop	ax
	call	Num_To_Str_Hex4
	call	Next_Line
	dec	dx
	jne	loop_segs
	pop	eax
	call	Num_To_Str_Hex8
	call	Next_Line
	pop	bx
	pop	ax
	call	Num_To_Str_Hex4
	mov	al,':'
	call	Write_Char
	xchg	ax,bx
	call	Num_To_Str_Hex4
	call	Next_Line
loop_key_int_00:
	mov	ah,KEY_FUNC_GET
	int	KEY_INTERRUPT
	cmp	ax,ESC_KEY
	jne	loop_key_int_00	
	mov	dx,ds: word ptr [old_offset_int_00]
	mov	ds,ds: word ptr [old_segment_int_00]
	mov	ax,(DOS_FUNC_SET_INTERRUPT SHL 8) + INT_00
	int	DOS_INTERRUPT
	jmp	exit_x_vesa
	