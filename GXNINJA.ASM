 	.MLIB	"GXMACS.LIB"
	.FILE	"GXNINJA.ASM"
	.TITLE	"<<< GENERATION X -- Ninja enemy >>>"
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
	.INCLUDE	"GXNINJA.TBL"
	.INCLUDE	"GXNATV.H"

***** In this file

	.DEF	PROC_NINJA_JUMPIN, AU_CREATE_WALKWAY_NINJA
	.DEF	AU_CREATE_DESK_NINJA, AU_CREATE_SHUFFLE_NINJA
	.DEF	AU_CREATE_SIDE_NINJA, PROC_STONED_NINJA
	.DEF	AU_CREATE_SHUFFLE_NINJA_OPP, AU_CREATE_SIDE_NINJA_OPP

***** from GXRAM.ASM
	.REF	WAVETIME, CURPLYRS, HOLD_ENEMY_DISPATCH, ENEMY_HITALL
	.REF	OBJENEMIES, SOCRATES, RAND, NUM_NSTARS, ENEMY_QUOTA, WAVE
	.REF	LAB_RAT
	
***** from GXAFUNC.ASM
	.REF	A_SOUNDZ, SetAnim_AFARG, A_SET_OYVEL, A_RAND_REL_BYTE
	.REF	A_Anim_DSJ, SetAnim, A_SOUND, A_STAY_TIL_ONSCRN
	.REF	A_SET_OXVEL, A_PreFrag_Center, A_INIT_AnimSLP
	.REF	A_TOGGLE_FLIP, A_STAY_TIL_OFFSCRN

***** from GXSND.ASM
	.REF	ONESND_Z, ONESND

***** from GXD.ASM
	.REF	GET_SHAD_MULTI, SET_ANIPU, XBASE, ZBASE, GETHEADPART, YBASE
	.REF	EXIST_OBJ_ALL, RESUME_EXIST_OBJ_ALL, SET_SCRN_POS
	.REF	SET_OBJSU, YWORLD, REPOS_OBJ, ZREL_OFF, XSCROLL, YHALF
	.REF	ZSCROLL, WORLD_GRNDOFF, SET_ANIPYU

***** from GXENEMY.ASM
	.REF	INSERT_ENEMY, CREATE_ENEMY, DEL_ENEMY_NOAUD, DELETE_ENEMY
	.REF	EGUN_FLASH_MULTI

***** from GXPLAYER.ASM
	.REF	CK_PLAYER_HIT, PLAYER_HIT

***** from GXCOG.ASM
	.REF	HIT_ENEMY, A_CLR_ALL_X, A_CLR_ALL_Z, OBJ_DRAWBITS_MULTI
	.REF	STORE_OCONST

***** from GXMONDR2.ASM
	.REF	A_SPAWN_PROJECTILE, NSTAR_INIT

***** from GXBLOOD.ASM
	.REF	BLOODY_BULLET_HIT, A_BLOOD_SPLORCH, A_SBOMB_BLOOD
	.REF	BIGBOY_ROCKET_BLOOD

***** from GXCONTRL.ASM
	.REF	ENEMYP_COLL

***** from GXNONBOY.ASM
	.REF	N_CHUNK

***** from GXUNIJP2.ASM
	.REF	WHAREA, ROW_PARMS_TABLE

***** from GXUTIL.ASM
	.REF	SET_VECTORS

***** from GXBUG.ASM
	.REF	SET_OCONST

*
* Ninja RAM
*
	.BSS	NINJA_POPS,16

	.BSS	BIG_LIST,16*3		;BIGBOY PICK LIST

	.TEXT


* Ninja Object data area
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
B_FOLLOW	EQU	8		;Follow the scroll
B_FLY_IN	EQU	9		;Fly in from the side
B_OPP_FLIP	EQU	10		;Flip opposite the enemy generator


M_SIDE		EQU	001H
M_BRIDGE	EQU	002H
M_JUMP_IN	EQU	004H
M_STAYPUT	EQU	008H
M_FLIP		EQU	010H
M_GUARD		EQU	020H
M_BLOCKING	EQU	040H
M_INVINCIBLE	EQU	080H
M_FOLLOW	EQU	0100H		
M_FLY_IN 	EQU	0200H
M_OPP_FLIP	EQU	0400H

HRUNVEL	EQU	-0140H			;HEADON RUN VELOCITY
HRUNVEL_CRAZY	.EQU	-280H		;Head on run for Crazy guy
SRUNVEL_MIN	EQU	01D000H		;SIDE RUN (TO THE RIGHT) VELOCITY 
SRUNVEL_MAX	EQU	01F000H		;SIDE RUN (TO THE RIGHT) VELOCITY 

JUMP_MIN_YVEL	.EQU	08000H		;Absolute jumping velocity

SHOOTCNT	EQU	3

NINJA_HITS_TO_KILL EQU	2		;HITS REQUIRED TO KILL NINJA

NINJA_FLASH_COLOR EQU	3E3EH		;FLASH COLOR FOR NINJA

SHORT_DEATH_ZVEL .EQU	1C0H
LONG_DEATH_ZVEL	 .EQU	2C0H

**************************************************************************
*								         *
* 	PROC_NINJA_HEADON_OFFSET					 *
* 									 *
* 	Process to create a head-on Ninja at an offset from		 *
* 	another object.							 *
* 									 *
* 	A8 = Object to offset from					 *
* 	A9 = [Y,X] offset						 *
* 	A11 = Z offset							 *
*								         *
**************************************************************************
PROC_NINJA_HEADON_OFFSET
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

	JRUC	PROC_NINJA_HEADON

**************************************************************************
*								         *
* 	PROC_NINJA_HEADON						 *
* 									 *
* 	Process to create a head-on Ninja.				 *
* 									 *
* 	A9  = Universe X						 *
* 	A10 = Universe Y						 *
* 	A11 = Universe Z						 *
*								         *
**************************************************************************
PROC_NINJA_HEADON
	CLR	A8			;Clear OFLAGS for headon
	JRUC	PROC_NINJA

**************************************************************************
*								         *
* 	PROC_NINJA_JUMPIN						 *
* 									 *
* 	Create a Ninja that jumps in from the top of the		 *
* 	screen.								 *
* 									 *
* 	A9 = [Univ X max >> 16, Univ X min >> 16]			 *
* 	A10 = [Univ Z max >> 8, Univ Z min >> 8] 			 *
*	A11 = Univ Y							 *
*								         *
**************************************************************************
PROC_NINJA_JUMPIN
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

	MOVE	A11,A10

	MOVE	A0,A11

	MOVE	@SOCRATES,A14,W
	JRNZ	PNJ_CRATES

	CLR	A8
	JRUC	PNJ_PICK_TYPE

PNJ_CRATES
	MOVI	512,A0
	CALLA	RANDPER
	JRNC	PNJ_PICK_TYPE		;BR = Not a follower
	MOVI	M_FOLLOW,A8		;Setup some flags
PNJ_PICK_TYPE
	MOVI	700,A0
	CALLA	RANDPER
	JRC	PNJ_JUMPER

	ORI	M_FLY_IN|M_SIDE,A8	;Make him the fly from side type

	MOVE	@RAND,A6,W
	ANDI	M_FLIPH,A6		;Random flip this guy

	JRUC	PROC_NINJA

PNJ_JUMPER
	ORI	M_JUMP_IN,A8
	JRUC	PROC_NINJA

**************************************************************************
*								         *
* 	PROC_NINJA_STAND						 *
* 									 *
* 	Create a Ninja that stands guard until ZBASE is			 *
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
PROC_NINJA_STAND
	MOVE	A8,A6
	MOVI	M_GUARD,A8
	JRUC	PROC_NINJA

**************************************************************************
*								         *
* 	PROC_NINJA							 *
* 									 *
* 	Process entry point to create a Ninja.				 *
* 									 *
* 	A6 = General purpose register, saved through Create		 *
* 	A8 = EFLAGS to denote Side or Headon				 *
* 	A9 = Universe X							 *
* 	A10 = Universe Y						 *
* 	A11 = Universe Z						 *
*								         *
**************************************************************************
PROC_NINJA
	MOVE	@HOLD_ENEMY_DISPATCH,A14,W
	JANE	SUCIDE

	MOVI	OID_NINJA,A0
	CALLA	GET_ENEMY_COUNT
	MOVK	5,A1
	MOVE	@CURPLYRS,A14,W
	ADD	A14,A1			;Adjust for amount of current players
	CMP	A1,A0
	JAHS	SUCIDE

	MMTM	SP,A6,A8
	MOVI	NINJA_INIT,B0
	CALLA	CREATE_ENEMY
	MMFM	SP,A6,A7		;Preserve status please
	JRZ	PBH_EXIT		;BR = Could not create the dude

	MOVI	SRUNVEL_MAX,A0
	MOVI	SRUNVEL_MIN,A1
	CALLA	RANGRAND
	MOVE	A0,*A8(OSRUNVEL),L	;SET SIDE VELOCITY

	MOVIM	HRUNVEL,*A8(OHRUNVEL),L	;Set the headon velocity

	MOVE	A11,A3

	MOVE	@ZREL_OFF,A14,L
	SRA	ZFRAC,A14
	ADD	A14,A3

	MOVE	A9,A1
	MOVE	A10,A2

	BTST	B_JUMP_IN,A7
	JRZ	PN_NOJUMPIN

;	MOVE	@YWORLD,A5,L
;	MOVE	@WORLD_GRNDOFF,A14,L
;	ADD	A14,A5

;	SUB	A5,A2
;	MOVE	A2,*A8(OGRNDOFF),L

	MOVK	10,A5
	NEG	A5
	STOUY	A3,A5	

	MOVE	A5,A2			;Set us off of the top of the screen
	JRUC	PN_POSITION

PN_NOJUMPIN
	BTST	B_FLY_IN,A7
	JRZ	PN_NOFLYIN

;	MOVE	@WORLD_GRNDOFF,A5,L
;	MOVE	@YWORLD,A14,L
;	ADD	A5,A14
;	MOVE	A2,A5
;	SUB	A14,A5
;	MOVE	A5,*A8(OGRNDOFF),L

	BTST	B_FLIPH,A6
	JRZ	PN_FLY_LEFT
	MOVI	460,A5
	JRUC	PN_FLY_CALC
PN_FLY_LEFT
	MOVI	-60,A5
PN_FLY_CALC
	STOUX	A3,A5	

	MOVE	A5,A1			;Set us off of the top of the screen
	JRUC	PN_POSITION

PN_NOFLYIN
PN_POSITION
	CALLA	SET_ANIPU		;Position him

	BTST	B_JUMP_IN,A7
	JRZ	PNA_NO_JUMP		;BR = This is not a jump in guy

	MOVI	ANIM_JUMP_ON,A1
	JRUC	PNA_LOAD_HEAD

PNA_NO_JUMP
	BTST	B_FLY_IN,A7
	JRZ	PNA_NO_FLY		;BR = This is not a jump in guy

	MOVI	ANIM_JUMP_SYDE,A1
	JRUC	PNA_LOAD_HEAD

PNA_NO_FLY
	BTST	B_GUARD,A7
	JRZ	PNA_RUNNING		;BR = This is not a guard guy

	MOVE	A6,*A8(OGUARD_STARTZ),L	;Save our starting ZBASE
	MOVI	ANIM_GUARD,A1
	JRUC	PNA_LOAD_HEAD
PNA_RUNNING
	MOVI	HEADON_HANDSPRING_ANIM,A1
PNA_LOAD_HEAD
	MOVIM	HEADON_DEATH_ANIM,*A8(ODEATH_ANIM),L
	MOVIM	HEADON_STOP_ANIM,*A8(OSTOP_ANIM),L
	MOVIM	HEADON_THROW_STAR_ANIM,*A8(OSHOOT_ANIM),L

PBH_DIRSET
	CALLA	STRT_ANIM		;START ANIMATION

	MOVE	A7,*A8(OEFLAGS),W

	BTST	B_SIDE,A7
	JRZ	PBH_NOSET
	MOVE	A6,A0	
	CALLA	SET_FLPS
PBH_NOSET

	MOVI	NINJA_FLASH_COLOR,A1
	CALLA	STORE_OCONST		;STORE THE PROPER VALUE FOR CONSTANT

	CALLA	OBJ_ON_MULTI		;We create with the objects off

	MOVE	@LAB_RAT,A14,W
	JRZ	PBH_YELPAL

	MOVI	NINBLU64,A0
	CALLA	CHANGE_PAL_MULTI

