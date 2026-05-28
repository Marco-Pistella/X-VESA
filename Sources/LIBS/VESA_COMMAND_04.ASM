;#############################################################################

;	DS:BX = Pointer to vesa_mode_info video mode

	VESA_Command_04:

;#############################################################################

	pusha
	call	Open_VESA_Video_Mode
	jnc	valid_vesa_command_04
	popa
	ret
valid_vesa_command_04:
	mov	ds: word ptr [fail_hor_samples],0h
	movzx	ecx,ds: word ptr [bx].VESA_MODE_PANEL.Y_RES
	cmp	ds: byte ptr [bx].VESA_MODE_PANEL.VIDEO_MODE_MODEL,VESA_MODE_TEXT
	jne	no_align_text_mode
	mov	ah,CRTC_MAXIMUM_SCAN_LINE
	call	Get_CRTC
	and	eax,VGA_MAX_FONT_HEIGHT - 1h
	inc	eax
	imul	ecx,eax
no_align_text_mode:
	mov	eax,13125000d
	xor	edx,edx
	imul	ecx,11d
	div	ecx
	mov	ds: dword ptr [min_pit_hor],eax
	mov	si,STATUS_LED
	call	Get_BIOS_Mem
	mov	ds: byte ptr [old_status_led],al
	push	bx
	mov	bx,64000d
	call	Delay
	pop	bx
	call	Get_Input_Status_Register
	call	Save_Timer_Ticks
	in	al,dx
	mov	ch,al
loop_check_vretrace_1:
	xor	di,di
loop_check_vretrace:
	in	al,dx
	xor	al,ch
	test	al,8h
	jne	valid_vretrace
	inc	di
	jne	loop_check_vretrace
	call	Get_BIOS_Ticks
	sub	eax,ds: dword ptr [timer_ticks]
	cmp	al,2h
	jb	loop_check_vretrace_1
	mov	ds: dword ptr [vertical_refresh],0FFFFFFFFh
	mov	ds: dword ptr [horizontal_refresh],0FFFFFFFFh
	jmp	no_retrace
valid_vretrace:
	mov	cx,N_VER_SAMPLE
pre_vretrace:
	in	al,dx
	test	al,8h
	jne	pre_vretrace
pre_von:
	in	al,dx
	test	al,8h
	je	pre_von
	call	Timer_On
loop_check_vertical_on:
	in	al,dx
	test	al,8h
	jne	loop_check_vertical_on
loop_check_vertical_off:
	in	al,dx
	test	al,8h
	je	loop_check_vertical_off
	loop	loop_check_vertical_on
	call	Timer_Off
	push	dx
	mov	eax,ds: dword ptr [elapsed_time]
	shr	eax,6h
	imul	ecx,eax,0Bh
	xor	edx,edx
	mov	eax,1312500000d
	div	ecx
	mov	ds: dword ptr [vertical_refresh],eax
	pop	dx
	call	Save_Timer_Ticks
pre_vretrace3:
	in	al,dx
	test	al,8h
	je	pre_vretrace3
pre_von3:
	in	al,dx
	test	al,8h
	jne	pre_von3
	in	al,dx
	mov	ch,al
loop_check_hretrace_1:
	xor	di,di
loop_check_hretrace:
	in	al,dx
	xor	al,ch
	test	al,1h
	jne	valid_hretrace
	inc	di
	jne	loop_check_hretrace
	call	Get_BIOS_Ticks
	sub	eax,ds: dword ptr [timer_ticks]
	cmp	al,2h
	jb	loop_check_hretrace_1
entry_fail_hor:
	mov	ds: dword ptr [horizontal_refresh],0FFFFFFFFh
	jmp	no_retrace
valid_hretrace:
	mov	si,N_HOR_SAMPLE
	xor	di,di
	mov	ax,ds
	add	ax,SEGMENT_4
	mov	es,ax
	mov	bp,1h
	mov	ds: word ptr [offset_led_table],OFFSET led_table
loop_ext_hor_ret:
	mov	cx,N_HOR_LINE
pre_von1:
	in	al,dx
	test	al,8h
	je	pre_von1
pre_vretrace1:
	in	al,dx
	test	al,8h
	jne	pre_vretrace1
pre_von2:
	in	al,dx
	test	al,1h
	je	pre_von2
pre_vretrace2:
	in	al,dx
	test	al,1h
	jne	pre_vretrace2
	call	Timer_On
