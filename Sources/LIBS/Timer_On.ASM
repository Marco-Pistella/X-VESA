;#############################################################################

	Timer_On:

;#############################################################################

	push	eax
	push	ds
	xor	ax,ax
	mov	ds,ax
	cli
	mov	al,34h
	out     43h,al
	xor	al,al
	out	40h,al
	call	Delay_Timer
	out	40h,al
	mov	eax,ds: dword ptr [46Ch]
	sti
	pop	ds
	mov	ds: dword ptr [timer_start],eax
	pop	eax
	ret
