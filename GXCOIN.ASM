   	.MLIB	"GXMACS.LIB"
	.FILE	"GXCOIN.ASM"
	.TITLE	"<<< GENERATION X - COIN HANDLING ROUTINES >>>"
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
	.INCLUDE	"IMGTBL.GLO"
	.INCLUDE	"BGNDEQU.H"


	.DEF	RCOIN,LCOIN,CCOIN,XCOIN, SCOIN,SLAM, COININT, NO_CREDS
	.DEF	CR_STRTP, CR_CONTP, P_START, P_CONT, CR_BOTH
	.DEF	GET_CSTR, CHECKFREE, COUNTER_ON, COUNTER_OFF
	.DEF	COINFLAG, TIMEINT, TIMEINIT, GAMEUNITS
	.DEF	CAT_A0, STRCAT
	.DEF	CRED_P
	.DEF	CREDIT_SCREEN
	.DEF	CRED_STRING
	.DEF	OCTO_FLAG

*SYMBOLS IN APBGDATA.ASM
	.REF	CREDIT_BGND
*SYMBOLS IN GXRAM.ASM
	.REF	COUNTER_COPY, SKYCOLOR, HOLD_ENEMY_DISPATCH
*SYMBOLS IN APMISC.ASM
	.REF	COLOR_START
*SYMBOLS IN APADJ.ASM
	.REF	TAMPEREDP, GET_CSPT
*SYMBOLS IN AP.ASM
	.REF	SWITCH_SPOKEN, WIPEOUT
*SYMBOLS IN APHSTD.ASM
	.REF	DEC_HSR, ON_HSTD
	.REF	RC_BYTE, RC_BYTEI, RC_WORD
	.REF	WC_BYTE, WC_BYTEI, WC_WORD, WC_WORDI
*SYMBOLS IN APMENU.ASM
	.REF	P_FORK
*SYMBOLS IN APDTST.ASM
	.REF	READ_DIP
*SYMBOLS IN APSCORE.ASM
	.REF	G_CRED
*SYMBOLS IN APATT.ASM
	.REF	OCTO_PAGE, ON_CRED, ATT_MODE_CREDIT

	.REF	KIL_CYCLE_COL

*SYMBOLS IN APPRNT.ASM
	.IF	PRINTER
	.REF	PLCOIN,PRCOIN,PSCOIN
	.ENDIF

**************************************************************************
*								         *
* 	GLOBAL VARIABLES						 *
*								         *
**************************************************************************

	.BSS	C_FLAGS,4*32		;INTERRUPT COIN BOUNCE
	.BSS	CTRLEFT,16		; FOR THE COIN COUNTERS
	.BSS	CTRRIGHT,16
	.BSS	COINFLAG,16
	.BSS	GAMEUNITS,16		;UNITS USED PER CURRENT GAME
	.BSS	TIMECNT,16		;TIME COUNTER
	.BSS	SUBTIMECNT,16		;YET ANOTHER TIMER COUNTER
	.BSS	OCTO_FLAG,16		;OCTOPUS FLAG
	.BSS	TEXT_BUFF,30*16		;TEMP FOR BUILDING STRINGS
	.BSS	UNUSED_WORD1,16		;For alignment purposes

**************************************************************************
*								         *
* 	COIN EQUATES							 *
*								         *
**************************************************************************

LC_FLAG  EQU     C_FLAGS
RC_FLAG  EQU     C_FLAGS+8
CC_FLAG  EQU     RC_FLAG+8
XC_FLAG	EQU	CC_FLAG+8

RUN_TIME EQU     32		;2ND LONG WORD COUNTS DOWN LONG TIME
OPENS_LEFT EQU   RUN_TIME+32	;3RD LONG WORD COUNTS DOWN CONSEC OPENS

PULSE_MAX        EQU     700/16       ;FRAMES TILL ITS TOO LINE.
MIN_OPENS        EQU     4
ACC_LIMIT        EQU     80H          ;AFTER 2 SECONDS OF NO-REPLY....RE-SET FLAG!
COIN_SBIT        EQU     0
COIN_SUCC_BIT    EQU     1
COIN_FAIL_BIT    EQU     2
COIN_ACK_BIT     EQU     3

COIN_SFLAG       EQU     1
COIN_SUCC_VAL    EQU     2
COIN_FAIL_VAL    EQU     4
COIN_ACK_VAL     EQU     8

**************************************************************************
*								         *
* 	COIN ROUTINES							 *
*								         *
**************************************************************************

	.TEXT
	.EVEN

**************************************************************************
*								         *
* 	CLICKLEFT							 *
* 									 *
* 	CLICK THE LEFT COIN COUNTER					 *
* 									 *
* 	ENTRY								 *
* 		NOTHING							 *
* 									 *
* 	EXIT								 *
* 		NOTHING							 *
*								         *
**************************************************************************

CLICKLEFT:
	MMTM	SP,A0,A1,A7
SINGLECLICK
	MOVE	@CTRLEFT,A0,W
	INC	A0
	MOVE	A0,@CTRLEFT,W
	CALLR	COINCTR_P		; CHECK TO SEE IF PROCESS EXISTS
	JRNE	CLRET
	CREATE	PID_COINCTR,COINCOUNTER
CLRET
	MMFM	SP,A0,A1,A7
	RETS

**************************************************************************
*								         *
* 	CLICKRIGHT							 *
* 									 *
* 	CLICK THE RIGHT COIN COUNTER					 *
* 									 *
* 	ENTRY								 *
* 		NOTHING							 *
* 									 *
* 	EXIT								 *
* 		NOTHING							 *
*								         *
**************************************************************************

CLICKRIGHT:
	MMTM	SP,A0,A1,A7
	CALLA	READ_DIP
	ANDI	DPCOUNTER,A0		; CHECK FOR DUAL COUNTERS
	JRZ	SINGLECLICK		; COMBINED COUNTER
	MOVE	@CTRRIGHT,A0,W
	INC	A0
	MOVE	A0,@CTRRIGHT,W
	CALLR	COINCTR_P		; CHECK TO SEE IF PROCESS EXISTS
	JRNE	CRRET
	CREATE	PID_COINCTR,COINCOUNTER
CRRET
	MMFM	SP,A0,A1,A7
	RETS


**************************************************************************
*								         *
* 	COINCOUNTER							 *
* 									 *
* 	PROCESS THAT DEALS WITH THE COIN COUNTER			 *
* 									 *
* 	ENTRY								 *
* 		NOTHING							 *
* 									 *
* 	EXIT								 *
* 		NOTHING							 *
*								         *
**************************************************************************
COINCOUNTER
	CLR	A8
	MOVE	@CTRLEFT,A1,W
	JRZ	CC1
	MOVI	LEFT_COIN,A8
	DEC	A1
	MOVE	A1,@CTRLEFT,W
CC1
	MOVE	@CTRRIGHT,A1,W
	JRZ	CC2
	ORI	RIGHT_COIN,A8
	DEC	A1
	MOVE	A1,@CTRRIGHT,W
CC2
	MOVE	A8,A8
	JRZ	CCDIE			; BOTH WERE EMPTY
;
	CALLA	READ_DIP
	ANDI	DPCOUNTER,A0
	JRNZ	CC3
   	ORI	RIGHT_COIN,A8
	ORI	LEFT_COIN,A8		; MAKE SURE BOTH TRIGGER
CC3
	MOVE	A8,A0
	CALLA	COUNTER_ON

	SLEEP	7			; THIS SUCKS, BUT CARY LIKES IT

	MOVE	A8,A0
	CALLA	COUNTER_OFF

	SLEEP	7			; GIVE THEM TIME TO BE OFF
	JRUC	COINCOUNTER
CCDIE
	DIE

**************************************************************************
*								         *
* COIL_ON - TURN A COIL ON VIA THE SECURITY CHIP.			 *
* A0 = COIL MASK							 *
* RETURNS:								 *
* 	NOTHING								 *
*								         *
**************************************************************************
COUNTER_ON
	PUSH	A1
	MOVE	@COUNTER_COPY,A1,W     
	OR	A0,A1
	MOVE	A1,@COUNTER_COPY,W
	MOVE	A1,@COIN_COUNTERS,W
	PULL	A1
	RETS

**************************************************************************
*								         *
* COIL_OFF - TURN A COIL OFF VIA THE SECURITY CHIP.			 *
* A0 = COIL MASK							 *
* RETURNS:								 *
* 	NOTHING								 *
*								         *
**************************************************************************
COUNTER_OFF
	PUSH	A1
	MOVE	@COUNTER_COPY,A1,W
	ANDN	A0,A1
	MOVE	A1,@COUNTER_COPY,W
	MOVE	A1,@COIN_COUNTERS,W
	PULL	A1
	RETS

**************************************************************************
*								         *
* 	COINCTR_P							 *
* 									 *
* 	IS THERE A COIN COUNTER PROCESS RUNNING				 *
* 									 *
* 	ENTRY								 *
* 		NOTHING							 *
* 									 *
* 	EXIT								 *
* 		.EQ.	NO						 *
* 		.NE.	YES						 *
*								         *
**************************************************************************

COINCTR_P
	MOVI    PID_COINCTR,A0
        CALLA   EXISTP_ALL
	RETS


CREDIT_JUMP
	JSRP	CREDIT_SCREEN
	JAUC	ATT_MODE_CREDIT

**************************************************************************
*								         *
* 	CREDIT_SCREEN							 *
* 									 *
* 	PLOT THE APPROPRIATE CREDIT SCREEN -- DESTROY ANYTHING THAT	 *
* 	HAPPENS TO BE AROUND AT THE TIME				 *
* 									 *
* 	ENTRY								 *
* 		NOTHING							 *
* 									 *
* 	EXIT								 *
* 		NOTHING							 *
*								         *
**************************************************************************
CREDIT_SCREEN:
	CALLA	KILL_DESTRUCTIBLES
	CALLA	COLOR_START
	MOVE	@COINFLAG,A0,W		; CHECK TO SEE WHICH PAGE WE ARE
	JRNZ	CS1
	CALLA	WIPEOUT			; LATER, DUDES!
	PAGEOFF				;TURN OFF PAGE FLIPPING
	DISPON
	MOVE	@COINFLAG,A0,W		; CHECK TO SEE WHICH PAGE WE ARE
	JRNZ	CS1

	CALLA	CLR_SCRN

	MOVIM	SCRNST_FULL,@SCRNTL,L
	MOVKM	3,@GAMERASE,W		;TOP HALF ON AUTO-ERASE
	SLEEP	3			
	MOVI	CREDIT_BGND,A10
	CALLA	StrtBgnd		;ON WITH ONE PLANE
	MOVE	@SKYCOLOR,@IRQSKYE,W
;	SOUND1	SND_MUSICOFF

CS1
	MOVK	1,A0
	MOVE	A0,@COINFLAG,W		; FLAG WE ARE ON THE COIN PAGE

*****
	MOVI	OID_CREDIT,A0		;KILL THE CREDIT MESSAGE
	CALLA	KILOBJ_ALL
	MOVI	OID_PROMPT,A0		;KILL THE PROMPTERS
	CALLA	KILOBJ_ALL
	MOVI	OID_PROMPT2,A0
	CALLA	KILOBJ_ALL
	MOVI	OID_REQUIRED,A0
	CALLA	KILOBJ_ALL
	MOVI	OID_TEXT,A0
	CALLA	KILOBJ_ALL

	CALLR	OUTPUT_CUSTOM

	MOVI	COIN_MESS,A8
	MOVE	A2,A2
	JRNZ	CS2
	MOVI	COIN_MESS2,A8
