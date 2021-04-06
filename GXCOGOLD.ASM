 	.MLIB	"GXMACS.LIB"
	.FILE	"GXCOG.ASM"
	.TITLE	"<<< GENERATION X -- COGHEAD ENEMY >>>"
	.WIDTH	132
	.OPTION	B,D,L,T
	.MNOLIST

**************************************************************************
*								         *
* 	COPYRIGHT (C) 1993 MIDWAY MANUFACTURING COMPANY.		 *
* 		       ALL RIGHTS RESERVED.				 *
*								         *
**************************************************************************

	.INCLUDE	"GX.INC"			;SYSTEM EQUATES
	.INCLUDE	"IMGTBL.GLO"
	.INCLUDE	"GXCOG.TBL"

	.REF	A_SET_OZVEL,EGUN_FLASH_MULTI,CK_PLAYER_HIT
	.REF	ENEMY_QUOTA

	.REF	SET_VECTORS

* SYMBOLS FROM GXUNIFX.ASM
	.REF	WALL_EXPLODE
	

*
*COG RAM
*

	.TEXT

*
*COGHEAD OBJECT DATA DEFINITION
*
OHITS		EQU	ODATA		;UHL GUN HIT COUNTER:
					;0-7:P1 HITS, 8-15:P2 HITS
					;16-23:P3 HITS, 24-31:P4 HITS

OMISSES		EQU	ODATA+020H	;UHB Number of consec. missed shots

OSCRNOFFCNT	EQU	ODATA+028H	;UHB OFF SCREEN COUNT

OHRUNVEL	EQU	ODATA+030H	;UHL HEADON RUN VELOCITY

OSRUNVEL	EQU	ODATA+050H	;UHL SIDE RUN VELOCITY
OAPERCENT	EQU	ODATA+070H	;UHW ATTACK PERCENTAGE
OEFLAGS		EQU	ODATA+080H	;UHW ENEMY FLAGS

ORUNSIZE	EQU	ODATA+090H	;UHL [Y, X] SIZE OF FIRST RUN FRAME

OYENEMY		EQU	ODATA+0B0H	;UHL WORLD Y POSITION OF ENEMY
OSHOOTCNT	EQU	ODATA+0D0H	;UHB COUNT SINCE LAST ATTACK
ORAPIDCNT	EQU	ODATA+0D8H	;UHB CURRENT RAPID FIRE COUNT

OZMIN		EQU	ODATA+0E0H	;UHW MINIMUM Z FOR COGHEAD
OZMAX		EQU	ODATA+0F0H	;UHW MAXIMUM Z FOR COGHEAD

OSHOOT_ANIM	EQU	ODATA+100H	;UHL USE THIS ANIMATION TO SHOOT
ODEATH_ANIM	EQU	ODATA+120H	;UHL USE THIS ANIMATION FOR DEATH
OBLOCK_ANIM	EQU	ODATA+140H	;UHL USE THIS ANIMATION FOR BLOCKING
OSTOP_ANIM	EQU	ODATA+160H	;UHL USE THIS ANIMATION FOR STOPPING

OSHOOT_TIME	EQU	ODATA+180H	;UHW TIME SPENT SHOOTING
OLAST_BLOCK_TIME EQU	ODATA+190H	;UHW TIME SINCE LAST BLOCK
OLAST_HIT_TIME	EQU	ODATA+1A0H	;UHW TIME SINCE LAST BULLET HIT

;ENEMY FLAGS
*
*HMMMM I WONDER WHAT DOZER'S MOTHER WOULD SAY IF SHE READ SOME OF THIS?
*
B_SIDE		EQU	0		;DIRECTION
					;0 = HEADON MOTHER FUCKER
					;1 = SIDEWAYS MELLOW DUDE
B_ATTACK	EQU	1		;RESULT OF LAST ATTACK
B_CENTER	EQU	2		;GO TO THE CENTER OF THE SCREEN
B_FALLING	EQU	3		;NONBOY FALLING FROM SKY
B_FLIP		EQU	4		;HORIZONTALLY FLIPPED OUT WACKO
B_BIG		EQU	5		;BIGBOY IN YOUR FUKIN' FACE
B_BLOCKING	EQU	6		;IF=1, THEN COGHEAD IS BLOCKING
B_INVINCIBLE	EQU	7		;IF=1, THEN COGHEAD IS INVINCIBLE


