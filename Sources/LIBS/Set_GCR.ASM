;#############################################################################

;	AH = Register
;	AL = Value

	Set_GCR:

;#############################################################################

	push	dx
	xchg	al,ah
	mov	dx,VGA_GCR_PORT
	out	dx,al
	inc	dx
	xchg	al,ah
	out	dx,al
	pop	dx
	ret
