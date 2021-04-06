 	.MLIB	"GXMACS.LIB"
	.FILE	"GXBZERK.ASM"
	.TITLE	"<<< GENERATION X -- Berzerker enemy >>>"
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
	.INCLUDE	"GXBZERK.TBL"

***** In this file

	.DEF	PROC_BZERK_HEADON_OFFSET, PROC_BZERK_JUMPIN
	.DEF	PROC_BZERK_STAND
	.DEF	PROC_BZERK_JMP_WRLD,PROC_BZERK_JUMP_ZW

***** from GXRAM.ASM
	.REF	WAVETIME, CURPLYRS, HOLD_ENEMY_DISPATCH, ENEMY_HITALL
	.REF	BASE_HIT, WAVE
	
***** from GXAFUNC.ASM
	.REF	A_SOUNDZ, SetAnim_AFARG, A_SET_OYVEL, A_RAND_REL_BYTE
	.REF	A_Anim_DSJ, SetAnim, A_SOUND, A_STAY_TIL_ONSCRN

***** from GXSND.ASM
	.REF	ONESND_Z, ONESND

***** from GXD.ASM
	.REF	GET_SHAD_MULTI, SET_ANIPU, XBASE, ZBASE, GETHEADPART, YBASE
	.REF	EXIST_OBJ_ALL, RESUME_EXIST_OBJ_ALL, SET_SCRN_POS
	.REF	SET_OBJSU, WORLD_GRNDOFF, YWORLD

***** from GXENEMY.ASM
	.REF	INSERT_ENEMY, CREATE_ENEMY, DEL_ENEMY_NOAUD, DELETE_ENEMY
	.REF	EGUN_FLASH_MULTI

***** from GXPLAYER.ASM
	.REF	CK_PLAYER_HIT, PLAYER_HIT

***** from GXPALL.ASM
	.REF	A_CHANGE_PAL

***** from GXCOG.ASM
	.REF	HIT_ENEMY, A_CLR_ALL_X, A_CLR_ALL_Z, OBJ_DRAWBITS_MULTI
	.REF	A_HIT_GROUND, A_GROUND_CK, STORE_OCONST

***** from GXMONDR2.ASM
	.REF	A_SPAWN_PROJECTILE, AXE_INIT

***** from GXBLOOD.ASM
	.REF	BLOODY_BULLET_HIT, A_BLOOD_SPLORCH, A_SBOMB_BLOOD

*
* Berzerker RAM
*


	.TEXT

*
* Berzerker Object data area
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

OSRUNVEL	.EQU	ODATA+080H	;UHL SIDE RUN VELOCITY

OHRUNVEL	.EQU	ODATA+0A0H	;UHL HEADON RUN VELOCITY

OJUMP_SLEEP	.EQU	ODATA+0C0H	;UHW Remaining jump sleep
OEFLAGS		.EQU	ODATA+0D0H	;UHW ENEMY FLAGS

* Used by guys that do not stand guard
OJUMPTAB	.EQU	ODATA+0E0H	;UHL Table of Jump positions
* Used be guard guys only. Also, must stay together, in this order
OGUARD_STARTZ	.EQU	ODATA+0E0H	;UHW Start Guard when ZBASE is GT
OGUARD_ATIME	.EQU	ODATA+0F0H	;UHW Time before activating

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
* Rope ODATA fields
*

*
* Enemy Flags
*
B_SIDE		EQU	0		;DIRECTION
					;0 = HEADON MOTHER FUCKER
					;1 = SIDEWAYS MELLOW DUDE
B_BRIDGE	EQU	1		;Bridge dwelling Coghead
B_JUMP_IN	EQU	2		;Jump in from the top of the screen
B_STAYPUT	EQU	3		;Flag to stay on screen 'til killed or off
B_FLIP		EQU	4		;HORIZONTALLY FLIPPED OUT WACKO
B_GUARD		EQU	5		;Standing guard guy
B_BLOCKING	EQU	6		;IF=1, THEN COGHEAD IS BLOCKING
B_INVINCIBLE	EQU	7		;IF=1, THEN COGHEAD IS INVINCIBLE


M_SIDE		EQU	001H
M_BRIDGE	EQU	002H
M_JUMP_IN	EQU	004H
M_STAYPUT	EQU	008H
M_FLIP		EQU	010H
M_GUARD		EQU	020H
M_BLOCKING	EQU	040H
M_INVINCIBLE	EQU	080H

HRUNVEL	EQU	-0140H			;HEADON RUN VELOCITY
HRUNVEL_CRAZY	.EQU	-280H		;Head on run for Crazy guy
SRUNVEL_MIN	EQU	01D000H		;SIDE RUN (TO THE RIGHT) VELOCITY 
SRUNVEL_MAX	EQU	01F000H		;SIDE RUN (TO THE RIGHT) VELOCITY 

JUMP_MIN_YVEL	.EQU	08000H		;Absolute jumping velocity

SHOOTCNT	EQU	3

BZRK_FRAME_TIME	.EQU	5		;BASE SLEEP TIME BETWEEN FRAMES
					;!!WARNING!! - VALUE MUST BE > 2
BZRK_HITS_TO_KILL EQU	5		;HITS REQUIRED TO KILL COG HEAD

BZRK_FLASH_COLOR EQU	0101H		;FLASH COLOR FOR COGHEAD

SHORT_DEATH_ZVEL .EQU	1C0H
LONG_DEATH_ZVEL	 .EQU	2C0H

**************************************************************************
*								         *
* 	PROC_BZERK_HEADON_OFFSET					 *
* 									 *
* 	Process to create a head-on berzerker at an offset from		 *
* 	another object.							 *
* 									 *
* 	A8 = Object to offset from					 *
* 	A9 = [Y,X] offset						 *
* 	A11 = Z offset							 *
*								         *
**************************************************************************
PROC_BZERK_HEADON_OFFSET
	MOVE	*A8(OYVAL),A10,L	;Get generator's universe Y
	MOVE	A9,A14
	SRA	16,A14
	SLL	15,A14			;Translate offset to world
	ADD	A14,A10			;This is the starting Y

	MOVE	*A8(OXVAL),A1,L		;Get generator's universe X
	SEXT	A9,W
	SLL	15,A9			;Translate
	ADD	A1,A9			;Starting Universe X

	ADDM	*A8(OZVAL),A11,L	;Starting Z

	JRUC	PROC_BZERK_HEADON

**************************************************************************
*								         *
* 	PROC_BZERK_HEADON						 *
* 									 *
* 	Process to create a head-on berzerker.				 *
* 									 *
* 	A9  = Universe X						 *
* 	A10 = Universe Y						 *
* 	A11 = Universe Z						 *
*								         *
**************************************************************************
PROC_BZERK_HEADON
	CLR	A8			;Clear OFLAGS for headon
	JRUC	PROC_BZERK

**************************************************************************
*								         *
* 	PROC_BZERK_JMP_WRLD						 *
* 									 *
* 	Create a berzerker that jumps in from the top of the		 *
* 	screen.								 *
* 									 *
* 	A9 = [Wrld X max >> 16, Wrld X min >> 16]			 *
* 	A10 = [Wrld Z max >> 4, Wrld Z min >> 4]			 *
* 	A11 = Don't leave screen (if = 1)				 *
*								         *
**************************************************************************
PROC_BZERK_JMP_WRLD
	MOVE	A11,A11
	JRZ	PBJW_NO_FLAGS
	MOVI	M_STAYPUT,A8
PBJW_NO_FLAGS
	MOVE	A9,A0
	MOVE	A0,A1
	SLL	16,A1
	CALLA	RANGERND		;Get our WORLD X position
	move	@XBASE,a14,L
	add	a14,a0
	MOVE	A0,A9

	MOVE	A10,A0
	SRA	16,A0
	SLL	4,A0
	MOVE	A10,A1
	SEXT	A1
	SLL	4,A1
	CALLA	RANGERND		;Get our WORLD Z position
	move	@ZBASE,a14,L
	add	a14,a0

	jruc	BZJ_hk	  


