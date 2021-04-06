 	.MLIB	"GXMACS.LIB"
 	.FILE	"GXUNIFX.ASM"
	.TITLE	" <<< GENERATION X -- UNIVERSE FX ROUTINES >>>"
	.WIDTH	132
	.OPTION	B,D,L,T
	.MNOLIST

**************************************************************************
*								         *
* 	COPYRIGHT (C) 1992 MIDWAY MANUFACTURING COMPANY.		 *
* 		       ALL RIGHTS RESERVED.				 *
*								         *
**************************************************************************

*	GET THE SYSTEM STUFF
	.INCLUDE	"GX.INC"
	.INCLUDE	"GXHELI.H"
	.INCLUDE	"GXCONTRL.H"
	.INCLUDE	"IMGTBL.GLO"
	.INCLUDE	"GXKLUDGE.H"
	.INCLUDE	"GXUNIFX.TBL"

* SYMBOLS IN HERE
	.DEF	COPTER_INTRO_CVECT, CHECK_FREAK_SPEECH 
	.DEF	WALL_EXPLODE
	.DEF	MAKE_CAT_PROC, CAT_DONE, GITTEN_KITTEN, GOT_TROG, MAKE_TROG_PROC
	.DEF	MAKE_INTRO_COPTER_PROC
	.DEF	MAKE_ROPE_LADDER
	.DEF	MAKE_CEILING_SMOKE,MAKE_CEILING_DEBRIS
	.DEF	PROC_AIR_RAID_SIREN
	.DEF	START_SIGN_FLASH

* SYMBOLS FROM GXHELI.ASM
	.REF	SIDE_COPTER_INTRO_INIT, SND_COPTER_FULL
	.REF	SIDE_COPTER_INTRO_COLLISIONS

* SYMBOLS IN GXKLUDGE.H
	.REF	ROPLAD4, NEONCX2, GLAMPH2, FLASHBULB1

***** From GXAFUNC.ASM
	.REF	A_BRANCH_IF_FALSE

***** from GXBLOOD.ASM
	.REF	SMALL_BLOOD_HIT

	.BSS	WALL_FLAG,8		;WALL STATE FLAG
	.BSS	CAT_DONE,8		;ARE WE DONE FUCKIN' WITH THE CAT? FLAG
	.bss	GITTEN_KITTEN,16	;If 1, then he killed the cat
	.BSS	GOT_TROG,16		;If 1, then he killed TROG
	.BSS	TROG_ALIVE,16		;Means Trog has been created
;	.bss	filler,16		; to keep long word aligned
	.TEXT
	.EVEN

**************************************************************************
*								         *
* START_SIGN_FLASH - FIND SIGN FLASH OBJECTS AND START THEIR ANIMATIONS	 *
* 									 *
* PASS:									 *
* NUTIN'								 *
* RETURN:								 *
* NUTIN'								 *
*								         *
**************************************************************************

START_SIGN_FLASH
	MOVI	FGLIST,A2
	MOVE	A2,A8
	MOVI	NEONCX2,A3			;IMAGES TO FIND
	MOVI	GLAMPH2,A4
	MOVI	FLASHBULB1,A5
	MOVK	3,A6				;ANIMATE THIS NUMBER OF IMAGES
SSF_LUPE
	MOVE	*A8,A8,L
	CMP	A2,A8
	JREQ	SSF_DONE			;BR=END OF LIST

	MOVE	*A8(OIMG),A14,L
	CMP	A3,A14
	JREQ	SSF_ANIM			;BR=MATCH
	CMP	A4,A14
	JREQ	SSF_ANIM			;BR=MATCH
	CMP	A5,A14
	JRNE	SSF_LUPE			;BR=NO MATCH
SSF_ANIM
	MOVE	*A8(OULINK),A0,L
	MOVE	*A0(MAP_IMG),A1,L
	ANDNI	M_IF_DANIM,A1
	MOVE	A1,*A0(MAP_IMG),L
	BTST	B_IF_DAM,A1
	JRZ	SSF_GO				;BR=NO DAMAGE TABLE
	SRL	4,A1
	SLL	4,A1
	MOVE	*A1,A1,L
SSF_GO
	SRL	4,A1
	SLL	4,A1
	CALLA	STRT_ANIM
	DEC	A6
	JRNZ	SSF_LUPE
SSF_DONE
	RETS

**************************************************************************
*								         *
* MAKE_CEILING_DEBRIS - CEILING CAVE-IN WITH SMOKE AND CEILING CHUNKS	 *
*								         *
**************************************************************************

MAKE_CEILING_DEBRIS
	MOVI	07C760H,B0		;OZVAL
	MOVI	08H,B1			;MIN X
	MOVI	0A8H,B2			;MAX X
	CLR	B3			;MIN X VEL
	CLR	B4			;MAX X VEL

	MOVI	-06AH,B5		;MIN Y
	MOVI	-06AH,B6		;MAX Y

	MOVI	08000H,B7		;MIN Y VEL
	MOVI	040000H,B8		;MAX Y VEL

	CLR	B9			;MIN Z VEL
	MOVI	0100H,B10		;MAX Z VEL
	MOVI	DEBRIS_SMOKE_FRAG,B14	;SCRIPT
	CALLA	Fragger

	CLR	B9			;MIN Z VEL
	CLR	B10			;MAX Z VEL
	MOVI	DEBRIS_SMOKE_FRAG,B14	;SCRIPT
	CALLA	Fragger

	MOVI	07C75FH,B0		;OZVAL
	CLR	B7			;MIN Y VEL
	MOVI	0800H,B8		;MAX Y VEL
	MOVI	DEBRIS_CCHUNK_FRAG,B14	;SCRIPT
	CALLA	Fragger

	SOUND1	SND_PREBUST		;MAKE BOOM SOUND!

	DIE

**************************************************************************
*								         *
* F_CCHUNK_STUFF - STUFF GRAVITY AND GROUND COLLISION			 *
*								         *
* A0 = Ptr to un-inserted object.					 *
* 									 *
* Note: Frag funcs must preserve A8-A11 and all B-File regs.		 *
*								         *
**************************************************************************

F_CCHUNK_STUFF
	MOVI	03000H,A14
	MOVE	A14,*A0(OYACCEL),W
	MOVI	CCHUNK_COLL,A14
	MOVE	A14,*A0(OCVECT),L	;Set up chunk with Vectors	
	RETS

**************************************************************************
*								         *
* CCHUNK COLLISION TABLE						 *
*								         *
**************************************************************************

CCHUNK_COLL
	WWL	OID_GRND,0FFFFH,CCHUNK_GROUND_COLL
	WL	0,DUMCRETS

**************************************************************************
*								         *
* CCHUNK_GROUND_COLL - GROUND COLLISION ROUTINE				 *
* 									 *
* PASS:									 *
* A8 = OBJECT								 *
*								         *
**************************************************************************

CCHUNK_GROUND_COLL
	JAUC	DELETE_OBJ
;	CLR	A14
;	MOVE	A14,*A8(OYACCEL),W
;	MOVE	A14,*A8(OYVEL),L
;	MOVE	A14,*A8(OZVEL),L
;	JAUC	SET_ONGRND

**************************************************************************
*								         *
* DEBRIS FRAGMENT TABLES AND ANIMS					 *
*								         *
**************************************************************************

DEBRIS_SMOKE_FRAG
	.long	SMOKE_ANIM,0
	.word	OID_JUNK,(15 << 11) + (1 << 6) + (FRGNOFLY+FRGPAL)
	.long	0

DEBRIS_CCHUNK_FRAG
	.long	CCHUNK1_ANIM,F_CCHUNK_STUFF
	.word	OID_JUNK,(5 << 11) + (1 << 6) + (FRGNOFLY+FRGPAL+FRGGCOL)
	.long	CCHUNK2_ANIM,F_CCHUNK_STUFF
	.word	OID_JUNK,(5 << 11) + (1 << 6) + (FRGNOFLY+FRGPAL+FRGGCOL)
	.long	CCHUNK3_ANIM,F_CCHUNK_STUFF
	.word	OID_JUNK,(5 << 11) + (1 << 6) + (FRGNOFLY+FRGPAL+FRGGCOL)
	.long	0

CCHUNK1_ANIM
	LWL	RFCHUNK1,1|AFunc,PULL_ANIM

CCHUNK2_ANIM
	LWL	RFCHUNK2,1|AFunc,PULL_ANIM

CCHUNK3_ANIM
	LWL	RFCHUNK3,1|AFunc,PULL_ANIM

**************************************************************************
*								         *
* MAKE_CEILING_SMOKE - CREATE SMOKE FOR TRANSITION THROUGH CEILING	 *
*								         *
**************************************************************************

MAKE_CEILING_SMOKE
	MOVI	07DD98H,B0		;OZVAL
	MOVI	08H,B1			;MIN X
	MOVI	0A8H,B2			;MAX X
	CLR	B3			;MIN X VEL
	CLR	B4			;MAX X VEL

	MOVI	-090H,B5		;MIN Y
	MOVI	-08AH,B6		;MAX Y

	MOVI	-020000H,B7		;MIN Y VEL
	MOVI	-08000H,B8		;MAX Y VEL
	MOVI	-0200,B9		;MIN Z VEL
	CLR	B10			;MAX Z VEL
	MOVI	SMOKE_FRAG,B14		;SCRIPT
	CALLA	Fragger

	MOVI	-080000H,B7		;MIN Y VEL
	MOVI	-010000H,B8		;MAX Y VEL
	MOVI	SMOKE_FRAG,B14		;SCRIPT
	CALLA	Fragger

	DIE

**************************************************************************
*								         *
* SMOKE FRAGMENT TABLE AND ANIM						 *
*								         *
**************************************************************************

SMOKE_FRAG
	.long	SMOKE_ANIM,0
	.word	OID_JUNK,(20 << 11) + (1 << 6) + (FRGNOFLY+FRGPAL)
	.long	0

SMOKE_ANIM
	LW	SMOKTR1,3
	LW	SMOKTR2,3
	LW	SMOKTR3,3
	LW	SMOKTR4,4
	LW	SMOKTR5,4
	LW	SMOKTR6,4
	LW	SMOKTR1,3
	LW	SMOKTR2,3
	LW	SMOKTR3,3
	LW	SMOKTR4,4
	LW	SMOKTR5,4
	LW	SMOKTR6,4
	LWL	1,1|AFunc,DELETE_OBJ
	
**************************************************************************
*								         *
* MAKE_ROPE_LADDER - CREATE SEGMENTS AND MAKE ROPE LADDER FALL		 *
*								         *
**************************************************************************

MAKE_ROPE_LADDER

	MOVI	ROPLAD4,A2			;STATIC ROPE LADDER IMAGE
	MOVI	-0228000H,A3			;UNIVERSE X
;	MOVI	05D9DAH,A4			;UNIVERSE Z
	MOVI	067000H,A4			;UNIVERSE Z
	MOVE	@UNIV_ID,A5			;GET ID
	MOVI	080000000H,A6
	MOVK	3,A7				;NUMBER OF LADDER PARTS - 1
	MOVI	ROPE_Y_TABLE,A8			;TABLE OF UNIVERSE Y VALUES
	CLR	A9				;MAP_FLAGS

MRL_LUPE
	CALLA	GET_FREE_LINK			;GET-A-LINK
	.if	DEBUG
	LOCKON	Z
	.else
	JAZ	SUCIDE
	.endif

	MOVE	A9,*A0(MAP_FLAGS),L		;INITIALIZE LINK FLAGS

	CMPK	1,A7
	JRNE	MRL_GO				;BR=THIS IS NOT THE ANIMATION
	MOVI	ROPE_LADDER_ANIM+M_IF_SEQ,A2	;ANIMATING FALL DOWN LADDER
MRL_GO
	MOVE	A2,*A0(MAP_IMG),L		;SET IMAGE

	MOVE	A3,*A0(MAP_X),L			;SET UNIVERSE POSITION
	MOVE	*A8+,A14,W
	SLL	12,A14
	MOVE	A14,*A0(MAP_Y),L  
	MOVE	A4,*A0(MAP_Z),L	

	MOVE	A5,*A0(MAP_ID),W		;SET ID	
	MOVE	A6,*A0(MAP_OBJ),L		;RESET OBJECT	
	CALLA	INSERT_LINK
	
	DSJ	A7,MRL_LUPE

	MOVK	1,A0
	MOVE	A0,@UNIVERR,W			;FORCE CREATION BY UPDATE_UNIV

	DIE