PBH_YELPAL
	CALLA	GET_SHAD_MULTI		;Setup his shadow

	CALLA	INSERT_ENEMY		;INSERT AND COUNT ENEMY
	JRUC	NINJA_WATCH

PBH_EXIT
	DIE

NINJA_WATCH
	MOVE	A13,*A8(OPLINK),L
NINJA_WATCH_LOOP
	SLOOP	7000H,NINJA_WATCH_LOOP	;Here we wait for shit to happen


**************************************************************************
*								         *
* 	Universe anim func to create a Ninja that will jump		 *
* 	onto a factory walkway. Direction is taken from H-flip of	 *
* 	generator.  Position is offset from generator position.		 *
* 									 *
* 	AARG+,W	= X offset						 *
* 	AARG+,W	= Y offset						 *
* 	AARG+,L = Bridge jump table					 *
*								         *
**************************************************************************
AU_CREATE_WALKWAY_NINJA
	MOVE	@OBJENEMIES,A14,W
	BTST	B_OF_WNINJA,A14
	JRZ	ACWN_ABORT		;BR = not allowed, yet
	
	MOVI	OID_NINJA,A0
	CALLA	GET_ENEMY_COUNT
	CMPK	3,A0
	JRHS	ACWN_ABORT		;BR = There are too many

	PUSH	A8
	MOVI	NINJA_INIT,B0		;Get us one
	CALLA	CREATE_ENEMY
	PULL	A2			;A2=obj block of creator, 
					;pull must preserve status.
	JRZ	ACWN_ABORT		;BR = Object not created.

	MOVI	SRUNVEL_MAX,A0
	MOVI	SRUNVEL_MIN,A1
	CALLA	RANGRAND
	MOVE	A0,*A8(OSRUNVEL),L	;SET SIDE VELOCITY

	MOVE	*A2(OCTRL),A14
	BTST	B_FLIPH,A14
	JRZ	ACWN_NOFLIP

	MOVI	M_FLIPH,A0	
	CALLA	SET_FLPS

ACWN_NOFLIP
*
*	set position
*
	MOVE	A8,A9
	MOVE	A2,A8

	CALLA	GETAFARG_LONG		; pixel Y:X in a0
	MOVE	A0,A4

	MOVE	*A8(OZVAL),A3,L
	ADDK	8,A3			;Hold Z for set

	MOVE	*A8(OXVAL),A1,L
	MOVE	*A8(OYVAL),A2,L
	MOVE	A4,A5			; do X and Y
	SEXT	A5
	SRA	16,A4
	SLL	15,A5
	SLL	15,A4
	ADD	A5,A1
	ADD	A4,A2

	CALLA	GETAFARG_LONG
	MOVE	A0,*A9(OJUMPTAB),L	;Load that jump table

	MOVE	A9,A8

	MOVE	@YWORLD,A14,L
	MOVE	A2,A4
	SUB	A14,A4
	MOVE	A4,*A8(OGRNDOFF),L

	MOVK	10,A7
	NEG	A7
	STOUY	A3,A7	

	MOVE	A7,A2			;Set us off of the top of the screen
;	SUBI	200 << 15, A2		;Offset for above screen

	CALLA	SET_ANIPU

	MOVIM	HEADON_DEATH_ANIM,*A8(ODEATH_ANIM),L
	CLRM	*A8(OSTOP_ANIM),L
	MOVIM	HEADON_THROW_STAR_ANIM,*A8(OSHOOT_ANIM),L

	MOVI	ANIM_JUMP_ON,A1
	CALLA	STRT_ANIM		;START ANIMATION

	MOVIM	M_SIDE|M_BRIDGE,*A8(OEFLAGS),W	;Give this enemy some personality

	CALLA	INSERT_ENEMY		;INSERT AND COUNT ENEMY

	MOVI	NINJA_FLASH_COLOR,A1
	CALLA	STORE_OCONST		;STORE THE PROPER VALUE FOR CONSTANT

	CREATE	PID_NINJA,NINJA_WATCH
	MOVE	A0,*A8(OPLINK),L

ACWN_ABORT
	RETS

**************************************************************************
*								         *
* 	AU_CREATE_DESK_NINJA						 *
* 									 *
* 	Universe anim func to create a Ninja that will jump		 *
* 	from behind a desk, over it, then attack.			 *
* 									 *
* 	AARG+,W = X offset						 *
* 	AARG+,W = Y offset						 *
* 	AARG+,L = Z offset						 *
*								         *
**************************************************************************
AU_CREATE_DESK_NINJA
	MOVK	B_OF_DNINJA,A1
	MOVI	M_INVINCIBLE,A6 ;This keeps the flags
	MOVI	ANIM_JUMP_OVER,A7	;This is our initial animation
	JRUC	CREATE_NINJA_GROUND

**************************************************************************
*								         *
* 	AU_CREATE_SHUFFLE_NINJA						 *
* 									 *
* 	Universe anim func to create a Ninja that will shuffle		 *
* 	out from behind a wall, then attack or flip towards you.	 *
* 									 *
* 	AARG+,W = X offset						 *
* 	AARG+,W = Y offset						 *
* 	AARG+,L = Z offset						 *
*								         *
**************************************************************************
AU_CREATE_SHUFFLE_NINJA
	MOVK	B_OF_WNINJA,A1
	CLR	A6 			;This keeps the flags
	MOVI	ANIM_SHUFFLE_OUT,A7	;This is our initial animation
	JRUC	CREATE_NINJA_GROUND

**************************************************************************
*								         *
* 	AU_CREATE_SHUFFLE_NINJA_OPP					 *
* 									 *
* 	Universe anim func to create a Ninja that will shuffle		 *
* 	out from behind a wall, then attack or flip towards you.	 *
*	Flip is opposite that of the generator.				 *
* 									 *
* 	AARG+,W = X offset						 *
* 	AARG+,W = Y offset						 *
* 	AARG+,L = Z offset						 *
*								         *
**************************************************************************
AU_CREATE_SHUFFLE_NINJA_OPP
	MOVK	B_OF_WNINJA,A1
	MOVI	M_OPP_FLIP,A6		;This keeps the flags
	MOVI	ANIM_SHUFFLE_OUT,A7	;This is our initial animation
	JRUC	CREATE_NINJA_GROUND

**************************************************************************
*								         *
* 	AU_CREATE_SIDE_NINJA						 *
* 									 *
* 	Universe anim func to create a Ninja that will jump		 *
* 	out from behind a wall, then attack or flip towards you.	 *
* 									 *
* 	AARG+,W = X offset						 *
* 	AARG+,W = Y offset						 *
* 	AARG+,L = Z offset						 *
*								         *
**************************************************************************
AU_CREATE_SIDE_NINJA
	MOVK	B_OF_WNINJA,A1
	CLR	A6 			;This keeps the flags
	MOVI	ANIM_JUMP_SYDE,A7	;This is our initial animation
	JRUC	CREATE_NINJA_GROUND

**************************************************************************
*								         *
* 	AU_CREATE_SIDE_NINJA_OPP					 *
* 									 *
* 	Universe anim func to create a Ninja that will jump		 *
* 	out from behind a wall, then attack or flip towards you.	 *
*	Flip is opposite that of the generator.				 *
* 									 *
* 	AARG+,W = X offset						 *
* 	AARG+,W = Y offset						 *
* 	AARG+,L = Z offset						 *
*								         *
**************************************************************************
AU_CREATE_SIDE_NINJA_OPP
	MOVK	B_OF_WNINJA,A1
	MOVI	M_OPP_FLIP,A6		;This keeps the flags
	MOVI	ANIM_JUMP_SYDE,A7	;This is our initial animation
	JRUC	CREATE_NINJA_GROUND

*
* Create a ground dwelling ninja (i.e. behind desk, out from wall)
*
*	AARG+,W = X Offset
*	AARG+,W = Y Offset
*	AARG+,L = Z Offset
*	AARG+,L = Generator animation branch on failure (0 = none)
*	A1 = OBJENEMIES bit to test
*	A6 = EFLAGS
*	A7 = Animation script
*	A8 = Ptr to generator object
*
CREATE_NINJA_GROUND
	MOVE	@OBJENEMIES,A14,W
	BTST	A1,A14
	JRZ	CNG_ABORT		;BR = not allowed, yet

	MOVI	OID_NINJA,A0
	CALLA	GET_ENEMY_COUNT
	CMPK	3,A0
	JRHS	CNG_ABORT		;BR = There are too many

	MMTM	SP,A6,A7
	PUSH	A8
	MOVI	NINJA_INIT,B0		;Get us one
	CALLA	CREATE_ENEMY
	PULL	A2			;A2=obj block of creator, 
	MMFM	SP,A6,A7
	JRNZ	CNG_GO			;BR = Object created succesfully

	MOVE	A2,A8
	JRUC	CNG_ABORT

CNG_GO
	MOVI	SRUNVEL_MAX,A0
	MOVI	SRUNVEL_MIN,A1
	CALLA	RANGRAND
	MOVE	A0,*A8(OSRUNVEL),L	;SET SIDE VELOCITY

	MOVIM	HRUNVEL,*A8(OHRUNVEL),L
*
*	set position
*
	MOVE	A8,A9
	MOVE	A2,A8

	CALLA	GETAFARG_LONG		; pixel Y:X in a0
	MOVE	A0,A4

	CALLA	GETAFARG_LONG		;Get Z offset

	MOVE	*A8(OZVAL),A3,L
	ADD	A0,A3

	MOVE	*A8(OXVAL),A1,L
	MOVE	*A8(OYVAL),A2,L
	MOVE	A4,A5			; do X and Y

	SEXT	A5

	CLR	A0

	BTST	B_OPP_FLIP,A6
	JRZ	CNG_NORM_FLIP_CK	;BR = No opposite flipping for you

	MOVE	*A8(OCTRL),A14
	BTST	B_FLIPH,A14
	JRNZ	CNG_NOFLIP		;BR = Don't flip this guy
	JRUC	CNG_FLIP

CNG_NORM_FLIP_CK
	MOVE	*A8(OCTRL),A14
	BTST	B_FLIPH,A14
	JRZ	CNG_NOFLIP

CNG_FLIP	
	NEG	A5
	MOVI	M_FLIPH,A0

CNG_NOFLIP

	SRA	16,A4
	SLL	15,A5
	SLL	15,A4
	ADD	A5,A1
	ADD	A4,A2


	MOVE	A9,A8

	CALLA	SET_FLPS

;	MOVE	@YWORLD,A14,L
;	MOVE	A2,A4
;	SUB	A14,A4
;	MOVE	A4,*A8(OGRNDOFF),L

	CALLA	SET_ANIPU

	MOVIM	HEADON_DEATH_ANIM,*A8(ODEATH_ANIM),L
	CLRM	*A8(OSTOP_ANIM),L
	MOVIM	HEADON_THROW_STAR_ANIM,*A8(OSHOOT_ANIM),L

	MOVE	A7,A1
	CALLA	STRT_ANIM		;START ANIMATION

	MOVE	A6,*A8(OEFLAGS),W	;Give this enemy some personality

	MOVI	NINJA_FLASH_COLOR,A1
	CALLA	STORE_OCONST		;STORE THE PROPER VALUE FOR CONSTANT

	MOVE	@LAB_RAT,A14,W
	JRZ	CNG_YELPAL

	MOVI	NINBLU64,A0
	CALLA	CHANGE_PAL_MULTI

CNG_YELPAL

	CALLA	GET_SHAD_MULTI		;Setup his shadow

	CALLA	INSERT_ENEMY		;INSERT AND COUNT ENEMY

	CREATE	PID_NINJA,NINJA_WATCH
	MOVE	A0,*A8(OPLINK),L

	RETS

*
* Come here on failure, this tries to branch animation of generator
*
CNG_ABORT
	CALLA	GETAFARG_LONG		;Throw out offsets
	CALLA	GETAFARG_LONG		;And Throw out more offsets
	CALLA	GETAFARG_LONG		;Get branch
	JRZ	CNG_AX			;BR = No branch to make
	MOVE	A0,*A8(AnimFrm),L	;OOPS! 
CNG_AX
	RETS
	
**************************************************************************
*								         *
* NINJA_CVECT								 *
*								         *
**************************************************************************
NINJA_CVECT
	WWL	OID_PROCKET,~MASK_PLAYER,NINJA_CD_COLL
	WWL	OID_PEXPLOSION,MASK_SUPP|MASK_TYPE|MASK_ID,NINJA_EXPLOSION_COLL
	WWL	OID_BLOWUP,0FFFFH,NINJA_SBOMB_COLL
	WL	0,DUMCRETS

