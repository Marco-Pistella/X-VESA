;#############################################################################

;	AL = Test value
;	AH = Mask test
;	CH = X coordinate
;	CL = Y coordinate
;	FS = Video Segment

	Yes_Or_No:

;	CL = Y coordinate + 1h

;#############################################################################

	push	si
	mov	si,OFFSET vga_message_022
	test	al,ah
	jne	valid_si
	mov	si,OFFSET vga_message_023
valid_si:
	call	Write_VGA_Message
	inc	cx
	inc	ds: byte ptr [start_xy]
	pop	si
	ret
