	.MLIB	"GXMACS.LIB"
	.FILE	"GXBONUS.ASM"
	.TITLE	"<<< REVOLUTION X -- BONUS STUFF AN'NAT >>>"
	.WIDTH	132
	.OPTION	B,D,L,T
	.MNOLIST

**************************************************************************
*								         *
* 	COPYRIGHT (C) 1993 MIDWAY MANUFACTURING COMPANY.		 *
* 		       ALL RIGHTS RESERVED.				 *
*								         *
**************************************************************************

	.INCLUDE	"IMGTBL.GLO"
	.INCLUDE	"BGNDTBL.GLO"
	.INCLUDE	"GX.INC"
	.INCLUDE	"GXSTRING.H"
	.INCLUDE	"GXBONUS.TBL"
	.INCLUDE	"GXBOOSH.TBL"

*
*Symbols from Bonusing
*
	.DEF	 GO_BONUS,INIT_ZERO_UNIVERSE
	.DEF	SETUP_TEST ,JAKE_BOX
	.DEF	BONUS_SET_X, NUMBER_RACKS
	.DEF	AERO_WINGS_INIT

*
*Symbols from around the GLOBE
*
*FROM GX
	.REF	MYOINIT,DUXNOFADE, PLAYER_BONUS_RESTART

	.REF	SND_DIR_CHOSEN,SND_DIR_INACTIVE
	.REF	GUNS_OFF,FADEOUT_PAL

	.REF	CREATE_MULTI_COPY

***** from GXCONTRL.ASM
	.REF	PLAYER_CURSOR
	.REF	CURSOR_OFF

*FROM GXFADE.ASM
	.REF	GO_NORMAL,GO_WHITE

***** from GXKERRI.ASM
	.REF	PROC_KERRI_KISS

*FROM GXRAM
	.REF	ENEMIES_TOTAL
	.REF	ENEMIES_P1
	.REF	ENEMIES_P2
	.REF	ENEMIES_P3
	.REF	BONUS_ONCE


	.REF	CALCULATE_HORIZON
	.REF	CR_STRTP

*number storage
	.BSS	NUM_DATA,32	;USED TO STORE NUMBERS TEMPORARILY
	.BSS	NUM_DATA_2,32	;USED TO STORE NUMBERS TEMPORARILY
	.BSS	NUM_DATA_3,32	;USED TO STORE BONUS FOR EACH RACK UP
	.BSS	NUMBER_RACKS,32	;ARE WE 2 OR 3 PLAYERS
	.BSS	WAVES_DONE,32
	.BSS	DIR_SELECTED,32

PBLK_STOR	.EQU	PDATA+0200H	;STORE AWAY THE PLAYER BLOCK IN A PROCESS

	.TEXT

;**************************************************************************
;*											      *
;* Actually start the bonus routine.								 *
;* input												 *
;*  - A1 0 - bring on from top of screen and ignore dash board stuff	 *
;*       1 - bring on from bottom of screen and include dash			 *
;*       2 - bring on from left of screen and include dash			 *
;*       3 - bring on from right of screen and include dash			 *
;*											      *
;**************************************************************************
GO_BONUS
SETUP_TEST
	MOVE	A1,A1
	JRNN	GB_GO_GO_GO		;BR = OK to do bonus
	RETP				

GB_GO_GO_GO
	PUSH	A1
	CALLA	MYOINIT			;initialize evreyfink
	CALLA	INIT_ZERO_UNIVERSE	;set up dummy universe
	CALLA	KILL_THAT_FUCKING_BUG
	MOVIM	-1,@GAMERASE,W		;make us erase all 
	MOVIM	SCRNST,@SCRNTL,L	
	MOVI	[0FDH,450],A1
	MOVE	A1,@SCRNBR,L
	MOVI	[20H,-18H],A1
	MOVE	A1,@SCRNTL,L

	MOVE	@NPLAYERS,A10,W		;how many players are able to play
	DEC	A10
	SLL	5,A10
	MOVE	A10,@NUMBER_RACKS	;0 - 2 players ; 10h - 3 players

	SOUND1	WOOSH_SND

	DISPON
	PULLQ	A1			;now, where were we ?
	MOVE	A1,A2			;oh yeah, depending on what A1 is,
	SLL	5,A1			;jump to a specific scroll on
	ADDI	WHERE_TO_START,A1	;routine
	MOVE	*A1,A1,L
	JUMP	A1

*Which way to bring on bonus screen
*
WHERE_TO_START
	.LONG	BRING_ON_FROM_TOP
	.LONG	BRING_ON_FROM_BOT
	.LONG	BRING_ON_FROM_LEFT
	.LONG	BRING_ON_FROM_RIGHT

;**************************************************************************
;*											      *
;* Create us a universe with the horizon at the bottom of the screen	 *
;*											      *
;**************************************************************************
INIT_ZERO_UNIVERSE
	MOVIM	0FEH,@YHALF,W		;YHALF = MidScreen
	MOVIM	70000H,@ZFAR,L
	MOVIM	0H,@YWORLD,L
	CLRM	@GROUNDCOLOR,W
	CLRM	@SKYCOLOR,W
	JAUC	CALCULATE_HORIZON

;**************************************************************************
;*											      *
;* Bring the screen on from the top, do the rack up stuff and 			 *
;* then just exit the bonus screen								 *
;*											      *
;**************************************************************************
BRING_ON_FROM_TOP
	ADDI	BONUS_BGND_T,A10	;start us high
	MOVE	*A10,A10,L		;which background, 2 or 3 player ?
	CALLA	StrtBgnd		
	SLEEP	3			;on with one plane
	MOVIM	0240000H,@YSCROLL,L
	SLEEP	50			;zap us down
	CLRM	@YSCROLL,L
	SLEEP	50			;stop us moving
	JSRP	CONTINE_BONUS		;do rest of rack up
	JRUC	EXIT_BONUS		;now run away home ....

;**************************************************************************
;*											      *
;* Bring the screen on from the bottom, do the rack up stuff and 		 *
;* then do the dash board stuff. Then run home to mommy				 *
;* input -
;* A10 contains 
;*											      *
;**************************************************************************
BRING_ON_FROM_BOT
	MOVIM	07000000H,@YBASE,L	;start us high
	ADDI	BONUS_BGND_B,A10	;which background, 2 or 3 player ?
	MOVE	*A10,A10,L
	CALLA	StrtBgnd		;on with one plane
	SLEEP	3
	MOVIM	-0220000H,@YSCROLL,L	;zap us down
	SLEEP	50
	CLRM	@YSCROLL,L		;stop us moving
	JSRP	CONTINE_BONUS		;do rest of rack up
	JRUC	DO_DASH			;you're soooooo dashing !

;**************************************************************************
;*											      *
;* Bring the screen on from the right, do the rack up stuff and 		 *
;* then do the dash board stuff. Then run home to mommy				 *
;*											      *
;**************************************************************************
BRING_ON_FROM_RIGHT
	MOVIM	07000000H,@YBASE,L	;start us high
	ADDI	BONUS_BGND_R,A10	;which background, 2 or 3 player ?
	MOVE	*A10,A10,L
	CALLA	StrtBgnd		;on with one plane
	SLEEP	3			
	MOVIM	080000H,@XSCROLL,L	;zap us right
	SLEEP	50			
	CLRM	@XSCROLL,L		;stop us moving
	JSRP	CONTINE_BONUS		;do rest of rack up
	JRUC	DO_DASH			;you're soooooo dashing !

;**************************************************************************
;*											      *
;* Bring the screen on from the left, do the rack up stuff and 		 *
;* then do the dash board stuff. Then run home to mommy				 *
;*											      *
;**************************************************************************
BRING_ON_FROM_LEFT
	MOVIM	07000000H,@YBASE,L	;start us high
	ADDI	BONUS_BGND_L,A10	;which background, 2 or 3 player ?
	MOVE	*A10,A10,L
	CALLA	StrtBgnd		;on with one plane
	SLEEP	3			
	MOVIM	-080000H,@XSCROLL,L	;zap us left
	SLEEP	50			
	CLRM	@XSCROLL,L		;stop us moving
	JSRP	CONTINE_BONUS		;do rest of rack up
	JRUC	DO_DASH			;you're soooooo dashing !

;**************************************************************************
;*											      *
;* With the screen in place, start the bonus rackup					 *
;*											      *
;**************************************************************************
CONTINE_BONUS
	JSRP	HACK_IT			;put up hacking message and do SFX

	MOVI	P1DATA,A10
	CREATE	PID_ATT,SET_UP_EACH_PLAYER	;set up plyr1 for rack up

	MOVI	P2DATA,A10
	CREATE	PID_ATT,SET_UP_EACH_PLAYER	;set up plyr2 for rack up

	MOVI	P3DATA,A10
	CREATE	PID_ATT,SET_UP_EACH_PLAYER	;set up plyr3 for rack up

	MOVI	PID_BONUS,A0
	CALLA	KILLPROC_ALL

	MOVI	CHECK_ENEMIES_TABLE,A11	;grab enemy check table

NEXT_RACK
	MOVI	P1DATA,A10			;set up player1 data block
	MOVI	ENEMIES_P1,A9			;set up player1 counter
	CREATE	PID_BONUS,DO_EACH_RACKUP		;rack up enemys for plyr1

	MOVI	P2DATA,A10			;set up player2 data block
	MOVI	ENEMIES_P2,A9			;set up player2 counter
	CREATE	PID_BONUS,DO_EACH_RACKUP		;rack up enemys for plyr2

	MOVI	P3DATA,A10			;set up player3 data block
	MOVI	ENEMIES_P3,A9			;set up player3 counter
	CREATE	PID_BONUS,DO_EACH_RACKUP		;rack up enemys for plyr3

	MOVI	10000,A9
RACKUP_NOT_DONE_YET
	SLEEP	1
	DEC	A9
	JRZ	TIME_OUT_ZOOM
	MOVI	PID_BONUS,A0			;is plyr1 rack up still going ?
	CALLA	EXISTP_ALL
	JRNZ	RACKUP_NOT_DONE_YET

TIME_OUT_ZOOM
	MOVE	*A11+,A0,L			;get next enemy to check against
	MOVE	*A11+,A0,L
	MOVE	*A11+,A0,L
	MOVE	*A11,A0,L
	INC	A0				;have we reached the last enemy ?
	JRNZ	NEXT_RACK
		   
	SLEEP	40				;finished racking up sub bonuses

* GEORGE, THIS IS WHERE YOUR HOOK WILL GO

	MOVE	@P1DATA+POBJ,A1,L
	MOVE	@P2DATA+POBJ,A2,L
	MOVE	@P3DATA+POBJ,A3,L

	CLR	A4
	MOVE	A1,A1
	JRZ	CHECK_A2
	INC	A4
CHECK_A2
	MOVE	A2,A2
	JRZ	CHECK_A3
	INC	A4
CHECK_A3
	MOVE	A3,A3
	JRZ	CHECK_A4
	INC	A4
CHECK_A4
	CMPI	2,A4
	JRLT	NO_GIRL

	MOVI	P1DATA,A1,L
	MOVE	@P1DATA+PBONUSCORE,B1,L
	MOVI	P2DATA,A2,L
	MOVE	@P2DATA+PBONUSCORE,B2,L
	MOVI	P3DATA,A3,L
	MOVE	@P3DATA+PBONUSCORE,B3,L

	CMP	B1,B2
	JRLT	NO_SWITCH_B2
	MOVE	B2,B1
	MOVE	A2,A1
NO_SWITCH_B2
	CMP	B1,B3
	JRLT	NO_SWITCH_B3
	MOVE	B3,B1
	MOVE	A3,A1
NO_SWITCH_B3
	MOVE	A1,A2

	MOVE	B1,B1
	JRZ	NO_GIRL
;THIS IS THE HOOK - A2 POINTS AT GUY TO DO
;	JSRP	????

	PUSH	A11
	MOVE	A2,A11
	CREATE	PID_IND,PROC_KERRI_KISS
	PULLQ	A11

	SLEEP	100
NO_GIRL


	SOUND1	SCORE_GOES_UP

	MOVI	P1DATA,A10			;set up stuff ready for score zoom 
	MOVE	@P1DATA+PBONUSOBJ,A8,L	
	CREATE	PID_GOODIE,ZOOM_BONUS_UP	;make score zoom up
	MOVI	P2DATA,A10			;set up stuff ready for score zoom
	MOVE	@P2DATA+PBONUSOBJ,A8,L	
	CREATE	PID_GOODIE,ZOOM_BONUS_UP	;make score zoom up
	MOVI	P3DATA,A10			;set up stuff ready for score zoom
	MOVE	@P3DATA+PBONUSOBJ,A8,L	
	CREATE	PID_GOODIE,ZOOM_BONUS_UP	;make score zoom up

ZOOM_NOT_DONE_YET
	SLEEP	1
	MOVI	PID_GOODIE,A0			;has score finished zooming yet ?
	CALLA	EXISTP_ALL
	JRNZ	ZOOM_NOT_DONE_YET

	MOVE	@P1DATA+PBONUSCORE,A0,L	;add p1 total bonus to real score
	MOVE	@P1DATA+PSCORE,A1,L
	ADD	A0,A1
	MOVE	A1,@P1DATA+PSCORE,L

	MOVE	@P2DATA+PBONUSCORE,A0,L	;add p2 total bonus to real score
	MOVE	@P2DATA+PSCORE,A1,L
	ADD	A0,A1
	MOVE	A1,@P2DATA+PSCORE,L

	MOVE	@P3DATA+PBONUSCORE,A0,L	;add p3 total bonus to real score
	MOVE	@P3DATA+PSCORE,A1,L
	ADD	A0,A1
	MOVE	A1,@P3DATA+PSCORE,L

	CALLA	SCORAREA			;update score are with new score

	MOVI	OID_TEXT,A0			;kill all rack up text
	CALLA	KILOBJ_ALL
	MOVI	OID_P2TEXT,A0			;kill TOTAL BONUS text
	CALLA	KILOBJ_ALL			
	MOVI	OID_P1MOTEXT,A0			;kill TOTAL BONUS score
	CALLA	KILOBJ_ALL

	RETP

