	.MLIB	"GXMACS.LIB"
	.FILE	"GXFADE.ASM"
	.TITLE	"<<< GENERATION X -- PALETTE FADERS AND THINGS >>>"
	.WIDTH	132
	.OPTION	B,D,L,T
	.MNOLIST

**************************************************************************
*								         *
* 	COPYRIGHT (C) 1992 MIDWAY MANUFACTURING COMPANY.		 *
* 		       ALL RIGHTS RESERVED.				 *
*								         *
**************************************************************************
			 
	.INCLUDE	"GX.INC"		;SYSTEM STUFF
	.INCLUDE	"IMGTBL.GLO"	;PALETTES FOR YOU


*SYMBOLS IN GXPALL.ASM
	.REF	PALSET

	.DEF	GO_NORMAL,GO_WHITE
	.DEF	FADEOUT_PAL

	.TEXT
	.EVEN

**************************************************************************
*								         *
* 	FADEALL								 *
* 									 *
* 	FADE EVERYTHING USING A GIVEN FADE ENTRY			 *
* 									 *
* 	ENTRY								 *
* 		A0	LIST OF PALETTES				 *
* 		A11	FADE MULT TABLE					 *
* 									 *
* 	EXIT								 *
* 		NOTHING							 *
* 									 *
* 	CALL								 *
* 		CALL							 *
*								         *
**************************************************************************

FADEALL:
	mmtm	SP,A0,A1,A2,A6,A7,A8,A9,A10,A11
	CLR	A10
	JRUC	Fader

**************************************************************************
*								         *
* 	FADEBLAK							 *
* 									 *
* 	FADE A LIST OF PALETTES TO BLACK, WITHIN ONE TICK		 *
* 									 *
* 	ENTRY								 *
* 		A0	PTR TO NULL TERMINATED LIST **NOT** TO FADE	 *
* 									 *
* 	EXIT								 *
* 		NOTHING							 *
*								         *
**************************************************************************
FADEBLAK:
	mmtm	SP,A0,A1,A2,A6,A7,A8,A9,A10,A11
	CLR	A10
	movi	FadeBlak,A11
	jruc	Fader

*FADE IN THE TEXT PALETTE ONLY TO BLACK
FADEBLAK_TEXT
	MMTM	SP,A0,A10,A11
	MOVI	TEXTPAL,A0
	movi	FadeBlak,A11
	CLR	A10
	CALLR	FADE_ONLY
	MMFM	SP,A0,A10,A11
	RETS

*FADE A SINGLE PALETTE TO BLACK (FAST)
*A0 = PALETTE I.D.
FADEBLAK_PAL 
	MMTM	SP,A10,A11
	CLR	A10
	movi	FadeBlak,A11
	CALLR	FADE_ONLY
	MMFM	SP,A10,A11
	RETS

*FADE A SINGLE PALETTE TO BLACK (AVERAGE)
*A0 = PALETTE I.D.
FADEOUT_PAL 
	MMTM	SP,A10,A11
	CLR	A10
	movi	FadeOut,A11
	CALLR	FADE_ONLY
	MMFM	SP,A10,A11
	RETS

**************************************************************************
*								         *
* 	FADEFULL							 *
* 									 *
* 	BRING A LIST OF PALETTES TO FULL BRIGHTNESS, WITHIN ONE TICK	 *
* 									 *
* 	ENTRY								 *
* 		A0	PTR TO NULL TERMINATED LIST **NOT** TO FADE	 *
* 									 *
* 	EXIT								 *
* 		NOTHING							 *
*								         *
**************************************************************************
FADEFULL:
	mmtm	SP,A0,A1,A2,A6,A7,A8,A9,A10,A11
	CLR	A10
	movi	FadeFull,A11
	jruc	Fader

*BRING TO WHITE
GO_WHITE:
	MMTM	SP,A10,A11
	MOVK	M_FADE_WHITE,A10
	movi	WHITELIST,A11
	CALLR	FADE_ONLY
	MMFM	SP,A10,A11
	RETS

*BRING TO NORMAL
GO_NORMAL:
	MMTM	SP,A10,A11
	MOVK	M_FADE_WHITE,A10
	movi	NORMLIST,A11
	CALLR	FADE_ONLY
	MMFM	SP,A10,A11
	RETS

