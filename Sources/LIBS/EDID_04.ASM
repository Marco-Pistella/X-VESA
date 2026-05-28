;#############################################################################

;	DS:BX = EDID pointer

	edid_04:

;#############################################################################

	pusha
	mov	cx,180Ch
	mov	si,OFFSET vga_message_066
	call	Write_VGA_Message
	mov	ds: byte ptr [color_base_mem],EXTRA_COLOR
	mov	ch,26h
	movzx	ax,ds: byte ptr [bx].EDID128.Gamma
	cmp	al,0FFh
	jne	write_gamma
	mov	si,OFFSET vga_message_085
	call	Write_VGA_Message
	jmp	next_color_detail
write_gamma:
	add	ax,100d
	mov	ds: byte ptr [decimal_digits],2h
	mov	ch,29h
	call	Write_Decimal_Number16
next_color_detail:
	inc	cx
	xor	si,si
loop_color:
	mov	ch,26h
	inc	cx
	mov	al,ds: byte ptr [bx + si].EDID128.ChromaData
	call	Num_To_Str_Hex2
	inc	si
	cmp	si,10d
	jne	loop_color
	add	cl,2h
	mov	ch,2Bh
	mov 	si,OFFSET EDID128.ChromaData
	lea	di,ds: word ptr [si + 2h]
	xchg	cx,bp
	mov	cl,6h
	mov	dh,8h
loop_coor_chroma:
	xor	ax,ax
	mov	al,ds: byte ptr [bx + di]
	shl	ax,2h
	mov	dl,ds: byte ptr [bx + si]
	shr	dl,cl
	and	dl,3h
	or	al,dl
	xchg	cx,bp
	movzx	eax,ax
	imul	eax,10000d
	shr	eax,10d
	mov	ds: byte ptr [decimal_digits],4h
	call	Write_Decimal_Number16
	inc	cx
	xchg	cx,bp
	sub	cl,2h
	jnc	no_next_byte
	mov	cl,6h
	inc	si
no_next_byte:
	inc	di
	dec	dh
	jne	loop_coor_chroma
	mov	ds: byte ptr [color_base_mem],COLOR_BASE
	popa
	ret
