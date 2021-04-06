 	.MLIB	"GXMACS.LIB"
 	.FILE	"GXBEEK1.ASM"
	.TITLE	" <<< GENERATION X -- BEEKEEPER ROUTINES >>>"
	.WIDTH	132
	.OPTION	B,D,L,T
	.MNOLIST

**************************************************************************
*								         *
* 	COPYRIGHT (C) 1993 MIDWAY MANUFACTURING COMPANY.		 *
* 		       ALL RIGHTS RESERVED.				 *
*								         *
**************************************************************************

*	GET THE SYSTEM STUFF
	.INCLUDE	"GXENEMY.INC"
	.INCLUDE	"IMGTBL.GLO"
	.include	gxnonboy.h
	.include	"univtbl.glo"
	.include	"gxbeek2.tbl"
	.include	"gxnatv.h"
	.INCLUDE	"GXCONTRL.H"

	.text

OLD_WAY	.set	0

**
**	The following .refs replace .include gxglo.h
**
	.ref  A_Anim_DSJ,A_SOUND,EASYMAKE,A_RAND_OXVEL,CK_PLAYER_HIT
	.ref  BG_TO_FG,ONESND,UNIV_DAMAGE_HANDLER,A_CHNG_SCRL_TBL,END_JUNGLE
	.ref  UNIV_ROCKET_COLL,NUM_OUT_THERE,UNIV_FLASH,ZBASE_HR,MAX_ALLOWED
	.ref  A_OFF_KILL_OBJ,RAND,UNIV_COLL_CHECK,XBASE,SET_SCALE_MANUAL
	.ref  YBASE,CURPLYRS,ZBASE,A_RAND_HFLIP,YHALF,A_Set_AnimLoop
	.ref  FADE_ONE,GET_SPARE_PAL,ONESND_Z,UNIV_DISAB_ENEMY_GEN
	.ref  LAVA_SHATTER_HOOK,LAVADAM2,LAVADAM3,LAVADAM4,LAVADAM5,LAVADAM6 
	.ref  A_CHANGE_PAL,PALSET,PALRAM,A_CLR_OZVEL,DELETE_OBJ_PROC
	.ref  JUNGDIECALL,SET_ANIPU,YWORLD,XSCROLL,PROCK_AWARD,SCROLLKILL
	.ref  NONBOY_SBOMB,INSERT_ENEMY,CREATE_ENEMY, WVSTRT_CHANCE
	.ref  HIT_SCREEN,WAVEIRQS,A_STAY_TIL_ZW_LT,YSCROLL,EGUN_FLASH
	.ref  A_SET_OYACCEL,A_STAY_TIL_GRND_HIT,SCROLL_FLAG,CHNG_SCRL_TBL
	.ref	SCRL_DISPATCHER,HOLD_ENEMY_DISPATCH,A_SOUNDZ_ONSCREEN
	.ref	DEL_ENEMY_NOAUD,DELETE_ENEMY,OBJENEMIES,PLAYER_AWARD_GIRL
	.ref	DROP_A_MASK_GUY,SND_MUSICOFF,A_TAB_SOUNDZ,SET_FLPS
**
**	End of gxglo.h
**

	.DEF	ROPE_BRIDGE,BRIDGE_STATE,KER_SND_TAB
	.DEF	KERRI_GUNVECT,FLAMBUSH_CVECT,A_Unlink_Enemy
	.DEF	TRKDR_GUNVECT,TRKDR_CVECT,CURPLYR_ADJ  
	.DEF	MAGDR_GUNVECT,MAGDR_CVECT,NOTICE_DAMAGE,CHECK4_CHEM_DAM
	.DEF	CHECK_ENEMY_DISAB,ENAB3DRS,ENEMY_ZW_MAX
	.DEF	AU_CREATE_BUGEYZ,AU_CREATE_NATIVE,LAST_CHEM_DAMAGE
	.DEF	IN_SECRET,BUB_CVECT,BUB_GUNVECT,HONEY_DESTROY  
	.DEF	MACH_FIRE,GLOW_BLUE,AU_CREATE_BUSHGUY,AU_CREATE_TREEGUY
	.DEF	RUSTLE_GUNVECT,RUSTLE_CVECT,BIG_EXPLOSIONS,KER3RUN
	.def	TTOP4_CVECT,TTOP4_GUNV,LILP2_CVECT,LILP2_GUNV,S_INIT_NATIVES
	.def	PALM_GUNVECT,RUSTLE2_GUNVECT,MAX_SPEARS_ALLOWED
	.DEF	KERRI_RUNAWAY_ANIM

	.ref	SKY_SND_TAB,FRG_GL_10	; from gxjungle
	.REF	METAL_DR_GUNVECT
	.ref	CHECK_HOST_ANIM	; from gxnonboy
	.ref	THROW_CD_WARREN	; from gxpower
	.ref	A_Set_LOOP_STRT	; from gxafunc
	.REF	SUCK_ME_IN,BLOW_GLASS_OUT	; scroll table in gxscrol2

**** from GXAFUNC.ASM
	.REF	A_CREATEP_R, A_BRANCH_IF_FALSE, A_Set_Rel_Long, A_SET_OXVEL
	.REF	A_SOUNDZ, A_PreFrag_Center, A_INIT_AnimSLP

**** from GXRAM.ASM
	.REF	NUM_SPEARS,ENEMY_QUOTA

**** from GXBZERK.ASM
	.REF	PROC_BZERK_HEADON_OFFSET

**** from GXD.ASM
	.REF	GET_SHAD_MULTI

***** from GXMONDR2.ASM
	.REF	A_SPAWN_PROJECTILE, NSPEAR_INIT

***** from GXNONBOY.ASM
	.REF	N_CHUNK

***** from GXUNIV1.ASM
	.REF	BOX_CHECK_OBJ

***** from GXBLOOD.ASM
	.REF	BLOODY_BULLET_HIT, A_BLOOD_SPLORCH, A_SBOMB_BLOOD

	.bss	LAST_CHEM_DAMAGE,32	; when last chem damage occured
	.bss	LAST_SPEAR_IRQ,32 ; When did he throw it?
	.bss	ENEMY_ZW_MAX,32		; Max ZW that enemy can exist
	.bss	IN_SECRET,16	; 1 if you are in a secret room, else 0
	.bss	ENAB3DRS,16	; if non-zero, collision with doors ok to process
	.bss	LAST_SPEAR_X,16	; DAG of native who threw last spear
	.bss	MAX_SPEARS_ALLOWED,16	; how many spears allowed?
	.bss	BRIDGE_STATE,16	; for rope bridge
	.bss	filler,16	; to keep long word aligned


**********************************************************************
*
*                       ROPE_BRIDGE
*
**********************************************************************
; 
;	BRIDGE_STATE - a 1 indicates a pile that is destroyed
;
;	bits   3        2         1           0
;           far lft  far rt   close lft    close rt
;
ROPE_BRIDGE:
	move	@BRIDGE_STATE,a0
	movk	1,a3			;  a bit
	move	*a8(OXVAL),a1,L
	move	@XBASE,a2,L
	sub	a2,a1			; pile world X
	jrnn	onrt
	sll	1,a3			; shift bit if pile is on right
onrt:
	move	*a8(OZVAL),a1,L
	cmpi	-20000h,a1
	jrlt	close
	sll	2,a3
close:
	or	a3,a0
	move	a0,@BRIDGE_STATE
	move	a0,a1
	srl	2,a0
	movk	1,a9			; signal FAR fall
	cmpk	3,a0
	jreq	MakeItFall
	sll	30,a1
	srl	30,a1
	neg	a9			; signal NEAR fall
	cmpk	3,a1
	jrne	SkipFall
MakeItFall:
	CREATEP	PID_IND,ROPE_BRIDGE_FALL_PROC
SkipFall:
	rets

SND_BRIDGE_OUT
	.word	0f380h,248,8555h,0

ROPE_BRIDGE_FALL_PROC:
	SOUND1	SND_MUSICOFF
	
	sleep	4

	SOUND1	SND_BRIDGE_OUT

	clr	a0
	dec	a0
	move	a0,@BRIDGE_STATE	; neg means it's going down

	movi	(3<<BIT_ID)|(OID_UNIV & ~MASK_SUPP),a10		; LOG ID
	movi	(4<<BIT_ID)|(OID_UNIV & ~MASK_SUPP),a11		; PILE ID
	move	a9,a9
	jrn	fwd_loop


bak_loop:
	movi	MASK_SUPP,a3
	clr	a2			; found count
bak_srch:
	move	*a8(OBLINK),a8,L
	cmpi	FGLIST,a8
	jreq	end_srch
	move	*a8(OID),a0
	andn	a3,a0
	cmp	a0,a10			; is it a log?
	jreq	bgotalog
	cmp	a0,a11
	jrne	bak_srch
*
*	end search with far pile
*
	move	*a8(OZVAL),a14,L
	cmpi	-20000h,a14
	jrgt	bak_srch

	jruc	end_srch

bgotalog:
	callr	TOSS_LOG
	cmpk	2,a2
	jrlt	bak_srch
	sloop	2,bak_loop


fwd_loop:
	movi	MASK_SUPP,a3
	clr	a2			; found count
fwd_srch:
	move	*a8,a8,L
	move	*a8(OID),a0
	andn	a3,a0
	cmp	a0,a10			; is it a log?
	jreq	fgotalog
	cmp	a0,a11
	jrne	fwd_srch
*
*	end search with far pile
*
	move	*a8(OZVAL),a14,L
	cmpi	-20000h,a14
	jrlt	fwd_srch

end_srch:
	movi	END_JUNGLE,a0
	calla	CHNG_SCRL_TBL
	DIE

fgotalog:
	callr	TOSS_LOG
	cmpk	2,a2
	jrlt	fwd_srch
	sloop	2,fwd_loop
	

TOSS_LOG:
	calla	BG_TO_FG
	MOVIM	-2c000h,*a8(OYVEL),L
	MOVIM	1c00h,*a8(OYACCEL),W
	CREATE	PID_IND,OFFSCRN_DELETE
	inc	a2
	rets


OFFSCRN_DELETE:
	sleep	25
	move	*a8(OFLAGS),a14
	btst	B_OFSCRN,a14
	jrz	OFFSCRN_DELETE
	calla	DELETE_OBJ
	DIE


********************************************************
*
*                       BUBBLER
*
********************************************************

BUB_CVECT
	WWL	OID_PROCKET,~MASK_PLAYER,UNIV_ROCKET_COLL
	WWL	OID_PEXPLOSION,~MASK_PLAYER,BUB_COLLVECT
	WL	0,DUMCRETS


BUB_COLLVECT:
	CALLA	UNIV_COLL_CHECK
	JRNZ	BUB_DONE

	MOVE	*A0(OID),A0,W			;GET PLAYER DATA ADDRESS
	CALLA	POID_TO_PDATA
	movi	M_NOMORE|M_NEXTFRM,a7
	jruc	bub_hk

BUB_GUNVECT:
	MOVI	M_NOMORE|M_FLASHOBJ,A7
bub_hk:
	MOVI	100,A5		       
	CLR	A9				;NO OFFSET
	CALLA	UNIV_DAMAGE_HANDLER
	jrc	bigexpsnd

	move	a10,a10
	jrz	BUB_DONE

	SOUNDZ	SND_LAVA_CRACK
BUB_DONE:
	rets
*
*	reached last frame
*
bigexpsnd:
	callr	NOTICE_DAMAGE

	MOVI	1000,A1
	CLR	A9
	CALLA	PRINT_SCORE

	PUSH	a8		
	MMTM	SP,B1,B2,B4,B5,B6,B8,B9,b10
	movi	BUBSPLSH_INIT,b0
	calla	MULTIMAKE	; splash in a8
	MMfM	SP,B1,B2,B4,B5,B6,B8,B9,b10
	jrz	BUBX
	move	*sp,a0,L	; orig in a0 (and still on stack)

	move	*a0(OXVAL),*a8(OXVAL),L
	move	*a0(OYVAL),*a8(OYVAL),L
	move	*a0(OZVAL),a1,L
	addk	3,a1
	calla	STORE_ZVAL
	move	*a8(OPARTS),a14,L
	move	*a8(OXVAL),*a14(OXVAL),L
	move	*a8(OYVAL),*a14(OYVAL),L

	calla	INSERT_OBJ

	movi	BUBDAMP,a11	  
	CREATE	PID_IND,BUB_SHATTER_PROC	; do frags and bubbles

BUBX:
	PULLQ	a8
	RETS


BUB_SHATTER_PROC
	SOUNDZ	SND_LAVA_SHATTER  
	jauc	LAVA_SHATTER_HOOK


SND_LAVA_CRACK
	.WORD	0E344H,47,0A32BH,0

SND_LAVA_SHATTER
	.WORD	0F346H,64,0A316H,0


BUBSPLSH_INIT
	.byte	2,0,0,1
	.long	BUBDAMP
	.word	OID_JUNK,0
	LWWWW	LAVADAM2,DMAWNZ,0,0,OM_ANIM
	.long	BUBSPLSH
	LWWWW	LAVADAM2,DMAWNZ|M_FLIPH,0,0,0


BUBSPLSH:
   LWLL   LAVADAM2,1|AMulti|AFunc,A_CHANGE_PAL+2,BUBDAMP
   LWLL	LAVADAM2,6|AFunc,A_CHANGE_PAL+2,BUBDAMP

   LW   LAVADAM3,1|AMulti
   LW	LAVADAM3,5

   LW   LAVADAM4,1|AMulti
   LW	LAVADAM4,4

   LW   LAVADAM5,1|AMulti
   LW	LAVADAM5,4

   LW   LAVADAM6,1|AMulti
   LW	LAVADAM6,4

   LWL   1,1|AFunc,DELETE_OBJ


*========================================================================


TRKDR_CVECT
	WWL	OID_PROCKET,~MASK_PLAYER,UNIV_ROCKET_COLL
	WWL	OID_PEXPLOSION,~MASK_PLAYER,TRKDR_COLLVECT
	WL	0,DUMCRETS

MAGDR_CVECT
	WWL	OID_PROCKET,~MASK_PLAYER,UNIV_ROCKET_COLL
	WWL	OID_PEXPLOSION,~MASK_PLAYER,MAGDR_COLLVECT
	WL	0,DUMCRETS


TRKDR_COLLVECT:
	CALLA	UNIV_COLL_CHECK
	JRNZ	TRKCX
	MOVE	*A0(OID),A0,W			;GET PLAYER DATA ADDRESS
	CALLA	POID_TO_PDATA

TRKDR_GUNVECT:
	move	@ENAB3DRS,a14
;	jrz	TRKCX
	JRZ	TGV_SND
	movi	TRICK_DRSW,a1
	calla	STRT_ANIM
	CLRM	@ENAB3DRS,W
TGV_SND
	JAUC	METAL_DR_GUNVECT
TRKCX:
	rets



MAGDR_COLLVECT:
	CALLA	UNIV_COLL_CHECK
	JRNZ	MAGCX
	MOVE	*A0(OID),A0,W			;GET PLAYER DATA ADDRESS
	CALLA	POID_TO_PDATA

MAGDR_GUNVECT:
	move	@ENAB3DRS,a14
;	jrz	MAGCX
	JRZ	MGV_SND

	MOVE	@ENEMY_QUOTA,A14,W
	JRZ	MD_OPEN_EASY			;BR = We are not done

	MOVI	[-77, 24],A3
	MOVI	[-72, 46],A4
	CALLA	BOX_CHECK_OBJ
	JRZ	MGV_SND				;BR = Not the latch

MD_OPEN_EASY
	movi	MAGIC_DRSW2,a1
	calla	STRT_ANIM
	CLRM	@ENAB3DRS,W
MGV_SND
	JAUC	METAL_DR_GUNVECT
MAGCX:
	rets



TRICK_DRSW:
   LWLL DOORSWING1,1|AFunc,A_SOUND+2,SND_UNLATCH
   LW   DOORSWING2,4
   LW   DOORSWING3,4
   LW   DOORSWING4,4
TRICK_SUPRISE
	LWLWL	DOORSWING5,30|AFunc,A_CREATEP_R+9,PID_BZERK,PROC_BZERK_HEADON_OFFSET
	.LONG	[0,0],0,2
   LW   DOORSWING4,4
   LW   DOORSWING3,4
   LWLL DOORSWING2,4|AFunc,A_SOUND+2,SND_LATCH
   LWL  DOORSWING1,1|AFunc,ENABLE_3DOORS
   LWL  1,1|AFunc,PULL_ANIM



MAGIC_DRSW2:
   LWLL   DOORSWING1,1|AFunc,A_SOUND+2,SND_UNLATCH
   LW   DOORSWING2,4
   LW   DOORSWING3,4
   LW   DOORSWING4,4
;   LWLL   DOORSWING5,3|AFunc,A_CHNG_SCRL_TBL+2,SUCK_ME_IN
   LWLLL	DOORSWING5,1|AFunc,A_BRANCH_IF_FALSE+4,ENEMY_QUOTA,TRICK_SUPRISE
   LWLL   1,3|AFunc,A_CHNG_SCRL_TBL+2,SUCK_ME_IN
   LWL  1,1|AFunc,PULL_ANIM