ROPE_Y_TABLE
	.WORD	-0E40H,-09C0H,-0538H,-0140H

ROPE_LADDER_ANIM
	LWLL	ROPLAD1,4|AFunc,A_SOUND+2,SND_ROPE_LADDER
	LW	ROPLAD2,4
	LW	ROPLAD3,4
	LWL	ROPLAD4,1|AFunc,PULL_ANIM
	
SND_ROPE_LADDER
	.WORD	0F341H,19,083A0H,0		;Rope ladder falls
	
**************************************************************************
*								         *
* WALL_EXPLODE - MAKE WALL GO BOOM! NOTE: THIS IS A PROCESS NOW!	 *
*								         *
**************************************************************************

NUM_BRICK_GROUPS	EQU	8
NUM_BRICKS		EQU	16

WALL_EXPLODE
	CLR	A14			
	MOVB	A14,@WALL_FLAG			;RESET WALL_FLAG

	MOVI	FGLIST,A9
	MOVE	A9,A0
WE_FIND_WALL_LUPE				;FIND WALL OBJECT
	MOVE	*A9,A9,L
	CMP	A0,A9
	LOCKON	EQ				;PROBLEM, IF IT DOESN'T EXIST 
	MOVE	*A9(OID),A14,W
	CMPI	(OID_UNIV|ID_5)&(MASK_TYPE|MASK_ID),A14
	JRNE	WE_FIND_WALL_LUPE		;BR=NO OID MATCH

	CREATE	PID_IND,EXPLOSION_4_WALL	;FINISH IT UP!
	SLEEP	5

	MOVK	NUM_BRICK_GROUPS,A10
	MOVI	WALL_FRAGMENT_TABLE,A11
WE_MASTER_LUPE
	MOVE	*A9(OYVAL),A2,L
	MOVE	*A9(OXVAL),A3,L
	MOVE	*A9(OZVAL),A4,L
	DEC	A4				;Z IN FRONT OF THE WALL
	MOVK	NUM_BRICKS,A6
WE_LUPE		
	MOVK	4,A0				;GET RANDOM TABLE INDEX
	CALLA	RAND0
	SLL	5,A0
	ADD	A11,A0
	MOVE	*A0,A5,L			;GET TABLE ENTRY			
	CALLA	CREATE_OBJ
	JRZ	WE_NEXT
	MOVE	A0,A8	

	MOVI	158,A0				;GET RANDOM Y PIXEL OFFSET
	MOVK	23,A1
	CALLA	RANGRAND
	SLL	15,A0				;CONVERT TO WORLD
	MOVE	A2,A14				;GET WALL OYVAL
	SUB	A0,A14				;COMPUTE BRICK OYVAL
	MOVE	A14,*A8(OYVAL),L
	SUBI	90 << 15,A0			;COMPUTE OYVEL
	NEG	A0
	SRA	6,A0				
	MOVE	A0,*A8(OYVEL),L

	
	MOVI	73,A0				;GET RANDOM X PIXEL OFFSET
	MOVI	-63,A1
	CALLA	RANGERND
	SLL	15,A0				;CONVERT TO WORLD
	MOVE	A3,A14				;GET WALL OXVAL
	ADD	A0,A14				;COMPUTE BRICK OXVAL
	MOVE	A14,*A8(OXVAL),L
	SRA	6,A0				;COMPUTE OYVEL
	MOVE	A0,*A8(OXVEL),L

	MOVE	A4,*A8(OZVAL),L			;SET Z			

	MOVI	-1,A0				;RANDOM Z VELOCITY
	MOVI	-4,A1
	CALLA	RANGERND
	SLL	7,A0
	MOVE	A0,*A8(OZVEL),L

	CALLA	RANDOM				;RANDOM FLIPPING
	ANDI	M_FLIPV|M_FLIPH,A0
	MOVE	*A8(OCTRL),A14,W
	OR	A0,A14
	MOVE	A14,*A8(OCTRL),W

	CALLA	INSERT_OBJ
WE_NEXT
	DSJ	A6,WE_LUPE
	CMPI	NUM_BRICK_GROUPS-1,A10
	JRNE	WE_NOPE				;BR=DON'T DO IT
	CREATE	PID_IND,FINISH_WALL_EXPLODE	;FINISH IT UP!
WE_NOPE
	SLEEP	1
	DSJ	A10,WE_MASTER_LUPE
	DIE

**************************************************************************
*								         *
* EXPLOSION_4_WALL - PROCESS TO FIRE OFF A PRE-EXPLOSION FOR THE WALL.	 *
* A9 = WALL OBJECT							 *
*								         *
**************************************************************************
EXPLOSION_4_WALL
	MOVI	PREBUST_EXPLO_INIT,B0		;CREATE EXPLOSION
	CALLA	MULTIMAKE
	JAZ	SUCIDE				;NO ALLOCATION
	
	MOVE	A8,A0
E4W_EXPLO_LUPE
	MOVE	*A9(OXVAL),*A0(OXVAL),L		;SET POSITION

	MOVE	*A9(OYVAL),A14,L
	SUBI	87*08000H,A14
	MOVE	A14,*A0(OYVAL),L

	MOVE	*A9(OZVAL),A14,L
	SUBK	17,A14
	MOVE	A14,*A0(OZVAL),L

	MOVE	*A0(OPARTS),A0,L
	JRNZ	E4W_EXPLO_LUPE

	MOVI	PRE_BUST_ANIM,A1
	CALLA	STRT_ANIM

	CALLA	INSERT_OBJ

	SOUND1	SND_PREBUST

	DIE

SND_PREBUST
	.WORD	0F2F0H,100,08304H,0	;PRE-BUST EXPLOSION

**************************************************************************
*								         *
* FINISH_WALL_EXPLODE - MAKE EXPLOSION AND EXTRA BRICKS			 *
*								         *
* PASS:									 *
* A9 = WALL OBJECT							 *
*								         *
**************************************************************************

EXPLO_TIME		EQU	3

NUM_FINAL_BRICKS	EQU	10

BRICK_TEMPLATE
	.LONG	0, BRICK_CVECT
	.WORD	OID_JUNK, DMAWNZ, M_GCOLL, 0
	.LONG	C_STRTANIM
	.LONG	BRICK_DEBRIS_ANIM

FINISH_WALL_EXPLODE
	MOVI	EXPLOSION_INIT,B0		;CREATE EXPLOSION
	CALLA	MULTIMAKE
	JRZ	FWE_FINAL_BRICKS
	
;	MOVE	A8,A0
;FWE_EXPLO_LUPE
;	MOVE	*A9(OXVAL),*A0(OXVAL),L		;SET POSITION
;
;	MOVE	*A9(OYVAL),A14,L
;	SUBI	87*08000H,A14
;	MOVE	A14,*A0(OYVAL),L
;
;	MOVE	*A9(OZVAL),A14,L
;	SUBK	17,A14
;	MOVE	A14,*A0(OZVAL),L
;
;	MOVE	*A0(OPARTS),A0,L
;	JRNZ	FWE_EXPLO_LUPE

	MOVE	*A9(OXVAL),A1,L
	MOVE	*A9(OYVAL),A2,L
	SUBI	87*08000H,A2
	MOVE	*A9(OZVAL),A3,L
	SUBK	17,A3
	CALLA	SET_ANIPU			;SET POSITION

	MOVI	EXPLOSION_ANIM,A1
	CALLA	STRT_ANIM

	CALLA	INSERT_OBJ

FWE_WAIT0					;WAIT UNTIL EXPLOSION HUGE
	SLEEP	EXPLO_TIME
	MOVB	@WALL_FLAG,A14
	JRZ	FWE_WAIT0			;BR=NO YET!

	CLR	A14
	MOVB	A14,@WALL_FLAG

	CLR	A2
	MOVE	A9,A8
	CLR	A5
	CLR	A7
	PUSH	A9
	CLR	A9
	CALLA	UNIV_DAMAGE_HANDLER		;DAMAGE WALL
	PULLQ	A9
FWE_FINAL_BRICKS
	MOVE	A13,A10
	ADDI	PDATA,A10

	MOVE	A10,A1				;COPY OBJECT SCRIPT TO PDATA
	MOVI	BRICK_TEMPLATE,A0
	MOVK	6,A14
FWE_COPY
	MOVE	*A0+,*A1+,L
	DSJS	A14,FWE_COPY

	MOVE	*A9(OYVAL),A2,L
	MOVE	*A9(OXVAL),A3,L
	MOVE	*A9(OZVAL),A4,L
	MOVI	BRICK_TABLE,A6
	MOVK	NUM_FINAL_BRICKS,A11		;NUMBER OF BRICKS
FWE_LUPE
	MOVK	15,A0
	CALLA	RAND0
	SLL	5,A0
	ADD	A6,A0
	MOVE	*A0,*A10,L
	MOVE	A10,A5
	CALLA	CREATE_OBJ
	JRZ	FWE_NEXT
	MOVE	A0,A8	

	MOVI	158,A0				;GET RANDOM Y PIXEL OFFSET
	MOVK	23,A1
	CALLA	RANGRAND
	SLL	15,A0				;CONVERT TO WORLD
	MOVE	A2,A14				;GET WALL OYVAL
	SUB	A0,A14				;COMPUTE BRICK OYVAL
	MOVE	A14,*A8(OYVAL),L
	
	MOVI	73,A0				;GET RANDOM X PIXEL OFFSET
	MOVI	-63,A1
	CALLA	RANGERND
	SLL	15,A0				;CONVECT TO WORLD
	MOVE	A3,A14				;GET WALL OXVAL
	ADD	A0,A14				;COMPUTE BRICK OXVAL
	MOVE	A14,*A8(OXVAL),L

	MOVI	16,A0				;GET RANDOM Z OFFSET
	CALLA	RANDU
	MOVE	A4,A14				;GET WALL OZVAL
	SUB	A0,A14				;COMPUTE BRICK OZVAL
	MOVE	A14,*A8(OZVAL),L

	MOVI	10,A0				;RANDOM X VELOCITY
	MOVI	-10,A1
	CALLA	RANGERND
	SLL	14,A0
	MOVE	A0,*A8(OXVEL),L

	MOVI	10,A0				;RANDOM Y VELOCITY
	MOVK	4,A1
	CALLA	RANGRAND
	SLL	13,A0
	MOVE	A0,*A8(OYVEL),L

	MOVI	01000H,A14
	MOVE	A14,*A8(OYACCEL),W	

	CALLA	RANDOM				;RANDOM FLIPPING
	ANDI	M_FLIPV|M_FLIPH,A0
	MOVE	*A8(OCTRL),A14,W
	OR	A0,A14
	MOVE	A14,*A8(OCTRL),W

	MOVI	BRICK_CVECT,A14
	MOVE	A14,*A8(OCVECT),L

	CALLA	INSERT_OBJ
FWE_NEXT
	DSJ	A11,FWE_LUPE
FWE_WAIT1					;WAIT UNTIL EXPLOSION CLEARS
	SLEEP	EXPLO_TIME
	MOVB	@WALL_FLAG,A14
	JRZ	FWE_WAIT1			;BR=NOT YET!

	SLEEP	60

;	MOVI	-1,A14
;	MOVE	A14,@OBJENEMIES,W		;ACTIVATE ALL ENEMIES

	DIE

**************************************************************************
*								         *
* BRICK COLLISION TABLE AND ROUTINE					 *
*								         *
**************************************************************************

BRICK_CVECT
	.WORD	OID_GRND,0FFFFH
	.LONG	BRICK_COLLVECT
	.WORD	0
	.LONG	DUMCRETS

BRICK_COLLVECT
	CLR	A14				;STOP, DROP, AND ROLL!
	MOVE	A14,*A8(OXVEL),L
	MOVE	A14,*A8(OYACCEL),W
	MOVE	A14,*A8(OYVEL),L
	MOVE	*A8(OFLAGS),A14,W
	ANDNI	M_GCOLL,A14
	MOVE	A14,*A8(OFLAGS),W
	RETS

**************************************************************************
*								         *
* A_DEL_BEYONDZ	- DELETE AN OBJECT WHEN IT EXCEEDS ZMAX_REAL		 *
*								         *
* PASS:									 *
* A8 = OBJECT								 *
*								         *
**************************************************************************

