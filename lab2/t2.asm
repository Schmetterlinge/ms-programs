; Task 2

DSEG	AT	30h
SEC:	DS	1
MIN:	DS	1
HR:		DS	1

DIAG_CNT:
		DS	3

CSEG	AT	0

RESET:
	AJMP	MAIN
;--------------------------------	
;Here goes your solution
INC_TIME:
	CLR     C
    INC     @R0
    MOV     A,@R0
    DA      A
    MOV     @R0,A
    CJNE    @R0,#96,LOOP
    MOV     @R0,#0
    CLR     C
    INC     R0
    INC     @R0
    MOV     A,@R0
    DA      A
    MOV     @R0,A
    CJNE    @R0,#96,LOOP
    MOV     @R0,#0
    INC     R0
    INC     @R0
    MOV     A,@R0
    DA      A
    MOV     @R0,A
    CJNE    @R0,#36,LOOP
    MOV		@R0,#0
LOOP:
    RET

;--------------------------------

MAIN:
	MOV		SP,#7Fh	
	MOV		DIAG_CNT,#80H
	MOV		DIAG_CNT + 1,#52H
	MOV		DIAG_CNT + 2,#2
	MOV		SEC,#0
	MOV		MIN,#0
	MOV		HR,#0
TEST_LP:
	MOV		R0,#SEC
	ACALL	INC_TIME	
TEST_STEP:	
	DJNZ	DIAG_CNT, TEST_LP
	DJNZ	DIAG_CNT + 1, TEST_LP
	DJNZ	DIAG_CNT + 2, TEST_LP	
STOP:
	SJMP	STOP
	
	END
	