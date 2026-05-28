;#############################################################################

;	DS:BX = Pointer to vesa_mode_info video mode

	VESA_Command_06:

;#############################################################################

	pusha
	cmp	ds: byte ptr [bx].VESA_MODE_PANEL.VIDEO_MODE_MODEL,VESA_MODE_PLANAR
	je	valid_vesa_command_06
	cmp	ds: byte ptr [bx].VESA_MODE_PANEL.VIDEO_MODE_MODEL,VESA_MODE_PACKET
	je	valid_vesa_command_06
	cmp	ds: byte ptr [bx].VESA_MODE_PANEL.VIDEO_MODE_MODEL,VESA_MODE_DIRECT_COLOR
	je	valid_vesa_command_06
	mov	si,OFFSET vga_message_201
	call	View_Alert_Message
	popa
	ret
valid_vesa_command_06:
	or	ds: byte ptr [status_flag_4],VALID_VESA_ADDRESSING OR VALID_VESA_IO
	call	Open_VESA_Video_Mode
	jnc	valid_vesa_command_06_open
	popa
	ret
valid_vesa_command_06_open:
	call	Retrieve_VRAM_Size
	jc	undetectable_vram_2
	or	ebp,ebp
	jne	view_vram_size_2
	call	Get_VESA_VRAM_Size
	call	Retrieve_VRAM_Size
	jnc	view_vram_size_2
undetectable_vram_2:
	call	Init_X_Vesa
	mov	si,OFFSET vga_message_198
	call	View_Alert_Message
	popa
	ret
view_vram_size_2:
	shl	ebp,0Ah
retest_vram_two_pages:
	movzx	eax,ds: word ptr [current_bpsl]
	movzx	ecx,ds: word ptr [bx].VESA_MODE_PANEL.Y_RES
	imul	eax,ecx
	cmp	ds: byte ptr [bx].VESA_MODE_PANEL.VIDEO_MODE_MODEL,VESA_MODE_PLANAR
	jne	valid_vram_size_6
	shl	eax,2h
valid_vram_size_6:
	add	eax,eax
	cmp	eax,ebp
	jbe	ok_2x_vram_size
	mov	cx,ds: word ptr [current_bpsl]
	mov	ax,8h
	mul	cx
	movzx	cx,ds: byte ptr [bx].VESA_MODE_PANEL.MEMORY_BPP
	div	cx	
	cmp	ax,ds: word ptr [bx].VESA_MODE_PANEL.X_RES
	ja	new_scanline_attempt
fail_new_scanline:
	call	Init_X_Vesa
	mov	si,OFFSET vga_message_254
	call	View_Alert_Message
	popa
	ret
new_scanline_attempt:
	or	ds: byte ptr [status_flag_2],SCANLINE_FORM
	mov	ax,ds: word ptr [bx].VESA_MODE_PANEL.X_RES
	call	Set_VESA_Scanline
	jc	fail_new_scanline
	mov	ax,ds: word ptr [scanline_vesa_bytes]
	cmp	ax,ds: word ptr [current_bpsl]
	jae	fail_new_scanline
	mov	ds: word ptr [current_bpsl],ax
	jmp	retest_vram_two_pages
ok_2x_vram_size:
	xor	edi,edi
	xchg	eax,ecx
	call	Clear_Graphic_VRAM
	call	VESA_Command_06_02
	test	ds: byte ptr [status_flag_4],VESA_DISPLAY_START
	jne	vesa_display_start_ok
	call	Init_X_Vesa
	mov	si,OFFSET vga_message_278
	test	ds: byte ptr [status_flag_6],DISPLAY_START_FAIL
	je	ds_ns
	mov	si,OFFSET vga_message_278a
ds_ns:
	call	View_Alert_Message
	popa
	ret
vesa_display_start_ok:
	mov	si,OFFSET vesa_box
	xor	bp,bp
