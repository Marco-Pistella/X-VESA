;#############################################################################

;	DS:BX = Head windows pointer
;	DS:DI = Bottom key window pointer
;	DS:SI = View message pointer
;	FS = Video segment

	Show_Message:

;#############################################################################


	pusha
	call	Str_Len
	mov	ah,al
	add	ah,6h
	mov	al,5h
	call	Center_Box_Dynamic
	xchg	bx,si
	call	Extended_Box
	xchg	bx,si
	add	cx,302h
	call	Write_VGA_Message
	popa
	ret
