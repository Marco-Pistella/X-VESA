;#############################################################################

	Show_VBE_PM:

;#############################################################################

	pusha
	call	Save_Current_Video_Page
	call	Clear_Screen
	mov	ax,(VESA_ID SHL 8h) + VESAFUNC_VBE_PM
	mov 	bl,REPORT_VBE_PM_CAPABILITIES
	mov	di,DUMMY_BUFFER_SDD53
	VIDEO_CALL
	cmp	ax,VESA_ID
	je	valid_vbe_pm
	mov	si,OFFSET vga_message_123
	call	View_Alert_Message
	jmp	exit_vbe_pm
valid_vbe_pm:
	mov	si,OFFSET vga_message_125
	mov	di,OFFSET vga_message_126
	CENTER_BOX 36h,0Ah
	call    Extended_Box
	add	cx,0A02h
	mov	si,OFFSET vga_message_124
	call	Write_Vga_Message
	mov	ch,27h
	mov	al,bl
	shr	al,4h
	call	Write_Dec_Num_Left8
	mov	al,ds: byte ptr [decimal_sign]
	call	Write_Char
	mov	al,bl
	and	al,0Fh
	call	Write_Dec_Num_Left8
	mov	ch,27h
	add	cl,2h
	mov	dx,108h
	mov	al,bh
	mov	ds: byte ptr [vbepm_capabilities],al
	call	Block_Yes_Or_No
loop_key_vbe_pm:
	call	Get_Key
	cmp	ax,F10_KEY
	jne	test_key_esc_vbe_pm
	call	Save_Current_Video_Page
	call	Clear_Screen
	mov	al,ds: byte ptr [vbepm_capabilities]
	mov	bx,OFFSET bit_table
	xlatb
	or	al,al
	jne	valid_pm_set
	mov	si,OFFSET vga_message_127
	call	View_Alert_Message
	jmp	exit_f10_vbepm
valid_pm_set:
	add	al,6h
	mov	ah,30h
	call	Center_Box_Dynamic
	mov	si,OFFSET vga_message_129
	mov	di,OFFSET vga_message_007
	call	Extended_Box
	add	cx,402h
	mov	al,ds: byte ptr [vbepm_capabilities]
	mov	ah,1h
	mov	si,OFFSET vga_message_128
loop_power_state:
	test	al,ah
	je	no_power_state
	call	Write_VGA_Message
	inc	cx
no_power_state:
	call	Str_Len_Mem
	add	ah,ah
	cmp	ah,10h
	jne	loop_power_state
	inc	cx
	mov	si,OFFSET vga_message_130
	call	Write_VGA_Message
loop_power_key:
	call	Get_Key
	mov	cl,ds: byte ptr [vbepm_capabilities]
	mov	bx,(1h SHL 8) OR SET_VBE_PM_POWER_STATE
	mov	si,OFFSET vga_message_131
	test	cl,1h
	je	no_1_key
	cmp	ax,_1_KEY
	je	set_power_state
no_1_key:
	add	bh,bh
	mov	si,OFFSET vga_message_132
	test	cl,2h
	je	no_2_key
	cmp	ax,_2_KEY
	je	set_power_state	                 	
no_2_key:
	add	bh,bh
	mov	si,OFFSET vga_message_133
	test	cl,4h
	je	no_3_key
	cmp	ax,_3_KEY
	je	set_power_state	                 	
no_3_key:
	add	bh,bh
	mov	si,OFFSET vga_message_134
	test	cl,8h
	je	no_4_key
	cmp	ax,_4_KEY
	je	set_power_state	                 	
no_4_key:
	cmp	ax,ESC_KEY
	je	exit_f10_vbepm
	jmp	loop_power_key
set_power_state:
	call	Save_Current_Video_Page
	call	Clear_Screen
	call	View_Instant_Message
	mov	ax,(VESA_ID SHL 8h) + VESAFUNC_VBE_PM
	VIDEO_CALL
	mov	ah,KEY_FUNC_GET
	int	KEY_INTERRUPT
	mov	ax,(VESA_ID SHL 8h) + VESAFUNC_VBE_PM
	mov	bx,SET_VBE_PM_POWER_STATE
	VIDEO_CALL
	call	Init_X_Vesa
	call	Restore_Current_Video_Page
	jmp	loop_power_key
exit_f10_vbepm:
	call	Restore_Current_Video_Page
	jmp	loop_key_vbe_pm
test_key_esc_vbe_pm:
	cmp	ax,ESC_KEY
	jne	loop_key_vbe_pm
exit_vbe_pm:	
	call	Restore_Current_Video_Page
	popa
	ret
