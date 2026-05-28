;#############################################################################

;	AX = Timer secs
;	CX = X coordinate
;	DX = Y coordinate

	Write_Timer:

;#############################################################################

	pusha
	mov	si,OFFSET vga_message_217
	call	Write_VGA_Message
	xor	dx,dx
	mov	bx,60d
	div	bx	
	add	ch,7h
	xchg	ax,dx
	call	Write_Dec_Num16
	xchg	ax,dx
	xor	dx,dx
	div	bx
	sub	ch,3h
	xchg	ax,dx
	call	Write_Dec_Num16
	xchg	ax,dx
	sub	ch,3h
	call	Write_Dec_Num16
	popa
	ret
