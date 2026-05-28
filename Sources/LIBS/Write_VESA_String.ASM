;#############################################################################

;	DS:SI = Pointer to string
;	DS:BX = Pointer to vesa_mode_info video mode
;	CX = X coordinate
;	DX = Y coordinate

	Write_VESA_String:

;#############################################################################

	pushad
	mov	es,ds: word ptr [banked_segment]
	movzx	edi,ds: word ptr [current_bpsl]
	cmp	ds: byte ptr [bx].VESA_MODE_PANEL.VIDEO_MODE_MODEL,VESA_MODE_TEXT
	jne	check_string_4p
	imul	di,dx
	add	cx,cx
	add	di,cx
	mov	ah,ds: byte ptr [text_vesa_color]
loop_text_vesa_string:
	lodsb
	or	al,al
	je	end_vesa_text_string
	stosw
	jmp	loop_text_vesa_string
check_string_4p:
	cmp	ds: byte ptr [bx].VESA_MODE_PANEL.VIDEO_MODE_MODEL,VESA_MODE_PLANAR
	jne	check_string_packed
	mov	ax,(VGA_MODE_REGISTER SHL 8h) + VGA_MODE_0
	call	Set_GCR
	mov	ah,VGA_SET_RESET
	mov	al,ds: byte ptr [foreground_vesa_color]
	call	Set_GCR
	mov	ax,(VGA_ENABLE_SET_RESET SHL 8h) + VGA_ALL_BITPLANES
	call	Set_GCR
	test	ds: byte ptr [status_flag_3],VESA_TRANSPARENCY
	je	skip_opaque_font
	mov	ah,VGA_SET_RESET
	mov	al,ds: byte ptr [background_vesa_color]
	call	Set_GCR
	mov	es: byte ptr [0h],0h
	mov	al,es: byte ptr [0h]
	mov	ah,VGA_SET_RESET
	mov	al,ds: byte ptr [foreground_vesa_color]
	call	Set_GCR
skip_opaque_font:
	mov	ax,(VGA_MODE_REGISTER SHL 8h) + VGA_MODE_3
	call	Set_GCR
	xchg	ax,dx
	mul	di
	mov	bp,cx
	shr	bp,3h
	add	ax,bp
	adc	dx,0h
	push	dx
	push	ax
	pop	eax
	xor	edx,edx
	div	ds: dword ptr [segment_bound]
	mov	edi,edx
	xchg	ax,dx	
	and	cx,7h
	mov	ds: byte ptr [shift_font],cl
	call	ds: word ptr [set_bank_default]
	call	Str_Len
	mov	ds: word ptr [str_len_vesa],ax
	mov	ds: word ptr [line_font],0h
	mov	ds: word ptr [init_string],si
loop_char_planar:
	mov	si,ds: word ptr [init_string]
	xor	ch,ch
loop_string_planar:
	lodsb
	or	al,al
	jne	continue_string_planar
	test	ds: byte ptr [status_flag_3],VESA_TRANSPARENCY
	jne	skip_transparent_font
	mov	al,es: byte ptr [di]
skip_transparent_font:
	mov	es: byte ptr [di],ch
	jmp	end_string_planar
continue_string_planar:
	movzx	bp,al
	imul	bp,VIDEO_FONT_HEIGHT
	add	bp,ds: word ptr [line_font]
	mov	ah,ds: byte ptr [bp + font_table_8x10]
	mov	cl,ds: byte ptr [shift_font]
	xor	al,al
	shr	ax,cl
	or	ah,ch
	mov	ch,al
	mov	al,es: byte ptr [di]
	mov	es: byte ptr [di],ah
	inc	di
	cmp	di,ds: word ptr [segment_bound]
	jne	loop_string_planar
	inc	dx
	call	ds: word ptr [set_bank_default]
	jmp	loop_string_planar
end_string_planar:
	movzx	eax,ds: word ptr [current_bpsl]
	sub	ax,ds: word ptr [str_len_vesa]
	add	edi,eax
	cmp	edi,ds: dword ptr [segment_bound]
	jb	no_inc_bank_planar
	inc	dx
	call	ds: word ptr [set_bank_default]
	sub	edi,ds: dword ptr [segment_bound]
no_inc_bank_planar:
	inc	ds: word ptr [line_font]
	cmp	ds: word ptr [line_font],VIDEO_FONT_HEIGHT
	jne	loop_char_planar
	mov	ax,500h
	call	Set_GCR
	jmp	end_vesa_text_string
check_string_packed:
	test	ds: byte ptr [status_flag_2],VESA_MEMORY_MODE
	jne	write_linear_string
	xchg	ax,dx
	mul	di
	movzx	bp,ds: byte ptr [bx].VESA_MODE_PANEL.MEMORY_BPP
	shr	bp,3h
	imul	bp,cx
	add	ax,bp
	adc	dx,0h
	push	dx
	push	ax
	pop	eax
	xor	edx,edx
	div	ds: dword ptr [segment_bound]
	mov	edi,edx
	xchg	ax,dx	
	call	ds: word ptr [set_bank_default]
	call	Str_Len
	mov	ds: word ptr [str_len_vesa],ax
	mov	ds: word ptr [line_font],0h
	mov	ds: word ptr [init_string],si