**************************************************************************
*								         *
* NINJA_GUNVECT								 *
*								         *
* PASS:									 *
* A2 = PTR TO PLAYER						         *
* A8 = PTR TO OBJECT							 *
*								         *
**************************************************************************
NINJA_GUNVECT
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
	JRNZ	NINJA_DO_DEATH		;BR = Wicked bullets being used

	BTST	B_INVINCIBLE,A6		;ARE WE CURRENTLY INVINCIBLE?
	JRNE	BG_DEAD			;BR = YES, JUST EXIT

*
* A4 = OPARTID of part shot
* A6 = OEFLAGS
* A9 = OFLAGS
*
BG_TAKE_HIT
	CLR	A5
	MOVK	NINJA_HITS_TO_KILL,A1	;This many hits to kill
	MOVI	OHITS,A3		;This is the variable to use
	CALLA	HIT_ENEMY		;IS THIS GUY TOAST?
	JRHS	NINJA_DO_DEATH		;BR = OH YEAH!


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

BG_SKIP_PUSH_BACK
	MOVE	*A8(OHRUN_DURATION),A14,W
	JRZ	BG_NOT_RUNNING
	ADDK	5,A14
	MOVE	A14,*A8(OHRUN_DURATION),W	
BG_NOT_RUNNING

*
* Ninja is still alive here
*
	MOVI	NINJA_UNFLASH,A7
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
* 	NINJA_UNFLASH							 *
* 									 *
* 	Process subroutine to turn off the Ninja flash and		 *
* 	invinciblity bits.						 *
* 									 *
* 	A8 = Ptr to head object						 *
* 									 *
* 	Note: Call with JSRP						 *
*								         *
**************************************************************************
NINJA_UNFLASH
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
* 	NINJA_SBOMB_COLL						 *
* 									 *
* 	Ninja get hit by a smart bomb.					 *
* 									 *
* 	A2 = Ptr to player smart bombing				 *
* 	A8 = Ptr to Ninja						 *
*								         *
**************************************************************************
NINJA_SBOMB_COLL
	CLR	A5
	CALLA	GET_HEAD_PART

	MOVIM	ANIM_NINJA_SBOMB_EXPLODE,*A8(ODEATH_ANIM),L

	JRUC	NINJA_GEN_COLL

**************************************************************************
*								         *
* 	NINJA_CD_COLL							 *
* 									 *
* 	Ninja get hit by a CD						 *
* 									 *
* 	A0 = Ptr to CD							 *
* 	A8 = Ptr to Ninja						 *
*								         *
**************************************************************************
NINJA_CD_COLL
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
* 	NINJA_EXPLOSION_COLL						 *
* 									 *
* 	Ninja collides with a player explosion.				 *
* 									 *
* 	A0 = Ptr to explosion						 *
* 	A8 = Ptr to Ninja						 *
*								         *
**************************************************************************
NINJA_EXPLOSION_COLL
	CALLA	GETHEADPART			;GET THE KILLERS HEAD
	MOVE	A0,A5				;KEEP KILLER HERE
	MOVE	*A0(OID),A0,W			;GET PLAYER DATA ADDRESS
	CALLA	POID_TO_PDATA

	CALLA	GET_HEAD_PART
	MOVB	*A8(OCHEWED_ROCKET),A14		;Did he actually get hit?
	JRZ	BEC_DEAD			;BR= No

	MOVIM	ANIM_NINJA_EXPLODE,*A8(ODEATH_ANIM),L

*
* A2 = Ptr to player that killed us
* A8 = Ptr to head part of object
*
NINJA_GEN_COLL
	MOVE	A2,*A8(OPLAYER),L

	MOVE	*A8(OFLAGS),A9,W

	MOVE	*A8(OEFLAGS),A6,W
	
	SOUND1	SND_NINJA_EXPLODE

	CLRM	*A8(OHRUN_DURATION),W

	CALLA	ALL_COLLS_OFF

	MOVE	A5,A5
	JRZ	NINJA_DO_DEATH			;BR = No explosion attached

	SWAP	A5,A8
	CALLA	GET_HEAD_PART
	CALLA	OBJ_OFF_MULTI			;Kill the explosion
	SWAP	A5,A8

*
* This is a generic Ninja death entrypoint
* Note: NOTHING SHOULD BE PUSHED!
* A5 = Ptr to accompanying explosion, 0 means there isn't one
* A6 = EFLAGS
* A8 = Ptr to head part of cog
* A9 = OFLAGS
* *A8(OPLAYER),L = Ptr to player that killed us
*
NINJA_DO_DEATH

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

*
* This is the bullet death thing
*
	RANDENT	TAB_DEATH_SNDS,NUM_DEATH_SNDS,5,L
	CALLA	ONESND_Z			;Give us a ding

	MOVIM	-20000H,*A8(OYVEL),L	;SEND HIM UP
	MOVIM	4000H,*A8(OYACCEL),W	;AND MAKE HIM COME DOWN
	MOVI	SHORT_DEATH_ZVEL,A14
;	MOVE	A14,*A8(OZVEL),L	;AND MAKE HIM GET BLOWN BACK
	MOVE	A1,*A8(AnimFrm),L
	CLR	A14
	MOVB	A14,*A8(AnimSlp)
BEC_DEAD
	RETS

**************************************************************************
*								         *
*  		Anim funcs for the Ninja				 *
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
;	MOVE	@ZSCROLL,A14,L
;	JRZ	AVW_STOP_STOP
;	JRN	AVW_BACKING

;	MOVE	*A8(OZVEL),A2,L
;	JRLE	AVW_STOP_STOP

;	MOVI	05000H,A10
;	MOVE	A10,A11
;	JRUC	A_CALC_BT_Z

;AVW_BACKING
;	MOVE	*A8(OZVEL),A2,L
;	JRGE	AVW_STOP_STOP
	
;	MOVI	05000H,A10
;	MOVE	A10,A11
;	JRUC	A_CALC_HT_Z

AVW_STOP_STOP
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
A_SCREEN_CK_MEAT
	CALLA	SCRTST
	JANZ	DEL_ENEMY_NOAUD

	RETS

**************************************************************************
*								         *
* 	A_SCREEN_CK_FOLLOW						 *
* 									 *
* 	Anim func to check if the Ninja should follow the scroll.	 *
* 	If not, then just do a normal screen check.			 *
* 									 *
* 	A8 = Ptr to any part						 *
*								         *
**************************************************************************
A_SCREEN_CK_FOLLOW
	CALLA	GET_HEAD_PART
	MOVE	*A8(OEFLAGS),A14,W
	BTST	B_FOLLOW,A14
	JRZ	A_SCREEN_CK_MEAT
	CLR	A4
	JRUC	A_FOLLOW_SCROLL

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
* 	A_CALC_BACKWARD_TARGET						 *
* 									 *
* 	Anim func to pick a target point and calculate the numbers	 *
* 	to get there.							 *
* 									 *
* 	A8 = Ptr to head part						 *
*								         *
**************************************************************************
A_CALC_BACKWARD_TARGET
	MOVE	@SOCRATES,A14,W
	JRZ	ACBT_NO_CRATE

	MOVI	0B000H,A10
	MOVI	09000H,A11

	MOVI	20,A0
	CALLA	SRAND
	JRUC	A_TARGET_GOT_X

ACBT_NO_CRATE
	MOVI	0C000H,A10
	MOVI	0A000H,A11

	JRUC	A_TARGET_G

**************************************************************************
*								         *
* 	A_CALC_BT_Z							 *
* 									 *
* 	Anim func to pick a target point and calculate the numbers.	 *
* 	You provide the Z						 *
* 									 *
* 	A8 = Ptr to head part						 *
* 	A10 = Max target Z						 *
* 	A11 = Min target Z						 *
*								         *
**************************************************************************
A_CALC_BT_Z
	MOVE	@SOCRATES,A14,W
	JRZ	A_TARGET_G

	MOVI	20,A0
	CALLA	SRAND
	JRUC	A_TARGET_GOT_X

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
	MOVI	9000H,A10
	MOVI	8000H,A11

A_CALC_HT_Z
	MOVE	@SOCRATES,A14,W
	JRZ	A_TARGET_G

	MOVI	20,A0
	CALLA	SRAND
	JRUC	A_TARGET_GOT_X

*
* Generic entry for target calculation
* A10 = Max target Z
* A11 = Min target Z
*
A_TARGET_G
	MOVI	WORLDX_ARRAY,A3
	MOVE	A3,A7			;Store here for second trip through
	CLR	A4			;This is our array count
	MOVK	NUM_WX,A5
	MOVE	@XBASE+16,A6,W

	MOVE	A8,A9			;Keep the object here

	MOVI	OID_NINJA,A0
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

A_TARGET_GOT_X
	MOVE	A0,A5			;This is our world X target
	SLL	16,A5

	MOVE	A10,A0
	MOVE	A11,A1
	CALLA	RANGERND

	MOVE	A0,A7			;This is our world Z target

	MOVE	*A8(OZVAL),A1,L
	MOVE	@ZBASE,A14,L
	SUB	A14,A1			;Universe to World Z

	MOVE	*A8(OXVAL),A3,L
	MOVE	@XBASE,A14,L
	SUB	A14,A3			;Universe to World X

	MOVE	*A8(OHRUNVEL),A2,L

	SUB	A7,A1			;Get the Z distance to travel
	JRGE	ACHT_GOING_FORWARD

	ABS	A1

	NEG	A2

	MOVE	@SOCRATES,A14,W
	JRZ	ACHT_STUFF_Z		;BR = Don't need to add this now

	MOVE	@ZSCROLL,A14,L
	JRGE	ACHT_STUFF_Z

	ADD	A14,A2
	JRUC	ACHT_STUFF_Z

ACHT_GOING_FORWARD
	MOVE	@SOCRATES,A14,W
	JRZ	ACHT_STUFF_Z		;BR = Don't need to add this now

	MOVE	@ZSCROLL,A14,L
	JRLE	ACHT_STUFF_Z
	ADD	A14,A2
ACHT_STUFF_Z
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
* 	A_THROW_OR_SHUFFLE						 *
* 									 *
* 	Anim func to determine what should be done, now that		 *
* 	the Ninja has landed and is ready for battle.			 *
* 									 *
* 	A8 = Ptr to Ninja head object					 *
*								         *
**************************************************************************
A_THROW_OR_SHUFFLE
	MOVI	512,A0
	CALLA	RANDPER
	JRNC	ATOS_SHUFFLE

	MOVI	HEADON_THROW_STAR_ANIM,A1
	JAUC	SetAnim

ATOS_SHUFFLE
	SLL	28,A0
	SRL	28,A0
	INC	A0
	MOVB	A0,*A8(AnimLoop)
	MOVI	HEADON_SHUFFLE_ANIM,A1
	JAUC	SetAnim
	
*
* Decide if we should throw, do a shuffle step or hand spring
*
A_THROW_SHUFFLE_OR_SPRING
	MOVE	@WAVE,A14,W
	CMPK	LAST_WAVE,A14
	JREQ	A_THROW_OR_SHUFFLE	;BR = These are the finale' guys

	MOVE	*A8(OEFLAGS),A14,W
	BTST	B_BRIDGE,A14
	JRNZ	A_THROW_OR_SHUFFLE

	BTST	B_FOLLOW,A14
	JRZ	ATSOS_SHUFFLE_CK

	MOVI	HEADON_THROW_STAR_ANIM,A4
	JRUC	A_FOLLOW_SCROLL

ATSOS_SHUFFLE_CK
	MOVE	*A8(OZVAL),A1,L
	MOVE	@ZBASE,A14,L
	SUB	A14,A1			;Universe to World Z

	CMPI	09000H,A1
	JRLT	A_THROW_OR_SHUFFLE	;BR = Too far, needs to run closer

	MOVI	HEADON_HANDSPRING_ANIM,A1
	JAUC	SetAnim

*
* Follow the scroll
* A4 = Animation branch if we don't need to follow. (0 = fall through)
*
A_FOLLOW_SCROLL
	MOVE	*A8(OXVAL),A1,L
	MOVE	*A8(OZVAL),A2,L
	MOVE	A2,A3

	MOVE	@ZBASE,A14,L
	SUB	A14,A3
	CMPI	ZMAX_REAL,A3
	JALT	AFS_WAY_FORWARD		;BR = Too far forward, deal with 'em

	MOVE	@SOCRATES,A14,W
	JRZ	AFS_NOCRATE

	MOVE	@WHAREA,A6,W
	MOVE	A6,A14
	SLL	5,A6
	SLL	6,A14
	ADD	A6,A14
	ADDI	ROW_PARMS_TABLE,A14

	MOVE	*A14(40H),A6,L		;A1 = UNIVERSE Z FARTHEST
	MOVE	@ZREL_OFF,A14,L
	SRA	ZFRAC,A14
	ADD	A14,A6

	CMP	A6,A2
	JRGT	AFS_WAY_BACK

