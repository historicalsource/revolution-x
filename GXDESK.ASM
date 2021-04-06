	.MLIB	"GXMACS.LIB"
	.FILE	"GXDESK.ASM"
	.TITLE	"<<< REVOLUTION X -- NEW JAPAN TECHNOLOGY - THE MECH DESK >>>"
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
	.INCLUDE	"GXSTRING.H"
	.INCLUDE	"GXS.H"
	.INCLUDE	"GXMONDOR.H"		;The desk is modelled after him
	.INCLUDE	"GXDESK.TBL"

*
*Symbols from the desk
*
	.DEF DESK_PROC, DESK_XFORM_FLAG, SPAWN_FIRE
	.DEF ANIM_SMALL_SHAKE, ANIM_MEDIUM_SHAKE, ANIM_BIG_SHAKE
	.DEF DGV_FRAG_SPARK, F_EXPLOSION_OUT, TAB_METAL_SOUNDS
	.DEF SNUM_NIGHTMARE, A_ADD_YPOS, JOSH_SIT_FLAG
	.DEF FRAG_DESK_EXPLOSION, FRAG_DESK_METAL, FRAG_DESK_RAIN
	.DEF SND_FINAL_EXPLODE1, SND_FINAL_EXPLODE2, SND_FINAL_EXPLODE3
	.DEF A_MULTI_METAL_CHUNK, A_NOSCALE_NOSHAD, F_EXPLOSION_OUT_2X
	.DEF INIT_SPARK, C_DESK, FRAG_SMALL_OUT_EXP

*
*Symbols from around the GLOBE
*

***** from GXRAM.ASM

	.REF ENEMY_QUOTA, GAME_STATE, SOUNDSUP, CURPLYRS, WAVETIME, RAND
	.REF GUNS_OFF, BASE_HIT

***** from GXAFUNC.ASM

	.REF A_Anim_DSJ, A_PreFrag_Box, A_PreFrag_Center, A_INIT_AnimSLP
	.REF A_Set_AnimLoop, SetAnim, A_SET_OZVEL, A_CREATEP, A_PreFrag_Rain
	.REF A_Set_Rel_Byte_Head, A_SOUND, A_SOUNDZ, A_RAND_SOUNDZ
	.REF A_Set_Var_Word, A_OBJ_ON_CHANGE_PAL, A_INC_AnimSLP
	.REF A_Set_Rel_Word_Head, A_Set_Rel_Long, A_Anim_Rel_DSJ
	.REF A_Set_Rel_Byte, SetAnim_AFARG, A_BRANCH_IF_FALSE

***** from GXSND.ASM

	.REF ONESND_Z, ONESND, SND_BGND1_OFF, SND_BGND2_OFF, IS_SOUND

***** from GXD.ASM

	.REF SETOFFPU, XBASE, YBASE, ZBASE, YHALF, GET_SHAD_MULTI
	.REF SET_ANIPXU, SET_OBJSU, EASYMAKE, SET_ONGRND, GETOFFPU
	.REF GETSUPP_FROM_OID, SET_ANIPU, SET_SCRN_POS
	.REF DELETE_OBJ_PROC, GET_HEAD_PART_A0, OBJCONST, SETANIPU
	.REF GETHEADPART

***** from GXUNILNK.ASM

	.REF BG_TO_FG

***** from GXUTIL.ASM

	.REF SET_VECTORS, SLINEVEL_LOAD_3D, PASTE_ON_DAMAGE

***** from GXCONTRL.ASM

	.REF BFLASH0_ANIM, bulit9

***** from GXPALL.ASM

	.REF A_CHANGE_PAL

***** from GXPLAYER.ASM

	.REF ANY_BOMBS, CK_PLAYER_HIT, GET_PLAYER_EXTENTS, PLAYER_HIT

***** from GXENEMY.ASM

	.REF INSERT_ENEMY, CREATE_ENEMY, DELETE_ENEMY

***** from GXCOG.asm

	.REF HIT_ENEMY

***** from GXMONDOR.ASM

	.REF A_GET_SHAD_MULTI

***** from GXMONDR2.ASM

	.REF FRAG_EXPLOSION, F_CHUNK, A_CHUNK_ONSCREEN, MONDOR_PROC
	.REF PROC_SKY_FLASH, A_CHECK_MISSLE_SCREEN_HIT, BLOW_PART
	.REF PROJECTILE_ROCKET_COLL, F_CHUNK_RAIN, PART_EXPLOSION
	.REF PROC_TEMP_ENDING

***** from GXUNIJAP.ASM

	.REF NO_CHARITY


*
*DESK RAM
*
	.BSS	DESK_XFORM_FLAG,16
	.BSS	DESK_TOTAL,16		;Set if Desk was totally destroyed.
	.BSS	JOSH_SIT_FLAG,16
	.BSS	UNUSED_WORD,16		;For alignment purposes

	.TEXT

**************************************************************************
*								         *
* 	DESK_PROC							 *
* 									 *
* 	Process to create the mech desk.  Searches the background	 *
* 	for the existing desk pieces and replaces them with a new	 *
* 	desk, ready to transform once DESK_XFORM_FLAG is set.		 *
*								         *
**************************************************************************
DESK_PROC
	MOVI	OID_DESK,A0
	CALLA	GET_ENEMY_COUNT
	CMPK	1,A0
	JAHS	SUCIDE

	CLRM	@DESK_XFORM_FLAG,W
	
	MOVI	(OID_UNIV|ID_30)&~MASK_SUPP,A0	;This is the desks I.D. in the universe
	MOVI	~MASK_SUPP,A1
;	CALLA	EXISTOBJ_ALL
	CALLA	EXISTOBJ
	JAZ	SUCIDE			;BR = No, just die

	PUSH	A0			;Save the ptr to the desk object

	MOVI	DESK_INIT,B0		;Allocate the desk
	CALLA	CREATE_ENEMY
	PULL	A0			;Restore background desk image ptr.
	JAZ	SUCIDE			;BR = No desk available? Blow out

	CLRM	@DESK_TOTAL,W		;Clear the total destruction flag

	MOVE	*A0(OXVAL),A1,L		;Grab positions of desk in universe
	MOVE	*A0(OYVAL),A2,L
	MOVE	*A0(OZVAL),A3,L

	CALLA	SET_ANIPU		;Set the new desk there

	PUSHP	A0			;Save this part of the desk placeholder

	CALLA	INSERT_ENEMY		;INSERT AND COUNT ENEMY

	CALLA	GET_SHAD_MULTI		;Setup his shadow

	SLEEP	1			;Wait a frame

	PUSH	A8			;Save desk ptr on system stack

	PULLP	A8			;Pull placeholder from process stack
	
	CALLA	BG_TO_FG		;Get place holder out of Bgnd
	CALLA	DELETE_OBJ		;And get rid of it

	MOVI	(OID_UNIV|ID_30)&~MASK_SUPP,A0	;This is the desks I.D. in the universe
	MOVI	~MASK_SUPP,A1
;	CALLA	EXISTOBJ_ALL		;Get the other half of the desk
	CALLA	EXISTOBJ		;Get the other half of the desk
	JRZ	DESK_READY_AND_WAITING	;Other half is gone?

	MOVE	A0,A8
	CALLA	BG_TO_FG		;Get place holder out of Bgnd
	CALLA	DELETE_OBJ		;Second half is now gone

DESK_READY_AND_WAITING
	PULLQ	A8			;Get the desk ptr back

	MOVE	A13,*A8(OPLINK),L

DESK_WAIT
	SLEEP	1
	MOVE	@DESK_XFORM_FLAG,A14,W	;Should we start the transform?
	JRZ	DESK_WAIT		;BR = Not yet, let's just wait a little

	MOVI	ANIM_TRANSFORM,A1
	CALLA	STRT_ANIM

*
*We will hang here and motor him around
*
	MOVE	@WAVETIME,A14,L
	MOVE	A14,*A13(PDATA),L	;Save the create time

	MOVK	20,A10			;Update accelerators every x ticks

DESK_WATCH_LOOP
	DEC	A10
	JRGT	DESK_EVERY_TICK
	MOVK	20,A10

	MOVE	@WAVETIME,A14,L
	MOVE	*A13(PDATA),A1,L
	SUB	A14,A1

	SRA	3,A1
	
	ADDI	1024,A1			;Create a percentage chance to pause

	CMPI	100,A1
	JRGE	DWL_MISS_PERC_OK

	MOVI	100,A1
DWL_MISS_PERC_OK

	MOVE	A1,*A8(OMISSLE_PERC),W	;% chance that we will pause before firing

*
*Shit to do every tick. Don't trash A10.
*
DESK_EVERY_TICK
	MOVE	A8,A0
;Stuff for head part only
	MOVB	*A0(OCLRNOSETZVEL),A14	;Clear the NOSET_ZVEL flag?
	JRZ	DET_HEAD_1		;BR = Not timing currently
	DEC	A14			;Down a tick
	MOVB	A14,*A0(OCLRNOSETZVEL)	;Save it
	JRNZ	DET_HEAD_1		;BR = Didn't hit 0 yet
	MOVB	A14,*A0(ONOSET_ZVEL)	;Clear dat flag
DET_HEAD_1
	MOVB	*A0(OXBURN),A14		;Clear the X acceleration?
	JRZ	DET_HEAD_2		;BR = Not timing currently
	DEC	A14			;Down a tick
	MOVB	A14,*A0(OXBURN)		;Save it
	JRNZ	DET_HEAD_2		;BR = Didn't hit 0 yet
	MOVE	A14,*A0(OXACCEL),W	;Clear that acceleration
DET_HEAD_2
	MOVB	*A0(OYBURN),A14		;Clear the Y acceleration?
	JRZ	DET_HEAD_3		;BR = Not timing currently
	DEC	A14			;Down a tick
	MOVB	A14,*A0(OYBURN)		;Save it
	JRNZ	DET_HEAD_3		;BR = Didn't hit 0 yet
	MOVE	A14,*A0(OYACCEL),W	;Clear that acceleration
DET_HEAD_3
	MOVB	*A0(OZBURN),A14		;Clear the Z acceleration?
	JRZ	DET_HEAD_4		;BR = Not timing currently
	DEC	A14			;Down a tick
	MOVB	A14,*A0(OZBURN)		;Save it
	JRNZ	DET_HEAD_4		;BR = Didn't hit 0 yet
	MOVE	A14,*A0(OZACCEL),W	;Clear that acceleration
DET_HEAD_4
	MOVB	*A0(OCLRCENTER),A14	;Clear the Center flag?
	JRZ	DET_HEAD_5		;BR = Not timing currently
	DEC	A14			;Down a tick
	MOVB	A14,*A0(OCLRCENTER)	;Save it
	JRNZ	DET_HEAD_5		;BR = Didn't hit 0 yet
	MOVE	A14,*A0(OCENTER_FLAG),W	;Clear that flag
DET_HEAD_5
	MOVE	*A0(OTALK_WAIT),A14,W	;Are we waiting to talk again?
	JRZ	DET_HEAD_6		;BR = No
	DEC	A14			;Decrement the wait timer
	MOVE	A14,*A0(OTALK_WAIT),W
DET_HEAD_6
	MOVB	*A0(OCLRFDAM),A14	;Clear the FDAM_GOING flag?
	JRZ	DET_HEAD_7		;BR = Not timing currently
	DEC	A14			;Down a tick
	MOVB	A14,*A0(OCLRFDAM)	;Save it
	JRNZ	DET_HEAD_7		;BR = Didn't hit 0 yet
	MOVB	A14,*A0(OFDAM_GOING)	;Clear that flag
DET_HEAD_7
	MOVB	*A0(OPROJ_CK_TIME),A14	;Check for a projectile hit?
	JRZ	DET_HEAD_7a		;BR = Not timing currently
	DEC	A14			;Down one
	MOVB	A14,*A0(OPROJ_CK_TIME)	;Save it
	JRNZ	DET_HEAD_8		;BR = Not time to check yet
	MOVB	*A0(OPROJ_HIT),A14	;Did any projectiles score a hit?
	JRZ	DET_HEAD_8		;BR = No
	PUSH	A0
	MOVI	256,A0
	CALLA	RANDPER
	JRNC	DET_SKIP_TAUNT
	MOVI	NUM_JOSH,A1
	CALLA	FINDPART
	MOVE	A0,A6
	MOVK	NUM_TAUNTS,A0		;Do a little taunting
	CALLA	RAND0
	SLL	3,A0
	ADDI	TAUNT_TABLE,A0
	MOVB	*A0,A0
	MOVB	A0,*A6(OTALK_FLAG)
DET_SKIP_TAUNT
	PULLQ	A0
	CLR	A14
DET_HEAD_7a
	MOVB	A14,*A0(OPROJ_HIT)
DET_HEAD_8
	MOVE	*A0(OGAT_WAIT),A14,W	;Are we waiting to do another arm action?
	JRZ	DET_HEAD_9		;BR = No
	DEC	A14			;Decrement the wait timer
	MOVE	A14,*A0(OGAT_WAIT),W
DET_HEAD_9
	MOVB	*A0(OGATS_GONE),A14
	CMPK	2,A14			;Are both his arms missing?
	JRLO	DET_HEAD_10		;BR = No
	INCM	*A0(ONOGAT_TIME),W
DET_HEAD_10
	MOVE	*A0(OMISSLE_WAIT),A14,W	;Waiting to open next missle bay?
	JRZ	DET_HEAD_11		;BR = No
	DEC	A14			;Decrement the wait timer
	MOVE	A14,*A0(OMISSLE_WAIT),W
	JRNZ	DET_HEAD_11		;BR = Didn't hit zero yet
	MOVB	A14,*A0(OMISSLE_VULNER)	;Clear the missle vulnerable flag
DET_HEAD_11

;Check all parts for un-tick
DET_ALL_PARTS
	MOVK	NUM_DESK_USED_PARTS,A6	;Double check number 'cause of gun flashes
	CLR	A5			;Offscreen counter

DET_TICK_LOOP
	MOVB	*A0(OFLASHTIME),A14	;Is this part flashing?
	JRZ	DET_FLASH_NEXT		;BR = No
	DEC	A14			;Decrement the flash time
	MOVB	A14,*A0(OFLASHTIME)	;Stuff it back for future
	JRNZ	DET_FLASH_NEXT		;BR = Not time to unflash
	MOVB	A14,*A0(O_BEING_DAMAGED) ;No longer being damaged

;	MOVE	*A0(OCTRL),A14,W
;	SLL	28,A14			;Is this object still on?
;	JRZ	DET_FLASH_NEXT		;BR = No

	move	*a0(OFLAGS),a14		; NEW METHOD - NODISP FLAG
	btst	B_NODISP,a14
	JRNZ	DET_FLASH_NEXT		;BR = No

	CALLA	OBJWNZ			;Unflash
DET_FLASH_NEXT
	MOVB	*A0(OCLRROCKETHIT),A14	;Do we need to clear this part?
	JRZ	DET_ROCKHIT_NEXT	;BR = No
	DEC	A14			;Decrement the clear time
	MOVB	A14,*A0(OCLRROCKETHIT)	;Stuff it back for future
	JRNZ	DET_ROCKHIT_NEXT	;BR = Not time to clear
	MOVB	A14,*A0(OROCKETHIT)	;No longer being hit by a rocket
DET_ROCKHIT_NEXT
	MOVB	*A0(OFLAGS),A14
	JRNN	DET_OFFSCREEN_NEXT
	INC	A5			;Click another part offscreen
DET_OFFSCREEN_NEXT
	MOVE	*A0(OPARTS),A0,L	;Get the next part
	JRZ	DET_SLEEP		;BR = We've lost parts somehow?
	DSJ	A6,DET_TICK_LOOP

DET_SLEEP
	CLR	A4			;Assume onscreen
	CMPK	NUM_DESK_USED_PARTS,A5	;Are all of the parts offscreen?
	JRLO	DET_SOME_ONSCREEN	;BR = No	
	MOVE	*A8(OFFSCRN_TIME),A4,W
	INC	A4			;Click another tick offscreen
DET_SOME_ONSCREEN
	MOVE	A4,*A8(OFFSCRN_TIME),W

	SLOOP	1,DESK_WATCH_LOOP	;Here we wait for shit to happen

NUM_TAUNTS	.EQU	1

TAUNT_TABLE
	.BYTE	SNUM_SORRY
	.EVEN

;**************************************************************************
;*								         *
;* 	JOSH_PROC							 *
;* 									 *
;* 	Process to find and handle the Josh Manager in the		 *
;* 	Japanese office.						 *
;*								         *
;**************************************************************************
;JOSH_PROC
;	CLRM	@JOSH_SIT_FLAG,W
;
;	MOVI	(OID_UNIV|ID_2)&~MASK_SUPP,A0	;This is Josh's I.D. in the universe
;	CALLA	EXISTOBJ_ALL		;Did we find him
;	JAZ	SUCIDE			;BR = No, just die
;
;	MOVE	A0,A8
;	
;	CALLA	BG_TO_FG		;Get Josh out of Bgnd
;
;	CALLA	CREATE_COPY		;We need a copy for the talking head
;	JRZ	JP_NO_HEAD
;
;	CALLA	OBJOFF
;	CALLA	INSPART
;	CALLR	UPDATE_OPARTIDS
;	CALLA	INSOBJ
;
;JP_NO_HEAD
;	MOVI	ANIM_JOSH_BOW,A1	
;	CALLA	STRT_ANIM		;And start him doing his thang
;
;	DIE

**************************************************************************
*								         *
* 	UPDATE_OPARTIDS							 *
* 									 *
* 	Update all OPARTIDs of objects in Multi-parter to reflect	 *
* 	the current order of things.					 *
* 									 *
* 	A8 = Ptr to head part						 *
*								         *
**************************************************************************
UPDATE_OPARTIDS
	MMTM	SP,A7,A8
	MOVK	1,A7
	MOVE	*A8(OPART1),A8,L
	JRZ	UO_X
UO_LOOP
	MOVB	A7,*A8(OPARTID)
	INC	A7
	MOVE	*A8(OPARTS),A8,L
	JRNZ	UO_LOOP
UO_X
	MMFM	SP,A7,A8
	RETS

**************************************************************************
*								         *
* 	A_STRTANIM_PART							 *
* 									 *
* 	Anim func to start the animation of a given part.		 *
* 									 *
* 	A8 = Ptr to any part of multi-parter				 *
* 	AARG+,W = OPARTID of part we need to start			 *
* 	AARG+,L = Animation to start					 *
*								         *
**************************************************************************
A_STRTANIM_PART
	CALLA	GETAFARG_WORD
	MOVE	A0,A1
	CALLA	GETAFARG_LONG
	MOVE	A0,A2
	CALLA	FINDPART		;Find the part we want
	JRZ	ASP_X			;BR = It doesn't exist
	MOVE	A2,A1
	JAUC	STRTANIM		;Fire off the animation
ASP_X
	RETS

**************************************************************************
*								         *
* 	C_DESK_PART_INIT						 *
* 									 *
* 	Create Func to be run on all active desk objects.		 *
*								         *
**************************************************************************
C_DESK_PART_INIT
	MOVIM	DESK_FLASH_COLOR,*A0(OCONST),W
	RETS

**************************************************************************
*								         *
* 		Animation Functions for The Desk			 *
*								         *
**************************************************************************

**************************************************************************
*								         *
* 	A_VELOCITY_WATCH						 *
* 									 *
* 	Anim Func to watch the Desk accelerations and do boundry	 *
* 	checks.								 *
* 									 *
* 	A8 = Ptr to any Desk part.					 *
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

	CMPI	DESK_ZMAX,A0		;Did we go too far back?
	JRGE	AVW_HIT_ZMAX		;BR = Yes

	CMPI	DESK_ZMIN,A0		;Did we come too far forward?
	JRGT	AVW_NO_Z_VIOLATION	;BR = No, no violations in Z

AVW_HIT_ZMIN
	MOVE	*A8(OZACCEL),A7,W
	JREQ	AVW_HZMIN_1
	JRGT	AVW_ADD_Z
	CLR	A7
	MOVE	A2,*A8(OZACCEL),W
AVW_HZMIN_1
	MOVE	A6,A6
	JRGE	AVW_ADD_Z
	SRA	SLED_ZBRAKE_SRA,A6
	JRZ	AVW_CLEARZ
	ABS	A6
	MOVI	SLED_ZBRAKE,A7
	MOVE	A7,*A8(OZACCEL),W
	MOVB	A6,*A8(OZBURN)

	JRUC	AVW_ADD_Z

AVW_HIT_ZMAX
	MOVE	*A8(OZACCEL),A7,W
	JREQ	AVW_HZMAX_1
	JRLT	AVW_ADD_Z
	CLR	A7
	MOVE	A2,*A8(OZACCEL),W
AVW_HZMAX_1
	MOVE	A6,A6
	JRLE	AVW_ADD_Z
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

	CMPI	DESK_XMAX,A3		;Did we go too far to the right?
	JRGE	AVW_HIT_XMAX		;BR = Yes

	CMPI	DESK_XMIN,A3		;Did we go too far to the left?
	JRGT	AVW_NO_X_VIOLATION	;BR = No, no violations in X

AVW_HIT_XMIN
	MOVE	*A8(OXACCEL),A7,W
	JREQ	AVW_HXMIN_1
	JRGT	AVW_ADD_X
	CLR	A7
	MOVE	A2,*A8(OXACCEL),W
AVW_HXMIN_1
	MOVE	A5,A5
	JRGE	AVW_ADD_X
	SRA	SLED_XYBRAKE_SRA,A5
	JRZ	AVW_CLEARX
	ABS	A5
	MOVI	SLED_XYBRAKE,A7
	MOVE	A7,*A8(OXACCEL),W
	MOVB	A5,*A8(OXBURN)

	JRUC	AVW_ADD_X

AVW_HIT_XMAX
	MOVE	*A8(OXACCEL),A7,W
	JREQ	AVW_HXMAX_1
	JRLT	AVW_ADD_X
	CLR	A7
	MOVE	A2,*A8(OXACCEL),W
AVW_HXMAX_1
	MOVE	A5,A5
	JRLE	AVW_ADD_X
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

	CMPI	DESK_YMAX,A1		;Did we go too far down?
	JRGE	AVW_HIT_YMAX		;BR = Yes

	CMPI	DESK_YMIN,A1		;Did we go too far up?
	JRGT	AVW_DONE		;BR = No, no violations in Y

	MOVE	*A8(OYACCEL),A7,W
	JREQ	AVW_HYMIN_1
	JRGT	AVW_DONE
	MOVE	A2,*A8(OYACCEL),W
AVW_HYMIN_1
	MOVE	A4,A4
	JRGE	AVW_DONE

	JRUC	AVW_YREFLECT
	SRA	SLED_XYBRAKE_SRA,A4
	JRZ	AVW_CLEARY
	ABS	A4
	INC	A4
	MOVIM	SLED_XYBRAKE,*A8(OYACCEL),W
	MOVB	A4,*A8(OYBURN)

	JRUC	AVW_DONE

AVW_HIT_YMAX
	MOVE	*A8(OYACCEL),A7,W
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
	CMPI	DESK_ZMAX_C,A0		;Did we go too far back?
	JRGE	AVW_SC_HIT_ZMAX		;BR = Yes

	CMPI	DESK_ZMIN_C,A0		;Did we come too far forward?
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

	CMPI	DESK_XMAX_C,A3		;Did we go too far to the right?
	JRGE	AVW_SC_HIT_XMAX		;BR = Yes

	CMPI	DESK_XMIN_C,A3		;Did we go too far to the left?
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

	CMPI	DESK_YMAX_C,A1		;Did we go too far down?
	JRGE	AVW_SC_HIT_YMAX		;BR = Yes

	CMPI	DESK_YMIN_C,A1		;Did we go too far up?
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
	CALLA	GET_HEAD_PART		;Velocity only works on the head

