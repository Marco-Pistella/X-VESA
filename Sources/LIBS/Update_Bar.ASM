;#############################################################################

;	DS:SI = PANEL pointer

	Update_Bar:

;#############################################################################

	pusha
	test	ds: byte ptr [si].PANEL.PANEL_FLAGS,NO_BAR
	jne	exit_update_bar
	mov	cx,ds: word ptr [si].PANEL.COOR_BAR
	mov	al,18h
	call	Write_Char
	dec	ch
	inc	cx
	movzx	ax,ds: byte ptr [si].PANEL.RELATIVE_ELEMENT
	add	ax,ds: word ptr [si].PANEL.ABSOLUTE_ELEMENT
	movzx	bx,ds: byte ptr [si].PANEL.BAR_ELEMENTS
	mul	bx
	mov	bp,ds: word ptr [si].PANEL.TOTAL_ELEMENTS
	or	bp,bp
	jne	valid_bp
	inc	bp
valid_bp:
	div	bp
	add	dx,dx
	cmp	dx,bp
	jb	no_inc_ax
	inc	ax
no_inc_ax:
	xor	bl,bl
	xchg	al,ah
loop_write_bar:
	mov	al,'°'
	cmp	ah,bl
	jne	invalid_bar
	mov	al,'²'
invalid_bar:
	call	Write_Char
	dec	ch
	inc	cx
	inc	bx
	cmp	bl,ds: byte ptr [si].PANEL.BAR_ELEMENTS
	jbe	loop_write_bar
	mov	al,19h
	call	Write_Char
exit_update_bar:
	popa
	ret
