 	.MLIB	"GXMACS.LIB"
	.FILE	"GXHELGA.ASM"
	.TITLE	"<<< GENERATION X -- Head Mistress Helga >>>"
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
	.INCLUDE	"GXCONTRL.H"
	.INCLUDE	"IMGTBL.GLO"
	.INCLUDE	"GXHELGA.TBL"

	.BSS	HELGA_GRUNT_FLAGS,32		;UHL
	.BSS	HELGA_THREAT_FLAGS,32		;UHL
	.BSS	HELGA_BITCH_FLAGS,32		;UHL

***** In this file
	.DEF	START_HELGA, PROC_THRONE_HELGA, START_FINAL_HELGA
	.DEF	MAKE_TABLE_SOUND

***** from GXAFUNC.ASM
	.REF	A_STAY_TIL_WY_GT, A_Set_Var_Word, A_STAY_TIL_OFFSCRN

***** from GXMONDR2.ASM
	.REF	MONDOR_START_FLAG

* SYMBOLS FROM GXD.ASM
	.REF	SET_ODAG_MULTI

* SYMBOLS FROM GXENEMY.ASM
	.REF	EFLASH_SHORT_INIT, GUN_FLASH_MULTI

***** from GXBLOOD.ASM
	.REF	BLOODY_BULLET_HIT_OFFSET

* SYMBOLS FROM GXBEEK2.ASM
	.REF	CURPLYR_ADJ

* SYMBOLS FROM GXCOG.ASM
	.REF	HIT_ENEMY

***** from GXRAM.ASM
	.REF	BASE_HIT, GUNS_OFF

* SYMBOLS FROM GXPALL.ASM
;	.REF	A_CHANGE_PAL_MULTI

* SYMBOLS FROM GXHELI.ASM
	.REF	PICK_ENTRY2

***** from GXDESK.ASM
	.REF	A_ADD_YPOS

	.TEXT

;1388     ($056c)  3         92.1    105.6   HELGA triumphant laugh
;1389     ($056d)  3         69.1     79.2   HELGA had enough?

;1391     ($056f)  3        111.8    128.2   HELGA you've been a bad boy

;1392     ($0570)  3         80.4     92.2   HELGA irresponsible -- 
;1393     ($0571)  3         69.9     80.2   HELGA scatterbrained --
;1394     ($0572)  3         69.1     79.2   HELGA undisciplined --

;1390     ($056e)  3        108.0    123.8   HELGA you can't harm the headmistress
;1395     ($0573)  3         36.8     42.2   HELGA brat!
;1396     ($0574)  3         43.9     50.4   HELGA brats!
;1397     ($0575)  3         78.7     90.2   HELGA how dare you?

;1398     ($0576)  3        137.3    157.4   HELGA you ain't seen nothing yet

;1399     ($0577)  1         17.2     19.7   HELGA effort grunt #0
;1400     ($0578)  2         17.2     19.7   HELGA effort grunt #0
;1401     ($0579)  3         17.2     19.7   HELGA effort grunt #0
;1402     ($057a)  1         16.7     19.2   HELGA effort grunt #1
;1403     ($057b)  2         16.7     19.2   HELGA effort grunt #1
;1404     ($057c)  3         16.7     19.2   HELGA effort grunt #1
;1405     ($057d)  1         16.3     18.7   HELGA effort grunt #2
;1406     ($057e)  2         16.3     18.7   HELGA effort grunt #2
;1407     ($057f)  3         16.3     18.7   HELGA effort grunt #2
;1408     ($0580)  1         19.3     22.1   HELGA small damage
;1409     ($0581)  2         19.3     22.1   HELGA small damage
;1410     ($0582)  3         19.3     22.1   HELGA small damage
;1411     ($0583)  1         43.5     49.9   HELGA medium damage #0
;1412     ($0584)  2         43.5     49.9   HELGA medium damage #0
;1413     ($0585)  3         43.5     49.9   HELGA medium damage #0
;1414     ($0586)  1         31.8     36.5   HELGA medium damage #1
;1415     ($0587)  2         31.8     36.5   HELGA medium damage #1
;1416     ($0588)  3         31.8     36.5   HELGA medium damage #1

;1436     ($059c)  3         92.9    106.6   HELGA I will destroy you
;1437     ($059d)  3         81.2     93.1   HELGA you will obey

*
* Sounds for Helga
*
SND_JUMP_LAND
	.WORD	0F330H,26,0A1D1H,0
;SND_HELGA_ASS
;	.WORD	0F142H,26,0A4EFH,0
SND_HELGA_TUNE
	.WORD	0F0FDH,1,08014H,0
SND_HELGA_TAUNT
	.WORD	0F380H,185,08506H,0

SND_HELGA_BODY_THUD
	.WORD	0F120H,26,0A1CFH,0

SND_BAD_BOY
	.WORD	0F3F1H,112,0856FH,0
SND_YOU_AINT_SEEN
	.WORD	0F380H,138,08576H,0


SND_IRR
	.WORD	0F380H,81,08570H,0
SND_SCAT
	.WORD	0F380H,70,08571H,0
SND_UND
	.WORD	0F380H,70,08572H,0
SND_HOW_DARE_YOU
	.WORD	0F380H,78,08575H,0

HELGA_BITCHES	EQU	4

HELGA_BITCH_TABLE
	.LONG	SND_IRR, SND_SCAT, SND_UND, SND_HOW_DARE_YOU


SND_HELGA_FIRE
	.WORD	0E303H,10,0A10BH,0

SND_HAD_ENOUGH
	.WORD	0F33FH,70,0856CH,0
SND_YOU_CANT_HARM
	.WORD	0F33FH,108,0856EH,0
SND_I_WILL_DESTROY_YOU
	.WORD	0F33FH,93,0859CH,0
SND_YOU_WILL_OBEY
	.WORD	0F33FH,82,0859DH,0

HELGA_THREATS	EQU	4

HELGA_THREAT_TABLE
	.LONG	SND_HAD_ENOUGH, SND_YOU_CANT_HARM, SND_I_WILL_DESTROY_YOU
	.LONG	SND_YOU_WILL_OBEY

SND_HELGA_STUN
	.WORD	0F340H,20,0A582H,0

SND_HELGA_FALLDOWN_0
	.WORD	0F360H,44,0A585H,0
SND_HELGA_FALLDOWN_1
	.WORD	0F360H,32,0A588H,0

SND_HELGA_GRUNT_0
	.WORD	0F360H,18,0A579H,0
SND_HELGA_GRUNT_1
	.WORD	0F360H,17,0A57CH,0
SND_HELGA_GRUNT_2
	.WORD	0F360H,17,0A57FH,0

HELGA_GRUNTS	EQU	3

HELGA_GRUNT_TABLE
	.LONG	SND_HELGA_GRUNT_0,SND_HELGA_GRUNT_1,SND_HELGA_GRUNT_2

FINAL_STAGE_Y	EQU	-02FB800H

CARTWHEEL_XVEL	EQU	01AAAAH	;028000H;01AAAAH;014000H;010000H

CARTWHEEL_TIME	EQU	3	;2	;3	;4	;5

;CARTWHEEL_XVEL_TABLE
;	.LONG	014000H, 01AAAAH, 028000H

MIN_HIT_TIME	EQU	20

HELGA_GUN_HITS	EQU	7

HELGA_HANG_TIME	EQU	60

THRONE_X_ERROR	EQU	0100000H

THROW_YACCEL	EQU	04000H

ROCKET_PUSH_ZVEL	EQU	080H

Z_GET_CLOSER	EQU	01000H

FARTHEST_WORLD_Z	EQU	0C000H

MIN_THROW_TIME	EQU	120

MAX_THROWS	EQU	1

MIN_STUN_TIME	EQU	100

MAX_STUNS	EQU	2

MIN_SHOOTTIME	EQU	88

*
* ODATA for Helga enemy
*

