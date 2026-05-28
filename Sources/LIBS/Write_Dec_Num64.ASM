;#############################################################################

;	CH = X Coordinate
;	CL = Y Coordinate
;	EAX:EDX = Write number
;	FS = Video Segment

	Write_Dec_Num64:

;#############################################################################

	pushad
	call	Locate
	mov	cl,THOUSANDS_LEN
	mov	ebx,TEN
next_dec_long:
	push	eax
	mov	eax,edx
	xor	edx,edx
	div	ebx
	mov	ebp,eax
	pop	eax
	div	ebx
	add	dl,'0'
	mov	dh,ds: byte ptr [color_base_mem]
	mov	fs: word ptr [di],dx
	mov	edx,ebp
	dec	di
	dec	di
	or	edx,edx
	jne	check_point_mode3
	or	eax,eax
	je      no_delete_point_long
check_point_mode3:
	dec	cl
	jne     next_dec_long
	mov	cl,ds: byte ptr [thousands_sign]
	mov	ch,ds: byte ptr [color_base_mem]
	test	ds: byte ptr [status_flag_0],FLAG_THOUSANDS
	jne	no_extra_point
	mov	fs: word ptr [di],cx
	dec	di
	dec	di
no_extra_point:
	mov	cl,THOUSANDS_LEN
	jmp	next_dec_long
no_delete_point_long:
	popad
	ret
