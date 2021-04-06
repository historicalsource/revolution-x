 	.MLIB	"GXMACS.LIB"
	.FILE	"GXSCROL2.ASM"
	.TITLE	" <<< GENERATION X -- SCROLL ROUTINES ptII >>>"
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
	.INCLUDE	"IMGTBL.GLO"
	.INCLUDE	"UNIVTBL.GLO"
	.INCLUDE	"GXSCROLL.TBL"
	.include	"gxscrl.h"


	.def	 SND_DIR_CHOSEN,S_MERGE_UNIV   
	.DEF	SND_DIR_INACTIVE,P_SYMGRN
	.def 	MERGE_UNIV_OFF

***** from GXAFUNC.ASM
	.REF	SetAnim_AFARG

***** from GXRAM.ASM
	.REF	IN_MAKE_DECISION, HOLD_ENEMY_DISPATCH, BOSS_DIFF

***** from GXPLAYER.ASM
	.REF	PLAYER_PRAISE

	.bss	DECISION_MADE,16	;If 1, then decision made.
	.bss	UNUSED_WORD,16		;For alignment purposes

	.text

**************************************************************************
*								         *
* 	S_LOAD_BOSS_PUNISH						 *
* 									 *
* 	Load the BOSS_PUNISH flag according to the BOSS_DIFF		 *
* 	variable.  If it is neg, then always zero.  If 1 then		 *
* 	set.  If zero then clr and inc.					 *
*								         *
**************************************************************************
S_LOAD_BOSS_PUNISH
	MOVE	@BOSS_DIFF,A14,W
	JRN	LBP_CLR
	JRNZ	LPB_SET
	INC	A14
	MOVE	A14,@BOSS_DIFF,W
	JRUC	LBP_CLR
LPB_SET
	MOVKM	1,@BOSS_PUNISH,W
	JAUC	SCRL_DISPATCHER

LBP_CLR	
	CLRM	@BOSS_PUNISH,W
	JAUC	SCRL_DISPATCHER

**************************************************************************
*								         *
* 	S_PRAISE							 *
* 									 *
* 	Scroll func to call the player praise function			 *
*								         *
**************************************************************************
S_PRAISE
	CALLA	PLAYER_PRAISE
	JAUC	SCRL_DISPATCHER

**************************************************************************
*								         *
* 	S_AUDIT								 *
* 									 *
* 	Scroll func to click an audit counter once.			 *
* 									 *
* 	*A11+,W = Audit number (equates in GXAUDN.H)			 *
*								         *
**************************************************************************
S_AUDIT
	MOVE	*A11+,A0,W
	MOVE	@GAME_STATE,A14,W
	CMPI	INAMODE,A14
	JAEQ	SCRL_DISPATCHER		;No auditing during Attract mode
	CALLA	AUD1
	JAUC	SCRL_DISPATCHER

**************************************************************************
*								         *
* S_DEL_ENEMY_NOAUD_OID - DELETE AN ENEMY OF SPECIFIED OID WITHOUT AUDIT *
* 									 *
* PASS:									 *
* 	.WORD	OID							 *
*								         *
**************************************************************************

S_DEL_ENEMY_NOAUD_OID
	MOVE	*A11+,A1,W			;GET OID

	MOVI	FGLIST,A0
	MOVE	A0,A8
S_DENO_LUPE
	MOVE	*A8,A8,L			;GET NEXT OBJECT
S_DENO_TEST
	CMP	A0,A8
	JAEQ	SCRL_DISPATCHER			;BR=NO MORE OBJECTS
	MOVE	*A8(OID),A14,W
	CMP	A1,A14
	JRNE	S_DENO_LUPE			;BR=NO OID MATCH
	MOVE	*A8,A2,L			;GET NEXT OBJECT
	MOVE	*A8(OPART1),A3,L
	JRZ	S_DENO_DEL			;BR=NOT A MULTIPARTER
	CMP	A8,A3
	JRNE	S_DENO_LUPE			;BR=THIS IS NOT THE HEAD
S_DENO_FIND_NEXT
	MOVE	*A2(OPART1),A14,L
	CMP	A3,A14
	JRNE	S_DENO_DEL			;BR=NOT PART OF THIS ENEMY
	MOVE	*A2,A2,L
	CMP	A0,A2
	JRNE	S_DENO_FIND_NEXT		;BR=NOT END OF LIST
S_DENO_DEL
	CALLA	DEL_ENEMY_NOAUD			;DELETE OBJECT
	MOVE	A2,A8				;TEST THE NEXT OBJECT
	JRUC	S_DENO_TEST

**************************************************************************
*								         *
* 	S_ACCEL_LIMIT_TO_POINT						 *
* 									 *
* 	Accelerate at a given rate to a given point.  Max velocity	 *
* 	is also given.  Acceleration and max vel should be given	 *
* 	as absolute values.						 *
* 									 *
* 	.LONG	S_ACCEL_LIMIT_TO_POINT					 *
* 	.WORD	X accel, X target, X max vel				 *
* 	.WORD	Y target, Y accel, Y max vel				 *
* 	.LONG	Z target						 *
* 	.WORD	Z accel (if negative, then Z target is relative)	 *
* 	.LONG	Z max vel						 *
* 	.WORD	Velocity "no clear" flags (M_X,M_Y,M_Z)			 *
*								         *
**************************************************************************
S_ACCEL_LIMIT_TO_POINT:
	MOVE	@XBASE,A3,L
	MOVE	@YBASE,A2,L
	MOVE	@ZBASE_HR,A1,L		;Bases loaded

	MOVE	*A11+,A4,L
	CLR	A8
	MOVY	A4,A8			;Target stays here
	SEXT	A4

	MOVE	*A11+,A5,W
	SLL	16,A5			;Max vel

	CMP	A8,A3			;Where are we, in prox to our dest?
	JRLT	SALTP_STUFF_X
	JRGT	SALTP_NEG_X
	CLR	A4
	JRUC	SALTP_STUFF_X

SALTP_NEG_X
	NEG	A4			;We gots to go neg
	NEG	A5
SALTP_STUFF_X
	MOVE	A4,@XSACCEL,L
	
* Now we do the Y
	MOVE	*A11+,A4,L
	CLR	A9
	MOVY	A4,A9			;Target stays here
	SEXT	A4

	MOVE	*A11+,A6,W
	SLL	16,A6			;Max vel

	CMP	A9,A2			;Where are we, in prox to our dest?
	JRLT	SALTP_STUFF_Y
	JRGT	SALTP_NEG_Y
	CLR	A4
	JRUC	SALTP_STUFF_Y

SALTP_NEG_Y
	NEG	A4			;We gots to go neg
	NEG	A6
SALTP_STUFF_Y
	MOVE	A4,@YSACCEL,L

* Now we do the Z

	MOVE	*A11+,A10,L		;Get the Z target
	SLL	ZFRAC,A10		;TRANSLATE TO HI-RES

	MOVE	*A11+,A4,W
	SLL	ZFRAC,A4		;XLATE TO HI
	JRNN	SALTP_NOZADJ		;Neg Accel means relative target
	MOVE	@ZREL_OFF,A14,L	 
	ADD	A14,A10			;Convert it to absolute
	NEG	A4
