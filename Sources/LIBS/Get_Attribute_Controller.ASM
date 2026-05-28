;#############################################################################

;	AH = Register

	Get_Attribute_Controller:

;	AL = Read value

;#############################################################################

	push	dx
	call	Get_Input_Status_Register
	in	al,dx
	mov	al,ah
	mov	dx,VGA_ATTRIBUTE_PORT
	out	dx,al
	inc	dx
	in	al,dx
	push	ax
	call	Get_Input_Status_Register
	in	al,dx
	mov	dx,VGA_ATTRIBUTE_PORT
	mov	al,VGA_PAS_BIT
	out	dx,al
	pop	ax
	pop	dx
	ret
