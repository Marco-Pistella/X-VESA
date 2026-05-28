;#############################################################################

;	DS:BX = EDID pointer

	edid_07:

;#############################################################################

	pusha
	mov	cx,0C0Ch
	mov	si,OFFSET vga_message_067
	call	Write_VGA_Message
	mov	ds: byte ptr [color_base_mem],EXTRA_COLOR
	mov	si,OFFSET vga_message_085
	mov	ch,26h
	mov	ax,0FE01h
	call	Search_Descriptor
	jc	desc_2
	call	edid_7_1
desc_2:
	mov	ah,0FCh
	call	Search_Descriptor
	jc	desc_3	
	call	edid_7_1
desc_3:
	mov	ah,0FFh
	call	Search_Descriptor
	jc	desc_4
	call	edid_7_1
desc_4:
	inc	cx
	mov	ax,0FD06h
	call	Search_Descriptor
	jc	exit_page_7
	call	edid_7_2
exit_page_7:
	mov	ds: byte ptr [color_base_mem],COLOR_BASE
	popa
	ret

;#############################################################################

	edid_7_1:

;#############################################################################

	pusha
	cmp	ds: byte ptr [bx + di + 4h],0h
	je	loop_edid_7_alpha
	mov	si,OFFSET vga_message_089
	call	Write_VGA_Message
	jmp	exit_edid_7_1
loop_edid_7_alpha:
	mov	al,ds: byte ptr [bx + di + 5h]
	or	al,al
	je	exit_edid_7_1
	cmp	al,0Ah
	je	exit_edid_7_1
	call	Write_Char
	inc	di
	cmp	ch,33h
	jne	loop_edid_7_alpha
exit_edid_7_1:
	popa
	inc	cx
	ret

;#############################################################################

	edid_7_2:

;#############################################################################

	pusha
	mov	al,ds: byte ptr [bx + di + 4h]
	add	di,5h
	mov	ds: word ptr [start_xy],cx
	mov	si,OFFSET table_edid_rate
	mov	ah,9h
loop_table_rate:
	cmp	al,ds: byte ptr [si]
	je	found_table_rate
	add	si,5h
	dec	ah
	jne	loop_table_rate
	mov	al,4h
	mov	si,OFFSET vga_message_097
	call	Write_Same_Message
	add	di,4h
	jmp	entry_max_pixel_clock
found_table_rate:
	inc	si
	mov	dl,4h
loop_write_range:
	movzx	ax,ds: byte ptr [bx + di]
	movzx	bp,ds: byte ptr [si]
	add	ax,bp
	call	Write_Dec_Num_Left16
	inc	ch
	push	si
	mov	si,OFFSET vga_message_073
	cmp	dl,2h
	ja	vertical_rate_unit
	mov	si,OFFSET vga_message_090
vertical_rate_unit:
	call	Write_VGA_Message
	pop	si
	inc	si
	inc	di
	call	Next_Line
	dec	dl
	jne	loop_write_range
entry_max_pixel_clock:
	movzx	ax,ds: byte ptr [bx + di]
	or	ax,ax
	jne	valid_max_pixel_clock
	mov	si,OFFSET vga_message_097
	call	Write_VGA_Message
	jmp	entry_vts
valid_max_pixel_clock:
	imul	ax,10d
	call	Write_Dec_Num_Left16
	inc	ch
	mov	si,OFFSET vga_message_078
	call	Write_VGA_Message
entry_vts:
	call	Next_Line
	call	Next_Line
	mov	al,ds: byte ptr [bx + di + 1h]
	test	ds: byte ptr [bx + 18h],1h
	jne	continuous_display
	mov	si,OFFSET vga_message_091
	call	Write_Index_String
	popa
	ret
continuous_display:
	mov	si,OFFSET vga_message_092
	call	Write_Index_String
	call	Next_Line
	mov	ds: byte ptr [color_base_mem],COLOR_BASE
	cmp	al,2h
	je	go_gtf
	cmp	al,4h
	je	go_cvt
	popa
	ret
go_gtf:
	mov	ch,0Fh
	mov	si,OFFSET vga_Message_093
	call	Write_VGA_Message
	mov	ch,26h
	mov	ds: byte ptr [color_base_mem],EXTRA_COLOR
	cmp	ds: byte ptr [bx + di + 2h],0h
	je	valid_gtf
	mov	si,OFFSET vga_message_088
	mov	al,5h
	call	Write_Same_Message
	popa
	ret
valid_gtf:
	mov	ah,5h
loop_sgtf:	
	mov	al,ds: byte ptr [bx + di + 3h]
	call	Write_Dec_Num_Left8
	call	Next_Line
	inc	di
	dec	ah
	jne	loop_sgtf
	popa
	ret
