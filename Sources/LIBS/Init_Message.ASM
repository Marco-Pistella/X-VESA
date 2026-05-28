;#############################################################################

	Init_Message:

;#############################################################################

	mov	ah,DOS_FUNC_DISPLAY_STRING
	mov	dx,OFFSET dos_message_03
	int	DOS_INTERRUPT
	mov	ah,DOS_FUNC_DISPLAY_STRING
	mov	dx,OFFSET dos_message_16
	int	DOS_INTERRUPT
	ret
