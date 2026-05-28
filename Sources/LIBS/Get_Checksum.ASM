;#############################################################################

;	DS:SI = Data buffer pointer
;	CX = Buffer length

	Get_Checksum:

;	EAX = Checksum

;#############################################################################

	push	edx
	push	cx
	push	si
	mov	eax,ds: dword ptr [si + SIZEOF DWORD]
	mov	edx,ds: dword ptr [si]
loop_crk:
	lodsb
	mul	dx
	not	eax
	xor	al,ds: byte ptr [si - SIZEOF BYTE]
	sub	edx,eax
	xor	eax,edx
	mul	edx
	loop	loop_crk
	rol	eax,CHECKSUM_ROL
	pop	si
	pop	cx
	pop	edx
	ret
