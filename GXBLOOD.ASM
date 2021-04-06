 	.MLIB	"GXMACS.LIB"
	.FILE	"GXBLOOD.ASM"
	.TITLE	"<<< GENERATION X -- Bloody stuff >>>"
	.WIDTH	132
	.OPTION	B,D,L,T
	.MNOLIST

**************************************************************************
*								         *
* 	COPYRIGHT (C) 1994 MIDWAY MANUFACTURING COMPANY.		 *
* 		       ALL RIGHTS RESERVED.				 *
*								         *
**************************************************************************

*	GET THE SYSTEM STUFF
	.INCLUDE	"GX.INC"
	.INCLUDE	"IMGTBL.GLO"
	.INCLUDE	"GXBLOOD.TBL"

***** In this file
	.DEF	BLOODY_BULLET_HIT, A_BLOOD_SPLORCH, A_SBOMB_BLOOD
	.DEF	GOOEY_BULLET_HIT, FRAG_GOOEY_SPLORCH, P_BLOODGR
	.DEF	BIGBOY_ROCKET_BLOOD, SMALL_BLOOD_HIT, BLOODY_BULLET_HIT_OFFSET
	.DEF	BLOODY_BULLET_HIT_ALWAYS

***** from GXMONDR2.ASM
	.REF	A_CHUNK_ONSCREEN, F_BLOOD_GLOB

***** from GXPALL.ASM
	.REF	CHANGE_PAL_CHECK

***** from GXUTIL.ASM
	.REF	PASTE_ON_DAMAGE_OFFSET,PASTE_ON_DAMAGE_OFFSET_XYZ

***** from GXRAM.ASM
	.REF	VIOLENCE_LEVEL

	.TEXT


**************************************************************************
*								         *
* 	A_SBOMB_BLOOD							 *
* 									 *
* 	Anim func to fire off a smart bomb blood from the center	 *
* 	of a given object.						 *
* 									 *
* 	AARG+,L = 16.16 Z Absolute Max Velocity				 *
* 	AARG+,L = 16.16 X and Y Absolute Max Velocity			 *
*								         *
**************************************************************************
A_SBOMB_BLOOD
	MOVE	@VIOLENCE_LEVEL,A14,W
	JRZ	ASB_X

	DEC	A14
	JRNZ	ASB_BLOODNESS

	MOVI	FRAG_SBOMB_GOO,A1
	JRUC	AB_G

ASB_BLOODNESS
	MOVI	FRAG_SBOMB_BLOOD,A1
	JRUC	AB_G

ASB_X
	RETS
**************************************************************************
*								         *
* 	A_BLOOD_SPLORCH							 *
* 									 *
* 	Anim func to fire off a blood splorch from the center		 *
* 	of a given object.						 *
* 									 *
* 	AARG+,L = 16.16 Z Absolute Max Velocity				 *
* 	AARG+,L = 16.16 X and Y Absolute Max Velocity			 *
*								         *
**************************************************************************
A_BLOOD_SPLORCH
	MOVE	@VIOLENCE_LEVEL,A14,W
	JRZ	ABS_SOUND_ONLY

	DEC	A14
	JRNZ	ABS_BLOOD

	MOVI	FRAG_GOOEY_SPLORCH,A1
	JRUC	AB_G

ABS_BLOOD	
	MOVI	FRAG_BLOOD_SPLORCH,A1

AB_G
	CALLA	GETAFARG_LONG		;Get the Z velocity
	MOVE	A0,A3			;Pass it here
	CALLA	GETAFARG_LONG		;Get the X and Y velocity
	CALLA	PreFrag_Center		;BLOW RANDOMLY OUT OR UP
	MOVE	A1,B14			;Right place at the right time
	CALLA	Fragger			;And get it goin' Boy
	MOVE	A8,*A0(FPDATA),L	;Pass pointer to parent
	RETS

ABS_SOUND_ONLY
	SOUND1	SND_SPLORCH_EXPLODE
	RETS

**************************************************************************
*								         *
* BIGBOY_ROCKET_BLOOD							 *
*								         *
**************************************************************************

