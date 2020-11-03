;----------------------------------------------------------
; 6 x 7-segments display
; P1 - segments
; P3 - load lines P3.0 - P3.5
;----------------------------------------------------------

TH0_INIT	EQU	128
DISP_MAX	EQU	6	

DSEG	AT	30H
DISP_BUF:	DS	DISP_MAX
DISP_PTR:	DS	1;		Diplay pointer (relative 0 - DISP_MAX)
	
SEC:		DS	1;		Clock structure 
MIN:		DS	1
HR:			DS	1

BSEG	AT	0H	

CL_HC:		DBIT	1

CSEG AT 0H
RESET:
	AJMP	INIT_SYSTEM; 	
ORG 0003H
	AJMP	INT0_ISR
ORG 000BH
	AJMP	T0_ISR
ORG 0013H
	AJMP	INT1_ISR
ORG 001BH
	AJMP	T1_ISR
ORG 0023H
	AJMP	UART_ISR
ORG 002BH
	AJMP	T2_ISR
	
;----------------------------------------------------------
; Your function to prepare
;----------------------------------------------------------
PRINT_TIME:	
	CLR 	C
	MOV		R0,#SEC
	MOV 	R1,#DISP_BUF
	MOV 	R7,#2
	MOV 	DPTR,#TO_7SEG
TIME_LP:
	MOV   	A,@R0
	MOV   	B,#10
	DIV   	AB
	MOV   	A,B
	MOVC  	A,@A + DPTR
	MOV   	@R1,A
	INC   	R1
	MOV   	A,@R0
	MOV   	B,#10
	DIV   	AB
	MOV   	B,#10
	DIV   	AB
	MOV   	A,B
	MOVC  	A,@A + DPTR
	MOV   	@R1,A
	INC   	R1
	INC   	R0
	DJNZ  	R7,TIME_LP
	MOV   	A,@R0
	MOV   	B,#10
	DIV   	AB
	MOV   	A,B
	MOVC  	A,@A + DPTR
	MOV   	@R1,A
	INC   	R1
	MOV   	A,@R0
	MOV   	B,#10
	DIV   	AB
	MOV   	B,#10
	DIV   	AB
	MOV   	A,B
	JZ		BLANK
	MOVC  	A,@A + DPTR
	MOV   	@R1,A
	SJMP  	END_TIME
BLANK:
	MOV		A,#15
	MOVC	A,@A + DPTR
	MOV   	@R1,A
END_TIME:
	RET
	
;----------------------------------------------------------
; End of your function to prepare
;----------------------------------------------------------	
	

INIT_SYSTEM:
	MOV		SEC,#58
	MOV		MIN,#59
	MOV		HR,#23
	
	MOV		R0,#DISP_BUF
	MOV		R7,#DISP_MAX

INIT_TIMER:
	MOV		TH0,#TH0_INIT	
	MOV		TL0,#TH0_INIT	
;GATE|C/nT|M1|M0
;MODE 0 - 8bit TH + div 5bit  TL
;MODE 1 - 16 bit TH + TL
;MODE 2 - 8 bit TH ld TL
;MODE 3 - 2 x 8bit TL->T0, TH->T1
	MOV	TMOD,#02H	
;TF1|TR1|TF0|TR0|IE1|IT1|IE0|IT1
;TFx - Timer OVF INT trigger
;TRx - Timer Run
;IEx - Ext Interrupt detection (Auto CLR after reception)
;ITx - 0 - Level/ 1 - Edge Int triggering
	MOV	TCON,#10H
INIT_INT:
;EA|-|ET2|ES|ET1|EX1|ET0|EX0
;EA - Global Int Enable
;ET - Timer
;ES - Serial
;EX - External
	MOV	IE,#10000010B

MAIN_LOOP:
	JBC		CL_HC,ON_CL_HC
	SJMP	MAIN_LOOP	

ON_CL_HC:	
	ACALL	PRINT_TIME
	SJMP	MAIN_LOOP
	

	
;----------------------------------------------------------
; Time increment in 24H format
; R0 - pointer to TIME struct {SEC,MIN,HR}
;----------------------------------------------------------
CLOCK_INC:	
	MOV		A,@R0
	ADD		A,#1	
	CJNE	A,#60,CLOCK_EX
	CLR		A
	MOV		@R0,A
	INC		R0
	MOV		A,@R0
	ADD		A,#1	
	CJNE	A,#60,CLOCK_EX
	CLR		A
	MOV		@R0,A
	INC		R0
	MOV		A,@R0
	ADD		A,#1	
	CJNE	A,#24,CLOCK_EX
	CLR		A
CLOCK_EX:
	MOV		@R0,A
	SETB	CL_HC
	RET
	
T0_ISR:	
	PUSH	PSW
	PUSH	ACC
	MOV		A,R0
	PUSH	ACC	
	PUSH	DPL
	PUSH	DPH	
T0_ISR_BODY:
	;ISR Body
	MOV		P3,#0FFh	
	MOV		A,DISP_PTR
	ADD		A,#DISP_BUF
	MOV		R0,A
	MOV		P1,@R0
	MOV		A,DISP_PTR
	MOV		DPTR,#TO_RING
	MOVC	A,@A + DPTR	
	MOV		P3,A
	MOV		A,DISP_PTR
	INC		A
	CJNE	A,#DISP_MAX,T0_DISP_PTR
	CLR		A
T0_DISP_PTR:	
	MOV		DISP_PTR,A
	;Incrementing a clock
	JNZ		T0_ISR_EX
	MOV		R0,#SEC
	ACALL	CLOCK_INC
T0_ISR_EX:	
	POP		DPH
	POP		DPL	
	POP		ACC
	MOV		R0,ACC
	POP		ACC
	POP		PSW
	RETI

INT0_ISR:
INT1_ISR:
UART_ISR:
T1_ISR:
T2_ISR:
	RETI
	
TO_7SEG:	
	DB	0x3F, 0x06, 0x5B, 0x4F
	DB	0x66, 0x6D, 0x7D, 0x07
	DB	0x7F, 0x6F, 0x38, 0x76
	DB	0x73, 0x77, 0x40, 0x00	
		
TO_RING:		
	DB 0xFE, 0xFD, 0xFB, 0xF7, 0xEF, 0xDF		
		

END	