loop_check_horizontal_on:
	in	al,dx
	test	al,1h
	jne	loop_check_horizontal_off
	in	al,dx
	test	al,1h
	je	loop_check_horizontal_on
loop_check_horizontal_off:
	in	al,dx
	test	al,1h
	je	ari_loop
	in	al,dx
	test	al,1h
	jne	loop_check_horizontal_off
ari_loop:
	loop	loop_check_horizontal_on
	call	Timer_Off
	mov	eax,ds: dword ptr [elapsed_time]
	cmp	eax,ds: dword ptr [min_pit_hor]
	jae	valid_sample_hor_1
	inc	ds: word ptr [fail_hor_samples]
	cmp	ds: word ptr [fail_hor_samples],2d * N_HOR_SAMPLE
	jne	loop_ext_hor_ret
	push	ds
	pop	es
	jmp	entry_fail_hor
valid_sample_hor_1:
	stosd
	dec	bp
	jne	no_led_on
	mov	bp,LED_ON
	pusha
	mov	si,STATUS_LED
	call	Get_BIOS_Mem
	and	al,8Fh
	mov	di,ds: word ptr [offset_led_table]
	or	al,ds: byte ptr [di]
	call	Set_BIOS_Mem
	inc	di
	cmp	di,OFFSET led_table + 4h
	jne	no_reset_led_table
	mov	di,OFFSET led_table
no_reset_led_table:
	mov	ds: word ptr [offset_led_table],di
	mov	ah,KEY_FUNC_CHECK
	int	KEY_INTERRUPT
	popa
no_led_on:
	dec	si
	jne	loop_ext_hor_ret
	push	bx
	xor	si,si
	xor	bp,bp
	xor	ecx,ecx
	mov	edx,0FFFFFFFFh
loop_copy_test:
	mov	eax,es: dword ptr [si]
	cmp	eax,ecx
	jb	no_min_fo_1
	mov	ecx,eax
no_min_fo_1:
	cmp	eax,edx
	ja	no_max_fo
	mov	edx,eax
no_max_fo:	
	mov	es: dword ptr [si + N_HOR_SAMPLE * SIZEOF DWORD],eax
	xor	di,di
	xor	bx,bx
loop_add_val_sample:
	cmp	bx,bp
	je	add_sample
	cmp	eax,es: dword ptr [di + 2 * N_HOR_SAMPLE * SIZEOF DWORD]
	je	add_val_sample
	inc	bx
	add	di,SIZEOF DWORD + SIZEOF WORD
	jmp	loop_add_val_sample
add_val_sample:
	inc	es: word ptr [di + 2 * N_HOR_SAMPLE * SIZEOF DWORD + SIZEOF DWORD]
	jmp	next_val_sample
add_sample:
	inc	bp
	mov	es: dword ptr [di + 2 * N_HOR_SAMPLE * SIZEOF DWORD],eax
	mov	es: word ptr [di + 2 * N_HOR_SAMPLE * SIZEOF DWORD + SIZEOF DWORD],1h
next_val_sample:
	add	si,SIZEOF DWORD
	cmp	si,N_HOR_SAMPLE * SIZEOF DWORD
	jne	loop_copy_test
	mov	ds: dword ptr [max_fo],ecx
	mov	ds: dword ptr [min_fo],edx
	mov	ds: word ptr [n_samples_fo],bp
	pop	bx
	mov	si,2 * N_HOR_SAMPLE * SIZEOF DWORD + SIZEOF DWORD
	xor	cx,cx
loop_max_samples:
	lods	es: dword ptr [si]
	cmp	ax,cx
	jb	no_min_fo
	mov	cx,ax
no_min_fo:
	add	si,SIZEOF WORD
	dec	bp
	jne	loop_max_samples
	mov	ds: word ptr [max_samples],cx
	xor	eax,eax
	xor	si,si
loop_mean:
	add	eax,es: dword ptr [si]
	add	si,SIZEOF DWORD
	cmp	si,N_HOR_SAMPLE * SIZEOF DWORD
	jne	loop_mean
	mov	ecx,10000d
	mul	ecx
	mov	ecx,N_HOR_SAMPLE
	div	ecx
	xchg	eax,ebp
	push	bx
	xor	si,si
	xor	ecx,ecx
	xor	edi,edi
	mov	ebx,N_HOR_SAMPLE
