 	.MLIB	"GXMACS.LIB"
 	.FILE	"GXUNIJAP.ASM"
	.TITLE	" <<< GENERATION X -- JAPAN UNIVERSE >>>"
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
	.INCLUDE	"IMGTBL.GLO"
	.include	"UNIVTBL.GLO"
	.INCLUDE	"GXSCRL.H"
	.INCLUDE	"GXUNIJAP.TBL"
	.INCLUDE	"GXNONBOY.H"
	.INCLUDE	"GXNATV.H"

***** Symbols in this file

	.DEF	JAP_OFFICE_SCROLL, JAP_OFFICE_VECT_TABLE, JAP_FACTORY_VECT_TABLE
	.DEF	JAP_FACTORY_SCROLL, JAP_OUTSIDE_SCROLL, JAP_OUTSIDE_VECT_TABLE
	.DEF	DEAD_GUNVECT, FIND_MY_MATCH, NO_CHARITY, BRICK_GRY_GUNVECT
	.DEF	AU_CREATE_REDBACK, FAC_DOORS_OPEN, FAC_DOORS_ALLOWED
	.DEF	JAP_RnD_TEST_SCROLL,DGV_FRAG_DUST_BRN,DGV_FRAG_DUST_GRY
	.DEF	OFFICE_DAMAGE_FLAG, SND_CHEST_HIT, SND_CHEST_EXPLODE
	.DEF	ATTRACT3, SIGN_CVECT, SIGN_GUNVECT

***** from GXRAM.ASM
	.REF	GUNS_OFF, WAVE_IPLANE, OBJENEMIES, POWERUP_DURATION
	.REF	HOLD_ENEMY_DISPATCH, LAB_RAT

***** from GXD.ASM
	.REF	WORLD_GRNDOFF

***** from GXAFUNC.ASM
	.REF	SetAnim_AFARG, A_RAND_REL_BYTE, A_AnimFrm_DSJ
	.REF	A_DELETE_ZBOT

***** from GXDESK.ASM
	.REF	DESK_PROC, DESK_XFORM_FLAG, DGV_FRAG_SPARK
	.REF	JOSH_SIT_FLAG, F_EXPLOSION_OUT, F_EXPLOSION_OUT_2X

***** from GXMONDOR.ASM
	.REF	MONDOR_MORPH_FLAG

***** from GXMONDR2.ASM
	.REF	PART_EXPLOSION

***** from GXLA1.ASM
	.REF	WC_MAKE_GLASS, PALMTREETOP_COLLVECTR, PALMTREETOP_GUNVECT

***** from GXLA2.ASM
	.REF	DLAMP_COLLVECT, DLAMP_GUNVECT

***** from GXPOWER.ASM
	.REF	REVEAL_LAZER2, REVEAL_SHIELD2, REVEAL_SUPERGUN2, REVEAL_CD2
	.REF	REVEAL_LIFE2
	.REF	REVEAL_LAZER, REVEAL_SHIELD, REVEAL_SUPERGUN, REVEAL_CD
	.REF	REVEAL_LIFE

***** from GXUNIJP2.ASM
	.REF	S_ADJUST_YHALF, S_ADJUST_YWORLD, METAL_GUNVECT
	.REF	JAP_BOXA_SCROLL, JAP_WARE_VECT_TABLE
	.REF	ENT_CRATE_CVECT, ENT_CRATE_GUNVECT
	.REF	ALIGHT_CVECT, ALIGHT_GUNVECT
	.REF	MARS_CVECT, MARS_GUNVECT, SND_METAL_HIT
	.REF	WARE_CRATE_CVECT, CRATE_GUNVECT, SND_GATE_EXPLODE

***** from GXENEMY.ASM
	.REF	PROC_SND

***** from GXJUNGLE.ASM
	.REF	VIDCAM_CVECT, VIDCAM_GUNVECT, VIDCAM_Z, VIDCAM_HOLDTIME
	.REF	PLYR_SEEN, BRK_ANIM_1, BRK_ANIM_2, JXLIMIT

***** from GXBEEK2.ASM
	.REF	IN_SECRET

***** from GXWAVE.ASM
	.REF	DSP_FACT_TOP, WAVE1END

***** from GXYJAK.ASM
	.REF	PROC_DESK_YJAK, CREATE_YJAK

***** from GXUNIV1.ASM
	.REF	FRAG_DUST_CLOUD_ANIM, F_UFRAG_STUFF_X2, F_UFRAG_STUFF, FRAG_UANIM

***** from GXSCROLL.ASM
	.REF	S_DELETE_ENEMY_OID

***** from GXNINJA.ASM
	.REF	PROC_STONED_NINJA, PROC_NINJA_JUMPIN

***** from GXUTIL.ASM
	.REF	PreFrag_Box_Offset


*
*RAMma jamma japanese mother fucker!
*
	.BSS	OFFICE_DAMAGE_FLAG,16		;Flag to allow office damage
	.BSS	NO_CHARITY,16			;Charity allowed?

	.BSS	POWERUP_SAVE,16			;Save area for POWERUP_DURATION
	.BSS	FAC_DOORS_OPEN,16		;Number of FACTORY doors open
	.BSS	FAC_DOORS_ALLOWED,16		;Number allowed open at a time
	.BSS	KTI_BUSTIN,16

;	.BSS	UNUSED_WORD,16

**************************************************************************
*								         *
* 	Special routines for the Japan universe				 *
*								         *
**************************************************************************
	.text
	

**************************************************************************
*								         *
* 	CLOUDx_PROC							 *
* 									 *
* 	Process to start the clouds in the far distance scrolling by.	 *
*								         *
**************************************************************************
CLOUD1_PROC
	MOVI	(OID_UNIV|ID_28)&~MASK_SUPP,A0	;This is Cloud 1's I.D. in the universe
	MOVI	4000H,A10
	JRUC	CLOUD_FINDER

CLOUD2_PROC
	MOVI	(OID_UNIV|ID_29)&~MASK_SUPP,A0	;This is Cloud 2's I.D. in the universe
	MOVI	2000H,A10
	JRUC	CLOUD_FINDER

*
*Entrypoint: To find a cloud of given I.D. and start it along it's path
*	A0 = I.D. to find
*	A10 = Minimum XVEL
*	A11 = Maximum XVEL
*
CLOUD_FINDER
	MOVE	A0,B6
	MOVI	~MASK_SUPP,A1
;	CALLA	EXIST_OBJ_ALL		;Did we find one
	CALLA	EXIST_OBJ		;Did we find one
	JAZ	SUCIDE			;BR = No, just die
CF_LOOP
	CALLA	BG_TO_FG		;Get Cloud out of Bgnd

	MOVE	A10,*A8(OXVEL),L

	MOVI	ANIM_CLOUD,A1	
	CALLA	STRT_ANIM		;Start the cloud watch

	MOVE	B6,A0
	MOVI	~MASK_SUPP,A1
;	CALLA	RESUME_EXIST_OBJ_ALL	;Did we find another
	CALLA	RESUME_EXIST_OBJ	;Did we find another
	MOVE	A0,A8
	JRNZ	CF_LOOP			;BR = Yes, do the same to it

	DIE


*
*Watch for cloud to go offscreen and then wrap it around
*
ANIM_CLOUD
	LW	1,10
	LWL	1,1|AFunc,A_CLOUD_CK
	.LONG	0


**************************************************************************
*								         *
* 	A_CLOUD_CK							 *
* 									 *
* 	Anim func to check cloud.  If it is offscreen, then 		 *
* 	wrap.								 *
* 									 *
* 	A8 = Ptr to cloud						 *
*								         *
**************************************************************************
A_CLOUD_CK
	CALLA	GET_ANIP_SCRNREL
	MOVE	A1,A14
	SEXT	A14
	CMPI	450,A14		;Are we off the right edge?
	JRLT	ACC_X		;BR = Not yet

	MOVIX	-50,A1	    	;Re-adjust to the left edge.
	JAUC	SET_SCRN_POS

ACC_X
	RETS


**************************************************************************
*								         *
* 			Japan Scroll funcs				 *
*								         *
**************************************************************************

**************************************************************************
*								         *
* 	S_KILL_INFINITY							 *
* 									 *
* 	Kill the infinity plane(s) and all of their current objects.	 *
*								         *
**************************************************************************
S_KILL_INFINITY
	calla	KILL_ALL_BG		; Kill objects
	calla	KillBgnd		; Kill procs
	JAUC	SCRL_DISPATCHER

**************************************************************************
*								         *
* 	S_MOVE_WORD_ABS							 *
* 									 *
* 	Move word long contents from absolute to absolute		 *
* 									 *
* 	*A11+,L	= Source						 *
* 	*A11+,L	= Destination						 *
*								         *
**************************************************************************
S_MOVE_WORD_ABS
	MOVE	*A11+,A1,L
	MOVE	*A11+,A2,L
	MOVE	*A1,*A2,W
	JAUC	SCRL_DISPATCHER

**************************************************************************
*								         *
* JAPAN WAVE SCROLL TABLES						 *
*								         *
**************************************************************************
ATTRACT3
	.LONG	S_SET_LONG, WXBUFFER, 0380000H		;Open univ block buffer
	.LONG	S_SET_LONG, WYBUFFER, 0540000H
	.LONG	S_SET_LONG, XBASE,    0BD0000H

	LLW	S_SET_WORD, UNIVERR, 1		;Force universe update

	LLW	S_SET_WORD,OBJENEMIES,0		;Keep enemy gens quiet

	.LONG	S_SET_LONG, UEP_Z, 10F00H	;Set enemy gen distance

	.LONG	S_LOCKOUT_PORTALS

	LW	S_WAIT_HERE,60

	.LONG	JAKE_JAP+M_JUMP

JAP_OUTSIDE_SCROLL
	.LONG	S_SET_LONG, WXBUFFER, 0380000H		;Open univ block buffer
	.LONG	S_SET_LONG, WYBUFFER, 0540000H

	LW	S_AUDIT, AUDJAPAN

	LLW	S_SET_WORD, UNIVERR, 1		;Force universe update

	LLW	S_SET_WORD,OBJENEMIES,0		;Keep enemy gens quiet

	.LONG	S_SET_LONG, UEP_Z, 10F00H	;Set enemy gen distance

	.LONG	S_LOCKOUT_PORTALS

	LW	S_WAIT_HERE,60

	LWL	S_X_ACCEL_LIMIT,1000H,10000H	;Move over to the ent

	LLLW	S_WAIT_FOR_COORD,XBASE,0A80000H,1 ;Scroll to entrance aisle

JAKE_JAP
	.LONG	S_DOZER_ACCEL			;Round corner and go down entrance
	.WORD	60 << 8 + M_X << 3 + M_Z  + M_X + M_ZREL
	.LONG	0BD0000H				;X Position target
	.LONG	0				;X Velocity target
	.LONG	0A0H << ZFRAC			;Z Velocity target

	LLW	S_SET_WORD,OBJENEMIES,M_BW	;Activate enemy gens

	LLW	S_WAIT_FOR_ZREL,09000H,1

	LLW	S_SET_WORD,OBJENEMIES,0		;Keep enemy gens quiet

	LLW	S_SET_WORD,KTI_BUSTIN,0		;O.K. You can bust in

	LW	S_DECEL_TO_STOP,5

	LW	S_WAIT_HERE,1+M_CLEANUP

	LWL	S_Z_ACCEL_LIMIT,-30H,-280H ;Backup and 

	.LONG	S_LEAVE_UNIV			; Set up and enter new universe
	.word	50
	.long	GXKTEN1			; name of universe
	.long	-025801h,-0FB0000h,00h	; Z, X, Y offsets
	.WORD	0

JO_ENTER
	LWL	S_Z_ACCEL_LIMIT,30H,400H ;Head for check point

	.LONG	S_CREATE_PROCR			;Start the damage color stuff
	.WORD	PID_DAMCC
	.LONG	9,29,31,HMILL1p,CYCLE16		;LEDs on computer and desk
	.WORD	PID_DAMCC
	.LONG	3,24,30,JDESKd2,CYCLE16		;Damage on computer and desk
	.WORD	0

	.LONG	S_SET_LONG, VIDCAM_Z, 10000H		;Set vidcam activation Z

	LLW	S_SET_WORD, VIDCAM_HOLDTIME, 15		;Set vidcam delay

	LLW	S_SET_WORD, PLYR_SEEN, 0		;Set vidcam spot flag

	LLW	S_SET_WORD,KTI_BUSTIN,0		;O.K. You can bust in again

	LLW	S_WAIT_FOR_Z,016E00H,1

	LW	S_DECEL_TO_STOP,4

	LLW	S_SET_WORD,OBJENEMIES,M_OF_DNINJA	;Activate Ninja

	LW	S_WAIT_HERE,60

	LLW	S_SET_WORD,OBJENEMIES,M_POPTOP	;Activate behind desk guys

	LW	S_WAIT_HERE,80

	LWL	S_X_ACCEL_LIMIT,1000H,10000H	;Move over to the ent

	LLLW	S_WAIT_FOR_COORD,XBASE,-10000H,1 ;Scroll to entrance aisle

	.LONG	S_DOZER_ACCEL			;Round corner and go down entrance
	.WORD	60 << 8 + M_X << 3 + M_Z  + M_X + M_ZREL
	.LONG	-60000H				;X Position target
	.LONG	0				;X Velocity target
	.LONG	0A0H << ZFRAC			;Z Velocity target

	LLW	S_OR_WORD,OBJENEMIES,M_BW|M_OF_WNINJA	;Activate Step out dudes

	LLW	S_WAIT_FOR_Z,036000H,1

	LLW	S_SET_WORD,OBJENEMIES,0		;Keep enemy gens quiet

	LW	S_DECEL_TO_STOP,5

	LW	S_WAIT_HERE,1+M_CLEANUP

	LWL	S_Z_ACCEL_LIMIT,-30H,-300H ;Backup and 

	.LONG	S_SET_VECTOR_TABLE, JAP_WARE_VECT_TABLE

	.LONG	S_LEAVE_UNIV		; Set up and enter new universe
	.word	50
	.long	GXJAPFUN		; name of universe
	.long	-41F0H,0A61000h,00h	; Z, X, Y offsets
	.WORD	0

JO_WARE_ENTER
	.LONG	S_CHANGE_ZFAR,10F00H	;Set the correct ZFAR

	LWL	S_Z_ACCEL_LIMIT,30H,400H ;Head for check point

	LLW	S_WAIT_FOR_Z,3C000H,1

	LW	S_DECEL_TO_STOP,4

	LW	S_KILL_ALL_PROCS,PID_DAMCC	;Kill cyclers

	.LONG	JAP_BOXA_SCROLL + M_JUMP

*
* Jump here when sitting a dock entrance and you want to go in
*
DOCK_ENT_JUMP
	.LONG	S_LEAVE_UNIV			; Set up and enter new universe
	.word	2
	.long	GXKTEN1			; name of universe
	.long	-024000h,-0FB0000h,00h	; Z, X, Y offsets
	.WORD	0

	LW	S_WAIT_HERE,4

	LW	S_DELETE_ENEMY_OID,OID_NONBOY

	LLW	S_SET_WORD,HOLD_ENEMY_DISPATCH,0 ;O.K. You can dispatch

       	.LONG	JO_ENTER+M_JUMP

*
* Jump here when sitting a warehouse entrance and you want to go in
*
WARE_ENT_JUMP
	.LONG	S_SET_VECTOR_TABLE, JAP_WARE_VECT_TABLE

	.LONG	S_LEAVE_UNIV		; Set up and enter new universe
	.word	2
	.long	GXJAPFUN		; name of universe
	.long	-41F0H,0A61000h,00h	; Z, X, Y offsets
	.WORD	0

	LW	S_WAIT_HERE,4

	LW	S_DELETE_ENEMY_OID,OID_NONBOY

	LW	S_DELETE_ENEMY_OID,OID_NINJA

	LLW	S_SET_WORD,HOLD_ENEMY_DISPATCH,0 ;O.K. You can dispatch

	.LONG	JO_WARE_ENTER+M_JUMP

**************************************************************************
*								         *
* 	METBRIK1_GUNVECT						 *
* 									 *
* 	Gunvector for vertical brick piece with metal edge.		 *
* 									 *
* 	A2 = Ptr to player shooting					 *
* 	A8 = Ptr to object						 *
*								         *
**************************************************************************
METBRIK1_GUNVECT
	MOVI	[-172, -38],A3
	MOVI	[0, -22],A4
	JRUC	MB_GV

**************************************************************************
*								         *
* 	METBRIK2_GUNVECT						 *
* 									 *
* 	Gunvector for horizontal brick piece with metal edge.		 *
* 									 *
* 	A2 = Ptr to player shooting					 *
* 	A8 = Ptr to object						 *
*								         *
**************************************************************************
METBRIK2_GUNVECT
	MOVI	[-14, -44],A3
	MOVI	[0, 46],A4

*
* Entrypoint: Does metal/brick check
*  A3 = UL offset of metal area
*  A4 = LR offset of metal area
*
MB_GV
	CALLA	BOX_CHECK_OBJ
	JANZ	METAL_GUNVECT			;BR = We hit metal
	JAUC	BRICK_GRY_GUNVECT			;No brick


*
* Lab desk collision
*
CDESK_CVECT
	WWL	OID_PROCKET,~MASK_PLAYER,UNIV_ROCKET_COLL
	WWL	OID_PEXPLOSION,~MASK_PLAYER,CDESK_EXPLOSION_CVECT
	WL	0,DUMCRETS

**************************************************************************
*								         *
* 	CDESK_EXPLOSION_CVECT						 *
* 									 *
* 	Collision service vector for the computer desk.			 *
* 									 *
* 	A0 = Ptr to explosion object					 *
* 	A8 = Ptr to Desk						 *
*								         *
**************************************************************************
CDESK_EXPLOSION_CVECT
	CALLA	UNIV_COLL_CHECK			;See if this was a valid collision
	JRNZ	MONITOR_DONE			;BR = No
	CLRM	*A8(OBOOTY_FUNC),L		;Give up da loot
	JRUC	FINISH_COMP_DESK

**************************************************************************
*								         *
* 	MONITOR_GUNVECT							 *
* 									 *
* 	Gun vector for the Lab desk monitor.				 *
* 									 *
* 	A2 = Ptr to player shooting					 *
* 	A8 = Ptr to chest						 *
*								         *
**************************************************************************
MONITOR_GUNVECT
	MOVIM	MONITOR_BOOTY,*A8(OBOOTY_FUNC),L
	MOVI	500,A5				;Points for killing this
	MOVK	M_FLASHOBJ,A7			;Flash if we hit it
	CLR	A9				;Offset for printed score
	CALLA	UNIV_DAMAGE_HANDLER		;Call the handler
	JRC	MONITOR_EXPLODE			;BR = Time to destroy

MONITOR_DEAD
	SOUNDZ	SND_CHEST_HIT			;Give a little sound to ack
	JAUC	DGV_FRAG_SPARK

	RETS

