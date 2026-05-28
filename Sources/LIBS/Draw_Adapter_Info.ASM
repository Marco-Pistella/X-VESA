;#############################################################################

	Draw_Adapter_Info:

;#############################################################################

	pusha
	mov	si,OFFSET vga_message_012
	add	cx,402h
	call	Write_VGA_Message
	mov	ds: byte ptr [color_base_mem],EXTRA_COLOR
	mov	ch,12h
	mov	ds: word ptr [start_xy],cx
	mov	bx,ds: word ptr [vesa_buffer_func_0].VbeInfoBlock.VbeVersion
	call	Draw_Version
	call	Next_Line
	mov	bx,OFFSET vesa_buffer_func_0.VbeInfoBlock.OemStringPtr
	mov	dl,MAX_VENDOR_STRING
	call	Draw_OEM_String
	call	Next_Line
	mov	eax,ds: dword ptr [vesa_buffer_func_0].VbeInfoBlock.Capabilities
	call	Num_To_Str_Hex8
	call	Next_Line
	mov	ds: byte ptr [color_base_mem],EXTRA_COLOR
	movzx	eax,ds: word ptr [vesa_buffer_func_0].VbeInfoBlock.TotalMemory
	shl	eax,6h
	call	Write_Dec_Num_Left32
	inc	ch
	mov	si,OFFSET vga_message_013
	call	Write_Simple_VGA_Message
	mov	ds: byte ptr [color_base_mem],COLOR_BASE
	cmp	ds: byte ptr [vesa_buffer_func_0 + 1].VbeInfoBlock.VbeVersion,VESA_LEGACY
	ja	valid_vmem
	cmp	ds: byte ptr [vesa_buffer_func_0 + 1].VbeInfoBlock.TotalMemory,ZERO
	je	valid_vmem
	inc	ch
	mov	si,OFFSET vga_message_026
	call	Write_VGA_Message
valid_vmem:
	popa
	ret

;#############################################################################

	Draw_Total_Video_Mode:

;#############################################################################

	pusha
	mov	si,OFFSET vga_message_202
	mov	cx,(HEADER_LEFT_SPACE SHL 8h) + MAIN_WIN1_HEIGHT
	mov	al,'µ'
	call	Write_Char
	call	Write_Simple_VGA_Message
	mov	ax,ds: word ptr [panel_01].PANEL.TOTAL_ELEMENTS
	inc	ax
	test	ds: byte ptr [status_flag_0],FLAG_TOO_VESA_MODE
	je	no_too_vesa_mode
	mov	ds: byte ptr [color_base_mem],ND_COLOR
no_too_vesa_mode:
	call	Write_Dec_Num_Left16
	mov	ds: byte ptr [color_base_mem],COLOR_BASE
	mov	al,'Æ'
	call	Write_Char
	popa
	ret
