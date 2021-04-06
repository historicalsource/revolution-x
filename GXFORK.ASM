 	.MLIB	"GXMACS.LIB"
	.FILE	"GXFORK.ASM"
	.TITLE	"<<< GENERATION X -- Forklift enemy >>>"
	.WIDTH	132
	.OPTION	B,D,L,T
	.MNOLIST

**************************************************************************
*								         *
* 	COPYRIGHT (C) 1994 MIDWAY MANUFACTURING COMPANY.		 *
* 		       ALL RIGHTS RESERVED.				 *
*								         *
**************************************************************************

	.INCLUDE	"GXENEMY.INC"			;SYSTEM EQUATES
	.INCLUDE	"GXCONTRL.H"
	.INCLUDE	"IMGTBL.GLO"
	.INCLUDE	"GXKLUDGE.H"
	.INCLUDE	"GXFORK.TBL"

* In this file

	.DEF	PROC_SIDE_FORKLIFT, PROC_BRAD_FORKLIFT, PROC_FRONT_FORKLIFT

***** from GXRAM.ASM
	.REF	RAND, HOLD_ENEMY_DISPATCH, SHIELD_AWARDS, BASE_HIT

***** from GXD.ASM
	.REF	XBASE, ZBASE, YWORLD, ZREL_OFF
	.REF	SET_ANIPU

***** from GXENEMY.ASM
	.REF	INSERT_ENEMY, CREATE_ENEMY, DEL_ENEMY_NOAUD, EGUN_FLASH_MULTI

***** from GXUNIJAP.ASM
	.REF	SND_CHEST_HIT, SND_CHEST_EXPLODE

***** from GXUNIJP2.ASM
	.REF	METAL_GUNVECT, CRATE_FRAGS, DEAD_GUNVECT

***** from GXAFUNC.ASM
	.REF	A_SET_OXVEL, A_STAY_TIL_ONSCRN, A_STAY_TIL_OFFSCRN
	.REF	A_SOUND, A_PreFrag_Center, A_Anim_DSJ, A_Set_AnimLoop
	.REF	A_RAND_REL_BYTE

***** from GXAERO.ASM
	.REF	BRAD_ON_FORK

***** from GXSND.ASM
	.REF	ONESND_Z, ONESND

***** from GXPOWER.ASM
	.REF	ATTACH_SHIELD, ATTACH_CD

***** from GXPROC.ASM
	.REF	OBJPROC_KILL_MULTI

***** from GXWARREN.ASM
	.REF	ANIM_PART_EXPLOSIONS, BLOW_BTR_PART

***** from GXDESK.ASM
	.REF	SND_FINAL_EXPLODE2, FRAG_SMALL_OUT_EXP, FRAG_DESK_METAL
	.REF	SND_FINAL_EXPLODE3, FRAG_EXPLOSION_SMALL

***** from GXCOG.ASM
	.REF	STORE_OCONST

***** from GXPLAYER.ASM
	.REF	CK_PLAYER_HIT, PLAYER_HIT


* Forklift Object data area
*	Note: Any fields named the same as the Coghead should
*		use the same offset.
*
OHITS		.EQU	ODATA		;UHL GUN HIT COUNTER:
					;0-7:P1 HITS, 8-15:P2 HITS
					;16-23:P3 HITS, 24-31:P4 HITS

OMISSES		.EQU	ODATA+020H	;UHB Number of consec. missed shots
OCHEWED_ROCKET	.EQU	ODATA+028H	;UHB Means that a rocket hit him
OBURSTCNT	.EQU	ODATA+030H	;UHB Number of bursts left, if hitting
ORAPIDCNT	.EQU	ODATA+038H	;UHB Current rapid fire shots left

ONO_STOP	.EQU	ODATA+060H	;UHB This is a non-stopper guy
OJUMPING	.EQU	ODATA+068H	;UHB We are currently jumping

OHRUN_DURATION	.EQU	ODATA+070H	;UHW Headon crazy run duration

OJUMP_SLEEP	.EQU	ODATA+0C0H	;UHW Remaining jump sleep
OEFLAGS		.EQU	ODATA+0D0H	;UHW ENEMY FLAGS

OBLOW_AFUNC	.EQU	ODATA+0E0H	;UHL Blow func for explosion

OSHOOT_ANIM	.EQU	ODATA+100H	;UHL USE THIS ANIMATION TO SHOOT
ODEATH_ANIM	.EQU	ODATA+120H	;UHL USE THIS ANIMATION FOR DEATH
OSTOP_ANIM	.EQU	ODATA+160H	;UHL USE THIS ANIMATION FOR STOPPING
OFLINCH_ANIM	.EQU	ODATA+180H	;UHL Current flinch animation

OXORIG		.EQU	ODATA+1B0H	;UHW Origination universe X
OXLIMIT		.EQU	ODATA+1C0H	;UHW If <> 0 then this is X travel

OYENEMY		.EQU	ODATA+1D0H	;UHW Universe Y position of enemy

OXACCEL		.EQU	ODATA+1E0H	;SHW X acceleration
OZACCEL		.EQU	ODATA+1F0H	;SHW Z acceleration


*
* Enemy Flags
*
B_SIDE		EQU	0		;DIRECTION
B_NOZREL	EQU	1		;Z values are absolute
B_STAYPUT	EQU	3		;Flag to stay on screen 'til killed or off
B_INVINCIBLE	EQU	7		;IF=1, THEN COGHEAD IS INVINCIBLE


