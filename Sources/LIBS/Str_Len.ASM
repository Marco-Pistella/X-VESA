;#############################################################################

;	DS:SI = String pointer zero terminated or command

	Str_Len:

;	CARRY = 0
;		AX = String length
;	CARRY = 1 -> Address failure

;#############################################################################

	pusha
	xor	dx,dx
	xor	ah,ah
loop_string_len:
	lodsb
	or	al,al
	je	end_string
	or	si,si
	jne	valid_address
	stc
	popa
	ret
valid_address:
	cmp	al,F6_COMMAND
	jne	test_f0_strlen
	push	ax
	push	si
	mov	si,ds: word ptr [si]
	call	Str_Len
	add	dx,ax
	pop	si
	pop	ax
	add	si,2h	
	jmp	loop_string_len
test_f0_strlen:
	cmp	al,F0_COMMAND
	je	end_string
	cmp	al,F1_COMMAND
	jne	test_f2_strlen
	lodsb
	add	dx,ax
	jmp	loop_string_len
test_f2_strlen:
	cmp	al,F2_COMMAND
	je	end_string
	cmp	al,F3_COMMAND
	jne	test_f4_strlen
	lodsb
	add	dx,ax
entry_f5_key:
	lodsb
	jmp	loop_string_len
test_f4_strlen:
	cmp	al,F4_COMMAND
	jne	test_f5_strlen
	add	si,2h
	jmp	loop_string_len
test_f5_strlen:
	cmp	al,F5_COMMAND
	je	entry_f5_key
	inc	dx
	jmp	loop_string_len
end_string:
	xchg	ax,dx
	call	Exit_Return_AX
	clc
	popa
	ret