*
* Lab desk monitor collision
*
MONITOR_CVECT
	WWL	OID_PROCKET,~MASK_PLAYER,UNIV_ROCKET_COLL
	WWL	OID_PEXPLOSION,~MASK_PLAYER,MONITOR_EXPLOSION_CVECT
	WL	0,DUMCRETS

**************************************************************************
*								         *
* 	MONITOR_EXPLOSION_CVECT						 *
* 									 *
* 	Collision service vector for the desk monitor.			 *
* 									 *
* 	A0 = Ptr to explosion object					 *
* 	A8 = Ptr to Crate						 *
*								         *
**************************************************************************
MONITOR_EXPLOSION_CVECT
	CALLA	UNIV_COLL_CHECK			;See if this was a valid collision
	JRNZ	MONITOR_DONE			;BR = No
	MOVIM	MONITOR_BOOTY,*A8(OBOOTY_FUNC),L		;Give up da loot
	
FINISH_COMP_DESK
	MOVE	*A0(OID),A0,W
	CALLA	POID_TO_PDATA			;Get player's data area

	MOVI	500,A5				;Points for killing this thing
	MOVI	M_LASTFRM|M_FLASHOBJ|M_NOSTOPANIM,A7 ;Last frame and flash
	CLR	A9				;Offset for printed score
	CALLA	UNIV_DAMAGE_HANDLER		;Do the patented damage shit
	JRNC	MONITOR_DEAD			;BR = Damage already done
*
*Here we explode the Monitor/Desk
*A8 = Ptr to Monitor/Desk
*
MONITOR_EXPLODE
	CALLA	UNIV_DISAB_ENEMY_GEN

	SOUNDZ	SND_CHEST_EXPLODE

	SOUND1	SND_MONITOR_FIZZ

	MOVIM	DEAD_GUNVECT,*A8(OGUNVECT),L
	MOVIM	DUMCOLL,*A8(OCVECT),L

	MOVE	A2,*A8(OPLAYER),L		;Keep the player ptr

	MMTM	SP,B1,B2,B4,B5,B6,B8,B9,B10	;MAKE FRAGMENTS

	MOVI	040000H,A0
	CLR	A3
	CALLA	PreFrag_Box
	MOVI	-0FFH,B9			;MIN Z VEL
	MOVI	-10H,B10			;MAX Z VEL
	MOVI	FRAG_U10_MIX,B14		;Use this fragment script
	CALLA	Fragger

;	MOVI	HMILL1p,A14
;	MOVE	A14,*A0(FPDATA),L		;Set Palette

	MOVE	*A8(OIMG),A1,L
	MOVE	*A1(ICMAP),*A0(FPDATA),L	;SET PALETTE

	MMFM	SP,B1,B2,B4,B5,B6,B8,B9,B10

	MOVE	*A8(OBOOTY_FUNC),A14,L
	JRZ	MONITOR_DONE			;BR = Give no loot

	CALL	A14
	
MONITOR_DONE
	RETS


**************************************************************************
*								         *
* 	MONITOR_BOOTY							 *
* 									 *
* 	Create the loot for the lab monitor.				 *
* 									 *
* 	A8 = Ptr to monitor object					 *
*								         *
**************************************************************************
MONITOR_BOOTY
	MMTM	SP,A0,A1,A7,A10,A11

	MOVI	512,A0	
	CALLA	RANDPER
	JRNC	MB_DONE

	MOVI	[-58,4],A10			; screen Y,X offset
	MOVK	8,A11

	CREATE	PID_IND, REVEAL_CD

MB_DONE
	MMFM	SP,A0,A1,A7,A10,A11
	RETS

*
* Lab disk drive collision
*
DISK_CVECT
	WWL	OID_PROCKET,~MASK_PLAYER,UNIV_ROCKET_COLL
	WWL	OID_PEXPLOSION,~MASK_PLAYER,DISK_EXPLOSION_CVECT
	WL	0,DUMCRETS

**************************************************************************
*								         *
* 	DISK_EXPLOSION_CVECT						 *
* 									 *
* 	Collision service vector for the disk drive.			 *
* 									 *
* 	A0 = Ptr to explosion object					 *
* 	A8 = Ptr to disk						 *
*								         *
**************************************************************************
DISK_EXPLOSION_CVECT
	CALLA	UNIV_COLL_CHECK			;See if this was a valid collision
	JRNZ	MONITOR_DONE			;BR = No
	MOVIM	DISK_BOOTY,*A8(OBOOTY_FUNC),L		;Give up da loot
	JRUC	FINISH_COMP_DESK

**************************************************************************
*								         *
* 	DISK_BOOTY							 *
* 									 *
* 	Create the loot for the lab disk drive.				 *
* 									 *
* 	A8 = Ptr to disk object						 *
*								         *
**************************************************************************
DISK_BOOTY
	MMTM	SP,A0,A1,A7,A9,A10,A11

	MOVI	512,A0	
	CALLA	RANDPER
	JRNC	DB_DONE

	MOVI	(2 << 16) + ((-64 << 8) & 0FF00H) + 0,A9  ;Z, Y, X OFFSET
	MOVI	[-010H,-0100H],A10		;[MAX, MIN] Z VELOCITY
	MOVI	[-060H,010H],A11		;[Y, X] VELOCITY LIMITS
	MOVI	PID_IND,A1
	MOVI	THROW_PROCK,A7

	CALLA	GETPRC
	CALLA	GETPRC
	CALLA	GETPRC
	CALLA	GETPRC

DB_DONE
	MMFM	SP,A0,A1,A7,A9,A10,A11
	RETS

**************************************************************************
*								         *
* 	SIGN_NOFLASH_GUNVECT						 *
* 									 *
* 	Gun vector for any kind of signage.				 *
* 									 *
* 	A2 = Ptr to player shooting					 *
* 	A8 = Ptr to sign						 *
*								         *
**************************************************************************
SIGN_NOFLASH_GUNVECT
	CLR	A7			;Flags for damage handler
	JRUC	SIGN_GUN_G

**************************************************************************
*								         *
* 	SIGN_GUNVECT							 *
* 									 *
* 	Gun vector for any kind of signage.				 *
* 									 *
* 	A2 = Ptr to player shooting					 *
* 	A8 = Ptr to sign						 *
*								         *
**************************************************************************
SIGN_GUNVECT
	MOVK	M_FLASHOBJ,A7			;Flash if we hit it
SIGN_GUN_G
	MOVI	500,A5				;Points for killing this
	CLR	A9				;Offset for printed score
	CALLA	UNIV_DAMAGE_HANDLER		;Call the handler
	JRC	SIGN_EXPLODE			;BR = Time to destroy
SIGN_DEAD
	JAUC	METAL_GUNVECT			;BR = Do patented metal stuff

*
* Generic signage collision vector
*
SIGN_CVECT
	WWL	OID_PROCKET,~MASK_PLAYER,UNIV_ROCKET_COLL
	WWL	OID_PEXPLOSION,~MASK_PLAYER,SIGN_EXPLOSION_CVECT
	WL	0,DUMCRETS

**************************************************************************
*								         *
* 	SIGN_EXPLOSION_CVECT						 *
* 									 *
* 	Collision service vector for any signage.			 *
* 									 *
* 	A0 = Ptr to explosion object					 *
* 	A8 = Ptr to sign						 *
*								         *
**************************************************************************
SIGN_EXPLOSION_CVECT
	CALLA	UNIV_COLL_CHECK			;See if this was a valid collision
	JRNZ	SIGN_DONE			;BR = No

	MOVE	*A0(OID),A0,W
	CALLA	POID_TO_PDATA			;Get player's data area

	MOVI	500,A5				;Points for killing this thing
	MOVI	M_LASTFRM|M_FLASHOBJ,A7		;Last frame and flash
	CLR	A9				;Offset for printed score
	CALLA	UNIV_DAMAGE_HANDLER		;Do the patented damage shit
	JRNC	SIGN_DEAD			;BR = Damage already done
*
*Here we explode the Signage
*A8 = Ptr to signage
*
SIGN_EXPLODE
	SOUNDZ	SND_CHEST_EXPLODE

	MOVIM	METAL_GUNVECT,*A8(OGUNVECT),L
	MOVIM	DUMCOLL,*A8(OCVECT),L

	MMTM	SP,B1,B2,B4,B5,B6,B8,B9,B10	;MAKE FRAGMENTS

	MOVI	040000H,A0
	CLR	A3
	CALLA	PreFrag_Box
	MOVI	-0FFH,B9			;MIN Z VEL
	MOVI	-10H,B10			;MAX Z VEL
	MOVI	FRAG_U10_MIX,B14		;Use this fragment script
	CALLA	Fragger

	MOVE	*A8(OIMG),A1,L
	MOVE	*A1(ICMAP),*A0(FPDATA),L	;SET PALETTE

	MMFM	SP,B1,B2,B4,B5,B6,B8,B9,B10

SIGN_DONE
	RETS

**************************************************************************
*								         *
* 	VENTBRIK_GUNVECT						 *
* 									 *
* 	Gunvector for vertical brick piece with green vents.		 *
* 									 *
* 	A2 = Ptr to player shooting					 *
* 	A8 = Ptr to object						 *
*								         *
**************************************************************************
VENTBRIK_GUNVECT
	MOVI	[-202, -26],A3
	MOVI	[-124, 60],A4
	CALLA	BOX_CHECK_OBJ
	JRNZ	VENT_GRN_GUNVECT	;BR = Hit vent part
	MOVI	[-76, -26],A3
	MOVI	[0, 60],A4
	CALLA	BOX_CHECK_OBJ
	JRNZ	VENT_GRN_GUNVECT	;BR = Hit vent part
	MOVI	[-120, -26],A3
	MOVI	[-78, -2],A4
	CALLA	BOX_CHECK_OBJ
	JRNZ	VENT_GRN_GUNVECT	;BR = Hit vent part
	JRUC	BRICK_GRY_GUNVECT


*
* Vent collsion table
*
VENT_CVECT
	WWL	OID_PROCKET,~MASK_PLAYER,UNIV_ROCKET_COLL
	WWL	OID_PEXPLOSION,~MASK_PLAYER,VENT_EXPLOSION_CVECT
	WL	0,DUMCRETS

**************************************************************************
*								         *
* 	VENT_EXPLOSION_CVECT			   			 *
* 									 *
* 	Collision service vector for the vent piece.			 *
* 									 *
* 	A0 = Ptr to explosion object					 *
* 	A8 = Ptr to Crate						 *
*								         *
**************************************************************************
VENT_EXPLOSION_CVECT
	CALLA	UNIV_COLL_CHECK			;See if this was a valid collision
	JRNZ	VENT_DONE			;BR = No

	MOVE	*A0(OID),A0,W
	CALLA	POID_TO_PDATA			;Get player's data area

	MOVI	500,A5				;Points for killing this thing
	MOVI	M_LASTFRM|M_FLASHOBJ|M_NOSTOPANIM,A7 ;Last frame and flash
	CLR	A9				;Offset for printed score
	CALLA	UNIV_DAMAGE_HANDLER		;Do the patented damage shit
	JRNC	VENT_DONE			;BR = Damage already done
*
*Here we explode the vent piece
*A8 = Ptr to vent
*
VENT_EXPLODE
	CALLA	UNIV_DISAB_ENEMY_GEN

	SOUND1	SND_WALL_EXPLODE

	MOVIM	VENT_GRN_GUNVECT,*A8(OGUNVECT),L
	MOVIM	DUMCOLL,*A8(OCVECT),L

	MOVE	@RAND,A14
	BTST	7,A14
	JRNZ	VEC_DO_FRAG

	MOVK	3,A0
	CALLA	RAND0
	SLL	5,A0
	ADDI	TAB_VENT_REVEAL,A0
	MOVE	*A0,A0,L
	CALL	A0

VEC_DO_FRAG
	MMTM	SP,B1,B2,B4,B5,B6,B8,B9,B10	;MAKE FRAGMENTS

	MOVI	040000H,A0
	CLR	A3
	CALLA	PreFrag_Box
	MOVI	-0FFH,B9			;MIN Z VEL
	MOVI	-10H,B10			;MAX Z VEL
	MOVI	FRAG_VENT_EXPLODE,B14		;Use this fragment script
	CALLA	Fragger

	MOVIM	P_RUBGRN,*A0(FPDATA),L
	MOVE	A8,*A0(FPOBJ),L			;Pass the object

	MMFM	SP,B1,B2,B4,B5,B6,B8,B9,B10

VENT_DONE
	RETS

*
* Table of Vent powerup reveals
*
TAB_VENT_REVEAL
	.LONG	VENT_REVEAL_2, VENT_REVEAL_BOT, VENT_REVEAL_TOP

*
* Reveal 2 small CDs in the blown vent structure
*
VENT_REVEAL_2
	MMTM	SP,A0,A1,A7,A10,A11
	MOVI	[-42,32],A10			; screen Y,X offset
	MOVK	8,A11
	CREATE	PID_IND,REVEAL_PROCK
	MOVI	[-162,32],A10			; screen Y,X offset
	MOVK	8,A11
	CREATE	PID_IND,REVEAL_PROCK
	MMFM	SP,A0,A1,A7,A10,A11
	RETS
	
*
* Reveal 1 big CD in the bottom part of the blown vent structure
*
VENT_REVEAL_BOT
	MMTM	SP,A0,A1,A7,A10,A11
	MOVI	[-42,32],A10			; screen Y,X offset
	MOVK	8,A11
	CREATE	PID_IND,REVEAL_CD
	MMFM	SP,A0,A1,A7,A10,A11
	RETS
*
* Reveal 1 big CD in the top part of the blown vent structure
*
VENT_REVEAL_TOP
	MMTM	SP,A0,A1,A7,A10,A11
	MOVI	[-162,32],A10			; screen Y,X offset
	MOVK	8,A11
	CREATE	PID_IND,REVEAL_CD
	MMFM	SP,A0,A1,A7,A10,A11
	RETS
*
* Entrance doors from dock
*
KTIDOOR1_CVECT
	WWL	OID_PROCKET,~MASK_PLAYER,UNIV_ROCKET_COLL
	WWL	OID_PEXPLOSION,~MASK_PLAYER,KTIDOOR1_EXP_CVECT
	WL	0,DUMCRETS

*
* Doors that lead to crate section
*
KTIDOOR2_CVECT
	WWL	OID_PROCKET,~MASK_PLAYER,UNIV_ROCKET_COLL
	WWL	OID_PEXPLOSION,~MASK_PLAYER,KTIDOOR2_EXP_CVECT
	WL	0,DUMCRETS

**************************************************************************
*								         *
* 	KTIDOOR1_EXP_CVECT						 *
* 									 *
* 	Collision vector service for KTI entrance doors from dock.	 *
* 									 *
* 	A0 = Ptr to explosion						 *
* 	A8 = Ptr to door						 *
*								         *
**************************************************************************
KTIDOOR1_EXP_CVECT
	MOVI	DOCK_ENT_JUMP,A6
	JRUC	KTIDOOR_EXP

**************************************************************************
*								         *
* 	KTIDOOR2_EXP_CVECT						 *
* 									 *
* 	Collision vector service for KTI entrance doors to Warehouse.	 *
* 									 *
* 	A0 = Ptr to explosion						 *
* 	A8 = Ptr to door						 *
*								         *
**************************************************************************
KTIDOOR2_EXP_CVECT
	MOVI	WARE_ENT_JUMP,A6
	JRUC	KTIDOOR_EXP

*
* Entrypoint:
*	A0 = Ptr to explosion
*	A6 = Ptr to scroll jump vector
*	A8 = Ptr to Door
*
KTIDOOR_EXP
	CALLA	UNIV_COLL_CHECK		;See if this was a valid collision
	JRNZ	KDE_X			;BR = No

	MOVE	@KTI_BUSTIN,A14,W
	JRNZ	KDE_X			;BR = Bust in already under way

	MOVE	*A8(OZVAL),A1,L
	MOVE	@ZBASE,A14,L
	SUB	A14,A1

	CMPI	9000H,A1
	JRGT	KDE_X			;BR = Way far away

	MOVE	@ZSCROLL,A14,L
	JRNZ	KDE_X			;We are currently moving in Z
	
	MOVE	A6,A0
	CALLA	CHNG_SCRL_TBL		;Change the direction of scroll	

	MOVKM	1,@KTI_BUSTIN,W

	SOUND1	SND_DOOR_BONK		;Hit that door baby

KDE_X
	RETS

**************************************************************************
*								         *
* 			Factory proper scroll				 *
*								         *
**************************************************************************
JAP_FACTORY_SCROLL
**	This is where we come through the portal

	.LONG	S_SET_LONG, WXBUFFER, 0380000H		;Open univ block buffer
	.LONG	S_SET_LONG, WYBUFFER, 0540000H

	LW	S_AUDIT, AUDJAFAC

	.LONG	S_MOVE_WORD_ABS, POWERUP_DURATION, POWERUP_SAVE

	LLW	S_SET_WORD, POWERUP_DURATION, 3*60

	LLW	S_SET_WORD, FAC_DOORS_OPEN, 0

	LLW	S_SET_WORD, FAC_DOORS_ALLOWED, 6

	LLW	S_SET_WORD, IN_SECRET, 0

	.LONG	S_LOCKOUT_PORTALS

	LW	S_KILL_ALL_PROCS,PID_DAMCC

	LW	S_WAIT_HERE,60

	.LONG	S_SET_LONG, UEP_Z, 1C800H		;Set enemy gen

;	LWL	S_CREATE_PROC,PID_IND,PROC_ELEV		;Set up the elevator frame

	LWL	S_Y_ACCEL_LIMIT,800H,8000H

	LLW	S_SET_WORD,OBJENEMIES,M_POPTOP|M_OF_BCOG|M_OF_WNINJA ;Activate enemy gens

	.LONG	S_SET_LONG, YSACCEL, 18H		;Slowly speed up

	LLLW	S_WAIT_FOR_COORD,YBASE,0A000000H,1	;Just turn'em off

	.LONG	S_CREATE_PROCR
	.WORD	PID_IND
	.LONG	0F7E5H,-0AB70000H,-0A30000H,M_FLIPH,PROC_STONED_NINJA
	.WORD	PID_IND
	.LONG	0F7E5H,-0AB70000H,0CC0000H,0,PROC_STONED_NINJA
	.WORD	0

	.LONG	S_SET_LONG, UEP_Z, 0H			;Get a handle on enemy

	LLLW	S_WAIT_FOR_COORD,YBASE,0AA80000H,1	;Stop at the top

	LW	S_DECEL_TO_STOP,4

	.LONG	S_KILL_INFINITY

	LLW	S_SET_WORD,OBJENEMIES,M_POPTOP		;Activate enemy gens

	.LONG	S_SET_LONG, UEP_Z, 2F000H		;Set enemy gen

	.LONG	S_SET_LONG, WORLD_GRNDOFF, -0A980000H

	LLW	S_DISPATCH_HERE, DSP_FACT_TOP+M_WAIT,5	;Set quota for top

	LW	S_WAIT_HERE, 1+M_QUOTA

