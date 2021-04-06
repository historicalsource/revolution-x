 	.MLIB	"GXMACS.LIB"
	.FILE	"GXMONDR2.ASM"
	.TITLE	"<<< REVOLUTION X -- MONDOR THE CARNIVOROUS ROCKER PT.2 >>>"
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
	.INCLUDE	"GXAUDN.H"
	.INCLUDE	"GXMONDR2.TBL"

*
*Symbols to share with the other Mondor module
*

	.DEF FRAG_EXPLOSION, FRAG_GUN_FLY, F_CHUNK
	.DEF A_JEANS_CHUNK, A_RANDOM_MULTI_CHUNK, A_SHIRT_CHUNK
	.DEF FRAG_FINAL_EXPLOSION, FIRE_BALL_INIT, A_SPAWN_PROJECTILE
	.DEF GRENADE_INIT, BLOW_PART, PROC_SKY_FLASH, A_DELETE_MONDOR
	.DEF A_VELOCITY_WATCH, A_MOVE_AROUND, FRAG_EXPLOSION_SMALL
	.DEF TALK_SCRIPTS, FRAG_FINAL_RAIN, INIT_POD_FIRE
	.DEF A_SPAWN_BLOOD, A_RAND_SPAWN_BLOOD, SPAWN_BLOOD, MONDOR_PROC
	.DEF A_ARM_FIRE_FNC, A_INIT_BLOOD_DROP, PROC_TEMP_ENDING
	.DEF A_CHUNK_ONSCREEN, A_CHECK_MISSLE_SCREEN_HIT
	.DEF PROJECTILE_ROCKET_COLL, PART_EXPLOSION, F_CHUNK_RAIN
	.DEF ANIM_JOSH_MORPH, AXE_INIT, NSPEAR_INIT, F_BLOOD_GLOB
	.DEF	NSTAR_INIT, MCHUNK_COLL, F_GUN_CHUNK, MONDOR_START_FLAG
	.DEF	EXPLO_BLOW_INIT
	.DEF	BUS_EXPLOSION,BUS_EXPLOSION_SMALL, FRAG_EXPLOSION_ONE

* SYMBOLS IN HERE FOR GXHELI.ASM
	.DEF	LILPLAZ1, LILPLAZ2, LILPLAZ3
	.DEF	C_FIREBALL, CHECK_SCREEN_HIT, A_FB_COLLS_ON
	.DEF	SND_FB_HIT_SCRN, SND_FIRE_HISS

***** from GX.ASM

	.REF WAVE_END, XSCROLL, WAVE_END_IMM

***** from GXRAM.ASM

	.REF IRQSKYE, IRQGNDE, GROUNDCOLOR, SKYCOLOR, WAVETIME
	.REF P1DATA, BUYIN_SECS, GUNS_OFF, BONUS_DIRECTION, BASE_HIT
	.REF	NUM_SPEARS, NUM_NSTARS, LAB_RAT, VIOLENCE_LEVEL

***** from GXAFUNC.ASM

	.REF A_INIT_AnimSLP, SetAnim, A_SOUND, A_SOUNDZ, A_TAB_SOUNDZ
	.REF A_Set_AnimLoop, A_Anim_DSJ, A_Set_Var_Word, A_Set_Rel_Long
	.REF A_Set_Rel_Word_Head, A_PreFrag_Center, A_CREATEP

***** from GXSND.ASM

	.REF ONESND_Z, ONESND, SND_BGND1_OFF, SND_BGND2_OFF

***** from GXD.ASM

	.REF SETOFFPU, EASYMAKE, XBASE, YBASE, ZBASE, YHALF, OBJ_UNIV_TO_SCRN
	.REF SETANIPU, GETHEADPART, GET_SHAD_MULTI, SET_SCRN_POS, YSCROLL
	.REF DELETE_OBJ_PROC, SET_SCALE_MANUAL, SET_ANIPU, SET_SCALEM
	.REF	WORLD_GRNDOFF

***** from GXUTIL.ASM

	.REF SLINEVEL_LOAD_3D

***** from GXPLAYER.ASM

	.REF CK_PLAYER_HIT, GET_PLAYER_EXTENTS

***** from GXENEMY.ASM

	.REF INSERT_ENEMY, CREATE_ENEMY, EGUN_FLASH_MULTI, DELETE_ENEMY

***** from GXPALL.ASM
	
	.REF A_CHANGE_PAL

***** from GXMONDOR.ASM

	.REF MONDOR_INIT, NUM_HEAD, MAKE_MONDOR_SCREAM, MONDOR_TOTAL
	.REF ANIM_MORPH_FINISH, C_GREEN_STRTANIM
	.REF MONDOR_MORPH_FLAG, A_GREEN_IF_NEC

***** from GXDESK.ASM
	.REF F_EXPLOSION_OUT,F_EXPLOSION_OUT_2X

***** from GXUNIJAP.ASM
	.REF	OFFICE_DAMAGE_FLAG

***** from GXMISC.ASM
	.REF	CYCLE16

***** from GXBLOOD.ASM
	.REF	P_BLOODGR
*
* More Mondor RAM
*

	.BSS	MONDOR_START_FLAG,16
	.BSS	UNUSED_WORD,16

	.TEXT

**************************************************************************
*								         *
* MONDOR_PROC	- PROCESS TO CREATE MONDOR				 *
* 									 *
* PASS:									 *
* A8  = INITIAL SLEEP BEFORE CREATION					 *
* A9  = UNIV X								 *
* A10 = UNIV Y								 *
* A11 = UNIV Z								 *
*								         *
**************************************************************************
MONDOR_PROC
	SLEEPR	A8

	MOVI	OID_MONDOR,A0
	CALLA	GET_ENEMY_COUNT
	CMPK	1,A0
	JAHS	SUCIDE

	MOVI	MONDOR_INIT,B0		;ALLOCATE OBJECT
	CALLA	CREATE_ENEMY
	JAZ	SUCIDE			;NOTHING CLEAN, RIGHT.

	CLR	A14
	MOVE	A14,@MONDOR_TOTAL,W	;Clear the total destruction flag
	MOVE	A14,@MONDOR_MORPH_FLAG,W ;Clear
	MOVE	A14,@MONDOR_START_FLAG,W	;Clear the starting flag

	MOVKM	1,@OFFICE_DAMAGE_FLAG,W

	MMTM	SP,A0,A1,A7,A8,A9,A10,A11

	MOVI	FHEDcc1,A8
	MOVI	57,A9
	MOVI	63,A10
	MOVK	3,A11
	MOVI	PID_DAMCC,A1
	MOVI	CYCLE16,A7
	CALLA	GETPRC
	MOVI	FHEDcc2,A8
	CALLA	GETPRC
	MOVI	FHEDcc3,A8
	CALLA	GETPRC

	MMFM	SP,A0,A1,A7,A8,A9,A10,A11

	MOVE	A9,A1
	MOVE	A10,A2

	MOVE	A11,A3

	CALLA	SET_ANIPU

;	MOVI	8000H,A11
;	UNIVZ	A11
;
;	MOVI	[-50,200],A1
;	CALLA	SET_SCRN_POS		;AND PUT THE GUY THERE
;
;	MOVIM	80000H,*A8(OYVEL),L	;Blow him up and outta here

	CALLA	INSERT_ENEMY		;INSERT AND COUNT ENEMY

;	CALLA	GET_SHAD_MULTI		;Setup his shadow

*
*We will hang here and motor him around
*
	MOVE	A13,*A8(OPLINK),L

	CLRM	@BUYIN_SECS,W		;Clear any held over buyin seconds

	MOVE	@WAVETIME,A14,L
	MOVE	A14,*A13(PDATA),L	;Save the create time

	MOVI	NUM_HEAD,A1
	CALLA	FINDPART
	MOVE	A0,*A13(PDATA+20H),L	;Save a pointer to the head

	MOVK	20,A10			;Update accelerators every x ticks

MONDOR_WATCH_LOOP
	DEC	A10
	JRGT	MONDOR_EVERY_TICK
	MOVK	20,A10

	MOVE	@WAVETIME,A14,L
	MOVE	*A13(PDATA),A1,L
	SUB	A14,A1

	SRA	3,A1
	
	ADDI	900,A1

	CMPI	100,A1
	JRGE	MWL_FB_PERC_OK

	MOVI	100,A1
MWL_FB_PERC_OK
	MOVE	*A13(PDATA+20H),A0,L

	MOVE	A1,*A0(OFB_PERC),W

*
*Shit to do every tick. Don't trash A10.
*
MONDOR_EVERY_TICK
	MOVE	@BUYIN_SECS,A14,W	;Did any buy-ins occur?
	JRZ	MET_HEAD_0		;BR = No

	CLR	A14
	MOVB	A14,*A8(OPROJ_HIT)	;Clear any remaining hit checkers
	MOVE	A14,@BUYIN_SECS,W	;Don't need these 'til next time

	MOVI	NUM_HEAD,A1
	CALLA	FINDPART
	MOVIB	TNUM_MORE,*A0(OTALK_FLAG) ;Make him say, "Back for more, eh?"

MET_HEAD_0
	MOVE	A8,A0
;Stuff for head part only
	MOVB	*A0(OCLRNOSETZVEL),A14	;Clear the NOSET_ZVEL flag?
	JRZ	MET_HEAD_1		;BR = Not timing currently
	DEC	A14			;Down a tick
	MOVB	A14,*A0(OCLRNOSETZVEL)	;Save it
	JRNZ	MET_HEAD_1		;BR = Didn't hit 0 yet
	MOVB	A14,*A0(ONOSET_ZVEL)	;Clear dat flag
MET_HEAD_1
	MOVB	*A0(OXBURN),A14		;Clear the X acceleration?
	JRZ	MET_HEAD_2		;BR = Not timing currently
	DEC	A14			;Down a tick
	MOVB	A14,*A0(OXBURN)		;Save it
	JRNZ	MET_HEAD_2		;BR = Didn't hit 0 yet
	MOVE	A14,*A0(OXACCEL),W	;Clear that acceleration
MET_HEAD_2
	MOVB	*A0(OYBURN),A14		;Clear the Y acceleration?
	JRZ	MET_HEAD_3		;BR = Not timing currently
	DEC	A14			;Down a tick
	MOVB	A14,*A0(OYBURN)		;Save it
	JRNZ	MET_HEAD_3		;BR = Didn't hit 0 yet
	MOVE	A14,*A0(OYACCEL),W	;Clear that acceleration
MET_HEAD_3
	MOVB	*A0(OZBURN),A14		;Clear the Z acceleration?
	JRZ	MET_HEAD_4		;BR = Not timing currently
	DEC	A14			;Down a tick
	MOVB	A14,*A0(OZBURN)		;Save it
	JRNZ	MET_HEAD_4		;BR = Didn't hit 0 yet
	MOVE	A14,*A0(OZACCEL),W	;Clear that acceleration
MET_HEAD_4
	MOVB	*A0(OCLRCENTER),A14	;Clear the Center flag?
	JRZ	MET_HEAD_5		;BR = Not timing currently
	DEC	A14			;Down a tick
	MOVB	A14,*A0(OCLRCENTER)	;Save it
	JRNZ	MET_HEAD_5		;BR = Didn't hit 0 yet
	MOVE	A14,*A0(OCENTER_FLAG),W	;Clear that flag
MET_HEAD_5
	MOVE	*A0(OTALK_WAIT),A14,W	;Are we waiting to talk again?
	JRZ	MET_HEAD_6		;BR = No
	DEC	A14			;Decrement the wait timer
	MOVE	A14,*A0(OTALK_WAIT),W
MET_HEAD_6
	MOVB	*A0(OCLRFDAM),A14	;Clear the FDAM_GOING flag?
	JRZ	MET_HEAD_7		;BR = Not timing currently
	DEC	A14			;Down a tick
	MOVB	A14,*A0(OCLRFDAM)	;Save it
	JRNZ	MET_HEAD_7		;BR = Didn't hit 0 yet
	MOVB	A14,*A0(OFDAM_GOING)	;Clear that flag
MET_HEAD_7
	MOVB	*A0(OPROJ_CK_TIME),A14	;Check for a projectile hit?
	JRZ	MET_HEAD_7a		;BR = Not timing currently
	DEC	A14			;Down one
	MOVB	A14,*A0(OPROJ_CK_TIME)	;Save it
	JRNZ	MET_HEAD_8		;BR = Not time to check yet
	MOVB	*A0(OPROJ_HIT),A14	;Did any projectiles score a hit?
	JRZ	MET_HEAD_8		;BR = No
	PUSH	A0
	MOVI	NUM_HEAD,A1
	CALLA	FINDPART
	MOVE	A0,A6
	MOVK	NUM_TAUNTS,A0		;Do a little taunting
	CALLA	RAND0
	SLL	3,A0
	ADDI	TAUNT_TABLE,A0
	MOVB	*A0,A0
	MOVB	A0,*A6(OTALK_FLAG)
	PULLQ	A0
	CLR	A14
MET_HEAD_7a
	MOVB	A14,*A0(OPROJ_HIT)
MET_HEAD_8
	MOVE	*A0(OARM_WAIT),A14,W	;Are we waiting to do another arm action?
	JRZ	MET_HEAD_9		;BR = No
	DEC	A14			;Decrement the wait timer
	MOVE	A14,*A0(OARM_WAIT),W
MET_HEAD_9
	MOVB	*A0(OARMS_GONE),A14
	CMPK	2,A14			;Are both his arms missing?
	JRLO	MET_HEAD_10		;BR = No
	INCM	*A0(ONOARM_TIME),W
MET_HEAD_10

;Check all parts for un-tick
MET_ALL_PARTS
	MOVK	NUM_MONDOR_PARTS,A6	;Double check number 'cause of gun flashes
	CLR	A5			;Offscreen counter

MET_TICK_LOOP
	MOVB	*A0(OFLASHTIME),A14	;Is this part flashing?
	JRZ	MET_FLASH_NEXT		;BR = No
	DEC	A14			;Decrement the flash time
	MOVB	A14,*A0(OFLASHTIME)	;Stuff it back for future
	JRNZ	MET_FLASH_NEXT		;BR = Not time to unflash
	MOVB	A14,*A0(O_BEING_DAMAGED) ;No longer being damaged
	CALLA	OBJWNZ			;Unflash
MET_FLASH_NEXT
	MOVB	*A0(OCLRROCKETHIT),A14	;Do we need to clear this part?
	JRZ	MET_ROCKHIT_NEXT	;BR = No
	DEC	A14			;Decrement the clear time
	MOVB	A14,*A0(OCLRROCKETHIT)	;Stuff it back for future
	JRNZ	MET_ROCKHIT_NEXT	;BR = Not time to clear
	MOVB	A14,*A0(OROCKETHIT)	;No longer being hit by a rocket
MET_ROCKHIT_NEXT
	MOVB	*A0(OFLAGS),A14
	JRNN	MET_OFFSCREEN_NEXT
	INC	A5			;Click another part offscreen
MET_OFFSCREEN_NEXT
	MOVE	*A0(OPARTS),A0,L	;Get the next part
	JRZ	MET_SLEEP		;BR = We've lost parts somehow?
	DSJ	A6,MET_TICK_LOOP

MET_SLEEP
	CLR	A4			;Assume onscreen
	CMPK	NUM_MONDOR_PARTS,A5	;Are all of the parts offscreen?
	JRLO	MET_SOME_ONSCREEN	;BR = No	
	MOVE	*A8(OFFSCRN_TIME),A4,W
	INC	A4			;Click another tick offscreen
MET_SOME_ONSCREEN
	MOVE	A4,*A8(OFFSCRN_TIME),W

	SLOOP	1,MONDOR_WATCH_LOOP	;Here we wait for shit to happen

NUM_TAUNTS	.EQU	3

TAUNT_TABLE
	.BYTE	TNUM_TAKE, TNUM_BOOM, TNUM_LAUGH
	.EVEN

SND_SWEET_EMOTION
	.WORD	0F0FDH,1,0801FH,0		;Sweet emotion direct start

**************************************************************************
*								         *
* 	PROC_TEMP_ENDING						 *
* 									 *
* 	Temporary ending for Mondor					 *
*								         *
**************************************************************************
PROC_TEMP_ENDING
	SLEEP	350		;Wait for the end of the rain

	SOUND1	SND_SWEET_EMOTION

	AUDIT	AUDJAEND

	MOVKM	3,@BONUS_DIRECTION,W

	JAUC	WAVE_END_IMM

	DIE


**************************************************************************
*								         *
* 	A_DELETE_MONDOR							 *
* 									 *
* 	Anim Func to delete the whole Mondor multi-parter, 		 *
* 	no matter what part is calling.					 *
* 									 *
* 	A8 = Ptr to any part						 *
*								         *
**************************************************************************
A_DELETE_MONDOR
	CALLA	GET_HEAD_PART
	SOUND1	SND_BGND1_OFF		;Kill the thruster sounds
	SOUND1	SND_BGND2_OFF
	JAUC	DELETE_ENEMY		;Now rid yourself of Mondor

**************************************************************************
*								         *
* 	A_DELETE_MULTI							 *
* 									 *
* 	Anim Func to delete the whole multi-parter, no matter what	 *
* 	part is calling.						 *
* 									 *
* 	A8 = Ptr to any part						 *
*								         *
**************************************************************************
A_DELETE_MULTI
	CALLA	GET_HEAD_PART
	JAUC	DELETE_OBJ

**************************************************************************
*								         *
* 	A_HEAD_OBJOFF							 *
* 									 *
* 	Anim Func to turn just the head object of a multi-parter off.	 *
* 									 *
* 	A8 = Ptr to any part						 *
*								         *
**************************************************************************
A_HEAD_OBJOFF
	CALLA	GET_HEAD_PART
	JAUC	OBJ_OFF

**************************************************************************
*								         *
* 	A_VELOCITY_WATCH						 *
* 									 *
* 	Anim Func to watch the Mondor craft accelerations and		 *
* 	do boundry checks.						 *
* 									 *
* 	A8 = Ptr to any Mondor part.					 *
*								         *
**************************************************************************
A_VELOCITY_WATCH
	CALLA	GET_HEAD_PART		;First things first

	MOVE	A8,A14
	ADDI	OXVAL,A14
	MMFM	A14,A0,A1,A3	;LOAD A3:OXPOS, A1:OYPOS, A0:OZPOS

	MOVI	XBASE,A14
	MMFM	A14,A2,A4,A5	;LOAD A5:XBASE, A4:YBASE, A2:ZBASE

	sub	A5,A3	       	;Universe to World X  
	add	A4,A1	       	;Universe to World Y  
	sub	A2,A0		;Universe to World Z

	MOVE	A8,A14
	ADDI	OZVEL,A14
	MMFM	A14,A4,A5,A6	;LOAD A6:OZVEL, A5:OXVEL, A4:OYVEL

	CLR	A2		;Use this to clear whatever we need to clear

*Do Z boundry check
	MOVB	*A8(OCENTER_FLAG),A14	;Time to center?
	JRNZ	AVW_STOP_AT_CENTER

	CMPI	MONDOR_ZMAX,A0		;Did we go too far back?
	JRGE	AVW_HIT_ZMAX		;BR = Yes

	CMPI	MONDOR_ZMIN,A0		;Did we come too far forward?
	JRGT	AVW_NO_Z_VIOLATION	;BR = No, no violations in Z

AVW_HIT_ZMIN
	MOVE	*A8(OZACCEL),A7,W
;	JRGE	AVW_HZMIN_1
	JREQ	AVW_HZMIN_1
	JRGT	AVW_ADD_Z
	CLR	A7
	MOVE	A2,*A8(OZACCEL),W
AVW_HZMIN_1
	MOVE	A6,A6
	JRGE	AVW_ADD_Z
;	MOVE	A2,*A8(OZVEL),L
	SRA	SLED_ZBRAKE_SRA,A6
	JRZ	AVW_CLEARZ
	ABS	A6
	MOVI	SLED_ZBRAKE,A7
	MOVE	A7,*A8(OZACCEL),W
	MOVB	A6,*A8(OZBURN)

	JRUC	AVW_ADD_Z

AVW_HIT_ZMAX
	MOVE	*A8(OZACCEL),A7,W
;	JRLE	AVW_HZMAX_1
	JREQ	AVW_HZMAX_1
	JRLT	AVW_ADD_Z
	CLR	A7
	MOVE	A2,*A8(OZACCEL),W
AVW_HZMAX_1
	MOVE	A6,A6
	JRLE	AVW_ADD_Z
;	MOVE	A2,*A8(OZVEL),L
	SRA	SLED_ZBRAKE_SRA,A6
	JRZ	AVW_CLEARZ
	ABS	A6
	MOVI	-SLED_ZBRAKE,A7
	MOVE	A7,*A8(OZACCEL),W
	MOVB	A6,*A8(OZBURN)
	JRUC	AVW_ADD_Z

AVW_CLEARZ
	MOVE	A2,*A8(OZVEL),L
	JRUC	AVW_ADD_Z

AVW_NO_Z_VIOLATION
	MOVE	*A8(OZACCEL),A7,W

AVW_ADD_Z
	ADDRM	A7,*A8(OZVEL),L
	

