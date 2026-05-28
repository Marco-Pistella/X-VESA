;#############################################################################

	Show_EDID:

;#############################################################################

	pusha
	call	Save_Current_Video_Page
	call	Clear_Screen
	test	ds: byte ptr [status_flag_1],EDID_EXECUTE
	jne	edid_readed
	xor	bp,bp
	mov	si,OFFSET edid_data
loop_read_edid:
	push	si
	mov	ax,bp
	add	al,'0'
	mov	si,OFFSET vga_message_027
	mov	ds: byte ptr [si + 16h],al
	call	View_Instant_Message
	pop	si
	mov	ax,(VESA_ID SHL 8h) + VESAFUNC_READ_EDID
	mov 	bx,REPORT_DDC_CAPABILITIES
	mov	cx,bp
	mov	di,DUMMY_BUFFER_SDD53
	VIDEO_CALL
	cmp	ax,VESA_ID
	je	edid_func0_ok
	cmp	al,VESA_ID
	jne	next_edid_controller
	or	ds: byte ptr [status_flag_1],EDID_SUPPORT_ERROR
	jmp	next_edid_controller
edid_func0_ok:
	or	ds: byte ptr [status_flag_1],EDID_SUPPORT
	mov	ds: word ptr [si].EDID.EDIDController,bp
	mov	ds: word ptr [si].EDID.EDIDFlag,bx	
	mov	ax,(VESA_ID SHL 8h) + VESAFUNC_READ_EDID
	mov	bx,READ_EDID
	mov	cx,bp
	xor	dx,dx
	lea	di,ds: byte ptr [si].EDID.EDIDData
	mov	ds: dword ptr [di],EDID_ID_WRITE
	VIDEO_CALL
	cmp	ax,VESA_ID
	je	valid_read_edid
	cmp	ds: dword ptr [di],EDID_ID_WRITE
	je	next_edid_controller
valid_read_edid:
	mov	al,ds: byte ptr [n_edid_controller]
	or	al,al
	je	valid_edid_controller
	push	si
	mov	si,OFFSET edid_data.EDID.EDIDData
loop_comp_edid:
	mov	cx,EDID_LEN
	repe	cmpsb
	or	cx,cx
	jne	next_controller
	pop	si
	jmp	next_edid_controller
next_controller:
	sub	di,EDID_LEN
	add	di,cx
	add	si,cx
	add	SI,(SIZEOF EDID) - EDID_LEN
	dec	al
	jne	loop_comp_edid
	pop	si
valid_edid_controller:
	add	si,SIZEOF EDID
	inc	ds: byte ptr [n_edid_controller]
next_edid_controller:
	inc	bp
	cmp	bp,MAX_EDID_CONTROLLERS
	jne	loop_read_edid
	or	ds: byte ptr [status_flag_1],EDID_EXECUTE
	call	Clear_Screen
	mov	al,ds: byte ptr [n_edid_controller]
	cmp	al,1h
	jbe	edid_readed
	mov	ah,TEXT_HEIGHT
	sub	ah,al
	shr	ah,1h
	mov	ds: byte ptr [panel_02].PANEL.COORD_START,ah
	dec	ax
	mov	ds: byte ptr [panel_02].PANEL.TOTAL_ELEMENTS,al
	mov	ds: byte ptr [panel_02].PANEL.TOTAL_RELATIVE_ELEMENTS,al
edid_readed:
	mov	al,ds: byte ptr [n_edid_controller]
	or	al,al
	jne	edid_ok
	test	ds: byte ptr [status_flag_1],EDID_SUPPORT
	jne	edid_ok
fail_edid_read:
	mov	si,OFFSET vga_message_029
	test	ds: byte ptr [status_flag_1],EDID_SUPPORT_ERROR
	je	view_alert_edid_no_support
	mov	si,OFFSET vga_message_045
view_alert_edid_no_support:
	call	View_Alert_Message
	jmp	exit_edid
