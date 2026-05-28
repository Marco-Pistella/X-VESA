	.X64P
	CODE SEGMENT PARA PUBLIC USE16 'CODE'
	ASSUME	CS:CODE,DS:CODE,ES:CODE,SS:CODE
	ORG 	100h

	include INCLUDE\DOS.INC
	include INCLUDE\VIDEO.INC
	include INCLUDE\VESA.INC
	include INCLUDE\X-VESA.INC
	include INCLUDE\HARDWARE.INC
	include INCLUDE\KEY.INC
	include INCLUDE\STRUCT.INC
	include INCLUDE\MACRO.INC

start_code:
	mov	ax,cs
	add	ax,((OFFSET end_code - OFFSET start_code) + 0Fh) SHR 4h
	mov	es,ax
	cmp	sp,0FFFEh
	je	no_sdt_stub
	pop	cx
	pop	bx
	push	cs
	mov	ax,OFFSET no_sdt_stub
	push	ax
	push	bx
	push	cx	
	retf
no_sdt_stub:
	mov	ax,es
	mov	ds,ax
	add	ax,START_STACK
	mov	ss,ax
	push	cs
	push	OFFSET start_x_vesa
	push	ds
	push	OFFSET start_data + 100h
	retf
start_x_vesa:
	mov	ax,ds
	add	ax,10h
	mov	ds,ax
	mov	es,ax
	cld
	call	Init_Message
	mov	ds: word ptr [dos_message_pointer],OFFSET dos_message_01
	mov	ax,(DOS_FUNC_GET_VERSION_NUMBER SHL 8h) + DOS_VerOrOEMFlag
	int	DOS_INTERRUPT
	cmp	al,DOS_VERSION_MIN
	jb	exit_with_print
	mov	ds: word ptr [dos_message_pointer],OFFSET dos_message_02
	mov	cx,HW_END_SEGMENT
	rep	lods	es: byte ptr [si]
	jcxz	pass_386_mode
exit_with_print:
	push	es
	pop	ds
	mov	ah,DOS_FUNC_DISPLAY_STRING
	mov	dx,ds: word ptr [dos_message_pointer]
	int	DOS_INTERRUPT
	mov	ax,(DOS_FUNC_END_PROGRAM SHL 8h) + DOS_ReturnValue
	int	DOS_INTERRUPT
pass_386_mode:
	mov	al,HW_TEST_SHIFT_VAL
	mov	cl,HW_TEST_SHIFT
	shl	al,cl
	or	al,al
	je	exit_with_print
	push	sp
	pop	ax
	cmp	ax,sp
	jne	exit_with_print
	pushf
	pop	ax
	or	ah,HW_FLAG_ID
	push	ax
	popf
	pushf
	pop	ax
	test	ah,HW_FLAG_ID
	je	exit_with_print
	mov	ds: word ptr [dos_message_pointer],OFFSET dos_message_18
	mov	cx,1000d
loop_386_bug:	
	mov	eax,417A000h
	mov	edx,81h
	mul	edx
	cmp	eax,0FE7A000h
	jne	exit_with_print
	cmp	edx,2h
	jne	exit_with_print
	mov	eax,0C17A000h
	mov	edx,0E1h
	mul	edx
	cmp	eax,0A0C3A000h
	jne	exit_with_print
	cmp	edx,0Ah
	jne	exit_with_print
	loop	loop_386_bug
	mov	ds: word ptr [dos_message_pointer],OFFSET dos_message_17
	mov	si,DOS_FREE_MEMORY
	call	Get_BIOS_Mem
	movzx	eax,ax
	shl	eax,10d
	mov	bx,cs
	movzx	ebx,bx
	shl	ebx,4d
	add	ebx,X_VESA_MEM
	sub	eax,ebx
	jb	exit_with_print
	mov	ax,ds
	mov	gs,ax
	add	ax,SEGMENT_3
	mov	ss,ax
	mov	ds: word ptr [dos_message_pointer],OFFSET dos_message_04
	mov	ds,cs: word ptr [DOS_OFFSET_pspEnvironment]
	xor	si,si
