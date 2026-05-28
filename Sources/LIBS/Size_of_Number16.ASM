;#############################################################################

;	AX = Number to count

	Size_Of_Number16:

;	DS: byte [number_count] = Count

;#############################################################################

	push	eax
	movzx	eax,ax
	call	Size_Of_Number32
	pop	eax
	ret