CS2
	CALLA	LM_SETUP
	CALLR	GET_CSTR		; GET THE CHARACTER STRING
	JSRP	PRINTF
	JSRP	ADD_PROMPT		; ADD THE RANDOM MESSAGE FLASHER

         MOVI    REQUIRE_PROC,A7
         CALLA   P_FORK               ;START UP ANOTHER W/ SAME ID TO FLASH!

	SLEEP	1
	MOVKM	2,@GAMERASE,W		;TOP HALF ON AUTO-ERASE
*****
*DO A BOTTOM PRINT HERE
	SLEEP	300
	CLR	A0
	MOVE	A0,@COINFLAG,W

	MOVI	PID_COLOR,A0
	CALLA	KILLPROC_ALL
	CALLA	KIL_CYCLE_COL

	CALLA	FADEOUT
	SLEEP	17
	RETP

**************************************************************************
*								         *
* REQUIRE_PROC - PROCESS TO FLASH THE CREDIT REQUIREMENTS FOR THIS GAME. *
*								         *
**************************************************************************
REQUIRE_PROC
	CALLR	CHECKFREE
	JANZ	SUCIDE

	MOVI	REQUIRE_MESS,A8
	JSRP	LM_PRINTF
RP_LP
*PRINT THE CREDITS REQUIRED TO START
	MOVIM	SUFFIX_BS,@RAMTEMP2,L
	ADJUST	ADJCSTRT
	MOVE	A0,@RAMTEMP1,L
	CMPI	1,A0
	JRNE	RP_TOSTART
	MOVIM	SUFFIX_NULL,@RAMTEMP2,L
RP_TOSTART
	MOVI	RTOSTART_MESS,A8
	JSRP	LM_PRINTF

	SLEEP	45
	MOVI	OID_REQUIRED,A0
	CALLA	KILOBJ_ALL

*PRINT THE CREDITS REQUIRED TO CONTINUE
	MOVIM	SUFFIX_BS,@RAMTEMP2,L
	ADJUST	ADJCCONT
	MOVE	A0,@RAMTEMP1,L
	CMPI	1,A0
	JRNE	RP_TOCONTINUE
	MOVIM	SUFFIX_NULL,@RAMTEMP2,L
RP_TOCONTINUE
	MOVI	RTOCONTINUE_MESS,A8
	JSRP	LM_PRINTF

	SLEEP	45
	MOVI	OID_REQUIRED,A0
	CALLA	KILOBJ_ALL
     	JRUC	RP_LP

	.IF GERMAN

REQUIRE_MESS
         MESS_MAC  RD7FONT,SPACING20,200,CREDIT_Y+70,COLOR_PWHITE,STRCNRMO,OID_TEXT
	.STRING	"DIESES SPIEL BEN",C_GERO,"TICT:",0
	.EVEN

RTOSTART_MESS
         MESS_MAC  RD15FONT,SPACING20,200,CREDIT_Y+82,COLOR_PLF,STRCNRMO,OID_REQUIRED
	.STRING	"%d KREDIT%p BEI SPIELBEGINN.",0
	.LONG	RAMTEMP1
	.LONG	RAMTEMP2
	.EVEN

RTOCONTINUE_MESS
         MESS_MAC  RD15FONT,SPACING20,200,CREDIT_Y+89,COLOR_PLF,STRCNRMO,OID_REQUIRED
	.STRING	"%d KREDIT%p ZUR SPIELFORTSETZUNG.",0
	.LONG	RAMTEMP1
	.LONG	RAMTEMP2
	.EVEN

SUFFIX_BS:
	.STRING	"E",0

	.ELSE

REQUIRE_MESS
         MESS_MAC  RD7FONT,SPACING20,200,CREDIT_Y+70,COLOR_PWHITE,STRCNRMO,OID_TEXT
	.STRING	"THIS GAME REQUIRES:",0
	.EVEN

RTOSTART_MESS
         MESS_MAC  RD15FONT,SPACING20,200,CREDIT_Y+82,COLOR_PLF,STRCNRMO,OID_REQUIRED
	.STRING	"%d CREDIT%p TO START.",0
	.LONG	RAMTEMP1
	.LONG	RAMTEMP2
	.EVEN

RTOCONTINUE_MESS
         MESS_MAC  RD15FONT,SPACING20,200,CREDIT_Y+92,COLOR_PLF,STRCNRMO,OID_REQUIRED
	.STRING	"%d CREDIT%p TO CONTINUE.",0
	.LONG	RAMTEMP1
	.LONG	RAMTEMP2
	.EVEN

SUFFIX_BS:
	.STRING	"S",0

	.ENDIF

**************************************************************************
*								         *
* 	OUTPUT_CUSTOM							 *
* 									 *
* 	OUTPUT THE COINUP MESSAGE.  THIS PLOTS ALL THE DIFFERENT	 *
* 	FORMS OF IT..							 *
* 									 *
* 	ENTRY								 *
* 		NOTHING							 *
* 									 *
* 	EXIT								 *
* 		A2	NUMBER OF LINES PLOTTED				 *
*								         *
**************************************************************************

CM_LINE1 EQU     CUSTOM_MESSAGE
CM_LINE2 EQU     CUSTOM_MESSAGE+CMESS_LINE_SIZE
CM_LINE3 EQU     CUSTOM_MESSAGE+(2*CMESS_LINE_SIZE)

CM_Y_GAP	EQU	13
CM_Y_ADDGAP	EQU	[CM_Y_GAP,200]
CM_Y1		EQU	25
CM_Y2		EQU	15
CM_Y3		EQU	7

OUTPUT_CUSTOM
	MOVI	OID_CUSTOM,A0
	CALLA	KILOBJ_ALL		;KILL CURRENT CUSTOM MESSAGE

	CLR	A2
	CALLR	CHECKFREE
	JRNZ	OCGO			; BR = FREEPLAY

        MOVI    ADJMAXC,A0
        CALLA   GET_ADJ			; MAX CREDITS ALLOWED
        JRZ	OCGO			; BR = NO MAX CREDITS
	MOVE	A0,A1
        CALLR   CRED_P
	JRZ	OCGO			; AIN'T GOT NO CREDITS
	CMP	A1,A0
	JRLO	OCGO			; CREDITS < MAXCREDITS
	MOVI	MESS_MAX,A8
	JSRP	LM_PRINTF
	MOVI	1,A2
	JRUC	OCRET
;	JRUC	OCNOMESS
OCGO
;XUNIT  CALLA   ADJ_PAGE 
        MOVI    VALID_CUSTOM,A7
        CALLA   RC_WORD
        CMPI    VALID_VALUE,A0		; CHECK TO SEE IF MESSAGE IS VALID
	JRNZ	OCNOMESS		; BR = NOT VALID

	CALLR	NUM_CLINES		; COMPUTE NUMBER OF DISPLAYABLE LINES
	JRZ	OCNOMESS		; NOTHING TO SHOW
	MOVK	1,A2
	SLL	4,A0
	ADDI	CM_YTAB,A0
	MOVE	*A0,A9,W

	MOVI	CM_LINE1,A10
	CALLR	CK_LINE			; LOAD IT UP, BABY!
	JRZ	OC1
	CALLR	CPLOTLINE
OC1
	MOVI	CM_LINE2,A10
	CALLR	CK_LINE
	JRZ	OC2
	CALLR	CPLOTLINE
OC2
	MOVI	CM_LINE3,A10
	CALLR	CK_LINE
	JRZ	OC3
	CALLR	CPLOTLINE
OC3
	JRUC	OCRET
OCNOMESS
	CALLA	TAMPEREDP		;ARE WE IN CUSTOM COINAGE?
	JRZ	OCRET			;BR = YES
	CALLR	PLOTCOINAGE
OCRET
	RETS

CM_YTAB	.WORD	0,CM_Y1, CM_Y2, CM_Y3, CM_Y3

**************************************************************************
*								         *
* 	CPLOTLINE							 *
* 									 *
* 	PLOT THE LINE IN PDATA OUT ON THE SCREEN			 *
* 									 *
* 	ENTRY								 *
* 		A9	Y LOCATION TO PLOT AT				 *
* 									 *
* 	EXIT								 *
* 		A9	NEW Y LOCATION					 *
*								         *
**************************************************************************

CPLOTLINE:
	PUSH	A9
	PUSH	A9
	MOVI	CUSTOM_SETUP,A8
	CALLA	LM_SETUP
;	MOVE	A13,A8
;	ADDI	PDATA,A8
	MOVI	TEXT_BUFF,A8
	PULL	A9
	SLL	16,A9
	ADDI	200,A9
	JSRP	PRINTF
	PULL	A9
	ADDI	CM_Y_GAP,A9
	RETS

CUSTOM_SETUP:
         MESS_MAC  RD7FONT,SPACING20,196,0,COLOR_PWHITE,STRCNRMO,OID_CUSTOM

	 .IF GERMAN

MESS_MAX:
         MESS_MAC  RD15FONT,SPACING20,200,CM_Y1-5,COLOR_PLF,STRCNRMO,OID_CUSTOM
	.STRING "MAXIMUM KREDITE",0
	.EVEN

	.ELSE

MESS_MAX:
         MESS_MAC  RD15FONT,SPACING20,200,CM_Y1-5,COLOR_PLF,STRCNRMO,OID_CUSTOM
	.STRING	"MAXIMUM CREDITS",0
	.EVEN

	.ENDIF

**************************************************************************
*								         *
* 	NUM_CLINES							 *
* 									 *
* 	COMPUTE THE NUMBER OF DISPLAYABLE LINES IN CUSTOM RAM		 *
* 									 *
* 	ENTRY								 *
* 		NOTHING							 *
* 									 *
* 	EXIT								 *
* 		A0	NUMBER OF LINES					 *
*								         *
**************************************************************************

NUM_CLINES
	MMTM	SP,A1,A10
	CLR	A1
	MOVI	CM_LINE1,A10
	CALLR	CK_LINE
	JRZ	NC2
	INC	A1
NC2
	MOVI	CM_LINE2,A10
	CALLR	CK_LINE
	JRZ	NC3
	INC	A1
NC3
	MOVI	CM_LINE3,A10
	CALLR	CK_LINE
	JRZ	NC4
	INC	A1
NC4
	MOVE	A1,A0
	MMFM	SP,A1,A10
	RETS

**************************************************************************
*								         *
* 	CK_LINE								 *
* 									 *
* 	COPY A LINE INTO PDATA AREA, AND RETURN IN A0 NUMBER OF CHARS	 *
* 									 *
* 	ENTRY								 *
* 		A10	POINTER TO CMOS LOC OF LINE			 *
* 									 *
* 	EXIT								 *
* 		A0	NUMBER OF VALID CHARS IN LINE			 *
*								         *
**************************************************************************

CK_LINE:
	MMTM    SP,A1,A2,A3,A4,A7,A10
        MOVE    A10,A7               ;INPUT POINTER TO CMOS
;        MOVE    A13,A2              ;OUR PDATA AREA
;        ADDI    PDATA,A2            ;A10 IS DESTINATION.
	MOVI	TEXT_BUFF,A2

        MOVI    CMESS_CHARS,A1       ;COUNTER
;XUNIT  CALLA   ADJ_PAGE             ;POINT THE PAGE
	CLR	A3  		; ONLY SPACES SO FAR

CK_LOOP CALLA   RC_BYTEI             ;FETCH A BYTE
        MOVB    A0,*A2               ;STORE
	MOVE	A0,A0
	JRZ	CKLX			; END OF STRING
	CMPI	20H,A0			; CHECK FOR NON-SPACES
	JRZ	CKGO
	INC	A3
CKGO
        ADDI    BYTE_SIZE,A2
        DSJS    A1,CK_LOOP
	CLR	A0
	MOVE	A0,*A2,W		; MAKE SURE OF THINGS
CKLX
;XUNIT  CALLA   DEF_PAGE             ;POINT AWAY NOW
	MOVE	A3,A3			; HOW MANY "REAL" CHARACTERS
	MMFM    SP,A1,A2,A3,A4,A7,A10
	RETS