loop_double_page:
	mov	ds: word ptr [si].VBOX.X_START,0h
	mov	ds: word ptr [si].VBOX.Y_START,bp
	mov	ax,ds: word ptr [bx].VESA_MODE_PANEL.X_RES
	dec	ax
	mov	ds: word ptr [si].VBOX.X_END,ax
	mov	ax,ds: word ptr [bx].VESA_MODE_PANEL.Y_RES
	dec	ax
	add	ax,bp
	mov	ds: word ptr [si].VBOX.Y_END,ax
	call	Write_Graphic_Box
	mov	ax,ds: word ptr [bx].VESA_MODE_PANEL.X_RES
	sub	ax,37d * VIDEO_FONT_WIDTH
	shr	ax,1h
	mov	ds: word ptr [si].VBOX.X_START,ax
	add	ax,37d * VIDEO_FONT_WIDTH - 1d
	mov	ds: word ptr [si].VBOX.X_END,ax
	mov	ax,ds: word ptr [bx].VESA_MODE_PANEL.Y_RES
	sub	ax,7d * VIDEO_FONT_HEIGHT + 36d
	shr	ax,1h
	add	ax,bp
	mov	ds: word ptr [si].VBOX.Y_START,ax
	add	ax,7d * VIDEO_FONT_HEIGHT + 35d
	mov	ds: word ptr [si].VBOX.Y_END,ax
	call	Write_Graphic_Box
	push	si
	mov	dx,ds: word ptr [si].VBOX.Y_START
	add	dx,4h
	mov	si,OFFSET vga_message_277
	mov	di,4h
loop_write_string_6:
	mov	cx,ds: word ptr [bx].VESA_MODE_PANEL.X_RES
	call	Str_Len
	imul	ax,VIDEO_FONT_WIDTH
	sub	cx,ax
	shr	cx,1h
	call	Write_VESA_String
	call	Str_Len_Mem
	add	dx,VIDEO_FONT_HEIGHT + 4d
	dec	di
	jne	loop_write_string_6
	add	dx,4d
	add	cx,8d
	call	Write_VESA_String
	push	si
	mov	si,OFFSET vga_message_033
	test	ds: byte ptr [status_flag_4],VGA_RETRACE
	je	no_vga_retrace_1
	mov	si,OFFSET vga_message_279
no_vga_retrace_1:
	add	cx,20d * VIDEO_FONT_WIDTH
	call	Write_VESA_String
	pop	si
	call	Str_Len_Mem
	add	dx,VIDEO_FONT_HEIGHT + 4d
	sub	cx,20d * VIDEO_FONT_WIDTH + 8d
	call	Write_VESA_String
	push	si
	mov	si,OFFSET vga_message_033
	test	ds: byte ptr [status_flag_4],VESA_RETRACE
	je	no_vesa_retrace_1
	mov	si,OFFSET vga_message_279
	test	ds: byte ptr [status_flag_5],VESA_RETRACE_FAIL
	je	no_vesa_retrace_1
	mov	si,OFFSET vga_message_280
no_vesa_retrace_1:
	add	cx,21d * VIDEO_FONT_WIDTH
	call	Write_VESA_String
	pop	si
	call	Str_Len_Mem
	add	dx,VIDEO_FONT_HEIGHT + 4d
	sub	cx,21d * VIDEO_FONT_WIDTH - 32d
	call	Write_VESA_String
	pop	si
	add	bp,ds: word ptr [bx].VESA_MODE_PANEL.Y_RES
	cmp	bp,ds: word ptr [bx].VESA_MODE_PANEL.Y_RES
	je	loop_double_page
	sub	dx,ds: word ptr [bx].VESA_MODE_PANEL.Y_RES
	sub	dx,2h
	mov	ds: word ptr [retrace_box_y],dx
	add	dx,VIDEO_FONT_HEIGHT + 2d
	mov	ds: word ptr [retrace_box_y + 2h],dx
	add	cx,17d * VIDEO_FONT_WIDTH - 2d
	mov	ds: word ptr [retrace_box_x],cx
	add	cx,3d * VIDEO_FONT_WIDTH + 4d
	mov	ds: word ptr [retrace_box_x + 2h],cx
	add	cx,4d
	mov	ds: word ptr [retrace_box_x + 4h],cx
	add	cx,3d * VIDEO_FONT_WIDTH + 4d
	mov	ds: word ptr [retrace_box_x + 6h],cx
	add	cx,4d
	mov	ds: word ptr [retrace_box_x + 8h],cx
	add	cx,4d * VIDEO_FONT_WIDTH + 4d
	mov	ds: word ptr [retrace_box_x + 0Ah],cx
	mov	ds: byte ptr [current_retrace],2h
	test	ds: byte ptr [status_flag_4],VESA_RETRACE
	jne	set_retrace_mode
	dec	ds: byte ptr [current_retrace]
	test	ds: byte ptr [status_flag_4],VGA_RETRACE
	jne	set_retrace_mode
	dec	ds: byte ptr [current_retrace]