**************************************************************************
*								         *
* 	PROC_BZERK_JUMP_ZW						 *
* 									 *
* 	Create a berzerker that jumps in from the top of the		 *
* 	screen.								 *
* 									 *
* 	A9 = [Univ X max >> 16, Univ X min >> 16]			 *
* 	A10 = [Wrld Z max >> 4, Wrld Z min >> 4]			 *
* 	A11 = Don't leave screen (if = 1)				 *
*								         *
**************************************************************************
PROC_BZERK_JUMP_ZW
	MOVE	A11,A11
	JRZ	PBJZ_NO_FLAGS
	MOVI	M_STAYPUT,A8
PBJZ_NO_FLAGS
	MOVE	A9,A0
	MOVE	A0,A1
	SLL	16,A1
	CALLA	RANGERND		;Get our Univ X position
	MOVE	A0,A9
	
	MOVE	A10,A0
	SRA	16,A0
	SLL	4,A0
	MOVE	A10,A1
	SEXT	A1
	SLL	4,A1
	CALLA	RANGERND		;Get our WORLD Z position
	move	@ZBASE,a14,L
	add	a14,a0

	jruc	BZJ_hk	  


**************************************************************************
*								         *
* 	PROC_BZERK_JUMPIN						 *
* 									 *
* 	Create a berzerker that jumps in from the top of the		 *
* 	screen.								 *
* 									 *
* 	A9 = [Univ X max >> 16, Univ X min >> 16]			 *
* 	A10 = [Univ Z max >> 8, Univ Z min >> 8] 			 *
*								         *
**************************************************************************
PROC_BZERK_JUMPIN
	MOVE	A9,A0
	MOVE	A0,A1
	SLL	16,A1
	CALLA	RANGERND		;Get our Univ X position
	MOVE	A0,A9
	
	MOVE	A10,A0
	SRA	16,A0
	SLL	8,A0
	MOVE	A10,A1
	SEXT	A1
	SLL	8,A1
	CALLA	RANGERND		;Get our Univ Z position

	CLR	A8
*
* Entrypoint: Creates jump-in Berzerker
*	A8 = EFLAGS
*
BZJ_hk:			  
	MOVE	A0,A11

	move	@YWORLD,a10,L
	move	@WORLD_GRNDOFF,a14,L
	add	a14,a10
;	MOVE	@YBASE,A10,L
	ADDI	[-200,0],A10

	ORI	M_JUMP_IN,A8
	JRUC	PROC_BZERK

**************************************************************************
*								         *
* 	PROC_BZERK_STAND						 *
* 									 *
* 	Create a berzerker that stands guard until ZBASE is		 *
* 	greater than a given universe value.  Then he will wait		 *
* 	for ATIME before activating.  If ZBASE to wait is 0 then	 *
* 	he skips that check.						 *
* 									 *
* 	A8 = [ATIME, ZBASE >> 4 at which to activate]			 *
* 	A9  = Universe X						 *
* 	A10 = Universe Y						 *
* 	A11 = Universe Z						 *
*								         *
**************************************************************************
PROC_BZERK_STAND
	MOVE	A8,A6
	MOVI	M_GUARD,A8
	JRUC	PROC_BZERK

**************************************************************************
*								         *
* 	PROC_BZERK							 *
* 									 *
* 	Process entry point to create a Berzerker.			 *
* 									 *
* 	A6 = General purpose register, saved through Create		 *
* 	A8 = EFLAGS to denote Side or Headon				 *
* 	A9 = Universe X							 *
* 	A10 = Universe Y						 *
* 	A11 = Universe Z						 *
*								         *
**************************************************************************
PROC_BZERK
	MOVE	@HOLD_ENEMY_DISPATCH,A14,W
	JANE	SUCIDE

	MOVI	OID_BZERK,A0
	CALLA	GET_ENEMY_COUNT
	MOVK	5,A1
	MOVE	@CURPLYRS,A14,W
	ADD	A14,A1			;Adjust for amount of current players
	CMP	A1,A0
	JAHS	SUCIDE

	MMTM	SP,A6,A8
	MOVI	BZERK_INIT,B0
	CALLA	CREATE_ENEMY
	MMFM	SP,A6,A7		;Preserve status please
	JRZ	PBH_EXIT		;BR = Could not create the dude

	MOVE	A11,A3
	MOVE	A10,A2
	MOVE	A9,A1
	CALLA	SET_ANIPU		;Position him

;Do this only if these guys live off of the ground
;	SRA	16,A10
;	MOVE	A10,*A8(OYENEMY),W	;Store the integer landing line

	MOVI	SRUNVEL_MAX,A0
	MOVI	SRUNVEL_MIN,A1
	CALLA	RANGRAND
	MOVE	A0,*A8(OSRUNVEL),L	;SET SIDE VELOCITY

	MOVI	HRUNVEL_CRAZY,A1
	MOVE	A1,*A8(OHRUNVEL),L	;Set the headon velocity

	BTST	B_SIDE,A7
	JRZ	PBH_HEAD_ON

;	MOVE	A0,*A8(OXVEL),L
;	MOVI	SIDE_SKATE_ANIM,A1
;	MOVIM	SIDE_DEATH_ANIM,*A8(ODEATH_ANIM),L
;	MOVIM	SIDE_SPIN_STOP,*A8(OSTOP_ANIM),L
;	MOVIM	SIDE_GLIDE_SHOOT,*A8(OSHOOT_ANIM),L
;	JRUC	PBH_DIRSET

*This guy will be a HEAD-ON man
PBH_HEAD_ON
	BTST	B_JUMP_IN,A7
	JRZ	PBH_ON_GROUND		;BR = This is not a jump in guy
	MOVI	ANIM_JUMP_ON,A1
	JRUC	PBH_LOAD_HEAD
PBH_ON_GROUND
	BTST	B_GUARD,A7
	JRZ	PBH_RUNNING		;BR = This is not a guard guy
	MOVE	A6,*A8(OGUARD_STARTZ),L	;Save our starting ZBASE
	MOVI	ANIM_GUARD,A1
	JRUC	PBH_LOAD_HEAD
PBH_RUNNING
	MOVI	HEADON_CRAZY_RUN_ANIM,A1
PBH_LOAD_HEAD
	MOVIM	HEADON_DEATH_ANIM,*A8(ODEATH_ANIM),L
	MOVIM	HEADON_STOP_ANIM,*A8(OSTOP_ANIM),L
	MOVIM	HEADON_THROW_ANIM,*A8(OSHOOT_ANIM),L

PBH_DIRSET
	CALLA	STRT_ANIM		;START ANIMATION

	MOVE	A7,*A8(OEFLAGS),W

	BTST	B_SIDE,A7
	JRZ	PBH_NOSET
	MOVE	A6,A0	
	CALLA	SET_FLPS
PBH_NOSET

	MOVI	BZRK_FLASH_COLOR,A1
	CALLA	STORE_OCONST		;STORE THE PROPER VALUE FOR CONSTANT

	CALLA	OBJ_ON_MULTI		;We create with the objects off

	CALLA	GET_SHAD_MULTI		;Setup his shadow

	CALLA	INSERT_ENEMY		;INSERT AND COUNT ENEMY
	JRUC	BZERK_WATCH

PBH_EXIT
	DIE

BZERK_WATCH
	MOVE	A13,*A8(OPLINK),L
BZERK_WATCH_LOOP
	SLOOP	7000H,BZERK_WATCH_LOOP	;Here we wait for shit to happen

	
**************************************************************************
*								         *
* BZERK_CVECT								 *
*								         *
**************************************************************************
BZERK_CVECT
	WWL	OID_PROCKET,~MASK_PLAYER,BZERK_CD_COLL
	WWL	OID_PEXPLOSION,MASK_SUPP|MASK_TYPE|MASK_ID,BZERK_EXPLOSION_COLL
	WWL	OID_BLOWUP,0FFFFH,BZERK_SBOMB_COLL
	WL	0,DUMCRETS

