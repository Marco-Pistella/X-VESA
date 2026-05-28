;#############################################################################

;	DS:BX = Pointer to vesa_mode_info video mode

	VESA_Command_03:

;#############################################################################

	pusha
	cmp	ds: byte ptr [bx].VESA_MODE_PANEL.VIDEO_MODE_MODEL,VESA_MODE_PACKET
	je	valid_vesa_command_03
	cmp	ds: byte ptr [bx].VESA_MODE_PANEL.VIDEO_MODE_MODEL,VESA_MODE_DIRECT_COLOR
	je	valid_vesa_command_03
	mov	si,OFFSET vga_message_154
fail_command_03:
	call	View_Alert_Message
	popa
	ret
valid_vesa_command_03:
	call	Retrieve_VRAM_Size
	jc	undetectable_vram_1
	or	ebp,ebp
	jne	view_vram_size_1
	or	ds: byte ptr [status_flag_4],VALID_VESA_ADDRESSING
	call	Open_VESA_Video_Mode
	jnc	valid_vesa_command_03_open
	popa
	ret
valid_vesa_command_03_open:
	call	Get_VESA_VRAM_Size
	call	Init_X_Vesa
	call	Retrieve_VRAM_Size
	jnc	view_vram_size_1
undetectable_vram_1:
	mov	si,OFFSET vga_message_198
	call	View_Alert_Message
	popa
	ret
view_vram_size_1:
	CENTER_BOX 60d,7d
	mov	si,OFFSET vga_message_207
	mov	di,OFFSET vga_message_208
	call	Extended_Box
	add	cx,402h
	mov	ds: word ptr [start_xy],cx
	mov	si,OFFSET vga_message_209
	call	Write_Simple_VGA_Message
	lea	eax,ss: word ptr [ebp - 1h]
	mov	ds: dword ptr [tmp_vram_offset],eax
	mov	di,bx
	mov	bx,OFFSET inputs_02
	mov	si,OFFSET vga_message_211
	call	VESA_Command_03_02
	jc	exit_vesa_command_03
	mov	ds: dword ptr [tmp_vram_offset],eax
	call	Next_Line
	add	ch,2h
	mov	si,OFFSET vga_message_210
	call	Write_Simple_VGA_Message
	xchg	eax,ebp
	sub	eax,ds: dword ptr [tmp_vram_offset]
	mov	ds: dword ptr [tmp_vram_size],eax
	mov	bx,OFFSET inputs_03
	mov	si,OFFSET vga_message_212
	call	VESA_Command_03_02
	jc	exit_vesa_command_03
	mov	ds: dword ptr [tmp_vram_size],eax
	call	Next_Line
	add	ch,0Ch
	mov	si,OFFSET vga_message_216
	call	Write_Simple_VGA_Message
	mov	bx,OFFSET inputs_04
	call	VESA_Command_03_03
	jc	exit_vesa_command_03
	mov	ds: byte ptr [n_pass],al
	mov	ds: byte ptr [tmp_n_pass],al
	call	Clear_Screen
	mov	bx,di
	or	ds: byte ptr [status_flag_4],VALID_VESA_ADDRESSING OR VALID_VESA_IO
	call	Open_VESA_Video_Mode
	jnc	valid_vesa_command_03_open_1
	popa
	ret
valid_vesa_command_03_open_1:
	mov	ds: word ptr [n_vram_errors],0h
	or	ds: byte ptr [status_flag_3],VESA_TRANSPARENCY
	call	Enter_Redirector
	call	Save_Timer_Ticks
exec_next_pass_vesa:
	xor	di,di
	mov	ebp,ds: dword ptr [tmp_vram_size]
	call	Set_Virtual_String
	mov	ds: byte ptr [buffer_vesa_string + VESA_NOMAD_LEN],0h
	mov	ds: word ptr [last_sec_time],0FFFFh
	mov	ds: dword ptr [last_nomad_pos],0FFFFFFFFh
	test	ds: byte ptr [status_flag_2],VESA_MEMORY_MODE
	jne	init_linear_test_3
	mov	esi,ds: dword ptr [tmp_vram_offset]
	shl	esi,10d
	mov	eax,esi
	xor	edx,edx
	div	ds: dword ptr [segment_bound]
	mov	esi,edx
	xchg	ax,dx
	call	ds: word ptr [set_bank_default]
	mov	ds: byte ptr [test_type],BITS_TEST
	mov	ds,ds: word ptr [banked_segment]
loop_test_3b:
	push	bx
	push	dx
	mov	cx,SIZE_VRAM_TEST_1K / SIZEOF DWORD
