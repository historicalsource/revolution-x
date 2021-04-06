 	.MLIB	"GXMACS.LIB"
	.FILE	"GXCOG.ASM"
	.TITLE	"<<< GENERATION X -- COGHEAD ENEMY >>>"
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
	.INCLUDE	"GXNATV.H"
	.INCLUDE	"IMGTBL.GLO"
	.INCLUDE	"GXCOG.TBL"

***** In this file

	.DEF	COG_BUSTER, COG_PROC, HIT_ENEMY, COG_BOUNCER, PROC_COG_BABBLE
	.DEF	PROC_COG_GARAGE_LEFT, PROC_COG_GARAGE_RIGHT
	.DEF	PROC_COG_NO_STOP, AU_CREATE_COG_BRIDGE, TAB_JBRIDGE
	.DEF	A_CLR_ALL_Z, A_CLR_ALL_X, OBJ_DRAWBITS_MULTI
	.DEF	A_HIT_GROUND, A_GROUND_CK, STORE_OCONST, A_SOUNDZ_ONSCREEN
	.DEF	PROC_COG_DESERT, COG_PROC_UNIV

***** from GXRAM.ASM
	.REF	WAVETIME, RAND, P1DATA, NPLAYERS, ENEMY_QUOTA, SUBWAVE
	.REF	OBJENEMIES, BASE_HIT, WAVE

***** from GXUNIFX.ASM
	.REF	WALL_EXPLODE
	
***** from GXAFUNC.ASM
	.REF	A_SOUND, A_SOUNDZ, SetAnim, A_SET_OZVEL, A_Set_Rel_Word
	.REF	A_OBJ_OFF_CHANGE_PAL, SetAnim_AFARG, A_OFFOPP_DEL
	.REF	A_Set_Rel_Word_Head, A_Set_Rel_Byte_Head, A_RAND_REL_BYTE
	.REF	A_TOGGLE_FLPS, A_FLIP_BRANCH, A_OFFOPP, A_SET_REL_LONG_HEAD
	.REF	A_Set_AnimLoop, A_Anim_DSJ, A_Set_Var_Word
	.REF	A_CREATEP_R

***** from GXSND.ASM
	.REF	ONESND_Z, ONESND

***** from GXD.ASM
	.REF	XSCROLL, YSCROLL, XBASE, ZBASE, GETHEADPART, SET_SCRN_POS
	.REF	GET_SHAD_MULTI, SET_ANIPU, YWORLD

***** from GXENEMY.ASM
	.REF	INSERT_ENEMY, CREATE_ENEMY, DEL_ENEMY_NOAUD, DELETE_ENEMY
	.REF	EGUN_FLASH_MULTI

***** from GXPLAYER.ASM
	.REF	CK_PLAYER_HIT, PLAYER_HIT	

***** from GX.ASM
	.REF	GPLAYNUM

***** from GXUTIL.ASM
	.REF	SET_VECTORS, GET_TSUL_SCRN

***** from GXPALL.ASM
	.REF	A_CHANGE_PAL

***** from GXDESK.ASM
	.REF	DGV_FRAG_SPARK

***** from GXJUNGLE.ASM
	.REF	JXLIMIT, BRIDGE_DESTROYED

***** from GXBEEK2.ASM
	.ref	IN_SECRET	       

***** from GXUNIV.ASM
	.ref	UNIV_DISAB_ENEMY_GEN   

***** from GXPOWER.ASM
	.REF	THROW_SHIELD

*
* COG RAM
*

	.BSS	SPEAK_AT_PLAYER,16	;If one then we can speak at player
	.BSS	UNUSED_WORD,16		;For alignment


	.TEXT

*
* Coghead Object data area
*	Note: Any fields named the same as the Berzerker should
*		use the same offset.
*
OHITS		.EQU	ODATA		;UHL GUN HIT COUNTER:
					;0-7:P1 HITS, 8-15:P2 HITS
					;16-23:P3 HITS, 24-31:P4 HITS

OMISSES		.EQU	ODATA+020H	;UHB Number of consec. missed shots
OCHEWED_ROCKET	.EQU	ODATA+028H	;UHB Means that a rocket hit him
OBURSTCNT	.EQU	ODATA+030H	;UHB Number of bursts left, if hitting
ORAPIDCNT	.EQU	ODATA+038H	;UHB Current rapid fire shots left
OSKATELOOPS	.EQU	ODATA+040H	;UHB Number of current skate cycles
OSPINNING	.EQU	ODATA+048H	;UHB Currently in a spin
OSTART_GLIDE	.EQU	ODATA+050H	;UHB Full vel skate strokes 'til glide
OGLIDING	.EQU	ODATA+058H	;UHB This says we should be gliding
ONO_STOP	.EQU	ODATA+060H	;UHB This is a non-stopper guy
OJUMPING	.EQU	ODATA+068H	;UHB We are currently jumping

OSRUNVEL	.EQU	ODATA+080H	;UHL SIDE RUN VELOCITY

OHRUNVEL	.EQU	ODATA+0A0H	;UHL HEADON RUN VELOCITY

OJUMP_SLEEP	.EQU	ODATA+0C0H	;UHW Remaining jump sleep
OEFLAGS		.EQU	ODATA+0D0H	;UHW ENEMY FLAGS

OJUMPTAB	.EQU	ODATA+0E0H	;UHL Table of Jump positions

OSHOOT_ANIM	.EQU	ODATA+100H	;UHL USE THIS ANIMATION TO SHOOT
ODEATH_ANIM	.EQU	ODATA+120H	;UHL USE THIS ANIMATION FOR DEATH
OBLOCK_ANIM	.EQU	ODATA+140H	;UHL USE THIS ANIMATION FOR BLOCKING
OSTOP_ANIM	.EQU	ODATA+160H	;UHL USE THIS ANIMATION FOR STOPPING

OSHOOT_TIME	.EQU	ODATA+180H	;UHW TIME SPENT SHOOTING
OLAST_BLOCK_TIME .EQU	ODATA+190H	;UHW TIME SINCE LAST BLOCK
OLAST_HIT_TIME	.EQU	ODATA+1A0H	;UHW TIME SINCE LAST BULLET HIT

OXORIG		.EQU	ODATA+1B0H	;UHW Origination universe X
OXLIMIT		.EQU	ODATA+1C0H	;UHW If <> 0 then this is X travel
OYENEMY		.EQU	ODATA+1D0H	;UHW Universe Y position of enemy

OXACCEL		.EQU	ODATA+1E0H	;SHW X acceleration
OZACCEL		.EQU	ODATA+1F0H	;SHW Z acceleration
;ENEMY FLAGS
*
*HMMMM I WONDER WHAT DOZER'S MOTHER WOULD SAY IF SHE READ SOME OF THIS?
*
B_SIDE		EQU	0		;DIRECTION
					;0 = HEADON MOTHER FUCKER
					;1 = SIDEWAYS MELLOW DUDE
B_BRIDGE	EQU	1		;Bridge dwelling Coghead
B_BOUNCER	EQU	2		;Bouncer type Cog Head
B_FALLING	EQU	3		;NONBOY FALLING FROM SKY
B_FLIP		EQU	4		;HORIZONTALLY FLIPPED OUT WACKO
B_BUSTER	EQU	5		;Bust through wall Cog Head
B_BLOCKING	EQU	6		;IF=1, THEN COGHEAD IS BLOCKING
B_INVINCIBLE	EQU	7		;IF=1, THEN COGHEAD IS INVINCIBLE


M_SIDE		EQU	001H
M_BRIDGE	EQU	002H
M_BOUNCER	EQU	004H
M_FALLING	EQU	008H
M_FLIP		EQU	010H
M_BUSTER	EQU	020H
M_BLOCKING	EQU	040H
M_INVINCIBLE	EQU	080H

HRUNVEL	EQU	-0140H		;HEADON RUN VELOCITY
SRUNVEL_MIN	EQU	01D000H		;SIDE RUN (TO THE RIGHT) VELOCITY 
SRUNVEL_MAX	EQU	01F000H		;SIDE RUN (TO THE RIGHT) VELOCITY 

SKATE_XACCEL	EQU	1800H		;Skating X acceleration
SKATE_XFRICTION	EQU	-200H		;Skating X friction decel
SKATE_XBRAKE	EQU	-1000H		;Skating X braking decel
SKATE_MIN_XVEL	.EQU	10000H		;Min vel your allowed to go

SKATE_ZFRICTION	EQU	80H		;Skating X friction decel
SKATE_ZACCEL	EQU	-200H		;Skating X acceleration

JUMP_MIN_YVEL	.EQU	08000H		;Absolute jumping velocity

SHOOTCNT	EQU	3

COG_FRAME_TIME	.EQU	5		;BASE SLEEP TIME BETWEEN FRAMES
					;!!WARNING!! - VALUE MUST BE > 2
COG_HITS_TO_KILL EQU	7		;HITS REQUIRED TO KILL COG HEAD

COG_FLASH_COLOR	EQU	0101H		;FLASH COLOR FOR COGHEAD

SHORT_DEATH_ZVEL .EQU	1C0H
LONG_DEATH_ZVEL	 .EQU	2C0H

**************************************************************************
*								         *
* 	PROC_COG_NO_STOP						 *
* 									 *
* 	Process to create a Cog Head that doesn't stop.			 *
* 									 *
* 	Input the same as COG_PROC					 *
*								         *
**************************************************************************
PROC_COG_NO_STOP
	MOVI	OID_COG,A0
	CALLA	GET_ENEMY_COUNT
	CMPK	4,A0
	JAHS	SUCIDE

	MOVI	COG_INIT,B0		;ALLOCATE OBJECT
	CALLA	CREATE_ENEMY
	JRZ	CP_EXIT			;NOTHING CLEAN, RIGHT.
	
	MOVKB	1,*A8(ONO_STOP)		;Mark this guy as a no stopper
	JRUC	COG_PROC_GO

**************************************************************************
*								         *
* COG_PROC	- PROCESS TO CREATE A COG HEAD				 *
* 									 *
* PASS:									 *
* A9  = SCREEN X POSITION TO START, IF 0, THEN PROCESS PICKS.		 *
* A10 = [ZMAX>>4,ZMIN>>4] LIMITS ON Z.					 *
* A11 = Z POSITION TO START, IF 0, THEN RANDOM BETWEEN ZMAX AND ZMIN.	 *
*								         *
**************************************************************************
COG_PROC_UNIV:		      ; same as COG_PROC only a10 = univ z
	move	@ZBASE,a0,L
	move	a11,a11
	jrz	noZgiven
	sub	a0,a11		; turn Z into world
noZgiven:
	srl	4,a0		; adjust Z max and Z min
	move	a0,a1
	sll	16,a1
	movy	a1,a0
	subxy	a0,a10

COG_PROC
	MOVI	OID_COG,A0
	CALLA	GET_ENEMY_COUNT
	CMPK	4,A0
	JAHS	SUCIDE

	MOVI	COG_INIT,B0		;ALLOCATE OBJECT
	CALLA	CREATE_ENEMY
	JRZ	CP_EXIT			;NOTHING CLEAN, RIGHT.

COG_PROC_GO
	MOVE	A11,A11			;WERE WE GIVEN A Z POSITION?
	JRNZ	CP_USEZ			;BR = YES, SO USE IT. YOU SHHHHOULD!

	MOVX	A10,A1			;TO RANDOMLY PICK A POSITION
	SEXT	A1
	SLL	4,A1
	MOVE	A10,A0
	SRA	16,A0
	SLL	4,A0
	CALLA	RANGERND
	MOVE	A0,A11			;WE'VE GOT IT

CP_USEZ
	UNIVZ	A11
CP_HOOK
	MOVI	SRUNVEL_MAX,A0
	MOVI	SRUNVEL_MIN,A1
	CALLA	RANGRAND
	MOVE	A0,*A8(OSRUNVEL),L	;SET SIDE VELOCITY

	MOVE	@XSCROLL,A14,L		;Add Scroll Velocity to base Velocity
	MOVE	A14,A1
	ABS	A14			;Positive values needed here
	ADD	A14,A0

	CLR	A6

	MOVE	A9,A9			;Check starting X position
	JRNZ	CP_GIVEN_X		;BR = X was passed by the Caller

	MOVE	A1,A1			;Appearing side based on scroll direction
	JRN	CP_RIGHTX		;Scrolling LEFT, then appear RIGHT
	JRNZ	CP_LEFTX		;Scrolling RIGHT, then appear LEFT
	MOVE	@RAND,A14,W		;Not Scrolling, pick RANDOM
	JRN	CP_RIGHTX
CP_LEFTX
	MOVI	-50,A9
	JRUC	CP_LEFT_SETUP
CP_RIGHTX
	MOVI	450,A9
	JRUC	CP_RIGHT_SETUP
CP_GIVEN_X
	JRN	CP_LEFT_SETUP

	CMPI	399,A9
;	JRLS	CP_NORIGHT	;<*** ADD THIS FOR RANDOM HEAD-ON GUY
*
* Cog head from the RIGHT
*
CP_RIGHT_SETUP
	MOVK	M_FLIPH,A6		;Flip him for Right/Left motion
	NEG	A0			;Oh! A negative X velocity would help
*
* Cog head - Jump here = he's from the LEFT. Fall through = he's from RIGHT
*
CP_LEFT_SETUP
	MOVK	M_SIDE,A7		;Mark him as a SIDE guy
;	MOVE	A0,*A8(OXVEL),L
	MOVI	SIDE_SKATE_ANIM,A1
	MOVIM	SIDE_DEATH_ANIM,*A8(ODEATH_ANIM),L
	MOVIM	SIDE_SPIN_STOP,*A8(OSTOP_ANIM),L
	MOVIM	SIDE_GLIDE_SHOOT,*A8(OSHOOT_ANIM),L
	JRUC	CP_DIRSET

*This guy will be a HEAD-ON man
CP_NORIGHT
	CLR	A7			;START AT HORIZON
	MOVE	A14,*A8(OZVEL),L
	MOVI	HEADON_SKATE_ANIM,A1
	MOVIM	HEADON_DEATH_ANIM,*A8(ODEATH_ANIM),L
	MOVIM	HEADON_STOP_ANIM,*A8(OSTOP_ANIM),L
	MOVIM	HEADON_SHOOT_ANIM,*A8(OSHOOT_ANIM),L
CP_DIRSET
	CALLA	STRT_ANIM		;START ANIMATION


	MOVE	A9,A1
	CALLA	SET_SCRN_POS		;AND PUT THE GUY THERE

	CALLA	SET_ONGRND		;And set him on the ground	

	MOVE	A7,*A8(OEFLAGS),W

	BTST	B_SIDE,A7
	JRZ	CP_SETCTRL
	MOVE	A6,A0	
CP_SETCTRL
	CALLA	SET_FLPS

	MOVI	COG_FLASH_COLOR,A1
	CALLR	STORE_OCONST		;STORE THE PROPER VALUE FOR CONSTANT

	CALLA	OBJ_ON_MULTI		;We create with the objects off

;	move	@WAVE,a14
;	cmpk	6+DEBUG,a14
;	jrge	CP_noshad
	CALLA	GET_SHAD_MULTI		;Setup his shadow
;CP_noshad:

	CALLA	INSERT_ENEMY		;INSERT AND COUNT ENEMY
	JRUC	COG_WATCH

CP_EXIT
	DIE

