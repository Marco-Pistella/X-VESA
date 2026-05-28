;#############################################################################

	Get_Key:

;	AX = Key scan code

;#############################################################################

	pusha
new_key:
	mov	ah,KEY_FUNC_GET
	int	KEY_INTERRUPT
	xchg	ax,bp
	mov	ah,KEY_FUNC_STATE
	int	KEY_INTERRUPT
	mov	ds: word ptr [key_status],ax
	mov	cx,DUAL_KEY_NUM
	mov	si,OFFSET dual_key_table
loop_dual_key:
	lodsw
	cmp	ax,bp
	jne	no_dual_key
	mov	bp,ds: word ptr [si]
	jmp	exit_get_key
no_dual_key:
	add	si,2h
	loop	loop_dual_key	
exit_get_key:
	xchg	ax,bp
	cmp	ax,F2_KEY
	jne	no_screenshoot
	test	ds: byte ptr [status_flag_3],SCREENSHOT_ON
	jne	no_screenshoot
	call	Save_IFF_File
no_screenshoot:
	call	Exit_Return_AX
	popa
	ret