*Do X boundry check

	SRA	16,A3			;Easier to do the integer

	CMPI	MONDOR_XMAX,A3		;Did we go too far to the right?
	JRGE	AVW_HIT_XMAX		;BR = Yes

	CMPI	MONDOR_XMIN,A3		;Did we go too far to the left?
	JRGT	AVW_NO_X_VIOLATION	;BR = No, no violations in X

AVW_HIT_XMIN
	MOVE	*A8(OXACCEL),A7,W
;	JRGE	AVW_HXMIN_1
	JREQ	AVW_HXMIN_1
	JRGT	AVW_ADD_X
	CLR	A7
	MOVE	A2,*A8(OXACCEL),W
AVW_HXMIN_1
	MOVE	A5,A5
	JRGE	AVW_ADD_X
;	MOVE	A2,*A8(OXVEL),L
	SRA	SLED_XYBRAKE_SRA,A5
	JRZ	AVW_CLEARX
	ABS	A5
	MOVI	SLED_XYBRAKE,A7
	MOVE	A7,*A8(OXACCEL),W
	MOVB	A5,*A8(OXBURN)

	JRUC	AVW_ADD_X

AVW_HIT_XMAX
	MOVE	*A8(OXACCEL),A7,W
;	JRLE	AVW_HXMAX_1
	JREQ	AVW_HXMAX_1
	JRLT	AVW_ADD_X
	CLR	A7
	MOVE	A2,*A8(OXACCEL),W
AVW_HXMAX_1
	MOVE	A5,A5
	JRLE	AVW_ADD_X
;	MOVE	A2,*A8(OXVEL),L
	SRA	SLED_XYBRAKE_SRA,A5
	JRZ	AVW_CLEARX
	ABS	A5
	MOVI	-SLED_XYBRAKE,A7
	MOVE	A7,*A8(OXACCEL),W
	MOVB	A5,*A8(OXBURN)

	JRUC	AVW_ADD_X

AVW_CLEARX
	MOVE	A2,*A8(OXVEL),L
	JRUC	AVW_ADD_X

AVW_NO_X_VIOLATION
	MOVE	*A8(OXACCEL),A7,W

AVW_ADD_X
	ADDRM	A7,*A8(OXVEL),L

*Do Y boundry check

	SRA	16,A1

	CMPI	MONDOR_YMAX,A1		;Did we go too far down?
	JRGE	AVW_HIT_YMAX		;BR = Yes

	CMPI	MONDOR_YMIN,A1		;Did we go too far up?
	JRGT	AVW_DONE		;BR = No, no violations in Y

	MOVE	*A8(OYACCEL),A7,W
;	JRGE	AVW_HYMIN_1
	JREQ	AVW_HYMIN_1
	JRGT	AVW_DONE
	MOVE	A2,*A8(OYACCEL),W
AVW_HYMIN_1
	MOVE	A4,A4
	JRGE	AVW_DONE

	JRUC	AVW_YREFLECT
;	MOVE	A2,*A8(OYVEL),L
	SRA	SLED_XYBRAKE_SRA,A4
	JRZ	AVW_CLEARY
	ABS	A4
	INC	A4
	MOVIM	SLED_XYBRAKE,*A8(OYACCEL),W
	MOVB	A4,*A8(OYBURN)

	JRUC	AVW_DONE

AVW_HIT_YMAX
	MOVE	*A8(OYACCEL),A7,W
;	JRLE	AVW_HYMAX_1
	JREQ	AVW_HYMAX_1
	JRLT	AVW_DONE
	MOVE	A2,*A8(OYACCEL),W
AVW_HYMAX_1
	MOVE	A4,A4
	JRLE	AVW_DONE
AVW_YREFLECT
	NEG	A4
	SRA	1,A4
	MOVE	A4,*A8(OYVEL),L
	JRUC	AVW_DONE

AVW_CLEARY
	MOVE	A2,*A8(OYVEL),L

AVW_DONE

AVW_X
	RETS

*
*Come here when you want a no nonsense stop at the center of
*the screen.
*A2 = 0 for clearing
*
AVW_STOP_AT_CENTER
*Do Z boundry check
	CMPI	MONDOR_ZMAX_C,A0	;Did we go too far back?
	JRGE	AVW_SC_HIT_ZMAX		;BR = Yes

	CMPI	MONDOR_ZMIN_C,A0	;Did we come too far forward?
	JRGT	AVW_SC_NO_Z_VIOLATION	;BR = No, no violations in Z

*Object is less than Z boundry
AVW_SC_HIT_ZMIN
	MOVE	*A8(OZVEL),A7,L		;Are we moving towards the boundry?
	JRGE	AVW_SC_NO_Z_VIOLATION	;BR = Yes, so let it go
	JRUC	AVW_SC_CLEARZ

AVW_SC_HIT_ZMAX
	MOVE	*A8(OZVEL),A7,L
	JRLE	AVW_SC_NO_Z_VIOLATION
AVW_SC_CLEARZ
	MOVE	A2,*A8(OZVEL),L
AVW_SC_NO_Z_VIOLATION

*Do X boundry check

	SRA	16,A3			;Easier to do the integer

	CMPI	MONDOR_XMAX_C,A3	;Did we go too far to the right?
	JRGE	AVW_SC_HIT_XMAX		;BR = Yes

	CMPI	MONDOR_XMIN_C,A3	;Did we go too far to the left?
	JRGT	AVW_SC_NO_X_VIOLATION	;BR = No, no violations in X

*Object is less than X boundry
	MOVE	*A8(OXVEL),A7,L		;Are we moving towards the boundry
	JRGE	AVW_SC_NO_X_VIOLATION	;BR = Yes, so let it get there
	JRUC	AVW_SC_CLEARX		;Otherwise, stop it

*Object is greater than X boundry
AVW_SC_HIT_XMAX
	MOVE	*A8(OXVEL),A7,L		;Are we moving towards the boundry
	JRLE	AVW_SC_NO_X_VIOLATION	;BR = Yes, so let it get there
AVW_SC_CLEARX
	MOVE	A2,*A8(OXVEL),L
AVW_SC_NO_X_VIOLATION

*Do Y boundry check

	SRA	16,A1

	CMPI	MONDOR_YMAX_C,A1	;Did we go too far down?
	JRGE	AVW_SC_HIT_YMAX		;BR = Yes

	CMPI	MONDOR_YMIN_C,A1	;Did we go too far up?
	JRGT	AVW_SC_NO_Y_VIOLATION	;BR = No, no violations in Y

*Object is less than Y boundry
	MOVE	*A8(OYVEL),A7,L		;Are we moving towards the boundry
	JRGE	AVW_SC_NO_Y_VIOLATION	;BR = Yes, so let it get there
	JRUC	AVW_SC_CLEARY		;Otherwise, stop it

*Object is greater than Y boundry
AVW_SC_HIT_YMAX
	MOVE	*A8(OYVEL),A7,L		;Are we moving towards the boundry
	JRLE	AVW_SC_NO_Y_VIOLATION	;BR = Yes, so let it get there
AVW_SC_CLEARY
	MOVE	A2,*A8(OYVEL),L
AVW_SC_NO_Y_VIOLATION

	RETS

**************************************************************************
*								         *
* 	A_MOVE_AROUND							 *
* 									 *
* 	Anim Func to deal with movin' this crate around.		 *
*								         *
**************************************************************************
A_MOVE_AROUND
;	RETS
	CALLA	GET_HEAD_PART	;Velocity only works on the head

;	MOVB	*A8(OCENTER_FLAG),A14	;Time to center?
;	MOVE	A14,B1
;	JRNZ	AMA_NEXT_MOVE

	MOVE	*A8(OFFSCRN_TIME),A14,W
	CMPI	60,A14		    	;Has he been offscreen awhile?
	JRLT	AMA_ONSCREEN		;BR = No
*Mondor is way offscreen, time to scare the player
	MOVB	*A8(OFDAM_GOING),A14	;Is major damage going?
	JRNE	AMA_ONSCREEN		;BR = Yes, no scaring

	MOVK	1,A3	       		;Scream direction
	MOVI	SND_KAMIKAZE,A4		;Scream sound
	MOVI	75,A5			;Scream duration
	MOVK	1,A6			;Scream severity
	CALLA	MAKE_MONDOR_SCREAM	;Kamikaze

	MOVE	@ZBASE,A3,L
	MOVI	200,A1
	STOUY	A3,A1
	MOVE	A1,A2

 	MOVE	@XBASE,A1,L

;	MOVE	@YBASE,A2,L
;	MOVE	@WORLD_GRNDOFF,A14,L
;	SUB	A14,A2

	CALLA	SET_ANIPU

	MOVE	A8,A14
	ADDI	OXVAL,A14
	MMFM	A14,A4,A5,A6	;LOAD A6:OXPOS, A5:OYPOS, A4:OZPOS

	MOVI	XBASE,A14
	MMFM	A14,A1,A2,A3	;LOAD A3:XBASE, A2:YBASE, A1:ZBASE

	SUB	A3,A6	       	;Universe to World X 
	ADD	A2,A5	       	;Universe to World Y  
	SUB	A1,A4		;Universe to World Z

	MOVI	10000H,A11
	CLR	A9
	CLR	A7
	MOVI	80,A10

	MOVIM	-720,*A8(OFFSCRN_TIME),W	;This gives us time to get back
	
	JRUC	AMA_THRUST

AMA_ONSCREEN
	MOVB	*A8(OMOVE_TIMER),A14
	JRZ	AMA_NEXT_MOVE
	DEC	A14
	MOVB	A14,*A8(OMOVE_TIMER)
	JRNZ	AMA_X

AMA_NEXT_MOVE
	MOVE	A8,A14
	ADDI	OXVAL,A14
	MMFM	A14,A4,A5,A6	;LOAD A6:OXPOS, A5:OYPOS, A4:OZPOS

	MOVI	XBASE,A14
	MMFM	A14,A1,A2,A3	;LOAD A3:XBASE, A2:YBASE, A1:ZBASE

	SUB	A3,A6	       	;Universe to World X 
	ADD	A2,A5	       	;Universe to World Y  
	SUB	A1,A4		;Universe to World Z

	CLR	B0		;This is the emergency register for Z vel

	MOVB	*A8(OCENTER_FLAG),A14	;Time to center?
	JRNZ	AMA_CENTER_NOW		;BR = Yes

	CMPI	MONDOR_ZMAX-100H,A4	;Did he get put waydafucbac?
	JRLT	AMA_NO_EMERGENCY_Z	;BR = No, then don't call 911

	MOVB	*A8(OSPITTING_FIRE),A14
	JRNZ	AMA_NO_EMERGENCY_Z

	MOVB	*A8(OTHROWING_BOMB),A14
	JRNZ	AMA_NO_EMERGENCY_Z

	MOVKB	1,*A8(OSHAKE_FIST)

	INC	B0			;Sound the alarm
	MOVI	8000h,A0		;Get Mondor up front now!
	MOVI	6000H,A1
	CALLA	RANGERND
	MOVE	A0,A11

	JRUC	AMA_SELECT_X

AMA_NO_EMERGENCY_Z
	CLRB	*A8(OSHAKE_FIST)

	CMPI	MONDOR_ZMIN,A4
	JRGT	AMA_FULL_Z
AMA_BACK_UP_Z
	MOVI	MONDOR_ZMIN+4000H,A1
	JRUC	AMA_RAND_Z
AMA_FULL_Z
	MOVI	MONDOR_ZMIN,A1
AMA_RAND_Z
	MOVI	10000h,A0
	CALLA	RANGERND
	MOVE	A0,A11			;Random Z

AMA_SELECT_X
	MOVB	*A8(OARMS_GONE),A14
	CMPK	2,A14			;Are both his arms missing?
	JRLO	AMA_FULL_X		;BR = No, do normal targeting

	MOVI	40,A0
	MOVK	10,A1
	CALLA	RANGERND		;Random Duration, end of battle
	MOVE	A0,A10

AMA_FULL_X
*First select duration.  This is during normal operation
	MOVI	120,A0
	MOVK	20,A1
	CALLA	RANGERND		;Random Duration
	MOVE	A0,A10

	MOVI	MONDOR_XMAX,A0
	MOVI	MONDOR_XMIN,A1
AMA_DO_RAND_X
	CALLA	RANGERND
	MOVE	A0,A9			;Random X
	SLL	16,A9

	MOVI	MONDOR_YMAX,A0
	MOVI	MONDOR_YMIN,A1
	CALLA	RANGERND
	MOVE	A0,A7			;Random Y
	SLL	16,A7

*
*World target points selected, now get us there
*A4 = World Z, A5 = World Y, A6 = World X
*A11 = Target world Z, A9 = Target world X, A7 = Target world Y
*A10 = Duration
*
AMA_THRUST
	MOVE	B0,B0
	JRNZ	AMA_SETZ

	MOVB	*A8(ONOSET_ZVEL),A14	;Can I set the ZVEL?
	JRNZ	AMA_SKIPZ		;BR = No

AMA_SETZ
	SUB	A4,A11		;Get the Z distance
	DIVS	A10,A11		;Dis'll give us the Z velocity
	MOVI	SLED_ZACCEL,A4
	SRA	SLED_ZACCEL_SRA,A11
	JRNN	AMA_ZPLUS
	NEG	A4
	JRUC	AMA_STUFFZ
AMA_ZPLUS
	JRZ	AMA_SKIPZ
AMA_STUFFZ
	ABS	A11
	MOVB	A11,*A8(OZBURN)
	MOVE	A4,*A8(OZACCEL),W

AMA_SKIPZ
	SUB	A6,A9		;Get the X distance
	DIVS	A10,A9		;Dis'll give us the X velocity
	MOVI	SLED_XYACCEL,A4
	SRA	SLED_XYACCEL_SRA,A9
	JRNN	AMA_XPLUS
	NEG	A4
	JRUC	AMA_STUFFX
AMA_XPLUS
	JRZ	AMA_SKIPX
AMA_STUFFX
	ABS	A9
	MOVB	A9,*A8(OXBURN)
	MOVE	A4,*A8(OXACCEL),W

AMA_SKIPX	
	SUB	A5,A7		;Get the Y distance
	DIVS	A10,A7		;Dis'll give us the Y velocity
	MOVI	SLED_XYACCEL,A4
	SRA	SLED_XYACCEL_SRA,A7
	JRNN	AMA_YPLUS
	NEG	A4
	JRUC	AMA_STUFFY
AMA_YPLUS
	JRZ	AMA_SKIPY
AMA_STUFFY
	ABS	A7
	MOVB	A7,*A8(OYBURN)
	MOVE	A4,*A8(OYACCEL),W
AMA_SKIPY

	MOVE	A10,A0
	MOVK	10,A1
	CALLA	RANGERND		;Random Duration
	MOVB	A0,*A8(OMOVE_TIMER)	;Set the duration
	
AMA_X
	RETS

*
*Come here when you want to get to the center right away.
*No accelerations are used, just straight velocity
*
AMA_CENTER_NOW
	MOVI	0A000H,A11
	CLR	A9

	MOVI	MONDOR_YMAX,A0
	MOVI	MONDOR_YMIN,A1
	CALLA	RANGERND
	MOVE	A0,A7			;Random Y
	SLL	16,A7

	MOVI	10,A10

	SUB	A4,A11			;Get the Z distance
	DIVS	A10,A11			;Dis'll give us the Z velocity
	MOVE	A11,*A8(OZVEL),L

	SUB	A6,A9			;Get the X distance
	DIVS	A10,A9			;Dis'll give us the X velocity
	MOVE	A9,*A8(OXVEL),L

	SUB	A5,A7			;Get the Y distance
	DIVS	A10,A7			;Dis'll give us the Y velocity
	MOVE	A7,*A8(OYVEL),L

	MOVB	A10,*A8(OMOVE_TIMER)	;Set the duration

	CLR	A14
	MOVE	A14,*A8(OXACCEL),W
	MOVE	A14,*A8(OYACCEL),W
	MOVE	A14,*A8(OZACCEL),W
	
	RETS

**************************************************************************
*								         *
* 	A_ARM_FIRE_FNC							 *
* 									 *
* 	Anim Func for arm part firing on the player(s).			 *
* 									 *
* 	A8 = Ptr to arm part doing the firing.				 *
* 	AARG+,L = [Y,X] firing offset for barrel #1			 *
* 	AARG+,L = [Y,X] firing offset for barrel #2			 *
*								         *
**************************************************************************
A_ARM_FIRE_FNC
	MOVB	*A8(O_BEING_DAMAGED),A14 ;Object being damaged?
	JRN	AFF_X			;BR = Yes

	CALLA	GETAFARG_LONG		;Get the firing offset for barrel 1

	MOVB	*A8(OBARREL),A14
	JRZ	AAFF_BARREL1
	CALLA	GETAFARG_LONG		;Get firing offset for barrel 2
	CLR	A14
	JRUC	AAFF_FLASH_IT
AAFF_BARREL1
	MOVK	1,A14
AAFF_FLASH_IT
	MOVB	A14,*A8(OBARREL)
	MOVE	A0,A3
	CALLA	EGUN_FLASH_MULTI	;Make a gun flash

	INCB	*A8(OSHOTS_TAKEN)

;	MOVI	[2,0],A5
	MOVE	@BASE_HIT,A5,W
	ADDI	800H,A5
	SLL	4,A5
	CALLA	CK_PLAYER_HIT

	JRNZ	AFF_HIT			;BR = Successful hit on Player(s)
	JRNC	AFF_NOHIT		;BR = No hit, but he was visible
 	JRUC	AFF_NOHIT_NO_SOUND	;He did'nt hit because he was not visible
AFF_HIT
	CLRB	*A8(OMISSES)
	SOUNDZ	SND_MONDOR_GUN
	JRUC	AFF_X
AFF_NOHIT
	SOUNDZ	SND_MONDOR_GUN
AFF_NOHIT_NO_SOUND
	INCB	*A8(OMISSES)
AFF_X
	RETS

**************************************************************************
*								         *
* 	A_RANDOM_MULTI_CHUNK						 *
* 									 *
* 	Anim Func to call a fragger script for chunks randomly		 *
* 	pick from MULTI_CHUNK_TAB.					 *
* 									 *
* 	A8 = Ptr to object creating chunks				 *
*								         *
**************************************************************************
A_RANDOM_MULTI_CHUNK
	MOVK	4,A0
	CALLA	RAND0
	SLL	5,A0
	ADDI	MULTI_CHUNK_TAB,A0
	MOVE	*A0,A0,L
	MOVE	A0,B14
	MOVI	[2,0],A0
	MOVI	400H,A3
	MOVI	[5,5],A4
	CALLA	PreFrag_Box
	JAUC	Fragger

**************************************************************************
*								         *
* 	A_SHIRT_CHUNK							 *
* 									 *
* 	Anim Func to call a fragger script for shirt chunks.		 *
* 									 *
* 	A8 = Ptr to object creating chunks				 *
*								         *
**************************************************************************
A_SHIRT_CHUNK
	MOVI	MONDOR_SHIRT_MULTI,B14
	MOVI	[2,0],A0
	MOVI	400H,A3
	MOVI	[5,5],A4
	CALLA	PreFrag_Box
	JAUC	Fragger

**************************************************************************
*								         *
* 	A_JEANS_CHUNK							 *
* 									 *
* 	Anim Func to call a fragger script for jeans chunks.		 *
* 									 *
* 	A8 = Ptr to object creating chunks				 *
*								         *
**************************************************************************
A_JEANS_CHUNK
	MOVI	MONDOR_JEANS_MULTI,B14
	MOVI	[2,0],A0
	MOVI	400H,A3
	MOVI	[5,5],A4
	CALLA	PreFrag_Box
	JAUC	Fragger

**************************************************************************
*								         *
* 	A_RAND_SPAWN_BLOOD						 *
* 									 *
* 	Same as A_SPAWN_BLOOD except there's a 50/50 chance of		 *
* 	not getting blood.						 *
*								         *
**************************************************************************
A_RAND_SPAWN_BLOOD
	MOVI	512,A0
	CALLA	RANDPER
	JRNC	ASB_X		;BR = Even, no blood

**************************************************************************
*								         *
* 	A_SPAWN_BLOOD							 *
* 									 *
* 	Anim Func to spawn some blood. Makes blood part of the		 *
* 	multi-parter.							 *
* 									 *
* 	AARG+,L	= Init table to create.					 *
* 	AARG+,L = [Y,X] offset						 *
*								         *
**************************************************************************
A_SPAWN_BLOOD
	CALLA	GETAFARG_LONG
	MOVE	A0,A5
	CALLA	GETAFARG_LONG
	MOVE	A0,A3
*
*Entrypoint: You provide the init table and the offsets.
*A3 = [Y,X] Offset
*A5 = Init table
*Note: trashes much register
*
SPAWN_BLOOD
	CALLA	CREATE_OBJ
	JRZ	ASB_X  			;No objects available

	MOVE	*A8(OCTRL),A7,W	     	;ADJUST OFFSET IF NECESSARY
	BTST	B_FLIPH,A7
	JRZ	ASB_CHECKV
	NEGX	A3
ASB_CHECKV
	BTST	B_FLIPV,A7
	JRZ	ASB_NOV			;BR=NO FLIP ADJUSTMENT			
	NEGY	A3