loop_test_1k_sb:
	mov	bx,OFFSET start_patterns_single
loop_test_vram_sb:
	mov	eax,es: dword ptr [bx]
	mov	ds: dword ptr [si],eax
	mov	edx,ds: dword ptr [si]
	cmp	eax,edx
	je	no_error_vram_sb
	call	VESA_Command_03_Fail_VRAM_b
no_error_vram_sb:
	add	bx,SIZEOF DWORD
	cmp	bx,OFFSET end_patterns_single
	jne	loop_test_vram_sb
	add	si,SIZEOF DWORD
	loop	loop_test_1k_sb
	sub	si,SIZE_VRAM_TEST_1K
	mov	es: byte ptr [test_type],BURST_TEST
	mov	bx,OFFSET start_patterns_multi
loop_test_1k_mb:
	mov	eax,es: dword ptr [bx]
	mov	cx,SIZE_VRAM_TEST_1K / SIZEOF DWORD
loop_set_vram_test_mb:
	mov	ds: dword ptr [si],eax
	add	si,SIZEOF DWORD
	loop	loop_set_vram_test_mb
	push	ax
        in	al,80h
	pop	ax
	sub	si,SIZE_VRAM_TEST_1K
	mov	cx,SIZE_VRAM_TEST_1K / SIZEOF DWORD
loop_get_vram_test_mb:
	mov	edx,ds: dword ptr [si]
	cmp	eax,edx
	je	no_error_vram_mb
	call	VESA_Command_03_Fail_VRAM_b
no_error_vram_mb:
	add	si,SIZEOF DWORD
	loop	loop_get_vram_test_mb
	sub	si,SIZE_VRAM_TEST_1K
	add	bx,SIZEOF DWORD
	cmp	bx,OFFSET end_patterns_multi
	jne	loop_test_1k_mb
	mov	es: byte ptr [test_type],MATRIX_TEST
	mov	cx,SIZE_VRAM_TEST_1K / SIZEOF DWORD
loop_test_1k_bb:
	mov	eax,1h
loop_test_vram_bb:
	mov	ds: dword ptr [si],eax
	mov	edx,ds: dword ptr [si]
	cmp	eax,edx
	je	no_error_vram_bb
	call	VESA_Command_03_Fail_VRAM_b
no_error_vram_bb:
	add	eax,eax
	jne	loop_test_vram_bb
	jc	loop_test_vram_bb
	add	si,SIZEOF DWORD
	loop	loop_test_1k_bb
	pop	dx
	pop	bx	
	push	ds
	push	es
	pop	ds
	cmp	si,ds: word ptr [segment_bound]
	jne	no_set_bank_3
	inc	dx
	call	ds: word ptr [set_bank_default]
	xor	si,si
no_set_bank_3:
	pop	ds
	call	Write_Nomad_Interface
	dec	ebp
	jne	loop_test_3b
	push	es
	pop	ds
	jmp	end_vesa_command_3
init_linear_test_3:
	mov	esi,ds: dword ptr [tmp_vram_offset]
	shl	esi,10d
	add	esi,ds: dword ptr [current_linear_vram_address]
	mov	ds: byte ptr [test_type],BITS_TEST
	xor	ax,ax
	mov	ds,ax
loop_test_3l:
	push	bx
	mov	cx,SIZE_VRAM_TEST_1K / SIZEOF DWORD
loop_test_1k_sl:
	mov	bx,OFFSET start_patterns_single
loop_test_vram_sl:
	mov	eax,es: dword ptr [bx]
	mov	ds: dword ptr [esi],eax
	mov	edx,ds: dword ptr [esi]
	cmp	eax,edx
	je	no_error_vram_sl
	call	VESA_Command_03_Fail_VRAM_l
no_error_vram_sl:
	add	bx,SIZEOF DWORD
	cmp	bx,OFFSET end_patterns_single
	jne	loop_test_vram_sl
	add	esi,SIZEOF DWORD
	loop	loop_test_1k_sl
	sub	esi,SIZE_VRAM_TEST_1K
	mov	es: byte ptr [test_type],BURST_TEST
	mov	bx,OFFSET start_patterns_multi
loop_test_1k_ml:
	mov	eax,es: dword ptr [bx]
	mov	cx,SIZE_VRAM_TEST_1K / SIZEOF DWORD
loop_set_vram_test_ml:
	mov	ds: dword ptr [esi],eax
	add	esi,SIZEOF DWORD
	loop	loop_set_vram_test_ml
	push	ax
        in	al,80h
	pop	ax
	sub	esi,SIZE_VRAM_TEST_1K
	mov	cx,SIZE_VRAM_TEST_1K / SIZEOF DWORD