;	LWWWLW	S_ACCEL_TO_POINT,-160,16H,0AACH,6000H,0	;Line Ninja doors

	LWL	S_Z_ACCEL_LIMIT,80H,0200h		;Get through door

	LLW	S_WAIT_FOR_ZREL,6000H,1

	LW	S_DECEL_TO_STOP,5

	LWWWLW	S_GOTO_POINT,-25,16H,0AACH,9B7DH,0	;Pull back so we are lined up

	.LONG	S_STOP_SCROLL

;	LW	S_DECEL_TO_STOP,5

	.LONG	S_SET_LONG, WORLD_GRNDOFF, 0000H

	.LONG	JAP_RnD_SCROLL+M_JUMP

* Start of portal setup
	.LONG	S_CREATE_PROCR
	.WORD	PID_IND
	.LONG	SND_LAB_DOOR,15,0,0,PROC_SND	;Delay start of door sound
	.WORD	0

	.LONG	S_SET_LONG, WAVE_IPLANE, 0

	.LONG	S_SET_VECTOR_TABLE, JAP_OFFICE_VECT_TABLE

	.LONG	S_ADJUST_YWORLD, GX_JAPB5

	.LONG	S_LEAVE_UNIV			; Set up and enter new universe
	.word	15
	.long	GX_JAPB5			; name of universe
	.long	-0C470H,3870000h,0000h	; Z, X, Y offsets
	.WORD	0

	.LONG	S_MOVE_WORD_ABS, POWERUP_SAVE, POWERUP_DURATION

	.LONG	JAP_OFFICE_SCROLL+M_JUMP


**************************************************************************
*								         *
* 		Factory damage routines					 *
*								         *
**************************************************************************
*
* Columns
*
FAC_COLUMN_CVECT
	WWL	OID_PROCKET,~MASK_PLAYER,UNIV_ROCKET_COLL
	WWL	OID_PEXPLOSION,~MASK_PLAYER,COLUMN_EXPLOSION_CVECT
	WL	0,DUMCRETS

FAC_COLUMN_DOOR_CVECT
	WWL	OID_PROCKET,~MASK_PLAYER,UNIV_ROCKET_COLL
	WWL	OID_PEXPLOSION,~MASK_PLAYER,COLUMN_DOOR_EXPLOSION_CVECT
	WL	0,DUMCRETS

FAC_BALCONY_CVECT
	WWL	OID_PROCKET,~MASK_PLAYER,UNIV_ROCKET_COLL
	WWL	OID_PEXPLOSION,~MASK_PLAYER,BALCONY_EXPLOSION_CVECT
	WL	0,DUMCRETS

**************************************************************************
*								         *
* 	COLUMN_DOOR_EXPLOSION_CVECT					 *
* 									 *
* 	Collision service vector for the factory column door.		 *
* 									 *
* 	A0 = Ptr to explosion object					 *
* 	A8 = Ptr to Column door						 *
*								         *
**************************************************************************
COLUMN_DOOR_EXPLOSION_CVECT
	MOVIM	COLUMN_DOOR_GIVE_CDS,*A8(OBOOTY_FUNC),L
	JRUC	COLUMN_EXP_G

**************************************************************************
*								         *
* 	BALCONY_EXPLOSION_CVECT						 *
* 									 *
* 	Collision service vector for the factory BALCONY.		 *
* 									 *
* 	A0 = Ptr to explosion object					 *
* 	A8 = Ptr to BALCONY						 *
*								         *
**************************************************************************
BALCONY_EXPLOSION_CVECT
	MOVIM	BALCONY_GIVE_CDS,*A8(OBOOTY_FUNC),L
	JRUC	COLUMN_EXP_G

**************************************************************************
*								         *
* 	COLUMN_EXPLOSION_CVECT						 *
* 									 *
* 	Collision service vector for the factory column.		 *
* 									 *
* 	A0 = Ptr to explosion object					 *
* 	A8 = Ptr to Column						 *
*								         *
**************************************************************************
COLUMN_EXPLOSION_CVECT
	MOVIM	COLUMN_GIVE_CDS,*A8(OBOOTY_FUNC),L

COLUMN_EXP_G
	CALLA	UNIV_COLL_CHECK			;See if this was a valid collision
	JRNZ	COLUMN_DONE			;BR = No

	MOVE	*A0(OID),A0,W
	CALLA	POID_TO_PDATA			;Get player's data area

	MOVI	M_FLASHOBJ|M_NOSTOPANIM,A7	;Take required hits

	CLR	A9				;Printed score offset
	MOVI	5000,A5				;Points for killing
	CALLA	UNIV_DAMAGE_HANDLER		;Call damage on this object
	JRC	COLUMN_EXPLODE			;BR = Column is hosed

	SOUND1	SND_COLUMN_HIT

	MMTM	SP,B1,B2,B4,B5,B6,B8,B9,B10	;MAKE FRAGMENTS

	MOVI	040000H,A0
	CLR	A3
	CALLA	PreFrag_Box
	MOVI	-0FFH,B9			;MIN Z VEL
	MOVI	-10H,B10			;MAX Z VEL
	MOVI	FRAG_COLUMN_EXPLOSION,B14	;Use this fragment script
	CALLA	Fragger

	MMFM	SP,B1,B2,B4,B5,B6,B8,B9,B10

	JRUC	COLUMN_DONE

COLUMN_EXPLODE
	MOVIM	BRICK_GRY_GUNVECT,*A8(OGUNVECT),L
	MOVIM	DUMCOLL,*A8(OCVECT),L

	SOUND1	SND_COLUMN_EXPLODE

	MMTM	SP,B1,B2,B4,B5,B6,B8,B9,B10	;MAKE FRAGMENTS

	MOVI	040000H,A0
	CLR	A3
	CALLA	PreFrag_Box
	MOVI	-0FFH,B9			;MIN Z VEL
	MOVI	-10H,B10			;MAX Z VEL
	MOVI	FRAG_FAC_U40_X2,B14		;Use this fragment script
	CALLA	Fragger

	MOVE	*A8(OIMG),A1,L
	MOVE	*A1(ICMAP),*A0(FPDATA),L	;SET PALETTE

	MMFM	SP,B1,B2,B4,B5,B6,B8,B9,B10

	MOVE	*A8(OBOOTY_FUNC),A14,L
	JRZ	COLUMN_DONE			;BR = You get no booty!

	JUMP	A14				;Go do booty routine

COLUMN_DONE
	RETS


*
* Place the CDs in the destroyed column
*
COLUMN_GIVE_CDS
	MOVK	1,A11
	MOVI	PID_IND,A1
	MOVI	REVEAL_CD,A7
	MOVI	[-14,76],A10
	CALLA	GETPRC
	MOVI	[24,92],A10
	CALLA	GETPRC
	RETS
*
* Place the CDs in the destroyed column door piece
*
COLUMN_DOOR_GIVE_CDS
	MOVK	1,A11
	MOVI	PID_IND,A1
	MOVI	REVEAL_CD,A7
	MOVI	[-60,114],A10
	CALLA	GETPRC
	MOVI	REVEAL_PROCK,A7
	MOVI	[-26,58],A10
	CALLA	GETPRC
	RETS

*
* Place the CDs in the destroyed balcony piece
*
BALCONY_GIVE_CDS
	MOVK	1,A11
	MOVI	PID_IND,A1
	MOVI	REVEAL_PROCK,A7
	MOVI	[-2,118],A10
	CALLA	GETPRC
	MOVI	[-2,148],A10
	CALLA	GETPRC
	RETS

*
* Factory walkways and stairways
*
FAC_WALKWAY_CVECT
	WWL	OID_PROCKET,~MASK_PLAYER,UNIV_ROCKET_COLL
	WWL	OID_PEXPLOSION,~MASK_PLAYER,WALKWAY_EXPLOSION_CVECT
	WL	0,DUMCRETS

**************************************************************************
*								         *
* 	WALKWAY_EXPLOSION_CVECT						 *
* 									 *
* 	Collision service vector for the Factory walkways.		 *
* 									 *
* 	A0 = Ptr to explosion object					 *
* 	A8 = Ptr to walkway piece					 *
*								         *
**************************************************************************
WALKWAY_EXPLOSION_CVECT
	CALLA	UNIV_COLL_CHECK			;See if this was a valid collision
	JRNZ	WALKWAY_DONE			;BR = No

	MOVE	*A0(OID),A0,W
	CALLA	POID_TO_PDATA			;Get player's data area

	MOVI	500,A5				;Points for killing this thing
	MOVI	M_FLASHOBJ|M_NOSTOPANIM,A7	;Last frame and flash
	CLR	A9				;Offset for printed score
	CALLA	UNIV_DAMAGE_HANDLER		;Do the patented damage shit
	JRC	WALKWAY_EXPLODE			;BR = Time to blow it all the way

WALKWAY_HIT_FRAGS
	MMTM	SP,B1,B2,B4,B5,B6,B8,B9,B10	;MAKE FRAGMENTS

	MOVI	040000H,A0
	CLR	A3
	CALLA	PreFrag_Box
	MOVI	-0FFH,B9			;MIN Z VEL
	MOVI	-10H,B10			;MAX Z VEL
	MOVI	FRAG_WALKWAY_EXPLOSION,B14	;Use this fragment script
	CALLA	Fragger

	MMFM	SP,B1,B2,B4,B5,B6,B8,B9,B10

	JRUC	WALKWAY_DONE

*
*Here we explode the Walkway
*A8 = Ptr to Walkway
*
WALKWAY_EXPLODE
	CALLA	UNIV_DISAB_ENEMY_GEN

	SOUNDZ	SND_WALKWAY_EXPLODE

	MOVIM	METAL_GUNVECT,*A8(OGUNVECT),L
	MOVIM	DUMCOLL,*A8(OCVECT),L

	MMTM	SP,B1,B2,B4,B5,B6,B8,B9,B10	;MAKE FRAGMENTS

	MOVI	040000H,A0
	CLR	A3
	CALLA	PreFrag_Box
	MOVI	-0FFH,B9			;MIN Z VEL
	MOVI	-10H,B10			;MAX Z VEL
	MOVI	FRAG_FAC_U10_X2,B14		;Use this fragment script
	CALLA	Fragger

	MOVE	*A8(OIMG),A1,L
	MOVE	*A1(ICMAP),*A0(FPDATA),L	;SET PALETTE

	MMFM	SP,B1,B2,B4,B5,B6,B8,B9,B10

WALKWAY_DONE
	RETS

*
* Factory doorways
*
FAC_DOORWAY_CVECT
	WWL	OID_PROCKET,~MASK_PLAYER,UNIV_ROCKET_COLL
	WWL	OID_PEXPLOSION,~MASK_PLAYER,DOORWAY_EXPLOSION_CVECT
	WL	0,DUMCRETS

**************************************************************************
*								         *
* 	DOORWAY_EXPLOSION_CVECT						 *
* 									 *
* 	Collision service vector for the Factory doorways.		 *
* 									 *
* 	A0 = Ptr to explosion object					 *
* 	A8 = Ptr to doorway piece					 *
*								         *
**************************************************************************
DOORWAY_EXPLOSION_CVECT
	CALLA	UNIV_COLL_CHECK			;See if this was a valid collision
	JRNZ	DOORWAY_DONE			;BR = No

	MOVE	*A0(OID),A0,W
	CALLA	POID_TO_PDATA			;Get player's data area

	MOVI	500,A5				;Points for killing this thing
	MOVI	M_FLASHOBJ|M_NOSTOPANIM,A7	;Last frame and flash
	CLR	A9				;Offset for printed score
	CALLA	UNIV_DAMAGE_HANDLER		;Do the patented damage shit
	JRNC	WALKWAY_HIT_FRAGS		;BR = Not time to blow yet
*
*Here we explode the Doorway
*A8 = Ptr to Doorway
*
DOORWAY_EXPLODE
	SOUNDZ	SND_COLUMN_EXPLODE

	CLRM	*A8(OGUNVECT),L
	MOVIM	DUMCOLL,*A8(OCVECT),L

	MMTM	SP,B1,B2,B4,B5,B6,B8,B9,B10	;MAKE FRAGMENTS

	MOVI	040000H,A0
	CLR	A3
	CALLA	PreFrag_Box
	MOVI	-0FFH,B9			;MIN Z VEL
	MOVI	-10H,B10			;MAX Z VEL
	MOVI	FRAG_FAC_U10_X2,B14		;Use this fragment script
	CALLA	Fragger

	MOVE	*A8(OIMG),A1,L
	MOVE	*A1(ICMAP),*A0(FPDATA),L	;SET PALETTE

	MMFM	SP,B1,B2,B4,B5,B6,B8,B9,B10

DOORWAY_DONE
	RETS

**************************************************************************
*								         *
* 	WALKWAY_GUNVECT							 *
* 									 *
* 	Gun vector for the Factory walkway.				 *
* 									 *
* 	A2 = Ptr to player shooting					 *
* 	A8 = Ptr to Walkway						 *
*								         *
**************************************************************************
WALKWAY_GUNVECT
	MOVI	500,A5				;Points for killing this
	MOVK	M_FLASHOBJ,A7			;Flash if we hit it
	CLR	A9				;Offset for printed score
	CALLA	UNIV_DAMAGE_HANDLER		;Call the handler
	JRC	WALKWAY_EXPLODE			;BR = Time to destroy

	CALLA	DGV_FRAG_SPARK
	SOUNDZ	SND_METAL_HIT			;Give a little sound to ack

	RETS

*
* Factory walkways and stairways
*
FAC_STAIRS_CVECT
	WWL	OID_PROCKET,~MASK_PLAYER,UNIV_ROCKET_COLL
	WWL	OID_PEXPLOSION,~MASK_PLAYER,STAIRS_EXPLOSION_CVECT
	WL	0,DUMCRETS

**************************************************************************
*								         *
* 	STAIRS_EXPLOSION_CVECT						 *
* 									 *
* 	Collision service vector for the Factory stairs.		 *
* 									 *
* 	A0 = Ptr to explosion object					 *
* 	A8 = Ptr to Window						 *
*								         *
**************************************************************************
STAIRS_EXPLOSION_CVECT
	CALLA	UNIV_COLL_CHECK			;See if this was a valid collision
	JRNZ	WALKWAY_DONE			;BR = No

	MOVE	*A0(OID),A0,W
	CALLA	POID_TO_PDATA			;Get player's data area

	MOVK	M_FLASHOBJ,A7			;Next frame and flash

	CLR	A5				;No points for match
	CLR	A9				;Printed score offset
	CALLR	FIND_MY_MATCH			;Find matching object
	JRZ	STAIRS_NO_MATCH			;BR = There isn't one
	PUSH	A8				;Store this half
	MOVE	A0,A8
	CALLA	UNIV_DAMAGE_HANDLER		;Call damage on match
	MOVIM	METAL_GUNVECT,*A8(OGUNVECT),L
	MOVIM	DUMCOLL,*A8(OCVECT),L
	PULLQ	A8				;Get us back our half
STAIRS_NO_MATCH
	MOVI	1000,A5				;Points for killing stairs
	CALLA	UNIV_DAMAGE_HANDLER		;Call damage on this half
	JRNC	WALKWAY_HIT_FRAGS		;BR = Not time to blow yet

	JRUC	WALKWAY_EXPLODE

**************************************************************************
*								         *
* 	WOOD_BRN_GUNVECT						 *
* 									 *
* 	Gun vector for brown wood stuff.				 *
* 									 *
* 	A2 = Ptr to player shooting					 *
* 	A8 = Ptr to wood thang						 *
*								         *
**************************************************************************
WOOD_BRN_GUNVECT
	CALLR	DGV_FRAG_DUST_BRN
	SOUNDZ	SND_CHEST_HIT
	RETS

**************************************************************************
*								         *
* 	BRICK_GRY_GUNVECT						 *
* 									 *
* 	Gun vector for the warehouse grey brick walls.			 *
* 									 *
* 	A2 = Ptr to player shooting					 *
* 	A8 = Ptr to brick stuff						 *
*								         *
**************************************************************************
BRICK_GRY_GUNVECT
	CALLR	DGV_FRAG_DUST_GRY
	SOUNDZ	SND_BRICK_HIT			;Give a little sound to ack

	RETS

**************************************************************************
*								         *
* 	VENT_GRN_GUNVECT						 *
* 									 *
* 	Gun vector for the green vent piece.				 *
* 									 *
* 	A2 = Ptr to player shooting					 *
* 	A8 = Ptr to vent						 *
*								         *
**************************************************************************
VENT_GRN_GUNVECT
	CALLR	DGV_FRAG_DUST_GRN
	SOUNDZ	SND_BRICK_HIT			;Give a little sound to ack
	RETS

*
*Make a green dust cloud for a bullet hit
*A2 = Ptr to player hitting
*A8 = Ptr to part being hit
*
DGV_FRAG_DUST_GRN
	PUSH	B0
	MOVI	INIT_DUST_GRN,B0
	JRUC	FRAG_DUST_G

*
*Make a green dust cloud for a bullet hit
*A2 = Ptr to player hitting
*A8 = Ptr to part being hit
*
DGV_FRAG_DUST_BRN
	PUSH	B0
	MOVI	INIT_DUST_BRN,B0
	JRUC	FRAG_DUST_G

*
*Make the dust cloud for hitting bricks
*A2 = Ptr to player hitting
*A8 = Ptr to part being hit
*
DGV_FRAG_DUST_GRY
	PUSH	B0
	MOVI	INIT_DUST_GRY,B0
	JRUC	FRAG_DUST_G

*
*Make the dust cloud for hitting red things
*A2 = Ptr to player hitting
*A8 = Ptr to part being hit
*
DGV_FRAG_DUST_RED
	PUSH	B0
	MOVI	INIT_DUST_RED,B0
	JRUC	FRAG_DUST_G

FRAG_DUST_G
	CALLA	PASTE_ON_DAMAGE
	PULLQ	B0
	RETS


INIT_DUST_GRY
	.LONG	POOOF1_WT
	.WORD	DMAWNZ, M_DEAD|M_NOPARTANI, OM_ANIM|OM_CFUNC
	.LONG	ANIM_DUST, C_DUST

INIT_DUST_GRN
	.LONG	POOOF1_GR
	.WORD	DMAWNZ, M_DEAD|M_NOPARTANI, OM_ANIM|OM_CFUNC
	.LONG	ANIM_DUST, C_DUST

INIT_DUST_BRN
	.LONG	POOOF1_BR
	.WORD	DMAWNZ, M_DEAD|M_NOPARTANI, OM_ANIM|OM_CFUNC
	.LONG	ANIM_DUST, C_DUST

INIT_DUST_RED
	.LONG	POOOF1_RD
	.WORD	DMAWNZ, M_DEAD|M_NOPARTANI, OM_ANIM|OM_CFUNC
	.LONG	ANIM_DUST, C_DUST