AFS_NOCRATE
	UTOSX	A2,A1			;Get a screen position for this guy

	MOVE	@XSCROLL,A3,L
	JRN	AFS_CK_RIGHTSIDE	;BR = Scrolling left, check right edge
	JRNZ	AFS_CK_LEFTSIDE		;BR = Scrolling right, check left edge
	
	CMPI	75,A1
	JRLT	SHUFFLE_RIGHT

	CMPI	325,A1
	JRLE	AFS_X

SHUFFLE_LEFT
	MOVI	M_FLIPH,A0
	JRUC	AFS_DO_SHUFFLE

SHUFFLE_RIGHT
	CLR	A0
AFS_DO_SHUFFLE
	CALLA	SET_FLPS

	MOVK	3,A0
	MOVE	A3,A3
	JRZ	ATOS_SHUFFLE
	ADDK	2,A0			;More if we are moving
	JRUC	ATOS_SHUFFLE

AFS_CK_RIGHTSIDE
	MOVE	*A8(OXVEL),A14,L
	JRNN	AFS_CR_GO		;BR = Velocity is not happening correctly

	ABS	A3
	ABS	A14
	SUB	A3,A14
	JRGT	AFS_X			;BR = Moving faster than the scroll

AFS_CR_GO
	CMPI	325,A1
	JRGE	SHUFFLE_LEFT
	JRUC	AFS_X

AFS_CK_LEFTSIDE
	MOVE	*A8(OXVEL),A14,L
	JRN	AFS_CL_GO		;BR = Velocity is not happening correctly
	JREQ	AFS_CL_GO

	ABS	A3
	ABS	A14
	SUB	A3,A14
	JRGT	AFS_X			;BR = Moving faster than the scroll

AFS_CL_GO
	CMPI	75,A1
	JRLE	SHUFFLE_RIGHT
AFS_X
	MOVE	A4,A1
	JANZ	SetAnim
	RETS

*
* The guy is too far forward in Z
* A1 = OXVAL
* A2 = OZVAL
* A8 = Ptr to head object
*
AFS_WAY_FORWARD
	MOVE	@XBASE,A14,L
	SUB	A14,A1

	MOVE	@ZSCROLL,A14,L
	JRLE	AFS_DEL

	ABS	A1
	SRA	16,A1
	CMPI	50,A1
	JRGT	AFS_DEL

	MOVI	BACKWARD_HANDSPRING_ANIM,A1
	JAUC	STRT_ANIM

AFS_DEL
	ADDKM	1,@NINJA_POPS,W
	JAUC	DEL_ENEMY_NOAUD

*
* The guy is too far back in Z
* A1 = OXVAL
* A2 = OZVAL
* A3 = World Z pos
* A8 = Ptr to head object
*
AFS_WAY_BACK
	MOVE	@XBASE,A14,L
	SUB	A14,A1

	MOVE	@ZSCROLL,A14,L
	JRGE	AFS_STAND_OR_JUMP

	ABS	A1
	SRA	16,A1
	CMPI	50,A1
	JRGT	AFS_STAND_OR_JUMP

	MOVI	HEADON_HANDSPRING_ANIM,A1
	JAUC	STRT_ANIM

AFS_STAND_OR_JUMP
	MOVE	@XSCROLL,A14,L
	JRNZ	AFS_JUMP_OFF
	
	MOVI	HEADON_STAND_ANIM,A1
	JAUC	STRT_ANIM

AFS_JUMP_OFF
	ADDKM	1,@NINJA_POPS,W
	MOVI	ANIM_JUMP_OFF,A1
	JAUC	STRT_ANIM

**************************************************************************
*								         *
* 	A_CK_FALL							 *
* 									 *
* 	Anim func to check if we should fall into oblivion		 *
* 									 *
* 	A8 = Ptr to Head part of object					 *
*								         *
**************************************************************************
A_CK_FALL
	MOVE	*A8(OEFLAGS),A14,W
	BTST	B_BRIDGE,A14
	JRZ	ACF_X			;BR = Not up on something

	SOUNDZ	SND_LONG_FALL

	MOVI	HEADON_FALL_ANIM,A1
	JAUC	SetAnim
ACF_X
	RETS

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
* A_HIT_GROUND - Animation Function for when the enemy hits the ground	 *
* 		while jumping.  It zeros velocity and sets on ground.	 *
* A8 = Ptr to object							 *
*								         *
**************************************************************************
A_HIT_GROUND
	CALLA	GET_HEAD_PART
	CLR	A14
	MOVE	A14,*A8(OYVEL),L
	MOVE	A14,*A8(OYACCEL),W
	MOVE	A14,*A8(OZVEL),L
	MOVE	*A8(OXVAL),A3,L
	MOVE	@YWORLD,A2,L
	MOVE	@WORLD_GRNDOFF,A0,L
	ADD	A0,A2
	MOVE	*A8(OGRNDOFF),A0,L
	ADD	A0,A2
	MOVE	*A8(OZVAL),A1,L
	JAUC	REPOS_OBJ

**************************************************************************
*								         *
* 	A_CK_SPEARS							 *
* 									 *
* 	Anim func to check the number of spears and skip throw		 *
* 	if there are too many.						 *
*								         *
**************************************************************************
A_CK_SPEARS
	MOVE	@NUM_NSTARS,A14,W
	CMPK	3,A14
	JRLS	ACS_X

	MOVIM	HEADON_SKIP_THROW,*A8(AnimFrm),L

ACS_X
	RETS

**************************************************************************
*								         *
* 	A_SETUP_JUMP_OVER						 *
* 									 *
* 	Set velocities for jumping over something.			 *
* 									 *
* 	A8 = Ptr to head part of object					 *
*								         *
**************************************************************************
A_SETUP_JUMP_OVER
	MOVIM	-40000H,*A8(OYVEL),L
	MOVIM	3000H,*A8(OYACCEL),W
	MOVIM	-20H,*A8(OZVEL),L
	RETS

**************************************************************************
*								         *
* 	A_NGROUND_CK							 *
* 									 *
* 	Anim func to check if an object is above ground.		 *
* 	If it is, then branch.						 *
* 									 *
* 	A8 = Ptr to object						 *
* 	AARG+,W = Integer Ground offset	   				 *
* 	AARG+,L = Branch						 *
*								         *
**************************************************************************
A_NGROUND_CK
	CALLA	GETAFARG_WORD
	MOVE	A0,A2
	SLL	16,A2

	CALLA	GET_HEAD_PART_A0
	MOVE	*A0(OYVEL),A14,L
	JRN	AGC_BRANCH		;BR = We are going up

	CALLA	DIST_FROM_GROUND
	CMP	A2,A1
	JRLE	AGC_X
AGC_BRANCH
     	CALLA	GETAFARG_LONG
	MOVE	A0,A1
	CALLA	GET_HEAD_PART
	JAUC	SetAnim
AGC_X
	RETS

**************************************************************************
*								         *
* 	A_CHECK_OBSTRUCTION						 *
* 									 *
* 	Check if the given point offset from the objects animation	 *
* 	point is free from obstruction.					 *
* 	If it is not, then branch.					 *
* 									 *
* 	A8 = Object							 *
* 	AARG+,L = [Y,X] Offset						 *
* 	AARG+,L = Branch if obstructed					 *
*								         *
**************************************************************************
A_CHECK_OBSTRUCTION
	CALLA	GETAFARG_LONG
	MOVE	A0,A3
	MOVE	A3,A7

	SEXT	A3,W
	SLL	15,A3			;X WORLD OFFSET
	SRA	16,A7
	SLL	15,A7			;Y WORLD OFFSET
	MOVE	*A8(OCTRL),A14,W	;ADJUST FIRING OFFSET IF NECESSARY
	BTST	B_FLIPH,A14
	JREQ	ACO_CKV			;BR=NO HORIZONTAL FLIP 
	NEG	A3
ACO_CKV
	BTST	B_FLIPV,A14
	JREQ	ACO_OFF			;BR=NO VERTICAL FLIP
	NEG	A7
ACO_OFF
	MOVE	*A8(OXVAL),A14,L
	ADD	A14,A3			;X UNIVERSE
	MOVE	*A8(OYVAL),A14,L
	ADD	A14,A7			;Y UNIVERSE
	MOVE	*A8(OZVAL),A2,L		;Z UNIVERSE

	UTOSXY	A2,A3,A7		;UNIVERSE X,Y TO SCREEN X,Y TRANSLATION
	SLL	16,A7
	ZEXT	A3,W
	ADDXY	A7,A3			;A3 IN [Y,X] FORMAT

	CALLA	ENEMYP_COLL
	JANZ	SetAnim_AFARG		;BR = There is an obstruction

	MOVE	@HOLD_ENEMY_DISPATCH,A14,W
	JANZ	SetAnim_AFARG		;BR = We are not to throw

	RETS	

**************************************************************************
*								         *
* 	A_CLR_INVINCIBLE						 *
* 									 *
* 	Anim func to clear the invinciblity flag			 *
* 									 *
* 	A8 = Ptr to any part						 *
*								         *
**************************************************************************
A_CLR_INVINCIBLE
	CALLA	GET_HEAD_PART
	ANDNIM	M_INVINCIBLE,*A8(OEFLAGS),W
	RETS

**************************************************************************
*								         *
* 	A_SIDE_FLY							 *
* 									 *
* 	Anim func to start him flying to the side.			 *
* 									 *
* 	A8 = Ptr to head part						 *
*								         *
**************************************************************************
A_SIDE_FLY
	MOVI	24000H,A1
	MOVI	2C000H,A0
	CALLA	RANGERND
	
	MOVE	*A8(OCTRL),A14,W
	BTST	B_FLIPH,A14
	JRZ	ASF_NOT_FLIPPED

	NEG	A0
	MOVE	@XSCROLL,A2,L
	JRNN	ASF_STUFF_XVEL

	ADD	A2,A0
	JRUC	ASF_STUFF_XVEL

ASF_NOT_FLIPPED
	MOVE	@XSCROLL,A2,L
	JRN	ASF_STUFF_XVEL

	ADD	A2,A0

ASF_STUFF_XVEL
	MOVE	A0,*A8(OXVEL),L

	MOVE	*A8(OZVAL),A2,L
	MOVE	@ZBASE,A14,L
	SUB	A14,A2
	CMPI	0B000H,A2
	JRGE	ASF_FAR_FLY
	MOVIM	-2C000H,*A8(OYVEL),L
	JRUC	ASF_FLY_ACCEL
ASF_FAR_FLY
	MOVIM	-40000H,*A8(OYVEL),L
ASF_FLY_ACCEL
	MOVIM	3000H,*A8(OYACCEL),W
	
	RETS

**************************************************************************
*								         *
* 	A_SET_NINJA_OXVEL						 *
* 									 *
* 	Anim func to set the OXVEL for the Ninja.			 *
* 									 *
* 	AARG+,L = Absolute XVEL to set					 *
*								         *
**************************************************************************
A_SET_NINJA_OXVEL
	MOVE	*A8(OEFLAGS),A14,W
	BTST	B_FOLLOW,A14
	JAZ	A_SET_OXVEL

	CALLA	GETAFARG_LONG

	MOVE	*A8(OCTRL),A14,W
	BTST	B_FLIPH,A14
	JRNZ	ASNO_FLIPPED
	MOVE	@XSCROLL,A1,L
	JRN	ASNO_STUFFIT
	JRUC	ASNO_ADDIT
ASNO_FLIPPED
	NEG	A0
	MOVE	@XSCROLL,A1,L
	JRNN	ASNO_STUFFIT
ASNO_ADDIT
	ADD	A1,A0	
ASNO_STUFFIT
	MOVE	A0,*A8(OXVEL),L
	RETS

