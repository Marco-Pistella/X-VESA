;#############################################################################

;	AX = Write number
;       CH = X Coordinate
;	CL = Y Coordinate
;	FS = Video Segment

	Write_Dec_Num_Left16:

;       CH = New X Coordinate

;#############################################################################

	call	Size_Of_Number16
	add	ch,ds: byte ptr [number_count]
	dec	ch
	call	Write_Dec_Num16
	inc	ch
	ret