edid_ok:
	cmp	al,1h
	jbe	edid_entry_1_c	
	add	al,4h
	mov	ah,EDID_INVERT_LEN + 4h
	call	Center_Box_Dynamic
	mov	di,OFFSET vga_message_007
	mov	si,OFFSET vga_message_030
	call	Extended_Box
	mov	si,OFFSET panel_02
	call	Redraw_All_Init
loop_key_vc:
	call	Select_Item
	cmp	ax,ENTER_KEY
	jne	test_key_vc_1
	call	Save_Current_Video_Page
	call	Clear_Screen
edid_entry_1_c:
	and	ds: byte ptr [status_flag_1],NOT (INVALID_EDID_HEADER OR INVALID_EDID_CHECKSUM)
	cmp	ds: byte ptr [n_edid_controller],0h
	je	valid_edid
	movzx	ax,ds: byte ptr [panel_02].PANEL.RELATIVE_ELEMENT
	add	ax,ds: word ptr [panel_02].PANEL.ABSOLUTE_ELEMENT
	imul	di,ax,SIZEOF EDID
	add	di,OFFSET edid_data.EDID.EDIDData
	mov	si,OFFSET edid_header
	mov	cx,SIZEOF EDID128.Header
	push	di
	repe	cmpsb
	pop	di
	je	valid_edid_header
	or	ds: byte ptr [status_flag_1],INVALID_EDID_HEADER
valid_edid_header:
	xor	al,al
	mov	cx,SIZEOF EDID128
loop_edid_checksum:
	add	al,ds: byte ptr [di]
	inc	di
	loop	loop_edid_checksum
	or	al,al
	je	valid_edid_checksum
	or	ds: byte ptr [status_flag_1],INVALID_EDID_CHECKSUM
valid_edid_checksum:
	lea	bx,ds: word ptr [di - EDID_LEN]
	test	ds: byte ptr [status_flag_1],INVALID_EDID_HEADER OR INVALID_EDID_CHECKSUM
	je	valid_edid
	push	bx
	mov	bx,OFFSET vga_message_028
	mov	di,OFFSET vga_message_034
	mov	si,OFFSET vga_message_032
	call	Show_Message
	pop	bx
loop_key_fe:
	call	Get_Key
	cmp	ax,T_KEY
	je	entry_valid_edid
test_b_key:
	cmp	ax,B_KEY
	jne	loop_key_fe
	call	Show_Binary_EDID
	jmp	exit_for_binary
entry_valid_edid:
	call	Clear_Screen
valid_edid:
	movzx	ax,ds: byte ptr [panel_02].PANEL.RELATIVE_ELEMENT
	add	ax,ds: word ptr [panel_02].PANEL.ABSOLUTE_ELEMENT
	imul	bx,ax,SIZEOF EDID
	add	bx,OFFSET edid_data.EDID.EDIDData
	xor	cx,cx
	mov	dx,((TEXT_WIDTH - 1) SHL 8) + EDID_WIN1_HEIGHT
	mov	si,OFFSET vga_message_035
	xor	di,di
	call	Extended_Box
	mov	si,OFFSET vga_message_036
	mov	cx,0D02h
	call	Write_VGA_Message
	mov	ds: byte ptr [color_base_mem],EXTRA_COLOR
	mov	al,ds: byte ptr [bx - 4h]
	mov	ch,26h
	mov	ds: word ptr [start_xy],cx
	call	Write_Dec_Num8
	call	Next_Line
	mov	al,ds: byte ptr [bx - 2h]
	mov	dx,104h
	call	Block_Yes_Or_No
	mov	al,ds: byte ptr [bx - 1h]
	call	Write_Dec_Num_Left8
	mov	ds: byte ptr [color_base_mem],COLOR_BASE
	inc	ch
	mov	al,'s'
	call	Write_Char
	mov	ds: byte ptr [current_edid_page],ZERO
