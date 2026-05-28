;#############################################################################

	Show_Adapter_Info:

;#############################################################################

	pusha
	call	Save_Current_Video_Page
	call	Clear_Screen
	CENTER_BOX TEXT_WIDTH,1Dh
	mov	si,OFFSET vga_message_019
	mov	di,OFFSET vga_message_322
	call	Extended_Box
	add	cx,0D02h
	mov	si,OFFSET vga_message_021
	call	Write_VGA_Message
	mov	ds: byte ptr [color_base_mem],EXTRA_COLOR
	mov	ch,24h
	mov	ds: word ptr [start_xy],cx
	cmp	ds: byte ptr [vesa_buffer_func_0 + 1].VbeInfoBlock.VbeVersion,VESA_LEGACY
	ja	go_extended_mode
	mov	al,4h
	mov	si,OFFSET vga_message_020
	call	Write_Same_Message
	jmp	go_capabilities
go_extended_mode:
	mov	bx,ds: word ptr [vesa_buffer_func_0].VbeInfoBlock.OemSoftwareRev
	call	Draw_Version
	call	Next_Line
	mov     bx,OFFSET vesa_buffer_func_0.VbeInfoBlock.OemVendorNamePtr
	mov	dl,MAX_OEM_STRING
loop_oem_string:
	call	Draw_OEM_String
	call	Next_Line
	add	bx,4h
	cmp	bx,OFFSET vesa_buffer_func_0.VbeInfoBlock.OemVendorNamePtr + 0Ch
	jne	loop_oem_string
go_capabilities:
	movzx	eax,ds: byte ptr [vbios_size]
	shl	eax,9h
	call	Write_Dec_Num_Left32
	add	ch,2h
	mov	si,OFFSET vga_message_318
	call	Write_Simple_VGA_Message
	shr	eax,9h
	imul	ax,0Ah
	shr	ax,1h
	mov	ds: byte ptr [decimal_digits],1h
	call	Write_Decimal_Number_Left32
	add	ch,2h
	mov	si,OFFSET vga_message_013
	call	Write_VGA_Message
	call	Next_Line
	push	es
	push	BIOS_ROM_VIDEO_SEGMENT
	pop	es
	mov	si,es: word ptr [PCIR_OFFSET]
	cmp	es: dword ptr [si],'RICP'
	jne	no_pci_device
	mov	ax,es: word ptr [si + PCI_VENDOR_OFFSET]
	call	Num_To_Str_Hex4
	mov	al,':'
	call	Write_Char
	mov	ax,es: word ptr [si + PCI_DEVICE_OFFSET]
	call	Num_To_Str_Hex4
	mov	al,':'
	call	Write_Char
	mov	ax,es: word ptr [si + PCI_REVISION_OFFSET]
	call	Num_To_Str_Hex4
	jmp	next_extra_info
no_pci_device:
	mov	si,OFFSET vga_message_326
	call	Write_VGA_Message
next_extra_info:
	pop	es
	call	Next_Line
	mov	al,ds: byte ptr [vesa_buffer_func_0].VbeInfoBlock.Capabilities
	xor	al,2h
	mov	dx,104h
	call	Block_Yes_Or_No
	cmp	ds: byte ptr [vesa_buffer_func_0 + 1].VbeInfoBlock.VbeVersion,VESA2
	ja	go_extended_mode3
	mov	al,2h
	mov	si,OFFSET vga_message_024
	call	Write_Same_Message
	jmp	check_pm_mode
go_extended_mode3:
	mov	dx,810h
	call	Block_Yes_Or_No
check_pm_mode:
	cmp	ds: byte ptr [vesa_buffer_func_0 + 1].VbeInfoBlock.VbeVersion,VESA_LEGACY
	ja	vesa2pm_ok
	mov	al,0Eh
	mov	si,OFFSET vga_message_020
	call	Write_Same_Message
	jmp	loop_key_01c
vesa2pm_ok:
	test	ds: byte ptr [status_flag_1],FLAG_PMID
	jne	valid_pmid
	mov	al,9h
	mov	si,OFFSET vga_message_025
	call	Write_Same_Message
	jmp	check_pmid_0a