M_SIDE		EQU	001H
M_NOZREL	EQU	002H
M_STAYPUT	EQU	008H
M_INVINCIBLE	EQU	080H

HEADON_VEL	EQU	-0140H		;HEADON RUN VELOCITY
SIDE_VEL	EQU	01F000H		;SIDE RUN (TO THE RIGHT) VELOCITY 

FORKLIFT_FLASH_COLOR	.EQU	0101H

	.TEXT


**************************************************************************
*								         *
* 	PROC_SIDE_FORKLIFT						 *
* 									 *
* 	Process to fire off a side fork lift.				 *
* 									 *
* 	A9 = Univ X							 *
* 	A10 = Univ Y							 *
* 	A11 = Univ Z  (ZREL_OFF added to this)				 *
*								         *
**************************************************************************
PROC_SIDE_FORKLIFT
	MOVI	M_SIDE,A8		;Make him come from the side

	MOVE	@RAND,A6,W
	ANDI	M_FLIPH,A6		;Random flip this guy

	JRUC	PROC_FORKLIFT

**************************************************************************
*								         *
* 	PROC_FRONT_FORKLIFT						 *
* 									 *
* 	Process to fire off a front fork lift.				 *
*								         *
* 	A9 = Univ X							 *
* 	A10 = Univ Y							 *
* 	A11 = Univ Z							 *
*								         *
**************************************************************************
PROC_FRONT_FORKLIFT
	CLR	A6
	CLR	A8
	JRUC	PROC_FORKLIFT

**************************************************************************
*								         *
* 	PROC_FORKLIFT							 *
* 									 *
* 	Process to fire off a fork lift.				 *
* 									 *
* 	A6 = General purpose register, saved through Create		 *
* 	A8 = EFLAGS to denote Side or Headon				 *
* 	A9 = Univ X							 *
* 	A10 = Univ Y							 *
* 	A11 = Univ Z							 *
*								         *
**************************************************************************
PROC_FORKLIFT
	MOVE	@HOLD_ENEMY_DISPATCH,A14,W
	JANE	SUCIDE

	MOVI	OID_FORKLIFT,A0
	CALLA	GET_ENEMY_COUNT
	CMPK	4,A0
	JAHS	SUCIDE

	BTST	B_SIDE,A8
	JRNZ	PF_SIDE_INIT			;BR = Doing a side guy

       	MOVI	FRONT_FORK_INIT,B0
	JRUC	PF_INIT

PF_SIDE_INIT
	MOVI	FORK_INIT,B0
PF_INIT
	MMTM	SP,A6,A8
	CALLA	CREATE_ENEMY
	MMFM	SP,A6,A7		;Preserve status please
	JAZ	SUCIDE			;BR = Could not create the dude

	MOVE	A11,A3

	BTST	B_NOZREL,A7
	JRNZ	PF_NOZREL		;BR = Skip the ZREL adjustment

	MOVE	@ZREL_OFF,A14,L
	SRA	ZFRAC,A14
	ADD	A14,A3

PF_NOZREL
	MOVE	A9,A1
	MOVE	A10,A2

	BTST	B_SIDE,A7
	JRZ	PF_NOSIDE

	MOVE	A2,A5
	MOVE	@YWORLD,A14,L
	SUB	A14,A5
	MOVE	A5,*A8(OGRNDOFF),L

	BTST	B_FLIPH,A6
	JRZ	PF_LEFT
	MOVI	650,A5
	JRUC	PF_SIDE_CALC
PF_LEFT
	MOVI	-250,A5
PF_SIDE_CALC
	STOUX	A3,A5	

	MOVE	A5,A1			;Set us off of the top of the screen
	JRUC	PF_POSITION

PF_NOSIDE
PF_POSITION
	CALLA	SET_ANIPU		;Position him

	BTST	B_SIDE,A7
	JRZ	PFA_NO_SIDE		;BR = This is not a jump in guy

	CALLR	LOAD_SIDE_BLOWS		;Load the blow frames for the side

	MOVI	ANIM_SIDE,A1
	JRUC	PFA_LOAD_HEAD

PFA_NO_SIDE

	MOVI	ANIM_FRONT,A1
	JRUC	PFA_LOAD_HEAD

PFA_LOAD_HEAD
	CALLA	STRT_ANIM		;START ANIMATION

	MOVE	A7,*A8(OEFLAGS),W

	BTST	B_SIDE,A7
	JRZ	PBH_NOSET
	MOVE	A6,A0	
	CALLA	SET_FLPS
PBH_NOSET

	MOVI	FORKLIFT_FLASH_COLOR,A1
	CALLA	STORE_OCONST		;STORE THE PROPER VALUE FOR CONSTANT

	CALLA	INSERT_ENEMY		;INSERT AND COUNT ENEMY

FORK_WATCH
	MOVE	A13,*A8(OPLINK),L

FORK_WATCH_LOOP
	SLOOP	7000H,FORK_WATCH_LOOP	;Here we wait for shit to happen