ASB_NOV
	MOVE	*A8(OPARTSXY),A14,L	;Grab the masters OPARTSXY
	ADDXY	A14,A3
	MOVE	A3,*A0(OPARTSXY),L

	MOVE	*A8(OZVAL),A3,L

	MOVB	*A8(OZOFF),A5
	SUB	A5,A3	     		;This calculation will make the 
	MOVB	*A0(OZOFF),A14		;OZOFF for the gun flash relative
	ADD	A5,A14			;to the base ZVAL of the multi-parter.
	MOVB	A14,*A0(OZOFF)

	MOVE	*A8(OCTRL),A5,W
	ANDI	M_FLIPH,A5		;ISOLATE FLIP BITS ONLY
	MOVE	*A0(OCTRL),A14,W
	OR	A5,A14			;Match flip to spawing object
	MOVE	A14,*A0(OCTRL),W

	CALLA	GET_HEAD_PART		;Use the head part as a good source

	MOVE	*A8(OXVAL),A1,L
	MOVE	*A8(OYVAL),A2,L

	CALLA	SETOFFPU

	CALLA	INSPART

	CALLA	INSOBJ
ASB_X
	RETS

**************************************************************************
*								         *
* 	BLOW_PART							 *
* 									 *
* 	Anim func entrypoint to blow a part of the enemy.		 *
* 									 *
* 	A1 = MIN XVEL							 *
* 	A2 = MAX XVEL							 *
* 	A3 = MIN YVEL							 *
* 	A4 = MAX YVEL							 *
* 	B0 = Init table							 *
* 									 *
* 	Note: trashes much register					 *
*								         *
**************************************************************************
BLOW_PART
	MOVI	900,A0	
	CALLA	RANDPER
	JRC	BP_DO_WHAT_I_TOLD_YOU

	MOVI	EXPLO_BLOW_INIT,B0	;Substitute this thang

BP_DO_WHAT_I_TOLD_YOU
	MOVE	A1,A5
	CALLA	EASYMAKE
	JRZ	BP_X  			;No objects available
	MOVE	A5,A1

	MOVE	*A8(OCTRL),A5,W
	ANDI	M_FLIPH|M_FLIPV,A5	;ISOLATE FLIP BITS ONLY
	MOVE	*A0(OCTRL),A14,W
	OR	A14,A5			;Match flip to spawing object
	MOVE	A5,*A0(OCTRL),W

	MOVE	A0,A6

	MOVE	A2,A0
	CALLA	RANGERND
	BTST	B_FLIPH,A5
	JRNZ	BP_X_POS
	NEG	A0
BP_X_POS
	MOVE	A0,*A6(OXVEL),L

	MOVE	A4,A0
	MOVE	A3,A1
	CALLA	RANGERND
	MOVE	A0,*A6(OYVEL),L
	
	MOVE	A6,A0

	CALLA	GET_HEAD_PART		;Use the head part as a good source

	MOVE	*A8(OXVAL),A1,L
	MOVE	*A8(OYVAL),A2,L
	MOVE	*A8(OZVAL),A3,L

	CALLA	SETANIPU

	CALLA	INSOBJ
BP_X
	RETS

**************************************************************************
*								         *
* 	PROC_SKY_FLASH							 *
* 									 *
* 	Process to flash the sky and ground white, then restore.	 *
*								         *
**************************************************************************
PROC_SKY_FLASH
	SLEEP	3
	MOVIM	07FFFH,@IRQSKYE,W
	MOVIM	07FFFH,@IRQGNDE,W
	SLEEP	2
	MOVE	@SKYCOLOR,@IRQSKYE,W
	MOVE	@GROUNDCOLOR,@IRQGNDE,W
	SLEEP	2
	MOVIM	07FFFH,@IRQSKYE,W
	MOVIM	07FFFH,@IRQGNDE,W
	SLEEP	2
	MOVE	@SKYCOLOR,@IRQSKYE,W
	MOVE	@GROUNDCOLOR,@IRQGNDE,W
	SLEEP	2
	MOVIM	07FFFH,@IRQSKYE,W
	MOVIM	07FFFH,@IRQGNDE,W
	SLEEP	2
	MOVE	@SKYCOLOR,@IRQSKYE,W
	MOVE	@GROUNDCOLOR,@IRQGNDE,W
	DIE

**************************************************************************
*								         *
* 	PROC_SKY_FLASH_ONCE			    			 *
* 									 *
* 	Process to flash the sky and ground white, then restore.	 *
*								         *
**************************************************************************
PROC_SKY_FLASH_ONCE
	MOVIM	07FFFH,@IRQSKYE,W
	MOVIM	07FFFH,@IRQGNDE,W
	SLEEP	2
	MOVE	@SKYCOLOR,@IRQSKYE,W
	MOVE	@GROUNDCOLOR,@IRQGNDE,W
	DIE

**************************************************************************
*								         *
* 	FB_GUNVECT							 *
* 									 *
* 	Gun vector for Mondor's fire ball.				 *
* 									 *
* 	A2 = Ptr to player shooting the fire ball.			 *
* 	A8 = Ptr to the fire ball object.				 *
*								         *
**************************************************************************
FB_GUNVECT
	CALLA	COLLS_OFF
	MOVIM	-8,*A8(OYVEL+16),L
	MOVIM	800H,*A8(OZVEL),L
	SOUNDZ	SND_PROJECTILE_FLY
	MOVI	250,A1
	CALLA	SCORE			;Score points for neutralizing
	MOVI	ANIM_FB_FLYAWAY,A1
	JAUC	SetAnim
	
**************************************************************************
*								         *
* 	GREN_GUNVECT							 *
* 									 *
* 	Gun vector for Mondor's Grenade.				 *
* 									 *
* 	A2 = Ptr to player shooting the Grenade.			 *
* 	A8 = Ptr to the Grenade object.					 *
*								         *
**************************************************************************
GREN_GUNVECT
	CALLA	COLLS_OFF
	CALLA	CLR_VEL
	MOVI	ANIM_GREN_EXPLODE,A1
	CALLA	SetAnim
	SOUNDZ	SND_GREN_EXPLODE
	MOVI	100,A1
	JAUC	SCORE			;Score points for neutralizing

**************************************************************************
*								         *
* 	AXE_GUNVECT							 *
* 									 *
* 	Gun vector for Berzerker's axe.					 *
* 									 *
* 	A2 = Ptr to player shooting the axe.				 *
* 	A8 = Ptr to the axe object.					 *
*								         *
**************************************************************************
AXE_GUNVECT
	CALLA	COLLS_OFF
	MOVIM	-8,*A8(OYVEL+16),L
	MOVIM	800H,*A8(OZVEL),L
	SOUNDZ	SND_AXE_FLY
	MOVI	250,A1
	CALLA	SCORE			;Score points for neutralizing
	MOVI	ANIM_AXE_FLYAWAY,A1
	JAUC	SetAnim

**************************************************************************
*								         *
* 	SPEAR_GUNVECT							 *
* 									 *
* 	Gun vector for Native's spear.					 *
* 									 *
* 	A2 = Ptr to player shooting the spear.				 *
* 	A8 = Ptr to the spear object.					 *
*								         *
**************************************************************************
SPEAR_GUNVECT
	CALLA	COLLS_OFF
	MOVIM	-8,*A8(OYVEL+16),L
	MOVIM	800H,*A8(OZVEL),L
	SOUNDZ	SND_SPEAR_FLY
	MOVI	250,A1
	CALLA	SCORE			;Score points for neutralizing
	DECM	@NUM_SPEARS,W
	MOVI	ANIM_SPEAR_FLYAWAY,A1
	JAUC	SetAnim

**************************************************************************
*								         *
* 	NSTAR_GUNVECT							 *
* 									 *
* 	Gun vector for Ninja's star.					 *
* 									 *
* 	A2 = Ptr to player shooting the star.				 *
* 	A8 = Ptr to the star object.					 *
*								         *
**************************************************************************
NSTAR_GUNVECT
	CALLA	COLLS_OFF
	MOVIM	-8,*A8(OYVEL+16),L
	MOVIM	800H,*A8(OZVEL),L
	SOUNDZ	SND_AXE_FLY
	MOVI	250,A1
	CALLA	SCORE			;Score points for neutralizing
	DECM	@NUM_NSTARS,W
	MOVI	ANIM_NSTAR_FLYAWAY,A1
	JAUC	SetAnim

**************************************************************************
*								         *
* 	FB_CVECT							 *
* 									 *
* 	Collision vector table for the FireBall				 *
*								         *
**************************************************************************
FB_CVECT
	WWL	OID_PROCKET,~MASK_PLAYER,PROJECTILE_ROCKET_COLL
	WWL	OID_PEXPLOSION,~MASK_PLAYER,FB_EXPLOSION_COLL
	WL	0,DUMCRETS

**************************************************************************
*								         *
* PROJECTILE_ROCKET_COLL - Collision vector with Player rocket bomb.	 *
* A0 = Ptr to rocket object						 *
* A8 = Ptr to projectile object						 *
*								         *
**************************************************************************
PROJECTILE_ROCKET_COLL
	MOVE	*A0(RL_INTENDED_OBJ),A14,L
	CMP	A14,A8			;Is this the object we are after?
	JRNE	PRC_X			;BR = No
	MOVK	1,A14
	MOVB	A14,*A8(OCHEWEDROCKET)	;Flag for the explosion
PRC_X
	RETS

**************************************************************************
*								         *
* 	FB_EXPLOSION_COLL						 *
* 									 *
* 	Explosion service for FireBall					 *
* 									 *
* 	A0 = ptr to explosion object					 *
* 	A8 = ptr to FireBall object					 *
*								         *
**************************************************************************
FB_EXPLOSION_COLL
	MOVB	*A8(OCHEWEDROCKET),A14	;Did he really take a rocket?
	JRZ	FEC_X			;BR = No, so bail

	MOVE	*A0(OID),A0,W		;We can find out who did this
	CALLA	POID_TO_PDATA		;by getting the Player's data area.

	JRUC	FB_GUNVECT

FEC_X
	RETS

**************************************************************************
*								         *
* 	AXE_CVECT							 *
* 									 *
* 	Collision vector table for the axe				 *
*								         *
**************************************************************************
AXE_CVECT
	WWL	OID_PROCKET,~MASK_PLAYER,PROJECTILE_ROCKET_COLL
	WWL	OID_PEXPLOSION,~MASK_PLAYER,AXE_EXPLOSION_COLL
	WL	0,DUMCRETS

**************************************************************************
*								         *
* 	AXE_EXPLOSION_COLL						 *
* 									 *
* 	Explosion service for axe					 *
* 									 *
* 	A0 = ptr to explosion object					 *
* 	A8 = ptr to axe object						 *
*								         *
**************************************************************************
AXE_EXPLOSION_COLL
	MOVB	*A8(OCHEWEDROCKET),A14	;Did he really take a rocket?
	JRZ	AEC_X			;BR = No, so bail
	MOVE	*A0(OID),A0,W		;We can find out who did this
	CALLA	POID_TO_PDATA		;by getting the Player's data area.
	JRUC	AXE_GUNVECT
AEC_X
	RETS

**************************************************************************
*								         *
* 	SPEAR_CVECT							 *
* 									 *
* 	Collision vector table for the spear				 *
*								         *
**************************************************************************
SPEAR_CVECT
	WWL	OID_PROCKET,~MASK_PLAYER,PROJECTILE_ROCKET_COLL
	WWL	OID_PEXPLOSION,~MASK_PLAYER,SPEAR_EXPLOSION_COLL
	WL	0,DUMCRETS

**************************************************************************
*								         *
* 	SPEAR_EXPLOSION_COLL						 *
* 									 *
* 	Explosion service for spear					 *
* 									 *
* 	A0 = ptr to explosion object					 *
* 	A8 = ptr to spear object					 *
*								         *
**************************************************************************
SPEAR_EXPLOSION_COLL
	MOVB	*A8(OCHEWEDROCKET),A14	;Did he really take a rocket?
	JRZ	SEC_X			;BR = No, so bail
	MOVE	*A0(OID),A0,W		;We can find out who did this
	CALLA	POID_TO_PDATA		;by getting the Player's data area.
	JRUC	SPEAR_GUNVECT
SEC_X
	RETS

**************************************************************************
*								         *
* 	NSTAR_CVECT							 *
* 									 *
* 	Collision vector table for the star				 *
*								         *
**************************************************************************
NSTAR_CVECT
	WWL	OID_PROCKET,~MASK_PLAYER,PROJECTILE_ROCKET_COLL
	WWL	OID_PEXPLOSION,~MASK_PLAYER,NSTAR_EXPLOSION_COLL
	WL	0,DUMCRETS

**************************************************************************
*								         *
* 	NSTAR_EXPLOSION_COLL						 *
* 									 *
* 	Explosion service for star					 *
* 									 *
* 	A0 = ptr to explosion object					 *
* 	A8 = ptr to star object						 *
*								         *
**************************************************************************
NSTAR_EXPLOSION_COLL
	MOVB	*A8(OCHEWEDROCKET),A14	;Did he really take a rocket?
	JRZ	NEC_X			;BR = No, so bail
	MOVE	*A0(OID),A0,W		;We can find out who did this
	CALLA	POID_TO_PDATA		;by getting the Player's data area.
	JRUC	NSTAR_GUNVECT
NEC_X
	RETS

**************************************************************************
*								         *
* 	A_SPAWN_PROJECTILE						 *
* 									 *
* 	Anim Func to spawn a projectile from a part.			 *
* 									 *
* 	AARG+,L	= Init table to create.					 *
* 	AARG+,L = [Y,X] offset						 *
*								         *
**************************************************************************
A_SPAWN_PROJECTILE
	CALLA	GETAFARG_LONG
	MOVE	A0,B0
	CALLA	GETAFARG_LONG
	MOVE	A0,A3

	CALLA	EASYMAKE
	JRZ	ASP_X  			;No objects available

	MOVE	*A8(OCTRL),A7,W	     	;Adjust offset if necessary
	BTST	B_FLIPH,A7
	JRZ	ASP_CHECKV
	NEGX	A3
ASP_CHECKV
	BTST	B_FLIPV,A7
	JRZ	ASP_NOV			;BR=NO FLIP ADJUSTMENT
	NEGY	A3
ASP_NOV

	MOVE	A3,*A0(OPARTSXY),L	;Just to position us

	MOVE	*A8(OCTRL),A5,W
	ANDI	M_FLIPH|M_FLIPV,A5	;ISOLATE FLIP BITS ONLY
	MOVE	*A0(OCTRL),A14,W
	OR	A14,A5			;Match flip to spawing object
	MOVE	A5,*A0(OCTRL),W

	CALLA	GET_HEAD_PART		;Use the head part as a good source

;This needs to be done by each individual projectile, if necessary
;	MOVIB	60,*A8(OPROJ_CK_TIME)	;Check for hits after this much time

	MOVE	*A8(OXVAL),A1,L
	MOVE	*A8(OYVAL),A2,L
	MOVE	*A8(OZVAL),A3,L
	SUBK	32,A3

	CALLA	SETOFFPU

	MOVE	*A0(OFLAGS),A14,W
	BTST	B_MANSCALE,A14		;Is this a manual scaling object?
	JREQ	ASP_NO_MANUALZ		;BR = No

	MOVE	*A0(OZVAL),A5,L		;We must compute our own scale
	MOVE	@ZBASE,A14,L
	SUB	A14,A5	      		;Current world Z
	SRA	8,A5		  	;compute pseudo Z
	MOVI	380h,A6
	MPYS	A6,A5
	SUBI	9000h,A5
	SRA	Z2SCALE,A5		;compute scale from pseudo Z
	MOVE	A5,A9
	MOVE	A8,B1
	MOVE	A0,A8
	CALLA	SET_SCALE_MANUAL
	MOVE	B1,A8

ASP_NO_MANUALZ
	MOVE	A8,*A0(OPROJECT_PARENT),L	;Tell us our roots

	MOVE	*A8(OZVEL),A14,L	;Transfer Z velocity only if Enemy
	JRP	ASP_INSERT		;is not moving away from the screen
	MOVE	A14,*A0(OZVEL),L
ASP_INSERT

	CALLA	INSOBJ
ASP_X
	RETS

**************************************************************************
*								         *
* 	A_PROJ_CK_PHIT							 *
* 									 *
* 	Anim Func to check if one of Mondor's projectiles hit		 *
* 	a player.							 *
* 									 *
* 	A8 = Ptr to projectile						 *
* 	AARG+,L = [Y,X] Firing offset					 *
* 	AARG+,L = [INT,FRAC] amount to add to BASE_HIT			 *
*								         *
**************************************************************************
A_PROJ_CK_PHIT
	CALLA	GETAFARG_LONG
	MOVE	A0,A3

	MOVE	@BASE_HIT,A5,W
	SLL	4,A5

	CALLA	GETAFARG_LONG
;	MOVE	A0,A5
	ADD	A0,A5

	CALLA	CK_PLAYER_HIT
	JRZ	APCP_X

	MOVE	*A8(OPROJECT_PARENT),A0,L	;Get the guy that created us
	JRZ	APCP_X			;BR = He's anonymous

	.IF DEBUG
	CALLA	IsAnObj			;Sanity check
	.ENDIF

	CALLA	GETHEADPART		;Get some head
	ADDKB	1,*A0(OPROJ_HIT)

APCP_X
	RETS

**************************************************************************
*								         *
* 	A_FIRE_BALL_TARGET						 *
* 									 *
* 	Anim func to set up the velocities and what not for		 *
* 	the fire ball.							 *
* 									 *
* 	A8 = ptr to the fire ball object				 *
*								         *
**************************************************************************
A_FIRE_BALL_TARGET
	MOVI	800,A0
	CALLA	RANDPER			;This is the chance that we target
	JRNC	AFBT_FULL_SCREEN	;BR = Not this time

	CALLA	GET_PLAYER_EXTENTS
	JRUC	AFBT_PICK_TARGET

AFBT_FULL_SCREEN
	MOVI	[SCRTOP+SKYTOPOF,SCRLFT],A2
	MOVI	[SCRBOT,SCRRGT],A3

AFBT_PICK_TARGET
	MOVY	A2,A0
	MOVY	A3,A1
	CALLA	RANGERND
	SRA	16,A0
	MOVE	A0,A5

	MOVX	A2,A0
	SEXT	A0
	MOVX	A3,A1
	SEXT	A1
	CALLA	RANGERND
	MOVE	A0,A1

	MOVE	A5,A3

	MOVE	@ZBASE,A5,L
	ADDI	ZMAX_REAL2,A5

	STOUXY	A5,A1,A3

	MOVE	*A8(OXVAL),A2,L
	MOVE	*A8(OYVAL),A4,L
	MOVE	*A8(OZVAL),A6,L

	MOVI	45,A7
	MOVB	A7,*A8(OPROJECT_TIME)

	CALLA	SLINEVEL_LOAD_3D

	MOVE	*A8(OPROJECT_PARENT),A0,L	;Get the guy that created us
	CALLA	GETHEADPART		;Get some head

	MOVE	*A0(OZVAL),A14,L
	CMP	A14,A6	       		;Is fireball already behind Mondor?
	JAGT	DELETE_OBJ_PROC		;BR = Yes

	MOVE	*A8(OZVEL),A1,L
	MOVE	*A0(OZVEL),A14,L
	CMP	A14,A1	       		;Is Mondor moving faster than the fireball?
	JAGT	DELETE_OBJ_PROC		;BR = Yes, delete

	MOVIB	60,*A0(OPROJ_CK_TIME)	;Store for talk back

	MOVE	*A0(ONOARM_TIME),A14,W
	CMPI	NOARMS_PISSED,A14	;Has it been a while with no arms?
	JRLO	AFBT_NORMAL_ARC		;BR = No
	MOVI	90000H,A0
	JRUC	AFBT_CALC_ARC
AFBT_NORMAL_ARC
	MOVI	40000H,A0
AFBT_CALC_ARC
	CALLA	SRAND
	ADDRM	A0,*A8(OXVEL),L
	MOVE	A0,A1
	MOVI	45/2,A0
	DIVS	A0,A1
	NEG	A1
	MOVE	A1,*A8(OXACCEL),W

	SOUNDZ	SND_FIRE_BALL
	SOUNDZ	SND_FIRE_HISS

	RETS

**************************************************************************
*								         *
* 	A_FB_COLLS_ON							 *
* 									 *
* 	Anim func to turn on collsions for the FireBall.		 *
* 									 *
* 	A8 = Ptr to FireBall						 *
*								         *
**************************************************************************
A_FB_COLLS_ON
	MOVIM	FB_GUNVECT,*A8(OGUNVECT),L
	MOVIM	FB_CVECT,*A8(OCVECT),L
	MOVI	OID_EROCKET,A1
	CALLA	CHANGE_OID
	RETS

**************************************************************************
*								         *
* 	A_GREN_COLLS_ON							 *
* 									 *
* 	Anim func to turn on collsions for the Grenade.			 *
* 									 *
* 	A8 = Ptr to Grenade						 *
*								         *
**************************************************************************
A_GREN_COLLS_ON
	MOVIM	GREN_GUNVECT,*A8(OGUNVECT),L
	MOVIM	FB_CVECT,*A8(OCVECT),L
	MOVI	OID_EROCKET,A1
	CALLA	CHANGE_OID
	RETS