*
* Dust could animation
*
ANIM_DUST
	LW	1,3
	LW	POOOF2,3
	LW	POOOF3,3
	LWL	1,AFunc,DELETE_OBJ

**************************************************************************
*								         *
* 	C_DUST								 *
* 									 *
* 	Create func for the paste on dust image.			 *
* 									 *
* 	A0 = Ptr to un-inserted dust object				 *
*								         *
**************************************************************************
C_DUST
	MMTM	SP,A0,A8
	MOVE	A0,A8
	MOVE	@RAND,A0,W
	ANDI	M_FLIPH|M_FLIPV,A0		;GET SOME RANDOM FLIP BITS
	CALLA	SET_FLIP
	MMFM	SP,A0,A8
	RETS


**************************************************************************
*								         *
* 	AU_CREATE_REDBACK						 *
* 									 *
* 	Anim func to create the red background for a factory		 *
* 	door.								 *
* 									 *
* 	A8 = Ptr to door creating					 *
*								         *
**************************************************************************
OHOST_DOOR	.EQU	ODATA	;UHL Ptr to object to watch for close

AU_CREATE_REDBACK
	MOVI	INIT_REDBACK,B0
	CALLA	EASYMAKE
	JRZ	AUCR_X

	MOVE	*A8(OULINK),A1,L

	MOVE	*A1(MAP_X),*A0(OXVAL),L
	MOVE	*A1(MAP_Y),*A0(OYVAL),L
	MOVE	*A1(MAP_Z),A14,L
	ADDI	50H,A14
	MOVE	A14,*A0(OZVAL),L

	MOVE	A8,*A0(OHOST_DOOR),L

	INCM	@FAC_DOORS_OPEN,W

	MOVE	A8,A9
	MOVE	A0,A8
	MOVE	*A9(OCTRL),A0,W
	ANDI	M_FLIPH,A0
	CALLA	SET_FLIP
	
	JAUC	INSERT_OBJ

AUCR_X
	RETS

**************************************************************************
*								         *
* 	A_REDBACK_CK							 *
* 									 *
* 	Anim func for red door background to check when it should	 *
* 	delete.								 *
* 									 *
* 	A8 = Ptr to background piece					 *
*								         *
**************************************************************************
A_REDBACK_CK
	MOVB	*A8(OFLAGS),A14
	JRN	ARC_DEL			;BR = Object is off screen

	MOVE	*A8(OHOST_DOOR),A2,L

	MOVE	*A2(OULINK),A1,L

	MOVE	*A1(MAP_Y),A3,L
	MOVE	*A2(OYVAL),A4,L
	CMP	A3,A4
	JREQ	ARC_DEL			;BR = Host object is closed

	RETS

ARC_DEL
	DECM	@FAC_DOORS_OPEN,W
	JAUC	DELETE_OBJ

*
* Initialization for the red door background
INIT_REDBACK
	.LONG	DORRED
	.WORD	DMAWNZ, M_DEAD|M_DBLSCL, OM_OID|OM_COLL|OM_GUNV|OM_ANIM
	.WORD	OID_JUNK
	.LONG	DUMCOLL, METAL_GUNVECT, ANIM_REDBACK

*
* Animation for red background
*
ANIM_REDBACK
	LW	1,9
	LWL	1,1|AFunc,A_REDBACK_CK
	.LONG	0

**************************************************************************
*								         *
* 		Factory processes					 *
*								         *
**************************************************************************

**************************************************************************
*								         *
* 			R&D area scroll					 *
*								         *
**************************************************************************
*Used for entering from factory top
JAP_RnD_TEST_SCROLL

	.LONG	S_SET_LONG, WXBUFFER, 0380000H		;Open univ block buffer
	.LONG	S_SET_LONG, WYBUFFER, 0540000H

	LLW	S_SET_WORD, FAC_DOORS_OPEN, 0

	LLW	S_SET_WORD, FAC_DOORS_ALLOWED, 1

	LLW	S_SET_WORD, IN_SECRET, 0

	.LONG	S_LOCKOUT_PORTALS

	LW	S_KILL_ALL_PROCS,PID_DAMCC

	.LONG	S_SET_LONG, UEP_Z, 1C800H		;Set enemy gen

	.LONG	S_KILL_INFINITY

	.LONG	S_SET_LONG, UEP_Z, 1F000H		;Set enemy gen

;	LWWWLW	S_ACCEL_TO_POINT,-160,16H,0AACH,6000H,0	;Line Ninja doors

	LWL	S_Z_ACCEL_LIMIT,80H,0200h		;Get through door

	LLW	S_WAIT_FOR_ZREL,6000H,1

	LW	S_DECEL_TO_STOP,5

	LWWWLW	S_GOTO_POINT,-25,16H,0AACH,9B7DH,0	;Pull back so we are lined up

	.LONG	S_STOP_SCROLL

* Start of portal setup
JAP_RnD_SCROLL
	.LONG	S_CREATE_PROCR
	.WORD	PID_IND
	.LONG	SND_LAB_DOOR,15,0,0,PROC_SND	;Delay start of door sound
	.WORD	0

	.LONG	S_SET_LONG, WAVE_IPLANE, 0

	.LONG	S_SET_VECTOR_TABLE, JAP_RnDLOB_VECT_TABLE

	.LONG	S_ADJUST_YWORLD, GXKEMLOB

	.LONG	S_LEAVE_UNIV			; Set up and enter new universe
	.word	15
	.long	GXKEMLOB			; name of universe
	.long	-040a00h,-1420000h,130000h	; Z, X, Y offsets
	.WORD	0

**	This is where we come through the portal

	.LONG	S_SET_LONG, WXBUFFER, 0380000H	;Open univ block buffer
	.LONG	S_SET_LONG, WYBUFFER, 0540000H

	LW	S_AUDIT, AUDJARD

	LLW	S_SET_WORD, IN_SECRET, 0

	.LONG	S_SET_LONG, UEP_Z, 1F000H	;Set enemy gen

	LLW	S_SET_WORD,OBJENEMIES,0		;Kill the enemy gens

	LLW	S_SET_WORD,LAB_RAT,1		;Now in the R&D area

	.LONG	S_LOCKOUT_PORTALS

	LW	S_KILL_ALL_PROCS,PID_DAMCC

	.LONG	S_CREATE_PROCR			;Start the damage color stuff
	.WORD	PID_DAMCC
	.LONG	5,47,55,KSINDAM1,CYCLE16	;Badge damage
	.WORD	0

	.LONG	S_SOUND, SND_RND_MUSIC		;Start the music

	LW	S_WAIT_HERE,80

	LLW	S_DISPATCH_HERE, WAVE1END+M_WAIT,1	;Set quota for nothing

	.LONG	S_SET_LONG, UEP_Z, 1C800H	;Set enemy gen

;	LWL	S_Z_ACCEL_LIMIT,80H,280h	;Get through door
	LWW	S_SET_ZSCROLL,100H,0

	LLW	S_WAIT_FOR_ZREL,-44D12H,1

	LW	S_DECEL_TO_STOP,4

	LW	S_WAIT_HERE,60

	LWL	S_X_ACCEL_LIMIT,1000H,10000H		;Let's start movin'

	LLW	S_SET_WORD,OBJENEMIES,M_BW|M_OF_WNINJA	;Activate enemy gens

	LLLW	S_WAIT_FOR_COORD,XBASE,1700000H,1	;Turn corner to portal

	.LONG	S_DOZER_ACCEL			;Round corner and go towards portal
	.WORD	90 << 8 + M_X << 3 + M_Z  + M_X + M_ZREL
	.LONG	1A40000H			;X Position target
	.LONG	0				;X Velocity target
	.LONG	0A0H << ZFRAC			;Z Velocity target

	LLW	S_OR_WORD,OBJENEMIES,M_OF_WNINJA	;Activate Ninja

	LLW	S_WAIT_FOR_ZREL,-35960H,1

	LLW	S_SET_WORD,OBJENEMIES,0			;Kill enemy gens

;	LLW	S_WAIT_FOR_ZREL,-313D2H,1
	LLW	S_WAIT_FOR_ZREL,-348D2H,1

	LW	S_DECEL_TO_STOP,4

	LWWWLW	S_GOTO_POINT,-25,1A4h,013H,-2FA96h,0	;Pull back so we are lined up

	.LONG	S_STOP_SCROLL

*
* Through portal to KEMHAL
*
	.LONG	S_CREATE_PROCR
	.WORD	PID_IND
	.LONG	SND_LAB_DOOR,15,0,0,PROC_SND	;Delay start of door sound
	.WORD	0

	.LONG	S_LEAVE_UNIV			; Set up and enter new universe
	.word	15
	.long	GXKEMHAL			; name of universe
	.long	-028600H,1A80000h,0C0000h	; Z, X, Y offsets
	.WORD	0

	.LONG	S_SET_LONG, WXBUFFER, 0580000H		;Open univ block buffer

	LW	S_KILL_ALL_PROCS,PID_DAMCC

	.LONG	S_CREATE_PROCR			;Start the damage color stuff
	.WORD	PID_DAMCC
	.LONG	9,29,31,HMILL1p,CYCLE16		;LEDs on computer and desk
	.WORD	PID_DAMCC
	.LONG	3,24,30,JDESKd2,CYCLE16		;Damage on computer and desk
	.WORD	PID_DAMCC
	.LONG	4,26,31,NONPUTER1,CYCLE16	;LEDs on computer disk
	.WORD	PID_DAMCC
	.LONG	3,26,31,NONPUTd1,CYCLE16	;Damage computer disk
	.WORD	PID_DAMCC
	.LONG	3,30,24,NGLAMP3p,CYCLE16	;Ceiling lamp
	.WORD	0

	LWL	S_Z_ACCEL_LIMIT,80H,200h	;Get through door

	LLW	S_WAIT_FOR_ZREL,-1D177H,1

	LW	S_DECEL_TO_STOP,4

	LLW	S_SET_WORD,OBJENEMIES,M_BW|M_POPTOP|M_OF_DNINJA	;Activate enemy gens

;	LWWWLW	S_ACCEL_TO_POINT,-25,1A8H,0CH,-1E177H,0	;Pull back so we are lined up
	LWWWLW	S_GOTO_POINT,-25,1A8H,0CH,-1E177H,0	;Pull back so we are lined up

	.LONG	S_STOP_SCROLL

	LW	S_WAIT_HERE,60

	LWL	S_X_ACCEL_LIMIT,1000H,10000H	;Head to the right

	LLLW	S_WAIT_FOR_COORD,XBASE,3600000H,1	;Get to turn start

	.LONG	S_DOZER_ACCEL			;Round corner and go towards portal
	.WORD	60 << 8 + M_X << 3 + M_Z  + M_X + M_ZREL
	.LONG	3770000H			;X Position target
	.LONG	0				;X Velocity target
	.LONG	0A0H << ZFRAC			;Z Velocity target

	LLW	S_WAIT_FOR_ZREL,-18000H,1

	LW	S_DECEL_TO_STOP,4

	.LONG	S_START_DANIM			;Open face doors

	.LONG	S_SOUND,SND_LAB_DOOR		;Door hiss sound

	LLW	S_OR_WORD,OBJENEMIES,M_OF_WNINJA ;Activate Ninjas

	LW	S_WAIT_HERE,10

	LWL	S_Z_ACCEL_LIMIT,80H,200h	;Get through door

	LLW	S_WAIT_FOR_ZREL,-1000H,1

	LWL	S_X_ACCEL_LIMIT,-2000H,-18000H	;Go through the bend

	LLW	S_WAIT_FOR_ZREL,3000H,1

	LWL	S_Z_DECEL_LIMIT,-10H,0

	.LONG	S_CREATE_PROCR			;Start the damage color stuff
	.WORD	PID_DAMCC
	.LONG	5,59,61,DARPAL1,CYCLE16		;Daruma eyes
	.WORD	0

	LWL	S_X_DECEL_LIMIT,100H,-10000H	;Slow down

	LLW	S_DISPATCH_HERE, DSP_KEMHAL+M_WAIT,5	;Get some action going

	LLLW	S_WAIT_FOR_COORD,XBASE,-2B60000H,1	;Get to turn start

	LLW	S_DISPATCH_HERE, WAVE1END+M_WAIT,1	;Set quota for nothing

	.LONG	S_DOZER_ACCEL			;Round corner and go towards portal
	.WORD	80 << 8 + M_X << 3 + M_Z  + M_X + M_ZREL
	.LONG	-2CD0000H			;X Position target
	.LONG	0				;X Velocity target
	.LONG	200H << ZFRAC			;Z Velocity target

	LLW	S_WAIT_FOR_ZREL,11d00H,1
*
* Through portal to KEMOF2
*
	.LONG	S_CREATE_PROCR
	.WORD	PID_IND
	.LONG	SND_LAB_DOOR,15,0,0,PROC_SND	;Delay start of door sound
	.WORD	0

	.LONG	S_LEAVE_UNIV			; Set up and enter new universe
	.word	15
	.long	GXKEMOF2			; name of universe
	.long	188C9H,-2D00000h,120000h	; Z, X, Y offsets
	.WORD	0

	LLW	S_SET_WORD, JXLIMIT, 430H

	.LONG	S_SET_LONG, WXBUFFER, 0380000H	;Restore block buffer to something normal

	LLW	S_SET_WORD,OBJENEMIES,M_BW|M_POPTOP|M_OF_SIDER	;Activate enemy gens

	LW	S_KILL_ALL_PROCS,PID_DAMCC

	.LONG	S_CREATE_PROCR			;Start the damage color stuff
	.WORD	PID_DAMCC
	.LONG	5,47,55,KSINDAM1,CYCLE16	;Badge damage
	.WORD	PID_DAMCC
	.LONG	9,29,31,HMILL1p,CYCLE16		;LEDs on computer and desk
	.WORD	PID_DAMCC
	.LONG	3,24,30,JDESKd2,CYCLE16		;Damage on computer and desk
	.WORD	PID_DAMCC
	.LONG	9,29,31,JAPDSK7l,CYCLE16	;LEDs on computer and desk
	.WORD	PID_DAMCC
	.LONG	3,24,30,JAPDSK7lb,CYCLE16	;Damage on computer and desk
	.WORD	PID_DAMCC
	.LONG	9,29,31,JAPDSK7l2,CYCLE16	;LEDs on computer and desk
	.WORD	PID_DAMCC
	.LONG	3,24,30,JAPDK7lb2,CYCLE16	;Damage on computer and desk
	.WORD	0

	LLW	S_WAIT_FOR_ZREL,1A000H,1

	LW	S_DECEL_TO_STOP,4

;	LWWWLW	S_ACCEL_TO_POINT,-25,-2D0H,12H,1A000H,0	;Pull back so we are lined up
	LWWWLW	S_GOTO_POINT,-25,-2D0H,12H,1A000H,0	;Pull back so we are lined up

	.LONG	S_STOP_SCROLL

	LW	S_WAIT_HERE,60

	LWL	S_X_ACCEL_LIMIT,-1000H,-10000H	;Dolly across the area

	LLLW	S_WAIT_FOR_COORD,XBASE,-04000000H,1	;Get to turn start

	LLW	S_OR_WORD,OBJENEMIES,M_OF_DNINJA ;Activate Ninjas

	LLLW	S_WAIT_FOR_COORD,XBASE,-06DA0000H,1	;Get to turn start

	LLW	S_SET_WORD,OBJENEMIES,M_BW|M_POPTOP|M_OF_SIDER	;Activate enemy gens

	LLLW	S_WAIT_FOR_COORD,XBASE,-07E80000H,1	;Get to turn start

	LLW	S_OR_WORD,OBJENEMIES,M_OF_DNINJA ;Activate Ninjas

	LWL	S_X_ACCEL_LIMIT,-100H,-18000H	;Dolly across the area

	LLLW	S_WAIT_FOR_COORD,XBASE,-0D170000H,1	;Get to turn start

	LLW	S_SET_WORD,OBJENEMIES,M_BW	;Activate enemy gens

	.LONG	S_DOZER_ACCEL			;Round corner and go towards portal
	.WORD	80 << 8 + M_X << 3 + M_Z  + M_X + M_ZREL
	.LONG	-0D2E0000H			;X Position target
	.LONG	0				;X Velocity target
	.LONG	0A0H << ZFRAC			;Z Velocity target

	LLW	S_WAIT_FOR_ZREL,1E8C9H,1
*
* Through portal to GXLABP2
*
	.LONG	S_CREATE_PROCR
	.WORD	PID_IND
	.LONG	SND_LAB_DOOR,15,0,0,PROC_SND	;Delay start of door sound
	.WORD	0

	.LONG	S_LEAVE_UNIV			; Set up and enter new universe
	.word	15
	.long	GXLABP2				; name of universe
	.long	5D930H,-6B30000h,120000h	; Z, X, Y offsets
	.WORD	0

	LLW	S_WAIT_FOR_ZREL,59930H,1

	.LONG	S_CHANGE_ZFAR, 022000H

	LW	S_KILL_ALL_PROCS,PID_DAMCC

	.LONG	S_CREATE_PROCR			;Start the damage color stuff
	.WORD	PID_DAMCC
	.LONG	3,30,24,NGLAMP3p,CYCLE16	;Ceiling lamp
	.WORD	PID_DAMCC
	.LONG	5,47,55,KSINDAM1,CYCLE16	;Badge damage
	.WORD	PID_DAMCC
	.LONG	3,27,31,SBAZE1d,CYCLE16		;Brain machine damage
	.WORD	0

	LLW	S_SET_WORD,OBJENEMIES,M_BW	;Activate enemy gens

	.LONG	S_DOZER_ACCEL			;Round corner and go right
	.WORD	80 << 8 + M_Z << 3 + M_Z  + M_X + M_ZREL
	.LONG	5A400H				;Z Position target
	.LONG	-10000H				;X Velocity target
	.LONG	0				;Z Velocity target

	.LONG	S_MAKE_BRAIN_WATCHERS

	LLLW	S_WAIT_FOR_COORD,XBASE,-09600000H,1	;Get to turn start

	.LONG	S_DOZER_ACCEL			;Round corner and go towards portal
	.WORD	80 << 8 + M_X << 3 + M_Z  + M_X + M_ZREL
	.LONG	-9770000H			;X Position target
	.LONG	0				;X Velocity target
	.LONG	0A0H << ZFRAC			;Z Velocity target

	LLW	S_WAIT_FOR_ZREL,72930H,1

	.LONG	S_START_DANIM			;Open face doors

	.LONG	S_SOUND,SND_LAB_DOOR		;Door hiss sound

	LW	S_WAIT_HERE,10

	LWL	S_Z_ACCEL_LIMIT,80H,280h	;Get through door