OATE_ROCKET	EQU	ODATA		;UHL ROCKET OBJECT	
OHFLAGS		EQU	ODATA+020H	;UHW FLAGS
OCARTSPEED	EQU	ODATA+030H	;UHW CARTWHEEL SPEED TIME
OLASTHITTIME	EQU	ODATA+040H	;UHL TIME OF LAST HIT
OHITS		EQU	ODATA+060H	;UHL HITS FROM EACH PLAYER
OTHROWS		EQU	ODATA+080H	;UHW NUMBER OF THROWS IN A ROW
OSTUNS		EQU	ODATA+090H	;UHW NUMBER OF STUNS IN A ROW
OLASTTHROW	EQU	ODATA+0A0H	;UHL TIME OF LAST THROW
OLASTSTUN	EQU	ODATA+0C0H	;UHL TIME OF LAST STUN
OTHRONE_OBJ	EQU	ODATA+0E0H	;UHL Throne object
OSHOOTTIME	EQU	ODATA+0100H	;UHL TIME OF HELGA START/LAST SHOOTIN'

M_INTRO		EQU	1

B_INTRO		EQU	0
	
**************************************************************************
*								         *
* START_FINAL_HELGA							 *
*								         *
**************************************************************************

START_FINAL_HELGA
	MOVI	FINAL_HELGA_INIT,B0	;Get dat multi-parter
	CALLA	CREATE_ENEMY

	CALLA	GET_SHAD_MULTI		;Setup her shadow

	CALLA	INSERT_ENEMY

;	MOVE	@YWORLD,A14,L
;	SUBI	FINAL_STAGE_Y,A14
;	MOVE	A14,*A8(OGRNDOFF),L

	MOVI	02000H,A14
	MOVE	A14,*A8(OYACCEL),W

	MOVK	M_INTRO,A14
	MOVE	A14,*A8(OHFLAGS),W

	MOVK	4,A14
	MOVE	A14,*A8(OCARTSPEED),W

	MOVI	[HELGA_GRUNTS, 0],A14
	MOVE	A14,@HELGA_GRUNT_FLAGS,L

	MOVI	[HELGA_BITCHES, 0],A14
	MOVE	A14,@HELGA_BITCH_FLAGS,L

	MOVI	[HELGA_THREATS, 0],A14
	MOVE	A14,@HELGA_THREAT_FLAGS,L

	MOVE	A8,A7
	MOVI	OID_MONDOR,A0
	CALLA	EXIST_OBJ_ALL
	LOCKON	Z
	MOVE	A8,*A7(OTHRONE_OBJ),L

	RETS

**************************************************************************
*								         *
* A_HELGA_GRUNT								 *
*								         *
**************************************************************************

A_HELGA_GRUNT
	MOVI	HELGA_GRUNT_TABLE,A3
	MOVI	HELGA_GRUNT_FLAGS,A6
	MOVK	HELGA_GRUNTS-1,A7
	CALLR	MAKE_TABLE_SOUND
	RETS

**************************************************************************
*								         *
* A_HELGA_THREAT							 *
*								         *
**************************************************************************

A_HELGA_THREAT
	MOVI	HELGA_THREAT_TABLE,A3
	MOVI	HELGA_THREAT_FLAGS,A6
	MOVK	HELGA_THREATS-1,A7
	CALLR	MAKE_TABLE_SOUND
	RETS

**************************************************************************
*								         *
* A_HELGA_BITCH								 *
*								         *
**************************************************************************

A_HELGA_BITCH
	MOVI	HELGA_BITCH_TABLE,A3
	MOVI	HELGA_BITCH_FLAGS,A6
	MOVK	HELGA_BITCHES-1,A7
	CALLR	MAKE_TABLE_SOUND
	RETS

**************************************************************************
*								         *
* MAKE_TABLE_SOUND							 *
* 									 *
* PASS:									 *
* A3 = ADDRESS OF TABLE							 *
* A6 = ADDRESS OF FLAGS LONG WORD					 *
* A7 = MAXIMUM NUMBER OF SOUNDS - 1					 *
* 									 *
* RETURN:								 *
* NUTIN'								 *
* UPDATED FLAGS LONG WORD						 *
*								         *
**************************************************************************

MAKE_TABLE_SOUND
	MMTM	SP,A0,A1,A4,A5

	MOVE	*A6,A1,L
	MOVE	A1,A0
	SRL	16,A0
	NEG	A0				;FLAG TABLE OF LONG WORDS
	ZEXT	A1,W
	MOVE	A1,A5
	CALLR	PICK_ENTRY2
	JRNZ	MTS_SAVE			;BR=NOT LAST ENTRY PICKED
	MOVE	A7,A0
	XOR	A5,A1
MTS_SAVE
	SLL	16,A0
	OR	A0,A1
	MOVE	A4,A0
	CALLA	ONESND
	JRNZ	MTS_NOGOOD			;BR=SANS SOUND
	MOVE	A1,*A6,L
MTS_NOGOOD
	MMFM	SP,A0,A1,A4,A5
	RETS

**************************************************************************
*								         *
* A_WAIT_TIL_ON_GROUND							 *
*								         *
**************************************************************************

A_WAIT_TIL_ON_GROUND
	MOVE	*A8(OFLAGS),A14,W
	BTST	B_GCOLL,A14
	JRZ	AWTOG_DONE
	MOVE	*A8(AnimFrm),A14,L
	SUBI	050H,A14
	MOVE	A14,*A8(AnimFrm),L
AWTOG_DONE
	RETS

**************************************************************************
*								         *
* A_WAIT_TIL_HELGA_OFFSCRN						 *
*								         *
**************************************************************************

A_WAIT_TIL_HELGA_OFFSCRN
	CALLA	GET_HEAD_PART
	MOVK	4,A0
AWTHO_LUPE	
	MOVB	*A8(OFLAGS),A14
	JRNN	AWTHO_ON		;BR=ON SCREEN
	DEC	A0
	JRZ	AWTHO_DONE		;BR=OFF SCREEN
	MOVE	*A8(OPARTS),A8,L
	JRNZ	AWTHO_LUPE		;BR=MORE PARTS TO CHECK			
	JRUC	AWTHO_DONE
AWTHO_ON
	MOVE	*A8(AnimFrm),A14,L
	SUBI	050H,A14
	MOVE	A14,*A8(AnimFrm),L
AWTHO_DONE
	RETS

**************************************************************************
*								         *
* A_HELGA_FIRE_FNC							 *
*								         *
**************************************************************************

A_HELGA_SHORT_FIRE_FNC
	MOVI	[-75,-17],A3			;FIRING OFFSET
	MOVI	EFLASH_SHORT_INIT,B0
	CALLA	GUN_FLASH_MULTI			;MAKE A GUN FLASH
	JRUC	AHFF_HIT
A_HELGA_FIRE_FNC
	MOVI	[-75,-17],A3			;FIRING OFFSET
	CALLA	EGUN_FLASH_MULTI		;MAKE A GUN FLASH
AHFF_HIT
	MOVE	@BASE_HIT,A5,L
;	SLL	4,A5
	SLL	4+1,A5

;	CLR	A5

	ALLPLYR	PLAYER_HIT			;HIT 'EM ALL

	SOUND1	SND_HELGA_FIRE

	RETS

**************************************************************************
*								         *
* A_START_HELGA_WHEEL							 *
*								         *
**************************************************************************

A_START_HELGA_WHEEL
	CLR	A14
	MOVE	A14,*A8(OZVEL),L

;	MOVE	*A8(OCARTSPEED),A14,W

	MOVI	CARTWHEEL_XVEL,A1
ASHW_RAND
	MOVE	@RAND,A0,W
	ANDI	M_FLIPH,A0
	JRZ	ASHW_SET			;BR=NO FLIP
	NEG	A1
ASHW_SET
	CALLA	SET_FLPS

	MOVE	A1,*A8(OXVEL),L

	MOVI	HELGA_WHEEL_ANIM,A14
	MOVE	A14,*A8(AnimScr),L

	MOVK	CARTWHEEL_TIME,A0
ASHW_SLEEP_LUPE
	MOVB	A0,*A8(AnimSLP)
	MOVE	*A8(OPARTS),A8,L
	JRNZ	ASHW_SLEEP_LUPE

	JRUC	A_HELGA_GRUNT