loop_q_error:
	mov	eax,es: dword ptr [si]
	imul	eax,10000d
	sub	eax,ebp
	jnc	no_neg_mul
	neg	eax
no_neg_mul:
	mul	eax
	push	eax
	xchg	eax,edx
	xor	edx,edx	
	div	ebx
	add	edi,eax
	pop	eax
	div	ebx
	add	ecx,eax
	adc	edi,0h
	add	si,SIZEOF DWORD
	cmp	si,N_HOR_SAMPLE * SIZEOF DWORD
	jne	loop_q_error
	push	ebp
	xor	eax,eax
	mov	ebx,80000000h
sqrt_loop:
	mov	esi,eax
	or	esi,ebx
	push	eax
	mov	eax,esi
	mul	esi
	mov	ebp,eax
	pop	eax
	cmp	edx,edi
	ja 	next_bit
	jb	is_smaller
	cmp	ebp,ecx
	ja 	next_bit
is_smaller:
	or	eax,ebx
next_bit:
	shr	ebx,1h
	jne	sqrt_loop
	pop	ebp
	pop	bx
	mov	ecx,10000d * 100d
	mul	ecx
	div	ebp
	mov	ds: dword ptr [sm_val],eax
invalid_stat_hor:
	mov	cx,N_HOR_SAMPLE
	mov	eax,0FFFFFFFFh
	xor	si,si
loop_stat_hor:
	cmp	eax,es: dword ptr [si]
	jb	no_min_hor
	mov	eax,es: dword ptr [si]
	mov	di,si
no_min_hor:
	add	si,4h
	loop	loop_stat_hor
	cmp	eax,0FFFFFFFFh
	je	entry_fail_hor	
	mov	ebp,eax
	xor	edx,edx
	mov	ecx,N_HOR_SAMPLE SHL 1h
	div	ecx
	add	ebp,eax
	xor	si,si
	xor	ecx,ecx
	xor	ax,ax
loop_stat_hor_2:
	cmp	es: dword ptr [si],ebp
	ja	no_add_stat
	inc	ax
	add	ecx,es: dword ptr [si]
no_add_stat:	
	add	si,SIZEOF DWORD
	cmp	si,N_HOR_SAMPLE * SIZEOF DWORD
	jne	loop_stat_hor_2
	cmp	ax,1h
	jne	valid_n_hor
	mov	es: dword ptr [di],0FFFFFFFFh
	jmp	invalid_stat_hor
valid_n_hor:
	push	ecx
	mov	ds: word ptr [valid_sample_hor],ax
	push	ds
	pop	es
	imul	ecx,0Bh
	xchg	eax,edi
	xor	edx,edx
	mov	eax,0C8458800h
	mul	edi
	div	ecx
	mov	ds: dword ptr [horizontal_refresh],eax
	pop	eax
	xor	edx,edx
	movzx	ecx,ds: word ptr [valid_sample_hor]
	div	ecx
	mov	ds: word ptr [fo_pit],ax
	mov	ah,1h
	call	Get_Sequencer
	mov	cx,8h
	test	al,1h
	jne	width_8
	inc	cx
width_8:
	xor	ah,ah
	call	Get_CRTC
	add	ax,5h
	mov	si,ax
entry_bw:
	mul	cx	
	cmp	ds: byte ptr [bx].VESA_MODE_PANEL.VIDEO_MODE_MODEL,VESA_MODE_TEXT
	je	no_ht_correct
	cmp	ax,ds: word ptr [bx].VESA_MODE_PANEL.X_RES
	ja	no_ht_correct
	add	si,256d
	mov	ax,si
	jmp	entry_bw
no_ht_correct:
	mov	si,ds: word ptr [bx].VESA_MODE_PANEL.X_RES
	cmp	ds: byte ptr [bx].VESA_MODE_PANEL.VIDEO_MODE_MODEL,VESA_MODE_TEXT
	jne	no_mul_for_text_mode
	imul	si,cx
no_mul_for_text_mode:
	mov	bp,si
	shr	si,3h
	imul	si,3h
	add	si,bp
	cmp	ax,si
	jb	bandwidth_valid
	mov	ds: dword ptr [bandwidth],0FFFFFFFEh
	jmp	no_retrace