A_DEL_BEYONDZ
	MOVE	*A8(OZVAL),A1,L
	MOVE	@ZBASE,A14,L
	SUB	A14,A1
	CMPI	ZMAX_REAL,A1
	JALT	DELETE_OBJ			;BR=OUT OF Z RANGE
	RETS

**************************************************************************
*								         *
* A_SET_WALL_FLAG - SET THE DAMN WALL FLAG				 *
*								         *
**************************************************************************

A_SET_WALL_FLAG
	MOVK	1,A14
	MOVB	A14,@WALL_FLAG
	RETS

**************************************************************************
*								         *
* WALL EXPLODE TABLES AND ANIMATIONS					 *
*								         *
**************************************************************************

BRICK_TABLE
	.LONG	BRIK1,BRIK7,BRIK9,BRIK18,BRIK23,BRIK25,GXBRIK1,GXBRIK3,GXBRIK5
	.LONG	CBRIK3,CBRIK4,CBRIK5,CBRIK9,CBRIK10,CBRIK11

WALL_FRAGMENT_TABLE
	.LONG	BRIK_INIT,GXBRIK_INIT,CBRIK_INIT,NOSHRED_INIT


BRIK_INIT
	.LONG	BRIK1, 0
	.WORD	OID_JUNK, DMAWNZ, 0, 0
	.LONG	C_STRTANIM
	.LONG	BRIK_ANIM

GXBRIK_INIT
	.LONG	GXBRIK1, 0
	.WORD	OID_JUNK, DMAWNZ, 0, 0
	.LONG	C_STRTANIM
	.LONG	GXBRIK_ANIM

CBRIK_INIT
	.LONG	CBRIK1, 0
	.WORD	OID_JUNK, DMAWNZ, 0, 0
	.LONG	C_STRTANIM
	.LONG	CBRIK_ANIM

NOSHRED_INIT
	.LONG	NOSHRED1, 0
	.WORD	OID_JUNK, DMAWNZ, 0, 0
	.LONG	C_STRTANIM
	.LONG	NOSHRED_ANIM

EXPLOSION_INIT
	.byte	 2, 0, 0, 1	;OBJCNT, PRCCNT, IMGPALCNT, PALCNT
	.long	REXPLO		;IMGPAL
	.word	OID_JUNK, 0	;OID, GLOBAL_OPTIONS
*        .long IMG
*        .word OCTRL, OFLAGS, OZOFF
*        .word OPTIONS 
	LWWWW	REXPLOA1h, DMAWNZ, 0, 0, 0
	LWWWW	REXPLOA1h, DMAWNZ|M_FLIPH, 0, 0, 0

PREBUST_EXPLO_INIT
	.byte	 2, 0, 0, 1	;OBJCNT, PRCCNT, IMGPALCNT, PALCNT
	.long	REXPLO		;IMGPAL
	.word	OID_JUNK, 0	;OID, GLOBAL_OPTIONS
*        .long IMG
*        .word OCTRL, OFLAGS, OZOFF
*        .word OPTIONS 
	LWWWW	REXPLOA8h, DMAWNZ, 0, 0, 0
	LWWWW	REXPLOA8h, DMAWNZ|M_FLIPH, 0, 0, 0

BRICK_DEBRIS_ANIM
	LWL	1,60|AFunc,A_DEL_BEYONDZ
	.long	0

BRIK_ANIM
	LW	BRIK1,1
	LW	BRIK3,1
	LW	BRIK5,1
	LW	BRIK7,1
	LW	BRIK9,1
	LW	BRIK11,1
	LW	BRIK12,1
	LW	BRIK14,1
	LW	BRIK16,1
	LW	BRIK18,1
	LW	BRIK21,1
	LW	BRIK23,1
	LWL	BRIK25,1|AFunc,A_DEL_BEYONDZ
	.long	0

GXBRIK_ANIM
	LW	GXBRIK1,1
	LW	GXBRIK2,1
	LW	GXBRIK3,1
	LW	GXBRIK4,1
	LW	GXBRIK5,1
	LW	GXBRIK6,1
	LW	GXBRIK7,1
	LW	GXBRIK8,1
	LW	GXBRIK9,1
	LW	GXBRIK10,1
	LWL	GXBRIK11,1|AFunc,A_DEL_BEYONDZ
	.long	0

CBRIK_ANIM
	LW	CBRIK1,1
	LW	CBRIK2,1
	LW	CBRIK3,1
	LW	CBRIK4,1
	LW	CBRIK5,1
	LW	CBRIK6,1
	LW	CBRIK7,1
	LW	CBRIK8,1
	LW	CBRIK9,1
	LW	CBRIK10,1
	LW	CBRIK11,1
	LWL	CBRIK12,1|AFunc,A_DEL_BEYONDZ
	.long	0

NOSHRED_ANIM
	LW	NOSHRED1,1
	LW	NOSHRED2,1
	LW	NOSHRED3,1
	LW	NOSHRED4,1
	LW	NOSHRED5,1
	LW	NOSHRED6,1
	LW	NOSHRED7,1
	LW	NOSHRED8,1
	LW	NOSHRED9,1
	LW	NOSHRED10,1
	LW	NOSHRED11,1
	LWL	NOSHRED12,1|AFunc,A_DEL_BEYONDZ
	.long	0

EXPLOSION_ANIM
	LW	REXPLOA1h,1|AMulti
	LW	REXPLOA1h,EXPLO_TIME

	LW	REXPLOA3h,1|AMulti
	LW	REXPLOA3h,EXPLO_TIME

	LW	REXPLOA4h,1|AMulti
	LW	REXPLOA4h,EXPLO_TIME

	LW	REXPLOA5h,1|AMulti
	LW	REXPLOA5h,EXPLO_TIME

	LW	REXPLOA6h,1|AMulti
	LW	REXPLOA6h,EXPLO_TIME
PRE_BUST_ANIM
	LW	REXPLOA8h,1|AMulti
	LW	REXPLOA8h,EXPLO_TIME

	LW	REXPLOA9h,1|AMulti
	LW	REXPLOA9h,EXPLO_TIME-1

	LWL	1,1|AFunc,A_SET_WALL_FLAG

	LW	REXPLOA10h,1|AMulti
	LW	REXPLOA10h,EXPLO_TIME

	LW	REXPLOA11h,1|AMulti
	LW	REXPLOA11h,EXPLO_TIME

	LW	REXPLOA12h,1|AMulti
	LW	REXPLOA12h,EXPLO_TIME-1

	LWL	1,1|AFunc,A_SET_WALL_FLAG
	LWL	1,1|AFunc,DELETE_OBJ


**************************************************************************
*								         *
* MAKE_CAT_PROC	- CREATE DA CAT						 *
*								         *
**************************************************************************

OSCORE		EQU	ODATA			;UHL NEXT SCORE
OASTADDR	EQU	ODATA+020H		;UHL ANIM SPEED TABLE ADDRESS
OCHEWEDROCKET	EQU	ODATA+040H		;UHB Flag for rocket contact
OHITSND		EQU	ODATA+060H		;UHL Sound to make upon hit
ODEATHSND	EQU	ODATA+080H		;UHL Sound to make upon death
ODEATHANIM	EQU	ODATA+0A0H		;UHL Anim for death
OTROG_MASTER	EQU	ODATA+0C0H		;UHL Master object that spawned us

SCORE_INC	EQU	1000

**************************************************************************
*								         *
* 	MAKE_TROG_PROC							 *
* 									 *
* 	Process to create the Trog that flies from an object to the	 *
* 	top of the wall.						 *
* 									 *
* 	A8 = Ptr to object creating					 *
*								         *
**************************************************************************
MAKE_TROG_PROC
	MOVI	TROG_INIT,B0
	JRUC	MCP_CREATE

**************************************************************************
*								         *
* 	MAKE_CAT_PROC							 *
* 									 *
* 	Process to make the wall walking cat				 *
*								         *
**************************************************************************
MAKE_CAT_PROC
	CLR	A14
	MOVE	A14,@CAT_DONE,W			;IT HAS ONLY JUST BEGUN.
	MOVE	A14,@GITTEN_KITTEN,W
	MOVE	A14,@GOT_TROG,W
	MOVE	A14,@TROG_ALIVE,W

	MOVI	CAT_INIT,B0
MCP_CREATE
	CALLA	EASYMAKE
	JRZ	MCP_NOCAT			;BR=OOPS!

	MOVE	A8,*A0(OTROG_MASTER),L
	MOVE	A0,A8

	MOVI	0358A000H,A0			;DEFAULT TO THE LEFT SIDE
	MOVI	0D000H,A1
	MOVE	@RAND,A14,W
	JRN	MCP_OK				;BR=IT'S NOT GONNA HAPPEN
	MOVI	0465A000H,A0			;COME FROM THE RIGHT SIDE
	NEG	A1
	MOVE	*A8(OCTRL),A14,W
	ORI	M_FLIPH,A14
	MOVE	A14,*A8(OCTRL),W
MCP_OK
	MOVE	A0,*A8(OXVAL),L			;SET VALUES
	MOVE	A1,*A8(OXVEL),L

	MOVI	-0408000H,A14
	MOVE	A14,*A8(OYVAL),L

	MOVI	-0F54BH,A14
	MOVE	A14,*A8(OZVAL),L

;	MOVI	CAT_GUNVECT,A14
;	MOVE	A14,*A8(OGUNVECT),L
	
	MOVI	SCORE_INC,A14
	MOVE	A14,*A8(OSCORE),L

	MOVI	ANIM_SPEED_TABLE,A14
	MOVE	A14,*A8(OASTADDR),L

	CLRB	*A8(OCHEWEDROCKET)

	CALLA	INSERT_OBJ

	MOVK	5,A14
	MOVB	A14,*A8(AnimSLP)		;INITIAL SLEEP BETWEEN FRAMES
	
	MOVK	1,A14				
	MOVE	A14,@GUN_ONE_SHOT,W		;SET ONE SHOT MODE
MCP_WAIT
	SLEEP	1
	MOVE	@GUN_ONE_SHOT,A14,W
	JRNZ	MCP_WAIT			;BR=WE'RE NOT DONE WITH THIS CAT
MCP_NOCAT	
	MOVK	1,A14
	MOVB	A14,@CAT_DONE			;CAT IS DONE FLAG
	DIE

**************************************************************************
*								         *
* 	CAT_GUNVECT							 *
* 									 *
* 	Cat gun vector makes cat reverse direction and speed up.	 *
* 	Unless, of course, it's time to kill him.			 *
* 									 *
* 	A2 = Ptr to player that hit us.					 *
* 	A8 = Ptr to the pussy object.					 *
*								         *
**************************************************************************
CAT_GUNVECT
	MOVE	*A8(OFLAGS),A14,W
	BTST	B_DEAD,A14			;Is the object dead?
	JRNZ	CGV_X				;BR = Yes, then do nothing

;	CALLA	SMALL_BLOOD_HIT

	MOVE	*A8(OSCORE),A1,L		;HE SCORES!
	CLR	A9				;NO OFFSET
	CALLA	PRINT_SCORE
	ADDI	SCORE_INC,A1
	MOVE	A1,*A8(OSCORE),L		;INCREASE SCORE

	MOVE	*A8(OHITSND),A0,L
	CALLA	ONESND

	MOVE	*A8(OXVEL),A3,L			;SPEED UP VELOCITY
	ABS	A3
	GETST	A14				;SAVE STATUS TO RESTORE SIGN
	ADDI	0B000H,A3
	PUTST	A14
	JRNN	CG_SIGNOK			;BR=SIGN IS FINE	
	NEG	A3				;RESTORE TO NEGATIVE STATE
CG_SIGNOK
	MOVE	*A8(OASTADDR),A0,L
	MOVE	*A0+,A1,W
	JRZ	CG_WIN				;BR=WE HAVE A WINNER!
	MOVE	A0,*A8(OASTADDR),L
	MOVB	A1,*A8(AnimSLP)		

	MOVE	A3,*A8(OXVEL),L

	MOVE	*A8(OCTRL),A14,W
	XORI	M_FLIPH,A14			;FLIP IT
	MOVE	A14,*A8(OCTRL),W
CGV_X
	RETS