SALTP_NOZADJ:	
	
	MOVE	*A11+,A7,L
	SLL	ZFRAC,A7		;XLATE TO HI

	CMP	A10,A1			;Where are we, in prox to our dest?
	JRLT	SALTP_STUFF_Z
	JRGT	SALTP_NEG_Z
	CLR	A4
	JRUC	SALTP_STUFF_Z

SALTP_NEG_Z
	NEG	A4			;We gots to go neg
	NEG	A7
SALTP_STUFF_Z
	MOVE	A4,@ZSACCEL,L

* Now everything is stuffed, let's wait 'til we get there
	MOVE	*A11+,A4,W
SALTP_WAIT	
	MMTM	A12,A4,A5,A6,A7		;Save our target vels
	SLEEP	1
	MMFM	A12,A4,A5,A6,A7
	
	MOVE	@XBASE,A3,L
	MOVE	@YBASE,A2,L
	MOVE	@ZBASE_HR,A1,L		;Bases loaded

	MOVI	XSCROLL,B14
	MMFM	B14,B1,B2,B3		;B1 = ZSCROLL, B2 = YSCROLL, B3 = XSCROLL

* Check the X
	MOVE	A5,A5	      		;Which way are we going
	JRZ	SALTP_Y_CK		;BR = We aren't
	JRN	SALTP_NEG_X_CK		;BR = Left

	MOVE	@XSACCEL,B4,L
	JRNZ	SALTP_POS_XS_SANITY

	MOVE	A5,@XSCROLL,L
	JRUC	SALTP_POS_X_CK_GO

SALTP_POS_XS_SANITY
	JRP	SALTP_POS_X_CK_GO
	MOVE	A5,@XSCROLL,L
	CLR	A14
	MOVE	A14,@XSACCEL,L

SALTP_POS_X_CK_GO
	CMP	A8,A3			;Moving right, are we less?
	JRGE	SALTP_CLR_X		;BR = We've hit our target

	MOVE	B3,A14
	CMP	A5,A14			;Do we need more X velocity?
	JRLT	SALTP_Y_CK		;BR = Yes, keep accel alive
	JRUC	SALTP_X_TARGET_VEL
	
SALTP_NEG_X_CK
	MOVE	@XSACCEL,B4,L
	JRNZ	SALTP_NEG_XS_SANITY

	MOVE	A5,@XSCROLL,L
	JRUC	SALTP_NEG_X_CK_GO

SALTP_NEG_XS_SANITY
	JRN	SALTP_NEG_X_CK_GO
	MOVE	A5,@XSCROLL,L
	CLR	A14
	MOVE	A14,@XSACCEL,L

SALTP_NEG_X_CK_GO

	CMP	A8,A3			;Moving left, are we greater?
	JRLE	SALTP_CLR_X		;BR = We hit the target

	MOVE	B3,A14
	CMP	A5,A14
	JRGT	SALTP_Y_CK

SALTP_X_TARGET_VEL
	MOVE	A5,@XSCROLL,L
	CLR	A14
	MOVE	A14,@XSACCEL,L
	JRUC	SALTP_Y_CK

SALTP_CLR_X
	CLR	A5	     		;Stop the X
	MOVE	A5,@XSACCEL,L
	BTST	B_X,A4
	JRNZ	SALTP_Y_CK
	MOVE	A8,@XBASE,L
	MOVE	A5,@XSCROLL,L

* Check the Y
SALTP_Y_CK	
	MOVE	A6,A6	      		;Which way are we going
	JRZ	SALTP_Z_CK		;BR = We aren't
	JRN	SALTP_NEG_Y_CK		;BR = Down

	MOVE	@YSACCEL,B4,L
	JRNZ	SALTP_POS_YS_SANITY

	MOVE	A6,@YSCROLL,L
	JRUC	SALTP_POS_Y_CK_GO

SALTP_POS_YS_SANITY
	JRP	SALTP_POS_Y_CK_GO
	MOVE	A6,@YSCROLL,L
	CLR	A14
	MOVE	A14,@YSACCEL,L

SALTP_POS_Y_CK_GO

	CMP	A9,A2			;Moving up, are we less?
	JRGE	SALTP_CLR_Y		;BR = We've hit our target

	MOVE	B2,A14
	CMP	A6,A14			;Do we need more Y velocity?
	JRLT	SALTP_Z_CK		;BR = Yes, keep accel alive
	JRUC	SALTP_Y_TARGET_VEL
	
SALTP_NEG_Y_CK
	MOVE	@YSACCEL,B4,L
	JRNZ	SALTP_NEG_YS_SANITY

	MOVE	A6,@YSCROLL,L
	JRUC	SALTP_NEG_Y_CK_GO

SALTP_NEG_YS_SANITY
	JRN	SALTP_NEG_Y_CK_GO
	MOVE	A6,@YSCROLL,L
	CLR	A14
	MOVE	A14,@YSACCEL,L

SALTP_NEG_Y_CK_GO

	CMP	A9,A2			;Moving down, are we greater?
	JRLE	SALTP_CLR_Y		;BR = We hit the target

	MOVE	B2,A14			;Velocity check in the neg direction
	CMP	A6,A14
	JRGT	SALTP_Z_CK		;BR = We still need more velocity

SALTP_Y_TARGET_VEL
	MOVE	A6,@YSCROLL,L		;Put our velocity right on target
	CLR	A14
	MOVE	A14,@YSACCEL,L		;So that means no more accelerating
	JRUC	SALTP_Z_CK

SALTP_CLR_Y
	CLR	A6	     		;Stop the Y
	MOVE	A6,@YSACCEL,L
	BTST	B_Y,A4
	JRNZ	SALTP_Z_CK
	MOVE	A9,@YBASE,L
	MOVE	A6,@YSCROLL,L

* Check the Z
SALTP_Z_CK	
	MOVE	A7,A7	      		;Which way are we going
	JRZ	SALTP_END_CK		;BR = We aren't
	JRN	SALTP_NEG_Z_CK		;BR = Out

	MOVE	@ZSACCEL,B4,L
	JRNZ	SALTP_POS_ZS_SANITY

	MOVE	A7,@ZSCROLL,L
	JRUC	SALTP_POS_Z_CK_GO

SALTP_POS_ZS_SANITY
	JRP	SALTP_POS_Z_CK_GO
	MOVE	A7,@ZSCROLL,L
	CLR	A14
	MOVE	A14,@ZSACCEL,L

SALTP_POS_Z_CK_GO

	CMP	A10,A1			;Moving in, are we less?
	JRGE	SALTP_CLR_Z		;BR = We've hit our target

	MOVE	B1,A14
	CMP	A7,A14			;Do we need more Z velocity?
	JRLT	SALTP_END_CK		;BR = Yes, keep accel alive
	JRUC	SALTP_Z_TARGET_VEL
	
SALTP_NEG_Z_CK
	MOVE	@ZSACCEL,B4,L
	JRNZ	SALTP_NEG_ZS_SANITY

	MOVE	A7,@ZSCROLL,L
	JRUC	SALTP_NEG_Z_CK_GO

SALTP_NEG_ZS_SANITY
	JRN	SALTP_NEG_Z_CK_GO
	MOVE	A7,@ZSCROLL,L
	CLR	A14
	MOVE	A14,@ZSACCEL,L

