;#############################################################################

	Timer_Off:

;#############################################################################

	push	eax
	cli
	xor	al,al
	out	43h,al
	in	al,40h
	call	Delay_Timer
	mov	ah,al
	in	al,40h
	xchg	al,ah
	push	ax
	push	ds
	xor	ax,ax
	mov	ds,ax
	mov	eax,ds: dword ptr [46Ch]
	sti
	pop	ds
	sub	eax,ds: dword ptr [timer_start]
	shl	eax,10h
	pop	ax
	neg	ax
	sub	eax,ds: dword ptr [timer_overhead]
	jnc	valid_timer
	xor	eax,eax
valid_timer:
	mov	ds: dword ptr [elapsed_time],eax
	pop	eax
	ret

;#############################################################################

	Delay_Timer:

;#############################################################################

	jmp	$+2h
	jmp	$+2h
	jmp	$+2h
	jmp	$+2h
	jmp	$+2h
	jmp	$+2h
	jmp	$+2h
	jmp	$+2h
	ret
