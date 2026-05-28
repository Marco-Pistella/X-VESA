;#############################################################################

;	DS:BX = EDID pointer

	edid_02:

;#############################################################################

	pusha
	mov	cx,150Ch
	mov	si,OFFSET vga_message_048
	call	Write_VGA_Message
	mov	di,bx
	mov	ds: byte ptr [color_base_mem],EXTRA_COLOR
	mov	dx,ds: word ptr [di].EDID128.ManufacturerID
	mov	ch,28h
	call	Write_EDID_Manifacturer_ID
	jnc	valid_idm3
	mov	ch,2Ah
	mov	si,OFFSET vga_message_049
	call	Write_VGA_Message
valid_idm3:
	mov	ax,ds: word ptr [di].EDID128.ProductID
	mov	cx,260Dh
	mov	ds: word ptr [start_xy],cx
	call	Num_To_Str_Hex4
	call	Next_Line
	mov	eax,ds: dword ptr [di].EDID128.SerialNumber
	call	Num_To_Str_Hex8
	call	Next_Line
	movzx	ax,ds: byte ptr [di].EDID128.MfgYear
	or	ax,ax
	jne	valid_year
	mov	si,OFFSET vga_message_050
	call	Write_VGA_Message
	jmp	exit_year
valid_year:
	add	ax,1990d
	or	ds: byte ptr [status_flag_0],FLAG_THOUSANDS
	call	Write_Dec_Num_Left16
	and	ds: byte ptr [status_flag_0],NOT FLAG_THOUSANDS
exit_year:
	call	Next_Line
	mov	al,ds: byte ptr [di].EDID128.MfgWeek
	or	al,al
	jne	write_week
week_not_specified:
	mov	si,OFFSET vga_message_050
	call	Write_VGA_Message
	jmp	exit_page_02
write_week:
	cmp	al,0FFh
	je	week_not_specified
	call	Write_Dec_Num_Left8
	cmp	al,54d
	jbe	exit_page_02
	inc	ch
	mov	si,OFFSET vga_message_051
	call	Write_VGA_Message
exit_page_02:
	mov	ds: byte ptr [color_base_mem],COLOR_BASE
	popa
	ret