CG_WIN
	MOVI	DUMRETS,A14
	MOVE	A14,*A8(OGUNVECT),L

	MOVI	OID_JUNK,A1			;He's no longer alive
	CALLA	CHANGE_OID

	ORIM	M_GCOLL|M_DEAD,*A8(OFLAGS),W	;Make him ground collidable and dead

	MOVE	*A8(ODEATHSND),A0,L
	CALLA	ONESND

	MOVE	*A8(ODEATHANIM),A1,L
	jauc	SetAnim

ANIM_SPEED_TABLE
	.WORD	4,4,3,3
	.WORD	2,2,1,1
	.WORD	0				;9TH HIT

SND_MEOW
	.WORD	0F330H,24,0A3A4H,0
SND_MEOW2
	.WORD	0F330H,25,0A3A7H,0
SND_Cat_Explode
;	.WORD	0F230H,60,08085H,0
	.WORD	0F141H,60,0A38BH,0	;Explosion used by much
SND_TROG_OUCH
	.WORD	0F330H,46,0A3AAH,0
SND_TROG_YELL
	.WORD	0F330H,74,0A3ADH,0



CAT_INIT
	.LONG	K_B3WKC1
	.WORD	DMAWNZ, 0, OM_OID|OM_COLL|OM_GUNV|OM_ANIM|OM_CFUNC
	.WORD	OID_CAT
	.LONG	CVect_Cat, CAT_GUNVECT, CAT_ANIM, C_CAT

;CAT_INIT
;	.LONG	K_B3WKC1, CVect_Cat
;	.WORD	OID_CAT, DMAWNZ, 0, 0
;	.LONG	0

TROG_INIT
	.LONG	TRWAP4F1
	.WORD	DMAWNZ, M_DBLSCL, OM_OID|OM_ANIM|OM_CFUNC
	.WORD	OID_CAT
	.LONG	ANIM_TROG_FLY, C_TROG

;TROG_INIT
;	.LONG	TRWAP4F1, CVect_Cat
;	.WORD	OID_CAT, DMAWNZ, 0, 0
;	.LONG	0

**************************************************************************
*								         *
* 	C_CAT								 *
* 									 *
* 	Create func for Cat target					 *
* 									 *
* 	A0 = Ptr to un-inserted object					 *
*								         *
**************************************************************************
C_CAT
	MOVIM	SND_MEOW,*A0(OHITSND),L
	MOVIM	SND_MEOW2,*A0(ODEATHSND),L
	MOVIM	ANIM_CAT_DEATH,*A0(ODEATHANIM),L
	RETS

**************************************************************************
*								         *
* 	C_TROG								 *
* 									 *
* 	Create func for Trog target					 *
* 									 *
* 	A0 = Ptr to un-inserted object					 *
*								         *
**************************************************************************
C_TROG
	MOVIM	SND_TROG_OUCH,*A0(OHITSND),L
	MOVIM	SND_TROG_YELL,*A0(ODEATHSND),L
	MOVIM	ANIM_TROG_DEATH,*A0(ODEATHANIM),L
	MOVKM	1,@TROG_ALIVE,W
	RETS


*
*Collision vector table for the Kitty Kat
*
CVect_Cat
	WWL	OID_PROCKET,~MASK_PLAYER,CAT_ROCKET_COLL
	WWL	OID_PEXPLOSION,~MASK_PLAYER,CAT_EXPLOSION_COLL
	WWL	OID_GRND,0FFFFH,Coll_Ground_Cat
	WL	0,DUMCRETS

**************************************************************************
*								         *
* 	CAT_ROCKET_COLL							 *
* 									 *
* 	Collision service vector for the cat with a player rocket.	 *
* 									 *
* 	A0 = Ptr to rocket object					 *
* 	A8 = Ptr to Cat object						 *
*								         *
**************************************************************************
CAT_ROCKET_COLL
	MOVE	*A0(RL_INTENDED_OBJ),A14,L
	CMP	A14,A8			;Is this the object we are after?
	JRNE	CRC_X			;BR = No
	MOVK	1,A14
	MOVB	A14,*A8(OCHEWEDROCKET)	;Flag for the explosion
CRC_X
	RETS

**************************************************************************
*								         *
* 	CAT_EXPLOSION_COLL						 *
* 									 *
* 	Collision service vector for Cat and player explosion.		 *
* 									 *
* 	A0 = Ptr to explosion object					 *
* 	A8 = Ptr to Cat object						 *
*								         *
**************************************************************************
CAT_EXPLOSION_COLL
	MOVB	*A8(OCHEWEDROCKET),A14	;Did he really take a rocket?
	JRZ	CAEC_X			;BR = No, so bail

	MOVE	*A0(OID),A0,W		;We can find out who did this
	CALLA	POID_TO_PDATA		;by getting the Player's data area.

	CLRB	*A8(OCHEWEDROCKET)	;Clear the rocket flag

	JRUC	CAT_GUNVECT		;Use the gun vector code
CAEC_X
	RETS

**************************************************************************
*								         *
* 	Coll_Ground_Cat							 *
* 									 *
* 	Collision routine for the Cat when it hits the ground.		 *
* 									 *
* 	A8 = Ptr Cat Object						 *
*								         *
**************************************************************************
Coll_Ground_Cat
	calla	CLR_VEL			;Stop him now!
	ANDNIM	M_GCOLL,*A8(OFLAGS),W	;Clear the ground collision flag
	CLRM	*A8(OCVECT),L		;Clear the collision vector
	rets

**************************************************************************
*								         *
* A_CHECK_CAT - CHECK IF IT RAN OFF THE SCREEN				 *
*								         *
* PASS:									 *
* A8 = DA CAT OBJECT							 *
*								         *
**************************************************************************
A_CHECK_CAT
	MOVE	*A8(OCTRL),A0,W
	MOVE	*A8(OXVAL),A14,L
	CMPI	0358A000H,A14
	JRLE	ACC_GONE			;BR=OFF THE RIGHT SIDE
ACC_CHECK_RIGHT
	CMPI	0465A000H,A14
	JRLT	ACC_DONE			;BR=INSIDE LEFT BORDER
ACC_GONE
	CALLA	DELETE_OBJ			;IT'S GONE
	CLR	A14
	MOVE	A14,@GUN_ONE_SHOT,W		;RETURN TO AUTO-FIRE
ACC_DONE
	RETS

**************************************************************************
*								         *
* A_Set_Cat_Vels - Set the Cat's falling off wall velocities.		 *
* A8 = Ptr to cat							 *
*								         *
**************************************************************************
A_Set_Cat_Vels
	CLRM	*A8(OXVEL),L

	MOVIM	-40000H,*A8(OYVEL),L	;SEND HIM UP
	MOVIM	4000H,*A8(OYACCEL),W	;AND MAKE HIM COME DOWN
	MOVIM	-01H,*A8(OZVEL),L	;Make him go forward, just a little.

	rets

**************************************************************************
*								         *
* A_YVel_Nonzero - Anim func to branch animation script if the Y velocit *
* 		is nonzero						 *
* A8 = PTR TO OBJECT							 *
* AARG+,L = BRANCH							 *
*								         *
**************************************************************************
A_YVel_Nonzero
	calla	GETAFARG_LONG
	calla	GET_HEAD_PART
	move	*A8(OYVEL),A14,L
	jrz	AYN_NoBranch
	move	A0,A1
	jauc	STRT_ANIM
AYN_NoBranch
	rets

**************************************************************************
*								         *
* 	A_BRANCH_IF_YVEL_ZERO						 *
* 									 *
* 	Anim func to branch if an objects OYVEL is zero.		 *
* 									 *
* 	A8 = Ptr to object						 *
* 	AARG+,L = Branch if zero					 *
*								         *
**************************************************************************
A_BRANCH_IF_YVEL_ZERO
	CALLA	GETAFARG_LONG
	CALLA	GET_HEAD_PART
	MOVE	*A8(OYVEL),A14,L
	JRNZ	ABIYZ_NOBRANCH
	MOVE	A0,A1
	JAUC	STRT_ANIM
ABIYZ_NOBRANCH
	RETS

**************************************************************************
*								         *
* 	A_START_TROG_FLY						 *
* 									 *
* 	Anim func to position Trog on his master object and		 *
* 	then start him flying to the wall.				 *
*								         *
**************************************************************************
A_START_TROG_FLY
	MOVE	*A8(OTROG_MASTER),A0,L
	MOVE	*A0(OXVAL),A1,L
	MOVI	-408000H,A2		;Put it at this Y
	MOVE	*A0(OZVAL),A3,L

	CALLA	SET_ANIPU

	MOVE	A3,A6
	MOVI	-0F54BH,A5		;Z target set

	MOVE	A2,A4
	MOVE	A2,A3			;Y target set

	MOVE	A1,A2
	ADDI	200000H,A1		;X target set

	MOVI	45,A7

	CALLA	SLINEVEL_LOAD_3D

	MOVB	A7,*A8(AnimSLP)

	MOVI	40000H,A1
	MOVE	A1,A2
	MOVI	45/2,A0
	DIVU	A0,A1
	MOVE	A1,*A8(OYACCEL),W
	NEG	A2
	MOVE	A2,*A8(OYVEL),L

	SOUND1	SND_TROG_YELL

	RETS

**************************************************************************
*								         *
* 	A_TROG_FLY_END							 *
* 									 *
* 	Anim func to handle the end of Trog's flying stuff.		 *
* 									 *
* 	A8 = Ptr to Trog						 *
*								         *
**************************************************************************
A_TROG_FLY_END
	CALLA	CLR_VEL

	MOVI	-0408000H,A14
	MOVE	A14,*A8(OYVAL),L

	MOVIM	0D000H,*A8(OXVEL),L

	MOVIM	CAT_GUNVECT,*A8(OGUNVECT),L
	MOVIM	CVect_Cat,*A8(OCVECT),L

	MOVKB	5,*A8(AnimSLP)		;Setup initial sleep

	MOVI	TROG_ANIM,A1
	JAUC	SetAnim			;Start him to walkin'



CAT_ANIM
	LW	K_B3WKC1,0
	LW	K_B3WKC2,0
	LW	K_B3WKC3,0
	LW	K_B3WKC4,0
	LWL	K_B3WKC5,0|AFunc,A_CHECK_CAT
	.long	0

ANIM_CAT_DEATH
	LWLLLL	1,1|AFunc,A_PreFrag_Center+6,FRAG_Cat,0h,0h
	LWL	K_B3FE1,7|AFunc,A_Set_Cat_Vels
	LWLLW	K_B3FE2,4|AFunc,A_Set_Var_Word+3,GITTEN_KITTEN,1
	LW	K_B3FE3,16
	LWL	K_B3FE4,20|AFunc,DELAYED_PRAISE
ANIM_CAT_WAIT
	LWLL	1,1|AFunc,A_YVel_Nonzero+2,ANIM_CAT_WAIT
	LWLLLL	1,1|AFunc,A_PreFrag_Center+6,FRAG_Cat,0h,0h
	LWL	1,80|AFunc,OBJ_OFF
	LWLLL	1,1|AFunc,A_BRANCH_IF_FALSE+4,TROG_ALIVE,ANIM_CAT_NO_TROG
	LWL	1,1|AFunc,DELETE_OBJ
ANIM_CAT_NO_TROG
	LWLLW	1,2|AFunc,A_Set_Var_Word+3,GUN_ONE_SHOT,0
	LWL	1,1|AFunc,DELETE_OBJ

*
* This will make Trog fly to the wall from the palm tree
*
ANIM_TROG_FLY
	LWWL	TRWAP4F1,1|AFlip|AFunc,0,A_START_TROG_FLY
	LW	1,0
	LWL	1,1|AFunc,A_TROG_FLY_END

TROG_ANIM
	LW	TRWAP4F1,0
	LW	TRWAP4F2,0
	LW	TRWAP4F3,0
	LW	TRWAP4F4,0
	LW	TRWAP4F5,0
	LW	TRWAP4F6,0
	LWL	TRWAP4F7,0|AFunc,A_CHECK_CAT
	.long	0

