;#############################################################################

	Write_Standard_Timing:

;#############################################################################

	pusha
	or	ax,ax
	je	next_mode_1
	cmp	ax,101h
	je 	next_mode_1
	or	al,al
	je	next_mode_1
	xor	ah,ah
	add	ax,1Fh
	shl	ax,3h
	call	Write_Dec_Num_Left16
	mov	si,OFFSET vga_message_071
	call	Write_Simple_VGA_Message
	movzx	si,ds: byte ptr [di - 1h]
	shr	si,6h
	add	si,si
	add	si,OFFSET table_ar
	movzx	dx,ds: byte ptr [si]
	imul	ax,dx
	xor	dx,dx
	movzx	si,ds: byte ptr [si + 1h]
	div	si
	call	Write_Dec_Num_Left16
	mov	si,OFFSET vga_message_072
	call	Write_Simple_VGA_Message
	mov	al,ds: byte ptr [di - 1h]
	and	al,3Fh
	add	al,60d
	call	Write_Dec_Num_Left8
	mov	si,OFFSET vga_message_073
	call	Write_VGA_Message
	clc
	popa
	ret
next_mode_1:
	stc
	popa
	ret
