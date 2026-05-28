;#############################################################################

;	CH = Coordinata X
;	CL = Coordinata Y
;	AL = Numero esadecimale
;	FS = Segmento video

	Num_To_Str_Hex2:

;#############################################################################

	push	cx
	push	di
	call	Locate
	mov	cl,DIGIT_2
	call	Num_To_Str_Hex
	pop	di
	pop	cx
	add	ch,2h
	ret

