;#############################################################################

;	DS:BX = Pointer to vesa_mode_info video mode

	VESA_Command_02:

;#############################################################################

	pusha
	cmp	ds: byte ptr [bx].VESA_MODE_PANEL.VIDEO_MODE_MODEL,VESA_MODE_PACKET
	je	valid_vesa_command_02
	cmp	ds: byte ptr [bx].VESA_MODE_PANEL.VIDEO_MODE_MODEL,VESA_MODE_DIRECT_COLOR
	je	valid_vesa_command_02
	mov	si,OFFSET vga_message_154
	call	View_Alert_Message
	popa
	ret
valid_vesa_command_02:
	or	ds: byte ptr [status_flag_4],VALID_VESA_ADDRESSING
	call	Open_VESA_Video_Mode
	jnc	valid_vesa_command_02_open
	popa
	ret
valid_vesa_command_02_open:
	mov	es,ds: word ptr [banked_segment]
	mov	di,OFFSET vesa_speed_routines
	test	ds: byte ptr [status_flag_2],VESA_MEMORY_MODE
	je	pointer_routines_vesa
	add	di,TEST_NUMBER SHL 1h
pointer_routines_vesa:
	mov	si,OFFSET result_speed
loop_test_speed:
	movzx	ebp,ds: word ptr [segment_size]
	mov	ds: dword ptr [si + 8h],0h
	mov	cx,20h
loop_dummy_routine:
	call	Timer_On
	inc	ds: dword ptr [n_exec_test]
	call	ds: word ptr [di + (TEST_NUMBER SHL 2h)]
	jc	dummy_no_speed_routine
dummy_no_speed_routine:
	call	Get_BIOS_Ticks
	sub	eax,ds: dword ptr [timer_ticks]
	cmp	eax,MAX_TICKS
	jbe     dummy_loop_bench_mode
dummy_loop_bench_mode:
	call	Timer_Off
	mov	eax,ds: dword ptr [elapsed_time]
	add	ds: dword ptr [si + 8h],eax
	loop	loop_dummy_routine
	shr	ds: dword ptr [si + 8h],5h
	mov	ds: dword ptr [n_exec_test],0h	
	mov	ds: dword ptr [kb_proc],0h
	call	Save_Timer_Ticks
	call	Timer_On
loop_bench_mode:
	inc	ds: dword ptr [n_exec_test]
	call	ds: word ptr [di]
	jc	no_speed_routine
	call	Get_BIOS_Ticks
	sub	eax,ds: dword ptr [timer_ticks]
	cmp	eax,MAX_TICKS
	jbe     loop_bench_mode
	call	Timer_Off
	mov	eax,13125000d
	mul	ds: dword ptr [kb_proc]
	imul	ecx,ds: dword ptr [elapsed_time],0Bh
	div	ecx
	mov	ds: dword ptr [si],eax
	mov	eax,ds: dword ptr [si + 8h]
	imul	eax,ds: dword ptr [n_exec_test]
	mov	ecx,ds: dword ptr [elapsed_time]
	sub	ecx,eax
	imul	ecx,0Bh	
	mov	eax,13125000d
	mul	ds: dword ptr [kb_proc]
	div	ecx
	mov	ds: dword ptr [si + 4h],eax
	mov	eax,ds: dword ptr [elapsed_time]
	mov	ecx,ds: dword ptr [si + 8h]
	imul	ecx,ds: dword ptr [n_exec_test]
	sub	eax,ecx
	mov	ecx,10000d
	mul	ecx
	div	ds: dword ptr [elapsed_time]
	sub	eax,ecx
	neg	eax
	mov	ds: dword ptr [si + 0Ch],eax
no_max_speed:
	add	di,2h
	add	si,10h
	cmp	si,OFFSET end_result_speed
	jne	loop_test_speed
	push	ds
	pop	es
	call	Init_X_Vesa
	xor	si,si
	mov	di,OFFSET vga_message_185
	xor	cx,cx
	mov	dx,((TEXT_WIDTH - 1h) SHL 8h) + TEXT_HEIGHT - 1h
	call	Extended_Box
	call	Draw_Adapter_Info
	mov	cx,50Bh
	mov	si,OFFSET vga_message_176
	call	Write_VGA_Message
	mov	cx,606h
	mov	si,OFFSET vga_message_175
	call	Write_VGA_Message
	mov	ds: byte ptr [color_base_mem],EXTRA_COLOR
	mov	ch,12h
	call	VESA_Command_02_01
	inc	cx
	mov	ch,12h
	xor	al,al
	test	ds: byte ptr [status_flag_2],VESA_MEMORY_MODE
	jne	write_memory_model
	inc	ax
	test	ds: byte ptr [status_flag_2],VESA_WINDOW_MODE
	je	write_memory_model
	inc	ax