SND_UNLATCH
	.WORD	0F320H,28,0A45AH,0
SND_LATCH
	.WORD	0F320H,16,0A45DH,0

DISABLE_3DOORS:
	CLRM	@ENAB3DRS,W
	rets

ENABLE_3DOORS:
	MOVKM	1,@ENAB3DRS,W
	rets



***********************************************
*
*	Bug Eyes in Honeycombs
*
***********************************************


BUGEYE_INIT
	.long	bugeye1
	.word   DMAWNZ,M_MANSCALE|M_NOPIXSCAN,OM_GUNV | OM_OID | OM_COLL
	.word	OID_BUGBOY	; OID
	.long	BUGI_CVECT	; COLL
	.LONG	DUMRETS		; GUNV

FEYBUG:
	.word	 16
	.word	00H,0400H,0400H,0400H,0400H,0400H,0400H,0400H
	.word	0400H,0400H,0400H,0400H,0400H,0400H,0400H,0400H


STSCL	.set	370h		; start scale for bugeye
SCLCHG	.set	18		; chg to scale each iteration
SCLIT	.set	26		; number of iterations to change
SCLLIM	.set	STSCL-((3*SCLCHG*SCLIT)/4)


BUGI_CVECT:
	WL	0,DUMCRETS

BUGI_GUNVECT:
;	move	*a8(OIHOFF),a3,W
;	jrnz	BUGIX
;	move	*a8(OSCALE),a3,W
;	cmpi	SCLLIM,a3
;	jrgt	BUGIX			; if bugeye not big...
					;  ignore hit


	move	*a8(OGenObj),a9,L	; obj that generated me.
	.if DEBUG
	jrz	$
	.endif

	clr	a14
	move	a14,*a9(UEGenObj),L	; let it create another

	move	*a8(ODATA+40h),a0,L
	jrz	noflsh
	.if	DEBUG
	jrn	$
	.endif
	move	a14,*a8(ODATA+40h),L
	move	a14,*a0(ODATA+40h),L

	move	a14,*a8(OGUNVECT),L
	calla	DELOBJ			; delete flash

	move	*a8(OZVAL),a10,L
	move	*a8(OXVAL),a9,L
	sra	12,a9
	move	*a8(OYVAL),a11,L
	sll	4,a11
	movx	a9,a11
	movi	[30,200],a9	; point on screen powerup heads to
	CREATE	PID_IND,THROW_CD_WARREN
	clr	a14
noflsh:
*
*	Throw out some splooge
*
	SOUND1	SND_GOOSH

	movi	DEDBUG_INIT,b0
	calla	EASYMAKE
	jrz	sploog_abt
	move	*a8(OXVAL),*a0(OXVAL),L
	move	*a8(OYVAL),*a0(OYVAL),L
	move	*a8(OZVAL),a14,L
	dec	a14
	move	a14,*a0(OZVAL),L
	MOVIM	-0c0h,*a0(OZVEL),L
	movim	2000h,*a0(OYACCEL),W
	calla	INSOBJ
sploog_abt:
	move	*a8(OPLINK),a0,L
	jrz	nokill
	move	a14,*a8(OPLINK),L
	calla	KILL
nokill:
	calla	DELETE_OBJ
	move	@NUM_OUT_THERE,a14
	dec	a14
	move	a14,@NUM_OUT_THERE	; dec eye count

BUGIX:
	rets

AU_CREATE_BUGEYZ:
	move	*a8(UEGenObj),a14,L	; Am I linked to an object?
	jrnz	CRE_BUGI_DONE		; If so, don't gen another
	CALLA	CHECK_HOST_ANIM
	JRC	CRE_BUGI_DONE		;BR=HOST ANIM OFF SCREEN
	move	@HOLD_ENEMY_DISPATCH,a14
	jrnz	CRE_BUGI_DONE

	move	@OBJENEMIES,a14
	btst	B_OF_HONEY,a14
	jrz	CRE_BUGI_DONE

	movi	BUGEYE_INIT,B0
	calla	EASYMAKE
	JRZ	CRE_BUGI_DONE	;BR = No object created

	calla	DELPAL		; need a unique pal.

	move	a8,*a0(OGenObj),L	; link generating object
	move	a0,*a8(UEGenObj),L      ; and generated object

	clr	a14
	move	a14,*a0(ODATA+40h),L	; no gun flash yet

	move	a8,a9
	move	a0,a1
	CALLA	GETAFARG_LONG		;GET Y:X pixel offset
	move	a1,a8
	move	a0,a1
	sext	a0		; X
	sra	16,a1		; Y
	sll	15,a0		; convert from pixel to world
	sll	15,a1		; convert from pixel to world

	MOVE	*A9(OCTRL),A10,W
	btst	B_FLIPH,a10	; adjust offset for flipped univ blocks
	jrz	negh
	neg	a0
negh:
	btst  	B_FLIPV,a10
	jrz	negv
	neg	a1
negv:

	move	*a9(OXVAL),a14,L
	add	a0,a14
	move	a14,*a8(OXVAL),L
	move	*a9(OYVAL),a14,L
	add	a1,a14
	move	a14,*a8(OYVAL),L
	move	*a9(OZVAL),a14,L
	subk	3,a14
	move	a14,*a8(OZVAL),L

	move	*a9(UENumber),a5	; num recreations
	inc	a5
	move	a5,*a9(UENumber)

	movi	EYBUG,a0
	calla	GET_SPARE_PAL
	MOVE	A0,*A8(OPAL),W		;STORE THE NEW PALETTE
	movi	EYBUG,a0
	movi	FadeBlak,A11
 	calla	FADE_ONE

	movi	260h,a5
	calla	SET_SCALE_MANUAL

	move	a8,a0
	calla	INSOBJ

	CREATE	PID_IND,MON_BUGEYE
	move	a0,*a8(OPLINK),L


CRE_BUGI_DONE:
	rets

FadeBlak: .word	0,0FFFFh

DEDBUG_INIT:
	.long	BGSPLAT1
	.word	DMAWNZ,0,OM_ANIM
	.long	DEDBUG_ANIM

DEDBUG_ANIM:
	LWL	BGSPLAT1,7|AFunc,SEND_OUT_BUG_PARTS
	LW	BGSPLAT2,7
	LW	BGSPLAT3,6
	LWL	1,1|AFunc,DELETE_OBJ

SEND_OUT_BUG_PARTS:
	movi	30000h,a0
	movi	100h,a3
	calla	PreFrag_Center
	sub	b10,b9
	clr	b10
	MOVI	FRG_BUGPARTS,B14
	calla	Fragger
	rets

SND_GOOSH  .word	0f3c8h,30,0a14dh,100,081c8h,0		

FRG_BUGPARTS:
	.long	BUGLEG_ANIM,0
	.word	OID_JUNK,(2 << 11) + (1 << 6) + (FRGPAL)
	.long	BUGSPIT_ANIM,0
	.word	OID_JUNK,(3 << 11) + (1 << 6) + (FRGPAL)
	.long	BUGDROP_ANIM,0
	.word	OID_JUNK,(3 << 11) + (1 << 6) + (FRGPAL)
	.long	0

BUGLEG_ANIM:
	LW	BGLEGs1,6
	LW	BGLEGs2,6
	LW	BGLEGs3,6
	LW	BGLEGs4,6
	LW	BGLEGs6,6
	LWL	BGLEGs7,6|AFunc,A_OFFSCRN_DEL
	.long	0


BUGSPIT_ANIM:
	LW	SPIT4,2
	LW	SPIT5,2
	LW	SPIT6,2
	LW	SPIT7,2
	LW	SPIT6,2
	LWL	SPIT5,2|AFunc,A_OFFSCRN_DEL
	.long	0

BUGDROP_ANIM
	LWL	BGDROP1,30|AFunc,A_OFFSCRN_DEL
	.long	0


*
*	a8 = BUGEYE obj 
*	a9 = BG OBJ that created it
MON_BUGEYE:
	RANDSLP	2,9

	move	*a8(OGenObj),a0,L	; get enemy generator
	move	*a0(OCTRL),a14
	btst	B_INUSE,a14		; did generator get deleted?
	jrz	MB_DELETE
	move	@OBJENEMIES,a14		; did this get disabled?
	btst	B_OF_HONEY,a14
	jrz	MB_DELETE
	MOVE	*A8(OFLAGS),A14		; ARE WE ON SCREEN?
	BTST	B_OFSCRN,A14
	JRNZ	MB_wait			; IF NOT, DON'T TRY TO FADE IN


	callr	CAN_I_CREATE
	jrnc	MB_wait
	move	@NUM_OUT_THERE,a0
;	cmpk	8,a0
;	jrge	MB_wait			; too many, wait some more
	inc	a0
	move	a0,@NUM_OUT_THERE

	movi	BUGI_GUNVECT,a14
	move	a14,*a8(OGUNVECT),L	; shootable

	movi	EYBUG,a0
	movi	IFadeIn,A11
 	calla	FADE_ONE

	movi	STSCL,a11
	movk	SCLIT,a10
grow_lp:
	sleep	2
	subk	SCLCHG,a11
	move	a11,*a8(ONuManScl)
	ANDNIM	M_NOSCALE,*a8(OFLAGS),W
	dsjs	a10,grow_lp

	move	*a8(OGenObj),a0,L	; get enemy generator
	move	*a0(OCTRL),a14
	btst	B_INUSE,a14		; did generator get deleted?
	jrz	MB_DELETE_A		; dec count and delete

	move	*a8(OFLAGS),a14		; IF OFSCRN, DON'T SHOOT
	btst	B_OFSCRN,a14
	jrnz	no_shoot

;	movb	@NUM_OUT_THERE+8,a0
;	move	@CURPLYRS,a1
;	addk	2,a1
;	cmp	a1,a0
;	jrge	no_shoot
;	inc	a0
;	movb	a0,@NUM_OUT_THERE+8	; write hi byte (spit count)
	
	movk	3,a1
	movk	8,a0
	calla	RANGRAND	; number of iterations of flashing
	move	a0,a5
	movi	[8,0],a4	; offset of gun flash
	calla	EGUN_FLASH

;	CREATE	PID_IND,LAUNCH_SPIT


wait_for_eoflash:
	sleep	8
	move	*a8(ODATA+40h),a14,L
	jrnz	wait_for_eoflash

;	sleep	90		; time eyes are up full


shoot_hook:
	move	a11,a10		; save ending scale
	movi	EYBUG,a0
	movi	IFadeOut,A11
 	calla	FADE_ONE

	MOVE	@NUM_OUT_THERE,a0	; dec before shrink starts
	dec	a0
	move	a0,@NUM_OUT_THERE

	movi	DUMRETS,a14		;
	move	a14,*a8(OGUNVECT),L	; not shootable

	move	a10,a11
	movk	SCLIT,a10
shrnk_lp:
	sleep	2
	addk	SCLCHG,a11
	move	a11,*a8(ONuManScl)
	ANDNIM	M_NOSCALE,*a8(OFLAGS),W
	dsjs	a10,shrnk_lp

	move	*a8(OGenObj),a0,L	; get enemy generator
	move	*a0(OCTRL),a14
	btst	B_INUSE,a14		; did generator get deleted?
	jrnz	MB_DELETE

MB_wait
	jruc	MON_BUGEYE

no_shoot:
	sleep	10
	jruc	shoot_hook


*
*	If this section done...
*
MB_DELETE_A:
	move	@NUM_OUT_THERE,a0	; dec before shrink starts
	dec	a0
	move	a0,@NUM_OUT_THERE
MB_DELETE:
	clr	a14
	move	a14,*a0(UEGenObj),L	; no object here
lose_me:
	clr	a14
	move	a14,*a8(OPLINK),L	; gonna die now
	calla	DELETE_OBJ
	DIE


IFadeIn	.word	8,16,24,32,40,48,56,64,72,80,88,96,104,112
	.word	120,128,0FFFFh

;IFadeIn	.word	5,10,15,20,25,30,35,40,45,50,55,60,65,70,75,80,85,90,95,100
;	.word	105,110,115,120,128,0FFFFh


;IFadeOut .word	120,115,110,105,100,95,90,85,80,75,70,65,60,55,50,40
;	.word	35,30,25,20,15,10,5,0,0FFFFh

IFadeOut .word	128,120,113,106,100,94,86,78,72,66,60,54,48,42
	.word	36,30,24,18,12,6,0,0FFFFh

*
*	called from COLL routine when rocket smashes honeycomb
*
HONEY_DESTROY:
	move	@OBJENEMIES,a14		; is this section done?
	btst	B_OF_HONEY,a14		; ignore this if we're moving on
	jrz	Ubozo2			; ignore this if we're moving on
	mmtm	sp,a0,a8

	calla	UNIV_DISAB_ENEMY_GEN
	move	*a8(UEGenObj),a1,L	; are we connected to a bug?
	jrz	HD_nobug

	move	*a1(OGUNVECT),a14,L
	jrz	HD_notout
	cmpi	DUMRETS,a14		;
	jreq	HD_notout		;
	move	@NUM_OUT_THERE,a14
	dec	a14
	move	a14,@NUM_OUT_THERE
HD_notout:

	move	*a1(ODATA+40h),a0,L
	jrz	HD_noflsh
	LOCKON	N
	clr	a14
	move	a14,*a1(ODATA+40h),L
	move	a14,*a0(ODATA+40h),L

	move	a14,*a1(OGUNVECT),L
	calla	DELOBJ			; delete flash

HD_noflsh:
	move	*a1(OPLINK),a0,L
	jrz	HD_nokill
	clr	a14
	move	a14,*a1(OPLINK),L
	calla	KILL
HD_nokill:
	move	a1,a8
	calla	DELETE_OBJ		; delete bug

HD_nobug:
	move	@ENAB3DRS,a14
	inc	a14
	move	a14,@ENAB3DRS

	cmpk	25,a14
	jrlt	Ubozo		; not into the secret room
*
* 	ENTER STAINED GLASS ROOM  ---  YAH! INTO DA SECRET ROOM WITH YE!
*
	movi	BLOW_GLASS_OUT,a0
	calla	CHNG_SCRL_TBL
Ubozo:
	mmfm	sp,a0,a8
Ubozo2:
	rets	


*
*	Disable enemy if a particular word is false
*
*
CHECK_ENEMY_DISAB
	calla	GETAFARG_LONG
	move	*a0,a14
	jrnz	CED_keepon
	calla	UNIV_DISAB_ENEMY_GEN
CED_keepon:
	rets


**************************************************************************
*								         *
* FREE KERRI								 *
*								         *
**************************************************************************
KERRI_GUNVECT:
* PASS:									 
* A2 = PTR TO PLAYER						         
* A8 = PTR TO OBJECT							 
* A1 = DAG of kerri
*
	movi	0fff0fffh,a4
	move	*a8(OZVAL),a3,L
	move	@ZBASE,a14,L
	sub	a14,a3		; world Z
	cmpi	014000h,a3	; won't work if she's too far away
	jrge	free_kerri_X

	move	*a2(PCURSORXY),a7,L	; where did we hit her?
*
*	compute valid box  (top 1/8 in Y) (center 1/4 in X)
*
	move	*a8(OSIZE),a5,L
	srl	2,a5		; 1/4 size y and x in a5
	move	a5,a3
	srl	1,a3		; 1/8 size y and x in a3
	zext	a5
	movy	a3,a5		; offset top by 1/8 y
	and	a4,a5
	and	a4,a3
	addxy	a5,a1		; shift origin by 1/4 X	& 1/8 y
	zext	a3		; 1/8 X in a3
	addxy	a3,a1		; shift origin by addl 1/8 X
	addxy	a1,a5		; lower right
*
*	POINT INSIDE A BOX COLLISION
*
*	a7 = point
*	a1 = upper left,  box
*	a5 = lower right, box
*
	cmpxy	a7,a1
	jrxgt	free_kerri_X
	jrygt	free_kerri_X
	cmpxy	a5,a7		
	jrxgt	free_kerri_X	
	jrygt	free_kerri_X
*
*	She is free	
*
	movi	8000,a1
	move	@IN_SECRET,a14		; is she worth more?
	jrz	notsecret
	movk	15,a1
	calla	PROCK_AWARD		; give bombs for freeing her
	MOVI	40000,A1
notsecret:
	CALLA	PRINT_SCORE
	calla	BG_TO_FG
	CLRM	*a8(OGUNVECT),L	; can't hit her no more
	movi	kerfree,a1
	move	a1,*a8(AnimFrm),L
	move	a1,*a8(AnimScr),L
	MOVKB	1,*a8(AnimSlp)

	move	*a8(OZVAL),a14,L
	subk	4,a14
	move	a14,*a8(OZVAL),L

	CALLA	PLAYER_AWARD_GIRL
free_kerri_X:
	rets

kerfree:
	LWLL	KERSHT2,6|AFunc,A_CHANGE_PAL+2,KSTRES_P
	LW	KERSHT3,6
	LW	KERSHT4,6
	LW	KERSHT5,6
	LW	KERSHT6,6
	LW	KERSHT7,6
	LW	KERSHT8,5
	LW	KERSHT9,4
	LW	KERSHT10,25

