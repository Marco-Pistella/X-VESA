
;	Constants used by Keyboard routine

	KEY_INTERRUPT					EQU	16h

	KEY_FUNC_GET					EQU	10h
	KEY_FUNC_STATE					EQU	12h
	KEY_FUNC_CHECK					EQU	1h

	DUAL_KEY_NUM					EQU	(OFFSET end_dual_key_table - OFFSET dual_key_table) / 4

	BACKSPACE_KEY					EQU	0E08h
	ESC_KEY						EQU	11Bh
	UP_KEY						EQU	48E0h
	UP_KEY2						EQU	4800h
	DOWN_KEY					EQU	50E0h
	DOWN_KEY2					EQU	5000h
	LEFT_KEY					EQU	4BE0h
	LEFT_KEY2					EQU	4B00h
	RIGHT_KEY					EQU	4DE0h
	RIGHT_KEY2					EQU	4D00h
	HOME_KEY					EQU	47E0h
	HOME_KEY2					EQU	4700h
	END_KEY						EQU	4FE0h
	END_KEY2					EQU	4F00h
	PGUP_KEY					EQU	49E0h
	PGUP_KEY2					EQU	4900h
	PGDN_KEY					EQU	51E0h
	PGDN_KEY2					EQU	5100h
	ENTER_KEY					EQU	1C0Dh
	ENTER_KEY2					EQU	0E00Dh
	INS_KEY						EQU	52E0h
	INS_KEY2					EQU	5200h
	DEL_KEY						EQU	53E0h
	DEL_KEY2					EQU	5300h
	CTRL_LEFT_KEY					EQU	73E0h
	CTRL_LEFT_KEY2					EQU	7300h
	CTRL_RIGHT_KEY					EQU	74E0h
	CTRL_RIGHT_KEY2					EQU	7400h
	CTRL_UP_KEY					EQU	8DE0h
	CTRL_UP_KEY2					EQU	8D00h
	CTRL_DOWN_KEY					EQU	91E0h
	CTRL_DOWN_KEY2					EQU	9100h
	PLUS_KEY					EQU	4E2Bh
	PLUS_KEY2					EQU	1B2Bh
	MINUS_KEY					EQU	4A2Dh
	MINUS_KEY2					EQU	352Dh

	_1_KEY						EQU	231h
	_1_KEY2						EQU	4F31h
	_2_KEY                                          EQU	332h
	_2_KEY2                                         EQU	5032h
	_3_KEY                                          EQU	433h
	_3_KEY2                                         EQU	5133h
	_4_KEY                                          EQU	534h
	_4_KEY2                                         EQU	4B34h

	I_KEY						EQU	1769h
	R_KEY						EQU     1372h
	F_KEY						EQU	2166h
	T_KEY                                           EQU	1474h
	B_KEY                                           EQU	3062h
	Y_KEY                                           EQU	1579h
	N_KEY						EQU	316Eh
	S_KEY						EQU	1F73h
	E_KEY						EQU	1265h
	G_KEY						EQU	2267h
	D_KEY						EQU	2064h

	F1_KEY						EQU	3B00h
	F2_KEY						EQU	3C00h
	F5_KEY						EQU	3F00h
	F6_KEY						EQU	4000h
	F7_KEY						EQU	4100h
	F8_KEY						EQU	4200h
	F9_KEY						EQU	4300h
	F10_KEY						EQU	4400h

	SPACE_KEY					EQU	3920h

	CHOICE_INS					EQU	(1 SHL 6)