*BRING TO WHITE
GOWHITE:
	mmtm	SP,A0,A1,A2,A6,A7,A8,A9,A10,A11
	MOVK	M_FADE_WHITE,A10
	movi	WHITELIST,A11
	jruc	Fader

*BRING TO NORMAL
GONORMAL:
	mmtm	SP,A0,A1,A2,A6,A7,A8,A9,A10,A11
	MOVK	M_FADE_WHITE,A10
	movi	NORMLIST,A11
	jruc	Fader


*BRING THE TEXT PALETTE ONLY TO FULL
FADEFULL_TEXT
	MMTM	SP,A0,A10,A11
	MOVI	TEXTPAL,A0
	CLR	A10
	movi	FadeFull,A11
	CALLR	FADE_ONLY
	MMFM	SP,A0,A10,A11
	RETS

**************************************************************************
*								         *
* 	FADEIN								 *
* 									 *
* 	FADE A LIST OF PALETTES FROM BLACK TO THEIR CURRENT COLORS	 *
* 									 *
* 	ENTRY								 *
* 		A0	PTR TO NULL TERMINATED LIST **NOT** TO FADE	 *
* 									 *
* 	EXIT								 *
* 		NOTHING							 *
*								         *
**************************************************************************
FADEIN:
	mmtm	SP,A0,A1,A2,A6,A7,A8,A9,A10,A11
	CLR	A10
	movi	FadeIn,A11
	jruc	Fader

FADEIN2:
	mmtm	SP,A0,A1,A2,A6,A7,A8,A9,A10,A11
	CLR	A10
	movi	FadeIn2,A11
	jruc	Fader

FADEINRED:
	mmtm	SP,A0,A1,A2,A6,A7,A8,A9,A10,A11
	MOVK	M_DONT_FADE_RED,A10
	movi	FadeIn2,A11
	jruc	Fader

*A10 = FADE MODE
FADEIN_ALLBUT1
	mmtm	SP,A0,A1,A2,A6,A7,A8,A9,A10,A11
	movi	FadeIn2,A11
	jruc	Fader

FADEIN_HALF
	mmtm	SP,A0,A1,A2,A6,A7,A8,A9,A10,A11
	movi	FadeBlak2Half,a11
	jruc	Fader

FADEIN_HALF_3
	mmtm	SP,A0,A1,A2,A6,A7,A8,A9,A10,A11
	movi	FadeBlak2Half3,a11
	jruc	Fader


*FADE IN A SINGLE PALETTE AT "FAST" SPEED
*A0 = PTR TO PALETTE
FADEIN_PALF
	MMTM	SP,A10,A11
	CLR	A10
	movi	FadeInF,A11
	CALLR	FADE_ONLY
	MMFM	SP,A10,A11
	RETS


*FADE IN A SINGLE PALETTE AT "NORMAL" SPEED
*A0 = PTR TO PALETTE
FADEOUT_PALF
	MMTM	SP,A10,A11
	CLR	A10
	movi	FadeOutF,A11
	CALLR	FADE_ONLY
	MMFM	SP,A10,A11
	RETS


*FADE IN A SINGLE OBJECT's PALETTE 
* a8 = object
* a0 = PALETTE ID (long)
* a11 = Fade Table
FADE_ONE
	MMTM	SP,a8,a9,A10
	move	*a8(OPAL),a9
	sll	24,a9
	srl	24,a9		; leave 8 bits
	move	a0,a8
	CLR	A10
	CREATE	PID_PFADE,FADEPROC
	MMFM	SP,a8,a9,A10
	RETS


*FADE IN A SINGLE PALETTE AT "NORMAL" SPEED
*A0 = PTR TO PALETTE
FADEIN_PAL
	MMTM	SP,A10,A11
	CLR	A10
	movi	FadeIn,A11
	CALLR	FADE_ONLY
	MMFM	SP,A10,A11
	RETS

*FAST VERSION OF FADEIN
*A0 = PTR TO TABLE OF PALETTES NOT TO FADE
FADEINF:
	mmtm	SP,A0,A1,A2,A6,A7,A8,A9,A10,A11
	CLR	A10
	movi	FadeInF,A11
	jruc	Fader

