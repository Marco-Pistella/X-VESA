;#############################################################################

;	CH = X Coordinate
;	CL = Y Coordinate
;	EAX = Hex number
;	FS = Video Segment

	Num_To_Str_Hex8:

;#############################################################################

	rol	eax,10h
	call	Num_To_Str_Hex4
	rol	eax,10h
	call	Num_To_Str_Hex4
	ret
