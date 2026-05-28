;#############################################################################

;	DS:SI = VBOX struct pointer

	Write_Graphic_Box_Fill:

;#############################################################################

	pusha
	mov	di,OFFSET vesa_line
	xchg	si,di
	mov	ax,ds: word ptr [di].VBOX.X_START
	mov	ds: word ptr [si].LINE.X_POS,ax
	mov	bp,ds: word ptr [di].VBOX.X_END
	sub	bp,ax
	inc	bp
	mov	ds: word ptr [si].LINE.LEN,bp
	mov	ax,ds: word ptr [di].VBOX.Y_START
	mov	ds: word ptr [si].LINE.Y_POS,ax
	mov	bp,ds: word ptr [di].VBOX.Y_END
	sub	bp,ax
	inc	bp
loop_box_fill:
	call	Write_Horizontal_Line
	inc	ds: word ptr [si].LINE.Y_POS
	dec	bp
	jne	loop_box_fill
	popa
	ret
