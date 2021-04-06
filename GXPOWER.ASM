	.MLIB	"GXMACS.LIB"
	.FILE	"GXPOWER.ASM"
	.TITLE	" <<< GENERATION X ---- POWER-UP ROUTINES >>>"
	.WIDTH	132
	.OPTION	B,D,L
	.MNOLIST

**************************************************************************
*								         *
* 	COPYRIGHT (C) 1992 MIDWAY MANUFACTURING COMPANY.		 *
* 		       ALL RIGHTS RESERVED.				 *
*								         *
**************************************************************************

	.INCLUDE	"GX.INC"
	.INCLUDE	"GXPOWER.TBL"
	.INCLUDE	"GXSTRING.H"
	.INCLUDE	"GXUNZIP.INC"
	.INCLUDE	"IMGTBL.GLO"

*DO YOU HAVE ANY REFERENCES
	
	.DEF	POWERUP_DISPATCH, DO_HEADS_UP, CLR_HEADS_UP, INIT_SBOMB_PAGE
	.DEF	CLR_PLAYER_TEXT, ATTACH_PROCK, ATTACH_CD, PROC_DELAYED_SBOMB
	.DEF	PROCK_AWARD , POWERUP_GUNVECT, REVEAL_LIFE
	.DEF	REVEAL_CD2, REVEAL_SBOMB2, REVEAL_LIFE2
	.DEF	A_UNIVOBJ_TO_POWERUP,A_OBJ_TO_POWERUP, REVEAL_SHIELD
	.DEF	REVEAL_SUPERGUN, REVEAL_LAZER, THROW_SHIELD
	.DEF	ALTWEAP_TAB_3P, ALTWEAP_TAB_2P, ATTACH_SHIELD
	.DEF	REVEAL_CD_BUS,SEND_FLOAT_POWER
	.DEF	THROW_BOOBY_PRIZE, REVEAL_SUPERGUN2, REVEAL_SHIELD2
	.DEF	REVEAL_LAZER2

*SYMBOLS IN GXAFUNC.ASM
	.REF	SetAnim
*SYMBOLS IN GXRAM.ASM
	.REF	POWERUP_DURATION, ENEMY_QUOTA, SKYCOLOR, HOLD_ENEMY_DISPATCH
	.REF	SHIELD_AWARDS, ENERGY_AWARDS, SUPERGUN_AWARDS, LAZER_AWARDS
*SYMBOLS IN GXPLAYER.ASM
	.REF	POID_TO_PDATA, P_LED_ON
***** From GXUNZIP.ASM
	.REF	STILL
***** From GXJUNGLE.ASM
	.REF	JEWEL_AWARD
***** From GXPALL.ASM
	.REF	PALSET
* SYMBOLS FROM GXUNISEQ.ASM
	.REF	SND_MORPH
***** from GXWARREN.ASM
	.REF	C_OCONST
***** from GXSCORE.ASM
	.REF	PLAYER_SHIELD


POWERUP_FLASH_COLOR	.EQU	0101H

M_PROCK	.EQU	1	;Flag for PPOWERHEADS for 3 CDs
M_CD	.EQU	2	;Flag for PPOWERHEADS for 10 CDs

**************************************************************************
*								         *
* A_UNIVOBJ_TO_POWERUP - CHANGE AN UNIVERSE OBJECT TO A POWERUP		 *
*								         *
* PASS:									 *
* A8 	  = OBJECT TO CHANGE						 *
* AARG+,W = OID OF POWERUP						 *
* RETURN:								 *
* NUTIN'								 *
*								         *
**************************************************************************

A_UNIVOBJ_TO_POWERUP

	MOVE	*A8(OULINK),A0,L
	CLR	A14
	MOVE	A14,*A8(OULINK),L
	CALLA	REMOVE_AND_FREE_LINK

A_OBJ_TO_POWERUP:
	CALLA	PULL_ANIM
	CALLA	PULL_SUPP

	CALLA	GETAFARG_WORD
	MOVE	A0,*A8(OID),W

	CALLA	INSERT_SUPP

	ANDNIM	M_NOSCALE,*A8(OFLAGS),W

	CREATE	PID_IND, UNIVOBJ_TO_POWERUP_PROC
	MOVE	A0,*A8(OPLINK),L

	RETS

UNIVOBJ_TO_POWERUP_PROC
	MOVI	POWER_COLL,A14
	MOVE	A14,*A8(OCVECT),L

	JRUC	OP_G

**************************************************************************
*								         *
* WINGS_AWARD - AWARD AEROSMITH WINGS TO THE PLAYER.			 *
* A2 = PTR TO PLAYER							 *
*								         *
**************************************************************************
WINGS_AWARD
	MMTM	SP,A0,A1

	MOVE	*A2(PWINGS),A14,W		;GET WINGS COUNT
	INC	A14				;ADD MORE WINGS				
	MOVE	A14,*A2(PWINGS),W

	SOUND1	SND_MORPH

	MOVI	WINGS_TAB_3P,A0
	MOVI	WINGS_TAB_2P,A1
	CALLR	DO_HEADS_UP

	MMFM	SP,A0,A1
	RETS

NPOWERUPS	.EQU	16			;MAX IS 16 UNTIL > PROCSIZE
POWERUPCNT	.EQU	PDATA
POWERUPSUB	.EQU	PDATA+10H		;SUBWAVE WE WERE CREATED UPON
POWERUPUSED	.EQU	PDATA+20H
POWERUPDATA	.EQU	POWERUPUSED + (NPOWERUPS*8)

;	MOVK	NUM_BOMB,A1

**************************************************************************
*								         *
* POWERUP_DISPATCH - PROCESS TO RANDOMLY SELECT FROM THE AVAILABLE	 *
* 			POWERUPS THIS WAVE AND OUTPUT THEM.		 *
* A8 = SLEEP TIME BETWEEN POWERUPS					 *
* A9 = [RANDOM TO ADD, BASE NUMBER OF EACH POWERUP]			 *
* A10 = POWER-UP FLAGS (16 MAX)						 *
*	POWERUP FLAGS:			    				 *
*								         *
**************************************************************************
POWERUP_DISPATCH
	MOVE	*A13(PROCID),A0,W
	CALLA	EXISTP_ALL
	JRNZ	PD_DIE

	CALLA	CLRPDATA
	MOVE	@SUBWAVE,A14,W
	MOVE	A14,*A13(POWERUPSUB),W	;SUBWAVE FOR DELETE

	MOVY	A9,A0
	SRL	16,A0
	JRZ	PD_NORAND
	ZEXT	A9
	INC	A0
	CALLA	RANDU			;GET RANDOM TO ADD
	DEC	A0
	ADD	A0,A9			;AND ADD IT
	JRZ	PD_HOLD_LP		;BR = NONE ALLOWED
PD_NORAND
	MOVI	POWERUP_TAB,A1
	MOVE	A13,A2
	ADDI	POWERUPDATA,A2
	MOVI	NPOWERUPS,A3
	CLR	A4

PD_INIT_LP
	SRL	1,A10	
	JRC	PD_CHOICE
	ADDK	32,A1			;SKIP THIS ROUTINE
	JRUC	PD_INIT_NXT
PD_CHOICE
	MOVE	*A1+,*A2+,L		;GET THE ROUTINE
	INC	A4
PD_INIT_NXT
	DSJ	A3,PD_INIT_LP

	MOVE	A4,*A13(POWERUPCNT),W

LD_IMM
	MOVE	*A13(PROCID),A0,W
	CALLA	EXISTP_ALL		;IS THERE A POWERUP OUT THERE?
	JRNZ	LD_RAND_NXT	        ;BR = YES, WAIT FOR IT TO CRUISE

LD_LOOP
	SLEEPR	A8			;MIN TIME BETWEEN OBJECTS
	MOVE	*A13(POWERUPSUB),A0,W
	MOVE	@SUBWAVE,A14,W
	CMP	A0,A14				;SAME SUBWAVE?
	JRNE	PD_DIE				;BR = NO, DELETE ME BOY

	MOVE	@ENEMY_QUOTA,A14,W	;IS THE WAVE SUPPOSED TO BE OVER?
	JRNZ	LD_LOOP			;BR = YES

	MOVE	*A13(POWERUPCNT),A0,W
	CALLA	RANDU			;SELECT AN AVAILABLE POWERUP
	DEC	A0
	MOVE	A0,A6
	SLL	3,A6
	ADD	A13,A6
	ADDI	POWERUPUSED,A6
	MOVB	*A6,A2
	CMP	A9,A2			;HAVE WE USED ALL OF THIS TYPE?
	JRLO	LD_OK			;BR = NO
LD_RAND_NXT
	SLOOP	5,LD_IMM

LD_OK
	MOVE	A0,A14
	SLL	5,A14
	ADDI	POWERUPDATA,A14
	ADD	A13,A14

	MOVE	*A14+,A7,L

	INC	A2
	MOVB	A2,*A6			;SHOW THE NEW COUNT

	MOVE	*A13(PROCID),A1,W
	CALLA	GETPRC

	SLEEP	4

	MOVE	*A13(POWERUPCNT),A4,W
	MOVE	A13,A1
	ADDI	POWERUPUSED,A1
LD_CK_LP
	MOVB	*A1,A0			;SEE IF WE'VE EXHAUSTED ALL POWERUPS	
	CMP	A9,A0
	JRLO	LD_IMM
	ADDK	8,A1
	DSJS	A4,LD_CK_LP

PD_HOLD_LP
	MOVE	*A13(POWERUPSUB),A0,W
	MOVE	@SUBWAVE,A14,W
	CMP	A0,A14		       	;SAME SUBWAVE?
	JRNE	PD_DIE		        ;BR = NO, RID O' PROCESS.
	SLOOP	20,PD_HOLD_LP		;JUST HANG TO STALL MORE POWERUPS
PD_DIE
	DIE

*
*TABLE OF POWERUP PROCESSES TO START
*
POWERUP_TAB

**************************************************************************
*								         *
* THROW_BOOBY_PRIZE - THROW MAMMERY BOOBY PRIZE AWARD POWERUP IN THE AIR *
*								         *
* A8  = IMG THIS IS COMING FROM						 *
* A9  = [Z,Y,X] OFFSET ( Z WORLD << 16 + Y SCREEN << 8 + X SCREEN)	 *
* A10 = [MAX, MIN] Z VELOCITY (MAX Z VEL << 16 + MIN Z VEL)	 	 *
* A11 = [Y,X] VELOCITY STUFF ( [Y MINIMUM VELOCITY >> 12] << 16 +	 *
* 			     X VELOCITY RANGE >> 12 (FOR UNFLIPPED) )    *
*								         *
**************************************************************************

THROW_BOOBY_PRIZE
	MOVI	BOOBY_PRIZE_INIT,B0
	JRUC	THROW_POWERUP_FLIP

**************************************************************************
*								         *
* THROW_PROCK - THROW ROCKET POWERUP INTO THE AIR			 *
*								         *
* A8  = IMG THIS IS COMING FROM						 *
* A9  = [Z,Y,X] OFFSET ( Z WORLD << 16 + Y SCREEN << 8 + X SCREEN)	 *
* A10 = [MAX, MIN] Z VELOCITY (MAX Z VEL << 16 + MIN Z VEL)	 	 *
* A11 = [Y,X] VELOCITY STUFF ( [Y MINIMUM VELOCITY >> 12] << 16 +	 *
* 			     X VELOCITY RANGE >> 12 (ABSOLUTE VALUE) )   *
*								         *
**************************************************************************

THROW_PROCK
	MOVI	PROCK_INIT,B0
	JRUC	THROW_POWERUP

**************************************************************************
*								         *
* THROW_CD - THROW CD POWERUP INTO THE AIR				 *
*								         *
* A8  = IMG THIS IS COMING FROM						 *
* A9  = [Z,Y,X] OFFSET ( Z WORLD << 16 + Y SCREEN << 8 + X SCREEN)	 *
* A10 = [MAX, MIN] Z VELOCITY (MAX Z VEL << 16 + MIN Z VEL)	 	 *
* A11 = [Y,X] VELOCITY STUFF ( [Y MINIMUM VELOCITY >> 12] << 16 +	 *
* 			     X VELOCITY RANGE >> 12 (ABSOLUTE VALUE) )   *
*								         *
**************************************************************************

THROW_CD
	MOVI	CD_INIT,B0
	JRUC	THROW_POWERUP

**************************************************************************
*								         *
* 	THROW_SHIELD							 *
* 									 *
* 	Throw shield powerup into the air.				 *
* 									 *
* 	A8 = Originating object						 *
* 	A9 = [Z,Y,X] Offset (Z world << 16 + Y screen << 9 + X screen)	 *
* 	A10 = [MAX,MIN] Z velocity					 *
* 	A11 = [Y,X] Velocity stuff					 *
*								         *
**************************************************************************
THROW_SHIELD
	MOVI	SHIELD_INIT,B0
	JRUC	THROW_POWERUP

**************************************************************************
*								         *
* THROW_POWERUP_FLIP - THROW POWERUP INTO THE AIR AND X DIR DEPENDS ON FLIP *
*								         *
* B0  = PTR TO CREATION TABLE						 *
* A8  = IMG THIS IS COMING FROM						 *
* A9  = [Z,Y,X] OFFSET ( Z WORLD << 16 + Y SCREEN << 8 + X SCREEN)	 *
* A10 = [MAX, MIN] Z VELOCITY (MAX Z VEL << 16 + MIN Z VEL)	 	 *
* A11 = [Y,X] VELOCITY STUFF ( [Y MINIMUM VELOCITY >> 12] << 16 +	 *
* 			     X VELOCITY RANGE >> 12 (FOR UNFLIPPED) )	 *
*								         *
**************************************************************************

THROW_POWERUP_FLIP
	PUSH	A8
	CALLA	MULTIMAKE
	PULL	A3		;PULL MUST PRESERVE STATUS, DON'T USE PULLQ
	JRZ	OP_DIE

	MOVE	A11,A0
	SRA	16,A0				;MAXIMUM Y VELOCITY
	SLL	12,A0
;	MOVI	-09000H,A1
;	CALLA	RANGERND
	MOVE	A0,*A8(OYVEL),L

	SEXT	A11,W
	SLL	12,A11
	MOVE	A11,A0				;MAXIMUM X VELOCITY
	MOVE	*A3(OCTRL),A14,W
	BTST	B_FLIPH,A14
	JRZ	TPF_GET_X			;BR=UNFLIPPED
	NEG	A0
TPF_GET_X
	MOVE	A0,A1
	SRA	1,A1	
	CALLA	RANGERND
	MOVE	A0,*A8(OXVEL),L

	JRUC	TP_GO

**************************************************************************
*								         *
* THROW_POWERUP	- THROW POWERUP INTO THE AIR				 *
*								         *
* B0  = PTR TO CREATION TABLE						 *
* A8  = IMG THIS IS COMING FROM						 *
* A9  = [Z,Y,X] OFFSET ( Z WORLD << 16 + Y SCREEN << 8 + X SCREEN)	 *
* A10 = [MAX, MIN] Z VELOCITY (MAX Z VEL << 16 + MIN Z VEL)	 	 *
* A11 = [Y,X] VELOCITY STUFF ( [Y MINIMUM VELOCITY >> 12] << 16 +	 *
* 			     X VELOCITY RANGE >> 12 (ABSOLUTE VALUE) )   *
*								         *
**************************************************************************

THROW_POWERUP
	PUSH	A8
	CALLA	MULTIMAKE
	PULL	A3		;PULL MUST PRESERVE STATUS, DON'T USE PULLQ
	JRZ	OP_DIE

	MOVE	A11,A0
	SRA	16,A0				;MAXIMUM Y VELOCITY
	SLL	12,A0
	MOVI	-09000H,A1
	CALLA	RANGERND
	MOVE	A0,*A8(OYVEL),L

	SEXT	A11,W
	SLL	12,A11
	MOVE	A11,A0				;MAXIMUM X VELOCITY
	MOVE	A0,A1				;MINIMUM X VELOCITY
	NEG	A1
	CALLA	RANGERND
	MOVE	A0,*A8(OXVEL),L
TP_GO
	MOVIM	POWERUP_FLASH_COLOR,*A8(OCONST),W

	MOVE	*A3(OXVAL),A1,L
	MOVE	A9,A14
	SLL	24,A14
	SRA	24-15,A14
	ADD	A14,A1				;X OFFSET

	MOVE	*A3(OYVAL),A2,L
	MOVE	A9,A14
	SEXT	A14,W
	SRA	8,A14
	SLL	15,A14
	ADD	A14,A2				;Y OFFSET

	MOVE	*A3(OZVAL),A3,L
	SRA	16,A9
	ADD	A9,A3				;Z OFFSET

	CALLA	SET_ANIPU

	MOVE	A10,A0
	SRA	16,A0				;MAXIMUM Z VELOCITY
	MOVE	A10,A1
	SEXT	A1,W				;MINIMUM Z VELOCITY
	CALLA	RANGERND
	MOVE	A0,*A8(OZVEL),L

	MOVI	03000H,A14
	MOVE	A14,*A8(OYACCEL),W

	ORIM	M_GCOLL,*A8(OFLAGS),W

	MOVE	A13,*A8(OPLINK),L
	CALLA	INSERT_OBJ
	CLR	A11				;NONE SHALL KNOW
