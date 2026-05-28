;#############################################################################

;	DS:SI = Source pointer
;	ES:DI = Destination pointer (ES=DS)
;	CX = Bytes to move

	Move_Mem:

;#############################################################################

	pusha
	cmp	di,si
	jb	go_cld
	std
	add	si,cx
	dec	si
	add	di,cx
	dec	di
	rep	movsb
	cld
	popa
	ret
go_cld:
	rep	movsb
	popa
	ret
