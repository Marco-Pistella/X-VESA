;#############################################################################

;	DS:SI = Buffer for line data
;	ES:DI = Buffer for line data compressed
;	AX = Line len

	Compress_Line:

;	ES:DI = Buffer for line data compresser (write)
;	AX = Line len compressed

;#############################################################################

	pusha
	push	di
	mov	bx,di
	xchg	ax,cx
init_iff_line:
	xor	di,di
	mov	bp,bx
	inc	bx
	xor	dh,dh
	mov	ah,ds: byte ptr [si]
	inc	si
	mov	es: byte ptr [bx],ah
	inc	bx
next_iff_col:
	dec	cx
	je	exit_next_iff_col
	mov	al,ds: byte ptr [si]
	inc	si
	cmp	al,ah
	jne	go_literal
	or	dh,dh
	jl	go_run
	jne	two_char_nq
	mov	dh,-1h
	jmp	next_iff_col
two_char_nq:
	dec	dh
	mov	es: byte ptr [bp],dh
	mov	di,bp
	mov	dh,-1d
	lea	bp,ds: word ptr [bx - 1h]
	mov	es: byte ptr [bx],al
	inc	bx
	jmp	next_iff_col
go_run:
	dec	dh
	cmp	dh,-127d
entry_max_bytecode:
	jne	next_iff_col
	dec	cx
	je	exit_next_iff_col
	mov	es: byte ptr [bp],dh
	jmp	init_iff_line
go_literal:
	or	dh,dh
	jge	exec_literal
	cmp	dh,0FFh
	jne	no_extra_pack
	or	di,di
	je	no_extra_pack
	cmp	es: byte ptr [di],0h
	jl	no_extra_pack
	cmp	es: byte ptr [di],124d
	ja	no_extra_pack
	add	es: byte ptr [di],2h
	mov	dh,es: byte ptr [di]
	mov	es: byte ptr [bp],ah
	mov	bp,di
	xor	di,di
	jmp	exec_literal
no_extra_pack:
	mov	es: byte ptr [bp],dh
	mov	di,bp
	mov	bp,bx
	inc	bx
	xor	dh,dh
	mov	es: byte ptr [bx],al
	inc	bx
	mov	ah,al
	jmp	next_iff_col
exec_literal:
	mov	es: byte ptr [bx],al
	inc	bx
	mov	ah,al
	inc	dh
	cmp	dh,127d
	jmp	entry_max_bytecode
exit_next_iff_col:
	mov	es: byte ptr [bp],dh
	xchg	ax,bx
	pop	bx
	sub	ax,bx
	call	Exit_Return_AX
	popa
	ret