**************************************************************************
*								         *
* 	A_AXE_COLLS_ON							 *
* 									 *
* 	Anim func to turn on collsions for the axe.			 *
* 									 *
* 	A8 = Ptr to Axe							 *
*								         *
**************************************************************************
A_AXE_COLLS_ON
	MOVIM	AXE_GUNVECT,*A8(OGUNVECT),L
	MOVIM	AXE_CVECT,*A8(OCVECT),L
	MOVI	OID_EROCKET,A1
	CALLA	CHANGE_OID
	RETS

**************************************************************************
*								         *
* 	A_NSTAR_COLLS_ON     						 *
* 									 *
* 	Anim func to turn on collsions for the Ninja star.		 *
* 									 *
* 	A8 = Ptr to Axe							 *
*								         *
**************************************************************************
A_NSTAR_COLLS_ON
	MOVIM	NSTAR_GUNVECT,*A8(OGUNVECT),L
	MOVIM	NSTAR_CVECT,*A8(OCVECT),L
	MOVI	OID_EROCKET,A1
	CALLA	CHANGE_OID
	RETS

**************************************************************************
*								         *
* 	A_GRENADE_TARGET						 *
* 									 *
* 	Anim func to set up the velocities and what not for		 *
* 	the Grenade.							 *
* 									 *
* 	A8 = ptr to the Grenade object					 *
*								         *
**************************************************************************
A_GRENADE_TARGET
	MOVB	*A8(OFLAGS),A14		;Are we onscreen?
	JAN	DELETE_OBJ_PROC		;BR = No, delete immeadiately

;	MOVE	*A8(OZVAL),A6,L		;Get the grenades current Z position
;	MOVE	*A8(OXVAL),A2,L		;We need X here for velocity calc
;	MOVE	A2,A1			;Copy for screen conversion
;	MOVE	*A8(OYVAL),A4,L		;We need Y here for velocity calc

;	UTOSX	A6,A1			;Get the screen X

;	CMPI	SCRLFT+75,A1		;Is this point too far left?
;	JRGE	AGT_SXL_OK		;BR = No, use it as is
;	MOVI	SCRLFT+75,A1		;Otherwise fix it
;	JRUC	AGT_RAND_SX
;AGT_SXL_OK
;	CMPI	SCRRGT-75,A1		;How about too far right?
;	JRLE	AGT_RAND_SX		;BR = No, you can use it
;	MOVI	SCRRGT-75,A1		;Otherwise make it right boundry
;AGT_RAND_SX
;	MOVI	50,A0
;	CALLA	SRAND			;Some random range
;	ADD	A0,A1			;Got X screen target

;	MOVI	(SCRBOT-SCRTOP)/2,A0
;	MOVI	SCRBOT-20,A1
;	CALLA	RANGERND
;	MOVE	A0,A3			;Got Y screen target

	MOVI	800,A0
	CALLA	RANDPER			;This is the chance that we target
	JRNC	AGT_FULL_SCREEN		;BR = Not this time

	CALLA	GET_PLAYER_EXTENTS

	MOVI	(SCRBOT-SCRTOP)/3,A14
	SLL	16,A14
	MOVY	A14,A2			;1/3 screen line is the top

	JRUC	AGT_PICK_TARGET

AGT_FULL_SCREEN
	MOVI	[(SCRBOT-SCRTOP)/3,SCRLFT],A2
	MOVI	[SCRBOT,SCRRGT],A3

AGT_PICK_TARGET
	MOVY	A2,A0
	MOVY	A3,A1
	CALLA	RANGERND
	SRA	16,A0
	MOVE	A0,A5

	MOVX	A2,A0
	SEXT	A0
	MOVX	A3,A1
	SEXT	A1
	CALLA	RANGERND
	MOVE	A0,A1

	MOVE	A5,A3

	MOVE	@ZBASE,A5,L
	ADDI	ZMAX_REAL,A5

	STOUXY	A5,A1,A3

	MOVE	*A8(OXVAL),A2,L
	MOVE	*A8(OYVAL),A4,L
	MOVE	*A8(OZVAL),A6,L

	MOVI	45,A7
	MOVB	A7,*A8(OPROJECT_TIME)

	CALLA	SLINEVEL_LOAD_3D

	MOVE	*A8(OPROJECT_PARENT),A0,L	;Get the guy that created us
	CALLA	GETHEADPART		;Get some head

	MOVE	*A0(OZVAL),A14,L
	CMP	A14,A6	       		;Is grenade already behind Mondor?
	JAGT	DELETE_OBJ_PROC		;BR = Yes

	MOVE	*A8(OZVEL),A1,L
	MOVE	*A0(OZVEL),A14,L
	CMP	A14,A1	       		;Is Mondor moving faster than the grenade?
	JAGT	DELETE_OBJ_PROC		;BR = Yes, delete

	MOVIB	60,*A0(OPROJ_CK_TIME)	;Store for talk back

	ADDIM	-20000H,*A8(OYVEL),L
	MOVIM	20000H/(45/2),*A8(OYACCEL),W

	SOUNDZ	SND_GREN_THROW

	RETS

**************************************************************************
*								         *
* 	A_AXE_TARGET							 *
* 									 *
* 	Anim func to set up the velocities and what not for		 *
* 	the axe.							 *
* 									 *
* 	A8 = ptr to the axe object					 *
*								         *
**************************************************************************
A_AXE_TARGET
	MOVB	*A8(OFLAGS),A14		;Are we onscreen?
	JAN	DELETE_OBJ_PROC		;BR = No, delete immediately

	MOVI	SCRTOP+100,A0
	MOVI	SCRBOT-50,A1
	CALLA	RANGERND
	MOVE	A0,A3			;Got Y screen target

	MOVE	*A8(OZVAL),A6,L		;Get the current Z position
	MOVE	*A8(OXVAL),A2,L		;We need X here for velocity calc
	MOVE	A2,A1			;Copy for screen conversion
	MOVE	*A8(OYVAL),A4,L		;We need Y here for velocity calc

	UTOSX	A6,A1			;Get the screen X

	CMPI	SCRLFT+10,A1		;Is this point too far left?
	JRGE	AGT_SXL_OK		;BR = No, use it as is
	MOVI	SCRLFT+10,A1		;Otherwise fix it
	JRUC	AGT_RAND_SX
AGT_SXL_OK
	CMPI	SCRRGT-10,A1		;How about too far right?
	JRLE	AGT_RAND_SX		;BR = No, you can use it
	MOVI	SCRRGT-10,A1		;Otherwise make it right boundry
AGT_RAND_SX

	MOVE	@ZBASE,A5,L
	ADDI	ZMAX_REAL,A5

	STOUXY	A5,A1,A3

	MOVI	45,A7
	MOVB	A7,*A8(OPROJECT_TIME)

	CALLA	SLINEVEL_LOAD_3D

;	ADDIM	-20000H,*A8(OYVEL),L
	MOVIM	20000H/(45/2),*A8(OYACCEL),W

	MOVE	@YSCROLL,A1,L
	NEG	A1
	ADDI	-20000H,A1
	ADDRM	A1,*A8(OYVEL),L

	RETS

**************************************************************************
*								         *
* 	A_SPEAR_TARGET							 *
* 									 *
* 	Anim func to set up the velocities and what not for		 *
* 	the spear.							 *
* 									 *
* 	A8 = ptr to the spear object					 *
*								         *
**************************************************************************
A_SPEAR_TARGET
	MOVB	*A8(OFLAGS),A14		;Are we onscreen?
	JAN	DELETE_OBJ_PROC		;BR = No, delete immediately

	INCM	@NUM_SPEARS,W		;Increment the active spear count

	MOVI	SCRTOP+100,A0
	MOVI	SCRBOT-50,A1
	CALLA	RANGERND
	MOVE	A0,A3			;Got Y screen target

	MOVE	*A8(OZVAL),A6,L		;Get the current Z position
	MOVE	*A8(OXVAL),A2,L		;We need X here for velocity calc
	MOVE	A2,A1			;Copy for screen conversion
	MOVE	*A8(OYVAL),A4,L		;We need Y here for velocity calc

	UTOSX	A6,A1			;Get the screen X

	CMPI	SCRLFT+10,A1		;Is this point too far left?
	JRGE	AST_SXL_OK		;BR = No, use it as is
	MOVI	SCRLFT+10,A1		;Otherwise fix it
	JRUC	AST_RAND_SX
AST_SXL_OK
	CMPI	SCRRGT-10,A1		;How about too far right?
	JRLE	AST_RAND_SX		;BR = No, you can use it
	MOVI	SCRRGT-10,A1		;Otherwise make it right boundry
AST_RAND_SX

	MOVE	@ZBASE,A5,L
	ADDI	ZMAX_REAL,A5

	STOUXY	A5,A1,A3

	MOVI	60,A7
	MOVB	A7,*A8(OPROJECT_TIME)

	CALLA	SLINEVEL_LOAD_3D
	move	*a8(OXVEL),a14,L
	move	@XSCROLL,a1,L
	add	a1,a14
	move	a14,*a8(OXVEL),L


	ADDIM	-18000H,*A8(OYVEL),L
	MOVIM	18000H/(60/2),*A8(OYACCEL),W

	RETS

**************************************************************************
*								         *
* 	A_CHUNK_ONSCREEN						 *
* 									 *
* 	Anim func to determine if a chunk is on screen or off.		 *
* 	If it is off, then check to see if it is below the		 *
* 	ground level. If it is then fall through.			 *
* 	If all velocities and accels go to zero, then we fall		 *
* 	through.							 *
* 									 *
* 	A8 = Ptr to object						 *
* 	AARG+,L = Branch						 *
*								         *
**************************************************************************
A_CHUNK_ONSCREEN
	CALLA	GETAFARG_LONG
	CALLA	GET_HEAD_PART

	MOVE	*A8(OYACCEL),A4,W
	MOVE	*A8(OYVEL),A5,L		;We'll need these

	MOVB	*A8(OFLAGS),A14
	JRNN	ACO_BRANCH		;BR = Object is on screen

	MOVE	A4,A14
	JRLE	ACO_NOBRANCH		;BR = Accelerating in the wrong dir

	MOVE	A5,A14
	JRN	ACO_NO_BOTCK		;BR = We are movin' up

* See if we are off of the bottom of the screen
	MOVE	*A8(ODAGY),A1,W
	MOVE	@(SCRNBR+16),A14,W
	CMP	A14,A1
	JRGT	ACO_NOBRANCH		;BR = Off of the bottom of the screen

ACO_NO_BOTCK
	CALLA	DIST_FROM_GROUND	;See if it is above
	JRLT	ACO_NOBRANCH		;BR = it is below

ACO_BRANCH
* This is a sanity check to make sure things are still moving
	MOVE	A5,A14
	JRNZ	ACO_BRANCH_OK		;BR = We are moving, this is good
	MOVE	A4,A14
	JRZ	ACO_NOBRANCH		;BR = No vertical movement, bail
ACO_BRANCH_OK
	MOVE	A0,A1
	JAUC	STRT_ANIM
ACO_NOBRANCH
	RETS


**************************************************************************
*								         *
* 	A_CHECK_FB_SCREEN_HIT						 *
* 									 *
* 	Anim func to check if FireBall hit the screen.			 *
* 									 *
* 	A8 = ptr to FireBall						 *
*								         *
**************************************************************************
A_CHECK_FB_SCREEN_HIT
	MOVI	SND_FB_HIT_SCRN,A4
	MOVI	ANIM_PROJ_HIT,A5
	JRUC	CHECK_SCREEN_HIT

**************************************************************************
*								         *
* 	A_CHECK_GREN_SCREEN_HIT						 *
* 									 *
* 	Anim func to check if Grenade hit the screen.			 *
* 									 *
* 	A8 = ptr to Grenade						 *
*								         *
**************************************************************************
A_CHECK_GREN_SCREEN_HIT
	MOVI	SND_GREN_HIT_SCRN,A4
	MOVI	ANIM_PROJ_HIT,A5
	JRUC	CHECK_SCREEN_HIT

**************************************************************************
*								         *
* 	A_CHECK_MISSLE_SCREEN_HIT		     			 *
* 									 *
* 	Anim func to check if Missle hit the screen.			 *
* 									 *
* 	A8 = ptr to Missle						 *
*								         *
**************************************************************************
A_CHECK_MISSLE_SCREEN_HIT
	MOVI	SND_GREN_HIT_SCRN,A4
	MOVI	ANIM_MISSLE_HIT,A5
	JRUC	CHECK_SCREEN_HIT

**************************************************************************
*								         *
* 	A_CHECK_AXE_SCREEN_HIT						 *
* 									 *
* 	Anim func to check if Axe hit the screen.			 *
* 									 *
* 	A8 = ptr to Axe							 *
*								         *
**************************************************************************
A_CHECK_AXE_SCREEN_HIT
	MOVI	SND_AXE_HIT_SCRN,A4
	MOVI	ANIM_AXE_HIT,A5
	JRUC	CHECK_SCREEN_HIT

**************************************************************************
*								         *
* 	A_CHECK_SPEAR_SCREEN_HIT					 *
* 									 *
* 	Anim func to check if Spear hit the screen.			 *
* 									 *
* 	A8 = ptr to Spear						 *
*								         *
**************************************************************************
A_CHECK_SPEAR_SCREEN_HIT
	MOVI	SND_SPEAR_HIT_SCRN,A4
	MOVI	ANIM_SPEAR_HIT,A5
	JRUC	CHECK_SCREEN_HIT

**************************************************************************
*								         *
* 	A_CHECK_NSTAR_SCREEN_HIT					 *
* 									 *
* 	Anim func to check if Ninja star hit the screen.		 *
* 									 *
* 	A8 = ptr to Axe							 *
*								         *
**************************************************************************
A_CHECK_NSTAR_SCREEN_HIT
	MOVI	SND_AXE_HIT_SCRN,A4
	MOVI	ANIM_NSTAR_HIT,A5
	JRUC	CHECK_SCREEN_HIT

**************************************************************************
*								         *
* 	A_KILL_MAN_SCALE						 *
* 									 *
* 	Anim func to kill the manual scale for this object.		 *
* 									 *
* 	A8 = Ptr to object						 *
*								         *
**************************************************************************
A_KILL_MAN_SCALE
	ANDNIM	M_MANSCALE,*A8(OFLAGS),W
	JAUC	OBJPROC_KILL

**************************************************************************
*								         *
* 	A_MAKE_MORPH_SND						 *
* 									 *
* 	Anim func to fire off the 2 morph sounds			 *
*								         *
**************************************************************************
A_MAKE_MORPH_SND
	SOUND1	SND_MORPH2
	SOUND1	SND_MORPH3
	RETS

*
*Entrypoint: This does a screen hit check for an object.
*		Assumption is made that object is animating.
*A4 = Sound to make upon hit
*A5 = Animation to jump to upon hit
*
CHECK_SCREEN_HIT
	MOVE	*A8(OZVAL),A1,L
	MOVE	@ZBASE,A3,L
	SUB	A3,A1			;Get the World Z position

	MOVE	*A8(OFLAGS),A14,W
	BTST	B_DBLSCL,A14
	JRZ	CSH_NORMAL_SCALE

* Do this for 2-scale objects

	CMPI	ZMAX_REAL2+400H,A1	;Did he hit the front?
	JRGT	CSH_CHECK_Z		;BR = No

	CALLA	CLR_VEL			;Stop this crazy thing

	MOVI	ZMAX_REAL2+100H,A1
	JRUC	CSH_STUFF_FRONT

CSH_NORMAL_SCALE
	CMPI	ZMAX_REAL+400H,A1	;Did he hit the front?
	JRGT	CSH_CHECK_Z		;BR = No

	CALLA	CLR_VEL			;Stop this crazy thing

	MOVI	ZMAX_REAL,A1
CSH_STUFF_FRONT
	ADD	A3,A1
	MOVE	A1,*A8(OZVAL),L		;Set it right at the front

	CALLA	COLLS_OFF		;Too late to hit this bitch

	MOVB	*A8(OFLAGS),A14
	JRN	CSH_NOSND		;BR = Offscreen

	MOVE	A4,A0
	CALLA	ONESND			;hit us with best shot preeese

CSH_NOSND
	CALLA	OBJPROC_KILL		;Kill any straggling process

	CALLA	OBJ_ON			;Make sure the object is on

	MOVE	A5,A1			;Run this animation
	JAUC	SetAnim

*See if we've fallen behind the object that created us.
*If so, then delete.
CSH_CHECK_Z
	MOVE	*A8(OPROJECT_PARENT),A0,L	;Get the guy that created us

	.IF DEBUG
	CALLA	IsAnObj			;Sanity check
	.ENDIF

	CALLA	GETHEADPART		;Get some head
	MOVE	*A0(OZVAL),A14,L	;Parent Z
	MOVE	*A8(OZVAL),A1,L		;Projectile Z

	CMP	A14,A1			;Is the projectile in front?
	JRLE	CSH_X			;BR = Yes, so it may be spared

	MOVE	*A8(OZVEL),A14,L	;Is it moving towards the rear?
	JRP	CSH_X			;BR = Yes

	CLRM	*A8(OPROJECT_PARENT),L

	JAUC	DELETE_OBJ_PROC		;Kind of harsh, don't you think?

CSH_X
	RETS

**************************************************************************
*								         *
* 	C_GRENADE							 *
* 									 *
* 	Create func for Mondor's Grenade				 *
* 									 *
* 	A0 = ptr to un-inserted Grenade					 *
*								         *
**************************************************************************
C_GRENADE
	MMTM	SP,A0,A8

	MOVE	A0,A8
	CREATE	PID_IND,PROC_MAN_SCALE
	MOVE	A0,*A8(OPLINK),L

	MMFM	SP,A0,A8
	JRUC	C_PROJECTILE

**************************************************************************
*								         *
* 	C_FIREBALL							 *
* 									 *
* 	Create func for Mondor's FireBall				 *
* 									 *
* 	A0 = ptr to un-inserted FireBall				 *
*								         *
**************************************************************************
C_FIREBALL
	MMTM	SP,A0,A8

	MOVE	A0,A8
	CREATE	PID_IND,PROC_PROJECTILE_FLASH
	MOVE	A0,*A8(OPLINK),L

	MMFM	SP,A0,A8
	CLR	A14
	MOVB	A14,*A0(OCHEWEDROCKET)
	MOVIM	0101H,*A0(OCONST),W
	RETS

**************************************************************************
*								         *
* 	C_PROJECTILE							 *
* 									 *
* 	Create function for Mondor's projectiles			 *
* 									 *
* 	A0 = ptr to un-inserted projectile object			 *
*								         *
**************************************************************************
C_PROJECTILE
	CLR	A14
	MOVB	A14,*A0(OCHEWEDROCKET)
	MOVIM	3F3FH,*A0(OCONST),W
	RETS

**************************************************************************
*								         *
* 	C_AXE								 *
* 									 *
* 	Create func for Berzerker's axe					 *
* 									 *
* 	A0 = ptr to un-inserted Axe					 *
*								         *
**************************************************************************
C_AXE
	CLR	A14
	MOVB	A14,*A0(OCHEWEDROCKET)
	MOVIM	0101H,*A0(OCONST),W
	RETS

**************************************************************************
*								         *
* 	C_SPEAR								 *
* 									 *
* 	Create func for Native's spear					 *
* 									 *
* 	A0 = ptr to un-inserted Spear					 *
*								         *
**************************************************************************
C_SPEAR
	CLR	A14
	MOVB	A14,*A0(OCHEWEDROCKET)
	MOVIM	3F3FH,*A0(OCONST),W
	RETS

**************************************************************************
*								         *
* 	C_NSTAR								 *
* 									 *
* 	Create func for Ninja's star					 *
* 									 *
* 	A0 = ptr to un-inserted star					 *
*								         *
**************************************************************************
C_NSTAR
	CLR	A14
	MOVB	A14,*A0(OCHEWEDROCKET)
	MOVIM	0505H,*A0(OCONST),W
	MOVE	@LAB_RAT,A14,W
	JRNZ	CNS_X

	MMTM	SP,A0,A8
	MOVE	A0,A8
	MOVI	REDWEAPN,A0
	CALLA	CHANGE_PAL
	MMFM	SP,A0,A8

CNS_X
	RETS

**************************************************************************
*								         *
* 	PROC_PROJECTILE_FLASH						 *
* 									 *
* 	Process to flash the projectile.				 *
* 									 *
* 	A8 = Ptr to projectile object.					 *
*								         *
**************************************************************************
PROC_PROJECTILE_FLASH
	MOVE	*A8(OXACCEL),A1,W
	ADDRM	A1,*A8(OXVEL),L
	SLEEP	1
	MOVE	*A8(OXACCEL),A1,W
	ADDRM	A1,*A8(OXVEL),L
	SLEEP	1
	CALLA	OBJ_OFF
	MOVE	*A8(OXACCEL),A1,W
	ADDRM	A1,*A8(OXVEL),L
	SLEEP	1
	CALLA	OBJ_ON
	JRUC	PROC_PROJECTILE_FLASH

