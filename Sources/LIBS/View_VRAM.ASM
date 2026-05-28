;#############################################################################

;	DS:BX = Pointer to vesa_mode_info video mode

	View_VRAM:

;#############################################################################

	pusha
	call	Save_Current_Video_Page
	xor	cx,cx
	mov	dx,((TEXT_WIDTH - 1) SHL 8) + MAIN_WIN1_HEIGHT
	mov	si,OFFSET vga_message_246
	xor	di,di
	call	Extended_Box
	call	Draw_Adapter_Info
	call	Draw_Total_Video_Mode
	mov	cx,MAIN_WIN1_HEIGHT + 2h
	mov	dx,((TEXT_WIDTH - 1) SHL 8) + TEXT_HEIGHT - 1
	xor	si,si
	mov	di,OFFSET vga_message_247
	call	Extended_Box
	mov	si,OFFSET vga_message_248
	mov	cx,809h
	call	Write_VGA_Message
	mov	ax,ds: word ptr [panel_01].PANEL.TOTAL_ELEMENTS
	mov	ds: word ptr [panel_05].PANEL.TOTAL_ELEMENTS,ax
	mov	si,OFFSET panel_05
	call	Redraw_All_Init
loop_get_key_view_vram:
	call	Select_Item
	cmp	ax,F5_KEY
	jne	test_wr5_k1
	call	Save_Current_Video_Page
	call	Clear_Screen
	pusha
	mov	bx,OFFSET vga_message_028
	mov	di,OFFSET vga_message_160
	mov	si,OFFSET vga_message_252
	call	Show_Message
	popa
loop_key_segment_1:
	call	Get_Key
	cmp	ax,N_KEY
	je	exit_f5_key
	cmp	ax,Y_KEY
	jne	loop_key_segment_1
	or	ds: byte ptr [status_flag_4],AUTO_OPEN_VESA
	mov	bx,OFFSET vesa_mode_info
	mov	cx,ds: word ptr [panel_01].PANEL.TOTAL_ELEMENTS
	inc	cx
loop_get_vram_all:
	cmp	ds: byte ptr [bx].VESA_MODE_PANEL.VIDEO_MODE_MODEL,VESA_MODE_PLANAR
	je	valid_video_mode_for_vram
	cmp	ds: byte ptr [bx].VESA_MODE_PANEL.VIDEO_MODE_MODEL,VESA_MODE_PACKET
	je	valid_video_mode_for_vram
	cmp	ds: byte ptr [bx].VESA_MODE_PANEL.VIDEO_MODE_MODEL,VESA_MODE_DIRECT_COLOR
	jne	next_video_mode
valid_video_mode_for_vram:
	and	ds: byte ptr [status_flag_2],NOT VESA_MEMORY_MODE
	call	Retrieve_VRAM_Size
	jc	next_video_mode
	or	ebp,ebp
	jne	next_video_mode
	or	ds: byte ptr [status_flag_4],VALID_VESA_ADDRESSING
	call	Open_VESA_Video_Mode
	jc	next_video_mode
	call	Get_VESA_VRAM_Size
next_video_mode:
	or	ds: byte ptr [status_flag_2],VESA_MEMORY_MODE
	call	Retrieve_VRAM_Size
	jc	next_video_mode_1
	or	ebp,ebp
	jne	next_video_mode_1
	or	ds: byte ptr [status_flag_4],VALID_VESA_ADDRESSING
	call	Open_VESA_Video_Mode
	jc	next_video_mode_1
	call	Get_VESA_VRAM_Size
next_video_mode_1:
	and	ds: byte ptr [status_flag_2],NOT VESA_MEMORY_MODE
	add	bx,SIZEOF VESA_MODE_PANEL
	loop	loop_get_vram_all
	and	ds: byte ptr [status_flag_4],NOT AUTO_OPEN_VESA
	call	Init_X_Vesa
	call	Restore_Current_Video_Page
	call	Redraw_All
	jmp	loop_get_key_view_vram
exit_f5_key:
	call	Restore_Current_Video_Page
	jmp	loop_get_key_view_vram
test_wr5_k1:
	cmp	ax,ESC_KEY
	jne	loop_get_key_view_vram
	call	Restore_Current_Video_Page
	popa
	ret