KERRI_RUNAWAY_ANIM
	LWLL	TRANS1,2|AFunc,A_RAND_HFLIP_CHANGE_PAL+2,KSTRES_P
	LWLLW	1,1|AFunc,A_TAB_SOUNDZ+3,KER_SND_TAB,6
	LWLLL	TRANS2,4|AFunc,A_RAND_OXVEL+4,24000h,38000h
	LWL	TRANS3,4|AFunc,A_Set_LOOP_STRT
KER3RUN:
   LWLL   RN3J01,4|AFunc,A_DEL_ZW_GT+2,1c000h
   LW     RN3J02,4
   LW     RN3J03,4
   LWLL   RN3J04,4|AFunc,A_DEL_ZW_GT+2,1c000h
   LW     RN3J05,4
   LWL    RN3J06,4|AFunc,A_OFF_KILL_OBJ
   .long  0

A_RAND_HFLIP_CHANGE_PAL
	CALLA	A_CHANGE_PAL
	JAUC	A_RAND_HFLIP

SND_THANK_YOU
	.WORD	0E2a4H,47,0A532H,0
SND_FREE_AT_LAST
	.WORD	0E2a4H,79,0A53BH,0
SND_BEST
	.WORD	0E2a4H,80,0A547H,0

SND_MYHERO
	.WORD	0E2a4H,82,0A54aH,0


KER_SND_TAB
	.long	SND_THANK_YOU,SND_FREE_AT_LAST,SND_THANK_YOU
	.long	SND_BEST,SND_THANK_YOU,SND_MYHERO


*
*	DELETE if Z world is greater than
*
*  	  This parameter can be an immediate value supplied		 *
*  	  in the animation OR						 *
*  	  you can supply an ADDRESS in the animation and the 		 *
*  	  desired Z will be taken from that address!			 *					     
*								         *
A_DEL_ZW_GT:
	calla	GETAFARG_LONG
	cmpi	10000000h,a0
	jrlt	assum_val
	move	*a0,a0,L	; if address, get target Z
assum_val:
	move	@ZBASE,a1,L
	move	*a8(OZVAL),a2,L
	sub	a1,a2
	cmp	a0,a2
	jagt	DELETE_OBJ_PROC
	rets


****************************************
*
*	LEAF / RUSTLE
*
****************************************


FRG_LF_4:
	.long	LEAFA_ANIM,L_STUFF
	.word	OID_JUNK,(1 << 11) + (1 << 6) + (FRGPAL|FRGGCOL)
;	.long	LEAFB_ANIM,L_STUFF
;	.word	OID_JUNK,(1 << 11) + (1 << 6) + (FRGPAL|FRGGCOL)
;	.long	LEAFA_ANIM,L_STUFF
;	.word	OID_JUNK,(1 << 11) + (1 << 6) + (FRGBOG|FRGPAL|FRGGCOL)
;	.long	LEAFB_ANIM,L_STUFF
;	.word	OID_JUNK,(1 << 11) + (0 << 6) + (FRGBOG|FRGPAL|FRGGCOL)
	.long	0

LEAF_COLL
	WWL	OID_GRND,0FFFFH,DELETE_OBJ
	WL	0,DUMCRETS

L_STUFF:
	move	*a0(OZVAL),a14,L
	subk	8,a14
	move	a14,*a0(OZVAL),L
	MOVI	LEAF_COLL,A14
	MOVE	A14,*A0(OCVECT),L	;Set up chunk with Vectors	
	ORIM	M_NOCOLL,*A8(OFLAGS),W	;Keeps CDs from colliding with us
	RETS


A_LF_CHG_OYACCEL:
	move	*a8(OYVEL),a14,L
	jrn	lvalon
	MOVIM	500h,*a8(OYACCEL),W
	CLRM	*a8(OZVEL),L
	move	*a8(AnimFrm),a14,L
	addk	32,a14
	move	a14,*a8(AnimFrm),L
	move	a14,*a8(AnimScr),L
lvalon:
	rets
	

LEAFA_ANIM:
	LWL	LEAFA2,6|AFunc,A_LF_CHG_OYACCEL
	.long	0


LEAFA_ANIM2:
	LW	LEAFA1,10
	LW	LEAFA2,5
	LW	LEAFA3,5
	LW	LEAFA4,5
	LW	LEAFA5,10
	LW	LEAFA4,5
	LW	LEAFA3,5
	LW	LEAFA2,5
	.long	0


LEAFB_ANIM:
	LWL	LEAFB2,6|AFunc,A_LF_CHG_OYACCEL
	.long	0


LEAFB_ANIM2:
	LW	LEAFB1,7
	LW	LEAFB2,6
	LW	LEAFB3,5
	LW	LEAFB4,6
	LW	LEAFB5,7
	LW	LEAFB4,6
	LW	LEAFB3,5
	LW	LEAFB2,6
	.long	0


RUSTLE_CVECT
	WWL	OID_PROCKET,~MASK_PLAYER,UNIV_ROCKET_COLL
	WWL	OID_PEXPLOSION,~MASK_PLAYER,RUSTLE_COLLVECT
	WL	0,DUMCRETS



FLAMBUSH_CVECT
	WWL	OID_PROCKET,~MASK_PLAYER,UNIV_ROCKET_COLL
	WWL	OID_PEXPLOSION,~MASK_PLAYER,FLAMBUSH_COLLVECT
	WL	0,DUMCRETS


LILP2_CVECT:
	WWL	OID_PROCKET,~MASK_PLAYER,UNIV_ROCKET_COLL
	WWL	OID_PEXPLOSION,~MASK_PLAYER,LILP2_COLLVECT
	WL	0,DUMCRETS

TTOP4_CVECT:
	WWL	OID_PROCKET,~MASK_PLAYER,UNIV_ROCKET_COLL
	WWL	OID_PEXPLOSION,~MASK_PLAYER,TTOP4_COLLVECT
	WL	0,DUMCRETS

LILP2_COLLVECT:
	movi	-15<<16,a7		; y offset
	movi	FIRE2_INIT,a6		; flame init table
	jruc	FlmBushHk

TTOP4_COLLVECT:
	movi	-36<<16,a7		; y offset
	movi	FIRE3_INIT,a6		; flame init table
	jruc	FlmBushHk

FLAMBUSH_COLLVECT:
	movi	-13<<16,a7		; y offset
	movi	BURNBUSH_INIT,a6	; flame init table
FlmBushHk:
	CALLA	UNIV_COLL_CHECK
	JRNZ	FLAMBUSH_DONE

	mmtm	a12,a6,a7		; save params for flame

	PUSH	a0
	MOVE	*A0(OID),A0,W			;GET PLAYER DATA ADDRESS
	CALLA	POID_TO_PDATA
	movi	M_NEXTFRM|M_NOMORE,a7	; might be enemy gen
*
*	Set UNIV LINK for correct recreation if we scroll off and on again
*
	move	*a8(OULINK),a3,L
	move	*a3(MAP_IMG),a5,L
	srl	4,a5
	sll	4,a5
	addi	60h,a5	; points to full frame (not skeleton)
	move	*a5,a6,L
	srl	4,a6
	sll	4,a6
	move	*a3(MAP_FLAGS),a4
	btst	B_BF_ENEMY,a4		; is this guy generating enemies?
	jrz	noengen
	ori	M_NOSTOPANIM,a7
*
*	turn into a static enemy generator (no longer damagable)
*
	addk	32,a5			; get to enemy gen 
	move	*a5,a6,L		; a7 is the enemy gen animation
	subi	30h,a6			; have it include an image
	ori	M_IF_DANIM|M_IF_SEQ,a6	; mark it properly
noengen:

	MOVI	0,A5		       
	CLR	A9				;NO OFFSET
	CALLA	UNIV_DAMAGE_HANDLER

	move	a6,*a3(MAP_IMG),L	; set for recreation
*
*	Clr Collisions and Set OID = 0
*
	movi	DUMCRETS,a14
	move	a14,*a8(OCVECT),L
	movi	DUMRETS,a14
	move	a14,*a8(OGUNVECT),L

	andni	M_BF_ID,a4	; clear out OID for recreation
	move	a4,*a3(MAP_FLAGS)
	movi	OID_UNIV&(~SUPP_4),a1
	calla	CHANGE_OID

	SOUNDZ	SND_TREE_TORCH

	mmtm	sp,b0,b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11

	mmfm	a12,a6,a7
	move	a6,b0
	calla	EASYMAKE
	jrz	FLAMBUSH_ABT		; cant make
	move	*a8(OXVAL),*a0(OXVAL),L
	move	*a8(OYVAL),a14,L
	add	a7,a14
	move	a14,*a0(OYVAL),L
	move	*a8(OZVAL),a3,L
	addk	2,a3
	move	a3,*a0(OZVAL),L
	move	*a0(OFLAGS),a14
	ori	M_DBLSCL,a14
	move	a14,*a0(OFLAGS)
	calla	INSOBJ
FLAMBUSH_ABT:
	mmfm	sp,b0,b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11
	PULLQ	a0
FLAMBUSH_DONE	
	rets

SND_TREE_TORCH
	.WORD	0F327H,85,0A33EH,0

;exception:
;	CLRM	*a8(OCVECT),L
;	rets
;
;RUSTLE_COLLVECT:
;	move	*a8(OIMG),a14,L		; which image?
;	cmpi	PALM1top,a14	
;	jreq	exception
	
RUSTLE_COLLVECT:
	CALLA	UNIV_COLL_CHECK
	JRNZ	RUSTLE_DONE

	PUSH	a0
	MOVE	*A0(OID),A0,W			;GET PLAYER DATA ADDRESS
	CALLA	POID_TO_PDATA
	movi	M_LASTFRM|M_NOMORE,a7 	    

	MOVI	0,A5		       
	CLR	A9				;NO OFFSET
	CALLA	UNIV_DAMAGE_HANDLER
	PUSH	a2
*
*	cover replacement with explosion
*
	move	*a8(ODAG),a0,L	; upper left in a1
	move	*a8(OSIZE),a4,L
	addxy	a0,a4		; lower right in a4

	move	*a8(OZVAL),a3,L
	move	a3,a6
	sll	ZFRAC,a3
	move	@ZBASE_HR,a14,L
	sub	a14,a3		; get world Z for computation
	move	a3,a5
	move	a3,a7
	move	a3,a1
	setf	10,1,1

	move	a0,a2		; save Y top in a2
	sext	a0		; screen left in a0
	subi	HALFX,a0
	mpys	a0,a1		; world left in a1
	sra	ZFRAC,a1

	move	a4,a0	
	sext	a0		; screen right in a0
	subi	HALFX,a0
	mpys	a0,a3		; -->	world right in a3
	sra	ZFRAC,a3


	sra	16,a2		; screen Y top in a2
	sra	16,a4		; screen Y bot in a4
	move	@YHALF,a14
	sub	a14,a4
	sub	a14,a2
	mpys	a2,a7		; -->	world Y top in a7
	mpys	a4,a5		; -->	world Y bot in a5
	sra	ZFRAC,a5
	sra	ZFRAC,a7
	move	a1,a4		; -->	world left in a4

	setf	32,0,1

	move	@XBASE,a14,L
	add	a14,a4
	add	a14,a3

	move	@YBASE,a14,L
	add	a14,a5
	add	a14,a7

	subk	8,a6

	PULLQ	a2
	PULLQ	a0
	mmtm	sp,b0,b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11
	PUSH	a0


	movk	4,a10		; num to create
	callr	BIG_EXPLOSIONS	; start some explosions


noexplo:
	PULL	a0
	move	*a0(OXVAL),a5,L
	move	*a0(OYVAL),a7,L

	movi	FIRE3_INIT,b0		; pick one of two fires
	move	@RAND,b14
	btst	6,b14
	jrnz	RCduh
	movi	FIRE2_INIT,b0
RCduh:
	calla	EASYMAKE
	jrz	nofire
       
	move	a5,*a0(OXVAL),L
	move	a7,*a0(OYVAL),L
	move	a6,*a0(OZVAL),L
	calla	INSOBJ

nofire:
	mmfm	sp,b0,b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11


RUSTLE_DONE	
	rets


*
*	start some explosions
*	a3  and a4 form an X range
*	a5  and a7 form a Y range
*	a6 = ZVAL
*	a10 = number of explosions
*	trashes a9
*
BIG_EXPLOSIONS:
	movi	EXPLO_INIT,b0
	calla	EASYMAKE
	jrz	noexplo
	move	a0,a9

	move	a3,a0
	move	a4,a1
	calla	RANGERND
	move	a0,*a9(OXVAL),L

	move	a5,a0
	move	a7,a1
	calla	RANGERND
	move	a0,*a9(OYVAL),L

	move	a6,*a9(OZVAL),L

	move	a9,a0
	calla	INSOBJ

	dsjs	a10,BIG_EXPLOSIONS
	rets



*
*	start fires in damaged control panel parts
*	a8 = object
*
MACH_FIRE:
	movk	2,a9			; number of fires
	move	*a8(OYVAL),a7,L
	subi	6<<15,a7		; Y of first fire in a7
	move	*a8(OZVAL),a6,L
	addk	3,a6			; Z of fires in a6
Mfirelp:
	movi	15<<15,a0
	move	a0,a1
	neg	a1
	calla	RANGRAND		; get random X offset in X
	move	*a8(OXVAL),a5,L
	add	a0,a5			; final X of this fire in a5

	move	@RAND+4,b14		; get a skewed random number
	andi	60h,b14			; turn into an index
	addi	RandFireTab,b14
	move	*b14,b0,L
	calla	EASYMAKE
	jrz	noMfire
       
	move	a5,*a0(OXVAL),L
	move	a7,*a0(OYVAL),L
	move	a6,*a0(OZVAL),L
	calla	INSOBJ

	movi	75<<15,a0
	movi	50<<15,a1
	calla	RANGRAND
	sub	a0,a7		; get Y of next fire
	dsj	a9,Mfirelp

noMfire:
	rets	


RandFireTab:
	.long	FIRE3_INIT,FIRE2_INIT,FIRE2_INIT,FIRE3_INIT



PALM_GUNVECT:
	movi	PalmTopAnim,a1
	jruc	TRchkZ

LILP2_GUNV:
	movi	Lilplant2Anim,a1
	jruc	TRchkZ

TTOP4_GUNV:
	movi	Tree4Anim,a1
TRchkZ:
	move	*a8(OZVAL),a14,L
	move	@ZBASE,a0,L
	sub	a0,a14		; world Z
	cmpi	1c000h,a14	; ignore if furthur in world than this
	jrlt	foundtree2
	rets



RUSTLE2_GUNVECT:
	move	*a8(OZVAL),a14,L
	move	@ZBASE,a0,L
	sub	a0,a14		; world Z
	cmpi	1c000h,a14	; ignore if furthur in world than this
	jrge	notree

	movb	*A8(OFLAGS+B_ANIM-7),A14
	jrn	notree			; already animating
	move	*a8(OIMG),a0,L		; which image?
	movk	5,a1
	cmpi	TREETOP1S,a0	;5
	jreq	foundtree
	inc	a1
	cmpi	TREETOP2S,a0	;6
	jreq	foundtree
	inc	a1
	cmpi	LILPLANT1S,a0	;7
	jrne	notree
	jruc	foundtree


*
*	make bushes rustle
*
RUSTLE_GUNVECT:
	move	*a8(OZVAL),a14,L
	move	@ZBASE,a0,L
	sub	a0,a14		; world Z
	cmpi	1c000h,a14	; ignore if furthur in world than this
	jrge	notree

	movb	*A8(OFLAGS+B_ANIM-7),A14
	jrn	notree			; already animating
	move	*a8(OIMG),a0,L		; which image?
	clr	a1
	cmpi	TREETOP3S,a0	;0
	jreq	foundtree
	inc	a1
	cmpi	BPLANT1S,a0	;1
	jreq	foundtree
	inc	a1
	cmpi	BPLANT2S,a0	;2
	jreq	foundtree
	inc	a1
	cmpi	LILPLANT3S,a0	;3
	jreq	foundtree
	inc	a1
	cmpi	TREEB1CS,a0	;4
	jrne	notree
foundtree:
	sll	5,a1
	addi	RUSSTAB,a1
	move	*a1,a1,L
foundtree2:
	calla	STRT_ANIM

	SOUNDZ	SND_RUSTLE		;Make a little shake sound

	MOVI	030000H,A0
	MOVI	028H,A3
	CLR	A4
;	CALLA	PreFrag_Box
	CALLA	PreFrag_Gun
;	sra	1,b3		; limit X Vel a bit
;	sra	1,b4

	MOVI	-60000H,B3			;MIN X VEL
	MOVI	60000H,B4			;MAX X VEL
	sub	b10,b9		; z alway negative
	movi	-1,b10		
;	sub	b8,b7		; y always negative
;	movi	-18000h,b8
	MOVI	-18000H,B7
	MOVI	-60000H,B8
	MOVI	FRG_LF_4,B14
	CALLA	Fragger


notree:
	rets

END_RUSTLE:
	jauc	PULL_ANIM	; simple case for now

SND_RUSTLE
	.WORD	0F220H,62,0A41FH,0


