;Reference clock input
CLK		EQU	P3.0
;Day light sensor input
DYLG	EQU	P3.1
;Light relay (active with a high state)
LIGHT	EQU	P3.7
;8 momentary push buttons (light switches)
BT		EQU	P1

; The controller remains inactive and turn-offs the light as long as
; the daylight sensor is high. When the daylight sensor output goes low
; initially the light is switched off. When any of the buttons is pressed the light is
; switched on for 20 periods of the reference clock (rising edge). To make the system
; energy efficient the light can be switched off by pushing the button again from
; the 5th period of the reference clock. After turning off the light there is a gap
; of 4 cycles before the light can be turned on again.

DSEG	AT	30
;Timer variable
TMR:	DS	1

CSEG	AT	0
RESET:
	MOV		SP, #7FH	
	
;Your implementation goes here
LIGHT_CTRL:
    CLR		LIGHT	; Switching off
    JB		DYLG, $ ; Controller inactive while daylight sensor is high
    MOV     R0, BT
    CJNE    R0, #0, LIGHT_ON ; Button pressed (manipulation by Keil I/O Ports utility)
    SJMP    LIGHT_CTRL
LIGHT_ON:
    SETB    LIGHT
    MOV 	R7, #5
CYCLE5:
    JNB		CLK, $
    JB		CLK, $
    DJNZ	R7, CYCLE5
    MOV		R7, #15
CYCLE15:
    JNB		CLK, $
    JB		CLK, $
    CJNE	R0, #BT, NO_PUSH
    SJMP	LIGHT_OFF
NO_PUSH:
    DJNZ    R7, CYCLE15
LIGHT_OFF:
    CLR		LIGHT
    MOV		R7, #4
GAP:
    JNB		CLK, $
    JB		CLK, $
    DJNZ    R7, GAP
    SJMP 	LIGHT_CTRL
STOP:
    SJMP    STOP

    END