	.386
	SEGMENT CODE USE16
	ASSUME	CS:CODE,DS:CODE
	ORG 	100h
	BUFFER	EQU	0C0h
	SAVID 	PROC
	SAVID	ENDP

	mov	dx,OFFSET dos_message_1
	mov	ah,9h
	int	21h
	mov	bp,OFFSET dos_message_2
	mov	si,BUFFER
	call	Get_Args
	lodsb
	cmp	al,1h
	je	ok_command_line
exit_whit_print:
	mov	dx,bp
	mov	ah,9h
	int	21h
	mov	ax,4C00h
	int	21h
ok_command_line:
	mov	bp,OFFSET dos_message_3
	mov	ax,cs
	add	ax,1000h
	mov	es,ax
	mov	ax,3D02h
	mov	dx,ds: word ptr [si]
	int	21h
	jc	exit_whit_print
	xchg	ax,bx
	mov	ah,3Fh
	mov	cx,0FFFFh
	xor	dx,dx
	push	es
	pop	ds
	int	21h
	push	cs
	pop	ds
	jc	exit_whit_print
	mov	bp,OFFSET dos_message_5
	cmp	ax,5h
	jb	exit_whit_print
	cmp	ax,0FF00h - (OFFSET crypt_off - OFFSET crypt_on)
	ja	exit_whit_print
	xchg	ax,di
	mov	ax,es: word ptr [0h]
	mov	ds: word ptr [_PATCH_0+4h],ax
	mov	al,es: byte ptr [2h]
	mov	ds: byte ptr [_PATCH_3+4h],al
	mov	si,3h
	lea	cx,ds: word ptr [di-1h]
loop_xor:
	mov	al,es: byte ptr [si+1h]
	xor	es: byte ptr [si],al
	inc	si
	cmp	si,cx
	jb	loop_xor
	lea	si,ds: word ptr [di+100h-1h]
	mov	ds: word ptr [_PATCH_1+1h],si
	sub	si,100h - (OFFSET crypt_off - OFFSET crypt_on)
	not	si
	mov	ds: word ptr [_PATCH_2+1h],si
	mov	ah,40h
	mov	dx,OFFSET crypt_on
	mov	cx,OFFSET crypt_off
	sub	cx,dx
	int	21h
	jc	exit_whit_print
	mov	ax,4200h
	xor	cx,cx
	xor	dx,dx
	int	21h
	jc	exit_whit_print
	mov	es: byte ptr [0],0E9h
	mov	cx,di
	sub	di,3h
	mov	es: word ptr [1h],di
	mov	ah,40h
	xor	dx,dx
	push	es
	pop	ds
	int	21h
	push	cs
	pop	ds
	jc	exit_whit_print
	mov	ah,3Eh
	int	21h
	jc	exit_whit_print
	mov	bp,OFFSET dos_message_4
	jmp	exit_whit_print

dos_message_1:
	DB	'Crypt V1.2 by M.Pistella (18/04/2026)',0Dh,0Ah,'$'
dos_message_2:
	DB	'Use: CRYPT.COM <file .COM to crypt>',0Dh,0Ah,'$'
dos_message_3:
	DB	'Error on I/O',0Dh,0Ah,'$'
dos_message_4:
	DB	'File Crypted',0Dh,0Ah,'$'
dos_message_5:
	DB	'Unsupported .COM file',0Dh,0Ah,'$'

;#############################################################################

;	DS:SI = Puntatore all'area di memoria in cui stoccare i puntatori agli
;		argomenti passati attraverso la linea di comando (il primo
;               byte rappresenta il numero di argomenti)

Get_Args:

;#############################################################################

	pusha
	xor	bx,bx
	push	si
	inc	si
	mov	di,81h
	movzx	cx,ds: byte ptr [di-1h]
	or	cl,cl
	je	exit_get_args
	mov	al,' '
another_arg:
	rep	scasb
	je	exit_get_args
	inc	bx
	mov	ds: word ptr [si],di
	dec	ds: word ptr [si]
	inc	si
	inc	si
	repne	scasb
	jne	set_final_string
	mov	ds: byte ptr [di-1h],ch
	jmp	another_arg
set_final_string:
	mov	ds: byte ptr [di],ch
exit_get_args:
	pop	si
	mov	ds: byte ptr [si],bl
	popa
	ret

crypt_on:
_PATCH_0:
	mov	ds: word ptr [100h],0h
_PATCH_3:
	mov	ds: byte ptr [102h],0h
_PATCH_1:
	mov	si,8000h
loop_crypt_routine:
	mov	al,ds: byte ptr [si]
	dec	si
	xor	ds: byte ptr [si],al
	cmp	si,103h
	jne	loop_crypt_routine
_PATCH_2:
	DB	0E9h,000h,000h
crypt_off:

	CODE	ENDS
	END	SAVID