;	LLW	S_WAIT_FOR_ZREL,08D480H,1
	LLW	S_WAIT_FOR_ZREL,08CE00H,1

	LW	S_DECEL_TO_STOP,4

	LWWWLW	S_GOTO_POINT,-25,-976h,012H,8E663h,0	;Pull back so we are lined up

	LW	S_WAIT_HERE,15

	LLW	S_SET_WORD,LAB_RAT,0		;No longer in the R&D area

	.LONG	S_SOUND, SND_MUSICOFF		;Kill the music

	.LONG	S_SET_VECTOR_TABLE, JAP_OFFICE_VECT_TABLE

	.LONG	S_CREATE_PROCR
	.WORD	PID_IND
	.LONG	SND_GONG,15,0,0,PROC_SND	;Delay start of door sound
	.WORD	0

	.LONG	S_LEAVE_UNIV			; Set up and enter new universe
	.word	15
	.long	GX_JAPB5			; name of universe
;	.long	-0C470H,3870000h,0000h	; Z, X, Y offsets
	.long	-10000H,3870000h,0000h	; Z, X, Y offsets
	.WORD	0

	.LONG	JAP_OFFICE_SCROLL+M_JUMP

	.LONG	0


*
* Generic signage collision vector
*
KTIBADGE_CVECT
	WWL	OID_PROCKET,~MASK_PLAYER,UNIV_ROCKET_COLL
	WWL	OID_PEXPLOSION,~MASK_PLAYER,KTIBADGE_EXPLOSION_CVECT
	WL	0,DUMCRETS

**************************************************************************
*								         *
* 	KTIBADGE_EXPLOSION_CVECT					 *
* 									 *
* 	Collision service vector for the big KTI Badge.			 *
* 									 *
* 	A0 = Ptr to explosion object					 *
* 	A8 = Ptr to badge						 *
*								         *
**************************************************************************
KTIBADGE_EXPLOSION_CVECT
	CALLA	UNIV_COLL_CHECK			;See if this was a valid collision
	JRNZ	KTIB_DONE			;BR = No

	MOVE	*A0(OID),A0,W
	CALLA	POID_TO_PDATA			;Get player's data area

	MOVI	1000,A5				;Points for killing this thing
	MOVI	M_LASTFRM|M_FLASHOBJ,A7		;Last frame and flash
	CLR	A9				;Offset for printed score
	CALLA	UNIV_DAMAGE_HANDLER		;Do the patented damage shit
	JRNC	METAL_GUNVECT			;BR = Damage already done

	SOUNDZ	SND_GATE_EXPLODE

	MOVIM	METAL_GUNVECT,*A8(OGUNVECT),L
	MOVIM	DUMCOLL,*A8(OCVECT),L

	MMTM	SP,B1,B2,B4,B5,B6,B8,B9,B10	;MAKE FRAGMENTS

	MOVI	040000H,A0
	CLR	A3
	CALLA	PreFrag_Center
	MOVI	-0FFH,B9			;MIN Z VEL
	MOVI	-10H,B10			;MAX Z VEL
	MOVI	FRAG_VENT_EXPLODE,B14		;Use this fragment script
	CALLA	Fragger

	MOVE	*A8(OIMG),A1,L
	MOVE	*A1(ICMAP),*A0(FPDATA),L	;SET PALETTE

	MMFM	SP,B1,B2,B4,B5,B6,B8,B9,B10

	MOVK	NUM_KTIB_POWERUPS,A0
	CALLA	RAND0
	SLL	5,A0

	MOVE	*A8(OFLAGS),A14,W
	BTST	B_DBLSCL,A14
	JRNZ	KTIB_2SCALE			;BR = This badge is 2-scale

	MOVI	[-67,4],A10		; screen Y,X offset
	ADDI	TAB_KTIB_POWERUPS,A0
	JRUC	KTIB_DO_POWER
KTIB_2SCALE
	MOVI	[-135,8],A10		; screen Y,X offset
	ADDI	TAB_KTIB_POWERUPS_X2,A0
KTIB_DO_POWER
	MOVE	*A0,A7,L
	MOVI	PID_IND,A1
	MOVK	8,A11

	CALLA	GETPRC

KTIB_DONE
	RETS


NUM_KTIB_POWERUPS	.EQU	5

TAB_KTIB_POWERUPS_X2
	.LONG	REVEAL_CD2, REVEAL_LAZER2, REVEAL_SUPERGUN2, REVEAL_SHIELD2
	.LONG	REVEAL_LIFE2

TAB_KTIB_POWERUPS
	.LONG	REVEAL_CD, REVEAL_LAZER, REVEAL_SUPERGUN, REVEAL_SHIELD
	.LONG	REVEAL_LIFE

*
* KTIVENT Collision vector
*
KTIVENT_CVECT
	WWL	OID_PROCKET,~MASK_PLAYER,UNIV_ROCKET_COLL
	WWL	OID_PEXPLOSION,~MASK_PLAYER,KTIVENT_EXPLOSION_CVECT
	WL	0,DUMCRETS

**************************************************************************
*								         *
* 	KTIVENT_EXPLOSION_CVECT			   			 *
* 									 *
* 	Collision service vector for the vent piece in the lab.		 *
* 									 *
* 	A0 = Ptr to explosion object					 *
* 	A8 = Ptr to vent						 *
*								         *
**************************************************************************
KTIVENT_EXPLOSION_CVECT
	CALLA	UNIV_COLL_CHECK			;See if this was a valid collision
	JRNZ	KTIVENT_DONE			;BR = No

	MOVE	*A0(OID),A0,W
	CALLA	POID_TO_PDATA			;Get player's data area

	MOVI	2500,A5				;Points for killing this thing
	MOVI	M_LASTFRM|M_FLASHOBJ|M_NOSTOPANIM,A7 ;Last frame and flash
	CLR	A9				;Offset for printed score
	CALLA	UNIV_DAMAGE_HANDLER		;Do the patented damage shit
	JRNC	KTIVENT_DONE			;BR = Damage already done
*
*Here we explode the vent piece
*A8 = Ptr to vent
*
KTIVENT_EXPLODE
	CALLA	UNIV_DISAB_ENEMY_GEN

	SOUND1	SND_WALL_EXPLODE

	MOVIM	VENT_GRN_GUNVECT,*A8(OGUNVECT),L
	MOVIM	DUMCOLL,*A8(OCVECT),L

	MOVE	@RAND,A14
	BTST	7,A14
	JRNZ	KVEC_DO_FRAG

	MOVI	REVEAL_PROCK,A7
	MOVI	PID_IND,A1
	MOVK	8,A11

	MOVI	[-74,-90],A10
	CALLA	GETPRC

	MOVI	[-142,-90],A10
	CALLA	GETPRC

	MOVI	[-218,-90],A10
	CALLA	GETPRC

	MOVI	[-284,-90],A10
	CALLA	GETPRC

KVEC_DO_FRAG
	MMTM	SP,B1,B2,B4,B5,B6,B8,B9,B10	;MAKE FRAGMENTS

	MOVI	040000H,A0
	CLR	A3
	MOVI	[-180,-92],A4
	MOVI	[-60,-32],A5
	CALLA	PreFrag_Box_Offset
	MOVI	-0FFH,B9			;MIN Z VEL
	MOVI	-10H,B10			;MAX Z VEL
	MOVI	FRAG_VENT_EXPLODE,B14		;Use this fragment script
	CALLA	Fragger

	MOVIM	P_RUBGRN,*A0(FPDATA),L
	MOVE	A8,*A0(FPOBJ),L			;Pass the object

	MMFM	SP,B1,B2,B4,B5,B6,B8,B9,B10

KTIVENT_DONE
	RETS

	
VASE_XORIG	.EQU	OU_ODATA+20H
VASE_YORIG	.EQU	VASE_XORIG+20H
VASE_ZORIG	.EQU	VASE_YORIG+20H

**************************************************************************
*								         *
* 	VASE_GUNVECT							 *
* 									 *
* 	Gun vector for lab vase.					 *
* 									 *
* 	A2 = Ptr to player shooting					 *
* 	A8 = Vase object						 *
*								         *
**************************************************************************
VASE_GUNVECT
	CALLA	DIST_FROM_GROUND
	SRA	16,A1
	ABS	A1
	CMPK	10,A1
	JRLO	VGV_NOISE		;BR = We are close to the ground

	MOVE	*A8(OFLAGS),A14,W
	BTST	B_DEAD,A14
	JREQ	VGV_GO
VGV_X
      	RETS
VGV_GO
	ORI	M_DEAD,A14
	MOVE	A14,*A8(OFLAGS),W
	MOVE	*A8(OXVAL),*A8(VASE_XORIG),L
	MOVE	*A8(OZVAL),*A8(VASE_ZORIG),L
	MOVE	*A8(OYVAL),*A8(VASE_YORIG),L
	MOVI	(2 << 16) + ((-52 << 8) & 0FF00H) + 0,A9  ;Z, Y, X OFFSET
	MOVI	[-010H,-0100H],A10		;[MAX, MIN] Z VELOCITY
	MOVI	[-060H,010H],A11		;[Y, X] VELOCITY LIMITS
	CREATE	PID_IND,THROW_PROCK

	MOVIM	-40000H,*A8(OYVEL),L
	MOVIM	7FFFH,*A8(OYACCEL),W

	MOVI	VASE_JUMP_ANIM,A1
	CALLA	STRT_ANIM

VGV_NOISE
	SOUNDZ	SND_VASE_HIT
	JRUC	DGV_FRAG_DUST_GRY

**************************************************************************
*								         *
* 	A_VASE_DONE							 *
* 									 *
* 	Anim func to reset vase to it's original position.		 *
* 									 *
* 	A8 = Ptr to vase						 *
*								         *
**************************************************************************
A_VASE_DONE
	CALLA	CLR_VEL
	MOVE	*A8(VASE_XORIG),*A8(OXVAL),L
	MOVE	*A8(VASE_YORIG),*A8(OYVAL),L
	MOVE	*A8(VASE_ZORIG),*A8(OZVAL),L
	ANDNIM	M_DEAD,*A8(OFLAGS),W
	JAUC	PULL_ANIM

VASE_JUMP_ANIM
	LW	1,16
	LWL	1,1|AFunc,A_VASE_DONE

*
* Vase collision vector
*
VASE_CVECT
	WWL	OID_PROCKET,~MASK_PLAYER,UNIV_ROCKET_COLL
	WWL	OID_PEXPLOSION,~MASK_PLAYER,VASE_EXPLOSION_CVECT
	WL	0,DUMCRETS

VASE_EXPLOSION_CVECT
	CALLA	UNIV_COLL_CHECK			;See if this was a valid collision
	JRNZ	VASE_DONE			;BR = No

	CALLA	DIST_FROM_GROUND
	SRA	16,A1
	ABS	A1
	CMPK	10,A1
	JRLO	VASE_DONE		;BR = We are close to the ground

VASE_EXPLODE
	MOVE	*A0(OID),A0,W
	CALLA	POID_TO_PDATA			;Get player's data area

	SOUNDZ	SND_VASE_EXPLODE

	CALLA	COLLS_OFF

	MOVI	1000,A1
	MOVI	[-10,0],A9
	CALLA	PRINT_SCORE

	MMTM	SP,B1,B2,B4,B5,B6,B8,B9,B10	;MAKE FRAGMENTS

	MOVI	040000H,A0
	CLR	A3
	CALLA	PreFrag_Center
	MOVI	-0FFH,B9			;MIN Z VEL
	MOVI	-10H,B10			;MAX Z VEL
	MOVI	FRAG_VASE_EXPLODE,B14		;Use this fragment script
	CALLA	Fragger

	MOVE	*A8(OIMG),A1,L
	MOVE	*A1(ICMAP),*A0(FPDATA),L	;SET PALETTE

	MMFM	SP,B1,B2,B4,B5,B6,B8,B9,B10

	MOVI	(2 << 16) + ((-52 << 8) & 0FF00H) + 0,A9  ;Z, Y, X OFFSET
	MOVI	[-010H,-0100H],A10		;[MAX, MIN] Z VELOCITY
	MOVI	[-060H,010H],A11		;[Y, X] VELOCITY LIMITS
	MOVI	PID_IND,A1
	MOVI	THROW_PROCK,A7

	CALLA	GETPRC
	CALLA	GETPRC
	CALLA	GETPRC
	CALLA	GETPRC

	MOVI	ANIM_VASE_DEL,A1
	CALLA	STRT_ANIM

VASE_DONE
	RETS

ANIM_VASE_DEL
	LWL	1,3|AFunc,BG_TO_FG
	LWL	1,1|AFunc,DELETE_OBJ

FRAG_VASE_EXPLODE
	.long	PART_EXPLOSION,0
	.word	OID_JUNK,1*800H+1*40H+FRGPAL+FRGNOFLY
	.long	FRAG_UANIM,F_UFRAG_STUFF
	.word	OID_JUNK,(3 << 11) + (1 << 6) + (FRGGCOL)
	.long	FRAG_UANIM,F_UFRAG_STUFF
	.word	OID_JUNK,(2 << 11) + (0 << 6) + (FRGBOG+FRGGCOL)
	.long	0

**************************************************************************
*								         *
* 	ARMOR_GUNVECT							 *
* 									 *
* 	Gun vector for the armor shogun guy.				 *
* 									 *
* 	A2 = Ptr to player shooting					 *
* 	A8 = Ptr to armor						 *
*								         *
**************************************************************************
ARMOR_GUNVECT
	SOUNDZ	SND_ARMOR_HIT			;Give a little sound to ack

	CALLA	DGV_FRAG_SPARK

	MMTM	SP,B1,B2,B4,B5,B6,B8,B9,b10		;MAKE FRAGMENTS

	MOVI	080000H,A0
	CLR	A3
	CLR	A4
	CALLA	PreFrag_Gun
	DEC	B0
	MOVI	FRAG_U1,B14
	CALLA	Fragger

	MOVE	*A8(OIMG),A1,L
	MOVE	*A1(ICMAP),*A0(FPDATA),L	;SET PALETTE

	MMFM	SP,B1,B2,B4,B5,B6,B8,B9,b10

	RETS


*
* Armor head collision vector
*
ARMOR_HEAD_CVECT
	WWL	OID_PROCKET,~MASK_PLAYER,UNIV_ROCKET_COLL
	WWL	OID_PEXPLOSION,~MASK_PLAYER,AHEAD_EXPLOSION_CVECT
	WL	0,DUMCRETS

AHEAD_EXPLOSION_CVECT
	CALLA	UNIV_COLL_CHECK		;See if this was a valid collision
	JRNZ	AHEAD_DONE     		;BR = No

	MOVE	*A0(OID),A0,W
	CALLA	POID_TO_PDATA			;Get player's data area

	SOUND1	SND_VASE_EXPLODE

	MOVI	5000,A1
	MOVI	[-150,0],A9
	CALLA	PRINT_SCORE

*
* A2 = Ptr to player
* A8 = Ptr to head object
*
AHEAD_EXPLODE
	CALLA	COLLS_OFF

	MMTM	SP,B1,B2,B4,B5,B6,B8,B9,B10	;MAKE FRAGMENTS

	MOVI	040000H,A0
	CLR	A3
	CALLA	PreFrag_Center
	MOVI	-0FFH,B9			;MIN Z VEL
	MOVI	-10H,B10			;MAX Z VEL
	MOVI	FRAG_AHEAD_EXPLODE,B14		;Use this fragment script
	CALLA	Fragger

	MOVE	*A8(OIMG),A1,L
	MOVE	*A1(ICMAP),*A0(FPDATA),L	;SET PALETTE

	MMFM	SP,B1,B2,B4,B5,B6,B8,B9,B10

	MOVI	OID_JUNK,A1
	CALLA	CHANGE_OID

	MOVI	ANIM_VASE_DEL,A1
	CALLA	STRT_ANIM

AHEAD_DONE
	RETS


FRAG_AHEAD_EXPLODE
	.long	PART_EXPLOSION,0
	.word	OID_JUNK,1*800H+1*40H+FRGPAL+FRGNOFLY
	.long	FRAG_UANIM,F_UFRAG_STUFF
	.word	OID_JUNK,(3 << 11) + (1 << 6) + (FRGGCOL)
	.LONG	FRAG_AHEAD,F_UFRAG_STUFF_X2
	.word	OID_JUNK,(1 << 11) + (1 << 6) + (FRGGCOL)
	.long	FRAG_UANIM,F_UFRAG_STUFF_X2
	.word	OID_JUNK,(2 << 11) + (0 << 6) + (FRGBOG+FRGGCOL)
	.long	0


FRAG_AHEAD
	LW	ARMHELM1,3
	LW	ARMHELM2,3
	LW	ARMHELM3,3
	LW	ARMHELM4,3
	LW	ARMHELM5,3
	LW	ARMHELM6,3
	LWL	ARMHELM7,3|AFunc,A_DELETE_ZBOT
	.long	0
	

*
* Armor Body collision vector
*
ARMOR_BODY_CVECT
	WWL	OID_PROCKET,~MASK_PLAYER,UNIV_ROCKET_COLL
	WWL	OID_PEXPLOSION,~MASK_PLAYER,ABODY_EXPLOSION_CVECT
	WL	0,DUMCRETS

ABODY_EXPLOSION_CVECT
	CALLA	UNIV_COLL_CHECK		;See if this was a valid collision
	JRNZ	ABODY_DONE     		;BR = No

	MOVE	*A0(OID),A0,W
	CALLA	POID_TO_PDATA			;Get player's data area

	SOUND1	SND_BODY_EXPLODE1
	SOUND1	SND_BODY_EXPLODE2

	PUSH	A8
	MOVE	*A8(OXPOS),A1,W

	MOVI	(OID_UNIV|ID_17),A0	;This is the Heads I.D.
	CALLA	EXIST_OBJ_ALL
	JRZ	ABODY_NO_HEAD
AEC_CHECK
	MOVE	*A8(OXPOS),A14,W
	SUB	A1,A14
	ABS	A14
	CMPK	20,A14
	JRLS	ABODY_GOT_HEAD

	CALLA	RESUME_EXIST_OBJ_ALL
	JRNZ	AEC_CHECK
	JRUC	ABODY_NO_HEAD

ABODY_GOT_HEAD
	CALLR	AHEAD_EXPLODE

ABODY_NO_HEAD
	PULLQ	A8

	CALLR	FIND_MY_MATCH			;Find matching object
	JRZ	ABODY_NO_MATCH			;BR = There isn't one

	PUSH	A8
	MOVE	A0,A8
	CALLR	ABODY_EXPLODE
	PULLQ	A8

ABODY_NO_MATCH
	MOVI	5000,A1
	MOVI	[-100,0],A9
	CALLA	PRINT_SCORE
*
* A2 = Ptr to player shooting
* A8 = Ptr to body part
*
ABODY_EXPLODE
	CALLA	COLLS_OFF

	MMTM	SP,B1,B2,B4,B5,B6,B8,B9,B10	;MAKE FRAGMENTS

	MOVI	040000H,A0
	CLR	A3
	CALLA	PreFrag_Center
	MOVI	-0FFH,B9			;MIN Z VEL
	MOVI	-10H,B10			;MAX Z VEL
	MOVI	FRAG_ABODY_EXPLODE,B14		;Use this fragment script
	CALLA	Fragger

	MOVE	*A8(OIMG),A1,L
	MOVE	*A1(ICMAP),*A0(FPDATA),L	;SET PALETTE

	MMFM	SP,B1,B2,B4,B5,B6,B8,B9,B10

	MOVI	OID_JUNK,A1
	CALLA	CHANGE_OID

	MOVI	ANIM_VASE_DEL,A1
	CALLA	STRT_ANIM

