;#############################################################################

;	DS:BX = EDID pointer

	Get_Extension_Block:

;#############################################################################

	pusha
	call	Save_Current_Video_Page
	call	Clear_Screen
	cmp	ds: byte ptr [bx].EDID128.ExtensionFlag,0h
	jne	valid_n_block
	mov	si,OFFSET vga_message_109
	call	View_Alert_Message
	jmp	exit_get_extension
valid_n_block:
	push	bx
	mov	ax,(VESA_ID SHL 8h) + VESAFUNC_READ_EDID
	mov	bx,READ_EDID
	movzx	cx,ds: byte ptr [bx - 4h]
	mov	dx,1h
	mov	di,OFFSET edid_extension_buffer
	VIDEO_CALL
	cmp	ax,VESA_ID
	pop	bx
	je	ok_read_ext_block
	mov	si,OFFSET vga_message_113
	call	View_Alert_Message
	jmp	exit_get_extension
ok_read_ext_block:
	mov	si,bx
	mov	cx,EDID_LEN
	repe	cmpsb
	jne	valid_ext_block_read
	mov	si,OFFSET vga_message_114
	call	View_Alert_Message
	jmp	exit_get_extension
valid_ext_block_read:
	CENTER_BOX TEXT_WIDTH,0Ch
	mov	di,OFFSET vga_message_010
	mov	si,OFFSET vga_message_110
	call	Extended_Box
	add	ch,10h
	mov	al,ds: byte ptr [bx - 4h]
	add	al,'0'
	call	Write_Char
	mov	dh,ds: byte ptr [bx].EDID128.ExtensionFlag
	mov	dl,1h
loop_ext_block:
	mov	cx,250Eh
	mov	al,dl
	call	Write_Dec_Num_Left8
	mov	al,'/'
	call	Write_Char
	mov	al,dh
	call	Write_Dec_Num_Left8
	mov	si,OFFSET vga_message_112
	call	Write_VGA_Message
	mov	si,OFFSET edid_extension_buffer
	mov	ch,4h
	add	cl,2h
	call	Show_Binary_EDID_1
	mov	si,OFFSET input_buffer
	mov	bp,dx
loop_ext_block_key:
	call	Get_Key
	cmp	ax,F1_KEY
	jne	test_ext_key_6
	call	Save_Current_Video_Page
	call	Clear_Screen
	mov	ds: byte ptr [n_line_help],HELP4_LINE + 4h
	push	bx
	mov	bx,OFFSET vga_message_111
	call	Show_Help
	pop	bx
	call	Restore_Current_Video_Page
	jmp	loop_ext_block_key
test_ext_key_6:
	cmp	ax,S_KEY
	jne	test_ext_key_5
	call	Save_Extension_Block
	jmp	loop_ext_block_key
test_ext_key_5:
	cmp	ax,G_KEY
	jne	test_ext_key_0
	call	Save_Current_Video_Page
	call	Clear_Screen
	push	dx
	CENTER_BOX (TEXT_WIDTH SHR 1),7h
	mov	di,OFFSET vga_message_116
	mov	si,OFFSET vga_message_115
	call	Extended_Box
	pop	dx
	add	cx,403h
	mov	si,OFFSET vga_message_117
	call	Write_Simple_VGA_Message
	mov	al,ds: byte ptr [bx].EDID128.ExtensionFlag
	call	Size_Of_Number8
	mov	ah,ds: byte ptr [number_count]
	add	ch,ah
	add	ch,2h
	mov	si,OFFSET vga_message_212
	call	Write_Simple_VGA_Message
	call	Write_Dec_Num_Left8
	mov	al,')'
	call	Write_Char
	mov	si,OFFSET inputs_01
	mov	ds: byte ptr [si].INPUTS.LEN,ah
	mov	ds: byte ptr [input_buffer],0h
	call	Choice
	call	Restore_Current_Video_Page
	cmp	ds: word ptr [si].INPUTS.KEY,ESC_KEY
	je	loop_ext_block_key
	mov	si,OFFSET input_buffer
	call	Asci_To_Num
	mov	dl,al
	call	Get_Extension_Block_1
	jmp	loop_ext_block
test_ext_key_0:
	cmp	ax,LEFT_KEY
	jne	test_ext_key_1
	cmp	dl,1h
	je	loop_ext_block_key
	dec	dl
	call	Get_Extension_Block_1
	jmp	loop_ext_block
test_ext_key_1:
	cmp	ax,RIGHT_KEY
	jne	test_ext_key_2
	cmp	dl,dh
	je	loop_ext_block_key
	inc	dl
	call	Get_Extension_Block_1
	jmp	loop_ext_block
test_ext_key_2:
	cmp	ax,HOME_KEY
	jne	test_ext_key_3
	cmp	dl,1h
	je	loop_ext_block_key
	mov	dl,1h
	call	Get_Extension_Block_1
	jmp	loop_ext_block
test_ext_key_3:
	cmp	ax,END_KEY
	jne	test_ext_key_4
	cmp	dl,dh
	je	loop_ext_block_key
	mov	dl,dh
	call	Get_Extension_Block_1
	jmp	loop_ext_block
test_ext_key_4:
	cmp	ax,ESC_KEY
	jne	loop_ext_block_key
exit_get_extension:
	call	Restore_Current_Video_Page
	popa
	ret

;#############################################################################

	Get_Extension_Block_1:

;#############################################################################

	pusha
	mov	ax,(VESA_ID SHL 8h) + VESAFUNC_READ_EDID
	mov	bx,READ_EDID
	movzx	cx,ds: byte ptr [bx - 4h]
	xor	dh,dh
	mov	di,OFFSET edid_extension_buffer
	VIDEO_CALL
	cmp	ax,VESA_ID
	popa
	je	valid_geb_1
	mov	dx,bp
	call	Save_Current_Video_Page
	call	Clear_Screen
	mov	si,OFFSET vga_message_113
	call	View_Alert_Message
	call	Restore_Current_Video_Page
valid_geb_1:
	ret
