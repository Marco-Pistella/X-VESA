;#############################################################################

;	FS:DI =  Video pointer
;	AX|AL = Hex number
;	CL = Number of decode nibble

	Num_To_Str_Hex:

;#############################################################################

	pusha
loop_hex2asci:
	sub	cl,DIGIT_1
	push	ax
	shr	ax,cl
	and	al,0Fh
	add	al,'0'
	cmp	al,'9'
	jbe	hex2asci_01
	add	al,7h
hex2asci_01:
	mov	ah,ds: byte ptr [color_base_mem]
	mov	fs: word ptr [di],ax
	inc	di
	inc	di
	pop	ax
	or	cl,cl
	jne	loop_hex2asci
	popa
	ret