**************************************************************************
*								         *
* BZERK_GUNVECT								 *
*								         *
* PASS:									 *
* A2 = PTR TO PLAYER						         *
* A8 = PTR TO OBJECT							 *
*								         *
**************************************************************************
BZERK_GUNVECT
	MOVB	*A8(OPARTID),A4			;Keep our Parts I.D.
	CALLA	GET_HEAD_PART

	SOUND1	SND_BODY_HIT

	CALLA	BLOODY_BULLET_HIT

	MOVE	*A8(OFLAGS),A9,W
	BTST	B_DEAD,A9
	JRNZ	BG_DEAD			;BR = He is already dead

	MOVE	A2,*A8(OPLAYER),L		;STORE PLAYER INFO FOR LATER???

	MOVE	*A8(OEFLAGS),A6,W

	RANDENT	TAB_HIT_SNDS,NUM_HIT_SNDS,5,L
	CALLA	ONESND_Z			;Give us a grunt

	MOVE	*A2(PPLASMASHOTS),A14,W
	JRNZ	BZERK_DO_DEATH		;BR = Wicked bullets being used

	BTST	B_INVINCIBLE,A6		;ARE WE CURRENTLY INVINCIBLE?
	JRNE	BG_DEAD			;BR = YES, JUST EXIT

	CMPK	NUM_LEGS,A4		;Was this the legs?
	JREQ	BG_TAKE_HIT		;BR = Yo, then no need to block

*
* A4 = OPARTID of part shot
* A6 = OEFLAGS
* A9 = OFLAGS
*
BG_TAKE_HIT
	CLR	A5
	MOVK	BZRK_HITS_TO_KILL,A1	;This many hits to kill
	MOVI	OHITS,A3		;This is the variable to use
	CALLA	HIT_ENEMY		;IS THIS GUY TOAST?
	JRHS	BZERK_DO_DEATH		;BR = OH YEAH!


;	MOVE	*A8(OZVEL),A14,L
;	JRNN	BG_SKIP_PUSH_BACK
;	PUSH	A2
;	MOVE	A8,A14
;	ADDI	OXVAL,A14
;	MOVE	*A14+,A1,L
;	MOVE	*A14+,A2,L
;	MOVE	*A14+,A3,L
;	ADDI	800H,A3
;	CALLA	SET_ANIPU
;	PULL	A2

;BG_SKIP_PUSH_BACK
	MOVE	*A8(OHRUN_DURATION),A14,W
	JRZ	BG_NOT_RUNNING
	ADDK	5,A14
	MOVE	A14,*A8(OHRUN_DURATION),W	
BG_NOT_RUNNING


*
* Berzerker is still alive here
*
	MOVI	BZERK_UNFLASH,A7
	CALLA	OBJPROC_INT		;INTERRUPT COG WATCHER
	JRZ	BG_DEAD			;BR = NO COG WATCHER EXISTS

	MOVI	DMACNZ&(~DMAGO),A1
	CALLA	OBJ_DRAWBITS_MULTI	;FLASH HIM WHITE

	ORI	M_INVINCIBLE,A6
	MOVE	A6,*A8(OEFLAGS),W	;MAKE HIM NON-HITTABLE NOW

BG_DEAD
	RETS

**************************************************************************
*								         *
* 	BZERK_UNFLASH							 *
* 									 *
* 	Process subroutine to turn off the Berzerker flash and		 *
* 	invinciblity bits.						 *
* 									 *
* 	A8 = Ptr to head object						 *
* 									 *
* 	Note: Call with JSRP						 *
*								         *
**************************************************************************
BZERK_UNFLASH
	SLEEP	2
	MOVI	DMAWNZ&(~DMAGO),A1
	CALLA	OBJ_DRAWBITS_MULTI
	SLEEP	2
	MOVE	*A8(OEFLAGS),A14,W
	ANDNI	M_INVINCIBLE,A14
	MOVE	A14,*A8(OEFLAGS),W
	RETP
	
**************************************************************************
*								         *
* 	BZERK_SBOMB_COLL						 *
* 									 *
* 	Berzerker get hit by a smart bomb.				 *
* 									 *
* 	A2 = Ptr to player smart bombing				 *
* 	A8 = Ptr to Berzerker						 *
*								         *
**************************************************************************
BZERK_SBOMB_COLL
	CLR	A5
	CALLA	GET_HEAD_PART
	JRUC	BZERK_GEN_COLL

**************************************************************************
*								         *
* 	BZERK_CD_COLL							 *
* 									 *
* 	Berzerker get hit by a CD					 *
* 									 *
* 	A0 = Ptr to CD							 *
* 	A8 = Ptr to Berzerker						 *
*								         *
**************************************************************************
BZERK_CD_COLL
	MOVE	*A0(RL_INTENDED_OBJ),A14,L
	CMP	A14,A8			;Is this the object we are after?
	JRNE	BCC_X			;BR = No

	CALLA	GET_HEAD_PART
	MOVKB	1,*A8(OCHEWED_ROCKET)	;Flag the rocket hit
	CLRM	*A8(OHRUN_DURATION),W	;Clear run target time
BCC_X
	RETS

**************************************************************************
*								         *
* 	BZERK_EXPLOSION_COLL						 *
* 									 *
* 	Berzerker collides with a player explosion.			 *
* 									 *
* 	A0 = Ptr to explosion						 *
* 	A8 = Ptr to Berzerker						 *
*								         *
**************************************************************************
BZERK_EXPLOSION_COLL
	CALLA	GETHEADPART			;GET THE KILLERS HEAD
	MOVE	A0,A5				;KEEP KILLER HERE
	MOVE	*A0(OID),A0,W			;GET PLAYER DATA ADDRESS
	CALLA	POID_TO_PDATA

	CALLA	GET_HEAD_PART
	MOVB	*A8(OCHEWED_ROCKET),A14		;Did he actually get hit?
	JRZ	BEC_DEAD			;BR= No

*
* A2 = Ptr to player that killed us
* A8 = Ptr to head part of object
*
BZERK_GEN_COLL
	MOVE	A2,*A8(OPLAYER),L

	MOVE	*A8(OFLAGS),A9,W
	BTST	B_DEAD,A9
	JRNZ	BEC_DEAD			;BR = He is already dead

	MOVE	*A8(OEFLAGS),A6,W
	
	SOUND1	SND_BZERK_EXPLODE
*
* This is a generic Berzerker death entrypoint
* Note: NOTHING SHOULD BE PUSHED!
* A5 = Ptr to accompanying explosion, 0 means there isn't one
* A6 = EFLAGS
* A8 = Ptr to head part of cog
* A9 = OFLAGS
* *A8(OPLAYER),L = Ptr to player that killed us
*
BZERK_DO_DEATH
	ORI	M_DEAD,A9
	MOVE	A9,*A8(OFLAGS),W

	MOVI	DMAWNZ&(~DMAGO),A1
	CALLA	OBJ_DRAWBITS_MULTI
	
	MOVI	1000,A1
	CALLA	SCORE
	CALLA	COUNT_PLAYER_KILL

	MOVE	*A8(ODEATH_ANIM),A1,L
	.IF DEBUG
	LOCKON	Z
	.ENDIF

;	MOVE	A5,A5
;	jrnz	BEC_Explosion
*
* This is the bullet death thing
*
;BEC_SHORT_DEATH
	RANDENT	TAB_DEATH_SNDS,NUM_DEATH_SNDS,5,L
	CALLA	ONESND_Z			;Give us a ding

	MOVIM	-20000H,*A8(OYVEL),L	;SEND HIM UP
	MOVIM	4000H,*A8(OYACCEL),W	;AND MAKE HIM COME DOWN
	MOVI	SHORT_DEATH_ZVEL,A14
	MOVE	A14,*A8(OZVEL),L	;AND MAKE HIM GET BLOWN BACK