*SLOW VERSION OF FADEIN
*A0 = PTR TO TABLE OF PALETTES NOT TO FADE
FADEINS:
	mmtm	SP,A0,A1,A2,A6,A7,A8,A9,A10,A11
	CLR	A10
	movi	FadeInS,A11
	jruc	Fader

FADEIN_TEXTSLW
	MMTM	SP,A0,A11
	movi	FadeInS,A11
	jruc	FDTXTHK

*FADE IN THE TEXT PALETTE ONLY
FADEIN_TEXT
	MMTM	SP,A0,A10,A11
	movi	FadeIn,A11
FDTXTHK:
	MOVI	TEXTPAL,A0
	CLR	A10
	CALLR	FADE_ONLY
	MMFM	SP,A0,A10,A11
	RETS

**************************************************************************
*								         *
* 	FADE_HALF2FULL							 *
* 									 *
* 	FADE A LIST OF PALETTES FROM HALF TO FULL BRIGHTNESS		 *
* 									 *
* 	ENTRY								 *
* 		A0	PTR TO NULL TERMINATED LIST **NOT** TO FADE	 *
* 									 *
* 	EXIT								 *
* 		NOTHING							 *
*								         *
**************************************************************************
FADE_HALF2FULL:
	mmtm	SP,A0,A1,A2,A6,A7,A8,A9,A10,A11
	CLR	A10
	movi	FadeHalf2Full,A11
	jruc	Fader

**************************************************************************
*								         *
* 	FADE_HALF2BLAK							 *
* 									 *
* 	FADE A LIST OF PALETTES FROM HALF BRIGHTNESS TO BLACK		 *
* 									 *
* 	ENTRY								 *
* 		A0	PTR TO NULL TERMINATED LIST **NOT** TO FADE	 *
* 									 *
* 	EXIT								 *
* 		NOTHING							 *
*								         *
**************************************************************************
FADE_HALF2BLAK:
	mmtm	SP,A0,A1,A2,A6,A7,A8,A9,A10,A11
	CLR	A10
	movi	FadeHalf2Blak,A11
	jruc	Fader

**************************************************************************
*								         *
* 	FADEOUT								 *
* 									 *
* 	FADE A LIST OF PALETTES DOWN TO BLACK				 *
* 									 *
* 	ENTRY								 *
* 		A0	PTR TO NULL TERMINATED LIST **NOT** TO FADE	 *
* 									 *
* 	EXIT								 *
* 		NOTHING							 *
*								         *
**************************************************************************
FADEOUT:
	mmtm	SP,A0,A1,A2,A6,A7,A8,A9,A10,A11
	CLR	A10
	movi	FadeOut,A11
	JRUC	Fader
FADEOUTRED:
	mmtm	SP,A0,A1,A2,A6,A7,A8,A9,A10,A11
	MOVK	M_DONT_FADE_RED,A10
	movi	FadeOut2,A11
	JRUC	Fader

*A10 = FADE MODE
FADEOUT_ALLBUT1:
	mmtm	SP,A0,A1,A2,A6,A7,A8,A9,A10,A11
	movi	FadeOut2,A11
	JRUC	Fader

*FAST VERSION OF FADEOUT
*A0 = PTR TO TABLE OF PALETTES NOT TO FADE
FADEOUTF:
	mmtm	SP,A0,A1,A2,A6,A7,A8,A9,A10,A11
	CLR	A10
	movi	FadeOutF,A11
	jruc	Fader

*SLOW VERSION OF FADEOUT
*A0 = PTR TO TABLE OF PALETTES NOT TO FADE
FADEOUTS:
	mmtm	SP,A0,A1,A2,A6,A7,A8,A9,A10,A11
	CLR	A10
	movi	FadeOutS,A11
	jruc	Fader

*FADE OUT THE TEXT PALETTE ONLY
FADEOUT_TEXT
	MMTM	SP,A0,A10,A11
	MOVI	TEXTPAL,A0
	movi	FadeOutF,A11
	CLR	A10
	CALLR	FADE_ONLY
	MMFM	SP,A0,A10,A11
	RETS

