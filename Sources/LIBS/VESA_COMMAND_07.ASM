;#############################################################################

;	DS:BX = Pointer to vesa_mode_info video mode

	VESA_Command_07:

;#############################################################################

	pusha
	cmp	ds: byte ptr [bx].VESA_MODE_PANEL.VIDEO_MODE_MODEL,VESA_MODE_PLANAR
	je	valid_vesa_command_07
	cmp	ds: byte ptr [bx].VESA_MODE_PANEL.VIDEO_MODE_MODEL,VESA_MODE_PACKET
	je	valid_vesa_command_07
	cmp	ds: byte ptr [bx].VESA_MODE_PANEL.VIDEO_MODE_MODEL,VESA_MODE_DIRECT_COLOR
	je	valid_vesa_command_07
	mov	si,OFFSET vga_message_201
	call	View_Alert_Message
exit_command_7:
	popa
	ret
valid_vesa_command_07:
	and	ds: byte ptr [status_flag_6],NOT DISPLAY_START_FAIL
	CENTER_BOX 36d,8d
	mov	si,OFFSET vga_message_307
	mov	di,OFFSET vga_message_306
	call	Extended_Box
	mov	si,OFFSET panel_07
	call	Redraw_All_Init
command_7_key_1:
	call	Select_Item
	cmp	ax,ESC_KEY
	je	exit_command_7	
	cmp	ax,ENTER_KEY
	jne	command_7_key_1
	mov	ax,ds: word ptr [bx].VESA_MODE_PANEL.X_RES
	mov	ds: word ptr [min_virtual_hor],ax
	mov	ax,ds: word ptr [bx].VESA_MODE_PANEL.Y_RES
	mov	ds: word ptr [min_virtual_ver],ax
	mov	al,ds: byte ptr [si].PANEL.RELATIVE_ELEMENT
	mov	ds: word ptr [max_virtual_hor],LEGACY_VIRTUAL_HOR
	mov	ds: word ptr [max_virtual_ver],LEGACY_VIRTUAL_VER
	or	al,al
	je	continue_command_7
	mov	ds: word ptr [max_virtual_hor],STANDARD_VIRTUAL_HOR
	mov	ds: word ptr [max_virtual_ver],STANDARD_VIRTUAL_VER
	cmp	al,1h
	je	continue_command_7
	mov	ds: word ptr [max_virtual_hor],INSANE_VIRTUAL_HOR
	mov	ds: word ptr [max_virtual_ver],INSANE_VIRTUAL_VER
	cmp	al,2h
	je	continue_command_7
	CENTER_BOX 60d,8d
	mov	si,OFFSET vga_message_308
	mov	di,OFFSET vga_message_306
	call	Extended_Box
	or	ds: byte ptr [status_flag_0],FLAG_THOUSANDS
	mov	cx,0E12h
	mov	si,OFFSET vga_message_309
	call	Write_Simple_VGA_Message
	add	ch,7h
	mov	al,'('
	call	Write_Char
	mov	ax,ds: word ptr [bx].VESA_MODE_PANEL.X_RES
	call	Write_Dec_Num_Left16
	mov	si,OFFSET vga_message_313
	call	Write_Simple_VGA_Message
	mov	si,OFFSET inputs_06
	mov	ds: byte ptr [si].INPUTS.LEN,5d
	mov	ds: byte ptr [input_buffer],0h
	call	Choice
	cmp	ds: word ptr [si].INPUTS.KEY,ESC_KEY
	je	exit_command_7
	mov	si,OFFSET input_buffer
	call	Asci_To_Num
	mov	ds: word ptr [min_virtual_hor],ax
	mov	cx,1013h
	mov	si,OFFSET vga_message_310
	call	Write_Simple_VGA_Message
	add	ch,7d
	mov	al,'('
	call	Write_Char
	mov	ax,ds: word ptr [min_virtual_hor]
	call	Write_Dec_Num_Left16
	mov	si,OFFSET vga_message_313
	call	Write_Simple_VGA_Message
	mov	si,OFFSET inputs_07
	mov	ds: byte ptr [si].INPUTS.LEN,5d
	mov	ds: byte ptr [input_buffer],0h
	call	Choice
	cmp	ds: word ptr [si].INPUTS.KEY,ESC_KEY
	je	exit_command_7
	mov	si,OFFSET input_buffer
	call	Asci_To_Num
	mov	ds: word ptr [max_virtual_hor],ax
	mov	cx,1014h
	mov	si,OFFSET vga_message_311
	call	Write_Simple_VGA_Message
	add	ch,7h
	mov	al,'('
	call	Write_Char
	mov	ax,ds: word ptr [bx].VESA_MODE_PANEL.Y_RES
	call	Write_Dec_Num_Left16
	mov	si,OFFSET vga_message_313
	call	Write_Simple_VGA_Message
	mov	si,OFFSET inputs_08
	mov	ds: byte ptr [si].INPUTS.LEN,5d
	mov	ds: byte ptr [input_buffer],0h
	call	Choice
	cmp	ds: word ptr [si].INPUTS.KEY,ESC_KEY
	je	exit_command_7
	mov	si,OFFSET input_buffer
	call	Asci_To_Num
	mov	ds: word ptr [min_virtual_ver],ax
	mov	cx,1215h
	mov	si,OFFSET vga_message_312
	call	Write_Simple_VGA_Message
	add	ch,7d
	mov	al,'('
	call	Write_Char
	mov	ax,ds: word ptr [min_virtual_ver]
	call	Write_Dec_Num_Left16
	mov	si,OFFSET vga_message_313
	call	Write_Simple_VGA_Message
	mov	si,OFFSET inputs_09
	mov	ds: byte ptr [si].INPUTS.LEN,5d
	mov	ds: byte ptr [input_buffer],0h
	call	Choice
	cmp	ds: word ptr [si].INPUTS.KEY,ESC_KEY
	je	exit_command_7
	mov	si,OFFSET input_buffer
	call	Asci_To_Num
	mov	ds: word ptr [max_virtual_ver],ax
	and	ds: byte ptr [status_flag_0],NOT FLAG_THOUSANDS