;	MOVE	*A8(OFFSCRN_TIME),A14,W
;	CMPI	60,A14		    	;Has he been offscreen awhile?
;	JRLT	AMA_ONSCREEN		;BR = No
*Desk is way offscreen, time to scare the player
;	MOVB	*A8(OFDAM_GOING),A14	;Is major damage going?
;	JRNE	AMA_ONSCREEN		;BR = Yes, no scaring

;	MOVK	1,A3	       		;Scream direction
;	MOVI	SND_KAMIKAZE,A4		;Scream sound
;	MOVI	75,A5			;Scream duration
;	MOVK	1,A6			;Scream severity
;	CALLA	MAKE_MONDOR_SCREAM	;Kamikaze

; 	MOVE	@XBASE,A1,L
;	MOVE	@YBASE,A2,L
;	MOVE	@ZBASE,A3,L
;	CALLA	SET_ANIPU

;	MOVE	A8,A14
;	ADDI	OXVAL,A14
;	MMFM	A14,A4,A5,A6		;LOAD A6:OXPOS, A5:OYPOS, A4:OZPOS

;	MOVI	XBASE,A14
;	MMFM	A14,A1,A2,A3		;LOAD A3:XBASE, A2:YBASE, A1:ZBASE

;	SUB	A3,A6	       		;Universe to World X 
;	ADD	A2,A5	       		;Universe to World Y  
;	SUB	A1,A4			;Universe to World Z

;	MOVI	10000H,A11
;	CLR	A9
;	CLR	A7
;	MOVI	80,A10

;	MOVIM	-720,*A8(OFFSCRN_TIME),W	;This gives us time to get back
	
;	JRUC	AMA_THRUST

;AMA_ONSCREEN
	MOVB	*A8(OMOVE_TIMER),A14
	JRZ	AMA_NEXT_MOVE
	DEC	A14
	MOVB	A14,*A8(OMOVE_TIMER)
	JRNZ	AMA_X

AMA_NEXT_MOVE
	MOVE	A8,A14
	ADDI	OXVAL,A14
	MMFM	A14,A4,A5,A6		;LOAD A6:OXPOS, A5:OYPOS, A4:OZPOS

	MOVI	XBASE,A14
	MMFM	A14,A1,A2,A3		;LOAD A3:XBASE, A2:YBASE, A1:ZBASE

	SUB	A3,A6	       		;Universe to World X 
	ADD	A2,A5	       		;Universe to World Y  
	SUB	A1,A4			;Universe to World Z

	CLR	B0			;This is the emergency register for Z vel

	MOVB	*A8(OCENTER_FLAG),A14	;Time to center?
	JRNZ	AMA_CENTER_NOW		;BR = Yes

	CMPI	DESK_ZMAX-100H,A4	;Did he get put waydafucbac?
	JRLT	AMA_NO_EMERGENCY_Z	;BR = No, then don't call 911

	MOVB	*A8(OFIRING_MISSLE),A14
	JRNZ	AMA_NO_EMERGENCY_Z

	MOVKB	1,*A8(OSHAKE_FIST)

	INC	B0			;Sound the alarm
	MOVI	DESK_ZMIN+2000H,A0	;Get Desk up front now!
	MOVI	DESK_ZMIN,A1
	CALLA	RANGERND
	MOVE	A0,A11

	JRUC	AMA_SELECT_X

AMA_NO_EMERGENCY_Z
	CLRB	*A8(OSHAKE_FIST)

	CMPI	DESK_ZMIN,A4
	JRGT	AMA_FULL_Z
AMA_BACK_UP_Z
	MOVI	DESK_ZMIN+4000H,A1
	JRUC	AMA_RAND_Z
AMA_FULL_Z
	MOVI	DESK_ZMIN,A1
AMA_RAND_Z
	MOVI	10000h,A0
	CALLA	RANGERND
	MOVE	A0,A11			;Random Z

AMA_SELECT_X
	MOVB	*A8(OGATS_GONE),A14
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

	MOVI	DESK_XMAX,A0
	MOVI	DESK_XMIN,A1
AMA_DO_RAND_X
	CALLA	RANGERND
	MOVE	A0,A9			;Random X
	SLL	16,A9

	MOVI	DESK_YMAX,A0
	MOVI	DESK_YMIN,A1
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

	MOVI	DESK_YMAX,A0
	MOVI	DESK_YMIN,A1
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
* 	A_START_DOME_RISE						 *
* 									 *
* 	Anim func to start the dome on it's way up.			 *
* 									 *
* 	A8 = Ptr to any part of the mech-desk				 *
*								         *
**************************************************************************
A_START_DOME_RISE
	CALLR	A_SCALE_SHAD
	MOVK	NUM_DOME,A1
	CALLA	FINDPART
	MOVI	ANIM_DOME_UP,A1
	JAUC	STRTANIM

**************************************************************************
*								         *
* 	A_START_SEAT_RISE						 *
* 									 *
* 	Anim func to start the seat on it's way up.			 *
* 									 *
* 	A8 = Ptr to any part of the mech-desk				 *
*								         *
**************************************************************************
A_START_SEAT_RISE
	MOVK	NUM_SEATL,A1
	CALLA	FINDPART		;Get the left half
	MOVI	ANIM_DOME_UP,A1
	CALLA	STRTANIM		;Start it up
	MOVE	*A0(OPARTS),A0,L	;Link on down to the right half
	JAUC	STRTANIM		;Start it up

**************************************************************************
*								         *
* 	A_DOME_UP							 *
* 									 *
* 	Anim func to move the dome up another notch during		 *
* 	transform.							 *
* 									 *
* 	A8 = Ptr to dome object						 *
*								         *
**************************************************************************
A_DOME_UP
	MOVE	*A8(OPARTSXY+16),A14,W
	SUBK	7,A14
	MOVE	A14,*A8(OPARTSXY+16),W
	CALLA	GET_HEAD_PART_A0
	CALLA	GETOFFPU
	MOVE	A8,A0
	JAUC	SETOFFPU

**************************************************************************
*								         *
* 	A_DOME_DONE							 *
* 									 *
* 	Anim func to perform the final shit on the dome after		 *
* 	it has risen.							 *
* 									 *
* 	A8 = Ptr to the dome object					 *
*								         *
**************************************************************************
A_DOME_DONE
	CLRM	*A8(OPARTSXY),L
	ANDNIM	M_OPARTSXY,*A8(OFLAGS),W
	CALLA	GET_HEAD_PART_A0
	CALLA	GETOFFPU
	MOVE	A8,A0
	JAUC	SETOFFPU

**************************************************************************
*								         *
* 	A_START_JOSH							 *
* 									 *
* 	Anim func to start the Josh character as mech-desk pilot.	 *
* 									 *
* 	A8 = Ptr to any part of the mech-desk				 *
*								         *
**************************************************************************
A_START_JOSH
	CALLA	GET_HEAD_PART_A0
	MOVIM	450,*A0(OTALK_WAIT),W		;Make sure he waits later
	MOVK	NUM_JOSH,A1
	CALLA	FINDPART
	MOVI	ANIM_JOSH_UP,A1
	JAUC	STRTANIM

**************************************************************************
*								         *
* 	A_START_COLLS							 *
* 									 *
* 	Anim func to start collisions for the desk			 *
* 									 *
* 	A8 = Ptr to any part						 *
*								         *
**************************************************************************
A_START_COLLS
	CALLA	GET_HEAD_PART
	MOVE	A8,A0
	MOVK	NUM_COLL_PARTS,A6	;Let's go through the parts and activate
	MOVI	DESK_GUNVECT,A5
	MOVI	DESK_CVECT,A4

ABS_COLL_LOOP
	MOVE	A4,*A0(OCVECT),L
	MOVE	A5,*A0(OGUNVECT),L

	MOVE	*A0(OPARTS),A0,L
	DSJS	A6,ABS_COLL_LOOP

	MOVK	NUM_DOME,A1
	CALLA	FINDPART
	ORIM	M_DEAD,*A0(OFLAGS),W
	MOVIM	DUMCOLL,*A0(OCVECT),L
	MOVIM	DOME_GUNVECT,*A0(OGUNVECT),L

	RETS

**************************************************************************
*								         *
* 	A_BATTLE_STATIONS						 *
* 									 *
* 	Anim func to make desk start attacking.				 *
* 									 *
* 	A8 = Ptr to any part						 *
*								         *
**************************************************************************
A_BATTLE_STATIONS
	CALLA	GET_HEAD_PART
	
	MOVIM	5*60,*A8(OMISSLE_WAIT),W	;Initial wait before 1st missle

	MOVK	NUM_GATL,A1		;Start the left Gatling gun.
	CALLA	FINDPART
	MOVI	ANIM_GAT_IDLE,A1
	CALLA	STRTANIM

	MOVE	*A0(OPARTS),A0,L	;Start the right Gatling gun.
	MOVI	ANIM_GAT_IDLE,A1
	CALLA	STRTANIM

	MOVK	NUM_MISSLE_DOOR,A1
	CALLA	FINDPART
	MOVI	ANIM_FRONT_MISSLE,A1
	CALLA	STRTANIM	    	;Start the front missle door.

	MOVK	NUM_SHOULDERL,A1	;Start the left shoulder.
	CALLA	FINDPART
	MOVI	ANIM_SHOULDER_MISSLE,A1
	CALLA	STRTANIM

	MOVE	*A0(OPARTS),A0,L	;Start the right shoulder.
	MOVI	ANIM_SHOULDER_MISSLE,A1
	CALLA	STRTANIM

	MOVK	NUM_GUN_ARM,A1		;Start the boundry checker.
	CALLA	FINDPART
	MOVI	ANIM_VELOCITY_WATCH,A1
	CALLA	STRTANIM

	MOVE	*A0(OPARTS),A0,L	;Start the movement.
	MOVI	ANIM_MOVEMENT,A1
	JAUC	STRTANIM

**************************************************************************
*								         *
* 	A_MULTI_METAL_CHUNK						 *
* 									 *
* 	Anim Func to call a fragger script for chunks randomly		 *
* 	picked from MULTI_METAL_CHUNK_TAB.				 *
* 									 *
* 	A8 = Ptr to object creating chunks				 *
*								         *
**************************************************************************
A_MULTI_METAL_CHUNK
	MOVK	NUM_METAL_CHUNKS,A0
	CALLA	RAND0
	SLL	5,A0
	ADDI	MULTI_METAL_CHUNK_TAB,A0
	MOVE	*A0,A0,L
	MOVE	A0,B14
	MOVI	[2,0],A0
	MOVI	400H,A3
	MOVI	[5,5],A4
	CALLA	PreFrag_Box
	JAUC	Fragger

**************************************************************************
*								         *
* 	A_START_MEDIUM_SHAKE						 *
* 									 *
* 	Anim Func to start a MEDIUM Desk shake.				 *
* 									 *
* 	A8 = Ptr to any part of the Desk				 *
*								         *
**************************************************************************
A_START_MEDIUM_SHAKE
	MOVK	NUM_MED_SHAKE,A1
	CALLA	FINDPART		;The foot rest will shake ust
	JRZ	ASMS_X			;BR = Couldn't find the part
	MOVI	ANIM_MEDIUM_SHAKE,A1	;Start a shaker anim
	CALLA	STRTANIM
ASMS_X
	RETS

**************************************************************************
*								         *
* 	A_START_BIG_SHAKE						 *
* 									 *
* 	Anim Func to start a BIG Desk shake.				 *
* 									 *
* 	A8 = Ptr to any part of the Desk				 *
*								         *
**************************************************************************
A_START_BIG_SHAKE
	MOVK	NUM_BIG_SHAKE,A1
	CALLA	FINDPART		;The foot rest will shake ust
	JRZ	ASBS_X			;BR = Couldn't find the part
	MOVI	ANIM_BIG_SHAKE,A1	;Start a shaker anim
	CALLA	STRTANIM
ASBS_X
	RETS

**************************************************************************
*								         *
* 	A_TURN_ON_EYE_DAMAGE						 *
* 									 *
* 	Anim func to turn on the damage for one of the			 *
* 	eye pieces.							 *
* 									 *
* 	A8 = Ptr to eye that's damaged					 *
*								         *
**************************************************************************
A_TURN_ON_EYE_DAMAGE
	MOVB	*A8(OPARTID),A1
	SUBK	NUM_EYEL,A1
	ADDK	NUM_EYE_DAMAGE,A1
	CALLA	FINDPART
	MOVI	ANIM_EYE_DAMAGE,A1
	JAUC	STRTANIM

**************************************************************************
*								         *
* 	A_TURN_ON_FRONT_DAMAGE						 *
* 									 *
* 	Anim func to turn on the damage for the front door.		 *
* 									 *
* 	A8 = Ptr to front piece.					 *
*								         *
**************************************************************************
A_TURN_ON_FRONT_DAMAGE
	MOVK	NUM_MISSLE_DOOR,A1
	CALLA	FINDPART
	MOVI	ANIM_FRONT_DAMAGE,A1
	JAUC	STRTANIM

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

	MOVE	A0,A7

	MOVIB	100,*A0(OCLRFDAM)	;Delay clearing for this many ticks

	MOVB	*A8(OPARTID),A4		;Let's find out about this part

	CMPK	NUM_GATL,A4
	JREQ	ACIF_IS_GAT
	CMPK	NUM_GATR,A4
	JRNE	ACIF_CK_LAUNCHER
ACIF_IS_GAT
	INCB	*A0(OGATS_GONE)		;Chalk up another gun death
	JRUC	ACIF_VITALS
ACIF_CK_LAUNCHER
	CMPK	NUM_SHOULDERL,A4
	JREQ	ACIF_IS_LAUNCHER
	CMPK	NUM_SHOULDERR,A4
	JREQ	ACIF_IS_LAUNCHER
	CMPK	NUM_FRONT,A4
	JRNE	ACIF_VITALS
ACIF_IS_LAUNCHER
	INCB	*A0(OMLAUNCH_GONE)
ACIF_VITALS
	MOVK	NUM_SHOULDERL,A1
	CALLA	FINDPART

	MOVE	*A0(OFLAGS),A14,W	;Check LEFT shoulder
	BTST	B_DEAD,A14
	JRZ	ACIF_NOT_FINAL		;BR = Not dead, can't be time

	MOVE	*A0(OPARTS),A0,L
	MOVE	*A0(OFLAGS),A14,W
	BTST	B_DEAD,A14	 	;Check RIGHT shoulder
	JRZ	ACIF_NOT_FINAL		;BR = Not dead

	MOVK	NUM_GATL,A1
	CALLA	FINDPART

	MOVE	*A0(OFLAGS),A14,W	;Check LEFT gatlin gun
	BTST	B_DEAD,A14
	JRZ	ACIF_NOT_FINAL		;BR = Not dead, can't be time

	MOVE	*A0(OPARTS),A0,L
	MOVE	*A0(OFLAGS),A14,W
	BTST	B_DEAD,A14	 	;Check RIGHT gatlin gun
	JRZ	ACIF_NOT_FINAL		;BR = Not dead

	MOVE	*A0(OPARTS),A0,L
	MOVE	*A0(OFLAGS),A14,W
	BTST	B_DEAD,A14	 	;Check FRONT piece
	JRZ	ACIF_NOT_FINAL		;BR = Not dead

*All vital parts are gone here
	MOVB	*A7(OPARTS_LOST),A14
	CMPK	9,A14	     		;Did player kill them all?
	JRLO	ACIF_GO_FINAL		;BR = No

	MOVKM	1,@DESK_TOTAL,W		;Flag the full kill
	JRUC	ACIF_GO_FINAL

*
*A8 = ptr to part that just blew up
*
ACIF_NOT_FINAL
	CMPK	NUM_FRONT,A4
	JRHI	ACIF_X

;	MOVE	A4,A6
;	DEC	A6
;	SRL	1,A6
;	SLL	3,A6
;	ADDI	TAB_FINAL_SNUMS,A6
;	MOVB	*A6,A6

;	MOVI	NUM_JOSH,A1
;	CALLA	FINDPART

;	MOVB	A6,*A0(OTALK_FLAG)
ACIF_X
	RETS

*Start the final explosion
*A7 = Ptr to head-part
ACIF_GO_FINAL
	MOVE	A8,A1
	MOVE	A7,A8
	CALLA	ALL_COLLS_OFF
	MOVE	A1,A8

	MOVKB	1,*A7(OFDAM_GOING)		;Flag the final damage
;	MOVIM	1,@GUNS_OFF,W
	MOVIM	1,@NO_CHARITY,W			;Kill the charity

	MOVK	NUM_SEATL,A1
	CALLA	FINDPART
	MOVI	ANIM_FINAL_EXPLOSION,A1
	CALLA	STRTANIM

	MOVIM	1000,*A7(OTALK_WAIT),W		;We can't talk anymore
	MOVK	SNUM_DESK_DESTROY,A0
	JRUC	A_SUB_SND_G	


TAB_FINAL_SNUMS
	.BYTE	SNUM_USELESS, SNUM_FORGIVE, SNUM_USELESS
	.BYTE	SNUM_BEAST, SNUM_HURT_DESK
	.EVEN

**************************************************************************
*								         *
* 	A_SELECT_GAT_IDLE_TIME						 *
* 									 *
* 	Anim Func to select idle time for a Gatlin gun.			 *
* 	Time is placed in the AnimSLP field of the gat object.		 *
*								         *
**************************************************************************
A_SELECT_GAT_IDLE_TIME
	MOVK	5,A0
	MOVI	20,A1
	CALLA	RANGERND
	MOVB	A0,*A8(AnimSLP)
	RETS

**************************************************************************
*								         *
* 	A_GAT_DECISION							 *
* 									 *
* 	Anim Func to make decisions for the Gatling gun.		 *
* 									 *
* 	AARG+,W = Number of animation we are coming from.		 *
*								         *
**************************************************************************
A_GAT_DECISION
	CALLA	GET_HEAD_PART_A0
	MOVE	A0,A7			;Head ptr to stay here for duration

	CALLA	GETAFARG_WORD
	JRZ	AGD_RETURN_FROM_IDLE	;BR = We just returned from idle

AGD_DO_IDLE
	MOVI	ANIM_GAT_IDLE,A1	;and run the idle sequence before
	JAUC	SetAnim			;we continue.

AGD_RETURN_FROM_IDLE
	MOVB	*A7(OFDAM_GOING),A14	;If damage show going then no arm action
	JRNZ	AGD_DO_IDLE		;BR = It is, so don't

	MOVI	800,A0
	CALLA	RANDPER
	JRNC	AGD_DO_IDLE

	MOVI	ANIM_GAT_SHOOT,A1
	JAUC	SetAnim

**************************************************************************
*								         *
* 	A_RANDOM_BURST_COUNT						 *
* 									 *
* 	Anim Func to load a random Burst count.				 *
* 									 *
* 	A8 = Ptr to part doing the firing				 *
*								         *
**************************************************************************
A_RANDOM_BURST_COUNT
	MOVK	1,A0
	MOVK	3,A1
	CALLA	RANGERND
	MOVB	A0,*A8(OBURSTCNT)
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
A_GAT_BURST_DECISION
	MOVB	*A8(OBURSTCNT),A14
	DEC	A14
	MOVB	A14,*A8(OBURSTCNT)
	JANZ	SetAnim_AFARG
	RETS

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
	MOVK	3,A0
	MOVK	12,A1
	CALLA	RANGERND
	MOVB	A0,*A8(ORAPIDCNT)
	RETS

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
A_GAT_RAPIDFIRE_DECISION
	MOVB	*A8(ORAPIDCNT),A14
	DEC	A14
	MOVB	A14,*A8(ORAPIDCNT)
	JANZ	SetAnim_AFARG
	RETS

**************************************************************************
*								         *
* 	A_GAT_FIRE_FNC							 *
* 									 *
* 	Anim Func for Gatling gun firing on the player(s).		 *
* 									 *
* 	A8 = Ptr to gat doing the firing.				 *
* 	AARG+,L = [Y,X] firing offset for the gun			 *
*								         *
**************************************************************************
A_GAT_FIRE_FNC
	MOVB	*A8(O_BEING_DAMAGED),A14 ;Object being damaged?
	JRN	AGFF_X			;BR = Yes

	CALLA	GETAFARG_LONG		;Get the firing offset for the gun

	MOVB	*A8(OBARREL),A14
	MOVE	A14,B14
	INC	B14			;Fire out of the next barrel
	CMPK	NUM_GUN_FLASHES-1,B14	;Did we wrap?
	JRLS	AGFF_LOAD_FLASH		;BR = No
	CLR	B14
AGFF_LOAD_FLASH
	MOVE	B14,A14
	MOVB	A14,*A8(OBARREL)
	SLL	5,B14
	ADDI	GUN_FLASH_TABLE,B14
	MOVE	*B14,B0,L	

	MOVE	A0,A3
	PUSH	A3
	INCB	*A8(OSHOTS_TAKEN)

	CALLA	EASYMAKE
	JRZ	AGFF_NO_OBJ		;BR = Creation failed, exit.

	MOVE	*A8(OXVAL),A1,L
	MOVE	*A8(OYVAL),A2,L
	MOVE	*A8(OZVAL),A3,L

	CALLA	SETOFFPU

	CALLA	INSPART

	MOVE	*A8(OCTRL),A5,W
	ANDI	M_FLIPH|M_FLIPV,A5	;ISOLATE FLIP BITS ONLY
	ORM	A5,*A0(OCTRL),W

	CALLA	INSOBJ
AGFF_NO_OBJ
	PULLQ	A3

;	MOVI	[2,0],A5
	MOVE	@BASE_HIT,A5,W
	ADDI	800H,A5
	SLL	4,A5

	CALLA	CK_PLAYER_HIT
	JRNZ	AGFF_HIT     		;BR = Successful hit on Player(s)
	JRNC	AGFF_NOHIT		;BR = No hit, but he was visible
 	JRUC	AGFF_NOHIT_NO_SOUND	;He didn't hit because he was not visible
AGFF_HIT
	CLRB	*A8(OMISSES)
	SOUNDZ	SND_DESK_GUN
	JRUC	AGFF_X
AGFF_NOHIT
	SOUNDZ	SND_DESK_GUN
	CALLA	GET_HEAD_PART_A0

	MOVB	*A0(OMLAUNCH_GONE),A14
	CMPK	3,A14		      	;Are we missing all of our Rocket launchers?
	JRLO	AGFF_NOHIT_NO_SOUND	;BR = No, we still have protection

	MOVB	*A0(OGATS_GONE),A14	;Are we missing a gat?
	JRZ	AGFF_NOHIT_NO_SOUND	;BR = No, we still have protection

;	MOVI	[1,0],A5
	MOVE	@BASE_HIT,A5,W
	SUBI	800H,A5
	SLL	4,A5

	ALLPLYR	PLAYER_HIT		;Hit 'em all, 'cause we're down.

AGFF_NOHIT_NO_SOUND
	INCB	*A8(OMISSES)
AGFF_X
	RETS

**************************************************************************
*								         *
* 	A_MAKE_NOOO							 *
* 									 *
* 	Anim func to make the Nooo! sound when final destruction	 *
* 	is near.							 *
* 									 *
* 	A8 = Ptr to part doing the final explode animation		 *
*								         *
**************************************************************************
A_MAKE_NOOO
	MOVB	*A8(AnimLoop),A14
	CMPK	5,A14
	JRNE	AMN_X

	MOVI	NUM_JOSH,A1
	CALLA	FINDPART
	MOVKB	SNUM_NOOO,*A0(OTALK_FLAG)
	RETS

