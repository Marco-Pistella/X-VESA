;#############################################################################

;	CH = X coordinate
;	CL = Y coordinate

	Cursor_Pos:

;#############################################################################

	pusha
	call	Locate
	mov	dx,di
	shr	dx,1h
	mov	ah,CRTC_CURSOR_HIGH_ADDRESS
	mov	al,dh
	call	Set_CRTC
	mov	ah,CRTC_CURSOR_LOW_ADDRESS
	mov	al,dl
	call	Set_CRTC
	popa
	ret