**************************************************************************
*								         *
* 	PROC_MAN_SCALE							 *
* 									 *
* 	Process to handle the manual scaling of an object.		 *
* 									 *
* 	A8 = Ptr to object						 *
*								         *
**************************************************************************
PROC_MAN_SCALE
	CLR	A9
PMS_LOOP
	CALLR	MAN_SCALE_CORE
	SLOOP	3,PMS_LOOP

*
*Subroutine to be used by Manual Scaling processes
*A8 = Object
*A9 = Last scale set
*note: Trashes A0,A5
MAN_SCALE_CORE
	MOVE	*A8(OZVAL),A5,L
	MOVE	@ZBASE,A14,L
	SUB	A14,A5	      	; WORLD Z
	SRA	8,A5	  	; compute pseudo Z
	MOVI	380h,A0
	MPYS	A0,A5
	SUBI	9000h,A5
	SRA	Z2SCALE,A5	; compute scale from pseudo Z
	CMP	A5,A9
	JREQ	PMS_NOTNEW
	MOVE	A5,A9
	CALLA	SET_SCALE_MANUAL
PMS_NOTNEW
	RETS



*Initialize Mondor's fire ball
FIRE_BALL_INIT
	.LONG	LILPLAZ1
	.WORD	DMAWNZ, M_DBLSCL, OM_OID|OM_COLL|OM_ANIM|OM_CFUNC
	.WORD	OID_JUNK
	.LONG	DUMCOLL, ANIM_FIRE_BALL, C_FIREBALL

*Animate the fire ball
ANIM_FIRE_BALL
	LWL	1,1|AFunc,A_FIRE_BALL_TARGET
	LW	LILPLAZ2,2
	LW	LILPLAZ3,2
	LW	LILPLAZ1,2
	LWL	LILPLAZ2,2|AFunc,A_FB_COLLS_ON
ANIM_FB_LOOP
	LWL	LILPLAZ3,2|AFunc,A_CHECK_FB_SCREEN_HIT
	LWL	LILPLAZ1,2|AFunc,A_CHECK_FB_SCREEN_HIT
	LWL	LILPLAZ2,1|AFunc,A_CHECK_FB_SCREEN_HIT
	LWLL	1,1|AFunc,A_ONSCREEN+2,ANIM_FB_LOOP
	LWL	1,1|AFunc,DELETE_OBJ_PROC


ANIM_FB_FLYAWAY
	LWLW	1,1|AFunc,A_Set_AnimLoop+1,4
AFBF_LOOP
	LW	LILPLAZ3,2
	LW	LILPLAZ1,2
	LWLL	LILPLAZ2,2|AFunc,A_Anim_DSJ+2,AFBF_LOOP
	LWL	1,1|AFunc,DELETE_OBJ_PROC

*Initialize Mondor's Grenade
GRENADE_INIT
	.LONG	GREN1
	.WORD	DMAWNZ, M_MANSCALE, OM_OID|OM_COLL|OM_GUNV|OM_ANIM|OM_CFUNC
	.WORD	OID_JUNK
	.LONG	DUMCOLL, DUMRETS, ANIM_GRENADE, C_GRENADE

*Animate the Grenade
ANIM_GRENADE
	LWL	1,1|AFunc,A_GRENADE_TARGET
	LW	GREN1,2
	LW	GREN2,2
	LW	GREN3,2
	LWL	GREN4,2|AFunc,A_GREN_COLLS_ON

ANIM_GREN_LOOP
	LW	GREN5,2
	LWL	GREN6,2|AFunc,A_CHECK_GREN_SCREEN_HIT
	LW	GREN7,2
	LWL	GREN1,2|AFunc,A_CHECK_GREN_SCREEN_HIT
	LW	GREN2,2
	LWL	GREN3,2|AFunc,A_CHECK_GREN_SCREEN_HIT
	LWLL	GREN4,2|AFunc,A_ONSCREEN+2,ANIM_GREN_LOOP
	LWL	1,1|AFunc,DELETE_OBJ_PROC

*
* Generic projectile screen hit
*
ANIM_PROJ_HIT
	LWL	1,1|AFunc,OBJ_CONST
ANIM_STICK_IT
	LWL	1,1|AFunc,OBJ_UNIV_TO_SCRN		;Make this stick
	LWL	1,1|AFunc,OBJ_OFF
	LWL	1,1|AFunc,OBJ_ON_WNZ
	LWLLL	1,1|AFunc,A_PROJ_CK_PHIT+4,0,-8000H
	LWL	1,2|AFunc,OBJ_CONST
	LWL	1,1|AFunc,OBJ_OFF
	LWL	1,1|AFunc,OBJ_ON_WNZ
	LWLLL	1,1|AFunc,A_PROJ_CK_PHIT+4,0,-8000H
	LWL	1,2|AFunc,OBJ_CONST
	LWL	1,1|AFunc,OBJ_OFF
	LWL	1,1|AFunc,OBJ_ON_WNZ
	LWLLL	1,1|AFunc,A_PROJ_CK_PHIT+4,0,-8000H
	LWL	1,2|AFunc,OBJ_CONST
	LWL	1,1|AFunc,OBJ_OFF
	LWL	1,1|AFunc,OBJ_ON_WNZ
	LWLLL	1,1|AFunc,A_PROJ_CK_PHIT+4,0,-8000H
	LWL	1,2|AFunc,OBJ_CONST
	LWL	1,1|AFunc,OBJ_OFF
	LWL	1,1|AFunc,OBJ_ON_WNZ
	LWLLL	1,1|AFunc,A_PROJ_CK_PHIT+4,0,-8000H
	LWL	1,1|AFunc,DELETE_OBJ

*Grenade explodes in mid-air
ANIM_GREN_EXPLODE
	LWLL	FHKEXPLOB1,3|AFunc,A_CHANGE_PAL+2,FX2
	LWL	1,1|AFunc,A_KILL_MAN_SCALE
;;	LWL	1,4|AFunc,CLR_VEL
	LW	FHKEXPLOB2,4
	LW	FHKEXPLOB3,4
	LW	FHKEXPLOB4,4
;	LW	FHKEXPLOB5,4
;	LW	FHKEXPLOB6,3
;	LW	FHKEXPLOB7,3
;	LW	FHKEXPLOB8,2
;	LW	FHKEXPLOB9,2
;	LW	FHKEXPLOB10,2
;	LW	FHKEXPLOB11,2
;;	LWL	1,1|AFunc,A_KILL_MAN_SCALE
	LWL	1,1|AFunc,DELETE_OBJ

*
* Initialize Berzerker's axe
*
AXE_INIT
	.LONG	ZAXVERT1
	.WORD	DMAWNZ, 0, OM_OID|OM_COLL|OM_GUNV|OM_ANIM|OM_CFUNC
	.WORD	OID_JUNK
	.LONG	DUMCOLL, DUMRETS, ANIM_AXE, C_AXE

*
* Animate the axe
*
ANIM_AXE
	LWL	1,1|AFunc,A_AXE_TARGET
	LWLL	ZAXVERT1,2|AFunc,A_SOUNDZ+2,SND_AXE_WHOOSH
	LW	ZAXVERT2,2
	LW	ZAXVERT3,2
	LWL	ZAXVERT4,2|AFunc,A_AXE_COLLS_ON

ANIM_AXE_LOOP
	LWLL	ZAXVERT5,2|AFunc,A_SOUNDZ+2,SND_AXE_WHOOSH
	LWL	ZAXVERT6,2|AFunc,A_CHECK_AXE_SCREEN_HIT
	LW	ZAXVERT7,2
	LWL	ZAXVERT8,2|AFunc,A_CHECK_AXE_SCREEN_HIT
	LWLL	ZAXVERT9,2|AFunc,A_SOUNDZ+2,SND_AXE_WHOOSH
	LWL	ZAXVERT10,2|AFunc,A_CHECK_AXE_SCREEN_HIT
	LW	ZAXVERT11,2
	LWL	ZAXVERT12,2|AFunc,A_CHECK_AXE_SCREEN_HIT
	LWLL	ZAXVERT1,2|AFunc,A_SOUNDZ+2,SND_AXE_WHOOSH
	LWL	ZAXVERT2,2|AFunc,A_CHECK_AXE_SCREEN_HIT
	LW	ZAXVERT3,2
	LWLL	ZAXVERT4,2|AFunc,A_ONSCREEN+2,ANIM_AXE_LOOP
	LWL	1,1|AFunc,DELETE_OBJ_PROC

*
* Axe hits the screen
*
ANIM_AXE_HIT
	LWL	ZAXVERT12,1|AFunc,A_CREATE_SCREEN_AXE
ANIM_AXE_HIT_FINISH
	LWL	1,1|AFunc,OBJ_CONST
	LWLWL	1,1|AFunc,A_Set_Rel_Long+3,OPROJECT_PARENT,0
	LWLL	1,1|AFunc,A_AnimGo+2,ANIM_STICK_IT

**************************************************************************
*								         *
* 	A_CREATE_SCREEN_NSTAR						 *
* 									 *
* 	Anim func to create the cool looking screen STAR.		 *
* 									 *
* 	A8 = Ptr old axe.						 *
*								         *
**************************************************************************
A_CREATE_SCREEN_NSTAR
	MOVI	NINJASTAR1,A1
	MOVI	ANIM_NSTAR_HIT_FINISH,A2
	JRUC	A_SCR_PROJ_G

**************************************************************************
*								         *
* 	A_CREATE_SCREEN_AXE						 *
* 									 *
* 	Anim func to create the cool looking screen axe.		 *
* 									 *
* 	A8 = Ptr old axe.						 *
*								         *
**************************************************************************
A_CREATE_SCREEN_AXE
	MOVI	ZLGAXE,A1
	MOVI	ANIM_AXE_HIT_FINISH,A2

A_SCR_PROJ_G
	MMTM	SP,A1,A2
	CALLA	CREATE_COPY
	JRZ	ACSA_X		;BR = Couldn't create it

	CALLA	DELETE_OBJ

	MOVE	A0,A8
	MOVI	1000100H,A1
	CALLA	SET_SCALEM

	ORIM	M_NOSCALE,*A8(OFLAGS),W

	MMFM	SP,A1,A2

	MOVE	*A8(OCTRL),A4,W
	CALLA	ANI

	MOVI	P_GXLAX,A0
	CALLA	CHANGE_PAL

	MOVE	A2,A1
	CALLA	STRT_ANIM
	JAUC	INSERT_OBJ

ACSA_X
	MMFM	SP,A1,A2
	RETS

*
* Axe flys away cause it was hit by a bullet
*
ANIM_AXE_FLYAWAY
	LW	ZAXVERT12,2
	LW	ZAXVERT11,2
	LW	ZAXVERT10,2
	LW	ZAXVERT9,2
	LW	ZAXVERT8,2
	LW	ZAXVERT7,2
	LW	ZAXVERT6,2
;	LW	ZAXVERT5,2
;	LW	ZAXVERT4,2
;	LW	ZAXVERT3,2
;	LW	ZAXVERT2,2
;	LW	ZAXVERT1,2
	LWL	1,1|AFunc,DELETE_OBJ_PROC

*
* Initialize Native's spear
*
NSPEAR_INIT
	.LONG	ARROW8
	.WORD	DMAWNZ, 0, OM_OID|OM_COLL|OM_GUNV|OM_ANIM|OM_CFUNC
	.WORD	OID_EROCKET
	.LONG	SPEAR_CVECT, SPEAR_GUNVECT, ANIM_SPEAR, C_SPEAR

*
* Animate the spear
*
ANIM_SPEAR
	LWL	1,1|AFunc,A_SPEAR_TARGET
	LWLL	1,15|AFunc,A_SOUNDZ+2,SND_SPEAR_COMING
	LW	ARROW9,15
	LWL	ARROW10,2|AFunc,A_CHECK_SPEAR_SCREEN_HIT
	LWL	1,2|AFunc,A_CHECK_SPEAR_SCREEN_HIT
	LWL	1,2|AFunc,A_CHECK_SPEAR_SCREEN_HIT
	LWL	1,2|AFunc,A_CHECK_SPEAR_SCREEN_HIT
	LWL	1,2|AFunc,A_CHECK_SPEAR_SCREEN_HIT
	LWL	ARROW11,2|AFunc,A_CHECK_SPEAR_SCREEN_HIT
	LWL	1,2|AFunc,A_CHECK_SPEAR_SCREEN_HIT
	LWL	1,2|AFunc,A_CHECK_SPEAR_SCREEN_HIT
	LWL	1,2|AFunc,A_CHECK_SPEAR_SCREEN_HIT
	LWL	ARROW12,2|AFunc,A_CHECK_SPEAR_SCREEN_HIT
	LWL	1,2|AFunc,A_CHECK_SPEAR_SCREEN_HIT
ANIM_SPEAR_LOOP
	LWL	1,2|AFunc,A_CHECK_SPEAR_SCREEN_HIT
	LWL	1,2|AFunc,A_CHECK_SPEAR_SCREEN_HIT
	LWLL	1,2|AFunc,A_ONSCREEN+2,ANIM_SPEAR_LOOP
	LWLL	1,1|AFunc,A_DEC_VAR_WORD+2,NUM_SPEARS
	LWL	1,1|AFunc,DELETE_OBJ_PROC

*
* Spear hits the screen
*
ANIM_SPEAR_HIT
	LWL	1,1|AFunc,OBJ_CONST
	LWLWL	1,1|AFunc,A_Set_Rel_Long+3,OPROJECT_PARENT,0
	LWLL	1,1|AFunc,A_DEC_VAR_WORD+2,NUM_SPEARS
	LWLL	1,1|AFunc,A_AnimGo+2,ANIM_STICK_IT

*
* Spear flys away cause it was hit by a bullet
*
ANIM_SPEAR_FLYAWAY
	LW	1,15
	LWL	1,1|AFunc,DELETE_OBJ_PROC


*
* Missle hits the screen
*
ANIM_MISSLE_HIT
	LWL	1,1|AFunc,OBJ_CONST
	LWLWL	1,1|AFunc,A_Set_Rel_Long+3,OPROJECT_PARENT,0
	LWLL	1,1|AFunc,A_AnimGo+2,ANIM_STICK_IT

*
* Initialize Ninja's star
*
NSTAR_INIT
	.LONG	STARQUAR01
	.WORD	DMAWNZ, M_NOPIXSCAN, OM_OID|OM_COLL|OM_GUNV|OM_ANIM|OM_CFUNC
	.WORD	OID_JUNK
	.LONG	DUMCOLL, DUMRETS, ANIM_NSTAR, C_NSTAR

*
* Animate the star
*
ANIM_NSTAR
	LWL	1,1|AFunc,A_AXE_TARGET
	LWLL	1,1|AFunc,A_INC_VAR_WORD+2,NUM_NSTARS
	LWLL	STARQUAR01,2|AFunc,A_SOUNDZ+2,SND_SPEAR_COMING
	LW	STARQUAR02,2
	LW	STARQUAR03,2
	LWL	STARQUAR04,2|AFunc,A_NSTAR_COLLS_ON

ANIM_NSTAR_LOOP
	LW	STARQUAR05,2
	LWL	STARQUAR06,2|AFunc,A_CHECK_NSTAR_SCREEN_HIT
	LW	STARQUAR07,2
	LWL	STARQUAR08,2|AFunc,A_CHECK_NSTAR_SCREEN_HIT
	LW	STARQUAR01,2
	LWL	STARQUAR02,2|AFunc,A_CHECK_NSTAR_SCREEN_HIT
	LW	STARQUAR03,2
	LWLL	STARQUAR04,2|AFunc,A_ONSCREEN+2,ANIM_NSTAR_LOOP
	LWLL	1,1|AFunc,A_DEC_VAR_WORD+2,NUM_NSTARS
	LWL	1,1|AFunc,DELETE_OBJ_PROC

*
* Nstar hits the screen
*
ANIM_NSTAR_HIT
	LWLL	1,1|AFunc,A_DEC_VAR_WORD+2,NUM_NSTARS
	LWL	1,1|AFunc,A_CREATE_SCREEN_NSTAR
ANIM_NSTAR_HIT_FINISH
	LWL	1,1|AFunc,OBJ_CONST
	LWLWL	1,1|AFunc,A_Set_Rel_Long+3,OPROJECT_PARENT,0
	LWLL	1,1|AFunc,A_AnimGo+2,ANIM_STICK_IT

*
* Ninja star flys away cause it was hit by a bullet
*
ANIM_NSTAR_FLYAWAY
	LW	STARQUAR08,2
	LW	STARQUAR07,2
	LW	STARQUAR06,2
	LW	STARQUAR05,2
	LW	STARQUAR04,2
	LW	STARQUAR03,2
	LW	STARQUAR02,2
	LW	STARQUAR01,2
	LWL	1,1|AFunc,DELETE_OBJ_PROC

REDWEAPN:
   .word   16 
   .word   00000h,01c00h,07c20h,079b2h,07a5bh,07adfh,04000h,04400h
   .word   04c00h,05000h,05800h,06000h,06400h,06c00h,07000h,07800h

**************************************************************************
*								         *
* 	A_INC_VAR_WORD							 *
* 									 *
* 	Anim func to INCrement a given variable of length word.		 *
* 									 *
* 	AARG+,L = Address of variable					 *
*								         *
**************************************************************************
A_INC_VAR_WORD
	CALLA	GETAFARG_LONG
	INCM	*A0,W
	RETS

**************************************************************************
*								         *
* 	A_DEC_VAR_WORD							 *
* 									 *
* 	Anim func to decrement a given variable of length word.		 *
* 									 *
* 	AARG+,L = Address of variable					 *
*								         *
**************************************************************************
A_DEC_VAR_WORD
	CALLA	GETAFARG_LONG
	DECM	*A0,W
	RETS

**************************************************************************
*								         *
* 	A_STAY_TIL_TRUE							 *
* 									 *
* 	Anim func to stay until a given Word variable is true.		 *
* 									 *
* 	AARG+,L = Address of variable					 *
*								         *
**************************************************************************
A_STAY_TIL_TRUE
	CALLA	GETAFARG_LONG
	MOVE	*A0,A14,W
	JRNZ	ASTT_X			;BR = Variable is true
	MOVE	*A8(AnimFrm),A14,L	; otherwise, stay here
	SUBI	70h,A14
	MOVE	A14,*A8(AnimFrm),L
ASTT_X
	RETS

*
* Some Mondor fire
*
INIT_POD_FIRE
	.LONG	HFIREA1
	.WORD	DMAWNZ, M_DEAD|M_NOPARTANI|M_OPARTSXY, OM_ANIM
	.LONG	ANIM_POD_FIRE

ANIM_POD_FIRE
	LWLW	1,1|AFunc,A_Set_AnimLoop+1,4
ANIM_PF_LOOP
	LW	HFIREA1,4
	LW	HFIREA2,4
	LW	HFIREA3,4
	LW	HFIREA4,4
	LW	HFIREA5,4
	LW	HFIREA6,3
	LWLL	1,1|AFunc,A_Anim_DSJ+2,ANIM_PF_LOOP
	LWL	1,1|AFunc,DELETE_OBJ
	.LONG	0

*
*Josh morphing. Everything up to the final frame
*
MORF_TICK	.EQU	5

