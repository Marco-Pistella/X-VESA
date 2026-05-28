;#############################################################################

;	DS:SI = PANEL pointer
;	FS = Video pointer

	Invert_Select:

;#############################################################################

	pusha
	mov	al,ds: byte ptr [si].PANEL.INVERSION_COLOR
	mov	cx,ds: word ptr [si].PANEL.COORD_START
	call	Locate
	inc	di
	movzx	cx,ds: byte ptr [si].PANEL.INVERSION_LEN
loop_inversion:
	xor	fs: byte ptr [di],al
	inc	di
	inc	di
	loop	loop_inversion
	popa
	ret

