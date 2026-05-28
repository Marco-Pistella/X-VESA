;#############################################################################

;	AL = Char value
;	CX = X coordinate
;	DX = Y coordinate

	Write_VESA_Char:

;#############################################################################

	pusha
	mov	si,OFFSET vesa_char_string
	xor	ah,ah
	mov	ds: word ptr [si],ax
	call	Write_VESA_String
	popa
	ret