**************************************************************************
*								         *
* 	PROC_COG_DESERT							 *
* 									 *
* 	Cog head to start on the left side of the screen		 *
* 	in the bus wave							 *
* 									 *
* 	A11 = Universe Z						 *
*								         *
**************************************************************************
PROC_COG_DESERT
	movi	-10,a9			; screen starting x
	STOUX	a11,a9			; convert to universe
	move	@YWORLD,a10,L

	CLR	A8
	MOVE	A8,*A13(PDATA),L	;Store our jump table

	MOVI	COG_INIT,B0		;Get us one
	CALLA	CREATE_ENEMY
	JRZ	CP_EXIT			;BR = None to be had

	MOVKB	1,*A8(ONO_STOP)		;Mark this guy as a no stopper

	JRUC	PROC_COG_hk

**************************************************************************
*								         *
* 	PROC_COG_GARAGE_LEFT						 *
* 									 *
* 	Cog head to start on the left side of the parking garage	 *
* 	in L.A.								 *
* 									 *
* 	A9  = Universe X						 *
* 	A10 = Universe Y						 *
* 	A11 = Universe Z						 *
*								         *
**************************************************************************
PROC_COG_GARAGE_LEFT
	MOVI	TAB_GARAGE_LEFT,A8
	JRUC	PROC_COG_JUMP

**************************************************************************
*								         *
* 	PROC_COG_GARAGE_RIGHT						 *
* 									 *
* 	Cog head to start on the right side of the parking garage	 *
* 	in L.A.								 *
* 									 *
* 	A9  = Universe X						 *
* 	A10 = Universe Y						 *
* 	A11 = Universe Z						 *
*								         *
**************************************************************************
PROC_COG_GARAGE_RIGHT
	MOVI	TAB_GARAGE_RIGHT,A8
	JRUC	PROC_COG_JUMP

**************************************************************************
*								         *
* 	PROC_COG_JUMP							 *
* 									 *
* 	Process to create a jumping Cog Head				 *
* 									 *
* 	A8  = Ptr to jump table						 *
* 	A9  = Universe X						 *
* 	A10 = Universe Y						 *
* 	A11 = Universe Z						 *
*								         *
**************************************************************************
PROC_COG_JUMP
	MOVE	A8,*A13(PDATA),L	;Store our jump table

	MOVI	COG_INIT,B0		;Get us one
	CALLA	CREATE_ENEMY
	JRZ	CP_EXIT			;BR = None to be had

PROC_COG_hk:

	MOVE	A11,A3
	MOVE	A10,A2
	MOVE	A9,A1
	CALLA	SET_ANIPU		;Position him

	SRA	16,A10
	MOVE	A10,*A8(OYENEMY),W	;Store the integer landing line

	MOVIM	1C000H,*A8(OSRUNVEL),L

	CLR	A6

	MOVE	*A13(PDATA),A4,L	;Get the jump table
	jrz	PCJ_LEFT

	MOVE	*A4+,A14,W		;Grab the direction
	JRZ	PCJ_LEFT
*
* Cog head from the RIGHT
*
	MOVK	M_FLIPH,A6		;Flip him for Right/Left motion
*
* Cog head - Jump here = he's from the LEFT. Fall through = he's from RIGHT
*
PCJ_LEFT
	MOVE	A4,*A8(OJUMPTAB),L	;Store the jump table for later

	MOVK	M_SIDE,A7		;Mark him as a SIDE guy
	MOVIM	SIDE_DEATH_ANIM,*A8(ODEATH_ANIM),L
	MOVIM	SIDE_SPIN_STOP,*A8(OSTOP_ANIM),L
	MOVIM	SIDE_GLIDE_SHOOT,*A8(OSHOOT_ANIM),L

	MOVI	COG_JUMPSTART_ANIM,A1
	CALLA	STRT_ANIM		;START ANIMATION

	MOVE	A7,*A8(OEFLAGS),W

	MOVE	A6,A0	
	CALLA	SET_FLPS

	MOVI	COG_FLASH_COLOR,A1
	CALLR	STORE_OCONST		;STORE THE PROPER VALUE FOR CONSTANT

	CALLA	OBJ_ON_MULTI		;We create with the objects off

	CALLA	INSERT_ENEMY		;INSERT AND COUNT ENEMY

	JRUC	COG_WATCH

**************************************************************************
*								         *
* 	Universe anim func to create a Cog Head that will run		 *
* 	along the bridge. Direction is taken from H-flip of		 *
* 	generator.  Position is offset from generator position.		 *
* 									 *
* 	AARG+,W	= relative universe X limit				 *
* 	AARG+,W	= X offset						 *
* 	AARG+,W	= Y offset						 *
* 	AARG+,L = Bridge jump table					 *
*								         *
**************************************************************************
AU_CREATE_COG_BRIDGE
	move	@IN_SECRET,a14
	janz	UNIV_DISAB_ENEMY_GEN	; if in secret room, disab this enemy

	MOVE	@OBJENEMIES,A14,W
	BTST	B_OF_BCOG,A14
	JRZ	ACCB_ABORT		;BR = not allowed, yet
	
	MOVI	OID_COG,A0
	CALLA	GET_ENEMY_COUNT
	CMPK	6,A0
	JRHS	ACCB_ABORT		;BR = There are to many Cog's around

	PUSH	A8
	MOVI	COG_INIT,B0		;Get us one
	CALLA	CREATE_ENEMY
	PULL	A2			;A2=obj block of creator, 
					;pull must preserve status.
	JRZ	ACCB_ABORT		;BR = Object not created.

	MOVI	SRUNVEL_MAX,A0
	MOVI	SRUNVEL_MIN,A1
	CALLA	RANGRAND
	MOVE	A0,*A8(OSRUNVEL),L	;SET SIDE VELOCITY

	MOVE	*A2(OCTRL),A14
	BTST	B_FLIPH,A14
	JRZ	ACCB_NOFLIP

	MOVI	M_FLIPH,A0	
	CALLA	SET_FLPS

ACCB_NOFLIP
*
*	set position
*
	MOVE	A8,A9
	MOVE	A2,A8
	CALLA	GETAFARG_WORD		;Get distance limit
	JRNN	ACCB_STUFF_XLIM		;BR = Got it
	MOVE	@JXLIMIT,A0,W		;Use the global set for us
ACCB_STUFF_XLIM
	MOVE	A0,*A9(OXLIMIT),W

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

	CALLA	SET_ANIPU

	SRA	16,A1
	MOVE	A1,*A8(OXORIG),W	;Store the integer starting univ X
	SRA	16,A2
	MOVE	A2,*A8(OYENEMY),W	;Store the integer landing line

	MOVIM	SIDE_DEATH_ANIM,*A8(ODEATH_ANIM),L
	MOVIM	SIDE_SPIN_STOP,*A8(OSTOP_ANIM),L
	MOVIM	SIDE_GLIDE_SHOOT,*A8(OSHOOT_ANIM),L

	MOVI	SIDE_SKATE_ANIM,A1
	CALLA	STRT_ANIM		;START ANIMATION

	MOVIM	M_SIDE|M_BRIDGE,*A8(OEFLAGS),W	;Give this enemy some personality

	MOVKB	1,*A8(ONO_STOP)		;Mark this guy as a no stopper

	CALLA	OBJ_ON_MULTI		;We create with the objects off

	CALLA	INSERT_ENEMY		;INSERT AND COUNT ENEMY

	MOVI	COG_FLASH_COLOR,A1
	CALLR	STORE_OCONST		;STORE THE PROPER VALUE FOR CONSTANT

	CREATE	PID_COG,COG_WATCH
	MOVE	A0,*A8(OPLINK),L
ACCB_ABORT
	RETS


**************************************************************************
*								         *
* COG_BUSTER - PROCESS TO CREATE THE COG HEAD THAT WILL BUST THROUGH	 *
* 		THE NEW ORDER POSTER.					 *
*								         *
**************************************************************************
COG_BUSTER
	MOVE	@YSCROLL,A14,L
	JRZ	CB_A_GOGO		;BR = WALL HAS SETTLED INTO VIEW
	SLOOP	5,COG_BUSTER
CB_A_GOGO
	CREATE	PID_IND,WALL_EXPLODE
	SLEEP	7
	MOVI	COG_INIT,B0		;ALLOCATE OBJECT
	CALLA	CREATE_ENEMY
	JRZ	CP_EXIT			;NOTHING CLEAN, RIGHT.

	MOVI	-0F600H,A1
	CALLA	STORE_ZVAL		;Set the Universe Z

	MOVIM	SRUNVEL_MAX,*A8(OSRUNVEL),L	;SET SIDE VELOCITY

	MOVI	200,A1
	CALLA	SET_SCRN_POS		;AND PUT THE GUY THERE

	CALLA	SET_ONGRND		;And set him on the ground	

	MOVI	COG_FLASH_COLOR,A1
	CALLR	STORE_OCONST		;STORE THE PROPER VALUE FOR CONSTANT

	MOVI	COG_HIT_SOUND_GUNVECT,A1	
	MOVI	DUMCOLL,A2		
	CALLA	SET_VECTORS		;GUN AND COLLISION VECTORS

	MOVIM	M_BUSTER,*A8(OEFLAGS),W	;Flag me a bust through

	CALLA	INSERT_ENEMY		;INSERT AND COUNT ENEMY

	MOVIM	BUSTER_SHOOTER,*A8(OSHOOT_ANIM),L
	MOVIM	BUSTER_DEATH_ANIM,*A8(ODEATH_ANIM),L
	MOVIM	STANDING_BLOCK,*A8(OBLOCK_ANIM),L

	MOVI	COG_BUST_ANIM,A1
	CALLA	STRT_ANIM		;START HIS ANIMATION


	CALLA	GET_SHAD_MULTI		;Setup his shadow

COG_WATCH
	MOVE	A13,*A8(OPLINK),L
COG_WATCH_LOOP
	SLOOP	7000H,COG_WATCH_LOOP	;HERE WE WAIT FOR SHIT TO HAPPEN

**************************************************************************
*								         *
* 	COG_BOUNCER							 *
* 									 *
* 	Process to create a Cog Head that is just standing there.	 *
* 	Waiting to shoot.						 *
* 									 *
* 	A9 = Universe X							 *
* 	A10 = Universe Z						 *
*								         *
**************************************************************************
COG_BOUNCER
	MOVI	COG_INIT,B0		;ALLOCATE OBJECT
	CALLA	CREATE_ENEMY
	JRZ	CP_EXIT			;NOTHING CLEAN, RIGHT.

	MOVE	A10,A3
	MOVE	A9,A1
	CLR	A2
	CALLA	SET_ANIPU		;Position him

	CALLA	SET_ONGRND		;And set him on the ground	

	MOVI	COG_FLASH_COLOR,A1
	CALLR	STORE_OCONST		;STORE THE PROPER VALUE FOR CONSTANT

	MOVIM	M_BOUNCER,*A8(OEFLAGS),W ;Flag me a bouncer

	MOVIM	BUSTER_SHOOTER,*A8(OSHOOT_ANIM),L
	MOVIM	BUSTER_DEATH_ANIM,*A8(ODEATH_ANIM),L
	MOVIM	STANDING_BLOCK,*A8(OBLOCK_ANIM),L

	MOVI	COG_BOUNCER_ANIM,A1
	CALLA	STRT_ANIM		;START HIS ANIMATION

	CALLA	OBJ_ON_MULTI		;We create with the objects off

	MOVI	COG_HIT_SOUND_GUNVECT,A1	
	MOVI	DUMCOLL,A2		
	CALLA	SET_VECTORS		;GUN AND COLLISION VECTORS

	CALLA	INSERT_ENEMY		;INSERT AND COUNT ENEMY

	CALLA	GET_SHAD_MULTI		;Setup his shadow

	JRUC	COG_WATCH

**************************************************************************
*								         *
* 	PROC_COG_BABBLE							 *
* 									 *
* 	Process to make random Cog Head phrases, never repeating	 *
* 	until all have been said.					 *
* 									 *
* 	Dies automatically when SUBWAVE is incremented.			 *
*								         *
**************************************************************************
PROC_COG_BABBLE
	SLEEP	200

	MOVE	@SUBWAVE,A10,W		;This is how we now when to stop

PCB_BABBLE_RESET
	MOVK	1,A9			;This starts the babbling
	CLR	A0

	JRUC	PCB_DO_BABBLE		;Phrase 1 is always first

PCB_BABBLE_LOOP
	MOVK	8,A5

PCB_TRY_BABBLE_AGAIN
	MOVK	NUM_BABBLINGS,A0	;Do a little babbling
	CALLA	RAND0

	BTST	A0,A9			;Have we babbled this yet?
	JRZ	PCB_BABBLE_OK		;BR = No

	DSJS	A5,PCB_TRY_BABBLE_AGAIN
*
* Here we have failed to randomly babble, we'll just select
*
	MOVK	NUM_BABBLINGS,A5
	CLR	A0			;Walk down babble list until we get one
PCB_WALK_BABBLE
	BTST	A0,A9			;Is this a good one?
	JRZ	PCB_BABBLE_OK		;BR = Yes, then use it
	INC	A0			;Next
	DSJS	A5,PCB_WALK_BABBLE

	JRUC	PCB_BABBLE_RESET	;BR = We've done them all, wrap.

PCB_BABBLE_OK
	BSET	A0,A9			;Flag this as babbled

PCB_DO_BABBLE
	MOVE	A0,A8

	CLRM	@SPEAK_AT_PLAYER,W
PCB_WAIT_TO_SPEAK
	SLEEP	1

	MOVE	@SUBWAVE,A14,W
	CMP	A10,A14
	JANE	SUCIDE			;BR = We've changed sections

	MOVE	@SPEAK_AT_PLAYER,A14,W
	JRZ	PCB_WAIT_TO_SPEAK

	SLL	5,A8
	ADDI	BABBLE_TABLE,A8
	MOVE	*A8,A0,L		;Grab the proper phrase
	CALLA	ONESND			;And sound it

	SLOOP	400,PCB_BABBLE_LOOP

**************************************************************************
*								         *
* COG_CVECT								 *
*								         *
**************************************************************************
COG_CVECT
	WWL	OID_PROCKET,~MASK_PLAYER,COG_ROCKET_COLL
	WWL	OID_PEXPLOSION,MASK_SUPP|MASK_TYPE|MASK_ID,COG_EXPLOSION_COLL
	WWL	OID_BLOWUP,0FFFFH,COG_SBOMB_COLL
	WL	0,DUMCRETS

**************************************************************************
*								         *
* 	HIT_ENEMY							 *
* 									 *
* 	Add a hit to the enemy and check if it causes the given		 *
* 	threshold to be crossed.  It weights the hit based on the	 *
* 	responsible player.						 *
* 	The given hit counter must be of the following format:		 *
* 			      	0-7:P1 HITS, 8-15:P2 HITS		 *
* 				16-23:P3 HITS, 24-31:P4 HITS		 *
* 	A1 = Hit threshold						 *
* 	A2 = Ptr to player responsible for hit				 *
* 	A3 = Offset of hit counter in the object block			 *
* 	A8 = Ptr to enemy object					 *
*								         *
**************************************************************************
HIT_ENEMY
	MMTM	SP,A0,A4,A6,A7
	MOVE	A8,A7
	ADD	A3,A7			;Offset to the counter
	ADDK	(8*(MAXPLAYERS-1)),A7	;We go backwards so get to last player
	CALLA	GPLAYNUM		;Convert player data ptr to number
	CLR	A6			;Gross hit accumulator
	MOVK	MAXPLAYERS-1,A4		;Check all players