RUSSTAB:
	.long	Tree3Anim,Bplant1Anim,Bplant2Anim,Lilplant3Anim
	.long	TreeB1CAnim,Tree1Anim,Tree2Anim,Lilplant1Anim


TreeB1CAnim
	LWLW	TREEB1CRS,3|AFunc,A_Set_AnimLoop+1,2
TreeB1CLp:
	LWLWW	TREEB1CS,1|AFunc,A_RAND_AnimSLP+2,2,7
	LW	1,0
	LWLWW	TREEB1CRS,1|AFunc,A_RAND_AnimSLP+2,2,7
	LWLL	1,0|AFunc,A_Anim_DSJ+2,TreeB1CLp
	LWL	TREEB1CS,1|AFunc,END_RUSTLE


Tree1Anim
	LWLW	TREETOP1RS,3|AFunc,A_Set_AnimLoop+1,2
Tree1Lp:
	LWLWW	TREETOP1S,1|AFunc,A_RAND_AnimSLP+2,2,7
	LW	1,0
	LWLWW	TREETOP1RS,1|AFunc,A_RAND_AnimSLP+2,2,7
	LWLL	1,0|AFunc,A_Anim_DSJ+2,Tree1Lp
	LWL	TREETOP1S,1|AFunc,END_RUSTLE

Tree2Anim
	LWLW	TREETOP2RS,3|AFunc,A_Set_AnimLoop+1,2
Tree2Lp:
	LWLWW	TREETOP2S,1|AFunc,A_RAND_AnimSLP+2,2,7
	LW	1,0
	LWLWW	TREETOP2RS,1|AFunc,A_RAND_AnimSLP+2,2,7
	LWLL	1,0|AFunc,A_Anim_DSJ+2,Tree2Lp
	LWL	TREETOP2S,1|AFunc,END_RUSTLE

Tree3Anim
	LWLW	TREETOP3RS,3|AFunc,A_Set_AnimLoop+1,2
Tree3Lp:
	LWLWW	TREETOP3S,1|AFunc,A_RAND_AnimSLP+2,2,7
	LW	1,0
	LWLWW	TREETOP3RS,1|AFunc,A_RAND_AnimSLP+2,2,7
	LWLL	1,0|AFunc,A_Anim_DSJ+2,Tree3Lp
	LWL	TREETOP3S,1|AFunc,END_RUSTLE


Tree4Anim
	LWLW	TREETOP4RS,3|AFunc,A_Set_AnimLoop+1,2
Tree4Lp:
	LWLWW	TREETOP4S,1|AFunc,A_RAND_AnimSLP+2,2,7
	LW	1,0
	LWLWW	TREETOP4RS,1|AFunc,A_RAND_AnimSLP+2,2,7
	LWLL	1,0|AFunc,A_Anim_DSJ+2,Tree4Lp
	LWL	TREETOP4S,1|AFunc,END_RUSTLE


Bplant1Anim
	LWLW	BPLANT1RS,3|AFunc,A_Set_AnimLoop+1,2
Bplant1Lp:
	LWLWW	BPLANT1S,1|AFunc,A_RAND_AnimSLP+2,2,7
	LW	1,0
	LWLWW	BPLANT1RS,1|AFunc,A_RAND_AnimSLP+2,2,7
	LWLL	1,0|AFunc,A_Anim_DSJ+2,Bplant1Lp
	LWL	BPLANT1S,1|AFunc,END_RUSTLE


Bplant2Anim:
	LWLW	BPLANT2RS,3|AFunc,A_Set_AnimLoop+1,2
Bplant2Lp:
	LWLWW	BPLANT2S,1|AFunc,A_RAND_AnimSLP+2,2,7
	LW	1,0
	LWLWW	BPLANT2RS,1|AFunc,A_RAND_AnimSLP+2,2,7
	LWLL	1,0|AFunc,A_Anim_DSJ+2,Bplant2Lp
	LWL	BPLANT2S,1|AFunc,END_RUSTLE

Lilplant1Anim:
	LWLW	LILPLANT1RS,3|AFunc,A_Set_AnimLoop+1,2
Lilplant1Lp:
	LWLWW	LILPLANT1S,1|AFunc,A_RAND_AnimSLP+2,2,7
	LW	1,0
	LWLWW	LILPLANT1RS,1|AFunc,A_RAND_AnimSLP+2,2,7
	LWLL	1,0|AFunc,A_Anim_DSJ+2,Lilplant1Lp
	LWL	LILPLANT1S,1|AFunc,END_RUSTLE


Lilplant3Anim:
	LWLW	LILPLANT3RS,3|AFunc,A_Set_AnimLoop+1,2
Lilplant3Lp:
	LWLWW	LILPLANT3S,1|AFunc,A_RAND_AnimSLP+2,2,7
	LW	1,0
	LWLWW	LILPLANT3RS,1|AFunc,A_RAND_AnimSLP+2,2,7
	LWLL	1,0|AFunc,A_Anim_DSJ+2,Lilplant3Lp
	LWL	LILPLANT3S,1|AFunc,END_RUSTLE


Lilplant2Anim:
	LWLW	LILPLANT2RS,3|AFunc,A_Set_AnimLoop+1,2
Lilplant2Lp:
	LWLWW	LILPLANT2S,1|AFunc,A_RAND_AnimSLP+2,2,7
	LW	1,0
	LWLWW	LILPLANT2RS,1|AFunc,A_RAND_AnimSLP+2,2,7
	LWLL	1,0|AFunc,A_Anim_DSJ+2,Lilplant2Lp
	LWL	LILPLANT2S,1|AFunc,END_RUSTLE


PalmTopAnim:
	LWLW	PALM1topR,3|AFunc,A_Set_AnimLoop+1,2
PalmtopLp:
	LWLWW	PALM1top,1|AFunc,A_RAND_AnimSLP+2,2,7
	LW	1,0
	LWLWW	PALM1topR,1|AFunc,A_RAND_AnimSLP+2,2,7
	LWLL	1,0|AFunc,A_Anim_DSJ+2,PalmtopLp
	LWL	PALM1top,1|AFunc,END_RUSTLE


FIRE2_INIT:
	.long	TFIRE1A
	.word	DMAWNZ,0,OM_ANIM|OM_CFUNC
	.long	FIRE2_Anim
	.long	RAND_HFLIP

FIRE3_INIT:
	.long	TFIRE2A
	.word	DMAWNZ,0,OM_ANIM|OM_CFUNC
	.long	FIRE3_Anim
	.long	RAND_HFLIP

FIRE1_INIT:
	.long	HFIREA1
	.word	DMAWNZ,0,OM_ANIM|OM_CFUNC
	.long	FIRE1_Anim
	.long	RAND_HFLIP

BURNBUSH_INIT:
	.long	BSHBRN1
	.word	DMAWNZ,0,OM_ANIM|OM_CFUNC
	.long	BRNBSHANIM
	.long	RAND_HFLIP


RAND_HFLIP:
	move	a0,a1
	calla	RANDOM			; generate a new RAND
	andi	M_FLIPH,a0		; isolate hflip bit
	move	*a1(OCTRL),a14	
	andni	M_FLIPH,a14		; clear old hflip
	or	a0,a14			; set new
	move	a14,*a1(OCTRL)		;      and store
	move	a1,a0
	rets

	    
EXPLO_INIT:
	.long	FHKEXPLOB1
	.word	DMAWNZ,M_DBLSCL|M_NODISP,OM_ANIM
	.long	BushBlow

BushBlow:
	LWLWW	1,1|AFunc,A_RAND_AnimSLP+2,2,18		; initial delay
	LW	1,0	
	LWLWW	1,1|AFunc,A_RAND_AnimSLP+2,3,7
	LWL	1,1|AFunc,OBJ_ON
	LW	1,0
	LW	FHKEXPLOB2,4
	LW	FHKEXPLOB3,4
	LWLWW	FHKEXPLOB4,1|AFunc,A_RAND_AnimSLP+2,3,7
	LW	1,0
	LW	FHKEXPLOB5,4
	LWLWW	FHKEXPLOB6,1|AFunc,A_RAND_AnimSLP+2,3,7
	LW	1,0
	LW	FHKEXPLOB7,4
	LWLWW	FHKEXPLOB8,1|AFunc,A_RAND_AnimSLP+2,3,7
	LW	1,0
	LW	FHKEXPLOB9,5
	LWLWW	FHKEXPLOB10,1|AFunc,A_RAND_AnimSLP+2,4,10
	LW	1,0
	LW	FHKEXPLOB11,7
	LWL	1,1|AFunc,DELETE_OBJ


******************************
*         FIRES              *
******************************

FIRE2_Anim:
	LW	TFIRE1A,3
	LW	TFIRE1B,3
	LW	TFIRE1C,3
	LW	TFIRE1D,3
	LWL	TFIRE1E,3|AFunc,A_OFFSCRN_DEL
	.long	0


FIRE3_Anim:
	LW	TFIRE2A,3
	LW	TFIRE2B,3
	LW	TFIRE2C,3
	LW	TFIRE2D,3
	LWL	TFIRE2E,3|AFunc,A_OFFSCRN_DEL
	.long	0

FIRE1_Anim:
	LW	HFIREA1,3
	LW	HFIREA2,3
	LW	HFIREA3,3
	LW	HFIREA4,3
	LW	HFIREA5,3
	LWL	HFIREA6,3|AFunc,A_OFFSCRN_DEL
	.long	0


BRNBSHANIM:
   LW   BSHBRN1,3
   LW   BSHBRN2,3
   LW   BSHBRN3,3
   LW   BSHBRN4,3
   LW   BSHBRN5,3
   LW   BSHBRN6,3
   LW   BSHBRN7,3
   LW   BSHBRN8,3
   LW   BSHBRN9,3
   LW   BSHBRN10,3
   LW   BSHBRN11,3
   LW   BSHBRN12,3
   LW   BSHBRN13,3
   LW   BSHBRN14,3
   LW   BSHBRN15,3
   LWL   BSHBRN16,3|AFunc,A_OFFSCRN_DEL
   .long  0


BUBDAMP:
   .word   126
   .word   01ce7h,0329fh,0221fh,0151fh,0151fh,014bfh,02e5fh,02a3fh
   .word   032bfh,01dbfh,014bfh,01ddfh,014bfh,032dfh,014ffh,014bfh
   .word   0159fh,014dfh,014dfh,014bfh,0195fh,0195fh,0153fh,01d7fh
   .word   0195fh,0223fh,01d9fh,03b3fh,029bfh,025dfh,0153fh,036dfh
   .word   014dfh,018dfh,01d7fh,014bfh,0153fh,014ffh,0253fh,0213fh
   .word   014bfh,014dfh,014bfh,0255fh,02e1fh,02a5fh,042dfh,029ffh
   .word   036ffh,03a5fh,0437fh,0155fh,0221fh,029dfh,035dfh,01e3fh
   .word   01ddfh,0151fh,014bfh,01cbfh,01cbfh,03e9fh,0437fh,014bfh
   .word   03a7fh,01d7fh,01cdfh,03f5fh,014bfh,014bfh,014bfh,028bfh
   .word   018bfh,028bfh,024bfh,028ffh,014bfh,014bfh,028bfh,014bfh
   .word   014bfh,015bfh,014bfh,014ffh,014bfh,014bfh,014bfh,0297fh
   .word   0155fh,015bfh,01d1fh,0367fh,014dfh,0155fh,0151fh,028dfh
   .word   0357fh,041ffh,042dfh,042ffh,03e5fh,029ffh,03ddfh,03d3fh
   .word   0417fh,03d7fh,0437fh,0437fh,018bfh,024bfh,028ffh,0419fh
   .word   040dfh,0365fh,0427fh,0419fh,0417fh,034ffh,024bfh,034dfh
   .word   039dfh,014bfh,02a3fh,0429fh,0317fh,0437fh


GLOW_BLUE:
	mmtm	sp,a5,a9
	move	*a0(OPAL),a5
	sll	24,a5
	srl	24,a5		; slot of palette
	move	a5,a9
	sll	6,a5		; since PALRSIZ = 40h
	ADDI	PALRAM,A5
	move	*a5(PALCNT),a14
	cmpk	1,a14		; is this first use of palette?
	jrne	already_glowing
	
	mmtm	sp,a0,a1,a7,a8,a10
	move	*a5(PALID),a8,L
	movk	21,a10
	CREATE	PID_TCYCLE,GLOW_BLUE_PROC
	mmfm	sp,a0,a1,a7,a8,a10
already_glowing:
	mmfm	sp,a5,a9
	rets


**************************************************************
*
*   GLOW_BLUE_PROC  -   make a palette glow BLUE by 
*			increasing its blue
*
*   a8 = PALID				 (passed when created)
*   a9 = palette slot : number of colors (slot passed when created)
*   a10 = CUR : max delta before reversing	 (passed when created)
*   a11 = direction (1 or -1) shifted to upper 6 bits
*
**************************************************************
GLOW_BLUE_PROC:
	movi	1<<26,a11   	; initial delta

	sll	16,a9		; slot # in upper half
	move	a8,a14
	move	*a14+,a5 	; numcols in a5
	movx	a5,a9		; a9 = slot : num_cols

*
*	MAIN LOOP
*
GG_lp1:
*
*	Is palette still allocated?
*
	move	a9,a5
	srl	16-6,a5		; since PALRSIZ = 40h
	ADDI	PALRAM,A5
	move	*a5(PALID),a14,L
	cmp	a14,a8
	jane	SUCIDE		; diff PALID, die
	move	*a5(PALCNT),a14	
	jaz	SUCIDE		; count 0 , die
;;;;	move	*a5(PALTIME),a14
;;;;	janz	SUCIDE		; TIME not zero, die
*
*	adjust palette and set up transfer
*
	move	a8,a6
	addk	16,a6		; pointer to source data
	move	a13,a4
	addi	PDATA+10h,a4	; RAM location of palette's current state
	move	a4,a0		; for PALSET
	move	a9,a5
	zext	a5		; # colors in a5
	clr	a7
	movy	a10,a7		; current delta

GG_lp2:
	move	*a6+,a1
;	move	a1,a2
	move	a1,a3
	sll	32-5,a1		; blue
	srl	1,a1		; leave a sign bit
	add	a7,a1
	jrnn	nosatblue
	move	a7,a1
	sra	31,a1
	not	a1
	srl	1,a1
nosatblue:
	srl	32-6,a1		; final blue

;	sll	32-15,a2	; red
;	srl	1,a2		; leave a sign bit
;	sub	a7,a2
;	jrnn	nosatred
;	move	a7,a2
;	sra	31,a2
;	srl	1,a2
;nosatred:
;	srl	32-6,a2
;	sll	10,a2		; final red

;	add	a2,a1
	andi	03e0h+07c00h,a3
	add	a3,a1
	move	a1,*a4+
	dsjs	a5,GG_lp2

	clr	a1
	clr	a2
	movy	a9,a1		; slot : st color in a1
	srl	8,a1		; slot in bits 8-15
	movx	a9,a2		; num colors in a2
	calla	PALSET
*
*	check direction of glow and adjust if necessary
*
	addxy	a11,a10		; a10 = cur count : max count
	move	a10,a14
	sra	26,a14
	abs	a14
	cmpxy	a10,a14
	jrxne	skpa11adj	; if cur count = max, make a11 neg
adja11:
	neg	a11
skpa11adj:

	sloop	1,GG_lp1


*******************************************************************
*
*		NATIVE GUY
*
*******************************************************************
	.DEF	PROC_RELEASE_NATIVE
	.ref	WORLD_GRNDOFF

*	a9 = UNIV Z
*	a10 = UNIV X enter left
*	a11 = UNIV X enter right
*
PROC_RELEASE_NATIVE:
	MOVI	OID_NATIVE,A0
	CALLA	GET_ENEMY_COUNT
	CMPK	4,A0
	JAHS	SUCIDE

	MOVI	BUSHGUY_INIT,B0		;ALLOCATE OBJECT
	CALLA	CREATE_ENEMY
	JAZ	SUCIDE			;BR = ERROR! ERROR!

	CLRM	*a8(OGenObj),L		; no generating object

	move	a10,a1
	calla	RANDOM
	btst	2,a0
	jrz	PRN_duh
	move	a11,a1
	movi	M_FLIPH,a0
	calla	SET_FLPS
PRN_duh:
	sll	16,a1
	move	@WORLD_GRNDOFF,a2,L
	move	@YWORLD,a14,L
	add	a14,a2
	move	a9,a3			; univ Z
	CALLA	SET_ANIPU

	movi	NATIVE_DEATH,a14
	move	a14,*a8(OEDEATH),L

	CALLA	GET_SHAD_MULTI		;Setup his shadow

	MOVK	1,A14
	MOVB	A14,*A8(OHITS)		;NUMBER OF ALLOWED HITS

	MOVKM	2,*a8(OEFLAGS),W	; mark this guy as different

	calla	INSERT_ENEMY		;INSERT AND COUNT ENEMY

	DIE

S_INIT_NATIVES:
	clr	a14
	move	a14,@NUM_OUT_THERE		; clear counts
	move	a14,@NUM_SPEARS
	move	*a11+,a0
	move	a0,@MAX_ALLOWED			; set maximums
	move	*a11+,a0
	move	a0,@MAX_SPEARS_ALLOWED
	move	@WAVEIRQS,@LAST_SPEAR_IRQ,L
	jauc	SCRL_DISPATCHER



