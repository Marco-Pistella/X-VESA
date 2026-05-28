;#############################################################################

;	DS:SI = PANEL pointer

	Select_Item:

;	AX = Key scan code

;#############################################################################

	pusha
loop_key_05:
	call	Get_Key
	cmp	ax,UP_KEY
	jne	test_down_key
	cmp	ds: byte ptr [si].PANEL.RELATIVE_ELEMENT,0h
	jne	select_item_up
	cmp	ds: word ptr [si].PANEL.ABSOLUTE_ELEMENT,0h
	je	loop_key_05
	dec	ds: word ptr [si].PANEL.ABSOLUTE_ELEMENT
	call	Redraw_All
	jmp	loop_key_05
select_item_up:
	call	Invert_Select
	dec	ds: byte ptr [si].PANEL.RELATIVE_ELEMENT
	dec	ds: byte ptr [si].PANEL.COORD_START
	call	Invert_Select
	call	Update_Bar
	jmp	loop_key_05
test_down_key:
	cmp	ax,DOWN_KEY
	jne	test_end_key
	movzx	ax,ds: byte ptr [si].PANEL.TOTAL_RELATIVE_ELEMENTS
	cmp	ax,ds: word ptr [si].PANEL.TOTAL_ELEMENTS
	jbe	ok_lenght
	mov	al,ds: byte ptr [si].PANEL.RELATIVE_ELEMENT
	cmp	al,ds: byte ptr [si].PANEL.TOTAL_ELEMENTS
	je	loop_key_05
	jmp	select_item_down
ok_lenght:
	mov	al,ds: byte ptr [si].PANEL.RELATIVE_ELEMENT
	cmp	al,ds: byte ptr [si].PANEL.TOTAL_RELATIVE_ELEMENTS
	jne	select_item_down
	add	ax,ds: word ptr [si].PANEL.ABSOLUTE_ELEMENT
	cmp	ax,ds: word ptr [si].PANEL.TOTAL_ELEMENTS
	je      loop_key_05
valid_down_key:
	inc	ds: word ptr [si].PANEL.ABSOLUTE_ELEMENT
	call	Redraw_All
	jmp	loop_key_05
select_item_down:
	call	Invert_Select
	inc	ds: byte ptr [si].PANEL.RELATIVE_ELEMENT
	inc	ds: byte ptr [si].PANEL.COORD_START
	call	Invert_Select
	call	Update_Bar
	jmp	loop_key_05
test_end_key:
	cmp	ax,END_KEY
	jne	test_home_key
entry_end:
	mov	ax,ds: word ptr [si].PANEL.TOTAL_ELEMENTS
	movzx	bx,ds: byte ptr [si].PANEL.TOTAL_RELATIVE_ELEMENTS
	sub	ax,bx
	jnc	minus_mode
	xor	ax,ax
	mov	bl,ds: byte ptr [si].PANEL.TOTAL_ELEMENTS
minus_mode:
	mov	ds: word ptr [si].PANEL.ABSOLUTE_ELEMENT,ax
	call	Invert_Select
	mov	al,ds: byte ptr [si].PANEL.RELATIVE_ELEMENT
	mov	ds: byte ptr [si].PANEL.RELATIVE_ELEMENT,bl
	sub	bl,al
	add	ds: byte ptr [si].PANEL.COORD_START,bl
	call	Invert_Select
	call	Redraw_All
	jmp	loop_key_05
test_home_key:
	cmp	ax,HOME_KEY
	jne	test_pgup_key
entry_home:
	call	Invert_Select
	mov	al,ds: byte ptr [si].PANEL.RELATIVE_ELEMENT
	sub	ds: byte ptr [si].PANEL.COORD_START,al
	call	Invert_Select
	mov	ds: byte ptr [si].PANEL.RELATIVE_ELEMENT,0h
	mov	ds: word ptr [si].PANEL.ABSOLUTE_ELEMENT,0h
	call	Redraw_All
	jmp	loop_key_05