**************************************************************************
*								         *
* 	FADE_FULL2HALF				   			 *
* 									 *
* 	FADE A LIST OF PALETTES DOWN TO HALF BRIGHT			 *
* 									 *
* 	ENTRY								 *
* 		A0	PTR TO NULL TERMINATED LIST **NOT** TO FADE	 *
* 									 *
* 	EXIT								 *
* 		NOTHING							 *
*								         *
**************************************************************************
FADE_FULL2HALF:
	mmtm	SP,A0,A1,A2,A6,A7,A8,A9,A10,A11
	CLR	A10
	movi	FadeFull2Half,A11
	JRUC	Fader

**************************************************************************
*								         *
* Fader - CREATE THE FADER PROCESS					 *
* 									 *
* A10 = FADE MODE							 *
*								         *
**************************************************************************

Fader:
	move	A0,A6		

;* WALK EUGENES PALETTE TABLE, START PROC TO FADE EACH PALETTE *
	clr	A9		;palette slot
	dec	A9
	movi	PALRAM-PALRSIZ,A2	;base of eugenes palette table
PalLp:
	addi	PALRSIZ,A2
	inc	A9
;	cmpi	NUMPAL,A9
	CMPI	NMFPAL,A9		;Only fade foreground palettes
	jrge	PalLpX

	move	*A2(PALCNT),A1,W	;is palette allocated?
	jrz	PalLp
	move	*A2(PALID),A8,L		;Ptr to palette
;*** SKIP FADING PALS IN LIST POINTED TO BY A6
	move	A6,A7
	jrz	SkFPalX
SkPalLp:
	move	*A7+,A1,L
	jrz	SkFPalX
	cmp	A1,A8
	jreq	PalLp
	jruc	SkPalLp
SkFPalX:
	CREATE	PID_PFADE,FADEPROC
	jruc	PalLp
PalLpX:

	mmfm	SP,A0,A1,A2,A6,A7,A8,A9,A10,A11
	rets

**************************************************************************
*								         *
* 	FADE_ONLY							 *
* 									 *
* 	FADE ONLY A CERTAIN PALETTE					 *
* 									 *
* 	ENTRY								 *
* 		A0	PALETTE TO BE FADED				 *
* 		A10	FADE MODE					 *
* 		A11	MULTIPLIER TABLE FOR PALETTES			 *
* 									 *
* 	EXIT								 *
* 		NOTHING							 *
* 									 *
* 	CALL								 *
* 		CALLA							 *
*								         *
**************************************************************************

FADE_ONLY:
	mmtm	SP,A0,A1,A2,A6,A7,A8,A9,A11
	move	A0,A6		

;* WALK EUGENES PALETTE TABLE, START PROC TO FADE EACH PALETTE *

	clr	A9		;palette slot
	dec	A9
	movi	PALRAM-PALRSIZ,A2	;base of eugenes palette table
FOPalLp:
	addi	PALRSIZ,A2
	inc	A9
	cmpi	NUMPAL,A9
	jrge	FOPalLpX

	move	*A2(PALCNT),A1,W	;is palette allocated?
	jrz	FOPalLp
	move	*A2(PALID),A8,L		;Ptr to palette
	CMP	A6,A8
	JRNZ	FOPalLp			; BR = NOT THE ONE FOR ME
	CREATE	PID_PFADE,FADEPROC
	jruc	FOPalLp
FOPalLpX:
	mmfm	SP,A0,A1,A2,A6,A7,A8,A9,A11
	rets

**************************************************************************
*								         *
* 	FADEPROC							 *
* 									 *
* 	PROCESS TO ACTUALLY FADE A PALETTE				 *
* 									 *
* 	ENTRY								 *
* 		A8	PTR TO PALETTE SOURCE DATA TO BE FADED		 *
* 		A9	PALETTE SLOT OF PALETTE				 *
* 		A10	FADE MODE					 *
* 		A11	FADE MULTIPLIER TABLE				 *
* 									 *
* 	EXIT								 *
* 		NOTHING							 *
* 									 *
* BIG NOTE: MAKE SURE PALETTE I.D. STAYS IN A8 DURING ALL SLEEPS.	 *
* 	  ROUTINE KILL_FADE WILL RELY ON THIS INFORMATION!!!!		 *
*								         *
**************************************************************************
FADEPROC:
*REMOVED .YUNIT STUFF
	sll	24,A9		
	srl	16,A9		;B8-15 DEST PAL | B0-7 START COLOR