write_memory_model:
	test	ds: byte ptr [status_flag_0],FLAG_AVX OR FLAG_AVX512
	je	ok_memory_model
	test	ds: byte ptr [status_flag_2],A20_ENABLED
	je	ok_memory_model
	test	ds: byte ptr [status_flag_2],EXEC_AVX
	jne	ok_memory_model
	add	al,3h
ok_memory_model:
	mov	si,OFFSET vga_message_177
	call	Write_Index_String
	mov	eax,ds: dword ptr [timer_overhead]
	call	Write_Dec_Num_Left32
	inc	ch
	mov	si,OFFSET vga_message_184
	call	Write_VGA_Message
	mov	cx,100Ah
loop_result_bar:
	mov	si,OFFSET vga_message_178
	call	Write_VGA_message
	add	cl,2h
	cmp	cl,TEXT_HEIGHT
	jne	loop_result_bar
	mov	ds: byte ptr [color_base_mem],COLOR_BASE
	mov	ds: byte ptr [current_page_result],0h
	mov	di,OFFSET result_speed
loop_result_page:
	mov	cx,(HEADER_LEFT_SPACE SHL 8h) + 0h
	lea	ax,ds: word ptr [di - (result_speed - start_data)]
	shr	ax,2h
	mov	si,OFFSET vga_message_174
	call	Write_Index_String
	mov	cx,0E0Bh
	call	Get_Max_Result
	xor	dl,dl
loop_write_speed_result_1:
	mov	ch,0Eh
	mov	si,OFFSET vga_message_186
	call	Write_VGA_Message
	call	Check_Valid_Result
	jc	next_result_test
	mov	ch,TEXT_WIDTH - 9h
	mov	eax,ds: dword ptr [di]
	mov	ds: byte ptr [color_base_mem],EXTRA_COLOR
	cmp	ds: byte ptr [current_page_result],3h
	jne	no_dec_result_num
	mov	ds: byte ptr [decimal_digits],2h
	call	Write_Decimal_Number32
	jmp	next_result_1
no_speed_routine:
	call	Timer_Off
	mov	ds: dword ptr [si],NO_TEST_EXEC
	mov	ds: dword ptr [si + 4h],NO_TEST_EXEC
	mov	ds: dword ptr [si + 8h],NO_TEST_EXEC
	mov	ds: dword ptr [si + 0Ch],NO_TEST_EXEC
	jmp	no_max_speed
no_dec_result_num:
	cmp	ds: byte ptr [current_page_result],2h
	je	next_result_1a
	mov	si,OFFSET vga_message_150
	cmp	eax,1000000d
	jb	ok_kibs
	shr	eax,10d
	mov	si,OFFSET vga_message_203
ok_kibs:
	push	dx
	push	si
	mov	ebx,0Ah
	mov	esi,1h
loop_normalize_result:
	xor	edx,edx
	cmp	eax,1000d
	jb	valid_result
	div	ebx
	imul	esi,ebx
	jmp	loop_normalize_result
valid_result:
	imul	esi
	pop	si
	pop	dx
	call	Write_Dec_Num32
	add	ch,2h
	jmp	valid_string_result
next_result_1a:
	call	Write_Dec_Num32
next_result_1:
	add	ch,2h
	mov	si,OFFSET vga_message_187
	cmp	ds: byte ptr [current_page_result],2h
	je	valid_string_result
	mov	si,OFFSET vga_message_188	
valid_string_result:
	call	Write_VGA_Message
	mov	ds: byte ptr [color_base_mem],ND_COLOR
	push	dx
	mov	eax,ds: dword ptr [di]
	mov	ch,0Eh	
	mov	esi,400d
	mul	esi
	div	ebp
	mov	bx,ax
	shr	ax,3h
	and	bl,7h
	mov	si,OFFSET vga_message_183
	mov	ds: byte ptr [si + 1h],al
	call	Write_VGA_Message
	add     ch,al
	mov	al,bl
	call	Write_Char
	pop	dx
next_result_test:
	add	di,20h
	inc	dl
	cmp	dl,TEST_NUMBER SHR 1h
	jne	next_test
	xor	dl,dl
	sub	di,(TEST_NUMBER SHL 4h) - 10h
next_test:
	add	cl,2h
	cmp	cl,TEXT_HEIGHT - 1h
	jne	loop_write_speed_result_1
	sub	di,20h
	mov	ds: byte ptr [color_base_mem],COLOR_BASE
loop_result_page_1:
	call	Get_Key
	cmp	ax,END_KEY
	jne	test_result_page_4
	cmp	ds: byte ptr [current_page_result],N_PAGE_RESULT - 1h
	je	loop_result_page_1
	mov	ds: byte ptr [current_page_result],N_PAGE_RESULT - 1h
	mov	di,OFFSET result_speed + 0Ch
	jmp	loop_result_page
