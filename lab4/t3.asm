;Gate sensors
GT_0	EQU	P1.0
GT_1	EQU	P1.1


BSEG	AT 0
GO_INC: DBIT		1
GO_DEC:	DBIT		1

DSEG	AT 30H
;This is a rotation counter
CNT:	DS			1

CSEG	AT 0H

RESET:
	AJMP	MAIN

; -------------------------------------	
;    Your implementation starts here	
; -------------------------------------	
GATE_CTRL:
S1_LP:
    JNB		GT_0, LEFT
    JNB		GT_1, RIGHT
	SJMP	S1_LP
RIGHT:
R1_LP:
	JB		GT_1, S1_LP
	JNB 	GT_0, R2_LP
	SJMP 	R1_LP
R2_LP:
	JB    	GT_0, R1_LP
	JB		GT_1, R3_LP
	SJMP 	R2_LP
R3_LP:
	JB    	GT_0, INCREMENT
	JNB    	GT_1, R2_LP
	SJMP    R3_LP
INCREMENT:
	MOV 	A, #255
	SUBB 	A, CNT
	JZ    	S1_LP
	INC 	CNT
	SJMP 	S1_LP
LEFT:
L1:
	JB		GT_0, S1_LP
	JNB    	GT_1, L2
	SJMP 	L1
L2:
	JB  	GT_1, L1
	JB		GT_0, L3
	SJMP	L2
L3:
	JB    	GT_1, DECREMENT
	JNB    	GT_0, L2
	SJMP    L3
DECREMENT:
	MOV 	A, CNT
	JZ    	S1_LP
	DEC 	CNT
	SJMP 	S1_LP
    
    RET
	
MAIN:
	MOV		SP, #7FH
	MOV		CNT, #0
RUN_GATE:	
	ACALL	GATE_CTRL

STOP:
	SJMP	STOP
	
	END