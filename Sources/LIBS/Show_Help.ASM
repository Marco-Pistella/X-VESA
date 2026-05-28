;#############################################################################

;	DS:BX = Pointer to help string
;	DS: BYTE [n_line_help] = Window help Y lenght

	Show_Help:

;#############################################################################

	pusha
	call	Save_Current_Video_Page
	call	Clear_Screen
	mov	ah,30h
	mov	al,ds: byte ptr [n_line_help]
	call	Center_Box_Dynamic
	mov	si,OFFSET vga_message_006
	mov	di,OFFSET vga_message_007
	call    Extended_Box
	mov	si,bx
	add	cx,402h
	call	Write_Vga_Message
loop_key_01a:
	call	Get_Key
	cmp	ax,ESC_KEY
	jne	loop_key_01a
	call	Restore_Current_Video_Page
	popa
	ret