BIGBOY_ROCKET_BLOOD
	MMTM	SP,A0,A1,A2,A3,A5,A8,A9
	MMTM	SP,B0,B1

	MOVE	@VIOLENCE_LEVEL,B1,W
	JRZ	BRB_DONE

	DEC	B1

	CALLA	GET_HEAD_PART
	MOVE	*A8(OXVAL),A5,L
	MOVE	*A8(OYVAL),A9,L
	SUBI	0100000H,A9
	
	MOVE	@CPUAVG,A2,W
	SUBI	200,A2
	MOVE	@DMAAVG,A3,W
	SUBI	200,A3

	MOVE	*A8(OCTRL),A1,W
	BTST	B_FLIPH,A1
	JRZ	BRB_BLOOD			;BR=MUST MAKE

	MOVE	A2,A2
	JRN	BRB_CHECK_BLOOD_F		;BR = CPU is hurting

	MOVE	A3,A3
	JRN	BRB_CHECK_BLOOD_F		;BR = DMA is hurting

	MOVE	@RAND,A0,W
	BTST	1,A0
	JRZ	BRB_CHECK_BLOOD_F		;BR=NO CHANCE
BRB_BLOOD
	MOVE	B1,B1
	JRNZ	BRB_BLOOD_IT_IS
	MOVI	INIT_GOOEY_SPLORCH,B0
	JRUC	BRB_PASTE_IT
BRB_BLOOD_IT_IS
	MOVI	INIT_BLOOD_SPLORCH,B0
BRB_PASTE_IT
	CALLA	PASTE_ON_DAMAGE_OFFSET_XYZ
BRB_CHECK_BLOOD_F
	BTST	B_FLIPH,A1
	JRNZ	BRB_BLOOD_F			;BR=MUST MAKE

	MOVE	A2,A2
	JRN	BRB_DONE			;BR = CPU is hurting

	MOVE	A3,A3
	JRN	BRB_DONE			;BR = DMA is hurting

	BTST	2,A0
	JRZ	BRB_DONE			;BR=NO CHANCE
BRB_BLOOD_F
	MOVE	B1,B1
	JRNZ	BRB_BLOOD_IT_IS_F
	MOVI	INIT_GOOEY_SPLORCH_F,B0
	JRUC	BRB_PASTE_IT_F
BRB_BLOOD_IT_IS_F
	MOVI	INIT_BLOOD_SPLORCH_F,B0
BRB_PASTE_IT_F
	CALLA	PASTE_ON_DAMAGE_OFFSET_XYZ
BRB_DONE
	MMFM	SP,B0,B1
	MMFM	SP,A0,A1,A2,A3,A5,A8,A9
	RETS

INIT_BLOOD_SPLORCH
	.LONG	SPLORCH2
	.WORD	DMAWNZ, M_DEAD|M_NOPARTANI, OM_ANIM
	.LONG	CHUNK_SPLORCH_NODROPS

INIT_BLOOD_SPLORCH_F
	.LONG	SPLORCH2
	.WORD	DMAWNZ|M_FLIPH, M_DEAD|M_NOPARTANI, OM_ANIM
	.LONG	CHUNK_SPLORCH_NODROPS

INIT_GOOEY_SPLORCH
	.LONG	SPLORCH2
	.WORD	DMAWNZ, M_DEAD|M_NOPARTANI, OM_ANIM | OM_CFUNC
	.LONG	CHUNK_SPLORCH_NODROPS
	.LONG	C_CHANGEPAL, P_BLOODGR

INIT_GOOEY_SPLORCH_F
	.LONG	SPLORCH2
	.WORD	DMAWNZ|M_FLIPH, M_DEAD|M_NOPARTANI, OM_ANIM | OM_CFUNC
	.LONG	CHUNK_SPLORCH_NODROPS
	.LONG	C_CHANGEPAL, P_BLOODGR

**************************************************************************
*								         *
* 	BLOODY_BULLET_HIT						 *
* 									 *
* 	Paste on a bloody bullet hit.					 *
* 									 *
* 	A2 = Ptr to player shooting					 *
* 	A8 = Object to paste onto					 *
*								         *
**************************************************************************
BLOODY_BULLET_HIT
	MOVE	@VIOLENCE_LEVEL,A14,W
	JRZ	BBH_XXX

	DEC	A14
	JRZ	GOOEY_BULLET_HIT
