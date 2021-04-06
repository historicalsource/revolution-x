 	.MLIB	"GXMACS.LIB"
	.FILE	"GXSCORE.ASM"
	.TITLE	" <<< GENERATION X -- SCORING ROUTINES >>>"
	.WIDTH	132
	.OPTION	B,D,L,T
	.MNOLIST

**************************************************************************
*								         *
* 	COPYRIGHT (C) 1992 MIDWAY MANUFACTURING COMPANY.		 *
* 		       ALL RIGHTS RESERVED.				 *
*								         *
**************************************************************************

*	GET THE SYSTEM STUFF
	.INCLUDE	"GX.INC"
	.INCLUDE	"GXSTRING.H"
	.INCLUDE	"IMGTBL.GLO"
	.INCLUDE	"GXSCORE.TBL"

	.DEF	UPDSL, OUTLIVES, OUTSCR, SUBLIFE
	
	.DEF	SCORE_GAME_OVER
	.DEF	SCORPROC, LEVEL_UPDATE
	.DEF	SCORE_IF_ACTIVE
	.DEF	G_CRED, G_CREDONLY
	.DEF	MARQUEE
	.DEF	AWARD_EXTRAS
	.DEF	FLASH_PSTATUS, PLAYER_SHIELD

*SYMBOLS IN GX.ASM
	.REF	ALLOW_CONTINUE
*SYMBOLS IN GXPOWER.ASM
	.REF	DO_HEADS_UP
*SYMBOLS IN GXRAM.ASM
	.REF	BTIME
*SYMBOLS IN GXPALL.ASM
	.REF	PALSET
*SYMBOLS IN GXCOIN.ASM
	.REF	CR_BOTH
***** from GXD.ASM
	.REF	OBJ_CONST_MULTI
***** from GXWARREN.ASM
	.REF	C_OCONST

	.BSS	CANSTRT,16
	.bss	filler,16	; to keep long word aligned
****	.BSS	HISEEN,16			; HOW MANY "HI"S IN A ROW
	
STATUS_FLASH_COLOR	.EQU	2929H	;CONSTANT COLOR FOR HIT FLASH
	.EVEN
	.TEXT

**************************************************************************
*								         *
*  SCORPROC - SIMPLE SCORE PROCESS FOR FLASHING PRESS START		 *
* 									 *
*  ENTRY :								 *
* 		A11 	POINTER TO PLAYER DATA AREA			 *
* 									 *
*  RETURNS :								 *
* 		NEVER EXITS						 *
* 									 *
*  NOTE :								 *
* 		A8	MESSAGE PART FLAG				 *
* 		A9	CURRENTLY ACTIVE PALETTE			 *
*								         *
**************************************************************************

SCORPROC:
	CLR	A8			; MESSAGE PART 0
SCORPLP2
	CALLA	CR_BOTH
	MOVE	A2,@CANSTRT,W		; START/CONTINUE FLAG

	MOVE	@NPLAYERS,A11,W		; NUMBER OF PLAYERS
	MOVI	P1DATA,A2		; ALWAYS ASSUME AT LEAST 1 PLAYER
SP_LP
	CALLR	SCORMESS
	ADDI	PDSIZE,A2
	DEC	A11
	JRNN	SP_LP

	SLEEP	40
	NOT	A8			; FLIP MESSAGE
	JRUC	SCORPLP2		; PLOT IT AGAIN, SAM

**************************************************************************
*								         *
* SCORMESS	FIGURE OUT WHAT MESSAGE TO PUT IN THE SCORE BOX		 *
* 									 *
* ENTRY									 *
*  	A2  : POINTER TO CURRENT PLAYER BANK				 *
* 	A8  : 0 IF FIRST PART OF MESSAGE, ~0 IF SECOND PART		 *
*	A9  : COLOR TO USE IN PALETTE                                    *
* 									 *
* RETURN								 *
*  	NOTHING								 *
* 									 *
**************************************************************************

SCORMESS:
	MMTM	SP,A2,A8,A9,A10,A11

SCORMRETRY:
	MOVK	1,A11			; ASSUME IN STORY MODE

	MOVE	@GAME_STATE,A0,W
	CMPI	INAMODE,A0
	JREQ	SCORMAMODE

	CLR	A11			; NOT IN ATTRACT MODE
	MOVE	*A2(PDEAD),A0,W		; CHECK FOR DEAD MESSAGE
	JRNZ	SCORM3

	MOVE	*A2(POBJ),A0,L		; CHECK TO SEE IF HAS OBJECT
	JRNZ	SCORMRET
	MOVE	*A2(PENTER),A0,W	; CHECK FOR ENTERING
	JRNZ	SCORMRET

SCORMAMODE

	MOVE	A8,A8			; CHECK SEQUENCER
	JRNZ	SCORM1			; WORKING ON SECOND MESSAGE

	MOVE	A11,A11			;ARE WE IN ATTRACT MODE?
	JRNZ	SCD_START_CREDITS	;BR = ALWAYS CHECK FOR STARTING CREDS

	MOVE	*A2(PSCORE),A3,L	;PLAYERS FIRST TIME PLAYING?
	JRNZ	SCO1			;BR = NO

SCD_START_CREDITS
	MOVE	@CANSTRT,A0,W		;DOES HE HAVE ENOUGH TO START?
	ANDI	1,A0
	JRZ	SCOPOOR			;BR = NO, TELL HIM HE NEEDS MORE
*THIS IS WHERE WE TO PLAYER SPECIFIC MESSAGES OF APPROPRIATE
SCDNAME
	MOVI	T1PRESS,A8
	JRUC	SCORMGO
SCO1	
	CALLA	ALLOW_CONTINUE
	JRZ	SCORM_GAME_OVER
	MOVE	@CANSTRT,A0,W
	ANDI	2,A0
	JRNZ	SCDNAME			; BR = YES, ENOUGH CONTINUE CREDITS

SCOPOOR
	MOVI	T1INSERT,A8		; INSERT COIN
	JRUC	SCORMGO

SCORM1 
	MOVI	T1TOPLAY,A8		; "TO PLAY"
	JRUC	SCORMGO

SCORM_GAME_OVER
	MOVK	2,A0
	MOVE	A0,*A2(PDEAD),W
SCORM3					; A0 CONTAINS PDEAD HERE
	CMPI	1,A0,W			; CHECK FOR BLANK
	JRZ	SCORMRET		; NOTHING TO PLOT
	CMPI	2,A0,W			; GAME OVER PLOTTED
	JRZ	SCORM4
	CLR	A0
	MOVE	A0,*A2(PDEAD),W		; CLEAR PDEAD CONDITION
	MOVK	1,A10			; FORCE AN ERASE
	JRUC	SCORMRETRY
SCORM4
	JRUC	SCORMRET
;	JRUC	SCORMPAL		; BYPASS FLASHING COLOR
;
;	PLOT THE MESSAGE IN A8 AT THE RIGHT LOCATION
;
SCORMGO 
	MOVI	0E0EH,A1
	SLL	16,A1			; THIS IS THE CONSTANT DRAW COLOR
	MOVE	*A2(PPALID),A0,L	; LOOKUP THE CURRENT PALETTE
	CALLA	FINDPAL			; MAKE SURE IT HAS A PALETTE
	MOVX	A0,A1

SCORMGOOBJ

	MOVE	*A2(PSCRAD),A3,L
	ADDI	SCRCTR,A3		; START OF TEXT
	MOVE	*A8(IANIOFFX),A14,L
	SUB	A14,A3			; ADJUST THE ANIMATION POINT

	MOVE	A8,A14
	MOVI	DMAWAL,A5		; FLAGS
	CALLR	SETUP_DMAN

	CALLA	QDMAN2			; OUTPUT THE SUCKER
SCORMRET
	MMFM	SP,A2,A8,A9,A10,A11
	RETS

PDTAB	.LONG	P1DATA,P2DATA,P3DATA,0


CENSORED_TIME	.EQU	120
**************************************************************************
*								         *
* SCORE_GAME_OVER - PROCESS TO PLACE "GAME OVER" MESSAGE IN THE		 *
* 		  PLAYERS SCORE BOX.					 *
* A11 = PTR TO PLAYER DATA						 *
*								         *
**************************************************************************
SCORE_GAME_OVER
	MOVE	*A11(PDEAD),A0,W	;IS THE PLAYER DEAD?
	JRZ	SGO_DIE			;BR = NOT ANYMORE

	MOVE	@CURPLYRS,A0,W
	JRZ	SGO_NO_HEADS

	MOVE	A11,A2

	MOVI	CENSORED_TAB_3P,A0
	MOVI	CENSORED_TAB_2P,A1
	CALLA	DO_HEADS_UP

SGO_NO_HEADS
	SLEEP	CENSORED_TIME

	CALLA	ALLOW_CONTINUE
	JRZ	SGO_DIE

	CALLA	ALLOW_CONTINUE
	JRZ	SGO_DIE

	MOVE	*A11(PDEAD),A0,W	;IS THE PLAYER DEAD?
	JRZ	SGO_DIE			;BR = NOT ANYMORE
	MOVK	3,A0			; PAUSE DONE, LET SCORPROC SYNC UP
	MOVE	A0,*A11(PDEAD),W

SGO_DIE:
	DIE

*
*"CENSORED" HEADS_UP DISPLAY for a 3-player model
*
CENSORED_TAB_3P
	.WORD	0F5H, CENSORED_TIME
	.LONG	RED_CENSORED_INIT, YEL_CENSORED_INIT, BLUE3_CENSORED_INIT

*
*"CENSORED" HEADS_UP DISPLAY for a 2-player model
*
CENSORED_TAB_2P
	.WORD	0F5H, CENSORED_TIME
	.LONG	RED_CENSORED_INIT, BLUE2_CENSORED_INIT

RED_CENSORED_INIT
	.byte	1, 0, 0, 1	;OBJCNT, PRCCNT, IMGPALCNT, PALCNT
	.long	P_CENSORR	;IMGPAL
	.WORD	OID_P1HUP,0
	LWWWW	CENSORR, DMAWNZ, M_NOSCALE|M_SCRNOBJ, 0 , 0