AMN_X	
	RETS

**************************************************************************
*								         *
* 	A_GOOD_TO_GO							 *
* 									 *
* 	Anim func to set up Desk for the final explode.			 *
* 									 *
* 	A8 = ptr to any desk part.					 *
*								         *
**************************************************************************
A_GOOD_TO_GO
	CALLA	GET_HEAD_PART
	CLRB	*A8(OCENTER_FLAG)	;No more centering

	MOVI	OID_INFOTEXT,A0
	CALLA	KILOBJ_ALL		;Kill any text

	MOVK	NUM_GUN_ARM+1,A1
	CALLA	FINDPART
	CALLA	PULLANIM

	MOVK	NUM_SMALL_SHAKE,A1
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
* 	A_KEEP_US_CENTERED						 *
* 									 *
* 	Anim Func to keep the OCENTERED flag set.			 *
* 									 *
* 	A8 = Ptr to any desk part.					 *
*								         *
**************************************************************************
A_KEEP_US_CENTERED
	CALLA	GET_HEAD_PART_A0
	MOVKB	2,*A0(OCENTER_FLAG)
	MOVIB	120,*A0(OCLRCENTER)
	RETS

**************************************************************************
*								         *
* 	A_DELETE_CREATE							 *
* 									 *
* 	Anim Func to delete the whole desk multi-parter,		 *
* 	no matter what part is calling. Then start Mondor in		 *
* 	it's place							 *
* 									 *
* 	A8 = Ptr to any part						 *
*								         *
**************************************************************************
A_DELETE_CREATE
	CALLA	GET_HEAD_PART
	PUSH	A8
	MOVI	200,A8			;Delay before desk comes down
;	CREATE	PID_MONDOR,MONDOR_PROC
	PULLQ	A8
	JAUC	DELETE_ENEMY		;Now rid yourself of the desk

**************************************************************************
*								         *
* 	A_ADD_YPOS							 *
* 									 *
* 	Anim func to add a value to OYPOS.				 *
* 									 *
* 	A8 = Object to add to						 *
* 	AARG+,W = Amount to add						 *
*								         *
**************************************************************************
A_ADD_YPOS
	CALLA	GETAFARG_WORD
	ADDRM	A0,*A8(OYPOS),W
	RETS

**************************************************************************
*								         *
* 	A_BRANCH_PCNT							 *
* 									 *
* 	Anim func to branch animation script a given percentage of	 *
* 	the time.							 *
* 									 *
* 	A8 = Ptr to object to branch					 *
* 	AARG+,W = Percent chance of branch				 *
* 	AARG+,L = Branch						 *
*								         *
**************************************************************************
A_BRANCH_PCNT
	CALLA	GETAFARG_WORD		;Get percentage
	CALLA	RANDPER			;Should we do it?
	JAC	SetAnim_AFARG		;BR = Yes
	RETS

**************************************************************************
*								         *
* 	A_INIT_EYE_DAMAGE						 *
* 									 *
* 	Anim func to initialize an eye damage piece.			 *
* 									 *
* 	A8 = Ptr to eye damage object					 *
*								         *
**************************************************************************
A_INIT_EYE_DAMAGE
	ORIM	M_NOSHADOW,*A8(OFLAGS),W
	MOVE	A8,A0
	CALLA	DELSHAD
	CALLA	OBJ_OFF
	MOVI	C_DAMGE_P,A0
	JAUC	CHANGE_PAL

**************************************************************************
*								         *
* 	A_CONTINUE_PART_FINAL						 *
* 									 *
* 	Anim func to grab OPART_FINAL_CONT and anim jump to it.		 *
* 	Unless it is 0, then fall through.				 *
* 									 *
* 	A8 = Ptr to part finally exploding				 *
*								         *
**************************************************************************
A_CONTINUE_PART_FINAL
	MOVE	*A8(OPART_FINAL_CONT),A1,L
	JANZ	SetAnim
	RETS

**************************************************************************
*								         *
* 	SPAWN_FIRE							 *
* 									 *
* 	Spawn a fire at a given offset and make it part of the 		 *
* 	Multi-parter.							 *
* 									 *
* 	A3 = OPARTSXY (unflipped)					 *
* 	A8 = Spawning object						 *
* 	A9 = Offset to add to OZOFF of spawner				 *
* 	B0 = Init table of fire						 *
*								         *
**************************************************************************
SPAWN_FIRE
	MMTM	SP,A0,A1,A2,A3,A7,A8
	MMTM	SP,B0,B1,B2,B3,B4,B5,B6,B7,B8,B9,B10
	CALLR	ASF_G
	MMFM	SP,B0,B1,B2,B3,B4,B5,B6,B7,B8,B9,B10
	MMFM	SP,A0,A1,A2,A3,A7,A8
	RETS
	
**************************************************************************
*								         *
* 	A_SPAWN_FIRE							 *
* 									 *
* 	Anim func to spawn a fire that will become part of the		 *
* 	multi-parter.							 *
* 									 *
* 	A8 = Ptr to part that is on fire				 *
* 	AARG+,L = Init table of fire					 *
* 	AARG+,L = OPARTSXY of fire					 *
* 	AARG+,W = Offset to add to parts OZOFF to get flames		 *
*								         *
**************************************************************************
A_SPAWN_FIRE
	CALLA	GETAFARG_LONG
	MOVE	A0,B0			;Got init table

	CALLA	GETAFARG_LONG
	MOVE	A0,A3			;Got OPARTSXY

	CALLA	GETAFARG_WORD
	MOVE	A0,A9			;Got Offset for OZOFF

ASF_G
	CALLA	EASYMAKE
	JRZ	ASF_X  			;No objects available

	CALLA	CLRODATA		;Clear for good measure

	MOVE	*A8(OCTRL),A7,W	     	;Adjust offset if necessary
	BTST	B_FLIPH,A7
	JRZ	ASF_CHECKV
	NEGX	A3
ASF_CHECKV
	BTST	B_FLIPV,A7
	JRZ	ASF_NOV			;BR=NO FLIP ADJUSTMENT
	NEGY	A3
ASF_NOV

	MOVE	A3,*A0(OPARTSXY),L	;Just to position us

	ANDI	M_FLIPH|M_FLIPV,A7	;ISOLATE FLIP BITS ONLY
	MOVE	*A0(OCTRL),A14,W
	OR	A14,A7			;Match flip to spawing object
	MOVE	A7,*A0(OCTRL),W

	MOVB	*A8(OZOFF),A14
	ADD	A9,A14
	MOVB	A14,*A0(OZOFF)		;Set us in given Z proximity

	CALLA	GET_HEAD_PART		;Use the head part as a good source

	MOVE	*A8(OXVAL),A1,L
	MOVE	*A8(OYVAL),A2,L
	MOVE	*A8(OZVAL),A3,L

	CALLA	SETOFFPU

	CALLA	INSPART

	CALLA	INSOBJ

ASF_X
	RETS

**************************************************************************
*								         *
* 	A_INITIAL_SHOULDER_FREAK					 *
* 									 *
* 	Anim func to set up the first part of the shoulder freak	 *
* 	out when it gets destroyed.  Basically brings it back home.	 *
* 									 *
* 	A8 = Ptr to shoulder object					 *
* 	AARG+,L = Animation branch if shoulder is home			 *
*								         *
**************************************************************************
A_INITIAL_SHOULDER_FREAK
	CALLA	GET_HEAD_PART_A0
	MOVE	*A8(OYPOS),A1,W
	MOVE	*A0(OYPOS),A2,W
	SUB	A1,A2			;Get the difference in position
	ABS	A2
	SRL	2,A2			;Divide by move increments
	JAZ	SetAnim_AFARG		;BR = There is nothing left.
	MOVB	A2,*A8(AnimLoop)
	RETS

**************************************************************************
*								         *
* 	A_CHECK_OK_MISSLE						 *
* 									 *
* 	Anim func to check if it is O.K. to open a missle bay		 *
* 	for firing.  If not, then take anim branch.			 *
* 									 *
* 	A8 = Ptr to part wishing to open				 *
* 	AARG+,L = Anim branch to take if not O.K. to open		 *
*								         *
**************************************************************************
A_CHECK_OK_MISSLE
	CALLA	GET_HEAD_PART_A0
	MOVE	*A0(OMISSLE_WAIT),A14,W	;Are we being forced to wait on next?
	JRNZ	ACOM_NOT_OK		;BR = Yes, then wait
	MOVB	*A0(OFIRING_MISSLE),A14	;Is another door open?
	JRZ	ACOM_OK			;BR = No
ACOM_NOT_OK
	CALLA	GETAFARG_LONG
	MOVE	A0,A1
	MOVE	A1,*A8(AnimFrm),L
	RETS
ACOM_OK
	MOVB	*A8(OPARTID),*A0(OFIRING_MISSLE) ;Mark it open for us
	RETS

**************************************************************************
*								         *
* 	A_CLR_MISSLE_OPEN						 *
* 									 *
* 	Anim func to clear the OFIRING_MISSLE_FLAG			 *
* 									 *
* 	A8 = Ptr to any part of desk					 *
*								         *
**************************************************************************
A_CLR_MISSLE_OPEN
	CALLA	GET_HEAD_PART_A0
	MOVB	*A0(OFIRING_MISSLE),A1
	MOVB	*A8(OPARTID),A14
	CMP	A1,A14			;Were we the ones firing missles?
	JRNE	ACMO_X			;BR = No
      	CLRB	*A0(OFIRING_MISSLE)	;We are in control so we can clear
ACMO_X
	RETS

**************************************************************************
*								         *
* 	A_MISSLE_TARGET							 *
* 									 *
* 	Anim func to set up the velocities and what not for		 *
* 	the missle.							 *
* 									 *
* 	A8 = ptr to the missle object					 *
*								         *
**************************************************************************
A_MISSLE_TARGET
	MOVI	800,A0
	CALLA	RANDPER			;This is the chance that we target
	JRNC	AMT_FULL_SCREEN		;BR = Not this time

	CALLA	GET_PLAYER_EXTENTS
	JRUC	AMT_PICK_TARGET

AMT_FULL_SCREEN
	MOVI	[SCRTOP+SKYTOPOF,SCRLFT],A2
	MOVI	[SCRBOT,SCRRGT],A3

AMT_PICK_TARGET
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

	MOVE	*A8(OPART1),A14,L		;Is this stuck on?
	JRZ	AMT_LOAD_VEL			;BR = No
	CALLA	PULL_PART			;Pull it before setting vels
AMT_LOAD_VEL
	CALLA	SLINEVEL_LOAD_3D

	MOVE	*A8(OPROJECT_PARENT),A0,L	;Get the guy that created us
	INCB	*A0(OMISSLES_FIRED)		;We fired one more

	CALLA	GETHEADPART			;Get some head

	MOVIB	60,*A0(OPROJ_CK_TIME)		;Check for hits after this much time

	SOUND1	SND_MISSLE_LAUNCH

	RETS

**************************************************************************
*								         *
* 	A_WAIT_FOR_MISSLES						 *
* 									 *
* 	Anim func to check if any projectiles exist with their		 *
* 	OPROJECT_PARENT equal to A8.					 *
* 									 *
* 	A8 = Ptr to owner of missles					 *
* 	AARG+,L	= Branch if missles still exist				 *
*								         *
**************************************************************************
A_WAIT_FOR_MISSLES
	MOVK	NUM_LAST_PART,A1
	CALLA	FINDPART
	JRUC	AWFM_TST_NEXT

AWFM_TST_LOOP
	MOVE	*A0(OPROJECT_PARENT),A14,L
	CMP	A14,A8	     		;Is this my missle?
	JRNE	AWFM_TST_NEXT		;BR = No

	CALLA	GETAFARG_LONG
	MOVE	A0,*A8(AnimFrm),L	;We found one, so branch animation
	RETS

AWFM_TST_NEXT
	MOVE	*A0(OPARTS),A0,L
	JRNZ	AWFM_TST_LOOP

	CALLA	GET_HEAD_PART_A0

	MOVB	*A8(OMISSLES_FIRED),A14	;Did we fire any of our missles?
	JRNZ	AWFM_LAUNCHED		;BR = Yes, then player is not that cool

	MOVI	6*60,A1
	CALLR	SET_MISSLE_WAIT
	MOVE	*A0(OMISSLE_WAIT),A14,W	;Are we waiting?
	JREQ	AWFM_NO_VULNER		;BR = No
	MOVKB	1,*A0(OMISSLE_VULNER)	;Make all missle launchers vulnerable
AWFM_NO_VULNER
	MOVK	NUM_JOSH,A1
	CALLA	FINDPART			;A0 gets wiped here
	MOVKB	SNUM_PISSED,*A0(OTALK_FLAG)	;Make Josh react to this
	JRUC	AWFM_X

AWFM_LAUNCHED
	MOVI	3*60,A1
	CALLR	SET_MISSLE_WAIT

AWFM_X
	RETS		     		;None exist, fall through

**************************************************************************
*								         *
* 	A_SET_MISSLE_WAIT						 *
* 									 *
* 	Anim func to set the wait time before the next missle		 *
* 	launcher is allowed to open.					 *
* 									 *
* 	A8 = Ptr to any part of desk.					 *
* 	AARG+,W = Wait time, in ticks					 *
*								         *
**************************************************************************
A_SET_MISSLE_WAIT
	CALLA	GETAFARG_WORD
	MOVE	A0,A1
	CALLA	GET_HEAD_PART_A0
*
* Entrypoint: SET_MISSLE_WAIT
*	A0 = Ptr to desk master part
*	A1 = Wait time
SET_MISSLE_WAIT
	MOVE	*A0(ONOGAT_TIME),A14
	CMPI	NOGATS_PISSED,A14   	;Have we been without for too long?
	JRHS	ASMW_X			;BR = Yes, then no missle waiting
	MOVE	A1,*A0(OMISSLE_WAIT),W
ASMW_X
	RETS

**************************************************************************
*								         *
* 	A_DESTROY_MISSLES						 *
* 									 *
* 	Anim func to destroy all missles attached to this object.	 *
* 									 *
* 	A8 = Missle launch object.					 *
*								         *
**************************************************************************
A_DESTROY_MISSLES
	MOVK	NUM_LAST_PART,A1
	CALLA	FINDPART

	MOVI	ANIM_MISSLE_EXPLODE,A1	;We need this to start kill anim

	JRUC	ADM_TST_NEXT

ADM_TST_LOOP
	MOVE	*A0(OPROJECT_PARENT),A14,L
	CMP	A14,A8	     		;Is this my missle?
	JRNE	ADM_TST_NEXT		;BR = No

	MOVE	*A0(OPARTS),A2,L	;Grab the next image in the multi-part
	CALLA	COLLSOFF		;Null it
	CALLA	PULLPART		;Pull it
	CALLA	STRTANIM		;Blow it
	MOVE	A2,A0			;Let's proceed
	JRNZ	ADM_TST_LOOP		;BR = This was not the last object
	RETS
	
ADM_TST_NEXT
	MOVE	*A0(OPARTS),A0,L
	JRNZ	ADM_TST_LOOP
	RETS		     		;None exist, fall through
	
**************************************************************************
*								         *
* 	A_MAKE_SMOKE							 *
* 									 *
* 	Anim func to make the lauch smoke for a missle.			 *
* 									 *
* 	A8 = Ptr to missle launching					 *
*								         *
**************************************************************************
A_MAKE_SMOKE
	CALLA	CREATE_COPY	;Copy us an object to use as smoke
	JRNZ	AMS_GO		;BR = Got the smoke now toke
      	RETS
AMS_GO
	CALLA	CLRODATA	;Whack the data area
	CALLA	OBJOFF		;Turn the object off for now
	CALLA	COLLSOFF	;Null the colls

	INCB	*A0(OZOFF)	;Move Z one behind the missle

	CALLA	INSPART		;Make it part of the Multi-parter
	CALLA	INSOBJ		;Now make it part of the world

	MOVI	ANIM_MISSLE_SMOKE,A1
	JAUC	STRTANIM	;Make it animate

**************************************************************************
*								         *
* 	A_CHECK_MISSLE_PAUSE						 *
* 									 *
* 	Anim func to check if we should pause before firing		 *
* 	missles from bay.  Uses the value in OMISSLE_PERC stored	 *
* 	in the master part.  This value is the % chance that we		 *
* 	will pause.  Pausing is done by not branching the animation.	 *
* 									 *
* 	A8 = Ptr to missle bay						 *
* 	AARG+,L = Branch for no pause					 *
*								         *
**************************************************************************
A_CHECK_MISSLE_PAUSE
	CALLA	GET_HEAD_PART_A0
	MOVE	*A0(OMISSLE_PERC),A0,W	;Grab the pause percentage
	CALLA	RANDPER			;Should we pause
	JANC	SetAnim_AFARG		;BR = No
	RETS

**************************************************************************
*								         *
* 	A_SPAWN_N_MISSLES						 *
* 									 *
* 	Anim Func to spawn the given number of missles from a		 *
* 	table of offsets.						 *
* 									 *
* 	Offsets are OPARTSXY from the head of the Multiparter.		 *
* 									 *
* 	AARG+,L	= Offset table.						 *
* 	AARG+,W = Number of offsets (max missles allowed).		 *
* 	AARG+,W	= Minimum missles to spawn.				 *
*								         *
**************************************************************************
A_SPAWN_N_MISSLES
	CALLA	GETAFARG_LONG
	MOVE	A0,A5			;Get the offset table
	CALLA	GETAFARG_WORD
	MOVE	A0,A4			;And the offset count
	CALLA	GETAFARG_WORD
	MOVE	A0,A1
	MOVE	A4,A0
	CALLA	RANGERND		;A little randy action
	MOVE	A0,A6			;And the missle count

	MOVK	10,A2			;Maximum tries

	CLR	A7			;This is our random marker

	CLRB	*A8(OMISSLES_FIRED)	;Clear the missles fired counter

ASTM_RAND_LOOP
	MOVE	A4,A0
	CALLA	RAND0
	BTST	A0,A7			;Have we picked this already?
	JRZ	ASTM_LAUNCH_IT		;BR = No, use it
	DSJS	A2,ASTM_RAND_LOOP	;Try again if we're allowed

	MOVE	A4,A14	      		;We've exhausted all tries
	CLR	A0			;Let's just step through the list
ASTM_DEFAULT_LOOP
	BTST	A0,A7			;Taken?
	JRZ	ASTM_LAUNCH_IT		;BR = No, use it
	INC	A0			;Get next
	DSJS	A14,ASTM_DEFAULT_LOOP
	RETS				;No offsets left, so bail

ASTM_LAUNCH_IT
	BSET	A0,A7			;Mark this as taken
	SLL	5,A0
	ADD	A5,A0
	MOVE	*A0,A3,L		;Get the offset
	CALLR	SPAWN_MISSLE		;DooDoo brown
	DSJ	A6,ASTM_RAND_LOOP

	RETS				;We've finished all of our work

**************************************************************************
*								         *
* 	SPAWN_MISSLE							 *
* 									 *
* 	Spawn a baby missle, to become part of the multi-parter desk.	 *
* 	OPROJECT_PARENT set to A8.					 *
* 									 *
* 	A3 = [Y,X] offset						 *
* 	A8 = Ptr to object firing missle				 *
* 									 *
* 	Returns:							 *
* 		 Z = No missle spawned					 *
* 		NZ = Missle spawned successfully			 *
*								         *
**************************************************************************
SPAWN_MISSLE
	MMTM	SP,A0,A1,A2,A3,A7,A8
	PUSH	B0

	MOVI	MISSLE_INIT,B0

	CALLA	EASYMAKE
	JRZ	SM_X  			;No objects available

	MOVE	*A8(OCTRL),A7,W	     	;Adjust offset if necessary
	BTST	B_FLIPH,A7
	JRZ	SM_CHECKV
	NEGX	A3
SM_CHECKV
	BTST	B_FLIPV,A7
	JRZ	SM_NOV			;BR=NO FLIP ADJUSTMENT
	NEGY	A3
SM_NOV

	MOVE	A3,*A0(OPARTSXY),L	;Just to position us

	ANDI	M_FLIPH|M_FLIPV,A7	;ISOLATE FLIP BITS ONLY
	MOVE	*A0(OCTRL),A14,W
	OR	A14,A7			;Match flip to spawing object
	MOVE	A7,*A0(OCTRL),W

	MOVE	A8,*A0(OPROJECT_PARENT),L	;Tell us our roots

	MOVB	*A8(OZOFF),A14
	SUBK	2,A14
	MOVB	A14,*A0(OZOFF)		;Set us just in front of our buddy

	MOVE	*A8(OXVAL),A1,L
	MOVE	*A8(OYVAL),A2,L

	CALLA	GET_HEAD_PART		;Use the head part as a good source

	MOVE	*A8(OZVAL),A3,L

	CALLA	SETOFFPU

	CALLA	INSPART

	CALLA	INSOBJ

	MOVE	A0,A0			;Set flag for success
SM_X
	PULL	B0
	MMFM	SP,A0,A1,A2,A3,A7,A8
	RETS

**************************************************************************
*								         *
* 	C_MISSLE							 *
* 									 *
* 	Create function for desk's missles				 *
* 									 *
* 	A0 = ptr to un-inserted missle object				 *
*								         *
**************************************************************************
C_MISSLE
	CLR	A14
	MOVB	A14,*A0(OCHEWEDROCKET)
	MOVIM	0101H,*A0(OCONST),W
	RETS

**************************************************************************
*								         *
* 	A_SELECT_JOSH_IDLE_TIME						 *
* 									 *
* 	Anim Func to select idle time for the Josh.			 *
* 	Time is placed in the AnimSLP field of the Josh object.		 *
*								         *
**************************************************************************
A_SELECT_JOSH_IDLE_TIME
	MOVK	1,A0
	MOVI	60,A1
	CALLA	RANGERND
	MOVB	A0,*A8(OJOSH_IDLE)
	RETS

**************************************************************************
*								         *
* 	A_JOSH_DECISION							 *
* 									 *
* 	Anim Func to make decisions for Josh.				 *
* 									 *
* 	AARG+,W = Number of animation we are coming from.		 *
*								         *
**************************************************************************
A_JOSH_DECISION
	CALLA	GET_HEAD_PART_A0
	MOVE	A0,A7			;Head-part stays in A7 for this func

	CALLA	GETAFARG_WORD
	MOVB	A0,*A8(OLASTANUM)	;Store where we just came from
	JRZ	AJD_RETURN_FROM_IDLE	;BR = We just returned from idle

	CLRB	*A8(OJOSH_ACTION)	;Clear the action flag
AJD_DO_IDLE
	MOVI	ANIM_JOSH_IDLE,A1	;and run the idle sequence before
	JAUC	SetAnim			;we continue.

AJD_RETURN_FROM_IDLE

*Check to see if it's time to talk at the player
	MOVB	*A8(OTALK_FLAG),A1
	JRZ	AJD_NO_TALK		;BR = No talking now
	
	SUBK	SNUMS_UNDER_DOME,A1
	SLL	5,A1
	ADDI	JOSH_VOCALS,A1

	MOVE	*A1,A1,L		;Grab the proper script

	MOVIM	450,*A7(OTALK_WAIT),W	;Make Josh wait before casual conversation

	CLRB	*A8(OTALK_FLAG)

	JAUC	SetAnim

AJD_NO_TALK