loop_draw_page:
	mov	cx,EDID_WIN1_HEIGHT + 2h
	mov	dx,((TEXT_WIDTH - 1h) SHL 8h) + TEXT_HEIGHT - 1h
	mov	di,OFFSET vga_message_010
	movzx	si,ds: byte ptr [current_edid_page]
	shl	si,2h
	push	si
	mov	si,ds: word ptr [si + offset_current_page]
	call	Extended_Box
	mov	cx,((TEXT_WIDTH - 0Eh) SHL 8) + TEXT_HEIGHT - 1h
	mov	si,OFFSET vga_message_039
	call	Write_VGA_Message
	add	ch,7h
	mov	al,ds: byte ptr [current_edid_page]
	add	al,'1'
	call	Write_Char
	pop	si
	cmp	ds: byte ptr [n_edid_controller],0h
	jne	show_page_edid
	mov	cx,40Dh
	mov	si,OFFSET vga_message_046
	call	Write_VGA_Message
	jmp	loop_key_page_edid
show_page_edid:
	call	ds: word ptr [si + offset_current_page + 2h]
loop_key_page_edid:
	call	Get_Key
	cmp	ax,LEFT_KEY
	jne	test_key_e_1
	cmp	ds: byte ptr [current_edid_page],0h
	je	loop_key_page_edid
	dec	ds: byte ptr [current_edid_page]
	jmp	loop_draw_page
test_key_e_1:
	cmp	ax,RIGHT_KEY
	jne	test_key_e_2
	cmp	ds: byte ptr [current_edid_page],N_EDID_PAGE - 1h
	je	loop_key_page_edid
	inc	ds: byte ptr [current_edid_page]
	jmp	loop_draw_page
test_key_e_2:
	cmp	ax,HOME_KEY
	jne	test_key_e_3
	cmp	ds: byte ptr [current_edid_page],0h
	je	loop_key_page_edid
	mov	ds: byte ptr [current_edid_page],0h
	jmp	loop_draw_page
test_key_e_3:
	cmp	ax,END_KEY
	jne	test_key_e_4
	cmp	ds: byte ptr [current_edid_page],N_EDID_PAGE - 1h
	je	loop_key_page_edid
	mov	ds: byte ptr [current_edid_page],N_EDID_PAGE - 1h
	jmp	loop_draw_page
test_key_e_4:
	cmp	ax,F1_KEY
	jne	test_key_e_5
	call	Save_Current_Video_Page
	call	Clear_Screen
	mov	ds: byte ptr [n_line_help],HELP2_LINE + 4h
	push	bx
	mov	bx,OFFSET vga_message_038
	cmp	ds: byte ptr [n_edid_controller],0h
	jne	standard_edid_help
	mov	ds: byte ptr [n_line_help],HELP3_LINE + 4h
	mov	bx,OFFSET vga_message_047
standard_edid_help:
	call	Show_Help
	pop	bx
	call	Restore_Current_Video_Page
	jmp	loop_key_page_edid
test_key_e_5:
	cmp	ax,ESC_KEY
	je	exit_for_binary	
	cmp	ds: byte ptr [n_edid_controller],0h
	je	loop_key_page_edid
	cmp	ax,E_KEY
	jne	test_key_b_1
	call	Get_Extension_Block
	jmp	loop_key_page_edid
test_key_b_1:
	cmp	ax,B_KEY
	jne	test_key_e_6
	call	Save_Current_Video_Page
	call	Show_Binary_EDID
	call	Restore_Current_Video_Page
	jmp	loop_key_page_edid
test_key_e_6:
	cmp	ax,S_KEY
	jne	loop_key_page_edid
	call	Save_EDID_File
	jmp	loop_key_page_edid
exit_for_binary:
	cmp	ds: byte ptr [n_edid_controller],1h
	jbe	exit_edid
	call	Restore_Current_Video_Page
	mov	si,OFFSET panel_02
	jmp	loop_key_vc
test_key_vc_1:
	cmp	ax,ESC_KEY
	jne	loop_key_vc
exit_edid:
	call	Restore_Current_Video_Page
	popa
	ret
