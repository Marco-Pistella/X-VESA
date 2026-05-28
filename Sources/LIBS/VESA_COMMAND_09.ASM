;#############################################################################

;	DS:BX = Pointer to vesa_mode_info video mode

	VESA_Command_09:

;#############################################################################

	pusha
retest_command_09:
	cmp	ds: byte ptr [bx].VESA_MODE_PANEL.VIDEO_MODE_MODEL,VESA_MODE_PLANAR
	je	valid_vesa_command_09
	cmp	ds: byte ptr [bx].VESA_MODE_PANEL.VIDEO_MODE_MODEL,VESA_MODE_PACKET
	je	valid_vesa_command_09
	cmp	ds: byte ptr [bx].VESA_MODE_PANEL.VIDEO_MODE_MODEL,VESA_MODE_DIRECT_COLOR
	je	valid_vesa_command_09
	mov	si,OFFSET vga_message_201
	call	View_Alert_Message
	popa
	ret
valid_vesa_command_09:
	call	Retrieve_VRAM_Size
	jc	undetectable_vram
	or	ebp,ebp
	jne	view_vram_size
	or	ds: byte ptr [status_flag_4],VALID_VESA_ADDRESSING
	call	Open_VESA_Video_Mode
	jnc	valid_vesa_command_09_open
	popa
	ret
valid_vesa_command_09_open:
	call	Get_VESA_VRAM_Size
	call	Init_X_Vesa
	call	Retrieve_VRAM_Size
	jnc	view_vram_size
undetectable_vram:
	mov	si,OFFSET vga_message_198
	call	View_Alert_Message
	popa
	ret
view_vram_size:
	CENTER_BOX 52d,7d
	mov	si,OFFSET vga_message_199
	mov	di,OFFSET vga_message_146
	test	ds: byte ptr [status_flag_2],VESA_MEMORY_MODE
	je	no_extra_retest
	cmp	ds: byte ptr [vesa_buffer_func_0 + 1].VbeInfoBlock.VbeVersion,VESA2
	jbe	no_extra_retest
	mov	di,OFFSET vga_message_263
no_extra_retest:
	call	Extended_Box
	add	cx,702h
	mov	si,OFFSET vga_message_200
	call	Write_VGA_Message
	mov	ds: byte ptr [color_base_mem],EXTRA_COLOR
	add	ch,0Ch
	mov	ds: word ptr [start_xy],cx
	call	VESA_Command_02_01
	call	Next_Line
	xor	al,al
	test	ds: byte ptr [status_flag_2],VESA_MEMORY_MODE
	jne	write_memory_model_02
	inc	ax
	test	ds: byte ptr [status_flag_2],VESA_WINDOW_MODE
	je	write_memory_model_02
	inc	ax
write_memory_model_02:
	mov	si,OFFSET vga_message_177
	call	Write_Index_String
	xchg	eax,ebp
	call	Write_Dec_Num_Left32
	inc	ch
	mov	si,OFFSET vga_message_013	
	call	Write_VGA_Message
	mov	ds: byte ptr [color_base_mem],COLOR_BASE
test_vram_size_key:
	call	Get_Key
	cmp	ax,R_KEY
	jne	test_exit_command_9_key
	test	ds: byte ptr [status_flag_2],VESA_MEMORY_MODE
	je	test_vram_size_key
	cmp	ds: byte ptr [vesa_buffer_func_0 + 1].VbeInfoBlock.VbeVersion,VESA2
	jbe	test_vram_size_key
	call	Save_Current_Video_Page
	call	Clear_Screen
	pusha
	mov	bx,OFFSET vga_message_028
	mov	di,OFFSET vga_message_160
	mov	si,OFFSET vga_message_264
	call	Show_Message
	popa
loop_key_11:
	call	Get_Key
	cmp	ax,N_KEY
	jne	check_key_y
	call	Restore_Current_Video_Page
	jmp	test_vram_size_Key
check_key_y:
	cmp	ax,Y_KEY
	jne	loop_key_11
	or	ds: byte ptr [status_flag_3],LIMIT_VBE_CHECK_VRAM
	call	Restore_Current_Video_Page
	jmp	retest_command_09
test_exit_command_9_key:
	cmp	ax,ESC_KEY
	jne	test_vram_size_key
	popa
	ret

;#############################################################################

	Get_VESA_VRAM_Size:

;#############################################################################

	pusha
	cmp	ds: byte ptr [bx].VESA_MODE_PANEL.VIDEO_MODE_MODEL,VESA_MODE_PLANAR
	jne	valid_packet_vram_size
	mov	ax,500h
	call	Set_GCR
	mov	ax,400h
	call	Set_GCR
	mov	ax,201h
	call	Set_Sequencer
