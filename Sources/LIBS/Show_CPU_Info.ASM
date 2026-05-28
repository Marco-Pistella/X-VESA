;#############################################################################

	Show_CPU_Info:

;#############################################################################

	pusha
	call	Save_Current_Video_Page
	call	Clear_Screen
	mov	si,OFFSET vga_message_016
	mov	di,OFFSET vga_message_007
	CENTER_BOX 2Dh,0Bh
	call    Extended_Box
	add	cx,402h
	mov	si,OFFSET vga_message_017
	call	Write_Vga_Message
	mov	ds: byte ptr [color_base_mem],EXTRA_COLOR
	add	ch,13h
	mov	al,ds: byte ptr [status_flag_0]
	mov	dx,(FLAG_V86_ON SHL 8) + FLAG_FPU_PRESENT
	call	Block_Yes_Or_No
	test	al,FLAG_V86_ON
	je	no_v86
	mov	si, OFFSET vga_message_018
	mov	al,5h
	call	Write_Same_Message
	jmp	exit_f8_key
no_v86:
	mov	al,ds: byte ptr [status_flag_2]
	mov	ah,A20_ENABLED
	call	Yes_Or_No
	mov	al,ds: byte ptr [status_flag_0]
	mov	dx,(FLAG_CPUID SHL 8) + FLAG_AVX512
	call	Block_Yes_Or_No
exit_f8_key:
	mov	ds: byte ptr [color_base_mem],COLOR_BASE
loop_key_01b:
	call	Get_Key
	cmp	ax,ESC_KEY
	jne	loop_key_01b	
	call	Restore_Current_Video_Page
	popa
	ret