SALTP_NEG_Z_CK_GO

	CMP	A10,A1			;Moving out, are we greater?
	JRLE	SALTP_CLR_Z		;BR = We hit the target

	MOVE	B1,A14			;Velocity check in the neg direction
	CMP	A7,A14
	JRGT	SALTP_END_CK		;BR = We still need more velocity

SALTP_Z_TARGET_VEL
	MOVE	A7,@ZSCROLL,L		;Put our velocity right on target
	CLR	A14
	MOVE	A14,@ZSACCEL,L		;So that means no more accelerating
	JRUC	SALTP_END_CK

SALTP_CLR_Z
	CLR	A7	     		;Stop the Z
	MOVE	A7,@ZSACCEL,L
	BTST	B_Z,A4
	JRNZ	SALTP_END_CK
	MOVE	A10,@ZBASE_HR,L	
	MOVE	A10,A14
	SRA	ZFRAC,A14
	MOVE	A14,@ZBASE,L
	MOVE	A7,@ZSCROLL,L

SALTP_END_CK
	CLR	A14			;Are we all done?
	ADD	A5,A14
	ADD	A6,A14
	ADD	A7,A14
	JRNZ	SALTP_WAIT		;BR = No, we must wait some more

	JAUC	SCRL_DISPATCHER

**************************************************************************
*								         *
* S_MAKE_DECISION	- CREATE OBJECTS FOR DECISION POINT		 *
*								         *
* TABLE ENTRY:								 *
* 	.LONG	S_MAKE_DECISION						 *
* 	LW	GO LEFT JUMP POINT, # of times allowed	;-X    00	 *
* 	LW	GO RIGHT JUMP POINT, # of times allowed	;+X    30	 *
* 	LW	GO UP JUMP POINT, # of times allowed	;-Y    60	 *
* 	LW	GO DOWN JUMP POINT, # of times allowed	;+Y    90	 *
* 	LW	GO OUT JUMP POINT, # of times allowed	;-Z    C0	 *
* 	LW	GO IN JUMP POINT, # of times allowed	;+Z    A0	 *
*								         *
**************************************************************************
ODEST		EQU	ODATA	  	;UHL Scroll vector for this obj
ODEST_COUNT	EQU	ODATA+020H	;UHL Ptr to counter for this vector
OWAVEIRQS	EQU	ODATA+040H	;UHL WAVEIRQS upon activation
OXSCROLL_CK	EQU	ODATA+060H	;UHL X scroll check value
OYSCROLL_CK	EQU	ODATA+080H	;UHL Y scroll check value
OZSCROLL_CK	EQU	ODATA+0A0H	;UHL Z scroll check value
OACTIVE_TIME	EQU	ODATA+0C0H	;UHW Remaining active time for button.

DECISION_CNT	.EQU	6		;This many decisions per table

BUTTON_FLASH_COLOR	.EQU	1010H

S_MAKE_DECISION
	MOVK	1,A14			;Set proper flags for decision
	MOVE	A14,@IN_MAKE_DECISION,W
	MOVE	A14,@HOLD_ENEMY_DISPATCH,W

	CLR	A14
	MOVE	A14,@DISPATCH_DELAY,W	;This guy is not needed
	MOVE	A14,@DECISION_MADE,W

	move	A11,A1
	callr	Find_Decision		;Has this decision been loaded?
	jrnz	MD_Got_Decision_RAM	;BR = Yes, A0 = ptr to array
	move	A0,A9			;We must load the new decision here
	move	A11,*A9+,L		;Store the address of the ROM table
	movk	DECISION_CNT,A6		;Load the vector counts in RAM
	move	A11,A1
	addk	20h,A1
MD_Load_Decision_Loop
	move	*A1+,*A9+,W
	addk	20h,A1
	dsjs	A6,MD_Load_Decision_Loop
MD_Got_Decision_RAM
	move	A0,A9			;Keep a copy of the RAM ptr here
	addk	MDec_Left_Cnt,A9	;Offset to the counters

*Let's actually offer the decision here.
	move	A11,A1
	move	A9,A2
	movk	DECISION_CNT,A6		;Load the vector counts
	clr	A10			;We'll count up in this reg
MD_Vector_Search_Loop
	move	*A1+,A14,L		;Get the vector address
	jrz	MD_No_Vector		;BR = not even an option
	move	*A2,A14,W		;Get the choices left
	jrz	MD_No_Vector		;BR = no choices left on this vector
	inc	A10			;We've got another one
MD_No_Vector
	addk	10h,A1			;Skip ROM count value in table
	addk	10h,A2			;Inc here to insure that it happens
	dsjs	A6,MD_Vector_Search_Loop

	cmpi	1,A10			;Is there just one valid?
	jreq	MD_Select		;BR = yes, then select it.
	jrlt	MD_Wait			;BR = Nothing left, just hang here

	mmtm	A12,A9,A10,A11		;Store these for later

	movi	TEXT_INIT,B0
	calla	MULTIMAKE		;Make the header
	jrz	MD_Random_Choose	;BR = not enough, just choose for us

	movk	6,A10			;Doing this many buttons
	movi	LEFT_INIT,B0
MD_DIR_LUPE
	calla	MULTIMAKE
	jrz	MD_Random_Choose	;Something is fucked, make a choice

	move	*A11+,A2,L		;Get the SCROLL vector, 0 = inactive
	addk	10h,A11			;Skip the choice
	move	A2,*A8(ODEST),L
	move	A9,*A8(ODEST_COUNT),L
	addk	10h,A9

	dsj	A10,MD_DIR_LUPE

	sleep	15*60			;Wait for bozo to pick

MD_Random_Choose
	move	@DECISION_MADE,A14,W	;Did a decision get made somewhere?
	jrnz	MD_Wait			;BR = Yes, just go wait for the effect.

	mmfm	A12,A9,A10,A11		;Store these for later

*We must select one for the player.
*A9 = ptr to RAM table of choice counts
*A10 = number of valid options (1 through DECISION_CNT)
*A11 = ptr to ROM vector table
MD_Select
	move	A10,A0
	calla	RANDU			;Get it randomly

	movk	DECISION_CNT,A6		;Load the vector counts
MD_Vector_Choose_Loop
	move	*A11+,A3,L		;Get the vector address
	jrz	MD_Choose_No_Vector	;BR = not even an option
	move	*A9,A4,W		;Get the choices left
	jrz	MD_Choose_No_Vector	;BR = no choices left on this vector
	dec	A0			;Take this one
	jrne	MD_Choose_No_Vector	;BR = No, try next

*Try to locate object that matches this vector, and let it do the choosing
	movi	FGLIST,A5		;Get the FGND list
	movi	OID_DIR,A7		;And we want this direction
	MOVE	A5,A8
	JRUC	MD_Search_Test

MD_Search_Loop
	move	*A8(OID),A14,W
	zext	A14
	cmp	A14,A7			;Is this our #1 guy?
	jrne	MD_Search_Test		;BR = no
	
	move	*A8(OPART1),A14,L	;Is this a multi-part button
	jrz	MD_Search_Test		;BR = no
	cmp	A8,A14			;Is this the head part?
	jrne	MD_Search_Test		;BR = no

	move	*A8(ODEST),A14,L
	cmp	A14,A3			;Is this the proper button?
	jrne	MD_Search_Test		;BR = no