**************************************************************************
*								         *
* 	PROC_BRAD_FORKLIFT						 *
* 									 *
* 	Process to fire off a fork lift that has Brad Whitford.		 *
* 									 *
* 	A9 = Univ X							 *
* 	A10 = Univ Y							 *
* 	A11 = Univ Z							 *
*								         *
**************************************************************************
PROC_BRAD_FORKLIFT
	MOVI	FORK_INIT,B0
	CALLA	CREATE_ENEMY
	JAZ	SUCIDE			;BR = Could not create the dude

	MOVE	A11,A3

	MOVE	@ZREL_OFF,A14,L
	SRA	ZFRAC,A14
	ADD	A14,A3

	MOVE	A9,A1
	MOVE	A10,A2

	CALLA	SET_ANIPU		;Position him

	MOVI	ANIM_BRAD_WAIT,A1
	CALLA	STRT_ANIM		;START ANIMATION

	MOVI	M_FLIPH,A0
	CALLA	SET_FLPS

	MOVI	FORKLIFT_FLASH_COLOR,A1
	CALLA	STORE_OCONST		;STORE THE PROPER VALUE FOR CONSTANT

	MOVI	DUMCOLL,A1	
	CALLR	STORE_OCVECT		;Make him not be hurt by rockets

	CALLA	INSERT_ENEMY		;INSERT AND COUNT ENEMY

	MOVK	NUM_BRAIN,A1
	CALLA	FINDPART
	CALLA	OBJOFF			;Turn off the Brain part

	PUSH	A8
	CALLA	BRAD_ON_FORK
	PULLQ	A8

	JRUC	FORK_WATCH

**************************************************************************
*								         *
* 	SIDE_FORK_CVECT							 *
* 									 *
* 	Collision vector table for side running forklift.		 *
*								         *
**************************************************************************
SIDE_FORK_CVECT
	WWL	OID_PROCKET,~MASK_PLAYER,FORK_CD_COLL
	WWL	OID_PEXPLOSION,~MASK_PLAYER,SFORK_EXPLOSION_CVECT
	WL	0,DUMCRETS

**************************************************************************
*								         *
* 	FRONT_FORK_CVECT						 *
* 									 *
* 	Collision vector table for front running forklift.		 *
*								         *
**************************************************************************
FRONT_FORK_CVECT
	WWL	OID_PROCKET,~MASK_PLAYER,FORK_CD_COLL
	WWL	OID_PEXPLOSION,~MASK_PLAYER,FFORK_EXPLOSION_CVECT
	WL	0,DUMCRETS

**************************************************************************
*								         *
* 	FORK_CD_COLL							 *
* 									 *
* 	Fork lift collides with a CD.					 *
* 									 *
* 	A0 = Ptr to CD							 *
* 	A8 = Ptr to fork lift part					 *
*								         *
**************************************************************************
FORK_CD_COLL
	MOVE	*A0(RL_INTENDED_OBJ),A14,L
	CMP	A14,A8			;Is this the object we are after?
	JRNE	FCC_X			;BR = No

	CALLA	GET_HEAD_PART
	MOVKB	1,*A8(OCHEWED_ROCKET)	;Flag the rocket hit
FCC_X
	RETS

**************************************************************************
*								         *
* 	SFORK_EXPLOSION_CVECT						 *
* 									 *
* 	Side forklift collides with an explosion.			 *
* 									 *
* 	A0 = Ptr to explosion						 *
* 	A8 = Ptr to forklift part					 *
*								         *
**************************************************************************
SFORK_EXPLOSION_CVECT
	CALLA	GET_HEAD_PART

	MOVB	*A8(OCHEWED_ROCKET),A14
	JRZ	SFEC_X
	
	MOVE	*A8(OHITS),A14,W
	INC	A14
	MOVE	A14,*A8(OHITS),W

	CMPK	2,A14
	JRHS	SEC_BLOWIT

	CLRB	*A8(OCHEWED_ROCKET)

	MOVK	NUM_CAGEFRNT,A1
	CALLA	FINDPART
	MOVI	ANIM_SIDE_ROCK_HIT,A1
	CALLA	STRTANIM
	JRUC	SFEC_X

SEC_BLOWIT
	ORIM	M_DEAD,*A8(OFLAGS),W

	CALLA	ALL_COLLS_OFF
	CALLA	OBJPROC_KILL_MULTI
	CALLA	PULL_ANIM_ALL

	CALLA	CLR_VEL

	MOVI	ANIM_SIDE_EXPLODE,A1
	CALLA	STRT_ANIM

SFEC_X
	RETS

**************************************************************************
*								         *
* 	FFORK_EXPLOSION_CVECT						 *
* 									 *
* 	Front forklift collides with an explosion.			 *
* 									 *
* 	A0 = Ptr to explosion						 *
* 	A8 = Ptr to forklift part					 *
*								         *
**************************************************************************
FFORK_EXPLOSION_CVECT
	CALLA	GET_HEAD_PART

	MOVB	*A8(OCHEWED_ROCKET),A14
	JRZ	FFEC_X
	
	MOVE	*A8(OHITS),A14,W
	INC	A14
	MOVE	A14,*A8(OHITS),W

	CMPK	2,A14
	JRHS	FFEC_BLOWIT

	CLRB	*A8(OCHEWED_ROCKET)

	MOVK	NUM_FCAGETOP,A1
	CALLA	FINDPART
	MOVI	ANIM_FRONT_ROCK_HIT,A1
	CALLA	STRTANIM
	JRUC	FFEC_X

FFEC_BLOWIT
	ORIM	M_DEAD,*A8(OFLAGS),W

	CALLA	ALL_COLLS_OFF
	CALLA	OBJPROC_KILL_MULTI
	CALLA	PULL_ANIM_ALL

	CALLA	CLR_VEL

	MOVI	ANIM_FRONT_EXPLODE,A1
	CALLA	STRT_ANIM

