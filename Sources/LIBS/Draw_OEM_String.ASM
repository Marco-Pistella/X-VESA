;#############################################################################

;	BX = String Pointer
;       CH = X Coordinate
;	CL = Y Coordinate
;	DL = Max string lenght

	Draw_OEM_String:

;#############################################################################

	pusha
	cmp	ds: dword ptr [bx],ZERO
	jne	ok_oem_string
	mov	si,OFFSET vga_message_085
	call	Write_VGA_Message
	popa
	ret
ok_oem_string:
	les	si,ds: dword ptr [bx]
	xor	dh,dh
	call	Locate
	mov	ah,ds: byte ptr [color_base_mem]
loop_oem_string_0:
	lods	es: byte ptr [si]
	or	al,al
	je	exit_oem_string
	mov	fs: word ptr [di],ax
	inc	di
	inc	di
	inc	dh
	cmp	dh,dl
	jne	loop_oem_string_0
exit_oem_string:
	push	ds
	pop	es
	popa
	ret