YEL_CENSORED_INIT
	.byte	1, 0, 0, 1	;OBJCNT, PRCCNT, IMGPALCNT, PALCNT
	.long	P_CENSORY	;IMGPAL
	.WORD	OID_P2HUP,0
	LWWWW	CENSORY, DMAWNZ, M_NOSCALE|M_SCRNOBJ, 0 , 0

BLUE3_CENSORED_INIT
	.byte	1, 0, 0, 1	;OBJCNT, PRCCNT, IMGPALCNT, PALCNT
	.long	P_CENSORB	;IMGPAL
	.WORD	OID_P3HUP,0
	LWWWW	CENSORB, DMAWNZ, M_NOSCALE|M_SCRNOBJ, 0 , 0

BLUE2_CENSORED_INIT
	.byte	1, 0, 0, 1	;OBJCNT, PRCCNT, IMGPALCNT, PALCNT
	.long	P_CENSORB	;IMGPAL
	.WORD	OID_P2HUP,0
	LWWWW	CENSORB, DMAWNZ, M_NOSCALE|M_SCRNOBJ, 0 , 0


**************************************************************************
*                                                                        *
* SCORAREA - OUTPUT THE SCORE AREA AND UPDATE ALL PLAYER STATUS		 *
*                                                                        *
**************************************************************************
SCORAREA
	CALLR	UPSTAT			;UPDATE PLAYERS STATUS
;	CALLR	MARQUEE
	RETS

**************************************************************************
*								         *
* MARQUEE - OUTPUT THE MARQUEE, THIS INCLUDES THE CREDIT/ISLAND MESSAGE	 *
*								         *
**************************************************************************
MARQUEE:
	RETS
	MMTM	SP,A0,A1,A2,A3,A4,A5,A6,A14
	MOVI	MARQTAB,A0
	CLR	A6
	JRUC	SSOUT1

**************************************************************************
*                                                                        *
* G_CRED - OUTPUT "CREDITS: xx" DURING GAMEPLAY				 *
* A8 = PTR CREDITS STRING, READY FOR STRINGER				 *
*                                                                        *
**************************************************************************
*ENTRY TO JUST REFRESH THE CREDIT'S NOT THE BUY-IN TIMER
G_CREDONLY
	MMTM	SP,A0,A1,A2,A3,A4,A5,A6,A7,A8,A9,A10,A11
	JRUC	G_CREDG
*ENTRY CALLED EVERY TIME A COIN IS PUT IN
G_CRED:
	MMTM	SP,A0,A1,A2,A3,A4,A5,A6,A7,A8,A9,A10,A11
	MOVI	PID_BUYIN,A0
	CALLA	EXISTP_ALL
	JRZ	G_CREDG			;THERE IS NO BUY IN AT THIS TIME
	MOVIM	BUYTIME,@BTIME,W	;RESET THE BUY-IN TIME
	MOVE	A0,A4
	MOVI	OID_BTIME,A0
	CALLA	EXISTOBJ_ALL
	JRZ	G_CREDG			;THERE'S NO PHYSICAL TIMER AS OF YET
	MOVE	A4,A0
	MOVI	BUYTICK,A11
	CALLA	PUTA11			;RESET THE TICK TIMER

*ENTRYPOINT JUST TO UPDATE THE CREDITS MESSAGE
G_CREDG
	MOVE	@GAME_STATE,A0,W
	CMPI	INDIAG,A0	
	JREQ	G_CRED_X
	CMPI	INAMODE,A0	
	JREQ	G_CRED_X
	CMPI	ININTRO,A0
	JREQ	G_CRED_X
	CMPI	INEPILOG,A0
	JREQ	G_CRED_X

	MOVE	A8,A14
CREDIT_LP
	MOVB	*A14,A4
	JRZ	G_CRED_X		;BR = ERROR IN CREDIT STRING
	CMPI	20H,A4
	JREQ	CREDIT_FOUND
	ADDK	8,A14
	JRUC	CREDIT_LP
CREDIT_FOUND
	ADDK	8,A14			;RID 'O SPACE
	MOVB	*A14,A4			;ARE THE CREDITS NON-EXISTANT?
	JRZ	G_CRED_X		;BR = YES
	CMPI	20H,A4
	JREQ	CREDIT_FOUND

	MOVI	CRDBOX,A3		;ERASE CURRENT CREDIT MESSAGE	
	MOVI	CRDSIZE,A4
	CLR	A1
	CALLA	FILLAREA2

	MOVI	RD5FONT,A11		;SET DA SHIT UP
	MOVK	1,A10
	MOVI	CRDBOX+CRDTXT,A9
	MOVI	0F0F0101H,A5
	CLR	A0
	CLR	B1
	JSRP	STRCNRM2		;LET IT RIP		   
G_CRED_X:
	MMFM	SP,A0,A1,A2,A3,A4,A5,A6,A7,A8,A9,A10,A11
	RETS


	.IF GERMAN

CREDIT_MESS:
	MESS_MAC RD5FONT,1,0,0,01010000H,STRCNRM2,0
	.STRING	"KRED",0
	.EVEN
FREE_MESS:
	MESS_MAC RD5FONT,1,0,0,0F0F0101H,STRCNRM2,0
	.STRING	"FREI",0
	.EVEN

	.ELSE

CREDIT_MESS:
	MESS_MAC RD5FONT,1,0,0,01010000H,STRCNRM2,0
	.STRING	"CRED",0
	.EVEN
FREE_MESS:
	MESS_MAC RD5FONT,1,0,0,0F0F0101H,STRCNRM2,0
	.STRING	"FREE",0
	.EVEN

	.ENDIF

**************************************************************************
*								         *
* 	SSOUT								 *
* 									 *
* 	Output some Score/Status area pieces via a table.		 *
* 	First entry, is area to blank before plotting.			 *
* 									 *
* 	A0 = Ptr to table						 *
* 	A2 = Player this belongs to. (0 = No player)			 *
* 	A6 = Offset to add to each piece (DAG for BLNKAREA).		 *
* 									 *
* 	Returns:							 *
* 		A0 = Pointing to next word after table			 *
*								         *
**************************************************************************
SSOUT:
	MMTM	SP,A0,A1,A2,A3,A4,A5,A6,A7,A8
SSOUT1:
	MOVE	*A0+,A4,L
	JRZ	SSOUT_BLANK_SKIP
	MOVE	A6,A3
	MOVI	ERASECOL*10000H,A1
	CALLA	FILLAREA2

SSOUT_BLANK_SKIP:
	CLR	A1			;CONSTANT:PALETTE
	MOVI	DMAWNZ,A5		;DRAW
	SLL	16,A5
	MOVE	A2,A2
	JRZ	SSO_NOPLAYER		;BR = No player association

	MOVE	A0,A7

	MOVE	*A2(PPALID),A0,L
	CALLA	FINDPAL
	MOVX	A0,A1			;Correct [Constant,Palette]

	MOVI	[0100H,0100H],A0	;SCALE IS 1:1

	MOVE	*A7+,A8,L
SSO_P_LOOP
	MOVE	*A8(ISIZE),A2,L		;GRAB THE UNSCALED SIZE
	MOVE	*A8(ICTRL),A14,W	;GET BPP AND COMPRESSION
	SLL	16,A14
	OR	A14,A5
	MOVE	*A8(ISAG),A4,L

	CALLA	QDMAN2			;Q THIS SUCKAH!

	MOVE	*A7+,A8,L
	JRNZ	SSO_P_LOOP

	JRUC	SSO_X

SSO_NOPLAYER
	MOVE	*A0+,A7,L		;KICK IT OFF COUSIN
SSOUTL:
	MOVE	*A0+,A3,L
	ADDXY	A6,A3
	CALLA	DTIME2			;DO IT
	MOVE	*A0+,A7,L		;GET THE NEXT
	JRNZ	SSOUTL			;BR = DO IT AGAIN

SSO_X
	MMFM	SP,A0,A1,A2,A3,A4,A5,A6,A7,A8
	RETS

MARQTAB	
	.LONG	0

	.LONG	0

P1SCOREAREA:
	.LONG	PBOXSIZ
	.LONG	BOX1d
	.LONG	[0,0]
	.LONG	0

P2SCOREAREA:
	.LONG	PBOXSIZ
	.LONG	BOX2d
	.LONG	[0,0]
	.LONG	0

P3SCOREAREA:
	.LONG	PBOXSIZ
	.LONG	BOX3d
	.LONG	[0,0]
	.LONG	0


*
*UPDATE ALL PLAYER STATUS AREAS
UPSTAT
	MMTM	SP,A2,A7
	ALLPLYR	UPDSL			;USES A7
	MMFM	SP,A2,A7
	RETS

*
*UPDATE THE PLAYERS SCORE,LIVES & WHATEVER ELSE.
*A2 = PLAYER DATA STRUCTURE
UPDSL
	MMTM	SP,A0,A1
	CALLA	PSENCL			;FIRST RE-INIT THE AREA
	MOVE	*A2(PSCORE),A0,L	;GET THE SCORE IN A0
	CALLR	OUTSCR			;AND OUTPUT IT
	CALLR	OUT_BOMBS

	MOVE	*A2(POBJ),A0,L
	JRZ	UPDSL_X
*DO THE FOLLOWING ONLY WHEN THE PLAYER IS ALIVE
;	CALLR	OUTGUN
;	CALLR	OUTENERGYWORD
	CALLR	OUTLIVES
;	CALLR	OUTGUNWORD
UPDSL_X:
	MMFM	SP,A0,A1
	RETS

**************************************************************************
*                                                                        *
* PSENCL - CREATE THE PLAYER SCORE ENCLOSURE				 *
* A2 = PLAYER DATA							 *
*                                                                        *
**************************************************************************
PSENCL:
	MMTM	SP,A0,A6
	MOVE	*A2(PSCRAD),A6,L

	CMPI	P1DATA,A2
	JRNE	PSENCL_CKP2
	MOVI	P1SCOREAREA,A0
	JRUC	PSENCL_BUILD
PSENCL_CKP2:
	CMPI	P2DATA,A2
	JRNE	PSENCL_CKP3
	MOVI	P2SCOREAREA,A0
	JRUC	PSENCL_BUILD
PSENCL_CKP3:
	CMPI	P3DATA,A2
	JRNE	PSENCL_X
	MOVI	P3SCOREAREA,A0

