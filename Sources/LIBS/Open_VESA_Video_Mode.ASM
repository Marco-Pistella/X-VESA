;#############################################################################

;	DS:BX = Pointer to vesa_mode_info video mode

	Open_VESA_Video_Mode:

;	CARRY = 0 -> VESA video mode open
;	CARRY = 1 -> VESA video mode failure

;#############################################################################

	pusha
	and	ds: byte ptr [status_flag_2],NOT CORRECT_BPSL
	mov	ds: byte ptr [error_open_vesa_video_mode],START_OPEN_VESA_ERROR
	mov	ax,(VESA_ID SHL 8h) + VESA_FUNC_RETURN_MODE_INFORMATION
	mov	cx,ds: word ptr [bx].VESA_MODE_PANEL.VIDEO_MODE
	mov	di,OFFSET vesa_buffer_func_1
	push	bx
	VIDEO_CALL
	cmp	ax,VESA_ID
	pop	bx
	je	valid_vesa_func_1_1
	mov	si,OFFSET vga_message_144
exit_open_error:
	lea	di,ds: word ptr [bx].VESA_MODE_PANEL.VRAM_SIZE_BANKED
	test	ds: byte ptr [status_flag_2],VESA_MEMORY_MODE
	je	set_open_error_banked
	lea	di,ds: word ptr [bx].VESA_MODE_PANEL.VRAM_SIZE_LINEAR
set_open_error_banked:
	cmp	ds: dword ptr [di],0FFFFFFFFh
	je	no_set_error_for_unsupported
	movzx	eax,ds: byte ptr [error_open_vesa_video_mode]
	mov	ds: dword ptr [di],eax
	or	ds: byte ptr [di + 3h],FLAG_OPEN_VESA_ERROR
no_set_error_for_unsupported:
	test	ds: byte ptr [status_flag_4],AUTO_OPEN_VESA
	jne	fail_open_vesa
	call	View_Alert_Message
fail_open_vesa:
	and	ds: byte ptr [status_flag_4],(NOT FONT_TABLE_LOAD) AND (NOT VALID_VESA_IO) AND (NOT VALID_VESA_ADDRESSING)
	stc
	popa
	ret
valid_vesa_func_1_1:
	mov	ds: byte ptr [error_open_vesa_video_mode],ERR_VESA_OPEN_01
	mov	si,OFFSET vga_message_155
	test	ds: byte ptr [di].ModeInfoBlock.ModeAttributes,VESA_HARDWARE_SUPPORT
	je	exit_open_error
	test	ds: byte ptr [status_flag_4],VALID_VESA_IO
	je	go_to_next_vesa_check
	mov	si,OFFSET vga_message_156
	mov	ax,MIN_X_RES_TEXT
	mov	cx,MIN_Y_RES_TEXT
	cmp	ds: byte ptr [bx].VESA_MODE_PANEL.VIDEO_MODE_MODEL,VESA_MODE_TEXT
	je	check_text_res
	mov	ax,MIX_X_RES_GRAPHIC
	mov	cx,MIX_Y_RES_GRAPHIC
check_text_res:
	mov	ds: byte ptr [error_open_vesa_video_mode],ERR_VESA_OPEN_02
	cmp	ax,ds: word ptr [bx].VESA_MODE_PANEL.X_RES
	ja	exit_open_error
	mov	ds: byte ptr [error_open_vesa_video_mode],ERR_VESA_OPEN_03
	cmp	cx,ds: word ptr [bx].VESA_MODE_PANEL.Y_RES
	ja	exit_open_error
	cmp	ds: byte ptr [bx].VESA_MODE_PANEL.VIDEO_MODE_MODEL,VESA_MODE_TEXT
	je	next_check_open_vesa
	mov	ds: byte ptr [error_open_vesa_video_mode],ERR_VESA_OPEN_04
	test	ds: byte ptr [bx].VESA_MODE_PANEL.X_RES,1h
	jne	exit_open_error
next_check_open_vesa:
	mov	ds: byte ptr [error_open_vesa_video_mode],ERR_VESA_OPEN_05
	mov	si,OFFSET vga_message_157
	mov	al,ds: byte ptr [bx].VESA_MODE_PANEL.COLOR_BPP
	mov	ah,ds: byte ptr [bx].VESA_MODE_PANEL.VIDEO_MODE_MODEL
	cmp	ah,VESA_MODE_TEXT
	je	check_bpsl
	cmp	ah,VESA_MODE_PLANAR
	jne	check_bpp_packet
	cmp	al,VESA_VIDEO_MODE_4BPP
	jne	exit_open_error
	jmp	check_bpsl