test_result_page_4:
	cmp	ax,HOME_KEY
	jne	test_result_page_3
	cmp	ds: byte ptr [current_page_result],0h
	je	loop_result_page_1
	mov	ds: byte ptr [current_page_result],0h
	mov	di,OFFSET result_speed
	jmp	loop_result_page	
test_result_page_3:	
	cmp	ax,LEFT_KEY
	jne	test_result_page_1
	sub	di,4h
	sub	ds: byte ptr [current_page_result],1h
	jnc	loop_result_page
	mov	ds: byte ptr [current_page_result],N_PAGE_RESULT - 1h
	mov	di,OFFSET result_speed + 0Ch
	jmp	loop_result_page
test_result_page_1:
	cmp	ax,RIGHT_KEY
	jne	test_result_page_2
	add	di,4h
	add	ds: byte ptr [current_page_result],1h
	cmp	ds: byte ptr [current_page_result],N_PAGE_RESULT
	jne	loop_result_page
	mov	ds: byte ptr [current_page_result],0h
	mov	di,OFFSET result_speed
	jmp	loop_result_page
test_result_page_2:
	cmp	ax,ESC_KEY
	jne	loop_result_page_1
	popa
	ret

;#############################################################################

	Get_Max_Result:

;#############################################################################

	push	di
	xor	ebp,ebp
	xor	dh,dh
loop_get_max_result:
	cmp	ds: dword ptr [di],NO_TEST_EXEC
	je	no_max_result
	cmp	ds: dword ptr [di],ebp
	jbe	no_max_result
	mov	ebp,ds: dword ptr [di]
no_max_result:
	add	di,10h
	inc	dh
	cmp	dh,TEST_NUMBER
	jne	loop_get_max_result
	pop	di
	ret

;#############################################################################

	Check_Valid_Result:

;#############################################################################

	mov	ds: byte ptr [color_base_mem],ND_COLOR
	cmp	dl,3h
	jne	test_sse_result
	test	ds: byte ptr [status_flag_0],FLAG_FPU_PRESENT
	jne	write_result
	mov	si,OFFSET vga_message_179
	call	Write_VGA_Message
	jmp	no_write_result
test_sse_result:
	cmp	dl,4h
	jne	test_avx_result
	mov	si,OFFSET vga_message_191
	test	ds: byte ptr [status_flag_0],FLAG_V86_ON
	jne	v86_sse
	test	ds: byte ptr [status_flag_0],FLAG_SSE
	jne	write_result
	mov	si,OFFSET vga_message_180
v86_sse:
	call	Write_VGA_Message
	jmp	no_write_result
test_avx_result:
	cmp	dl,5h
	jne	test_avx512_result
	mov	si,OFFSET vga_message_192
	test	ds: byte ptr [status_flag_0],FLAG_V86_ON
	jne	v86_avx
	mov	si,OFFSET vga_message_193
	test	ds: byte ptr [status_flag_2],A20_ENABLED
	je	v86_avx
	mov	si,OFFSET vga_message_181
	test	ds: byte ptr [status_flag_0],FLAG_AVX
	je	v86_avx
	mov	si,OFFSET vga_message_194
	test	ds: byte ptr [status_flag_2],EXEC_AVX
	je	write_result
v86_avx:
	call	Write_VGA_Message
	jmp	no_write_result	
test_avx512_result:
	cmp	dl,6h
	jne	write_result
	mov	si,OFFSET vga_message_195
	test	ds: byte ptr [status_flag_0],FLAG_V86_ON
	jne	v86_avx512
	mov	si,OFFSET vga_message_196
	test	ds: byte ptr [status_flag_2],A20_ENABLED
	je	v86_avx512
	mov	si,OFFSET vga_message_182
	test	ds: byte ptr [status_flag_0],FLAG_AVX512
	je	v86_avx512
	mov	si,OFFSET vga_message_197
	test	ds: byte ptr [status_flag_2],EXEC_AVX
	je	write_result
v86_avx512:
	call	Write_VGA_Message
no_write_result:
	stc
	ret
write_result:
	clc
	ret

;#############################################################################

	VESA_Command_02_01:

;#############################################################################

	mov	ax,ds: word ptr [bx].VESA_MODE_PANEL.VIDEO_MODE
	call	Num_To_Str_Hex4
	inc	ch
	mov	al,'-'
	call	Write_Char
	inc	ch
	mov	al,'('
	call	Write_Char
	mov	ax,ds: word ptr [bx].VESA_MODE_PANEL.X_RES
	call	Write_Dec_Num_Left16
	mov	al,'x'
	call	Write_Char
	mov	ax,ds: word ptr [bx].VESA_MODE_PANEL.Y_RES
	call	Write_Dec_Num_Left16
	mov	al,'x'
	call	Write_Char
	mov	al,ds: byte ptr [bx].VESA_MODE_PANEL.COLOR_BPP
	call	Write_Dec_Num_Left8
	mov	al,')'
	call	Write_Char
	ret