*Found it
	move	A9,A1			;Put dat in the correct place
	callr	MDG_Directon_Selected	;Do it the normal way
MD_Wait
	SLOOP	5000,MD_Wait		;And wait to be picked up

MD_Search_Test
	move	*A8,A8,L
	cmp	A8,A5
	jrne	MD_Search_Loop

*Not found, just do it ourselves and cruise

	MOVKM	1,@DECISION_MADE,W	;Flag the decision

	CLR	A14			;We are no longer deciding
	MOVE	A14,@IN_MAKE_DECISION,W
	MOVE	A14,@HOLD_ENEMY_DISPATCH,W

	movi	OID_DIR,A0
	calla	KILOBJ_ALL		;Kill all buttons

	dec	A4
	move	A4,*A9,W		;Decrement the count
	move	A3,A11
	jauc	SCRL_DISPATCHER

MD_Choose_No_Vector
	addk	10h,A9			;Move forward
	addk	10h,A11
	dsj	A6,MD_Vector_Choose_Loop
	LOCKUP
	DIE

**************************************************************************
*								         *
* S_CLEAR_CHOICE_COUNT - Scroll func to clear a given choice counter	 *
* 			for a stored decision point.			 *
* A11 = Ptr to:								 *
* 		.LONG	Ptr to ROM Decision table.			 *
* 		.WORD	Direction offset to clear			 *
*								         *
**************************************************************************
S_CLEAR_CHOICE_COUNT
	move	*A11+,A1,L
	move	*A11+,A2,W
	callr	Find_Decision		;Is this decision loaded?
	jrz	SCCC_X			;BR = No, don't do anything
	add	A2,A0			;Offset to the correct direction
	clr	A14
	move	A14,*A0,W		;Clear the choices left
SCCC_X
	jauc	SCRL_DISPATCHER

**************************************************************************
*								         *
* 	S_BRANCH_NO_CHOICE						 *
* 									 *
* 	Check the given decision point and if no choices are left	 *
* 	then take branch, otherwise fall through.			 *
* 									 *
* A11 = Ptr to:								 *
* 		.LONG	Ptr to ROM decision table.			 *
* 		.LONG	Scroll table branch to take if clear		 *
*								         *
**************************************************************************
S_BRANCH_NO_CHOICE
	MOVE	*A11+,A1,L		;Get decision pnt to check
	MOVE	*A11+,A2,L		;Get branch in case we need it
	CALLR	Find_Decision		;Is the decision loaded?
	JRZ	SBNC_TAKE_BRANCH	;BR = No, assume they are all clear
	ADDK	20H,A0			;Get past table I.D.
	MOVK	DECISION_CNT,A6		;Let's take a look see at the counts
SBNC_NEXT
	MOVE	*A0+,A14,W		;Do we have a choice left here?
	JRNZ	SBNC_NO_BRANCH		;BR = Yes, now we've failed, so no branch
	DSJS	A6,SBNC_NEXT
SBNC_TAKE_BRANCH
	MOVE	A2,A11			;Load branch address
SBNC_NO_BRANCH
	JAUC	SCRL_DISPATCHER

**************************************************************************
*								         *
* 	S_MAKE_SOLO_BUTTON						 *
* 									 *
* 	Scroll func to create a solo directional button that		 *
* 	pulls down from the top of the screen for a fixed amount	 *
* 	of time or until the direction changes.				 *
* 	Kills all other active buttons, so beware!			 *
* 									 *
* 	*A11+,L = Scroll jump vector					 *
* 	*A11+,W = Direction						 *
* 	*A11+,W = Duration						 *
* 									 *
* 	Valid Directions:						 *
* 			0 = Left					 *
* 			1 = Right					 *
* 			2 = Up						 *
* 			3 = Down					 *
* 			4 = Out						 *
* 			5 = In						 *
*								         *
**************************************************************************
S_MAKE_SOLO_BUTTON
	MOVI	OID_DIR,A0
	CALLA	KILOBJ_ALL		;Kill any other buttons

	MOVE	*A11+,A9,L		;Get our params
	MOVE	*A11+,A1,W
	MOVE	*A11+,A10,W
	MOVE	A1,B0
	SLL	5,B0
	ADDI	TAB_SOLO_BUTTONS,B0	;Index into direction init table
	MOVE	*B0,B0,L
	CALLA	MULTIMAKE		;Make the button
	JAZ	SCRL_DISPATCHER		;BR = not enough, no choosing, sorry.
	
	CLRM	@DECISION_MADE,W

	MOVE	A9,*A8(ODEST),L		;Set the destination
	MOVE	A10,*A8(OACTIVE_TIME),W	;Set the active time
	
	JAUC	SCRL_DISPATCHER		;And get back to business

**************************************************************************
*								         *
* 	S_MAKE_DUAL_BUTTONS						 *
* 									 *
* 	Scroll func to create two directional buttons that		 *
* 	pull down, side by side, from the top of the screen		 *
* 	for a fixed amount of time or until the direction changes.	 *
* 	Button #1 appears on the left.					 *
* 	Kills all other active buttons, so beware!			 *
* 									 *
* 	*A11+,L = Scroll jump vector button #1				 *
* 	*A11+,W = Direction for button #1				 *
* 	*A11+,W = Duration for button #1				 *
* 	*A11+,L = Scroll jump vector button #2				 *
* 	*A11+,W = Direction for button #2				 *
* 	*A11+,W = Duration for button #2				 *
* 									 *
* 	Valid Directions:						 *
* 			0 = Left					 *
* 			1 = Right					 *
* 			2 = Up						 *
* 			3 = Down					 *
* 			4 = Out						 *
* 			5 = In						 *
*								         *
**************************************************************************
S_MAKE_DUAL_BUTTONS
	MOVI	OID_DIR,A0
	CALLA	KILOBJ_ALL		;Kill any other buttons

	MOVE	*A11+,A9,L		;Get our params
	MOVE	*A11+,A1,W
	MOVE	*A11+,A10,W
	MOVE	A1,B0
	SLL	5,B0
	ADDI	TAB_SOLO_BUTTONS,B0	;Index into direction init table
	MOVE	*B0,B0,L
	CALLA	MULTIMAKE		;Make the button
	JAZ	SCRL_DISPATCHER		;BR = not enough, no choosing, sorry.

	MOVE	A9,*A8(ODEST),L		;Set the destination
	MOVE	A10,*A8(OACTIVE_TIME),W	;Set the active time
	
	MOVE	A8,A0
SMDB_BUT1_LP
	SUBIM	50,*A0(OXPOS),W
	MOVE	*A0(OPARTS),A0,L
	JRNZ	SMDB_BUT1_LP

	MOVE	*A11+,A9,L		;Get our params
	MOVE	*A11+,A1,W
	MOVE	*A11+,A10,W
	MOVE	A1,B0
	SLL	5,B0
	ADDI	TAB_SOLO_BUTTONS,B0	;Index into direction init table
	MOVE	*B0,B0,L
	CALLA	MULTIMAKE		;Make the button
	JAZ	SCRL_DISPATCHER		;BR = not enough, no choosing, sorry.

	MOVE	A9,*A8(ODEST),L		;Set the destination
	MOVE	A10,*A8(OACTIVE_TIME),W	;Set the active time

	MOVE	A8,A0