PSENCL_BUILD:
	CALLR	SSOUT
PSENCL_X:
	MMFM	SP,A0,A6
	RETS

**************************************************************************
*								         *
* BCDADD - ADD TWO BCD VALUES						 *
* A0 = 8 DIGIT BCD VALUE						 *
* A1 = 8 DIGIT BCD VALUE						 *
* RETURNS								 *
* 	A0 = 8 DIGIT BCD RESULT						 *
* NOTE: PACKED BCD FORMAT 4-BITS/ DIGIT					 *
*								         *
**************************************************************************
BCDADD:	
	MMTM	SP,A1,A3,A4,A5,A6
	MOVK	8,A5  		;DO 8 DIGITS
	CLRC			;CLEAR THE CARRY
	MOVK	0Ah,A6
BCDLP:
	MOVK	0Fh,A3
	MOVK	0Fh,A4
	AND	A1,A3		;MASK GARBAGE
	AND	A0,A4
	ADDC	A3,A4
	CMP	A6,A4		;NEED TO ADJUST?
	JRLO	BCDAD1
	ADDK	6,A4
	SRL	4,A0
	SLL	28,A4
	ADD	A4,A0
	SRL	4,A1
	SETC
	DSJS	A5,BCDLP
	JRUC	BCDADX
BCDAD1:	
	SRL	4,A0	
	SLL	28,A4
	ADD	A4,A0
	SRL	4,A1
	CLRC
	DSJS	A5,BCDLP
BCDADX:	
	MMFM	SP,A1,A3,A4,A5,A6	
	RETS

**************************************************************************
*								         *
* SCORE - PLAYER SCORE ROUTINE						 *
* A1 = SCORE VALUE							 *
* A2 = PTR TO PLAYER DATA AREA (0 = NO PLAYER, NO SCORE)		 *
*								         *
**************************************************************************
SCORE:
	PUSH	A0
	MOVE	@GAME_STATE,A0,W
	CMPI	INAMODE,A0
	JREQ	SCOREX			;NO SCORING IN ATTRACT MODE
	CMPI	INGAMEOV,A0		
	JREQ	SCOREX			;NO SCORING IN GAME OVER
	MOVE	A2,A2			;IS THIS A FALSE ALARM?
	JRZ	SCOREX			;BR = YES
	MOVE	*A2(POBJ),A0,L
	JRZ	SCOREX			;NO PLAYER, NO SCORE

	MOVE	*A2(PSCORE),A0,L	;GET SCORE
	ADD	A1,A0			;LET'S GO NORMAL
	CALLR	REPCK			;CHECK REPLAY
	MOVE	A0,*A2(PSCORE),L	;STORE SCORE
	CALLR	OUTSCR			;OUTPUT CURRENT PLAYER SCORE
SCOREX
	PULLQ	A0
	RETS

**************************************************************************
*								         *
* SCORE_IF_ACTIVE - GIVE THE PLAYER THIS SCORE IFF HE IS ACTIVE.	 *
* A1 = BCD SCORE VALUE							 *
* A2 = PTR TO PLAYER DATA						 *
*								         *
**************************************************************************
SCORE_IF_ACTIVE:
	PUSH	A0
	MOVE	*A2(POBJ),A0,L
	JRZ	SCORE_IA_X
	CALLR	SCORE
SCORE_IA_X:
	PULL	A0
	RETS

**************************************************************************
*								         *
* REPCK - CHECK TO SEE IF A PLAYER HAS SCORED A REPLAY AND IF SO	 *
* 	AWARD A NEW DUDE.						 *
* A0 = CURRENT PLAYER SCORE						 *
* A2 = PLAYER DATA AREA							 *
* RETURNS:								 *
* 	NOTHING								 *
* NOTE: DESTROYS A14							 *
*								         *
**************************************************************************
REPCK
	RETS

****	MMTM	SP,A0,A1,A3,A4

****	MOVE	*A2(PEXTRAS),A1,W	
****	JRZ	REPCKX			;BR = LAST ONE EXTINGUISHED

****	MOVE	*A2(PNEXTREP),A1,L
****	JRZ	REPCKX			;0 = NO EXTRA DUDES

****	CLR	A3			;KEEP COUNT OF HOW MANY LIVES WE OWE
****	MOVE	A0,A4			;KEEP THE SCORE HERE BECAUSE OF BCDADD
****REPCKLP:
****	CMP	A1,A4			;HAVE WE EXCEEDED THIS LEVEL?
****	JRLO	REPCK_CASH_OUT		;BR = NO, CASH OUT

****	ADJUST	ADJEXTRA		;GET EXTRA MAN EVERY ADJUSTMENT

****	ADD	A0,A1
****	DECM	*A2(PEXTRAS),W
****	JRNZ	REPCK1
****	CLR	A1			;NO MORE REPLAYS JOE
****REPCK1
****	MOVE	A1,*A2(PNEXTREP),L	;NEW REPLAY LEVEL
****	SOUND1	FREE_SND

****	MOVE	A4,A0			;RESTORE THE SCORE
****	INC	A3			;INCREMENT THE LIFE COUNT
****	MOVE	A1,A1
****	JRNZ	REPCKLP			;CHECK FOR MORE
****REPCK_CASH_OUT:
****	MOVE	A3,A0
****	JRZ	REPCKX			;WE OWE HIM NOTHING
****	CALLR	ADDNLIFE		;PAY THE MAN

****	MOVE	A0,A1
****	MOVI	AUDDEARNED,A0
****	CALLA	AUD			;COUNT IT OUT
****REPCKX:
****	MMFM	SP,A0,A1,A3,A4
****	RETS

****FREE_SND
****	.WORD	0F3E0H,03CH,08012H,0	;"WHOOP TE DOOO"

**************************************************************************
*                                                                        *
* OUTSCRHI - OUTPUT SCORE TO SCREEN, ALWAYS BRIGHT			 *
* A0 = PLAYER SCORE							 *
* A2 = PLAYER DATA AREA							 *
*                                                                        *
**************************************************************************
OUTSCRHI:
	MMTM	SP,A0,A1,A2,A3,A4,A5,A6,A7,A8
	MOVI	0D0D0000H,A1		;BRIGHTEN THE SCENE
	JRUC	OUTSCRG
**************************************************************************
*                                                                        *
* OUTSCRLO - OUTPUT SCORE TO SCREEN, ALWAYS DIM				 *
* A0 = PLAYER SCORE							 *
* A2 = PLAYER DATA AREA							 *
*                                                                        *
**************************************************************************
OUTSCRLO:
	MMTM	SP,A0,A1,A2,A3,A4,A5,A6,A7,A8
	MOVI	05050000H,A1		;DIMMER COLOR
	JRUC	OUTSCRG
**************************************************************************
*                                                                        *
* OUTSCR - OUTPUT SCORE TO SCREEN, BRIGHT OR DIM DEPENDING ON PLAYER	 *
* A0 = PLAYER SCORE							 *
* A2 = PLAYER DATA AREA							 *
*                                                                        *
**************************************************************************
OUTSCR:
	MMTM	SP,A0,A1,A2,A3,A4,A5,A6,A7,A8,A9

	MOVE	@GAME_STATE,A14,W
	CMPI	INAMODE,A14
	JREQ	OUTSCRD
	MOVE	*A2(PENTER),A14,W
	JRNZ	OUTSCRH			;BR = PLAYER WILL ENTER SOON
	MOVE	*A2(POBJ),A14,L
	JRZ	OUTSCRD
OUTSCRH:
	MOVI	0D0D0000H,A1		;BRIGHTEN THE SCENE
	JRUC	OUTSCRG
OUTSCRD:
	MOVI	05050000H,A1		;DIMMER COLOR FOR NON-ACTIVE PLAYER
*	
*OUTSCR - ENTRY POINT WITH FIXED CONSTANT COLOR IN A1
OUTSCRG:
	MOVK	8,A3			;DIGIT COUNT
	CALLR	SCORE_TO_DEC		;CONVERT THE NUMBER

	MOVE	A3,A6
	MOVE	*A2(PSCRAD),A3,L	;PLAYER SCORE AREA ADDRESS
	ADDI	PSCOREOF,A3		

	MOVI	SCRSPC,A8		;SPACING BETWEEN DIGITS	
	CLR	A7			;INIT BLANKING FLAG

	MOVE	A0,A5			;STORE THE SCORE HERE

	MOVE	*A2(PPALID),A4,L
	MOVE	A4,A0
	CALLA	FINDPAL			;MAKE SURE IT HAS A PALETTE
	JRNZ	OUTSC01			;BR = THERE EXISTS A PALETTE
	MOVE	A4,A0
	CALLA	GETFPAL			;MAKE A PALETTE EXIST	
OUTSC01
	MOVX	A0,A1

	MOVE	A5,A9
	MOVI	DMAWNZ,A5		;CONTROL REGISTER

*NOTE:A2 GETS DESTROYED UPON THE FIRST ITERATION OF THIS LOOP
OUTSCL:
	MOVB	*A9,A14			;GET THE FIRST DIGIT
	JRNE	OUTSC1			;NON-ZERO DIGIT
	CMPI	2,A6
	JRLS	OUTSC1			;LAST DIGITS - OUTPUT ANYWAY
	MOVE	A7,A7	   		;BLANKING OVER?
	JREQ	OUTSC2			;NO
OUTSC1:	
	INC	A7			;BLANKING IS OVER

	SLL	7,A14			;MULTIPLY BY 128
	ADDI	SNUM0,A14

	CALLR	SETUP_DMAN
	CALLA	QDMAN2			;OUTPUT THE SUCKER
	SRL	16,A5

OUTSC2:
	ADDXY	A8,A3			;SPACE TO NEXT DIGIT
	ADDK	8,A9			;NEXT IN THE BUFFER
	DSJ	A6,OUTSCL

	MMFM	SP,A0,A1,A2,A3,A4,A5,A6,A7,A8,A9

	RETS

**************************************************************************
*								         *
* OUT_BOMBS - OUTPUT THE NUMBER OF BOMBS CURRENTLY HELD BY		 *
* 		THIS PLAYER.						 *
* A2 = PLAYER DATA AREA							 *
*								         *
**************************************************************************
OUT_BOMBS
	MMTM	SP,A0,A1,A2,A3,A4,A5,A6,A8,A9

	MOVE	*A2(PBOMB2),A0,W		;DOES HE HAVE A SPECIAL BOMB?
	JRNZ	OB_BOMB2			;BR = YES

	MOVE	*A2(PBOMB1),A0,W		;DEFAULT NORMAL COUNT