**************************************************************************
*								         *
* A_CENTER_HELGA_WHEEL - CARTWHEEL TOWARD CENTER SCREEN			 *
*								         *
**************************************************************************

A_CENTER_HELGA_WHEEL
	CLR	A14
	MOVE	A14,*A8(OZVEL),L

	CLR	A0				;DEFAULT NO FLIP
	MOVI	CARTWHEEL_XVEL,A1

	MOVI	HELGA_WHEEL_ANIM,A14
	MOVE	A14,*A8(AnimFrm),L

	MOVE	*A8(OXVAL),A2,L
	MOVE	@XBASE,A14,L
	SUB	A14,A2
	JRZ	ASHW_RAND			;BR=IN CENTER ALREADY, RANDOMIZE
	JRN	ASHW_SET			;BR=ON THE LEFT, NO FLIP
	MOVK	M_FLIPH,A0			;ON THE RIGHT, FLIP
	NEG	A1
	JRUC	ASHW_SET

**************************************************************************
*								         *
* A_AWAY_HELGA_WHEEL - CARTWHEEL AWAY FROM CENTER SCREEN		 *
*								         *
**************************************************************************

A_AWAY_HELGA_WHEEL
	CLR	A14
	MOVE	A14,*A8(OZVEL),L

	CLR	A0				;DEFAULT NO FLIP
	MOVI	CARTWHEEL_XVEL,A1

	MOVI	HELGA_WHEEL_ANIM,A14
	MOVE	A14,*A8(AnimFrm),L

	MOVE	*A8(OXVAL),A2,L
	MOVE	@XBASE,A14,L
	SUB	A14,A2
	JRZ	ASHW_RAND			;BR=IN CENTER ALREADY, RANDOMIZE
	JRNN	ASHW_SET			;BR=ON THE LEFT, NO FLIP
	MOVK	M_FLIPH,A0			;ON THE RIGHT, FLIP
	NEG	A1
	JRUC	ASHW_SET

**************************************************************************
*								         *
* A_WHEEL_CHECK								 *
*								         *
**************************************************************************

A_WHEEL_CHECK
	CALLA	SCRTST
	JRNZ	AWC_OFF

	MOVE	*A8(OZVAL),A0,L
	MOVE	*A8(OXVAL),A1,L

	UTOSX	A0,A1

	CMPI	SCRLFT+SCRWIDTH/6,A1
	JRLT	AWC_DONE
	CMPI	SCRRGT-SCRWIDTH/6,A1
	JRGT	AWC_DONE

	MOVE	*A8(OSHOOTTIME),A14,L			;CHECK LAST SHOOT
	JRNZ	AWC_SHOOT				;BR=SHOOT NOW

	MOVI	512+128,A0
	CALLA	RANDPER
	JRNC	AWC_DONE
AWC_SHOOT
	CLR	A14
	MOVE	A14,*A8(OXVEL),L

	MOVI	HELGA_START_SHOOT_ANIM,A14
	MOVE	A14,*A8(AnimFrm),L

AWC_DONE
	RETS
AWC_OFF
	MOVE	*A8(OXVAL),A0,L
	MOVE	@XBASE,A14,L
	SUB	A14,A0
	MOVE	*A8(OXVEL),A1,L
;	MOVE	*A8(OCTRL),A1,W
;	SLL	(31-B_FLIPH),A1			;SHIFT UP TO SIGN BIT	
	XOR	A0,A1
	SRL	31,A1
	JRNZ	AWC_DONE
;	JRZ	AWC_DONE

	MOVE	*A8(OZVAL),A1,L
	SUBI	Z_GET_CLOSER,A1
	MOVE	@ZBASE,A14,L
	ADDI	08000H,A14
	CMP	A14,A1
	JRGT	AWC_SET_Z
	MOVE	A14,A1
AWC_SET_Z
	MOVE	A1,A2

	MOVI	512,A0
	CALLA	RANDPER
	JRNC	AWC_JUMP_DOWN

	CALLA	SET_ANIPZU

	MOVK	M_FLIPH,A0
	CALLA	TOGGLE_FLPS

	MOVE	*A8(OXVEL),A14,L
	NEG	A14
	MOVE	A14,*A8(OXVEL),L
	
	RETS
AWC_JUMP_DOWN
	CLR	A14
	MOVE	A14,*A8(OXVEL),L

	MOVE	@RAND,A3,W
	MOVE	A3,A0
	ANDI	M_FLIPH,A0
	CALLA	SET_FLPS

;	MOVI	SCRRGT-SCRWIDTH/6,A0
	MOVI	SCRLFT+SCRWIDTH/3,A0
	MOVI	SCRLFT+SCRWIDTH/6,A1	
	CALLA	RANGERND
	BTST	15,A3
	JRZ	AWC_TRANS				;BR=ON DA LEFT SIDE
	ADDI	200,A0
AWC_TRANS
	MOVE	A0,A1
	STOUX	A2,A1

	MOVE	A2,A3
	MOVI	-0500000H,A2
	MOVE	@YBASE,A14,L
	SUB	A14,A2
	CALLA	SET_ANIPU

	MOVI	04000H,A14
	MOVE	A14,*A8(OYACCEL),W

	MOVE	*A8(OFLAGS),A14,W
	ORI	M_GCOLL,A14
	MOVE	A14,*A8(OFLAGS),W

	MOVI	FINAL_DROP_ANIM,A1
	CALLA	STRT_ANIM

	RETS

**************************************************************************
*								         *
* A_HELGA_JUMP_DOWN							 *
*								         *
**************************************************************************

A_HELGA_JUMP_DOWN
	MOVE	*A8(OZVAL),A2,L
	JRUC	AWC_JUMP_DOWN

**************************************************************************
*								         *
* A_CHECK_JUMP_UP							 *
*								         *
**************************************************************************

A_CHECK_JUMP_UP
	MOVE	*A8(AnimScr),A14,L
	CMPI	HELGA_JUMP_UP_ANIM,A14
	JRNE	ENABLE_HELGA_VECTORS
	RETS


**************************************************************************
*								         *
* A_SET_WHEEL_XVEL							 *
*								         *
**************************************************************************

A_SET_WHEEL_XVEL
	CALLA	GETAFARG_LONG
	MOVE	*A8(OCTRL),A14,W
	BTST	B_FLIPH,A14
	JRZ	ASWX_SET
	NEG	A0
ASWX_SET
	MOVE	A0,*A8(OXVEL),L
	RETS

**************************************************************************
*								         *
* A_JUMP_ON_SET_HFLAG							 *
* A_JUMP_ON_CLR_HFLAG							 *
*								         *
**************************************************************************

A_JUMP_ON_SET_HFLAG
	CALLA	GETAFARG_WORD	
	MOVE	*A8(OHFLAGS),A14,W
	AND	A0,A14
	JRNZ	AJOH_JUMP
	RETS
A_JUMP_ON_CLR_HFLAG
	CALLA	GETAFARG_WORD	
	MOVE	*A8(OHFLAGS),A14,W
	AND	A0,A14
	JRNZ	AJOH_DONE
AJOH_JUMP
	CALLA	GETAFARG_LONG
	MOVE	A0,*A8(AnimFrm),L
AJOH_DONE
	RETS
  
**************************************************************************
*								         *
* A_TOGGLE_HELGA_FLIP							 *
*								         *
**************************************************************************

A_TOGGLE_HELGA_FLIP
	MOVK	M_FLIPH,A0
	CALLA	TOGGLE_FLPS
	JAUC	SET_ODAG_MULTI

**************************************************************************
*								         *
* HELGA COLLISION VECTORS						 *
*								         *
**************************************************************************

HELGA_CVECT
	WWL	OID_PROCKET,~MASK_PLAYER,HELGA_ROCKET_COLL
	WWL	OID_PEXPLOSION,~MASK_PLAYER,HELGA_EXPLO_COLL
HELGA_GROUND_CVECT
	WWL	OID_GRND,0FFFFH,HELGA_GRND_COLLVECT
	WL	0,DUMCRETS