FadePLp:
	;**** SET UP FADED PAL IN PROCESS DATA SPACE ****
	move	*A11+,A2,W	;A2 - Color Multiplier
	jrn	FadePrcX
	move	A13,A0
	addi	PDATA+010h,A0	;A0 - Dest Ram for Pal
	move	A8,A1		;A1 - Src for Pal
	callr	FadePal
	;**** GET FADED PALETTE XFERRED TO PALRAM ****
FadeP_Retry
	move	A9,A1		;B8-15 DEST PAL | B0-7 START COLOR
	move	A13,A0
	addi	PDATA+010h,A0	;SRC FOR XFER
	move	*A0+,A2,W	;GET # COLORS IN PALETTE
	calla	PALSET		;SETUP PALETTE TRANSFER
	jrnz	FadeP_Set	;BR = Transfer was setup correctly

	SLOOP	1,FadeP_Retry	;We failed to get the Xfer, try again

FadeP_Set
	SLOOP	1,FadePLp

FadePrcX:
	SLEEP	1		;give last xfer a chance to go
	DIE

**************************************************************************
*								         *
* 	FADEPAL								 *
* 									 *
* 	APPLY THE COLOR MULTIPLIER AND DO ONE ITERATION ON THE PALETTE	 *
* 									 *
* 	ENTRY								 *
* 		A0	DESTINATION RAM FOR PALETTE			 *
* 		A1	SOURCE FOR PALETTE				 *
* 		A2	COLOR MULTIPLIER				 *
* 		A10     FADE MODE					 *
* 									 *
* 	EXIT								 *
* 		NOTHING							 *
* 									 *
* 	NOTE:	EACH COLOR IN PALETTE WILL BE MULTIPLIED BY A2 THEN 	 *
* 		DIVIDED BY 128						 *
*								         *
**************************************************************************
FadePal:
	mmtm	SP,A8,A9,A10,A11
	MOVE	A10,B0
	pushst
	setf	8,0,1

	move	*A1+,A14,W
	move	A14,*A0+,W
	sll	23,A14		;top bits of field are flags
	srl	23,A14		;	only 9 bits needed for # colors

	movi	07C00h,A4	;A4 - Pre Mult Mask for 5 bits of red
	movi	003E0h,A6	;A6 - Pre Mult Mask for 5 bits of green
	movi	0001Fh,A8	;A8 - Pre Mult Mask for 5 bits of blue
	move	A4,A9
	move	A6,A10
	move	A8,A11
	BTST	B_FADE_WHITE,B0
	JRNZ	FadeLp		;BR=WHITE MODE
	sll	7,A9		; A9 - Post Mult Max for 5 bits of red
	sll	7,A10		;A10 - Post Mult Max for 5 bits of green
	sll	7,A11		;A11 - Post Mult Max for 5 bits of blue

FadeLp:
	move	*A1+,A3,W	;A3 - RED
	move	A3,A5		;A5 - GREEN
	move	A3,A7		;A7 - BLUE
	and	A4,A3
	JRNZ	RED_GOOD		;BR=RED EXISTS
	BTST	B_FADE_WHITE,B0
	JRZ	RED_GOOD		;BR=NOT WHITE MODE
	MOVI	0400h,A3		;SET RED TO 1
RED_GOOD
	and	A6,A5
	JRNZ	GREEN_GOOD		;BR=GREEN EXISTS
	BTST	B_FADE_WHITE,B0
	JRZ	GREEN_GOOD		;BR=NOT WHITE MODE
	MOVK	020h,A5			;SET GREEN TO 1
GREEN_GOOD
	and	A8,A7
	JRNZ	BLUE_GOOD		;BR=BLUE EXISTS
	BTST	B_FADE_WHITE,B0
	JRZ	BLUE_GOOD		;BR=NOT WHITE MODE
	MOVK	01h,A7			;SET BLUE TO 1