SMDB_BUT2_LP
	ADDIM	50,*A0(OXPOS),W
	MOVE	*A0(OPARTS),A0,L
	JRNZ	SMDB_BUT2_LP

	CLRM	@DECISION_MADE,W

	JAUC	SCRL_DISPATCHER		;And get back to business

**************************************************************************
*								         *
* Find_Decision - Find a given decision points RAM area, if it exists.	 *
* A1 = Address of ROM decision vector table to find.			 *
* Returns								 *
* 	 Z = Decision not currently stored, A0 = Next open decision area *
* 	NZ = Decision located, A0 = Ptr to decision RAM.		 *
*								         *
**************************************************************************
Find_Decision
	PUSH	A2
	movk	MDec_Num,A2
	movi	MDec_RAM,A0
FD_Loop
	move	*A0,A14,L		;Grab I.D.
	jrz	FD_Exit			;BR = Done, none found, use this.
	cmp	A14,A1			;Is this the one we want? 
	jreq	FD_Found		;BR = Yes
	addi	MDec_Size,A0		;Move on to the next
	dsjs	A2,FD_Loop		;Did we do 'em all?
	LOCKUP				;If we're here, then were out of space
FD_Found
	CLRZ				;Flag that we found it
FD_Exit
	PULL	A2
	rets

**************************************************************************
*								         *
* MAKE_DECISION_GUNVECT	- GUN VECTOR FOR DIRECTION CHOSEN		 *
* A8 = Ptr to Symbol object						 *
* *A8(ODEST),L = Scroll jump point, 0 = not an active direction		 *
*								         *
**************************************************************************

MAKE_DECISION_GUNVECT
	move	@DECISION_MADE,A14,W	;Has a decision already been made?
	jrnz	MDG_Abort		;BR = Yes

	calla	GET_HEAD_PART		;Get the head object

	MOVE	*A8(OWAVEIRQS),A0,L
	MOVE 	@WAVEIRQS,A1,L
	SUB	A0,A1
	CMPI	30,A1
	JRLT	MDG_Abort		;BR = UNDER MINIMUM DECISION TIME

	MOVE	*A8(ODEST),A11,L	;Is this an active direction?
	jrz	MDG_Not_Active		;BR = No

	move	*A8(ODEST_COUNT),A1,L		
	move	*A1,A4,W		;Does it have any choices left to give
	jrnz	MDG_Directon_Selected	;BR = Yes
*
*Direction is not active, must make denial sound.
*
MDG_Not_Active
	SOUND1	SND_DIR_INACTIVE	;He picked the wrong one baby, uh huh!
	jruc	MDG_Abort
*
*	Wake up the Scroll Process at SCRL_DISPATCHER with the next table ptr
*	in a11
*	Choice counter in A1
*	Current Choice count in A4
*Note: People call this directly, so beware if you push on stacky
MDG_Directon_Selected
	dec	A4			;Decrement the choice count
	move	A4,*A1,W		;And store it away

	SOUND1	SND_DIR_CHOSEN		;He picked one!

	MOVKM	1,@DECISION_MADE,W	;Flag the decision

	movi	OID_JUNK,A1
	calla	CHANGE_OID_MULTI	;Make us generic now

	movi	OID_DIR,A0
	calla	KILOBJ_ALL		;Kill the other buttons

	move	*A8(OPARTS),A0,L	;Grab the button part
	movim	BUTTON_FLASH_COLOR,*A0(OCONST),W
	movi	ANIM_BUTTON_CHOSEN,A1
	jauc	SetAnim	
MDG_Abort
	RETS

**************************************************************************
*								         *
* A_Go_Scroll_Decison - Anim func to execute scroll decision based on	 *
* 			button hit.					 *
* A8 = Ptr to head of button.						 *
*								         *
**************************************************************************
A_Go_Scroll_Decison
	CLR	A14			;Clear proper flags for decision
	MOVE	A14,@IN_MAKE_DECISION,W
	MOVE	A14,@HOLD_ENEMY_DISPATCH,W

	MOVE	*A8(ODEST),A0,L
	CALLA	CHNG_SCRL_TBL

	jauc	DELETE_OBJ			;Delete the button
SND_DIR_INACTIVE
	.WORD	0F3FAH,22,81FFH,0		;Bonk sound for illegal direc.
SND_DIR_CHOSEN
	.WORD	0F3FBH,64,81FEH,0		;Player chose a direction.

*
*Animation to activate a solo button.
*
ANIM_SOLO_ACTIVE
	LWLL	1,13|AFunc,A_SET_OYVEL+2,40000H
	LWL	1,1|AFunc,CLR_VEL

	LWL	1,1|AFunc,A_SOLO_BUTTON
ANIM_SOLO_FLASH
	LWLL	1,6|AFunc,A_CHANGE_PAL+2,P_SYMGRN
	LWLL	1,5|AFunc,A_CHANGE_PAL+2,P_SYMNORM
	LWLL	1,1|AFunc,A_SOLO_CK+2,ANIM_SOLO_FLASH

ANIM_SOLO_UP
	LWLL	1,13|AFunc,A_SET_OYVEL+2,-40000H
	LWL	1,1|AFunc,DELETE_OBJ

*
*Animation when a solo button has been shot
*
ANIM_SOLO_CHOSEN
	LWLL	1,1|AFunc,A_CHANGE_PAL+2,P_SYMGRN
	LWL	1,1|AFunc,A_AnimGo+2,ANIM_SOLO_UP

;	LWLW	1,1|AFunc,A_Set_AnimLoop+1,4
;ANIM_SOLO_WHITE_FLASH
;	LW	1,1|AMulti
;	LWL	1,4|AFunc,OBJ_CONST
;	LW	1,1|AMulti
;	LWL	1,3|AFunc,OBJ_WNZ
;	LWLL	1,1|AFunc,A_Anim_DSJ+2,ANIM_SOLO_WHITE_FLASH
;	LWL	1,1|AFunc,A_AnimGo+2,ANIM_SOLO_UP

**************************************************************************
*								         *
* 	A_SOLO_BUTTON							 *
* 									 *
* 	Anim func to activate the solo directional button that has	 *
* 	just dropped from the sky.					 *
* 									 *
* 	A8 = Ptr to button						 *
*								         *
**************************************************************************
A_SOLO_BUTTON
	MOVE	@XSCROLL,A14,L	
	MOVE	A14,*A8(OXSCROLL_CK),L
	MOVE	@YSCROLL,A14,L	
	MOVE	A14,*A8(OYSCROLL_CK),L
	MOVE	@ZSCROLL,A14,L	
	MOVE	A14,*A8(OZSCROLL_CK),L

	MOVI	SOLO_BUTTON_GUNVECT,A1
	MOVE	A8,A0
ASB_LOOP
	MOVE	A1,*A0(OGUNVECT),L
	MOVE	*A0(OPARTS),A0,L
	JRNZ	ASB_LOOP

	RETS

**************************************************************************
*								         *
* 	A_SOLO_CK							 *
* 									 *
* 	Anim func to check if we should make this solo button		 *
* 	bail.								 *
* 									 *
* 	A8 = Ptr to head of the button.					 *
* 	AARG+,L = Anim branch if not finished.				 *
*								         *
**************************************************************************
A_SOLO_CK
	MOVE	*A8(OXSCROLL_CK),A14,L	;What was the XSCROLL when we started?
	JRNZ	ASC_CKY			;BR = It was set, leave it out of this
	MOVE	@XSCROLL,A14,L		;Is it set now?
	JRNZ	ASC_BUTTON_BAIL		;BR = Yes, then we must bail