;**************************************************************************
;*											      *
;* Make bonus zoom up into score box								 *
;*											      *
;**************************************************************************
ZOOM_BONUS_UP
	MOVE	A8,A8				;if no bonus already there
	JRZ	NO_BONUS_SO_NO_WORRY		;dont delete it
	CALLA	DELETE_OBJ
	MOVE	A10,*A13(PBLK_STOR),L	;grab plyr block data address
	MOVE	*A10(PBONUSCORE),A0,L	;get bonus score from data area
	MOVE	A0,@NUM_DATA,L			;store it ready to to be displayed
	MOVI	TOTAL_NUM2,A8
	CALLA	LM_SETUP
	CALLA	BONUS_SET_X			;set player x offset
	JSRP	PRINTF
	MOVE	A2,A8				;store away the score object
	MOVI	[-5,0],A1			;set up zoom up velocity
	MOVE	A1,*A8(OYVEL),L

	MOVI	20,A11				;create 20 copies
COPY_ZOOM_OBJ
	CALLA	CREATE_MULTI_COPY		;copy score object
	PUSH	A8				;store away original score object
	MOVE	A0,A8				;move new score object into a8
	CLR	A0
	MOVE	A0,*A8(OYVEL),L			;stop new score object from moving
	CALLA	INSERT_OBJ			;insert new object
	CREATE	PID_GOODIE,KILL_SOON		;set up routine to fade and kill
	PULLQ	A8				;get pointer to original back again 
	SLEEP	2				;sleep a bit
	DSJS	A11,COPY_ZOOM_OBJ		;go create another copy

NO_BONUS_SO_NO_WORRY
	DIE

KILL_SOON					;sleep a bit and change constant
	SLEEP	3				;color so we go through gray to
	MOVI	0909H,A1			;black, then kill object
	CALLR	SET_CONST
	SLEEP	3
	MOVI	0A0AH,A1
	CALLR	SET_CONST
	SLEEP	3
	MOVI	0B0BH,A1
	CALLR	SET_CONST
	SLEEP	3
	MOVI	0C0CH,A1
	CALLR	SET_CONST
	SLEEP	3
	MOVI	0D0DH,A1
	CALLR	SET_CONST
	SLEEP	3
	CALLA	DELETE_OBJ
	DIE

SET_CONST
	MOVE	A8,A0				;set a constant color for a multi
SET_NEXT_CONST					;part object
	MOVE	A1,*A0(OCONST)
	MOVE	*A0(OPARTS),A0,L
	JRNZ	SET_NEXT_CONST
	RETS

;**************************************************************************
;*											      *
;* Do dash board bit of bonus and then exit						 *
;*											      *
;**************************************************************************
DO_DASH
	MOVI	PID_ATT,A0		;kill the process allowing someone
	CALLA	KILLPROC_ALL		;to join in at this time

;	SOUND1	WOOSH_SND		;do screen woosh on

	MOVE	@WAVE,A1		;should we put up CD ?
	.IF	DEBUG
	DEC	A1
	.ENDIF

	CMPI	2,A1			;if we aren't at the end of the 
	JRNE	AVOID_DOING_STEVE	;chopper, don't do the steve stuff

	SOUND1	WOOSH_SND		;do screen woosh on

	CLRM	@WAVES_DONE,L		;clear out which waves have been done

	MOVI	CD_INIT,B0		;create the CD
	CALLA	EASYMAKE
	MOVE	A0,A8

	MOVI	-050000H,A1		;scroll the screen and the CD on 
	MOVE	A1,*A8(OYVEL),L
	MOVI	-0220000H,A1
	MOVE	A1,@YSCROLL,L		;move us from bonus screen
	SLEEP	50			;to dash board below
	CLR	A1
	MOVE	A1,*A8(OYVEL),L
	MOVE	A1,@YSCROLL,L		;STOP !!!!
	MOVI	05C0000H,A1		;make sure screen and CD get to the
	MOVE	A1,@YBASE,L		;right spot, avoiding sleep errors
	MOVI	00DD0000H,A1
	MOVE	A1,*A8(OYVAL),L

	SLEEP	10

	SOUND1	CD_DASH_SND		;do CD slide sound

	MOVI	DISC2124,A1		;grab CD SAG
	MOVE	*A1(ISAG),A9,L
	MOVI	145*7,A11		;set up width of CD img in pixels
	MOVI	40,A10			;set up height of CD
MOVE_DISK_IN
	SLEEP	1			;add CD width to SAG
	ADD	A11,A9
	MOVE	A9,*A8(OSAG),L
	MOVE	*A8(OUSIZEY),A1		;decrement Y size so it appears to move up
	DEC	A1
	MOVE	A1,*A8(OUSIZEY)
	MOVE	A1,*A8(OSIZEY)
	DSJS	A10,MOVE_DISK_IN	;do it 40 times

	SLEEP	1
	CALLA	DELETE_OBJ		;delete the CD object

	MOVI	LEDPAL1,A8		;make LED's flash
	MOVK	1,A9
	MOVK	2,A10
	MOVK	4,A11
	CREATE	PID_DAMCC,CYCLE16

	MOVI	STEVEN_STUFF,A8		;put up steven saying "LOOKS LIKE YOU.."
	JSRP	SLAP_UP_GUYS

	JRUC	GO_TO_CHOICE		;jump to dir selection

AVOID_DOING_STEVE
	MOVE	@WAVES_DONE,A1		;have all waves been done ?

	CMPK	7,A1
	JRNE	DASH_DOODOO		;BR = All waves not selected

	MOVE	@WAVE,A14,W
	CMPK	LAST_WAVE,A14
	JRHS	EXIT_BONUS		;BR = We've done it all

DASH_DOODOO
	SOUND1	WOOSH_SND		;do screen woosh on

	MOVI	-0220000H,A1
	MOVE	A1,@YSCROLL,L		;move us from bonus screen
	SLEEP	50				;to dash board below
	CLR	A1
	MOVE	A1,@YSCROLL,L			;STOP !!!!

	MOVI	LEDPAL1,A8		;make LED's flash
	MOVK	1,A9
	MOVK	2,A10
	MOVK	4,A11
	CREATE	PID_DAMCC,CYCLE16

	CLR	A8
	MOVK	5,A1			;set up wave as though we have finished
	MOVE	@WAVES_DONE,A2		;have all waves been done ?

	CMPI	7,A2
	JREQ	WHICH_GUY_SET

GO_TO_CHOICE

	SOUND1	SND_SWEET_VOCALS

	JSRP	SLAP_UP_OBJECTIVE	;put up objectives on the screen

	MOVE	@WAVES_DONE,A1,L	;reset waves done to clear top 16 bits
	MOVE	A1,A2
	SLL	16,A2
	SRL	16,A2
	MOVE	A2,@WAVES_DONE,L
	SRL	16,A1			;this is wave selected
WHICH_GUY_SET
	SLL	6,A1
	ADDI	WHICH_WAVE_AND_GUY_TABLE-040H,A1
	MOVE	*A1+,A8,L
	MOVE	*A1+,A3

	.IF	DEBUG
	INC	A3
	.ENDIF
	MOVE	A3,@WAVE		;store us a new wave to do
	
	JSRP	SLAP_UP_GUYS		;put up which ever guy should be there

* Finish bonus / selection, lets go home
*
EXIT_BONUS
	MOVI	PID_DAMCC,A0
	CALLA	KILLPROC_ALL

	MOVI	DUXNOFADE,A0	;fade us out
	CALLA	FADEOUTF
	SLEEP	12
	CLR	A0
	CLR	A1
	CALLA	KILL_DESTRUCTIBLES	;kill background procs
	CALLA	OINIT		;kill objects
	RETP

WHICH_WAVE_AND_GUY_TABLE
	.LONG	PERRY_STUFF,2
	.LONG	BRAD_STUFF,3
	.LONG	0,0
	.LONG	KRAMER_STUFF,4		;this is where mid east guy will go
	.LONG	TOM_STUFF,5		;this is where end wave guy will go

;**************************************************************************
;*											      *
;* Put up fancy hacking images whilst hacking message displayed		 *
;*											      *
;**************************************************************************
HACK_IT
	MOVE	@BONUS_ONCE,A14,W
	JRZ	HT_DO_GEEKNESS		;BR = Haven't hooked up yet

	MOVI	ATP4_MESS,A8		;Still connected
	CALLA	LM_SETUP
	MOVK	1,A0
	JSRP	PRINTF

	JRUC	HT_LOOKUP		;Go scan the data base

HT_DO_GEEKNESS
	MOVKM	1,@BONUS_ONCE,W
	SOUND1	MODEM_SND

	MOVI	ATP_MESS,A8			;DISPLAY "HACKING..."
	CALLA	LM_SETUP
	MOVK	1,A0
	JSRP	PRINTF

	SLEEP	200				;wait for connexion

	MOVI	ATP2_MESS,A8			;we have connected !!
	CALLA	LM_SETUP
	MOVK	1,A0
	JSRP	PRINTF

	MOVI	ATP3_MESS,A8			;print up geek stuff
	CALLA	LM_SETUP
	MOVK	1,A0
	JSRP	PRINTF
HT_LOOKUP
	MOVE	@NUMBER_RACKS,A3	;are we 2 or 3	players
	ADDI	HACK_IT_TABLE,A3	;add to num of boxes table
	MOVE	*A3,A3,L		
	MOVI	P1DATA,A9		;set up for player 1

DO_NEXT_HACK
	MOVE	*A3+,A0,L		;are we at end of box table ?
	JRZ	LAST_HACK
	MOVE	A0,A8			;grabed box defintion for player
	CREATE	PID_JUNK,HACK_IT_ON	;set up box scale proc
	ADDI	PDSIZE,A9		;next player
	JRUC	DO_NEXT_HACK
LAST_HACK

	SLEEP	10
	SOUND1	HACK_DATA_SND

WAIT_LAST_HACK
	SLEEP	3
	MOVI	PID_JUNK,A0		;wait until box procs are dead
	CALLA	EXISTP_ALL		
	JRNZ	WAIT_LAST_HACK
	SLEEP	5

	MOVI	OID_TEXT,A0	    	;kill hacking message			
	CALLA	KILOBJ_ALL
	SLEEP	10
	RETP

;**************************************************************************
;*											      *
;* Stick hack box up on screen, then do cool shit with it, then		 *
;* delete it											 *
;*											      *
;**************************************************************************
HACK_IT_ON
	MOVE	A8,B0
	CALLA	EASYMAKE		;create box
	MOVE	A0,A8
	MOVE	*A8(OYVAL),A3,L		;store initial Y/X pos in storage
	MOVE	*A8(OXPOS),A4		;for use later in avoiding that 
	MOVX	A4,A3			;incredibly stupid anim point fuck up
	MOVE	A3,*A8(ODATA),L		
	MOVE	*A9(PPID),A1		;get player PID
	SLL	8,A1
	ADDI	PID_IND,A1
	MOVI	SCALE_BOX_ON,A7		;scale box up from small
	CALLA	GETPRC
	MOVE	A1,A9			;keep PID around

IS_BOX_STILL_COMING_ON_H
	SLEEP	1
	MOVE	A9,A0			;is box proc still going ?
	CALLA	EXISTP_ALL
	JRNZ	IS_BOX_STILL_COMING_ON_H

* do fancy flickering graphics for hacking database
* 
	MOVI	CHECK_ENEMIES_TABLE,A11

NEXT_HACK
	SLEEP	10

	MOVE	*A11(040H),A1,L
	JRZ	NO_HACK_BOX
	MOVE	*A1(ICMAP),A0,L
	CALLA	CHANGE_PAL

	MOVE	*A8(OCTRL),A4
	MOVE	*A1(IANIOFF),*A8(OUANIOFF),L
	CALLA	ANI
	MOVI	0100H,A9
	CALLR	RESET_DAG_FOR_SCALE

NO_HACK_BOX
	MOVE	*A11+,A0,L			;get next enemy to check against
	MOVE	*A11+,A0,L
	MOVE	*A11+,A0,L
	MOVE	*A11,A0,L
	INC	A0				;have we reached the last enemy ?
	JRNZ	NEXT_HACK

	SLEEP	10

	MOVE	A9,A1			;scale box down to small and kill it
	MOVI	SCALE_BOX_OFF,A7
	CALLA	GETPRC
	DIE