;	jruc	BEC_Death_Anim
;BEC_Explosion
;	SOUNDZ	SND_DEATH_LONG
;;	SOUNDZ	SND_ROCKET_HIT
;	MOVIM	-40000H,*A8(OYVEL),L	;SEND HIM UP
;	MOVIM	4000H,*A8(OYACCEL),W	;AND MAKE HIM COME DOWN
;	MOVI	LONG_DEATH_ZVEL,A14
;	MOVE	A14,*A8(OZVEL),L	;AND MAKE HIM GET BLOWN BACK
;	MOVE	A14,*A5(OZVEL),L	;AND HIS LITTLE DOG TOO
;BEC_Death_Anim
	MOVE	A1,*A8(AnimFrm),L
	CLR	A14
	MOVB	A14,*A8(AnimSlp)
BEC_DEAD
	RETS

**************************************************************************
*								         *
*  		Anim funcs for the Berzerker				 *
*								         *
**************************************************************************

**************************************************************************
*								         *
* 	A_VELOCITY_WATCH						 *
* 									 *
* 	Anim func to watch velocities and boundries and such.		 *
* 	Should be called every tick					 *
* 									 *
* 	A8 = Ptr to any part						 *
*								         *
**************************************************************************
A_VELOCITY_WATCH
	CALLA	GET_HEAD_PART

	MOVE	*A8(OXVEL),A5,L
	MOVE	*A8(OZVEL),A6,L

	MOVE	*A8(OXACCEL),A7,W

	MOVE	*A8(OHRUN_DURATION),A14,W
	JRZ	AVW_NO_TARGET		 ;BR = We are not running to a target
	DEC	A14
	MOVE	A14,*A8(OHRUN_DURATION),W
	JRZ	AVW_DO_HEADON_STOP

AVW_NO_TARGET
	MOVE	*A8(OCTRL),A14,W
	BTST	B_FLIPH,A14		;Are we flipped
	JRZ	AVW_NOFLIP

*
* This is the flipped case
*

	NEG	A7			;Handle acceleration backwards during flip
	JRZ	AVW_CHECK_Z		;BR = No accel to worry	about

	ADD	A7,A5			;Add the acceleration

	MOVE	*A8(OSRUNVEL),A2,L
	NEG	A2

	CMP	A2,A5			;Did we max out?
	JRGE	AVW_STUFF_X		;BR = No
	JRUC	AVW_CHECK_Z

*
* This is the unflipped case
*
AVW_NOFLIP
	MOVE	A7,A7
	JRZ	AVW_CHECK_Z		;BR = No acceleration, no worry

	ADD	A7,A5			;Add the acceleration

	MOVE	*A8(OSRUNVEL),A2,L

	CMP	A2,A5			;Did we max out?
	JRGT	AVW_CHECK_Z		;BR = No
	
AVW_STUFF_X
	MOVE	A5,*A8(OXVEL),L		;Stuff that velocity

*
* Now we do Z
*
AVW_CHECK_Z
	MOVE	*A8(OZACCEL),A7,W
	ADD	A7,A6
	MOVE	A6,*A8(OZVEL),L

	RETS

*
* Here we will stop and do the proper shoot/throw animation
*
AVW_DO_HEADON_STOP
	MOVE	*A8(OFLAGS),A14,W
	BTST	B_DEAD,A14
	JRZ	AVW_STOP_GO		;BR = He's not dead, O.K. to stop
	RETS
AVW_STOP_GO
	CALLA	CLR_VEL			;Stop the show
	CLR	A14
	MOVE	A14,*A8(OXACCEL),W
	MOVE	A14,*A8(OZACCEL),W

	MOVE	*A8(OSHOOT_ANIM),A1,L
	JAUC	STRT_ANIM		;Do whatever it is that you do

**************************************************************************
*								         *
* 	A_SCREEN_CK							 *
* 									 *
* 	Anim func to check if any guy is off the screen period.		 *
* 	If he is, then delete him.					 *
* 									 *
* 	A8 = Ptr to any part						 *
*								         *
**************************************************************************
A_SCREEN_CK
	CALLA	GET_HEAD_PART

;	MOVE	*A8(OZVAL),A2,L
;	move	@ZBASE,a14,L
;	sub	a14,a2
;	CMPI	ZMAX_REAL,A2
;	JALT	DEL_ENEMY_NOAUD		;BR = Enemy too far forward

	CALLA	SCRTST
	JANZ	DEL_ENEMY_NOAUD

	RETS

**************************************************************************
*								         *
* A_STAND_RAPIDFIRE_DECISION - Anim Function to decide if we should fire *
* 				again quickly.				 *
* A8 = PTR TO FIRING PART						 *
* AARG+,L = ANIM BRANCH IF WE SHOULD FIRE AGAIN				 *
*								         *
**************************************************************************
A_STAND_RAPIDFIRE_DECISION
	MOVB	*A8(ORAPIDCNT),A14
	DEC	A14
	MOVB	A14,*A8(ORAPIDCNT)
	JANZ	SetAnim_AFARG
	RETS

**************************************************************************
*								         *
* A_STAND_FIRE_DECISION - Anim Function to decide if we should fire	 *
* 				again.					 *
* A8 = PTR TO FIRING PART						 *
* AARG+,L = ANIM BRANCH IF WE SHOULD FIRE AGAIN				 *
*								         *
**************************************************************************
A_STAND_FIRE_DECISION
	MOVB	*A8(OMISSES),A14
	JRNZ	ASFD_X			;BR = We've been missing our target

	MOVB	*A8(OBURSTCNT),A14
	DEC	A14
	MOVB	A14,*A8(OBURSTCNT)
	JANZ	SetAnim_AFARG
ASFD_X
	RETS

**************************************************************************
*								         *
* A_INITIALIZE_FIRING - DO ANY FIRING VARIABLE INITIALIZATION THAT	 *
* 			MIGHT BE NECESSARY.				 *
* A8 = PTR TO PART DOING THE FIRING					 *
*								         *
**************************************************************************
A_INITIALIZE_FIRING
	CALLA	GET_HEAD_PART
	CLR	A14
	MOVB	A14,*A8(OMISSES)
	RETS

**************************************************************************
*								         *
* 	A_FIRE_FNC							 *
* 									 *
* 	Anim func for normal part gun fire.				 *
* 									 *
* 	A8 = Ptr to part firing						 *
* 	AARG+,L = [Y,X] firing offset					 *
* 	AARG+,L = [INT,FRAC] hit points to take				 *
*								         *
**************************************************************************
A_FIRE_FNC
	CALLA	GET_HEAD_PART_A0
	MOVE	A0,A9  				;Everything is in his head

	MOVE	*A8(OFLAGS),A14,W
	BTST	B_DEAD,A14
	JRNZ	AFF_X				;BR = He is already dead

	move	*a8(OZVAL),a14,L		; Don't shoot if you're
	move	@ZBASE,a3,L			; offscreen in Z
	sub	a3,a14
	cmpi	ZMAX_REAL,a14
	jrlt	AFF_X

	CALLA	GETAFARG_LONG			;Get the firing offset
	MOVE	A0,A3

;	CALLA	GETAFARG_LONG			;And the hit points
;	MOVE	A0,A5

	MOVE	@BASE_HIT,A5,W
	ADDI	800H,A5
	SLL	4,A5

	CALLA	EGUN_FLASH_MULTI		;Make a flash


	MOVE	@ENEMY_HITALL,A14,W
	JRZ	AFF_CK_PLAYER			;BR = Check player by player
	DEC	A14
	JRZ	AFF_HITALL			;BR = Hit everyboy
	CLR	A5				;No Damage

AFF_CK_PLAYER
	CALLA	CK_PLAYER_HIT
	JRNZ	AFF_HIT			;BR = Successful hit on Player(s)
	JRNC	AFF_NOHIT		;BR = No hit, but he was visible
 	jruc	AFF_NOHIT_No_Sound	;He did'nt hit because he was not visible
