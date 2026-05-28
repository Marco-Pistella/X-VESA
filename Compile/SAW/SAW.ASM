	.386
	SEGMENT CODE USE16
	ASSUME	CS:CODE,DS:CODE
	ORG	100h
	SAVID	PROC

start_code:
	mov	ax,3D00h
	mov	dx,OFFSET file_name
	int	21h
	jb	errore
	xchg	ax,bx
	mov	ax,4200h
	xor	cx,cx
	mov	dx,768d
	int	21h
	jc	errore
	mov	ax,cs
	add	ax,((OFFSET end_code - OFFSET start_code) + 10Fh) SHR 4h
	mov	ds,ax
	mov	es,ax
	add	ax,1000h
	mov	ss,ax
	mov	cx,5h
	xor	dx,dx
	mov	ah,3Fh
	int	21h
	jc	errore
	mov	cx,ds: word ptr [3h]
	shl	cx,4h
	sub	cx,5h
	mov	dx,5h
	mov	ah,3Fh
	int	21h
	jc	errore
	mov	bp,bx
	push	ds
	mov	ax,cs
	mov	ds,ax
	mov	dx,OFFSET file_code
	xor	cx,cx
	mov	ah,3Ch
	int	21h
	pop	ds
	jc	errore
	xchg	ax,bx
	xor	dx,dx
	mov	cx,ds: word ptr [3h]
	shl	cx,4h
	mov	ah,40h
	int	21h
	jc	errore
	mov	ah,3Eh
	int	21h
	jc	errore
	push	ds
	mov	ax,cs
	mov	ds,ax
	mov	dx,OFFSET file_data
	xor	cx,cx
	mov	ah,3Ch
	int	21h
	pop	ds
	jc	errore
	xchg	bx,bp
	mov	ah,3Fh
	mov	cx,0FFFFh
	xor	dx,dx
	int	21h
	jc	errore
	push	ax
	mov	ah,3Eh
	int	21h
	pop	cx
	xchg	bx,bp
	xor	dx,dx
	mov	ah,40h
	int	21h
	jc	errore
	mov	ah,3Eh
	int	21h	                                                                                                                                                                                                                                                                                               	                                                                                                                                      		
	jc	errore
	push	cs
	pop	ds
	jmp	exit
errore:
	push	cs
	pop	ds
	mov	dx,OFFSET stringa_errore
	mov	ah,9h
	int	21h
exit:
	mov	ax,4C00h
	int	21h

stringa_errore:
	DB	'Errore I/O',0Dh,0Ah,'$'
file_name:
	DB	'X-VESA.EXE',0h
file_code:
	DB	'CODE.COM',0h
file_data:
	DB	'DATA.COM',0h

end_code:

	SAVID	ENDP
	CODE	ENDS
	END	SAVID
