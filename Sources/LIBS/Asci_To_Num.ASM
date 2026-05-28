;#############################################################################

;	DS:SI = Asci num pointer

	Asci_To_Num:

;	CARRY = 0
;		EAX = Value
;	CARRY = 1 -> Invalid string

;#############################################################################

	pusha
	call	Str_Len
	or	ax,ax
	je	invalid_value
	add	si,ax
	dec	si
	xchg	ax,cx
	xor	eax,eax
	mov	ebx,1h
loop_asci:
	movzx	edx,ds: byte ptr [si]
	sub	dl,'0'
	cmp	dl,9h
	jbe	valid_value
invalid_value:
	stc
	popa
	ret
valid_value:
	imul	edx,ebx
	add	eax,edx
	imul	ebx,0Ah
	dec	si
	loop	loop_asci
	cmp	ds: byte ptr [si + 1h],'0'
	jne	valid_exit_value
	cmp	ds: byte ptr [si + 2h],0h
	jne	invalid_value
valid_exit_value:
	call	Exit_Return_AX
	clc
	popa
	ret
