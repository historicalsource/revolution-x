	.MLIB	"GXMACS.LIB"
	.FILE	"GXBGFX.ASM"
	.TITLE	" <<< GENERATION X --- BACKGROUND BLOCK DESTRUCTION >>>"
	.WIDTH	132
	.OPTION	B,D,L
	.MNOLIST

**************************************************************************
* 									 *
* 	COPYRIGHT (C) 1991 WILLIAMS ELECTRONICS GAMES, INC.		 *
* 		       ALL RIGHTS RESERVED.				 *
*								         *
**************************************************************************

	.INCLUDE	"GX.INC"
	.INCLUDE	"IMGTBL.GLO"
	.INCLUDE	"GXBGFX.TBL"
;	.INCLUDE	"GXBGFX.H"

* SYMBOLS IN HERE
	.DEF	PUT_PROCK, PUT_INFINITE_PROCK, PUT_CD, SPRINKLE_POWERUPS
	.DEF	PUT_PROCK_TIMED, PACK_SUPERGUN, PACK_LAZER, PACK_SHIELD

*SYMBOLS IN GX.ASM
	.REF	POWERUP_DURATION

**** from GXPOWER.ASM
	.REF	REVEAL_SUPERGUN, REVEAL_LAZER, REVEAL_SHIELD

* OBJECT VARS FOR ALL BACKGROUND DESTRUCTO OBJECTS
*STRUCT BGFX+OBJ
BGFX_HITS	.EQU	ODATA		;UHW HITS TAKEN BY THIS FHK OBJECT
BGFX_HITSTOKILL	.EQU	ODATA+10H	;UHW HITS REQUIRED TO KILL OBJECT
BGFX_ATE_ROCKET	.EQU	ODATA+20H	;UHB FLAG FOR BG BLOCK TAKING A ROCKET
BGFX_OPENCOUNT	.EQU	ODATA+28H	;UHB TIMES WEAPON CRATE HAS OPENED
BGFX_HIT_INIT	.EQU	ODATA+30H	;UHL INIT TABLE FOR EACH HIT TAKEN
BGFX_EXP_ANIM	.EQU	ODATA+50H	;UHL ANIMATION SCRIPT FOR DESTRUCTION
BGFX_DEPENDENCY	.EQU	ODATA+70H	;UHL DEPENDENCY ROUTINE
BGFX_TEMP	.EQU	ODATA+90H	;UHW TEMP FOR ANYBODY
BGFX_PASTEONS	.EQU	ODATA+0A0H	;UHW HITS SUCCESSFULLY TURNED TO HOLES
BGFX_ANIM	.EQU	ODATA+0B0H	;UHL ANIMATION SCRIPT FOR NORMAL USE
BGFX_FLASH	.EQU	ODATA+0D0H	;UHW FLASH COLOR FOR FlshWyte
*ENDSTRUCT

	.TEXT



**************************************************************************
*								         *
* A_RESET_PACK - RESET PACKAGE TO PUT OUT SOME MORE			 *
* 									 *
* PASS:									 *
* A8 = OBJECT								 *
*								         *
**************************************************************************

A_RESET_PACK
	MOVIM	WEAPC_GV,*A8(OGUNVECT),L
	MOVIM	WEAPC_COLL,*A8(OCVECT),L
	CLR	A14
	MOVE	A14,*A8(BGFX_HITS),W
	JAUC	PULL_ANIM
	
**************************************************************************
*								         *
* PUT_INIFINITE_PROCK - PUT A ROCKET PACK AT A UNIVERSE			 *
*			 POSITION (X, Y, Z) THAT CONTAINS AN INFINITE	 *
* 			 NUMBER OF ROCKETS				 *
* 									 *
* PASS:									 *
* A9  = UNIVERSE Z 							 *
* A10 = UNIVERSE Y							 *
* A11 = UNIVERSE X							 *
* RETURN:								 *
* NUTIN'								 *
*								         *
**************************************************************************

