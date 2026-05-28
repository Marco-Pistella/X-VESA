;#############################################################################

;	DS:BX = Pointer to vesa_mode_info video mode

	VESA_Command_05:

;#############################################################################

	pusha
	or	ds: byte ptr [status_flag_4],VALID_VESA_ADDRESSING OR VALID_VESA_IO
	call	Open_VESA_Video_Mode
	jnc	valid_vesa_command_05_open
	popa
	ret
valid_vesa_command_05_open:
	call	Enter_Redirector
	cmp	ds: byte ptr [bx].VESA_MODE_PANEL.VIDEO_MODE_MODEL,VESA_MODE_TEXT
	jne	next_type_mode_command_5
	mov	es,ds: word ptr [banked_segment]
	xor	di,di
	mov	dx,ds: word ptr [bx].VESA_MODE_PANEL.Y_RES
	mov	si,ds: word ptr [bx].VESA_MODE_PANEL.X_RES
	mov	bp,ds: word ptr [current_bpsl]
	mov	ax,(0Fh SHL 8h ) + 'Û'
	stosw
	mov	cx,bp
	shr	cx,1h
	dec	cx
	dec	cx
	mov	al,'ß'
	rep 	stosw
	mov	al,'Û'
	stosw
	mov	cx,dx
	dec	cx
	dec	cx
loop_ext_text:
	mov	al,'Ý'
	mov	es: word ptr [di],ax
	mov	al,'Þ'
	mov	es: word ptr [bp + di - 2h],ax
	add	di,bp
	loop	loop_ext_text
	mov	al,'Û'
	stosw
	mov	cx,bp
	shr	cx,1h
	dec	cx
	dec	cx
	mov	al,'Ü'
	rep 	stosw
	mov	al,'Û'
	stosw
	mov	ax,dx
	sub	ax,10h
	shr	ax,1h
	mov	dx,ax
	add	dx,11h
	push	dx
	mul	bp
	sub	si,10h
	add	ax,si
	xchg	ax,di
	xor	ax,ax
	mov	ch,10h
loop_text_int_2:
	mov	cl,10h
loop_text_int_1:
	stosw
	add	ax,101h
	dec	cl
	jne	loop_text_int_1
	add	di,bp
	sub	di,20h
	dec	ch
	jne	loop_text_int_2
	call	Set_Virtual_String
	xor	cx,cx
	mov	si,OFFSET vga_message_228
	call	Write_Simple_VGA_Message
	inc	ch
	call	VESA_Command_02_01
	pop	dx
	call	Center_VESA_String
	call	Set_Virtual_String
	xor	cx,cx
	mov	si,OFFSET vga_message_245
	call	Write_VGA_Message
	inc	dx
	call	Center_VESA_String
	jmp	exit_vesa_command_05
next_type_mode_command_5:
	mov	si,OFFSET vesa_box
	mov	ds: word ptr [si].VBOX.X_START,0h
	mov	ds: word ptr [si].VBOX.Y_START,0h
	mov	ax,ds: word ptr [bx].VESA_MODE_PANEL.X_RES
	dec	ax
	mov	ds: word ptr [si].VBOX.X_END,ax
	mov	ax,ds: word ptr [bx].VESA_MODE_PANEL.Y_RES
	dec	ax
	mov	ds: word ptr [si].VBOX.Y_END,ax
	call	Write_Graphic_Box
	mov	ax,ds: word ptr [bx].VESA_MODE_PANEL.X_RES
	shr	ax,5h
	cmp	ax,10h
	jae	entry_x_box_len
	mov	ax,10h
entry_x_box_len:
	mov	ds: word ptr [command_box_x_len],ax
	shl	ax,4h
	mov	cx,ax
	sub	ax,ds: word ptr [bx].VESA_MODE_PANEL.X_RES
	neg 	ax
	shr	ax,1h
	cmp	ax,4h
	jae	valid_x_start_box
	mov	ax,ds: word ptr [command_box_x_len]
	dec	ax
	jmp	entry_x_box_len
valid_x_start_box:
	mov	ds: word ptr [command_box_x_start],ax
	add	ax,cx
	dec	ax
	mov	ds: word ptr [command_box_x_end],ax
	mov	ax,ds: word ptr [bx].VESA_MODE_PANEL.Y_RES
	sub	ax,38d * 2d
	shr	ax,5h
	cmp	ax,0Ah
	jae	entry_y_box_len
	mov	ax,0Ah