AFF_HITALL
	ALLPLYR	PLAYER_HIT			;Hit every player
AFF_HIT
	CLRB	*A9(OMISSES)			;We did not miss
	SOUNDZ	SND_BZERK_FIRE
	JRUC	AFF_X
AFF_NOHIT
	SOUNDZ	SND_BZERK_FIRE
AFF_NOHIT_No_Sound
	MOVB	*A9(OMISSES),A14
	INC	A14  				;Knock the miss count
	MOVB	A14,*A9(OMISSES)
AFF_X
	RETS

**************************************************************************
*								         *
* A_FACE_CLR_VEL - Anim Function to mark enemy as head-on and clear	 *
* 		it's velocity.						 *
* A8 = Ptr to object							 *
*								         *
**************************************************************************
A_FACE_CLR_VEL
	CALLA	GET_HEAD_PART
	MOVIM	HEADON_DEATH_ANIM,*A8(ODEATH_ANIM),L
	MOVIM	HEADON_SHOOT_ANIM,*A8(OSHOOT_ANIM),L
	CALLA	A_CLR_ALL_X
	JAUC	A_CLR_ALL_Z

NUM_WX	.EQU	16
	.BSS	WORLDX_ARRAY,NUM_WX*16

**************************************************************************
*								         *
* 	A_CALC_HEADON_TARGET						 *
* 									 *
* 	Anim func to pick a target point and calculate the numbers	 *
* 	to get there.							 *
* 									 *
* 	A8 = Ptr to head part						 *
*								         *
**************************************************************************
A_CALC_HEADON_TARGET
	MOVI	WORLDX_ARRAY,A3
	MOVE	A3,A7			;Store here for second trip through
	CLR	A4			;This is our array count
	MOVK	NUM_WX,A5
	MOVE	@XBASE+16,A6,W

	MOVE	A8,A9			;Keep the object here

	MOVI	OID_BZERK,A0
	CALLA	EXIST_OBJ_ALL		;Load array with all World X's
	JRZ	ACHT_GET_PT		;BR = No others exist
ACHT_WX_LOOP
	MOVE	*A8(OPART1),A14,L
	CMP	A14,A8
	JRNE	ACHT_NEXT_WX		;BR = This is not the head

	CMP	A8,A9
	JREQ	ACHT_NEXT_WX		;BR = This is us

	MOVE	*A8(OXPOS),A14,W
	SUB	A6,A14			;Universe to World X
	MOVE	A14,*A3+,W
	INC	A4
	DEC	A5
	JRZ	ACHT_GET_PT		;BR = We ran out of storage

ACHT_NEXT_WX	
	CALLA	RESUME_EXIST_OBJ_ALL
	JRNZ	ACHT_WX_LOOP

ACHT_GET_PT
	MOVK	10,A5			;We can only try this many times
ACHT_RAND_WX_LOOP
	MOVI	90,A0
	CALLA	SRAND			;Get a prospective value

	MOVE	A4,A6
	JRZ	ACHT_GOT_WX		;BR = Nothing in the array

	MOVE	A7,A3

	MOVE	A0,A1
	MOVE	A0,A2
	SUBK	20,A1
	ADDK	20,A2			;We gots da range now

ACHT_FIND_WX_LOOP
	MOVE	*A3+,A14
	CMP	A1,A14
	JRLT	ACHT_TRY_NEXT
	CMP	A2,A14
	JRGT	ACHT_TRY_NEXT
	DSJS	A5,ACHT_RAND_WX_LOOP	;BR = Time to get yet another candidate
	JRUC	ACHT_GOT_WX		;We've wasted too much time, just use it

ACHT_TRY_NEXT
	DSJS	A6,ACHT_FIND_WX_LOOP
	
ACHT_GOT_WX
	MOVE	A9,A8			;Restore object ptr

	MOVE	A0,A5			;This is our world X target
	SLL	16,A5

	MOVI	9000H,A0
	MOVI	8000H,A1
	CALLA	RANGERND

	MOVE	A0,A7			;This is our world Z target

	MOVE	*A8(OZVAL),A1,L
	MOVE	@ZBASE,A14,L
	SUB	A14,A1			;Universe to World Z

	MOVE	*A8(OXVAL),A3,L
	MOVE	@XBASE,A14,L
	SUB	A14,A3			;Universe to World X

	SUB	A7,A1			;Get the Z distance to travel
	ABS	A1

	MOVE	*A8(OHRUNVEL),A2,L
	MOVE	A2,*A8(OZVEL),L
	ABS	A2
	
	DIVU	A2,A1			;Get the duration, in ticks.

	SUB	A3,A5			;Now what the hell for X target

	DIVS	A1,A5			;Get the proper XVEL

	MOVE	A5,*A8(OXVEL),L		;Make him get there

	MOVE	A1,*A8(OHRUN_DURATION),L

	RETS
	
**************************************************************************
*								         *
* 	A_THROW_OR_RUN							 *
* 									 *
* 	Anim func to determine what should be done, now that		 *
* 	the berzerker has the axe over his head.  If he is		 *
* 	far away, then he will target a point and run at the		 *
* 	screen.  If he is close, then he will just throw the		 *
* 	thing.								 *
* 									 *
* 	A8 = Ptr to Berzerker head object				 *
*								         *
**************************************************************************
A_THROW_OR_RUN
	move	@WAVE,a14
	cmpk	6+DEBUG,a14
	jrge	ATOR_THROW

	MOVE	*A8(OZVAL),A1,L
	MOVE	@ZBASE,A14,L
	SUB	A14,A1			;Universe to World Z

	CMPI	09800H,A1
	JRGT	ATOR_RUN		;BR = Too far, needs to run closer
ATOR_THROW:

	MOVI	HEADON_THROW_ANIM,A1
	JAUC	SetAnim

ATOR_RUN
	MOVI	HEADON_CRAZY_RUN_ANIM,A1
	JAUC	SetAnim
	
**************************************************************************
*								         *
* 	A_JUMP_OFF_CK							 *
* 									 *
* 	Anim func to check if we should jump off of the screen.		 *
* 									 *
* 	A8 = Ptr to any part						 *
*								         *
**************************************************************************
A_JUMP_OFF_CK
	CALLA	GET_HEAD_PART
	MOVB	*A8(OMISSES),A14
	JRNZ	AJOC_JUMP		;BR = We've been missing our target

	MOVI	OID_BZERK,A0
	CALLA	GET_ENEMY_COUNT
	CMPK	4,A0
	JRHI	AJOC_JUMP		;BR = Too many berzerkers spoils the broth

	RETS

AJOC_JUMP
	MOVE	*A8(OEFLAGS),A14,W
	BTST	B_STAYPUT,A14
	JRZ	AJOC_JUMP_JUMP		;BR = We are not inclined to stay

	RETS

AJOC_JUMP_JUMP
	MOVI	ANIM_JUMP_OFF,A1
	JAUC	SetAnim

**************************************************************************
*								         *
* 	A_STAY_TIL_ZBASE						 *
* 									 *
* 	Anim func to wait here until ZBASE is greater than what		 *
* 	is stored in *A8(OGUARD_STARTZ),W.  Value is >> 4.		 *
* 									 *
* 	A8 = Ptr to any part						 *
*								         *
**************************************************************************
A_STAY_TIL_ZBASE
	CALLA	GET_HEAD_PART
	MOVE	*A8(OGUARD_STARTZ),A2,W
	JRZ	ASTZ_X			;BR = No value to check
	SLL	4,A2
	MOVE	@ZBASE,A14,L
	CMP	A2,A14
	JRGT	ASTZ_X			;BR = We have surpassed our target

	SUBIM	50H,*A8(AnimFrm),L	;Back to the hoes

	JRUC	A_SCREEN_CK		;Check if we are on screen
ASTZ_X
	RETS

