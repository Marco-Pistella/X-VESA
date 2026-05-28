;#############################################################################

;	DS:BX = Pointer to vesa_mode_info video mode

	VESA_Command_08:

;#############################################################################

	pusha
	cmp	ds: byte ptr [bx].VESA_MODE_PANEL.VIDEO_MODE_MODEL,VESA_MODE_PACKET
	je	valid_vesa_command_08
	mov	si,OFFSET vga_message_296
	call	View_Alert_Message
	popa
	ret
valid_vesa_command_08:
	or	ds: byte ptr [status_flag_4],VALID_VESA_ADDRESSING OR VALID_VESA_IO
	call	Open_VESA_Video_Mode
	jnc	valid_vesa_command_08_open
	popa
	ret
valid_vesa_command_08_open:
	or	ds: byte ptr [status_flag_5],DAC_WIDTH
	call	VESA_Command_08_01
	je	valid_dac_mode
invalid_dac_mode:
	call	Init_X_Vesa
	mov	si,OFFSET vga_message_297
	call	View_Alert_Message
	popa
	ret
valid_dac_mode:
	and	ds: byte ptr [status_flag_5],NOT DAC_WIDTH
	call	VESA_Command_08_01
	jne	invalid_dac_mode
	call	VESA_Command_08_Set_6_8
	jnc	valid_dac_write
	call	Init_X_Vesa
	mov	si,OFFSET vga_message_301
	call	View_Alert_Message
	popa
	ret
valid_dac_write:
	mov	ds: byte ptr [foreground_vesa_color],0FFh
	mov	si,OFFSET vesa_box
	mov	ds: word ptr [si].VBOX.X_START,0h
	mov	ds: word ptr [si].VBOX.Y_START,0h
	mov	ax,ds: word ptr [bx].VESA_MODE_PANEL.X_RES
	dec	ax
	mov	ds: word ptr [si].VBOX.X_END,ax
	mov	ax,ds: word ptr [bx].VESA_MODE_PANEL.Y_RES
	dec	ax
	mov	ds: word ptr [si].VBOX.Y_END,ax
	call	Write_Graphic_Box
	mov	dx,ds: word ptr [bx].VESA_MODE_PANEL.X_RES
	shr	dx,7h
	cmp	dx,4h
	jae	no_min_x_res_col
	mov	dx,4h
no_min_x_res_col:
	mov	bp,dx
	shl	dx,6h
	mov	ax,ds: word ptr [bx].VESA_MODE_PANEL.X_RES
	sub	ax,dx
	shr	ax,1h
	sub	ax,2h
	mov	ds: word ptr [si].VBOX.X_START,ax
	add	ax,dx
	add	ax,3h
	mov	ds: word ptr [si].VBOX.X_END,ax
	mov	ax,ds: word ptr [bx].VESA_MODE_PANEL.Y_RES
	shr	ax,3h
	add	ax,4h
	shl	ax,2h
	add	ax,58d
	sub	ax,ds: word ptr [bx].VESA_MODE_PANEL.Y_RES
	neg	ax
	shr	ax,1h
	mov	cx,4h
	xor	di,di
	mov	ds: word ptr [color_string_dac],OFFSET vga_message_303
	mov	ds: word ptr [dac_6_8_offset],OFFSET dac_6_8_coords
loop_box_color:
	mov	ds: word ptr [si].VBOX.Y_START,ax
	mov	dx,ds: word ptr [bx].VESA_MODE_PANEL.Y_RES
	shr	dx,3h
	add	ax,dx
	add	ax,3h
	mov	ds: word ptr [si].VBOX.Y_END,ax
	add	ax,4h
	call	Write_Graphic_Box
	push	ax
	push	cx
	push	si
	mov	ax,ds: word ptr [si].VBOX.Y_START
	mov	dx,ds: word ptr [si].VBOX.Y_END
	mov	cx,ds: word ptr [si].VBOX.X_START
	add	cx,2h
	mov	si,OFFSET little_vesa_box
	add	ax,2h
	mov	ds: word ptr [si].VBOX.Y_START,ax
	sub	dx,2h
	mov	ds: word ptr [si].VBOX.Y_END,dx
	mov	ah,40h