bandwidth_valid:
	movzx	eax,ax
	mul	ds: dword ptr [horizontal_refresh]
	mov	ecx,1000d
	div	ecx
	mov	ds: dword ptr [bandwidth],eax
	mov	bp,ds: word ptr [bx].VESA_MODE_PANEL.Y_RES
	cmp	ds: word ptr [bx].VESA_MODE_PANEL.VIDEO_MODE_MODEL,VESA_MODE_TEXT
	jne	no_correct_text_y_res
	mov	ah,CRTC_MAXIMUM_SCAN_LINE
	call	Get_CRTC
	and	ax,1Fh
	inc	ax
	imul	bp,ax
no_correct_text_y_res:
	mov	ah,CRTC_MAXIMUM_SCAN_LINE
	call	Get_CRTC
	test	al,CRTC_DOUBLE_SCAN
	je	no_retrace
	add	bp,bp
no_retrace:
	mov	si,STATUS_LED
	mov	al,ds: byte ptr [old_status_led]
	call	Set_BIOS_Mem
	mov	ah,KEY_FUNC_CHECK
	int	KEY_INTERRUPT
	call	Init_X_Vesa
	mov	cx,3h
	mov	dx,((TEXT_WIDTH - 1) SHL 8) + MAIN_WIN1_HEIGHT + 3h
	mov	si,OFFSET vga_message_009
	xor	di,di
	call	Extended_Box
	call	Draw_Adapter_Info
	CENTER_BOX 62d,12d
	mov	si,OFFSET vga_message_204
	mov	di,OFFSET vga_message_255
	call	Extended_Box
	add	cx,0D02h
	mov	si,OFFSET vga_message_205
	call	Write_VGA_Message
	add	ch,0Ch
	mov	ds: word ptr [start_xy],cx
	mov	ds: byte ptr [color_base_mem],EXTRA_COLOR
	call	VESA_Command_02_01
	call	Next_Line
	mov	al,ds: byte ptr [status_flag_2]
	and	al,VESA_MEMORY_MODE
	mov	si,OFFSET vga_message_206
	call	Write_Index_String
	mov	eax,ds: dword ptr [vertical_refresh]
	cmp	eax,0FFFFFFFFh
	jne	valid_vertical_retrace
	mov	al,6h
invalid_horizontal_retrace:
	mov	si,OFFSET vga_message_025
invalid_horizontal_retrace_1:
	call	Write_Same_Message
	jmp	loop_retrace_1
valid_vertical_retrace:
	call	VESA_Command_04_01
	mov	eax,ds: dword ptr [horizontal_refresh]
	cmp	eax,0FFFFFFFFh
	jne	valid_Horizontal_retrace
	mov	al,5h
	cmp	ds: word ptr [fail_hor_samples],0h
	je	invalid_horizontal_retrace
	mov	si,OFFSET vga_message_262
	jmp	invalid_horizontal_retrace_1
valid_horizontal_retrace:
	call	VESA_Command_04_01
	mov	si,OFFSET vga_message_214
	cmp	ds: dword ptr [bandwidth],0FFFFFFFEh
	je	emu_vga
	mov	eax,ds: dword ptr [horizontal_refresh]
	imul	eax,100d
	xor	edx,edx
	div	ds: dword ptr [vertical_refresh]
	cmp	ax,bp
	ja	valid_bandwidth
	cmp	ds: dword ptr [vertical_refresh],7500d
	ja	valid_bandwidth
	mov	dx,bp
	shr	dx,4h
	shr	bp,2h
	add	bp,dx
	cmp	ax,bp
	jbe	valid_bandwidth
	mov	si,OFFSET vga_message_213
emu_vga:
	mov	al,2h
	call	Write_Same_Message	
	jmp	write_sis
valid_bandwidth:
	mov	eax,ds: dword ptr [bandwidth]
	call	VESA_Command_04_01
	mov	si,OFFSET vga_message_206
	mov	di,1h
	cmp	ds: dword ptr [vertical_refresh],5000d
	jb	write_interlace
	mov	eax,ds: dword ptr [horizontal_refresh]
	imul	eax,100d
	xor	edx,edx
	div	ds: dword ptr [vertical_refresh]
	cmp	ax,bp
	jb	write_interlace	
	dec	di
write_interlace:
	xchg	ax,di
	call	Write_Index_String
