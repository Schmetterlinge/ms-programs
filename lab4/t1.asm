nRDY	EQU		P3.0
nACK	EQU		P3.1
;In order DIN make an input, it should
;be loaded with 0xFF - an open drain port
DIN		EQU		P1

DSEG	AT	30H
DATA_BUF:	DS	6
DATA_LRC:	DS	1

	
	
CSEG	AT	0	
RESET:
	MOV		SP,#7FH
	
; Here goes your implementation of the controller	
HSK_CTRL:
    MOV    R7,#7
    MOV    R0,#DATA_BUF
DATA_LOOP:
    JB    nRDY,$
    CLR   nACK
    JNB   nRDY,$
    CJNE  R7,#7,REST_DATA
    SJMP  FIRST_DATA
REST_DATA:
    MOV   @R0,P1
    INC   R0
FIRST_DATA:
    DJNZ    R7, DATA_LOOP
    SJMP    PROC_DATA
	

;Just a catcher in case of incomplete code
STOP:
	SJMP	STOP	
	
PROC_DATA:
	MOV		@R0,#DATA_BUF
	MOV		R7,#6
	MOV		A,#0FFH
PROC_DATA_LP:
	ADD		A,@R0
	INC		R0
	DJNZ	R7, PROC_DATA_LP	
	MOV		DATA_LRC,A
	RET	
	
	END
	