search_double_zero:
	inc	si
	cmp	si,HW_END_SEGMENT
	je	exit_with_print
	cmp	ds: word ptr [si],DOS_DOUBLE_ZERO
	jne	search_double_zero
	add	si,4h
	call	Str_Len
	jc	exit_with_print
	inc	ax
	mov	es: word ptr [dos_message_pointer],OFFSET dos_message_05
	cmp	ax,DOS_MAX_LEN_PATH
	ja	exit_with_print
	xchg	ax,cx
	mov	di,OFFSET x_vesa_file_name
	rep	movsb
	push	es
	pop	ds
	mov	ds: word ptr [dos_message_pointer],OFFSET dos_message_06
	mov	ax,(DOS_FUNC_OPEN_FILE SHL 8h) + DOS_OPEN_ACCESS_READ_ONLY
	mov	dx,OFFSET x_vesa_file_name
	int	DOS_INTERRUPT
	jc	exit_with_print
	xchg	ax,bx
	mov	ax,ds
	add	ax,SEGMENT_4
	mov	ds,ax
	mov	ah,DOS_FUNC_READ_FILE
	mov	cx,MAX_X_VESA_FILE_LEN
	xor	dx,dx
	int	DOS_INTERRUPT
	jc	exit_with_print
	push	ax
	mov	ah,DOS_FUNC_CLOSE_FILE
	int	DOS_INTERRUPT
	pop	cx
	jc	exit_with_print
	sub	cx,CHECKSUM_LEN
	xor	si,si
	call	Get_Checksum
	add	si,cx
	cmp	eax,ds: dword ptr [si]
	push	es
	pop	ds
	mov	ds: word ptr [dos_message_pointer],OFFSET dos_message_07
	jne	exit_with_print
	mov	ds: word ptr [dos_message_pointer],OFFSET dos_message_08
	mov	si,OFFSET x_vesa_file_name
	call	Str_Len
	add	si,ax
	mov	cx,OFFSET end_x_vesa_name - OFFSET x_vesa_name
	sub	si,cx
	mov	di,OFFSET x_vesa_name
	repe	cmpsb
	or	cx,cx
	jne	exit_with_print
	mov	ds: word ptr [dos_message_pointer],OFFSET dos_message_10
	mov	ax,(VIDEO_FUNC_RW_DCC SHL 8d) + VIDEO_READ_DCC
	VIDEO_CALL
	cmp	al,VIDEO_FUNC_RW_DCC
	jne	exit_with_print
	cmp	bl,VIDEO_VGA_MONO
	je	ok_vga
	cmp	bl,VIDEO_VGA_COLOR
	jne	exit_with_print
ok_vga:
	mov	ds: word ptr [dos_message_pointer],OFFSET dos_message_09
next_init_mode_3:
	mov	ah,VIDEO_FUNC_CURRENT_STATE
	VIDEO_CALL
	cmp	al,VIDEO_MODE_START
	jne	set_mode_3
	mov	si,VIDEO_OFFSET_HEIGHT
	call	Get_BIOS_Mem
	cmp	al,VIDEO_START_TEXT_HEIGHT - 1h
	jne	set_mode_3
	mov	si,VIDEO_OFFSET_FONT_HEIGHT
	call	Get_BIOS_Mem
	cmp	al,VIDEO_INIT_FONT_HEIGHT
	je	ok_mode_3
set_mode_3:
	test	ds: byte ptr [status_flag_3],INIT_VGA_MODE_3
	jne	exit_with_print
	or	ds: byte ptr [status_flag_3],INIT_VGA_MODE_3
	mov	ax,(VIDEO_FUNC_ALTERNATE_SELECT SHL 8) + VIDEO_400_LINES
	mov	bl,VIDEO_SUBFUNC_SET_SCANLINES
	VIDEO_CALL
	mov	ax,(VIDEO_FUNC_SET_MODE SHL 8h) + VIDEO_MODE_START
	VIDEO_CALL
	call	Init_Message
	jmp	next_init_mode_3
ok_mode_3:
	mov	ax,(DOS_FUNC_GET_COUNTRY_INFORMATION SHL 8h) + DOS_CountryCode
	mov	dx,OFFSET dos_country_info_buffer
	int	DOS_INTERRUPT
	jc	fail_country_info_use_eng
	mov	al,ds: byte ptr [dos_country_info_buffer + DOS_OFFSET_ciThousands]
	mov	ds: byte ptr [thousands_sign],al
	mov	al,ds: byte ptr [dos_country_info_buffer + DOS_OFFSET_ciDecimal]
	mov	ds: byte ptr [decimal_sign],al
