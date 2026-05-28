;#############################################################################

;	CH = X Coordinate
;	CL = Y Coordinate
;	AL = Write number
;	FS = Video Segment

	Write_Dec_Num8:

;#############################################################################

	push	ax
	movzx	ax,al
	call	Write_Dec_Num16
	pop	ax
	ret