ANIM_TROG_DEATH
	LWLLLL	1,1|AFunc,A_PreFrag_Center+6,FRAG_Cat,0h,0h
	LWL	TRYLP4F1,7|AFunc,A_Set_Cat_Vels
	LWLLW	TRYLP4F2,4|AFunc,A_Set_Var_Word+3,GOT_TROG,1
	LW	TRYLP4F3,4
	LW	TRYLP4F4,4
	LWL	TRYLP4F5,4|AFunc,DELAYED_PRAISE
ANIM_TROG_WAIT
	LWLL	TRYLP4F3,3|AFunc,A_BRANCH_IF_YVEL_ZERO+2,ANIM_TROG_BLOW
	LWLL	TRYLP4F4,3|AFunc,A_BRANCH_IF_YVEL_ZERO+2,ANIM_TROG_BLOW
	LWLL	TRYLP4F5,2|AFunc,A_BRANCH_IF_YVEL_ZERO+2,ANIM_TROG_BLOW
	LWLL	1,1|AFunc,A_AnimGo+2,ANIM_TROG_WAIT

ANIM_TROG_BLOW
	LWLLLL	1,1|AFunc,A_PreFrag_Center+6,FRAG_Cat,0h,0h
	LWLLW	1,2|AFunc,A_Set_Var_Word+3,GUN_ONE_SHOT,0
	LWL	1,1|AFunc,DELETE_OBJ

*
*Cat kill fragger script
*
FRAG_Cat
	.long	FHK_Explosion,F_Cat_Explosion
	.word	OID_JUNK,1*800H+1*40H+FRGPAL
	.long	0
*
*Cat fragger init func
*
F_Cat_Explosion
	jauc	CLRVEL			;Just make sure it is stopped
	

FHK_Explosion
	LWLL	FHKEXPLOB1,6|AFunc,A_SOUND+2,SND_Cat_Explode
	LW	FHKEXPLOB2,8
	LW	FHKEXPLOB3,6
	LW	FHKEXPLOB4,4
	LW	FHKEXPLOB5,4
	LW	FHKEXPLOB6,3
	LW	FHKEXPLOB7,3
	LW	FHKEXPLOB8,2
	LW	FHKEXPLOB9,2
	LW	FHKEXPLOB10,2
	LW	FHKEXPLOB11,2
	LWL	1,1|AFunc,DELETE_OBJ

**************************************************************************
*								         *
* PROC_AIR_RAID_SIREN - Wait and make the Siren. Created from		 *
* 			a scroll table.					 *
*								         *
**************************************************************************
PROC_AIR_RAID_SIREN
	SLEEP	60*6
	SOUND1	SND_AIR_RAID	
	DIE

**************************************************************************
*								         *
* MAKE_INTRO_COPTER_PROC - CREATE INTRO COPTER AND MAKE IT FLY!		 *
*								         *
**************************************************************************
SND_AIR_RAID
	.word	0F2F0H,407,08313H,0
SND_PILOT_FREAK
	.word	0F2C0H,139,0820FH,0
SND_HIT_COPTER
	.word	0F310H,30,0A111H,0
SND_ROCKET_COPTER
	.word	0F320H,69,0A14AH,0
SND_DIE_COPTER
	.word	0F340H,30,0A30BH,30,0A30BH,60,0A30BH,0

NO_FREAK_AFTER_TIME	.EQU	530	;Do NOT make the freak sound after
					;this amount of WAVEIRQS.

PYACCEL		EQU	PDATA		;UHL Y MOTION EFFECT (ACCELERATION)
PHOVERSTART	EQU	PDATA+020H	;UHL WAVEIRQ AT BEGINNING OF HOVER

STARTING_POINTS	EQU	100
RADIO_AT	EQU	90
MAKE_SMOKE_AT	EQU	50	
MORE_SMOKE_AT	EQU	25

BOMB_POINTS	EQU	10

MAKE_INTRO_COPTER_PROC
	MOVI	COPDAM2,A8
	MOVK	24,A9
	MOVK	31,A10
	MOVK	10,A11
	CREATE	PID_DAMCC, CYCLE16

	MOVI	SIDE_COPTER_INTRO_INIT,B0 
	CALLA	MULTIMAKE
	LOCKON	Z

	CALLA	CLR_ODATA

	MOVI	015912000H,A1
	MOVI	-036D7000H,A2
	MOVI	03971H,A3
	CALLA	SET_ANIPU

	MOVI	STARTING_POINTS,A14
	MOVE	A14,*A8(OHIT_POINTS),W

;	MOVE	A13,*A8(OPLINK),L

	MOVI	-0100000H,A14		;SET UP INITIAL MOTION PARMS
	MOVE	A14,*A8(OXVEL),L
;	MOVI	0100000H,A14
	MOVI	070000H,A14
	MOVE	A14,*A8(OYVEL),L
;	MOVI	-07000H,A14
	MOVI	-02000H,A14
	MOVE	A14,*A8(OYACCEL),W

	MOVE	A8,A0
	MOVI	0101H,A1
	MOVI	[0800H,0800H],A2
	MOVI	SIDE_COPTER_INTRO_COLLISIONS,A3
	MOVK	20,A4
MCP_CONST_STUFF_LUPE
	MOVE	A1,*A0(OCONST),L
	MOVE	A2,*A0(OZDEPTH),L
	MOVE	*A3+,A14,L
	MOVE	A14,*A0(OCOLLISION),L	
	MOVE	*A0(OPARTS),A0,L
	DSJS	A4,MCP_CONST_STUFF_LUPE

;	MOVE	@WAVEIRQS,A14,L
;	MOVE	A14,*A8(ODROPTIME),L

	SOUND0	SND_COPTER_FULL
	MOVE	A8,A4
	CLR	A8				;FULL UP
	MOVK	3,A10
	MOVI	60,A11
	CREATE	PID_IND,TRACK_FADE_IN_FULL_PROC
	MOVE	A4,A8

MCOP_WAIT				;WAIT TILL ON THE LEFT SIDE
	SLEEP	1
	MOVE	*A8(OXVAL),A14,L
	CMPI	012D12000H,A14
	JRGT	MCOP_WAIT		;BR=NOT YET!	

	MOVK	1,A14
	MOVE	A14,@SCROLL_FLAG,W

;	MOVI	03000H,A14
;	MOVE	A14,*A8(OYACCEL),W	

	CLR	A14
	MOVE	A14,*A8(OYACCEL),W
	MOVE	A14,*A8(OYVEL),L

	CLR	A14
	MOVE	A14,*A13(PYACCEL),L
	MOVE	A14,*A13(PHOVERSTART),L

;CONTINUE WITH COPTER_STAGE1_PROC

**************************************************************************
*								         *
* COPTER_STAGE1_PROC - FLY BACK TO THE MIDDLE OF THE SCREEN		 *
*								         *
**************************************************************************

;	MOVI	0100000H,A9
	CLR	A9
COPTER_STAGE1_PROC
	MOVE	*A8(OXVAL),A0,L
	MOVE	@XBASE,A14,L
	SUB	A14,A0
;	ABS	A0
;	CMP	A9,A0
;	JRLE	COPTER_STAGE2_PROC	;BR=WE'RE THERE!
	JRP	COPTER_STAGE2_PROC	;BR=WE'RE THERE!

	MOVI	01800H,A0
	MOVI	01800H,A1
	MOVI	02000H,A2
	CALLR	FLY_EFFECT2		;FLY AROUND SOME

	MOVE	*A8(OXVEL),A14,L
	ADDI	010000H,A14		;DECELERATE TO THE RIGHT
	MOVE	A14,*A8(OXVEL),L
	SLEEP	2
	JRUC	COPTER_STAGE1_PROC

**************************************************************************
*								         *
* FLY_EFFECT - FLYING PARAMETERS ON THE WAY TO CLUB			 *
*								         *
* PASS:									 *
* A8 = OBJECT								 *
*								         *
**************************************************************************

;FLY_EFFECT
	MOVE	*A8(OYVAL),A0,L
	MOVE	*A8(OYVEL),A1,L
	CLR	A2

	CMPI	-02965000H,A0
	JRLT	FE_CHECK_UPPER_Y	;BR=ABOVE LOWER Y LIMIT

	MOVE	A1,A1
	JRN	FE_GO_UP		;BR=WE'RE GOING UP ALREADY!
	MOVI	-03000H,A2		;CORRECT DIRECTION: STOP GOING DOWN!
	JRUC	FE_Y_DONE
FE_GO_UP
	MOVI	-02000H,A2		;GO UP!
	JRUC	FE_Y_DONE
FE_CHECK_UPPER_Y
;	CMPI	-02965000H,A0
	CMPI	-02AEA000H,A0
	JRGT	FE_Y_DONE		;BR=BELOW UPPER Y LIMIT

	MOVE	A1,A1
	JRNN	FE_GO_DOWN		;BR=WE'RE GOING DOWN ALREADY!
	MOVI	03000H,A2		;CORRECT DIRECTION: STOP GOING UP!
	JRUC	FE_Y_DONE
FE_GO_DOWN
	MOVI	02000H,A2		;GO DOWN!
	JRUC	FE_Y_DONE
FE_Y_DONE
	MOVE	A2,*A8(OYACCEL),W	;SET Y ACCELERATION	

;	MOVE	@XSCROLL,A14,L
;	MOVE	A14,*A8(OXVEL),L
;	RETS

	MOVE	*A8(OXVAL),A0,L
	MOVE	*A8(OXVEL),A1,L
	MOVI	0C000H,A2
	MOVI	0280H,A3

	MOVE	@XBASE,A14,L
	SUB	A14,A0

	CMPI	0400000H,A0
	JRLT	FE_CHECK_LEFT_X

	SUB	A2,A1
	MOVE	A1,*A8(OXVEL),L
	MOVE	A3,*A8(OZVEL),L
	RETS
FE_CHECK_LEFT_X
	CMPI	-0400000H,A0
	JRGT	FE_X_DONE	

	MOVE	A1,A1
	JRP	FE_X_DONE
	ADD	A2,A1
	NEG	A3
	MOVE	A1,*A8(OXVEL),L
	MOVE	A3,*A8(OZVEL),L
FE_X_DONE
	RETS
	
	
**************************************************************************
*								         *
* FLY_EFFECT2 - FLYING PARAMETERS AT THE CLUB				 *
* 									 *
* PASS:									 *
* A0 = MAX Y ACCEL							 *
* A1 = MIN Y ACCEL							 *
* A2 = REVERSE Y ACCEL							 *
* A8 = OBJECT								 *
*								         *
**************************************************************************

FLY_EFFECT2
	MOVE	*A8(OYVAL),A5,L
	MOVE	*A8(OYVEL),A6,L
	CLR	A7			;FLAG ACCEL RESET

	CMPI	-02C00000H,A5
	JRLT	FE2_CHECK_UPPER_Y	;BR=ABOVE DA Y
	MOVE	A6,A6
	JRN	FE2_GO_UP		;BR=ALREADY GOING UP!
	MOVE	A2,A0			;CORRECT DIRECTION: STOP GOING DOWN!
	NEG	A0
	JRUC	FE2_Y_DONE
FE2_GO_UP
	MOVE	*A13(PYACCEL),A14,L
	JRNZ	FE2_DONE		;BR=ACCEL ALREADY SET
	NEG	A0			;NEGATE LIMITS FOR GOING UP
	NEG	A1
	CALLA	RANGERND		;GET RANDOM ACCEL
	JRUC	FE2_SET
FE2_CHECK_UPPER_Y
;	CMPI	-02C00000H,A5
;	JRGT	FE2_Y_DONE
	MOVE	A6,A6
	JRNN	FE2_GO_DOWN		;BR=ALREADY GOING DOWN!
	MOVE	A2,A0			;CORRECT DIRECTION: STOP GOING UP!
	JRUC	FE2_Y_DONE
FE2_GO_DOWN
	MOVE	*A13(PYACCEL),A14,L
	JRNZ	FE2_DONE		;BR=ACCEL ALREADY SET
	CALLA	RANGERND		;GOING DOWN! GET RANDOM ACCEL
FE2_SET
	MOVE	A0,A7			;FLAG ACCEL SET
FE2_Y_DONE
	MOVE	A0,*A8(OYACCEL),W
	MOVE	A7,*A13(PYACCEL),L
FE2_DONE
	RETS

**************************************************************************
*								         *
* COPTER_STAGE2_PROC - FLY AROUND, FLY OFF SCREEN, AND COME BACK	 *
*								         *
**************************************************************************

