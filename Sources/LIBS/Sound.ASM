;#############################################################################

;	AX = Frequency
;	BX = Time in millisecs

	Sound:

;#############################################################################

	pusha
	mov	cx,ax
	mov	al,0B6h
	out	43h,al
	mov	dx,12h
	mov	ax,34DDh
	div	cx
	out	42h,al
	mov	al,ah
	out	42h,al
	in	al,61h
	or	al,3h
	out	61h,al
	imul	bx,66d
	call	Delay
	in	al,61h
	and	al,0FCh
	out	61h,al
	popa
	ret