OB_BOMB2
	CMPI	999,A0				;MAX DISPLAYABLE?
	JRLS	OB_SIZEOK			;BR = NO
	MOVI	999,A0				;DEFAULT ON MAX
OB_SIZEOK
	MOVK	3,A3			;DIGIT COUNT
	CALLR	SCORE_TO_DEC		;CONVERT THE NUMBER
	MOVE	A3,A6
	MOVE	A0,A3			;STORE THE SCORE HERE

	MOVE	*A2(PPALID),A4,L
	MOVE	A4,A0
	CALLA	FINDPAL			;MAKE SURE IT HAS A PALETTE
	JRNZ	OB_01			;BR = THERE EXISTS A PALETTE
	MOVE	A4,A0
	CALLA	GETFPAL			;MAKE A PALETTE EXIST	
OB_01
	MOVX	A0,A1
	MOVE	A3,A9

	MOVE	*A2(PSCRAD),A3,L	;PLAYER SCORE AREA ADDRESS
	ADDI	PBOMBOF,A3		

   	MOVI	SCRSPC,A8		;SPACING BETWEEN DIGITS	
	MOVI	DMAWNZ,A5		;CONTROL REGISTER

*NOTE:A2 GETS DESTROYED UPON THE FIRST ITERATION OF THIS LOOP
OB_LP
	MOVB	*A9,A14			;GET THE FIRST DIGIT

	SLL	7,A14			;MULTIPLY BY 128
	ADDI	CNUM0,A14

	CALLR	SETUP_DMAN
	CALLA	QDMAN2			;OUTPUT THE SUCKER
	SRL	16,A5

	ADDXY	A8,A3			;SPACE TO NEXT DIGIT
	ADDK	8,A9			;NEXT IN THE BUFFER
	DSJ	A6,OB_LP

	MMFM	SP,A0,A1,A2,A3,A4,A5,A6,A8,A9
	RETS

**************************************************************************
*								         *
* SETUP_DMAN - ROUTINE TO CORRECT OFFSET DUE TO MIRRORING FOR MANUAL	 *
* 		DMA'S (I.E. THOSE USING DMAN)				 *
* A14 = PTR TO IMAGE							 *
* A3  = UNFLIPPED DESTINATION						 *
* A5  = FLAGS FOR THIS DMA						 *
* RETURNS								 *
*	A0 = SCALE [0100H,0100H]					 *
* 	A2 = OSIZE							 *
*	A3 = [Y,X] DAG							 *
* 	A4 = SAG							 *
* 	A5 = [CONTROL,OFFSET]						 *
*								         *
**************************************************************************
SETUP_DMAN
	MOVI	[0100H,0100H],A0
	MOVE	*A14(ISIZE),A2,L		;GRAB THE UNSCALED SIZE
	MOVE	*A14(ICTRL),A4,W		;GET BPP AND COMPRESSION
	OR	A4,A5
	SLL	16,A5
	MOVE	*A14(ISAG),A4,L
	RETS

**************************************************************************
*								         *
* SCORE_TO_DEC - FORMAT A HEXADECIMAL # TO A DECIMAL STRING, LEAD ZERO	 *
* 		FILL IS USED.						 *
* A0 = HEXADECIMAL #							 *
* A3 = width, MINIMUM # OF CHARACTERS TO OUTPUT				 *
* RETURNS:								 *
* A0 = PTR TO STRING							 *
*								         *
**************************************************************************
SCORE_TO_DEC
	MMTM	SP,A1,A3,A4,A9

	MOVE	A3,A4
	DEC	A4

	SLL	3,A4
	ADDI	STRNGRAM,A4		;THIS IS OUR STORAGE BUFFER

        MOVK	10,A9			;DIVISOR FOR DECIMAL

	MOVE	A0,A1
SCTODEC2
	CLR	A0
	DIVU	A9,A0
	MOVB	A1,*A4			;SAVE HERE
	SUBK	8,A4
	DEC	A3			;DECREMENT THE WIDTH
	MOVE	A0,A1
	JRNZ	SCTODEC2		;BR = NOT DONE YET

	MOVE	A3,A3
	JRZ	SCTODEC3A		;WIDTH HAS BEEN FULFILLED
	JRN	SCTODEC3A		;THANX TI
	CLR	A1
SCTODEC31:
	MOVB	A1,*A4			;STUFF THE LEADER
	SUBK	8,A4
	DSJS	A3,SCTODEC31
SCTODEC3A:
	MOVI	STRNGRAM,A0		;PASS THE NEW STRING BACK

	MMFM	SP,A1,A3,A4,A9
	RETS

**************************************************************************
*                                                                        *
* 	PLAYER LIFE ROUTINES						 *
*                                                                        *
**************************************************************************

**************************************************************************
*								         *
* AWARD_EXTRAS - AWARD ONE EXTRA MAN TO ALL ACTIVE PLAYERS.		 *
* NOTE: CALL WITH JSRP							 *
*								         *
**************************************************************************
AWARD_EXTRAS
	ALLPLYR	AWEB
	RETP

**************************************************************************
*								         *
* AWEB - AWARD ONE EXTRA MAN TO PLAYER IF ACTIVE AT THE			 *
* 		TIME OF CALLING.					 *
* A2 = PTR TO PLAYER DATA						 *
*								         *
**************************************************************************
AWEB
	PUSH	A0
	MOVE	*A2(POBJ),A0,L
	JRZ	AWEB_X
	CALLR	ADDLIFE
AWEB_X
	PULL	A0
	RETS

**************************************************************************
*                                                                        *
* ADD LIFE								 *
* A0 = # OF LIVES TO ADD						 *
* A2 = PLINDX=PLAYER DATA AREA						 *
*                                                                        *
**************************************************************************
*
*ADD ONE LIFE
ADDLIFE:
	MOVI	[1,0],A0
*
*ADD N LIFE(VES)
ADDNLIFE
	MOVE	*A2(POBJ),A14,L		;IS THIS GUY ALIVE?
	JRZ	AL_XXX			;BR = NO, THEN DON'T ADD LIFE
	MMTM	SP,A0,A1,A3
	MOVE	*A2(PLIVES),A1,L	;CURRENT # OF LIVES
	ADD	A0,A1
	MOVE	A1,*A2(PLIVES),L
***	CALLR	OUTLIVES
	MMFM	SP,A0,A1,A3
AL_XXX
	RETS

**************************************************************************
*								         *
* SUBLIFE - SUBTRACT LIFE ENERGY FROM THE PLAYER.			 *
* A0 = ENERGY TO SUBTRACT [INT,FRAC]					 *
* A2 = PTR PLAYER DATA AREA						 *
* RETURN(S):								 *
* 	 C = ENERGY DEPLETED						 *
*								         *
**************************************************************************
SUBLIFE:
	MMTM	SP,A0,A1,A5

	.if	BILL
;	JRUC	SL_CLRC
	.endif

	.IF NO_DEATH
	JRUC	SL_CLRC
	.ENDIF

	MOVE	@GAME_STATE,A1,W
	CMPI	INAMODE,A1
	JREQ	SL_CLRC

	MOVE	*A2(PINVINCIBLE),A1,W	;IS THIS PLAYER INVINCIBLE?
	JRNZ	SL_CLRC			;BR = YES, NO SUBTRACTING

	MOVE	*A2(PSHIELD),A1,L	;Get current shield value
	JRZ	SUB_NORM		;BR = No shield

	SUB	A0,A1
	JRGT	SUB_STORE_SHIELD	;BR = More shield left
	CLR	A1
	CALLR	PLAYER_SHIELD_DONE
SUB_STORE_SHIELD
	MOVE	A1,*A2(PSHIELD),L	;Clear the shield value
	JRUC	SL_CLRC

SUB_NORM
	MOVE	*A2(PLIVES),A1,L	;GET REMAINING # OF LIVES
	JRLE	SUBLF1			;WE'VE HIT BOTTOM
	MOVE	@BOSS_PUNISH,A14,W
	JRZ	SUB_PROTECT	  	;BR = HAVE MERCY ON THE PLAYER
	SUB	A0,A1			;DO A STRAIGHT SUBTRACT OF LIFE
	JRUC	SUB_OK
SUB_PROTECT
	MOVE	*A2(PSECLIFE),A5,L
	MOVE	*A2(PTOTTIME),A14,W
	MPYU	A14,A5			;ALLOWED TO LOSE THIS MUCH
	SRL	16,A5
	MOVE	*A2(PINITLIFE),A14,W
	SUB	A5,A14			;MIN LEVEL CURRENTLY ALLOWED

*A4 = INTEGER MINIMUM ENERGY
	SLL	16,A14
	SUB	A0,A1
	CMP	A14,A1			;DID WE GO LOWER THAN THE MINIMUM?
	JRGE	SUB_OK			;BR = NO, USE WHAT WE HAVE
	MOVE	A14,A1
*JUMP HERE WHEN YOU HAVE VALUE TO STUFF BACK
*A1 = LIFE VALUE
SUB_OK
	MOVE	A1,*A2(PLIVES),L
	MOVE	A1,A1			;IS THAT IT?
	JRLE	SUBLF1			;BR = YES
SL_CLRC
	CLRC
	JRUC	SUBLFX
SUBLF1:
	SETC
SUBLFX:
	MMFM	SP,A0,A1,A5
	RETS
	
**************************************************************************
*								         *
* 	THE FOLLOWING IS THE BASIC LAYOUT OF THE PLAYERS LIFE AND	 *
* 	GUN STATUS OVERLAY. EACH PART IS A DIFFERENT OBJECT. ALL	 *
* 	OBJECT POINTERS ARE STORED IN PDATA. IF A PTR IS ZERO, THE	 *
* 	OBJECT CURRENTLY DOES NOT EXIST.				 *
* 									 *
* 	�							     �	 *
* 	�							     �	 *
* 	�							     �	 *
* 	�							     �	 *
* 	�							     �	 *
* 	�							     �	 *
* 	�							     �	 *
* 	E							     E	 *
* 	N							     N	 *
* 	E							     E	 *
* 	R							     R	 *
* 	G							     G	 *
* 	Y 							     Y	 *
* 	� GUN:STUN 께께께께께께께께께� 께께께께께께께께께� GUN: KILL �	 *
*								         *
**************************************************************************

