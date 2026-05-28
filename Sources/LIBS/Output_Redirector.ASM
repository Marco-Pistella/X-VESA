;#############################################################################

	Enter_Redirector:

;#############################################################################

	push	ax
	mov	ax,ds
	add	ax,(OFFSET buffer_vesa_string - OFFSET start_data) SHR 4h
	mov	fs,ax
	pop	ax
	ret

;#############################################################################

	Set_Virtual_String:

;#############################################################################

	push	di
	xor	di,di
loop_clear_vesa_string_buffer:
	mov	fs: word ptr [di],2020h
	add	di,SIZEOF WORD
	cmp	di,(TEXT_WIDTH + 10h) SHL 1h
	jne	loop_clear_vesa_string_buffer
	pop	di
	ret

;#############################################################################

	Get_Virtual_String:

;#############################################################################

	pusha
	mov	di,2h
	mov	si,1h
	xor	bx,bx
loop_end_vesa_string:
	mov	al,fs: byte ptr [di]
	mov	fs: byte ptr [si],al
	inc	si
	add	di,SIZEOF WORD
	cmp	al,' '
	je	no_end_string_redirector
	mov	bx,si
no_end_string_redirector:
	cmp	di,(TEXT_WIDTH + 10h) SHL 1h
	jne	loop_end_vesa_string
	mov	fs: byte ptr [bx],0h
	popa
	ret

;#############################################################################

	Exit_Redirector:

;#############################################################################

	push	VIDEO_SEGMENT
	pop	fs
	ret