fail_country_info_use_eng:
	mov	ds: word ptr [dos_message_pointer],OFFSET dos_message_11
	mov	ax,(VESA_ID SHL 8h) + VESA_FUNC_RETURN_CONTROLLER_INFORMATION
	mov	di,OFFSET vesa_buffer_func_0
	mov	ds: dword ptr [di],VESA_MAGIC_1
	VIDEO_CALL
	cmp	ax,VESA_ID
	jne	exit_with_print
	cmp	ds: dword ptr [di],VESA_MAGIC_2
	jne	exit_with_print
	mov	ds: word ptr [dos_message_pointer],OFFSET dos_message_12
	lfs	si,ds: dword ptr [di].VbeInfoBlock.VideoModePtr
	mov	bx,OFFSET vesa_mode_info
loop_get_vesa_mode:
	cmp	si,HW_END_SEGMENT
	je	exit_with_print
	or	si,si
	je	exit_with_print
	lods	fs: word ptr [si]
	cmp	ax,VESA_END_TABLE
	je	exit_loop_get_vesa_mode
	cmp	ds: word ptr [panel_01].PANEL.TOTAL_ELEMENTS,MAX_VESA_MODE - 1h
	jne	add_vesa_video_mode
	or	ds: byte ptr [status_flag_0],FLAG_TOO_VESA_MODE
	jmp	exit_loop_get_vesa_mode
add_vesa_video_mode:
	call	Check_VESA_Mode
	jc	loop_get_vesa_mode
	add	bx,SIZEOF VESA_MODE_PANEL
	inc	ds: word ptr [panel_01].PANEL.TOTAL_ELEMENTS
	jmp	loop_get_vesa_mode
exit_loop_get_vesa_mode:
	mov	ds: word ptr [dos_message_pointer],OFFSET dos_message_13
	cmp	ds: word ptr [panel_01].PANEL.TOTAL_ELEMENTS,ZERO_VESA_MODE
	je	exit_with_print
	call	Retrieve_CPU_Capabilities
	call	Get_VESA_PM
	mov	ds: word ptr [dos_message_pointer],OFFSET dos_message_14
	call	Init_X_VESA
	jc	exit_with_print
	test	ds: byte ptr [status_flag_0],FLAG_TOO_VESA_MODE
	je	no_too_vesa_mode_1
	mov	si,OFFSET vga_message_304
	or	ds: byte ptr [status_flag_5],ESC_ALERT_MESSAGE
	call	View_Alert_Message
	and	ds: byte ptr [status_flag_5],NOT ESC_ALERT_MESSAGE
	call	Clear_Screen
no_too_vesa_mode_1:
	call	Draw_Interface
	push	cs
	pop	ds
	mov	dx,OFFSET DOS_Error_Handler
	mov	ax,(DOS_FUNC_SET_INTERRUPT SHL 8) + DOS_CRITICAL_ERROR_HANDLER
	int	DOS_INTERRUPT
	mov	ax,(DOS_FUNC_GET_INTERRUPT SHL 8) + INT_00
	int	DOS_INTERRUPT
	mov	gs: word ptr [old_offset_int_00],bx
	mov	gs: word ptr [old_segment_int_00],es
	mov	dx,OFFSET INT_00_Handler
	mov	ax,(DOS_FUNC_SET_INTERRUPT SHL 8) + INT_00
	int	DOS_INTERRUPT
	mov	ax,gs
	mov	ds,ax
	mov	es,ax
	mov	si,OFFSET panel_01
	call    Redraw_All_Init
key_loop_01:
	call	Select_Item
	cmp	ax,F6_KEY
	jne	test_key0
	call	View_VRAM
test_key0:
	cmp	ax,F1_KEY
	jne	test_key1
	mov	bx,OFFSET vga_message_008
	mov	ds: byte ptr [n_line_help],HELP1_LINE + 4h
	call	Show_Help
test_key1:
	cmp	ax,F8_KEY
	jne	test_key2
	call	Show_CPU_Info
test_key2:
	cmp	ax,F10_KEY
	jne	test_key3
	call	Show_Adapter_Info
test_key3:
	cmp	ax,F9_KEY
	jne	test_key4
	call	Show_EDID
