VIDEO_CALL MACRO
	int	VIDEO_INTERRUPT
	cld
ENDM

CENTER_BOX MACRO X,Y
	mov	cx,(((TEXT_WIDTH - X) / 2) SHL 8) + (TEXT_HEIGHT - Y) / 2
	mov	dx,((((TEXT_WIDTH - X) / 2) + X - 1) SHL 8) + ((TEXT_HEIGHT - Y) / 2) + Y - 1
ENDM

SWAP16 MACRO X
    EXITM <((X AND 0FFh) SHL 8) OR ((X AND 0FF00h) SHR 8)>
ENDM

SWAP32 MACRO X
    EXITM <(((X AND 000000FFh) SHL 24) OR \
        ((X AND 0000FF00h) SHL 8)  OR \
        ((X AND 00FF0000h) SHR 8)  OR \
        ((X AND 0FF000000h) SHR 24))>
ENDM

SOUND_ERROR MACRO
	pusha
	mov	ax,1000d
	mov	bx,140d
	call	Sound
	popa
ENDM

SOUND_END MACRO
	pusha
	mov	ax,5000d
	mov	bx,140d
	call	Sound
	popa
ENDM

TABELLA_CIFRE CATSTR <0123456789>

NUM_TO_CHAR_PREP MACRO n, final_name
    LOCAL val, s_acc, resto, cifra_char
    val = n
    s_acc CATSTR <>
    IF val EQ 0
        final_name EQU <'0'>
    ELSE
        WHILE val GT 0
            resto = val MOD 10
            cifra_char SUBSTR TABELLA_CIFRE, (resto + 1), 1
            s_acc CATSTR cifra_char, s_acc
            val = val / 10
        ENDM
        final_name CATSTR <'>, s_acc, <'>
    ENDIF
ENDM
