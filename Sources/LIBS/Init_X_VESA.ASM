;#############################################################################

	Init_X_VESA:

;	CARRY(0) = Ok Init routine
;	CARRY(1) = Fail Init routine

;#############################################################################

	pusha
	call	Exit_Redirector
	and	ds: byte ptr [status_flag_5],NOT (DAC_VGA OR DAC_WIDTH)
	mov	ax,(VIDEO_FUNC_SET_MODE SHL 8h) + VIDEO_MODE_START
	VIDEO_CALL
	call	Get_Miscellaneous
	and	al,NOT VGA_CLOCK_BIT
	call	Set_Miscellaneous
	mov	ah,VGA_CLOCKING_MODE
	call	Get_Sequencer
	or	al,VGA_8_9_DOT_MODE
	call	Set_Sequencer
	mov	ax,1300h
	call	Set_Attribute_Controller
	mov	ah,CRTC_MAXIMUM_SCAN_LINE
	call	Get_CRTC
	or	al,CRTC_DOUBLE_SCAN
	call	Set_CRTC
	mov	ah,CRTC_MAXIMUM_SCAN_LINE
	call	Get_CRTC
	test	al,CRTC_DOUBLE_SCAN
	jne	entry_x_vesa
	test	ds: byte ptr [status_flag_2],INIT_X_VESA_EXEC
	jne	init_ok_2
	mov	ah,DOS_FUNC_DISPLAY_STRING
	mov	dx,OFFSET dos_message_03
	int	DOS_INTERRUPT
	mov	ah,DOS_FUNC_DISPLAY_STRING
	mov	dx,OFFSET dos_message_15
	int	DOS_INTERRUPT
loop_key_dos:
	mov	ah,KEY_FUNC_GET
	int	KEY_INTERRUPT
	cmp	ax,N_KEY
	je	fail_init2
	cmp	ax,Y_KEY
	jne	loop_key_dos
init_ok_2:
	mov	ax,(VIDEO_FUNC_ALTERNATE_SELECT SHL 8) + VIDEO_200_LINES
	mov	bl,VIDEO_SUBFUNC_SET_SCANLINES
	VIDEO_CALL
	cmp	al,VIDEO_FUNC_ALTERNATE_SELECT
	jne	fail_init2
	mov	ax,(VIDEO_FUNC_SET_MODE SHL 8h) + VIDEO_MODE_START
	VIDEO_CALL
	mov	ah,CRTC_MAXIMUM_SCAN_LINE
	call	Get_CRTC
	test	al,CRTC_DOUBLE_SCAN
	je	fail_init2
entry_x_vesa:
	and	al,NOT ((CRTC_MAX_FONT_HEIGHT - 1) OR CRTC_DOUBLE_SCAN)
	or	al,VIDEO_FONT_HEIGHT - 1
	call	Set_CRTC
	call	Cursor_Off
	mov	ax,(VIDEO_FUNC_CHARACTER_GENERATOR SHL 8) + VIDEO_USER_ALPHA_LOAD
	mov	bx,(VIDEO_FONT_HEIGHT SHL 8) + VIDEO_CHARACTER_BLOCK
	mov	cx,VIDEO_CHARACTER_NUM
	mov	dx,VIDEO_OFFSET_CHARACTER
	mov	bp,OFFSET font_table_8x10
	VIDEO_CALL
	test	ds: byte ptr [status_flag_2],INIT_X_VESA_EXEC
	jne	exit_init_x_vesa
	xor	eax,eax
	mov	cx,100h
calc_timer_overhead:
	call	Timer_On
	call	Timer_Off
	add	eax,ds: dword ptr [elapsed_time]
	loop	calc_timer_overhead
	shr	eax,8h
	or	eax,eax
	jns	valid_overhead
	xor	eax,eax
valid_overhead:
	mov	ds: dword ptr [timer_overhead],eax
	mov	di,OFFSET default_register_80x40
	call	Get_Miscellaneous
	stosb
	mov	ah,1h
	call	Get_Sequencer
	stosb
	mov	ah,4h
	call	Get_Sequencer
	stosb
	mov	ah,7h
loop_get_register_status:
	call	Get_CRTC
	stosb
	dec	ah
	jns	loop_get_register_status
exit_init_x_vesa:
	or	ds: byte ptr [status_flag_2],INIT_X_VESA_EXEC
	and	ds: byte ptr [status_flag_2],NOT VESA_VIDEO_MODE_ON
	clc
	popa
	ret
fail_init2:
	mov	ax,(VIDEO_FUNC_ALTERNATE_SELECT SHL 8) + VIDEO_400_LINES
	mov	bl,VIDEO_SUBFUNC_SET_SCANLINES
	VIDEO_CALL
	mov	ax,(VIDEO_FUNC_SET_MODE SHL 8h) + VIDEO_MODE_START
	VIDEO_CALL
	mov	ah,DOS_FUNC_DISPLAY_STRING
	mov	dx,OFFSET dos_message_03
	int	DOS_INTERRUPT
	stc
	popa
	ret