**************************************************************************
*								         *
* 	PLOTCOINAGE							 *
* 									 *
* 	PLOT OUT THE CURRENT COINAGE ON THE SCREEN			 *
* 									 *
* 	ENTRY								 *
* 		NOTHING							 *
* 									 *
* 	EXIT								 *
* 		NOTHING							 *
*								         *
**************************************************************************

PLOTCOINAGE:
	MMTM	SP,A0,A1,A6
	CLR	A2
	MOVI	ADJFREPL,A0
	CALLA	GET_ADJ
	JRNZ	PCNOHEAD
        MOVI    ADJMAXC,A0
        CALLA   GET_ADJ			; MAX CREDITS ALLOWED
        JRZ	PC1			; BR = NO MAX CREDITS
	MOVE	A0,A1
        CALLR   CRED_P
	JRZ	PC1			; AIN'T GOT NO CREDITS
	CMP	A1,A0
	JRHS	PCNOHEAD
PC1
	MOVI	ADJPRICE,A0
	CALLA	GET_ADJ			; GET THE CURRENT PRICING
        CALLA   GET_CSPT
        MOVE    *A6(CS_LIST),A2,L  	
        JRZ	PCNOHEAD		; NO HEADER, BELIEVE IT OR NOT
	MOVI	PCSETUP,A8
	CALLA	LM_SETUP
	MMTM	SP,A0,A1,A2	
	CLR	A0
PC2
	MOVE	*A2+,A1,L		; COUNT UP NUMBER OF MESSAGES
	JRZ	PC3
	INC	A0
	JRUC	PC2
PC3
	SLL	4,A0
	ADDI	CM_YTAB,A0
	MOVE	*A0,A9,W
	SLL	16,A9
	ADDI	200,A9
	MMFM	SP,A0,A1,A2
PCNEXTHEAD
        MOVE    *A2+,A8,L            	; PICKUP THE NEXT POINTER
	JRZ	PCDONE
	PUSHP	A2
	JSRP	PRINTF
	PULLP	A2
	SRL	16,A9
	SLL	16,A9			; MASK OFF X ADDRESS
	ADDI	CM_Y_ADDGAP,A9
	JRUC	PCNEXTHEAD
PCDONE
	MOVK	1,A2
	JRUC	PCRET

PCNOHEAD
	CLR	A2
PCRET
	MMFM	SP,A0,A1,A6
	RETS

PCSETUP
	MESS_MAC  RD7FONT,SPACING20,200,CM_Y1,COLOR_PWHITE,STRCNRMO,OID_CUSTOM

**************************************************************************
*								         *
* 	GET_CSTR							 *
* 									 *
* 	CREATE THE CREDIT STRING AND RETURN IT IN TEXT_BUFF		 *
* 									 *
* 	ENTRY								 *
* 		NOTHING							 *
* 									 *
* 	EXIT								 *
* 		A8	POINTS TO TEXT_BUFF				 *
*								         *
**************************************************************************
GET_CSTR: 
	MMTM	SP,A0,A1,A7,A10

	CALLR	CHECKFREE
	JRZ	NOT_FREE

	MOVI	MESS_FREEP,A8		;FREEPLAY MESSAGE
	JRUC	GET_CX
NOT_FREE
	MOVI	TEXT_BUFF,A7		;TEXT STRING TO BUILD IN
	MOVI	MESS_CREDITS,A8		;POINT AT TEXT PART
	CALLA	STRCAT			;BUILD THIS IN.
	CALLR	CRED_P
	MOVE	A0,A10			;SAVE CREDITS
	CALLR	CAT_A0
*
*	NOW WE NEED TO SEE IF WE SHOULD ADD A FRACTION.
*
	MOVI	ADJFRAC,A0
	CALLA	GET_ADJ			;CHECK THE ADJUSTMENT
	JRZ	NSFRAC			;DON'T SHOW IT!
*
*	ADD ANY FRACTION WE HAVE.
*
;XUNIT	CALLR	COIN_PAG		;PUT US ON COIN PAGE
	CALLR	GET_CUNITS		;A0 HAS CUNITS
;XUNIT	CALLA	DEF_PAGE		;FLIP CMOS AWAY
	MOVE	A0,A0			;ZERO?
	JRZ	NSFRAC			;THEN NO FRACTION.
*
*	WE HAVE A FRACTION...WERE THE CREDITS ZERO?
*
	MOVE	A10,A10			;WE SAVED EM IN A10
	JRNZ	NZM			;NON ZERO MANTISSA

	MOVI	TEXT_BUFF,A8		;LOOK FOR THE TERMINATOR
KILL_Z
	MOVB	*A8,A1			;GET A BYTE
	JRZ	NZM			;COULDN'T FIND IT....GO ON.
	CMPI	LET_0,A1		;IS THIS THE ZERO?
	JRZ	GOT_ZERO
	ADDI	BYTE_SIZE,A8
	JRUC	KILL_Z
GOT_ZERO 
	CLR	A1
	MOVB	A1,*A8			;KILL THE ZERO
	MOVE	A8,A7			;UPDATE END OF STRING LOCATION

NZM
	MOVI	MESS_2SPACE,A8		;SPACE BET. MANTISSA AND DENMO
	CALLA	STRCAT

NOT_ZM
	CALLR	CAT_A0			;ADD A0 ONTO FRACTION

	MOVI	MESS_SLASH,A8
	CALLA	STRCAT			;ADD SLASH

	MOVI	ADJCUNIT,A0		;UNITS REQUIRED FOR CREDIT
	CALLA	GET_ADJ
	CALLR	CAT_A0			;DENOMINATOR

NSFRAC
	MOVI	TEXT_BUFF,A8
GET_CX
	CLRC				;RETURN OK
GET_CXX 
	MMFM	SP,A0,A1,A7,A10
	RETS

**************************************************************************
*								         *
* 	CAT_A0								 *
* 									 *
* 	TURN A0 INTO A DECIMAL NUMBER AND THEN CONCATENATE IT ONTO	 *
* 	THE END OF THE STRING WE ARE BUILDING				 *
* 									 *
* 	ENTRY								 *
* 		A0	NUMBER FOR THE END OF THE STRING		 *
* 									 *
* 	EXIT								 *
* 		NOTHING							 *
*								         *
**************************************************************************

CAT_A0  
	MMTM    SP,A8
        MOVE    A0,A8                          ;CREDIT COUNT IN A8
        CALLA   HEXTOASC                       ;STRING
        CALLA   STRCAT                         ;NOW WE HAVE WHOLE NUMBER.
	MMFM    SP,A8
	RETS

**************************************************************************
*								         *
* 	STRCAT								 *
* 									 *
* 	CONCATENATE THE STRING POINTED TO BY A8 ONTO A7 STARTING AT	 *
* 	A7.  GROSS BUT EFFECTIVE					 *
* 									 *
* 	ENTRY								 *
* 		A7	STARTING POSITION IN STRING			 *
* 		A8	ZERO-TERMINATED STRING TO STICK ONTO A7		 *
* 									 *
* 	EXIT								 *
* 		A7	POINTS AT ZERO TERMINATOR			 *
*								         *
**************************************************************************

STRCAT
	PUSH	A0
STRLOOP
	MOVB	*A8,*A7			; STICK NEXT CHAR IN
	MOVB	*A7,A0			; MOVB SUCKS 
	JRZ	STRDONE
	ADDI	8,A7
	ADDI	8,A8			; WOOF WOOF WHO CARES
	JRUC	STRLOOP
STRDONE
	PULL	A0
	RETS

**************************************************************************
*								         *
* 	ADD_PROMPT							 *
* 									 *
* 	THIS IS CALLED ON THE CREDITS PAGE TO ADD A WORD OF 		 *
* 	WISDOM BELOW THE CREDITS MESSAGE -- IT PICKS OUT THE 		 *
* 	BEST MESSAGES AND BLINKS THEM					 *
* 									 *
* 	ENTRY								 *
* 		NOTHING							 *
* 									 *
* 	EXIT								 *
* 		NOTHING							 *
*								         *
**************************************************************************

ADD_PROMPT:
        MOVI    PROMPT_PROC,A7
        CALLA   P_FORK               ;START UP ANOTHER W/ SAME ID TO FLASH!
        RETP

**************************************************************************
*								         *
* 	PROMPT_PROC							 *
* 									 *
* 	PROCESS TO PICK A GOOD MESSAGE AND SHOW IT			 *
* 									 *
* 	ENTRY								 *
* 		NOTHING							 *
* 									 *
* 	EXIT								 *
* 		NOTHING							 *
*								         *
**************************************************************************

PROMPT_PROC:
	CALLR	CHECKFREE
	JRNZ	PPFREE			; BR = FREEPLAY

        CALLR   CRED_P
        JRZ     PPNOCOIN		; BR = NOT ENOUGH TO START 1 PLAYER

	MOVE	A0,A1			; STORE CREDS IN A1
	MOVI	ADJCSTRT,A0		; CREDITS TO START
	CALLA	GET_ADJ	
	CMP	A0,A1
	JRLO	PPNOCOIN		; BR = NOT ENOUGH TO START
	MOVE	A0,A2			; CREDS REQUIRED IN A2
	SUB	A2,A1			; GET US GOING HERE
	MOVK	1,A0			; HAVE ENOUGH FOR 1 PLAYER
	SUB	A2,A1
	JRN	PPMESS			; BR = NOT ENOUGH FOR 2
	INC	A0
	SUB	A2,A1
	JRN	PPMESS			; BR = NOT ENOUGH FOR 3

;	INC	A0
;	SUB	A2,A1
;	JRN	PPMESS			; BR = NOT ENOUGH FOR 4
;	INC	A0
;	JRUC	PPMESS			; CAN HAVE UP TO 4 PLAYERS

PPFREE
	MOVK	3,A0			; FREEPLAY IS MAX PLAYERS

;
;	A0	NUMBER OF PLAYERS WE ARE READY FOR ( 0 = NONE )
;
PPMESS
	MOVE	@NPLAYERS,A1,W		; GRAB GAME NUMBER OF PLAYERS
	INC	A1
	CMP	A1,A0
	JRLS	PPMESS1			; BR = COOL NUMBER
	MOVE	A1,A0			; SET TO MAXIMUM NUMBER OF PLAYERS
PPMESS1
	SLL	5,A0
	ADDI	PROMPT_TAB,A0
	MOVE	*A0,A0,L		; GET APPROPRIATE MESSAGE
	JRZ	PPNOCOIN
	PUSH	A0
	MOVI	PROMPT_SETUP,A8
	CALLA	LM_SETUP
	PULL	A8			; PULL OUT THE MESSAGE STRING
	JSRP	PRINTF
	MOVK	1,A0		
	JRUC	BLINKINIT
PPNOCOIN
	CLR	A0
BLINKINIT
	MOVE	A0,*A13(PDATA),W	; FLASH "PRESS START"
	MOVI	PROMPT_COLOR,A0
	MOVE	A0,*A13(PDATA+10H),L	; COLOR TO FLASH IT IN

BLINKLOOP
	MOVI	PROMPT_SETUP2,A8
	CALLA	LM_SETUP
	MOVE	*A13(PDATA),A8,W	; GET STRING
	SLL	5,A8
	ADDI	PROMPT_MESSTAB,A8
	MOVE	*A8,A8,L
	JSRP	PRINTF
	SLEEP	10H
	MOVI	OID_PROMPT2,A0
	CALLA	KILOBJ_ALL
	SLEEP	10H
	JRUC	BLINKLOOP

PROMPT_COLOR	EQU	COLOR_PWHITE

MESS_SLASH .STRING "/"
           .BYTE 0
           .EVEN