ANIM_JOSH_MORPH
	LWLL	1,1|AFunc,A_STAY_TIL_TRUE+2,MONDOR_START_FLAG

	LWLLW	1,5|AFunc,A_Set_Var_Word+3,GUNS_OFF,1

	LWL	1,1|AMulti|AFunc,OBJ_ON
	LWL	1,1|AMulti|AFunc,OBJ_ON
	LWL	1,1|AMulti|AFunc,OBJ_ON
	LWL	1,1|AMulti|AFunc,OBJ_ON
	LWL	1,1|AMulti|AFunc,OBJ_ON
	LWL	1,MORF_TICK|AFunc,A_MAKE_MORPH_SND

	LW	HELMON1_02A,1|AMulti
	LW	HELMON1_02B,1|AMulti
	LW	HELMON1_02C,1|AMulti
	LW	HELMON1_02D,1|AMulti
	LW	HELMON1_02E,MORF_TICK

	LW	HELMON1_03A,1|AMulti
	LW	HELMON1_03B,1|AMulti
	LW	HELMON1_03C,1|AMulti
	LW	HELMON1_03D,1|AMulti
	LW	HELMON1_03E,MORF_TICK

	LW	HELMON1_04A,1|AMulti
	LW	HELMON1_04B,1|AMulti
	LW	HELMON1_04C,1|AMulti
	LW	HELMON1_04D,1|AMulti
	LW	HELMON1_04E,MORF_TICK

	LW	HELMON1_05A,1|AMulti
	LWLLLL	HELMON1_05B,1|AMulti|AFunc,A_PreFrag_Center+6,FRAG_JOSH_SUIT_UL,400h,60000h
	LWLLLL	HELMON1_05C,1|AMulti|AFunc,A_PreFrag_Center+6,FRAG_JOSH_SHIRT,400h,60000h
	LWLLLL	HELMON1_05D,1|AMulti|AFunc,A_PreFrag_Center+6,FRAG_JOSH_SUIT_UR,400h,60000h
	LWL	HELMON1_05E,1|AMulti|AFunc,OBJ_ON
	LWL	HELMON1_05F,1|AMulti|AFunc,OBJ_ON
	LWL	HELMON1_05G,MORF_TICK|AFunc,OBJ_ON

	LW	HELMON1_06FA,1|AMulti
	LW	HELMON1_06FB,1|AMulti
	LW	HELMON1_06FC,1|AMulti
	LW	HELMON1_06FD,1|AMulti
	LW	HELMON1_06FE,1|AMulti
	LWW	HELMON1_06FA,1|AMulti|AFlip,M_FLIPH
	LWW	HELMON1_06FB,1|AMulti|AFlip,M_FLIPH
	LWWL	HELMON1_06FC,1|AMulti|AFlip|AFunc,M_FLIPH,OBJ_ON
	LWWL	HELMON1_06FD,1|AMulti|AFlip|AFunc,M_FLIPH,OBJ_ON
	LWWL	HELMON1_06FE,MORF_TICK|AFlip|AFunc,M_FLIPH,OBJ_ON

	LW	HELMON1_07FA,1|AMulti
	LW	HELMON1_07FB,1|AMulti
	LW	HELMON1_07FC,1|AMulti
	LW	HELMON1_07FD,1|AMulti
	LW	HELMON1_07FE,1|AMulti
	LW	HELMON1_07FA,1|AMulti
	LW	HELMON1_07FB,1|AMulti
	LW	HELMON1_07FC,1|AMulti
	LW	HELMON1_07FD,1|AMulti
	LW	HELMON1_07FE,MORF_TICK

	LW	HELMON1_08FA,1|AMulti
	LW	HELMON1_08FB,1|AMulti
	LW	HELMON1_08FC,1|AMulti
	LW	HELMON1_08FD,1|AMulti
	LW	HELMON1_08FE,1|AMulti
	LW	HELMON1_08FA,1|AMulti
	LW	HELMON1_08FB,1|AMulti
	LW	HELMON1_08FC,1|AMulti
	LW	HELMON1_08FD,1|AMulti
	LW	HELMON1_08FE,MORF_TICK

;	LWLWW	HELMON1_09FA,1|AMulti|AFunc,A_Set_Rel_Word_Head+2,OYACCEL,-1000H
	LW	HELMON1_09FA,1|AMulti
	LW	HELMON1_09FB,1|AMulti
	LW	HELMON1_09FC,1|AMulti
	LW	HELMON1_09FD,1|AMulti
	LW	HELMON1_09FE,1|AMulti
	LW	HELMON1_09FA,1|AMulti
	LW	HELMON1_09FB,1|AMulti
	LW	HELMON1_09FC,1|AMulti
	LW	HELMON1_09FD,1|AMulti
	LW	HELMON1_09FE,MORF_TICK-1

	LWLL	1,1|AFunc,A_AnimFrm+2,ANIM_MORPH_FINISH

**************************************************************************
*								         *
* 		More Sounds for Mondor					 *
*								         *
**************************************************************************

SND_MONDOR_GUN
	.WORD	0E320H,10,0A108H,0	;Mondor fires upon your ass
SND_PART_EXPLODE
	.WORD	0F341H,60,0A38DH,0	;Explosion used by much
SND_FIRE_BALL
	.WORD	0F342H,44,08292H,0	;FireBall being launched
SND_FIRE_HISS
	.WORD	0F340H,36,0A396H,0	;FireBall hissing
SND_FB_HIT_SCRN
	.WORD	0F341H,60,0A393H,0	;FireBall hits the screen

SND_GREN_THROW
	.WORD	0F342H,73,0A1A6H,0	;Sound of a Grenade being thrown
SND_GREN_HIT_SCRN
	.WORD	0F342H,60,0A390H,0	;Grenade hits the screen
SND_GREN_EXPLODE
	.WORD	0F341H,80,0A38DH,0	;Grenade blows up in mid-air

SND_AXE_WHOOSH
	.WORD	0F342H,15,0A489H,0	;Sound of an axe being thrown
SND_AXE_HIT_SCRN
	.WORD	0F342H,71,0A48CH,0	;Axe hits the screen
SND_AXE_FLY
	.WORD	0F342H,62,0A1A3H,0	;Axe gets blown back

SND_SPEAR_FLY
	.WORD	0F342H,62,0A1A3H,0	;Spear gets blown out of the air
SND_SPEAR_HIT_SCRN
	.WORD	0F343H,67,0A48Fh,0
SND_SPEAR_COMING
	.WORD	0F342H,46,0A41AH,0

SND_PROJECTILE_FLY
	.WORD	0F141H,62,0A1A1H,0	;Projectile gets blown back

SND_GUN_BOUNCE
	.WORD	0F304H,19,0A3A0H,0	;Gun bounces off of the ground

SND_RIP_HEAD
	.WORD	0E344H,133,0828EH,0	;"I'll rip your head off! For that."
SND_SUSHI
	.WORD	0E3D1H,89,08290H,0	;"Ahhh Sushi"
SND_TAKE_THAT
	.WORD	0E342H,49,0828DH,0	;"Take that"
SND_CMON
	.WORD	0E342H,102,0828CH,0	;"C'mon! Whaddya, scared?"
SND_PRAY
	.WORD	0E342H,108,0829DH,0	;"Pray for a fast death"
SND_NIGHT
	.WORD	0E342H,131,0829BH,0	;"I'm your worst nightmare."
SND_DEVOUR
	.WORD	0E342H,109,082A5H,0	;"I will devour you."
SND_NOTHING
	.WORD	0E342H,99,082A2H,0	;"You are nothing."
SND_LAUGH
	.WORD	0E342H,82,08291H,0	;Mondor laughs
SND_FLESH_WOUND
	.WORD	0E344H,90,08287H,0	;"It's only a flesh wound."
SND_BOOM
	.WORD	0E342H,46,0828AH,0	;"Boom!"
SND_GUTS_SOY
	.WORD	0E342H,131,0828FH,0	;"I'll eat your guts with soy sauce!"
SND_COWARD
	.WORD	0E342H,59,0829EH,0	;"Coward"
SND_MOMMY
	.WORD	0E342H,113,0829FH,0	;"Go on, run to mommy"
SND_MONDOR
	.WORD	0E342H,84,082A0H,0	;"I am Mondor!"
SND_DONE
	.WORD	0E342H,69,082A1H,0	;"You are done!"
SND_KAMIKAZE
	.WORD	0E343H,95,082A4H,0	;Kamikaze scream
SND_WORSE
	.WORD	0E344H,63,082A7H,0	;"I've had worse"
SND_GETUP
	.WORD	0E344H,78,082A3H,0	;"Don't make me get up"
SND_MORE
	.WORD	0E342H,86,08299H,0	;"Back for more, huh?"

SND_MORPH2
	.WORD	0E24AH,95,0832FH,0	;Josh morphs into Mondor TRACK 2
SND_MORPH3
	.WORD	0E34AH,95,08330H,0	;Josh morphs into Mondor TRACK 3
	

TAB_BLOOD_SPLAT
	.LONG	SND_BLOOD_SPLAT1, SND_BLOOD_SPLAT2, SND_BLOOD_SPLAT3

SND_BLOOD_SPLAT1
	.WORD	0E300H,10,0A1A9H,0	;Blood drops #1
SND_BLOOD_SPLAT2
	.WORD	0E300H,10,0A1ACH,0	;Blood drops #2
SND_BLOOD_SPLAT3
	.WORD	0E300H,11,0A1AFH,0	;Blood drops #3

**************************************************************************
*								         *
* 			Talk Scripts					 *
* 			------------					 *
* 									 *
* 	Talk scripts are used to give the talk animation it's		 *
* 	counts so that it can sync to the given speech.			 *
* 									 *
* 	A script looks like this:					 *
* 									 *
* 	.BYTE	syllable_count, intial_pause				 *
* 	.LONG	sound_script1						 *
* 	.BYTE	syllable1_open_time, syllable1_close_time		 *
* 		.							 *
* 		.							 *
* 		.							 *
* 	.LONG	sound_scriptN						 *
* 	.BYTE	syllableN_open_time, syllableN_close_time		 *
*								         *
**************************************************************************
TALK_SCRIPTS
	.LONG	TSCRIPT_TAKE_THAT, TSCRIPT_SUSHI, TSCRIPT_RIP_HEAD
	.LONG	TSCRIPT_LAUGH, TSCRIPT_CMON, TSCRIPT_PRAY
	.LONG	TSCRIPT_NIGHT, TSCRIPT_DEVOUR, TSCRIPT_NOTHING
	.LONG	TSCRIPT_FLESH_WOUND, TSCRIPT_BOOM, TSCRIPT_GUTS_SOY
	.LONG	TSCRIPT_COWARD, TSCRIPT_MOMMY, TSCRIPT_MONDOR, TSCRIPT_DONE
	.LONG	TSCRIPT_WORSE, TSCRIPT_GETUP, TSCRIPT_MORE

TSCRIPT_TAKE_THAT
	.BYTE	2,40
	.LONG	SND_TAKE_THAT
	.BYTE	14,6
	.BYTE	20,1
	.EVEN

TSCRIPT_SUSHI
	.BYTE	3,10
	.LONG	SND_SUSHI
	.BYTE	30,22
	.BYTE	10,3
	.BYTE	10,1
	.EVEN

TSCRIPT_RIP_HEAD
	.BYTE	7,60
	.LONG	SND_RIP_HEAD
	.BYTE	13,8
	.BYTE	10,5
	.BYTE	15,6
	.BYTE	11,4
	.BYTE	15,8
	.BYTE	12,4
	.BYTE	15,1
	.EVEN

TSCRIPT_LAUGH
	.BYTE	6,10
	.LONG	SND_LAUGH
	.BYTE	2,2
	.BYTE	18,2
	.BYTE	12,2
	.BYTE	12,2
	.BYTE	12,2
	.BYTE	18,2

TSCRIPT_PRAY
	.BYTE	5,10
	.LONG	SND_PRAY
	.BYTE	20,4
	.BYTE	10,4
	.BYTE	6,4
	.BYTE	15,12
	.BYTE	16,1

TSCRIPT_NIGHT
	.BYTE	5,10
	.LONG	SND_NIGHT
	.BYTE	13,18
	.BYTE	18,6
	.BYTE	18,12
	.BYTE	18,7
	.BYTE	25,1

TSCRIPT_DEVOUR
	.BYTE	6,10
	.LONG	SND_DEVOUR
	.BYTE	10,4
	.BYTE	12,6
	.BYTE	10,4
	.BYTE	10,4
	.BYTE	8,4
	.BYTE	14,1
	
TSCRIPT_NOTHING
	.BYTE	4,10
	.LONG	SND_NOTHING
	.BYTE	19,4
	.BYTE	22,6
	.BYTE	12,5
	.BYTE	16,1

TSCRIPT_FLESH_WOUND
	.BYTE	5,60
	.LONG	SND_FLESH_WOUND
	.BYTE	10,4
	.BYTE	10,4
	.BYTE	10,2
	.BYTE	16,4
	.BYTE	16,1

TSCRIPT_BOOM
	.BYTE	1,10
	.LONG	SND_BOOM
	.BYTE	21,1
	
TSCRIPT_CMON
	.BYTE	5,10
	.LONG	SND_CMON
	.BYTE	5,2
	.BYTE	24,4
	.BYTE	10,2
	.BYTE	15,6
	.BYTE	30,1

TSCRIPT_GUTS_SOY	
	.BYTE	7,10
	.LONG	SND_GUTS_SOY
	.BYTE	12,6
	.BYTE	10,3
	.BYTE	10,4
	.BYTE	12,4
	.BYTE	12,6
	.BYTE	16,4
	.BYTE	18,1

TSCRIPT_COWARD
	.BYTE	2,10
	.LONG	SND_COWARD
	.BYTE	11,4
	.BYTE	32,1

TSCRIPT_MOMMY
	.BYTE	6,30
	.LONG	SND_MOMMY
	.BYTE	12,3
	.BYTE	20,14
	.BYTE	12,4
	.BYTE	12,4
	.BYTE	10,3
	.BYTE	16,1

TSCRIPT_MONDOR
	.BYTE	4,10
	.LONG	SND_MONDOR
	.BYTE	12,4
	.BYTE	10,6
	.BYTE	14,6
	.BYTE	18,1

TSCRIPT_DONE
	.BYTE	3,1
	.LONG	SND_DONE
	.BYTE	18,5
	.BYTE	14,6
	.BYTE	12,1

TSCRIPT_WORSE
	.BYTE	3,60
	.LONG	SND_WORSE
	.BYTE	10,5
	.BYTE	12,6
	.BYTE	12,6

TSCRIPT_GETUP
	.BYTE	5,60
	.LONG	SND_GETUP
	.BYTE	12,5
	.BYTE	11,5
	.BYTE	8,4
	.BYTE	10,4
	.BYTE	11,1

TSCRIPT_MORE
	.BYTE	4,60
	.LONG	SND_MORE
	.BYTE	8,9
	.BYTE	11,8
	.BYTE	15,8
	.BYTE	15,1

**************************************************************************
*								         *
* 		Fragger Scripts						 *
*								         *
**************************************************************************

**************************************************************************
*								         *
* F_CHUNK - Frag Func for MONDOR chunk.					 *
* A0 = Ptr to un-inserted object.					 *
* 									 *
* Note: Frag funcs must preserve A8-A11 and all B-File regs.		 *
*								         *
**************************************************************************
F_CHUNK
;	MOVE	*A0(OZVEL),A14,L
;	ABS	A14
;	NEG	A14
;	MOVE	A14,*A0(OZVEL),L
	MOVIM	MCHUNK_COLL,*A0(OCVECT),L	;Set up chunk with Vectors	
	RETS

**************************************************************************
*								         *
* F_CHUNK_FINAL - Frag Func for MONDOR chunk participating in the final	 *
* 		Mondor explosion.					 *
* A0 = Ptr to un-inserted object.					 *
* 									 *
* Note: Frag funcs must preserve A8-A11 and all B-File regs.		 *
*								         *
**************************************************************************
F_CHUNK_FINAL
	MOVE	*A0(OZVEL),A14,L
	ABS	A14
	NEG	A14
	MOVE	A14,*A0(OZVEL),L
	MOVIM	MCHUNK_COLL,*A0(OCVECT),L	;Set up chunk with Vectors	
	RETS

**************************************************************************
*								         *
* 	F_JOSH_CHUNK_UR							 *
* 									 *
* 	Frag func for Josh shirt/suit chunks that go up and right.	 *
* 									 *
* 	A0 = Ptr to un-inserted chunk					 *
* 									 *
* 	Note: Frag funcs must preserve A8-A11 and all B-file regs.	 *
*								         *
**************************************************************************
F_JOSH_CHUNK_UR
	MOVE	*A0(OXVEL),A14,L
	ABS	A14
	MOVE	A14,*A0(OXVEL),L
	JRUC	F_JOSH_CHUNK

**************************************************************************
*								         *
* 	F_JOSH_CHUNK_UL							 *
* 									 *
* 	Frag func for Josh shirt/suit chunks that go up and left.	 *
* 									 *
* 	A0 = Ptr to un-inserted chunk					 *
* 									 *
* 	Note: Frag funcs must preserve A8-A11 and all B-file regs.	 *
*								         *
**************************************************************************
F_JOSH_CHUNK_UL
	MOVE	*A0(OXVEL),A14,L
	ABS	A14
	NEG	A14
	MOVE	A14,*A0(OXVEL),L
	JRUC	F_JOSH_CHUNK

**************************************************************************
*								         *
* 	F_JOSH_CHUNK							 *
* 									 *
* 	Frag func for Josh shirt/suit chunks.				 *
* 									 *
* 	A0 = Ptr to un-inserted chunk					 *
* 									 *
* 	Note: Frag funcs must preserve A8-A11 and all B-file regs.	 *
*								         *
**************************************************************************
F_JOSH_CHUNK
	MOVE	*A0(OYVEL),A14,L
	ABS	A14
	NEG	A14
	MOVE	A14,*A0(OYVEL),L

	MOVIM	JCHUNK_COLL,*A0(OCVECT),L	;Set up chunk with Vectors	
	RETS

**************************************************************************
*								         *
* JOSH CHUNK Collision Vector Table					 *
* 									 *
*								         *
**************************************************************************
JCHUNK_COLL
	WWL	OID_GRND,0FFFFH,MCGC_DEL
	WL	0,DUMCRETS

**************************************************************************
*								         *
* MONDOR CHUNK Collision Vector Table					 *
* 									 *
*								         *
**************************************************************************
MCHUNK_COLL
	WWL	OID_GRND,0FFFFH,MCHUNK_GROUND_COLL
	WL	0,DUMCRETS

**************************************************************************
*								         *
* MCHUNK_GROUND_COLL - Collision routine for MONDOR CHUNK.		 *
* A8 = Ptr Chunk Object							 *
*								         *
**************************************************************************
MCHUNK_GROUND_COLL
	MOVB	*A8(OFLAGS),A14		;Are we out of Range?
	JRN	MCGC_DEL		;BR = Yes

	MOVE	*A8(OYVEL),A14,L
	MOVE	A14,A1
	SRA	1,A14			;Knock off 25% for the bounce.
	SUB	A14,A1
	CMPI	4000H,A1		;Have we hit the minimum?
	JRLE	MCGC_DEL		;BR = Yes, delete the object.
;	CMPI	40000H,A1		;Will it bounce too high?
;	JRLE	MCGC_BOUNCE		;BR = No, let it bounce.
;	MOVI	40000H,A1		;Cap the rebound velocity
MCGC_BOUNCE
       	NEG	A1			;Turn it up
	MOVE	A1,*A8(OYVEL),L
	RETS
MCGC_DEL	
	JAUC	DELETE_OBJ

**************************************************************************
*								         *
* 	F_BLOOD_GLOB							 *
* 									 *
* 	Fragment init function for blood (global).			 *
* 									 *
* 	A0 = Ptr to un-inserted blood object.				 *
*								         *
**************************************************************************
F_BLOOD_GLOB
	MOVIM	BLOOD_DROP_CVECT,*A0(OCVECT),L	;Set up blood vectors
	RETS

**************************************************************************
*								         *
* 	GLOOD_PAL							 *
* 									 *
* 	Change blood objects palette to green.  To be used with		 *
* 	create funcs.							 *
* 									 *
* 	A0 = Ptr to uninserted object					 *
*								         *
**************************************************************************
GLOOD_PAL
	MMTM	SP,A0,A8
	MOVE	A0,A8
	MOVI	GLOOD_P,A0
	CALLA	CHANGE_PAL
	MMFM	SP,A0,A8
	RETS

**************************************************************************
*								         *
* 	F_BLOOD								 *
* 									 *
* 	Fragment init function for blood.				 *
* 									 *
* 	A0 = Ptr to un-inserted blood object.				 *
*								         *
**************************************************************************
F_BLOOD
	MOVE	@VIOLENCE_LEVEL,A14,W
	DEC	A14
	JRP	FB_RED
	CALLR	GLOOD_PAL	
FB_RED
	MOVIM	BLOOD_DROP_CVECT,*A0(OCVECT),L	;Set up blood vectors
	RETS

**************************************************************************
*								         *
* 	F_BLOOD_FINAL							 *
* 									 *
* 	Fragment init function for blood participating in the final	 *
* 	Mondor explosion.						 *
* 									 *
* 	A0 = Ptr to un-inserted blood object.				 *
*								         *
**************************************************************************
F_BLOOD_FINAL
	MOVE	@VIOLENCE_LEVEL,A14,W
	DEC	A14
	JRP	FBF_RED
	CALLR	GLOOD_PAL	
FBF_RED
	MOVE	*A0(OZVEL),A14,L
	ABS	A14
	NEG	A14
	MOVE	A14,*A0(OZVEL),L
	MOVIM	BLOOD_DROP_CVECT,*A0(OCVECT),L	;Set up blood vectors
	RETS

**************************************************************************
*								         *
* 	F_CHUNK_UP					   		 *
* 									 *
* 	Fragment init function for chunk to go straight up.		 *
* 									 *
* 	A0 = Ptr to un-inserted chunk object.				 *
*								         *
**************************************************************************
F_CHUNK_UP
	MOVIM	MCHUNK_COLL,*A0(OCVECT),L	;Set up chunk with Vectors	
	JRUC	F_UP_THE_BUTT

**************************************************************************
*								         *
* 	F_BLOOD_UP					   		 *
* 									 *
* 	Fragment init function for blood to go straight up.		 *
* 									 *
* 	A0 = Ptr to un-inserted blood object.				 *
*								         *
**************************************************************************
F_BLOOD_UP
	MOVE	@VIOLENCE_LEVEL,A14,W
	DEC	A14
	JRP	FBU_RED
	CALLR	GLOOD_PAL	
FBU_RED
	MOVIM	BLOOD_DROP_CVECT,*A0(OCVECT),L	;Set up blood vectors
	JRUC	F_UP_THE_BUTT