check_bpp_packet:
	cmp	ah,VESA_MODE_PACKET
	jne	check_bpp_direct_color
	cmp	al,VESA_VIDEO_MODE_8BPP
	jne	exit_open_error
	jmp	check_bpsl
check_bpp_direct_color:
	cmp	ah,VESA_MODE_DIRECT_COLOR
	jne	exit_open_error
	cmp	al,VESA_VIDEO_MODE_8BPP
	jbe	exit_open_error
	mov	cl,ds: byte ptr [bx].VESA_MODE_PANEL.MEMORY_BPP
	cmp	cl,VESA_VIDEO_MODE_32BPP
	ja	exit_open_error
	mov	ds: byte ptr [error_open_vesa_video_mode],ERR_VESA_OPEN_06
	mov	si,OFFSET vga_message_158
	cmp	ds: byte ptr [di].ModeInfoBlock.MemoryModel,VESA_MODE_PACKET
	jne	valid_mask_vesa12
	push	si
	push	di
	mov	cx,VESA_SIZE_MASK
	mov	si,OFFSET default_direct_color_mask
	mov	di,OFFSET dc_red_size
	cmp	al,VESA_VIDEO_MODE_15BPP
	je	valid_mask_vesa1
	mov	si,OFFSET default_direct_color_mask + VESA_SIZE_MASK
	cmp	al,VESA_VIDEO_MODE_16BPP
	je	valid_mask_vesa1
	mov	si,OFFSET default_direct_color_mask + (VESA_SIZE_MASK SHL 1h)
	cmp	al,VESA_VIDEO_MODE_24BPP
	je	valid_mask_vesa1
	cmp	al,VESA_VIDEO_MODE_32BPP
	jne	exit_open_error_1
valid_mask_vesa1:
	rep	movsb
	pop	di
	pop	si
	jmp	check_bpsl
exit_open_error_1:
	pop	di
	pop	si
	jmp	exit_open_error
valid_mask_vesa12:
	push	si
	lea	si,ds: byte ptr [di].ModeInfoBlock.RedMaskSize
	call	Create_Direct_Color_Map_Mask
	pop	si
	jc	exit_open_error
check_bpsl:
	mov	ax,ds: word ptr [di].ModeInfoBlock.BytesPerScanLine
	call	Check_Bytes_Per_Scan_Line
	cmp	ax,ds: word ptr [di].ModeInfoBlock.BytesPerScanLine
	je	check_lp_open	
	or	ds: byte ptr [status_flag_2],CORRECT_BPSL
check_lp_open:
	mov	ds: word ptr [current_bpsl],ax
go_to_next_vesa_check:
	test	ds: byte ptr [status_flag_2],VESA_MEMORY_MODE
	jne	open_linear_memory_model
	test	ds: byte ptr [status_flag_4],VALID_VESA_ADDRESSING
	je	valid_segment_open
	mov	ds: byte ptr [error_open_vesa_video_mode],ERR_VESA_OPEN_07
	mov	si,OFFSET vga_message_161
	test	ds: byte ptr [di].ModeInfoBlock.ModeAttributes,VESA_BANKED_MODE
	jne	exit_open_error
	mov	ds: byte ptr [error_open_vesa_video_mode],ERR_VESA_OPEN_08
	mov	ax,ds: word ptr [di].ModeInfoBlock.WinAAttributes
	xor	bp,bp
	and	ax,(VESA_WINDOW_RW SHL 8h) + VESA_WINDOW_RW
	cmp	al,VESA_WINDOW_RW
	je	valid_win_mode
	inc	bp
	cmp	ah,VESA_WINDOW_RW
	je	valid_win_mode
	inc	bp
	or	al,ah
	cmp	al,VESA_WINDOW_RW
	jne	exit_open_error
valid_win_mode:
	test	ds: byte ptr [status_flag_2],VESA_WINDOW_MODE
	je	ok_routine_set_bank
	add	bp,3h
	mov	ds: byte ptr [error_open_vesa_video_mode],ERR_VESA_OPEN_09
	mov	si,OFFSET vga_message_173
	cmp	ds: dword ptr [di].ModeInfoBlock.WinFuncPtr,0h
	je	exit_open_error
	push	ds: dword ptr [di].ModeInfoBlock.WinFuncPtr
	pop	ds: dword ptr [current_call_vesa_pointer]
