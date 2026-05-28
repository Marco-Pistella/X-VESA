;#############################################################################

;	AL = Char
;	CH = X coordinate
;	CL = Y coordinate
;	FS = Video Segment

	Write_Char:

;#############################################################################

	push	ax
	push	di
	call	Locate
	mov	ah,ds: byte ptr [color_base_mem]
	mov	fs: word ptr [di],ax
	pop	di
	pop	ax
	inc	ch
	ret