;TP_WAIT
;	SLEEP	2
;	MOVE	*A8(OYACCEL),A14,W
;	JRNZ	TP_WAIT				;BR=NOT ON GROUND YET
	JRUC	OP_G

	.DEF	THROW_CD_WARREN

SND_TO_PLYR	.word	0f390h,100,081c8h,0		

THROW_CD_WARREN:
	MOVI	PROCK_INIT,B0

**************************************************************************
*								         *
* THROW_POWERUP_WARREN	- THROW POWERUP TOWARD PLAYER			 *
*								         *
* B0  = PTR TO CREATION TABLE						 *
* A9  = [Y,X] Screen position to reach at ZMIN_REAL			 *
* A10 = Starting Univ Z						 	 *
* A11 = Starting Univ [Y,X] shifted left by 4				 *
*								         *
**************************************************************************
THROW_POWERUP_WARREN
	CALLA	MULTIMAKE
	JRZ	OP_DIE

	MOVIM	POWERUP_FLASH_COLOR,*A8(OCONST),W

	move	a11,a1
	move	a11,a2
	sra	16,a2
	sll	12,a2		; restore Y
	sll	16,a1		; restore X
	sra	4,a1
	move	a10,a3		; set Z

	CALLA	SET_ANIPU

	move	@ZBASE,a14,L
	sub	a14,a3
	subi	ZMAX_REAL+200h,a3
	sra	5,a3
	neg	a3
	move	a3,*a8(OZVEL),L

	movi	ZMAX_REAL+200h,a3
	clr	a5
	movx	a9,a5		; Target Screen X in a5
	sra	16,a9		; Target Screen Y in a9

	setf	16,1,1
	SUBI	HALFX,a5
	MPYS	a3,a5		; Target WORLD X in a5

	MOVE	@YHALF,A14,W
	SUB	A14,a9
	MPYS	a3,a9		; Target WORLD Y in a9
	setf	32,0,1

	move	@XBASE,a14,L
	sub	a14,a1		; Starting WORLD X in a1
	sub	a1,a5
	sra	5,a5
	move	a5,*a8(OXVEL),L

	move	@YBASE,a14,L
	add	a14,a2		; Starting WORLD Y in a2
	sub	a2,a9
	sra	5,a9
	subi	10000h,a9
	move	a9,*a8(OYVEL),L

	MOVI	2200H,A14
	MOVE	A14,*A8(OYACCEL),W

	ORIM	M_GCOLL,*A8(OFLAGS),W

	MOVE	A13,*A8(OPLINK),L
	CALLA	INSERT_OBJ
	CLR	A11				;NONE SHALL KNOW

	SOUND1	SND_TO_PLYR

	SLEEP	5
	JRUC	OP_G


**************************************************************************
*								         *
* FALL_SBOMB - PROCESS TO MAKE A SBOMB START AT A SCREEN RELATIVE	 *
* 		 POINT AND FALL TO THE GROUND.  ALL THE TIME WAITING	 *
* 		 TO BE DETONATED BY A WILLING PLAYER.			 *
* A8 = OBJECT FALLING FROM						 *
* A10 = [Y,X] SCREEN RELATIVE POINT TO START				 *
*								         *
**************************************************************************
FALL_SBOMB
	MOVI	SBOMB_INIT,B0
	CLR	A11
	JRUC	FALLOUT_POWERUP

*
*FALLOUT_POWERUP - PROCESS TO MAKE A POWERUP FALLOUT OF THE SKY.
*B0 = PTR TO CREATION TABLE
*A8 = IMG THIS IS COMING FROM
*A10 = [Y,X] SCREEN RELATIVE CREATION POINT
*A11 = INITIAL YVEL
*
FALLOUT_POWERUP
	PUSH	A8
	CALLA	MULTIMAKE
	MOVE	A8,A0
	PULL	A8		;PULL MUST PRESERVE STATUS, DON'T USE PULLQ
	JRZ	OP_DIE

	MOVIM	POWERUP_FLASH_COLOR,*A0(OCONST),W

;	MOVB	*A8(OPLANE),A1
 	MOVE	A0,A8
	CALLA	STORE_OPLANE
	MOVE	A13,*A8(OPLINK),L
	MOVIB	18H,*A8(OGRNDOFF)
	ORIM	M_GCOLL,*A8(OFLAGS),W
	MOVE	A11,*A8(OYVEL),L
	MOVIM	7800H,*A8(OYACCEL),W
	MOVI	ZMAX,A1
	CALLA	STORE_ZVAL
	MOVE	A10,A1
	CALLA	SET_SCRN_POS
	CALLA	OBJ_TO_PNT
	CALLA	INSERT_OBJ
	SLEEP	10				;GIVE IT TIME OUT
	JRUC	OP_G

*
*FALLOUT2_POWERUP - PROCESS TO MAKE A POWERUP POP OUT TOWARDS THE PLAYERS.
*B0 = PTR TO CREATION TABLE
*A6 = OFFSET FROM GROUND
*A7 = ANIMATION SCRIPT
*A8 = IMG THIS IS COMING FROM
*A10 = [Y,X] OFFSET
*A11 = INITIAL YVEL
*
FALLOUT2_POWERUP
	PUSH	A8
	CALLA	MULTIMAKE
	MOVE	A8,A0
	PULL	A8		;PULL MUST PRESERVE STATUS, DON'T USE PULLQ
	JRZ	OP_DIE

	MOVIM	POWERUP_FLASH_COLOR,*A0(OCONST),W

	MOVE	A10,A4
	CALLA	ADD_OFF2ANIP
	MOVE	*A8(OZVAL),A1,L
	move	@ZBASE,a14,L
	add	a14,a1
 	MOVE	A0,A8
	CALLA	STORE_ZVAL
	MOVE	A13,*A8(OPLINK),L
	ORIM	M_GCOLL,*A8(OFLAGS),W
	MOVB	A6,*A8(OGRNDOFF)
;	MOVE	*A8(OFLAGS),A14,W
;	XORI	M_NOAUTOZ,A14
;	MOVE	A14,*A8(OFLAGS),W
;	PUSH	A8
;	MOVE	*A8(OPARTS),A8,L
;	MOVE	*A8(OFLAGS),A14,W
;	XORI	M_NOAUTOZ,A14
;	MOVE	A14,*A8(OFLAGS),W
;	PULL	A8

	CLR	A0	
	MOVK	3,A1
	CALLA	RANGERND
	SLL	16,A0
	MOVE	A0,*A8(OXVEL),L

	MOVE	A11,*A8(OYVEL),L

	MOVIM	7800H,*A8(OYACCEL),W

	CALLA	OBJ_TO_PNT
	CALLA	INSERT_OBJ

	MOVE	A7,A1

	CALLA	STRT_ANIM
	SLEEP	10				;GIVE IT TIME OUT
	JRUC	OP_G


*
*FALLOUT3_POWERUP - PROCESS TO MAKE A POWERUP FALL THROUGH THE SCREEN.
*B0 = PTR TO CREATION TABLE
*A8 = IMG THIS IS COMING FROM
*A10 = [Y,X] SCREEN RELATIVE CREATION POINT
*A11 = INITIAL YVEL
*
FALLOUT3_POWERUP
	CALLA	MULTIMAKE
	JRZ	OP_DIE

	MOVIM	POWERUP_FLASH_COLOR,*A8(OCONST),W

	MOVI	ZMAX,A1
	CALLA	STORE_ZVAL
	MOVE	A13,*A8(OPLINK),L
	MOVE	A11,*A8(OYVEL),L
	MOVIM	1000H,*A8(OYACCEL),W
	MOVE	A10,A1
	CALLA	SET_SCRN_POS
	CALLA	OBJ_TO_PNT
	CALLA	INSERT_OBJ
	CLR	A11				;NONE SHALL KNOW
	SLEEP	10				;GIVE IT TIME OUT
	JRUC	OP_G


**************************************************************************
*								         *
* ATTACH_SBOMB - PROCESS TO ATTACH A SMART BOMB TO A			 *
* 		GIVEN OBJECT						 *
* A10 = [Y,X] SCREEN OFFSET						 *
* A11 = OFFSET FOR OZVAL						 *
*								         *
**************************************************************************
ATTACH_SBOMB
	MOVI	SBOMB_INIT,B0
	JRUC	ATTACH_POWERUP

**************************************************************************
*								         *
* ATTACH_CD - PROCESS TO ATTACH A CD TO A				 *
* 		GIVEN OBJECT						 *
* A10 = [Y,X] SCREEN OFFSET						 *
* A11 = OFFSET FOR OZVAL						 *
*								         *
**************************************************************************
ATTACH_CD
	MOVI	CD_INIT,B0
	JRUC	ATTACH_POWERUP

**************************************************************************
*								         *
* ATTACH_PROCK - PROCESS TO ATTACH A ROCKET BOMB TO A			 *
* 		GIVEN OBJECT						 *
* A10 = [Y,X] SCREEN OFFSET						 *
* A11 = OFFSET FOR OZVAL						 *
*								         *
**************************************************************************
ATTACH_PROCK
	MOVI	PROCK_INIT,B0
	JRUC	ATTACH_POWERUP

**************************************************************************
*								         *
* 	ATTACH_SHIELD							 *
* 									 *
* 	Process to attache a shield to a given object.			 *
* 									 *
* 	A10 = [Y,X] Screen offset					 *
* 	A11 = Offset for OZVAL						 *
*								         *
**************************************************************************
ATTACH_SHIELD
	MOVI	SHIELD_INIT,B0
	JRUC	ATTACH_POWERUP

*
*ATTACH_POWERUP - PROCESS TO MAKE A POWERUP BECOME PART OF AN OBJECT ON
*                       SCREEN
*B0 = PTR TO CREATION TABLE
*A8 = IMG THIS IS TO BE ATTACHED TO
*A10 = [Y,X] SCREEN OFFSET FROM OBJECT ANIMATION POINT
*A11 = AMOUNT TO ADD TO OZVAL OF OBJECT FOR POWERUP
*
ATTACH_POWERUP
	PUSH	A8
	CALLA	MULTIMAKE
	PULL	A0		;PULL MUST PRESERVE STATUS, DON'T USE PULLQ
	JRZ	OP_DIE

	MOVIM	POWERUP_FLASH_COLOR,*A8(OCONST),W

	MOVIM	01994h,*a8(ODATA),W	; code to say this is head of a powerup

	MOVE	*A0(OXVAL),A1,L		;GET X POSITION
	MOVE	A10,A14
	SEXT	A14,W
	SLL	15,A14			;TRANSLATE OFFSET TO WORLD
	ADD	A14,A1			;NEW X POSITION

	MOVE	*A0(OYVAL),A2,L		;GET Y POSITION
	SRA	16,A10
	SLL	15,A10			;TRANSLATE OFFSET TO WORLD
	ADD	A10,A2			;NEW Y POSITION

	MOVE	A8,A3
AP_PART_LUPE
	MOVE	A1,*A3(OXVAL),L
	MOVE	A2,*A3(OYVAL),L
	MOVE	*A3(OPARTS),A3,L
	JRNZ	AP_PART_LUPE

	MOVE	*A0(OZVAL),A1,L
	sub	A11,A1			;ADD Z OFFSET
	CALLA	STORE_ZVAL

	MOVE	A13,*A8(OPLINK),L
	CALLA	INSERT_OBJ
	SWAP	a8,a0			; new into a0, old into a8
	calla	INSPART
	move	a0,a8			; new back into a8

	MOVI	AP_POWERUP_GUNVECT,A14	; gunvector goes to head part only!!
	MOVE	A14,*A8(OGUNVECT),L

	CLR	A11				;HOLD FLIGHT TIME HERE
	MOVE	@POWERUP_DURATION,A10,W		;GET THE NORMAL TIME 
	CLR	A9
AP_POWERUP_TIMEOUT
	CMPI	160,A10				;ARE WE IN FLASH RANGE?
	JRLS	APT_FLASH			;BR = YES
	SUBK	5,A10
	JRLE	APT_DONE
	SLOOP	5,AP_POWERUP_TIMEOUT

APT_FLASH
	MOVE	*A8(OFLAGS),A14,W
	BTST	B_ANIM,A14
	JRNZ	APT_SLEEP			;BR = Animating, do not flash

	MOVE	A9,A9
	JRZ	APT_OFF
	CLR	A9
	CALLA	OBJ_CONST
	JRUC	APT_SLEEP
APT_OFF
	MOVK	1,A9
	CALLA	OBJ_WNZ

APT_SLEEP
;	MOVE	A10,A14
;	SRL	3,A14
;	CMPK	4,A14	
;	JRHI	APT_OK
;	MOVI	4,A14
;APT_OK
;	SUB	A14,A10
;	SLOOPR	A14,AP_POWERUP_TIMEOUT
	SUBK	4,A10
	SLOOP	4,AP_POWERUP_TIMEOUT

APT_DONE
	CALLA	OBJ_WNZ

	SLEEP	20
	movi	01994h,a3
	move	*a8(OPART1),a5,L	; get head (obj attached to)
	move	a8,a0
AP_DEL_LP:
	move	*a0(OPARTS),a8,L
	calla	PULLPART
	CALLA	DELOBJ
	move	a8,a0
	jrz	awdone
	move	*a0(ODATA),a14		; stop deleting parts if
	cmp	a3,a14			; we hit the head of another powerup
	jrne	AP_DEL_LP
awdone:
	move	*a5(OPARTS),a14,L	; any more parts to head?
	jrnz	moparts
	move	a14,*a5(OPART1),L	; not a multi no more
moparts:
	DIE


*
*	This routine unlinks the hit powerup from the item
*	it is attached to.
*	a8 = powerup head (or obj if not multi)
*
AP_POWERUP_GUNVECT:
	move	*a8(OPART1),a14,L	; head (box)
	move	a14,a7			; save a while
find_prev_part:
	move	a14,a1
	move	*a1(OPARTS),a14,L	; find the part before a8
	cmp	a8,a14
	jrne	find_prev_part
*
*	a1 contains part before powerup head
*	Find link after this powerup
*
	movi	01994h,a5
	move	a14,a3
find_last_part:
	move	a3,a14
	move	*a14(OPARTS),a3,L	; look for 0 (end of multi)
	jrz	found_end
	move	*a3(ODATA),a6		; look for code (start of a powerup)
	cmp	a5,a6
	jrne	find_last_part
	clr	a6
	move	a6,*a14(OPARTS),L	; terminate powerup
found_end:
*
*	a3 contains link after end of powerup
*
	move	a3,*a1(OPARTS),L	; attach prev link to post link

	move	*a7(OPARTS),a14,L	; is only one part left to head?
	jrnz	still_multi
	clr	a14
	move	a14,*a7(OPART1),L	; head is not a multi no more
still_multi:
	movi	POWERUP_GUNVECT,a14	; new GUNVECT
	move	a14,*a8(OGUNVECT),L	; stuff in head
	move	*a8(OPARTS),a1,L
	jrz	no_power_multi
	move	a8,*a8(OPART1),L	; new head in OPART1
new_head_lp:
	move	a8,*a1(OPART1),L	; stuff new head of powerup multi
	move	a14,*a1(OGUNVECT),L	; all parts have new gunvect
	move	*a1(OPARTS),a1,L	; more to stuff?
	jrnz	new_head_lp
	jruc	POWERUP_GUNVECT
no_power_multi:
	clr	a14			; if powerup is not a multi
	move	a14,*a8(OPART1),L	; clear out OPART1
	jruc	POWERUP_GUNVECT

**************************************************************************
*								         *
* REVEAL_SBOMB - PROCESS TO PLACE A SMART BOMB IN RELATION TO A		 *
* 		GIVEN OBJECT						 *
* A10 = [Y,X] SCREEN OFFSET						 *
* A11 = OFFSET FOR OZVAL						 *
*								         *
**************************************************************************
REVEAL_SBOMB
	MOVI	SBOMB_INIT,B0
	JRUC	REVEAL_POWERUP

**************************************************************************
*								         *
* REVEAL_SBOMB2 - PROCESS TO PLACE A 2X SCALE SMART BOMB IN RELATION TO A		 *
* 		GIVEN OBJECT						 *
* A10 = [Y,X] SCREEN OFFSET						 *
* A11 = OFFSET FOR OZVAL						 *
*								         *
**************************************************************************
REVEAL_SBOMB2
	MOVI	SBOMB2_INIT,B0
	JRUC	REVEAL_POWERUP

*
*	a8 = num to send (moved to a11)
*	a9 = min ticks between
*	a10 = max ticks between
*
SEND_FLOAT_POWER:
	move	a8,a11
	sub	a9,a10
SFP_lp:
	SLEEPR	a9

	movi	FLOAT_CD,a6
	calla	RANDOM
	btst	13,a0
	jrz	randpick
	movi	FLOAT_PROCK,a6
randpick:
	call	a6

	move	a10,a0
	calla	RANDU
	calla	PRCSLP
	dsjs	a11,SFP_lp

	DIE


