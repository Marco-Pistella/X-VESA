;#############################################################################

;	DS:BX = EDID pointer

	edid_08:

;#############################################################################

	pusha
	mov	cx,60Ch
	mov	si,OFFSET vga_message_103
	call	Write_VGA_Message
	mov	ds: byte ptr [color_base_mem],EXTRA_COLOR
	mov	si,OFFSET vga_message_085
	mov	ch,26h
	mov	ax,0FB08h
	call	Search_Descriptor
	jc	desc_2_8
	call	edid_8_1
desc_2_8:
	inc	cx
	mov	ax,0F906h
	call	Search_Descriptor
	jc	desc_3_8
	call	edid_8_3
desc_3_8:
	inc	cx
	mov	ax,0FA01h
	call	Search_Descriptor
	jc	desc_4_8
	call	edid_8_2
desc_4_8:
	mov	ds: byte ptr [color_base_mem],COLOR_BASE
	popa
	ret

;#############################################################################

	edid_8_1:

;#############################################################################

	pusha
	cmp	ds: byte ptr [bx + di + 4h],0h
	je	valid_coo_col
	mov	si,OFFSET vga_message_089
	mov	al,4h
	call	Write_Same_Message
	inc	cx
	call	Write_Same_Message
	ret
valid_coo_col:
	mov	ds: word ptr [start_xy],cx
loop_next_color_white:
	mov	al,ds: byte ptr [bx + di + 5h]
	or	al,al
	jne	ok_color_data
	mov	si,OFFSET vga_message_085
	or	bp,bp
	jne	write_color_zero
	mov	si,OFFSET vga_message_097
write_color_zero:
	mov	al,5h
	call	Write_Same_Message
	jmp	next_color_white
ok_color_data:
	call	Write_Dec_Num_Left8
	call	Next_Line
	xor	bp,bp
loop_color_white:
	push	cx
	movzx	si,ds: byte ptr [bp + table_edid_color]
	mov	cl,ds: byte ptr [bp + table_edid_color + 1h]
	add	si,di
	movzx	ax,ds: byte ptr [bx + si]
	shl	ax,2h
	mov	dl,ds: byte ptr [bx + di + 6h]
	shr	dl,cl
	and	dl,3h
	or	al,dl
	push	bx
	xchg	ax,bx
	mov	cl,1h
	mov	dx,1 SHL 9h
	xor	esi,esi
loop_bit_color:
	test	bx,dx
	je	no_add_color
	mov	eax,1000000000d
	shr	eax,cl
	add	esi,eax
no_add_color:
	inc	cl	
	shr	dx,1h
	jne	loop_bit_color
	xchg	eax,esi
	pop	bx
	pop	cx
	mov	ds: byte ptr [decimal_digits],9h
	add	ch,0Ah
	call	Write_Decimal_Number32
	call	Next_Line
	add	bp,2h
	cmp	bp,4h
	jne	loop_color_white
	movzx	ax,ds: byte ptr [bx + di + 9h]
	cmp	al,0FFh
	jne	write_gamma_2
	mov	si,OFFSET vga_message_085
	call	Write_vga_message
	jmp	next_color_white_2
write_gamma_2:
	mov	ds: byte ptr [decimal_digits],2h
	add	ax,100d
	add	ch,3h
	call	Write_Decimal_Number16
next_color_white_2:
	call	Next_Line
next_color_white:
	call	Next_Line
	add	di,5h
	cmp	cl,16h
	jne	loop_next_color_white
	popa
	add	cl,9h
	ret

;#############################################################################

	edid_8_2:

;#############################################################################

	cmp	ds: byte ptr [bx + di + 4h],0h
	je	valid_extra_timing
	mov	si,OFFSET vga_message_089
	call	Write_VGA_Message
	add	cl,2h
	ret
valid_extra_timing:
	or	ds: byte ptr [status_flag_0],FLAG_THOUSANDS
	mov	dl,6h
loop_spc_mode_1:
	mov	ax,ds: word ptr [bx + di + 5h]
	call	Write_Standard_Timing
	jc	next_mode_x
	inc	cx
next_mode_x:
	add	di,2h
	dec	dl
	jne	loop_spc_mode_1
	cmp	cl,18h
	jne	exit_edid_6
	mov	si,OFFSET vga_message_087
	call	Write_VGA_Message
exit_edid_6:
	and	ds: byte ptr [status_flag_0],NOT FLAG_THOUSANDS
	ret

;#############################################################################

	edid_8_3:

;#############################################################################

	cmp	ds: byte ptr [bx + di + 4h],0h
	je	valid_extra_cm
	mov	si,OFFSET vga_message_089
	mov	al,6h
	call	Write_Same_Message
	inc	cx
	ret
valid_extra_cm:
	mov	dl,6h
loop_cm:
	mov	ax,ds: word ptr [bx + di + 6h]
	call	Num_To_Str_Hex4
	mov	ch,26h
	inc	cx
	add	di,2h
	dec	dl
	jne	loop_cm
	ret
