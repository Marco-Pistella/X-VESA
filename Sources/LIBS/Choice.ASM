;#############################################################################

;	DS:SI = INPUTS struct pointer

	Choice:

;#############################################################################

	pusha
	and	ds: byte ptr [status_flag_1],NOT CHOICE_INS
	call	Cursor_On
	mov	dl,VIDEO_FONT_HEIGHT - 3d
	mov	dh,VIDEO_FONT_HEIGHT - 2d
	call	Cursor_Size
	mov	bx,si
	mov	cx, ds: word ptr [bx].INPUTS.COORD_START
	call	Cursor_Pos
	mov	al,ds: byte ptr [bx].INPUTS.COLOR
	mov	ds: byte ptr [color_base_mem],al
	mov	al,ds: byte ptr [bx].INPUTS.LEN
	mov	si,OFFSET vga_message_118
	mov	ds: byte ptr [si + 1h],al
	call	Write_VGA_Message
	mov	si,ds: word ptr [bx].INPUTS.BUFFER
	call	Write_VGA_Message
	mov	ds: byte ptr [bx].INPUTS.CUR_POS,0h
	jmp	loop_choice_copy
loop_choice_verify:
	call	Choice_Verify
	jc	loop_choice_copy
	call	Choice_Copy_Tmp_Buffer
	call	Choice_Write_String
	jmp	loop_choice
loop_choice_copy:
	call	Choice_Copy_Buffer
loop_choice:
	call	Get_Key
	cmp	ax,BACKSPACE_KEY
	jne	choice_key_1
	dec	ds: byte ptr [bx].INPUTS.TMP_CUR_POS
	call	Choice_Sub
	jmp	loop_choice_verify
choice_key_1:
	cmp	ax,DEL_KEY
	jne	choice_key_2
	call	Choice_Sub
	jmp	loop_choice_verify
choice_key_2:
	cmp	ax,LEFT_KEY
	jne	choice_key_3
	dec	ds: byte ptr [bx].INPUTS.TMP_CUR_POS
	jmp	loop_choice_verify
choice_key_3:
	cmp	ax,RIGHT_KEY
	jne	choice_key_4
	inc	ds: byte ptr [bx].INPUTS.TMP_CUR_POS
	jmp	loop_choice_verify
choice_key_4:
	cmp	ax,HOME_KEY
	jne	choice_key_5
	mov	ds: byte ptr [bx].INPUTS.TMP_CUR_POS,0h
	jmp	loop_choice_verify
choice_key_5:
	cmp	ax,END_KEY
	jne	choice_key_6
	mov	si,ds: word ptr [bx].INPUTS.TMP_BUFFER
	call	Str_Len
	mov	ds: byte ptr [bx].INPUTS.TMP_CUR_POS,al
	jmp	loop_choice_verify
choice_key_6:
	cmp	ax,INS_KEY
	jne	choice_key_7
	xor	ds: byte ptr [status_flag_1],CHOICE_INS
	mov	dl,VIDEO_FONT_HEIGHT - 3d
	mov	dh,VIDEO_FONT_HEIGHT - 2d
	test	ds: byte ptr [status_flag_1],CHOICE_INS
	je	set_cursor_size_choice
	xor	dl,dl
	mov	dh,VIDEO_FONT_HEIGHT - 1d
set_cursor_size_choice:
	call	Cursor_Size
	jmp	loop_choice
choice_key_7:
	call	ds: word ptr [bx].INPUTS.EXIT
	jnc	exit_choice
	cmp	ax,CHOICE_NO_EXIT
	je	loop_choice
	call	Choice_Add
	jmp	loop_choice_verify
exit_choice:
	mov	ds: word ptr [bx].INPUTS.KEY,ax
	call	Cursor_Off
	mov	ds: byte ptr [color_base_mem],COLOR_BASE
	popa
	ret

;#############################################################################

	Choice_Exit:

;#############################################################################

	cmp	ax,ESC_KEY
	je	exit_choice_1
	cmp	ax,ENTER_KEY
	jne	no_exit_choice
	call	Choice_Verify
	jnc	exit_choice_2
no_exit_choice_1:
	mov	ax,CHOICE_NO_EXIT
no_exit_choice:
	stc
	ret