FFEC_X
	RETS

**************************************************************************
*								         *
* 	FCRATE_CVECT							 *
* 									 *
* 	Collision vector table for fork lift crate.			 *
*								         *
**************************************************************************
FCRATE_CVECT
	WWL	OID_PROCKET,~MASK_PLAYER,FORK_CRATE_CD_COLL
	WWL	OID_PEXPLOSION,~MASK_PLAYER,FCRATE_EXPLOSION_CVECT
	WL	0,DUMCRETS

**************************************************************************
*								         *
* 	FORK_CRATE_CD_COLL						 *
* 									 *
* 	Fork lift crate collides with a CD.				 *
* 									 *
* 	A0 = Ptr to CD							 *
* 	A8 = Ptr to fork lift crate					 *
*								         *
**************************************************************************
FORK_CRATE_CD_COLL
	MOVE	*A0(RL_INTENDED_OBJ),A14,L
	CMP	A14,A8			;Is this the object we are after?
	JRNE	FCCC_X			;BR = No

	MOVKB	1,*A8(OCHEWED_ROCKET)	;Flag the rocket hit
FCCC_X
	RETS

**************************************************************************
*								         *
* 	FCRATE_EXPLOSION_CVECT						 *
* 									 *
* 	Fork lift crate collides with an explosion.			 *
* 									 *
* 	A0 = Ptr to explosion						 *
* 	A8 = Ptr to fork lift crate					 *
*								         *
**************************************************************************
FCRATE_EXPLOSION_CVECT
	MOVB	*A8(OCHEWED_ROCKET),A14
	JRNZ	FEC_GO
	RETS
FEC_GO
	MOVE	*A0(OID),A0,W
	CALLA	POID_TO_PDATA			;Get player's data area
*
* A2 = Ptr to player
*
FCRATE_EXPLODE
	SOUNDZ	SND_CHEST_EXPLODE

	MOVIM	DEAD_GUNVECT,*A8(OGUNVECT),L
	MOVIM	DUMCOLL,*A8(OCVECT),L

	CALLA	CRATE_FRAGS

	MOVI	2500,A1				;Points for killing this thing
	CLR	A9				;Offset for printed score
	CALLA	PRINT_SCORE

	MOVK	1,A11
	MOVI	[-46,0],A10

	MOVE	@SHIELD_AWARDS,A14,W
	CMPK	3,A14
	JRLO	FCE_SHIELD

	CREATE	PID_IND,ATTACH_CD
	JRUC	FCE_BLOWBOX

FCE_SHIELD
	CREATE	PID_IND,ATTACH_SHIELD
FCE_BLOWBOX
	MOVI	NEWNBOXD,A1
	MOVE	*A8(OCTRL),A4,W
	CALLA	ANI

	MOVI	P_NBOXDM,A0
	JAUC	CHANGE_PAL

**************************************************************************
*								         *
* 	FCRATE_GUNVECT							 *
* 									 *
* 	Gun vector for the forklift crate.				 *
* 									 *
* 	A2 = Ptr to player shooting					 *
* 	A8 = Ptr to crate						 *
*								         *
**************************************************************************
FCRATE_GUNVECT
	MOVK	1,A1
	MOVE	*A2(PPLASMASHOTS),A14,W
	JRZ	FGV_TAKE_HITS

	ADDK	9,A1
FGV_TAKE_HITS
	MOVE	*A8(OHITS),A14,W
	ADD	A1,A14
	MOVE	A14,*A8(OHITS),W
	CMPK	5,A14
	JRHS	FCRATE_EXPLODE

	SOUNDZ	SND_CHEST_HIT

	RETS
	
**************************************************************************
*								         *
* 	A_STAY_TIL_OFFOPP						 *
* 									 *
* 	Anim func to stay put until object is off of the opposite	 *
* 	side of the screen.						 *
* 									 *
* 	A8 = Ptr to any head part					 *
*								         *
**************************************************************************
A_STAY_TIL_OFFOPP
	CALLA	SCRTST
	JREQ	ASTO_STAY		;BR = Not offscreen yet
		
	MOVE	*A8(OCTRL),A4,W

	MOVE	*A8(OXVAL),A1,L
	MOVE	@XBASE,A14
	SUB	A14,A1			;Universe to World X
	JRLT	ASTO_LEFT		;BR = Off left side of screen
*
* He's off of the right side of the screen
*
	BTST	B_FLIPH,A4		;Is he currently facing left?
	JRZ	ASTO_X			;BR = No, then he's gone

	SUBIM	50H,*A8(AnimFrm),L

	RETS
*
* He's off of the left side of the screen
*
ASTO_LEFT
	BTST	B_FLIPH,A4		;Is he currently facing right?
	JRNZ	ASTO_X			;BR = No, then he's gone

ASTO_STAY
	SUBIM	50H,*A8(AnimFrm),L

ASTO_X
	RETS

**************************************************************************
*								         *
* 	A_TIRE_SPEED							 *
* 									 *
* 	Anim func to select a sleep time and direction for		 *
* 	the tire, based on velocity.					 *
* 									 *
* 	A8 = Tire							 *
*								         *
**************************************************************************
A_TIRE_SPEED
	CALLA	GET_HEAD_PART_A0
	MOVE	*A0(OXVEL),A1,L
	MOVK	6,A2
