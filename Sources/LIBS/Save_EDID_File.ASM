;#############################################################################

	Save_EDID_File:

;#############################################################################

	pusha
	mov	di,OFFSET dos_create_file
	mov	ds: word ptr [di].CREATE_FILE.OFFSET_INSTANT_MESSAGE,OFFSET vga_Message_044
	mov	ds: word ptr [di].CREATE_FILE.OFFSET_NAME_DECIMAL,OFFSET vga_message_041 + 1Eh
	mov	ds: word ptr [di].CREATE_FILE.OFFSET_FILE_NAME,OFFSET vga_message_041 + 1Ah
	mov	ds: word ptr [di].CREATE_FILE.OFFSET_FAIL_MESSAGE,OFFSET vga_message_043
	mov	ds: word ptr [di].CREATE_FILE.OFFSET_CLOSE_MESSAGE,OFFSET vga_message_041
	mov	ds: word ptr [di].CREATE_FILE.OFFSET_BUFFER_IO,BUFFER_IO
	mov	ds: word ptr [di].CREATE_FILE.SEGMENT_BUFFER_IO,ds
	add	ds: word ptr [di].CREATE_FILE.SEGMENT_BUFFER_IO,SEGMENT_4
	call	Create_Unique_File
	jc	fail_edid_file_save
	mov	ds: word ptr [di].CREATE_FILE.DATA_LEN,SIZEOF EDID128
	movzx	ax,ds: byte ptr [panel_02].PANEL.RELATIVE_ELEMENT
	add	ax,ds: word ptr [panel_02].PANEL.ABSOLUTE_ELEMENT
	imul	ax,SIZEOF EDID
	add	ax,OFFSET edid_data.EDID.EDIDData
	mov	ds: word ptr [di].CREATE_FILE.OFFSET_BUFFER_SOURCE,ax
	mov	ds: word ptr [di].CREATE_FILE.SEGMENT_BUFFER_SOURCE,ds
	call	Push_IO
	jc	fail_edid_file_save
	call	Flush_IO
	jc	fail_edid_file_save
	call	Close_File
fail_edid_file_save:
	popa
	ret
