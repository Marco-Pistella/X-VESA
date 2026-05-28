;#############################################################################

;	DI = Offset video memory

	Unlocate:

;	CH = X coordinate
;	CL = Y coordinate

;#############################################################################

	push	ax
	mov	ax,di
	shr	ax,1h
	mov	cl,TEXT_WIDTH
	div	cl
	xchg	ax,cx
	pop	ax
	ret