FLOAT_PROCK_INIT
	.byte	1, 0, 0, 1	;OBJCNT, PRCCNT, IMGPALCNT, PALCNT
	.long	P_CD		;PAL LIST
	.word	OID_PROCK, 0
	LWWWW   XCDSM1, DMAWNZ, M_NOPIXSCAN|M_SCRNOBJ|M_NOSCALE, 0, OM_ANIM
	.LONG	FLT_CDSM_ANIM

FLOAT_CD_INIT
	.byte	1, 0, 0, 1	;OBJCNT, PRCCNT, IMGPALCNT, PALCNT
	.long	P_CD		;PAL LIST
	.word	OID_CD, 0
	LWWWW   XCD1, DMAWNZ, M_NOPIXSCAN|M_SCRNOBJ|M_NOSCALE, 0, OM_ANIM
	.LONG	FLT_CD_ANIM

FLT_CD_ANIM
	LW	XCD1,2
	LW	XCD2,2
	LW	XCD3,2
	LW	XCD4,2
	LW	XCD5,2
	LW	XCD6,2
	LW	XCD7,2
	LWL	XCD8,2|AFunc,A_DELETE_BOT
	.long	0

FLT_CDSM_ANIM
	LW	XCDSM1,2
	LW	XCDSM2,2
	LW	XCDSM3,2
	LW	XCDSM4,2
	LW	XCDSM5,2
	LW	XCDSM6,2
	LW	XCDSM7,2
	LWL	XCDSM8,2|AFunc,A_DELETE_BOT
	.long	0


A_DELETE_BOT
	MOVE	*A8(ODAGY),A1,W
	MOVE	@(SCRNBR+16),A14,W
	CMP	A14,A1
	JAGT	DELETE_OBJ_PROC			;BR=OFF DA BOTTOM
	RETS


FLOAT_CD
	movi	FLOAT_CD_INIT,b0
	jruc	FLOAT_POWERUP

FLOAT_PROCK
	movi	FLOAT_PROCK_INIT,b0
	jruc	FLOAT_POWERUP

FLOAT_POWERUP
	calla	MULTIMAKE
	jrz	FLT_X
	movi	380,a0
	calla	RANDU	; screen X in a0
	addk	10,a0
	move	a0,*a8(OXPOS)
	zext	a0
	move	a0,*a8(ODAG),L
	sra	16,a0
	move	a0,*a8(OYPOS)
	movi	6800h,a14
	move	a14,*a8(OZVAL),L
	calla	INSERT_OBJ
	movi	0e00h,a1
	movi	2000h,a0
	calla	RANGRAND
	move	a0,*a8(OYACCEL),W
	MOVIM	SCRNPOWER_GUNV,*a8(OGUNVECT),L
	CREATE	PID_IND,OP_G_FLT
	move	a0,*a8(OPLINK),L
FLT_X:
	rets


SCRNPOWER_GUNV:
	move	*a8(OFLAGS),a14
	andni	M_SCRNOBJ,a14
	move	a14,*a8(OFLAGS)		; no longer a screen obj
	move	*a8(OZVAL),a1,L		; world Z
	move	*a8(OXPOS),a3
	subi	HALFX,a3
	mpys	a1,a3			; world X
	move	@XBASE,a14,L
	add	a14,a3
	move	a3,*a8(OXVAL),L
	move	*a8(OYPOS),a3
	move	@YHALF,a14
	sub	a14,a3
	mpys	a1,a3			; world Y
	move	@YBASE,a14,L
	add	a14,a3
	move	a3,*a8(OYVAL),L
	move	@ZBASE,a14,L
	add	a14,a1
	move	a1,*a8(OZVAL),L
	MOVIM	POWERUP_GUNVECT,*a8(OGUNVECT),L
	jruc	POWERUP_GUNVECT



*
*	NOTE!  POWERUPS WHICH ARE PLACED IN THE SPHINX'S MOUTH
*	       ARE "NO_SCALED" INSIDE THE ROUTINE.  YOU DO NOT NEED TO MAKE
*	       A SEPARATE INIT TABLE.  YOU SHOULD MAKE SURE THAT THE POWER UP
*	       IS SMALL ENOUGH TO FIT IN THE SPHINX'S MOUTH! (NOT 
*	       GUARANTEED)
*
BUS_CD_INIT
	.byte	1, 0, 0, 1	;OBJCNT, PRCCNT, IMGPALCNT, PALCNT
	.long	P_CD		;PAL LIST
	.word	OID_CD, 0
	LWWWW   XCDSM1, DMAWNZ, M_NOPIXSCAN, 0, OM_COLL | OM_ANIM
	.LONG	POWER_COLL
	.LONG	CDSM_ANIM

**************************************************************************
*								         *
* REVEAL_CD_BUS - PROCESS TO PLACE A CD IN RELATION TO A		 *
* 	        	GIVEN OBJECT					 *
* a8 = source object		      					 *
* A9 =  UNIV X								 *
* A10 = UNIV Y								 *
* A11 = offset from object's UNIV Z	  				 *
*								         *
**************************************************************************
REVEAL_CD_BUS
	sleep	24
	MOVI	BUS_CD_INIT,B0

REVEAL_POWER_BUS
	PUSH	A8
	CALLA	MULTIMAKE
	PULL	A2		;PULL MUST PRESERVE STATUS, DON'T USE PULLQ
	JRZ	OP_DIE

	movi	P_SMCDG,a0	; gold pal for small cd
	calla	CHANGE_PAL

	CREATE	PID_IND,SPHINX_PWR_KLUDGE

	move	a8,a0		; powerup in a0
	move	a2,a8		; original obj in a8

	move	*a0(OFLAGS),a14	; set to noscale
	ori	M_NOSCALE,a14
	move	a14,*a0(OFLAGS)

	move	a9,a1		; set X and Y position
	move	a10,a2
	MOVE	A0,A3
	jruc	RP_PART_LUPE

*
*	This process waits till OP_G process has been started, then
*	sneakily changes the gunvector to do some preprocessing.
*
SPHINX_PWR_KLUDGE:
	sleep	13
	MOVIM	SPHINX_PWR_GUNV,*a8(OGUNVECT),L
	DIE

	.ref	SNOZZ_COUNT

SPHINX_PWR_GUNV:
	move	@SNOZZ_COUNT,a14
	inc	a14
	move	a14,@SNOZZ_COUNT
	MOVIM	POWERUP_GUNVECT,*a8(OGUNVECT),L
	jruc	POWERUP_GUNVECT



**************************************************************************
*								         *
* REVEAL_CD - PROCESS TO PLACE A CD IN RELATION TO A			 *
* 		GIVEN OBJECT						 *
* A10 = [Y,X] SCREEN OFFSET						 *
* A11 = OFFSET FOR OZVAL						 *
*								         *
**************************************************************************
REVEAL_CD
	MOVI	CD_INIT,B0
	JRUC	REVEAL_POWERUP

**************************************************************************
*								         *
* REVEAL_CD - PROCESS TO PLACE A 2X SCALE CD IN RELATION TO A			 *
* 		GIVEN OBJECT						 *
* A10 = [Y,X] SCREEN OFFSET						 *
* A11 = OFFSET FOR OZVAL						 *
*								         *
**************************************************************************
REVEAL_CD2
	MOVI	CD2_INIT,B0
	JRUC	REVEAL_POWERUP

**************************************************************************
*								         *
* REVEAL_PROCK - PROCESS TO PLACE A ROCKET BOMB IN RELATION TO A	 *
* 		GIVEN OBJECT						 *
* A10 = [Y,X] SCREEN OFFSET						 *
* A11 = OFFSET FOR OZVAL						 *
*								         *
**************************************************************************
REVEAL_PROCK
	MOVI	PROCK_INIT,B0
	JRUC	REVEAL_POWERUP

**************************************************************************
*								         *
* 	REVEAL_LIFE							 *
* 									 *
* 	Process to place an extra life powerup in relation to a		 *
* 	given object.							 *
* 									 *
* 	A10 = [Y,X] screen offset					 *
* 	A11 = OZVAL offset from spawning object				 *
*								         *
**************************************************************************
REVEAL_LIFE
	MOVI	LIFE_INIT,B0
	JRUC	REVEAL_POWERUP

**************************************************************************
*								         *
* 	REVEAL_LIFE							 *
* 									 *
* 	Process to place an 2X SCALE extra life powerup in relation to a		 *
* 	given object.							 *
* 									 *
* 	A10 = [Y,X] screen offset					 *
* 	A11 = OZVAL offset from spawning object				 *
*								         *
**************************************************************************
REVEAL_LIFE2
	MOVI	LIFE2_INIT,B0
	JRUC	REVEAL_POWERUP

**************************************************************************
*								         *
* 	REVEAL_CLIP							 *
* 									 *
* 	Process to place a clip powerup in relation to a		 *
* 	given object.							 *
* 									 *
* 	A10 = [Y,X] screen offset					 *
* 	A11 = OZVAL offset from spawning object				 *
*								         *
**************************************************************************
REVEAL_CLIP
	MOVI	CLIP_INIT,B0
	JRUC	REVEAL_POWERUP

**************************************************************************
*								         *
* 	REVEAL_SHIELD							 *
* 									 *
* 	Process to place a shield powerup in relation to a		 *
* 	given object							 *
* 									 *
* 	A10 = [Y,X] screen offset					 *
* 	A11 = OZVAL offset from spawning object				 *
*								         *
**************************************************************************
REVEAL_SHIELD
	MOVI	SHIELD_INIT,B0
	JRUC	REVEAL_POWERUP

**************************************************************************
*								         *
* 	REVEAL_SHIELD2							 *
* 									 *
* 	Process to place a shield powerup in relation to a		 *
* 	given object, 2 scale.						 *
* 									 *
* 	A10 = [Y,X] screen offset					 *
* 	A11 = OZVAL offset from spawning object				 *
*								         *
**************************************************************************
REVEAL_SHIELD2
	MOVI	SHIELD2_INIT,B0
	JRUC	REVEAL_POWERUP

**************************************************************************
*								         *
* 	REVEAL_SUPERGUN							 *
* 									 *
* 	Process to place a SuperGun powerup in relation to a		 *
* 	given object							 *
* 									 *
* 	A10 = [Y,X] screen offset					 *
* 	A11 = OZVAL offset from spawning object				 *
*								         *
**************************************************************************
REVEAL_SUPERGUN
	MOVI	SUPERGUN_INIT,B0
	JRUC	REVEAL_POWERUP

**************************************************************************
*								         *
* 	REVEAL_SUPERGUN2						 *
* 									 *
* 	Process to place a SuperGun powerup in relation to a		 *
* 	given object, 2 scale.						 *
* 									 *
* 	A10 = [Y,X] screen offset					 *
* 	A11 = OZVAL offset from spawning object				 *
*								         *
**************************************************************************
REVEAL_SUPERGUN2
	MOVI	SUPERGUN2_INIT,B0
	JRUC	REVEAL_POWERUP

**************************************************************************
*								         *
* 	REVEAL_LAZER							 *
* 									 *
* 	Process to place a Lazer disc powerup in relation to a		 *
* 	given object							 *
* 									 *
* 	A10 = [Y,X] screen offset					 *
* 	A11 = OZVAL offset from spawning object				 *
*								         *
**************************************************************************
REVEAL_LAZER
	MOVI	LAZER_INIT,B0
	JRUC	REVEAL_POWERUP

**************************************************************************
*								         *
* 	REVEAL_LAZER2							 *
* 									 *
* 	Process to place a Lazer disc powerup in relation to a		 *
* 	given object, 2 scale.						 *
* 									 *
* 	A10 = [Y,X] screen offset					 *
* 	A11 = OZVAL offset from spawning object				 *
*								         *
**************************************************************************
REVEAL_LAZER2
	MOVI	LAZER2_INIT,B0
	JRUC	REVEAL_POWERUP

*
*REVEAL_POWERUP - PROCESS TO MAKE A POWERUP APPEAR AT POINT ON SCREEN
*B0 = PTR TO CREATION TABLE
*A8 = IMG THIS IS COMING FROM
*A10 = [Y,X] SCREEN OFFSET FROM OBJECT ANIMATION POINT
*A11 = AMOUNT TO SUB TO OZVAL OF OBJECT FOR POWERUP
*
REVEAL_POWERUP
	PUSH	A8
	CALLA	MULTIMAKE
	MOVE	A8,A0
	PULL	A8		;PULL MUST PRESERVE STATUS, DON'T USE PULLQ
	JRZ	OP_DIE

	MOVIM	POWERUP_FLASH_COLOR,*A0(OCONST),W

	MOVE	*A8(OXVAL),A1,L		;GET X POSITION
	MOVE	A10,A14
	SEXT	A14,W
	SLL	15,A14			;TRANSLATE OFFSET TO WORLD
	move	*a8(OCTRL),a4
	btst	B_FLIPH,a4
	jrz	RP_noflph
	neg	a14			; compensate for flipped obj
RP_noflph:
	ADD	A14,A1			;NEW X POSITION

	MOVE	*A8(OYVAL),A2,L		;GET Y POSITION
	SRA	16,A10
	SLL	15,A10			;TRANSLATE OFFSET TO WORLD
	btst	B_FLIPV,a4		; compensate for flipped obj
	jrz	RP_noflpv
	neg	a10
RP_noflpv:
	ADD	A10,A2			;NEW Y POSITION

	MOVE	A0,A3
RP_PART_LUPE
	MOVE	A1,*A3(OXVAL),L
	MOVE	A2,*A3(OYVAL),L
	MOVE	*A3(OPARTS),A3,L
	JRNZ	RP_PART_LUPE

	MOVE	*A8(OZVAL),A1,L
	SUB	A11,A1			;ADD Z OFFSET
 	MOVE	A0,A8
	CALLA	STORE_ZVAL

	MOVE	A13,*A8(OPLINK),L
	CALLA	INSERT_OBJ
	SLEEP	10				;GIVE IT TIME OUT
	JRUC	OP_G

*
*OUTPUT_POWERUP - PROCESS TO FLIP A POWERUP OUT ON THE PLAYFIELD
*B0 = PTR TO CREATION TABLE
*
***********************************************************************
*NOTE: A11 MUST REMAIN 0 DURING THE ROUTINE OUTPUT_POWERUP, IT WILL   *
*	EVENTUALLY BECOME THE ELAPSED FLIGHT TIME TO THE PLAYER       *
*	SCORE AREA.						      *
***********************************************************************
OUTPUT_POWERUP
	CALLA	MULTIMAKE
	JRZ	OP_DIE

	MOVIM	POWERUP_FLASH_COLOR,*A8(OCONST),W

	MOVE	A13,*A8(OPLINK),L


	CALLA	SetOnGrnd		;OPLANE, OSIZEY -> sets OYPOS
	move	*A8(OYPOS),A14,W
	SUBI	18H,A14
	move	A14,*A8(OYPOS),W

	MOVI	10,A1
	MOVI	SCREEN_WIDTH-10,A0
	CALLA	RANGRAND
	MOVE	A0,A3
	MOVI	ZMAX,A1
	CALLA	STORE_ZVAL
;	TOWORLDX	A1,A3
	MOVE	A3,*A8(OXVAL),L


	CALLA	INSERT_OBJ

OP_G
	MOVE	A8,A11
	MOVI	POWERUP_GUNVECT,A14
OP_GV_LP
	MOVE	A14,*A8(OGUNVECT),L
	MOVE	*A8(OPARTS),A8,L		;GUN VECTOR GOES TO ALL PARTS
	JRNZ	OP_GV_LP
	MOVE	A11,A8
OP_G_FLT:
	CLR	A11				;HOLD FLIGHT TIME HERE
	MOVE	@POWERUP_DURATION,A10,W		;GET THE NORMAL TIME 
	CLR	A9
POWERUP_TIMEOUT
	CMPI	160,A10				;ARE WE IN FLASH RANGE?
	JRLS	PT_FLASH			;BR = YES
	SUBK	5,A10
	JRLE	PT_DONE
	SLOOP	5,POWERUP_TIMEOUT

PT_FLASH
	MOVE	*A8(OFLAGS),A14,W
	BTST	B_ANIM,A14
	JRNZ	PT_SLEEP			;BR = Animating, do not flash
	MOVE	A9,A9
	JRZ	PT_OFF
	CLR	A9
	CALLA	OBJ_CONST
	JRUC	PT_SLEEP
PT_OFF
	MOVK	1,A9

	CALLA	OBJ_WNZ

PT_SLEEP
;	MOVE	A10,A14
;	SRL	3,A14
;	CMPK	4,A14
;	JRHI	PT_OK
;	MOVI	4,A14
;PT_OK
;	SUB	A14,A10
;	SLOOPR	A14,POWERUP_TIMEOUT
	SUBK	4,A10
	SLOOP	4,POWERUP_TIMEOUT
PT_DONE
	CALLA	OBJ_WNZ
	SLEEP	20
	MOVE	*A8(OID),A14,W
	CMPI	OID_WINGS,A14
	JRNE	PT_DEL				;BR = Not deleting the wings
	SOUND1	SND_STUPID
PT_DEL
	CALLA	DELETE_OBJ
OP_DIE
	DIE

*
* Call the guy stupid for not picking up the wings
*
SND_STUPID
	.WORD	0F1E0H,213,0A875H,0		;Sound for missing the wings

