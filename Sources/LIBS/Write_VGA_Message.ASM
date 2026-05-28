;#############################################################################

;	CH = X coordinate
;	CL = Y coordinate
;	DS:SI = String pointer
;	FS = Video Segment

;	COMMANDS

;	0F0h = Next line with left alignment
;	0F1h = Skip nn chars
;	0F2h = Next line with right alignment
;	0F3h = nn times mm char
;	0F4h = Write nn chars with m color
;	0F5h = Write string if nn = ds: byte ptr [string_id]
;	0F6h = Write string at nn OFFSET

	Write_VGA_Message:

;#############################################################################

	pusha
	mov	ah,ds: byte ptr [color_base_mem]
	xor	dx,dx
	call	Locate
	mov	bp,di
loop_write_string:
	lodsb
	cmp	al,F6_COMMAND
	jne	test_f5_command
	call	Unlocate
	push	si
	mov	si,ds: word ptr [si]
	call	Write_Simple_VGA_Message
	call	Locate
	pop	si
	add	si,2h	
	jmp	loop_write_simple_string
test_f5_command:
	cmp	al,F5_COMMAND
	jne	test_f4_command
	lodsb
	cmp	al,ds: byte ptr [string_id]
	je	loop_write_string
	call	Str_Len_Mem
	cmp	ds: byte ptr [si - 1h],0h
	je	exit_write_string
	jmp	loop_write_string
test_f4_command:
	cmp	al,F4_COMMAND
	jne	test_f3_command
	lodsb
	mov	dh,al
	lodsb
	mov	dl,al
	xchg	ah,dl
	jmp	loop_write_string
test_f3_command:
	cmp	al,F3_COMMAND
	jne	test_f2_command
	lodsb
	mov	bl,al
	lodsb
	or	bl,bl
	je	loop_write_string
loop_f3_command:
	mov	fs: word ptr [di],ax
	inc	di
	inc	di
	dec	bl
	jne	loop_f3_command
	jmp	loop_write_string
test_f2_command:
	cmp	al,F2_COMMAND
	jne	test_f1_command
enter_f2_f5:
	cmp	ds: byte ptr [si],F5_COMMAND
	jne	normal_string_f2
	inc	si
	lodsb
	cmp	al,ds: byte ptr [string_id]
	je	normal_string_f2
	call	Str_Len_Mem
	cmp	ds: byte ptr [si - 1h],0h
	je	exit_write_string
	jmp	enter_f2_f5
normal_string_f2:
	add	di,2h * TEXT_WIDTH
	push	ax
	call	Str_Len
	add	ax,ax
	sub	di,ax
	pop	ax
	mov	bp,di
	jmp	loop_write_string
test_f1_command:
	cmp	al,F1_COMMAND
	jne	test_f0_command
	lodsb
	movzx	bx,al
	add	di,bx
	add	di,bx
	jmp	loop_write_string
test_f0_command:
	cmp	al,F0_COMMAND
	jne	test_char
	mov	di,bp
	add	di,2 * TEXT_WIDTH
	mov	bp,di
	jmp	loop_write_string
test_char:
	or	al,al
	je	exit_write_string
	mov	fs: word ptr [di],ax
	add	di,2h
	or	dh,dh
	je	loop_write_string
	dec	dh
	jne	loop_write_string
	xchg	ah,dl
	jmp	loop_write_string
exit_write_string:
	popa
	ret