continue_command_7:
	call	Clear_Screen
	cmp	ds: word ptr [max_virtual_hor],STANDARD_VIRTUAL_HOR
	ja	alert_message_command_7
	cmp	ds: word ptr [max_virtual_ver],STANDARD_VIRTUAL_VER
	jbe	no_hangs_command_7_limits
alert_message_command_7:
	pusha
	mov	bx,OFFSET vga_message_028
	mov	di,OFFSET vga_message_160
	mov	si,OFFSET vga_message_298
	call	Show_Message
	popa
loop_key_command_7_5:
	call	Get_Key
	cmp	ax,N_KEY
	je	exit_command_7
	cmp	ax,Y_KEY
	jne	loop_key_command_7_5
	call	Clear_Screen
no_hangs_command_7_limits:
	call	Save_Timer_Ticks
	or	ds: byte ptr [status_flag_4],VALID_VESA_ADDRESSING OR VALID_VESA_IO
	call	Open_VESA_Video_Mode
	jnc	valid_vesa_command_07_open
	popa
	ret
valid_vesa_command_07_open:
	mov	ax,(VESA_ID SHL 8h) + VESA_FUNC_DISPLAY_START
	mov	dx,1h
	xor	cx,cx
	push	bx
	xor	bx,bx
	VIDEO_CALL
	pop	bx
	cmp	al,VESA_ID
	jne	fail_command_7
	or	ds: byte ptr [status_flag_6],DISPLAY_START_FAIL
	or	ah,ah
	jne	fail_command_7
	mov	ax,(VESA_ID SHL 8h) + VESA_FUNC_DISPLAY_START
	push	bx
	mov	bx,1h
	VIDEO_CALL
	pop	bx
	cmp	ax,VESA_ID
	jne	fail_command_7
	or	cx,cx
	jne	fail_command_7
	cmp	dx,1h
	jne	fail_command_7
	mov	ax,(VESA_ID SHL 8h) + VESA_FUNC_DISPLAY_START
	xor	cx,cx
	xor	dx,dx
	push	bx
	xor	bx,bx
	VIDEO_CALL
	pop	bx
	cmp	ax,VESA_ID
	je	ok_command_7
fail_command_7:
	call	Init_X_VESA
	mov	si,OFFSET vga_message_281
	test	ds: byte ptr [status_flag_6],DISPLAY_START_FAIL
	je	ds_ns_1
	mov	si,OFFSET vga_message_281a
ds_ns_1:
	call	View_Alert_Message
	popa
	ret
ok_command_7:
	call	Retrieve_VRAM_Size
	jc	undetectable_vram_3
	or	ebp,ebp
	jne	view_vram_size_3
	call	Get_VESA_VRAM_Size
	call	Retrieve_VRAM_Size
	jnc	view_vram_size_3
undetectable_vram_3:
	call	Init_X_VESA
	mov	si,OFFSET vga_message_198
	call	View_Alert_Message
	popa
	ret
view_vram_size_3:
	or	ds: byte ptr [status_flag_2],SCANLINE_FORM
	shl	ebp,0Ah
	mov	si,ds: word ptr [min_virtual_hor]
	mov	ds: word ptr [n_scanline],0h
loop_virtual_scanline:
	mov	ax,si
	call	Set_VESA_Scanline
	jc	next_scanline_test
	pusha
	push	ax
	mov	ax,(VESA_ID SHL 8h) + VESA_FUNC_SET_SCAN_LINE
	mov	bx,1h
	VIDEO_CALL
	cmp	ax,VESA_ID
	pop	ax
	jne	fail_get_scanline_info
	cmp	ax,cx
fail_get_scanline_info:
	popa
	jne	next_scanline_test
	cmp	ax,ds: word ptr [max_virtual_hor]
	ja	end_scanline_test
	movzx	ecx,ds: word ptr [min_virtual_ver]
	movzx	dx,ds: byte ptr [bx].VESA_MODE_PANEL.MEMORY_BPP
	cmp	ds: byte ptr [bx].VESA_MODE_PANEL.VIDEO_MODE_MODEL,VESA_MODE_PLANAR
	jne	valid_vram_size_7
	shl	dx,2h
valid_vram_size_7:
	push	ax
	mul	dx
	push	dx
	push	ax
	pop	eax
	add	eax,7d
	shr	eax,3h
	mul	ecx
	cmp	eax,ebp
	pop	ax
	ja	end_scanline_test
	mov	di,ds: word ptr [n_scanline]
	shl	di,2h
	or	di,di
	je	add_scanline
	cmp	ax,ss: word ptr [di - 4h]
	jbe	next_scanline_test
add_scanline:
	mov	ss: word ptr [di],ax
	movzx	dx,ds: byte ptr [bx].VESA_MODE_PANEL.MEMORY_BPP
	cmp	ds: byte ptr [bx].VESA_MODE_PANEL.VIDEO_MODE_MODEL,VESA_MODE_PLANAR
	jne	valid_vram_size_7_1
	shl	dx,2h
valid_vram_size_7_1:
	mul	dx
	push	dx
	push	ax
	pop	ecx
	add	ecx,7d
	shr	ecx,3h
	mov	eax,ebp
	xor	edx,edx
	div	ecx
	movzx	edx,ds: word ptr [min_virtual_ver]
	cmp	eax,edx
	jb	next_scanline_test
	movzx	edx,ds: word ptr [max_virtual_ver]
	cmp	eax,edx
	jbe	valid_ver_res
	xchg	ax,dx
