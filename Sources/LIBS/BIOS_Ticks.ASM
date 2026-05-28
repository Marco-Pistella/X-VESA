;#############################################################################

	Save_Timer_Ticks:

;#############################################################################

	push	eax
	call	Get_BIOS_Ticks
	mov	ds: dword ptr [timer_ticks],eax
	pop	eax
	ret

;#############################################################################

	Get_BIOS_Ticks:

;#############################################################################

	push	ds
	push	BIOS_SAVE_AREA_SEGMENT
	pop	ds
	mov	eax,ds: dword ptr [OFFSET_TIMER]
	pop	ds
	ret