loop_char_packet:
	mov	si,ds: word ptr [init_string]
loop_string_packet:
	lodsb
	or	al,al
	je	end_string_packet
	movzx	bp,al
	imul	bp,VIDEO_FONT_HEIGHT
	add	bp,ds: word ptr [line_font]
	mov	al,ds: byte ptr [bp + font_table_8x10]
	mov	ah,80h
loop_line_font_packet:
	mov	bp,OFFSET foreground_vesa_color
	test	al,ah
	jne	write_pixel_font
	test	ds: byte ptr [status_flag_3],VESA_TRANSPARENCY
	je	no_write_pixel_font
	mov	bp,OFFSET background_vesa_color
write_pixel_font:
	mov	cl,ds: byte ptr [current_bpl]
loop_write_color:
	mov	ch,ds: byte ptr [bp]
	mov	es: byte ptr [di],ch
	inc	di
	cmp	di,ds: word ptr [segment_bound]
	jne	next_byte_color
	inc	dx
	call	ds: word ptr [set_bank_default]
next_byte_color:
	inc	bp
	dec	cl
	jne	loop_write_color
	jmp	no_inc_bank_packet_font
no_write_pixel_font:
	movzx	ecx,ds: byte ptr [bx].VESA_MODE_PANEL.MEMORY_BPP
	shr	cl,3h
	add	edi,ecx
	cmp	edi,ds: dword ptr [segment_bound]
	jb	no_inc_bank_packet_font
	inc	dx
	call	ds: word ptr [set_bank_default]
	sub	edi,ds: dword ptr [segment_bound]
no_inc_bank_packet_font:
	shr	ah,1h
	jne	loop_line_font_packet
	jmp	loop_string_packet
end_string_packet:
	movzx	eax,ds: word ptr [str_len_vesa]
	movzx	ecx,ds: byte ptr [bx].VESA_MODE_PANEL.MEMORY_BPP
	imul	ecx,eax
	movzx	eax,ds: word ptr [current_bpsl]
	sub	eax,ecx
	add	edi,eax
	cmp	edi,ds: dword ptr [segment_bound]
	jb	no_inc_bank_packet
	inc	dx
	call	ds: word ptr [set_bank_default]
	sub	edi,ds: dword ptr [segment_bound]
no_inc_bank_packet:
	inc	ds: word ptr [line_font]
	cmp	ds: word ptr [line_font],VIDEO_FONT_HEIGHT
	jne	loop_char_packet
	jmp	end_vesa_text_string
write_linear_string:
	xor	ax,ax
	mov	es,ax
	movzx	edx,dx
	movzx	edi,di
	imul	edi,edx
	movzx	ecx,cx
	movzx	ebp,ds: word ptr [current_bpl]
	imul	ecx,ebp
	add	edi,ecx
	add	edi,ds: dword ptr [current_linear_vram_address]
	call	Str_Len
	mov	ds: word ptr [str_len_vesa],ax
	mov	ds: word ptr [init_string],si
	xor	dx,dx
loop_char_packet_linear:
	mov	si,ds: word ptr [init_string]
loop_string_packet_linear:
	lodsb
	or	al,al
	je	end_string_packet_linear
	movzx	bp,al
	imul	bp,VIDEO_FONT_HEIGHT
	add	bp,dx
	mov	al,ds: byte ptr [bp + font_table_8x10]
	mov	ah,80h
loop_line_font_packet_linear:
	mov	bp,OFFSET foreground_vesa_color
	test	al,ah
	jne	write_pixel_font_linear
	test	ds: byte ptr [status_flag_3],VESA_TRANSPARENCY
	je	no_write_pixel_font_linear
	mov	bp,OFFSET background_vesa_color
write_pixel_font_linear:
	mov	cl,ds: byte ptr [bx].VESA_MODE_PANEL.MEMORY_BPP
	shr	cl,3h
loop_write_color_linear:
	mov	ch,ds: byte ptr [bp]
	mov	es: byte ptr [edi],ch
	inc	edi
	inc	bp
	dec	cl
	jne	loop_write_color_linear
	jmp	no_inc_bank_packet_font_linear
no_write_pixel_font_linear:
	movzx	ecx,ds: byte ptr [bx].VESA_MODE_PANEL.MEMORY_BPP
	shr	cl,3h
	add	edi,ecx
no_inc_bank_packet_font_linear:
	shr	ah,1h
	jne	loop_line_font_packet_linear
	jmp	loop_string_packet_linear
end_string_packet_linear:
	movzx	eax,ds: word ptr [str_len_vesa]
	movzx	ecx,ds: byte ptr [bx].VESA_MODE_PANEL.MEMORY_BPP
	imul	ecx,eax
	movzx	eax,ds: word ptr [current_bpsl]
	sub	eax,ecx
	add	edi,eax
	inc	dx
	cmp	dx,VIDEO_FONT_HEIGHT
	jne	loop_char_packet_linear
end_vesa_text_string:
	push	ds
	pop	es
	popad
	ret