HE_LOOP
	MOVB	*A7,A14			;Get counter for this player
	CMP	A4,A0			;Is this the responsible player?
	JRNE	HE_NOT_PLAYER		;BR = No
	ADDK	1,A14			;Add a hit for this player
	MOVB	A14,*A7			;Store 
	JRUC	HE_ACCUM
HE_NOT_PLAYER
	SRA	2,A14			;If not player accumulate 25% of hits
HE_ACCUM
	ADD	A14,A6			;Add to gross hits
	SUBK	8,A7			;Back down a byte
	DEC	A4
	JRNN	HE_LOOP

	CMP	A1,A6			;Do the compare
	MMFM	SP,A0,A4,A6,A7
	RETS

**************************************************************************
*								         *
* COG_GUNVECT								 *
*								         *
* PASS:									 *
* A2 = PTR TO PLAYER						         *
* A8 = PTR TO OBJECT							 *
*								         *
**************************************************************************
COG_GUNVECT
	MOVB	*A8(OPARTID),A4			;Keep our Parts I.D.
	CALLA	GET_HEAD_PART

	MOVB	*A8(OFLAGS+B_DEAD-7),A9		;IS THIS OBJECT DEAD?
	JRN	CG_DEAD				;BR = YES

	MOVE	@WAVETIME,A5,W		;KEEP THIS HERE, WE'LL NEED IT
	MOVE	A5,*A8(OLAST_HIT_TIME),W	;ALWAYS STORE THIS

	MOVE	A2,*A8(OPLAYER),L		;STORE PLAYER INFO FOR LATER???

	MOVE	*A8(OEFLAGS),A6,W

	RANDENT	TAB_HIT_SNDS,NUM_HIT_SNDS,5,L
	CALLA	ONESND_Z			;Give us a ding

	CALLA	DGV_FRAG_SPARK

	BTST	B_INVINCIBLE,A6		;ARE WE CURRENTLY INVINCIBLE?
	JRNE	CG_DEAD			;BR = YES, JUST EXIT

	MOVE	*A2(PPLASMASHOTS),A14,W
	JRNZ	CG_BLASTED		;BR = Player has massive firepower

;	BTST	B_BLOCKING,A6		;ARE WE CURRENTLY BLOCKING?
;	JRNE	CG_BLOCKED		;BR = YES, JUST SOUND AND CRUISE

	CMPK	NUM_LEGS,A4		;Was this the legs?
	JREQ	CG_TAKE_HIT		;BR = Yo, then no need to block

	MOVE	*A8(OLAST_BLOCK_TIME),A3,W
	MOVE	A5,A14
	SUB	A3,A14			;CHECK THE ELAPSED TIME SINCE LAST BLOCK
	CMPI	45,A14			;HAS IT BEEN TOO LONG?
	JRLT	CG_TAKE_HIT		;BR = NO

	MOVE	*A8(OSHOOT_TIME),A3,W
	CMP	A5,A3			;HAVE WE BEEN SHOOTING ENOUGH HERE?
	JRLO	CG_TAKE_HIT		;BR = NO

	MOVE	*A8(OBLOCK_ANIM),A1,L	;GET THE PROPER BLOCK ANIMATION
	JRZ	CG_TAKE_HIT		;BR = HE CAN'T BLOCK RIGHT NOW

	ORI	M_BLOCKING,A6
	MOVE	A6,*A8(OEFLAGS),W	;MAKE US KNOWN

	JAUC	SetAnim			;AND FIRE IT OFF
*
* A4 = OPARTID of part shot
* A6 = OEFLAGS
* A9 = OFLAG+B_DEAD-7
*
CG_TAKE_HIT
	CMPK	NUM_TORSO,A4		;Was this the torso object?
	JRNE	CG_DEAD			;BR = No, then no hit

	SOUNDZ	SND_CHEST_HIT

	CLR	A5
	MOVK	COG_HITS_TO_KILL,A1	;This many hits to kill

	BTST	B_BRIDGE,A6
	JRZ	CG_NOT_EASY
	MOVK	2,A1			;Easier for bridge guy
CG_NOT_EASY
	BTST	B_BOUNCER,A6		
	JRNZ	CG_DUHBLE_HITS		;BR = Bouncer takes twice as many
	BTST	B_BUSTER,A6
	JRZ	CG_NORM_HITS		;BR = This is a normal guy
CG_DUHBLE_HITS
	ADDK	COG_HITS_TO_KILL,A1	;Double hits required for buster
CG_NORM_HITS
	MOVI	OHITS,A3		;This is the variable to use
	CALLA	HIT_ENEMY		;IS THIS GUY TOAST?
	JRHS	COG_DO_DEATH		;BR = OH YEAH!
*
* Cog is still alive here
*
	MOVI	COG_UNFLASH,A7
	CALLA	OBJPROC_INT		;INTERRUPT COG WATCHER
	JRZ	CG_BLOCKED		;BR = NO COG WATCHER EXISTS

	MOVI	DMACNZ&(~DMAGO),A1
	CALLR	OBJ_DRAWBITS_MULTI	;FLASH HIM WHITE

	ORI	M_INVINCIBLE,A6
	MOVE	A6,*A8(OEFLAGS),W	;MAKE HIM NON-HITTABLE NOW

	JRUC	CG_DEAD

CG_BLOCKED
	CMPK	NUM_TORSO,A4		;Was this the torso object?
	JRNE	CG_DEAD			;BR = No, then no sound
	SOUNDZ	SND_SHIELD_HIT
CG_DEAD
	RETS

*
* Just kill the thing
* A4 = OPARTID of part shot
* A6 = OEFLAGS
* A9 = OFLAG+B_DEAD-7
*
CG_BLASTED
	CLR	A5
	JRUC	COG_DO_DEATH

**************************************************************************
*								         *
* 	COG_HIT_SOUND_GUNVECT						 *
* 									 *
* 	Gunvector to just make a hit sound and spark.			 *
* 									 *
* 	A2 = Ptr to player hitting					 *
* 	A8 = Ptr to Cog part						 *
*								         *
**************************************************************************
COG_HIT_SOUND_GUNVECT
	RANDENT	TAB_HIT_SNDS,NUM_HIT_SNDS,5,L
	CALLA	ONESND_Z			;Give us a ding

	CALLA	DGV_FRAG_SPARK

	RETS

**************************************************************************
*								         *
* COG_UNFLASH - PROCESS SUBROUTINE TURN OFF THE COG HEAD FLASH AND	 *
* 		INVINCIBILTY BITS.					 *
* A8 = PTR TO HEAD OBJECT						 *
* NOTE: CALL WITH JSRP							 *
*								         *
**************************************************************************
COG_UNFLASH
	SLEEP	2
	MOVI	DMAWNZ&(~DMAGO),A1
	CALLR	OBJ_DRAWBITS_MULTI
	SLEEP	2
	MOVE	*A8(OEFLAGS),A14,W
	ANDNI	M_INVINCIBLE,A14
	MOVE	A14,*A8(OEFLAGS),W
	RETP
	
**************************************************************************
*								         *
* OBJ_DRAWBITS_MULTI - GIVE ALL OF AN OBJECTS PARTS NEW DRAW BITS.	 *
* A1 = NEW DRAW BITS (LOW FOUR OF OCTRL ONLY)				 *
* A8 = PTR TO FIRST PART TO TURN "ON"					 *
*								         *
**************************************************************************
OBJ_DRAWBITS_MULTI
	PUSH	A8
ODM_LP
	MOVE	*A8(OFLAGS),A14,W	
	BTST	B_SHAD,A14		;Is this object a shadow?
	JRNZ	ODM_NXT			;BR = Yes, then no flashing for it

	MOVB	*A8(OCTRL),A14
	SRL	4,A14
	SLL	4,A14
	OR	A1,A14
	MOVB	A14,*A8(OCTRL)
ODM_NXT
	MOVE	*A8(OPARTS),A8,L
	JRNZ	ODM_LP
	PULLQ	A8
	RETS

**************************************************************************
*								         *
* STORE_OCONST - Store the given value in the OCONST field of all	 *
* 		the objects of a multi-parter.  It starts with		 *
* 		the given and works its way to the end.			 *
* A1 = Value to store							 *
* A8 = ptr to first part to store					 *
*								         *
**************************************************************************
STORE_OCONST
	MOVE	A8,A14
SO_LP
	MOVE	A1,*A14(OCONST),W
	MOVE	*A14(OPARTS),A14,L
	JRNZ	SO_LP
	RETS

**************************************************************************
*								         *
* COG_SBOMB_COLL - COGHEAD GETS WHACKED BY A SMART BOMB			 *
* A2 = PTR TO PLAYER SMART BOMBING					 *
* A8 = PTR TO COGHEAD							 *
*								         *
**************************************************************************
COG_SBOMB_COLL
	CLR	A5
	CALLA	GET_HEAD_PART
	JRUC	COG_GEN_COLL

**************************************************************************
*								         *
* COG_ROCKET_COLL - COLLISION WITH COGHEAD AND A ROCKET			 *
* A0 = PTR TO ROCKET							 *
* A8 = PTR TO COGHEAD							 *
*								         *
**************************************************************************
COG_ROCKET_COLL
	MOVE	*A0(RL_INTENDED_OBJ),A14,L
	CMP	A14,A8			;Is this the object we are after?
	JRNE	CRC_X			;BR = No

	CALLA	GET_HEAD_PART
	MOVKB	1,*A8(OCHEWED_ROCKET)	;Flag the rocket hit
CRC_X
	RETS

**************************************************************************
*								         *
* COG_EXPLOSION_COLL - COLLISION WITH COGHEAD AND AN EXPLOSION		 *
* A0 = PTR TO EXPLOSION							 *
* A8 = PTR TO COGHEAD							 *
*								         *
**************************************************************************
COG_EXPLOSION_COLL
	CALLA	GETHEADPART			;GET THE KILLERS HEAD
	MOVE	A0,A5				;KEEP KILLER HERE
	MOVE	*A0(OID),A0,W			;GET PLAYER DATA ADDRESS
	CALLA	POID_TO_PDATA

	CALLA	GET_HEAD_PART
	MOVB	*A8(OCHEWED_ROCKET),A14		;Did he actually get hit?
	JRZ	CEC_DEAD			;BR= No

*
* A8 = Ptr to head part of object
*
COG_GEN_COLL
	MOVE	A2,*A8(OPLAYER),L		;Keep here for scoring

	MOVB	*A8(OFLAGS+B_DEAD-7),A9		;IS THIS OBJECT DEAD?
	JRN	CEC_DEAD			;BR = YES

	MOVE	*A8(OEFLAGS),A6,W
	
*
* This is a generic Cog death entrypoint
* Note: NOTHING SHOULD BE PUSHED!
* A5 = Ptr to accompanying explosion, 0 means there isn't one
* A6 = EFLAGS
* A8 = Ptr to head part of cog
* A9 = OFLAGS+B_DEAD-7
* *A8(OPLAYER),L = Ptr to player that killed us.
*
COG_DO_DEATH
	ADDI	M_DEAD >> 3,A9
	MOVB	A9,*A8(OFLAGS+B_DEAD-7)

	CLRM	*A8(OJUMPTAB),L		;We won't be jumping any longer

	MOVI	DMAWNZ&(~DMAGO),A1
	CALLR	OBJ_DRAWBITS_MULTI
	
	MOVE	*A8(OPLAYER),A2,L
	MOVI	1000,A1
	CALLA	SCORE
	CALLA	COUNT_PLAYER_KILL

	MOVE	*A8(ODEATH_ANIM),A1,L
	.IF DEBUG
	LOCKON	Z
	.ENDIF

	BTST	B_BOUNCER,A6
	JRNZ	CEC_SHORT_DEATH		;BR = Bouncer guys get shorted

	MOVE	A5,A5
	jrnz	CEC_Explosion
*
* This is the bullet death thing
*
CEC_SHORT_DEATH
	SOUNDZ	SND_DEATH_SHORT
	MOVIM	-20000H,*A8(OYVEL),L	;SEND HIM UP
	MOVIM	4000H,*A8(OYACCEL),W	;AND MAKE HIM COME DOWN
	MOVI	SHORT_DEATH_ZVEL,A14
	MOVE	A14,*A8(OZVEL),L	;AND MAKE HIM GET BLOWN BACK
	jruc	CEC_Death_Anim
CEC_Explosion
	MOVB	*A8(OSPINNING),A14
	JRZ	CEC_NORMAL_FLY
	MOVI	SPIN_DEATH_ANIM,A1
	JRUC	CEC_Death_Anim

CEC_NORMAL_FLY
	SOUNDZ	SND_DEATH_SHORT
	SOUNDZ	SND_ROCKET_HIT
	MOVIM	-40000H,*A8(OYVEL),L	;SEND HIM UP
	MOVIM	4000H,*A8(OYACCEL),W	;AND MAKE HIM COME DOWN
	MOVI	LONG_DEATH_ZVEL,A14

	move	@WAVE,a3
	cmpk	6+DEBUG,a3
	jrlt	CEC_smallzvel
	MOVI	SHORT_DEATH_ZVEL,A14
CEC_smallzvel:

	MOVE	A14,*A8(OZVEL),L	;AND MAKE HIM GET BLOWN BACK
	MOVE	A14,*A5(OZVEL),L	;AND HIS LITTLE DOG TOO
CEC_Death_Anim
	MOVE	A1,*A8(AnimFrm),L
	CLR	A14
	MOVB	A14,*A8(AnimSlp)
CEC_DEAD
	RETS

**************************************************************************
*								         *
* 		ANIM FUNCS ABOUND IN THIS CRAZY WORLD			 *
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

	MOVE	*A8(OCTRL),A14,W
	BTST	B_FLIPH,A14		;Are we flipped
	JRZ	AVW_NOFLIP

*
* This is the flipped case
*

	MOVE	*A8(OJUMPTAB),A4,L	;Get the jump table
	JRZ	AVW_F_NOJUMPS

	MOVE	*A8(OEFLAGS),A14,W
	BTST	B_BRIDGE,A14
	JRZ	AVW_F_NO_BRIDGE

	MOVB	*A8(OJUMPING),A14
	JRNZ	AVW_F_NOJUMPS

	MOVE	*A8(OXPOS),A2,W
	MOVE	*A4,A14,W		;Get left boundry
AVW_F_BRIDGE_CK
	ADDK	2,A14
	CMP	A14,A2	
	JRLE	AVW_F_NEXT_BRIDGE	;BR = Past this block
	MOVE	*A4(JT_RIGHT),A3,W	;Get right boundry
	CMP	A3,A2
	JRGT	AVW_F_NEXT_BRIDGE	;BR = Hasn't hit the block yet

	MOVE	*A4(JT_TEST),A14,L
	CALL	A14			;Test the block
	JRZ	AVW_F_NEXT_BRIDGE	;BR = Block is still there

	SUB	A2,A3
	ABS	A3
	CMPK	8,A3
	JRLS	AVW_F_DO_BRIDGE_JUMP	;BR = It's time to jump the bridge
	JRUC	AVW_DO_DEATH

AVW_F_NEXT_BRIDGE
	ADDI	JT_SIZE,A4
	MOVE	*A4,A14,W
	JRNZ	AVW_F_BRIDGE_CK
	JRUC	AVW_F_NOJUMPS