**************************************************************************
*								         *
* POWERUP_GUNVECT - SERVICE ROUTINE FOR GUN COLLISION.			 *
* A2 = PTR TO PLAYER SHOOTING THIS POWERUP				 *
* A8 = PTR TO POWERUP OBJECT						 *
*								         *
**************************************************************************
POWERUP_GUNVECT
	MMTM	SP,A0,A1,A7,A8,A10,A11
	CALLA	GET_HEAD_PART

	MOVE	*A8(OID),A0,W
	CMPI	OID_SBOMB,A0			;SMART BOMBS DON'T FLY!
	JRNE	PGV_FLYBOY			;IF THEY HAD WINGS THEY WOULD
*BLOW THE SMART BOMB
	CALLA	OBJPROC_KILL
	CALLA	DELETE_OBJ
	CALLR	SBOMB_AWARD
	JRUC	PGV_X

PGV_FLYBOY
	CALLA	OBJ_WNZ

	MOVE	*A8(OPLINK),A0,L	
	JRZ	PGV_X

	CALLA	GETA11				;GET REMAINING FLIGHT TIME
	JRZ	PGV_LOAD_NEW			;BR = NOT IN FLIGHT YET

	CALLA	GETA10				
	CMP	A2,A10				;FLYING TO WHICH PLAYER?
	JREQ	PGV_X				;BR = SAME, NO ACTION

	CMPI	POWERUP_FLY_TIME/4,A11
	JRLO	PGV_SEND_PLAYER

	MOVE	A0,A7
	SOUND1	POWERUP_STEAL_SND		;TELL EVERYONE IT GOT STOLEN
	MOVE	A7,A0
	JRUC	PGV_SEND_PLAYER

PGV_LOAD_NEW
	MOVK	1,A11
	CALLA	PUTA11				;SET THE IN FLIGHT FLAG

PGV_SEND_PLAYER
	MOVE	A2,A10				;PASS THIS NEW PLAYER
	CALLA	PUTA10

	MOVE	*A8(OID),A14,W
	ANDI	MASK_ID,A14
;	SLL	28,A14
;	SRL	28,A14
	CMPI	ID_LIFE,A14			;IS THIS A LIFE ICON?
	JRNE	PGV_GO_PROC			;BR = NO

	MOVI	POWERUP_FLY_TIME,A7
	SUB	A11,A7
	JRGT	PGV_ADD_INV
	MOVK	1,A7				;MAKE SURE THERE'S A LITTLE TIME
PGV_ADD_INV
	ADDK	2,A7				;ADD A COUPLE FOR INSURANCE
	MOVE	*A2(PINVINCIBLE),A14,W
	CMP	A7,A14
	JRGE	PGV_GO_PROC
	MOVE	A7,*A2(PINVINCIBLE),W
;	ADDRM	A7,*A2(PINVINCIBLE),W		;MAKE HIM INVINCIBLE FOR FLIGHT

PGV_GO_PROC
	MOVI	POWERUP_FLY,A7
	CALLA	PUTWAKE

	ORIM	M_WAVEWAIT,*A0(PROCID),W

	SOUND1	POWERUP_HIT_SND			;LET'S MAKE SOME NOISE

;	MOVE	*A8(OPARTS),A0,L
;	JRZ	PGV_NO_HALO
;	CALLA	CKPULLANIM			;STOP IT FROM ANIMATING
;	CALLA	OBJOFF				;AND MAKE SURE IT IS OFF
;PGV_NO_HALO

PGV_X
	MMFM	SP,A0,A1,A7,A8,A10,A11
	RETS

**************************************************************************
*								         *
* POWER_GROUND_COLL - COLLISION VECTOR FOR GROUND COLLISION.		 *
* A8 = PTR TO POWERUP							 *
*								         *
**************************************************************************
POWER_GROUND_COLL
	MOVE	*A8(OYVEL),A14,L
	JRN	PGC_DONE
	JRZ	PGC_DONE
	SRA	2,A14
	CMPI	[1,0],A14
	JRLT	PGC_DONE
	NEG	A14
	MOVE	A14,*A8(OYVEL),L
	RETS
PGC_DONE
	ANDNIM	M_GCOLL,*A8(OFLAGS),W
	JAUC	CLR_VEL

*
*SOUND FOR HITTING A POWERUP WITH A BULLET
*
POWERUP_HIT_SND
	.WORD	0F341H,47,0A40EH,0

*
*SOUND FOR STEALING A POWER UP
*
POWERUP_STEAL_SND
	.WORD	0F241H,48,0A410H,0

*
*BASE FLIGHT TIME(IN TICKS) TO GET TO THE PLAYERS SCORE AREA
*
POWERUP_FLY_TIME	EQU	45
**************************************************************************
*								         *
* POWERUP_FLY - PROCESS TO SEND A POWERUP TO A PLAYERS SCORE AREA.	 *
* 		A11 WILL ALWAYS BE THE # OF TICKS THAT HAVE ELAPSED	 *
* 		SINCE STARTING TOWARDS THAT AREA.			 *
* A8 = PTR POWERUP OBJECT						 *
* A10 = PTR TO PLAYERS AREA TO WHICH WE ARE TRAVELING			 *
* A11 = ELAPSED TICKS							 *
*								         *
**************************************************************************
POWERUP_FLY
	ORIM	M_WAVEWAIT,*A13(PROCID),W
	CALLA	PSTOP
PF_UPDATE_LOOP
;	MOVI	PBOXSIZ,A0
;	HALFXY	A0			;FLY TO THE CENTER 'O THE PLAYER BOX

	MOVI	PBOXPOWER,A0		;Get the offset for fly target
	MOVE	*A10(PSCRAD),A1,L
	ADDXY	A0,A1			;Offset for collecting player

	MOVE	A1,A3			;Isolate screen coords
	SEXT	A1,W
	SRA	16,A3

	MOVE	@ZBASE,A5,L
	ADDI	ZMAX_REAL,A5

	STOUXY	A5,A1,A3		;Convert screen target to universe

;	MOVE	A1,A3			;SETUP OF SLINEVEL_LOAD_3D
;	SEXT	A1,W
;	SUBI	HALFX,A1
;	SLL	15,A1
;	MOVE	@XBASE,A14,L
;	ADD	A14,A1			;ADD XBASE
;	SRA	16,A3
;	MOVE	@YHALF,A14,W
;	SUB	A14,A3
;	SLL	15,A3
;	MOVE	@YBASE,A14,L
;	SUB	A14,A3			;ADD YBASE

;	MOVE	@ZBASE,A5,L
;	ADDI	08000H,A5		;ADD TO ZBASE

	MOVE	*A8(OXVAL),A2,L		;Get everything setup for SLINEVEL
	MOVE	*A8(OYVAL),A4,L
	MOVE	*A8(OZVAL),A6,L

PF_SKIPSR
	MOVI	POWERUP_FLY_TIME,A7
	SUB	A11,A7			;IT WILL TAKE THIS AMOUNT OF TICKS
	JRLE	PF_SCORE		;BR = THERE ALREADY

;	CALLA	SLINEVEL_LOAD_3D	;GET THE VELOCITIES
	CALLA	SLINEVEL_3D		;GET THE VELOCITIES

	MOVI	XSCROLL,A14
	MMFM	A14,A2,A4,A6
	sra	ZFRAC,a2		; compensate for new fraction
	ADD	A6,A1			;COMPENSATE FOR XSCROLL
	SUB	A4,A3			;		YSCROLL
	ADD	A2,A5			;		ZSCROLL
	move	a1,*a8(OXVEL),L
	move	a3,*a8(OYVEL),L
	move	a5,*a8(OZVEL),L

PF_LP
	SLEEP	3
	ADDK	3,A11
;	CALLA	SCRTST			;CHECK FOR OFF SCREEN
;	JREQ	PF_LP
 	MOVB	*A8(OFLAGS),A14
	JRNN	PF_UPDATE_LOOP
PF_SCORE
	MOVE	*A8(OID),A0,W		;JUMP TO AWARD ROUTINE BASED ON OID
	CALLA	DELETE_OBJ
	SLL	25,A0
	SRL	27,A0
	SLL	5,A0
	ADDI	POWERUP_AWARD_TAB,A0
	MOVE	*A0,A0,L
	MOVE	A10,A2
;	MOVK	NUM_BOMB,A1
	CALL	A0
	DIE

**************************************************************************
*								         *
* 			POWERUP AWARD ROUTINES				 *
*								         *
**************************************************************************
*
*TABLE OF ROUTINES TO CALL TO AWARD A POWERUP
*
POWERUP_AWARD_TAB
	.LONG	LIFE_AWARD,SBOMB_AWARD,PROCK_AWARD,CD_AWARD,JEWEL_AWARD
	.LONG	CLIP_AWARD,WINGS_AWARD,SHIELD_AWARD,SUPERGUN_AWARD
	.LONG	LAZER_AWARD,CD_AWARD,BOOBY_PRIZE_AWARD

**************************************************************************
*								         *
* BOOBY_PRIZE_AWARD - AWARD MAMMERY BOOBY PRIZE.			 *
* A2 = PTR TO PLAYER							 *
*								         *
**************************************************************************
BOOBY_PRIZE_AWARD
	PUSH	A0

	INCM	*A2(PMAMMY),W

	SOUND1	SND_MORPH

	PULLQ	A0
	RETS

**************************************************************************
*								         *
* LIFE_AWARD - AWARD EXTRA LIFE.					 *
* A2 = PTR TO PLAYER							 *
*								         *
**************************************************************************
LIFE_AWARD
	MMTM	SP,A0,A1

	INCM	@ENERGY_AWARDS,W

	ADJUST	ADJENERGY		;Get amount of energy bar from CMOS
	SLL	15,A0			;Add half for POWER drink
	CMPI	[50,0],A0
	JRLE	LA_NRG_OK		;BR = Added life is in range

	MOVI	[50,0],A0		;This is the max to give

LA_NRG_OK
	CALLA	ADDNLIFE

	SOUND1	SND_EXTRA_ENERGY

	MOVI	ENERGY_TAB_3P,A0
	MOVI	ENERGY_TAB_2P,A1
	CALLR	DO_HEADS_UP

	MMFM	SP,A0,A1
	RETS

*
*SOUND TO MAKE WHEN GIVING ADDED ENERGY
*
SND_EXTRA_ENERGY
	.WORD	0F1E0H,180,0A55AH,98,0A85AH,0	;Sound for more life

**************************************************************************
*								         *
* PROCK_AWARD - AWARD ANOTHER ROCKET BOMB TO THE PLAYER.		 *
* A2 = PTR TO PLAYER							 *
*								         *
**************************************************************************
PROCK_AWARD
	MMTM	SP,A0,A1

	MOVE	*A2(PBOMB1),A1,W
	JRNZ	PA_NO_LED_ON
	CALLA	P_LED_ON
PA_NO_LED_ON
 	ADDK	3,A1
	MOVE	A1,*A2(PBOMB1),W

;	ADDKM	3,*A2(PBOMB1),W			;Little guys give one

	CALLA	OUT_BOMBS

;	SOUND1	PROCK_SND
	MOVE	*A2(PPOWERHEADS),A14,W		;ALREADY SEEN THIS?
	ANDI	M_PROCK,A14
	JRZ	PA_BIG_HEAD

	MOVI	SM_PROCK_TAB_3P,A0
	MOVI	SM_PROCK_TAB_2P,A1
	CALLR	DO_HEADS_UP
	JRUC	PA_X

PA_BIG_HEAD
	MOVI	PROCK_TAB_3P,A0
	MOVI	PROCK_TAB_2P,A1
	CALLR	DO_HEADS_UP
	JRZ	PA_X

	ORIM	M_PROCK,*A2(PPOWERHEADS),W

PA_X
	MMFM	SP,A0,A1
	RETS

*
*SOUND TO MAKE WHEN AWARDING ANOTHER ROCKET BOMB 
*
PROCK_SND
	.WORD	0F2D0H,040H,0808CH,0

**************************************************************************
*								         *
* CD_AWARD - AWARD ANOTHER CD TO THE PLAYER.				 *
* A2 = PTR TO PLAYER							 *
*								         *
**************************************************************************
CD_AWARD
	MMTM	SP,A0,A1

	MOVE	*A2(PBOMB1),A1,W
	JRNZ	CDA_NO_LED_ON
	CALLA	P_LED_ON
CDA_NO_LED_ON
 	ADDK	10,A1
	MOVE	A1,*A2(PBOMB1),W

;	ADDKM	10,*A2(PBOMB1),W		;ADD SOME MORE

	CALLA	OUT_BOMBS

	MOVE	*A2(PPOWERHEADS),A14,W		;ALREADY SEEN THIS?
	ANDI	M_CD,A14
	JRZ	CDA_BIG_HEAD

	MOVI	SM_PCD_TAB_3P,A0
	MOVI	SM_PCD_TAB_2P,A1
	CALLR	DO_HEADS_UP
	JRUC	CDA_X

CDA_BIG_HEAD
	MOVI	PCD_TAB_3P,A0
	MOVI	PCD_TAB_2P,A1
	CALLR	DO_HEADS_UP
	JRZ	CDA_X

	ORIM	M_CD,*A2(PPOWERHEADS),W

CDA_X
	MMFM	SP,A0,A1
	RETS

**************************************************************************
*								         *
* 	CLIP_AWARD							 *
* 									 *
* 	Award another clip to the player.				 *
* 									 *
* 	A2 = Ptr to player						 *
*								         *
**************************************************************************
CLIP_AWARD
	PUSH	A0
	CALLA	GUNPOWER_TO_MAX

	ADDKM	1,*A2(PCLIPS),W			;Add another one

* Need sound and number update

	PULLQ	A0
	RETS

**************************************************************************
*								         *
* 	SHIELD_AWARD							 *
* 									 *
* 	Award some shield to the player.				 *
* 									 *
* 	A2 = Ptr to player						 *
*								         *
**************************************************************************
SHIELD_AWARD
	PUSH	A0
	INCM	@SHIELD_AWARDS,W
	SOUND1	SND_SHIELD

     	MOVI	[30,0],A14
	MOVE	A14,*A2(PSHIELD),L

	CALLA	PLAYER_SHIELD

	PULLQ	A0
	RETS

*
* SOUND TO MAKE WHEN AWARDING A SHIELD
*
SND_SHIELD
;	.WORD	0F1E0H,132,0A55DH,0		;Sound for shield
	.WORD	0F1E0H,92,0A845H,0		;Sound for shield

**************************************************************************
*								         *
* 	SUPERGUN_AWARD							 *
* 									 *
* 	Award a SuperGun to the player.					 *
* 									 *
* 	A2 = Ptr to player						 *
*								         *
**************************************************************************
SUPERGUN_AWARD
	MMTM	SP,A0,A1

	INCM	@SUPERGUN_AWARDS,W

	SOUND1	SND_SUPERGUN

	MOVIM	200,*A2(PPLASMASHOTS),W

	MOVI	SUPERGUN_TAB_3P,A0
	MOVI	SUPERGUN_TAB_2P,A1
	CALLR	DO_HEADS_UP

	MMFM	SP,A0,A1
	RETS

SND_SUPERGUN
	.WORD	0F1E0H,120,0A519H,67,0A857H,0		;Sound for SuperGun

**************************************************************************
*								         *
* 	LAZER_AWARD							 *
* 									 *
* 	Award a Lazer disc to the player.				 *
* 									 *
* 	A2 = Ptr to player						 *
*								         *
**************************************************************************
LAZER_AWARD
	MMTM	SP,A0,A1

	INCM	@LAZER_AWARDS,W

	SOUND1	SND_LAZER

	MOVIM	25,*A2(PBOMB2),W

	CALLA	P_LED_ON

;	ADDIM	5,*A2(PBOMB2),W

	MOVI	LAZER_TAB_3P,A0
	MOVI	LAZER_TAB_2P,A1
	CALLR	DO_HEADS_UP

	MMFM	SP,A0,A1
	RETS

SND_LAZER
	.WORD	0F1E0H,52,0A848H,0		;Sound for Lazer disc

**************************************************************************
*								         *
* SBOMB_AWARD - AWARD A SMART BOMB TO THE PLAYER.			 *
* A2 = PTR TO PLAYER							 *
*								         *
**************************************************************************
SBOMB_AWARD
	MMTM	SP,A0,A1,A7,A11
	MOVE	A2,A11
	CREATE	PID_IND,SBOMB_SHOCK_WAVE
	MOVIM	120,@DISPATCH_DELAY,W
	MOVKM	1,@HOLD_ENEMY_DISPATCH,W
	MMFM	SP,A0,A1,A7,A11
	RETS

**************************************************************************
*								         *
* 	PROC_DELAYED_SBOMB						 *
* 									 *
* 	Process to do a delayed SBOMB effect.				 *
* 									 *
* 	A10 = Delay time						 *
* 	A11 = Ptr to player triggering					 *
*								         *
**************************************************************************
PROC_DELAYED_SBOMB
	SLEEPR	A10	
	MOVIM	120,@DISPATCH_DELAY,W
	MOVKM	1,@HOLD_ENEMY_DISPATCH,W
	JRUC	SBOMB_SHOCK_WAVE

