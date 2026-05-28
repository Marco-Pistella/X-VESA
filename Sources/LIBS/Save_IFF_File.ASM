;#############################################################################

	Save_IFF_File:

;#############################################################################

	pusha
	mov	ds: byte ptr [color_base_mem],COLOR_BASE
	or	ds: byte ptr [status_flag_3],SCREENSHOT_ON
	mov	ds: dword ptr [iff_write_bytes],SIZEOF IFF_PBM
	mov	di,OFFSET dos_create_file
	mov	ds: word ptr [di].CREATE_FILE.OFFSET_INSTANT_MESSAGE,OFFSET vga_Message_135
	mov	ds: word ptr [di].CREATE_FILE.OFFSET_NAME_DECIMAL,OFFSET vga_message_136 + 1Dh
	mov	ds: word ptr [di].CREATE_FILE.OFFSET_FILE_NAME,OFFSET vga_message_136 + 19h
	mov	ds: word ptr [di].CREATE_FILE.OFFSET_FAIL_MESSAGE,OFFSET vga_message_137
	mov	ds: word ptr [di].CREATE_FILE.OFFSET_CLOSE_MESSAGE,OFFSET vga_message_136
	mov	ds: word ptr [di].CREATE_FILE.OFFSET_BUFFER_IO,BUFFER_IO
	mov	ds: word ptr [di].CREATE_FILE.SEGMENT_BUFFER_IO,ds
	add	ds: word ptr [di].CREATE_FILE.SEGMENT_BUFFER_IO,SEGMENT_4
	call	Create_Unique_File
	jc	exit_file_save_iff
	mov	si,OFFSET iff_pbm_data
	test	ds: byte ptr [status_flag_2],VESA_VIDEO_MODE_ON
	jne	vesa_mode_iff_1
	mov	ds: word ptr [si].IFF_PBM.Width,SWAP16(TEXT_WIDTH * VIDEO_FONT_WIDTH)
	mov	ds: word ptr [si].IFF_PBM.Height,SWAP16(TEXT_HEIGHT * VIDEO_FONT_HEIGHT)
	mov	ds: word ptr [si].IFF_PBM.PageWidth,SWAP16(TEXT_WIDTH * VIDEO_FONT_WIDTH)
	mov	ds: word ptr [si].IFF_PBM.PageHeight,SWAP16(TEXT_HEIGHT * VIDEO_FONT_HEIGHT)
	mov	ds: byte ptr [si].IFF_PBM.nPlanes,PACKED_BIT_COLOR
	mov	ds: dword ptr [iff_cmap_data].IFF_CMAP.CMAPSize,SWAP32((1 SHL PACKED_BIT_COLOR) * 3h)
	jmp	write_iff_pbm
vesa_mode_iff_1:
	movzx	bx,ds: byte ptr [panel_01].PANEL.RELATIVE_ELEMENT
	add	bx,ds: word ptr [panel_01].PANEL.ABSOLUTE_ELEMENT
	imul	bx,SIZEOF VESA_MODE_PANEL
	add	bx,OFFSET vesa_mode_info
	mov	ax,ds: word ptr [bx].VESA_MODE_PANEL.X_RES
	mov	dx,ds: word ptr [bx].VESA_MODE_PANEL.Y_RES
	cmp	ds: byte ptr [bx].VESA_MODE_PANEL.VIDEO_MODE_MODEL,VESA_MODE_TEXT
	jne	no_vesa_iff_text
	push	ax
	call	Get_Default_Font_Table
	imul	dx,ax
	pop	ax
	movzx	bp,ds: byte ptr [current_font_scanrow]
	imul	ax,bp
no_vesa_iff_text:
	inc	ax
	and	ax,0FFFEh
	xchg	al,ah
	xchg	dl,dh
	mov	ds: word ptr [si].IFF_PBM.Width,ax
	mov	ds: word ptr [si].IFF_PBM.Height,dx
	mov	ds: word ptr [si].IFF_PBM.PageWidth,ax
	mov	ds: word ptr [si].IFF_PBM.PageHeight,dx
	cmp	ds: byte ptr [bx].VESA_MODE_PANEL.VIDEO_MODE_MODEL,VESA_MODE_DIRECT_COLOR
	jne	no_vesa_iff_direct_color
	mov	ds: byte ptr [si].IFF_PBM.nPlanes,BIT_TRUE_COLOR
	jmp	write_iff_pbm