BLUE_GOOD
	BTST	B_DONT_FADE_RED,B0
	JRZ	DO_RED			;BR = FADE RED
	SLL	7,A3			;RED ONLY MODE, SKIP RED ADJUSTMENT
	JRUC	NO_RED
DO_RED	
	mpyu	A2,A3
NO_RED
	BTST	B_DONT_FADE_GREEN,B0
	JRZ	DO_GREEN		;BR = FADE GREEN
	SLL	7,A5			;GREEN ONLY MODE, SKIP GREEN ADJUSTMENT
	JRUC	NO_GREEN
DO_GREEN	
	mpyu	A2,A5
NO_GREEN
	BTST	B_DONT_FADE_BLUE,B0
	JRZ	DO_BLUE			;BR = FADE BLUE
	SLL	7,A7			;BLUE ONLY MODE, SKIP BLUE ADJUSTMENT
	JRUC	NO_BLUE
DO_BLUE	
	mpyu	A2,A7
NO_BLUE
	cmp	A9,A3
	jrle	RedOk			;BR=BELOW LIMIT
	move	A9,A3
RedOk:
	cmp	A10,A5
	jrle	GreenOk			;BR=BELOW LIMIT
	move	A10,A5	
GreenOk:
	cmp	A11,A7
	jrle	BlueOk			;BR=BELOW LIMIT
	move	A11,A7
BlueOk:
	and	A9,A3
	and	A10,A5

	or	A5,A3
	or	A7,A3
	BTST	B_FADE_WHITE,B0
	JRNZ	NO_SHIFTING		;BR=WHITE MODE
	srl	7,A3
NO_SHIFTING
	move	A3,*A0+,W
	DSJ	A14,FadeLp

	popst
	mmfm	SP,A8,A9,A10,A11
	rets


*
*KILL JUST THE TEXT PALETTE FADER
*
KILLFADE_TEXT
	PUSH	A1
	MOVI	TEXTPAL,A1
	CALLR	KILLFADE
	PULLQ	A1
	RETS

**************************************************************************
*								         *
* KILLFADE - ROUTINE TO FIND A FADE PROCESS FOR A SPECIFIC PALETTE	 *
* 	   AND KILL IT.							 *
* A1 = PALETTE I.D. (PTR TO SOURCE DATA)				 *
*								         *
**************************************************************************
KILLFADE
	MMTM	SP,A0,A2,A4,A8
	MOVI	ACTIVE,A2
	MOVI	PID_PFADE,A4
KF_LP
	MOVE	*A2,A2,L	;GET NEXT
	JREQ	KF_X		;ALL DONE
KF_LP_LP
	MOVE	*A2(PROCID),A14
	ZEXT	A14
	CMP	A4,A14		;IS THIS A FADE PROCESS?
	JRNE	KF_LP		;BR = NO
	MOVE	A2,A0
	CALLA	GETA8
	CMP	A8,A1		;IS IT THE CORRECT FADE PROCESS?
	JRNE	KF_LP		;BR = NO
	MOVE	*A2,A2,L	;GET NEXT BEFORE KILL
	CALLA	KILL
	MOVE	A2,A2		;IS THERE ANOTHER?
	JRNZ	KF_LP_LP	;BR = YES
KF_X
	MMFM	SP,A0,A2,A4,A8
	RETS
	
*
*FADE TABLES
*
FadeBlak: .word	0,0FFFFh
FadeFull .WORD	128,0FFFFh
FadeInF	.word	8,24,40,56,72,88,104,120,128,0FFFFh
FadeIn	.word	0,0,8,16,24,32,40,48,56,64,72,80,88,96,104,112,120,128,0FFFFh
FadeInS	.word	0,0,4,8,12,16,20,24,28,32,36,40,44,48,52,56,60,64,68,72,76
	.word	80,84,88,92,96,100,104,108,112,116,120,124,128,0FFFFh
FadeHalf2Full .word 64,72,80,88,96,104,112,120,128,0FFFFh
FadeHalf2Blak .WORD 64,56,48,40,32,24,16,8,0,0FFFFh
FadeBlak2Half	.WORD 0,8,16,24,32,40,48,56,64,0FFFFh
FadeBlak2Half3	.WORD 0,8,16,24,32,40,48,0FFFFh