SSW_PRIORITY	.EQU	0FFH	;PRIORITY OF THE SMART BOMB RECON EFFECT
**************************************************************************
*								         *
* SBOMB_SHOCK_WAVE - PROCESS TO HANDLE SHOCK OF A SMART BOMB.		 *
* A11 = PTR TO PLAYER SMART BOMBING					 *
*								         *
**************************************************************************
SBOMB_SHOCK_WAVE
	SOUND1	SND_SBOMB_EXP3
;	calla	DOBIGSHAKE
	MOVIM	07FFFH,@IRQSKYE,W
	MOVIM	07FFFH,@IRQGNDE,W

* Switch in palette based on player that shot smart bomb

	MOVE	A11,A2
	CALLA	GPLAYNUM

	MOVE	@NPLAYERS,A14,W
	DEC	A14
	JRNZ	SSW_3P			;BR = 3 player model
	MOVI	TAB_SBOMB_COLORS_2P,A1
	JRUC	SSW_CHANGE_PAL
SSW_3P
	MOVI	TAB_SBOMB_COLORS_3P,A1
SSW_CHANGE_PAL
	SLL	5,A0
	ADD	A0,A1
	MOVE	*A1,A0,L
	MOVE	*A0+,A2,W		;Grab the color count
	MOVI	6400H,A1		;This is where the colors go
	CALLA	PALSET

	SLEEP	1
	SOUND1	SND_SBOMB_EXP2
	SLEEP	1
	SOUND1	SND_SBOMB_EXP2	
	MOVE	@SKYCOLOR,@IRQSKYE,W
	MOVE	@GROUNDCOLOR,@IRQGNDE,W
	MOVE	A11,A2
	CALLR	SCAN_FOR_SBOMB		;YIKES!
	MOVE	B2,A10
;	MOVKM	1,@HOLD_ENEMY_DISPATCH,W
;	MOVE	@WAVE,A14,W
;SSW_FUTURE
	SLEEP	2

	MOVIM	07FFFH,@IRQSKYE,W
	MOVIM	07FFFH,@IRQGNDE,W
	MOVKM	1,@SUPRESS_PAGE_FLIP,W	;Shut down all writes to DPYST
	MOVIM	DPYSTRT2,@DPYST,L	;Rock on to FREAK frame

	SLEEP	3

	MOVE	@SKYCOLOR,@IRQSKYE,W
	MOVE	@GROUNDCOLOR,@IRQGNDE,W
	CLRM	@SUPRESS_PAGE_FLIP,W	;Restore writes to DPYST

	SLEEP	2

	MOVIM	07FFFH,@IRQSKYE,W
	MOVIM	07FFFH,@IRQGNDE,W
	MOVKM	1,@SUPRESS_PAGE_FLIP,W	;Shut down all writes to DPYST
	MOVIM	DPYSTRT2,@DPYST,L	;Rock on to FREAK frame

	SLEEP	3

	MOVE	@SKYCOLOR,@IRQSKYE,W
	MOVE	@GROUNDCOLOR,@IRQGNDE,W
	CLRM	@SUPRESS_PAGE_FLIP,W	;Restore writes to DPYST

	SLEEP	2
;	calla	DOSMALLSHAKE

	MOVIM	07FFFH,@IRQSKYE,W
	MOVIM	07FFFH,@IRQGNDE,W
	MOVKM	1,@SUPRESS_PAGE_FLIP,W	;Shut down all writes to DPYST
	MOVIM	DPYSTRT2,@DPYST,L	;Rock on to FREAK frame

	SLEEP	3

	MOVE	@SKYCOLOR,@IRQSKYE,W
	MOVE	@GROUNDCOLOR,@IRQGNDE,W
	CLRM	@SUPRESS_PAGE_FLIP,W	;Restore writes to DPYST

	SLEEP	2

	MOVIM	07FFFH,@IRQSKYE,W
	MOVIM	07FFFH,@IRQGNDE,W
	MOVKM	1,@SUPRESS_PAGE_FLIP,W	;Shut down all writes to DPYST
	MOVIM	DPYSTRT2,@DPYST,L	;Rock on to FREAK frame

	SLEEP	3

	MOVE	@SKYCOLOR,@IRQSKYE,W
	MOVE	@GROUNDCOLOR,@IRQGNDE,W
	CLRM	@SUPRESS_PAGE_FLIP,W	;Restore writes to DPYST

	SLEEP	2

	MOVIM	07FFFH,@IRQSKYE,W
	MOVIM	07FFFH,@IRQGNDE,W
	MOVKM	1,@SUPRESS_PAGE_FLIP,W	;Shut down all writes to DPYST
	MOVIM	DPYSTRT2,@DPYST,L	;Rock on to FREAK frame

	SLEEP	3

	MOVE	@SKYCOLOR,@IRQSKYE,W
	MOVE	@GROUNDCOLOR,@IRQGNDE,W
	CLRM	@SUPRESS_PAGE_FLIP,W	;Restore writes to DPYST

	SLEEP	2

	MOVIM	07FFFH,@IRQSKYE,W
	MOVIM	07FFFH,@IRQGNDE,W
	MOVKM	1,@SUPRESS_PAGE_FLIP,W	;Shut down all writes to DPYST
	MOVIM	DPYSTRT2,@DPYST,L	;Rock on to FREAK frame

	SLEEP	3

	MOVE	@SKYCOLOR,@IRQSKYE,W
	MOVE	@GROUNDCOLOR,@IRQGNDE,W
	CLRM	@SUPRESS_PAGE_FLIP,W	;Restore writes to DPYST

;	SLEEP	2
	SLEEP	50
	MOVE	A10,A10			;We're 0 enemies killed?
	JRNZ	SBOMB_KILLED_SOME	;BR = No
	SOUND1	SND_SBOMB_BOOBY		;Do this sound when no enemies wasted
	JRUC	SBOMB_ON_WITH_IT
SBOMB_KILLED_SOME
;	CMPK	8,A10			;We're a shitload of enemies killed?
;	JRLO	SBOMB_NORMAL_RESPONSE	;BR = No
;	SOUND1	SND_SBOMB_1ST_PRIZE	;Do this for total carnage
;	JRUC	SBOMB_ON_WITH_IT
;SBOMB_NORMAL_RESPONSE
	ADJUST	ADJPROFANITY
	JRNZ	SBOMB_NORM_SOUND

	RANDENT	TAB_SBOMB_SNDS_G,NUM_SBOMB_SNDS-1,5,L
	JRUC	SBOMB_ACK_SOUND

SBOMB_NORM_SOUND
	RANDENT	TAB_SBOMB_SNDS,NUM_SBOMB_SNDS,5,L
SBOMB_ACK_SOUND
	CALLA	ONESND			;Normal Smart bomb sound gig
SBOMB_ON_WITH_IT
	SLEEP	50
;	CLRM	@HOLD_ENEMY_DISPATCH,W
	MOVE	@GAME_STATE,A14,W
	CMPI	INPLAY,A14
	JANE	SUCIDE

	MOVE	*A11(POBJ),A14,L	;DID THIS GUY DIE?
	JAZ	SUCIDE			;BR = YES, NO MORE STUFF

	MOVI	SSW_PRIORITY,A0
	MOVI	130,A1
	JSRP	START_HUP_WAIT

	MOVE	A11,A2
	MOVE	A10,@RAMTEMP1,W		;STORE COUNT
*SELECT CORRECT SUFFIX FOR THE JOB
	CMPI	1,A10
	JRNE	SSW_S
	MOVIM	SUFFIX_NULL,@RAMTEMP2,L
	JRUC	SSW_MORE
SSW_S
	MOVIM	SUFFIX_S,@RAMTEMP2,L
SSW_MORE
	MOVI	10000,A9
	MPYU	A10,A9			;CALCULATE THE BONUS POINT SITUATION
	MOVE	A9,@RAMTEMP3,L
	MMTM	A12,A9,A11

	CALLR	SET_PLAYER_COLOR
	SRL	16,A5
	MOVE	A5,@RAMTEMP4,W

;	MOVI	SBOMB_RECON_MESS,A8
;	CALLA	LM_SETUP
;	CALLR	CENTER_PLAYER_TEXT	;CORRECT POSITION
;	CALLR	SET_PLAYER_TOID		;CORRECT OID
;	MOVK	1,A0
;	JSRP	PRINTF
	MMFM	A12,A9,A11
	MOVE	A11,A2
	MOVE	*A2(POBJ),A14,L		;DID THE PLAYER DIE?
	JRZ	SSW_CLRIT		;BR = YES
	SLEEP	60
	MOVE	A11,A2
	MOVE	A9,A1
	CALLA	SCORE			;AWARD THE BONUS
SSW_CLRIT
	CALLR	CLR_PLAYER_TEXT		;CLEAR JUST THIS PLAYERS TEXT
	
	DIE

**************************************************************************
*								         *
* 	INIT_SBOMB_PAGE							 *
* 									 *
* 	Initialize the video page for the Smart Bomb effect		 *
* 									 *
* 	Call with JSRP							 *
*								         *
**************************************************************************
INIT_SBOMB_PAGE
;	MOVI	0B0B0B0BH,A0
	CLR	A0
	CALLA	FILL_PAGE2
	MOVI	GXBOOM,A8		;Let's setup the gnarly still
	CLR	A9			;Starting point of picture
	MOVI	PAGE2_START,A10		;Put it on this page
	CLR	A11			;No fade
	JAUC	STILL			;Decompress that beeeaahtch

**************************************************************************
*								         *
* CENTER_PLAYER_TEXT - RETURN THE VALUE THAT IS THE CENTER X OF THE	 *
* 			PLAYERS HIT AREA.				 *
* A2 = PTR TO PLAYER DATA AREA						 *
* A9 = [Y,X] TEXT LOCATION						 *
* RETURNS								 *
* 	A9 X PART = SCREEN RELATIVE PLAYER CENTER X			 *
* NOTE: A9 Y PART IS KEPT INTACT					 *
*								         *
**************************************************************************
CENTER_PLAYER_TEXT
	PUSH	A0
	MOVE	*A2(PHITBOXLR),A0,L
	MOVE	*A2(PHITBOXUL),A14,L
	SUBXY	A14,A0
	ZEXT	A0
	SRL	1,A0
	ADDXY	A0,A14
	MOVX	A14,A9			;CENTER IN THE PLAYERS BOX
	PULLQ	A0
	RETS

**************************************************************************
*								         *
* SET_PLAYER_COLOR - SET THE COLOR OF A STRING TO MATCH THAT OF 	 *
* 			THE PLAYER ASSOCIATED WITH IT.			 *
* A2 = PTR TO PLAYER							 *
* A5 = STRING [COLOR,PALETTE]						 *
* RETURNS								 *
* 	A5 = STRING [COLOR,PALETTE] FOR THIS PLAYER			 *
*								         *
**************************************************************************
SET_PLAYER_COLOR
	PUSH	A0
	CALLA	GPLAYNUM
	SLL	5,A0
	ADDI	PLAYER_COLOR_TAB,A0
	MOVE	*A0,A5,L
	PULLQ	A0
	RETS
PLAYER_COLOR_TAB
	.LONG	COLOR_PBLUE,COLOR_PRED

**************************************************************************
*								         *
* SET_PLAYER_TOID - SET THE OID OF THIS STRING TO THAT OF A PLAYER TYPE	 *
* 			TEXT.						 *
* A2 = PTR TO PLAYER							 *
* B1 = [SND INDX, OID]							 *
* RETURNS								 *
* 	B1 = SND INDX, PLAYER TEXT OID]					 *
*								         *
**************************************************************************
SET_PLAYER_TOID
	PUSH	A0
	CALLA	GPLAYNUM
	SLL	4,A0
	ADDI	PLAYER_TOID_TAB,A0
	MOVE	*A0,A14,W
	MOVE	A14,B14
	MOVX	B14,B1
	PULLQ	A0
	RETS
PLAYER_TOID_TAB
	.LONG	OID_P1TEXT,OID_P2TEXT

**************************************************************************
*								         *
* CLR_PLAYER_TEXT - CLEAR THE TEXT FOR A SPECIFIC PLAYER.		 *
* A2 = PTR TO PLAYER DATA AREA						 *
*								         *
**************************************************************************
CLR_PLAYER_TEXT
	PUSH	A0
	CALLA	GPLAYNUM
	SLL	4,A0
	ADDI	PLAYER_TOID_TAB,A0
	MOVE	*A0,A0,W
	CALLA	KILOBJ_ALL
	PULLQ	A0
	RETS

SND_SBOMB_EXP1
	.WORD	0E1F0H,88,08303H,0	;Final explosion sound, channel 1
SND_SBOMB_EXP2
	.WORD	0E2F0H,40,0838FH,0	;Final explosion sound, channel 2
SND_SBOMB_EXP3
	.WORD	0E3F0H,88,08390H,0	;Final explosion sound, channel 3

	.IF GERMAN

SBOMB_RECON_MESS
	MESS_MAC RD15FONT,2,197,10+SKYTOPOF,COLOR_PWHITE,STRCNRMO,10000H|OID_TEXT
	.STRING	"INTELLIGENTE\n"
	.STRING	"BOMB\aE\a\d\*b\n\n"
	.STRING "ERKUNDUNGSRAPPORT\a:\a\n\n"
	.STRING "\b%d\*b ZIEL%p ZERST",C_GERO,"RT\a.\a\n\n"
	.STRING "\b%,ld\*b BONUS-PUNKTE.",0
	.WORD	5
	.WORD	1
	.LONG	RD7FONT
	.LONG	RAMTEMP4
	.WORD	5
	.WORD	1
	.WORD	COLOR_WHITE
	.LONG	RAMTEMP1
	.LONG	RAMTEMP4
	.LONG	RAMTEMP2
	.WORD	5
	.WORD	1
	.WORD	COLOR_WHITE
	.LONG	RAMTEMP3
	.LONG	RAMTEMP4
	.EVEN

	.ELSE

SBOMB_RECON_MESS
	MESS_MAC RD15FONT,2,197,25+SKYTOPOF,COLOR_PWHITE,STRCNRMO,10000H|OID_TEXT
	.STRING	"SMART BOM\aB\a\d\*b\n\n"
	.STRING "RECON REPORT\a:\a\n\n"
	.STRING "\b%d\*b TARGET%p DESTROYED\a.\a\n\n"
	.STRING "\b%,ld\*b BONUS POINTS.",0
	.WORD	5
	.WORD	1
	.LONG	RD7FONT
	.LONG	RAMTEMP4
	.WORD	5
	.WORD	1
	.WORD	COLOR_WHITE
	.LONG	RAMTEMP1
	.LONG	RAMTEMP4
	.LONG	RAMTEMP2
	.WORD	5
	.WORD	1
	.WORD	COLOR_WHITE
	.LONG	RAMTEMP3
	.LONG	RAMTEMP4
	.EVEN

	.ENDIF

*
*SOUND TO MAKE WHEN AWARDING A SMART BOMB
*
NUM_SBOMB_SNDS	.EQU	5

TAB_SBOMB_SNDS
	.LONG	SND_SBOMB1
TAB_SBOMB_SNDS_G
	.LONG	SND_SBOMB2, SND_SBOMB3, SND_SBOMB_1ST_PRIZE
	.LONG	SND_SBOMB4

SND_SBOMB1
	.WORD	0F3F1H,53,0881DH,0	;"Kick ass!"
SND_SBOMB2
	.WORD	0F3F1H,79,0881BH,0	;"Rock n'Roll"
SND_SBOMB3
	.WORD	0F3F1H,48,08823H,0	;"Toasty!"
SND_SBOMB4
	.WORD	0F3F1H,130,08874H,0	;"Hey Baby...Ka-Blam!"

SND_SBOMB_BOOBY
	.WORD	0F3F1H,33,08819H,0	;"Excrement"
SND_SBOMB_1ST_PRIZE
	.WORD	0F3F1H,173,0881CH,0	;"G-G-G-Gaow!!"


**************************************************************************
*								         *
* SCAN_FOR_SBOMB - SCAN A GIVEN OBJECT LIST FOR OBJECTS TO BLOW UP	 *
* 		'CAUSE OF A SMART BOMB					 *
* A2 = PTR TO PLAYER SCANNING						 *
* B8 = PTR TO OBJECT LIST TO SCAN					 *
* RETURNS:								 *
* 	B2 = NUMBER OF DESTRUCTION CALLS MADE				 *
*								         *
**************************************************************************
*ENTRY POINT FOR HUMAN SMART BOMB
SCAN_FOR_SBOMB_HUMAN
	MMTM	SP,A0,A1,A3,A4,A5,A6,A7,A8,A9,A10,A11
	MMTM	SP,B0,B1,B3,B4,B5
	MOVI	OID_BLOWUP,B3
	CLR	B2				;CLEAR DESTRUCTO COUNT
	MOVI	SUPPLSTS+4*020H,B5		;THIS IS THE HUMAN ENTRY
	JRUC	SFS_RESET

*ENTRY POINT FOR ENEMY SMART BOMB
SCAN_FOR_SBOMB
	MMTM	SP,A0,A1,A3,A4,A5,A6,A7,A8,A9,A10,A11
	MMTM	SP,B0,B1,B3,B4,B5
	MOVI	OID_BLOWUP,B3
	CLR	B2				;CLEAR DESTRUCTO COUNT
	MOVI	SUPPLSTS+2*020H,B5		;THIS IS THE ENEMY ENTRY