valid_ver_res:
	inc	ds: word ptr [n_scanline]
	mov	ss: word ptr [di + 2h],ax
	cmp	ds: word ptr [n_scanline],MAX_N_SCANLINE
	jne	next_scanline_test
	call	Init_X_VESA
	mov	si,OFFSET vga_message_283
	or	ds: byte ptr [status_flag_5],ESC_ALERT_MESSAGE
	call	View_Alert_Message
	and	ds: byte ptr [status_flag_5],NOT ESC_ALERT_MESSAGE
	call	Clear_Screen
	jmp	ok_command_7_2
next_scanline_test:
	push	eax
	call	Get_BIOS_Ticks
	sub	eax,ds: dword ptr [timer_ticks]
	cmp	al,CHANGE_VRAM_STATUS
	pop	eax
	jb	no_change_vram_status
	pushad
	call	Save_Timer_Ticks
	mov	eax,ds: dword ptr [clear_value]
	or	eax,eax
	jne	no_start_value
	inc	eax
	jmp	ok_start_value
no_start_value:
	rol	eax,1h
ok_start_value:
	mov	ds: dword ptr [clear_value],eax
	movzx	ecx,ds: word ptr [current_bpsl]
	cmp	ds: word ptr [n_scanline],0h
	je	no_virtual_screen_n
	mov	di,ds: word ptr [n_scanline]
	shl	di,2h
	movzx	ecx,ss: word ptr [di - 4h]
no_virtual_screen_n:
	movzx	eax,ds: byte ptr [bx].VESA_MODE_PANEL.MEMORY_BPP
	cmp	ds: byte ptr [bx].VESA_MODE_PANEL.VIDEO_MODE_MODEL,VESA_MODE_PLANAR
	jne	valid_vram_size_8
	shl	eax,2h
valid_vram_size_8:
	imul	ecx,eax
	shr	ecx,3h
	movzx	eax,ds: word ptr [bx].VESA_MODE_PANEL.Y_RES
	imul	ecx,eax
	xor	edi,edi
	call	Clear_Graphic_VRAM
	popad
no_change_vram_status:
	inc	si
	mov	ax,ds: word ptr [max_virtual_hor]
	inc	ax
	cmp	si,ax
	jne	loop_virtual_scanline
end_scanline_test:
	cmp	ds: word ptr [n_scanline],0h
	jne	ok_command_7_1
	call	Init_X_VESA
	mov	si,OFFSET vga_message_282
	call	View_Alert_Message
	popa
	ret
ok_command_7_1:
	call	Init_X_VESA
ok_command_7_2:
	CENTER_BOX 68d,10d
	mov	si,OFFSET vga_message_285
	mov	di,OFFSET vga_message_284
	call	Extended_Box
	add	cx,0F02h
	mov	si,OFFSET vga_message_286
	call	Write_VGA_Message
	mov	ds: byte ptr [color_base_mem],EXTRA_COLOR
	add	ch,0Ch
	mov	ds: word ptr [start_xy],cx
	call	VESA_Command_02_01
	call	Next_Line
	xor	al,al
	test	ds: byte ptr [status_flag_2],VESA_MEMORY_MODE
	jne	write_memory_model_02_1
	inc	ax
	test	ds: byte ptr [status_flag_2],VESA_WINDOW_MODE
	je	write_memory_model_02_1
	inc	ax
write_memory_model_02_1:
	mov	si,OFFSET vga_message_177
	call	Write_Index_String
	mov	eax,ebp
	shr	eax,0Ah
	call	Write_Dec_Num_Left32
	inc	ch
	mov	si,OFFSET vga_message_013	
	call	Write_VGA_Message
	call	Next_Line
	mov	ax,ds: word ptr [n_scanline]
	call	Write_Dec_Num_Left16
	shl	ax,2h
	xchg	ax,si
	mov	ax,ss: word ptr [si - 4h]
	or	ds: byte ptr [status_flag_0],FLAG_THOUSANDS
	call	Size_Of_Number16
	push	ax
	mov	al,ds: byte ptr [number_count]
	mov	si,OFFSET inputs_05
	mov	ds: byte ptr [si].INPUTS.LEN,al
	mov	ds: byte ptr [color_base_mem],COLOR_BASE
	call	Next_Line
	inc	cx
	add	ch,al
	inc	ch
	mov	al,'('
	call	Write_Char
	mov	ax,ds: word ptr [bx].VESA_MODE_PANEL.X_RES
	call	Write_Dec_Num_Left16
	mov	al,'-'
	call	Write_Char
	pop	ax
	call	Write_Dec_Num_Left16
	mov	al,')'
	call	Write_Char
	inc	ch
	push	si
	mov	si,OFFSET vga_message_288
	call	Write_VGA_Message
	pop	si
	and	ds: byte ptr [status_flag_0],NOT FLAG_THOUSANDS
	mov	ds: byte ptr [input_buffer],0h
	call	Choice
	cmp	ds: word ptr [si].INPUTS.KEY,ESC_KEY
	je	exit_vesa_command_07
	mov	si,OFFSET input_buffer
	call	Asci_To_Num
	mov	si,ds: word ptr [bx].VESA_MODE_PANEL.X_RES
	mov	di,ss: word ptr [2h]
	cmp	ax,si
	jbe	go_set_scanline_7
	mov	si,ds: word ptr [n_scanline]
	shl	si,2h
	mov	di,ss: word ptr [si - 2h]
	mov	si,ss: word ptr [si - 4h]
	cmp	ax,si
	jae	go_set_scanline_7
	xor	cx,cx
	mov	dx,ds: word ptr [n_scanline]
	dec	dx
loop_get_scanline:
	cmp	cx,dx
	je	go_set_scanline_7_1
	mov	si,cx
	add	si,dx
	shr	si,1h
	mov	di,si
	shl	di,2h
	cmp	ax,ss: word ptr [di]
	jb	set_max_7
	ja	set_min_7
	jmp	go_set_scanline_7_2
