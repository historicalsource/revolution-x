 	.MLIB	"GXMACS.LIB"
	.FILE	"GXMONDOR.ASM"
	.TITLE	"<<< REVOLUTION X -- MONDOR THE CARNIVOROUS ROCKER >>>"
	.WIDTH	132
	.OPTION	B,D,L,T
	.MNOLIST

**************************************************************************
*								         *
* 	COPYRIGHT (C) 1993 MIDWAY MANUFACTURING COMPANY.		 *
* 		       ALL RIGHTS RESERVED.				 *
*								         *
**************************************************************************

	.INCLUDE	"GXENEMY.INC"			;SYSTEM EQUATES
	.INCLUDE	"IMGTBL.GLO"
	.INCLUDE	"GXCONTRL.H"
	.INCLUDE	"GXMONDOR.H"
	.INCLUDE	"GXSTRING.H"
	.INCLUDE	"GXS.H"
	.INCLUDE	"GXMONDOR.TBL"

*
*Symbols from Mondor himself
*
	.DEF MONDOR_INIT, NUM_HEAD, MAKE_MONDOR_SCREAM, MONDOR_TOTAL
	.DEF A_GET_SHAD_MULTI
	.DEF ANIM_MORPH_FINISH, MONDOR_MORPH_FLAG, SND_WALK_XITION
	.DEF	C_GREEN_STRTANIM, A_GREEN_IF_NEC

*
*Symbols from around the GLOBE
*

***** from GX.ASM
	.REF	WAVE_END_IMM

***** from GXRAM.ASM
	.REF ENEMY_QUOTA, GAME_STATE, SOUNDSUP, CURPLYRS, GUNS_OFF
	.REF	BONUS_DIRECTION, NPLAYERS, P1DATA, VIOLENCE_LEVEL

***** from GXAFUNC.ASM
	.REF A_Anim_DSJ, A_PreFrag_Box, A_PreFrag_Center, A_INIT_AnimSLP
	.REF A_Set_AnimLoop, SetAnim, A_SET_OZVEL, A_CREATEP, A_PreFrag_Rain
	.REF A_Set_Rel_Byte_Head, A_SOUND, A_SOUNDZ, A_RAND_SOUNDZ
	.REF A_Set_Var_Word, A_Set_Rel_Word, A_Set_Rel_Word_Head
	.REF A_OBJ_OFF_CHANGE_PAL

***** from GXSND.ASM
	.REF ONESND_Z, ONESND, SND_BGND1_OFF, SND_BGND2_OFF, IS_SOUND
	.REF	SND_CHAN0_OFF

***** from GXD.ASM
	.REF SETOFFPU, XBASE, ZBASE
	.REF SET_ANIPXU, SET_ANIPZU, SET_OBJSU, EASYMAKE, GET_SHAD_MULTI

***** from GXUTIL.ASM
	.REF SET_VECTORS, PASTE_ON_DAMAGE

***** from GXPALL.ASM
	.REF A_CHANGE_PAL

***** from GXPLAYER.ASM
	.REF ANY_BOMBS

***** from GXCOG.asm
	.REF HIT_ENEMY

***** from GXMONDR2.ASM
	.REF FRAG_EXPLOSION, BLOODY_BULLET_HIT, FRAG_GUN_FLY
	.REF A_JEANS_CHUNK, A_RANDOM_MULTI_CHUNK, A_SHIRT_CHUNK
	.REF FRAG_FINAL_EXPLOSION, FIRE_BALL_INIT, A_SPAWN_PROJECTILE
	.REF GRENADE_INIT, BLOW_PART, PROC_SKY_FLASH, A_DELETE_MONDOR
	.REF A_VELOCITY_WATCH, A_MOVE_AROUND, FRAG_EXPLOSION_SMALL
	.REF TALK_SCRIPTS, FRAG_FINAL_RAIN
	.REF A_SPAWN_BLOOD, A_RAND_SPAWN_BLOOD, SPAWN_BLOOD
	.REF A_ARM_FIRE_FNC, A_INIT_BLOOD_DROP, MONDOR_PROC
	.REF INIT_POD_FIRE, ANIM_JOSH_MORPH, MCHUNK_COLL
	.REF	F_GUN_CHUNK, A_CHUNK_ONSCREEN, FRAG_EXPLOSION_ONE

***** from GXDESK.ASM
	.REF ANIM_SMALL_SHAKE, ANIM_MEDIUM_SHAKE, ANIM_BIG_SHAKE
	.REF SPAWN_FIRE, DGV_FRAG_SPARK, TAB_METAL_SOUNDS
	.REF SNUM_NIGHTMARE

***** from GXUNIJAP.ASM
	.REF NO_CHARITY

***** from GXUNIJP2.ASM
	.REF METAL_GUNVECT

***** from GXHELGA.ASM
	.REF	PROC_THRONE_HELGA

***** from GXSCROLL.ASM
	.REF	SCROLL_FLAG

*
*MONDOR RAM
*
	.BSS	MONDOR_TOTAL,16		;Set if Mondor was totally destroyed.
	.BSS	MONDOR_MORPH_FLAG,16	;Set after Mondor morphs
	.BSS	DO_AERO_ENDING,16	;Set if the player achieved the goal
	.BSS	UNUSED_WORD,16		;Place holder

*Grenade through equates
Z_THROW_LIMIT	.EQU	0B000H	;Mondor cannot be closer than this
Y_THROW_LIMIT	.EQU	-18H	;Mondor cannot be higher that this
X_THROW_LIMIT	.EQU	50H	;Mondor cannot be over farther than this

	.TEXT

**************************************************************************
*								         *
* 	C_MONDOR_PART_INIT						 *
* 									 *
* 	Create Func to be run on all active Mondor objects.		 *
*								         *
**************************************************************************
C_MONDOR_PART_INIT
	MOVIM	MONDOR_FLASH_COLOR,*A0(OCONST),W
	RETS

**************************************************************************
*								         *
* 	C_SEAT_INIT							 *
* 									 *
* 	Create func for the seat.					 *
*								         *
**************************************************************************
C_SEAT_INIT
	MOVIM	180000H,*A0(OGRNDOFF),L
	JRUC	C_CRAFT_PART_INIT

**************************************************************************
*								         *
* 	C_CRAFT_PART_INIT						 *
* 									 *
* 	Create Func to be run on all active Craft objects.		 *
*								         *
**************************************************************************
C_CRAFT_PART_INIT
	MOVIM	CRAFT_FLASH_COLOR,*A0(OCONST),W
	RETS

**************************************************************************
*								         *
* 	C_PLATE_PART_INIT						 *
* 									 *
* 	Create Func to be run on the license plate object.		 *
*								         *
**************************************************************************
C_PLATE_PART_INIT
	MOVIM	0101H,*A0(OCONST),W
	RETS

**************************************************************************
*								         *
* 	DEFAULT_SCREAM							 *
* 									 *
* 	Make the default mondor scream.					 *
* 									 *
* 	A3 = Scream direction 1 = straight, 2 = left, 3 = right		 *
* 	A6 = Index into scream table.  If 0 then random damage sound.	 *
*								         *
**************************************************************************
DEFAULT_SCREAM
	MMTM	SP,A0,A4,A5,A6
	MOVE	A6,A6			;Is this a severe scream?
	JRZ	DS_NORMAL		;BR = No, just a normal one
	DEC	A6
	MOVE	A6,A14
	SLL	5,A6
	SLL	4,A14
	ADDI	SCREAM_TAB,A6
	ADD	A14,A6
	MOVE	*A6+,A4,L		;Get a severe scream going
	MOVE	*A6,A5,W		;Get the duration
	CLR	A6
	JRUC	DS_DOIT
DS_NORMAL
	RANDENT	TAB_DAMAGE_SOUNDS,NUM_DAMAGE_SNDS,5,L
	MOVE	A0,A4
DS_DOIT
	MOVK	15,A5
	CALLR	MAKE_MONDOR_SCREAM
	MMFM	SP,A0,A4,A5,A6
	RETS

SCREAM_TAB
	.LONG	SND_SCREAM
	.WORD	50
	.LONG	SND_BLOW_BACK
	.WORD	25

**************************************************************************
*								         *
* 	MAKE_MONDOR_SCREAM						 *
* 									 *
* 	Routine to make Mondor scream, if he isn't screaming already.	 *
* 									 *
* 	A3 = Scream direction 1 = straight, 2 = left, 3 = right		 *
* 	A4 = Scream sound script					 *
* 	A5 = Scream duration						 *
* 	A6 = Scream severity						 *
*								         *
**************************************************************************
MAKE_MONDOR_SCREAM
	MMTM	SP,A0,A1

	MOVK	NUM_HEAD,A1
	CALLA	FINDPART		;The head shall scream
	JRZ	MMS_X			;BR = Couldn't find the part

	MOVB	A3,*A0(OSCREAM)
	MOVE	A4,*A0(OSCREAM_SND),L
	MOVB	A5,*A0(OSCREAM_DUR)
	MOVB	A6,*A0(OSCREAM_SEV)
MMS_X
	MMFM	SP,A0,A1
	RETS

**************************************************************************
*								         *
* 	A_LOAD_ANIMATION						 *
* 									 *
* 	Anim Func to load a given animation based on the parts		 *
* 	current damage level.						 *
* 									 *
* 	*AARG+,L = Table of animations					 *
* 									 *
* 	LOAD_ANIMATION							 *
* 									 *
* 	Entrypoint to load a given animation, assumes that the		 *
* 	part is currently animating.					 *
* 									 *
* 	A1 = Table of animations					 *
* 									 *
* 	Returns								 *
* 		A1 = Animation script loaded				 *
*								         *
**************************************************************************
A_LOAD_ANIMATION
	CALLA	GETAFARG_LONG
	MOVE	A0,A1
LOAD_ANIMATION
	MOVB	*A8(ODAMAGE),A14
	SLL	29,A14			;There are only four levels
	SRL	24,A14			;and this is protection
	ADD	A14,A1
	MOVE	*A1,A1,L
	JAUC	STRT_ANIM

**************************************************************************
*								         *
* 	A_SELECT_ARM_IDLE_TIME						 *
* 									 *
* 	Anim Func to select idle time for an arm.			 *
* 	Time is placed in the AnimSLP field of the arm object.		 *
*								         *
**************************************************************************
A_SELECT_ARM_IDLE_TIME
	MOVK	5,A0
	MOVI	20,A1
	CALLA	RANGERND
	MOVB	A0,*A8(AnimSLP)
	RETS


**************************************************************************
*								         *
* 	A_ARM_DECISION							 *
* 									 *
* 	Anim Func to make decisions for an arm.				 *
* 									 *
* 	AARG+,W = Number of animation we are coming from.		 *
*								         *
**************************************************************************
A_ARM_DECISION
	CALLA	GET_HEAD_PART_A0
	MOVE	A0,A7			;Head ptr to stay here for duration

	CLRB	*A7(OTHROWING_BOMB)	;Clear this every time for safety

	CALLA	GETAFARG_WORD
	JRZ	ALD_RETURN_FROM_IDLE	;BR = We just returned from idle

	MOVB	A0,*A8(OLASTANUM)	;Store where we just came from
ALD_DO_IDLE
	MOVI	ANIM_ARM_IDLE,A1	;and run the idle sequence before
	JRUC	LOAD_ANIMATION		;we continue.

ALD_RETURN_FROM_IDLE
	MOVB	*A7(OFDAM_GOING),A14	;If damage show going then no arm action
	JRNZ	ALD_DO_IDLE		;BR = It is, so don't

	MOVB	*A7(OSPITTING_FIRE),A14	;Are FireBalls going?
	JRNZ	ALD_CK_SHAKE		;Then no throwing

	MOVE	A7,B14
	ADDI	OXVAL,B14
	MMFM	B14,B0,B1,B3	;LOAD B3:OXPOS, B1:OYPOS, B0:OZPOS

	MOVI	XBASE,B14
	MMFM	B14,B2,B4,B5	;LOAD B5:XBASE, B4:YBASE, B2:ZBASE

	SUB	B5,B3	       	;Universe to World X  
	ADD	B4,B1	       	;Universe to World Y  
	SUB	B2,B0		;Universe to World Z

	ABS	B3

	CMPI	Z_THROW_LIMIT,B0	;Is he too close?
	JRLT	ALD_CK_SHAKE		;BR = Yes

	SRA	16,B1
	CMPI	Y_THROW_LIMIT,B1	;Is he too high?
	JRLT	ALD_CK_SHAKE		;BR = Yes

	SRA	16,B3
	CMPI	X_THROW_LIMIT,B3	;Is he too close to the edge?
	JRGT	ALD_CK_SHAKE

;	MOVI	800,A0	   		;He has a good chance of Grenading
;	CALLA	RANDPER			;How good?
;	JRNC	ALD_CK_SHAKE		;BR = Not good enough

	CLRB	*A8(ONO_GET)		;Allow gun grab after this

	MOVI	ANIM_ARM_THROW,A1
	JRUC	ALD_DO_ACTION

ALD_CK_SHAKE
	MOVB	*A7(OSHAKE_FIST),A14
	JRNZ	AAD_SHAKE_IT

	MOVB	*A8(ONO_GET),A14	;Are we allowed to grab the gun
	JRNZ	ALD_DO_RAND_ACTION	;BR = No

	MOVI	800,A0	   		;Chance that we might pull gun
	CALLA	RANDPER
	JRNC	ALD_DO_RAND_ACTION	;BR = Just do a random arm action

	MOVI	ANIM_ARM_GET,A1		;Johnny get your gun
	JRUC	ALD_DO_ACTION

ALD_DO_RAND_ACTION
	MOVE	*A7(OARM_WAIT),A14,W	;Do we have to wait before another?
	JRNZ	ALD_DO_IDLE		;BR = Yes

	MOVK	NUM_ARM_ACTIONS,A0	;Do a little arm swinging
	CALLA	RAND0

	SLL	3,A0
	ADDI	ARM_TABLE,A0
	MOVB	*A0,A0
	SLL	5,A0
	ADDI	ACTIONS_ARM,A0
	MOVE	*A0,A1,L

	MOVIM	240,*A7(OARM_WAIT),W	;Make-a-Mondor wait before more

ALD_DO_ACTION
	JRUC	LOAD_ANIMATION

AAD_SHAKE_IT
	MOVI	ANIM_ARM_FIST,A1
	JRUC	LOAD_ANIMATION


NUM_ARM_ACTIONS	.EQU	3
ALL_ARM_BITS	.EQU	07H		;Must equal (2^NUM_ARM_ACTIONS) - 1

ARM_TABLE
	.BYTE	ANUM_666, ANUM_FIST, ANUM_PNT
	.EVEN

**************************************************************************
*								         *
* 	A_POINT_CHECK							 *
* 									 *
* 	Anim Func to see if it is O.K. to point.  If not, we'll just	 *
* 	jump into the arm decision code.				 *
* 									 *
* 	A8 = Ptr to arm							 *
*								         *
**************************************************************************
A_POINT_CHECK
	MOVB	*A8(ODAMAGE),A14	;Is there any damage?
	JRZ	APC_X			;BR = No, it's O.K. to point.
	MOVKB	ANUM_PNT,*A8(OLASTANUM)
	JRUC	ALD_RETURN_FROM_IDLE
APC_X
	RETS

**************************************************************************
*								         *
* 	A_SELECT_HEAD_IDLE_TIME						 *
* 									 *
* 	Anim Func to select idle time for the head.			 *
* 	Time is placed in the AnimSLP field of the head object.		 *
*								         *
**************************************************************************
A_SELECT_HEAD_IDLE_TIME
	MOVK	1,A0
	MOVI	60,A1
	CALLA	RANGERND
	MOVB	A0,*A8(OHEAD_IDLE)
	RETS

**************************************************************************
*								         *
* 	A_HEAD_DECISION							 *
* 									 *
* 	Anim Func to make decisions for the head.			 *
* 									 *
* 	AARG+,W = Number of animation we are coming from.		 *
*								         *
**************************************************************************
A_HEAD_DECISION
	CALLA	GET_HEAD_PART_A0
	MOVE	A0,A7			;Head-part stays in A7 for this func

	CLRB	*A7(OSPITTING_FIRE)	;Clear the fire blow flag for safety

	CALLA	GETAFARG_WORD

	MOVE	A0,A5
	JRZ	AHD_RETURN_FROM_IDLE	;BR = We just returned from idle
	
	CMPK	ANUM_SCREAM_LT,A5
	JREQ	AHD_RETURN_FROM_SCREAM
	CMPK	ANUM_SCREAM_RT,A5
	JRNE	AHD_CHECK_NEXT

AHD_RETURN_FROM_SCREAM
	MOVI	750,A0
	CALLA	RANDPER			;Should we shake our heads?
	JRNC	AHD_CHECK_NEXT		;BR = No

	MOVI	ANIM_HEAD_SHAKE,A1
	JRUC	LOAD_ANIMATION

AHD_CHECK_NEXT
	CMPK	ANUM_SHAKE,A5		;Are we returning from a shake-off?
	JREQ	AHD_SCREAM_CLR		;BR = Yes, try to clear the scream

	CMPK	ANUM_BREATHE_FIRE,A5
	JRNE	AHD_CK_NXT2

AHD_SCREAM_CLR
	MOVB	*A8(OSCREAM_SEV),A14	;Are we pending on a severe scream?
	JRNZ	AHD_CK_NXT2		;BR = Yes, don't clear

	CLRB	*A8(OSCREAM)		;No screaming after FireBall

AHD_CK_NXT2

	MOVB	A5,*A8(OLASTANUM)	;Store where we just came from
	MOVI	ANIM_HEAD_IDLE,A1	;and run the idle sequence before
	JRUC	LOAD_ANIMATION		;we continue.

AHD_RETURN_FROM_IDLE

*Check to see if we should scream
	MOVB	*A8(OSCREAM),A0
	JRZ	AHD_NO_SCREAM

*A0 = OSCREAM value
*A7 Is NOT guaranteed to be the ptr to the head-part here
MONDOR_SCREAM_IMM
	MOVB	*A8(OSCREAM_SEV),*A8(OCUR_SCREAM_SEV)
	CLR	A14
	MOVB	A14,*A8(OSCREAM)
	MOVB	A14,*A8(OSCREAM_SEV)
	MOVB	A14,*A8(OTALK_FLAG)

;	MOVB	*A8(OSCREAM_DUR),*A8(AnimSLP)
	MOVB	*A8(OSCREAM_DUR),*A8(AnimLoop)

	DEC	A0
	SLL	5,A0
	ADDI	SCREAM_TABLE,A0
	JRUC	AHD_LOAD_IT

AHD_NO_SCREAM
*Check to see if all player's have left the game
	MOVE	@GAME_STATE,A14,W
	CMPI	INGAMEOV,A14		;Did we land in game over?
	JRNZ	AHD_GAME_ON		;BR = No

	MOVB	*A8(OMOMMY_FLAG),A14	;Did we already say this?
	JRNZ	AHD_GAME_ON		;BR = Yes

	SOUNDON

	MOVKB	TNUM_MOMMY,*A8(OTALK_FLAG)
	MOVB	A14,*A8(OMOMMY_FLAG)

AHD_GAME_ON
*Check to see if it's time to talk at the player
	MOVB	*A8(OTALK_FLAG),A0	
	JRZ	AHD_NO_TALK		;BR = No talking now
	
	CMPK	TNUM_DONE,A0		;Is this the you are done message?
	JRNE	AHD_TALK_CK2		;BR = No

	MOVE	@CURPLYRS,A1,W		;Check out how many are playing
	MOVB	*A8(ONUM_DONE),A14	;Number when we were to talk
	CMP	A14,A1			;Is the player still missing?
	JRLS	AHD_TALK_CK2		;BR = Yes, then still say it
	
	CLRB	*A8(OTALK_FLAG)		;Otherwise kill this phrase
	JRUC	AHD_NO_TALK

AHD_TALK_CK2
	DEC	A0
	SLL	5,A0
	ADDI	TALK_SCRIPTS,A0		

	MOVE	*A0,A0,L		;Grab the proper script

	MOVB	*A0(0),*A8(AnimLoop)	;First byte is syllable count
	ADDK	8,A0
	MOVB	*A0(0),*A8(AnimSLP)	;Load the pause before talking time
	ADDK	8,A0
	MOVE	A0,*A8(OTALK_SCRIPT),L	;Save the script ptr for next frame

	MOVIM	450,*A7(OTALK_WAIT),W	;Make-a-Mondor wait before casual conversation

	MOVI	ANIM_TALK,A1   		;One talk animation does it all!
	JRUC	LOAD_ANIMATION

AHD_NO_TALK

*Check to see if we should look at the missing gun
	MOVB	*A8(OGUN_BLOWN),A1
	JRZ	AHD_NO_GUN_REACT

	CLR	A14
	MOVB	A14,*A8(OGUN_BLOWN)

	CMPK	NUM_ARML,A1
	JRNE	AHD_LOOK_RIGHT

	MOVI	ANIM_HEAD_LOOK_LEFT,A1
	JRUC	LOAD_ANIMATION
AHD_LOOK_RIGHT
	MOVI	ANIM_HEAD_LOOK_RIGHT,A1
	JRUC	LOAD_ANIMATION

AHD_NO_GUN_REACT
	MOVB	*A8(OHEAD_IDLE),A14
	DEC	A14
	MOVB	A14,*A8(OHEAD_IDLE)
	JRZ	AHD_IDLE_DONE

	RETS

AHD_IDLE_DONE
	MOVB	*A7(OFDAM_GOING),A14	;If damage show going then no fire
	JRNZ	AHD_DO_IDLE		;BR = It is, so don't

	MOVE	*A8(OFB_PERC),A0,W
	CALLA	RANDPER			;Should we idle
	JRNC	AHD_DO_ACTION		;BR = No

*Mondor will idle is head here

AHD_DO_IDLE
	MOVE	@CURPLYRS,A0,W		;Check out how many are playing
	MOVB	*A8(OLAST_CURPLYRS),A14
	CMP	A14,A0			;Same as last time we checked?
	JREQ	AHD_SAME_PLAYERS	;BR = Yes
	MOVB	A0,*A8(OLAST_CURPLYRS)	;Save this new player count
	JRGT	AHD_MORE_PLAYERS	;BR = There's more now

	MOVB	A0,*A8(ONUM_DONE)	;This was the number when you were supposed to say it
	MOVI	TNUM_DONE,A6		;Now there are less	
	JRUC	AHD_DO_TALK		;Tell them so
AHD_MORE_PLAYERS

AHD_SAME_PLAYERS
	MOVE	*A7(OTALK_WAIT),A14	;Can we talk now?
	JRNZ	AHD_IDLE_IT_IS		;BR = No, just idle

	MOVB	*A7(OFDAM_GOING),A14	;No random babbling during big damage
	JRNZ	AHD_IDLE_IT_IS

	MOVK	8,A5
	MOVE	*A8(OBABBLE_BITS),A6,W

AHD_TRY_BABBLE_AGAIN
	MOVK	NUM_BABBLINGS,A0	;Do a little babbling
	CALLA	RAND0

	BTST	A0,A6			;Have we babbled this yet?
	JRZ	AHD_BABBLE_OK		;BR = No

	DSJS	A5,AHD_TRY_BABBLE_AGAIN
*Here we have failed to randomly babble, we'll just select
	MOVK	NUM_BABBLINGS,A5
	CLR	A0			;Walk down babble list until we get one
AHD_WALK_BABBLE
	BTST	A0,A6			;Is this a good one?
	JRZ	AHD_BABBLE_OK		;BR = Yes, then use it
	INC	A0			;Next
	DSJS	A5,AHD_WALK_BABBLE
	JRUC	AHD_IDLE_IT_IS		;BR = Error, no babbles left

AHD_BABBLE_OK
	BSET	A0,A6			;Flag this as babbled

	SLL	32-NUM_BABBLINGS,A6
	SRL	32-NUM_BABBLINGS,A6	;Strip the high stuff, if there is any
	CMPI	ALL_BABBLE_BITS,A6	;Is that all of the phrases?
	JRNE	AHD_STORE_BABBLE	;BR = No

	CLR	A6			;Reset babble counter

AHD_STORE_BABBLE
	MOVE	A6,*A8(OBABBLE_BITS),W

	SLL	3,A0
	ADDI	BABBLE_TABLE,A0
	MOVB	*A0,A6
AHD_DO_TALK
	MOVB	A6,*A8(OTALK_FLAG)

AHD_IDLE_IT_IS
	MOVI	ANIM_HEAD_IDLE,A1
	JRUC	LOAD_ANIMATION

*Mondor will do some action with his head here

