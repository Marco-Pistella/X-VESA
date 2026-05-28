;#############################################################################

	Enable_A20_Line:

;#############################################################################

	pusha
	cli
	call	Enable_A20_Line_Check
	jnc	ok_a20_line
	mov	ax,(A20_LINE_FUNC SHL 8h) + SET_A20_LINE
	int	SYSTEM_SERVICES_INTERRUPT
	jc	fail_a20_bios
	or	ah,ah
	jne	fail_a20_bios
	call	Enable_A20_Line_Check
	jnc	ok_a20_line
fail_a20_bios:
	in	al,SYSTEM_CONTROL_PORT_A
	or	al,A20_ENABLE_PORT_A
	and	al,NOT FAST_RESET_PORT_A
	out	SYSTEM_CONTROL_PORT_A,al
	mov	bx,3h
entry_8042_a20:
	call	Delay
	call	Enable_A20_Line_Check
	jnc	ok_a20_line
	call	Enable_A20_Line_Keyboard_In
	jc	fail_8042_a20
	mov	al,DISABLE_KEYBOARD
	out	KEYBOARD_COMMAND_REGISTER,al
	call	Enable_A20_Line_Keyboard_In
	jc	fail_8042_a20
	mov	al,WRITE_OUTPUT_PORT
	out	KEYBOARD_COMMAND_REGISTER,al
	call	Enable_A20_Line_Keyboard_In
	jc	fail_8042_a20
	mov	al,KEYBOARD_A20_ENABLE
	out	KEYBOARD_DATA_PORT,al
	call	Enable_A20_Line_Keyboard_In
	jc	fail_8042_a20
	mov	al,ENABLE_KEYBOARD
	out	KEYBOARD_COMMAND_REGISTER,al
	call	Enable_A20_Line_Keyboard_Out
	jc	flush_done
	in	al,KEYBOARD_DATA_PORT
flush_done:
	call	Enable_A20_Line_Check
	jnc	ok_a20_line
fail_8042_a20:
	mov	al,ENABLE_KEYBOARD
	out	KEYBOARD_COMMAND_REGISTER,al
	cmp	bx,6h
	je	no_a20_line
	mov	bx,6h
	jmp	entry_8042_a20
ok_a20_line:
	or	ds: byte ptr [status_flag_2],A20_ENABLED
no_a20_line:
	sti
	popa
	ret

;#############################################################################

	Enable_A20_Line_Check:

;#############################################################################

	push	ds
	push	es
	push	ax
	xor	ax,ax
	mov	ds,ax
	dec	ax
	mov	es,ax
	mov	al,ds: byte ptr [500h]
	cmp	al,es: byte ptr [510h]
	jne	a20_enabled_check
	xor	ds: byte ptr [500h],ah
	mov	ah,al
	xor	al,0FFh
	push	bx
	mov	bl,ds: byte ptr [start_code]
	pop	bx
	cmp	al,es: byte ptr [510h]
	mov	ds: byte ptr [500h],ah
a20_enabled_check:
	pop	ax
	pop	es
	pop	ds
	je	a20_not_enabled
	clc
	ret
a20_not_enabled:
	stc
	ret

;#############################################################################

	Enable_A20_Line_Keyboard_In:

;#############################################################################

	xor	cx,cx
wait_keyboard_in:
	in	al,KEYBOARD_STATUS_REGISTER
	test	al,INPUT_BUFFER_FULL
	je	ok_keyboard_in
	loop	wait_keyboard_in
	stc
	ret
ok_keyboard_in:
	clc
	ret

;#############################################################################

	Enable_A20_Line_Keyboard_Out:

;#############################################################################

	xor	cx,cx
wait_keyboard_out:
	in	al,KEYBOARD_STATUS_REGISTER
	test	al,OUTPUT_BUFFER_FULL
	jne	ok_keyboard_out
	loop	wait_keyboard_out
	stc
	ret
ok_keyboard_out:
	clc
	ret