F_UP_THE_BUTT
	MMTM	SP,A0,A1
	MOVI	-100000H,A0
	MOVI	-080000H,A1
	CALLA	RANGERND
	MOVE	A0,A14
	MMFM	SP,A0,A1
	MOVE	A14,*A0(OYVEL),L	
	MOVE	*A0(OXVEL+16),A14,W
	CMPK	1,A14
	JRLE	FBU_LOWX
	MOVK	1,A14
	JRUC	FBU_FINISHX
FBU_LOWX
	CMPI	-1,A14
	JRGE	FBU_XOK
	MOVK	1,A14	
	NEG	A14
FBU_FINISHX
	MOVE	A14,*A0(OXVEL+16),W
FBU_XOK	
	RETS

**************************************************************************
*								         *
* 	F_CHUNK_RAIN					   		 *
* 									 *
* 	Fragment init function for raining chunk.			 *
* 									 *
* 	A0 = Ptr to un-inserted chunk object.				 *
*								         *
**************************************************************************
F_CHUNK_RAIN
	MOVIM	MCHUNK_COLL,*A0(OCVECT),L	;Set up chunk with Vectors	
	JRUC	F_RAIN_MAN

**************************************************************************
*								         *
* 	F_BLOOD_RAIN					   		 *
* 									 *
* 	Fragment init function for raining blood.			 *
* 									 *
* 	A0 = Ptr to un-inserted blood object.				 *
*								         *
**************************************************************************
F_BLOOD_RAIN
	MOVE	@VIOLENCE_LEVEL,A14,W
	DEC	A14
	JRP	FBR_RED
	CALLR	GLOOD_PAL	
FBR_RED
	MOVIM	BLOOD_DROP_CVECT,*A0(OCVECT),L	;Set up blood vectors
	JRUC	F_RAIN_MAN

F_RAIN_MAN
	MMTM	SP,A0,A1
	MOVI	-100000H,A0
	MOVI	-080000H,A1
	CALLA	RANGERND
	MOVE	A0,A14
	MMFM	SP,A0,A1
	MOVE	A14,*A0(OYVEL),L
	CLRM	*A0(OXVEL),L

	RETS

**************************************************************************
*								         *
* 			Blood stuff -- OOO Scary!			 *
*								         *
**************************************************************************

**************************************************************************
*								         *
* 	A_INIT_BLOOD_DROP						 *
* 									 *
* 	Anim Func to initialize the blood drop created by the spurt.	 *
* 									 *
* 	A8 = Ptr to spurt about to become a drop.			 *
*								         *
**************************************************************************
A_INIT_BLOOD_DROP
	MOVIM	20000H,*A8(OYVEL),L
	MOVI	20000H,A1
	MOVE	*A8(OCTRL),A14,W
	BTST	B_FLIPH,A14
	JRNZ	AIBD_ADDX
	NEG	A1
AIBD_ADDX
	ADDRM	A1,*A8(OXVEL),L
	ORIM	M_GCOLL,*A8(OFLAGS),W
	MOVIM	BLOOD_CVECT,*A8(OCVECT),L
	RETS

**************************************************************************
*								         *
* 	A_BLOOD_SOUND							 *
* 									 *
* 	Anim func to determine if we need to make a blood		 *
* 	splat sound.							 *
* 									 *
* 	A8 = Ptr to object						 *
* 	AARG+,L = Table of sound calls					 *
* 	AARG+,W	= # of sound calls in table				 *
*								         *
**************************************************************************
A_BLOOD_SOUND
	MOVB	*A8(OFLAGS),A14		;Are we onscreen?
	JANN	A_TAB_SOUNDZ		;BR = Yes
	RETS

**************************************************************************
*								         *
* MONDOR Blood Drop Collision Vector Table				 *
* 									 *
*								         *
**************************************************************************
BLOOD_DROP_CVECT
;	WWL	OID_GRND,0FFFFH,BLOOD_DROP_GROUND_COLL
	WWL	OID_GRND,0FFFFH,BLOOD_GROUND_COLL
	WL	0,DUMCRETS

**************************************************************************
*								         *
* BLOOD_DROP_GROUND_COLL - Collision routine for MONDOR blood.		 *
* A8 = Ptr blood Object							 *
*								         *
**************************************************************************
BLOOD_DROP_GROUND_COLL
	MOVIM	DUMCOLL,*A8(OCVECT),L
	ANDNIM	M_GCOLL,*A8(OFLAGS),W
	CALLA	CLR_VEL
	CLR	A3
	MOVI	BLOOD_SPLAT_INIT,A5
	JRUC	SPAWN_BLOOD


**************************************************************************
*								         *
* MONDOR Blood spray Collision Vector Table				 *
* 									 *
*								         *
**************************************************************************
BLOOD_CVECT
	WWL	OID_GRND,0FFFFH,BLOOD_GROUND_COLL
	WL	0,DUMCRETS

**************************************************************************
*								         *
* BLOOD_GROUND_COLL - Collision routine for MONDOR blood.		 *
* A8 = Ptr blood Object							 *
*								         *
**************************************************************************
BLOOD_GROUND_COLL
	MOVIM	DUMCOLL,*A8(OCVECT),L
	ANDNIM	M_GCOLL,*A8(OFLAGS),W
	CALLA	CLR_VEL
	MOVE	*A8(OPARTSXY),A5,L		;Must compensate for OPARTS
	JRNZ	BLOOD_SPRAY_DROP
	CLR	A3
	JRUC	BLOOD_DO_SPLAT
BLOOD_SPRAY_DROP
	MOVI	[18,-130],A3			;This is the real offset
	MOVE	*A8(OCTRL),A14
	BTST	B_FLIPH,A14			;Is this blood flipped?
	JRZ	BGC_NOXFLIP			;BR = No, do nothing
	NEGX	A5
BGC_NOXFLIP
	SUBXY	A5,A3				;Offset for OPARTS
BLOOD_DO_SPLAT
	MOVE	*A8(OPAL),A0,W
	CALLA	GET_PALID
	CMPI	P_BLOODGR,A0
	JRNE	BGC_NORMAL

	MOVI	GOO_SPLAT_INIT,A5
	JRUC	SPAWN_BLOOD

BGC_NORMAL
	MOVI	BLOOD_SPLAT_INIT,A5
	JRUC	SPAWN_BLOOD

BLOOD_SPLAT_INIT
	.LONG	BLOOD_SPLAT_1,DUMCOLL
	.WORD	OID_JUNK,DMAWNZ,M_DEAD|M_NOPARTANI|M_OPARTSXY,-1
	.LONG	C_GREEN_STRTANIM,GLOOD_P,ANIM_BLOOD_SPLAT

GOO_SPLAT_INIT
	.LONG	GOO_SPLAT_1,DUMCOLL
	.WORD	OID_JUNK,DMAWNZ,M_DEAD|M_NOPARTANI|M_OPARTSXY,-1
	.LONG	C_STRTANIM,ANIM_BLOOD_SPLAT

ANIM_BLOOD_SPLAT
	LWL	BLOOD_SPLAT_1,1|AFunc,A_HEAD_OBJOFF
	LWLLW	1,2|AFunc,A_BLOOD_SOUND+3,TAB_BLOOD_SPLAT,3
	LW	BLOOD_SPLAT_2,3
	LW	BLOOD_SPLAT_3,3
	LW	BLOOD_SPLAT_4,3
	LW	BLOOD_SPLAT_5,3
	LW	BLOOD_SPLAT_6,3
	LWL	1,1|AFunc,A_DELETE_MULTI

*
*Table for random pick of single chunks
*
;SINGLE_CHUNK_TAB
;	.LONG	MONDOR_CHUNK_A,MONDOR_CHUNK_B,MONDOR_CHUNK_C

*
*Table for random pick of multi chunks
*
MULTI_CHUNK_TAB
	.LONG	MONDOR_CHUNK_MULTI_A,MONDOR_CHUNK_MULTI_B,MONDOR_CHUNK_MULTI_C
	.LONG	MONDOR_CHUNK_MULTI_D

*
*Give a little piece of Mondor
*
;MONDOR_CHUNK_A
;	.long	CHUNK_A,F_CHUNK
;	.word	OID_JUNK,1*800H+1*40H+FRGPAL+FRGGCOL

;	.long	0

MONDOR_CHUNK_MULTI_A
	.long	CHUNK_A,F_CHUNK
	.word	OID_JUNK,5*800H+1*40H+FRGPAL+FRGGCOL

	.long	CHUNK_BLOOD,F_BLOOD
	.word	OID_JUNK,8*800H+6*40H+FRGPAL+FRGGCOL+FRGNOFLP+FRGRND

	.long	CHUNK_B,F_CHUNK
	.word	OID_JUNK,5*800H+1*40H+FRGPAL+FRGGCOL

	.long	CHUNK_BLOOD,F_BLOOD
	.word	OID_JUNK,8*800H+15*40H+FRGPAL+FRGGCOL+FRGNOFLP+FRGRND

	.long	CHUNK_C,F_CHUNK
	.word	OID_JUNK,5*800H+1*40H+FRGPAL+FRGGCOL

	.long	CHUNK_BLOOD,F_BLOOD
	.word	OID_JUNK,8*800H+1*40H+FRGPAL+FRGGCOL+FRGNOFLP+FRGRND
	.long	0


;MONDOR_CHUNK_B
;	.long	CHUNK_B,F_CHUNK
;	.word	OID_JUNK,1*800H+1*40H+FRGPAL+FRGGCOL

;	.long	0

MONDOR_CHUNK_MULTI_B
	.long	CHUNK_B,F_CHUNK
	.word	OID_JUNK,5*800H+1*40H+FRGPAL+FRGGCOL

	.long	CHUNK_BLOOD,F_BLOOD
	.word	OID_JUNK,8*800H+6*40H+FRGPAL+FRGGCOL+FRGNOFLP+FRGRND

	.long	CHUNK_D,F_CHUNK
	.word	OID_JUNK,5*800H+1*40H+FRGPAL+FRGGCOL

	.long	CHUNK_BLOOD,F_BLOOD
	.word	OID_JUNK,8*800H+15*40H+FRGPAL+FRGGCOL+FRGNOFLP+FRGRND

	.long	CHUNK_C,F_CHUNK
	.word	OID_JUNK,5*800H+1*40H+FRGPAL+FRGGCOL

	.long	CHUNK_BLOOD,F_BLOOD
	.word	OID_JUNK,8*800H+1*40H+FRGPAL+FRGGCOL+FRGNOFLP+FRGRND
	.long	0

;MONDOR_CHUNK_C
;	.long	CHUNK_C,F_CHUNK
;	.word	OID_JUNK,1*800H+1*40H+FRGPAL+FRGGCOL

;	.long	0

MONDOR_CHUNK_MULTI_C
	.long	CHUNK_C,F_CHUNK
	.word	OID_JUNK,5*800H+1*40H+FRGPAL+FRGGCOL

	.long	CHUNK_BLOOD,F_BLOOD
	.word	OID_JUNK,8*800H+6*40H+FRGPAL+FRGGCOL+FRGNOFLP+FRGRND

	.long	CHUNK_A,F_CHUNK
	.word	OID_JUNK,5*800H+1*40H+FRGPAL+FRGGCOL

	.long	CHUNK_BLOOD,F_BLOOD
	.word	OID_JUNK,8*800H+15*40H+FRGPAL+FRGGCOL+FRGNOFLP+FRGRND

	.long	CHUNK_D,F_CHUNK
	.word	OID_JUNK,5*800H+1*40H+FRGPAL+FRGGCOL

	.long	CHUNK_BLOOD,F_BLOOD
	.word	OID_JUNK,8*800H+1*40H+FRGPAL+FRGGCOL+FRGNOFLP+FRGRND
	.long	0

MONDOR_CHUNK_MULTI_D
	.long	CHUNK_D,F_CHUNK
	.word	OID_JUNK,5*800H+1*40H+FRGPAL+FRGGCOL

	.long	CHUNK_BLOOD,F_BLOOD
	.word	OID_JUNK,8*800H+6*40H+FRGPAL+FRGGCOL+FRGNOFLP+FRGRND

	.long	CHUNK_B,F_CHUNK
	.word	OID_JUNK,5*800H+1*40H+FRGPAL+FRGGCOL

	.long	CHUNK_BLOOD,F_BLOOD
	.word	OID_JUNK,8*800H+15*40H+FRGPAL+FRGGCOL+FRGNOFLP+FRGRND

	.long	CHUNK_A,F_CHUNK
	.word	OID_JUNK,5*800H+1*40H+FRGPAL+FRGGCOL

	.long	CHUNK_BLOOD,F_BLOOD
	.word	OID_JUNK,8*800H+1*40H+FRGPAL+FRGGCOL+FRGNOFLP+FRGRND
	.long	0
*
*Piece of Mondor's shirt
*
MONDOR_SHIRT_MULTI
	.long	CHUNK_SHIRT,F_CHUNK
	.word	OID_JUNK,2*800H+1*40H+FRGPAL+FRGGCOL

	.long	CHUNK_D,F_CHUNK
	.word	OID_JUNK,3*800H+1*40H+FRGPAL+FRGGCOL

	.long	CHUNK_BLOOD,F_BLOOD
	.word	OID_JUNK,8*800H+3*40H+FRGPAL+FRGGCOL+FRGNOFLP+FRGRND

	.long	CHUNK_SHIRT,F_CHUNK
	.word	OID_JUNK,2*800H+1*40H+FRGPAL+FRGGCOL

	.long	CHUNK_C,F_CHUNK
	.word	OID_JUNK,3*800H+1*40H+FRGPAL+FRGGCOL

	.long	CHUNK_BLOOD,F_BLOOD
	.word	OID_JUNK,8*800H+3*40H+FRGPAL+FRGGCOL+FRGNOFLP+FRGRND

	.long	CHUNK_SHIRT,F_CHUNK
	.word	OID_JUNK,2*800H+1*40H+FRGPAL+FRGGCOL

	.long	CHUNK_BLOOD,F_BLOOD
	.word	OID_JUNK,8*800H+1*40H+FRGPAL+FRGGCOL+FRGNOFLP+FRGRND
	.long	0

*
*Piece of Mondor's jeans
*
MONDOR_JEANS_MULTI
	.long	CHUNK_JEANS,F_CHUNK
	.word	OID_JUNK,2*800H+1*40H+FRGPAL+FRGGCOL

	.long	CHUNK_D,F_CHUNK
	.word	OID_JUNK,3*800H+1*40H+FRGPAL+FRGGCOL

	.long	CHUNK_BLOOD,F_BLOOD
	.word	OID_JUNK,8*800H+3*40H+FRGPAL+FRGGCOL+FRGNOFLP+FRGRND

	.long	CHUNK_JEANS,F_CHUNK
	.word	OID_JUNK,2*800H+1*40H+FRGPAL+FRGGCOL

	.long	CHUNK_A,F_CHUNK
	.word	OID_JUNK,3*800H+1*40H+FRGPAL+FRGGCOL

	.long	CHUNK_BLOOD,F_BLOOD
	.word	OID_JUNK,8*800H+3*40H+FRGPAL+FRGGCOL+FRGNOFLP+FRGRND

	.long	CHUNK_JEANS,F_CHUNK
	.word	OID_JUNK,2*800H+1*40H+FRGPAL+FRGGCOL

	.long	CHUNK_BLOOD,F_BLOOD
	.word	OID_JUNK,8*800H+1*40H+FRGPAL+FRGGCOL+FRGNOFLP+FRGRND
	.long	0

*
*Pieces of Josh's dress shirt
*
FRAG_JOSH_SHIRT
	.long	CHUNK_JOSH_SUIT,F_JOSH_CHUNK_UL
	.word	OID_JUNK,7*800H+1*40H+FRGPAL+FRGGCOL

	.long	0

*
*Pieces of Josh's suit (left and up)
*
FRAG_JOSH_SUIT_UL
	.long	CHUNK_JOSH_SUIT,F_JOSH_CHUNK_UL
	.word	OID_JUNK,7*800H+1*40H+FRGPAL+FRGGCOL

	.long	CHUNK_JOSH_SHIRT,F_JOSH_CHUNK
	.word	OID_JUNK,2*800H+1*40H+FRGPAL+FRGGCOL

	.long	0

*
*Pieces of Josh's suit (right and up)
*
FRAG_JOSH_SUIT_UR
	.long	CHUNK_JOSH_SUIT,F_JOSH_CHUNK_UR
	.word	OID_JUNK,5*800H+1*40H+FRGPAL+FRGGCOL

	.long	CHUNK_JOSH_SHIRT,F_JOSH_CHUNK
	.word	OID_JUNK,2*800H+1*40H+FRGPAL+FRGGCOL

	.long	0

CHUNK_A
	LWLL	CHUNK_A_1,1|AFunc,A_GREEN_IF_NEC+2,CHIN_GRN
	LWLW	1,1|AFunc,A_INIT_AnimSLP+1,1
CHUNK_A_LOOP
	LW	CHUNK_A_2,0
	LW	CHUNK_A_3,0
	LW	CHUNK_A_4,0
	LW	CHUNK_A_5,0
	LW	CHUNK_A_6,0
	LW	CHUNK_A_7,0
	LWLW	CHUNK_A_8,0|AFunc,A_INC_AnimSLP+1,5
	LWLL	CHUNK_A_1,0|AFunc,A_CHUNK_ONSCREEN+2,CHUNK_A_LOOP
	LWL	1,1|AFunc,DELETE_OBJ

CHUNK_B
	LWLL	CHUNK_B_1,1|AFunc,A_GREEN_IF_NEC+2,CHIN_GRN
	LWLW	1,1|AFunc,A_INIT_AnimSLP+1,1
CHUNK_B_LOOP
	LW	CHUNK_B_2,0
	LW	CHUNK_B_3,0
	LW	CHUNK_B_4,0
	LW	CHUNK_B_5,0
	LW	CHUNK_B_6,0
	LW	CHUNK_B_7,0
	LWLW	CHUNK_B_8,0|AFunc,A_INC_AnimSLP+1,5
	LWLL	CHUNK_B_1,0|AFunc,A_CHUNK_ONSCREEN+2,CHUNK_B_LOOP
	LWL	1,1|AFunc,DELETE_OBJ

CHUNK_C
	LWLL	CHUNK_C_1,1|AFunc,A_GREEN_IF_NEC+2,CHIN_GRN
	LWLW	1,1|AFunc,A_INIT_AnimSLP+1,1
CHUNK_C_LOOP
	LW	CHUNK_C_2,0
	LW	CHUNK_C_3,0
	LW	CHUNK_C_4,0
	LW	CHUNK_C_5,0
	LW	CHUNK_C_6,0
	LW	CHUNK_C_7,0
	LWLW	CHUNK_C_8,0|AFunc,A_INC_AnimSLP+1,5
	LWLL	CHUNK_C_1,0|AFunc,A_CHUNK_ONSCREEN+2,CHUNK_C_LOOP
	LWL	1,1|AFunc,DELETE_OBJ

CHUNK_D
	LWLL	CHNK1,1|AFunc,A_GREEN_IF_NEC+2,CHIN_GRN
	LWLW	1,1|AFunc,A_INIT_AnimSLP+1,1
CHUNK_D_LOOP
	LW	CHNK2,0
	LW	CHNK3,0
	LW	CHNK4,0
	LW	CHNK5,0
	LW	CHNK6,0
	LW	CHNK7,0
	LW	CHNK8,0
	LWLW	CHNK9,0|AFunc,A_INC_AnimSLP+1,5
	LWLL	CHNK1,0|AFunc,A_CHUNK_ONSCREEN+2,CHUNK_D_LOOP
	LWL	1,1|AFunc,DELETE_OBJ

CHUNK_JOSH_SHIRT
	LWLW	J_SHRT,1|AFunc,A_Set_AnimLoop+1,3
	LWLL	1,1|AFunc,A_AnimFrm+2,CHUNK_JOSH_LOOP
CHUNK_JOSH_SUIT
	LWLW	SHRT1,1|AFunc,A_Set_AnimLoop+1,3
CHUNK_JOSH_LOOP
	LW	SHRT2,4
	LW	SHRT3,4
	LW	SHRT4,4
	LW	SHRT5,4
	LW	SHRT6,4
	LW	SHRT7,4
	LW	SHRT8,4
	LW	SHRT9,4
	LWLL	SHRT1,4|AFunc,A_Anim_DSJ+2,CHUNK_JOSH_LOOP
	LWL	1,1|AFunc,DELETE_OBJ


CHUNK_JEANS
;	LWLW	JEANS,1|AFunc,A_INIT_AnimSLP+1,1
;	LWLL	1,1|AFunc,A_AnimFrm+2,CHUNK_SHIRT_LOOP
CHUNK_SHIRT
	LWLW	SHRT1,1|AFunc,A_INIT_AnimSLP+1,1
CHUNK_SHIRT_LOOP
	LW	SHRT2,0
	LW	SHRT3,0
	LW	SHRT4,0
	LW	SHRT5,0
	LW	SHRT6,0
	LW	SHRT7,0
	LW	SHRT8,0
	LWLW	SHRT9,0|AFunc,A_INC_AnimSLP+1,5
	LWLL	SHRT1,0|AFunc,A_CHUNK_ONSCREEN+2,CHUNK_SHIRT_LOOP
	LWL	1,1|AFunc,DELETE_OBJ

