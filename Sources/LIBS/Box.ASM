;#############################################################################

;	CH = X coordinate top left
;	CL = Y coordinate top left
;	DH = X coordinate bottom right
;	DL = Y coordinate bottom right
;	FS = Video Segment

	Box:

;#############################################################################

	pusha
	push	es
	push	fs
	pop	es
	call	Locate
	push	di
	mov	ah,ds: byte ptr [color_base_mem]
	mov	al,'É'
	stosw
	sub	dx,cx
	sub	dx,101h
	movzx	cx,dh
	mov	al,'Í'
	rep	stosw
	mov	al,'»'
	stosw
	pop	di
cornice:
	add	di,2 * TEXT_WIDTH
	push	di
	mov	al,'º'
	stosw
	mov	cl,dh
	xor	al,al
	rep	stosw
	mov	al,'º'
	stosw
	dec	dl
	pop	di
	jne	cornice
	add	di,2 * TEXT_WIDTH
	mov	al,'È'
	stosw
	mov	cl,dh
	mov	al,'Í'
	rep	stosw
	mov	al,'¼'
	stosw
	pop	es
	popa
	ret