ABODY_DONE
	RETS


FRAG_ABODY_EXPLODE
	.long	PART_EXPLOSION,0
	.word	OID_JUNK,1*800H+1*40H+FRGPAL+FRGNOFLY
	.long	FRAG_UANIM,F_UFRAG_STUFF_X2
	.word	OID_JUNK,(3 << 11) + (1 << 6) + (FRGGCOL)
	.LONG	FRAG_ABODYa,F_UFRAG_STUFF_X2
	.word	OID_JUNK,(2 << 11) + (1 << 6) + (FRGGCOL)
	.long	PART_EXPLOSION,0
	.word	OID_JUNK,1*800H+1*40H+FRGPAL+FRGNOFLY
	.long	FRAG_UANIM,F_UFRAG_STUFF_X2
	.word	OID_JUNK,(2 << 11) + (0 << 6) + (FRGBOG+FRGGCOL)
	.LONG	FRAG_ABODYb,F_UFRAG_STUFF_X2
	.word	OID_JUNK,(2 << 11) + (1 << 6) + (FRGGCOL)
	.long	PART_EXPLOSION,0
	.word	OID_JUNK,1*800H+1*40H+FRGPAL+FRGNOFLY
	.long	FRAG_UANIM,F_UFRAG_STUFF_X2
	.word	OID_JUNK,(2 << 11) + (0 << 6) + (FRGBOG+FRGGCOL)
	.LONG	FRAG_ABODYc,F_UFRAG_STUFF_X2
	.word	OID_JUNK,(2 << 11) + (1 << 6) + (FRGGCOL)
	.long	FRAG_UANIM,F_UFRAG_STUFF_X2
	.word	OID_JUNK,(2 << 11) + (0 << 6) + (FRGBOG+FRGGCOL)
	.long	0

FRAG_ABODYa
	LW	ARMCHNKa1,3
	LW	ARMCHNKa2,3
	LW	ARMCHNKa3,3
	LW	ARMCHNKa4,3
	LW	ARMCHNKa5,3
	LWL	ARMCHNKa6,3|AFunc,A_DELETE_ZBOT
	.long	0
	
FRAG_ABODYb
	LW	ARMCHNKb1,3
	LW	ARMCHNKb2,3
	LW	ARMCHNKb3,3
	LW	ARMCHNKb4,3
	LW	ARMCHNKb5,3
	LWL	ARMCHNKb6,3|AFunc,A_DELETE_ZBOT
	.long	0

FRAG_ABODYc
	LW	ARMCHNKc1,3
	LW	ARMCHNKc2,3
	LW	ARMCHNKc3,3
	LW	ARMCHNKc4,3
	LW	ARMCHNKc5,3
	LWL	ARMCHNKc6,3|AFunc,A_DELETE_ZBOT
	.long	0


**************************************************************************
*								         *
* 	FAN_GUNVECT							 *
* 									 *
* 	Gun vector for folding fan.					 *
* 									 *
* 	A2 = Ptr to player shooting					 *
* 	A8 = Fan object							 *
*								         *
**************************************************************************
FAN_GUNVECT
	MOVE	*A8(OFLAGS),A14,W
	BTST	B_DEAD,A14
	JREQ	FGV_GO
      	RETS
FGV_GO
	ORI	M_DEAD,A14
	MOVE	A14,*A8(OFLAGS),W

	SOUND1	SND_FAN_OPEN

	MOVI	fan1,A1
	JAUC	STRT_ANIM


*
* Ornamental fan collision vector
*
FAN_CVECT
	WWL	OID_PROCKET,~MASK_PLAYER,UNIV_ROCKET_COLL
	WWL	OID_PEXPLOSION,~MASK_PLAYER,FAN_EXPLOSION_CVECT
	WL	0,DUMCRETS

FAN_EXPLOSION_CVECT
	CALLA	UNIV_COLL_CHECK			;See if this was a valid collision
	JRZ	VASE_EXPLODE			;BR = Yes
	RETS


**************************************************************************
*								         *
* 	GONG_GUNVECT							 *
* 									 *
* 	Gun vector for the gong.					 *
* 									 *
* 	A2 = Ptr to player shooting					 *
* 	A8 = Ptr to gong						 *
*								         *
**************************************************************************
GONG_GUNVECT
	MOVE	*A2(PPLASMASHOTS),A14,W
	JRNZ	GEC_RING
	CALLA	DGV_FRAG_SPARK
	SOUND1	SND_GONG_BULLET_HIT		;Give a little sound to ack
	RETS


*
* Gong collision vector
*
GONG_CVECT
	WWL	OID_PROCKET,~MASK_PLAYER,UNIV_ROCKET_COLL
	WWL	OID_PEXPLOSION,~MASK_PLAYER,GONG_EXPLOSION_CVECT
	WL	0,DUMCRETS

GONG_EXPLOSION_CVECT
	CALLA	UNIV_COLL_CHECK			;See if this was a valid collision
	JRNZ	GEC_X				;BR = Yes

	MOVE	*A0(OID),A0,W
	CALLA	POID_TO_PDATA			;Get player's data area
*
* A2 = Ptr to player
*
GEC_RING
     	MOVE	*A8(OFLAGS),A14,W
	BTST	B_ANIM,A14
	JRNZ	GEC_SOUND			;Don't re-animate

	MOVI	GGONG1,A1
	CALLA	STRT_ANIM

	MOVE	@LAB_RAT,A14,W
	JRZ	GEC_SOUND			;BR = No score if not in lab

	MOVI	5000,A1
	MOVI	[0,0],A9
	CALLA	PRINT_SCORE

GEC_SOUND
	SOUND1	SND_GONG_HIT
GEC_X
	RETS

*
* The windows to the world
*
RND_WINDOW_CVECT
	WWL	OID_PROCKET,~MASK_PLAYER,UNIV_ROCKET_COLL
	WWL	OID_PEXPLOSION,~MASK_PLAYER,RND_WINDOW_EXPLOSION
	WL	0,DUMCRETS

**************************************************************************
*								         *
* 	RND_WINDOW_EXPLOSION						 *
* 									 *
* 	Collision service vector for the R&D windows.			 *
* 									 *
* 	A0 = Ptr to explosion object					 *
* 	A8 = Ptr to Window						 *
*								         *
**************************************************************************
RND_WINDOW_EXPLOSION
	CALLA	UNIV_COLL_CHECK			;See if this was a valid collision
	JRNZ	RND_WINDOW_DONE			;BR = No

	MOVE	*A0(OID),A0,W
	CALLA	POID_TO_PDATA			;Get player's data area

	MOVK	M_NOMORE|M_NEXTFRM|M_FLASHOBJ,A7		;Next frame and flash
	JRUC	RND_WINDOW_GO

**************************************************************************
*								         *
* 	RND_WINDOW_GUNVECT						 *
* 									 *
* 	Gun vector for the R&D window.					 *
* 									 *
* 	A2 = Player that shot us					 *
* 	A8 = Ptr to window object					 *
*								         *
**************************************************************************
RND_WINDOW_GUNVECT
	MOVK	M_NOMORE|M_FLASHOBJ,A7		;FLASH
RND_WINDOW_GO
	SOUND1	SND_WINDOW_CRACK
	CLR	A9				;Printed score offset
	MOVI	5000,A5				;Points for killing window
	CALLA	UNIV_DAMAGE_HANDLER		;Call damage on this window
	JRNC	RND_WINDOW_DONE			;BR = We haven't hit the last frame

	ANDNIM	M_NOPIXSCAN,*A8(OFLAGS),W

	MMTM	SP,B1,B2,B4,B5,B6,B8,B9,B10	;MAKE FRAGMENTS

	MOVI	040000H,A0
	CLR	A3
	CALLA	PreFrag_Box
	MOVI	-0FFH,B9			;MIN Z VEL
	MOVI	-01H,B10			;MAX Z VEL
	MOVI	FRAG_S20,B14
	CALLA	Fragger

	MOVI	SHARDPAL1,A14
	MOVE	A14,*A0(FPDATA),L		;SET PALETTE

	MMFM	SP,B1,B2,B4,B5,B6,B8,B9,B10

	SOUND1	SND_WINDOW_BREAK

	JAUC	WC_MAKE_GLASS

RND_WINDOW_DONE
	RETS

*
* Plasma glass collision
*
PLASMA_CVECT
	WWL	OID_PROCKET,~MASK_PLAYER,UNIV_ROCKET_COLL
	WWL	OID_PEXPLOSION,~MASK_PLAYER,PLASMA_EXPLOSION_CVECT
	WL	0,DUMCRETS

**************************************************************************
*								         *
* 	PLASMATOP_GUNVECT						 *
* 									 *
* 	Gun vector for the top piece of the plasma deal.		 *
* 									 *
* 	A2 = Ptr to player shooting					 *
* 	A8 = Ptr to top piece						 *
*								         *
**************************************************************************
PLASMATOP_GUNVECT
	MOVIM	DISK_BOOTY,*A8(OBOOTY_FUNC),L
	MOVI	500,A5				;Points for killing this
	MOVK	M_FLASHOBJ,A7			;Flash if we hit it
	CLR	A9				;Offset for printed score
	CALLA	UNIV_DAMAGE_HANDLER		;Call the handler
	JRC	MONITOR_EXPLODE			;BR = Time to destroy

	SOUNDZ	SND_METAL_HIT			;Give a little sound to ack
	JAUC	DGV_FRAG_SPARK

	RETS

*
* Plasma brain flosser top piece
*
PLASMATOP_CVECT
	WWL	OID_PROCKET,~MASK_PLAYER,UNIV_ROCKET_COLL
	WWL	OID_PEXPLOSION,~MASK_PLAYER,PLASMATOP_EXPLOSION_CVECT
	WL	0,DUMCRETS

**************************************************************************
*								         *
* 	PLASMATOP_EXPLOSION_CVECT					 *
* 									 *
* 	Collision service vector for the plasma top.			 *
* 									 *
* 	A0 = Ptr to explosion object					 *
* 	A8 = Ptr to top piece						 *
*								         *
**************************************************************************
PLASMATOP_EXPLOSION_CVECT
	CALLA	UNIV_COLL_CHECK			;See if this was a valid collision
	JRNZ	MONITOR_DONE			;BR = No
	MOVIM	DISK_BOOTY,*A8(OBOOTY_FUNC),L	;Dis be da loot
	JRUC	FINISH_COMP_DESK

**************************************************************************
*								         *
* 	DARUMA_GUNVECT							 *
* 									 *
* 	Gun vector for the daruma base.					 *
* 									 *
* 	A2 = Ptr to player shooting					 *
* 	A8 = Ptr to wood thang						 *
*								         *
**************************************************************************
DARUMA_GUNVECT
	CALLR	DGV_FRAG_DUST_RED
	SOUNDZ	SND_CHEST_HIT
	RETS

DARUMA_CVECT
	WWL	OID_PROCKET,~MASK_PLAYER,UNIV_ROCKET_COLL
	WWL	OID_PEXPLOSION,~MASK_PLAYER,DARUMA_EXPLOSION_CVECT
	WL	0,DUMCRETS


DARUMA_EXPLOSION_CVECT
	CALLA	UNIV_COLL_CHECK			;See if this was a valid collision
	JRNZ	DARUMA_DONE			;BR = No

	MOVE	*A0(OID),A0,W
	CALLA	POID_TO_PDATA			;Get player's data area

	SOUNDZ	SND_VASE_EXPLODE

	CALLA	COLLS_OFF

	MOVI	1000,A1
	MOVI	[-10,0],A9
	CALLA	PRINT_SCORE

	MMTM	SP,B1,B2,B4,B5,B6,B8,B9,B10	;MAKE FRAGMENTS

	MOVI	040000H,A0
	CLR	A3
	CALLA	PreFrag_Center
	MOVI	-0FFH,B9			;MIN Z VEL
	MOVI	-10H,B10			;MAX Z VEL
	MOVI	FRAG_VASE_EXPLODE,B14		;Use this fragment script
	CALLA	Fragger

	MOVE	*A8(OIMG),A1,L
	MOVE	*A1(ICMAP),*A0(FPDATA),L	;SET PALETTE

	MMFM	SP,B1,B2,B4,B5,B6,B8,B9,B10

	MOVI	ANIM_VASE_DEL,A1
	CALLA	STRT_ANIM

	MOVI	(2 << 16) + ((-52 << 8) & 0FF00H) + 0,A9  ;Z, Y, X OFFSET
	MOVI	[-010H,-0100H],A10		;[MAX, MIN] Z VELOCITY
	MOVI	[-060H,010H],A11		;[Y, X] VELOCITY LIMITS
	MOVI	PID_IND,A1
	MOVI	THROW_PROCK,A7

	CALLA	GETPRC
	CALLA	GETPRC
	CALLA	GETPRC
	CALLA	GETPRC

	PUSH	A8

	MOVE	*A8(OXPOS),A5,W

	MOVI	(OID_UNIV|ID_20)&~MASK_SUPP,A0	;Let's find the top parts
	MOVI	~MASK_SUPP,A1
	CALLA	EXIST_OBJ		;Did we find one
	JRZ	DARUMA_X		;BR = No, just die
DS_LOOP
	MOVE	*A8(OXPOS),A14,W	
	SUB	A5,A14
	ABS	A14
	CMPK	10,A14
	JRGT	DS_NEXT

	CALLA	COLLS_OFF

	MOVI	OID_JUNK,A1
	CALLA	CHANGE_OID

	MOVI	ANIM_VASE_DEL,A1
	CALLA	STRT_ANIM

DS_NEXT
	MOVI	(OID_UNIV|ID_20)&~MASK_SUPP,A0	;Let's find the top parts
	MOVI	~MASK_SUPP,A1
	CALLA	RESUME_EXIST_OBJ	;Did we find another
	MOVE	A0,A8
	JRNZ	DS_LOOP			;BR = Yes, do the same to it

DARUMA_X
	PULLQ	A8
DARUMA_DONE
	RETS

**************************************************************************
*								         *
* 	DARTOP_GUNVECT							 *
* 									 *
* 	Gun vector for the daruma top.					 *
* 									 *
* 	A2 = Ptr to player shooting					 *
* 	A8 = Ptr to wood thang						 *
*								         *
**************************************************************************
DARTOP_GUNVECT
	MOVI	[-45, -12],A3
	MOVI	[-38, -7],A4
	CALLA	BOX_CHECK_OBJ
	JRZ	DARUMA_GUNVECT		;BR = Hit the wood
	JRUC	DARTOP_EXPLODE


DARTOP_CVECT
	WWL	OID_PROCKET,~MASK_PLAYER,UNIV_ROCKET_COLL
	WWL	OID_PEXPLOSION,~MASK_PLAYER,DARTOP_EXPLOSION_CVECT
	WL	0,DUMCRETS

DARTOP_EXPLOSION_CVECT
	CALLA	UNIV_COLL_CHECK			;See if this was a valid collision
	JRNZ	DARTOP_DONE			;BR = No

	MOVE	*A0(OID),A0,W
	CALLA	POID_TO_PDATA			;Get player's data area

*
* A2 = Ptr to player data
*
DARTOP_EXPLODE
	SOUNDZ	SND_VASE_EXPLODE

	CALLA	COLLS_OFF

	MOVI	1000,A1
	MOVI	[-10,0],A9
	CALLA	PRINT_SCORE

	MMTM	SP,B1,B2,B4,B5,B6,B8,B9,B10	;MAKE FRAGMENTS

	MOVI	040000H,A0
	CLR	A3
	CALLA	PreFrag_Center
	MOVI	-0FFH,B9			;MIN Z VEL
	MOVI	-10H,B10			;MAX Z VEL
	MOVI	FRAG_VASE_EXPLODE,B14		;Use this fragment script
	CALLA	Fragger

	MOVE	*A8(OIMG),A1,L
	MOVE	*A1(ICMAP),*A0(FPDATA),L	;SET PALETTE

	MMFM	SP,B1,B2,B4,B5,B6,B8,B9,B10

	CALLR	FIND_MY_MATCH
	JRNZ	DARTOP_SPEW_CDS			;There's another

	MOVK	NUM_KTIB_POWERUPS,A0
	CALLA	RAND0
	SLL	5,A0

	MOVI	[-52,0],A10		; screen Y,X offset
	ADDI	TAB_KTIB_POWERUPS,A0
	MOVE	*A0,A7,L
	MOVI	PID_IND,A1
	MOVK	8,A11

	CALLA	GETPRC

	JRUC	DARTOP_DEL

DARTOP_SPEW_CDS
	MOVI	(2 << 16) + ((-52 << 8) & 0FF00H) + 0,A9  ;Z, Y, X OFFSET
	MOVI	[-010H,-0100H],A10		;[MAX, MIN] Z VELOCITY
	MOVI	[-060H,010H],A11		;[Y, X] VELOCITY LIMITS
	MOVI	PID_IND,A1
	MOVI	THROW_PROCK,A7

	CALLA	GETPRC
	CALLA	GETPRC
	CALLA	GETPRC
	CALLA	GETPRC

DARTOP_DEL
	MOVI	OID_JUNK,A1
	CALLA	CHANGE_OID

	MOVI	ANIM_VASE_DEL,A1
	CALLA	STRT_ANIM

DARTOP_DONE
	RETS

**************************************************************************
*								         *
* 	PROC_NINJA_RnD_JUMPIN						 *
* 									 *
* 	Process to create a jump in Ninja in the R&D section.		 *
*								         *
**************************************************************************
PROC_NINJA_RnD_JUMPIN
	MOVE	@XBASE+16,A0,W
	MOVE	A0,A9	
	SUBI	250,A9
	ADDI	250,A0
	SLL	16,A0
	MOVY	A0,A9

	MOVE	@YBASE,A11,L

	MOVE	@ZBASE,A0,L
	MOVE	@ZREL_OFF,A14,L
	SRA	ZFRAC,A14
	SUB	A14,A0
	
	MOVE	A0,A10
	ADDI	7000H,A10
	SRA	8,A10

	ADDI	09000H,A0
	SLL	8,A0
	MOVY	A0,A10

	JAUC	PROC_NINJA_JUMPIN


**************************************************************************
*								         *
* 	S_MAKE_BRAIN_WATCHERS						 *
* 									 *
* 	Scroll func to make the Yellow jackets that watch over the	 *
* 	Kerris.								 *
*								         *
**************************************************************************
S_MAKE_BRAIN_WATCHERS:
	movi	BRAIN_WATCH_TABLE,a9

	move	*a9+,a10		; how many guards