exit_choice_2:
	push	si
	mov	si,ds: word ptr [bx].INPUTS.BUFFER
	cmp	ds: byte ptr [si],0h
	pop	si
	jne	exit_choice_1
	pusha
	SOUND_ERROR
	popa
	jmp	no_exit_choice_1
exit_choice_1:
	clc
	ret

;#############################################################################

	Choice_Exit_02:

;#############################################################################

	cmp	ax,ESC_KEY
	je	exit_choice_1
	cmp	ax,ENTER_KEY
	jne	no_exit_choice
	push	si
	mov	si,ds: word ptr [bx].INPUTS.BUFFER
	call	Asci_To_Num
	pop	si
	jc	no_exit_choice
	push	bx
	push	dx
	movzx	bx,ds: byte ptr [panel_01].PANEL.RELATIVE_ELEMENT
	add	bx,ds: word ptr [panel_01].PANEL.ABSOLUTE_ELEMENT
	imul	bx,SIZEOF VESA_MODE_PANEL
	add	bx,OFFSET vesa_mode_info
	movzx	edx,ds: word ptr [bx].VESA_MODE_PANEL.X_RES
	cmp	eax,edx
	pop	dx
	pop	bx
	jb	no_exit_choice
	cmp	eax,0FFFFh
	ja	no_exit_choice
	jmp	exit_choice_2

;#############################################################################

	Choice_Exit_03:

;#############################################################################

	cmp	ax,ESC_KEY
	je	exit_choice_1
	cmp	ax,ENTER_KEY
	jne	no_exit_choice
	push	si
	mov	si,ds: word ptr [bx].INPUTS.BUFFER
	call	Asci_To_Num
	pop	si
	jc	no_exit_choice
	push	dx
	movzx	edx,ds: word ptr [min_virtual_hor]
	cmp	eax,edx
	pop	dx
	jb	no_exit_choice
	cmp	eax,0FFFFh
	ja	no_exit_choice
	jmp	exit_choice_2

;#############################################################################

	Choice_Exit_04:

;#############################################################################

	cmp	ax,ESC_KEY
	je	exit_choice_1
	cmp	ax,ENTER_KEY
	jne	no_exit_choice
	push	si
	mov	si,ds: word ptr [bx].INPUTS.BUFFER
	call	Asci_To_Num
	pop	si
	jc	no_exit_choice
	push	bx
	push	dx
	movzx	bx,ds: byte ptr [panel_01].PANEL.RELATIVE_ELEMENT
	add	bx,ds: word ptr [panel_01].PANEL.ABSOLUTE_ELEMENT
	imul	bx,SIZEOF VESA_MODE_PANEL
	add	bx,OFFSET vesa_mode_info
	movzx	edx,ds: word ptr [bx].VESA_MODE_PANEL.Y_RES
	cmp	eax,edx
	pop	dx
	pop	bx
	jb	no_exit_choice
	cmp	eax,0FFFFh
	ja	no_exit_choice
	jmp	exit_choice_2

;#############################################################################

	Choice_Exit_05:

;#############################################################################

	cmp	ax,ESC_KEY
	je	exit_choice_1
	cmp	ax,ENTER_KEY
	jne	no_exit_choice
	push	si
	mov	si,ds: word ptr [bx].INPUTS.BUFFER
	call	Asci_To_Num
	pop	si
	jc	no_exit_choice
	push	dx
	movzx	edx,ds: word ptr [min_virtual_ver]
	cmp	eax,edx
	pop	dx
	jb	no_exit_choice
	cmp	eax,0FFFFh
	ja	no_exit_choice
	jmp	exit_choice_2

;#############################################################################

	Choice_Exit_01:

;#############################################################################

	cmp	ax,F10_KEY
	jne	Choice_Exit_1
	pusha
	call	Cursor_Off
	mov	al,ds: byte ptr [color_base_mem]
	mov	ds: byte ptr [color_base_mem_tmp],al
	mov	ds: byte ptr [color_base_mem],COLOR_BASE
	call	Save_Current_Video_Page
	call	Clear_Screen
	CENTER_BOX VRES_PANEL_WIDHT,TEXT_HEIGHT
	mov	si,OFFSET vga_message_299
	mov	di,OFFSET vga_message_116
	call	Extended_Box
	add	cx,702h
	mov	si,OFFSET vga_message_300
	call	Write_VGA_Message
	mov	si,OFFSET panel_06
	mov	ax,ds: word ptr [n_scanline]
	dec	ax
	mov	ds: word ptr [si].PANEL.TOTAL_ELEMENTS,ax
	call	Redraw_All_Init
