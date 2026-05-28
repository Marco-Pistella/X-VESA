;#############################################################################

	Draw_Interface:

;#############################################################################

	pusha
	xor	cx,cx
	mov	dx,((TEXT_WIDTH - 1) SHL 8) + MAIN_WIN1_HEIGHT
	mov	si,OFFSET vga_message_009
	xor	di,di
	call	Extended_Box
	call	Draw_Adapter_Info
	call	Draw_Total_Video_Mode
	mov	cx,MAIN_WIN1_HEIGHT + 2h
	mov	dx,((TEXT_WIDTH - 1) SHL 8) + TEXT_HEIGHT - 1
	xor	si,si
	mov	di,OFFSET vga_message_010
	call	Extended_Box
	mov	si,OFFSET vga_message_011
	mov	cx,809h
	call	Write_VGA_Message
	popa
	ret