HELGA_GRND_COLLVECT
	CLR	A14
	MOVE	A14,*A8(OYACCEL),W
	MOVE	A14,*A8(OXVEL),L
	MOVE	A14,*A8(OYVEL),L
	MOVE	A14,*A8(OZVEL),L

	MOVE	*A8(OFLAGS),A14,W
	ANDNI	M_GCOLL,A14
	MOVE	A14,*A8(OFLAGS),W

	MOVI	FINAL_STAGE_Y,A1
	CALLA	SET_ANIPYU

	RETS

**************************************************************************
*								         *
* HELGA_ROCKET_COLL - ROCKET COLLISION WITH HELGA OBJECT		 *
*								         *
* PASS:									 *
* A0 = ROCKET OBJECT							 *
* A8 = HELGA OBJECT							 *
*								         *
**************************************************************************

HELGA_ROCKET_COLL
	CALLA	GETHEADPART			;OF ROCKET
	MOVE	A0,*A8(OATE_ROCKET),L
	RETS

HELGA_EXPLO_COLL
	CALLA	GETHEADPART			;OF EXPLOSION
	MOVE	*A8(OATE_ROCKET),A14,L
	JRZ	HEC_DONE			;BR=NO ROCKET COLLISION
	CMP	A0,A14
	JRNE	HEC_DONE			;BR=DIFFERENT EXPLOSION

	MOVE	*A0(RL_INTENDED_OBJ),A14,L	;DO WE HAVE THE RIGHT TARGET?
	CMP	A8,A14
	JRNE	HEC_DONE			;BR=NOPE. NOT THE RIGHT TARGET.
	
	CLRM	*A8(OATE_ROCKET),L		;HIT! READY FOR ANOTHER!

;	MOVE	*A0(OID),A0,W			;GET PLAYER DATA ADDRESS
;	CALLA	POID_TO_PDATA

	CALLA	GET_HEAD_PART
;	MOVE	*A8(OYVEL),A14,L
;	JRNZ	HEC_DONE
;	MOVE	*A8(OZVEL),A14,L
;	JRNZ	HEC_DONE

	MOVI	SND_HELGA_FALLDOWN_0,A0
	MOVE	@RAND,A14,W
	BTST	B_FLIPH,A14
	JRZ	HEC_SOUND
	MOVI	SND_HELGA_FALLDOWN_1,A0
HEC_SOUND
	CALLA	ONESND

	CLR	A14
	MOVE	A14,*A8(OYACCEL),W
	MOVE	A14,*A8(OXVEL),L
	MOVE	A14,*A8(OYVEL),L

	MOVE	*A8(OTHRONE_OBJ),A9,L

	MOVE	*A8(OXVAL),A3,L			;HELGA UNIVERSE X
	MOVE	*A9(OXVAL),A14,L		;THRONE UNIVERSE X
	SUB	A14,A3
	ABS	A3

	MOVI	ROCKET_PUSH_ZVEL,A0

	MOVE	*A8(OLASTTHROW),A14,L
	MOVE	@WAVEIRQS,A5,L
	MOVE	A5,*A8(OLASTTHROW),L
	SUB	A14,A5

	MOVE	*A8(OZVAL),A1,L
	MOVE	@ZBASE,A14,L
	SUB	A14,A1
	CMPI	FARTHEST_WORLD_Z,A1
	JRLT	HEC_SET_ZVEL

	CLR	A0				;CLEAR PUSH VELOCITY

	CMPI	THRONE_X_ERROR,A3
	JRGT	HEC_SET_ZVEL			;BR=NOT WITHIN THRONE LIMIT

	CMPI	MIN_THROW_TIME,A5
	JRLE	HEC_SET_ZVEL			;BR=UNDER MINIMUM TIME

	MOVI	HELGA_THRONE_START_ANIM,A1
	CALLA	STRT_ANIM

;	MOVI	DUMCOLL,A14
;	MOVE	A14,*A8(OCVECT),L
;	MOVI	DUMRETS,A14
;	MOVE	A14,*A8(OGUNVECT),L

	CALLA	ALL_COLLS_OFF

	MOVK	1,A14
	MOVE	A14,@GUNS_OFF,W

	CALLA	DELETE_SHADOW			;SHADOW GO AWAY

	RETS

HEC_SET_ZVEL
	MOVE	A0,*A8(OZVEL),L

	MOVI	-020000H,A14
	MOVE	A14,*A8(OYVEL),L
	MOVI	02000H,A14
	MOVE	A14,*A8(OYACCEL),W

	MOVE	*A8(OFLAGS),A14,W
	ORI	M_GCOLL,A14
	MOVE	A14,*A8(OFLAGS),W

	CLR	A14
	MOVB	A14,*A8(AnimSlp)

	MOVI	HELGA_FLYBACK_ANIM,A14
	MOVE	A14,*A8(AnimFrm),L

	CLR	A4
	CMPI	MIN_THROW_TIME,A5
	JRGT	HEC_NO_JUMP			;BR=OVER MINIMUM TIME
	MOVE	*A8(OTHROWS),A4,W
	INC	A4
	CMPK	MAX_THROWS,A4
	JRLT	HEC_NO_JUMP			;BR=NOT THROWN ENOUGH
	CLR	A14
	MOVE	A14,*A8(OTHROWS),W
	MOVI	HELGA_JUMP_UP_ANIM,A14
	JRUC	HEC_SET_RECOVER_ANIM
HEC_NO_JUMP
	MOVE	A4,*A8(OTHROWS),W

	MOVI	HELGA_START_SHOOT_ANIM,A14

	CMPI	THRONE_X_ERROR*3/2,A3
	JRGT	HEC_SET_RECOVER_ANIM

	MOVI	HELGA_AWAY_WHEEL_ANIM,A14
HEC_SET_RECOVER_ANIM

	MOVE	A14,*A8(AnimScr),L

	CALLR	DISABLE_HELGA_VECTORS
HEC_DONE
	RETS

**************************************************************************
*								         *
* DISABLE_HELGA_VECTORS							 *
* DISABLE_GUN_VECTOR							 *
*								         *
**************************************************************************

DISABLE_HELGA_VECTORS
	MMTM	SP,A1,A2,A3,A8
	MOVI	HELGA_GROUND_CVECT,A2
	JRUC	DHV_GO
DISABLE_GUN_VECTOR
	MMTM	SP,A1,A2,A3,A8
	MOVI	HELGA_CVECT,A2
DHV_GO
	CALLA	GET_HEAD_PART
	MOVI	HELGA_FX_GUNVECT,A1
	MOVK	4,A3
DHV_LUPE
	MOVE	A1,*A8(OGUNVECT),L
	MOVE	A2,*A8(OCVECT),L
	DEC	A3
	JRZ	DHV_DONE
	MOVE	*A8(OPARTS),A8,L
	JRNZ	DHV_LUPE
DHV_DONE
	MMFM	SP,A1,A2,A3,A8
	RETS

**************************************************************************
*								         *
* ENABLE_HELGA_VECTORS							 *
*								         *
**************************************************************************

ENABLE_HELGA_VECTORS
	MMTM	SP,A1,A2,A3,A8
	CALLA	GET_HEAD_PART
	MOVI	HELGA_GUNVECT,A1
	MOVI	HELGA_CVECT,A2
	MOVK	4,A3
EHV_LUPE
	MOVE	A1,*A8(OGUNVECT),L
	MOVE	A2,*A8(OCVECT),L
	DEC	A3
	JRZ	EHV_DONE
	MOVE	*A8(OPARTS),A8,L
	JRNZ	EHV_LUPE
EHV_DONE
	MMFM	SP,A1,A2,A3,A8
	RETS

**************************************************************************
*								         *
* HELGA GUN VECTOR							 *
*								         *
**************************************************************************

HELGA_FX_GUNVECT
	SOUND1	SND_HELGA_BODY_THUD
	CALLA	BLOODY_BULLET_HIT_OFFSET
	RETS

HELGA_GUNVECT
	SOUND1	SND_HELGA_BODY_THUD

	CALLA	GET_HEAD_PART
;	MOVE	*A8(OYVEL),A14,L
;	JRNZ	HG_DONE

	CALLA	BLOODY_BULLET_HIT_OFFSET

