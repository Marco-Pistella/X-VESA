;#############################################################################

;	DS:BX = EDID pointer

	edid_03:

;#############################################################################

	pusha
	mov	cl,0Ch
	mov	ax,ds: word ptr [bx].EDID128.MaxHSize
	mov	ds: byte ptr [decimal_digits],2h
	xor	di,di
	or	ax,ax
	je	call_edid3
	add	di,2h
	or	al,al
	je	call_edid3
	add	di,2h
	or	ah,ah
	je	call_edid3
	add	di,2h
call_edid3:
	call	ds: word ptr [di + edid3_routine]
	mov	ds: byte ptr [color_base_mem],COLOR_BASE
	mov	al,ds: byte ptr [bx].EDID128.VideoInput
	mov	ah,al
	and	al,80h
	mov	ds: byte ptr [string_id],al
	mov	ch,8h
	mov	si,OFFSET vga_message_055
	call	Write_VGA_Message
	mov	ds: byte ptr [color_base_mem],EXTRA_COLOR
	mov	ch,26h
	mov	al,ds: byte ptr [bx].EDID128.Features
	mov	dx,104h
	call	Block_Yes_Or_No
	mov	dx,2080h
	call	Block_Yes_Or_No
	shr	al,3h
	and	al,3h
	test	ah,80h
	jne	digital_signal
	mov	si,OFFSET vga_message_057
	call	Write_VGA_Message
	inc	cx
	mov	si,OFFSET vga_message_059
	call	Write_Index_String
	mov	al,ah
	and	al,0Fh
	mov	dx,108h
	call	Block_Yes_Or_No
	mov	al,ah
	shr	al,4h
	and	al,1h
	mov	si,OFFSET vga_message_064
	call	Write_Index_String
	mov	al,ah
	shr	al,5h
	and	al,3h
	mov	si,OFFSET vga_message_065
	call	Write_Index_String
	mov	ds: byte ptr [color_base_mem],COLOR_BASE
	popa
	ret
digital_signal:
	mov	si,OFFSET vga_message_058
	call	Write_VGA_Message
	inc	cx
	mov	si,OFFSET vga_message_060
	call	Write_Index_String
	mov	al,ah
	mov	si,OFFSET vga_message_061
	and	al,0Fh
	call	Write_Index_String
	mov	al,ah
	shr	al,4h
	and	al,7h
	mov	si,OFFSET vga_message_063
	call	Write_Index_String
	mov	ds: byte ptr [color_base_mem],COLOR_BASE
	popa
	ret

;#############################################################################

	edid_3_1:

;#############################################################################

	mov	ch,0Dh
	mov	si,OFFSET vga_message_052
	call	Write_VGA_Message
	mov	ch,26h
	mov	ds: byte ptr [color_base_mem],EXTRA_COLOR
	mov	si,OFFSET vga_message_050
	mov	al,2h
	call	Write_Same_Message
	ret

;#############################################################################

	edid_3_2:

;#############################################################################

	mov	ch,0Dh
	mov	si,OFFSET vga_message_054
	call	Write_VGA_Message
	mov	ds: byte ptr [color_base_mem],EXTRA_COLOR
	mov	ch,29h
	movzx	di,ah
	add	di,99d
	mov	ax,10000d
	xor	dx,dx
	div	di
	call	Write_Decimal_Number16
	inc	cx
	ret

;#############################################################################

	edid_3_3:

;#############################################################################

	mov	si,OFFSET vga_message_053
	mov	ch,0Ch
	call	Write_VGA_Message
	mov	ds: byte ptr [color_base_mem],EXTRA_COLOR
	mov	ch,29h
	add	ax,99d
	call	Write_Decimal_Number16
	inc	cx
	ret

;#############################################################################

	edid_3_4:

;#############################################################################

	mov	ch,0Dh
	mov	si,OFFSET vga_message_052
	call	Write_VGA_Message
	mov	ds: byte ptr [color_base_mem],EXTRA_COLOR
	xor	di,di
loop_dims:
	mov	al,ds: byte ptr [bx + di].EDID128.MaxHSize
	mov	ch,26h
	call	Write_Dec_Num_Left8
	inc	ch
	mov	si,OFFSET vga_message_056
	call	Write_VGA_Message
	inc	cx
	inc	di
	cmp	di,2h
	jne	loop_dims
	ret
