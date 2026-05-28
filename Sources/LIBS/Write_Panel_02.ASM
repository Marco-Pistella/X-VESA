;#############################################################################

;	AX = Elemento da visualizzare

	Write_Panel_02:

;#############################################################################

	pusha
	imul	di,ax,SIZEOF EDID
	add	di,OFFSET edid_data.EDID.EDIDData
	mov	ch,((TEXT_WIDTH - EDID_INVERT_LEN) SHR 1h) + 2
	mov	si,OFFSET vga_message_031
	call	Write_VGA_Message
	add	ch,0Ch
	mov	ax,ds: word ptr [di-4h]
	call	Write_Dec_Num8
	add	ch,6h
	mov	dx,ds: word ptr [di].EDID128.ManufacturerID
	call	Write_EDID_Manifacturer_ID
	mov	ax,ds: word ptr [di].EDID128.ProductID
	inc	ch
	call	Num_To_Str_Hex4
	popa
	ret
