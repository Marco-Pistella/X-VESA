;#############################################################################

;	AX = Elemento da visualizzare

	Write_Panel_07:

;#############################################################################

	pusha
	mov	si,OFFSET vga_message_305
	mov	ch,((TEXT_WIDTH - 36d) SHR 1h) + 7d
	call	Write_Index_String
	popa
	ret