PUT_INFINITE_PROCK
	MMTM	SP,A0,A1,A2,A5
	MOVI	Z_ROCKET,A1
	MOVI	PACKOPENCLOSE_ANIM,A2
	JRUC	PUT_PACK


**************************************************************************
*								         *
* SPRINKLE_POWERUPS - PUT A BUNCH OF ROCKET PACKS ON GROUND WITHIN	 *	 *
*               A UNIVERSE BOX (X, Y, Z)				 *
* 									 *
* PASS:	       								 *
* A8  = Number to drop
* A9  = FARTHEST UNIVERSE Z (Relative to local uni)			 *
* a10 = 0 (X is univ) , 1 (X is world)
* A11 = UNIVERSE X left	: X right					 *
* RETURN:								 *
* NUTIN'								 *
*								         *
**************************************************************************
SPRINKLE_POWERUPS
	move	a10,a10
	jrz	X_is_univ
	move	@XBASE,a14,L
	move	a14,a0
	sra	16,a0
	movx	a0,a14
	addxy	a14,a11		; convert from world to univ
X_is_univ:
	move	@ZREL_OFF,a14,L
	srl	ZFRAC,a14
	add	a14,a9
	move	@YWORLD,a10,L
SPPOWlp:
	mmtm	sp,a8,a9,a11

	move	@ZBASE,a1,L
	addi	7000h,a1	; Z MIN
	move	a9,a0		; Z MAX
	cmp	a0,a1
	jrge	SPPOW_ABT
	calla	RANGRAND
	move	a0,a9

	move	a11,a0
	clr	a1
	movy	a0,a1
	sll	16,a0
	calla	RANGERND
	move	a0,a11

	MOVK	NUM_PACKS,A0
	CALLA	RAND0			;PICK A RANDOM TABLE ENTRY
	SLL	5,A0
	ADDI	PACK_TABLE,A0
	MOVE	*A0,A0,L
	CALL	A0			;DO IT!
SPPOW_ABT:
	mmfm	sp,a8,a9,a11
	dec	a8
	jaz	SUCIDE
; sleep
	sloop	1,SPPOWlp

	.if 0
	.DEF	BUS_POWERUPS

BUS_POWERUPS
	move	@YWORLD,a10,L
BPOWlp:
	movi	8000h,a0
	movi	10000h,a1
	calla	RANGERND
	move	@ZBASE,a9,L
	add	a0,a9		; Z in a9

	movi	450-HALFX,a11	; scrn pos of 450
	mpys	a0,a11
	move	@XBASE,a14,L
	add	a14,a11		; univ X in a11

	MOVK	NUM_PACKS,A0
	CALLA	RAND0			;PICK A RANDOM TABLE ENTRY
	SLL	5,A0
	ADDI	BUS_PACK_TABLE,A0
	MOVE	*A0,A0,L
	CALL	A0			;DO IT!
	MOVE	@XSCROLL,a14,L
	sra	1,a14
	move	a14,*a6(OXVEL),L
BPOW_ABT:

	RANDSLP	60,180
	jruc	BPOWlp


BUS_PACK_TABLE
	.LONG	BUS_PUT_PROCK_TIMED, BUS_PUT_CD_TIMED


BUS_PUT_CD_TIMED:
	MMTM	SP,A0,A1,A2,A5
	MOVI	Z_CD,A1
	jruc	BUS_PUT_TIMED

BUS_PUT_PROCK_TIMED:
	MMTM	SP,A0,A1,A2,A5
	MOVI	Z_ROCKET,A1
BUS_PUT_TIMED:
	MOVI	PACKOPEN_ANIM,A2
	MOVI	PUT_PACK_INIT,A5		; timed
	CALLA	CREATE_OBJ
	JRZ	PP_X
	move	a0,a6			; have it available upon return
	JRUC	PUT_PACK_B

	.endif

NUM_PACKS	.EQU	2
PACK_TABLE
	.LONG	PUT_PROCK_TIMED, PUT_CD_TIMED

	.def PLACE_POWER_TABLE