COPTER_DEST_TABLE
	.WORD	1,SCREEN_WIDTH/3,SCREEN_WIDTH*2/3

COPTER_STAGE2_PROC
	CLR	A14
	MOVE	A14,@SCROLL_FLAG,W
;	MOVE	A14,*A8(OYACCEL),W

;	MOVE	A14,*A8(OYVEL),L
	

CS2P_LUPE
	SLEEP	1
	MOVI	01800H,A0
	MOVI	01800H,A1
	MOVI	02000H,A2
	CALLR	FLY_EFFECT2		;FLY AROUND SOME

	MOVE	*A8(OXVEL),A14,L
	SUBI	010000H,A14
	MOVE	A14,*A8(OXVEL),L

	MOVE	@XSCROLL,A0,L
	SUB	A0,A14
	JRNN	CS2P_LUPE

	MOVE	@XSCROLL,A5,L
	SUBI	010000H,A5

;	MOVI	09600000H,A9		;END LOOP AT THIS XBASE
	MOVI	05759800H,A9		;END LOOP AT THIS XBASE
	CLR	A10			;LEFT X OF DESTINATION QUADRANT
	CLR	A11			;ESCAPE X ACCELERATION
CS2P_LUPE2				;FLY AROUND UNTIL WE GET TO A9
	SLEEP	1

	MOVE	@XBASE,A3,L

	MOVE	*A8(OHIT_POINTS),A14,W
	CMPI	RADIO_AT,A14
	JRGT	CS2P_Y_FLY		;BR=NOT ENOUGH DAMAGE

	MOVE	A10,A2
	JRZ	CS2P_PLAYER_CHECK

	BTST	0,A11
	JRZ	CS2P_NO_STOP		;BR=WE'RE NOT STOPPING YET
	MOVE	A11,A14
	NEG	A14
	GETST	A2
	
	MOVE	*A8(OXVEL),A1,L
	ADD	A14,A1
	MOVE	A1,A14
	MOVE	@XSCROLL,A5,L
	SUB	A5,A14
	GETST	A14
	XOR	A14,A2
	MOVE	A2,A2
	JRN	CS2P_DONT_STOP		;BR=STILL SLOWING DOWN
	CLR	A10			;WE'RE STOPPING
	CLR	A11
	MOVE	A5,A1
CS2P_DONT_STOP
	MOVE	A1,*A8(OXVEL),L
	JRUC	CS2P_Y_FLY

CS2P_NO_STOP
	MOVE	*A8(OZVAL),A1,L
	MOVE	*A8(OXVAL),A5,L
	UTOSX	A1,A5	

	CMP	A10,A5
	JRLT	CS2P_KEEP_GOIN		;BR=OUTSIDE OF LEFT X BOUNDARY
	ADDI	SCREEN_WIDTH/3,A2
	CMP	A2,A5
	JRGT	CS2P_KEEP_GOIN		;BR=OUTSIDE OF RIGHT X BOUNDARY

	INC	A11			;FLAG STOP
	JRUC	CS2P_Y_FLY

CS2P_KEEP_GOIN
	MOVE	*A8(OXVEL),A1,L
	MOVE	A1,A14
	MOVE	@XSCROLL,A2,L
	SUB	A2,A14
	ABS	A14
	CMPI	0E0000H,A14
	JRGT	CS2P_Y_FLY		;BR=WE EXCEEDED THE SPEED LIMIT
	
	ADD	A11,A1
	MOVE	A1,*A8(OXVEL),L
	
	JRUC	CS2P_Y_FLY
	

CS2P_PLAYER_CHECK
	MOVE	*A8(OFLAGS),A14,W
	BTST	B_OFSCRN,A14
	JRNZ	CS2P_Y_FLY		;BR=WE'RE OFFSCREEN DON'T WORRY

	CALLA	GET_TSUL_SCRN
	ADD	A0,A1

	MOVE	@NPLAYERS,A7,W
	MOVI	P1DATA,A2

CS2P_PLAYER_LUPE
	MOVE	*A2(POBJ),A4,L		;IS THE PLAYER ALIVE?
	JRZ	CS2P_NEXT_PLAYER	;BR = NO
	MOVE	*A2(PCURSORXY),A4,L
	CMPXY	A0,A4
	JRXLT	CS2P_NEXT_PLAYER	;BR=X ABOVE
	JRYLT	CS2P_NEXT_PLAYER	;BR=Y LEFT

	CMPXY	A1,A4
	JRXGT	CS2P_NEXT_PLAYER	;BR=X BELOW
	JRYGT	CS2P_NEXT_PLAYER	;BR=Y RIGHT

	MOVE	*A8(OZVAL),A1,L		;BR=SOMEONE'S TRACKING DA COPTER
	MOVE	*A8(OXVAL),A5,L
	UTOSX	A1,A5	

	MOVI	010000H,A11		;DEFAULT X ACCELERATION
CS2P_TRY_AGAIN
	MOVK	3,A0
	CALLA	RANDU			;GET RANDOM INDEX

	DEC	A0
	SLL	4,A0
	ADDI	COPTER_DEST_TABLE,A0
	MOVE	*A0,A10,W
	MOVE	A10,A14
	ADDI	SCREEN_WIDTH/3,A14

	CMP	A10,A5
	JRLT	CS2P_Y_FLY		;BR=WE'RE LEFT OF THE LEFT X BOUNDARY
	CMP	A14,A5
	JRLE	CS2P_TRY_AGAIN		;BR=WE'RE LEFT OF THE RIGHT X BOUNDARY	
	NEG	A11			;ACCELERATE OTHER X DIRECTION
	JRUC	CS2P_Y_FLY

CS2P_NEXT_PLAYER
	ADDI	PDSIZE,A2		;NEXT PLAYER DATA AREA
	DEC	A7
	JRNN	CS2P_PLAYER_LUPE	;BR=NO MORE PLAYERS

CS2P_Y_FLY
	MOVI	01800H,A0
	MOVI	01800H,A1
	MOVI	02000H,A2
	CALLR	FLY_EFFECT2		;FLY AROUND SOME
CS2P_CHECK_XBASE
	CMP	A9,A3
;	JRUC	CS2P_LUPE2		;BR=WE'RE NOT THERE YET
	JRGT	CS2P_LUPE2		;BR=WE'RE NOT THERE YET

	JRUC	COPTER_STAGE3_PROC

	CLR	A14
	MOVE	A14,*A8(OZVEL),L

	MOVI	-0C000H,A9		;ACCELERATE TO THE LEFT
CS2P_GO_OFF_LUPE			;FLY OFF THE SCREEN
	SLEEP	1
	CALLA	SCRTST
	JRNE	CS2P_WERE_OFF		;BR=WE'RE OFF THE SCREEN
	MOVI	04000H,A0
	MOVI	02000H,A1
	MOVI	03000H,A2
	CALLR	FLY_EFFECT2
	MOVE	*A8(OXVEL),A14,L
	ADD	A9,A14			;ACCELERATE
	MOVE	A14,*A8(OXVEL),L
	JRUC	CS2P_GO_OFF_LUPE

CS2P_WERE_OFF			
	MOVE	@XBASE,A1,L
	SUBI	01F00000H,A1
	MOVI	-02C00000H,A2
	MOVI	03971H,A3
	CALLA	SET_ANIPU		;REPOSITION COPTER

	MOVE	@XSCROLL,A14,L		;SET AND RESET MOTION STUFF
	MOVE	A14,*A8(OXVEL),L
	CLR	A14
	MOVE	A14,*A8(OYACCEL),W
	MOVE	A14,*A8(OYVEL),L
	MOVE	A14,*A8(OZVEL),L

CS2P_STAY_OFF
	SLEEP	1
	MOVE	@XBASE,A0,L
;	CMPI	070D9800H,A0
	CMPI	074D9800H,A0
	JRGT	CS2P_STAY_OFF

CS2P_COME_BACK				;COME BACK ON
	SLEEP	1
	MOVI	04000H,A0
	MOVI	02000H,A1
	MOVI	03000H,A2
	CALLR	FLY_EFFECT2
	MOVE	*A8(OXVEL),A14,L
	ADDI	0C000H,A14
	MOVE	A14,*A8(OXVEL),L

	MOVE	@XBASE,A0,L
	CMPI	068D0000H,A0
	JRGT	CS2P_COME_BACK

;CONTINUE WITH COPTER_STAGE3_PROC

**************************************************************************
*								         *
* COPTER_STAGE3_PROC - FLY OFF THE SCREEN AGAIN DROPPING NONBOYS	 *
*								         *
**************************************************************************

COPTER_STAGE3_PROC
	MOVE	@WAVEIRQS,A10,L
	MOVK	2,A11			;NONBOY DROP TIME INTERVAL
CS3P_LUPE
	MOVE	*A8(OXVAL),A0,L
	CMPI	01600000H,A0
	JRGT	CS3P_NOT_DONE		;BR=NOT OFF YET!
	MOVK	8,A14
	MOVE	A14,@OBJENEMIES,W	;SET BUILDING POP-UPS
	JRUC	COPTER_STAGE4_PROC
CS3P_NOT_DONE
	MOVE	*A8(OXVEL),A14,L
	ADDI	-08000H,A14		;ACCELERATE TO THE LEFT
	MOVE	A14,*A8(OXVEL),L
	MOVE	*A8(OXVAL),A4,L
	CALLR	DROP_NONBOYS		;DROP-A-NONBOY
	MOVI	04000H,A0
	MOVI	02000H,A1
	MOVI	03000H,A2
	CALLR	FLY_EFFECT2		;FLY!		
	SLEEP	1
	JRUC	CS3P_LUPE

**************************************************************************
*								         *
* COPTER_STAGE4_PROC - FLY AROUND ABOVE THE BUILDING			 *
*								         *
**************************************************************************

COPTER_STAGE4_PROC
	CLR	A9			;INIT X ACCELERATION
	MOVK	8,A11			;NONBOY DROP TIME INTERVAL
	
	MOVE	*A8(OHIT_POINTS),A14,W
	JRP	CS4P_HEAD_LUPE
	MOVK	11,A14
	MOVE	A14,*A8(OHIT_POINTS),W
	
CS4P_HEAD_LUPE
;	JRUC	CS4P_GO			;DON'T DIE!
;
;	MOVE	*A8(OHIT_POINTS),A14,W
;	JRP	CS4P_GO
;
;	MOVK	1,A14
;	MOVE	A14,@SCROLL_FLAG,W
;
;	MOVI	04000H,A14
;	MOVE	A14,*A8(OYACCEL),W
;
;	CLR	A14
;	MOVE	A14,*A8(OXVEL),L
;	MOVE	A14,*A8(OZVEL),L
;
;	CALLA	PULL_ANIM_ALL
;
;	SOUNDZ	SND_DIE_COPTER
;
;CS4P_TIME_TO_DIE
;
;* B0 = OZVAL								 *
;* B1 = min Xpos								 *
;* B2 = max Xpos								 *
;* B3 = min Xvel								 *
;* B4 = max Xvel								 *
;* B5 = min Ypos								 *
;* B6 = max Ypos								 *
;* B7 = min Yvel								 *
;* B8 = max Yvel								 *
;* B9 = min Zvel								 *
;* B10 = max Zvel							 *
;* B14 = Ptr to explosion script						 *
;
;	MOVE	A8,B14
;
;	MOVE	*B14(OZVAL),B0,L
;
;	MOVE	*B14(OXPOS),B1,W
;	MOVE	B1,B2
;
;	MOVE	*B14(OYPOS),B5,W
;	MOVE	B5,B6
;
;	MOVE	*B14(OXVEL),B3,L
;	MOVE	B3,B4
;	SUBI	040000H,B3
;	ADDI	040000H,B4
;
;	MOVE	*B14(OYVEL),B7,L
;	MOVE	B7,B8
;	SUBI	040000H,B7
;	ADDI	040000H,B8
;
;;	MOVE	*B14(OZVEL),B9,L
;;	MOVE	B9,B10
;;	SUBI	01000H,B9
;	CLR	B9
;	CLR	B10
;
;	MOVI	COPTER_DEATH_FRAG,B14
;	CALLA	Fragger
;
;;	CALLA	SCRTST
;;	JRNZ	CS4P_DIE
;	MOVE	*A8(OYVAL),A14,L
;	CMPI	-019325DFH,A14
;	JRGT	CS4P_DIE
;	SLEEP	2
;	JRUC	CS4P_TIME_TO_DIE
;CS4P_GO
	MOVE	*A8(OYVAL),A0,L
	MOVE	@YBASE,A14,L
	ADD	A14,A0
	CMPI	-01320000H,A0
	JRGT	CS4P_ALIVE		;BR=NOT FAR ENOUGH OFF SCREEN YET
