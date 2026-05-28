;#############################################################################

;	AH = Register
;	AL = Value

	Set_CRTC:

;#############################################################################

	push	dx
	xchg	al,ah
	call	Get_Port
	out	dx,al
	xchg	al,ah
	inc	dx
	out	dx,al
	pop	dx
	ret

