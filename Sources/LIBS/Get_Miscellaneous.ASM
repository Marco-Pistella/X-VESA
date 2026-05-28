;#############################################################################

	Get_Miscellaneous:

;	AL = Read value

;#############################################################################

	push	dx
	mov	dx,VIDEO_READ_MISCELLANEOUS_REG
	in	al,dx
	pop	dx
	ret