**************************************************************************
*								         *
* OUTLIVES - OUTPUT PLAYER ENERGY BAR.					 *
* A2 = PTR TO PLAYER DATA AREA						 *
* RETURNS:								 *
* 	NOTHING								 *
* NOTE: TRASHES A14							 *
*								         *
**************************************************************************
OUTLIVES:
	MMTM	SP,A0,A1,A2,A3,A4,A7,A8
	MOVE	*A2(PLIVES),A1,L	;CURRENT ENERGY LEVEL
	JRUC	OUTLIVES_G
*
*ENTRYPOINT FOR OUTLIVES, BUT PLOT LEVEL PASSED IN A1
*
OUTLIVES_A1
	MMTM	SP,A0,A1,A2,A3,A4,A7,A8
OUTLIVES_G
	MOVE	A1,*A2(PLASTLPLOT),L	;KEEP IT AS OUR LAST PLOT

	MOVE	@GAME_STATE,A14,W
	CMPI	INAMODE,A14
	JREQ	OUTENX			;NO ENERGY OUTPUT DURING ATTRACT MODE

	MOVE	*A2(POBJ),A14,L
	JRZ	OUTEN_DEL		;BR = NO LIFE BAR FOR DEAD GUY

	MOVE	A1,A1
	JRZ	OUTEN_DEL		;BR = NO ENERGY, DELETE THE OBJECT

	CLR	A4
	MOVE	*A2(PEBAROBJ),A8,L	;GET THE ENERGY BAR OBJECT
	JRNZ	OL_OBJEXISTS		;BR = GOOD, THE OBJECT EXISTS
	MOVE	A4,*A2(PECOLOR),W	;CLEAR THE CURRENT BAR COLOR VALUE
	INC	A4
	MOVI	PLIFEBAR_TAB,A3
	CALLR	MAKE_PSTATUS_MULTI	;CREATE THE STATUS OBJECT
	JRZ	OUTENX
	CALLA	OBJ_OFF
	CALLA	INSERT_OBJ
	MOVE	A8,*A2(PEBAROBJ),L
	
OL_OBJEXISTS
	MOVE	*A2(PENRGSIZ),A7,L	;GET # OF LIFE UNITS/ENERGY UNIT
	DIVU	A7,A1			;A11 = LIVES/(LIVES/UNIT) = UNITS

	MOVI	NNRGUNIP,A7
	CMP	A7,A1			;ARE WE WITHIN MAX SIZE?
	JRLE	OL_MAXOK		;BR = YES
	MOVE	A7,A1
	JRUC	OL_PLOT
OL_MAXOK
	CMPI	4,A1			;ARE WE GREATER THAN THE MIN GUN SIZE
	JRGE	OL_PLOT			;BR = YES
	MOVK	4,A1			;THIS SHALL BE THE MIN 
OL_PLOT
	MOVE	A1,A3			;KEEP THE NEW SIZE
	SUB	A1,A7
	ABS	A7			;A7 = LEFT CLIP
	SLL	8,A7
	MOVE	A7,*A8(OFSET),W

	MOVE	A4,A4 			;WAS THE OBJECT OFF?
	JRZ	OUTEN_COLORS		;BR = NO
	CALLA	OBJ_ON

*A3 = CURRENT VERTICAL SIZE OF LIFE BAR
OUTEN_COLORS
	SRL	3,A3			;DIVIDE SIZE BY 8
	SLL	4,A3
	MOVE	A3,A0
	ADDI	ENERGY_COLORS,A0
	MOVE	*A0,A3
	CMPM	*A2(PECOLOR),A3,W	;ARE WE OF THE CORRECT COLOR?
	JREQ	OUTEN_COLORED

	MOVE	A3,*A2(PECOLOR),W	;KEEP THE LATEST COLOR CHANGE

	MOVE	A0,A1
	CALLA	GPLAYNUM
	INC	A0
	SWAP	A0,A1
	SLL	8,A1
	ORI	40,A1
	MOVK	1,A2
	CALLA	PALSET
OUTEN_COLORED

OUTENX
	MMFM	SP,A0,A1,A2,A3,A4,A7,A8
	RETS

*DELETE THE ENERGY BAR
OUTEN_DEL
	CLR	A3
	MOVE	*A2(PEBAROBJ),A8,L	;PLAYER SCORE ADDRESS
	JRZ	OUTEN_COLORS		;BR = ALREADY GONE
	CALLA	DELETE_OBJ
	CLRM	*A2(PEBAROBJ),L
	JRUC	OUTEN_COLORS

*
*PLAYERS LIFE GRADATION BARS
*
PLIFEBAR_TAB
	.LONG	P1LIFEBAR_INIT,P2LIFEBAR_INIT,P3LIFEBAR_INIT

P1LIFEBAR_INIT
	.byte	2, 0, 0, 2	;OBJCNT, PRCCNT, IMGPALCNT, PALCNT
	.long	REDPLAYR, P_REDHIT ;PAL LIST
	.word	OID_P1, OM_COLL
	.LONG	DUMCOLL

	LWWWW   X1LIFEBAR1b, DMAWNZ|M_LRCLIP, M_SCRNOBJ, 0, OM_CFUNC
	LW	C_OCONST, STATUS_FLASH_COLOR
	LWWWW	PLAY_HIT1_R, DMAWNZ, M_SCRNOBJ|M_NOPARTANI|M_NODISP|M_NOSCALE, 0, OM_CFUNC
	LW	C_OCONST, 0101H

P2LIFEBAR_INIT
	.byte	2, 0, 0, 2	;OBJCNT, PRCCNT, IMGPALCNT, PALCNT
	.long	YELPLAYR, P_YELHIT ;PAL LIST
	.word	OID_P2, OM_COLL
	.LONG	DUMCOLL

	LWWWW   X2LIFEBAR1b, DMAWNZ|M_LRCLIP, M_SCRNOBJ, 0, OM_CFUNC
	LW	C_OCONST, STATUS_FLASH_COLOR
	LWWWW	PLAY_HIT1_Y, DMAWNZ, M_SCRNOBJ|M_NOPARTANI|M_NODISP|M_NOSCALE, 0, OM_CFUNC
	LW	C_OCONST, 0101H

P3LIFEBAR_INIT
	.byte	2, 0, 0, 2	;OBJCNT, PRCCNT, IMGPALCNT, PALCNT
	.long	BLUPLAYR, P_BLUHIT ;PAL LIST
	.word	OID_P3, OM_COLL
	.LONG	DUMCOLL

	LWWWW   X3LIFEBAR1b, DMAWNZ|M_LRCLIP, M_SCRNOBJ, 0, OM_CFUNC
	LW	C_OCONST, STATUS_FLASH_COLOR
	LWWWW	PLAY_HIT1_B, DMAWNZ, M_SCRNOBJ|M_NOPARTANI|M_NODISP|M_NOSCALE, 0, OM_CFUNC
	LW	C_OCONST, 0101H


;P1LIFEBAR_INIT
;	.LONG	X1LIFEBAR1b,DUMCOLL
;	.WORD	OID_P1,DMAWNZ|M_LRCLIP,M_SCRNOBJ,0
;	.LONG	0

;P2LIFEBAR_INIT
;	.LONG	X2LIFEBAR1b,DUMCOLL
;	.WORD	OID_P2,DMAWNZ|M_LRCLIP,M_SCRNOBJ,0
;	.LONG	0

;P3LIFEBAR_INIT
;	.LONG	X3LIFEBAR1b,DUMCOLL
;	.WORD	OID_P3,DMAWNZ|M_LRCLIP,M_SCRNOBJ,0
;	.LONG	0


ENERGY_COLORS
	.word	07C00H,07C00H,07D20H,07DC0H,07E00H,07E60H
	.word	07EE0H,07F60H,07FE0H,07FE8H,07FEEH,07FF3H
	.word	07FFFH,07FFFH


**************************************************************************
*								         *
* OUTENERGYWORD - ROUTINE TO OUTPUT ENERGY WORD.			 *
* A2 = PTR TO PLAYER DATA AREA						 *
*								         *
**************************************************************************
OUTENERGYWORD
	rets
	MMTM	SP,A1,A3,A4,A7,A8
;	MOVI	T1ENERENE,A1
	JRUC	OUTED_G
**************************************************************************
*								         *
* OUTDANGERWORD - ROUTINE TO OUTPUT DANGER WORD.			 *
* A2 = PTR TO PLAYER DATA AREA						 *
*								         *
**************************************************************************
OUTDANGERWORD
	rets
	MMTM	SP,A1,A3,A4,A7,A8
;	MOVI	T1ENERDAN,A1

OUTED_G
	CLR	A7
	MOVE	*A2(PEWORDOBJ),A8,L	;GET THE ENERGY BAR OBJECT
	JRNZ	OED_OBJEXISTS		;BR = GOOD, THE OBJECT EXISTS
	INC	A7
	MOVI	PLIFEBAR_TAB,A3
	CALLR	MAKE_PSTATUS_MULTI	;CREATE THE STATUS OBJECT
	JRZ	OED_X
	CALLA	OBJ_OFF
	CALLA	INSERT_OBJ
	MOVE	A8,*A2(PEWORDOBJ),L

OED_OBJEXISTS
	MOVE	*A8(OFLAGS),A4,W
	CALLA	ANI
	MOVE	A7,A7
	JRZ	OED_X
	CALLA	OBJ_ON
OED_X
	MMFM	SP,A1,A3,A4,A7,A8
	RETS

**************************************************************************
*								         *
* LEVEL_UPDATE - PROCESS TO UPDATE PLAYER LIFE AND GUN POWER LEVELS	 *
* 	       AT A LEVEL RATE.						 *
*								         *
**************************************************************************
LEVEL_UPDATE
;	ALLPLYR	START_DW
LU_LP
	ALLPLYR	PLOT_LEVELS
	SLOOP	3,LU_LP