loop_choice_f10:
	call	Select_Item
	cmp	ax,ENTER_KEY
	jne	test_choice_f10_esc
	popa
	call	Restore_Current_Video_Page
	mov	ds: byte ptr [color_base_mem],COLOR_BASE
	add	sp,2h
	popa
	add	sp,2h
	movzx	di,ds: byte ptr [panel_06].PANEL.RELATIVE_ELEMENT
	add	di,ds: word ptr [panel_06].PANEL.ABSOLUTE_ELEMENT
	shl	di,2h
	mov	si,ss: word ptr [di]
	mov	di,ss: word ptr [di + 2h]
	jmp	ok_set_scanline_7
test_choice_f10_esc:
	cmp	ax,ESC_KEY
	jne	loop_choice_f10
	call	Restore_Current_Video_Page
	mov	al,ds: byte ptr [color_base_mem_tmp]
	mov	ds: byte ptr [color_base_mem],al
	call	Cursor_On
	popa
	jmp	no_exit_choice_1
choice_exit_1:
	cmp	ax,ESC_KEY
	je	exit_choice_1
	cmp	ax,ENTER_KEY
	jne	no_exit_choice
	push	si
	mov	si,ds: word ptr [bx].INPUTS.BUFFER
	call	Asci_To_Num
	pop	si
	jc	no_exit_choice
	push	bx
	push	dx
	movzx	bx,ds: byte ptr [panel_01].PANEL.RELATIVE_ELEMENT
	add	bx,ds: word ptr [panel_01].PANEL.ABSOLUTE_ELEMENT
	imul	bx,SIZEOF VESA_MODE_PANEL
	add	bx,OFFSET vesa_mode_info
	movzx	edx,ds: word ptr [bx].VESA_MODE_PANEL.X_RES
	cmp	eax,edx
	pop	dx
	pop	bx
	jb	no_exit_choice
	push	bx
	mov	bx,ds: word ptr [n_scanline]
	shl	bx,2h
	cmp	ax,ss: word ptr [bx - 4h]
	pop	bx
	ja	no_exit_choice
	jmp	exit_choice_2

;#############################################################################

	Choice_Copy_Buffer:

;#############################################################################

	pusha
	mov	si,ds: word ptr [bx].INPUTS.BUFFER
	call	Str_Len
	xchg	ax,cx
	inc	cx
	mov	di,ds: word ptr [bx].INPUTS.TMP_BUFFER
	call	Move_Mem
	mov	al,ds: byte ptr [bx].INPUTS.CUR_POS
	mov	ds: byte ptr [bx].INPUTS.TMP_CUR_POS,al
	popa
	ret

;#############################################################################

	Choice_Copy_Tmp_Buffer:

;#############################################################################

	pusha
	mov	si,ds: word ptr [bx].INPUTS.TMP_BUFFER
	call	Str_Len
	xchg	ax,cx
	inc	cx
	mov	di,ds: word ptr [bx].INPUTS.BUFFER
	call	Move_Mem
	mov	al,ds: byte ptr [bx].INPUTS.TMP_CUR_POS
	mov	ds: byte ptr [bx].INPUTS.CUR_POS,al
	popa
	ret

;#############################################################################

	Choice_Write_String:

;#############################################################################

	pusha
	mov	si,ds: word ptr [bx].INPUTS.BUFFER
	call	Write_VGA_Message
	call	Str_Len
	cmp	al,ds: byte ptr [bx].INPUTS.LEN
	je	exit_choice_write_string
	add	ch,al
	mov	al,' '
	call	Write_Char
exit_choice_write_string:
	popa
	ret

;#############################################################################

	Choice_Verify:

;#############################################################################

	pusha
	mov	si,ds: word ptr [bx].INPUTS.TMP_BUFFER
	cmp	ds: byte ptr [si],0h
	jne	ok_choice_verify
	cmp	ds: byte ptr [bx].INPUTS.TMP_CUR_POS,0h
	je	valid_choice_verify
