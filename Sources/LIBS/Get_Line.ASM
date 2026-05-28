;#############################################################################

;	DS:SI = Buffer for line data (ready)
;	CX = Line to read

	Get_Line:

;	DS:SI = Buffer for line data (write)
;	AX = Line len (bytes)

;#############################################################################

	push	es
	pusha
	push	si
	test	ds: byte ptr [status_flag_2],VESA_VIDEO_MODE_ON
	jne	get_line_vesa
	mov	ax,ds
	add	ax,SEGMENT_2
	mov	es,ax
	mov	ax,cx
	mov	bp,VIDEO_FONT_HEIGHT
	xor	dx,dx
	div	bp
	mov	bp,dx
	imul	ax,2 * TEXT_WIDTH
	movzx	di,ds: byte ptr [n_saved_video_page]
	dec	di
	imul	di,2 * TEXT_WIDTH * TEXT_HEIGHT
	add	di,ax
	mov	dx,TEXT_WIDTH
loop_line_80x40:
	mov	ax,es: word ptr [di]
	movzx	bx,al
	imul	bx,VIDEO_FONT_HEIGHT
	add	bx,bp
	mov	al,ds: byte ptr [bx + font_table_8x10]
	mov	cl,80h
loop_char_font_80x40:
	mov	ch,ah
	and	ch,0Fh
	test	al,cl
	jne	set_font_pixel_80x40
	mov	ch,ah
	shr	ch,4h
set_font_pixel_80x40:
	mov	ds: byte ptr [si],ch
	inc	si
	shr	cl,1h
	jne	loop_char_font_80x40
	add	di,2h
	dec	dx
	jne	loop_line_80x40
	jmp	exit_get_line
get_line_vesa:
	cmp	ds: byte ptr [bx].VESA_MODE_PANEL.VIDEO_MODE_MODEL,VESA_MODE_TEXT
	jne	no_vesa_get_line_text
	Call	Get_Default_Font_Table
	mov	es,ds: word ptr [banked_segment]
	xchg	ax,cx
	xor	dx,dx
	div	cx
	mov	bp,ds: word ptr [current_bpsl]
	imul	ax,bp
	xchg	ax,di
loop_line_text_vesa:
	mov	ax,es: word ptr [di]
	movzx	bx,al
	imul	bx,cx
	add	bx,dx
	mov	al,ss: byte ptr [bx]
	mov	bl,80h
loop_char_font_text_vesa:
	mov	bh,ah
	and	bh,0Fh
	test	al,bl
	jne	set_font_pixel_text_vesa
	mov	bh,ah
	shr	bh,4h
set_font_pixel_text_vesa:
	mov	ds: byte ptr [si],bh
	inc	si
	shr	bl,1h
	jne	loop_char_font_text_vesa
	test	ds: byte ptr [status_flag_3],VESA_FONT_9
	je	no_add_9_pxl
	cmp	al,0C0h
	jb	add_9_0
	cmp	al,0Dfh
	jbe	add_9_x
add_9_0:
	mov	bh,ah
	shr	bh,4h
add_9_x:
	mov	ds: byte ptr [si],bh
	inc	si
no_add_9_pxl:
	add	di,2h
	sub	bp,2h
	jne	loop_line_text_vesa
	jmp	exit_get_line
no_vesa_get_line_text:
	test	ds: byte ptr [status_flag_2],VESA_MEMORY_MODE
	jne	get_line_linear
	mov	es,ds: word ptr [banked_segment]
	mov	ax,ds: word ptr [current_bpsl]
	xchg	ax,cx
	test	ds: byte ptr [status_flag_5],VIRTUAL_VESA_VIDEO_MODE
	je	no_planar_virtual_5
	add	ax,ds: word ptr [offset_virtual_y_res]	
