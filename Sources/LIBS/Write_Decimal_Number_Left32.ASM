;#############################################################################

;	ds: byte ptr [decimal_digits] = number of significant figures
;	EAX = Decimal number
;	CH = X coordinate
;	CL = Y coordinate
;	FS = Video Segment

	Write_Decimal_Number_Left32:

;#############################################################################

	pusha
	push	eax
	mov	bh,0FFh
	mov	bl,ds: byte ptr [decimal_digits]
	mov	edi,10d
loop_write_decimal_left:
	or	bl,bl
	jns	dec_num_left
	or	eax,eax
	je	exit_dec_num_left
dec_num_left:
	xor	edx,edx
	div	edi
	inc	bh
	dec	bl
	jne	loop_write_decimal_left
	inc	bh
	jmp	loop_write_decimal_left
exit_dec_num_left:
	pop	eax
	add	ch,bh
	mov	ds: byte ptr [number_count],bh
	call	Write_Decimal_Number32
	popa
	add	ch,ds: byte ptr [number_count]
	ret