SMBW_lp:
	move	*a9+,a4,L
	move	*a9+,a2,L
	move	*a9+,a3,L

	MOVE	@ZREL_OFF,A14,L
	SRA	ZFRAC,A14
	ADD	A14,A3

	calla	CREATE_YJAK

	sleep	1

	dsjs	a10,SMBW_lp
	jauc	SCRL_DISPATCHER	


BRAIN_WATCH_TABLE:
	.word	2
	.long	-7F50000h,190000h,062E12h
	.long	-9730000h,190000h,062E12h

**************************************************************************
*								         *
* 			Manager's office scroll				 *
*								         *
**************************************************************************
JAP_OFFICE_SCROLL
**	This is where we come through the portal
	LWL	S_CREATE_PROC,PID_IND,PROC_DESK_YJAK	;Create the manager

	LW	S_AUDIT, AUDJADESK

	LW	S_KILL_ALL_PROCS,PID_DAMCC

	LLW	S_SET_WORD,OFFICE_DAMAGE_FLAG,0		;Clear for good measure

	LLW	S_SET_WORD,DESK_XFORM_FLAG,0		;Clear for good measure

	LLW	S_SET_WORD,NO_CHARITY,1			;Don't give it

	LLW	S_SET_WORD,GUNS_OFF,1

;	LLW	S_SET_WORD,OFFICE_DAMAGE_FLAG,1

;	.long	0

	.LONG	S_SET_LONG, WYBUFFER, 0640000H

	LW	S_WAIT_HERE,45
	
	LWL	S_CREATE_PROC,PID_IND,CLOUD1_PROC	;Set up the far away clouds

	LWL	S_CREATE_PROC,PID_IND,CLOUD2_PROC	;Set up the closer clouds

	LW	S_WAIT_HERE,30

	.LONG	S_SOUND, SND_OFFICE			;Start some music

	LWL	S_CREATE_PROC,PID_DESK,DESK_PROC	;Set up the real desk

	LWL	S_Z_ACCEL_LIMIT,10H,380h		;Head for desk

;	LWLW	S_GOTO_POINTZ,-300,-5600H,0		;Zoom up to manager's desk

	LLW	S_WAIT_FOR_ZREL,-18470H,1

;	LWL	S_CREATE_PROC,PID_IND,JOSH_PROC

	LLW	S_SET_WORD,GUNS_OFF,1

	LLW	S_WAIT_FOR_ZREL,-6000H,1

	LW	S_DECEL_TO_STOP,4

	LWLW	S_GOTO_POINTZ,-25,-5600H,0		;Lock on manager's desk

	LLW	S_SET_WORD,JOSH_SIT_FLAG,1

	.LONG	S_WAIT_UNTIL_TRUE, DESK_XFORM_FLAG	;Wait until desk xforms

	LW	S_WAIT_HERE,130				;Wait for the xform

;	.LONG	S_CREATE_PROCR			;Start the damage color stuff
;	.WORD	PID_DAMCC
;	.LONG	4,60,48,C_DAMGE_P,CYCLE16	;Craft damage
;	.WORD	0

	LLW	S_SET_WORD,GUNS_OFF,0

	LLW	S_SET_WORD,NO_CHARITY,0			;Give to the needy

	LLW	S_SET_WORD,OFFICE_DAMAGE_FLAG,1

	.LONG	S_LOAD_BOSS_PUNISH

;	LWLW	S_GOTO_POINTZ,-70,-13E70H,0		;Pull back in a panic
	LWLW	S_GOTO_POINTZ,-70,-13000H,0		;Pull back in a panic

	.LONG	S_WAIT_UNTIL_TRUE, MONDOR_MORPH_FLAG	;Wait until Mondor morphs

	LWLW	S_GOTO_POINTZ,-60,-13E70H,0		;Pull back in a panic

	.long	0


**************************************************************************
*								         *
* 		Manager's office damage handlers			 *
*								         *
**************************************************************************
*
*Warchest
*
OFFICE_CHEST_CVECT
	WWL	OID_PROCKET,~MASK_PLAYER,UNIV_ROCKET_COLL
	WWL	OID_PEXPLOSION,~MASK_PLAYER,CHEST_EXPLOSION_CVECT
	WL	0,DUMCRETS

* SPECIAL warchest
OFFICE_SCHEST_CVECT
	WWL	OID_PROCKET,~MASK_PLAYER,UNIV_ROCKET_COLL
	WWL	OID_PEXPLOSION,~MASK_PLAYER,SCHEST_EXPLOSION_CVECT
	WL	0,DUMCRETS

**************************************************************************
*								         *
* 	CHEST_EXPLOSION_CVECT						 *
* 									 *
* 	Collision service vector for the Japanese war chest.		 *
* 									 *
* 	A0 = Ptr to explosion object					 *
* 	A8 = Ptr to Chest						 *
*								         *
**************************************************************************
CHEST_EXPLOSION_CVECT
	MOVE	@OFFICE_DAMAGE_FLAG,A14,W	;Are we allowed to blow these up?
	JRZ	CHEST_DONE			;BR = No

	MOVIM	CHEST_GIVE_ROCKETS,*A8(OBOOTY_FUNC),L

CHEST_EXPLOSION_G
	CALLA	UNIV_COLL_CHECK			;See if this was a valid collision
	JRNZ	CHEST_DONE			;BR = No

	MOVE	*A0(OID),A0,W
	CALLA	POID_TO_PDATA			;Get player's data area

	MOVI	500,A5				;Points for killing this thing
	MOVK	M_LASTFRM|M_FLASHOBJ,A7		;Last frame and flash
	CLR	A9				;Offset for printed score
	CALLA	UNIV_DAMAGE_HANDLER		;Do the patented damage shit
	JRNC	CHEST_DONE			;BR = Damage already done
*
*Here we explode the Warchest
*A8 = Ptr to chest
*
CHEST_EXPLODE
	SOUNDZ	SND_CHEST_EXPLODE

	MOVIM	DEAD_GUNVECT,*A8(OGUNVECT),L
	MOVIM	DUMCOLL,*A8(OCVECT),L

	MMTM	SP,B1,B2,B4,B5,B6,B8,B9,B10	;MAKE FRAGMENTS

	MOVI	040000H,A0
	CLR	A3
	CALLA	PreFrag_Box
	MOVI	-0FFH,B9			;MIN Z VEL
	MOVI	-01H,B10			;MAX Z VEL
	MOVI	FRAG_U20,B14			;Use this fragment script
	CALLA	Fragger

	MOVI	Chest_p,A14
	MOVE	A14,*A0(FPDATA),L		;Set Palette

	MOVI	040000H,A0
	CLR	A3
	CALLA	PreFrag_Center

	CLR	B3
	CLR	B4   				;No XVEL
	MOVK	4,B7				;Maximum YVEL
	SLL	16,B7
	MOVE	B7,B8
	MOVI	FRAG_EXPLOSION_UP,B14		;Throw an explosion
	CALLA	Fragger

	MMFM	SP,B1,B2,B4,B5,B6,B8,B9,B10

	MOVE	*A8(OBOOTY_FUNC),A14,L
	JUMP	A14

CHEST_GIVE_ROCKETS
	MOVK	1,A11
	MOVI	PID_IND,A1
	MOVI	REVEAL_PROCK,A7
	MOVI	[-20,-17],A10
	CALLA	GETPRC
	MOVI	[-40,-17],A10
	CALLA	GETPRC
	MOVI	[-23,6],A10
	CALLA	GETPRC
	MOVI	[-43,6],A10
	CALLA	GETPRC

	MOVI	ANIM_CHEST_CHARITY,A1		;Make the chest give a shit
	CALLA	STRT_ANIM

CHEST_DONE
	RETS

*
* Give up the special shit, if the player finds it
*
CHEST_GIVE_SPECIAL
	MOVK	1,A11
	MOVI	[-33,-8],A10
	CREATE	PID_IND,REVEAL_CD
	RETS

**************************************************************************
*								         *
* 	SCHEST_EXPLOSION_CVECT						 *
* 									 *
* 	Collision service vector for the SPECIAL Japanese war chest.	 *
* 									 *
* 	A0 = Ptr to explosion object					 *
* 	A8 = Ptr to Chest						 *
*								         *
**************************************************************************
SCHEST_EXPLOSION_CVECT
	MOVIM	CHEST_GIVE_SPECIAL,*A8(OBOOTY_FUNC),L
	JRUC	CHEST_EXPLOSION_G

**************************************************************************
*								         *
* 	OFFICE_CHEST_GUNVECT						 *
* 									 *
* 	Gun vector for Japanese war chest.				 *
* 									 *
* 	A2 = Ptr to player shooting					 *
* 	A8 = Ptr to chest						 *
*								         *
**************************************************************************
OFFICE_CHEST_GUNVECT
	MOVE	@OFFICE_DAMAGE_FLAG,A14,W	;Are we allowed to blow these up?
	JRZ	CHEST_HIT_SND			;BR = No

	MOVIM	CHEST_GIVE_ROCKETS,*A8(OBOOTY_FUNC),L

*Jump in here from other chest gun vectors
CHEST_GUN_G
	MOVI	500,A5				;Points for killing this
	MOVK	M_FLASHOBJ,A7			;Flash if we hit it
	CLR	A9				;Offset for printed score
	CALLA	UNIV_DAMAGE_HANDLER		;Call the handler
	JRC	CHEST_EXPLODE			;BR = Time to destroy

CHEST_HIT_SND
	SOUNDZ	SND_CHEST_HIT			;Give a little sound to ack

	RETS

**************************************************************************
*								         *
* 	OFFICE_SCHEST_GUNVECT						 *
* 									 *
* 	Gun vector for SPECIAL Japanese war chest.			 *
* 									 *
* 	A2 = Ptr to player shooting					 *
* 	A8 = Ptr to chest						 *
*								         *
**************************************************************************
OFFICE_SCHEST_GUNVECT
	MOVIM	CHEST_GIVE_SPECIAL,*A8(OBOOTY_FUNC),L
	JRUC	CHEST_GUN_G

**************************************************************************
*								         *
* 	DEAD_GUNVECT							 *
* 									 *
* 	Gun vector to just make a thunk sound when object is shot.	 *
*								         *
**************************************************************************
DEAD_GUNVECT
	SOUNDZ	SND_CHEST_HIT
	RETS

*
* The windows to the world
*
OFFICE_WINDOW_CVECT
	WWL	OID_PROCKET,~MASK_PLAYER,UNIV_ROCKET_COLL
	WWL	OID_PEXPLOSION,~MASK_PLAYER,WINDOW_EXPLOSION_CVECT
	WL	0,DUMCRETS

**************************************************************************
*								         *
* 	WINDOW_EXPLOSION_CVECT						 *
* 									 *
* 	Collision service vector for the Japanese office windows.	 *
* 									 *
* 	A0 = Ptr to explosion object					 *
* 	A8 = Ptr to Window						 *
*								         *
**************************************************************************
WINDOW_EXPLOSION_CVECT
	MOVE	@OFFICE_DAMAGE_FLAG,A14,W	;Are we allowed to blow these up?
	JRZ	WINDOW_DONE			;BR = No

PLASMA_EXPLOSION_CVECT
	CALLA	UNIV_COLL_CHECK			;See if this was a valid collision
	JRNZ	CHEST_DONE			;BR = No

	MOVE	*A0(OID),A0,W
	CALLA	POID_TO_PDATA			;Get player's data area

	MOVK	M_NOMORE|M_NEXTFRM|M_FLASHOBJ,A7		;Next frame and flash
	JRUC	WINDOW_GO


**************************************************************************
*								         *
* 	OFFICE_WINDOW_GUNVECT						 *
* 									 *
* 	Gun vector for the office window.				 *
* 									 *
* 	A2 = Player that shot us					 *
* 	A8 = Ptr to window object					 *
*								         *
**************************************************************************
OFFICE_WINDOW_GUNVECT
	MOVI	[-186,-80],A3
	MOVI	[-28, 0],A4
	CALLA	BOX_CHECK_OBJ			;Did we hit just the glass?
	JRZ	WINDOW_DONE			;BR = No, musta hit the frame

	MOVE	@OFFICE_DAMAGE_FLAG,A14,W	;Are we allowed to blow these up?
	JRZ	WINDOW_HIT_SND			;BR = No

PLASMA_GUNVECT
	MOVK	M_NOMORE|M_FLASHOBJ,A7		;FLASH

WINDOW_GO
	SOUNDZ	SND_WINDOW_CRACK
	CLR	A5				;No points for match
	CLR	A9				;Printed score offset
	CALLR	FIND_MY_MATCH			;Find matching object
	JRZ	WINDOW_NO_MATCH			;BR = There isn't one
	PUSH	A8				;Store this window
	MOVE	A0,A8
	CALLA	UNIV_DAMAGE_HANDLER		;Call damage on match
	JRNC	WINDOW_MATCH_NOT_LAST		;BR = Match still has some left
	ANDNIM	M_NOPIXSCAN,*A8(OFLAGS),W	;Clear pixscan when done
WINDOW_MATCH_NOT_LAST
	PULLQ	A8				;Get us back our window
WINDOW_NO_MATCH
	MOVI	1000,A5				;Points for killing window
	CALLA	UNIV_DAMAGE_HANDLER		;Call damage on this window
	JRNC	WINDOW_DONE			;BR = We haven't hit the last frame

	ANDNIM	M_NOPIXSCAN,*A8(OFLAGS),W

	MMTM	SP,B1,B2,B4,B5,B6,B8,B9,B10	;MAKE FRAGMENTS

	MOVI	040000H,A0
	CLR	A3
	CALLA	PreFrag_Box
	MOVI	-0FFH,B9			;MIN Z VEL
	MOVI	-01H,B10			;MAX Z VEL
	MOVI	FRAG_S20,B14
	CALLA	Fragger

	MOVI	SHARDPAL1,A14
	MOVE	A14,*A0(FPDATA),L		;SET PALETTE

	MMFM	SP,B1,B2,B4,B5,B6,B8,B9,B10

	SOUND1	SND_WINDOW_BREAK

	JAUC	WC_MAKE_GLASS

WINDOW_DONE
	RETS

WINDOW_HIT_SND
	SOUNDZ	SND_WINDOW_CRACK
	RETS

**************************************************************************
*								         *
* 	FIND_MY_MATCH							 *
* 									 *
* 	Find this objects match.  Used for finding an opposite		 *
* 	flipped version of the same object at approx. the same		 *
* 	position.							 *
* 									 *
* 	A8 = Ptr to object						 *
* 									 *
* 	Returns:							 *
* 		 Z = No match, A0 = 0					 *
* 		NZ = Found match, A0 = Ptr to matching object		 *
*								         *
**************************************************************************
FIND_MY_MATCH
	MMTM	SP,A1,A2,A3,A4,A5,A6
	CALLA	GET_SUPP		;Get the correct supp list
	JRZ	FMM_X			;BR = Not on one, yikes!

	MOVE	*A8(OCTRL),A2,W
	ANDI	M_FLIPH,A2		;Isolate the flip we are concerned with

	MOVE	*A8(OXPOS),A3,W
	MOVE	*A8(OYPOS),A4,W
	SLL	16,A4
	MOVY	A4,A3
	MOVE	A3,A4	  		;Open up a target box
	ADDXYI	[-10,-10],A3
	ADDXYI	[10,10],A4

	MOVE	*A8(OID),A5,W		;We need an I.D. to match

	MOVE	*A8(OZVAL),A6,L

	JRUC	FMM_NEXT

FMM_LOOP
	MOVE	*A0(OID),A14,W	
	CMP	A5,A14			;Is it the same type?
	JRNE	FMM_NEXT		;BR = Not one of us

	MOVE	*A0(OCTRL),A14,W	;Get the flip 
	ANDI	M_FLIPH,A14
	CMP	A2,A14			;Are they the same?
	JREQ	FMM_NEXT		;BR = Yes.  Well, we hate that.

	MOVE	*A0(OZVAL),A14,L
	SUB	A6,A14
	ABS	A14
	CMPI	1000H,A14
	JRGT	FMM_NEXT

	MOVE	*A0(OXPOS),A1,W
	MOVE	*A0(OYPOS),A14,W
	SLL	16,A14
	MOVY	A14,A1

	CMPXY	A3,A1			;Check point against UL
	JRXLT	FMM_NEXT
	JRYLT	FMM_NEXT
	CMPXY	A4,A1			;Check point against LR
	JRXGT	FMM_NEXT
	JRYGT	FMM_NEXT

	MOVE	A0,A0			;We've got it!
	JRUC	FMM_X
FMM_NEXT
	MOVE	*A0(OSLINK),A0,L	;Grab next object in line
	JRNZ	FMM_LOOP		;BR = Got another to check
FMM_X
	MMFM	SP,A1,A2,A3,A4,A5,A6
	RETS

**************************************************************************
*								         *
* 		Sounds for Japan office damage				 *
*								         *
**************************************************************************
SND_CHEST_EXPLODE
	.WORD	0F340H,103,0A3D1H,0
SND_CHEST_HIT
	.WORD	0F308H,31,0A15AH,0
SND_WINDOW_BREAK
	.WORD	0F342H,70,0A32EH,0	;Window break, skips channels
SND_WINDOW_CRACK
	.WORD	0F308H,47,0A32BH,0
SND_WALKWAY_EXPLODE
	.WORD	0F340H,72,0A405H,0	;Gate being blown out
SND_OFFICE
	.WORD	0F0FDH,1,08004H,0	;Enter Japanese manager's office
SND_LAB_DOOR
	.WORD	0F280H,62,08332H,0	;Pnuematic lab door opening
SND_COLUMN_HIT
	.WORD	0F341H,60,0A170H,0	;Column piece getting hit
SND_COLUMN_EXPLODE
	.WORD	0F342H,60,0A38DH,0	;Column piece exploding
SND_BRICK_HIT
	.WORD	0F308H,47,0A166H,0	;Brick wall being hit
SND_MONITOR_FIZZ
	.WORD	0F142H,20,0A320H,0A31AH,0A31DH,0A31AH,0	;Monitor fizzling
SND_GONG
	.WORD	0F280H,308,0817EH,0	;Manager's office gong
SND_WALL_EXPLODE
	.WORD	0F340h,103,0A3D1h,0	;Wall piece exploding
SND_DOOR_BONK
	.WORD	0F351H,74,0A13BH,0
SND_RND_MUSIC
	.WORD	0F0FDH,1,0800FH,0	;Enter research and development area
SND_VASE_HIT
	.WORD	0F108H,31,0A15EH,0	;Hit vase in RnD
SND_VASE_EXPLODE
	.WORD	0F340H,60,0A147H,0
SND_ARMOR_HIT
	.WORD	0F108H,49,0A130H,0	;Hit armor head in RnD
SND_BODY_EXPLODE1
	.WORD	0F141H,60,0A124H,0
SND_BODY_EXPLODE2
	.WORD	0F340H,75,0A170H,0
SND_FAN_OPEN
	.WORD	0F140H,20,0A18CH,0
SND_GONG_HIT
	.WORD	0F143H,308,0A17DH,0	;Player rockets the gong