AVW_F_NO_BRIDGE
	MOVE	*A4,A2,W		;Grab the target
	MOVE	*A8(OXPOS),A14,W
	CMP	A2,A14
	JRLE	AVW_DO_JUMP

AVW_F_NOJUMPS
	NEG	A7			;Handle acceleration backwards during flip
	JRZ	AVW_CHECK_Z		;BR = No accel to worry	about
	JRNN	AVW_ADD_N_STUFF_X	;BR = Decelerating, no glide check

	ADD	A7,A5			;Add the acceleration

	MOVE	*A8(OSRUNVEL),A2,L
	NEG	A2
	MOVE	@XSCROLL,A3,L		;Get our current scroll
	JRN	AVW_F_CATCHUP		;BR = We're skating with the scroll
	CLR	A3			;Against, then no worry
AVW_F_CATCHUP
	ADD	A3,A2			;Adjust target velocity

	CMP	A2,A5			;Did we max out?
	JRGE	AVW_STUFF_X		;BR = No
	JRUC	AVW_CK_GLIDE_X

*
* This is the unflipped case
*
AVW_NOFLIP
	MOVE	*A8(OJUMPTAB),A4,L	;Get the jump table
	JRZ	AVW_NOJUMPS

	MOVE	*A8(OEFLAGS),A14,W
	BTST	B_BRIDGE,A14
	JRZ	AVW_NO_BRIDGE		;BR = Not checking jump on a bridge

	MOVB	*A8(OJUMPING),A14
	JRNZ	AVW_NOJUMPS

	MOVE	*A8(OXPOS),A2,W
	MOVE	*A4(JT_RIGHT),A14,W	;Get right boundry
AVW_BRIDGE_CK
	SUBK	2,A14
	CMP	A14,A2	
	JRGE	AVW_NEXT_BRIDGE		;BR = Past this block
	MOVE	*A4,A3,W		;Get left boundry
	CMP	A3,A2
	JRLT	AVW_NOJUMPS		;BR = Hasn't hit the block yet

	MOVE	*A4(JT_TEST),A14,L
	CALL	A14			;Test the block
	JRZ	AVW_NEXT_BRIDGE		;BR = Block is still there

	SUB	A2,A3
	ABS	A3
	CMPK	8,A3
	JRLS	AVW_DO_BRIDGE_JUMP	;BR = It's time to jump the bridge
	JRUC	AVW_DO_DEATH

AVW_NEXT_BRIDGE
	ADDI	JT_SIZE,A4
	MOVE	*A4(JT_RIGHT),A14,W
	JRNZ	AVW_BRIDGE_CK
	JRUC	AVW_NOJUMPS

AVW_NO_BRIDGE
	MOVE	*A4,A2,W		;Grab the target
	MOVE	*A8(OXPOS),A14,W
	CMP	A2,A14
	JRGE	AVW_DO_JUMP

AVW_NOJUMPS
	MOVE	A7,A7
	JRZ	AVW_CHECK_Z		;BR = No acceleration, no worry
	JRN	AVW_ADD_N_STUFF_X	;BR = Decelerating, no glide check

	ADD	A7,A5			;Add the acceleration

	MOVE	*A8(OSRUNVEL),A2,L
	MOVE	@XSCROLL,A3,L		;Get our current scroll
	JRNN	AVW_NF_CATCHUP		;BR = We're skating with the scroll
	CLR	A3			;Against, then no worry
AVW_NF_CATCHUP
	ADD	A3,A2			;Adjust target velocity

	CMP	A2,A5			;Did we max out?
	JRLE	AVW_STUFF_X		;BR = No
AVW_CK_GLIDE_X
	MOVB	*A8(OFLAGS),A14
	JRN	AVW_CHECK_Z		;BR = We are not onscreen, no glide

	MOVB	*A8(OSTART_GLIDE),A14
	JRZ	AVW_CHECK_Z		;BR = No gliding for this guy

	MOVK	1,A0
	MOVE	@RAND,A14,W
	JRNN	AVW_GLIDE_CK

	INC	A0

AVW_GLIDE_CK
	MOVB	*A8(OSKATELOOPS),A14
	CMP	A0,A14
	JRLO	AVW_CHECK_Z
	
;	DEC	A14
;	MOVB	A14,*A8(OSTART_GLIDE)
;	JRNZ	AVW_CHECK_Z		;BR = Do not glide right now

	CLRB	*A8(OSTART_GLIDE)	;Don't let us glide again

	MOVKB	1,*A8(OGLIDING)
	JRUC	AVW_CHECK_Z

AVW_ADD_N_STUFF_X
	ADD	A7,A5
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
* Time to jump a bridge piece
* A4 = Ptr to jump table entry
* A8 = Ptr to head object
*
AVW_F_DO_BRIDGE_JUMP			;Flipped case
	MOVE	*A8(OJUMPTAB),A2,L

AVW_F_DBJ_LOOP
	MOVE	*A4,A1,W		;Get left target
	CMP	A4,A2
	JREQ	AVW_DO_BRIDGE_JUMP_G	;This is the last block we're jumping
	SUBI	JT_SIZE,A4		;Get next block going left
	MOVE	*A4(JT_TEST),A14,L
	CALL	A14
	JRNZ	AVW_F_DBJ_LOOP		;BR = Target piece is not there
	JRUC	AVW_DO_BRIDGE_JUMP_G

AVW_DO_BRIDGE_JUMP			;Unflipped case
	MOVE	*A4(JT_RIGHT),A1,W	;Get right target

	ADDI	JT_SIZE,A4		;Get the next block in line
	MOVE	*A4,A14,W	
	JRZ	AVW_DO_BRIDGE_JUMP_G	;BR = There is no next block
	MOVE	*A4(JT_TEST),A14,L
	CALL	A14
	JRNZ	AVW_DO_BRIDGE_JUMP	;BR = Target piece is not there
	
AVW_DO_BRIDGE_JUMP_G
	MOVI	P_GXCOGY,A0
	CALLA	CHANGE_PAL_MULTI	;Make sure all is cool
	
	MOVKB	1,*A8(OJUMPING)		;Mark us as jumping

	MOVE	*A8(OXPOS),A3,W
	SUB	A3,A1

	MOVK	30,A3
	SLL	16,A1
	DIVS	A3,A1

	MOVE	A1,*A8(OXVEL),L
	MOVE	A1,A2
	ABS	A2
	
	MOVE	A3,A1

	JRUC	AVW_DO_JUMP_G
	
*
* Time to take a jump or stop
* A4 = Ptr to current jump table entry
* A8 = Ptr to head object
*
AVW_DO_JUMP
	ADDK	16,A4

	MOVI	P_GXCOGY,A0
	CALLA	CHANGE_PAL_MULTI	;Make sure all is cool

	MOVE	*A4+,A1,W
	JRZ	AVW_DO_STOP		;BR = He needs to stop now

	MOVE	A4,*A8(OJUMPTAB),L	;Store for the next jump

	MOVE	*A8(OXVAL),A2,L
	SLL	16,A1
	SUB	A2,A1			;Get the distance
	ABS	A1

	MOVE	*A8(OXVEL),A2,L
	ABS	A2

	DIVU	A2,A1			;This gives us the time it takes
*
* Entrypoint:
*	A1 = Duration of jump, in ticks
*	A2 = Absolute XVEL of object
*
AVW_DO_JUMP_G
	SRA	1,A1			;Break it off

	MOVI	JUMP_MIN_YVEL,A3	;This is the velocity that we jump with
	SRL	17,A2
	JRZ	AVW_GOT_YVEL
AVW_ADJUST_YVEL
	SLL	1,A3
	SRL	1,A2
	JRNZ	AVW_ADJUST_YVEL
	
AVW_GOT_YVEL

	MOVE	A3,A4			;Copy for stuff

	DIVU	A1,A3			;Get accel needed to land in the ticks

	NEG	A4			;Negate to go up

	MOVE	A4,*A8(OYVEL),L	 	;Go up
	MOVE	A3,*A8(OYACCEL),W	;And come down

	CLR	A4
	MOVE	A4,*A8(OXACCEL),W	;No frictionating
	MOVE	A4,*A8(OBLOCK_ANIM),L	;No blockinating

	SLL	1,A1
	CMPI	7FH,A1
	JRLS	AVW_SLEEP_READY
	MOVE	A1,A4
	MOVI	7FH,A1
	SUB	A1,A4
AVW_SLEEP_READY
	MOVE	A4,*A8(OJUMP_SLEEP),W	;Store this as the remainder
	MOVB	A1,*A8(AnimSLP)		;Sleep before landing

	MOVI	SIDE_JUMP_ANIM,A1
	JAUC	STRT_ANIM		;Immediate please

AVW_DO_STOP
	MOVIM	SKATE_XBRAKE,*A8(OXACCEL),W
	CLRM	*A8(OJUMPTAB),L		;No mo jumping, obviously

	MOVI	SIDE_STOP_STAND,A1
	JAUC	STRT_ANIM		;Immediate please

*
* Time to make Coghead die
* A8 = Ptr to head part
*
AVW_DO_DEATH
	MOVI	P_GXCOGY,A0
	CALLA	CHANGE_PAL_MULTI	;Make sure all is cool

	ORIM	M_DEAD,*A8(OFLAGS),W

	MOVI	DMAWNZ&(~DMAGO),A1
	CALLR	OBJ_DRAWBITS_MULTI
	
	MOVE	*A8(ODEATH_ANIM),A1,L
	.IF DEBUG
	LOCKON	Z
	.ENDIF

	SOUNDZ	SND_DEATH_LONG
	MOVIM	4000H,*A8(OYACCEL),W	;AND MAKE HIM COME DOWN

	MOVE	A1,*A8(AnimFrm),L
	CLR	A14
	MOVB	A14,*A8(AnimSlp)
	MOVE	A14,*A8(OXACCEL),W	;No frictionating
	MOVE	A14,*A8(OJUMPTAB),L	;No jumping while dead

	RETS

**************************************************************************
*								         *
* 	A_SIDE_SCREEN_CK						 *
* 									 *
* 	Anim func to check if side skating guy is off the opposite	 *
* 	side of the screen.						 *
* 									 *
* 	A8 = Ptr to any part						 *
* 	AARG+,L = Branch if your off the opposite			 *
*								         *
**************************************************************************
A_SIDE_SCREEN_CK
	CALLA	GET_HEAD_PART

	MOVE	*A8(OXLIMIT),A2,W	;Get distance allowed
	JRZ	ASSC_FULL		;BR = Full screen
	MOVE	*A8(OXPOS),A0,W
	MOVE	*A8(OXORIG),A1,W
	SUB	A0,A1
	ABS	A1   			;Distance traveled in a1
	CMP	A2,A1
	JAGT	DEL_ENEMY_NOAUD		;BR = Delete enemy, cause he's gone

ASSC_FULL
	MOVE	*A8(OZVAL),A2,L
	move	@ZBASE,a14,L
	sub	a14,a2
	CMPI	ZMAX_REAL,A2
	JALT	DEL_ENEMY_NOAUD		;BR = Enemy too far forward

	INCB	*A8(OSKATELOOPS)	;Show another cycle

	MOVE	@XSCROLL,A14,L
	JANZ	A_OFFOPP_DEL

	MOVB	*A8(ONO_STOP),A14
	JANZ	A_OFFOPP_DEL

	JAUC	A_OFFOPP

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

	MOVE	*A8(OZVAL),A2,L
	move	@ZBASE,a14,L
	sub	a14,a2
	CMPI	ZMAX_REAL,A2
	JALT	DEL_ENEMY_NOAUD		;BR = Enemy too far forward

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
	MOVE	@WAVETIME,A14,W
	MOVE	A14,*A8(OSHOOT_TIME),W
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

	MOVE	*A9(OSHOOT_TIME),A3,W
	ADDI	28,A3
	MOVE	A3,*A9(OSHOOT_TIME),W

	MOVB	*A8(OFLAGS+B_DEAD-7),A14
	JRN	AFF_X				;BR = Object is dead

	CALLA	GETAFARG_LONG			;Get the firing offset
	MOVE	A0,A3

;	CALLA	GETAFARG_LONG			;And the hit points
;	MOVE	A0,A5

	MOVE	@BASE_HIT,A5,W
	ADDI	800H,A5
	SLL	4,A5

	CALLA	EGUN_FLASH_MULTI		;Make a flash

	CALLA	CK_PLAYER_HIT
	JRNZ	AFF_HIT			;BR = Successful hit on Player(s)
	JRNC	AFF_NOHIT		;BR = No hit, but he was visible
 	jruc	AFF_NOHIT_No_Sound	;He did'nt hit because he was not visible
AFF_HIT
	CLRB	*A9(OMISSES)			;We did not miss
	SOUNDZ	SND_COG_FIRE
	JRUC	AFF_X
AFF_NOHIT
	SOUNDZ	SND_COG_FIRE
AFF_NOHIT_No_Sound
	MOVB	*A9(OMISSES),A14
	INC	A14  				;Knock the miss count
	MOVB	A14,*A9(OMISSES)
AFF_X
	RETS

**************************************************************************
*								         *
* A_BUSTER_FIRE_FNC - ANIM FUNC, FOR BUST THROUGH GUN PART FIRE.	 *
* A8 = PTR TO ARM PART DOING THE FIRING.				 *
* AARG+,L = [Y,X] FIRING OFFSET.					 *
*								         *
**************************************************************************
A_BUSTER_FIRE_FNC
	CALLA	GET_HEAD_PART_A0

	MOVE	*A0(OSHOOT_TIME),A3,W
	ADDI	28,A3
	MOVE	A3,*A0(OSHOOT_TIME),W

	MOVB	*A8(OFLAGS+B_DEAD-7),A14	;IS THIS OBJECT DEAD?
	JRN	BFF_X				;BR = YES

	CALLA	GETAFARG_LONG		;GET THE FIRING OFFSET
	MOVE	A0,A3
	CALLA	EGUN_FLASH_MULTI	;MAKE A GUN FLASH

;	SOUND1	SND_COG_FIRE

	MOVE	@BASE_HIT,A5,W
	ADDI	800H,A5
	SLL	4,A5
;	MOVI	[2,0],A5

	ALLPLYR	PLAYER_HIT		;HIT 'EM ALL
BFF_X
	RETS

**************************************************************************
*								         *
* A_SHIFT_XVEL - Anim Function to shift the OXVEL of an object		 *
* 		by the given amount.					 *
* A8 = PTR TO OBJECT							 *
* AARG+,W = SHIFT COUNT							 *
*								         *
**************************************************************************
A_SHIFT_XVEL
	MOVE	*A8(OXVEL),A3,L
	CALLA	GETAFARG_WORD
	SRA	A0,A3
	MOVE	A3,*A8(OXVEL),L
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
	MOVIM	STANDING_BLOCK,*A8(OBLOCK_ANIM),L
	MOVIM	HEADON_DEATH_ANIM,*A8(ODEATH_ANIM),L
	MOVIM	HEADON_SHOOT_ANIM,*A8(OSHOOT_ANIM),L
	CALLR	A_CLR_ALL_X
	JRUC	A_CLR_ALL_Z

