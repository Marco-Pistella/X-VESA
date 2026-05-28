;#############################################################################

	Save_Extension_Block:

;#############################################################################

	pusha
	mov	di,OFFSET dos_create_file
	mov	ds: word ptr [di].CREATE_FILE.OFFSET_INSTANT_MESSAGE,OFFSET vga_Message_120
	mov	ds: word ptr [di].CREATE_FILE.OFFSET_NAME_DECIMAL,OFFSET vga_message_121 + 22h
	mov	ds: word ptr [di].CREATE_FILE.OFFSET_FILE_NAME,OFFSET vga_message_121 + 1Eh
	mov	ds: word ptr [di].CREATE_FILE.OFFSET_FAIL_MESSAGE,OFFSET vga_message_122
	mov	ds: word ptr [di].CREATE_FILE.OFFSET_CLOSE_MESSAGE,OFFSET vga_message_121
	mov	ds: word ptr [di].CREATE_FILE.OFFSET_BUFFER_IO,BUFFER_IO
	mov	ds: word ptr [di].CREATE_FILE.SEGMENT_BUFFER_IO,ds
	add	ds: word ptr [di].CREATE_FILE.SEGMENT_BUFFER_IO,SEGMENT_4
	call	Create_Unique_File
	jc	fail_ext_file_save
	mov	ds: word ptr [di].CREATE_FILE.DATA_LEN,SIZEOF EDID128
	mov	ds: word ptr [di].CREATE_FILE.OFFSET_BUFFER_SOURCE,OFFSET edid_extension_buffer
	mov	ds: word ptr [di].CREATE_FILE.SEGMENT_BUFFER_SOURCE,ds
	call	Push_IO
	jc	fail_ext_file_save
	call	Flush_IO
	jc	fail_ext_file_save
	call	Close_File
fail_ext_file_save:
	popa
	ret