*	creates NATIVES in main corridor leading to Stone wall
*	can be controlled by setting any or all of the following words.
*
*	MAX_ALLOWED		; maximum number of them allowed out there
*	MAX_SPEARS_ALLOWED	; same for spears
*	ENEMY_ZW_MAX		; World Z which they are created at (or less than)
*
AU_CREATE_TREEGUY:
	callr	CAN_I_CREATE
	jrnc	AU_CN_DONE

	move	@OBJENEMIES,a14
	btst	B_OF_TREE,a14
	jrz	AU_CN_DONE

	MOVI	TREEGUY_INIT,B0		;ALLOCATE OBJECT
	callr	CREATE_NATIVE
	jrnc	AU_CN_DONE

	MOVE	*A9(OXVAL),A1,L
	MOVE	*A9(OYVAL),A2,L
	MOVE	*A9(OZVAL),A3,L
	addk	20,a3
	CALLA	SET_ANIPU

	jauc	INSERT_ENEMY		;INSERT AND COUNT ENEMY


*
*	creates NATIVES in main corridor leading to Stone wall
*	can be controlled by setting any or all of the following words.
*
*	MAX_NUM_OUT_THERE	; maximum number of them allowed out there
*	MAX_SPEARS_ALLOWED	; same for spears

JUMPOUT_Z	.set	20000h	; world Z past which they won't jump out

AU_CREATE_NATIVE:
	callr	CAN_I_CREATE
	jrnc	AU_CN_DONE

	move	@OBJENEMIES,a14
	btst	B_OF_CNATV,a14
	jrz	AU_CN_DONE

	move	@XBASE+10h,a14	; can only create these guys when
	subi	2c8h,a14	;  1) XBASE is between 2c8h and 38fh
	cmpi	38fh-2c8h,a14	;  2) SCROLL_FLAG is non-zero
	jrnb	AU_CN_DONE
;	move	@SCROLL_FLAG,a14,L
;	jrz	AU_CN_DONE


	MOVI	CENTER_INIT,B0		;ALLOCATE OBJECT
	callr	CREATE_NATIVE
	jrnc	AU_CN_DONE

	move	a9,*a8(OGenObj),L	; save generating object
	move	a8,*a9(UEGenObj),L

	movi	160000h,a0		; x delta from block to native
	movi	130000h,a1		; x delta from block to native
	calla	RANGRAND

	move	a8,a3			; get head in a3

	MOVE	*A9(OCTRL),A14,W
	andi	M_FLIPH,a14
	jrz	AUCN_flplp
	neg	a0
AUCN_flplp:
	move	*a3(OCTRL),a10
	OR	A14,A10
	MOVE	A10,*A3(OCTRL),W
	move	*a3(OPARTS),a3,L
	jrnz	AUCN_flplp

	MOVE	*A9(OXVAL),A1,L
	add	a0,a1			; get off center a bit
	move	@YWORLD,a2,L
	MOVE	*A9(OZVAL),A3,L
	addk	8,a3
	CALLA	SET_ANIPU

	MOVKM	1,*a8(OEFLAGS),W	; mark this guy as different

	jauc	INSERT_ENEMY		;INSERT AND COUNT ENEMY

*
*	BUSH GUYS are created from bushes on the ground
*
AU_CREATE_BUSHGUY:
	callr	CAN_I_CREATE
	jrnc	AU_CN_DONE

	move	@OBJENEMIES,a14
	btst	B_OF_BUSH,a14
	jrz	AU_CN_DONE

	MOVI	BUSHGUY_INIT,B0		;ALLOCATE OBJECT
	callr	CREATE_NATIVE
	jrnc	AU_CN_DONE

	move	a9,*a8(OGenObj),L	; save generating object
	move	a8,*a9(UEGenObj),L     

	movi	-0e0000h,a3		; delta X for bushguy

	MOVE	@RAND,A14,W		;LEFTY OR RIGHTY?
	ANDI	M_FLIPH,A14
	jrz	adj_xdelta
	neg	a3
adj_xdelta:
	move	a8,a0
AUCB_flplp:
	MOVE	*A0(OCTRL),A10,W
	OR	A14,A10
	MOVE	A10,*A0(OCTRL),W
	move	*a0(OPARTS),a0,L
	jrnz	AUCB_flplp

	MOVE	*A9(OXVAL),A1,L
	add	a3,a1			; get off center a bit
	move	@YWORLD,a2,L
	MOVE	*A9(OZVAL),A3,L
	addk	20,a3
	CALLA	SET_ANIPU

	jauc	INSERT_ENEMY		;INSERT AND COUNT ENEMY

AU_CN_DONE
	RETS
*
*	CREATE_NATIVE - core routine to create tree and bush guys
*			b0 = init table
*	Return:  C set if guy created,  NC if not
*
CREATE_NATIVE:
	move	*a8(OFLAGS),a14
	btst	B_OFSCRN,a14
	JRNZ	CN_leave			;BR=HOST ANIM OFF SCREEN
	move	*a8(OZVAL),a9,L
	move	@ZBASE,a14,L
	sub	a14,a9 			; world Z in a9
	move	*a8(UEGenObj),a14,L	; Am I linked to an object?
	jrnz	CN_leave
	move	@ENEMY_ZW_MAX,a14,L
	cmp	a14,a9
	jrge	CN_leave			; skip if generating obj too far away

	MOVE	A8,A9
	CALLA	CREATE_ENEMY
	JRZ	CN_leave		;BR = ERROR! ERROR!

	movi	NATIVE_DEATH,a14
	move	a14,*a8(OEDEATH),L

	MOVK	1,A14
	MOVB	A14,*A8(OHITS)		;NUMBER OF ALLOWED HITS

	CLRM	*a8(OEFLAGS),W		; clear EFLAGS for all natives

	move	@NUM_OUT_THERE,a14
	inc	a14
	move	a14,@NUM_OUT_THERE

	CALLA	GET_SHAD_MULTI		;Setup his shadow

	setc
	rets

*
*	if guy exists, delete him if his Z becomes too far
*
CN_leave:
	clrc			; nobody was created
	rets



BUSHGUY_CVECT
	WWL	OID_PROCKET,~MASK_PLAYER,NATV_ROCKET_COLL
	WWL	OID_PEXPLOSION,~MASK_PLAYER,NATV_EXPLOSION_COLL
	WWL	OID_BLOWUP,0FFFFH,NATV_SBOMB_COLL
	WL	0,DUMCRETS

**************************************************************************
*								         *
* NONBOY_ROCKET_COLL - Collision vector for Player rocket bomb.		 *
* A0 = Ptr to rocket object						 *
* A8 = Ptr to NON-BOY object						 *
*								         *
**************************************************************************
NATV_ROCKET_COLL
	MOVE	*A0(RL_INTENDED_OBJ),A14,L
	CMP	A14,A8			;Is this the object we are after?
	JRNE	NRC_X			;BR = No

	CALLA	GET_HEAD_PART
	ORIM	M_ATEROCKET,*A8(OEFLAGS),W	;Flag the rocket touch
NRC_X
	RETS


BUSH_EXPLODE_SBOMB
	LWLLL	1,1|AFunc,A_SBOMB_BLOOD+4,0,40000H
	LWLL	1,1|AFunc,A_AnimGo+2,ANIM_BUSH_EXP_NOBLOOD

BUSH_EXPLODE_ANIM
	LWLLL	1,1|AFunc,A_BLOOD_SPLORCH+4,0,0
	LWL	1,3|AFunc,CLR_VEL

	.IF AUSTRALIA

ANIM_BUSH_EXP_NOBLOOD
	LWL	1,1|AFunc,A_DEL_NATIVE

	.ELSE

ANIM_BUSH_EXP_NOBLOOD
	LWLLLL	1,1|AFunc,A_PreFrag_Center+6,NATIVE_PARTS_1,80h,60000h
	LWLLLL	1,1|AFunc,A_PreFrag_Center+6,NATIVE_PARTS_2,500h,50000h
;	LWL	1,5|AFunc,A_PreFrag_BUSH
	LWL	1,1|AFunc,A_DEL_NATIVE

	.ENDIF


; - Delete
;A_PreFrag_BUSH:
;	movi	080h,a3	 	; Abs v Z
;	movi	40000h,a0	; Abs v X and Y
;	calla	PreFrag_Center	      
;	sra	1,b10		; halve max Z
;	sll	1,b9		; double min Z
;	sll	1,b7		; double min Y
;	clr	b8		; y go up only
;	movi	BEEK_PARTS,b14
;	JAUC	Fragger			;And get it goin' Boy

**************************************************************************
*								         *
* 	NATV_SBOMB_COLL							 *
* 									 *
* 	Smart bomb service for Native					 *
* 									 *
* 	A2 = Ptr to player that smart bombed				 *
* 	A8 = Ptr to Native						 *
*								         *
**************************************************************************
NATV_SBOMB_COLL
	CALLA	GET_HEAD_PART
	ORIM	M_ATEROCKET,*A8(OEFLAGS),W	;This will make him blow up

	MOVI	BUSH_EXPLODE_SBOMB,A3	;Hit directly by the rocket

	JRUC	NATV_GEN_COLL

**************************************************************************
*								         *
* NATV_EXPLOSION_COLL - Collision vector for Player explosion.		 *
* A0 = Ptr to explosion object						 *
* A8 = Ptr to NATIVE object						 *
*								         *
**************************************************************************
NATV_EXPLOSION_COLL:
	CALLA	GET_HEAD_PART

	MOVE	*A8(OEFLAGS),A14,W
	BTST	B_ATEROCKET,A14
	JRZ	NEC_NO_EXP_OFF		;BR = Not hit directly

	SWAP	A0,A8
	CALLA	GET_HEAD_PART
	CALLA	OBJ_OFF_MULTI
	SWAP	A0,A8

NEC_NO_EXP_OFF
	MOVE	*A0(OID),A0,W		;GET PLAYER DATA ADDRESS
	CALLA	POID_TO_PDATA		;GET PDATA IN A2

	MOVI	BUSH_EXPLODE_ANIM,A3	;Hit directly by the rocket
*
* Entrypoint for all explosion stuff
*	A8 = Ptr to Native head part
*	A3 = Animation script if exploding
*
NATV_GEN_COLL
	PUSH	A3
	callr	A_Unlink_Enemy
	PULLQ	A3

	move	*a8(OPLINK),a0,L	; if he was shooting, kill proc
	jrz	noproc1
	clr	a14
	move	a14,*a8(OPLINK),L	; he ain't pissed no more.
	calla	KILL
noproc1:
	CALLA	ALL_COLLS_OFF		;Turn all collisions off now!

	MOVE	A2,*A8(OPLAYER),L	;Hang on to this address

	MOVI	1000,A1
	CALLA	SCORE			;Explosions are always good for points

	CALLA	COUNT_PLAYER_KILL

	SOUNDZ	SND_NATIVE_EXPLODE	;Blow him up proper

	MOVE	*A8(OEFLAGS),A14,W
	BTST	B_ATEROCKET,A14
	JRZ	NEC_HIT_BY_EXPLOSION

	MOVE	A3,A1			;Hit directly by the rocket
	jruc	SetAnimNow
NEC_HIT_BY_EXPLOSION
	move	*a8(OFLAGS),a14		; renable ground coll for head part
	ori	M_GCOLL,a14
	andni	M_NOCOLL,a14
	move	a14,*a8(OFLAGS)

	MOVIM	FLYBOY_CVECT,*a8(OCVECT),L

	MOVIM	-1,*a8(OZVEL),L
	MOVIM	5000h,*a8(OYACCEL),W
	MOVIM	-0a6000h,*a8(OYVEL),L
	MOVI	-20000h,a1
	movi	20000h,a0
	calla	RANGERND
	move	a0,*a8(OXVEL),L

	MOVk	14,a14
	movb	a14,*a8(AnimSLP)	; slow fall back
	movi	NTV_DTH_ANIM,a1

	SOUNDZ	SND_NATIVE_SCREAM	;Make him scream

SetAnimNow:
	movk	1,a14
	movb	a14,*a8(AnimSlp)
	MOVE	A1,*A8(AnimFrm),L
	MOVE	A1,*A8(AnimScr),L
	RETS


FLYBOY_CVECT
	WWL	OID_GRND,0FFFFH,NATIVE_GRND_COLL
	WL	0,DUMCRETS


NATIVE_GRND_COLL:
	SOUNDZ	SND_GROUND_HIT
	calla	COLLS_OFF
	calla	PSTOP
	movk	1,a14
	movb	a14,*a8(AnimSLP)
	movb	a14,*a8(AnimSlp)
	rets


NTV_DTH_CVECT
	WWL	OID_GRND,0FFFFH,NTV_DTH_GRND_COLL
	WL	0,DUMCRETS


NTV_DTH_GRND_COLL:
	SOUNDZ	SND_GROUND_HIT
	ANDNIM	M_GCOLL,*A8(OFLAGS),W	;Disable ground coll
	CALLA	PSTOP
	RETS


NATIVE_GUNVECT:
	move	*a8(OPART1),a8,L	; get head
	callr	A_Unlink_Enemy
	MOVE	A2,*A8(OPLAYER),L

	SOUND1	SND_BODY_THUD
	CALLA	BLOODY_BULLET_HIT

	jauc	NONBOY_SBOMB


A_Unlink_Enemy:
	move	*a8(OGenObj),a3,L	; Enemy Generator Object
	jrz	notlnked
	clr	a14
	move	a14,*a8(OGenObj),L
	.if	DEBUG
	move	*a3(UEGenObj),a4,L	
	cmp	a4,a8
	LOCKON	NE
	.endif
	move	a14,*a3(UEGenObj),L

notlnked:
	rets


*
*	delete an enemy if off screen or too far away in Z
*
CheckNativeOffScrn:
	move	@WORLD_GRNDOFF+10h,a14
	jrnz	notlnked

	move	*a8(OFLAGS),a14		; unlink and delete native
	btst	B_OFSCRN,a14		; if offscreen
	jrnz	delete_him
	
	move	*a8(OZVAL),a1,L
	move	@ZBASE,a14,L
	sub	a14,a1 			; world Z in a9
	move	@ENEMY_ZW_MAX,a0,L
	cmp	a0,a1
	jrge	delete_him
	rets

delete_him:	
	callr	A_Unlink_Enemy
	move	@NUM_OUT_THERE,a14	;
	dec	a14			;
	move	a14,@NUM_OUT_THERE	;
	jauc	DEL_ENEMY_NOAUD

*
*	DELETE NATIVE FROM DEATH ANIMATION
*
A_DEL_NATIVE:
	callr	A_Unlink_Enemy		;
	move	@NUM_OUT_THERE,a14	;
	dec	a14			;
	move	a14,@NUM_OUT_THERE	;
	JAUC	DELETE_ENEMY		;
	

**************************************************************************
*								         *
* 	A_START_TREE_SHAD						 *
* 									 *
* 	Anim func to start a shadow for the tree guy.  It first		 *
* 	clears the NOSHADOW flag for all parts.				 *
* 									 *
* 	A8 = Ptr to any part of Native					 *
*								         *
**************************************************************************
A_START_TREE_SHAD
	MOVI	M_NOSHADOW,A2
	MOVE	*A8(OPART1),A0,L
ASTS_LOOP
	MOVE	*A0(OFLAGS),A14,W
	ANDN	A2,A14
	MOVE	A14,*A0(OFLAGS),W	;Turn off all NOSHADOW flags
	MOVE	*A0(OPARTS),A0,L
	JRNZ	ASTS_LOOP
	JAUC	GET_SHAD_MULTI		;And start the shadow

**************************************************************************
*								         *
* 	A_CHECK_SHAD_START						 *
* 									 *
* 	Anim func to check if we need to start a shadow.		 *
* 									 *
* 	A8 = Ptr to any part of Native					 *
*								         *
**************************************************************************
A_CHECK_SHAD_START
	MOVE	*A8(OFLAGS),A14,W
	BTST	B_NOSHADOW,A14
	JRNZ	A_START_TREE_SHAD	;BR = No shadow currently exists
	RETS


CENTER_INIT:
	.byte	5,0,0,1
	.long	NI28
	.word	OID_NATIVE,OM_COLL
	.long	BUSHGUY_CVECT
	LWWWW	peek1rl,DMAWNZ,M_NODISP|M_NOSHADOW,0,OM_ANIM|OM_GUNV
	.long	NATIVE_GUNVECT
	.long	BUSHGUY_ANIM
	LWWWW	peek1ll,DMAWNZ,M_NODISP|M_NOSHADOW,0,OM_PRVGUNV
	LWWWW	peek1ra,DMAWNZ,M_NODISP|M_NOSHADOW,0,OM_PRVGUNV
	LWWWW	peek1la,DMAWNZ,M_NODISP|M_NOSHADOW,0,OM_PRVGUNV
	LWWWW	peek1m,DMAWNZ,M_NODISP|M_NOSHADOW,0,OM_PRVGUNV

