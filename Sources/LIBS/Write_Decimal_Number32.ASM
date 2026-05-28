;#############################################################################

;	ds: byte ptr [decimal_digits] = number of significant figures
;	EAX = Decimal number
;	CH = X coordinate
;	CL = Y coordinate
;	FS = Video Segment

	Write_Decimal_Number32:

;#############################################################################

	pusha
	mov	bl,ds: byte ptr [decimal_digits]
	mov	edi,10d
loop_write_decimal:
	or	bl,bl
	jns	dec_num
	or	eax,eax
	je	exit_dec_num
dec_num:
	xor	edx,edx
	div	edi
	xchg	eax,edx
	add	al,'0'
	call	Write_Char
	sub	ch,2h
	xchg	eax,edx
	dec	bl
	jne	loop_write_decimal
	xchg	ax,si
	mov	al,ds: byte ptr [decimal_sign]
	call	Write_Char
	xchg	ax,si
	sub	ch,2h
	jmp	loop_write_decimal
exit_dec_num:
	popa
	ret