loop_get_vram_test_ml:
	mov	edx,ds: dword ptr [esi]
	cmp	eax,edx
	je	no_error_vram_ml
	call	VESA_Command_03_Fail_VRAM_l
no_error_vram_ml:
	add	esi,SIZEOF DWORD
	loop	loop_get_vram_test_ml
	sub	esi,SIZE_VRAM_TEST_1K
	add	bx,SIZEOF DWORD
	cmp	bx,OFFSET end_patterns_multi
	jne	loop_test_1k_ml
	mov	es: byte ptr [test_type],MATRIX_TEST
	mov	cx,SIZE_VRAM_TEST_1K / SIZEOF DWORD
loop_test_1k_bl:
	mov	eax,1h
loop_test_vram_bl:
	mov	ds: dword ptr [esi],eax
	mov	edx,ds: dword ptr [esi]
	cmp	eax,edx
	je	no_error_vram_bl
	call	VESA_Command_03_Fail_VRAM_l
no_error_vram_bl:
	add	eax,eax
	jne	loop_test_vram_bl
	jc	loop_test_vram_bl
	add	esi,SIZEOF DWORD
	loop	loop_test_1k_bl
	pop	bx
	call	Write_Nomad_Interface
	dec	ebp
	jne	loop_test_3l
	push	es
	pop	ds
end_vesa_command_3:
	call	Set_Virtual_String
	mov	eax,ds: dword ptr [last_nomad_pos]
	xor	edx,edx
	movzx	ecx,ds: word ptr [current_bpsl]
	div	ecx
	xchg	eax,edx
	mov	cx,ds: word ptr [bx].VESA_MODE_PANEL.X_RES
	sub	cx,VESA_NOMAD_LEN SHL 3h
	shr	cx,1h
	mov	si,OFFSET buffer_vesa_string
	mov	ds: byte ptr [si + VESA_NOMAD_LEN],0h
	call	Write_VESA_String
	dec	ds: byte ptr [n_pass]
	jne	exec_next_pass_vesa
entry_for_break:
	and	ds: byte ptr [status_flag_3],NOT VESA_TRANSPARENCY
	call	Init_X_Vesa
	test	ds: byte ptr [status_flag_3],BREAK_FLAG
	je	no_break_user
	mov	si,OFFSET vga_message_239
	call	View_Alert_Message
	and	ds: byte ptr [status_flag_3],NOT BREAK_FLAG
	jmp	exit_vesa_command_03
no_break_user:
	test	ds: byte ptr [status_flag_3],TOO_VRAM_ERROR
	je	no_too_error
	push	bx
	mov	bx,OFFSET vga_message_028
	mov	si,OFFSET vga_message_234
	mov	di,OFFSET vga_message_238
	call	Show_Message
	pop	bx
loop_key_09:
	call	Get_Key
	cmp	ax,ENTER_KEY
	jne	loop_key_09
	call	Clear_Screen
no_too_error:
	mov	cx,3h
	mov	dx,((TEXT_WIDTH - 1) SHL 8) + MAIN_WIN1_HEIGHT + 3h
	mov	si,OFFSET vga_message_009
	xor	di,di
	call	Extended_Box
	call	Draw_Adapter_Info
	mov	cx,911h
	mov	dx,451Ch
	mov	si,OFFSET vga_message_220
	mov	di,OFFSET vga_message_146
	cmp	ds: word ptr [n_vram_errors],0h
	je	no_view_errors
	mov	di,OFFSET vga_message_221
no_view_errors:
	call	Extended_Box
	add	cx,0A02h
	mov	si,OFFSET vga_message_219
	call	Write_VGA_Message
	add	ch,0Ch
	mov	ds: word ptr [start_xy],cx
	mov	ds: byte ptr [color_base_mem],EXTRA_COLOR
	call	VESA_Command_02_01
	call	Next_Line
	xor	al,al
	test	ds: byte ptr [status_flag_2],VESA_MEMORY_MODE
	jne	write_memory_model_04
	inc	ax
	test	ds: byte ptr [status_flag_2],VESA_WINDOW_MODE
	je	write_memory_model_04
	inc	ax
write_memory_model_04:
	mov	si,OFFSET vga_message_177
	call	Write_Index_String
	mov	eax,ds: dword ptr [tmp_vram_offset]
	call	Write_Dec_Num_Left32
	inc	ch
	mov	si,OFFSET vga_message_013
	call	Write_Simple_VGA_Message
	call	Next_Line
	mov	eax,ds: dword ptr [tmp_vram_size]
	call	Write_Dec_Num_Left32
	inc	ch
	mov	si,OFFSET vga_message_013
	call	Write_Simple_VGA_Message
	call	Next_Line
	mov	al,ds: byte ptr [tmp_n_pass]
	call	Write_Dec_Num_Left8
	call	Next_Line
	mov	ax,ds: word ptr [n_vram_errors]
	or	ax,ax
	je	no_error_color
	mov	ds: byte ptr [color_base_mem],ND_COLOR