M_SIDE		EQU	001H
M_ATTACK	EQU	002H
M_CENTER	EQU	004H
M_FALLING	EQU	008H
M_FLIP		EQU	010H
M_BIG		EQU	020H
M_BLOCKING	EQU	040H
M_INVINCIBLE	EQU	080H

HRUNVEL	EQU	-0140H		;HEADON RUN VELOCITY
SRUNVEL_MIN	EQU	01D000H		;SIDE RUN (TO THE RIGHT) VELOCITY 
SRUNVEL_MAX	EQU	01F000H		;SIDE RUN (TO THE RIGHT) VELOCITY 

SHOOTCNT	EQU	3

COG_FRAME_TIME	.EQU	5		;BASE SLEEP TIME BETWEEN FRAMES
					;!!WARNING!! - VALUE MUST BE > 2
COG_HITS_TO_KILL EQU	5		;HITS REQUIRED TO KILL COG HEAD
COGBUSTER_HITS_TO_KILL EQU	10	;HITS REQUIRED TO KILL BUSTER COG HEAD

COG_FLASH_COLOR	EQU	0101H		;FLASH COLOR FOR COGHEAD

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
COG_PROC
	MOVI	OID_COG,A0
	CALLA	GET_ENEMY_COUNT
	CMPK	1,A0
	JAHS	SUCIDE

	MOVI	COG_INIT,B0		;ALLOCATE OBJECT
	CALLA	CREATE_ENEMY
	JRZ	CP_EXIT			;NOTHING CLEAN, RIGHT.

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

	MOVE	A10,*A8(OZMIN),L	;STORE Z BOUNDS FOR LATER USE

	MOVIM	HRUNVEL,*A8(OHRUNVEL),L	;SET HEADON VELOCITY

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

*Cog head from the RIGHT
CP_RIGHT_SETUP
	MOVK	M_FLIPH,A6		;Flip him for Right/Left motion
	NEG	A0			;Oh! A negative X velocity would help
*Cog head - Jump here = he's from the LEFT. Fall through = he's from RIGHT
CP_LEFT_SETUP
	MOVK	M_SIDE,A7		;Mark him as a SIDE guy
	MOVE	A0,*A8(OXVEL),L
	MOVI	SIDE_RUN_ANIM,A1
	MOVIM	SIDE_SHOOT_DEATH_ANIM,*A8(ODEATH_ANIM),L
	MOVIM	SIDE_STOP_ANIM,*A8(OSTOP_ANIM),L
	JRUC	CP_DIRSET

*This guy will be a HEAD-ON man
CP_NORIGHT
	CLR	A7			;START AT HORIZON
	MOVE	A14,*A8(OZVEL),L
	MOVI	HEADON_RUN_ANIM,A1
	MOVIM	HEADON_SHOOT_DEATH_ANIM,*A8(ODEATH_ANIM),L
	MOVIM	HEADON_STOP_ANIM,*A8(OSTOP_ANIM),L
CP_DIRSET
	CALLA	STRT_ANIM		;START ANIMATION

	MOVIM	HEADON_SHOOT_ANIM,*A8(OSHOOT_ANIM),L

	MOVE	A9,A1
	CALLA	SET_SCRN_POS		;AND PUT THE GUY THERE
	CALLA	SetOnGrnd

	MOVI	COG_GUNVECT,A1	
	MOVI	COG_CVECT,A2		
	CALLA	SET_VECTORS		;GUN AND COLLISION VECTORS

	MOVKB	2,*A8(OSCRNOFFCNT)

	MOVI	1023,A0
	MOVI	512-1,A1		
	CALLA	RANGRAND
	MOVE	A0,*A8(OAPERCENT),W
	CALLA	GET_TSUL_SCRN

	MOVI	[8,8],A14
	ADDXY	A14,A1
	MOVE	A1,*A8(ORUNSIZE),L

	MOVE	@RAND,A0,W		;LEFTY OR RIGHTY?
	ANDI	M_FLIPH,A0

	OR	A0,A7	
	MOVE	A7,*A8(OEFLAGS),W

	BTST	B_SIDE,A7
	JRZ	CP_SETCTRL
	MOVE	A6,A0	
CP_SETCTRL
	MOVE	*A8(OCTRL),A14,W
	OR	A0,A14
	MOVE	A14,*A8(OCTRL),W

	MOVI	COG_FLASH_COLOR,A1
	CALLR	STORE_OCONST		;STORE THE PROPER VALUE FOR CONSTANT

	CALLA	INSERT_ENEMY		;INSERT AND COUNT ENEMY
	JRUC	COG_WATCH

