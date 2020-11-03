;------------------------------------------------
; Keyboard simple controller
; P1 - push buttons
;------------------------------------------------
TH0_INIT	EQU	128
KB_MAX		EQU	4	
INC_A		EQU	1
DEC_A		EQU	2	
INC_B		EQU	4
DEC_B		EQU	8

DSEG	AT	30H
ARG_A:		DS	1
ARG_B:		DS	1
RES_Y:		DS	1

;Keyboard items
KB_BUF:		DS	KB_MAX
KB_DW:		DS	1
KB_UP:		DS	1


BSEG	AT	0H	
KB_DW_RQ:	DBIT	1
KB_UP_RQ:	DBIT	1

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

INIT_SYSTEM:
	MOV		KB_BUF,#0H
	MOV		KB_BUF + 1,#0H
	MOV		KB_BUF + 2,#0H
	MOV		KB_BUF + 3,#0H
	
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
	JBC		KB_DW_RQ,ON_KB_DW	
	JBC		KB_UP_RQ,ON_KB_UP	
	SJMP	MAIN_LOOP
	
;----------------------------------------------------------
; Your function to prepare
; When K0 hold down longer than 16 timer cycles - call ON_LONG_K0
; When K7 and K1 simultanously down - call ON_K7_K1
;----------------------------------------------------------	
	
ON_KB_DW:
	SJMP	MAIN_LOOP
	
ON_KB_UP:	

	SJMP	MAIN_LOOP
	
ON_LONG_K0:
	
	RET
	
ON_K7_K1:

	RET	
	
;----------------------------------------------------------
; End of your function to prepare
;----------------------------------------------------------	
	
T0_ISR:	
	PUSH	PSW
	PUSH	ACC		
T0_ISR_BODY:
	MOV		KB_BUF + 3, KB_BUF + 2
	MOV		KB_BUF + 2, KB_BUF + 1
	MOV		KB_BUF + 1, KB_BUF
	MOV		A, P1
	CPL		A
	MOV		KB_BUF, A
T0_KB_DW_TEST:
	MOV		A,KB_BUF + 3
	CPL		A
	ANL		A,KB_BUF + 2
	ANL		A,KB_BUF + 1
	ANL		A,KB_BUF	
	JZ		T0_KB_UP_TEST
	MOV		KB_DW,A
	SETB	KB_DW_RQ	
;----------------------------------------------------------
; Your extension begin
; When key up event detected
; 1. Set KB_UP_RQ
; 2. Write pattern of released keys to KB_UP
;----------------------------------------------------------	
T0_KB_UP_TEST:
	MOV		A,KB_BUF + 3
	CPL		A
	ORL		A,KB_BUF + 2
	ORL		A,KB_BUF + 1
	ORL		A,KB_BUF
	CPL		A
	JZ		T0_ISR_EX
	MOV		KB_UP,A
	SETB	KB_UP_RQ	

;----------------------------------------------------------
; Your extension end
;----------------------------------------------------------
	
T0_ISR_EX:	
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