ok_routine_set_bank:
	add	bp,bp
	mov	ax,ds: word ptr [bp + set_bank_routine]
	mov	ds: word ptr [set_bank_default],ax
	mov	ds: byte ptr [error_open_vesa_video_mode],ERR_VESA_OPEN_10
	mov	si,OFFSET vga_message_162
	movzx	ax,ds: byte ptr [bx].VESA_MODE_PANEL.WINDOW_SIZE
	or	ax,ax
	je	exit_open_error
	mov	ds: word ptr [segment_size],ax
	movzx	edx,ax
	shl	edx,0Ah
	mov	ds: dword ptr [segment_bound],edx
	mov	ds: byte ptr [error_open_vesa_video_mode],ERR_VESA_OPEN_11
	mov	si,OFFSET vga_message_163
	movzx	cx,ds: byte ptr [bx].VESA_MODE_PANEL.WINDOW_GRANULARITY
	or	cx,cx
	je	exit_open_error
	mov	ds: byte ptr [error_open_vesa_video_mode],ERR_VESA_OPEN_12
	xor	dx,dx
	div	cx
	or	dx,dx
	jne	exit_open_error
	mov	ds: word ptr [granularity_units_per_bank],ax
	mov	ds: byte ptr [error_open_vesa_video_mode],ERR_VESA_OPEN_13
	mov	si,OFFSET vga_message_164
	mov	dx,ds: word ptr [di].ModeInfoBlock.WinASegment
	mov	ax,ds: word ptr [di].ModeInfoBlock.WinBSegment
	test	ds: byte ptr [di].ModeInfoBlock.WinAAttributes,VESA_WINDOW_RW
	je	no_check_wina_segment
	test	ds: byte ptr [di].ModeInfoBlock.WinBAttributes,VESA_WINDOW_RW
	je	no_check_winb_segment
	cmp	ax,dx
	jne	exit_open_error
no_check_wina_segment:
	xchg	ax,dx
no_check_winb_segment:
	or	dx,dx
	je	exit_open_error
	mov	cx,0A000h
	cmp	ds: byte ptr [bx].VESA_MODE_PANEL.VIDEO_MODE_MODEL,VESA_MODE_TEXT
	jne	check_graphic_segment
	mov	ch,0B8h
	test	ds: byte ptr [di].ModeInfoBlock.ModeAttributes,VESA_MONO_MODE
	jne	check_graphic_segment
	mov	ch,0B0h
check_graphic_segment:
	mov	ds: word ptr [banked_segment],dx
	cmp	dx,cx
	je	valid_segment_open
	test	ds: byte ptr [status_flag_4],AUTO_OPEN_VESA
	jne	force_segment_auto
	pusha
	mov	bx,OFFSET vga_message_028
	mov	di,OFFSET vga_message_160
	mov	si,OFFSET vga_message_165
	call	Show_Message
	popa
loop_key_segment:
	call	Get_Key
	cmp	ax,N_KEY
	je	valid_segment_open
	cmp	ax,Y_KEY
	jne	loop_key_segment
force_segment_auto:
	mov	ds: word ptr [banked_segment],cx
valid_segment_open:
	push	bx
	mov	bx,ds: word ptr [bx].VESA_MODE_PANEL.VIDEO_MODE
	xor	bp,bp
entry_open_vesa_mode:
	mov	ds: byte ptr [error_open_vesa_video_mode],ERR_VESA_OPEN_14
	mov	si,OFFSET vga_message_166
	mov	ax,(VESA_ID SHL 8h) + VESA_FUNC_OPEN_VIDEO_MODE
	VIDEO_CALL
	pop	bx
	cmp	ax,VESA_ID
	je	valid_vesa_open_mode
	call	Init_X_Vesa
	jmp	exit_open_error