*
* Entrypoint: Does no checking for Violence level
*
BLOODY_BULLET_HIT_ALWAYS
	PUSH	A0
	PUSH	B0

	MOVI	INIT_BLOOD_SPLAT,B0
	CALLA	PASTE_ON_DAMAGE

	MOVE	@CPUAVG,A14,W
	CMPI	200,A14
	JRLE	BBH_X				;BR = CPU is hurting

	MOVE	@DMAAVG,A14,W
	CMPI	200,A14
	JRLE	BBH_X				;BR = DMA is hurting

	MOVE	@RAND,A0,W
	SRL	3,A0
	JRNC	BBH_NXT2

	MOVI	INIT_BLOOD_SPLAT_R,B0
	CALLA	PASTE_ON_DAMAGE
BBH_NXT2
	SRL	3,A0
	JRNC	BBH_X

	MOVI	INIT_BLOOD_SPLAT_L,B0
	CALLA	PASTE_ON_DAMAGE
BBH_X
	PULLQ	B0
	PULLQ	A0
BBH_XXX
	RETS

**************************************************************************
*								         *
* 	BLOODY_BULLET_HIT_OFFSET					 *
* 									 *
* 	Paste on a bloody bullet hit.					 *
* 									 *
* 	A2 = Ptr to player shooting					 *
* 	A8 = Object to paste onto					 *
*								         *
**************************************************************************
BLOODY_BULLET_HIT_OFFSET
	MOVE	@VIOLENCE_LEVEL,A14,W
	JRZ	BBHO_XXX

	DEC	A14
	JRZ	GOOEY_BULLET_HIT_OFFSET

	PUSH	A0
	PUSH	B0

	MOVI	INIT_BLOOD_SPLAT,B0
	CALLA	PASTE_ON_DAMAGE_OFFSET

	MOVE	@CPUAVG,A14,W
	CMPI	200,A14
	JRLE	BBHO_X				;BR = CPU is hurting

	MOVE	@DMAAVG,A14,W
	CMPI	200,A14
	JRLE	BBHO_X				;BR = DMA is hurting

	MOVE	@RAND,A0,W
	SRL	3,A0
	JRNC	BBHO_NXT2

	MOVI	INIT_BLOOD_SPLAT_R,B0
	CALLA	PASTE_ON_DAMAGE_OFFSET
BBHO_NXT2
	SRL	3,A0
	JRNC	BBHO_X

	MOVI	INIT_BLOOD_SPLAT_L,B0
	CALLA	PASTE_ON_DAMAGE_OFFSET
BBHO_X
	PULLQ	B0
	PULLQ	A0
BBHO_XXX
	RETS

**************************************************************************
*								         *
* 	SMALL_BLOOD_HIT							 *
* 									 *
* 	Paste on a small bloody bullet hit.				 *
* 									 *
* 	A2 = Ptr to player shooting					 *
* 	A8 = Object to paste onto					 *
*								         *
**************************************************************************
SMALL_BLOOD_HIT
	MOVE	@VIOLENCE_LEVEL,A14,W
	JRZ	SBH_XXX

	DEC	A14
	JRZ	SMALL_GOOEY_HIT

	PUSH	A0
	PUSH	B0

	MOVI	INIT_BLOOD_SPLAT,B0
	CALLA	PASTE_ON_DAMAGE

	PULLQ	B0
	PULLQ	A0
SBH_XXX
	RETS

**************************************************************************
*								         *
* 	GOOEY_BULLET_HIT						 *
* 									 *
* 	Paste on a green gooey bullet hit.				 *
* 									 *
* 	A2 = Ptr to player shooting					 *
* 	A8 = Object to paste onto					 *
*								         *
**************************************************************************
GOOEY_BULLET_HIT
	MOVE	@VIOLENCE_LEVEL,A14,W
	JRZ	GBH_XXX

	PUSH	A0
	PUSH	B0

	MOVI	INIT_GOOEY_SPLAT,B0
	CALLA	PASTE_ON_DAMAGE

	MOVE	@CPUAVG,A14,W
	CMPI	200,A14
	JRLE	GBH_X				;BR = CPU is hurting

	MOVE	@DMAAVG,A14,W
	CMPI	200,A14
	JRLE	GBH_X				;BR = DMA is hurting

	MOVE	@RAND,A0,W
	SRL	3,A0
	JRNC	GBH_NXT2

	MOVI	INIT_GOOEY_SPLAT_R,B0
	CALLA	PASTE_ON_DAMAGE
