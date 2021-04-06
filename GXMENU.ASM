      	.MLIB	"GXMACS.LIB"
	.FILE	"GXMENU.ASM"
	.TITLE	"<<< GENERATION X - MENU ROUTINES >>>"
	.WIDTH	132
	.OPTION	B,D,L,T
	.MNOLIST

**************************************************************************
*								         *
* 	COPYRIGHT (C) 1992 MIDWAY MANUFACTURING COMPANY.		 *
* 		       ALL RIGHTS RESERVED.				 *
*								         *
**************************************************************************

	.INCLUDE	"GX.INC"
	.INCLUDE	"GXSTRING.H"
	.INCLUDE	"GXDICT.H"
	.INCLUDE	"IMGTBL.GLO"

*SYMBOLS IN THIS MODULE

	.DEF	P_FORK, ROM_NAME, WAIT_BUT, DIAG, CPU_RET
	.DEF	ST_STICK, GETSTICK, MESS_MM, MENU_TOP, STD_BORD, B_MENU
	.DEF	BLNKHELP, COL_INST, H_SLAVE
	.DEF	CKDIAG, CKTEST, DIGSRT
	.DEF	SET_AVGWAVE, SCR_BOX_OBJ, SCR_REV_OBJ, MESS_TITLE
	.DEF	UHOH, BEEP_1, FORM_SWS, ANY_BUT
	.DEF	GET_PLAYS, LASTCOLOR
	.DEF	BLASTMESS, M_CALIBRATE, MESS_DRIVER, OCTO_AUDS

	.GLOBAL	TOP_BOX

	.IF	PRINTER
	.DEF	PRINTAUDTABLE
	.DEF	PRINTCOINTABLE
	.ENDIF
*SYMBOLS IN AP.ASM
	.REF	DIPINIT, WIPEOUT, WARMSET
	.REF	SLEEP_SWITCHX
*SYMBOLS IN APCONTRL.ASM
	.REF	GO_DRIVER, GO_CALIBRATE, RECOIL_OFF
*SYMBOLS IN APCMOS.ASM
	.REF	DUMP_FS, DISPDUMP
	.REF	FORM_ADC, CMOS_VAL, FAC_SET, F_ADC_S, CLR_AUD
*SYMBOLS IN APUTIL.ASM
	.REF	FILLAREA
*SYMBOLS IN APMISC.ASM
	.REF	COLOR_START
*SYMBOLS IN APHSTD.ASM
	.REF	INIT_TB, INIT_HSR, ALL_TAB, WC_WORD, GET_HSC, WC_BYTEI
*SYMBOLS IN APADJ.ASM
	.REF	GO_ADJ, DO_ADJH, MEN_ADJ, CKDIP, GET_CSPT
*SYMBOLS IN APRAM.ASM
	.REF	GAME_STATE, VALIDATOR
*SYMBOLS IN APCOIN.ASM
	.REF	NO_CREDS, GAMEUNITS, CAT_A0, STRCAT
*SYMBOLS IN APDTST.ASM
	.REF	DIAGCPUTEST, BURNIN, READ_DIP

	.IF	PRINTER
*SYMBOLS IN APPRNT.ASM
	.REF	PRINTAUDS,PBADGUY
	.ELSE
*SYMBOLS IN APDTST.ASM
	.REF	SWITCHTEST, CONV_PLOT, DIPTEST
	.REF	COLORBAR
	.ENDIF
*SYMBOLS IN GXTEXT.ASM
	.REF	HEX_TO_ASCII_DEC

*SYMBOLS IN GXSND.ASM
	.REF	SOUND_RX
*
*        MAIN_RET
*
*        POSITIVE NUMBER HERE SAYS RETURN (UPWARD) TO MAIN MENU (GEN_MENU ONLY)
*        NEGATIVE NUMBER HERE SAYS SETUP RESTORE AFTER RAM TEST. (GEN_MENU)
*
	.BSS	MAIN_RET,16		;FLAG SAYS RETURN TO MAIN MENU
	.BSS	GMENULEV,16		;HOW DEEP INTO GEN_MENU WE ARE
	.BSS	SND_MADE,16		;SOUND TEST FLAG
	.BSS	NO_CLEAR,16		;FLAG TELLS GET_MENU NOT TO CLEAR!
	.BSS	SCODE,16
	.BSS	DCODE,16
	.BSS	FAC_FLAG,16		;FLAG SAYS CLEAR AUDITS AND HSTABLE
	.BSS	CHAROUT,16
	.BSS	BLINE,16
	.BSS	BCHAR,16
	.BSS	PTSIZE,16		; BOGUS 15 PT FONT FLAG
	.BSS	UNUSED_WORD1,16		;For alignment purposes

	.BSS	LAST_BUT,32
	.BSS	SWSET1,32
	.BSS	SWSET2,32
	.BSS	LASTCOLOR,32

	.BSS	_serial_number,32
	.BSS	_month,32
	.BSS	_day,32
	.BSS	_year,32
	.BSS	_volume_level,32

	.bss	_in_volume_adjust,32
	.globl	_cabinet_type
	.bss	_cabinet_type,32
	.globl	_in_driver_test
	.bss	_in_driver_test,32

         .TEXT

	.globl	DIAG_UP, DIAG_DOWN, DIAG_ENTER, DIAG_ESCAPE

DIAG_UP:
	.WORD	0F2FFH, 30, 083d4H, 0
DIAG_DOWN:
	.WORD	0F2FFH, 30, 083d5H, 0
DIAG_ENTER:
	.WORD	0F2FFH, 30, 083d6H, 0
DIAG_ESCAPE:
	.WORD	0F2FFH, 30, 083d7H, 0
VOL_ADJUST_SOUND:
	.WORD	0F0FFH, 30, 083e8H, 0
SOUNDS_OFF
	.WORD	0F07FH, 1, 043e3H
	.WORD	0F17FH, 1, 043e4H
	.WORD	0F27FH, 1, 043e5H
	.WORD	0F37FH, 1, 043e6H, 0
GET_VERSION_SOUND:
	.WORD	0F0FFH, 1, 083e7H,0

;XUNIT START

READ_SW1_CNS:
	move	@SWITCH,a0
	move	@COINS,a14
	sll	16,a14
	movy	a14,a0
	RETS

READ_SW2_DIP:
	move	@SWITCH2,a0
	move	@DIPSWITCH,a14
	sll	16,a14
	movy	a14,a0
	RETS

**************************************************************************
*								         *
* 	READ_SW1_SW2							 *
* 									 *
* 	Combine the locations SWITCH and SWITCH2 into one		 *
* 	LONG word looking like this [SWITCH2,SWITCH]			 *
*								         *
**************************************************************************
READ_SW1_SW2
	move	@SWITCH,a0
	move	@SWITCH2,a14
	sll	16,a14
	movy	a14,a0
	RETS

;XUNIT END



	.IF	PRINTER
GO_PRINT
	JAUC	PRINTAUDS
	.ENDIF

**************************************************************************
*								         *
* 	DIAG								 *
* 									 *
* 	PROCESS STARTED WHEN DIAG SWITCH IS HIT				 *
* 									 *
* 	ENTRY								 *
* 		NOTHING							 *
* 									 *
* 	EXIT								 *
* 		WARMBOOTS THE PROCESSOR					 *
*								         *
**************************************************************************
DIAG
	move	@COINS,a14,L
	not	a14
	btst	13,a14
	janz	SUCIDE
	SOUNDON
	MOVE	@GAME_STATE,A0,W
	CMPI	INDIAG,A0
	JAEQ	SUCIDE
	CMPI	INAMODE,A0
	JREQ	DIAG_JUMP
	CMPI	INGAMEOV,A0
	JREQ	DIAG_JUMP

	AUDIT	AUDSTOCKINGS		;Click audit to show bogusness

DIAG_JUMP
	SOUND1	SOUNDS_OFF

	clr	a14
	move	a14,@_in_volume_adjust,1
	callr	READ_DIP
	andi	02000h,a0
	jrz	_x_cab
	movk	1,a0
_x_cab:
	move	a0,@_cabinet_type,L
	CLR	A0
	MOVE	A0,@PTSIZE,W		;EVERYTHING IN 7PT
	CALLR	DIGSRT			;MAKE SURE WE'RE IN TEST MODE

	.IF	PRINTER
	MOVK	8,A0
	CALLA	PBADGUY			;ENTERING TEST MODE
	.ENDIF
	CLR	A0
	MOVE	A0,@MAIN_RET,W		;CLEAR THE FLOAT TO TOP FLAG.
	MOVE    A0,@GMENULEV,W		;INDICATE WE'RE AT LEVEL ZERO.

DIAG_RESTART
	MOVI	MEN_MAIN,A8
	JSRP	GEN_MENU		;PROCESS THIS MENU!

**************************************************************************
*								         *
* 	DIAG_EX								 *
* 									 *
* 	DIAGNOSTIC EXIT							 *
* 									 *
* 	ENTRY								 *
* 		NOTHING							 *
* 									 *
* 	EXIT								 *
* 		NOTHING							 *
*								         *
**************************************************************************
DIAG_EX:
	SLEEP	2
	CALLA	CLR_SCRN
	CALLA	CMOS_VAL		; VALIDATE THE CMOS
;Removed for momentary coin door test switch operation
;	CALLA	CKTEST
	CALLA	READ_DIP
	ANDI	DPTEST,A0
	JRZ	DE2
	MOVI	NOTCLOSEDDIP,A8
	CALLA	LM_SETUP
	JSRP	PRINTF
	jruc	DE3
DE2
	CALLR	READ_SW1_CNS		; XUNIT
	NOT	A0
	ANDI	00100000H,A0
	JAZ	WARMSET
	MOVI	NOTCLOSEDJAMMA,A8
	CALLA	LM_SETUP
	JSRP	PRINTF
DE3
	MOVI	NOTCLOSEDWAIT,A8
	CALLA	LM_SETUP
	JSRP	PRINTF
	CALLR	READ_SW1_CNS		; XUNIT HANGOUT FOR A WHILE
	ANDI	1E643030H,A0
	MOVE	A0,@SWSET1,L
	CALLR	READ_SW2_DIP		; XUNIT
	ANDI	00003030H,A0
	MOVE	A0,@SWSET2,L
DE4
	SLEEP	1			;APPEASE THE MAIN LOOP
;	CALLR	CKTEST			;CHECK STATUS OF TEST SWITCH
	CALLR	READ_SW1_CNS		; XUNIT GOTTA SEE IF TIME TO LEAVE
	MOVE	@SWSET1,A1,L
	MOVE	A0,A3			;SAVE A COPY AROUND
	ANDI	1E643030H,A0
	ANDI	1E643030H,A1
	CMP	A0,A1
	JRNZ	DE5
	CALLR	READ_SW2_DIP		; XUNIT
	MOVE	A0,A4			;SAVE A COPY

	MOVE	@SWSET1,A2,L
	ANDI	00003030H,A1
	ANDI	00003030H,A3
	CMP	A1,A3
	JRNZ	DIAG_EX			; WELL ONE OF THEM IS OPEN NOW
	MOVE	@SWSET2,A1,L
	ANDI	DPTEST << 16,A1
	ANDI	DPTEST << 16,A4
	CMP	A1,A4
	JRNZ	DIAG_EX
	JRUC	DE4
DE5
;	CALLR	CKTEST			; ONE FINAL TIME ( STILL WRONG )
	JRUC	DIAG_JUMP

NOTCLOSEDDIP
	MESS_MAC RD7FONT,SPACING07,200,50,COLOR_PRED,STRCNRM,0
	.STRING	W_DIPSWITCH," ",W_TEST," SELECT (U108 # 8) ",W_CLOSED,".",0
	.EVEN

NOTCLOSEDJAMMA
	MESS_MAC RD7FONT,SPACING07,200,70,COLOR_PRED,STRCNRM,0
	.STRING	W_COIN," DOOR ",W_TEST," ",W_SWITCH," ",W_CLOSED,".",0
	.EVEN

NOTCLOSEDWAIT
	MESS_MAC RD7FONT,SPACING07,200,120,COLOR_PRED,STRCNRM,0
	.STRING	"PRESS ANY ",W_BUTTON," TO ",W_RETURN," TO ",W_TEST," MODE\nOR"
	.STRING	"\nOPEN THE ",W_SWITCH,"(S) TO ",W_RETURN," TO ",W_GAME,".",0
	.EVEN

**************************************************************************
*                                                                        *
*          DIGSRT                                                        *
*                                                                        *
*          THIS IS CALLED ON ENTRY TO DIAGNOSTICS.                       *
*                                                                        *
**************************************************************************
DIGSRT
	CALLR	DIAG_STATE
	CALLA	WIPEOUT		;INITIALIZE THE OBJECT LIST
	PAGEOFF			;MAKE SURE PAGE FLIPPING IS OFF
	CALLA	COLOR_START	;START UP THE COLOR PROCESSES
	CALLA	DIPINIT		;INITIALIZE WHAT WE CAN FROM THE DIPS
	MOVK	1,A0
	MOVE	A0,@DISPLAYON,W	;WE NEED TO SEE THE STUFF JACK

	movi	DPYSTRT0,a14	; XUNIT
	move	a14,@DPYST,L	; XUNIT

	CALLA	CLR_SCRN	;CLEAR THE SCREEN!

	RETS

**************************************************************************
*								         *
* 	DIAG_STATE							 *
* 									 *
* 	GET EVERYTHING SETUP/KILLED OFF FOR DIAG STATE			 *
* 									 *
* 	ENTRY								 *
* 		NOTHING							 *
* 									 *
* 	EXIT								 *
* 		NOTHING							 *
*								         *
**************************************************************************
DIAG_STATE 
	CLR	A1
	CALLA	KILALL			;KILL ABSOLUTELY EVERYONE!
	CALLA	RECOIL_OFF		;TURN THE GUN RECOILS OFF

	MOVI	PID_DIAG,A1		;SET OUR ID TO DIAGNOSTICS MAN
	MOVE	A1,*A13(PROCID),W	;PASS OUR ID TO FORKED PROCESS

	MOVI	INDIAG,A0
	MOVE	A0,@GAME_STATE,W	;PUT US IN TEST MODE!
	RETS

**************************************************************************
*								         *
* 	GO_DIAG								 *
* 									 *
* 	ENTER THE DIAGNOSTICS MENU					 *
*								         *
**************************************************************************

	.IF	PRINTER
	.ELSE

GO_DIAG
	MOVI	MEN_DIAG,A8		;PUT UP THE MENU AND GO!
	JAUC	GEN_MENU		;THIS WILL RETURN TO LEVEL ABOVE US!

GO_SWITCH
	MMTM	SP,A12,A13
	DISPOFF
	CALLA	CLR_SCRN
	CALLA	SWITCHTEST
	CLRM	@TIMER,W
	SOUND1	DIAG_ESCAPE
	MMFM	SP,A12,A13
DIAG_RESTORE
	CALLA	CLRDMAQ
	CALLA	MYOINIT
	DISPON
	CALLA	CLR_SCRN
	RETP

GO_DIP
	MMTM	SP,A12,A13
	DISPOFF
	CALLA	CLR_SCRN
	MOVKM	1,@_in_volume_adjust,L
	CALLA	DIPTEST
	CLRM	@_in_volume_adjust,L
	CLRM	@TIMER,W
	SOUND1	DIAG_ESCAPE
	CALLA	DIPINIT
	MMFM	SP,A12,A13
	JRUC	DIAG_RESTORE

	.ENDIF

GO_CPU
	DISPOFF
	JAUC	DIAGCPUTEST

GO_BURN
	DISPOFF
	JAUC	BURNIN

CPU_RET
	CLR	A0
	MOVE	A0,@GMENULEV,W	;INDICATE WE'RE AT LEVEL ZERO.

	.IF	PRINTER
	.ELSE
	MOVI	RTR_LEV,A0	;THIS IS THE LEVEL TO DIVE TO
	NEG	A0		;NEGATE IT AS FLAG TO DIVE.
	MOVE	A0,@MAIN_RET,W	;INDICATE
	.ENDIF
	PAGEOFF			;MAKE SURE PAGE FLIPPING IS OFF
	JAUC	DIAG_RESTART	;NOW START IT UP....

	.IF	PRINTER
	.ELSE
GO_CONV
	MMTM	SP,A12,A13
	DISPOFF
	CALLA	CLR_SCRN
	CALLA	CONV_PLOT

;	SOUND1	DIAG_ESCAPE

	MMFM	SP,A12,A13
	JSRP	WAIT_BUT	;NOW WAIT FOR ANY BUTTON!
	JRUC	DIAG_RESTORE

GO_BARS
	MMTM	SP,A12,A13
	DISPOFF
	CALLA	CLR_SCRN
	CALLA	COLORBAR

;	SOUND1	DIAG_ESCAPE

	MMFM	SP,A12,A13
	JSRP	WAIT_BUT	;NOW WAIT FOR ANY BUTTON!
	JRUC	DIAG_RESTORE

	.ENDIF

**************************************************************************
*								         *
* 	OPERATOR MESSAGE ENTRY						 *
*								         *
**************************************************************************

OP_LINE_CHAR	EQU	PDATA
OP_LINE_LINE	EQU	PDATA+WORD_SIZE
OP_LETS		EQU	OP_LINE_LINE+WORD_SIZE
OP_STIME      	EQU	OP_LETS+(30 * BYTE_SIZE)
OP_SVAL		EQU	OP_STIME+WORD_SIZE

LET_DIST_X	EQU	25
LET_DIST_Y	EQU	20
LET_BOX_CX	EQU	6
LET_BOX_CY	EQU	3
LET_BOX_WX	EQU	3
LET_BOX_WY	EQU	1
LET_START_Y1	EQU	175
LET_START_Y2	EQU	LET_START_Y1+LET_DIST_Y
LET_START_Y3	EQU	LET_START_Y2+LET_DIST_Y
LET_START_Y4	EQU	LET_START_Y3+LET_DIST_Y
LET_INST1	EQU	60
LET_START_X	EQU	15
LET_LINE_MAX	EQU	3
LET_CHAR_MAX	EQU	14
LET_TEXT_GAP	EQU	11
LET_TEXT1	EQU	120
LET_TEXT2	EQU	LET_TEXT1+LET_TEXT_GAP
LET_TEXT3	EQU	LET_TEXT2+LET_TEXT_GAP
OP_MAX_CHARS	EQU	CMESS_CHARS

	.IF	0	;OPERATOR MESSAGE TAKEN OUT 
DO_OPMESS:
	CALLA	CLR_SCRN
         MOVI    M_SET_OMESS,A8       ;SET OPERATOR MESSAGE...ARE YOU SURE
         MOVI    OPGOFORIT,A9        ;GEORGE'S ENTRY POINT
         MOVI    NULL_ST,A10          ;THIS WILL NEVER BE SEEN!
         JAUC    AREUSURE             ;ASK EM.

OPGOFORIT
	.IF	PRINTER
	MOVK	1,A0
	CALLA	PBADGUY
	.ENDIF
	CALLA	CLR_SCRN
        MOVI    U_OPMESS,A2
        MOVI    COLOR_YELLOW,A3
        JSRP    TOP_BOX			; KICK OUT TOP BOX
	MOVI	OMINST1,A8
	CALLA	LM_SETUP
	JSRP	PRINTF
	CLR	A8			; DO THE THREE ROWS OF LETTERS
	MOVI	0FFH,A10
	CALLR	OPPLOTLINE
	MOVK	1,A8
	MOVI	0FFH,A10
	CALLR	OPPLOTLINE
	MOVK	2,A8
	MOVI	0FFH,A10
	CALLR	OPPLOTLINE
	MOVK	3,A8
	MOVI	0FFH,A10
	CALLR	OPPLOTLINE
	CLR	A0
	MOVE	A0,@BLINE,W
	MOVE	A0,@BCHAR,W
	CLR	A8
	MOVE	A8,*A13(OP_LINE_LINE),W	; ON THE FIRST LINE
	CALLR	OMSTARTLINE		; INITIALIZE ALL THE FLAGS FOR IT
	CLR	A10
	MOVK	1,A11
	CALLR	BOXCHAR			; BOX INITIAL ONE
	MOVK	1,A11
	CALLR	OMPLOTTEXT
;
;	LOOP FOR STICK AND THINGS
;
	CLR	A0
	MOVE	A0,*A13(OP_SVAL),W
	MOVE	A0,*A13(OP_STIME),W
DOLOOP
	SLEEP   1
        CALLR   OPGETSTICK		; CHECK OUT THE PLAYER BOARD
        MOVE    A0,A0
	JRNZ	DO1			; BR = GOT SOMETHING
	MOVE	A0,*A13(OP_SVAL),W	; CLEAR TIMER AND DIRECTION
	MOVE	A0,*A13(OP_STIME),W
	JRUC	DOLOOP
DO1
	MOVE	*A13(OP_SVAL),A1,W	; GET LAST DIRECTION
	ANDI	7,A1			; MASK OFF REPEAT BIT
	CMP	A0,A1
	JRZ	DO2			; BR = YES, STILL SAME THING
	MOVE	A0,*A13(OP_SVAL),W
	CLR	A1
	MOVE	A1,*A13(OP_STIME),W	; CLEAR THE TIMER
	JRUC	DODONE			; PROCESS INITIAL HIT
DO2
	MOVE	*A13(OP_SVAL),A1,W	; SNAG THE REPEAT BIT
	ANDI	80H,A1
	JRNZ	DO3			; BR = IN REPEAT MODE
	MOVE	*A13(OP_STIME),A0,W	; GET TIMER
	INC	A0
	MOVE	A0,*A13(OP_STIME),W
	CMPI	15,A0
	JRLO	DOLOOP			; GO BACK TO SLEEP
	CLR	A0
	MOVE	A0,*A13(OP_STIME),W	; CLEAR OUT THE TIMER
	MOVE	*A13(OP_SVAL),A1,W
	MOVE	A1,A0
	ORI	80H,A1			; PUT UPPER BIT ON
	MOVE	A1,*A13(OP_SVAL),W	; SET DIRECTION WITH REPEAT ON
	JRUC	DODONE
DO3
	MOVE	*A13(OP_STIME),A0,W	; GET TIMER
	INC	A0
	MOVE	A0,*A13(OP_STIME),W
	CMPI	5,A0
	JRLO	DOLOOP			; GO BACK TO SLEEP
	CLR	A0
	MOVE	A0,*A13(OP_STIME),W	; CLEAR OUT THE TIMER
	MOVE	*A13(OP_SVAL),A0,W
	ANDI	7H,A0			; TURN OFF REPEAT BIT
DODONE
        MOVE    *A13(OP_SVAL),A1,W        ;GET CURRENT ENTRY...IN A1
	ANDI	7,A1
	MOVE	@BLINE,A8,W
	MOVE	@BCHAR,A10,W
	CLR	A11
	CALLR	BOXCHAR			; UNHIGHLIGHT IT

	CMPI	1,A1			; CHECK UP
	JRNZ	DOC1
	DEC	A8
	JRUC	DOPROC
DOC1
	CMPI	2,A1
	JRNZ	DOC2
	INC	A8
	JRUC	DOPROC
DOC2
	CMPI	3,A1
	JRNZ	DOC3
	DEC	A10
	JRUC	DOPROC
DOC3
	CMPI	4,A1
	JRNZ	DOC4
	INC	A10
	JRUC	DOPROC
DOC4
	CMPI	5,A1			; DRAW BUTTON
	JRNZ	DOCCLR			; WOOF WOOF
	CALLR	OMADDCHAR		; ADD THE CHAR IN A8/A10
	CMPI	0FFH,A8			; CHECK TO SEE IF DONE WITH ALL
	JRZ	DOCEND
	MOVE	@BLINE,A8,W
	MOVE	@BCHAR,A10,W
	MOVK	1,A11
	CALLR	BOXCHAR			; TURN THE BOX BACK ON
	JRUC	DOLOOP
DOCCLR
	CMPI	6,A1			; START BUTTON
	JRNZ	DOLOOP
	CLR	A7
	MOVE	A7,*A13(OP_LINE_LINE),W
	MOVE	A7,*A13(OP_LETS),L
	CALLR	OMSTORECMOS
	MOVK	1,A7
	MOVE	A7,*A13(OP_LINE_LINE),W
	CALLR	OMSTORECMOS
	MOVK	2,A7
	MOVE	A7,*A13(OP_LINE_LINE),W
	CALLR	OMSTORECMOS
	CALLR	BLASTMESS
	JRUC	DOCCLEAR
	
;
;	CHECK A8 ( BLINE ) AND A10 ( BCHAR ) FOR BOUNDARY STUFF
;
DOPROC
	MOVE	A8,A8
	JRNN	DOC5
	CLR	A8
	JRUC	DOC6
DOC5
	CMPI	LET_LINE_MAX,A8
	JRLE	DOC6
	MOVI	LET_LINE_MAX,A8
DOC6
	MOVE	A10,A10
	JRNN	DOC7
	CLR	A10
	JRUC	DOC8
DOC7
	CMPI	LET_CHAR_MAX,A10
	JRLE	DOC8
	MOVI	LET_CHAR_MAX,A10
DOC8
	MOVE	A8,@BLINE,W
	MOVE	A10,@BCHAR,W
	MOVK	1,A11
	CALLR	BOXCHAR
	JRUC	DOLOOP

;
;	HERE IS WHERE ONE COMES WHEN DONE ENTERING THE MESSAGE -- ALREADY
;	STORED IN CMOS, TOO
;

DOCEND
	SLEEP	2			; GET EVERYBODY CAUGHT UP
	CALLA   CLR_SCRN                       ;CLEAR THE SCREEN
	MOVI    MESS_SUCCESS,A8                ;THIS IS SUCCESS MESSAGE
	JSRP    SUR_MESS                       ;PRINT THE MESSAGE	
	RETP

DOCCLEAR
	SLEEP	2
	CALLA	CLR_SCRN
	MOVI	MESS_CLEARED,A8
	JSRP	SUR_MESS
	RETP

MESS_SUCCESS
	.STRING	W_MESSAGE," STORED",0
	.EVEN

MESS_CLEARED
	.STRING	W_MESSAGE," ",W_CLEAR,"ED",0
	.EVEN

	.ENDIF

BLASTMESS:
	CALLA	CMOSUNLOCK
;XUNIT        CALLA   ADJ_PAGE		; GUY ENTERETED A WHOLE MESSAGE
	CLR	A0
        MOVI    VALID_CUSTOM,A7
        CALLA   WC_WORD
	CALLA	CMOSLOCK
        CALLA   F_ADC_S			; FIX UP THE CHECKSUM
	RETS

	.IF	0
**************************************************************************
*								         *
* 	OPGETSTICK							 *
*								         *
**************************************************************************
OPGETSTICK
	MMTM	SP,A1
	CALLR	READ_SW1_CNS		; XUNIT 
	NOT	A0
	MOVE	A0,A2
	ANDI	00040030H,A0		; P1 START/BOMB/FIRE
	MOVE	A2,A1
	ANDI	00203000H,A1		; P2 START/BOMB/FIRE
	SRL	8,A1
	OR	A1,A0

	BTST	18,A0			;PLAYER 1 START IS UP
	JRZ	OG2

	MOVK	1,A0
	JRUC	OGRET
OG2
	BTST	13,A0			;PLAYER 2 START IS DOWN
	JRZ	OG3
	MOVK	2,A0
	JRUC	OGRET
OG3
****	MOVE	A0,A1
****	ANDI	04H,A1
****	JRZ	OG4
****	MOVK	3,A0
****	JRUC	OGRET
****OG4
****	MOVE	A0,A1
****	ANDI	08H,A1
****	JRZ	OG5
****	MOVK	4,A0
****	JRUC	OGRET
OG5
	BTST	P1TRIGGER,A0
	JRZ	OG6
	MOVK	5,A0
	JRUC	OGRET
OG6
	BTST	P1BOMB,A0
	JRZ	OG7
	MOVK	6,A0
	JRUC	OGRET
OG7
	CLR	A0
OGRET
	MMFM	SP,A1
	RETS

**************************************************************************
*								         *
* 	OMSTARTLINE							 *
* 									 *
* 	SETUP THINGS FOR A NEW LINE OF TEXT				 *
* 									 *
* 	ENTRY								 *
* 		NOTHING							 *
* 									 *
* 	EXIT								 *
* 		NOTHING							 *
*								         *
**************************************************************************

OMSTARTLINE:
	PUSH	A0
	CLR	A0
	MOVE	A0,*A13(OP_LETS),W
	MOVE	A0,*A13(OP_LINE_CHAR),W
	PULL	A0
	RETS

**************************************************************************
*								         *
* 	OMPLOTTEXT							 *
* 									 *
* 	PLOT OUT A LINE OF TEXT ON THE SCREEN				 *
* 									 *
* 	ENTRY								 *
* 		NOTHING ( WELL, ALMOST )				 *
* 									 *
* 	EXIT								 *
* 		NOTHING							 *
*								         *
**************************************************************************

OMPLOTTEXT:
	MMTM	SP,A8,A10,A11
	PUSH	A11
	MOVI	OMTSETUP,A8
	CALLA	LM_SETUP
	MOVE	A13,A8
	ADDI	OP_LETS,A8
	MOVE	*A13(OP_LINE_LINE),A9,W
	SLL	5,A9
	ADDI	OMLOC,A9
	MOVE	*A9,A9,L
	SLL	16,A9
	MMTM	SP,A3,A4,A9
	MOVE	A9,A3
	SUBI	20000H,A3
	MOVI	[LET_TEXT_GAP+2,394],A4
	CALLA	BLNKAREA
	MMFM	SP,A3,A4,A9
	ADDI	200,A9
	JSRP	PRINTF
	PULL	A5
	MOVE	A5,A5			; FLAG FOR UNDERSCORE OR NOT
	JRZ	NOUNDER
	MOVI	COLOR_PLF,A5
	MOVI	OMUNDERSCORE,A8
	ADDI	5,A9			; SHIFT THE LITTLE GUY OVER
	JSRP	PRINTF
NOUNDER
	MMFM	SP,A8,A10,A11
	RETS

**************************************************************************
*								         *
* 	OMADDCHAR							 *
* 									 *
* 	ADD THE CHARACTER POINTED TO BY A8/A10				 *
* 									 *
* 	ENTRY								 *
* 		A8	LINE						 *
* 		A10	CHAR ON LINE					 *
* 									 *
* 	EXIT								 *
* 		NOTHING							 *
*								         *
**************************************************************************

OMADDCHAR:
	MMTM	SP,A8,A10
	MOVE	A8,A0
	SLL	16,A0
	ADD	A10,A0
	CMPI	[3,13],A0		; RUB
	JRNZ	OMAC1
	MOVE	*A13(OP_LINE_CHAR),A1,W
	JRZ	OMACRET
	DEC	A1
	MOVE	A1,*A13(OP_LINE_CHAR),W
	MOVE	A1,A2
	CLR	A0
	JRUC	RUBENT

OMAC1
	CMPI	[3,14],A0		; CR
	JRNZ	OMAC2
	CLR	A11
	CALLR	OMPLOTTEXT		; GET RID OF THE FLASHING UNDERSCORE
	CLR	A0
	MOVE	A0,@BLINE,W
	MOVE	A0,@BCHAR,W
	CALLR	OMSTORECMOS		; WELL, BABY -- STORE IT
	MOVE	*A13(OP_LINE_LINE),A8,W	; GRAB THE LINE
	CMPI	2,A8
	JRHS	OMADONE
	INC	A8
	MOVE	A8,*A13(OP_LINE_LINE),W	; ON THE FIRST LINE
	CALLR	OMSTARTLINE		; INITIALIZE ALL THE FLAGS FOR IT
	MOVK	1,A11
	CALLR	OMPLOTTEXT
	JRUC	OMACRET
;
;	HERE IS JUST ENTER A NORMAL CHARACTER --
;
;	A8 = LINE
;	A10 = CHARACTER
;
OMAC2
	SLL	5,A8
	ADDI	OLTAB,A8		; GET TABLE BASE ADDRESS
	MOVE	*A8,A8,L
	SLL	3,A10			
	ADD	A10,A8			; CHAR OFFSET
	MOVB	*A8,A0			; SNAG THE CHAR
	MOVE	*A13(OP_LINE_CHAR),A1,W
	MOVE	A1,A2
	CMPI	OP_MAX_CHARS,A1
	JRHS	OMACMAX
	INC	A1
	MOVE	A1,*A13(OP_LINE_CHAR),W
RUBENT
	CMPI	7EH,A0			; CHECK FOR THE SPACE CHARACTER
	JRNZ	OMNOTSPACE
	MOVI	20H,A0
OMNOTSPACE
	MOVE	A13,A8
	ADDI	OP_LETS,A8
	SLL	3,A2
	ADD	A2,A8			; OFFSET INTO LOCAL STORAGE
	MOVB	A0,*A8
	ADDK	8,A8
	CLR	A0
	MOVB	A0,*A8			; MAKE SURE ZERO TERMINATED
	MOVK	1,A11
	CALLR	OMPLOTTEXT
OMACRET	
	MMFM	SP,A8,A10
	RETS

OMADONE				; COME HERE WHEN REALLY DONE
	CALLA	CMOSUNLOCK
;XUNIT        CALLA   ADJ_PAGE		; GUY ENTERETED A WHOLE MESSAGE
        MOVI    VALID_CUSTOM,A7
        MOVI    VALID_VALUE,A0
        CALLA   WC_WORD
	CALLA	CMOSLOCK
        CALLA   F_ADC_S			; FIX UP THE CHECKSUM
	MMFM	SP,A8,A10
	MOVI	0FFH,A8			; FLAG DONE WITH EVERYTHING
	RETS

OMACMAX
	MMFM	SP,A8,A10		; LIKE TOTALLY GROSS, MAN...
	CLR	A11
	CALLR	BOXCHAR
	MOVK	3,A8
	MOVK	14,A10
	MOVE	A8,@BLINE,W
	MOVE	A10,@BCHAR,W
	RETS


**************************************************************************
*								         *
* 	OMSTORECMOS							 *
* 									 *
* 	STORE THE MESSAGE IN CMOS					 *
* 									 *
* 	ENTRY								 *
* 		NOTHING							 *
* 									 *
* 	EXIT								 *
* 		NOTHING							 *
*								         *
**************************************************************************

OMSTORECMOS:
	CALLA	CMOSUNLOCK
;XUNIT	CALLA	ADJ_PAGE		; POINT AT ADJUSTMENTS PAGE
	MOVE	*A13(OP_LINE_LINE),A7,W
	MOVI	CMESS_LINE_SIZE,A6
	MPYU	A6,A7			; OFFSET ME, BABY
	ADDI	CUSTOM_MESSAGE,A7	; A7 IS CMOS LOCATION
	MOVE	A13,A6
	ADDI	OP_LETS,A6		; A6 IS THE PROCESS BLOCK LOC
	MOVI	CMESS_CHARS,A5		; CHARS/LINE

CMOS_LOOP
        MOVB    *A6,A0                         ;FETCH A CHARACTER
        ANDI    BYTE_MASK,A0
        CALLA   WC_BYTEI                       ;WRITE A BYTE
        ADDI    BYTE_SIZE,A6                   ;POINT AT NEXT BYTE
        DSJS    A5,CMOS_LOOP

	CALLA	CMOSLOCK
        CALLA   F_ADC_S                        ;REFRESH CHECKSUM
	RETS

OMLOC	.LONG	LET_TEXT1, LET_TEXT2, LET_TEXT3

**************************************************************************
*								         *
* 	BOXCHAR								 *
* 									 *
* 	ENTRY								 *
* 		A8	WHICH LINE ( 0 - 2 )				 *
* 		A10 	CHARACTER ON LINE				 *
* 		A11	COLOR TO USE ( 0 = BLACK, 1 = LASER FLASH )	 *
* 									 *
* 	EXIT								 *
* 		NOTHING							 *
*								         *
**************************************************************************

BOXCHAR:
	MMTM	SP,A1,A8,A10
	MOVI	LET_DIST_Y,A1
	MPYU	A8,A1				; DISTANCE
	ADDI	LET_START_Y1-LET_BOX_CY,A1
	SLL	16,A1
	MOVE	A1,A4
	MOVI	LET_DIST_X,A1
	MPYU	A10,A1
	ADDI	LET_START_X-LET_BOX_CX,A1
	MOVX	A1,A4				; UPPER LEFT IN A4
	MOVE	A4,A5	
	MOVI	[LET_DIST_Y+LET_BOX_WY,LET_DIST_X+LET_BOX_WX],A0
	ADDXY	A0,A5				; LOWER RIGHT IN A5

	MOVI	[1,1],A0			; BORDER HEIGHT,WIDTH
	MOVI	COLOR_BLACK,A9			; DOBORDER IS RETARDED
	MOVE	A11,A11
	JRZ	BC1
	MOVI	COLOR_LF,A9
BC1
	CALLR	DOBORDER

	MOVE	A11,A11
	JRNZ	BC2
	MOVI	0FFH,A10
BC2
   	CALLR	OPPLOTLINE
	MMFM	SP,A1,A8,A10
	RETS

