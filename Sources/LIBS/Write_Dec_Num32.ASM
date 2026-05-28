;#############################################################################

;	CH = X Coordinate
;	CL = Y Coordinate
;	EAX = Write number
;	FS = Video Segment

	Write_Dec_Num32:

;#############################################################################

	push	edx
	xor	edx,edx
	call	Write_Dec_Num64
	pop	edx
	ret