set_retrace_mode:
	movzx	ebp,ds: word ptr [bx].VESA_MODE_PANEL.Y_RES
	sub	ds: word ptr [si].VBOX.Y_START,bp
	sub	ds: word ptr [si].VBOX.Y_END,bp
	mov	ax,1h
	mov	di,ax
	mov	cx,0FFFFh
	mov	dx,0FFFFh
	jmp	entry_little_box_retrace
write_little_box_retrace:
	push	ebp
	push	ax
	push	si
	push	di
	mov	si,OFFSET little_vesa_box
	mov	ds: dword ptr [foreground_vesa_color],0h
	movzx	di,ds: byte ptr [old_retrace]
	shl	di,2h
	mov	ax,ds: word ptr [retrace_box_y]
	mov	ds: word ptr [si].VBOX.Y_START,ax
	mov	ax,ds: word ptr [retrace_box_y + 2h]
	mov	ds: word ptr [si].VBOX.Y_END,ax
	mov	ax,ds: word ptr [di + retrace_box_x]
	mov	ds: word ptr [si].VBOX.X_START,ax
	mov	ax,ds: word ptr [di + retrace_box_x + 2h]
	mov	ds: word ptr [si].VBOX.X_END,ax
	call	Write_Graphic_Box
	mov	ax,ds: word ptr [bx].VESA_MODE_PANEL.Y_RES
	add	ds: word ptr [si].VBOX.Y_START,ax
	add	ds: word ptr [si].VBOX.Y_END,ax
	call	Write_Graphic_Box
	pop	di
	pop	si
	pop	ax
	pop	ebp
entry_little_box_retrace:
	push	ebp
	push	ax
	push	si
	push	di
	mov	si,OFFSET little_vesa_box
	mov	ds: byte ptr [foreground_vesa_color],0Fh
	cmp	ds: byte ptr [bx].VESA_MODE_PANEL.VIDEO_MODE_MODEL,VESA_MODE_DIRECT_COLOR
	jne	bkc_ndc_ok_1
	mov	ds: dword ptr [foreground_vesa_color],0FFFFFFFFh
bkc_ndc_ok_1:
	movzx	di,ds: byte ptr [current_retrace]
	shl	di,2h
	mov	ax,ds: word ptr [retrace_box_y]
	mov	ds: word ptr [si].VBOX.Y_START,ax
	mov	ax,ds: word ptr [retrace_box_y + 2h]
	mov	ds: word ptr [si].VBOX.Y_END,ax
	mov	ax,ds: word ptr [di + retrace_box_x]
	mov	ds: word ptr [si].VBOX.X_START,ax
	mov	ax,ds: word ptr [di + retrace_box_x + 2h]
	mov	ds: word ptr [si].VBOX.X_END,ax
	call	Write_Graphic_Box
	mov	ax,ds: word ptr [bx].VESA_MODE_PANEL.Y_RES
	add	ds: word ptr [si].VBOX.Y_START,ax
	add	ds: word ptr [si].VBOX.Y_END,ax
	call	Write_Graphic_Box
	mov	al,ds: byte ptr [current_retrace]
	mov	ds: byte ptr [old_retrace],al
	pop	di
	pop	si
	pop	ax
	pop	ebp
no_key_pressed_6:
	push	ax
	push	bx
	push	cx
	push	dx
	cmp	ds: byte ptr [current_retrace],0h
	je	no_retrace_command_6
	cmp	ds: byte ptr [current_retrace],1h
	jne	test_vesa_retrace	
	call	Get_Input_Status_Register
pre_vretrace_6:
	in	al,dx
	test	al,8h
	jne	pre_vretrace_6
pre_von_6:
	in	al,dx
	test	al,8h
	je	pre_von_6
no_retrace_command_6:
	xor	bx,bx
	jmp	retrace_command_6
test_vesa_retrace:
	mov	bx,80h