entry_y_box_len:
	mov	ds: word ptr [command_box_y_len],ax
	shl	ax,4h
	mov	cx,ax
	sub	ax,ds: word ptr [bx].VESA_MODE_PANEL.Y_RES
	sub	ax,38d
	neg	ax
	shr	ax,1h
	sub	ax,38d
	cmp	ax,4h
	jae	valid_y_start_box
	mov	ax,ds: word ptr [command_box_y_len]
	dec	ax
	jmp	entry_y_box_len
valid_y_start_box:
	mov	ds: word ptr [command_box_y_start],ax
	add	ax,cx
	dec	ax
	mov	ds: word ptr [command_box_y_end],ax
	cmp	ds: byte ptr [bx].VESA_MODE_PANEL.VIDEO_MODE_MODEL,VESA_MODE_PLANAR
	jne	go_command_5_box_packed
	mov	ax,ds: word ptr [command_box_x_start]
	mov	ds: word ptr [si].VBOX.X_START,ax
	mov	ax,ds: word ptr [command_box_x_end]
	mov	ds: word ptr [si].VBOX.X_END,ax
	mov	ax,ds: word ptr [command_box_y_start]
	mov	ds: word ptr [si].VBOX.Y_START,ax
	add	ax,ds: word ptr [command_box_y_len]
	dec	ax
	mov	ds: word ptr [si].VBOX.Y_END,ax
	xor	cl,cl
loop_box_fill_planar:
	mov	ds: byte ptr [foreground_vesa_color],cl
	call	Write_Graphic_Box_Fill
	mov	ax,ds: word ptr [command_box_y_len]
	add	ds: word ptr [si].VBOX.Y_START,ax
	add	ds: word ptr [si].VBOX.Y_END,ax
	inc	cl
	cmp	cl,VGA_16_COLORS
	jne	loop_box_fill_planar
	jmp	enter_for_command_5
go_command_5_box_packed:
	cmp	ds: byte ptr [bx].VESA_MODE_PANEL.VIDEO_MODE_MODEL,VESA_MODE_PACKET
	jne	go_command_5_box_direct_color
	mov	ax,ds: word ptr [command_box_x_start]
	mov	ds: word ptr [si].VBOX.X_START,ax
	add	ax,ds: word ptr [command_box_x_len]
	dec	ax
	mov	ds: word ptr [si].VBOX.X_END,ax
	mov	ax,ds: word ptr [command_box_y_start]
	mov	ds: word ptr [si].VBOX.Y_START,ax
	add	ax,ds: word ptr [command_box_y_len]
	dec	ax
	mov	ds: word ptr [si].VBOX.Y_END,ax
	mov	cl,10h
	mov	ds: byte ptr [foreground_vesa_color],0h
loop_box_fill_packed_ver:
	mov	ch,10h
loop_box_fill_packed_hor:
	call	Write_Graphic_Box_Fill
	inc	ds: byte ptr [foreground_vesa_color]
	mov	ax,ds: word ptr [command_box_x_len]
	add	ds: word ptr [si].VBOX.X_START,ax
	add	ds: word ptr [si].VBOX.X_END,ax
	dec	ch
	jne	loop_box_fill_packed_hor
	mov	ax,ds: word ptr [command_box_x_start]
	mov	ds: word ptr [si].VBOX.X_START,ax
	add	ax,ds: word ptr [command_box_x_len]
	dec	ax
	mov	ds: word ptr [si].VBOX.X_END,ax
	mov	ax,ds: word ptr [command_box_y_len]
	add	ds: word ptr [si].VBOX.Y_START,ax
	add	ds: word ptr [si].VBOX.Y_END,ax
	dec	cl
	jne	loop_box_fill_packed_ver
	mov	ds: byte ptr [foreground_vesa_color],0Fh
	jmp	enter_for_command_5
go_command_5_box_direct_color:
	shl	ds: word ptr [command_box_y_len],4h
	shl	ds: word ptr [command_box_x_len],4h
	push	bx
	mov	di,OFFSET iff_buffer
	mov	ax,0FFh
	xor	edx,edx
	movzx	ecx,ds: word ptr [command_box_x_len]
	dec	cx
	div	cx
	mov	ds: byte ptr [quotient],al
	xor	eax,eax
	div	ecx
	mov	ds: dword ptr [extra_div],eax
	shr	eax,1h
	xchg	eax,esi
	inc	cx
	mov	bp,cx
	xor	dx,dx
