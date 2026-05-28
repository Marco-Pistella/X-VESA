	.8086
	SEGMENT CODE USE16
	ASSUME	CS:CODE,DS:CODE
	ORG	100h
	SAVID	PROC

start_code:
	cld
	mov	ax,40h
	mov	ds,ax
	mov	ax,ds: word ptr [13h]
	mov	cl,6h
	shl	ax,cl
	mov	bx,cs
	mov	ds,bx
	sub	ax,bx
	cmp	ax,3000h
	jae	ok_mem
	mov	ah,9h
	mov	dx,OFFSET no_mem_message
	int	21h
	int	20h
ok_mem:
	mov	ax,cs
	add	ah,20h
	mov	ss,ax
	mov	es,ax
	mov	cx,OFFSET end_code - OFFSET start_code
	mov	si,OFFSET start_code
	mov	di,si
	shr	cx,1h
	jnc	no_odd_1
	movsb
no_odd_1:
	rep	movsw
	push	es
	mov	ax,OFFSET reloc_jmp_1
	push	ax
	retf
reloc_jmp_1:
	mov	si,OFFSET end_code
	add	si,ds: word ptr [code_comp_len]
	mov	di,OFFSET end_code
	mov	cx,ds: word ptr [data_comp_len]
	shr	cx,1h
	jnc	no_odd_2
	movsb
no_odd_2:
	rep	movsw
	mov	di,OFFSET start_code
	mov	si,OFFSET end_code
	mov	ax,ds
	mov	es,ax
	mov	cx,ds: word ptr [code_comp_len]
	shr	cx,1h
	jnc	no_odd_3
	movsb
no_odd_3:
	rep	movsw
	push	cs
	mov	ax,OFFSET reloc_jmp_2
	push	ax
	push	ds
	mov	ax,OFFSET start_code
	push	ax
	retf
reloc_jmp_2:
	mov	si,OFFSET end_code
	mov	ax,cs
	mov	ds,ax
	mov	di,OFFSET start_code
	mov	cx,ds: word ptr [data_comp_len]
	shr	cx,1h
	jnc	no_odd_4
	movsb
no_odd_4:
	rep	movsw
	retf
no_mem_message:
	DB	'SDT-STUB V1.0.0 (15/04/2026)',0Dh,0Ah,'Not enough memory, 192KiB or more required',0Dh,0Ah,'$'
code_comp_len:
	DW	0h
data_comp_len:
	DW	0h
end_code:

	SAVID	ENDP
	CODE	ENDS
	END	SAVID