*
*PLOT_LEVELS - SUBROUTINE FOR LEVEL_UPDATE ONLY, TRASHES ANY REGS
*		IT USES.
*A2 = PTR TO PLAYER DATA AREA
*
PLOT_LEVELS
	MOVE	*A2(PLIVES),A0,L
	MOVE	*A2(PLASTLPLOT),A1,L
	CMP	A0,A1				;IS THE LIFE LEVEL CORRECT?
	JREQ	PL_X				;BR = YES
	SUB	A1,A0
	JRLT	PL_DROPPING
*BAR RISING
	CMPI	[1,0],A0			;SMALL JUMP?
	JRLS	PL_PADDL			;BR = YES
	MOVI	[1,0],A0			;MELLOW PLOTAGE
	JRUC	PL_PADDL
*BAR DROPPING
PL_DROPPING
	ABS	A0
	CMPI	[1,0],A0			;SMALL JUMP?
	JRLS	PL_ADDA0L			;BR = YES
	CMPI	[15,0],A0			;BIG JUMP?
	JRHS	PL_ADDA0L			;BR = YES, PLOT IT
	MOVI	[1,0],A0			;MELLOW PLOTAGE
PL_ADDA0L
	NEG	A0
PL_PADDL
	ADD	A0,A1
	CALLR	OUTLIVES_A1
PL_X
	RETS

**************************************************************************
*								         *
* START_DW - ROUTINE TO START THE DANGER WATCH PROCESS FOR A PLAYER.	 *
* A2 = PTR TO PLAYER DATA AREA						 *
*								         *
**************************************************************************
START_DW
	MMTM	SP,A0,A1,A7,A11
	MOVE	A2,A11
	CREATE	PID_IND,DANGER_WATCH
	MMFM	SP,A0,A1,A7,A11
	RETS

*
*NUMBER OF LIFE UNITS LEFT AT WHICH THE PLAYER IS IN DANGER
*
DANGER_LEVEL	.EQU	20
DANGER_MIN_SLEEP .EQU	6
**************************************************************************
*								         *
* DANGER_WATCH - PROCESS TO WATCH A PLAYERS LIFE LEVEL AND SCREAM 	 *
* 		DANGER! IF HE IS LOW ON LIFE.				 *
* A11 = PTR TO PLAYER DATA AREA						 *
*								         *
**************************************************************************
DANGER_WATCH
	MOVE	A11,A2
	CALLA	GPLAYNUM
	SLL	5,A0
	ADDI	DANGER_SOUND_TAB,A0
	MOVE	*A0,A9,L			;GET SOUND CALL TO MAKE

DW_PLAYER_WATCH
	MOVE	*A11(POBJ),A14,L
	JRNZ	DW_NORMAL_LP
	SLOOP	5,DW_PLAYER_WATCH

DW_NORMAL_LP
	MOVE	*A11(PLIVES+16),A10,W		;GET THE CURRENT LIFE AMOUNT
	CMPI	DANGER_LEVEL,A10		;TOO LOW?
	JRLE	DW_IN_DANGER			;BR = YES, HE'S IN DANGER
	SLOOP	1,DW_NORMAL_LP

DW_IN_DANGER
	SLEEP	1
	MOVE	A11,A2
****	MOVI	NRGLOW_TAB,A0
****	CALLA	DO_HEADS_UP			;PUT UP THE MESSAGE
****	CALLR	OUTDANGERWORD			;PLOP THE WORD DANGER
	MOVE	*A11(PEWORDOBJ),A8,L
	JRNZ	DW_DWORD_OK
	SLOOP	1,DW_NORMAL_LP

DW_DWORD_OK
	CALLA	OBJ_ON
	MOVE	*A11(PLIVES),A10,L		;IS THIS PLAYER GONE?
	JRLE	DW_PLAYER_WATCH			;BR = YES, NO MORE
	SRL	16,A10
	CMPI	DANGER_MIN_SLEEP,A10		;MINIMUM SLEEP TIME?
	JRHS	DW_DSLEEP_OK			;BR = NO
	MOVK	DANGER_MIN_SLEEP,A10		;DEFAULT ON MINIMUM
DW_DSLEEP_OK
	CMPI	DANGER_LEVEL,A10		;STILL IN DANGER?
	JRHI	DW_OUT_OF_DANGER		;BR = NO

	MOVE	@GAME_STATE,A14,W
	CMPI	INPLAY,A14
	JRNE	DW_SKIP_SND
	MOVE	A9,A0
;	CALLA	ONESND
DW_SKIP_SND
	SLEEPR	A10
	CALLA	OBJ_OFF
	SLOOPR	A10,DW_DWORD_OK

DW_OUT_OF_DANGER
	MOVE	A11,A2
****	CALLR	OUTENERGYWORD			;PLOP THE WORD ENERGY
	SLOOP	1,DW_NORMAL_LP


DANGER_SOUND_TAB
	.LONG	P1_DANGER_SND, P2_DANGER_SND

P1_DANGER_SND
	.WORD	0F201H,1,08082H,0		;PLAYER ONE DANGER SOUND
P2_DANGER_SND
	.WORD	0F201H,1,08083H,0			;PLAYER TWO DANGER SOUND
	
**************************************************************************
*								         *
* 	MAKE_PSTATUS_MULTI						 *
* 									 *
* 	Make a player status object.  Treats it as a multi-parter	 *
* 									 *
* 	A2 = Ptr to player data area					 *
* 	A3 = Table of status obj init tables				 *
* 									 *
* 	Returns:							 *
* 		 Z = Could not create object (A8 = undefined)		 *
* 		NZ = Successfully created (A8 = Un-inserted object)	 *
*								         *
**************************************************************************
MAKE_PSTATUS_MULTI
	MMTM	SP,A0,A1,A3,A5
	MMTM	SP,B0,B1,B2,B3,B4,B5,B6,B7,B8,B9,B10

	CALLA	GPLAYNUM

	MOVE	@NPLAYERS,A14,W
	DEC	A14
	JRGT	MPM_3PLAY		;BR = This is a three player game
*
* This is a funky hack to make player 2, use player 3's colors when
* we are setup for a two-player max model.  Thanx Jack!
*
	CMPK	1,A0
	JRNE	MPM_3PLAY		;BR = This is not player 2

	INC	A0			;Use player 3's colors

MPM_3PLAY
	SLL	5,A0
	ADD	A3,A0
	MOVE	*A0,A5,L
	MOVE	A5,B0	 		;Get the proper init table
	CALLA	MULTIMAKE
	JRZ	MPM_X			;BR = Object(s) not allocated

	MOVE	*A2(PSTATUSXY),A3,L
	MOVE	A8,A0	
MPM_POS_LOOP
	CALLA	OBJTOPNT
	MOVE	*A0(OPARTS),A0,L
	JRNZ	MPM_POS_LOOP

	MOVI	(PIZPOS+1) << 16,A1
	CALLA	STORE_ZVAL

	MOVE	A8,A8
MPM_X
	MMFM	SP,B0,B1,B2,B3,B4,B5,B6,B7,B8,B9,B10
	MMFM	SP,A0,A1,A3,A5
	RETS

**************************************************************************
*								         *
* FLASH_PSTATUS - FLASH THE PLAYERS STATUS BARS.			 *
* A2 = PTR TO PLAYER							 *
*								         *
**************************************************************************
FLASH_PSTATUS
	MMTM	SP,A1,A8
	MOVE	*A2(PEBAROBJ),A8,L	
	JRZ	FP_EW

	MOVB	*A8(OFLAGS+B_ANIM-7),A14
	JRN	FP_EW				;BR = Already flashing

	MOVI	FS_UNFLASH,A1
	CALLA	STRT_ANIM

	CALLA	OBJ_CONST

	MOVE	*A2(PSHIELD),A14,L
	JRNZ	FP_EW				;BR = No HIT while shielded

	MOVE	*A8(OPARTS),A8,L		;Get the HIT object

	ANDNIM	M_NODISP,*A8(OFLAGS),W

	CALLA	OBJ_CONST

	MOVI	FS_HIT_DISSIPATE,A1
	CALLA	STRT_ANIM

FP_EW
;	MOVE	*A2(PEWORDOBJ),A8,L	
;	JRZ	FP_GB
;	CALLR	FLASH_STAT
;FP_GB
;	MOVE	*A2(PGBAROBJ),A8,L	
;	JRZ	FP_GW
;	CALLA	FLASH_STAT
;FP_GW
;	MOVE	*A2(PGWORDOBJ),A8,L	
;	JRZ	FP_SFLASH
;	CALLA	FLASH_STAT
FP_SFLASH
	MOVE	*A2(PSCOREFLASH),A14,W	;ARE WE FLASHING THE SCORE AREA?
	JRNZ	FP_X			;BR = YES, DO NOT FLASH AGAIN
	MOVE	*A2(PDEAD),A14,W	;IS HE MARKED AS DEAD?
	JRNZ	FP_X			;BR = YES, DO NOT FLASH

	MMTM	SP,A0,A2,A3,A4,A5,A7,A11

	MOVI	STATUS_FLASH_COLOR,A1	;MAKE SCORE AREA THIS COLOR
	SLL	16,A1			; THIS IS THE CONSTANT DRAW COLOR
	MOVE	*A2(PPALID),A0,L	; LOOKUP THE CURRENT PALETTE
	CALLA	FINDPAL			; MAKE SURE IT HAS A PALETTE
	MOVX	A0,A1

	MOVE	A1,A7
	MOVE	*A2(PSCRAD),A3,L	;GET THE SCORE ADDRESS
	MOVI	BOX1d,A1		;THIS IS OUR REFERENCE IMAGE
	MOVI	DMACNZ,A5		;WRITE CONSTANT COLOR ALWAYS
	MOVE	A2,A11			;KEEP PLAYER PTR HERE

	MOVE	A1,A14
	CALLR	SETUP_DMAN
	MOVE	*A1(IANIOFFX),A14,L
	MOVE	A7,A1	
	ADDI	SCRCTR,A3		; START OF TEXT
	SUB	A14,A3			; ADJUST THE ANIMATION POINT
	CALLA	QDMAN2			; OUTPUT THE SUCKER

	MOVKM	1,*A11(PSCOREFLASH),W
	CREATE	PID_INDE,SCORE_REPLOT

	MMFM	SP,A0,A2,A3,A4,A5,A7,A11