**************************************************************************
*								         *
* 	A_CHECK_XBOUNDS							 *
* 									 *
* 	Anim func to check the current X boundries of the Ninja		 *
* 									 *
* 	A8 = Ptr to any part						 *
*								         *
**************************************************************************
A_CHECK_XBOUNDS
	MOVE	@SOCRATES,A14,W
	JRZ	ACX_X

	CALLA	GET_HEAD_PART

	MOVE	*A8(OEFLAGS),A14,W
	BTST	B_FOLLOW,A14
	JRZ	ACX_X
	
	MOVE	*A8(OXVEL),A4,L
	JRZ	ACX_X	    		;BR = Not moving

	CALLR	GET_MY_ROW
	JRZ	ACX_X			;BR = Row not found

	MOVE	*A6,A2,L		;A1 = UNIVERSE Z FARTHEST

	MOVY	A2,A3
	SRA	16,A3
	SEXT	A2

	MOVE	*A8(OXPOS),A1,W
	MOVE	A4,A4
	JRNN	ACX_CHECK_RIGHT

	CMP	A2,A1
	JRLT	ACX_STOP_NOW		;BR = Too far left
	JRUC	ACX_X

ACX_CHECK_RIGHT
	CMP	A3,A1
	JRLT	ACX_X			;BR = OK on the right side

ACX_STOP_NOW
	CLR	A14
	MOVE	A14,*A8(OXVEL),L
	MOVE	A14,*A8(OXACCEL),W

	MOVI	HEADON_STAND_ANIM,A1
	CALLA	STRT_ANIM

ACX_X
	RETS


**************************************************************************
*								         *
* 	A_SET_SHUFFLE_X							 *
* 									 *
* 	Anim func to set the amount of shuffle loops to do.		 *
* 									 *
* 	A8 = Ptr to head part						 *
*								         *
**************************************************************************
A_SET_SHUFFLE_X
	MOVE	@LAB_RAT,A14,W
	JRZ	ASSX_NORM

	MOVK	2,A0
	MOVB	A0,*A8(AnimLoop)
	RETS

ASSX_NORM	
	MOVK	3,A1
	MOVK	5,A0
	CALLA	RANGERND		;And make it into something
	MOVB	A0,*A8(AnimLoop)
	RETS
	
**************************************************************************
*								         *
* 	GET_MY_ROW							 *
* 									 *
* 	Get the current row entry for this guy, based on		 *
* 	current universe Z, not relative.				 *
* 									 *
* 	A8 = Ptr to object						 *
* 									 *
* 	Returns:							 *
* 		 Z = No row found, A6 = 0				 *
* 		NZ = Found one, A6 = Entry				 *
*								         *
**************************************************************************
GET_MY_ROW
	PUSH	A4

	MOVE	*A8(OZVAL),A4,L

	MOVE	@ZREL_OFF,A14,L
	SRA	ZFRAC,A14

	SUB	A14,A4

	MOVI	ROW_PARMS_TABLE,A6

GMR_LOOP
	MOVE	*A6(20H),A14,L
	CMP	A14,A4
	JRLT	GMR_NEXT		;BR = Too far forward for this one
	
	MOVE	*A6(40H),A14,L
	CMP	A14,A4
	JRLE	GMR_GOT_IT		;BR = We found one

GMR_NEXT
	ADDI	96,A6
	MOVE	*A6,A14,L
	JRNZ	GMR_LOOP
	JRUC	GMR_X

GMR_GOT_IT
	MOVE	@WHAREA,A4,W
	MOVE	A4,A14
	SLL	5,A4
	SLL	6,A14
	ADD	A14,A4
	ADDI	ROW_PARMS_TABLE,A4
	CMP	A4,A6			
	JREQ	GMR_USE_IT		;BR = same as WHAREA

	MOVE	@ZSCROLL,A14,L
	JRNZ	GMR_USE_IT		;Moving in Z so use what you got

	MOVE	A4,A6			;Otherwise use correct

GMR_USE_IT
	MOVE	A6,A6
GMR_X	
	PULL	A4
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
	.WORD	0F102H,16,0A589H,0	;Bullet hit vocal response
SND_HIT2
	.WORD	0F102H,12,0A58CH,0	;Bullet hit vocal response

SND_BODY_HIT
	.WORD	0F302H,26,0A1D1H,0	;Bullet hits his body

SND_CHEST_HIT
	.WORD	0F304H,24,0A1E6H,0	;Chest plate gets hit

NUM_DEATH_SNDS .EQU	2
TAB_DEATH_SNDS
	.LONG	SND_DEATH1, SND_DEATH2
SND_DEATH1
	.WORD	0F342H,23,0A591H,0
SND_DEATH2
	.WORD	0F342H,23,0A594H,0

SND_LONG_FALL
	.WORD	0F343H,197,0A59AH,0

SND_NINJA_EXPLODE
	.WORD	0F142H,60,0A38BH,0	;Explosion used by much

SND_NINJA_EXP_SCREAM
	.WORD	0F342H,30,0A597H,0

SND_SPRING_WHOOSH
	.WORD	0F342H,15,0A489H,0	;Sound of an axe being thrown

SND_GROUND_HIT
	.WORD	0F330H,26,0A1D1H,0

SND_JUMP_LAND
	.WORD	0F330H,26,0A1D1H,0

SND_NINJA_FIRE
	.WORD	0F305H,25,0A10BH,0	;Ninja fire sound
SND_NINJA_THROW
	.WORD	0F142H,30,0A469H,0

*
* Object initialization table for the Ninja
*
NINJA_INIT
	.byte	 4, 0, 1, 0	;OBJCNT, PRCCNT, IMGPALCNT, PALCNT
	.long	NST1_01A	;IMGPAL
	.word	OID_NINJA, OM_COLL
	.LONG	NINJA_CVECT
*
*    .long	IMG
*    .word 		  OCTRL,  OFLAGS,   OZOFF, OPTION_FLAGS
*
NUM_LEGS .EQU	1
	LWWWW	NST1_01A, DMAWNZ, M_NODISP,	0, OM_GUNV
	.LONG	NINJA_GUNVECT
NUM_TORSO .EQU	2
	LWWWW	NST1_01B, DMAWNZ, M_NODISP,    -1, OM_ANIM|OM_PRVGUNV
	.LONG	ANIM_VELOCITY_WATCH
	LWWWW	NST1_01C, DMAWNZ, M_NODISP,    -2, OM_PRVGUNV
	LWWWW	NST1_01A, DMAWNZ, M_NODISP,    -3, OM_PRVGUNV


*
*Animation script to keep tabs on the velocity and movement boundries
*
ANIM_VELOCITY_WATCH
	LWL	1,1|AFunc,A_VELOCITY_WATCH
	.LONG	0

HEADON_HANDSPRING_ANIM
	LWL	1,1|AFunc,A_CALC_HEADON_TARGET

	LW	NSPRING1_12,1|AMulti
	LWL	1,1|AMulti|AFunc,OBJ_OFF
	LWL	1,1|AMulti|AFunc,OBJ_OFF
	LWL	1,3|AFunc,OBJ_OFF

	LW	NSPRING1_11,3

	LW	NSPRING1_10,3
HHA_LOOP
	LWLL	NSPRING1_09,3|AFunc,A_SOUNDZ+2,SND_SPRING_WHOOSH

	LW	NSPRING1_08,3
	
	LW	NSPRING1_07,3

	LW	NSPRING1_06,3

	LW	NSPRING1_05,3

	LW	NSPRING1_04,3

	LWLL	NSPRING1_10,1|AMulti|AFunc,A_AnimFrm+2,HHA_LOOP
	LWL	1,1|AFunc,A_SCREEN_CK

BACKWARD_HANDSPRING_ANIM
	LW	NSPRING1_01,1|AMulti
	LWL	1,1|AMulti|AFunc,OBJ_OFF
	LWL	1,1|AMulti|AFunc,OBJ_OFF
	LWL	1,4|AFunc,OBJ_OFF

	LW	NSPRING1_02,4

	LW	NSPRING1_03,3

	LWL	1,1|AFunc,A_CALC_BACKWARD_TARGET

BHA_LOOP
	LWLL	NSPRING1_04,3|AFunc,A_SOUNDZ+2,SND_SPRING_WHOOSH

	LW	NSPRING1_05,3
	
	LW	NSPRING1_06,3

	LW	NSPRING1_07,3

	LW	NSPRING1_08,3

	LW	NSPRING1_09,3

	LWLL	NSPRING1_10,1|AMulti|AFunc,A_AnimFrm+2,BHA_LOOP
	LWL	1,1|AFunc,A_SCREEN_CK

*
* Throw star, starting from stance position 1
*
HEADON_THROW_STAR_ANIM
	LWLWWL	1,1|AFunc,A_CHECK_OBSTRUCTION+4,-21,-99,HEADON_STAND_ANIM

	LW	NSTAR1_01A,1|AMulti
	LWL	NSTAR1_01B,1|AMulti|AFunc,OBJ_ON
	LWL	NSTAR1_01C,1|AMulti|AFunc,OBJ_ON
	LWL	1,3|AFunc,OBJ_OFF

	LW	NSTAR1_02A,1|AMulti
	LW	NSTAR1_02B,1|AMulti
	LW	NSTAR1_02C,3

	LW	NSTAR1_03A,1|AMulti
	LW	NSTAR1_03B,1|AMulti
	LW	NSTAR1_03C,1|AMulti
	LWL	NSTAR1_03D,3|AFunc,OBJ_ON

	LWL	NSTAR1_04A,1|AMulti|AFunc,A_CK_SPEARS
	LW	NSTAR1_04B,1|AMulti
	LWL	NSTAR1_04C,1|AMulti|AFunc,A_SCREEN_CK_FOLLOW
	LW	NSTAR1_04D,3

	LW	NSTAR1_05A,1|AMulti
	LW	NSTAR1_05B,1|AMulti
	LW	NSTAR1_05C,1|AMulti
	LWLLWW	NSTAR1_05D,10|AFunc,A_SPAWN_PROJECTILE+4,NSTAR_INIT,-21,-99

HEADON_SKIP_THROW
	LWLL	NNRG1_01A,1|AMulti|AFunc,A_AnimGo+2,HEADON_STAND_ANIM
	LW	NNRG1_01B,1|AMulti
	LW	NNRG1_01C,1|AMulti
	LW	NNRG1_01D,4


*
* Jump from where you are, up and off the screen
*
ANIM_JUMP_OFF	
	LW	NLD1_04A,1|AMulti
	LW	NLD1_04B,1|AMulti
	LW	NLD1_04C,1|AMulti
	LWL	1,4|AFunc,OBJ_OFF

	LW	NLD1_03A,1|AMulti
	LW	NLD1_03B,1|AMulti
	LW	NLD1_03C,10

	LW	NLD1_02A,1
	LW	NLD1_02B,1
	LW	NLD1_02C,4

	LWLL	NLD1_01A,1|AMulti|AFunc,A_SET_OYVEL+2,-80000H
	LW	NLD1_01B,1|AMulti
	LW	NLD1_01C,4

	LWL	1,1|AFunc,DELETE_SHADOW

	LWL	1,10|AFunc,A_STAY_TIL_OFFSCRN

	LWL	1,1|AFunc,DEL_ENEMY_NOAUD

*
* Jump from above to the ground.
*
ANIM_JUMP_ON
	LWL	NJP1_05A,1|AMulti|AFunc,OBJ_ON
	LWL	NJP1_05B,1|AMulti|AFunc,OBJ_ON
	LWL	NJP1_05C,1|AMulti|AFunc,OBJ_ON
	LWL	1,1|AFunc,OBJ_OFF

	LWLL	1,1|AFunc,A_SET_OYVEL+2,60000H
	
AJO_WAIT
	LWLWL	1,1|AFunc,A_NGROUND_CK+3,10,AJO_WAIT

	LWL	NLD1_01A,1|AMulti|AFunc,A_HIT_GROUND
	LW	NLD1_01B,1|AMulti
	LW	NLD1_01C,4

	LWL	NLD1_02A,1|AMulti|AFunc,A_CLR_INVINCIBLE
	LWLL	NLD1_02B,1|AMulti|AFunc,A_SOUNDZ+2,SND_JUMP_LAND
	LW	NLD1_02C,4

	LW	NLD1_03A,1|AMulti
	LW	NLD1_03B,1|AMulti
	LW	NLD1_03C,10

	LW	NLD1_04A,1|AMulti
	LW	NLD1_04B,1|AMulti
	LW	NLD1_04C,4

	LWL	NST1_01A,1|AMulti|AFunc,A_THROW_SHUFFLE_OR_SPRING
	LW	NST1_01B,1|AMulti
	LW	NST1_01C,6

	LWL	1,1|AFunc,A_AnimGo+2,HEADON_SHUFFLE_ANIM

ANIM_SHUFFLE_OUT
	LWL	NSHFL1_01A,1|AMulti|AFunc,OBJ_ON
	LWL	NSHFL1_01B,1|AMulti|AFunc,OBJ_ON
	LWL	NSHFL1_01C,1|AMulti|AFunc,OBJ_ON
	LWL	NSHFL1_01D,1|AFunc,OBJ_ON