CP_EXIT
	DIE

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
;	SLEEP	100
	CREATE	PID_IND,WALL_EXPLODE
	SLEEP	7
	MOVI	COG_INIT,B0		;ALLOCATE OBJECT
	CALLA	CREATE_ENEMY
	JRZ	CP_EXIT			;NOTHING CLEAN, RIGHT.

;	UNIVZ	8000H			;Turn world Z into universe Z
	MOVIM	-10000H,*A8(OZVAL),L	;Set universe Z position

	MOVIM	HRUNVEL,*A8(OHRUNVEL),L	;SET HEADON VELOCITY
	MOVIM	SRUNVEL_MAX,*A8(OSRUNVEL),L	;SET SIDE VELOCITY

	MOVI	C_B1BUSTA4,A1
	MOVE	*A8(OCTRL),A4,W
	CALLA	ANI

	MOVI	200,A1
	CALLA	SET_SCRN_POS		;AND PUT THE GUY THERE
	CALLA	SetOnGrnd

	MOVIM	-40000H,*A8(OYVEL),L	;SEND HIM UP
	MOVIM	4000H,*A8(OYACCEL),W	;AND MAKE HIM COME DOWN
	MOVIM	-0C0H,*A8(OZVEL),L	;AND MAKE HIM GO FORWARD

	MOVI	COG_FLASH_COLOR,A1
	CALLR	STORE_OCONST		;STORE THE PROPER VALUE FOR CONSTANT

	CALLA	INSERT_ENEMY		;INSERT AND COUNT ENEMY

	MOVIM	BUSTER_SHOOTER,*A8(OSHOOT_ANIM),L
	MOVIM	BUSTER_DEATH_ANIM,*A8(ODEATH_ANIM),L
	MOVIM	STANDING_BLOCK,*A8(OBLOCK_ANIM),L

	MOVI	COG_BUST_ANIM,A1
	CALLA	STRT_ANIM		;START HIS ANIMATION

COG_WATCH
	MOVE	A13,*A8(OPLINK),L
COG_WATCH_LOOP
	SLOOP	200,COG_WATCH_LOOP	;HERE WE WAIT FOR SHIT TO HAPPEN

**************************************************************************
*								         *
* COG_CVECT								 *
*								         *
**************************************************************************
COG_CVECT
	WWL	OID_PEXPLOSION,MASK_SUPP|MASK_TYPE|MASK_ID,COG_ROCKET_COLL
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
	CALLA	GET_HEAD_PART

	MOVB	*A8(OFLAGS+B_DEAD-7),A9		;IS THIS OBJECT DEAD?
	JRN	CG_DEAD				;BR = YES

	MOVE	@WAVETIME,A5,W		;KEEP THIS HERE, WE'LL NEED IT
	MOVE	A5,*A8(OLAST_HIT_TIME),W	;ALWAYS STORE THIS

	MOVE	A2,*A8(OPLAYER),L		;STORE PLAYER INFO FOR LATER???

	MOVE	*A8(OEFLAGS),A6,W

	BTST	B_INVINCIBLE,A6		;ARE WE CURRENTLY INVINCIBLE?
	JRNE	CG_DEAD			;BR = YES, JUST EXIT

	BTST	B_BLOCKING,A6		;ARE WE CURRENTLY BLOCKING?
	JRNE	CG_BLOCKED		;BR = YES, JUST SOUND AND CRUISE

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

	CLRB	*A8(OSHOOTCNT)		;CLEAR THE SHOOT COUNT

	JAUC	SetAnim			;AND FIRE IT OFF
*
*A6 MUST = OEFLAGS
*A9 MUST = OFLAG+B_DEAD-7
*
CG_TAKE_HIT
	clr	A5
	MOVI	COGBUSTER_HITS_TO_KILL,A1	;WE NEED THIS MANY HITS TO KILL
	MOVI	OHITS,A3		;This is the variable to use
	CALLA	HIT_ENEMY		;IS THIS GUY TOAST?
	JRHS	COG_DO_DEATH		;BR = OH YEAH!