go_cvt:
	mov	ch,9h
	mov	si,OFFSET vga_message_094
	call	Write_VGA_Message
	mov	ch,26h
	mov	ds: byte ptr [color_base_mem],EXTRA_COLOR
	cmp	ds: word ptr [bx + di + 2h],200Ah
	jne	valid_cvt
	mov	si,OFFSET vga_message_088
	mov	al,9h
	call	Write_Same_Message
	popa
	ret
valid_cvt:
	mov	ah,ds: byte ptr [bx + di + 2h]
	mov	al,ah
	shr	al,4h
	call	Write_Dec_Num_Left8
	mov	al,ds: byte ptr [decimal_sign]
	call	Write_Char
	mov	al,ah
	and	al,0Fh
	call	Write_Dec_Num_Left8
	call	Next_Line
	mov	ds: byte ptr [decimal_digits],2h
	movzx	eax,ds: byte ptr [bx + di]
	imul	eax,1000d
	movzx	edx,ds: byte ptr [bx + di + 3h]
	shr     dl,2h
	imul	dx,25
	add	eax,edx
	call	Size_Of_Number32
	add	ch,ds: byte ptr [number_count]
	dec	ch
	call	Write_Decimal_Number32
	add	ch,2h
	mov	si,OFFSET vga_message_078
	call	Write_VGA_Message
	call	Next_Line
	mov	ax,ds: word ptr [bx + di + 3]
	and	al,3h
	xchg	al,ah
	shl	ax,3h
	call	Write_Dec_Num_Left16
	inc	ch
	mov	si,OFFSET vga_message_079
	call	Write_VGA_Message
	call	Next_Line
	mov	al,ds: byte ptr [bx + di + 5h]
	test	al,7h
	je	valid_cvt_ar
	call	Write_Reserved
	jmp	next_cvt_item
valid_cvt_ar:
	test	al,0F8h
	jne	valid_cvt_ar_1
	mov	si,OFFSET vga_message_087
	call	Write_VGA_Message
	jmp	next_cvt_item
valid_cvt_ar_1:
	mov	ah,80h
	mov	si,OFFSET vga_message_096
	xchg	ax,dx
loop_cvt_ar:
	test	dl,dh
	je	no_cvr_ar
	cmp	ch,26h
	je	no_cvt_sep
	inc	ch
	mov	al,'|'
	call	Write_Char
	inc	ch
no_cvt_sep:
	call	Write_Simple_VGA_Message
	call	Str_Len_Mem
no_cvr_ar:
	shr	dh,1h
	cmp	dh,4h
	jne	loop_cvt_ar
next_cvt_item:
	call	Next_Line
	mov	al,ds: byte ptr [bx + di + 6h]
	test	al,7h
	je	valid_cvt_par
	call	Write_Reserved
	call	Next_Line
	mov	al,2h
	mov	si,OFFSET vga_message_097
	call	Write_Same_Message
	jmp	next_cvt_item_2
valid_cvt_par:
	shr	al,5h
	mov	si,OFFSET vga_message_096
	call	Write_Index_String	
	mov	al,ds: byte ptr [bx + di + 6h]
	mov	dx,810h
	call	Block_Yes_Or_No
next_cvt_item_2:

	mov	al,ds: byte ptr [bx + di + 7h]
	test	al,0Fh
	je	valid_cvt_ds
	call	Write_Reserved
	jmp	next_cvt_item_3
valid_cvt_ds:
	test	al,0F0h
	jne	valid_cvt_ds_1
	mov	si,OFFSET vga_message_087
	call	Write_VGA_Message
	jmp	next_cvt_item_3
valid_cvt_ds_1:
	mov	ah,80h
	mov	si,OFFSET vga_message_098
	xchg	ax,dx
loop_cvt_ds:
	test	dl,dh
	je	no_cvt_ds
	cmp	ch,26h
	je	no_cvt_seq
	mov	al,','
	call	Write_Char
	inc	ch
no_cvt_seq:
	call	Write_Simple_VGA_Message
	call	Str_Len_Mem
no_cvt_ds:
	shr	dh,1h
	cmp	dh,8h
	jne	loop_cvt_ds
next_cvt_item_3:
	call	Next_Line
	mov	al,ds: byte ptr [bx + di + 8h]
	or	al,al
	jne	valid_pvrr
	mov	si,OFFSET vga_message_097
	call	Write_VGA_Message
	popa
	ret
valid_pvrr:
	call	Write_Dec_Num_Left8
	inc	ch
	mov	si,OFFSET vga_message_073
	call	Write_VGA_Message
	popa
	ret