GBH_NXT2
	SRL	3,A0
	JRNC	GBH_X

	MOVI	INIT_GOOEY_SPLAT_L,B0
	CALLA	PASTE_ON_DAMAGE
GBH_X
	PULLQ	B0
	PULLQ	A0
GBH_XXX
	RETS

**************************************************************************
*								         *
* 	GOOEY_BULLET_HIT_OFFSET						 *
* 									 *
* 	Paste on a green gooey bullet hit.				 *
* 									 *
* 	A2 = Ptr to player shooting					 *
* 	A8 = Object to paste onto					 *
*								         *
**************************************************************************
GOOEY_BULLET_HIT_OFFSET
	MOVE	@VIOLENCE_LEVEL,A14,W
	JRZ	GBHO_XXX

	PUSH	A0
	PUSH	B0

	MOVI	INIT_GOOEY_SPLAT,B0
	CALLA	PASTE_ON_DAMAGE_OFFSET

	MOVE	@CPUAVG,A14,W
	CMPI	200,A14
	JRLE	GBHO_X				;BR = CPU is hurting

	MOVE	@DMAAVG,A14,W
	CMPI	200,A14
	JRLE	GBHO_X				;BR = DMA is hurting

	MOVE	@RAND,A0,W
	SRL	3,A0
	JRNC	GBHO_NXT2

	MOVI	INIT_GOOEY_SPLAT_R,B0
	CALLA	PASTE_ON_DAMAGE_OFFSET
GBHO_NXT2
	SRL	3,A0
	JRNC	GBHO_X

	MOVI	INIT_GOOEY_SPLAT_L,B0
	CALLA	PASTE_ON_DAMAGE_OFFSET
GBHO_X
	PULLQ	B0
	PULLQ	A0
GBHO_XXX
	RETS

**************************************************************************
*								         *
* 	SMALL_GOOEY_HIT							 *
* 									 *
* 	Paste on a small gooey bullet hit.				 *
* 									 *
* 	A2 = Ptr to player shooting					 *
* 	A8 = Object to paste onto					 *
*								         *
**************************************************************************
SMALL_GOOEY_HIT
	MOVE	@VIOLENCE_LEVEL,A14,W
	JRZ	SGH_XXX

	PUSH	A0
	PUSH	B0

	MOVI	INIT_GOOEY_SPLAT,B0
	CALLA	PASTE_ON_DAMAGE

	PULLQ	B0
	PULLQ	A0
SGH_XXX
	RETS

*
* Initialization for bullet hit blood splat
*
INIT_BLOOD_SPLAT
	.LONG	FIRSTBLO1
	.WORD	DMAWNZ, M_DEAD|M_NOPARTANI, OM_ANIM|OM_CFUNC
	.LONG	BSPLAT_ANIM
	.LONG	C_RANDFLIP

INIT_GOOEY_SPLAT
	.LONG	FIRSTBLO1
	.WORD	DMAWNZ, M_DEAD|M_NOPARTANI, OM_ANIM|OM_CFUNC
	.LONG	GSPLAT_ANIM
	.LONG	C_RF_CP, P_BLOODGR


**************************************************************************
*								         *
* 	C_RANDFLIP							 *
* 									 *
* 	Create func to randomly flip an object				 *
* 									 *
* 	A0 = Ptr to un-inserted object					 *
*								         *
**************************************************************************
C_RANDFLIP
	PUSH	A8
	MOVE	A0,A8
	MOVE	@RAND,A0,W
	ANDI	M_FLIPH|M_FLIPV,A0		;ISOLATE FLIP BITS ONLY
	CALLA	SET_FLIP
	MOVE	A8,A0
	PULLQ	A8
	RETS

BSPLAT_ANIM
	LW	FIRSTBLO1,4
	LWLLLL	FIRSTBLO2,4|AFunc,A_PreFrag_Box+6,FRAG_BLOOD_SM,0h,20000h
	LW	FIRSTBLO3,4
	LWL	1,1|AFunc,DELETE_OBJ

