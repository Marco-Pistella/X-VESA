;#############################################################################

;	DS:BX = Pointer to vesa_mode_info video mode
;	AX = Scanline lenght in bytes (SCANLINE_FORM = 0)
;	AX = Scanline lenght in pixel (SCANLINE_FORM = 1)
;		Chars in TEXT_MODE

	Set_VESA_Scanline:

;	CARRY = 0 -> Valid scanline lenght
;		AX = Scanline lenght in bytes (SCANLINE_FORM = 0)
;		AX = Scanline lenght in pixel (SCANLINE_FORM = 1)
;			Chars in TEXT_MODE
;		DS:[scanline_vesa_pixel] = Scanline lenght in pixel
;		DS:[scanline_vesa_bytes] = Scanline lenght in bytes
;			Chars in TEXT_MODE
;	CARRY = 1 -> Fail scanline lenght

;#############################################################################

	pusha
	test	ds: byte ptr [status_flag_2],SCANLINE_FORM
	jne	go_scanline_pixel
	cmp	ds: byte ptr [bx].VESA_MODE_PANEL.VIDEO_MODE_MODEL,VESA_MODE_TEXT
	jne	no_text_scanline_bytes
	mov	ds: word ptr [scanline_vesa_bytes],ax
	shr	ax,1h
	mov	ds: word ptr [scanline_vesa_pixel],ax
	shr	ax,1h
	mov	ah,13h
	call	Set_CRTC
	jmp	valid_scanline_1
no_text_scanline_bytes:
	push	ax
	push	bx
	xchg	ax,cx
	mov	ax,(VESA_ID SHL 8h) + VESA_FUNC_SET_SCAN_LINE
	mov	bx,2h
	VIDEO_CALL
	cmp	ax,VESA_ID
	mov	ds: word ptr [scanline_vesa_pixel],cx
	mov	ds: word ptr [scanline_vesa_bytes],bx
	pop	bx
	pop	cx
	je	valid_scanline_1
	mov	ax,8h
	mul	cx
	push	eax
	push	ecx
	push	edx
	push	dx
	push	ax
	pop	eax
	movzx	ecx,ds: byte ptr [bx].VESA_MODE_PANEL.MEMORY_BPP
	xor	edx,edx
	div	ecx
	cmp	eax,10000h
	pop	edx
	pop	ecx
	xchg	ax,cx
	pop	eax	
	jae	fail_scanline_1
	mov	ax,(VESA_ID SHL 8h) + VESA_FUNC_SET_SCAN_LINE
	xor	bx,bx
	VIDEO_CALL
	cmp	ax,VESA_ID
	mov	ds: word ptr [scanline_vesa_pixel],cx
	mov	ds: word ptr [scanline_vesa_bytes],bx
	je	valid_scanline_1
	stc
	popa
	ret
valid_scanline_1:
	mov	ax,ds: word ptr [scanline_vesa_bytes]
	call	Exit_Return_AX
	clc
	popa
	ret
go_scanline_pixel:
	cmp	ds: byte ptr [bx].VESA_MODE_PANEL.VIDEO_MODE_MODEL,VESA_MODE_TEXT
	jne	no_text_scanline_pixel
	mov	ds: word ptr [scanline_vesa_pixel],ax
	shl	ax,1h
	mov	ds: word ptr [scanline_vesa_bytes],ax
	shr	ax,2h
	mov	ah,13h
	call	Set_CRTC
	jmp	valid_scanline_2
no_text_scanline_pixel:
	push	ax
	push	bx
	xchg	ax,cx
	mov	ax,(VESA_ID SHL 8h) + VESA_FUNC_SET_SCAN_LINE
	xor	bx,bx
	VIDEO_CALL
	cmp	ax,VESA_ID
	mov	ds: word ptr [scanline_vesa_pixel],cx
	mov	ds: word ptr [scanline_vesa_bytes],bx
	pop	bx
	pop	cx
	je	valid_scanline_2
	movzx	ax,ds: byte ptr [bx].VESA_MODE_PANEL.MEMORY_BPP
	mul	cx
	push	eax
	push	ecx
	push	edx
	mov	ecx,8h
	push	dx
	push	ax
	pop	eax
	xor	edx,edx
	div	ecx
	cmp	eax,10000h
	pop	edx
	pop	ecx
	xchg	ax,cx
	pop	eax	
	jae	fail_scanline_1
	mov	ax,(VESA_ID SHL 8h) + VESA_FUNC_SET_SCAN_LINE
	mov	bx,2h
	VIDEO_CALL
	cmp	ax,VESA_ID
	mov	ds: word ptr [scanline_vesa_pixel],cx
	mov	ds: word ptr [scanline_vesa_bytes],bx
	je	valid_scanline_2
fail_scanline_1:
	stc
	popa
	ret
valid_scanline_2:
	mov	ax,ds: word ptr [scanline_vesa_pixel]
	call	Exit_Return_AX
	clc
	popa
	ret