*Check to see if we should do some action
	MOVB	*A8(OJOSH_ACTION),A1	;Are we ready for action?
	JRZ	AJD_NO_ACTION
	CMPK	ANUM_STEER_L,A1		;Are we currently steering?
	JREQ	AJD_NO_STEER		;BR = Yes, then don't do it again
	CMPK	ANUM_STEER_R,A1
	JREQ	AJD_NO_STEER		;BR = Yes, then don't do it again

AJD_LOAD_ACTION
	SLL	5,A1
	ADDI	JOSH_ACTIONS,A1
	MOVE	*A1,A1,L
	JAUC	SetAnim

AJD_NO_ACTION
*Check if we should steer the craft
	MOVB	*A7(OXBURN),A14		;Are we firing our jets?
	CMPK	5,A14	    		;Is it worth the effort?
	JRLS	AJD_NO_STEER		;BR = No
	MOVB	A14,*A8(OJOSH_IDLE)	;This is the steer time
	MOVE	*A7(OXACCEL),A14	;Base our direction on the accel
	JRN	AJD_STEER_LEFT

	MOVK	ANUM_STEER_R,A1		;Steer us to the right
	JRUC	AJD_DO_STEER

AJD_STEER_LEFT
	MOVK	ANUM_STEER_L,A1		;Steer us to the left
AJD_DO_STEER
	MOVB	A1,*A8(OJOSH_ACTION)
	JRUC	AJD_LOAD_ACTION

AJD_NO_STEER
	MOVB	*A8(OJOSH_IDLE),A14
	DEC	A14
	MOVB	A14,*A8(OJOSH_IDLE)
	JRZ	AJD_IDLE_DONE

	RETS

AJD_IDLE_DONE

	MOVE	*A7(OTALK_WAIT),A14	;Can we talk now?
	JRNZ	AJD_IDLE_IT_IS		;BR = No, just idle

	MOVB	*A7(OFDAM_GOING),A14	;No random babbling during big damage
	JRNZ	AJD_IDLE_IT_IS

	MOVK	8,A5
	MOVE	*A8(OBABBLE_BITS),A6,W

AJD_TRY_BABBLE_AGAIN
	MOVK	NUM_BABBLINGS,A0	;Do a little babbling
	CALLA	RAND0

	BTST	A0,A6			;Have we babbled this yet?
	JRZ	AJD_BABBLE_OK		;BR = No

	DSJS	A5,AJD_TRY_BABBLE_AGAIN
*Here we have failed to randomly babble, we'll just select
	MOVK	NUM_BABBLINGS,A5
	CLR	A0			;Walk down babble list until we get one
AJD_WALK_BABBLE
	BTST	A0,A6			;Is this a good one?
	JRZ	AJD_BABBLE_OK		;BR = Yes, then use it
	INC	A0			;Next
	DSJS	A5,AJD_WALK_BABBLE
	JRUC	AJD_IDLE_IT_IS		;BR = Error, no babbles left

AJD_BABBLE_OK
	BSET	A0,A6			;Flag this as babbled

	SLL	32-NUM_BABBLINGS,A6
	SRL	32-NUM_BABBLINGS,A6	;Strip the high stuff, if there is any
	CMPI	ALL_BABBLE_BITS,A6	;Is that all of the phrases?
	JRNE	AJD_STORE_BABBLE	;BR = No

	CLR	A6			;Reset babble counter

AJD_STORE_BABBLE
	MOVE	A6,*A8(OBABBLE_BITS),W

	SLL	3,A0
	ADDI	BABBLE_TABLE,A0
	MOVB	*A0,A6
	MOVB	A6,*A8(OTALK_FLAG)

AJD_IDLE_IT_IS
	JRUC	AJD_DO_IDLE
	

NUM_BABBLINGS	.EQU	6
ALL_BABBLE_BITS .EQU	3FH		;Must equal (2^NUM_BABBLINGS)-1

BABBLE_TABLE
	.BYTE	SNUM_GAI_JIN, SNUM_BLUE_EYE, SNUM_SUPERIOR, SNUM_LAST_LAUGH
	.BYTE	SNUM_GIMME, SNUM_NEW_ORDER

	.EVEN

**************************************************************************
*								         *
* 	A_STEER_CHECK							 *
* 									 *
* 	Anim func to check if we should abort the steer at this		 *
* 	point.								 *
* 									 *
* 	A8 = Ptr to Josh						 *
* 	AARG+,L = Animation jump if we should bail			 *
*								         *
**************************************************************************
A_STEER_CHECK
	MOVB	*A8(OJOSH_IDLE),A14
	SUBK	6,A14
	JRNN	ASC_FLOOR
	CLR	A14
ASC_FLOOR
	MOVB	A14,*A8(OJOSH_IDLE)
	JAZ	SetAnim_AFARG
	RETS

**************************************************************************
*								         *
* 	A_DEC_STEER_TIME						 *
* 									 *
* 	Anim func to decrement the current steering timer.		 *
* 	Checks to see if we have another action to do. If so,		 *
* 	then fall through.						 *
* 									 *
* 	A8 = Ptr to Josh						 *
* 	AARG+,W = Action number we are checking				 *
* 	AARG+,L	= Animation branch if we are NOT done			 *
*								         *
**************************************************************************
A_DEC_STEER_TIME
	MOVB	*A8(OJOSH_IDLE),A14
	DEC	A14
	MOVB	A14,*A8(OJOSH_IDLE)
	JRZ	ADST_X

	CALLA	GETAFARG_WORD
	MOVB	*A8(OJOSH_ACTION),A14	;Get action Josh should be doing
	CMP	A0,A14	     		;Is this the same action we are doing?
	JRNE	ADST_X			;BR = No, let's fall through to suck it up

	JAUC	SetAnim_AFARG		;Loop the animation
ADST_X
	RETS
	
**************************************************************************
*								         *
* 	A_BLOW_SHOULDER							 *
* 									 *
* 	Anim func to blow a shoulder piece.				 *
* 									 *
* 	A8 = Ptr to shoulder piece					 *
*								         *
**************************************************************************
A_BLOW_SHOULDER
	MOVI	80000H,A1
	MOVE	A1,A2
	MOVI	-80000H,A3
	MOVE	A3,A4
	MOVI	SHOULDER_BLOW_INIT,B0
	JRUC	BLOW_DESK_PART

**************************************************************************
*								         *
* 	A_BLOW_TIT							 *
* 									 *
* 	Anim func to blow a tit.					 *
* 									 *
* 	A8 = Ptr to tit piece						 *
*								         *
**************************************************************************
A_BLOW_TIT
	MOVI	80000H,A1
	MOVE	A1,A2
	CLR	A3
	CLR	A4
	MOVI	TIT_BLOW_INIT,B0
	JRUC	BLOW_DESK_PART

**************************************************************************
*								         *
* 	A_BLOW_EYE							 *
* 									 *
* 	Anim func to blow a eye piece.					 *
* 									 *
* 	A8 = Ptr to eye piece						 *
*								         *
**************************************************************************
A_BLOW_EYE
	MOVI	80000H,A1
	MOVE	A1,A2
	MOVI	80000H,A3
	MOVE	A3,A4
	MOVI	EYE_BLOW_INIT,B0
	JRUC	BLOW_DESK_PART

**************************************************************************
*								         *
* 	A_BLOW_DOME							 *
* 									 *
* 	Anim func to blow the dome.					 *
* 									 *
* 	A8 = Ptr to the dome.						 *
*								         *
**************************************************************************
A_BLOW_DOME
	CLR	A1
	CLR	A2
	MOVI	-80000H,A3
	MOVE	A3,A4
	MOVI	DOME_BLOW_INIT,B0
	JRUC	BLOW_DESK_PART

**************************************************************************
*								         *
* 	A_BLOW_FRONT							 *
* 									 *
* 	Anim func to blow the front  piece.				 *
* 									 *
* 	A8 = Ptr to the front piece					 *
*								         *
**************************************************************************
A_BLOW_FRONT
	CLR	A1
	CLR	A2
	MOVI	80000H,A3
	MOVE	A3,A4
	MOVI	FRONT_BLOW_INIT,B0
	JRUC	BLOW_DESK_PART

**************************************************************************
*								         *
* 	BLOW_DESK_PART							 *
* 									 *
* 	Anim func entrypoint to blow a part of the desk.		 *
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
BLOW_DESK_PART
	MOVE	A1,A5
	CALLA	EASYMAKE
	JRZ	BDP_X  			;No objects available
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
	JRNZ	BDP_X_POS
	NEG	A0
BDP_X_POS
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
BDP_X
	RETS

**************************************************************************
*								         *
* 	A_START_BLOWS							 *
* 									 *
* 	Anim func to start all parts blowin' up				 *
* 									 *
* 	A8 = Any master part of desk					 *
*								         *
**************************************************************************
A_START_BLOWS
	MOVI	NUM_SHOULDERL,A1
	CALLA	FINDPART
	CALLA	COLLSOFF
	MOVI	ANIM_SHOULDER_BLOW,A1
	CALLA	STRTANIM
	MOVE	*A0(OPARTS),A0,L
	CALLA	COLLSOFF
	CALLA	STRTANIM

	MOVI	NUM_EYEL,A1
	CALLA	FINDPART
	CALLA	COLLSOFF
	MOVI	ANIM_EYE_BLOW,A1
	CALLA	STRTANIM
	MOVE	*A0(OPARTS),A0,L
	CALLA	COLLSOFF
	CALLA	STRTANIM

	MOVI	NUM_FRONT,A1
	CALLA	FINDPART
	CALLA	COLLSOFF
	MOVI	ANIM_FRONT_BLOW,A1
	CALLA	STRTANIM

	MOVI	NUM_DOME,A1
	CALLA	FINDPART
	CALLA	COLLSOFF
	MOVI	ANIM_DOME_BLOW,A1
	CALLA	STRTANIM

	MOVI	NUM_TITL,A1
	CALLA	FINDPART
	CALLA	COLLSOFF
	MOVI	ANIM_TIT_BLOW,A1
	CALLA	STRTANIM
	MOVE	*A0(OPARTS),A0,L
	CALLA	COLLSOFF

	JAUC	STRTANIM
	
**************************************************************************
*								         *
* 	A_DESK_OFF							 *
* 									 *
* 	Anim func to turn the whole desk off.				 *
* 									 *
* 	A8 = ptr to any part						 *
*								         *
**************************************************************************
A_DESK_OFF
	CALLA	GET_HEAD_PART
	JAUC	OBJ_OFF_MULTI

**************************************************************************
*								         *
* 	A_BLOW_GAT							 *
* 									 *
* 	Anim Func to blow the gatlin gun.				 *
* 									 *
* 	A8 = Ptr to gat doing the blowing				 *
*								         *
**************************************************************************
A_BLOW_GAT
	MOVI	GAT_BLOW_INIT,B0
	MOVI	-50000H,A1
	MOVI	50000H,A2
	MOVI	20000H,A3
	MOVI	60000H,A4
	JAUC	BLOW_PART

**************************************************************************
*								         *
* 	A_SHAKE_FUNC							 *
* 									 *
* 	Anim Func to give a little shake.				 *
* 									 *
* 	A8 = Ptr to any part of a multi-parter				 *
* 	AARG+,L = Absolute maximum X & Y velocity			 *
* 	AARG+,W = Absolute maximum Z velocity				 *
* 									 *
* 	Returns:							 *
* 		AnimSLP stuffed with amount to sleep			 *
*								         *
**************************************************************************
A_SHAKE_FUNC
	CALLA	GETAFARG_LONG
	MOVE	A0,A2
	CALLA	GETAFARG_WORD

	MOVE	A8,A1	     		;Save the part ptr
	CALLA	GET_HEAD_PART		;Get the head part

	MOVE	A0,A0
	JRZ	ASF_SKIPZ
	CALLA	SRAND			;Signed Random Z velocity
	MOVE	A0,*A8(OZVEL),L
ASF_SKIPZ
	MOVE	A2,A0
	JRZ	ASF_SKIPXY
	CALLA	SRAND			;Signed Random X velocity
	MOVE	A0,*A8(OXVEL),L

	MOVE	A2,A0			
	CALLA	SRAND			;Signed Random Y velocity
	MOVE	A0,*A8(OYVEL),L
ASF_SKIPXY
	MOVK	1,A0			;Select a random sleep time of 1 or 2
	MOVB	@RAND,A14
	JRN	ASS_STORE_SLEEP
	ADDK	1,A0
ASS_STORE_SLEEP
	MOVB	A0,*A1(AnimSLP)
	RETS

**************************************************************************
*								         *
* 	A_NOSCALE_NOSHAD						 *
* 									 *
* 	Anim func to set the NOSCALE and NOSHADOW bits of an		 *
* 	object and delete it'shadow, if it has one.			 *
* 									 *
* 	A8 = Ptr to object						 *
*								         *
**************************************************************************
A_NOSCALE_NOSHAD
	ORIM	M_NOSCALE|M_NOSHADOW,*A8(OFLAGS),W
	MOVIM	1000100H,*A8(OSCALE),L
	MOVE	A8,A0
	JAUC	DELSHAD

**************************************************************************
*								         *
* 	A_SCALE_SHAD							 *
* 									 *
* 	Anim func to make an object scaleable and able to		 *
* 	have a shadow.							 *
* 									 *
* 	A8 = Ptr to object						 *
*								         *
**************************************************************************
A_SCALE_SHAD
	ANDNIM	M_NOSCALE|M_NOSHADOW,*A8(OFLAGS),W
	RETS

**************************************************************************
*								         *
* 	A_OBJ_OFF_SCALE_SHAD						 *
* 									 *
* 	Anim func to make an object scaleable and turn it off.		 *
* 									 *
* 	A8 = Ptr to object						 *
*								         *
**************************************************************************
A_OBJ_OFF_SCALE_SHAD
	CALLA	OBJ_OFF
	JRUC	A_SCALE_SHAD

**************************************************************************
*								         *
* 	A_SUB_SND							 *
* 									 *
* 	Anim func to make a sound call and put out a subtitle.		 *
* 									 *
* 	A8 = Any part of the desk					 *
* 	AARG+,W = Sound/Subtitle index					 *
*								         *
**************************************************************************
A_SUB_SND
	CALLA	GETAFARG_WORD
*
*Entrypoint:
*	A0 = Sound/Subtitle index
*
A_SUB_SND_G
	MOVE	A0,A2
	MOVE	A0,A14
	SLL	6,A2
	SLL	5,A14
	ADD	A14,A2
	ADDI	TAB_SUBTITLE_SOUND,A2

	MOVE	*A2+,A0,L		;Get the sound
	JRZ	ASS_NO_SOUND		;BR = No subtitle for this sound

	CALLA	ONESND			;Fire off the speech
	JRNZ	ASS_NO_SOUND		;BR = No sound made

	MOVE	A0,A3

	MOVI	OID_INFOTEXT,A0
	CALLA	KILOBJ_ALL		;Kill any text

	MOVK	NUM_SEATR,A1
	CALLA	FINDPART		;Get the controller of all subtitles
	JRNZ	ASS_GOT_WATCHER
*This is a fucked up thang right here.  Means Josh ain't connected to no
*desk, yet.
	MOVI	OID_DESK,A0
	CALLA	EXISTOBJ_ALL		;Is there a desk around?
	JRZ	ASS_TRY_FUCK		;BR = No, then no subtitles

	MOVE	A0,A8
	MOVK	NUM_SEATR,A1
	CALLA	FINDPART		;Get the controller once again
	JRNZ	ASS_GOT_WATCHER		;BR = Got it

*This is doubly, fucked.  No Josh, no desk.  Let's just start a process.
ASS_TRY_FUCK
	MOVE	*A2+,A9,L		;Get the current subtitle text
	MOVE	*A2+,A11,W		;Get the Y screen position
	MOVE	*A2+,A10,W		;Duration
	JRUC	ASS_DO_TITLE
	
ASS_GOT_WATCHER
	MOVE	*A2+,A9,L		;Get the current subtitle text
	MOVE	*A2+,A11,W		;Get the Y screen position
	MOVE	*A2+,A14,W		;Get the duration

	MOVE	A14,*A0(OSUB_DURATION)	;Stuff the duration
	
	MOVE	A3,*A0(OSUB_SND),L	;and the sound we're making

	MOVI	ANIM_SUBTITLE,A1
	CALLA	STRTANIM		;Start the subtitle watcher

	CLR	A10

ASS_DO_TITLE
;	CREATE	PID_IND,PROC_SUBTITLE

ASS_NO_SOUND
	RETS

**************************************************************************
*								         *
* 	A_CHECK_SUB							 *
* 									 *
* 	Anim func to check the progress of our little sub-title		 *
* 	and go for the next, if need be.				 *
* 									 *
* 	A8 = Ptr to object watching the sub-title			 *
*								         *
**************************************************************************
A_CHECK_SUB
	MOVE	*A8(OSUB_DURATION),A14,W
	DEC	A14			;Click another off of the timer
	MOVE	A14,*A8(OSUB_DURATION),W
	JRZ	ACS_DONE		;BR = Your time is up

	MOVE	*A8(OSUB_SND),A0,L
	CALLA	IS_SOUND		;Are we still running the same sound?
	JRZ	ACS_X			;BR = Yes
	
ACS_DONE
	MOVI	OID_INFOTEXT,A0
	CALLA	KILOBJ_ALL		;Kill any text

	JAUC	PULL_ANIM		;And stop all

ACS_X
	RETS
	
**************************************************************************
*								         *
* 	A_CHECK_FRONT_DEAD						 *
* 									 *
* 	Anim func to check if front piece is supposed to be dead.	 *
* 	If it is, then take animation branch.				 *
* 									 *
* 	A8 = Ptr to piece dependant on front				 *
* 	AARG+,L = Branch if front is dead				 *
*								         *
**************************************************************************
A_CHECK_FRONT_DEAD
	MOVI	NUM_FRONT,A1
	CALLA	FINDPART			;Find front piece
	MOVE	*A0(OFLAGS),A14,W
	BTST	B_DEAD,A14			;Is it dead?
	JRZ	ACFD_X				;BR = No, then no branch
	JAUC	SetAnim_AFARG
ACFD_X
	RETS

**************************************************************************
*								         *
* 	PROC_SUBTITLE							 *
* 									 *
* 	Process to print a subtitle.					 *
* 									 *
* 	A9 = Ptr to text to print					 *
* 	A10 = Duration, if 0 then someone else will handle it		 *
* 	A11 = Screen Y address						 *
*								         *
**************************************************************************
PROC_SUBTITLE
	PUSHP	A10

	MOVE	A9,A2			;Save ptr to actual text
	MOVE	A11,A3			;Save Y screen address

	MOVI	M_SUBTITLE,A8
	CALLA	LM_SETUP		;Setup a generic subtitle string

	MOVE	A2,A8			;Drop in required text
	SLL	16,A3
	MOVY	A3,A9			;And put it at our Y
	
	JSRP	PRINTF

	PULLP	A10
	MOVE	A10,A10			;Should we wait?
	JAZ	SUCIDE			;BR = No

	SLEEPR	A10			;Wait around a bit
	
	MOVI	OID_INFOTEXT,A0
	CALLA	KILOBJ_ALL		;Kill any text

	DIE

**************************************************************************
*								         *
* 	Collision stuff - This is where we get really interactive	 *
*								         *
**************************************************************************

**************************************************************************
*								         *
* 	DOME_GUNVECT							 *
* 									 *
* 	Gun Vector for all the glass dome.  				 *
* 									 *
* 	A2 = Ptr to player hitting the dome.				 *
* 	A8 = Ptr to part 						 *
*								         *
**************************************************************************
DOME_GUNVECT
	SOUNDZ	SND_DOME_HIT
	JRUC	DGV_FRAG_SPARK

**************************************************************************
*								         *
* 	DESK_GUNVECT							 *
* 									 *
* 	Gun Vector for all of Desk's parts.  The part will flash	 *
* 	and increase in damage if necessary.				 *
* 									 *
* 	A2 = Ptr to player hitting the Desk				 *
* 	A8 = Ptr to part 						 *
*								         *
**************************************************************************
DESK_GUNVECT
	MOVB	*A8(O_BEING_DAMAGED),A14	;Is this part currently under attack?
	JRNZ	DGV_X			;BR = Yes

	CALLA	GET_HEAD_PART_A0
	MOVE	A0,A7			;Head-part stays in A7

	MOVB	*A8(OPARTID),A4		;Keep PARTID here throughout

	MOVE	*A8(OFLAGS),A14,W
	BTST	B_DEAD,A14   		;Is this guy dead?
	JRNZ	DGV_DEAD		;BR = Yes, then no flashing

	CALLA	OBJ_CONST		;Turn constant color on
	MOVKB	4,*A8(OFLASHTIME)

	CMPK	NUM_FRONT,A4		;Are we dealing with the front?
	JRNE	DGV_NOT_FRONT		;BR = No
	
	MOVK	NUM_MISSLE_DOOR,A1	;We must fudge the front door
	CALLA	FINDPART		;since it's a seperate piece

;	MOVE	*A0(OCTRL),A14,W	; OLD WAY
;	SLL	28,A14			;Is the door even on?
;	JRZ	DGV_NOT_FRONT		;BR = No

	move	*a0(OFLAGS),a14		; Use New NODISP Flag
	btst	B_NODISP,a14
	JRNZ	DGV_NOT_FRONT		;BR = No

	CALLA	OBJCONST		;Fire it up, boyee
	MOVKB	4,*A0(OFLASHTIME)

DGV_NOT_FRONT
	CALLR	MAKE_METAL_SOUND
	CALLR	DGV_FRAG_SPARK

	MOVI	DESK_BULLET_HITS,A1
	MOVI	OBULLET_HITS,A3
	CALLA	HIT_ENEMY		;Enough hits to merit damage?
	JRLO	DGV_X			;BR = No
	CLR	A14
	MOVE	A14,*A8(OBULLET_HITS),L	;Clear count

	CALLA	ANY_BOMBS		;Are there any rockets out there?
	JRZ	DESK_MAJOR_HIT		;BR = No, then let bullets finish

DGV_X
	RETS


*Part is dead, just spark it
*A4 = OPARTID
*A7 = Ptr to master-part
DGV_DEAD
	CALLR	MAKE_METAL_SOUND
	JRUC	DGV_FRAG_SPARK


*
*Make the spark for the metal gunvector
*A2 = Ptr to player hitting
*A8 = Ptr to part being hit
*
DGV_FRAG_SPARK
	PUSH	B0
	MOVI	INIT_SPARK,B0
	CALLA	PASTE_ON_DAMAGE
	PULLQ	B0
	RETS

;	MMTM	SP,A0,A3,A4
;	MMTM	SP,B0,B1,B2,B3,B4,B5,B6,B7,B8,B9,B10

;	MOVI	FRAG_SPARK,B14

;	MOVI	[1,0],A0
;	MOVI	10H,A3
;	CLR	A4

;	CALLA	PreFrag_Gun
;	CALLA	Fragger
;	MMFM	SP,B0,B1,B2,B3,B4,B5,B6,B7,B8,B9,B10
;	MMFM	SP,A0,A3,A4
;	RETS

**************************************************************************
*								         *
* 	MAKE_METAL_SOUND						 *
* 									 *
* 	Make the proper sound for the part that was hit.		 *
* 									 *
* 	A4 = OPARTID							 *
*								         *
**************************************************************************
MAKE_METAL_SOUND
	CMPK	NUM_FRONT,A4
	JRHI	MMS_X

	PUSH	A0

	MOVE	A4,A0
	DEC	A0
	SRL	1,A0
	SLL	5,A0
	ADDI	TAB_METAL_SOUNDS,A0
	MOVE	*A0,A0,L
	CALLA	ONESND_Z

	PULLQ	A0