no_vesa_iff_direct_color:
	mov	ds: byte ptr [si].IFF_PBM.nPlanes,PACKED_BIT_COLOR
	mov	ds: dword ptr [iff_cmap_data].IFF_CMAP.CMAPSize,SWAP32((1 SHL PACKED_BIT_COLOR) *3)
write_iff_pbm:
	mov	ds: word ptr [di].CREATE_FILE.DATA_LEN,SIZEOF IFF_PBM
	mov	ds: word ptr [di].CREATE_FILE.OFFSET_BUFFER_SOURCE,si
	mov	ds: word ptr [di].CREATE_FILE.SEGMENT_BUFFER_SOURCE,ds
	call	Push_IO
	jc	exit_file_save_iff
	test	ds: byte ptr [status_flag_2],VESA_VIDEO_MODE_ON
	je	write_cmap
	cmp	ds: byte ptr [bx].VESA_MODE_PANEL.VIDEO_MODE_MODEL,VESA_MODE_DIRECT_COLOR
	je	no_cmap_write
write_cmap:
	add	ds: dword ptr [iff_write_bytes],(SIZEOF IFF_CMAP)+ (1 SHL PACKED_BIT_COLOR) * 3d
	mov	ds: word ptr [di].CREATE_FILE.DATA_LEN,SIZEOF IFF_CMAP
	mov	ds: word ptr [di].CREATE_FILE.OFFSET_BUFFER_SOURCE,OFFSET iff_cmap_data
	call	Push_IO
	jc	exit_file_save_iff
	mov	si,OFFSET iff_buffer
	xor	ah,ah
loop_get_colors:
	test	ds: byte ptr [status_flag_2],VESA_VIDEO_MODE_ON
	je	read_16_colors
	mov	al,ah
	cmp	ds: byte ptr [bx].VESA_MODE_PANEL.VIDEO_MODE_MODEL,VESA_MODE_PACKET
	je	read_256_colors
read_16_colors:
	cmp	ah,VGA_16_COLORS
	jb	read_attribute_color
	mov	ds: byte ptr [si],ZERO
	inc	si
	mov	ds: byte ptr [si],ZERO
	inc	si
	mov	ds: byte ptr [si],ZERO
	inc	si
	jmp	next_dac_color
read_attribute_color:
	call	Get_Attribute_Controller
read_256_colors:
	call	Get_DAC_Palette
	test	ds: byte ptr [status_flag_5],DAC_WIDTH
	je	standard_vga_dac
	add	si,3h
	jmp	next_dac_color
standard_vga_dac:
	shl	ds: byte ptr [si],2h
	inc	si
	shl	ds: byte ptr [si],2h
	inc	si
	shl	ds: byte ptr [si],2h
	inc	si
next_dac_color:
	inc	ah
	jne	loop_get_colors
	mov	ds: word ptr [di].CREATE_FILE.DATA_LEN,(1 SHL PACKED_BIT_COLOR) * 3h
	mov	ds: word ptr [di].CREATE_FILE.OFFSET_BUFFER_SOURCE,OFFSET iff_buffer
	call	Push_IO
	jc	exit_file_save_iff
no_cmap_write:
	add	ds: dword ptr [iff_write_bytes],SIZEOF IFF_BODY
	mov	ds: word ptr [di].CREATE_FILE.DATA_LEN,SIZEOF IFF_BODY
	mov	ds: word ptr [di].CREATE_FILE.OFFSET_BUFFER_SOURCE,OFFSET iff_body_data
	call	Push_IO
	jc	exit_file_save_iff
	xor	cx,cx
	mov	dx,ds: word ptr [iff_pbm_data].IFF_PBM.Height
	xchg	dl,dh
	mov	si,OFFSET iff_buffer
loop_line_iff:
	call	Get_Line
	test	ds: byte ptr [status_flag_2],VESA_VIDEO_MODE_ON
	je	exit_line_xor_0
	cmp	ax,MAX_IFF_BUFFER
	ja	exit_file_save_iff
	cmp	ds: byte ptr [bx].VESA_MODE_PANEL.VIDEO_MODE_MODEL,VESA_MODE_TEXT
	jne	line_xor_grfx
	push	ax
	push	cx
	mov	ax,cx
	movzx	cx,ds: byte ptr [current_font_scanline]
	div	cl
	dec	cx
	cmp	ah,cl
	jne	exit_line_xor_1
check_al_text:
	or	al,al
	jne	text_double_xor
	call	Line_Xor
	jmp	exit_line_xor_1
text_double_xor:
	dec	ax
	call	Line_Xor
	pop	cx
	dec	dx
	cmp	cx,dx
	push	cx
	jne	no_end_text
	inc	dx
	jmp	exit_line_xor_1
