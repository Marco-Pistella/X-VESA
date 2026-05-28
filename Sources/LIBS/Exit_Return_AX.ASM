;#############################################################################

;	AX = Return value

	Exit_Return_AX:

;#############################################################################

	push	bp
	mov	bp,sp
	mov	ss: word ptr [bp + OFFSET_AX_STACK],ax
	pop	bp
	ret