ATS_SPEED_LOOP
	ABS	A1	
	SUBI	8000H,A1
	JRLE	ATS_DONE
	DSJS	A2,ATS_SPEED_LOOP
	INC	A2				;Default to 1
ATS_DONE
	MOVB	A2,*A8(AnimSLP)
	RETS

**************************************************************************
*								         *
* 	A_STAY_TIL_XVEL_NONZ						 *
* 									 *
* 	Anim func to stay put if the head part velocity of		 *
* 	object is zero.							 *
* 									 *
* 	A8 = Ptr to any part						 *
*								         *
**************************************************************************
A_STAY_TIL_XVEL_NONZ
	CALLA	GET_HEAD_PART_A0
	MOVE	*A0(OXVEL),A14,L
	JRNZ	ASTYN_X		  	;BR = We are movin'

	SUBIM	50H,*A8(AnimFrm),L

ASTYN_X
	RETS

**************************************************************************
*								         *
* 	A_STAY_TIL_ZVEL_NONZ						 *
* 									 *
* 	Anim func to stay put if the head part velocity of		 *
* 	object is zero.							 *
* 									 *
* 	A8 = Ptr to any part						 *
*								         *
**************************************************************************
A_STAY_TIL_ZVEL_NONZ
	CALLA	GET_HEAD_PART_A0
	MOVE	*A0(OZVEL),A14,L
	JRNZ	ASTZN_X		  	;BR = We are movin'

	SUBIM	50H,*A8(AnimFrm),L

ASTZN_X
	RETS

**************************************************************************
*								         *
* 	A_START_SIDE_PARTS						 *
* 									 *
* 	Anim func to start all relevent parts animating.		 *
*								         *
**************************************************************************
A_START_SIDE_PARTS
	CALLA	GETAFARG_LONG
	MOVE	A0,A2
	MOVK	NUM_SBODY,A1
	CALLA	FINDPART
	MOVK	5,A6
	MOVE	A2,A1
ASSP_LOOP
	CALLA	STRTANIM
	MOVE	*A0(OPARTS),A0,L
	DSJS	A6,ASSP_LOOP
	RETS

**************************************************************************
*								         *
* 	A_START_FRONT_PARTS						 *
* 									 *
* 	Anim func to start all relevent parts animating.		 *
*								         *
**************************************************************************
A_START_FRONT_PARTS
	CALLA	GETAFARG_LONG
	MOVE	A0,A2
	MOVK	NUM_FBODY,A1
	CALLA	FINDPART
	MOVK	6,A6
	MOVE	A2,A1
ASFP_LOOP
	CALLA	STRTANIM
	MOVE	*A0(OPARTS),A0,L
	DSJS	A6,ASFP_LOOP
	RETS

**************************************************************************
*								         *
* 	A_START_SIDE_FINAL						 *
* 									 *
* 	Anim func to start final side parts on their blow.		 *
* 									 *
* 	A8 = Ptr to any part						 *
*								         *
**************************************************************************
A_START_SIDE_FINAL
	CALLA	GETAFARG_LONG
	MOVE	A0,A2

	MOVK	NUM_CAGEBACK,A1
	CALLA	FINDPART
	MOVK	11,A6
	MOVE	A2,A1
ASS2P_LOOP
	MOVE	*A0(OBLOW_AFUNC),A14,L
	JRZ	ASS2P_SKIP
	
	CALLA	STRTANIM
ASS2P_SKIP
	MOVE	*A0(OPARTS),A0,L
	DSJS	A6,ASS2P_LOOP
	RETS

**************************************************************************
*								         *
* 	A_BLOW_DAMN							 *
* 									 *
* 	Anim func to blow out a body part.				 *
*								         *
**************************************************************************
A_BLOW_DAMN
	MOVE	*A8(OBLOW_AFUNC),A14,L
	JRNZ	ABD_JUMP
	RETS
ABD_JUMP
	JUMP	A14

**************************************************************************
*								         *
* 	A_FRONT_DECISION1						 *
* 									 *
* 	First decision for the front fork lift.				 *
* 									 *
* 	Are we a cruiser, or a Stay put?				 *
* 									 *
* 	A8 = Ptr to head part.						 *
*								         *
**************************************************************************
A_FRONT_DECISION1
	MOVE	*A8(OEFLAGS),A14,W
	BTST	M_STAYPUT,A14
	JRNZ	AFD_STAY
	MOVIM	HEADON_VEL,*A8(OZVEL),L
AFD_STAY
	RETS

**************************************************************************
*								         *
* 	A_FIRE_FNC							 *
* 									 *
* 	Anim func for normal part gun fire.				 *
* 									 *
* 	A8 = Ptr to part firing						 *
* 	AARG+,L = [Y,X] firing offset					 *
*								         *
**************************************************************************
A_FIRE_FNC
	CALLA	GET_HEAD_PART_A0
	MOVE	A0,A9  				;Everything is in his head

	MOVB	*A9(OFLAGS+B_DEAD-7),A14
	JRN	AFF_X				;BR = Object is dead

	MOVB	*A8(OFLAGS),A14
	JRN	AFF_X				;BR = Offscreen

	CALLA	GETAFARG_LONG			;Get the firing offset
	MOVE	A0,A3

	MOVE	@BASE_HIT,A5,W
	SLL	4,A5

	CALLA	EGUN_FLASH_MULTI		;Make a flash