AHD_DO_ACTION
	MOVE	*A8(OZVAL),A0,L
	MOVE	@ZBASE,A2,L
	SUB	A2,A0			;Universe to World Z

	MOVB	*A7(OARMS_GONE),A14	;If both arms are missing, get ruthless
	CMPK	2,A14			;Are they both gone?
	JRLO	AHD_STILL_HAS_ARMS	;BR = No

	CMPI	MIN_FIRE_Z_2,A0		;Let Mondor fire at a closer Z
	JRUC	AHD_DO_FB_BRA		;Wait one mach cycle and we'll find out

AHD_STILL_HAS_ARMS
	CMPI	MIN_FIRE_Z,A0		;Is Mondor too close to fire?
AHD_DO_FB_BRA
	JRLT	AHD_DO_IDLE		;BR = Yes

	MOVB	*A7(OTHROWING_BOMB),A14	;Is he throwing a bomb?
	JRNZ	AHD_DO_IDLE		;BR = Yes, then no FireBalls

*Mondor is going to send a FireBall, the only ? is, how many?

	MOVE	*A7(OXVEL+16),A14,W
	ABS	A14		   	;Is he jaunting sideways?
	CMPK	4,A14			
	JRHS	AHD_FIRE_MULTI_BALLS	;BR = Yes, so fire a few

	MOVB	*A7(OARMS_GONE),A14	;If both arms are missing, get ruthless
	CMPK	2,A14			;Are they both gone?
;	JRLO	AHD_FOB_ONE		;BR = No, so fire one and only one
	JRHS	AHD_FIRE_MULTI_BALLS	;BR = Yes, so always fire multiple

;	MOVI	512,A0			;1 in 2 when just head is left
;	CALLA	RANDPER
;	JRC	AHD_FIRE_MULTI_BALLS	;BR = Lucky bastard

AHD_FOB_ONE
	MOVK	1,A4
;AHD_NO_SPEAK
;	CLR	A6
AHD_STUFF_FB_CNT
	MOVB	A4,*A8(AnimLoop)
;	MOVB	A6,*A8(OTALK_FLAG)

	MOVI	ANIM_HEAD_BREATH_FIRE,A1
	JRUC	LOAD_ANIMATION

*He's going to fire more than one here
AHD_FIRE_MULTI_BALLS
	MOVE	*A7(ONOARM_TIME),A14,W
	CMPI	NOARMS_PISSED,A14	;Has it been a while with no arms?
	JRLO	AHD_RAND_MULTI_BALLS	;BR = No
	MOVK	8,A0			;Fire five all the time after a min.
	JRUC	AHD_DO_RAND_MULTI
AHD_RAND_MULTI_BALLS
	MOVK	5,A0
AHD_DO_RAND_MULTI
	CALLA	RANDU			;Pick Random amount
	MOVE	A0,A4
;	CMPK	3,A4			;Is it enough to merit talking?
;	JRLO	AHD_NO_SPEAK		;BR = No
	JRUC	AHD_STUFF_FB_CNT

;	MOVK	NUM_TAUNTS,A0		;Do a little taunting
;	CALLA	RAND0
;	SLL	3,A0
;	ADDI	TAUNT_TABLE,A0
;	MOVB	*A0,A6
;	JRUC	AHD_STUFF_FB_CNT

AHD_LOAD_IT
	MOVE	*A0,A1,L
	JRUC	LOAD_ANIMATION

NUM_TAUNTS	.EQU	3

TAUNT_TABLE
	.BYTE	TNUM_TAKE, TNUM_BOOM, TNUM_LAUGH
	.EVEN

NUM_BABBLINGS	.EQU	9
ALL_BABBLE_BITS .EQU	01FFH		;Must equal (2^NUM_BABBLINGS)-1

BABBLE_TABLE
	.BYTE	TNUM_LAUGH, TNUM_CMON, TNUM_PRAY, TNUM_NIGHT
	.BYTE	TNUM_DEVOUR, TNUM_GUTS, TNUM_COWARD, TNUM_MONDOR
	.BYTE	TNUM_NOTHING
	.EVEN

**************************************************************************
*								         *
* 	A_INITIALIZE_FIRING						 *
* 									 *
* 	Anim Func to any variable initialization that might be		 *
* 	necessary.							 *
* 									 *
* 	A8 = Ptr to part doing the firing.				 *
*								         *
**************************************************************************
A_INITIALIZE_FIRING
	CLR	A14
	MOVB	A14,*A8(OMISSES)
	MOVB	A14,*A8(OSHOTS_TAKEN)
	MOVKB	1,*A8(OGUN_IN_HAND)
	RETS

**************************************************************************
*								         *
* 	A_CLR_GUN_FLAG							 *
* 									 *
* 	Anim Func to clear the flag that says this hand holds a gun.	 *
* 									 *
* 	A8 = Ptr to part that can hold a gun.				 *
*								         *
**************************************************************************
;A_CLR_GUN_FLAG
;	CLR	A14
;	MOVB	A14,*A8(OGUN_IN_HAND)
;	RETS

**************************************************************************
*								         *
* 	A_RANDOM_BURST_COUNT						 *
* 									 *
* 	Anim Func to load a random Burst count.				 *
* 									 *
* 	A8 = Ptr to part doing the firing				 *
*								         *
**************************************************************************
;A_RANDOM_BURST_COUNT
;	MOVK	2,A0
;	MOVK	6,A1
;	CALLA	RANGERND
;	MOVB	A0,*A8(OBURSTCNT)
;	RETS

**************************************************************************
*								         *
* 	A_RANDOM_RAPID_COUNT						 *
* 									 *
* 	Anim Func to load a random Rapid Fire count.			 *
* 									 *
* 	A8 = Ptr to part doing the firing				 *
*								         *
**************************************************************************
A_RANDOM_RAPID_COUNT
	MOVK	2,A0
	MOVK	6,A1
	CALLA	RANGERND
	MOVB	A0,*A8(ORAPIDCNT)
	RETS

**************************************************************************
*								         *
* 	A_ARM_BURST_DECISION						 *
* 									 *
* 	Anim Func to decide if we should fire another burst.		 *
* 									 *
* 	A8 = Ptr to arm part firing					 *
* 	AARG+,L	= Anim branch if the need arises to burst again.	 *
*								         *
**************************************************************************
;A_ARM_BURST_DECISION
;	MOVB	*A8(OBURSTCNT),A14
;	DEC	A14
;	MOVB	A14,*A8(OBURSTCNT)
;	JRNZ	AABD_BRANCH
;	RETS
;AABD_BRANCH
;	CALLA	GETAFARG_LONG
;	MOVE	A0,A1
;	JAUC	SetAnim

**************************************************************************
*								         *
* 	A_ARM_RAPIDFIRE_DECISION					 *
* 									 *
* 	Anim Func to decide if we should quickly fire again.		 *
* 									 *
* 	A8 = Ptr to arm part firing					 *
* 	AARG+,L	= Anim branch if the need arises to fire again.		 *
*								         *
**************************************************************************
A_ARM_RAPIDFIRE_DECISION
	MOVB	*A8(ORAPIDCNT),A14
	DEC	A14
	MOVB	A14,*A8(ORAPIDCNT)
	JRNZ	AARD_BRANCH
	RETS
AARD_BRANCH
	CALLA	GETAFARG_LONG
	MOVE	A0,A1
	JAUC	SetAnim


**************************************************************************
*								         *
* 	A_CHEST_DAMAGE							 *
* 									 *
* 	Anim Func to intialize a chest damage piece.			 *
* 									 *
* 	A8 = Ptr to the piece						 *
*								         *
**************************************************************************
A_INIT_CHEST_DAMAGE
	MOVKB	MAX_DAMAGE_LEVEL,*A8(ODAMAGE)
	MOVIM	DUMRETS,*A8(OGUNVECT),L
	JAUC	OBJ_ON

**************************************************************************
*								         *
* 	A_TORSO_DAMAGE							 *
* 									 *
* 	Anim Func to select animations based on the ODAMAGE field.	 *
* 	If ODAMAGE = 1 then fall through				 *
* 		   = 2 then take Branch #1				 *
* 		   = 3 then take Branch #2				 *
* 									 *
* 	A8 = Ptr to torso object					 *
* 	AARG+,L = Branch #1						 *
* 	AARG+,L = Branch #2						 *
*								         *
**************************************************************************
A_TORSO_DAMAGE
	MOVB	*A8(ODAMAGE),A6
	DEC	A6
	JRLE	ATD_X			;BR = Fall through, no branch
	CALLA	GETAFARG_LONG
	CMPK	1,A6			;Take branch 1 or 2?
	JRNE	ATD_2			;BR = Take 2
	MOVE	A0,A1
	JAUC	SetAnim
ATD_2
	CALLA	GETAFARG_LONG
	MOVE	A0,A1
	JAUC	SetAnim
ATD_X
	RETS
	
**************************************************************************
*								         *
* 	A_THRUSTERL_INIT						 *
* 									 *
* 	Anim Func to initialize the left thruster.			 *
* 									 *
* 	A8 = ptr to the left thruster					 *
*								         *
**************************************************************************
A_THRUSTERL_INIT
	MOVIM	SND_THRUSTER1,*A8(OTHRUSTER_SND),L
	MOVIM	SND_BGND1_OFF,*A8(OTHRUSTER_SNDOFF),L
	RETS

**************************************************************************
*								         *
* 	A_THRUSTERR_INIT						 *
* 									 *
* 	Anim Func to initialize the right thruster.			 *
* 									 *
* 	A8 = ptr to the right thruster					 *
*								         *
**************************************************************************
A_THRUSTERR_INIT
	MOVIM	SND_THRUSTER2,*A8(OTHRUSTER_SND),L
	MOVIM	SND_BGND2_OFF,*A8(OTHRUSTER_SNDOFF),L
	RETS

**************************************************************************
*								         *
* 	A_THRUSTER_CHECK_x						 *
* 									 *
* 	Anim Func to check if a thruster should fire up.		 *
* 	x = L or R for left or right thruster.				 *
* 									 *
* 	A8 = Ptr to thruster						 *
*								         *
**************************************************************************
A_THRUSTER_CHECK_L
	CALLA	GET_HEAD_PART_A0
	CLR	A7
	MOVE	*A0(OXACCEL),A4,W
	JRLE	ATC_ZTHRUST
	JRUC	ATC_XBURN

A_THRUSTER_CHECK_R
	CALLA	GET_HEAD_PART_A0
	CLR	A7
	MOVE	*A0(OXACCEL),A4,W
	JRGE	ATC_ZTHRUST
ATC_XBURN
	ABS	A4
	CMPI	SLED_XYACCEL,A4
	JRLO	ATC_ZTHRUST
	MOVB	*A0(OXBURN),A7

ATC_ZTHRUST
	MOVE	*A0(OZACCEL),A14,W
	JRZ	ATC_FIRE
	ABS	A14
	CMPI	SLED_ZACCEL,A14
	JRLO	ATC_FIRE

	MOVB	*A0(OZBURN),A14
	ADD	A14,A7
ATC_FIRE
	SLL	1,A7
	JRZ	ATC_X
	MOVB	A7,*A8(AnimLoop)
	MOVIM	ANIM_THRUSTER_FIRE,*A8(AnimFrm),L
	CLRB	*A8(AnimSlp)
	MOVE	*A8(OTHRUSTER_SND),A0,L
	JRZ	ATC_X
	JAUC	ONESND_Z
ATC_X
	RETS


**************************************************************************
*								         *
* 	A_THRUSTER_LOOP							 *
* 									 *
* 	Anim func to loop the thruster fire animation.			 *
* 									 *
* 	A8 = Ptr to thruster						 *
*								         *
**************************************************************************
A_THRUSTER_LOOP
	MOVB	*A8(AnimLoop),A14
	DEC	A14
	MOVB	A14,*A8(AnimLoop)
	JRLE	ATL_FALLOUT
	MOVIM	ANIM_THRUSTER_FIRE,*A8(AnimFrm),L
	RETS

ATL_FALLOUT
	MOVE	*A8(OTHRUSTER_SNDOFF),A0,L
	JRZ	ATL_X
	JAUC	ONESND
ATL_X		
	RETS

**************************************************************************
*								         *
* 	A_POUND_FUNC							 *
* 									 *
* 	Anim Func for pounding reaction.				 *
*								         *
**************************************************************************
A_POUND_FUNC
	MOVE	A8,A5
	CALLA	GET_HEAD_PART
	MOVI	28000H,A0
	CALLA	RANDU
	ADDI	8000H,A0
	ADDRM	A0,*A8(OYVEL),L
	SOUNDZ	SND_POUND
	MOVE	A5,A8
	MOVB	*A8(AnimLoop),A14
	DEC	A14
	MOVB	A14,*A8(AnimLoop)
	JRZ	APF_X
     	MOVE	*A8(AnimScr),*A8(AnimFrm),L
APF_X
	RETS

**************************************************************************
*								         *
* 	A_LOSE_GUN_IFNECC						 *
* 									 *
* 	Anim Func to let the gun fly off of Mondor's hand, if		 *
* 	he has one.							 *
* 									 *
* 	A8 = Ptr to arm part						 *
*								         *
**************************************************************************
A_LOSE_GUN_IFNECC
	MOVB	*A8(OGUN_IN_HAND),A14
	JRZ	ALGI_X

	MOVI	80H,A3			;Max Z velocity
	MOVI	20000H,A0		;Max X&Y velocities
	CALLA	PreFrag_Center		;Blow from the center
	MOVI	FRAG_GUN_FLY,B14	;Use this script
	JAUC	Fragger			;And get it goin' Boy
ALGI_X
	RETS

**************************************************************************
*								         *
* 	A_LOSE_GLASSES_IFNECC						 *
* 									 *
* 	Anim Func to let the glasses fly off of Mondor's head, if	 *
* 	he has them.							 *
* 									 *
* 	A8 = Ptr to head part						 *
*								         *
**************************************************************************
A_LOSE_GLASSES_IFNECC
	MOVE	*A8(OPARTS),A0,L
	MOVE	*A0(OFLAGS),A14,W
	BTST	B_NODISP,A14
	JRNZ	ALGLI_X

	ORI	M_NODISP,A14
	MOVE	A14,*A0(OFLAGS),W

	MOVI	80H,A3			;Max Z velocity
	MOVI	20000H,A0		;Max X&Y velocities
	CALLA	PreFrag_Center		;Blow from the center
	MOVI	FRAG_GLASSES_FLY,B14	;Use this script
	JAUC	Fragger			;And get it goin' Boy

ALGLI_X
	RETS

**************************************************************************
*								         *
* 	A_CLR_OGUN_BLOWN						 *
* 									 *
* 	Anim Func to set the OGUN_BLOWN flag.				 *
*								         *
**************************************************************************
A_CLR_OGUN_BLOWN
	MOVK	NUM_HEAD,A1
	CALLA	FINDPART
	JRZ	ACOB_X
	CLR	A14
	MOVB	A14,*A0(OGUN_BLOWN)
ACOB_X
	RETS


**************************************************************************
*								         *
* 	A_TURN_ON_ARM_STUMP						 *
* 									 *
* 	Anim Func to fire up the arm bone stump.			 *
* 	And increment OARMS_GONE in the head-part.			 *
* 									 *
* 	A8 = Ptr to arm part that just stumped.				 *
*								         *
**************************************************************************
A_TURN_ON_ARM_STUMP
	CALLA	GET_HEAD_PART_A0
	INCB	*A0(OARMS_GONE)
	CLRB	*A0(OTHROWING_BOMB)

	MOVB	*A8(OPARTID),A1
	ADDK	NUM_ABONEL-NUM_ARML,A1
	CALLA	FINDPART
	JRZ	ATOAS_X

	CALLA	OBJON
	MOVI	ANIM_ARM_STUMP,A1
	JAUC	STRTANIM

ATOAS_X
	RETS

**************************************************************************
*								         *
* 	A_BLOW_PART							 *
* 									 *
* 	Anim func to call function in OPART_BLOW_FUNC			 *
* 									 *
* 	A8 = Ptr to part blowing					 *
*								         *
**************************************************************************
A_BLOW_PART
	.IF AUSTRALIA
	RETS
	.ENDIF
	MOVE	*A8(OPART_BLOW_FUNC),A14,L
	JRZ	ABP_X
	JUMP	A14
ABP_X
	RETS

**************************************************************************
*								         *
* 	A_BLOW_HEAD							 *
* 									 *
* 	Anim Func to blow the head part.				 *
* 									 *
* 	A8 = Ptr to head doing the blowing				 *
*								         *
**************************************************************************
A_BLOW_HEAD
	MOVI	HEAD_BLOW_INIT,B0
	MOVI	-10000H,A1
	MOVI	10000H,A2
	MOVI	-60000H,A3
	MOVI	-20000H,A4
	JAUC	BLOW_PART

**************************************************************************
*								         *
* 	A_BLOW_ARM							 *
* 									 *
* 	Anim Func to blow an arm part.					 *
* 									 *
* 	A8 = Ptr to arm doing the blowing				 *
*								         *
**************************************************************************
A_BLOW_ARM
	MOVI	ARM_BLOW_INIT,B0
	JRUC	A_BLOW_GEN

**************************************************************************
*								         *
* 	A_BLOW_LEG							 *
* 									 *
* 	Anim Func to blow a leg part.					 *
* 									 *
* 	A8 = Ptr to leg doing the blowing				 *
*								         *
**************************************************************************
A_BLOW_LEG
	CALLA	GET_HEAD_PART_A0
	MOVI	LEG_BLOW_INIT,B0
A_BLOW_GEN
	MOVI	20000H,A1
	MOVI	60000H,A2
	MOVI	-20000H,A3
	MOVI	20000H,A4
	JAUC	BLOW_PART

**************************************************************************
*								         *
* 	A_PULL_ARM_SPURT						 *
* 									 *
* 	Anim Func to pull the arm blood spurt from the Mega Mondor	 *
* 	multi-parter and give it some random X velocity.		 *
* 									 *
* 	A8 = Ptr to blood part						 *
*								         *
**************************************************************************
A_PULL_ARM_SPURT
	CALLA	PULL_PART
	MOVI	28000H,A0
	CALLA	RAND0
	MOVE	*A8(OCTRL),A14,W
	BTST	B_FLIPH,A14
	JRNZ	APAS_ADDX
	NEG	A0
APAS_ADDX
	ADDRM	A0,*A8(OXVEL),L
	RETS
	
**************************************************************************
*								         *
* 	A_PICK3								 *
* 									 *
* 	Anim Func to randomly pick one of three animation branches.	 *
* 									 *
* 	A8 = Ptr to object						 *
* 	AARG+,L = First branch						 *
* 	AARG+,L = Second branch						 *
* 	AARG+,L = Third branch						 *
*								         *
**************************************************************************
A_PICK3
	CALLA	GETAFARG_LONG
	MOVE	A0,A1
	MOVK	3,A0
	CALLA	RAND0
	JAZ	SetAnim
	MOVE	A0,A2
	CALLA	GETAFARG_LONG
	MOVE	A0,A1
	DEC	A2
	JAZ	SetAnim
	CALLA	GETAFARG_LONG
	MOVE	A0,A1
	JAUC	SetAnim

**************************************************************************
*								         *
* 	A_START_BIG_SHAKE						 *
* 									 *
* 	Anim Func to start a big Mondor shake				 *
* 									 *
* 	A8 = Ptr to any part of Mondor					 *
*								         *
**************************************************************************
A_START_BIG_SHAKE
	MOVK	NUM_PIPEL,A1
	CALLA	FINDPART		;The foot rest will shake ust
	JRZ	ASBS_X			;BR = Couldn't find the part
	MOVI	ANIM_BIG_SHAKE,A1	;Start a shaker anim
	CALLA	STRTANIM
ASBS_X
	RETS

**************************************************************************
*								         *
* 	A_START_MEDIUM_SHAKE						 *
* 									 *
* 	Anim Func to start a MEDIUM Mondor shake			 *
* 									 *
* 	A8 = Ptr to any part of Mondor					 *
*								         *
**************************************************************************
A_START_MEDIUM_SHAKE
	MOVK	NUM_FOOTR,A1
	CALLA	FINDPART		;The foot rest will shake ust
	JRZ	ASMS_X			;BR = Couldn't find the part
	MOVI	ANIM_MEDIUM_SHAKE,A1	;Start a shaker anim
	CALLA	STRTANIM
ASMS_X
	RETS

**************************************************************************
*								         *
* 	A_POUND_SCREAM							 *
* 									 *
* 	Anim Func to determine if we should scream while we pound.	 *
* 									 *
* 	A8 = Ptr to pounding arm					 *
*								         *
**************************************************************************
A_POUND_SCREAM
	MOVK	1,A3
	MOVK	1,A6
	JRUC	DEFAULT_SCREAM	

**************************************************************************
*								         *
* 	A_SCREAM_SND							 *
* 									 *
* 	Anim Func to activate the proper scream sound for 		 *
* 	the current scream animation.					 *
* 									 *
* 	A8 = ptr to Mondor's head					 *
*								         *
**************************************************************************
A_SCREAM_SND
	MOVE	*A8(OSCREAM_SND),A0,L
	CALLA	ONESND_Z
	JRZ	ASS_SOUND_MADE		;BR = Sound was successful
	
	MOVI	ANIM_HEAD_IDLE,A1	;Run the idle,
	JRUC	LOAD_ANIMATION		;immeadiately

ASS_SOUND_MADE
	MOVE	A0,*A8(OCUR_SCREAM),L	;Keep here for scream check
	RETS


**************************************************************************
*								         *
* 	A_SCREAM_HOLD							 *
* 									 *
* 	Anim func to call for every tick of the mouth open.		 *
* 									 *
* 	A8 = Ptr to the head object					 *
* 	AARG+,L = Where to jump to hold mouth open longer.		 *
*								         *
**************************************************************************
A_SCREAM_HOLD
	MOVE	*A8(OCUR_SCREAM),A0,L
	CALLA	IS_SOUND		;Are we still running the scream?
	JAZ	A_Anim_DSJ		;BR = Yes, I will allow you to continue
	RETS
	
**************************************************************************
*								         *
* 	A_BIG_SHIT_SCREAM						 *
* 									 *
* 	Anim func to make Mondor do the big shit scream for		 *
* 	losing a part, if the part is not the head.			 *
* 									 *
* 	A8 = ptr to part being lost					 *
*								         *
**************************************************************************
A_BIG_SHIT_SCREAM
	MOVB	*A8(OPARTID),A14
	CMPK	NUM_HEAD,A14
	JREQ	ABSS_X
	MOVK	1,A3
	MOVI	SND_PART_LOST,A4
	MOVI	80,A5
	MOVK	1,A6
	JRUC	MAKE_MONDOR_SCREAM
ABSS_X
	RETS

**************************************************************************
*								         *
* 	A_LOAD_PART_BLOW						 *
* 									 *
* 	Anim func to load the OPART_BLOW_FUNC field of an object.	 *
*								         *
**************************************************************************
A_LOAD_PART_BLOW
	CALLA	GETAFARG_LONG
	MOVE	A0,*A8(OPART_BLOW_FUNC),L
	RETS

**************************************************************************
*								         *
* 	A_CHECK_POUND							 *
* 									 *
* 	Anim func to see if this pissed Mondor off enough to 		 *
* 	pound.								 *
* 									 *
* 	A8 = ptr to arm							 *
*								         *
**************************************************************************
A_CHECK_POUND
	MOVKB	1,*A8(ONO_GET)		;Limit gun grab 'til after next throw
	MOVB	*A8(OSHOTS_TAKEN),A14
	CMPK	10,A14		     	;Did he shoot enough before losing?
	JRLO	ACP_POUND		;BR = No, so get pissed, you should.
	MOVI	ANIM_ARM_IDLE,A1
	JRUC	LOAD_ANIMATION
ACP_POUND
	MOVI	ANIM_ARM_POUND,A1
	JRUC	LOAD_ANIMATION


**************************************************************************
*								         *
* 	A_CHECK_IF_FINAL						 *
* 									 *
* 	Anim Func to see if this was the final part to explode.		 *
* 	if so, then we will branch to the final explode animation.	 *
* 	If not, then we just pull ourselves.				 *
* 									 *
* 	A8 = ptr to part that just exploded				 *
*								         *
**************************************************************************
A_CHECK_IF_FINAL
	CALLA	GET_HEAD_PART_A0

;	CLRB	*A0(OFDAM_GOING)
	MOVIB	200,*A0(OCLRFDAM)	;Delay clearing for this many ticks

	MOVB	*A8(OPARTID),A7
	CMPK	NUM_HEAD,A7
	JREQ	ACIF_GO_FINAL

	CMPK	NUM_ARML,A7		;Was this an arm that got blasted?
	JRLO	ACIF_LEG		;BR = No, must've been a leg then

	MOVB	*A0(OARMS_GONE),A14
	CMPK	2,A14			;First or second arm toasted?
	JRLO	ACIF_FIRST_ARM		;BR = First arm

	MOVK	TNUM_RIP,A6		;Say this for the second arm
	JRUC	ACIF_TALK

