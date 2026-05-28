;#############################################################################

	Get_VESA_PM:

;#############################################################################

	push	BIOS_ROM_VIDEO_SEGMENT
	pop	fs
	xor	si,si
	cmp	fs: word ptr [si],BIOS_INIT
	jne	next_pm_pointer
	add	si,2h
	movzx	ax,fs: byte ptr [si]
	mov	ds: byte ptr [vbios_size],al
	cmp	al,MAX_BIOS_LEN
	ja	next_pm_pointer
	shl	ax,BIOS_SIZE_SHIFT
	sub	ax,SIZEOF PMInfoBlock + 2
loop_bios_pmid:
	inc	si
	cmp	fs: dword ptr [si],VESA_MAGIC_3
	jne	next_byte_rom
	mov	ds: word ptr [segment_pmid],fs
	mov	ds: word ptr [offset_pmid],si
	mov	cx,SIZEOF PMInfoBlock
	xor	al,al
loop_pm_checksum:
	add	al,fs: byte ptr [si]
	inc	si
	loop	loop_pm_checksum
	or	al,al
	jne	next_pm_pointer
	or	ds: byte ptr [status_flag_1],FLAG_PMID
	jmp	next_pm_pointer	
next_byte_rom:	
	dec	ax
	jne	loop_bios_pmid	
next_pm_pointer:
	mov	ax,(VESA_ID SHL 8h) + VESA_FUNC_RETURN_PMI
	mov	bl,VESA_RETURN_PM_TABLE
	VIDEO_CALL
	cmp	ax,VESA_ID
	jne	exit_pm_pointer
	or	ds: byte ptr [status_flag_1],FLAG_PM0A
	mov	ds: word ptr [segment_pm0a],es
	mov	ds: word ptr [offset_pm0a],di
exit_pm_pointer:
	push	ds
	pop	es
	ret