MESS_2SPACE .STRING " "
MESS_NULL   .BYTE 0
            .EVEN

CREDIT_Y .EQU	13+SKYTOPOF

	.IF GERMAN

MESS_CREDITS
         .STRING   "KREDIT "
         .BYTE     0
         .EVEN

	 .ELSE

MESS_CREDITS
         .STRING   "CREDIT "
         .BYTE     0
         .EVEN

	 .ENDIF

PROMPT_SETUP
         MESS_MAC  RD7FONT,SPACING20,196,CREDIT_Y+28,COLOR_PYELLOW,STRCNRMO,OID_PROMPT

PROMPT_SETUP2
         MESS_MAC  RD15FONT,SPACING20,200,CREDIT_Y+44,PROMPT_COLOR,STRCNRMO,OID_PROMPT2

	.IF GERMAN

PROMPT_1
	.STRING	"START F",C_GERU,"R 1 SPIELER.",0
	.EVEN
PROMPT_2
	.STRING	"START F",C_GERU,"R 1 ODER 2 SPIELER.",0
	.EVEN
PROMPT_3
	.STRING	"START F",C_GERU,"R 1, 2 ODER 3 SPIELER.",0
	.EVEN

	.ELSE

PROMPT_1
	.STRING	"READY FOR 1 PLAYER.",0
	.EVEN
PROMPT_2
	.STRING	"READY FOR 1 OR 2 PLAYERS.",0
	.EVEN
PROMPT_3
	.STRING	"READY FOR 1, 2 OR 3 PLAYERS.",0
	.EVEN

	.ENDIF

PROMPT_TAB
	.LONG	0,PROMPT_1, PROMPT_2, PROMPT_3

	.IF GERMAN

PROMPT_INSCOIN
	.STRING	"M",C_GERU,"NZE EINWERFEN BEI SPIELBEGINN.",0
	.EVEN
PROMPT_PRESSSTART
	.STRING	"START DR",C_GERU,"CKEN.",0
	.EVEN

	.ELSE

PROMPT_INSCOIN
	.STRING	"INSERT COIN.",0
	.EVEN
PROMPT_PRESSSTART
	.STRING	"PRESS START.",0
	.EVEN

	.ENDIF

PROMPT_MESSTAB
	.LONG	PROMPT_INSCOIN, PROMPT_PRESSSTART	

*
*        NORMAL CREDITS SETUP STRING
*

	.IF GERMAN

MESS_FREEP
         .STRING   "FREIS SPIEL"
         .BYTE     0
         .EVEN

	 .ELSE

MESS_FREEP
         .STRING   "FREE  PLAY"
         .BYTE     0
         .EVEN

	 .ENDIF

COIN_MESS
         MESS_MAC  RD20FONT,SPACING20,200,CREDIT_Y,COLOR_PWHITE,STRCNRMO,OID_CREDIT
	.EVEN
COIN_MESS2
         MESS_MAC  RD20FONT,SPACING20,200,CREDIT_Y,COLOR_PWHITE,STRCNRMO,OID_CREDIT
	.EVEN

**************************************************************************
*								         *
* 	COIN UTILITY ROUTINES						 *
*								         *
**************************************************************************

**************************************************************************
*								         *
* 	CRED_STRING							 *
* 									 *
* 	RETURN A STRING TO JUST THE NUMBER OF CREDITS IN A8		 *
* 									 *
* 	ENTRY								 *
* 		NOTHING							 *
* 									 *
* 	EXIT								 *
* 		A8	STRING POINTING TO CREDITS			 *
*								         *
**************************************************************************

CRED_STRING:
	MMTM	SP,A0
	CALLR	CRED_P			; GET CREDITS IN A0
	MOVE	A0,A8
	CALLA	HEXTOASC
	MMFM	SP,A0
	RETS

**************************************************************************
*								         *
* 	CHECKFREE							 *
* 									 *
* 	CHECK TO SEE IF THE GAME IS IN FREEPLAY STATE			 *
* 									 *
* 	ENTRY								 *
* 		NOTHING							 *
* 									 *
* 	EXIT								 *
* 		NZ	= FREEPLAY					 *
* 		Z	= NOT IN FREEPLAY				 *
*								         *
**************************************************************************

CHECKFREE:
	.IF	FORCEFREE
	MOVK	1,A0
	JRUC	CFRET
	.ENDIF

        MOVI    ADJFREPL,A0	
        CALLA   GET_ADJ	
CFRET
	MOVE	A0,A0
	RETS
	
**************************************************************************
*								         *
* 	SCOIN								 *
* 									 *
* 	PROCESS CALLED WHEN SERVICE COIN SWITCH TRIGGERED		 *
* 									 *
* 	ENTRY								 *
* 		NOTHING							 *
* 									 *
* 	EXIT								 *
* 		NOTHING							 *
*								         *
**************************************************************************
SCOIN:
	move	@COINS,a14,L
	not	a14
	btst	13,a14
	janz	SUCIDE			;BR = No service with coin door closed

	.IF	PRINTER
	JSRP	PSCOIN
	.ENDIF

	MOVE	@GAME_STATE,A0,W	;DIAGNOSTICS?
	CMPI	INDIAG,A0
	JREQ	CRX			;THEN NO ACTION!

	MOVI	PID_LC,A0		;USE THIS FOR SERVICE
	MOVE	A0,*A13(PROCID),W	;SET OUR ID (IN CASE TABLE IS WRONG)

	CALLR	CK_MAX			;ARE WE AT MAXIMUM CREDITS?
	JRHS	SCOIN_KURT_DAMAGE	;BR = YES, SKIP THIS KURT BONER

	MOVI	AUDPAIDC,A0
	MOVI	-1,A1
	CALLA	AUD			;OFFSET FOR SERVICE, GROSS!!

SCOIN_KURT_DAMAGE
****	MOVI	AUDSCOIN,A11
****	MOVK	1,A8

	AUDIT	AUDSCOIN
	CALLR	FETCH_REQ
	MOVE	A2,A8			;NEED THIS MANY FOR A CREDIT HERE

	JRUC	CGOPROC

**************************************************************************
*								         *
* 	XCOIN								 *
* 									 *
* 	PROCESS CALLED WHEN FOURTH COIN SWITCH TRIGGERED		 *
* 									 *
* 	ENTRY								 *
* 		NOTHING							 *
* 									 *
* 	EXIT								 *
* 		NOTHING							 *
*								         *
**************************************************************************
XCOIN
	MOVI	ADJ4MULT,A8
	MOVI	XC_FLAG,A10		;FOURTH COIN FLAG
	MOVI	AUD4COIN,A11
	JRUC	COIN_ROUTINE

**************************************************************************
*								         *
* 	LCOIN								 *
* 									 *
* 	PROCESS CALLED WHEN LEFT COIN SWITCH TRIGGERED			 *
* 									 *
* 	ENTRY								 *
* 		NOTHING							 *
* 									 *
* 	EXIT								 *
* 		NOTHING							 *
*								         *
**************************************************************************
LCOIN   
	.IF	PRINTER
	JSRP	PLCOIN
	.ENDIF
	MOVI	ADJLMULT,A8
	MOVI	LC_FLAG,A10		;LEFT COIN FLAG
	MOVI	AUDLCOIN,A11
	JRUC	COIN_ROUTINE

**************************************************************************
*								         *
* 	CCOIN								 *
* 									 *
* 	PROCESS CALLED WHEN CENTER COIN SWITCH TRIGGERED		 *
* 									 *
* 	ENTRY								 *
* 		NOTHING							 *
* 									 *
* 	EXIT								 *
* 		NOTHING							 *
*								         *
**************************************************************************
CCOIN
	MOVI	ADJCMULT,A8
	MOVI	CC_FLAG,A10		;CENTER COIN FLAG
	MOVI	AUDCCOIN,A11
	JRUC	COIN_ROUTINE

**************************************************************************
*								         *
* 	RCOIN								 *
* 									 *
* 	PROCESS CALLED WHEN RIGHT COIN SWITCH TRIGGERED			 *
* 									 *
* 	ENTRY								 *
* 		NOTHING							 *
* 									 *
* 	EXIT								 *
* 		NOTHING							 *
*								         *
**************************************************************************
RCOIN   
	.IF	PRINTER
	JSRP	PRCOIN
	.ENDIF
	MOVI	ADJRMULT,A8
	MOVI	RC_FLAG,A10		;RIGHT COIN FLAG
	MOVI	AUDRCOIN,A11

;	FALL THROUGH

**************************************************************************
*                                                                        *
*          COIN_ROUTINE                                                  *
*                                                                        *
*          THIS IS CALLED FROM EACH OF THE COIN SWITCHES WHEN            *
*          MADE.  IT CONTAINS THE FOLLOWING:                             *
*                                                                        *
*                  A8 = MULTIPLIER FOR THAT SWITCH.                      *
*                  A10 = BASE OF RAM POINTERS                            *
*                  A11 = BASE AUDIT NUMBER                               *
*                                                                        *
**************************************************************************
COIN_ROUTINE
	MOVE	@GAME_STATE,A0,W	;DIAGNOSTICS?
	CMPI	INDIAG,A0
	JREQ	CRX			;THEN NO ACTION!

	MOVE	A8,A0			;MOVE MULTIPLIER ADJUST NUMBER TO A0
	CALLA	GET_ADJ			;FETCH IT
	MOVE	A0,A8			;AND BACK TO STATIC REG...ANY THERE?
	JRZ	CRX			;NOPE....DON'T WASTE THE TIME!

	CALLR	SLAM_P			;SLAM AROUND?
	JRNZ	CRX			;THEN NO ACTION

	MOVI	PID_LC,A0		;ALL 3 SLOTS USE THIS ID NOW
	MOVE	A0,*A13(PROCID),W	;SET OUR ID (IN CASE TABLE IS WRONG)

	MOVB	*A10,A0			;GET FLAG BYTE
	JRNZ	CRX			;SOMEONE ELSE THERE...WE'RE A BOUNCE!
*
*	OK....THIS IS A NEW POSITIVE EDGE....START THE TIMING
*	WHEELS   (A0 HAS A ZERO!)
*
	MOVI	PULSE_MAX,A1		;MAXIMUM PULSE WIDTH
	MOVB	A1,*A10(RUN_TIME)	;COUNT IT DOWN HERE.

	MOVI	MIN_OPENS,A1		;THIS MANY FRAMES OF OPEN TIL OPEN
	MOVB	A1,*A10(OPENS_LEFT)

	MOVI	COIN_SFLAG,A1
	MOVB	A1,*A10			;TELL INTERRUPT TO START!

	MOVI	100H,A9			;4 SECONDS MAX
COIN_LOOP
	SLEEP	1			;NOW SLEEP TIGHTLY TILL WE GET SUCCESS OR FAIL
	MOVB	*A10,A0			;GET THE FLAGS
	BTST	COIN_FAIL_BIT,A0	;TOO LONG?
	JRZ	CK_SUCC
*
*	WE HAVE FAILURE...ACKNOWLEDGE IT
*
	ORI	COIN_ACK_VAL,A0		;THIS ACKNOWLEDGES WE SAW IT.
	MOVB	A0,*A10			;PUT IT BACK
	JRUC	CRX			;AND GET OUT

CK_SUCC
	BTST	COIN_SUCC_BIT,A0
	JRNZ	COIN_GO			;GOT IT!...CONTINUE!

	DSJS	A9,COIN_LOOP		;TIME OUT FOR SAFETY


	.IF	DEBUG			;THIS IS A STUPID PLACE TO BE
	JRUC	$
	.ENDIF

	JRUC	CRX			;TIMED OUT....JUST DIE!

COIN_GO
	CLR	A0
	MOVB	A0,*A10			;CLEAR THE FLAGS BACK OUT!

	CALLR	SLAM_P			;SLAM?
	JRNZ	CRX			;THEN WE'RE OUT OF HERE
