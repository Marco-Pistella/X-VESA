;#############################################################################

	Get_Port:

;	DX = CRTC Port

;#############################################################################

	push	ax
	call	Get_Miscellaneous
	and	al,CRTC_ADDRESS
	shl	al,CRTC_ADDRESS_SHIFT
	mov	dx,CRTC_MONO
	add	dl,al
	pop	ax
	ret