;	MOVE	*A8(AnimScr),A14,L
;	CMPI	HELGA_FLINCH_ANIM,A14
;	JREQ	HG_DONE

	MOVE	*A8(OLASTHITTIME),A1,L
	MOVE	@WAVEIRQS,A14,L
	MOVE	A14,*A8(OLASTHITTIME),L
	SUB	A1,A14
	CMPI	MIN_HIT_TIME,A14
	JRLT	HG_GO				;BR=UNDER MINIMUM TIME
	CLR	A14
	MOVE	A14,*A8(OHITS),L
	JRUC	HG_DONE
HG_GO
	MOVK	HELGA_GUN_HITS,A0
	calla	CURPLYR_ADJ
	move	a0,a1
	MOVI	OHITS,A3 

	MOVE	*A2(PPLASMASHOTS),A14,W
	JRZ	HG_ONE_HIT			;BR=NO BIG GUN
	CALLA	HIT_ENEMY
	JRGE	HG_CHECK			;BR=TRY TO STUN
HG_ONE_HIT
	CALLA	HIT_ENEMY
	JRLT	HG_DONE				;BR=DON'T STUN
HG_CHECK
	MOVE	*A8(AnimFrm),A14,L
	CMPI	HELGA_END_NOGUN_HIT,A14
	JRHS	HG_HIT				;BR=IN RETURN FRAMES
	CMPI	HELGA_START_NOGUN_HIT,A14
	JRHS	HG_DONE				;BR=UPSIDE FRAMES
HG_HIT
	CLR	A14
	MOVE	A14,*A8(OHITS),L

;	CALLA	BLOODY_BULLET_HIT

	CLR	A14
	MOVE	A14,*A8(OYACCEL),W
	MOVE	A14,*A8(OXVEL),L
	MOVE	A14,*A8(OYVEL),L
	MOVE	A14,*A8(OZVEL),L

	CLR	A14
	MOVB	A14,*A8(AnimSlp)
	MOVI	HELGA_FLINCH_ANIM,A14
	MOVE	A14,*A8(AnimFrm),L

	CLR	A4
	MOVE	*A8(OLASTSTUN),A1,L
	MOVE	@WAVEIRQS,A14,L
	MOVE	A14,*A8(OLASTSTUN),L
	SUB	A1,A14
	CMPI	MIN_STUN_TIME,A14
	JRGT	HG_NO_JUMP			;BR=OVER MINIMUM TIME
	MOVE	*A8(OSTUNS),A4,W
	INC	A4
	CMPK	MAX_STUNS,A4
	JRLT	HG_NO_JUMP			;BR=NOT STUNNED ENOUGH
	CLR	A14
	MOVE	A14,*A8(OSTUNS),W
	MOVI	HELGA_JUMP_UP_ANIM,A14
	JRUC	HG_SET_RECOVER_ANIM
HG_NO_JUMP
	MOVE	A4,*A8(OSTUNS),W

	MOVI	HELGA_CENTER_WHEEL_ANIM,A14
HG_SET_RECOVER_ANIM
	MOVE	A14,*A8(AnimScr),L

	CALLR	DISABLE_GUN_VECTOR
HG_DONE
	RETS

**************************************************************************
*								         *
* A_SET_SHOOTTIME							 *
*								         *
**************************************************************************

A_SET_SHOOTTIME
	CALLA	GET_HEAD_PART
	MOVE	@WAVEIRQS,A14,L
	MOVE	A14,*A8(OSHOOTTIME),L
	RETS

**************************************************************************
*								         *
* A_CHECK_SHOOTTIME							 *
*								         *
**************************************************************************

A_CHECK_SHOOTTIME
	CALLA	GET_HEAD_PART

	MOVE	*A8(OZVAL),A0,L
	MOVE	*A8(OXVAL),A1,L

	UTOSX	A0,A1

	CMPI	SCRLFT+SCRWIDTH/6,A1
	JRLT	ACS_OFF
	CMPI	SCRRGT-SCRWIDTH/6,A1
	JRGT	ACS_OFF
	JRUC	ACS_CHECK_SHOOT
ACS_OFF
	CLR	A14
	MOVE	A14,*A8(OSHOOTTIME),L			;FLAG SHOOTTIME
	RETS
ACS_CHECK_SHOOT

	MOVE	*A8(OSHOOTTIME),A0,L
	MOVE	@WAVEIRQS,A14,L
	MOVE	A14,A1
	SUB	A0,A14
	CMPI	MIN_SHOOTTIME,A14
	JRLT	ACS_SHOOT_AGAIN				;BR=STILL SHOOT
	CLR	A14
	MOVE	A14,*A8(OSHOOTTIME),L			;FLAG SHOOTTIME
	MOVI	512,A0
	CALLA	RANDPER
	JRC	ACS_SHOOT_AGAIN				;BR=SHOOT AGAIN
	RETS
ACS_SHOOT_AGAIN
	MOVI	HELGA_SHOOT_ANIM,A14
	MOVE	A14,*A8(AnimFrm),L
	RETS

FINAL_HELGA_INIT
	.byte	 4, 0, 0, 1	;OBJCNT, PRCCNT, IMGPALCNT, PALCNT
	.long	P_HELGA		;IMGPAL
	.word	OID_HELGA,OM_COLL|OM_WPOS	;OID, GLOBAL_OPTIONS
	.LONG	HELGA_CVECT
	.long	0,-0500000H,08000H
*        .long IMG
*        .word OCTRL, OFLAGS, OZOFF
*        .word OPTIONS 
	LWWWW	HL1J_A5, DMAWNZ, M_GCOLL, 0, OM_GUNV|OM_ANIM
	.LONG	HELGA_GUNVECT
	.LONG	FINAL_DROP_ANIM
	LWWWW	HT1J_A5, DMAWNZ, 0, 0, OM_PRVGUNV
	LWWWW	HT1J_A5, DMAWNZ, M_NODISP, 0, OM_PRVGUNV
	LWWWW	HT1J_A5, DMAWNZ, M_NODISP, 0, OM_PRVGUNV

HELGA_THREAT_SHOOT_ANIM
	LWLL	1,1|AMulti|AFunc,A_AnimGo+2,HELGA_START_SHOOT_ANIM
	LWL	1,1|AFunc,A_HELGA_THREAT

FINAL_DROP_ANIM:
	LW	HL1J_A5,1|AMulti
	LW	HT1J_A5,3

	LWL	1,1|AFunc,A_WAIT_TIL_ON_GROUND

	LW	HL1J_A6,1|AMulti
	LWLL	HT1J_A6,5|AFunc,A_SOUND+2,SND_JUMP_LAND

	LW	HL1J_A7,1|AMulti
	LW	HT1J_A7,5

	LW	HL1J_A8,1|AMulti
	LW	HT1J_A8,5

	LW	HH1ST_A4,1|AMulti
	LW	HB1ST_A4,6

	LW	HH1ST_A3,1|AMulti
	LW	HB1ST_A3,7

	LWLWL	HH1ST_A2,1|AMulti|AFunc,A_JUMP_ON_CLR_HFLAG+3,M_INTRO,HELGA_THREAT_SHOOT_ANIM
	LW	HB1ST_A2,8

	LWLWW	HH1ST_A1,1|AMulti|AFunc,A_Set_Rel_Word+2,OHFLAGS,0
	LWLL	HT1ST_A1,1|AMulti|AFunc,A_SOUND+2,SND_BAD_BOY
	LWL	HL1ST_A1,112|AFunc,OBJ_ON

	LWLLW	HH1ST_A2,1|AMulti|AFunc,A_Set_Var_Word+3,GUNS_OFF,0
	LW	HB1ST_A2,1|AMulti
	LWL	1,4|AFunc,OBJ_OFF

HELGA_START_SHOOT_ANIM
	LWL	HH1SH_A1,1|AMulti|AFunc,ENABLE_HELGA_VECTORS
	LWL	HT1SH_A1,1|AMulti|AFunc,A_SET_SHOOTTIME
	LWL	HL1SH_A1,1|AFunc,OBJ_ON