no_error_color:
	call	Write_Dec_Num_Left16
	call	Next_Line
	mov	ds: byte ptr [color_base_mem],EXTRA_COLOR
	call	VESA_Command_03_13
	call	Next_Line
	call	VESA_Command_03_14
	mov	ds: byte ptr [color_base_mem],COLOR_BASE
loop_key_command_04:
	call	Get_Key
	cmp	ax,F10_KEY
	jne	test_key_command_03_esc
	cmp	ds: byte ptr [n_vram_errors],0h
	je	loop_key_command_04
	call	Save_Current_Video_Page
	call	Clear_Screen
	xor	cx,cx
	mov	dx,((TEXT_WIDTH - 1) SHL 8) + MAIN_WIN1_HEIGHT
	mov	si,OFFSET vga_message_222
	xor	di,di
	call	Extended_Box
	call	Draw_Adapter_Info
	mov	cx,MAIN_WIN1_HEIGHT + 2h
	mov	dx,((TEXT_WIDTH - 1h) SHL 8h) + TEXT_HEIGHT - 1h
	xor	si,si
	mov	di,OFFSET vga_message_223
	call	Extended_Box
	mov	ch,8h
	mov	si,OFFSET vga_message_235
	call	Write_VGA_Message
	mov	cx,20Ah
	mov	si,OFFSET vga_message_224
	call	Write_Simple_VGA_Message
	mov	ax,ds: word ptr [n_vram_errors]
	dec	ax
	mov	si,OFFSET panel_04
	mov	ds: word ptr [si].PANEL.TOTAL_ELEMENTS,ax
	call	Redraw_All_Init
loop_key_command_04_1:
	call	Select_Item
	cmp	ax,S_KEY
	jne	test_esc_command_4
	mov	di,OFFSET dos_create_file
	mov	ds: word ptr [di].CREATE_FILE.OFFSET_INSTANT_MESSAGE,OFFSET vga_Message_225
	mov	ds: word ptr [di].CREATE_FILE.OFFSET_NAME_DECIMAL,OFFSET vga_message_226 + 1Ah
	mov	ds: word ptr [di].CREATE_FILE.OFFSET_FILE_NAME,OFFSET vga_message_226 + 16h
	mov	ds: word ptr [di].CREATE_FILE.OFFSET_FAIL_MESSAGE,OFFSET vga_message_227
	mov	ds: word ptr [di].CREATE_FILE.OFFSET_CLOSE_MESSAGE,OFFSET vga_message_226
	mov	ds: word ptr [di].CREATE_FILE.OFFSET_BUFFER_IO,BUFFER_IO
	mov	ds: word ptr [di].CREATE_FILE.SEGMENT_BUFFER_IO,ds
	add	ds: word ptr [di].CREATE_FILE.SEGMENT_BUFFER_IO,SEGMENT_4
	call	Create_Unique_File
	jc	fail_log_file_save
	mov	ds: word ptr [di].CREATE_FILE.OFFSET_BUFFER_SOURCE,OFFSET buffer_vesa_string
	mov	ds: word ptr [di].CREATE_FILE.SEGMENT_BUFFER_SOURCE,ds
	call	Enter_Redirector
	xor	cx,cx
	mov	bp,OFFSET VESA_Command_03_05
	call	VESA_Command_03_04
	call	VESA_Command_New_Line
	jc	fail_log_file_save
	mov	bp,OFFSET VESA_Command_03_06
	call	VESA_Command_03_04
	mov	bp,OFFSET VESA_Command_03_07
	call	VESA_Command_03_04
	mov	bp,OFFSET VESA_Command_03_08
	call	VESA_Command_03_04
	mov	bp,OFFSET VESA_Command_03_09
	call	VESA_Command_03_04
	mov	bp,OFFSET VESA_Command_03_10
	call	VESA_Command_03_04
	mov	bp,OFFSET VESA_Command_03_11
	call	VESA_Command_03_04
	mov	bp,OFFSET VESA_Command_03_15
	call	VESA_Command_03_04
	mov	bp,OFFSET VESA_Command_03_16
	call	VESA_Command_03_04
	call	VESA_Command_New_Line
	jc	fail_log_file_save
	mov	bp,OFFSET VESA_Command_03_12
	call	VESA_Command_03_04
	call	VESA_Command_New_Line
	jc	fail_log_file_save
	xor	ch,ch
	xor	ax,ax