ASC_CKY
	MOVE	*A8(OYSCROLL_CK),A14,L	;What was the YSCROLL when we started?
	JRNZ	ASC_CKZ			;BR = It was set.
	MOVE	@YSCROLL,A14,L		;Is it set now?
	JRNZ	ASC_BUTTON_BAIL		;BR = Yes, then we must bail
ASC_CKZ
	MOVE	*A8(OZSCROLL_CK),A14,L	;What was the ZSCROLL when we started?
	JRNZ	ASC_CKTIME		;BR = It was set.
	MOVE	@ZSCROLL,A14,L		;Is it set now?
	JRNZ	ASC_BUTTON_BAIL		;BR = Yes, then we must bail

ASC_CKTIME
	MOVE	*A8(OACTIVE_TIME),A1,W
	SUBK	12,A1			;Subtract the time we elapsed
	MOVE	A1,*A8(OACTIVE_TIME),W
	JRLE	ASC_BUTTON_BAIL		;BR = Time to pull the button back

	MOVE	@DECISION_MADE,A14,W
	JRNZ	ASC_BUTTON_BAIL

	JAUC	SetAnim_AFARG		;Branch to keep going

ASC_BUTTON_BAIL
	CALLA	ALL_COLLS_OFF 		;No shooting on the way up
	MOVI	ANIM_SOLO_UP,A1		;Animate it up
	JAUC	SetAnim

**************************************************************************
*								         *
* 	SOLO_BUTTON_GUNVECT						 *
* 									 *
* 	Gun vector for a solo direction button.				 *
* 									 *
* 	A8 = Ptr to button object					 *
* 	*A8(ODEST),L = Scroll jump point				 *
*								         *
**************************************************************************
SOLO_BUTTON_GUNVECT
	MOVE	@DECISION_MADE,A14,W
	JRZ	SBG_SELECT		;BR = Nobody's chosen anything
	RETS
SBG_SELECT
	CALLA	GET_HEAD_PART		;Get the head object

	MOVE	*A8(ODEST),A11,L	;Is this an active direction?

	CALLA	ALL_COLLS_OFF

	SOUND1	SND_DIR_CHOSEN		;He picked one!

	MOVKM	1,@DECISION_MADE,W

	MOVE	*A8(ODEST),A0,L
	CALLA	CHNG_SCRL_TBL		;Change the scroll

	MOVE	*A8(OPARTS),A0,L	;Grab the button part
	MOVIM	BUTTON_FLASH_COLOR,*A0(OCONST),W

	MOVI	ANIM_SOLO_CHOSEN,A1
	JAUC	SetAnim	

*
*Animation script for active directional symbol
*
ANIM_DIR_ACTIVE
	LW	1,15	; was 30
	LWL	1,1|AFunc,A_Activate_Button
ANIM_DIR_FLASH
	LWLL	1,6|AFunc,A_CHANGE_PAL+2,P_SYMGRN
	LWLL	1,6|AFunc,A_CHANGE_PAL+2,P_SYMNORM
	.long	0

ANIM_BUTTON_CHOSEN
	LWLL	1,1|AFunc,A_CHANGE_PAL+2,P_SYMGRN
	LWLW	1,1|AFunc,A_Set_AnimLoop+1,4
ANIM_Button_Flash
	LW	1,1|AMulti
	LWL	1,4|AFunc,OBJ_CONST
	LW	1,1|AMulti
	LWL	1,3|AFunc,OBJ_WNZ
	LWLL	1,1|AFunc,A_Anim_DSJ+2,ANIM_Button_Flash
	LW	1,5
	LWL	1,1|AFunc,A_Go_Scroll_Decison

**************************************************************************
*								         *
* A_Activate_Button - Anim Func to activate a multi-part direction	 *
* 			button.						 *
* A8 = Ptr to head part of button, which should be the symbol		 *
*								         *
**************************************************************************
A_Activate_Button
	move	A8,A0
	move	@WAVEIRQS,A2,L
	move	A2,*A0(OWAVEIRQS),L
	movi	MAKE_DECISION_GUNVECT,A1
AAB_Loop
	move	A1,*A0(OGUNVECT),L
	move	*A0(OPARTS),A0,L
	jrnz	AAB_Loop
	
	move	*A8(ODEST),A1,L			;Is this button active?
	jaz	PULL_ANIM_ALL			;BR = No
	move	*A8(ODEST_COUNT),A1,L		
	move	*A1,A14,W			;Does it have any milk left?
	jaz	PULL_ANIM_ALL			;BR = No

	movi	ANIM_DIR_FLASH,A1
	jauc	SetAnim

DIR_SOLO_POS	.EQU	[0,200]
DIR_SCRN_POS	.EQU	[120,200]
DIR_BUT_ZPOS	.EQU	ZMAX_REAL	; was -6000000h
TEXT_INIT
	.byte	 1, 0, 0, 4	;OBJCNT, PRCCNT, IMGPALCNT, PALCNT
	.long	P_BOX,P_SYMNORM,P_SYMOFF,P_SYMGRN	;PALETTES

	.word	OID_DIR, OM_SPOS | OM_INSERT
	.long	DIR_SCRN_POS,DIR_BUT_ZPOS	; screen position

*    .long IMG
*    .word OCTRL, OFLAGS, OZOFF, OPTION_BITS

	LWWWW	DIRBOX_TXT, DMAWNZ, M_SCRNOBJ|M_NOSCALE, 0, 0


LEFT_INIT
	.byte	 2, 0, 0, 0	;OBJCNT, PRCCNT, IMGPALCNT, PALCNT
	.word	OID_DIR, OM_SPOS | OM_INSERT
	.long	DIR_SCRN_POS,DIR_BUT_ZPOS	; screen position

*    .long IMG
*    .word OCTRL, OFLAGS, OZOFF, OPTION_BITS

	LWWWW	DIRSYM_RTLT, DMAWNZ, M_SCRNOBJ|M_NOSCALE, -1, OM_ANIM
	.long	ANIM_DIR_ACTIVE
	LWWWW	DIRBUT_LT, DMAWNZ, M_SCRNOBJ|M_NOSCALE, 0, 0

RIGHT_INIT
	.byte	 2, 0, 0, 0	;OBJCNT, PRCCNT, IMGPALCNT, PALCNT
	.word	OID_DIR, OM_SPOS | OM_INSERT
	.long	DIR_SCRN_POS,DIR_BUT_ZPOS	; screen position

*    .long IMG
*    .word OCTRL, OFLAGS, OZOFF, OPTION_BITS

	LWWWW	DIRSYM_RTLT, DMAWNZ|M_FLIPH, M_SCRNOBJ|M_NOSCALE, -1, OM_ANIM
	.long	ANIM_DIR_ACTIVE
	LWWWW	DIRBUT_RT, DMAWNZ, M_SCRNOBJ|M_NOSCALE, 0, 0

