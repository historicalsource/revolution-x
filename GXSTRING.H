**************************************************************************
*                                                                        *
* 				EQUATES FOR STRING ROUTINES											 *
*                                                                        *
**************************************************************************
*
*	TEXT ROUTINES
*
	.GLOBAL	STRLNRMOS
	.GLOBAL	PRINTF, LM_PRINTF
	.GLOBAL	STRLNRMOF, STRCNRMOF
	.GLOBAL	STRINGF
	.GLOBAL	STRLNRM, STRCNRM, STRRNRM, STRCNRMO, STRLNRMO, STRRNRMO
	.GLOBAL	STRLNC, STRCNC, STRRNC, STRCNCO, STRCNRM2, STRCNRMS2
	.GLOBAL	STRLNRM2, STRRNRM2

	.GLOBAL	STRLNCF,STRRNCF,STRCNCOF,STRLNCOF,STRRNCOF
	.GLOBAL	STRLNCO

	.GLOBAL	STRCNRMOS, STRLNRMS, STRCNRMS, STRRNRMS, STRRNRMOS
	.GLOBAL	STRCNRMOS_SCALE, STRLNRMOS_SCALE, STRRNRMOS_SCALE
	.GLOBAL	L_MESS, LM_SETUP, LM_FINIS
	.GLOBAL	CLRTEXT, HEXTOASC
	.GLOBAL	RD5FONT
	.GLOBAL	RD7FONT, RD11FONT
	.GLOBAL	RD15FONT, SP15FONT, G15FONT
	.GLOBAL	RD20FONT
	.GLOBAL	STRING1, STRING2, STRING3
	.GLOBAL	STRNGLEN
	.GLOBAL	STRNGRAM
	.GLOBAL	STRINGF_RAM
	.GLOBAL	HTOHXASC
	.GLOBAL	STRING_SHADOW
	.GLOBAL	SUFFIX_S, SUFFIX_NULL
	.GLOBAL	PROC_TEXT
	.GLOBAL	FONT150, FONT151, FONT152, FONT153, FONT154, FONT155, FONT156
	.GLOBAL	FONT157, FONT158, FONT159
	.GLOBAL	STRRNRMOF

*
*ASCII FONT MISCELLANEOUS EQUATES
*
F15SP		EQU	80H			;FONT 15 SP CHARACTER, FOR HS ENTRY
F15RUB	EQU	F15SP+1		;FONT 15 RUB CHARACTER,FOR HS ENTRY
F15END	EQU	F15RUB+1		;FONT 15 END CHARACTER,FOR HS ENTRY
F15RQUOT EQU	F15END+1		;FONT 15 RIGHT QUOTE

C_GERA	EQU	"<"			;German Ž
C_GERB	EQU	"["			;German á
C_GERO	EQU	"]"			;German ™
C_GERU	EQU	"^"			;German š
C_GERa	EQU	"_"			;German „
C_GERb	EQU	60H			;German á
C_GERo	EQU	"{"			;German ”
C_GERu	EQU	"|"			;German    
C_TM		EQU	"}"			;TM (TRADEMARK)
C_REG		EQU	"~"			;Circle R (REGISTERED)
C_COPY	EQU	7FH			;Circle C (COPYRIGHT)
*
*STRINGER CONTROL CHARACTERS
NEW_SLEEP	EQU	1	;CHANGE CURRENT SLEEP TIME
NEW_PCOLOR	EQU	2	;CHANGE THE CURRENT PRINT COLOR
NEW_CONTROL	EQU	3	;CHANGE CURRENT DMA CONTROL WORD
NEW_FONT		EQU	4	;CHANGE CURRENT FONT
NEW_XY		EQU	5	;CHANGE CURRENT PRINT POSITION
NEW_SPACING	EQU	6	;CHANGE CURRENT SPACING
ADD_DYDX		EQU	7	;ADD THIS [Y,X] TO THE CURRENT POSITION
NEW_PALETTE EQU	8	;USE NEW PALETTE, SPECIFIED BY I.D.
ASCII_TAB	EQU	9
UNDERLINE_ON	EQU	0AH	; TURN ON UNDERLINING
UNDERLINE_OFF	EQU	0BH	; TURN OFF UNDERLINING
ASCII_CR		EQU	0DH
*
*FLAGS USED BY STRINGER
*
*MASKS
M_TEXTDMA2	.EQU	 4000H
M_TEXTSHAD	.EQU	 8000H
M_TEXTOBJ	.EQU	10000H
M_NOINSERT	.EQU	20000H

M_FIXEDSPC	.EQU	2000H		

*BITS POSITIONS
B_FIXEDSPC	.EQU	13			
B_TEXTDMA2	.EQU	14 
B_TEXTSHAD	.EQU	15
B_TEXTOBJ	.EQU	16
B_NOINSERT	.EQU	17

*
*JUSTIFICATION EQUATES
*
LEFT_JUSTIFY	.EQU	0
CENTER_JUSTIFY	.EQU	1
RIGHT_JUSTIFY	.EQU	2

TEXTZVAL	.EQU	-7c000000H		;DEFAULT Z VALUE FOR TEXT OBJECTS	FIX 9/14/92

**************************************************************************
*                                                                        *
* PCOLOR - CHANGE TO A NEW PRINT COLOR					 *
*                                                                        *
**************************************************************************
PCOLOR	.macro	COLOR
	.BYTE	NEW_PCOLOR
	.WORD	:COLOR:
	.endm

**************************************************************************
*                                                                        *
*          MESS_MAC                                                      *
*                                                                        *
*          THIS MACRO IS USED TO SETUP AN "L_MESS" MESSAGE.              *
*          THE MESSAGE FOLLOWS THE MACRO.                                *
*          ZERO TERMINATES THE MESSAGE.                                  *
*          ANOTHER ZERO TERMINATES L_MESS.                               *
*                                                                        *
*          A "1" AFTER THE TERMINATING "0" WILL CAUSE                    *
*          L_MESS TO PRINT OUT ANOTHER MESSAGE.                          *
*                                                                        *
**************************************************************************

MESS_MAC .macro  FONT,SPACING,X,Y,COLOR,ROUTINE,CHAROID
         .LONG	:FONT:
         .LONG	:SPACING:
			.WORD	:X:	
			.WORD	:Y:
         .LONG	:COLOR:
         .LONG	:ROUTINE:
         .LONG	:CHAROID:
         .endm

SPACING20        EQU     2
SPACING07        EQU     1


