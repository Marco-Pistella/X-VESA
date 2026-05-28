;#############################################################################

;	DS:BX = Pointer to vesa_mode_info video mode

	VESA_Command_01:

;#############################################################################

	pusha
	mov	ax,(VESA_ID SHL 8h) + VESA_FUNC_RETURN_MODE_INFORMATION
	mov	cx,ds: word ptr [bx].VESA_MODE_PANEL.VIDEO_MODE
	mov	di,OFFSET vesa_buffer_func_1
	push	bx
	VIDEO_CALL
	cmp	ax,VESA_ID
	pop	bx
	je	valid_vesa_func_1
	mov	si,OFFSET vga_message_144
	call	View_Alert_Message
	popa
	ret
valid_vesa_func_1:
	CENTER_BOX TEXT_WIDTH,34d
	mov	si,OFFSET vga_message_145
	mov	di,OFFSET vga_message_146
	call	Extended_Box
	add	cl,2h
	mov	ch,12h
	mov	si,OFFSET vga_message_147
	call	Write_VGA_Message
	mov	ch,33h
	mov	si,OFFSET vga_message_148
	call	Write_VGA_Message
	mov	ds: byte ptr [color_base_mem],EXTRA_COLOR
	mov	ch,1Eh
	mov	ds: word ptr [start_xy],cx
	mov	ax,ds: word ptr [bx].VESA_MODE_PANEL.VIDEO_MODE
	mov	di,OFFSET vesa_buffer_func_1
	call	Num_To_Str_Hex4
	call	Next_Line
	mov	al,ds: byte ptr [di].ModeInfoBlock.ModeAttributes
	mov	ah,1h
	call	Yes_Or_No
	mov	dx,408h
	call	Block_Yes_Or_No
	shr	al,4h
	and	al,1h
	mov	si,OFFSET vga_message_149
	call	Write_Index_String
	cmp	ds: byte ptr [vesa_buffer_func_0 + 1].VbeInfoBlock.VbeVersion,VESA_LEGACY
	ja	valid_item_5
	mov	al,8h
	mov	si,OFFSET vga_message_151
	call	Write_Same_Message	
	jmp	valid_item_6
valid_item_5:
	mov	al,ds: byte ptr [di].ModeInfoBlock.ModeAttributes
	xor	al,60h
	mov	dx,2080h
	call	Block_Yes_Or_No
	cmp	ds: byte ptr [vesa_buffer_func_0 + 1].VbeInfoBlock.VbeVersion,VESA2
	ja	valid_item_7
	mov	al,5h
	mov	si,OFFSET vga_message_151
	call	Write_Same_Message	
	jmp	valid_item_6
valid_item_7:
	mov	al,ds: byte ptr [di + 1h].ModeInfoBlock.ModeAttributes
	mov	dx,110h
	call	Block_Yes_Or_No
valid_item_6:
	mov	al,ds: byte ptr [di].ModeInfoBlock.WinAAttributes
	mov	dx,104h
	call	Block_Yes_Or_No
	mov	ax,ds: word ptr [di].ModeInfoBlock.WinASegment
	or	ax,ax
	jne	valid_seg_1
	mov	si,OFFSET vga_message_033
	call	Write_VGA_Message
	jmp	next_item_1
valid_seg_1:
	call	Num_To_Str_Hex4
next_item_1:
	call	Next_Line
	mov	al,ds: byte ptr [di].ModeInfoBlock.WinBAttributes
	mov	dx,104h
	call	Block_Yes_Or_No
	mov	ax,ds: word ptr [di].ModeInfoBlock.WinBSegment
	or	ax,ax
	jne	valid_seg_2
	mov	si,OFFSET vga_message_033
	call	Write_VGA_Message
	jmp	next_item_2
valid_seg_2:
	call	Num_To_Str_Hex4
next_item_2:
	call	Next_Line
	mov	ax,ds: word ptr [di].ModeInfoBlock.WinGranularity
	or	ax,ax
	jne	valid_seg_3
	mov	si,OFFSET vga_message_033
	call	Write_VGA_Message
	jmp	next_item_3
valid_seg_3:
	call	Write_Dec_Num_Left16
	inc	ch
	mov	si,OFFSET vga_message_013
	call	Write_VGA_Message
next_item_3:
	call	Next_Line
	mov	ax,ds: word ptr [di].ModeInfoBlock.WinSize
	or	ax,ax
	jne	valid_seg_4
	mov	si,OFFSET vga_message_033
	call	Write_VGA_Message
	jmp	next_item_4