GSPLAT_ANIM
	LW	FIRSTBLO1,4
	LWLLLL	FIRSTBLO2,4|AFunc,A_PreFrag_Box+6,FRAG_GOO_SM,0h,20000h
	LW	FIRSTBLO3,4
	LWL	1,1|AFunc,DELETE_OBJ

INIT_BLOOD_SPLAT_R
	.LONG	BULLETBLO1
	.WORD	DMAWNZ, M_DEAD|M_NOPARTANI, OM_ANIM
	.LONG	BSPLAT_SPRAY_ANIM

INIT_BLOOD_SPLAT_L
	.LONG	BULLETBLO1
	.WORD	DMAWNZ|M_FLIPH, M_DEAD|M_NOPARTANI, OM_ANIM
	.LONG	BSPLAT_SPRAY_ANIM

INIT_GOOEY_SPLAT_R
	.LONG	BULLETBLO1
	.WORD	DMAWNZ, M_DEAD|M_NOPARTANI, OM_ANIM|OM_CFUNC
	.LONG	GSPLAT_SPRAY_ANIM
	.LONG	C_CHANGEPAL,P_BLOODGR

INIT_GOOEY_SPLAT_L
	.LONG	BULLETBLO1
	.WORD	DMAWNZ|M_FLIPH, M_DEAD|M_NOPARTANI, OM_ANIM|OM_CFUNC
	.LONG	GSPLAT_SPRAY_ANIM
	.LONG	C_CHANGEPAL,P_BLOODGR

**************************************************************************
*								         *
* 	C_RF_CP								 *
* 									 *
* 	Create func calls C_RANDFLIP then C_CHANGEPAL			 *
*								         *
**************************************************************************
C_RF_CP
	CALLR	C_RANDFLIP
	JRUC	C_CHANGEPAL

**************************************************************************
*								         *
* 	C_CHANGEPAL							 *
* 									 *
* 	Create func to change a palette					 *
* 									 *
* 	A0 = Ptr to un-inserted object					 *
* 	*B0+,L = New palette						 *
*								         *
**************************************************************************
C_CHANGEPAL
	PUSH	A8
	MOVE	A0,A8
	MOVE	*B0+,B14,L
	MOVE	B14,A0
	CALLA	CHANGE_PAL
	PULLQ	A8
	RETS


BSPLAT_SPRAY_ANIM
	LW	1,4
	LW	BULLETBLO2,4
	LWLLLL	BULLETBLO3,4|AFunc,A_PreFrag_Box+6,FRAG_BLOOD_SM,0h,20000h
	LW	BULLETBLO4B,4
	LW	BULLETBLO5B,4
	LWL	1,1|AFunc,DELETE_OBJ

GSPLAT_SPRAY_ANIM
	LW	1,4
	LW	BULLETBLO2,4
	LWLLLL	BULLETBLO3,4|AFunc,A_PreFrag_Box+6,FRAG_GOO_SM,0h,20000h
	LW	BULLETBLO4B,4
	LW	BULLETBLO5B,4
	LWL	1,1|AFunc,DELETE_OBJ


FRAG_BLOOD_SM
	.long	CHUNK_BLOOD_SM,F_DIR_BLOOD
	.word	OID_JUNK,2*800H+6*40H+FRGPAL+FRGNOFLP+FRGGCOL+FRGRND+FRGBOG

	.LONG	0

FRAG_GOO_SM
	.long	CHUNK_BLOOD_SM,F_DIR_GOO
	.word	OID_JUNK,2*800H+6*40H+FRGPAL+FRGNOFLP+FRGGCOL+FRGRND+FRGBOG

	.LONG	0


**************************************************************************
*								         *
* 	F_DIR_GOO							 *
* 									 *
* 	Frag func for goo that is supposed to travel in a		 *
* 	direction matching the flip of the spawner.			 *
* 									 *
* 	A0 = Ptr to un-inserted object					 *
*								         *
**************************************************************************
F_DIR_GOO
	CALLR	F_GOOEY_PAL
	JRUC	F_DIR_BLOOD