**************************************************************************
*								         *
* 	A_DEC_STAY_TIL_ZERO						 *
* 									 *
* 	Anim func to decrement a given word value at some offset	 *
* 	into the head part of a multi-parter.				 *
* 									 *
* 	A8 = Ptr to any part						 *
* 	AARG+,W = Variable offset					 *
*								         *
**************************************************************************
A_DEC_STAY_TIL_ZERO
	CALLA	GETAFARG_WORD
	CALLA	GET_HEAD_PART

	ADD	A8,A0
	MOVE	*A0,A14,W
	JRZ	ADSTZ_X
	DEC	A14
	MOVE	A14,*A0,W
	JRZ	ADSTZ_X

	SUBIM	60H,*A8(AnimFrm),L	;Back to where we were

ADSTZ_X
	RETS	

**************************************************************************
*								         *
* 	A_INCREASE_ROPE_OXVEL						 *
* 									 *
* 	Anim func to increase the OXVEL of the rope.			 *
* 									 *
* 	A8 = Ptr to head part						 *
* 	AARG+,L =  Amount to increase					 *
*								         *
**************************************************************************
A_INCREASE_ROPE_OXVEL
	CALLA	GETAFARG_LONG
	MOVE	*A8(OCTRL),A14,W
	BTST	B_FLIPH,A14
	JRNZ	AIRO_ADD_IT		;BR = Rope is flipped
	NEG	A0			;The rope is backwards
AIRO_ADD_IT
	ADDRM	A0,*A8(OXVEL),L
	RETS

**************************************************************************
*								         *
* 		LET'S GET DOWN AND DATA!				 *
*								         *
**************************************************************************

	.DATA

*
*SOME SOUNDS FOR YOU
*
NUM_HIT_SNDS	.EQU	2
TAB_HIT_SNDS
	.LONG	SND_HIT1, SND_HIT2
SND_HIT1
	.WORD	0F102H,23,0A46CH,0	;Metal hit
SND_HIT2
	.WORD	0F102H,20,0A46FH,0	;Metal hit

SND_BODY_HIT
	.WORD	0F102H,26,0A1CFH,0	;Bullet hits his body

NUM_DEATH_SNDS .EQU	2
TAB_DEATH_SNDS
	.LONG	SND_DEATH1, SND_DEATH2
SND_DEATH1
	.WORD	0F342H,46,0A474H,0
SND_DEATH2
	.WORD	0F342H,41,0A477H,0

SND_BZERK_EXPLODE
	.WORD	0F142H,60,0A38BH,0	;Explosion used by much

SND_CRAZY_RUN
	.WORD	0F342H,64,0A468H,0

SND_GROUND_HIT
	.WORD	0F330H,26,0A1D1H,0

SND_JUMP_LAND
	.WORD	0F330H,26,0A1D1H,0

;SND_ROCKET_HIT
;	.WORD	0F330H,52,0A341H,0

SND_BZERK_FIRE
	.WORD	0F305H,25,0A10BH,0	;Berzerker fire sound
SND_BZERK_THROW
	.WORD	0F142H,30,0A469H,0

*
* Object initialization table for the Berzerker
*
BZERK_INIT
	.byte	 4, 0, 1, 0	;OBJCNT, PRCCNT, IMGPALCNT, PALCNT
	.long	ZT1STX_A1	;IMGPAL
	.word	OID_BZERK, OM_COLL
	.LONG	BZERK_CVECT
*
*    .long	IMG
*    .word 		  OCTRL,  OFLAGS,   OZOFF, OPTION_FLAGS
*
NUM_LEGS .EQU	1
	LWWWW	ZL1STX_A1, DMAWNZ, M_NODISP,	0, OM_GUNV
	.LONG	BZERK_GUNVECT
NUM_TORSO .EQU	2
	LWWWW	ZT1STX_A1, DMAWNZ, M_NODISP,    -1, OM_ANIM|OM_PRVGUNV
	.LONG	ANIM_VELOCITY_WATCH
	LWWWW	ZH1STX_A1, DMAWNZ, M_NODISP,    -2, OM_PRVGUNV
	LWWWW	ZT1STX_A1, DMAWNZ, M_NODISP,    -1, OM_PRVGUNV


*
*Animation script to keep tabs on the velocity and movement boundries
*
ANIM_VELOCITY_WATCH
	LWL	1,1|AFunc,A_VELOCITY_WATCH
	.LONG	0

HEADON_CRAZY_RUN_ANIM
	LWL	1,1|AMulti|AFunc,A_CALC_HEADON_TARGET
	LWLL	1,1|AFunc,A_SOUND+2,SND_CRAZY_RUN

HCRA_LOOP
	LW	ZL1RN_A1,1|AMulti
	LW	ZT1RNX_A1,1|AMulti
	LWL	1,1|AMulti|AFunc,OBJ_OFF
	LWL	1,3|AFunc,OBJ_OFF

	LW	ZL1RN_A2,1|AMulti
	LW	ZT1RNX_A2,3

	LW	ZL1RN_A3,1|AMulti
	LW	ZT1RNX_A3,3

	LW	ZL1RN_A4,1|AMulti
	LW	ZT1RNX_A4,3

	LW	ZL1RN_A5,1|AMulti
	LW	ZT1RNX_A5,3
	
	LW	ZL1RN_A6,1|AMulti
	LW	ZT1RNX_A6,3

	LW	ZL1RN_A7,1|AMulti
	LW	ZT1RNX_A1_a,3

	LW	ZL1RN_A8,1|AMulti
	LW	ZT1RNX_A2_a,3

	LW	ZL1RN_A9,1|AMulti
	LW	ZT1RNX_A3,3

	LW	ZL1RN_A10,1|AMulti
	LW	ZT1RNX_A4_a,3

	LWLL	ZL1RN_A11,1|AMulti|AFunc,A_AnimFrm+2,HCRA_LOOP
	LWL	ZT1RNX_A6_a,3|AFunc,A_SCREEN_CK

*
* Throw axe, starting from hands over head
*
HEADON_THROW_ANIM
	LW	ZL1OT_A9,1|AMulti
	LW	ZT1OT_A9,1|AMulti
	LWL	1,1|AMulti|AFunc,OBJ_OFF
	LWL	1,3|AFunc,OBJ_OFF

	LW	ZL1OT_A10,1|AMulti
	LW	ZT1OT_A10,1|AMulti
	LWL	ZA1OT_A10,3|AFunc,OBJ_ON

	LWLLWW	ZL1OT_A11,1|AMulti|AFunc,A_SPAWN_PROJECTILE+4,AXE_INIT,-3,-99
	LWLL	ZT1OT_A11,1|AMulti|AFunc,A_SOUND+2,SND_BZERK_THROW
	LW	ZH1OT_A11,3

	LW	ZL1OT_A13,1|AMulti
	LW	ZT1OT_A13,1|AMulti
	LWL	1,3|AFunc,OBJ_OFF

	LW	ZL1OT_A14,1|AMulti
	LW	ZT1OT_A14,25

	LW	ZL1OT_A13,1|AMulti
	LW	ZT1OT_A13,4

	LW	ZL1STX_A1,1|AMulti
	LW	ZT1STX_A1,1|AMulti
	LWL	ZH1STX_A1,50|AFunc,OBJ_ON

	LW	ZL1G_A2,1|AMulti
	LW	ZT1G_A2,1|AMulti
	LW	ZH1G_A2,5

	LW	ZL1G_A4,1|AMulti
	LW	ZT1G_A4,1|AMulti
	LW	ZH1G_A4,5

	LW	ZB1G_A5,1|AMulti
	LW	ZH1G_A5,1|AMulti
	LWL	1,5|AFunc,OBJ_OFF

	LW	ZL1G_A6,1|AMulti
	LW	ZT1G_A6,1|AMulti
	LWL	ZH1G_A6,1|AMulti|AFunc,OBJ_ON
	LWL	ZA1G_A6,5|AFunc,OBJ_ON

	LW	ZL1G_A8,1|AMulti
	LW	ZT1G_A8,1|AMulti
	LW	ZH1G_A8,1|AMulti
	LWL	1,5|AFunc,OBJ_OFF

	LWLL	ZL1ST_A1,1|AMulti|AFunc,A_AnimGo+2,ANIM_STRUM_SHOOT
	LW	ZT1ST_A1,1|AMulti
	LW	ZH1ST_A1,1|AMulti
	LWL	ZA1ST_A1,30|AFunc,OBJ_ON

