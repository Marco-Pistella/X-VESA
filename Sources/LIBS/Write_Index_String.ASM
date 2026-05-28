;#############################################################################

;	DS:SI = String pointer
;	AL = NN view string
;	CH = X coordinate
;	CL = Y coordinate
;	FS = Video Segment

	Write_Index_String:

;	CL = Y coordinate + 1h

;#############################################################################

	pusha
	mov	bl,al
	mov	bh,al
	or	al,al
	je	exit_index_string
loop_index_string:
	call	Str_Len_Mem
	cmp	ds: byte ptr [si],WRITE_RESERVED_ID
	jne	normal_index
	mov	al,bh
	call	Write_Reserved
	jmp	exit_no_write_index
normal_index:
	dec	bl
	jne	loop_index_string
exit_index_string:
	call	Write_VGA_Message
exit_no_write_index:
	mov	bp,sp
	inc	ss: byte ptr [bp + OFFSET_CX_STACK]
	inc	ds: byte ptr [start_xy]
	popa
	ret