*
*	Place a bunch of powerups based on a table
*	a4 = table of univ x, y, z's (Z's relative to local universe)
*
PLACE_POWER_TABLE:
	move	*a4+,a7
	move	@ZREL_OFF,a5,L
	sll	ZFRAC,a5
pptlp:
	move	*a4+,a9,L
	move	*a4+,a10,L
	move	*a4+,a11,L
	add	a5,a11			; xlat Z to abs universe
	MOVK	NUM_PACKS,A0
	CALLA	RAND0			;PICK A RANDOM TABLE ENTRY
	SLL	5,A0
	ADDI	PACK_TABLE,A0
	MOVE	*A0,A0,L
	CALL	A0			;DO IT!
	dsjs	a7,pptlp
	rets


**************************************************************************
*								         *
* PUT_PROCK - PUT A ROCKET PACK AT A UNIVERSE POSITION (X, Y, Z)	 *
* 									 *
* PASS:									 *
* A9  = UNIVERSE Z 							 *
* A10 = UNIVERSE Y							 *
* A11 = UNIVERSE X							 *
* RETURN:								 *
* NUTIN'								 *
*								         *
**************************************************************************
PUT_CD_TIMED
	MMTM	SP,A0,A1,A2,A5
	MOVI	Z_CD,A1
	MOVI	PACKOPEN_ANIM,A2
	MOVI	PUT_PACK_INIT,A5		; timed
	JRUC	PUT_PACK_A

PUT_PROCK_TIMED
	MMTM	SP,A0,A1,A2,A5
	MOVI	Z_ROCKET,A1
	MOVI	PACKOPEN_ANIM,A2
	MOVI	PUT_PACK_INIT,A5		; timed
	JRUC	PUT_PACK_A

PUT_CD
	MMTM	SP,A0,A1,A2,A5
	MOVI	Z_CD,A1
	MOVI	PACKOPEN_ANIM,A2
	JRUC	PUT_PACK

PUT_PROCK
	MMTM	SP,A0,A1,A2,A5
	MOVI	Z_ROCKET,A1
	MOVI	PACKOPEN_ANIM,A2
	JRUC	PUT_PACK

*A1 = PACK CONTENTS IDENTIFIER (INDEX INTO WEAPON_CRATE_TAB).
*A2 = PACK ANIMATION
PUT_PACK
	MOVI	PACK_NOANIM_INIT,a5		; not timed
PUT_PACK_A:
	CALLA	CREATE_OBJ
	JRZ	PP_X
PUT_PACK_B:	
	CALLA	CLRODATA			;CLR THE DATA AREA

	MOVE	A1,*A0(BGFX_TEMP),W		;SET TYPE
	MOVE	A2,*A0(BGFX_EXP_ANIM),L
	
	MOVIM	WEAPC_GV,*A0(OGUNVECT),L
	MOVIM	WEAPC_COLL,*A0(OCVECT),L
	MOVIM	01F1FH,*A0(OCONST),W	;Store the constant color for flash

	MOVE	A0,A14
	ADDI	OZVAL+020H,A14
	MMTM	A14,A9,A10,A11			;SET POSITION	
	
	CALLA	INSOBJ
PP_X
	MMFM	SP,A0,A1,A2,A5
	RETS

**************************************************************************
*								         *
* PACK_SBOMB - ROUTINE TO DROP A PACK CONTAINING A SMART BOMB.		 *
* A3 = SIDE FLAG							 *
* 	-1 = FULL SCREEN						 *
* 	0  = PLAYER ONE HALF/THIRD					 *
* 	1  = PLAYER TWO HALF/THIRD					 *
* 	2  = PLAYER THREE THIRD						 *
* A10 = MINIMUM Z OF DROP						 *
* A11 = MAXIMUM Z OF DROP						 *
*								         *
**************************************************************************
PACK_SBOMB
	MMTM	SP,A0,A1,A3,A8
	MOVI	Z_SBOMB,A1
	JRUC	PC_SELPLAY

