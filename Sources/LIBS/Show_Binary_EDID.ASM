;#############################################################################

;	DS:BX = EDID pointer

	Show_Binary_EDID:

;#############################################################################

	pusha
	call	Clear_Screen
	CENTER_BOX TEXT_WIDTH,0Ch
	mov	di,OFFSET vga_message_007
	mov	si,OFFSET vga_message_037
	call	Extended_Box
	add	cx,402h
	mov	si,bx
	call	Show_Binary_EDID_1
loop_key_bin:
	call	Get_Key
	cmp	ax,ESC_KEY
	jne	loop_key_bin
	popa
	ret

;#############################################################################

	Show_Binary_EDID_1:

;#############################################################################

	pusha
	mov	dx,810h
	xor	di,di
loop_binary_r:
	mov	ds: byte ptr [color_base_mem],COLOR_BASE
	mov	ax,di
	call	Num_to_Str_Hex2
	inc	ch
	mov	al,'-'
	call	Write_Char
	inc	ch
	mov	ds: byte ptr [color_base_mem],EXTRA_COLOR
	mov	bh,3Ch
loop_binary_c:
	lodsb
	call	Num_To_Str_Hex2
	xchg	ch,bh
	mov	ds: byte ptr [color_base_mem],BIN_COLOR
	call	Write_Char
	mov	ds: byte ptr [color_base_mem],EXTRA_COLOR
	xchg	ch,bh
	inc	ch
	cmp	dl,9h
	jne	no_pipe
	mov	al,'|'
	call	Write_Char
	inc	ch
no_pipe:
	dec	dl
	jne	loop_binary_c
	mov	dl,10h
	mov	ch,4h
	inc	cx
	add	di,10h
	dec	dh
	jne	loop_binary_r
	mov	ds: byte ptr [color_base_mem],COLOR_BASE
	popa
	ret