SFS_RESET
	MOVE	*B5,B0,L			;GET THE SUPP LIST HEAD
	JRZ	SFS_X
SFS_LP	
	MOVE	*B0(OCVECT),B1,L		;GRAB THE COLLISION VECTOR
	JRZ	SFS_TST				;CAN'T COLLIDE
	
	MOVB	*B0(OFLAGS+B_NOCOLL-7),B14	;WANTS THE COLLISION?
	JRN	SFS_TST				;BR = NO

SFS_COLL_LIST
	MOVE	*B1+,B14,W			;GET ID
	JRZ	SFS_TST				;WE'VE HIT DEFAULT
	CMP	B3,B14				;IS THIS THE GROUND I.D.?
	JREQ	SFS_MATCH			;BR = YES
	ADDI	30H,B1				;SKIP MASK AND VECTOR
	JRUC	SFS_COLL_LIST			;SEARCH SOME MORE
SFS_MATCH
	MOVE	*B0(OPART1),B14,L
	JRZ	SFS_GOT_HEAD			;ALRIGHT!
	CMP	B14,B0				;IS THIS THE HEAD PART
	JRNE	SFS_TST				;BR = COOL
SFS_GOT_HEAD
	MOVE	B0,A8				;SEND THE OBJECT IN A8
	MOVE	B0,B4				;KEEP OBJECT FOR B-SIDE CMP

SFS_NEXT_LP
	MOVE	*B0(OSLINK),B0,L		;GET THE NEXT OBJECT TO PROCESS
	JRZ	SFS_BLOW_OBJECT			;NO MORE AFTER THIS
	MOVE	*B0(OPART1),B14,L
	CMP	B14,B4				;IS NEXT CONNECTED TO THIS ONE
	JREQ	SFS_NEXT_LP			;BR = YES
SFS_BLOW_OBJECT
	MOVE	*B0(OID),B4,W			;GET IT'S I.D.

	ADDK	10H,B1				;SKIP MASK
	MOVE	*B1,B14,L			;GRAB THE VECTOR

	INC	B2				;ONE MORE BABY
	PUSH	A2
	CALL	B14				;CALL-A-ROUTINE
	PULLQ	A2

	MOVE	B0,B0				;LIST DONE?
	JRZ	SFS_X				;BR = YES
	MOVB	*B0(OCTRL+B_INUSE-7),B14	;NEXT OBJECT DELETED?
	JRNN	SFS_RESET			;BR = YES, START SCAN AGAIN
	MOVE	*B0(OID),B14,W
	CMP	B4,B14				;DID WE GET AN OID CHANGE
	JRNE	SFS_RESET			;BR = YES, START SCAN AGAIN
	JRUC	SFS_LP
SFS_TST
	MOVE	*B0(OSLINK),B0,L		;GET THE NEXT
	JRNE	SFS_LP
SFS_X	
	MMFM	SP,B0,B1,B3,B4,B5
	MMFM	SP,A0,A1,A3,A4,A5,A6,A7,A8,A9,A10,A11
	RETS

**************************************************************************
*								         *
* 	DO_HEADS_UP							 *
* 									 *
* 	Pop a Heads-Up display for a given player.			 *
* 	Kills current display if priority equal or higher.		 *
* 									 *
* 	A0 = Heads up table:						 *
* 		.WORD	Priority, Duration				 *
* 		.LONG	P1_Head, P2_Head, P3_Head			 *
* 	A1 = Alternate table for 2 player model				 *
* 	A2 = Ptr to player data						 *
* 									 *
* 	Returns:							 *
* 		 Z = No heads up display activated			 *
* 		NZ = Successful creation of display			 *
*								         *
**************************************************************************
DO_HEADS_UP
	MMTM	SP,A0,A1,A7,A9,A11
	MOVE	@NPLAYERS,A14,W
	DEC	A14
	JRNZ	DHU_3P			;BR = This is a 3 player model
	MOVE	A1,A0			;Switch in the 2
DHU_3P
	MOVE	*A0,A1,W
	CMPI	0F0H,A1				;VERY HIGH PRI?
	JRHS	DHU_NO_CAN			;BR = YES, NO CANNING
	MOVE	@HUP_OFF,A14,W			;ARE HEADS UP DISPS TURNED OFF?
	JRNZ	DHU_FAIL			;BR = YES
DHU_NO_CAN
	MOVE	*A2(PDTIME),A14,W		;IS DISPLAY EFFECT RUNNING?
	JRZ	DHU_GO				;BR = NO
	MOVE	*A2(PDPRIORITY),A14,W		;DO A PRIORITY CHECK		
	CMP	A14,A1				;HOW DOES THIS NEW ONE FAIR
	JRLO	DHU_FAIL			;BR = TOO LOW
DHU_GO
	MOVE	A0,A9
	MOVE	A2,A11
	CREATE	PID_IND,HEADS_UP_PROCESS
DHU_X
	MMFM	SP,A0,A1,A7,A9,A11
	RETS
	
DHU_FAIL
	SETZ				;Flag our failure
	JRUC	DHU_X

**************************************************************************
*								         *
* START_HUP_WAIT - PROCESS SUBROUTINE TO START A NEW HEADS UP PROCESS	 *
* 		BUT NOT UNTIL CURRENT ONE RUNNING, IF IT IS OF EQUAL	 *
* 		OR HIGHER PRIORITY, IT THROUGH.				 *
* A0 = NEW PRIORITY							 *
* A1 = NEW TIME								 *
* A11 = PTR TO PLAYER							 *
* NOTE: CALL WITH JSRP							 *
*								         *
**************************************************************************
START_HUP_WAIT
	MOVE	*A11(PDTIME),A14,W
	JRZ	SHW_GO
	MOVE	*A11(PDPRIORITY),A14,W
	CMP	A14,A0				;ARE WE BETTER THAN CURRENT?
	JRHI	SHW_KIL_GO			;BR = YES, KILL CURRENT
	MMTM	A12,A0,A1
	SLEEP	2
	MMFM	A12,A0,A1
	JRUC	START_HUP_WAIT	
SHW_KIL_GO
	MOVE	A11,A2
	CALLR	CLR_HEADS_UP
SHW_GO
	MOVE	A0,*A11(PDPRIORITY),W
	MOVE	A1,*A11(PDTIME),W
	RETP

**************************************************************************
*								         *
* HEADS_UP_PROCESS - PROCESS TO OUTPUT AND TIME A HEADS UP DISPLAY.	 *
* A9 = PTR TO HEADS UP TABLE 						 *
* A11 = PTR TO PLAYER							 *
*								         *
**************************************************************************
HEADS_UP_PROCESS
	MOVE	*A11(PDOBJ),A8,L	
	JRZ	HUP_SKIP_DEL
	CALLA	OBJPROC_KILL
	CALLA	DELETE_OBJ
	CLRM	*A11(PDOBJ),L			;CLEAR BUBBA
HUP_SKIP_DEL
	MOVE	*A9+,A0,W
	MOVE	A0,*A11(PDPRIORITY),W
	MOVE	*A9+,A10,W
	MOVE	A10,*A11(PDTIME),W		;LOAD THE NEW STUFF

	MOVE	A11,A2
	CALLA	GPLAYNUM
	SLL	5,A0
	ADD	A9,A0
	MOVE	*A0,A0,L
	MOVE	A0,B0
	CALLA	MULTIMAKE			;CREATE THE HEADS UP DISPLAY
	JRZ	HUP_DIE				;BR = WE DIDN'T GET IT!

	MOVE	A13,*A8(OPLINK),L
	MOVE	A8,*A11(PDOBJ),L		;STORE THE OBJECT

	MOVE	A11,*A8(OPLAYER),L		;SAVE DIS FOR RANDOM BONUS HUP

	MOVI	PIZPOS-1,A1
	SLL	16,A1
	CALLA	STORE_ZVAL

	MOVE	*A11(PSTATUSXY),A1,L
	CALLA	SET_OFFP
	CALLA	INSERT_OBJ

	SLEEPR	A10				;KEEP IT OUT
	CLR	A14
	MOVE	A14,*A11(PDOBJ),L		;WE GONE
	MOVE	A14,*A8(OPLINK),L
	CALLA	DELETE_OBJ
HUP_DIE
	DIE

**************************************************************************
*								         *
* CLR_HEADS_UP - CLEAR CURRENT PLAYER HEADS UP DISPLAY, NO MATTER	 *
* 		WHATS UP.						 *
* A2 = PLAYER DATA AREA							 *
*								         *
**************************************************************************
CLR_HEADS_UP
	PUSH	A8
	MOVE	*A2(PDOBJ),A8,L	
	JRZ	CHU_SKIP_DEL
	CALLA	OBJPROC_KILL
	CALLA	DELETE_OBJ
	CLRM	*A2(PDOBJ),L
CHU_SKIP_DEL
	CLRM	*A2(PDTIME),W
	PULLQ	A8
	RETS

**************************************************************************
*								         *
* A_FALL_FUNC - ANIM FUNC FOR POWERUPS THAT FALL TOP TO BOTTOM		 *
* 		NEVER LANDING ON THE GROUND. IT WILL DELETE		 *
* 		THEM WHEN THEY GET OFF THE SCREEN.			 *
* A8 = PTR TO POWERUP HEAD PART						 *
*								         *
**************************************************************************
A_FALL_FUNC
	MOVE	*A8(OPLINK),A0,L	
	JRZ	AFF_SCRCK
	CALLA	GETA11				;GET REMAINING FLIGHT TIME
	JRZ	AFF_SCRCK			;BR = NOT FLYING YET
	JAUC	PULL_ANIM			;LET FLY CODE TAKE OVER
AFF_SCRCK
	CALLA	SCRTST
	JREQ	AFF_X
	CALLA	OBJPROC_KILL			;KILL THE CONTROL
	JAUC	DELETE_OBJ			;AND THE OBJECT
AFF_X
	RETS
	

	.DATA

**************************************************************************
*								         *
* 			POWERUP INITIALIZATION TABLES			 *
*								         *
**************************************************************************

*POWER UP SMART BOMB INIT TABLES
SBOMB_INIT
	.byte	1, 0, 0, 1	;OBJCNT, PRCCNT, IMGPALCNT, PALCNT
	.long	SCREAM		;PAL LIST
	.word	OID_SBOMB, 0
	LWWWW  XBOMB1, DMAWNZ, M_NOPIXSCAN, 0, OM_COLL | OM_ANIM
	.LONG	POWER_COLL
	.LONG	SCREAM_ANIM

SBOMB2_INIT
	.byte	1, 0, 0, 1	;OBJCNT, PRCCNT, IMGPALCNT, PALCNT
	.long	SCREAM		;PAL LIST
	.word	OID_SBOMB, 0
	LWWWW  XBOMB1, DMAWNZ, M_NOPIXSCAN|M_DBLSCL, 0, OM_COLL | OM_ANIM
	.LONG	POWER_COLL
	.LONG	SCREAM_ANIM

SCREAM_ANIM
	LW	XBOMB1,4
	LW	XBOMB2,4
	.long	0

*POWER UP CD INIT TABLES
CD_INIT
	.byte	1, 0, 0, 1	;OBJCNT, PRCCNT, IMGPALCNT, PALCNT
	.long	P_CD		;PAL LIST
	.word	OID_CD, 0
	LWWWW   XCD1, DMAWNZ, M_NOPIXSCAN, 0, OM_COLL | OM_ANIM
	.LONG	POWER_COLL
	.LONG	CD_ANIM

CD2_INIT
	.byte	1, 0, 0, 1	;OBJCNT, PRCCNT, IMGPALCNT, PALCNT
	.long	P_CD		;PAL LIST
	.word	OID_CD, 0
	LWWWW   XCD1, DMAWNZ, M_NOPIXSCAN|M_DBLSCL, 0, OM_COLL | OM_ANIM
	.LONG	POWER_COLL
	.LONG	CD_ANIM

CD_ANIM
	LW	XCD1,2
	LW	XCD2,2
	LW	XCD3,2
	LW	XCD4,2
	LW	XCD5,2
	LW	XCD6,2
	LW	XCD7,2
	LW	XCD8,2
	.long	0
		
*POWER UP MAMMERY BOOBY PRIZE INIT TABLE
BOOBY_PRIZE_INIT
	.byte	1, 0, 0, 1	;OBJCNT, PRCCNT, IMGPALCNT, PALCNT
	.long	STATUp1		;PAL LIST
	.word	OID_BOOBY, 0
	LWWWW   MAMMYAWARDx, DMAWNZ, M_NOPIXSCAN, 0, OM_COLL
	.LONG	POWER_COLL

*POWER UP ROCKET INIT TABLE
PROCK_INIT
	.byte	1, 0, 0, 1	;OBJCNT, PRCCNT, IMGPALCNT, PALCNT
	.long	P_CD		;PAL LIST
	.word	OID_PROCK, 0
	LWWWW   XCDSM1, DMAWNZ, M_NOPIXSCAN, 0, OM_COLL | OM_ANIM
	.LONG	POWER_COLL
	.LONG	CDSM_ANIM

CDSM_ANIM
	LW	XCDSM1,2
	LW	XCDSM2,2
	LW	XCDSM3,2
	LW	XCDSM4,2
	LW	XCDSM5,2
	LW	XCDSM6,2
	LW	XCDSM7,2
	LW	XCDSM8,2
	.long	0

*
* Extra life powerup
*
LIFE_INIT
	.byte	1, 0, 0, 1	;OBJCNT, PRCCNT, IMGPALCNT, PALCNT
	.long	P_NEWPSHA	;PAL LIST
	.word	OID_LIFE, 0
	LWWWW   NPSHAKE, DMAWNZ, M_NOPIXSCAN, 0, OM_COLL
	.LONG	POWER_COLL

LIFE2_INIT
	.byte	1, 0, 0, 1	;OBJCNT, PRCCNT, IMGPALCNT, PALCNT
	.long	P_NEWPSHA	;PAL LIST
	.word	OID_LIFE, 0
	LWWWW   NPSHAKE, DMAWNZ, M_NOPIXSCAN|M_DBLSCL, 0, OM_COLL
	.LONG	POWER_COLL

*
* Ammo clip powerup
*
CLIP_INIT
	.byte	1, 0, 0, 1	;OBJCNT, PRCCNT, IMGPALCNT, PALCNT
	.long	P_CLIPPS	;PAL LIST
	.word	OID_CLIP, 0
	LWWWW   MAGG1, DMAWNZ, M_NOPIXSCAN, 0, OM_COLL
	.LONG	POWER_COLL

*
* Shield powerup
*
SHIELD_INIT
	.byte	1, 0, 0, 1	;OBJCNT, PRCCNT, IMGPALCNT, PALCNT
	.long	P_XSHLD		;PAL LIST
	.word	OID_SHIELD, 0
	LWWWW   XSHIELD, DMAWNZ, M_NOPIXSCAN, 0, OM_COLL
	.LONG	POWER_COLL

SHIELD2_INIT
	.byte	1, 0, 0, 1	;OBJCNT, PRCCNT, IMGPALCNT, PALCNT
	.long	P_XSHLD		;PAL LIST
	.word	OID_SHIELD, 0
	LWWWW   XSHIELD, DMAWNZ, M_NOPIXSCAN|M_DBLSCL, 0, OM_COLL
	.LONG	POWER_COLL

*
* SuperGun powerup
*
SUPERGUN_INIT
	.byte	1, 0, 0, 1	;OBJCNT, PRCCNT, IMGPALCNT, PALCNT
	.long	P_SUPRGN	;PAL LIST
	.word	OID_SUPERGUN, 0
	LWWWW   SUPERGUN, DMAWNZ, M_NOPIXSCAN, 0, OM_COLL
	.LONG	POWER_COLL

SUPERGUN2_INIT
	.byte	1, 0, 0, 1	;OBJCNT, PRCCNT, IMGPALCNT, PALCNT
	.long	P_SUPRGN	;PAL LIST
	.word	OID_SUPERGUN, 0
	LWWWW   SUPERGUN, DMAWNZ, M_NOPIXSCAN|M_DBLSCL, 0, OM_COLL
	.LONG	POWER_COLL

*
* Lazer disc
*
LAZER_INIT
	.byte	2, 0, 0, 2	;OBJCNT, PRCCNT, IMGPALCNT, PALCNT
	.long	P_LD_HT,P_LDFLAM	;PAL LIST
	.word	OID_LAZER, 0
	LWWWW   XLD1, DMAWNZ, M_NOPIXSCAN, 0, OM_COLL
	.LONG	POWER_COLL

	LWWWW   DISCFLM1, DMAWNZ, 0, 0, OM_COLL | OM_ANIM
	.LONG	DUMCOLL
	.LONG	LAZER_FLAME_ANIM

LAZER2_INIT
	.byte	2, 0, 0, 2	;OBJCNT, PRCCNT, IMGPALCNT, PALCNT
	.long	P_LD_HT,P_LDFLAM	;PAL LIST
	.word	OID_LAZER, 0
	LWWWW   XLD1, DMAWNZ, M_NOPIXSCAN|M_DBLSCL, 0, OM_COLL
	.LONG	POWER_COLL

	LWWWW   DISCFLM1, DMAWNZ, M_DBLSCL, 0, OM_COLL | OM_ANIM
	.LONG	DUMCOLL
	.LONG	LAZER_FLAME_ANIM