loop_calc_elem:
	mov	cl,8h
	sub	cl,ds: byte ptr [dc_red_size]
	movzx	eax,dl
	shr	al,cl
	mov	cl,ds: byte ptr [dc_red_pos]
	shl	eax,cl
	mov	cl,8h
	sub	cl,ds: byte ptr [dc_blue_size]
	movzx	ebx,dl
	not	bl
	shr	bl,cl
	mov	cl,ds: byte ptr [dc_blue_pos]
	shl	ebx,cl
	or	eax,ebx
	stosd
	add	dl,ds: byte ptr [quotient]
	add	esi,ds: dword ptr [extra_div]
	adc	dl,dh
	dec	bp
	jne	loop_calc_elem
	mov	ax,0FFh
	xor	edx,edx
	movzx	ecx,ds: word ptr [command_box_y_len]
	dec	cx
	div	cx
	mov	ds: byte ptr [quotient],al
	xor	eax,eax
	div	ecx
	mov	ds: dword ptr [extra_div],eax
	shr	eax,1h
	mov	ds: dword ptr [rstss],eax
	mov	ds: byte ptr [current_green_val],0h
	test	ds: byte ptr [status_flag_2],VESA_MEMORY_MODE
	jne	vesa_command_5_linear
	mov	es,ds: word ptr [banked_segment]
	mov	ax,ds: word ptr [command_box_y_start]
	mul	ds: word ptr [current_bpsl]
	mov	cx,ds: word ptr [command_box_x_start]
	mov	bp,ds: word ptr [current_bpl]
	imul	cx,bp
	add	ax,cx
	adc	dx,0h
	push	dx
	push	ax
	pop	eax
	xor	edx,edx
	div	ds: dword ptr [segment_bound]
	movzx	edi,dx
	xchg	ax,dx
	call	ds: word ptr [set_bank_default]
	movzx	ebx,ds: word ptr [current_bpsl]
	movzx	eax,ds: word ptr [current_bpl]
	imul	ax,ds: word ptr [command_box_x_len]
	sub	bx,ax
	mov	dh,ds: byte ptr [current_bpl]
	sub	ax,ds: word ptr [segment_bound]
	neg	ax
	mov	ds: word ptr [max_di_bank],ax
loop_ver_grad:
	mov	cl,8h
	sub	cl,ds: byte ptr [dc_green_size]
	movzx	ebp,ds: byte ptr [current_green_val]
	shr	bp,cl
	mov	cl,ds: byte ptr [dc_green_pos]
	shl	ebp,cl
	mov	si,OFFSET iff_buffer
	mov	cx,ds: word ptr [command_box_x_len]
	push	bx
	mov	bx,ds: word ptr [segment_bound]
	cmp	di,ds: word ptr [max_di_bank]
	jae	loop_hor_grad
	cmp	dh,2h
	jne	test_gradient_24
loop_fast_gradient_16:
	lodsd
	or	ax,bp
	stosw
	dec	cx
	jne	loop_fast_gradient_16
	jmp	exit_gradient_fast
test_gradient_24:
	cmp	dh,3h
	jne	loop_fast_gradient_32
	dec	cx
loop_fast_gradient_24:
	lodsd
	or	eax,ebp
	stosd
	dec	di
	dec	cx
	jne	loop_fast_gradient_24
	lodsd
	or	eax,ebp
	stosw
	shr	eax,10h
	stosb
	jmp	exit_gradient_fast
loop_fast_gradient_32:
	lodsd
	or	eax,ebp
	stosd
	dec	cx
	jne	loop_fast_gradient_32
	jmp	exit_gradient_fast
loop_hor_grad:
	lodsd
	or	eax,ebp
	mov	dl,dh
loop_grad_point:
	stosb
	cmp	di,bx
	jne	no_grad_point_bank
	push	dx
	mov	dx,ds: word ptr [current_bank]
	inc	dx
	call	ds: word ptr [set_bank_default]
	pop	dx
no_grad_point_bank:
	shr	eax,8h
	dec	dl
	jne	loop_grad_point
	dec	cx
	jne	loop_hor_grad
exit_gradient_fast:
	pop	bx
	add	edi,ebx
	cmp	edi,ds: dword ptr [segment_bound]
	jb	no_inc_bank_dc_5
	push	dx
	mov	dx,ds: word ptr [current_bank]
	inc	dx
	call	ds: word ptr [set_bank_default]
	sub	edi,ds: dword ptr [segment_bound]
	pop	dx
no_inc_bank_dc_5:
	mov	al,ds: byte ptr [quotient]
	add	ds: byte ptr [current_green_val],al
	mov	eax,ds: dword ptr [extra_div]
	add	ds: dword ptr [rstss],eax
	adc	ds: byte ptr [current_green_val],0h
	dec	ds: word ptr [command_box_y_len]
	jne	loop_ver_grad
	pop	bx
	jmp	enter_for_command_5_1
