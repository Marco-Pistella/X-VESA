;#############################################################################

;	DS:[vesa_direct_color] = Color to set (red, green, blue)

;	Direct color mode

	Set_VESA_Color:

;#############################################################################

	pushad
	mov	di,OFFSET foreground_vesa_color
	test	ds: byte ptr [status_flag_4],VESA_COLOR_TYPE
	je	direct_color_set_vesa_color
	mov	di,OFFSET background_vesa_color
direct_color_set_vesa_color:
	mov	si,OFFSET vesa_direct_color
	xor	ebp,ebp
	mov	cl,8h
	sub	cl,ds: byte ptr [dc_red_size]
	movzx	eax,ds: byte ptr [si]
	shr	al,cl
	mov	cl,ds: byte ptr [dc_red_pos]
	shl	eax,cl
	or	ebp,eax
	mov	cl,8h
	sub	cl,ds: byte ptr [dc_green_size]
	movzx	eax,ds: byte ptr [si + 1h]
	shr	al,cl
	mov	cl,ds: byte ptr [dc_green_pos]
	shl	eax,cl
	or	ebp,eax
	mov	cl,8h
	sub	cl,ds: byte ptr [dc_blue_size]
	movzx	eax,ds: byte ptr [si + 2h]
	shr	al,cl
	mov	cl,ds: byte ptr [dc_blue_pos]
	shl	eax,cl
	or	ebp,eax
	mov	ds: dword ptr [di],ebp
	popad
	ret

;#############################################################################

;	DS:BX = Pointer to vesa_mode_info video mode

	Set_VESA_Default_Color:

;#############################################################################

	mov	ds: dword ptr [background_vesa_color],0h
	cmp	ds: byte ptr [bx].VESA_MODE_PANEL.VIDEO_MODE_MODEL,VESA_MODE_DIRECT_COLOR
	je	direct_mode_set_color_default
	mov	ds: byte ptr [text_vesa_color],0Fh
	mov	ds: byte ptr [foreground_vesa_color],0Fh
	ret
direct_mode_set_color_default:
	mov	ds: byte ptr [vesa_direct_color],0FFh
	mov	ds: byte ptr [vesa_direct_color + 1h],0FFh
	mov	ds: byte ptr [vesa_direct_color + 2h],0FFh
	call	Set_VESA_Color
	ret