loop_color_shade:
	mov	ds: word ptr [foreground_vesa_color],di
	mov	ds: word ptr [si].VBOX.X_START,cx
	add	cx,bp
	dec	cx
	mov	ds: word ptr [si].VBOX.X_END,cx
	call	Write_Graphic_Box_Fill
	inc	cx
	inc	di
	dec	ah
	jne	loop_color_shade
	mov	ax,ds: word ptr [si].VBOX.Y_END
	sub	ax,ds: word ptr [si].VBOX.Y_START
	inc	ax
	sub	ax,VIDEO_FONT_HEIGHT + 8d
	shr	ax,1h
	add	ds: word ptr [si].VBOX.Y_START,ax
	mov	ax,ds: word ptr [si].VBOX.Y_START
	mov	dx,ax
	add	dx,4h
	add	ax,VIDEO_FONT_HEIGHT + 6d
	mov	ds: word ptr [si].VBOX.Y_END,ax
	mov	si,ds: word ptr [color_string_dac]
	call	Str_Len
	add	ds: word ptr [color_string_dac],ax
	inc	ds: word ptr [color_string_dac]
	imul	cx,ax,VIDEO_FONT_WIDTH
	sub	cx,ds: word ptr [bx].VESA_MODE_PANEL.X_RES
	neg	cx
	shr	cx,1h
	push	si
	mov	si,OFFSET little_vesa_box
	mov	ds: word ptr [si].VBOX.X_START,cx
	sub	ds: word ptr [si].VBOX.X_START,6h
	imul	ax,VIDEO_FONT_WIDTH
	add	ax,cx
	add	ax,6h
	mov	ds: word ptr [si].VBOX.X_END,ax
	mov	ah,ds: byte ptr [foreground_vesa_color]
	mov	ds: byte ptr [foreground_vesa_color],0FFh
	call	Write_Graphic_Box
	inc	ds: word ptr [si].VBOX.X_START
	inc	ds: word ptr [si].VBOX.Y_START
	dec	ds: word ptr [si].VBOX.X_END
	dec	ds: word ptr [si].VBOX.Y_END
	mov	ds: byte ptr [foreground_vesa_color],0h
	call	Write_Graphic_Box_fill
	mov	ds: byte ptr [foreground_vesa_color],ah
	pop	si
	call	Write_VESA_String
	mov	si,ds: word ptr [dac_6_8_offset]
	mov	ds: word ptr [si],cx
	mov	ds: word ptr [si + 2h],dx
	add	ds: word ptr [dac_6_8_offset],4h
	pop	si
	pop	cx
	pop	ax
	mov	ds: byte ptr [foreground_vesa_color],0FFh
	dec	cx
	jne	loop_box_color
	mov	dx,ds: word ptr [si].VBOX.Y_END
	add	dx,0Ah
	mov	si,OFFSET vga_message_302
	mov	di,3h
loop_write_string_68:
	call	Str_Len
	imul	cx,ax,VIDEO_FONT_WIDTH
	sub	cx,ds: word ptr [bx].VESA_MODE_PANEL.X_RES
	neg	cx
	shr	cx,1h
	call	Write_VESA_String
	add	si,ax
	inc	si
	add	dx,VIDEO_FONT_HEIGHT + 4d
	dec	di
	jne	loop_write_string_68
loop_68_dac_key:
	call	Get_Key
	cmp	ax,PLUS_KEY
	je	enter_toggle_68
	cmp	ax,SPACE_KEY
	jne	test_key_68
enter_toggle_68:
	xor	ds: byte ptr [status_flag_5],DAC_WIDTH
	call	VESA_Command_08_01
	call	VESA_Command_08_Set_6_8
	mov	si,OFFSET dac_6_8_coords
	xor	di,di
