;#############################################################################

;	EAX = Write number
;       CH = X Coordinate
;	CL = Y Coordinate
;	FS = Video Segment

	Write_Dec_Num_Left32:

;       CH = New X Coordinate

;#############################################################################

	call	Size_Of_Number32
	add	ch,ds: byte ptr [number_count]
	dec	ch
	call	Write_Dec_Num32
	inc	ch
	ret
