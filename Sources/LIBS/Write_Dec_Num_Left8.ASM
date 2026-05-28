;#############################################################################

;	AL = Write number
;       CH = X Coordinate
;	CL = Y Coordinate
;	FS = Video Segment

	Write_Dec_Num_Left8:

;       CH = New X Coordinate

;#############################################################################

	call	Size_Of_Number8
	add	ch,ds: byte ptr [number_count]
	dec	ch
	call	Write_Dec_Num8
	inc	ch
	ret
