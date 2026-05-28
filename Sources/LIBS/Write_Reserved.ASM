;#############################################################################

;	CH = X coordinate
;	CL = Y coordinate
;	AL = NN view string

	Write_Reserved:

;#############################################################################

	pusha
	mov	si,OFFSET vga_message_062
	call	Write_VGA_Message
	add	ch,9h
	call	Num_To_Str_Hex2
	popa
	ret
