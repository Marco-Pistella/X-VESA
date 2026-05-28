;#############################################################################

	Get_VESA_Scanline:

;	CARRY = 0 -> Valid scanline lenght
;		DS:[scanline_vesa_pixel] = Scanline lenght in pixel
;		DS:[scanline_vesa_bytes] = Scanline lenght in bytes
;			Chars in TEXT_MODE
;	CARRY = 1 -> Fail scanline lenght

;#############################################################################

	pusha
	cmp	ds: byte ptr [bx].VESA_MODE_PANEL.VIDEO_MODE_MODEL,VESA_MODE_TEXT
	jne	no_text_scanline_get
	mov	ah,13h
	call	Get_CRTC
	movzx	ax,al
	add	ax,ax
	mov	ds: word ptr [scanline_vesa_pixel],ax
	add	ax,ax
	mov	ds: word ptr [scanline_vesa_bytes],ax
	clc
	popa
	ret
no_text_scanline_get:
	mov	ax,(VESA_ID SHL 8h) + VESA_FUNC_SET_SCAN_LINE
	mov	bx,1h
	VIDEO_CALL
	cmp	ax,VESA_ID
	jne	invalid_get_bpsl_1
	mov	ds: word ptr [scanline_vesa_pixel],cx
	mov	ds: word ptr [scanline_vesa_bytes],bx
	clc
	popa
	ret
invalid_get_bpsl_1:
	stc
	popa
	ret