;	CALLA	CK_PLAYER_HIT
;	JRNZ	AFF_SOUND		;BR = Successful hit on Player(s)
;	JRC	AFF_X			;BR = No hit, and not visible
;AFF_SOUND

	ALLPLYR	PLAYER_HIT		;HIT 'EM ALL

	SOUNDZ	SND_FORK_FIRE
AFF_X
	RETS

**************************************************************************
*								         *
* 	STORE_OCVECT							 *
* 									 *
* 	Store the given collision vector in all of the objects		 *
* 	in a multi-parter, from the given on down.			 *
* 									 *
* 	A1 = OCVECT to store						 *
* 	A8 = Ptr to first part to store					 *
*								         *
**************************************************************************
STORE_OCVECT
	MOVE	A8,A14
SOV_LP
	MOVE	A1,*A14(OCVECT),L
	MOVE	*A14(OPARTS),A14,L
	JRNZ	SOV_LP
	RETS

**************************************************************************
*								         *
* 	LOAD_SIDE_BLOWS							 *
* 									 *
* 	Load the proper blow frames for the side fork lift.		 *
* 									 *
* 	A8 = Ptr to any part						 *
*								         *
**************************************************************************
LOAD_SIDE_BLOWS
	MMTM	SP,A0,A1

	CALLA	GET_HEAD_PART_A0

	MOVE	*A0(OPARTS),A0,L
	MOVIM	SIDE_CGTOP_BLOW,*A0(OBLOW_AFUNC),L
	MOVE	*A0(OPARTS),A0,L
	MOVIM	SIDE_CGFRT_BLOW,*A0(OBLOW_AFUNC),L

	MOVK	NUM_SBODY,A1
	CALLA	FINDPART

	MOVIM	SIDE_FKBOD_BLOW,*A0(OBLOW_AFUNC),L
	MOVE	*A0(OPARTS),A0,L
	MOVIM	SIDE_FKLGO_BLOW,*A0(OBLOW_AFUNC),L
	MOVE	*A0(OPARTS),A0,L
	MOVIM	SIDE_FKTRK_BLOW,*A0(OBLOW_AFUNC),L

	MOVK	NUM_BRAIN,A1
	CALLA	FINDPART

	MOVIM	SIDE_FKBOX_BLOW,*A0(OBLOW_AFUNC),L

	MMFM	SP,A0,A1
	RETS


**************************************************************************
*								         *
* 	LOAD_FRONT_BLOWS						 *
* 									 *
* 	Load the proper blow frames for the front fork lift.		 *
* 									 *
* 	A8 = Ptr to any part						 *
*								         *
**************************************************************************
LOAD_FRONT_BLOWS
	MMTM	SP,A0,A1

	MOVK	NUM_FBODY,A1
	CALLA	FINDPART

	MOVIM	FRONT_FKBOD_BLOW,*A0(OBLOW_AFUNC),L
	MOVE	*A0(OPARTS),A0,L
	MOVIM	FRONT_FKBOD_BLOW,*A0(OBLOW_AFUNC),L

	MMFM	SP,A0,A1
	RETS

**************************************************************************
*								         *
* 	Blow funcs for side forklift.					 *
*								         *
**************************************************************************
SIDE_FKBOX_BLOW	
SIDE_CGTOP_BLOW
SIDE_FKBOD_BLOW
	MOVI	-20000H,A1
	MOVI	20000H,A2
	MOVI	-80000H,A3
	MOVE	A3,A4
	JAUC	BLOW_BTR_PART

SIDE_CGFRT_BLOW
	MOVI	-80000H,A1
	MOVE	A1,A2
	MOVI	-80000H,A3
	MOVE	A3,A4
	JAUC	BLOW_BTR_PART

SIDE_FKLGO_BLOW
	MOVI	-80000H,A1
	MOVI	80000H,A2
	MOVI	-80000H,A3
	MOVE	A3,A4
	JAUC	BLOW_BTR_PART

SIDE_FKTRK_BLOW
	MOVI	-20000H,A1
	MOVI	20000H,A2
	MOVI	-20000H,A3
	MOVE	A3,A4
	JAUC	BLOW_BTR_PART


**************************************************************************
*								         *
* 	Blow funcs for front forklift.					 *
*								         *
**************************************************************************
FRONT_FKBOD_BLOW
	MOVI	-80000H,A1
	MOVE	A1,A2
	CLR	A3
	MOVE	A3,A4
	JAUC	BLOW_BTR_PART


*
* Sounds for a forking experience
*
SND_FORK_FIRE
	.WORD	0F305H,25,0A10BH,0	;Fire sound

*
* Object initialization table for the Forklift that cruises
*
FORK_INIT
	.byte	 12, 0, 0, 9	;OBJCNT, PRCCNT, IMGPALCNT, PALCNT
	.long	P_SDFKBOD, P_SDFKLGO, P_SDFKBOX, P_SDCGBCK	;Palettes
	.long	P_SDCGTOP, P_SDCGFRT, P_SDFKTRK, P_SDFKLFT, P_SDFKTRS
	.word	OID_FORKLIFT, OM_COLL
	.LONG	DUMCOLL
*
*    .long	IMG
*    .word 		  OCTRL,  OFLAGS,   OZOFF, OPTION_FLAGS
*
NUM_CAGEBACK	.EQU	1
	LWWWW	SDCGBCK, DMAWNZ,  0,	5, OM_GUNV
	.LONG	METAL_GUNVECT

	LWWWW	SDCGTOP, DMAWNZ,  0,    0, OM_ANIM | OM_PRVGUNV
	.LONG	ANIM_VELOCITY_WATCH