**************************************************************************
*								         *
* 	A_ABOVE_CK							 *
* 									 *
* 	Anim func to check if the object is above a certain Y		 *
* 	and coming down.  If it is the branch.				 *
* 									 *
* 	A8 = Ptr to object						 *
* 	AARG+,W = Integer Y to be above					 *
* 	AARG+,L = Branch						 *
*								         *
**************************************************************************
A_ABOVE_CK
	CALLA	GETAFARG_WORD
	MOVE	*A8(OYVEL),A14,L	;Are we coming down?
	JAN	SetAnim_AFARG		;Br = No, then branch
	CALLA	DIST_FROM_GROUND	;Get our distance
	SRA	16,A1			;Make it integer
	CMP	A0,A1			;Are we still above?
	JAGT	SetAnim_AFARG		;BR = Yes
	RETS

**************************************************************************
*								         *
* 	A_GROUND_CK							 *
* 									 *
* 	Anim func to check if an object is above ground.		 *
* 	If it is, then branch.						 *
* 									 *
* 	A8 = Ptr to object						 *
* 	AARG+,W = Integer Ground offset	   				 *
* 	AARG+,L = Branch						 *
*								         *
**************************************************************************
A_GROUND_CK
	CALLA	GET_HEAD_PART_A0
	MOVE	*A0(OYENEMY),A1,W
	JRZ	AGC_TERRA_FIRMA		;BR = We're not floating in air

	MOVB	*A0(OFLAGS),A14
	JRNN	AGC_TERRA_FIRMA		;BR = We're still on screen

	MOVE	A0,A8
	MOVE	*A8(OFLAGS),A14,W
	BTST	B_DEAD,A14
	JANZ	DELETE_ENEMY
	JAUC	DEL_ENEMY_NOAUD		;He's outta here

AGC_TERRA_FIRMA
	CALLA	GETAFARG_WORD
	SLL	16,A0
	CALLA	DIST_FROM_GROUND
	CMP	A0,A1
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
	JAUC	SET_ONGRND

**************************************************************************
*								         *
* A_SET_BLOCK_AND_BUST_VECT - Anim Func to set the BLOCK bit and the	 *
* 				collision vectors for the cog head.	 *
* A8 = Ptr to head object						 *
*								         *
**************************************************************************
A_SET_BLOCK_AND_BUST_VECT
	MOVE	*A8(OEFLAGS),A14,W
	ORI	M_BLOCKING,A14		;We block now!
	MOVE	A14,*A8(OEFLAGS),W
	JRUC	A_SET_BUST_VECT

**************************************************************************
*								         *
* A_SET_BUST_VECT - Animation Function to set the Collision and Gun	 *
* 			Vectors for the Bust through guy.		 *
* A8 = Ptr to object							 *
*								         *
**************************************************************************
A_SET_BUST_VECT
	MOVI	COG_GUNVECT,A1	
	MOVI	COG_CVECT,A2		
	JAUC	SET_VECTORS

**************************************************************************
*								         *
* A_JUMP_TO_SHOOT - Anim Func to jump to the animation stored in	 *
* 			OSHOOT_ANIM					 *
* A8 = Ptr to HEAD part							 *
*								         *
**************************************************************************
A_JUMP_TO_SHOOT
	MOVE	*A8(OSHOOT_ANIM),A1,L
	.IF DEBUG
	LOCKON	Z
	.ENDIF
	JAUC	SetAnim

**************************************************************************
*								         *
* A_CHECK_UNBLOCK - ANIM FUNC TO DETERMINE IF WE SHOULD UNBLOCK.	 *
* 		IT USES FACTORS SUCH AS, TIME SINCE LAST FIRING,	 *
* 		AND CURRENT HITS TAKEN.					 *
* A8 = PTR TO OBJECT							 *
* AARG+,L = ANIMATION JUMP IF WE ARE TO STILL BLOCK			 *
*								         *
**************************************************************************
A_CHECK_UNBLOCK		
	CALLA	GET_HEAD_PART_A0
	MOVE	@WAVETIME,A5,W
	MOVE	*A0(OSHOOT_TIME),A3,W
	CMP	A5,A3
	JRLO	ACU_MUST_TO_SHOOT_NOW
*LOOK FOR NEGATIVE INCOMING FIRE
	MOVE	*A0(OLAST_HIT_TIME),A3,W
	MOVE	A5,A14
	SUB	A3,A14			;CHECK THE ELAPSED TIME SINCE LAST HIT
	CMPK	20,A14			;HAS IT BEEN TOO LONG?
	JRGE	ACU_MUST_TO_SHOOT_NOW	;BR = YES
*CHECK FOR MAXIMUM BLOCK TIME
	MOVE	*A0(OLAST_BLOCK_TIME),A3,W
	MOVE	A5,A14
	SUB	A3,A14			;CHECK THE ELAPSED TIME SINCE LAST BLOCK
	CMPI	100,A14			;HAS IT BEEN TOO LONG?
	JRGE	ACU_MUST_TO_SHOOT_NOW	;BR = YES
*HOLD BLOCK FOR ANOTHER KUPLATIKS
	CALLA	GETAFARG_LONG
	MOVE	A0,A1
	JAUC	SetAnim
ACU_MUST_TO_SHOOT_NOW
	RETS

**************************************************************************
*								         *
* A_SET_BLOCKTIME - ANIM FUNC TO SET OLAST_BLOCK_TIME TO CURRENT WAVETIME.	 *
* A8 = PTR TO HEAD COG OBJECT						 *
*								         *
**************************************************************************
A_SET_BLOCKTIME
	CALLA	GET_HEAD_PART
	MOVE	@WAVETIME,A14,W
	MOVE	A14,*A8(OLAST_BLOCK_TIME),W
	RETS

**************************************************************************
*								         *
* A_CLR_BLOCK - ANIM FUNC TO CLEAR THE BLOCKING FLAG.			 *
* A8 = PTR TO HEAD COG OBJECT						 *
*								         *
**************************************************************************
A_CLR_BLOCK
	MOVE	*A8(OEFLAGS),A6,W
	ANDNI	M_BLOCKING,A6
	MOVE	A6,*A8(OEFLAGS),W
	RETS

**************************************************************************
*								         *
* 	A_START_BUST_VELS						 *
* 									 *
* 	Anim func to give the bust through velocities			 *
*								         *
**************************************************************************
A_START_BUST_VELS
	MOVIM	-40000H,*A8(OYVEL),L	;SEND HIM UP
	MOVIM	4000H,*A8(OYACCEL),W	;AND MAKE HIM COME DOWN
	MOVIM	-0C0H,*A8(OZVEL),L	;AND MAKE HIM GO FORWARD
	JAUC	OBJ_ON_MULTI

**************************************************************************
*								         *
* 	A_GLIDE_CK							 *
* 									 *
* 	Anim func to check if we should be gliding, if so then		 *
* 	branch animation.						 *
* 									 *
* 	A8 = Ptr to any part						 *
* 	AARG+,L = Branch to glide animation				 *
*								         *
**************************************************************************
A_GLIDE_CK
	CALLA	GET_HEAD_PART_A0
	MOVB	*A0(OGLIDING),A14	;Should we be gliding?
	JRZ	AGLC_X
	MOVE	A0,A2
	CALLA	GETAFARG_LONG
	MOVE	A0,A1
	MOVE	A2,A8
	JAUC	SetAnim
AGLC_X
	RETS

**************************************************************************
*								         *
* 	A_SIDE_GLIDE_END						 *
* 									 *
* 	Anim func to check what we should do at the end of the		 *
* 	side glide.							 *
* 									 *
* 	A8 = Ptr to any part						 *
*								         *
**************************************************************************
A_SIDE_GLIDE_END
	CALLA	GET_HEAD_PART

	MOVE	@XSCROLL,A14,L		;Are we scrolling?
	JRNZ	ASGE_SKATE_ON		;BR = Yes, then continue on

	MOVB	*A8(ONO_STOP),A14
	JRNZ	ASGE_SKATE_ON

	MOVB	*A8(OFLAGS),A14
	JRNN	ASGE_ON_SCREEN		;BR = Still onscreen

	MOVI	SIDE_OFF_OPP,A1		;Circle back from offscreen
	JAUC	SetAnim

ASGE_ON_SCREEN
	MOVI	SIDE_SPIN_REVERSE,A1	;Circle back for the kill
	JAUC	SetAnim

ASGE_SKATE_ON
	MOVI	SIDE_SKATE_ANIM,A1
	JAUC	SetAnim

**************************************************************************
*								         *
* 	A_HEADON_GLIDE_END						 *
* 									 *
* 	Anim func to check what we should do at the end of the		 *
* 	headon glide.							 *
* 									 *
* 	A8 = Ptr to any part						 *
*								         *
**************************************************************************
A_HEADON_GLIDE_END
	CALLA	GET_HEAD_PART

	MOVB	*A8(OFLAGS),A14
	JRNN	AHGE_ON_SCREEN		;BR = Still onscreen

	JAUC	DEL_ENEMY_NOAUD

AHGE_ON_SCREEN
	MOVI	HEADON_SKATE_ANIM,A1
	JAUC	SetAnim

**************************************************************************
*								         *
* 	A_SIDE_GLIDE_DECIDE						 *
* 									 *
* 	Anim func to make a decision on what to do while		 *
* 	gliding.							 *
* 									 *
* 	A8 = Ptr to any part						 *
*								         *
**************************************************************************
A_SIDE_GLIDE_DECIDE
	MOVE	@XSCROLL,A14,L
	JRNZ	ASGD_X			;BR = There is scroll, fuck it

	MOVE	*A8(OXVAL),A3,L
	MOVE	@XBASE,A5,L
	SUB	A5,A3			;Universe to World X

	ABS	A3
	SRL	16,A3
	CMPI	15,A3
	JRGT	ASGD_X

	CALLA	GET_HEAD_PART

	MOVB	*A8(ONO_STOP),A14
	JRNZ	ASGD_X			;BR = A no stop dude

	MOVE	*A8(OSTOP_ANIM),A1,L	;Got to stop and shoot
	.IF DEBUG
	LOCKON	Z
	.ENDIF
	JAUC	SetAnim

ASGD_X
	RETS

**************************************************************************
*								         *
* 	A_CLR_ALL_Z							 *
* 									 *
* 	Anim func to clear all of the Z movement stuff			 *
* 									 *
* 	A8 = Ptr to any part						 *
*								         *
**************************************************************************
A_CLR_ALL_Z
	CALLA	GET_HEAD_PART
	CLR	A14
	MOVE	A14,*A8(OZVEL),L
	MOVE	A14,*A8(OZACCEL),W
	RETS

**************************************************************************
*								         *
* 	A_CLR_ALL_X							 *
* 									 *
* 	Anim func to clear all of the X movement stuff			 *
* 									 *
* 	A8 = Ptr to any part						 *
*								         *
**************************************************************************
A_CLR_ALL_X
	CALLA	GET_HEAD_PART
	CLR	A14
	MOVE	A14,*A8(OXVEL),L
	MOVE	A14,*A8(OXACCEL),W
	RETS

**************************************************************************
*								         *
* 	A_CLR_ALL_Y							 *
* 									 *
* 	Anim func to clear all of the Y movement stuff			 *
* 									 *
* 	A8 = Ptr to any part						 *
*								         *
**************************************************************************
A_CLR_ALL_Y
	CALLA	GET_HEAD_PART
	CLR	A14
	MOVE	A14,*A8(OYVEL),L
	MOVE	A14,*A8(OYACCEL),W
	RETS

**************************************************************************
*								         *
* 	A_SET_ON_YENEMY							 *
* 									 *
* 	Anim func to set object right on the OYENEMY value.		 *
* 									 *
* 	A8 = Ptr to any part						 *
*								         *
**************************************************************************
A_SET_ON_YENEMY
	CALLR	A_CLR_ALL_Y		;Returns A8 = Head
	
	CLRB	*A8(OJUMPING)		;No more jumping
	MOVE	*A8(OZVAL),A3,L
	MOVE	*A8(OXVAL),A1,L
	MOVE	*A8(OYENEMY),A2,W
	SLL	16,A2
	JAUC	SET_ANIPU		;Position him

**************************************************************************
*								         *
* 	A_HEADON_SHOOT_DONE						 *
* 									 *
* 	Anim func to do something when the headon shoot is done.	 *
* 									 *
* 	A8 = Ptr to any part						 *
*								         *
**************************************************************************
A_HEADON_SHOOT_DONE
	CALLA	GET_HEAD_PART
	MOVE	*A8(OEFLAGS),A14,W
	BTST	B_SIDE,A14
	JRZ	AHSD_X

	MOVI	SIDE_SKATE_ANIM,A1	
	JAUC	SetAnim
AHSD_X
	RETS

**************************************************************************
*								         *
* 	A_SETUP_SIDE_SKATE						 *
* 									 *
* 	Anim func to do all of the necessary stuff for side		 *
* 	skating.							 *
* 									 *
* 	A8 = Ptr to any part						 *
*								         *
**************************************************************************
A_SETUP_SIDE_SKATE
	CALLA	GET_HEAD_PART
	MOVI	60,A0
	MOVK	15,A1
	CALLA	RANGERND
	MOVB	A0,*A8(OSTART_GLIDE)
	MOVIM	SKATE_XACCEL,*A8(OXACCEL),W
	CLR	A14
	MOVB	A14,*A8(OGLIDING)
	MOVB	A14,*A8(OSKATELOOPS)
	MOVB	A14,*A8(OSPINNING)
	MOVE	A14,*A8(OBLOCK_ANIM),L
	MOVIM	SIDE_DEATH_ANIM,*A8(ODEATH_ANIM),L
	MOVIM	SIDE_GLIDE_SHOOT,*A8(OSHOOT_ANIM),L
	RETS

**************************************************************************
*								         *
* 	A_SETUP_HEADON_SKATE						 *
* 									 *
* 	Anim func to do all of the necessary stuff for headon		 *
* 	skating.							 *
* 									 *
* 	A8 = Ptr to any part						 *
*								         *
**************************************************************************
A_SETUP_HEADON_SKATE
	CALLA	GET_HEAD_PART
	MOVI	60,A0
	MOVK	15,A1
	CALLA	RANGERND
	MOVB	A0,*A8(OSTART_GLIDE)
	MOVIM	SKATE_ZACCEL,*A8(OZACCEL),W
	CLR	A14
	MOVB	A14,*A8(OGLIDING)
	MOVB	A14,*A8(OSKATELOOPS)
	MOVB	A14,*A8(OSPINNING)
	MOVE	A14,*A8(OBLOCK_ANIM),L
	MOVIM	HEADON_DEATH_ANIM,*A8(ODEATH_ANIM),L
	MOVIM	HEADON_GLIDE_SHOOT,*A8(OSHOOT_ANIM),L
	RETS

**************************************************************************
*								         *
* 	A_SETUP_SIDE_SPIN						 *
* 									 *
* 	Anim func to do all of the necessary stuff for side		 *
* 	spinning.							 *
* 									 *
* 	A8 = Ptr to any part						 *
*								         *
**************************************************************************
A_SETUP_SIDE_SPIN
	CALLA	GET_HEAD_PART
	ANDNIM	M_BLOCKING,*A8(OEFLAGS),W
	CLR	A14
	MOVB	A14,*A8(OGLIDING)
	MOVE	A14,*A8(OBLOCK_ANIM),L
	MOVKB	1,*A8(OSPINNING)
	MOVIM	SIDE_DEATH_ANIM,*A8(ODEATH_ANIM),L
	MOVIM	SIDE_GLIDE_SHOOT,*A8(OSHOOT_ANIM),L
	RETS