test_pgup_key:
	cmp	ax,PGUP_KEY
	jne	test_pgdn_key
	mov	ax,ds: word ptr [si].PANEL.ABSOLUTE_ELEMENT
	movzx	bx,ds: byte ptr [si].PANEL.TOTAL_RELATIVE_ELEMENTS
	sub	ax,bx
	jc	minus_due
	mov	ds: word ptr [si].PANEL.ABSOLUTE_ELEMENT,ax
	call	Redraw_All
	jmp	loop_key_05
minus_due:
	movzx	ax,ds: byte ptr [si].PANEL.RELATIVE_ELEMENT
	add	ax,ds: word ptr [si].PANEL.ABSOLUTE_ELEMENT
	movzx	bx,ds: byte ptr [si].PANEL.TOTAL_RELATIVE_ELEMENTS
	sub	ax,bx
	jbe	entry_home
	call	Invert_Select
	mov	ds: word ptr [si].PANEL.ABSOLUTE_ELEMENT,0h
	mov	bl,ds: byte ptr [si].PANEL.RELATIVE_ELEMENT
	mov	ds: byte ptr [si].PANEL.RELATIVE_ELEMENT,al
	sub	bl,al
	sub	ds: byte ptr [si].PANEL.COORD_START,bl
	call	Invert_Select
	call	Redraw_All
	jmp	loop_key_05
test_pgdn_key:
	cmp	ax,PGDN_KEY
	jne	exit_select_item
	movzx   ax,ds: byte ptr [si].PANEL.TOTAL_RELATIVE_ELEMENTS
	add	ax,ds: word ptr [si].PANEL.ABSOLUTE_ELEMENT
	movzx	bx,ds: byte ptr [si].PANEL.RELATIVE_ELEMENT
	add	ax,bx
	movzx	bx,ds: byte ptr [si].PANEL.TOTAL_RELATIVE_ELEMENTS
	sub	bl,ds: byte ptr [si].PANEL.RELATIVE_ELEMENT
	add	ax,bx
	cmp	ax,ds: word ptr [si].PANEL.TOTAL_ELEMENTS
	ja	minus_quattro
	movzx	ax,ds: byte ptr [si].PANEL.TOTAL_RELATIVE_ELEMENTS
	add	ds: word ptr [si].PANEL.ABSOLUTE_ELEMENT,ax
	call	Redraw_All
	jmp	loop_key_05
minus_quattro:
	mov	ax,ds: word ptr [si].PANEL.TOTAL_ELEMENTS
	movzx	bx,ds: byte ptr [si].PANEL.RELATIVE_ELEMENT
	add	bx,ds: word ptr [si].PANEL.ABSOLUTE_ELEMENT
	sub	ax,bx
	movzx	bx,ds: byte ptr [si].PANEL.TOTAL_RELATIVE_ELEMENTS
	cmp	ax,bx
	jbe	entry_end
	sub	ax,bx
	call	Invert_Select
	mov	bl,ds: byte ptr [si].PANEL.TOTAL_RELATIVE_ELEMENTS
	sub	bl,al
	mov	al,ds: byte ptr [si].PANEL.RELATIVE_ELEMENT
	sub	al,bl
	sub	ds: byte ptr [si].PANEL.COORD_START,al
	mov	ds: byte ptr [si].PANEL.RELATIVE_ELEMENT,bl
	mov	ax,ds: word ptr [si].PANEL.TOTAL_ELEMENTS
	movzx	bx,ds: byte ptr [si].PANEL.TOTAL_RELATIVE_ELEMENTS
	sub	ax,bx
	mov	ds: word ptr [si].PANEL.ABSOLUTE_ELEMENT,ax
	call	Invert_Select
	call	Redraw_All
	jmp	loop_key_05
exit_select_item:
	call	Exit_Return_AX
	popa
	ret