write_sis:
	movzx	eax,ds: word ptr [valid_sample_hor]
	imul	eax,10000d
	xor	edx,edx
	mov	ebp,N_HOR_SAMPLE
	div	ebp
	mov	ds: byte ptr [decimal_digits],2h
	call	Write_Decimal_Number_Left32
	add	ch,2h
	mov	si,OFFSET vga_message_188
	call	Write_Simple_VGA_Message
	inc	ch
	mov	si,OFFSET vga_message_215
	call	Write_Simple_VGA_Message
	inc	ch
	mov	eax,ds: dword ptr [sm_val]
	mov	ds: byte ptr [decimal_digits],4h
	call	Write_Decimal_Number_Left32
	call	Next_Line
	mov	ax,ds: word ptr [valid_sample_hor]
	call	Write_Dec_Num_Left16
	mov	si,OFFSET vga_message_273
	call	Write_Simple_vga_message
	mov	ax,N_HOR_SAMPLE
	call	Write_Dec_Num_Left16
	mov	ax,ds: word ptr [fail_hor_samples]
	or	ax,ax
	je	loop_retrace_1
	inc	ch
	mov	si,OFFSET vga_message_261
	call	Write_Simple_VGA_Message
	inc	ch
	call	Write_Dec_Num_Left16
loop_retrace_1:
	mov	ds: byte ptr [color_base_mem],COLOR_BASE
loop_retrace:
	call	Get_Key
	cmp	ax,D_KEY
	jne	test_command_4_esc
	call	Save_Current_Video_Page
	call	Clear_Screen
	mov	si,OFFSET vga_message_260
	cmp	ds: dword ptr [horizontal_refresh],0FFFFFFFFh
	je	no_d_key
	mov	eax,ds: dword ptr [min_fo]
	cmp	eax,ds: dword ptr [max_fo]
	jne	draw_distr
	mov	si,OFFSET vga_message_256
no_d_key:
	call	View_Alert_Message
	jmp	exit_view_distr
draw_distr:
	mov	si,OFFSET vga_message_257
	mov	di,OFFSET vga_message_010
	xor	cx,cx
	mov	dx,((TEXT_WIDTH - 1h) SHL 8h) + TEXT_HEIGHT - 1h
	call	Extended_Box
	mov	si,OFFSET vga_message_259
	add	cx,501h
	call	Write_VGA_Message
	mov	ds: byte ptr [color_base_mem],EXTRA_COLOR
	mov	ch,0Fh
	mov	ds: word ptr [start_xy],cx
	push	bx
	mov	bx,OFFSET vesa_buffer_func_0.VbeInfoBlock.OemStringPtr
	mov	dl,MAX_VENDOR_STRING
	call	Draw_OEM_String
	pop	bx
	call	Next_Line
	call	VESA_Command_02_01
	call	Next_Line
	mov	ax,ds: word ptr [valid_sample_hor]
	call	Write_Dec_Num_Left16
	mov	si,OFFSET VGA_Message_273
	call	Write_Simple_VGA_Message
	mov	ax,N_HOR_SAMPLE
	call	Write_Dec_Num_Left16
	mov	ax,ds: word ptr [fail_hor_samples]
	or	ax,ax
	je	loop_retrace_2
	inc	ch
	mov	si,OFFSET vga_message_261
	call	Write_Simple_VGA_Message
	inc	ch
	call	Write_Dec_Num_Left16
loop_retrace_2:
	call	Next_Line
	mov	ds: word ptr [distr_zoom],100d
	mov	ds: word ptr [distr_shift],0d
	mov	si,OFFSET vga_message_272
	call	Write_Simple_VGA_Message
	mov	ax,ds: word ptr [fo_pit]
	call	Write_Dec_Num_Left16
	mov	si,OFFSET vga_message_268
	call	Write_Simple_VGA_Message
	mov	si,OFFSET vga_message_258
	call	Write_Simple_VGA_Message
	mov	eax,ds: dword ptr [min_fo]
	call	Write_Dec_Num_Left32
	mov	si,OFFSET vga_message_268
	call	Write_Simple_VGA_Message
	mov	si,OFFSET vga_message_265
	call	Write_Simple_VGA_Message
	mov	eax,ds: dword ptr [max_fo]
	call	Write_Dec_Num_Left32
	mov	si,OFFSET vga_message_268
	call	Write_Simple_VGA_Message
	mov	si,OFFSET vga_message_266
	call	Write_Simple_VGA_Message
	mov	ax,ds: word ptr [max_samples]
	call	Write_Dec_Num_Left16
	mov	si,OFFSET vga_message_268
	call	Write_Simple_VGA_Message
	mov	si,OFFSET vga_message_267
	call	Write_Simple_VGA_Message
	mov	ax,ds: word ptr [n_samples_fo]
	call	Write_Dec_Num_Left16
	mov	ds: byte ptr [color_base_mem],COLOR_BASE
	mov	cx,6h
	mov	si,OFFSET vga_message_274
	call	Write_VGA_Message
	mov	cl,7h