ACIF_FIRST_ARM
	MOVK	TNUM_FLESH,A6		;Say this for the first arm
	JRUC	ACIF_TALK

ACIF_LEG
	MOVB	*A0(OLEGS_GONE),A14
	INC	A14
	MOVB	A14,*A0(OLEGS_GONE)
	CMPK	2,A14			;First or second leg toasted?
	JRLO	ACIF_FIRST_LEG		;BR = First leg

	MOVK	TNUM_GETUP,A6		;Say this for the second leg
	JRUC	ACIF_TALK

ACIF_FIRST_LEG
	MOVK	TNUM_WORSE,A6		;Say this for the first leg

ACIF_TALK
	MOVK	NUM_HEAD,A1
	CALLA	FINDPART

	MOVB	A6,*A0(OTALK_FLAG)	;Still taunt the player

	JAUC	PULL_ANIM

*Start the final explosion
*A0 = Ptr to head-part
ACIF_GO_FINAL
	MOVE	A8,A1
	MOVE	A0,A8
	CALLA	ALL_COLLS_OFF
	MOVE	A1,A8

	MOVKB	1,*A0(OFDAM_GOING)	;Flag the final damage
	MOVIM	1,@GUNS_OFF,W

	MOVB	*A0(OPARTS_LOST),A14
	CMPK	5,A14
	JRLO	ACIF_NOT_TOTAL
	MOVKM	1,@MONDOR_TOTAL,W	;Set the total flag
ACIF_NOT_TOTAL

	MOVI	PID_POWERUPD0,A0
	CALLA	KILLPROC_ALL

	MOVI	ANIM_FINAL_EXPLOSION,A1
	JAUC	SetAnim
	

**************************************************************************
*								         *
* 	A_TURN_OFF_NEXT_PART						 *
* 									 *
* 	Anim func to turn off the next part in the craft.		 *
* 									 *
* 	A8 = Ptr to Mondor part						 *
* 	AARG+,L = Branch if there are more parts to turn off		 *
*								         *
**************************************************************************
A_TURN_OFF_NEXT_PART
	CALLA	GET_HEAD_PART_A0
	MOVK	1,A6
ATONP_LOOP
	MOVE	*A0(OFLAGS),A14
	BTST	B_NODISP,A14
	JRNZ	ATONP_NEXT		;BR = Already off

	CALLA	OBJOFF
	CALLA	GETAFARG_LONG
	MOVE	A0,*A8(AnimFrm),L
	RETS
ATONP_NEXT
	INC	A6	
	CMPK	NUM_TORSOL,A6
	JRHS	ATONP_ALL_DONE
	MOVE	*A0(OPARTS),A0,L
	JRNZ	ATONP_LOOP
ATONP_ALL_DONE
	RETS


**************************************************************************
*								         *
* 	A_KEEP_US_CENTERED						 *
* 									 *
* 	Anim Func to keep the OCENTERED flag set.			 *
* 									 *
* 	A8 = Ptr to any Mondor part.					 *
*								         *
**************************************************************************
A_KEEP_US_CENTERED
	CALLA	GET_HEAD_PART_A0
	MOVKB	2,*A0(OCENTER_FLAG)
	MOVIB	120,*A0(OCLRCENTER)
	RETS

**************************************************************************
*								         *
* 	A_GOOD_TO_GO							 *
* 									 *
* 	Anim func to set up Mondor for the final explode.		 *
* 									 *
* 	A8 = ptr to any mondor part.					 *
*								         *
**************************************************************************
A_GOOD_TO_GO
	CALLA	GET_HEAD_PART
	CLRB	*A8(OCENTER_FLAG)	;No more centering
	CALLA	PULL_ANIM		;No more random movement
	MOVK	NUM_FOOTL,A1
	CALLA	FINDPART
	JRZ	AGTG_VEL
	CALLA	CKPULLANIM
	MOVE	*A0(OPARTS),A0,L
	CALLA	CKPULLANIM
	MOVE	*A0(OPARTS),A0,L
	CALLA	CKPULLANIM
AGTG_VEL
	MOVE	@XBASE,A1,L
	CALLA	SET_ANIPXU		;Center Mondor
	CALLA	SET_OBJSU		;and all of his parts
	MOVIM	400H,*A8(OZVEL),L	;And no more jerky beef
	RETS


**************************************************************************
*								         *
* 	A_MAKE_HEAD_LOOK						 *
* 									 *
* 	Anim Func to make the head look at the hand that lost		 *
* 	the gun.							 *
* 									 *
* 	A8 = Ptr to hand that lost it.					 *
*								         *
**************************************************************************
A_MAKE_HEAD_LOOK
	MOVK	NUM_HEAD,A1
	CALLA	FINDPART
	JRZ	AMHL_NO_HEAD_FOUND
	MOVB	*A8(OPARTID),*A0(OGUN_BLOWN)	;Mark it for the head
AMHL_NO_HEAD_FOUND
	CALLA	GET_HEAD_PART
	CLRM	*A8(OARM_WAIT),W		;Let arm work again
	RETS

**************************************************************************
*								         *
* 	A_START_TALKIN							 *
* 									 *
* 	Anim func to fire off the talk sound after the intial		 *
* 	wait.								 *
* 									 *
* 	A8 = Ptr to Mondor's head					 *
* 	AARG+,L = Script loop point					 *
*								         *
**************************************************************************
A_START_TALKIN
	CALLA	GETAFARG_LONG
	MOVE	A0,*A8(AnimScr),L	;Setup talk loop

	MOVE	*A8(OTALK_SCRIPT),A1,L
	MOVE	*A1+,A0,L
	MOVE	A1,*A8(OTALK_SCRIPT),L
	MOVE	A0,*A8(OTALK_SND),L

	CALLA	ONESND			;Fire off the speech
	JRZ	AST_SOUND_MADE		;BR = Sound was successful
	
	CLRB	*A8(OTALK_FLAG)		;Clear that flag
	MOVI	ANIM_HEAD_IDLE,A1	;Run the idle,
	JRUC	LOAD_ANIMATION		;immeadiately

AST_SOUND_MADE

	JRUC	A_TALK_NEXT		;And setup the next

**************************************************************************
*								         *
* 	A_TALK_NEXT							 *
* 									 *
* 	Anim func to load the next talk sleep time.			 *
* 									 *
* 	A8 = Ptr to Mondor's head					 *
*								         *
**************************************************************************
A_TALK_NEXT
;	MOVE	*A8(OTALK_SND),A0,L
;	JRZ	ATN_SOUND_MADE
;	CALLA	ONESND			;Fire off the speech
;	JRZ	ATN_SOUND_MADE		;BR = Sound was successful
	
;	CLRB	*A8(OTALK_FLAG)		;Clear that flag
;	MOVI	ANIM_HEAD_IDLE,A1	;Run the idle,
;	JRUC	LOAD_ANIMATION		;immeadiately

;ATN_SOUND_MADE
;	CLRM	*A8(OTALK_SND),L
	MOVE	*A8(OTALK_SCRIPT),A1,L
	MOVB	*A1(0),*A8(AnimSLP)	;Load next close pause
	ADDK	8,A1
	MOVE	A1,*A8(OTALK_SCRIPT),L
	RETS

**************************************************************************
*								         *
* 	A_TALK_END							 *
* 									 *
* 	Anim func for completion of one syllable of speech.		 *
* 	Decrements syllable count and loads next sleep if necessary.	 *
* 									 *
* 	A8 = Ptr to Mondor's head					 *
*								         *
**************************************************************************
A_TALK_END
	MOVB	*A8(OSCREAM),A0		;Does Mondor need a scream?
	JRZ	ATE_NO_SCREAMING	;BR = No

	MOVB	*A8(OSCREAM_SEV),A14	;If so, is it worth blowing this off?
	JRNZ	MONDOR_SCREAM_IMM	;BR = Yes

ATE_NO_SCREAMING
	MOVE	@GAME_STATE,A14,W
	CMPI	INGAMEOV,A14		;Did we land in game over?
	JRNZ	ATE_GAME_ON		;BR = No

	MOVB	*A8(OTALK_FLAG),A14	;We are in game over
	CMPI	TNUM_MOMMY,A14		;Only allowed to say, mommy line
	JREQ	ATE_GAME_ON		;BR = and we are

ATE_GET_THE_HELL_OUT
	CLRB	*A8(OTALK_FLAG)		;Clear that flag
	MOVI	ANIM_HEAD_IDLE,A1	;Run the idle,
	JRUC	LOAD_ANIMATION		;immeadiately

ATE_GAME_ON
	MOVE	*A8(OTALK_SND),A0,L
	CALLA	IS_SOUND		;Are we still running the same sound?
	JRNZ	ATE_GET_THE_HELL_OUT	;BR = No

	MOVB	*A8(AnimLoop),A14
	DEC	A14			;Any more syllables left?
	MOVB	A14,*A8(AnimLoop)
	JRNZ	ATE_NEXT_SYL		;BR = Yes, do next syllable

	CLRB	*A8(OTALK_FLAG)		;Clear that flag
	MOVB	A14,*A8(OSCREAM)	;Clear scream flag, it looks stupid
	JRUC	ATE_X

ATE_NEXT_SYL
	MOVE	*A8(OTALK_SCRIPT),A1,L	;Advance the script

;	MOVE	*A1(0),*A8(OTALK_SND),L	;Load the next sound
;	ADDK	32,A1

	MOVB	*A1(0),*A8(AnimSLP)	;Load next open pause
	ADDK	8,A1
	MOVE	A1,*A8(OTALK_SCRIPT),L

	MOVE	*A8(AnimScr),*A8(AnimFrm),L	;Loop the animation
ATE_X
	RETS

**************************************************************************
*								         *
* 	A_HEAD_INTRO							 *
* 									 *
* 	Anim func to setup Mondor's head for the intro speech.		 *
* 									 *
* 	A8 = Ptr to Mondor's head					 *
*								         *
**************************************************************************
A_HEAD_INTRO
	MOVKB	TNUM_SUSHI,*A8(OTALK_FLAG)
	RETS

**************************************************************************
*								         *
* 	A_INIT_ARM							 *
* 									 *
* 	Anim func to initialize Mondor's arms for action.		 *
* 									 *
* 	A8 = Ptr to arm object						 *
*								         *
**************************************************************************
A_INIT_ARM
	CALLR	TURN_ON_SCALE_SHAD
	MOVI	FLESH1p,A0	
	CALLA	CHANGE_PAL
	ORIM	M_NOPARTANI,*A8(OFLAGS),W
	MOVI	ANIM_ARM_INIT,A1
	JAUC	STRT_ANIM

**************************************************************************
*								         *
* 	A_INIT_HEAD							 *
* 									 *
* 	Anim func to initialize Mondor's head for action.		 *
* 									 *
* 	A8 = Ptr to head object						 *
*								         *
**************************************************************************
A_INIT_HEAD
	CALLR	TURN_ON_SCALE_SHAD
	MOVI	FHEDcc1,A0	
	CALLA	CHANGE_PAL
	ORIM	M_NOPARTANI,*A8(OFLAGS),W
	MOVIB	-2,*A8(OZOFF)
	PUSH	A8
	CALLA	GET_HEAD_PART
	MOVE	*A8(OZVAL),A1,L
	CALLA	SET_ANIPZU
	PULLQ	A8
	MOVI	ANIM_HEAD_INTRO,A1
	JAUC	STRT_ANIM

**************************************************************************
*								         *
* 	A_INIT_GLASSES							 *
* 									 *
* 	Anim func to initialize Mondor's head for action.		 *
* 									 *
* 	A8 = Ptr to head object						 *
*								         *
**************************************************************************
A_INIT_GLASSES
	ANDNIM	M_NOSCALE|M_NOSHADOW,*A8(OFLAGS),W

	MOVI	GLASPAL2,A0	
	CALLA	CHANGE_PAL
	MOVIB	-3,*A8(OZOFF)
	PUSH	A8
	CALLA	GET_HEAD_PART
	MOVE	*A8(OZVAL),A1,L
	CALLA	SET_ANIPZU
	PULLQ	A8
	RETS

**************************************************************************
*								         *
* 	A_START_MOVEMENT						 *
* 									 *
* 	Anim func to start the master part animating with the		 *
* 	move decision animation.					 *
* 									 *
* 	A8 = Ptr to any part						 *
*								         *
**************************************************************************
A_START_MOVEMENT
	CALLA	GET_HEAD_PART
	MOVI	ANIM_MOVEMENT,A1
	CALLA	STRT_ANIM
	MOVE	*A8(OPARTS),A8,L
	MOVI	ANIM_VELOCITY_WATCH,A1
	JAUC	STRT_ANIM

**************************************************************************
*								         *
* 	A_START_GEAR_OUT						 *
* 									 *
* 	Anim func to start the pods and foot rests extending.		 *
* 									 *
* 	A8 = Ptr to any part of Mondor					 *
*								         *
**************************************************************************
A_START_GEAR_OUT
	CALLA	GET_HEAD_PART_A0
	MOVK	8,A6
	MOVI	CRAFT_CVECT,A1
ASGO_CVECT_LOOP
	MOVE	A1,*A0(OCVECT),L
	MOVE	*A0(OPARTS),A0,L
	DSJS	A6,ASGO_CVECT_LOOP

	MOVK	NUM_PODL,A1
	CALLA	FINDPART	      	;Get the left pod object
	MOVI	ANIM_THRUSTER_OUT_L,A1
	CALLA	STRTANIM	   	;Start it out
	MOVE	*A0(OPARTS),A0,L
	MOVI	ANIM_THRUSTER_OUT_R,A1
	CALLA	STRTANIM	    	;Start right on it's way

	MOVK	NUM_PLATE,A1
	CALLA	FINDPART	  	;Find license plate
	MOVI	ANIM_PLATE_OUT,A1	;Start
	CALLA	STRTANIM

	MOVK	NUM_PIPEL,A1
	CALLA	FINDPART	  	;Find left foot rest pipe
	MOVI	ANIM_FOOT_OUT,A1	;Start
	CALLA	STRTANIM
	MOVE	*A0(OPARTS),A0,L	;Now the right side
	JAUC	STRTANIM		;Start

**************************************************************************
*								         *
* 	A_FOOT_ON							 *
* 									 *
* 	Anim func to turn on the foot rest parts.			 *
* 									 *
* 	A8 = Ptr to a pipe object					 *
*								         *
**************************************************************************
A_FOOT_ON
	CALLR	TURN_ON_SCALE_SHAD
	MOVK	NUM_FOOTL,A1
	CALLA	FINDPART	      	;Get the left foot rest object
	CALLA	OBJON			;Turn it on, Turn it on Again
	MOVE	*A0(OPARTS),A0,L	;Same with the right
	JAUC	OBJON
	
**************************************************************************
*								         *
* 	A_THRUSTER_EXTENDED						 *
* 									 *
* 	Anim func to run on a thruster when it is fully extended.	 *
* 									 *
* 	A8 = Ptr to thruster						 *
* 	AARG+,L = Animation to jump to					 *
*								         *
**************************************************************************
A_THRUSTER_EXTENDED
	CALLR	TURN_ON_SCALE_SHAD
	JAUC	A_AnimGo

**************************************************************************
*								         *
* 	A_SCALE_PAL							 *
* 									 *
* 	Anim func to turn on scaling and change the palette of		 *
* 	an object.							 *
* 									 *
* 	A8 = Ptr to object						 *
* 	AARG+,L = New palette						 *
*								         *
**************************************************************************
A_SCALE_PAL
	CALLR	TURN_ON_SCALE_SHAD
	JAUC	A_CHANGE_PAL

**************************************************************************
*								         *
* 	A_OBJ_OFF_SCALE_PAL						 *
* 									 *
* 	Anim func to turn an object off, turn on scaling and		 *
* 	change the palette! Whew!					 *
* 									 *
* 	A8 = Ptr to object						 *
* 	AARG+,L = New palette						 *
*	AARG+,L = Alternate, non-violent palette			 *
*								         *
**************************************************************************
A_OBJ_OFF_SCALE_PAL
	CALLR	TURN_ON_SCALE_SHAD
	CALLA	OBJ_OFF
	JRUC	A_CHANGE_PAL_VIOLENCE

**************************************************************************
*								         *
* 	A_GET_SHAD_MULTI						 *
* 									 *
* 	Anim func to get a shadow for the given multi-part object.	 *
* 									 *
* 	A8 = Ptr to any part						 *
*								         *
**************************************************************************
A_GET_SHAD_MULTI
	CALLA	GET_HEAD_PART
	JAUC	GET_SHAD_MULTI

**************************************************************************
*								         *
* 	TURN_ON_SCALE_SHAD						 *
* 									 *
* 	Kill the NOSCALE flag on an object and it's shadow.		 *
* 									 *
* 	A8 = Ptr to object						 *
*								         *
**************************************************************************
TURN_ON_SCALE_SHAD
	PUSH	A0
	ANDNIM	M_NOSCALE|M_NOSHADOW,*A8(OFLAGS),W
	MOVE	*A8(OSHAD),A0,L
	JRZ	TOS_X
	ANDNIM	M_NOSCALE,*A0(OFLAGS),W
TOS_X	
	PULLQ	A0
	RETS

**************************************************************************
*								         *
* MONDOR_CVECT								 *
*								         *
**************************************************************************
MONDOR_CVECT
	WWL	OID_PROCKET,~MASK_PLAYER,MONDOR_ROCKET_COLL
	WWL	OID_PEXPLOSION,~MASK_PLAYER,MONDOR_EXPLOSION_COLL
	WL	0,DUMCRETS

*Special chest gun vector
MONDOR_CHEST_CVECT
	WWL	OID_PROCKET,~MASK_PLAYER,MONDOR_ROCKET_COLL
	WWL	OID_PEXPLOSION,~MASK_PLAYER,MONDOR_CHEST_EXP_COLL
	WL	0,DUMCRETS

**************************************************************************
*								         *
* CRAFT_CVECT								 *
*								         *
**************************************************************************
CRAFT_CVECT
	WWL	OID_PROCKET,~MASK_PLAYER,MONDOR_ROCKET_COLL
	WWL	OID_PEXPLOSION,~MASK_PLAYER,CRAFT_EXPLOSION_COLL
	WL	0,DUMCRETS

**************************************************************************
*								         *
* PLATE_CVECT								 *
*								         *
**************************************************************************
PLATE_CVECT
	WWL	OID_PROCKET,~MASK_PLAYER,MONDOR_ROCKET_COLL
	WWL	OID_PEXPLOSION,~MASK_PLAYER,PLATE_EXPLOSION_COLL
	WL	0,DUMCRETS


*Craft seat hits the ground
CRAFT_SEAT_CVECT
	WWL	OID_GRND,0FFFFH,SEAT_GROUND_COLL
	WL	0,DUMCRETS
	
**************************************************************************
*								         *
* 	SEAT_GROUND_COLL						 *
* 									 *
* 	Ground collision service for the craft's seat.			 *
* 									 *
* 	A8 = Ptr to seat object						 *
*								         *
**************************************************************************
SEAT_GROUND_COLL
	SOUND1	SND_SEAT_BOUNCE
	MOVE	*A8(OYVEL),A3,L
	CMPI	80000H,A3
	JRLT	SGC_NOT_FIRST

	MOVK	NUM_TORSOL,A1
	CALLA	FINDPART

	MOVI	ANIM_JOSH_MORPH,A1
;	MOVI	ANIM_START_MONDOR,A1

	CALLA	STRTANIM

SGC_NOT_FIRST
	SRA	2,A3
	CMPI	10000H,A3
	JRGE	SGC_OK
      	CLR	A3
SGC_OK
	NEG	A3
	MOVE	A3,*A8(OYVEL),L
	JRNZ	SGC_X

	MOVE	A3,*A8(OYACCEL),W

	MOVIM	CRAFT_CVECT,*A8(OCVECT),L
	ANDNIM	M_GCOLL,*A8(OFLAGS),W

	CREATE	PID_HELGA,PROC_THRONE_HELGA

SGC_X
	RETS

**************************************************************************
*								         *
* MONDOR_ROCKET_COLL - Collision vector with Player rocket bomb.	 *
* A0 = Ptr to rocket object						 *
* A8 = Ptr to MONDOR part						 *
*								         *
**************************************************************************
MONDOR_ROCKET_COLL
;	MOVB	*A8(OROCKETHIT),A14	;Should we set the flag again?
;	JRNZ	MRC_X			;BR = No, it is already set
	MOVE	*A0(RL_INTENDED_OBJ),A14,L
	CMP	A14,A8			;Is this the object we are after?
	JRNE	MRC_X			;BR = No
	MOVK	1,A14
;	MOVB	A14,*A8(OROCKETHIT)	;Flag the rocket attack
	MOVB	A14,*A8(OCHEWEDROCKET)	;Flag for the explosion
MRC_X
	RETS

**************************************************************************
*								         *
* MONDOR_EXPLOSION_COLL - Collision vector for Player explosion against	 *
*			  generic Mondor part.				 *
* A0 = Ptr to explosion object						 *
* A8 = Ptr to MONDOR part						 *
*								         *
**************************************************************************
MONDOR_EXPLOSION_COLL
	MOVI	512,A0
	CALLA	RANDPER
	JRC	MEC_DO_SMALL_BLOW

	MOVB	*A8(OCHEWEDROCKET),A14	;Did he really take a rocket?
	JRZ	MEC_X			;BR = No, so bail

	CLR	A14
	MOVB	A14,*A8(OCHEWEDROCKET)	;Clear the rocket flag

	MOVE	A0,A5			;Visiting explosion goes here

	MOVE	*A8(OZVAL),A1,L
	MOVE	@ZBASE,A14,L
	SUB	A14,A1			;Universe to World Z

	CMPI	MONDOR_ZMAX-100H,A1	;Should we blast him back?
	JRGT	MEC_NO_BLOW_BACK	;BR = No, not close enough.
	JRUC	MEC_JERK_HIM

MEC_DO_SMALL_BLOW
	MOVE	A0,A4
	MOVK	20,A0
	MOVK	4,A1
	CALLA	RANGERND
	SWAP	A0,A4
	JRUC	MONDOR_TAKE_ROCKET


**************************************************************************
*								         *
* MONDOR_CHEST_EXP_COLL - Collision vector for Player explosion against	 *
*			  Mondor's chest.				 *
* A0 = Ptr to explosion object						 *
* A8 = Ptr to MONDOR part						 *
*								         *
**************************************************************************
MONDOR_CHEST_EXP_COLL
	MOVI	50,A4

*A4 = Blow back duration, if we decide to blow back
MONDOR_TAKE_ROCKET
	MOVB	*A8(OCHEWEDROCKET),A14	;Did he really take a rocket?
	JRZ	MEC_X			;BR = No, so bail

	CLR	A14
	MOVB	A14,*A8(OCHEWEDROCKET)	;Clear the rocket flag

	MOVE	A0,A5			;Visiting explosion goes here

	MOVE	*A8(OZVAL),A1,L
	MOVE	@ZBASE,A14,L
	SUB	A14,A1			;Universe to World Z

	CMPI	MONDOR_ZMAX-100H,A1	;Should we blast him back?
	JRGT	MEC_NO_BLOW_BACK	;BR = No, not close enough.

	CALLA	GET_HEAD_PART_A0	;Check this velocity stuff on head

	MOVB	*A0(OCENTER_FLAG),A14	;Are we currently supposed to be centered?
	JRNZ	MEC_JERK_HIM		;BR = Yes, then don't go back

	MOVB	*A0(ONOSET_ZVEL),A14	;Are we currently blowing back?
	JRNZ	MEC_JERK_HIM		;BR = Yes, then don't do it again

	MOVE	*A0(OZVEL),A14,L	;Determine how much time to blowback
	JRGE	MEC_FULL_BLOWBACK	;BR = Set full time
	SRA	8,A14
	ADD	A4,A14			;Calculate accordingly
	CMPK	5,A14			;Too small?
	JRGE	MEC_SET_ZBLOW_TIME	;BR = no, it'll do
	MOVK	5,A14			;Min ticks
	JRUC	MEC_SET_ZBLOW_TIME
MEC_FULL_BLOWBACK
	MOVE	A4,A14			;Max ticks
MEC_SET_ZBLOW_TIME	
	MOVB	A14,*A0(OCLRNOSETZVEL)
	MOVB	A14,*A0(ONOSET_ZVEL)

	ADDIM	0C00H,*A0(OZVEL),L	;Back to mama punk!

	MOVE	A0,A1

	MOVI	40000H,A0
	CALLA	SRAND
	ADDRM	A0,*A1(OXVEL),L

	MOVI	10000H,A0
	CALLA	SRAND
	ADDRM	A0,*A1(OYVEL),L

	MOVK	1,A3
	CLR	A6
	CMPK	20,A4			;Was this a short burst?
	JRLS	MEC_DO_BLOW_SCREAM	;BR = Yes, then short scream
	MOVK	2,A6			;Do the patented blow back yell