*COG HEAD IS STILL ALIVE HERE
	MOVI	COG_UNFLASH,A7
	CALLA	OBJPROC_INT		;INTERRUPT COG WATCHER
	JRZ	CG_BLOCKED		;BR = NO COG WATCHER EXISTS

	MOVI	DMACNZ&(~DMAGO),A4
	CALLR	OBJ_DRAWBITS_MULTI	;FLASH HIM WHITE

	ORI	M_INVINCIBLE,A6
	MOVE	A6,*A8(OEFLAGS),W	;MAKE HIM NON-HITTABLE NOW

CG_BLOCKED
;	SOUND1	SND_SHIELD_HIT
CG_DEAD
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
	MOVI	DMAWNZ&(~DMAGO),A4
	CALLR	OBJ_DRAWBITS_MULTI
	SLEEP	2
	MOVE	*A8(OEFLAGS),A14,W
	ANDNI	M_INVINCIBLE,A14
	MOVE	A14,*A8(OEFLAGS),W
	RETP
	
**************************************************************************
*								         *
* OBJ_DRAWBITS_MULTI - GIVE ALL OF AN OBJECTS PARTS NEW DRAW BITS.	 *
* A4 = NEW DRAW BITS (LOW FOUR OF OCTRL ONLY)				 *
* A8 = PTR TO FIRST PART TO TURN "ON"					 *
*								         *
**************************************************************************
OBJ_DRAWBITS_MULTI
	PUSH	A8
ODM_LP
	MOVB	*A8(OCTRL),A14
	SRL	4,A14
	SLL	4,A14
	OR	A4,A14
	MOVB	A14,*A8(OCTRL)
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
	JRUC	COG_GEN_COLL

**************************************************************************
*								         *
* COG_ROCKET_COLL - COLLISION WITH COGHEAD AND A ROCKET			 *
* A0 = PTR TO ROCKET							 *
* A8 = PTR TO COGHEAD							 *
*								         *
**************************************************************************
COG_ROCKET_COLL
	CALLA	GETHEADPART			;GET THE KILLERS HEAD
	MOVE	A0,A5				;KEEP KILLER HERE
	MOVE	*A0(OID),A0,W			;GET PLAYER DATA ADDRESS
	CALLA	POID_TO_PDATA
COG_GEN_COLL
	CALLA	GET_HEAD_PART
	MOVE	A2,*A8(OVAR9),L

	MOVB	*A8(OFLAGS+B_DEAD-7),A9		;IS THIS OBJECT DEAD?
	JRN	CRC_DEAD			;BR = YES

	MOVE	*A8(OEFLAGS),A6,W
	
	MOVE	A2,A2
	JRZ	CRC_NOSCORE			;BR = NO SCORE

	MOVK	10,A0
	CALLA	RANDU
	MOVE	A0,A1
	MOVI	1000,A0
	MPYU	A0,A1
	CALLA	PRINT_SCORE

CRC_NOSCORE
*
*THIS IS AN ENTRYPOINT FOR OTHER ROUTINES
*NOTHING SHOULD BE PUSHED
*A5 = PTR TO ACCOMPANYING EXPLOSION, 0 MEANS THERE ISN'T ONE.
*A9 = OFLAGS+B_DEAD-7
COG_DO_DEATH
	ADDI	M_DEAD >> 3,A9
	MOVB	A9,*A8(OFLAGS+B_DEAD-7)

	MOVE	*A8(ODEATH_ANIM),A1,L
	.IF DEBUG
	JRZ	$
	.ENDIF

	MOVE	A5,A5
	jrnz	CRC_Explosion
*This is the bullet death thing
	MOVIM	-20000H,*A8(OYVEL),L	;SEND HIM UP
	MOVIM	4000H,*A8(OYACCEL),W	;AND MAKE HIM COME DOWN
	MOVI	1C0H,A14
	MOVE	A14,*A8(OZVEL),L	;AND MAKE HIM GET BLOWN BACK
	jruc	CRC_Death_Anim
CRC_Explosion
	MOVIM	-40000H,*A8(OYVEL),L	;SEND HIM UP
	MOVIM	4000H,*A8(OYACCEL),W	;AND MAKE HIM COME DOWN
	MOVI	2C0H,A14
	MOVE	A14,*A8(OZVEL),L	;AND MAKE HIM GET BLOWN BACK
	MOVE	A14,*A5(OZVEL),L	;AND HIS LITTLE DOG TOO
CRC_Death_Anim
	MOVE	A1,*A8(AnimFrm),L
	CLR	A14
	MOVB	A14,*A8(AnimSlp)
