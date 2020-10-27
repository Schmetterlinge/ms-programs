TX_DATA    	EQU    P1
TX			EQU    P3.0
TX_RQ    	EQU    P3.7
TX_ACK    	EQU    P3.6

DSEG    AT    30H
DUTY:       DS    1
PWM_CNT:    DS    1
PWM_DUTY:   DS    1

BSEG    AT    0H    
PWM_SYNC:   DBIT    1

CSEG 	AT 	  0H
RESET:
    AJMP    INIT_SYSTEM
    ;Interrupt vectors - ISR entries
ORG 0003H
    AJMP    INT0_ISR
ORG 000BH
    AJMP    T0_ISR
ORG 0013H
    AJMP    INT1_ISR
ORG 001BH
    AJMP    T1_ISR
ORG 0023H
    AJMP    UART_ISR
ORG 002BH
    AJMP    T2_ISR

INIT_SYSTEM:
    MOV        SP,#7Fh        
    ; Initialize timer and interrupt system
    MOV        TH0,#254
    MOV        TH1,#192
    MOV        TL1,#192
    MOV        TMOD,#21H
    MOV        TCON,#50H
    MOV        IE,#82H
    MOV		   IP,#00001000B
    
    
TEST:    
    MOV        P1,#55H
    ACALL      TEST_HSK
    MOV        P1,#0AAH
    ACALL      TEST_HSK
TEST_DONE:
    SJMP       TEST_DONE
    
TEST_HSK:    
    CLR        TX_RQ
    JB         TX_ACK,$
    SETB       TX_RQ
    JNB        TX_ACK,$
    RET
    

T0_ISR:
    PUSH       PSW
    PUSH       ACC
T0_ISR_BODY:
    MOV        TH0,#254
    SETB	   TX_ACK
	JB		   TX_RQ, T0_ISR_EX
	CLR		   TX_ACK
START_BIT: 
    MOV        A, TX_DATA
    JB         ACC.0, START_BIT
    RR         A
    MOV        R0, #0
CHARACTER:
	JNB		   ACC.0, BIT_0
BIT_1:
	SETB	   TX
	JNB        TF1,$
	RR		   A
	INC        R0
	CJNE       R0, #8, CHARACTER
	SJMP	   END_BIT
BIT_0:
    CLR		   TX
	JNB        TF1,$
    RR         A
    INC        R0
    CJNE       R0, #8, CHARACTER
END_BIT:
    MOV        A, TX_DATA
    JNB        ACC.0, END_BIT
T0_ISR_EX:            
    POP        ACC
    POP        PSW
T0_ISR_DONE:    
    RETI    
    
T1_ISR:        
INT0_ISR:
INT1_ISR:
UART_ISR:
T2_ISR:
    RETI
    
    END