MEC_DO_BLOW_SCREAM
	CALLR	DEFAULT_SCREAM

	JRUC	MEC_NO_BLOW_BACK

*Just give the rig a jolt.
*A5 = Ptr to explosion object
MEC_JERK_HIM
	MOVK	NUM_FOOTL,A1
	CALLA	FINDPART		;The foot rest will shake ust
	JRZ	MEC_NO_BLOW_BACK	;BR = Couldn't find the part
	MOVI	ANIM_SMALL_SHAKE,A1	;Start a shaker anim
	CALLA	STRTANIM

MEC_NO_BLOW_BACK
	CALLA	OBJ_CONST		;Turn constant color on
	MOVKB	6,*A8(OFLASHTIME)

	MOVB	*A8(OROCKETHIT),A14	;Should we actually take damage?
	JRNZ	MEC_X			;BR = No, we are waiting

	MOVKB	1,*A8(OROCKETHIT)	;Flag the hit, and use to delay

	SOUNDZ	SND_EXPLODE_ON_MONDOR	;Make our own explosion sound

	MOVE	*A5(OID),A0,W		;We can find out who did this
	CALLA	POID_TO_PDATA		;by getting the Player's data area.

*
*Entry point for somebody to score a major hit on Mondor.
*A2 = Ptr to player doing the hitting
*A5 = 0
*A8 = Ptr to Mondor part being hit
*
MONDOR_MAJOR_HIT
	CALLA	GET_HEAD_PART_A0
	MOVE	A0,A7			;Head-part stays in A7

	MOVB	*A7(OFDAM_GOING),A14	;Is a Final damage going?
	JRNZ	MEC_DONE		;BR = Right, then no one else goes

	MOVK	5,A1
	MOVI	OHITS,A3
	CALLA	HIT_ENEMY	
	JRLO	MEC_NO_KILL

	CLR	A14
	MOVE	A14,*A8(OHITS),L

	MOVB	*A8(ODAMAGE),A14
	INC	A14
	CMPK	MAX_DAMAGE_LEVEL,A14	;Is the damage maxed out?
	JRLS	MEC_DAMAGE		;BR = No, go to the next level!
*
*Cannot lose a part completely until all other parts are fully damaged.
*

*Only one final damage animation at a time
;	MOVB	*A7(OFDAM_GOING),A14
;	JRNZ	MEC_DONE

*Except for the legs, they can go right away

	MOVB	*A8(OPARTID),A4

	CMPK	NUM_LEGL,A4		;Is this the left leg?
	JREQ	MEC_LOSE_PART		;BR = Yes, then it my blow when ready
	CMPK	NUM_LEGR,A4		;Is this the right leg?
	JREQ	MEC_LOSE_PART		;BR = Yes, then it my blow when ready

	MOVK	NUM_TORSOL,A1		;Start with the Torso pieces
	CALLA	FINDPART		;Get the part
	MOVK	NUM_TORSO_PARTS,A6
MEC_CHECK_NEXT_DAMAGE
	MOVB	*A0(ODAMAGE),A14
	CMPK	MAX_DAMAGE_LEVEL,A14	;Is this part fully damaged?
	JRLO	MEC_NO_KILL		;BR = No, then we cannot lose part
	MOVE	*A0(OPARTS),A0,L
	DSJS	A6,MEC_CHECK_NEXT_DAMAGE

*A4 = OPARTID
MEC_LOSE_PART
	CMPK	NUM_HEAD,A4		;Is this his head?
	JRNE	MEC_LOSE_PART2		;BR = No, just lose the part
*
*Both arms must be toasted before head is allowed to go
*
	MOVB	*A7(OARMS_GONE),A14
	CMPK	2,A14			;Are they both gone?
	JRLO	MEC_NO_KILL		;BR = No

MEC_LOSE_PART2
	SUBK	NUM_TORSOL,A4
	SLL	5,A4
	ADDI	FINAL_ANIM_TABLE,A4
	MOVE	*A4,A1,L		;Get the final animation for this part
	JRZ	MEC_NO_DAMAGE

	INCB	*A7(OPARTS_LOST)	;Chalk another part gone

	MOVKB	2,*A7(OCENTER_FLAG)
	MOVIB	120,*A7(OCLRCENTER)

	MOVKB	1,*A7(OFDAM_GOING)

	CALLA	STRT_ANIM		;and start it animating
	MOVIM	DUMCOLL,*A8(OCVECT),L	;No more collisions for you
	MOVIM	DUMRETS,*A8(OGUNVECT),L	;No more bullets either

	INCB	*A8(ODAMAGE)		;Get that Damage level past the point

	MOVI	9900,A1
	CALLA	SCORE			;Killing is the best for points

	MOVK	NUM_PIPEL,A1
	CALLA	FINDPART		;The foot rest will shake ust
	JRZ	MEC_DONE		;BR = Couldn't find the part
	MOVI	ANIM_BIG_SHAKE,A1	;Start a shaker anim
	CALLA	STRTANIM

	JRUC	MEC_DONE

*We can damage our little hearts out!
*A7 = Ptr to head-part
MEC_DAMAGE
	MOVB	A14,*A8(ODAMAGE)

	MOVB	*A8(OPARTID),A14
	SUBK	NUM_TORSOL,A14
	SLL	5,A14
	ADDI	DAMAGE_ANIM_TABLE,A14
	MOVE	*A14,A1,L		;Get the damage animation for this part
	JRZ	MEC_NO_DAMAGE

;	CALLA	GET_HEAD_PART_A0
;	MOVKB	1,*A0(OCENTER_FLAG)
;	MOVIB	70,*A0(OCLRCENTER)

	CALLA	STRT_ANIM		;and start it animating

	MOVI	4900,A1
	CALLA	SCORE			;Damage is good for points

	MOVK	NUM_FOOTR,A1
	CALLA	FINDPART		;The foot rest will shake ust
	JRZ	MEC_DONE		;BR = Couldn't find the part
	MOVI	ANIM_MEDIUM_SHAKE,A1	;Start a shaker anim
	CALLA	STRTANIM

	MOVK	1,A3
	CLR	A6
	CALLR	DEFAULT_SCREAM

;	RANDENT	TAB_DAMAGE_SOUNDS,NUM_DAMAGE_SNDS,5,L
;	CALLA	ONESND_Z
	
	JRUC	MEC_DONE

MEC_NO_DAMAGE

*
*A5 = Ptr to explosion object, 0 = No explosion object 
*
MEC_NO_KILL
	MOVB	*A8(OPARTID),A6
	CMPK	NUM_HEAD,A6
	JRNE	MEC_CHECK_ARM

*Make head scream when hit by a rocket
	MOVK	3,A0
	CALLA	RANDU
	MOVE	A0,A3
	CLR	A6
	CALLR	DEFAULT_SCREAM
	JRUC	MEC_DONE

MEC_CHECK_ARM
	CMPK	NUM_ARML,A6	
	JREQ	MEC_CHK_ARM_GUN
	CMPK	NUM_ARMR,A6
	JRNE	MEC_DONE

*Make gun fly out of his hand when hit by a rocket
MEC_CHK_ARM_GUN
	MOVB	*A8(OGUN_IN_HAND),A14	;Is he holding a gun in this hand?
	JRZ   	MEC_DONE		;BR = No, do the regular thang

	CLR	A14
	MOVB	A14,*A8(OGUN_IN_HAND)	;Not holding that gun anymore

;	MOVK	NUM_HEAD,A1
;	CALLA	FINDPART
;	JRZ	MEC_NO_HEAD_FOUND

;	MOVB	A6,*A0(OGUN_BLOWN)	;Mark it for the head
;MEC_NO_HEAD_FOUND
	MOVI	ANIM_ARM_LOSE_GUN,A1
	CALLR	LOAD_ANIMATION		;Start the animation happening

MEC_DONE
	MOVKB	25,*A8(OCLRROCKETHIT)	;Time 'til we reset for the next

	MOVE	A2,*A8(OPLAYER),L	;Hang on to this address

	MOVI	100,A1
	CALLA	SCORE			;Explosions are always good for points
	
MEC_X
	RETS

**************************************************************************
*								         *
* 	MONDOR_GUNVECT							 *
* 									 *
* 	Gun Vector for all of Mondor's parts.  The part will flash	 *
* 	and increase in damage if necessary.				 *
* 									 *
* 	A2 = Ptr to player hitting Mondor				 *
* 	A8 = Ptr to part 						 *
*								         *
**************************************************************************
MONDOR_GUNVECT
	MOVB	*A8(O_BEING_DAMAGED),A14	;Is this part currently under attack?
	JRNZ	MGV_X			;BR = Yes

	CALLA	OBJ_CONST		;Turn constant color on
	MOVKB	4,*A8(OFLASHTIME)

	SOUNDZ	SND_FLESH_HIT

	MOVB	*A8(ODAMAGE),A5
	CMPK	MAX_DAMAGE_LEVEL,A5	;Is the damage maxed for this object?
	JRHI	MGV_NO_FRAGS		;BR = Yes

	MOVE	*A2(PPLASMASHOTS),A14,W
	JRZ	MGV_BLOODY

	MMTM	SP,A0,A3,A4
	MMTM	SP,B0,B1,B2,B3,B4,B5,B6,B7,B8,B9,B10

	MOVI	FRAG_EXPLOSION_ONE,B14

	MOVI	[1,0],A0
	MOVI	10H,A3
	CLR	A4

	CALLA	PreFrag_Gun
	CALLA	Fragger
	MMFM	SP,B0,B1,B2,B3,B4,B5,B6,B7,B8,B9,B10

	MOVK	NUM_FOOTL,A1
	CALLA	FINDPART		;The foot rest will shake ust
	JRZ	MGV_NO_SHAKE		;BR = Couldn't find the part
	MOVI	ANIM_SMALL_SHAKE,A1	;Start a shaker anim
	CALLA	STRTANIM
MGV_NO_SHAKE
	MMFM	SP,A0,A3,A4

	CALLA	BLOODY_BULLET_HIT

	MOVI	BULLET_HITS-5,A1	;More powerful hits
	JRUC	MGV_DO_HIT

MGV_BLOODY
	CALLA	BLOODY_BULLET_HIT

MGV_NO_FRAGS
	MOVI	BULLET_HITS,A1
MGV_DO_HIT
	MOVI	OBULLET_HITS,A3
	CALLA	HIT_ENEMY		;Enough hits to merit damage?
	JRLO	MGV_X			;BR = No
	CLR	A14
	MOVE	A14,*A8(OBULLET_HITS),L	;Clear count

	MOVB	*A8(ODAMAGE),A14
	INC	A14
	CMPK	MAX_DAMAGE_LEVEL,A14	;Is the damage maxed out?
	JRLS	MONDOR_MAJOR_HIT	;BR = No, bullets allowed

	CALLA	ANY_BOMBS		;Are there any rockets out there?
	JRZ	MONDOR_MAJOR_HIT	;BR = No, then let bullets finish

MGV_X
	RETS


**************************************************************************
*								         *
* 	CRAFT_EXPLOSION_COLL						 *
* 									 *
* 	Collision vector for player explosion against the craft.	 *
* 									 *
* 	A0 = Ptr to explosion object					 *
* 	A8 = Ptr to Craft part						 *
*								         *
**************************************************************************
CRAFT_EXPLOSION_COLL
	MOVB	*A8(OCHEWEDROCKET),A14	;Did he really take a rocket?
	JRZ	CEC_X			;BR = No, so bail

	CLR	A14
	MOVB	A14,*A8(OCHEWEDROCKET)	;Clear the rocket flag

	MOVE	A0,A5			;Visiting explosion goes here

	CALLA	GET_HEAD_PART_A0	;Check this velocity stuff on head
	MOVE	A0,A7			;Head-part stays in A7

	MOVE	*A8(OZVAL),A1,L
	MOVE	@ZBASE,A14,L
	SUB	A14,A1			;Universe to World Z

	CMPI	MONDOR_ZMAX-100H,A1	;Should we blast him back?
	JRGT	CEC_NO_BLOW_BACK	;BR = No, not close enough.

	MOVK	NUM_FOOTR,A1
	CALLA	FINDPART		;The foot rest will shake ust
	JRZ	CEC_NO_BLOW_BACK	;BR = Couldn't find the part
	MOVI	ANIM_MEDIUM_SHAKE,A1	;Start a shaker anim
	CALLA	STRTANIM

CEC_NO_BLOW_BACK
	CALLA	OBJ_CONST		;Turn constant color on
	MOVKB	6,*A8(OFLASHTIME)

	MOVB	*A8(OROCKETHIT),A14	;Should we actually take damage?
	JRNZ	CEC_X			;BR = No, we are waiting

	MOVKB	1,*A8(OROCKETHIT)	;Flag the hit, and use to delay

	SOUNDZ	SND_EXPLODE_ON_MONDOR	;Make our own explosion sound

	MOVE	*A5(OID),A0,W		;We can find out who did this
	CALLA	POID_TO_PDATA		;by getting the Player's data area.

	MOVB	*A8(OPARTID),A4

*Check if we hit the pods
	CMPK	NUM_PODL,A4		;Is it the left?
	JRNE	CEC_CK_PODR		;BR = No

	MOVK	NUM_ARML,A1		;Check left arm
	JRUC	CEC_CK_POD_FIRE

CEC_CK_PODR
	CMPK	NUM_PODR,A4		;Is it the right?
	JRNE	CEC_DONE		;BR = No

	MOVK	NUM_ARMR,A1		;Check the right arm

CEC_CK_POD_FIRE
	CALLA	FINDPART
	MOVB	*A0(ODAMAGE),A14
	CMPK	MAX_DAMAGE_LEVEL,A14	;Is arm completely gone?
	JRLS	CEC_NO_FIRE		;BR = No, then no fire

*Spawn an engine fire
	MOVK	5,A0
	CALLA	RAND0
	SLL	5,A0
	ADDI	POD_FIRE_TAB,A0
	MOVE	*A0,A3,L
	MOVK	1,A9
	MOVI	INIT_POD_FIRE,B0
	CALLA	SPAWN_FIRE

CEC_NO_FIRE

CEC_DONE
	MOVKB	25,*A8(OCLRROCKETHIT)	;Time 'til we reset for the next

	MOVE	A2,*A8(OPLAYER),L	;Hang on to this address

	MOVI	100,A1
	CALLA	SCORE			;Explosions are always good for points

CEC_X
	RETS

**************************************************************************
*								         *
* 	PLATE_EXPLOSION_COLL						 *
* 									 *
* 	Collision vector for player explosion against the license plate. *
* 									 *
* 	A0 = Ptr to explosion object					 *
* 	A8 = Ptr to part						 *
*								         *
**************************************************************************
PLATE_EXPLOSION_COLL
	MOVB	*A8(OCHEWEDROCKET),A14	;Did he really take a rocket?
	JRZ	PEC_X			;BR = No, so bail

	CLR	A14
	MOVB	A14,*A8(OCHEWEDROCKET)	;Clear the rocket flag

	MOVE	A0,A5			;Visiting explosion goes here

	SOUNDZ	SND_GUN_FLY		;Make our own explosion sound

	MOVE	*A5(OID),A0,W		;We can find out who did this
	CALLA	POID_TO_PDATA		;by getting the Player's data area.

	MOVI	1000,A1
	CALLA	SCORE			;Explosions are always good for points

	CALLA	OBJ_OFF

	CALLA	COLLS_OFF

	MMTM	SP,B0,B1,B2,B3,B4,B5,B6,B7,B8,B9,B10
	MOVI	180H,A3			;Max Z velocity
	MOVI	30000H,A0		;Max X&Y velocities
	CALLA	PreFrag_Center		;Blow from the center
	MOVI	FRAG_PLATE_FLY,B14	;Use this script
	CALLA	Fragger			;And get it goin' Boy
	MMFM	SP,B0,B1,B2,B3,B4,B5,B6,B7,B8,B9,B10

PEC_X
	RETS

**************************************************************************
*								         *
* 	CRAFT_GUNVECT							 *
* 									 *
* 	Gun Vector for all of the craft parts.  A ding sound will be	 *
* 	made for effect, and that's all.				 *
* 									 *
* 	A2 = Ptr to player hitting the craft				 *
* 	A8 = Ptr to part						 *
*								         *
**************************************************************************
CRAFT_GUNVECT
	CALLA	DGV_FRAG_SPARK		;Spark it up

	MOVB	*A8(OPARTID),A4
	CMPK	NUM_TORSOL,A4		;Sanity check, are we a craft part?
	JRHS	CGV_X			;BR = No

	MOVE	A4,A0
	DEC	A0
	SRL	1,A0
	SLL	5,A0
	ADDI	TAB_METAL_SOUNDS,A0
	MOVE	*A0,A0,L	   	;Grab us a sound from the desk table
	CALLA	ONESND_Z

CGV_X
	RETS

**************************************************************************
*								         *
* 	INCREASE_DAMAGE_LEVEL						 *
* 									 *
* 	Use this routine to increase the damage level on		 *
* 	a given part.							 *
* 									 *
* 	A8 = Ptr to part						 *
*								         *
**************************************************************************
INCREASE_DAMAGE_LEVEL
	MOVB	*A8(ODAMAGE),A14
	CMPK	MAX_DAMAGE_LEVEL,A14
	JRHS	IDL_X
	INC	A14
	MOVB	A14,*A8(ODAMAGE)
IDL_X
	RETS

**************************************************************************
*								         *
* 	A_CHANGE_PAL_VIOLENCE						 *
* 									 *
* 	Anim func to change the palette based on the violence level.	 *
* 									 *
* 	A8 = Ptr to object						 *
* 	AARG+,L = Palette if violence level is high			 *
* 	AARG+,L = Paleete if violence level is med/low			 *
*								         *
**************************************************************************
A_CHANGE_PAL_VIOLENCE
	CALLA	GETAFARG_LONG
	MOVE	@VIOLENCE_LEVEL,A14,W
	DEC	A14
	JAP	CHANGE_PAL		;BR = Violence is high
	CALLA	GETAFARG_LONG		;Get the alternate palette
	JAUC	CHANGE_PAL

**************************************************************************
*								         *
* 		Sounds for Mondor					 *
*								         *
**************************************************************************
SND_HEAD_SHAKE
	.WORD	0F343H,46,0828BH,0	;Rapid head shake
SND_SCREAM
	.WORD	0F342H,62,08284H,0	;Mondor screams
SND_BLOW_BACK
	.WORD	0F342H,26,08294H,0	;Mondor gets blown back
SND_BLOOD_SPRAY
	.WORD	0E300H,60,0A197H,0	;Blood spray from bone stump

NUM_DAMAGE_SNDS	.EQU	6

TAB_DAMAGE_SOUNDS
	.LONG	SND_DAMAGE1,SND_DAMAGE2,SND_DAMAGE3,SND_DAMAGE4
	.LONG	SND_DAMAGE5,SND_DAMAGE6

SND_DAMAGE1
	.WORD	0E242H,21,0A526H,0	;Mondor gets damaged #1
SND_DAMAGE2
	.WORD	0E242H,25,0A523H,0	;Mondor gets damaged #7
SND_DAMAGE3
	.WORD	0E242H,29,0A529H,0	;Mondor gets damaged #3
SND_DAMAGE4
	.WORD	0E242H,40,0A52CH,0	;Mondor gets damaged #4
SND_DAMAGE5
	.WORD	0E242H,29,0A52FH,0	;Mondor gets damaged #5
SND_DAMAGE6
	.WORD	0E242H,40,0A520H,0	;Mondor gets damaged #6
	
SND_FLESH_HIT
	.WORD	0F302H,17,0A1E9H,0	;Flesh Hit on Mondor

SND_PART_PREAMBLE
	.WORD	0F144H,60,0A38BH,0	;Preamble to Mondor's part lost scream
SND_PART_LOST
	.WORD	0F344H,150,08286H,0	;Mondor screams cause he lost a part
SND_FINAL_DEATH
	.WORD	0F345H,521,0829AH,0	;Mondor's final death scream

SND_THRUSTER1
	.WORD	0F101H,1,05186H,0	;Thruster sound, make it a background
SND_THRUSTER2
	.WORD	0F201H,1,05187H,0	;Thruster sound, make it a background

SND_POUND
	.WORD	0F330H,73,0A13BH,0	;Mondor pounds

SND_INTRO_ROAR
	.WORD	0E342H,74,08281H,0	;Introductory ROAR!

SND_GUN_GRAB
	.WORD	0F340H,10,0A389H,0	;Mondor grabs his gun
	
SND_GUN_FLY
	.WORD	0E141H,46,0A3B1H,0	;Gun gets knocked out of hand

;SND_FINAL_EXPLODE1
;	.WORD	0E148H,200,08303H,0	;Final explosion sound, channel 1
;SND_FINAL_EXPLODE2
;	.WORD	0E248H,200,08304H,0	;Final explosion sound, channel 2
;SND_FINAL_EXPLODE3
;	.WORD	0E348H,200,08305H,0	;Final explosion sound, channel 3

SND_FINAL_EXPLODE1
	.WORD	0E148H,88,08303H,0	;Final explosion sound, channel 1
SND_FINAL_EXPLODE2
	.WORD	0E248H,40,0838FH,0	;Final explosion sound, channel 2
SND_FINAL_EXPLODE3
	.WORD	0E348H,88,08390H,0	;Final explosion sound, channel 3

SND_HUH
	.WORD	0E340H,23,08289H,0	;"Huh!?"

;SND_PREASE_TO_ENJOY
;	.WORD	0E349H,143,08280H,0	;"Prease to enjoy, your worst nightmare"
SND_BUTT_HURT
	.WORD	0E34AH,34,0827BH,0	;Manager's ass hurts from fall
SND_GEAR_OUT
	.WORD	0E348H,36,0A1FDH,0	;Mondor's gear comes out
SND_SEAT_BOUNCE
	.WORD	0F342H,27,0A33BH,0	;Manager's seat bounces

;SND_MONDOR_BATTLE
;	.WORD	0F0FDH,1,08005H,0	;Battle Mondor tune

SND_EXPLODE_ON_MONDOR
	.WORD	0F341H,60,0A38DH,0	;Explosion when rocket hits Mondor

NUM_MONDOR_PARTS	.EQU	21

NUM_BODY_PARTS		.EQU	7	;Legs, Arms, Head, Chest

NUM_TORSO_PARTS		.EQU	2	;Number of pieces making up the Torso

MONDOR_INIT
	.byte	NUM_MONDOR_PARTS, 0, 0, 5 ;OBJCNT, PRCCNT, IMGPALCNT, PALCNT
	.long	VESTPAL1,PANPAL1,FHEDcc1,PODS,FLESH1p	;Palettes used
	.word	OID_MONDOR, OM_COLL
;	.LONG	CRAFT_CVECT
	.LONG	DUMCOLL

*
*    .long IMG
*    .word OCTRL, OFLAGS, OZOFF, OPTION_FLAGS
*

	LWWWW	CRFT_SEAT_A, DMAWNZ, 0, 3, OM_COLL|OM_GUNV|OM_CFUNC ;OM_ANIM
	.LONG	CRAFT_SEAT_CVECT
	.LONG	CRAFT_GUNVECT
;	.LONG	ANIM_DROP_IN
	.LONG	C_SEAT_INIT

	LWWWW	CRFT_SEAT_A, DMAWNZ|M_FLIPH, 0, 3, OM_PRVGUNV|OM_CFUNC
	.LONG	C_CRAFT_PART_INIT

NUM_PODL	.EQU	3
	LWWWW	POD_L_A4, DMAWNZ, M_NOSCALE|M_NODISP, 4, OM_PRVGUNV|OM_CFUNC
	.LONG	C_CRAFT_PART_INIT

NUM_PODR	.EQU	4
	LWWWW	POD_L_A4, DMAWNZ|M_FLIPH, M_NOSCALE|M_NODISP, 4, OM_PRVGUNV|OM_CFUNC
	.LONG	C_CRAFT_PART_INIT
	
NUM_FOOTL	.EQU	5	;This part is used for small shake of Mondor
	LWWWW	CRFT_FOOT, DMAWNZ, M_NODISP, 4, OM_PRVGUNV|OM_CFUNC
	.LONG	C_CRAFT_PART_INIT

NUM_FOOTR	.EQU	6	;This part is used for medium shake of Mondor
	LWWWW	CRFT_FOOT, DMAWNZ|M_FLIPH, M_NODISP, 4, OM_PRVGUNV|OM_CFUNC
	.LONG	C_CRAFT_PART_INIT