CRC_DEAD
	RETS

**************************************************************************
*								         *
* 		ANIM FUNCS ABOUND IN THIS CRAZY WORLD			 *
*								         *
**************************************************************************

**************************************************************************
*								         *
* A_CHECK_SCREEN - CHECK UP ON THE COG MAN AND SEE IF HE'S OFFSCREEN	 *
* 		OR WHAT.						 *
* 		IF IT IS OFFSCREEN, THEN WE DELETE WITH NO PLAYER	 *
* 		KILL CREDIT.						 *
* 									 *
* PASS:									 *
* A8 = PTR TO OBJECT							 *
*								         *
**************************************************************************
A_CHECK_SCREEN
	MOVE	*A8(OZVAL),A2,L
	move	@ZBASE,a14,L
	sub	a14,a2
	CMPI	ZMAX_REAL,A2
	JALT	DEL_ENEMY_NOAUD		;BR = ENEMY IS BEYOND VISIBLE Z

	MOVB	*A8(OFLAGS),A14
	JRNN	ACS_DONE

	MOVB	*A8(OSCRNOFFCNT),A14
	DEC	A14
	JAZ	DEL_ENEMY_NOAUD			;BR = BEHIND THE PLAYERS
	MOVB	A14,*A8(OSCRNOFFCNT)
ACS_DONE
	RETS

**************************************************************************
*								         *
* A_CHECK_FIRE - CHECK UP ON ENEMY AND LET'S SEE IF IT WANTS TO FIRE	 *
* 		  HIS GUN						 *
* 									 *
* PASS:								         *
* A8 = PTR TO OBJECT							 *
*								         *
**************************************************************************
A_CHECK_FIRE
	MOVE	*A8(OZVAL),A2,L
	move	@ZBASE,a14,L
	sub	a14,a2
	CMPI	ZMAX_REAL,A2
	JALT	DEL_ENEMY_NOAUD		;BR = ENEMY IS BEHIND OF PLAYERS 		

;	MOVB	*A8(OSHOOTCNT),A1
;	INC	A1
;	CMPK	SHOOTCNT,A1
;	JRLT	ACF_EXIT
;	CLR	A1

	MOVE	@NPLAYERS,A5,W
	MOVI	P1DATA,A9

	MOVE	*A8(ODAG),A6,L
	MOVE	*A8(OSIZE),A7,L
	ADDXY	A6,A7

ACF_BOX_LUPE
	MOVE	*A9(POBJ),A14,L
	JRZ	ACF_NEXT		;BR = PLAYER NOT ACTIVE

	MOVE	*A9(PHITBOXUL),A4,L
	MOVE	*A9(PHITBOXLR),A3,L

*
*	BOX OVERLAP COLLISION
*
*	A6 = Top left, box 1
*	A7 = Bottom right, box 1  
*	A4 = Top left, box 2  
*	A3 = Bottom right, box 2 
*
	cmpxy	A6,A3
	jrxle	ACF_NEXT
	jryle	ACF_NEXT
	cmpxy	A4,A7
	jrxle	ACF_NEXT
	jryle	ACF_NEXT

	JRUC	ACF_LET_EM_HAVE_IT

ACF_NEXT
	ADDI	PDSIZE,A9
	DSJ	A5,ACF_BOX_LUPE
ACF_EXIT
;	MOVB	A1,*A8(OSHOOTCNT)
	RETS

ACF_LET_EM_HAVE_IT
	MOVE	@XSCROLL,A0,L
	JRNZ	ACF_SKATE_AND_SHOOT
	MOVB	A1,*A8(OSHOOTCNT)
	MOVE	*A8(OSTOP_ANIM),A1,L	;Got to stop and shoot
	.IF DEBUG
	JRZ	$
	.ENDIF
	JAUC	SetAnim

ACF_SKATE_AND_SHOOT
	RETS

**************************************************************************
*								         *
* A_STANDING_DECISION - Anim Function to make a decision while stopped,	 *
* 			standing and facing player.			 *
* A8 = PTR TO ANY PART							 *
*								         *
**************************************************************************
A_STANDING_DECISION
	CALLA	GET_HEAD_PART
	CALLA	RANDOM
	JRN	ASD_BLOCK
	MOVI	HEADON_SHOOT_ANIM,A1
	JAUC	SetAnim
ASD_BLOCK
	MOVI	STANDING_BLOCK,A1
	JAUC	SetAnim

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
	JRNZ	ASRD_BRANCH
	RETS