LAZER_FLAME_ANIM
	LW	DISCFLM1,4
	LW	DISCFLM2,4
	LW	DISCFLM3,4
	LW	DISCFLM4,4
	LW	DISCFLM5,4
	.LONG	0

**************************************************************************
*								         *
* 			POWER UP COLLISIONS				 *
*								         *
**************************************************************************
POWER_COLL:
;*****	WWL PATTERN,[MASK],FUNC
	WWL	OID_GRND,0FFFFH,POWER_GROUND_COLL
	WL	0,DUMCRETS


*
* Heads up tables
*

*
* "SUPERGUN" Heads up display
*
SUPERGUN_TAB_3P
	.WORD	020H, 100
	.LONG	RED_SUPERGUN_INIT, YEL_SUPERGUN_INIT, BLUE3_SUPERGUN_INIT

SUPERGUN_TAB_2P
	.WORD	020H, 100
	.LONG	RED_SUPERGUN_INIT, BLUE2_SUPERGUN_INIT

RED_SUPERGUN_INIT
	.byte	1, 0, 0, 1	;OBJCNT, PRCCNT, IMGPALCNT, PALCNT
	.long	P_PRUPTXR	;IMGPAL
	.WORD	OID_P1HUP,0
	LWWWW	SUPERGUN_R, DMAWNZ, M_NOSCALE|M_SCRNOBJ, 0 , OM_ANIM|OM_CFUNC
	.LONG	ANIM_HEADS_UP_FLASH
	LW	C_OCONST, 0101H

YEL_SUPERGUN_INIT
	.byte	1, 0, 0, 1	;OBJCNT, PRCCNT, IMGPALCNT, PALCNT
	.long	P_PRUPTXY	;IMGPAL
	.WORD	OID_P2HUP,0
	LWWWW	SUPERGUN_Y, DMAWNZ, M_NOSCALE|M_SCRNOBJ, 0 , OM_ANIM|OM_CFUNC
	.LONG	ANIM_HEADS_UP_FLASH
	LW	C_OCONST, 0101H

BLUE3_SUPERGUN_INIT
	.byte	1, 0, 0, 1	;OBJCNT, PRCCNT, IMGPALCNT, PALCNT
	.long	P_PRUPTXB	;IMGPAL
	.WORD	OID_P3HUP,0
	LWWWW	SUPERGUN_B, DMAWNZ, M_NOSCALE|M_SCRNOBJ, 0 , OM_ANIM|OM_CFUNC
	.LONG	ANIM_HEADS_UP_FLASH
	LW	C_OCONST, 0101H

BLUE2_SUPERGUN_INIT
	.byte	1, 0, 0, 1	;OBJCNT, PRCCNT, IMGPALCNT, PALCNT
	.long	P_PRUPTXB	;IMGPAL
	.WORD	OID_P2HUP,0
	LWWWW	SUPERGUN_B, DMAWNZ, M_NOSCALE|M_SCRNOBJ, 0 , OM_ANIM|OM_CFUNC
	.LONG	ANIM_HEADS_UP_FLASH
	LW	C_OCONST, 0101H


*
* "EXTRA ENERGY" Heads up display
*
ENERGY_TAB_3P
	.WORD	020H, 100
	.LONG	RED_ENERGY_INIT, YEL_ENERGY_INIT, BLUE3_ENERGY_INIT

ENERGY_TAB_2P
	.WORD	020H, 100
	.LONG	RED_ENERGY_INIT, BLUE2_ENERGY_INIT

RED_ENERGY_INIT
	.byte	1, 0, 0, 1	;OBJCNT, PRCCNT, IMGPALCNT, PALCNT
	.long	P_PRUPTXR	;IMGPAL
	.WORD	OID_P1HUP,0
	LWWWW	EXTRAE_R, DMAWNZ, M_NOSCALE|M_SCRNOBJ, 0 , OM_ANIM|OM_CFUNC
	.LONG	ANIM_HEADS_UP_FLASH
	LW	C_OCONST, 0101H

YEL_ENERGY_INIT
	.byte	1, 0, 0, 1	;OBJCNT, PRCCNT, IMGPALCNT, PALCNT
	.long	P_PRUPTXY	;IMGPAL
	.WORD	OID_P2HUP,0
	LWWWW	EXTRAE_Y, DMAWNZ, M_NOSCALE|M_SCRNOBJ, 0 , OM_ANIM|OM_CFUNC
	.LONG	ANIM_HEADS_UP_FLASH
	LW	C_OCONST, 0101H

BLUE3_ENERGY_INIT
	.byte	1, 0, 0, 1	;OBJCNT, PRCCNT, IMGPALCNT, PALCNT
	.long	P_PRUPTXB	;IMGPAL
	.WORD	OID_P3HUP,0
	LWWWW	EXTRAE_B, DMAWNZ, M_NOSCALE|M_SCRNOBJ, 0 , OM_ANIM|OM_CFUNC
	.LONG	ANIM_HEADS_UP_FLASH
	LW	C_OCONST, 0101H

BLUE2_ENERGY_INIT
	.byte	1, 0, 0, 1	;OBJCNT, PRCCNT, IMGPALCNT, PALCNT
	.long	P_PRUPTXB	;IMGPAL
	.WORD	OID_P2HUP,0
	LWWWW	EXTRAE_B, DMAWNZ, M_NOSCALE|M_SCRNOBJ, 0 , OM_ANIM|OM_CFUNC
	.LONG	ANIM_HEADS_UP_FLASH
	LW	C_OCONST, 0101H


*
* "LAZER DISC" Heads up display
*
LAZER_TAB_3P
	.WORD	020H, 100
	.LONG	RED_LAZER_INIT, YEL_LAZER_INIT, BLUE3_LAZER_INIT

LAZER_TAB_2P
	.WORD	020H, 100
	.LONG	RED_LAZER_INIT, BLUE2_LAZER_INIT

RED_LAZER_INIT
	.byte	1, 0, 0, 1	;OBJCNT, PRCCNT, IMGPALCNT, PALCNT
	.long	P_PRUPTXR	;IMGPAL
	.WORD	OID_P1HUP,0
	LWWWW	LAZERDSC_R, DMAWNZ, M_NOSCALE|M_SCRNOBJ, 0 , OM_ANIM|OM_CFUNC
	.LONG	ANIM_HEADS_UP_FLASH
	LW	C_OCONST, 0101H

YEL_LAZER_INIT
	.byte	1, 0, 0, 1	;OBJCNT, PRCCNT, IMGPALCNT, PALCNT
	.long	P_PRUPTXY	;IMGPAL
	.WORD	OID_P2HUP,0
	LWWWW	LAZERDSC_Y, DMAWNZ, M_NOSCALE|M_SCRNOBJ, 0 , OM_ANIM|OM_CFUNC
	.LONG	ANIM_HEADS_UP_FLASH
	LW	C_OCONST, 0101H

BLUE3_LAZER_INIT
	.byte	1, 0, 0, 1	;OBJCNT, PRCCNT, IMGPALCNT, PALCNT
	.long	P_PRUPTXB	;IMGPAL
	.WORD	OID_P3HUP,0
	LWWWW	LAZERDSC_B, DMAWNZ, M_NOSCALE|M_SCRNOBJ, 0 , OM_ANIM|OM_CFUNC
	.LONG	ANIM_HEADS_UP_FLASH
	LW	C_OCONST, 0101H

BLUE2_LAZER_INIT
	.byte	1, 0, 0, 1	;OBJCNT, PRCCNT, IMGPALCNT, PALCNT
	.long	P_PRUPTXB	;IMGPAL
	.WORD	OID_P2HUP,0
	LWWWW	LAZERDSC_B, DMAWNZ, M_NOSCALE|M_SCRNOBJ, 0 , OM_ANIM|OM_CFUNC
	.LONG	ANIM_HEADS_UP_FLASH
	LW	C_OCONST, 0101H


*
* "3 CDs" Heads up display
*
PROCK_TAB_3P
	.WORD	01FH, 100
	.LONG	RED_PROCK_INIT, YEL_PROCK_INIT, BLUE3_PROCK_INIT

PROCK_TAB_2P
	.WORD	01FH, 100
	.LONG	RED_PROCK_INIT, BLUE2_PROCK_INIT

RED_PROCK_INIT
	.byte	1, 0, 0, 1	;OBJCNT, PRCCNT, IMGPALCNT, PALCNT
	.long	P_PRUPTXR	;IMGPAL
	.WORD	OID_P1HUP,0
	LWWWW	THREECD_R, DMAWNZ, M_NOSCALE|M_SCRNOBJ, 0 , OM_ANIM|OM_CFUNC
	.LONG	ANIM_HEADS_UP_FLASH
	LW	C_OCONST, 0101H

YEL_PROCK_INIT
	.byte	1, 0, 0, 1	;OBJCNT, PRCCNT, IMGPALCNT, PALCNT
	.long	P_PRUPTXY	;IMGPAL
	.WORD	OID_P2HUP,0
	LWWWW	THREECD_Y, DMAWNZ, M_NOSCALE|M_SCRNOBJ, 0 , OM_ANIM|OM_CFUNC
	.LONG	ANIM_HEADS_UP_FLASH
	LW	C_OCONST, 0101H

BLUE3_PROCK_INIT
	.byte	1, 0, 0, 1	;OBJCNT, PRCCNT, IMGPALCNT, PALCNT
	.long	P_PRUPTXB	;IMGPAL
	.WORD	OID_P3HUP,0
	LWWWW	THREECD_B, DMAWNZ, M_NOSCALE|M_SCRNOBJ, 0 , OM_ANIM|OM_CFUNC
	.LONG	ANIM_HEADS_UP_FLASH
	LW	C_OCONST, 0101H

BLUE2_PROCK_INIT
	.byte	1, 0, 0, 1	;OBJCNT, PRCCNT, IMGPALCNT, PALCNT
	.long	P_PRUPTXB	;IMGPAL
	.WORD	OID_P2HUP,0
	LWWWW	THREECD_B, DMAWNZ, M_NOSCALE|M_SCRNOBJ, 0 , OM_ANIM|OM_CFUNC
	.LONG	ANIM_HEADS_UP_FLASH
	LW	C_OCONST, 0101H


*
* "3 CDs" Heads up display (small version)
*
SM_PROCK_TAB_3P
	.WORD	00FH, 60
	.LONG	SM_RED_PROCK_INIT, SM_YEL_PROCK_INIT, SM_BLUE3_PROCK_INIT

SM_PROCK_TAB_2P
	.WORD	00FH, 60
	.LONG	SM_RED_PROCK_INIT, SM_BLUE2_PROCK_INIT

SM_RED_PROCK_INIT
	.byte	1, 0, 0, 1	;OBJCNT, PRCCNT, IMGPALCNT, PALCNT
	.long	P_PRUPTXR	;IMGPAL
	.WORD	OID_P1HUP,0
	LWWWW	LILTHREECD_R, DMAWNZ, M_NOSCALE|M_SCRNOBJ, 0 , OM_ANIM|OM_CFUNC
	.LONG	ANIM_HEADS_UP_FLASH
	LW	C_OCONST, 0101H

SM_YEL_PROCK_INIT
	.byte	1, 0, 0, 1	;OBJCNT, PRCCNT, IMGPALCNT, PALCNT
	.long	P_PRUPTXY	;IMGPAL
	.WORD	OID_P2HUP,0
	LWWWW	LILTHREECD_Y, DMAWNZ, M_NOSCALE|M_SCRNOBJ, 0 , OM_ANIM|OM_CFUNC
	.LONG	ANIM_HEADS_UP_FLASH
	LW	C_OCONST, 0101H

SM_BLUE3_PROCK_INIT
	.byte	1, 0, 0, 1	;OBJCNT, PRCCNT, IMGPALCNT, PALCNT
	.long	P_PRUPTXB	;IMGPAL
	.WORD	OID_P3HUP,0
	LWWWW	LILTHREECD_B, DMAWNZ, M_NOSCALE|M_SCRNOBJ, 0 , OM_ANIM|OM_CFUNC
	.LONG	ANIM_HEADS_UP_FLASH
	LW	C_OCONST, 0101H

SM_BLUE2_PROCK_INIT
	.byte	1, 0, 0, 1	;OBJCNT, PRCCNT, IMGPALCNT, PALCNT
	.long	P_PRUPTXB	;IMGPAL
	.WORD	OID_P2HUP,0
	LWWWW	LILTHREECD_B, DMAWNZ, M_NOSCALE|M_SCRNOBJ, 0 , OM_ANIM|OM_CFUNC
	.LONG	ANIM_HEADS_UP_FLASH
	LW	C_OCONST, 0101H

*
* "10 CDs" Heads up display
*
PCD_TAB_3P
	.WORD	01FH, 100
	.LONG	RED_PCD_INIT, YEL_PCD_INIT, BLUE3_PCD_INIT

PCD_TAB_2P
	.WORD	01FH, 100
	.LONG	RED_PCD_INIT, BLUE2_PCD_INIT

RED_PCD_INIT
	.byte	1, 0, 0, 1	;OBJCNT, PRCCNT, IMGPALCNT, PALCNT
	.long	P_PRUPTXR	;IMGPAL
	.WORD	OID_P1HUP,0
	LWWWW	TENCD_R, DMAWNZ, M_NOSCALE|M_SCRNOBJ, 0 , OM_ANIM|OM_CFUNC
	.LONG	ANIM_HEADS_UP_FLASH
	LW	C_OCONST, 0101H

YEL_PCD_INIT
	.byte	1, 0, 0, 1	;OBJCNT, PRCCNT, IMGPALCNT, PALCNT
	.long	P_PRUPTXY	;IMGPAL
	.WORD	OID_P2HUP,0
	LWWWW	TENCD_Y, DMAWNZ, M_NOSCALE|M_SCRNOBJ, 0 , OM_ANIM|OM_CFUNC
	.LONG	ANIM_HEADS_UP_FLASH
	LW	C_OCONST, 0101H

BLUE3_PCD_INIT
	.byte	1, 0, 0, 1	;OBJCNT, PRCCNT, IMGPALCNT, PALCNT
	.long	P_PRUPTXB	;IMGPAL
	.WORD	OID_P3HUP,0
	LWWWW	TENCD_B, DMAWNZ, M_NOSCALE|M_SCRNOBJ, 0 , OM_ANIM|OM_CFUNC
	.LONG	ANIM_HEADS_UP_FLASH
	LW	C_OCONST, 0101H

BLUE2_PCD_INIT
	.byte	1, 0, 0, 1	;OBJCNT, PRCCNT, IMGPALCNT, PALCNT
	.long	P_PRUPTXB	;IMGPAL
	.WORD	OID_P2HUP,0
	LWWWW	TENCD_B, DMAWNZ, M_NOSCALE|M_SCRNOBJ, 0 , OM_ANIM|OM_CFUNC
	.LONG	ANIM_HEADS_UP_FLASH
	LW	C_OCONST, 0101H


*
* "10 CDs" Heads up display
*
SM_PCD_TAB_3P
	.WORD	0FH, 60
	.LONG	SM_RED_PCD_INIT, SM_YEL_PCD_INIT, SM_BLUE3_PCD_INIT

SM_PCD_TAB_2P
	.WORD	0FH, 60
	.LONG	SM_RED_PCD_INIT, SM_BLUE2_PCD_INIT

SM_RED_PCD_INIT
	.byte	1, 0, 0, 1	;OBJCNT, PRCCNT, IMGPALCNT, PALCNT
	.long	P_PRUPTXR	;IMGPAL
	.WORD	OID_P1HUP,0
	LWWWW	LILTENCD_R, DMAWNZ, M_NOSCALE|M_SCRNOBJ, 0 , OM_ANIM|OM_CFUNC
	.LONG	ANIM_HEADS_UP_FLASH
	LW	C_OCONST, 0101H

SM_YEL_PCD_INIT
	.byte	1, 0, 0, 1	;OBJCNT, PRCCNT, IMGPALCNT, PALCNT
	.long	P_PRUPTXY	;IMGPAL
	.WORD	OID_P2HUP,0
	LWWWW	LILTENCD_Y, DMAWNZ, M_NOSCALE|M_SCRNOBJ, 0 , OM_ANIM|OM_CFUNC
	.LONG	ANIM_HEADS_UP_FLASH
	LW	C_OCONST, 0101H

SM_BLUE3_PCD_INIT
	.byte	1, 0, 0, 1	;OBJCNT, PRCCNT, IMGPALCNT, PALCNT
	.long	P_PRUPTXB	;IMGPAL
	.WORD	OID_P3HUP,0
	LWWWW	LILTENCD_B, DMAWNZ, M_NOSCALE|M_SCRNOBJ, 0 , OM_ANIM|OM_CFUNC
	.LONG	ANIM_HEADS_UP_FLASH
	LW	C_OCONST, 0101H

SM_BLUE2_PCD_INIT
	.byte	1, 0, 0, 1	;OBJCNT, PRCCNT, IMGPALCNT, PALCNT
	.long	P_PRUPTXB	;IMGPAL
	.WORD	OID_P2HUP,0
	LWWWW	LILTENCD_B, DMAWNZ, M_NOSCALE|M_SCRNOBJ, 0 , OM_ANIM|OM_CFUNC
	.LONG	ANIM_HEADS_UP_FLASH
	LW	C_OCONST, 0101H