NUM_PIPEL	.EQU	7	;This part is used for BIG shake of Mondor
	LWWWW	CRFT_FOOT_A, DMAWNZ, M_NOSCALE|M_NODISP, 5, OM_PRVGUNV|OM_CFUNC
	.LONG	C_CRAFT_PART_INIT

	LWWWW	CRFT_FOOT_A, DMAWNZ|M_FLIPH, M_NOSCALE|M_NODISP, 5, OM_PRVGUNV|OM_CFUNC
	.LONG	C_CRAFT_PART_INIT

NUM_PLATE	.EQU	9
	LWWWW	PLATOUT1, DMAWNZ, M_NOSCALE|M_NODISP, 2, OM_COLL|OM_GUNV|OM_CFUNC
	.LONG	PLATE_CVECT
	.LONG	METAL_GUNVECT
	.LONG	C_PLATE_PART_INIT

NUM_TORSOL	.EQU	10
	LWWWW	HELMON1_01A, DMAWNZ, M_NODISP|M_NOSCALE|M_NOSHADOW, 0, OM_COLL|OM_GUNV|OM_ANIM|OM_CFUNC
	.LONG	MONDOR_CHEST_CVECT
	.LONG	MONDOR_GUNVECT
	.LONG	ANIM_JOSH_MORPH
	.LONG	C_MONDOR_PART_INIT

NUM_TORSOR	.EQU	11
	LWWWW	HELMON1_01B, DMAWNZ, M_NODISP|M_NOSCALE|M_NOSHADOW, 0, OM_COLL|OM_PRVGUNV|OM_CFUNC
	.LONG	MONDOR_CHEST_CVECT
	.LONG	C_MONDOR_PART_INIT

NUM_LEGL	EQU	12
	LWWWW	HELMON1_01C, DMAWNZ, M_NODISP|M_NOSCALE|M_NOSHADOW, -1, OM_COLL|OM_PRVGUNV|OM_CFUNC
	.LONG	MONDOR_CVECT
	.LONG	C_MONDOR_PART_INIT

NUM_LEGR	.EQU	13
	LWWWW	HELMON1_01D, DMAWNZ, M_NODISP|M_NOSCALE|M_NOSHADOW, -1, OM_COLL|OM_PRVGUNV|OM_CFUNC
	.LONG	MONDOR_CVECT
	.LONG	C_MONDOR_PART_INIT

NUM_ARML	.EQU	14
	LWWWW	HELMON1_01E, DMAWNZ, M_NODISP|M_NOSCALE|M_NOSHADOW, 1, OM_COLL|OM_PRVGUNV|OM_CFUNC
	.LONG	MONDOR_CVECT
	.LONG	C_MONDOR_PART_INIT

NUM_ARMR	.EQU	15
	LWWWW	HELMON1_01E, DMAWNZ, M_NODISP|M_NOSCALE|M_NOSHADOW, 1, OM_COLL|OM_PRVGUNV|OM_CFUNC
	.LONG	MONDOR_CVECT
	.LONG	C_MONDOR_PART_INIT

NUM_HEAD	.EQU	16
	LWWWW	HELMON1_01E, DMAWNZ, M_NODISP|M_NOSCALE|M_NOSHADOW, -2, OM_COLL|OM_PRVGUNV|OM_CFUNC
	.LONG	MONDOR_CVECT
	.LONG	C_MONDOR_PART_INIT

	LWWWW	HELMON1_01E, DMAWNZ|M_FLIPH, M_NODISP|M_NOSCALE|M_NOSHADOW, -3, OM_COLL|OM_GUNV
	.LONG	0,0

	LWWWW	HELMON1_01E, DMAWNZ|M_FLIPH, M_NODISP|M_NOSCALE|M_NOSHADOW, -1, OM_COLL
	.LONG	DUMCOLL

	LWWWW	HELMON1_01E, DMAWNZ|M_FLIPH, M_NODISP|M_NOSCALE|M_NOSHADOW, -1, OM_COLL
	.LONG	DUMCOLL

NUM_ABONEL	.EQU	20
	LWWWW	BONE_STUMP, DMAWNZ, M_NODISP|M_NOSHADOW, 2, OM_COLL
	.LONG	DUMCOLL

NUM_ABONER	.EQU	21
	LWWWW	BONE_STUMP, DMAWNZ|M_FLIPH, M_NODISP|M_NOSHADOW, 2, OM_COLL
	.LONG	DUMCOLL

*
* Use for dropping in Mondor on the seat
*
	.if 0
NUM_TORSOL	.EQU	10
	LWWWW	TORSO_0, DMAWNZ, 0, 0, OM_COLL|OM_GUNV|OM_CFUNC
	.LONG	MONDOR_CHEST_CVECT
	.LONG	MONDOR_GUNVECT
	.LONG	C_MONDOR_PART_INIT

NUM_TORSOR	.EQU	11
	LWWWW	TORSO_0, DMAWNZ|M_FLIPH, 0, 0, OM_COLL|OM_PRVGUNV|OM_CFUNC
	.LONG	MONDOR_CHEST_CVECT
	.LONG	C_MONDOR_PART_INIT

NUM_LEGL	EQU	12
	LWWWW	LEG_A, DMAWNZ, 0, -1, OM_COLL|OM_PRVGUNV|OM_CFUNC
	.LONG	MONDOR_CVECT
	.LONG	C_MONDOR_PART_INIT

NUM_LEGR	.EQU	13
	LWWWW	LEG_A, DMAWNZ|M_FLIPH, 0, -1, OM_COLL|OM_PRVGUNV|OM_CFUNC
	.LONG	MONDOR_CVECT
	.LONG	C_MONDOR_PART_INIT
NUM_ARML	.EQU	14
	LWWWW	L_IDL_A_1, DMAWNZ, M_NOPARTANI, 1, OM_COLL|OM_ANIM|OM_PRVGUNV|OM_CFUNC
	.LONG	MONDOR_CVECT
	.LONG	AAIDLE_A
	.LONG	C_MONDOR_PART_INIT
NUM_ARMR	.EQU	15
	LWWWW	L_IDL_A_1, DMAWNZ|M_FLIPH, M_NOPARTANI, 1, OM_COLL|OM_ANIM|OM_PRVGUNV|OM_CFUNC
	.LONG	MONDOR_CVECT
	.LONG	AAIDLE_A
	.LONG	C_MONDOR_PART_INIT

NUM_HEAD	.EQU	16
	LWWWW	H_IDL_A_1, DMAWNZ, 0, -2, OM_COLL|OM_ANIM|OM_PRVGUNV|OM_CFUNC
	.LONG	MONDOR_CVECT
	.LONG	ANIM_HEAD_INTRO
	.LONG	C_MONDOR_PART_INIT

	LWWWW	H_IDLGLA1, DMAWNZ, M_NOSHADOW, -3, OM_COLL|OM_GUNV
	.LONG	0,0

	LWWWW	TORSO_2, DMAWNZ, M_NODISP, -1, OM_COLL
	.LONG	DUMCOLL

	LWWWW	TORSO_1, DMAWNZ, M_NODISP, -1, OM_COLL
	.LONG	DUMCOLL

	.endif

**************************************************************************
*								         *
* 			Animation tables				 *
* 			________________				 *
* 									 *
* 		Each arm and head animation has four scripts.		 *
* 		One for each damage level.  They are indexed		 *
* 		via a table and the ODAMAGE variable in the		 *
* 		object field						 *
*								         *
**************************************************************************

*
*Animation script to keep tabs on the velocity and movement boundries
*
ANIM_VELOCITY_WATCH
	LWL	1,1|AFunc,A_VELOCITY_WATCH
	.LONG	0

*
*Handle Mondor's craft movement
*
ANIM_MOVEMENT
	LWL	1,1|AFunc,A_MOVE_AROUND
	.LONG	0

*
*Animation number equates, used to tell decision funcs where animation
*just came from
*
ANUM_IDLE	.EQU	0

ANUM_666	.EQU	1
ANUM_FIST	.EQU	2
ANUM_GET	.EQU	3
ANUM_PNT	.EQU	4
ANUM_THROW	.EQU	5


*
*HEAD animation numbers.
*
ANUM_NO		.EQU	1
ANUM_YES	.EQU	2
ANUM_BREATHE_FIRE .EQU	3
ANUM_SCREAM	.EQU	4
ANUM_SCREAM_LT	.EQU	5
ANUM_SCREAM_RT	.EQU	6
ANUM_SHAKE	.EQU	7
ANUM_TALK	.EQU	8
ANUM_LOOK	.EQU	9

ACTION_HEAD_NUMS .EQU	4

LAST_HEAD_NUM	.EQU	10


*
* Table of each arm action
*
ACTIONS_ARM
	.LONG	ANIM_ARM_IDLE,ANIM_ARM_666,ANIM_ARM_FIST,ANIM_ARM_GET
	.LONG	ANIM_ARM_PNT,ANIM_ARM_THROW

*
*ARM AT REST
*

ANIM_ARM_INIT
	LWLL	1,30|AFunc,A_AnimGo+2,AAIDLE_A

ANIM_ARM_IDLE
	.LONG	AAIDLE_A,AAIDLE_A,AAIDLE_C,AAIDLE_D

AAIDLE_A
	LWLL	L_IDL_A_1,1|AFunc,A_CHANGE_PAL+2,FLESH1p
	LWL	1,1|AFunc,A_SELECT_ARM_IDLE_TIME
	LW	1,0
	LWLW	1,1|AFunc,A_ARM_DECISION+1,ANUM_IDLE
;AAIDLE_B
;	LWL	L_IDL_B_1,1|AFunc,A_SELECT_ARM_IDLE_TIME
;	LW	1,0
;	LWLW	1,1|AFunc,A_ARM_DECISION+1,ANUM_IDLE
AAIDLE_C
	LWLLL	L_IDL_C_1,1|AFunc,A_CHANGE_PAL_VIOLENCE+4,FLESH2p,FLESH2pG
	LWL	1,1|AFunc,A_SELECT_ARM_IDLE_TIME
	LW	1,0
	LWLW	1,1|AFunc,A_ARM_DECISION+1,ANUM_IDLE
AAIDLE_D
	LWLLL	L_IDL_D_1,1|AFunc,A_CHANGE_PAL_VIOLENCE+4,FLESH3p,FLESH3pG
	LWL	1,1|AFunc,A_SELECT_ARM_IDLE_TIME
	LW	1,0
	LWLW	1,1|AFunc,A_ARM_DECISION+1,ANUM_IDLE

*
*INTERNATIONAL SIGN OF THE DEVIL
*
ANIM_ARM_666
	.LONG	AA666_A,AA666_A,AA666_C,AA666_D

AA666_A
	LW	L_666_A_1,5
	LW	L_666_A_2,5
	LW	L_666_A_3,5
	LW	L_666_A_4,9
	LW	L_666_A_3,9
	LW	L_666_A_4,9
	LW	L_666_A_3,9
	LW	L_666_A_4,9
	LW	L_666_A_3,5
	LW	L_666_A_2,5
	LW	L_666_A_1,5
	LWLW	1,1|AFunc,A_ARM_DECISION+1,ANUM_666
	
;AA666_B
;	LW	L_666_B_1,5
;	LW	L_666_B_2,5
;	LW	L_666_B_3,5
;	LW	L_666_B_4,9
;	LW	L_666_B_3,9
;	LW	L_666_B_4,9
;	LW	L_666_B_3,9
;	LW	L_666_B_4,9
;	LW	L_666_B_3,5
;	LW	L_666_B_2,5
;	LW	L_666_B_1,5
;	LWLW	1,1|AFunc,A_ARM_DECISION+1,ANUM_666

AA666_C
	LWLLL	L_666_C_1,5|AFunc,A_CHANGE_PAL_VIOLENCE+4,FLESH2p,FLESH2pG
	LW	L_666_C_2,5
	LW	L_666_C_3,5
	LW	L_666_C_4,9
	LW	L_666_C_3,9
	LW	L_666_C_4,9
	LW	L_666_C_3,9
	LW	L_666_C_4,9
	LW	L_666_C_3,5
	LW	L_666_C_2,5
	LW	L_666_C_1,5
	LWLW	1,1|AFunc,A_ARM_DECISION+1,ANUM_666

AA666_D
	LWLLL	L_666_D_1,5|AFunc,A_CHANGE_PAL_VIOLENCE+4,FLESH3p,FLESH3pG
	LW	L_666_D_2,5
	LW	L_666_D_3,5
	LW	L_666_D_4,9
	LW	L_666_D_3,9
	LW	L_666_D_4,9
	LW	L_666_D_3,9
	LW	L_666_D_4,9
	LW	L_666_D_3,5
	LW	L_666_D_2,5
	LW	L_666_D_1,5
	LWLW	1,1|AFunc,A_ARM_DECISION+1,ANUM_666

*
*WHY I OUGHTTA SOCK YA ONE RIGHT IN THE KISSER
*
ANIM_ARM_FIST
	.LONG	AAFIST_A,AAFIST_A,AAFIST_C,AAFIST_D

AAFIST_A
	LW	L_FST_A_1,5
	LW	L_FST_A_2,5
	LW	L_FST_A_3,5
	LW	L_FST_A_4,5
	LW	L_FST_A_5,9
	LW	L_FST_A_4,9
	LW	L_FST_A_5,9
	LW	L_FST_A_3,5
	LW	L_FST_A_2,5
	LW	L_FST_A_1,5
	LWLW	1,1|AFunc,A_ARM_DECISION+1,ANUM_FIST

;AAFIST_B
;	LW	L_FST_B_1,5
;	LW	L_FST_B_2,5
;	LW	L_FST_B_3,5
;	LW	L_FST_B_4,5
;	LW	L_FST_B_5,9
;	LW	L_FST_B_4,9
;	LW	L_FST_B_5,9
;	LW	L_FST_B_3,5
;	LW	L_FST_B_2,5
;	LW	L_FST_B_1,5
;	LWLW	1,1|AFunc,A_ARM_DECISION+1,ANUM_FIST

AAFIST_C
	LWLLL	L_FST_C_1,5|AFunc,A_CHANGE_PAL_VIOLENCE+4,FLESH2p,FLESH2pG
	LW	L_FST_C_2,5
	LW	L_FST_C_3,5
	LW	L_FST_C_4,5
	LW	L_FST_C_5,9
	LW	L_FST_C_4,9
	LW	L_FST_C_5,9
	LW	L_FST_C_3,5
	LW	L_FST_C_2,5
	LW	L_FST_C_1,5
	LWLW	1,1|AFunc,A_ARM_DECISION+1,ANUM_FIST

AAFIST_D
	LWLLL	L_FST_D_1,5|AFunc,A_CHANGE_PAL_VIOLENCE+4,FLESH3p,FLESH3pG
	LW	L_FST_D_2,5
	LW	L_FST_D_3,5
	LW	L_FST_D_4,5
	LW	L_FST_D_5,9
	LW	L_FST_D_4,9
	LW	L_FST_D_5,9
	LW	L_FST_D_3,5
	LW	L_FST_D_2,5
	LW	L_FST_D_1,5
	LWLW	1,1|AFunc,A_ARM_DECISION+1,ANUM_FIST

*
*GRENADE THROW
*
ANIM_ARM_THROW
	.LONG	AATHROW_A,AATHROW_A,AATHROW_C,AATHROW_D

AATHROW_A
	LWLWW	L_THR_A_1,5|AFunc,A_Set_Rel_Byte_Head+2,OTHROWING_BOMB,1
	LW	L_THR_A_2,5
	LW	L_THR_A_3,5
	LW	L_THR_A_4,5
	LW	L_THR_A_5,5
	LW	L_THR_A_6,9
	LW	L_THR_A_7,4
	LWLLWW	L_THR_A_8,4|AFunc,A_SPAWN_PROJECTILE+4,GRENADE_INIT,-88,-44
	LW	L_THR_A_9,4
	LWLW	1,1|AFunc,A_ARM_DECISION+1,ANUM_THROW

;AATHROW_B
;	LWLWW	L_THR_B_1,5|AFunc,A_Set_Rel_Byte_Head+2,OTHROWING_BOMB,1
;	LW	L_THR_B_2,5
;	LW	L_THR_B_3,5
;	LW	L_THR_B_4,5
;	LW	L_THR_B_5,5
;	LW	L_THR_B_6,9
;	LW	L_THR_B_7,4
;	LWLLWW	L_THR_B_8,4|AFunc,A_SPAWN_PROJECTILE+4,GRENADE_INIT,-88,-44
;	LW	L_THR_B_9,4
;	LWLW	1,1|AFunc,A_ARM_DECISION+1,ANUM_THROW

AATHROW_C
	LWLWW	1,1|AFunc,A_Set_Rel_Byte_Head+2,OTHROWING_BOMB,1
	LWLLL	L_THR_C_1,4|AFunc,A_CHANGE_PAL_VIOLENCE+4,FLESH2p,FLESH2pG
	LW	L_THR_C_2,5
	LW	L_THR_C_3,5
	LW	L_THR_C_4,5
	LW	L_THR_C_5,5
	LW	L_THR_C_6,9
	LW	L_THR_C_7,4
	LWLLWW	L_THR_C_8,4|AFunc,A_SPAWN_PROJECTILE+4,GRENADE_INIT,-88,-44
	LW	L_THR_C_9,4
	LWLW	1,1|AFunc,A_ARM_DECISION+1,ANUM_THROW

AATHROW_D
	LWLWW	1,1|AFunc,A_Set_Rel_Byte_Head+2,OTHROWING_BOMB,1
	LWLLL	L_THR_D_1,4|AFunc,A_CHANGE_PAL_VIOLENCE+4,FLESH3p,FLESH3pG
	LW	L_THR_D_2,5
	LW	L_THR_D_3,5
	LW	L_THR_D_4,5
	LW	L_THR_D_5,5
	LW	L_THR_D_6,9
	LW	L_THR_D_7,4
	LWLLWW	L_THR_D_8,4|AFunc,A_SPAWN_PROJECTILE+4,GRENADE_INIT,-88,-44
	LW	L_THR_D_9,4
	LWLW	1,1|AFunc,A_ARM_DECISION+1,ANUM_THROW


*
*GET THIS BOYEEEEE!
*
ANIM_ARM_GET
	.LONG	AAGET_A,AAGET_A,AAGET_C,AAGET_D

AAGET_A
	LW	L_THR_A_1,5
	LW	L_THR_A_2,5
	LW	L_THR_A_3,5
	LW	L_THR_A_4,5
	LW	L_THR_A_5,5
	LWLL	L_THR_A_6,15|AFunc,A_SOUNDZ+2,SND_GUN_GRAB
	LWLL	R_GN2_A_1,6|AFunc,A_CHANGE_PAL+2,GARMS1p
	LW	R_GN2_A_2,6
	LWL	R_GN2_A_3,6|AFunc,A_INITIALIZE_FIRING
	LW	R_GN2_A_4,6

*Common shoot animation hook
AAGET_SHOOT
	LW	1,6
AAGET_SHOOTER
	LWL	1,5|AFunc,A_RANDOM_RAPID_COUNT
AAGET_RAPID_FIRE
	LWLWWWW	1,7|AFunc,A_ARM_FIRE_FNC+4,-81,-45,-81,-54
	LWLL	1,1|AFunc,A_ARM_RAPIDFIRE_DECISION+2,AAGET_RAPID_FIRE
	LWLWW	1,1|AFunc,A_RAND_AnimSLP+2,7,20
	LW	1,0
	LWLL	1,1|AFunc,A_AnimFrm+2,AAGET_SHOOTER

;AAGET_B
;	LW	L_THR_B_1,5
;	LW	L_THR_B_2,5
;	LW	L_THR_B_3,5
;	LW	L_THR_B_4,5
;	LW	L_THR_B_5,5
;	LWLL	L_THR_B_6,15|AFunc,A_SOUNDZ+2,SND_GUN_GRAB
;	LW	R_GN2_B_1,6
;	LW	R_GN2_B_2,6
;	LWL	R_GN2_B_3,6|AFunc,A_INITIALIZE_FIRING
;	LWLL	R_GN2_B_4,6|AFunc,A_AnimFrm+2,AAGET_SHOOT

AAGET_C
	LWLLL	L_THR_C_1,5|AFunc,A_CHANGE_PAL_VIOLENCE+4,FLESH2p,FLESH2pG
	LW	L_THR_C_2,5
	LW	L_THR_C_3,5
	LW	L_THR_C_4,5
	LW	L_THR_C_5,5
	LWLL	L_THR_C_6,15|AFunc,A_SOUNDZ+2,SND_GUN_GRAB
	LWLLL	R_GN2_C_1,6|AFunc,A_CHANGE_PAL_VIOLENCE+4,GARMS2p,GARMS2pG
	LW	R_GN2_C_2,6
	LWL	R_GN2_C_3,6|AFunc,A_INITIALIZE_FIRING
	LWLL	R_GN2_C_4,6|AFunc,A_AnimFrm+2,AAGET_SHOOT

AAGET_D
	LWLLL	L_THR_D_1,5|AFunc,A_CHANGE_PAL_VIOLENCE+4,FLESH3p,FLESH3pG
	LW	L_THR_D_2,5
	LW	L_THR_D_3,5
	LW	L_THR_D_4,5
	LW	L_THR_D_5,5
	LWLL	L_THR_D_6,15|AFunc,A_SOUNDZ+2,SND_GUN_GRAB
	LWLLL	R_GN2_D_1,6|AFunc,A_CHANGE_PAL_VIOLENCE+4,GARMS3p,GARMS3pG
	LW	R_GN2_D_2,6
	LWL	R_GN2_D_3,6|AFunc,A_INITIALIZE_FIRING
	LWLL	R_GN2_D_4,6|AFunc,A_AnimFrm+2,AAGET_SHOOT

*
*POUND HAND
*
ANIM_ARM_POUND
	.LONG	AAPOUND_A,AAPOUND_A,AAPOUND_C,AAPOUND_D

AAPOUND_A
	LWLW	1,1|AFunc,A_Set_AnimLoop+1,3
	LWL	1,1|AFunc,A_POUND_SCREAM
	LWLL	1,1|AFunc,A_AnimGo+2,AAPOUND_A_LOOP
AAPOUND_A_LOOP
	LW	L_FST_A_7,3
	LW	L_THR_A_3,3
	LW	L_THR_A_4,3
	LW	L_THR_A_5,6
	LW	L_THR_A_4,2
	LW	L_THR_A_3,2
	LW	L_FST_A_7,2
	LWL	L_FST_A_6,6|AFunc,A_POUND_FUNC

	LWLW	1,1|AFunc,A_ARM_DECISION+1,ANUM_GET

;AAPOUND_B
;	LWLW	1,1|AFunc,A_Set_AnimLoop+1,3
;	LWL	1,1|AFunc,A_POUND_SCREAM
;	LWLL	1,1|AFunc,A_AnimGo+2,AAPOUND_B_LOOP
;AAPOUND_B_LOOP
;	LW	L_FST_B_7,3
;	LW	L_THR_B_3,3
;	LW	L_THR_B_4,3
;	LW	L_THR_B_5,6
;	LW	L_THR_B_4,2
;	LW	L_THR_B_3,2
;	LW	L_FST_B_7,2
;	LWL	L_FST_B_6,6|AFunc,A_POUND_FUNC

;	LWLW	1,1|AFunc,A_ARM_DECISION+1,ANUM_GET

AAPOUND_C
	LWLW	1,1|AFunc,A_Set_AnimLoop+1,3
	LWL	1,1|AFunc,A_POUND_SCREAM
	LWLLL	L_FST_C_7,1|AFunc,A_CHANGE_PAL_VIOLENCE+4,FLESH2p,FLESH2pG
	LWLL	1,1|AFunc,A_AnimGo+2,AAPOUND_C_LOOP
AAPOUND_C_LOOP
	LW	L_FST_C_7,3
	LW	L_THR_C_3,3
	LW	L_THR_C_4,3
	LW	L_THR_C_5,6
	LW	L_THR_C_4,2
	LW	L_THR_C_3,2
	LW	L_FST_C_7,2
	LWL	L_FST_C_6,6|AFunc,A_POUND_FUNC

	LWLW	1,1|AFunc,A_ARM_DECISION+1,ANUM_GET

AAPOUND_D
	LWLW	1,1|AFunc,A_Set_AnimLoop+1,3
	LWL	1,1|AFunc,A_POUND_SCREAM
	LWLLL	L_FST_D_7,1|AFunc,A_CHANGE_PAL_VIOLENCE+4,FLESH3p,FLESH3pG
	LWLL	1,1|AFunc,A_AnimGo+2,AAPOUND_D_LOOP