no_end_text:
	inc	dx
	inc	ax
	call	Line_Xor
exit_line_xor_1:
	pop	cx
	pop	ax
	jmp	exit_line_xor_0
line_xor_grfx:
	or	cx,cx
	jne	xor_current_line
	call	Line_XOR
	jmp	exit_line_xor_0
xor_current_line:
	dec	dx
	cmp	cx,dx
	je	no_init_xor_2
	call	Line_XOR
no_init_xor_2:
	inc	dx
	dec	cx
	call	Line_XOR
	inc	cx
exit_line_xor_0:
	mov	di,ds
	add	di,SEGMENT_4
	mov	es,di
	xor	di,di
	call	Compress_Line
	add	ds: word ptr [iff_write_bytes],ax
	adc	ds: word ptr [iff_write_bytes + 2h],0h
	mov	ds: word ptr [dos_create_file].CREATE_FILE.OFFSET_BUFFER_SOURCE,di
	mov	di,OFFSET dos_create_file
	mov	ds: word ptr [di].CREATE_FILE.DATA_LEN,ax
	mov	ds: word ptr [di].CREATE_FILE.SEGMENT_BUFFER_SOURCE,es
	call	Push_IO
	jc	exit_file_save_iff
	mov	bp,ds
	mov	es,bp
	inc	cx
	cmp	dx,cx
	jne	loop_line_iff
	mov	ds: word ptr [di].CREATE_FILE.SEGMENT_BUFFER_SOURCE,ds
	test	ds: byte ptr [iff_write_bytes],1h
	je	no_pad_iff
	mov	ds: byte ptr [si],IFF_PAD
	mov	ds: word ptr [di].CREATE_FILE.DATA_LEN,1h
	mov	ds: word ptr [di].CREATE_FILE.OFFSET_BUFFER_SOURCE,si
	call	Push_IO
	jc	exit_file_save_iff
no_pad_iff:
	call	Flush_IO
	jc	exit_file_save_iff
	xor	cx,cx
	mov	dx,FORM_SIZE_FILE_OFFSET
	call	Seek_File
	jc	exit_file_save_iff
	mov	eax,ds: dword ptr [iff_write_bytes]
	sub	eax,IFF_FORM_LEN
	call	Swap_32
	mov	ds: dword ptr [si],eax
	mov	ds: word ptr [di].CREATE_FILE.DATA_LEN,SIZEOF DWORD
	mov	ds: word ptr [di].CREATE_FILE.OFFSET_BUFFER_SOURCE,si
	call	Push_IO
	jc	exit_file_save_iff
	call	Flush_IO
	jc	exit_file_save_iff
	xor	cx,cx
	mov	dx,(SIZEOF IFF_PBM) + (SIZEOF IFF_CMAP) + (1 SHL PACKED_BIT_COLOR) * 3d + SIZEOF DWORD
	test	ds: byte ptr [status_flag_2],VESA_VIDEO_MODE_ON
	je	valid_seek_body
	cmp	ds: byte ptr [bx].VESA_MODE_PANEL.VIDEO_MODE_MODEL,VESA_MODE_DIRECT_COLOR
	jne	valid_seek_body
	mov	dx,(SIZEOF IFF_PBM) + SIZEOF DWORD
valid_seek_body:
	call	Seek_File
	jc	exit_file_save_iff
	mov	eax,ds: dword ptr [iff_write_bytes]
	sub	eax,(SIZEOF IFF_PBM) + (SIZEOF IFF_CMAP) + (1 SHL PACKED_BIT_COLOR) * 3d + (SIZEOF IFF_BODY)
	test	ds: byte ptr [status_flag_2],VESA_VIDEO_MODE_ON
	je	valid_size_body
	cmp	ds: byte ptr [bx].VESA_MODE_PANEL.VIDEO_MODE_MODEL,VESA_MODE_DIRECT_COLOR
	jne	valid_size_body
	add	eax,(SIZEOF IFF_CMAP) + (1 SHL PACKED_BIT_COLOR) * 3d
valid_size_body:
	call	Swap_32
	mov	ds: dword ptr [si],eax
	call	Push_IO
	jc	exit_file_save_iff
	call	Flush_IO
	jc	exit_file_save_iff
	call	Close_File
exit_file_save_iff:
	test	ds: byte ptr [status_flag_2],VESA_VIDEO_MODE_ON
	je	no_sound_ss_done
	SOUND_END
no_sound_ss_done:
	and	ds: byte ptr [status_flag_3],NOT SCREENSHOT_ON
	popa
	ret