*
* "WINGS" Heads up display
*
WINGS_TAB_3P
	.WORD	021H, 100
	.LONG	RED_WINGS_INIT, YEL_WINGS_INIT, BLUE3_WINGS_INIT

WINGS_TAB_2P
	.WORD	021H, 100
	.LONG	RED_WINGS_INIT, BLUE2_WINGS_INIT

RED_WINGS_INIT
	.byte	1, 0, 0, 1	;OBJCNT, PRCCNT, IMGPALCNT, PALCNT
	.long	P_PRUPTXR	;IMGPAL
	.WORD	OID_P1HUP,0
	LWWWW	WINGS_R, DMAWNZ, M_NOSCALE|M_SCRNOBJ, 0 , OM_ANIM|OM_CFUNC
	.LONG	ANIM_HEADS_UP_FLASH
	LW	C_OCONST, 0101H

YEL_WINGS_INIT
	.byte	1, 0, 0, 1	;OBJCNT, PRCCNT, IMGPALCNT, PALCNT
	.long	P_PRUPTXY	;IMGPAL
	.WORD	OID_P2HUP,0
	LWWWW	WINGS_Y, DMAWNZ, M_NOSCALE|M_SCRNOBJ, 0 , OM_ANIM|OM_CFUNC
	.LONG	ANIM_HEADS_UP_FLASH
	LW	C_OCONST, 0101H

BLUE3_WINGS_INIT
	.byte	1, 0, 0, 1	;OBJCNT, PRCCNT, IMGPALCNT, PALCNT
	.long	P_PRUPTXB	;IMGPAL
	.WORD	OID_P3HUP,0
	LWWWW	WINGS_B, DMAWNZ, M_NOSCALE|M_SCRNOBJ, 0 , OM_ANIM|OM_CFUNC
	.LONG	ANIM_HEADS_UP_FLASH
	LW	C_OCONST, 0101H

BLUE2_WINGS_INIT
	.byte	1, 0, 0, 1	;OBJCNT, PRCCNT, IMGPALCNT, PALCNT
	.long	P_PRUPTXB	;IMGPAL
	.WORD	OID_P2HUP,0
	LWWWW	WINGS_B, DMAWNZ, M_NOSCALE|M_SCRNOBJ, 0 , OM_ANIM|OM_CFUNC
	.LONG	ANIM_HEADS_UP_FLASH
	LW	C_OCONST, 0101H

*
*"PRESS SIDE BUTTON FOR ALTERNATE WEAPON" HEADS_UP DISPLAY
*
ALTWEAP_TAB_3P
	.WORD	0F1H, 150
	.LONG	RED_ALTWEAP_INIT, YEL_ALTWEAP_INIT, BLUE3_ALTWEAP_INIT

ALTWEAP_TAB_2P
	.WORD	0F1H, 150
	.LONG	RED_ALTWEAP_INIT, BLUE2_ALTWEAP_INIT

RED_ALTWEAP_INIT
	.byte	1, 0, 0, 1	;OBJCNT, PRCCNT, IMGPALCNT, PALCNT
	.long	P_PRUPTXR	;IMGPAL
	.WORD	OID_P1HUP,0
	LWWWW	PRESSBUT_R, DMAWNZ, M_NOSCALE|M_SCRNOBJ, 0 , OM_ANIM
	.LONG	ANIM_ALTWEAP
	
YEL_ALTWEAP_INIT
	.byte	1, 0, 0, 1	;OBJCNT, PRCCNT, IMGPALCNT, PALCNT
	.long	P_PRUPTXY	;IMGPAL
	.WORD	OID_P2HUP,0
	LWWWW	PRESSBUT_Y, DMAWNZ, M_NOSCALE|M_SCRNOBJ, 0 , OM_ANIM
	.LONG	ANIM_ALTWEAP

BLUE3_ALTWEAP_INIT
	.byte	1, 0, 0, 1	;OBJCNT, PRCCNT, IMGPALCNT, PALCNT
	.long	P_PRUPTXB	;IMGPAL
	.WORD	OID_P3HUP,0
	LWWWW	PRESSBUT_B, DMAWNZ, M_NOSCALE|M_SCRNOBJ, 0 , OM_ANIM
	.LONG	ANIM_ALTWEAP

BLUE2_ALTWEAP_INIT
	.byte	1, 0, 0, 1	;OBJCNT, PRCCNT, IMGPALCNT, PALCNT
	.long	P_PRUPTXB	;IMGPAL
	.WORD	OID_P2HUP,0
	LWWWW	PRESSBUT_B, DMAWNZ, M_NOSCALE|M_SCRNOBJ, 0 , OM_ANIM
	.LONG	ANIM_ALTWEAP

*
* Generic heads up flash
*
ANIM_HEADS_UP_FLASH
	LWLW	1,2|AFunc,A_Set_AnimLoop+1,5
AHUF_LOOP
	LWL	1,2|AFunc,OBJ_CONST
	LWL	1,1|AFunc,OBJ_OFF
	LWL	1,1|AFunc,OBJ_WNZ
	LWL	1,1|AFunc,OBJ_ON
	LWLL	1,1|AFunc,A_Anim_DSJ+2,AHUF_LOOP

	LW	1,120
	LW	1,120

	.LONG	0

*
* Animation for the "Use your CD button BOZO!" message
*
ANIM_ALTWEAP
	LW	1,20
	LWL	1,5|AFunc,OBJ_ON
	LWL	1,5|AFunc,OBJ_OFF
	LWL	1,5|AFunc,OBJ_ON
	LWL	1,5|AFunc,OBJ_OFF
	LWL	1,5|AFunc,OBJ_ON
	LWL	1,5|AFunc,OBJ_OFF
	LWL	1,5|AFunc,OBJ_ON
	LWL	1,5|AFunc,OBJ_OFF
	LWL	1,100|AFunc,OBJ_ON

	.LONG	0

*
* Different palettes for smart bomb explosion
*
TAB_SBOMB_COLORS_2P
	.LONG	P_BOOMRED,P_BOOMBLU
TAB_SBOMB_COLORS_3P
	.LONG	P_BOOMRED,P_BOOMYEL,P_BOOMBLU

P_BOOMRED:
   .word   256
   .word   00000h,00000h,00421h,00842h,00c63h,01084h,018c6h,02529h
   .word   0294ah,02d4bh,0318ch,035adh,039ceh,03defh,04210h,035ceh
   .word   0356ch,0358eh,041efh,0458ch,03d6bh,0392ah,03dd0h,041aeh
   .word   03ce8h,04000h,03800h,03909h,045cfh,041d0h,04a31h,04420h
   .word   03863h,03085h,03886h,0352ch,04632h,0456dh,03cc7h,04442h
   .word   03420h,03c41h,04085h,0356fh,03d2bh,04463h,04c20h,034c8h
   .word   04a52h,0394eh,04485h,05040h,038eah,03dd2h,04e73h,04a53h
   .word   0410ah,05083h,034c7h,041f3h,039b1h,0412dh,048e8h,05440h
   .word   040a6h,04635h,0450ah,05840h,05294h,0454bh,05c60h,05273h
   .word   05109h,049cfh,054a4h,06c81h,074c2h,06060h,04e10h,05c81h
   .word   06860h,06481h,04a32h,049ach,030c8h,02ca6h,03821h,03d8fh
   .word   054c6h,030a6h,03000h,04c62h,02800h,03022h,07080h,07880h
   .word   06c80h,03990h,06840h,07cc1h,07ca0h,0416fh,07060h,07ce2h
   .word   02000h,078a1h,07d23h,07d24h,06c60h,07860h,07dc8h,07fb7h
   .word   07d45h,039b3h,07e4dh,07fd8h,07e6dh,07f54h,07e0ah,01400h
   .word   07e8eh,07d44h,00c00h,07eafh,07f56h,07738h,07f99h,07946h
   .word   0514ch,07e4ch,07ffah,07bbch,055abh,02c41h,052b4h,0554ch
   .word   07fffh,07fddh,05420h,05c40h,01c00h,05694h,056b5h,07a4bh
   .word   07e0bh,075edh,07166h,05ad6h,06c00h,05ed6h,05ef7h,06318h
   .word   0596ch,04a56h,05ef8h,05297h,054a2h,05ab6h,05ad5h,05275h
   .word   064c5h,06739h,056b7h,060a4h,04484h,05ad8h,05eb7h,05697h
   .word   04ce6h,05633h,0498eh,05698h,05ef9h,05298h,044a6h,0620dh
   .word   07670h,075a8h,05eb5h,065cbh,06904h,065cdh,05e53h,05928h
   .word   05482h,05a12h,06ce4h,068a2h,06929h,03d29h,07693h,07d66h
   .word   07904h,07ed3h,07da7h,07f32h,0764dh,07105h,07967h,068c3h
   .word   05e11h,070c2h,07ef1h,07ffdh,07bffh,07f75h,06af5h,074e3h
   .word   04d49h,07ed0h,07f96h,05a74h,06e70h,051ceh,055f4h,06d85h
   .word   070c6h,07169h,06dabh,068e6h,07925h,06b5ah,06527h,058c6h
   .word   07b34h,05ab8h,05eb9h,06a4eh,0660dh,07fb9h,07fd9h,07e4fh
   .word   04508h,05e13h,07b56h,06f19h,04daeh,05d6ch,0768eh,07ad5h
   .word   055efh,07318h,0671bh,0779ch,05a97h,05883h,05e77h,05e99h
   .word   069edh,0520fh,066b2h,00000h,00000h,00000h,00000h,00000h

P_BOOMYEL
   .word   256
   .word   00000h,00000h,00421h,00842h,00c63h,01084h,018c6h,02529h
   .word   0294ah,02d4ah,0318ch,035adh,039ceh,03defh,04210h,035aeh
   .word   0356bh,0398eh,0420fh,045ech,03dcbh,03969h,041d0h,041cdh
   .word   03d67h,04140h,03920h,03968h,045eeh,041cfh,04a51h,04580h
   .word   03943h,03104h,03904h,03529h,04a32h,045abh,03d66h,04582h
   .word   03520h,03d61h,04164h,03d6eh,03d69h,04583h,04da0h,03506h
   .word   04a52h,0394bh,04564h,051e0h,03907h,049d2h,04e73h,04e53h
   .word   04168h,051e3h,03526h,04df3h,045b1h,04129h,049a7h,05600h
   .word   04165h,05235h,04588h,05a00h,05294h,045cah,05e40h,05293h
   .word   051e8h,04a0eh,05604h,06ea1h,07702h,06260h,04e50h,05e61h
   .word   06a80h,06681h,04a31h,04a2ch,03106h,02d05h,03921h,03d8dh
   .word   05606h,03105h,03100h,04dc2h,028c0h,030e1h,072e0h,07b00h
   .word   06ec0h,0418fh,06a60h,07f41h,07f40h,0416bh,072c0h,07f42h
   .word   020a0h,07b01h,07f83h,07f64h,06ea0h,07ae0h,07fa8h,073f7h
   .word   07f65h,049b3h,07fcdh,073f8h,07fedh,077f4h,07fcah,01460h
   .word   07feeh,07f84h,00c40h,07fefh,07bf6h,077b8h,07bf9h,07b46h
   .word   051eah,07fech,073fah,07bdch,0568bh,02d01h,052b5h,055eah
   .word   07fffh,07ffdh,055e0h,05e20h,01c80h,056b4h,056b5h,07bcbh
   .word   07fcbh,0774dh,07346h,05ad6h,06e40h,05ef6h,05ef7h,06318h
   .word   05a2bh,05656h,062f8h,05a97h,05642h,05ab6h,05ad5h,05675h
   .word   06665h,06739h,05ab7h,06244h,04584h,062d8h,05eb6h,05e97h
   .word   04de6h,05651h,049cch,06298h,066f9h,05e98h,04585h,0630dh
   .word   07790h,07768h,05ed5h,066ebh,06ae4h,066cdh,05e92h,05a48h
   .word   05622h,05a50h,06ec4h,06aa2h,06a89h,03da9h,07773h,07f86h
   .word   07b24h,07fd3h,07fa7h,077f2h,077adh,072e5h,07b47h,06aa3h
   .word   05e90h,072e2h,07bf1h,07bfdh,07bffh,077f5h,06b55h,07703h
   .word   04e29h,07ff0h,073f6h,05a93h,06f50h,0524eh,055f0h,06f65h
   .word   072a6h,07309h,06f0bh,06a86h,07b45h,06b5ah,066a7h,05a26h
   .word   077d4h,062b8h,066b9h,06b4eh,0670dh,077f9h,073f9h,07fafh
   .word   045c8h,05e50h,077d6h,06f38h,04e0dh,05e4bh,077aeh,07b95h
   .word   0566fh,07378h,06f1bh,077bch,05e96h,05a23h,05e74h,06698h
   .word   06b0dh,0528fh,06732h,00000h,00000h,00000h,00000h,00000h

P_BOOMBLU
   .word   256
   .word   00000h,00000h,00421h,00842h,00c63h,01084h,018c6h,02529h
   .word   0294ah,0296ah,0318ch,035adh,039ceh,03defh,04210h,039adh
   .word   02dadh,031cch,03e10h,031f1h,02dafh,0258eh,03a0eh,03610h
   .word   01d8fh,00110h,000eeh,0218eh,03a31h,03a0fh,04652h,00111h
   .word   00d2eh,0112ch,0116eh,025ach,04a51h,02e11h,0198fh,00951h
   .word   000cdh,004efh,01170h,02debh,025cfh,00d51h,00133h,0198dh
   .word   04a52h,029cch,01191h,00134h,01dceh,03e4eh,04e73h,04e72h
   .word   021d0h,00d74h,0196dh,0426fh,03a2dh,0260fh,01dd2h,00135h
   .word   01590h,04eb1h,021f1h,00136h,05294h,029f1h,00137h,04e94h
   .word   021f4h,03a32h,01195h,0057bh,0099dh,00158h,04253h,00537h
   .word   0017ah,00579h,04652h,031d2h,0196ch,0152bh,0050eh,031edh
   .word   019d5h,0154ch,000cch,00953h,000aah,0050ch,0017ch,0019eh
   .word   0015bh,0320ch,0019ah,0059fh,0017fh,02e0eh,0019ch,0099fh
   .word   00088h,0059eh,00d9fh,011bfh,0017bh,001beh,021dfh,066ffh
   .word   015dfh,03e6dh,0365fh,06f1fh,0363fh,0529fh,029ffh,00045h
   .word   03a3fh,0119fh,00023h,03e3fh,05affh,0635dh,0673fh,019feh
   .word   02a34h,0321fh,0775fh,0739eh,02dd5h,004abh,05695h,02a55h
   .word   07fffh,077bfh,00155h,00157h,00067h,052b5h,056b5h,02ddeh
   .word   02e1fh,0369dh,019bch,05ad6h,001dbh,05af7h,05ef7h,06318h
   .word   02e56h,052d2h,06317h,05af4h,00935h,056d6h,05ab6h,04eb3h
   .word   015f9h,06739h,05af5h,011d8h,01171h,05f16h,056f6h,056f4h
   .word   01993h,046b5h,03232h,05714h,06337h,05b14h,01591h,03618h
   .word   0429dh,021ddh,056d7h,02df9h,0117ah,03659h,04ad7h,021d6h
   .word   00955h,042b6h,011bbh,0099ah,0265ah,0258fh,04efdh,019dfh
   .word   011deh,04edfh,01dbfh,04a5fh,0361dh,015dch,01dfeh,00d9ah
   .word   042b7h,0099ch,0467fh,07bbfh,07ffeh,05abfh,056dah,00dbdh
   .word   025b3h,0425fh,062dfh,04ed6h,0427bh,03a34h,03eb3h,0153bh
   .word   01a5ch,0263ch,02e3bh,01a1ah,015deh,06b5ah,01dd9h,019d6h
   .word   0529eh,05b15h,05735h,03a1ah,03619h,06b3fh,06f3fh,03ebfh
   .word   021b1h,042f7h,05adeh,0637bh,03633h,02e57h,03a1dh,0573eh
   .word   03e55h,0635ch,06778h,073bdh,052f5h,00d96h,04ef5h,05334h
   .word   0365ah,03e34h,04a79h,00000h,00000h,00000h,00000h,00000h

P_SMCDG:
   .word   62 
   .word   00000h,07ff7h,05a28h,06669h,0770eh,07710h,05e8ch,03d41h
   .word   04583h,03d20h,028c0h,02ce0h,024a0h,01c60h,01440h,055e6h
   .word   051c5h,06248h,06ecbh,04982h,04562h,030e0h,02080h,051a4h
   .word   04983h,06eaah,076ech,0628ch,06e87h,04141h,034e0h,024a0h
   .word   06eefh,03900h,04a08h,06aceh,02ca0h,02880h,04140h,01840h
   .word   01820h,066adh,01800h,01400h,02060h,030c0h,05582h,034e0h
   .word   03900h,041c6h,05e6ah,03984h,01420h,03521h,04e29h,04641h
   .word   01c60h,045e7h,0524ah,068c0h,07180h,04da4h

	.END