set_max_7:
	cmp	si,dx
	je	go_set_scanline_7_2
	mov	dx,si
	jmp	loop_get_scanline
set_min_7:
	cmp	si,cx
	je	go_set_scanline_7_2
	mov	cx,si
	jmp	loop_get_scanline
go_set_scanline_7_1:
	mov	si,cx
go_set_scanline_7_2:
	shl	si,2h
	mov	di,ss: word ptr [si + 2h]
	mov	si,ss: word ptr [si]
go_set_scanline_7:
	cmp	ax,si
	je	ok_set_scanline_7
	push	di
	push	si
	call	Clear_Screen
	CENTER_BOX 50d,8d
	mov	si,OFFSET vga_message_028
	mov	di,OFFSET vga_message_160
	call	Extended_Box
	add	cx,402h
	mov	si,OFFSET vga_message_287
	call	Write_VGA_Message
	add	ch,19h
	mov	ds: word ptr [start_xy],cx
	mov	ds: byte ptr [color_base_mem],EXTRA_COLOR
	call	Write_Dec_Num_Left16
	mov	ds: byte ptr [color_base_mem],COLOR_BASE
	inc	ch
	mov	si,OFFSET vga_message_288
	call	Write_VGA_Message
	call	Next_Line
	pop	ax
	mov	ds: byte ptr [color_base_mem],EXTRA_COLOR
	call	Write_Dec_Num_Left16
	mov	ds: byte ptr [color_base_mem],COLOR_BASE
	inc	ch
	mov	si,OFFSET vga_message_288
	call	Write_VGA_Message
	call	Next_Line
	inc	cx
	sub	ch,19h
	mov	si,OFFSET vga_message_289
	call	Write_VGA_Message
	xchg	ax,si
	pop	di
loop_key_command_7:
	call	Get_Key
	cmp	ax,N_KEY
	je	exit_vesa_command_07
	cmp	ax,Y_KEY
	jne	loop_key_command_7
ok_set_scanline_7:
	or	ds: byte ptr [status_flag_4],VALID_VESA_ADDRESSING OR VALID_VESA_IO
	call	Open_VESA_Video_Mode
	jnc	valid_vesa_command_07_open_1
	popa
	ret
valid_vesa_command_07_open_1:
	mov	ax,si
	call	Set_VESA_Scanline
	jnc	ok_scanline_07
	call	Init_X_VESA
	mov	si,OFFSET vga_message_290
	call	View_Alert_Message
	popa
	ret
ok_scanline_07:
	mov	ax,ds: word ptr [scanline_vesa_bytes]
	mov	ds: word ptr [current_bpsl],ax
	movzx	ecx,ds: byte ptr [bx].VESA_MODE_PANEL.MEMORY_BPP
	mov	ds: word ptr [virtual_x_res],si
	movzx	esi,si
	imul	ecx,esi
	mov	ds: word ptr [virtual_y_res],di
	movzx	edi,di
	imul	ecx,edi
	cmp	ds: byte ptr [bx].VESA_MODE_PANEL.VIDEO_MODE_MODEL,VESA_MODE_PLANAR
	jne	valid_vram_size_7_2
	shl	ecx,2h
valid_vram_size_7_2:
	shr	ecx,3h
	xor	edi,edi
	call	Clear_Graphic_VRAM
	and	ds: byte ptr [status_flag_6],NOT (DISPLAY_START_BOUND_X OR DISPLAY_START_BOUND_Y)
	mov	ax,ds: word ptr [virtual_x_res]
	sub	ax,ds: word ptr [bx].VESA_MODE_PANEL.X_RES
	cmp	ax,DISPLAY_START_ALIGN
	jbe	ok_test_ds_x
	mov	ax,DISPLAY_START_ALIGN
ok_test_ds_x:
	xor	cx,cx
	or	ax,ax
	je	ok_align_x
	inc	cx
loop_test_ds_x:
	push	cx
	push	ax
	mov	ax,(VESA_ID SHL 8h) + VESA_FUNC_DISPLAY_START
	xor	dx,dx
	push	bx
	xor	bx,bx
	VIDEO_CALL
	pop	bx
	mov	ax,(VESA_ID SHL 8h) + VESA_FUNC_DISPLAY_START
	push	bx
	mov	bx,1h
	VIDEO_CALL
	pop	bx
	mov	dx,cx
	cmp	ax,VESA_ID
	pop	ax
	pop	cx
	jne	fail_test_ds_x
	cmp	cx,dx
	je	ok_align_x
fail_test_ds_x:
	inc	cx
	cmp	cx,ax
	jbe	loop_test_ds_x
	inc	cx
ok_align_x:
	mov	ds: byte ptr [ds_align_x],cl
	mov	ax,ds: word ptr [virtual_y_res]
	sub	ax,ds: word ptr [bx].VESA_MODE_PANEL.Y_RES
	cmp	ax,DISPLAY_START_ALIGN
	jbe	ok_test_ds_y
	mov	ax,DISPLAY_START_ALIGN
ok_test_ds_y:
	xor	dx,dx
	or	ax,ax
	je	ok_align_y
	inc	dx
loop_test_ds_y:
	push	dx
	push	ax
	mov	ax,(VESA_ID SHL 8h) + VESA_FUNC_DISPLAY_START
	push	bx
	xor	bx,bx
	xor	cx,cx
	VIDEO_CALL
	pop	bx
	mov	ax,(VESA_ID SHL 8h) + VESA_FUNC_DISPLAY_START
	push	bx
	mov	bx,1h
	VIDEO_CALL
	pop	bx
	mov	cx,dx
	cmp	ax,VESA_ID
	pop	ax
	pop	dx
	jne	fail_test_ds_y
	cmp	cx,dx
	je	ok_align_y
