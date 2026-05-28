;#############################################################################

;	0040h:SI = Data pointer
;	AL = Write value

	Set_BIOS_Mem:

;#############################################################################

	push	ds
	push	BIOS_SAVE_AREA_SEGMENT
	pop	ds
	mov	ds: byte ptr [si],al
	pop	ds
	ret