**************************************************************************
*								         *
* PACK_CD - ROUTINE TO DROP A PACK WITH CD.				 *
* A3 = SIDE FLAG							 *
* 	-1 = FULL SCREEN						 *
* 	0  = PLAYER ONE HALF/THIRD					 *
* 	1  = PLAYER TWO HALF/THIRD					 *
* 	2  = PLAYER THREE THIRD						 *
* A10 = MINIMUM Z OF DROP						 *
* A11 = MAXIMUM Z OF DROP						 *
*								         *
**************************************************************************
PACK_CD
	MMTM	SP,A0,A1,A3,A8
	MOVI	Z_CD,A1
	JRUC	PC_SELPLAY

**************************************************************************
*								         *
* PACK_SUPERGUN - ROUTINE TO DROP A PACK WITH Super Gun.		 *
* A3 = SIDE FLAG							 *
* 	-1 = FULL SCREEN						 *
* 	0  = PLAYER ONE HALF/THIRD					 *
* 	1  = PLAYER TWO HALF/THIRD					 *
* 	2  = PLAYER THREE THIRD						 *
* A10 = MINIMUM Z OF DROP						 *
* A11 = MAXIMUM Z OF DROP						 *
*								         *
**************************************************************************
PACK_SUPERGUN
	MMTM	SP,A0,A1,A3,A8
	MOVI	Z_SUPERGUN,A1
	JRUC	PC_SELPLAY

**************************************************************************
*								         *
* 	PACK_LAZER							 *
* 									 *
* 	Drop a pack containing a Lazer disc.				 *
* 									 *
* 	A3 = Alignment flag						 *
* 		-1 = Full screen					 *
* 		 0 = Player 1's area					 *
* 		 1 = Player 2's area					 *
* 		 2 = Player 3's area					 *
* 	A10 = Minimum Z of drop						 *
* 	A11 = Maximum Z of drop						 *
*								         *
**************************************************************************
PACK_LAZER
	MMTM	SP,A0,A1,A3,A8
	MOVI	Z_LAZER,A1
	JRUC	PC_SELPLAY

**************************************************************************
*								         *
* PACK_SHIELD - ROUTINE TO DROP A PACK WITH Shield.			 *
* A3 = SIDE FLAG							 *
* 	-1 = FULL SCREEN						 *
* 	0  = PLAYER ONE HALF/THIRD					 *
* 	1  = PLAYER TWO HALF/THIRD					 *
* 	2  = PLAYER THREE THIRD						 *
* A10 = MINIMUM Z OF DROP						 *
* A11 = MAXIMUM Z OF DROP						 *
*								         *
**************************************************************************
PACK_SHIELD
	MMTM	SP,A0,A1,A3,A8
	MOVI	Z_SHIELD,A1
	JRUC	PC_SELPLAY

**************************************************************************
*								         *
* PACK_PROCK - ROUTINE TO DROP A PACK WITH ROCKETS.			 *
* A3 = SIDE FLAG							 *
* 	-1 = FULL SCREEN						 *
* 	0  = PLAYER ONE HALF/THIRD					 *
* 	1  = PLAYER TWO HALF/THIRD					 *
* 	2  = PLAYER THREE THIRD						 *
* A10 = MINIMUM Z OF DROP						 *
* A11 = MAXIMUM Z OF DROP						 *
*								         *
**************************************************************************
PACK_PROCK
	MMTM	SP,A0,A1,A3,A8
	MOVI	Z_ROCKET,A1

PC_SELPLAY
	MOVE	A3,A3
	JRN	PC_FULL					;BR=YOUR FULL OF IT
	MOVE	@NPLAYERS,A14,W
	DEC	A3
	JRN	PC_PLAYER_ONE
	JRZ	PC_PLAYER_TWO
	MOVI	[SCRWIDTH-50,SCRWIDTH*2/3+10],A3	;PLAYER 3'S THIRD
	JRUC	PACK_ATTACK