AAPOUND_D_LOOP
	LW	L_FST_D_7,3
	LW	L_THR_D_3,3
	LW	L_THR_D_4,3
	LW	L_THR_D_5,6
	LW	L_THR_D_4,2
	LW	L_THR_D_3,2
	LW	L_FST_D_7,2
	LWL	L_FST_D_6,6|AFunc,A_POUND_FUNC

	LWLW	1,1|AFunc,A_ARM_DECISION+1,ANUM_GET


*
*POINT IT OUT TO THE PLAYER
*
ANIM_ARM_PNT
	.LONG	AAPNT_A,AAPNT_A,AAPNT_A,AAPNT_A

AAPNT_A
	LWL	1,1|AFunc,A_POINT_CHECK
	LW	L_PNT_A_1,5
	LW	L_PNT_A_2,5
	LW	L_PNT_A_3,9
	LW	L_PNT_A_2,9
	LW	L_PNT_A_3,9
	LW	L_PNT_A_2,5
	LW	L_PNT_A_1,5
	LWLW	L_IDL_A_1,1|AFunc,A_ARM_DECISION+1,ANUM_PNT


*
*LEG AT REST
*
ANIM_LEG_IDLE
	.LONG	ALIDLE_A,ALIDLE_B,ALIDLE_C,ALIDLE_D

ALIDLE_A
	LWL	LEG_A,1|AFunc,PULL_ANIM
ALIDLE_B
	LWLLL	LEG_B,1|AFunc,A_CHANGE_PAL_VIOLENCE+4,LEG1p,LEG1pG
	LWL	1,1|AFunc,PULL_ANIM
ALIDLE_C
	LWLLL	LEG_C,1|AFunc,A_CHANGE_PAL_VIOLENCE+4,LEG2p,LEG2pG
	LWL	1,1|AFunc,PULL_ANIM
ALIDLE_D
	LWLLL	LEG_D,1|AFunc,A_CHANGE_PAL_VIOLENCE+4,LEG3p,LEG3pG
	LWL	1,1|AFunc,PULL_ANIM


*This is the intro sequence for Mondors head
ANIM_HEAD_INTRO
	LW	1,70
	LWL	1,1|AFunc,A_HEAD_INTRO
	LWLW	1,1|AFunc,A_HEAD_DECISION+1,ANUM_IDLE

*
* Idle frames for the head
*
ANIM_HEAD_IDLE
	.LONG	AHIDLE_A,AHIDLE_A,AHIDLE_C,AHIDLE_D

AHIDLE_A
	LWL	H_IDL_A_1,1|AMulti|AFunc,A_SELECT_HEAD_IDLE_TIME
	LW	H_IDLGLA1,1

	LWLL	1,1|AFunc,A_AnimGo+2,AHIDLE_LOOP
AHIDLE_B
	LWL	H_IDL_A_1,1|AFunc,A_SELECT_HEAD_IDLE_TIME
	LWLL	1,1|AFunc,A_AnimGo+2,AHIDLE_LOOP
AHIDLE_C
	LWLLL	H_IDL_C_1,1|AFunc,A_CHANGE_PAL_VIOLENCE+4,FHEDcc2,FHEDcc2G
	LWL	1,1|AFunc,A_SELECT_HEAD_IDLE_TIME
	LWLL	1,1|AFunc,A_AnimGo+2,AHIDLE_LOOP
AHIDLE_D
	LWLLL	H_IDL_D_1,1|AFunc,A_CHANGE_PAL_VIOLENCE+4,FHEDcc3,FHEDcc3G
	LWL	1,1|AFunc,A_SELECT_HEAD_IDLE_TIME
	LWLL	1,1|AFunc,A_AnimGo+2,AHIDLE_LOOP
AHIDLE_LOOP
	LWLW	1,1|AFunc,A_HEAD_DECISION+1,ANUM_IDLE
	.LONG	0

SCREAM_TABLE
	.LONG	ANIM_HEAD_SCREAM,ANIM_HEAD_SCREAM_LEFT,ANIM_HEAD_SCREAM_RIGHT
*
* Mondor SCREAMS
*
ANIM_HEAD_SCREAM
	.LONG	AHSCREAM_A,AHSCREAM_B,AHSCREAM_C,AHSCREAM_D

AHSCREAM_A
	LWL	1,1|AFunc,A_SCREAM_SND

	LW	H_SCM_A_1,1|AMulti
	LW	H_SCMGLA1,4

	LW	H_SCM_A_2,1|AMulti
	LW	H_SCMGLA2,4

AHSA_LOOP
	LWLL	H_SCM_A_3,1|AMulti|AFunc,A_SCREAM_HOLD+2,AHSA_LOOP
	LW	H_SCMGLA3,1

	LW	H_SCM_A_2,1|AMulti
	LW	H_SCMGLA2,4

	LW	H_SCM_A_1,1|AMulti
	LW	H_SCMGLA1,3

	LWLW	1,1|AFunc,A_HEAD_DECISION+1,ANUM_SCREAM

AHSCREAM_B
	LWL	1,1|AFunc,A_SCREAM_SND
	LW	H_SCM_A_1,4
	LW	H_SCM_A_2,4
AHSB_LOOP
	LWLL	H_SCM_A_3,1|AFunc,A_SCREAM_HOLD+2,AHSB_LOOP
	LW	H_SCM_A_2,4
	LW	H_SCM_A_1,3
	LWLW	1,1|AFunc,A_HEAD_DECISION+1,ANUM_SCREAM

AHSCREAM_C
	LWL	1,1|AFunc,A_SCREAM_SND
	LW	H_SCM_C_1,4
	LW	H_SCM_C_2,4
AHSC_LOOP
	LWLL	H_SCM_C_3,1|AFunc,A_SCREAM_HOLD+2,AHSC_LOOP
	LW	H_SCM_C_2,4
	LW	H_SCM_C_1,3
	LWLW	1,1|AFunc,A_HEAD_DECISION+1,ANUM_SCREAM

AHSCREAM_D
	LWL	1,1|AFunc,A_SCREAM_SND
	LW	H_SCM_D_1,4
	LW	H_SCM_D_2,4
AHSD_LOOP
	LWLL	H_SCM_D_3,1|AFunc,A_SCREAM_HOLD+2,AHSD_LOOP
	LW	H_SCM_D_2,4
	LW	H_SCM_D_1,3
	LWLW	1,1|AFunc,A_HEAD_DECISION+1,ANUM_SCREAM

*
* Mondor SCREAMS to our left
*
ANIM_HEAD_SCREAM_LEFT
	.LONG	AHSCREAML_A,AHSCREAML_B,AHSCREAML_C,AHSCREAML_D

AHSCREAML_A
	LWL	1,1|AFunc,A_SCREAM_SND
	LW	H_SCL_A_1,1|AMulti
	LW	H_SCLGLA1,4

	LW	H_SCL_A_2,1|AMulti
	LW	H_SCLGLA2,4

	LW	H_SCL_A_3,1|AMulti
	LW	H_SCLGLA3,4

AHSLA_LOOP
	LWLL	H_SCL_A_4,1|AMulti|AFunc,A_SCREAM_HOLD+2,AHSLA_LOOP
	LW	H_SCLGLA4,1

	LW	H_SCL_A_3,1|AMulti
	LW	H_SCLGLA3,4

	LW	H_SCL_A_2,1|AMulti
	LW	H_SCLGLA2,4

	LW	H_SCL_A_1,1|AMulti
	LW	H_SCLGLA1,3

	LWLW	1,1|AFunc,A_HEAD_DECISION+1,ANUM_SCREAM_LT

AHSCREAML_B
	LWL	1,1|AFunc,A_SCREAM_SND
	LW	H_SCL_A_1,4
	LW	H_SCL_A_2,4
	LW	H_SCL_A_3,4
AHSLB_LOOP
	LWLL	H_SCL_A_4,1|AFunc,A_SCREAM_HOLD+2,AHSLB_LOOP
	LW	H_SCL_A_3,4
	LW	H_SCL_A_2,4
	LW	H_SCL_A_1,3
	LWLW	1,1|AFunc,A_HEAD_DECISION+1,ANUM_SCREAM_LT

AHSCREAML_C
	LWL	1,1|AFunc,A_SCREAM_SND
	LW	H_SCL_C_1,4
	LW	H_SCL_C_2,4
	LW	H_SCL_C_3,4
AHSLC_LOOP
	LWLL	H_SCL_C_4,1|AFunc,A_SCREAM_HOLD+2,AHSLC_LOOP
	LW	H_SCL_C_3,4
	LW	H_SCL_C_2,4
	LW	H_SCL_C_1,3
	LWLW	1,1|AFunc,A_HEAD_DECISION+1,ANUM_SCREAM_LT

AHSCREAML_D
	LWL	1,1|AFunc,A_SCREAM_SND
	LW	H_SCL_D_1,4
	LW	H_SCL_D_2,4
	LW	H_SCL_D_3,4
AHSLD_LOOP
	LWLL	H_SCL_D_4,1|AFunc,A_SCREAM_HOLD+2,AHSLD_LOOP
	LW	H_SCL_D_3,4
	LW	H_SCL_D_2,4
	LW	H_SCL_D_1,3
	LWLW	1,1|AFunc,A_HEAD_DECISION+1,ANUM_SCREAM_LT

*
* Mondor SCREAMS to our right
*
ANIM_HEAD_SCREAM_RIGHT
	.LONG	AHSCREAMR_A,AHSCREAMR_B,AHSCREAMR_C,AHSCREAMR_D

AHSCREAMR_A
	LWL	1,1|AFunc,A_SCREAM_SND
	LWW	H_SCL_A_1,1|AMulti|AFlip,M_FLIPH
	LW	H_SCLGLA1,4

	LW	H_SCL_A_2,1|AMulti
	LW	H_SCLGLA2,4

	LW	H_SCL_A_3,1|AMulti
	LW	H_SCLGLA3,4
AHSRA_LOOP
	LWLL	H_SCL_A_4,1|AMulti|AFunc,A_SCREAM_HOLD+2,AHSRA_LOOP
	LW	H_SCLGLA4,1

	LW	H_SCL_A_3,1|AMulti
	LW	H_SCLGLA3,4

	LW	H_SCL_A_2,1|AMulti
	LW	H_SCLGLA2,4

	LW	H_SCL_A_1,1|AMulti
	LW	H_SCLGLA1,3

	LWWLW	H_IDL_A_1,1|AFlip|AFunc,0,A_HEAD_DECISION+1,ANUM_SCREAM_RT

AHSCREAMR_B
	LWL	1,1|AFunc,A_SCREAM_SND
	LWW	H_SCL_A_1,4|AFlip,M_FLIPH
	LW	H_SCL_A_2,4
	LW	H_SCL_A_3,4
AHSRB_LOOP
	LWLL	H_SCL_A_4,1|AFunc,A_SCREAM_HOLD+2,AHSRB_LOOP
	LW	H_SCL_A_3,4
	LW	H_SCL_A_2,4
	LW	H_SCL_A_1,3
	LWWLW	H_IDL_A_1,1|AFlip|AFunc,0,A_HEAD_DECISION+1,ANUM_SCREAM_RT

AHSCREAMR_C
	LWL	1,1|AFunc,A_SCREAM_SND
	LWW	H_SCL_C_1,4|AFlip,M_FLIPH
	LW	H_SCL_C_2,4
	LW	H_SCL_C_3,4
AHSRC_LOOP
	LWLL	H_SCL_C_4,1|AFunc,A_SCREAM_HOLD+2,AHSRC_LOOP
	LW	H_SCL_C_3,4
	LW	H_SCL_C_2,4
	LW	H_SCL_C_1,3
	LWWLW	H_IDL_C_1,1|AFlip|AFunc,0,A_HEAD_DECISION+1,ANUM_SCREAM_RT

AHSCREAMR_D
	LWL	1,1|AFunc,A_SCREAM_SND
	LWW	H_SCL_D_1,4|AFlip,M_FLIPH
	LW	H_SCL_D_2,4
	LW	H_SCL_D_3,4
AHSRD_LOOP
	LWLL	H_SCL_D_4,1|AFunc,A_SCREAM_HOLD+2,AHSRD_LOOP
	LW	H_SCL_D_3,4
	LW	H_SCL_D_2,4
	LW	H_SCL_D_1,3
	LWWLW	H_IDL_D_1,1|AFlip|AFunc,0,A_HEAD_DECISION+1,ANUM_SCREAM_RT

*
*Animations for Mondor talking
*
ANIM_TALK
	.LONG	ATALK_TT_A, ATALK_TT_B, ATALK_TT_C, ATALK_TT_D

ATALK_TT_A
	LW	1,0
	LWLL	1,1|AFunc,A_START_TALKIN+2,ATTT_A_LOOP
ATTT_A_LOOP
	LWL	H_SCM_A_1,1|AMulti|AFunc,A_TALK_NEXT
	LW	H_SCMGLA1,0

	LWL	H_IDL_A_1,1|AMulti|AFunc,A_TALK_END
	LW	H_IDLGLA1,0

	LWLW	1,1|AFunc,A_HEAD_DECISION+1,ANUM_TALK

ATALK_TT_B
	LW	1,0
	LWLL	1,1|AFunc,A_START_TALKIN+2,ATTT_B_LOOP
ATTT_B_LOOP
	LWL	H_SCM_A_1,0|AFunc,A_TALK_NEXT
	LWL	H_IDL_A_1,0|AFunc,A_TALK_END
	LWLW	1,1|AFunc,A_HEAD_DECISION+1,ANUM_TALK

ATALK_TT_C
	LW	1,0
	LWLL	1,1|AFunc,A_START_TALKIN+2,ATTT_C_LOOP
ATTT_C_LOOP
	LWL	H_SCM_C_1,0|AFunc,A_TALK_NEXT
	LWL	H_IDL_C_1,0|AFunc,A_TALK_END
	LWLW	1,1|AFunc,A_HEAD_DECISION+1,ANUM_TALK

ATALK_TT_D
	LW	1,0
	LWLL	1,1|AFunc,A_START_TALKIN+2,ATTT_D_LOOP
ATTT_D_LOOP
	LWL	H_SCM_D_1,0|AFunc,A_TALK_NEXT
	LWL	H_IDL_D_1,0|AFunc,A_TALK_END
	LWLW	1,1|AFunc,A_HEAD_DECISION+1,ANUM_TALK

*
* Mondor breathes fire
*
ANIM_HEAD_BREATH_FIRE
	.LONG	AHBREATHE_A,AHBREATHE_B,AHBREATHE_C,AHBREATHE_D

AHBREATHE_A
	LWLWW	H_SCM_A_1,1|AMulti|AFunc,A_Set_Rel_Byte_Head+2,OSPITTING_FIRE,1
	LW	H_SCMGLA1,4

	LW	H_SCM_A_2,1|AMulti
	LW	H_SCMGLA2,4

	LW	H_SCM_A_3,1|AMulti
	LW	H_SCMGLA3,3
AHB_A_LOOP
	LWLLWW	1,10|AFunc,A_SPAWN_PROJECTILE+4,FIRE_BALL_INIT,0,-33
	LWLL	1,1|AFunc,A_Anim_DSJ+2,AHB_A_LOOP

	LW	H_SCM_A_2,1|AMulti
	LW	H_SCMGLA2,4

	LW	H_SCM_A_1,1|AMulti
	LW	H_SCMGLA1,3

	LWLW	H_IDL_A_1,1|AMulti|AFunc,A_HEAD_DECISION+1,ANUM_BREATHE_FIRE
	LW	H_IDLGLA1,1

AHBREATHE_B
	LWLWW	H_SCM_A_1,4|AFunc,A_Set_Rel_Byte_Head+2,OSPITTING_FIRE,1
	LW	H_SCM_A_2,4
	LW	H_SCM_A_3,3
AHB_B_LOOP
	LWLLWW	1,10|AFunc,A_SPAWN_PROJECTILE+4,FIRE_BALL_INIT,0,-33
	LWLL	1,1|AFunc,A_Anim_DSJ+2,AHB_B_LOOP
	LW	H_SCM_A_2,4
	LW	H_SCM_A_1,3
	LWLW	H_IDL_A_1,1|AFunc,A_HEAD_DECISION+1,ANUM_BREATHE_FIRE

AHBREATHE_C
	LWLWW	H_SCM_C_1,4|AFunc,A_Set_Rel_Byte_Head+2,OSPITTING_FIRE,1
	LW	H_SCM_C_2,4
	LW	H_SCM_C_3,3
AHB_C_LOOP
	LWLLWW	1,10|AFunc,A_SPAWN_PROJECTILE+4,FIRE_BALL_INIT,0,-33
	LWLL	1,1|AFunc,A_Anim_DSJ+2,AHB_C_LOOP
	LW	H_SCM_C_2,4
	LW	H_SCM_C_1,3
	LWLW	H_IDL_C_1,1|AFunc,A_HEAD_DECISION+1,ANUM_BREATHE_FIRE

AHBREATHE_D
	LWLWW	H_SCM_D_1,4|AFunc,A_Set_Rel_Byte_Head+2,OSPITTING_FIRE,1
	LW	H_SCM_D_2,4
	LW	H_SCM_D_3,6
AHB_D_LOOP
	LWLLWW	1,10|AFunc,A_SPAWN_PROJECTILE+4,FIRE_BALL_INIT,0,-33
	LWLL	1,1|AFunc,A_Anim_DSJ+2,AHB_D_LOOP
	LW	H_SCM_D_2,4
	LW	H_SCM_D_1,3
	LWLW	H_IDL_D_1,1|AFunc,A_HEAD_DECISION+1,ANUM_BREATHE_FIRE

*
* Mondor shake that head
*
ANIM_HEAD_SHAKE
	.LONG	AHSHAKE_A,AHSHAKE_B,AHSHAKE_C,AHSHAKE_D

AHSHAKE_A
	LWLW	1,1|AFunc,A_Set_AnimLoop+1,4
	LWLL	H_NOP_A_2,1|AMulti|AFunc,A_SOUNDZ+2,SND_HEAD_SHAKE
	LW	H_NOPGLA2,1
AHSK_A_LOOP
	LW	H_NOP_A_3,1|AMulti
	LW	H_NOPGLA3,2

	LW	H_NOP_A_2,1|AMulti
	LW	H_NOPGLA2,1

	LW	H_IDL_A_1,1|AMulti
	LW	H_IDLGLA1,1

	LWW	H_NOP_A_2,1|AMulti|AFlip,M_FLIPH
	LW	H_NOPGLA2,1

	LW	H_NOP_A_3,1|AMulti
	LW	H_NOPGLA3,2

	LW	H_NOP_A_2,1|AMulti
	LW	H_NOPGLA2,1

	LW	H_IDL_A_1,1|AMulti|AFlip,0
	LW	H_IDLGLA1,1

	LWLL	H_NOP_A_2,1|AMulti|AFunc,A_Anim_DSJ+2,AHSK_A_LOOP
	LW	H_NOPGLA2,1

	LW	H_NOP_A_3,1|AMulti
	LW	H_NOPGLA3,2

	LW	H_NOP_A_2,1|AMulti
	LW	H_NOPGLA2,1

	LW	H_IDL_A_1,1|AMulti
	LW	H_IDLGLA1,1

	LWW	H_NOP_A_2,1|AMulti|AFlip,M_FLIPH
	LW	H_NOPGLA2,1

	LW	H_NOP_A_3,1|AMulti
	LW	H_NOPGLA3,2

	LW	H_NOP_A_2,1|AMulti
	LW	H_NOPGLA2,1

	LWWLW	H_IDL_A_1,1|AMulti|AFlip|AFunc,0,A_HEAD_DECISION+1,ANUM_SHAKE
	LW	H_IDLGLA1,1

AHSHAKE_B
	LWLW	1,1|AFunc,A_Set_AnimLoop+1,4
	LWLL	H_NOP_A_2,1|AFunc,A_SOUNDZ+2,SND_HEAD_SHAKE
AHSK_B_LOOP
	LW	H_NOP_A_3,1
	LW	H_NOP_A_2,1
	LW	H_IDL_A_1,1
	LWW	H_NOP_A_2,1|AFlip,M_FLIPH
	LW	H_NOP_A_3,1
	LW	H_NOP_A_2,1
	LW	H_IDL_A_1,1|AFlip,0
	LWLL	H_NOP_A_2,1|AFunc,A_Anim_DSJ+2,AHSK_B_LOOP

	LW	H_NOP_A_3,1
	LW	H_NOP_A_2,1
	LW	H_IDL_A_1,1
	LWW	H_NOP_A_2,1|AFlip,M_FLIPH
	LW	H_NOP_A_3,1
	LW	H_NOP_A_2,1
	LWWLW	H_IDL_A_1,1|AFlip|AFunc,0,A_HEAD_DECISION+1,ANUM_SHAKE

AHSHAKE_C
	LWLW	1,1|AFunc,A_Set_AnimLoop+1,4
	LWLL	H_NOP_C_2,1|AFunc,A_SOUNDZ+2,SND_HEAD_SHAKE
AHSK_C_LOOP
	LW	H_NOP_C_3,1
	LW	H_NOP_C_2,1
	LW	H_IDL_C_1,1
	LWW	H_NOP_C_2,1|AFlip,M_FLIPH
	LW	H_NOP_C_3,1
	LW	H_NOP_C_2,1
	LW	H_IDL_C_1,1|AFlip,0
	LWLL	H_NOP_C_2,1|AFunc,A_Anim_DSJ+2,AHSK_C_LOOP

	LW	H_NOP_C_3,1
	LW	H_NOP_C_2,1
	LW	H_IDL_C_1,1
	LWW	H_NOP_C_2,1|AFlip,M_FLIPH
	LW	H_NOP_C_3,1
	LW	H_NOP_C_2,1
	LWWLW	H_IDL_C_1,1|AFlip|AFunc,0,A_HEAD_DECISION+1,ANUM_SHAKE

AHSHAKE_D
	LWLW	1,1|AFunc,A_Set_AnimLoop+1,4
	LWLL	H_NOP_D_2,1|AFunc,A_SOUNDZ+2,SND_HEAD_SHAKE
AHSK_D_LOOP
	LW	H_NOP_D_3,1
	LW	H_NOP_D_2,1
	LW	H_IDL_D_1,1
	LWW	H_NOP_D_2,1|AFlip,M_FLIPH
	LW	H_NOP_D_3,1
	LW	H_NOP_D_2,1
	LW	H_IDL_D_1,1|AFlip,0
	LWLL	H_NOP_D_2,1|AFunc,A_Anim_DSJ+2,AHSK_D_LOOP

	LW	H_NOP_D_3,1
	LW	H_NOP_D_2,1
	LW	H_IDL_D_1,1
	LWW	H_NOP_D_2,1|AFlip,M_FLIPH
	LW	H_NOP_D_3,1
	LW	H_NOP_D_2,1
	LWWLW	H_IDL_D_1,1|AFlip|AFunc,0,A_HEAD_DECISION+1,ANUM_SHAKE


*
* Mondor looks to the left
*
ANIM_HEAD_LOOK_LEFT
	.LONG	AHLL_A,AHLL_B,AHLL_C,AHLL_D

AHLL_A
	LW	H_NOP_A_1,1|AMulti
	LW	H_NOPGLA1,1
AHLL_A_IN
	LWLL	1,2|AFunc,A_SOUND+2,SND_HUH

	LW	H_NOP_A_2,1|AMulti
	LW	H_NOPGLA2,3

	LW	H_NOP_A_3,1|AMulti
	LW	H_NOPGLA3,15

	LW	H_NOP_A_2,1|AMulti
	LW	H_NOPGLA2,4

	LW	H_NOP_A_1,1|AMulti
	LW	H_NOPGLA1,4

	LWWLW	H_IDL_A_1,1|AMulti|AFlip|AFunc,0,A_HEAD_DECISION+1,ANUM_LOOK
	LW	H_IDLGLA1,1

AHLL_B
	LW	H_NOP_A_1,1
AHLL_B_IN
	LWLL	1,2|AFunc,A_SOUND+2,SND_HUH
	LW	H_NOP_A_2,3
	LW	H_NOP_A_3,15
	LW	H_NOP_A_2,4
	LW	H_NOP_A_1,4
	LWWLW	H_IDL_A_1,1|AFlip|AFunc,0,A_HEAD_DECISION+1,ANUM_LOOK

AHLL_C
	LW	H_NOP_C_1,1
AHLL_C_IN
	LWLL	1,2|AFunc,A_SOUND+2,SND_HUH
	LW	H_NOP_C_2,3
	LW	H_NOP_C_3,15
	LW	H_NOP_C_2,4
	LW	H_NOP_C_1,4
	LWWLW	H_IDL_C_1,1|AFlip|AFunc,0,A_HEAD_DECISION+1,ANUM_LOOK

AHLL_D
	LW	H_NOP_D_1,1
