;#############################################################################

;	DS:SI = Alert message pointer
;	FS = Video segment

	View_Alert_Message:

;#############################################################################

	pusha
	mov	bx,OFFSET vga_message_028
	mov	di,OFFSET vga_message_007
	test	ds: byte ptr [status_flag_5],ESC_ALERT_MESSAGE
	je	alert_esc_exit
	mov	di,OFFSET vga_message_314
alert_esc_exit:
	call	Show_Message
key_loop_02:
	call	Get_Key
	cmp	ax,ESC_KEY
	jne	key_loop_02
	popa
	ret