PC_PLAYER_TWO
	MOVI	[SCRWIDTH-50,SCRWIDTH/2+10],A3		;PLAYER 2'S HALF
	SUBK	2,A14
	JRZ	PACK_ATTACK				;BR=2 PLAYER GAME				
	MOVI	[SCRWIDTH*2/3-50,SCRWIDTH/3+10],A3	;PLAYER 2'S THIRD
	JRUC	PACK_ATTACK
PC_PLAYER_ONE
	MOVI	[SCRWIDTH/2-10,50],A3			;PLAYER 1'S HALF
	SUBK	2,A14
	JRZ	PACK_ATTACK				;BR=2 PLAYER GAME				
	MOVI	[SCRWIDTH/3-10,50],A3			;PLAYER 1'S THIRD
	JRUC	PACK_ATTACK
PC_FULL
	MOVI	[SCRWIDTH-50,50],A3			;FUCK IT, DO THE FULL
	JRUC	PACK_ATTACK
	
*A1 = PACK CONTENTS IDENTIFIER (INDEX INTO WEAPON_CRATE_TAB).
*A3 = [X MAX, X MIN] RANGE 
PACK_ATTACK
	MOVI	PACK_INIT,A5
	CALLA	CREATE_OBJ
	JRZ	PA_X
	MOVE	A0,A8
	MOVE	A1,*A8(BGFX_TEMP),W
	ORIM	M_GCOLL,*A8(OFLAGS),W
	MOVIM	7800H,*A8(OYACCEL),W
	MOVIM	01F1FH,*A8(OCONST),W	;Store the constant color for flash

	MOVE	A11,A0
	MOVE	A10,A1
	CALLA	RANGERND
	move	@ZBASE,a14,L
	add	a14,a0
	MOVE	A0,*A8(OZVAL),L		;SET RANDOM Z UNIVERSE

	CLR	A0
	MOVX	A3,A0
	MOVE	A3,A1
	SRL	16,A1
	CALLA	RANGERND		;GET RANDOM SCREEN X
	MOVE	A0,A1
	MOVIY	-20,A1			;SET SCREEN Y
	CALLA	SET_SCRN_POS		;CONVERT TO UNIVERSE
	CALLA	INSERT_OBJ
PA_X
	MMFM	SP,A0,A1,A3,A8
	RETS

**************************************************************************
*								         *
* PACK_GROUND_COLL - COLLISION VECTOR FOR GROUND COLLISION OF WEAPONS	 *
* 			PACK.						 *
* A8 = PTR TO PACK							 *
*								         *
**************************************************************************
PACK_GROUND_COLL
;	SOUND1	PACK_GROUND_SND
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
	MOVE	*A8(BGFX_TEMP),A1,W
	CALLA	CLR_ODATA			;CLR THE DATA AREA
	MOVE	A1,*A8(BGFX_TEMP),W
	MOVIM	PACKOPEN_ANIM,*A8(BGFX_EXP_ANIM),L
	MOVIM	WEAPC_GV,*A8(OGUNVECT),L
	MOVIM	WEAPC_COLL,*A8(OCVECT),L
	CALLA	SET_ONGRND
	JAUC	CLR_VEL

**************************************************************************
*								         *
* A_FlshWyte - ANIM FUNC TO FLASH THE OBJECT TO A CONSTANT COLOR	 *
* A8 = OBJECT								 *
* AARG+,W = OCONST							 *
*								         *
**************************************************************************
;A_FlshWyte
;	CALLA	GETAFARG_WORD
;	MOVE	A0,A1
;	JAUC	FlshWyte

