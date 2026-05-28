;#############################################################################

;	DS:BX = EDID pointer

	edid_09:

;#############################################################################

	pusha
	mov	cx,817h
	mov	si,OFFSET vga_message_107
	call	Write_VGA_Message
	mov	cx,120Ch
	mov	si,OFFSET vga_message_104
	call	Write_VGA_Message
	mov	ds: byte ptr [color_base_mem],EXTRA_COLOR
	mov	si,OFFSET vga_message_085
	mov	ch,26h
	mov	ax,0F809h
	call	Search_Descriptor
	jc	desc_2_9
	call	edid_9_1
desc_2_9:
	mov	ax,0F700h
	call	Search_Descriptor
	jc	desc_3_9
	call	edid_9_2
desc_3_9:
	mov	ds: byte ptr [color_base_mem],COLOR_BASE
	popa
	ret

;#############################################################################

	edid_9_1:

;#############################################################################

	pusha
	cmp	ds: byte ptr [bx + di + 4h],0h
	je	valid_f8
	mov	si,OFFSET vga_message_089
	call	Write_VGA_Message
exit_9_1:
	add	cl,2h
	mov	al,8h
	call	Write_Same_Message
	popa
	ret
valid_f8:
	mov	si,OFFSET vga_message_097
	mov	al,ds: byte ptr [bx + di + 5h]
	cmp	al,1h
	je	valid_f8_1
	call	Write_Reserved
	jmp	exit_9_1
valid_f8_1:
	mov	ds: word ptr [start_xy],cx
	call	Write_Dec_Num_Left8
	call	Next_Line
	call	Next_Line
	or	ds: byte ptr [status_flag_0],FLAG_THOUSANDS
	xor	bp,bp
loop_cvt:
	movzx	eax,ds: word ptr [bx + di + 6h]
	or	al,al
	jne	valid_f8_2
entry_cvt_2:
	mov	al,2h
	mov	si,OFFSET vga_message_097
	call	Write_Same_Message
	jmp	next_loop_cvt
valid_f8_2:
	test	ah,3h
	jne	entry_cvt_2
	test	ds: byte ptr [bx + di + 8h],80h
	jne	entry_cvt_2
	movzx	si,ah
	shr	si,2h
	and	si,3h
	shr	ah,4h
	inc	ax
	shl	ax,1h
	push	ax
	add	si,si
	movzx	edx,ds: byte ptr [si + table_ar_cvt]
	imul	eax,edx
	xor	edx,edx
	movzx	esi,ds: byte ptr [si + table_ar_cvt + 1h]
	div	esi
	and	ax,0FFF8h
	call	Write_Dec_Num_Left16
	mov	si,OFFSET vga_message_071
	call	Write_Simple_VGA_Message
	pop	ax
	call	Write_Dec_Num_Left16
	mov	si,OFFSET vga_message_072
	call	Write_Simple_VGA_Message
	mov	al,ds: byte ptr [bx + di + 8h]
	mov	ah,al
	shr	al,5h
	mov	si,OFFSET vga_message_105
	call	Write_Index_String
	mov	ch,26h
	mov	dl,10h
	mov	si,OFFSET vga_message_106
loop_cvt_2:
	test	ah,dl
	je	next_cvt_4
ok_cvt_vr:
	cmp	ch,26h
	je	write_cvt_vr
	mov	al,'/'
	call	Write_Char
write_cvt_vr:
	call	Write_Simple_VGA_Message
next_cvt_4:
	call	Str_Len_Mem
	shr	dl,1
	jne	loop_cvt_2
	cmp	ch,26h
	jne	valid_cvt_vr
	mov	si,OFFSET vga_message_087
	call	Write_VGA_Message
valid_cvt_vr:
	call	Next_Line
next_loop_cvt:
	add	di,3h
	inc	bp
	cmp	bp,4h
	jne	loop_cvt
	and	ds: byte ptr [status_flag_0],NOT FLAG_THOUSANDS
	popa
	ret

;#############################################################################

	edid_9_2:

;#############################################################################

	pusha
	cmp	ds: byte ptr [bx + di + 4h],0h
invalid_f7:
	je	valid_f7
	mov	si,OFFSET vga_message_108
	call	edid_9_3
	popa
	ret
valid_f7:
	cmp	ds: byte ptr [bx + di + 5h],0Ah
	jne	invalid_f7
	mov	cx,1617h
	mov	ax,ds: word ptr [bx + di + 6h]
	mov	dx,8001h
	call	Block_Yes_Or_No
	mov	al,ah
	mov	dl,2h
	call	Block_Yes_Or_No
	mov	cx,3017h
	mov	ah,1h
	call	Yes_Or_No
	mov	ax,ds: word ptr [bx + di + 8h]
	mov	dl,1h
	call	Block_Yes_Or_No
	mov	dl,4h
	call	Block_Yes_Or_No
	mov	cx,4A17h
	mov	dx,201h
	call	Block_Yes_Or_No
	mov	ax,ds: word ptr [bx + di + 0Ah]
	mov	dx,8001h
	call	Block_Yes_Or_No
	mov	al,ah
	mov	dl,10h
	call	Block_Yes_Or_No
	popa
	ret

;#############################################################################

	edid_9_3:

;#############################################################################

	mov	cx,1617h
	mov	al,0Fh
	call	Write_Same_Message
	mov	cx,3017h
	call	Write_Same_Message
	mov	cx,4A17h
	dec	ax
	call	Write_Same_Message
	ret