BUSHGUY_INIT:
	.byte	5,0,0,1
	.long	NI28
	.word	OID_NATIVE,OM_COLL
	.long	BUSHGUY_CVECT
	LWWWW	peek1rl,DMAWNZ,M_NODISP,0,OM_ANIM|OM_GUNV
	.long	NATIVE_GUNVECT
	.long	BUSHGUY_ANIM
	LWWWW	peek1ll,DMAWNZ,M_NODISP,0,OM_PRVGUNV
	LWWWW	peek1ra,DMAWNZ,M_NODISP,0,OM_PRVGUNV
	LWWWW	peek1la,DMAWNZ,M_NODISP,0,OM_PRVGUNV
	LWWWW	peek1m,DMAWNZ,M_NODISP,0,OM_PRVGUNV

TREEGUY_INIT:
	.byte	5,0,0,1
	.long	NI28
	.word	OID_NATIVE,OM_COLL
	.long	BUSHGUY_CVECT
	LWWWW	jmtr1rl,DMAWNZ,M_NOSHADOW,0,OM_ANIM|OM_GUNV
	.long	NATIVE_GUNVECT
	.long	TREEGUY_ANIM
	LWWWW	jmtr1ll,DMAWNZ,M_NOSHADOW,0,OM_PRVGUNV
	LWWWW	jmtr1ra,DMAWNZ,M_NOSHADOW,0,OM_PRVGUNV
	LWWWW	jmtr1la,DMAWNZ,M_NOSHADOW,0,OM_PRVGUNV
	LWWWW	jmtr1m,DMAWNZ,M_NOSHADOW,0,OM_PRVGUNV

TREEGUY_ANIM:
	LWLWW	1,40|AFunc,A_RAND_AnimSLP+2,2,120
	LW	1,0
	LWLW	1,1|AFunc,A_SET_OYACCEL+1,3000h

	LWL	1,1|AFunc,A_START_TREE_SHAD

	LWL	1,1|AFunc,A_STAY_TIL_GRND_HIT

	LWLL	jmtr2rf,1|AMulti|AFunc,A_SOUNDZ+2,SND_GROUND_HIT
	LW	jmtr2lf,1|AMulti
	LW	jmtr2ra,1|AMulti
	LW	jmtr2la,1|AMulti
;	LWL	jmtr2m,3|AFunc,OBJ_OFF
	LW	jmtr2m,3

	LW	jmtr3rl,1|AMulti
	LW	jmtr3ra,1|AMulti
	LW	jmtr3la,1|AMulti
;	LW	jmtr3m,3
	LW	jmtr3m,1|AMulti
	LWL	1,3|AFunc,OBJ_OFF

	LW	jmtr4ll,1|AMulti
	LW	jmtr4ra,1|AMulti
	LW	jmtr4la,1|AMulti
	LW	jmtr4m,3

	LW	jmtr5rl,1|AMulti
	LW	jmtr5ra,1|AMulti
	LW	jmtr5m,1|AMulti
	LWL	1,3|AFunc,OBJ_OFF

	LW	jmtr6rl,1|AMulti
	LW	jmtr6ra,1|AMulti
	LW	jmtr6la,1|AMulti
	LWL	jmtr6m,3|AFunc,OBJ_ON

	LWL	jmtr7rl,1|AMulti|AFunc,A_Unlink_Enemy
	LW	jmtr7ra,1|AMulti
	LW	jmtr7la,1|AMulti
	LW	jmtr7m,2

	LWL	1,1|AFunc,A_Set_LOOP_STRT

BUSHGUY_ANIM:
	LW	1,5	;This is a hack to wait for Zsort to catch up

	LWL	peek1rl,1|AMulti|AFunc,OBJ_ON
	LWL	peek1ll,1|AMulti|AFunc,OBJ_ON
	LWL	peek1ra,1|AMulti|AFunc,OBJ_ON
	LWL	peek1la,1|AMulti|AFunc,OBJ_ON
	LWL	peek1m,3|AFunc,OBJ_ON
BUSHWAIT:
	LWL	1,1|AFunc,CheckNativeOffScrn
	LWL	1,1|AFunc,WHAT_TO_DO

	LW	peek2rl,1|AMulti
	LW	peek2ll,1|AMulti
	LW	peek2ra,1|AMulti
	LW	peek2la,1|AMulti
	LW	peek2m,3

	LW	peek3rl,1|AMulti
	LW	peek3ll,1|AMulti
	LW	peek3ra,1|AMulti
	LW	peek3la,1|AMulti
	LW	peek3m,3

	LW	peek4rl,1|AMulti
	LW	peek4ll,1|AMulti
	LW	peek4ra,1|AMulti
	LW	peek4la,1|AMulti
	LW	peek4m,3

	LW	peek5rl,1|AMulti
	LW	peek5ll,1|AMulti
	LW	peek5ra,1|AMulti
	LW	peek5la,1|AMulti
	LW	peek5m,60

	LW	peek4rl,1|AMulti
	LW	peek4ll,1|AMulti
	LW	peek4ra,1|AMulti
	LW	peek4la,1|AMulti
	LW	peek4m,3

	LW	peek3rl,1|AMulti
	LW	peek3ll,1|AMulti
	LW	peek3ra,1|AMulti
	LW	peek3la,1|AMulti
	LW	peek3m,3

	LW	peek2rl,1|AMulti
	LW	peek2ll,1|AMulti
	LW	peek2ra,1|AMulti
	LW	peek2la,1|AMulti
	LW	peek2m,3

	LW	peek1rl,1|AMulti
	LW	peek1ll,1|AMulti
	LW	peek1ra,1|AMulti
	LW	peek1la,1|AMulti
	LW	peek1m,3

	LWLWW	1,1|AFunc,A_RAND_AnimSLP+2,20,100
	LW	1,0
	LW	1,0

	.long	0

BUSHJMP_ANIM
	LW	jmpo1ra,1|AMulti
	LW	jmpo1m,1|AMulti
	LW	jmpo1la,1|AMulti
	LWL	1,1|AMulti|AFunc,OBJ_OFF
	LWL	1,3|AFunc,OBJ_OFF

	LW	jmpo2rl,1|AMulti
	LW	jmpo2ra,1|AMulti
	LW	jmpo2la,1|AMulti
	LWL	jmpo2m,3|AFunc,OBJ_ON

	LWLL	jmpo3rl,1|AMulti|AFunc,A_SET_OXVEL+2,-40000H
	LW	jmpo3ll,1|AMulti
	LW	jmpo3ra,1|AMulti
	LW	jmpo3la,1|AMulti
	LWL	jmpo3m,3|AFunc,OBJ_ON

	LW	jmpo4rl,1|AMulti
	LW	jmpo4ll,1|AMulti
	LW	jmpo4ra,1|AMulti
	LW	jmpo4la,1|AMulti
	LW	jmpo4m,3

	LW	jmpo5rl,1|AMulti
	LW	jmpo5ll,1|AMulti
	LW	jmpo5ra,1|AMulti
	LW	jmpo5la,1|AMulti
	LW	jmpo5m,3

	LW	jmpo6rl,1|AMulti
	LW	jmpo6ll,1|AMulti
	LW	jmpo6ra,1|AMulti
	LW	jmpo6la,1|AMulti
	LW	jmpo6m,3

	LW	jmpo7rl,1|AMulti
	LW	jmpo7ll,1|AMulti
	LW	jmpo7ra,1|AMulti
	LW	jmpo7la,1|AMulti
	LW	jmpo7m,3

	LW	jmpo8rl,1|AMulti
	LW	jmpo8ll,1|AMulti
	LW	jmpo8ra,1|AMulti
	LW	jmpo8la,1|AMulti
	LW	jmpo8m,3

	LWL	jmpo9rl,1|AMulti|AFunc,A_Unlink_Enemy
	LW	jmpo9ll,1|AMulti
	LW	jmpo9ra,1|AMulti
	LW	jmpo9la,1|AMulti
	LW	jmpo9m,3

	LWLWL	jmpo10rl,1|AMulti|AFunc,A_Set_Rel_Long+3,OXVEL,0
	LW	jmpo10ll,1|AMulti
	LW	jmpo10ra,1|AMulti
	LW	jmpo10la,1|AMulti
	LW	jmpo10m,3

	LW	jmpo11rl,1|AMulti
	LW	jmpo11ll,1|AMulti
	LW	jmpo11ra,1|AMulti
	LW	jmpo11la,1|AMulti
	LW	jmpo11m,2

;	LWL	1,1|AFunc,NatvAdjXJmp

	.long	0

NATV_THRW_ANIM:
	LW	throw2rl,1|AMulti
	LW	throw2ll,1|AMulti
	LW	throw2ra,1|AMulti
	LW	throw2la,1|AMulti
	LW	throw2m,6

	LW	throw3rl,1|AMulti
	LW	throw3ll,1|AMulti
	LW	throw3ra,1|AMulti
	LW	throw3la,1|AMulti
	LW	throw3m,6

	LW	throw4rl,1|AMulti
	LW	throw4ll,1|AMulti		 
	LW	throw4ra,1|AMulti
	LW	throw4la,1|AMulti
	LW	throw4m,6

	LW	throw5rl,1|AMulti
	LW	throw5ll,1|AMulti
	LW	throw5ra,1|AMulti
	LW	throw5la,1|AMulti
	LW	throw5m,6

;	LWL	throw6rl,1|AMulti|AFunc,THROW_SPEAR
	LWLLWW	throw6rl,1|AMulti|AFunc,A_SPAWN_PROJECTILE+4,NSPEAR_INIT,-21,-108
	LWLL	throw6ll,1|AMulti|AFunc,A_SOUNDZ+2,SND_CHUCK_IT
	LW	throw6ra,1|AMulti
	LW	throw6la,1|AMulti
	LW	throw6m,6

	LW	throw7rl,1|AMulti
	LW	throw7ll,1|AMulti
	LW	throw7la,1|AMulti
	LW	throw7la,1|AMulti
	LW	throw7m,5

	LW	throw8rl,1|AMulti
	LW	throw8ll,1|AMulti
	LW	throw8ra,1|AMulti
	LW	throw8la,1|AMulti
	LW	throw8m,5

	LW	throw9rl,1|AMulti
	LW	throw9ll,1|AMulti
	LW	throw9ra,1|AMulti
	LW	throw9la,1|AMulti
	LW	throw9m,5

	LW	throw10rl,1|AMulti
	LW	throw10ll,1|AMulti
	LW	throw10ra,1|AMulti
	LW	throw10la,1|AMulti
	LW	throw10m,5

	LW	ano2rl,1|AMulti
	LW	ano2ll,1|AMulti
	LW	ano2ra,1|AMulti
	LW	ano2la,1|AMulti
	LW	ano2m,5

	LW	ano3rl,1|AMulti
	LW	ano3ll,1|AMulti
	LW	ano3ra,1|AMulti
	LW	ano3m,1|AMulti
	LWL	1,5|AFunc,OBJ_OFF

	LW	ano4rl,1|AMulti
	LW	ano4ll,1|AMulti
	LW	ano4ra,1|AMulti
	LW	ano4la,1|AMulti
	LWL	ano4m,5|AFunc,OBJ_ON

;	LW	ano5rl,1|AMulti
;	LW	ano5ll,1|AMulti
;	LW	ano5ra,1|AMulti
;	LW	ano5la,1|AMulti
;	LW	ano5m,5

	LW	ano6rl,1|AMulti
	LW	ano6ll,1|AMulti
	LW	ano6ra,1|AMulti
	LW	ano6la,1|AMulti
	LW	ano6m,5

	LW	ano7rl,1|AMulti
	LW	ano7ll,1|AMulti
	LW	ano7ra,1|AMulti
	LW	ano7la,1|AMulti
	LW	ano7m,5

	.long	0
;	LWLL	1,1|AFunc,A_AnimFrm+2,BUSHGUY_ANIM

*
* Native sounds
*
SND_GROUND_HIT
	.WORD	0F330H,26,0A1D1H,0	;Thud when hitting ground
SND_BODY_THUD
	.WORD	0E10AH,26,0A1CFH,0	;Thud for getting shot
SND_CHUCK_IT
	.WORD	0F141H,13,0A47EH,0	;Sound for throwing the spear
SND_NATIVE_GRUNT
	.WORD	0E341H,26,0A47DH,0	;Native grunts for appear
SND_NATIVE_EXPLODE
	.WORD	0F342H,60,0A38DH,0	;Explosion used by much
SND_NATIVE_SCREAM
	.WORD	0F142H,74,0A3ABH,0	;Scream flying explode guy



NATV_RUN_ANIM:
	LW	rdru1rl,1|AMulti
	LW	rdru1ll,1|AMulti
	LW	rdru1ra,1|AMulti
	LW	rdru1la,1|AMulti
	LW	rdru1m,4

	LW	rdru2rl,1|AMulti
	LW	rdru2ll,1|AMulti
	LW	rdru2ra,1|AMulti
	LW	rdru2la,1|AMulti
	LW	rdru2m,4

	LW	rdru3rl,1|AMulti
	LW	rdru3ll,1|AMulti
	LW	rdru3m,1|AMulti
	LW	rdru3la,1|AMulti
	LWL	1,4|AFunc,OBJ_OFF

NATV_RUN_LP:
	LWLL	run1ll,1|AMulti|AFunc,A_SET_OZVEL+2,-0e0h
	LW	run1rl,1|AMulti
	LW	run1ra,1|AMulti
	LW	run1m,1|AMulti
	LWL	run1la,4|AFunc,OBJ_ON

	LW	run2ll,1|AMulti
	LW	run2rl,1|AMulti
	LW	run2ra,1|AMulti
	LW	run2m,1|AMulti
	LW	run2la,4

	LW	run3ll,1|AMulti
	LW	run3rl,1|AMulti
	LW	run3ra,1|AMulti
	LW	run3m,1|AMulti
	LW	run3la,4

	LW	run4ll,1|AMulti
	LW	run4rl,1|AMulti
	LW	run4ra,1|AMulti
	LW	run4m,1|AMulti
	LW	run4la,4

	LW	run5ll,1|AMulti
	LW	run5rl,1|AMulti
	LW	run5ra,1|AMulti
	LW	run5m,1|AMulti
	LW	run5la,4

	LW	run6ll,1|AMulti
	LW	run6rl,1|AMulti
	LW	run6ra,1|AMulti
	LW	run6m,1|AMulti
	LW	run6la,4

	LW	run7ll,1|AMulti
	LW	run7rl,1|AMulti
	LW	run7ra,1|AMulti
	LW	run7m,1|AMulti
	LW	run7la,4

	LW	run8ll,1|AMulti
	LW	run8rl,1|AMulti
	LW	run8ra,1|AMulti
	LW	run8m,1|AMulti
	LW	run8la,4

	LW	run9ll,1|AMulti
	LW	run9rl,1|AMulti
	LW	run9ra,1|AMulti
	LW	run9m,1|AMulti
	LW	run9la,4

	LW	run10ll,1|AMulti
	LW	run10rl,1|AMulti
	LW	run10ra,1|AMulti
	LW	run10m,1|AMulti
	LW	run10la,3

	LWL	1,1|AFunc,HES_RUNNING

NATV_RUN_HALT:
	LW	rurd1rl,1|AMulti
	LW	rurd1ll,1|AMulti
	LW	rurd1ra,1|AMulti
	LW	rurd1la,1|AMulti
	LW	rurd1m,4

	LWL	rurd2rl,1|AMulti|AFunc,A_CLR_OZVEL
	LW	rurd2ll,1|AMulti
	LW	rurd2ra,1|AMulti
	LW	rurd2la,1|AMulti
	LW	rurd2m,4

	.long	0
		


*
*	called from NONBOY_GUNVECTOR
*
NATIVE_DEATH:
	movk	3,a14
	movb	a14,*a8(AnimSLP)	; normal speed for gun death

	MOVE	*A8(OYVEL),A14,L
	JRNZ	ND_NO_NEW_YVEL

	MOVIM	-28000H,*A8(OYVEL),L	;Make him fly up

ND_NO_NEW_YVEL
	MOVIM	3000H,*A8(OYACCEL),W	;Drop him

	move	*a8(OFLAGS),a14		; renable ground coll for head part
	ori	M_GCOLL,a14
	andni	M_NOCOLL,a14
	move	a14,*a8(OFLAGS)

	MOVIM	NTV_DTH_CVECT,*a8(OCVECT),L

	movi	NTV_DTH_ANIM,a1
	jruc	SetAnimNow


NTV_DTH_ANIM
	LW	det1m,1|AMulti
	LW	det1rl,1|AMulti
	LW	det1ll,1|AMulti
	LWL	det1ra,1|AMulti|AFunc,OBJ_ON
	LWL	det1la,0|AFunc,OBJ_ON

