 	.MLIB	"GXMACS.LIB"
	.FILE	"GXBGDATA.ASM"
	.TITLE	" <<< GXBGDATA -- GENERATION X BACKGROUND DATA >>>"
	.WIDTH	132
	.OPTION	B,D,L,T
	.MNOLIST

**************************************************************************
*								         *
* 	COPYRIGHT (C) 1992 MIDWAY MANUFACTURING COMPANY.		 *
* 		       ALL RIGHTS RESERVED.				 *
*								         *
**************************************************************************

	.INCLUDE	GX.INC	;sys\*.inc sys\*.equ *.equ
	.INCLUDE	BGNDTBL.GLO
	.INCLUDE	BGNDEQU.H

;*** GLOBAL SYMBOLS IN THIS FILE
	.def	BAKPLANE,BAKTL,BAKBITS,BAKMODS
	.def	StrtBgnd
	.DEF	CREDIT_BGND, START_BONUS, JFACTR_BGND
	.DEF	STAR_BGND,DESERT_BGND

	.DEF	AERO_BGND

	.DEF	DISC_BGND
	.DEF	TEACHER_BGND
	.DEF	CDOFFER_BGND

*SYMBOLS IN T2BGND.ASM
	.ref	BGND_UD1,BAK_STRT,BAK_END

*SYMBOLS IN T2RAM.ASM
	.REF	SKYCOLOR	;UHW full color of sky (parm to SKYUP)
	.REF	WAVE_SCROLL

	.BSS	BAKTL,32
	.BSS	BAKMODS,32
	.BSS	BAKBITS,32
PLANEBITS	.set	40*32		   ;keep multiple of 32
	;THIS TBL USED TO TELL IF A GIVEN BLOCK NEEDS TO BE INSERT ON BGND
	.BSS	BITTBL,PLANEBITS*MAXPLANES,1

	;THIS TBL USED TO TELL IF BLOCK OF DEATH STAR IS NOT DESTROYED
DSBITS	.set	PLANEBITS*3	    ;DEATH STAR FRONTPLANE NEEDS THREE
	.BSS	DSBITTBL,DSBITS,1   ;PLANES WORTH OF BITS

*VARIABLE BONUS BACKGROUND
	.BSS	BONUS_BGND,(2*16)+(2*32)	;VARIABLE BONUS BACKGROUND LIST

	.BSS	BAKPLANE,16		;really a byte, but keep aligned
	.bss	filler,16		; to keep long word aligned

;OFFSET FROM REGULAR BITTBL PTR (OPLINK) TO DSBITTBL
DSPLANE0	.set	7
DSBITOFF .SET	DSBITTBL-(BITTBL+(DSPLANE0*PLANEBITS))

*

bakpln	.set	PDATA
bakmods	.set	PDATA+020h
bakbits	.set	PDATA+040h
xrate	.set	PDATA+060h


*ALTERNATE ENTRIES FOR BGNDMODULE OF PLANE TABLE
BMODFUNC	.set	2	;EXECUTE THE PLANE FUNCTION
	.text


**************************************************************************
*								         *
* KILL_ALL_BG - ROUTINE TO KILL ALL BGLISTS EXCEPT PLANE 0		 *
*								         *
**************************************************************************

KILL_ALL_BG:
*NOW DO THE BACKGROUND OBJECTS
	MOVI	BGLISTS,A0
;	ADDI	PLNSIZ,A0			;SKIP FIRST LIST
	MOVE	@BGPLANECT,A1,W
	jrz	KBBB_X			;skip if no planes
;	DEC	A1
KBBB_LP
	CALLR	DEL_OBJLIST
	ADDI	PLNSIZ,A0
	DSJS	A1,KBBB_LP
KBBB_X:
	RETS


**************************************************************************
*								         *
* KILL_ALL_OBJECTS - ROUTINE TO KILL ALL OF THE OBJECT LISTS.		 *
*								         *
**************************************************************************
KILL_ALL_OBJECTS:
	MMTM	SP,A0,A1
*DO THE FOREGROUND FIRST
	MOVI	FGLIST,A0
	CALLR	DEL_OBJLIST
	CALLA	KILL_ALL_BG
	MMFM	SP,A0,A1
	RETS



**************************************************************************
*								         *
* DEL_OBJLIST - FUNCTION TO DELETE AN ENTIRE OBJECT LIST.		 *
* A0 = PTR TO LIST							 *
*								         *
**************************************************************************
DEL_OBJLIST
	MMTM	SP,A0,A5,A8
	MOVE	A0,A5
	MOVE	*A0,A0,L		;GET THE FIRST
	CMP	A0,A5
	JREQ	DOBJL_X			;BR = LIST IS EMPTY
