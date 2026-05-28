;#############################################################################

;	DX = Manufacturer ID
;	CH = X coordinate
;	CL = Y coordinate
;	FS = Video Segment

	Write_EDID_Manifacturer_ID:

;	CARRY = 0 -> Valid ID
;	CARRY = 1 -> Invalid ID

;#############################################################################

	pusha	
	xchg	dl,dh
	mov	bx,103h
	test	dh,80h
	je	loop_monitor_id2
	xor	bh,bh
loop_monitor_id2:
	mov	ax,dx
	and	al,1Fh
	cmp	al,26d
	jbe	valid_idm1
	xor	bh,bh
valid_idm1:
	or	al,al
	jne	valid_idm2
	xor	bh,bh
valid_idm2:
	or	al,40h
	call	Write_Char
	sub	ch,2h
	shr	dx,5h
	dec	bl
	jne	loop_monitor_id2
	sub	bh,1h
	popa
	ret