fail_test_ds_y:
	inc	dx
	cmp	dx,ax
	jbe	loop_test_ds_y
	inc	dx
ok_align_y:
	mov	ds: byte ptr [ds_align_y],dl
	mov	ax,ds: word ptr [virtual_x_res]
	sub	ax,ds: word ptr [bx].VESA_MODE_PANEL.X_RES
	xor	cx,cx
	cmp	ax,DISPLAY_START_ALIGN
	jbe	fail_test_ds_x_bound
	mov	cx,DISPLAY_START_ALIGN
loop_test_ds_x_bound:
	push	cx
	push	ax
	mov	ax,(VESA_ID SHL 8h) + VESA_FUNC_DISPLAY_START
	xor	dx,dx
	push	bx
	xor	bx,bx
	VIDEO_CALL
	pop	bx
	mov	ax,(VESA_ID SHL 8h) + VESA_FUNC_DISPLAY_START
	push	bx
	mov	bx,1h
	VIDEO_CALL
	pop	bx
	mov	dx,cx
	cmp	ax,VESA_ID
	pop	ax
	pop	cx
	jne	fail_test_ds_x_bound
	cmp	cx,dx
	jne	fail_test_ds_x_bound
	cmp	cx,8192d
	jbe	mul_2_bound_x
	add	cx,4096d
	jmp	bound_x_add4k
mul_2_bound_x:
	add	cx,cx
bound_x_add4k:
	jc	end_bound_test_x
	cmp	cx,ax
	jbe	loop_test_ds_x_bound
end_bound_test_x:
	or	ds: byte ptr [status_flag_6],DISPLAY_START_BOUND_X
fail_test_ds_x_bound:
	mov	ds: word ptr [ds_bound_x],cx
	mov	ax,ds: word ptr [virtual_y_res]
	sub	ax,ds: word ptr [bx].VESA_MODE_PANEL.Y_RES
	xor	dx,dx
	cmp	ax,DISPLAY_START_ALIGN
	jbe	fail_test_ds_y_bound
	mov	dx,DISPLAY_START_ALIGN
loop_test_ds_y_bound:
	push	dx
	push	ax
	mov	ax,(VESA_ID SHL 8h) + VESA_FUNC_DISPLAY_START
	xor	cx,cx
	push	bx
	xor	bx,bx
	VIDEO_CALL
	pop	bx
	mov	ax,(VESA_ID SHL 8h) + VESA_FUNC_DISPLAY_START
	push	bx
	mov	bx,1h
	VIDEO_CALL
	pop	bx
	mov	cx,dx
	cmp	ax,VESA_ID
	pop	ax
	pop	dx
	jne	fail_test_ds_y_bound
	cmp	cx,dx
	jne	fail_test_ds_y_bound
	cmp	dx,8192d
	jbe	mul_2_bound_y
	add	dx,4096d
	jmp	bound_y_add4k
mul_2_bound_y:
	add	dx,dx
bound_y_add4k:
	jc	end_bound_test_y
	cmp	dx,ax
	jbe	loop_test_ds_y_bound
end_bound_test_y:
	or	ds: byte ptr [status_flag_6],DISPLAY_START_BOUND_Y
fail_test_ds_y_bound:
	mov	ds: word ptr [ds_bound_y],dx
	mov	ax,(VESA_ID SHL 8h) + VESA_FUNC_DISPLAY_START
	xor	cx,cx
	xor	dx,dx
	push	bx
	xor	bx,bx
	VIDEO_CALL
	pop	bx
	mov	si,OFFSET vesa_box
	mov	ds: word ptr [si].VBOX.X_START,0h
	mov	ds: word ptr [si].VBOX.Y_START,0h
	mov	ax,ds: word ptr [virtual_x_res]
	dec	ax
	mov	ds: word ptr [si].VBOX.X_END,ax
	mov	ax,ds: word ptr [virtual_y_res]
	dec	ax
	mov	ds: word ptr [si].VBOX.Y_END,ax
	call	Write_Graphic_Box
	mov	edi,100d
	mov	si,OFFSET vesa_line
loop_hor_line_7:
	mov	ds: word ptr [si].LINE.X_POS,0h
	mov	dx,ds: word ptr [virtual_x_res]
	mov	ds: word ptr [si].LINE.LEN,dx
	mov	ds: word ptr [si].LINE.Y_POS,di
	push	edi
	call	Write_Horizontal_Line
	pop	edi
	add	edi,100d
	movzx	eax,ds: word ptr [virtual_y_res]
	cmp	edi,eax
	jb	loop_hor_line_7
	mov	edi,100d
	mov	si,OFFSET vesa_line
loop_ver_line_7:
	mov	ds: word ptr [si].LINE.Y_POS,0h
	mov	dx,ds: word ptr [virtual_y_res]
	mov	ds: word ptr [si].LINE.LEN,dx
	mov	ds: word ptr [si].LINE.X_POS,di
	push	edi
	call	Write_Vertical_Line
	pop	edi
	add	edi,100d
	movzx	eax,ds: word ptr [virtual_x_res]
	cmp	edi,eax
	jb	loop_ver_line_7
	call	Enter_Redirector
	or	ds: byte ptr [status_flag_0],FLAG_THOUSANDS
	mov	si,OFFSET buffer_vesa_string
	mov	edi,100d
loop_numy_7:
	mov	ebp,100d
