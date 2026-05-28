;#############################################################################

;	DS:SI = Header Window Pointer
;	DS:DI = Key Window Pointer
;	CH = X coordinate top left
;	CL = Y coordinate top left
;	DH = X coordinate bottom right
;	DL = Y coordinate bottom right
;	FS = Video Segment

	Extended_Box:

;#############################################################################

	pusha
	call	Box
	add	ch,HEADER_LEFT_SPACE
	call	Write_Box_Message
	mov	cl,dl
	mov	si,di
	call	Write_Box_Message
	popa
	ret
