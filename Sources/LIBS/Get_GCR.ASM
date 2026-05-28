;#############################################################################

;	AH = Register

	Get_GCR:

;#############################################################################

	push	dx
	xchg	al,ah
	mov	dx,VGA_GCR_PORT
	out	dx,al
	inc	dx
	xchg	al,ah
	in	al,dx
	pop	dx
	ret