open_linear_memory_model:
	mov	ds: byte ptr [error_open_vesa_video_mode],ERR_VESA_OPEN_15
	mov	si,OFFSET vga_message_168
	test	ds: byte ptr [status_flag_0],FLAG_V86_ON
	jne	exit_open_error
	mov	ds: byte ptr [error_open_vesa_video_mode],ERR_VESA_OPEN_16
	mov	si,OFFSET vga_message_169
	test	ds: byte ptr [status_flag_2],A20_ENABLED
	je	exit_open_error
	mov	ds: byte ptr [error_open_vesa_video_mode],ERR_VESA_OPEN_17
	mov	si,OFFSET vga_message_170
	cmp	ds: byte ptr [vesa_buffer_func_0 + 1].VbeInfoBlock.VbeVersion,VESA_LEGACY
	jbe	exit_open_error
	mov	ds: byte ptr [error_open_vesa_video_mode],ERR_VESA_OPEN_18
	mov	si,OFFSET vga_message_171
	test	ds: byte ptr [di].ModeInfoBlock.ModeAttributes,VESA_LINEAR_MODE
	je	exit_open_error
	mov	ds: byte ptr [error_open_vesa_video_mode],ERR_VESA_OPEN_19
	mov	si,OFFSET vga_message_119
	cmp	ds: byte ptr [bx].VESA_MODE_PANEL.VIDEO_MODE_MODEL,VESA_MODE_TEXT
	je	exit_open_error
	cmp	ds: byte ptr [bx].VESA_MODE_PANEL.VIDEO_MODE_MODEL,VESA_MODE_PLANAR
	je	exit_open_error
	test	ds: byte ptr [status_flag_4],VALID_VESA_ADDRESSING
	je	valid_linear_addressing
	mov	ds: byte ptr [error_open_vesa_video_mode],ERR_VESA_OPEN_20
	mov	si,OFFSET vga_message_172
	mov	eax,ds: dword ptr [di].ModeInfoBlock.PhysBasePtr
	mov	ds: dword ptr [current_linear_vram_address],eax
	cmp	eax,1048576d
	jbe	exit_open_error
valid_linear_addressing:
	test	ds: byte ptr [status_flag_4],VALID_VESA_IO
	je	no_check_vesa3_options
	cmp	ds: byte ptr [vesa_buffer_func_0 + 1].VbeInfoBlock.VbeVersion,VESA2
	jbe	no_check_vesa3_options
	mov	ax,ds: word ptr [di].ModeInfoBlock.LinBytesPerScanLine
	call	Check_Bytes_Per_Scan_Line
	cmp	ax,ds: word ptr [di].ModeInfoBlock.LinBytesPerScanLine
	je	check_lp_open_linear
	test	ds: byte ptr [status_flag_2],CORRECT_BPSL
	jne	check_lp_open_linear
	mov	ax,ds: word ptr [di].ModeInfoBlock.BytesPerScanLine
	call	Check_Bytes_Per_Scan_Line
	cmp	ax,ds: word ptr [di].ModeInfoBlock.BytesPerScanLine
	je	check_lp_open_linear
	or	ds: byte ptr [status_flag_2],CORRECT_BPSL
check_lp_open_linear:
	and	ds: byte ptr [status_flag_2],NOT CORRECT_BPSL
	mov	ds: word ptr [current_bpsl],ax
	cmp	ds: byte ptr [bx].VESA_MODE_PANEL.VIDEO_MODE_MODEL,VESA_MODE_DIRECT_COLOR
	jne	no_check_vesa3_options
	lea	si,ds: byte ptr [di].ModeInfoBlock.LinRedMaskSize
	call	Create_Direct_Color_Map_Mask
	mov	si,OFFSET vga_message_158
	mov	ds: byte ptr [error_open_vesa_video_mode],ERR_VESA_OPEN_21
	jc	exit_open_error
no_check_vesa3_options:
	push	bx
	mov	bx,ds: word ptr [bx].VESA_MODE_PANEL.VIDEO_MODE
	or	bh,40h
	xor	bp,bp
	jmp	entry_open_vesa_mode
valid_vesa_open_mode:
	or	bp,bp
	jne	ok_open_vesa_mode
	mov	di,OFFSET default_register_80x40
	call	Get_Miscellaneous
	scasb
	jne	ok_open_vesa_mode
	mov	ah,1h
	call	Get_Sequencer
	scasb
	jne	ok_open_vesa_mode
	mov	ah,4h
	call	Get_Sequencer
	scasb
	jne	ok_open_vesa_mode
	mov	ah,7h