*
* Do it double scale
*
F_DIR_GOO_X2
	CALLR	F_GOOEY_PAL
	JRUC	F_DIR_BLOOD_X2

**************************************************************************
*								         *
* 	F_DIR_BLOOD							 *
* 									 *
* 	Frag func for blood that is supposed to travel in a		 *
* 	direction matching the flip of the spawning object.		 *
* 									 *
* 	A0 = Ptr to un-inserted object					 *
*								         *
**************************************************************************
*
* Do it double scale
*
F_DIR_BLOOD_X2
	ORIM	M_DBLSCL,*A0(OFLAGS),W
F_DIR_BLOOD
	MOVE	*A0(OXVEL),A2,L
	ABS	A2

	MOVE	*A0(OYVEL+16),A14,W
	ABS	A14
	MOVE	A14,A14
	JRNZ	FDB_NO_DROP

	CMPI	18000H,A2
	JRLT	FDB_NO_DROP

	MOVI	CHUNK_BLOOD_DIR,A1
	CALLA	STRTANIM

	JRUC	FDB_SKIP_YADD

FDB_NO_DROP
	SUBIM	10000H,*A0(OYVEL),L

FDB_SKIP_YADD
	MOVE	*A13(FPDATA),A1,L

	PUSH	A8

	MOVE	A0,A8

	MOVE	*A1(OCTRL),A14,W
	BTST	B_FLIPH,A14    		;Set X vel according to flip
	JRZ	FDB_SETXVEL

	MOVI	M_FLIPH,A0
	CALLA	TOGGLE_FLIP
	NEG	A2
FDB_SETXVEL
	MOVE	A2,*A0(OXVEL),L

	MOVE	A8,A0
	PULLQ	A8

	JAUC	F_BLOOD_GLOB

*
* Spawing blood drops
*
CHUNK_BLOOD_SM
	LW	LILBLOOD1,3
	LW	LILBLOOD2,3
	LW	LILBLOOD3,3
	LW	LILBLOOD4,3
	LW	LILBLOOD5,3
	LWLL	1,1|AFunc,A_CHUNK_ONSCREEN+2,CHUNK_BLOOD_SM
	LWL	1,1|AFunc,DELETE_OBJ

CHUNK_BLOOD_DIR
	LW	DIRDROPSM5,4
	LW	DIRDROPSM6,4
	LW	DIRDROPSM7,4
	LW	DIRDROPSM8,4
CHUNK_BD_LOOP
	LWLL	1,1|AFunc,A_CHUNK_ONSCREEN+2,CHUNK_BD_LOOP
	LWL	1,1|AFunc,DELETE_OBJ


*
* Create the big blood hit for body parts
*
FRAG_BLOOD_SPLORCH
	.long	CHUNK_SPLORCH,F_CLRVEL
	.word	OID_JUNK,1*800H+0*40H+FRGPAL+FRGNOFLP+FRGNOFLY

	.long	CHUNK_SPLORCH,F_FLIPH_CLRVEL
	.word	OID_JUNK,1*800H+1*40H+FRGPAL+FRGNOFLP+FRGNOFLY

	.LONG	0


*
* Create the big gooey splorch for exposion
*
FRAG_GOOEY_SPLORCH
	.long	CHUNK_GSPLORCH,F_GOOEY_CLRVEL
	.word	OID_JUNK,1*800H+0*40H+FRGPAL+FRGNOFLP+FRGNOFLY

	.long	CHUNK_GSPLORCH,F_GOOEY_FLIPH_CLRVEL
	.word	OID_JUNK,1*800H+1*40H+FRGPAL+FRGNOFLP+FRGNOFLY

	.LONG	0

**************************************************************************
*								         *
* 	A_EXPLODE_SPLORCH_SND						 *
* 									 *
* 	Anim func to make the sound for the exploding splorch.		 *
*								         *
**************************************************************************
A_EXPLODE_SPLORCH_SND
	SOUND1	SND_SPLORCH_EXPLODE
	SOUND1	SND_SPLORCH_SPLORCH
	RETS

SND_SPLORCH_EXPLODE
	.WORD	0F226H,60,0A30AH,0	;Explode
SND_SPLORCH_SPLORCH
	.WORD	0F126H,68,0A1BFH,0	;Splorch