valid_packet_vram_size:
	call	Get_BIOS_Ticks
	xchg	eax,ebp
	xor	edi,edi
	test	ds: byte ptr [status_flag_2],VESA_MEMORY_MODE
	jne	test_max_vram_linear
	or	ds: byte ptr [status_flag_3],FLAG_VESA_WINDOW_STATUS
	xor	dx,dx
	mov	es,ds: word ptr [banked_segment]
loop_max_vram_banked:
	call	ds: word ptr [set_bank_default]
	cmp	ax,VESA_ID
	jne	end_vram_size
	xor	si,si
loop_banked_1k:
	cmp	es: dword ptr [si],ebp
	jne	next_banked_1k
	cmp	es: dword ptr [si + 4h],edi
	jb	end_vram_size
next_banked_1k:
	mov	es: dword ptr [si],ebp
	cmp	es: dword ptr [si],ebp
	jne	end_vram_size
	mov	es: dword ptr [si + 4h],edi
	cmp	es: dword ptr [si + 4h],edi
	jne	end_vram_size
	inc	edi
	add	si,1024d
	cmp	si,ds: word ptr [segment_bound]
	jne	loop_banked_1K
	inc	dx
	jne	loop_max_vram_banked
	jmp	end_vram_size
test_max_vram_linear:
	mov	esi,ds: dword ptr [current_linear_vram_address]
	xor	ax,ax
	mov	es,ax
loop_linear_1k:
	cmp	es: dword ptr [esi],ebp
	jne	next_linear_1k
	cmp	es: dword ptr [esi + 4h],edi
	jb	end_vram_size
next_linear_1k:
	mov	es: dword ptr [esi],ebp
	cmp	es: dword ptr [esi],ebp
	jne	end_vram_size
	mov	es: dword ptr [esi + 4h],edi
	cmp	es: dword ptr [esi + 4h],edi
	jne	end_vram_size
	inc	edi
	add	esi,1024d
	test	ds: byte ptr [status_flag_3],LIMIT_VBE_CHECK_VRAM
	jne	no_check_vram_max_size
	cmp	ds: byte ptr [vesa_buffer_func_0 + 1].VbeInfoBlock.VbeVersion,VESA2
	jbe	no_check_vram_max_size
	movzx	eax,ds: word ptr [vesa_buffer_func_0].VbeInfoBlock.TotalMemory
	shl	eax,6h
	cmp	edi,eax
	je	end_vram_size
no_check_vram_max_size:
	or	esi,esi
	jne	loop_linear_1K
end_vram_size:
	and	ds: byte ptr [status_flag_3],NOT FLAG_VESA_WINDOW_STATUS
	cmp	ds: byte ptr [bx].VESA_MODE_PANEL.VIDEO_MODE_MODEL,VESA_MODE_PLANAR
	jne	valid_packet_vram_size_1
	movzx	eax,ds: byte ptr [bx].VESA_MODE_PANEL.COLOR_BPP
	imul	edi,eax
valid_packet_vram_size_1:
	or	edi,edi
	jne	exit_vram_size_ok
	mov	edi,0FFFFFFFFh
exit_vram_size_ok:
	test	ds: byte ptr [status_flag_2],VESA_MEMORY_MODE
	je	valid_vram_size_banked
	mov	ds: dword ptr [bx].VESA_MODE_PANEL.VRAM_SIZE_LINEAR,edi
	jmp	exit_vram_size
valid_vram_size_banked:
	mov	ds: dword ptr [bx].VESA_MODE_PANEL.VRAM_SIZE_BANKED,edi
exit_vram_size:
	and	ds: byte ptr [status_flag_3],NOT LIMIT_VBE_CHECK_VRAM
	push	ds
	pop	es
	popa
	ret

;#############################################################################

	Retrieve_VRAM_Size:

;#############################################################################

	test	ds: byte ptr [status_flag_3],LIMIT_VBE_CHECK_VRAM
	je	continue_retrieve_vram_size
retest_vram_1:
	xor	ebp,ebp
	clc
	ret
continue_retrieve_vram_size:
	mov	ebp,ds: dword ptr [bx].VESA_MODE_PANEL.VRAM_SIZE_BANKED
	test	ds: byte ptr [status_flag_2],VESA_MEMORY_MODE
	je	ok_retrieve_vram_size
	mov	ebp,ds: dword ptr [bx].VESA_MODE_PANEL.VRAM_SIZE_LINEAR
ok_retrieve_vram_size:
	test	ebp,80000000h
	jne	no_retrieve_vram_size
	clc
	ret
no_retrieve_vram_size:
	cmp	bp,ERR_VESA_OPEN_02
	jb	error_vram_1
	cmp	bp,ERR_VESA_OPEN_07
	jb	retest_vram_1
	cmp	bp,ERR_VESA_OPEN_21
	je	retest_vram_1
error_vram_1:
	stc
	ret
