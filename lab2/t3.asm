; Task 3 - Calendar incrementation including a leap year

DSEG	AT	30h
WDAY:		DS	1
DAY:		DS	1
MTH:		DS	1
YR:			DS	1

;Diagnostic data
DIAG_CNT:	DS	2

CSEG	AT	0

RESET:
	AJMP	MAIN
;--------------------------------	
;Here goes your solution
INC_DATE:
    INC        WDAY
    MOV        A,#7
    SUBB       A,WDAY
    JNZ        INC_DAY
    MOV        WDAY,#0
INC_DAY:
    INC        DAY
    MOV        A,YR
    MOV        B,#4
    DIV        AB
    MOV        A,B
    JNZ        NO_LEAP
    MOV        A,#2
    SUBB       A,MTH
    JNZ        NO_LEAP
    MOV        DPTR,#MTH_LEN
    MOV        A,MTH
    MOVC       A,@A + DPTR
    INC        A
    SUBB       A,DAY
    JNZ        INC_YEAR
    INC        MTH
    MOV        DAY, #1
    SJMP       INC_YEAR
NO_LEAP:
    MOV        A,#1
    ADD        A,1
    MOV        DPTR,#MTH_LEN
    MOV        A,MTH
    MOVC       A,@A + DPTR
    SUBB       A,DAY
    JNZ        INC_YEAR
    INC        MTH
    MOV        DAY,#1
INC_YEAR:
    MOV        A,#13
    SUBB       A,MTH
    JNZ        INC_END
    MOV        MTH,#1
    INC        YR
INC_END:
    RET    

;--------------------------------

MAIN:
	MOV		SP,#7Fh	
	MOV		DIAG_CNT,#245
	MOV		DIAG_CNT + 1,#6	
	MOV		WDAY,#0
	MOV		DAY,#1
	MOV		MTH,#1
	MOV		YR,#0
TEST_LP:
	MOV		R0,#WDAY
	ACALL	INC_DATE	
TEST_STEP:	
	DJNZ	DIAG_CNT, TEST_LP
	DJNZ	DIAG_CNT + 1, TEST_LP	
STOP:
	SJMP	STOP
	
; You can use MTH_LEN table to determine number of days	
MTH_LEN:
	DB 0, 32, 29, 32, 31, 32, 31, 32, 32, 31, 32, 31, 32
	
	END
	