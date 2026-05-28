;#############################################################################

;	CX = Current line
;	AL = Line char for TEXT video mode
;	DS:BX = Pointer to vesa_mode_info video mode

	Line_XOR:

;#############################################################################

	pusha
	push	es
	mov	es,ds: word ptr [banked_segment]
	test	ds: byte ptr [status_flag_2],VESA_VIDEO_MODE_ON
	je	no_line_xor
	cmp	ds: byte ptr [bx].VESA_MODE_PANEL.VIDEO_MODE_MODEL,VESA_MODE_TEXT
	jne	no_vesa_text_line_xor
	movzx	ax,al
	mov	di,ds: word ptr [current_bpsl]
	imul	di,ax
	mov	cx,ds: word ptr [bx].VESA_MODE_PANEL.X_RES
loop_xor_text:
	xor	es: word ptr [di],7F00h
	add	di,2h
	loop	loop_xor_text
	jmp	no_line_xor
no_vesa_text_line_xor:
	cmp	ds: byte ptr [bx].VESA_MODE_PANEL.VIDEO_MODE_MODEL,VESA_MODE_PLANAR
	jne	xor_line_vesa_packet
	mov	ax,205h
	call	Set_GCR
	mov	ax,318h
	call	Set_GCR
	mov	ax,8FFh
	call	Set_GCR
	mov	ax,ds: word ptr [current_bpsl]
	test	ds: byte ptr [status_flag_5],VIRTUAL_VESA_VIDEO_MODE
	je	no_planar_virtual_2
	add	cx,ds: word ptr [offset_virtual_y_res]	
no_planar_virtual_2:
	mul	cx
	push	dx
	push	ax
	pop	eax
	test	ds: byte ptr [status_flag_5],VIRTUAL_VESA_VIDEO_MODE
	je	no_planar_virtual	
	movzx	edx,ds: word ptr [offset_virtual_x_res]
	shr	dx,3h
	add	eax,edx
no_planar_virtual:
	xor	edx,edx
	div	ds: dword ptr [segment_bound]
	mov	di,dx
	xchg	ax,dx	
	call	ds: word ptr [set_bank_default]
	mov	cx,ds: word ptr [bx].VESA_MODE_PANEL.X_RES
	shr	cx,3h
	test	ds: byte ptr [status_flag_5],VIRTUAL_VESA_VIDEO_MODE
	je	no_planar_virtual_1
	mov	al,ds: byte ptr [offset_virtual_x_res]
	and	al,7h
	je	no_planar_virtual_1
	push	cx
	mov	cl,8d
	sub	cl,al
	mov	al,1h
	shl	al,cl
	dec	ax
	mov	ah,VGA_BITMAP_REGISTER
	call	Set_GCR
	mov	al,0Fh
	mov	ah,es: byte ptr [di]
	stosb
	cmp	di,ds: word ptr [segment_bound]
	jne	no_xor_bank_1
	inc	dx
	call	ds: word ptr [set_bank_default]
no_xor_bank_1:
	mov	ax,8FFh
	call	Set_GCR
	pop	cx
	dec	cx
no_planar_virtual_1:
	mov	al,0Fh
xor_loop_planar:
	mov	ah,es: byte ptr [di]
	stosb
	cmp	di,ds: word ptr [segment_bound]
	jne	no_xor_bank
	inc	dx
	call	ds: word ptr [set_bank_default]
no_xor_bank:
	dec	cx
	jne	xor_loop_planar
	test	ds: byte ptr [status_flag_5],VIRTUAL_VESA_VIDEO_MODE
	je	no_planar_virtual_6
	mov	al,ds: byte ptr [offset_virtual_x_res]
	and	al,7h
	je	no_planar_virtual_2
	mov	cl,8d
	sub	cl,al
	mov	al,1h
	shl	al,cl
	dec	ax
	xor	ax,0FFh
	mov	ah,VGA_BITMAP_REGISTER
	call	Set_GCR
	mov	al,0Fh
	mov	ah,es: byte ptr [di]
	stosb
	mov	ax,8FFh
	call	Set_GCR
no_planar_virtual_6:
	mov	ax,300h
	call	Set_GCR
	mov	ax,500h
	call	Set_GCR
	jmp	no_line_xor
xor_line_vesa_packet:
	mov	ebp,5A5A5A5Ah
	test	ds: byte ptr [status_flag_5],VIRTUAL_VESA_VIDEO_MODE
	je	no_planar_virtual_4
	add	cx,ds: word ptr [offset_virtual_y_res]	
no_planar_virtual_4:
	test	ds: byte ptr [status_flag_2],VESA_MEMORY_MODE
	jne	line_xor_packet_linear
	mov	ax,ds: word ptr [current_bpsl]
	mul	cx
	push	dx
	push	ax
	pop	eax
	test	ds: byte ptr [status_flag_5],VIRTUAL_VESA_VIDEO_MODE
	je	no_packed_virtual_banked
	movzx	edx,ds: word ptr [offset_virtual_x_res]
	imul	edx,ds: dword ptr [current_bpl]
	add	eax,edx
no_packed_virtual_banked:
	xor	edx,edx
	div	ds: dword ptr [segment_bound]
	mov	di,dx
	xchg	ax,dx	
	call	ds: word ptr [set_bank_default]
	mov	cx,ds: word ptr [bx].VESA_MODE_PANEL.X_RES
	mov	ax,ds: word ptr [current_bpl]
	imul	cx,ax
	shr	cx,2h
loop_packet_xor_b:
	xor	es: dword ptr [di],ebp
	add	di,4h
	cmp	di,ds: word ptr [segment_bound]
	jne	no_xor_b_packet
	inc	dx
	call	ds: word ptr [set_bank_default]
no_xor_b_packet:
	dec	cx
	jne	loop_packet_xor_b
	jmp	no_line_xor
line_xor_packet_linear:
	xor	ax,ax
	mov	es,ax
	movzx	edi,cx
	movzx	eax,ds: word ptr [current_bpsl]
	imul	edi,eax
	add	edi,ds: dword ptr [current_linear_vram_address]
	test	ds: byte ptr [status_flag_5],VIRTUAL_VESA_VIDEO_MODE
	je	no_packed_virtual_linear
	movzx	eax,ds: word ptr [offset_virtual_x_res]
	imul	eax,ds: dword ptr [current_bpl]
	add	edi,eax
no_packed_virtual_linear:
	mov	cx,ds: word ptr [bx].VESA_MODE_PANEL.X_RES
	mov	ax,ds: word ptr [current_bpl]
	imul	cx,ax
	shr	cx,2h
loop_packet_xor_l:
	xor	es: dword ptr [edi],ebp
	add	edi,4h
	dec	cx
	jne	loop_packet_xor_l	
no_line_xor:
	pop	es
	popa
	ret