loop_write_to_file_errors:
	push	ax
	mov	bp,OFFSET Write_Panel_04
	call	VESA_Command_03_04
	pop	ax
	inc	ax
	cmp	ax,ds: word ptr [n_vram_errors]
	jb	loop_write_to_file_errors
	call	Flush_IO
	jc	fail_log_file_save
	call	Close_File
fail_log_file_save:
	call	Exit_Redirector
	jmp	loop_key_command_04_1
test_esc_command_4:
	cmp	ax,ESC_KEY
	jne	loop_key_command_04_1
	call	Restore_Current_Video_Page
	jmp	loop_key_command_04
test_key_command_03_esc:
	cmp	ax,ESC_KEY
	jne	loop_key_command_04
exit_vesa_command_03:
	popa
	ret

;#############################################################################

	Write_Nomad_Interface:

;#############################################################################

	push	ds
	push	dx
	push	di
	push	esi
	mov	ax,BIOS_SAVE_AREA_SEGMENT
	mov	ds,ax
	mov	ax,ds: word ptr [KEYBOARD_BUFFER_HEAD]
	cmp	ax,ds: word ptr [KEYBOARD_BUFFER_TAIL]
	je	no_key_pressed
	mov	ah,KEY_FUNC_GET
	int	KEY_INTERRUPT
	cmp	ax,ESC_KEY
	jne	no_key_pressed
	pop	esi
	pop	di
	pop	dx
	pop	ds
	push	es
	pop	ds
	add	sp,2h
	or	ds: byte ptr [status_flag_3],BREAK_FLAG
	jmp	entry_for_break
no_key_pressed:
	push	es
	pop	ds
	xor	eax,eax
	cmp	ds: dword ptr [last_nomad_pos],eax
	je	zero_interface_pos
	movzx	edi,ds: word ptr [current_bpsl]
	imul	edi,VIDEO_FONT_HEIGHT
	test	ds: byte ptr [status_flag_2],VESA_MEMORY_MODE
	jne	nomad_linear
	movzx	edx,dx
	imul	edx,ds: dword ptr [segment_bound]
	movzx	ecx,si
	add	ecx,edx
	jmp	check_nomad_pos
nomad_linear:
	mov	ecx,esi
	sub	ecx,ds: dword ptr [current_linear_vram_address]
check_nomad_pos:
	cmp	edi,ecx
	jbe	valid_zero_pos
	xchg	eax,edi
	add	eax,1023d
	and	eax,0FFFFFC00h
valid_zero_pos:
	cmp	ds: dword ptr [last_nomad_pos],0FFFFFFFFh
	mov	ds: dword ptr [last_nomad_pos],eax
	je	zero_interface_pos
	or	eax,eax
	jne	zero_interface_pos
	xchg	eax,edi
	xor	edx,edx
	movzx	ecx,ds: word ptr [current_bpsl]
	div	ecx
	xchg	eax,edx
	mov	cx,ds: word ptr [bx].VESA_MODE_PANEL.X_RES
	sub	cx,VESA_NOMAD_LEN SHL 3h
	shr	cx,1h
	mov	si,OFFSET buffer_vesa_string
	mov	ds: byte ptr [si + VESA_NOMAD_LEN],0h
	call	Write_VESA_String
	mov	ds: byte ptr [si + VESA_NOMAD_LEN],20h
	mov	ds: word ptr [last_sec_time],0FFFFh
zero_interface_pos:
	call	Get_BIOS_Ticks
	sub	eax,ds: dword ptr [timer_ticks]
	mov	edi,eax
	mov	ecx,90112d
	mul	ecx
	mov	ecx,1640625d
	div	ecx
	cmp	ax,ds: word ptr [last_sec_time]
	je	no_write_nomad_interface
	mov	ds: word ptr [last_sec_time],ax
	xor	cx,cx
	call	Write_Timer
	mov	ch,9h
	or	edi,edi
	jne	calc_timer_end
invalid_time_next:
	mov	si,OFFSET vga_message_218
	call	Write_Simple_VGA_Message
	jmp	next_info_string_vesa