AHLL_D_IN
	LWLL	1,2|AFunc,A_SOUND+2,SND_HUH
	LW	H_NOP_D_2,3
	LW	H_NOP_D_3,15
	LW	H_NOP_D_2,4
	LW	H_NOP_D_1,4
	LWWLW	H_IDL_D_1,1|AFlip|AFunc,0,A_HEAD_DECISION+1,ANUM_LOOK

*
*Mondor looks to the right
*
ANIM_HEAD_LOOK_RIGHT
	.LONG	AHLR_A,AHLR_B,AHLR_C,AHLR_D

AHLR_A
	LWWLL	H_NOP_A_1,1|AMulti|AFlip|AFunc,M_FLIPH,A_AnimFrm+2,AHLL_A_IN
	LW	H_NOPGLA1,1

AHLR_B
	LWWLL	H_NOP_A_1,1|AFlip|AFunc,M_FLIPH,A_AnimFrm+2,AHLL_B_IN

AHLR_C
	LWWLL	H_NOP_C_1,1|AFlip|AFunc,M_FLIPH,A_AnimFrm+2,AHLL_C_IN

AHLR_D
	LWWLL	H_NOP_D_1,1|AFlip|AFunc,M_FLIPH,A_AnimFrm+2,AHLL_D_IN

*
*Mondor loses his gun
*
ANIM_ARM_LOSE_GUN
	.LONG	ALG_A,ALG_A,ALG_C,ALG_D

ALG_A
	LWLL	L_THR_A_4,1|AFunc,A_CHANGE_PAL+2,FLESH1p
	LWLLLL	1,1|AFunc,A_PreFrag_Center+6,FRAG_GUN_FLY,80h,20000h
	LWLL	L_THR_A_5,12|AFunc,A_SOUNDZ+2,SND_GUN_FLY
	LW	L_THR_A_4,6
	LW	L_THR_A_3,6
	LW	L_THR_A_2,6
	LWL	L_THR_A_1,6|AFunc,A_MAKE_HEAD_LOOK
	LWL	L_IDL_A_1,6|AFunc,A_CLR_OGUN_BLOWN
	LWL	1,1|AFunc,A_CHECK_POUND
	
;ALG_B
;	LWLLLL	L_THR_B_4,1|AFunc,A_PreFrag_Center+6,FRAG_GUN_FLY,80h,20000h
;	LWLL	L_THR_B_5,12|AFunc,A_SOUNDZ+2,SND_GUN_FLY
;	LW	L_THR_B_4,6
;	LW	L_THR_B_3,6
;	LW	L_THR_B_2,6
;	LWL	L_THR_B_1,6|AFunc,A_MAKE_HEAD_LOOK
;	LWL	L_IDL_B_1,6|AFunc,A_CLR_OGUN_BLOWN
;	LWL	1,1|AFunc,A_CHECK_POUND

ALG_C
	LWLLL	L_THR_C_4,1|AFunc,A_CHANGE_PAL_VIOLENCE+4,FLESH2p,FLESH2pG
	LWLLLL	1,1|AFunc,A_PreFrag_Center+6,FRAG_GUN_FLY,80h,20000h
	LWLL	L_THR_C_5,12|AFunc,A_SOUNDZ+2,SND_GUN_FLY
	LW	L_THR_C_4,6
	LW	L_THR_C_3,6
	LW	L_THR_C_2,6
	LWL	L_THR_C_1,6|AFunc,A_MAKE_HEAD_LOOK
	LWL	L_IDL_C_1,6|AFunc,A_CLR_OGUN_BLOWN
	LWL	1,1|AFunc,A_CHECK_POUND

ALG_D
	LWLLL	L_THR_D_4,1|AFunc,A_CHANGE_PAL_VIOLENCE+4,FLESH3p,FLESH3pG
	LWLLLL	1,1|AFunc,A_PreFrag_Center+6,FRAG_GUN_FLY,80h,20000h
	LWLL	L_THR_D_5,12|AFunc,A_SOUNDZ+2,SND_GUN_FLY
	LW	L_THR_D_4,6
	LW	L_THR_D_3,6
	LW	L_THR_D_2,6
	LWL	L_THR_D_1,6|AFunc,A_MAKE_HEAD_LOOK
	LWL	L_IDL_D_1,6|AFunc,A_CLR_OGUN_BLOWN
	LWL	1,1|AFunc,A_CHECK_POUND

*
*TABLE OF DAMAGE ANIMATIONS FOR MONDOR (INDEXED VIA OPARTID)
*
DAMAGE_ANIM_TABLE
	.LONG	ANIM_LEFT_TORSO_DAMAGE	;Torso - left
	.LONG	ANIM_RIGHT_TORSO_DAMAGE	;Torso - right
	.LONG	ANIM_LEG_DAMAGE		;Leg - left
	.LONG	ANIM_LEG_DAMAGE		;Leg - right
	.LONG	ANIM_ARM_DAMAGE		;Arm - left
	.LONG	ANIM_ARM_DAMAGE		;Arm - right
	.LONG	ANIM_HEAD_DAMAGE	;Head

ANIM_LEFT_TORSO_DAMAGE
	LWLL	1,1|AFunc,A_TORSO_DAMAGE+4,ANIM_LEFT_TORSO_DAMAGE2
	.LONG	ANIM_LEFT_TORSO_DAMAGE3
	LWL	1,1|AFunc,PULL_ANIM

ANIM_LEFT_TORSO_DAMAGE2
	LWLLLL	1,15|AFunc,A_PreFrag_Box+6,FRAG_EXPLOSION_SMALL,80h,40000h
	LWL	1,1|AFunc,A_SHIRT_CHUNK

	LW	1,1|AMulti
	LW	1,1|AMulti
	LW	1,1|AMulti
	LW	1,1|AMulti
	LW	1,1|AMulti
	LW	1,1|AMulti
	LW	1,1|AMulti
	LW	1,1|AMulti
	LW	1,1|AMulti
	LWL	1,1|AFunc,A_INIT_CHEST_DAMAGE

	LWL	1,1|AFunc,PULL_ANIM

ANIM_LEFT_TORSO_DAMAGE3
	LWLLLL	1,15|AFunc,A_PreFrag_Box+6,FRAG_EXPLOSION_SMALL,80h,40000h
	LWL	1,1|AFunc,A_SHIRT_CHUNK
	LWLLL	TORSO_4,1|AFunc,A_CHANGE_PAL_VIOLENCE+4,CHESTdp1,CHESTdp1G
	LWL	1,1|AFunc,PULL_ANIM

ANIM_RIGHT_TORSO_DAMAGE
	LWLL	1,1|AFunc,A_TORSO_DAMAGE+4,ANIM_RIGHT_TORSO_DAMAGE2
	.LONG	ANIM_RIGHT_TORSO_DAMAGE3
	LWL	1,1|AFunc,PULL_ANIM

ANIM_RIGHT_TORSO_DAMAGE2
	LWLLLL	1,15|AFunc,A_PreFrag_Box+6,FRAG_EXPLOSION_SMALL,80h,40000h
	LWL	1,1|AFunc,A_SHIRT_CHUNK

	LW	1,1|AMulti
	LW	1,1|AMulti
	LW	1,1|AMulti
	LW	1,1|AMulti
	LW	1,1|AMulti
	LW	1,1|AMulti
	LW	1,1|AMulti
;	LWL	TORSO_2,1|AFunc,A_INIT_CHEST_DAMAGE
	LWL	1,1|AFunc,A_INIT_CHEST_DAMAGE

	LWL	1,1|AFunc,PULL_ANIM

ANIM_RIGHT_TORSO_DAMAGE3
	LWLLLL	1,15|AFunc,A_PreFrag_Box+6,FRAG_EXPLOSION_SMALL,80h,40000h
	LWL	1,1|AFunc,A_SHIRT_CHUNK

	LWWLLL	TORSO_3,1|AFlip|AFunc,0,A_CHANGE_PAL_VIOLENCE+4,CHESTdp1,CHESTdp1G
	LWL	1,1|AFunc,PULL_ANIM

ANIM_LEG_DAMAGE
	LWLLLL	1,15|AFunc,A_PreFrag_Box+6,FRAG_EXPLOSION_SMALL,80h,40000h
	LWL	1,1|AFunc,A_JEANS_CHUNK
	LWLL	1,1|AFunc,A_LOAD_ANIMATION+2,ANIM_LEG_IDLE
	
ANIM_ARM_DAMAGE
	LWLLLL	1,15|AFunc,A_PreFrag_Box+6,FRAG_EXPLOSION_SMALL,80h,40000h
	LWL	1,1|AFunc,A_LOSE_GUN_IFNECC
	LWL	1,1|AFunc,A_RANDOM_MULTI_CHUNK
	LWLL	1,1|AFunc,A_LOAD_ANIMATION+2,ANIM_ARM_IDLE
	
ANIM_HEAD_DAMAGE
	LWLLLL	1,15|AFunc,A_PreFrag_Box+6,FRAG_EXPLOSION_SMALL,80h,40000h
	LWL	1,1|AFunc,A_LOSE_GLASSES_IFNECC
	LWL	1,1|AFunc,A_RANDOM_MULTI_CHUNK
	LWLL	1,1|AFunc,A_LOAD_ANIMATION+2,ANIM_HEAD_IDLE


*
*TABLE OF FINAL ANIMATIONS FOR MONDOR (INDEXED VIA OPARTID)
*
FINAL_ANIM_TABLE
	.LONG	0			;Torso - left
	.LONG	0			;Torso - right
	.LONG	ANIM_LEG_FINAL		;Leg - left
	.LONG	ANIM_LEG_FINAL		;Leg - right
	.LONG	ANIM_ARM_FINAL		;Arm - left
	.LONG	ANIM_ARM_FINAL		;Arm - right
	.LONG	ANIM_HEAD_FINAL		;Head

ANIM_LEG_FINAL
	LWLL	1,1|AFunc,A_SOUND+2,SND_PART_PREAMBLE
	LWL	1,1|AFunc,A_BIG_SHIT_SCREAM
	LWLLLL	1,1|AFunc,A_PreFrag_Box+6,FRAG_EXPLOSION,80h,40000h
	LWLL	1,1|AFunc,A_LOAD_PART_BLOW+2,A_BLOW_LEG
	LWL	1,3|AFunc,A_BLOW_PART
	LWL	1,3|AFunc,A_BLOW_PART
	LWL	1,3|AFunc,A_BLOW_PART
	LWL	1,3|AFunc,A_BLOW_PART
	LWL	1,3|AFunc,A_BLOW_PART
	LWL	1,1|AFunc,A_RANDOM_MULTI_CHUNK
	LWLLWW	LEG_E,5|AFunc,A_SPAWN_BLOOD+4,LEG_STUMP_INIT,15,62
ANIM_BIG_SHIT_EXPLOSION
	LWLLLL	1,1|AFunc,A_PreFrag_Box+6,FRAG_EXPLOSION,80h,40000h
	LWL	1,1|AFunc,A_START_MEDIUM_SHAKE
	LWL	1,1|AFunc,A_RANDOM_MULTI_CHUNK
	LWL	1,5|AFunc,A_BLOW_PART
	LWL	1,5|AFunc,A_BLOW_PART
	LWL	1,5|AFunc,A_BLOW_PART
	LWL	1,5|AFunc,A_BLOW_PART
	LWL	1,5|AFunc,A_BLOW_PART
	LWLLLL	1,1|AFunc,A_PreFrag_Box+6,FRAG_EXPLOSION,80h,40000h
	LWL	1,1|AFunc,A_START_MEDIUM_SHAKE
	LWL	1,1|AFunc,A_RANDOM_MULTI_CHUNK
	LWL	1,5|AFunc,A_BLOW_PART
	LWL	1,5|AFunc,A_BLOW_PART
	LWL	1,5|AFunc,A_BLOW_PART
	LWLWW	1,1|AFunc,A_RAND_AnimSLP+2,1,10
	LW	1,0
	LWLLLL	1,1|AFunc,A_PreFrag_Box+6,FRAG_EXPLOSION,80h,40000h
	LWL	1,1|AFunc,A_START_MEDIUM_SHAKE
	LWL	1,1|AFunc,A_RANDOM_MULTI_CHUNK
	LWL	1,5|AFunc,A_BLOW_PART
	LWL	1,5|AFunc,A_BLOW_PART
	LWL	1,5|AFunc,A_BLOW_PART
	LWLWW	1,1|AFunc,A_RAND_AnimSLP+2,1,10
	LW	1,0
	LWLLLL	1,1|AFunc,A_PreFrag_Box+6,FRAG_EXPLOSION,80h,40000h
	LWL	1,1|AFunc,A_START_MEDIUM_SHAKE
	LWL	1,1|AFunc,A_RANDOM_MULTI_CHUNK
	LWL	1,5|AFunc,A_BLOW_PART
	LWL	1,5|AFunc,A_BLOW_PART
	LWL	1,5|AFunc,A_BLOW_PART
	LWLWW	1,1|AFunc,A_RAND_AnimSLP+2,1,10
	LW	1,0
	LWL	1,1|AFunc,A_CHECK_IF_FINAL


LEG_BLOW_INIT
	.LONG	LEG_D
	.WORD	DMAWNZ, 0, OM_CFUNC|OM_DUMCOLL
	.LONG	C_GREEN_STRTANIM,LEG3pG,ANIM_BLOW_SCREEN

ARM_BLOW_INIT
	.LONG	L_IDL_D_1
	.WORD	DMAWNZ, 0, OM_CFUNC|OM_DUMCOLL
	.LONG	C_GREEN_STRTANIM,FLESH3pG,ANIM_BLOW_SCREEN

HEAD_BLOW_INIT
	.LONG	H_IDL_D_1
	.WORD	DMAWNZ, 0, OM_ANIM|OM_DUMCOLL
	.LONG	ANIM_BLOW_SCREEN

*Simple animation to check if we are off screen and delete.
ANIM_BLOW_SCREEN
	LWLL	1,5|AFunc,A_ONSCREEN+2,ANIM_BLOW_SCREEN
	LWL	1,1|AFunc,DELETE_OBJ

LEG_STUMP_INIT
	.LONG	BONE_STUMP,DUMCOLL
	.WORD	OID_JUNK,DMAWNZ,M_DEAD|M_NOPARTANI|M_OPARTSXY,0
	.LONG	C_GREEN_STRTANIM,GLOOD_P,ANIM_ARM_STUMP

ANIM_ARM_FINAL
	LWLL	1,1|AFunc,A_SOUND+2,SND_PART_PREAMBLE
	LWL	1,1|AFunc,A_BIG_SHIT_SCREAM
	LWLLLL	1,1|AFunc,A_PreFrag_Box+6,FRAG_EXPLOSION,80h,40000h
	LWLL	1,1|AFunc,A_LOAD_PART_BLOW+2,A_BLOW_ARM
	LWL	1,3|AFunc,A_BLOW_PART
	LWL	1,3|AFunc,A_BLOW_PART
	LWL	1,3|AFunc,A_BLOW_PART
	LWL	1,3|AFunc,A_BLOW_PART
	LWL	1,3|AFunc,A_BLOW_PART
	LWL	1,1|AFunc,A_LOSE_GUN_IFNECC
	LWL	1,1|AFunc,A_RANDOM_MULTI_CHUNK
	LWL	L_IDL_E_1,30|AFunc,A_TURN_ON_ARM_STUMP
	LWLL	1,1|AFunc,A_AnimFrm+2,ANIM_BIG_SHIT_EXPLOSION

ANIM_HEAD_FINAL
	LWLL	1,1|AFunc,A_SOUND+2,SND_PART_PREAMBLE
	LWLLLL	1,1|AFunc,A_PreFrag_Box+6,FRAG_EXPLOSION,80h,40000h
	LWLL	1,1|AFunc,A_SOUNDZ+2,SND_FINAL_DEATH
	LWLL	1,1|AFunc,A_LOAD_PART_BLOW+2,A_BLOW_HEAD
	LWL	1,3|AFunc,A_BLOW_PART
	LWL	1,3|AFunc,A_BLOW_PART
	LWL	1,3|AFunc,A_BLOW_PART
	LWL	1,3|AFunc,A_BLOW_PART
	LWL	1,3|AFunc,A_BLOW_PART
	LWL	1,1|AFunc,A_RANDOM_MULTI_CHUNK

*The following three lines replace the three after that for 
*an explosion with sound
	LW	H_SCM_D_1,3
	LW	H_SCM_D_2,3
	LW	H_SCM_D_3,1

	LWLL	1,1|AFunc,A_AnimFrm+2,ANIM_BIG_SHIT_EXPLOSION

*
*Bloody stump stuff
*
ANIM_ARM_STUMP
	LWLL	1,1|AFunc,A_GREEN_IF_NEC+2,GLOOD_P
	LWLW	1,40|AFunc,A_Set_AnimLoop+1,55
AAS_LOOP
	LWLLWW	BLOOD_B_1,2|AFunc,A_RAND_SPAWN_BLOOD+4,ARM_SPRAY_INIT,0,0
	LWLLWW	BLOOD_B_2,2|AFunc,A_RAND_SPAWN_BLOOD+4,ARM_SPRAY_INIT,0,0
	LWLLWW	BLOOD_B_3,2|AFunc,A_RAND_SPAWN_BLOOD+4,ARM_SPRAY_INIT,0,0
	LWLLWW	BLOOD_B_4,2|AFunc,A_RAND_SPAWN_BLOOD+4,ARM_SPRAY_INIT,0,0
	LWLLWW	BLOOD_B_5,2|AFunc,A_RAND_SPAWN_BLOOD+4,ARM_SPRAY_INIT,0,0
	LWLLWW	BLOOD_B_6,2|AFunc,A_RAND_SPAWN_BLOOD+4,ARM_SPRAY_INIT,0,0
	LWLLWW	BLOOD_B_7,2|AFunc,A_RAND_SPAWN_BLOOD+4,ARM_SPRAY_INIT,0,0
	LWLWW	BONE_STUMP,1|AFunc,A_RAND_AnimSLP+2,1,15
	LWLL	1,0|AFunc,A_Anim_DSJ+2,AAS_LOOP

AAS_LOOP2
	LW	BLOOD_B_1,2
	LWLLWW	BLOOD_B_2,2|AFunc,A_RAND_SPAWN_BLOOD+4,ARM_SPRAY_INIT,0,0
	LW	BLOOD_B_3,2
	LWLLWW	BLOOD_B_4,2|AFunc,A_RAND_SPAWN_BLOOD+4,ARM_SPRAY_INIT,0,0
	LW	BLOOD_B_5,2
	LWLLWW	BLOOD_B_6,2|AFunc,A_RAND_SPAWN_BLOOD+4,ARM_SPRAY_INIT,0,0
	LW	BLOOD_B_7,2
	LWLWW	BONE_STUMP,1|AFunc,A_RAND_AnimSLP+2,1,15
	LWLL	1,0|AFunc,A_AnimFrm+2,AAS_LOOP2


ARM_SPRAY_INIT
	.LONG	BLOOD_A_1,DUMCOLL
	.WORD	OID_JUNK,DMAWNZ,M_DEAD|M_NOPARTANI|M_OPARTSXY,2
	.LONG	C_GREEN_STRTANIM,GLOOD_P,ANIM_ARM_SPRAY

ANIM_ARM_SPRAY
	LWLWW	1,1|AFunc,A_RAND_AnimSLP+2,1,4
	LWLWL	BLOOD_A_2,0|AFunc,A_RAND_SOUNDZ+3,500,SND_BLOOD_SPRAY
	LW	BLOOD_A_3,0
	LW	BLOOD_A_4,0
	LW	BLOOD_A_5,0
	LW	BLOOD_A_6,0
	LW	BLOOD_A_7,0
	LW	BLOOD_A_8,0
	LW	BLOOD_A_9,0
	LW	BLOOD_A_10,0
	LW	BLOOD_A_11,0
	LWL	BLOOD_A_12,0|AFunc,A_PULL_ARM_SPURT
	LW	BLOOD_A_13,0
	LW	BLOOD_A_14,0
	LW	BLOOD_A_15,0
	LW	BLOOD_A_16,0
	LWL	BLOOD_A_17,0|AFunc,A_INIT_BLOOD_DROP
	LWL	1,1|AFunc,PULL_ANIM

**************************************************************************
*								         *
* 	C_GREEN_STRTANIM						 *
* 									 *
* 	Create func to change the palette to green if			 *
* 	necessary, then jump to C_STRTANIM				 *
* 									 *
* 	A0 = Ptr to un-inserted object					 *
*								         *
**************************************************************************
C_GREEN_STRTANIM
	MOVE	*B0+,B14,L

	MOVE	@VIOLENCE_LEVEL,A14,W
	DEC	A14
	JRP	CGS_RED

	MMTM	SP,A0,A8
	MOVE	A0,A8
	MOVE	B14,A0
	CALLA	CHANGE_PAL
	MMFM	SP,A0,A8
CGS_RED
	JAUC	C_STRTANIM
	
**************************************************************************
*								         *
* 	A_GLOOD_IF_NEC							 *
* 									 *
* 	Anim func to change to green blood if necessary.		 *
* 									 *
* 	A8 = Ptr to object						 *
*	AARG+,L = Palette we are changing to				 *
*								         *
**************************************************************************
A_GREEN_IF_NEC
	MOVE	@VIOLENCE_LEVEL,A14,W
	DEC	A14
	JRP	AGIN_X
	CALLA	GETAFARG_LONG
	JAUC	CHANGE_PAL
AGIN_X
	RETS

**************************************************************************
*								         *
* 	Mondor's big gig in the sky					 *
*								         *
**************************************************************************
ANIM_FINAL_EXPLOSION
	LWLW	1,1|AFunc,A_Set_AnimLoop+1,10
AFE_LOOP
	LWLLLL	1,1|AFunc,A_PreFrag_Center+6,FRAG_EXPLOSION,0400h,40000h
	LWL	1,1|AFunc,A_START_BIG_SHAKE
	LWLLLL	1,1|AFunc,A_PreFrag_Center+6,FRAG_EXPLOSION,0400h,40000h
	LWLWW	1,1|AFunc,A_RAND_AnimSLP+2,10,25
	LWLL	1,0|AFunc,A_Anim_DSJ+2,AFE_LOOP

AFE_CRAFT_BLOW
	LWL	1,1|AFunc,A_KEEP_US_CENTERED
	LWLLLL	1,1|AFunc,A_PreFrag_Center+6,FRAG_EXPLOSION,0400h,40000h
	LWL	1,1|AFunc,A_START_MEDIUM_SHAKE
	LWLWW	1,1|AFunc,A_RAND_AnimSLP+2,5,10
	LWLL	1,0|AFunc,A_TURN_OFF_NEXT_PART+2,AFE_CRAFT_BLOW

	LWL	1,7|AFunc,A_GOOD_TO_GO

	LWLWL	1,1|AFunc,A_CREATEP+3,PID_IND,PROC_SKY_FLASH
	LWLL	1,1|AFunc,A_SOUND+2,SND_FINAL_EXPLODE3
	LWLLLL	1,1|AFunc,A_PreFrag_Center+6,FRAG_FINAL_EXPLOSION,0100h,40000h
	LWLL	1,1|AFunc,A_SOUND+2,SND_FINAL_EXPLODE2
	LWLL	1,1|AFunc,A_SOUND+2,SND_FINAL_EXPLODE1

	LWLLLL	1,1|AFunc,A_PreFrag_Rain+6,FRAG_FINAL_RAIN,80H,40000H

	LWLWL	1,1|AFunc,A_CREATEP+3,PID_IND,PROC_GAME_ENDING

	LWL	1,1|AFunc,A_DELETE_MONDOR
	
*
*Thruster animation scripts
*
ANIM_THRUSTER_L
	LWL	1,1|AFunc,A_THRUSTERL_INIT
	LWLL	1,1|AFunc,A_AnimGo+2,ANIM_THRUSTERL_LOOP
ANIM_THRUSTERL_LOOP
	LWL	1,1|AFunc,A_THRUSTER_CHECK_L
	.LONG	0

ANIM_THRUSTER_R
	LWL	1,1|AFunc,A_THRUSTERR_INIT
	LWLL	1,1|AFunc,A_AnimGo+2,ANIM_THRUSTERR_LOOP
ANIM_THRUSTERR_LOOP
	LWL	1,1|AFunc,A_THRUSTER_CHECK_R
	.LONG	0


ANIM_THRUSTER_FIRE
	LW	POD_L_B1,2
	LWL	POD_L_A1,1|AFunc,A_THRUSTER_LOOP
	.LONG	0

*Left Thruster extend
ANIM_THRUSTER_OUT_L
	LWL	1,6|AFunc,OBJ_ON
	LW	POD_L_A3,6
	LW	POD_L_A2,6
	LWLL	POD_L_A1,6|AFunc,A_THRUSTER_EXTENDED+2,ANIM_THRUSTER_L
	
