;#############################################################################

;	DX = Bank

	Set_Bank_Int10_WinA_RW:

;#############################################################################

	pusha
	mov	ax,VESA_ID
	cmp	dx,ds: word ptr [current_bank]
	je	no_bank_1
	mov	ds: word ptr [current_bank],dx
	mov	ax,(VESA_ID SHL 8h) + VESA_FUNC_WINDOW_CONTROL
	mov	bx,(SET_VESA_BANK SHL 8h) + VESA_WINDOW_A
	imul	dx,ds: word ptr [granularity_units_per_bank]
	VIDEO_CALL
no_bank_1:
	test	ds: byte ptr [status_flag_3],FLAG_VESA_WINDOW_STATUS
	je	no_return_ax_01
	call	Exit_Return_AX
no_return_ax_01:
	popa
	ret

;#############################################################################

;	DX = Bank

	Set_Bank_Int10_WinB_RW:

;#############################################################################

	pusha
	mov	ax,VESA_ID
	cmp	dx,ds: word ptr [current_bank]
	je	no_bank_2
	mov	ds: word ptr [current_bank],dx
	mov	ax,(VESA_ID SHL 8h) + VESA_FUNC_WINDOW_CONTROL
	mov	bx,(SET_VESA_BANK SHL 8h) + VESA_WINDOW_B
	imul	dx,ds: word ptr [granularity_units_per_bank]
	VIDEO_CALL
no_bank_2:
	test	ds: byte ptr [status_flag_3],FLAG_VESA_WINDOW_STATUS
	je	no_return_ax_02
	call	Exit_Return_AX
no_return_ax_02:
	popa
	ret

;#############################################################################

;	DX = Bank

	Set_Bank_Int10_WinA_RoW_WinB_RoW:

;#############################################################################

	pusha
	mov	ax,VESA_ID
	cmp	dx,ds: word ptr [current_bank]
	je	no_bank_3
	mov	ds: word ptr [current_bank],dx
	imul	dx,ds: word ptr [granularity_units_per_bank]
	mov	ax,(VESA_ID SHL 8h) + VESA_FUNC_WINDOW_CONTROL
	mov	bx,(SET_VESA_BANK SHL 8h) + VESA_WINDOW_A
	VIDEO_CALL
	xchg	ax,bp
	mov	ax,(VESA_ID SHL 8h) + VESA_FUNC_WINDOW_CONTROL
	mov	bx,(SET_VESA_BANK SHL 8h) + VESA_WINDOW_B
	VIDEO_CALL
	or	ax,bp
no_bank_3:
	test	ds: byte ptr [status_flag_3],FLAG_VESA_WINDOW_STATUS
	je	no_return_ax_03
	call	Exit_Return_AX
no_return_ax_03:
	popa
	ret

;#############################################################################

;	DX = Bank

	Set_Bank_Call_WinA_RW:

;#############################################################################

	pusha
	cmp	dx,ds: word ptr [current_bank]
	je	no_bank_4
	mov	ds: word ptr [current_bank],dx
	mov	ax,(VESA_ID SHL 8h) + VESA_FUNC_WINDOW_CONTROL
	mov	bx,(SET_VESA_BANK SHL 8h) + VESA_WINDOW_A
	imul	dx,ds: word ptr [granularity_units_per_bank]
	call	ds: dword ptr [current_call_vesa_pointer]
no_bank_4:
	test	ds: byte ptr [status_flag_3],FLAG_VESA_WINDOW_STATUS
	je	no_return_ax_04
	mov	ax,VESA_ID
	call	Exit_Return_AX
no_return_ax_04:
	popa
	ret

;#############################################################################

;	DX = Bank

	Set_Bank_Call_WinB_RW:

;#############################################################################

	pusha
	cmp	dx,ds: word ptr [current_bank]
	je	no_bank_5
	mov	ds: word ptr [current_bank],dx
	mov	ax,(VESA_ID SHL 8h) + VESA_FUNC_WINDOW_CONTROL
	mov	bx,(SET_VESA_BANK SHL 8h) + VESA_WINDOW_B
	imul	dx,ds: word ptr [granularity_units_per_bank]
	call	ds: dword ptr [current_call_vesa_pointer]
no_bank_5:
	test	ds: byte ptr [status_flag_3],FLAG_VESA_WINDOW_STATUS
	je	no_return_ax_05
	mov	ax,VESA_ID
	call	Exit_Return_AX
no_return_ax_05:
	popa
	ret

;#############################################################################

;	DX = Bank

	Set_Bank_Call_WinA_RoW_WinB_RoW:

;#############################################################################

	pusha
	cmp	dx,ds: word ptr [current_bank]
	je	no_bank_6
	mov	ds: word ptr [current_bank],dx
	imul	dx,ds: word ptr [granularity_units_per_bank]
	mov	ax,(VESA_ID SHL 8h) + VESA_FUNC_WINDOW_CONTROL
	mov	bx,(SET_VESA_BANK SHL 8h) + VESA_WINDOW_A
	call	ds: dword ptr [current_call_vesa_pointer]
	mov	ax,(VESA_ID SHL 8h) + VESA_FUNC_WINDOW_CONTROL
	mov	bx,(SET_VESA_BANK SHL 8h) + VESA_WINDOW_B
	call	ds: dword ptr [current_call_vesa_pointer]
no_bank_6:
	test	ds: byte ptr [status_flag_3],FLAG_VESA_WINDOW_STATUS
	je	no_return_ax_06
	mov	ax,VESA_ID
	call	Exit_Return_AX
no_return_ax_06:
	popa
	ret