calc_timer_end:
	mov	esi,ds: dword ptr [tmp_vram_size]
	movzx	eax,ds: byte ptr [tmp_n_pass]
	imul	esi,eax
	sub	al,ds: byte ptr [n_pass]
	imul	eax,ds: dword ptr [tmp_vram_size]
	mov	edx,ds: dword ptr [tmp_vram_size]
	sub	edx,ebp
	inc	edx
	add	edx,eax
	xchg	eax,esi
	mov	esi,edx
	xor	edx,edx
	push	eax
	push	esi
	mul	edi
	div	esi
	mov	esi,90112d
	mul	esi
	mov	esi,1640625d
	div	esi
	cmp	eax,359999d
	ja	invalid_time_next
	call	Write_Timer
	pop	eax
	pop	esi
	xor	edx,edx
	mov	edi,10000d
	mul	edi
	div	esi
	mov	ch,31d
	mov	ds: byte ptr [decimal_digits],2h
	call	Write_Decimal_Number32
	inc	ch
	mov	al,'%'
	call	write_Char
	mov	al,'-'
	call	write_Char
next_info_string_vesa:
	mov	eax,ds: dword ptr [tmp_vram_size]
	sub	eax,ebp
	inc	eax
	shl	eax,10d
	mov	ch,18d
	call	Num_To_Str_Hex8
	mov	ch,26d
	mov	al,'-'
	call	Write_Char
	mov	al,ds: byte ptr [tmp_n_pass]
	sub	al,ds: byte ptr [n_pass]
	inc	ax
	mov	ch,35d
	call	Write_Dec_Num8
	mov	eax,ds: dword ptr [last_nomad_pos]
	xor	edx,edx
	movzx	ecx,ds: word ptr [current_bpsl]
	div	ecx
	xchg	eax,edx
	mov	cx,ds: word ptr [bx].VESA_MODE_PANEL.X_RES
	sub	cx,VESA_NOMAD_LEN SHL 3h
	shr	cx,1h
	mov	si,OFFSET buffer_vesa_string
	call	Get_Virtual_String
	call	Write_VESA_String
	call	Set_Virtual_String
no_write_nomad_interface:
	pop	esi
	pop	di
	pop	dx
	test	ds: byte ptr [status_flag_2],VESA_MEMORY_MODE
	jne	no_set_bank_nomad
	cmp	dx,ds: word ptr [current_bank]
	je	no_set_bank_nomad
	call	ds: word ptr [set_bank_default]
no_set_bank_nomad:
	pop	ds
	ret

;#############################################################################

	VESA_Command_03_01:

;#############################################################################

	push	dx
	or	ds: byte ptr [status_flag_0],FLAG_THOUSANDS
	call	Size_Of_Number32
	mov	dl,ds: byte ptr [number_count]
	add	ch,dl
	add	ch,2h
	mov	ds: byte ptr [bx].INPUTS.LEN,dl
	and	ds: byte ptr [status_flag_0],NOT FLAG_THOUSANDS
	pop	dx
	ret

;#############################################################################

	VESA_Command_03_02:

;#############################################################################

	call	VESA_Command_03_01
	call	Write_Simple_VGA_Message
	call	Write_Dec_Num_Left32
	mov	al,')'
	call	Write_Char
	inc	ch
	mov	si,OFFSET vga_message_013
	call	Write_Simple_VGA_Message
	call	VESA_Command_03_03
	ret

;#############################################################################

	VESA_Command_03_03:

;#############################################################################

	mov	si,bx
	mov	ds: byte ptr [input_buffer],0h
	call	Choice
	cmp	ds: word ptr [si].INPUTS.KEY,ESC_KEY
	je	exit_vesa_command_03_02
	mov	si,OFFSET input_buffer
	call	Asci_To_Num
	clc
	ret
exit_vesa_command_03_02:
	stc
	ret

;#############################################################################

	VESA_Command_03_Fail_VRAM_b:

;#############################################################################

	cmp	di,MAX_VRAM_ERROR * SIZEOF ERROR_VESA
	jne	add_error_b
	push	es
	pop	ds
	or	ds: byte ptr [status_flag_3],TOO_VRAM_ERROR
	add	sp,2h
	pop	dx
	pop	bx
	jmp	end_vesa_command_3
add_error_b:
	push	eax
	push	edx
	push	esi
	inc	es: word ptr [n_vram_errors]
	mov	ss: dword ptr [di].ERROR_VESA.WRITE_VALUE,eax
	mov	ss: dword ptr [di].ERROR_VESA.READ_VALUE,edx
	movzx	edx,es: word ptr [current_bank]
	imul	edx,es: dword ptr [segment_bound]
	movzx	esi,si
	add	edx,esi
	mov	ss: dword ptr [di].ERROR_VESA.OFFSET_VRAM,edx
	call	Get_BIOS_Ticks
	sub	eax,es: dword ptr [timer_ticks]
	mov	ss: dword ptr [di].ERROR_VESA.TICKS,eax
	mov	al,es: byte ptr [n_pass]
	mov	ss: byte ptr [di].ERROR_VESA.PASS,al
	mov	al,es: byte ptr [test_type]
	mov	ss: byte ptr [di].ERROR_VESA.TEST_ID,al
	add	di,SIZEOF ERROR_VESA
	pop	esi
	pop	edx
	pop	eax
	ret