ASRD_BRANCH
	CALLA	GETAFARG_LONG
	MOVE	A0,A1
	JAUC	SetAnim

**************************************************************************
*								         *
* A_STAND_FIRE_DECISION - Anim Function to decide if we should fire	 *
* 				again.					 *
* A8 = PTR TO FIRING PART						 *
* AARG+,L = ANIM BRANCH IF WE SHOULD FIRE AGAIN				 *
*								         *
**************************************************************************
A_STAND_FIRE_DECISION
	CALLA	RANDOM
	JRN	ASFD_BRANCH
	RETS
ASFD_BRANCH
	CALLA	GETAFARG_LONG
	MOVE	A0,A1
	JAUC	SetAnim

**************************************************************************
*								         *
* A_INITIALIZE_FIRING - DO ANY FIRING VARIABLE INITIALIZATION THAT	 *
* 			MIGHT BE NECESSARY.				 *
* A8 = PTR TO PART DOING THE FIRING					 *
*								         *
**************************************************************************
A_INITIALIZE_FIRING
	MOVE	@WAVETIME,A14,W
	MOVE	A14,*A8(OSHOOT_TIME),W
	CLR	A14
	MOVB	A14,*A8(OMISSES)
	RETS

**************************************************************************
*								         *
* A_FIRE_FNC - ANIM FUNC, FOR NORMAL GUN PART FIRE.			 *
* A8 = PTR TO ARM PART DOING THE FIRING.				 *
* AARG+,L = [Y,X] FIRING OFFSET.					 *
* AARG+,L = [INT,FRAC] HIT POINTS TO TAKE				 *
*								         *
**************************************************************************
A_FIRE_FNC
	CALLA	GET_HEAD_PART_A0

	MOVE	*A0(OSHOOT_TIME),A3,W
	ADDI	28,A3
	MOVE	A3,*A0(OSHOOT_TIME),W

	MOVB	*A8(OFLAGS+B_DEAD-7),A14	;IS THIS OBJECT DEAD?
	JRN	AFF_X				;BR = YES

	CALLA	GETAFARG_LONG		;GET THE FIRING OFFSET
	MOVE	A0,A3
	CALLA	GETAFARG_LONG
	MOVE	A0,A5
	CALLA	EGUN_FLASH_MULTI	;MAKE A GUN FLASH

	CALLA	CK_PLAYER_HIT
	JRNZ	AFF_HIT			;BR = Successful hit on Player(s)
	JRNC	AFF_NOHIT		;BR = No hit, but he was visible
 	jruc	AFF_NOHIT_No_Sound	;He did'nt hit because he was not visible
AFF_HIT
	CLRB	*A8(OMISSES)		;We did not miss
	SOUNDZ	SND_COG_FIRE
	JRUC	AFF_X
AFF_NOHIT
	SOUNDZ	SND_COG_FIRE
AFF_NOHIT_No_Sound
	MOVB	*A8(OMISSES),A14
	INC	A14
	CMPK	2,A14
	JRLO	AFF_TRY_AGAIN
	MOVI	SIDE_RUN_ANIM,A1
	JAUC	SetAnim
AFF_TRY_AGAIN
	MOVB	A14,*A8(OMISSES)
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

	MOVI	[2,0],A5
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
	MOVE	*A8(OEFLAGS),A14,W
	ANDNI	M_SIDE,A14
	MOVE	A14,*A8(OEFLAGS),W
	MOVIM	STANDING_BLOCK,*A8(OBLOCK_ANIM),L
	MOVIM	HEADON_SHOOT_DEATH_ANIM,*A8(ODEATH_ANIM),L
	JAUC	CLR_VEL

**************************************************************************
*								         *
* A_GROUND_CK - Anim Function to check if an object is above ground.	 *
* 		If it is, then branch.					 *
* A8 = Ptr to object							 *
* AARG+,L = Branch							 *
*								         *
**************************************************************************
A_GROUND_CK
	CALLA	DIST_FROM_GROUND
	JRLE	AGC_X
	CALLA	GETAFARG_LONG
	MOVE	A0,A1
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
	CLR	A14
	MOVE	A14,*A8(OYVEL),L
	MOVE	A14,*A8(OYACCEL),W
	JAUC	SetOnGrnd

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
* A_RANDOM_RAPID_COUNT - Anim Func to load a random Rapid Fire count.	 *
* A8 = Ptr to part doing the firing					 *
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
* A_JUMP_TO_SHOOT - Anim Func to jump to the animation stored in	 *
* 			OSHOOT_ANIM					 *
* A8 = Ptr to HEAD part							 *
*								         *
**************************************************************************
A_JUMP_TO_SHOOT
	MOVE	*A8(OSHOOT_ANIM),A1,L
	.IF DEBUG
	JRZ	$
	.ENDIF
	JAUC	SetAnim