**************************************************************************
*								         *
* 	OPPLOTLINE							 *
* 									 *
* 	PLOT OUT A LINE OF CHARACTERS					 *
* 									 *
* 	ENTRY								 *
* 		A8	TABLE NUMBER					 *
* 		A10	WHICH CHARACTER TO HIGHLIGHT			 *
* 									 *
* 	EXIT								 *
* 		NOTHING							 *
*								         *
**************************************************************************

OPPLOTLINE:
	MMTM	SP,A8,A9,A10,A11
	MOVE	A8,A9
	SLL	5,A8
	ADDI	OLTAB,A8
	MOVE	*A8,A8,L
	SLL	4,A9
	ADDI	OLYTAB,A9
	MOVE	*A9,A9,W
	
	SLL	16,A9			; GET IN THE Y POSITION
	ADDI	LET_START_X,A9
OPLLOOP	
	MOVB	*A8,A0			; GRAB CHAR NUMBER
	MOVE	A0,A0	
	JRZ	OPLRET
	MOVE	A0,@CHAROUT,W
	PUSH	A8
	PUSH	A9
	PUSH	A10
	PUSH	A9
	MOVI	COLOR_PRED,A5		; COLOR
	MOVE	A10,A10
	JRNZ	OPL1
	MOVI	COLOR_PLF,A5
OPL1
	PUSH	A5
	MOVI	OP_MESS,A8
	CALLA	LM_SETUP
	PULL	A5			; COLOR
	PULL	A9			; SET THE POSITION OF THE CHAR
	JSRP	PRINTF
	PULL	A10
	DEC	A10
	PULL	A9
	PULL	A8
	ADDK	8,A8
	ADDI	LET_DIST_X,A9
	JRUC	OPLLOOP
OPLRET
	MMFM	SP,A8,A9,A10,A11
	RETS

OP_MESS:
	MESS_MAC RD15FONT,1,200,95,COLOR_PRED,STRLNRM,0
	.STRING	"%c",0
	.LONG	CHAROUT
	.EVEN

OLTAB	.LONG	OL1TAB, OL2TAB, OL3TAB, OL4TAB
OLYTAB	.WORD	LET_START_Y1, LET_START_Y2, LET_START_Y3, LET_START_Y4

OL1TAB	.BYTE	41H, 42H, 43H, 44H, 45H, 46H, 47H, 48H, 49H, 31H, 32H, 33H
	.BYTE	3FH, 21H, 22H
	.BYTE	00

OL2TAB	.BYTE	4AH, 4BH, 4CH, 4DH, 4EH, 4FH, 50H, 51H, 52H, 34H, 35H, 36H
	.BYTE	28H, 29H, 2AH
	.BYTE	00

OL3TAB	.BYTE	53H, 54H, 55H, 56H, 57H, 58H, 59H, 5AH, 7EH, 37H, 38H, 39H
	.BYTE	30H, 3AH, 3BH
	.BYTE	00

OL4TAB	.BYTE	23H, 24H, 20H, 26H, 27H
	.BYTE	2BH, 2CH, 2DH, 2EH, 2FH
	.BYTE	3DH, 82H, 7EH, 7FH, 83H
	.BYTE	00

OMINST1:
	MESS_MAC   RD7FONT,SPACING07,200,LET_INST1,COLOR_PWHITE,STRCNRM,0
	.STRING	"USE ",W_PLAYER," 1 CONTROLS TO ENTER A ",W_MESSAGE
	.STRING	"\nOF UP TO 3 LINES OF 25 LETTERS."
	.STRING	"\n\b",W_SELECT," CR TO END EACH LINE."
	.STRING	"\nPRESS \b",W_PLAYER," 1 ",W_START," \bTO ",W_CLEAR," OUT ",W_MESSAGE,"."
	.BYTE	0
	.WORD	COLOR_YELLOW
	.WORD	COLOR_RED
	.WORD	COLOR_YELLOW
	.WORD	COLOR_RED
	.WORD	COLOR_YELLOW
	.EVEN

OMTSETUP
	MESS_MAC   RD7FONT,SPACING07,200,LET_INST1,COLOR_PBLUE,STRCNRM,0
	.EVEN

OMUNDERSCORE
	.STRING	"-",0
	.EVEN

	.ENDIF
**************************************************************************
*								         *
* 	SOUND SYSTEM TEST						 *
*								         *
**************************************************************************

TO_SD_BD EQU     0
TO_Y_BD  EQU     3               ;A5 FOR SNDSND
TEST_YAM EQU     0F2H            ;A3 GETS CODE
TEST_DAC EQU     0F2H

**************************************************************************
*								         *
* 	GO_STEST							 *
* 									 *
* 	SETUP THE MENU FOR THE SOUND TEST				 *
* 									 *
* 	ENTRY								 *
* 		NOTHING							 *
* 									 *
* 	EXIT								 *
* 		NOTHING							 *
*								         *
**************************************************************************
GO_STEST CLR     A0
         MOVE    A0,@SCODE,W          ;NO "CURRENT" SYNTH YET
         MOVE    A0,@DCODE,W          ;NO "CURRENT" DIG YET
         MOVI    MEN_STEST,A8         ;PUT UP THE MENU AND GO!
         JAUC    GEN_MENU             ;THIS WILL RETURN TO LEVEL ABOVE US!

**************************************************************************
*								         *
* 	SEND_YAM							 *
* 									 *
* 	SEND A CODE PASSED IN A3 OUT TO THE YAMAMAHA			 *
* 									 *
* 	ENTRY								 *
* 		A3	CODE						 *
* 									 *
* 	EXIT								 *
* 		NOTHING							 *
*								         *
**************************************************************************
SEND_YAM 
	mmtm	sp,a0
	move	@SCODE,a0,W
	sll	6,a0
	addi	SCTAB,a0
	calla	ONESND
	mmfm	sp,a0
	rets

**************************************************************************
*								         *
* 	SHUT_UP								 *
* 									 *
* 	TELL THE SOUND BOARD TO GET SCREWED				 *
* 									 *
* 	ENTRY								 *
* 		NOTHING							 *
* 									 *
* 	EXIT								 *
* 		NOTHING							 *
*								         *
**************************************************************************

SHUT_UP
	MOVI	SND_ALLOFF,A0	;TURN OFF SOUNDS
	CALLA	ONESND
        SLEEP   1
        RETP

INC_IF_NEC
	MOVE	A3,A3		;IF ITS ZERO...KICK IT!
	JRZ	INC_IT
;	MOVE	@LAST_BUT,A0,L	;SEE WHICH BUTTON
;	CMPI	2,A0
	JRNZ	NO_INC		;THEN USE SAME CODE
INC_IT
	INC	A3
NO_INC
	RETS

SCTAB
	.WORD	0F080H, 1, 08000H, 0
	.WORD	0F080H, 1, 08001H, 0
	.WORD	0F080H, 1, 08005H, 0
	.WORD	0F080H, 1, 08006H, 0
	.WORD	0F080H, 1, 0800dH, 0
	.WORD	0F080H, 1, 08011H, 0
	.WORD	0F080H, 1, 08018H, 0
	.WORD	0F080H, 1, 08019H, 0
	.WORD	0F080H, 1, 0801aH, 0
	.WORD	0F180H, 1, 084abH, 0
	.WORD	0F180H, 1, 084aeH, 0
	.WORD	0F180H, 1, 08100H, 0
	.WORD	0F180H, 1, 08103H, 0
	.WORD	0F180H, 1, 08106H, 0
	.WORD	0F180H, 1, 0812dH, 0
	.WORD	0F180H, 1, 0813cH, 0
	.WORD	0F080H, 1, 08145H, 0
	.WORD	0F080H, 1, 0814eH, 0
	.WORD	0F080H, 1, 08161H, 0
	.WORD	0F080H, 1, 08167H, 0
	.WORD	0F080H, 1, 0816bH, 0
	.WORD	0F080H, 1, 08174H, 0
	.WORD	0F080H, 1, 0817dH, 0
	.WORD	0F080H, 1, 081b9H, 0
	.WORD	0F080H, 1, 081d5H, 0
	.WORD	0F080H, 1, 081d8H, 0
	.WORD	0F080H, 1, 08200H, 0
	.WORD	0F080H, 1, 0820aH, 0
	.WORD	0F080H, 1, 08213H, 0
	.WORD	0F080H, 1, 08219H, 0
	.WORD	0F080H, 1, 08231H, 0
	.WORD	0F080H, 1, 08232H, 0
	.WORD	0F080H, 1, 08252H, 0
	.WORD	0F080H, 1, 08281H, 0
	.WORD	0F080H, 1, 08282H, 0
	.WORD	0F080H, 1, 08287H, 0
	.WORD	0F080H, 1, 0828dH, 0
	.WORD	0F080H, 1, 0829bH, 0
	.WORD	0F080H, 1, 082a7H, 0
	.WORD	0F080H, 1, 082c1H, 0
	.WORD	0F080H, 1, 08313H, 0
	.WORD	0F080H, 1, 0832cH, 0
	.WORD	0F080H, 1, 08336H, 0
	.WORD	0F080H, 1, 08339H, 0
	.WORD	0F080H, 1, 0833fH, 0
	.WORD	0F080H, 1, 08366H, 0
	.WORD	0F080H, 1, 08368H, 0
	.WORD	0F080H, 1, 083a5H, 0
	.WORD	0F080H, 1, 08806H, 0
	.WORD	0F080H, 1, 08812H, 0
	.WORD	0F080H, 1, 08815H, 0
	.WORD	0F080H, 1, 08820H, 0
	.WORD	0F080H, 1, 0882fH, 0
	.WORD	0F080H, 1, 08832H, 0
	.WORD	0F080H, 1, 08835H, 0
	.WORD	0F080H, 1, 08838H, 0
	.WORD	0F080H, 1, 0883cH, 0
	.WORD	0F080H, 1, 08843H, 0

;LAST_SCODE       EQU     ($-SCTAB)/WORD_SIZE
LAST_SCODE	EQU	(($-SCTAB)/(WORD_SIZE*4))-1
         .EVEN


**************************************************************************
*								         *
* 	GO_DIGT								 *
* 									 *
* 	SETUP A GENERIC SOUND BOARD TEST				 *
* 									 *
* 	ENTRY								 *
* 		NOTHING							 *
* 									 *
* 	EXIT								 *
* 		NOTHING							 *
*								         *
**************************************************************************
GO_DIGT  
	CALLA	QSNDRST			;RESET IN CASE CRASHED!
	SLEEP	4			;LET IT GO A SEC!
	CALLA	CLR_SCRN
	MOVI	M_DIGT,A2
	MOVI	COLOR_GREEN,A3
	JSRP	TOP_BOX			;PRINT TITLE BOX.

;        CALLA	SURE_BOX		;PUT A NICE BOX UP!
SOUND_IRQ_CONNECTED
SOUND_DONGER
	clr	a8
	move	a8,@SOUND_RX,W
	CALLA	SNDRES			;RESET TO GET THE DINGS
	movi	SOUND_WAIT_MESS,a8
	CALLA	LM_SETUP
	JSRP	PRINTF
	movi	25,a2
	move	a2,@_serial_number,L
_sound_diag_loop:
	SLEEP	16			;6.4 Seconds
	move	@SOUND_RX,a8,W
	jrnz	snd_response
	move	@_serial_number,a2,L
	dec	a2
	move	a2,@_serial_number,L
	jrnz	_sound_diag_loop
	jruc	no_response
snd_response:
	SLEEP	10
	move	@SOUND_RX,a8,W
	andi	0ffh,a8
	subi	1,a8
	sll	5,a8
	addi	SOUNDTEST_MSGS,a8
	move	*a8,a8,L
	CALLA	LM_SETUP
	JSRP	PRINTF
	SLEEP	5
	CALLA	SET_VOLUME
	SLEEP	30
	movi	-1,a8
;	clr	a8
	move	a8,@SOUND_RX,W
	SOUND1	GET_VERSION_SOUND

	movi	10,a2
	move	a2,@_serial_number,L
_release_loop:
	SLEEP	20
	move	@SOUND_RX,a8,W
	cmpi	-1,a8
	jrnz	_got_release
	move	@_serial_number,a2,L
	dec	a2
	move	a2,@_serial_number,L
	jrnz	_release_loop
	jruc	no_release
_got_release:

	move	a8,a2
	srl	4,a2
	andi	0fh,a2
	CMPK	0dh,a2
	JRNE	_release_prompt
	andi	0fh,a8
	move	a8,@_serial_number,L
	movi	SNDPROTO_NUM_PROMPT,a8
	CALLA	LM_SETUP
	JSRP	PRINTF
	jruc	snd_diag_done
_release_prompt:
	andi	0fh,a8
	move	a8,@_serial_number,L
	movi	SNDRELEASE_NUM_PROMPT,a8
	CALLA	LM_SETUP
	JSRP	PRINTF
	jruc	snd_diag_done

no_release:
	movi	SOUND_NOREL_MESS,a8,L
	CALLA	LM_SETUP
	JSRP	PRINTF
	jruc	snd_diag_done

no_response:
	movi	SOUND_NORESP_MESS,a8,L
	CALLA	LM_SETUP
	JSRP	PRINTF
snd_diag_done:
;	MOVI	SOUND_TEST_RESULTS	;Test Results String
;	CALLA	LM_SETUP
;	JSRP	PRINTF
;        MOVI    DAC_ERR,A8
;	JSRP	L_MESS			;PRINT ERROR
	movi	SOUNDS_OFF,a0
	calla	ONESND
	SOUNDON
	JAUC	ANY_BUT			;AND TELL EM ANY BUTTON TO CONTINUE

**************************************************************************
*                                                                        *
*          GO_SYNP                                                       *
*                                                                        *
*          THIS IS THE "PLAY SYNTHESIZER" CODE.                          *
*                                                                        *
*          GET THE NEXT CODE...SEND IT TO THE YAMAHA AND                 *
*          DISPLAY THE CORRESPONDING TITLE.                              *
*                                                                        *
**************************************************************************
GO_SYNP
	movk	2,a0
	move	a0,@_in_volume_adjust,1
	movi	SOUNDS_OFF,a0
	calla	ONESND
	MOVE	@SCODE,A3,W		;GET THE NEXT CODE
	CALLR	INC_IF_NEC
	CMPI	LAST_SCODE,A3		;HAVE WE HIT THE LAST CODE?
	JRLS	GO_SYNP1		;BR = NO
	MOVK	1,A3			;RESET SOUND LIST
GO_SYNP1
	MOVE	A3,@SCODE,W		;STORE CURRENT CODE COUNTER
	CALLR	SEND_YAM
	MOVK	1,A0
	MOVE	A0,@NO_CLEAR
	RETP				;THATS IT!

**************************************************************************
*								         *
* 	GAME UTILITIES SELECTED						 *
*								         *
**************************************************************************

GO_UTIL  MOVI    MEN_UTIL,A8
         JAUC    GEN_MENU             ;PROCESS THE UTILITY MENU!

**************************************************************************
*								         *
* 	DO_FACSET							 *
* 									 *
* 	RESET THE CMOS TO FACTORY SETTINGS				 *
* 									 *
* 	ENTRY								 *
* 		NOTHING							 *
* 									 *
* 	EXIT								 *
* 		NOTHING							 *
*								         *
**************************************************************************

DO_FACSET:
        MOVI    MESS_FACSET,A8
        MOVK    1,A0
        JRUC    DEF_ADJ_PART

**************************************************************************
*								         *
* 	DO_DEF_ADJ							 *
* 									 *
* 	JUST RESET THE ADJUSTMENTS TO THE FACTORY SETTINGS		 *
* 									 *
* 	ENTRY								 *
* 		NOTHING							 *
* 									 *
* 	EXIT								 *
* 		NOTHING							 *
*								         *
**************************************************************************

DO_DEF_ADJ:
        MOVI    MESS_DEF_ADJ,A8
        CLR     A0

;	FALL THROUGH

**************************************************************************
*								         *
* 	DEF_ADJ_PART							 *
* 									 *
* 	SETUP CMOS TO DEFAULT ADJUSTMENTS				 *
* 									 *
* 	ENTRY								 *
* 		A0	HOW MUCH TO CLEAR				 *
* 		A8	MESSAGE TO USE					 *
* 									 *
* 	EXIT								 *
* 		NOTHING							 *
*								         *
**************************************************************************

DEF_ADJ_PART:
        MOVE    A0,@FAC_FLAG,W       ;INDICATE THIS IS ADJUSTMENTS ONLY

        MOVE    A8,-*A12,L           ;PUSH THE MESSAGE
        MOVE    *A12+,A8,L           ;RESTORE MESSAGE

        MOVI    DEFADJSOFT,A9
        MOVI    NULL_ST,A10          ;DON'T PRINT ANYTHING....ROUTINE WILL.
        JSRP    AREUSURE
        RETP
*
*        RETURN A0=0 FOR FAILURE
*
DO_CANCEL
        CLR     A0
        RETP

DEFADJSOFT
*
*        NOW SMASH THE CHECKSUM
*
	.IF	PRINTER
	MOVE	@FAC_FLAG,A0,W
	ADDI	6,A0
	CALLA	PBADGUY
	.ENDIF
        CALLA   FORM_ADC               ;FORM THE CKSUM
        MOVE    A1,A0                  ;PUT IN CMOS WRITING REGGIE
        MOVI    ADJ_CKSUM,A7
        INC     A0                     ;THIS SMASHES ADJUSTMENTS
	CALLA	CMOSUNLOCK
        CALLA   WC_WORD                ;AND STORE IT
	CALLA	CMOSLOCK
*
*        NOW MAKE SURE ITS SMASHED
*
        CALLA   CMOS_VAL
        JRZ     AD_FAIL                ;WE CAN'T DO IT.....PRINT FAILURE.
*
*        NOW SET THE ADJUSTMENTS TO THE FACTORY VALUE.
*
        CALLA   FAC_SET             ;THIS DOES THE DEED!
        CALLA   CMOS_VAL            ;IS IT OK NOW?
        JRNZ    AD_FAIL             ;NOPE...PRINT FAILURE

	MOVI	DEFRESMESS,A8
        MOVE    @FAC_FLAG,A0,W      ;DO WE NEED TO CLEAR THE TABLES?
        JRZ     DAX                 ;NOPE...POST SINGLE MESSAGE
        MOVI    MESS_DEFCONF,A8     ;THIS IS SINGLE MESSAGE

        CALLA   CLR_SCRN        ;CLEAR THE SCREEN FOR OUR MESSAGES.
        CALLR   FAC_STUF        ;DO AUDITS AND HIGH SCORE TABLE

        MOVI    MESS_FFSCONF,A8 ;PRINT THE REST OF THE MESSAGES
        JSRP    L_MESS          ;THAT DOES IT!

NOTABS   RETP

AD_FAIL  MOVI    MESS_FACFAIL,A8
         JRUC    DAX

DEF_CAN  MOVI    MESS_CANCELLED,A8

DAX      CALLA   CLR_SCRN
         JSRP    SUR_MESS
         RETP

DEFRESMESS
	.STRING	W_ADJUSTMENTS," RESTORED",0
	.EVEN


*
*        ON A FULL FACTORY SETTING (EITHER REQUESTED OR
*        ADJUSTMENT FAILURE) THIS CLEARS THE AUDITS AND
*        HIGH SCORE TABLE.
*
FAC_STUF 
	CALLA   CLR_AUD         ;CLEAR AUDITS TOO
        CALLR   RES_ALL         ;ALL TIME TABLE
        CALLR   INVALID_CUSTOM
        RETS

**************************************************************************
*								         *
* 	INVALID_CUSTOM							 *
* 									 *
* 	THIS KILLS THE CUSTOM MESSAGE SO THAT THE FACTORY MESSAGE	 *
* 	WILL BE USED.  NOTE THAT THIS CHECKSUMS THE ADJUSTMENTS,	 *
* 	SO BE CAREFUL WITH IT!						 *
* 									 *
* 	ENTRY								 *
* 		NOTHING							 *
* 									 *
* 	EXIT								 *
* 		NOTHING							 *
*								         *
**************************************************************************
INVALID_CUSTOM:
        MMTM    SP,A0,A7
;XUNIT        CALLA   ADJ_PAGE             ;POINT AT ADJUSTMENT PAGE
        CLR     A0
        MOVI    VALID_CUSTOM,A7
	calla	CMOSUNLOCK
	CALLA   WC_WORD
	calla	CMOSLOCK
        CALLA   F_ADC_S              ;FIXUP CHECKSUM FOR OUR DEED!
	MMFM    SP,A0,A7
	RETS


	.if	NOPIC
	.else
**************************************************************************
*                                                                        *
*         HARDWARE INFORMATION SELECTED                                  *
*                                                                        *
**************************************************************************

SERIAL_NUM_PROMPT:
	MESS_MAC RD7FONT,SPACING07,200,180,COLOR_PPURPLE,STRCNRM,0
	.STRING "SERIAL NUMBER:  %06ld",0
	.LONG	_serial_number
	.EVEN

MAN_DATE_PROMPT:
	MESS_MAC RD7FONT, SPACING07,200, 200, COLOR_PPURPLE,STRCNRM,0
	.STRING "DATE OF MANUFACTURE:  %02ld/%02ld/19%02ld",0
	.LONG	_month
	.LONG	_day
	.LONG	_year
	.EVEN

WILLY_PROMPT:
	MESS_MAC RD15FONT, SPACING07, 200, 100, COLOR_PGREEN, STRCNRM,0
	.STRING	"Midway Manufacturing Inc.",0
	.EVEN

X_PROMPT:
	MESS_MAC RD20FONT, SPACING20, 200, 140, COLOR_PYELLOW, STRCNRM, 0
	.STRING	"X UNIT",0
	.EVEN

	.globl	_get_serial_number

_get_serial_number:
	movi	CMOS_SN,a0
	movk	3,a1
	clr	a2
_gs_loop:
	sll	8,a2
	move	*a0+,a3,1
	andi	0ffh,a3
	or	a3,a2
	dsjs	a1,_gs_loop
	move	a2,@_serial_number,1
	rets

_get_date:
	movi	CMOS_DATE,a0
	movk	2,a1
	clr	a2
_gd_loop:
	sll	8,a2
	move	*a0+,a3,1
	andi	0ffh,a3
	or	a3,a2
	dsjs	a1,_gd_loop
	move	a2,a1
	subk	1,a1
	movi	372,a0
	divu	a0,a1
	movi	372,a3
	mpyu	a1,a3
	sub	a3,a2
	addi	80,a1
	move	a1,@_year,1
	move	a2,a0
	movi	31,a1
	modu	a1,a0
	move	a0,@_day,1
	move	a2,a1
	subk	1,a1
	movi	31,a0
	divu	a0,a1
	addk	1,a1
	move	a1,@_month,1
	rets

GO_HARDWARE:
	calla	_get_serial_number
	calla	_get_date
	movk	1,a8
	move	a8,@NO_CLEAR,W
	calla	CLR_SCRN
	movi	WILLY_PROMPT,a8
	calla	LM_SETUP
	JSRP	PRINTF
	movi	X_PROMPT,a8
	calla	LM_SETUP
	JSRP	PRINTF
	movi	SERIAL_NUM_PROMPT,a8
	calla	LM_SETUP
	JSRP	PRINTF
	movi	MAN_DATE_PROMPT,a8
	calla	LM_SETUP
	JSRP	PRINTF
	movi	MEN_HARDWARE,a8
	jauc	GEN_MENU
RET_HARDWARE:
	clr	a8
	move	a8,@NO_CLEAR,W
	JSRP	FORCE_MAIN
	RETP
	.endif

SNDRELEASE_NUM_PROMPT:
	MESS_MAC RD15FONT,SPACING07,200,130,COLOR_PPURPLE,STRCNRM,0
	.STRING	"Sound Software Version:\n"
	.STRING "RELEASE %2ld",0
	.LONG	_serial_number
	.EVEN
SNDPROTO_NUM_PROMPT:
	MESS_MAC RD15FONT,SPACING07,200,130,COLOR_PPURPLE,STRCNRM,0
	.STRING	"Sound Software Version:\n"
	.STRING "PROTO %2ld",0
	.LONG	_serial_number
	.EVEN

VOL_PROMPT:
	MESS_MAC	RD15FONT, SPACING07, 200, 100, COLOR_PGREEN, STRCNRM,0
	.STRING	"Volume Level",0
	.EVEN
MIN_PROMPT:
	MESS_MAC	RD7FONT, SPACING07, 50, 137, COLOR_PGREEN, STRCNRM, 0
	.STRING "-",0
	.EVEN
MAX_PROMPT:
	MESS_MAC	RD7FONT, SPACING07, 350, 137, COLOR_PGREEN, STRCNRM, 0
	.STRING	"+",0
	.EVEN
;CVAL_PROMPT:
;	MESS_MAC	RD15FONT, SPACING07, 150, 170, COLOR_PPURPLE,STRLNRM,0
;	.STRING	"Current Value: %3ld",0
;	.STRING	"CURRENT VALUE",0
;	.LONG	_volume_level
;	.EVEN

VOL_PROMPT1:
	.STRING	"VOLUME LEVEL",0
	.EVEN
MIN_PROMPT1:
	.STRING "MIN",0
	.EVEN
MAX_PROMPT1:
	.STRING	"MAX",0
	.EVEN

	.globl	draw_volume_scale1

draw_volume_scale:
	ADJUST	ADJVOLUME
	move	a0,@_volume_level,1
	mmtm	sp,a0
;	movi	[170,150],a0
;	movi	[16,200],a1
;	movi	COLOR_BLACK,a2
;	FCALL	RECTANGLE,b6
;	movi	CVAL_PROMPT,a0
;;	clr	a2
;	movi	COLOR_PURPLE,a3
;	movi	[170,150],a1
;	FCALL	STRING,b6
;	movi	3,a3
;	movk	5,a4
;	move	@_volume_level,a8,1
;	calla	HEX_TO_ASCII_DEC
;	move	a8,a0
;	movi	[170,260],a1
;	clr	a2
;	movi	COLOR_PURPLE,a3
;	FCALL	STRING,b6
;	calla	LM_SETUP
;	JSRP	PRINTF
	movi	VOL_PROMPT,a8
	calla	LM_SETUP
	JSRP	PRINTF
	movi	MIN_PROMPT,a8
	calla	LM_SETUP
	JSRP	PRINTF
	movi	MAX_PROMPT,a8
	calla	LM_SETUP
	JSRP	PRINTF
	movi	[134,75],a0
	movi	[16,256],a1
	movi	COLOR_BLACK,a2
	FCALL	RECTANGLE,b6
	movi	[0,85],a3
_yblock_loop:
	move	a3,a0
	addi	[139,0],a0
	movi	[5,5],a1
	movi	COLOR_YELLOW,a2
	FCALL	RECTANGLE,b6
	addi	20,a3
	cmpi	334,a3
	jrlt	_yblock_loop
	move	*sp,a4,1
	jrz	_rblock_done
	movi	[0,75],a3
_rblock_loop:
	move	a3,a0
	addi	[134,0],a0
	movi	[15,5],a1
	movi	COLOR_RED,a2
	FCALL	RECTANGLE,b6
	addi	10,a3
	subi	10,a4
	cmpi	0,a4
	jrgt	_rblock_loop
_rblock_done:
	mmfm	sp,a0
	rets

draw_volume_scale1:
	mmtm	sp,a0,a1,a2,a3,a4,a5,a6,a8,a13
	ADJUST	ADJVOLUME
	move	a0,@_volume_level,1
	mmtm	sp,a0
;	movi	[968,150],a0
;	movi	[16,200],a1
;	movi	COLOR_BLACK,a2
;	FCALL	RECTANGLE,b6
;	movi	CVAL_PROMPT,a0
;	clr	a2
;	movi	COLOR_PURPLE,a3
;	movi	[968,150],a1
;	FCALL	STRING,b6
;	movi	3,a3
;	movk	5,a4
;	move	@_volume_level,a8,1
;	calla	HEX_TO_ASCII_DEC
;	move	a8,a0
;	movi	[968,260],a1
;	clr	a2
;	movi	COLOR_PURPLE,a3
;	FCALL	STRING,b6
	movi	VOL_PROMPT1,a0
	FCALL	STRINGCENTER,b6
	addi	[860,0],a1
	clr	a2
	movi	COLOR_GREEN,a3
	FCALL	STRING,b6
	movi	MIN_PROMPT1,a0
	movi	[905,40],a1
	clr	a2
	movi	COLOR_GREEN,a3
	FCALL	STRING,b6
	movi	MAX_PROMPT1,a0
	movi	[905,340],a1
	clr	a2
	movi	COLOR_GREEN,a3
	FCALL	STRING,b6
	movi	[902,75],a0
	movi	[16,256],a1
	movi	COLOR_BLACK,a2
	FCALL	RECTANGLE,b6
	movi	[0,85],a3
_yblock_loop1:
	move	a3,a0
	addi	[907,0],a0
	movi	[5,5],a1
	movi	COLOR_YELLOW,a2
	FCALL	RECTANGLE,b6
	addi	20,a3
	cmpi	334,a3
	jrlt	_yblock_loop1
	move	*sp,a4,1
	jrz	_rblock_done1
	movi	[0,75],a3
_rblock_loop1:
	move	a3,a0
	addi	[902,0],a0
	movi	[15,5],a1
	movi	COLOR_RED,a2
	FCALL	RECTANGLE,b6
	addi	10,a3
	subi	10,a4
	cmpi	0,a4
	jrgt	_rblock_loop1
_rblock_done1:
	mmfm	sp,a0
	mmfm	sp,a0,a1,a2,a3,a4,a5,a6,a8,a13
	rets

GO_VOLUME:
	ADJUST	ADJVOLUME
	move	a0,@_volume_level,1
 	SOUND1	VOL_ADJUST_SOUND
	movk	1,a8
	move	a8,@_in_volume_adjust,L
	calla	CLR_SCRN
	movi	MESS_VOL_TITLE,a2
	movi	COLOR_WHITE,a3
	JSRP	TOP_BOX
	move	@_cabinet_type,a8,L
	jrz	_xvol_inst
	movi	VOL_INST_T2,a8
	jruc	_xvol_inst_out
_xvol_inst:
	movi	VOL_INST,a8
_xvol_inst_out:
	calla	LM_SETUP
	JSRP	PRINTF
	calla	draw_volume_scale
	movi	MEN_VOLUME,a8
	movk	1,a9
	JSRP	B_MENU
RET_VOLUME:
	clr	a8
	move	a8,@NO_CLEAR,W
	move	a8,@_in_volume_adjust,L
	SOUND1	SOUNDS_OFF
	RETP

**************************************************************************
*                                                                        *
*         COIN BOOKKEEPING SELECTED                                      *
*                                                                        *
**************************************************************************
GO_BOOK
	CALLA	CLR_SCRN
	MOVI	MES_BOOK,A2
	MOVI	COLOR_WHITE,A3
	JSRP	TOP_BOX			;PRINT TITLE BOX.

	MOVE	@VALIDATOR,A0,W
	JRZ	BOOK_NO_BV		;BR = We are not using a bill validator

	MOVI	COIN_AUDS_BV,A0		;PUT TABLE UP.
	JRUC	BOOK_PRINT

BOOK_NO_BV
	MOVI	COIN_AUDS,A0		;PUT TABLE UP.

BOOK_PRINT
	JSRP	PRNT_AUD

	MOVI	MEN_DETAIL,A8
	MOVI	1,A9			;CURSOR ON 1ST ENTRY
	JSRP	B_MENU			;SEE IF THEY WANT PAGE 2.

	CMPI	1,A8			;DID WE GET 1'ST ENTRY?
	JRNZ	NO_DETAIL		;NOPE...RETURN TO OUR CALLER
DETAIL_SCREEN
	CALLA	CLR_SCRN		;CLEAR OUT FOR ACTION!
	MOVI	MES_TOTALS,A2
	MOVI	COLOR_WHITE,A3
	JSRP	TOP_BOX			;PRINT TITLE BOX.

	MOVK	1,A0
	MOVE	A0,@PTSIZE,W		;THIS BOX IS IN 15 PT

	MOVE	@VALIDATOR,A2,W
	JRZ	DS_FOUR_SLOT

	MOVI	COIN_D1_BV,A2		;DETAILED AUDIT 1 W/Validator
	MOVI	ADJCDIV,A0
	CALLA	GET_ADJ
	JRNZ	DSGO
	MOVI	COIN_SD1_BV,A2
  	JRUC	DSGO

DS_FOUR_SLOT
	MOVI	COIN_D1,A2		;DETAILED AUDIT 1
	MOVI	ADJCDIV,A0
	CALLA	GET_ADJ
	JRNZ	DSGO
	MOVI	COIN_SD1,A2
DSGO
	MOVE	A2,A0
	JSRP	PRNT_AUD		;PRINT IT
	CLR	A0
	MOVE	A0,@PTSIZE,W

	MOVI	MEN_CLR_SUB,A8		;CLEAR SUBTOTAL OR RETURN TO MAIN MENU
	MOVI	2,A9			;CURSOR ON 2ND ENTRY
	JSRP	B_MENU               

	CMPI	1,A8			;CHOICE 1 IS CLEAR.....
	JRNZ	NO_CLEAR_SUB		;NOPE...RETURN TO CALLER!

	MOVI	MESS_CLEAR_SUBS,A8	;CLEAR COIN SUB-TOTALS...ARE YOU SURE
	MOVI	CLR_COINS,A9		;ROUTINE TO DO IT
	MOVI	MESS_SUBS_CLEAR,A10	;CONFIRMATION.
	JSRP	AREUSURE		;ASK EM.
	JRUC	DETAIL_SCREEN		;NOW PUT THIS SCREEN BACK UP.

NO_CLEAR_SUB
NO_DETAIL
	RETP

**************************************************************************
*                                                                        *
*          GAME AUDITS SELECTED                                          *
*                                                                        *
**************************************************************************
GO_AUD
	JSRP	NEW_AUDIT_PAGE

	MOVI	GAME_AUDS,A0
	JSRP	PRNT_AUD		;PLOT PAGE ONE

	MOVI	MEN_AP1,A8		;OPTIONS FOR FIRST PAGE
	MOVI	1,A9			;CURSOR ON 1ST ENTRY
	JSRP	B_MENU			;WAIT FOR OPERATOR ENTRY

	CMPI	1,A8			;DOES HE WANT NEXT PAGE?
	JRNZ	NO_AP2			;BR = NO, RETURN TO MAIN MENU
        
GA2
	JSRP	NEW_AUDIT_PAGE

	MOVI	GAME_AUD2,A0
	JSRP	PRNT_AUD		;PLOT PAGE TWO

	MOVI	MEN_AP2,A8		;PAGE 2 OPTIONS
	MOVI	1,A9			;CURSOR ON 1ST ENTRY
	JSRP	B_MENU			;WAIT FOR OPERATOR ENTRY
		
	CMPI	1,A8			;NEXT PAGE?
	JRZ	GA3			;BR = YES
	CMPI	2,A8			;PREVIOUS PAGE?
	JRZ	GO_AUD			;BR = YES
	JRUC	NO_AP2			;MUST WANT OUT

GA3
	JSRP	NEW_AUDIT_PAGE		;WIPE TO NEW PAGE

	MOVI	GAME_AUD3,A0
	JSRP	PRNT_AUD		;PLOT PAGE 3

	MOVI	MEN_AP2,A8		;PAGE 3 OPTIONS
	MOVI	1,A9			;CURSOR ON 2ND ENTRY
	JSRP	B_MENU			;WAIT FOR OPERATOR ENTRY
		
	CMPI	1,A8			;PREVIOUS PAGE?
	JRZ	GA4			;BR = YES
	CMPI	2,A8			;PREVIOUS PAGE?
	JRZ	GA2			;BR = YES
	JRUC	NO_AP2			;MUST WANT OUT

GA4
	JSRP	NEW_AUDIT_PAGE		;WIPE TO NEW PAGE

	MOVI	GAME_AUD4,A0
	JSRP	PRNT_AUD		;PLOT PAGE 3

	MOVI	MEN_AP2,A8		;PAGE 3 OPTIONS
	MOVI	1,A9			;CURSOR ON 2ND ENTRY
	JSRP	B_MENU			;WAIT FOR OPERATOR ENTRY
		
	CMPI	1,A8			;PREVIOUS PAGE?
	JRZ	GA5			;BR = YES
	CMPI	2,A8			;PREVIOUS PAGE?
	JRZ	GA3			;BR = YES
	JRUC	NO_AP2			;MUST WANT OUT


GA5
	JSRP	NEW_AUDIT_PAGE		;WIPE TO NEW PAGE

	MOVI	GAME_AUD5,A0
	JSRP	PRNT_AUD		;PLOT PAGE 3

	MOVI	MEN_AP2,A8		;PAGE 3 OPTIONS
	MOVI	1,A9			;CURSOR ON 2ND ENTRY
	JSRP	B_MENU			;WAIT FOR OPERATOR ENTRY
		
	CMPI	1,A8			;PREVIOUS PAGE?
	JRZ	GA_LAST			;BR = YES
	CMPI	2,A8			;PREVIOUS PAGE?
	JRZ	GA4			;BR = YES
	JRUC	NO_AP2			;MUST WANT OUT