*
*        WE SURVIVED 1/2 SECOND WITHOUT A SLAM....ITS TIME TO CASH
*        IN HIS STACHE.
*
	CMPI	XC_FLAG,A10
	JREQ	CGO_CLICKL

	CMPI	CC_FLAG,A10
	JREQ	CGO_CLICKL

	CMPI	LC_FLAG,A10
	JRNZ	CGO1

CGO_CLICKL
	CALLR	CLICKLEFT		;CLICK LEFT COIN COUNTER
	JRUC	CGO2
CGO1
	CMPI	RC_FLAG,A10
	JRNZ	CGO2
	CALLR	CLICKRIGHT		;CLICK RIGHT COIN COUNTER
CGO2
	CALLR	CHALK_COIN		;STRIKE UP THE AUDIT(S)
*
CGOPROC
	MOVE	A8,A8			;NO CUNITS?
	JRZ	CRX			;THEN NO MORE WORK TO DO.

	CALLR	ADJUST_CREDITS		;GIVE CREDIT FOR THE MONEY.
;XUNIT	CALLA	DEF_PAGE		;POINT PAGE AWAY!

	MOVE	@GAME_STATE,A0,W	;CHECK FOR ATTRACT MODE
	CMPI	INAMODE,A0
	JRNZ	CRCALL

	MOVE	@SOUNDSUP,A1,W
	SOUNDON
	SOUND1	SND_CHAN0_OFF
	SOUND1	SND_CHAN2_OFF
	SOUND1	SND_CHAN3_OFF
	SOUND1	COINSND	 
	MOVE	A1,@SOUNDSUP,W

	MOVI	PID_IND,A0
	MOVE	A0,*A13(PROCID),W	;MAKE ME KILLABLE
	JRUC	CREDIT_JUMP
CRCALL
	MOVE	@SOUNDSUP,A1,W
	SOUNDON
	SOUND1	COINSND	 
	MOVE	A1,@SOUNDSUP,W

	CALLR	GET_CSTR		;GET CREDIT STRING
	CALLA	G_CRED			;CALL GEORGE
CRX     
	JAUC	SUCIDE

**************************************************************************
*                                                                        *
*          CHALK_COIN                                                    *
*                                                                        *
*          A11 contains the base audit number.  Chalk the audit for      *
*          1 more coin hit there!                                        *
*                                                                        *
*          3 away from the base is the "door-closed" counter             *
*                                                                        *
*          3 away from that is the "sub-total".                          *
*                                                                        *
*          3 away from that is the "door-closed" sub-total.              *
*                                                                        *
*                                                                        *
**************************************************************************
CHALK_COIN: 
	MMTM	SP,A0
	MOVE	A11,A0
	CALLR	CHALK_FOR_A0	;CHALK RELEVANT COUNTERS
	MMFM	SP,A0
	RETS

**************************************************************************
*                                                                        *
*          CHALK_FOR_A0                                                  *
*                                                                        *
*          THIS IS CALLED TO CHALK THE AUDITS FOR A COIN SWITCH.         *
*          A0 HAS THE BASE AUDIT FOR THE COIN SWITCH.                    *
*                                                                        *
**************************************************************************
CHALK_FOR_A0
	MMTM	SP,A0
	CALLA	AUD1		;CHALK THE DIRECT AUDIT
	MMFM	SP,A0
	RETS

**************************************************************************
*								         *
* 	ADJUST_CREDITS							 *
* 									 *
* 	TAKES A VALID COIN SWITCH HIT AND COUNTS IT TOWARDS CREDITS	 *
* 									 *
* 	ENTRY								 *
* 		A8	CHUTE MULTIPLIER				 *
* 									 *
* 	EXIT								 *
* 		NOTHING							 *
*								         *
**************************************************************************

ADJUST_CREDITS
	MMTM    SP,A0,A1,A2,A3,A4,A5,A6,A7,A8,A9,A10,A11
        CALLR   CK_MAX          ;ARE WE AT MAXIMUM CREDITS?
        JRHS    ADCRXX          ;YEP.....DON'T ROCK THE BOAT!
*
        CALLR   CCCC            ;VALIDATE THE CURRENT TOTALS (OR CLEAR!)

        CALLR   FETCH_REQ       ;GET THE REQUIRED FOR CREDIT, BONUS AND MINIMUM
*
*        A2 = REQUIRED FOR CREDIT
*        A3 = FOR BONUS
*        A4 = MINIMUM
*
	CALLA	CMOSUNLOCK
        CALLR   ADD_TO_CUNITS   ;ADD TO OUR CUNITS
        MOVE    A3,A3           ;BONUS EFFECTIVE?
        JRZ     NO_BUNITS       ;NOPE....DON'T RUN UP THE COUNTER!

        CALLR   ADD_TO_BUNITS   ;ADD TO BONUS UNITS

NO_BUNITS
        MOVE    A4,A4           ;MINIMUM REQUIRED?
        JRZ     NO_MINIMUM      ;NOPE.....LEAVE ALONE.

        MOVI    MINUNITS,A7     ;POINT AT MINIMUM
        CALLA   RC_WORD         ;GET THE AMOUNT ACCUMULATED
        ADD     A8,A0           ;ADD AMOUNT RECEIVED
        CALLA   WC_WORD         ;WRITE THE MINUNITS BACK IN CASE NOT ENOUGH.

        SUB     A4,A0           ;DO WE HAVE ENOUGH TO ACT?
        JRLO    ADCRX           ;NOPE....NO CREDITS YET!

        CLR     A0              ;CLEAR OUT MINIMUM FOR NEXT SHOT!
        CALLA   WC_WORD         ;REMOVE ACCUMULATED MINIMUM.

NO_MINIMUM
        CLR     A6              ;COUNT ACCUMULATED CREDITS IN A6
        CLR     A10             ;IN CASE NO BONUS!

        CLR     A8
        MOVI    BUNITS,A7
        CALLA   RC_WORD         ;GET THE NUMBER OF BUNITS
        MOVE    A0,A9           ;INTO A9

        MOVE    A3,A3           ;DON'T DIVIDE BY ZERO!
        JRZ     NO_BU_BU
        DIVU    A3,A8           ;DIVIDE BUNITS BY NUMBER NEEDED FOR BONUS

        MOVE    A9,A0           ;WRITE REMAINDER BACK
        CALLA   WC_WORD

        MOVE    A8,A6           ;NUMBER OF BONUS CREDITS EARNED.
        MOVE    A8,A10          ;REMEMBER IF ANY BONUS CREDITS WERE EARNED!

NO_BU_BU
        CLR     A8
        CALLR   GET_CUNITS      ;READ IN THE CUNITS
        MOVE    A0,A9

        MOVE    A2,A2           ;DON'T DIVIDE BY ZERO.
        JRZ     NO_CR

        DIVU    A2,A8           ;GET CREDITS!
        MOVE    A9,A0           ;REMAINDER IS LEFTOVER CUNITS
        CALLR   PUT_CUNITS
        ADD     A8,A6           ;A6 HAS WHAT WE'VE WON!

NO_CR   MOVE    A6,A1
        MOVI    AUDPAIDC,A0
        CALLA   AUD             ;CHALK UP THE EARNED CREDITS!

        CALLR   GET_CREDITS
        ADD     A6,A0           ;ADD IN THE NEW ONES.
        CALLR   PUT_CREDITS     ;NOW STORE EM BACK (ENFORCE MAX)

        MOVE    A10,A10         ;WAS THE BONUS EARNED?
        JRZ     ADCRX           ;NOPE...EXIT!
*
*        WHEN BONUS EARNED...WE START THE WHOLE SYSTEM OVER!
*
        CALLR   CLEAR_UNITS

ADCRX   
	CALLR   FORM_COIN_CKSUM_AND_STORE
	CALLA	CMOSLOCK
ADCRXX	
	MMFM    SP,A0,A1,A2,A3,A4,A5,A6,A7,A8,A9,A10,A11
	RETS

**************************************************************************
*								         *
* 	PUT_CREDITS							 *
* 									 *
* 	STORE THE CREDIT COUNT IN A0 TO CMOS -- ENFORCE MAX CREDITS	 *
* 									 *
* 	ENTRY								 *
* 		A0	CREDIT COUNT					 *
* 									 *
* 	EXIT								 *
* 		NOTHING							 *
*								         *
**************************************************************************

PUT_CREDITS
	MMTM    SP,A0,A6,A7
        CALLR   GET_MAX         ;GET MAX CREDS IN A1....BE ON COIN PAGE
        CMP     A1,A0           ;SEE HOW WE STACK UP.
        JRLO    USE_A0          ;WE'RE LOWER...JUST STORE.
*
*        WE'RE AT (OR OVER) MAXIMUM CREDITS
*
        CALLR   CLEAR_UNITS     ;CLEAR OUT THE UNIT FRACTIONS.
        MOVE    A1,A0           ;USE MAXIMUM

USE_A0  MOVI    CREDITS,A7
	CALLA	CMOSUNLOCK
        CALLA   WC_BYTE         ;WRITE THE CREDITS OUT.
	CALLA	CMOSLOCK
	MMFM    SP,A0,A6,A7
	RETS

**************************************************************************
*								         *
* 	GET_MAX								 *
* 									 *
* 	GET MAXIMUM CREDITS IN A1 ( LEAVES YOU ON COIN PAGE )		 *
* 									 *
* 	ENTRY								 *
* 		NOTHING							 *
* 									 *
* 	EXIT								 *
* 		A1	MAXIMUM CREDITS					 *
*								         *
**************************************************************************

GET_MAX
	MMTM    SP,A0
        MOVI    ADJMAXC,A0
        CALLA   GET_ADJ    ;FETCH MAXIMUM CREDITS (PUT US ON COIN PAGE)
        MOVE    A0,A1
	MMFM    SP,A0
	RETS

**************************************************************************
*								         *
* 	CK_MAX								 *
* 									 *
* 	CALED TO SEE IF WE ARE AT MAXIMUM CREDITS			 *
* 									 *
* 	ENTRY								 *
* 		NOTHING							 *
* 									 *
* 	EXIT								 *
* 		.HS.	AT MAXIMUM CREDITS				 *
*								         *
**************************************************************************

CK_MAX 	MMTM    SP,A0,A1
        CALLR   GET_MAX              ;GET MAXIMUM IN A1
        CALLR   CRED_P               ;GET CREDITS IN A0 (AND FLIP PAGE AWAY)
        CMP     A1,A0                ;JRHS FOR MAXIMUM CREDITS!
	MMFM    SP,A0,A1
	RETS

**************************************************************************
*								         *
* 	CLEAR_UNITS							 *
* 									 *
* 	CLEAR OUT ANY FRACTIONS OF A UNIT IN CMOS			 *
* 									 *
* 	ENTRY								 *
* 		NOTHING							 *
* 									 *
* 	EXIT								 *
* 		NOTHING							 *
*								         *
**************************************************************************

CLEAR_UNITS
	MMTM    SP,A0,A7
        CLR     A0
        MOVI    CUNITS,A7       ;3 CONSECUTIVE WORDS OF CMOS
        CALLA   WC_WORDI
        CALLA   WC_WORDI
        CALLA   WC_WORD
	MMFM    SP,A0,A7
	RETS

**************************************************************************
*								         *
* 	FETCH_REQ							 *
* 									 *
* 	SNAG THE NUMBER OF UNITS REQUIRED FOR CREDIT, BONUS AND		 *
* 	MINIMUM								 *
* 									 *
* 	ENTRY								 *
* 		NOTHING							 *
* 									 *
* 	EXIT								 *
* 		A2	REQUIRED FOR CREDITS				 *
* 		A3	REQUIRED FOR BONUS				 *
* 		A4	MINIMUM						 *
*								         *
**************************************************************************