ok_choice_verify:
	call	ds: word ptr [bx].INPUTS.VERIFY
	jc	fail_choice_verify
	call	Str_Len
	cmp	al,ds: byte ptr [bx].INPUTS.TMP_CUR_POS
	jb	fail_choice_verify
	cmp	al,ds: byte ptr [bx].INPUTS.LEN
	ja	fail_choice_verify
	mov	ch,ds: byte ptr [bx + 1h].INPUTS.COORD_START
	add	ch,ds: byte ptr [bx].INPUTS.TMP_CUR_POS
valid_choice_verify:
	call	Cursor_Pos
	clc
	popa
	ret
fail_choice_verify:
	SOUND_ERROR
	stc
	popa
	ret

;#############################################################################

	Choice_Sub:

;#############################################################################

	pusha
	mov	si,ds: word ptr [bx].INPUTS.BUFFER
	call	Str_Len
	cmp	al,ds: byte ptr [bx].INPUTS.TMP_CUR_POS
	jb	no_choice_sub
	mov	di,ds: word ptr [bx].INPUTS.TMP_BUFFER
	movzx	cx,ds: byte ptr [bx].INPUTS.TMP_CUR_POS
	rep	movsb
	inc	si
	call	Str_Len
	inc	ax
	xchg	ax,cx
	rep	movsb
no_choice_sub:
	popa
	ret

;#############################################################################

	Choice_Add:

;#############################################################################

	pusha
	mov	si,ds: word ptr [bx].INPUTS.BUFFER
	mov	di,ds: word ptr [bx].INPUTS.TMP_BUFFER
	movzx	cx,ds: byte ptr [bx].INPUTS.TMP_CUR_POS
	call	Move_Mem
	add	di,cx
	stosb
	test	ds: byte ptr [status_flag_1],CHOICE_INS
	je	no_align_si
	inc	si
no_align_si:
	add	si,cx
	call	Str_Len
	inc	ax
	xchg	ax,cx
	call	Move_Mem
	inc	ds: byte ptr [bx].INPUTS.TMP_CUR_POS
	popa
	ret

;#############################################################################

	Choice_Verify_1:

;#############################################################################

	pusha
	call	Asci_To_Num
	jc	fail_choice_verify_1
	movzx	bx,ds: byte ptr [panel_02].PANEL.RELATIVE_ELEMENT
	add	bx,ds: word ptr [panel_02].PANEL.ABSOLUTE_ELEMENT
	imul	bx,SIZEOF EDID
	add	bx,OFFSET edid_data.EDID.EDIDData
	movzx	bx,ds: byte ptr [bx].EDID128.ExtensionFlag
	cmp	ax,bx
	ja	fail_choice_verify_1
	or	ax,ax
	je	fail_choice_verify_1
	clc
	popa
	ret
fail_choice_verify_1:
	stc
	popa
	ret

;#############################################################################

	Choice_Verify_2:

;#############################################################################

	pusha
	call	Asci_To_Num
	jc	fail_choice_verify_1
	cmp	eax,ds: dword ptr [tmp_vram_offset]
	ja	fail_choice_verify_1
	clc
	popa
	ret

;#############################################################################

	Choice_Verify_3:

;#############################################################################

	pusha
	call	Asci_To_Num
	jc	fail_choice_verify_1
	cmp	eax,ds: dword ptr [tmp_vram_size]
	ja	fail_choice_verify_1
	or	eax,eax
	je	fail_choice_verify_1
	clc
	popa
	ret

;#############################################################################

	Choice_Verify_4:

;#############################################################################

	pusha
	call	Asci_To_Num
	jc	fail_choice_verify_1
	cmp	eax,MAX_PASS_VESA
	ja	fail_choice_verify_1
	or	eax,eax
	je	fail_choice_verify_1
	clc
	popa
	ret

;#############################################################################

	Choice_Verify_5:

;#############################################################################

	pusha
	call	Asci_To_Num
	jc	fail_choice_verify_1
	or	eax,eax
	je	fail_choice_verify_1
	clc
	popa
	ret
	