GA_LAST
	JSRP	NEW_AUDIT_PAGE		;WIPE TO NEW PAGE

	MOVI	GAME_AUDL,A0
	JSRP	PRNT_AUD		;PLOT PAGE 3

	MOVI	MEN_AP3,A8		;PAGE 3 OPTIONS
	MOVI	2,A9			;CURSOR ON 2ND ENTRY
	JSRP	B_MENU			;WAIT FOR OPERATOR ENTRY
		
	CMPI	1,A8			;PREVIOUS PAGE?
	JRZ	GA5			;BR = YES

	CALLR	READ_SW1_CNS		; XUNIT 
	ANDI	200000H,A0		;HOLDING P2 START?
	JRNZ	NO_AP2

*THE FOLLOWING ARE CONSIDERED HIDDEN AUDITS
	JSRP	NEW_AUDIT_PAGE		;WIPE TO NEW PAGE

	MOVI	GAME_AUDH,A0
	JSRP	PRNT_AUD		;PLOT PAGE 4

	MOVI	MEN_AP3,A8		;PAGE 4 OPTIONS
	MOVI	2,A9			;CURSOR ON 2ND ENTRY
	JSRP	B_MENU			;WAIT FOR OPERATOR ENTRY

	CMPI	1,A8			;PREVIOUS PAGE?
	JRZ	GA3			;BR = YES

	JSRP	DISPDUMP		;DISPLAY THE DUMPS

NO_AP2
	RETP

**************************************************************************
*								         *
* OCTO_AUDS - PRINT OUT AUDITS DURING OCTOPUS PAGE			 *
*								         *
**************************************************************************
OCTO_AUDS
	JSRP	NEW_AUDIT_PAGE
	MOVI	GAME_AUDS,A0
	JSRP	PRNT_AUD		;PLOT PAGE ONE
	SLEEP	15
	MOVI	2000,A0
	JSRP	SLEEP_SWITCHX

	JSRP	NEW_AUDIT_PAGE
	MOVI	GAME_AUD2,A0
	JSRP	PRNT_AUD		;PLOT PAGE ONE
	SLEEP	15
	MOVI	2000,A0
	JSRP	SLEEP_SWITCHX

	JSRP	NEW_AUDIT_PAGE
	MOVI	GAME_AUD3,A0
	JSRP	PRNT_AUD		;PLOT PAGE ONE
	SLEEP	15
	MOVI	2000,A0
	JSRP	SLEEP_SWITCHX

	JSRP	NEW_AUDIT_PAGE
	MOVI	GAME_AUD4,A0
	JSRP	PRNT_AUD		;PLOT PAGE ONE
	SLEEP	15
	MOVI	2000,A0
	JSRP	SLEEP_SWITCHX

	JSRP	NEW_AUDIT_PAGE
	MOVI	GAME_AUD5,A0
	JSRP	PRNT_AUD		;PLOT PAGE ONE
	SLEEP	15
	MOVI	2000,A0
	JSRP	SLEEP_SWITCHX

	JSRP	NEW_AUDIT_PAGE
	MOVI	GAME_AUDL,A0
	JSRP	PRNT_AUD		;PLOT PAGE ONE
	SLEEP	15
	MOVI	2000,A0
	JSRP	SLEEP_SWITCHX

	JSRP	NEW_AUDIT_PAGE
	MOVI	GAME_AUDH,A0
	JSRP	PRNT_AUD		;PLOT PAGE ONE
	SLEEP	15
	MOVI	2000,A0
	JSRP	SLEEP_SWITCHX

	JAUC	DISPDUMP		;DISPLAY THE DUMPS

**************************************************************************
*								         *
* NEW_AUDIT_PAGE - INITIALIZE A NEW AUDIT PAGE, CLEAR SCREEN AND	 *
* 		 PLOT THE HEADER BOX.					 *
* NOTE: CALL WITH JSRP							 *
*								         *
**************************************************************************
NEW_AUDIT_PAGE
	CALLA	CLR_SCRN
	MOVI	MES_AUD,A2
	MOVI	COLOR_BLUE,A3
	JRUC	TOP_BOX			;PRINT TITLE BOX.

**************************************************************************
*                                                                        *
*          PRNT_AUD                                                      *
*                                                                        *
*          THIS IS CALLED TO PRINT OUT AN AUDIT TABLE.                   *
*                                                                        *
**************************************************************************
AT_PTR   EQU     PDATA                ;LONG
AT_Y     EQU     PDATA+LONG_SIZE      ;WORD
AT_DY    EQU     AT_Y+WORD_SIZE       ;WORD
AT_LX    EQU     AT_DY+WORD_SIZE      ;WORD   LEFT MARGIN X
AT_RX    EQU     AT_LX+WORD_SIZE      ;WORD   RIGHT MARGIN X
AT_OBJ   EQU     AT_RX+WORD_SIZE      ;LONG   OBJECT POINTER FOR COLLECTION ROUT
AT_MESS  EQU     AT_OBJ+LONG_SIZE     ;LONG   PRINT_MONEY MESSAGE STASH

PRNT_AUD
	MOVE	*A0+,A1,W		;GET STARTING HEIGHT
	MOVE	A1,*A13(AT_Y),W		;STORE

	MOVE	*A0+,A1,W		;GET DY TO USE
	MOVE	A1,*A13(AT_DY),W	;STASH IT AWAY

	MOVI	40,A14
	MOVE	@PTSIZE,A1,W
	JRZ	PAGO_PT
	MOVI	33,A14
PAGO_PT
	MOVE	*A0+,A1,W		;GET LEFT MARGIN
	ADD	A14,A1
	MOVE	A1,*A13(AT_LX),W	;STORE
	MOVE	*A0+,A1,W		;GET RIGHT MARGIN
	SUB	A14,A1
	MOVE	A1,*A13(AT_RX),W	;STASH IT AWAY
	MOVE	A0,*A13(AT_PTR),L	;SAVE POINTER INTO AREA

PA1      
	MOVE	@LASTCOLOR,A14,L
	CMPI	COLOR_PYELLOW,A14
	JRZ	PACOLFLIP1
	MOVI	COLOR_PYELLOW,A14
	JRUC	PACOLFLIP2
PACOLFLIP1
	MOVI	COLOR_PPURPLE,A14
PACOLFLIP2
	MOVE	A14,@LASTCOLOR,L

	JSRP	DO_AN_AUDIT		;PRINT OUT THE CURRENT AUDIT

	MOVE	*A13(AT_PTR),A0,L	;GET POINTER
	ADDI	AUD_T_SIZE,A0
	MOVE	A0,*A13(AT_PTR),L	;PUT BACK

	CALLR	ADD_AUDIT_DY

	MOVE	*A0,A1,L		;ARE WE DONE?
	JRNZ	PA1

	RETP

**************************************************************************
*                                                                        *
*          ADD_AUDIT_DY                                                  *
*                                                                        *
*          THIS IS CALLED TO MOVE THE AUDIT Y (STORE IN                  *
*          PROCESS AREA) TO THE NEXT AUDIT BY ADDING THE                 *
*          CURRENT DY (ALSO STORED IN PROCESS AREA).                     *
*                                                                        *
**************************************************************************
ADD_AUDIT_DY
         MMTM    SP,A1,A2
         MOVE    *A13(AT_Y),A1,W
         MOVE    *A13(AT_DY),A2,W      ;GET DELTA Y
         ADD     A2,A1                 ;MOVE THE Y DOWN
         MOVE    A1,*A13(AT_Y),W
	MMFM    SP,A1,A2
	RETS

BEGIN_AUDIT
         MMTM    SP,A0
         CLR     A0
         MOVE    A0,@BAD_AUD,W            ;MONITOR CORRUPTION.
	MMFM    SP,A0
	RETS

DO_AN_AUDIT
	CALLR	BEGIN_AUDIT
	MOVE	*A13(AT_PTR),A3,L	;GET POINTER
	MOVE	*A3(AUD_ROUTINE),A4,L	;ROUTINE TO CALL?
	JRZ	DO_BY_NUMBER		;NOPE....DO IT BY NUMBER

	MOVI	DAA_RET,A7
	MOVE	A7,-*A12,L		;PUSH RET ADDR
	JUMP	A4			;"CALL" THE ROUTINE

DO_BY_NUMBER
	MOVE	*A3(AUD_NUMBER),A0,W	;FETCH THE AUDIT NUMBER
	CALLA	GET_AUD			;TURN INTO AUDIT COUNT!
	MOVE	A1,A3			;PROTECT FOR A SECOND.

	JSRP	NUMBER_WORK		;GET THE NUMBER IN A3 UP THERE!

DAA_RET  
	MOVI	MESS_AUD_LINE,A8
	MOVE	@PTSIZE,A14,W
	JRZ	DAA_GO
	MOVI	MESS15_AUD_LINE,A8
DAA_GO
	CALLA	LM_SETUP		;SETUP FOR AUDIT PRINTING.
	MOVE	@LASTCOLOR,A5,L

	MOVE	*A13(AT_PTR),A3,L	;GET AUDIT POINTER
	MOVE	*A3(AUD_MESS),A8,L	;GET TEXT POINTER

	JSRP	LEFT_FINISH
	RETP				;THAT'S ALL WE DO!

*
*        LEFT_FINISH   AND    RIGHT_FINISH
*
*        THESE ARE CALLED TO PUT AUDIT INFO
*        ON THE LEFT OR RIGHT SIDE ONCE A8 POINTS AT
*        THE CORRECT DATA TO PRINT
*
LEFT_FINISH
	CALLR	TURN_RED_IF_NEC
	CALLR	SET_FOR_Y		;SET FOR AUDIT'S Y
	CALLR	SET_LEFT_X		;SET FOR LEFT X
	JSRP	PRINTF		;AND TYPE UP THE MESSAGE!
	RETP

RIGHT_FINISH
	CALLR	TURN_RED_IF_NEC		;CHANGE COLOR IF CORRUPTED.
	CALLR	SET_FOR_Y		;SET FOR AUDIT'S Y
	CALLR	SET_RIGHT_X
	JSRP	PRINTF		;FINISH THE JOB!

	MOVE	@BAD_AUD,A0,W		;IS IT CORRUPTED?
	JRZ	RFX			;NOPE....RETURN

	MOVI	MESS_ERROR,A8
	CALLA	LM_SETUP		;SETUP "ERROR"

	CALLR	SET_FOR_Y		;SET FOR AUDIT'S Y
****	ADDI	40000H,A9		;PUSH 4 Y UNITS TO CENTER 
	CALLR	SET_RIGHT_X
	JSRP	PRINTF		;FINISH THE JOB!

RFX
	RETP

TURN_RED_IF_NEC
	MMTM	SP,A3
	MOVE	@BAD_AUD,A3,W		;CHANGE TO RED?
	JRZ	DAA_1			;NOPE...ITS OK!
	MOVI	COLOR_PRED,A5		;CHANGE COLOR TO RED
DAA_1
	MMFM    SP,A3
	RETS
                              
SET_FOR_Y
	MMTM	SP,A3
	MOVE	*A13(AT_Y),A3,W		;GET Y COORDINATE
	SLL	16,A3			;PUT IT IN POSITION
	MOVY	A3,A9			;PUT IT IN PLACE
	MMFM    SP,A3
	RETS

SET_LEFT_X
	MMTM	SP,A3
	MOVE	*A13(AT_LX),A3,W
	MOVX	A3,A9			;PUT THE X IN PLACE
	MMFM	SP,A3
	RETS

SET_RIGHT_X
	MMTM	SP,A3
	MOVE	*A13(AT_RX),A3,W
	MOVX	A3,A9			;PUT THE X IN PLACE
	MMFM	SP,A3
	RETS

**************************************************************************
*                                                                        *
*          NUMBER_WORK                                                   *
*                                                                        *
*          A3 HAS THE NUMBER TO DISPLAY.....DO IT!                       *
*                                                                        *
**************************************************************************
NUMBER_WORK
	MOVI	MESS_AUD_NUM,A8		;SETUP FOR AUDIT NUMBER
	MOVE	@PTSIZE,A14,W
	JRZ	NUMGO
	MOVI	MESS15_AUD_NUM,A8
NUMGO
	CALLA	LM_SETUP
	MOVE	@LASTCOLOR,A5,L
	MOVE	A3,A8                   ;NOW WE HAVE BINARY NUMBER
	CALLA	HEXTOASC		;NOW WE POINT TO THE STRING.

	JSRP	RIGHT_FINISH

	RETP

STARTS
	CALLR	GET_STARTS
	MOVE	A2,A3			;GET IN PRINTOUT REG.
	JRUC	NUMBER_WORK		;AND PRINT IT

CONTINS
	CALLR	GET_CONTS
	MOVE	A2,A3			;GET IN PRINTOUT REG.
	JRUC	NUMBER_WORK		;AND PRINT IT

DOPLAYS
	CALLR	GET_PLAYS
	MOVE	A2,A3			;PUT IN PLACE
	JRUC	NUMBER_WORK

DOTOTTIME
	CLR	A3
	JRUC	NUMBER_WORK

DOHSLEFT
	MOVI	ADJHSRES,A0
	CALLA	GET_ADJ			;IS IF OFF?
	JRZ	DOHSOFF			;YEP...PRINT IT

	CALLA	GET_HSC			;GET THE COUNTER VALUE
	MOVE	A0,A3
	JRUC	NUMBER_WORK		;AND SHOW IT!

DOHSOFF
	MOVI	MESS_AUD_NUM,A8
	CALLA	LM_SETUP		;SETUP FOR AUDIT PRINTING.
	MOVE	@LASTCOLOR,A5,L
	MOVI	M_HSOFF,A8		;THIS EFFECTIVELY ERASES LINE!
	JAUC	RIGHT_FINISH

**************************************************************************
*								         *
* 	GET_STARTS							 *
* 									 *
* 	RETURN THE TOTAL GAME STARTS					 *
* 									 *
* 	ENTRY								 *
* 		NOTHING							 *
* 									 *
* 	EXIT								 *
* 		A2	TOTAL GAME STARTS				 *
*								         *
**************************************************************************
GET_STARTS:
        MMTM    SP,A0,A1
        MOVI    AUDSTART,A0
        CALLA   GET_AUD
        MOVE    A1,A2
	MMFM    SP,A0,A1
	RETS

**************************************************************************
*								         *
* 	GET_CONTS							 *
* 									 *
* 	RETURN TOTAL GAME CONTINUES IN A2				 *
* 									 *
* 	ENTRY								 *
* 		NOTHING							 *
* 									 *
* 	EXIT								 *
* 		A2	TOTAL GAME CONTINUES				 *
*								         *
**************************************************************************
GET_CONTS:
        MMTM    SP,A0,A1
        MOVI    AUDCONTTAKEN,A0
        CALLA   GET_AUD
        MOVE    A1,A2
	MMFM    SP,A0,A1
	RETS
		   

**************************************************************************
*								         *
* 	GET_PLAYS							 *
* 									 *
* 	RETURN THE TOTAL PLAYS ( STARTS + CONTINUES )			 *
* 									 *
* 	ENTRY								 *
* 		NOTHING							 *
* 									 *
* 	EXIT								 *
* 		A2	TOTAL PLAYS					 *
*								         *
**************************************************************************
GET_PLAYS:
        MMTM    SP,A0
        CALLR   GET_STARTS
        MOVE    A2,A0
        CALLR   GET_CONTS
        ADD     A0,A2
	MMFM    SP,A0
	RETS

DO_PTIME
	MOVI	AUDPTIME,A0
	JRUC	TIMEGO

DO_AVGTC
	CLR	A3
	MOVI	AUDNUMTC,A0
	CALLA	GET_AUD		; GET THE DIVISOR
	MOVE	A1,A2
	JRZ	DTCGO		; NO /0'S HERE, BUD
	MOVI	AUDAVGTC,A0
	CALLA	GET_AUD		; GET TOTAL TIME
	CLR	A0
	DIVU	A2,A0		; A0 CONTAINS THE REAL NUMBER
	MOVE	A0,A3		; NUMBER TO DISPLAY
DTCGO
	JRUC	PLOTTIME

**************************************************************************
*								         *
* 	SET_AVGWAVE							 *
* 									 *
* 	CALL FOR SETTING THE AVERAGE WAVE				 *
* 									 *
* 	ENTRY								 *
* 		A1	WAVE REACHED					 *
* 									 *
* 	EXOT								 *
* 		NOTHING							 *
* 									 *
* 	CALL								 *
* 		CALL							 *
*								         *
**************************************************************************

SET_AVGWAVE:
	MMTM	SP,A0,A1,A2
	MOVE	A1,A2			; SAVE AWAY FOR POSTERITY
	MOVI	AUDNUMTG,A0
	CALLA	AUD1
	MOVI	AUDWAVECNT,A0		; WAVE COUNTER THINGIE
	CALLA	GET_AUD
	ADD	A2,A1	
	CALLA	STORE_AUDIT
	MOVI	AUDAVGGC,A0
	CALLA	GET_AUD
	MOVE	@GAMEUNITS,A2,W		; UNITS USED IN THIS GAME
	ADD	A2,A1	
	CALLA	STORE_AUDIT
	MMFM	SP,A0,A1,A2
	RETS

DO_AVGWAVE
	CLR	A3
	MOVI	AUDNUMTG,A0
	CALLA	GET_AUD		; GET THE DIVISOR
	MOVE	A1,A2
	JRZ	DAWAVEGO 	; NO /0'S HERE, BUD
	MOVI	AUDWAVECNT,A0
	CALLA	GET_AUD		; GET TOTAL TIME
	CLR	A0
	DIVU	A2,A0		; A0 CONTAINS THE REAL NUMBER
	MOVE	A0,A3		; NUMBER TO DISPLAY
DAWAVEGO
	JAUC	NUMBER_WORK

*
*CALCULATE PERCENTAGE OF CONTINUES TAKEN
*
DO_PCTCONT
	CLR	A3
	MOVI	AUDCONTOFFER,A0
	CALLA	GET_AUD		;CONTINUES OFFERED IS THE DIVISOR
	MOVE	A1,A2
	JRZ	DAPCTGO		;BR = 0 NOT ALLOWED IN THIS DIVIDE

	MOVI	AUDCONTTAKEN,A0
	CALLA	GET_AUD		;CONTINUES TAKEN IS THE DIVIDEND
	MOVI	100,A0		;MAKE IT A PERCENTAGE
	MPYU	A0,A1
	DIVU	A2,A1		;AND GET IT
	MOVE	A1,A3		;NUMBER TO DISPLAY
DAPCTGO
	JAUC	NUMBER_WORK

*
* Average credits spent per game
*
DO_AVGGC
	CLR	A3
	MOVI	AUDNUMTG,A0
	CALLA	GET_AUD		; GET THE DIVISOR
	MOVE	A1,A2
	JRZ	DAGCGO 		; NO /0'S HERE, BUD
	MOVI	AUDAVGGC,A0
	CALLA	GET_AUD		; GET TOTAL CREDITS
	CLR	A0
	DIVU	A2,A0		; A0 CONTAINS THE REAL NUMBER
	MOVE	A0,A3		; NUMBER TO DISPLAY
DAGCGO
	JAUC	NUMBER_WORK

*
* Average credits spent per player/game
*
DO_AVGPC
	CLR	A3
	CALLR	GET_STARTS
	JRZ	DAPCGO 		; NO /0'S HERE, BUD
	MOVI	AUDAVGGC,A0
	CALLA	GET_AUD		; GET TOTAL CREDITS SPENT
	CLR	A0
	DIVU	A2,A0		; A0 CONTAINS THE REAL NUMBER
	MOVE	A0,A3		; NUMBER TO DISPLAY
DAPCGO
	JAUC	NUMBER_WORK


DO_UPTIME
	MOVI	AUDUPTIME,A0
	JRUC	TIMEGO

DO_P1TIME
	MOVI	AUD1TIME,A0
	JRUC	TIMEGO

DO_P2TIME
	MOVI	AUD2TIME,A0
	JRUC	TIMEGO
	
DO_P3TIME
	MOVI	AUD3TIME,A0
	JRUC	TIMEGO

TIMEGO
	CALLA	GET_AUD
	MOVE	A1,A3
	JRUC	PLOTTIME

**************************************************************************
*								         *
* 	PLOTTIME								 *
* 									 *
* 	PLOT OUT THE TIME SPECIFIED IN A3				 *
* 									 *
* 	ENTRY								 *
* 		A3	TIME ( IN SECONDS )				 *
* 									 *
* 	EXIT								 *
* 		NOTHING							 *
*								         *
**************************************************************************

PLOTTIME:
	MOVI	MESS_AUD_NUM,A8
	CALLA	LM_SETUP
	MOVE	@LASTCOLOR,A5,L

	MMTM	SP,A0,A1,A2,A7,A9,A10,A11
	CLR	A9			; NO SECONDS
	CLR	A10			; NO MINUTES
	CLR	A11			; NO HOURS
	MOVI	STRINGF_RAM,A7		; STRING TO BUILD IN
	MOVE	A3,A1			; BASE VALUE
	JRZ	PNOTIME

	CLR	A0			; DIVIDEND IN <A0><A1>
	MOVI	60,A2			; 60 SECS/MINUTE
	DIVU	A2,A0			; A0 = MINUTES, A1 = SECONDS
	MOVE	A1,A9			; SET SECONDS
	MOVE	A0,A1			; MINUTES/HOURS
	JRZ	PNOTIME
	CLR	A0
	DIVU	A2,A0			; A0 = HOURS, A1 = MINUTES
	MOVE	A1,A10
	MOVE	A0,A11

PNOTIME
	MOVE	A11,A0
	JRZ	PNOHOURS
	CALLA	CAT_A0			; HOURS
	MOVI	ME_COLON,A8
	CALLA	STRCAT
PNOHOURS
	MOVE	A10,A0
	CMPI	10,A0
	JRHS	P1
	MOVE	A11,A11			; NO LEADING ZERO IF NO HOURS
	JRZ	P1
	CLR	A0
	CALLA	CAT_A0			; INSERT EXTRA ZERO
	MOVE	A10,A0
P1
	CALLA	CAT_A0			; MINUTES
	MOVI	ME_COLON,A8
	CALLA	STRCAT
	MOVE	A9,A0
	CMPI	10,A0
	JRHS	P2
	CLR	A0
	CALLA	CAT_A0			; INSERT EXTRA ZERO
	MOVE	A9,A0
P2
	CALLA	CAT_A0			; SECONDS
	MMFM	SP,A0,A1,A2,A7,A9,A10,A11
	MOVI	STRINGF_RAM,A8
	JSRP	RIGHT_FINISH
	RETP

ME_COLON:
	.STRING	":",0
	.EVEN

**************************************************************************
*								         *
* DO_MONEY - ROUTINE TO OUTPUT MONEY TOTALS FOR A GIVEN STANDARD COINAGE *
* 		IF THE COINAGE IS CUSTOM, IT JUST TOTALS COINS		 *
* 		RECEIVED IN COIN SLOTS.  USED ON THE DETAILED		 *
* 		BOOKKEEPING PAGE.					 *
*								         *
**************************************************************************
DO_MONEY:
	MOVI	COLOR_PWHITE,A8
	MOVE	A8,@LASTCOLOR,L			; A GROSS KLUDGE
	MOVE	*A13(AT_Y),A8,W
	ADDI	10H,A8
	MOVE	A8,*A13(AT_Y),W
	MOVI	MESS_AUD_NUM,A8
	MOVE	@PTSIZE,A14,W
	JRZ	DO_M_GO
	MOVI	MESS15_AUD_NUM,A8
DO_M_GO
	CALLA	LM_SETUP
	MOVE	@LASTCOLOR,A5,L
	MMTM	SP,A0,A1,A2,A3,A4,A5,A7,A10,A11

	CALLR	BEGIN_AUDIT		;KEEP TRACK OF SANITY OF CALC.
	MOVI	AUDLCOIN,A8		;NOW PRINT MONEY FOR THE CHUTES

	CALLR	SUM_COINS

	MOVK	1,A0			;DIVIDE COINS BY 1 IF ITS BEEN TAMPERED WITH
	CALLR	SIXP
	JRZ	DIV_BY_1		;TAMPERED WITH...DIVIDE BY 1 FOR "COINS"

	MOVI	ADJCDIV,A0		;GET THE COIN PARTS PLEASE
	CALLA	GET_ADJ
DIV_BY_1
	MOVE	A2,A11                ;SETUP <A10><A11> AS DIVIDEND
	CLR	A10
	DIVU	A0,A10		      ; DOLLARS IN A10, CHANGE IN A11
	MOVI	100,A5
	DIVU	A0,A5
	MPYU	A5,A11

	MOVI	STRINGF_RAM,A7		; STRING TO BUILD IN
	CALLR	SIXP			;HAVE THE 6 BEEN TAMPERED 
	JRZ	NO_PREFIX
	CALLA	GET_CSPT
	MOVE	*A6(CS_LMES),A8,L
	CALLA	STRCAT
NO_PREFIX

	MOVE	A0,A2			;KEEP DIVISOR FOR CHECK
	MOVE	A10,A0
	CALLA	CAT_A0			;STUFF IN THE WHOLE GRAIN VALUE
	CMPI	1,A2			;WE'RE WE DEALING FRACTIONS?
	JREQ	NO_FRACTION		;BR = NO
	MOVI	PERIODSIGN,A8
	CALLA	STRCAT
	CMPI	10,A11
	JRHS	DM2
	CLR	A0
	CALLA	CAT_A0
DM2
	MOVE	A11,A0
	CALLA	CAT_A0
NO_FRACTION
	CALLR	SIXP			;HAVE THE 6 BEEN TAMPERED 
	JRZ	NO_SUFFIX
	MOVE	*A6(CS_RMES),A8,L
	CALLA	STRCAT
NO_SUFFIX

	MMFM	SP,A0,A1,A2,A3,A4,A5,A7,A10,A11
	MOVI	STRINGF_RAM,A8
	JSRP	RIGHT_FINISH
	RETP

**************************************************************************
*                                                                        *
*          SUM_COINS                                                     *
*                                                                        *
*          A8 HAS FIRST OF THE "CHUTES" AUDIT NUMBERS OF INTEREST        *
*                                                                        *
*          RETURN COINS TIMES THEIR FACTORS IN A2.                       *
*                                                                        *
**************************************************************************
SUM_COINS            
	MMTM	SP,A0,A1,A3,A6,A4

	MOVE	A8,A0			;POINT AT AUDIT NUMBER
	CLR	A2			;SUM = ZERO

	CALLA	GET_CSPT		;A6 POINTS AT CSELECT TABLE
	ADDI	CS_LVAL,A6		;POINT AT 1ST MULTIPLIER

	MOVI	CHUTES,A4		;NOW...ITERATE OVER THE CHUTES

NEXT_CHUTE
	MOVE	*A6+,A3,W		;GET MULTPLIER FOR THIS CHUTE
	CALLR	FIX_A3			;REPLACE A3 WITH 1 (MULTIPLIER) IF 
*					;ITS SOME CUSTOM MODE.
	CALLR	ADD_AUD_A0_TIMES_A3_TO_A2 
	INC	A0			;NEXT AUDIT
	DSJS	A4,NEXT_CHUTE

	MMFM	SP,A0,A1,A3,A6,A4
	RETS

ADD_AUD_A0_TIMES_A3_TO_A2
	CALLA	GET_AUD			;FETCH THE AUDIT
	MPYU	A1,A3			;TIME THE FACTOR
	ADD	A3,A2
	RETS

**************************************************************************
*                                                                        *
*          FIX_A3                                                        *
*                                                                        *
*          THIS IS CALLED BY THE LOW LEVEL MONEY TOTALIZER.              *
*          THE MULTIPLIER FOR THE COIN SLOT THAT ITS WORKING             *
*          ON IS IN A3.  WE REPLACE IT WITH "1" TO SUM "TOTAL COINS"     *
*          IF ITS IN A NON-STANDARD COIN MODE.                           *
*                                                                        *
**************************************************************************
FIX_A3
	CALLR	SIXP			;HAS IT BEEN TAMPERED WITH?
	JRNZ	FIX_A3X			;NOPE...LEAVE A3
	MOVK	1,A3
FIX_A3X
	RETS

**************************************************************************
*                                                                        *
*          SIXP                                                          *
*                                                                        *
*          THIS IS CALLED TO SEE IF THE 1ST 6 COIN PARAMETERS HAVE       *
*          BEEN TAMPERED WITH.                                           *
*                                                                        *
*          .EQ.            YES                                           *
*          .NE.            NO                                            *
*                                                                        *
**************************************************************************
SIXP
	MMTM	SP,A0
	MOVI	ADJ1ST6,A0
	CALLA	GET_ADJ              ;HAS IT BEEN TAMPERED WITH?
	MMFM	SP,A0
	RETS

PERIODSIGN:
	.STRING	".",0
	.EVEN

**************************************************************************
*								         *
* 	UTILITY ROUTINES FOR UTILITIES MENU				 *
*								         *
**************************************************************************
DO_CLCRED
	MOVI	MESS_CLCRED,A8		;CLEAR COIN SUB-TOTALS...ARE YOU SURE
	MOVI	CLR_CREDITS,A9		;ROUTINE TO DO IT
	MOVI	MESS_CCCONF,A10		;CONFIRMATION.
	JAUC	AREUSURE		;ASK EM......THEN RETURN!

CLR_CREDITS
	.IF PRINTER
	MOVK	2,A0
	CALLA	PBADGUY
	.ENDIF
	CALLA	NO_CREDS		;CALL THE ROUTINE THAT DOES IT
	RETP

DO_CLCOIN
	MOVI	MESS_CLCOIN,A8		;CLEAR COIN SUB-TOTALS...ARE YOU SURE
	MOVI	CLR_COINS,A9		;ROUTINE TO DO IT
	MOVI	MESS_CCNCONF,A10	;CONFIRMATION.
	JAUC	AREUSURE		;ASK EM......THEN RETURN!

CLR_COINS
	.IF PRINTER
	CLR	A0
	CALLA	PBADGUY
	.ENDIF
	MOVI	FRST_C,A0
	MOVI	LAST_C,A1
	CALLA	CLR_AUDR
         RETP

DO_CLAUD
	MOVI	MESS_CLAUD,A8		;CLEAR COIN SUB-TOTALS...ARE YOU SURE
	MOVI	CLR_AUDITS,A9		;ROUTINE TO DO IT
	MOVI	MESS_CAUDCONF,A10	;CONFIRMATION.
	JAUC	AREUSURE		;ASK EM......THEN RETURN!

CLR_AUDITS
	.IF PRINTER
	MOVK	4,A0
	CALLA	PBADGUY
	.ENDIF
	MOVI	FRSTGAUD,A0
	MOVI	LASTGAUD,A1
	CALLA	CLR_AUDR
	CALLA	DUMP_FS			;AND START THE "DUMP" RECORDS OVER
	RETP

DO_HSRES
	MOVI	MESS_HSRESET,A8
	MOVI	HSSOFT,A9
	MOVI	MESS_HSRCONF,A10
	JAUC	AREUSURE

HSSOFT   
	.IF PRINTER
	MOVK	5,A0
	CALLA	PBADGUY
	.ENDIF
	CALLR	RES_ALL
	RETP				;PROGRAM TO DO THE JOB!

**************************************************************************
*								         *
* 	RES_ALL								 *
* 									 *
* 	RESET THE ALL TIME HIGHSCORE TABLE AND THE RESET COUNTER	 *
* 									 *
* 	ENTRY								 *
* 		NOTHING							 *
* 									 *
* 	EXIT								 *
* 		NOTHING							 *
*								         *
**************************************************************************
RES_ALL:
	MOVI	ALL_TAB,A8		;ALWAYS CLEAR OUT TODAYS TABLE
	CALLA	INIT_TB
	CALLA	INIT_HSR		;RE-SET THE HIGH SCORE RESET COUNTER
	RETS

**************************************************************************
*                                                                        *
*          MONITOR PATTERNS                                              *
*                                                                        *
**************************************************************************
	.IF	PRINTER
	.ELSE
GO_PATTERNS
	MOVI	MEN_PATTERNS,A8		;PUT UP THE MENU AND GO!
	JAUC	GEN_MENU		;THIS WILL RETURN TO LEVEL ABOVE US!
* A1 = <COLOR><PALETTE>
* A3 = DAG OF AREA [YPOS,XPOS]						 
* A4 = [Y,X] SIZE OF AREA						 
GO_RED
	MOVI	COLOR_RED,A1
	JAUC	SC_COL
GO_GREEN
	MOVI	COLOR_GREEN,A1
	JAUC	SC_COL
GO_BLUE
	MOVI	COLOR_BLUE,A1
SC_COL
	SLL	16,A1			;PALETTE 0....COLOR UP HIGH
	CLR	A3			;UPPER LEFT 
	MOVI	00FF0190H,A4
	CALLA	FILLAREA		;THIS DOES THE SCREEN
	JAUC	WAIT_BUT		;NOW WAIT FOR ANY BUTTON!
	.ENDIF

**************************************************************************
*								         *
* 	WAIT FOR A BUTTON MENU						 *
*								         *
**************************************************************************
ANY_BUT
         MOVI    ANY_MENU,A8          ;ANY BUTTON TO CONTINUE
         MOVI    1,A9                 ;CURSOR ON ENTRY 1
         JAUC    B_MENU               ;DO IT....RETURN WHEN PRESSED.

**************************************************************************
*                                                                        *
*          WAIT_BUT                                                      *
*                                                                        *
*          THIS IS CALLED ON RETURN FROM MANY OF THE "HARD"              *
*          DIAGNOSTIC TESTS TO HOLD CONTROL TILL ANY BUTTON IS           *
*          HIT.                                                          *
*                                                                        *
**************************************************************************
WAIT_BUT
	PUSHP	A8
	CLR	A8
*WAIT FIRST FOR ALL SWITCHES TO BE OPEN, TIMEOUT IS 8 SECONDS
WB_OPEN_WAIT
	CALLR	READ_SW1_CNS		; XUNIT  HANGOUT FOR A WHILE
	move	a0,a1
	callr	READ_SW2_DIP
	ori	0ffff0000h,a0
	and	a1,a0
	move	@_in_driver_test,a1,1
	jrz	_wb_norm
	andi	1A642020h,a0
	cmpi	1A642020h,a0
	jruc	_wb_driver
_wb_norm:

;	ANDI	1A643030H,A0
;	CMPI	1A643030H,A0		;ARE ALL SWITCHES OFF?
	ANDI	1A743030H,A0
	CMPI	1A743030H,A0		;ARE ALL SWITCHES OFF?

_wb_driver:
	JREQ	WB_GO			;BR = YES
	INC	A8
	CMPI	300,A8			;HAVE WE WAITED TOO LONG?
	JRHS	WB_GO
	SLOOP	1,WB_OPEN_WAIT

WB_GO
	PULLP	A8
	MOVE	A0,@SWSET1,L

WB1
	SLEEP	10
	CALLR	CKTEST			; CHECK TEST SWITCHES
	CALLR	READ_SW1_CNS		; XUNIT GOTTA SEE IF TIME TO LEAVE
	move	a0,a1
	callr	READ_SW2_DIP
	ori	0ffff0000h,a0
	and	a1,a0
	move	@_in_driver_test,a1,1
	jrz	_wb_norm1
	andi	1A642020h,a0
	cmpi	1A642020h,a0
	jruc	_wb_driver1
_wb_norm1:

;	ANDI	1A643030H,A0
;	cmpi	1a643030h,a0
	ANDI	1A743030H,A0
	cmpi	1a743030h,a0

_wb_driver1:
;	JRNZ	WBEND
	jrnz	wbend1

;	SLEEP	1
	JRUC	WB1
wbend1
	SOUND1	DIAG_ESCAPE
	
WBEND
	sleep	10
	callr	READ_SW1_CNS
	move	a0,a1
	callr	READ_SW2_DIP
	ori	0ffff0000h,a0
	and	a1,a0
	move	@_in_driver_test,a1,1
	jrz	_wb_norm2
	andi	1A642020h,a0
	cmpi	1A642020h,a0
	jruc	_wb_driver2
_wb_norm2:

;	andi	1a643030h,a0
;	cmpi	1a643030h,a0
	andi	1a743030h,a0
	cmpi	1a743030h,a0

_wb_driver2:
	jrnz	WBEND
	clr	a0
	move	a0,@_in_driver_test,1

;	SOUND1	DIAG_ESCAPE

	RETP

**************************************************************************
*								         *
* 	CKTEST								 *
* 									 *
* 	CHECK TO SEE IF EITHER OF THE TEST BUTTONS IS CLOSED,		 *
* 	IF NOT, HEAD OUT TO WARMSET					 *
* 									 *
* 	ENTRY								 *
* 		NOTHING							 *
* 									 *
* 	EXIT								 *
* 		NOTHING							 *
*								         *
**************************************************************************
CKTEST
;Following removed to accomodate the new momentary coin door test switch
;	PUSH	A0
;	CALLA	READ_DIP		;Get the dipswitches
;	ANDI	DPTEST,A0		;Is the test switch still closed?
;	JRNZ	CKRET			;BR = Yes, do nothing
;	JAUC	WARMSET			;Switch is open, exit
;	CALLR	READ_SW1_CNS		; XUNIT 
;	NOT	A0
;	ANDI	00100000H,A0
;	JAZ	WARMSET			; WE BE OUTTA HERE!
;CKRET
;	PULL	A0
	RETS