vesa_command_5_linear:
	xor	ax,ax
	mov	es,ax
	movzx	edx,ds: word ptr [command_box_y_start]
	movzx	edi,ds: word ptr [current_bpsl]
	imul	edi,edx
	movzx	ecx,ds: word ptr [command_box_x_start]
	movzx	ebp,ds: byte ptr [current_bpl]
	imul	ecx,ebp
	add	edi,ecx
	add	edi,ds: dword ptr [current_linear_vram_address]
	mov	dh,ds: byte ptr [current_bpl]
loop_ver_dcl:
	mov	cl,8h
	sub	cl,ds: byte ptr [dc_green_size]
	movzx	ebp,ds: byte ptr [current_green_val]
	shr	bp,cl
	mov	cl,ds: byte ptr [dc_green_pos]
	shl	ebp,cl
	mov	si,OFFSET iff_buffer
	mov	cx,ds: word ptr [command_box_x_len]
	cmp	dh,2h
	jne	test_gradient_24_linear
loop_fast_gradient_16_linear:
	lodsd
	or	ax,bp
	stos	es: word ptr [edi]
	dec	cx
	jne	loop_fast_gradient_16_linear
	jmp	exit_gradient_fast_linear
test_gradient_24_linear:
	cmp	dh,3h
	jne	loop_fast_gradient_32_linear
	dec	cx
loop_fast_gradient_24_linear:
	lodsd
	or	eax,ebp
	stos	es: dword ptr [edi]
	dec	edi
	dec	cx
	jne	loop_fast_gradient_24_linear
	lodsd
	or	eax,ebp
	stos	es: word ptr [edi]
	shr	eax,10h
	stos	es: byte ptr [edi]
	jmp	exit_gradient_fast_linear
loop_fast_gradient_32_linear:
	lodsd
	or	eax,ebp
	stos	es: dword ptr [edi]
	dec	cx
	jne	loop_fast_gradient_32_linear
exit_gradient_fast_linear:
	mov	ax,ds: word ptr [current_bpsl]
	mov	bx,ds: word ptr [command_box_x_len]
	imul	bx,ds: word ptr [current_bpl]
	sub	ax,bx
	movzx	eax,ax
	add	edi,eax
	mov	al,ds: byte ptr [quotient]
	add	ds: byte ptr [current_green_val],al
	mov	eax,ds: dword ptr [extra_div]
	add	ds: dword ptr [rstss],eax
	adc	ds: byte ptr [current_green_val],0h
	dec	ds: word ptr [command_box_y_len]
	jne	loop_ver_dcl
	pop	bx
enter_for_command_5_1:
	mov	si,OFFSET vesa_box
	mov	ax,ds: word ptr [command_box_x_len]
	sub	ax,128d
	shr	ax,1h
	add	ax,ds: word ptr [command_box_x_start]
	mov	ds: word ptr [si].VBOX.X_START,ax
	add	ax,127d
	mov	ds: word ptr [si].VBOX.X_END,ax
	mov	ax,ds: word ptr [command_box_y_end]
	sub	ax,ds: word ptr [command_box_y_start]
	inc	ax
	sub	ax,110d
	shr	ax,1h
	add	ax,ds: word ptr [command_box_y_start]
	mov	ds: word ptr [si].VBOX.Y_START,ax
	add	ax,25d
	mov	ds: word ptr [si].VBOX.Y_END,ax
	xor	di,di
loop_box_black:
	mov	ds: dword ptr [vesa_direct_color],0h
	call	Set_Vesa_Color
	call	Write_Graphic_Box_Fill
	call	Set_VESA_Default_Color
	add	ds: word ptr [si].VBOX.X_START,1h
	add	ds: word ptr [si].VBOX.Y_START,1h
	sub	ds: word ptr [si].VBOX.X_END,1d
	sub	ds: word ptr [si].VBOX.Y_END,1d
	call	Write_Graphic_Box
	sub	ds: word ptr [si].VBOX.X_START,1h
	sub	ds: word ptr [si].VBOX.Y_START,1h
	add	ds: word ptr [si].VBOX.X_END,1d
	add	ds: word ptr [si].VBOX.Y_END,1d
	mov	ds: dword ptr [vesa_direct_color],0h
	mov	si,OFFSET vesa_line
	mov	ax,ds: word ptr [vesa_box].VBOX.X_START
	add	ax,3h
	mov	ds: word ptr [si].LINE.X_POS,ax
	mov	ax,ds: word ptr [vesa_box].VBOX.Y_START
	add	ax,3h
	mov	ds: word ptr [si].LINE.Y_POS,ax
	mov	ds: word ptr [si].LINE.LEN,20d
	mov	ah,10h
	mov	al,0Fh
	mov	dx,ds: word ptr [si].LINE.X_POS
	xor	bp,bp
