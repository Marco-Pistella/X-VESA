;#############################################################################

;	AX = Video mode
;	DS:BX = Offset vesa_mode_info struct

	Check_VESA_Mode:

;	CARRY(0) = Valid VESA video mode
;	CARRY(1) = Invalid VESA video mode

;#############################################################################

	pusha
	mov	ds: word ptr [bx].VESA_MODE_PANEL.VIDEO_MODE,ax
	push	ax
	push	bx
	xchg	ax,cx
	mov	ax,(VESA_ID SHL 8h) + VESA_FUNC_RETURN_MODE_INFORMATION
	mov	di,OFFSET vesa_buffer_func_1
	VIDEO_CALL
	pop	bx
	cmp	ax,VESA_ID
	pop	ax
	je	valid_vesa_mode
error_check_mode:
	stc
	popa
	ret
valid_vesa_mode:
	test	ds: byte ptr [di].ModeInfoBlock.ModeAttributes,VESA_EXTENDED_INFO
	jne	extended_video_mode
	mov	si,OFFSET vesa_mode_table
	mov	cx,(OFFSET end_vesa_mode_table - OFFSET vesa_mode_table) / SIZEOF VESA_MODE_1X
loop_valid_vesa_mode:
	cmp	ax,ds: word ptr [si].VESA_MODE_1X.VIDEO_MODE
	je	ok_vesa_limited_mode
	add	si, SIZEOF VESA_MODE_1X
	loop	loop_valid_vesa_mode
	jmp     error_check_mode
ok_vesa_limited_mode:
	push	ds: dword ptr [si].VESA_MODE_1X.X_RES
	pop	ds: dword ptr [bx].VESA_MODE_PANEL.X_RES
	mov	al,ds: byte ptr [si].VESA_MODE_1X.MODEL
	mov	ds: byte ptr [bx].VESA_MODE_PANEL.VIDEO_MODE_MODEL,al
	mov	al,ds: byte ptr [si].VESA_MODE_1X.BPP
	jmp	normal_bpp
extended_video_mode:
	mov	al,ds: byte ptr [di].ModeInfoBlock.MemoryModel
	mov	ds: byte ptr [bx].VESA_MODE_PANEL.VIDEO_MODE_MODEL,al
	push	ds: dword ptr [di].ModeInfoBlock.XResolution
	pop	ds: dword ptr [bx].VESA_MODE_PANEL.X_RES
	mov	al,ds: byte ptr [di].ModeInfoBlock.BitsPerPixel
	cmp	al,VESA_VIDEO_MODE_8BPP
	jbe	normal_bpp
	cmp	ds: byte ptr [di].ModeInfoBlock.MemoryModel,VESA_MODE_PACKET
	jne	vesa_12_ok
	mov	ds: byte ptr [bx].VESA_MODE_PANEL.VIDEO_MODE_MODEL,VESA_MODE_DIRECT_COLOR
	mov	ah,VESA_VIDEO_MODE_16BPP
	cmp	al,VESA_VIDEO_MODE_15BPP
	je	set_vesa1_direct_color	
	mov	ah,al
	jmp	set_vesa1_direct_color
vesa_12_ok:
	mov	al,ds: byte ptr [di].ModeInfoBlock.RedMaskSize
	add	al,ds: byte ptr [di].ModeInfoBlock.GreenMaskSize
	add	al,ds: byte ptr [di].ModeInfoBlock.BlueMaskSize
	mov	ah,VESA_VIDEO_MODE_16BPP
	cmp	al,VESA_VIDEO_MODE_15BPP
	je	set_vesa1_direct_color
	mov	ah,al
	cmp	al,VESA_VIDEO_MODE_24BPP
	jne	set_vesa1_direct_color
	cmp	ds: byte ptr [di].ModeInfoBlock.RsvdMaskSize,0h
	jne	use_reserved_mask
	cmp	ds: byte ptr [di].ModeInfoBlock.BitsPerPixel,VESA_VIDEO_MODE_24BPP
	je	set_vesa1_direct_color
	mov	ah,VESA_VIDEO_MODE_32BPP
	jmp	set_vesa1_direct_color
use_reserved_mask:
	add	ah,ds: byte ptr [di].ModeInfoBlock.RsvdMaskSize
set_vesa1_direct_color:
	add	ah,7h
	and	ah,0F8h
	mov	ds: byte ptr [bx].VESA_MODE_PANEL.MEMORY_BPP,ah
normal_bpp:
	mov	ds: byte ptr [bx].VESA_MODE_PANEL.COLOR_BPP,al
	cmp	al,VESA_VIDEO_MODE_4BPP
	jne	no_set_packet_mode
	mov	bp,ds: word ptr [di].ModeInfoBlock.BytesPerScanLine
	add	bp,bp
	cmp	bp,ds: word ptr [bx].VESA_MODE_PANEL.X_RES
	jne	no_set_packet_mode
	mov	ds: byte ptr [bx].VESA_MODE_PANEL.VIDEO_MODE_MODEL,VESA_MODE_PACKET