loop_ver_distr:
	mov	ch,4h
	mov	ah,cl
	mov	al,'³'
	and	ah,3h
	cmp	ah,1h
	jne	no_180
	mov	al,'´'
no_180:
	call	Write_Char
	inc	cx
	cmp	cl,37d
	jne	loop_ver_distr
	xor	ch,ch
	mov	si,OFFSET vga_message_275
	call	Write_VGA_Message
reset_view_4:
	mov	ds: word ptr [distr_zoom],100d
	mov	ds: word ptr [distr_shift],0d
rewrite_view:
	mov	ds: byte ptr [color_base_mem],EXTRA_COLOR
	mov	cx,0F05h
	mov	si,OFFSET vga_message_269
	call	Write_Simple_VGA_Message
	mov	ax,ds: word ptr [distr_zoom]
	call	Write_Dec_Num_Left16
	mov	si,OFFSET vga_message_188
	call	Write_Simple_VGA_Message
	mov	si,OFFSET vga_message_268
	call	Write_Simple_VGA_Message
	mov	si,OFFSET vga_message_270
	call	Write_Simple_VGA_Message
	mov	ax,ds: word ptr [distr_shift]
	test	ah,80h
	je	positive_shift
	push	ax
	mov	al,'-'
	call	Write_Char
	pop	ax
	neg	ax
positive_shift:
	call	Write_Dec_Num_Left16
	mov	si,OFFSET vga_message_118
	mov	ds: byte ptr [si + 1h],5d
	call	Write_VGA_Message
	mov	eax,ds: dword ptr [max_fo]
	sub	eax,ds: dword ptr [min_fo]
	cmp	ax,N_DISTR_DATA
	jae	valid_minmax_fo
	xchg	eax,ecx
	sub	cx,N_DISTR_DATA
	neg	cx
	shr	cx,1h
	mov	eax,ds: dword ptr [min_fo]
	sub	eax,ecx
	mov	ds: dword ptr [min_fo_tmp],eax
	mov	eax,ds: dword ptr [max_fo]
	add	eax,ecx
	mov	ds: dword ptr [max_fo_tmp],eax
	jmp	continue_fo_wr_1
valid_minmax_fo:
	mov	eax,ds: dword ptr [min_fo]
	mov	ds: dword ptr [min_fo_tmp],eax
	mov	eax,ds: dword ptr [max_fo]
	mov	ds: dword ptr [max_fo_tmp],eax
continue_fo_wr_1:
	movsx	eax,ds: word ptr [distr_shift]
	add	ds: dword ptr [min_fo_tmp],eax
	add	ds: dword ptr [max_fo_tmp],eax
	mov	eax,ds: dword ptr [max_fo_tmp]
	sub	eax,ds: dword ptr [min_fo_tmp]
	mov	ecx,100d	
	mul	ecx
	mov	cx,ds: word ptr [distr_zoom]
	div	ecx
	shr	eax,1h
	mov	ecx,ds: dword ptr [max_fo_tmp]
	sub	ecx,ds: dword ptr [min_fo_tmp]
	shr	ecx,1h
	sub	eax,ecx
	add	ds: dword ptr [max_fo_tmp],eax
	sub	ds: dword ptr [min_fo_tmp],eax
	mov	cx,N_DISTR_DATA
	mov	di,OFFSET distribution_data
	xor	ax,ax
	rep	stosw
	mov	ax,ds: word ptr [max_samples]
	mov	cx,100d
	mul	cx
	mov	cx,ds: word ptr [distr_zoom]
	div	cx
	mov	ds: word ptr [max_samples_tmp],ax
	mov	ax,ds
	add	ax,SEGMENT_4
	mov	es,ax
	mov	cx,ds: word ptr [n_samples_fo]
	mov	si,2 * N_HOR_SAMPLE * SIZEOF DWORD