SND_GONG_BULLET_HIT
	.WORD	0F308H,56,0A135H,0	;Player shoots the gong


OBOOTY_FUNC	.EQU	OU_ODATA	;UHL This is where we go to give the shit

**************************************************************************
*								         *
* 		Animation stuff for Japan office damage			 *
*								         *
**************************************************************************
*
* Make the destroyed chest sit around and feed powerups when
* somebody is low.
*
ANIM_CHEST_CHARITY
	LWLWWW	1,1|AFunc,A_RAND_REL_BYTE+3,3,7,AnimLoop
ACC_WAIT_LOOP
	LWLL	1,100|AFunc,A_Anim_DSJ+2,ACC_WAIT_LOOP
ACC_LOW_LOOP
	LWLL	1,10|AFunc,A_CHECK_CHARITY+2,ACC_LOW_LOOP
*It's time to give it up
	LWLWWW	1,1|AFunc,A_RAND_REL_BYTE+3,1,3,AnimLoop
ACC_DELIVER_LOOP
	LWLL	1,60|AFunc,A_Anim_DSJ+2,ACC_DELIVER_LOOP
*Check once more before we give it up
	LWLL	1,10|AFunc,A_CHECK_CHARITY+2,ANIM_CHEST_CHARITY
	LWL	1,1|AFunc,A_CHEST_GIVE
	LWLL	1,1|AFunc,A_AnimFrm+2,ANIM_CHEST_CHARITY

**************************************************************************
*								         *
* 	A_CHECK_CHARITY							 *
* 									 *
* 	Anim func to check if we should give some charity		 *
* 	rockets.  If any active player is low on rockets,		 *
* 	then we will fall through.  Otherwise the animation		 *
* 	branch is taken.						 *
* 									 *
* 	A8 = Ptr to object checking					 *
* 	AARG+,L = Animation branch if no charity needed			 *
*								         *
**************************************************************************
A_CHECK_CHARITY
	MOVE	@NO_CHARITY,A14,W	;Are we allowed to give charity?
	JANE	SetAnim_AFARG		;BR = No

	MOVI	P1DATA,A2
	MOVI	MAXPLAYERS,A6		;This many players possible
ACC_LOOP
	MOVE	*A2(POBJ),A14,L		;Is this player active?
	JRZ	ACC_NEXT		;BR = No, then don't check

	MOVE	*A2(PBOMB1),A14,W
	CMPI	50,A14			;Is this player low on rockets?
	JRHS	ACC_NEXT		;BR = No
	RETS				;Fall through

ACC_NEXT
	ADDI	PDSIZE,A2		;Next player
	DSJ	A6,ACC_LOOP		;If there is one
	
	JAUC	SetAnim_AFARG
	
**************************************************************************
*								         *
* 	A_CHEST_GIVE							 *
* 									 *
* 	Anim func to make chest give some charity rockets.		 *
* 									 *
* 	A8 = Ptr to chest object					 *
*								         *
**************************************************************************
A_CHEST_GIVE
	MOVK	1,A11
	MOVI	PID_IND,A1
	MOVI	REVEAL_PROCK,A7
	MOVI	[-21,-18],A10
	CALLA	GETPRC
	MOVI	[-21,7],A10
	JAUC	GETPRC

**************************************************************************
*								         *
* 	F_EXPLOSION_UP					   		 *
* 									 *
* 	Fragment init function for explosion going up.			 *
* 									 *
* 	A0 = Ptr to un-inserted chunk object.				 *
*								         *
**************************************************************************
F_EXPLOSION_UP_2X
	ORIM	M_DBLSCL,*A0(OFLAGS),W
F_EXPLOSION_UP
	MOVE	*A0(OYVEL),A14,L
	ABS	A14
	NEG	A14
	MOVE	A14,*A0(OYVEL),L
	RETS


FRAG_EXPLOSION_UP
	.long	FRAG_EXPLOSION,F_EXPLOSION_UP
	.word	OID_JUNK,1*800H+1*40H+FRGPAL+FRGNOFLY
	.long	0

FRAG_EXPLOSION
	LW	FHKEXPLOB1,6
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
* Factory fragger scripts
*
FRAG_FAC_U40_X2
	.long	FRAG_EXPLOSION,F_EXPLOSION_OUT_2X
	.word	OID_JUNK,1*800H+0*40H+FRGPAL+FRGNOFLY

	.long	FRAG_FAC_UANIM,F_UFRAG_FAC_X2
	.word	OID_JUNK,(4 << 11) + (1 << 6)

	.long	FRAG_EXPLOSION,F_EXPLOSION_OUT_2X
	.word	OID_JUNK,1*800H+0*40H+FRGPAL+FRGNOFLY

	.long	FRAG_FAC_UANIM,F_UFRAG_FAC_X2
	.word	OID_JUNK,(4 << 11) + (1 << 6) + FRGBOG

	.long	FRAG_EXPLOSION,F_EXPLOSION_OUT_2X
	.word	OID_JUNK,1*800H+0*40H+FRGPAL+FRGNOFLY

	.long	FRAG_FAC_UANIM,F_UFRAG_FAC_X2
	.word	OID_JUNK,(4 << 11) + (1 << 6) + FRGBOG

	.long	FRAG_FAC_UANIM,F_UFRAG_FAC_X2
	.word	OID_JUNK,(4 << 11) + (1 << 6) + FRGBOG

	.long	FRAG_FAC_UANIM,F_UFRAG_FAC_X2
	.word	OID_JUNK,(4 << 11) + (1 << 6) + FRGBOG

	.long	FRAG_FAC_UANIM,F_UFRAG_FAC_X2
	.word	OID_JUNK,(4 << 11) + (1 << 6) + FRGBOG

	.long	FRAG_FAC_UANIM,F_UFRAG_FAC_X2
	.word	OID_JUNK,(4 << 11) + (1 << 6) + FRGBOG

	.long	0

FRAG_FAC_U10_X2
	.long	FRAG_EXPLOSION,F_EXPLOSION_UP_2X
	.word	OID_JUNK,1*800H+0*40H+FRGPAL+FRGNOFLY

	.long	FRAG_FAC_UANIM,F_UFRAG_FAC_X2
	.word	OID_JUNK,(3 << 11) + (1 << 6)

	.long	FRAG_FAC_UANIM,F_UFRAG_FAC_X2
	.word	OID_JUNK,(3 << 11) + (1 << 6) + FRGBOG

	.long	FRAG_FAC_UANIM,F_UFRAG_FAC_X2
	.word	OID_JUNK,(3 << 11) + (1 << 6) + FRGBOG

	.long	0

FRAG_COLUMN_EXPLOSION
	.long	FRAG_EXPLOSION,F_EXPLOSION_OUT_2X
	.word	OID_JUNK,1*800H+1*40H+FRGPAL+FRGNOFLY

	.long	FRAG_EXPLOSION,F_EXPLOSION_OUT_2X
	.word	OID_JUNK,1*800H+1*40H+FRGPAL+FRGNOFLY

	.long	FRAG_EXPLOSION,F_EXPLOSION_OUT_2X
	.word	OID_JUNK,1*800H+1*40H+FRGPAL+FRGNOFLY

	.long	0

FRAG_WALKWAY_EXPLOSION
	.long	FRAG_EXPLOSION,F_EXPLOSION_OUT_2X
	.word	OID_JUNK,1*800H+1*40H+FRGPAL+FRGNOFLY

	.long	FRAG_EXPLOSION,F_EXPLOSION_OUT_2X
	.word	OID_JUNK,1*800H+1*40H+FRGPAL+FRGNOFLY

	.long	0

FRAG_FAC_UANIM
	LWLW	FHKI1SHRAPB1,1|AFunc,A_Set_AnimLoop+1,3
	LWLWW	1,1|AFunc,A_RAND_AnimSLP+2,1,5
FF_UANIM_LOOP
	LW	FHKI1SHRAPB2,0
	LW	FHKI1SHRAPB3,0
	LW	FHKI1SHRAPB4,0
	LW	FHKI1SHRAPB5,0
	LW	FHKI1SHRAPB6,0
	LW	FHKI1SHRAPB7,0
	LWLL	FHKI1SHRAPB1,0|AFunc,A_AnimFrm_DSJ+2,FF_UANIM_LOOP
	LWL	1,1|AFunc,DELETE_OBJ

**************************************************************************
*								         *
* 	F_UFRAG_FAC_X2							 *
* 									 *
* 	Frag create func to make the fragment X2 scale then		 *
* 	jump to the usual						 *
* 									 *
* 	A0 = Ptr to un-inserted object.					 *
*								         *
**************************************************************************
F_UFRAG_FAC_X2
	ORIM	M_DBLSCL,*A0(OFLAGS),W
F_UFRAG_FAC
	move	A0,A2
	MOVE	*A13(FPDATA),A0,L	;GET PALETTE
	JRZ	FUF_NOPAL		;BR = NO PALETTE TO SET!
	CALLA	GETFPAL
	MOVE	A0,*A2(OPAL),W
FUF_NOPAL
	MOVE	A2,A0
	RETS

FRAG_VENT_EXPLODE
	.long	FRAG_DUST_CLOUD_ANIM,F_VENT_DUST
	.word	OID_JUNK,(1 << 11) + (0 << 6) + (FRGNOFLY+FRGNOFLP)
	.long	BRK_ANIM_1,F_UFRAG_STUFF_X2
	.word	OID_JUNK,(4 << 11) + (1 << 6) + (FRGGCOL)
	.long	BRK_ANIM_2,F_UFRAG_STUFF
	.word	OID_JUNK,(4 << 11) + (1 << 6) + (FRGBOG|FRGGCOL)
	.long	0

**************************************************************************
*								         *
* 	F_VENT_DUST							 *
* 									 *
* 	Frag func to initialize the vent dust cloud			 *
* 									 *
* 	A0 = Ptr to un-inserted object					 *
*								         *
**************************************************************************
F_VENT_DUST
	ORIM	M_DBLSCL,*A0(OFLAGS),W
	MOVE	A0,A2
	MOVI	P_DUSTGRN,A0
	CALLA	GETFPAL
	MOVE	A0,*A2(OPAL),W
	MOVE	A2,A0

	MOVE	*A13(FPOBJ),A2,L
	MOVE	*A2(OCTRL),A14,W
	BTST	B_FLIPH,A14
	JREQ	FVD_NOFLIP

	MOVE	*A0(OXVEL),A14,L
	ABS	A14
	NEG	A14
	JRUC	FVD_VSTORE

FVD_NOFLIP
	MOVE	*A0(OXVEL),A14,L
	ABS	A14
FVD_VSTORE
	MOVE	A14,*A0(OXVEL),L

	RETS

P_DUSTGRN
   .word   64 
   .word   00000h,00000h,00000h,00000h,00042h,00021h,00000h,000c6h
   .word   00063h,00000h,00000h,00084h,00108h,00001h,00001h,000a5h
   .word   0014ah,00023h,00002h,00dceh,0058ch,01610h,000e7h,00129h
   .word   0016bh,01e51h,000c8h,00086h,00043h,00003h,00026h,0000bh
   .word   0010ah,0006ah,02691h,0012ah,0014bh,00109h,009adh,0012bh
   .word   00045h,000c7h,000e8h,0014ch,000abh,00004h,000cdh,0058eh
   .word   011efh,0016ch,000a7h,00010h,00130h,000a6h,0016dh,0000dh
   .word   00089h,0012eh,000efh,0058dh,00022h,02ed1h,011edh,01a2fh

P_RUBGRN:
   .word   32 
   .word   00000h,00088h,00088h,0012ah,00109h,0014ah,000a8h,000c8h
   .word   00129h,0016ah,00088h,000a8h,000e8h,00088h,00088h,000eah
   .word   000c8h,00129h,000e8h,0018bh,00108h,00088h,000a8h,00088h
   .word   00108h,0020fh,00088h,001cdh,000a8h,000c8h,0020fh,0010ah


*
* Inside R&D area
*
DSP_KEMHAL
	.LONG	DSPTAB_KEMHAL,0
	.WORD	   0,   0,   0,   0,   0,   0,   0,   0	
	.WORD	   0,   0,   0,   0,   0,   0,   0,   1

*
* R&D KEMHAL section
*
DSPTAB_KEMHAL
	.WORD	0			;End of initial dispatch

	.WORD  	60,PID_NINJA
	.LONG	0H,0h,0H,0,PROC_NINJA_RnD_JUMPIN

	.WORD	0

**************************************************************************
*								         *
* 	Collision vector tables for Japan universe.			 *
* 									 *
* 	Each Table is made up of 32 entries, one for			 *
* 	each allowable background ID.					 *
* 									 *
* 	Each entry:							 *
* 									 *
* 	.LONG	Collision_Vector, Gun_Vector				 *
*								         *
**************************************************************************
JAP_OUTSIDE_VECT_TABLE
;1, 2
	.LONG	0, 0, 0, METAL_GUNVECT
;3, 4
	.LONG	0, BRICK_GRY_GUNVECT, 0, METBRIK1_GUNVECT
;5, 6
	.LONG	0, METBRIK2_GUNVECT, KTIDOOR1_CVECT, METAL_GUNVECT
;7, 8
	.LONG	VIDCAM_CVECT, VIDCAM_GUNVECT, MONITOR_CVECT, MONITOR_GUNVECT
;9, 10
	.LONG	CDESK_CVECT, METAL_GUNVECT, 0, 0
;11, 12
	.LONG	0, 0, SIGN_CVECT, SIGN_GUNVECT
;13, 14
	.LONG	VENT_CVECT, VENTBRIK_GUNVECT, 0, 0
;15, 16
	.LONG	0, 0, ENT_CRATE_CVECT, ENT_CRATE_GUNVECT
;17, 18
	.LONG	ALIGHT_CVECT, ALIGHT_GUNVECT, KTIDOOR2_CVECT, METAL_GUNVECT
;19, 20
	.LONG	0, 0, 0, 0
;21, 22
	.LONG	0, 0, 0, 0
;23, 24
	.LONG	0, 0, 0, 0
;25, 26
	.LONG	0, 0, 0, 0
;27, 28
	.LONG	0, 0, 0, 0
;29, 30
	.LONG	0, 0, 0, 0
;31, 32
	.LONG	0, 0, 0, 0

JAP_FACTORY_VECT_TABLE
;1, 2
	.LONG	0, 0, FAC_COLUMN_CVECT, BRICK_GRY_GUNVECT
;3, 4
	.LONG	DUMCOLL, METAL_GUNVECT, FAC_DOORWAY_CVECT, METAL_GUNVECT
;5, 6
	.LONG	FAC_STAIRS_CVECT, METAL_GUNVECT, 0, 0
;7, 8
	.LONG	0, BRICK_GRY_GUNVECT, 0, METAL_GUNVECT
;9, 10
	.LONG	FAC_COLUMN_DOOR_CVECT, BRICK_GRY_GUNVECT, FAC_BALCONY_CVECT, BRICK_GRY_GUNVECT
;11, 12
	.LONG	FAC_WALKWAY_CVECT, METAL_GUNVECT, 0, 0
;13, 14
	.LONG	0, 0, 0, 0
;15, 16
	.LONG	0, 0, 0, 0
;17, 18
	.LONG	0, 0, 0, 0
;19, 20
	.LONG	0, 0, 0, 0
;21, 22
	.LONG	0, 0, 0, 0
;23, 24
	.LONG	0, 0, 0, 0
;25, 26
	.LONG	0, 0, 0, 0
;27, 28
	.LONG	0, 0, 0, 0
;29, 30
	.LONG	0, 0, 0, 0
;31, 32
	.LONG	0, 0, 0, 0

JAP_RnDLOB_VECT_TABLE
;1, 2
	.LONG	0, 0, DUMCOLL, WOOD_BRN_GUNVECT
;3, 4
	.LONG	KTIVENT_CVECT, VENT_GRN_GUNVECT, DUMCOLL, VENT_GRN_GUNVECT
;5, 6
	.LONG	VASE_CVECT, VASE_GUNVECT, PALMTREETOP_COLLVECTR, PALMTREETOP_GUNVECT
;7, 8
	.LONG	DUMCOLL, METAL_GUNVECT, DLAMP_COLLVECT, DLAMP_GUNVECT
;9, 10
	.LONG	RND_WINDOW_CVECT, RND_WINDOW_GUNVECT, KTIBADGE_CVECT, METAL_GUNVECT
;11, 12
	.LONG	0, 0, FAN_CVECT, FAN_GUNVECT
;13, 14
	.LONG	GONG_CVECT, GONG_GUNVECT, SIGN_CVECT, SIGN_NOFLASH_GUNVECT
;15, 16
	.LONG	MARS_CVECT, MARS_GUNVECT, 0, 0
;17, 18
	.LONG	ARMOR_BODY_CVECT, ARMOR_GUNVECT, ARMOR_HEAD_CVECT, ARMOR_GUNVECT
;19, 20
	.LONG	CDESK_CVECT, METAL_GUNVECT, MONITOR_CVECT, MONITOR_GUNVECT
;21, 22
	.LONG	DARTOP_CVECT, DARTOP_GUNVECT, DARUMA_CVECT, DARUMA_GUNVECT
;23, 24
	.LONG	DISK_CVECT, METAL_GUNVECT, PLASMA_CVECT, PLASMA_GUNVECT
;25, 26
	.LONG	CDESK_CVECT, METAL_GUNVECT, PLASMATOP_CVECT, PLASMATOP_GUNVECT
;27, 28
	.LONG	0, 0, 0, 0
;29, 30
	.LONG	0, 0, 0, 0
;31, 32
	.LONG	0, 0, 0, 0

JAP_OFFICE_VECT_TABLE
;1, 2
	.LONG	0, 0, 0, 0
;3, 4
	.LONG	0, 0, 0, 0
;5, 6
	.LONG	0, 0, OFFICE_CHEST_CVECT, OFFICE_CHEST_GUNVECT
;7
	.LONG	OFFICE_WINDOW_CVECT, OFFICE_WINDOW_GUNVECT
;8
	.LONG	OFFICE_SCHEST_CVECT, OFFICE_SCHEST_GUNVECT
;9, 10
	.LONG	0, 0, 0, 0
;11, 12
	.LONG	VASE_CVECT, VASE_GUNVECT, PALMTREETOP_COLLVECTR, PALMTREETOP_GUNVECT
;13, 14
	.LONG	GONG_CVECT, GONG_GUNVECT, 0, 0
;15, 16
	.LONG	0, 0, 0, 0
;17, 18
	.LONG	0, 0, 0, 0
;19, 20
	.LONG	0, 0, 0, 0
;21, 22
	.LONG	0, 0, 0, 0
;23, 24
	.LONG	0, 0, 0, 0
;25, 26
	.LONG	0, 0, 0, 0
;27, 28
	.LONG	0, 0, 0, 0
;29, 30
	.LONG	0, 0, 0, 0
;31, 32
	.LONG	0, 0, 0, 0

	.END