NUM_CAGEFRNT	.EQU	3
	LWWWW	SDCGFRT, DMAWNZ,  0,    5, OM_PRVGUNV

NUM_SBODY	.EQU	4
	LWWWW	SDFKBOD, DMAWNZ,  0,    0, OM_PRVGUNV | OM_COLL
	.LONG	SIDE_FORK_CVECT

NUM_SLOGO	.EQU	5
	LWWWW	SDFKLGO, DMAWNZ,  0,   -1, OM_PRVGUNV | OM_COLL
	.LONG	SIDE_FORK_CVECT

	LWWWW	SDFKTRK, DMAWNZ,  0,    0, OM_PRVGUNV | OM_COLL
	.LONG	SIDE_FORK_CVECT

NUM_FORKS	.EQU	7
	LWWWW	SDFKLFT1, DMAWNZ,  0,    0, OM_PRVGUNV

	LWWWW	SDFKLFT2, DMAWNZ,  0,    0, OM_PRVGUNV

NUM_TIRES	.EQU	9
	LWWWW	SDFKTR1, DMAWNZ,  0,    -1, OM_OPARTS | OM_ANIM | OM_PRVGUNV
	.WORD	62,-20
	.LONG	ANIM_SIDE_TIRE

	LWWWW	SDFKTR1, DMAWNZ,  0,    -1, OM_OPARTS | OM_ANIM | OM_PRVGUNV
	.WORD	-61,-20
	.LONG	ANIM_SIDE_TIRE

NUM_BRAIN	.EQU	11
	LWWWW	SDFKBOX, DMAWNZ,  0,     3, OM_PRVGUNV | OM_COLL
	.LONG	SIDE_FORK_CVECT

	LWWWW	NONBOXX, DMAWNZ,  0,    -1, OM_OPARTS | OM_COLL | OM_GUNV
	.WORD	168,-28
	.LONG	FCRATE_CVECT, FCRATE_GUNVECT


*
* Object initialization table for the front facing forklift
*
FRONT_FORK_INIT
	.byte	 13, 0, 0, 6	;OBJCNT, PRCCNT, IMGPALCNT, PALCNT
	.long	P_FFKBOD, P_FFCGTOP, P_FFCGBAR, P_FFKTRS	;Palettes
	.long	P_FFKLFT, P_M60
	.word	OID_FORKLIFT, OM_COLL
	.LONG	DUMCOLL
*
*    .long	IMG
*    .word 		  OCTRL,  OFLAGS,   OZOFF, OPTION_FLAGS
*
	LWWWW	FFCGBAR, DMAWNZ,  0,	0, OM_GUNV
	.LONG	METAL_GUNVECT

	LWWWW	FFCGBAR, DMAWNZ|M_FLIPH,  0,    0, OM_ANIM | OM_PRVGUNV
	.LONG	ANIM_VELOCITY_WATCH

NUM_FCAGETOP	.EQU	3
	LWWWW	FFCAGTP, DMAWNZ,  0,    0, OM_PRVGUNV

	LWWWW	FFCAGTP, DMAWNZ|M_FLIPH,  0,    0, OM_PRVGUNV

NUM_FBODY	.EQU	5
	LWWWW	FFRKBOD, DMAWNZ,  0,    -1, OM_COLL | OM_PRVGUNV
	.LONG	FRONT_FORK_CVECT

	LWWWW	FFRKBOD, DMAWNZ|M_FLIPH,  0,    -1, OM_COLL | OM_PRVGUNV
	.LONG	FRONT_FORK_CVECT

	LWWWW	FFKLFT1, DMAWNZ,  0,    -2, OM_PRVGUNV

	LWWWW	FFKLFT1, DMAWNZ|M_FLIPH,  0,    -2, OM_PRVGUNV

	LWWWW	FFKLFT2, DMAWNZ,  0,    -3, OM_PRVGUNV

	LWWWW	FFKLFT2, DMAWNZ|M_FLIPH,  0,    -3, OM_PRVGUNV

	LWWWW	FFTR1, DMAWNZ,  0,    -1, OM_ANIM | OM_PRVGUNV
	.LONG	ANIM_FRONT_TIRE

	LWWWW	FFTR1, DMAWNZ|M_FLIPH,  0,    -1, OM_ANIM | OM_PRVGUNV
	.LONG	ANIM_FRONT_TIRE

	LWWWW	M605, DMAWNZ,  0,    -1, OM_OPARTS | OM_ANIM | OM_PRVGUNV
	.WORD	5,-182
	.LONG	ANIM_FRONT_GUN


ANIM_VELOCITY_WATCH
	LW	1,50
	.LONG	0

*
* Forklift drives by on the side
*
ANIM_SIDE
	LWLL	1,1|AFunc,A_SET_OXVEL+2,SIDE_VEL
	LWL	1,40|AFunc,A_STAY_TIL_OFFOPP
	LWL	1,1|AFunc,OBJPROC_KILL_MULTI		;Just in case
	LWL	1,1|AFunc,DEL_ENEMY_NOAUD