;	LWLWWW	1,1|AFunc,A_RAND_REL_BYTE+3,3,5,AnimLoop
	LWL	1,1|AFunc,A_SET_SHUFFLE_X

HEADON_SHUFFLE_ANIM
	LWLL	NSHFL1_01A,1|AMulti|AFunc,A_SET_NINJA_OXVEL+2,20000H
	LW	NSHFL1_01B,1|AMulti
	LW	NSHFL1_01C,1|AMulti
	LWL	NSHFL1_01D,4|AFunc,OBJ_ON

HEADON_SHUFFLE_LOOP
	LWL	NSHFL1_02A,1|AMulti|AFunc,A_CHECK_XBOUNDS
	LW	NSHFL1_02B,1|AMulti
	LW	NSHFL1_02C,1|AMulti
	LWL	1,4|AFunc,OBJ_OFF

	LWL	NSHFL1_03A,1|AMulti|AFunc,A_CHECK_XBOUNDS
	LW	NSHFL1_03B,1|AMulti
	LW	NSHFL1_03C,4
	
	LWL	NSHFL1_04A,1|AMulti|AFunc,A_CHECK_XBOUNDS
	LW	NSHFL1_04B,1|AMulti
	LW	NSHFL1_04C,1|AMulti
	LWL	NSHFL1_04D,4|AFunc,OBJ_ON

	LWL	NSHFL1_05A,1|AMulti|AFunc,A_CHECK_XBOUNDS
	LW	NSHFL1_05B,1|AMulti
	LW	NSHFL1_05C,1|AMulti
	LW	NSHFL1_05D,4

	LWLL	NSHFL1_01A,1|AMulti|AFunc,A_Anim_DSJ+2,HEADON_SHUFFLE_LOOP
	LW	NSHFL1_01B,1|AMulti
	LWL	NSHFL1_01C,1|AMulti|AFunc,A_SCREEN_CK_FOLLOW
	LW	NSHFL1_01D,4

HEADON_STAND_ANIM
	LWL	NST1_01A,1|AMulti|AFunc,A_CLR_ALL_X
	LWL	NST1_01B,1|AMulti|AFunc,OBJ_ON
	LWL	NST1_01C,1|AMulti|AFunc,OBJ_ON
	LWL	1,1|AFunc,OBJ_OFF

	LWLWW	1,1|AFunc,A_RAND_AnimSLP+2,1,15

	LW	1,0

	LWL	1,1|AFunc,A_SCREEN_CK_FOLLOW

	LWL	1,1|AFunc,A_AnimGo+2,HEADON_THROW_STAR_ANIM


*
* Stand guard and then bring up a staff
*
ANIM_GUARD
	LW	NST1_01A,1|AMulti
	LW	NST1_01B,1|AMulti
	LW	NST1_01C,1|AMulti
	LWL	1,1|AFunc,OBJ_OFF

	LWL	1,5|AFunc,A_STAY_TIL_ONSCRN

	LWL	1,5|AFunc,A_STAY_TIL_ZBASE

	LWLW	1,1|AFunc,A_DEC_STAY_TIL_ZERO+1,OGUARD_ATIME

	LWL	1,1|AFunc,A_AnimGo+2,HEADON_THROW_STAR_ANIM

*
* Jump over desk
*
ANIM_JUMP_OVER
	LWL	NLD1_03A,1|AMulti|AFunc,OBJ_ON
	LWL	NLD1_03B,1|AMulti|AFunc,OBJ_ON
	LWL	NLD1_03C,1|AMulti|AFunc,OBJ_ON
	LWL	1,4|AFunc,OBJ_OFF

	LW	NLD1_04A,1|AMulti
	LW	NLD1_04B,1|AMulti
	LW	NLD1_04C,4

	LWL	NJP1_05A,1|AMulti|AFunc,A_SETUP_JUMP_OVER
	LW	NJP1_05B,1|AMulti
	LW	NJP1_05C,4


	LWLL	1,1|AFunc,A_AnimGo+2,AJO_WAIT

*
* Jump sideways
*
ANIM_JUMP_SYDE
	LWL	NSYDJP1_01A,1|AMulti|AFunc,OBJ_ON
	LWL	NSYDJP1_01B,1|AMulti|AFunc,OBJ_ON
	LWL	NSYDJP1_01C,1|AMulti|AFunc,OBJ_ON
	LWL	1,4|AFunc,OBJ_OFF

	LW	NSYDJP1_02A,1|AMulti
	LW	NSYDJP1_02B,1|AMulti
	LW	NSYDJP1_02C,4

	LWL	NSYDJP1_03A,1|AMulti|AFunc,A_SIDE_FLY
	LW	NSYDJP1_03B,1|AMulti
	LW	NSYDJP1_03C,1|AMulti
	LWL	NSYDJP1_03D,4|AFunc,OBJ_ON

	LW	NSYDJPSTR_05A,1|AMulti
	LW	NSYDJPSTR_00B,1|AMulti
	LW	NSYDJPSTR_00C,1|AMulti
	LW	NSYDJPSTR_00D,4

AJS_STAR_THROW
;	LWLWW	1,1|AFunc,A_RAND_AnimSLP+2,1,5
	LWLWL	1,2|AFunc,A_NGROUND_CK+3,10,AJS_CK_OBJSTRUCT

	LWLL	1,1|AFunc,A_AnimGo+2,AJS_LAND

AJS_CK_OBJSTRUCT
	LWLWWL	1,1|AFunc,A_CHECK_OBSTRUCTION+4,1,-134,AJS_STAR_THROW

	LW	1,1|AMulti
	LW	NSYDJPSTR_01B,1|AMulti
	LW	NSYDJPSTR_01C,1|AMulti
	LW	NSYDJPSTR_01D,4

	LW	1,1|AMulti
	LW	NSYDJPSTR_02B,1|AMulti
	LW	NSYDJPSTR_02C,1|AMulti
	LW	NSYDJPSTR_02D,4

	LW	1,1|AMulti
	LW	NSYDJPSTR_05B,1|AMulti
	LW	NSYDJPSTR_04C,1|AMulti
	LWL	1,4|AFunc,OBJ_OFF

	LWLLWW	1,1|AMulti|AFunc,A_SPAWN_PROJECTILE+4,NSTAR_INIT,1,-134
	LW	NSYDJPSTR_05B,1|AMulti
	LW	NSYDJPSTR_05C,1|AMulti
	LWL	NSYDJPSTR_05D,6|AFunc,OBJ_ON

	LW	NSYDJPSTR_05A,1|AMulti
	LW	NSYDJPSTR_00B,1|AMulti
	LW	NSYDJPSTR_00C,1|AMulti
	LW	NSYDJPSTR_00D,1

AJS_WAIT
	LWLWL	1,1|AFunc,A_NGROUND_CK+3,10,AJS_WAIT

AJS_LAND
	LWL	NSYDJP1_06A,1|AMulti|AFunc,A_HIT_GROUND
	LW	NSYDJP1_06B,1|AMulti
	LW	NSYDJP1_06C,1|AMulti
	LW	NSYDJP1_06D,4

	LWL	NSYDJP1_01A,1|AMulti|AFunc,A_CLR_OXVEL
	LW	NSYDJP1_01B,1|AMulti
	LW	NSYDJP1_01C,1|AMulti
	LWL	1,4|AFunc,OBJ_OFF

	LWL	NST1_01A,1|AMulti|AFunc,A_THROW_SHUFFLE_OR_SPRING
	LW	NST1_01B,1|AMulti
	LW	NST1_01C,6

	LWL	1,1|AFunc,A_AnimGo+2,HEADON_SHUFFLE_ANIM


HEADON_STOP_ANIM
HEADON_SHOOT_ANIM

HEADON_DEATH_ANIM
	LW	NDIE1_01A,1|AMulti
	LWL	NDIE1_01B,1|AMulti|AFunc,OBJ_ON
	LWL	NDIE1_01C,1|AMulti|AFunc,OBJ_ON
	LWL	1,4|AFunc,OBJ_OFF

	LW	NDIE1_02A,1|AMulti
	LW	NDIE1_02B,1|AMulti
	LWL	1,4|AFunc,OBJ_OFF

	LWL	NDIE1_03A,1|AMulti|AFunc,A_CK_FALL
	LW	NDIE1_03B,1|AMulti
	LWL	NDIE1_03C,4|AFunc,OBJ_ON

ROCKET_DEATH_GROUND_WAIT
	LWLWL	1,1|AFunc,A_NGROUND_CK+3,0,ROCKET_DEATH_GROUND_WAIT

	LWL	NDIE1_04A,1|AMulti|AFunc,A_HIT_GROUND
	LWLL	NDIE1_04B,1|AMulti|AFunc,A_SOUNDZ+2,SND_GROUND_HIT
	LW	NDIE1_04C,4

	LWL	NDIE1_05A,1|AMulti|AFunc,A_CLR_ALL_Z
	LWL	1,1|AMulti|AFunc,OBJ_OFF
	LWL	1,60|AFunc,A_CLR_ALL_X

	LWL	1,1|AFunc,DELETE_ENEMY

HEADON_FALL_ANIM
	LW	NFALLA_01A,1|AMulti
	LW	NFALLA_01B,1|AMulti
	LW	NFALLA_01C,1|AMulti
	LWL	1,3|AFunc,OBJ_OFF
	
	LW	NFALLA_02A,1|AMulti
	LW	NFALLA_02B,1|AMulti
	LW	NFALLA_02C,3

	LW	NFALLA_03A,1|AMulti
	LW	NFALLA_03B,1|AMulti
	LW	NFALLA_03C,3

	LW	NFALLA_04A,1|AMulti
	LW	NFALLA_04B,1|AMulti
	LW	NFALLA_04C,3

	LW	NFALLA_05A,1|AMulti
	LW	NFALLA_05B,1|AMulti
	LW	NFALLA_05C,3

	LW	NFALLA_06A,1|AMulti
	LW	NFALLA_06B,1|AMulti
	LW	NFALLA_06C,1|AMulti
	LWL	NFALLA_06D,3|AFunc,OBJ_ON

	LWL	NFALLA_07A,1|AMulti|AFunc,A_SCREEN_CK
	LW	NFALLA_07B,1|AMulti
	LW	NFALLA_07C,1|AMulti
	LWL	1,3|AFunc,OBJ_OFF

	.LONG	0


	.IF AUSTRALIA

ANIM_NINJA_SBOMB_EXPLODE
	LWLLL	1,1|AFunc,A_SBOMB_BLOOD+4,0,40000H
	LWLL	1,1|AFunc,A_AnimGo+2,ANIM_NINJA_EXP_NOBLOOD
ANIM_NINJA_EXPLODE
	LWLLL	1,1|AFunc,A_BLOOD_SPLORCH+4,0,0
	LWL	1,1|AFunc,CLR_VEL
	LWLL	1,2|AFunc,A_SOUNDZ+2,SND_NINJA_EXP_SCREAM
ANIM_NINJA_EXP_NOBLOOD
	LWL	1,1|AFunc,DELETE_ENEMY

	.ELSE

ANIM_NINJA_SBOMB_EXPLODE
	LWLLL	1,1|AFunc,A_SBOMB_BLOOD+4,0,40000H
	LWLL	1,1|AFunc,A_AnimGo+2,ANIM_NINJA_EXP_NOBLOOD
ANIM_NINJA_EXPLODE
	LWLLL	1,1|AFunc,A_BLOOD_SPLORCH+4,0,0
	LWL	1,1|AFunc,CLR_VEL
	LWLL	1,2|AFunc,A_SOUNDZ+2,SND_NINJA_EXP_SCREAM
ANIM_NINJA_EXP_NOBLOOD
	LWLLLL	1,1|AFunc,A_PreFrag_Center+6,NINJA_PARTS_1,80h,60000h
	LWLLLL	1,1|AFunc,A_PreFrag_Center+6,NINJA_PARTS_2,500h,50000h
	LWL	1,1|AFunc,DELETE_ENEMY

	.ENDIF

**************************************************************************
*								         *
* 		Fragger Scripts						 *
*								         *
**************************************************************************

*
* Ninja blows up a little bit
*
NINJA_PARTS_1
	.long	ARM_SPIN,NINJA_CHUNK_ARM
	.word	OID_JUNK,1*800H+1*40H+FRGPAL+FRGGCOL

	.long	LEG_SPIN,NINJA_CHUNK_LEG
	.word	OID_JUNK,1*800H+1*40H+FRGPAL+FRGGCOL

	.long	0