FP_X
	MMFM	SP,A1,A8
	RETS
	
**************************************************************************
*								         *
* 	PLAYER_SHIELD							 *
* 									 *
* 	Bring up the player shield message, in place of HIT.		 *
* 									 *
* 	A2 = Ptr to player						 *
*								         *
**************************************************************************
PLAYER_SHIELD
	MMTM	SP,A1,A8
	MOVE	*A2(PEBAROBJ),A8,L	
	JRZ	PS_X

	MOVE	*A8(OPARTS),A8,L		;Get the shield object

	MOVI	FS_SHIELD_START,A1
	CALLA	STRT_ANIM
PS_X
	MMFM	SP,A1,A8
	RETS

**************************************************************************
*								         *
* 	PLAYER_SHIELD_DONE						 *
* 									 *
* 	Turn off shield message and put back the HIT.			 *
* 									 *
* 	A2 = Ptr to player						 *
*								         *
**************************************************************************
PLAYER_SHIELD_DONE
	MMTM	SP,A1,A8
	MOVE	*A2(PEBAROBJ),A8,L	
	JRZ	PSD_X

	MOVE	*A8(OPARTS),A8,L		;Get the shield object

	MOVI	FS_HIT_START,A1
	CALLA	STRT_ANIM
PSD_X
	MMFM	SP,A1,A8
	RETS

**************************************************************************
*								         *
* SCORE_REPLOT - PROCESS TO REPLOT THE PLAYERS SCORE AREA AFTER		 *
* 		4 TICKS.						 *
* A11 = PTR TO PLAYER DATA						 *
*								         *
**************************************************************************
SCORE_REPLOT
	SLEEP	4
	MOVE	A11,A2
	CALLR	UPDSL
	CLRM	*A2(PSCOREFLASH),W
	DIE
	
**************************************************************************
*								         *
* FLASH_STAT - FLASH A STATUS OBJECT TO ITS CONSTANT COLOR. IF THE	 *
* 		STATUS OBJECT IS ALREADY ANIMATING THEN BAIL.		 *
* A1 = OCONST								 *
*								         *
**************************************************************************
FLASH_STAT:
	PUSH	A1
	movb	*A8(OFLAGS+B_ANIM-7),A14	;already animating??
	jrn	FS_X				;YES
FlashIt
	movi	FS_UNFLASH,A1
	calla	STRT_ANIM
	move	*A8(OCTRL),A14,W
	andni	M_WRNONZ|M_WRZERO,A14		;NO NORMAL WRITING
	ori	M_CONNON,A14			;REPLACE ALL DATA
	move	A14,*A8(OCTRL),W
FS_X
	PULLQ	A1
	rets

*
* FLASH ANIM SCRIPT
*
FS_UNFLASH
	LW	1,4
	LWL	1,1|AFunc,A_FS_UNFLASH_PULL

*
* HIT marker dissipates
*
FS_HIT_DISSIPATE
	LW	1,2
	LWL	1,2|AFunc,A_FS_UNFLASH
	LWL	1,1|AFunc,OBJ_OFF
	LWL	1,1|AFunc,PULL_ANIM

*
* "SHIELD UP" in place of hit
*
FS_SHIELD_START
	LWL	SHLDUP_R,1|AFunc,OBJ_ON
	LWL	1,1|AFunc,A_FS_UNFLASH_PULL

*
* "HIT" marker resume
*
FS_HIT_START
	LWL	PLAY_HIT1_R,1|AFunc,OBJ_OFF
	LWL	1,1|AFunc,A_FS_UNFLASH_PULL

**************************************************************************
*								         *
* A_FS_UNFLASH - ANIM FUNC TO UNFLASH A STATUS OBJECT.			 *
*								         *
**************************************************************************
A_FS_UNFLASH_PULL:
	calla	PULL_ANIM
A_FS_UNFLASH
	move	*A8(OCTRL),A1,W
	ori	M_WRNONZ,A1		;Do Write Non-Zero Data
	andni	M_CONNON|M_CONZER,A1	;Don't Replace ALL
	move	A1,*A8(OCTRL),W

	rets

**************************************************************************
*								         *
* PRINT_SCORE - ROUTINE TO PLASTER A SCORE ON A GIVEN OBJECT.		 *
*								         *
* A1 = SCORE TO GIVE							 *
* A2 = PTR TO PLAYER RECIEVING						 *
* A8 = OBJECT TO PLASTER IT UPON					 *
* A9 = SCREEN OFFSET FROM CENTER OF OBJECT IN [Y,X] FORMAT		 *
*								         *
**************************************************************************
PRINT_SCORE:
	MOVE	A2,A2
	JRZ	PS_XXX
	MMTM	SP,A0,A1,A7,A8,A9,A10,A11
	MOVE	A1,A10
	SRL	1,A1			;SHIFT OUT FLAG
	SLL	1,A1
	CALLR	SCORE			;AND GIVE SCORE
	MOVE	A2,A11			;ALL IN PROPER PROCESS REGS
	CREATE	PID_INDE,SCOREOBJ
	MMFM	SP,A0,A1,A7,A8,A9,A10,A11
PS_XXX
	RETS

**************************************************************************
*								         *
* SCOREOBJ - PROCESS TO CREATE A SCORE OBJECT THEN TAKE IT AWAY.	 *
*								         *
* A8 = OBJECT TO PLASTER IT UPON					 *
* A9 = SCREEN OFFSET FROM CENTER OF OBJECT IN [Y,X] FORMAT		 *
* A10 = SCORE TO AWARD (BIT 0 FLAGS UPWARD MOTION ON IMAGE)		 *
* A11 = PTR TO PLAYER DATA						 *
*								         *
**************************************************************************
SCOREOBJ:
	MOVI	SCORETAB,A3
	JRUC	SCOBJ_EXE
*
*SCORE2XOBJ - SAME AS SCOREOBJ EXCEPT USES A DIFFERENT LOOK-UP TABLE
SCORE2XOBJ:
	MOVI	SCORETAB2X,A3
	JRUC	SCOBJ_EXE

SCOBJ_EXE
	MOVE	A10,A14			;KEEP THE SCORE HERE
	SRA	1,A14			;SHIFT OUT FLAG
	SLL	1,A14
SO_SCLP:
	MOVE	*A3+,A4,L
	JRZ	SO_DIE			;THE SCORE IMAGE CANNOT BE FOUND
	CMP	A4,A14			
	JREQ	SO_SFOUND		;BR = FOUND A SCORE
	ADDK	32,A1	
	JRUC	SO_SCLP			;SEARCH AGAIN

SO_SFOUND:
	MOVI	SCRIMGINIT,A5
	CALLA	CREATE_OBJ
	JRZ	SO_DIE			;BR=OOPS!

;	MOVE	*A8(OID),A14,W
;	ANDI	MASK_TYPE,A14
;	CMPI	TYPE_ENEMY & MASK_TYPE,A14
;	JRNE	SO_NOENEMY		;BR=NOT AN ENEMY

	BTST	0,A10
	JRZ	SO_NOMO			;BR=DON'T MOVE

	MOVI	-010000H,A14
	MOVE	A14,*A0(OYVEL),L	;MOVIN' ON UP				
;SO_NOENEMY
SO_NOMO
	MOVE	*A8(OZVAL),A7,L
	DEC	A7			;PLACE SCORE IN FRONT OF OBJECT
	MOVE	A7,*A0(OZVAL),L

	MOVE	*A8(OCTRL),A4,W

	CALLA	GET_CPNTU		;GET UNIV POSITIONS: X IN A2, Y IN A1
	MOVE	A9,A14			;CONVERT SCRN X OFFSET TO WORLD
	SEXT	A14,W
	BTST	B_FLIPH,A4
	JRZ	SO_NOFLIPH		;BR=NO H-FLIP
	NEG	A14
SO_NOFLIPH	
	SLL	15,A14
	ADD	A14,A2			;ADD X OFFSET
	MOVE	A2,*A0(OXVAL),L
	SRA	16,A9			;CONVERT SCRN Y OFFSET TO WORLD
	BTST	B_FLIPV,A4
	JRZ	SO_NOFLIPV		;BR=NO V-FLIP
	NEG	A9
SO_NOFLIPV	
	SLL	15,A9
	ADD	A9,A1			;ADD Y OFFSET
	MOVE	A1,*A0(OYVAL),L

	MOVE	*A3,A1,L		;GET THE IMAGE

	MOVE	A0,A8
	MOVE	*A11(PPALID),A0,L
	CALLA	CHANGE_PAL		;CHANGE TO THE CORRECT PALETTE

	MOVE	*A8(OCTRL),A4,W

	CALLA	ANI			;CHANGE THE SCORE IMAGE

;THIS CODE IS DIABLED
;
;	MOVE	*A8(OUSIZE),A0,L
;	MOVE	*A8(OUANIOFF),A1,L
;
;	CMPI	0E0H << Z2SCALE,A7
;	JRHI	SO_NOT2X		;BR = NOT DOUBLE SCALE
;;THE FOLLOWING WILL NOT WORK IF WE HAVE NEGATIVE ANIMATION POINTS
;	SLL	1,A0			;MULTIPLY BY 2
;	SLL	1,A1
;	MOVI	080H,A2
;	JRUC	SO_SCALEOK
;SO_NOT2X
;	CMPI	0200H << Z2SCALE,A7
;	JRLO	SO_SCALE1TO1		;BR = NOT HALF SCALE
;	MOVE	A0,A3			;DIVIDE BY 2
;	SRL	1,A3
;	ZEXT	A0,W
;	SRL	1,A0
;	MOVY	A3,A0
;	MOVE	A1,A3
;	SRL	1,A3
;	ZEXT	A1,W
;	SRL	1,A1
;	MOVY	A3,A1
;	MOVI	0200H,A2
;SO_SCALEOK
;	MOVE	A0,*A8(OSIZE),L
;	MOVE	A1,*A8(OANIOFF),L
;	MOVE	A2,*A8(OSCALEX),W
;	MOVE	A2,*A8(OSCALEY),W
;SO_SCALE1TO1
	CALLA	INSERT_OBJ	
	SLEEP	60			;PAUSE THE SCORE FOR A SECOND
	CALLA	DELETE_OBJ		;RID O' THE OBJECT