CS4P_DIE
	MOVE	A8,A0
	JRUC	CS4P_START		;THE BEGINNING OF THE END
CS4P_LUPE
	MOVE	*A8(OPARTS),A8,L
	JRZ	CS4P_ZAP		;BR=NO MORE PARTS
CS4P_START
	MOVE	*A8(OID),A14,W
	CMPI	OID_NONBOY,A14
	JRNE	CS4P_LUPE		;BR=NOT A NONBOY
	CALLA	DEC_ENEMY_COUNT		;FOR THE NONBOY BEING DELETED
CS4P_ZAP
	MOVE	A0,A8			;BYE, BYE
	MOVE	*A8(OPLINK),A0,L
	JRZ	CS4P_NO_PROC
	CLR	A14
	MOVE	A14,*A8(OPLINK),L
	CALLA	KILL			;KILL GUNVECT PROC
CS4P_NO_PROC
	CALLA	DELETE_OBJ

	CLR	A8				;FULL DOWN
	MOVK	3,A10
	MOVI	60,A11
	CREATE	PID_IND,TRACK_FADE_OUT_FULL_PROC

	DIE
CS4P_ALIVE
	MOVE	*A8(OXVEL),A3,L
	MOVE	*A8(OXVAL),A4,L
	MOVE	A9,A9
	JRZ	CS4P_NO_HOVER		;BR=NO HOVERING
	ADD	A9,A3			;ADD X ACCELERATION
	MOVE	A3,*A8(OXVEL),L

	MOVI	03000H,A0
	MOVI	02000H,A1
	MOVI	03000H,A2
	CALLR	FLY_EFFECT2		;FLY AROUND SOME

	BTST	0,A9
	JRNZ	CS4P_GET_OFF		;BR=LEAVING THE SCREEN

	MOVE	A9,A0
	GETST	A1			;GET ACCELERATION SIGN
	ABS	A0
	CMPI	03000H,A0
	JRNE	CS4P_NO_INIT		;BR=NOT STOPPING
	MOVE	A3,A3
	GETST	A2			;GET VELOCITY SIGN
	XOR	A1,A2
	MOVE	A2,A2
	JRN	CS4P_DROP_NOW		;BR=SAME SIGNS, STILL GOING SAME DIR

CS4P_NO_INIT
;	MOVE	*A8(OXVAL),A0,L
	CMPI	03D20000H-0A00000H,A4
	JRGT	CS4P_CHECK_RIGHT_HOVER	;BR=WITHIN LEFT HOVER LIMIT
	MOVE	A3,A3
	JRNN	CS4P_DROP_NOW		;BR=MOVIN' TOWARD THE RIGHT
	MOVI	04000H,A9		;MOVE TO THE RIGHT, NOW!
	JRUC	CS4P_DROP_NOW
CS4P_CHECK_RIGHT_HOVER
	CMPI	03D20000H+0A00000H,A4
	JRLT	CS4P_CHECK_THIS		;BR=WITHIN RIGHT HOVER LIMIT
	MOVE	A3,A3
	JRN	CS4P_DROP_NOW		;BR=MOVIN' TOWARD THE LEFT
	MOVI	-04000H,A9		;MOVE TO THE LEFT, NOW!
	JRUC	CS4P_DROP_NOW

CS4P_CHECK_THIS
	MOVI	0800H,A0		;GET NORMAL FLYING ACCELERATION
	MOVE	A9,A9	
	JRNN	CS4P_NOT_NEG		;BR=WE'RE POSITION RIGHT NOW
	NEG	A0	
CS4P_NOT_NEG
	MOVE	A0,A9

	MOVE	*A13(PHOVERSTART),A14,L	;CHECK HOVERING TIME
	MOVE	@WAVEIRQS,A0,L
	SUB	A14,A0
	CMPI	180,A0
	JRLT	CS4P_HOVER_OK		;BR=UNDER LIMIT
	CALLA	TAKE_OFF_NOW		;YOU HOVERED ENOUGH NOW GIT!
	JRUC	CS4P_DROP_NOW
CS4P_HOVER_OK
	MOVI	256,A0
	CALLA	RANDPER
	JRNC	CS4P_DROP_NOW		;BR=DON'T WANNA REVERSE
	NEG	A9			;REVERSE X ACCELERATION			
	MOVI	256,A0
	CALLR	TAKE_OFF		;CHECK IF WE WANNA TAKE OFF
	JRUC	CS4P_DROP_NOW

CS4P_NO_HOVER				;FLYING HIGH AGAIN
	MOVI	01800H,A0
	MOVI	01800H,A1
	MOVI	02000H,A2
	CALLR	FLY_EFFECT2		;FLY AROUND SOME
CS4P_GET_OFF
;	MOVE	*A8(OXVAL),A0,L
	CMPI	01600000H,A4
	JRGT	CS4P_CHECK_RIGHT	;BR=WITHIN LEFT LIMIT
	MOVI	01600001H,A1		;NEW POSITION
	MOVI	080000H,A2		;NEW VELOCITY
	JRUC	CS4P_SET
CS4P_CHECK_RIGHT
	CMPI	06440000H,A4
	JRLT	CS4P_DROP		;BR=WITHIN RIGHT LIMIT
	MOVI	0643FFFFH,A1		;NEW POSITION
	MOVI	-080000H,A2		;NEW VELOCITY
CS4P_SET
	MOVI	512,A0
	CALLA	RANDPER
	JRNC	CS4P_NO_STOP		;BR=NOT GOIN' TO STOP ON THIS PASS
	INC	A2
CS4P_NO_STOP
	MOVE	A1,*A8(OXVAL),L		;SET HEAD'S X
	MOVE	A2,*A8(OXVEL),L		
	MOVI	-02C00000H,A14
	MOVE	A14,*A8(OYVAL),L	;SET HEAD'S Y
	CLR	A9			;RESET Y MOTION
	MOVE	A9,*A8(OYACCEL),W
	MOVE	A9,*A8(OYVEL),L
	MOVE	A9,*A13(PYACCEL),L
	MOVK	M_FLIPH,A0
	CALLA	TOGGLE_FLPS		;FLIP THE MOTHER
	JRUC	CS4P_NAP
CS4P_DROP
	BTST	0,A9
	JRNZ	CS4P_DROP_NOW		;BR=LEAVING THE SCREEN		

;	MOVE	*A8(OXVEL),A14,L
	BTST	0,A3
	JRNZ	CS4P_DROP_NOW		;BR=NOT GOIN' TO STOP

;	MOVE	*A8(OXVAL),A0,L		;CHECK IF WE CAN STOP
	MOVE	@XBASE,A14,L
	SUB	A4,A14
	ABS	A14
	CMPI	0A00000H,A14
	JRGE	CS4P_DROP_NOW		;BR=CAN'T STOP YET

	MOVI	256,A0
	CALLA	RANDPER
	JRNC	CS4P_DROP_NOW		;BR=DON'T WANNA STOP
	MOVE	@WAVEIRQS,A14,L
	MOVE	A14,*A13(PHOVERSTART),L
	MOVI	03000H,A9
;	MOVE	*A8(OXVEL),A14,L
	MOVE	A3,A3
	JRN	CS4P_DROP_NOW		;BR=X ACCEL SET FOR CURRENT NEG MOTION
	NEG	A9	
CS4P_DROP_NOW
	CALLR	DROP_NONBOYS		;DROP-A-NONBOY
CS4P_NAP
	SLEEP	1
	JRUC	CS4P_HEAD_LUPE

;COPTER_DEATH_FRAG
;	.long	COPTER_EXPLO_ANIM,0
;	.word	OID_JUNK,(5 << 11) + (1 << 6) + (FRGBOG+FRGNOFLY+FRGNOFLP+FRGPAL)
;	.long	0

**************************************************************************
*								         *
* TAKE_OFF     - LEAVE THE SCREEN IF RANDOM EVENT OCCURS		 *
* TAKE_OFF_NOW - LEAVE THE SCREEN NOW					 *
* 									 *
* PASS:									 *
* A0 = PROBABILITY FOR TAKE_OFF (0-1023) P(A0=1024) = 1; P(A0=1) = 1/102 *
* A8 = HELICOPTER OBJECT						 *
* A9 = CURRENT X ACCELERATION						 *
*								         *
**************************************************************************

TAKE_OFF
	CALLA	RANDPER
	JRNC	TO_NOPE			;BR=DON'T WANNA TAKE OFF JUST YET
TAKE_OFF_NOW
	MOVE	*A8(OCTRL),A0,L
	MOVE	A9,A9
	JRN	TO_OTHER_CHECK		;BR=CHECK DA OTHER DIRECTION
	BTST	B_FLIPH,A0
	JRNZ	TO_GO			;BR=FACING DIRECTION, TAKE OFF!
	RETS
TO_OTHER_CHECK
	BTST	B_FLIPH,A0
	JRNZ	TO_NOPE			;BR=NOT FACING TAKE OFF DIRECTION				
TO_GO	
	SLL	4,A9			;INCREASE X ACCELERATION
	INC	A9			;FLAG TAKE OFF
TO_NOPE
	RETS

**************************************************************************
*								         *
* COPTER_INTRO_CVECT - Collision vector table for the intro copter.	 *
*								         *
**************************************************************************
COPTER_INTRO_CVECT
	WWL	OID_PROCKET,~MASK_PLAYER,COPTER_ROCKET_COLL
	WWL	OID_PEXPLOSION,~MASK_PLAYER,COPTER_EXPLOSION_COLL
	WL	0,DUMCRETS

**************************************************************************
*								         *
* COPTER_ROCKET_COLL - Rocket collision for the intro copter.		 *
* A0 = Ptr to rocket object						 *
* A8 = Ptr to copter part						 *
*								         *
**************************************************************************
COPTER_ROCKET_COLL
;	CALLA	GETHEADPART
	MOVE	A0,*A8(OATE_ROCKET),L
	RETS

**************************************************************************
*								         *
* COPTER_EXPLOSION_COLL - Explosion collision for the intro copter.	 *
* A0 = Ptr to explosion object.						 *
* A8 = Ptr to the copter part.						 *
*								         *
**************************************************************************
COPTER_EXPLOSION_COLL
	move	*A8(OATE_ROCKET),A14,L
	jrz	CEC_X				;BR=NO ROCKET COLLISION
	CMP	A0,A14
	JRNE	CEC_X				;BR=DIFFERENT EXPLOSION

	MOVE	*A0(RL_INTENDED_OBJ),A14,L	;DO WE HAVE THE RIGHT TARGET?
	CMP	A8,A14
	JRNE	CEC_X				;BR=NOPE. NOT THE RIGHT TARGET.