loop_write_6_8_dac_string:
	lodsw
	xchg	ax,cx
	movzx	ax,ds: byte ptr [di + table_dac_offset_string]
	add	cx,ax
	lodsw
	xchg	ax,dx
	inc	di
	mov	ax,di
	shl	ax,6h
	dec	ax
	mov	ds: byte ptr [foreground_vesa_color],al
	mov	al,'6'
	test	ds: byte ptr [status_flag_5],DAC_WIDTH
	je	ok_dac_string_6
	mov	al,'8'
ok_dac_string_6:
	or	ds: byte ptr [status_flag_3],VESA_TRANSPARENCY
	call	Write_VESA_Char
	and	ds: byte ptr [status_flag_3],NOT VESA_TRANSPARENCY
	cmp	di,4h
	jne	loop_write_6_8_dac_string
	jmp	loop_68_dac_key
test_key_68:
	cmp	ax,ESC_KEY
	jne	loop_68_dac_key
	and	ds: byte ptr [status_flag_5],NOT (DAC_VGA OR DAC_WIDTH)
	call	VESA_Command_08_01
	call	Init_X_Vesa
	popa
	ret

;#############################################################################

	VESA_Command_08_Set_6_8:

;#############################################################################

	pusha
	test	ds: byte ptr [status_flag_5],DAC_VGA
	jne	set_vesa_dac
	xor	al,al
	mov	dx,VGA_DAC_INDEX_WRITE
	out	dx,al
	mov	dx,VGA_DAC_DATA
	xor	ah,ah
red_dac_set:
	mov	al,ah
	out	dx,al
	xor	al,al
	out	dx,al
	out	dx,al
	add	ah,4h
	jne	red_dac_set
green_dac_set:
	xor	al,al
	out	dx,al
	mov	al,ah
	out	dx,al
	xor	al,al
	out	dx,al
	add	ah,4h
	jne	green_dac_set
blue_dac_set:
	xor	al,al
	out	dx,al
	out	dx,al
	mov	al,ah
	out	dx,al
	add	ah,4h
	jne	blue_dac_set
gray_dac_set:
	mov	al,ah
	out	dx,al
	out	dx,al
	out	dx,al
	add	ah,4h
	jne	gray_dac_set
	clc
	popa
	ret
set_vesa_dac:
	mov	al,ah
	out	dx,al
	push	ss
	pop	es
	xor	di,di
	mov	cx,10h
loop_vesa_rgb_palette:
	movzx	eax,ch
	shl	eax,cl
	stosd	
	add	ch,4h
	jne	loop_vesa_rgb_palette
	sub	cl,8h
	jns	loop_vesa_rgb_palette
	xor	ah,ah
loop_vesa_gray_palette:
	mov	al,ah
	stosb
	stosb
	stosb
	xor	al,al
	stosb
	add	ah,4h
	jne	loop_vesa_gray_palette
	mov	ax,(VESA_ID SHL 8h) + VESA_FUNC_SET_PALETTE
	xor	bl,bl
	mov	cx,100h
	xor	dx,dx
	xor	di,di
	VIDEO_CALL
	push	ds
	pop	es
	cmp	ax,VESA_ID
	je	ok_set_palette
	stc
	popa
	ret
ok_set_palette:
	clc
	popa
	ret

;#############################################################################

;	DS:BX = Pointer to vesa_mode_info video mode

	VESA_Command_08_01:

;#############################################################################

	pusha
	mov	ax,(VESA_ID SHL 8h) + VESA_FUNC_SET_DAC
	mov	bx,600h
	test	ds: byte ptr [status_flag_5],DAC_WIDTH
	je	set_vga_dac
	mov	bh,8h
set_vga_dac:
	VIDEO_CALL
	cmp	ax,VESA_ID
	popa
	ret