loop_fo_distr:
	lods	es: dword ptr [si]
	cmp	eax,ds: dword ptr [min_fo_tmp]
	jb	next_fo_val
	cmp	eax,ds: dword ptr [max_fo_tmp]
	ja	next_fo_val
	sub	eax,ds: dword ptr [min_fo_tmp]
	mov	edi,N_DISTR_DATA - 1h
	mul	edi
	mov	edi,ds: dword ptr [max_fo_tmp]
	sub	edi,ds: dword ptr [min_fo_tmp]
	xor	edx,edx
	div	edi
	xchg	ax,di
	add	di,di
	mov	ax,es: word ptr [si]
	add	ds: word ptr [di + distribution_data],ax
next_fo_val:
	add	si,SIZEOF WORD
	loop	loop_fo_distr
	or	ds: byte ptr [status_flag_0],FLAG_THOUSANDS
	mov	cx,126h
	mov	si,OFFSET vga_message_118
	mov	ds: byte ptr [si + 1h],78d
	call	Write_VGA_Message
	mov	ch,5h
	xor	bp,bp
loop_hor_distr_val:
	mov	ax,ds: word ptr [max_fo_tmp]
	sub	ax,ds: word ptr [min_fo_tmp]
	mul	bp
	mov	si,N_DISTR_DATA / 2d
	div	si
	add	ax,ds: word ptr [min_fo_tmp]
	sub	ax,ds: word ptr [fo_pit]
	test	ah,80h
	je	pos_distr_val
	neg	ax
	cmp	ax,9999d
	ja	entry_val_1
	push	ax
	call	Size_Of_Number16
	sub	ch,ds: byte ptr [number_count]
	mov	al,'-'
	call	Write_Char
	dec	ch
	add	ch,ds: byte ptr [number_count]
	pop	ax
pos_distr_val:
	cmp	ax,9999d
	jbe	valid_val_3
entry_val_1:
	sub	ch,4h
	mov	si,OFFSET vga_message_276
	mov	ds: byte ptr [si + 1h],5h
	call	Write_Simple_VGA_Message
	dec	ch
	jmp	valid_val_4
valid_val_3:
	call	Write_Dec_Num16
valid_val_4:
	add	bp,9h
	add	ch,9h
	cmp	ch,86d
	jne	loop_hor_distr_val
	mov	bp,4h
	mov	cl,21h
loop_ver_distr_val:
	mov	ch,1h
	mov	si,OFFSET vga_message_118
	mov	ds: byte ptr [si + 1h],3h
	call	Write_VGA_Message
	mov	ch,3h
	mov	ax,ds: word ptr [max_samples_tmp]
	mul	bp
	mov	si,MAX_DISTR_SAMPLE / 2d
	div	si
	cmp	ax,999d
	jbe	valid_val_1
	mov	ch,1h
	mov	si,OFFSET vga_message_276
	mov	ds: byte ptr [si + 1h],3h
	call	Write_VGA_Message
	jmp	next_val_1	
valid_val_1:
	call	Write_Dec_Num16
next_val_1:
	add	bp,4h
	sub	cl,4h
	cmp	cl,5h
	jne	loop_ver_distr_val
	mov	si,OFFSET distribution_data
	mov	cx,N_DISTR_DATA
loop_norm_data:
	lodsw
	or	ax,ax
	je	next_distr_data_1
	mov	dx,MAX_DISTR_SAMPLE + 1h
	cmp	ax,ds: word ptr [max_samples_tmp]
	ja	over_max_sample
	dec	dx
	mul	dx
	mov	di,ds: word ptr [max_samples_tmp]
	div	di
	xchg	ax,dx
over_max_sample:
	mov	ds: word ptr [si - 2h],dx
next_distr_data_1:
	loop	loop_norm_data
	mov	di,(5h + TEXT_WIDTH * 36d) SHL 1h
	mov	cx,MAX_DISTR_SAMPLE / 2d
loop_write_data_distr:
	mov	bp,N_DISTR_DATA / 2h
	mov	si,OFFSET distribution_data
	mov	ah,ND_COLOR
loop_write_x_coo:
	mov	dl,ds: byte ptr [si]
	xor	al,al
	or	dl,dl
	je	first_val_distr_1
	inc	ax
	cmp	al,dl
	je	first_val_distr
	inc	ax
first_val_distr:
	sub	ds: byte ptr [si],al
first_val_distr_1:
	mov	dl,al
	add	dl,dl
	add	al,dl
	push	ax
	add	si,2h	
	mov	dl,ds: byte ptr [si]
	xor	al,al
	or	dl,dl
	je	second_val_distr_1
	inc	ax
	cmp	al,dl
	je	second_val_distr
	inc	ax