test_key4:
	cmp	ax,F7_KEY
	jne	test_key5
	call	Show_VBE_PM
test_key5:
	cmp	ax,ENTER_KEY
	jne	test_key6
	call	Exec_VESA_Command
test_key6:
	cmp	ax,ESC_KEY
	jne	key_loop_01
exit_x_vesa:
	mov	ax,(VIDEO_FUNC_ALTERNATE_SELECT SHL 8) + VIDEO_400_LINES
	mov	bl,VIDEO_SUBFUNC_SET_SCANLINES
	VIDEO_CALL
	mov	ax,(VIDEO_FUNC_SET_MODE SHL 8h) + VIDEO_MODE_START
	VIDEO_CALL
	mov	ax,(DOS_FUNC_END_PROGRAM SHL 8h) + DOS_ReturnValue
	int	DOS_INTERRUPT

	include LIBS\Asci_To_Num.ASM
	include LIBS\BIOS_Ticks.ASM
	include LIBS\Block_Yes_Or_No.ASM
	include LIBS\Box.ASM
	include LIBS\Center_Box_Dynamic.ASM
	include LIBS\Check_VESA_Mode.ASM
	include	LIBS\Choice.ASM
	include LIBS\Clear_Graphic_VRAM.ASM
	include LIBS\Clear_Screen.ASM
	include LIBS\Compress_Line.ASM
	include	LIBS\Cursor_Off.ASM
	include	LIBS\Cursor_On.ASM
	include LIBS\Cursor_Pos.ASM
	include LIBS\Cursor_Size.ASM
	include LIBS\Delay.ASM
	include LIBS\DOS_Error_Handler.ASM
	include LIBS\DOS_IO.ASM
	include LIBS\Draw_Adapter_Info.ASM
	include LIBS\Draw_Interface.ASM
	include LIBS\Draw_OEM_String.ASM
	include LIBS\Draw_Version.ASM
	include LIBS\EDID_01.ASM
	include LIBS\EDID_02.ASM
	include LIBS\EDID_03.ASM
	include LIBS\EDID_04.ASM
	include LIBS\EDID_05.ASM
	include LIBS\EDID_06.ASM
	include LIBS\EDID_07.ASM
	include LIBS\EDID_08.ASM
	include LIBS\EDID_09.ASM
	include LIBS\Enable_A20_Line.ASM
	include LIBS\Exec_VESA_Command.ASM
	include LIBS\Exit_Return_AX.ASM
	include LIBS\Extended_Box.ASM
	include LIBS\Get_Attribute_Controller.ASM
	include LIBS\Get_BIOS_Mem.ASM
	include LIBS\Get_Checksum.ASM
	include LIBS\Get_CRTC.ASM
	include LIBS\Get_DAC_Palette.ASM
	include LIBS\Get_Default_Font_Table.ASM
	include LIBS\Get_Extension_Block.ASM
	include LIBS\Get_GCR.ASM
	include LIBS\Get_Input_Status_Register.ASM
	include LIBS\Get_Key.ASM
	include LIBS\Get_Line.ASM
	include LIBS\Get_Miscellaneous.ASM
	include LIBS\Get_Port.ASM
	include	LIBS\Get_Sequencer.ASM
	include LIBS\Get_VESA_PM.ASM
	include LIBS\Get_VESA_Scanline.ASM
	include LIBS\Init_Message.ASM
	include LIBS\Init_X_VESA.ASM
	include LIBS\INT_00_Handler.ASM
	include LIBS\Invert_Select.ASM
	include LIBS\Line_XOR.ASM
	include LIBS\Locate.ASM
	include LIBS\Move_Mem.ASM
	include LIBS\Next_Line.ASM
	include LIBS\Num_To_Str_Dec.ASM
	include LIBS\Num_To_Str_Hex.ASM
	include LIBS\Num_To_Str_Hex2.ASM
	include LIBS\Num_To_Str_Hex4.ASM
	include LIBS\Num_To_Str_Hex8.ASM
	include LIBS\Open_VESA_Video_Mode.ASM
	include	LIBS\Output_Redirector.ASM
	include LIBS\Redraw_All.ASM
	include LIBS\Restore_Current_Video_Page.ASM
	include LIBS\Retrieve_CPU_Capabilities.ASM
	include LIBS\Save_Current_Video_Page.ASM
	include LIBS\Save_EDID_File.ASM
	include LIBS\Save_Extension_Block.ASM
	include LIBS\Save_IFF_File.ASM
	include LIBS\Search_Descriptor.ASM
	include LIBS\Select_Item.ASM
	include LIBS\Set_Attribute_Controller.ASM
	include LIBS\Set_Bank.ASM
	include LIBS\Set_BIOS_Mem.ASM
	include LIBS\Set_CRTC.ASM
	include LIBS\Set_GCR.ASM
	include	LIBS\Set_Miscellaneous.ASM
	include LIBS\Set_Sequencer.ASM
	include LIBS\Set_VESA_Color.ASM
	include LIBS\Set_VESA_Scanline.ASM
	include LIBS\Show_Adapter_Info.ASM
	include LIBS\Show_Binary_EDID.ASM
	include LIBS\Show_CPU_Info.ASM
	include LIBS\Show_EDID.ASM
	include LIBS\Show_Help.ASM
	include LIBS\Show_Message.ASM
	include libs\Show_VBE_PM.ASM
	include LIBS\Size_of_Number8.ASM
	include LIBS\Size_of_Number16.ASM
	include LIBS\Size_of_Number32.ASM
	include	LIBS\Sound.ASM
	include LIBS\Str_Len.ASM
	include	LIBS\Str_Len_Mem.ASM
	include LIBS\Swap_32.ASM
	include LIBS\Timer_Off.ASM
	include	LIBS\Timer_On.ASM
	include	LIBS\Unlocate.ASM
	include LIBS\Update_Bar.ASM
	include LIBS\VESA_COMMAND_01.ASM
	include LIBS\VESA_COMMAND_02.ASM
	include LIBS\VESA_COMMAND_03.ASM
	include LIBS\VESA_COMMAND_04.ASM
	include LIBS\VESA_COMMAND_05.ASM
	include LIBS\VESA_COMMAND_06.ASM
	include LIBS\VESA_COMMAND_07.ASM
	include LIBS\VESA_COMMAND_08.ASM
	include LIBS\VESA_COMMAND_09.ASM
	include LIBS\VESA_Speed_Routines.ASM
	include LIBS\View_Alert_Message.ASM
	include LIBS\View_Instant_Message.ASM
	include LIBS\View_VRAM.ASM
	include LIBS\Write_Box_Message.ASM
	include LIBS\Write_Char.ASM
	include LIBS\Write_Dec_Num8.ASM
	include LIBS\Write_Dec_Num16.ASM
	include LIBS\Write_Dec_Num32.ASM
	include LIBS\Write_Dec_Num64.ASM
	include LIBS\Write_Dec_Num_Left8.ASM
	include LIBS\Write_Dec_Num_Left16.ASM
	include LIBS\Write_Dec_Num_Left32.ASM
	include LIBS\Write_Decimal_Number16.ASM
	include LIBS\Write_Decimal_Number32.ASM
	include LIBS\Write_Decimal_Number_Left32.ASM
	include LIBS\Write_EDID_Manifacturer_ID.ASM
	include LIBS\Write_Graphic_Box.ASM
	include LIBS\Write_Graphic_Box_Fill.ASM
	include LIBS\Write_Horizontal_Line.ASM
	include LIBS\Write_Index_String.ASM
	include LIBS\Write_Panel_01.ASM
	include LIBS\Write_Panel_02.ASM
	include LIBS\Write_Panel_03.ASM
	include LIBS\Write_Panel_04.ASM
	include LIBS\Write_Panel_05.ASM
	include LIBS\Write_Panel_06.ASM
	include LIBS\Write_Panel_07.ASM
	include LIBS\Write_Reserved.ASM
	include LIBS\Write_Same_Message.ASM
	include	LIBS\Write_Simple_VGA_Message.ASM
	include LIBS\Write_Standard_Timing.ASM
	include LIBS\Write_Timer.ASM
	include LIBS\Write_Vertical_Line.ASM
	include LIBS\Write_VESA_Char.ASM
	include LIBS\Write_VESA_String.ASM
	include LIBS\Write_VGA_Message.ASM
	include LIBS\Yes_Or_No.ASM

end_code:

	CODE ENDS

	include INCLUDE\DATA.ASM

	END	start_code