**************************************************************************
*								         *
* WEAPC_GV - WEAPON CRATE GUN VECTOR. 					 *
* 	  REMEBER THAT THE EXPLOSION ANIM MUST DELETE THE OBJECT OR	 *
* 	  CLEAR BNODEL SO THAT THE BACKGROUND PROCESSOR WILL DELETE IT.	 *
* A2 = PTR TO PLAYER SHOOTING THIS BLOCK				 *
* A8 = PTR TO BLOCK							 *
* A8(BGFX_HITSTOKILL),W = NUMBER OF HITS TO CALL THIS OBJECT DEAD	 *
* A8(BGFX_HIT_INIT),L = INIT TABLE FOR DAMAGE, 0 = NONE			 *
* A8(BGFX_EXP_ANIM),L = ANIMATION SCRIPT FOR DESTRUCTION		 *
*								         *
**************************************************************************
WEAPC_GV
	MOVE	*A8(BGFX_HITS),A14,W
	JRNZ	WGV_XXX
	INC	A14
	MOVE	A14,*A8(BGFX_HITS),W
	PUSH	A1
	MOVE	*A8(BGFX_EXP_ANIM),A1,L
	CLRM	*A8(OPLINK),L		;CLEAR BACKGROUND BLOCK FLAG JUNK
	MOVE	A2,*A8(OPLAYER),L
	CALLA	A_DEL_OID_DAMAGE
	CALLA	OBJ_ON_WNZ		;Make sure we are normal
	CALLA	STRT_ANIM		;MAKE IT GO UP IN SMOKE
	PULL	A1
WGV_XXX
	RETS

WEAPC_COLL:
;*****	WWL PATTERN,[MASK],FUNC
	WWL	OID_PROCKET,~MASK_PLAYER,WALLB_RCOLL
	WWL	OID_PEXPLOSION,~MASK_PLAYER,WEAPC_EXP_COLL
	WL	0,DUMCRETS

**************************************************************************
*								         *
* WALLB_RCOLL - WALL BLOCK ROCKET COLLISION.				 *
* A8 = PTR TO WALL BLOCK						 *
*								         *
**************************************************************************
WALLB_RCOLL
	MOVKB	1,*A8(BGFX_ATE_ROCKET)
	RETS

**************************************************************************
*								         *
* WEAPC_EXP_COLL - WEAPON CRATE EXPLOSION COLLISION.			 *
* A0 = PTR TO EXPLOSION							 *
* A8 = PTR TO WEAPON CRATE						 *
*								         *
**************************************************************************
WEAPC_EXP_COLL
	MOVB	*A8(BGFX_ATE_ROCKET),A14	;DID HE CHEW ON THE ROCKET?
	JRNZ	WEPC_DO				;BR = YES
	RETS
WEPC_DO
	MOVE	*A8(BGFX_HITS),A14,W		;IS IT OPEN?
	JRNZ	WEPC_X				;BR = YES
	INC	A14
	MOVE	A14,*A8(BGFX_HITS),W
	CLRM	*A8(OPLINK),L		;CLEAR BACKGROUND BLOCK FLAG JUNK
	MOVE	*A0(OPLAYER),*A8(OPLAYER),L
	MOVE	*A8(BGFX_EXP_ANIM),A1,L
	CALLA	A_DEL_OID_DAMAGE
	CALLA	OBJ_ON_WNZ		;Make sure we are normal
	CALLA	STRT_ANIM		;MAKE IT GO UP IN SMOKE
WEPC_X
	RETS

**************************************************************************
*								         *
* A_PACK_OPEN - ANIM FUNC TO REVEAL WHAT IS CONTAINED IN THE		 *
* 		WEAPONS PACK.  THIS IS DETERMINED BY WHAT		 *
* 		IS STORED IN BGFX_TEMP.					 *
* 		SEE Z_xxxx EQUATES ABOVE WEAPON_CRATE_TAB.		 *
* A8 = PTR TO PACK							 *
*								         *
**************************************************************************
A_PACK_OPEN
	MOVE	*A8(BGFX_TEMP),A6,W
	CMPK	NUM_Z_POWER,A6		;BOOTY NUMBER IN RANGE?
	JRLS	APO_OK			;BR = YES
;	MOVI	Z_CLIP,A6		;REVERT TO CLIPS
APO_OK
	SLL	5,A6
	JRUC	AGIU_G