loop_spread_color:
	mov	ds: byte ptr [di + vesa_direct_color],al
	call	Set_VESA_Color
	mov	cx,dx
	add	cx,bp
	mov	ds: word ptr [si].LINE.X_POS,cx
	call	Write_Vertical_Line
	mov	cx,dx
	add	cx,122d
	sub	cx,bp
	mov	ds: word ptr [si].LINE.X_POS,cx
	call	Write_Vertical_Line
	inc	bp
	add	al,10h
	dec	ah
	jne	loop_spread_color
	mov	si,OFFSET vesa_box
	add	ds: word ptr [si].VBOX.X_START,19d
	add	ds: word ptr [si].VBOX.Y_START,3d
	sub	ds: word ptr [si].VBOX.X_END,18d
	sub	ds: word ptr [si].VBOX.Y_END,3d
	call	Write_Graphic_Box_Fill
	sub	ds: word ptr [si].VBOX.X_START,19d
	sub	ds: word ptr [si].VBOX.Y_START,3d
	add	ds: word ptr [si].VBOX.X_END,18d
	add	ds: word ptr [si].VBOX.Y_END,3d
	mov	si,OFFSET vga_message_253
	mov	cx,di
loop_get_string_color:
	or	cx,cx
	je	found_string_color
	call	Str_Len_Mem
	dec	cx
	jmp	loop_get_string_color
found_string_color:
	call	Str_Len
	shl	ax,3h
	sub	ax,128d
	neg	ax
	shr	ax,1h
	add	ax,ds: word ptr [vesa_box].VBOX.X_START
	xchg	ax,cx
	mov	dx,ds: word ptr [vesa_box].VBOX.Y_START
	add	dx,9d
	mov	ds: dword ptr [vesa_direct_color],0h
	call	Set_Vesa_Color
	call	Write_VESA_String
	dec	cx
	dec	dx
	call	Set_VESA_Default_Color
	call	Write_VESA_String
	mov	si,OFFSET vesa_box
	add	ds: word ptr [si].VBOX.Y_START,42d
	add	ds: word ptr [si].VBOX.Y_END,42d
	inc	di
	cmp	di,3h
	jne	loop_box_black
	call	Set_VESA_Default_Color
enter_for_command_5:
	mov	si,OFFSET vesa_box
	mov	ax,ds: word ptr [command_box_x_start]
	sub	ax,2h
	mov	ds: word ptr [si].VBOX.X_START,ax
	mov	ax,ds: word ptr [command_box_x_end]
	add	ax,2h
	mov	ds: word ptr [si].VBOX.X_END,ax
	mov	ax,ds: word ptr [command_box_y_start]
	sub	ax,2h
	mov	ds: word ptr [si].VBOX.Y_START,ax
	mov	ax,ds: word ptr [command_box_y_end]
	add	ax,2h
	mov	ds: word ptr [si].VBOX.Y_END,ax
	call	Write_Graphic_Box
	add	ax,0Ah
	xchg	ax,dx
	call	Set_Virtual_String
	xor	cx,cx
	mov	si,OFFSET vga_message_228
	call	Write_Simple_VGA_Message
	inc	ch
	call	VESA_Command_02_01
	call	Center_VESA_String
	add	dx,12h
	call	Set_Virtual_String
	xor	cx,cx
	mov	si,OFFSET vga_message_245
	call	Write_VGA_Message
	call	Center_VESA_String
exit_vesa_command_05:
	push	ds
	pop	es
no_exit_command_5:
	call	Get_Key
	cmp	ax,F2_KEY
	je	no_exit_command_5
	call	Init_X_Vesa
	popa
	ret

;#############################################################################

	Center_VESA_String:

;#############################################################################

	call	Get_Virtual_String
	mov	si,OFFSET buffer_vesa_string
	call	Str_Len
	mov	cx,ds: word ptr [bx].VESA_MODE_PANEL.X_RES
	cmp	ds: byte ptr [bx].VESA_MODE_PANEL.VIDEO_MODE_MODEL,VESA_MODE_TEXT
	je	center_text
	shl	ax,3h
center_text:
	sub	cx,ax
	shr	cx,1h
	call	Write_VESA_String
	ret
	