;**************************************************************************
;*											      *
;* Set up the screen for rack up									 *
;* If this player is playing then ..								 *
;* Put up TOTAL BONUS text, as well as TOTAL BONUS score				 *
;* Else												 *
;* Put up the join in message, and then wait until the player			 *
;* buys in, in which case, replace join in with stand by				 *
;*											      *
;**************************************************************************
SET_UP_EACH_PLAYER
	CLR	A8
	CLR	A9
	MOVE	A10,*A13(PBLK_STOR),L	;stor plyr block data address
	MOVE	*A10(POBJ),A6,L			;is this player playing ?
	JRZ	PUT_UP_JOIN_IN
	MOVI	TOTAL_MESS,A8			;yep, so put up TOTAL BONUS
	CALLA	LM_SETUP
	CALLA	BONUS_SET_X			;set player x offset
	JSRP	PRINTF
	MOVE	*A13(PBLK_STOR),A10,L	;grab plyr block data address
	CLR	A1
	MOVE	A1,*A10(PBONUSCORE),L	;clear out TOTAL bonus score
	MOVE	A1,@NUM_DATA,L			;also clear out num to be displayed
	MOVI	TOTAL_NUM,A8			;display total bonus score
	CALLA	LM_SETUP
	CALLA	BONUS_SET_X			;set player x offset
	JSRP	PRINTF
	MOVE	*A13(PBLK_STOR),A10,L	;grab plyr block data address
	MOVE	A2,*A10(PBONUSOBJ),L		;store Total bonus score obj 
	DIE

;**************************************************************************
;*											      *
;* Display the join in message, whilst waiting to put				 *
;* up the stand by message									 *
;*											      *
;**************************************************************************
PUT_UP_JOIN_IN
	MOVI	JOIN_IN_MESS,A6			;Set up press start mess
	CALLA	CR_STRTP
	JRHS	JOIN_IN_MESS_RIGHT		;have we credits enuff ?
	MOVI	COIN_IN_MESS,A6			;set up insert coin mess
JOIN_IN_MESS_RIGHT
	PUSH	A6				;save mess type
	CMP	A6,A9
	JREQ	NO_NEW_MESS			;is it same as last mess ?
	MOVE	A8,A8				;no, can we delete last mess
	JRZ	NO_MESS_TO_DELETE
	CALLA	DELETE_OBJ			;yes, delete last mess
NO_MESS_TO_DELETE
	CLR	A2
	MOVE	A6,A8				;set up join in mess
	CALLA	LM_SETUP
	CALLA	BONUS_SET_X			;set player x offset
	JSRP	PRINTF
	MOVE	*A13(PBLK_STOR),A10,L	;grab plyr block data address
	MOVE	A2,A8				;keep join in mess obj around
NO_NEW_MESS
	PULLQ	A9				;restore this tick mess
WAIT_FOR_PLAYER_ENTRY
	SLEEP	1
	MOVE	*A10(PENTER),A1			;has player bought in ?
	JRZ	PUT_UP_JOIN_IN
	CALLA	DELETE_OBJ			;delete join in mess
	MOVI	STAND_BY_MESS,A8		;stick up stand by mess
	CALLA	LM_SETUP
	CALLA	BONUS_SET_X			;set player x offset
	JSRP	PRINTF
	DIE

;**************************************************************************
;*											      *
;* Do the actual racking up for each enemy and/or damage 				 *
;* and/or casualties										 *
;*											      *
;**************************************************************************
DO_EACH_RACKUP
	MOVE	A10,*A13(PBLK_STOR),L	;stor plyr block data address
	CLR	A1
	MOVE	A1,*A10(PBONUSYNCH)		;clear out plyr synch bits in case
	MOVE	*A10(POBJ),A6,L			;is this player playing ?
	JRZ	THIS_GUY_NOT_PLAYING

	MOVK	1,A1				;yes, so set synch bit so other
	MOVE	A1,*A10(PBONUSYNCH)		;plyr procs will wait for us

	MOVE	*A11(020H),A1,L			;get type of rack up routine
	JUMP	A1				;from enemy check table

;**************************************************************************
;*											      *
;* Normal rack up with number wiped out, % accuracy, and bonus			 *
;*											      *
;**************************************************************************
DISPLAY_NORMAL_RACK
	MOVE	*A11,A0,L			;grab enemy table offset
	MOVE	A0,A1				;from enemy check table

	ADD	A9,A1				;add player counter table to offset
	MOVE	*A1,A1				;and get number killed from table
	MOVE	A1,@NUM_DATA,L

	ADDI	ENEMIES_TOTAL,A0		;add enemy total counter to offset
	MOVE	*A0,A0				;and get number of enemies spawned
	JRZ	THIS_GUY_NOT_PLAYING		;if none, then this rackup is OVER

	MOVE	*A11(040H),A6,L			;get box image from enemies table 
	PUSH	A6				;save for later

	CALLR	GETPERCENT			;figure out what % player hit
	MOVE	A1,@NUM_DATA_2,L

	MOVI	STAT0_MESS,A8			;put up number wiped out
	CALLA	LM_SETUP
	CALLA	BONUS_SET_X			;set player x offset
	JSRP	PRINTF

	MOVI	STAT1_MESS,A8			;put up % hit
	CALLA	LM_SETUP
	CALLA	BONUS_SET_X			;set player x offset
	JSRP	PRINTF

	MOVE	@NUM_DATA,A1			;bonus = number hit * 1000
	MOVI	01000,A3
	MPYU	A1,A3
	MOVE	A3,@NUM_DATA_3,L

	MOVI	STAT2_MESS,A8			;put up bonus number
	CALLA	LM_SETUP
	CALLA	BONUS_SET_X			;set player x offset
	JSRP	PRINTF
	JRUC	CONTINUE_THIS_RACK

;**************************************************************************
;*											      *
;* Rescued rack up with number rescued, % accuracy, and bonus			 *
;*											      *
;**************************************************************************
DISPLAY_RESCUE_RACK
	MOVE	@WAVE,A10			;if playing from club to heli, miss this
	.IF DEBUG
	DEC	A10				;counter debug thing
	.ENDIF
	CMPK	2,A10				;are we at roof in wave 1 ?
	JREQ	THIS_GUY_NOT_PLAYING

	MOVE	*A11(040H),A6,L			;get box image from enemies table 
	PUSH	A6				;save for later

	MOVE	*A13(PBLK_STOR),A10,L	;grab plyr block data address
	MOVE	*A10(PGIRLS_SAVED),A1	;get no of babes player rescued
	MOVE	A1,@NUM_DATA,L

	MOVI	STAT0A_MESS,A8			;put up number wiped out
	CALLA	LM_SETUP
	CALLA	BONUS_SET_X			;set player x offset
	JSRP	PRINTF

	MOVE	@NUM_DATA,A1			;bonus = number hit * 1000
	MOVI	010000,A3
	MPYU	A1,A3
	MOVE	A3,@NUM_DATA_3,L

	MOVI	STAT2_MESS,A8			;put up bonus number
	CALLA	LM_SETUP
	CALLA	BONUS_SET_X			;set player x offset
	JSRP	PRINTF
	JRUC	CONTINUE_THIS_RACK

;**************************************************************************
;*											      *
;* WINGS rack up with wings earned			                          *
;*											      *
;**************************************************************************
DISPLAY_WINGS_RACK

	MOVE	*A13(PBLK_STOR),A10,L	;grab plyr block data address
	MOVE	*A10(PWINGS),A9
	JRZ	NO_WINGS_EARNED

	MOVI	WINGS_MESS,A8			;put up number wiped out
	CALLA	LM_SETUP
	CALLA	BONUS_SET_X			;set player x offset
	JSRP	PRINTF

	MOVI	WING_BONUS_MESS_2,A8			;put up number wiped out
	CALLA	LM_SETUP
	CALLA	BONUS_SET_X			;set player x offset
	JSRP	PRINTF

	MOVE	*A13(PBLK_STOR),A10,L	;grab plyr block data address

	MOVE	*A10(PBONUSCORE),A11,L	;grab bonus score ready for multiplying
	CLR	A1
	MOVE	A1,*A10(PBONUSCORE)		;clear out number of wings earned
	CLR	A8				;no wings earned yet

	MOVE	*A10(PWINGS),A9
	INC	A9
DISPLAY_NEXT_WING
	MMTM	A12,A9,A11			;store away registers to be corrupted

	MOVE	A8,A8
	JRZ	IGNORE_WING_DELETE
	CALLA	DELETE_OBJ			;delete bonus multiplier object
IGNORE_WING_DELETE

	MOVE	*A13(PBLK_STOR),A10,L	;grab plyr block data address
	MOVE	*A10(PBONUSCORE),A2		;have to use bonus score as storage
	INC	A2				;for number of wings earned cos we got
	MOVE	A2,*A10(PBONUSCORE)		;nothing else to use 
	MOVE	A2,@NUM_DATA_2,L
	DEC	A2
	JRZ	NO_WINGS_DISPLAYED		;no wings on screen yet
	MOVI	AERO_WINGS_INIT,B0
	CALLA	EASYMAKE
	SLL	5,A2
	ADDI	WINGPOS_TABLE-20H,A2
	MOVE	*A2,A9,L
	CALLR	BONUS_SET_X
	MOVE	A9,*A0(ODAG),L
	MOVE	A9,*A0(OXPOS)
	SRL	16,A9
	MOVE	A9,*A0(OYPOS)
	MOVI	02000200H,A1
	MOVE	A1,*A0(OSCALE),L

	MOVI	6000H,A1
	MOVE	A1,*A0(OZVAL),L

NO_WINGS_DISPLAYED
	MOVE	@NUM_DATA_2,A1			;increment number of wings earned

	MPYU	A11,A1				;multiply bonus score by wings earned
	MOVE	A1,@NUM_DATA,L
	MOVE	*A13(PBLK_STOR),A10,L	;grab plyr block data address
	MOVE	*A10(PBONUSOBJ),A8,L
	CALLA	DELETE_OBJ			;delete bonus total number object

	MOVI	TOTAL_NUM,A8			;put up bonus number
	CALLA	LM_SETUP
	CALLA	BONUS_SET_X			;set player x offset
	JSRP	PRINTF
	MOVE	*A13(PBLK_STOR),A10,L	;grab plyr block data address
	MOVE	A2,*A10(PBONUSOBJ),L

	MOVE	A2,A8				;put up a box around the bonus score
	MOVI	[6,6],A4
	MOVI	COLOR_WHITE,A7
	CALLR	JAKE_BOX
	MOVE	A6,A8
	CREATE	PID_JUNK,KILL_BOX_SOON	;set up routine to kill highlite box

	SOUND1	SCORE_MUL_SND

	MOVI	WING_BONUS_MESS,A8		;put up bonus number
	CALLA	LM_SETUP
	CALLA	BONUS_SET_X			;set player x offset
	JSRP	PRINTF
	MOVE	A2,A8				;store away bonus multiplyer object

	MOVE	@NUM_DATA,A10,L
	SLEEP	50
	MMFM	A12,A9,A11			;recover registers corrupted by print
	DEC	A9
	JRNZ	DISPLAY_NEXT_WING		;more wings earned ?

	MOVE	A10,A1
	MOVE	*A13(PBLK_STOR),A10,L	;grab plyr block data address
	MOVE	A1,*A10(PBONUSCORE),L	;store new bonus in bonus total
	CLR	A8
	MOVE	A8,@P1DATA+PBONUS_STOR,L
	MOVE	A8,@P2DATA+PBONUS_STOR,L
	MOVE	A8,@P3DATA+PBONUS_STOR,L
	JRUC	UPDATING_SCORE_DONE		;bypass normal rackup 

KILL_BOX_SOON
	SLEEP	20				;kill hilite box after 15 tixs
	CALLA	DELETE_OBJ
	DIE

WINGPOS_TABLE
	.LONG	[80,20]
	.LONG	[80,74]
	.LONG	[105,46]
	.LONG	[130,20]
	.LONG	[130,74]

NO_WINGS_EARNED
	MOVI	NO_WING_BONUS_MESS,A8		;put up bonus number
	CALLA	LM_SETUP
	CALLA	BONUS_SET_X			;set player x offset
	JSRP	PRINTF
	SLEEP	40				;kill hilite box after 15 tixs
	CLR	A8
	MOVE	A8,@P1DATA+PBONUS_STOR,L
	MOVE	A8,@P2DATA+PBONUS_STOR,L
	MOVE	A8,@P3DATA+PBONUS_STOR,L
	MOVE	*A13(PBLK_STOR),A10,L	;grab plyr block data address
	JRUC	UPDATING_SCORE_DONE		;bypass normal rackup 


;**************************************************************************
;*											      *
;* Casualty bonus, if no casualties then say so, otherwise			 *
;* set up -bonus											 *
;*											      *
;**************************************************************************
DISPLAY_CASUALTIES

	MOVE	*A11(040H),A6,L			;get box image from enemies table 
	PUSH	A6				;save for later

	MOVE	*A13(PBLK_STOR),A10,L	;grab plyr block data address
	MOVE	*A10(PCASUALTY),A1		;get player casualties
	MOVE	A1,@NUM_DATA,L
	JRZ	NO_CASUALTIES			;did we actaully kill anyone ?

	MOVI	HC_MESS,A8			;display number of dead un's
	CALLA	LM_SETUP
	CALLA	BONUS_SET_X			;set player x offset
	JSRP	PRINTF

	MOVI	HUMAN_MESS,A8			;display WE GOT DEAD UN's
	CALLA	LM_SETUP
	CALLA	BONUS_SET_X			;set player x offset
	JSRP	PRINTF

	MOVE	@NUM_DATA,A1,L			;-bonus = casualties * 50000
	MOVI	050000,A3
	MPYU	A3,A1
	NEG	A1
	MOVE	A1,@NUM_DATA_3,L		;stored in bonus var

	MOVI	PEN_MESS,A8
	CALLA	LM_SETUP
	CALLA	BONUS_SET_X			;set player x offset
	JSRP	PRINTF
	JRUC	CONTINUE_THIS_RACK

NO_CASUALTIES
	CLRM	@NUM_DATA_3,L			;clear out bonus var
	MOVI	HC_MESS,A8			;put up NO CASUALTIES mess
	CALLA	LM_SETUP
	CALLA	BONUS_SET_X			;set player x offset
	MOVI	NOHCSTR,A8
	JSRP	PRINTF
	JRUC	CONTINUE_THIS_RACK

