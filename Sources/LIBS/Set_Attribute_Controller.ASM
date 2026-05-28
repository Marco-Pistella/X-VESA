;#############################################################################

;	AH = Register
;	AL = Write value

	Set_Attribute_Controller:

;#############################################################################

	push	dx
	push	ax
	call	Get_Input_Status_Register
	in	al,dx
	mov	al,ah
	mov	dx,VGA_ATTRIBUTE_PORT
	out	dx,al
	pop	ax
	out	dx,al
	call	Get_Input_Status_Register
	in	al,dx
	mov	dx,VGA_ATTRIBUTE_PORT
	mov	al,VGA_PAS_BIT
	out	dx,al
	pop	dx
	ret
