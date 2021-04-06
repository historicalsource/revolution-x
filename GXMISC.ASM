	.MLIB	"GXMACS.LIB"
	.FILE	"GXMISC.ASM"
	.TITLE	"<<< GENERATION X - MISCELLANEOUS ROUTINES >>>"
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
	.INCLUDE	"BGNDTBL.GLO"

	.DEF	COLOR_START, DUMP_IT
	.DEF	SKYUP, SKYDOWN
	.DEF	BUYINWIN
	.DEF	BUYWIN_Z
	.DEF	SECURITY
	.DEF	SKYWHITE, SKYNORM

*SYMBOLS IN AP.ASM
	.REF	DUXNOFADE
*SYMBOLS IN GXRAM.ASM
	.REF	COLRTEMP, SKYCOLOR, BTIME, SEC_FLAG, BUYIN_SECS, BUYIN_NOFADE
	.REF	BUYIN_RESETS
*SYMBOLS IN APPALL.ASM
	.REF	PALSET
*SYMBOLS IN APCOIN.ASM 
	.REF	CR_CONTP
*SYMBOLS IN APPOWER.ASM
	.REF	CLR_HEADS_UP, CLR_PLAYER_TEXT
*SYMBOLS IN APCMOS.ASM
	.REF	ADD_DUMP
*SYMBOLS IN APPROC.ASM
	.IF NOTFINAL
	.REF	THISWAKE
	.ENDIF
*SYMBOLS IN APPRNT.ASM
	.IF	PRINTER
	.REF	PRINT_DUMP
	.ENDIF

***** from GXDTST.ASM
	.ref	_pic_secure
	
	.EVEN
	.TEXT

**************************************************************************
*								         *
* 	NOTE: PLACE THESE TWO DUMB COLLISION VECTORS IN A USABLE	 *
* 	      POSITION SOMEDAY!!!!					 *
*								         *
**************************************************************************
DUMCRETS			;COLLISION RETURN TO CONTINUE SCAN
	CLRZ
	RETS

DUMCOLL				;LABEL FOR THE COMMON CAUSE
	.WORD	0
	.LONG	DUMCRETS	;DO NOTHING

**************************************************************************
*								         *
* DUMPPRINT - Do a register dump to the Printer, if it's installed.	 *
* 		If not, then go to CMOS.				 *
* 									 *
* 		If DEBUG  then we jsut hang here.			 *
* 		If PRINTER & ~DEBUG  then PRINT registers.		 *
* 		If ~PRINTER & ~DEBUG  then Write to CMOS.		 *
*								         *
**************************************************************************
DUMPPRINT
	.IF DEBUG

	JRUC	$
	RETS			;USE THIS TO JUMP BACK. 

	.ELSE

	MOVE	*SP,B14,L	;Grab the return address for dump

	 .IF PRINTER

	 JAUC	PRINT_DUMP

	 .ELSE

	 PUSH	A0
	 AUDIT	AUDWARNING
	 PULLQ	A0
	 CLR	A14
	 JRUC	DUMP_IT

	 .ENDIF

	.ENDIF

**************************************************************************
*								         *
* DUMP_IT - Dump Registers and relevent info to the CMOS dump pages.	 *
* A14 = Dump Code							 *
* B14 = Return Address							 *
*								         *
**************************************************************************
DUMP_IT
	MMTM	SP,A0,A1,A2,A3,A4,A5,A6,A7,A8
	MOVE	A0,A7

