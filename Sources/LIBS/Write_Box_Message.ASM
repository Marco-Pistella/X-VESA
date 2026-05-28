;#############################################################################

;	CH = X coordinate
;	CL = Y coordinate
;	DS:SI = String pointer
;	FS = Video Segment

	Write_Box_Message:

;#############################################################################

	pusha
	or	si,si
	je	exit_write_box_message
	mov	al,'µ'
	call	Write_Char
	call	Write_Simple_VGA_Message
	mov	al,'Æ'
	call	Write_Char
exit_write_box_message:
	popa
	ret
