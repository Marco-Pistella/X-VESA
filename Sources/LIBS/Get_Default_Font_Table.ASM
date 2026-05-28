;#############################################################################

	Get_Default_Font_Table:

;	SS:[0] = Font table
;	AX = Font scan line

;#############################################################################

	test	ds: byte ptr [status_flag_4],FONT_TABLE_LOAD
	je	no_font_loaded	
	movzx	ax,ds: byte ptr [current_font_scanline]
	ret
no_font_loaded:
	push	fs
	push	es
	pusha
	and	ds: byte ptr [status_flag_3],NOT VESA_FONT_9
	xor	di,di
	mov	ah,CRTC_MAXIMUM_SCAN_LINE
	call	Get_CRTC
	and	al,VGA_MAX_FONT_HEIGHT - 1h
	inc	ax
	xchg	ax,cx
	mov	ah,1h
	call	Get_Sequencer
	mov	ch,8h
	test	al,1h
	jne	width_8_vesa_1
	inc	ch
width_8_vesa_1:
	mov	ds: byte ptr [current_font_scanrow],ch
	mov	dh,ds: byte ptr [vesa_buffer_func_1].ModeInfoBlock.XCharSize
	mov	dl,ds: byte ptr [vesa_buffer_func_1].ModeInfoBlock.YCharSize
	cmp	dh,8d
	je	ok_font_bios
	cmp	dh,9d
	jne	entry_for_9x8
	cmp	dl,8h
	je	entry_for_9x8
ok_font_bios:
	cmp	dl,8d
	je	ok_font_vesa_1
	cmp	dl,14d
	je	ok_font_vesa_1
	cmp	dl,16d
	jne	entry_for_9x8
ok_font_vesa_1:
	cmp	cx,dx
	je	ok_font_vesa
entry_for_9x8:
	cmp	ch,8d
	je	no_set_9_flag
	or	ds: byte ptr [status_flag_3],VESA_FONT_9
no_set_9_flag:
	mov	ah,4h
	call	Get_GCR
	push	ax
	mov	al,2h
	call	Set_GCR
	mov	ah,5h
	call	Get_GCR
	push	ax
	mov	al,0h
	call	Set_GCR
	mov	ah,6h
	call	Get_GCR
	push	ax
	mov	al,0h
	call	Set_GCR
	mov	ah,4h
	call	Get_Sequencer
	push	ax
	mov	al,4h
	call	Set_Sequencer
	movzx	dx,cl
	mov	ax,0A000h
	mov	es,ax
	xor	bx,bx
loop_next_vga_char:
	xor	si,si
	mov	cx,dx
loop_direct_char:
	mov	al,es: byte ptr [bx + si]
	mov	ss: byte ptr [di],al
	inc	di
	inc	si	
	loop	loop_direct_char
	add	bx,20h
	cmp	bx,2000h
	jne	loop_next_vga_char
	pop	ax
	call	Set_Sequencer
	pop	ax
	call	Set_GCR
	pop	ax
	call	Set_GCR
	pop	ax
	call	Set_GCR
	jmp	exit_get_font_size
ok_font_vesa:
	cmp	ch,8d
	je	font_8_x
	or	ds: byte ptr [status_flag_3],VESA_FONT_9
	mov	bh,2h
	mov	dh,5h
	cmp	cl,14d
	je	go_get_9
	mov	bh,6h
	mov	dh,7h
go_get_9:
	push	cx
	push	dx
	mov	ax,VGA_GET_FONT_INFO
	VIDEO_CALL
	pop	bx
	push	es
	push	bp
	mov	ax,VGA_GET_FONT_INFO
	VIDEO_CALL
	pop	fs
	pop	si
	pop	cx
	movzx	dx,cl
	mov	ax,fs
	mov	bx,es
	cmp	ax,bx
	jne	go_alternate
	cmp	bp,si
	jne	go_alternate
entry_for_get_font:
	xor	ch,ch
	shl	cx,7h
loop_move_font_9x:
	mov	ax,es: word ptr [bp]
	mov	ss: word ptr [di],ax
	add	bp,2h
	add	di,2h
	loop	loop_move_font_9x
	jmp	exit_get_font_size
go_alternate:
	xor	ch,ch
	shl	cx,7h
loop_move_font_8x_alternate:
	mov	ax,fs: word ptr [si]
	mov	ss: word ptr [di],ax
	add	si,2h
	add	di,2h
	loop	loop_move_font_8x_alternate
	mov	si,100h
next_font_patch:
	mov	al,es: byte ptr [bp]
	cmp	al,0FFh
	je	exit_get_font_size
	inc	bp
	movzx	bx,al
	imul	bx,dx
	mov	cx,dx
loop_patch_9x1x:
	mov	al,es: byte ptr [bp]
	mov	ss: byte ptr [bx],al
	inc	bx
	inc	bp
	loop	loop_patch_9x1x
	dec	si
	jne	next_font_patch
	jmp	exit_get_font_size
font_8_x:
	cmp	cl,8d
	je	special_8x8
	mov	bh,2h
	cmp	cl,14d
	je	go_get_8
	mov	bh,6h
go_get_8:
	push	cx
	mov	ax,VGA_GET_FONT_INFO
	VIDEO_CALL
	pop	cx
	movzx	dx,cl
	jmp	entry_for_get_font
special_8x8:
	mov	bh,3h
next_8x1:
	push	bx
	push	cx
	mov	ax,VGA_GET_FONT_INFO
	VIDEO_CALL
	pop	cx
	pop	bx
	movzx	dx,cl
	xor	ch,ch
	shl	cx,6h
loop_move_font_8x1:
	mov	ax,es: word ptr [bp]
	mov	ss: word ptr [di],ax
	add	bp,2h
	add	di,2h
	loop	loop_move_font_8x1
	mov	cx,dx
	inc	bh
	cmp	bh,4h
	jbe	next_8x1
exit_get_font_size:
	xchg	ax,dx
	mov	ds: byte ptr [current_font_scanline],al
	call	Exit_Return_AX
	popa
	pop	es
	pop	fs
	or	ds: byte ptr [status_flag_4],FONT_TABLE_LOAD
	ret