*
* Jam on the guitar
*
;ANIM_JAM
;	LWLWWW	ZB1JAM_A1,1|AMulti|AFunc,A_RAND_REL_BYTE+3,2,4,AnimLoop
;	LW	ZA1JAM_A1,1|AMulti
;	LW	ZH1JAM_A1,1|AMulti
;	LWL	1,6|AFunc,OBJ_OFF

;ANIM_JAM_LOOP
;	LW	ZB1JAM_A2,1|AMulti
;	LW	ZA1JAM_A2,1|AMulti
;	LW	ZH1JAM_A2,6

;	LW	ZB1JAM_A3,1|AMulti
;	LW	ZA1JAM_A3,1|AMulti
;	LW	ZH1JAM_A3,6

;	LW	ZB1JAM_A4,1|AMulti
;	LW	ZA1JAM_A4,1|AMulti
;	LW	ZH1JAM_A4,6

;	LW	ZB1JAM_A5,1|AMulti
;	LW	ZA1JAM_A5,1|AMulti
;	LW	ZH1JAM_A5,6

;	LW	ZB1JAM_A6,1|AMulti
;	LW	ZH1JAM_A6,1|AMulti
;	LWL	1,6|AFunc,OBJ_OFF

;	LW	ZL1JAM_A7,1|AMulti
;	LW	ZT1JAM_A7,1|AMulti
;	LWL	ZH1JAM_A7,6|AFunc,OBJ_ON

;	LWLL	ZB1JAM_A1,1|AMulti|AFunc,A_Anim_DSJ+2,ANIM_JAM_LOOP
;	LW	ZA1JAM_A1,1|AMulti
;	LW	ZH1JAM_A1,6

;	LWL	1,1|AFunc,A_SCREEN_CK

*
* Do a Pete Townsend and fire that crazy guitar
*
ANIM_STRUM_SHOOT
	LW	ZB1PLTR_A2,1|AMulti
	LW	ZH1PLTR_A2,1|AMulti
	LWL	1,1|AMulti|AFunc,OBJ_OFF
	LWL	1,6|AFunc,OBJ_OFF

	LWLWWW	ZL1PL_A1,1|AMulti|AFunc,A_RAND_REL_BYTE+3,3,7,ORAPIDCNT
	LW	ZT1PL_A1,1|AMulti
	LWL	ZH1PL_A1,4|AFunc,OBJ_ON
	
	LWL	ZL1PL_A2,1|AMulti|AFunc,A_INITIALIZE_FIRING
	LW	ZT1PL_A2,1|AMulti
	LW	ZH1PL_A2,4

ANIM_STRUM_LOOP
	LW	ZL1PL_A3,1|AMulti
	LW	ZT1PL_A3,1|AMulti
	LW	ZH1PL_A3,4

	LW	ZL1PL_A4,1|AMulti
	LW	ZT1PL_A4,1|AMulti
	LW	ZH1PL_A4,1|AMulti
	LWL	ZA1PL_A4,4|AFunc,OBJ_ON

	LW	ZL1PL_A5,1|AMulti
	LW	ZT1PL_A5,1|AMulti
	LW	ZH1PL_A5,1|AMulti
	LW	ZA1PL_A5,4

	LW	ZL1PL_A6,1|AMulti
	LW	ZT1PL_A6,1|AMulti
	LW	ZH1PL_A6,1|AMulti
	LWL	1,4|AFunc,OBJ_OFF

	LW	ZL1PL_A7,1|AMulti
	LW	ZT1PL_A7,1|AMulti
	LW	ZH1PL_A7,4

	LW	ZL1PL_A8,1|AMulti
	LW	ZT1PL_A8,1|AMulti
	LW	ZH1PL_A8,4

	LW	1,1|AMulti
	LWLWW	1,1|AFunc,A_FIRE_FNC+2,-10,-74

	LWLL	ZL1PLSH_A9,1|AMulti|AFunc,A_CHANGE_PAL+2,P_GXZERS
	LWLL	ZT1PLSH_A9,1|AMulti|AFunc,A_CHANGE_PAL+2,P_GXZERS
	LWLL	ZH1PLSH_A9,3|AFunc,A_CHANGE_PAL+2,P_GXZERS

	LWLL	ZL1PL_A2,1|AMulti|AFunc,A_CHANGE_PAL+2,P_GXZERK
	LWLL	ZT1PL_A2,1|AMulti|AFunc,A_CHANGE_PAL+2,P_GXZERK
	LWLL	ZH1PL_A2,3|AFunc,A_CHANGE_PAL+2,P_GXZERK

	LWLL	1,1|AFunc,A_STAND_RAPIDFIRE_DECISION+2,ANIM_STRUM_LOOP

	LWL	1,1|AFunc,A_SCREEN_CK

	LWL	1,1|AFunc,A_JUMP_OFF_CK

*
* Pick that axe up over head
*
ANIM_OVERHEAD
	LW	ZL1OT_A1,1|AMulti
	LW	ZT1OT_A1,1|AMulti
	LWL	ZH1OT_A1,1|AMulti|AFunc,OBJ_ON
	LWL	ZA1OT_A1,6|AFunc,OBJ_ON
	
	LW	ZL1OT_A3,1|AMulti
	LW	ZT1OT_A3,1|AMulti
	LW	ZH1OT_A3,1|AMulti
	LW	ZA1OT_A3,6

	LW	ZL1OT_A5,1|AMulti
	LW	ZT1OT_A5,1|AMulti
	LWL	1,1|AMulti|AFunc,OBJ_OFF
	LWL	1,6|AFunc,OBJ_OFF

	LW	ZL1OT_A7,1|AMulti
	LW	ZT1OT_A7,1|AMulti
	LWL	ZH1OT_A7,1|AMulti|AFunc,OBJ_ON
	LWL	ZA1OT_A7,4|AFunc,OBJ_ON

	LWL	1,1|AFunc,A_THROW_OR_RUN

*
* Jump from where you are, up and off the screen
*
ANIM_JUMP_OFF	
	LW	ZL1J_A8,1|AMulti
	LW	ZT1J_A8,1|AMulti
	LW	ZH1J_A8,1|AMulti
	LWL	1,10|AFunc,OBJ_OFF

	LWLL	ZL1J_A2,1|AMulti|AFunc,A_SET_OYVEL+2,-80000H
	LW	ZT1J_A2,1|AMulti
	LW	ZH1J_A2,1|AMulti
	LWL	ZA1J_A2,3|AFunc,OBJ_ON

	LW	ZB1J_A6,1|AMulti
	LW	ZH1J_A6,1|AMulti
	LWL	1,1|AMulti|AFunc,OBJ_OFF
	LWL	1,3|AFunc,OBJ_OFF

	LW	ZL1J_A4,1|AMulti
	LW	ZT1J_A4,1|AMulti
	LW	ZH1J_A4,1|AMulti
	LWL	1,3|AFunc,OBJ_OFF

AJO_LOOP
	LWLL	1,10|AFunc,A_ONSCREEN+2,AJO_LOOP

	LWL	1,1|AFunc,DEL_ENEMY_NOAUD

*
* Jump from above to the ground.
*
ANIM_JUMP_ON
	LWLL	ZL1J_A4,1|AMulti|AFunc,A_SET_OYVEL+2,60000H
	LW	ZT1J_A4,1|AMulti
	LW	ZH1J_A4,1|AMulti
	LWL	1,1|AFunc,OBJ_OFF
	
