;#############################################################################

;	AL = DAC Palette Color Register

	Get_DAC_Palette:

;	DS:SI = RGB value read

;#############################################################################

	pusha
	test	gs: byte ptr [status_flag_5],DAC_VGA
	je	get_palette_vga_dac
	movzx	dx,al
	mov	cx,1h
	mov	bl,1h
	mov	ax,(VESA_ID SHL 8h) + VESA_FUNC_SET_PALETTE
	mov	di,OFFSET vesa_single_palette_color
	push	es
	push	gs
	pop	es
	VIDEO_CALL
	mov	al,es: byte ptr [di]
	mov	ds: byte ptr [si + 2h],al
	mov	al,es: byte ptr [di + 1h]
	mov	ds: byte ptr [si + 1h],al
	mov	al,es: byte ptr [di + 2h]
	mov	ds: byte ptr [si],al
	pop	es
	popa
	ret
get_palette_vga_dac:
	mov	dx,VGA_DAC_INDEX_READ
	out	dx,al
	mov	dx,VGA_DAC_DATA
	mov	ah,3h
loop_dac_rgb:	
	in	al,dx
	mov	ds: byte ptr [si],al
	inc	si
	dec	ah
	jne	loop_dac_rgb
	popa
	ret