retrace_command_6:
	mov	ax,(VESA_ID SHL 8h) + VESA_FUNC_DISPLAY_START
	xor	cx,cx
	mov	dx,bp
	VIDEO_CALL
	pop	dx
	pop	cx
	pop	bx
	pop	ax
	rol	ebp,10h
	mov	ds: dword ptr [foreground_vesa_color],0h
	or	bp,bp
	je	command_6_page_0
	xchg	cx,di
	call	VESA_Command_06_01
	mov	di,cx
	jmp	move_line_6
command_6_page_0:
	xchg	dx,di
	call	VESA_Command_06_01
	mov	di,dx
move_line_6:
	mov	ds: byte ptr [foreground_vesa_color],0Fh
	cmp	ds: byte ptr [bx].VESA_MODE_PANEL.VIDEO_MODE_MODEL,VESA_MODE_DIRECT_COLOR
	jne	bkc_ndc_ok
	mov	ds: dword ptr [foreground_vesa_color],0FFFFFFFFh
bkc_ndc_ok:
	call	VESA_Command_06_01
	add	di,ax
	or	di,di
	je	move_line_61
	mov	si,ds: word ptr [bx].VESA_MODE_PANEL.Y_RES
	dec	si
	cmp	si,di
	jne	move_line_62
move_line_61:
	sub	di,ax
	sub	di,ax
	neg	ax
move_line_62:
	or	bp,bp
	je	no_key_pressed_6
	mov	si,BIOS_SAVE_AREA_SEGMENT
	mov	ds,si
	mov	si,ds: word ptr [KEYBOARD_BUFFER_HEAD]
	cmp	si,ds: word ptr [KEYBOARD_BUFFER_TAIL]
	push	es
	pop	ds
	je	no_key_pressed_6
	push	ax
	push	ebp
	call	Get_Key
	pop	ebp
	cmp	ax,F10_KEY
	jne	test_retrace_key_esc
	mov	al,ds: byte ptr [current_retrace]
next_retrace_test:
	inc	ax
	cmp	al,3h
	jne	toggle_retrace
	xor	al,al
	jmp	no_key_pressed_6_0
toggle_retrace:
	cmp	al,1h
	jne	toggle_vesa_retrace
	test	ds: byte ptr [status_flag_4],VGA_RETRACE
	jne	no_key_pressed_6_0
	inc	ax
toggle_vesa_retrace:
	test	ds: byte ptr [status_flag_4],VESA_RETRACE
	je	next_retrace_test
no_key_pressed_6_0:
	mov	ah,ds: byte ptr [current_retrace]
	mov	ds: byte ptr [current_retrace],al
	mov	ds: byte ptr [old_retrace],ah
	cmp	al,ah
	pop	ax
	je	no_key_pressed_6	
	jmp	write_little_box_retrace
test_retrace_key_esc:
	cmp	ax,ESC_KEY
	pop	ax
	jne	no_key_pressed_6
	call	Init_X_Vesa
	popa
	ret

;#############################################################################

	VESA_Command_06_01:

;#############################################################################

	push	ax
	push	ebp
	cmp	di,0FFFFh
	je	no_write_line_6
	mov	si,OFFSET vesa_line
	mov	ax,di
	add	ax,bp
	mov	ds: word ptr [si].LINE.Y_POS,ax
	cmp	di,ds: word ptr [vesa_box].VBOX.Y_START
	jb	one_line_6
	cmp	di,ds: word ptr [vesa_box].VBOX.Y_END
	ja	one_line_6
	mov	ds: word ptr [si].LINE.X_POS,1h
	mov	ax,ds: word ptr [vesa_box].VBOX.X_START
	dec	ax
	mov	ds: word ptr [si].LINE.LEN,ax
	call	Write_Horizontal_Line
	mov	ax,ds: word ptr [bx].VESA_MODE_PANEL.X_RES
	sub	ax,ds: word ptr [vesa_box].VBOX.X_END
	sub	ax,2h
	mov	ds: word ptr [si].LINE.LEN,ax
	mov	ax,ds: word ptr [vesa_box].VBOX.X_END
	inc	ax
	mov	ds: word ptr [si].LINE.X_POS,ax
	call	Write_Horizontal_Line
	jmp	no_write_line_6