;**************************************************************************
;*											      *
;* Damage rackup											 *
;*											      *
;**************************************************************************
DISPLAY_DAMAGE_RACK

	MOVE	*A11(040H),A6,L			;get box image from enemies table 
	PUSH	A6				;save for later

	MOVE	*A13(PBLK_STOR),A10,L	;grab plyr block data address
	MOVE	*A10(PDAMAGE),A1		;grab plyr damage
	MOVI	01000,A3			;times by 100000
	MPYU	A3,A1				;and store in bonus
	MOVE	A1,@NUM_DATA_3,L
	MOVI	DAM_MESS,A8
	CALLA	LM_SETUP
	CALLA	BONUS_SET_X			;set player x offset
	JSRP	PRINTF
	JRUC	CONTINUE_THIS_RACK

;**************************************************************************
;*											      *
;* Mammys rackup											 *
;*											      *
;**************************************************************************
DISPLAY_MAMMYS_RACK

	MOVE	*A11(040H),A6,L			;get box image from enemies table 
	PUSH	A6				;save for later

	MOVE	*A13(PBLK_STOR),A10,L	;grab plyr block data address
;	MOVK	2,A1
	MOVE	*A10(PMAMMY),A1			;grab plyr mammys
	MOVI	050000,A3			;times by 100000
	MPYU	A3,A1				;and store in bonus
	MOVE	A1,@NUM_DATA_3,L
	MOVI	MAM_MESS,A8
	CALLA	LM_SETUP
	CALLA	BONUS_SET_X			;set player x offset
	JSRP	PRINTF

;**************************************************************************
;*											      *
;* Now that the rack up info has been displayed, put up the info box	 *
;* and add the bonus to the TOTAL BONUS score						 *
;*											      *
;**************************************************************************
CONTINUE_THIS_RACK
	MOVE	*A13(PBLK_STOR),A10,L	;grab plyr block data address

	MOVE	@NUMBER_RACKS,A6		;are we 2 or 3 players ?
	MOVE	A10,A2
	CALLA	GPLAYNUM			;which player are we ?
	SLL	6,A0
	ADD	A6,A0				;work out which box going where
	ADDI	WHAT_WHERE_BOX,A0		;based on player number and
	MOVE	*A0,A0,L			;total number of players
	MOVE	A0,B0

	CALLA	EASYMAKE			;create relevant info box
	MOVE	A0,A8

	MOVE	*A8(OYVAL),A3,L			;store it a little higher than norm
	SUBI	[0104,0],A3
	MOVE	A3,*A8(OYVAL),L
	MOVE	*A8(OXPOS),A4			;store initial Y/X pos in storage
	MOVX	A4,A3				;for use later in avoiding that 
	MOVE	A3,*A8(ODATA),L			;incredibly stupid anim point fuck up

	PULLQ	A1
	MOVE	*A1(ICMAP),A0,L			;change pallette on new info box
	CALLA	CHANGE_PAL

	MOVE	*A8(OCTRL),A4
	MOVE	*A1(IANIOFF),*A8(OUANIOFF),L
	CALLA	ANI
	MOVI	0100H,A9
	CALLR	RESET_DAG_FOR_SCALE

	MOVE	*A10(PPID),A1
	SLL	8,A1
	ADDI	PID_IND,A1			;create scale box up proc
	MOVI	SCALE_BOX_ON,A7
	CALLA	GETPRC
	MOVE	A1,A9

	MOVE	@NUM_DATA_3,A11,L		;pick up bonus score from info disp.

IS_BOX_STILL_COMING_ON
	SLEEP	1
	MOVE	A9,A0				;has box finished appearing yet ?
	CALLA	EXISTP_ALL
	JRNZ	IS_BOX_STILL_COMING_ON

	MOVE	A11,A11				;is there any bonus to add to TOTAL ?
	JRNZ	WE_HAVE_UPDATING_TO_DO
	MOVE	A11,*A10(PBONUS_STOR),L

	SLEEP	50				;nope, so just hang around a while
	JRUC	UPDATING_SCORE_DONE		;cos we lookin' at NO CASUALTIES !

WE_HAVE_UPDATING_TO_DO

	SLEEP	30

	MOVI	1000,A9	      		;heres what we increment Total by
	CMPI	1000000,A11     	;if bonus > 1000000 then.....
	JRLT	INC_NUMBER_SET
	MOVI	10000,A9		;make increment 10000
INC_NUMBER_SET

	MOVI	RACKUP_SND,A0		;set up rackup sound
	MOVE	A11,A11			;if bonus is - then make increment -
	JRNN	WAIT_FOR_UPDATING
	MOVI	RACKDOWN_SND,A0		;make rackdown sound
	NEG	A9

WAIT_FOR_UPDATING
	CALLA ONESND			;do the rack sound
	SLEEP	10			;give it time to start
	MOVE	A11,*A10(PBONUS_STOR),L

KEEP_UPDATING

	MMTM	SP,A9,A8,A11		;store box obj so we dont lose it
	MOVE	*A10(PBONUSOBJ),A8,L
	CALLA	DELETE_OBJ

	MOVE	*A10(PBONUSCORE),A0,L
	ADD	A9,A0			;add increment to score
	JRNN	NO_ZERO_WORRIES
	CLR	A0			;cant be less than 0 !
NO_ZERO_WORRIES
	MOVE	A0,*A10(PBONUSCORE),L
	MOVE	A0,@NUM_DATA,L
	MOVI	TOTAL_NUM,A8
	CALLA	LM_SETUP
	CALLA	BONUS_SET_X			;set player x offset
	JSRP	PRINTF
	MMFM	SP,A9,A8,A11	   ;get store object back in A8

	MOVE	*A13(PBLK_STOR),A10,L	;grab plyr block data address
	MOVE	A2,*A10(PBONUSOBJ),L

	SUB	A9,A11			   ;sub increment from bonus
	JRZ	UPDATING_SCORE_DONE	   ;are we at zero yet ?

	CMPI	10000,A9
	JRNE	MORE_UPDATING
	CMPI	10000,A11
	JRGE	MORE_UPDATING
	MOVI	1000,A9
MORE_UPDATING
	SLEEP	1
	JRUC	KEEP_UPDATING

UPDATING_SCORE_DONE

	CLR	A1				;since we are done updating
	MOVE	A1,*A10(PBONUSYNCH)		;bonus, let others know

OTHERS_NOT_DONE
	SLEEP	1
	MOVE	@P1DATA+PBONUSYNCH,A1	;has plyr1 finished updating bonus
	MOVE	@P2DATA+PBONUSYNCH,A2	;has plyr2 finished updating bonus
	MOVE	@P3DATA+PBONUSYNCH,A3	;has plyr3 finished updating bonus
	OR	A1,A2				;is anyone still updating bonus ?
	OR	A2,A3
	JRNZ	OTHERS_NOT_DONE

	MOVI	STOP_RACKUP_SND,A0		;set up rackup sound
	MOVE	A11,A11			;if bonus is - then make increment -
	JRNN	STOP_RACK_SOUND
	MOVI	STOP_RACKDOWN_SND,A0		;make rackdown sound

STOP_RACK_SOUND
	CALLA ONESND			;do the rack sound

	MOVI	PBOMBPID,A0
	CALLA	EXISTP_ALL
	JRNZ	FLASHING_X_GOING
	CREATE	PBOMBPID,FLASH_X

FLASHING_X_GOING
	SLEEP	30

	MOVE	A8,A8				;is this rackup one with no box
	JRZ	NO_BOX_FOR_RACKUP

	MOVE	A9,A1				;we are all done, so scale
	MOVI	SCALE_BOX_OFF,A7		;info box off screen
	CALLA	GETPRC

IS_BOX_STILL_COMING_OFF
	SLEEP	1
	MOVE	A9,A0
	CALLA	EXISTP_ALL			;has box proc finished yet ?
	JRNZ	IS_BOX_STILL_COMING_OFF

NO_BOX_FOR_RACKUP

	MOVI	OID_P1TEXT,A0		;yes, so kill rackup text
	CALLA	KILOBJ_ALL
THIS_GUY_NOT_PLAYING
	DIE

;**************************************************************************
;*											      *
;* Make big X in bakground flash for whoever got most bonus			 *
;*											      *
;**************************************************************************
FLASH_X
	CLR	A1
	CLR	A2
	CLR	A3
	CLR	A4
	CLR	A5
	CLR	A6
	MOVE	@P1DATA+POBJ,A0,L
	JRZ	NO_FLASH_X_1
	MOVE	@P1DATA+PBONUS_STOR,A1,L
	JRZ	NO_FLASH_X_1
	MOVI	XREGP1r,A4
NO_FLASH_X_1
	MOVE	@P2DATA+POBJ,A0,L
	JRZ	NO_FLASH_X_2
	MOVE	@P2DATA+PBONUS_STOR,A2,L
	JRZ	NO_FLASH_X_2
	MOVI	XREGP2y,A5
NO_FLASH_X_2
	MOVE	@P3DATA+POBJ,A0,L
	JRZ	NO_FLASH_X_3
	MOVE	@P3DATA+PBONUS_STOR,A3,L
	JRZ	NO_FLASH_X_3
	MOVI	XREGP3b,A6
NO_FLASH_X_3
	MOVE	@NUMBER_RACKS,A7	;are we playing 2 or 3 players ?
	JRNZ	WE_HAVE_3
	CLR	A3
	CLR	A6
	MOVE	A5,A5
	JRZ	WE_HAVE_3
	MOVI	XREGP3b,A5
WE_HAVE_3
	CMP	A1,A2
	JRLT	P1_BIGGEST
	JREQ	P1_P2_SAME
	MOVE	A2,A1
	MOVE	A5,A4
P1_BIGGEST
	CLR	A5
P1_P2_SAME
	CMP	A1,A3
	JRLT	P1A_BIGGEST
	JREQ	P1_P3_SAME
	MOVE	A3,A1
	MOVE	A6,A4
P1A_BIGGEST
	CLR	A6
P1_P3_SAME
	MOVE	A4,A8
	JRZ	NO_FLASH_PAL_1
	CREATE	PINITIALPID,FLASH_THAT_PAL
NO_FLASH_PAL_1
	MOVE	A5,A8
	JRZ	NO_FLASH_PAL_2
	CREATE	PINITIALPID,FLASH_THAT_PAL
NO_FLASH_PAL_2
	MOVE	A6,A8
	JRZ	NO_FLASH_PAL_3
	CREATE	PINITIALPID,FLASH_THAT_PAL
NO_FLASH_PAL_3
	DIE


FLASH_THAT_PAL
	MOVE	A8,A0
	CALLA	GO_WHITE
	SLEEP	6
	MOVE	A8,A0
	CALLA	GO_NORMAL
	SLEEP	6
	MOVE	A8,A0
	CALLA	GO_WHITE
	SLEEP	6
	MOVE	A8,A0
	CALLA	GO_NORMAL
	SLEEP	6
	MOVE	A8,A0
	CALLA	GO_WHITE
	SLEEP	6
	MOVE	A8,A0
	CALLA	GO_NORMAL
	DIE

;**************************************************************************
;*											      *
;* Scale box onto screen from small to 100%						 *
;*											      *
;**************************************************************************
SCALE_BOX_ON
	MOVI 	05000500H,A9		;start scale
	MOVI	00800080H,A10		;increment
	MOVI	01000100H,A11		;limit small
ZAP_BOX_UP
	MOVE	A9,*A8(OSCALE),L
	CALLR	RESET_DAG_FOR_SCALE	;redo dag to avoid anim point fuck up
	SLEEP	1
	SUB	A10,A9			;subtract increment
	CMPXY	A11,A9
	JRXGT	ZAP_BOX_UP		;have we reached limit ?
	MOVE	A11,*A8(OSCALE),L
	MOVE	A11,A9
	CALLR	RESET_DAG_FOR_SCALE	;redo dag to avoid anim point fuck up
	DIE

;**************************************************************************
;*											      *
;* Scale box off screen from 100% to small							 *
;*											      *
;**************************************************************************
SCALE_BOX_OFF
	MOVI 	01000100H,A9		;start scale
	MOVI	00800080H,A10		;increment
	MOVI	05000500H,A11		;limit large
ZAP_BOX_DOWN
	MOVE	A9,*A8(OSCALE),L
	CALLR	RESET_DAG_FOR_SCALE	;redo dag to avoid anim point fuck up
	SLEEP	1
	ADD	A10,A9			;add increment
	CMPXY	A11,A9
	JRXLT	ZAP_BOX_DOWN		;have we reached limit
	CALLA	DELETE_OBJ		;kill box object
	DIE

;**************************************************************************
;*											      *
;* Get X position offset for player and add it message X pos			 *
;*											      *
;**************************************************************************
BONUS_SET_X
	MMTM	SP,A0,A1,A2
	MOVE	*A13(PBLK_STOR),A2,L	;grab plyr block data address
	CALLA	GPLAYNUM	;get player number
	SLL	4,A0		;use it as offset into x offset table
	MOVE	@NUMBER_RACKS,A1	;are we playing 2 or 3 players ?
	JRZ	SET_X_FOR_2
	ADDI	BONUS_3_X_OFFSET,A0	;ahhh... 3 players
	JRUC	OFFSET_X_SET
SET_X_FOR_2
	ADDI	BONUS_2_X_OFFSET,A0	;hmmmm... 2 players