FETCH_REQ
	MMTM    SP,A0
        MOVI    ADJCUNIT,A0
        CALLA   GET_ADJ
        MOVE    A0,A2

        MOVI    ADJBUNIT,A0
        CALLA   GET_ADJ
        MOVE    A0,A3

        MOVI    ADJMUNIT,A0
        CALLA   GET_ADJ
        MOVE    A0,A4
	MMFM    SP,A0
	RETS


**************************************************************************
*								         *
* 	CRED_P								 *
* 									 *
* 	RETURN NUMBER OF CREDITS IN A0.  ALSO CLEARS Z BIT IF		 *
* 	CREDITS EXIST OR IN FREE PLAY					 *
* 									 *
* 	ENTRY								 *
* 		NOTHING							 *
* 									 *
* 	EXIT								 *
* 		A0	NUMBER OF CREDITS				 *
* 		.NZ.	CREDITS OR FREEPLAY				 *
*								         *
**************************************************************************

CRED_P:
	CALLR   CCCC			; CHECKSUM COIN CREDITS

GET_CREDITS
        MMTM    SP,A7
;XUNIT  CALLR	COIN_PAG		; COIN PAGE
        MOVI    CREDITS,A7		; WANT NUMBER OF CREDITS
        CALLA   RC_BYTE         ;READ CURRENT CREDITS
;        JRNZ    GC1             ;WE GOT SOME!

;        MOVI    ADJFREPL,A0	
;        CALLA   GET_ADJ         ;SEE IF FREEPLAY......(Z BIT CLEAR IF SO!)

GC1:
;XUNIT	CALLA   DEF_PAGE        ;FLIP CMOS AWAY
	MMFM    SP,A7
	RETS

**************************************************************************
*								         *
* 	ADD_TO_CUNITS							 *
* 									 *
* 	ADD A VALUE TO THE CREDIT UNITS					 *
* 									 *
* 	ENTRY								 *
* 		A8	NUMBER OF CUNITS TO ADD				 *
* 									 *
* 	EXIT								 *
* 		NOTHING							 *
*								         *
**************************************************************************

ADD_TO_CUNITS
        MMTM    SP,A0,A7
        CALLR   GET_CUNITS
        ADD     A8,A0
        CALLR   PUT_CUNITS
	MMFM    SP,A0,A7
	RETS

**************************************************************************
*								         *
* 	GET_CUNITS							 *
* 									 *
* 	GET THE NUMBER OF CREDIT UNITS HANGING AROUND			 *
* 									 *
* 	ENTRY								 *
* 		NOTHING							 *
* 									 *
* 	EXIT								 *
* 		A0	NUMBER OF CUNITS				 *
*								         *
**************************************************************************

GET_CUNITS
        MMTM    SP,A7
        MOVI    CUNITS,A7
        CALLA   RC_WORD
	MMFM    SP,A7
	RETS

**************************************************************************
*								         *
* 	PUT_CUNITS							 *
* 									 *
* 	PUT THE NUMBER OF CREDIT UNITS IN A0 OUT TO CMOS		 *
* 									 *
* 	ENTRY								 *
* 		A0	NUMBER OF CUNITS				 *
* 									 *
* 	EXIT								 *
* 		NOTHING							 *
*								         *
**************************************************************************

PUT_CUNITS
        MMTM    SP,A7
        MOVI    CUNITS,A7
        CALLA   WC_WORD
	MMFM    SP,A7
	RETS

**************************************************************************
*								         *
* 	ADD_TO_BUNITS							 *
* 									 *
* 	ADD A NUMBER OF BONUS UNITS TO THE BONUS COUNTER		 *
* 									 *
* 	ENTRY								 *
* 		A8	NUMBER OF BONUS UNITS TO ADD			 *
* 									 *
* 	EXIT								 *
* 		NOTHING							 *
*								         *
**************************************************************************

ADD_TO_BUNITS
        MMTM    SP,A7,A0
        MOVI    BUNITS,A7
        CALLA   RC_WORD
        ADD     A8,A0
        CALLA   WC_WORD
	MMFM    SP,A7,A0
	RETS

**************************************************************************
*								         *
* 	FORM_COIN_CKSUM							 *
* 									 *
* 	THIS ROUTINE IS CALLED TO FORM THE COINS/CREDITS CHECKSUM.	 *
* 	THE CHECKSUM IS RETURNED IN A1					 *
* 									 *
* 	ENTRY								 *
* 		NOTHING							 *
* 									 *
* 	EXIT								 *
* 		A1	CHECKSUM					 *
* 		.EQ.	MATCHES WHAT'S THERE				 *
* 		.NE.	IT DON'T MATCH, DUDE				 *
*								         *
**************************************************************************

FORM_COIN_CKSUM:
        MMTM    SP,A0,A7,A2
;XUNIT  CALLR   COIN_PAG                 ;MAKE SURE WE'RE ON THE RIGHT PAGE.
        MOVI    COIN_CKSUM_START,A7       ;POINT AT FIRST BYTE TO CHECK
        MOVI    COIN_CKSUM_BYTES,A2
        CLR     A1                        ;CLEAR OUT CHECKSUM

CN_SUM  CALLA   RC_BYTEI                  ;FETCH A BYTE IN A0
        ADD     A0,A1                     ;ADD TO SUM
        DSJS    A2,CN_SUM                 ;TILL WE HAVE EM ALL

        NOT     A1                        ;COMPLEMENT OF COURSE
        ANDI    BYTE_MASK,A1              ;AND KEEP THE BYTE

        MOVI    COIN_CKSUM,A7
        CALLA   RC_BYTE                   ;FETCH THE CURRENT CKSUM
        CMP     A0,A1                     ;COMPARE TO THIS
	MMFM    SP,A0,A7,A2
	RETS

**************************************************************************
*								         *
* 	FORM_COIN_CKSUM_AND_STORE					 *
* 									 *
* 	CHECKSUM THE COINS AND THEN STORE IT OUT 			 *
* 									 *
* 	ENTRY								 *
* 		NOTHING							 *
* 									 *
* 	EXIT								 *
* 		NOTHING							 *
*								         *
**************************************************************************

FORM_COIN_CKSUM_AND_STORE
        MMTM    SP,A1,A7,A0
        CALLR   FORM_COIN_CKSUM
        MOVI    COIN_CKSUM,A7
        MOVE    A1,A0
	CALLA	CMOSUNLOCK
        CALLA   WC_BYTE
	CALLA	CMOSLOCK
	MMFM    SP,A1,A7,A0
	RETS

**************************************************************************
*								         *
* 	CCCC								 *
* 									 *
* 	CHECK COIN AND CLEAR ON BAD CHECKSUM -- BASICALLY JUST 		 *
* 	CHECKS OUT THE COIN CHECKSUMS AND IF THEY ARE WRONG IT		 *
* 	CLEARS THEM OUT							 *
* 									 *
* 	ENTRY								 *
* 		NOTHING							 *
* 									 *
* 	EXIT								 *
* 		NOTHING							 *
*								         *
**************************************************************************

CCCC     
	MMTM    SP,A0,A1,A7,A2
        CALLR   FORM_COIN_CKSUM      ;THIS SETS US TO THE COINAGE PAGE!
        JRZ     CCCCX                ;ALL IS OK!

	calla	CMOSUNLOCK
        MOVI    COIN_CKSUM_START,A7  ;POINT AT FIRST BYTE
        MOVI    COIN_CKSUM_BYTES,A2  ;NUMBER OF BYTES TO CLEAR
        CLR     A0

CCCC_LOOP
        CALLA   WC_BYTEI             ;WRITE A BYTE
        DSJS    A2,CCCC_LOOP         ;UNTIL THEY'RE DONE!

        CALLR   FORM_COIN_CKSUM_AND_STORE  ;NOW MAKE THE CKSUM VALID
	calla	CMOSLOCK

CCCCX   MMFM    SP,A0,A1,A7,A2
	RETS


**************************************************************************
*								         *
* 	NO_CREDS							 *
* 									 *
* 	THIS IS CALLED TO REMOVE CREDITS AND STUFF FROM THE MACHINE	 *
* 									 *
* 	ENTRY								 *
* 		NOTHING							 *
* 									 *
* 	EXIT								 *
* 		NOTHING							 *
*								         *
**************************************************************************

NO_CREDS 
	MMTM    SP,A0,A1,A7
        CALLR   FORM_COIN_CKSUM 
        MOVI    COIN_CKSUM,A7
        MOVE    A1,A0
        INC     A0              ;MAKE THE CKSUM BAD!
	calla	CMOSUNLOCK
	CALLA   WC_BYTE
	calla	CMOSLOCK
	MMFM    SP,A0,A1,A7
	RETS

**************************************************************************
*								         *
* 	CR_BOTH								 *
* 									 *
* 	CHECK TO SEE IF THINGS ARE GOOD FOR A LOT OF STUFF		 *
* 									 *
* 	ENTRY								 *
* 		NOTHING							 *
* 									 *
* 	EXIT								 *
* 		A2	0 = NEITHER					 *
* 			1 = CAN START					 *
* 			2 = CAN CONTINUE				 *
* 			3 = YOU CAN DO ANYTHING YOU WANT		 *
*								         *
**************************************************************************

CR_BOTH:
	MMTM    SP,A0,A1

	.IF	FORCEFREE
	MOVK	3,A2
	JRUC	CR_BX
	.ENDIF

	MOVK	3,A2		; ASSUME FREEPLAY

        MOVI    ADJFREPL,A0
        CALLA   GET_ADJ		; ARE WE IN FREE PLAY?
	MOVE	A0,A0
	JRNZ	CR_BX

	CLR	A2		; ASSUME NOTHING
        CALLR   GET_CREDITS	; GET CURRENT CREDS
	CMPI	1,A0
	JRLO	CR_BX
        MOVE    A0,A1
        MOVI    ADJCSTRT,A0
        CALLA   GET_ADJ		; GET START CREDS
        CMP     A0,A1
	JRLO	CR_B1
	MOVK	1,A2		; YES, ENOUGH TO START
CR_B1
	MOVI	ADJCCONT,A0
	CALLA	GET_ADJ		; GET CONTINUE CREDS
	CMP	A0,A1
	JRLO	CR_BX
	ORI	2,A2		; SET SECOND BIT

CR_BX	MMFM    SP,A0,A1
	RETS

**************************************************************************
*								         *
* 	CR_STRTP							 *
* 									 *
* 	CHECK TO SEE IF THERE ARE ENOUGH CREDITS TO START		 *
* 									 *
* 	ENTRY								 *
* 		NOTHING							 *
* 									 *
* 	EXIT								 *
* 		.HS.	ENOUGH CREDITS TO START				 *
*								         *
**************************************************************************
CR_STRTP: 
	MMTM	SP,A0,A1

	.IF	FORCEFREE
	MOVK	1,A0
	CMPI	0,A0
	JRUC	CR_STX
	.ENDIF

	MOVI	ADJFREPL,A0
	CALLA	GET_ADJ		;ARE WE IN FREE PLAY?
	MOVE	A0,A0
	JRNZ	CR_STX

	CALLR	CCCC		;CHECK IT OUT

	CALLR	GET_CREDITS	;GET CURRENT CREDITS
	CMPI	1,A0
	JRLO	CR_STX
	MOVE	A0,A1
	MOVI	ADJCSTRT,A0
	CALLA	GET_ADJ		;GET NUMBER NEEDED
	CMP	A0,A1		;DO WE HAVE ENOUGH TO START?
CR_STX
	MMFM	SP,A0,A1
	RETS