**************************************************************************
*								         *
* 	A_SETUP_SIDE_GLIDE						 *
* 									 *
* 	Anim func to do all of the necessary stuff for side		 *
* 	gliding.							 *
* 									 *
* 	A8 = Ptr to any part						 *
*								         *
**************************************************************************
A_SETUP_SIDE_GLIDE
	CALLA	GET_HEAD_PART
	MOVE	@XSCROLL+16,A14,W
	JRZ	ASSG_NORMAL_FRIC
	MOVIM	SKATE_XFRICTION*4,*A8(OXACCEL),W
	JRUC	ASSG_CONT
ASSG_NORMAL_FRIC
	MOVIM	SKATE_XFRICTION,*A8(OXACCEL),W
ASSG_CONT
	MOVIM	SIDE_DEATH_ANIM,*A8(ODEATH_ANIM),L
	MOVIM	SIDE_GLIDE_SHOOT,*A8(OSHOOT_ANIM),L
	MOVIM	SIDE_GLIDE_BLOCK,*A8(OBLOCK_ANIM),L
	RETS

**************************************************************************
*								         *
* 	A_SETUP_HEADON_GLIDE						 *
* 									 *
* 	Anim func to do all of the necessary stuff for headon		 *
* 	gliding.							 *
* 									 *
* 	A8 = Ptr to any part						 *
*								         *
**************************************************************************
A_SETUP_HEADON_GLIDE
	CALLA	GET_HEAD_PART
	MOVIM	SKATE_ZFRICTION,*A8(OXACCEL),W
	MOVIM	HEADON_DEATH_ANIM,*A8(ODEATH_ANIM),L
	MOVIM	HEADON_GLIDE_SHOOT,*A8(OSHOOT_ANIM),L
	MOVIM	HEADON_GLIDE_BLOCK,*A8(OBLOCK_ANIM),L
	RETS

**************************************************************************
*								         *
* 	A_BRANCH_ON_X_FORWARD						 *
* 									 *
* 	Anim func to branch if this object is going forward in X.	 *
* 	This means +X vel when unflipped and vice-versa.		 *
* 									 *
* 	A8 = Ptr to any part						 *
* 	AARG+,L = Branch if moving forward				 *
*								         *
**************************************************************************
A_BRANCH_ON_X_FORWARD
	CALLA	GETAFARG_LONG	
	MOVE	A0,A1			;Load branch just in case
	CALLA	GET_HEAD_PART		;Head keeps the vel
	MOVE	*A8(OCTRL),A14,W
	BTST	B_FLIPH,A14		;BR = Dealing with unflipped image
	JRZ	ABOXF_NOFLIP

	MOVE	*A8(OXVEL),A14,L	
	JAN	SetAnim
	RETS

ABOXF_NOFLIP
	MOVE	*A8(OXVEL),A14,L
	JAP	SetAnim
	RETS

**************************************************************************
*								         *
* 	A_BRANCH_ON_X_BACKWARD						 *
* 									 *
* 	Anim func to branch if this object is going backward in X.	 *
* 	This means -X vel when unflipped and vice-versa.		 *
* 									 *
* 	A8 = Ptr to any part						 *
* 	AARG+,L = Branch if moving backward				 *
*								         *
**************************************************************************
A_BRANCH_ON_X_BACKWARD
	CALLA	GETAFARG_LONG	
	MOVE	A0,A1			;Load branch just in case
	CALLA	GET_HEAD_PART		;Head keeps the vel
	MOVE	*A8(OCTRL),A14,W
	BTST	B_FLIPH,A14		;BR = Dealing with unflipped image
	JRZ	ABOXB_NOFLIP

	MOVE	*A8(OXVEL),A14,L	
	JAP	SetAnim
	RETS

ABOXB_NOFLIP
	MOVE	*A8(OXVEL),A14,L
	JAN	SetAnim
	RETS

**************************************************************************
*								         *
* 	A_SPIN_DEATH_DONE						 *
* 									 *
* 	Anim func to finish off the spinning death.			 *
* 									 *
* 	A8 = Ptr to any part						 *
*								         *
**************************************************************************
A_SPIN_DEATH_DONE
	CALLA	GET_HEAD_PART
	CLRB	*A8(OSPINNING)

	SOUNDZ	SND_DEATH_LONG

	MOVIM	-40000H,*A8(OYVEL),L	;SEND HIM UP
	MOVIM	4000H,*A8(OYACCEL),W	;AND MAKE HIM COME DOWN
	MOVI	LONG_DEATH_ZVEL,A14
	MOVE	A14,*A8(OZVEL),L	;AND MAKE HIM GET BLOWN BACK

	MOVI	HEADON_DEATH_ANIM,A1
	JAUC	SetAnim

**************************************************************************
*								         *
* 	A_RENEW_JUMP_SLEEP						 *
* 									 *
* 	Anim func to check if there is more jump sleeping to do.	 *
* 									 *
* 	A8 = Ptr to any part						 *
* 	AARG+,L = Branch if there is					 *
*								         *
**************************************************************************
A_RENEW_JUMP_SLEEP
	CALLA	GETAFARG_LONG
	MOVE	A0,A1
	CALLA	GET_HEAD_PART
	MOVE	*A8(OJUMP_SLEEP),A2,W
	JRZ	ARJS_X
	CLR	A4
	CMPI	7FH,A2
	JRLS	ARJS_SLEEP_READY
	MOVE	A2,A4
	MOVI	7FH,A2
	SUB	A2,A4
ARJS_SLEEP_READY
	MOVE	A4,*A8(OJUMP_SLEEP),W	;Store this as the remainder
	MOVB	A2,*A8(AnimSLP)		;Sleep before landing
	JAUC	SetAnim
ARJS_X
	RETS

**************************************************************************
*								         *
* 	A_SOUNDZ_ONSCREEN						 *
* 									 *
* 	Anim func to make a Z based sound if object is on screen.	 *
* 									 *
* 	A8 = Ptr to any part						 *
*								         *
**************************************************************************
A_SOUNDZ_ONSCREEN
	CALLA	GETAFARG_LONG
	CALLA	GET_HEAD_PART
	MOVB	*A8(OFLAGS),A14
	JANN	ONESND_Z		;BR = On screen, make sound
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
NUM_HIT_SNDS	.EQU	3
TAB_HIT_SNDS
	.LONG	SND_HIT1, SND_HIT2, SND_HIT3
SND_HIT1
	.WORD	0F302H,16,0A1DDH,0	;Metal hit
SND_HIT2
	.WORD	0F302H,13,0A1E0H,0	;Metal hit
SND_HIT3
	.WORD	0F302H,27,0A1E3H,0	;Metal hit

SND_CHEST_HIT
	.WORD	0F304H,24,0A1E6H,0	;Chest plate gets hit

SND_SHIELD_HIT
	.WORD	0F105H,62,0A1A1H,0	;Ricochet off shield

SND_DEATH_LONG
	.WORD	0F341H,167,0A238H,0
SND_DEATH_SHORT
	.WORD	0F341H,54,0A235H,0

SND_GROUND_HIT
	.WORD	0F330H,46,0A357H,0

SND_ROCKET_HIT
	.WORD	0F330H,52,0A341H,0

SND_COG_FIRE
	.WORD	0F305H,25,0A10BH,0	;CogHead fire sound
SND_COG_SKATE
	.WORD	0F301H,50,0A423H,0	;CogHead skate
SND_COG_STOP
	.WORD	0F30AH,50,0A423H,0	;CogHead stop
SND_COG_SPIN
	.WORD	0F30AH,50,0A423H,0	;CogHead spin
SND_COG_SPINOUT
	.WORD	0F343H,80,0A2E0H,0	;CogHead spins out from rocket

SND_SHOW_CANCELLED
	.WORD	0F342H,94,082DFH,0		;"The show is cancelled"
SND_CLEAR_STREET
	.WORD	0F342H,72,082DBH,44,082DCH,0	;"Clear the street, now!"
SND_COMBAT_ZONE
	.WORD	0F342H,100,082DDH,0		;"This is a combat zone"
SND_LEAVE_AREA
	.WORD	0F342H,85,082DEH,44,082DCH,0	;"Leave the area, now!"

NUM_BABBLINGS	.EQU	4

BABBLE_TABLE
	.LONG	SND_SHOW_CANCELLED, SND_CLEAR_STREET, SND_COMBAT_ZONE
	.LONG	SND_LEAVE_AREA


COG_INIT
	.byte	 4, 0, 1, 0	;OBJCNT, PRCCNT, IMGPALCNT, PALCNT
	.long	CT1ST_A1	;IMGPAL
	.word	OID_COG, OM_COLL
	.LONG	COG_CVECT
*
*    .long	IMG
*    .word 		  OCTRL,  OFLAGS,   OZOFF, OPTION_FLAGS
*
NUM_LEGS .EQU	1
	LWWWW	CL1ST_A1, DMAWNZ, M_NODISP,	0, OM_GUNV
	.LONG	COG_GUNVECT
NUM_TORSO .EQU	2
	LWWWW	CT1ST_A1, DMAWNZ, M_NODISP,    -1, OM_ANIM|OM_PRVGUNV
	.LONG	ANIM_VELOCITY_WATCH
	LWWWW	CH1ST_A1, DMAWNZ, M_NODISP,    -2, OM_PRVGUNV
	LWWWW	CT1ST_A1, DMAWNZ, M_NODISP,    -1, OM_PRVGUNV


*
*Animation script to keep tabs on the velocity and movement boundries
*
ANIM_VELOCITY_WATCH
	LWL	1,1|AFunc,A_VELOCITY_WATCH
	.LONG	0

SIDE_SKATE_ANIM
	LWLL	1,1|AMulti|AFunc,A_AnimGo+2,SIDE_SKATE_LOOP
	LWL	1,1|AFunc,A_SETUP_SIDE_SKATE

SIDE_SKATE_LOOP
	LWLL	CL3SK_C1,1|AMulti|AFunc,A_GLIDE_CK+2,SIDE_GLIDE
	LWLL	CT3SK_C1,1|AMulti|AFunc,A_SOUNDZ_ONSCREEN+2,SND_COG_SKATE
	LW	CH3SK_C1,1|AMulti
	LWL	CA3SK_C1,COG_FRAME_TIME-1|AFunc,OBJ_ON

	LW	CL3SK_C2,1|AMulti
	LW	CT3SK_C2,1|AMulti
	LW	CH3SK_C2,1|AMulti
	LW	CA3SK_C2,COG_FRAME_TIME-1

	LW	CL3SK_C3,1|AMulti
	LW	CT3SK_C3,1|AMulti
	LW	CH3SK_C3,1|AMulti
	LW	CA3SK_C3,COG_FRAME_TIME-1

	LW	CL3SK_C4,1|AMulti
	LW	CT3SK_C4,1|AMulti
	LW	CH3SK_C4,1|AMulti
	LW	CA3SK_C4,COG_FRAME_TIME

	LW	CL3SK_C5,1|AMulti
	LW	CT3SK_C5,1|AMulti
	LW	CH3SK_C5,1|AMulti
	LW	CA3SK_C5,COG_FRAME_TIME-1

	LW	CL3SK_C6,1|AMulti
	LW	CT3SK_C6,1|AMulti
	LW	CH3SK_C6,1|AMulti
	LW	CA3SK_C6,COG_FRAME_TIME-1

	LW	CL3SK_C7,1|AMulti
	LW	CT3SK_C7,1|AMulti
	LW	CH3SK_C7,1|AMulti
	LWL	1,(COG_FRAME_TIME-1)|AFunc,OBJ_OFF

	LW	CL3SK_C8,1|AMulti
	LW	CT3SK_C8,1|AMulti
	LW	CH3SK_C8,1|AMulti
	LWL	1,(COG_FRAME_TIME-1)|AFunc,OBJ_OFF

	LW	CL3SK_C9,1|AMulti
	LW	CT3SK_C9,1|AMulti
	LW	CH3SK_C9,1|AMulti
	LWL	1,COG_FRAME_TIME|AFunc,OBJ_OFF

	LWLL	CL3SK_C10,1|AMulti|AFunc,A_SIDE_SCREEN_CK+2,SIDE_OFF_OPP
	LW	CT3SK_C10,1|AMulti
	LW	CH3SK_C10,1|AMulti
	LWL	CA3SK_C10,(COG_FRAME_TIME-1)|AFunc,OBJ_ON

	.LONG	0

SIDE_OFF_OPP
	LWLL	1,1|AMulti|AFunc,A_AnimGo+2,SIDE_SPIN_REVERSE
	LWLWL	1,1|AFunc,A_SET_REL_LONG_HEAD+3,OHITS,0

SIDE_GLIDE
	LWL	CL3GL_C2,1|AMulti|AFunc,A_SETUP_SIDE_GLIDE
	LWLLW	CT3GL_C2,1|AMulti|AFunc,A_Set_Var_Word+3,SPEAK_AT_PLAYER,1
	LW	CH3GL_C2,1|AMulti
	LWL	1,1|AFunc,OBJ_OFF

	LWLWW	1,1|AFunc,A_RAND_AnimSLP+2,15,25

	LWL	1,1|AFunc,A_SIDE_GLIDE_DECIDE

	LW	1,0
SIDE_GLIDE_SHOOT
	LWLWWW	CL3GLSH_C3,1|AMulti|AFunc,A_RAND_REL_BYTE+3,2,6,ORAPIDCNT
	LW	CT3GLSH_C2,1|AMulti
	LWL	CH3GLSH_C2,5|AFunc,A_INITIALIZE_FIRING

SIDE_GLIDE_RAPID_FIRE
	LW	1,1|AMulti
	LW	1,1|AMulti
	LWLWW	1,1|AFunc,A_FIRE_FNC+2,14,-74

	LW	1,1|AMulti
	LWLL	CT3GLSH_C3,1|AMulti|AFunc,A_CHANGE_PAL+2,P_GXCOGF
	LWLL	CA3GLSH_C3,4|AFunc,A_CHANGE_PAL+2,P_GXCOGF

	LW	1,1|AMulti
	LWLL	CT3GLSH_C2,1|AMulti|AFunc,A_CHANGE_PAL+2,P_GXCOGY
	LWLL	CH3GLSH_C2,1|AFunc,A_CHANGE_PAL+2,P_GXCOGY

	LWLL	1,4|AFunc,A_STAND_RAPIDFIRE_DECISION+2,SIDE_GLIDE_RAPID_FIRE

	LW	CL3GLSH_C1,1|AMulti
	LW	CT3GLSH_C1,1|AMulti
	LW	CH3GLSH_C1,4

	LWL	1,1|AFunc,A_SIDE_GLIDE_END