; To improve bog problems, no shadow added on death
;	LWL	det2m,1|AMulti|AFunc,A_CHECK_SHAD_START
	LW	det2m,1|AMulti
	LW	det2rl,1|AMulti
	LW	det2ll,1|AMulti
	LW	det2ra,1|AMulti
	LW	det2la,0

	LW	det3m,1|AMulti
	LW	det3rl,1|AMulti
	LW	det3ll,1|AMulti
	LW	det3ra,1|AMulti
	LW	det3la,0

	LW	det4m,1|AMulti
	LW	det4rl,1|AMulti
	LW	det3ll,1|AMulti
	LW	det4ra,1|AMulti
	LW	det4la,0

	LW	det5m,1|AMulti
	LW	det5rl,1|AMulti
	LW	det5ll,1|AMulti
	LW	det5ra,1|AMulti
	LW	det5la,0

	LW	det6la,1|AMulti
	LW	det6rl,1|AMulti
	LW	det6ra,1|AMulti
	LWL	1,1|AFunc|AMulti,OBJ_OFF
	LWL	1,0|AFunc,OBJ_OFF

	LWL	1,1|AFunc,A_STAY_TIL_GRND_HIT

	LWL	det7la,1|AMulti|AFunc,A_NATIVE_HIT_SND
	LW	det7rl,1|AMulti
	LW	det7ra,0

	LWLWL	det8ll,1|AMulti|AFunc,A_Set_Rel_Long+3,OXVEL,0
	LW	det8ra,1|AMulti
	LW	det8la,0

	LW	det9rl,1|AMulti
	LW	det9ll,1|AMulti
	LW	det9la,0

	LW	det10la,1|AMulti
	LW	det10rl,1|AMulti
	LW	det10ll,34

	LWL	1,1|AFunc,A_DEL_NATIVE


*
* Native blows up a little bit
*
NATIVE_PARTS_1
	.long	ARM_SPIN,N_CHUNK
	.word	OID_JUNK,1*800H+0*40H+FRGPAL+FRGGCOL

	.long	LEG_SPIN,N_CHUNK
	.word	OID_JUNK,1*800H+0*40H+FRGPAL+FRGGCOL

	.long	0

*
* Native blows up some more
*
NATIVE_PARTS_2
	.long	ARM_SPIN2,N_CHUNK
	.word	OID_JUNK,1*800H+0*40H+FRGPAL+FRGGCOL

	.long	HEAD_SPIN,N_CHUNK
	.word	OID_JUNK,1*800H+0*40H+FRGPAL+FRGGCOL

	.long	LEG_SPIN,N_CHUNK
	.word	OID_JUNK,1*800H+0*40H+FRGPAL+FRGGCOL

	.long	0

**************************************************************************
*								         *
* Fragment Animation Scripts - These are used by the Fragger Scripts	 *
*								         *
**************************************************************************

*
* Native arm spin animation
*
ARM_SPIN
	LWLW	ARMTOR1,1|AFunc,A_INIT_AnimSLP+1,1
ARM_SPIN_LOOP
	LW	ARMTOR2,0
	LW	ARMTOR3,0
	LW	ARMTOR4,0
	LW	ARMTOR5,0
	LW	ARMTOR6,0
	LW	ARMTOR7,0
	LW	ARMTOR8,0
	LW	ARMTOR1,0
	LW	ARMTOR2,0
	LW	ARMTOR3,0
	
	LW	ARMTOR4,0
	LW	ARMTOR5,0
	LW	ARMTOR6,0
	LW	ARMTOR7,0
	LWLW	ARMTOR8,0|AFunc,A_INC_AnimSLP+1,4
	LWLL	ARMTOR1,0|AFunc,A_AnimFrm+2,ARM_SPIN_LOOP

ARM_SPIN2
	LWLW	ARMRIP1,1|AFunc,A_INIT_AnimSLP+1,1
ARM_SPIN2_LOOP
	LW	ARMRIP2,0
	LW	ARMRIP3,0
	LW	ARMRIP4,0
	LW	ARMRIP5,0
	LW	ARMRIP6,0
	LW	ARMRIP7,0
	LW	ARMRIP8,0
	LW	ARMRIP1,0
	LW	ARMRIP2,0
	LW	ARMRIP3,0
	
	LW	ARMRIP4,0
	LW	ARMRIP5,0
	LW	ARMRIP6,0
	LW	ARMRIP7,0
	LWLW	ARMRIP8,0|AFunc,A_INC_AnimSLP+1,4
	LWLL	ARMRIP1,0|AFunc,A_AnimFrm+2,ARM_SPIN2_LOOP

*
* Native leg spin animation
*
LEG_SPIN
	LWLW	LEGRIP1,1|AFunc,A_INIT_AnimSLP+1,3
LEG_SPIN_LOOP
	LW	LEGRIP2,0
	LW	LEGRIP3,0
	LW	LEGRIP4,0
	LW	LEGRIP5,0
	LW	LEGRIP6,0
	LW	LEGRIP7,0
	LW	LEGRIP8,0
	LW	LEGRIP1,0
	
	LW	LEGRIP2,0
	LW	LEGRIP3,0
	LW	LEGRIP4,0
	LW	LEGRIP5,0
	LW	LEGRIP6,0
	LW	LEGRIP7,0
	LWLW	LEGRIP8,0|AFunc,A_INC_AnimSLP+1,8
	LWLL	LEGRIP1,0|AFunc,A_AnimFrm+2,LEG_SPIN_LOOP

*
* Native head spin animation
*
HEAD_SPIN
	LWLW	MASKBLOW1,1|AFunc,A_INIT_AnimSLP+1,3
HEAD_SPIN_LOOP
	LW	MASKBLOW2,0
	LW	MASKBLOW3,0
	LW	MASKBLOW4,0
	LW	MASKBLOW5,0
	LW	MASKBLOW6,0
	LW	MASKBLOW7,0
	LW	MASKBLOW8,0
	LW	MASKBLOW1,0
	
	LW	MASKBLOW2,0
	LW	MASKBLOW3,0
	LW	MASKBLOW4,0
	LW	MASKBLOW5,0
	LW	MASKBLOW6,0
	LW	MASKBLOW7,0
	LWLW	MASKBLOW8,0|AFunc,A_INC_AnimSLP+1,8
	LWLL	MASKBLOW1,0|AFunc,A_AnimFrm+2,HEAD_SPIN_LOOP

**************************************************************************
*								         *
* 	A_NATIVE_HIT_SND						 *
* 									 *
* 	Anim func to make the ground hit sound for the native.		 *
* 									 *
* 	A8 = Ptr to native head part					 *
*								         *
**************************************************************************
A_NATIVE_HIT_SND
	MOVI	SND_GROUND_HIT,A0
	MOVE	*A8(OYVEL),A14,L
	JAZ	ONESND_Z
	RETS

********************************************************
*						       *
*   NATIVE BRANCH ROUTINES			       *
*						       *
*     AFuncs to decide what to do next based on what   *
*     	he just did				       *
*						       *
*						       *
********************************************************

*
*	GENERAL DECISION ROUTINE
*
WHAT_TO_DO:
	move	*a8(OEFLAGS),a14	; normal or building guy?
	jrz	normalguy
	cmpk	1,a14
	jreq	jumpoutguy

*
*	FINALE GUY, jump sideways to get on screen, try to throw
*
	movb	*a8(OFLAGS),a14
	jrnn	do_throw
	movi	M_FLIPH,a0
	move	*a8(ODAGX),a14
	jrn	jump_right
	clr	a0
jump_right:
	calla	SET_FLPS
	jruc	do_jump

normalguy:
	move	*a8(OGenObj),a14,L	; is he behind a bush?
	jrz	out_from_bush
*
*	Either peek or jump out or wait
*
behind_bush:
	movi	BUSHWAIT,a1
	movi	100,a0			; wait (small prob)
	calla	RANDPER
	jrc	set4
	calla	WVSTRT_CHANCE		; peek at first, then jump more
	jrnc	keepon

	MOVB	*A8(OFLAGS),A14
	JRN	WTD_NOSND		;BR = Offscreen
	SOUNDZ	SND_NATIVE_GRUNT	;Make the appear sound
WTD_NOSND

	movi	BUSHJMP_ANIM,a1
set4:
	move	a1,*a8(AnimFrm),L
keepon:
	rets

*
*	This guy is coming out of building
*	His intelligence is slightly different.
*	He jumps out, then tries to throw until he gets too close, 
*	then he runs forward and off
jumpoutguy:
	move	*a8(OZVAL),a0,L
	move	@ZBASE,a14,L
	sub	a14,a0
	cmpi	JUMPOUT_Z,a0		; if too far, then wait 
	jrgt	do_wait
	cmpi	07000h,a0  		; if close, run 
	jrlt	do_run
	move	*a8(OGenObj),a14,L
	jrnz	do_jump			; if attached, jump
	callr	TRY_TO_THROW		; else try to throw
	jrc	success
do_wait:
	movi	BUSHWAIT,a1
	move	a1,*a8(AnimFrm),L
	rets

*
*	In ready position... either throw or run
*
out_from_bush:
	calla	WVSTRT_CHANCE		; early on, try to run 1st,
	jrc	try_to_throw1st		;  later, try to throw 1st
try_to_run1st:
	callr	TRY_TO_RUN
	jrc	success
	callr	TRY_TO_THROW
	jrc	success
do_jump:
	movi	BUSHJMP_ANIM,a1
	move	a1,*a8(AnimFrm),L
success:
	rets


try_to_throw1st:
	callr	TRY_TO_THROW
	jrc	success
	callr	TRY_TO_RUN
	jrc	success
	jruc	do_jump


TRY_TO_THROW:
	callr	SHOULD_I_THROW
	jrnc	nono
	callr	CAN_I_THROW
	jrnc	nono
do_throw:
	move	*a8(ODAGX),a14
	move	a14,@LAST_SPEAR_X
	move	@WAVEIRQS,@LAST_SPEAR_IRQ,L

	movi	NATV_THRW_ANIM,a1
	move	a1,*a8(AnimFrm),L
	setc
	rets


TRY_TO_RUN:
	callr	SHOULD_I_RUN
	jrnc	nono
	callr	CAN_I_RUN
	jrnc	nono
do_run:
	movi	NATV_RUN_ANIM,a1
	move	a1,*a8(AnimFrm),L
yesyes:
	setc
	rets

nono:
	clrc
	rets



HES_RUNNING:
	callr	SHOULD_I_RUN
	jrnz	closenuf

	movi	NATV_RUN_LP,a1		; keep running or stop
	movi	800,a0			
	calla	RANDPER			; small chance of stopping anyway
	jrc	set5
closenuf:
	movi	NATV_RUN_HALT,a1
set5:
	move	a1,*a8(AnimFrm),L
	rets

*
*	SHOULD_I_SIDE - He decides if he is offscreen and should come
*	back on
*
*	Carry set means do it
*	Carry clr means don't
*
;SHOULD_I_SIDE:
;	move	*a8(ODAGX),a14		; am I off screen left?
;	jrnn	SIS_chkleft
;	move	@XSCROLL,a4,L
;	jrgt	side_right		; get back on screen
;	callr	SHOULD_I_RUN
;	jrz	throw_again
;
;SIS_chkleft:
;	subi	HALFX*2,a14
;	jrnn	side_left


*
*	SHOULD_I_RUN  - He decides to run if he is too far back
*	Carry set means run
*	Carry clr means don't
*
SHOULD_I_RUN:
	move	*a8(OZVAL),a1,L
	move	@ZBASE,a14,L
	sub	a14,a1
	cmpi	8000h,a1	; close enuf, don't run
	jrle	nono
	cmpi	0e000h,a1	; far enuf, do run
	jrgt	yesyes
	movi	512,a0
	jauc	RANDPER		; 



*
*	CAN_I_RUN  - He sees if there is something in front of him
*			(like a tree)
*	Carry set means yes, you can
*	Carry clr means no, you can't
*
CAN_I_RUN:
	jruc	yesyes



*
*	SHOULD_I_THROW - Would piercing this invader be a good idea?
*	Carry set means yes, you can
*	Carry clr means no, you can't
*
SHOULD_I_THROW:
	jruc	yesyes


*
*	CAN_I_THROW - He sees if another guy threw a spear at a close X
*                                     or recently
*	Carry set means yes, you can
*	Carry clr means no, you can't
*
CAN_I_THROW:
	callr	CAN_I_CREATE_SPEAR
	jrnc	nono

	move	@LAST_SPEAR_IRQ,a14,L
	move	@WAVEIRQS,a1,L
	sub	a14,a1
	cmpk	25,a1 		; don't throw another within some tiks
	jrlt	nono

	move	*a8(OZVAL),a14,L
	move	@ZBASE,a1,L
	sub	a1,a14			; world Z
	cmpi	014000h,a14		; don't throw if further than this
	jrgt	nono

	movi	-41,a5		; spear pixel offset from thrower
	mpys	a14,a5		; world Z delta
	sra	15,a5		; pixels at that Z
	move	*a8(OCTRL),a14
	btst	B_FLIPH,a14
	jrz	CIT_noflp
	neg	a5
CIT_noflp:
	move	*a8(ODAGX),a3
	add	a3,a5		; proposed DAG of spear
	subk	8,a5
	jrn	nono
	subi	SCREEN_WIDTH-8,a5
	jrnn	nono

;	move	@LAST_SPEAR_X,a14
;	sub	a3,a14		; a3 still contains ODAGX
;	abs	a14
;	cmpk	30,a14
;	jrlt	nono
	jruc	yesyes

*
*	An enemy generator can call this routine to see if it should
*	actually generate the enemy.
*
CAN_I_CREATE:
	move	@HOLD_ENEMY_DISPATCH,a14
	jrnz	nono
*
*	determine max allowed based on CURPLYRS and MAX_ALLOWED
*
	move	@MAX_ALLOWED,a0
	callr	CURPLYR_ADJ	   
	move	@NUM_OUT_THERE,a14
	jrge	itsok
	clr	a14		  	
	move	a14,@NUM_OUT_THERE
itsok:
	cmp	a0,a14
	jrge	nono
	jruc	yesyes



CAN_I_CREATE_SPEAR:
	move	@HOLD_ENEMY_DISPATCH,a14
	jrnz	nono

	move	@OBJENEMIES,a14		; did this get disabled?
	andi	M_OF_BUSH|M_OF_TREE|M_OF_CNATV,a14
	jrz	nono

*
*	determine max allowed based on CURPLYRS and MAX_ALLOWED
*
	move	@MAX_SPEARS_ALLOWED,a0
	move	a0,a1
	srl	1,a1		; half of max
	move	@CURPLYRS,a14
	dec	a0
	jrle	Sadj_done
	add	a1,a0
	dec	a0
	jrle	adj_done
	add	a1,a0
Sadj_done:
	move	@NUM_SPEARS,a14
	cmp	a0,a14
	jrge	nono
	jruc	yesyes


	
*	ENTRY:	a0 = some limit
*
*	EXIT:	a0 = the limit adjusted based on
*			CURPLYRS
*	(Formula:  for each player, the limit is increase by
*			50%)
* ****	NOTE!!!!  THIS TRASHES A1 and A14 !
*
CURPLYR_ADJ:
	move	a0,a1
	srl	1,a1		; half of max
	move	@CURPLYRS,a14
	dec	a14
	jrle	adj_done
	add	a1,a0
	dec	a14
	jrle	adj_done
	add	a1,a0
adj_done:
	rets


*
*	This routine makes a note that damage has been done in the
*	chem plant.  (If it isnt, beekeepers will be dispatched to 
*	fuck up the player)
*
NOTICE_DAMAGE:
	move	@WAVEIRQS,@LAST_CHEM_DAMAGE,L
	rets

*
*	This process checks to make sure that damage is being done in the
*	chemical plant.   If not, it dispatches nasty beekeepers
*
CHECK4_CHEM_DAM
	callr	NOTICE_DAMAGE		; initialize
CHK_CHMDAM_lp:
	sleep	60
	move	@SCROLLKILL,a4
	jrz	CCD0
	dec	a4
	move	a4,@SCROLLKILL
	DIE
CCD0:
	move	@WAVEIRQS,a3,L
	move	@LAST_CHEM_DAMAGE,a1
	sub	a1,a3

	movi	4*60,a0   		; 4 (was 10) seconds for 1 player
	move	@CURPLYRS,a14
	dec	a14
	jrz	CCD1
	subi	60,a0	  		; 3 (was 8) seconds for 2 players
	dec	a14
	jrz	CCD1
	subi	60,a0	  		; 2 (was 6) seconds for 3 players
CCD1:
	cmp	a0,a3			; if too long, fall through
	jrlt	CHK_CHMDAM_lp
*
*	Dispatch a bad guy
*
	calla	DROP_A_MASK_GUY
	callr	NOTICE_DAMAGE		; reset
	jruc	CHK_CHMDAM_lp


	.IF	0
SPEAR_INIT:
	LWWWW	ARROW1,DMAWNZ,0,OM_ANIM|OM_OID|OM_GUNV|OM_COLL, OID_EROCKET
	.long	SPEAR_CVECT	; COLL
	.LONG	SPEAR_GUNVECT	; GUNV
	.long	SPEAR_ANIM

SPEAR_CVECT
	WWL	OID_PROCKET,~MASK_PLAYER,SPEAR_COLLVECT 	;
	WL	0,DUMCRETS

SPEAR_FALL_CVECT
	WWL	OID_GRND,0FFFFH,SPEAR_GRND_COLL	       
	WL	0,DUMCRETS


