;#############################################################################

;	CH = X Coordinate
;	CL = Y Coordinate
;	AX = Write number
;	FS = Video Segment

	Write_Dec_Num16:

;#############################################################################

	push	eax
	movzx	eax,ax
	call	Write_Dec_Num32
	pop	eax
	ret