OFFSET_X_SET
	MOVE	*A0,A0			;grab x offset from table
	ADDXY	A0,A9			;add it to message x value
	MMFM	SP,A0,A1,A2
	RETS

;**************************************************************************
;*											      *
;* When scaling a screen rel object with animation points,			 *
;* Use this routine to place it on screen.							 *
;*  - Assumes real Y/X position stored in object ODATA long word		 *
;*											      *
;**************************************************************************
RESET_DAG_FOR_SCALE
	MOVE	*A8(OUSIZE),A5,L	;Unscaled size in a1
	MOVE	*A8(OUANIOFF),A1,L	;Unscaled animation pnt in A1

	CLR	A7
	MOVX	A9,A7
	MOVI	10000H,A3		; for inverse scale computation
	DIVU	A7,A3	  		;Inverse of scale in a3

	SETF	12,1,1		; change FS1 to quicken multiplies
	CLR	A7
	MOVX	A5,A7
	MPYU	A3,A7		  ; result in a11
	SRL	8,A7
	SRL	8,A5
	MPYU	A3,A5
	MOVX	A7,A5

	MOVE	A1,A7
	SEXT	A7
	MPYS	A3,A7		  ; result in a11
	SRA	8,A7
	SRA	16,A1
	MPYS	A3,A1

	SLL	8,A1
	MOVX	A7,A1
	SETF	32,0,1		; restore FS1	 !!!
	MOVE	A1,*A8(OANIOFF),L
	MOVE	A5,*A8(OSIZE),L

	MOVE	*A8(ODATA),A3,L		;grab real Y/X pos from storage

	SUBXY	A1,A3			;subtract new anioff from real Y/X
	MOVE	A3,*A8(ODAG),L

	MOVY	A3,A4

	MOVE	A4,*A8(OYVAL),L		;store away in YPOS & XPOS for Veladd
	MOVE	A3,*A8(OXPOS)		;to use as DAG
	RETS

**************************************************
*							 *
*  GETPERCENT						 *
* 							 *
*  RETURNS INTEGER PORTION OF A PERCENTAGE		 *
*							 *
*							 *
*  IN:  A0, DIVISOR					 *
*	A1, DIVIDEND					 *
*							 *
*  OUT: A1, INTEGER PERCENT				 *
*							 *
**************************************************
GETPERCENT
	MOVI	100,A14		; total * 100
	MPYU	A14,A1		;-------------
	DIVU	A0,A1		;  number shot
	RETS			

*x offset tables
*
BONUS_3_X_OFFSET
	.WORD	0
	.WORD	138
	.WORD	271

BONUS_2_X_OFFSET
	.WORD	0
	.WORD	271
	.WORD	-138


;**************************************************************************
;*											      *
;* Do the where you go is up to you sound call						 *
;*											      *
;**************************************************************************
CALL_WHERE
	SOUND1	WHERE_YOU_GO
	RETS

CALL_MAGGOTS
	SOUND1	MAGGOTS_SND
	RETS

CALL_KEMMITECH
	SOUND1	KEMMITECH
	RETS

CALL_TEAR_DOWN_THE_WALL
	SOUND1	TEAR_DOWN_THE_WALL
	RETS

CALL_STOP_THE_BUS
	SOUND1	STOP_THE_BUS
	RETS

;**************************************************************************
;*											      *
;* Put up the direction select stuff on the screen, turn on the		 *
;* guns and wait for a direction to go in							 *
;*											      *
;**************************************************************************
SLAP_UP_OBJECTIVE
	MOVI	OBJECTIVE_TEXT_INIT,A10		;get the cd text going
	CREATE	PID_JUNK,DISPLAY_DASH_TEXT
	SLEEP	30
	CREATE	PID_JUNK,DISPLAY_CD_TIME		;start the cd timer going


;	MOVI	WAVEOFF_P,A0		;get non selectable obj pal
;	CALLA	GETFPAL
;
;	MOVI	WAVEOFF_P,A8		;make X inside obj col cycle
;	MOVK	1,A9
;	MOVK	7,A10
;	MOVK	4,A11
;	CREATE	PID_DAMCC,CYCLE16


	MOVI	DEST1A_INIT,B0				;put up "USE GUNS" text
	CALLA	MULTIMAKE
	MOVE	*A0(OPART1),A11,L			;store object for later
*THIS IS TO FIX SOMETHING THAT BLOODY MULTIMAKE SHOULD DO IN THE FIRST
*FUCKING PLACE ! INFACT IT THINKS IT DOES DO IT, ONLY ITS F*U*L*L O*F
*B*U*G*S !!!!!
	MOVI	37H,A0
	MOVE	A0,*A11(OYPOS)
	MOVI	88H,A0
	MOVE	A0,*A11(OXPOS)
	MOVI	[37H,88H],A0
	MOVE	A0,*A11(ODAG),L
	MOVE	*A11(OPARTS),A14,L
	MOVI	85H,A0
	MOVE	A0,*A14(OYPOS)
	MOVI	82H,A0
	MOVE	A0,*A14(OXPOS)
	MOVI	[85H,82H],A0
	MOVE	A0,*A14(ODAG),L

	MOVE	@WAVES_DONE,A10		;get which waves are already done
	MOVI	DEST2A_INIT,B0		;set up amazon as shootable object
	SRL	1,A10			;has amazon been done ?
	JRNC	DEST2_SET
	MOVI	DEST2B_INIT,B0		;yes so set wave as unshootable 
DEST2_SET
	CALLA	EASYMAKE
	MOVK	1,A1			;set which wave this object is
	MOVE	A1,*A0(OVAR9)
	MOVI	303H,A1
	MOVE	A1,*A0(OCONST)		;set up const ready for flashing
	MOVE	A0,A8			;store object for later

	MOVI	DEST3A_INIT,B0		;set up japan as shootable object
	SRL	1,A10			;has japan been done ?
	JRNC	DEST3_SET
	MOVI	DEST3B_INIT,B0		;yes so set wave as unshootable 
DEST3_SET
	CALLA	EASYMAKE
	MOVK	2,A1			;set which wave this object is
	MOVE	A1,*A0(OVAR9)
	MOVI	303H,A1
	MOVE	A1,*A0(OCONST)		;set up const ready for flashing
	MOVE	A0,A9			;store object for later

	MOVI	DEST4A_INIT,B0		;set up mid east as shootable object
	SRL	1,A10			;has mid east been done ?
	JRNC	DEST4_SET
	MOVI	DEST4B_INIT,B0		;yes so set wave as unshootable 
DEST4_SET
	CALLA	EASYMAKE
	MOVK	4,A1			;set which wave this object is
	MOVE	A1,*A0(OVAR9)
	MOVI	303H,A1
	MOVE	A1,*A0(OCONST)		;set up const ready for flashing
	MOVE	A0,A10			;store object for later

	MMTM	SP,A8,A9,A10,A11	;save object pointers, just incase
	MOVIM	INBONUS,@GAME_STATE,W	;\
	CREATEP	PID_CURSOR,PLAYER_CURSOR; - CAUTION: NO SLEEPING DURING THESE.
	ALLPLYR	PLAYER_BONUS_RESTART	;/
	MMFM	SP,A8,A9,A10,A11	;get object pointers back

	SLEEP	50

	CLR	A1
	MOVE	A1,@GUNS_OFF,W		;turn guns on
	MOVE	A1,@DIR_SELECTED,L	;set up wave selected as nothing
	MMTM	A12,A11			;save object pointer cos we need a11
	MOVI	1000,A11 		;set up time out 
NO_CHOICE_MADE
	SLEEP	1
	DEC	A11			;decrement time out
	JRNZ	NOT_TIMED_OUT_YET	;timed out yet ?
	CALLR	GET_OUR_OWN_DIR		;yes, so get a dir anyway
NOT_TIMED_OUT_YET
	MOVE	@DIR_SELECTED,A6,L	;wait for wave object to be shot
	JRZ	NO_CHOICE_MADE
	MMFM	A12,A11			;retrieve a11 again

	MMTM	SP,A8,A9,A10,A11	;save object pointers, just incase

	MOVIM	1,@GUNS_OFF,W		;turn off guns
	MOVIM	INGAME,@GAME_STATE,W	;set game state back to in game

	MOVI	PID_CURSOR,A0
	CALLA	KILLPROC_ALL		;KILL THE CURSOR DOOLIES

	ALLPLYR	CURSOR_OFF		;turnoff the cursors

	SOUND1	SND_DIR_CHOSEN		;sound it !

	MMFM	SP,A8,A9,A10,A11	;get object pointers back

	MOVE	*A6(OVAR9),A5		;get from wave object shot, which wave it is
	MOVE	@WAVES_DONE,A1,L	;put it in waves done for next time
	OR	A5,A1
	SLL	16,A5			;also store it alone in top bits of wave done
	OR	A5,A1
	MOVE	A1,@WAVES_DONE,L

	CMP	A6,A8			;is object shot amazon ?
	JREQ	NO_DELETE_MISSION_1
	CALLA	DELETE_OBJ		;no, so delete this wave option
NO_DELETE_MISSION_1
	CMP	A6,A9			;is object shot japan ?
	JREQ	NO_DELETE_MISSION_2
	MOVE	A9,A8			;no, so delete this wave option
	CALLA	DELETE_OBJ
NO_DELETE_MISSION_2
	CMP	A6,A10			;is object shot mid east ?
	JREQ	NO_DELETE_MISSION_3
	MOVE	A10,A8			;no, so delete this wave option
	CALLA	DELETE_OBJ
NO_DELETE_MISSION_3

	MOVE	A11,A8			;delete USE GUNS text
	CALLA	DELETE_OBJ

	MOVE	A6,A8			;make box flash around wave object selected
	MOVK	4,A9
	CREATE	PID_DAMCC,FLASH_BOX
	MOVE	A0,A8

	SLEEP	70			;sleep, then kill flashing box routine
	MOVE	A8,A0
	CALLA	KILL

	MOVI	OID_P2MOTEXT,A0		;kill all outstanding text
	MOVI	-1,A1
	CALLR	BKILOBJ

	MOVI	OID_P1MOTEXT,A0		;kill dash text and cd timer
	MOVI	-1,A1
	CALLR	BKILOBJ

	SLEEP	10
	RETP

;**************************************************************************
;*											      *
;* Get what ever direction is first free							 *
;*											      *
;**************************************************************************
GET_OUR_OWN_DIR
	MOVE	A8,A6		;set up amazon as selection
	CALLR	IS_DIR_VALID	;has it already been done ?
	JRZ	DIR_GOT		
	MOVE	A9,A6		;set up kemmitech as selection
	CALLR	IS_DIR_VALID	;has it already been done ?
	JRZ	DIR_GOT
	MOVE	A10,A6		;set up mid east as selection
DIR_GOT				
	MOVE	A6,@DIR_SELECTED,L	;set up new selection
	RETS

IS_DIR_VALID
	MOVE	*A6(OVAR9),A1		;pick up which wave we selected
	MOVE	@WAVES_DONE,A2
	AND	A2,A1			;is it already in waves done ?
	RETS

;**************************************************************************
;*											      *
;* Make selected wave object flash by turning it from				 *
;* write non zero to write constant alternatly						 *
;* A8 - object to flash - one parter								 *
;* A9 - delay between flashes									 *
;*											      *
;**************************************************************************
FLASH_BOX
	MOVI	0101h,A1
	MOVE	A1,*A8(OCONST)
	MOVE	*A8(OCTRL),A1		;get ctrl bits
	ANDI	0FFFFH-DMAWNZ,A1	;or out write on non zero
	ORI	DMACNZ,A1		;set up write constant
	MOVE	A1,*A8(OCTRL)		;save it away
	MOVE	A9,A0
	CALLA	PRCSLP			;sleeeeeeeeeeeeep
	MOVE	*A8(OCTRL),A1		;get ctrl bits
	ANDI	0FFFFH-DMACZ,A1		;or out write constant non zero
	ORI	DMAWNZ,A1		;set up write on non zero
	MOVE	A1,*A8(OCTRL)	     ;save it away
	MOVE	A9,A0
	CALLA	PRCSLP			;sleeeeeeeeeeeeep
	JRUC	FLASH_BOX

;**************************************************************************
;*											      *
;* Put guys animations up on the screen and wait until done			 *
;*											      *
;**************************************************************************
SLAP_UP_GUYS
	MOVE	A8,A8
	JRZ	NO_GUY_TO_PUT_UP	;check if we create someone
	MOVE	*A8+,A10,L
	CREATE	PID_JUNK,DISPLAY_DASH_TEXT	;setup dash text

	SLEEP	30
	CREATE	PID_JUNK,DISPLAY_CD_TIME		;setup cd timer going

	MOVK	1,A1			;create anims at balcj
	MOVE	A1,@BLACKOUT
	MOVE	*A8+,A0,L		;get background from table
	MOVE	A0,B0
	CALLA	EASYMAKE		;create background
	MOVE	A0,A9
	MOVE	*A9(OIMG),A1,L		;set up img pallette to be faded in
	MOVE	*A1(ICMAP),A10,L
	MOVE	A10,A0
	CALLA	FADEIN_PAL

	MOVE	*A8+,A0,L		;get guy from table
	MOVE	*A8,A2
	MOVE	A0,B0			;create guy
	CALLA	EASYMAKE
	MOVE	A0,A8			;set up img pallette to be faded in
	MOVE	*A8(OIMG),A1,L
	MOVE	*A1(ICMAP),A11,L
	MOVE	A11,A0
	CALLA	FADEIN_PAL

	CLR	A1
	MOVE	A1,@BLACKOUT
	MOVE	A2,A0			;wait for anim to be done
	CALLA	PRCSLP

	MOVE	A11,A0			;fade us all out again
	CALLA	FADEOUT_PAL
	MOVE	A10,A0
	CALLA	FADEOUT_PAL
	SLEEP	17			;wait until faded out
	CALLA	DELETE_OBJ		;delete both background and guy
	MOVE	A9,A8			
	CALLA	DELETE_OBJ

	MOVI	OID_P2MOTEXT,A0		;kill dash text and cd timer
	MOVI	-1,A1
	CALLR	BKILOBJ
	SLEEP	10
