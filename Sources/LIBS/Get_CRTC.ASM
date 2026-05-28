;#############################################################################

;	AH = Register

	Get_CRTC:

;	AL = Read value

;#############################################################################

	push	dx
	call	Get_Port
	mov	al,ah
	out	dx,al
	inc	dx
	in	al,dx
	pop	dx
	ret