;#############################################################################

	VESA_Command_03_Fail_VRAM_l:

;#############################################################################

	cmp	di,MAX_VRAM_ERROR * SIZEOF ERROR_VESA
	jne	add_error_l
	push	es
	pop	ds
	or	ds: byte ptr [status_flag_3],TOO_VRAM_ERROR
	add	sp,2h
	pop	bx
	jmp	end_vesa_command_3
add_error_l:
	push	eax
	push	esi
	inc	es: word ptr [n_vram_errors]
	sub	esi,es: dword ptr [current_linear_vram_address]
	mov	ss: dword ptr [di].ERROR_VESA.OFFSET_VRAM,esi
	mov	ss: dword ptr [di].ERROR_VESA.WRITE_VALUE,eax
	mov	ss: dword ptr [di].ERROR_VESA.READ_VALUE,edx
	call	Get_BIOS_Ticks
	sub	eax,es: dword ptr [timer_ticks]
	mov	ss: dword ptr [di].ERROR_VESA.TICKS,eax
	mov	al,es: byte ptr [n_pass]
	mov	ss: byte ptr [di].ERROR_VESA.PASS,al
	mov	al,es: byte ptr [test_type]
	mov	ss: byte ptr [di].ERROR_VESA.TEST_ID,al
	add	di,SIZEOF ERROR_VESA
	pop	esi
	pop	eax
	ret

;#############################################################################

	VESA_Command_03_04:

;#############################################################################

	call	Set_Virtual_String
	call	bp
	call	Get_Virtual_String
	mov	si,OFFSET buffer_vesa_string
	call	Str_Len
	mov	ds: word ptr [di].CREATE_FILE.DATA_LEN,ax
	call	Push_IO
	jc	error_VESA_Command_03_04
	call	VESA_Command_New_Line
	jc	error_VESA_Command_03_04
	ret
error_VESA_Command_03_04:
	add	sp,2h
	jmp	fail_log_file_save

;#############################################################################

	VESA_Command_03_05:

;#############################################################################

	mov	ch,4h
	mov	si,OFFSET vga_message_220
	call	Write_Simple_VGA_Message
	ret

;#############################################################################

	VESA_Command_03_06:

;#############################################################################

	mov	ch,0Ah
	movzx	bx,ds: byte ptr [panel_01].PANEL.RELATIVE_ELEMENT
	add	bx,ds: word ptr [panel_01].PANEL.ABSOLUTE_ELEMENT
	imul	bx,SIZEOF VESA_MODE_PANEL
	add	bx,OFFSET vesa_mode_info
	mov	si,OFFSET vga_message_228
	call	Write_Simple_VGA_Message
	inc	ch
	call	VESA_Command_02_01
	ret

;#############################################################################

	VESA_Command_03_07:

;#############################################################################

	mov	ch,8h
	mov	si,OFFSET vga_message_229
	call	Write_Simple_VGA_Message
	inc	ch
	mov	si,OFFSET vga_message_177
	test	ds: byte ptr [status_flag_2],VESA_MEMORY_MODE
	jne	write_memory_model_04_1
	mov	si,OFFSET vga_message_177a
	test	ds: byte ptr [status_flag_2],VESA_WINDOW_MODE
	je	write_memory_model_04_1
	mov	si,OFFSET vga_message_177b
write_memory_model_04_1:
	call	Write_Simple_VGA_Message
	ret

;#############################################################################

	VESA_Command_03_08:

;#############################################################################

	mov	ch,4h
	mov	si,OFFSET vga_message_230
	call	Write_Simple_VGA_Message
	inc	ch
	mov	eax,ds: dword ptr [tmp_vram_offset]
	call	Write_Dec_Num_Left32
	inc	ch
	mov	si,OFFSET vga_message_013
	call	Write_Simple_VGA_Message
	ret

;#############################################################################

	VESA_Command_03_09:

;#############################################################################

	mov	ch,6h
	mov	si,OFFSET vga_message_231
	call	Write_Simple_VGA_Message
	inc	ch
	mov	eax,ds: dword ptr [tmp_vram_size]
	call	Write_Dec_Num_Left32
	inc	ch
	mov	si,OFFSET vga_message_013
	call	Write_Simple_VGA_Message
	ret

;#############################################################################

	VESA_Command_03_10:

;#############################################################################

	mov	ch,0Bh
	mov	si,OFFSET vga_message_232
	call	Write_Simple_VGA_Message
	inc	ch
	mov	al,ds: byte ptr [tmp_n_pass]
	call	Write_Dec_Num_Left8
	ret
	
;#############################################################################

	VESA_Command_03_11:

;#############################################################################

	mov	ch,9h
	mov	si,OFFSET vga_message_233
	call	Write_Simple_VGA_Message
	inc	ch
	mov	ax,ds: word ptr [n_vram_errors]
	call	Write_Dec_Num_Left16
	ret

;#############################################################################

	VESA_Command_03_12:

;#############################################################################

	mov	cx,400h
	mov	si,OFFSET vga_message_224
	call	Write_Simple_VGA_Message
	ret

;#############################################################################

	VESA_Command_03_13:

;#############################################################################

	pusha
	push	cx
	mov	ah,DOS_FUNC_GET_DATE
	int	DOS_INTERRUPT
	mov	ax,ds: word ptr [dos_country_info_buffer + DOS_OFFSET_ciDateFormat]
	cmp	ax,2h
	je	date_japan
	cmp	ax,1h
	je	date_europe
	movzx	ax,dh
	movzx	di,dl
	mov	bp,cx
	jmp	write_date
date_japan:
	mov	ax,cx
	movzx	di,dh
	movzx	bp,dl
	jmp	write_date
date_europe:
	movzx	ax,dl
	movzx	di,dh
	mov	bp,cx
write_date:
	or	ds: byte ptr [status_flag_0],FLAG_THOUSANDS
	pop	cx
	call	Write_Dec_Num_Left16
	mov	al,ds: byte ptr [dos_country_info_buffer + DOS_OFFSET_ciDateSep]
	call	Write_Char
	mov	ax,di
	call	Write_Dec_Num_Left16
	mov	al,ds: byte ptr [dos_country_info_buffer + DOS_OFFSET_ciDateSep]
	call	Write_Char
	mov	ax,bp
	call	Write_Dec_Num_Left16
	and	ds: byte ptr [status_flag_0],NOT FLAG_THOUSANDS
	popa
	ret

;#############################################################################

	VESA_Command_03_14:

;#############################################################################

	pusha
	push	cx
	mov	ah,DOS_FUNC_GET_TIME
	int	DOS_INTERRUPT
	mov	bx,cx
	pop	cx
	mov	al,bh
	cmp	ds: byte ptr [dos_country_info_buffer + DOS_OFFSET_ciTimeFormat],1h
	je	valid_24h
	cmp	al,13d
	jb	valid_24h
	sub	al,12d
valid_24h:
	cmp	al,10d
	jae	ok_h
	push	ax
	mov	al,'0'
	call	Write_Char
	pop	ax
ok_h:
	call	Write_Dec_Num_Left8
	mov	al,ds: byte ptr [dos_country_info_buffer + DOS_OFFSET_ciTimeSep]
	call	Write_Char
	mov	al,bl
	cmp	al,10d
	jae	ok_m
	push	ax
	mov	al,'0'
	call	Write_Char
	pop	ax
ok_m:
	call	Write_Dec_Num_Left8
	mov	al,ds: byte ptr [dos_country_info_buffer + DOS_OFFSET_ciTimeSep]
	call	Write_Char
	mov	al,dh
	cmp	al,10d
	jae	ok_s
	push	ax
	mov	al,'0'
	call	Write_Char
	pop	ax
ok_s:
	call	Write_Dec_Num_Left8
	cmp	ds: byte ptr [dos_country_info_buffer + DOS_OFFSET_ciTimeFormat],1h
	je	valid_24h_1
	mov	si,OFFSET vga_message_236
	cmp	bh,13d
	jb	write_12time
	mov	si,OFFSET vga_message_237
write_12time:
	call	Write_Simple_VGA_Message
valid_24h_1:
	popa
	ret

;#############################################################################

	VESA_Command_03_15:

;#############################################################################

	mov	ch,10h
	mov	si,OFFSET vga_message_242
	call	Write_Simple_VGA_Message
	inc	ch
	call	VESA_Command_03_13
	ret

;#############################################################################

	VESA_Command_03_16:

;#############################################################################

	mov	ch,10h
	mov	si,OFFSET vga_message_243
	call	Write_Simple_VGA_Message
	inc	ch
	call	VESA_Command_03_14
	ret

;#############################################################################

	VESA_Command_New_Line:

;#############################################################################

	mov	ds: word ptr [buffer_vesa_string],0A0Dh
	mov	ds: word ptr [di].CREATE_FILE.DATA_LEN,2h
	call	Push_IO
	ret