DOBJL_LP
	MOVE	*A0,A8,L		;GET NEXT
	CALLA	ZAPOBJ			;DELETE THIS ONE
	MOVE	A8,A0			;WAS NEXT END?
	CMP	A0,A5
	JRNE	DOBJL_LP		;BR = NO
DOBJL_X
	MMFM	SP,A0,A5,A8
	RETS


**************************************************************************
*								         *
* START_BONUS - ROUTINE INSERT THE BONUS BACKGROUND DIRECTLY ABOVE	 *
* 		THE SCREEN. SCROLLING UP SHOULD GET YOU THERE.		 *
*								         *
**************************************************************************
START_BONUS
****	MMTM	SP,A0,A5,A7
****	MOVIM	BONUSBMOD,@BONUS_BGND,L
****	MOVE	@BGLISTS+(P_XPOS+16),@BONUS_BGND+32,W
****	MOVE	@BGLISTS+(P_YPOS+16),A14,W
****	SUBI	HBONUS,A14
****	MOVE	A14,@BONUS_BGND+48,W
****	MOVIM	0FFFFFFFFH,@BONUS_BGND+64,L
****	MOVE	@PACTIVE,A0,L
****	MOVI	PID_BGND,A5
****SB_LP
****	MOVE	*A0(PROCID),A14,W
****	CMP	A5,A14
****	JREQ	SB_FOUND
****	MOVE	*A0,A0,L
****	JRNZ	SB_LP
****	JRUC	SB_X
****SB_FOUND
****	MOVIM	BONUS_BGND,*A0(bakmods),L		;THROW IN A NEW MOD
****	movi	BITTBL,A5		;CLEAR BITS FOR THIS PLANE
****	movi	PLANEBITS/32,A7
****	clr	A14
****SB_CLRBITS
****	move	A14,*A5+,L
****	dsjs	A7,SB_CLRBITS
****	MOVI	DO_BGND,A7
****	CALLA	PUTWAKE
****SB_X
****	MMFM	SP,A0,A5,A7
	RETS

****************************************************************************
InitDSTbl
;INITIALIZE the bit table of which death star blocks have not been destroyed
;(sets all bits of DSBITTBL to 1)
	mmtm	SP,A0,A1,A2
	movi	DSBITTBL,A0
	movi	DSBITS/32,A1
	movi	0FFFFFFFFh,A2
SetBits	move	A2,*A0+,L
	dsjs	A1,SetBits
	mmfm	SP,A0,A1,A2
	rets
****************************************************************************

****************************************************************************
DSKILBLK:
;A8 ptr to OBJ which is part of front plane of death star
;clear bit which says that block is not destroyed
	mmtm	SP,A0,A14
	move	*A8(OPLINK),A0,L
	.IF DEBUG
	jrz	$
	.ENDIF
	addi	DSBITOFF,A0
	movb	*A0,A14
	.IF DEBUG
	jrnn	$
	.ENDIF
	andi	07Fh,A14
	movb	A14,*A0
;	clr	A0
;	move	A0,*A8(OPLINK),L
	mmfm	SP,A0,A14
	rets
****************************************************************************

****************************************************************************
DSCKBLK:
;A0 ptr to OBJ which is part of front plane of death star
;IF BLOCK IS NOT YET DESTROYED RETURN (NEG)
	PUSH	A0
	move	*A0(OPLINK),A0,L
	addi	DSBITOFF,A0
	movb	*A0,A0
	PULL	A0
	rets
****************************************************************************

**************************************************************************
*								         *
* SINGLE_PLANE - ROUTINE TO INITIALIZE THE DISPLAY SYSTEM TO ONE SINGLE	 *
* 		FOREGROUND PLANE.					 *
*								         *
**************************************************************************
SINGLE_PLANE
	PUSH	A10
	MOVI	NULL_BGND,A10
	CALLR	StrtBgnd
	PULLQ	A10
	RETS


**************************************************************************
*								         *
* NULL_BGND - DEFINITION OF A SINGLE FOREGROUND PLANE, NO BACKGROUND.	 *
* 		USED FOR SINGLE PAGE STUFF.				 *
*								         *
**************************************************************************
NULL_BGND
	.LONG	0			;End of Planes marker
	.long	DUMRETS

**************************************************************************
*								         *
* 	        Note on Infinity plane background tables.		 *
* 									 *
* 	A BLIMP module is now justified so that it's bottom is		 *
* 	sitting on the horizon line (if y offset = 0).  To move		 *
* 	the module above the horizon, you must provide a negative	 *
* 	Y offset, and vice-versa to move it below.			 *
* 									 *
* 	If a background is made of multiple modules, the BLSTSTRT and	 *
* 	BLSTEND operations still work.					 *
*								         *
**************************************************************************

