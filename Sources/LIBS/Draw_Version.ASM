;#############################################################################

;	BX = Version
;       CH = X Coordinate
;	CL = Y Coordinate

	Draw_Version:

;#############################################################################

	pusha
	or	bx,bx
	jne	valid_oem_version
	mov	si,OFFSET vga_message_085
	call	Write_VGA_Message
	popa
	ret
valid_oem_version:
	mov	al,bh
	call	Write_Dec_Num_Left8
	mov	al,ds: byte ptr [decimal_sign]
	call	Write_Char
	mov	al,bl
	call	Write_Dec_Num_Left8
	popa
	ret
