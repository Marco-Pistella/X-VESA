;#############################################################################

;	AX = Elemento da visualizzare

	Write_Panel_04:

;#############################################################################

	pusha
	mov	ds: byte ptr [color_base_mem],EXTRA_COLOR
	mov	si,ax
	mov	ch,5h
	inc	ax
	call	Write_Dec_Num16
	imul	si,SIZEOF ERROR_VESA
	add	ch,7h
	mov	al,ss: byte ptr [si].ERROR_VESA.PASS
	call	Write_Dec_Num8
	add	ch,5h
	mov	eax,ss: dword ptr [si].ERROR_VESA.TICKS
	mov	edi,90112d
	mul	edi
	mov	edi,1640625d
	div	edi
	call	Write_Timer
	add	ch,8h
	mov	al,' '
	call	Write_Char
	add	ch,2h
	mov	eax,ss: dword ptr [si].ERROR_VESA.OFFSET_VRAM
	call	Num_To_Str_Hex8
	add	ch,3h
	mov	eax,ss: dword ptr [si].ERROR_VESA.WRITE_VALUE
	call	Num_To_Str_Hex8
	xchg	eax,edx
	add	ch,3h
	mov	eax,ss: dword ptr [si].ERROR_VESA.READ_VALUE
	call	Num_To_Str_Hex8
	add	ch,3h
	xor	eax,edx
	call	Num_To_Str_Hex8
	add	ch,3h
	mov	al,ss: byte ptr [si].ERROR_VESA.TEST_ID
	mov	si,OFFSET vga_message_241
	call	Write_Index_String
	mov	ds: byte ptr [color_base_mem],COLOR_BASE
	popa
	ret
