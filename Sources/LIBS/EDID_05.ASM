;#############################################################################

;	DS:BX = EDID pointer

	edid_05:

;#############################################################################

	pusha
	mov	cx,190Ch
	mov	si,OFFSET vga_message_068
	call	Write_VGA_Message
	mov	cx,1420h
	mov	si,OFFSET vga_message_070
	call	Write_VGA_Message
	mov	cx,110Eh
	mov	si,OFFSET vga_message_069
	call	Write_VGA_Message
	mov	ds: byte ptr [color_base_mem],EXTRA_COLOR
	mov	ch,26h
	mov	al,ds: byte ptr [bx].EDID128.EstTimings
	mov	dx,8001h
	call	Block_Yes_Or_No
	mov	al,ds: byte ptr [bx + 1h].EDID128.EstTimings
	call	Block_Yes_Or_No
	mov	al,ds: byte ptr [bx + 2h].EDID128.EstTimings
	mov	ah,80h
	call	Yes_Or_No
	or	ds: byte ptr [status_flag_0],FLAG_THOUSANDS
	mov	cx,522h
	lea	di,ds: word ptr [bx].EDID128.StdTimings
	mov	bl,8h
loop_spc_mode:
	mov	ax,ds: word ptr [di]
	add	di,2h
	call	Write_Standard_Timing
	jc	next_mode
	add	ch,12h
	cmp	ch,4Dh
	jne	next_mode
	mov	ch,5h
	inc	cx
next_mode:
	dec	bl
	jne	loop_spc_mode
	cmp	cx,522h
	jne	exit_edid_5
	mov	si,OFFSET vga_message_087
	call	Write_VGA_Message
exit_edid_5:
	and	ds: byte ptr [status_flag_0],NOT FLAG_THOUSANDS
	mov	ds: byte ptr [color_base_mem],COLOR_BASE
	popa
	ret