**************************************************************************
*								         *
* 	CKDIAG								 *
* 									 *
* 	CHECK TO SEE IF WE NEED TO GO OFF TO THE DIAGNOSTICS ROUTINES	 *
* 									 *
* 	ENTRY								 *
* 		NOTHING							 *
* 									 *
* 	EXIT								 *
* 		A0	0 = COOL, 1 = GO TO DIAGS			 *
*								         *
**************************************************************************
CKDIAG
	CLR	A0
	CALLA	READ_DIP
	ANDI	DPTEST,A0
	JRNZ	CKDGO
	CALLR	READ_SW1_CNS		; XUNIT 
	NOT	A0
	ANDI	00100000H,A0
	JRZ	CKDRET
CKDGO
	MOVK	1,A0
CKDRET
	MOVE	A0,A0
	RETS

**************************************************************************
*                                                                        *
*          FORCE_MAIN                                                    *
*                                                                        *
*          THIS IS CALLED TO GET TO MAIN MENU FROM LEVEL FURTHER         *
*          THAN 1 DOWN.  IT SETS THE GLOBAL FLAG "MAIN_RET"              *
*          NON ZERO.  GEN_MENU WILL KEEP RETURNING UNTIL                 *
*          IT GETS BACK TO THE MAIN MENU.                                *
*                                                                        *
**************************************************************************
FORCE_MAIN
	MOVK	1,A0			;POSITIVE NUMBER FORCES MAIN MENU.
	MOVE	A0,@MAIN_RET,W
	RETP				;NOW "RETURN TO THE MENU"


**************************************************************************
*                                                                        *
*          GEN_MENU                                                      *
*                                                                        *
*          THIS IS A GENERAL MENU HANDLER.  IT POSTS THE MENU            *
*          WITH SELECTION 1 AVAILABLE.  AFTER A SELECTION IS             *
*          MADE, IF IT HAS A ROUTINE CODE OF ZERO, (EXIT)                *
*          IT RETURNS TO THE LEVEL ABOVE IT.  ELSE, IT                   *
*          JSRP'S THE NEW ROUTINE.  WHEN THE NEW ROUTINE                 *
*          RETURNS, WE RE-POST THE SAME MENU WITH THE                    *
*          BAR ON THE FOLLOWING ENTRY.                                   *
*                                                                        *
*          A8 = MENU DESCRIPTOR                                          *
*                                                                        *
**************************************************************************
*
*        MENU ROM OFFSETS
*	   
MR_FONT  EQU     0
MR_TCAL  EQU     MR_FONT+LONG_SIZE
MR_TITLE EQU     MR_TCAL+LONG_SIZE    ;POINTER TO TITLE FOR TILE BOX (IF NEC)
MR_TCLR  EQU     MR_TITLE+LONG_SIZE   ;COLOR OF TITLE
MR_WORDS EQU     MR_TCLR+WORD_SIZE    ;STREAM OF WORDS TO COPY TO PDATA STARTS HERE
MR_X     EQU     MR_WORDS
MR_Y     EQU     MR_X+WORD_SIZE
MR_DY    EQU     MR_Y+WORD_SIZE
MR_COL   EQU     MR_DY+WORD_SIZE
MR_HITE  EQU     MR_COL+WORD_SIZE
MR_BDY   EQU     MR_HITE+WORD_SIZE
MR_DX    EQU     MR_BDY+WORD_SIZE
MR_WID   EQU     MR_DX+WORD_SIZE

GEN_MENU
	CALLR	CKTEST			;ROUND ABOUT 100 ON PLOTBUG
	MOVE	@GMENULEV,A0,W		;KICK LEVEL POINTER
	INC	A0
	MOVE	A0,@GMENULEV,W
*
	MOVE	A8,-*A12,L		;SAVE MENU PTR
	MOVI	1,A8			;START WITH "FIRST" ENTRY
	MOVE	A8,-*A12,W		;PUT MENU NUMBER AS A WORD
*
*	IF WE GET HERE AND MAIN_RET IS NOT ZERO, THE WE MUST
*	RETURN TO LEVEL ABOVE US IF WE'RE NOT THE MAIN
*	MENU.
*
GEN_LOOP
	MOVE	@MAIN_RET,A0,W		;ARE WE IN "EXIT" MODE?
	JRZ	NO_EXIT			;NO

	JRN	DIVE_TO_MONITOR		;WE'RE DIVING TO MONITOR PATTERNS.

	MOVE	@GMENULEV,A0,W		;CHECK LEVEL
	CMPI	1,A0			;ARE WE AT LEVEL 1
	JRNZ	GEN_EXIT		;NOPE.....POP UP A LEVEL.
*
*	WE'RE AT LEVEL 1....CLEAR OUT THE FLAG THAT
*	GOT US HERE.
*
DIVE_COMPLETE
	CLR	A0
	MOVE	A0,@MAIN_RET,W		;NOW WE MAY PROCEED!

NO_EXIT
	MOVE	@NO_CLEAR,A0,W		;INHIBIT CLEAR?
	JRNZ	SKIP_CLR

	CALLA	CLR_SCRN		;CLEAR THE SCREEN

SKIP_CLR
	CLR	A0
	MOVE	A0,@NO_CLEAR,W		;AND RE-SET IT!

	MOVE	*A12(WORD_SIZE),A8,L	;GET MENU DESCRIPTOR
	JSRP	MENU_TOP
	JSRP	CYAN_BOX		;PUT UP MAIN MENU INSTRUCTIONS

	MOVE	*A12,A9,W		;GET MENU NUMBER TO USE
	JSRP	B_MENU			;GET RESULT

PHONEY_MENU_RET
	MOVE	A10,A10			;WAS IT ADVANCE?
	JRZ	NO_KICK			;NOPE....LEAVE WHERE HE CAME FROM

	INC	A8			;KICK INDEX BY 1 FOR NEXT TIME
NO_KICK
	MOVE	A8,*A12,W		;AND LEAVE ON THE STACK

	MOVE	A9,A9			;NOW JSRP THE ROUTINE
	JRZ	GEN_EXIT		;NONE THERE....ITS "EXIT"
*
*	JSRP TO A9
*
	MOVI	GEN_LOOP,A7
	MOVE	A7,-*A12,L		;PUSH RET ADDR
	JUMP	A9

GEN_EXIT
	ADDI	WORD_SIZE+LONG_SIZE,A12	;POP THE ARGUMENTS
	MOVE	@GMENULEV,A0,W		;KICK LEVEL POINTER
	DEC	A0
	MOVE	A0,@GMENULEV,W
	RETP

**************************************************************************
*                                                                        *
*          DIVE_TO_MONITOR                                               *
*                                                                        *
*          WE GET CONTROL HERE WHEN WE ARE KLUDGING THE RETURN           *
*          FROM "CPU" TEST (WHICH BLOWS AWAY RAM!)                       *
*                                                                        *
**************************************************************************
DIVE_TO_MONITOR
         MOVE    @GMENULEV,A0,W            ;CHECK LEVEL
         CMPI    1,A0                      ;ARE WE AT LEVEL 1
         JRNZ    DTM1                      ;NOPE....SET "MONITOR" LEVEL
*
*        WE'RE AT LEVEL 1......."SELECT" THE DIAGNOSTIC MENU
*        A8 = 1.....A9 = ROUTINE FOR DIAGNOSTIC MENU
*
         MOVK    1,A8
	.IF	PRINTER
	.ELSE
         MOVI    GO_DIAG,A9           ;ROUTINE FOR DIAGNOSTIC MENU
	.ENDIF
         MOVK    1,A10                ;RETURN AS IF ADVANCE WAS PRESSED
         JRUC    PHONEY_MENU_RET      ;WE'RE READY TO CALL DIAG MENU
*
*        WE'RE IN DIAGNOSTIC MENU....NOW WE JUST NEED TO MAKE
*        THE "CURRENT" SELECTION THE ONE AFTER CPU TEST
*        (MONITOR PATTERNS)
*
DTM1     MOVE    @MAIN_RET,A8,W            ;FLAG IS OPPOSITE OF ENTRY NUMBER
         NEG     A8                        ;THIS IS RETURN LEVEL!
	.IF	PRINTER
	.ELSE
         MOVI    RTR_LEV,A8                ;START WITH "RETURN" ENTRY NUMBER
	.ENDIF
         MOVE    A8,*A12,W                 ;PUT MENU NUMBER AS A WORD
         JRUC    DIVE_COMPLETE             ;THIS COMPLETES THE DIVE!

*
*          FOR DOBORDER
*
*          A4 = UPPER LEFT Y,X                                           
*          A5 = LOWER RIGHT Y,X                                        
*          A0 = Y,X WIDTH OF BORDER                                     
*          A9 = COLOR OF BORDER.                                         

**************************************************************************
*                                                                        *
*          TOP_BOX                                                       *
*                                                                        *
*          THIS DISPLAYS THE TEST BOX AT THE TOP.                        *
*                                                                        *
*          A2 POINTS AT THE STRING TO CENTER IN THE BOX.                 *
*          A3 IS COLOR TO DO IT IN.                                      *
*                                                                        *
**************************************************************************
MENU_TOP
	MOVE	*A8(MR_TITLE),A2,L	;GET TITLE INTO A2
	MOVE	*A8(MR_TCLR),A3,W	;AND COLOR INTO A3

TOP_BOX
	MOVE	A8,-*A12,L		;PUSH MENU PTR
*
*	FIRST MAKE THE BOX...IT BLACKS OUT THE REGION
*
	CALLR	SCR_BOX			;PUT UP THE TITLE BOX

	MOVI	MESS_TITLE,A8		;SET PARAMETERS
	CALLA	LM_SETUP		;PUT IT OUT.

	MOVE	A2,A8			;GET STRING IN THE CORRECT REGGIE
	MOVE	A3,A6			;MOVE COLOR TO COLOR REGGIE
;	MOVE	A3,A5			;FIXING THIS WOULD BREAK EVERYTHING!
*
	JSRP	PRINTF		;AND PRINT IT!

	JSRP	SCR_REV			;NOW ADD THE REV.

	MOVE	*A12+,A8,L		;RESTORE THE MENU PTR

	RETP

**************************************************************************
*								         *
*          SCR_REV							 *
* 									 *
*          DISPLAY REV IN TITLE BOX.					 *
*								         *
**************************************************************************
SCR_REV
	MOVI	MESS_REV,A8	;GET READY FOR REV MESSAGE
	CALLA	LM_SETUP	;SETUP FOR REV MESSAGE

	MOVI	ROM_NAME,A8	;USE ROM COPY OF REV.
	JSRP	PRINTF	;FINISH PRINTING MESSAGE
	RETP

**************************************************************************
*								         *
*          SCR_REV_OBJ							 *
* 									 *
*          DISPLAY REV IN TITLE BOX AS OBJECTS				 *
*								         *
**************************************************************************
SCR_REV_OBJ
	MOVI	MESS_REV,A8	;GET READY FOR REV MESSAGE
	CALLA	LM_SETUP	;SETUP FOR REV MESSAGE
	MOVI	STRCNRMO,A1
	MOVI	ROM_NAME,A8	;USE ROM COPY OF REV.
	JSRP	PRINTF	;FINISH PRINTING MESSAGE
	RETP

**************************************************************************
*                                                                        *
*          SCR_BOX                                                       *
*                                                                        *
*          THIS DISPLAYS THE TITLE BOX.                                  *
*                                                                        *
**************************************************************************
SCR_BOX
	MOVI	TIT_ULX+(10000H*TIT_ULY),A4	;UPPER LEFT
	MOVI	TIT_LRX+(10000H*TIT_LRY),A5	;LOWER RIGHT
	MOVI	COLOR_YELLOW,A9
	CALLR	STD_BORD	;TACO BELL HAS YOUR ORDER, MAKE A RU-UUUN......
	RETS

**************************************************************************
*								         *
*          SCR_BOX_OBJ							 *
* 									 *
*          THIS DISPLAYS THE TITLE BOX AS OBJECTS			 *
*								         *
**************************************************************************
SCR_BOX_OBJ
	MOVI	COLOR_PYELLOW,A1
	MOVI	TIT_ULX+(10000H*TIT_ULY),A3	;UPPER LEFT
	MOVI	MB_XWID,A2			;LINE THICKNESS
	MOVI	(TIT_LRX+(10000H*TIT_LRY))-(TIT_ULX+(10000H*TIT_ULY)),A0 ;SIZE
	CALLA	DRAWBOX_OBJ			;DRAW DAT BOX
	RETS

**************************************************************************
*                                                                        *
*          REV_TO_PDATA                                                  *
*                                                                        *
*          THIS COPIES THE CURRENT REV. DATA TO THE                      *
*          CALLING (CONTROLLING) PROCESSES' PDATA AREA.                  *
*                                                                        *
**************************************************************************
*                                                                        *
* REV_TO_PDATA                                                           *
*          MMTM    SP,A2,A7,A6,A0                                        *
*          CALLA   ADJ_PAGE                                              *
*          MOVI    NAME_REV,A7          ;POINT AT CMOS NAME STORAGE      *
*          MOVE    A13,A6               ;POINT WITH A6                   *
*          ADDI    PDATA,A6                                              *
*          MOVI    NAME_REV_SIZE,A2     ;MAXIMUM NAME SIZE               *
*                                                                        *
* REV_XFER_LOOP                                                          *
*          CALLA   RC_BYTEI             ;FETCH A BYTE                    *
*          MOVB    A0,*A6               ;PUT IN PROCESS AREA             *
*          ADDI    BYTE_SIZE,A6         ;PUSH THIS POINTER               *
*          DSJS    A2,REV_XFER_LOOP                                      *
*                                                                        *
*          CLR     A0                   ;STORE A ZERO BEYOND IN CASE ITS *
*          MOVE    A0,*A6,W             ;2 BYTES DOESN'T HURT            *
* 	MMFM    SP,A2,A7,A6,A0                                          *
* 	RETS                                                            *
*                                                                        *
**************************************************************************
*
*        THIS PRINTS THE "MOVE JOYSTICK" BOX.
*
*        A8 = MENU DESCRIPTOR THAT WILL ACCOMPANY IT
*        ON SCREEN.  WE ADJUST THE BOX EDGES AND
*        MESSAGE CENTER IN "X" ONLY TO CORRESPOND
*        TO THE MENU BOX.
*
CYAN_BOX
	MOVE	A8,-*A12,L		;PUSH THE MENU PTR

	MOVI	COLOR_RED,A9
	CALLR	COL_INST		;THIS PRINTS BOX AND STASHES 
*					;CENTER X AT *A13(PDATA),W
	move	@_cabinet_type,a8
	jrz	_x_inst1
	movi	MM_INST1_T2,a8
	jruc	_x_inst1a
_x_inst1:
	MOVI	MM_INST1,A8		;POINT AT INSTRUCTIONS MESSAGE
_x_inst1a:
	JSRP	C_PD_M

	move	@_cabinet_type,a8
	jrz	_x_inst2
	movi	MM_INST2_T2,a8
	jruc	_x_inst2a
_x_inst2:
	MOVI	MM_INST2,A8		;POINT AT INSTRUCTIONS MESSAGE
_x_inst2a:
	JSRP	C_PD_M

	MOVE	*A12+,A8,L		;GET BACK MENU PTR.
	RETP

**************************************************************************
*                                                                        *
*          COL_INST                                                      *
*                                                                        *
*          THIS PRINTS OUT THE "CYAN" INSTRUCTION BOX                    *
*          IN THE COLOR SPECIFIED BY A9.                                 *
*                                                                        *
**************************************************************************
COL_INST
*
*	WE NEED TO DETERMINE LEFT AND RIGHT X
*
	CALLR	STUFF_MENU_PROCESS		;MOVE DATA INTO PDATA AREA
	CALLR	MEN_NUMS			;GET THE NUMBERS FOR THIS MENU
	MOVE	A6,*A13(PDATA),W		;STASH THE X CENTER
	ADDI	10000H*INST_ULY,A4		;UPPER LEFT Y
	ADDI	10000H*INST_LRY,A5		;UPPER LEFT X
	CALLR	STD_BORD	;TACO BELL HAS YOUR ORDER, MAKE A RU-UUUN......
	RETS

**************************************************************************
*                                                                        *
*          MEN_NUMS                                                      *
*                                                                        *
*          THIS IS CALLED TO GET SOME NUMBERS ASSOCIATED                 *
*          WITH A MENU BOX.                                              *
*                                                                        *
*          THIS RETURNS:                                                 *
*                                                                        *
*          A4 = LEFT X                                                   *
*          A5 = RIGHT X                                                  *
*          A6 = CENTER X                                                 *
*                                                                        *
**************************************************************************
MEN_NUMS
	CALLR	MENU_UL_A4_A5		;LEFT X IN A4
	CALLR	MENU_LR_A6_A5		;RIGHT X IN A6
	MOVE	A6,A5			;COPY RIGHT X INTO A5
	ADD	A4,A6			;FIND CENTER
	SRL	1,A6			;A6 NOW HAS CENTER X (FOR LATER)
	RETS

**************************************************************************
*                                                                        *
*          C_PD_M                                                        *
*                                                                        *
*          THIS PRINTS A L_MESS MESSAGE PASSED IN A8, CENTERED           *
*          ON THE X STORED AT *A13(PDATA),W                              *
*                                                                        *
**************************************************************************
C_PD_M
	CALLA	LM_SETUP		;SETUP THE MESSAGE
	ANDI	0FFFF0000H,A9		;REMOVE X
	MOVE	*A13(PDATA),A3,W	;GET THE X
	ADD	A3,A9			;PUT OUR X IN
;	JUMP	A1			;AND "CALL" THE ROUTINE
	JAUC	PRINTF

**************************************************************************
*                                                                        *
*          WT_ADV                                                        *
*                                                                        *
*          WAIT TILL ADVANCE.  THIS HOLDS CONTROL UNTIL ADVANCE          *
*          BUTTON IS PRESSED.                                            *
*                                                                        *
**************************************************************************
WT_ADV
	SLEEP	2
WT_A6
	CALLR	GET_ADV			;SCAN THE BUTTON
	JRNZ	WT_ADV			;NOT PRESSED. 
	RETP

BEEP_1	.WORD	0F3DFH,010H,08082H,0	;MENU ITEM SCAN SOUND
WOLF	.WORD	0F3DFH,010H,080AEH,0	;MENU ITEM SELECT SOUND
UHOH	.WORD	0F3DFH,010H,0813AH,0	;FAILURE OF ANY KIND

**************************************************************************
*                                                                        *
*          WW_ADV                                                        *
*                                                                        *
*          WAIT WHILE ADVANCE.  THIS HOLDS CONTROL WHILE ADVANCE         *
*          BUTTON IS HELD (OR STUCK).                                    *
*                                                                        *
**************************************************************************
WW_ADV
	SLEEP	2
	CALLR	GET_ADV
	JRZ	WW_ADV
	RETP

**************************************************************************
*                                                                        *
*          GET_ADV                                                       *
*                                                                        *
*          THIS GETS PHYSICAL STATE OF ADVANCE BUTTON.                   *
*                                                                        *
*          .EQ.    PRESSED                                               *
*          .NE.    OPEN                                                  *
*                                                                        *
**************************************************************************
GET_ADV
	MMTM	SP,A0
	MOVE	@COINS,A0,W	;FETCH COIN SWITCHES (LOOKING FOR ADVANCE)
;	ANDI	ADV_BIT,A0	;KEEP ADVANCE BIT.
	MMFM	SP,A0
	RETS

**************************************************************************
*                                                                        *
*          GET_MENU                                                      *
*                                                                        *
*          This routine is called (via JSRP) to display a menu on        *
*          screen and receive a selection from the operator.             *
*                                                                        *
*          The menu descriptor is passed in A8.                          *
*                                                                        *
*          The selection number is returned in a8. (line 1 = 1)          *
*          The routine address is returned in a9.                        *
*          A10 is returned non-zero if advance was the button used       *
*                                                                        *
*          A menu (pointed to by A8) is defined as follows:              *
*                                                                        *
*                      FONT TO BE USED             (LONG)                *
*                      X FOR LEFT MARGIN           (WORD)                *
*                      Y FOR TOP LINE              (WORD)                *
*                      DY PER ENTRY                (WORD)                *
*                      TEXT_COLOR                  (WORD)                *
*                      HEIGHT OF SELECTION BAR     (WORD)                *
*                      DX FROM TOP OF TEXT TO SEL. BAR  (WORD)           *
*                                                                        *
*          A9 POINTS AT ENTRY TO START WITH                              *
*                                                                        *
*          Then for each entry:                                          *
*                                                                        *
*                      TEXT POINTER        (LONG)                        *
*                      ACTIVATION ROUTINE  (LONG)                        *
*                                                                        *
*          The list is terminated by a zero.                             *
*                                                                        *
*          This routine forks a separate process to do the work          *
*          for it.  Therefore the caller has full use of                 *
*          the PDATA area.                                               *
*                                                                        *
**************************************************************************
*
*        Equates for GET_MENU slave process.
*
MEN_OFF	EQU	PDATA			;WORD-OFFSET INTO MENU OF SELECTION
MEN_ROUT EQU	MEN_OFF+WORD_SIZE	;LONG-ROUTINE FOR SELECTION
MEN_ROM	EQU	MEN_ROUT+LONG_SIZE	;LONG-POINTER TO ROM STRUCTURE
MEN_ULX	EQU	MEN_ROM+LONG_SIZE	;WORD-LEFT X  (CENTER X WHEN CENTERING)
MEN_ULY	EQU	MEN_ULX+WORD_SIZE	;WORD-TOP Y
MEN_DY	EQU	MEN_ULY+WORD_SIZE	;WORD-Y UNITS PER ENTRY
MEN_COLR EQU	MEN_DY+WORD_SIZE	;WORD-COLOR FOR ENTRIES
MEN_BAR	EQU	MEN_COLR+WORD_SIZE	;WORD-HEIGHT OF SELECTION BAR
MEN_BDY	EQU	MEN_BAR+WORD_SIZE	;WORD-DY FROM TOP OF TEXT TO TOP OF BAR.
MEN_BDX	EQU	MEN_BDY+WORD_SIZE	;WORD-DX FROM LEFT OF WORD TO LEFT OF BAR
MEN_BWID EQU	MEN_BDX+WORD_SIZE	;WORD-WIDTH OF BAR
MEN_SCOL EQU	MEN_BWID+WORD_SIZE	;WORD-COLOR OF SELECTED TEXT
MEN_TPTR EQU	MEN_SCOL+WORD_SIZE	;LONG-POINTER TO BEGINNING OF TEXT ENTRIES.
MEN_ENTS EQU	MEN_TPTR+LONG_SIZE	;WORD-NUMBER OF ENTRIES IN MENU
MEN_CUR  EQU	MEN_ENTS+WORD_SIZE	;WORD-CURRENT SELECTION (1ST IS 1)
MEN_WALK EQU	MEN_CUR+WORD_SIZE	;WORD-NUMBER OF ENTRY WE'RE ON AS WE WALK
MEN_STIK EQU	MEN_WALK+WORD_SIZE	;LONG-"STUCK" STATE OF SWITCHES
MEN_ACT  EQU	MEN_STIK+LONG_SIZE	;LONG-SWITCH WE'RE ACTING ON. (BIT)
MEN_TYPO EQU	MEN_ACT+LONG_SIZE	;WORD-TYPOMATIC COUNTER
MEN_HITS EQU	MEN_TYPO+WORD_SIZE	;WORD-CONSECUTIVE TYPOMATIC HITS
MEN_ADV  EQU	MEN_HITS+WORD_SIZE	;WORD-NON-ZERO IF ADVANCE WAS BUTTON USED

WORD_ENTS EQU	(MEN_TPTR-MEN_ULX)/WORD_SIZE	;NUMBER OF WORD ENTRIES

B_MENU
	MOVI	BD_SLAVE,A7
	JRUC	GMJMP

GET_MENU
	MOVI	GM_SLAVE,A7		;THIS IS ROUTINE
GMJMP
	MOVI	MENU_PID,A1		;THIS IS ID
	CALLA	GETPRC			;CREATE IT

	MOVE	A0,A10			;SAVE HIS POINTER
GM1
	SLEEP	2

	MOVI	MDUN_PID,A0
	CALLA	EXISTP_ALL		;WAIT FOR ID TO CHANGE TO THIS!

	JRZ	GM1			;LOOP UNTIL IT EXISTS!

	MOVE	*A10(MEN_OFF),A8,W	;RETURN OFFSET OF SELECTION
	MOVE	*A10(MEN_ROUT),A9,L	;AND ROUTINE THAT WAS SELECTED.
	MOVE	*A10(MEN_ADV),A10,W	;INDICATE WHETHER ADVANCE WAS USED

	MOVI	MDUN_PID,A0
	CALLA	KILLPROC_ALL		;KILL THE HANGING MENU GETTER!
	RETP				;AND RETURN
         
**************************************************************************
*                                                                        *
*          GM_SLAVE                                                      *
*                                                                        *
*          This displays the menu.......moves the selection bar          *
*          and returns the selection information by stuffing             *
*          it in its process area and changing its ID to                 *
*          MDUN_PID once selection is made.                              *
*                                                                        *
*          On entry....A8 points at the GET_MENU data structure.         *
*                      A9 is which entry to start with selected.         *
*                                                                        *
**************************************************************************
BD_SLAVE
	CALLR	MENU_BORDER		;DRAW THE BORDER FOR SELCTIONS.
GM_SLAVE
	JSRP	ST_STICK		;TELL STICK(S) AND BUTTONS WE'RE STARTING.

	CALLR	STUFF_MENU_PROCESS	;MOVE DATA INTO PDATA AREA
*
*	PLOT ENTIRE MENU
*
*	DO_MENU_LINE WILL RETURN CARRY SET
*	WHEN WE GET BEYOND THE END.
*
	MOVK	1,A0			;SETUP FOR LINE 1.
DO_ANOTHER_LINE
	MOVE	A0,*A13(MEN_WALK),W	;WALK THROUGH.

	JSRP	DO_MENU_LINE		;PUT OUT LINE IN A0.
	MOVE	*A13(MEN_WALK),A0,W	;GET BACK THE COUNTER

	INC	A0			;MOVE TO NEXT ENTRY.
	MOVE	*A13(MEN_ENTS),A1,W	;SEE IF WE'RE DONE.
	CMP	A1,A0
	JRLS	DO_ANOTHER_LINE
*
*	MAIN MENU PLOTTED......NOW LET THE DMA UN-LOAD BEFORE PLOTTING HELP
*
	CALLR	PLOT_HELP		;PLOT HELP FOR 1ST IF NECESSARY

*
*	NOW WE JUST WANT TO UPDATE BASED ON STICK...ACT
*	ON BUTTONS!
*
*	RESPONSES:   UP....DOWN....BUTTON....NOTHING....
*
*	NOTHING = 0
*	UP = 1
*	DOWN = 2
*	BUTTON = 3
*
*	A0 = RESPONSE
*	A1 = MEN_CUR VALUE.
*
	
	CLR	A0
	MOVE	A0,*A13(MEN_HITS),W
	MOVE	A0,*A13(MEN_TYPO),L
MENU_LOOP
	SLEEP   1
        JSRP    GETSTICK		;CHECK OUT THE PLAYER BOARD
        MOVE    A0,A0
	JRNZ	ML1			;BR = GOT SOMETHING
	MOVE	A0,*A13(MEN_HITS),W	;CLEAR TIMER AND DIRECTION
	MOVE	A0,*A13(MEN_TYPO),W
	JRUC	MENU_LOOP
ML1
	MOVE	*A13(MEN_HITS),A1,W	;GET LAST DIRECTION
	ANDI	7,A1			;MASK OFF REPEAT BIT
	CMP	A0,A1
	JRZ	ML2			;BR = YES, STILL SAME THING
	MOVE	A0,*A13(MEN_HITS),W
	CLR	A1
	MOVE	A1,*A13(MEN_TYPO),W	;CLEAR THE TIMER
	JRUC	MLDONE			;PROCESS INITIAL HIT
ML2
	MOVE	*A13(MEN_HITS),A1,W	;SNAG THE REPEAT BIT
	ANDI	80H,A1
	JRNZ	ML3			;BR = IN REPEAT MODE
	MOVE	*A13(MEN_TYPO),A0,W	;GET TIMER
	INC	A0
	MOVE	A0,*A13(MEN_TYPO),W
	CMPI	15,A0
	JRLO	MENU_LOOP		;GO BACK TO SLEEP
	CLR	A0
	MOVE	A0,*A13(MEN_TYPO),W	;CLEAR OUT THE TIMER
	MOVE	*A13(MEN_HITS),A1,W
	MOVE	A1,A0
	ORI	80H,A1			;PUT UPPER BIT ON
	MOVE	A1,*A13(MEN_HITS),W	;SET DIRECTION WITH REPEAT ON
	JRUC	MLDONE
ML3
	MOVE	*A13(MEN_TYPO),A0,W	;GET TIMER
	INC	A0
	MOVE	A0,*A13(MEN_TYPO),W
	CMPI	5,A0
	JRLO	MENU_LOOP		;GO BACK TO SLEEP
	CLR	A0
	MOVE	A0,*A13(MEN_TYPO),W	;CLEAR OUT THE TIMER
	MOVE	*A13(MEN_HITS),A0,W
	ANDI	7H,A0			;TURN OFF REPEAT BIT
MLDONE
	MOVE	*A13(MEN_CUR),A1,W	;GET CURRENT ENTRY...IN A1

	cmpi	4,a0			;ESCAPE BUTTON?
	jrz	menu_escape		;YEP KILL OFF THIS LEVEL

	CMPI	3,A0			;BUTTON?
	JRZ	MENU_BUTTON		;YEP....WE'RE OUT OF HERE.

	CMPI	2,A0
	JRZ	MENU_DOWN		;ITS DOWN....
*
*	REQUEST TO GO UP....ARE WE AT #1
*
	mmtm	sp,a0,a1
	move	@SCODE,a0,W
	move	@DCODE,a1,W
	or	a0,a1
	jrz	_no_scode_sub
	movk	2,a1
	move	a1,@_in_volume_adjust,1
	subk	1,a0
	jrnn	_scode_ok
	clr	a0
_scode_ok:
	move	a0,@SCODE,W
	mmfm	sp,a0,a1
	jruc	MENU_BUTTON
_no_scode_sub:
	mmfm	sp,a0,a1
	CMPI	1,A1			;WELL?
	JRLS	MENU_LOOP		;YEP....IGNORE

	JSRP	UN_SELECT		;PUT BACK THE OLD "CURRENT ONE
	MOVE	*A13(MEN_CUR),A0,W	;GET CURRENT ENTRY
	DEC	A0			;MAKE ONE LESS.
	mmtm	sp,a0,a1
	SOUND1	DIAG_UP
	mmfm	sp,a0,a1
	JRUC	JOIN_DOWN		;NOW PLOT THE NEW ONE.

MENU_DOWN
	mmtm	sp,a0,a1
	move	@SCODE,a0,W
	move	@DCODE,a1,W
	or	a0,a1
	jrz	_no_scode_add
	movk	2,a1
	move	a1,@_in_volume_adjust,1
	addk	1,a0
	move	a0,@SCODE,W
	mmfm	sp,a0,a1
	jruc	MENU_BUTTON
_no_scode_add:
	mmfm	sp,a0,a1
	MOVE	*A13(MEN_ENTS),A2,W	;GET NUMBER IN MENU
	CMP	A2,A1			;ARE WE AT MAX
	JRHS	MENU_LOOP		;YEP...NO ACTION

	JSRP	UN_SELECT		;PUT BACK THE OLD "CURRENT ONE

	MOVE	*A13(MEN_CUR),A0,W	;GET CURRENT ENTRY
	INC	A0			;MAKE THIS THE NEXT.

	mmtm	sp,a0,a1
	SOUND1	DIAG_DOWN
	mmfm	sp,a0,a1

JOIN_DOWN
	MOVE	A0,*A13(MEN_CUR),W	;PUT BACK
	JSRP	DO_MENU_LINE		;PUT OUT LINE IN A0.
*
*	MAKE THE "DINK" SOUND HERE FOR ENTRY TO ENTRY MOVEMENT 
*
	CALLR	PLOT_HELP		;PLOT HELP NEW ONE
	SLEEP	1			;DELAY BEEP 1 FRAME
;	SOUND1	BEEP_1			;MAKE A BEEP.
	JRUC	MENU_LOOP		;AND WAIT FOR NEXT RESPONSE.
*
*	CONTROL COMES HERE WHEN A BUTTON IS PRESSED
*
*	The selection number is returned in a8. (line 1 = 1)          
*	The routine address is returned in a9.                        

MENU_BUTTON
*
*	A0 HAS A 3.
*	A2 HAS THE BUTTON BIT.....IS IT ADVANCE?
*
	mmtm	sp,a0
	move	@_in_volume_adjust,a0,L
	jrnz	_no_enter_sound
	SOUND1  DIAG_ENTER           ;MAKE THE CASH SOUND
_no_enter_sound:
	mmfm	sp,a0
	MOVE	*A13(MEN_ROM),A0,L
	CMPI	MEN_ADJ,A0		;SPECIAL CASE FOR MENU ADJ
	JRNZ	MBNOTADJ
	CALLA	CKDIP
	JRNZ	MBNOTADJ		;NOT USING DIP SWITCHES
	MOVE	*A13(MEN_CUR),A0,W	;GET THE SELECT ITEM
	CMPI	2,A0			;"STANDARD PRICING"
	JRZ	MBABORT
	CMPI	3,A0			;"CUSTOM PRICING"
	JRZ	MBABORT
	CMPI	4,A0			;"FREE PLAY"
	JRNZ	MBNOTADJ
MBABORT
;	SOUND1	UHOH
	JRUC	MENU_LOOP
MBNOTADJ
	CLR	A0			;NOT ADVANCE
IS_ADV
	MOVE	A0,*A13(MEN_ADV),W	;NON ZERO IF IT WAS ADVANCE

	JSRP	BUTTON_STALL		;HIGHLIGHT SELECTION AND HANG ON BUTTON

	MOVE	*A13(MEN_CUR),A0,W	;GET "CURRENT" ENTRY.
	CALLR	GET_MENU_DATA		;A1=CURRENT_OFFSET  A2=TEXT  A3=ROUTINE
	MOVE	A0,*A13(MEN_OFF),W	;STORE THE OFFSET (CHOICE NUM)
	MOVE	A3,*A13(MEN_ROUT),L	;AND THE ROUTINE POINTER
	MOVI	MDUN_PID,A0
	MOVE	A0,*A13(PROCID),W	;CHANGE OUR ID.
MENU_DONE
	SLEEP	20
	JRUC	MENU_DONE		;NOW HANG TILL DISPATCHER SEES ID.


menu_escape:
	mmtm	sp,a0,a1
	SOUND1	SOUNDS_OFF
	move	@SCODE,a0,W		;ARE WE IN SOUND REPEAT ?
	move	@DCODE,a1,W
	or	a0,a1
	jrz	mbe_norepeat		;BR = NOT REPEATING SOUNDS
	clr	a0
	move	a0,@_in_volume_adjust,1
	move	a0,@SCODE,W
	move	a0,@DCODE,W
	mmfm	sp,a0,a1
	movk	2,a0
	jruc	MENU_DOWN
mbe_norepeat:
	mmfm	sp,a0,a1
	SOUND1	DIAG_ESCAPE
	CLR	A0			;NOT ADVANCE
	MOVE	A0,*A13(MEN_ADV),W	;NON ZERO IF IT WAS ADVANCE
	JSRP	BUTTON_STALL		;HIGHLIGHT SELECTION AND HANG ON BUTTON
	MOVE	*A13(MEN_CUR),A0,W	;GET "CURRENT" ENTRY.
	CALLR	GET_MENU_DATA		;A1=CURRENT_OFFSET  A2=TEXT  A3=ROUTINE
	clr	a0
	MOVE	A0,*A13(MEN_OFF),W	;STORE THE OFFSET (CHOICE NUM)
	MOVE	A0,*A13(MEN_ROUT),L	;AND THE ROUTINE POINTER
	MOVI	MDUN_PID,A0
	MOVE	A0,*A13(PROCID),W	;CHANGE OUR ID.
	jruc	MENU_DONE

**************************************************************************
*                                                                        *
*                 MENU UTILITIES                                         *
*                                                                        *
**************************************************************************
**************************************************************************
*                                                                        *
*          BUTTON_STALL                                                  *
*                                                                        *
*          THIS IS CALLED WHEN THE MENU GETS A BUTTON HIT.               *
*          A1 HAS THE BIT OF THE BUTTON.                                 *
*                                                                        *
*          WE PAINT THE MENU SQUARE TO FEEDBACK THE HIT.                 *
*                                                                        *
*          THEN WE HANG ON THE BUTTON UNTIL ITS LET GO.                  *
*                                                                        *
**************************************************************************
BUTTON_STALL
         MOVE    A2,@LAST_BUT,L       ;PUSH THE BUTTON STATE

         MOVE    @SCODE,A0,W          ;NO CASH FOR REPEAT SOUND CODES
         MOVE    @DCODE,A1,W
         OR      A0,A1
         JRNZ    DONT_WAIT            ;ITS A SOUND REPEAT....DON'T HOLD EITHER!

         MOVE    *A13(MEN_CUR),A0,W   ;GET CURRENT SELECTION
         MOVI    COLOR_YELLOW,A1
         CALLR   MENU_BAR             ;CHANGE THE BAR COLOR.

         CALLR   GET_MENU_DATA             ;GET OUR TEXT POINTER BACK
         MOVI    COLOR_WHITE,A1            ;WHITE ON ORANGE DURING HOT MOMENT
         JSRP    MENU_TEXT                 ;AND WRITE INVERTED TEXT

         MOVE    @LAST_BUT,A8,L            ;GET BUTTON BACK
         MOVI    08H,A9                    ;MINIMUM TIME FOR BUTTON HIGHLITE

         MOVI    2AH,A10              ;.5 SECONDS OF ADVANCE HOLD-DOWN