CDOFFER_BGND
	.LONG	CDOFFERBMOD
	.WORD	00,-50H			;x start , y offset from horizon
	.LONG	0FFFFFFFFH		;end of module list
	.LONG	0H			;XRATE [16,16]
	.LONG	0			;End of Planes marker
	.long	DUMRETS

TEACHER_BGND
	.LONG	BLKBOARDBMOD
	.WORD	-20,10H			;x start , y offset from horizon
	.LONG	0FFFFFFFFH		;end of module list
	.LONG	0H			;XRATE [16,16]
	.LONG	0			;End of Planes marker
	.long	DUMRETS

DISC_BGND
	.LONG	PLATDISCBMOD
	.WORD	4CH,-10H			;x start , y offset from horizon
	.LONG	0FFFFFFFFH		;end of module list
	.LONG	0H			;XRATE [16,16]
	.LONG	0			;End of Planes marker
	.long	DUMRETS

AERO_BGND
	.LONG	TITLE1BMOD		;module
	.WORD	-26,36			;x start , y offset from horizon
	.LONG	0FFFFFFFFH		;end of module list
	.LONG	0H			;XRATE [16,16]
	.LONG	0			;End of Planes marker
	.long	DUMRETS

*
*BACKGROUND TABLE FOR CREDIT SCREEN
*
CREDIT_BGND
	;***** RATING BACKGROUND
	.LONG	PREVIEWBMOD		;module
	.WORD	0,250			;x start , y offset from horizon
	.LONG	0FFFFFFFFH		;end of module list
	.LONG	0H			;XRATE [16,16]
	.LONG	0			;End of Planes marker
	.long	DUMRETS

*
*STARFIELD BACKGROUND
*
STAR_BGND
	.LONG	stars2BMOD		;MODULE
	.WORD	0,0			;x start , y offset from horizon
	.LONG	0FFFFFFFFH		;end of module list
	.LONG	0H			;XRATE [16.16]
	.LONG	0			;End of Planes marker
	.long	DUMRETS

*
*DESERT BACKGROUND
*
DESERT_BGND
	.LONG	MIDFINITYBMOD		;MODULE
	.WORD	0,0			;x start , y offset from horizon
	.LONG	0FFFFFFFFH		;end of module list
	.LONG	0H			;XRATE [16.16]
	.LONG	0			;End of Planes marker
	.long	DUMRETS

*
*JAPANESE FACTORY BACKGROUND (LEFT)
*
JFACTR_BGND
	.LONG	FACMODBMOD		;MODULE
	.WORD	-75,175			;x start , y offset from horizon
	.LONG	0FFFFFFFFH		;end of module list
	.LONG	0H			;XRATE [16.16]
	.LONG	0			;End of Planes marker
	.long	DUMRETS

**************************************************************************
* 			WAVE SCROLL FUNCTIONS				 *
*								         *
**************************************************************************

**************************************************************************
* DUMSCROLL
* Temp proc to make bgnd move for examination purposes
****DUMSCROLL
****	movi	010000h,A0
****	move	A0,@SCROLLX,L
****	SLEEP	WRHPLANE1-SCRWIDTH
****	movi	-010000h,A0
****	move	A0,@SCROLLX,L
****	SLEEP	WRHPLANE1-SCRWIDTH
****	jruc	DUMSCROLL


**************************************************************************
*								         *
* 		      END WAVE SCROLL FUNCTIONS				 *
*								         *
**************************************************************************

****************************************************************************

KillBgnd:				  
	mmtm	SP,A0,A1,A2,A5,A6,A7,A9,A10,A11
	clr	a10	       
	CLRM	@BGPLANECT,W   
	jruc	BgEntry	       
StrtBgnd:
;A10 Plane Table
	mmtm	SP,A0,A1,A2,A5,A6,A7,A9,A10,A11
BgEntry:
	.IF	IMGBGND
	calla	InitBTbl	;Init the Block Tables
	.ENDIF

	;*** CLEAR OUT BIT TBL FOR ALL PLANES ***
	movi	BITTBL,A0
	movi	MAXPLANES*PLANEBITS/32,A1
	clr	A2
CBits1	move	A2,*A0+,L
	dsjs	A1,CBits1

	clr	A11		;Plane BG #
	movi	BGLISTS,A6	;A6 = ptr to BG PLANE struct of disp.asm

	MOVI	PID_BGND,A0
	MOVI	0FF00H,A1
	CALLA	KILALL

*FILL FOREGROUND VARIABLES JUST FOR NOW.
	MOVIM	010000H,@FGLIST+P_XRATE,L

	move	a10,a10
	jrz	SkBFunc		;Abort if no bg to kill old one.

