;#############################################################################

;	AX = Elemento da visualizzare

	Write_Panel_03:

;#############################################################################

	pusha
	mov	ch,((TEXT_WIDTH - COMMANDS_INVERT_LEN) SHR 1h) + 1h
	mov	si,OFFSET vga_message_140
	call	Write_Index_String
	popa
	ret