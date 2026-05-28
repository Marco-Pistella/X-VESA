;#############################################################################

	DOS_Error_Handler:

;#############################################################################

	push	es
	push	ds
	push	fs
	pusha
	mov	bx,cs
	add	bx,((OFFSET end_code - OFFSET start_code) + 10Fh) SHR 4h
	mov	ds,bx
	test	ds: byte ptr [status_flag_2],VESA_VIDEO_MODE_ON
	je	tui_mode_dos_error
	mov	ax,2h
	jmp	exit_dos_error_handler
tui_mode_dos_error:
	call	Enter_Redirector
	call	Set_Virtual_String
	xor	cx,cx
	test	ah,DOS_FAIL_ERROR
	je	no_abort
	mov	si,OFFSET vga_message_001
	call	Write_Simple_VGA_Message
no_abort:
	test	ah,DOS_RETRY_ERROR
	je	no_retry
	mov	si,OFFSET vga_message_002
	call	Write_Simple_VGA_Message
no_retry:
	test 	ah,DOS_IGNORE_ERROR
	je	no_ignore
	mov	si,OFFSET vga_message_003
	call	Write_Simple_VGA_Message
no_ignore:
	push	ax
	sub	ch,2h
	mov	al,' '
	call	Write_Char
	call	Get_Virtual_String
	call	Exit_Redirector
	call	Save_Current_Video_Page
	call	Clear_Screen
	mov	di,OFFSET buffer_vesa_string
	mov	si,OFFSET vga_message_004
	CENTER_BOX 27h,8h
	call    Extended_Box
	add	cl,2h
	add	ch,4h
	mov	si,OFFSET vga_message_005
	call	Write_VGA_Message
	push	cx
	mov	ah,59h
	int	21h
	mov	dx,cx
	pop	cx
	add	ch,14h
	mov	ds: word ptr [start_xy],cx
	call	Num_To_Str_Hex4
	call	Next_Line
	mov	al,bh
	call	Num_To_Str_Hex2
	call	Next_Line
	mov	al,bl
	call	Num_To_Str_Hex2
	call	Next_Line
	mov	al,dh
	call 	Num_To_Str_Hex2
	pop	bx
loop_error_handler:
	mov	ah,KEY_FUNC_GET
	int	KEY_INTERRUPT
	xor	dx,dx
	cmp	ax,I_KEY
	jne	test_r_key
	test	bh,DOS_IGNORE_ERROR
	jne	exit_error_handler
test_r_key:
	inc	dx
	cmp	ax,R_KEY
	jne	test_f_key
	test	bh,DOS_RETRY_ERROR
	jne	exit_error_handler
test_f_key:
	add	dl,2h
	cmp	ax,F_KEY
	jne	loop_error_handler
	test	bh,DOS_FAIL_ERROR
	je	loop_error_handler
exit_error_handler:
	xchg	ax,dx
	call	Restore_Current_Video_Page
exit_dos_error_handler:
	call    Exit_Return_AX
	popa
	pop	fs
	pop	ds
	pop	es
	iret
