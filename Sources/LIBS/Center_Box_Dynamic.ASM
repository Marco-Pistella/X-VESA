;#############################################################################

;	AH = X lenght
;	AL = Y lenght
;	FS = Video Segment

	Center_Box_Dynamic:

;	CH = X coordinate top left
;	CL = Y coordinate top left
;	DH = X coordinate bottom right
;	DL = Y coordinate bottom right

;#############################################################################

	mov	cx,(TEXT_WIDTH SHL 8h) + TEXT_HEIGHT
	sub	cx,ax
	shr	ch,1h
	shr	cl,1h
	mov	dx,cx
	sub	dx,101h
	add	dx,ax
	ret
