;#############################################################################

;	DS:SI = String pointer zero terminated

	Str_Len_Mem:

;	SI = Pointer to new string

;#############################################################################

loop_string_len_mem:
	cmp	ds: byte ptr [si],0h
	je	end_string_mem
	cmp	ds: byte ptr [si],F0_COMMAND
	je	end_string_mem
	cmp	ds: byte ptr [si],F2_COMMAND
	je	end_string_mem
	inc	si
	jne	loop_string_len_mem
end_string_mem:
	inc	si
	ret