HELGA_SHOOT_ANIM
	LWL	HH1SH_A1,1|AMulti|AFunc,A_HELGA_FIRE_FNC
	LW	HT1SH_A1,1|AMulti
	LW	HL1SH_A1,5

	LW	HH1SH_A2,1|AMulti
	LW	HT1SH_A2,1|AMulti
	LW	HL1SH_A2,6

	LWL	1,1|AFunc,A_CHECK_SHOOTTIME

HELGA_START_WHEEL_ANIM
	LWL	HT3CW_A1,1|AMulti|AFunc,A_START_HELGA_WHEEL
	LW	HL3CW_A1,1|AMulti
	LWL	1,1|AMulti|AFunc,OBJ_OFF
	LWL	1,0|AFunc,OBJ_OFF

HELGA_WHEEL_ANIM
	LW	HT3CW_A2,1|AMulti
	LW	HL3CW_A2,1|AMulti
	LWL	HH3CW_A2,0|AFunc,OBJ_ON

	LW	HT3CW_A3,1|AMulti
	LW	HL3CW_A3,1|AMulti
	LW	HA3CW_A3,0
HELGA_START_NOGUN_HIT				;REMEMBER AnimFrm ONE FRAME AHED
	LW	HT3CW_A4,1|AMulti
	LW	HL3CW_A4,1|AMulti
	LWL	1,0|AFunc,OBJ_OFF

	LW	HT3CW_A5,1|AMulti
	LW	HL3CW_A5,0

	LW	HT3CW_A6,1|AMulti
	LW	HL3CW_A6,1|AMulti
	LWL	HA3CW_A6,1|AMulti|AFunc,OBJ_ON
	LWL	HZ3CW_A6,0|AFunc,OBJ_ON

	LW	HT3CW_A7,1|AMulti
	LW	HL3CW_A7,1|AMulti
	LW	HA3CW_A7,1|AMulti
	LW	HZ3CW_A7,0

	LW	HT3CW_A8,1|AMulti
	LW	HL3CW_A8,1|AMulti
	LW	HA3CW_A8,1|AMulti
	LW	HZ3CW_A8,0

	LW	HT3CW_A9,1|AMulti
	LW	HL3CW_A9,1|AMulti
	LW	HA3CW_A9,1|AMulti
	LW	HZ3CW_A9,0

	LW	HT3CW_A10,1|AMulti
	LW	HL3CW_A10,1|AMulti
	LWL	1,1|AMulti|AFunc,OBJ_OFF
	LWL	1,0|AFunc,OBJ_OFF

	LW	HT3CW_A11,1|AMulti
	LW	HL3CW_A11,1|AMulti
	LWL	HZ3CW_A11,0|AFunc,OBJ_ON

	LWL	HT3CW_A12,1|AMulti|AFunc,A_TOGGLE_HELGA_FLIP
	LW	HL3CW_A12,1|AMulti
	LW	HH3CW_A12,0
HELGA_END_NOGUN_HIT				;REMEMBER AnimFrm ONE FRAME AHED
	LWL	HT3CW_A13,1|AMulti|AFunc,A_WHEEL_CHECK
	LW	HL3CW_A13,1|AMulti
	LWL	1,0|AFunc,OBJ_OFF

	LWL	HT3CW_A1,1|AMulti|AFunc,A_TOGGLE_HELGA_FLIP
	LW	HL3CW_A1,0

	.long	0

HELGA_CENTER_WHEEL_ANIM
	LWL	HT3CW_A1,1|AMulti|AFunc,A_CENTER_HELGA_WHEEL
	LW	HL3CW_A1,1|AMulti
	LWL	1,1|AMulti|AFunc,OBJ_OFF
	LWL	1,0|AFunc,OBJ_OFF

HELGA_AWAY_WHEEL_ANIM
	LWL	HT3CW_A1,1|AMulti|AFunc,A_AWAY_HELGA_WHEEL
	LW	HL3CW_A1,1|AMulti
	LWL	1,1|AMulti|AFunc,OBJ_OFF
	LWL	1,0|AFunc,OBJ_OFF

HELGA_FLINCH_ANIM
;	LW	HT1H_A3,1|AMulti
;	LW	HL1H_A3,1|AMulti
;	LWL	1,1|AMulti|AFunc,OBJ_OFF
;	LWL	1,3|AFunc,OBJ_OFF

	LWLL	HH1H_A2,1|AMulti|AFunc,A_SOUND+2,SND_HELGA_STUN
	LW	HT1H_A2,1|AMulti
	LWL	HL1H_A2,1|AMulti|AFunc,OBJ_ON
	LWL	1,6|AFunc,OBJ_OFF

	LWL	HH1H_A1,1|AMulti|AFunc,A_CHECK_JUMP_UP
	LW	HT1H_A1,1|AMulti
	LW	HL1H_A1,9

	.long	0

HELGA_FLYBACK_ANIM
	LW	HL1DIE_A2,1|AMulti
	LW	HT1DIE_A2,1|AMulti
	LWL	HA1DIE_A2,1|AMulti|AFunc,OBJ_ON
	LWL	HZ1DIE_A2,3|AFunc,OBJ_ON

	LW	HL1DIE_A3,1|AMulti
	LW	HT1DIE_A3,1|AMulti
	LW	HA1DIE_A3,1|AMulti
	LW	HZ1DIE_A3,3

	LW	HL1DIE_A4,1|AMulti
	LW	HT1DIE_A4,1|AMulti
	LW	HA1DIE_A4,1|AMulti
	LW	HZ1DIE_A4,3

	LW	HL1DIE_A5,1|AMulti
	LW	HT1DIE_A5,1|AMulti
	LW	HA1DIE_A5,1|AMulti
	LWL	1,1|AFunc,OBJ_OFF

	LWL	1,1|AFunc,A_WAIT_TIL_ON_GROUND

	LWL	HL1DIE_A13,1|AMulti|AFunc,A_HELGA_BITCH
	LW	HT1DIE_A13,1|AMulti
	LW	HA1DIE_A13,3

	LW	HA1DIE_A10,1|AMulti
	LW	HL1DIE_A10,1|AMulti
	LW	HT1DIE_A10,1|AMulti
	LWL	HZ1DIE_A10,5|AFunc,OBJ_ON

	LW	HA1DIE_A9,1|AMulti
	LW	HZ1DIE_A9,1|AMulti
	LW	HL1DIE_A9,1|AMulti
	LWL	1,7|AFunc,OBJ_OFF

	LW	HA1DIE_A10,1|AMulti
	LW	HL1DIE_A10,1|AMulti
	LW	HT1DIE_A10,1|AMulti
	LWL	HZ1DIE_A10,5|AFunc,OBJ_ON

	LW	HL1DIE_A13,1|AMulti
	LW	HT1DIE_A13,1|AMulti
	LW	HA1DIE_A13,3|AMulti
	LWL	1,3|AFunc,OBJ_OFF

	LW	HH1ST_A4,1|AMulti
	LW	HB1ST_A4,1|AMulti
	LWL	1,6|AFunc,OBJ_OFF

	LW	HH1ST_A3,1|AMulti
	LW	HB1ST_A3,7

	LWL	HH1ST_A2,1|AMulti|AFunc,A_CHECK_JUMP_UP
	LW	HB1ST_A2,8

	.long	0

HELGA_JUMP_UP_ANIM
;	LW	HH1ST_A2,1|AMulti
;	LW	HB1ST_A2,1|AMulti
;	LWL	1,1|AMulti|AFunc,OBJ_OFF
;	LWL	1,8|AFunc,OBJ_OFF
;
;	LW	HH1ST_A3,1|AMulti
;	LW	HB1ST_A3,7

	LW	HH1ST_A3,1|AMulti
	LW	HB1ST_A3,1|AMulti
	LWL	1,1|AMulti|AFunc,OBJ_OFF
	LWL	1,5|AFunc,OBJ_OFF

	LW	HH1ST_A4,1|AMulti
	LW	HB1ST_A4,5

	LW	HL1J_A8,1|AMulti
	LW	HT1J_A8,4

	LWLW	HL1J_A7,1|AMulti|AFunc,A_SET_OYACCEL+1,-04000H
	LW	HT1J_A7,4

	LW	HL1J_A6,1|AMulti
	LW	HT1J_A6,3

	LW	HL1J_A5,1|AMulti
	LW	HT1J_A5,3

	LWL	1,1|AFunc,A_WAIT_TIL_HELGA_OFFSCRN

	LWL	1,1|AFunc,CLR_VEL

	LWL	1,1|AFunc,A_HELGA_JUMP_DOWN