second_val_distr:
	sub	ds: byte ptr [si],al
second_val_distr_1:
	add	si,2h
	pop	dx
	add	al,dl
	cmp	cl,1h
	jne	no_last_distr_line
	cmp	ds: byte ptr [si - 4h],1h
	jne	test_over_distr_1
	mov	dl,9d
	cmp	al,6d
	je	over_1
	mov	dl,10d
	cmp	al,7d
	je	over_1
	mov	dl,11d
	cmp	ds: byte ptr [si - 2h],1h
	jne	over_1	
	mov	dl,12d
over_1:
	jmp	over_2
test_over_distr_1:
	cmp	ds: byte ptr [si - 2h],1h
	jne	no_last_distr_line
	mov	dl,13d
	cmp	al,2d
	je	over_2
	mov	dl,14d
	cmp	al,5d
	je	over_2
	mov	dl,15d
over_2:
	mov	al,dl
no_last_distr_line:
	add	al,0F0h
	mov	fs: word ptr [di],ax
	add	di,2h		
	dec	bp
	jne	loop_write_x_coo
	sub	di,(TEXT_WIDTH * 2h) + N_DISTR_DATA
	dec	cx
	jne	loop_write_data_distr
	and	ds: byte ptr [status_flag_0],NOT FLAG_THOUSANDS
	push	ds
	pop	es
loop_key_d4:
	call	Get_Key
	cmp	ax,F1_KEY
	jne	key_d41
	push	bx
	mov	bx,OFFSET vga_message_271
	mov	ds: byte ptr [color_base_mem],COLOR_BASE
	mov	ds: byte ptr [n_line_help],HELP6_LINE + 4h
	call	Show_Help
	pop	bx
	mov	ds: byte ptr [color_base_mem],EXTRA_COLOR
	jmp	loop_key_d4
key_d41:
	cmp	ax,DEL_KEY
	je	reset_view_4
	cmp	ax,LEFT_KEY
	jne	key_d42
	dec	ds: word ptr [distr_shift]
	jmp	rewrite_view
key_d42:
	cmp	ax,RIGHT_KEY
	jne	key_d43
	inc	ds: word ptr [distr_shift]
	jmp	rewrite_view
key_d43:
	cmp	ax,CTRL_LEFT_KEY
	jne	key_d44
	sub	ds: word ptr [distr_shift],10d
	jmp	rewrite_view
key_d44:
	cmp	ax,CTRL_RIGHT_KEY
	jne	key_d45
	add	ds: word ptr [distr_shift],10d
	jmp	rewrite_view
key_d45:
	cmp	ax,PLUS_KEY
	jne	key_d46
	cmp	ds: word ptr [distr_zoom],400d
	je	loop_key_d4
	add	ds: word ptr [distr_zoom],10d	
	jmp	rewrite_view
key_d46:
	cmp	ax,MINUS_KEY
	jne	key_d47
	cmp	ds: word ptr [distr_zoom],10d
	je	loop_key_d4
	sub	ds: word ptr [distr_zoom],10d
	jmp	rewrite_view
key_d47:
	cmp	ax,ESC_KEY
	jne	loop_key_d4
	mov	ds: byte ptr [color_base_mem],COLOR_BASE
exit_view_distr:
	call	Restore_Current_Video_Page
	jmp	loop_retrace
test_command_4_esc:
	cmp	ax,ESC_KEY
	jne	loop_retrace
	popa
	ret

;#############################################################################

	VESA_Command_04_01:

;#############################################################################

	mov	si,OFFSET vga_message_073
	mov	ds: byte ptr [decimal_digits],2h
	cmp	cl,13h
	jne	w_ver
	mov	si,OFFSET vga_message_090
	inc	ds: byte ptr [decimal_digits]
w_ver:
	cmp	cl,14h
	jne	h_ver
	mov	si,OFFSET vga_message_078
	inc	ds: byte ptr [decimal_digits]
h_ver:	
	or	ds: byte ptr [status_flag_0],FLAG_THOUSANDS
	call	Size_Of_Number32
	and	ds: byte ptr [status_flag_0],NOT FLAG_THOUSANDS
	add	ch,ds: byte ptr [number_count]
	call	Write_Decimal_Number32
	add	ch,2h
exit_refresh:
	call	Write_VGA_Message
	call	Next_Line
	ret
