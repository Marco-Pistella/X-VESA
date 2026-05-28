;#############################################################################

;	ds: byte ptr [decimal_digits] = number of significant figures
;	AX = Decimal number
;	CH = X coordinate
;	CL = Y coordinate
;	FS = Video Segment

	Write_Decimal_Number16:

;#############################################################################

	pusha
	movzx	eax,ax
	call	Write_Decimal_Number32
	popa
	ret
