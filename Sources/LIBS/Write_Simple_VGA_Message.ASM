;#############################################################################

;	CH = X coordinate
;	CL = Y coordinate
;	DS:SI = String pointer
;	FS = Video Segment

;	COMMANDS

;	0F1h = Skip nn chars
;	0F3h = nn times mm char
;	0F4h = Write nn chars with m color
;	0F6h = Write simple string at nn OFFSET

	Write_Simple_VGA_Message:

;	CH = New X coordinate

;#############################################################################

	pusha
	mov	ah,ds: byte ptr [color_base_mem]
	xor	dx,dx
	call	Locate
loop_write_simple_string:
	lodsb
	cmp	al,F6_COMMAND
	jne	test_simple_f4_command
	call	Unlocate
	push	si
	mov	si,ds: word ptr [si]
	call	Write_Simple_VGA_Message
	call	Locate
	pop	si
	add	si,2h	
	jmp	loop_write_simple_string
test_simple_f4_command:
	cmp	al,F4_COMMAND
	jne	test_simple_f3_command
	lodsb
	mov	dh,al
	lodsb
	mov	dl,al
	xchg	ah,dl
	jmp	loop_write_simple_string
test_simple_f3_command:
	cmp	al,F3_COMMAND
	jne	test_simple_f1_command
	lodsb
	mov	bl,al
	lodsb
loop_simple_f3_command:
	mov	fs: word ptr [di],ax
	inc	di
	inc	di
	dec	bl
	jne	loop_simple_f3_command
	jmp	loop_write_simple_string
test_simple_f1_command:
	cmp	al,F1_COMMAND
	jne	test_simple_char
	lodsb
	movzx	bx,al
	add	di,bx
	add	di,bx
	jmp	loop_write_simple_string
test_simple_char:
	or	al,al
	je	exit_simple_write_string
	mov	fs: word ptr [di],ax
	add	di,2h
	or	dh,dh
	je	loop_write_simple_string
	dec	dh
	jne	loop_write_simple_string
	xchg	ah,dl
	jmp	loop_write_simple_string
exit_simple_write_string:
	call	Unlocate
	mov	bp,sp
	mov	ss: byte ptr [bp + OFFSET_CX_STACK + 1h],ch
	popa
	ret
