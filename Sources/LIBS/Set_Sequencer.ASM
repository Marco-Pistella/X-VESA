;#############################################################################

;	AH = Register
;	AL = Write value

	Set_Sequencer:

;#############################################################################

	push	dx
	mov	dx,VGA_SEQUENCER
	xchg	al,ah
	out	dx,al
	inc	dx
	xchg	al,ah
	out	dx,al
	pop	dx
	ret

