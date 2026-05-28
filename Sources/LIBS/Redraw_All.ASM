;#############################################################################

;	DS:SI = PANEL pointer

	Redraw_All:

;#############################################################################

	pusha
	call	Invert_Select
entry_redraw_all:
	movzx	dx,ds: byte ptr [si].PANEL.TOTAL_RELATIVE_ELEMENTS
	mov	ax,ds: word ptr [si].PANEL.ABSOLUTE_ELEMENT
	mov	bl,ds: byte ptr [si].PANEL.COORD_START
	sub	bl,ds: byte ptr [si].PANEL.RELATIVE_ELEMENT
	cmp	dx,ds: word ptr [si].PANEL.TOTAL_ELEMENTS
	jb	loop_redraw_all_init
	mov	dx,ds: word ptr [si].PANEL.TOTAL_ELEMENTS
loop_redraw_all_init:
	add	dx,ax
	inc	dx
loop_redraw_all:
	mov	cl,LAST_LINE
	mov	ch,ds: byte ptr [si + 1h].PANEL.COORD_START
	mov	bh,ds: byte ptr [si].PANEL.INVERSION_LEN
	pusha
	mov	ah,ds: byte ptr [color_base_mem]
	mov	al,' '
loop_atob:
	call	Locate
	mov	fs: word ptr [di],ax
	inc	ch
	dec	bh
	jne	loop_atob
	popa
	call	ds: word ptr [si].PANEL.DRAW_OFFSET
	pusha
loop_btoa:
	mov	cl,LAST_LINE
	call	Locate
	mov	si,di
	mov     cl,bl
	call	Locate
	mov	ax,fs: word ptr [si]
	mov     fs: word ptr [di],ax
	inc	ch
	dec	bh
	jne	loop_btoa
	popa
	inc	bx
	inc	ax
	cmp	ax,dx
	jne	loop_redraw_all
	call	Invert_Select
	call	Update_Bar
	popa
	ret
Redraw_All_Init:
	pusha
	mov	al,ds: byte ptr [si].PANEL.RELATIVE_ELEMENT
	sub	ds: byte ptr [si].PANEL.COORD_START,al
	mov	ds: byte ptr [si].PANEL.RELATIVE_ELEMENT,0h
	mov	ds: word ptr [si].PANEL.ABSOLUTE_ELEMENT,0h
	jmp	entry_redraw_all