MMS_X
	RETS

	
*
*Collision vector table for the desk
*
DESK_CVECT
	WWL	OID_PROCKET,~MASK_PLAYER,DESK_ROCKET_COLL
	WWL	OID_PEXPLOSION,~MASK_PLAYER,DESK_EXPLOSION_COLL
	WL	0,DUMCRETS

**************************************************************************
*								         *
* DESK_ROCKET_COLL - Collision vector with Player rocket bomb.		 *
* A0 = Ptr to rocket object						 *
* A8 = Ptr to Desk part							 *
*								         *
**************************************************************************
DESK_ROCKET_COLL
	MOVB	*A8(OROCKETHIT),A14	;Should we set the flag again?
	JRNZ	MRC_X			;BR = No, it is already set
	MOVE	*A0(RL_INTENDED_OBJ),A14,L
	CMP	A14,A8			;Is this the object we are after?
	JRNE	MRC_X			;BR = No
	MOVK	1,A14
	MOVB	A14,*A8(OROCKETHIT)	;Flag the rocket attack
	MOVB	A14,*A8(OCHEWEDROCKET)	;Flag for the explosion
MRC_X
	RETS

**************************************************************************
*								         *
* DESK_EXPLOSION_COLL - Collision vector for Player explosion against	 *
*			  generic Desk part.				 *
* A0 = Ptr to explosion object						 *
* A8 = Ptr to Desk part							 *
*								         *
**************************************************************************
DESK_EXPLOSION_COLL
	MOVB	*A8(OCHEWEDROCKET),A14	;Did he really take a rocket?
	JRZ	DEC_X			;BR = No, so bail

	CLR	A14
	MOVB	A14,*A8(OCHEWEDROCKET)	;Clear the rocket flag

	MOVE	A0,A5			;Visiting explosion goes here

	MOVE	*A8(OZVAL),A1,L
	MOVE	@ZBASE,A14,L
	SUB	A14,A1			;Universe to World Z

	CMPI	DESK_ZMAX-100H,A1	;Should we fuck him around?
	JRGT	DEC_NO_BLOW_BACK	;BR = No, too far back
	JRUC	DEC_JERK_HIM		;Fuck him around

**************************************************************************
*								         *
* DESK_CENTER_EXP_COLL - Collision vector for Player explosion against	 *
*			  Desk's center.				 *
* A0 = Ptr to explosion object						 *
* A8 = Ptr to Desk part							 *
*								         *
**************************************************************************
DESK_CENTER_EXP_COLL
	MOVB	*A8(OCHEWEDROCKET),A14	;Did he really take a rocket?
	JRZ	DEC_X			;BR = No, so bail

	CLR	A14
	MOVB	A14,*A8(OCHEWEDROCKET)	;Clear the rocket flag

	MOVE	A0,A5			;Visiting explosion goes here

	MOVE	*A8(OZVAL),A1,L
	MOVE	@ZBASE,A14,L
	SUB	A14,A1			;Universe to World Z

	CMPI	DESK_ZMAX-100H,A1	;Should we blast him back?
	JRGT	DEC_NO_BLOW_BACK	;BR = No, not close enough.

	CALLA	GET_HEAD_PART_A0	;Check this velocity stuff on head

	MOVB	*A0(OCENTER_FLAG),A14	;Are we currently supposed to be centered?
	JRNZ	DEC_JERK_HIM		;BR = Yes, then don't go back

	MOVB	*A0(ONOSET_ZVEL),A14	;Are we currently blowing back?
	JRNZ	DEC_JERK_HIM		;BR = Yes, then don't do it again

	MOVE	*A0(OZVEL),A14,L	;Determine how much time to blowback
	JRGE	DEC_FULL_BLOWBACK	;BR = Set full time
	SRA	8,A14
	ADDI	50,A14			;Calculate accordingly
	CMPK	5,A14			;Too small?
	JRGE	DEC_SET_ZBLOW_TIME	;BR = no, it'll do
	MOVK	5,A14			;Min ticks
	JRUC	DEC_SET_ZBLOW_TIME
DEC_FULL_BLOWBACK
	MOVI	50,A14			;Max ticks
DEC_SET_ZBLOW_TIME	
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

	JRUC	DEC_NO_BLOW_BACK

*Just give the rig a jolt.
*A5 = Ptr to explosion object
DEC_JERK_HIM
	MOVK	NUM_SMALL_SHAKE,A1
	CALLA	FINDPART		;The foot rest will shake us
	JRZ	DEC_NO_BLOW_BACK	;BR = Couldn't find the part
	MOVI	ANIM_SMALL_SHAKE,A1	;Start a shaker anim
	CALLA	STRTANIM

DEC_NO_BLOW_BACK
	MOVE	*A5(OID),A0,W		;We can find out who did this
	CALLA	POID_TO_PDATA		;by getting the Player's data area.

	MOVE	*A8(OFLAGS),A14,W
	BTST	B_DEAD,A14   		;Is this guy dead?
	JRZ	DEC_NORMAL_EXP		;BR = No, you may continue

*Desk part is dead, we just wanted to jerk him
	MOVKB	10,*A8(OCLRROCKETHIT)	;Time 'til we reset for the next
	MOVE	A2,*A8(OPLAYER),L	;Hang on to this address
	JRUC	DEC_X

DEC_NORMAL_EXP
	CALLA	OBJ_CONST		;Turn constant color on
	MOVKB	6,*A8(OFLASHTIME)

*
*Entry point for somebody to score a major hit on Desk.
*A2 = Ptr to player doing the hitting
*A5 = 0
*A8 = Ptr to Desk part being hit
*
DESK_MAJOR_HIT
	CALLA	GET_HEAD_PART_A0
	MOVE	A0,A7			;Head-part stays in A7

	MOVB	*A7(OFDAM_GOING),A14	;Is a Final damage going?
	JRNZ	DEC_DONE		;BR = Right, then no one else goes

	MOVB	*A8(OPARTID),A4		;Get the I.D. of this part
	MOVB	*A7(OMISSLE_VULNER),A14	;Are the missle launchers vulnerable?
	JRNZ	DEC_DO_HIT		;BR = Yes
*Missle launcher open check
	CMPK	NUM_SHOULDERL,A4   	;Did we hit the left missle launcher?
	JREQ	DEC_SHOULDER_MISSLE	;BR = Yes
	CMPK	NUM_SHOULDERR,A4   	;Did we hit the right missle launcher?
	JREQ	DEC_SHOULDER_MISSLE	;BR = Yes
	CMPK	NUM_FRONT,A4		;Did we hit the front missle launcher?
	JRNE	DEC_DO_HIT		;BR = No
	MOVB	*A7(OFIRING_MISSLE),A14	;Special case for the front missle guy
	CMPK	NUM_MISSLE_DOOR,A14
	JRNE	DEC_NO_KILL
	JRUC	DEC_DO_HIT
DEC_SHOULDER_MISSLE
	MOVB	*A7(OFIRING_MISSLE),A14	
	CMP	A4,A14			;Is this missle launcher open?
	JRNE	DEC_NO_KILL		;BR = No, then no damage is to occur
DEC_DO_HIT
	MOVK	6,A1
;	MOVK	10,A1
	MOVI	OHITS,A3
	CALLA	HIT_ENEMY	
	JRLO	DEC_NO_KILL

	CLR	A14
	MOVE	A14,*A8(OHITS),L

	MOVB	*A8(ODAMAGE),A14
	INC	A14
	CMPK	MAX_DESK_DAMAGE_LEVEL,A14	;Is the damage maxed out?
	JRHI	DEC_DONE			;BR = Yes, no more

*We can damage our little hearts out!
*A4 = OPARTID for this part
*A7 = Ptr to head-part
DEC_DAMAGE
	MOVB	A14,*A8(ODAMAGE)

	MOVE	A4,A14
	DEC	A14
	SLL	5,A14
	ADDI	FINAL_ANIM_TABLE,A14
	MOVE	*A14,A1,L		;Get the final animation for this part
	JRZ	DEC_NO_DAMAGE

	INCB	*A7(OPARTS_LOST)	;Chalk another part gone

	MOVKB	2,*A7(OCENTER_FLAG)
	MOVIB	120,*A7(OCLRCENTER)

	MOVKB	1,*A7(OFDAM_GOING)

	CALLA	STRT_ANIM		;and start it animating

	ORIM	M_DEAD,*A8(OFLAGS),W
;	MOVIM	DUMCOLL,*A8(OCVECT),L	;No more collisions for you
;	MOVIM	DUMRETS,*A8(OGUNVECT),L	;No more bullets either

	INCB	*A8(ODAMAGE)		;Get that Damage level past the point

	MOVI	5150,A1
	CALLA	SCORE			;Killing is the best for points

	CMPK	NUM_GATL,A4		;Gats don't need grunt sound
	JREQ	DEC_NO_HGRUNT
	CMPK	NUM_GATR,A4
	JREQ	DEC_NO_HGRUNT

	RANDENT	TAB_HGRUNT_SOUNDS,NUM_HGRUNT_SNDS,5,L
	CALLA	ONESND

DEC_NO_HGRUNT

	MOVK	NUM_BIG_SHAKE,A1
	CALLA	FINDPART		;The foot rest will shake ust
	JRZ	DEC_DONE		;BR = Couldn't find the part
	MOVI	ANIM_BIG_SHAKE,A1	;Start a shaker anim
	CALLA	STRTANIM

	JRUC	DEC_DONE

DEC_NO_DAMAGE

*
*A4 = OPARTID for this part
*A5 = Ptr to explosion object, 0 = No explosion object 
*
DEC_NO_KILL
;	MOVB	*A8(OPARTID),A6
;	CMPK	NUM_HEAD,A6
;	JRNE	MEC_CHECK_ARM

DEC_CHECK_ARM
	CMPK	NUM_GATL,A4
	JREQ	DEC_WHACK_GUN
	CMPK	NUM_GATR,A4
	JRNE	DEC_BODY_HIT

*Make gun flip to the side
DEC_WHACK_GUN
	MOVI	ANIM_GAT_WHACK,A1
	CALLA	STRT_ANIM		;Start the animation happening

*Make a random hit sound when taking a rocket
DEC_BODY_HIT
	MOVI	256,A0
	CALLA	RANDPER
	JRNC	DEC_DONE
	
	RANDENT	TAB_JGRUNT_SOUNDS,NUM_JGRUNT_SNDS,5,L
	CALLA	ONESND

DEC_DONE
	MOVKB	25,*A8(OCLRROCKETHIT)	;Time 'til we reset for the next

	MOVE	A2,*A8(OPLAYER),L	;Hang on to this address

	MOVI	100,A1
	CALLA	SCORE			;Explosions are always good for points
	
DEC_X
	RETS

**************************************************************************
*								         *
* 	MISSLE_GUNVECT							 *
* 									 *
* 	Gun vector for desk's missle.					 *
* 									 *
* 	A2 = Ptr to player shooting the missle.				 *
* 	A8 = Ptr to the missle object.					 *
*								         *
**************************************************************************
MISSLE_GUNVECT
	CALLA	COLLS_OFF
	CALLA	CLR_VEL
	MOVE	*A8(OPART1),A14,L	;Is it still attached to the desk?
	JRZ	MGV_FLYING		;BR = No
	CALLA	PULL_PART		;Pull it
MGV_FLYING
	MOVI	ANIM_MISSLE_EXPLODE,A1
	CALLA	STRT_ANIM
	MOVI	100,A1
	JAUC	SCORE			;Score points for neutralizing

**************************************************************************
*								         *
* 	MISSLE_CVECT							 *
* 									 *
* 	Collision vector table for the missle.				 *
*								         *
**************************************************************************
MISSLE_CVECT
	WWL	OID_PROCKET,~MASK_PLAYER,PROJECTILE_ROCKET_COLL
	WWL	OID_PEXPLOSION,~MASK_PLAYER,MISSLE_EXPLOSION_COLL
	WL	0,DUMCRETS

**************************************************************************
*								         *
* 	MISSLE_EXPLOSION_COLL						 *
* 									 *
* 	Explosion service for missle					 *
* 									 *
* 	A0 = ptr to explosion object					 *
* 	A8 = ptr to missle object					 *
*								         *
**************************************************************************
MISSLE_EXPLOSION_COLL
	MOVB	*A8(OCHEWEDROCKET),A14	;Did he really take a rocket?
	JRZ	MEC_X			;BR = No, so bail

	MOVE	*A0(OID),A0,W		;We can find out who did this
	CALLA	POID_TO_PDATA		;by getting the Player's data area.

	JRUC	MISSLE_GUNVECT

MEC_X
	RETS

**************************************************************************
*								         *
* 		Sounds for The Desk					 *
*								         *
**************************************************************************
SND_TRANSFORM
	.WORD	0F344H,115,0838AH,0	;Mech desk transforms
SND_PREASE
	.WORD	0E342H,179,0826FH,0	;"Prease to enjoy, new Japan technology"
SND_COME_IN
	.WORD	0E342H,39,0826CH,0826CH,0 ;"Come in, Come in"
SND_SO_NICE
	.WORD	0E342H,59,0826BH,0	;"So nice to see you"
SND_NIGHTMARE
	.WORD	0E349H,143,08280H,0	;"Prease to enjoy, your worst nightmare"
SND_GET_READY
	.WORD	0E342H,64,084CDH,0	;Short laugh
SND_GAI_JIN
	.WORD	0E342H,104,084C9H,0	;"You cannot destroy me"
SND_BLUE_EYE
	.WORD	0E342H,65,084caH,0	;"Impudent Youth"
SND_SUPERIOR
	.WORD	0E342H,122,084c8H,0	;"Submit to the New Order"
SND_LAST_LAUGH
	.WORD	0E342H,79,084c6H,0	;"You have no choice"
SND_GIMME
	.WORD	0E342H,64,084cbH,0	;"Go to your doom!"
SND_NEW_ORDER
	.WORD	0E342H,85,084C7H,0	;"You have no future"
SND_BANZAI
	.WORD	0E342H,122,084c8H,0	;"Submit to the New Order"
SND_DESK_DESTROY
	.WORD	0E345H,92,08264H,0	;"You've destroyed my desk!"
SND_SORRY
	.WORD	0E342H,96,084ccH,0	;Laugh 0
SND_NOOO
	.WORD	0E345H,157,084c3H,0	;"You have destroyed New Order prop."
SND_BEAST
	.WORD	0E344H,26,084ceH,0	;effort grunt #0
SND_FORGIVE
	.WORD	0E344H,31,084d1H,0	;damage grunt #0
SND_USELESS
	.WORD	0E344H,33,084d2H,0	;damage grunt #1
SND_HURT_DESK
	.WORD	0E344H,29,084d3H,0	;damage grunt #2
SND_PISSED
	.WORD	0E344H,47,08871H,0	;Josh says this when you hit all missles
SND_COOOO_EEEEL
	.WORD	0F1D1H,56,0886CH,0	;"Coo-eeel"

SND_DESK_BATTLE
	.WORD	0F0FDH,1,08003H,0	;Battle the bat desk

TAB_METAL_SOUNDS
	.LONG	SND_METAL_TIT, SND_METAL_SHOULDER, SND_METAL_EYE
	.LONG	SND_METAL_GAT, SND_METAL_FRONT, SND_METAL_TIT
	.LONG	SND_METAL_TIT, SND_METAL_TIT, SND_METAL_TIT

SND_METAL_TIT
	.WORD	0F302H,16,0A1DDH,0	;Desk metal hit TIT
SND_METAL_FRONT
	.WORD	0F302H,13,0A1E0H,0	;Desk metal hit FRONT
SND_METAL_EYE
	.WORD	0F302H,21,0A1E6H,0	;Desk metal hit EYE
SND_METAL_GAT
	.WORD	0F302H,44,0A194H,0	;Desk metal hit GAT
SND_METAL_SHOULDER
	.WORD	0F302H,24,0A1E3H,0	;Desk metal hit SHOULDER

SND_DOME_HIT
	.WORD	0F302H,46,0A32BH,0	;Desk hit DOME

SND_DESK_GUN
	.WORD	0E320H,10,0A108H,0	;Jap boy fires upon your ass
SND_DOOR_OPEN
	.WORD	0F340H,20,0A1F7H,0	;Front missle door opening
SND_SHOULDER_SHORT
	.WORD	0F340H,21,0A1FAH,0	;Shoulder pops up, short
SND_SHOULDER_LONG
	.WORD	0F340H,36,0A1FDH,0	;Shoulder pops up, long
SND_SHLDR_SHORT_FINAL
	.WORD	0F341H,21,0A1FAH,0	;Shoulder pops up, short for final damage
SND_SHLDR_LONG_FINAL
	.WORD	0F341H,36,0A1FDH,0	;Shoulder pops up, long	for final damage
SND_MISSLE_LAUNCH
	.WORD	0F340H,93,0A3B0H,0	;Missle launching
SND_MISSLE_EXPLODE
	.WORD	0F341H,80,0A38DH,0	;Missle blows up in mid-air
SND_GAT_WHACK
	.WORD	0E341H,46,0A3B3H,0	;Gat gets whacked


*Normal grunts, used randomly during battle
NUM_JGRUNT_SNDS	.EQU	3

TAB_JGRUNT_SOUNDS
	.LONG	SND_JGRUNT1,SND_JGRUNT2,SND_JGRUNT3

SND_JGRUNT1
	.WORD	0E342H,31,084d1H,0	;Josh GRUNT #1
SND_JGRUNT2
	.WORD	0E342H,33,084d2H,0	;Josh GRUNT #2
SND_JGRUNT3
	.WORD	0E342H,28,084d3H,0	;Josh GRUNT #3


*High priority grunts, used for when a part explodes
NUM_HGRUNT_SNDS	.EQU	3

TAB_HGRUNT_SOUNDS
	.LONG	SND_HGRUNT1,SND_HGRUNT2,SND_HGRUNT3

SND_HGRUNT1
	.WORD	0E344H,31,084d1H,0	;damage grunt #0
SND_HGRUNT2
	.WORD	0E344H,33,084d2H,0	;damage grunt #1
SND_HGRUNT3
	.WORD	0E344H,29,084d3H,0	;damage grunt #2

SND_FINAL_EXPLODE1
	.WORD	0E148H,88,08303H,0	;Final explosion sound, channel 1
SND_FINAL_EXPLODE2
	.WORD	0E248H,40,0838FH,0	;Final explosion sound, channel 2
SND_FINAL_EXPLODE3
	.WORD	0E348H,88,08390H,0	;Final explosion sound, channel 3

SND_FINAL_SCREAM
	.WORD	0E349H,285,084d4H,0	;Final scream sound, channel 3


NUM_DESK_PARTS		.EQU	21	;# of total parts that make up the desk
NUM_DESK_USED_PARTS	.EQU	12	;# of parts desk uses

NUM_COLL_PARTS	.EQU	9		;Number of parts to stuff with default collision stuff


**************************************************************************
*								         *
* 			Subtitles					 *
*								         *
**************************************************************************
SNUM_COME_IN	.EQU	0
SNUM_SO_NICE	.EQU	1
SNUM_PREASE	.EQU	2
SNUM_NIGHTMARE	.EQU	3
SNUM_BANZAI	.EQU	4
SNUM_GAI_JIN	.EQU	5
SNUM_SUPERIOR	.EQU	6
SNUM_BLUE_EYE	.EQU	7
SNUM_LAST_LAUGH	.EQU	8
SNUM_GIMME	.EQU	9
SNUM_NEW_ORDER	.EQU	10
SNUM_DESK_DESTROY .EQU	11
SNUM_SORRY	.EQU	12
SNUM_NOOO	.EQU	13
SNUM_BEAST	.EQU	14
SNUM_FORGIVE	.EQU	15
SNUM_USELESS	.EQU	16
SNUM_HURT_DESK	.EQU	17
SNUM_PISSED	.EQU	18

SNUMS_UNDER_DOME .EQU	4		;Start of SNUMS while under glass dome

TAB_SUBTITLE_SOUND
	LLWW	SND_COME_IN,M_COME_IN,180+SKYTOPOF,65
	LLWW	SND_SO_NICE,M_SO_NICE,180+SKYTOPOF,58
	LLWW	SND_PREASE,M_PLEASE,175+SKYTOPOF,175
	LLWW	SND_NIGHTMARE,M_NIGHTMARE,175+SKYTOPOF,143
	LLWW	SND_BANZAI,M_BANZAI,180+SKYTOPOF,60
	LLWW	SND_GAI_JIN,M_GAI_JIN,180+SKYTOPOF,71
	LLWW	SND_SUPERIOR,M_SUPERIOR,180+SKYTOPOF,100
	LLWW	SND_BLUE_EYE,M_BLUE_EYE,180+SKYTOPOF,52
	LLWW	SND_LAST_LAUGH,M_LAST_LAUGH,180+SKYTOPOF,83
	LLWW	SND_GIMME,M_GIMME,180+SKYTOPOF,101
	LLWW	SND_NEW_ORDER,M_NEW_ORDER,180+SKYTOPOF,126
	LLWW	SND_DESK_DESTROY,M_DESK_DESTROY,180+SKYTOPOF,92
	LLWW	SND_SORRY,M_SORRY,180+SKYTOPOF,37
	LLWW	SND_NOOO,M_NOOO,180+SKYTOPOF,60
	LLWW	SND_BEAST,M_BEAST,180+SKYTOPOF,43
	LLWW	SND_FORGIVE,M_FORGIVE,180+SKYTOPOF,62
	LLWW	SND_USELESS,M_USELESS,180+SKYTOPOF,30
	LLWW	SND_HURT_DESK,M_HURT_DESK,180+SKYTOPOF,71
	LLWW	SND_PISSED,M_PISSED,180+SKYTOPOF,50


*
* Common subtitle text header
*
M_SUBTITLE
	MESS_MAC RD15FONT,2,197,180+SKYTOPOF,COLOR_PWHITE,STRCNRMOS,OID_INFOTEXT


M_COME_IN
	.STRING	"Come in! Come in!",0
	.EVEN
M_SO_NICE
	.STRING	"So nice to see you.",0
	.EVEN
M_PLEASE
	.STRING	"Please enjoy,\n"
	.STRING	"our new Japanese technology!",0
	.EVEN
M_NIGHTMARE
	.STRING	"Please enjoy,\n"
	.STRING	"your Worst Nightmare!",0
	.EVEN
M_BANZAI
	.STRING	"BANZAI!",0
	.EVEN
M_GAI_JIN
	.STRING	"Death to Gai-Jin!",0
	.EVEN
M_SUPERIOR
	.STRING	"We are superior!",0
	.EVEN
M_BLUE_EYE
	.STRING	"Blue-eyed devil!",0
	.EVEN
M_LAST_LAUGH
	.STRING	"I will have the last laugh!",0
	.EVEN
M_GIMME
	.STRING	"I require your life!",0
	.EVEN
M_NEW_ORDER
	.STRING	"The NEW ORDER wants YOU!",0
	.EVEN
M_DESK_DESTROY
	.STRING	"You've destroyed my desk!",0
	.EVEN
M_SORRY
	.STRING	"So sorry!",0
	.EVEN
M_NOOO
	.STRING	"Noooooo!",0
	.EVEN
M_BEAST
	.STRING	"You Beast!",0
	.EVEN
M_FORGIVE
	.STRING	"This I cannot forgive!",0
	.EVEN
M_USELESS
	.STRING	"A useless effort.",0
	.EVEN
M_HURT_DESK
	.STRING	"You hurt my desk!",0
	.EVEN
M_PISSED
	.STRING	"You Freak!",0
	.EVEN