**************************************************************************
*								         *
* 	CR_CONTP							 *
* 									 *
* 	CHECK TO SEE IF THERE ARE ENOUGH CREDITS TO CONTINUE		 *
* 									 *
* 	ENTRY								 *
* 		NOTHING							 *
* 									 *
* 	EXIT								 *
* 		.HS.	ENOUGH CREDITS TO START				 *
*								         *
**************************************************************************
CR_CONTP
	MMTM	SP,A0,A1

	.IF	FORCEFREE
	MOVK	1,A0
	CMPI	0,A0
	JRUC	CR_CTX
	.ENDIF

	MOVI	ADJFREPL,A0
	CALLA	GET_ADJ		;ARE WE IN FREE PLAY?
	MOVE	A0,A0
	JRNZ	CR_CTX

	CALLR	CCCC		;CHECK IT OUT

	CALLR	GET_CREDITS	;GET CURRENT CREDITS
	MOVE	A0,A1
	CMPI	1,A0
	JRLO	CR_STX
	MOVI	ADJCCONT,A0
	CALLA	GET_ADJ		;GET NUMBER NEEDED
	CMP	A0,A1		;DO WE HAVE ENOUGH TO START?
CR_CTX
	MMFM	SP,A0,A1
	RETS

**************************************************************************
*								         *
* 	P_START								 *
* 									 *
* 	PLAYER STARTED -- DEDUCT REQUISITE NUMBER OF CREDITS		 *
* 									 *
* 	ENTRY								 *
* 		NOTHING							 *
* 									 *
* 	EXIT								 *
* 		NOTHING							 *
*								         *
**************************************************************************
P_START
	MMTM	SP,A0,A1,A8
	CALLR	CRED_P
	MOVE	A0,A1
	MOVI	ADJCSTRT,A0
	CALLA	GET_ADJ			;GET NUMBER NEEDED ( IN A0 )
	ADDRM	A0,@GAMEUNITS,W		;CONTINUING COST OF THE GAME
	CALLR	REMOVE_CREDITS
	CALLA	DEC_HSR			;TAKE 1 FROM HIGH SCORE RESET COUNTER
	CALLR	GET_CSTR		;GET CREDIT STRING
	CALLA	G_CRED			;CALL GEORGE
	MMFM	SP,A0,A1,A8
	RETS

**************************************************************************
*								         *
* 	P_CONT								 *
* 									 *
* 	PLAYER CONTINUED -- DEDUCT REQUISITE NUMBER OF CREDITS		 *
* 									 *
* 	ENTRY								 *
* 		NOTHING							 *
* 									 *
* 	EXIT								 *
* 		NOTHING							 *
*								         *
**************************************************************************

P_CONT  MMTM    SP,A0,A1,A8
        CALLR   CRED_P
        MOVE    A0,A1
        MOVI    ADJCCONT,A0
        CALLA   GET_ADJ              ;GET NUMBER NEEDED
	ADDRM	A0,@GAMEUNITS,W		; CONTINUING COST OF THE GAME
        CALLR   REMOVE_CREDITS
        CALLA   DEC_HSR              ;TAKE 1 FROM HIGH SCORE RESET COUNTER
	CALLR	GET_CSTR		; GET CREDIT STRING
	CALLA	G_CRED			; CALL GEORGE
	MMFM    SP,A0,A1,A8
	RETS

**************************************************************************
*								         *
* 	REMOVE_CREDITS							 *
* 									 *
* 	REMOVE N CREDITS FROM THE MACHINE				 *
* 									 *
* 	ENTRY								 *
* 		A0	NUMBER OF CREDITS TO REMOVE			 *
* 		A1	NUMBER OF CREDITS ON THE MACHINE		 *
* 									 *
* 	EXIT								 *
* 		NOTHING							 *
*								         *
**************************************************************************

REMOVE_CREDITS
        SUB     A0,A1                ;REMOVE START AMOUNT FROM WHAT WE HAVE
        JRHS    PS1                  ;WE'RE OK.
        CLR     A1                   ;IT WENT NEGATIVE....MAKE ZERO.
PS1:
;XUNIT  CALLR   COIN_PAG
        MOVI    CREDITS,A7
        MOVE    A1,A0                ;PUT WHATS LEFT OUT TO WRITE
	calla	CMOSUNLOCK
	CALLA   WC_BYTE              ;WRITE THE NEW AMOUNT
        CALLR   FORM_COIN_CKSUM_AND_STORE
	calla	CMOSLOCK
;XUNIT  CALLA   DEF_PAGE             ;POINT AT DEFAULT PAGE.
        RETS

TIMEINIT
	MOVI	PTAB,A0
TILOOP
	MOVE	*A0+,A1,L
	JRZ	TIDONE
	CLR	A2
	MOVE	A2,*A1(PTOTTIME),L
	JRUC	TILOOP
TIDONE
	RETS
	

**************************************************************************
*								         *
* 	TIMEINT								 *
* 									 *
* 	TIME INTERRUPT -- CALLED ONCE EVERY TIME THROUGH THE EXEC	 *
* 	LOOP..								 *
* 									 *
* 	ENTRY								 *
* 		NOTHING							 *
* 									 *
* 	EXIT								 *
* 		NOTHING							 *
* 									 *
* NOTE: TRASHES A0,A1,A2,A3,A14						 *
*								         *
**************************************************************************
MINRES		EQU	1			;MINIMUM TIME RESOLUTION
ONE_SECOND	EQU	55			;THIS MANY TICKS PER SECOND

TIMEINT:
	MOVE	@LAST_TIMER,A0,W		;DO IT VIA TIMER
	MOVE	@PAUSE_GAME,A14,W
	JRNZ	TI_SKIP_WT
	ADDRM	A0,@WAVETIME,L
****	INCM	@WAVETIME,L			;CLICK THE WAVE TIMER
TI_SKIP_WT
	MOVE	@GAME_STATE,A3,W		;STATE MUST STAY IN A3

	MOVE	@SUBTIMECNT,A14,W
	ADD	A0,A14
****	INC	A14				;CLICK ANOTHER TICK
	MOVE	A14,@SUBTIMECNT,W
	CMPI	MINRES,A14			;IS IT TIME TO PROCESS?
	JRLO	TIMECHECK			;BR = NO, JUST RETURN

	CLR	A14
	MOVE	A14,@SUBTIMECNT,W
;
;	EVERY MINRES TICKS
;
	MOVI	PTAB,A0
TLOOP
	MOVE	*A0+,A1,L
	JRZ	TIME_OCTO_CHECK

*
*DECREMENT CURRENT DISPLAY EFFECT TIME
*
	MOVE	*A1(PDTIME),A2,W
	JRZ	TI_DTIME_OUT
	SUBK	MINRES,A2
	JRGE	TI_DTIME_STORE
	CLR	A2			;MAKE SURE IT IS ZERO	
TI_DTIME_STORE
	MOVE	A2,*A1(PDTIME),W
TI_DTIME_OUT

	MOVE	*A1(POBJ),A2,L
	JRZ	TI_AVGTPCRED		; BR = HE'S DEAD

	CMPI	INPLAY,A3		;ARE WE IN A STATE TO DO THIS?
	JRNE	TLOOP			;BR = NO

*ALL PLAYER POWER-UP TIMERS SHOULD BE DECREMENTED AFTER THIS POINT.

*
*DECREMENT PLAYER INVINCIBILITY TIMER
*
TI_INVINCIBLE_TIMER
	MOVE	*A1(PINVINCIBLE),A2,W	;ARE WE TIMING INVINCIBILITY?
	JRZ	TLOOP			;BR = NO
	SUBK	MINRES,A2
	JRGE	TI_IT_STORE
	CLR	A2
TI_IT_STORE
	MOVE	A2,*A1(PINVINCIBLE),W

	JRUC	TLOOP

*END OF PLAYER POWER-UP TIMER DECREMENTS

TI_AVGTPCRED
	MOVE	*A1(PTOTTIME),A2,L	;HAVE WE ACCOUNTED FOR THE LAST CRED?
	JRZ	TLOOP			;BR = YES, DON'T DO IT AGAIN
*
*INCREMENT AVERAGE TIME PER CREDIT STUFF ONCE THE DUDE IS DEAD
*
	PUSH	A0
	CLR	A0
	MOVE	A0,*A1(PTOTTIME),L	; SO WE DON'T COUNT IT AGAIN
	MOVI	AUDNUMTC,A0
	CALLA	AUD1			; TC DIVISOR ++ 
	MOVI	AUDAVGTC,A0
	MOVE	A2,A1
	CALLA	AUD			; TIME += NTIME
	PULLQ	A0
	JRUC	TLOOP
*
*CHECK FOR ANY OCTOPUS STUFF HERE
*
TIME_OCTO_CHECK:
	CMPI	INAMODE,A3		;OCTOS ONLY ALLOWED IN ATTRACT MODE
	JRNZ	TIMECHECK

	MOVE	@OCTO_FLAG,A0
	JRNZ	TIME_OCTO_PART2		;BR = WORKING ON SECOND PART YET

	MOVE	@SWITCH,A1,L		; GET SWITCH STATE
	NOT	A1
	ANDI	3030H,A1		; BUTTONS ONLY, DUDE
	CMPI	3030H,A1		; ALL TRIGGERS AND BOMBS
	JRNZ	TIME_OCTO_FAIL
	MOVK	1,A0
	MOVE	A0,@SWITCH_SPOKEN,W	;STOP THE "NO WAY JOSE"
	MOVK	1,A0
	MOVE	A0,@OCTO_FLAG,W		;SET THE "WE SAW IT" FLAG
TIME_OCTO_PART2:
	CMPI	2,A0
	JRHS	TIME_OCTO_PART3
	MOVE	@SWITCH,A1,L
	NOT	A1
	MOVE	A1,A2
	ANDI	3030H,A1		;ANY OF THOSE SWITCHES STILL HELD?
	JRNZ	TIME_HSTD_CHECK		;YEP, KEEP WAITING

	MOVE	@COINS,A1
	NEG	A1
	ANDI	0024H,A1		;JUST CHECK THE STARTS
	CMPI	0024H,A1		;BOTH HELD?

	JRNZ	TIME_OCTO_FAIL
	MOVK	1,A0
	MOVE	A0,@SWITCH_SPOKEN,W	;STOP THE "NO WAY JOSE"
	MOVK	2,A0
	MOVE	A0,@OCTO_FLAG,W		;SET THE "WE SAW IT AGAIN" FLAG
TIME_OCTO_PART3
	MOVE	@COINS,A1		; XUNIT
	sll	16,a1			; XUNIT
	move	@SWITCH,a2		; XUNIT
	NOT	A1
	NOT	a2
	ANDI	00240000H,A1		;STILL HOLDING A START BUTTON?
	JRNZ	TIME_HSTD_CHECK		;BR = YES
	ANDI	3030H,A2		;NOW LOOK AT THE GUN
	CMPI	2020H,A2		;ARE JUST THE BOMB BUTTONS HELD?
	JRNZ	TIME_OCTO_FAIL		;BR = NO SIR, YOU FAILED
	CREATE	PID_INDW,OCTO_PAGE	;FIRE OFF THE PUSSY PAGE
TIME_OCTO_FAIL:
	CLR	A0
	MOVE	A0,@OCTO_FLAG,W
;
;	CHECK FOR P1 DOWN, P2 DOWN FOR HSTD PAGE
;
TIME_HSTD_CHECK:
****	MOVE	@SWITCH,A1,L		; GET SWITCH STATE
****	NOT	A1
****	ANDI	1F1FH,A1		; STICKS AND BUTTONS ONLY, DUDE
****	CMPI	0202H,A1		; P1 DOWN, P2 DOWN
****	JRNZ	TIME_CRED_CHECK
****	MOVE	@ON_HSTD,A2,W
****	JRNZ	TIMECHECK
****	ADJUST	ADJHSON			; CHECK TO SEE IF HIGHSCORE EXISTS
****	JREQ	TIMECHECK
****	CREATE	PID_INDW,HSTD_ENTRY_POINT
****	JRUC	TIMECHECK
TIME_CRED_CHECK:
****	CMPI	0408H,A1
****	JRNZ	TIMECHECK
****	MOVE	@ON_CRED,A2,W
****	JRNZ	TIMECHECK
****	CREATE	PID_INDW,CRED_ENTRY_POINT