NO_GUY_TO_PUT_UP
	RETP

;**************************************************************************
;*											      *
;* Display the cd text on the dash board							 *
;*											      *
;**************************************************************************
DISPLAY_DASH_TEXT
	MOVI	DASH_ARROW_INIT,B0	;create the arrow
	CALLA	EASYMAKE
	MOVE	A0,A8
	MOVI	3,A11
FLASH_ARROW
	SLEEP	6			;flash it three times by turning on/off
	MOVI	M_SCRNOBJ|M_NOSCALE|M_NODISP,A1
	MOVE	A1,*A8(OFLAGS)
	SLEEP	6
	MOVI	M_SCRNOBJ|M_NOSCALE,A1
	MOVE	A1,*A8(OFLAGS)
	DSJS	A11,FLASH_ARROW

	MOVE	A10,B0			;create text
	CALLA	EASYMAKE
	DIE

;	MOVE	A0,A8			;slide dash text on from left
;	MOVE	*A8(OCTRL),A1
;	ORI	M_LRCLIP,A1
;	MOVE	A1,*A8(OCTRL)
;	MOVE	*A8(OSIZEX),A9
;	DEC	A9
;	DEC	A9
;	MOVE	A9,*A8(OFSET)
;	MOVE	*A8(OIMG),A1,L
;	MOVE	*A1(ISAG),A10,L
;	MOVE	A9,A1
;	MOVE	A1,*A8(OFSET)
;NEW_TEXT_SAG
;	SLEEP	1
;	MOVE	A9,A1
;	MOVE	A1,*A8(OFSET)
;	SUBK	2,A9
;	JRNN	NEW_TEXT_SAG
;	CLR	A1
;	MOVE	A1,*A8(OFSET)
;	DIE

;**************************************************************************
;*											      *
;* Put up the CD time on the dash board							 *
;*											      *
;**************************************************************************
DISPLAY_CD_TIME
	MOVI	NAMEZ1,A0	;find the pallete for the text numbers
	CALLA	GETFPAL
	MOVE	A0,A10		;store it away
	CLR	A9		;clear ticks
	CLR	A8		;clear object
NEXT_TIME
	CALLA	UPDATE_TIME	;update the time on the screen
	SLEEP	6		;sleep one tenth of a second
	INC	A9		;increment tick count
	CMPI	100,A9		;is > than  100
	JRNE	NEXT_TIME
	CLR	A9		;yes , so reset to 0
	JRUC	NEXT_TIME

UPDATE_TIME
	MMTM	SP,A8,A9,A10	;store away important registers
	MOVE	A9,@NUM_DATA,L	;store display number in string
	MOVI	TIME_MESS,A8
	MOVE	A10,A2		;new pallette for string
	CALLA	LM_SETUP
	MOVE	A2,A5		;display numbers
	JSRP	PRINTF		;get important registers back
	MMFM	SP,A8,A9,A10
	MOVE	A8,A8		;was there a number object last time ?
	JRZ	NO_SET_UP_YET
	CALLA	DELETE_OBJ	;yep so delete it
NO_SET_UP_YET
	MOVE	A2,A8			;store this process in the new time object
	MOVE	A13,*A8(OPLINK),L	;so when this obj is killed, so is this proc
	RETS


**************************************************************************
*								         *
* KILOBJ - KILL A CLASS OF OBJECTS ON ALL FOREGROUND PLANES		 *
* A0 = OID (16 BITS)							 *
* A1 = MASK: MASK BITS OF ZERO ARE DONT CARES (16 BITS)			 *
*								         *
**************************************************************************
BKILOBJ
	MMTM	SP,A0,A2,A3,A8
	MOVI	FGLIST,A8

	MOVE	A0,A2
	SEXT	A2
	AND	A1,A2		;FORM MATCH

	MOVE	A8,A0
	JRUC	BKO_TST
BKO_LP	
	MOVE	*A0(OID),A14,W
	AND	A1,A14		;CAN DONT CARE BITS
	CMP	A2,A14		;MATCH?
	JRNE	BKO_TST		;NO

	MOVE	*A0,A3,L
	PUSH	A8
	MOVE	A0,A8
	CALLA	DEL_PROC_AND_OBJ
	PULLQ	A8
	MOVE	A3,A0
	JRUC	BKO_TST2
BKO_TST
	MOVE	*A0,A0,L
BKO_TST2
	CMP	A0,A8
	JRNE	BKO_LP

	MMFM	SP,A0,A2,A3,A8
	RETS

;**************************************************************************
;*											      *
;* Kill off all bonuses from last rackup							 *
;*											      *
;**************************************************************************
KILL_THAT_FUCKING_BUG
	CLR	A2
	MOVE	A2,@P1DATA+PBONUSCORE,L
	MOVE	A2,@P1DATA+PBONUSOBJ,L
	MOVE	A2,@P2DATA+PBONUSCORE,L
	MOVE	A2,@P2DATA+PBONUSOBJ,L
	MOVE	A2,@P3DATA+PBONUSCORE,L
	MOVE	A2,@P3DATA+PBONUSOBJ,L
	RETS

BONUS_GUN_VECT
	MOVE	@DIR_SELECTED,A14,L
	JRNZ	BGV_X
	MOVE	A8,@DIR_SELECTED,L
BGV_X
	RETS

NON_BONUS_GUN_VECT
	SOUND1	SND_DIR_INACTIVE
	RETS

*Which enemies to check, in this ID order
* long  offset in counter tables, type of bonus rackup for enemy type
* -1 to end
*
CHECK_ENEMIES_TABLE
	.LONG	030H,DISPLAY_NORMAL_RACK,BOYBOX1
	.LONG	040H,DISPLAY_NORMAL_RACK,BERZBOX1
	.LONG	050H,DISPLAY_NORMAL_RACK,YELJBOX
	.LONG	070H,DISPLAY_NORMAL_RACK,SKATEBOX1
;	.LONG	080H,DISPLAY_NORMAL_RACK,KEMTEKKBOX
	.LONG	0A0H,DISPLAY_NORMAL_RACK,EVERBOX1x
	.LONG	0C0H,DISPLAY_NORMAL_RACK,NATIVBOX1
	.LONG	0D0H,DISPLAY_NORMAL_RACK,NONINBOX
;	.LONG	0E0H,DISPLAY_NORMAL_RACK,BOYBOX1
	.LONG	0,DISPLAY_RESCUE_RACK,HOSTAGEBOX
	.LONG	0,DISPLAY_DAMAGE_RACK,DAMAGEBOX1
	.LONG	0,DISPLAY_MAMMYS_RACK,MAMMYBOX1
	.LONG	0,DISPLAY_WINGS_RACK,0
	.LONG	-1

*
*BACKGROUND TABLE FOR BONUS SCREEN
*

BONUS_BGND_R
	.LONG	BONUS_BGND_2_R
	.LONG	BONUS_BGND_3_R

BONUS_BGND_3_R
	;***** BONUS BACKGROUND
	.LONG	GXPL1BMOD		;module
	.WORD	5+400,-260			;x start , y offset from horizon
	.LONG	GXPL2BMOD		;module
	.WORD	138+400,-261			;x start , y offset from horizon
	.LONG	GXPL3BMOD		;module
	.WORD	271+400,-261			;x start , y offset from horizon
	.LONG	DASHBMOD		;module
	.WORD	0+400,0			;x start , y offset from horizon
	.LONG	0FFFFFFFFH		;end of module list
	.LONG	010000H			;XRATE [16,16]
	.LONG	0			;End of Planes marker
	.long	DUMRETS

BONUS_BGND_2_R
	;***** BONUS BACKGROUND
	.LONG	GXPL1BMOD		;module
	.WORD	5+400,-260			;x start , y offset from horizon
	.LONG	GXPL2ABMOD		;module
	.WORD	270+400,-261			;x start , y offset from horizon
	.LONG	DASHBMOD		;module
	.WORD	0+400,0			;x start , y offset from horizon
	.LONG	0FFFFFFFFH		;end of module list
	.LONG	010000H			;XRATE [16,16]
	.LONG	0			;End of Planes marker
	.long	DUMRETS

BONUS_BGND_L
	.LONG	BONUS_BGND_2_L
	.LONG	BONUS_BGND_3_L

BONUS_BGND_3_L
	;***** BONUS BACKGROUND
	.LONG	GXPL1BMOD		;module
	.WORD	5-400,-260			;x start , y offset from horizon
	.LONG	GXPL2BMOD		;module
	.WORD	138-400,-261			;x start , y offset from horizon
	.LONG	GXPL3BMOD		;module
	.WORD	271-400,-261			;x start , y offset from horizon
	.LONG	DASHBMOD		;module
	.WORD	0-400,0			;x start , y offset from horizon
	.LONG	0FFFFFFFFH		;end of module list
	.LONG	010000H			;XRATE [16,16]
	.LONG	0			;End of Planes marker
	.long	DUMRETS

BONUS_BGND_2_L
	;***** BONUS BACKGROUND
	.LONG	GXPL1BMOD		;module
	.WORD	5-400,-260			;x start , y offset from horizon
	.LONG	GXPL2ABMOD		;module
	.WORD	270-400,-261			;x start , y offset from horizon
	.LONG	DASHBMOD		;module
	.WORD	0-400,0			;x start , y offset from horizon
	.LONG	0FFFFFFFFH		;end of module list
	.LONG	010000H			;XRATE [16,16]
	.LONG	0			;End of Planes marker
	.long	DUMRETS

BONUS_BGND_T
	.LONG	BONUS_BGND_2_T
	.LONG	BONUS_BGND_3_T

BONUS_BGND_3_T
	;***** BONUS BACKGROUND
	.LONG	GXPL1BMOD		;module
	.WORD	5,-260			;x start , y offset from horizon
	.LONG	GXPL2BMOD		;module
	.WORD	138,-261			;x start , y offset from horizon
	.LONG	GXPL3BMOD		;module
	.WORD	271,-261			;x start , y offset from horizon
	.LONG	0FFFFFFFFH		;end of module list
	.LONG	010000H			;XRATE [16,16]
	.LONG	0			;End of Planes marker
	.long	DUMRETS

BONUS_BGND_2_T
	;***** BONUS BACKGROUND
	.LONG	GXPL1BMOD		;module
	.WORD	5,-260			;x start , y offset from horizon
	.LONG	GXPL2ABMOD		;module
	.WORD	270,-261			;x start , y offset from horizon
	.LONG	0FFFFFFFFH		;end of module list
	.LONG	010000H			;XRATE [16,16]
	.LONG	0			;End of Planes marker
	.long	DUMRETS

BONUS_BGND_B
	.LONG	BONUS_BGND_2_B
	.LONG	BONUS_BGND_3_B

BONUS_BGND_3_B
	;***** BONUS BACKGROUND
	.LONG	GXPL1BMOD		;module
	.WORD	5,-260			;x start , y offset from horizon
	.LONG	GXPL2BMOD		;module
	.WORD	138,-261			;x start , y offset from horizon
	.LONG	GXPL3BMOD		;module
	.WORD	271,-261			;x start , y offset from horizon
	.LONG	DASHBMOD		;module
	.WORD	0,0			;x start , y offset from horizon
	.LONG	0FFFFFFFFH		;end of module list
	.LONG	010000H			;XRATE [16,16]
	.LONG	0			;End of Planes marker
	.long	DUMRETS

BONUS_BGND_2_B
	;***** BONUS BACKGROUND
	.LONG	GXPL1BMOD		;module
	.WORD	5,-260			;x start , y offset from horizon
	.LONG	GXPL2ABMOD		;module
	.WORD	270,-261			;x start , y offset from horizon
	.LONG	DASHBMOD		;module
	.WORD	0,0			;x start , y offset from horizon
	.LONG	0FFFFFFFFH		;end of module list
	.LONG	010000H			;XRATE [16,16]
	.LONG	0			;End of Planes marker
	.long	DUMRETS


*2 or 3 boxes for initial HACKING.... message
*
HACK_IT_TABLE
	.LONG	HACK_IT_2
	.LONG	HACK_IT_3

HACK_IT_2
	.LONG	EMPTY_BONUS_BOX_INIT_1_2
	.LONG	EMPTY_BONUS_BOX_INIT_2_2
	.LONG	0

HACK_IT_3
	.LONG	EMPTY_BONUS_BOX_INIT_1_3
	.LONG	EMPTY_BONUS_BOX_INIT_2_3
	.LONG	EMPTY_BONUS_BOX_INIT_3_3
	.LONG	0

*Placement of boxes on screen for combinations of 2 or 3 players

WHAT_WHERE_BOX
	.LONG	EMPTY_BONUS_BOX_INIT_1_2
	.LONG	EMPTY_BONUS_BOX_INIT_1_3

	.LONG	EMPTY_BONUS_BOX_INIT_2_2
	.LONG	EMPTY_BONUS_BOX_INIT_2_3

	.LONG	EMPTY_BONUS_BOX_INIT_3_2
	.LONG	EMPTY_BONUS_BOX_INIT_3_3