loop_numx_7:
	call	Set_Virtual_String
	xor	cx,cx
	mov	ax,bp
	call	Write_Dec_Num_Left16
	mov	al,','
	call	Write_Char
	mov	ax,di
	call	Write_Dec_Num_Left16
	call	Get_Virtual_String
	call	Str_Len
	imul	ax,VIDEO_FONT_WIDTH
	mov	cx,bp
	sub	cx,ax
	mov	dx,di
	sub	dx,VIDEO_FONT_HEIGHT
	push	edi
	push	ebp
	call	Write_VESA_String
	pop	ebp
	pop	edi
	add	ebp,100d
	movzx	eax,ds: word ptr [virtual_x_res]
	cmp	ebp,eax
	jb	loop_numx_7
	add	edi,100d
	movzx	eax,ds: word ptr [virtual_y_res]
	cmp	edi,eax
	jb	loop_numy_7
	and	ds: byte ptr [status_flag_0],NOT FLAG_THOUSANDS
	mov	si,OFFSET vesa_box
	mov	bp,TEXT_WIDTH
	mov	ds: word ptr [si].VBOX.X_START,16d
	mov	ds: word ptr [si].VBOX.Y_START,16d
	mov	ax,51d * VIDEO_FONT_WIDTH + 15d
	mov	dx,51d * VIDEO_FONT_WIDTH + 15d + 16d
	cmp	dx,ds: word ptr [virtual_x_res]
	jbe	valid_size_panel_7
	mov	ax,ds: word ptr [virtual_x_res]
	mov	bp,ax
	shr	bp,3h
	sub	bp,6d
	sub	ax,15d
valid_size_panel_7:
	mov	ds: word ptr [si].VBOX.X_END,ax
	mov	ds: word ptr [si].VBOX.Y_END,11d * VIDEO_FONT_HEIGHT + 15d
	call	Write_Graphic_Box
	mov	ds: dword ptr [foreground_vesa_color],0h
	inc	ds: word ptr [si].VBOX.X_START
	inc	ds: word ptr [si].VBOX.Y_START
	dec	ds: word ptr [si].VBOX.X_END
	dec	ds: word ptr [si].VBOX.Y_END
	call	Write_Graphic_Box_Fill
	call	Set_VESA_Default_Color
	call	Set_Virtual_String
	mov	cx,800h
	mov	si,OFFSET vga_message_228
	call	Write_Simple_VGA_Message
	inc	ch
	call	VESA_Command_02_01
	call	Get_Virtual_String
	mov	cx,28d
	mov	dx,21d
	mov	si,OFFSET buffer_vesa_string
	mov	ds: byte ptr [bp + si],0h
	call	Write_VESA_String
	call	Set_Virtual_String
	mov	cx,600h
	mov	si,OFFSET vga_message_229
	call	Write_Simple_VGA_Message
	inc	ch
	xor	al,al
	test	ds: byte ptr [status_flag_2],VESA_MEMORY_MODE
	jne	write_memory_model_02_2
	inc	ax
	test	ds: byte ptr [status_flag_2],VESA_WINDOW_MODE
	je	write_memory_model_02_2
	inc	ax
write_memory_model_02_2:
	mov	si,OFFSET vga_message_177
	call	Write_Index_String
	call	Get_Virtual_String
	mov	cx,28d
	mov	dx,31d
	mov	si,OFFSET buffer_vesa_string
	mov	ds: byte ptr [bp + si],0h
	call	Write_VESA_String
	call	Set_Virtual_String
	push	bp
	mov	cx,400h
	mov	si,OFFSET vga_message_200a
	call	Write_Simple_VGA_Message
	call	Retrieve_VRAM_Size
	xchg	eax,ebp
	inc	ch
	call	Write_Dec_Num_Left32
	inc	ch
	mov	si,OFFSET vga_message_013 + 3h
	call	Write_Simple_VGA_Message
	call	Get_Virtual_String
	mov	cx,28d
	mov	dx,41d
	mov	si,OFFSET buffer_vesa_string
	pop	bp
	mov	ds: byte ptr [bp + si],0h
	call	Write_VESA_String
	call	Set_Virtual_String
	xor	cx,cx
	mov	si,OFFSET vga_message_291
	call	Write_Simple_VGA_Message
	inc	ch
	mov	ax,ds: word ptr [virtual_x_res]
	call	Write_Dec_Num_Left16
	mov	al,'x'
	call	Write_Char
	mov	ax,ds: word ptr [virtual_y_res]
	call	Write_Dec_Num_Left16
	inc	ch
	mov	si,OFFSET vga_message_288
	call	Write_Simple_VGA_Message
	call	Get_Virtual_String
	mov	cx,28d
	mov	dx,51d
	mov	si,OFFSET buffer_vesa_string
	mov	ds: byte ptr [bp + si],0h
	call	Write_VESA_String
	mov	si,OFFSET vga_message_292
	mov	ax,5h
	mov	dx,71d
loop_panel_7:
	mov	cx,26d
	push	ax
	call	Str_Len
	xchg	ax,di
	pop	ax
	cmp	di,bp
	jbe	no_little_size_7
	push	ax
	mov	al,ds: byte ptr [bp + si]
	mov	ds: byte ptr [bp + si],0h
	call	Write_VESA_String
	mov	ds: byte ptr [bp + si],al
	pop	ax
	jmp	next_string_7
no_little_size_7:
	call	Write_VESA_String
next_string_7:
	call	Str_Len_Mem
	add	dx,VIDEO_FONT_HEIGHT
	dec	ax
	jne	loop_panel_7
	or	ds: byte ptr [status_flag_5],VIRTUAL_VESA_VIDEO_MODE
	push	bx
	and	ds: byte ptr [status_flag_5],NOT (MOUSE_X_DEM OR MOUSE_Y_DEM)
	mov	ax,(DOS_FUNC_GET_INTERRUPT SHL 8h) + MOUSE_INTERRUPT
	int	DOS_INTERRUPT
	mov	ax,es
	push	ds
	pop	es
	or	ax,bx
	pop	bx
	je	set_new_display_start_1
	mov	ax,MOUSE_GET_STATUS
	push	bx
	int	MOUSE_INTERRUPT
	pop	bx
	or	ax,ax
	je	set_new_display_start_1
	or	ds: byte ptr [status_flag_5],MOUSE_ON
	mov	ax,MOUSE_HIDE_CURSOR
	push	bx
	int	MOUSE_INTERRUPT
	pop	bx
	mov	ax,MOUSE_MAXMIN_X
	xor	cx,cx
	mov	dx,ds: word ptr [virtual_x_res]
	sub	dx,ds: word ptr [bx].VESA_MODE_PANEL.X_RES
	cmp	dx,32767d
	jbe	no_dem_x
	or	ds: byte ptr [status_flag_5],MOUSE_X_DEM
	shr	dx,1h