UP_INIT
	.byte	 2, 0, 0, 0	;OBJCNT, PRCCNT, IMGPALCNT, PALCNT
	.word	OID_DIR, OM_SPOS | OM_INSERT
	.long	DIR_SCRN_POS,DIR_BUT_ZPOS	; screen position

*    .long IMG
*    .word OCTRL, OFLAGS, OZOFF, OPTION_BITS

	LWWWW	DIRSYM_UPDN, DMAWNZ, M_SCRNOBJ|M_NOSCALE, -1, OM_ANIM
	.long	ANIM_DIR_ACTIVE
	LWWWW	DIRBUT_UP, DMAWNZ, M_SCRNOBJ|M_NOSCALE, 0, 0

DOWN_INIT
	.byte	 2, 0, 0, 0	;OBJCNT, PRCCNT, IMGPALCNT, PALCNT
	.word	OID_DIR, OM_SPOS | OM_INSERT
	.long	DIR_SCRN_POS,DIR_BUT_ZPOS	; screen position

*    .long IMG
*    .word OCTRL, OFLAGS, OZOFF, OPTION_BITS

	LWWWW	DIRSYM_UPDN, DMAWNZ|M_FLIPV, M_SCRNOBJ|M_NOSCALE, -1, OM_ANIM
	.long	ANIM_DIR_ACTIVE
	LWWWW	DIRBUT_DN, DMAWNZ, M_SCRNOBJ|M_NOSCALE, 0, 0

OUT_INIT
	.byte	 2, 0, 0, 0	;OBJCNT, PRCCNT, IMGPALCNT, PALCNT
	.word	OID_DIR, OM_SPOS | OM_INSERT
	.long	DIR_SCRN_POS,DIR_BUT_ZPOS	; screen position

*    .long IMG
*    .word OCTRL, OFLAGS, OZOFF, OPTION_BITS

	LWWWW	DIRSYM_OUT, DMAWNZ, M_SCRNOBJ|M_NOSCALE, -1, OM_ANIM
	.long	ANIM_DIR_ACTIVE
	LWWWW	DIRBUT_OUT, DMAWNZ, M_SCRNOBJ|M_NOSCALE, 0, 0

IN_INIT
	.byte	 2, 0, 0, 0	;OBJCNT, PRCCNT, IMGPALCNT, PALCNT
	.word	OID_DIR, OM_SPOS | OM_INSERT
	.long	DIR_SCRN_POS,DIR_BUT_ZPOS	; screen position

*    .long IMG
*    .word OCTRL, OFLAGS, OZOFF, OPTION_BITS

	LWWWW	DIRSYM_IN, DMAWNZ, M_SCRNOBJ|M_NOSCALE, -1, OM_ANIM
	.long	ANIM_DIR_ACTIVE
	LWWWW	DIRBUT_IN, DMAWNZ, M_SCRNOBJ|M_NOSCALE, 0, 0


*
*Table of solo buttons inits
*
TAB_SOLO_BUTTONS
	.LONG	SOLO_LEFT_INIT
	.LONG	SOLO_RIGHT_INIT
	.LONG	SOLO_UP_INIT
	.LONG	SOLO_DOWN_INIT
	.LONG	SOLO_OUT_INIT
	.LONG	SOLO_IN_INIT

SOLO_LEFT_INIT
	.byte	 2, 0, 0, 0	;OBJCNT, PRCCNT, IMGPALCNT, PALCNT
	.word	OID_SOLO_DIR, OM_SPOS | OM_INSERT
	.long	DIR_SOLO_POS,DIR_BUT_ZPOS	; screen position

*    .long IMG
*    .word OCTRL, OFLAGS, OZOFF, OPTION_BITS

	LWWWW	SOLOSYM_RTLT, DMAWNZ, M_SCRNOBJ|M_NOSCALE, -1, OM_ANIM
	.long	ANIM_SOLO_ACTIVE
	LWWWW	SOLO_BUTTON, DMAWNZ, M_SCRNOBJ|M_NOSCALE, 0, 0

SOLO_RIGHT_INIT
	.byte	 2, 0, 0, 0	;OBJCNT, PRCCNT, IMGPALCNT, PALCNT
	.word	OID_SOLO_DIR, OM_SPOS | OM_INSERT
	.long	DIR_SOLO_POS,DIR_BUT_ZPOS	; screen position

*    .long IMG
*    .word OCTRL, OFLAGS, OZOFF, OPTION_BITS

	LWWWW	SOLOSYM_RTLT, DMAWNZ|M_FLIPH, M_SCRNOBJ|M_NOSCALE, -1, OM_ANIM
	.long	ANIM_SOLO_ACTIVE
	LWWWW	SOLO_BUTTON, DMAWNZ, M_SCRNOBJ|M_NOSCALE, 0, 0

SOLO_UP_INIT
	.byte	 2, 0, 0, 0	;OBJCNT, PRCCNT, IMGPALCNT, PALCNT
	.word	OID_SOLO_DIR, OM_SPOS | OM_INSERT
	.long	DIR_SOLO_POS,DIR_BUT_ZPOS	; screen position

*    .long IMG
*    .word OCTRL, OFLAGS, OZOFF, OPTION_BITS

	LWWWW	SOLOSYM_UPDN, DMAWNZ, M_SCRNOBJ|M_NOSCALE, -1, OM_ANIM
	.long	ANIM_SOLO_ACTIVE
	LWWWW	SOLO_BUTTON, DMAWNZ, M_SCRNOBJ|M_NOSCALE, 0, 0

SOLO_DOWN_INIT
	.byte	 2, 0, 0, 0	;OBJCNT, PRCCNT, IMGPALCNT, PALCNT
	.word	OID_SOLO_DIR, OM_SPOS | OM_INSERT
	.long	SOLO_BUTTON,DIR_BUT_ZPOS	; screen position

*    .long IMG
*    .word OCTRL, OFLAGS, OZOFF, OPTION_BITS

	LWWWW	SOLOSYM_UPDN, DMAWNZ|M_FLIPV, M_SCRNOBJ|M_NOSCALE, -1, OM_ANIM
	.long	ANIM_SOLO_ACTIVE
	LWWWW	SOLO_BUTTON, DMAWNZ, M_SCRNOBJ|M_NOSCALE, 0, 0

SOLO_OUT_INIT
	.byte	 2, 0, 0, 0	;OBJCNT, PRCCNT, IMGPALCNT, PALCNT
	.word	OID_SOLO_DIR, OM_SPOS | OM_INSERT
	.long	DIR_SOLO_POS,DIR_BUT_ZPOS	; screen position

*    .long IMG
*    .word OCTRL, OFLAGS, OZOFF, OPTION_BITS

	LWWWW	SOLOSYM_OUT, DMAWNZ, M_SCRNOBJ|M_NOSCALE, -1, OM_ANIM
	.long	ANIM_SOLO_ACTIVE
	LWWWW	SOLO_BUTTON, DMAWNZ, M_SCRNOBJ|M_NOSCALE, 0, 0

SOLO_IN_INIT
	.byte	 2, 0, 0, 0	;OBJCNT, PRCCNT, IMGPALCNT, PALCNT
	.word	OID_SOLO_DIR, OM_SPOS | OM_INSERT
	.long	DIR_SOLO_POS,DIR_BUT_ZPOS	; screen position