SIDE_SPIN_REVERSE
;	LW	CL3SP_C1,1|AMulti
;	LW	CT3SP_C1,1|AMulti
;	LW	CH3SP_C1,1|AMulti
;	LWL	1,3|AFunc,OBJ_OFF

	LWL	CL3SP_C2,1|AMulti|AFunc,A_SETUP_SIDE_SPIN
	LWLL	CT3SP_C2,1|AMulti|AFunc,A_SOUNDZ+2,SND_COG_SPIN
	LW	CH3SP_C2,3|AMulti
	LWL	1,3|AFunc,OBJ_OFF

	LW	CL3SP_C3,1|AMulti
	LW	CT3SP_C3,1|AMulti
	LW	CH3SP_C3,3

	LW	CL3SP_C4,1|AMulti
	LW	CT3SP_C4,1|AMulti
	LW	CH3SP_C4,1|AMulti
	LWL	CA3SP_C4,3|AFunc,OBJ_ON

	LW	CL3SP_C5,1|AMulti
	LW	CT3SP_C5,1|AMulti
	LW	CH3SP_C5,1|AMulti
	LWL	1,3|AFunc,OBJ_OFF

	LW	CL3SP_C6,1|AMulti
	LW	CT3SP_C6,1|AMulti
	LW	CH3SP_C6,3

	LWLL	CL3SP_C7,1|AMulti|AFunc,A_FLIP_BRANCH+2,SS_REV_FLIPPED
	LW	CT3SP_C7,1|AMulti
	LW	CH3SP_C7,3

	LWWLL	CL3SK_C1,1|AMulti|AFlip|AFunc,M_FLIPH,A_AnimGo+2,SIDE_SKATE_ANIM
	LWW	CT3SK_C1,1|AMulti|AFlip,M_FLIPH
	LWW	CH3SK_C1,1|AMulti|AFlip,M_FLIPH
	LWWL	CA3SK_C1,1|AFlip|AFunc,M_FLIPH,OBJ_ON

SS_REV_FLIPPED
	LWWLL	CL3SK_C1,1|AMulti|AFlip|AFunc,0,A_AnimGo+2,SIDE_SKATE_ANIM
	LWW	CT3SK_C1,1|AMulti|AFlip,0
	LWW	CH3SK_C1,1|AMulti|AFlip,0
	LWWL	CA3SK_C1,1|AFlip|AFunc,0,OBJ_ON

*
* Spin and stop
*
SIDE_SPIN_STOP
;	LW	CL3SP_C1,1|AMulti
;	LW	CT3SP_C1,1|AMulti
;	LW	CH3SP_C1,1|AMulti
;	LWL	1,3|AFunc,OBJ_OFF

	LWL	CL3SP_C2,1|AMulti|AFunc,A_SETUP_SIDE_SPIN
	LWLL	CT3SP_C2,1|AMulti|AFunc,A_SOUNDZ+2,SND_COG_SPIN
	LW	CH3SP_C2,3|AMulti
	LWL	1,3|AFunc,OBJ_OFF

	LW	CL3SP_C3,1|AMulti
	LW	CT3SP_C3,1|AMulti
	LW	CH3SP_C3,3

	LW	CL3SP_C4,1|AMulti
	LW	CT3SP_C4,1|AMulti
	LW	CH3SP_C4,1|AMulti
	LWL	CA3SP_C4,3|AFunc,OBJ_ON

	LW	CL3SP_C5,1|AMulti
	LW	CT3SP_C5,1|AMulti
	LW	CH3SP_C5,1|AMulti
	LWL	1,3|AFunc,OBJ_OFF

	LW	CL3SP_C6,1|AMulti
	LW	CT3SP_C6,1|AMulti
	LW	CH3SP_C6,3

	LW	CL3SP_C7,1|AMulti
	LW	CT3SP_C7,1|AMulti
	LW	CH3SP_C7,3

	LW	CL3SP_C8,1|AMulti
	LW	CT3SP_C8,1|AMulti
	LW	CH3SP_C8,3

	LW	CL1SP_A1,1|AMulti
	LW	CT1SP_A1,1|AMulti
	LW	CH1SP_A1,3

	LW	CL1SP_A2,1|AMulti
	LW	CT1SP_A2,1|AMulti
	LW	CH1SP_A2,3

	LWLWW	CL1SK_A7,1|AMulti|AFunc,A_Set_Rel_Word+2,OXACCEL,SKATE_XBRAKE
	LWLL	CT1SK_A7,1|AMulti|AFunc,A_SOUNDZ_ONSCREEN+2,SND_COG_STOP
	LW	CH1SK_A7,1|AMulti
	LWL	1,1|AFunc,OBJ_OFF

SSS_LOOP
	LWLL	1,1|AFunc,A_BRANCH_ON_X_FORWARD+2,SSS_LOOP

	LWLL	CL1SK_A8,1|AMulti|AFunc,A_AnimGo+2,HEADON_STAND_SHOOT
	LWL	CT1SK_A8,1|AMulti|AFunc,A_CLR_ALL_X
	LWLWW	CH1SK_A8,3|AFunc,A_Set_Rel_Byte_Head+2,OSPINNING,0

*
* Stop and stand 'til offscreen
*
SIDE_STOP_STAND
	LWLWW	CL1SK_A7,1|AMulti|AFunc,A_Set_Rel_Word+2,OXACCEL,SKATE_XBRAKE
	LWLL	CT1SK_A7,1|AMulti|AFunc,A_SOUNDZ_ONSCREEN+2,SND_COG_STOP
	LW	CH1SK_A7,1|AMulti
	LWL	1,1|AFunc,OBJ_OFF

SSST_LOOP
	LWLL	1,1|AFunc,A_BRANCH_ON_X_FORWARD+2,SSST_LOOP

	LWL	CL1SK_A8,1|AMulti|AFunc,A_CLR_ALL_X
	LW	CT1SK_A8,1|AMulti
	LW	CH1SK_A8,200

SSST_OFF_LOOP
	LWLL	1,1|AMulti|AFunc,A_AnimGo+2,SSST_OFF_LOOP
	LWL	1,15|AFunc,A_SCREEN_CK

*
* Throw a block while gliding to the side
*
SIDE_GLIDE_BLOCK
	LWLL	CL3GLB_C1,1|AMulti|AFunc,A_CHANGE_PAL+2,P_GXCOGY
	LWLL	CT3GLB_C1,1|AMulti|AFunc,A_CHANGE_PAL+2,P_GXCOGY
	LWLL	CH3GLB_C1,1|AMulti|AFunc,A_CHANGE_PAL+2,P_GXCOGY
	LWLL	1,3|AFunc,A_OBJ_OFF_CHANGE_PAL+2,P_GXCOGY

	LWL	CL3GLB_C2,1|AMulti|AFunc,A_SET_BLOCKTIME
	LW	CT3GLB_C3,1|AMulti
	LW	CH3GLB_C3,1|AMulti
	LWL	CA3GLB_C3,4|AFunc,OBJ_ON

SIDE_GLIDE_HOLD_BLOCK
	LWLL	1,1|AFunc,A_BRANCH_ON_X_BACKWARD+2,SIDE_SPIN_REVERSE
	LWLL	1,4|AFunc,A_CHECK_UNBLOCK+2,SIDE_GLIDE_HOLD_BLOCK

	LW	CL3GLB_C1,1|AMulti
	LW	CT3GLB_C1,1|AMulti
	LW	CH3GLB_C1,1|AMulti
	LWL	1,3|AFunc,OBJ_OFF

	LWL	1,1|AFunc,A_CLR_BLOCK

	LWL	1,1|AFunc,A_JUMP_TO_SHOOT

*
* Use this to jump
*
SIDE_JUMP_ANIM
	LWLL	CL3J_C14,1|AMulti|AFunc,A_RENEW_JUMP_SLEEP+2,SIDE_JUMP_ANIM
	LW	CT3J_C14,1|AMulti
	LW	CH3J_C14,1|AMulti
	LWL	1,0|AFunc,OBJ_OFF

	LWL	CL3J_C10,1|AMulti|AFunc,A_SET_ON_YENEMY
	LW	CT3J_C10,1|AMulti
	LW	CH3J_C10,3

	LW	CL3J_C12,1|AMulti
	LW	CT3J_C12,1|AMulti
	LW	CH3J_C12,3

	LWLL	1,1|AFunc,A_AnimGo+2,SIDE_SKATE_ANIM


HEADON_STOP_ANIM
;	LWLW	C_B3SKxSTA3,COG_FRAME_TIME|AFunc,A_SHIFT_XVEL+1,1
;	LW	C_B3SKxSTA4,COG_FRAME_TIME
;	LWLW	C_B3SKxSTA5,COG_FRAME_TIME|AFunc,A_SHIFT_XVEL+1,1
;	LWL	C_B3SKxSTA6,COG_FRAME_TIME|AFunc,A_FACE_CLR_VEL
;	LWL	C_B3SKxSTA8,COG_FRAME_TIME|AFunc,A_JUMP_TO_SHOOT

*
* Stop and stand facing the player
*
HEADON_STAND_SHOOT
	LWL	CL1ST_A1,1|AMulti|AFunc,A_FACE_CLR_VEL
	LW	CT1ST_A1,1|AMulti
	LW	CH1ST_A1,1|AMulti
	LWL	1,1|AFunc,OBJ_OFF

	LWLWW	1,1|AFunc,A_RAND_AnimSLP+2,15,25

	LW	1,0

HEADON_SHOOT_ANIM
	LWLWWW	CL1STSH_A3,1|AMulti|AFunc,A_RAND_REL_BYTE+3,3,7,OBURSTCNT
	LW	CT1STSH_A3,1|AMulti
	LWL	CH1STSH_A3,1|AMulti|AFunc,A_INITIALIZE_FIRING
	LW	CA1STSH_A3,5

HEADON_SHOOTER
	LWLWWW	CL1STSH_A1,1|AMulti|AFunc,A_RAND_REL_BYTE+3,2,6,ORAPIDCNT
	LW	CT1STSH_A1,1|AMulti
	LWL	CH1STSH_A1,1|AMulti|AFunc,OBJ_ON
	LWL	CA1STSH_A1,5|AFunc,OBJ_ON
HEADON_RAPID_FIRE
	LW	1,1|AMulti
	LW	1,1|AMulti
	LWLWW	1,1|AFunc,A_FIRE_FNC+2,-18,-100

	LWLL	CL1STSH_A2,1|AMulti|AFunc,A_CHANGE_PAL+2,P_GXCOGF
	LWLL	CT1STSH_A2,1|AMulti|AFunc,A_CHANGE_PAL+2,P_GXCOGF
	LWLL	CH1STSH_A2,1|AMulti|AFunc,A_CHANGE_PAL+2,P_GXCOGF
	LWL	1,4|AFunc,OBJ_OFF

	LWLL	CL1STSH_A1,1|AMulti|AFunc,A_CHANGE_PAL+2,P_GXCOGY
	LWLL	CT1STSH_A1,1|AMulti|AFunc,A_CHANGE_PAL+2,P_GXCOGY
	LWLL	CH1STSH_A1,1|AMulti|AFunc,A_CHANGE_PAL+2,P_GXCOGY
	LWL	CA1STSH_A1,1|AFunc,OBJ_ON

	LWLL	1,4|AFunc,A_STAND_RAPIDFIRE_DECISION+2,HEADON_RAPID_FIRE

	LWLL	1,1|AFunc,A_STAND_FIRE_DECISION+2,HEADON_SHOOTER

	LWL	1,1|AFunc,A_HEADON_SHOOT_DONE

HEADON_SKATE_ANIM
;	LWLL	1,1|AMulti|AFunc,A_AnimGo+2,HEADON_SKATE_LOOP
;	LWL	1,1|AFunc,A_SETUP_HEADON_SKATE

HEADON_SKATE_LOOP
;	LWLL	CL1SK_A3,1|AMulti|AFunc,A_GLIDE_CK+2,SIDE_GLIDE
;	LWLL	CT1SK_A3,1|AMulti|AFunc,A_SOUNDZ_ONSCREEN+2,SND_COG_SKATE
;	LWL	CH1SK_A3,(COG_FRAME_TIME-1)|AFunc,OBJ_ON

;	LW	CL1SK_A4,1|AMulti
;	LW	CT1SK_A4,1|AMulti
;	LW	CH1SK_A4,COG_FRAME_TIME-1

;	LW	CL1SK_A5,1|AMulti
;	LW	CT1SK_A5,1|AMulti
;	LW	CH1SK_A5,COG_FRAME_TIME-1

;	LW	CL1SK_A6,1|AMulti
;	LW	CT1SK_A6,1|AMulti
;	LW	CH1SK_A6,COG_FRAME_TIME-1

;	LW	CL1SK_A7,1|AMulti
;	LW	CT1SK_A7,1|AMulti
;	LW	CH1SK_A7,COG_FRAME_TIME

;	LW	CL1SK_A6,1|AMulti
;	LW	CT1SK_A8,1|AMulti
;	LW	CH1SK_A8,COG_FRAME_TIME-1

;	LW	CL1SK_A5,1|AMulti
;	LWLL	CT1SK_A9,1|AMulti|AFunc,A_SOUNDZ_ONSCREEN+2,SND_COG_SKATE
;	LW	CH1SK_A9,(COG_FRAME_TIME-1)

;	LW	CL1SK_A8,1|AMulti
;	LW	CT1SK_A10,1|AMulti
;	LW	CH1SK_A10,(COG_FRAME_TIME-1)

;	LW	CL1SK_A3,1|AMulti
;	LW	CT1SK_A11,1|AMulti
;	LW	CH1SK_A11,COG_FRAME_TIME-1

;	LW	CL1SK_A2,1|AMulti
;	LW	CT1SK_A12,1|AMulti
;	LW	CH1SK_A12,(COG_FRAME_TIME-1)

;	LW	CL1SK_A1,1|AMulti
;	LW	CT1SK_A1,1|AMulti
;	LW	CH1SK_A1,COG_FRAME_TIME

;	LWLL	CL1SK_A2,1|AMulti|AFunc,A_SIDE_SCREEN_CK+2,SIDE_OFF_OPP
;	LW	CT1SK_A2,1|AMulti
;	LW	CH1SK_A2,(COG_FRAME_TIME-1)

;	.LONG	0


HEADON_GLIDE
;	LWL	CL1GL_A1,1|AMulti|AFunc,A_SETUP_SIDE_GLIDE
;	LWLLW	CT1GL_A1,1|AMulti|AFunc,A_Set_Var_Word+3,SPEAK_AT_PLAYER,1
;	LW	CH1GL_A1,1|AMulti
;	LWL	1,1|AFunc,OBJ_OFF

;	LWLWW	1,1|AFunc,A_RAND_AnimSLP+2,15,25

;	LW	1,0
HEADON_GLIDE_SHOOT
;	LWLWWW	CL1GLSH_A1,1|AMulti|AFunc,A_RAND_REL_BYTE+3,2,6,ORAPIDCNT
;	LWL	CT1GLSH_A1,1|AMulti|AFunc,A_INITIALIZE_FIRING
;	LW	CH1GLSH_A1,1|AMulti
;	LWL	CA1GLSH_A1,5|AFunc,OBJ_ON

HEADON_GLIDE_RAPID_FIRE
;	LW	1,1|AMulti
;	LWLWW	1,1|AFunc,A_FIRE_FNC+2,-5,-88

;	LW	1,1|AMulti
;	LWLL	CT1GLSH_A2,1|AMulti|AFunc,A_CHANGE_PAL+2,P_GXCOGF
;	LWLL	CA1GLSH_A2,4|AFunc,A_CHANGE_PAL+2,P_GXCOGF
;	LWL	1,1|AFunc,OBJ_OFF

;	LW	1,1|AMulti
;	LWLL	CT1GLSH_A1,1|AMulti|AFunc,A_CHANGE_PAL+2,P_GXCOGY
;	LWLL	CH1GLSH_A1,1|AMulti|AFunc,A_CHANGE_PAL+2,P_GXCOGY
;	LWL	CA1GLSH_A1,5|AFunc,OBJ_ON

;	LWLL	1,4|AFunc,A_STAND_RAPIDFIRE_DECISION+2,HEADON_GLIDE_RAPID_FIRE

;	LW	CL1GL_A1,1|AMulti
;	LW	CT1GL_A1,1|AMulti
;	LW	CH1GL_A1,4

