;#############################################################################

;	AL = n times
;	CH = X coordinate
;	CL = Y coordinate
;	DS:SI = String pointer
;	FS = Video Segment

	Write_Same_Message:

;	CL = Y coordinate + AL

;#############################################################################

	push	ax
loop_same_message:
	call	Write_VGA_Message
	inc	cx
	dec	al
	jne	loop_same_message
	mov	ds: word ptr [start_xy],cx
	pop	ax
	ret