one_line_6:
	mov	ds: word ptr [si].LINE.X_POS,1h
	mov	ax,ds: word ptr [bx].VESA_MODE_PANEL.X_RES
	sub	ax,2h
	mov	ds: word ptr [si].LINE.LEN,ax
	call	Write_Horizontal_Line
no_write_line_6:
	pop	ebp
	pop	ax
	ret

;#############################################################################

	VESA_Command_06_02:

;#############################################################################

	pusha
	and	ds: byte ptr [status_flag_4],NOT (VGA_RETRACE OR VESA_RETRACE OR VESA_DISPLAY_START)
	and	ds: byte ptr [status_flag_5],NOT VESA_RETRACE_FAIL
	and	ds: byte ptr [status_flag_6],NOT DISPLAY_START_FAIL
	mov	ax,(VESA_ID SHL 8h) + VESA_FUNC_DISPLAY_START
	mov	dx,ds: word ptr [bx].VESA_MODE_PANEL.Y_RES
	xor	cx,cx
	push	bx
	xor	bx,bx
	VIDEO_CALL
	pop	bx
	cmp	al,VESA_ID
	jne	check_vga_retrace
	or	ds: byte ptr [status_flag_6],DISPLAY_START_FAIL
	or	ah,ah
	jne	check_vga_retrace
	mov	ax,(VESA_ID SHL 8h) + VESA_FUNC_DISPLAY_START
	push	bx
	mov	bx,1h
	VIDEO_CALL
	pop	bx
	cmp	ax,VESA_ID
	jne	check_vga_retrace
	or	cx,cx
	jne	check_vga_retrace
	cmp	dx,ds: word ptr [bx].VESA_MODE_PANEL.Y_RES
	jne	check_vga_retrace
	mov	ax,(VESA_ID SHL 8h) + VESA_FUNC_DISPLAY_START
	xor	cx,cx
	xor	dx,dx
	push	bx
	xor	bx,bx
	VIDEO_CALL
	pop	bx
	cmp	ax,VESA_ID
	jne	check_vga_retrace
	or	ds: byte ptr [status_flag_4],VESA_DISPLAY_START
check_vga_retrace:
	call	Get_Input_Status_Register
	call	Save_Timer_Ticks
	in	al,dx
	mov	ch,al
loop_check_vretrace_1_6:
	xor	di,di
loop_check_vretrace_6:
	in	al,dx
	xor	al,ch
	test	al,8h
	je	no_vga_retrace
	or	ds: byte ptr [status_flag_4],VGA_RETRACE
	jmp	end_vga_retrace
no_vga_retrace:
	inc	di
	jne	loop_check_vretrace_6
	call	Get_BIOS_Ticks
	sub	eax,ds: dword ptr [timer_ticks]
	cmp	al,2h
	jb	loop_check_vretrace_1_6
end_vga_retrace:
	mov	ax,(VESA_ID SHL 8h) + VESA_FUNC_DISPLAY_START
	mov	dx,ds: word ptr [bx].VESA_MODE_PANEL.Y_RES
	xor	cx,cx
	push	bx
	mov	bx,80h
	VIDEO_CALL
	pop	bx
	cmp	ax,VESA_ID
	jne	exit_exec_display_start
	mov	ax,(VESA_ID SHL 8h) + VESA_FUNC_DISPLAY_START
	push	bx
	mov	bx,1h
	VIDEO_CALL
	pop	bx
	cmp	ax,VESA_ID
	jne	exit_exec_display_start
	or	cx,cx
	jne	exit_exec_display_start
	cmp	dx,ds: word ptr [bx].VESA_MODE_PANEL.Y_RES
	jne	exit_exec_display_start
	mov	ax,(VESA_ID SHL 8h) + VESA_FUNC_DISPLAY_START
	xor	cx,cx
	xor	dx,dx
	push	bx
	mov	bx,80h
	VIDEO_CALL
	pop	bx
	cmp	ax,VESA_ID
	jne	exit_exec_display_start
	or	ds: byte ptr [status_flag_4],VESA_RETRACE
	call	Get_Input_Status_Register
	in	al,dx	
	test	al,8h
	jne	exit_exec_display_start
	or	ds: byte ptr [status_flag_5],VESA_RETRACE_FAIL
exit_exec_display_start:
	popa
	ret
