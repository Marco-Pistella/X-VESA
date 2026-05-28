;#############################################################################

;	0040h:SI = BIOS Save area pointer

	Get_BIOS_Mem:

;	EAX = Read value

;#############################################################################

	push	ds
	push	BIOS_SAVE_AREA_SEGMENT
	pop	ds
	mov	eax,ds: dword ptr [si]
	pop	ds
	ret