**************************************************************************
*								         *
* 	THRONE_HELGA							 *
* 									 *
* 	Create the Helga that will find the throne and land		 *
* 	in it.								 *
*								         *
**************************************************************************
PROC_THRONE_HELGA
	MOVI	OID_MONDOR,A0
	CALLA	EXIST_OBJ_ALL
	JRZ	PTH_FAIL

	PUSH	A8
	MOVI	THRONE_HELGA_INIT,B0	;Get dat multi-parter
	CALLA	CREATE_ENEMY
	PULL	A9
	JRNZ	PTH_GOT_OBJ		;BR = Success

PTH_FAIL
	SLOOP	5,PROC_THRONE_HELGA	;Try again later

PTH_GOT_OBJ

	MOVE	*A9(OXVAL),A1,L
	MOVE	*A9(OZVAL),A3,L
	SUBK	1,A3
	MOVE	A9,*A8(OTHRONE_OBJ),L

	MOVI	-50,A5
	STOUY	A3,A5
	MOVE	A5,A2

	CALLA	SET_ANIPU

	MOVIM	80000H,*A8(OYVEL),L	;Drop this guy
	MOVIM	5000H,*A8(OYACCEL),W	;Add some Grav

	CALLA	INSERT_OBJ		;Insert this bitch

	DIE

**************************************************************************
*								         *
* 	A_STAY_TIL_IN_THRONE						 *
* 									 *
* 	Stay here til she lands that awesome ass on the throne.		 *
* 									 *
* 	A8 = Ptr to head object						 *
*								         *
**************************************************************************
A_STAY_TIL_IN_THRONE
	MOVE	*A8(OYPOS),A1,W
	MOVE	*A8(OTHRONE_OBJ),A0,L
	MOVE	*A0(OYPOS),A2,W
	MOVE	*A8(OYVEL+16),A14,W
	JRN	ASTIT_STAY
	SUB	A14,A2

	CMP	A2,A1
	JRGE	ASTIT_THERE		;BR = Hit the thrown
ASTIT_STAY
	MOVE	*A8(AnimFrm),A14,L	; otherwise, stay here
	SUBI	50h,A14
	MOVE	A14,*A8(AnimFrm),L
	RETS

ASTIT_THERE
	CLR	A14
	MOVE	A14,*A8(OXVEL),L		;STOP X AND Z MOTION		
	MOVE	A14,*A8(OZVEL),L

	MOVE	*A0(OXVAL),A1,L
	SLL	16,A2
	MOVE	*A0(OZVAL),A3,L
	SUBK	1,A3
	JAUC	SET_ANIPU
	
**************************************************************************
*								         *
* 	A_HELGA_ASS_BOUNCE						 *
* 									 *
* 	Anim func to bounce helga on that ass.				 *
* 									 *
* 	A8 = Ptr to Helga head part					 *
*								         *
**************************************************************************
A_HELGA_ASS_BOUNCE
	SOUND1	SND_JUMP_LAND
	MOVE	*A8(OYVEL),A3,L

	SRA	2,A3
	CMPI	10000H,A3
	JRGE	AHAB_OK
      	CLR	A3
AHAB_OK
	NEG	A3
	MOVE	A3,*A8(OYVEL),L
	JRNZ	AHAB_X

	MOVE	A3,*A8(OYACCEL),W

	MOVI	ANIM_ASS_LAND,A1
	JAUC	SetAnim

AHAB_X
	RETS

**************************************************************************
*								         *
* 	A_STAY_TIL_YVEL_POS						 *
* 									 *
* 	Anim func to stay put until the OYVEL of an object is positive.	 *
* 									 *
* 	A8 = Ptr to head part						 *
*								         *
**************************************************************************
A_STAY_TIL_YVEL_POS
	MOVE	*A8(OYVEL+16),A14,W
	JRN	ASTYP_STAY
	RETS

ASTYP_STAY
	MOVE	*A8(AnimFrm),A14,L	; otherwise, stay here
	SUBI	50h,A14
	MOVE	A14,*A8(AnimFrm),L
	RETS

A_STAY_TIL_ZSCROLL_NONZ
	MOVE	@ZSCROLL,A14,L
	JRZ	ASTYP_STAY
	RETS

A_STAY_TIL_ZSCROLL_ZERO
	MOVE	@ZSCROLL,A14,L
	JRNZ	ASTYP_STAY
	RETS

**************************************************************************
*								         *
* 	A_START_PEDASTAL						 *
* 									 *
* 	Anim func to make the throne pedastal sink into the stage.	 *
*								         *
**************************************************************************
A_START_PEDASTAL
	MOVI	ANIM_SINK_PED,A1
;	MOVI	(OID_UNIV|ID_1)&~MASK_SUPP,A0	;Get the first half
	MOVI	(OID_UNIV|ID_1),A0		;Get the first half
	CALLA	EXIST_OBJ_ALL
	JRZ	ASP_X				;BR = Not found
	CALLA	BG_TO_FG		;Get place holder out of Bgnd
	CALLA	STRT_ANIM
;	MOVI	(OID_UNIV|ID_1)&~MASK_SUPP,A0
	MOVI	(OID_UNIV|ID_1),A0
	CALLA	RESUME_EXIST_OBJ_ALL		;Get the other half
	JRZ	ASP_X
	CALLA	BG_TO_FG		;Get place holder out of Bgnd
	CALLA	STRT_ANIM
ASP_X
	RETS

**************************************************************************
*								         *
* 	START_HELGA							 *
* 									 *
* 	Start the Helga that drops in after Aerosmith has been		 *
* 	pushed off of the stage.					 *
*								         *
**************************************************************************
START_HELGA:
	movi	HELGA_INIT,b0
	calla	MULTIMAKE
	MOVIM	2000h,*a8(OYACCEL),W
	rets


HELGA_INIT
	.byte	4,0,0,1
	.long	P_HELGA
	.word	OID_HELGA,OM_DUMCOLL|OM_WPOS|OM_INSERT
	.long	0h,-500000h,8000h

	.long	HL1J_A5
	.word	DMAWNZ,M_NOSCALE,0,OM_ANIM
	.long	HELGA_DROP_ANIM

	.long	HT1J_A5
	.word	DMAWNZ,M_NOSCALE,0,0

	.long	HT1J_A5
	.word	DMAWNZ,M_NODISP|M_NOSCALE,0,0
		 
	.long	HT1J_A5
	.word	DMAWNZ,M_NODISP|M_NOSCALE,0,0
 

*
*  She drops!
*
HELGA_DROP_ANIM:
	LW	HL1J_A5,1|AMulti
;	LWLL	HT1J_A5,3|AFunc,A_SOUND+2,SND_HELGA_TUNE
	LW	HT1J_A5,3

	LWLW	1,2|AFunc,A_STAY_TIL_WY_GT+1,17h

	LW	HL1J_A6,1|AMulti
	LWLL	HT1J_A6,5|AFunc,A_SOUND+2,SND_JUMP_LAND

	LW	HL1J_A7,1|AMulti
	LW	HT1J_A7,5

	LW	HL1J_A8,1|AMulti
	LW	HT1J_A8,5
*
*  She stands!
*
HELG_STND_ANIM
	LW	HH1ST_A4,1|AMulti
	LW	HB1ST_A4,6

	LW	HH1ST_A3,1|AMulti
	LW	HB1ST_A3,7

	LW	HH1ST_A2,1|AMulti
	LW	HB1ST_A2,8

;	LWLLW	1,1|AFunc,A_Set_Var_Word+3,SCROLL_FLAG,1

	LW	HH1ST_A1,1|AMulti
	LW	HT1ST_A1,1|AMulti
	LWL	HL1ST_A1,8|AFunc,OBJ_ON