*
* Ninja blows up some more
*
NINJA_PARTS_2
	.long	ARM_SPIN,NINJA_CHUNK_ARM
	.word	OID_JUNK,1*800H+1*40H+FRGPAL+FRGGCOL

	.long	HEAD_SPIN,NINJA_CHUNK_HEAD
	.word	OID_JUNK,1*800H+1*40H+FRGPAL+FRGGCOL

	.long	CHEST_SPIN,NINJA_CHUNK_LEG
	.word	OID_JUNK,1*800H+1*40H+FRGPAL+FRGGCOL
	
	.long	LEG_SPIN,NINJA_CHUNK_LEG
	.word	OID_JUNK,1*800H+1*40H+FRGPAL+FRGGCOL

	.long	0


**************************************************************************
*								         *
* 	NINJA_CHUNK							 *
* 									 *
* 	Frag func for a piece of the ninja.				 *
*								         *
**************************************************************************
NINJA_CHUNK_ARM
	MOVE	@LAB_RAT,A14,W
	JAZ	N_CHUNK			;BR = Not the special ninja

	MMTM	SP,A0,A8
	MOVE	A0,A8
	MOVI	NINARMB2,A0
	CALLA	CHANGE_PAL
	MMFM	SP,A0,A8

	JAUC	N_CHUNK
	
NINJA_CHUNK_LEG
	MOVE	@LAB_RAT,A14,W
	JAZ	N_CHUNK			;BR = Not the special ninja

	MMTM	SP,A0,A8
	MOVE	A0,A8
	MOVI	NINLEGB2,A0
	CALLA	CHANGE_PAL
	MMFM	SP,A0,A8

	JAUC	N_CHUNK

NINJA_CHUNK_HEAD
	MOVE	@LAB_RAT,A14,W
	JAZ	N_CHUNK			;BR = Not the special ninja

	MMTM	SP,A0,A8
	MOVE	A0,A8
	MOVI	NINHEDB2,A0
	CALLA	CHANGE_PAL
	MMFM	SP,A0,A8

	JAUC	N_CHUNK


*
* Ninja arm spin animation
*
ARM_SPIN
	LWLW	NINARM1,1|AFunc,A_INIT_AnimSLP+1,3
	LW	NINARM2,0
	LW	NINARM3,0
ARM_SPIN_LOOP
	LWLW	NINARM1,0|AFunc,A_TOGGLE_FLIP+1,M_FLIPV|M_FLIPH
	LW	NINARM2,0	
	LW	NINARM3,0

	LWLW	NINARM1,0|AFunc,A_TOGGLE_FLIP+1,M_FLIPV|M_FLIPH
	LW	NINARM2,0	
	LW	NINARM3,0

	LWLW	NINARM1,0|AFunc,A_TOGGLE_FLIP+1,M_FLIPV|M_FLIPH
	LW	NINARM2,0	
	LW	NINARM3,0

	LWLW	NINARM1,0|AFunc,A_TOGGLE_FLIP+1,M_FLIPV|M_FLIPH
	LW	NINARM2,0	
	LWLL	NINARM3,0|AFunc,A_AnimFrm+2,ARM_SPIN_LOOP

*
* Ninja leg spin animation
*
LEG_SPIN
	LWLW	NINLEG1,1|AFunc,A_INIT_AnimSLP+1,3
	LW	NINLEG2,0
	LW	NINLEG3,0
LEG_SPIN_LOOP
	LWLW	NINLEG1,0|AFunc,A_TOGGLE_FLIP+1,M_FLIPV|M_FLIPH
	LW	NINLEG2,0	
	LW	NINLEG3,0

	LWLW	NINLEG1,0|AFunc,A_TOGGLE_FLIP+1,M_FLIPV|M_FLIPH
	LW	NINLEG2,0	
	LW	NINLEG3,0

	LWLW	NINLEG1,0|AFunc,A_TOGGLE_FLIP+1,M_FLIPV|M_FLIPH
	LW	NINLEG2,0	
	LW	NINLEG3,0

	LWLW	NINLEG1,0|AFunc,A_TOGGLE_FLIP+1,M_FLIPV|M_FLIPH
	LWLW	NINLEG2,0|AFunc,A_INC_AnimSLP+1,8	
	LWLL	NINLEG3,0|AFunc,A_AnimFrm+2,LEG_SPIN_LOOP

*
* Ninja head spin animation
*
HEAD_SPIN
	LWLW	NINHEAD1,1|AFunc,A_INIT_AnimSLP+1,3
	LW	NINHEAD2,0
	LW	NINHEAD3,0
HEAD_SPIN_LOOP
	LWLW	NINHEAD2,0|AFunc,A_TOGGLE_FLIP+1,M_FLIPV
	LW	NINHEAD1,0	
	LWLW	NINHEAD2,0|AFunc,A_TOGGLE_FLIP+1,M_FLIPH
	LW	NINHEAD3,0	
	LWLW	NINHEAD2,0|AFunc,A_TOGGLE_FLIP+1,M_FLIPV
	LWLW	NINHEAD1,0|AFunc,A_TOGGLE_FLIP+1,M_FLIPH
	LW	NINHEAD2,0
	LW	NINHEAD3,0

	LWLW	NINHEAD2,0|AFunc,A_TOGGLE_FLIP+1,M_FLIPV
	LW	NINHEAD1,0	
	LWLW	NINHEAD2,0|AFunc,A_TOGGLE_FLIP+1,M_FLIPH
	LW	NINHEAD3,0	
	LWLW	NINHEAD2,0|AFunc,A_TOGGLE_FLIP+1,M_FLIPV
	LWLW	NINHEAD1,0|AFunc,A_TOGGLE_FLIP+1,M_FLIPH
	LWLW	NINHEAD2,0|AFunc,A_INC_AnimSLP+1,8
	LWLL	NINHEAD3,0|AFunc,A_AnimFrm+2,HEAD_SPIN_LOOP

*
* Ninja chest spin animation
*
CHEST_SPIN
	LWLW	NINCHEST1,1|AFunc,A_INIT_AnimSLP+1,3
	LW	NINCHEST2,0
	LW	NINCHEST3,0
CHEST_SPIN_LOOP
	LWLW	NINCHEST2,0|AFunc,A_TOGGLE_FLIP+1,M_FLIPV
	LW	NINCHEST1,0	
	LWLW	NINCHEST2,0|AFunc,A_TOGGLE_FLIP+1,M_FLIPH
	LW	NINCHEST3,0	
	LWLW	NINCHEST2,0|AFunc,A_TOGGLE_FLIP+1,M_FLIPV
	LWLW	NINCHEST1,0|AFunc,A_TOGGLE_FLIP+1,M_FLIPH
	LW	NINCHEST2,0
	LW	NINCHEST3,0

	LWLW	NINCHEST2,0|AFunc,A_TOGGLE_FLIP+1,M_FLIPV
	LW	NINCHEST1,0	
	LWLW	NINCHEST2,0|AFunc,A_TOGGLE_FLIP+1,M_FLIPH
	LW	NINCHEST3,0	
	LWLW	NINCHEST2,0|AFunc,A_TOGGLE_FLIP+1,M_FLIPV
	LWLW	NINCHEST1,0|AFunc,A_TOGGLE_FLIP+1,M_FLIPH
	LWLW	NINCHEST2,0|AFunc,A_INC_AnimSLP+1,8
	LWLL	NINCHEST3,0|AFunc,A_AnimFrm+2,CHEST_SPIN_LOOP


**************************************************************************
*								         *
* 		Stoned Ninja						 *
*								         *
**************************************************************************

**************************************************************************
*								         *
* 	PROC_STONED_NINJA						 *
* 									 *
* 	Process entry point to create a Stoned Ninja.			 *
* 									 *
*	A8 = Flip flags							 *
* 	A9 = Universe X							 *
* 	A10 = Universe Y						 *
* 	A11 = Universe Z						 *
*								         *
**************************************************************************
PROC_STONED_NINJA
	MOVI	STONE_NINJA_INIT,B0
	PUSH	A8
	CALLA	MULTIMAKE
	PULL	A6
	JRZ	PSN_EXIT		;BR = Could not create the dude

	MOVE	A11,A3

	MOVE	@ZREL_OFF,A14,L
	SRA	ZFRAC,A14
	ADD	A14,A3

	MOVE	A9,A1
	MOVE	A10,A2

	CALLA	SET_ANIPU		;Position him

	MOVE	A6,A0	
	CALLA	SET_FLPS

	CALLA	OBJ_ON_MULTI		;We create with the objects off

	CALLA	INSERT_OBJ		;Insert

PSN_EXIT
	DIE

*
* Object initialization table for the Stoned Ninja
*
STONE_NINJA_INIT
	.byte	 4, 0, 1, 0	;OBJCNT, PRCCNT, IMGPALCNT, PALCNT
	.long	STNGUYA		;IMGPAL
	.word	OID_JUNK, OM_COLL
	.LONG	DUMCOLL
*
*    .long	IMG
*    .word 		  OCTRL,  OFLAGS,   OZOFF, OPTION_FLAGS
*
	LWWWW	STNGUYA, DMAWNZ, M_NODISP|M_DBLSCL,	0, OM_ANIM
	.LONG	ANIM_STONE_WATCH
	LWWWW	STNGUYB, DMAWNZ, M_NODISP|M_DBLSCL,    -1, 0
	LWWWW	STNGUYC, DMAWNZ, M_NODISP|M_DBLSCL,    -2, 0
	LWWWW	STNGUYD, DMAWNZ, M_NODISP|M_DBLSCL,    -3, 0
	
ANIM_STONE_WATCH
	LWL	1,10|AFunc,A_STAY_TIL_ONSCRN	
	LWL	1,10|AFunc,A_STAY_TIL_OFFSCRN	
	LWL	1,1|AFunc,DELETE_OBJ

*
* Blue guy palettes
*
NINBLU64:
   .word   63 
   .word   00000h,063ffh,043feh,03ffdh,02ffch,037fbh,033fbh,02fd9h
   .word   02bb8h,02b97h,01b77h,00fb6h,01f55h,02ad2h,00313h,012b2h
   .word   00ad1h,00eaeh,0028fh,01a4eh,0024dh,0022ah,005cah,001c9h
   .word   00000h,05abeh,0463eh,035beh,0295eh,039b9h,02539h,01cfah
   .word   02936h,018d9h,018d5h,01093h,00852h,018aeh,00432h,00430h
   .word   0042eh,0042dh,01066h,00009h,00c45h,00007h,00005h,00003h
   .word   07f34h,07f13h,07691h,06a6fh,0622dh,05a0ch,055ebh,051cah
   .word   04989h,04588h,03d47h,03105h,030e4h,07fbfh,07f3fh

NINHEDB2:
   .word   32 
   .word   00000h,00421h,05adfh,039deh,0463eh,06b5dh,0253ah,04659h
   .word   01097h,031d6h,00d35h,00c74h,00873h,04a53h,00871h,02551h
   .word   00430h,0042eh,0318eh,0002dh,00026h,00002h,05826h,05000h
   .word   03c00h,03c26h,03969h,01800h,019adh,014c6h,00863h,065aeh

NINARMB2:
   .word   32 
   .word   00000h,039deh,0463eh,0253ah,03258h,00858h,01cf7h,02dd5h
   .word   004eeh,0042eh,00026h,06e16h,064a5h,06000h,0610bh,05488h
   .word   05064h,04800h,048a0h,01800h,07f34h,07af3h,072d1h,06eb0h
   .word   0666fh,0624eh,05a2dh,0560ch,051ebh,049aah,024c3h,03987h

NINLEGB2:
   .word   32 
   .word   00000h,0479fh,04bdfh,03f5fh,0371dh,01afdh,00adch,05b5bh
   .word   00a37h,02656h,01556h,001f5h,019d2h,00871h,02551h,004eeh
   .word   01d0ah,06bf9h,057f9h,064a5h,05314h,060e7h,05d67h,05821h
   .word   055aah,04800h,04841h,02c00h,01800h,07bffh,034c3h,018a6h


	.IF	0

**************************************************************************
*								         *
* 		Big, in yo' face, pop-up Ninja				 *
*								         *
**************************************************************************

BIGBOY_Z	EQU	ZMAX_KLUDGE+0100H

BIG_POS_TABLE
	.LONG	BIGBOY_Z*(SCRWIDTH*1/6-HALFX),BIGBOY_Z*(SCRWIDTH*3/6-HALFX)
	.LONG	BIGBOY_Z*(SCRWIDTH*5/6-HALFX)