CHUNK_BLOOD
	LW	BLOOD_DROP,20
	LWLL	1,1|AFunc,A_CHUNK_ONSCREEN+2,CHUNK_BLOOD
	LWL	1,1|AFunc,DELETE_OBJ

*
*Generic explosion show
*
FRAG_EXPLOSION
	.long	PART_EXPLOSION,0
	.word	OID_JUNK,3*800H+5*40H+FRGPAL+FRGNOFLY
	.long	PART_EXPLOSION,0
	.word	OID_JUNK,3*800H+15*40H+FRGPAL+FRGNOFLY
	.long	PART_EXPLOSION,0
	.word	OID_JUNK,3*800H+15*40H+FRGPAL+FRGNOFLY
	.long	PART_EXPLOSION,0
	.word	OID_JUNK,3*800H+1*40H+FRGPAL+FRGNOFLY
	.long	0
	
FRAG_EXPLOSION_SMALL
	.long	PART_EXPLOSION,0
	.word	OID_JUNK,1*800H+5*40H+FRGPAL+FRGNOFLY
	.long	PART_EXPLOSION,0
	.word	OID_JUNK,1*800H+5*40H+FRGPAL+FRGNOFLY
	.long	PART_EXPLOSION,0
	.word	OID_JUNK,1*800H+1*40H+FRGPAL+FRGNOFLY
	.long	0

FRAG_EXPLOSION_ONE
	.long	PART_EXPLOSION,0
	.word	OID_JUNK,1*800H+1*40H+FRGPAL+FRGNOFLY
	.long	0

BUS_EXPLOSION
	.long	PART_EXPLOSION,F_EXPLOSION_OUT
	.word	OID_JUNK,3*800H+5*40H+FRGPAL+FRGNOFLY
	.long	PART_EXPLOSION,F_EXPLOSION_OUT
	.word	OID_JUNK,3*800H+15*40H+FRGPAL+FRGNOFLY
	.long	PART_EXPLOSION,F_EXPLOSION_OUT
	.word	OID_JUNK,3*800H+15*40H+FRGPAL+FRGNOFLY
	.long	PART_EXPLOSION,F_EXPLOSION_OUT
	.word	OID_JUNK,3*800H+1*40H+FRGPAL+FRGNOFLY+FRGBOG
	.long	0
	
BUS_EXPLOSION_SMALL
	.long	PART_EXPLOSION,F_EXPLOSION_OUT_2X
	.word	OID_JUNK,1*800H+5*40H+FRGPAL+FRGNOFLY
	.long	PART_EXPLOSION,F_EXPLOSION_OUT_2X
	.word	OID_JUNK,1*800H+5*40H+FRGPAL+FRGNOFLY
	.long	PART_EXPLOSION,F_EXPLOSION_OUT_2X
	.word	OID_JUNK,1*800H+1*40H+FRGPAL+FRGNOFLY+FRGBOG
	.long	0

PART_EXPLOSION
	LWLL	FHKEXPLOB1,6|AFunc,A_SOUND+2,SND_PART_EXPLODE
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

*
*Explosion sometimes used by BLOW_PART
*
EXPLO_BLOW_INIT
	.LONG	FHKEXPLOB1
	.WORD	DMAWNZ, 0, OM_ANIM|OM_DUMCOLL
	.LONG	PART_EXPLOSION

*
*The final blast
*
FRAG_FINAL_EXPLOSION
	.long	PART_EXPLOSION,F_EXPLOSION_OUT
	.word	OID_JUNK,10*800H+1*40H+FRGPAL+FRGNOFLY

	.long	CHUNK_BLOOD,F_BLOOD_FINAL
	.word	OID_JUNK,15*800H+5*40H+FRGPAL+FRGGCOL+FRGNOFLP

	.long	PART_EXPLOSION,F_EXPLOSION_OUT
	.word	OID_JUNK,10*800H+1*40H+FRGPAL+FRGNOFLY

	.long	CHUNK_A,F_CHUNK_FINAL
	.word	OID_JUNK,5*800H+0*40H+FRGPAL+FRGGCOL

	.long	CHUNK_B,F_CHUNK_FINAL
	.word	OID_JUNK,5*800H+0*40H+FRGPAL+FRGGCOL

	.long	CHUNK_D,F_CHUNK_FINAL
	.word	OID_JUNK,5*800H+5*40H+FRGPAL+FRGGCOL

	.long	CHUNK_BLOOD,F_BLOOD
	.word	OID_JUNK,20*800H+15*40H+FRGPAL+FRGGCOL+FRGNOFLP

	.long	PART_EXPLOSION,F_EXPLOSION_OUT
	.word	OID_JUNK,10*800H+1*40H+FRGPAL+FRGNOFLY

	.long	CHUNK_SHIRT,F_CHUNK_FINAL
	.word	OID_JUNK,10*800H+0*40H+FRGPAL+FRGGCOL

	.long	CHUNK_C,F_CHUNK
	.word	OID_JUNK,5*800H+1*40H+FRGPAL+FRGGCOL

	.long	CHUNK_BLOOD,F_BLOOD_UP
	.word	OID_JUNK,10*800H+0*40H+FRGPAL+FRGGCOL+FRGNOFLP

	.long	CHUNK_BLOOD,F_BLOOD
	.word	OID_JUNK,10*800H+5*40H+FRGPAL+FRGGCOL+FRGNOFLP

	.long	CHUNK_A,F_CHUNK
	.word	OID_JUNK,5*800H+0*40H+FRGPAL+FRGGCOL

	.long	CHUNK_B,F_CHUNK_UP
	.word	OID_JUNK,5*800H+0*40H+FRGPAL+FRGGCOL

	.long	CHUNK_D,F_CHUNK_UP
	.word	OID_JUNK,5*800H+5*40H+FRGPAL+FRGGCOL

	.long	CHUNK_BLOOD,F_BLOOD_UP
	.word	OID_JUNK,10*800H+0*40H+FRGPAL+FRGGCOL+FRGNOFLP

	.long	CHUNK_BLOOD,F_BLOOD
	.word	OID_JUNK,10*800H+5*40H+FRGPAL+FRGGCOL+FRGNOFLP

	.long	CHUNK_JEANS,F_CHUNK
	.word	OID_JUNK,10*800H+0*40H+FRGPAL+FRGGCOL

	.long	CHUNK_A,F_CHUNK_UP
	.word	OID_JUNK,5*800H+15*40H+FRGPAL+FRGGCOL

;	.long	CHUNK_BLOOD,F_BLOOD_UP
;	.word	OID_JUNK,10*800H+5*40H+FRGPAL+FRGGCOL+FRGNOFLP

;	.long	CHUNK_BLOOD,F_BLOOD_UP
;	.word	OID_JUNK,10*800H+0*40H+FRGPAL+FRGGCOL+FRGNOFLP

;	.long	CHUNK_BLOOD,F_BLOOD
;	.word	OID_JUNK,5*800H+5*40H+FRGPAL+FRGGCOL+FRGNOFLP

;	.long	CHUNK_BLOOD,F_BLOOD_UP
;	.word	OID_JUNK,10*800H+0*40H+FRGPAL+FRGGCOL+FRGNOFLP

;	.long	CHUNK_BLOOD,F_BLOOD
;	.word	OID_JUNK,5*800H+5*40H+FRGPAL+FRGGCOL+FRGNOFLP

;	.long	CHUNK_BLOOD,F_BLOOD_UP
;	.word	OID_JUNK,10*800H+0*40H+FRGPAL+FRGGCOL+FRGNOFLP

;	.long	CHUNK_BLOOD,F_BLOOD
;	.word	OID_JUNK,5*800H+5*40H+FRGPAL+FRGGCOL+FRGNOFLP

;	.long	CHUNK_BLOOD,F_BLOOD
;	.word	OID_JUNK,5*800H+5*40H+FRGPAL+FRGGCOL+FRGNOFLP

;	.long	CHUNK_BLOOD,F_BLOOD_UP
;	.word	OID_JUNK,10*800H+0*40H+FRGPAL+FRGGCOL+FRGNOFLP

;	.long	CHUNK_BLOOD,F_BLOOD_UP
;	.word	OID_JUNK,10*800H+5*40H+FRGPAL+FRGGCOL+FRGNOFLP

;	.long	CHUNK_B,F_CHUNK_FINAL
;	.word	OID_JUNK,5*800H+0*40H+FRGPAL+FRGGCOL

;	.long	CHUNK_C,F_CHUNK_FINAL
;	.word	OID_JUNK,5*800H+0*40H+FRGPAL+FRGGCOL

;	.long	CHUNK_D,F_CHUNK_FINAL
;	.word	OID_JUNK,5*800H+5*40H+FRGPAL+FRGGCOL

;	.long	CHUNK_BLOOD,F_BLOOD_FINAL
;	.word	OID_JUNK,20*800H+1*40H+FRGPAL+FRGGCOL+FRGNOFLP

	.LONG	0


*
*The final blast aftermath
*
FRAG_FINAL_RAIN
*Pause
	.long	CHUNK_BLOOD,F_BLOOD_RAIN
	.word	OID_JUNK,0*800H+30*40H+FRGPAL+FRGGCOL+FRGNOFLP

	.long	CHUNK_BLOOD,F_BLOOD_RAIN
	.word	OID_JUNK,0*800H+30*40H+FRGPAL+FRGGCOL+FRGNOFLP

	.long	CHUNK_BLOOD,F_BLOOD_RAIN
	.word	OID_JUNK,0*800H+30*40H+FRGPAL+FRGGCOL+FRGNOFLP

	.long	CHUNK_BLOOD,F_BLOOD_RAIN
	.word	OID_JUNK,0*800H+10*40H+FRGPAL+FRGGCOL+FRGNOFLP

*End of pause

	.long	CHUNK_BLOOD,F_BLOOD_RAIN
	.word	OID_JUNK,10*800H+15*40H+FRGPAL+FRGGCOL+FRGNOFLP

	.long	CHUNK_A,F_CHUNK_RAIN
	.word	OID_JUNK,3*800H+1*40H+FRGPAL+FRGGCOL

	.long	CHUNK_BLOOD,F_BLOOD_RAIN
	.word	OID_JUNK,15*800H+15*40H+FRGPAL+FRGGCOL+FRGNOFLP

	.long	CHUNK_JEANS,F_CHUNK_RAIN
	.word	OID_JUNK,5*800H+1*40H+FRGPAL+FRGGCOL

	.long	CHUNK_BLOOD,F_BLOOD_RAIN
	.word	OID_JUNK,15*800H+15*40H+FRGPAL+FRGGCOL+FRGNOFLP

	.long	CHUNK_B,F_CHUNK_RAIN
	.word	OID_JUNK,3*800H+1*40H+FRGPAL+FRGGCOL

	.long	CHUNK_BLOOD,F_BLOOD_RAIN
	.word	OID_JUNK,15*800H+15*40H+FRGPAL+FRGGCOL+FRGNOFLP

	.long	CHUNK_SHIRT,F_CHUNK_RAIN
	.word	OID_JUNK,5*800H+1*40H+FRGPAL+FRGGCOL

	.long	CHUNK_BLOOD,F_BLOOD_RAIN
	.word	OID_JUNK,15*800H+15*40H+FRGPAL+FRGGCOL+FRGNOFLP

	.long	CHUNK_C,F_CHUNK_RAIN
	.word	OID_JUNK,3*800H+10*40H+FRGPAL+FRGGCOL

	.long	CHUNK_BLOOD,F_BLOOD_RAIN
	.word	OID_JUNK,15*800H+15*40H+FRGPAL+FRGGCOL+FRGNOFLP

	.long	CHUNK_BLOOD,F_BLOOD_RAIN
	.word	OID_JUNK,15*800H+15*40H+FRGPAL+FRGGCOL+FRGNOFLP

	.long	CHUNK_B,F_CHUNK_RAIN
	.word	OID_JUNK,3*800H+10*40H+FRGPAL+FRGGCOL

	.long	CHUNK_BLOOD,F_BLOOD_RAIN
	.word	OID_JUNK,15*800H+10*40H+FRGPAL+FRGGCOL+FRGNOFLP

	.long	CHUNK_BLOOD,F_BLOOD_RAIN
	.word	OID_JUNK,15*800H+15*40H+FRGPAL+FRGGCOL+FRGNOFLP

	.long	CHUNK_SHIRT,F_CHUNK_RAIN
	.word	OID_JUNK,5*800H+10*40H+FRGPAL+FRGGCOL

	.long	CHUNK_BLOOD,F_BLOOD_RAIN
	.word	OID_JUNK,15*800H+10*40H+FRGPAL+FRGGCOL+FRGNOFLP

	.long	CHUNK_BLOOD,F_BLOOD_RAIN
	.word	OID_JUNK,15*800H+15*40H+FRGPAL+FRGGCOL+FRGNOFLP

	.long	CHUNK_A,F_CHUNK_RAIN
	.word	OID_JUNK,3*800H+10*40H+FRGPAL+FRGGCOL

	.long	CHUNK_BLOOD,F_BLOOD_RAIN
	.word	OID_JUNK,15*800H+10*40H+FRGPAL+FRGGCOL+FRGNOFLP

	.long	CHUNK_BLOOD,F_BLOOD_RAIN
	.word	OID_JUNK,15*800H+15*40H+FRGPAL+FRGGCOL+FRGNOFLP

*Pause
	.long	CHUNK_BLOOD,F_BLOOD_RAIN
	.word	OID_JUNK,0*800H+30*40H+FRGPAL+FRGGCOL+FRGNOFLP

	.long	CHUNK_BLOOD,F_BLOOD_RAIN
	.word	OID_JUNK,0*800H+30*40H+FRGPAL+FRGGCOL+FRGNOFLP

;	.long	CHUNK_BLOOD,F_BLOOD_RAIN
;	.word	OID_JUNK,0*800H+30*40H+FRGPAL+FRGGCOL+FRGNOFLP

*End Pause
	.long	CHUNK_A,F_CHUNK_RAIN
	.word	OID_JUNK,3*800H+10*40H+FRGPAL+FRGGCOL

	.long	CHUNK_BLOOD,F_BLOOD_RAIN
	.word	OID_JUNK,10*800H+10*40H+FRGPAL+FRGGCOL+FRGNOFLP

	.long	CHUNK_BLOOD,F_BLOOD_RAIN
	.word	OID_JUNK,10*800H+10*40H+FRGPAL+FRGGCOL+FRGNOFLP

	.long	CHUNK_BLOOD,F_BLOOD_RAIN
	.word	OID_JUNK,10*800H+10*40H+FRGPAL+FRGGCOL+FRGNOFLP

	.long	CHUNK_BLOOD,F_BLOOD_RAIN
	.word	OID_JUNK,10*800H+10*40H+FRGPAL+FRGGCOL+FRGNOFLP

	.long	CHUNK_BLOOD,F_BLOOD_RAIN
	.word	OID_JUNK,15*800H+10*40H+FRGPAL+FRGGCOL+FRGNOFLP

	.long	CHUNK_B,F_CHUNK_RAIN
	.word	OID_JUNK,3*800H+10*40H+FRGPAL+FRGGCOL

	.long	CHUNK_BLOOD,F_BLOOD_RAIN
	.word	OID_JUNK,15*800H+10*40H+FRGPAL+FRGGCOL+FRGNOFLP

	.long	CHUNK_BLOOD,F_BLOOD_RAIN
	.word	OID_JUNK,15*800H+10*40H+FRGPAL+FRGGCOL+FRGNOFLP

	.long	CHUNK_BLOOD,F_BLOOD_RAIN
	.word	OID_JUNK,15*800H+10*40H+FRGPAL+FRGGCOL+FRGNOFLP

	.long	CHUNK_BLOOD,F_BLOOD_RAIN
	.word	OID_JUNK,10*800H+10*40H+FRGPAL+FRGGCOL+FRGNOFLP

	.long	CHUNK_BLOOD,F_BLOOD_RAIN
	.word	OID_JUNK,10*800H+10*40H+FRGPAL+FRGGCOL+FRGNOFLP

	.long	CHUNK_BLOOD,F_BLOOD_RAIN
	.word	OID_JUNK,10*800H+30*40H+FRGPAL+FRGGCOL+FRGNOFLP
*Pause
	.long	CHUNK_BLOOD,F_BLOOD_RAIN
	.word	OID_JUNK,0*800H+30*40H+FRGPAL+FRGGCOL+FRGNOFLP

	.long	CHUNK_BLOOD,F_BLOOD_RAIN
	.word	OID_JUNK,0*800H+30*40H+FRGPAL+FRGGCOL+FRGNOFLP

*End Pause
	.long	CHUNK_BLOOD,F_BLOOD_RAIN
	.word	OID_JUNK,3*800H+20*40H+FRGPAL+FRGGCOL+FRGNOFLP

	.long	CHUNK_BLOOD,F_BLOOD_RAIN
	.word	OID_JUNK,2*800H+20*40H+FRGPAL+FRGGCOL+FRGNOFLP

	.long	CHUNK_BLOOD,F_BLOOD_RAIN
	.word	OID_JUNK,1*800H+20*40H+FRGPAL+FRGGCOL+FRGNOFLP

	.long	CHUNK_BLOOD,F_BLOOD_RAIN
	.word	OID_JUNK,1*800H+20*40H+FRGPAL+FRGGCOL+FRGNOFLP

*Pause
	.long	CHUNK_BLOOD,F_BLOOD_RAIN
	.word	OID_JUNK,0*800H+30*40H+FRGPAL+FRGGCOL+FRGNOFLP
*End Pause

	.long	CHUNK_BLOOD,F_BLOOD_RAIN
	.word	OID_JUNK,1*800H+20*40H+FRGPAL+FRGGCOL+FRGNOFLP

	.LONG	0

*
*Script to make the gun fly from Mondor's hand
*
FRAG_GUN_FLY
	.long	GUN_FLY,F_GUN_CHUNK
	.word	OID_JUNK,1*800H+1*40H+FRGPAL+FRGGCOL

	.LONG	0

**************************************************************************
*								         *
* F_GUN_CHUNK - Frag Func for MONDOR gun.				 *
* A0 = Ptr to un-inserted object.					 *
* 									 *
* Note: Frag funcs must preserve A8-A11 and all B-File regs.		 *
*								         *
**************************************************************************
F_GUN_CHUNK
	MOVE	*A0(OZVEL),A14,L
	ABS	A14
	NEG	A14
	MOVE	A14,*A0(OZVEL),L

	MOVE	*A0(OYVEL),A14,L
	ABS	A14
	ADDI	20000H,A14
	NEG	A14
	MOVE	A14,*A0(OYVEL),L

;	CLR	A14
;	MOVE	A14,*A0(OXVEL),L

	MOVIM	GUN_CHUNK_COLL,*A0(OCVECT),L	;Set up chunk with Vectors	
	RETS

GUN_CHUNK_COLL
	WWL	OID_GRND,0FFFFH,GUN_CHUNK_GROUND_COLL
	WL	0,DUMCRETS

GUN_CHUNK_GROUND_COLL
	MOVB	*A8(OFLAGS),A14		;Are we out of Range?
	JRN	GCGC_DEL		;BR = Yes

	SOUNDZ	SND_GUN_BOUNCE

;	MOVE	*A8(OYVEL),A14,L
;	MOVE	A14,A1
;	SRA	1,A14			;Knock off 25% for the bounce.
;	SUB	A14,A1
	MOVE	*A8(OYVEL),A1,L
	SRA	2,A1

	CMPI	4000H,A1		;Have we hit the minimum?
	JRLE	GCGC_DEL		;BR = Yes, delete the object.
	CMPI	24000H,A1		;Will it bounce too high?
	JRLE	GCGC_BOUNCE		;BR = No, let it bounce.
	MOVI	24000H,A1		;Cap the rebound velocity
GCGC_BOUNCE
       	NEG	A1			;Turn it up
	MOVE	A1,*A8(OYVEL),L
	RETS
GCGC_DEL	
	JAUC	DELETE_OBJ

GUN_FLY
	LWLW	GUNF_1,1|AFunc,A_INIT_AnimSLP+1,1
GUN_FLY_LOOP
	LW	GUNF_2,0
	LW	GUNF_3,0
	LW	GUNF_4,0
	LW	GUNF_5,0
	LW	GUNF_6,0
	LW	GUNF_7,0
	LWLW	GUNF_8,0|AFunc,A_INC_AnimSLP+1,5
	LWLL	GUNF_1,0|AFunc,A_CHUNK_ONSCREEN+2,GUN_FLY_LOOP
	LWL	1,1|AFunc,DELETE_OBJ

*
* Green palette for skin pieces
*
CHIN_GRN:
   .word   32 
   .word   00000h,00c61h,018a4h,001c0h,001e0h,00100h,02d27h,03989h
   .word   00200h,003e0h,045cbh,002a0h,043e5h,05a4dh,066afh,05563h
   .word   072d1h,002e1h,035c3h,014c1h,00129h,02962h,07f53h,04645h
   .word   00120h,03147h,03568h,03e06h,039a6h,02d81h,03160h,01d01h

	.END
