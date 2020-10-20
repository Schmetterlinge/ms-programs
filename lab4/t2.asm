;Reference clock input
CLK		EQU	P3.0
;Day light sensor input
DYLG	EQU	P3.1

LIGHT	EQU	P3.7
;8 momentary push buttons
BT		EQU	P1


DSEG	AT	30
;Timer variable
TMR:	DS	1

CSEG	AT	0
RESET:
	MOV		SP,#7FH	
	
; Your implementation goes here	
LIGHT_CTRL:
	CLR		LIGHT; Switching off
	JB		DYLG,$
	MOV		R0,BT
	CJNE	R0,#0,LIGHT_ON
	SJMP	Light_CTRL
	Light_ON:
	SetB	Light
	Mov R7,#5
	cycle5:
	JNB		CLK,$
	JB		CLK,$
	DJNZ	R7,Cycle5
	Mov	R7,#15
	cycle15:
	JNB		CLK,$
	JB		CLK,$
	Mov		A,R0
	Subb	A,BT
	JNZ no_push
	SJMP	Light_off
	no_push:
	DJNZ	R7,cycle15
	light_off:
	CLR		light
	MOV		R7,#4
	Gap:
	JNB		CLK,$
	JB		CLK,$
	DJNZ	R7,Gap
	SJMP Light_CTRL
STOP:
	SJMP	STOP
	
	
END	