**************************************************************************
*								         *
* 		The desk animations and such				 *
*								         *
**************************************************************************
DESK_INIT
	.byte	NUM_DESK_PARTS, 0, 0, 4 ;OBJCNT, PRCCNT, IMGPALCNT, PALCNT
	.long	DESK_p,DA_MECH_P,C_DAMGE_P,GLASS_p	;Palettes used
	.word	OID_DESK, OM_COLL
	.LONG	DUMCOLL

*
*    .long IMG
*    .word OCTRL, OFLAGS, OZOFF, OPTION_FLAGS
*

NUM_TITL	.EQU	1
	LWWWW	C_DESK, DMAWNZ, 0, 0, OM_CFUNC			;XFORM1
	.LONG	C_DESK_PART_INIT				;LEFT TIT

	LWWWW	C_DESK, DMAWNZ|M_FLIPH, 0, 0, OM_CFUNC		;XFORM1f
	.LONG	C_DESK_PART_INIT				;RIGHT TIT

NUM_SHOULDERL	.EQU	3
	LWWWW	TRANSFORM_A_2, DMAWNZ, M_NOSCALE|M_NOSHADOW|M_NODISP, 6, OM_CFUNC	;XFORM2
	.LONG	C_DESK_PART_INIT				;LEFT SHOULDER
NUM_SHOULDERR	.EQU	4
	LWWWW	TRANSFORM_A_2, DMAWNZ|M_FLIPH, M_NOSCALE|M_NOSHADOW|M_NODISP, 6, OM_CFUNC	;XFORM2f
	.LONG	C_DESK_PART_INIT				;RIGHT SHOULDER
	
NUM_EYEL	.EQU	5
	LWWWW	TRANSFORM_A_3, DMAWNZ, M_NOSCALE|M_NOSHADOW|M_NODISP, 5, OM_CFUNC		;XFORM3
	.LONG	C_DESK_PART_INIT				;LEFT EYE

	LWWWW	TRANSFORM_A_3, DMAWNZ|M_FLIPH, M_NOSCALE|M_NOSHADOW|M_NODISP, 5, OM_CFUNC	;XFORM3f
	.LONG	C_DESK_PART_INIT				;RIGHT EYE

NUM_GATL	.EQU	7
	LWWWW	TRANSFORM_B_4, DMAWNZ, M_NOSCALE|M_NOSHADOW|M_NODISP, 1, OM_CFUNC		;XFORM4
	.LONG	C_DESK_PART_INIT				;LEFT GUN

NUM_GATR	.EQU	8
	LWWWW	TRANSFORM_B_4, DMAWNZ|M_FLIPH, M_NOSCALE|M_NOSHADOW|M_NODISP, 1, OM_CFUNC	;XFORM4f
	.LONG	C_DESK_PART_INIT				;RIGHT GUN

NUM_FRONT	.EQU	9
	LWWWW	TRANSFORM_B_5, DMAWNZ, M_NOSCALE|M_NOSHADOW|M_NODISP, 0, OM_CFUNC		;XFORM5
	.LONG	C_DESK_PART_INIT				;FRONT PIECE

NUM_JOSH .EQU	10
	LWWWW	TRANSFORM_B_5, DMAWNZ|M_FLIPH, M_NOSCALE|M_NOSHADOW|M_NODISP, 7, OM_CFUNC	;XFORM5f
	.LONG	C_DESK_PART_INIT				;JOSH

NUM_MISSLE_DOOR	.EQU	11
	LWWWW	TRANSFORM_B_6, DMAWNZ, M_NOSCALE|M_NOSHADOW|M_NODISP, -1, OM_CFUNC		;XFORM6
	.LONG	C_DESK_PART_INIT				;FRONT MISSLE

NUM_GUN_ARM	.EQU	12
	LWWWW	TRANSFORM_B_6, DMAWNZ|M_FLIPH, M_NOSCALE|M_NOSHADOW|M_NODISP, 1, OM_CFUNC	;XFORM6f
	.LONG	C_DESK_PART_INIT				;Right gun arm

	LWWWW	TRANSFORM_K_7, DMAWNZ, M_NOSCALE|M_NOSHADOW|M_NODISP, 0, OM_CFUNC		;XFORM7
	.LONG	C_DESK_PART_INIT				;Left gun arm

NUM_SMALL_SHAKE	.EQU	14
	LWWWW	TRANSFORM_K_7, DMAWNZ|M_FLIPH, M_NOSCALE|M_NOSHADOW|M_NODISP, 1, OM_CFUNC	;XFORM7f
	.LONG	C_DESK_PART_INIT				;nothing

NUM_MED_SHAKE	.EQU	15
	LWWWW	TRANSFORM_K_8, DMAWNZ, M_NOSCALE|M_NOSHADOW|M_NODISP, 0, OM_CFUNC		;XFORM8
	.LONG	C_DESK_PART_INIT				;nothing

NUM_BIG_SHAKE	.EQU	16
	LWWWW	TRANSFORM_K_8, DMAWNZ|M_FLIPH, M_NOSCALE|M_NOSHADOW|M_NODISP, 0, OM_COLL	;XFORM8f
	.LONG	DUMCOLL						;nothing

NUM_DOME .EQU	17
	LWWWW	C_GLASS, DMAWNZ, M_OPARTSXY|M_NODISP, 9, OM_OPARTS|OM_COLL ;Glass dome
	.WORD	0,35
	.LONG	DUMCOLL

NUM_EYE_DAMAGE	.EQU	18
	LWWWW	TRANSFORM_K_9, DMAWNZ, M_NOSCALE|M_NOSHADOW|M_NODISP, 4, OM_COLL		;XFORM9
	.LONG	DUMCOLL						;Left eye damage

	LWWWW	TRANSFORM_K_9, DMAWNZ|M_FLIPH, M_NOSCALE|M_NOSHADOW|M_NODISP, 4, OM_COLL	;XFORM9f
	.LONG	DUMCOLL						;Right eye damage

NUM_SEATL	.EQU	20
	LWWWW	MEK_SEAT_A, DMAWNZ, M_OPARTSXY|M_NOSHADOW|M_NODISP, 8, OM_OPARTS|OM_COLL ;Left half of seat
	.WORD	0,35						;Used for final
	.LONG	DUMCOLL

NUM_SEATR	.EQU	21
NUM_LAST_PART	.EQU	21
	LWWWW	MEK_SEAT_A, DMAWNZ|M_FLIPH, M_OPARTSXY|M_NOSHADOW|M_NODISP, 8, OM_OPARTS|OM_COLL ;Right half of seat
	.WORD	0,35						;;Used for subtitles
	.LONG	DUMCOLL


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
*Animation number equates, used to tell decision funcs where animation
*just came from
*
ANUM_IDLE	.EQU	0

*Gatling gun animation equates
ANUM_FIRE	.EQU	1
ANUM_WHACK	.EQU	2

*Josh animation equates
ANUM_VICTORY	.EQU	1
ANUM_PISSED	.EQU	2
ANUM_BLOWN	.EQU	3
ANUM_STEER_L	.EQU	4
ANUM_STEER_R	.EQU	5

XFORM_TIX	.EQU	6	;Ticks per transform frame

ANIM_TRANSFORM
	LWLL	1,1|AFunc,A_SOUND+2,SND_TRANSFORM

	LWL	TRANSFORM_A_1,1|AMulti|AFunc,A_NOSCALE_NOSHAD
	LWL	TRANSFORM_A_1,1|AMulti|AFunc,A_NOSCALE_NOSHAD

	LWL	1,1|AMulti|AFunc,OBJ_ON
	LWL	1,1|AMulti|AFunc,OBJ_ON

	LWL	1,1|AMulti|AFunc,OBJ_ON
	LWL	1,XFORM_TIX|AFunc,OBJ_ON


	LW	TRANSFORM_B_1,1|AMulti
	LW	TRANSFORM_B_1,1|AMulti

	LW	TRANSFORM_B_2,1|AMulti
	LW	TRANSFORM_B_2,1|AMulti

	LW	TRANSFORM_B_3,1|AMulti
	LW	TRANSFORM_B_3,1|AMulti

	LWL	TRANSFORM_B_4,1|AMulti|AFunc,OBJ_ON
	LWL	TRANSFORM_B_4,1|AMulti|AFunc,OBJ_ON

	LWL	TRANSFORM_B_5,1|AMulti|AFunc,OBJ_ON
	LWL	TRANSFORM_B_5,1|AMulti|AFunc,OBJ_ON

	LWL	TRANSFORM_B_6,1|AMulti|AFunc,OBJ_ON
	LWL	TRANSFORM_B_6,XFORM_TIX|AFunc,OBJ_ON


	LW	TRANSFORM_C_1,1|AMulti
	LW	TRANSFORM_C_1,1|AMulti

	LW	TRANSFORM_C_2,1|AMulti
	LW	TRANSFORM_C_2,1|AMulti

	LW	TRANSFORM_C_3,1|AMulti
	LW	TRANSFORM_C_3,1|AMulti

	LW	TRANSFORM_C_4,1|AMulti
	LW	TRANSFORM_C_4,1|AMulti

	LW	TRANSFORM_C_5,1|AMulti
	LW	TRANSFORM_C_5,1|AMulti

	LWL	1,1|AMulti|AFunc,OBJ_OFF
	LWL	1,XFORM_TIX|AFunc,OBJ_OFF


	LW	TRANSFORM_D_1,1|AMulti
	LW	TRANSFORM_D_1,1|AMulti

	LW	TRANSFORM_D_2,1|AMulti
	LW	TRANSFORM_D_2,1|AMulti

	LW	TRANSFORM_D_3,1|AMulti
	LW	TRANSFORM_D_3,1|AMulti

	LW	TRANSFORM_D_4,1|AMulti
	LW	TRANSFORM_D_4,1|AMulti

	LWL	1,1|AMulti|AFunc,OBJ_OFF
	LWL	1,XFORM_TIX|AFunc,OBJ_OFF


	LW	TRANSFORM_E_1,1|AMulti
	LW	TRANSFORM_E_1,1|AMulti

	LW	TRANSFORM_E_2,1|AMulti
	LW	TRANSFORM_E_2,1|AMulti

	LW	TRANSFORM_E_3,1|AMulti
	LW	TRANSFORM_E_3,1|AMulti

	LW	TRANSFORM_E_4,1|AMulti
	LW	TRANSFORM_E_4,XFORM_TIX


	LW	TRANSFORM_F_1,1|AMulti
	LW	TRANSFORM_F_1,1|AMulti

	LW	TRANSFORM_F_2,1|AMulti
	LW	TRANSFORM_F_2,1|AMulti

	LW	TRANSFORM_F_3,1|AMulti
	LW	TRANSFORM_F_3,1|AMulti

	LW	TRANSFORM_F_4,1|AMulti
	LW	TRANSFORM_F_4,XFORM_TIX


	LW	TRANSFORM_G_1,1|AMulti
	LW	TRANSFORM_G_1,1|AMulti

	LW	TRANSFORM_G_2,1|AMulti
	LW	TRANSFORM_G_2,1|AMulti

	LW	TRANSFORM_G_3,1|AMulti
	LW	TRANSFORM_G_3,1|AMulti

	LW	TRANSFORM_G_4,1|AMulti
	LW	TRANSFORM_G_4,1|AMulti

	LWL	TRANSFORM_G_5,1|AMulti|AFunc,OBJ_ON
	LWL	TRANSFORM_G_5,1|AMulti|AFunc,OBJ_ON

	LWL	TRANSFORM_G_6,1|AMulti|AFunc,OBJ_ON
	LWL	TRANSFORM_G_6,XFORM_TIX|AFunc,OBJ_ON


	LWLW	TRANSFORM_H_1,1|AMulti|AFunc,A_SET_OYACCEL+1,-1000H
	LW	TRANSFORM_H_1,1|AMulti
	  
	LW	TRANSFORM_H_2,1|AMulti
	LW	TRANSFORM_H_2,1|AMulti

	LW	TRANSFORM_H_3,1|AMulti
	LW	TRANSFORM_H_3,1|AMulti

	LW	TRANSFORM_H_4,1|AMulti
	LW	TRANSFORM_H_4,1|AMulti

	LW	TRANSFORM_H_5,1|AMulti
	LW	TRANSFORM_H_5,1|AMulti

	LWL	1,1|AMulti|AFunc,OBJ_OFF
	LWL	1,XFORM_TIX|AFunc,OBJ_OFF


	LWL	TRANSFORM_I_1,1|AMulti|AFunc,A_SCALE_SHAD
	LWL	TRANSFORM_I_1,1|AMulti|AFunc,A_SCALE_SHAD

	LWL	TRANSFORM_I_2,1|AMulti|AFunc,A_SCALE_SHAD
	LWL	TRANSFORM_I_2,1|AMulti|AFunc,A_SCALE_SHAD

	LWL	TRANSFORM_I_3,1|AMulti|AFunc,A_SCALE_SHAD
	LWL	TRANSFORM_I_3,1|AMulti|AFunc,A_SCALE_SHAD

	LWL	TRANSFORM_I_4,1|AMulti|AFunc,A_SCALE_SHAD
	LWL	TRANSFORM_I_4,1|AMulti|AFunc,A_START_DOME_RISE

	LWL	1,1|AMulti|AFunc,A_OBJ_OFF_SCALE_SHAD
	LWL	1,1|AMulti|AFunc,A_OBJ_OFF_SCALE_SHAD

	LWL	1,1|AMulti|AFunc,A_SCALE_SHAD
	LWL	1,1|AMulti|AFunc,A_SCALE_SHAD

	LWL	1,1|AMulti|AFunc,A_SCALE_SHAD
	LWL	1,1|AMulti|AFunc,A_SCALE_SHAD

	LWL	1,1|AMulti|AFunc,A_SCALE_SHAD
	LWL	1,1|AMulti|AFunc,A_SCALE_SHAD

	LW	1,1|AMulti

	LWL	1,1|AMulti|AFunc,A_SCALE_SHAD
	LWL	1,(XFORM_TIX-2)|AFunc,A_SCALE_SHAD


	LWL	1,1|AFunc,A_GET_SHAD_MULTI

	LWLL	1,1|AFunc,A_SOUND+2,SND_COOOO_EEEEL


	LW	TRANSFORM_J_1,1|AMulti
	LW	TRANSFORM_J_1,1|AMulti

	LW	TRANSFORM_J_2,1|AMulti
	LW	TRANSFORM_J_2,1|AMulti

	LW	TRANSFORM_J_3,1|AMulti
	LW	TRANSFORM_J_3,1|AMulti

	LW	TRANSFORM_J_4,1|AMulti
	LW	TRANSFORM_J_4,1|AMulti

	LWL	TRANSFORM_J_5,1|AMulti|AFunc,OBJ_ON
	LWL	TRANSFORM_J_5,XFORM_TIX|AFunc,OBJ_ON


	LWLW	TRANSFORM_K_1,1|AMulti|AFunc,A_SET_OYACCEL+1,1000H
	LW	TRANSFORM_K_1,1|AMulti

	LW	TRANSFORM_K_2,1|AMulti
	LW	TRANSFORM_K_2,1|AMulti

	LW	TRANSFORM_K_3,1|AMulti
	LW	TRANSFORM_K_3,1|AMulti

	LW	TRANSFORM_K_4,1|AMulti
	LW	TRANSFORM_K_4,1|AMulti

	LW	TRANSFORM_K_5,1|AMulti
	LW	TRANSFORM_K_5,1|AMulti

	LWL	TRANSFORM_K_6,1|AMulti|AFunc,OBJ_ON
	LWL	TRANSFORM_K_6,1|AMulti|AFunc,OBJ_ON

	LWL	TRANSFORM_K_7,1|AMulti|AFunc,OBJ_ON
	LWL	TRANSFORM_K_7,1|AMulti|AFunc,OBJ_ON

	LWL	TRANSFORM_K_8,1|AMulti|AFunc,OBJ_ON
	LWL	TRANSFORM_K_8,1|AMulti|AFunc,OBJ_ON

	LW	1,1|AMulti

	LWL	TRANSFORM_K_9,1|AMulti|AFunc,OBJ_ON
	LWL	TRANSFORM_K_9,XFORM_TIX|AFunc,OBJ_ON


	LW	TRANSFORM_L_1,1|AMulti
	LW	TRANSFORM_L_1,1|AMulti

	LW	TRANSFORM_L_2,1|AMulti
	LW	TRANSFORM_L_2,1|AMulti

	LW	TRANSFORM_L_3,1|AMulti
	LW	TRANSFORM_L_3,1|AMulti

	LW	TRANSFORM_L_4,1|AMulti
	LW	TRANSFORM_L_4,1|AMulti

	LW	TRANSFORM_L_5,1|AMulti
	LW	TRANSFORM_L_5,1|AMulti

	LW	TRANSFORM_L_6,1|AMulti
	LW	TRANSFORM_L_6,1|AMulti

	LW	TRANSFORM_L_7,1|AMulti
	LW	TRANSFORM_L_7,1|AMulti

	LW	TRANSFORM_L_8,1|AMulti
	LW	TRANSFORM_L_8,1|AMulti

	LW	1,1|AMulti

	LW	TRANSFORM_L_9,1|AMulti
	LW	TRANSFORM_L_9,XFORM_TIX


	LW	TRANSFORM_M_1,1|AMulti
	LW	TRANSFORM_M_1,1|AMulti

	LWL	TRANSFORM_M_2,1|AMulti|AFunc,A_START_SEAT_RISE
	LW	TRANSFORM_M_2,1|AMulti

	LW	TRANSFORM_M_3,1|AMulti
	LW	TRANSFORM_M_3,1|AMulti

	LW	TRANSFORM_M_4,1|AMulti
	LW	TRANSFORM_M_4,1|AMulti

	LW	TRANSFORM_M_5,1|AMulti
	LW	TRANSFORM_M_5,1|AMulti

	LW	TRANSFORM_M_6,1|AMulti
	LW	TRANSFORM_M_6,1|AMulti

	LW	TRANSFORM_M_7,1|AMulti
	LW	TRANSFORM_M_7,1|AMulti

	LWL	1,1|AMulti|AFunc,OBJ_OFF
	LWL	1,1|AMulti|AFunc,OBJ_OFF

	LW	1,1|AMulti

	LWL	1,1|AMulti|AFunc,OBJ_OFF
	LWL	1,XFORM_TIX|AFunc,OBJ_OFF


	LWLL	C_TIT_1,1|AMulti|AFunc,A_CHANGE_PAL+2,DA_MECH_P
	LWLL	C_TIT_1,1|AMulti|AFunc,A_CHANGE_PAL+2,DA_MECH_P

	LWLL	C_SHOULDER_1,1|AMulti|AFunc,A_CHANGE_PAL+2,DA_MECH_P
	LWLL	C_SHOULDER_1,1|AMulti|AFunc,A_CHANGE_PAL+2,DA_MECH_P

	LWLL	C_EYES_1,1|AMulti|AFunc,A_CHANGE_PAL+2,DA_MECH_P
	LWLL	C_EYES_1,1|AMulti|AFunc,A_CHANGE_PAL+2,DA_MECH_P

	LWLL	C_GATLIN_1,1|AMulti|AFunc,A_CHANGE_PAL+2,DA_MECH_P
	LWLL	C_GATLIN_1,1|AMulti|AFunc,A_CHANGE_PAL+2,DA_MECH_P

	LWWLL	C_FRONT_1,1|AMulti|AFlip|AFunc,0,A_CHANGE_PAL+2,DA_MECH_P
	LWL	YDMRISE1,1|AMulti|AFunc,OBJ_OFF

	LWL	1,1|AMulti|AFunc,OBJ_OFF
	LWLL	C_GATLIN_ARM,1|AMulti|AFunc,A_OBJ_ON_CHANGE_PAL+2,DA_MECH_P

	LWLL	C_GATLIN_ARM,1|AMulti|AFunc,A_OBJ_ON_CHANGE_PAL+2,DA_MECH_P
	LWL	1,1|AMulti|AFunc,OBJ_OFF

	LW	1,1|AMulti
	LW	1,1|AMulti

	LW	1,1|AMulti

	LWL	C_EYES_2,1|AMulti|AFunc,A_INIT_EYE_DAMAGE
	LWL	C_EYES_2,1|AFunc,A_INIT_EYE_DAMAGE


	LWL	1,1|AFunc,CLR_VEL

	LWL	1,1|AFunc,A_START_COLLS

	LWL	1,10|AFunc,A_START_JOSH

	LWLL	1,80|AFunc,A_SOUND+2,SND_DESK_BATTLE

	LWL	1,1|AFunc,A_BATTLE_STATIONS

	LWL	1,1|AFunc,PULL_ANIM

*
*Animation to make the dome rise
*
ANIM_DOME_UP
	LWL	1,(XFORM_TIX-1)|AFunc,OBJ_ON
	LWL	1,XFORM_TIX|AFunc,A_DOME_UP
	LWL	1,XFORM_TIX|AFunc,A_DOME_UP
	LWL	1,XFORM_TIX|AFunc,A_DOME_UP
	LWL	1,XFORM_TIX|AFunc,A_DOME_UP
	LWL	1,XFORM_TIX|AFunc,A_DOME_DONE

	LWL	1,1|AFunc,PULL_ANIM

*
*Animation script to keep tabs on the velocity and movement boundries
*
ANIM_VELOCITY_WATCH
	LWL	1,1|AFunc,A_VELOCITY_WATCH
	.LONG	0

*
*Handle Desk's movement
*
ANIM_MOVEMENT
	LWL	1,1|AFunc,A_MOVE_AROUND
	.LONG	0

*
*Gatlin gun idles
*
ANIM_GAT_IDLE
	LWL	C_GATLIN_1,1|AFunc,A_SELECT_GAT_IDLE_TIME
	LW	1,0
	LWLW	1,1|AFunc,A_GAT_DECISION+1,ANUM_IDLE

*
*Make Gatlin gun fire
*
*Common shoot animation hook
ANIM_GAT_SHOOT
	LW	1,6
	LWL	1,5|AFunc,A_RANDOM_BURST_COUNT
AAGAT_SHOOTER
	LWL	1,5|AFunc,A_RANDOM_RAPID_COUNT
AAGAT_RAPID_FIRE
	LWLWW	1,7|AFunc,A_GAT_FIRE_FNC+2,-170,37
	LWLL	1,1|AFunc,A_GAT_RAPIDFIRE_DECISION+2,AAGAT_RAPID_FIRE
	LWLWW	1,1|AFunc,A_RAND_AnimSLP+2,7,20
	LW	1,0
	LWLL	1,1|AFunc,A_GAT_BURST_DECISION+2,AAGAT_SHOOTER
	LWLW	1,1|AFunc,A_GAT_DECISION+1,ANUM_FIRE

*
*Gun flash creation tables
*
NUM_GUN_FLASHES	.EQU	6

GUN_FLASH_TABLE
	.LONG	GAT_FLASH_1, GAT_FLASH_2, GAT_FLASH_3, GAT_FLASH_4
	.LONG	GAT_FLASH_5, GAT_FLASH_6


GAT_FLASH_1
	.LONG	GATLIN_F_2
	.word	DMAWNZ,M_DEAD|M_NOPARTANI,OM_ANIM
	.LONG	ANIM_GAT_FLASH
GAT_FLASH_2
	.LONG	GATLIN_F_3
	.word	DMAWNZ,M_DEAD|M_NOPARTANI,OM_ANIM
	.LONG	ANIM_GAT_FLASH
GAT_FLASH_3
	.LONG	GATLIN_F_4
	.word	DMAWNZ,M_DEAD|M_NOPARTANI,OM_ANIM
	.LONG	ANIM_GAT_FLASH
