;#############################################################################

;	DS: BYTE [n_saved_video_page] = Current saving page
;	FS = Video segment

	Restore_Current_Video_Page:

;	DS: BYTE [n_saved_video_page] = Decrement page

;#############################################################################

	push	es
	push	ds
	pusha
	push	fs
	pop	es
	mov	cx,TEXT_WIDTH * TEXT_HEIGHT
	xor	di,di
	dec	ds: byte ptr [n_saved_video_page]
	movzx	si,ds: byte ptr  [n_saved_video_page]
	imul	si,2 * TEXT_WIDTH * TEXT_HEIGHT
	mov	ax,ds
	add	ax,SEGMENT_2
	mov	ds,ax
	rep	movs	es: word ptr [di],ds: word ptr [si]
	popa
	pop	ds
	pop	es
	ret