**************************************************************************
*								         *
* A_GIVE_IT_UP - ANIM FUNC TO PLACE A POWER UP IN A WEAPONS CRATE.	 *
* 		POWER TABLE IS DETERMINED FROM THE LOW FOUR		 *
* 		BITS OF THE INTEGER PART OF THE ZVAL.			 *
* 		IT WILL LOAD AnimSLP WITH POWER_DURATION/4		 *
* A8 = PTR TO WEAPONS CRATE						 *
*								         *
**************************************************************************
A_GIVE_IT_UP
	MOVE	*A8(OZPOS),A6,W
	SLL	28,A6
	SRL	23,A6
*A6 = WEAPON TYPE OFFSET
AGIU_G
	ADDI	WEAPON_CRATE_TAB,A6
	MOVE	*A6,A6,L
	MOVE	*A6+,A0,W
	CALLA	RAND0
	SLL	5,A0
	ADD	A0,A6
	MOVE	*A6,A6,L
	MOVI	PID_IND,A1
AGIU_LP
	MOVE	*A6+,A7,L
	JRZ	AGIU_POWER_DONE
	MOVE	*A6+,A10,L
	MOVK	1,A11
	CALLA	GETPRC
	JRNZ	AGIU_LP
AGIU_POWER_DONE	
	MOVE	@POWERUP_DURATION,A14,W	;DURATION MUST NOT EXCEED 3F0H
	ADDK	16,A14
	SRL	2,A14
	JRNZ	AGIU_DUR_OK
	MOVK	1,A14
AGIU_DUR_OK
	MOVB	A14,*A8(AnimSLP)
	RETS


*
* WEAPON FLAG TYPES
*

NUM_Z_POWER	.EQU	5

Z_SBOMB		.EQU	0
Z_ROCKET	.EQU	1
Z_CD		.EQU	2
Z_SUPERGUN	.EQU	3
Z_LAZER		.EQU	4
Z_SHIELD	.EQU	5

*
*TABLE TO GET CORRECT WEAPONS LIST FOR A GIVEN CRATE
*
WEAPON_CRATE_TAB
	.LONG	WEAP_SBOMB,WEAP_ROCKS,WEAP_CD,WEAP_SUPERGUN,WEAP_LAZER
	.LONG	WEAP_SHIELD

*
*TABLES FOR WEAPON CRATE CONTENTS:
*	.WORD	NUMBER OF WEAPONS
*	.LONG	WEAPON1, ..., WEAPONn

*SMART BOMB CRATE
WEAP_SBOMB
	.WORD	1
	.LONG	POWER_SBOMB
*ROCKET CRATE
WEAP_ROCKS
	.WORD	1
	.LONG	POWER_ROCKS
*CD CRATE
WEAP_CD
	.WORD	1
	.LONG	POWER_CD
*
* Supergun Crate
*
WEAP_SUPERGUN
	.WORD	1
	.LONG	POWER_SUPERGUN
*
* Lazer disk Crate
*
WEAP_LAZER
	.WORD	1
	.LONG	POWER_LAZER
*
* Shield Crate
*
WEAP_SHIELD
	.WORD	1
	.LONG	POWER_SHIELD

*
*TABLES FOR WEAPON CRATE POWER UP PLACEMENT:
*	.LONG	POWERUP1, [Y,X]
*		.
*	.LONG	POWERUPn, [Y,X]
*	.LONG	0

POWER_SBOMB
	.LONG	REVEAL_SBOMB,[21-40,25-25]
	.LONG	0
POWER_ROCKS
	.LONG	REVEAL_PROCK,[28-40,16-25]
	.LONG	REVEAL_PROCK,[28-40,35-25]
	.LONG	REVEAL_PROCK,[15-40,16-25]
	.LONG	REVEAL_PROCK,[15-40,35-25]
	.LONG	0
POWER_CD
	.LONG	REVEAL_CD,[21-40,24-25]
	.LONG	0

POWER_SUPERGUN
	.LONG	REVEAL_SUPERGUN,[21-40,24-25]
	.LONG	0

POWER_LAZER
	.LONG	REVEAL_LAZER,[21-40,24-25]
	.LONG	0

POWER_SHIELD
	.LONG	REVEAL_SHIELD,[21-40,24-25]
	.LONG	0


