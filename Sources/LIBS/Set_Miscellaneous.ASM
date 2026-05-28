;#############################################################################

;	AL = Write value

	Set_Miscellaneous:

;#############################################################################

	push	dx
	mov	dx,VIDEO_WRITE_MISCELLANEOUS_REG
	out	dx,al
	pop	dx
	ret