loop_get_register_status_1:
	call	Get_CRTC
	scasb
	jne	ok_open_vesa_mode
	dec	ah
	jns	loop_get_register_status_1
	mov	ds: byte ptr [error_open_vesa_video_mode],ERR_VESA_OPEN_22
	call	Init_X_Vesa
	test	ds: byte ptr [status_flag_4],AUTO_OPEN_VESA
	jne	invalid_video_mode
	pusha
	mov	bx,OFFSET vga_message_028
	mov	di,OFFSET vga_message_160
	mov	si,OFFSET vga_message_167
	call	Show_Message
	popa
loop_key_fail_regs:
	call	Get_Key
	cmp	ax,N_KEY
	je	invalid_video_mode
	cmp	ax,Y_KEY
	jne	loop_key_fail_regs
	inc	bp
	push	bx
	mov	bx,ds: word ptr [bx].VESA_MODE_PANEL.VIDEO_MODE
	test	ds: byte ptr [status_flag_2],VESA_MEMORY_MODE
	je	entry_open_vesa_mode
	or	bh,40h
	jmp	entry_open_vesa_mode
invalid_video_mode:
	lea	di,ds: word ptr [bx].VESA_MODE_PANEL.VRAM_SIZE_BANKED
	test	ds: byte ptr [status_flag_2],VESA_MEMORY_MODE
	je	set_open_error_banked_1
	lea	di,ds: word ptr [bx].VESA_MODE_PANEL.VRAM_SIZE_LINEAR
set_open_error_banked_1:
	or	ds: byte ptr [di + 3h],FLAG_OPEN_VESA_ERROR
	mov	al,ds: byte ptr [error_open_vesa_video_mode]
	mov	ds: byte ptr [di],al
	jmp	fail_open_vesa
ok_open_vesa_mode:
	cmp	ds: byte ptr [bx].VESA_MODE_PANEL.VIDEO_MODE_MODEL,VESA_MODE_TEXT
	jne	no_cursor_off
	call	Cursor_Off
no_cursor_off:
	test	ds: byte ptr [status_flag_2],CORRECT_BPSL
	je	valid_open_vesa_mode
	call	Get_VESA_Scanline
	jc	invalid_get_bpsl
	mov	ax,ds: word ptr [current_bpsl]
	cmp	ax,ds: word ptr [scanline_vesa_bytes]
	je	valid_open_vesa_mode
invalid_get_bpsl:
	and	ds: byte ptr [status_flag_2],NOT SCANLINE_FORM
	call	Set_VESA_Scanline
	jc	invalid_set_bpsl
	cmp	ax,ds: word ptr [current_bpsl]
	je	valid_open_vesa_mode
invalid_set_bpsl:
	test	ds: byte ptr [status_flag_4],AUTO_OPEN_VESA
	jne	valid_open_vesa_mode
	call	Init_X_Vesa
	pusha
	mov	bx,OFFSET vga_message_028
	mov	di,OFFSET vga_message_160
	mov	si,OFFSET vga_message_159
	call	Show_Message
	popa
loop_key_bpsl:
	call	Get_Key
	cmp	ax,N_KEY
	jne	check_yes_bpsl	
	mov	ax,ds: word ptr [di].ModeInfoBlock.BytesPerScanLine
	mov	ds: word ptr [current_bpsl],ax
	jmp	continue_open_mode
check_yes_bpsl:
	cmp	ax,Y_KEY
	jne	loop_key_bpsl
continue_open_mode:
	push	bx
	mov	ax,(VESA_ID SHL 8h) + VESA_FUNC_OPEN_VIDEO_MODE
	mov	bx,ds: word ptr [bx].VESA_MODE_PANEL.VIDEO_MODE
	test	ds: byte ptr [status_flag_2],VESA_MEMORY_MODE
	je	entry_open_vesa_mode_1
	or	bh,40h
entry_open_vesa_mode_1:
	VIDEO_CALL
	pop	bx
valid_open_vesa_mode:
	test	ds: byte ptr [status_flag_2],VESA_MEMORY_MODE
	jne	ok_unreal_mode
	test	ds: byte ptr [status_flag_2],A20_ENABLED
	je	no_unreal_mode
	test	ds: byte ptr [status_flag_0],FLAG_AVX OR FLAG_AVX512
	je	no_unreal_mode