AJO_WAIT
	LWLWL	1,1|AFunc,A_GROUND_CK+3,30,AJO_WAIT

	LW	ZB1J_A6,1|AMulti
	LW	ZH1J_A6,1|AMulti
	LWL	1,4|AFunc,OBJ_OFF

	LWL	ZL1J_A8,1|AMulti|AFunc,A_HIT_GROUND
	LWLL	ZT1J_A8,1|AMulti|AFunc,A_SOUNDZ+2,SND_JUMP_LAND
	LWL	ZH1J_A8,10|AFunc,OBJ_ON

	LWLL	ZL1ST_A1,1|AMulti|AFunc,A_AnimFrm+2,ANIM_OVERHEAD
	LW	ZT1ST_A1,1|AMulti
	LW	ZH1ST_A1,1|AMulti
	LWL	ZA1ST_A1,6|AFunc,OBJ_ON

*
* Stand guard and then bring up axe and run towards player
*
ANIM_GUARD
	LW	ZB1ST_A5,1|AMulti
	LW	ZH1ST_A5,1|AMulti
	LWL	1,1|AMulti|AFunc,OBJ_OFF
	LWL	1,6|AFunc,OBJ_OFF

	LWL	1,5|AFunc,A_STAY_TIL_ONSCRN

	LWL	1,5|AFunc,A_STAY_TIL_ZBASE

	LWLW	1,1|AFunc,A_DEC_STAY_TIL_ZERO+1,OGUARD_ATIME

	LW	ZL1ST_A6,1|AMulti
	LW	ZT1ST_A6,1|AMulti
	LWL	ZH1ST_A6,6|AFunc,OBJ_ON
	
	LWLL	ZL1ST_A7,1|AMulti|AFunc,A_AnimGo+2,ANIM_OVERHEAD
	LW	ZT1ST_A7,1|AMulti
	LW	ZH1ST_A7,1|AMulti
	LWL	ZA1ST_A7,6|AFunc,OBJ_ON

HEADON_STOP_ANIM
HEADON_SHOOT_ANIM

HEADON_DEATH_ANIM
	LWLL	ZL1DX_A2,1|AMulti|AFunc,A_CHANGE_PAL+2,P_GXZERK
	LWLL	ZT1DX_A2,1|AMulti|AFunc,A_CHANGE_PAL+2,P_GXZERK
	LWLL	ZA1DX_A2,1|AMulti|AFunc,A_OBJ_ON_CHANGE_PAL+2,P_GXZERK
	LWLL	ZH1DX_A2,4|AFunc,A_OBJ_ON_CHANGE_PAL+2,P_GXZERK

	LW	ZH1DX_A3,1|AMulti
	LW	ZT1DX_A3,1|AMulti
	LW	ZL1DX_A3,1|AMulti
	LW	ZA1DX_A3,4

	LW	ZH1DX_A4,1|AMulti
	LW	ZT1DX_A4,1|AMulti
	LW	ZL1DX_A4,1|AMulti
	LW	ZA1DX_A4,1

ROCKET_DEATH_GROUND_WAIT
	LWLWL	1,1|AFunc,A_GROUND_CK+3,0,ROCKET_DEATH_GROUND_WAIT

	LWL	ZH1DX_A5,1|AMulti|AFunc,A_HIT_GROUND
	LWLL	ZT1DX_A5,1|AMulti|AFunc,A_SOUNDZ+2,SND_GROUND_HIT
	LW	ZL1DX_A5,1|AMulti
	LWL	1,4|AFunc,OBJ_OFF


	LW	ZA1DX_A7,1|AMulti
	LWL	ZT1DX_A7,1|AMulti|AFunc,A_CLR_ALL_Z
	LWL	ZL1DX_A7,60|AFunc,A_CLR_ALL_X

	LWL	1,1|AFunc,DELETE_ENEMY

SIDE_DEATH_ANIM

**************************************************************************
*								         *
* 		Berzerker miscellany					 *
*								         *
**************************************************************************

	.IF	0
*
* Object initialization table for the Berzerker
*
ROPE_INIT
	.byte	 2, 0, 1, 0	;OBJCNT, PRCCNT, IMGPALCNT, PALCNT
	.long	ROPESEC01	;IMGPAL
	.word	OID_JUNK, OM_DUMCOLL
*
*    .long	IMG
*    .word 		  OCTRL,  OFLAGS,   OZOFF, OPTION_FLAGS
*
	LWWWW	ROPESEC07,	DMAWNZ,	M_NOSCALE,	0, OM_ANIM
	.LONG	ANIM_ROPE_SWING
	LWWWW	ROPESEC07b,	DMAWNZ, M_NOSCALE,	0, 0


ANIM_ROPE_SWING
	LW	1,5
ANIM_ROPE_LOOP
	LWLL	ROPESEC06,1|AMulti|AFunc,A_INCREASE_ROPE_OXVEL+2,08000H
	LW	ROPESEC06b,5

	LWLL	ROPESEC05,1|AMulti|AFunc,A_INCREASE_ROPE_OXVEL+2,08000H
	LW	ROPESEC05b,5

	LWLL	ROPESEC04,1|AMulti|AFunc,A_INCREASE_ROPE_OXVEL+2,08000H
	LW	ROPESEC04b,5

	LWLL	ROPESEC03,1|AMulti|AFunc,A_INCREASE_ROPE_OXVEL+2,08000H
	LW	ROPESEC03b,5

	LW	ROPESEC02,1|AMulti
	LW	ROPESEC02b,5

	LW	ROPESEC01,1|AMulti
	LW	ROPESEC01b,4

	LWLW	1,1|AFunc,A_TOGGLE_FLPS+1,M_FLIPH

	LW	ROPESEC02,1|AMulti
	LW	ROPESEC02b,5

	LW	ROPESEC03,1|AMulti
	LW	ROPESEC03b,6

	LW	ROPESEC04,1|AMulti
	LW	ROPESEC04b,7

	LWLL	ROPESEC05,1|AMulti|AFunc,A_INCREASE_ROPE_OXVEL+2,08000H
	LW	ROPESEC05b,8

	LWLL	ROPESEC06,1|AMulti|AFunc,A_INCREASE_ROPE_OXVEL+2,08000H
	LW	ROPESEC06b,9


	LWLL	ROPESEC07,1|AMulti|AFunc,A_INCREASE_ROPE_OXVEL+2,08000H
	LW	ROPESEC07b,5

	LWLL	1,4|AFunc,A_INCREASE_ROPE_OXVEL+2,08000H

	LWLL	1,1|AFunc,A_AnimGo+2,ANIM_ROPE_LOOP
	

	.ENDIF

	.ref  CURPLYR_ADJ,SCRL_DISPATCHER
	.def	S_CREATE_BZERKS
**************************************************************************
*								         *
* 	.LONG	S_CREATE_BZERKS						 *
*	 .word  how many		   			         *
*	 .word  how many ticks apart	   			         *
*	 .word  left world X, right world X				 *
*	 .long	close Z, far Z						 *
*								         *
**************************************************************************
S_CREATE_BZERKS:
	move	a11,a5
	move	*a5+,a0		; how many
	calla	CURPLYR_ADJ
	move	a0,a8		; adjusted number in a8
	move	*a5+,a3		; ticks between creations
	move	*a5+,a9,L	; x range
	move	*a5+,a10,L	; min Z
	move	*a5+,a2,L	; max Z
	sll	12,a2
	sra	4,a10
	movy	a2,a10
	movk	1,a11		; don't leave screen
SCBlp:
	CREATE	PID_BZERK,PROC_BZERK_JMP_WRLD
	mmtm	a12,a3,a5
	SLEEPR	a3
	mmfm	a12,a3,a5
	dsjs	a8,SCBlp

	move	a5,a11
	sleep	90
	jauc	SCRL_DISPATCHER




	.END

