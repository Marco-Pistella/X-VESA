;#############################################################################

;	AL = Number to count

	Size_Of_Number8:

;	DS: byte [number_count] = Count

;#############################################################################

	push	ax
	movzx	ax,al
	call	Size_Of_Number16
	pop	ax
	ret