**************************************************************************
*								         *
* 	F_FLIPH								 *
* 									 *
* 	Frag func to flip in the horizontal				 *
*								         *
**************************************************************************
F_FLIPH_CLRVEL
	ORIM	M_FLIPH,*A0(OCTRL),W
F_CLRVEL
	JAUC	CLRVEL

F_GOOEY_CLRVEL
	CALLR	F_GOOEY_PAL
	JRUC	F_CLRVEL

F_GOOEY_FLIPH_CLRVEL
	CALLR	F_GOOEY_PAL
	JRUC	F_FLIPH_CLRVEL

*
* Change object in A0 to the GOOEY palette
*
F_GOOEY_PAL
	MMTM	SP,A0,A8
	MOVE	A0,A8
	MOVI	P_BLOODGR,A0
	CALLA	CHANGE_PAL
	MMFM	SP,A0,A8
	RETS
	
CHUNK_SPLORCH
	LWL	SPLORCH2,4|AFunc,A_EXPLODE_SPLORCH_SND
	LW	SPLORCH3,4
	LWLLLL	SPLORCH4,4|AFunc,A_PreFrag_Box+6,FRAG_BLOOD_SPLORCH_DROPS,0h,20000h
	LW	SPLORCH5,4
	LWL	1,1|AFunc,DELETE_OBJ

FRAG_BLOOD_SPLORCH_DROPS
	.long	CHUNK_BLOOD_SM,F_DIR_BLOOD_X2
	.word	OID_JUNK,4*800H+3*40H+FRGPAL+FRGNOFLP+FRGGCOL

	.long	CHUNK_BLOOD_SM,F_DIR_BLOOD
	.word	OID_JUNK,2*800H+2*40H+FRGPAL+FRGNOFLP+FRGGCOL+FRGBOG

FRAG_SBOMB_BLOOD
	.long	CHUNK_BLOOD_SM,F_DIR_BLOOD_X2
	.word	OID_JUNK,4*800H+2*40H+FRGPAL+FRGNOFLP+FRGGCOL+FRGBOG

	.long	CHUNK_BLOOD_SM,F_DIR_BLOOD
	.word	OID_JUNK,2*800H+1*40H+FRGPAL+FRGNOFLP+FRGGCOL+FRGBOG

	.LONG	0

CHUNK_GSPLORCH
	LWL	SPLORCH2,4|AFunc,A_EXPLODE_SPLORCH_SND
	LW	SPLORCH3,4
	LWLLLL	SPLORCH4,4|AFunc,A_PreFrag_Box+6,FRAG_GOOEY_SPLORCH_DROPS,0h,20000h
	LW	SPLORCH5,4
	LWL	1,1|AFunc,DELETE_OBJ

FRAG_GOOEY_SPLORCH_DROPS
	.long	CHUNK_BLOOD_SM,F_DIR_GOO_X2
	.word	OID_JUNK,4*800H+3*40H+FRGPAL+FRGNOFLP+FRGGCOL

	.long	CHUNK_BLOOD_SM,F_DIR_GOO
	.word	OID_JUNK,2*800H+2*40H+FRGPAL+FRGNOFLP+FRGGCOL+FRGBOG

FRAG_SBOMB_GOO
	.long	CHUNK_BLOOD_SM,F_DIR_GOO_X2
	.word	OID_JUNK,4*800H+2*40H+FRGPAL+FRGNOFLP+FRGGCOL+FRGBOG

	.long	CHUNK_BLOOD_SM,F_DIR_GOO
	.word	OID_JUNK,2*800H+1*40H+FRGPAL+FRGNOFLP+FRGGCOL+FRGBOG

	.LONG	0

CHUNK_SPLORCH_NODROPS
	LWL	SPLORCH2,4|AFunc,A_EXPLODE_SPLORCH_SND
	LW	SPLORCH3,4
	LW	SPLORCH4,4
	LW	SPLORCH5,4
	LWL	1,1|AFunc,DELETE_OBJ

P_BLOODGR:
   .word   16 
   .word   00000h,06b99h,04f71h,02f4ah,003e0h,01783h,01383h,016e4h
   .word   01303h,012a3h,012c4h,00220h,011e3h,001e0h,001a0h,04eafh

	.END