GAT_FLASH_4
	.LONG	GATLIN_F_6
	.word	DMAWNZ,M_DEAD|M_NOPARTANI,OM_ANIM
	.LONG	ANIM_GAT_FLASH
GAT_FLASH_5
	.LONG	GATLIN_F_7
	.word	DMAWNZ,M_DEAD|M_NOPARTANI,OM_ANIM
	.LONG	ANIM_GAT_FLASH
GAT_FLASH_6
	.LONG	GATLIN_F_8
	.word	DMAWNZ,M_DEAD|M_NOPARTANI,OM_ANIM
	.LONG	ANIM_GAT_FLASH

*
*Gat gets whacked
*
ANIM_GAT_WHACK
	LWLL	C_GATLIN_3,25|AFunc,A_SOUND+2,SND_GAT_WHACK
	LW	C_GATLIN_2,8
	LW	C_GATLIN_1,80
	LWLW	1,8|AFunc,A_GAT_DECISION+1,ANUM_WHACK

*
*Generic gun flash animation
*
ANIM_GAT_FLASH
	LW	1,4
	LWL	1,1|AFunc,DELETE_OBJ

*
*The talking head finishes of "So nice to see you!"
*
;ANIM_JOSH_HEAD_NICE
;	LWLW	J1_TALK_A,1|AFunc,A_Set_AnimLoop+1,3
;AJHN_LOOP
;	LWL	1,6|AFunc,OBJ_ON
;	LWL	1,5|AFunc,OBJ_OFF
;	LWLL	1,1|AFunc,A_Anim_DSJ+2,AJHN_LOOP
;	LWL	1,1|AFunc,PULL_ANIM
	
*
*The talking head says, "Prease to enjoy, new Japan technology"
*
;ANIM_JOSH_HEAD_PREASE
;	LWLW	J1_TALK_A,1|AFunc,A_Set_AnimLoop+1,2
;AJHP_LOOP1
;	LWL	1,6|AFunc,OBJ_ON
;	LWL	1,5|AFunc,OBJ_OFF
;	LWLL	1,1|AFunc,A_Anim_DSJ+2,AJHP_LOOP1
;	LW	1,10
;	LWLW	1,1|AFunc,A_Set_AnimLoop+1,6
;AJHP_LOOP2
;	LWL	1,6|AFunc,OBJ_ON
;	LWL	1,5|AFunc,OBJ_OFF
;	LWLL	1,1|AFunc,A_Anim_DSJ+2,AJHP_LOOP2

;	LW	1,5

;	LWLW	1,1|AFunc,A_Set_AnimLoop+1,5
;AJHP_LOOP3
;	LWL	1,6|AFunc,OBJ_ON
;	LWL	1,5|AFunc,OBJ_OFF
;	LWLL	1,1|AFunc,A_Anim_DSJ+2,AJHP_LOOP3

;	LWL	1,1|AFunc,PULL_ANIM

	
*
*Table of actions that Josh does whilst driving his desk
*
JOSH_ACTIONS
	.LONG	ANIM_JOSH_IDLE, ANIM_JOSH_VICTORY, ANIM_PISSED
	.LONG	ANIM_JOSH_BLOWN, ANIM_JOSH_STEER_L, ANIM_JOSH_STEER_R

*
*Animation to make Josh the mech-pilot appear
*
ANIM_JOSH_UP
	LWLL	1,35|AFunc,A_CHANGE_PAL+2,P_GXDOME
	LWL	1,6|AFunc,OBJ_ON
	LWLL	YDMRISE2,6|AFunc,A_SOUND+2,SND_GET_READY
	LW	YDMRISE3,6
	LW	YDMRISE4,6
	LW	YDMSTAND,35
	LWLL	1,1|AFunc,A_AnimGo+2,ANIM_BANZAI

*
* Table of animations that make Josh vocalize
*
JOSH_VOCALS
	.LONG	ANIM_BANZAI, ANIM_GAI_JIN, ANIM_SUPERIOR, ANIM_BLUE_EYE
	.LONG	ANIM_LAST_LAUGH, ANIM_GIMME, ANIM_NEW_ORDER
	.LONG	ANIM_DESK_DESTROY, ANIM_SORRY, ANIM_NOOO, ANIM_BEAST
	.LONG	ANIM_FORGIVE, ANIM_USELESS, ANIM_HURT_DESK, ANIM_PISSED


ANIM_BANZAI
	LWLW	1,1|AFunc,A_SUB_SND+1,SNUM_BANZAI
	LWLL	1,1|AFunc,A_AnimGo+2,ANIM_JOSH_VICTORY

ANIM_GAI_JIN
	LWLW	1,1|AFunc,A_SUB_SND+1,SNUM_GAI_JIN
	LWLL	1,1|AFunc,A_AnimGo+2,ANIM_JOSH_VICTORY

ANIM_SUPERIOR
	LWLW	1,1|AFunc,A_SUB_SND+1,SNUM_SUPERIOR
	LWLL	1,1|AFunc,A_AnimGo+2,ANIM_JOSH_VICTORY

ANIM_BLUE_EYE
	LWLW	1,1|AFunc,A_SUB_SND+1,SNUM_BLUE_EYE
	LWLL	1,1|AFunc,A_AnimGo+2,ANIM_JOSH_VICTORY

ANIM_LAST_LAUGH
	LWLW	1,1|AFunc,A_SUB_SND+1,SNUM_LAST_LAUGH
	LWLL	1,1|AFunc,A_AnimGo+2,ANIM_JOSH_VICTORY

ANIM_GIMME
	LWLW	1,1|AFunc,A_SUB_SND+1,SNUM_GIMME
	LWLL	1,1|AFunc,A_AnimGo+2,ANIM_JOSH_VICTORY

ANIM_NEW_ORDER
	LWLW	1,1|AFunc,A_SUB_SND+1,SNUM_NEW_ORDER
	LWLL	1,1|AFunc,A_AnimGo+2,ANIM_JOSH_VICTORY

ANIM_DESK_DESTROY
	LWLW	1,1|AFunc,A_SUB_SND+1,SNUM_DESK_DESTROY
	LWLL	1,1|AFunc,A_AnimGo+2,ANIM_JOSH_VICTORY

ANIM_SORRY
	LWLW	YDMSTAND,37|AFunc,A_SUB_SND+1,SNUM_SORRY
	LWLL	1,1|AFunc,A_AnimGo+2,ANIM_JOSH_IDLE
	
ANIM_BEAST
	LW	1,60
	LWLW	1,1|AFunc,A_SUB_SND+1,SNUM_BEAST
	LWLL	1,1|AFunc,A_AnimGo+2,ANIM_PISSED_G

ANIM_FORGIVE
	LW	1,60
	LWLW	1,1|AFunc,A_SUB_SND+1,SNUM_FORGIVE
	LWLL	1,1|AFunc,A_AnimGo+2,ANIM_PISSED_G

ANIM_USELESS
	LW	1,60
	LWLW	1,26|AFunc,A_SUB_SND+1,SNUM_USELESS
	LWLL	1,1|AFunc,A_AnimGo+2,ANIM_JOSH_IDLE

ANIM_HURT_DESK
	LW	1,60
	LWLW	1,1|AFunc,A_SUB_SND+1,SNUM_HURT_DESK
	LWLL	1,1|AFunc,A_AnimGo+2,ANIM_PISSED_G

ANIM_PISSED
	LW	1,40
	LWLW	1,1|AFunc,A_SUB_SND+1,SNUM_PISSED
	LWLL	1,1|AFunc,A_AnimGo+2,ANIM_PISSED_G
	
ANIM_NOOO
	LWLW	1,1|AFunc,A_SUB_SND+1,SNUM_NOOO
ANIM_PISSED_G
	LW	YDMFLAIL1,4
	LW	YDMFLAIL2,4
	LW	YDMFLAIL3,4
	LW	YDMFLAIL4,4
	LW	YDMFLAIL5,4
	LW	YDMFLAIL6,4
	LW	YDMFLAIL7,4
	LWLW	1,1|AFunc,A_JOSH_DECISION+1,ANUM_PISSED

*
*Josh sits idley by as the his craft gets destroyed
*
ANIM_JOSH_IDLE
	LWL	YDMSTAND,1|AFunc,A_SELECT_JOSH_IDLE_TIME
	LWLL	1,1|AFunc,A_AnimScr+2,AJIDLE_LOOP
AJIDLE_LOOP
	LWLW	1,1|AFunc,A_JOSH_DECISION+1,ANUM_IDLE
	.LONG	0

*
*Josh puts a fist up in a victory gesture
*
ANIM_JOSH_VICTORY
	LWLW	YDMFIST1,4|AFunc,A_Set_AnimLoop+1,3
	LW	YDMFIST2,4
ANIM_JOSH_VICTORY_LOOP
	LW	YDMFIST3,9
	LWLL	YDMFIST4,9|AFunc,A_Anim_DSJ+2,ANIM_JOSH_VICTORY_LOOP
	LWLW	1,1|AFunc,A_JOSH_DECISION+1,ANUM_VICTORY

*
*Josh gets blown back
*
ANIM_JOSH_BLOWN
	LW	YDMTILT1,4
	LW	YDMTILT2,4
	LW	YDMTILT3,4
	LW	YDMTILT4,0
	LW	YDMTILT3,3
	LW	YDMTILT2,3
	LWLW	YDMTILT1,3|AFunc,A_JOSH_DECISION+1,ANUM_BLOWN

*
*Josh steers to screen Left
*
ANIM_JOSH_STEER_L
	LWW	YDMLEAN1,1|AFlip,M_FLIPH
	LWLL	1,5|AFunc,A_STEER_CHECK+2,AJSL_X_1
	LWLL	YDMLEAN3,6|AFunc,A_STEER_CHECK+2,AJSL_X_2
AJSL_LOOP
	LWLWL	YDMLEAN4,0|AFunc,A_DEC_STEER_TIME+3,ANUM_STEER_L,AJSL_LOOP
AJSL_X_2
	LW	YDMLEAN3,4
AJSL_X_1
	LWLW	YDMLEAN1,4|AFunc,A_JOSH_DECISION+1,ANUM_STEER_L

*
*Josh steers to screen Right
*
ANIM_JOSH_STEER_R
	LWW	YDMLEAN1,1|AFlip,0
	LWLL	1,5|AFunc,A_STEER_CHECK+2,AJSR_X_1
	LWLL	YDMLEAN3,6|AFunc,A_STEER_CHECK+2,AJSR_X_2
AJSR_LOOP
	LWLWL	YDMLEAN4,0|AFunc,A_DEC_STEER_TIME+3,ANUM_STEER_R,AJSR_LOOP
AJSR_X_2
	LW	YDMLEAN3,4
AJSR_X_1
	LWLW	YDMLEAN1,4|AFunc,A_JOSH_DECISION+1,ANUM_STEER_R

*
* Run a sub-title.  Used by the left half of the seat.
*
ANIM_SUBTITLE
	LWL	1,1|AFunc,A_CHECK_SUB
	.LONG	0

**************************************************************************
*								         *
* 			Missle Launcher Animations			 *
*								         *
**************************************************************************

*
*Animation for the front missle door
*
ANIM_FRONT_MISSLE
	LWLL	1,1|AFunc,A_CHANGE_PAL+2,DA_MECH_P
ANIM_FRONT_LOOP
	LWLWW	1,1|AFunc,A_RAND_AnimSLP+2,60,120
	LW	1,0
	LWLL	1,1|AFunc,A_CHECK_OK_MISSLE+2,ANIM_FRONT_LOOP

	LWLL	1,1|AFunc,A_CHECK_FRONT_DEAD+2,ANIM_FRONT_DAMAGE

	LWLL	1,1|AFunc,A_SOUNDZ+2,SND_DOOR_OPEN
	LWL	C_FRONT_A,4|AFunc,OBJ_ON
	LW	C_FRONT_B,4
	LWLLWW	C_FRONT_C,20|AFunc,A_SPAWN_N_MISSLES+4,FRONT_MISSLE_TAB,6,3
ANIM_FRONT_WAIT
	LWLL	1,5|AFunc,A_WAIT_FOR_MISSLES+2,ANIM_FRONT_WAIT
	LW	1,15
	LWLL	1,1|AFunc,A_SOUNDZ+2,SND_DOOR_OPEN
	LW	C_FRONT_B,4
	LW	C_FRONT_A,4
	LWL	1,1|AFunc,OBJ_OFF
	LWL	1,1|AFunc,A_CLR_MISSLE_OPEN
	LWLL	1,1|AFunc,A_AnimFrm+2,ANIM_FRONT_LOOP

*
*Table of offsets for the front missles
*
FRONT_MISSLE_TAB
	.WORD	-24,-8
	.WORD	-2,-8
	.WORD	23,-8
	.WORD	-24,9
	.WORD	-2,9
	.WORD	23,9

*
*Animation for the shoulder missle bay
*
ANIM_SHOULDER_MISSLE
	LWLWW	1,1|AFunc,A_RAND_AnimSLP+2,60,120
	LW	1,0

	LWLL	1,1|AFunc,A_CHECK_OK_MISSLE+2,ANIM_SHOULDER_MISSLE

	LWLWL	1,1|AFunc,A_BRANCH_PCNT+3,512,ANIM_SHORT_SHOULDER

	LWLW	1,1|AFunc,A_Set_AnimLoop+1,7
	LWLL	1,1|AFunc,A_SOUNDZ+2,SND_SHOULDER_LONG
ANIM_SHOULDER_LOOP
	LWLW	1,1|AFunc,A_ADD_YPOS+1,-4
	LWLL	1,1|AFunc,A_Anim_DSJ+2,ANIM_SHOULDER_LOOP
	LWLLWW	1,20|AFunc,A_SPAWN_N_MISSLES+4,SHOULDER_MISSLE_TAB,6,3
ANIM_SHOULDER_WAIT
	LWLL	1,5|AFunc,A_WAIT_FOR_MISSLES+2,ANIM_SHOULDER_WAIT
	LW	1,15
	LWLL	1,1|AFunc,A_SOUNDZ+2,SND_SHOULDER_LONG
	LWLW	1,1|AFunc,A_Set_AnimLoop+1,7
ANIM_SHOULDER_DOWN_LOOP
	LWLW	1,1|AFunc,A_ADD_YPOS+1,4
	LWLL	1,1|AFunc,A_Anim_DSJ+2,ANIM_SHOULDER_DOWN_LOOP
	LWL	1,1|AFunc,A_CLR_MISSLE_OPEN
	LWLL	1,1|AFunc,A_AnimFrm+2,ANIM_SHOULDER_MISSLE

*
*Animation for the shoulder missle bay, short pop-up, three holes only
*
ANIM_SHORT_SHOULDER
	LWLL	1,1|AFunc,A_SOUNDZ+2,SND_SHOULDER_SHORT
	LWLW	1,1|AFunc,A_Set_AnimLoop+1,4
ANIM_SHOULDER_LOOP2
	LWLW	1,1|AFunc,A_ADD_YPOS+1,-4
	LWLL	1,1|AFunc,A_Anim_DSJ+2,ANIM_SHOULDER_LOOP2
	LWLLWW	1,20|AFunc,A_SPAWN_N_MISSLES+4,SHOULDER_MISSLE_TAB,3,3
ANIM_SHOULDER_WAIT2
	LWLL	1,5|AFunc,A_WAIT_FOR_MISSLES+2,ANIM_SHOULDER_WAIT2
	LW	1,15
	LWLL	1,1|AFunc,A_SOUNDZ+2,SND_SHOULDER_SHORT
	LWLW	1,1|AFunc,A_Set_AnimLoop+1,4
ANIM_SHOULDER_DOWN_LOOP2
	LWLW	1,1|AFunc,A_ADD_YPOS+1,4
	LWLL	1,1|AFunc,A_Anim_DSJ+2,ANIM_SHOULDER_DOWN_LOOP2
	LWL	1,1|AFunc,A_CLR_MISSLE_OPEN
	LWLL	1,1|AFunc,A_AnimFrm+2,ANIM_SHOULDER_MISSLE

*
*Table of offsets for the shoulder missles
*
SHOULDER_MISSLE_TAB
	.WORD	-107,-33
	.WORD	-89,-37
	.WORD	-71,-41
	.WORD	-107,-11
	.WORD	-89,-15
	.WORD	-71,-19

;	.WORD	-107,-89
;	.WORD	-89,-93
;	.WORD	-71,-97
;	.WORD	-107,-67
;	.WORD	-89,-71
;	.WORD	-71,-75

*
*Initialize desk missle
*
MISSLE_INIT
	.LONG	C_BABYMISILE
	.WORD	DMAWNZ, M_OPARTSXY, OM_OID|OM_COLL|OM_GUNV|OM_ANIM|OM_CFUNC
	.WORD	OID_EROCKET
	.LONG	MISSLE_CVECT, MISSLE_GUNVECT, ANIM_MISSLE, C_MISSLE

*
*Missle animation
*
ANIM_MISSLE
	LWLL	1,1|AFunc,A_CHECK_MISSLE_PAUSE+2,ANIM_MISSLE_NO_PAUSE
	LWLWW	1,60|AFunc,A_RAND_AnimSLP+2,60,120
	LWLL	1,1|AFunc,A_AnimFrm+2,ANIM_MISSLE_WAIT
ANIM_MISSLE_NO_PAUSE
	LWLWW	1,1|AFunc,A_RAND_AnimSLP+2,20,120
ANIM_MISSLE_WAIT
	LW	1,0
ANIM_MISSLE_GO
	LWLL	1,1|AFunc,A_OFFSCREEN+2,ANIM_MISSLE_WAIT
	LWL	1,1|AFunc,A_MAKE_SMOKE
	LWL	1,10|AFunc,A_MISSLE_TARGET
	LWLL	mossile1,4|AFunc,A_CHANGE_PAL+2,mossred
	LW	mossile2,4
	LW	mossile3,4
	LW	mossile4,4
	LW	mossile5,4
	LW	mossile6,4
	LW	mossile7,4
ANIM_MISSLE_LOOP
	LW	1,2
	LWL	1,2|AFunc,A_CHECK_MISSLE_SCREEN_HIT
	LW	1,2
	LWL	1,2|AFunc,A_CHECK_MISSLE_SCREEN_HIT
	LW	1,2
	LWL	1,2|AFunc,A_CHECK_MISSLE_SCREEN_HIT
	LWLL	1,2|AFunc,A_ONSCREEN+2,ANIM_MISSLE_LOOP
	LWLWL	1,1|AFunc,A_Set_Rel_Long+3,OPROJECT_PARENT,0
	LWL	1,1|AFunc,DELETE_OBJ_PROC

*
*Missle lauch smoke
*
ANIM_MISSLE_SMOKE
	LWLL	MSLSMOKE2,4|AFunc,A_OBJ_ON_CHANGE_PAL+2,SMOKEPAL
	LW	MSLSMOKE3,4
	LW	MSLSMOKE4,4
	LW	MSLSMOKE5,4
	LW	MSLSMOKE6,4
	LW	MSLSMOKE7,4
	LWL	1,1|AFunc,DELETE_OBJ
	
*
*Missle explodes in mid-air
*
ANIM_MISSLE_EXPLODE
	LWLL	1,1|AFunc,A_SOUNDZ+2,SND_MISSLE_EXPLODE
	LWLL	FHKEXPLOB1,1|AFunc,A_CHANGE_PAL+2,FX2
	LWLWL	1,1|AFunc,A_Set_Rel_Long+3,OPROJECT_PARENT,0
	LW	FHKEXPLOB2,4
	LW	FHKEXPLOB3,4
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
*TABLE OF FINAL ANIMATIONS FOR DESK PARTS
*
FINAL_ANIM_TABLE
	.LONG	ANIM_TIT_FINAL		;Tit - left
	.LONG	ANIM_TIT_FINAL		;Tit - right
	.LONG	ANIM_SHOULDER_FINAL	;Shoulder - left
	.LONG	ANIM_SHOULDER_FINAL	;Shoulder - right
	.LONG	ANIM_EYE_FINAL		;Eye - left
	.LONG	ANIM_EYE_FINAL		;Eye - right
	.LONG	ANIM_GAT_FINAL		;Gun - left
	.LONG	ANIM_GAT_FINAL		;Gun - right
	.LONG	ANIM_FRONT_FINAL	;Front piece

ANIM_SHOULDER_FINAL
	LWL	1,1|AFunc,A_DESTROY_MISSLES

	LWLLLL	1,1|AFunc,A_PreFrag_Box+6,FRAG_EXPLOSION,80h,40000h

	LWLL	1,1|AFunc,A_INITIAL_SHOULDER_FREAK+2,ANIM_SHOULDER_FREAK
	LWLL	1,1|AFunc,A_SOUNDZ+2,SND_SHLDR_LONG_FINAL
ANIM_SHOULDERF_LOOPI
	LWLW	1,1|AFunc,A_ADD_YPOS+1,4
	LWLL	1,1|AFunc,A_Anim_DSJ+2,ANIM_SHOULDERF_LOOPI
ANIM_SHOULDER_FREAK
	LWLWW	1,1|AFunc,A_Set_Rel_Byte+2,OFREAK_CNT,4

ANIM_SHOULDERF_LOOP
	LWLWL	1,1|AFunc,A_BRANCH_PCNT+3,512,ANIM_SHOULDER_FREAK_LONG

	LWLL	1,1|AFunc,A_SOUNDZ+2,SND_SHLDR_SHORT_FINAL
	LWLW	1,1|AFunc,A_Set_AnimLoop+1,2
ANIM_SHOULDERF_LOOPSU
	LWLW	1,1|AFunc,A_ADD_YPOS+1,-8
	LWLL	1,1|AFunc,A_Anim_DSJ+2,ANIM_SHOULDERF_LOOPSU
	LWLL	1,1|AFunc,A_SOUNDZ+2,SND_SHLDR_SHORT_FINAL
	LWLW	1,1|AFunc,A_Set_AnimLoop+1,2
ANIM_SHOULDERF_LOOPSD
	LWLW	1,1|AFunc,A_ADD_YPOS+1,8
	LWLL	1,1|AFunc,A_Anim_DSJ+2,ANIM_SHOULDERF_LOOPSD
	LWLL	1,1|AFunc,A_AnimFrm+2,ANIM_END_SFREAK

ANIM_SHOULDER_FREAK_LONG
	LWLLLL	1,1|AFunc,A_PreFrag_Box+6,FRAG_EXPLOSION,80h,40000h
	LWLL	1,1|AFunc,A_SOUNDZ+2,SND_SHLDR_LONG_FINAL
	LWLW	1,1|AFunc,A_Set_AnimLoop+1,3
ANIM_SHOULDERF_LOOPLU
	LWLW	1,1|AFunc,A_ADD_YPOS+1,-8
	LWLL	1,1|AFunc,A_Anim_DSJ+2,ANIM_SHOULDERF_LOOPLU
	LWLL	1,1|AFunc,A_SOUNDZ+2,SND_SHLDR_LONG_FINAL
	LWLW	1,1|AFunc,A_Set_AnimLoop+1,3
ANIM_SHOULDERF_LOOPLD
	LWLW	1,1|AFunc,A_ADD_YPOS+1,8
	LWLL	1,1|AFunc,A_Anim_DSJ+2,ANIM_SHOULDERF_LOOPLD

