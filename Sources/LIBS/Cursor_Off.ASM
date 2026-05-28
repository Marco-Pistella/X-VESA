;#############################################################################

	Cursor_Off:

;#############################################################################

	pusha
	mov	ah,CRTC_CURSOR_START
	call	Get_CRTC
	or	al,CRTC_CURSOR_OFF
	call	Set_CRTC
	popa
	ret