valid_pmid:
	mov	si,OFFSET offset_pmid
	mov	dx,7h
	mov	ax,ds: word ptr [si + 2h]
	call	Num_To_Str_Hex4
	mov	al,':'
	call	Write_Char
	mov	ax,ds: word ptr [si]
	call	Num_To_Str_Hex4
	call	Next_Line
	les	si,ds: dword ptr [si]
	add	si,4h
loop_pointer_id1:
	lods	es: word ptr [si]
	call	Num_To_Str_Hex4
	call	Next_Line
	dec	dx	
	jne	loop_pointer_id1
	lods	es: byte ptr [si]
	call	Num_To_Str_Hex2
	call	Next_Line
check_pmid_0a:
	test	ds: byte ptr [status_flag_1],FLAG_PM0A
	jne	valid_pmid0a
	mov	al,5h
	mov	si,OFFSET vga_message_025
	call	Write_Same_Message
	jmp	loop_key_01c
valid_pmid0a:
	mov	si,OFFSET offset_pm0a
	mov	dx,4h
	mov	ax,ds: word ptr [si + 2h]
	call	Num_To_Str_Hex4
	mov	al,':'
	call	Write_Char
	mov	ax,ds: word ptr [si]
	call	Num_To_Str_Hex4
	call	Next_Line
	les	si,ds: dword ptr [si]
loop_pointer_id2:
	lods	es: word ptr [si]
	call	Num_To_Str_Hex4
	call	Next_Line
	dec	dx	
	jne	loop_pointer_id2
loop_key_01c:
	mov	ds: byte ptr [color_base_mem],COLOR_BASE
	call	Get_Key
	cmp	ax,S_KEY
	jne	test_exit_key_show_adapter
	mov	di,OFFSET dos_create_file
	mov	ds: word ptr [di].CREATE_FILE.OFFSET_INSTANT_MESSAGE,OFFSET vga_Message_323
	mov	ds: word ptr [di].CREATE_FILE.OFFSET_NAME_DECIMAL,OFFSET vga_message_324 + 21h
	mov	ds: word ptr [di].CREATE_FILE.OFFSET_FILE_NAME,OFFSET vga_message_324 + 1Dh
	mov	ds: word ptr [di].CREATE_FILE.OFFSET_FAIL_MESSAGE,OFFSET vga_message_325
	mov	ds: word ptr [di].CREATE_FILE.OFFSET_CLOSE_MESSAGE,OFFSET vga_message_324
	mov	ds: word ptr [di].CREATE_FILE.OFFSET_BUFFER_IO,BUFFER_IO
	mov	ds: word ptr [di].CREATE_FILE.SEGMENT_BUFFER_IO,ds
	add	ds: word ptr [di].CREATE_FILE.SEGMENT_BUFFER_IO,SEGMENT_4
	call	Create_Unique_File
	jc	loop_key_01c
	mov	ds: word ptr [di].CREATE_FILE.OFFSET_BUFFER_SOURCE,BIOS_ROM_VIDEO_START
	mov	ds: word ptr [di].CREATE_FILE.SEGMENT_BUFFER_SOURCE,BIOS_ROM_VIDEO_SEGMENT
	movzx	ax,ds: byte ptr [vbios_size]
	shl	ax,9h
	jne	no_64k_bios
	mov	ax,8000h
	mov	ds: word ptr [di].CREATE_FILE.DATA_LEN,ax
	call	Push_IO
	jc	loop_key_01c
	add	ds: word ptr [di].CREATE_FILE.OFFSET_BUFFER_SOURCE,ax
no_64k_bios:
	mov	ds: word ptr [di].CREATE_FILE.DATA_LEN,ax
	call	Push_IO
	jc	loop_key_01c
	call	Flush_IO
	jc	loop_key_01c
	call	Close_File
	jmp	loop_key_01c
test_exit_key_show_adapter:
	cmp	ax,ESC_KEY
	jne	loop_key_01c
	call	Restore_Current_Video_Page
	push	ds
	pop	es
	popa
	ret
