**************************************************************************
*																							    *
* 		SYSTEM "ASSEMBLY TIME" CONDITIONALS											 *
*																							    *
**************************************************************************
WARREN	equ	0		; Only One of these should be 1
BILL		equ   0		; If NONE are 1, then final game choices are used
GEORGE	equ	0
NOBODY	equ	1		; for running the game


	.if WARREN+BILL+GEORGE+NOBODY != 1

	DIS AIN'T RIGHT!!!

	.endif

;DEBUG		EQU	1	;THIS VERSION IS CURRENTLY UNDER CONSTRUCTION
DEBUG		EQU	0	;ADD THIS BEFORE RELEASE!!!!!

CENTER_SCREEN	EQU	1	;FLAG TO CENTER PAGES HORIZONTALLY IN BITMAP
;CENTER_SCREEN	EQU	0

GERMAN		EQU	0	;ENGLISH RELEASE
;GERMAN		EQU	1	;GERMAN RELEASE

NOTFINAL		EQU	1	;IF = 1, NOT PRODUCTION QUALITY PROGRAM
;NOTFINAL	EQU	0	;ADD THIS BEFORE RELEASE!!!!!

PRINTER		EQU	0	; IF 1, THERE IS A PRINTER HOOKED TO SOUND PORT

YUNIT			EQU	1	;IF 1, THIS VERSION IS FOR THE Y-UNIT AT 6 BITS/PIXEL

TUNIT			EQU	1	;WE GOTS THE T-UNIT NOW!

IMGBGND		EQU	0	;SET TO 1 TO PUT BGNDTBLS IN IMAGE MEMORY

FORCEFREE	EQU	0	;1 = GAME HARDWIRED FREE
NO_DEATH		EQU	0	;1 = Player's will never die
FULLPRICE	EQU	1	;1 = ALL THE PRICINGS ARE INCLUDED

NTSC			EQU	0	;IF 1, THEN SET THE VIDEO TO NTSC COMPATIBLE

USING_UART	EQU	1	;Using UART for sound communication

NOPIC		equ	0	; Set to 1 if you don't have a PIC
DEVEL_PIC	equ	0	;Set to 1 if you have a development PIC
UNSECURE	equ	0	; Set to 1 to disable security

	.if UNSECURE
SECURITY_LEVEL	EQU	0
	.elseif NOPIC
SECURITY_LEVEL	EQU	0
	.else
SECURITY_LEVEL	EQU	1
	.endif