no_planar_virtual_5:
	mul	cx
	push	dx
	push	ax
	pop	eax
	test	ds: byte ptr [status_flag_5],VIRTUAL_VESA_VIDEO_MODE
	je	no_get_line_virtual
	movzx	edx,ds: word ptr [offset_virtual_x_res]
	cmp	ds: byte ptr [bx].VESA_MODE_PANEL.VIDEO_MODE_MODEL,VESA_MODE_PLANAR
	jne	no_planar_virtual_get_line
	shr	dx,3h
	jmp	next_virtual_get_line
no_planar_virtual_get_line:
	imul	edx,ds: dword ptr [current_bpl]
next_virtual_get_line:
	add	eax,edx
no_get_line_virtual:
	xor	edx,edx
	div	ds: dword ptr [segment_bound]
	mov	di,dx
	xchg	ax,dx	
	call	ds: word ptr [set_bank_default]
	mov	cx,ds: word ptr [bx].VESA_MODE_PANEL.X_RES
	cmp	ds: byte ptr [bx].VESA_MODE_PANEL.VIDEO_MODE_MODEL,VESA_MODE_PLANAR
	jne	loop_line_packed_bank
	push	bx
	test	ds: byte ptr [status_flag_5],VIRTUAL_VESA_VIDEO_MODE
	je	no_get_line_virtual_5
	mov	al,ds: byte ptr [offset_virtual_x_res]
	and	al,7h
	je	no_get_line_virtual_5
	add	cx,8d
no_get_line_virtual_5:
	mov	bp,cx
	shr	bp,3h
loop_line_planar:
	xor	cl,cl
loop_plane_get:
	mov	al,cl
	mov	ah,VGA_READ_MAP_SELECT
	call	Set_GCR
	mov	bl,es: byte ptr [di]
	rol	ebx,8h
	inc	cx
	cmp	cl,VESA_VIDEO_MODE_4BPP
	jne	loop_plane_get
	inc	di
	cmp	di,ds: word ptr [segment_bound]
	jne	get_line_planar_nob
	inc	dx
	call	ds: word ptr [set_bank_default]
get_line_planar_nob:
	push	dx
	mov	dl,80h
	mov	cl,3h
loop_extract_plane:
	mov	ch,4h
	xor	ah,ah
loop_extract_byte:
	mov	al,bl
	rol	ebx,8h
	and	al,dl
	or	ah,al
	ror	ah,1h
	dec	ch
	jne	loop_extract_byte
	ror	ah,cl
	mov	ds: byte ptr [si],ah
	dec	cl
	inc	si
	shr	dl,1h
	jne	loop_extract_plane
	pop	dx
	dec	bp
	jne	loop_line_planar
	pop	bx
	test	ds: byte ptr [status_flag_5],VIRTUAL_VESA_VIDEO_MODE
	je	no_get_line_virtual_7
	mov	ax,ds: word ptr [offset_virtual_x_res]
	and	ax,7h
	je	no_get_line_virtual_7
	push	si
	mov	cx,ds: word ptr [bx].VESA_MODE_PANEL.X_RES
	sub	si,cx
	sub	si,8h
	mov	di,si
	add	si,ax
	push	ds
	pop	es
	rep	movsb
	pop	si
	sub	si,8h
no_get_line_virtual_7:
	mov	ax,500h
	call	Set_GCR
	jmp	exit_get_line
loop_line_packed_bank:
	push	cx
	cmp	ds: byte ptr [bx].VESA_MODE_PANEL.VIDEO_MODE_MODEL,VESA_MODE_DIRECT_COLOR
	je	get_line_direct_color_b
	mov	al,es: byte ptr [di]
	mov	ds: byte ptr [si],al
	inc	si
	inc	di
	cmp	di,ds: word ptr [segment_bound]
	jne	get_line_next_pixel_b
	inc	dx
	call	ds: word ptr [set_bank_default]
	jmp	get_line_next_pixel_b
get_line_direct_color_b:
	xor	eax,eax
	xor	cl,cl