**************************************************************************
*								         *
* 	 DATA SECTION FOR DA "PACKAGE" AS IN "NICE PACKAGE"		 *
*								         *
**************************************************************************
	.DATA

PUT_PACK_INIT
	.LONG	WEPBOX1,PACK_COLL
	.WORD	OID_JUNK,DMAWNZ,0,0
	.LONG	C_STRTANIM,PUT_PACK_ANIM

PUT_PACK_ANIM
	LW	1,100
	LW	1,100
	LWLL	1,100|AFunc,A_AnimGo+2,PACK_TIME_LP
	

*
*WEAPONS PACK THAT DROPS IN
*
PACK_INIT
	.LONG	WEPBOX1,PACK_COLL
	.WORD	OID_JUNK,DMAWNZ,0,0
	.LONG	C_STRTANIM,PACK_TIME_ANIM

PACK_NOANIM_INIT
	.LONG	WEPBOX1,PACK_COLL
	.WORD	OID_JUNK,DMAWNZ,0,0
	.LONG	0

;*****	WWL PATTERN,[MASK],FUNC
PACK_COLL
	WWL	OID_GRND,0FFFFH,PACK_GROUND_COLL
	WL	0,DUMCRETS

*
*ANIMATION TO TIME THE GRANTED WEAPONS PACK
*
PACK_TIME_ANIM
	LWLL	1,100|AFunc,A_SOUND+2,SND_WEAPC_DROP
	LW	1,100
	LW	1,100
PACK_TIME_LP
	LWL	1,1|AFunc,FlshWyte
	LW	1,3
	LWL	1,1|AFunc,FlshWyte
	LW	1,3
	LWL	1,1|AFunc,FlshWyte
	LW	1,3
	LWL	1,1|AFunc,FlshWyte
	LW	1,3
	LWL	1,1|AFunc,FlshWyte
	LW	1,3
	LWL	1,1|AFunc,FlshWyte
	LW	1,3
	LWL	1,1|AFunc,FlshWyte
	LW	1,3
	LWL	1,1|AFunc,FlshWyte
	LW	1,3
	LWL	1,1|AFunc,FlshWyte
	LW	1,30
	LWL	1,1|AFunc,DELETE_OBJ

PACKOPEN_ANIM
;	LWLL	WEPBOX2,2|AFunc,A_PLAYER_SND+2,WEAPC_OPEN_SND_TAB
	LWLL	WEPBOX3,4|AFunc,A_SOUND+2,SND_WEAPC_OPEN
;	LW	WEPBOX3,2
;	LW	WEPBOX4,2
	LW	WEPBOX5,4
	LWL	1,1|AFunc,A_PACK_OPEN
	LW	1,0
	LW	1,0
	LW	1,0
	LWL	1,1|AFunc,DELETE_OBJ

PACKOPENCLOSE_ANIM
;	LWLL	WEPBOX2,2|AFunc,A_PLAYER_SND+2,WEAPC_OPEN_SND_TAB
	LWLL	WEPBOX3,4|AFunc,A_SOUND+2,SND_WEAPC_OPEN
;	LW	WEPBOX3,2
;	LW	WEPBOX4,2
	LW	WEPBOX5,4
	LWL	1,1|AFunc,A_PACK_OPEN
	LW	1,0
	LW	1,0
	LW	1,0
	LW	1,0
	LW	1,0
;	LW	WEPBOX4,2
	LW	WEPBOX3,4
;	LW	WEPBOX2,2
	LWL	WEPBOX1,1|AFunc,A_RESET_PACK

**************************************************************************
*								         *
* 		SOUND EFFECTS FOR ALL BG BLOCKS				 *
*								         *
**************************************************************************
SND_WEAPC_OPEN
	.WORD	0F230H,17,0A337H,0		;Shooting open a weapons crate
SND_WEAPC_DROP
	.WORD	0F230H,38,0A334H,0		;weapons crate dropping in

;PACK_GROUND_SND
;	.WORD	0F010H,8,0804AH,0		;PACK HITS GROUND
	.END