SO_DIE:
	DIE

*
*GENERIC SCORE IMAGE INIT TABLE
SCRIMGINIT:
	.LONG	SCR1000,DUMCOLL
	.WORD	OID_JUNK,DMAWNZ,M_NOSCALE|M_NOPIXSCAN,0
	.LONG	0

*
*TABLE OF BCD SCORES AND THEIR ASSOCIATED IMAGES
*	.LONG	SCORE, PTR TO IMAGE
*	.LONG	0
SCORETAB
SCORETAB2X
	.LONG	500,SCR500
	.LONG	1000,SCR1000,2000,SCR2000,3000,SCR3000,4000,SCR4000
	.LONG	5000,SCR5000,6000,SCR6000,7000,SCR7000,8000,SCR8000
	.LONG	9000,SCR9000,10000,SCR10000,15000,SCR15000
	.LONG	20000,SCR20000,25000,SCR25000,40000,SCR40000
	.LONG	80000,SCR80000,0


	.IF 	0	;This is the scrap heap

**************************************************************************
*								         *
* OUTGUN - OUTPUT PLAYER GUN ENERGY BAR.				 *
* A2 = PTR TO PLAYER DATA AREA						 *
* RETURNS:								 *
* 	NOTHING								 *
* NOTE: TRASHES A14							 *
*								         *
**************************************************************************
OUTGUN
	rets
	MMTM	SP,A1,A2,A3,A4,A5,A7,A8
	MOVE	*A2(PGUNPOWER),A1,W		;CURRENT GUN ENERGY LEVEL
	JRUC	OUTGUN_G
*
*ENTRYPOINT FOR OUTGUN, BUT PLOT LEVEL PASSED IN A1
*
OUTGUN_A1
	MMTM	SP,A1,A2,A3,A4,A5,A7,A8
OUTGUN_G
	MOVE	A1,*A2(PLASTGPLOT),W		;KEEP IT AS OUR LAST PLOT

	MOVE	@GAME_STATE,A3,W
	CMPI	INAMODE,A3
	JREQ	OUTGUNX				;NO ENERGY OUTPUT DURING AMODE

	MOVE	*A2(POBJ),A8,L
	JRZ	OUTGUN_DEL			;BR = NO GUN BAR FOR DEAD GUY

	MOVE	A1,A1
	JRZ	OUTGUN_DEL			;BR = NO GUN, DELETE THE OBJECT

	CLR	A4
	MOVE	*A2(PGBAROBJ),A8,L		;GET THE GUN BAR OBJECT
	JRNZ	OG_OBJEXISTS			;BR = GOOD, THE OBJECT EXISTS
	INC	A4
	MOVI	PGUNBAR_TAB,A3
	CALLA	MAKE_PSTATUS		;CREATE THE STATUS OBJECT
	JRZ	OUTGUNX
	CALLA	OBJ_OFF
	CALLA	INSERT_OBJ
	MOVE	A8,*A2(PGBAROBJ),L
OG_OBJEXISTS

	MOVE	*A2(PGUNMULT),A7,L	;GET GUN MULTIPLIER
	MPYU	A7,A1			;MAKE OUR SIZE
	SRL	16,A1			;THIS IS THE HORIZONTAL SIZE WE NEED
	JREQ	OUTGUN_DEL		;BR = OOPS WENT TO ZERO
	CMPI	GUNENERGY,A1		;ARE WE BIGGER THAN THE MAX
	JRLS	OG_SOK
      	MOVI	GUNENERGY,A1		;DEFAULT ON MAX
OG_SOK
	MOVE	*A8(OSIZEX),A3,W
	SUB	A1,A3

	CMPI	P1DATA,A2
	JRNE	OG_P2

     	MOVE	A3,A2
	CLR	A3
	JRUC	OG_OBJCLIP
OG_P2
	CLR	A2
OG_OBJCLIP
	CALLR	CLIP_GUNBAR

	MOVE	A4,A4 			;WAS THE OBJECT OFF?
	JRZ	OUTGUNX			;BR = NO
	CALLA	OBJ_ON

OUTGUNX
	MMFM	SP,A1,A2,A3,A4,A5,A7,A8
	RETS

*DELETE THE GUN BAR
OUTGUN_DEL
	MOVE	*A2(PGBAROBJ),A8,L	;GET GUN BAR OBJECT
	JRZ	OUTGUNX			;BR = ALREADY GONE
	CALLA	DELETE_OBJ
	CLRM	*A2(PGBAROBJ),L
	JRUC	OUTGUNX

*
*PLAYERS GUN GRADATION BARS
*
PGUNBAR_TAB
	.LONG	P1GUNBAR_INIT,P2GUNBAR_INIT

P1GUNBAR_INIT
	.LONG	T1GUNBAR,DUMCOLL
	.WORD	OID_JUNK,DMAWNZ|M_SCRNOBJ,0
	.LONG	0

P2GUNBAR_INIT
	.LONG	T2GUNBAR,DUMCOLL
	.WORD	OID_JUNK,DMAWNZ|M_SCRNOBJ,0
	.LONG	0

**************************************************************************
*								         *
* CLIP_GUNBAR - ROUTINE TO CLIP GUN BAR OBJECT				 *
* A2 = RIGHT CLIP (RELATIVE TO CURRENT SIZE)				 *
* A3 = LEFT CLIP (RELATIVE TO CURRENT SIZE)				 *
* A8 = OBJECT BLOCK							 *
* RETURNS								 *
* 	NOTHINE								 *
*								         *
**************************************************************************
CLIP_GUNBAR
	MMTM	SP,A0,A2,A3,A4,A9,A11,A12
	MOVE	A8,A0
	MOVE	*A8(OXPOS),A4,W
	ADDI	OFLAGS,A0  	;GET INDEX INTO OBJECT STRUCTURE

*	A9= VS:HS
*	A11= SAG
*	A12= OFFSET:FLAGS
	MMFM	A0,A9,A11,A12

*
*CLIP THE SAG, HS, AND ADJUST OFFSET
*	
	MOVE	@NO_MIRROR,A14,W
	JRZ	CGB_MIRROR

	ADD	A3,A2		;RC+LC
	MOVE	A9,A14
	SUB	A2,A14
	SEXT	A14		;DID WE GO TOO FART?
	JRGT	CGB_NM_SOK
	MOVK	1,A14		;MIN SIZE
CGB_NM_SOK
***	SUB	A2,A9		;DECREASE OBJECT SIZE ACCORDINGLY
	MOVX	A14,A9
	ADD	A3,A4		;ADD LEFT CLIP TO X POSITION

	BTST	B_FLIPH,A12			;TEST WHILE NOT MIRRORED
	JREQ	CGB_NOFLIP
	JRUC	CGB_FLIPPED

CGB_MIRROR
	SWAP	A2,A3		;SWAP LEFT AND RIGHT CLIP FOR MIRROR
	ADD	A2,A4		;ADD LEFT CLIP TO X POSITION
	ADD	A3,A2		;RC+LC

	MOVE	A9,A14
	SUB	A2,A14
	SEXT	A14		;DID WE GO TOO FART?
	JRGT	CGB_M_SOK
	MOVK	1,A14		;MIN SIZE
CGB_M_SOK
***	SUB	A2,A9		;DECREASE OBJECT SIZE ACCORDINGLY
	MOVX	A14,A9

	BTST	B_FLIPH,A12			;TEST WHILE MIRRORING
	JRNE	CGB_NOFLIP
CGB_FLIPPED
	NEG	A2		;NEGATE RC+LC
	NEG	A3		;NEGATE LC
CGB_NOFLIP
	SLL	3,A3
	ADD	A3,A11		;ADD TO SAG
	SLL	16,A2
	ADDXY	A2,A12		;CHANGE THE OFFSET

	PUSHST
	DINT
	MMTM	A0,A9,A11,A12
	MOVE	A4,*A8(OXPOS),W
	POPST

	MMFM	SP,A0,A2,A3,A4,A9,A11,A12
	RETS

**************************************************************************
*								         *
* OUTGUNWORD - ROUTINE TO OUTPUT THE GUN WORD OBJECT.			 *
* A2 = PTR TO PLAYER DATA AREA						 *
*								         *
**************************************************************************
OUTGUNWORD
	rets

	MMTM	SP,A3,A8
	MOVE	*A2(PGWORDOBJ),A8,L	;GET THE CURRENT GUN WORD OBJECT
	JRNZ	OGW_X			;BR = GOOD, THE OBJECT EXISTS
	MOVI	PGUNWORD_TAB,A3
	CALLA	MAKE_PSTATUS		;CREATE THE STATUS OBJECT
	JRZ	OGW_X
	CALLA	INSERT_OBJ
	MOVE	A8,*A2(PGWORDOBJ),L
OGW_X
	MMFM	SP,A3,A8
	RETS


*
*TABLE OF PLAYER GUN WORD INIT TABLES
*
PGUNWORD_TAB
	.LONG	P1GUNWORD_INIT,P2GUNWORD_INIT

*
*PLAYER GUN WORD INIT TABLES
*
P1GUNWORD_INIT
	.LONG	T1GUNGUN,DUMCOLL
	.WORD	OID_JUNK,DMAWNZ|M_SCRNOBJ,0
	.LONG	0

P2GUNWORD_INIT
	.LONG	T2GUNGUN,DUMCOLL
	.WORD	OID_JUNK,DMAWNZ|M_SCRNOBJ,0
	.LONG	0

*
* This goes on the end of PLOT_LEVELS
PL_GUN
	MOVE	*A2(PGUNPOWER),A0,W
	MOVE	*A2(PLASTGPLOT),A1,W
	CMP	A0,A1				;IS THE GUN LEVEL CORRECT?
	JREQ	PL_DONE				;BR = YES
	SUB	A1,A0
	MOVE	A0,A14
	ABS	A0
	CMPI	1,A0
	JRLS	PL_ADDA0G
	MOVK	1,A0
PL_ADDA0G
	MOVE	A14,A14
	JRNN	PL_PADDG
	NEG	A0
PL_PADDG
	ADD	A0,A1
	CALLR	OUTGUN_A1
PL_DONE
	RETS

	.ENDIF

	.END

