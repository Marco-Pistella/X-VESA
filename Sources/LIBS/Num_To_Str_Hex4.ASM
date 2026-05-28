;#############################################################################

;	CH = X Coordinate
;	CL = Y Coordinate
;	AX = Hex number
;	FS = Video Segment

	Num_To_Str_Hex4:

;#############################################################################

	push	cx
	push	di
	call	Locate
	mov	cl,DIGIT_4
	call	Num_To_Str_Hex
	pop	di
	pop	cx
	add	ch,4h
	ret

