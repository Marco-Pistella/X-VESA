;#############################################################################

;	DS:SI = Pointer to string for descriptor not found
;	AH = Descriptor to found
;	AL = Descriptor items
;	CH = X coordinate
;	CL = Y coordinate
;	FS = Video Segment

	Search_Descriptor:

;	CARRY = 0 -> Found descriptor
;		DI = pointer to Descriptor
;	CARRY = 1 -> No descriptor found
;		CL = New Y coordinate

;#############################################################################

	mov	di,36h
loop_se_de:
	cmp	ds: word ptr [bx + di],0h
	jne	next_dsc
	cmp	ds: byte ptr [bx + di + 2h],0h
	jne	next_dsc
	cmp	ah,ds: byte ptr [bx + di + 3h]
	jne	next_dsc
	clc
	ret
next_dsc:
	add	di,18d
	cmp	di,7Eh
	jb	loop_se_de
	cmp	ax,0F700h
	jne	search_ok_exit
	call	edid_9_3
	jmp	no_cc_ds
search_ok_exit:
	push	ax
	push	di
loop_string_not_found:
	call	Locate
	cmp	fs: byte ptr [di - 4h],':'
	jne	no_not_found_string
	call	Write_VGA_Message
	dec	al
	je	exit_search_descriptor
no_not_found_string:
	inc	cx
	cmp	cl,TEXT_HEIGHT - 2h
	jne	loop_string_not_found
exit_search_descriptor:
	inc	cx
	pop	di
	pop	ax
no_cc_ds:
	stc
	ret