*                                     ;WILL EXIT TEST MODE.
WAIT_FOR_RELEASE
;         CMPI    ADV_HIGH,A8               ;IS IT ADVANCE BUTTON?
;         JRNZ    NOT_ADV                   ;NOPE.....NEVER MIND

;         DEC     A10                  ;1 LESS TIME UNIT
;         JRZ     DIAG_EX            ;IF HE HOLDS ADVANCE...WE'RE GONE!

NOT_ADV  SLEEP   1
         
         MOVE    A9,A9                ;REDUCE FOR HELD TIME
         JRZ     WAIT_1               ;ZEROED OUT ALREADY.
         DEC     A9

WAIT_1
         CALLR   FORM_SWS        ;WAIT FOR THIS ONE TO GO TO ZERO
         AND     A8,A0                ;IS OUR BUTTON STILL DOWN?
         JRNZ    WAIT_FOR_RELEASE
*
*        ITS RELEASED...NOW SHOW ORANGE BAR FOR MINIMUM TIME

         INC     A9                   ;MAKE SURE A9 HAS 1 OR MORE
WAIT_2
         SLEEP   1
         DSJS    A9,WAIT_2

DONT_WAIT
         MOVE    *A13(MEN_CUR),A0,W   ;GET CURRENT SELECTION
         CLR     A1                   ;ERASE BAR
         CALLR   MENU_BAR             ;CHANGE THE BAR COLOR.

         CALLR   GET_MENU_DATA             ;GET OUR TEXT POINTER BACK
         MOVE    *A13(MEN_COLR),A1,W       ;RE-PLOT THE NORMAL TEXT
         JSRP    MENU_TEXT                 

         SLEEP   2                    ;NOW GIVE SOME BOUNCE PROTECTION.

         RETP

**************************************************************************
*                                                                        *
*          STUFF_MENU_PROCESS                                            *
*                                                                        *
*          THIS IS CALLED TO STUFF THE MENU ROM DATA INTO THE            *
*          CURRENT PROCESSES PDATA AREA.                                 *
*                                                                        *
**************************************************************************
STUFF_MENU_PROCESS
         MMTM    SP,A0,A1,A2,A3,A8
         MOVE    A13,A0               ;POINT IN PROCESS AREA
         ADDI    MEN_ROM,A0           ;THIS IS WHERE 1ST TIDBIT GOES
         MOVE    A8,*A0+,L            ;STORE OUR BASE POINTER IN STRUCTURE
         ADDI    MR_WORDS,A8          ;MOVE TO WORD LIST

         MOVI    WORD_ENTS,A2         ;NOW THIS MANY MORE WORDS.

GMS1     MOVE    *A8+,A1,W
         MOVE    A1,*A0+,W
         DSJS    A2,GMS1
*
*        ALL THE MENU PARAMETERS ARE NOW IN THE PDATA AREA.
*        A8 POINTS AT THE FIRST ITEM TO DISPLAY.
*
         MOVE    A8,*A13(MEN_TPTR),L  ;STORE IN PROCESS AREA.
*
*        NOW WE WANT TO FIND THE NUMBER OF ENTRIES IN THE MENU
*
         CLR     A0                        ;START AT #1.
HOW_MANY
         INC     A0                        ;MOVE TO NEXT ENTRY.
         CALLR   GET_MENU_DATA             ;GET THE PARAMETERS FOR THIS ENTRY
         MOVE    A2,A2                     ;AND SEE IF A2=0
         JRNZ    HOW_MANY                  ;ITS REAL.....PUT IT UP.

         DEC     A0                        ;PREVIOUS LINE WAS THE LAST.
         MOVE    A0,*A13(MEN_ENTS),W       ;STUFF NUMBER IN MENU.

         MOVE    A9,A9                     ;DID BOZO PASS ZERO AS CURRENT?
         JRZ     USE_LAST
         CMP     A0,A9                     ;MAKE SURE ITS NOT TOO HIGH
         JRHI    USE_LAST                  ;A9 IS TOO HIGH
         MOVE    A9,A0                     ;USE THE ONE PAST

USE_LAST MOVE    A0,*A13(MEN_CUR),W   ;MAKE ENTRY "1" CURRENT.

	MMFM    SP,A0,A1,A2,A3,A8
	RETS

**************************************************************************
*                                                                        *
*          DO_MENU_LINE                                                  *
*                                                                        *
*          A0 HAS THE LINE TO DO. (1 THROUGH N).                         *
*          PRINT TEXT NORMAL IF NOT "MEN_CUR".                           *
*          PRINT INVERT BAR FOLLOWED BY BLACK TEXT IF                    *
*          ITS THE CURRENT ENTRY.                                        *
*                                                                        *
**************************************************************************
DO_MENU_LINE
         CALLR   GET_MENU_DATA             ;GET "CURRENT" IN A1
         CMP     A0,A1                     ;IS IT "CURRENT" ENTRY?
         JRZ     DO_CURRENT_ENT            ;YEP....DO INVERSE STUFF
*
*        A0 HAS OFFSET (FOR POSITIONING)
*        A2 HAS TEXT POINTER (FOR MESSAGE)
*        A1 NEEDS COLOR FOR MESSAGE.
*
         MOVE    *A13(MEN_COLR),A1,W       ;USE THE NORMAL ENTRY COLOR
         JSRP    MENU_TEXT                 ;PUT UP THE "TEXT" PORTION.
         RETP                              ;AND RETURN

DO_CURRENT_ENT       
         MOVI    COLOR_WHITE,A1            ;DO THE BAR IN WHITE (AT A0 HEIGHT)
         CALLR   MENU_BAR                  ;PUT IT UP (A0 PRESERVED)

         CALLR   GET_MENU_DATA             ;GET OUR TEXT POINTER BACK
         MOVE    *A13(MEN_SCOL),A1,W       ;GET "SELECTED" COLOR
         JSRP    MENU_TEXT                 ;AND WRITE INVERTED TEXT
         RETP                              ;THAT'S ALL FOLKS.

**************************************************************************
*                                                                        *
*          UN_SELECT                                                     *
*                                                                        *
*          THIS IS CALLED TO "UN-SELECT" THE CURRENT ENTRY.              *
*                                                                        *
**************************************************************************
UN_SELECT
         MOVE    *A13(MEN_CUR),A0,W        ;POINT AT CURRENT ENTRY
         CLR     A1                        ;USE BLACK FOR BACKGROUND
         CALLR   MENU_BAR                  ;THIS REMOVES THE BAR.

         CALLR   GET_MENU_DATA             ;NOW GET A2 TO TEXT POINTER
         MOVE    *A13(MEN_COLR),A1,W       ;USE THE NORMAL ENTRY COLOR
         JSRP    MENU_TEXT                 ;PUT UP THE "TEXT" PORTION.
         RETP                              ;AND RETURN

**************************************************************************
*                                                                        *
*          MENU_BAR                                                      *
*                                                                        *
*          THIS IS CALLED TO PUT UP THE SELECTION BAR FOR                *
*          THE ENTRY IN A0, IN THE COLOR IN A1.                          *
*                                                                        *
*          THIS ROUTINE MUST PRESERVE A0.                                *
*                                                                        *
**************************************************************************
* STRNGLEN - RETURNS THE LENGTH, IN PIXELS, OF A GIVEN STRING		 *
* A8 = PTR TO STRING							 *
* A10 = [Y,X] SPACING OF STRING						 *
* A11 = PTR TO FONT TABLE						 *
* RETURNS:								 *
* A7 = LENGTH OF STRING							 *
* Z BIT SET IF LENGTH IS ZERO						 *
*
*        FOR FILLAREA
*
* A1 = <COLOR><PALETTE>
* A3 = DAG OF AREA [YPOS,XPOS]						 
* A4 = [Y,X] SIZE OF AREA						 
*
MENU_BAR MMTM    SP,A0,A1,A3,A4,A5,A6,A7,A8    ;SAVE THE OFFSET
         MMTM    SP,A1                     ;SAVE COLOR!
         CALLR   GET_MENU_DATA             ;GET THE TEXT POINTER
         CALLR   STLEN_SETUP               ;SETUP FOR STRLEN CALL.
         CALLA   STRNGLEN                  ;FIND WIDTH OF STRING.
*
*        A7 HAS LENGTH OF STRING.
*
*        WE NEED TO GET INTO A3 THE COORDINATES UF UPPER LEFT
*        AND A4 THE LENGTH.
*
*        IF WE'RE CENTERING, WE USE THE BAR WIDTH PARAMETER
*        ALONG THE CENTER LINE.
*
*        IF WE'RE LEFT JUSTIFIED, WE'LL LET THE BOX GO THE
*        LENGTH OF THE TEXT FOR NOW.
*
         MOVE    *A13(MEN_ULX),A3,W        ;LEFT X IN A3                    
*
*        IF WE'RE CENTERING....WE NEED TO MOVE THE "LEFT X" BACK HALF
*        THE WIDTH OF THE STRING.
*
         MOVE    *A13(MEN_ROM),A6,L        ;GET ROM POINTER
         MOVE    *A6(MR_TCAL),A6,L         ;CHECK ROUTINE
         CMPI    STRCNRM,A6
         JRNZ    NOT_CENTERING
*
*        WE'RE CENTERING....CENTER X IS IN A3
*
         MOVE    *A13(MEN_BWID),A7,W       ;A7 IS THE REGISTER FOR BAR WIDTH
         MOVE    A7,A4                     ;GET COPY IN A4
         SRL     1,A4                      ;1/2 OF WIDTH COMES OFF OF CENTER
         SUB     A4,A3                     ;A3 NOW HAS "LEFT X" 
         JRUC    CENTERING                 ;A7 IS WIDTH...A3 IS X

*
*        LEFT JUSTIFIED....DO IT THE OLD WAY!
*
NOT_CENTERING
         MOVE    *A13(MEN_BDX),A4,W        ;GET EXTRA X UNITS FOR BAR
         SUB     A4,A3

*        NOW ADD TWICE THE EXTRA X TO THE STRING LENGTH TO
*        FORM THE BAR LENGTH.
*
         SLL     1,A4                      ;NOW DOUBLE THE EXCESS DX FOR BAR
         ADD     A4,A7                     ;NOW A7 HAS WIDTH OF BAR

CENTERING
         SUBI    C_KLUDGE,A3          ;KLUDGE TO NULLIFY FINAL SPACE.

         CALLR   GET_ENTRY_Y               ;GET Y FOR ENTRY IN A5

         MOVE    *A13(MEN_BDY),A6,W        ;GET BAR DY (NEGATIVE)
         ADD     A6,A5                     ;ADJUST Y BY BAR DY
         SLL     16,A5                     ;SHIFT Y INTO POSITION

         ADD     A5,A3                     ;A3 NOW POINTS AT UPPER LEFT

         MOVE    *A13(MEN_BAR),A4,W        ;Y HEIGHT OF BAR
         SLL     16,A4                     ;IN POSITION
         ADD     A7,A4                     ;A7 HAS X WIDTH OF BAR.

         MMFM    SP,A1                     ;NOW GET COLOR BACK!
         SLL     16,A1                     ;SHIFT COLOR TO HIGH HALF (PAL. 0) 
         CALLA   FILLAREA                  ;FILL IT UP!

	MMFM    SP,A0,A1,A3,A4,A5,A6,A7,A8    ;SAVE THE OFFSET
	RETS

**************************************************************************
*                                                                        *
*          MENU_TEXT                                                     *
*                                                                        *
*          THIS IS CALLED TO DISPLAY THE TEXT FOR AN ENTRY.              *
*                                                                        *
*          A0 HAS OFFSET (FOR POSITIONING)                               *
*          A1 HAS COLOR FOR MESSAGE.                                     *
*          A2 HAS TEXT POINTER (FOR MESSAGE)                             *
*                                                                        *
*          WE NEED TO SHIFT THE DATA FOR THE TEXT ROUTINE                *
*          AS FOLLOWS:                                                   *
*                                                                        *
*          A0 = SLEEP                                                    *
*          A5 = COLOR                                                    *
*          A8 = POINTER                                                  *
*          A9 = ADDRESS                                                  *
*          A10 = SPACING                                                 *
*          A11 = FONT                                                    *
*                                                                        *
**************************************************************************
MENU_TEXT
         CALLR   GET_ENTRY_Y               ;GET Y FOR ENTRY IN A5
         SLL     16,A5                     ;SHIFT Y INTO POSITION
         MOVE    *A13(MEN_ULX),A9,W        ;GET THE X
         ADD     A5,A9                     ;A9 SET WITH SCREEN ADDRESS

;         MOVE    A1,A6                     ;COLOR -- THIS IS NARC STYLE
	MOVE	A1,A5			; FIX FOR PASSING COLORS -- JKM
	SLL	16,A5
         CLR     A0                        ;NO SLEEP

         CALLR   STLEN_SETUP

         MOVE    *A13(MEN_ROM),A1,L
         MOVE    *A1(MR_TCAL),A1,L         ;GET THE ROUTINE TO USE
;         JUMP    A1                        ;AND CALL IT!
	JAUC	PRINTF

STLEN_SETUP
         MOVE    A2,A8                     ;TEXT POINTER
         MOVI    SPACING20,A10             ;SPACING
         MOVE    *A13(MEN_ROM),A11,L
         MOVE    *A11(MR_FONT),A11,L       ;LOAD FONT
         RETS

**************************************************************************
*                                                                        *
*          MENU JOYSTICK HANDLING                                        *
*                                                                        *
**************************************************************************

**************************************************************************
*								         *
* 	ST_STICK							 *
* 									 *
* 	INITIALIZE THE STUCK STICK STUFF				 *
* 									 *
* 	ENTRY								 *
* 		NOTHING							 *
* 									 *
* 	EXIT								 *
* 		NOTHING							 *
*								         *
**************************************************************************

ST_STICK	
	CALLR	READ_SW1_CNS		; XUNIT 
	MOVE	A0,*A13(MEN_STIK),L	; BITS TO IGNORE PART 1
	RETP

**************************************************************************
*								         *
* 	GETSTICK							 *
* 									 *
* 	CHECKS OUT ALL THE STICKS ON THE BOARD AND RETURNS SOME		 *
* 	USEFUL INFO ABOUT THEM						 *
* 									 *
* 	ENTRY								 *
* 		NOTHING							 *
* 									 *
* 	EXIT								 *
* 		A0	STICK/BUTTON CONDITION				 *
* 			0 = NOTHING					 *
* 			1 = STICK UP					 *
* 			2 = STICK DOWN					 *
* 			3 = BUTTON DOWN					 *
*								         *
**************************************************************************

GETSTICK:
;
	CALLR	CKTEST			; CHECK THE TEST SWITCH
;
	MMTM	SP,A3,A4
;
;	THIS ALSO TAKES CARE OF STUCK SWITCHES
;
	CALLR	READ_SW1_CNS		; XUNIT 
	move	a0,a2

	move	@SWITCH2,a0,L
	ori	0ffff0000h,a0
	and	a0,a2

	MOVE	*A13(MEN_STIK),A0,L
	NOT	A0			; THIS IS SOOOOO GROSS
	NOT	A2
	AND	A2,A0
	NOT	A0
	MOVE	A0,*A13(MEN_STIK),L	
	AND	A0,A2			; IGNORE SOME BITS

;
;	SCAN FOR BUTTONS
;

	MOVE	A2,A4			;CHECK ALL BUTTONS
;	ANDI	00003030H,A4
; switches
	ANDI	00503030H,A4		;TEST/ESCAPE P1,2,3,or 4 a or b BUTTON ?

	JRZ	GSCKSTK			;BR = NO BUTTONS
;	ANDI	00001010H,A4		;FIRE BUTTONS?
; switches
	ANDI	00101010H,A4		;TEST P1,2,3,or 4 a BUTTON?

	JRZ	GSCK1			;BR = NO
	MOVK	2,A2
	JRUC	GSGOTBUTS
GSCK1
	MOVK	1,A2			;MUSTA BEEN AN ESCAPE
	JRUC	GSGOTESC

*
*	SCAN FOR START BUTTONS
*
GSCKSTK
	BTST	18,A2
	JRNZ	GSGOTUP
	BTST	27,A2
	JRNZ	GSGOTUP
	BTST	21,A2
	JRNZ	GSGOTDOWN
	BTST	28,A2
	JRNZ	GSGOTDOWN
GSAINTGOT
	CLR	A0
	JRUC	GSRET

GSGOTUP
	move	@_in_volume_adjust,a0,1
	cmpi	2,a0
	jrz	_up_snd_done
	move	a0,a0	
	jrnz	_noup_sound
	jruc	_up_snd_done
_noup_sound:
	ADJUST	ADJMINVOL
	move	a0,a4
	ADJUST	ADJVOLUME
	addi	-1,a0
	cmp	a4,a0
	jrge	_vol_min
	move	a4,a0
_vol_min:
	move	a0,@_volume_level,1
	move	a0,a1
	movi	ADJVOLUME,a0
	calla	PUT_ADJ
	calla	F_ADC_S
	calla	SET_VOLUME
	calla	draw_volume_scale
_up_snd_done:
	MOVK	1,A0
	JRUC	GSRET

GSGOTDOWN
	move	@_in_volume_adjust,a0,1
	cmpi	2,a0
	jrz	_down_snd_done
	move	a0,a0	
	jrnz	_nodown_sound
	jruc	_down_snd_done
_nodown_sound:
	ADJUST	ADJVOLUME
	addi	1,a0
	cmpi	256,a0
	jrlt	_vol_max
	movi	255,a0
_vol_max:
	move	a0,@_volume_level,1
	move	a0,a1
	movi	ADJVOLUME,a0
	calla	PUT_ADJ
	calla	F_ADC_S
	calla	SET_VOLUME
	calla	draw_volume_scale
_down_snd_done:
	MOVK	2,A0
	JRUC	GSRET

GSGOTBUTS
	MOVK	3,A0
	jruc	GSRET

GSGOTESC:
	movk	4,a0

GSRET
	MOVE	A0,A0			; SET THE FLAGS
	MMFM	SP,A3,A4
	RETP

**************************************************************************
*                                                                        *
*          FRST_BIT                                                      *
*                                                                        *
*          A0 HAS 1 OR MORE BITS SET....RETURN 1 OF THEM.                *
*                                                                        *
**************************************************************************
FRST_BIT MMTM    SP,A1,A2
         MOVK    1,A1            ;SHIFT TILL WE FIND IT.
FB1      MOVE    A0,A2
         AND     A1,A2
         JRNZ    GOT_IT          ;WE HAVE ON (IN A1)
         SLL     1,A1            ;SHIFT IT
         JRUC    FB1
GOT_IT   MOVE    A1,A0           ;RETURN THE BIT
	MMFM    SP,A1,A2
	RETS

**************************************************************************
*								         *
*          FORM_SWS							 *
* 									 *
*          GET THE SWITCHES....1=CLOSED.....AND SAVE			 *
*          THIS SCAN AS "LAST STATE".  RETURN:				 *
* 									 *
*          CURRENT STATE IN A0						 *
*          PREVIOUS STATE IN A1						 *
*								         *
**************************************************************************
FORM_SWS
	MOVE	*A13(MEN_STIK),A1,L	;RETURN PREVIOUS STATE
	CALLR	READ_SW1_CNS		; XUNIT GET BOTH SWITCH WORDS
	NOT	A0			;COMPLEMENT
	MOVE	A0,*A13(MEN_STIK),L	;SAVE "STUCK" STATE.
	RETS

**************************************************************************
*                                                                        *
*          GET_MENU_DATA                                                 *
*                                                                        *
*          A0 IS OFFSET OF ENTRY OF INTEREST                             *
*                                                                        *
*          RETURN  A1 = CURRENT OFFSET                                   *
*                  A2 = TEXT POINTER                                     *
*                  A3 = ROUTINE                                          *
*                                                                        *
**************************************************************************
GET_MENU_DATA
         MMTM    SP,A0                ;DON'T ALTER A0

         CALLR   PM_ENTRY     ;POINT A1 AT ENTRY

         MOVE    *A1(MENU_TEXT_PTR),A2,L   ;FETCH THE TEXT POINTER
         MOVE    *A1(MENU_ROUTINE),A3,L    ;FETCH THE ROUTINE
         MOVE    *A13(MEN_CUR),A1,W        ;RETURN CURRENT ENTRY IN A1
	MMFM    SP,A0                ;DON'T ALTER A0
	RETS

**************************************************************************
*                                                                        *
*          PM_ENTRY                                                      *
*                                                                        *
*          A0 = MENU ENTRY OF INTEREST                                   *
*          RETURN A1 -> POINTS AT <TEXT><ROUTINE><HELP> FOR THIS         *
*          ENTRY.                                                        *
*                                                                        *
**************************************************************************
PM_ENTRY
         MMTM    SP,A0
         DEC     A0                   ;INDEX FROM ZERO
         MOVI    MENU_ENTRY_SIZE,A1   ;TIMES SIZE PER ENTRY 
         MPYU    A0,A1                ;A1 CONTAINS OFFSET INTO TABLE

         MOVE    *A13(MEN_TPTR),A0,L  ;GET THE BASE OF THE MENU TEXT ENTRIES
         ADD     A0,A1                ;ADD TO OFFSET
	MMFM    SP,A0
	RETS

**************************************************************************
*                                                                        *
*          PLOT_HELP                                                     *
*                                                                        *
*          THIS ROUTINE PLOTS (OR CLEARS) THE HELP AREA                  *
*          FOR THE CURRENT ENTRY.                                        *
*                                                                        *
**************************************************************************
PLOT_HELP
         MOVE    *A13(MEN_CUR),A0,W        ;GET CURRENT ENTRY
         CALLR   PM_ENTRY          ;A1 POINTS AT GROUP
         MOVE    *A1(MENU_HELP),A8,L       ;GET HELP TABLE
         CMPI    NO_HELP,A8                ;NOT A "HELP" SITUATION?
         JRZ     NO_HELP_FOR_THIS_ONE
         CMPI    ADJ_HELP,A8               ;ADJUSTMENT HELP REQUESTED?
         JAEQ    DO_ADJH                   ;THEN DO IT IN ADJ MODULE!
         CMPI    SND_HELP,A8               ;ARE WE IN SOUND TEST?
         JREQ    DO_SHELP
         CMPI    SND_PLAY,A8
         JREQ    DO_SPLAY
         CALLR   DO_HELP_MENU
NO_HELP_FOR_THIS_ONE
         RETS

**************************************************************************
*                                                                        *
*          DO_SHELP                                                      *
*                                                                        *
*          THIS IS CALLED FOR EACH NON PLAYING ENTRY IN THE SOUND        *
*          TABLE MENU.  IT CAUSES THE SOUND BOARD TO BE SHUT             *
*          UP AND THE BOTTOM LINE (WHERE TITLES APPEAR)                  *
*          TO BE ERASED.                                                 *
*                                                                        *
**************************************************************************
DO_SHELP
	MOVE	@SND_MADE,A0,W	;DID SOMEONE MAKE A SOUND?
	JRZ	DO_SH1		;NOPE
	CLR	A0
	MOVE	A0,@SND_MADE,W	;CLEAR THIS AND RESET THE BOARD!
	MOVE	A0,@SCODE,W
	MOVE	A0,@DCODE,W
	CALLA	QSNDRST		;kill any sounds in progress
DO_SH1
	CALLR	BLNKSNAM	;BLANK OUT ANY WRITING!
	RETS
*
*	A0 CONTAINS 3 FOR SYNTHESIZER...4 FOR DIGITIZER...
*	IF CORRESPONDING "CODE" BYTE IS NON ZERO, THEN DISPLAY
*	THE TEXTLINE THAT CORRESPONDS.  ELSE BLANK OUT THE
*	AREA.
*
DO_SPLAY
	CALLR	BLNKSNAM	;BLANK OUT LAST MESSAGE
	CMPI	2,A0		;SYNTHESIZER?
	JRZ	CK_SYNT		;YEP.

	CLR	A1
	JRUC	DO_SPQX

CK_SYNT
	MOVE	@DCODE,A1,W	;HOLD INFO IF DIGITIZER WAS RUNNING
	CLR	A0
	MOVE	A0,@DCODE,W	;CLEAR OUT DIG CODE
	MOVE	@SCODE,A0	;ANY CODE
	JRZ	DO_SPQX		;NOTHING HERE.

	MOVI	STABLE,A1	;BASE OF POINTER TABLE FOR DIGITIZER
DO_SP1
	CALLR	MEN_NUMS	;A4 = LEFT X  A5 = RIGHT X
	.IF GERMAN
	SUBK	3,A4
	ADDK	6,A5
	.ENDIF
	ADDI	10000H*SND_MESS_Y,A4               ;UPPER LEFT Y
	ADDI	10000H*(SND_MESS_Y+SND_BOX_H),A5   ;UPPER LEFT X
	MOVI	COLOR_WHITE,A9
	CALLR	STD_BORD	;TACO BELL HAS YOUR ORDER, MAKE A RU-UUUN......

	DEC	A0		;INDEX FROM 1.
	SLL	5,A0
	ADD	A0,A1
	MOVE	*A1,A2,L	;NOW WE HAVE THE MESSAGE

	move	@_cabinet_type,a8,L
	jrz	_xsnd_inst
	movi	SND_INST_T2,a8
	jruc	_xsnd_insta
_xsnd_inst:
	MOVI	SND_INST,A8
_xsnd_insta:
	JSRP	L_MESS		;PUT INSTRUCTION OUT.

	MOVI	SND_SETUP,A8
	CALLA	LM_SETUP

	MOVE	A2,A8                   
	JSRP	PRINTF		;DO THE DEED
	RETS			;AND RETURN

DO_SPQX
	MOVE	A1,A1		;OUR SELECTION ISN'T RUNNING...WAS OTHER?
	JRZ	DO_SPX		;NOPE
	CALLA	QSNDRST		;KILL SOUNDS IN PROGRESS
	CLR	A0
	MOVE	A0,@SND_MADE,W	;NO RESET NECESSARY NOW
DO_SPX
	RETS

**************************************************************************
*                                                                        *
*          BLNKSNAM                                                      *
*                                                                        *
*          CALLED TO BLANK OUT THE SOUND CODE NAME DURING                *
*          SOUND TEST.                                                   *
*                                                                        *
**************************************************************************
*
*        A3 = POINTER
*        A4 = SIZE
*
BLNKSNAM
         MOVI    (SND_MESS_Y*10000H)+20H,A3
         MOVI    (SND_BOX_H*10000H)+1E0H,A4
         JAUC    BLNKAREA                  ;ITS BLANK!

**************************************************************************
*                                                                        *
*          GET_ENTRY_Y                                                   *
*                                                                        *
*          THIS RETURNS THE Y POSITIONS FOR THE ENTRY SPECIFIED          *
*          IN A0.                                                        *
*                                                                        *
*          A5 = Y VALUE IN UNITS.                                        *
*                                                                        *
**************************************************************************
GET_ENTRY_Y
         MMTM    SP,A0,A1
         MOVE    *A13(MEN_ULY),A5,W
         MOVE    *A13(MEN_DY),A1,W
         DEC     A0
         MPYU    A0,A1                ;A1 HAS OFFSET PER ENTRY
         ADD     A1,A5
	MMFM    SP,A0,A1
	RETS

**************************************************************************
*                                                                        *
*          MENU_BORDER                                                   *
*                                                                        *
*          THIS IS CALLED TO PUT A BORDER AROUND THE MENU.               *
*                                                                        *
*          A8 = MENU STRUCTURE                                           *
*          A9 = 1st item to activate as current                          *
*                                                                        *
*          BORDER IS DONE IN MENU TEXT COLOR                             *
*                                                                        *
*          THIS ASSUMES MENU IS IN THE CENTERING FORMAT                  *
*                                                                        *
**************************************************************************
*
*        1ST WE NEED TO FIND UPPER LEFT.
*
*
*        X = MENU_X - (BAR_WIDTH/2) - 2       (LESS BORDER WIDTH)
*        Y = MENU_Y - BDY                     (LESS BORDER HEIGHT)
*
*        LOWER RIGHT :
*
*        X = MENU_X + (BAR_WIDTH/2) - 2       (PLUS BORDER WIDTH)
*        Y = MENU_Y + (MENU_ENTRIES-1) * DY)) - BDY + BAR_HITE
*
*
MENU_BORDER
         MMTM    SP,A0,A1,A2,A3,A4,A5,A6,A7,A8,A9
         CALLR   STUFF_MENU_PROCESS   ;MOVE DATA INTO PDATA AREA
*
*        FIRST COMPUTE UPPER LEFT
*
         CALLR   MENU_UL_A4_A5             ;GET UPPER LEFT COORDINATES
         SLL     16,A5
         ADD     A5,A4                     ;A4 POINTS TO UPPER LEFT.
*
*        FORM LOWER RIGHT
*
         CALLR   MENU_LR_A6_A5
         SLL     16,A5                     ;SHIFT A5 DOWN
         ADD     A6,A5                     ;A5 POINTS AT LOWER RIGHT

         MOVE    *A13(MEN_COLR),A9,W       ;GET MENU TEXT COLOR
         CALLR   STD_BORD

	MMFM    SP,A0,A1,A2,A3,A4,A5,A6,A7,A8,A9
	RETS