**************************************************************************
*								         *
* A_LOAD_OBLOCK - Anim Func to load the OBLOCK_ANIM field of		 *
* 		the object.						 *
* A8 = Ptr to Object							 *
* AARG+,L = Address to load						 *
*								         *
**************************************************************************
A_LOAD_OBLOCK
	CALLA	GETAFARG_LONG
	MOVE	A0,*A8(OBLOCK_ANIM),L
	RETS

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
	MOVE	@WAVETIME,A5,W
	MOVE	*A8(OSHOOT_TIME),A3,W
	CMP	A5,A3
	JRLO	ACU_MUST_TO_SHOOT_NOW
*LOOK FOR NEGATIVE INCOMING FIRE
	MOVE	*A8(OLAST_HIT_TIME),A3,W
	MOVE	A5,A14
	SUB	A3,A14			;CHECK THE ELAPSED TIME SINCE LAST HIT
	CMPK	20,A14			;HAS IT BEEN TOO LONG?
	JRGE	ACU_MUST_TO_SHOOT_NOW	;BR = YES
*CHECK FOR MAXIMUM BLOCK TIME
	MOVE	*A8(OLAST_BLOCK_TIME),A3,W
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
* 		LET'S GET DOWN AND DATA!				 *
*								         *
**************************************************************************

	.DATA

*
*SOME SOUNDS FOR YOU
*
SND_HIT
	.WORD	0F305H,5,08108H,0	;COG TAKES A REAL HIT
SND_SHIELD_HIT
	.WORD	0F305H,5,08322H,0	;HIT HIS SHIELD
SND_ROCKET_HIT	
	.WORD	0F331H,184,08234H,0

SND_COG_FIRE
	.WORD	0F305H,25,0810bH,0	;CogHead fire sound

COG_INIT
	.byte	 1, 0, 1, 0	;OBJCNT, PRCCNT, IMGPALCNT, PALCNT
	.long	C_B3SKATEC1	;IMGPAL
	.word	OID_COG, OM_DUMCOLL
*
*    .long IMG
*    .word OCTRL, OFLAGS, OZOFF, OPTION_FLAGS
*
	LWWWW	C_B3SKATEC1, DMAWNZ, 0,	0, 0


HEADON_RUN_ANIM
SIDE_RUN_ANIM
	LWL	C_B3SKATEC1,COG_FRAME_TIME|AFunc,A_CHECK_SCREEN
	LW	C_B3SKATEC2,COG_FRAME_TIME
	LW	C_B3SKATEC3,COG_FRAME_TIME
	LWL	C_B3SKATEC4,COG_FRAME_TIME|AFunc,A_CHECK_FIRE
	LWL	C_B3SKATEC5,COG_FRAME_TIME|AFunc,A_CHECK_SCREEN
	LW	C_B3SKATEC6,COG_FRAME_TIME
	LWL	C_B3SKATEC7,COG_FRAME_TIME|AFunc,A_CHECK_FIRE
	LWL	C_B3SKATEC8,COG_FRAME_TIME|AFunc,A_CHECK_SCREEN
	LW	C_B3SKATEC9,COG_FRAME_TIME

	.LONG	0

HEADON_STOP_ANIM
SIDE_STOP_ANIM
	LWLW	C_B3SKxSTA3,COG_FRAME_TIME|AFunc,A_SHIFT_XVEL+1,1
	LW	C_B3SKxSTA4,COG_FRAME_TIME
	LWLW	C_B3SKxSTA5,COG_FRAME_TIME|AFunc,A_SHIFT_XVEL+1,1
	LWL	C_B3SKxSTA6,COG_FRAME_TIME|AFunc,A_FACE_CLR_VEL
	LWL	C_B3SKxSTA8,COG_FRAME_TIME|AFunc,A_JUMP_TO_SHOOT

HEADON_SHOOT_ANIM
	LWL	C_B1SHOOTA1,COG_FRAME_TIME|AFunc,A_INITIALIZE_FIRING