loop_get_line_dcb:
	movzx	ebp,es: byte ptr [di]
	shl	ebp,cl
	or	eax,ebp
	inc	di
	cmp	di,ds: word ptr [segment_bound]
	jne	get_line_dc_nob
	inc	dx
	call	ds: word ptr [set_bank_default]
get_line_dc_nob:
	add	cl,8h
	cmp	cl,ds: byte ptr [bx].VESA_MODE_PANEL.MEMORY_BPP
	jb	loop_get_line_dcb
	call	Get_Line_01
get_line_next_pixel_b:
	pop	cx
	dec	cx
	jne	loop_line_packed_bank
	jmp	exit_get_line
get_line_linear:
	xor	ax,ax
	mov	es,ax
	test	ds: byte ptr [status_flag_5],VIRTUAL_VESA_VIDEO_MODE
	je	no_planar_virtual_7
	add	cx,ds: word ptr [offset_virtual_y_res]	
no_planar_virtual_7:
	movzx	edi,cx
	movzx	eax,ds: word ptr [current_bpsl]
	imul	edi,eax
	add	edi,ds: dword ptr [current_linear_vram_address]
	test	ds: byte ptr [status_flag_5],VIRTUAL_VESA_VIDEO_MODE
	je	no_packed_virtual_linear_1
	movzx	eax,ds: word ptr [offset_virtual_x_res]
	imul	eax,ds: dword ptr [current_bpl]
	add	edi,eax
no_packed_virtual_linear_1:
	mov	dx,ds: word ptr [bx].VESA_MODE_PANEL.X_RES
loop_line_packed_linear:
	cmp	ds: byte ptr [bx].VESA_MODE_PANEL.VIDEO_MODE_MODEL,VESA_MODE_DIRECT_COLOR
	je	get_line_direct_color_l
	mov	al,es: byte ptr [edi]
	mov	ds: byte ptr [si],al
	inc	si
	inc	edi
	jmp	get_line_next_pixel_l
get_line_direct_color_l:
	mov	eax,es: dword ptr [edi]
	movzx	ebp,ds: byte ptr [bx].VESA_MODE_PANEL.MEMORY_BPP
	shr	ebp,3h
	add	edi,ebp
	mov	ebp,1h
	mov	cl,ds: byte ptr [bx].VESA_MODE_PANEL.COLOR_BPP
	shl	ebp,cl
	dec	ebp
	and	eax,ebp
	call	Get_Line_01
get_line_next_pixel_l:
	dec	dx
	jne	loop_line_packed_linear
exit_get_line:
	xchg	ax,si
	pop	si
	sub	ax,si
	call	Exit_Return_AX
	popa
	pop	es
	ret

;#############################################################################

	Get_Line_01:

;#############################################################################

	push	eax
	mov	cl,ds: byte ptr [dc_red_pos]
	shr	eax,cl
	mov	ebp,1h
	mov	cl,ds: byte ptr [dc_red_size]
	shl	ebp,cl
	dec	ebp
	and	eax,ebp
	mov	ch,8h
	sub	ch,cl
	mov	cl,ch
	shl	al,cl
	mov	ds: byte ptr [si],al
	inc	si
	pop	eax
	push	eax
	mov	cl,ds: byte ptr [dc_green_pos]
	shr	eax,cl
	mov	ebp,1h
	mov	cl,ds: byte ptr [dc_green_size]
	shl	ebp,cl
	dec	ebp
	and	eax,ebp
	mov	ch,8h
	sub	ch,cl
	mov	cl,ch
	shl	al,cl
	mov	ds: byte ptr [si],al
	inc	si
	pop	eax
	push	eax
	mov	cl,ds: byte ptr [dc_blue_pos]
	shr	eax,cl
	mov	ebp,1h
	mov	cl,ds: byte ptr [dc_blue_size]
	shl	ebp,cl
	dec	ebp
	and	eax,ebp
	mov	ch,8h
	sub	ch,cl
	mov	cl,ch
	shl	al,cl
	mov	ds: byte ptr [si],al
	inc	si
	pop	eax
	ret
