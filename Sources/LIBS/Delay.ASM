;#############################################################################

;	BX = Wait time in 61h change state

	Delay:

;#############################################################################

	pusha
	xor	ah,ah
loop_refresh:
	in	al,61h
	and	al,10h
	cmp	al,ah
	je	loop_refresh
	mov	ah,al
	dec	bx
	jne	loop_refresh
	popa
	ret
