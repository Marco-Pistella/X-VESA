;#############################################################################

;	AX = Elemento da visualizzare

	Write_Panel_05:

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
	jbe	no_dc_mode_1
	mov	al,ds: byte ptr [bx].VESA_MODE_PANEL.COLOR_BPP
	dec	ch
	call	Write_Dec_Num8
	inc	ch
	mov	al,'/'
	call	Write_Char
	mov	al,ds: byte ptr [bx].VESA_MODE_PANEL.MEMORY_BPP
no_dc_mode_1:
	call	Write_Dec_Num_Left8
	mov	si,OFFSET vga_message_249
	mov	ch,22h
	mov	al,ds: byte ptr [bx].VESA_MODE_PANEL.VIDEO_MODE_MODEL
	call	Write_Index_String
	dec	cx
	mov	ch,30h
	mov	eax,ds: dword ptr [bx].VESA_MODE_PANEL.VRAM_SIZE_BANKED
	call	Write_Panel_05_01
	mov	ch,40h
	mov	eax,ds: dword ptr [bx].VESA_MODE_PANEL.VRAM_SIZE_LINEAR
	call	Write_Panel_05_01
	mov	ds: byte ptr [color_base_mem],COLOR_BASE
	popa
	ret

;#############################################################################

;	AX = Elemento da visualizzare

	Write_Panel_05_01:

;#############################################################################

	mov	si,OFFSET vga_message_250
	cmp	eax,0FFFFFFFFh
	je	write_ns_vram
	mov	si,OFFSET vga_message_025
	inc	ch
	or	eax,eax
	jne	continue_vram
write_ns_vram:
	call	Write_VGA_Message
	jmp	exit_vram_report
continue_vram:
	test	eax,80000000h
	je	valid_vram_size
	add	ch,4h
	mov	si,OFFSET vga_message_251
	call	Write_VGA_Message
	add	ch,5h
	mov	ds: byte ptr [color_base_mem],ND_COLOR
	call	Num_To_Str_Hex2
	mov	ds: byte ptr [color_base_mem],EXTRA_COLOR
	jmp	exit_vram_report
valid_vram_size:
	add	ch,7h
	call	Write_Dec_Num32
	add	ch,2h
	mov	si,OFFSET vga_message_013
	call	Write_VGA_Message
exit_vram_report:
	ret