valid_seg_4:
	call	Write_Dec_Num_Left16
	inc	ch
	mov	si,OFFSET vga_message_013
	call	Write_VGA_Message
next_item_4:
	call	Next_Line
	cmp	ds: dword ptr [di].ModeInfoBlock.WinFuncPtr,0h
	jne	valid_function_pointer
	mov	si,OFFSET vga_message_033
	call	Write_VGA_Message
	jmp	no_function_pointer
valid_function_pointer:
	mov	ax,ds: word ptr [di + 2h].ModeInfoBlock.WinFuncPtr
	call	Num_To_Str_Hex4
	mov	al,':'
	call	Write_Char
	mov	ax,ds: word ptr [di].ModeInfoBlock.WinFuncPtr
	call	Num_To_Str_Hex4
no_function_pointer:
	call	Next_Line	
	mov	ax,ds: word ptr [di].ModeInfoBlock.BytesPerScanLine
	call	Write_Dec_Num_Left16
	call	Next_Line
	test	ds: byte ptr [di].ModeInfoBlock.ModeAttributes,2h
	jne	valid_extra_vesa_info
	mov	al,5d
	mov	si,OFFSET vga_message_151
	call	Write_Same_Message
	mov	cx,4205h
	mov	al,30d
	call	Write_Same_Message
	jmp	key_loop_05
valid_extra_vesa_info:
	mov	ax,ds: word ptr [di].ModeInfoBlock.XResolution
	call	Write_Dec_Num_Left16
	inc	ch
	mov	si,OFFSET vga_message_079
	call	Write_VGA_Message
	call	Next_Line
	mov	ax,ds: word ptr [di].ModeInfoBlock.YResolution
	call	Write_Dec_Num_Left16
	inc	ch
	mov	si,OFFSET vga_message_079
	call	Write_VGA_Message
	call	Next_Line
	mov	al,ds: byte ptr [di].ModeInfoBlock.XCharSize
	call	Write_Dec_Num_Left8
	call	Next_Line	
	mov	al,ds: byte ptr [di].ModeInfoBlock.YCharSize
	call	Write_Dec_Num_Left8
	call	Next_Line	
	mov	al,ds: byte ptr [di].ModeInfoBlock.NumberOfPlanes
	call	Write_Dec_Num_Left8
	call	Next_Line
	mov	cx,4205h
	mov	ds: word ptr [start_xy],cx
	mov	al,ds: byte ptr [di].ModeInfoBlock.BitsPerPixel
	call	Write_Dec_Num_Left8
	call	Next_Line
	mov	al,ds: byte ptr [di].ModeInfoBlock.NumberOfBanks
	call	Write_Dec_Num_Left8
	call	Next_Line
	mov	al,ds: byte ptr [di].ModeInfoBlock.MemoryModel
	mov	si,OFFSET vga_message_152
	call	Write_Index_String
	mov	al,ds: byte ptr [di].ModeInfoBlock.BankSize
	or	al,al
	jne	valid_seg_8
	mov	si,OFFSET vga_message_033
	call	Write_VGA_Message
	jmp	next_item_8
valid_seg_8:
	call	Write_Dec_Num_Left8
next_item_8:
	call	Next_Line
	mov	al,ds: byte ptr [di].ModeInfoBlock.NumberOfImagePages
	inc	ax
	call	Write_Dec_Num_Left8
	call	Next_Line
	cmp	ds: byte ptr [di].ModeInfoBlock.MemoryModel,DIRECT_COLOR
	je	valid_RGB
	cmp	ds: byte ptr [di].ModeInfoBlock.MemoryModel,YUV
	je	valid_RGB
	mov	al,10d
	mov	si,OFFSET vga_message_033
	call	Write_Same_Message
	jmp	next_item_9
valid_rgb:
	mov	dl,8h
	lea	si,ds: word ptr [di].ModeInfoBlock.RedMaskSize
loop_mask_vesa:
	lodsb
	call	Write_Dec_Num_Left8
	call	Next_Line
	dec	dl
	jne	loop_mask_vesa
	cmp	ds: byte ptr [di].ModeInfoBlock.MemoryModel,DIRECT_COLOR
	je	valid_direct_color
	mov	al,2h
	mov	si,OFFSET vga_message_033
	call	Write_Same_Message
	jmp	next_item_9