ANIM_END_SFREAK
	LWLLLL	1,1|AFunc,A_PreFrag_Box+6,FRAG_EXPLOSION,80h,40000h
	LWLWL	1,1|AFunc,A_Anim_Rel_DSJ+3,OFREAK_CNT,ANIM_SHOULDERF_LOOP


	LWLWL	1,1|AFunc,A_Set_Rel_Long+3,OPART_FINAL_CONT,ANIM_SHOULDER_FIRE
	LWL	1,1|AFunc,A_MULTI_METAL_CHUNK
	LWLL	C_SHOULDER_2,5|AFunc,A_CHANGE_PAL+2,C_DAMGE_P
	LWL	1,1|AFunc,A_CLR_MISSLE_OPEN
	LWLW	1,1|AFunc,A_SET_MISSLE_WAIT+1,3*60
	LWLLWWW	1,1|AFunc,A_SPAWN_FIRE+5,INIT_FLAMER_B,-140,-122,1
	LWLL	1,1|AFunc,A_AnimFrm+2,ANIM_BIG_SHIT_EXPLOSION

ANIM_SHOULDER_FIRE
	LWLLWWW	1,1|AFunc,A_SPAWN_FIRE+5,INIT_FLAMER_A,-101,-61,1
	LWL	1,1|AFunc,PULL_ANIM

ANIM_EYE_FINAL
	LWLWL	1,1|AFunc,A_Set_Rel_Long+3,OPART_FINAL_CONT,ANIM_EYE_FIRE
	LWLLLL	1,1|AFunc,A_PreFrag_Box+6,FRAG_EXPLOSION,80h,40000h
	LWL	1,1|AFunc,A_MULTI_METAL_CHUNK
	LWL	1,5|AFunc,A_TURN_ON_EYE_DAMAGE
	LWLL	1,1|AFunc,A_AnimFrm+2,ANIM_BIG_SHIT_EXPLOSION

ANIM_EYE_FIRE
	LWLLWWW	1,1|AFunc,A_SPAWN_FIRE+5,INIT_FLAMER_A,-52,-16,-2
	LWL	1,1|AFunc,PULL_ANIM

ANIM_FRONT_FINAL
	LWLLLL	1,1|AFunc,A_PreFrag_Box+6,FRAG_EXPLOSION,80h,40000h
	LWL	1,1|AFunc,A_MULTI_METAL_CHUNK
	LWL	1,5|AFunc,A_TURN_ON_FRONT_DAMAGE
	LWLL	1,1|AFunc,A_OBJ_ON_CHANGE_PAL+2,C_DAMGE_P
	LWLL	1,1|AFunc,A_AnimFrm+2,ANIM_BIG_SHIT_EXPLOSION

ANIM_TIT_FINAL
	LWLWL	1,1|AFunc,A_Set_Rel_Long+3,OPART_FINAL_CONT,ANIM_TIT_FIRE
	LWLLLL	1,1|AFunc,A_PreFrag_Box+6,FRAG_EXPLOSION,80h,40000h
	LWL	1,1|AFunc,A_MULTI_METAL_CHUNK
	LWLL	C_TIT_2,5|AFunc,A_CHANGE_PAL+2,C_DAMGE_P
	LWLL	1,1|AFunc,A_AnimFrm+2,ANIM_BIG_SHIT_EXPLOSION

ANIM_TIT_FIRE
	LWLLWWW	1,1|AFunc,A_SPAWN_FIRE+5,INIT_FLAMER_B,-112,-74,1
	LWL	1,1|AFunc,PULL_ANIM

ANIM_BIG_SHIT_EXPLOSION
	LWLLLL	1,1|AFunc,A_PreFrag_Box+6,FRAG_EXPLOSION,80h,40000h
	LWL	1,1|AFunc,A_START_MEDIUM_SHAKE
	LWL	1,26|AFunc,A_MULTI_METAL_CHUNK
	LWLLLL	1,1|AFunc,A_PreFrag_Box+6,FRAG_EXPLOSION,80h,40000h
	LWL	1,1|AFunc,A_START_MEDIUM_SHAKE
	LWL	1,16|AFunc,A_MULTI_METAL_CHUNK
	LWLWW	1,1|AFunc,A_RAND_AnimSLP+2,1,10
	LW	1,0
	LWL	1,1|AFunc,A_CHECK_IF_FINAL
	LWL	1,1|AFunc,A_CONTINUE_PART_FINAL
	LWL	1,1|AFunc,PULL_ANIM


ANIM_GAT_FINAL
	LWLLLL	1,1|AFunc,A_PreFrag_Box+6,FRAG_EXPLOSION,80h,40000h
	LWLW	1,1|AFunc,A_Set_AnimLoop+1,5
AGF_LOOP
	LWL	1,5|AFunc,A_BLOW_GAT
	LWLLLL	1,1|AFunc,A_PreFrag_Box+6,FRAG_EXPLOSION,80h,40000h
	LWLL	1,1|AFunc,A_Anim_DSJ+2,AGF_LOOP
	LWL	C_GATLIN_D,1|AFunc,A_CHECK_IF_FINAL
	LWL	1,1|AFunc,PULL_ANIM

**************************************************************************
*								         *
* 	This is the explosion that decimates the desk			 *
*								         *
**************************************************************************
ANIM_FINAL_EXPLOSION
;	LWL	1,1|AFunc,A_MAKE_NOOO
	LWLL	1,1|AFunc,A_SOUND+2,SND_NOOO

	LWLW	1,1|AFunc,A_Set_AnimLoop+1,3
AFE_LOOP
	LWLLLL	1,1|AFunc,A_PreFrag_Center+6,FRAG_EXPLOSION,0400h,40000h
	LWL	1,1|AFunc,A_START_BIG_SHAKE
	LWLLLL	1,1|AFunc,A_PreFrag_Center+6,FRAG_EXPLOSION,0400h,40000h
	LWLWW	1,1|AFunc,A_RAND_AnimSLP+2,10,25
	LWLL	1,0|AFunc,A_Anim_DSJ+2,AFE_LOOP

	LWLW	1,1|AFunc,A_Set_AnimLoop+1,10
AFE_CRAFT_BLOW
	LWL	1,1|AFunc,A_KEEP_US_CENTERED
	LWLLLL	1,1|AFunc,A_PreFrag_Center+6,FRAG_EXPLOSION,0400h,40000h
	LWL	1,2|AFunc,A_START_MEDIUM_SHAKE
	LWLWW	1,1|AFunc,A_RAND_AnimSLP+2,5,10
	LWLL	1,0|AFunc,A_Anim_DSJ+2,AFE_CRAFT_BLOW

	LWL	1,7|AFunc,A_GOOD_TO_GO

	LWLWL	1,1|AFunc,A_CREATEP+3,PID_IND,PROC_SKY_FLASH
	LWLL	1,1|AFunc,A_SOUND+2,SND_FINAL_EXPLODE3
	LWLLLL	1,1|AFunc,A_PreFrag_Center+6,FRAG_DESK_EXPLOSION,01000h,80000h
	LWLL	1,1|AFunc,A_SOUND+2,SND_FINAL_EXPLODE2
	LWLL	1,1|AFunc,A_SOUND+2,SND_FINAL_EXPLODE1
	LWLLLL	1,1|AFunc,A_PreFrag_Center+6,FRAG_DESK_METAL,01000h,80000h

	LWLLLL	1,1|AFunc,A_PreFrag_Rain+6,FRAG_DESK_RAIN,80H,40000H

	LWL	1,15|AFunc,A_START_BLOWS

	LWLL	1,1|AFunc,A_SOUND+2,SND_FINAL_SCREAM

	LWL	1,50|AFunc,A_DESK_OFF

	LWLWL	1,1|AFunc,A_CREATEP+3,PID_IND,PROC_TEMP_ENDING

	LWL	1,1|AFunc,A_DELETE_CREATE

*
*Animation to turn on damage for a given eye
*
ANIM_EYE_DAMAGE
	LWL	1,1|AFunc,OBJ_ON
	LWL	1,1|AFunc,PULL_ANIM
	
*
*Animation to turn on damage for the front piece
*
ANIM_FRONT_DAMAGE
	LWL	1,4|AFunc,A_DESTROY_MISSLES
	LWLL	C_FRONT_2,1|AFunc,A_OBJ_ON_CHANGE_PAL+2,C_DAMGE_P
	LWL	1,1|AFunc,A_CLR_MISSLE_OPEN
	LWLW	1,1|AFunc,A_SET_MISSLE_WAIT+1,3*60
	LWL	1,1|AFunc,PULL_ANIM

*
*Final blow animations
*
ANIM_SHOULDER_BLOW
	LWLW	1,1|AFunc,A_Set_AnimLoop+1,7
ANIM_SB_LOOP
	LWL	1,5|AFunc,A_BLOW_SHOULDER
	LWLL	1,1|AFunc,A_Anim_DSJ+2,ANIM_SB_LOOP
	LWL	1,1|AFunc,PULL_ANIM

ANIM_EYE_BLOW
	LWLW	1,1|AFunc,A_Set_AnimLoop+1,7
ANIM_EYE_LOOP
	LWL	1,5|AFunc,A_BLOW_EYE
	LWLL	1,1|AFunc,A_Anim_DSJ+2,ANIM_EYE_LOOP
	LWL	1,1|AFunc,PULL_ANIM

ANIM_TIT_BLOW
	LWLW	1,1|AFunc,A_Set_AnimLoop+1,7
ANIM_TIT_LOOP
	LWL	1,5|AFunc,A_BLOW_TIT
	LWLL	1,1|AFunc,A_Anim_DSJ+2,ANIM_TIT_LOOP
	LWL	1,1|AFunc,PULL_ANIM

ANIM_DOME_BLOW
	LWLW	1,1|AFunc,A_Set_AnimLoop+1,7
ANIM_DOME_LOOP
	LWL	1,5|AFunc,A_BLOW_DOME
	LWLL	1,1|AFunc,A_Anim_DSJ+2,ANIM_DOME_LOOP
	LWL	1,1|AFunc,PULL_ANIM

ANIM_FRONT_BLOW
	LWLW	1,1|AFunc,A_Set_AnimLoop+1,7
ANIM_FB_LOOP
	LWL	1,5|AFunc,A_BLOW_FRONT
	LWLL	1,1|AFunc,A_Anim_DSJ+2,ANIM_FB_LOOP
	LWL	1,1|AFunc,PULL_ANIM

SHOULDER_BLOW_INIT
	.LONG	C_SHOULDER_2
	.WORD	DMAWNZ, 0, OM_ANIM|OM_DUMCOLL
	.LONG	ANIM_BLOW_SCREEN

TIT_BLOW_INIT
	.LONG	C_TIT_2
	.WORD	DMAWNZ, 0, OM_ANIM|OM_DUMCOLL
	.LONG	ANIM_BLOW_SCREEN

EYE_BLOW_INIT
	.LONG	C_EYES_2
	.WORD	DMAWNZ, 0, OM_ANIM|OM_DUMCOLL
	.LONG	ANIM_BLOW_SCREEN

DOME_BLOW_INIT
	.LONG	C_GLASS
	.WORD	DMAWNZ, 0, OM_ANIM|OM_DUMCOLL
	.LONG	ANIM_BLOW_SCREEN

FRONT_BLOW_INIT
	.LONG	C_FRONT_2
	.WORD	DMAWNZ, 0, OM_ANIM|OM_DUMCOLL
	.LONG	ANIM_BLOW_SCREEN

GAT_BLOW_INIT
	.LONG	C_GATLIN_1
	.WORD	DMAWNZ, 0, OM_ANIM|OM_DUMCOLL
	.LONG	ANIM_BLOW_SCREEN

*Simple animation to check if we are off screen and delete.
ANIM_BLOW_SCREEN
	LWLL	1,5|AFunc,A_ONSCREEN+2,ANIM_BLOW_SCREEN
	LWL	1,1|AFunc,DELETE_OBJ

*
*Initialize damage fire
*
INIT_FLAMER_A
	.LONG	HDFLAM1
	.WORD	DMAWNZ, M_DEAD|M_NOPARTANI|M_OPARTSXY, OM_ANIM
	.LONG	ANIM_FLAMER_A

INIT_FLAMER_B
	.LONG	HFIREA1
	.WORD	DMAWNZ, M_DEAD|M_NOPARTANI|M_OPARTSXY, OM_ANIM
	.LONG	ANIM_FLAMER_B

;INIT_FLAMER_C
;	.LONG	FIRE_A_1
;	.WORD	DMAWNZ, M_DEAD|M_NOPARTANI|M_OPARTSXY, OM_ANIM
;	.LONG	ANIM_FLAMER_C

*
*Damage flamer animations
*
ANIM_FLAMER_A
	LWLWW	1,1|AFunc,A_RAND_AnimSLP+2,3,6
	LWLL	1,1|AFunc,A_AnimScr+2,ANIM_FA_LOOP
ANIM_FA_LOOP
	LW	HDFLAM1,0
	LW	HDFLAM2,0
	LW	HDFLAM3,0
	LW	HDFLAM4,0
	LW	HDFLAM5,0
	LW	HDFLAM6,0
	LW	HDFLAM7,0
	.LONG	0

ANIM_FLAMER_B
	LWLWW	1,1|AFunc,A_RAND_AnimSLP+2,3,6
	LWLL	1,1|AFunc,A_AnimScr+2,ANIM_FLAMEB_LOOP
ANIM_FLAMEB_LOOP
	LW	HFIREA1,0
	LW	HFIREA2,0
	LW	HFIREA3,0
	LW	HFIREA4,0
	LW	HFIREA5,0
	LW	HFIREA6,0
	.LONG	0

;ANIM_FLAMER_C
;	LW	FIRE_A_1,4
;	LW	FIRE_A_2,4
;	LW	FIRE_A_3,4
;	LW	FIRE_A_4,4
;	LW	FIRE_A_5,4
;	LW	FIRE_A_6,4
;	LW	FIRE_A_7,4
;	LW	FIRE_A_8,4
;	LW	FIRE_A_9,4
;	LW	FIRE_A_10,4
;	.LONG	0

*
*Animations that cause the desk and Mondor to shake
*
ANIM_SMALL_SHAKE
	LWLLW	1,1|AFunc,A_SHAKE_FUNC+3,30000H,400H
	LWLLW	1,0|AFunc,A_SHAKE_FUNC+3,30000H,400H
	LWLLW	1,0|AFunc,A_SHAKE_FUNC+3,30000H,400H
	LWLLW	1,0|AFunc,A_SHAKE_FUNC+3,30000H,400H
	LWLLW	1,0|AFunc,A_SHAKE_FUNC+3,30000H,400H
	LWL	1,1|AFunc,PULL_ANIM

ANIM_MEDIUM_SHAKE
	LWLLW	1,1|AFunc,A_SHAKE_FUNC+3,30000H,400H
	LWLLW	1,0|AFunc,A_SHAKE_FUNC+3,30000H,400H
	LWLLW	1,0|AFunc,A_SHAKE_FUNC+3,30000H,400H
	LWLLW	1,0|AFunc,A_SHAKE_FUNC+3,30000H,400H
	LWLLW	1,0|AFunc,A_SHAKE_FUNC+3,30000H,400H
	LWLLW	1,0|AFunc,A_SHAKE_FUNC+3,30000H,400H
	LWLLW	1,0|AFunc,A_SHAKE_FUNC+3,30000H,400H
	LWLLW	1,0|AFunc,A_SHAKE_FUNC+3,30000H,400H
	LWL	1,1|AFunc,PULL_ANIM

ANIM_BIG_SHAKE
	LWLLW	1,1|AFunc,A_SHAKE_FUNC+3,60000H,800H
	LWLLW	1,0|AFunc,A_SHAKE_FUNC+3,60000H,800H
	LWLLW	1,0|AFunc,A_SHAKE_FUNC+3,60000H,800H
	LWLLW	1,0|AFunc,A_SHAKE_FUNC+3,60000H,800H
	LWLLW	1,0|AFunc,A_SHAKE_FUNC+3,60000H,800H
	LWLLW	1,0|AFunc,A_SHAKE_FUNC+3,60000H,800H
	LWLLW	1,0|AFunc,A_SHAKE_FUNC+3,60000H,800H
	LWLLW	1,0|AFunc,A_SHAKE_FUNC+3,60000H,800H
	LWLLW	1,0|AFunc,A_SHAKE_FUNC+3,60000H,800H
	LWLLW	1,0|AFunc,A_SHAKE_FUNC+3,60000H,800H
	LWLLW	1,0|AFunc,A_SHAKE_FUNC+3,60000H,800H
	LWLLW	1,0|AFunc,A_SHAKE_FUNC+3,60000H,800H
	LWL	1,1|AFunc,PULL_ANIM

**************************************************************************
*								         *
* 			Fragger stuff					 *
*								         *
**************************************************************************
*
*Table for random pick of multi chunks
*
NUM_METAL_CHUNKS	.EQU	4

MULTI_METAL_CHUNK_TAB
	.LONG	MONDOR_METAL_MULTI_A,MONDOR_METAL_MULTI_A,MONDOR_METAL_MULTI_A
	.LONG	MONDOR_METAL_MULTI_A

MONDOR_METAL_MULTI_A
	.long	CHUNK_METAL_A,F_CHUNK
	.word	OID_JUNK,5*800H+7*40H+FRGPAL+FRGGCOL

	.long	CHUNK_METAL_A,F_CHUNK
	.word	OID_JUNK,5*800H+16*40H+FRGPAL+FRGGCOL

	.long	CHUNK_METAL_A,F_CHUNK
	.word	OID_JUNK,5*800H+1*40H+FRGPAL+FRGGCOL

	.long	0

CHUNK_METAL_A
	LWLW	METAL_1,1|AFunc,A_INIT_AnimSLP+1,1
CHUNK_M_A_LOOP
	LW	METAL_2,0
	LW	METAL_3,0
	LW	METAL_4,0
	LW	METAL_5,0
	LW	METAL_6,0
	LWLW	METAL_7,0|AFunc,A_INC_AnimSLP+1,5
	LWLL	METAL_1,0|AFunc,A_CHUNK_ONSCREEN+2,CHUNK_M_A_LOOP
	LWL	1,1|AFunc,DELETE_OBJ


FRAG_DESK_EXPLOSION
	.long	PART_EXPLOSION,F_EXPLOSION_OUT
	.word	OID_JUNK,10*800H+5*40H+FRGPAL+FRGNOFLY
	.long	PART_EXPLOSION,F_EXPLOSION_OUT
	.word	OID_JUNK,10*800H+5*40H+FRGPAL+FRGNOFLY
	.long	PART_EXPLOSION,F_EXPLOSION_OUT
	.word	OID_JUNK,10*800H+5*40H+FRGPAL+FRGNOFLY
	.long	PART_EXPLOSION,F_EXPLOSION_OUT
	.word	OID_JUNK,10*800H+5*40H+FRGPAL+FRGNOFLY
	.long	PART_EXPLOSION,F_EXPLOSION_OUT
	.word	OID_JUNK,10*800H+5*40H+FRGPAL+FRGNOFLY
	.long	PART_EXPLOSION,F_EXPLOSION_OUT
	.word	OID_JUNK,10*800H+5*40H+FRGPAL+FRGNOFLY
FRAG_SMALL_OUT_EXP
	.long	PART_EXPLOSION,F_EXPLOSION_OUT
	.word	OID_JUNK,10*800H+15*40H+FRGPAL+FRGNOFLY
	.long	PART_EXPLOSION,F_EXPLOSION_OUT
	.word	OID_JUNK,10*800H+15*40H+FRGPAL+FRGNOFLY
	.long	PART_EXPLOSION,F_EXPLOSION_OUT
	.word	OID_JUNK,5*800H+15*40H+FRGPAL+FRGNOFLY
	.long	0


**************************************************************************
*								         *
* 	F_EXPLOSION_OUT							 *
* 									 *
* 	Frag func that makes an explosion fly at the player.		 *
* 									 *
* 	A0 = Ptr to un-inserted object.					 *
* 									 *
* 	Note: Frag funcs must preserve A8-A11 and all B-File regs.	 *
*								         *
**************************************************************************
F_EXPLOSION_OUT_2X
	ORIM	M_DBLSCL,*A0(OFLAGS),W
F_EXPLOSION_OUT
	MOVE	*A0(OZVEL),A14,L
	ABS	A14
	NEG	A14
	MOVE	A14,*A0(OZVEL),L
	RETS

FRAG_DESK_RAIN
*Pause
	.long	CHUNK_METAL_A,F_CHUNK_RAIN
	.word	OID_JUNK,3*800H+1*40H+FRGPAL+FRGGCOL

	.long	CHUNK_METAL_A,F_CHUNK_RAIN
	.word	OID_JUNK,5*800H+1*40H+FRGPAL+FRGGCOL

	.long	CHUNK_METAL_A,F_CHUNK_RAIN
	.word	OID_JUNK,3*800H+1*40H+FRGPAL+FRGGCOL

	.long	CHUNK_METAL_A,F_CHUNK_RAIN
	.word	OID_JUNK,5*800H+1*40H+FRGPAL+FRGGCOL

	.long	CHUNK_METAL_A,F_CHUNK_RAIN
	.word	OID_JUNK,3*800H+10*40H+FRGPAL+FRGGCOL

	.long	CHUNK_METAL_A,F_CHUNK_RAIN
	.word	OID_JUNK,3*800H+10*40H+FRGPAL+FRGGCOL

	.LONG	0

*
*This is the metal that gets blown on final explosion
*
FRAG_DESK_METAL
	.long	CHUNK_METAL_A,F_CHUNK
	.word	OID_JUNK,3*800H+5*40H+FRGPAL+FRGGCOL
	.long	CHUNK_METAL_A,F_CHUNK
	.word	OID_JUNK,3*800H+5*40H+FRGPAL+FRGGCOL
	.long	CHUNK_METAL_A,F_CHUNK
	.word	OID_JUNK,3*800H+5*40H+FRGPAL+FRGGCOL
	.long	CHUNK_METAL_A,F_CHUNK
	.word	OID_JUNK,3*800H+5*40H+FRGPAL+FRGGCOL
	.long	CHUNK_METAL_A,F_CHUNK
	.word	OID_JUNK,2*800H+5*40H+FRGPAL+FRGGCOL
	.long	CHUNK_METAL_A,F_CHUNK
	.word	OID_JUNK,1*800H+5*40H+FRGPAL+FRGGCOL
	.long	0

*
*Script for spark that happens when desk gets shot by a bullet
*
FRAG_SPARK
	.long	BFLASH0_ANIM,F_SPARK
	.word	OID_JUNK,1*800H+1*40H+FRGPAL+FRGNOFLY

	.LONG	0

**************************************************************************
*								         *
* F_SPARK - Frag Func for bullet spark.					 *
* A0 = Ptr to un-inserted object.					 *
* 									 *
* Note: Frag funcs must preserve A8-A11 and all B-File regs.		 *
*								         *
**************************************************************************
F_SPARK
	MOVI	-40H,A14
	MOVE	A14,*A0(OZVEL),L
       	CLRM	*A0(OYVEL),L
       	CLRM	*A0(OXVEL),L
	RETS

INIT_SPARK
	.LONG	bulit9
	.WORD	DMAWNZ, M_DEAD|M_NOPARTANI, OM_ANIM|OM_CFUNC
	.LONG	BFLASH0_ANIM
	.LONG	C_SPARK

**************************************************************************
*								         *
* 	C_SPARK								 *
* 									 *
* 	Create func for the paste on spark image			 *
* 									 *
* 	A0 = Ptr to un-inserted spark object				 *
*								         *
**************************************************************************
C_SPARK
	MMTM	SP,A0,A8
	MOVE	A0,A8
	MOVE	@RAND,A0,W
	ANDI	M_FLIPH|M_FLIPV,A0		;GET SOME RANDOM FLIP BITS
	CALLA	SET_FLIP
	MMFM	SP,A0,A8
	RETS

	.END