no_dem_x:
	push	bx
	int	MOUSE_INTERRUPT
	pop	bx
	mov	ax,MOUSE_MAXMIN_Y
	xor	cx,cx
	mov	dx,ds: word ptr [virtual_y_res]
	sub	dx,ds: word ptr [bx].VESA_MODE_PANEL.Y_RES
	cmp	dx,32767d
	jbe	no_dem_y
	or	ds: byte ptr [status_flag_5],MOUSE_Y_DEM
	shr	dx,1h
no_dem_y:
	push	bx
	int	MOUSE_INTERRUPT
	pop	bx
set_new_display_start_1:
	mov	ds: word ptr [offset_virtual_x_res],0h
	mov	ds: word ptr [offset_virtual_y_res],0h
set_new_display_start:
	test	ds: byte ptr [status_flag_5],MOUSE_ON
	je	no_key_pressed_9
	mov	ax,MOUSE_SET_POS
	mov	cx,ds: word ptr [offset_virtual_x_res]
	test	ds: byte ptr [status_flag_5],MOUSE_X_DEM
	je	no_mouse_x_dem_1
	shr	cx,1h
no_mouse_x_dem_1:
	mov	dx,ds: word ptr [offset_virtual_y_res]
	test	ds: byte ptr [status_flag_5],MOUSE_Y_DEM
	je	no_mouse_x_dem_2
	shr	dx,1h
no_mouse_x_dem_2:
	push	bx
	int	MOUSE_INTERRUPT
	pop	bx
no_key_pressed_9:
	push	bx
	mov	ax,(VESA_ID SHL 8h) + VESA_FUNC_DISPLAY_START
	xor	bx,bx
	mov	cx,ds: word ptr [offset_virtual_x_res]
	mov	dx,ds: word ptr [offset_virtual_y_res]
	VIDEO_CALL
	pop	bx
no_key_pressed_7:
	test	ds: byte ptr [status_flag_5],MOUSE_ON
	je	no_key_pressed_8
	mov	ax,MOUSE_GET_POS
	push	bx
	int	MOUSE_INTERRUPT
	pop	bx
	test	ds: byte ptr [status_flag_5],MOUSE_X_DEM
	je	no_mouse_x_dem_3
	shl	cx,1h
no_mouse_x_dem_3:
	test	ds: byte ptr [status_flag_5],MOUSE_Y_DEM
	je	no_mouse_x_dem_4
	shl	dx,1h
no_mouse_x_dem_4:
	cmp	cx,ds: word ptr [offset_virtual_x_res]
	jne	set_mouse_pos
	cmp	dx,ds: word ptr [offset_virtual_y_res]
	je	no_key_pressed_8
set_mouse_pos:
	mov	ds: word ptr [offset_virtual_x_res],cx
	mov	ds: word ptr [offset_virtual_y_res],dx
	jmp	set_new_display_start
no_key_pressed_8:
	mov	si,BIOS_SAVE_AREA_SEGMENT
	mov	ds,si
	mov	si,ds: word ptr [KEYBOARD_BUFFER_HEAD]
	cmp	si,ds: word ptr [KEYBOARD_BUFFER_TAIL]
	push	es
	pop	ds
	je	no_key_pressed_7
loop_key_virtual_scroll:
	call	Get_Key
	cmp	ax,LEFT_KEY
	jne	test_key_7_1
	cmp	ds: word ptr [offset_virtual_x_res],0h
	je	loop_key_virtual_scroll
	dec	ds: word ptr [offset_virtual_x_res]
	jmp	set_new_display_start
test_key_7_1:
	cmp	ax,UP_KEY
	jne	test_key_7_2
	cmp	ds: word ptr [offset_virtual_y_res],0h
	je	loop_key_virtual_scroll
	dec	ds: word ptr [offset_virtual_y_res]
	jmp	set_new_display_start
test_key_7_2:
	cmp	ax,RIGHT_KEY
	jne	test_key_7_3
	mov	ax,ds: word ptr [bx].VESA_MODE_PANEL.X_RES
	add	ax,ds: word ptr [offset_virtual_x_res]
	cmp	ax,ds: word ptr [virtual_x_res]
	je	loop_key_virtual_scroll
	inc	ds: word ptr [offset_virtual_x_res]
	jmp	set_new_display_start
test_key_7_3:	
	cmp	ax,DOWN_KEY
	jne	test_key_7_4
	mov	ax,ds: word ptr [bx].VESA_MODE_PANEL.Y_RES
	add	ax,ds: word ptr [offset_virtual_y_res]
	cmp	ax,ds: word ptr [virtual_y_res]
	je	loop_key_virtual_scroll
	inc	ds: word ptr [offset_virtual_y_res]
	jmp	set_new_display_start
test_key_7_4:
	cmp	ax,CTRL_LEFT_KEY
	jne	test_key_7_5
	mov	ax,ds: word ptr [offset_virtual_x_res]
	or	ax,ax
	je	loop_key_virtual_scroll
	mov	dx,10d
	cmp	ax,dx
	jae	ok_ctrl_1
	xchg	ax,dx
ok_ctrl_1:
	sub	ds: word ptr [offset_virtual_x_res],dx
	jmp	set_new_display_start