**************************************************************************
*                                                                        *
*          MCSETUP                                                       *
*                                                                        *
*          RETURN:                                                       *
*                  A0 = CENTER OF MENU                                   *
*                  A1 = 1/2 BAR WIDTH                                    *
*                  A2 = Y FOR FIRST LINE OF TEXT OF MENU                 *
*                  A3 = DELTA Y (NEGATIVE TO GET FROM TEXT TO BAR.       *
*                                                                        *
**************************************************************************
MCSETUP
         MOVE    *A13(MEN_ULX),A0,W        ;UPPER LEFT X (ACTUALLY CENTER)
         MOVE    *A13(MEN_BWID),A1,W       ;BAR_WIDTH
         SRL     1,A1                      ;ALL CALCS USE BAR_WIDTH/2
         MOVE    *A13(MEN_ULY),A2,W        ;UPPER LEFT Y
         MOVE    *A13(MEN_BDY),A3,W        ;DELTA Y (NEGATIVE)
         RETS


**************************************************************************
*                                                                        *
*          MENU_UL_A4_A5                                                 *
*                                                                        *
*          RETURN WINDOW UPPER LEFT CORNER                               *
*                                                                        *
*          A4 = X                                                        *
*          A5 = Y                                                        *
*                                                                        *
**************************************************************************
MENU_UL_A4_A5
         MMTM    SP,A0,A1,A2,A3
         CALLR   MCSETUP                   ;STUFF THE REGGIES
         MOVE    A0,A4                     ;FORM ULX
         SUB     A1,A4
         SUBI    C_KLUDGE,A4          ;A4 HAS UPPER LEFT X

         MOVE    A2,A5
         ADD     A3,A5                     ;A5 HAS UPPER LEFT Y

         SUBI    MB_XWID+GAP,A4            ;NOW WE POINT AT UPPER LEFT FOR FRAME
         SUBI    MB_YWID+GAP,A5
	MMFM    SP,A0,A1,A2,A3
	RETS

**************************************************************************
*                                                                        *
*          MENU_LR_A6_A5                                                 *
*                                                                        *
*          RETURN WINDOW LOWER RIGHT CORNER                              *
*                                                                        *
*          A6 = X                                                        *
*          A5 = Y                                                        *
*                                                                        *
**************************************************************************
MENU_LR_A6_A5
         MMTM    SP,A0,A1,A2,A3
         CALLR   MCSETUP                   ;STUFF THE REGGIES

         MOVE    A0,A6                     ;LOWER RIGHT X
         ADD     A1,A6
         SUBI    C_KLUDGE,A6          ;THIS IS THE X

         MOVE    *A13(MEN_ENTS),A0,W       ;THIS IS LAST ENTRY
         CALLR   GET_ENTRY_Y               ;A5 HAS THE Y FOR THE LAST ENTRY
         ADD     A3,A5                     ;A5 NOW HAS TOP OF LAST BOX
         MOVE    *A13(MEN_BAR),A7,W        ;HEIGHT OF BAR
         ADD     A7,A5                     ;A5 NOW HAS LOWER RIGHT Y

         ADDI    MB_YWID+GAP,A5
         ADDI    MB_XWID+GAP,A6            ;THIS IS END OF BORDER
	MMFM    SP,A0,A1,A2,A3
	RETS


**************************************************************************
*                                                                        *
*          F_TITLE                                                       *
*                                                                        *
*          THIS IS CALLED TO FRAME A TITLE IN THE SAME WIDTH             *
*          AS THE MAIN TITLE.                                            *
*                                                                        *
*          A0 = Y LEVEL OF 15 POINT TEXT                                 *
*          A9 = COLOR                                                    *
*                                                                        *
**************************************************************************
F_TITLE  MMTM    SP,A4,A5,A0
         MOVE    A0,A4           ;COPY Y
;         SUBI    12,A4
	SUBI	8,A4
         SLL     16,A4
         ADDI    TIT_ULX,A4      ;UPPER LEFT SET

         MOVE    A0,A5           ;LOWER RIGHT
;         ADDI    27,A5
	ADDI	23,A5
         SLL     16,A5
         ADDI    TIT_LRX,A5      ;LOWER RIGHT SET

         CALLR   STD_BORD       ;TACO BELL HAS YOUR ORDER, MAKE A RU-UUUN......
	MMFM    SP,A4,A5,A0
	RETS

FIRST_BORDER_COLOR       EQU     0E0E0H
LAST_BORDER_COLOR        EQU     0EFEFH
**************************************************************************
*                                                                        *
*          G_BORDER                                                      *
*                                                                        *
*          THIS IS CALLED TO DO A "HSTD TABLE" TYPE CYCLING              *
*          BORDER.  THIS ROUTINE GETS:                                   *
*                                                                        *
*          A4 = UPPER LEFT Y,X                                           *
*          A5 = LOWER RIGHT Y,X                                          *
*          A6 = NUMBER OF SLICES GOING IN.                               *
*                                                                        *
**************************************************************************
G_BORDER MMTM    SP,A0,A1,A2,A3,A4,A5,A6
         MOVI    10001H,A0                 ;1 BY 1 DIMENSION

         MOVI    LAST_BORDER_COLOR,A9      ;USE LAST ONE 1ST
NEXT_RING
         CALLR   DOBORDER                  ;DO THIS RING

         MOVI    10001H,A1                  ;THIS IS 1 UNIT IN X AND Y
         ADDXY   A1,A4
         SUBXY   A1,A5

         SUBI    101H,A9
         CMPI    FIRST_BORDER_COLOR,A9
         JRHS    COLOK
         MOVI    LAST_BORDER_COLOR,A9

COLOK    DSJS    A6,NEXT_RING
	MMFM    SP,A0,A1,A2,A3,A4,A5,A6
	RETS

**************************************************************************
*                                                                        *
*          DOBORDER                                                     *
*                                                                        *
*          THIS IS CALLED TO DRAW A BORDER FRAME.                        *
*                                                                        *
*          A4 = UPPER LEFT Y,X                                           *
*          A5 = LOWER RIGHT Y,X                                          *
*          A0 = Y,X WIDTH OF BORDER                                      *
*          A9 = COLOR OF BORDER.                                         *
*                                                                        *
*          THIS ROUTINE *** CLEARS OUT ALL AREA INSIDE THE BORDER***     *
*          AS A FUNCTION OF ITS OPERATION.                               *
*                                                                        *
*          THE BORDER IS DONE IN THE "FIXED" PALETTE                     *
*                                                                        *
*          IT IS ASSUMED THAT THE DISPLAY SYSTEM IS RUNNING!             *
*                                                                        *
**************************************************************************
*
* A1 = <COLOR><PALETTE>
* A3 = DAG OF AREA [YPOS,XPOS]						 
* A4 = [Y,X] SIZE OF AREA						 
*
DOBORDER
	MMTM	SP,A0,A1,A2,A3,A4,A5,A6,A7,A8,A9
	MOVE	A9,A1			;GET COLOR
	SLL	16,A1			;COLOR ON TOP..PALETTE 0
*
*	NOW WE NEED TO MAKE 4 BARS!
*
	MOVE	A0,A2			;SEPARATE DELTA
	ANDI	SX_MASK,A0
	ANDI	SY_MASK,A2

	MOVE	A4,A6			;UPPER LEFTS HERE
	MOVE	A4,A7

	MOVE	A5,A8			;LOWER RIGHTS HERE
	MOVE	A5,A9

	ANDI	SX_MASK,A6		;LEFT X
	ANDI	SX_MASK,A8		;RIGHT X

	ANDI	SY_MASK,A7		;TOP Y
	ANDI	SY_MASK,A9		;BOTTOM Y

*
*	FIRST BAR GOES FROM ORIGINAL UL XY TO RIGHT X
*	AND TOP Y+DELTA Y
*
*	A3 IS ORIGINAL A4 PASSED.
*	FORM DESTINATION IN A4
*
	MOVE	A4,A3

	MOVX	A8,A4
	MOVY	A7,A4
	ADDXY	A2,A4			;ADD THE DELTA

	CALLR	DO_A_LINE		;DO THIS LINE
*
*	GOING AROUND CLOCKWISE.....THIS ONE STARTS AT RIGHT X-DELTA
*	AND TOP Y
*
	MOVX	A8,A3
	SUBXY	A0,A3
	MOVY	A7,A3
*
*	THIS IS THE NATURAL LOWER RIGHT CORNER
*
	MOVX	A8,A4
	MOVY	A9,A4

	CALLR	DO_A_LINE
*
*	NOW FOR BOTTOM LINE.....A4 IS STILL SET!
*
	MOVX	A6,A3
	MOVY	A9,A3
	SUBXY	A2,A3

	CALLR	DO_A_LINE
*
*	LEFT WALL....FROM UPPER LEFT
*
	MOVX	A6,A3
	MOVY	A7,A3

	MOVX	A6,A4
	ADDXY	A0,A4
	MOVY	A9,A4

	CALLR	DO_A_LINE

	MMFM	SP,A0,A1,A2,A3,A4,A5,A6,A7,A8,A9
	RETS

DO_A_LINE
	MMTM	SP,A4
	SUBXY	A3,A4           ;FORM DISTANCE
	CALLA	FILLAREA        ;AND DO THE FILL
	MMFM	SP,A4
	RETS

STD_BORD
	MMTM	SP,A0
	MOVI	BORDER_SIZE,A0
	CALLA	DOBORDER
	MMFM	SP,A0
	RETS

**************************************************************************
*                                                                        *
*          DO_HELP_MENU                                                  *
*                                                                        *
*          THIS IS CALLED TO DISPLAY A HELP MENU FOR THE CURRENT         *
*          MENU ENTRY.                                                   *
*                                                                        *
*          A HELP MENU IS DEFINED AS FOLLOWS:                            *
*                                                                        *
*          HM_JUST         WORD    0=CENTER   1=LEFT                     *
*          HM_COLOR        WORD    COLOR OF MENU                         *
*          HM_ENTS         WORD    NUMBER OF LINES IN MENU               *
*                          LONG    LONG WORD POINTERS FOR EACH LINE!     *
*                                                                        *
*          THE PROCESS AREA IS FILLED WITH THE CURRENT MENU              *
*          PARAMETERS.                                                   *
*                                                                        *
*          A8 = POINTER TO HELP MENU STRUCTURE ABOVE                     *
*                                                                        *
**************************************************************************
DO_HELP_MENU
         CALLR   BLNKHELP

         MOVE    A8,A8                ;CHECK IF HELP MENU EXISTS.
         JRZ     DHMX                 ;NOPE JUST CLEARING WAS OUR JOB.

         MOVE    *A13(MEN_CUR),A0,W   ;THIS IS CURRENT ENTRY
         MOVE    A0,A11               ;PASS ENTRY NUMBER IN A11
         CALLR   GET_ENTRY_Y          ;A5 HAS THE Y FOR THE CURRENT ENTRY
*
*        NOW WE NEED TO MOVE TO MAKE TOP ENTRY BOX LINE UP.
*
         MOVE    *A13(MEN_BDY),A10,W  ;THIS IS NEGATIVE TO GIVE US BOX TOP
         ADD     A5,A10               ;NOW WE HAVE BOX TOP

         MOVE    *A13(MEN_BAR),A5,W   ;GET BAR HEIGHT
         SRL     1,A5                 ;FIND CENTER OF BAR
         ADD     A5,A10               ;NOW WE'RE AT BAR CENTER.

*         SUBI    MB_YWID+GAP,A10      ;THIS IS MAIN MENU TOP. (FOR TOP ENTRY)

         MOVI    H_SLAVE,A7        ;FORK OFF SO IT CAN USE PDATA!
         CALLA   P_FORK               ;START UP ANOTHER W/ SAME ID TO FLASH!
DHMX     RETS

**************************************************************************
*                                                                        *
*          BLNKHELP                                                      *
*                                                                        *
*          THIS IS CALLED TO BLANK OUT THE HELP AREA.  IT IS             *
*          USED BY BOTH THE "NORMAL" HELP PLOTTER AND IS                 *
*          CALLED BY THE ADJUSTMENT HELP PROGRAM.                        *
*                                                                        *
*          THIS RETURNS THE LEFT X FOR THE HELP MENU IN A9               *
*                                                                        *
**************************************************************************
BLNKHELP
         MMTM    SP,A3,A4,A5,A6
         CALLR   MENU_LR_A6_A5        ;GET RIGHT X OF MAIN MENU IN A6
         MOVE    A6,A9                ;PASS TO HELP MENU SLAVE
*
*        NOW BLANK OUT THE "HELP" REGION
*
         MOVE    A6,A3                ;UPPER LEFT X OF REGION TO BLANK OUT
         ADDI    INST_ULY*10000H,A3   ;THIS IS UPPER LEFT OF BLOCK

         MOVI    TIT_LRX+(10000H*400),A4 ;COORDINATE OF LOWER RIGHT OF HELP AREA
         SUBXY   A3,A4                   ;THIS IS SIZE OF REGION TO BLANK
         CALLA   BLNKAREA                ;BLANK OUT THE HELP AREA
         ADDI    BOX_XGAP,A9             ;RETURN X FOR HELP MENUS
	MMFM    SP,A3,A4,A5,A6
	RETS

P_FORK
        MMTM    SP,A1
        MOVE    *A13(PROCID),A1,W    ;PASS OUR ID TO FORKED PROCESS
        CALLA   GETPRC               ;MAKE THE PROCESS
	MMFM    SP,A1
	RETS


**************************************************************************
*                                                                        *
*          H_SLAVE                                                       *
*                                                                        *
*          THIS IS A PROCESS CREATED TO PLOT THE HELP BOX.               *
*          IT DOES ITS PLOTTING THEN DIES.   THIS ALLOWS IT              *
*          TO USE THE PDATA AREA WITHOUT DISTURBING THE CALLER.          *
*                                                                        *
*          A8 = POINTER TO HELP BOX STRUCTURE                            *
*          A9 = LEFT MARGIN FOR THE HELP BOX.                            *
*          A10 = Y OF CENTER OF BOX ...HIGH HALF IS ZERO FOR Y CENTING   *
*                IF HIGH HALF IS NON-ZERO, THEN THIS IS TOP OF BOX       *
*                                                                        *
**************************************************************************
HM_JUST          EQU     0
HM_COLOR         EQU     HM_JUST+WORD_SIZE
HM_ENTS          EQU     HM_COLOR+WORD_SIZE
HM_DATA          EQU     HM_ENTS+WORD_SIZE      ;ENTRY POINTERS

HS_ROUT          EQU     PDATA             ;LONG-TEXT ROUTINE
HS_X             EQU     HS_ROUT+LONG_SIZE ;WORD-X FOR TEXT ROUTINE
HS_Y             EQU     HS_X+WORD_SIZE    ;WORD-CURRENT Y
HS_ENTS          EQU     HS_Y+WORD_SIZE    ;WORD-ENTRIES LEFT TO DO
HS_COLOR         EQU     HS_ENTS+WORD_SIZE ;WORD-COLOR OF MENU
HS_PTR           EQU     HS_COLOR+WORD_SIZE ;LONG-CURRENT TEXT POINTER

H_SLAVE
*
*        A9 HAS RIGHT X OF MENU
*
         MOVE    A9,A1                     ;PUT THIS X VALUE IN A1

         MOVE    *A8(HM_JUST),A0,W         ;0 = CENTER  1=LEFT
         JRZ     HS_CENT                   ;CENTER....SETUP X ACCORDINGLY
*
*        LEFT JUSTIFY....STORE ROUTINE
*
         MOVI    STRLNRM,A0                ;LEFT JUSTIFY ROUTIN
*
*        NOW FORM X AS SOME MARGIN FROM WINDOW....
*
         ADDI    MB_XWID+HELP_X_MARGIN,A1  ;ADD MARGIN TO FORM X FOR TEXT
         JRUC    CENTER_JOIN               ;CONTINUE

HS_CENT  MOVI    STRCNRM,A0                ;USE CENTERING ROUTINE
*
*        A1 HAS LEFT X OF HELP BOX...FIND RIGHT X
*
         ADDI    TIT_LRX,A1
         SRL     1,A1                      ;THIS IS CENTER X

CENTER_JOIN
         MOVE    A1,*A13(HS_X),W           ;STORE X
         MOVE    A0,*A13(HS_ROUT),L        ;STORE ROUTINE

         MOVE    *A8(HM_ENTS),A1,W         ;GET NUMBER OF ENTRIES
         MOVE    A1,*A13(HS_ENTS),W        ;COUNT IT DOWN IN P-AREA

         MOVE    *A8(HM_COLOR),A0,W        ;GET COLOR
         MOVE    A0,*A13(HS_COLOR),W       ;STASH IT

         ADDI    HM_DATA,A8                ;POINT AT 1ST ENTRY
         MOVE    A8,*A13(HS_PTR),L         ;NOW WE'RE READY.
*
*        ALL PDATA AREA SET.....NOW WE NEED TO DRAW THE BORDER
*
*          FOR DOBORDER
*
*          A4 = UPPER LEFT Y,X                                           
*          A5 = LOWER RIGHT Y,X                                        
*          A0 = Y,X WIDTH OF BORDER                                     
*          A9 = COLOR OF BORDER.                                         
*
*        LOWER RIGHT X IS SUCH THAT IT LINES UP WITH TITLE BOX.
*        THE Y IS A BIT TRICKIER......NUMBER OF ENTRIES IS
*        SITTING IN A1
*
         MOVI    HELP_DY,A5                ;DISTANCE PER ENTRY
         MPYU    A1,A5                     ;DISTANCE FOR ALL ENTRIES
         ADDI    HELP_Y_MARGIN+(MB_YWID*2)+HELP_YLO_MARGIN,A5
*
*        A5 NOW CONTAINS FULL HEIGHT OF BOX
*
*        NOW SEE IF WE'RE CENTERING ON A10 OR IF A10 IS THE TOP.
*
         CALLR   TOP_IN_A10
*
*        NOW FORM UPPER LEFT IN A4
*
         MOVE    A10,A4                    ;MOVE Y OVER
         SLL     16,A4                     ;MAKE ROOM FOR X
         ADD     A9,A4                     ;PUT IN THE X...THIS IS UPPER LEFT!

         ADD     A10,A5                    ;ADD BASE TO OFFSET
         SLL     16,A5                     ;PUT IN Y POSITION
         ADDI    TIT_LRX,A5                ;ADD IN THE X FOR THE CORNER
*
*        NOW ADJUST FROM TOP OF BOX TO POSITION OF 
*        1ST ENTRY.
*
         ADDI    MB_YWID+HELP_Y_MARGIN,A10  ;Y OF 1ST ENTRY
         MOVE    A10,*A13(HS_Y),W           ;PUT AWAY

         MOVE    *A13(HS_COLOR),A9,W       ;GET THE COLOR FOR DOBORDER

         CALLR   STD_BORD       
*
*        NOW WE NEED TO WALK THROUGH AND PLOT THE HELP
*        MENU ENTRIES.
*
*        A0 = SLEEP
*        A1 = ROUTINE
*        A6 = COLOR
*        A8 = POINTER
*        A9 = ADDRESS
*        A10 = SPACING
*        A11 = FONT
*        A14 = FLAGS
*
NEXT_HELP
         MOVE    *A13(HS_PTR),A2,L         ;GET OUR CURRENT POINTER
         MOVE    *A2+,A8,L                 ;GET THE CURRENT MESSAGE POINTER
         MOVE    A2,*A13(HS_PTR),L         ;AND PUT POINTER BACK

         CLR     A0
         MOVE    *A13(HS_ROUT),A1,L        ;ROUTINE IN A1
;         MOVE    *A13(HS_COLOR),A6,W       ;STUFF COLOR -- OLD NARC STYLE
        MOVE    *A13(HS_COLOR),A5,W       ;STUFF COLOR 
	SLL	16,A5

         MOVE    *A13(HS_Y),A9,W           ;GET Y
         SLL     16,A9                     ;SHIFT INTO PLACE
         MOVE    *A13(HS_X),A10,W
         ADD     A10,A9                    ;A9 IS NOW POINTING AT SCREEN

         MOVI    SPACING07,A10             ;SPACING
         MOVI    RD7FONT,A11               ;FONT IS BABY FONT
         JSRP    PRINTF                  ;PRINT IT OUT!

         MOVE    *A13(HS_Y),A9,W           ;GET THE Y
         ADDI    HELP_DY,A9                ;KICK IT
         MOVE    A9,*A13(HS_Y),W           ;PUT IT BACK

         MOVE    *A13(HS_ENTS),A0,W        ;ENTRY COUNT
         DEC     A0
         MOVE    A0,*A13(HS_ENTS),W        ;PUT IT BACK
         JRNZ    NEXT_HELP

         JAUC    SUCIDE                    ;OUR WORK IS DONE!

**************************************************************************
*                                                                        *
*          TOP_IN_A10                                                    *
*                                                                        *
*          THIS IS CALLED BY H_SLAVE TO GET THE UPPER LEFT               *
*          CORNER OF THE BOX IN A10.  A10 HAS THE PASSED PARAMETER.      *
*          A5 HAS THE HEIGHT OF THE BOX.  IF THE TOP HALF OF A10         *
*          IS ZERO, THEN THEN WE WANT THE BOX CENTER AT THE              *
*          A10 LEVEL.  IF THE TOP HALF OF A10 IS NON-ZERO THEN           *
*          A10 WAS PASSED AS THE TOP.                                    *
*                                                                        *
*          RETURN A10 AS THE Y FOR THE TOP OF THE HELP BOX.              *
*                                                                        *
**************************************************************************
TOP_IN_A10
         MMTM    SP,A5
         CMPI    0FFFFH,A10                ;IS THE TOP HALF ZERO?
         JRHI    TOP_IS_TOP                ;TOP IS SET..RETURN
         SRL     1,A5                      ;TOP OF BOX IS HALF UP FROM MAIN MENU BAR CENTER
         SUB     A5,A10                    ;NOW A10 HAS Y BASE OF BOX
TOP_IS_TOP
	MMFM    SP,A5
	RETS

**************************************************************************
*                                                                        *
*          AREUSURE                                                      *
*                                                                        *
*          THIS IS CALLED TO GET A CONFIRMATION FROM THE USER.           *
*          A8 = PROMPT...THIS WILL APPEAR ABOVE THE "ARE YOU SURE"       *
*          A9 = ROUTINE TO JSRP TO DO THE DESIRED ACTION                 *
*          A10 = MESSAGE TO DISPLAY CONFIRMING COMPLETION                *
*                                                                        *
*          RETURN A0=0 MEANS YES WAS CHOSEN.                             *
*                 A0 .NE. 0 MEANS NO                                     *
*                                                                        *
**************************************************************************
AREUSURE
         CALLA   CLR_SCRN             ;BLANK IT ALL OUT!
         MOVE    A9,*A13(PDATA),L     ;SAVE ROUTINE
         MOVE    A10,-*A12,L          ;AND CONFIRM MESSAGE

         CALLR   SURE_BOX

         MOVE    A8,A2                ;PUT MESSAGE TEXT IN SAFE PLACE
         MOVI    MESS_SURE,A8         ;SETUP FOR TITLE
         CALLA   LM_SETUP             ;STUFF REGGIES
         MOVE    A2,A8                ;GET STRING IN THERE
         JSRP    PRINTF             ;AND PRINT IT

         MOVI    M_SURE,A8            ;NOW THE "ARE YOU SURE" PART
         JSRP    L_MESS               ;PUT IT UP.

         MOVI    MEN_YN,A8            ;PUT UP THE "YES/NO" SELECTOR.
         MOVI    2,A9                 ;CURSOR ON 2ND ENTRY (NO)

         JSRP    B_MENU               ;AND GET A RESPONSE.
         CMPI    1,A8                 ;WAS IT YES?
         JRNZ    SURE_X               ;NOPE....GET OUT

         CALLA   CLR_SCRN             ;CLEAR THE SCREEN FIRST, SO ROUTINE CAN PLOT!

         MOVE    *A13(PDATA),A0,L     ;GET THE ROUTINE TO CALL
         MOVI    SURE_RET,A7
         MOVE    A7,-*A12,L           ;PUSH RETURN ADDRESS
         JUMP    A0                   ;AND "JSRP" THE ROUTINE

SURE_RET CALLR   SURE_BOX             ;BOX IT!
         MOVE    *A12+,A8,L
         JSRP    SUR_MESS             ;PRINT THE MESSAGE

         JSRP    ANY_BUT              ;NOW RETRIEVE ANY BUTTON THEN RETURN
		 
         CLR     A0                   ;RETURN SUCCESS
         RETP

SURE_X   ADDI    LONG_SIZE,A12        ;POP MESSAGE
         MOVI    2,A0                 ;RETURN FAILURE
         RETP

**************************************************************************
*                                                                        *
*          SUR_MESS                                                      *
*                                                                        *
*          THIS PRINTS MESSAGE IN A8 IN THE ARE U SURE BOX               *
*          CONFIRMATION SPOT.                                            *
*                                                                        *
**************************************************************************
SUR_MESS
	MOVE	A8,-*A12,L
	MOVI	MESS_CONFIRM,A8
	CALLA	LM_SETUP		;GET CONFIRMATION DATA READY.
	MOVE	*A12+,A8,L
	JSRP	PRINTF		;PRINT OUR PART
	RETP

SURE_BOX
	MOVI	COLOR_YELLOW,A9
	MOVI	003D0025H,A4
	MOVI	00F6016AH,A5
	CALLR	STD_BORD		;BORDER-IZE THE WHOLE THING.
	RETS

*
*BLANK THE INSIDE OF THE "ARE YOU SURE BOX"
*
BLNK_SURE_BOX
	MOVI	[41H,29H],A3
	MOVI	[0F2H,166H]-[41H,29H],A4
	JAUC	BLNKAREA		;ITS BLANK!

CENT_BOX
	MOVI	COLOR_RED,A9
CBOX_COL
	MOVI	0006E0030H,A4
	MOVI	0011A01D0H,A5
	CALLR	STD_BORD		;BORDER-IZE THE WHOLE THING.
	RETS

*----------------------------------------------------------------------------*
*----------------------------------------------------------------------------*
*****************************    MESSAGES    *********************************
*----------------------------------------------------------------------------*
*----------------------------------------------------------------------------*

	.IF	SCREEN_WIDE
INSTR_Y  EQU     INST_ULY+10
INSTR_2Y EQU     INSTR_Y+12
	.ELSE
INSTR_Y  EQU     INST_ULY+6
INSTR_2Y EQU     INSTR_Y+10
	.ENDIF

	.IF GERMAN

MM_INST1
	MESS_MAC RD7FONT,SPACING07,MENU_X,INSTR_Y,COLOR_PRGB,STRCNRM,0
	.STRING	"- AUF/+ AB",0
	.EVEN

MM_INST2
	MESS_MAC RD7FONT,SPACING07,MENU_X,INSTR_2Y,COLOR_PRGB,STRCNRM,0
	.STRING	"START MIT TEST",0
	.EVEN

MM_INST1_T2
	MESS_MAC RD7FONT,SPACING07,MENU_X,INSTR_Y,COLOR_PRGB,STRCNRM,0
	.STRING	"P1 START AUF/P2 START AB",0
	.EVEN

MM_INST2_T2
	MESS_MAC RD7FONT,SPACING07,MENU_X,INSTR_2Y,COLOR_PRGB,STRCNRM,0
	.STRING	"START MIT TRIGGER",0
	.EVEN

	.ELSE

MM_INST1
	MESS_MAC RD7FONT,SPACING07,MENU_X,INSTR_Y,COLOR_PRGB,STRCNRM,0
	.STRING	"- = MOVE UP/+ = MOVE DOWN",0
	.EVEN

MM_INST2
	MESS_MAC RD7FONT,SPACING07,MENU_X,INSTR_2Y,COLOR_PRGB,STRCNRM,0
	.STRING	"ENTER = RUN/ESC = PREV MENU",0
	.EVEN

MM_INST1_T2
	MESS_MAC RD7FONT,SPACING07,MENU_X,INSTR_Y,COLOR_PRGB,STRCNRM,0
	.STRING	"P1 START UP/P2 START DOWN",0
	.EVEN

MM_INST2_T2
	MESS_MAC RD7FONT,SPACING07,MENU_X,INSTR_2Y,COLOR_PRGB,STRCNRM,0
	.STRING	"TRIGGER=RUN/BOMB=PREV MENU",0
	.EVEN
	.ENDIF

MESS_FAIL
         MESS_MAC  RD15FONT,SPACING20,256,176,COLOR_PRED,STRCNRM,0
         .STRING  "INVALID ",W_GAME," ",W_SETTINGS
         .BYTE   0,1                  ;0 = END OF STRING...1 = MORE MESSAGES!
         .EVEN
         MESS_MAC  RD15FONT,SPACING20,256,226,COLOR_PWHITE,STRCNRM,0
         .STRING  "ATTEMPT TO RESTORE"
         .BYTE   0,1                  ;0 = END OF STRING...1 = MORE MESSAGES!
         .EVEN
         MESS_MAC  RD15FONT,SPACING20,256,256,COLOR_PWHITE,STRCNRM,0
         .STRING  W_FACSET,"S HAS FAILED."
         .BYTE    0,0
         .EVEN

MESS_TITLE
         MESS_MAC  RD15FONT,SPACING20,TM_X,TM_Y,COLOR_PGREEN,STRCNRM,0
	
	.IF	SCREEN_WIDE
RV_Y     EQU     TM_Y+25
	.ELSE
RV_Y	EQU	TM_Y+18
	.ENDIF

MESS_REV
         MESS_MAC  RD7FONT,SPACING07,TM_X,RV_Y,COLOR_PYELLOW,STRCNRM,0
*
*        THIS IS SETUP FOR THE QUESTION BEING ASKED
*        BY "ARE YOU SURE"
*
MESS_SURE
         MESS_MAC  RD15FONT,SPACING20,200,102,COLOR_PLF,STRCNRM,0
*
*        THIS IS THE "ARE YOU SURE" PART.
*
M_SURE
         MESS_MAC  RD15FONT,SPACING20,200,128,COLOR_PYELLOW,STRCNRM,0
	.IF GERMAN

	.STRING "OK?"

	.ELSE

         .STRING   "ARE YOU SURE?"

	.ENDIF

	.BYTE	0
	.EVEN
	.WORD	0

MESS_CONFIRM
         MESS_MAC  RD15FONT,SPACING20,200,115,COLOR_PLF,STRCNRM,0

SIY1     EQU     SND_MESS_Y+30
SIY3     EQU     SND_MESS_Y+41
SIY2     EQU     SND_MESS_Y+8

	.IF GERMAN

SND_INST
	MESS_MAC RD7FONT,SPACING07,200,SIY1,COLOR_PWHITE,STRCNRM,0
	.STRING	"WIEDERHOLUNG MIT BOMBEN-TASTE",0
	.EVEN
	.WORD	1
	MESS_MAC RD7FONT,SPACING07,200,SIY3,COLOR_PWHITE,STRCNRM,0
	.STRING	"N",C_GERA,"CHSTES GER",C_GERA,"USCH MIT TRIGGER",0
	.EVEN
	.WORD	0
SND_INST_T2
	MESS_MAC RD7FONT,SPACING07,200,SIY1,COLOR_PWHITE,STRCNRM,0
	.STRING	"WIEDERHOLUNG MIT BOMBEN-TASTE",0
	.EVEN
	.WORD	1
	MESS_MAC RD7FONT,SPACING07,200,SIY3,COLOR_PWHITE,STRCNRM,0
	.STRING	"N",C_GERA,"CHSTES GER",C_GERA,"USCH MIT TRIGGER",0
	.EVEN
	.WORD	0

	.ELSE

SND_INST

	MESS_MAC RD7FONT,SPACING07,198,SIY1,COLOR_PWHITE,STRCNRM,0
	.STRING	"ESCAPE = QUIT/ENTER = REPEAT",0
	.EVEN
	.WORD	1
	MESS_MAC RD7FONT,SPACING07,196,SIY3,COLOR_PWHITE,STRCNRM,0
	.STRING	"+ = NEXT SOUND/- = PREV SOUND",0
	.EVEN

	.WORD	0
SND_INST_T2

	MESS_MAC RD7FONT,SPACING07,198,SIY1,COLOR_PWHITE,STRCNRM,0
	.STRING	"BOMB = QUIT/TRIGGER = REPEAT",0
	.EVEN
	.WORD	1
	MESS_MAC RD7FONT,SPACING07,198,SIY3,COLOR_PWHITE,STRCNRM,0
	.STRING	"P2 START =NEXT/P1 START =PREV",0
	.EVEN

	.WORD	0

	.ENDIF

SND_SETUP MESS_MAC  RD15FONT,SPACING20,200,SIY2,COLOR_PLF,STRCNRM,0

STABLE
	.LONG	st0,st1,st2,st3,st4,st5,st6,st7,st9
	.LONG	st10,st11,st12,st13,st14,st15,st16,st18,st19
	.LONG	st20,st21,st22,st23,st24,st26,st27,st28,st29
	.LONG	st30,st31,st32,st33,st34,st35,st36,st37,st38,st39
	.LONG	st40,st42,st44,st45,st46,st47,st48,st49
	.LONG	st50,st51,st53,st54,st55,st57,st58,st59
	.LONG	st60,st61,st62,st64

st0:
	.string	"AUDITORIUM MUSIC",0
	.even
st1:
	.string	"MONDOR BATTLE",0
	.even
st2:
	.string	"GUITAR GROOVE",0
	.even
st3:
	.string	"JUNGLE GROOVE",0
	.even
st4:
	.string	"CHEMICAL GROOVE",0
	.even
st5:
	.string	"ELEVATOR MUZAK",0
	.even
st6:
	.string	"SWEET EMOTION",0
	.even
st7:
	.string	"WALK THIS WAY",0
	.even
st9:
	.string	"PLAYER GUN SHOT",0
	.even
st10:
	.string	"CD LAUNCH",0
	.even
st11:
	.string	"ENEMY AK47",0
	.even
st12:
	.string	"ENEMY M1",0
	.even
st13:
	.string	"ENEMY 357 MAGNUM",0
	.even
st14:
	.string	"SOAP DISPENSER DIES",0
	.even
st15:
	.string	"SINK HIT",0
	.even
st16:
	.string	"DRYER ROCKET HIT",0
	.even
st18:
	.string	"TOILET FLUSH",0
	.even
st19:
	.string	"BOUNCING COINS",0
	.even
st20:
	.string	"GUITAR SLIDE",0
	.even
st21:
	.string	"SHATTERING BOTTLE",0
	.even
st22:
	.string	"ROCKETED TABLE",0
	.even
st23:
	.string	"GONG",0
	.even
st24:
	.string	"SIGN FALL ON RECEPTIONIST",0
	.even
st25:
	.string	"NONBOY THUD",0
	.even
st26:
	.string	"DEBRIS EXPLOSION",0
	.even
st27:
	.string	"VIDEO CAMERA SHOT",0
	.even
st28:
	.string	"OOMPH",0
	.even
st29:
	.string	"WAKE UP",0
	.even
st30:
	.string	"WARCRY",0
	.even
st31:
	.string	"ENEMY SCREAM",0
	.even
st32:
	.string	"CLUB'S CLOSED",0
	.even
st33:
	.string	"NO TRESSPASSING",0
	.even
st34:
	.string	"KISS",0
	.even
st35:
	.string	"OW",0
	.even
st36:
	.string	"OOH",0
	.even
st37:
	.string	"FLESH WOUND",0
	.even
st38:
	.string	"TAKE THAT",0
	.even
st39:
	.string	"WORST NIGHTMARE",0
	.even
st40:
	.string	"I'VE HAD WORSE",0
	.even
st42:
	.string	"LAND THE CHOPPER",0
	.even
st43:
	.string	"BREAKING GLASS",0
	.even
st44:
	.string	"AIR RAID",0
	.even
st45:
	.string	"GLASS SHATTER",0
	.even
st46:
	.string	"OPEN POWERUP CRATE",0
	.even
st47:
	.string	"DUMPSTER HIT",0
	.even
st48:
	.string	"CANNON GARBAGE CAN",0
	.even
st49:
	.string	"PHONE RING",0
	.even
st50:
	.string	"IF YOU'D LIKE TO MAKE...",0
	.even
st51:
	.string	"CAT HIT",0
	.even
st53:
	.string	"LOOK OUT",0
	.even
st54:
	.string	"GOOD SHOT",0
	.even
st55:
	.string	"YESS",0
	.even
st57:
	.string	"YOU'RE DOING GREAT",0
	.even
st58:
	.string	"REVOLUTION XSSSS",0
	.even
st59:
	.string	"SQUASH 'EM",0
	.even
st60:
	.string	"SCHOOL'S OUT",0
	.even
st61:
	.string	"WOAH",0
	.even
st62:
	.string	"HEY BACK OFF",0
	.even
st64:
	.string	"DESTROY KEMITECH",0
	.even

ROM_NAME .STRING   "REVOLUTION X - REVISION 2.0 - 7/19/94"

	.IF AUSTRALIA

	.STRING	" AUSTRALIA.",0

	.ELSE

	.STRING	0

	.ENDIF

         .EVEN

**************************************************************************
*								         *
* 			     MENU DATA					 *
*								         *
**************************************************************************

**************************************************************************
*								         *
* 	MAIN TEST MENU AND ASSOCIATED DATA 				 *
*								         *
**************************************************************************

	.IF	PRINTER
MEN_MAIN
	.LONG	RD7FONT		;FONT
	.LONG	STRCNRM		;CENTER PLEASE
	.LONG	MESSMAIN	;TITLE
	.WORD	COLOR_WHITE	;COLOR OF TITLE
	.WORD	MENU_X		;UL X
	.WORD	MENU_Y		;UL Y
	.WORD	MENU_DY-4	;VERTICAL SPACING
	.WORD	COLOR_WHITE	;COLOR WHEN NOT SELECTED
	.WORD	BAR_HITE-4	;HEIGHT OF SELECTION BAR
	.WORD	BAR_DY+1	;DISTANCE OF BAR FROM TOP OF TEXT (NEGATIVE)
	.WORD	BAR_DX		;EXTRA X ON EACH SIDE.
	.WORD	BAR_WID		;WIDTH OF BAR!
	.WORD	COLOR_DECAY	;TEXT COLOR OF SELECTED ITEM
	.LONG	MESS_COIN_AUD,GO_BOOK,COIN_HELP
	.LONG	MESS_GAME_AUD,GO_AUD,AUDIT_HELP
	.LONG	MESS_GAME_ADJ,GO_ADJ,ADJUST_HELP
	.LONG	MESS_UTIL,GO_UTIL,UTIL_HELP
	.LONG	M_PRINT,GO_PRINT,BLNK_HELP	;SPECIAL CASE!
	.LONG	M_CALIBRATE,GO_CALIBRATE,CALIBRATE_HELP
	.LONG	MESS_EXIT,0,EXIT_HELP	
	.LONG	0		;END

M_PRINT
	.STRING	"PRINT GAME INFORMATION",0
	.EVEN

	.ELSE

	.IF GERMAN
MEN_MAIN
	.LONG	RD7FONT		;FONT
	.LONG	STRCNRM		;CENTER PLEASE
	.LONG	MESSMAIN	;TITLE
	.WORD	COLOR_WHITE	;COLOR OF TITLE
	.WORD	MENU_X		;UL X
	.WORD	MENU_Y+2	;UL Y
	.WORD	MENU_DY-8	;VERTICAL SPACING
	.WORD	COLOR_WHITE	;COLOR WHEN NOT SELECTED
	.WORD	BAR_HITE-6	;HEIGHT OF SELECTION BAR
	.WORD	BAR_DY+2	;DISTANCE OF BAR FROM TOP OF TEXT (NEGATIVE)
	.WORD	BAR_DX		;EXTRA X ON EACH SIDE.
	.WORD	BAR_WID		;WIDTH OF BAR!
	.WORD	COLOR_DECAY	;TEXT COLOR OF SELECTED ITEM
	.LONG	MESS_DIAG,GO_DIAG,DIAG_HELP
	.LONG	MESS_COIN_AUD,GO_BOOK,BLNK_HELP
	.LONG	MESS_GAME_AUD,GO_AUD,BLNK_HELP
	.LONG	MESS_GAME_ADJ,GO_ADJ,BLNK_HELP
	.LONG	MESS_UTIL,GO_UTIL,UTIL_HELP
	.LONG	M_CALIBRATE,GO_CALIBRATE,BLNK_HELP
	.if	NOPIC
	.else
	.LONG	MESS_HARDWARE,GO_HARDWARE,HARDWARE_HELP
	.endif
	.LONG	MESS_VOL,GO_VOLUME,VOLUME_HELP
	.LONG	MESS_EXIT,0,BLNK_HELP
	.LONG	0		;END
	.ELSE
MEN_MAIN
	.LONG	RD7FONT		;FONT
	.LONG	STRCNRM		;CENTER PLEASE
	.LONG	MESSMAIN	;TITLE
	.WORD	COLOR_WHITE	;COLOR OF TITLE
	.WORD	MENU_X		;UL X
	.WORD	MENU_Y+2	;UL Y
	.WORD	MENU_DY-8	;VERTICAL SPACING
	.WORD	COLOR_WHITE	;COLOR WHEN NOT SELECTED
	.WORD	BAR_HITE-6	;HEIGHT OF SELECTION BAR
	.WORD	BAR_DY+2	;DISTANCE OF BAR FROM TOP OF TEXT (NEGATIVE)
	.WORD	BAR_DX		;EXTRA X ON EACH SIDE.
	.WORD	BAR_WID		;WIDTH OF BAR!
	.WORD	COLOR_DECAY	;TEXT COLOR OF SELECTED ITEM
	.LONG	MESS_DIAG,GO_DIAG,DIAG_HELP
	.LONG	MESS_COIN_AUD,GO_BOOK,COIN_HELP
	.LONG	MESS_GAME_AUD,GO_AUD,AUDIT_HELP
	.LONG	MESS_GAME_ADJ,GO_ADJ,ADJUST_HELP
	.LONG	MESS_UTIL,GO_UTIL,UTIL_HELP
	.LONG	M_CALIBRATE,GO_CALIBRATE,CALIBRATE_HELP
	.if	NOPIC
	.else
	.LONG	MESS_HARDWARE,GO_HARDWARE,HARDWARE_HELP
	.endif
	.LONG	MESS_VOL,GO_VOLUME,VOLUME_HELP
	.LONG	MESS_EXIT,0,EXIT_HELP
	.LONG	0		;END
	.ENDIF

	.ENDIF

	.IF GERMAN

MESSMAIN
	.STRING	"REVOLUTION X  ",W_TEST,"  MEN",C_GERU,0
	.EVEN

MESS_DIAG
	.STRING	"DIAGNOSE-",W_TEST,"S",0
	.EVEN

MES_BOOK
MESS_COIN_AUD
	.STRING	"M{NZBUCHHALTUNG",0
	.EVEN

MES_AUD
MESS_GAME_AUD
	.STRING	"AUSLESEDATEN",0
	.EVEN

MESS_GAME_ADJ
	.STRING	"SPIEL-EINSTELLUNG",0
	.EVEN

MESS_UTIL
	.STRING	W_TEST,"-FUNKTIONEN",0
	.EVEN

M_CALIBRATE
	.STRING	"PISTOLEN KALIBRIEREN",0
	.EVEN

MESS_HARDWARE
	.STRING	"",0
	.EVEN

MESS_EXIT
	.STRING	"{BERGANG INS SPIELENDE",0
	.EVEN

	.ELSE

MESSMAIN
	.STRING	"REVOLUTION X  ",W_TEST,"  MENU",0
	.EVEN

MESS_DIAG
	.STRING	"DIAGNOSTIC ",W_TEST,"S",0
	.EVEN

MES_BOOK
MESS_COIN_AUD
	.STRING	W_COIN," ",W_BOOK,"KEEPING",0
	.EVEN

MES_AUD
MESS_GAME_AUD
	.STRING	W_GAME," ",W_AUDITS,0
	.EVEN

MESS_GAME_ADJ
	.STRING	W_GAME," ",W_ADJUSTMENT,0
	.EVEN

MESS_UTIL
	.STRING	"UTILITIES",0
	.EVEN

M_CALIBRATE
	.STRING	"CALIBRATE GUNS",0
	.EVEN

MESS_HARDWARE
	.STRING	"HARDWARE INFO",0
	.EVEN

MESS_VOL
	.STRING	"ADJUST VOLUME",0
	.EVEN

MESS_EXIT
	.STRING	"EXIT TO ",W_GAME," OVER",0
	.EVEN

	.ENDIF

DIAG_HELP
	.WORD	0		;CENTER JUSTIFY
	.WORD	COLOR_BLUE	;COLOR
	.WORD	7		;2 ENTRIES
	.LONG	MESS_SWTEST
	.LONG	MESS_DIPTEST
	.LONG	MESS_CPUTEST
	.LONG	M_STEST
	.LONG	MESS_PATTERNS
	.LONG	MESS_DRIVER
	.LONG	U_BURNIN

COIN_HELP
         .WORD   0               ;CENTER JUSTIFY
         .WORD	COLOR_BLUE      ;COLOR
         .WORD   3               ;2 ENTRIES
         .LONG   CH_0
         .LONG   CH_1
         .LONG   CH_2

AUDIT_HELP
         .WORD   0               ;CENTER JUSTIFY
         .WORD	COLOR_BLUE      ;COLOR
         .WORD   2               ;2 ENTRIES
         .LONG   AH_1
         .LONG   AH_2

ADJUST_HELP
         .WORD   0               ;CENTER JUSTIFY
         .WORD	COLOR_BLUE      ;COLOR
         .WORD   3               ;3 ENTRIES
         .LONG   AD_1
         .LONG   AD_2
         .LONG   AD_3

CALIBRATE_HELP
         .WORD   0               ;CENTER JUSTIFY
         .WORD	COLOR_BLUE      ;COLOR
         .WORD   3               ;3 ENTRIES
         .LONG   GCH_1
         .LONG   GCH_2
         .LONG   GCH_3

UTIL_HELP
	.WORD	0		;CENTER JUSTIFY
	.WORD	COLOR_BLUE	;COLOR
	.WORD	5		;NUMBER OF ENTRIES
****	.LONG	U_OPMESS
	.LONG	U_CLR_CRED
	.LONG	U_CLR_COIN
	.LONG	U_CLR_AUD
	.LONG	U_HSRESET
	.LONG	U_FACTORY

EXIT_HELP
         .WORD   0               ;CENTER JUSTIFY
         .WORD	COLOR_BLUE      ;COLOR
         .WORD   1               ;1 ENTRY
         .LONG   U_END

HARDWARE_HELP
	.WORD	0
	.WORD	COLOR_BLUE
	.WORD	2
	.LONG	HDWH_SN
	.LONG	HDWH_MAN

VOLUME_HELP
	.WORD	0
	.WORD	COLOR_BLUE
	.WORD	2
	.LONG	VOLH1
	.LONG	VOLH2
	.IF GERMAN
	.ELSE
HDWH_SN
	.STRING	"SERIAL NUMBER",0
	.EVEN
HDWH_MAN
	.STRING	"MANUFACTURE DATE",0
	.EVEN
VOLH1
	.STRING	"ALTERNATE VOLUME",0
	.EVEN
VOLH2
	.STRING	"ADJUSTMENT METHOD",0
	.EVEN
	.ENDIF

	 .IF GERMAN

MESS_SWTEST
	.STRING	"KONTAKT-",W_TEST,0
	.EVEN
MESS_DIPTEST
	.STRING "DIP-SCHALTER-",W_TEST,0
	.EVEN
MESS_CPUTEST
	.STRING "CPU-PLATINEN-",W_TEST,0
	.EVEN
MESS_STEST
M_STEST
	.STRING	"SOUND-PLATINEN-",W_TEST,0
	.EVEN
MESS_PATTERNS
	.STRING "MONITOR-MUSTER",0
	.EVEN
MESS_DRIVER
	.STRING	"TREIBER-PLATINEN-",W_TEST,0
	.EVEN

MESS_BURN
U_BURNIN
	.STRING "BURN-IN-",W_TEST,0
	.EVEN

	.ELSE

MESS_SWTEST
	.STRING	W_SWITCH," ",W_TEST,0
	.EVEN
MESS_DIPTEST
	.STRING "DIP ",W_SWITCH," ",W_TEST,0
	.EVEN
MESS_CPUTEST
	.STRING "CPU ",W_BOARD," ",W_TEST,0
	.EVEN
MESS_STEST
M_STEST
	.STRING	"SOUND ",W_BOARD," ",W_TEST,0
	.EVEN
MESS_PATTERNS
	.STRING "MONITOR PATTERNS",0
	.EVEN
MESS_DRIVER
	.STRING	"DRIVER ",W_BOARD," ",W_TEST,0
	.EVEN

MESS_BURN
U_BURNIN
	.STRING "BURN-IN ",W_TEST,0
	.EVEN
MESS_SERIAL_NUM
	.STRING	"SERIAL NUMBER",0
	.EVEN

	.ENDIF

CH_0
	.STRING	"VIEW COINBOX",0
	.EVEN
CH_1
	.STRING	W_TOTALS," AND",0
	.EVEN
CH_2
	.STRING	W_GAME,W_PLAY," COUNTERS",0
	.EVEN

AH_1
	.STRING	"VIEW ",W_GAME,0
	.EVEN
AH_2
	.STRING	W_PLAY," STATISTICS",0
	.EVEN

AD_1
	.STRING	"MAKE CHANGES",0
	.EVEN
AD_2
	.STRING	"TO PRICING AND",0
	.EVEN
AD_3
	.STRING	W_GAME," DIFFICULTY",0
	.EVEN

GCH_1
	.STRING	"ALIGN GUNS",0
	.EVEN
GCH_2
	.STRING	"SO THAT CURSOR",0
	.EVEN
GCH_3
	.STRING	"TRACKS ACCURATELY.",0
	.EVEN

	.IF GERMAN

MESS_MM
	.STRING	"ZUR",C_GERU,"CH INS HAUPTMEN",C_GERU,0
	.EVEN
MESS_HSRESET
U_HSRESET
	.STRING "HIGHSCORE L",C_GERO,"SCHEN",0
	.EVEN

U_FACTORY
	.STRING "FABRIKDATENEINSTELLUNG",0
	.EVEN

	.ELSE

MESS_MM
	.STRING	"RETURN TO MAIN MENU",0
	.EVEN
MESS_HSRESET
U_HSRESET
	.STRING "RESET HIGH SCORES",0
	.EVEN
U_FACTORY
	.STRING W_FACSET,"S",0
	.EVEN

	.ENDIF

****U_OPMESS
****	.STRING "OPERATOR ",W_MESSAGE,0
****	.EVEN
U_END
	.STRING "END ",W_TEST,"ING",0
	.EVEN

**************************************************************************
*								         *
* 	SOUNDS SYSTEM TESTS MENU					 *
*								         *
**************************************************************************

MEN_STEST
         .LONG   RD7FONT	;FONT
         .LONG   STRCNRM	;CENTER PLEASE
         .LONG   M_STEST	;TITLE
         .WORD   COLOR_GREEN	;COLOR OF TITLE
         .WORD   200		;UL X
         .WORD   MENU_Y-3	;UL Y
         .WORD   18             ;VERTICAL SPACING
         .WORD   COLOR_RED	;COLOR WHEN NOT SELECTED
         .WORD   18		;HEIGHT OF SELECTION BAR
         .WORD   -6		;DISTANCE OF BAR FROM TOP OF TEXT (NEGATIVE)
         .WORD   BAR_DX		;EXTRA X ON EACH SIDE.
         .WORD   195		;WIDTH OF BAR!
         .WORD   COLOR_DECAY	;TEXT COLOR OF SELECTED ITEM
         .LONG   M_DIGT,GO_DIGT,SND_HELP
         .LONG   M_SYNP,GO_SYNP,SND_PLAY

	.IF	PRINTER
	.ELSE
         .LONG   MESS_DIAGM,0,SND_HELP
	.ENDIF
         .LONG   MESS_MM,FORCE_MAIN,SND_HELP
         .LONG   0

	 .IF GERMAN

M_DIGT
	.STRING	"ALLGEMEINER ",W_TEST,0
	.EVEN
M_SYNP
	.STRING	"MUSIK SPIELEN",0
	.EVEN

	.ELSE

M_DIGT
	.STRING	"SOUND BOARD ",W_TEST,0
	.EVEN
M_SYNP
	.STRING	W_PLAY," SOUNDS",0
	.EVEN

	.ENDIF

DAC_LX   EQU     125

*
*MESSAGE FOR SOUND BOARD IRQ NOT WORKING
*
SIRQ_ERR
	MESS_MAC RD15FONT,SPACING07,200,95,COLOR_PLF,STRCNRM,0
	.STRING	"** WARNING! **",0
	.EVEN
	.WORD	1
	MESS_MAC RD7FONT,SPACING07,200,120,COLOR_PYELLOW,STRCNRM,0
	.STRING	"UNABLE TO DETECT ",W_SOUND," BOARD IRQ.",0
	.EVEN
	.WORD	1
	MESS_MAC RD7FONT,SPACING07,200,135,COLOR_PYELLOW,STRCNRM,0
	.STRING	"THIS MAY RESULT IN ERRANT ",W_SOUND,"S.",0
	.EVEN
	.WORD	0

*
*FOOTNOTE MESSAGE TO REMIND US THAT THE IRQ FAILED
*
SIRQ_ERR2
	MESS_MAC RD7FONT,SPACING07,200,165,COLOR_PRED,STRCNRM,0
	.STRING	W_ERROR," - ",W_SOUND," IRQ NOT DETECTED.",0
	.EVEN
	.WORD	0

	.IF GERMAN

*
*FOOTNOTE MESSAGE TO TELL US THAT THE IRQ LINE WAS CHECKED
*
SIRQ_DETECT
         MESS_MAC  RD7FONT,SPACING07,200,165,COLOR_PGREEN,STRCNRM,0
	.STRING	W_SOUND," IRQ FUNKTIONIERT.",0
	.EVEN
	.WORD	0

*
*CLUE OPERATOR IN ON HOW TO TELL IF HIS SOUND BOARD IS WORKING
*
DAC_LX2  EQU     DAC_LX+52

DAC_ERR
	MESS_MAC RD7FONT,SPACING07,200,70,COLOR_PLF,STRCNRM,0
	.STRING	"AUF GER[SCHE ACHTEN:",0
	.EVEN
	.WORD	1
	MESS_MAC RD7FONT,SPACING07,DAC_LX,85,COLOR_PYELLOW,STRLNRM,0
	.STRING	"0 GER[SCHE - HARDWARE PR{FEN",0
	.EVEN
	.WORD	1
	MESS_MAC RD7FONT,SPACING07,DAC_LX,95,COLOR_PYELLOW,STRLNRM,0
	.STRING	"1 GER[SCHE - ",W_SOUND,"-PLATINE OK",0
	.EVEN
	.WORD	1
	MESS_MAC RD7FONT,SPACING07,DAC_LX,105,COLOR_PYELLOW,STRLNRM,0
	.STRING	"2 GER[SCHE - ROM-FEHLER U2",0
	.EVEN
	.WORD	1
         MESS_MAC  RD7FONT,SPACING07,DAC_LX,115,COLOR_PYELLOW,STRLNRM,0
	.STRING	"3 GER[SCHE - ROM-FEHLER U3",0
	.EVEN
	MESS_MAC RD7FONT,SPACING07,DAC_LX,125,COLOR_PYELLOW,STRLNRM,0
	.STRING	"4 GER[SCHE - ROM-FEHLER U4",0
	.EVEN
	.WORD	1
	MESS_MAC RD7FONT,SPACING07,DAC_LX,135,COLOR_PYELLOW,STRLNRM,0
	.STRING	"5 GER[SCHE - ROM-FEHLER U5",0
	.EVEN
	.WORD	1
	MESS_MAC RD7FONT,SPACING07,DAC_LX,145,COLOR_PYELLOW,STRLNRM,0
	.STRING	"6 GER[SCHE - ROM-FEHLER U6",0
	.EVEN
	.WORD	1
	MESS_MAC RD7FONT,SPACING07,DAC_LX,155,COLOR_PYELLOW,STRLNRM,0
	.STRING	"7 GER[SCHE - ROM-FEHLER U7",0
	.EVEN
	.WORD	1
	MESS_MAC RD7FONT,SPACING07,DAC_LX,165,COLOR_PYELLOW,STRLNRM,0
	.STRING	"8 GER[SCHE - ROM-FEHLER U8",0
	.EVEN
	.WORD	1
	MESS_MAC RD7FONT,SPACING07,DAC_LX,175,COLOR_PYELLOW,STRLNRM,0
	.STRING	"9 GER[SCHE - ROM-FEHLER U9",0
	.EVEN
	.WORD	1
	MESS_MAC RD7FONT,SPACING07,DAC_LX,185,COLOR_PYELLOW,STRLNRM,0
	.STRING	"10 GER[SCHE - RAM-FEHLER",0
	.EVEN
	.WORD	0

	.ELSE

*
*FOOTNOTE MESSAGE TO TELL US THAT THE IRQ LINE WAS CHECKED
*
SIRQ_DETECT
         MESS_MAC  RD7FONT,SPACING07,200,165,COLOR_PGREEN,STRCNRM,0
	.STRING	W_SOUND," IRQ DETECT FUNCTIONAL.",0
	.EVEN
	.WORD	0

*
*CLUE OPERATOR IN ON HOW TO TELL IF HIS SOUND BOARD IS WORKING
*
DAC_LX2  EQU     DAC_LX+52
;DAC_ERR
;	MESS_MAC RD7FONT,SPACING07,200,70,COLOR_PLF,STRCNRM,0
;	.STRING	"LISTEN FOR ",W_TONE,"S:",0
;	.EVEN
;	.WORD	1
;	MESS_MAC RD7FONT,SPACING07,DAC_LX,85,COLOR_PYELLOW,STRLNRM,0
;	.STRING	"0 ",W_TONE,"S - CHECK HARDWARE",0
;	.EVEN
;	.WORD	1
;	MESS_MAC RD7FONT,SPACING07,DAC_LX,95,COLOR_PYELLOW,STRLNRM,0
;	.STRING	"1 ",W_TONE," ",0
;	.EVEN
;	.WORD	1
;	MESS_MAC RD7FONT,SPACING07,DAC_LX2,95,COLOR_PYELLOW,STRLNRM,0
;	.STRING	"- ",W_SOUND," BOARD OK",0
;	.EVEN
;	.WORD	1
;	MESS_MAC RD7FONT,SPACING07,DAC_LX,105,COLOR_PYELLOW,STRLNRM,0
;	.STRING	"2 ",W_TONE,"S - ROM ",W_ERROR," U2",0
;	.EVEN
;	.WORD	1
;         MESS_MAC  RD7FONT,SPACING07,DAC_LX,115,COLOR_PYELLOW,STRLNRM,0
;	.STRING	"3 ",W_TONE,"S - ROM ",W_ERROR," U3",0
;	.EVEN
;	.WORD	1
;	MESS_MAC RD7FONT,SPACING07,DAC_LX,125,COLOR_PYELLOW,STRLNRM,0
;	.STRING	"4 ",W_TONE,"S - ROM ",W_ERROR," U4",0
;	.EVEN
;	.WORD	1
;	MESS_MAC RD7FONT,SPACING07,DAC_LX,135,COLOR_PYELLOW,STRLNRM,0
;	.STRING	"5 ",W_TONE,"S - ROM ",W_ERROR," U5",0
;	.EVEN
;	.WORD	1
;	MESS_MAC RD7FONT,SPACING07,DAC_LX,145,COLOR_PYELLOW,STRLNRM,0
;	.STRING	"6 ",W_TONE,"S - ROM ",W_ERROR," U6",0
;	.EVEN
;	.WORD	1
;	MESS_MAC RD7FONT,SPACING07,DAC_LX,155,COLOR_PYELLOW,STRLNRM,0
;	.STRING	"7 ",W_TONE,"S - ROM ",W_ERROR," U7",0
;	.EVEN
;	.WORD	1
;	MESS_MAC RD7FONT,SPACING07,DAC_LX,165,COLOR_PYELLOW,STRLNRM,0
;	.STRING	"8 ",W_TONE,"S - ROM ",W_ERROR," U8",0
;	.EVEN
;	.WORD	1
;	MESS_MAC RD7FONT,SPACING07,DAC_LX,175,COLOR_PYELLOW,STRLNRM,0
;	.STRING	"9 ",W_TONE,"S - ROM ",W_ERROR," U9",0
;	.EVEN
;	.WORD	1
;	MESS_MAC RD7FONT,SPACING07,DAC_LX,185,COLOR_PYELLOW,STRLNRM,0
;	.STRING	"10 ",W_TONE,"S - SRAM ",W_ERROR,0
;	.EVEN
;	.WORD	0

SOUND_NORESP_MESS:
	MESS_MAC RD15FONT,SPACING07,200,95,COLOR_PRED,STRCNRM,0
	.STRING "ERROR - Sound Board not responding.",0
	.EVEN

SOUND_NOREL_MESS:
	MESS_MAC RD15FONT,SPACING07,200,138,COLOR_PRED,STRCNRM,0
	.STRING "No Revision Info Available.",0
	.EVEN

SOUND_WAIT_MESS:
	MESS_MAC RD15FONT,SPACING07,200,217,COLOR_PDECAY,STRCNRM,0
	.STRING "Testing Sound Hardware",0
	.EVEN

SOUNDTEST_MSGS:
	.long	stmess_0, stmess_1, stmess_2, stmess_3, stmess_4
	.long	stmess_5, stmess_6, stmess_7, stmess_8, stmess_9

stmess_0:
	MESS_MAC RD15FONT,SPACING07,200,95,COLOR_PGREEN,STRCNRM,0
	.STRING "Sound Board Tests O.K.",0
	.EVEN
stmess_1:
	MESS_MAC RD15FONT,SPACING07,200,95,COLOR_PRED,STRCNRM,0
	.STRING "Sound ROM U2 Failure",0
	.EVEN
stmess_2:
	MESS_MAC RD15FONT,SPACING07,200,95,COLOR_PRED,STRCNRM,0
	.STRING "Sound ROM U3 Failure",0
	.EVEN
stmess_3:
	MESS_MAC RD15FONT,SPACING07,200,95,COLOR_PRED,STRCNRM,0
	.STRING "Sound ROM U4 Failure",0
	.EVEN
stmess_4:
	MESS_MAC RD15FONT,SPACING07,200,95,COLOR_PRED,STRCNRM,0
	.STRING "Sound ROM U5 Failure",0
	.EVEN
stmess_5:
	MESS_MAC RD15FONT,SPACING07,200,95,COLOR_PRED,STRCNRM,0
	.STRING "Sound ROM U6 Failure",0
	.EVEN
stmess_6:
	MESS_MAC RD15FONT,SPACING07,200,95,COLOR_PRED,STRCNRM,0
	.STRING "Sound ROM U7 Failure",0
	.EVEN
stmess_7:
	MESS_MAC RD15FONT,SPACING07,200,95,COLOR_PRED,STRCNRM,0
	.STRING "Sound ROM U8 Failure",0
	.EVEN
stmess_8:
	MESS_MAC RD15FONT,SPACING07,200,95,COLOR_PRED,STRCNRM,0
	.STRING "Sound ROM U9 Failure",0
	.EVEN
stmess_9:
	MESS_MAC RD15FONT,SPACING07,200,95,COLOR_PRED,STRCNRM,0
	.STRING "Sound RAM Failure",0
	.EVEN
	.ENDIF


**************************************************************************
*								         *
* 	DIAGNOSTIC TESTS MENU						 *
*								         *
**************************************************************************

	.IF	PRINTER
	.ELSE
MEN_DIAG
	.LONG	RD7FONT		;FONT
	.LONG	STRCNRM		;CENTER PLEASE
	.LONG	MESS_DIAG	;TITLE
	.WORD	COLOR_RED	;COLOR OF TITLE
	.WORD	200		;UL X
	.WORD	MENU_Y-3	;UL Y
	.WORD	MENU_DY-6	;VERTICAL SPACING
	.WORD	COLOR_RED	;COLOR WHEN NOT SELECTED
	.WORD	BAR_HITE-6	;HEIGHT OF SELECTION BAR
	.WORD	-6		;DISTANCE OF BAR FROM TOP OF TEXT (NEGATIVE)
	.WORD	BAR_DX		;EXTRA X ON EACH SIDE.
	.WORD	195		;WIDTH OF BAR!  (A LITTLE FATTER)
	.WORD	COLOR_DECAY	;TEXT COLOR OF SELECTED ITEM (SHOULD BE DECAY)
	.LONG	MESS_SWTEST,GO_SWITCH,BLNK_HELP   
	.LONG	MESS_DIPTEST,GO_DIP,BLNK_HELP  
ROM_LEV	EQU	3		;TEST NUMBER FOLLOWING ROM TEST
	.LONG	MESS_CPUTEST,GO_CPU,BLNK_HELP  
RTR_LEV	EQU	4		;TEST NUMBER FOLLOWING CPU TEST (FOR RETURN)
	.LONG	M_STEST,GO_STEST,BLNK_HELP
	.LONG	MESS_PATTERNS,GO_PATTERNS,BLNK_HELP
	.LONG	MESS_DRIVER,GO_DRIVER,BLNK_HELP
	.LONG	MESS_BURN,GO_BURN,BLNK_HELP
	.LONG	MESS_MM,0,BLNK_HELP        ;RETURN TO MAIN MENU
	.LONG	0
	.ENDIF

**************************************************************************
*								         *
* 	HARDWARE INFORMATION MENU                       		 *
*								         *
**************************************************************************

	.IF	PRINTER
	.ELSE
MEN_HARDWARE
	.LONG	RD7FONT		;FONT
	.LONG	STRCNRM		;CENTER PLEASE
	.LONG	MESS_HDW_TITLE	;TITLE
	.WORD	COLOR_GREEN	;COLOR OF TITLE
	.WORD	200		;UL X
	.WORD	230		;UL Y
	.WORD	MENU_DY		;VERTICAL SPACING
	.WORD	COLOR_BLUE	;COLOR WHEN NOT SELECTED
	.WORD	BAR_HITE	;HEIGHT OF SELECTION BAR
	.WORD	BAR_DY		;DISTANCE OF BAR FROM TOP OF TEXT (NEGATIVE)
	.WORD	BAR_DX		;EXTRA X ON EACH SIDE.
	.WORD	234		;WIDTH OF BAR!  (A LITTLE FATTER)
	.WORD	COLOR_DECAY	;TEXT COLOR OF SELECTED ITEM (SHOULD BE DECAY)
	.if	NOPIC
	.LONG	MESS_MM,FORCE_MAIN,NO_HELP
	.else
	.LONG	MESS_MM,RET_HARDWARE,NO_HELP
	.endif
	.LONG	0
	.ENDIF

MESS_HDW_TITLE
	.STRING	"HARDWARE INFORMATION",0
	.EVEN

**************************************************************************
*								         *
* 	VOLUME ADJUSTMENT MENU                          		 *
*								         *
**************************************************************************

	.IF	PRINTER
	.ELSE
MEN_VOLUME
	.LONG	RD7FONT		;FONT
	.LONG	STRCNRM		;CENTER PLEASE
	.LONG	MESS_VOL_TITLE	;TITLE
	.WORD	COLOR_GREEN	;COLOR OF TITLE
	.WORD	200		;UL X
	.WORD	230		;UL Y
	.WORD	MENU_DY		;VERTICAL SPACING
	.WORD	COLOR_BLUE	;COLOR WHEN NOT SELECTED
	.WORD	BAR_HITE	;HEIGHT OF SELECTION BAR
	.WORD	BAR_DY		;DISTANCE OF BAR FROM TOP OF TEXT (NEGATIVE)
	.WORD	BAR_DX		;EXTRA X ON EACH SIDE.
	.WORD	244		;WIDTH OF BAR!  (A LITTLE FATTER)
	.WORD	COLOR_DECAY	;TEXT COLOR OF SELECTED ITEM (SHOULD BE DECAY)
	.LONG	MESS_MM,FORCE_MAIN,NO_HELP
	.LONG	0
	.ENDIF

VOL_INST:
	MESS_MAC	RD7FONT,SPACING07,200,60,COLOR_PRGB,STRCNRM,0
	.STRING		"- = VOLUME DOWN / + = VOLUME UP",0
	.EVEN
VOL_INST_T2:
	MESS_MAC	RD7FONT,SPACING07,200,60,COLOR_PRGB,STRCNRM,0
	.STRING		"P1 START = VOLUME DOWN / P2 START = VOLUME UP",0
	.EVEN

MESS_VOL_TITLE
	.STRING	"VOLUME ADJUSTMENT",0
	.EVEN

**************************************************************************
*								         *
* 	BOOKKEEPING							 *
*								         *
**************************************************************************

**************************************************************************
*                                                                        *
*          AUDIT TABLE STRUCTURE                                         *
*                                                                        *
**************************************************************************

AUD_MESS	EQU	0			;LONG-PTR TO TEXT
AUD_ROUTINE	EQU	AUD_MESS+LONG_SIZE	;LONG - NON ZERO MEANS CALL FOR NUMBER
AUD_NUMBER	EQU	AUD_ROUTINE+LONG_SIZE	;WORD - IF ABOVE ZERO, THEN AUDIT NUMBER
AUD_T_SIZE	EQU	AUD_NUMBER+WORD_SIZE

AMAC     .MACRO  MESS,ROUT,AUDIT
         .LONG   :MESS:
         .LONG   :ROUT:
         .WORD   :AUDIT:
         .ENDM

AUD_LM		EQU	TIT_ULX			;SQUARE OFF AUDITS W/ HEADER.
AUD_RM		EQU	TIT_LRX
AUD_Y_START	EQU	61
AUD_DY		EQU	18

CP2_Y		EQU	142			;PART 2 OF COIN AUDIT PAGE.

MES_TOTALS
	.STRING	W_TOTAL," ",W_COLLECTION,0
	.EVEN

*
*	DETAILED COINAGE AVAILABLE (ON 1ST COINAGE PAGE)
*
MEN_DETAIL
	.LONG	RD7FONT		;FONT
	.LONG	STRCNRM		;CENTER PLEASE
	.LONG	MESS_PATTERNS	;TITLE
	.WORD	COLOR_YELLOW	;COLOR OF TITLE
	.WORD	200		;UL X	(CENTER IT!)
	.WORD	227		;UL Y
	.WORD	12		;VERTICAL SPACING
	.WORD	COLOR_BLUE	;COLOR WHEN NOT SELECTED
	.WORD	12		;HEIGHT OF SELECTION BAR
	.WORD	-2		;DISTANCE OF BAR FROM TOP OF TEXT (NEGATIVE)
	.WORD	BAR_DX		;EXTRA X ON EACH SIDE.
	.WORD	170		;WIDTH OF BAR!
	.WORD	COLOR_DECAY	;TEXT COLOR OF SELECTED ITEM
	.LONG	MESS_DETAIL,0,NO_HELP		;DETAILED SECTION
	.LONG	MESS_MM,FORCE_MAIN,NO_HELP	;RETURN TO MAIN MENU
	.LONG	0

	.IF GERMAN

MESS_DETAIL
         .STRING         "WEITERE DATEN"
         .BYTE           0
         .EVEN

	.ELSE

MESS_DETAIL
         .STRING         "MORE DETAILED DATA"
         .BYTE           0
         .EVEN

	.ENDIF


*
*        TOP HALF OF COIN AUDIT PAGE 1 TABLE
*
COIN_AUDS      
	.WORD	AUD_Y_START		;Y START
	.WORD	14			;Y BETWEEN ENTRIES
	.WORD	AUD_LM			;LEFT MARGIN X
	.WORD	AUD_RM			;RIGHT MARGIN X
	AMAC	M_LCOIN,0,AUDLCOIN
	AMAC	M_RCOIN,0,AUDRCOIN
	AMAC	M_CCOIN,0,AUDCCOIN
	AMAC	M_4COIN,0,AUD4COIN
	AMAC	M_SCOIN,0,AUDSCOIN
	AMAC	M_PAIDC,0,AUDPAIDC
	AMAC	M_GSTART,0,AUDGSTARTS
	AMAC	M_START,STARTS,0
	AMAC	M_CONT,CONTINS,0
	AMAC	M_PLAYS,DOPLAYS,0
	AMAC	M_HSLEFT,DOHSLEFT,0
	.LONG	0

COIN_AUDS_BV
	.WORD	AUD_Y_START		;Y START
	.WORD	14			;Y BETWEEN ENTRIES
	.WORD	AUD_LM			;LEFT MARGIN X
	.WORD	AUD_RM			;RIGHT MARGIN X
	AMAC	M_LCOIN,0,AUDLCOIN
	AMAC	M_RCOIN,0,AUDRCOIN
	AMAC	M_CCOIN,0,AUDCCOIN
	AMAC	M_DBV,0,AUD4COIN
	AMAC	M_SCOIN,0,AUDSCOIN
	AMAC	M_PAIDC,0,AUDPAIDC
	AMAC	M_GSTART,0,AUDGSTARTS
	AMAC	M_START,STARTS,0
	AMAC	M_CONT,CONTINS,0
	AMAC	M_PLAYS,DOPLAYS,0
	AMAC	M_HSLEFT,DOHSLEFT,0
	.LONG	0

	.IF GERMAN

M_WDOG:
	.STRING	"WATCHDOGS AUSGEL",C_GERO,"ST",0
	.EVEN
M_SECURITY
	.STRING	"FEHLSTARTS",0
	.EVEN

	.ELSE

M_WDOG:
	.STRING	"WATCHDOGS TRIGGERED",0
	.EVEN
M_SECURITY
	.STRING	"START FAILURES",0
	.EVEN

	.ENDIF

M_BADTRAP
	.STRING	"SOFTWARE TRAPS",0
	.EVEN
M_WARNING
	.STRING	"SOFTWARE WARNINGS",0
	.EVEN
M_STOCKINGS
	.STRING	"STOCKING ALERT!",0
	.EVEN

*
*        BOTTOM HALF OF COIN AUDIT PAGE 1 TABLE
*

	.IF GERMAN

M_LCOIN
	.STRING "LINKER M",C_GERU,"NZEINWURF",0
        .EVEN
M_CCOIN  
	.STRING "3. M",C_GERU,"NZEINWURF",0
        .EVEN
M_RCOIN  
	.STRING "RECHTER M",C_GERU,"NZEINWURF",0
        .EVEN
M_4COIN	
	.STRING	"4. M",C_GERU,"NZEINWURF",0
	.EVEN
M_SCOIN
	.STRING	"SERVICE-KREDITE",0
	.EVEN
M_PAIDC
	.STRING "GESPIELTE KREDITE",0
	.EVEN
M_START
	.STRING	"GESTARTETE SPIELE",0
	.EVEN
M_CONT
	.STRING	"SPIELFORTSETZUNGEN",0
	.EVEN
M_PLAYS
	.STRING	"GESAMTSPIELE",0
	.EVEN
M_HSLEFT
	.STRING	"SPIELE BIS H.S.-R",C_GERU,"CKSTELLUNG",0
	.EVEN
M_HSOFF
	.STRING "OFF",0
	.EVEN

	.ELSE

M_LCOIN
	.STRING W_LEFT," ",W_SLOT," ",W_COINS,0
        .EVEN
M_CCOIN  
	.STRING "THIRD ",W_SLOT," ",W_COINS,0
        .EVEN
M_RCOIN  
	.STRING W_RIGHT," ",W_SLOT," ",W_COINS,0
        .EVEN
M_4COIN	
	.STRING	W_FOURTH," ",W_SLOT," ",W_COINS,0
	.EVEN
M_SCOIN
	.STRING	"SERVICE ",W_CREDITS,0
	.EVEN
M_PAIDC
	.STRING "PAID ",W_CREDITS,0
	.EVEN
M_GSTART
	.STRING	W_TOTAL," ",W_GAMES," ",W_START,"ED",0
	.EVEN
M_GGAMEO
	.STRING	W_TOTAL," ",W_GAMES," ENDED",0
	.EVEN
M_START
	.STRING W_PLAYER," ",W_STARTS,0
	.EVEN
M_CONT
	.STRING W_PLAYER," ",W_CONTINUES,0
	.EVEN
M_PLAYS
	.STRING W_TOTAL," ",W_PLAYER," ",W_STARTS," AND ",W_CONTINUES,0
	.EVEN
M_HSLEFT
	.STRING W_PLAYS," UNTIL H.S. RESET",0
	.EVEN
M_HSOFF
	.STRING "OFF",0
	.EVEN

	.ENDIF

M_DBV
	.STRING	"BILL VALIDATOR PULSES",0
	.EVEN

*
*        AUDIT TEXT
*
MESS_ERROR
         MESS_MAC  RD7FONT,SPACING07,0,0,COLOR_PRED,STRLNRM,0
         .STRING   "  ",W_ERROR
         .BYTE     0
         .EVEN

MESS_AUD_NUM
         MESS_MAC  RD7FONT,SPACING07,367,227,COLOR_PYELLOW,STRRNRM,0

MESS15_AUD_NUM
         MESS_MAC  RD15FONT,SPACING07,367,227,COLOR_PYELLOW,STRRNRM,0

MESS_AUD_LINE
         MESS_MAC  RD7FONT,SPACING07,30,355,COLOR_PYELLOW,STRLNRM,0

MESS15_AUD_LINE
         MESS_MAC  RD15FONT,SPACING07,30,355,COLOR_PYELLOW,STRLNRM,0

**************************************************************************
*                                                                        *
*          COIN_D1                                                       *
*                                                                        *
*          THIS IS TOP HALF OF DETAILED COIN AUDIT PAGE                  *
*          ITS THE SAME AS THE OTHER COIN PAGE WITH THE Y POSITIONING    *
*          A LITTLE DIFFERENT                                            *
*                                                                        *
**************************************************************************
COIN_D1
	.WORD	AUD_Y_START+7
	.WORD	24			;Y BETWEEN ENTRIES
	.WORD	AUD_LM			;LEFT MARGIN X
	.WORD	AUD_RM			;RIGHT MARGIN X
	AMAC	M_LCOIN,0,AUDLCOIN
	AMAC	M_RCOIN,0,AUDRCOIN
	AMAC	M_CCOIN,0,AUDCCOIN
	AMAC	M_4COIN,0,AUD4COIN
	AMAC	M_TOTCOL,DO_MONEY,0
	.LONG	0

COIN_D1_BV
	.WORD	AUD_Y_START+7
	.WORD	24			;Y BETWEEN ENTRIES
	.WORD	AUD_LM			;LEFT MARGIN X
	.WORD	AUD_RM			;RIGHT MARGIN X
	AMAC	M_LCOIN,0,AUDLCOIN
	AMAC	M_RCOIN,0,AUDRCOIN
	AMAC	M_CCOIN,0,AUDCCOIN
	AMAC	M_DBV,0,AUD4COIN
	AMAC	M_TOTCOL,DO_MONEY,0
	.LONG	0

COIN_SD1
	.WORD	AUD_Y_START+7
	.WORD	24			;Y BETWEEN ENTRIES
	.WORD	AUD_LM			;LEFT MARGIN X
	.WORD	AUD_RM			;RIGHT MARGIN X
	AMAC	M_LCOIN,0,AUDLCOIN
	AMAC	M_RCOIN,0,AUDRCOIN
	AMAC	M_CCOIN,0,AUDCCOIN
	AMAC	M_4COIN,0,AUD4COIN
	.LONG	0

COIN_SD1_BV
	.WORD	AUD_Y_START+7
	.WORD	24			;Y BETWEEN ENTRIES
	.WORD	AUD_LM			;LEFT MARGIN X
	.WORD	AUD_RM			;RIGHT MARGIN X
	AMAC	M_LCOIN,0,AUDLCOIN
	AMAC	M_RCOIN,0,AUDRCOIN
	AMAC	M_CCOIN,0,AUDCCOIN
	AMAC	M_DBV,0,AUD4COIN
	.LONG	0

*
*        DOOR CLOSED AUDITS.
*
M_TOTCOL
	.STRING	W_TOTAL,0
	.EVEN

	.IF GERMAN

MESS_CLEAR_SUBS
	.STRING	"M",C_GERU,"NZZ",C_GERA,"HLER-L",C_GERO,"SCHEN",0
	.EVEN

	.ELSE

MESS_CLEAR_SUBS
	.STRING	W_CLEAR," ",W_COINCOUNTS,0
	.EVEN

	.ENDIF

MESS_SUBS_CLEAR
	.STRING	W_COINCOUNTS," ",W_CLEAR,"ED",0
	.EVEN

	.IF GERMAN

MESS_YES
	.STRING	"JA",0
	.EVEN
MESS_NO
	.STRING	"NEIN",0
	.EVEN

	.ELSE

MESS_YES
	.STRING	"YES",0
	.EVEN
MESS_NO
	.STRING	"NO",0
	.EVEN

	 .ENDIF

*
*	CLEAR SUB-TOTALS (ON DETAILED COINAGE PAGE)
*
MEN_CLR_SUB
	.LONG	RD7FONT		;FONT
	.LONG	STRCNRM		;CENTER PLEASE
	.LONG	MESS_PATTERNS	;TITLE
	.WORD	COLOR_YELLOW	;COLOR OF TITLE
	.WORD	200		;UL X	(CENTER IT!)
	.WORD	227		;UL Y
	.WORD	12		;VERTICAL SPACING
	.WORD	COLOR_BLUE	;COLOR WHEN NOT SELECTED
	.WORD	12		;HEIGHT OF SELECTION BAR
	.WORD	-2		;DISTANCE OF BAR FROM TOP OF TEXT (NEGATIVE)
	.WORD	BAR_DX		;EXTRA X ON EACH SIDE.
	.WORD	170		;WIDTH OF BAR!
	.WORD	COLOR_DECAY	;TEXT COLOR OF SELECTED ITEM
	.LONG   MESS_CLEAR_SUBS,0,NO_HELP	;CLEAR SUB-TOTALS
	.LONG	MESS_MM,FORCE_MAIN,NO_HELP	;RETURN TO MAIN MENU
	.LONG	0

*
*	YES/NO	(FOR ARE YOU SURE?)
*
MEN_YN
	.LONG	RD7FONT		;FONT
	.LONG	STRCNRM		;CENTER PLEASE
	.LONG	MESS_PATTERNS	;TITLE
	.WORD	COLOR_RED	;COLOR OF TITLE
	.WORD	200		;UL X
	.WORD	166		;UL Y
	.WORD	17		;VERTICAL SPACING
	.WORD	COLOR_YELLOW	;COLOR WHEN NOT SELECTED
	.WORD	17		;HEIGHT OF SELECTION BAR
	.WORD	-4		;DISTANCE OF BAR FROM TOP OF TEXT (NEGATIVE)
	.WORD	BAR_DX		;EXTRA X ON EACH SIDE.
	.WORD	78		;WIDTH OF BAR!  (A LITTLE FATTER)
	.WORD	COLOR_DECAY	;TEXT COLOR OF SELECTED ITEM
	.LONG	MESS_YES,0,NO_HELP
	.LONG	MESS_NO,0,NO_HELP
	.LONG	0

**************************************************************************
*								         *
*          	GAME PLAY AUDIT PAGES					 *
*								         *
**************************************************************************
GAME_AUDS
	.WORD	61			;Y START
	.WORD	17			;Y BETWEEN ENTRIES
	.WORD	AUD_LM			;LEFT MARGIN X
	.WORD	AUD_RM			;RIGHT MARGIN X
	AMAC	M_GSTART,0,AUDGSTARTS
	AMAC	M_GGAMEO,0,AUDNUMTG
	AMAC	M_TTIME,DO_PTIME,0
	AMAC	M_UPTIME,DO_UPTIME,0
	AMAC	M_AVGTC,DO_AVGTC,0
	AMAC	M_COSTPG,DO_AVGGC,0
	AMAC	M_1TIME,DO_P1TIME,0
	AMAC	M_2TIME,DO_P2TIME,0
	AMAC	M_3TIME,DO_P3TIME,0
	.LONG	0

GAME_AUD2
	.WORD	61			;Y START
	.WORD	15			;Y BETWEEN ENTRIES
	.WORD	AUD_LM			;LEFT MARGIN X
	.WORD	AUD_RM			;RIGHT MARGIN X
	AMAC	M_START,STARTS,0
	AMAC	M_CONT,CONTINS,0
	AMAC	M_PLAYS,DOPLAYS,0
	AMAC	M_CONTOFF,0,AUDCONTOFFER
	AMAC	M_CONTTAK,0,AUDCONTTAKEN
	AMAC	M_PCTCONT,DO_PCTCONT,0
	AMAC	M_COSTPP,DO_AVGPC,0
	AMAC	M_SLAMS,0,AUDSLAMS
	AMAC	M_BURNIN,0,AUDAUTO
	AMAC	M_SECURITY,0,AUDSECURITY
	.LONG	0

GAME_AUD3
	.WORD	61			;Y START
	.WORD 	17			;Y BETWEEN ENTRIES
	.WORD 	AUD_LM			;LEFT MARGIN X
	.WORD 	AUD_RM			;RIGHT MARGIN X
	AMAC	M_GSTART,0,AUDGSTARTS
	AMAC	M_LABTR,0,AUDLABTR	;Checkpoint - BTR in LA
	AMAC	M_LACLUB,0,AUDLACLUB	;Checkpoint - Enter CLUB X
	AMAC	M_LAAERO,0,AUDLAAERO	;Checkpoint - See Aerosmith
	AMAC	M_LAEND,0,AUDLAEND	;Checkpoint - End CLUB X
	AMAC	M_FLHELI,0,AUDFLHELI	;Checkpoint - Boss helicopter reached
	AMAC	M_FLEND,0,AUDFLEND	;Checkpoint - Flight wave completed
	AMAC	M_MIDEAST,0,AUDMIDEAST	;Checkpoint - Middle East Selected
	AMAC	M_MIEND,0,AUDMIEND	;Checkpoint - Middle East Completed
	.LONG	0

GAME_AUD4
	.WORD	61			;Y START
	.WORD 	17			;Y BETWEEN ENTRIES
	.WORD 	AUD_LM			;LEFT MARGIN X
	.WORD 	AUD_RM			;RIGHT MARGIN X
	AMAC	M_GSTART,0,AUDGSTARTS
	AMAC	M_JUNGLE,0,AUDJUNGLE	;Checkpoint - Jungle selected
	AMAC	M_JUBTR,0,AUDJUBTR	;Checkpoint - Reached BTR
	AMAC	M_JUDESK,0,AUDJUDESK	;Checkpoint - Defeated receptionist
	AMAC	M_JUELEV,0,AUDJUELEV	;Checkpoint - Reached elevator
	AMAC	M_JUBZERK,0,AUDJUBZERK	;Checkpoint - Reached Berzerk hall
	AMAC	M_JUBUG,0,AUDJUBUG	;Checkpoint - Bug chase
	AMAC	M_JUEND,0,AUDJUEND	;Checkpoint - Jungle completed
	.LONG	0

GAME_AUD5
	.WORD	61			;Y START
	.WORD 	17			;Y BETWEEN ENTRIES
	.WORD 	AUD_LM			;LEFT MARGIN X
	.WORD 	AUD_RM			;RIGHT MARGIN X
	AMAC	M_GSTART,0,AUDGSTARTS
	AMAC	M_JAPAN,0,AUDJAPAN	;Checkpoint - Pacific Rim selected
	AMAC	M_JACRATE,0,AUDJACRATE	;Checkpoint - Crated section reached
	AMAC	M_JAFAC,0,AUDJAFAC	;Checkpoint - Factory section reached
	AMAC	M_JARD,0,AUDJARD	;Checkpoint - R&D section reached
	AMAC	M_JADESK,0,AUDJADESK	;Checkpoint - Boss desk reached
	AMAC	M_JAEND,0,AUDJAEND	;Checkpoint - Pacific Rim completed
	AMAC	M_WEMBLEY,0,AUDWEMBLEY	;Checkpoint - Wembley stadium reached
	AMAC	M_GAMEC,0,AUDFINISH	;Game completed
	.LONG	0

GAME_AUDL
	.WORD	61			;Y START
	.WORD 	17			;Y BETWEEN ENTRIES
	.WORD 	AUD_LM			;LEFT MARGIN X
	.WORD 	AUD_RM			;RIGHT MARGIN X
	AMAC	M_GSTART,0,AUDGSTARTS
	AMAC	M_TYLER,0,AUDTYLER	;Steven Tyler found
	AMAC	M_PERRY,0,AUDPERRY	;Joe Perry found
	AMAC	M_HAMILTON,0,AUDHAMILTON	;Tom Hamilton found
	AMAC	M_WHITFORD,0,AUDWHITFORD	;Brad Whitford found
	AMAC	M_KRAMER,0,AUDKRAMER	;Joey Kramer found
	AMAC	M_BACKSTAGE,0,AUDBACKSTAGE ;Checkpoint - Pleasure dome
	.LONG	0

GAME_AUDH
	.WORD	61			;Y START
	.WORD 	17			;Y BETWEEN ENTRIES
	.WORD 	AUD_LM			;LEFT MARGIN X
	.WORD 	AUD_RM			;RIGHT MARGIN X
	AMAC	M_WDOG,0,AUDDOGGY
	AMAC	M_WARNING,0,AUDWARNING
	AMAC	M_BADTRAP,0,AUDBADTRAP
	AMAC	M_STOCKINGS,0,AUDSTOCKINGS
	.LONG	0

**************************************************************************
*								         *
* 		    AUDIT PAGE OPTIONS #1				 *
* 									 *
* 			TO NEXT PAGE					 *
* 		     RETURN TO MAIN MENU				 *
*								         *
**************************************************************************
MEN_AP1
	.LONG	RD7FONT			;FONT
	.LONG	STRCNRM			;CENTER PLEASE
	.LONG	MESS_PATTERNS		;TITLE
	.WORD	COLOR_YELLOW		;COLOR OF TITLE
	.WORD	200			;UL X      (CENTER IT!)
	.WORD	227			;UL Y
	.WORD	12			;VERTICAL SPACING
	.WORD	COLOR_BLUE		;COLOR WHEN NOT SELECTED
	.WORD	12			;HEIGHT OF SELECTION BAR
	.WORD	-2			;DISTANCE OF BAR FROM TOP OF TEXT (NEGATIVE)
	.WORD	BAR_DX+5		;EXTRA X ON EACH SIDE.
	.WORD	170			;WIDTH OF BAR!
	.WORD	COLOR_DECAY		;TEXT COLOR OF SELECTED ITEM
	.LONG	MESS_TOPAGE2,0,NO_HELP		;"TO NEXT PAGE"
	.LONG	MESS_MM,FORCE_MAIN,NO_HELP	;"RETURN TO MAIN MENU"
	.LONG	0

**************************************************************************
*								         *
* 		    AUDIT PAGE OPTIONS #2				 *
* 									 *
* 			TO NEXT PAGE					 *
* 		      TO PREVIOUS PAGE					 *
* 		     RETURN TO MAIN MENU				 *
*								         *
**************************************************************************
MEN_AP2
	.LONG	RD7FONT			;FONT
	.LONG	STRCNRM			;CENTER PLEASE
	.LONG	MESS_PATTERNS		;TITLE
	.WORD	COLOR_YELLOW		;COLOR OF TITLE
	.WORD	200			;UL X      (CENTER IT!)
	.WORD	216			;UL Y
	.WORD	12			;VERTICAL SPACING
	.WORD	COLOR_BLUE		;COLOR WHEN NOT SELECTED
	.WORD	12			;HEIGHT OF SELECTION BAR
	.WORD	-2			;DISTANCE OF BAR FROM TOP OF TEXT (NEGATIVE)
	.WORD	BAR_DX+5		;EXTRA X ON EACH SIDE.
	.WORD	170			;WIDTH OF BAR!
	.WORD	COLOR_DECAY		;TEXT COLOR OF SELECTED ITEM
	.LONG	MESS_TOPAGE2,0,NO_HELP		;"TO NEXT PAGE"
	.LONG	MESS_BACKP1,0,NO_HELP		;"TO PREVIOUS PAGE"
	.LONG	MESS_MM,FORCE_MAIN,NO_HELP	;"RETURN TO MAIN MENU"
	.LONG	0

**************************************************************************
*								         *
* 		    AUDIT PAGE OPTIONS #3				 *
* 									 *
* 		      TO PREVIOUS PAGE					 *
* 		     RETURN TO MAIN MENU				 *
*								         *
**************************************************************************
MEN_AP3
	.LONG	RD7FONT			;FONT
	.LONG	STRCNRM			;CENTER PLEASE
	.LONG	MESS_PATTERNS		;TITLE
	.WORD	COLOR_YELLOW		;COLOR OF TITLE
	.WORD	200			;UL X      (CENTER IT!)
	.WORD	227			;UL Y
	.WORD	12			;VERTICAL SPACING
	.WORD	COLOR_BLUE		;COLOR WHEN NOT SELECTED
	.WORD	12			;HEIGHT OF SELECTION BAR
	.WORD	-2			;DISTANCE OF BAR FROM TOP OF TEXT (NEGATIVE)
	.WORD	BAR_DX+5		;EXTRA X ON EACH SIDE.
	.WORD	170			;WIDTH OF BAR!
	.WORD	COLOR_DECAY		;TEXT COLOR OF SELECTED ITEM
	.LONG	MESS_BACKP1,0,NO_HELP	;"TO PREVIOUS PAGE"
	.LONG	MESS_MM,FORCE_MAIN,NO_HELP	;"RETURN TO MAIN MENU"
	.LONG	0


**************************************************************************
*								         *
* 			AUDIT PAGE MESSAGES				 *
*								         *
**************************************************************************
	.IF GERMAN

MESS_TOPAGE2
	.STRING	"N",C_GERA,"CHSTE AUSLESE-SEITE",0
	.EVEN
MESS_BACKP1
	.STRING	"VORHERIGE AUSLESE-SEITE",0
	.EVEN
M_GAMEC
	.STRING	"KOMPLETT DURCHGESPIELTE SPIELE",0
	.EVEN
M_WAVER
	.STRING	"DURCHSCHN. ERREICHTE WELLE",0
	.EVEN
M_COSTPG
	.STRING	"DURCHSCHN. KREDIT/SPIEL",0
	.EVEN
M_BURNIN
	.STRING	"BURN-IN-TEST ERFOLGREICH BEENDET",0
	.EVEN
M_1TIME
	.STRING	"ZEIT F. 1 SPIELER",0
	.EVEN
M_2TIME
	.STRING	"ZEIT F. 2 SPIELER",0
	.EVEN
M_3TIME
	.STRING	"ZEIT F. 3 SPIELER",0
	.EVEN
M_TTIME
	.STRING	"GESAMT-SPIELZEIT",0
	.EVEN
M_UPTIME
	.STRING	"EINSCHALTZEIT",0
	.EVEN
M_AVGTC
	.STRING	"DURCHSCHN. ZEIT/KREDIT",0
	.EVEN
M_MAXWAVE
	.STRING	"MAXIMUM-WELLE ERREICHT",0
	.EVEN
M_CONTOFF
	.STRING "ANGEBOTENE SPIELFORTSETZUNGEN",0
	.EVEN
M_CONTTAK
	.STRING	"ANGENOMMENE SPIELFORTSETZUNGEN",0
	.EVEN
M_PCTCONT
	.STRING	"PERCENTAGE OF ",W_CONTINUES," TAKEN",0
	.EVEN
M_SLAMS
	.STRING	"M",C_GERU,"NZT",C_GERU,"R-SLAMS",0
	.EVEN

	.ELSE

MESS_TOPAGE2
	.STRING	"NEXT ",W_AUDIT," PAGE",0
	.EVEN
MESS_BACKP1
	.STRING	"PREVIOUS ",W_AUDIT," PAGE",0
	.EVEN
M_GAMEC
	.STRING	W_GAME,"S ",W_PLAY,"ED TO COMPLETION",0
	.EVEN
M_WAVER
	.STRING	W_AVERAGE," WAVE REACHED",0
	.EVEN
M_COSTPG
	.STRING	W_AVERAGE," ",W_CREDITS," SPENT PER ",W_GAME,0
	.EVEN
M_COSTPP
	.STRING	W_AVERAGE," ",W_CREDITS," SPENT PER ",W_PLAYER,"/",W_GAME,0
	.EVEN
M_BURNIN
	.STRING	"BURNIN LOOPS SUCCESSFULLY COMPLETED",0
	.EVEN
M_1TIME
	.STRING	W_TIME," 1 ",W_PLAYER," ONLY",0
	.EVEN
M_2TIME
	.STRING	W_TIME," 2 ",W_PLAYER," ",W_SIMULTANEOUS,0
	.EVEN
M_3TIME
	.STRING	W_TIME," 3 ",W_PLAYER," ",W_SIMULTANEOUS,0
	.EVEN
M_TTIME
	.STRING	W_TOTAL," ",W_PLAY," ",W_TIME,0
	.EVEN
M_UPTIME
	.STRING	W_TOTAL," ",W_GAME," UPTIME",0
	.EVEN
M_AVGTC
	.STRING	W_AVERAGE," ",W_TIME," / ",W_CREDIT,0
	.EVEN
M_MAXWAVE
	.STRING	"MAXIMUM WAVE COMPLETED",0
	.EVEN
M_CONTOFF
	.STRING W_GAME," ",W_CONTINUES," OFFERED",0
	.EVEN
M_CONTTAK
	.STRING	W_GAME," ",W_CONTINUES," TAKEN",0
	.EVEN
M_PCTCONT
	.STRING	"PERCENTAGE OF ",W_CONTINUES," TAKEN",0
	.EVEN
M_SLAMS
	.STRING	W_COIN," DOOR SLAMS",0
	.EVEN

	.ENDIF

M_LABTR
	.STRING	"REACHED L.A. BTR",0
	.EVEN
M_LACLUB
	.STRING	"ENTERED CLUB X",0
	.EVEN
M_LAAERO
	.STRING	"REACHED AEROSMITH IN CLUB X",0
	.EVEN
M_LAEND
	.STRING	"COMPLETED CLUB X",0
	.EVEN
M_FLHELI
	.STRING	"REACHED HELICOPTER BOSS",0
	.EVEN
M_FLEND
	.STRING	"COMPLETED FLYING WAVE",0
	.EVEN
M_MIDEAST
	.STRING	"SELECTED MIDDLE EAST",0
	.EVEN
M_MIEND
	.STRING	"COMPLETED MIDDLE EAST",0
	.EVEN
M_JUNGLE
	.STRING	"SELECTED JUNGLE",0
	.EVEN
M_JUBTR
	.STRING	"REACHED JUNGLE BTR",0
	.EVEN
M_JUDESK
	.STRING	"REACHED RECEPTIONIST",0
	.EVEN
M_JUELEV
	.STRING	"REACHED ELEVATOR",0
	.EVEN
M_JUBZERK
	.STRING	"REACHED FINAL HALLWAY",0
	.EVEN
M_JUBUG
	.STRING	"STARTED BUG CHASE",0
	.EVEN
M_JUEND
	.STRING	"COMPLETED JUNGLE",0
	.EVEN
M_JAPAN
	.STRING	"SELECTED PACIFIC RIM",0
	.EVEN
M_JACRATE
	.STRING	"REACHED WAREHOUSE",0
	.EVEN
M_JAFAC
	.STRING	"REACHED FACTORY",0
	.EVEN
M_JARD
	.STRING	"REACHED R&D AREA",0
	.EVEN
M_JADESK
	.STRING	"REACHED MANAGER'S OFFICE",0
	.EVEN
M_JAEND
	.STRING	"COMPLETED PACIFIC RIM",0
	.EVEN
M_WEMBLEY
	.STRING	"REACHED WEMBLEY STADIUM",0
	.EVEN
M_TYLER
	.STRING	"FOUND STEVEN TYLER",0
	.EVEN
M_PERRY
	.STRING	"FOUND JOE PERRY",0
	.EVEN
M_WHITFORD
	.STRING	"FOUND BRAD WHITFORD",0
	.EVEN
M_HAMILTON
	.STRING	"FOUND TOM HAMILTON",0
	.EVEN
M_KRAMER
	.STRING	"FOUND JOEY KRAMER",0
	.EVEN
M_BACKSTAGE
	.STRING	"PARTYED BACKSTAGE",0
	.EVEN

**************************************************************************
*								         *
* 	UTILITIES MENU							 *
*								         *
**************************************************************************

*
*        UTILITES MENU GOES LEFT OF CENTER
*

UM_WID   EQU     206
UM_X     EQU     TIT_ULX+GAP+MB_XWID+(UM_WID/2)+C_KLUDGE

	.IF GERMAN

MEN_UTIL
	.LONG	RD7FONT		;FONT
	.LONG	STRCNRM		;CENTER PLEASE
	.LONG	MESS_UTIL	;TITLE
	.WORD	COLOR_WHITE	;COLOR OF TITLE
	.WORD	UM_X		;UL X
	.WORD	MENU_Y-5	;UL Y
	.WORD	20		;VERTICAL SPACING
	.WORD	COLOR_WHITE	;COLOR WHEN NOT SELECTED
	.WORD	19		;HEIGHT OF SELECTION BAR
	.WORD	-5		;DISTANCE OF BAR FROM TOP OF TEXT (NEGATIVE)
	.WORD	BAR_DX		;EXTRA X ON EACH SIDE.
	.WORD	UM_WID		;WIDTH OF BAR!
	.WORD	COLOR_DECAY	;TEXT COLOR OF SELECTED ITEM
****	.LONG	MESS_OPMESS,DO_OPMESS,BLNK_HELP
	.LONG	MESS_CLCRED,DO_CLCRED,BLNK_HELP
	.LONG	MESS_CLCOIN,DO_CLCOIN,BLNK_HELP
	.LONG	MESS_CLAUD,DO_CLAUD,BLNK_HELP
	.LONG	MESS_HSRES,DO_HSRES,BLNK_HELP
	.LONG	MESS_DEF_ADJ,DO_DEF_ADJ,BLNK_HELP
	.LONG	MESS_FACSET,DO_FACSET,BLNK_HELP
	.LONG	MESS_MM,0,BLNK_HELP		;RETURN TO MAIN MENU
	.LONG	0		;END

MESS_CLCRED
U_CLR_CRED
MESS_CCCONF
	.STRING "KREDITE-L]SCHUNG",0
	.EVEN
MESS_CLCOIN
U_CLR_COIN
	.STRING "M{NZZ[HLER-L]SCHUNG",0
	.EVEN
MESS_CLAUD
U_CLR_AUD
	.STRING "AUSLESEDATEN L]SCHEN",0
	.EVEN
MESS_HSRES
	.STRING "HIGHSCORE L]SCHEN",0
	.EVEN
MESS_FACSET
	.STRING "FABRIKDATENEINSTELLUNG",0
	.EVEN
MESS_FACFAIL
	.STRING	"CMOS SCHLECHT",0
	.EVEN
MESS_CANCELLED
	.STRING "CANCELLED",0
	.EVEN
MESS_DEF_ADJ
	.STRING "VORGEW[HLTE EINSTELLUNG",0
	.EVEN

	.ELSE
MEN_UTIL
	.LONG	RD7FONT		;FONT
	.LONG	STRCNRM		;CENTER PLEASE
	.LONG	MESS_UTIL	;TITLE
	.WORD	COLOR_WHITE	;COLOR OF TITLE
	.WORD	UM_X		;UL X
	.WORD	MENU_Y-5	;UL Y
	.WORD	20		;VERTICAL SPACING
	.WORD	COLOR_WHITE	;COLOR WHEN NOT SELECTED
	.WORD	19		;HEIGHT OF SELECTION BAR
	.WORD	-5		;DISTANCE OF BAR FROM TOP OF TEXT (NEGATIVE)
	.WORD	BAR_DX		;EXTRA X ON EACH SIDE.
	.WORD	UM_WID		;WIDTH OF BAR!
	.WORD	COLOR_DECAY	;TEXT COLOR OF SELECTED ITEM
****	.LONG	MESS_OPMESS,DO_OPMESS,OPMESS_HELP
	.LONG	MESS_CLCRED,DO_CLCRED,CLCRED_HELP
	.LONG	MESS_CLCOIN,DO_CLCOIN,CLCOIN_HELP
	.LONG	MESS_CLAUD,DO_CLAUD,CLAUD_HELP
	.LONG	MESS_HSRES,DO_HSRES,HSRES_HELP
	.LONG	MESS_DEF_ADJ,DO_DEF_ADJ,DEF_ADJ_HELP
	.LONG	MESS_FACSET,DO_FACSET,FACSET_HELP
	.LONG	MESS_MM,0,BLNK_HELP		;RETURN TO MAIN MENU
	.LONG	0		;END

MESS_CLCRED
U_CLR_CRED
	.STRING W_CLEAR," ",W_CREDITS,0
	.EVEN
MESS_CCCONF
	.STRING W_CREDITS," ",W_CLEAR,"ED",0
	.EVEN
MESS_CLCOIN
U_CLR_COIN
	.STRING W_CLEAR," ",W_COINCOUNTS,0
	.EVEN
MESS_CLAUD
U_CLR_AUD
	.STRING W_CLEAR," ",W_GAME," ",W_AUDITS,0
	.EVEN
MESS_HSRES
	.STRING "RESET ",W_HIGH," ",W_SCORE,"S",0
	.EVEN
MESS_FACSET
	.STRING "FULL FACTORY RESTORE",0
	.EVEN
MESS_FACFAIL
	.STRING  "FAILURE IN CMOS RAM",0
	.EVEN
MESS_CANCELLED
	.STRING "CANCELLED",0
	.EVEN
MESS_DEF_ADJ
	.STRING "DEFAULT ",W_ADJUSTMENTS,0
	.EVEN

	.ENDIF

*
*        HELP FOR UTILITY MENU
*
CLCRED_HELP
	.WORD	0		;CENTER JUSTIFY
	.WORD	COLOR_BLUE	;COLOR
	.WORD	3		;2 ENTRIES
	.LONG	MEH_CLCRED1
	.LONG	MEH_CLCRED2
	.LONG	MEH_CLCRED3

CLCOIN_HELP
	.WORD	0		;CENTER JUSTIFY
	.WORD	COLOR_BLUE	;COLOR
	.WORD	4		;2 ENTRIES
	.LONG	MEH_CLCOIN1
	.LONG	MEH_CLCOIN2
	.LONG	MEH_CLCOIN3
	.LONG	MEH_CLCOIN4

CLAUD_HELP
	.WORD	0		;CENTER JUSTIFY
	.WORD	COLOR_BLUE	;COLOR
	.WORD	2		;2 ENTRIES
	.LONG	MEH_CLAUD1
	.LONG	MEH_CLAUD2

HSRES_HELP
	.WORD	0		;CENTER JUSTIFY
	.WORD	COLOR_BLUE	;COLOR
	.WORD	3		;2 ENTRIES
	.LONG	MEH_RESHS1
	.LONG	MEH_RESHS2
	.LONG	MEH_RESHS3

OPMESS_HELP
	.WORD	0		;CENTER JUSTIFY
	.WORD	COLOR_BLUE	;COLOR
	.WORD	4		;2 ENTRIES
	.LONG	MEH_CUSM1
	.LONG	MEH_CUSM2
	.LONG	MEH_CUSM3
	.LONG	MEH_CUSM4

DEF_ADJ_HELP
	.WORD	0		;CENTER JUSTIFY
	.WORD	COLOR_BLUE	;COLOR
	.WORD	4		;2 ENTRIES
	.LONG	MEH_DEFA1
	.LONG	MEH_DEFA2
	.LONG	MEH_DEFA3
	.LONG	MEH_DEFA4

FACSET_HELP
	.WORD	0		;CENTER JUSTIFY
	.WORD	COLOR_BLUE	;COLOR
	.WORD	3		;2 ENTRIES
	.LONG	MEH_FAC1
	.LONG	MEH_FAC2
	.LONG	MEH_FAC3

**************************************************************************
*                                                                        *
*          STRINGS FOR UTILITY HELP MENUS                                *
*                                                                        *
**************************************************************************
MEH_CLCRED1
	.STRING "REMOVE ANY",0
	.EVEN
MEH_CLCRED2
	.STRING "POSTED ",W_CREDITS,0
	.EVEN
MEH_CLCRED3
	.STRING "FROM THE ",W_GAME,0
	.EVEN
MEH_CLCOIN1
	.STRING W_CLEAR," OUT PAID",0
	.EVEN
MEH_CLCOIN2
	.STRING W_CREDITS," ",W_TOTAL,0
	.EVEN
MEH_CLCOIN3
	.STRING "AND THE ",W_COIN,0
	.EVEN
MEH_CLCOIN4
	.STRING W_SLOT," COUNTERS",0
	.EVEN
MEH_CLAUD1
	.STRING W_CLEAR," ",W_GAME,W_PLAY,0
	.EVEN
MEH_CLAUD2
	.STRING "STATISTICS",0
	.EVEN
MEH_RESHS1
	.STRING "RESET ",W_HIGH," ",W_SCORE,0
	.EVEN
MEH_RESHS2
	.STRING "TABLE TO FACTORY",0
	.EVEN
MEH_RESHS3
	.STRING "DEFAULT VALUES",0
	.EVEN
MEH_CUSM1
	.STRING "ENTER YOUR OWN",0
	.EVEN
MEH_CUSM2
	.STRING W_MESSAGE," TO",0
	.EVEN
MEH_CUSM3
	.STRING "APPEAR IN THE",0
	.EVEN
MEH_CUSM4
	.STRING "ATTRACT MODE",0
	.EVEN
MEH_DEFA1
	.STRING "SET ALL ",W_GAME,0
	.EVEN
MEH_DEFA2
	.STRING W_ADJUSTMENTS," TO",0
	.EVEN
MEH_DEFA3
	.STRING "THEIR FACTORY",0
	.EVEN
MEH_DEFA4
	.STRING "DEFAULT VALUE",0
	.EVEN
MEH_FAC1
	.STRING "RESET ALL ",W_AUDITS,",",0
	.EVEN
MEH_FAC2
	.STRING "COUNTERS, ",W_ADJUSTMENTS,0
	.EVEN
MEH_FAC3
	.STRING "AND THE ",W_HIGH," ",W_SCORE,"S.",0
	.EVEN

**************************************************************************
*								         *
* 	PRESS ANY BUTTON TO CONTINUE					 *
*								         *
**************************************************************************
ANY_MENU
	.LONG	RD7FONT		;FONT
	.LONG	STRCNRM		;CENTER PLEASE
	.LONG	0		;TITLE
	.WORD	0		;COLOR OF TITLE
	.WORD	200		;UL X
	.WORD	215		;UL Y
	.WORD	MENU_DY		;VERTICAL SPACING
	.WORD	COLOR_BLUE	;COLOR WHEN NOT SELECTED
	.WORD	BAR_HITE	;HEIGHT OF SELECTION BAR
	.WORD	BAR_DY		;DISTANCE OF BAR FROM TOP OF TEXT (NEGATIVE)
	.WORD	BAR_DX		;EXTRA X ON EACH SIDE.
	.WORD	234		;WIDTH OF BAR!
	.WORD	COLOR_DECAY	;TEXT COLOR OF SELECTED ITEM
	.LONG	MESS_ANY,0,NO_HELP   
	.LONG	0

	 .IF GERMAN

MESS_ANY
	.STRING	"WEITER MIT BELIEBIGEM KNOPF",0
	.EVEN

MESS_FFSCONF
MESS_FAC
	MESS_MAC  RD7FONT,SPACING07,200,96,COLOR_PWHITE,STRCNRM,0
MESS_DEFCONF
	.STRING	"VORGEW",C_GERA,"HLTE EINSTELLUNG.",0
	.EVEN
	.WORD	1
	MESS_MAC RD7FONT,SPACING07,200,112,COLOR_PYELLOW,STRCNRM,0
	.EVEN
MESS_CCNCONF
	.STRING	"M",C_GERU,"NZZ",C_GERA,"HLER-L",C_GERO,"SCHUNG.",0
	.EVEN
	.WORD	1
	MESS_MAC RD7FONT,SPACING07,200,128,COLOR_PBLUE,STRCNRM,0
MESS_CAUDCONF
	.STRING	"AUSLESEDATEN L",C_GERO,"SCHEN.",0
	.EVEN
	.WORD	1
	MESS_MAC RD7FONT,SPACING07,200,144,COLOR_PRED,STRCNRM,0
MESS_HSRCONF
	.STRING  "HIGHSCORE L",C_GERO,"SCHEN.",0
	.EVEN
	.WORD	0

	.ELSE

MESS_ANY
	.STRING	"ENTER ",W_BUTTON," TO ",W_CONTINUE,0
	.EVEN

MESS_FFSCONF
MESS_FAC
	MESS_MAC  RD7FONT,SPACING07,200,96,COLOR_PWHITE,STRCNRM,0
MESS_DEFCONF
	.STRING	"DEFAULT ",W_ADJUSTMENTS," RESTORED.",0
	.EVEN
	.WORD	1
	MESS_MAC RD7FONT,SPACING07,200,112,COLOR_PYELLOW,STRCNRM,0
	.EVEN
MESS_CCNCONF
	.STRING	W_COINCOUNTS," ",W_CLEAR,"ED.",0
	.EVEN
	.WORD	1
	MESS_MAC RD7FONT,SPACING07,200,128,COLOR_PBLUE,STRCNRM,0
MESS_CAUDCONF
	.STRING	W_GAME," ",W_AUDITS," ",W_CLEAR,"ED.",0
	.EVEN
	.WORD	1
	MESS_MAC RD7FONT,SPACING07,200,144,COLOR_PRED,STRCNRM,0
MESS_HSRCONF
	.STRING  W_HIGH," ",W_SCORE," TABLE RESET.",0
	.EVEN
	.WORD	0

	.ENDIF

*
*        MONITOR PATTERNS
*

	.IF	PRINTER
	.ELSE

MEN_PATTERNS
         .LONG   RD7FONT        ;FONT
         .LONG   STRCNRM         ;CENTER PLEASE
         .LONG   MESS_PATTERNS         ;TITLE
         .WORD	COLOR_RED    ;COLOR OF TITLE
         .WORD   200             ;UL X      (CENTER IT!)
         .WORD   MENU_Y-3        ;UL Y
         .WORD   20              ;VERTICAL SPACING
         .WORD	COLOR_YELLOW    ;COLOR WHEN NOT SELECTED
         .WORD   20              ;HEIGHT OF SELECTION BAR
         .WORD   -6             ;DISTANCE OF BAR FROM TOP OF TEXT (NEGATIVE)
         .WORD   BAR_DX          ;EXTRA X ON EACH SIDE.
         .WORD   234             ;WIDTH OF BAR!
         .WORD	COLOR_DECAY      ;TEXT COLOR OF SELECTED ITEM
         .LONG   MESS_RED,GO_RED,BLNK_HELP
         .LONG   MESS_GREEN,GO_GREEN,BLNK_HELP
         .LONG   MESS_BLUE,GO_BLUE,BLNK_HELP
         .LONG   MESS_BARS,GO_BARS,BLNK_HELP
         .LONG   MESS_CROSS,GO_CONV,BLNK_HELP
         .LONG   MESS_DIAGM,0,BLNK_HELP
         .LONG   MESS_MM,FORCE_MAIN,NO_HELP        ;RETURN TO MAIN MENU
         .LONG   0

	.IF GERMAN

MESS_RED
	.STRING "ROT",0
	.EVEN
MESS_GREEN
	.STRING "GR",C_GERU,"N",0
	.EVEN
MESS_BLUE
	.STRING "BLAU",0
	.EVEN
MESS_BARS
	.STRING "FARBBALKEN",0
	.EVEN
MESS_CROSS
	.STRING "GITTERMUSTER",0
	.EVEN
MESS_DIAGM
	.STRING "ZUR",C_GERU,"CK ZUM DIAGNOSE-MEN",C_GERU,0
	.EVEN

	.ELSE

MESS_RED
	.STRING "RED ",W_SCREEN,0
	.EVEN
MESS_GREEN
	.STRING "GREEN ",W_SCREEN,0
	.EVEN
MESS_BLUE
	.STRING "BLUE ",W_SCREEN,0
	.EVEN
MESS_BARS
	.STRING "COLOR BARS",0
	.EVEN
MESS_CROSS
	.STRING "CROSSHATCH  PATTERN",0
	.EVEN
MESS_DIAGM
	.STRING "BACK TO DIAGNOSTICS MENU",0
	.EVEN

	.ENDIF

	.ENDIF

NULL_ST
	.BYTE	0
	.EVEN

	.IF	PRINTER
**************************************************************************
*								         *
* 	AUDIT PRINTING TABLES						 *
*								         *
**************************************************************************

PAMAC	.MACRO	TEXT,ADJUST,FORMAT
	.LONG	:TEXT:
	.WORD	:ADJUST:
	.WORD	:FORMAT:
	.ENDM

;
;	FORMAT
;
;		0 = STRAIGHT NUMBER
;		1 = TIME
;		2 = TOTAL NUMBER OF PLAYS ( GROSS, HUH? )
;

PRINTAUDTABLE:
        PAMAC	M_PLAYS,0,2     	;PLAYS ON TOP
	PAMAC	M_TTIME,AUDPTIME,1
	PAMAC	M_UPTIME,AUDUPTIME,1
	PAMAC	M_AVGTL,AUDAVGTL,4
	PAMAC	M_AVGTC,AUDAVGTC,3
	PAMAC	M_1TIME,AUD1TIME,1
	PAMAC	M_2TIME,AUD2TIME,1
	PAMAC	M_MAXWAVE,AUDMAXWAVE,0
	PAMAC	M_CONTOFF,AUDCONTOFFER,0
	PAMAC	M_CONTTAK,AUDCONTTAKEN,0
	PAMAC	M_PCTCONT,AUDCONTTAKEN,7
	PAMAC	M_SLAMS,AUDSLAMS,0
	PAMAC	M_GAMEC,AUDFINISH,0
	PAMAC	M_COSTPG,AUDAVGGC,6
	PAMAC	M_WAVER,AUDWAVECNT,5
	PAMAC	M_BURNIN,AUDAUTO,0
	.LONG	0

PRINTCOINTABLE:
	PAMAC   M_LCOIN,AUDLCOIN,0
        PAMAC   M_RCOIN,AUDRCOIN,0
        PAMAC   M_CCOIN,AUDCCOIN,0
	PAMAC	M_4COIN,AUD4COIN,0
	PAMAC	M_SCOIN,AUDSCOIN,0
        PAMAC   M_PAIDC,AUDPAIDC,0
	.LONG	0

	.ENDIF 

