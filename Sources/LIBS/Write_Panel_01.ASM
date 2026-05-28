;#############################################################################

;	AX = Elemento da visualizzare

	Write_Panel_01:

;#############################################################################

	pusha
	mov	ds: byte ptr [color_base_mem],EXTRA_COLOR
	imul	bx,ax,SIZEOF VESA_MODE_PANEL
	add	bx,OFFSET vesa_mode_info
	mov	ch,3h
	mov	ax,ds: word ptr [bx].VESA_MODE_PANEL.VIDEO_MODE
	call	Num_To_Str_Hex4
	mov	ax,ds: word ptr [bx].VESA_MODE_PANEL.X_RES
	mov	ch,0Eh
	call	Write_Dec_Num16
	mov	ax,ds: word ptr [bx].VESA_MODE_PANEL.Y_RES
	mov	ch,16h
	call	Write_Dec_Num16
	mov	ch,1Ch
	mov	al,ds: byte ptr [bx].VESA_MODE_PANEL.COLOR_BPP
	cmp	al,VESA_VIDEO_MODE_8BPP
	jbe	no_dc_mode
	mov	al,ds: byte ptr [bx].VESA_MODE_PANEL.COLOR_BPP
	dec	ch
	call	Write_Dec_Num8
	inc	ch
	mov	al,'/'
	call	Write_Char
	mov	al,ds: byte ptr [bx].VESA_MODE_PANEL.MEMORY_BPP
no_dc_mode:
	call	Write_Dec_Num_Left8
display_mode_type:
	mov	ch,23h
	mov	si,OFFSET vga_message_014
	cmp	ds: byte ptr [bx].VESA_MODE_PANEL.VIDEO_MODE_MODEL,VESA_MODE_TEXT
	je	text_mode
	dec	ch
	mov	si,OFFSET vga_message_015
text_mode:
	call	Write_VGA_Message
	mov	ax,ds: word ptr [bx].VESA_MODE_PANEL.VIDEO_SEGMENT
	or	ax,ax
	jne	valid_banked_video_mode
	mov	si,OFFSET vga_message_033
	mov	ch,2Eh
	call	Write_VGA_Message
	mov	ch,39h
	call	Write_VGA_Message
	mov	ch,47h
	call	Write_VGA_Message
	jmp	exit_write_panel_01
valid_banked_video_mode:
	mov	ch,2Dh
	call	Num_To_Str_Hex4
	mov	al,'h'
	call	Write_Char
	mov	al,ds: byte ptr [bx].VESA_MODE_PANEL.WINDOW_SIZE
	mov	ch,39h
	call	Write_Dec_Num8
	mov	al,ds: byte ptr [bx].VESA_MODE_PANEL.WINDOW_GRANULARITY
	mov	ch,46h
	call	Write_Dec_Num8
	mov	si,OFFSET vga_message_013
	mov	ch,3Bh
	call	Write_VGA_Message
	mov	ch,48h
	call	Write_VGA_Message
exit_write_panel_01:
	mov	ds: byte ptr [color_base_mem],COLOR_BASE
	popa
	ret
