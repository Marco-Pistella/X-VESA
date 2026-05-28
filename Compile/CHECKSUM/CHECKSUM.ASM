	.386
	SEGMENT CODE USE16
	ASSUME	CS:CODE,DS:CODE
	MAX_LEN	EQU	0FF00h
	ORG	100h
	SAVID	PROC

	mov	ax,3D02h
	mov	dx,OFFSET file_name
	int	21h
	jb	errore
	xchg	ax,bx
	mov	ax,cs
	add	ax,1000h
	mov	ds,ax
	mov	ah,3Fh
	mov	cx,MAX_LEN
	xor	dx,dx
	int	21h
	jb	errore
	xchg	ax,cx
	xor	si,si
	call	Get_Checksum
	mov	si,cx
	mov	ds: dword ptr [si],eax
	mov	ah,40h
	mov	cx,4h
	mov	dx,si
	int	21h
	jb	errore
	mov	ah,3Eh
	int	21h
	jb	errore
	int	20h
errore:
	push	cs
	pop	ds
	mov	dx,OFFSET stringa_errore
	mov	ah,9h
	int	21h
	int	20h

;#############################################################################

;	DS:SI = Puntatore al blocco dati
;	CX = Dimensioni blocco dati

	Get_Checksum:

;	EAX = Checksum

;#############################################################################

	push	edx
	push	cx
	push	si
	mov	eax,ds: dword ptr [si+4h]
	mov	edx,ds: dword ptr [si]
loop_crc:
	lodsb
	mul	dx
	not	eax
	xor	al,ds: byte ptr [si-1h]
	sub	edx,eax
	xor	eax,edx
	mul	edx
	loop	loop_crc
	rol	eax,11h
	pop	si
	pop	cx
	pop	edx
	ret

file_name:
	DB	'X-VESA.COM',0h
stringa_errore:
	DB	'Errore in fase di modifica',0Dh,0Ah,'$'

	SAVID	ENDP
	CODE	ENDS
	END	SAVID