SPEAR_GRND_COLL:
	clr	a14
	move	a14,*a8(OYACCEL),W
	jauc	DELETE_OBJ

SPEAR_COLLVECT:
	move	@NUM_SPEARS,a14	       
	dec	a14
	move	a14,@NUM_SPEARS	       
	calla	DELETE_OBJ_PROC
	rets

SPEAR_GUNVECT:
	CLRM	*a8(OZVEL),L
	calla	PULL_ANIM

	CALLA	COLLS_OFF		;Turn all collisions off now!

	calla	OBJPROC_KILL

	move	*a8(OFLAGS),a14
	ori	M_GCOLL,a14
	andni	M_NOCOLL,a14
	move	a14,*a8(OFLAGS)

	MOVIM	SPEAR_FALL_CVECT,*a8(OCVECT),L

	SOUNDZ	SND_SPEAR_DEFLECT

	move	@NUM_SPEARS,a14
	dec	a14
	move	a14,@NUM_SPEARS

	clr	a14
	move	a14,*a8(OXVEL),L
	movi	100h,a14
	move	a14,*a8(OZVEL),L
	movi	-30000h,a14
	move	a14,*a8(OYVEL),L
	movi	3000h,a14
	move	a14,*a8(OYACCEL),W
tooclose:
	rets

SND_SPEAR_DEFLECT:
	.WORD	0F342H,62,0A1A3H,0	;Spear gets blown out of the air
SND_SPEAR_HIT:
	.WORD	0F342H,67,0A48Fh,0
SND_SPEAR_LAND:
	.WORD	0E341H,46,0A41AH,0



SPEAR_ANIM:
	LW	ARROW1,8
	LW	ARROW4,8
	LW	ARROW7,8
	LW	ARROW8,10
	LWLL	ARROW9,2|AFunc,A_STAY_TIL_ZW_LT+2,SPEAR_DEST_Z-(40*SPEAR_ZVEL)
	LWLL	ARROW10,24|AFunc,A_SOUND+2,SND_SPEAR_LAND
	LW	ARROW11,7
	LW	ARROW12,4
	LWL	ARROW13,3|AFunc,COLLS_OFF
	LW	ARROW14,2
	LWL	1,1|AFunc,HIT_BY_SPEAR

INTO_SCRNOBJ:
	move	*a8(OFLAGS),a14
	ori	M_SCRNOBJ,a14
	move	a14,*a8(OFLAGS)

	move	*a8(ODAG),a1,L
	clr	a2
	movy	a1,a2
	sll	16,a1
	move	a1,*a8(OXVAL),L
	move	a2,*a8(OYVAL),L
	rets

SPEAR_DEST_Z	.set	4800h
SPEAR_ZVEL	.set	-180h

THROW_SPEAR:
	movi	SPEAR_INIT,b0
	calla	EASYMAKE
	jrz	nospear

	move	*a8(OXVAL),a1,L
	move	*a8(OYVAL),a2,L
	move	*a8(OZVAL),a3,L
	movi	-41<<15,a4
	movi	-100<<15,a5
	move	*a8(OCTRL),a14
	btst	B_FLIPH,a14
	jrz	nooffadj
	neg	a4			; adjust X offset
nooffadj:
	add	a4,a1
	add	a5,a2
	dec	a3
	move	a1,*a0(OXVAL),L
	move	a2,*a0(OYVAL),L
	move	a3,*a0(OZVAL),L

	move	@NUM_SPEARS,a14
	inc	a14
	move	a14,@NUM_SPEARS

	MOVI	SPEAR_ZVEL,a10

	MOVE	@ZBASE,A14,L
	sub	a14,a3		; src WORLD Z in a3

	sll	ZFRAC,a10		; hi res ZVEL in a10
	move	a0,a8
	move	a3,a9
	sll	ZFRAC,a9		; hi res world Z in a9

	move	@OBJENEMIES,a14		; are we outside main entrance?
	btst	B_OF_CNATV,a14		; if yes, move spear in X
	jrnz	varyX

	CREATE	PID_IND,SPEAR_ADJ_ZX	; keep X same screen rel.
	move	a0,*a8(OPLINK),L

	move	a8,a0
	calla	INSOBJ

nospear:
	rets

varyX:
	move	a1,a5			; save OXVAL in a5

	CREATE	PID_IND,SPEAR_ADJ_Z	; allow motion in X
	move	a0,*a8(OPLINK),L

	move	@XBASE,a0,L		; compute an XVEL
	move	a0,a1
	addi	185*ZMAX_REAL,a0
	subi	185*ZMAX_REAL,a1
	calla	RANGRAND
	sub	a5,a0		; target - current
	sra	7,a0
	move	a0,*a8(OXVEL),L

	move	a8,a0
	calla	INSOBJ
	rets



*
*	If player is hit by spear
*
HIT_BY_SPEAR:
	move	@NUM_SPEARS,a14
	dec	a14
	move	a14,@NUM_SPEARS		; log it.

	move	*a8(OFLAGS),a14
	btst	B_OFSCRN,a14
	janz	DELETE_OBJ_PROC

	calla	PSTOP
	calla	OBJPROC_KILL
	callr	INTO_SCRNOBJ
	calla	COLLS_OFF
	clr	a3

	movi	[8,0],a5
	MOVE	@BASE_HIT,A5,W
	ADDI	6800H,A5
	SLL	4,A5

	calla	CK_PLAYER_HIT
	SOUND1	SND_SPEAR_HIT
	movi	(63<<8)+63,a1
	calla	HIT_SCREEN
	rets



*
*	To keep spear relative to world, override automatic calc
*
*	a8 = obj
*	a9 = UNIV Z POS (Hi res world)
*	a10 = ZVEL
*
SPEAR_ADJ_ZX:
	sleep	1
	move	*a8(ODAGX),a11
SAZX_lp
	move	@ZBASE_HR,a0,L
	move	a0,a4
	add	a10,a9
	add	a9,a0
	sra	ZFRAC,a0
	move	a0,*a8(OZVAL),L		; counteract ZSCROLL
*
*	Keep X at same DAG
*
	move	*a8(ODAGX),a1
	sub	a11,a1
	jreq	xsame
	mpys	a9,a1		; hi res world Z * pixels
	neg	a1
	sra	ZFRAC,a1	; convert to lo res
	move	*a8(OXVAL),a2,L	; adjust X accordingly
	add	a1,a2
	move	a2,*a8(OXVAL),L
xsame:	
	sloop	1,SAZX_lp
	

SPEAR_ADJ_Z:
	sleep	1
	move	*a8(ODAGX),a11
SAZ_lp
	move	@ZBASE_HR,a0,L
	move	a0,a4
	add	a10,a9
	add	a9,a0
	sra	ZFRAC,a0
	move	a0,*a8(OZVAL),L		; counteract ZSCROLL

	sloop	1,SAZ_lp

	.ENDIF

	.if 0	; can't shoot the stained glass no mo

STAIN_CVECT
	WWL	OID_PROCKET,~MASK_PLAYER,UNIV_ROCKET_COLL
	WWL	OID_PEXPLOSION,~MASK_PLAYER,STAIN_COLLVECT
	WL	0,DUMCRETS


STAIN_COLLVECT:
	CALLA	UNIV_COLL_CHECK
	JRNZ	STAIN_DONE

	MOVE	*A0(OID),A0,W			;GET PLAYER DATA ADDRESS
	CALLA	POID_TO_PDATA
	movi	M_LASTFRM|M_NOMORE,a7

	MOVI	0,A5		       
	CLR	A9				;NO OFFSET
	CALLA	UNIV_DAMAGE_HANDLER

	move	a10,a10
	jrz	STAIN_DONE

	MMTM	SP,B1,B2,B4,B5,B6,B8,B9,B10

	movi	SKY_SND_TAB,a1
	movk	3,a0
	CALLA	RAND0
	SLL	5,A0
	ADD	A0,A1
	MOVE	*A1,A0,L
	calla	ONESND_Z

	MOVI	0dc00H,A0
	MOVI	0180H,A3
	CALLA	PreFrag_Box
	subi	200h,b9
	subi	200h,b10	; adjust ZVEL to be neg always
	MOVI	FRG_GL_10,B14
	subk	10h,b0		; adjust ZVAL
	CALLA	Fragger

	MOVE	*A8(OIMG),A1,L
	MOVE	*A1(ICMAP),*A0(FPDATA),L	;SET PALETTE

	MMFM	SP,B1,B2,B4,B5,B6,B8,B9,B10
STAIN_DONE	
	rets

	.endif

	.if 0  ; SPIT STUFF
OSPITCHN	.set	ODATA+40h	; forward link for spit chain

SND_SPIT_LAUNC	.word	0f3a4h,54,0a396h,0
SND_SPIT_HIT	.word	0f3a8h,60,0a14dh,0

SPIT_ANIM:
	LW	SPIT1,2
	LW	SPIT2,2
	LW	SPIT3,2
	LW	SPIT4,2
	LW	SPIT5,2
	LW	SPIT6,2
	LW	SPIT7,2
	LW	SPIT8,2
	LWL	SPIT9,2|AFunc,A_OFF_KILL_SPIT
	.long	0

SPIT_HIT_ANIM:
	LWLL	ISPLAT2,22|AFunc,A_SOUND+2,SND_SPIT_HIT
	LWL	ISPLAT3,16|AFunc,UNIV_FLASH
	LWL	ISPLAT4,12|AFunc,UNIV_FLASH
	LW	ISPLAT5,10
	LW	ISPLAT6,9
	LW	ISPLAT7,9
	LW	ISPLAT8,11
	LWL	ISPLAT9,14|AFunc,A_DEC_NUM
	LWL	1,1|AFunc,DELETE_OBJ


A_DEC_NUM:
	move	@NUM_OUT_THERE+8,a0
	dec	a0
	move	a0,@NUM_OUT_THERE+8
	rets


SPIT_INIT:
	.long	SPIT1
	.word	DMAWNZ,0,OM_GUNV|OM_COLL|OM_ANIM
	.long	SPIT_CVECT, SPIT_GUNVECT, SPIT_ANIM


SPIT_CVECT
;	WWL	OID_PROCKET,~MASK_PLAYER,SPIT_ALLCOLL
	WWL	OID_PEXPLOSION,~MASK_PLAYER,SPIT_COLLVECT
	WL	0,DUMCRETS


SPIT_COLLVECT:
	MOVE	*A0(OID),A0,W			;GET PLAYER DATA ADDRESS
	CALLA	POID_TO_PDATA			;GET PDATA IN A2

SPIT_GUNVECT:
	move	*a8(OPLINK),a5,L
	LOCKON	Z

	CLRM	*a8(OZVEL),L		

	calla	OBJPROC_KILL
	calla	COLLS_OFF

	movi	38000h,a0
	calla	RAND0
	addi	18000h,a0
	move	@RAND,a14
	btst	7,a14
	jrz	spg0
	neg	a0
spg0:
	move	a0,*a8(OXVEL),L

	movi	18000h,a0
	calla	RAND0
	addi	8000h,a0
	neg	a0
	move	a0,*a8(OYVEL),L

	MOVIM	1000h,*a8(OYACCEL),W

	movb	@NUM_OUT_THERE+8,a0
	dec	a0
	movb	a0,@NUM_OUT_THERE+8

	rets

ZSPLAT	.set	3800h

*
*	process to launch spit pieces
*	pieces are chained through OSPTCHN (ODATA+40h)
*
*	a8 = obj creating spit
LAUNCH_SPIT:
	move	*a8(OFLAGS),a14
	btst	B_OFSCRN,a14
	janz	SUCIDE

	move	*a8(OYVAL),a9,L		; starting Y pos
	move	*a8(OZVAL),a10,L    
	subk	2,a10		    	; starting Z pos
	move	*a8(OXVAL),a8,L	    	; starting X pos

	.if OLD_WAY

	clr	a11			; last obj in stream

	move	@ZBASE,a4,L		; COMPUTE ZVEL OF SPIT
	addi	ZSPLAT,a4
	sub	a10,a4
	sra	6,a4	   		; Z vel
	addi	50h,a4			; fudge factor

	movi	150*ZSPLAT,a3		; used for getting targets

	move	@XBASE,a0,L
	move	a0,a1
	add	a3,a0
	sub	a3,a1
	calla	RANGRAND	; get random X target
	sub	a8,a0		; delta X
	sra	6,a0	   
	move	a0,a6

;	move	a3,a0
;	calla	RAND0		; random Y target in a0
	move	@YBASE,a0,L
	neg	a0
	sub	a9,a0		; delta Y
	sra	6,a0		
	move	a0,a2

	clr	a3		; counter

	mmtm	a12,a2,a3,a4,a6
LAUNCH_lp:
	movi	SPIT_INIT,b0
	calla	EASYMAKE
	jaz	DIE

	move	a11,a11
	jrz	nolink1
	move	a0,*a11(OSPITCHN),L	; link this to prev. (exc first time)
nolink1:
	move	a0,a5
	mmfm	a12,a2,a3,a4,a6

	move	a4,*a5(OZVEL),L		; hit screen in 64 ticks.
	move	a10,*a5(OZVAL),L

	move	a6,*a5(OXVEL),L
	move	a8,*a5(OXVAL),L

	move	a9,*a5(OYVAL),L
	move	a2,*a5(OYVEL),L	

	MOVI	2800H,A14
	MOVE	A14,*A5(OYACCEL),W	;SET GRAVITY
	move	a14,*a5(OSPITCHN),L	; clear fwd link for this block (next piece will set this)

	PUSH	a8
	move	a5,a8
	CREATE	PID_IND,MON_SPIT
	move	a0,*a8(OPLINK),L
	PULLQ	a8

	move	a5,a0
	calla	INSOBJ

	SOUND1	SND_SPIT_LAUNC

	mmtm	a12,a2,a3,a4,a6
	move	a5,a11			; save for next one
	sloop	2,LAUNCH_lp


	.else

	move	@ZBASE,a5,L		; COMPUTE ZVEL OF SPIT
	addi	ZSPLAT,a5
	sub	a10,a5
	sra	6,a5	   		; Z vel

	movi	140*ZSPLAT,a0		; pos and neg range
	move	a0,a1
	neg	a1
	calla	RANGERND	; random world X target
	move	a0,a3		;   is in a3

	movi	-90*ZSPLAT,a1		; pos and neg range
	clr	a0
	calla	RANGERND      	; random world Y target
	move	a0,a4	      	;   is in a4

	move	@XBASE,a14,L
	add	a14,a3
	move	@YBASE,a14,L
	sub	a14,a4

	sub	a8,a3 		; turn target into X velocity
	sra	6,a3

	sub	a9,a4 		; turn target into Y velocity
	sra	6,a4

	movi	SPIT_INIT,b0
	calla	EASYMAKE
	jaz	DIE

	move	a5,*a0(OZVEL),L		; hit screen in 64 ticks.
	move	a10,*a0(OZVAL),L

	move	a3,*a0(OXVEL),L
	move	a8,*a0(OXVAL),L

	move	a4,*a0(OYVEL),L	
	move	a9,*a0(OYVAL),L

;	MOVI	0800H,A14
;	MOVE	A14,*A0(OYACCEL),W	;SET GRAVITY

	move	a0,a8
	CREATE	PID_IND,MON_SPIT
	move	a0,*a8(OPLINK),L

	move	a8,a0
	calla	INSOBJ

	SOUND1	SND_SPIT_LAUNC

	DIE


	.endif

A_OFF_KILL_SPIT:
	move	*a8(OFLAGS),a14
	btst	B_OFSCRN,a14
	jrz	SpitOn
	callr	A_DEC_NUM		; adjust accounting
	jauc	DELETE_OBJ_PROC

SpitOn:
	rets



*	a8 = spit obj
* 	a11 = obj block of prev spit in stream (0=first)
MON_SPIT:
	move	*a8(OZVEL),a9,L
	movi	ZSPLAT,a10
MON_SPIT_LP:
	sleep	1

	move	*a8(OXVAL),a14,L
	move	@XSCROLL,a0,L
	add	a0,a14
	move	a14,*a8(OXVAL),L	; counteract addition of XSCROLL

	move	*a8(OYVAL),a14,L
	move	@YSCROLL,a0,L
	sub	a0,a14
	move	a14,*a8(OYVAL),L	; counteract addition of YSCROLL

	move	*a8(OZVAL),a0,L
	move	@ZBASE,a14,L
	sub	a14,a0
	add	a9,a0
	cmp	a10,a0		; compare against target to splat at
	jrgt	MON_SPIT_LP
*
*	hit player
*
	movi	SPIT_HIT_ANIM,a0
	move	a0,*a8(AnimFrm),L
	move	a0,*a8(AnimScr),L

	calla	PSTOP
	calla	COLLS_OFF

	clr	a3

;	movi	[4,0],a5
	MOVE	@BASE_HIT,A5,W
	ADDI	2800H,A5
	SLL	4,A5

	calla	CK_PLAYER_HIT

	MOVIM	1414h,*a8(OCONST),W
	calla	UNIV_FLASH

	sleep	7

	movi	500h,a14
	move	a14,*a8(OYACCEL)

	clr	a14
	move	a14,*a8(OPLINK),L

	DIE

	.endif

	.END




