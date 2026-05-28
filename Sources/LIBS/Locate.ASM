;#############################################################################

;	CH = X coordinate
;	CL = Y coordinate

	Locate:

;	FS:DI = Offset video memory

;#############################################################################

	xchg	ax,di
	mov	al,TEXT_WIDTH
	mul	cl
	add	al,ch
	adc	ah,ZERO
	add	ax,ax
	xchg	ax,di
	ret