EMPTY_BONUS_BOX_INIT_1_3
EMPTY_BONUS_BOX_INIT_1_2
	.LONG	BOYBOX1
	.WORD	DMAWNZ, M_SCRNOBJ|M_NOSCALE
	.WORD	OM_OID|OM_INSERT|OM_SPOS
	.WORD	OID_DAMAGE
	.LONG	[225,5+62+40+15],0

EMPTY_BONUS_BOX_INIT_2_3
	.LONG	BOYBOX1
	.WORD	DMAWNZ, M_SCRNOBJ|M_NOSCALE
	.WORD	OM_OID|OM_INSERT|OM_SPOS
	.WORD	OID_DAMAGE
	.LONG	[225,138+62+40+15],0

EMPTY_BONUS_BOX_INIT_2_2
EMPTY_BONUS_BOX_INIT_3_3
EMPTY_BONUS_BOX_INIT_3_2
	.LONG	BOYBOX1
	.WORD	DMAWNZ, M_SCRNOBJ|M_NOSCALE
	.WORD	OM_OID|OM_INSERT|OM_SPOS
	.WORD	OID_DAMAGE
	.LONG	[225,271+62+40+15],0

*Screen messages for bonus rackup
*
ATP_MESS:
	MESS_MAC RD15FONT,3,196,70,COLOR_PWHITE,STRCNRMOS,10000H|OID_TEXT
	.STRING "HACKING NEW ORDER DATABASE...",0
	.EVEN

ATP2_MESS:
	MESS_MAC RD15FONT,3,196,95,COLOR_PWHITE,STRCNRMOS,10000H|OID_TEXT
	.STRING "CONNECTED........",0
	.EVEN

ATP3_MESS:
	MESS_MAC RD11FONT,3,196,120,COLOR_PWHITE,STRCNRMOS,10000H|OID_TEXT
	.STRING "57600/REL,  V76.bis",0
	.EVEN

ATP4_MESS:
	MESS_MAC RD15FONT,3,196,110,COLOR_PWHITE,STRCNRMOS,10000H|OID_TEXT
	.STRING "STILL CONNECTED.....",0
	.EVEN

WINGS_MESS
	MESS_MAC RD11FONT,3,62+5,50,COLOR_PWHITE,STRCNRMOS,10000H|OID_P1TEXT
	.STRING	"WINGS EARNED.",0
	.EVEN

NO_WING_BONUS_MESS
	MESS_MAC RD11FONT,3,62+5,110,COLOR_PWHITE,STRCNRMOS,10000H|OID_P1TEXT
	.STRING	"NO WINGS EARNED.",0
	.EVEN

WING_BONUS_MESS
	MESS_MAC RD15FONT,3,62+5,175,COLOR_PYELLOW,STRCNRMOS,10000H|OID_P1TEXT
	.STRING	"X %ld",0
	.LONG	NUM_DATA_2
	.EVEN

WING_BONUS_MESS_2
	MESS_MAC RD11FONT,2,62+5,160,COLOR_PYELLOW,STRCNRMOS,10000H|OID_P1TEXT
	.STRING	"BONUS MULTIPLIER",0
	.EVEN

STAT0A_MESS:
	MESS_MAC RD11FONT,2,62+5,SKYTOPOF+69+25,COLOR_PWHITE,STRCNRMOS,OID_P1TEXT
	.STRING "%ld Rescued.",0
	.LONG	NUM_DATA
	.EVEN

TOTAL_NUM2:
	MESS_MAC RD20FONT,2,62+5,SKYTOPOF+190,COLOR_PWHITE,STRCNRMO,OID_P1MOTEXT
	.STRING "%,ld",0
	.LONG	NUM_DATA
	.EVEN

STAT0_MESS:
	MESS_MAC RD11FONT,2,62+5,SKYTOPOF+69+25,COLOR_PWHITE,STRCNRMOS,OID_P1TEXT
	.STRING "%ld Wiped Out.",0
	.LONG	NUM_DATA
	.EVEN

STAT1_MESS:
	MESS_MAC RD11FONT,2,62+5,SKYTOPOF+89+25,COLOR_PWHITE,STRCNRMOS,OID_P1TEXT
	.STRING "Accuracy = %ld@",0
	.LONG	NUM_DATA_2
	.EVEN

STAT2_MESS:
	MESS_MAC RD15FONT,2,62+5,SKYTOPOF+114+19,COLOR_PYELLOW,STRCNRMOS,OID_P1TEXT
	.STRING "BONUS\n\f%,ld",0
	.LONG	[-5,0]
	.LONG	NUM_DATA_3
	.EVEN

HC_MESS:
	MESS_MAC RD11FONT,2,62+5,SKYTOPOF+80,COLOR_PLF,STRCNRMOS,OID_P1TEXT
	.STRING	"%ld",0
	.LONG	NUM_DATA
NOHCSTR	.STRING	"\nNO\nHUMAN\nCASUALTIES",0
	.EVEN

HUMAN_MESS:
	MESS_MAC RD11FONT,2,62+5,SKYTOPOF+80,COLOR_PRED,STRCNRMOS,OID_P1TEXT
	.STRING	"\nHUMAN\nCASUALTIES",0
	.EVEN

PEN_MESS:
	MESS_MAC RD15FONT,2,62+5,SKYTOPOF+140,COLOR_PYELLOW,STRCNRMOS,OID_P1TEXT
	.STRING "PENALTY\n%,ld",0
	.LONG	NUM_DATA_3
	.EVEN

DAM_MESS:
	MESS_MAC RD15FONT,2,62+5,08AH,COLOR_PYELLOW,STRCNRMOS,OID_P1TEXT
	.STRING	"DAMAGE\nBONUS\n\f%,ld",0
	.LONG	[-5,0]
	.LONG	NUM_DATA_3
	.EVEN

MAM_MESS:
	MESS_MAC RD15FONT,2,62+5,08AH,COLOR_PYELLOW,STRCNRMOS,OID_P1TEXT
	.STRING	"MAMMY\nBONUS\n\f%,ld",0
	.LONG	[-5,0]
	.LONG	NUM_DATA_3
	.EVEN


TOTAL_MESS:
	MESS_MAC RD15FONT,2,62+5,SKYTOPOF+171,COLOR_PWHITE,STRCNRMOS,OID_TEXT
	.STRING "TOTAL BONUS",0
	.EVEN
TOTAL_NUM:
	MESS_MAC RD20FONT,2,62+5,SKYTOPOF+190,COLOR_PLF,STRCNRMOS,OID_P1MOTEXT
	.STRING "%,ld",0
	.LONG	NUM_DATA
	.EVEN

JOIN_IN_MESS
	MESS_MAC RD15FONT,2,58+5,SKYTOPOF+65,COLOR_PWHITE,STRCNRMOS,OID_P2TEXT
	.STRING "PRESS START\nTo Join The\nRevolution !",0
	.EVEN

COIN_IN_MESS
	MESS_MAC RD15FONT,2,58+5,SKYTOPOF+65,COLOR_PWHITE,STRCNRMOS,OID_P2TEXT
	.STRING "INSERT COIN\nTo Join The\nRevolution !",0
	.EVEN

STAND_BY_MESS
	MESS_MAC RD15FONT,2,58+5,SKYTOPOF+65,COLOR_PWHITE,STRCNRMOS,OID_P2TEXT
	.STRING "STAND BY\nTo Join The\nRevolution !",0
	.EVEN

TIME_MESS
	MESS_MAC DASH_TIME_FONT,0000FFFEH,260,187,COLOR_PYELLOW,STRLNCO,OID_P2MOTEXT
	.STRING ":%02ld",0
	.LONG	NUM_DATA
	.EVEN

;SOUND SCRIPTS
MODEM_SND
	.WORD	0F380H,020H,0836BH	;dial tone
	.WORD	0F380H,008H,0836EH	;button
	.WORD	0F380H,008H,0837AH	;button
	.WORD	0F380H,008H,0836EH	;button
	.WORD	0F380H,008H,08377H	;button
	.WORD	0F380H,008H,08377H	;button
	.WORD	0F380H,008H,08371H	;button
	.WORD	0F380H,008H,08374H	;button
	.WORD	0F380H,020H,08367H	;phone ring
	.WORD	0F380H,020H,08092H	;modem tick
	.WORD	0F380H,050H,08093H	;modem connect
	.word	0F3FFh,1,43E6h		;Kill track 3
	.WORD	0

SCORE_MUL_SND
	.WORD	0F280H,078H,0409BH	;rackup sound
	.WORD	0

HACK_DATA_SND
	.WORD	0F380H,078H,08094H	;hacking images
	.word	0F3FFh,1,43E6h		;Kill track 3
	.WORD	0

RACKUP_SND
	.WORD	0F380H,078H,04095H	;rackup sound
	.WORD	0

RACKDOWN_SND
	.WORD	0F380H,078H,04096H	;rackdown sound
	.WORD	0

STOP_RACKDOWN_SND
	.word	0F380h,1,4098h		;Kill track 3
	.WORD	0
STOP_RACKUP_SND
	.word	0F380h,1,4097h		;Kill track 3
	.WORD	0

STOP_RACK_SND
	.word	0F3FFh,1,43E6h		;Kill track 3
	.WORD	0

STOP_ALL_SND
	.word	0F0FFh,1,43E3h		;Kill track 3
	.word	0F1FFh,1,43E4h		;Kill track 3
	.word	0F2FFh,1,43E5h		;Kill track 3
	.word	0F3FFh,1,43E6h		;Kill track 3
	.WORD	0

CD_DASH_SND
	.WORD	0F380H,078H,041fdH	;move cd into dash
	.WORD	0

WHERE_YOU_GO
	.WORD	0F380H,078H,0482EH	;where you go now is up to you
	.WORD	0

SCORE_GOES_UP
	.WORD	0F380H,078H,0434DH	;where you go now is up to you
	.WORD	0

MAGGOTS_SND
	.WORD	0F380H,078H,04831H	;they're maggots
	.WORD	0

KEMMITECH
	.WORD	0F380H,180,04843H	;destroy kemmitech  
	.WORD	0

TEAR_DOWN_THE_WALL
	.WORD	0F380H,180,0483EH	;destroy kemmitech  
	.WORD	0

STOP_THE_BUS
	.WORD	0F380H,180,04834H	;destroy kemmitech  
	.WORD	0

WOOSH_SND
	.WORD	0F380H,078H,0409AH	;WOOSH THE SCREEN ON
	.WORD	0

SND_SWEET_VOCALS
	.WORD	0F0FDH,1,08021H,0

AERO_WINGS_INIT
	.LONG	RXLOGO_vda
	.WORD	DMAWNZ, M_SCRNOBJ
	.WORD	OM_INSERT|OM_OID
	.WORD	OID_P1TEXT


DEST1A_INIT
	.BYTE	2,0,0,2
	.LONG	GUNON_P
	.LONG	WHITTIT_P
	.WORD	OID_P2MOTEXT,OM_INSERT|OM_SPOS|OM_GUNV
	.LONG	NON_BONUS_GUN_VECT
	.LONG	[104,198]

	.LONG	USEGUN
	.WORD	DMAWNZ, M_SCRNOBJ|M_NOSCALE|M_NOPIXSCAN,0,0

	.LONG	WHITETIT
	.WORD	DMAWNZ, M_SCRNOBJ|M_NOSCALE|M_NOPIXSCAN,0,0

DEST2A_INIT
	.LONG	AMAON
	.WORD	DMAWNZ, M_SCRNOBJ|M_NOSCALE|M_NOPIXSCAN
	.WORD	OM_INSERT|OM_SPOS|OM_OID|OM_GUNV
	.WORD	OID_P1MOTEXT
	.LONG	BONUS_GUN_VECT
	.LONG	[104,198],0

DEST2B_INIT
	.LONG	AMAOFF
	.WORD	DMAWNZ, M_SCRNOBJ|M_NOSCALE|M_NOPIXSCAN
	.WORD	OM_INSERT|OM_SPOS|OM_OID|OM_GUNV
	.WORD	OID_P2MOTEXT
	.LONG	NON_BONUS_GUN_VECT
	.LONG	[104,198],0

DEST3A_INIT
	.LONG	PACON
	.WORD	DMAWNZ, M_SCRNOBJ|M_NOSCALE|M_NOPIXSCAN
	.WORD	OM_INSERT|OM_SPOS|OM_OID|OM_GUNV
	.WORD	OID_P1MOTEXT
	.LONG	BONUS_GUN_VECT
	.LONG	[104,198],0

DEST3B_INIT
	.LONG	PACOFF
	.WORD	DMAWNZ, M_SCRNOBJ|M_NOSCALE|M_NOPIXSCAN
	.WORD	OM_INSERT|OM_SPOS|OM_OID|OM_GUNV
	.WORD	OID_P2MOTEXT
	.LONG	NON_BONUS_GUN_VECT
	.LONG	[104,198],0

DEST4A_INIT
	.LONG	MIDON
	.WORD	DMAWNZ, M_SCRNOBJ|M_NOSCALE|M_NOPIXSCAN
	.WORD	OM_INSERT|OM_SPOS|OM_OID|OM_GUNV
	.WORD	OID_P1MOTEXT
	.LONG	BONUS_GUN_VECT
	.LONG	[104,198],0

DEST4B_INIT
	.LONG	MIDOFF
	.WORD	DMAWNZ, M_SCRNOBJ|M_NOSCALE|M_NOPIXSCAN
	.WORD	OM_INSERT|OM_SPOS|OM_OID|OM_GUNV
	.WORD	OID_P2MOTEXT
	.LONG	NON_BONUS_GUN_VECT
	.LONG	[104,198],0