;	CALLA	CV_ROCKET
;
;	SOUND1	SND_ROCKET_COPTER
;
;	CLRM	*A8(OATE_ROCKET),L		;Need another rocket
;
;	MOVE	A0,B14
;	
;	MMTM	SP,B1,B2,B4,B5,B6,B8,B9
;
;	MOVE	*A0(OZVAL),A1,L
;	MOVE	A1,B0
;
;	MOVE	*A0(OXVAL),A3,L
;	MOVE	A3,B1
;	SRA	16,B1
;	MOVE	B1,B2
;
;	MOVE	*A0(OYVAL),A5,L
;	MOVE	A5,B5
;	SRA	16,B5
;	MOVE	B5,B6
;
;	MOVI	-040000H,B3
;	MOVI	040000H,B4
;
;	MOVE	*B14(OYVEL),B7,L
;	MOVE 	B7,B8
;	ADDI	-040000H,B7
;	ADDI	060000H,B8
;
;	MOVE	*B14(OZVEL),B9,L
;	MOVE	B9,B10
;	SUBI	0C00H,B9
;
;	MOVE	@SCRNTL,A7,L
;	MOVE	A7,A9
;	SEXT	A7,W
;	SRA	16,A9
;
;	STOUXY	A1,A7,A9
;
;	CMP	A7,A3
;	JRGE	CEC_T
;	SRA	16,A7
;	MOVE	A7,B1
;	MOVE	A7,B2
;	CLR	B3
;	SLL	2,B4
;CEC_T
;	CMP	A9,A5
;	JRGE	CEC_BR
;	SRA	16,A5
;	MOVE	A5,B5
;	MOVE	A5,B6
;	CLR	B7
;	ADDI	060000H,B8
;CEC_BR	
;	MOVE	@SCRNBR,A7,L
;	MOVE	A7,A9
;	SEXT	A7,W
;	SRA	16,A9
;
;	STOUXY	A1,A7,A9
;
;	CMP	A7,A3
;	JRLE	CEC_B
;	SRA	16,A7
;	MOVE	A7,B1
;	MOVE	A7,B2
;	SLL	2,B3
;	CLR	B4
;CEC_B
;	CMP	A9,A5
;	JRLE	CEC_FRAG
;	SRA	16,A5
;	MOVE	A5,B5
;	MOVE	A5,B6
;	ADDI	-040000H,B7
;	CLR	B8
;
;CEC_FRAG
;	MOVI	COPTER_EXPLO_FRAG,B14		;SCRIPT
;	CALLA	Fragger
;	MMFM	SP,B1,B2,B4,B5,B6,B8,B9

	MOVE	A0,A1
	MOVK	BOMB_POINTS,A0
	CALLR	CHECK_FREAK_SPEECH
	MOVE	A1,A0

	CLRM	*A8(OATE_ROCKET),L		;HIT! READY FOR ANOTHER!

	MOVE	*A0(OID),A0,W			;GET PLAYER DATA ADDRESS
	CALLA	POID_TO_PDATA

	MOVI	ROCKET_DAMAGE,A0,W		;ROCKET DAMAGE

	MOVE	*A8(OCOLLISION),A14,L
	JRZ	CEC_X				;BR=NO COLLSION ROUTINE	
	JUMP	A14

CEC_X
	RETS

**************************************************************************
*								         *
* CHECK_FREAK_SPEECH - CHECK IF WE SHOULD MAKE FREAK OUT SPEECH		 *
* 									 *
* PASS:									 *
* A0 = DAMAGE POINTS							 *
* A8 = PART OBJECT							 *
* RETURN:								 *
* NUTIN'								 *
*								         *
**************************************************************************

CHECK_FREAK_SPEECH
	MMTM	SP,A0,A1,A8
	calla	GET_HEAD_PART

	MOVE	*A8(OHIT_POINTS),A14,W
	SUB	A0,A14
	MOVE	A14,*A8(OHIT_POINTS),W

	CMPK	BOMB_POINTS,A0
	JREQ	CFS_GO				;BR=HIT BY A BOMB
	CMPI	RADIO_AT,A14
	JRGT	CFS_X				;BR=NOT READY FOR SPEECH
CFS_GO
	MOVK	2,A0
	MOVI	0F0H,A1
	CALLA	CKSNDPRI			;Still timing the radio chatter?
	JRC	CFS_X				;BR = Yes

	move	@WAVEIRQS,A14,L
	cmpi	NO_FREAK_AFTER_TIME,A14		;Is it too late for the sound?
	jrhs	CFS_X				;BR = Yes

	move	*A8(OFREAKED),A14,W		;Have we freaked already?
	jrnz	CFS_X				;BR = Yes
	move	*A8(OHIT_COUNT),A14,W
	inc	A14
	move	A14,*A8(OHIT_COUNT),W
	cmpi	1,A14
	jrlo	CFS_X
*Need to get FREAK snd on channel 1
	SOUND1	SND_PILOT_FREAK			;Kick that freaky sound
	jrnz	CFS_Sound_Fail			;BR = Did not get made
	MOVKM	1,*A8(OFREAKED),W
	JRUC	CFS_X
CFS_Sound_Fail
	CLRM	*A8(OHIT_COUNT),W		;Clear the count on failure
CFS_X
	MMFM	SP,A0,A1,A8
	RETS


;COPTER_EXPLO_FRAG
;	.long	COPTER_EXPLO_ANIM,0
;	.word	OID_JUNK,(15 << 11) + (1 << 6) + (FRGBOG+FRGNOFLY+FRGNOFLP+FRGPAL)
;	.long	0
;
;COPTER_EXPLO_ANIM
;	LW	FHKEXPLOB1,6
;	LW	FHKEXPLOB2,8
;	LW	FHKEXPLOB3,6
;	LW	FHKEXPLOB4,4
;	LW	FHKEXPLOB5,4
;	LW	FHKEXPLOB6,3
;	LW	FHKEXPLOB7,3
;	LW	FHKEXPLOB8,2
;	LW	FHKEXPLOB9,2
;	LW	FHKEXPLOB10,2
;	LW	FHKEXPLOB11,2
;	LWL	1,1|AFunc,DELETE_OBJ

**************************************************************************
*								         *
* DROP_NONBOYS - DROP 'EM FROM DA COPTER				 *
*								         *
* PASS:									 *
* A4  = OXVAL OF COPTER							 *
* A8  = OBJECT								 *
* A10 = WAVEIRQS AT LAST DROP						 *
* A11 = NONBOY DROP TIME INTERVAL					 *
*								         *
**************************************************************************

DROP_NONBOYS
;	MOVE	*A8(OXVAL),A0,L
	SUBI	03D40000H,A4
	ABS	A4
;	CMPI	0C00000H,A4
	CMPI	0A00000H,A4
	JRGT	DN_NO_CAN_DO			;BR=CAN'T DROP 'EM HERE!

;	MOVE	@WAVEIRQS,A14,L
;	MOVE	*A8(ODROPTIME),A0,L
;	SUB	A0,A14
;	CMPI	5,A14
;	JRLT	DN_NO_CAN_DO
;	ADD	A14,A0
;	MOVE	A0,*A8(ODROPTIME),L

	MOVI	OID_NONBOY,A0
	CALLA	GET_ENEMY_COUNT
	CMPI	10,A0
	JRHS	DN_NO_CAN_DO			;BR=MAX NONBOYS
	
	MOVE	@WAVEIRQS,A14,L
	MOVE	A14,A0
	SUB	A10,A14
	CMP	A11,A14
	JRLT	DN_NO_CAN_DO			;BR=NOT ENOUGH TIME YET			

	MOVE	A0,A10
	MMTM	SP,A9,A10,A11			;REGISTERS, SAVE 'EM			

	MOVE	*A8(OZVAL),A11,L		;GET COPTER'S Z
	ADDK	17,A11				;PUT NONBOY IN BACK
	MOVI	-02180000H,A10			;TOP OF BUILDING Y
	MOVE	*A8(OYVAL),A9,L			;GET COPTER'S Y
	ADDI	75 << 15,A9			;OFFSET IT SOME
	MOVE	*A8(OCTRL),A0,W
	MOVI	65 << 15,A14			;DEFAULT X OFFSET
	BTST	B_FLIPH,A0
	JRZ	DN_X_OK				;BR=WE'RE NOT FLIPPED
	NEG	A14				;WE'RE FLIPPED, NEGATE OFFSET
DN_X_OK
	MOVE	A8,A2
	MOVE	*A8(OXVAL),A8,L			;GET COPTER'S X
	SUB	A14,A8				;OFFSET X 
	CREATE	PID_IND,CREATE_HELIDROP_NONBOY0	
	MOVE	A2,A8
	MMFM	SP,A9,A10,A11			;GET 'EM BACK
DN_NO_CAN_DO
	RETS

**************************************************************************
*								         *
* A_CHECK_SMOKE - SHOULD WE MAKE SOME SMOKE?				 *
* 									 *
* PASS:									 *
* A8 = OBJECT								 *
*								         *
**************************************************************************

A_CHECK_SMOKE
	CALLA	GET_HEAD_PART
	MOVE	*A8(OHIT_POINTS),A1,W
	CMPI	MAKE_SMOKE_AT,A1
	JRGT	ACS_NO_SMOKE

* B0 = OZVAL								 *
* B1 = min Xpos								 *
* B2 = max Xpos								 *
* B3 = min Xvel								 *
* B4 = max Xvel								 *
* B5 = min Ypos								 *
* B6 = max Ypos								 *
* B7 = min Yvel								 *
* B8 = max Yvel								 *
* B9 = min Zvel								 *
* B10 = max Zvel							 *
* B14 = Ptr to explosion script						 *

	MOVE	A8,B14

	MOVE	*B14(OZVAL),B0,L

	MOVI	024H,B7
	MOVI	080000H,B8
	MOVI	-014H,A2
	MOVE	*A8(OCTRL),A14,W
	BTST	B_FLIPH,A14
	JRZ	ACS_NO_FLIPH
	NEG	B7
	NEG	B8
	NEG	A2
ACS_NO_FLIPH
	MOVE	*B14(OXPOS),B1,W
	ADD	B7,B1
	MOVE	B1,B2

	MOVE	*B14(OYPOS),B5,W
	ADDI	-022H,B5
	MOVE	B5,B6

	MOVE	*B14(OXVEL),B3,L
	MOVE	B3,B4
	ADD	B8,B4	

	MOVE	*B14(OYVEL),B7,L
	MOVE	B7,B8

	MOVE	*B14(OZVEL),B9,L
	MOVE	B9,B10
	ADDI	0100H,B9
	SUBI	0100H,B10

	MOVI	COPTER_SMOKE_FRAG,B14
	CALLA	Fragger

	CMPI	MORE_SMOKE_AT,A1
	JRGT	ACS_NO_SMOKE

	MOVE	A8,B14

	SUBK	2,B0

	MOVE	*B14(OXPOS),B1,W
	MOVE	A2,B2
	ADD	B2,B1
	MOVE	B1,B2

	MOVE	*B14(OYPOS),B5,W
	ADDI	-025H,B5
	MOVE	B5,B6

	MOVE	*B14(OZVEL),B10,L

	MOVI	COPTER_SMOKE_FRAG,B14
	CALLA	Fragger

ACS_NO_SMOKE
	RETS

COPTER_SMOKE_FRAG
	.long	COPTER_SMOKE_ANIM,0
	.word	OID_JUNK,(3 << 11) + (1 << 6) + (FRGBOG+FRGNOFLY+FRGPAL+FRGRND)
	.long	0

COPTER_SMOKE_ANIM
	LW	SMOKTR1,3
	LW	SMOKTR2,3
	LW	SMOKTR3,3
	LW	SMOKTR4,4
	LW	SMOKTR5,4
	LW	SMOKTR6,4
	LWL	1,1|AFunc,DELETE_OBJ


	.def	KCAGE_EXPLO_INIT

KCAGE_EXPLO_INIT
	.byte	 2, 0, 0, 1	;OBJCNT, PRCCNT, IMGPALCNT, PALCNT
	.long	REXPLO		;IMGPAL
	.word	OID_JUNK, 0	;OID, GLOBAL_OPTIONS
*        .long IMG
*        .word OCTRL, OFLAGS, OZOFF
*        .word OPTIONS 
	LWWWW	REXPLOA1h, DMAWNZ, M_MANSCALE|M_NOSCALE, 0, OM_ANIM
	.long	KCAGE_EXPLO_ANIM
	LWWWW	REXPLOA1h, DMAWNZ|M_FLIPH, M_MANSCALE|M_NOSCALE, 0, 0

KCAGE_EXPLO_ANIM
	LW	REXPLOA1h,1|AMulti
	LW	REXPLOA1h,2

	LW	REXPLOA3h,1|AMulti
	LW	REXPLOA3h,2

	LW	REXPLOA4h,1|AMulti
	LW	REXPLOA4h,2

	LW	REXPLOA5h,1|AMulti
	LW	REXPLOA5h,2

	LW	REXPLOA6h,1|AMulti
	LW	REXPLOA6h,2

	LW	REXPLOA8h,1|AMulti
	LW	REXPLOA8h,2

	LW	REXPLOA9h,1|AMulti
	LW	REXPLOA9h,2

	LW	REXPLOA10h,1|AMulti
	LW	REXPLOA10h,2

	LW	REXPLOA11h,1|AMulti
	LW	REXPLOA11h,2

	LW	REXPLOA12h,1|AMulti
	LW	REXPLOA12h,2

	LWL	1,1|AFunc,DELETE_OBJ_PROC




	.END

