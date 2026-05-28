;#############################################################################

;	DS: BYTE [n_saved_video_page] = Current saving page
;	FS = Video segment

	Save_Current_Video_Page:

;	DS: BYTE [n_saved_video_page] = Increment page

;#############################################################################

	push	es
	pusha
	mov	ax,ds
	add	ax,SEGMENT_2
	mov	es,ax
	mov	cx,TEXT_WIDTH * TEXT_HEIGHT
	xor	si,si
	movzx	di,ds: byte ptr [n_saved_video_page]
	imul	di,2 * TEXT_WIDTH * TEXT_HEIGHT
	rep	movs	es: word ptr [di],fs: word ptr [si]
	inc	ds: byte ptr [n_saved_video_page]
	popa
	pop	es
	ret

