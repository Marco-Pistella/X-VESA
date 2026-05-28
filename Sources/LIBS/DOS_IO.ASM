;#############################################################################

;	DS:DI = Pointer to CREATE_FILE struct

	Create_Unique_File:

;	CARRY = 0 -> Ok create file
;	CARRY = 1 -> Fail to create file

;#############################################################################

	pusha
	test	ds: byte ptr [status_flag_2],VESA_VIDEO_MODE_ON
	jne	no_tui_mode
	call	Save_Current_Video_Page
	call	Clear_Screen
	mov	si,ds: word ptr [di].CREATE_FILE.OFFSET_INSTANT_MESSAGE
	call	View_Instant_Message
no_tui_mode:
	xor	bp,bp
loop_found_file_io:
	mov	si,ds: word ptr [di].CREATE_FILE.OFFSET_NAME_DECIMAL
	mov	ax,bp
	call	Num_To_Str_Dec
	mov	ax,(DOS_FUNC_OPEN_FILE SHL 8) + DOS_OPEN_ACCESS_READ_ONLY
	mov	dx,ds: word ptr [di].CREATE_FILE.OFFSET_FILE_NAME
	int	DOS_INTERRUPT
	jc	ok_create_file_io
	xchg	ax,bx
	mov	ah,DOS_FUNC_CLOSE_FILE
	int	DOS_INTERRUPT
	jc      fail_write_file_io
	inc	bp
	cmp	bp,10000d
	jne	loop_found_file_io
	mov	si,OFFSET vga_message_042
	jmp	exit_create_unique_file
fail_write_file_io:
	mov	si,ds: word ptr [di].CREATE_FILE.OFFSET_FAIL_MESSAGE
exit_create_unique_file:
	call	Exit_Redirector
	test	ds: byte ptr [status_flag_2],VESA_VIDEO_MODE_ON
	jne	no_tui_mode_1
	call	Clear_Screen
	call	View_Alert_Message
	call	Restore_Current_Video_Page
	stc
	popa
	ret
no_tui_mode_1:
	SOUND_ERROR
	stc
	popa
	ret
ok_create_file_io:
	mov	dx,ds: word ptr [di].CREATE_FILE.OFFSET_FILE_NAME
	mov	ah,DOS_FUNC_CREATE_FILE
	mov	cx,DOS_ATTRIBUTE
	int	DOS_INTERRUPT
	jc	fail_write_file_io
	mov	ds: word ptr [di].CREATE_FILE.HANDLE_WRITE,ax
	mov	ds: word ptr [di].CREATE_FILE.BUFFER_LEN_IO,0h
	popa
	clc
	ret

;#############################################################################

;	DS:DI = Pointer to CREATE_FILE struct

	Close_File:

;	CARRY = 0 -> Ok close file
;	CARRY = 1 -> Fail to close file

;#############################################################################

	pusha
	mov	ah,DOS_FUNC_CLOSE_FILE
	mov	bx,ds: word ptr [di].CREATE_FILE.HANDLE_WRITE
	int	21h
	jc	fail_write_file_io
	call	Exit_Redirector
	test	ds: byte ptr [status_flag_2],VESA_VIDEO_MODE_ON
	jne	no_tui_mode_2
	mov	si,ds: word ptr [di].CREATE_FILE.OFFSET_CLOSE_MESSAGE
	call	Clear_Screen
	or	ds: byte ptr [status_flag_5],ESC_ALERT_MESSAGE
	call	View_Alert_Message
	and	ds: byte ptr [status_flag_5],NOT ESC_ALERT_MESSAGE
	call	Restore_Current_Video_Page
no_tui_mode_2:
	clc
	popa
	ret

;#############################################################################

;	DS:DI = Pointer to CREATE_FILE struct

	Flush_IO:

;	CARRY = 0 -> Ok write buffer
;	CARRY = 1 -> Fail to write buffer

;#############################################################################

	pusha
	push	ds
	mov	ah,DOS_FUNC_WRITE_FILE
	mov	bx,ds: word ptr [di].CREATE_FILE.HANDLE_WRITE
	mov	cx,ds: word ptr [di].CREATE_FILE.BUFFER_LEN_IO
	lds	dx,ds: dword ptr [di].CREATE_FILE.OFFSET_BUFFER_IO
	int	DOS_INTERRUPT
	pop	ds
	jc      fail_write_file_io
	mov	ds: word ptr [di].CREATE_FILE.BUFFER_LEN_IO,0h
	clc
	popa
	ret

;#############################################################################

;	DS:DI = Pointer to CREATE_FILE struct

	Push_IO:

;	CARRY = 0 -> Ok push buffer
;	CARRY = 1 -> Fail to write buffer

;#############################################################################

	pusha
	mov	cx,ds: word ptr [di].CREATE_FILE.DATA_LEN
	mov	bp,ds: word ptr [di].CREATE_FILE.OFFSET_BUFFER_SOURCE
continue_push_io:
	mov	bx,di
	mov	ax,MAX_BUFFER_LEN_IO
	sub	ax,ds: word ptr [di].CREATE_FILE.BUFFER_LEN_IO
	cmp	cx,ax
	jbe	ok_push_io
	sub	cx,ax
	xchg	ax,cx
	push	ax
	push	ds
	push	es
	les	di,ds: dword ptr [di].CREATE_FILE.OFFSET_BUFFER_IO
	add	di,ds: word ptr [bx].CREATE_FILE.BUFFER_LEN_IO
	add	ds: word ptr [bx].CREATE_FILE.BUFFER_LEN_IO,cx
	lds	si,ds: dword ptr [bx].CREATE_FILE.OFFSET_BUFFER_SOURCE
	add	gs: word ptr [bx].CREATE_FILE.OFFSET_BUFFER_SOURCE,cx
	rep	movsb
	pop	es
	pop	ds
	mov	di,bx
	call	Flush_IO
	pop	cx
	jc	fail_push_io
	jmp	continue_push_io
ok_push_io:
	push	ds
	push	es
	les	di,ds: dword ptr [di].CREATE_FILE.OFFSET_BUFFER_IO
	add	di,ds: word ptr [bx].CREATE_FILE.BUFFER_LEN_IO
	add	ds: word ptr [bx].CREATE_FILE.BUFFER_LEN_IO,cx
	lds	si,ds: dword ptr [bx].CREATE_FILE.OFFSET_BUFFER_SOURCE
	rep	movsb
	pop	es
	pop	ds
	mov	ds: word ptr [bx].CREATE_FILE.OFFSET_BUFFER_SOURCE,bp
	clc
fail_push_io:
	popa
	ret

;#############################################################################

;	DS:DI = Pointer to CREATE_FILE struct
;	CX:DX = Seek point

	Seek_File:

;	CARRY = 0 -> Ok seek
;	CARRY = 1 -> Fail seek

;#############################################################################

	pusha
	mov	ax,(DOS_FUNC_MOVE_FILE_POINTER SHL 8) + DOS_SEEK_FROM_START
	mov	bx,ds: word ptr [di].CREATE_FILE.HANDLE_WRITE
	int	DOS_INTERRUPT
	jc	fail_write_file_io
	popa
	ret