*Right Thruster extend
ANIM_THRUSTER_OUT_R
	LWL	1,6|AFunc,OBJ_ON
	LW	POD_L_A3,6
	LW	POD_L_A2,6
	LWLL	POD_L_A1,6|AFunc,A_THRUSTER_EXTENDED+2,ANIM_THRUSTER_R

*
*Foot rest animations
*
ANIM_FOOT_OUT
	LWL	1,4|AFunc,OBJ_ON
	LW	CRFT_FOOT_B,4
	LW	CRFT_FOOT_C,4
	LW	CRFT_FOOT_D,4
	LW	CRFT_FOOT_E,4
	LW	CRFT_FOOT_F,4
	LWL	CRFT_PIPE,1|AFunc,A_FOOT_ON
	LWL	1,1|AFunc,PULL_ANIM

*
* License plate drop
*
ANIM_PLATE_OUT
	LWL	1,4|AFunc,OBJ_ON
	LW	PLATOUT2,4
	LW	PLATOUT3,4
	LW	PLATOUT4,4
	LWL	LISCPLATE1,1|AFunc,TURN_ON_SCALE_SHAD
	LWL	1,1|AFunc,PULL_ANIM

*
* Animation to handle the disembodied seat dropping to the ground.
* Note: this animation must be run by the head part only!
*
ANIM_DROP_IN
	LWLWW	1,1|AFunc,A_Set_Rel_Word+2,OYACCEL,2000H
	LWL	1,1|AFunc,PULL_ANIM

*
* Just the final frame of the big Helga morph.  This is what Mondor
* really is.
*
ANIM_MORPH_FINISH
	LWLL	TORSO_0,1|AMulti|AFunc,A_SCALE_PAL+2,VESTPAL1
	LWWLL	TORSO_0,1|AMulti|AFlip|AFunc,M_FLIPH,A_SCALE_PAL+2,VESTPAL1
	LWLL	LEG_A,1|AMulti|AFunc,A_SCALE_PAL+2,PANPAL1
	LWWLL	LEG_A,1|AMulti|AFlip|AFunc,M_FLIPH,A_SCALE_PAL+2,PANPAL1
	LWL	L_IDL_A_1,1|AMulti|AFunc,A_INIT_ARM
	LWWL	L_IDL_A_1,1|AMulti|AFlip|AFunc,M_FLIPH,A_INIT_ARM
	LWWL	H_IDL_A_1,1|AMulti|AFlip|AFunc,0,A_INIT_HEAD
	LWWL	H_IDLGLA1,1|AMulti|AFlip|AFunc,0,A_INIT_GLASSES
	LWWLLL	TORSO_2,1|AMulti|AFlip|AFunc,0,A_OBJ_OFF_SCALE_PAL+4,CHESTdp1,CHESTdp1G
	LWWLLL	TORSO_1,1|AMulti|AFlip|AFunc,0,A_OBJ_OFF_SCALE_PAL+4,CHESTdp1,CHESTdp1G
	LWL	1,1|AMulti|AFunc,OBJ_ON
	LWL	1,5|AFunc,OBJ_ON

;ANIM_START_MONDOR
	LWL	1,1|AFunc,A_START_GEAR_OUT

;	LWL	1,1|AFunc,A_GET_SHAD_MULTI

	LW	1,15
;	LWLWW	1,1|AFunc,A_Set_Rel_Word_Head+2,OYACCEL,1000H
	LW	1,8
	LWL	1,7|AFunc,A_GET_SHAD_MULTI
;	LWLWW	1,1|AFunc,A_Set_Rel_Word_Head+2,OYACCEL,0
;	LWLWW	1,1|AFunc,A_Set_Rel_Word_Head+2,OYVEL+16,0

;	LWL	1,1|AFunc,A_GET_SHAD_MULTI

	LWLLW	1,1|AFunc,A_Set_Var_Word+3,MONDOR_MORPH_FLAG,1
	LWLLW	1,1|AFunc,A_Set_Var_Word+3,NO_CHARITY,0
	LWLLW	1,30|AFunc,A_Set_Var_Word+3,GUNS_OFF,0
	
;	LWLL	1,1|AFunc,A_SOUND+2,SND_MONDOR_BATTLE

	LWL	1,1|AFunc,A_START_MOVEMENT

	LWL	1,1|AFunc,PULL_ANIM


*
*Some miscellaneous fire stuff
*
POD_FIRE_TAB
	.WORD	-96,-68
	.WORD	-53,-76
	.WORD	-73,-87
	.WORD	-87,-83
	.WORD	-57,-83

*
*Script to make the glasses fly from Mondor's head
*
FRAG_GLASSES_FLY
	.long	GLASSES_FLY,F_GLASSES_CHUNK
	.word	OID_JUNK,1*800H+1*40H+FRGPAL+FRGGCOL

	.LONG	0

**************************************************************************
*								         *
* F_GLASSES_CHUNK - Frag Func for MONDOR glasses.			 *
* A0 = Ptr to un-inserted object.					 *
* 									 *
* Note: Frag funcs must preserve A8-A11 and all B-File regs.		 *
*								         *
**************************************************************************
F_GLASSES_CHUNK
	MOVE	*A0(OZVEL),A14,L
	ABS	A14
	NEG	A14
	MOVE	A14,*A0(OZVEL),L

	MOVE	*A0(OYVEL),A14,L
	ABS	A14
	ADDI	20000H,A14
	NEG	A14
	MOVE	A14,*A0(OYVEL),L

	MOVIM	MCHUNK_COLL,*A0(OCVECT),L	;Set up chunk with Vectors	
	RETS

GLASSES_FLY
	LW	H_IDLGLA1,1
	LWL	1,1|AFunc,PULL_ANIM


*
*Script to make the license plate fly
*
FRAG_PLATE_FLY
	.long	PLATE_FLY,F_GUN_CHUNK
	.word	OID_JUNK,1*800H+1*40H+FRGPAL+FRGGCOL

	.LONG	0

PLATE_FLY
	LWLW	PLT1,1|AFunc,A_INIT_AnimSLP+1,1
PLATE_FLY_LOOP
	LW	PLT2,0
	LW	PLT3,0
	LW	PLT4,0
	LW	PLT5,0
	LW	PLT6,0
	LW	PLT7,0
	LWLW	PLT8,0|AFunc,A_INC_AnimSLP+1,5
	LWLL	PLT1,0|AFunc,A_CHUNK_ONSCREEN+2,PLATE_FLY_LOOP
	LWL	1,1|AFunc,DELETE_OBJ


**************************************************************************
*								         *
* 	PROC_GAME_ENDING						 *
* 									 *
* 	Ending message for game. This is when Mondor is defeated.	 *
*								         *
**************************************************************************
PROC_GAME_ENDING
	MOVIM	INEPILOG,@GAME_STATE,W		;Show us the state

	MOVKM	1,@GUNS_OFF,W

	SLEEP	100
	SOUND1	SND_MONDOR_FINALE
	SLEEP	2
	SOUND1	SND_CHAN0_OFF

	SLEEP	180
	SOUND1	SND_WALK_INTRO

	SLEEP	320			;Wait for the end of the rain

	CLR	A4
	MOVE	@NPLAYERS,A6,W
	MOVI	P1DATA,A2
PGE_WING_LOOP
	MOVE	*A2(PWINGS),A14,W
	ADD	A14,A4
	ADDI	PDSIZE,A2
	DEC	A6
	JRNN	PGE_WING_LOOP

	CLR	A1
	CMPK	5,A4	
	JRLO	PGE_STUFF_WING

	MOVK	1,A1
PGE_STUFF_WING
	MOVE	A1,@DO_AERO_ENDING,W

	MOVI	CONGRATS_MESS1,A8
	JSRP	TEXT_SLIDE_UP
	SLEEP	80

	MOVI	CONGRATS_MESS2,A8
	JSRP	TEXT_SLIDE_UP
	SLEEP	80

	MOVI	CONGRATS_MESS3,A8
	JSRP	TEXT_SLIDE_UP

	MOVI	CONGRATS_MESS4,A8
	JSRP	TEXT_SLIDE_UP

	SLEEP	120

	CALLA	CLRTEXT

	SLEEP	2

	MOVI	CONGRATS_MESS5,A8
	JSRP	TEXT_SLIDE_UP

	MOVI	CONGRATS_MESS6,A8
	JSRP	TEXT_SLIDE_UP

	SLEEP	100

	MOVE	@DO_AERO_ENDING,A14,W
	JRNZ	PGE_COOL_ENDING

	MOVI	CONGRATS_MESS7,A8
	JSRP	TEXT_SLIDE_UP

	SLEEP	80

	CALLA	CLRTEXT

	SLEEP	2

	MOVI	CONGRATS_MESS8,A8
	JSRP	TEXT_SLIDE_UP

	MOVI	CONGRATS_MESS9,A8
	JSRP	TEXT_SLIDE_UP

	SLEEP	100

	MOVI	CONGRATS_MESS10,A8
	JSRP	TEXT_SLIDE_UP

	SLEEP	80

	MOVI	CONGRATS_MESS11,A8
	JSRP	TEXT_SLIDE_UP

	SLEEP	60

	CALLA	CLRTEXT

	SLEEP	2

	MOVI	CONGRATS_MESS12,A8
	JSRP	TEXT_SLIDE_UP

	MOVI	CONGRATS_MESS13,A8
	JSRP	TEXT_SLIDE_UP

	MOVI	CONGRATS_MESS14,A8
	JSRP	TEXT_SLIDE_UP

	SLEEP	150

	CALLA	CLRTEXT

	SLEEP	2

	MOVI	CONGRATS_MESS15,A8
	JSRP	TEXT_SLIDE_UP

	MOVI	CONGRATS_MESS16,A8
	JSRP	TEXT_SLIDE_UP

	SOUND1	SND_WALK_XITION

	SLEEP	100

;	MOVIM	3,@BONUS_DIRECTION,W
	CLRM	@BONUS_DIRECTION,W

	JAUC	WAVE_END_IMM

	DIE


PGE_COOL_ENDING
	MOVI	CONGRATS_MESS7b,A8
	JSRP	TEXT_SLIDE_UP

	SLEEP	80

	CALLA	CLRTEXT

	SLEEP	2

	MOVI	CONGRATS_MESS8b,A8
	JSRP	TEXT_SLIDE_UP

	SLEEP	80

	MOVI	CONGRATS_MESS9b,A8
	JSRP	TEXT_SLIDE_UP

	SLEEP	100

	MOVI	CONGRATS_MESS10,A8
	JSRP	TEXT_SLIDE_UP

	SLEEP	10

;	SOUND1	SND_WALK_XITION

* Bring band up here

	SLEEP	60

	CALLA	CLRTEXT

	SLEEP	2

* Head for the dressing room

	MOVKM	1,@SCROLL_FLAG,W

	DIE

**************************************************************************
*								         *
* 	TEXT_SLIDE_UP							 *
* 									 *
* 	Process subroutine to create text off the bottom of		 *
* 	the screen and slide it on.					 *
* 									 *
* 	A8 = Ptr to string						 *
*								         *
**************************************************************************
TEXT_SLIDE_UP
	CALLA	LM_SETUP
	PUSHP	A9
	MOVIY	275,A9
	JSRP	PRINTF
	PULLP	A9
	PUSHP	A8
	MOVE	A2,A8
	MOVE	A9,A3
	MOVE	A3,A2
	MOVIY	275,A2
	MOVK	25,A4
	CALLA	SLINEVEL_LOAD
	SLEEPR	A4
	CALLA	CLR_VEL
	PULLP	A8
	RETP

CONGRATS_MESS1
	MESS_MAC RD20FONT,2,197,15+SKYTOPOF,COLOR_PLF,STRCNRMOS,OID_TEXT
	.STRING	"Congratulations!",0
	.EVEN

CONGRATS_MESS2
	MESS_MAC RD15FONT,2,197,40+SKYTOPOF,COLOR_PWHITE,STRCNRMOS,OID_TEXT
	.STRING	"You have defeated the NEW ORDER.",0
	.EVEN

CONGRATS_MESS3
	MESS_MAC RD15FONT,2,197,65+SKYTOPOF,COLOR_PWHITE,STRCNRMOS,OID_TEXT
	.STRING	"Youth all around the world",0
	.EVEN

CONGRATS_MESS4
	MESS_MAC RD15FONT,2,197,90+SKYTOPOF,COLOR_PWHITE,STRCNRMOS,OID_TEXT
	.STRING	"will be free to pursue their pleasures.",0
	.EVEN

CONGRATS_MESS5
	MESS_MAC RD15FONT,2,197,20+SKYTOPOF,COLOR_PWHITE,STRCNRMOS,OID_TEXT
	.STRING	"And you will be known throughout history",0
	.EVEN

CONGRATS_MESS6
	MESS_MAC RD15FONT,2,197,50+SKYTOPOF,COLOR_PWHITE,STRCNRMOS,OID_TEXT
	.STRING	"as the leader of this Revolution!",0
	.EVEN

CONGRATS_MESS7
	MESS_MAC RD15FONT,2,197,80+SKYTOPOF,COLOR_PWHITE,STRCNRMOS,OID_TEXT
	.STRING	"BUT....",0
	.EVEN

CONGRATS_MESS8
	MESS_MAC RD15FONT,2,197,20+SKYTOPOF,COLOR_PWHITE,STRCNRMOS,OID_TEXT
	.STRING	"You will NOT be known for partying",0
	.EVEN

CONGRATS_MESS9
	MESS_MAC RD15FONT,2,197,40+SKYTOPOF,COLOR_PWHITE,STRCNRMOS,OID_TEXT
	.STRING	"with the world's greatest rock band,",0
	.EVEN

CONGRATS_MESS10
	MESS_MAC RD20FONT,2,197,80+SKYTOPOF,COLOR_PLF,STRCNRMOS,OID_TEXT
	.STRING	"AEROSMITH!",0
	.EVEN

CONGRATS_MESS11
	MESS_MAC RD15FONT,2,197,120+SKYTOPOF,COLOR_PWHITE,STRCNRMOS,OID_TEXT
	.STRING	"Why?",0
	.EVEN

CONGRATS_MESS12
	MESS_MAC RD15FONT,2,197,20+SKYTOPOF,COLOR_PWHITE,STRCNRMOS,OID_TEXT
	.STRING	"Because you did not successfully locate",0
	.EVEN

CONGRATS_MESS13
	MESS_MAC RD15FONT,2,197,50+SKYTOPOF,COLOR_PWHITE,STRCNRMOS,OID_TEXT
	.STRING	"All of the band members hidden",0
	.EVEN

CONGRATS_MESS14
	MESS_MAC RD15FONT,2,197,80+SKYTOPOF,COLOR_PWHITE,STRCNRMOS,OID_TEXT
	.STRING	"throughout the game!",0
	.EVEN

CONGRATS_MESS15
	MESS_MAC RD15FONT,2,197,40+SKYTOPOF,COLOR_PWHITE,STRCNRMOS,OID_TEXT
	.STRING	"Find all members of AEROSMITH",0
	.EVEN

CONGRATS_MESS16
	MESS_MAC RD15FONT,2,197,60+SKYTOPOF,COLOR_PWHITE,STRCNRMOS,OID_TEXT
	.STRING	"and become a true Rock legend!",0
	.EVEN

*
* Text for alternate "You won" ending
*
CONGRATS_MESS7b
	MESS_MAC RD15FONT,2,197,80+SKYTOPOF,COLOR_PWHITE,STRCNRMOS,OID_TEXT
	.STRING	"NOW....",0
	.EVEN

CONGRATS_MESS8b
	MESS_MAC RD15FONT,2,197,20+SKYTOPOF,COLOR_PWHITE,STRCNRMOS,OID_TEXT
	.STRING	"It's time to get the real party started!",0
	.EVEN

CONGRATS_MESS9b
	MESS_MAC RD15FONT,2,197,40+SKYTOPOF,COLOR_PWHITE,STRCNRMOS,OID_TEXT
	.STRING	"Midway presents the world's greatest rock band,",0
	.EVEN

*
* Sounds for the ending sequence
*

SND_MONDOR_FINALE
	.word	0f1f0h,162,8556h,0

SND_WALK_INTRO
	.WORD	0F0FDH,1,08024H,0		;Walk this way, intro loop

SND_WALK_XITION
	.WORD	0F0FDH,1,08026H,0		;Walk this way, transition


*
* Wimpy green palettes for the fucking Australian govt.
*
FLESH2pG:
   .word   61 
   .word   00000h,07fffh,02906h,03147h,03989h,049ech,045cah,024e5h
   .word   05a4dh,055aah,0628fh,06ed0h,072f1h,07b32h,01165h,00421h
   .word   03568h,021e5h,01483h,01cc4h,04e0ch,065cah,0662dh,00460h
   .word   00e85h,03208h,001e0h,001a7h,00260h,00260h,04e0bh,002e5h
   .word   00120h,010e0h,00188h,00162h,01dc3h,0722ch,061cdh,0768fh
   .word   01503h,06ad5h,067f1h,046e8h,002a0h,05e0bh,05e8eh,05dcdh
   .word   01929h,04f27h,05a30h,04a10h,06b18h,06a0bh,00d8ch,02d48h
   .word   03267h,064a3h,026e5h,01fa3h,0158bh

FLESH3pG:
   .word   62 
   .word   00000h,07fffh,072f1h,07b32h,0628fh,05a4dh,04e0ch,06ed0h
   .word   045cah,03527h,03568h,03989h,02926h,024c5h,00081h,00d40h
   .word   00900h,01483h,01ea7h,04549h,00480h,01a23h,01cc4h,02a25h
   .word   00d60h,00269h,01965h,00580h,055adh,065aah,0116ah,04a31h
   .word   049cch,0294ah,00f05h,056b5h,00de0h,05652h,06bfah,0662dh
   .word   06a0bh,01d8ah,01307h,01de3h,06652h,04e0bh,02883h,039adh
   .word   066d6h,0728fh,0560bh,054a3h,0722ch,05e8eh,072f7h,05ab2h
   .word   0262fh,029eeh,03a51h,029abh,01506h,06317h

CHESTdp1G:
   .word   60 
   .word   00000h,07fdfh,00420h,00060h,00080h,00100h,00160h,00240h
   .word   02927h,014c5h,02483h,04907h,00300h,001c0h,000c0h,00c83h
   .word   02929h,03989h,024c6h,003eeh,01c64h,035adh,0354ah,045cah
   .word   045e9h,03527h,030e8h,045ceh,00c84h,05a4dh,04e0ch,059adh
   .word   06a4eh,06a51h,065eeh,059abh,01a04h,04e52h,02d8bh,00120h
   .word   00120h,04549h,03e0fh,02064h,01d07h,05483h,05907h,065aah
   .word   06968h,07713h,051d1h,01483h,0356dh,0496ch,05278h,045ech
   .word   040e8h,01d29h,04e0bh,06f18h

FHEDcc2G:
   .word   64 
   .word   00000h,07fffh,045cah,00180h,001a0h,03527h,00620h,03989h
   .word   006a5h,04e0ch,02926h,00020h,05a4dh,049e8h,02d45h,01645h
   .word   03568h,066afh,03d87h,04483h,018c5h,07b32h,045a7h,00140h
   .word   028e3h,059aah,03e2ah,04948h,00080h,01483h,06ef1h,028a4h
   .word   003e0h,05483h,02883h,06a31h,04dc7h,0662dh,04e0bh,07610h
   .word   06bf5h,0720ch,035adh,072f1h,05273h,06eb5h,02529h,06f5ah
   .word   059cdh,0728fh,049ach,06f17h,07b37h,05a8eh,0562bh,06a0bh
   .word   02962h,07de0h,07d40h,06400h,001a0h,05400h,07c00h,07ce0h

FHEDcc3G:
   .word   64 
   .word   00000h,07fffh,000e0h,00565h,01145h,04949h,035adh,04beeh
   .word   03949h,049adh,03989h,02906h,00020h,05a4dh,00220h,04631h
   .word   03527h,045cah,0628fh,04e0ch,018c5h,07b32h,01e27h,03483h
   .word   0294ah,028a5h,00060h,01483h,056b5h,04e0bh,05a30h,001a0h
   .word   05549h,02883h,06ab0h,021a6h,06739h,06631h,059aah,00a25h
   .word   077bdh,00260h,06ab5h,0662dh,02a67h,072d1h,04beah,021c3h
   .word   00280h,05e92h,06527h,05a8eh,057b5h,07759h,07a10h,02562h
   .word   0520bh,07de0h,07d40h,06400h,00120h,05400h,07c00h,07ce0h

GARMS2pG:
   .word   62 
   .word   00000h,07fffh,03989h,045cah,03568h,01862h,00c42h,02926h
   .word   03147h,04e0ch,05a4dh,049ech,01cc4h,001a5h,001a0h,02e68h
   .word   01a44h,020c5h,00920h,01aa5h,00220h,05e8eh,04e0bh,0628fh
   .word   06ed0h,07b32h,072f1h,01482h,0332ah,059aah,02267h,02aa8h
   .word   0662ch,024a3h,00340h,02ea7h,06569h,02f27h,01780h,04883h
   .word   0722ch,0716bh,071a9h,0560bh,043b1h,02b87h,003a0h,076afh
   .word   065eeh,017a4h,05dceh,03083h,035adh,05610h,02920h,02529h
   .word   05ad6h,04a52h,03587h,06483h,077b5h,07ffch

GARMS3pG:
   .word   61 
   .word   00000h,07fffh,03989h,045cah,03568h,01862h,00c42h,02906h
   .word   03127h,001a0h,000e0h,024c5h,045ceh,01cc4h,034c5h,04e0ch
   .word   04527h,00200h,05a4dh,05e8eh,04e0bh,0628fh,01625h,06ed0h
   .word   07b32h,033a9h,059aah,06a0ch,01882h,024a3h,01aa7h,072f1h
   .word   00dc3h,00260h,04549h,06589h,04a31h,05652h,059cdh,006a5h
   .word   05ad6h,06318h,00300h,02529h,035adh,06547h,060c4h,00ba0h
   .word   06883h,0720ch,076afh,03e73h,04ad6h,01a23h,02920h,0114ah
   .word   03587h,06a51h,05a92h,077b5h,07ffch

LEG1pG:
   .word   61 
   .word   00000h,07fffh,02929h,018a5h,00821h,01063h,01044h,020e7h
   .word   0316bh,039adh,024e9h,05273h,0356eh,04631h,05ab5h,02d26h
   .word   020c2h,041eeh,077bch,06716h,039aah,05293h,01d08h,01883h
   .word   045cah,066afh,07b33h,0564dh,06ef1h,00320h,072f1h,06e4dh
   .word   05a0ah,069cch,05627h,02748h,00280h,01b45h,05907h,04e0ch
   .word   051c8h,059aah,06631h,0764eh,037a9h,03c20h,05dech,0622ah
   .word   04bd2h,00b80h,06c83h,076afh,071edh,065a6h,057f5h,07483h
   .word   07f74h,01d07h,00c83h,00c84h,02d8bh

LEG2pG:
   .word   58 
   .word   00000h,07fffh,02929h,018a5h,00021h,01042h,01044h,020e7h
   .word   0356ah,039adh,024e9h,05651h,0356eh,04631h,05ab5h,03126h
   .word   024a3h,045ceh,077bdh,07335h,03989h,05692h,01d08h,01883h
   .word   00120h,009a0h,01580h,04529h,03946h,00ea0h,038c6h,03483h
   .word   045cah,06b5ah,0654ah,05949h,04927h,01ea6h,05bb2h,059cdh
   .word   05a4dh,059aah,048a3h,00f61h,0666eh,04b8eh,05da7h,071cbh
   .word   071edh,069aah,07359h,065c9h,050a3h,069b0h,01d07h,00c83h
   .word   00c84h,02d8bh

LEG3pG:
   .word   62 
   .word   00000h,07fffh,02929h,018a5h,00821h,01442h,01044h,020e7h
   .word   0356bh,039adh,024e9h,05631h,0356eh,04a31h,05ab5h,02926h
   .word   020c2h,045ceh,07bddh,06716h,0398ah,05293h,00140h,005a1h
   .word   038c5h,01d08h,01883h,00621h,002c0h,03925h,04549h,054c6h
   .word   05929h,03527h,06b5ah,0654ah,059cdh,051abh,041aah,04751h
   .word   050cah,01a46h,0562eh,03b2eh,04883h,03883h,05107h,06e0fh
   .word   06443h,066d5h,06693h,04543h,071ceh,04e0ch,021adh,07359h
   .word   076d6h,07a73h,01d07h,00c83h,00c84h,02d8bh

	.END
