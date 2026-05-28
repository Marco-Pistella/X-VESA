;#############################################################################

;	DL = Cursor start row
;	DH = Cursor end row

	Cursor_Size:

;#############################################################################

	pusha
	mov	ah,CRTC_CURSOR_START
	call	Get_CRTC
	and	al,CRTC_CURSOR_OFF
	or	al,dl
	call	Set_CRTC
	mov	ah,CRTC_CURSOR_END
	call	Get_CRTC
	and	al,CRTC_CURSOR_DELAY
	or	al,dh
	call	Set_CRTC
	popa
	ret