no_set_packet_mode:
	cmp	al,VESA_VIDEO_MODE_8BPP
	ja	no_set_mbpp
	cmp	ds: byte ptr [bx].VESA_MODE_PANEL.VIDEO_MODE_MODEL,VESA_MODE_PLANAR
	jne	no_planar_case
	mov	al,1h
no_planar_case:
	mov	ds: byte ptr [bx].VESA_MODE_PANEL.MEMORY_BPP,al
no_set_mbpp:
	mov	bp,ds: word ptr [di].ModeInfoBlock.WinASegment
	test	ds: byte ptr [di].ModeInfoBlock.WinAAttributes,VESA_WINDOW_SUPPORTED
	jne     vesa_segment_ok
	cmp	ds: byte ptr [bx].VESA_MODE_PANEL.VIDEO_MODE_MODEL,VESA_MODE_TEXT
	jne	vesa_segment_B
	or	bp,bp
	jne	vesa_segment_ok
vesa_segment_B:
	mov	bp,ds: word ptr [di].ModeInfoBlock.WinBSegment
	test	ds: byte ptr [di].ModeInfoBlock.WinBAttributes,VESA_WINDOW_SUPPORTED
	jne	vesa_segment_ok
fail_bank_mode:
	cmp	ds: byte ptr [bx].VESA_MODE_PANEL.VIDEO_MODE_MODEL,VESA_MODE_TEXT
	je	vesa_segment_ok
	mov	ds: word ptr [bx].VESA_MODE_PANEL.VIDEO_SEGMENT,0h
	mov	ds: byte ptr [bx].VESA_MODE_PANEL.WINDOW_SIZE,0h
	mov	ds: byte ptr [bx].VESA_MODE_PANEL.WINDOW_GRANULARITY,0h
	jmp	write_flags
vesa_segment_ok:
	mov	ds: word ptr [bx].VESA_MODE_PANEL.VIDEO_SEGMENT,bp
	cmp	ds: byte ptr [bx].VESA_MODE_PANEL.VIDEO_MODE_MODEL,VESA_MODE_TEXT
	jne	check_win_size
	mov	ds: byte ptr [bx].VESA_MODE_PANEL.WINDOW_SIZE,32d
	mov	ds: byte ptr [bx].VESA_MODE_PANEL.WINDOW_GRANULARITY,32d
	jmp	write_flags
check_win_size:
	mov	ax,ds: word ptr [di].ModeInfoBlock.WinSize
	cmp	ax,VESA_MAX_WINDOW_SIZE
	ja	fail_bank_mode
	or	ax,ax
	je	fail_bank_mode
	mov	ds: byte ptr [bx].VESA_MODE_PANEL.WINDOW_SIZE,al
	mov	cx,ds: word ptr [di].ModeInfoBlock.WinGranularity
	or	cx,cx
	je	fail_bank_mode
check_granularity:
	cmp	ax,cx
	jb	fail_bank_mode
	mov	ds: byte ptr [bx].VESA_MODE_PANEL.WINDOW_GRANULARITY,cl
write_flags:
	mov	ds: dword ptr [bx].VESA_MODE_PANEL.VRAM_SIZE_BANKED,0FFFFFFFFh
	mov	ds: dword ptr [bx].VESA_MODE_PANEL.VRAM_SIZE_LINEAR,0FFFFFFFFh
	cmp	ds: byte ptr [bx].VESA_MODE_PANEL.VIDEO_MODE_MODEL,VESA_MODE_TEXT
	jne	no_set_vram_text
	mov	ds: dword ptr [bx].VESA_MODE_PANEL.VRAM_SIZE_BANKED,32d
no_set_vram_text:
	cmp	ds: byte ptr [bx].VESA_MODE_PANEL.VIDEO_MODE_MODEL,VESA_MODE_PLANAR
	jne	no_set_vram_planar
	mov	ds: dword ptr [bx].VESA_MODE_PANEL.VRAM_SIZE_BANKED,0h
no_set_vram_planar:
	cmp	ds: byte ptr [bx].VESA_MODE_PANEL.VIDEO_MODE_MODEL,VESA_MODE_PACKET
	je	set_vram_non_detected
	cmp	ds: byte ptr [bx].VESA_MODE_PANEL.VIDEO_MODE_MODEL,VESA_MODE_DIRECT_COLOR
	jne	no_set_vram_exo
set_vram_non_detected:
	mov	ds: dword ptr [bx].VESA_MODE_PANEL.VRAM_SIZE_BANKED,0h
	mov	ds: dword ptr [bx].VESA_MODE_PANEL.VRAM_SIZE_LINEAR,0h
no_set_vram_exo:
	clc
	popa
	ret
