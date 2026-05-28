;#############################################################################

;	AL = Test value
;	DH = Min mask
;	DL = Max mask

	Block_Yes_Or_No:

;	CL = Y coordinate + nn

;#############################################################################

	push	ax
	mov	ah,dh
loop_aspi_1:
	call    Yes_Or_No
	cmp	dh,dl
	jb	normal_byon
	shr	ah,1h
	je	end_block_mode
	cmp	dl,ah
	jbe	loop_aspi_1
	jmp	end_block_mode
normal_byon:
	add	ah,ah
	je	end_block_mode
	cmp	ah,dl
	jbe	loop_aspi_1
end_block_mode:
	mov	ds: word ptr [start_xy],cx
	pop	ax
	ret