valid_direct_color:
	mov	al,ds: byte ptr [di].ModeInfoBlock.DirectColorModeInfo
	mov	dx,102h
	call	Block_Yes_Or_No
next_item_9:
	cmp	ds: byte ptr [vesa_buffer_func_0 + 1].VbeInfoBlock.VbeVersion,VESA_LEGACY
	ja	valid_item_10
	mov	al,15d
	mov	si,OFFSET vga_message_151
	call	Write_Same_Message
	jmp	key_loop_05
valid_item_10:
	test	ds: byte ptr [di].ModeInfoBlock.ModeAttributes,VESA_LINEAR_MODE
	jne	write_address_vesa2
	mov	si,OFFSET vga_message_033
	call	Write_VGA_Message
	jmp	off_screen_view
write_address_vesa2:
	cmp	ds: word ptr [di + 2h].ModeInfoBlock.PhysBasePtr,0h
	jne	valid_physbaseptr
	mov	si,OFFSET vga_message_097
	call	Write_VGA_Message
	jmp	off_screen_view
valid_physbaseptr:
	mov	eax,ds: dword ptr [di].ModeInfoBlock.PhysBasePtr
	call	Num_To_Str_Hex8
off_screen_view:
	call	Next_Line
	cmp	ds: dword ptr [di].ModeInfoBlock.OffScreenMemOffset,0h
	jne	valid_item_11
	mov	si,OFFSET vga_message_033
	call	Write_VGA_Message
	jmp	next_item_11
valid_item_11:
	mov	eax,ds: dword ptr [di].ModeInfoBlock.OffScreenMemOffset
	call	Num_To_Str_Hex8
next_item_11:
	call	Next_Line
	cmp	ds: word ptr [di].ModeInfoBlock.OffScreenMemSize,0h
	jne	valid_item_12
	mov	si,OFFSET vga_message_033
	call	Write_VGA_Message
	jmp	next_item_12
valid_item_12:
	mov	ax,ds: word ptr [di].ModeInfoBlock.OffScreenMemSize
	call	Write_Dec_Num_Left16
	inc	ch
	mov	si,OFFSET vga_message_013
	call	Write_VGA_Message
next_item_12:
	call	Next_Line
	cmp	ds: byte ptr [vesa_buffer_func_0 + 1].VbeInfoBlock.VbeVersion,VESA2
	ja	valid_item_13
	mov	al,12d
	mov	si,OFFSET vga_message_151
	call	Write_Same_Message
	jmp	key_loop_05
valid_item_13:
	mov	ax,ds: word ptr [di].ModeInfoBlock.LinBytesPerScanLine
	call	Write_Dec_Num_Left16
	call	Next_Line
	mov	al,ds: byte ptr [di].ModeInfoBlock.BnkNumberOfImagePages
	inc	ax
	call	Write_Dec_Num_Left8
	call	Next_Line
	mov	al,ds: byte ptr [di].ModeInfoBlock.LinNumberOfImagePages
	inc	ax
	call	Write_Dec_Num_Left8
	call	Next_Line
	cmp	ds: byte ptr [di].ModeInfoBlock.MemoryModel,DIRECT_COLOR
	je	valid_RGB3
	cmp	ds: byte ptr [di].ModeInfoBlock.MemoryModel,YUV
	je	valid_RGB3
	mov	al,8h
	mov	si,OFFSET vga_message_033
	call	Write_Same_Message
	jmp	next_item_14
valid_RGB3:
	mov	dl,8h
	lea	si,ds: word ptr [di].ModeInfoBlock.LinRedMaskSize
loop_mask_vesa3:
	lodsb
	call	Write_Dec_Num_Left8
	call	Next_Line
	dec	dl
	jne	loop_mask_vesa3
next_item_14:
	mov	eax,ds: dword ptr [di].ModeInfoBlock.MaxPixelClock
	or	eax,eax
	jne	valid_item_15
	mov	si,OFFSET vga_Message_033
	call	Write_VGA_Message
	jmp	key_loop_05
valid_item_15:
	cmp	eax,999999999d
	jbe	valid_item_16
	mov	si,OFFSET vga_message_097
	call	Write_VGA_Message
	jmp	key_loop_05
valid_item_16:
	call	Write_Dec_Num_Left32
key_loop_05:
	call	Get_Key
	cmp	ax,ESC_KEY
	jne	key_loop_05
	mov	ds: byte ptr [color_base_mem],COLOR_BASE
	popa
	ret
