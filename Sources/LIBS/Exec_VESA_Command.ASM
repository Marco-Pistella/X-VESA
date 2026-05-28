;#############################################################################

	Exec_VESA_Command:

;#############################################################################

	pusha
	call	Save_Current_Video_Page
	call	Clear_Screen
	mov	cx,(((TEXT_WIDTH - COMMANDS_BOX_LEN) SHR 1h) SHL 8h) + ((TEXT_HEIGHT - TOTAL_VESA_COMMANDS - 4h) SHR 1h) - 6
	mov	dx,((((TEXT_WIDTH - COMMANDS_BOX_LEN) SHR 1h) + COMMANDS_BOX_LEN - 1h) SHL 8h) + ((TEXT_HEIGHT - TOTAL_VESA_COMMANDS + 4h) SHR 1h) + TOTAL_VESA_COMMANDS - 7h
	mov	si,OFFSET vga_message_138
	mov	di,OFFSET vga_message_010
	call	Extended_Box
	mov	cx,1Ah
	mov	dx,4F20h
	call	Box
	mov	ch,8h
	mov	si,OFFSET vga_message_011
	call	Write_VGA_Message
	add	cl,4h
	movzx	ax,ds: byte ptr [panel_01].PANEL.RELATIVE_ELEMENT
	add	ax,ds: word ptr [panel_01].PANEL.ABSOLUTE_ELEMENT
	call	Write_Panel_01
	xchg	ax,bx
	imul	bx,SIZEOF VESA_MODE_PANEL
	add	bx,OFFSET vesa_mode_info
	add	cl,2h
	mov	ch,3h
	mov	si,OFFSET vga_message_142
	call	Write_VGA_Message
	mov	si,OFFSET panel_03
	call	Redraw_All_Init
loop_exec_vesa:
	mov	si,OFFSET vga_message_143
	mov	al,ds: byte ptr [status_flag_2]
	and	al,VESA_MEMORY_MODE
	mov	ch,HEADER_LEFT_SPACE + 48d
	call	Write_Index_String
	dec	cx
	mov	ch,HEADER_LEFT_SPACE + 70d
	mov	si,vga_message_189
	test	ds: byte ptr [status_flag_2],EXEC_AVX
	je	avx_on
	mov	si,OFFSET vga_message_190
avx_on:
	call	Write_VGA_Message
	mov	ch,HEADER_LEFT_SPACE + 23d
	test	al,VESA_MEMORY_MODE
	je	write_window_mode
	mov	si,OFFSET vga_message_153
	call	Write_VGA_Message
	jmp	loop_exec_vesa_1
write_window_mode:
	mov	si,OFFSET vga_message_141
	mov	al,ds: byte ptr [status_flag_2]
	and	al,VESA_WINDOW_MODE
	shr	al,2h
	call	Write_Index_String
	dec	cx
loop_exec_vesa_1:
	mov	si,OFFSET panel_03
	call	Select_Item
	cmp	ax,F8_KEY
	jne	test_f9_key_exec
	xor	ds: byte ptr [status_flag_2],EXEC_AVX
	jmp	loop_exec_vesa
test_f9_key_exec:
	cmp	ax,F9_KEY
	jne	test_f1_key_exec
	test	ds: byte ptr [status_flag_2],VESA_MEMORY_MODE
	je	ok_f9_exec
	SOUND_ERROR
	jmp	loop_exec_vesa_1
ok_f9_exec:
	xor	ds: byte ptr [status_flag_2],VESA_WINDOW_MODE
	jmp	loop_exec_vesa
test_f1_key_exec:
	cmp	ax,F1_KEY
	jne	test_enter_key_exec
	push	bx
	mov	bx,OFFSET vga_message_139
	mov	ds: byte ptr [n_line_help],HELP5_LINE + 4h
	call	Show_Help
	pop	bx
	jmp	loop_exec_vesa_1
test_enter_key_exec:
	cmp	ax,ENTER_KEY
	jne	test_vesa_command_f10
	call	Save_Current_Video_Page
	call	Clear_Screen
	movzx	di,ds: byte ptr [si].PANEL.PANEL.RELATIVE_ELEMENT
	add	di,di
	call	ds: word ptr [di + table_vesa_commands]
	call	Restore_Current_Video_Page
	jmp	loop_exec_vesa_1
test_vesa_command_f10:
	cmp	ax,F10_KEY
	jne	test_vesa_command_esc
	xor	ds: byte ptr [status_flag_2],VESA_MEMORY_MODE
	jmp	loop_exec_vesa
test_vesa_command_esc:	
	cmp	ax,ESC_KEY
	jne	loop_exec_vesa_1
	and	ds: byte ptr [status_flag_2],NOT (VESA_MEMORY_MODE OR VESA_WINDOW_MODE OR EXEC_AVX)
	call	Restore_Current_Video_Page
	popa
	ret
