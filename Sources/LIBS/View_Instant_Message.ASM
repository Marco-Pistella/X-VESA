;#############################################################################

;	DS:SI = Instant message pointer
;	FS = Video segment

	View_Instant_Message:

;#############################################################################

	pusha
	xor	bx,bx
	xor	di,di
	call	Show_Message
	popa
	ret