FadeOut	.word	120,112,104,96,88,80,72,64,56,48,40,32,24,16,8,0,0FFFFh
FadeOutF .word	120,104,88,72,56,40,24,8,0,0FFFFh
FadeOutS .word	128,124,120,116,112,108,104,100,96,92,88,84,80,76,72
	.word	68,64,60,56,52,48,44,40,36,32,28,24,20,16,12,8,4,0,0FFFFh
FadeFull2Half .word 120,112,104,96,88,80,72,64,0FFFFh

;FadeIn2	 .word	0,2,4,8,16,32,64,128,0FFFFh
FadeIn2	 .word	8,16,24,32,40,48,56,64,72,80,88,96,104,112,120,128,0FFFFh

FadeOut2 .word	120,112,104,96,88,80,72,64,56,48,40,32,24,16,8,0,0FFFFh

WHITELIST .WORD	2,4,8,16,32,0FFFFh

NORMLIST .WORD	16,8,4,2,1,0FFFFh

	.if 0	;The junk pile

**************************************************************************
*								         *
* 	FADE_256...							 *
* 									 *
* 	FADE Four consecutive palettes (used by movie process)           *
* 	ENTRY								 *
* 		A0	LAST PALETTE SLOT NUMBER 			 *
*		A1	Fade Table to use	                   	 *
* 									 *
* 	EXIT								 *
* 		NOTHING							 *
*								         *
**************************************************************************
FADE_256_BLAK:
	movi	FadeBlak,a1
	jruc	FADE_256

FADE_256_IN:
	movi	FadeIn,a1
	jruc	FADE_256

FADE_256_OUT:
	movi	FadeOutS,a1

FADE_256:
	mmtm	SP,A0,A1,A2,A3,a4,A7,a8,a9,A10,a11
	move	a1,a11
	move	a0,a9

	move	a9,a3
	sll	6,a3		; since PALRSIZ = 40h
************************************************************************
*   IF PALRSIZ IS NOT A POWER OF TWO, REPLACE THE ABOVE LINE WITH...	
*	MOVI	PALRSIZ,A3	; old way
*	MPYU	A9,A3
************************************************************************
	addi	PALRAM+PALRSIZ,A3
	movk	4,a4
f256olp:
	subi	PALRSIZ,a3
	move	*A3(PALCNT),A2,W	;is palette allocated?
	jrz	f256olp
	move	*A3(PALID),A8,L		;Ptr to palette
	CLR	A10
	CREATE	PID_PFADE,FADEPROC
 	dec	a9
	dsjs	a4,f256olp

	mmfm	SP,A0,A1,A2,A3,a4,A7,a8,a9,A10,a11
	rets

**************************************************************************
*								         *
* 	FADE_64...							 *
* 									 *
* 	FADE one palette (used by movie process)                         *
* 	ENTRY								 *
* 		A0	PALETTE SLOT NUMBER				 *
*		A1	Fade Table to use	                   	 *
* 									 *
* 	EXIT								 *
* 		NOTHING							 *
*								         *
**************************************************************************
FADE_64_IN:
	movi	FadeIn,a1
	jruc	FADE_64

FADE_64_BLAK:
	movi	FadeBlak,a1
FADE_64:
	mmtm	SP,A0,A1,A2,A3,a4,A7,a8,a9,A10,a11
	
	move	a1,a11
	sll	6,a3		; since PALRSIZ = 40h
************************************************************************
*   IF PALRSIZ IS NOT A POWER OF TWO, REPLACE THE ABOVE LINE WITH...	
*	MOVI	PALRSIZ,A3	; old way
*	MPYU	A0,A3
************************************************************************
	addi	PALRAM,A3
	move	*A3(PALCNT),A2,W	;is palette allocated?
	jrz	FADE_64_X
	move	*A3(PALID),A8,L		;Ptr to palette
	CLR	A10
	CREATE	PID_PFADE,FADEPROC
FADE_64_X:
	mmfm	SP,A0,A1,A2,A3,a4,A7,a8,a9,A10,a11
	rets

	.endif

	.end


