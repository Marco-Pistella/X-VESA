;#############################################################################

;	DS:SI = String pointer
;	AX = Value
;	DS: BYTE [n_digit_str_dec] = Digit number to write

	Num_To_Str_Dec:

;#############################################################################

	pusha
	movzx	bx,ds: byte ptr [n_digit_str_dec]
	mov	cx,10d
loop_dec2asci:
	xor	dx,dx
	div	cx
	add	dl,'0'
	mov	ds: byte ptr [bx+si - 1h],dl
	dec	bx
	jne	loop_dec2asci
	popa
	ret
