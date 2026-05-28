;#############################################################################

	Cursor_On:

;#############################################################################

	pusha
	mov	ah,CRTC_CURSOR_START
	call	Get_CRTC
	and	al,NOT CRTC_CURSOR_OFF
	call	Set_CRTC
	popa
	ret
