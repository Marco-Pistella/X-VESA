;#############################################################################

;	EDI = VRAM Address
;	ECX = Bytes to clear

	Clear_Graphic_VRAM:

;#############################################################################

	pusha
	test	ds: byte ptr [status_flag_2],VESA_MEMORY_MODE
	jne	clear_linear_vram
	mov	es,ds: word ptr [banked_segment]
	xchg	eax,edi
	xor	edx,edx
	div	ds: dword ptr [segment_bound]
	mov	di,dx
	xchg	ax,dx
	call	ds: word ptr [set_bank_default]
	cmp	ds: byte ptr [bx].VESA_MODE_PANEL.VIDEO_MODE_MODEL,VESA_MODE_PLANAR
	jne	clear_no_planar
	mov	ax,(VGA_MODE_REGISTER SHL 8h) + VGA_MODE_0
	call	Set_GCR
	mov	ax,20Fh
	call	Set_Sequencer
	shr	ecx,2h
clear_no_planar:
	mov	eax,ds: dword ptr [clear_value]
	mov	ebp,ecx
next_clear_bank:
	mov	ecx,ds: dword ptr [segment_bound]
	sub	ecx,edi
	cmp	ecx,ebp
	jbe	ok_clear_bank
	mov	ecx,ebp
ok_clear_bank:
	sub	ebp,ecx
	shr	ecx,2h
	rep	stosd
	or	ebp,ebp
	je	exit_clear_graphic
	inc	dx
	call	ds: word ptr [set_bank_default]
	jmp	next_clear_bank
clear_linear_vram:
	shr	ecx,2h
	xor	eax,eax
	mov	es,ax
	add	edi,ds: dword ptr [current_linear_vram_address]
	rep	stos es: dword ptr [edi]
exit_clear_graphic:
	push	ds
	pop	es
	popa
	ret