;
;EVERY TICK
;
TIMECHECK
	MOVE	@DISPATCH_DELAY,A14,W
	JRZ	TC_TICK1
	DEC	A14
	MOVE	A14,@DISPATCH_DELAY,W
	JRNZ	TC_TICK1
	MOVE	A14,@HOLD_ENEMY_DISPATCH,W
TC_TICK1
	MOVE	@TIMECNT,A0,W
	MOVE	@TIMER,A14,W
	ADD	A14,A0
	MOVE	A0,@TIMECNT,W
	CMPI	ONE_SECOND,A0
	JRLO	TIME_REAL_RET
;
;EVERY "SECOND"
;
	CLR	A0
	MOVE	A0,@TIMECNT,W		; RESET TIMER

	MOVI	AUDUPTIME,A0		; TOTAL GAME POWER ON TIME
	CALLA	AUD1

	MOVI	AUDONTIME,A0		; GAME POWER ON TIME
	CALLA	AUD1

	CMPI	INGAME,A3
	JRZ	TIMEGAME
	CMPI	ININTRO,A3
	JRZ	TIMEGAME
	CMPI	INGAMEOV,A3
	JRZ	TIMEGAME
	CMPI	INEPILOG,A3
	JREQ	TIMEGAME
	CMPI	INBONUS,A3
	JREQ	TIMEGAME
	CMPI	INPLAY,A3
	JRNZ	TIME_REAL_RET

TIMEGAME
	MOVI	AUDPTIME,A0		; TOTAL PLAY TIME
	CALLA	AUD1
	CLR	A2			; COUNT OF ACTIVE PLAYERS
	MOVI	PTAB,A0
TLOOP2
	MOVE	*A0+,A1,L
	JRZ	TIMEDONE
	MOVE	*A1(POBJ),A14,L
	JRZ	TLOOP2			; BR = NOT ALIVE
	MOVE	*A1(PTOTTIME),A14,L	; CREDIT TIME
	INC	A14
	MOVE	A14,*A1(PTOTTIME),L
	MOVE	*A1(PLIFETIME),A14,L	; LIFE TIME
	INC	A14
	MOVE	A14,*A1(PLIFETIME),L
	INC	A2
	JRUC	TLOOP2

TIMEDONE
	SLL	4,A2
	ADDI	TIMETAB,A2
	MOVE	*A2,A0,W
	CALLA	AUD1			; ADD FOR RIGHT NUMBER OF PLAYERS

TIME_REAL_RET
TI_XXX
	RETS

TIMETAB	.WORD	0,AUD1TIME, AUD2TIME, AUD3TIME
PTAB	.LONG	P1DATA,P2DATA,P3DATA,0

	
**************************************************************************
*								         *
* 	COININT								 *
* 									 *
* 	INTERRUPT ROUTINE PROCESSING FOR COINS				 *
* 									 *
* 	ENTRY								 *
* 		NOTHING							 *
* 									 *
* 	EXIT								 *
* 		NOTHING							 *
*								         *
**************************************************************************
COININT:
	MOVE	@C_FLAGS,A0,L		;ANY FLAGS SET?
	JRZ	NO_COIN_WORK		;NOPE!

	MOVI	C_FLAGS,A10		;WALK THROUGH THE 3 COUNTERS
	MOVI	4,A9
	MOVI	L_COIN_BIT,A8		;THIS IS THE BIT TO CHECK
*
*I BELIEVE THAT LC_FLAG IS IN THE LOW BYTE...THEN CC_FLAG...THEN RC_FLAG
*
NEXT_SLOT
	MOVE	A0,A1			;GET CURRENT BYTE IN A1
	SRL	8,A0			;SHIFT DOWN TO NEXT
	ANDI	0FFH,A1			;JUST HOLD LEFT SWITCH
	JRZ	TRY_NEXT		;NOT LEFT

	BTST	COIN_FAIL_BIT,A1 	;FAIL LOOKING FOR OPEN?
	JRZ	CHECK_START		;YEP...THAT'S ALL WE NEED DO!
*
*	WE'RE IN A FAIL CONDITION SEE IF WE CAN CANCEL IT!
*
	BTST	COIN_ACK_BIT,A1		;HAS IT BEEN ACKNOWLEDGED?
	JRNZ	FAIL_ACKED		;YEP.....JUST RUN DOWN THE "OPEN" TIMER
*
*	HASN'T BEEN ACKNOWLEDGED.....TIME DOWN AND AUTO ACK IF
*	PROCESS IS DEAD!        THIS SHOULDN'T HAPPEN, BUT
*	DEADLOCKS ARE UGLY!
*
	MOVB	*A10(RUN_TIME),A3	;WE'RE RUNNING OUT OF TIME
	DEC	A3
	MOVB	A3,*A10(RUN_TIME)	;PUT IT BACK!
	JRNZ	TRY_TO_OPEN		;NOW CONTINUE TO OPEN THE SWITCH
*
*	NO ACK IN ALL THIS TIME!
*	PROVIDE THE ACK OURSELVES!
*
	.IF	DEBUG			;THIS IS A FAIL-SAFE...TRAP DURING DEBUG
	JRUC	$
	.ENDIF

	ORI	COIN_ACK_VAL,A1		;ADD IN THE ACK!
	MOVB	A1,*A10			;AND STORE IT BACK!
*
*	WE HAVE ACK...HAVE WE HAD OUR OPEN?
*
FAIL_ACKED
	MOVB	*A10(OPENS_LEFT),A3	;HAVE WE MADE IT?
	JRNZ	TRY_TO_OPEN		;NOT YET...KEEP TRYING.
*
*	WERE OPEN AND HAVE OUR ACK CLEAR OUT THE FLAGS!
*
	MOVB	A3,*A10			;THIS CLEARS OUT THE FLAG
	JRUC	TRY_NEXT		;FLAGS ARE CLEAR...STEP TO NEXT

CHECK_START
	BTST	COIN_SBIT,A1		;"START" FLAG?
	JRNZ	TIME_START		;YEP......KEEP TIMING
*
*	HERE BY PROCESS OF ELIMINATION...ITS "SUCC" BIT OR
*	SOMTHING ELSE GOT SET.....SIMPLY TIME IT DOWN
*	IN CASE SOMEONE TRASHED IN ON THIS BYTE
*
	MOVB	*A10(RUN_TIME),A3	;WE'RE RUNNING OUT OF TIME
	DEC	A3
	MOVB	A3,*A10(RUN_TIME)	;PUT IT BACK!
	JRNZ	TRY_NEXT		;WHEN IT HITS ZERO...WE'LL CLEAR OUT!

	.IF	DEBUG			;THIS IS A FAIL-SAFE...TRAP DURING DEBUG
	JRUC	$
	.ENDIF

	MOVB	A3,*A10			;CLEAR OUT THE FLAGS...PROC IS GONE!
	JRUC	TRY_NEXT		;MUST BE SUCCESS...NO ACTION.

TIME_START
	MOVB	*A10(RUN_TIME),A3	;WE'RE RUNNING OUT OF TIME
	DEC	A3
	MOVB	A3,*A10(RUN_TIME)	;PUT IT BACK!
	JRNZ	TRY_TO_OPEN		;NOW CONTINUE TO OPEN THE SWITCH
*
*	THIS ONE TIMED OUT......ITS FAIL FLAG TIME!
*
	MOVI	COIN_FAIL_VAL,A3
	MOVB	A3,*A10			;WE HAVE FAILURE

	MOVI	ACC_LIMIT,A3
	MOVB	A3,*A10(RUN_TIME)	;THIS IS TIME LIMIT FOR PROCESS TO ANSWER!
*
TRY_TO_OPEN
	CMPI	8,A8
	JRZ	TTOFOURTH		;	ANOTHER KLUDGE FOR XCOIN
	MOVE	@COINS,A2,W		;THE SWITCH HAS 1/2 SECOND TO OPEN
	CMPI	4,A8			;	SPECIAL CHECK FOR CENTER CHUTE
	JRZ	TTOCENTER
	AND     A8,A2			;A1 CONTIAINS ZERO FOR CLOSED
	JRZ	STILL_CLOSED		;ITS CLOSED...RE-START THE OPEN COUNT
	JRUC	TTOGO
TTOCENTER
	ANDI	80H,A2			;MASK FOR JAMMA CENTER
	JRZ	STILL_CLOSED
	JRUC	TTOGO
TTOFOURTH
	MOVE	@SWITCH2,A2,W
	ANDI	20H,A2
	JRZ	STILL_CLOSED
TTOGO
*
*	ITS OPEN
*
	MOVB	*A10(OPENS_LEFT),A3	;HAVE WE MADE IT?
	JRZ	HIT_ZERO		;WE HAVE A LONG ENOUGH OPEN
	DEC	A3
	MOVB	A3,*A10(OPENS_LEFT)	;PUT IT BACK
	JRNZ	TRY_NEXT		;TRY THE NEXT BYTE
*
*	WE HIT ZERO....IF "START FLAG" IS ON THEN WE HAVE SUCCESS
*
HIT_ZERO
	BTST	COIN_SBIT,A1		;"START" FLAG?
	JRZ	TRY_NEXT		;NOPE....

	MOVI	COIN_SUCC_VAL,A3
	MOVB	A3,*A10			;INDICATE WE MADE IT!

	MOVI	ACC_LIMIT,A3
	MOVB	A3,*A10(RUN_TIME)	;THIS IS TIME LIMIT FOR PROCESS TO ANSWER!

	JRUC	TRY_NEXT

STILL_CLOSED
	MOVI	MIN_OPENS,A1		;THIS MANY FRAMES OF OPEN TIL OPEN
	MOVB	A1,*A10(OPENS_LEFT)

TRY_NEXT
	ADDI	8,A10			;NEXT BYTE
	SLL	1,A8			;NEXT COIN BIT

	DSJ	A9,NEXT_SLOT

NO_COIN_WORK
	RETS

**************************************************************************
*									 *
* 	SLAM_P								 *
* 									 *
* 	IS THERE A SLAM PROCESS RUNNING					 *
* 									 *
* 	ENTRY								 *
* 		NOTHING							 *
* 									 *
* 	EXIT								 *
* 		.EQ.	NO						 *
* 		.NE.	YES						 *
*								         *
**************************************************************************
SLAM_P
	MOVI	PID_SLAM,A0
	CALLA	EXISTP_ALL
	RETS

**************************************************************************
*								         *
* 	SLAM								 *
* 									 *
* 	PROCESS THAT STARTS UP WHEN WE GET SLAMMED ON			 *
* 									 *
* 	ENTRY								 *
* 		NOTHING							 *
* 									 *
* 	EXIT								 *
* 		NOTHING							 *
*								         *
**************************************************************************
SLAM	
	MOVI	AUDSLAMS,A0
	CALLA	AUD1
	MOVI	PID_SLAM,A0		;YOU KNOW WHO YOU ARE DAHLINGS
	MOVE	A0,*A13(PROCID),W	;SET OUR ID TO SLAM
	CALLA	KILLPROC_ALL		;KILL ANY OTHER INCARNATIONS
	SLEEP	40H			;1 SECOND OF COIN IGNORING.
	JAUC	SUCIDE

**************************************************************************
*                                                                        *
* 	SOUND(S?)							 *
*                                                                        *
**************************************************************************

COINSND
	.WORD	0F1FDH,41,08815H,0	;COIN SOUND


	.END


