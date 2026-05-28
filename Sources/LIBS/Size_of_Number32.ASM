;#############################################################################

;	EAX = Number to count

	Size_Of_Number32:

;	DS: byte ptr [number_count] = Count

;#############################################################################

	pushad
	mov	bx,THOUSANDS_LEN SHL 8
	mov	ebp,TEN
loop_char_count:
	xor	edx,edx
	div	ebp
	inc	bx
	or	eax,eax
	je	fine_size_number
	dec	bh
	jne	loop_char_count
	mov	bh,THOUSANDS_LEN
	test	ds: byte ptr [status_flag_0],FLAG_THOUSANDS
	jne	loop_char_count
	inc	bx
	jmp	loop_char_count
fine_size_number:
	mov	ds: byte ptr [number_count],bl
	popad
	ret