PlaneLp:
	move	*A10+,A0,L	;Another Plane?
	jrz	PlaneX

	move	A0,A14
	andi	0Fh,A14
	jrz	MkBgPln
	cmpi	BMODFUNC,A14
	jreq	DoPlnFnc
	.IF	DEBUG
	jruc	$
	.ENDIF

	;DO SOME SPECIAL FUNCTION: i.e. check if being used in attract mode
DoPlnFnc
	;**** GOT A PLANE FUNCTION ****
	srl	4,A0
	sll	4,A0
	call	A0
	jruc	PlaneLp

	;MAKE A BACKGROUND PLANE
MkBgPln
	subk	020h,A10

	.IF	IMGBGND
	move	A10,A0
	calla	DnLdMods
	.ENDIF

	move	*A10(020h),A9,W	;should be start X of ground
	move	*A10(030h),A2,W	;should be start Y of ground

	movi	PID_BGND,A1
	SLL	4,A11
	or	A11,A1
	SRL	4,A11
	movi	DO_BGND,A7
	calla	GETPPRC
	jrz	PlaneX
	move	A11,A7
	movk	3,A1
	modu	A1,A7
	move	A7,*A0(PTIME),W	;sleep from 0 to 2 (don't do all together)
	move	A0,A7
	move	A10,*A7(bakmods),L

;* GET PTR TO BACKGROUND OBJECT LIST
	move	A6,*A7(bakpln),L
;	clr	A1
;	move	A1,*A6,L	;no objs on bakpln yet

;* find end of module list
WalkMods:
	addi	64,A10		;Look at next Module
	move	*A10,A0,L
	inc	A0		;looking for 0FFFFFFFFh
	jrnz	WalkMods
	addk	32,A10		;go to entry after module list

;* set BAKBITS ptr
	movi	PLANEBITS,A1
	mpyu	A11,A1
	addi	BITTBL,A1
	move	A1,*A7(bakbits),L

	move	*A10+,A0,L	;get XRATE
	move	A0,*A6(P_XRATE),L
	move	A0,*A7(xrate),L

;	move	A6,A0		;A0 ptr to a plane
;	calla	SetPlaneXPos

	CLRM	*A6(P_XPOS),L
	MOVE	@HORIZON,A14,W
	MOVE	@HORIZON_BASE,A0,W
	SUB	A14,A0
	SLL	16,A0
	MOVE	A0,*A6(P_YPOS),L

	;*** go on to next bgnd plane ***
	INCM	@BGPLANECT,W
	inc	A11	
	addi	PLNSIZ,A6
	jruc	PlaneLp


	;NO MORE PLANES TO BE MADE, JUST PROCESS REST OF BGND SPEC
PlaneX:
	move	*A10+,A0,L
	jrz	SkBFunc
	call	A0
SkBFunc:

	mmfm	SP,A0,A1,A2,A5,A6,A7,A9,A10,A11
	rets
****************************************************************************

****************************************************************************
DO_BGND:
;* PROCESS TO UPDATE THE BAKLST WHEN NECESSARY
;A8-PTR TO BAKPLANE
;A11-PLANE #
;
;A9-USED INTERNALLY AS LAST X POSITION UPDATED

	move	*A13(bakmods),A0,L
	move	*A0,A0,L
;	cmpi	nullBMOD,A0
;	jaeq	SUCIDE

	move	*A13(bakpln),A8,L
	move	*A8(P_XPOS+010h),A1,W
	MOVE	*A8(P_YPOS+010h),A14,W
	SLL	16,A14
	MOVY	A14,A1
	jruc	DoUpdate

BGNDLP:
	;CHECK DISTANCE FROM LAST UPDATE XPOS TO CURRENT XPOS
	move	*A8(P_XPOS+010h),A1,W
	MOVE	*A8(P_YPOS+010h),A14,W
	SLL	16,A14
	MOVY	A14,A1
	move	A9,A0
	SUBXY	A1,A0
	ABSXY	A0
GotXDist:
****	cmpi	020h,A0
	MOVI	[020h,020h],A14
	CMPXY	A14,A0
	JRXGE	DoUpdate
	JRYLT	SkUpdate
****	jrlt	SkUpdate

DoUpdate:
	move	A1,A9			;save last x position
***	move	@WORLDXY,A2,L
***	movx	A1,A2
***	move	A2,@BAKTL,L
	move	A1,@BAKTL,L

	move	*A13(bakmods),A0,L
	move	A0,@BAKMODS,L
	move	*A13(bakbits),A0,L
	move	A0,@BAKBITS,L
	movb	A11,@BAKPLANE
	calla	BGND_UD1

SkUpdate:
	movk	3,A0
	movi	BGNDLP,A7
	jauc	PRCLSP



	.end





