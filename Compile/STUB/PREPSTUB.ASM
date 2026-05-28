	.386
	SEGMENT CODE USE16
	ASSUME	CS:CODE,DS:CODE
	ORG	100h
	SAVID	PROC

	mov	ax,3D00h
	mov	dx,OFFSET code_file_name
	int	21h
	xchg	ax,bx

	xor	cx,cx
	xor	dx,dx
	mov	ax,4202h
	int	21h

	mov	ds: word ptr [code_comp_len],ax
	mov	ah,3Eh
	int	21h

	mov	ax,3D00h
	mov	dx,OFFSET data_file_name
	int	21h
	xchg	ax,bx

	xor	cx,cx
	xor	dx,dx
	mov	ax,4202h
	int	21h

	mov	ds: word ptr [data_comp_len],ax
	mov	ah,3Eh
	int	21h

	mov	ax,3D01h
	mov	dx,OFFSET stub_file_name
	int	21h
	xchg	ax,bx

	mov	cx,0FFFFh
	mov	dx,0FFFCh
	mov	ax,4202h
	int	21h

	mov	cx,4h
	mov	dx,OFFSET code_comp_len
	mov	ah,40h
	int	21h

	mov	ah,3Eh
	int	21h

	mov	ax,4C00h
	int	21h

code_file_name:
	DB	'CODE.COM',0h
data_file_name:
	DB	'DATA.COM',0h
stub_file_name:
	DB	'STUB.COM',0h
code_comp_len:
	DW	0h
data_comp_len:
	DW	0h

	SAVID	ENDP
	CODE	ENDS
	END	SAVID
