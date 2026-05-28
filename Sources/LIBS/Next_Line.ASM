;#############################################################################

;	ds: word ptr [start_xy] = Init coordinates

	Next_Line:

;       CH = New X Coordinate
;       CH = New Y Coordinate

;#############################################################################

	inc	ds: byte ptr [start_xy]
	mov	cx,ds: word ptr [start_xy]
	ret
