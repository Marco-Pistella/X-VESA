;#############################################################################

;	AX = Elemento da visualizzare

	Write_Panel_06:

;#############################################################################

	pusha
	mov	si,ax
	shl	si,2h
	mov	ch,((TEXT_WIDTH - VRES_PANEL_WIDHT) SHR 1h) + 7d
	inc	ax
	call	Write_Dec_Num16
	add	ch,9h
	mov	ax,ss: word ptr [si]
	call	Write_Dec_Num_Left16
	mov	al,'x'
	call	Write_Char
	mov	ax,ss: word ptr [si + 2h]
	call	Write_Dec_Num_Left16
	popa
	ret
