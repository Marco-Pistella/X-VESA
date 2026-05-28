;#############################################################################

;	FS = Text mode video memory segment

	Clear_Screen:

;#############################################################################

	push	es
	pusha
	push	fs
	pop	es
	mov	cx,TEXT_WIDTH * TEXT_HEIGHT
	mov	ax,CLEAR_CODE
	xor	di,di
	rep	stosw
	popa
	pop	es
	ret

