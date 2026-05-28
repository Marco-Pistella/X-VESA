;#############################################################################

;	DS:BX = EDID pointer

	edid_01:

;#############################################################################

	pusha
	mov	cx,130Ch
	mov	si,OFFSET vga_message_040
	call	Write_VGA_Message
	mov	ds: byte ptr [color_base_mem],EXTRA_COLOR
	mov	ch,26h
	mov	ds: word ptr [start_xy],cx
	lea	si,ds: word ptr [bx].EDID128.Header
loop_padding:
	lodsb
	call	Num_To_Str_Hex2
	inc	ch
	cmp	ch,3Eh
	jne	loop_padding
	call	Next_Line
	mov	al,ds: byte ptr [bx].EDID128.EdidVersion
	call	Write_Dec_Num_Left8
	cmp	al,1h
	je	valid_version
	inc	ch
	mov	si,OFFSET vga_message_100
	call	Write_VGA_Message
valid_version:
	call	Next_Line
	mov	al,ds: byte ptr [bx].EDID128.EdidRevision
	call	Write_Dec_Num_Left8
	cmp	al,4h
	jbe	valid_revision
	inc	ch
	mov	si,OFFSET vga_message_101
	call	Write_VGA_Message
valid_revision:
	call	Next_Line
	mov	al,ds: byte ptr [bx].EDID128.Checksum
	call    Num_To_Str_Hex2
	call	Next_Line
	mov	al,ds: byte ptr [bx].EDID128.ExtensionFlag
	mov	si,OFFSET vga_message_097
	cmp	al,0FFh
	jne	write_block_count
write_block_data:
	call	Write_VGA_Message
	jmp	view_checksum
write_block_count:
	mov	si,OFFSET vga_message_099
	or	al,al
	je	write_block_data
	call	Write_Dec_Num_Left8
view_checksum:
	call	Next_Line
	mov	al,ds: byte ptr [status_flag_1]
	shr	al,3h
	and	al,3h
	mov	si,OFFSET vga_message_022
	call	Write_Index_String
	mov	ds: byte ptr [color_base_mem],COLOR_BASE
	popa
	ret