*
* Fork lift drives from back to front
*
ANIM_FRONT
	LWL	1,1|AFunc,A_FRONT_DECISION1
	LWL	1,30|AFunc,A_STAY_TIL_ONSCRN
	LWL	1,30|AFunc,A_STAY_TIL_OFFSCRN
	LWL	1,1|AFunc,OBJPROC_KILL_MULTI		;Just in case
	LWL	1,1|AFunc,DEL_ENEMY_NOAUD

*
* Forklift that has Brad Whitford.  Delete watch
*
ANIM_BRAD_WAIT
	LWL	1,30|AFunc,A_STAY_TIL_ONSCRN
	LWL	1,30|AFunc,A_STAY_TIL_OFFSCRN
	LWL	1,1|AFunc,OBJPROC_KILL_MULTI		;Just in case
	LWL	1,1|AFunc,DEL_ENEMY_NOAUD


*
* Side forklift tire animation
*
ANIM_SIDE_TIRE
	LWL	SDFKTR2,1|AFunc,A_TIRE_SPEED
	LWL	1,0|AFunc,A_STAY_TIL_XVEL_NONZ

	LWL	SDFKTR3,1|AFunc,A_TIRE_SPEED
	LWL	1,0|AFunc,A_STAY_TIL_XVEL_NONZ

	LWL	SDFKTR1,1|AFunc,A_TIRE_SPEED
	LWL	1,0|AFunc,A_STAY_TIL_XVEL_NONZ

	.LONG	0

*
* Front fork lift tire animation
*
ANIM_FRONT_TIRE
	LWL	FFTR2,1|AFunc,A_TIRE_SPEED
	LWL	1,0|AFunc,A_STAY_TIL_ZVEL_NONZ

	LWL	FFTR3,1|AFunc,A_TIRE_SPEED
	LWL	1,0|AFunc,A_STAY_TIL_ZVEL_NONZ

	LWL	FFTR1,1|AFunc,A_TIRE_SPEED
	LWL	1,0|AFunc,A_STAY_TIL_ZVEL_NONZ

	.LONG	0

*
* Side running forklift explodes
*
ANIM_SIDE_EXPLODE
;	LWLL	1,1|AFunc,A_START_SIDE_PARTS+2,ANIM_PART_EXPLOSIONS

;	LW	1,10

	LWLL	1,1|AFunc,A_START_SIDE_FINAL+2,ANIM_DAMN_BLOW

	LWLL	1,1|AFunc,A_SOUND+2,SND_FINAL_EXPLODE3
	LWLLLL	1,1|AFunc,A_PreFrag_Center+6,FRAG_SMALL_OUT_EXP,0400h,40000h
	LWLL	1,1|AFunc,A_SOUND+2,SND_FINAL_EXPLODE2

	LWL	1,20|AFunc,OBJ_OFF_MULTI

	LWL	1,5|AFunc,DELAYED_PRAISE

	LWL	1,1|AFunc,DEL_ENEMY_NOAUD


*
* Front running forklift explodes
*
ANIM_FRONT_EXPLODE
	LWLL	1,1|AFunc,A_START_SIDE_FINAL+2,ANIM_DAMN_BLOW

	LWLL	1,1|AFunc,A_SOUND+2,SND_FINAL_EXPLODE3
	LWLLLL	1,1|AFunc,A_PreFrag_Center+6,FRAG_SMALL_OUT_EXP,0400h,40000h
	LWLL	1,1|AFunc,A_SOUND+2,SND_FINAL_EXPLODE2

	LWL	1,20|AFunc,OBJ_OFF_MULTI

	LWL	1,3|AFunc,DELAYED_PRAISE

	LWL	1,1|AFunc,DEL_ENEMY_NOAUD


ANIM_FRONT_ROCK_HIT
	LWLL	1,1|AFunc,A_START_FRONT_PARTS+2,ANIM_PART_EXP_EFFECT
	LWL	1,1|AFunc,PULL_ANIM

*
*Final blow animations
*
ANIM_DAMN_BLOW
	LWLW	1,1|AFunc,A_Set_AnimLoop+1,2
ANIM_D1_LOOP
	LWL	1,5|AFunc,A_BLOW_DAMN
	LWLL	1,1|AFunc,A_Anim_DSJ+2,ANIM_D1_LOOP
	LWL	1,1|AFunc,PULL_ANIM

ANIM_SIDE_ROCK_HIT
	LWLL	1,1|AFunc,A_START_SIDE_PARTS+2,ANIM_PART_EXP_EFFECT
	LWL	1,1|AFunc,PULL_ANIM

ANIM_PART_EXP_EFFECT
	LWLLLL	1,1|AFunc,A_PreFrag_Center+6,FRAG_EXPLOSION_SMALL,0100h,40000h
	LWL	1,1|AFunc,PULL_ANIM

*
* Head mounted gun does some shooting
*
ANIM_FRONT_GUN
	LWL	1,10|AFunc,A_STAY_TIL_ZVEL_NONZ
AFG_SHOOT_LOOP
	LWLWWW	1,1|AFunc,A_RAND_REL_BYTE+3,2,6,AnimLoop
AFG_RAPID_FIRE
	LWLWW	1,6|AFunc,A_FIRE_FNC+2,-3,0
	LWLL	1,1|AFunc,A_Anim_DSJ+2,AFG_RAPID_FIRE

	LWLWW	1,1|AFunc,A_RAND_AnimSLP+2,5,20

	LWL	1,0|AFunc,A_AnimFrm+2,AFG_SHOOT_LOOP


	.END