ok_unreal_mode:
	xor	eax,eax
	mov	ax,ds
	shl	eax,4h
	add	eax,(OFFSET GDT_Start - OFFSET start_data)
	mov	ds: dword ptr [GDT_Addr],eax
	cli
	lgdt	ds: fword ptr [GDT_Ptr]
	mov	eax,cr0
	or	al,1h
	mov	cr0,eax
	jmp	$ + 2h
	mov	ax,8h
	mov	ds,ax
	mov	es,ax
	mov	eax,cr0
	and	al,0FEh
	mov	cr0,eax
	push	cs
	push	OFFSET go_real_mode
	retf
go_real_mode:
	mov	ax,gs
	mov	ds,ax
	mov	es,ax
	sti
no_unreal_mode:
	call	Set_VESA_Default_Color
	movzx	eax,ds: byte ptr [bx].VESA_MODE_PANEL.MEMORY_BPP
	shr	al,3h
	mov	ds: dword ptr [current_bpl],eax
	mov	ds: dword ptr [clear_value],0h
	and	ds: byte ptr [status_flag_5],NOT DAC_VGA
	mov	dx,VGA_DAC_PEL_MASK
	in	al,dx
	mov	ah,al
	mov	al,55h
	out	dx,al
	in	al,dx
	cmp	al,55h
	jne	no_vga_dac
	mov	al,0AAh
	out	dx,al
	in	al,dx
	cmp	al,0AAh
	je	ok_vga_dac
no_vga_dac:
	or	ds: byte ptr [status_flag_5],DAC_VGA
ok_vga_dac:
	mov	al,ah
	out	dx,al
	mov	ds: word ptr [current_bank],NO_BANK
	or	ds: byte ptr [status_flag_2],VESA_VIDEO_MODE_ON
	and	ds: byte ptr [status_flag_4],(NOT FONT_TABLE_LOAD) AND (NOT VALID_VESA_IO) AND (NOT VALID_VESA_ADDRESSING)
	clc
	popa
	ret

;#############################################################################

;	DS:SI = Pointer VESA map mask color

	Create_direct_color_Map_Mask:

;	CARRY = 0 -> Map mask ok
;	CARRY = 1 -> Invalid map mask

;#############################################################################

	pusha
	mov	di,OFFSET dc_red_size
	xor	edx,edx
	mov	bp,VESA_SIZE_MASK SHR 1h
next_direct_color:
	lodsw
	stosw
	or	al,al
	je	fail_map_mask
	cmp	al,8h
	ja	fail_map_mask
	mov	ch,ds: byte ptr [bx].VESA_MODE_PANEL.MEMORY_BPP
	sub	ch,al
	jc	fail_map_mask
	sub	ch,ah
	jc	fail_map_mask
	xchg	ax,cx
	mov	eax,1h
	shl	eax,cl
	dec	eax
	xchg	cl,ch
	shl	eax,cl
	test	eax,edx
	jne	fail_map_mask
	or	edx,eax
	dec	bp
	jne	next_direct_color
        clc
	popa
	ret
fail_map_mask:
	stc
	popa
	ret

;#############################################################################

;	AX = Byte per scan line
;	DS:BX = Pointer to vesa_mode_info video mode

	Check_Bytes_Per_Scan_Line:

;	AX = Valid byte per scan line

;#############################################################################

	pusha
	mov	cx,ds: word ptr [bx].VESA_MODE_PANEL.X_RES
	cmp	ds: byte ptr [bx].VESA_MODE_PANEL.VIDEO_MODE_MODEL,VESA_MODE_TEXT
	jne	bpsl_text
	add	cx,cx
bpsl_text:
	cmp	ds: byte ptr [bx].VESA_MODE_PANEL.VIDEO_MODE_MODEL,VESA_MODE_PLANAR
	jne	bpsl_planar
	shr	cx,3h
bpsl_planar:		
	cmp	ds: byte ptr [bx].VESA_MODE_PANEL.VIDEO_MODE_MODEL,VESA_MODE_DIRECT_COLOR
	jne	bpsl_check
	movzx	dx,ds: byte ptr [bx].VESA_MODE_PANEL.MEMORY_BPP
	shr	dx,3h
	imul	cx,dx
bpsl_check:
	cmp	ax,cx
	jae	ok_bpsl
	xchg	ax,cx
ok_bpsl:
	test	ax,3h
	je	exit_bpsl
	add	ax,3h
	and	al,0FCh
exit_bpsl:
	call	Exit_Return_AX
	popa
	ret
