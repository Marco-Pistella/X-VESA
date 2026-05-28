;#############################################################################

;	DS:BX = EDID pointer

	edid_06:

;#############################################################################

	pusha
	mov	cx,1A0Ch
	mov	si,OFFSET vga_message_102
	call	Write_VGA_Message
	mov	cx,1B0Dh
	mov	si,OFFSET vga_message_075
	call	Write_VGA_Message
	mov	cx,0E0Eh
	mov	si,OFFSET vga_message_076
	call	Write_VGA_Message
	mov	ds: byte ptr [color_base_mem],EXTRA_COLOR
	add	bx,OFFSET EDID128.Desc1
	mov	ch,22h
loop_desc_edid:
	mov	cl,0Eh
	push	cx
	mov	ax,ds: word ptr [bx]
	or	ax,ax
	jne	valid_descriptor
	sub	ch,5h
	mov	si,OFFSET vga_message_077
	mov	al,21d
	call	Write_Same_Message
	jmp	next_descriptor
valid_descriptor:
	mov	ds: word ptr [start_xy],cx
	mov	ds: byte ptr [decimal_digits],2h
	call	Write_Decimal_Number16
	add	ch,2h
	mov	si,OFFSET vga_message_078
	call	Write_VGA_Message
	mov	di,2h
loop_hv_snc:
	call	Next_Line
	mov	al,ds: byte ptr [bx + di]
	mov	ah,ds: byte ptr [bx + di + 2]
	shr	ah,4h
	call	Write_Dec_Num16
	add	ch,2h
	mov	si,OFFSET vga_message_079
	call	Write_VGA_Message
	call	Next_Line
	mov	al,ds: byte ptr [bx + di + 1h]
	mov	ah,ds: byte ptr [bx + di + 2h]
	and	ah,0Fh
	call	Write_Dec_Num16
	add	ch,2h
	mov	si,OFFSET vga_message_079
	call	Write_VGA_Message
	add	di,3h
	cmp	di,8h
	jne	loop_hv_snc
	call	Next_Line
	mov	al,ds: byte ptr [bx + 8h]
	mov	ah,ds: byte ptr [bx + 0Bh]
	shr	ah,6h
	call	Write_Dec_Num16
	add	ch,2h
	mov	si,OFFSET vga_message_079
	call	Write_VGA_Message
	call	Next_Line
	mov	al,ds: byte ptr [bx + 9h]
	mov	ah,ds: byte ptr [bx + 0Bh]
	shr	ah,4h
	and	ah,3h
	call	Write_Dec_Num16
	add	ch,2h
	mov	si,OFFSET vga_message_079
	call	Write_VGA_Message
	call	Next_Line
	mov	al,ds: byte ptr [bx + 0Ah]
	shr	al,4h
	mov	ah,ds: byte ptr [bx + 0Bh]
	and	ah,0Ch
	shl	ah,2h
	or	al,ah
	call	Write_Dec_Num8
	add	ch,2h
	mov	si,OFFSET vga_message_079
	call	Write_VGA_Message
	call	Next_Line
	mov	al,ds: byte ptr [bx + 0Ah]
	and	al,0Fh
	mov	ah,ds: byte ptr [bx + 0Bh]
	and	ah,3h
	shl	ah,3h
	or	al,ah
	call	Write_Dec_Num8
	add	ch,2h
	mov	si,OFFSET vga_message_079
	call	Write_VGA_Message
	call	Next_Line
	mov	al,ds: byte ptr [bx + 0Ch]
	mov	ah,ds: byte ptr [bx + 0Eh]
	shr	ah,4h
	call	Write_Dec_Num16
	add	ch,2h
	mov	si,OFFSET vga_message_080
	call	Write_VGA_Message
	call	Next_Line
	mov	al,ds: byte ptr [bx + 0Dh]
	mov	ah,ds: byte ptr [bx + 0Eh]
	and	ah,0Fh
	call	Write_Dec_Num16
	add	ch,2h
	mov	si,OFFSET vga_message_080
	call	Write_VGA_Message
	call	Next_Line
	mov	al,ds: byte ptr [bx + 0Fh]
	call	Write_Dec_Num8
	add	ch,2h
	mov	si,OFFSET vga_message_079
	call	Write_VGA_Message
	call	Next_Line
	mov	al,ds: byte ptr [bx + 10h]
	call	Write_Dec_Num8
	add	ch,2h
	mov	si,OFFSET vga_message_079
	call	Write_VGA_Message
	call	Next_Line
	sub	ch,7h
	mov	al,ds: byte ptr [bx + 11h]
	mov	ah,80h
	call	Yes_Or_No
	mov	ah,al
	and	al,1h
	shr	ah,4d
	and	ah,6h
	or	al,ah
	and	al,7h
	mov	si,OFFSET vga_message_081
	call	Write_Index_String
	mov	dl,ds: byte ptr [bx + 11h]
	mov	al,dl
	shr	al,4h
	and	al,1h
	mov	si,OFFSET vga_message_057
	call	Write_Index_String
	mov	al,dl
	shr	al,3h
	and	al,1h
	test	dl,10h
	jne	edid_6_digital
	mov	si,OFFSET vga_message_082
	call	Write_Index_String
	mov	al,dl
	mov	ah,4h
	call	Yes_Or_No
	mov	al,dl
	and	al,1h
	mov	si,OFFSET vga_message_084
	call	Write_Index_String
	mov	si,OFFSET vga_message_085
	mov	al,2h
	call	Write_Same_Message
	jmp	next_descriptor
edid_6_digital:
	mov	si,OFFSET vga_message_083
	call	Write_Index_String
	or	al,al
	jne	no_serration_6
	mov	al,dl
	mov	ah,4h
	call	Yes_Or_No
	mov	si,OFFSET vga_message_085
	mov	al,2h
	call	Write_Same_Message
	jmp	edid_6_polarity
no_serration_6:	
	mov	si,OFFSET vga_message_085
	mov	al,2h
	call	Write_Same_Message
	mov	al,dl
	shr	al,1h
	and	al,1h
	mov	si,OFFSET vga_message_086
	call	Write_Index_String
edid_6_polarity:
	mov	si,OFFSET vga_Message_086
	mov	al,dl
	and	al,1h
	call	Write_Index_String
next_descriptor:
	pop	cx
	add	bx,18d
	add	ch,0Dh
	cmp	ch,56h
	jne	loop_desc_edid
	mov	ds: byte ptr [color_base_mem],COLOR_BASE
	popa
	ret