*
*  She points!
*
HELG_PT_ANIM
	LWLL	HT1PT_A8,1|AMulti|AFunc,A_SOUND+2,SND_HELGA_TAUNT
	LW	HL1PT_A8,1|AMulti
	LW	HH1PT_A8,1|AMulti
	LWL	HA1PT_A8,6|AFunc,OBJ_ON

	LW	HT1PT_A9,1|AMulti
	LW	HL1PT_A9,1|AMulti
	LW	HH1PT_A9,1|AMulti
	LW	HA1PT_A9,6

	LW	HT1PT_A10,1|AMulti
	LW	HL1PT_A10,1|AMulti
	LW	HH1PT_A10,1|AMulti
	LW	HA1PT_A10,5

	LWLW	1,1|AFunc,A_Set_AnimLoop+1,6

HELGA_PT_LOOP
	LW	HT1PT_A11,1|AMulti
	LW	HL1PT_A11,1|AMulti
	LWL	HA1PT_A11,1|AMulti|AFunc,OBJ_ON
	LWL	1,6|AFunc,OBJ_OFF

	LW	HT1PT_A12,1|AMulti
	LW	HL1PT_A12,1|AMulti
	LWL	1,6|AFunc,OBJ_OFF

	LW	HT1PT_A13,1|AMulti
	LW	HL1PT_A13,1|AMulti
	LWL	HH1PT_A13,6|AFunc,OBJ_ON

	LWLL	HT1PT_A12,1|AMulti|AFunc,A_Anim_DSJ+2,HELGA_PT_LOOP
	LW	HL1PT_A12,1|AMulti
	LWL	1,6|AFunc,OBJ_OFF

	LW	HT1PT_A13,1|AMulti
	LW	HL1PT_A13,1|AMulti
	LWL	HH1PT_A13,6|AFunc,OBJ_ON

	LW	HT1PT_A14,1|AMulti
	LW	HL1PT_A14,1|AMulti
	LW	HH1PT_A14,6

	LWLLW	HT1PT_A15,1|AMulti|AFunc,A_Set_Var_Word+3,SCROLL_FLAG,1
	LW	HL1PT_A15,1|AMulti
	LW	HH1PT_A15,120

	LW	1,120
	LW	1,120

	LWL	1,120|AFunc,DELETE_OBJ

*
* Init table for Helga that lands in the throne and then morphs
*
THRONE_HELGA_INIT
	.byte	4,0,0,1
	.long	P_HLSIT
	.word	OID_HELGA,OM_DUMCOLL

	.long	HELSIT_A1
	.word	DMAWNZ,M_NOSCALE,0,OM_ANIM
	.long	HELGA_THRONE_DROP_ANIM

	.long	HELSIT_T1
	.word	DMAWNZ,M_NOSCALE,0,0

	.long	HELSIT_Z1
	.word	DMAWNZ,M_NOSCALE,0,0
		 
	.long	HELSIT_L1
	.word	DMAWNZ,M_NOSCALE,0,0

**************************************************************************
*								         *
* A_THROW_START								 *
*								         *
**************************************************************************

A_THROW_START
	MOVI	P_HLSIT,A0
	CALLA	CHANGE_PAL_MULTI
	MOVE	*A8(OYVAL),A1,L
	SUBI	96 << 15,A1
	MOVE	A1,A10
	CALLA	SET_ANIPYU
	CALLA	SET_ODAG_MULTI

	MOVE	*A8(OTHRONE_OBJ),A9,L

* A1 = PNT. B X POSITION (32 BITS)					 *
* A2 = PNT. A X POSITION (32 BITS)					 *
* A3 = PNT. B Y POSITION (32 BITS)					 *
* A4 = PNT. A Y POSITION (32 BITS)					 *
* A5 = PNT. B Z POSITION (32 BITS)					 *
* A6 = PNT. A Z POSITION (32 BITS)					 *
* A7 = DURATION(# OF TICKS TO GET FROM A TO B)				 *

	MOVE	*A9(OXVAL),A1,L
	MOVE	*A8(OXVAL),A2,L
	CLR	A3				;DON'T STUFF Y
	CLR	A4
	MOVE	*A9(OZVAL),A5,L
	SUBK	1,A5
	MOVE	*A8(OZVAL),A6,L
	MOVI	HELGA_HANG_TIME,A7

	CALLA	SLINEVEL_3D
	MOVE	A1,*A8(OXVEL),L
	MOVE	A5,*A8(OZVEL),L

	MOVE	*A9(OYVAL),A1,L			
	SUB	A10,A1
	DIVS	A7,A1				;(X - X0) / T

	MOVI	THROW_YACCEL,A14
	MOVE	A14,*A8(OYACCEL),W

	SUBI	(THROW_YACCEL * HELGA_HANG_TIME) >> 1,A1
	
	MOVE	A1,*A8(OYVEL),L			;V0 = (X - X0) / T - 0.5*A*T

	RETS

*
*  She drops into her seat
*

HELGA_THRONE_START_ANIM
	LWL	HELSIT_A1,1|AMulti|AFunc,A_THROW_START
	LW	HELSIT_T1,1|AMulti
	LWL	HELSIT_Z1,1|AMulti|AFunc,OBJ_ON
	LWL	HELSIT_L1,(HELGA_HANG_TIME/2)|AFunc,OBJ_ON

HELGA_THRONE_DROP_ANIM:
	LWL	1,1|AFunc,A_STAY_TIL_IN_THRONE

;	LWLL	1,1|AFunc,A_SOUND+2,SND_HELGA_ASS

ANIM_ASS_BOUNCE
	LWL	HELSIT_T3,1|AMulti|AFunc,A_HELGA_ASS_BOUNCE
	LW	HELSIT_L3,1|AMulti
	LW	HELSIT_Z3,1|AMulti
	LWL	1,1|AFunc,OBJ_OFF

	LWL	1,1|AFunc,A_STAY_TIL_YVEL_POS

	LW	HELSIT_A2,1|AMulti
	LW	HELSIT_T2,1|AMulti
	LW	HELSIT_Z2,1|AMulti
	LWL	HELSIT_L2,1|AFunc,OBJ_ON

	LWL	1,1|AFunc,A_STAY_TIL_IN_THRONE

	LWLL	1,1|AFunc,A_AnimGo+2,ANIM_ASS_BOUNCE
	
ANIM_ASS_LAND
	LW	HELSIT_T5,1|AMulti
	LW	HELSIT_L5,1|AMulti
	LW	HELSIT_Z5,5

	LW	HELSIT_T6,1|AMulti
	LW	HELSIT_A6,1|AMulti
	LW	HELSIT_Z6,1|AMulti
	LWL	HELSIT_L6,5|AFunc,OBJ_ON

	LW	HELSIT_H7,1|AMulti
	LW	HELSIT_T7,1|AMulti
	LW	HELSIT_L7,1|AMulti
	LW	HELSIT_Z7,5

	LWLL	HELSIT_H8,1|AMulti|AFunc,A_SOUND+2,SND_YOU_AINT_SEEN
	LW	HELSIT_T8,1|AMulti
	LW	HELSIT_L8,1|AMulti
	LW	HELSIT_Z8,10

	LWLLW	1,1|AFunc,A_Set_Var_Word+3,SCROLL_FLAG,1

	LWL	1,1|AFunc,A_STAY_TIL_ZSCROLL_NONZ

	LWL	1,1|AFunc,A_STAY_TIL_ZSCROLL_ZERO

	LW	1,30

	LWLLW	1,7|AFunc,A_Set_Var_Word+3,MONDOR_START_FLAG,1

	LWL	1,1|AFunc,A_START_PEDASTAL

	LWL	1,1|AFunc,DELETE_OBJ


ANIM_SINK_PED
	LWLW	1,60|AFunc,A_Set_AnimLoop+1,20
ANIM_PED_LOOP
	LWLW	1,1|AFunc,A_ADD_YPOS+1,4
	LWLL	1,1|AFunc,A_Anim_DSJ+2,ANIM_PED_LOOP

	LWL	1,1|AFunc,DELETE_OBJ

	.END
