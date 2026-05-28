;#############################################################################

;	AH = Register

	Get_Sequencer:

;	AL = Read value

;#############################################################################

	push	dx
	mov	dx,VGA_SEQUENCER
	mov	al,ah
	out	dx,al
	inc	dx
	in	al,dx
	pop	dx
	ret