OBJECTIVE_TEXT_INIT
	.LONG	TXTNONOBJ1
	.WORD	DMAWNZ, M_SCRNOBJ|M_NOSCALE
	.WORD	OM_INSERT|OM_SPOS|OM_OID
	.WORD	OID_P2MOTEXT
	.LONG	[180,130],0

CD_INIT
	.LONG	DISC2124
	.WORD	DMAWNZ, M_SCRNOBJ|M_NOSCALE
	.WORD	OM_INSERT|OM_SPOS
	.LONG	[470,200],1

DASH_ARROW_INIT
	.LONG	TXTARROW1
	.WORD	DMAWNZ, M_SCRNOBJ|M_NOSCALE
	.WORD	OM_INSERT|OM_SPOS|OM_OID
	.WORD	OID_P2MOTEXT
	.LONG	[187,123],0

STEVE_TEXT_INIT
	.LONG	STEVETXT1
	.WORD	DMAWNZ, M_SCRNOBJ|M_NOSCALE
	.WORD	OM_INSERT|OM_SPOS|OM_OID
	.WORD	OID_P2MOTEXT
	.LONG	[180,130],0

ST_WALL_INIT
	.LONG	TWAL
	.WORD	DMAWNZ, M_SCRNOBJ|M_NOSCALE
	.WORD	OM_INSERT|OM_SPOS
	.LONG	[095H,0C7H],1

STEVEN_TYLER_INIT
	.LONG	S471sa4
	.WORD	DMAWNZ, M_SCRNOBJ|M_NOSCALE
	.WORD	OM_INSERT|OM_SPOS|OM_ANIM
	.LONG	STEVE_ANIM
	.LONG	[039h,0a0h],0

BRAD_TEXT_INIT
	.LONG	BRADTXT1
	.WORD	DMAWNZ, M_SCRNOBJ|M_NOSCALE
	.WORD	OM_INSERT|OM_SPOS|OM_OID
	.WORD	OID_P2MOTEXT
	.LONG	[180,130],0

BRAD_WALL_INIT
	.LONG	BRADWAL
	.WORD	DMAWNZ, M_SCRNOBJ|M_NOSCALE
	.WORD	OM_INSERT|OM_SPOS
	.LONG	[095H,0C7H],1

BRAD_INIT
	.LONG	B241SA10
	.WORD	DMAWNZ, M_SCRNOBJ|M_NOSCALE
	.WORD	OM_INSERT|OM_SPOS|OM_ANIM
	.LONG	BRAD_ANIM
	.LONG	[03ah,090h],0

PERRY_TEXT_INIT
	.LONG	JOETXT1
	.WORD	DMAWNZ, M_SCRNOBJ|M_NOSCALE
	.WORD	OM_INSERT|OM_SPOS|OM_OID
	.WORD	OID_P2MOTEXT
	.LONG	[180,130],0

PERRY_WALL_INIT
	.LONG	PERRYWAL
	.WORD	DMAWNZ, M_SCRNOBJ|M_NOSCALE
	.WORD	OM_INSERT|OM_SPOS
	.LONG	[095H,0C7H],1

JOE_PERRY_INIT
	.LONG	J321SA10
	.WORD	DMAWNZ, M_SCRNOBJ|M_NOSCALE
	.WORD	OM_INSERT|OM_SPOS|OM_ANIM
	.LONG	PERRY_ANIM
	.LONG	[03ah,08ch],0		 

KRAMER_TEXT_INIT
	.LONG	JOEYTXT1
	.WORD	DMAWNZ, M_SCRNOBJ|M_NOSCALE
	.WORD	OM_INSERT|OM_SPOS|OM_OID
	.WORD	OID_P2MOTEXT
	.LONG	[180,130],0

KRAMER_WALL_INIT
	.LONG	DESRT
	.WORD	DMAWNZ, M_SCRNOBJ|M_NOSCALE
	.WORD	OM_INSERT|OM_SPOS
	.LONG	[095H,0C7H],1

KRAMER_INIT
	.LONG	KRAM04
	.WORD	DMAWNZ, M_SCRNOBJ|M_NOSCALE
	.WORD	OM_INSERT|OM_SPOS|OM_ANIM
	.LONG	KRAMER_ANIM
	.LONG	[095h,0C7h],0

TOM_TEXT_INIT
	.LONG	TOMTXT1
	.WORD	DMAWNZ, M_SCRNOBJ|M_NOSCALE
	.WORD	OM_INSERT|OM_SPOS|OM_OID
	.WORD	OID_P2MOTEXT
	.LONG	[180,130],0

TOM_WALL_INIT
	.LONG	TVWALL
	.WORD	DMAWNZ, M_SCRNOBJ|M_NOSCALE
	.WORD	OM_INSERT|OM_SPOS
	.LONG	[095H,0C7H],1

TOM_INIT
	.LONG	TOMHAM06
	.WORD	DMAWNZ, M_SCRNOBJ|M_NOSCALE
	.WORD	OM_INSERT|OM_SPOS|OM_ANIM
	.LONG	TOM_ANIM
	.LONG	[095h,0C7h],0


STEVE_ANIM
	LW	S471sa4,24
	LWL	S471sa5,6|AFunc,CALL_WHERE
	LW	S471sa6,6
	LW	S471sa7,6
	LW	S471sa8,6
	LW	S471sa9,6
	LW	S471sa10,6
	LW	S471sa11,6
	LW	S471sa12,6
	LW	S471sa13,7
	LW	S471sa14,9
	LW	S471sa15,9
	LW	S471sa16,8
	LW	S471sa17,7
	LW	S471sa18,7
	LW	S471sa19,7
	LW	S471sa20,6
	LW	S471sa21,7
	LW	S471sa22,7
	LW	S471sa23,0BH
	LW	S471sa24,6
	LW	S471sa25,8
	LW	S471sa26,0AH
	LW	S471sa27,8
	LW	S471sa28,8
	LW	S471sa29,120
	.LONG	0

BRAD_ANIM
	LW	B241SA10,12
	LW	B241SA11,12
	LW	B241SA12,1
	LWL	1,5|AFunc,CALL_KEMMITECH   
	LW	B241SA13,6
	LW	B241SA14,6
	LW	B241SA15,6
	LW	B241SA16,6
	LW	B241SA17,6
	LW	B241SA18,6
	LW	B241SA19,6
	LW	B241SA20,6
	LW	B241SA21,6
	LW	B241SA22,6
	LW	B241SA23,6
	LW	B241SA24,6
	LW	B241SA25,5
	LW	B241SA26,6
	LW	B241SA27,5
	LW	B241SA28,6
	LW	B241SA29,6
	LW	B241SA30,6
	LW	B241SA31,7
	LW	B241SA32,5
	LW	B241SA33,6
	LW	B241SA34,6
	LW	B241SA35,6
	LW	B241SA36,6
	LW	B241SA37,6
	LW	B241SA38,6
	LW	B241SA39,6
	LW	B241SA40,6
	LW	B241SA41,6
	LW	B241SA42,120
	.LONG	0

PERRY_ANIM
	LW	J321SA10,24
	LW	J321SA11,1
	LWL	1,5|AFunc,CALL_MAGGOTS
	LW	J321SA12,6
	LW	J321SA13,6
	LW	J321SA14,5
	LW	J321SA15,5
	LW	J321SA16,6
	LW	J321SA17,6
	LW	J321SA18,5
	LW	J321SA19,6
	LW	J321SA20,6
	LW	J321SA21,6
	LW	J321SA22,6
	LW	J321SA23,6
	LW	J321SA24,6
	LW	J321SA25,6
	LW	J321SA26,6
	LW	J321SA27,6
	LW	J321SA28,6
	LW	J321SA29,6
	LW	J321SA30,6
	LW	J321SA31,6
	LW	J321SA32,6
	LW	J321SA33,6
	LW	J321SA34,6
	LW	J321SA35,6
	LW	J321SA36,6
	LW	J321SA37,6
	LW	J321SA38,6
	LW	J321SA39,6
	LW	J321SA40,120
	.LONG	0

KRAMER_ANIM
	LW	KRAM04,24
	LWL	KRAM04,4|AFunc,CALL_STOP_THE_BUS
	LW	KRAM05,4			
	LW	KRAM06,6
	LW	KRAM07,6			
	LW	KRAM08,6
	LW	KRAM09,6
	LW	KRAM10,6
	LW	KRAM11,6
	LW	KRAM12,6
	LW	KRAM13,6
	LW	KRAM14,6
	LW	KRAM15,6
	LW	KRAM16,6
	LW	KRAM17,4
	LW	KRAM18,6
	LW	KRAM19,6
	LW	KRAM20,120
	LW	1,120
	.LONG	0

TOM_ANIM
	LW	TOMHAM06,24
	LWL	TOMHAM07,6|AFunc,CALL_TEAR_DOWN_THE_WALL			
	LW	TOMHAM08,6
	LW	TOMHAM09,6
	LW	TOMHAM10,6
	LW	TOMHAM11,6
	LW	TOMHAM12,6
	LW	TOMHAM13,6
	LW	TOMHAM14,6
	LW	TOMHAM15,6
	LW	TOMHAM16,6
	LW	TOMHAM17,6
	LW	TOMHAM18,120
	.LONG	0

DASH_TIME_FONT
	.LONG  COLTXT1,COLTXT1,COLTXT1,COLTXT1,COLTXT1
	.LONG  COLTXT1,COLTXT1,COLTXT1,COLTXT1,COLTXT1
	.LONG  COLTXT1,COLTXT1,COLTXT1,COLTXT1,COLTXT1
	.LONG  TXT0,TXT1,TXT2,TXT3,TXT4,TXT5,TXT6
	.LONG  TXT7,TXT8,TXT9
	.LONG  COLTXT1
	.LONG  TXT2,TXT2,TXT2,TXT2,TXT2,TXT2
	.LONG  TXT2,TXT2,TXT2,TXT2,TXT2,TXT2,TXT2,TXT2
	.LONG  TXT2,TXT2,TXT2,TXT2,TXT2,TXT2,TXT2,TXT2

STEVEN_STUFF
	.LONG	STEVE_TEXT_INIT,ST_WALL_INIT,STEVEN_TYLER_INIT
	.WORD	229

PERRY_STUFF
	.LONG	PERRY_TEXT_INIT,PERRY_WALL_INIT,JOE_PERRY_INIT
	.WORD	229

BRAD_STUFF
	.LONG	BRAD_TEXT_INIT,BRAD_WALL_INIT,BRAD_INIT
	.WORD	250

KRAMER_STUFF
	.LONG	KRAMER_TEXT_INIT,KRAMER_WALL_INIT,KRAMER_INIT
	.WORD	150

TOM_STUFF
	.LONG	TOM_TEXT_INIT,TOM_WALL_INIT,TOM_INIT
	.WORD	100

;**************************************************************************
;*											      *
;* CREATE BOX BEHIND ANOTHER OBJECT, CAN BE BEHIND LOTS OF MULTIPARTERS	 *
;* WILL CREATE A ZPOS 1 BEHIND MAIN OBJECT							 *
;* ASSUMES FIRST OBJECT IN MULTIPARTER, FAR LEFT AND TOP				 *
;* ASSUMES LAST OBJECT IN MULTIPARTER, FAR RIGHTAND BOTTOM			 *
;* 												 *
;* COMING IN											 *
;* A8 - EXISTING OBJECTS YOU WANT BOX AROUND (CAN BE MULTIPARTERS)		 *
;* A4 - EXTRA PIXEL OVERSPILL Y/X								 *
;* A7 - COLOUR										 *
;* RETURNS											 *
;* A6 - BOX OBJECT										 *
;*											      *
;**************************************************************************
JAKE_BOX
	MMTM	SP,A8

	MOVI	STATIC_BOX_INIT,B0	;create a static object
	CALLA	EASYMAKE
	MOVE	A0,A6

	MOVE	*A8(ODAG),A0,L		;get initial object dag
	SRL	1,A4			;divide pixel surround by 1
	ANDI	0FFFF7FFFH,A4
	SUBXY	A4,A0			;sub pixel surround from dag
	MOVE	A8,A3

GET_NEXT_BOX_PART
	MOVE	A3,A2			;find last piece (if multiparter)
	MOVE	*A2(OPARTS),A3,L
	JRNZ	GET_NEXT_BOX_PART
	MOVE	*A2(ODAG),A1,L		;get last piece dag 
	MOVE	*A2(OSIZE),A3,L		;get last piece size
	ADDXY	A3,A1			;add initial object size to br dag
	ADDXY	A4,A1			;add pixel surround	to br dag
	SUBXY	A0,A1			;sub box dag from br dag to get size
	MOVE	A1,*A6(OSIZE),L		;store new box size
	MOVE	A1,*A6(OUSIZE),L
	MOVE	A0,*A6(ODAG),L		;store dag
	MOVE	A0,*A6(OXPOS)		;store x & ypos in object registers
	SRL	16,A0
	MOVE	A0,*A6(OYPOS)
	MOVE	A7,*A6(OCONST)		;store pixel constant

	MOVE	*A8(OZVAL),A1,L		;grab initial object zpos
	INC	A1			;make box 1 behind
	MOVE	A1,*A6(OZVAL),L		

	MMFM	SP,A8
	RETS

STATIC_BOX_INIT
	.LONG	STATIC_BOX1
	.WORD	DMACAL, M_SCRNOBJ|M_NOSCALE
	.WORD	OM_INSERT|OM_OID
	.WORD	OID_P2MOTEXT

	.long   TEXTPAL
STATIC_BOX1
	.word   0100CH,10,10
	.long   0f800000H
	.word   0,0


	.END