*    .long IMG
*    .word OCTRL, OFLAGS, OZOFF, OPTION_BITS

	LWWWW	SOLOSYM_IN, DMAWNZ, M_SCRNOBJ|M_NOSCALE, -1, OM_ANIM
	.long	ANIM_SOLO_ACTIVE
	LWWWW	SOLO_BUTTON, DMAWNZ, M_SCRNOBJ|M_NOSCALE, 0, 0


*
*Palette to turn button symbol to normal unlit status
*
;P_SYMNORM:
;	.word	 16
;	.word	0B5H,039CEH,0294AH,01CE7H,04631H,00H,0739CH,0673BH
;	.word	05AFAH,05294H,06739H,05AD6H,052B9H,04698H,03E78H,07BDEH

*
*Palette to turn button symbol GREEN
*
P_SYMGRN:
	.word	 16
	.word	00H,039CEH,0294AH,01CE7H,04631H,0344H,0739CH,0673BH
	.word	05AFAH,05294H,06739H,05AD6H,052B9H,04698H,03E78H,07BDEH



*********************************************************************
*
*      MERGE UNIVERSE ROUTINES
*
*********************************************************************
S_MERGE_UNIV:
	move	*a11+,a8,L
	move	*a8+,a5		; num objs
	addi	7*10h,a8	; skip rest of header
	move	@ZREL_OFF,a9,L
	sra	ZFRAC,a9	; make lo res

	move	@BGHEAD_ACTIVE,a1,L	; start of active list

	move	@UNIV_ID,a4
	movi	80000000h,a2		; stuff all objs with this
	move	@FREE_LINKS,b0,L
SMU_lp:
*
*	Get a free link
*
	move	b0,a0
	move	*b0(MAP_NEXT),b14,L
	cmp	b14,b0
	jreq	SMU_abt
	move	*b0(MAP_PREV),b1,L
	move	b1,*b14(MAP_PREV),L
	move	b14,*b1(MAP_NEXT),L
	move	b14,b0
*
*	Stuff it with new info
*
	move	a0,a3
	move	a2,*a3(MAP_OBJ),L
	move	a4,*a3(MAP_ID)		; JUST universe ID, DAMAGE LEVEL IS ZERO
	move	*a8+,*a3+,L		; xfer IMG,X,Y,Z & flags
	move	*a8+,*a3+,L
	move	*a8+,*a3+,L
	move	*a8+,a14,L
	add	a9,a14			; adjust Z (for prev univ)
	move	a14,*a3+,L
	move	*a8+,*a3+
*
*	Find where link goes (a14 contains Z of new link)
*
SMU_nxtlnk_lp:
	move	*a1(MAP_Z),a6,L
	cmp	a6,a14
	jrlt	SMU_inslnk
	move	*a1(MAP_NEXT),a1,L
	jruc	SMU_nxtlnk_lp

SMU_inslnk:
*
*	Insert the new link
*
	move	*a1(MAP_PREV),a14,L	;*** INSLINK
	move	a0,*a1(MAP_PREV),L
	move	a14,*a0(MAP_PREV),L
	move	a0,*a14(MAP_NEXT),L
	move	a1,*a0(MAP_NEXT),L	;*** INSLINK

	dsj	a5,SMU_lp  		; loop back to insert next

	move	b0,@FREE_LINKS,L

	calla	SET_REFS

	sleep	3
SMU_abt:
	jauc	SCRL_DISPATCHER


S_MERGE_UNIV_OFF:
	move	*a11+,a8,L		; univ table
	move	*a11+,a0,L		; X off
	move	@XBASE,a9,L
	sub	a0,a9
	move	*a11+,a1,L		; Y off
	move	@YBASE,a10,L
	sub	a1,a10
	move	*a11+,a2,L		; Z off
	move	a11,*-a12,L
	move	@ZBASE,a11,L
	sub	a2,a11
	JSRP	MERGE_UNIV_OFF
	move	*a12+,a11,L
	jauc	SCRL_DISPATCHER


*
*	MERGE A UNIVERSE INTO THE CURRENT ONE
*
*	a8 = universe
*	a9 =  X off
*	a10 = Y off
* 	a11 = Z off
*
*	call with a JSRP
*
MERGE_UNIV_OFF:
	move	*a8+,a5		; num objs
	addi	7*10h,a8	; skip rest of header

	move	a5,a7
	cmpk	32,a7
	jrle	do_in_1
	addk	3,a5
	srl	2,a5		; do it in 4 ticks
do_in_1:
	mmtm	a12,a5,a7
MUO_lp0:
	mmfm	a12,a5,a7
	sub 	a5,a7
	jrge	MUO_ok
	add	a7,a5		; compensate on last pass
MUO_ok:
	move	@BGHEAD_ACTIVE,a1,L	; start of active list

	move	@UNIV_ID,a4
	movi	80000000h,a2		; stuff all objs with this
	move	@FREE_LINKS,b0,L
	mmtm	sp,a5,a7
	move	a5,b5
	move	@XBASE,a3,L
	sub	a9,a3
	move	@YBASE,a5,L
	sub	a10,a5
	move	@ZBASE,a7,L
	sub	a11,a7
MUO_lp1:
*
*	Get a free link
*
	move	b0,a0
	move	*b0(MAP_NEXT),b14,L
	cmp	b14,b0
	jreq	MUO_abt
	move	*b0(MAP_PREV),b1,L
	move	b1,*b14(MAP_PREV),L
	move	b14,*b1(MAP_NEXT),L
	move	b14,b0
*
*	Stuff it with new info
*
	move	a2,*a0(MAP_OBJ),L
	move	a4,*a0(MAP_ID)		; JUST universe ID, DAMAGE LEVEL IS ZERO
	move	*a8(0),*a0(MAP_IMG),L	; xfer IMG,X,Y,Z & flags
	addk	32,a8
	move	*a8+,a14,L
	add	a3,a14
	move	a14,*a0(MAP_X),L
	move	*a8+,a14,L
	add	a5,a14
	move	a14,*a0(MAP_Y),L
	move	*a8+,a14,L
	add	a7,a14			; adjust Z (for prev univ)
	move	a14,*a0(MAP_Z),L
	move	*a8(0),*a0(MAP_FLAGS)
	addk	16,a8
*
*	Find where link goes (a14 contains Z of new link)
*
MUO_nxtlnk_lp:
	move	*a1(MAP_Z),a6,L
	cmp	a6,a14
	jrlt	MUO_inslnk
	move	*a1(MAP_NEXT),a1,L
	jruc	MUO_nxtlnk_lp

MUO_inslnk:
*
*	Insert the new link
*
	move	*a1(MAP_PREV),a14,L	;*** INSLINK
	move	a0,*a1(MAP_PREV),L
	move	a14,*a0(MAP_PREV),L
	move	a0,*a14(MAP_NEXT),L
	move	a1,*a0(MAP_NEXT),L	;*** INSLINK

	dsj	b5,MUO_lp1  		; loop back to insert next
	mmfm	sp,a5,a7
	move	a7,a7
	jrle	MUO_done
	mmtm	a12,a5,a7
	move	b0,@FREE_LINKS,L
	calla	SET_REFS
	sloop	1,MUO_lp0

MUO_done:
	move	b0,@FREE_LINKS,L
	calla	SET_REFS

	sleep	3
MUO_abt:
	RETP

	.end