;	LWL	1,1|AFunc,A_HEADON_GLIDE_END

*
* Throw a block while gliding headon
*
HEADON_GLIDE_BLOCK
;	LWLL	CL1GL_A1,1|AMulti|AFunc,A_CHANGE_PAL+2,P_GXCOGY
;	LWLL	CT1GLB_A1,1|AMulti|AFunc,A_CHANGE_PAL+2,P_GXCOGY
;	LWLL	CH1GLB_A1,1|AMulti|AFunc,A_CHANGE_PAL+2,P_GXCOGY
;	LWLL	1,3|AFunc,A_OBJ_OFF_CHANGE_PAL+2,P_GXCOGY

;	LWL	CL1GLB_A3,1|AMulti|AFunc,A_SET_BLOCKTIME
;	LW	CT1GLB_A3,1|AMulti
;	LW	CH1GLB_A3,4

HEADON_GLIDE_HOLD_BLOCK
;	LWLL	1,4|AFunc,A_CHECK_UNBLOCK+2,HEADON_GLIDE_HOLD_BLOCK

;	LW	CL1GL_A1,1|AMulti
;	LW	CT1GLB_A1,1|AMulti
;	LW	CH1GLB_A1,3

;	LWL	1,1|AFunc,A_CLR_BLOCK

;	LWL	1,1|AFunc,A_JUMP_TO_SHOOT

*
* Throw a block while standing and shooting forward
*
STANDING_BLOCK
	LWLL	CL1STB_A3,1|AMulti|AFunc,A_CHANGE_PAL+2,P_GXCOGY
	LWLL	CT1STB_A3,1|AMulti|AFunc,A_CHANGE_PAL+2,P_GXCOGY
	LWLL	1,1|AMulti|AFunc,A_OBJ_OFF_CHANGE_PAL+2,P_GXCOGY
	LWLL	1,1|AFunc,A_OBJ_OFF_CHANGE_PAL+2,P_GXCOGY

	LWL	1,4|AFunc,A_SET_BLOCKTIME
HOLD_BLOCK
	LWLL	1,5|AFunc,A_CHECK_UNBLOCK+2,HOLD_BLOCK

	LW	CL1STB_A1,1|AMulti
	LW	CT1STB_A2,4

	LWL	1,1|AFunc,A_CLR_BLOCK
	LWL	1,1|AFunc,A_JUMP_TO_SHOOT


*
* Spin death
*
SPIN_DEATH_ANIM
	LWLW	1,1|AMulti|AFunc,A_Set_AnimLoop+1,4
	LWLL	1,1|AMulti|AFunc,A_SOUNDZ+2,SND_COG_SPINOUT
	LWL	1,1|AFunc,A_SETUP_SIDE_SPIN

	LWLWL	1,1|AFunc,A_CREATEP_R+9,PID_IND,THROW_SHIELD
	.LONG	0
	.LONG	[-010H,-0100H]
	.LONG	[-060H,010H]

	LWLL	CL3SP_C2,1|AMulti|AFunc,A_CHANGE_PAL+2,P_GXCOGY
	LWLL	CT3SP_C2,1|AMulti|AFunc,A_CHANGE_PAL+2,P_GXCOGY
	LWLL	CH3SP_C2,1|AMulti|AFunc,A_OBJ_ON_CHANGE_PAL+2,P_GXCOGY
	LWLL	1,4|AFunc,A_OBJ_OFF_CHANGE_PAL+2,P_GXCOGY

SPIN_DEATH_LOOP
	LW	CL3SP_C2,1|AMulti
	LW	CT3SP_C2,1|AMulti
	LW	CH3SP_C2,3|AMulti
	LWL	1,1|AFunc,OBJ_OFF

	LW	CL3SP_C3,1|AMulti
	LW	CT3SP_C3,1|AMulti
	LW	CH3SP_C3,1

	LW	CL3SP_C4,1|AMulti
	LW	CT3SP_C4,1|AMulti
	LW	CH3SP_C4,1|AMulti
	LWL	CA3SP_C4,1|AFunc,OBJ_ON

	LW	CL3SP_C5,1|AMulti
	LW	CT3SP_C5,1|AMulti
	LW	CH3SP_C5,1|AMulti
	LWL	1,1|AFunc,OBJ_OFF

	LW	CL3SP_C6,1|AMulti
	LW	CT3SP_C6,1|AMulti
	LW	CH3SP_C6,1

	LW	CL3SP_C7,1|AMulti
	LW	CT3SP_C7,1|AMulti
	LW	CH3SP_C7,1

	LW	CL3SP_C8,1|AMulti
	LW	CT3SP_C8,1|AMulti
	LW	CH3SP_C8,1

	LW	CL1SP_A1,1|AMulti
	LW	CT1SP_A1,1|AMulti
	LW	CH1SP_A1,1

	LWLL	CL1SP_A2,1|AMulti|AFunc,A_Anim_DSJ+2,SPIN_DEATH_LOOP
	LW	CT1SP_A2,1|AMulti
	LW	CH1SP_A2,1

	LWL	1,1|AFunc,A_SPIN_DEATH_DONE

;HEADON_DEATH_ANIM
;BUSTER_DEATH_ANIM
;	LWLL	CL1D_A1,1|AMulti|AFunc,A_CHANGE_PAL+2,P_GXCOGY
;	LWLL	CT1D_A1,1|AMulti|AFunc,A_CHANGE_PAL+2,P_GXCOGY
;	LWLL	CA1D_A1,1|AMulti|AFunc,A_OBJ_ON_CHANGE_PAL+2,P_GXCOGY
;	LWLL	CH1D_A1,4|AFunc,A_OBJ_ON_CHANGE_PAL+2,P_GXCOGY

;	LW	CL1D_A2,1|AMulti
;	LW	CT1D_A2,1|AMulti
;	LW	CA1D_A2,1|AMulti
;	LW	CH1D_A2,4

;	LW	CL1D_A3,1|AMulti
;	LW	CT1D_A3,1|AMulti
;	LW	CA1D_A3,1|AMulti
;	LW	CH1D_A3,4

ROCKET_DEATH_GROUND_WAIT
	LWLWL	1,1|AFunc,A_GROUND_CK+3,0,ROCKET_DEATH_GROUND_WAIT

	LWL	CH1D_A7,1|AMulti|AFunc,A_HIT_GROUND
	LWLL	CA1D_A7,1|AMulti|AFunc,A_SOUNDZ+2,SND_GROUND_HIT
	LW	CT1D_A7,1|AMulti
	LW	CL1D_A7,4

	LWL	CZ1D_A8,1|AMulti|AFunc,A_CLR_ALL_Z
	LW	CA1D_A8,1|AMulti
	LW	CL1D_A8,1|AMulti
	LWL	1,4|AFunc,OBJ_OFF

	LW	CZ1D_A9,1|AMulti
	LW	CT1D_A9,1|AMulti
	LW	CL1D_A9,4

	LWL	CZ1D_A10,1|AMulti|AFunc,A_CLR_ALL_X
	LW	CA1D_A10,1|AMulti
	LW	CT1D_A10,1|AMulti
	LWL	CL1D_A10,60|AFunc,OBJ_ON

	LWL	1,1|AFunc,DELETE_ENEMY

BUSTER_DEATH_ANIM
	LWL	1,1|AFunc,DELAYED_PRAISE
	LWLL	1,1|AFunc,A_AnimGo+2,SIDE_DEATH_ANIM

HEADON_DEATH_ANIM
SIDE_DEATH_ANIM
	LWLL	CL1D_A4,1|AMulti|AFunc,A_CHANGE_PAL+2,P_GXCOGY
	LWLL	CT1D_A4,1|AMulti|AFunc,A_CHANGE_PAL+2,P_GXCOGY
	LWLL	CA1D_A4,1|AMulti|AFunc,A_OBJ_ON_CHANGE_PAL+2,P_GXCOGY
	LWLL	CH1D_A4,4|AFunc,A_OBJ_ON_CHANGE_PAL+2,P_GXCOGY

	LW	CH1D_A5,1|AMulti
	LW	CA1D_A5,1|AMulti
	LW	CT1D_A5,1|AMulti
	LW	CL1D_A5,4

	LWLL	CH1D_A6,1|AMulti|AFunc,A_AnimGo+2,ROCKET_DEATH_GROUND_WAIT
	LW	CA1D_A6,1|AMulti
	LW	CT1D_A6,1|AMulti
	LW	CL1D_A6,4


*
* Cog Head busting through NON poster at beginning of game
*
COG_BUST_ANIM
	LW	CL1J_A5,1|AMulti
	LW	CT1J_A5,1|AMulti
	LW	CH1J_A5,1|AMulti
	LW	CA1J_A5,15

	LWL	1,1|AFunc,A_START_BUST_VELS

COG_BUST_ALMOST_WT
	LWLWL	1,1|AFunc,A_ABOVE_CK+3,25,COG_BUST_ALMOST_WT

	LW	CL1J_A7,1|AMulti
	LW	CT1J_A7,1|AMulti
	LW	CH1J_A7,1|AMulti
	LW	CA1J_A7,5

	LW	CL1J_A8,1|AMulti
	LW	CT1J_A8,1|AMulti
	LW	CH1J_A8,1|AMulti
	LW	CA1J_A8,1

COG_BUST_LAND_WT	
	LWLWL	1,1|AFunc,A_GROUND_CK+3,0,COG_BUST_LAND_WT

	LWLL	CB1J_A9,1|AMulti|AFunc,A_SET_OZVEL+2,0
	LWL	CH1J_A9,1|AMulti|AFunc,A_HIT_GROUND
	LWL	1,1|AMulti|AFunc,OBJ_OFF
	LWL	1,12|AFunc,OBJ_OFF

	LW	CL1J_A2,1|AMulti
	LW	CT1J_A2,1|AMulti
	LWL	CH1J_A2,4|AFunc,OBJ_ON

	LW	CL1ST_A1,1|AMulti
	LW	CT1ST_A1,1|AMulti
	LW	CH1ST_A1,20

	LWLWW	1,1|AFunc,A_RAND_AnimSLP+2,15,25
	LWL	1,0|AFunc,A_SET_BLOCK_AND_BUST_VECT

	LWL	1,COG_FRAME_TIME|AFunc,A_CLR_BLOCK

BUSTER_START_SHOOT
	LW	CL1STSH_A3,1|AMulti
	LW	CT1STSH_A3,1|AMulti
	LWL	CH1STSH_A3,1|AMulti|AFunc,A_INITIALIZE_FIRING
	LW	CA1STSH_A3,5

BUSTER_SHOOTER
	LWLWWW	CL1STSH_A1,1|AMulti|AFunc,A_RAND_REL_BYTE+3,2,6,ORAPIDCNT
	LW	CT1STSH_A1,1|AMulti
	LWL	CH1STSH_A1,1|AMulti|AFunc,OBJ_ON
	LWL	CA1STSH_A1,5|AFunc,OBJ_ON
BUSTER_RAPID_FIRE
	LW	1,1|AMulti
	LW	1,1|AMulti
	LWLWW	1,1|AMulti|AFunc,A_BUSTER_FIRE_FNC+2,-18,-100
	LWLL	1,1|AFunc,A_SOUNDZ+2,SND_COG_FIRE

	LWLL	CL1STSH_A2,1|AMulti|AFunc,A_CHANGE_PAL+2,P_GXCOGF
	LWLL	CT1STSH_A2,1|AMulti|AFunc,A_CHANGE_PAL+2,P_GXCOGF
	LWLL	CH1STSH_A2,1|AMulti|AFunc,A_CHANGE_PAL+2,P_GXCOGF
	LWL	1,4|AFunc,OBJ_OFF

	LWLL	CL1STSH_A1,1|AMulti|AFunc,A_CHANGE_PAL+2,P_GXCOGY
	LWLL	CT1STSH_A1,1|AMulti|AFunc,A_CHANGE_PAL+2,P_GXCOGY
	LWLL	CH1STSH_A1,1|AMulti|AFunc,A_CHANGE_PAL+2,P_GXCOGY
	LWL	CA1STSH_A1,1|AFunc,OBJ_ON

	LWLL	1,4|AFunc,A_STAND_RAPIDFIRE_DECISION+2,BUSTER_RAPID_FIRE

	LWLL	CL1STSH_A3,1|AMulti|AFunc,A_AnimFrm+2,BUSTER_SHOOTER
	LW	CT1STSH_A3,1|AMulti
	LW	CH1STSH_A3,1|AMulti
	LW	CA1STSH_A3,5

*
* The Club X bouncer Cog
*
COG_BOUNCER_ANIM
	LW	CL1ST_A1,1|AMulti
	LW	CT1ST_A1,1|AMulti
	LW	CH1ST_A1,1|AMulti
	LWL	1,110|AFunc,OBJ_OFF	;This needs to be here

	LWL	1,1|AFunc,A_SET_BUST_VECT

	LWLL	1,1|AFunc,A_AnimGo+2,BUSTER_START_SHOOT


*
* Cog Head that stands, then takes off to jump
*
COG_JUMPSTART_ANIM
	LW	CL1ST_A1,1|AMulti
	LW	CT1ST_A1,1|AMulti
	LW	CH1ST_A1,1|AMulti
	LWL	1,15|AFunc,OBJ_OFF	;This needs to be here

	LWLL	1,1|AFunc,A_AnimGo+2,SIDE_SKATE_ANIM

**************************************************************************
*								         *
* Jumping Cog Head tables						 *
* 									 *
* 	.WORD	Direction (0 = Facing Right, 1 = Facing Left)		 *
* 	.LONG	Universe X jump 1, Universe X land 1			 *
* 	  .								 *
* 	  . 								 *
* 	  .								 *
* 	.LONG	Universe X jump n, 0 (This is his turn around)		 *
*								         *
**************************************************************************

*
* Starting at left of L.A. parking garage
*
TAB_GARAGE_LEFT
	.WORD	0
	.WORD	1A4DH,1C43H
	.WORD	21C2H,2386H
	.WORD	2440H,0
	
*
* Starting at right of L.A. parking garage
*
TAB_GARAGE_RIGHT
	.WORD	1
	.WORD	2386H,21C2H
	.WORD	1C43H,1A4DH
	.WORD	1700H,0

**************************************************************************
*								         *
*  Bridge jumping tables						 *
* 									 *
* 	.WORD	Left univ X boundry, Right univ X boundry		 *
* 	.LONG	Test function to tell if bridge piece is intact		 *
* 	  .								 *
* 	  .								 *
* 	  .								 *
* 	.LONG	0	;End 						 *
*								         *
**************************************************************************
JT_LEFT	.EQU	0
JT_RIGHT .EQU	10H
JT_TEST	.EQU	20H
JT_SIZE	.EQU	40H

TAB_JBRIDGE
	.WORD	2DAH,342H
	.LONG	TF_LEFT_JBRIDGE
	.WORD	318H,381H
	.LONG	TF_RIGHT_JBRIDGE
	.LONG	0

*
* Test funcs for bridge jumping tables.
* Return:
*	 Z = Bridge piece is present
*	NZ = Bridge piece is missing
*
TF_LEFT_JBRIDGE
	MOVE	@BRIDGE_DESTROYED,A14,W
	BTST	0,A14
	RETS

TF_RIGHT_JBRIDGE
	MOVE	@BRIDGE_DESTROYED,A14,W
	BTST	1,A14
	RETS

	.END