*
* Some data for the big guy
*
OBIGPOS		EQU	ODATA+0A0H	;UHW POSITION INDEX
OBIGYON		EQU	ODATA+0C0H	;UHL WORLD Y POPUP ON POSITION
OBIGYOFF	EQU	ODATA+0E0H	;UHL WORLD Y POPUP OFF POSITION
OBIGYVEL	EQU	ODATA+100H	;UHL UPWARD Y VELOCITY

**************************************************************************
*								         *
* 	PROC_BIG_NINJA							 *
* 									 *
* 	Process to decide when to throw up a big ninja.			 *
*								         *
**************************************************************************
PROC_BIG_NINJA
	CLR	A9				;CLEAR BIGBOY POSITION FLAGS
	MOVE	A9,@NINJA_POPS,W		;CLEAR BIGBOY COUNT
BWP_LUPE
	MOVK	10,A1
	MOVI	60,A0
	CALLA	RANGERND
	CALLA	PRCSLP				;RANDOM SLEEP

	MOVE	@NINJA_POPS,A10,W
	JRZ	BWP_CHECK_QUOTA			;BR=NONE READY

	MOVE	@HOLD_ENEMY_DISPATCH,A14,W
	JRNZ	BWP_CHECK_QUOTA			;BR=HOLD ON THERE

	MOVE	@ZSCROLL,A14,L
	JRNZ	BWP_CHECK_QUOTA			;BR = No popping when in Z
	
	CMPK	0111B,A9
	JREQ	BWP_CHECK_QUOTA			;BR=ALL POSITIONS FILLED

	MOVI	POP_NINJA_INIT,B0		;ALLOCATE OBJECT
	CALLA	CREATE_ENEMY
	JRZ	BWP_CHECK_QUOTA			;BR=CAN'T DO IT

	MOVE	A13,*A8(OPLINK),L

	CLR	A0
	MOVK	3,A1
	MOVI	BIG_LIST,A2
BWP_MAKE_LIST
	DEC	A1
	JRN	BWP_PICK			;BR=DONE PICKIN'
	BTST	A1,A9
	JRNZ	BWP_MAKE_LIST			;BR=NOT OPEN
	INC	A0				;COUNT ENTRY
	MOVE	A1,*A2+,W			;ENTER IN LIST
	JRUC	BWP_MAKE_LIST
BWP_PICK
	CALLA	RAND0				;PICK INDEX
	SLL	4,A0				;TRANSLATE TO OFFSET
	ADDI	BIG_LIST,A0
	MOVE	*A0,A0,W			;GET POSITION FROM LIST
	MOVK	1,A14
	SLL	A0,A14
	OR	A14,A9				;FLAG POSITION PICKED
	MOVE	A14,*A8(OBIGPOS),W		;POSITION PICKED

	SLL	5,A0				;TRANSLATE TO OFFSET
	ADDI	BIG_POS_TABLE,A0
	MOVE	*A0,A1,L			;GET WORLD X POSITION
					
	MOVE	@XBASE,A14,L
	ADD	A14,A1

	MOVE	@XSCROLL,A14,L
	ADD	A14,A1

	MOVI	BIGBOY_Z,A3
	MOVI	256+150,A5
	STOWY	A3,A5
	MOVE	A5,A2
	MOVE	A2,*A8(OBIGYOFF),L		;OFF SCREEN WORLD Y

	MOVI	256,A7
	STOWY	A3,A7
	MOVE	A7,*A8(OBIGYON),L		;ON SCREEN WORLD Y

	SUB	A5,A7
	MOVK	15,A14
	DIVS	A14,A7
	MOVE	A7,*A8(OYVEL),L
	MOVE	A7,*A8(OBIGYVEL),L		;UPWARD Y VELOCITY

	MOVE	@YBASE,A14,L
	SUB	A14,A2
		
	MOVE	@ZBASE,A14,L
	ADD	A14,A3

	CALLA	SET_ANIPU			;SET POSITION

	MOVE	@RAND,A0,W			;LEFTY OR RIGHTY?
	ANDI	M_FLIPH,A0
	CALLA	SET_FLPS

	MOVI	0101H,A4			;SET FLASH COLOR
	CALLA	SET_OCONST

	MOVI	ANIM_BIG_NINJA_POPUP,A1		;POP UP ANIMATION
	CALLA	STRT_ANIM

	CALLA	INSERT_ENEMY

	DEC	A10
	MOVE	A10,@NINJA_POPS,W

BWP_CHECK_QUOTA
	MOVE	@ENEMY_QUOTA,A14,W
	JRZ	BWP_LUPE			;BR=NO QUOTA YET
BWP_BIGBOY_WAIT
	SLEEP	1
	MOVE	A9,A9
	JRNZ	BWP_BIGBOY_WAIT			;BR=SOME BIGBOYS STILL ACTIVE

	DIE

**************************************************************************
*								         *
* A_CHECK_BIGUP - CHECK IF BIGBOY DONE COMIN' ON SCREEN			 *
*								         *
* PASS:									 *
* A8 = OBJECT								 *
*								         *
**************************************************************************

A_CHECK_BIGUP
	MOVE	*A8(OYVAL),A0,L			;CURRENT Y
	MOVE	*A8(OBIGYON),A1,L		;ON SCREEN Y DESTINATION
	MOVE	@YBASE,A14,L
	ADD	A14,A1				;TRANSLATE TO UNIVERSE
	CMP	A1,A0
	JRGT	ACBU_DONE			;BR=NOT UP YET
	CLR	A14
	MOVE	A14,*A8(OYVEL),L		;STOP Y MOTION
	CALLA	SET_ANIPYU			;SET Y POSITION TO DESTINATION	

;	MOVI	BIGBOY_GUNVECT,A1		;ENABLE VECTORS
;	MOVI	BIGBOY_CVECT,A2
;	CALLA	SET_VECTORS

	MOVE	*A8(OPARTS),A0,L
	MOVI	ANIM_BIG_NINJA_WATCH,A1
	CALLA	STRTANIM			;Start part watching us

	MOVI	30,A14				;INITIAL SLEEP BEFORE ATTACK
	MOVB	A14,*A8(AnimSlp)
	MOVI	ANIM_BIG_NINJA_ATTACK,A1	;SHOOTIN' ANIMATION
	MOVE	A1,*A8(AnimFrm),L
	MOVE	A1,*A8(AnimScr),L
ACBU_DONE
	RETS

**************************************************************************
*								         *
* A_BIGBOY_POPDOWN - START BIGBOY GOIN' OFF SCREEN			 *
*								         *
* PASS:									 *
* A8 = OBJECT								 *
*								         *
**************************************************************************

A_BIGBOY_POPDOWN
	MOVE	*A8(OBIGYVEL),A14,L		;SET DOWNWARD Y MOTION
	NEG	A14				;OPPOSITE DIRECTION
	SLL	1,A14				;FASTER BY TIMES 2
	MOVE	A14,*A8(OYVEL),L

	MOVI	ANIM_BIG_NINJA_POPDOWN,A1		;GOIN' DOWN ANIMATION
	MOVE	A1,*A8(AnimFrm),L
	MOVE	A1,*A8(AnimScr),L
	RETS

**************************************************************************
*								         *
* A_CHECK_BIGDOWN - CHECK IF BIGBOY DONE GOIN' OFF SCREEN		 *
*								         *
* PASS:									 *
* A8 = OBJECT								 *
*								         *
**************************************************************************

A_CHECK_BIGDOWN
	MOVE	*A8(OYVAL),A0,L			;CURRENT Y
	MOVE	*A8(OBIGYOFF),A1,L		;OFF SCREEN Y DESTINATION
	MOVE	@YBASE,A14,L
	ADD	A14,A1				;TRANSLATE TO UNIVERSE
	CMP	A1,A0
	JRLT	ACBD_DONE			;BR=NOT DOWN YET

	MOVE	*A8(OPLINK),A0,L		;GET STARTING PROCESS
	MOVE	*A8(OBIGPOS),A14,W		;GET POSITION FLAG
	MOVE	*A0(PA9),A9,W			;GET CURRENT POSITION FLAGS
	ANDN	A14,A9				;TURN OFF POSITION	
	MOVE	A9,*A0(PA9),W			;SET POSITION FLAGS
	CLR	A14
	MOVE	A14,*A8(OPLINK),L		;CLEAR STARTING PROCESS
	MOVE	*A8(OPLAYER),A14,L
	JAZ	DEL_ENEMY_NOAUD			;BR=NOT KILLED BY PLAYER		
	JAUC	DELETE_ENEMY
ACBD_DONE
	RETS

**************************************************************************
*								         *
* 	A_CHECK_BIG_AWAY						 *
* 									 *
* 	Anim func to check if we should disappear now.			 *
* 									 *
* 	A8 = Ptr to any part						 *
*								         *
**************************************************************************
A_CHECK_BIG_AWAY
	MOVE	@HOLD_ENEMY_DISPATCH,A14,W
	JRNZ	ACBA_GO_AWAY

	MOVE	@ZSCROLL,A14,L
	JRNZ	ACBA_GO_AWAY
	
	MOVB	*A8(OFLAGS),A14
	JRN	ACBA_GO_AWAY

	RETS

ACBA_GO_AWAY
	CALLA	GET_HEAD_PART	

	JRUC	A_BIGBOY_POPDOWN


*
* Big Ninja initialization
*
POP_NINJA_INIT
	.byte	 4, 0, 0, 2		;OBJCNT, PRCCNT, IMGPALCNT, PALCNT
	.long	NINYEL64, NUNCHUK	;Palettes we must have
	.word	OID_NINJA, OM_COLL	;OID, GLOBAL_OPTIONS
;	.LONG	BIG_NINJA_CVECT
	.LONG	DUMCOLL
*        .long IMG
*        .word OCTRL, OFLAGS, OZOFF
*        .word OPTIONS 
	LWWWW	NCUCHUK_01A, DMAWNZ, M_NOSCALE|M_NOPIXSCAN, 0, OM_GUNV
	.LONG	DUMRETS
	LWWWW	NCUCHUK_01B, DMAWNZ, M_NOSCALE|M_NOPIXSCAN, 1, OM_PRVGUNV
	LWWWW	NCUCHUK_01C, DMAWNZ, M_NOSCALE|M_NOPIXSCAN, 0, OM_PRVGUNV
	LWWWW	CHUK1, DMAWNZ, M_NOSCALE|M_NOPIXSCAN|M_NODISP, 0, OM_PRVGUNV

ANIM_BIG_NINJA_POPUP
	LWL	1,1|AFunc,A_CHECK_BIGUP
	.long	0

ANIM_BIG_NINJA_POPDOWN
	LWL	1,1|AFunc,A_CHECK_BIGDOWN
	.long	0

ANIM_BIG_NINJA_WATCH
	LWL	1,1|AFunc,A_CHECK_BIG_AWAY
	.LONG	0

ANIM_BIG_NINJA_ATTACK
	LW	1,10
	.LONG	0
	
ANIM_BIG_NINJA_DEATH
	LWL	1,1|AFunc,A_BIGBOY_POPDOWN



**************************************************************************
*								         *
* 	PROC_NINJA_ROPE							 *
* 									 *
* 	Process to start a rope swinging Ninja.				 *
* 									 *
* 	A9 = Starting side, 0 = From Left, 1 = From Right		 *
*								         *
**************************************************************************
PROC_NINJA_ROPE
	MOVE	@HOLD_ENEMY_DISPATCH,A14,W
	JANE	SUCIDE

;	MOVI	ROPE_INIT,B0
	CALLA	MULTIMAKE
	JAZ	SUCIDE			;BR = No rope to swing on

	MOVI	8000H,A1
	UNIVZ	A1			;Set Z for 1 to 1

	MOVE	A9,A9
	JRNZ	PBR_ROPE_RIGHT

	MOVI	M_FLIPH,A0
	CALLA	SET_FLPS

	MOVI	[30,100],A1
	JRUC	PBR_SETUP_ROPE

PBR_ROPE_RIGHT
	MOVI	[30,200],A1

PBR_SETUP_ROPE
	CALLA	SET_SCRN_POS

	CALLA	INSERT_OBJ

	DIE

	CALLA	CREATE_ENEMY
	MMFM	SP,A6,A7		;Preserve status please
	JRZ	PBH_EXIT		;BR = Could not create the dude

	MOVI	NINJA_INIT,B0
	CALLA	CREATE_ENEMY
	MMFM	SP,A6,A7		;Preserve status please
	JRZ	PBH_EXIT		;BR = Could not create the dude

	.ENDIF

	.END