;	PUSH	A14
;	PUSH	B14
;	MOVI	AUDUPTIME,A0
;	CALLA	GET_AUD
;	MOVE	A1,A6
;	PULLQ	B14
;	PULLQ	A14

	MOVE	@TIMER,A0,W
	SLL	4,A0
	OR	A14,A0
	SLL	16,A0
	MOVE	@GAME_STATE,A14,W
	MOVX	A14,A0			;A0 = [CODE, GSTATE]

	MOVE	@WAVE,A1,W
	SLL	16,A1
	MOVE	@CURPLYRS,A14,W
	MOVX	A14,A1			;A1 = [WAVE, # OF PLAYERS]

;	MOVE	*SP(120H),A2,L		;A2 = RETURN ADDRESS
	MOVE	B14,A2			;A2 = RETURN ADDRESS

	.IF NOTFINAL
	MOVE	@THISWAKE,A3,L		;A3 = LAST WAKE-UP ADDRESS
	.ENDIF

	MOVE	@WAVETIME,A4,L		;A4 = ELAPSED WAVE TIME

	MOVE	@XBASE,A5,L

	MOVE	@YBASE,A6,L

	MOVE	@ZBASE,A7,L

	MOVE	@ZREL_OFF,A8,L
	SRA	ZFRAC,A8

	;NEED TO SEND WORLD COORDINATES ALSO

	CALLA	ADD_DUMP

	MMFM	SP,A0,A1,A2,A3,A4,A5,A6,A7,A8
	RETS

**************************************************************************
*								         *
* SECURITY - AND FINALLY ... THERE IS SECURITY!				 *
* B0 = RETURN ADDRESS							 *
* SETS GLOBAL SEC_FLAG TO 1 IF BREECH!					 *
* NOTE: TRASHES A0,A1,A2,A3,A4,A6					 *
*								         *
**************************************************************************
SECURITY
	move	@_pic_secure,a0,W
;	CLR	A0
	MOVE	A0,@SEC_FLAG,W
	FRET	B0

**************************************************************************
*                                                                        *
* COLOR_START - START THE COLOR RAM PROCESSES				 *
*                                                                        *
**************************************************************************
COLOR_START
	MMTM	SP,A0,A1,A7
	MOVI	PID_COLOR,A0
	CALLA	KILLPROC_ALL
	CREATE	PID_COLOR,LFLASH
	CREATE	PID_COLOR,RGB
	CREATE	PID_COLOR,BPR
	CREATE	PID_COLOR,DECAY
	MMFM	SP,A0,A1,A7
	RETS

**************************************************************************
*                                                                        *
* TABLE DRIVEN COLOR RAM PROCESSES					 *
*                                                                        *
**************************************************************************
*	xxxxxA0(10)	-	RGB
*	xxxxxB0(11)	-	BPR
*	xxxxxC0(12)	-	DECAY
*	xxxxxD0(13)	-	LASER FLASH

RGB	CALLR	TABDRIVE
	.LONG	RGBTAB,COLRTEMP+0A0H
	.WORD	8
RGBTAB	.WORD	07C00H,001FH,077A0h,0741Ah,0FFFFH

*
DECAY	CALLR	TABDRIVE
	.LONG	DCATAB,COLRTEMP+0C0H
	.WORD	2
DCATAB	.WORD	001CH,001CH,011CH,021CH,031CH,039CH,239CH,2390H,2388H
	.WORD	2380H,4300H,5280H,7180H,6180H,7080H,7000H,6000H,5000H
	.WORD	4000H,3000H,2000H,1000H,0FFFFH
*
BPR	CALLR	TABDRIVE
	.LONG	BPRTAB,COLRTEMP+0B0H
	.WORD	1
BPRTAB	.WORD	001CH,101CH,201CH,301CH,401CH,501CH,601CH,701CH,7010H
	.WORD	7010H,7008H,7008H,7000H,7000H,7008H,7008H,7010H,7010H
	.WORD	701CH,701CH,601CH,501CH,401CH,301CH,201CH,101CH,0FFFFH

**************************************************************************
*								         *
* LFLASH - PROCESS TO CREATE THE FAMOUS LASER FLASH COLOR 		 *
*								         *
**************************************************************************
LFLASH	MOVI	07FFFH,A0
	MOVE	A0,@COLRTEMP+0D0H,W
	SLEEP	2
LFLASH1
	MOVE	@RAND,A0,W
	ANDI	0000001FH,A0
	MOVI	COLTAB,A1
	SLL	4,A0
	ADD	A0,A1
	MOVE	*A1,A1,W
	MOVE	A1,@COLRTEMP+0D0H,W
	SLEEP	6
	JRUC	LFLASH

COLTAB	.WORD	0380H,1380H,2380H,3380H,4380H,5380H,6380H,7380H,7300H
	.WORD	7280H,7200H,7180H,7080H,7008H,7008H,7010H,7010H,701CH
	.WORD	701CH,601CH,501CH,409CH,309CH,209CH,219CH,029CH,039CH
	.WORD	139CH,239CH,339CH,539CH,739CH,7390H,7380H,6380H,4380H
	.WORD	0FFFFH

**************************************************************************
*                                                                        *
* THE TABLE DRIVEN PROCESS						 *
*                                                                        *
**************************************************************************
TABDRIVE
	MOVE	*SP+,A0,L
	MOVE	*A0+,A11,L	;A11 = TABLE START
	MOVE	*A0+,A9,L	;A9 = LOCATION TO STUFF COLOR
	MOVE	*A0,A10,W	;A10 = SLEEP TIME
TABDRV1
	MOVE	A11,A8		;RESET TO START OF TABLE
TABDRV2
	MOVE	*A8+,A0,W	;GET A COLOR
	JRN	TABDRV1		;BR = END OF TABLE
	MOVE	A0,*A9,W
	MOVE	A10,A0
	MOVI	TABDRV2,A7
	JAUC	PRCLSP		;LOOP SLEEP

**************************************************************************
*								         *
* CYCLE16 - PROCESS TO CYCLE UP TO SIXTEEN COLORS OF A GIVEN PALETTE.	 *
* A8 = PTR TO PALETTE (PALETTE MUST BE ALLOCATED).			 *
* A9 = START COLOR #							 *
* A10 = END COLOR #							 *
* A11 = SPEED								 *
*								         *
**************************************************************************
CYCLE16:
	MOVE	A11,*A13(PDATA),W	;KEEP THE SLEEP TIME
	MOVE	A10,A2
	CLR	A11			;THIS WILL BE THE DIRECTION FLAG
	SUB	A9,A2
	JRNN	CYCLE16_FOR		;BR = FOWARD CYCLE
	ABS	A2	
	NOT	A11			;FLAG A REVERSE CYCLE 
	SWAP	A9,A10			;SWAP THESE FOR LOAD

CYCLE16_FOR:
	MOVE	A9,*A13(PDATA+10H),W	;STORE THE START COLOR
	MOVE	A9,A3	
	MOVE	A13,A9
	ADDI	PDATA+60H,A9		;START COLOR ADDRESS
	MOVE	A9,A10
	MOVE	A2,A4
	SLL	4,A4
	ADD	A4,A10			;END COLOR ADDRESS

	MOVE	A8,A0
	MOVE	A9,A1			;THIS IS THE STARTING COLOR LOCATION
	ADDK	16,A0			;SKIP THE COLOR COUNT
	SLL	4,A3
	ADD	A3,A0			;AND GET TO THE START COLOR
	INC	A2
	MOVE	A2,*A13(PDATA+20H),W	;STORE THE COLOR COUNT

CYCLE16_LOAD:
	MOVE	*A0+,*A1+,W		;TRANSFER THE PALETTE TO RAM
	DSJS	A2,CYCLE16_LOAD

CYCLE16_WAIT:
	MOVE	A8,A0
	CALLA	FINDPAL			;DOES THIS PALETTE EXIST?	
	JRNZ	CYCLE16_FND		;BR = YES, GO AHEAD AND CYCLE
	SLOOP	6,CYCLE16_WAIT		;WAIT FOR IT TO EXIST

CYCLE16_FND:
	MOVE	A0,A7			;STORE FOUND PALETTE NUMBER HERE
	MOVE	*A13(PDATA+20H),A4,W	;DO IT THIS MANY TIMES
	DEC	A4			;WATCH THE ZERO BASE

	MOVE	A11,A11			;CHECK DIRECTION
	JRNN	CYCLE16_UP		;BR = CYCLE COLORS UP
	MOVE	A9,A1			;GET THE END COLOR
	MOVE	*A1,A3,W		;STORE THE COLOR
	MOVE	A10,A2
	MOVE	A1,A0	
	ADDK	16,A1
CYCLE16_DN_LP:
	MOVE	*A1+,*A0+,W
	DSJS	A4,CYCLE16_DN_LP
	JRUC	CYCLE16_DONE

CYCLE16_UP:
	MOVE	A10,A1			;GET THE END COLOR
	MOVE	*A1,A3,W		;STORE THE COLOR
	MOVE	A9,A2
	MOVE	A1,A0	
	ADDK	16,A1
CYCLE16_UP_LP:
	MOVE	-*A0,-*A1,W	
	DSJS	A4,CYCLE16_UP_LP
CYCLE16_DONE:
	MOVE	A3,*A2,W		;WRAP COLOR
	MOVE	A9,A0
	MOVE	*A13(PDATA+10H),A1,W
	ZEXT	A7

****	.IF	YUNIT
****	SRL	12,A7
****	.ELSE
	SRL	8,A7
****	.ENDIF

	SLL	8,A7
	OR	A7,A1			;DESTINATION: 8-15 PALETTE, 0-7 START		
	MOVE	*A13(PDATA+20H),A2,W	;GET THE COUNT
	CALLA	PALSET			;SETUP A TRANSFER
	MOVE	*A13(PDATA),A0,W
	SLOOPR	A0,CYCLE16_WAIT

**************************************************************************
*								         *
* CYCLE1 - PROCESS TO CYCLE ONE COLOR OF A PALETTE THROUGH DIFFERENT	 *
*	   VALUES.							 *
* A8 = PALETTE I.D. PROCESS WILL WAIT 'TIL PALETTE IS ALLOCATED.	 *
* A9 = TABLE OF COLORS							 *
* A10 = COLOR #								 *
* A11 = SPEED								 *
*								         *
**************************************************************************
CYCLE1:
	MOVE	A9,*A13(PDATA+10H),L	;STORE THE TABLE START ADDRESS
CYCLE1_WAIT:
	MOVE	A8,A0
	CALLA	FINDPAL			;DOES THIS PALETTE EXIST?	
	JRNZ	CYCLE1_FND		;BR = YES, GO AHEAD AND CYCLE
	SLOOP	6,CYCLE1_WAIT		;WAIT FOR IT TO EXIST
CYCLE1_FND:
	MOVE	A0,A8			;KEEP FOR SUCCESSIVE ITERATIONS
	MOVE	A0,A5
	CALLA	INC_PALCNT		;SURELY YOUR NOT GOING ANYWHERE
	ZEXT	A8
	SRL	8,A8
	SLL	8,A8
CYCLE1_LP
	MOVE	A10,A1			;COLOR NUMBER
	OR	A8,A1			;DESTINATION: 8-15 PALETTE, 0-7 START		
	MOVE	A9,A0
	MOVK	1,A2
	CALLA	PALSET			;SETUP A TRANSFER
	ADDK	16,A9			;INCREMENT TABLE PTR
	MOVE	*A9,A14,W
	JRNN	CYCLE1_SLP
	MOVE	*A13(PDATA+10H),A9,L	;RESET TO THE HEAD OF THE TABLE
CYCLE1_SLP
	SLOOPR	A11,CYCLE1_LP

BUYWIN_Z	.EQU	7FFF0001H
CURR_BUY_MESS	.EQU	PDATA		;UHL Ptr to current Text string
BUY_LINE1_OBJ	.EQU	PDATA+20H	;UHL Ptr to Line 1 string object
BUY_LINE2_OBJ	.EQU	PDATA+40H	;UHL Ptr to Line 2 string object
BUY_TIME_OBJ	.EQU	PDATA+60H	;UHL Ptr to Timer string object

	.BSS	B_CONT_CREDS,32		;CREDITS TO CONTINUE
	.BSS	B_CONT_SUFFIX,32	;SUFFIX FOR CREDIT(S)
**************************************************************************
*                                                                        *
* BUYINWIN - PUT UP THE BUY-IN WINDOW PROCESS				 *
*                                                                        *
**************************************************************************
BUYINWIN
****	MOVI	16,A0
****	MOVI	BUYWIN_Z,A1
****	MOVI	[88+SKYTOPOF,198],A10
****	MOVI	[120,236],A8
****	JSRP	OWINDOW			;OPEN THE WINDOW
****	JRZ	BUYINWDI		;COULDN'T DO IT
	CALLA	IAUTOE			;DO THIS JUST IN CASE
	MOVE	@SKYCOLOR,@IRQSKYE,W
	MOVE	@GROUNDCOLOR,@IRQGNDE,W

	ALLPLYR	CLR_HEADS_UP		;CLEAR ALL HEADS UP DISPLAYS
	ALLPLYR	CLR_PLAYER_TEXT		;CLEAR ANY CURRENT PLAYER TEXT

	PAUSEON
	MOVE	@BUYIN_NOFADE,A0,L
	JRNZ	BIW_FADE	  	;BR = We have a special fade script
	MOVI	DUXNOFADE,A0
BIW_FADE
	CALLA	FADE_FULL2HALF		;DROP THE PLAYFIELD BRIGHTNESS
	SLEEP	16
;	SOUND1	BUYSTART_SND		;START DAT CRAZY BUYIN TING

	CALLA	CLRPDATA		;Initialize our data area
	CALLR	INIBTIME		;INITIALIZE BUY IN TIME
	CALLR	INIBMESS		;INITIALIZE BUY IN MESSAGE
	MOVK	1,A0
	MOVE	A0,@BUYNOW,W
	MOVKM	8,@BUYIN_RESETS,W	;Initialize the allowed reset counter
	CLRM	@BUYIN_SECS,W		;Clear the seconds counter
PBUYOLP
	MOVI	BUYTICK,A11
PBUYILP
	MOVE	@CURPLYRS,A0,W
	JRNZ	PBUYDONE_BOUGHTIN	;OTHER GUY BOUGHT IN
	SLEEP	BUYSLP
	CALLR	UPBMESS1		;UPDATE BUYIN MESSAGE 1
	DSJS	A11,PBUYILP
	INCM	@BUYIN_SECS,W		;Increment Buy-in seconds counter
	CALLR	DECBTIME		;DECREMENT BUYIN TIME
	JRGE	PBUYOLP			;WE ARE NOT DONE YET
	JRUC	PBUYDONE_GAMEOVER
*
*DUDE JUST SLAMMED SOME MORE TIN. HE'S WAY COOL. WHAT A GOD.
*
PBUYDONE_BOUGHTIN
;	SOUND1	BUYEND_SND		;STOP DAT CRAZY BUYIN TING
*
*DUDE JUST WIMPED OUT. HE SURE DID. WHAT A FAG!
*
PBUYDONE_GAMEOVER
	CALLR	CLEAR_BUY_TIME
	CALLR	CLEAR_BUY_MESSAGE

	MOVI	PID_GOODIE,A0
	CALLA	KILLPROC_ALL

****	MOVI	20,A0
****	JSRP	CWINDOW
	MOVI	PID_PFADE,A0
	CALLA	KILLPROC_ALL
	SLEEP	3
	CALLA	CLR_0PALS
	MOVE	@BUYIN_NOFADE,A0,L
	JRNZ	PBD_FADE	  	;BR = We have a special fade script
	MOVI	DUXNOFADE,A0
PBD_FADE
	CALLA	FADE_HALF2FULL			;BRING THE PLAYFIELD UP
	SLEEP	20
	PAUSEOFF
	CLR	A0
	MOVE	A0,@BUYNOW,W
BUYINWDI
	DIE

BUYSTART_SND
	.WORD	0F2FEh,001h,08012h,0
BUYEND_SND
	.WORD	0F2FEh,001h,08011h,0

**************************************************************************
*								         *
* INIBMESS - INITIALIZE THE BUY IN MESSAGE				 *
* A13 = PTR TO BUY-IN PROCESS						 *
*								         *
**************************************************************************
INIBMESS
	MMTM	SP,A0,A1,A2,A5,A6,A8,A9,A10,A11
	ADJUST	ADJCCONT
	MOVE	A0,@B_CONT_CREDS,W
	CMPI	1,A0
	JRNE	IB_NOSUF
	MOVIM	SUFFIX_NULL,@B_CONT_SUFFIX,L
	JRUC	IB_MESS
IB_NOSUF
	MOVIM	SUFFIX_S,@B_CONT_SUFFIX,L
IB_MESS
	CALLA	CR_CONTP	;ENOUGH TO CONTINUE?
	JRLO	INIBMIN		;BR = NO
	MOVI	PRESS_MESS,A8
	JRUC	INIBM1
INIBMIN
	MOVI	INSRT_MESS,A8
INIBM1
	MOVE	A8,*A13(CURR_BUY_MESS),L

	CALLA	LM_SETUP
	CALLR	GWINCENT	;POSITION
	PUSH	A0		;Save the center position
	.IF GERMAN
	SUBI	[25,0],A0	;OFFSET FROM BOX CENTER
	.ELSE
	SUBI	[50,0],A0	;OFFSET FROM BOX CENTER
	.ENDIF
	MOVE	A0,A9
	CLR	A0
	JSRP	PRINTF
	MOVE	A2,*A13(BUY_LINE1_OBJ),L	;Store Line 1 object


	.IF GERMAN
	CLR	A2
	.ELSE
	MOVI	TOCON_MESS,A8
	CALLA	LM_SETUP
	PULLQ	A9		;Restore center position in the proper reg
	SUBI	[22,0],A9	;OFFSET FROM BOX CENTER
	JSRP	PRINTF
	.ENDIF
	MOVE	A2,*A13(BUY_LINE2_OBJ),L	;Store Line 2 object

	MMFM	SP,A0,A1,A2,A5,A6,A8,A9,A10,A11
	RETS

**************************************************************************
*								         *
* INIBTIME - INITIALIZE THE BUY IN TIMER				 *
* A13 = PTR TO BUY-IN PROCESS						 *
*								         *
**************************************************************************
INIBTIME
	MMTM	SP,A0,A1,A2,A5,A6,A8,A9,A10,A11
	CALLR	CLEAR_BUY_TIME
	MOVI	BUYTIME,A0
	MOVE	A0,@BTIME,W	;STORE IT AWAY

	MOVI	TIME_MESS,A8
	CALLA	LM_SETUP
	CALLR	GWINCENT	;POSITION
	.IF GERMAN
	ADDI	[10,0],A0	;OFFSET FROM BOX CENTER
	.ELSE
	ADDI	[35,0],A0	;OFFSET FROM BOX CENTER
	.ENDIF
	MOVE	A0,A9
	CLR	A0
	JSRP	PRINTF
	MOVE	A2,*A13(BUY_TIME_OBJ),L	;Store Timer object

	MMFM	SP,A0,A1,A2,A5,A6,A8,A9,A10,A11
	RETS

**************************************************************************
*								         *
* CLEAR_BUY_MESSAGE - Clear the Buy-In message text, all lines.		 *
* A13 = Ptr to Buy-In process.						 *
*								         *
**************************************************************************
CLEAR_BUY_MESSAGE
	CALLR	CLEAR_BUY_LINE1
	CALLR	CLEAR_BUY_LINE2
	RETS

**************************************************************************
*								         *
* CLEAR_BUY_LINE1 - Clear the first line of the Buy-In message.		 *
* A13 = Ptr to Buy-In process.						 *
*								         *
**************************************************************************
CLEAR_BUY_LINE1
	PUSH	A8
	MOVE	*A13(BUY_LINE1_OBJ),A8,L
	JRZ	CBM_NO_LINE1
	CALLA	DELETE_OBJ
	CLR	A8
	MOVE	A8,*A13(BUY_LINE1_OBJ),L
	MOVE	A8,*A13(CURR_BUY_MESS),L
CBM_NO_LINE1
	PULLQ	A8
	RETS

**************************************************************************
*								         *
* CLEAR_BUY_LINE2 - Clear the second line of the Buy-In message.	 *
* A13 = Ptr to Buy-In process.						 *
*								         *
**************************************************************************
CLEAR_BUY_LINE2
	PUSH	A8
	MOVE	*A13(BUY_LINE2_OBJ),A8,L
	JRZ	CBM_NO_LINE2
	CALLA	DELETE_OBJ
	CLR	A8
	MOVE	A8,*A13(BUY_LINE2_OBJ),L
CBM_NO_LINE2
	PULLQ	A8
	RETS

**************************************************************************
*								         *
* CLEAR_BUY_TIME - CLEAR THE BUY-IN TIME TEXT.				 *
* A13 = Ptr to BuyIn process						 *
*								         *
**************************************************************************
CLEAR_BUY_TIME
	PUSH	A8
	MOVE	*A13(BUY_TIME_OBJ),A8,L
	JRZ	CBT_X
	CALLA	DELETE_OBJ
	CLR	A8
	MOVE	A8,*A13(BUY_TIME_OBJ),L
CBT_X
	PULLQ	A8
	RETS

**************************************************************************
*                                                                        *
* DECBTIME - DECREMENT THE BUY IN TIMER					 *
* RETURNS:								 *
* 	Z BIT SET = BUY IN TIME DONE					 *
* 	Z BIT CLR = HURRY WHILE SPECIALS LAST!				 *
*                                                                        *
**************************************************************************
DECBTIME
	MMTM	SP,A0,A1,A2,A5,A6,A8,A9,A10,A11
	CALLR	CLEAR_BUY_TIME
	MOVE	@BTIME,A0,W
	DEC	A0
	JRLT	DECBTX
	MOVE	A0,@BTIME,W

;	CMPI	BUYTIME-5,A0
	CMPK	5,A0
	JRNE	DBT_NOSPEAK1
	SOUND1	BUYHURRY_SND
DBT_NOSPEAK1
;	CMPI	BUYTIME-7,A0
	CMPK	3,A0
	JRNE	DBT_NOSPEAK2
	SOUND1	SND_BUYHURRY2
DBT_NOSPEAK2

	MOVI	TIME_MESS,A8
	CALLA	LM_SETUP
	CALLR	GWINCENT	;POSITION
	.IF GERMAN
	ADDI	[10,0],A0	;OFFSET FROM BOX CENTER
	.ELSE
	ADDI	[35,0],A0	;OFFSET FROM BOX CENTER
	.ENDIF
	MOVE	A0,A9
	CLR	A0
	JSRP	PRINTF
	MOVE	A2,*A13(BUY_TIME_OBJ),L	;Store Timer object

	MOVE	@BTIME,A8,W	;SET STATUS
DECBTX
	MMFM	SP,A0,A1,A2,A5,A6,A8,A9,A10,A11
	RETS

BUYHURRY_SND
	.WORD	0F3E1h,26,0880Bh,0	;"HURRY!"

SND_BUYHURRY2
	.WORD	0F3E1h,46,0880Dh,0	;"Right Now"

**************************************************************************
*								         *
* UPBMESS1 - UPDATE THE "PRESS START" OR "INSERT COIN" MESSAGE.		 *
* A13 = PTR TO BUY-IN PROCESS						 *
* RETURNS:								 *
* A11 = UPDATED SLEEP LOOP TIME FOR BUYIN THING				 *
*								         *
**************************************************************************
UPBMESS1
	MMTM	SP,A0,A1,A2,A5,A6,A8	;MORE PUSHING TO COME
	CALLA	CR_CONTP		;ENOUGH TO CONTINUE?
	JRLO	UPBMIN			;BR = NO
	MOVI	PRESS_MESS,A8
	JRUC	UPBM1
UPBMIN
	MOVI	INSRT_MESS,A8
UPBM1
	MMTM	SP,A9,A10,A11		;WATCH OUT FOR THIS BOGUSNESS
	MOVE	*A13(CURR_BUY_MESS),A0,L
	CMP	A0,A8			;SAME MESSAGE?
	JREQ	UPBMESS1_X		;BR = YES

	CALLR	CLEAR_BUY_LINE1

	MOVE	A8,*A13(CURR_BUY_MESS),L	;MARK NEW MESSAGE

	CALLA	LM_SETUP
	CALLR	GWINCENT		;POSITION
	.IF GERMAN
	SUBI	[25,0],A0	;OFFSET FROM BOX CENTER
	.ELSE
	SUBI	[50,0],A0	;OFFSET FROM BOX CENTER
	.ENDIF
	MOVE	A0,A9
	CLR	A0
	JSRP	PRINTF			;OUTPUT NEW MESSAGE
	MOVE	A2,*A13(BUY_LINE1_OBJ),L
UPBMESS1_X
	MMFM	SP,A0,A1,A2,A5,A6,A8,A9,A10,A11
	RETS

**************************************************************************
*                                                                        *
* GWINCENT - GET THE CURRENT TEXT WINDOW CENTER POINT.			 *
* RETURNS:								 *
* A0 = CENTER PNT.							 *
*                                                                        *
**************************************************************************
GWINCENT
	MOVI	[88+SKYTOPOF,198],A0
****	MMTM	SP,A1,A8
****	MOVI	TEXTWOID,A0
****	CALLA	EXISTOBJ_ALL
****	JRZ	GWINCX
****	MOVE	A0,A8
****	CALLA	GET_CPNT
****	MOVE	A1,A0
****GWINCX
****	MMFM	SP,A1,A8
	RETS

*
*SOME MESSAGES
*

	.IF GERMAN

INSRT_MESS:
	MESS_MAC RD20FONT,1,200,(88+SKYTOPOF),COLOR_PLF,STRCNRMO,OID_BMES1
	.STRING "%d\b KREDIT%p",0
	.LONG	B_CONT_CREDS
	.WORD	COLOR_RGB
	.LONG	B_CONT_SUFFIX
	.EVEN
PRESS_MESS:
	MESS_MAC RD20FONT,1,200,(88+SKYTOPOF),COLOR_PRGB,STRCNRMO,OID_BMES1
	.STRING	"START DR",C_GERU,"CKEN",0
	.EVEN
TOCON_MESS:
	MESS_MAC RD20FONT,1,200,(88+SKYTOPOF),COLOR_PBPR,STRCNRMO,OID_BMES2
	.STRING	"DIESES\nSPIEL BEN",C_GERO,"TICT",0
	.EVEN
	
	.ELSE

INSRT_MESS:
	MESS_MAC RD20FONT,1,200,(88+SKYTOPOF),COLOR_PLF,STRCNRMO,OID_BMES1
	.STRING "%d\b CREDIT%p",0
	.LONG	B_CONT_CREDS
	.WORD	COLOR_RGB
	.LONG	B_CONT_SUFFIX
	.EVEN
PRESS_MESS:
	MESS_MAC RD20FONT,1,200,(88+SKYTOPOF),COLOR_PRGB,STRCNRMO,OID_BMES1
	.STRING	"PRESS START",0
	.EVEN
TOCON_MESS:
	MESS_MAC RD20FONT,1,200,(88+SKYTOPOF),COLOR_PBPR,STRCNRMO,OID_BMES2
	.STRING	"TO\nCONTINUE",0
	.EVEN

	.ENDIF

TIME_MESS:
	MESS_MAC RD20FONT,1,200,88+SKYTOPOF,COLOR_PLF,STRCNRMO,OID_BTIME
	.STRING	"%d",0
	.LONG	BTIME
	.EVEN

**************************************************************************
*                                                                        *
* SKYUP - FADE UP THE SKY COLOR AND DIE					 *
* A9 = FADER SPEED							 *
* I.D. = PID_SKY								 *
**************************************************************************
SKYUP
	MOVE	*A13(PROCID),A0,W
	CLR	A1
	NOT	A1
	CALLA	KILALL
	CLR	A8
SKYUP1
	MOVE	@SKYCOLOR,A0,W
	MOVE	A8,A1
	CALLA	XCOLOR
	MOVE	A0,@IRQSKYE,W

	MOVE	@GROUNDCOLOR,A0,W
	MOVE	A8,A1
	CALLA	XCOLOR
	MOVE	A0,@IRQGNDE,W

	SLEEP	1

	ADD	A9,A8
	CMPI	10000H,A8
	JRLE	SKYUP1
SKYFULL
	MOVE	@SKYCOLOR,@IRQSKYE,W
	MOVE	@GROUNDCOLOR,@IRQGNDE,W
	DIE

**************************************************************************
*								         *
* SKYDOWN - FADE DOWN THE SKY COLOR AND DIE				 *
* A9 = FADER SPEED							 *
* I.D. = PID_SKY								 *
*								         *
**************************************************************************
SKYDOWN
	MOVE	*A13(PROCID),A0,W
	CLR	A1
	NOT	A1
	CALLA	KILALL
	MOVI	10000H,A8
SKYDOWN1
	MOVE	@SKYCOLOR,A0,W
	MOVE	A8,A1
	CALLA	XCOLOR
	MOVE	A0,@IRQSKYE,W

	MOVE	@GROUNDCOLOR,A0,W
	MOVE	A8,A1
	CALLA	XCOLOR
	MOVE	A0,@IRQGNDE,W

	SLEEP	1

	SUB	A9,A8
	JRGT	SKYDOWN1
SKYBLACK
	CLR	A1
	MOVE	A1,@IRQSKYE,W
	MOVE	A1,@IRQGNDE,W
	DIE

**************************************************************************
*                                                                        *
* SKYWHITE - FADE UP THE SKY COLOR TO WHITE AND DIE			 *
* A9 = FADER SPEED							 *
* I.D. = PID_SKY								 *
**************************************************************************
SKYWHITE
	MOVE	*A13(PROCID),A0,W
	CLR	A1
	NOT	A1
	CALLA	KILALL
	CLR	A8
SKYWHITE1
	MOVI	07FFFh,A0
	MOVE	A8,A1
	CALLA	XCOLOR
	MOVE	A0,@IRQSKYE,W
	SLEEP	1
	ADD	A9,A8
	CMPI	10000H,A8
	JRLE	SKYWHITE1
	JRUC	SKYFULL

**************************************************************************
*								         *
* SKYNORM - FADE DOWN THE SKY COLOR FROM WHITE AND DIE			 *
* A9 = FADER SPEED							 *
* I.D. = PID_SKY								 *
*								         *
**************************************************************************
SKYNORM
	MOVE	*A13(PROCID),A0,W
	CLR	A1
	NOT	A1
	CALLA	KILALL
	MOVI	10000H,A8
SKYNORM1
	MOVI	07FFFh,A0
	MOVE	A8,A1
	CALLA	XCOLOR
	MOVE	@SKYCOLOR,A14,W
	CMP	A14,A0
	JRHS	SKY_OK
	MOVE	A14,@IRQSKYE,W
	SLEEP	1
	JRUC	SKYBLACK
SKY_OK
	MOVE	A0,@IRQSKYE,W
	SLEEP	1
	SUB	A9,A8
	JRNN	SKYNORM1

	JRUC	SKYBLACK


**************************************************************************
*                                                                        *
* XCOLOR - COLOR VALUE MULTIPLIER					 *
* A0 = COLOR VALUE							 *
* A1 = X FACTOR (MSW:INTEGER LSW:FRACTION)				 *
* RETURNS								 *
* A0 = X COLOR VALUE							 *
*                                                                        *
**************************************************************************
XCOLOR
	MMTM	SP,A3,A4
	CLR	A4
	MOVE	A0,A3
	SLL	27,A3
	SRL	27,A3		;NOW I GOT 'DA BLUES
	MPYU	A1,A3
	SLL	11,A3
	SRL	27,A3
	OR	A3,A4
	MOVE	A0,A3
	SLL	22,A3
	SRL	27,A3		;GREENS
	MPYU	A1,A3
	SLL	11,A3		;STRIP GARBAGE
	SRL	27,A3
	SLL	5,A3
	OR	A3,A4
	MOVE	A0,A3
	SLL	17,A3
	SRL	27,A3		;NOW REDS
	MPYU	A1,A3
	SLL	11,A3
	SRL	27,A3
	SLL	10,A3
	OR	A3,A4
	MOVE	A4,A0
	MMFM	SP,A3,A4
	RETS

	.END