STAND_SHOOT
	LWL	C_B1SHOOTA2,COG_FRAME_TIME|AFunc,A_RANDOM_RAPID_COUNT
STAND_RAPID_FIRE
	LWLWWL	C_B1SHOOTA2,COG_FRAME_TIME-1|AFunc,A_FIRE_FNC+4,12,-91,[1,0]
	LW	C_B1SHOOTA3,(COG_FRAME_TIME-1)
	LWLL	1,1|AFunc,A_STAND_RAPIDFIRE_DECISION+2,STAND_RAPID_FIRE
	LW	C_B1SHOOTA2,COG_FRAME_TIME
	LW	C_B1SHOOTA4,4
	LWLL	1,1|AFunc,A_AnimFrm+2,STAND_SHOOT

*THROW A BLOCK WHILE STANDING FORWARD AND FIRING
STANDING_BLOCK
	LWL	C_B1SHOOTA6,COG_FRAME_TIME|AFunc,A_SET_BLOCKTIME
HOLD_BLOCK
	LW	C_B1SHOOTA7,COG_FRAME_TIME
	LWLL	1,1|AFunc,A_CHECK_UNBLOCK+2,HOLD_BLOCK
UNBLOCK_ANIM
	LW	C_B1SHOOTA6,COG_FRAME_TIME-2
	LWL	1,1|AFunc,A_CLR_BLOCK
	LWL	1,1|AFunc,A_JUMP_TO_SHOOT

BUSTER_DEATH_ANIM
	LWLL	1,1|AFunc,A_SOUND+2,SND_ROCKET_HIT
HEADON_SHOOT_DEATH_ANIM
	LW	C_B1DEATHA2,COG_FRAME_TIME
	LW	C_B1DEATHA3,COG_FRAME_TIME
SIDE_SHOOT_DEATH_ANIM
	LW	C_B1DEATHA4,COG_FRAME_TIME
COG_HSDA_GROUND_WAIT
	LWLL	1,1|AFunc,A_GROUND_CK+2,COG_HSDA_GROUND_WAIT
	LWL	C_B1DEATHA5,1|AFunc,A_HIT_GROUND
	LWLL	1,(COG_FRAME_TIME-1)|AFunc,A_SET_OZVEL+2,0
	LW	C_B1DEATHA6,COG_FRAME_TIME
	LWL	C_B1DEATHA7,60|AFunc,A_CLR_OXVEL
	LWL	1,1|AFunc,DELETE_ENEMY
	
	
*
*COGHEAD BUSTING THROUGH THE NON-POSTER
*
COG_BUST_ANIM
	LWLL	1,1|AFunc,A_GROUND_CK+2,COG_BUST_ANIM
	LWL	C_B1BUSTA5,4|AFunc,A_HIT_GROUND
	LWLL	C_B1BUSTA4,4|AFunc,A_SET_OZVEL+2,0
	LW	C_B1BUSTA8,20
	LWLWW	1,1|AFunc,A_RAND_AnimSLP+2,15,25
	LWL	1,0|AFunc,A_SET_BLOCK_AND_BUST_VECT
	LWL	C_B3SKxSTA8,COG_FRAME_TIME|AFunc,A_CLR_BLOCK
	LWL	C_B1SHOOTA1,COG_FRAME_TIME|AFunc,A_INITIALIZE_FIRING
BUSTER_SHOOTER
	LWL	C_B1SHOOTA2,COG_FRAME_TIME|AFunc,A_RANDOM_RAPID_COUNT
BUSTER_RAPID_FIRE
	LWLL	1,1|AFunc,A_SOUNDZ+2,SND_COG_FIRE
	LWLWW	C_B1SHOOTA2,COG_FRAME_TIME-1|AFunc,A_BUSTER_FIRE_FNC+2,12,-91
	LW	C_B1SHOOTA3,(COG_FRAME_TIME-2)
	LWLL	1,1|AFunc,A_STAND_RAPIDFIRE_DECISION+2,BUSTER_RAPID_FIRE
	LW	C_B1SHOOTA2,COG_FRAME_TIME
;	LWLWW	C_B1SHOOTA4,1|AFunc,A_RAND_AnimSLP+2,4,12
	LW	C_B1SHOOTA4,4
;	LW	1,0
	LWLL	1,1|AFunc,A_AnimFrm+2,BUSTER_SHOOTER