test_key_7_5:
	cmp	ax,CTRL_UP_KEY
	jne	test_key_7_6
	mov	ax,ds: word ptr [offset_virtual_y_res]
	or	ax,ax
	je	loop_key_virtual_scroll
	mov	dx,10d
	cmp	ax,dx
	jae	ok_ctrl_2
	xchg	ax,dx
ok_ctrl_2:
	sub	ds: word ptr [offset_virtual_y_res],dx
	jmp	set_new_display_start
test_key_7_6:
	cmp	ax,CTRL_RIGHT_KEY
	jne	test_key_7_7
	mov	ax,ds: word ptr [virtual_x_res]
	sub	ax,ds: word ptr [bx].VESA_MODE_PANEL.X_RES
	sub	ax,ds: word ptr [offset_virtual_x_res]
	or	ax,ax
	je	loop_key_virtual_scroll
	mov	dx,10d
	cmp	ax,dx
	jae	ok_ctrl_3
	xchg	ax,dx
ok_ctrl_3:
	add	ds: word ptr [offset_virtual_x_res],dx
	jmp	set_new_display_start
test_key_7_7:	
	cmp	ax,CTRL_DOWN_KEY
	jne	test_key_7_8
	mov	ax,ds: word ptr [virtual_y_res]
	sub	ax,ds: word ptr [bx].VESA_MODE_PANEL.Y_RES
	sub	ax,ds: word ptr [offset_virtual_y_res]
	or	ax,ax
	je	loop_key_virtual_scroll
	mov	dx,10d
	cmp	ax,dx
	jae	ok_ctrl_4
	xchg	ax,dx
ok_ctrl_4:
	add	ds: word ptr [offset_virtual_y_res],dx
	jmp	set_new_display_start
test_key_7_8:
	cmp	ax,DEL_KEY
	je	set_new_display_start_1
	cmp	ax,ESC_KEY
	jne	loop_key_virtual_scroll
	and	ds: byte ptr [status_flag_5],NOT VIRTUAL_VESA_VIDEO_MODE
	call	Init_X_VESA
	CENTER_BOX 52d,9d
	mov	si,OFFSET vga_message_315
	mov	di,OFFSET vga_message_007
	call	Extended_Box
	add	cx,602h
	mov	si,OFFSET vga_message_316
	call	Write_VGA_Message
	add	ch,16h
	mov	ds: word ptr [start_xy],cx
	mov	ds: byte ptr [color_base_mem],EXTRA_COLOR
	mov	al,ds: byte ptr [ds_align_x]
	mov	si,OFFSET vga_message_319
	or	al,al
	je	write_align_x
	mov	si,OFFSET vga_message_320
	cmp	al,DISPLAY_START_ALIGN + 1d
	je	write_align_x
	call	Write_Dec_Num_Left8
	inc	ch
	mov	si,OFFSET vga_message_321
write_align_x:
	call	Write_VGA_Message
	call	Next_Line
	mov	si,OFFSET vga_message_317
	test	ds: byte ptr [status_flag_6],DISPLAY_START_BOUND_X
	jne	write_bound_x
	mov	ax,ds: word ptr [ds_bound_x]
	mov	si,OFFSET vga_message_319
	or	ax,ax
	je	write_bound_x
	mov	si,OFFSET vga_message_320
	cmp	ax,DISPLAY_START_ALIGN
	je	write_bound_x
	mov	ds: byte ptr [color_base_mem],ND_COLOR
	call	Write_Dec_Num_Left16
	inc	ch
	mov	ds: byte ptr [color_base_mem],EXTRA_COLOR
	mov	si,OFFSET vga_message_321
write_bound_x:
	call	Write_VGA_Message
	call	Next_Line
	mov	al,ds: byte ptr [ds_align_y]
	mov	si,OFFSET vga_message_319
	or	al,al
	je	write_align_y
	mov	si,OFFSET vga_message_320
	cmp	al,DISPLAY_START_ALIGN + 1d
	je	write_align_y
	call	Write_Dec_Num_Left8
	inc	ch
	mov	si,OFFSET vga_message_321
write_align_y:
	call	Write_VGA_Message
	call	Next_Line
	mov	si,OFFSET vga_message_317
	test	ds: byte ptr [status_flag_6],DISPLAY_START_BOUND_Y
	jne	write_bound_y
	mov	ax,ds: word ptr [ds_bound_y]
	mov	si,OFFSET vga_message_319
	or	ax,ax
	je	write_bound_y
	mov	si,OFFSET vga_message_320
	cmp	ax,DISPLAY_START_ALIGN
	je	write_bound_y
	mov	ds: byte ptr [color_base_mem],ND_COLOR
	call	Write_Dec_Num_Left16
	inc	ch
	mov	ds: byte ptr [color_base_mem],EXTRA_COLOR
	mov	si,OFFSET vga_message_321
write_bound_y:
	call	Write_VGA_Message
	call	Next_Line
	mov	si,OFFSET vga_message_319
	mov	dx,ds: word ptr [n_scanline]
	xor	di,di
	mov	ax,ss: word ptr [di]
loop_get_gr_hor:
	cmp	ax,ss: word ptr [di]
	jne	ok_gr_hor
	add	di,4h
	dec	dx
	jne	loop_get_gr_hor
	jmp	no_gr_hor
ok_gr_hor:
	sub	ax,ss: word ptr [di]
	neg	ax
	call	Write_Dec_Num_Left16
	inc	ch
	mov	si,OFFSET vga_message_321
no_gr_hor:
	call	Write_VGA_Message
loop_command_7_ba:
	call	Get_Key
	cmp	ax,ESC_KEY
	jne	loop_command_7_ba
	mov	ds: byte ptr [color_base_mem],COLOR_BASE
exit_vesa_command_07:
	popa
	ret
