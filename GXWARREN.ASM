 	.MLIB	"GXMACS.LIB"
	.FILE	"GXWARREN.ASM"
	.TITLE	"<<< GENERATION X -- WARREN'S ROUTINES >>>"
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
	.INCLUDE	"GXBTR.TBL"
	.include	GXNONBOY.h
	.include	GXCONTRL.h

	.def	HIT_SCREEN,BTR_HANG_TIME,S_SHOCKER, BTR_DEAD
	.def	MAKE_EXPLOSION,MAKE_SAFE_EXPLOSION	
	.DEF	A_SLP_Based_CURPLYRS,DOWN_THE_HATCH, C_OCONST
	.DEF	ANIM_PART_EXPLOSIONS, BLOW_BTR_PART

	.rEF	A_STAY_TIL_SY_LT		; from gxafunc
	.ref	A_RANDOM_MULTI_CHUNK		; from gxmondr2.asm
	.ref	ATTACK_TIME		; from gxjungle
	.ref	BOX_CHECK_OBJ2		; from gxuniv1.asm
	.ref	NONBOY_ROCKET_COLL,OUTCLUB_GUNVECT,OUTCLUB_CVECT
	.ref	DO_FLASH_DINK,A_OFFSCRN_DEL
	.ref	Do_Dink,PROC_BZERK_JMP_WRLD,SET_WAVE   
	.ref	REXPLOA4h,REXPLOA6h,REXPLOA8h,REXPLOA9h	
	.ref	REXPLOA10h,REXPLOA11h,REXPLOA12h       
	.ref	DGV_FRAG_SPARK,TAB_SOUND,BG_TO_FG

***** From GXAFUNC
	.REF	SetAnim_AFARG, A_Set_Rel_Long, A_RAND_REL_BYTE
	.ref	A_SET_SCALE, A_BRANCH_IF_TRUE
	
***** From GXDESK
	.REF	SND_FINAL_EXPLODE1, SND_FINAL_EXPLODE2, SND_FINAL_EXPLODE3
	.REF	FRAG_DESK_EXPLOSION, FRAG_DESK_METAL, FRAG_DESK_RAIN
	.REF	A_MULTI_METAL_CHUNK, F_EXPLOSION_OUT

***** from GXMONDR2.ASM
	.REF	FRAG_EXPLOSION, PART_EXPLOSION, EXPLO_BLOW_INIT
	.REF	FRAG_EXPLOSION_SMALL

***** From GXUNIJP2.ASM
	.REF	METAL_GUNVECT

***** from GXRAM.ASM
	.REF	HOLD_ENEMY_DISPATCH, BASE_HIT

***** from GXPLAYER.ASM
	.REF	DELAYED_PRAISE

***** from GXNONBOY.ASM
	.REF	NONBOY_SBOMB

OLD_WAY 	.set	0
KILL_BTR	.set	0

	.bss	BTR_HANG_TIME,16  ; TIME BTR STAYS STOPPED ON SCREEN
	.bss	BTR_GONE,16
	.BSS	BTR_DEAD,16		;Flag if BTR has been killed
	.BSS	UNUSED_WORD,16

	.TEXT
	.even

OHITCNT	.set	ODATA
OTOTHITS .set	ODATA+10h
OMISSOBJ .set	ODATA+20h
OBAYOPEN .set	ODATA+40h
OROCKTIM .set	ODATA+50h
OIDLETIM .set	ODATA+60h	; time for missle to just sit there
OPART_FINAL_CONT .EQU	ODATA+80H	;UHL Jump vector after part explosion
OCHEWEDROCKET	.EQU	ODATA+0A0H	;UHB I just ate a rocket
OPARTEXPLODING	.EQU	ODATA+0A8H	;UHB A part is currently exploding
ORAPIDCNT	.EQU	ODATA+0B0H	;UHB Rapid fire count
OBLOW_AFUNC	.EQU	ODATA+0C0H	;UHL Anim func to blow this part

BTR_Z	.set	0a000h

BTR_HITS  .set 50	; hits to destroy a piece
RHITS_TUR .set 2	; each rocket hit on turret counts as this
RHITS_BTR .set 3	; each rocket hit on other piece 

;
;	BTR CHECKLIST...
;	     Explode each piece	  turret (fire, blow away)
;	     fires		  nonboys jump out
;	     blow out wheels	  missles... steer to player, explode at player
;	     TOTAL BTR Destruction




*
*	Troop Transport will move onto screen, stop, start,
*	go off other side , then repeat in reverse.
*	
CREATE_TROOPTRANS:
	clr	a14
	move	a14,@BTR_GONE
	MOVE	A14,@BTR_DEAD,W
	MOVKM	1,@BTR_HANG_TIME,W	; don't hang first time through

	movi	BTR_INIT,b0
	CALLA	MULTIMAKE
	jrz	TT_abt

	CLRM	*a8(OTOTHITS),W
	MOVB	A14,*A8(OPARTEXPLODING)

	move	*a8(OYVAL),a14,L   	; compute ground offset
	move	@YBASE,a0,L
	sub	a0,a14
	move	@YWORLD,a0,L
	sub	a14,a0
	move	a0,*a8(OGRNDOFF),L

	move	a13,*a8(OPLINK),L

	clr	a14
	move	a14,*a8(OBAYOPEN)	; bay is closed
	move	*a8(OPART1),a0,L
	CLR	A1
clrlp:
	MOVIM	BTR_HITS,*a0(OHITCNT),W	; 20 hits to blast each piece
	MOVB	A1,*A0(OCHEWEDROCKET)	;Clear some valuable stuff
	move	*a0(OPARTS),a0,L
	jrnz	clrlp

	MOVIB	70,*a8(AnimSLP)	; time for missle to sit in bay.

	movi	-8000h,a14
	move	a14,*a8(OXVEL),L

;	move	a8,a3
;	movi	mosspal,a8
;	movi	112,a9
;	movi	125,a10
;	movk	4,a11
;	CREATE	PID_TCYCLE,CYCLE16
;	move	a3,a8

	CREATE	PID_IND,TRANS_LAUNCH
	move	a0,a10

	SOUND1	SND_BTR_ARRIVE
	SOUND1	SND_BTR_BGND
*
*	
*	
nostopyet:
	sleep	2*60
	move	*a8(OXPOS),a0
	move	@XBASE+16,a1
	sub	a1,a0
	abs	a0
	subi	80,a0		; when gets to center of screen, stop
	jrge	nostopyet
*
*	SLOW DOWN AND STOP!!!!
*
	MOVE	A8,A0
STPTT_lp:
	movb	*a0(OZOFF),a14
	addk	2,a14
	jrnz	not_a_tire0
	move	*a0(AnimScr),a1,L	; Switch to slowdown
	addi	tirerotStop-tirerot,a1
	move	a1,*a0(AnimScr),L
not_a_tire0:
	MOVE	*A0(OPARTS),A0,L
	JRNZ	STPTT_lp

	move	*a8(OXVEL),a9,L
	sra	7,a9
	SOUND1	SND_BTR_STOP
	SOUND1	SND_BGND3_OFF
slowdown:
	sleep	1
	move	*a8(OXVEL),a0,L
	sub	a9,a0
	move	a0,*a8(OXVEL),L
	jrnz	slowdown
*
*	START UP AGAIN
*
	move	@BTR_HANG_TIME,a0	; stick around time.
	calla	PRCSLP

	SOUND1	SND_BTR_START
	SOUND1	SND_BTR_BGND
	MOVK	NUM_TIRE1,A1
	CALLA	FINDPART
	movi	tirerotStart,a1
	move	a9,a9			; acceleration
	jrnn	goin_rt
	movi	tirerotlftStart,a1
goin_rt:
;	MOVE	A8,A0
	MOVK	4,A5
STTT_lp:
;	movb	*a0(OZOFF),a14
;	addk	2,a14
;	jrnz	not_a_tire1
	calla	STRTANIM
not_a_tire1:
	MOVE	*A0(OPARTS),A0,L
;	JRNZ	STTT_lp
	JRZ	strtup
	DSJS	A5,STTT_lp

strtup:
	sleep	1
	move	*a8(OXVEL),a0,L
	add	a9,a0
	move	a0,*a8(OXVEL),L
	abs	a0
	cmpi	8000h,a0
	jrlt	strtup

   	sleep	4*60
TT_abt:
	sleep	20

	move	*a8(ODAGX),a1
	subi	HALFX,a1
	abs	a1
	cmpi	200,a1
	jrlt	TT_abt

	SOUND1	SND_BTR_LEAVE
	SOUND1	SND_BGND3_OFF

TT_abt2:
	sleep	20

	move	*a8(ODAGX),a1		; wait til its time to mark
	subi	HALFX,a1
	abs	a1
	cmpi	350,a1
	jrlt	TT_abt2			; as gone

	movk	1,a0
	move	a0,@BTR_GONE

;	SOUND1	SND_BGND3_OFF

TT_abt3:
	sleep	20

	move	*a8(ODAGX),a1
	subi	HALFX,a1
	abs	a1
	cmpi	500,a1
	jrlt	TT_abt3


	.if	KILL_BTR==1		; test purposes, always kill

	jruc	BTR_GO_AWAY

	.elseif KILL_BTR==2		; test purposes, always come back

	move	*a8(OXVEL),a11,L
	clr	a14
	move	a14,*a8(OXVEL),L
	move	a14,@BTR_GONE
	jruc	BTR_RETURN

	.endif

*
*	reverse
*

	move	*a8(OXVEL),a11,L
	clr	a14
	move	a14,*a8(OXVEL),L

wait_4_ret_signal:
	sleep	100
	move	@BTR_GONE,a14		; if somebody resets BTR_GONE to 0
	jrz	BTR_GO_AWAY		;    kill it.
	jrnn	wait_4_ret_signal	; if it gets set to 0, kill
					; if neg, idle until return signal
*
*	KILL MISSLE LAUNCHER PROCESS
*
	move	a10,a0			; missle launcher process
	calla	KILL

	CALLR	DEL_HATCH_BOY

*
*	Remove BTR from object list 
*
	PUSHST	
	DINT
	move	a8,a0
pullnxt:
	movb	*A0(OFLAGS+B_ANIM-7),A14
	jrnn	notanim
	calla	PULLANIM
	ORIM	M_ANIM,*a0(OFLAGS),W	; keep marked for return
notanim:
	calla	PULLOBJ
	move	*a0(OPARTS),a0,L
	jrnz	pullnxt
	POPST	


BTR_IDLE:
	move	@ZSCROLL,a14,L
	jrnz	zmoving
	move	@BTR_GONE,a14		; return signal is BTR_GONE = 0
	jrz	BTR_RETURN
zmoving:
	sloop	20,BTR_IDLE		;wait until ZSCROLL stops

BTR_RETURN:
*
*	Set off to side in universe
*
	move	@ZBASE,a3,L
	addi	BTR_Z,a3	; univ z
	move	@YWORLD,a2,L
	MOVE	*A8(OGRNDOFF),A14,L    
	SUB	A14,A2		       
	movi	1200000h,a1
	move	a11,a11		; check last vel
	jrnn	keepXpos
	neg	a1		; X neg if we moved off left
keepXpos:
	move	@XBASE,a14,L
	add	a14,a1		; univ X
*
*	turn into delta for parts
*
	move	*a8(OXVAL),a14,L
	move	a1,*a8(OXVAL),L
	sub	a14,a1
	move	*a8(OYVAL),a14,L
	move	a2,*a8(OYVAL),L
	sub	a14,a2
	move	*a8(OZVAL),a14,L
	move	a3,*a8(OZVAL),L
	sub	a14,a3

	move	*a8(OPARTS),a0,L
set_pos_lp:
	move	*a0(OXVAL),a14,L
	add	a1,a14
	move	a14,*a0(OXVAL),L
	move	*a0(OYVAL),a14,L
	add	a2,a14
	move	a14,*a0(OYVAL),L
	move	*a0(OZVAL),a14,L
	add	a3,a14
	move	a14,*a0(OZVAL),L
	move	*a0(OPARTS),a0,L
	jrnz	set_pos_lp

*
*	Put it back in the list
*
	PUSHST	
	DINT	
	move	a8,a0
	calla	INSOBJ			; for first only to find place
	movb	*A0(OFLAGS+B_ANIM-7),A14
	jrnn	btr_ins_lp
	ANDNIM	M_ANIM,*a0(OFLAGS),W	; clr flag for return
	calla	INSANIM
btr_ins_lp:
	move	*a0(OPARTS),a1,L
	jrz	its_back

	move	*a0,a2,L		; old fwd link of prev obj

	move	a0,*a1(OBLINK),L	
	move	a2,*a1,L
	move	a1,*a0,L
	move	a1,*a2(OBLINK),L

	move	a1,a0

	calla	INSSUPP			;INSERT ON SUPPLEMENTAL LIST

	movb	*A0(OFLAGS+B_ANIM-7),A14
	jrnn	btr_ins_lp
	ANDNIM	M_ANIM,*a0(OFLAGS),W	; clr flag for return
	calla	INSANIM

	jruc	btr_ins_lp
its_back:
	POPST
	CREATE	PID_IND,TRANS_LAUNCH
	move	a0,a10
*
*	Get the wheels a rollin'
*
	movi	tirerotlftStart,a1
	neg	a11
	move	a11,*a8(OXVEL),L
	jrn	goin_lft
	movi	tirerotStart,a1
goin_lft:
	MOVE	A8,A0
RTT_lp:
	movb	*a0(OZOFF),a14
	addk	2,a14
	jrnz	not_a_tire2
	move	a1,*a0(AnimScr),L

not_a_tire2:
	MOVE	*A0(OPARTS),A0,L
	JRNZ	RTT_lp

	CREATE	PID_IND,BTR_WALL_BLAST

	SOUND1	SND_BTR_ARRIVE
	SOUND1	SND_BTR_BGND

	jruc	nostopyet	; to loop back

*
*	This process contains the BTR head in a8
*	and the missle launcher process in a10
*
BTR_DEATH:
	move	a10,a0			; missle launcher process
	calla	KILL
	      
*
*	PLACE BTR DEATH EFFECT HERE
*
		
	.if	DEBUG
	move	*a8(OPART1),a14,L	; hang if not deleting head
	cmp	a8,a14
	LOCKON	NE
	.endif

	MOVI	ANIM_FINAL_EXPLOSION,A1
	CALLA	STRT_ANIM

	CLRM	*a8(OPLINK),L

	SOUND1	SND_BGND3_OFF
	SOUND1	SND_CHAN3_OFF

	MOVKM	1,@BTR_DEAD,W		;The BTR is officially dead!!

;	movk	1,a14
;	move	a14,@BTR_GONE
;	calla	DELETE_OBJ
	DIE 



BTR_GO_AWAY:	
	move	a10,a0			; missle launcher process
	calla	KILL
	movk	1,a14
	move	a14,@BTR_GONE
			
	CALLR	DEL_HATCH_BOY

	.if	DEBUG
	move	*a8(OPART1),a14,L	; hang if not deleting head
	cmp	a8,a14
	LOCKON	NE
	.endif

	calla	DELETE_OBJ
	DIE 

**************************************************************************
*								         *
* 	DEL_HATCH_BOY							 *
* 									 *
* 	Delete the Non-boy in the hole.					 *
* 									 *
* 	A8 = Ptr to any part of BTR					 *
*								         *
**************************************************************************
DEL_HATCH_BOY
	MMTM	SP,A1,A8
	MOVI	OID_NONBOY,A1
	CALLA	EXIST_PART
	JRZ	DHB_X			;BR = No NonBoys around

	MOVE	A0,A8
	CALLA	PULL_PART
	CALLR	DOWN_THE_HATCH
	CALLA	DEL_ENEMY_NOAUD

DHB_X
	MMFM	SP,A1,A8
	RETS
	
*
*	Process to launch a missle out of the BTR
*
*	a8 = head of btr
*
TRANS_DELAY:
	sleep	10
TRANS_LAUNCH:
	move	*a8(OXVAL),a0,L
	move	@XBASE,a1,L
	sub	a1,a0			; world X position
	abs	a0
	cmpi	190*BTR_Z,a0
	jrgt	notok2shoot
*
*	FIRE MISSLE
*
	move	*a8(OBAYOPEN),a14	; bay door open?
	jrnz	TRANS_DELAY
	movi	tdoor,a1
	move	a8,a0
	calla	STRTANIM
notok2shoot:
	movi	30,a0
	movi	170,a1
	calla	RANGERND	; result in a0
	movi	TRANS_LAUNCH,a7
	jauc	PRCLSP


BTR_CVECT
	WWL	OID_PROCKET,~MASK_PLAYER,BTR_ROCKET_COLL
	WWL	OID_PEXPLOSION,~MASK_PLAYER,BTR_EXPLOSION_COLL
	WWL	OID_BLOWUP,0FFFFH,BTR_SBOMB_COLLVECT
	WWL	OID_GRND,0FFFFH,BTR_GROUND_COLL
	WL	0,DUMCRETS

TURRET_CVECT
	WWL	OID_GRND,0FFFFH,TUR_GROUND_COLL
	WL	0,DUMCRETS

BTR_HOLE_CVECT
	WWL	OID_PROCKET,~MASK_PLAYER,BTR_ROCKET_COLL
	WWL	OID_PEXPLOSION,~MASK_PLAYER,BTR_HOLE_COLL
	WL	0,DUMCRETS

BTR_HOLE_COLL:
	MOVB	*A8(OCHEWEDROCKET),A14
	JRZ	BTR_GV_XIT			;BR = We really didn't get hit
	CLRB	*A8(OCHEWEDROCKET)
	mmtm	sp,a0,a8
 	move	*a8(OPART1),a5,L		; get head of BTR
	move	*a5(OBAYOPEN),a14
	jrz	HOLE_X				; door is not open

*
*	determine if rocket hit opening
*
	move	*a0(OXVAL),a7,L
	move	*a0(OYVAL),a1,L
		
	move	*a5(OXVAL),a3,L		; check X first
	move	a3,a4
	addi	16*BTR_Z,a4		; xoffset changes with FLIPH
	subi	16*BTR_Z,a3

	cmp	a7,a3 		; is rocket within X limits?
	jrgt	HOLE_X
	cmp	a7,a4
	jrlt	HOLE_X

	move	*a5(OYVAL),a3,L
	move	a3,a4
	addi	-21*BTR_Z,a4
	addi	-52*BTR_Z,a3

	cmp	a1,a3 		; is rocket within X limits?
	jrgt	HOLE_X
	cmp	a1,a4
	jrlt	HOLE_X
	
	move	*a5(OTOTHITS),a14
	cmpk	10,a14		     	; if 10 parts not hit
	jrlt	BTR_JUMP		; don't bother


*	If it did, blow up BTR
*
*	a8 = bottom part
*	a5 = head of BTR
*	a0 = rocket becomes a3
*
BLOW_UP_BTR:
	move	a0,a3
	move	*a5(OMISSOBJ),a8,L
	jrz	no_missle
	CLRM	*a5(OMISSOBJ),L
	calla	DELETE_OBJ		; trash missle
no_missle:
	move	a5,a8

	CALLA	OBJ_OFF

;	move	*a8(OCTRL),a4
;	movi	MISFLA,a1
;	calla	ANI			; change door to inside flame

;	movi	MISFLAME,a0
;	CALLA	CHANGE_PAL

;	movi	MISFLAME,a8
;	movi	1,a9
;	movi	13,a10
;	movk	2,a11
;	CREATE	PID_TCYCLE,CYCLE16

	SOUND1	SND_MISSLE_HIT		; really loud explo

	move	a5,a8			; head of BTR into a8
	move	*a8(OPLINK),a0,L
	MOVIM	BTR_DEATH,*a0(PWAKE),L	; tell control process to kill btr
	MOVKM	1,*a0(PTIME),W


;	calla	ALL_COLLS_OFF		; nomo colls

	MMTM	SP,A6,A8
	MOVK	NUM_BTR_PARTS,A6
BUB_COLLS_OFF
	CALLA	COLLS_OFF
	MOVE	*A8(OPARTS),A8,L
	DSJS	A6,BUB_COLLS_OFF
	MMFM	SP,A6,A8

	clr	a14
	move	a14,*a8(OXVEL),L	; stop moving
*
*	stop tires if moving and turret if still there
*
pulanilp:
	move	*a5(OID),a14
	cmpi	OID_BTR,a14
	jrne	nopull
	move	a5,a0
	move	*a5(OFLAGS),a14
	btst	B_ANIM,a14
	jrz	nopull
	calla	PULLANIM		; stop all animations
nopull:
	move	*a5(OPARTS),a5,L
	jrnz	pulanilp

HOLE_X:
	mmfm	sp,a0,a8
	rets


BTR_JUMP:
	move	*a5(OYACCEL),a14,W
	jrnz	doinit
	MOVIM	-40000h,*a5(OYVEL),L	; make it jump a bit
	movim	7800h,*a5(OYACCEL),W
	ORIM	M_GCOLL,*a5(OFLAGS),W
*
*	for tires (whose OZOFF is -2)  add to their pos
*
	move	a5,a0
	movi	80000h,a3
	callr	AdjustTires
doinit:
	SOUNDZ	SND_HOLE_HIT
	MOVE	A5,A8	
	MMTM	SP,B0,B1,B2,B3,B4,B5,B6,B7,B8,B9,B10	;MAKE FRAGMENTS
	MOVI	040000H,A0
	MOVI	1000H,A3
	CALLA	PreFrag_Center
	MOVI	FRAG_MISSLE_DOOR,B14		;Use this fragment script
	CALLA	Fragger
	MMFM	SP,B0,B1,B2,B3,B4,B5,B6,B7,B8,B9,B10
	mmfm	sp,a0,a8
	rets


BTR_GROUND_COLL
	PUSH	a8
	move	*a8(OPART1),a8,L
	clr	a14
	move	a14,*a8(OYVEL),L
	move	a14,*a8(OYACCEL),W
	move	*a8(OFLAGS),a14
	andni	M_GCOLL,a14
	move	a14,*a8(OFLAGS)

	move	a0,a5
	move	a8,a0
	movi	-80000h,a3
	callr	AdjustTires
	move	a5,a0		; restore a0
ignoregc:
	PULLQ	a8
	rets

*
*	a0 = head of BTR
*	a3 = Y delta
*
AdjustTires:	
	movb	*a0(OZOFF),a14
	addk	2,a14
	jrnz	not_a_tire3
	move	*a0(OYVAL),a14,L
	add	a3,a14
	move	a14,*a0(OYVAL),L
not_a_tire3:
	MOVE	*A0(OPARTS),A0,L
	JRNZ	AdjustTires
	rets
	



MISSLE_INIT:
	LWWWW	mossile1,DMAWNZ, M_MANSCALE, OM_OID | OM_COLL | OM_GUNV, OID_EROCKET
	.long	MISSLE_CVECT,MISSLE_GUNVECT

MISSLE_CVECT
	WWL	OID_PROCKET,~MASK_PLAYER,MISSLE_COLL
	WL	0,DUMCRETS


CREATE_MISSLE:
	movi	MISSLE_INIT,b0
	calla	EASYMAKE
	JRZ	CM_X
	move	*a8(OXVAL),a14,L
	move	a14,*a0(OXVAL),L
	move	*a8(OYVAL),a14,L
	subi	(48<<15),a14
	move	a14,*a0(OYVAL),L
	move	*a8(OZVAL),a5,L
	move	a5,*a0(OZVAL),L
	
	calla	INSOBJ
	calla	INSPART
	move	a0,*a8(OMISSOBJ),L	; save missle obj in door obj

	movi	100h,a5
	calla	SET_SCALE_MANUAL

	SOUNDZ	SND_BAY_OPEN
CM_X	
	rets


BAY_CLOSED:
	clr	a14
	move	a14,*a8(OBAYOPEN)
	rets


BAY_OPEN:
	movk	1,a14
	move	a14,*a8(OBAYOPEN)
	rets

*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   SET_TARG_VEL    >>>>>>>>>>>>>>>>>>>>>>>>>>>>
*
*	Set X and Y velocities to get from current position to supplied target
*	in about 32 ticks
*
*	a0 = object
*	a3 = X target
*	a4 = Y target
*
SetTargVel:
	move	*a0(OXVAL),a5,L
	move	*a0(OYVAL),a6,L
	sub	a5,a3
	sub	a6,a4		       ; Compute delta from current to target
	sra	7,a3
	move	a3,a14
	sra	1,a14
	add	a14,a3			; assume 48 tiks to destination
	sra	7,a4		       ; div by 32
	move	a4,a14
	sra	1,a14		       ; then add half of that back
	add	a14,a4
	move	a3,*a0(OXVEL),L
	move	a4,*a0(OYVEL),L	       ; Store velocities

	rets


LAUNCH_MISSLE:
 	move	*a8(OMISSOBJ),a0,L 	; retrive missle obj
	jrz	got_hit

	calla	PULLPART
	clr	a14
	move	a14,*a8(OMISSOBJ),L	; clear out OMISSOBJ field

	move	*a0(OFLAGS),a14
	btst	B_OFSCRN,a14
	janz	DELOBJ			; goombye if offscreen

	movi	(ZMAX_REAL-BTR_Z)/66,a3	; basis for ZVEL
	move	a3,*a0(OZVEL),L
	movi	MISSL,a1
	calla	STRTANIM
	move	@XBASE,a3,L
	clr	a4
	movi	-300000h,a4
	MOVIM	400h,*a0(OYACCEL),W
	callr	SetTargVel		; set X and Y velocities to take it there

	movb	*a8(AnimSLP),a14
	subk	4,a14
	movb	a14,*a8(AnimSLP)

	move	a8,a5
	move	a0,a8
	CREATE	PID_IND,SPIN_MISSLE
	move	a0,*a8(OPLINK),L
	move	a5,a8

	SOUND1	SND_MISSLE_LAUNCH
got_hit:
	rets



SpiralTab:			; Mag = 30
   .long    0177eah,0ffffdf26h
   .long    01717bh,0ffff9e02h
   .long    0164bah,0ffff5e8bh
   .long    0151dfh,0ffff21d8h
   .long    01393bh,0fffee8f1h
   .long    011b3ch,0fffeb4d1h
   .long    0f863h,0fffe865bh
   .long    0d14bh,0fffe5e5ch
   .long    0a69eh,0fffe3d82h
   .long    07917h,0fffe245dh
   .long    0497eh,0fffe135bh
   .long    018a3h,0fffe0ac8h
   .long    0ffffe75dh,0fffe0ac8h
   .long    0ffffb682h,0fffe135bh
   .long    0ffff86e9h,0fffe245dh
   .long    0ffff5962h,0fffe3d82h
   .long    0ffff2eb5h,0fffe5e5ch
   .long    0ffff079dh,0fffe865bh
   .long    0fffee4c4h,0fffeb4d1h
   .long    0fffec6c5h,0fffee8f1h
   .long    0fffeae21h,0ffff21d8h
   .long    0fffe9b46h,0ffff5e8bh
   .long    0fffe8e85h,0ffff9e02h
   .long    0fffe8816h,0ffffdf26h
   .long    0fffe8816h,020dah
   .long    0fffe8e85h,061feh
   .long    0fffe9b46h,0a175h
   .long    0fffeae21h,0de28h
   .long    0fffec6c5h,01170fh
   .long    0fffee4c4h,014b2fh
   .long    0ffff079dh,0179a5h
   .long    0ffff2eb5h,01a1a4h
   .long    0ffff5962h,01c27eh
   .long    0ffff86e9h,01dba3h
   .long    0ffffb682h,01eca5h
   .long    0ffffe75dh,01f538h
   .long    018a3h,01f538h
   .long    0497eh,01eca5h
   .long    07917h,01dba3h
   .long    0a69eh,01c27eh
   .long    0d14bh,01a1a4h
   .long    0f863h,0179a5h
   .long    011b3ch,014b2fh
   .long    01393bh,01170fh
   .long    0151dfh,0de28h
   .long    0164bah,0a175h
   .long    01717bh,061feh
   .long    0177eah,020dah

*
*	SPIN_MISSLE as it heads to player
*	we start with missle at left
*	
SPIN_MISSLE
	movi	48,a10
	move	a10,a0
	calla	RAND0
	move	a0,a11
	movi	SpiralTab,a9

SPIN_MISSL_lp
	inc	a11
	cmp	a10,a11
	jrne	SM_ok
	clr	a11
SM_ok:
	move	a11,a0		; Y Offset
	sll	6,a0
	add	a9,a0
	move	*a0+,a2,L		; Y delta
	move	*a0,a1,L		; X delta

	move	*a8(OXVAL),a3,L
	add	a1,a3
	move	a3,*a8(OXVAL),L
	move	*a8(OYVAL),a4,L
	add	a2,a4
	move	a4,*a8(OYVAL),L

	sloop	1,SPIN_MISSL_lp



		.if 0		; OLD?

* a8 = object
*      Compute proper OSIZE and OANIOFF from SCALE FACTOR.
*	Should be used only for NOSCALE objects which you want
*	to scale manually.
*
*	Unlike SET_SCALE_M, this works only on a single object
*
SET_SCALED_SIZE:
	mmtm	sp,a1,a2,a3
	move 	*a8(OSCALE),a14,L
	movy	a14,a2
	srl	16,a2	; YSCALE in a2
	zext	a14	; XSCALE in a14

	move	*a8(OUSIZE),a1,L
	movy	a1,a3
	srl	16,a3	; UYSIZE in a3
	zext	a1	; UXSIZE in a1
	sll	8,a3
	divu	a2,a3	; YSIZE in a3
	sll	8,a1
	divu	a14,a1	; XSIZE in a1
	sll	16,a3
	movy	a3,a1
	move	a1,*a8(OSIZE),L

	move	*a8(OUANIOFF),a1,L
	movy	a1,a3
	srl	16,a3	; UYSIZE in a3
	sext	a1	; UXSIZE in a1
	sll	8,a3
	divs	a2,a3	; YSIZE in a3
	sll	8,a1
	divs	a14,a1	; XSIZE in a1
	sll	16,a3
	movy	a3,a1
	move	a1,*a8(OANIOFF),L

	mmfm	sp,a1,a2,a3
	rets

		.endif

*
*	a0 = scale factor for explosion
*
MAKE_SAFE_EXPLOSION:
	movi	MSAFEXP_INIT,b0		; player destroys before being hit
	move	a0,a6			; scale in to a6
	calla	PSTOP
	calla	COLLS_OFF

	calla	EASYMAKE		; explosion obj in a0
	JRZ	MSE_X
	move	a8,a7			
	addi	OXVAL,a7
	mmfm	a7,a1,a3,a5		; get univ position of missle
	subk	4,a1

	move	a0,a2
	move	a6,*a2(ONuManScl)
	addi	OXVAL+060h,a2
	mmtm	a2,a1,a3,a5

	calla	INSOBJ
MSE_X
	rets


MAKE_EXPLOSION:
	movi	MEXP_INIT,b0		; hits player
	move	a0,a6			; scale into a6
	calla	PSTOP
	calla	COLLS_OFF
	move	a8,a4			; save missle obj in a4
	
	calla	MULTIMAKE
	move	a4,a7			; save missle obj in a7
	addi	OXVAL,a4
	mmfm	a4,a1,a3,a5		; get univ position of missle
	subk	4,a1

	move	a8,a2
	move	a6,*a2(ONuManScl)
	addi	OXVAL+060h,a2
	mmtm	a2,a1,a3,a5

	move	*a8(OPARTS),a2,L
	move	a6,*a2(ONuManScl)
	addi	OXVAL+060h,a2
	mmtm	a2,a1,a3,a5

	calla	INSERT_OBJ

	move	a8,a0			; save new object
	move	a7,a8			; restore missle obj
	rets


*
*	called from missle anim when missle explodes
*
A_MISSLE_EXPL:
	movi	[0b0h,0b0h],a0
	callr	MAKE_EXPLOSION	

*
*	check for player hit and enery drain
*
	clr	a3
;	movi	[8,0],a5
	MOVE	@BASE_HIT,A5,W
	ADDI	6800H,A5
	SLL	4,A5

	calla	CK_PLAYER_HIT

	CLRM	*a8(OYVEL),L
	move	a14,*a8(OXVEL),L
	move	a14,*a8(OYACCEL),W

	calla	OBJPROC_KILL

	move	*a8(OZVAL),a14,L
	subk	30,a14
	move	a14,*a8(OZVAL),L
 	calla	GETAFARG_WORD
	move	a0,a1
	callr	HIT_SCREEN

	SOUND1	SND_MISSLE_HIT

	rets



MISSLE_COLL:
	MOVE	*A0(OID),A0,W			;GET PLAYER DATA ADDRESS
	CALLA	POID_TO_PDATA			;GET PDATA IN A2
	mmtm	sp,b0,b1,b2,b3,b4,b5,b6,b7,b8,b9,B10
	callr	MISSLE_GUNVECT
	mmfm	sp,b0,b1,b2,b3,b4,b5,b6,b7,b8,b9,b10
	rets


*
* MISSLE Gun Vector
*
* PASS:									 
* A2 = PTR TO PLAYER						         
* A8 = PTR TO OBJECT							 
*
MISSLE_GUNVECT:
	move	*a8(OPART1),a5,L	; still part of BTR?
	jrz	MISOK
*			Detach from BTR
	CLRM	*a5(OMISSOBJ),L		; tell it it's gone
	calla	PULL_PART

MISOK:
	move	*a8(OZVAL),a0,L
	move	@ZBASE,a14,L
	sub	a14,a0
	subi	0d55h,a0
	movi	51ch,a1
	mpys	a0,a1
	move	a1,a0
	sra	16,a1
	movx	a1,a0
	PUSH	a2
	calla	MAKE_SAFE_EXPLOSION
	PULLQ	a2
	movi	1000,a1
	calla	SCORE
	calla	DELETE_OBJ_PROC		; delete the missle and controlling proc
	SOUND1	SND_MISSLE_EXPLODE

MISGUNX:
	rets


;EXP_ENT	.MACRO	TYP,NUM,ST
;	.if	($symcmp(TYP,"C") = 0)
;	.word   (:NUM:<<8)|(:ST:)|080h
;	.else
;	.word   (:NUM:<<8)|(:ST:)
;	.endif
;	.ENDM

;EXP_PC	.MACRO	X,Y
;	.word (:X:)*(BTR_Z>>8),(:Y:)*(BTR_Z>>8)
;	.ENDM


;BTR_explo:
;	EXP_ENT	B,2,0		; EXPLO TYP, NUMBER, START
;	EXP_ENT	B,1,2
;	.word 0
;	EXP_ENT	B,1,3
;	EXP_ENT	B,2,4
;	EXP_ENT	B,1,6
;	EXP_ENT	B,1,7
;	EXP_ENT	C,3,8
;	EXP_ENT	B,2,11
;	EXP_ENT	B,2,13
;	EXP_ENT	B,1,15
;	.word 0,0,0,0


;EXPLO_PCS:
;; Part 1:
;	EXP_PC	8,-24
;	EXP_PC	-15,-18
;; Part 2:
;	EXP_PC	-1,-6
;; Part 4:
;	EXP_PC	-4,-18
;; Part 5:
;	EXP_PC	14,-16
;	EXP_PC	-15,-27
;; Part 6:
;	EXP_PC	-13,-37
;; Part 7:
;	EXP_PC	-1,-15
;; Part 8:
;	EXP_PC	-4,-26
;	EXP_PC	3,-18
;	EXP_PC	6,-9
;; Part 9:
;	EXP_PC	-23,-15
;	EXP_PC	4,-15
;; Part 10:
;	EXP_PC	15,-11
;	EXP_PC	-23,-18
;; Part 11:
;	EXP_PC	11,-37


;TUREXPTAB:
;	EXP_PC	-25,-8	;2
;	EXP_PC	23,-7	;3
;	EXP_PC	-1,-19	;-9

TUR_GROUND_COLL:
	CALLA	CLR_VEL
	MOVI	ANIM_TUR_GROUND,A1
	CALLA	STRT_ANIM
	ANDNIM	M_GCOLL,*a8(OFLAGS),W
	MOVIM	DUMCOLL,*a8(OCVECT),L
;	calla	DELETE_OBJ
;
;	movi	FHKEXB_INIT,a6
;	movi	TUREXPTAB,a5
;	movk	3,a4
;	mmtm	sp,b0,b1,b2,b3,b4,b5,b6,b7,b8,b9,B10
;	callr	BTRGlp
;	mmfm	sp,b0,b1,b2,b3,b4,b5,b6,b7,b8,b9,b10
 	rets

;BTR_dam_tbl:
;	.long	DAMN1,DAMN2,DAMN3,DAMN4,DAMN5,DAMN6,DAMN7,DAMN8
;	.long	DAMN9,DAMN10,DAMN11,TIREFL,TIREFL,TIREFL,TIREFL
*
* Table of damage animations for parts of the BTR
*
BTR_dam_tbl:
	.long	ANIM_DAMN1,ANIM_DAMN2,ANIM_DAMN3,ANIM_DAMN4,ANIM_DAMN5
	.LONG	ANIM_DAMN6,ANIM_DAMN7,ANIM_DAMN8,ANIM_DAMN9,ANIM_DAMN10
	.LONG	ANIM_DAMN11
	.LONG	ANIM_TIREFL,ANIM_TIREFL,ANIM_TIREFL,ANIM_TIREFL

**************************************************************************
*								         *
* 	BTR_ROCKET_COLL							 *
* 									 *
* 	Collision vector for any BTR part and a player rocket.		 *
* 									 *
* 	A0 = Ptr to rocket						 *
* 	A8 = Ptr to BTR part						 *
*								         *
**************************************************************************
BTR_ROCKET_COLL
	MOVE	*A0(RL_INTENDED_OBJ),A14,L
	CMP	A14,A8			;Is this the object we are after?
	JRNE	BRC_X			;BR = No
	MOVK	1,A14
	MOVB	A14,*A8(OCHEWEDROCKET)	;Flag for the explosion
BRC_X
	RETS
*
* BTR gets whacked by a smart bomb
* 	A2 = Ptr to smart player
*	A8 = Ptr to object
*
BTR_SBOMB_COLLVECT
	MMTM	SP,B0,B3,B4,B5

	MOVI	BTR_CVECT,B3
	MOVE	A8,B0
	MOVE	*B0(OPART1),B4,L	;Keep head

	MOVI	HATCHBOY_CVECT,B5	;We'll look for the hatch boy also

	MOVE	*B0(OPARTS),B0,L
	JRUC	BSC_DO_BOMB
BSC_TEST
	MOVE	*B0(OCVECT),B14,L
	MOVE	B0,A8	
	MOVE	*B0(OPARTS),B0,L
	CMP	B5,B14
	JRNE	BSC_CHECK_PART
	CALLR	HATCHBOY_SBOMB
	JRUC	BSC_NEXT

BSC_CHECK_PART
	CMP	B3,B14
	JRNE	BSC_NEXT
BSC_DO_BOMB
	CLR	B14
	MOVB	B14,*B4(OPARTEXPLODING)
	CALLR	BTR_SBOMB_PART
BSC_NEXT
	MOVE	B0,B0
	JRNZ	BSC_TEST

	MMFM	SP,B0,B3,B4,B5
	RETS


BTR_SBOMB_PART
	MOVE	*A8(OHITCNT),a3		; how many times hit?
	JRZ	BTR_GV_XIT		;BR = Part already dead
	CLR	A3
	MOVE	A3,*A8(OHITCNT)
	MOVB	*A8(OPARTID),A14
	CMPK	3,A14
	JRNE	NORM_PART_SBOMB		;BR = This is not the turret
	
	move	*a8(OPART1),a1,L	; get head
	move	*a1(OTOTHITS),a14
	JRUC	TURRET_SBOMB


;BTR_ROCKET_COLL:
BTR_EXPLOSION_COLL:
	MOVB	*A8(OCHEWEDROCKET),A14	
	JRZ	BTR_GV_XIT		;BR = We really didn't take it

;	move	@WAVEIRQS,a5		; current int num
;	move	*a8(OROCKTIM),a14	; int num of last rocket
;	jrz	ok2rock			; if 0, we're cool
;	sub	a5,a14			
;	addk	8,a14
;	jrnn	BTR_GV_XIT		; if we're within 8 ticks, no way
;ok2rock:
;	move	a5,*a8(OROCKTIM)
	CLRB	*A8(OCHEWEDROCKET)	;Reset for next rocket
	MOVE	*A0(OID),A0,W			;GET PLAYER DATA ADDRESS
	CALLA	POID_TO_PDATA			;GET PDATA IN A2

	SOUNDZ	SND_HIT_BY_ROCKET

	movb	*a8(OPARTID),a14
	cmpi	3,a14			; is this the turret?
	jrne	btr_rocket1
	move	*a8(OHITCNT),a3
	subk	RHITS_TUR,a3
	jrnn	notneg1
	clr	a3
notneg1:
	move	a3,*a8(OHITCNT)
;	jrnz	BTR_GV_XIT
	JRZ	BTR_BLOW_TURRET

BTR_SPIN_TURRET
	SOUND1	SND_TURRET_HIT

	MOVI	ANIM_TURRET_HIT,A1
	CALLA	STRT_ANIM	  	;Make the turret spin
	JRUC	BTR_GV_XIT
*
*	Blow off turret
*
*		Adjust total btr pieces destroyed
*
BTR_BLOW_TURRET
	move	*a8(OPART1),a1,L	; get head
	move	*a1(OTOTHITS),a14
	CMPK	4,A14
	JRLO	BTR_SPIN_TURRET		;BR = He did not kill enough other pts
TURRET_SBOMB
	inc	a14
	move	a14,*a1(OTOTHITS)	; tell head another part trashed
*
*		Pull from multiparter, change OID, clear GUNVECT
*
	calla	PULL_PART

	movi	OID_JUNK,a1
	calla	CHANGE_OID

*
* Start fragment script
*
	MMTM	SP,B0,B1,B2,B3,B4,B5,B6,B7,B8,B9,B10	;MAKE FRAGMENTS
	MOVI	040000H,A0
	MOVI	80H,A3
	CALLA	PreFrag_Center
	MOVI	FRAG_TURRET,B14			;Use this fragment script
	CALLA	Fragger
	MMFM	SP,B0,B1,B2,B3,B4,B5,B6,B7,B8,B9,B10

*
*		Start animation
*
	movi	TURBLOW,a1
	calla	STRT_ANIM
*
*	Give a velocity
*
	MOVI    -40000h,A14
	move	a14,*a8(OYVEL),L
	movi	0c000h,a0
	movi	-0c000h,a1
	calla	RANGERND
	move	a0,*a8(OXVEL),L
	MOVI 	1800h,A14
	move	a14,*a8(OYACCEL)
	ORIM	M_GCOLL,*a8(OFLAGS),W
	MOVIM	DUMRETS,*a8(OGUNVECT),L
	MOVIM	TURRET_CVECT,*a8(OCVECT),L

	; ADDSOUND  turret flying off
;	movi	TURRET_BLAST_SND_TAB,A0
;	calla	PLAYER_SND
	rets


btr_rocket1:
	move	*a8(OHITCNT),a3		; how many times hit?
	jrz	BTR_GV_XIT
	subk	RHITS_BTR,a3
	jrnn	not_neg
	clr	a3
not_neg:
	move	a3,*a8(OHITCNT)
	jrnz	BTR_GV_XIT
NORM_PART_SBOMB
	mmtm	sp,b0,b1,b2,b3,b4,b5,b6,b7,b8,b9,B10   
	callr	ROCK_HOOK
	mmfm	sp,b0,b1,b2,b3,b4,b5,b6,b7,b8,b9,B10   
	rets


Do_BTR_Dink:
	calla	DGV_FRAG_SPARK

	movi	BTRHITSND,a1
	movk	3,a0
	jauc	TAB_SOUND


BTRHITSND
	.long	BTRHIT_S1,BTRHIT_S2,BTRHIT_S3

BTRHIT_S1	.word	0f334h,24,0a1e3h,0
BTRHIT_S2	.word	0f334h,13,0a1e0h,0
BTRHIT_S3	.WORD	0F334H,21,0A1e6H,0


*
* Troop Transport Gun Vector
*
* PASS:									 
* A2 = PTR TO PLAYER						         
* A8 = PTR TO OBJECT							 
*
BTR_GUNVECT:
	move	*a8(OHITCNT),a3		; how many times hit?
;	jrz	BTR_GV_XIT
	JAZ	Do_Dink
	
	MOVE	*A2(PPLASMASHOTS),A14,W
	JRZ	BGV_NORM		;BR = Shooting normal gun

	SUBK	10,A3
	JRGT	BGV_HITOK
	CLR	A3
	MOVE	A3,*A8(OHITCNT),W
	JRUC	ROCK_HOOK

BGV_NORM
	dec	a3
	CMPK	1,A3
	JRHS	BGV_HITOK
	MOVK	1,A3
BGV_HITOK
	move	a3,*a8(OHITCNT)
;	janz	DO_FLASH_DINK
	JAUC	DO_FLASH_DINK
ROCK_HOOK:
	movb	*a8(OPARTID),a5
	move	a5,a7
	subk	6,a5
	jrn	BTR_GV_XIT
	sll	5,a5
	move	*a8(OPART1),a6,L	; get head
	MOVB	*A6(OPARTEXPLODING),A14
	JRZ	BGV_XPLODE_IT		;BR = O.K. to explode this part
	MOVKM	1,*A8(OHITCNT),W	;Reset to allow kill again
	JRUC	BTR_GV_XIT
BGV_XPLODE_IT
	move	*a6(OTOTHITS),a14
	inc	a14
	move	a14,*a6(OTOTHITS)	; tell head another part trashed
	move	a5,a1
	addi	BTR_dam_tbl,a1
	move	*a1,a1,L
	jrz	BTR_GV_XIT

	MOVKB	1,*A6(OPARTEXPLODING)

;	move	*a8(OFLAGS),a14
;	btst	B_ANIM,a14
;	jrz	skpanistop
;	calla	PULL_ANIM
;skpanistop:
;	move	*a8(OCTRL),a4
;	calla	ANI

	CALLA	OBJ_ON_WNZ		;Make sure this malaka is on
	CALLA	STRT_ANIM
*
*	get explosion/fire table
*
;	srl	1,a5			; word index
;	addi	BTR_explo,a5
;	move	*a5,a5			; NUM (8 bits), Typ (1 bit)
;	jrz	BTR_GV_XIT
;	movi	FHKEXB_INIT,a6
;	btst	7,a5
;	jrz	B_ok
;	movi	FHKEXC_INIT,a6
;B_ok:
;	move	a5,a4
;	srl	8,a4			; num of explos in a4
;	sll	26,a5
;	srl	21,a5			
;	addi	EXPLO_PCS,a5		; start of explo offsets
;BTRGlp:
;	move	a6,b0
;	calla	EASYMAKE
;	move	*a5+,a1,L
;	movx	a1,a3			; X world offset
;	sext	a3			
;	sll	8,a3
;	move	*a8(OXVAL),a14,L
;	add	a3,a14
;	move	a14,*a0(OXVAL),L
;	sra	16,a1
;	sll	8,a1			; Y world offset
;	move	*a8(OYVAL),a14,L
;	add	a1,a14
;	move	a14,*a0(OYVAL),L
;	move	*a8(OZVAL),a14,L
;	subk	4,a14
; 	move	a14,*a0(OZVAL),L

;	calla 	INSOBJ
;	dsj	a4,BTRGlp
*
;	cmpi	7,a7			; is this the pipe on top?
;	jrne	BTR_GV_XIT
*
*	add a fire
*
;	movi	BTR_FIRE_INIT,b0
;	calla	EASYMAKE
;	jrz	BTR_GV_XIT
;	PUSH	a8
;	move	*a8(OPART1),a8,L
;	move	*a8(OXVAL),a1,L		; set fire position
;	addi	115*BTR_Z,a1
;	move	a1,*a0(OXVAL),L
;	move	*a8(OYVAL),a1,L
;	subi	103*BTR_Z,a1
;	move	a1,*a0(OYVAL),L
;	move	*a8(OZVAL),a1,L
;	addk	6,a1
;	move	a1,*a0(OZVAL),L
;	calla	INSOBJ
;	calla	INSPART
;	PULLQ	a8
BTR_GV_XIT:
	rets

**************************************************************************
*								         *
* 	TIRE_GUNVECT							 *
* 									 *
* 	Gun vector for the BTR's tires.					 *
* 									 *
* 	A2 = Ptr to player shooting					 *
* 	A8 = Ptr to tire						 *
*								         *
**************************************************************************
TIRE_GUNVECT
	SOUNDZ	SND_TIRE_HIT
	rets


**************************************************************************
*								         *
* 	TURRET_GUNVECT							 *
* 									 *
* 	Gun vector for the BTR's turret.				 *
* 									 *
* 	A2 = Ptr to player shooting					 *
* 	A8 = Ptr to turret						 *
*								         *
**************************************************************************
TURRET_GUNVECT
	MOVE	*A2(PPLASMASHOTS),A14,W
	JRNZ	BTR_SPIN_TURRET
DORBOM_GUNVECT
	JAUC	DO_FLASH_DINK



;
;	something new - velocities!
;
	move	a0,a5
	clr	a0
	movi	-080h,a1
	calla	RANGRAND
	move	a0,*a5(OZVEL),L
	move	a5,a0



;BTR_FIRE_INIT
;	.long	F1R1
;	.word	DMAWNZ,M_NOSCALE|M_NOPARTANI,OM_ANIM
;	.long	BTR_FIRE_ANIM

;BTR_FIRE_ANIM
;	LW	F1R1,3
;	LW	F1R2,3
;	LW	F1R3,3
;	LW	F1R4,3
;	LW	F1R5,3
;	LW	F1R6,3
;	LW	F1R7,3
;	LW	F1R8,3
;	LW	F1R9,3
;	LW	F1R10,3
;	.long	0




	.if 0		; replaced by Do_Dink
*
*	richochet
*
BTR_GV_rik:
*		compute position of sparks
*		Fire up sparks, then let em die
*
	move	*a2(PCURSORXY),a5,L
	move	@ZBASE,a6,L
	move	*a8(OZVAL),a4,L
	subk	4,a4
	sub	a6,a4		; world Z in a4

	move	a5,a3
	zext	a3
	TOWORLDX	a4,a3
	srl	16,a5
	TOWORLDY	a4,a5
	add	a6,a4		; univ Z in a4
	movi	SPARK_INIT,b0
	calla	EASYMAKE
	move	@XBASE,a14,L
	add	a14,a3
	move	@YBASE,a14,L
	add	a14,a5
	move	a3,*a0(OXVAL),L
	move	a5,*a0(OYVAL),L
	move	a4,*a0(OZVAL),L
	calla 	INSOBJ

	rets

	.endif



*
*	Turn next frame into start of script  
*

MEXP_INIT
	.byte  2,0,0,1
	.long	REXPLO
	.word  OID_BLOWUP, 0
	LWWWW	REXPLOA4h, DMAWNZ, M_MANSCALE|M_NOSCALE,0,OM_ANIM
	.long	misexplo
	LWWWW   REXPLOA4h, DMAWNZ|M_FLIPH, M_MANSCALE|M_NOSCALE,0,OM_PRVANIM


misexplo:
	LW	REXPLOA4h,2
	LW	REXPLOA6h,2
	LW	REXPLOA8h,2
	LW	REXPLOA9h,2
	LW	REXPLOA10h,2
	LW	REXPLOA11h,2
	LW	REXPLOA12h,2
	LWL	1,3|AFunc,DELETE_OBJ


MSAFEXP_INIT
	.long  FHKEXPLOB1
	.word  DMAWNZ, M_MANSCALE|M_NOSCALE, OM_ANIM|OM_OID
	.word  OID_BLOWUP
	.long	safmisexplo


safmisexplo:
	LW	FHKEXPLOB1,2
	LW	FHKEXPLOB2,2
	LW	FHKEXPLOB3,2
	LW	FHKEXPLOB4,2
	LW	FHKEXPLOB5,2
	LW	FHKEXPLOB6,2
	LW	FHKEXPLOB7,2
	LW	FHKEXPLOB8,2
	LW	FHKEXPLOB9,2
	LW	FHKEXPLOB10,2
	LW	FHKEXPLOB11,2
	LWL	1,1|AFunc,DELETE_OBJ



**************************************************************************
*								         *
* 	A_TURRET_FIRE_FNC						 *
* 									 *
* 	Anim func for the turret gun fire.				 *
* 									 *
* 	A8 = Ptr to part firing						 *
* 	AARG+,L = [Y,X] firing offset					 *
*								         *
**************************************************************************
A_TURRET_FIRE_FNC
	MOVB	*A8(OFLAGS),A14
	JRN	ATFF_X				;BR = Object offscreen

	MOVE	*A8(OXVAL),A3,L
	MOVE	@XBASE,A5,L
	SUB	A5,A3				;Universe to World X

	ABS	A3
	SRL	16,A3
	CMPI	120,A3
	JRGT	ATFF_X				;BR = Too far to the side

	CALLA	GETAFARG_LONG			;GET THE FIRING OFFSET
	MOVE	A0,A3
	CALLA	EGUN_FLASH_MULTI		;MAKE A GUN FLASH

	SOUND1	SND_BTR_FIRE

;	MOVI	[2,0],A5
	MOVE	@BASE_HIT,A5,W
	ADDI	800H,A5
	SLL	4,A5
	ALLPLYR	PLAYER_HIT		;HIT 'EM ALL
ATFF_X
	RETS

**************************************************************************
*								         *
* 	A_RAPIDFIRE_DECISION						 *
* 									 *
* 	Anim func to decide if we should fire again.			 *
* 									 *
* 	A8 = Ptr to firing part						 *
* 	AARG+,L = Animation branch to fire again			 *
*								         *
**************************************************************************
A_RAPIDFIRE_DECISION
	MOVB	*A8(ORAPIDCNT),A14
	DEC	A14
	MOVB	A14,*A8(ORAPIDCNT)
	JANZ	SetAnim_AFARG
	RETS

**************************************************************************
*								         *
* 	C_OCONST							 *
* 									 *
* 	Create func to set the OCONST field of an object.		 *
* 									 *
* 	A0 = Ptr to uninserted object					 *
* 	*B0+,W = OCONST value						 *
*								         *
**************************************************************************
C_OCONST
	MOVE	*B0+,B14,W
	MOVE	B14,A14
	MOVE	A14,*A0(OCONST),W
	RETS

**************************************************************************
*								         *
* 	C_BTR_BODY							 *
* 	  								 *
* 	Create func to setup the BTR body part.				 *
* 									 *
* 	A0 = Ptr to uninserted object					 *
* 	*B0+,L =  Blow func						 *
*								         *
**************************************************************************
C_BTR_BODY
	MOVE	*B0+,B14,L
	MOVE	B14,A14
	MOVE	A14,*A0(OBLOW_AFUNC),L
	MOVIM	0101H,*A0(OCONST),W
	RETS

NUM_BTR_PARTS	.EQU	20

BTR_INIT
	.byte	NUM_BTR_PARTS, 0, 0, 7	;OBJCNT, PRCCNT, IMGPALCNT, PALCNT
	.long	P_BTRTUR1,P_BTR1,P_BTR2,P_BTR3,P_BTR4
	.LONG	TIREPAL,P_BHATCH	;PALS
	.word	OID_BTR, OM_COLL | (OM_WPOS | OM_GRND) | OM_INSERT
			     ; world position, call INSERT_OBJ when done
	.long	BTR_CVECT
	.long	1800000h,-090000H,BTR_Z	; X,Y,Z  
*
*    .long IMG
*    .word DMAFLAGS, OFLAGS, OZOFF, OPTION_BITS
*
       LWWWW	DORBOM1, DMAWNZ|M_FLIPH, M_NOSCALE, -3, OM_GUNV | OM_CFUNC
       .long	DORBOM_GUNVECT
	LW	C_OCONST, 0101H
       LWWWW	HATCHC6, DMAWNZ|M_FLIPH, M_NOSCALE, 0, OM_OPARTS | OM_ANIM | OM_CFUNC | OM_PRVGUNV
       .word	20,-94
       .long	btrhatch
	LW	C_OCONST, 0101H
       LWWWW	TURST1, DMAWNZ|M_FLIPH, M_NOSCALE, -1, OM_OPARTS | OM_GUNV | OM_ANIM | OM_CFUNC
       .word	-75,-96
	.LONG	TURRET_GUNVECT
       .long	btrturret
	LW	C_OCONST, 0101H
       LWWWW	BTOrt, DMAWNZ|M_FLIPH, M_NOSCALE, 0, OM_OPARTS | OM_GUNV | OM_COLL | OM_CFUNC
	.word   -79,5
       .long	BTR_HOLE_CVECT
	.LONG	METAL_GUNVECT
	LW	C_OCONST, 0101H
       LWWWW	BTOrt, DMAWNZ, M_NOSCALE, 0, OM_OPARTS | OM_PRVGUNV | OM_COLL | OM_CFUNC
	.word   79,5
       .long	BTR_HOLE_CVECT
	LW	C_OCONST, 0101H
NUM_BODY	.EQU	6
       LWWWW	clea1, DMAWNZ|M_FLIPH, M_NOSCALE, 0, OM_GUNV | OM_OPARTS | OM_CFUNC
	.word   -(51-251),47-99
       .long	BTR_GUNVECT
       .LONG	C_BTR_BODY, A_BLOW_DAMN1
       LWWWW	clea2, DMAWNZ|M_FLIPH, M_NOSCALE, 0, OM_OPARTS | OM_PRVGUNV | OM_CFUNC
	.word   -(34-148),10-104
       .LONG	C_BTR_BODY, A_BLOW_DAMN234
       LWWWW	clea3, DMAWNZ|M_FLIPH, M_NOSCALE, 0, OM_OPARTS | OM_PRVGUNV | OM_CFUNC
	.word   -(5-69),18-111
       .LONG	C_BTR_BODY, A_BLOW_DAMN234
       LWWWW	clea4, DMAWNZ|M_FLIPH, M_NOSCALE, 0, OM_OPARTS | OM_PRVGUNV | OM_CFUNC
	.word   -(29-168),54-102
       .LONG	C_BTR_BODY, A_BLOW_DAMN234
       LWWWW	clea5, DMAWNZ|M_FLIPH, M_NOSCALE, 0, OM_OPARTS | OM_PRVGUNV | OM_CFUNC
	.word   -(42-113),47-96
       .LONG	C_BTR_BODY, A_BLOW_DAMN5
       LWWWW	clea6, DMAWNZ|M_FLIPH, M_NOSCALE, 0, OM_OPARTS | OM_PRVGUNV | OM_CFUNC
	.word   -(46-252),56-54
       .LONG	C_BTR_BODY, A_BLOW_DAMN6
       LWWWW	clea7, DMAWNZ|M_FLIPH, M_NOSCALE, 0, OM_OPARTS | OM_PRVGUNV | OM_CFUNC
	.word   -(31-34),45-95
       .LONG	C_BTR_BODY, A_BLOW_DAMN7
       LWWWW	clea8, DMAWNZ|M_FLIPH, M_NOSCALE, 0, OM_OPARTS | OM_PRVGUNV | OM_CFUNC
	.word   -(19+24),46-95
       .LONG	C_BTR_BODY, A_BLOW_DAMN8
       LWWWW	clea9, DMAWNZ|M_FLIPH, M_NOSCALE, 0, OM_OPARTS | OM_PRVGUNV | OM_CFUNC
	.word   -(47+59),46-95
       .LONG	C_BTR_BODY, A_BLOW_DAMN9
       LWWWW	clea10, DMAWNZ|M_FLIPH, M_NOSCALE, 0, OM_OPARTS | OM_PRVGUNV | OM_CFUNC
	.word   -(52+148),50-98
       .LONG	C_BTR_BODY, A_BLOW_DAMN10
       LWWWW	clea11, DMAWNZ|M_FLIPH, M_NOSCALE, 0, OM_OPARTS | OM_PRVGUNV | OM_CFUNC
	.word   -(41+158),53-50
       .LONG	C_BTR_BODY, A_BLOW_DAMN11
NUM_TIRE1	.EQU	17
       LWWWW	TIROT1, DMAWNZ|M_FLIPH, M_NOSCALE, -2, OM_OPARTS | OM_COLL | OM_GUNV | OM_ANIM
       .word	-8fh, -15
	.LONG	DUMCOLL
	.LONG	TIRE_GUNVECT
       .long	tirerotlftStart
       LWWWW	TIROT1, DMAWNZ|M_FLIPH, M_NOSCALE, -2, OM_OPARTS | OM_COLL | OM_PRVANIM | OM_PRVGUNV
       .word	-35h, -15
	.LONG	DUMCOLL
       LWWWW	TIROT1, DMAWNZ|M_FLIPH, M_NOSCALE, -2, OM_OPARTS | OM_COLL | OM_PRVANIM | OM_PRVGUNV
       .word	39h, -15 
	.LONG	DUMCOLL
       LWWWW	TIROT1, DMAWNZ|M_FLIPH, M_NOSCALE, -2, OM_OPARTS | OM_COLL | OM_PRVANIM | OM_PRVGUNV
       .word	92h, -15
	.LONG	DUMCOLL

*
* Turret firing animation
*
btrturret:
	LWLWWW	TURST1,1|AFunc,A_RAND_REL_BYTE+3,2,6,ORAPIDCNT

	LWLWW	1,1|AFunc,A_RAND_AnimSLP+2,5,30
	LW	1,0
TURRET_RAPID_FIRE
	LWLWW	1,1|AFunc,A_TURRET_FIRE_FNC+2,-4,-12
	LWLL	TURST2,4|AFunc,A_CHANGE_PAL+2,P_BTRTUR2

	LWLL	TURST1,1|AFunc,A_CHANGE_PAL+2,P_BTRTUR1
TURRET_RETURN
	LWLL	1,4|AFunc,A_RAPIDFIRE_DECISION+2,TURRET_RAPID_FIRE

	LWLL	1,1|AFunc,A_AnimFrm+2,btrturret


;	LW	TUR2,4
;trt3:
;	LW	TUR3,4
;	LWLL	TUR4,4|AFunc,A_RANDBRANCH+2,tbk4
;	LW	TUR5,4
;trt6:
;	LW	TUR6,4
;	LW	TUR7,4
;	LWLL	TUR8,4|AFunc,A_RANDBRANCH+2,tbk8
;	LW	TUR9,4
;	LW	TUR10,4
;	LW	TUR11,4
;trt12:
;	LW	TUR12,4
;	LW	TUR13,4
;	LWLL	TUR14,4|AFunc,A_RANDBRANCH+2,tbk14
;	LW	TUR15,4
;	LWLL	TUR16,4|AFunc,A_BRANCH+2,btrturret
;	.long	0

*
* Animation to spin turret when hit by a rocket
*
ANIM_TURRET_HIT
	LWLL	TUR5,1|AFunc,A_CHANGE_PAL+2,P_BTRTUR1
	LWL	1,40|AFunc,OBJ_WNZ
	LWLL	TUR4,4|AFunc,A_SOUND+2,SND_TURRET_SPIN
	LW	TUR3,4
	LW	TUR2,4

	LWLL	TURST1,1|AFunc,A_AnimFrm+2,TURRET_RETURN

AU_CREATE_HATCHBOY:
	MOVE	@HOLD_ENEMY_DISPATCH,A14,W
	JRNZ	AUC_H_X

	move	*a8(OFLAGS),a14
	btst	B_OFSCRN,a14
	jrnz	AUC_H_X

	MOVE	A8,A9
	MOVI	WINBOY_INIT,B0		;ALLOCATE OBJECT
	CALLA	CREATE_ENEMY
	JRZ	AUC_H_X			;BR = ERROR! ERROR!

	MOVK	M_WINDOW,A11		;SET TYPE
	MOVE	A11,*A8(OEFLAGS),W	;SAVE TYPE

	MOVE	@RAND,A0,W		;LEFTY OR RIGHTY?
	ANDI	M_FLIPH,A0
	MOVE	*A8(OCTRL),A10,W
	OR	A0,A10
	MOVE	A10,*A8(OCTRL),W

	movi	4<<15,a2

	BTST	B_FLIPH,A10		;Is it flipped?
	JRZ	AU_CW_NOROM		;BR = No horiz flip to worry about
	movi	-8<<15,a2
AU_CW_NOROM

	MOVE	*A9(OXVAL),A1,L
	ADD	A2,A1			;OFFSET X
	MOVE	*A9(OYVAL),A2,L
	addi	115<<15,a2
	MOVE	A2,*A8(OYSTART),L
	MOVE	*A9(OZVAL),A3,L
	addk	5,A3			;OFFSET Z FROM GENERATOR
	CALLA	SET_ANIPU

	move	a9,*a8(OGenObj),L	; hold on to guy that created me

	MOVI	HATCHBOY_ANIM,A1
	CALLA	STRT_ANIM		;START ANIMATION

	MOVI	-20 << 15,A14
	MOVE	A14,*A8(OGRNDOFF),L	;GROUND OFFSET UPON FALL

	MOVK	1,A14
	MOVB	A14,*A8(OHITS)		;NUMBER OF ALLOWED HITS

	movk	10,a14
	movb	a14,*a8(AnimLoop)

	MOVK	20,A0			;RANDOM DELAY BEFORE SHOOTING UP
	MOVK	5,A1
	CALLA	RANGRAND
	MOVB	A0,*A8(AnimSLP)
	MOVE	A0,A3

	MOVI	220,A0			;RANDOM LIFE TIME
	MOVI	50,A1
	CALLA	RANGRAND
	ADD	A3,A0			;EXTRA DELAY BEFORE SHOOTING UP
	SUBK	21,A0			;POPUP AND POPDOWN TIME
	MOVE	A0,*A8(OETIME),W
	MOVIB	127,*a9(AnimSLP)

	MOVIM	HATCHBOY_GUNVECT,*a8(OGUNVECT),L
	MOVIM	HATCHBOY_CVECT,*a8(OCVECT),L

	CALLA	INSERT_ENEMY		;INSERT AND COUNT ENEMY

	move	a8,a0
	move	a9,a8
	calla	INSPART

AUC_H_X:
	rets

HATCHBOY_CVECT
	WWL	OID_PROCKET,~MASK_PLAYER,HATCHBOY_ROCKET_COLL
	WL	0,DUMCRETS

HATCHBOY_ROCKET_COLL:
	calla	PULL_PART
	callr	DOWN_THE_HATCH
	movi	OUTCLUB_CVECT,a14
	move	a14,*a8(OCVECT),L
	MOVIM	OUTCLUB_GUNVECT,*a8(OGUNVECT),L

	jauc	NONBOY_ROCKET_COLL


HATCHBOY_GUNVECT:
	calla	PULL_PART
	callr	DOWN_THE_HATCH
	movi	OUTCLUB_CVECT,a14
	move	a14,*a8(OCVECT),L
	MOVIM	OUTCLUB_GUNVECT,*a8(OGUNVECT),L

	jauc	OUTCLUB_GUNVECT

HATCHBOY_SBOMB
	calla	PULL_PART
	movi	OUTCLUB_CVECT,a14
	move	a14,*a8(OCVECT),L
	MOVIM	OUTCLUB_GUNVECT,*a8(OGUNVECT),L

	jauc	NONBOY_SBOMB


DOWN_THE_HATCH:
	move	*a8(OZVAL),a14,L
	addk	2,a14
	move	a14,*a8(OZVAL),L	; make sure we're behind hatch

	move	*a8(OGenObj),a5,L
	jrz	hclosing		; if 0, hatch is closing now
	MOVKB	20,*a5(AnimSlp)  	; start hatch closing
	MOVKB	1,*a5(AnimSLP)  	; start hatch closing
	CLRM	*a8(OGenObj),L
hclosing:
	rets

btrhatch:
	LWL	HATCHC6,8|AFunc,A_STAY_TIL_ONSCRN
	LW	HATCHC5,4
;	LW	HATCHC4,3
	LWL	HATCHC3,4|AFunc,AU_CREATE_HATCHBOY
;	LW	HATCHC2,3
	LW	HATCHC1,4
	LW	1,0
	LW	1,0
;	LW	HATCHC2,3
	LW	HATCHC3,4
;	LW	HATCHC4,3
	LW	HATCHC5,4
	LWLWW	HATCHC6,10|AFunc,A_RAND_AnimSLP+2,30,130
	LW	1,0
	.long	0


;turback:
;	LW	TUR16,4
;	LW	TUR15,4
;tbk14:
;	LW	TUR14,4
;	LW	TUR13,4
;	LWLL	TUR12,4|AFunc,A_RANDBRANCH+2,trt12
;	LW	TUR11,4
;	LW	TUR10,4
;	LW	TUR9,4
;tbk8:
;	LW	TUR8,4
;	LW	TUR7,4
;	LWLL	TUR6,4|AFunc,A_RANDBRANCH+2,trt6
;	LW	TUR5,4
;tbk4:
;	LW	TUR4,4
;	LWLL	TUR3,4|AFunc,A_RANDBRANCH+2,trt3
;	LW	TUR2,4
;	LWLL	TUR1,4|AFunc,A_BRANCH+2,turback
;	.long	0

A_RANDBRANCH:
	calla	RANDOM		; branch on random condition
	btst	5,a0
	janz	A_BRANCH
	rets

A_BRANCH_TRUE:
	calla	GETAFARG_LONG	; address of word to test into a0
	move	*a0,a0
	janz	A_BRANCH
	rets

tirerotStart:
	LW	TIROT3,20
	LW	TIROT2,18
	LW	TIROT1,16
	LW	TIROT3,14
	LW	TIROT2,12
	LW	TIROT1,10
	LW	TIROT3,8
	LW	TIROT2,7
	LW	TIROT1,6
	LW	TIROT3,5
	LW	TIROT2,4
	LWLL	TIROT1,3|AFunc,A_BRANCH+2,tirerot

tirerot:
	LW	TIROT3,3
	LW	TIROT2,3
	LW	TIROT1,3
	.long	0

tirerotStop:
	LW	TIROT3,3
	LW	TIROT2,4
	LW	TIROT1,5
	LW	TIROT3,6
	LW	TIROT2,7
	LW	TIROT1,8
	LW	TIROT3,10
	LW	TIROT2,12
	LW	TIROT1,14
	LW	TIROT3,16
	LW	TIROT2,18
	LWL	TIROT1,20|AFunc,PULL_ANIM



tirerotlftStart:
	LW	TIROT1,20
	LW	TIROT2,17
	LW	TIROT3,14
	LW	TIROT1,12
	LW	TIROT2,10
	LW	TIROT3,9
	LW	TIROT1,8
	LW	TIROT2,7
	LW	TIROT3,6
	LW	TIROT1,5
	LW	TIROT2,4
	LWLL	TIROT3,3|AFunc,A_BRANCH+2,tirerotlft

tirerotlft:
	LW	TIROT1,3
	LW	TIROT2,3
	LW	TIROT3,3
	.long	0


tirerotlftStop:
	LW	TIROT1,3
	LW	TIROT2,4
	LW	TIROT3,5
	LW	TIROT1,6
	LW	TIROT2,7
	LW	TIROT3,8
	LW	TIROT1,9
	LW	TIROT2,10
	LW	TIROT3,12
	LW	TIROT1,14
	LW	TIROT2,17
	LWL	TIROT3,20|AFunc,PULL_ANIM



tdoor:
	LWL	DORBOM1,8|AFunc,A_STAY_TIL_ONSCRN
;	LWL	DORBOM2,3|AFunc,CREATE_MISSLE
	LWL	DORBOM3,4|AFunc,CREATE_MISSLE
;	LWL	DORBOM4,3|AFunc,BAY_OPEN
;	LW	DORBOM5,3
	LWL	DORBOM6,4|AFunc,BAY_OPEN
	LW	1,0
	LWL	1,5|AFunc,LAUNCH_MISSLE	      	
;	LW	DORBOM5,3
;	LW	DORBOM4,3
	LWL	DORBOM3,4|AFunc,BAY_CLOSED
;	LWL	DORBOM2,3|AFunc,BAY_CLOSED
	LWL	DORBOM1,3|AFunc,PULL_ANIM
	LWLWW	1,1|AFunc,A_RAND_AnimSLP+2,30,70
	LW	1,0
	.long	0


MISSL:
	LW	mossile1,14
	LW	mossile2,11
	LW	mossile3,9
	LW	mossile4,8
	LW	mossile5,7
	LW	mossile6,6
	LW	mossile7,5
	LWLW	1,3|AFunc,A_SET_SCALE+1,80h
	LWLW	1,1|AFunc,A_MISSLE_EXPL+1,0101h


	.if	0   ;*****************************not used

BOLT:
     	LW	bolt1,2
     	LW	bolt2,2
     	LW	bolt3,2
     	LW	bolt4,2
     	LW	bolt3,2
     	LW	bolt4,2
     	LW	bolt5,2
     	LW	bolt6,3
     	LW	bolt4,2
     	LW	bolt5,2
     	LW	bolt6,2
     	LW	bolt7,2
	LWL	bolt8,2|AFunc,DELETE_OBJ
	.long	0


SPARK:
     	LW	spark1,2
	LW	spark2,2
     	LW	spark3,2
     	LW	spark4,2
     	LW	spark5,2
     	LW	spark6,2
     	LW	spark7,2
	LWL	1,2|AFunc,DELETE_OBJ
	.long	0


SPARK_INIT:
	.long	spark1
	.word	DMAWNZ,M_NOSCALE|M_NOCOLL
	.word	OM_ANIM
	.long	SPARK

	.endif  ;*********************************************

;FHKEXB_INIT:
;	.long	FHKEXPLOB1
;	.word	DMAWNZ,M_NOCOLL
;	.word	OM_ANIM
;	.long	FHKEXB

;FHKEXC_INIT:
;	.long	FHKEXPLOC1
;	.word	DMAWNZ,M_NOSCALE|M_NOCOLL
;	.word	OM_ANIM
;	.long	FHKEXC

;SMCHNK:
;	LW	FHKI1SHRAPB1,3
;	LW	FHKI1SHRAPB2,3
;	LW	FHKI1SHRAPB3,3
;	LW	FHKI1SHRAPB4,4
;	LW	FHKI1SHRAPB5,4
;	LW	FHKI1SHRAPB6,5
;	LW	FHKI1SHRAPB7,5
;	LWL	1,1|AFunc,DELETE_OBJ
;	.long	0

;BIGCHNK:
;	LW	FHKEF1CHUNK1,3
;	LW	FHKEF1CHUNK2,3
;	LW	FHKEF1CHUNK3,3
;	LW	FHKEF1CHUNK4,4
;	LW	FHKEF1CHUNK5,4
;	LW	FHKEF1CHUNK6,4
;	LW	FHKEF1CHUNK7,5
;	LW	FHKEF1CHUNK8,5
;	LWL	1,1|AFunc,DELETE_OBJ
;	.long	0


;BtrChunks
;	.long	BIGCHNK,0
;	.word	OID_JUNK,(2<<11)+(3<<6)+FRGPAL

;	.long	SMCHNK,0
;	.word	OID_JUNK,(4<<11)+(3<<6)+FRGPAL

;	.long	BIGCHNK,0
;	.word	OID_JUNK,(1<<11)+(4<<6)+FRGPAL

;	.long	SMCHNK,0
;	.word	OID_JUNK,(3<<11)+FRGPAL

;	.long	0

;FHKEXB:
;	LWLL	FHKEXPLOB1,3|AFunc,A_SOUND+2,SND_BTR_PRTEXP
;	LWLLLL	FHKEXPLOB2,3|AFunc,A_PreFrag_Center+6,BtrChunks,300h,60000h
;	LW	FHKEXPLOB3,3
;	LW	FHKEXPLOB4,3
;	LW	FHKEXPLOB5,4
;	LW	FHKEXPLOB6,4
;	LW	FHKEXPLOB7,4
;	LW	FHKEXPLOB8,4
;	LW	FHKEXPLOB9,4
;	LW	FHKEXPLOB10,4
;	LW	FHKEXPLOB11,4
;	LWL	1,1|AFunc,DELETE_OBJ
;	.long	0

;FHKEXC:
;	LWLL	FHKEXPLOC1,2|AFunc,A_SOUND+2,SND_BTR_PRTEXP			; ADDSOUND btr part explosion
;	LW	FHKEXPLOC2,2
;	LW	FHKEXPLOC3,2
;	LW	FHKEXPLOC4,2
;	LW	FHKEXPLOC5,2
;	LW	FHKEXPLOC6,2
;	LW	FHKEXPLOC7,2
;	LW	FHKEXPLOC8,2
;	LW	FHKEXPLOC9,3
;	LW	FHKEXPLOC10,3
;	LW	FHKEXPLOC11,3
;	LWL	1,1|AFunc,DELETE_OBJ
;	.long	0



DEC_ZPOS:
	move	*a8(OZVAL),a14,L
	dec	a14
	move	a14,*a8(OZVAL),L
	rets

TURBLOW:
	LWL	TURBLO9,4|AFunc,OBJ_WNZ
;	LW	TURBLO8,2
	LWL	TURBLO7,4|AFunc,DEC_ZPOS
;	LWL	TURBLO6,2|AFunc,DEC_ZPOS
	LW	TURBLO5,4
;	LW	TURBLO4,2
	LWL	TURBLO3,4|AFunc,DEC_ZPOS
;	LWL	TURBLO2,2|AFunc,DEC_ZPOS
	LW	TURBLO1,4
;	LW	TURBLO10,2
	.long	0

*
* BTR Sounds
*
SND_MISSLE_LAUNCH
	.WORD	0F140H,93,0A3AEH,0	;Missle launching
SND_MISSLE_EXPLODE
	.WORD	0F141H,80,0A38BH,0	;Missle blows up in mid-air
SND_MISSLE_EXPLHIP
	.WORD	0F170H,30,0A309H,0	;Missle launch sound Track skip
SND_MISSLE_HIT
	.WORD	0F142H,60,0A38EH,0	;Missle hits the screen

SND_BAY_OPEN
	.WORD	0F126H,36,081fBH,0	;servo

;TURRET_BLAST_SND_TAB
;	.LONG	SND_TURRET_BLAST1,SND_TURRET_BLAST2
;SND_TURRET_BLAST1
;	.WORD	0F342H,30,0a084H,0	;TURRET BLAST sound Chan P1
;SND_TURRET_BLAST2
;	.WORD	0F242H,100,0a386H,0	;TURRET BLAST sound Chan P2

SND_BTR_ARRIVE
	.word	0F350h,3*60,834Fh,0
SND_BTR_STOP
	.word	0F351h,51,08351h,0
SND_BTR_START
	.word	0F350h,3*60,0834Fh,0
SND_BTR_LEAVE
	.word	0F351h,260,08350h,0
SND_BTR_BGND
	.word	0F300h,1,5354h,0	;Make the BTR background sound
;SND_BTR_PRTEXP
;	.word	0F340H,60,0A302H,0
SND_HOLE_HIT
	.WORD	0E342H,88,0A390H,0	;Hole took a square hit
SND_TIRE_HIT
	.WORD	0F134H,20,0A37EH,0	;Tire gets hit
SND_BTR_FIRE
	.WORD	0F110H,39,0A326H,0	;BTR fire sound
SND_HIT_BY_ROCKET
	.WORD	0E340H,40,0A38DH,0	;BTR takes a hit by the players rocket
SND_TURRET_SPIN
	.WORD	0F141H,10,0A42DH,0	;Turret spin
SND_TURRET_HIT
	.WORD	0F141H,56,0A133H,0	;Turret takes a CD hit



*************************  New scroll acceleration routines

MAXACC	.set	10000h
MAXZACC	.set	10h



*	.long	X,Y,Z		; target in universe
*
*
*
*
S_STEER_TOWARD_TARGET:
	MOVI    40h,A9
	mmfm	a11,a0,a1,a2	; Z,Y,X
steerlp:
	mmtm	a12,a0,a1,a2	; save in proc block
	move	@ZBASE_HR,a3,L
	move	@YBASE,a4,L
	move	@XBASE,a5,L
	sub	a3,a0
	sub	a4,a1
	sub	a5,a2
	SRA 8,A0
	SRA 10,A0
	SRA 10,A2

	movi	MAXZACC,a3
	movi	MAXACC,a4

	move	a3,a14		; max Z acc
	move	a0,a6
	jrnn	str0
	neg	a14 		; if acc is neg
	neg	a6
str0:
	cmp	a3,a6
	jrle	usez
	move	a14,a0
usez:

	move	a4,a14		; max y acc
	move	a1,a6
	jrnn	str1
	neg	a14 		; if acc is neg
	neg	a6
str1:
	cmp	a4,a6
	jrle	usey
	move	a14,a1
usey:

	move	a4,a14		; max x acc
	move	a2,a6
	jrnn	str2
	neg	a14 		; if acc is neg
	neg	a6
str2:
	cmp	a4,a6
	jrle	usex
	move	a14,a2
usex:

	move	a0,@ZSACCEL,L
	move	a1,@YSACCEL,L
	move	a2,@XSACCEL,L

	sleep	1
	mmfm	a12,a0,a1,a2
	dsj	a9,steerlp

	clr	a14
	move	A14,@XSACCEL,L
	move	A14,@YSACCEL,L
	move	A14,@ZSACCEL,L
	JAUC	SCRL_DISPATCHER



*
*	P_EBUTS  colors 24 (up arrow) and 16 (down arrow)
*			 2a0h               6c00h
*
*

*
*	CONTROL FLASHING WHEN SOMETHING HITS SCREEN
*
*	a1 = constant color
*	a8 = object
*
HIT_SCREEN:
	move	a1,*a8(OCONST)
	move	*a8(OFLAGS),a14
	movi	FLASH_ANIM,a1
	btst	B_ANIM,a14
	jrz	no_pull
	move	a1,*a8(AnimFrm),L
	move	a1,*a8(AnimScr),L
	jruc	HShook
no_pull:
	calla	STRT_ANIM
HShook:
	movk	5,a14
	movb	a14,*a8(AnimLoop)
	movk	1,a14
	movb	a14,*a8(AnimSlp)
	rets

FLASH_ANIM:
	LWLWW	1,1|AFunc,A_RAND_AnimSLP+2,1,3
	LWL	1,1|AFunc,WARREN_FLASH
	LW	1,0
	LWL	1,1|AFunc,WARREN_UNFLASH
	LW	1,0
	LWLL	1,1|AFunc,A_Anim_DSJ+2,FLASH_ANIM
	LWL	1,1|AFunc,DELETE_OBJ


WARREN_FLASH:
	move	*A8(OCTRL),A14,W
	andni	M_WRNONZ,A14	;Don't Write Non-Zero Data
	ori	M_CONNON,A14	;Do Replace Non-Zero Data with constant
	move	A14,*A8(OCTRL),W
	rets


WARREN_UNFLASH:
	move	*A8(OCTRL),A1,W
	ori	M_WRNONZ,A1	;Do Write Non-Zero Data
	andni	M_CONNON,A1	;Don't Replace Non-Zero Data with constant
	move	A1,*A8(OCTRL),W
	rets

*
*	Set AnimSLP based on the number of players
*	WORD ARG 1 = param. A
*	WORD ARG 2 = param. B
*
*	AnimSLP = B - (A << CURPLYRS)
*
A_SLP_Based_CURPLYRS
	move	@CURPLYRS,a1		; random sleep time based on # plyrs
	calla	GETAFARG_WORD		; param. A
	sll	a1,a0
	movk	1,a1		; minimum = 1
	CALLA	RANGRAND
	move	a0,a1
	calla	GETAFARG_WORD		; param. B
	sub	a1,a0
	movb	a0,*a8(AnimSLP)
	rets


**************************************************************************
*								         *
* BTR REENTRANCE WALL EXPLODE EFFECT					 *
*								         *
**************************************************************************
SND_PREBUST
	.WORD	0F3F0H,130,0a305H,0	;PRE-BUST EXPLOSION


NUM_BRICK_GROUPS	EQU	6
NUM_BRICKS		EQU	12

BTR_WALL_BLAST:
	SOUND1	SND_PREBUST
	MOVK	NUM_BRICK_GROUPS,A10

	MOVI	WALL_FRAGMENT_TABLE,A11
WE_MASTER_LUPE
	MOVK	NUM_BRICKS,A6
WE_LUPE		
	MOVK	5,A0				;GET RANDOM TABLE INDEX
	CALLA	RAND0
	SLL	5,A0
	ADD	A11,A0
	MOVE	*A0,A5,L			;GET TABLE ENTRY
	move	a5,b0
	CALLA	EASYMAKE
	JRZ	WE_NEXT
	MOVE	A0,A8	

	move	@YWORLD,a0,L
	subi	30000h,a0
	MOVI	-100000h,A1 			;GET RANDOM Y PIXEL OFFSET
	CALLA	RANGRAND
	MOVE	A0,*A8(OYVAL),L
	movi	-10000h,a0
	movi	-60000h,a1
	calla	RANGRAND
	MOVE	A0,*A8(OYVEL),L
	MOVIM	2400h,*a8(OYACCEL),W

	MOVI	-210*BTR_Z,a5

	move	@XBASE,a14,L
	add	a14,a5
	move	a5,*A8(OXVAL),L
	movi	80000h,a0
	movi	10000h,a1
	calla	RANGRAND
	MOVE	A0,*A8(OXVEL),L

	move	@ZBASE,a14,L
	addi	BTR_Z,a14
	move	a14,*A8(OZVAL),L			;SET Z			

	MOVI	020h,A0				;RANDOM Z VELOCITY
	MOVI	-120h,A1
	CALLA	RANGERND
	MOVE	A0,*A8(OZVEL),L

	CALLA	RANDOM				;RANDOM FLIPPING
	ANDI	M_FLIPV|M_FLIPH,A0
	MOVE	*A8(OCTRL),A14,W
	OR	A0,A14
	MOVE	A14,*A8(OCTRL),W

	CALLA	INSERT_OBJ
WE_NEXT
	DSJ	A6,WE_LUPE
	SLEEP	1
	DSJ	A10,WE_MASTER_LUPE
	DIE


WALL_FRAGMENT_TABLE
	.LONG	BRIK_INIT,GXBRIK_INIT,CBRIK_INIT,CBRIK_INIT, EXPLO_BLOW_INIT
;	NOSHRED_INIT


BRIK_INIT
	.LONG	BRIK1
	.word	DMAWNZ,M_GCOLL,OM_ANIM|OM_COLL
	.LONG	BRICK_CVECT,BRIK_ANIM

GXBRIK_INIT 
	.LONG	GXBRIK1
	.word	DMAWNZ,M_GCOLL,OM_ANIM|OM_COLL
	.LONG	BRICK_CVECT,GXBRIK_ANIM

CBRIK_INIT
	.LONG	CBRIK1
	.word	DMAWNZ,M_GCOLL,OM_ANIM|OM_COLL
	.LONG	BRICK_CVECT,CBRIK_ANIM


;NOSHRED_INIT
;	.LONG	NOSHRED1, 0
;	.WORD	OID_JUNK, DMAWNZ, M_GCOLL, 0
;	.LONG	C_STRTANIM
;	.LONG	NOSHRED_ANIM

BRICK_CVECT
	.WORD	OID_GRND,0FFFFH
	.LONG	BRICK_COLLVECT
	.WORD	0
	.LONG	DUMCOLL

BRICK_COLLVECT
	CLR	A14				;STOP, DROP, AND ROLL!
	MOVE	A14,*A8(OZVEL),L
	MOVE	A14,*A8(OYACCEL),W
	MOVE	A14,*A8(OYVEL),L
	MOVE	*A8(OFLAGS),A14,W
	ANDNI	M_GCOLL,A14
	MOVE	A14,*A8(OFLAGS),W
	RETS


BRIK_ANIM
	LW	BRIK1,2
	LW	BRIK3,2
	LW	BRIK5,2
	LW	BRIK7,2
	LW	BRIK9,2
	LW	BRIK11,2
	LW	BRIK12,2
	LW	BRIK14,2
	LW	BRIK16,2
	LW	BRIK18,2
	LW	BRIK21,2
	LW	BRIK23,2
	LWL	BRIK25,2|AFunc,A_OFFSCRN_DEL
	.long	0

GXBRIK_ANIM
	LW	GXBRIK1,2
	LW	GXBRIK2,2
	LW	GXBRIK3,2
	LW	GXBRIK4,2
	LW	GXBRIK5,2
	LW	GXBRIK6,2
	LW	GXBRIK7,2
	LW	GXBRIK8,2
	LW	GXBRIK9,2
	LW	GXBRIK10,2
	LWL	GXBRIK11,2|AFunc,A_OFFSCRN_DEL
	.long	0

CBRIK_ANIM
	LW	CBRIK1,2
	LW	CBRIK2,2
	LW	CBRIK3,2
	LW	CBRIK4,2
	LW	CBRIK5,2
	LW	CBRIK6,2
	LW	CBRIK7,2
	LW	CBRIK8,2
	LW	CBRIK9,2
	LW	CBRIK10,2
	LW	CBRIK11,2
	LWL	CBRIK12,2|AFunc,A_OFFSCRN_DEL
	.long	0

;NOSHRED_ANIM
;	LW	NOSHRED1,2
;	LW	NOSHRED2,2
;	LW	NOSHRED3,2
;	LW	NOSHRED4,2
;	LW	NOSHRED5,2
;	LW	NOSHRED6,2
;	LW	NOSHRED7,2
;	LW	NOSHRED8,2
;	LW	NOSHRED9,2
;	LW	NOSHRED10,2
;	LW	NOSHRED11,2
;	LWL	NOSHRED12,2|AFunc,A_OFFSCRN_DEL
;	.long	0


**************************************************************************
*								         *
* 		BTR Destruction stuff					 *
*								         *
**************************************************************************
**************************************************************************
*								         *
* 	A_DELETE_BTR							 *
* 									 *
* 	Anim Func to delete the whole BTR multi-parter,			 *
* 	no matter what part is calling. 				 *
* 									 *
* 	A8 = Ptr to any part						 *
*								         *
**************************************************************************
A_DELETE_BTR
	CALLA	GET_HEAD_PART

	CALLR	DEL_HATCH_BOY

	movk	1,a0
	move	a0,@BTR_GONE		; tell the world to move on.

	JAUC	DELETE_ENEMY		;Now rid yourself of the desk

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
	MOVE	*A8(OPART1),A0,L
	CLRB	*A0(OPARTEXPLODING)
	MOVE	*A8(OPART_FINAL_CONT),A1,L
	JANZ	SetAnim
	RETS

**************************************************************************
*								         *
* 	A_START_PARTS							 *
* 									 *
* 	Anim func to start all relevent parts animating.		 *
*								         *
**************************************************************************
A_START_PARTS
	CALLA	GETAFARG_LONG
	MOVE	A0,A2
	MOVK	NUM_BODY,A1
	CALLA	FINDPART
	MOVK	11,A6
	MOVE	A2,A1
ASP_LOOP
	CALLA	STRTANIM
	MOVE	*A0(OPARTS),A0,L
	DSJS	A6,ASP_LOOP
	RETS

**************************************************************************
*								         *
* 	A_BLOW_DAMN							 *
* 									 *
* 	Anim func to blow out a body part.				 *
*								         *
**************************************************************************
A_BLOW_DAMN
	MOVE	*A8(OBLOW_AFUNC),A14,L
	JUMP	A14

**************************************************************************
*								         *
* 	A_BLOW_DAMN1							 *
* 									 *
* 	Anim func to blow damage piece.					 *
* 									 *
* 	A8 = Ptr to damage piece					 *
*								         *
**************************************************************************
A_BLOW_DAMN1
	MOVI	80000H,A1
	MOVE	A1,A2
	MOVI	-80000H,A3
	MOVE	A3,A4
	JRUC	BLOW_BTR_PART

**************************************************************************
*								         *
* 	A_BLOW_DAMN234							 *
* 									 *
* 	Anim func to blow damage piece.					 *
* 									 *
* 	A8 = Ptr to damage piece					 *
*								         *
**************************************************************************
A_BLOW_DAMN234
	MOVI	20000H,A1
	MOVI	60000H,A2
	MOVI	-80000H,A3
	MOVE	A3,A4
	JRUC	BLOW_BTR_PART

**************************************************************************
*								         *
* 	A_BLOW_DAMN5							 *
* 									 *
* 	Anim func to blow damage piece.					 *
* 									 *
* 	A8 = Ptr to damage piece					 *
*								         *
**************************************************************************
A_BLOW_DAMN5
	MOVI	20000H,A1
	MOVE	A1,A2
	MOVI	-80000H,A3
	MOVE	A3,A4
	JRUC	BLOW_BTR_PART

**************************************************************************
*								         *
* 	A_BLOW_DAMN6							 *
* 									 *
* 	Anim func to blow damage piece.					 *
* 									 *
* 	A8 = Ptr to damage piece					 *
*								         *
**************************************************************************
A_BLOW_DAMN6
	MOVI	80000H,A1
	MOVE	A1,A2
	CLR	A3
	MOVE	A3,A4
	JRUC	BLOW_BTR_PART

**************************************************************************
*								         *
* 	A_BLOW_DAMN7							 *
* 									 *
* 	Anim func to blow damage piece.					 *
* 									 *
* 	A8 = Ptr to damage piece					 *
*								         *
**************************************************************************
A_BLOW_DAMN7
	CLR	A1
	MOVE	A1,A2
	MOVI	-80000H,A3
	MOVE	A3,A4
	JRUC	BLOW_BTR_PART

**************************************************************************
*								         *
* 	A_BLOW_DAMN8							 *
* 									 *
* 	Anim func to blow damage piece.					 *
* 									 *
* 	A8 = Ptr to damage piece					 *
*								         *
**************************************************************************
A_BLOW_DAMN8
	MOVI	-20000H,A1
	MOVE	A1,A2
	MOVI	-80000H,A3
	MOVE	A3,A4
	JRUC	BLOW_BTR_PART

**************************************************************************
*								         *
* 	A_BLOW_DAMN9							 *
* 									 *
* 	Anim func to blow damage piece.					 *
* 									 *
* 	A8 = Ptr to damage piece					 *
*								         *
**************************************************************************
A_BLOW_DAMN9
	MOVI	-40000H,A1
	MOVE	A1,A2
	MOVI	-80000H,A3
	MOVE	A3,A4
	JRUC	BLOW_BTR_PART

**************************************************************************
*								         *
* 	A_BLOW_DAMN10							 *
* 									 *
* 	Anim func to blow damage piece.					 *
* 									 *
* 	A8 = Ptr to damage piece					 *
*								         *
**************************************************************************
A_BLOW_DAMN10
	MOVI	-80000H,A1
	MOVE	A1,A2
	MOVI	-80000H,A3
	MOVE	A3,A4
	JRUC	BLOW_BTR_PART

**************************************************************************
*								         *
* 	A_BLOW_DAMN11							 *
* 									 *
* 	Anim func to blow damage piece.					 *
* 									 *
* 	A8 = Ptr to damage piece					 *
*								         *
**************************************************************************
A_BLOW_DAMN11
	MOVI	-80000H,A1
	MOVE	A1,A2
	CLR	A3
	MOVE	A3,A4
	JRUC	BLOW_BTR_PART

**************************************************************************
*								         *
* 	BLOW_BTR_PART							 *
* 									 *
* 	Anim func entrypoint to blow a part of the desk.		 *
* 									 *
* 	A1 = MIN XVEL							 *
* 	A2 = MAX XVEL							 *
* 	A3 = MIN YVEL							 *
* 	A4 = MAX YVEL							 *
* 	A8 = Ptr to object we are blowing				 *
* 									 *
* 	Note: trashes much register					 *
*								         *
**************************************************************************
BLOW_BTR_PART
	CALLA	CREATE_COPY
	JRZ	BBP_X  			;No objects available

	MOVE	*A0(OCTRL),A5,W

	MOVE	A0,A6

	MOVE	A2,A0
	CALLA	RANGERND
	BTST	B_FLIPH,A5
	JRNZ	BBP_X_POS
	NEG	A0
BBP_X_POS
	MOVE	A0,*A6(OXVEL),L

	MOVE	A4,A0
	MOVE	A3,A1
	CALLA	RANGERND
	MOVE	A0,*A6(OYVEL),L
	
	MOVE	A6,A0

	ANDNIM	M_NODISP,*A0(OFLAGS),W

	MOVI	ANIM_BLOW_SCREEN,A1
	CALLA	STRTANIM

	CALLA	INSOBJ
BBP_X
	RETS

*
* Turret hits the ground
*
ANIM_TUR_GROUND
	LWL	1,1|AFunc,OBJ_OFF
	LWLLLL	1,1|AFunc,A_PreFrag_Box+6,FRAG_EXPLOSION,80h,40000h
	LWL	1,1|AFunc,A_MULTI_METAL_CHUNK
	LWLLLL	1,1|AFunc,A_PreFrag_Box+6,FRAG_EXPLOSION,80h,40000h
	LWL	1,1|AFunc,DELETE_OBJ

ANIM_DAMN1
	LWLL	DAMN1,1|AFunc,A_CHANGE_PAL+2,P_BTRD1
	LWLWL	1,1|AFunc,A_Set_Rel_Long+3,OPART_FINAL_CONT,0
	LWLL	1,1|AFunc,A_AnimFrm+2,ANIM_BIG_SHIT_EXPLOSION
ANIM_DAMN2
	LWLL	DAMN2,1|AFunc,A_CHANGE_PAL+2,P_BTRD1
	LWLWL	1,1|AFunc,A_Set_Rel_Long+3,OPART_FINAL_CONT,0
	LWLL	1,1|AFunc,A_AnimFrm+2,ANIM_BIG_SHIT_EXPLOSION
ANIM_DAMN3
	LWLL	DAMN3,1|AFunc,A_CHANGE_PAL+2,P_BTRD2
	LWLWL	1,1|AFunc,A_Set_Rel_Long+3,OPART_FINAL_CONT,0
	LWLL	1,1|AFunc,A_AnimFrm+2,ANIM_BIG_SHIT_EXPLOSION
ANIM_DAMN4
	LWLL	DAMN4,1|AFunc,A_CHANGE_PAL+2,P_BTRD4
	LWLWL	1,1|AFunc,A_Set_Rel_Long+3,OPART_FINAL_CONT,0
	LWLL	1,1|AFunc,A_AnimFrm+2,ANIM_BIG_SHIT_EXPLOSION
ANIM_DAMN5
	LWLL	DAMN5,1|AFunc,A_CHANGE_PAL+2,P_BTRD3
	LWLWL	1,1|AFunc,A_Set_Rel_Long+3,OPART_FINAL_CONT,0
	LWLL	1,1|AFunc,A_AnimFrm+2,ANIM_BIG_SHIT_EXPLOSION
ANIM_DAMN6
	LWLL	DAMN6,1|AFunc,A_CHANGE_PAL+2,P_BTRD2
	LWLWL	1,1|AFunc,A_Set_Rel_Long+3,OPART_FINAL_CONT,0
	LWLL	1,1|AFunc,A_AnimFrm+2,ANIM_BIG_SHIT_EXPLOSION
ANIM_DAMN7
	LWLL	DAMN7,1|AFunc,A_CHANGE_PAL+2,P_BTRD3
	LWLWL	1,1|AFunc,A_Set_Rel_Long+3,OPART_FINAL_CONT,0
	LWLL	1,1|AFunc,A_AnimFrm+2,ANIM_BIG_SHIT_EXPLOSION
ANIM_DAMN8
	LWLL	DAMN8,1|AFunc,A_CHANGE_PAL+2,P_BTRD3
	LWLWL	1,1|AFunc,A_Set_Rel_Long+3,OPART_FINAL_CONT,0
	LWLL	1,1|AFunc,A_AnimFrm+2,ANIM_BIG_SHIT_EXPLOSION
ANIM_DAMN9
	LWLL	DAMN9,1|AFunc,A_CHANGE_PAL+2,P_BTRD3
	LWLWL	1,1|AFunc,A_Set_Rel_Long+3,OPART_FINAL_CONT,0
	LWLL	1,1|AFunc,A_AnimFrm+2,ANIM_BIG_SHIT_EXPLOSION
ANIM_DAMN10
	LWLL	DAMN10,1|AFunc,A_CHANGE_PAL+2,P_BTRD1
	LWLWL	1,1|AFunc,A_Set_Rel_Long+3,OPART_FINAL_CONT,0
	LWLL	1,1|AFunc,A_AnimFrm+2,ANIM_BIG_SHIT_EXPLOSION
ANIM_DAMN11
	LWLL	DAMN11,1|AFunc,A_CHANGE_PAL+2,P_BTRD1
	LWLWL	1,1|AFunc,A_Set_Rel_Long+3,OPART_FINAL_CONT,0
	LWLL	1,1|AFunc,A_AnimFrm+2,ANIM_BIG_SHIT_EXPLOSION

ANIM_TIREFL
;	LWLWL	TIREFL,1|AFunc,A_Set_Rel_Long+3,OPART_FINAL_CONT,0
	LWLWL	1,1|AFunc,A_Set_Rel_Long+3,OPART_FINAL_CONT,0
	LWLL	1,1|AFunc,A_AnimFrm+2,ANIM_BIG_SHIT_EXPLOSION

ANIM_BIG_SHIT_EXPLOSION
	LWLLL	1,1|AFunc,A_BRANCH_IF_TRUE+4,HOLD_ENEMY_DISPATCH,ANIM_LITTLE_SHIT

	LWLLLL	1,1|AFunc,A_PreFrag_Box+6,FRAG_EXPLOSION,80h,40000h
	LWL	1,1|AFunc,A_MULTI_METAL_CHUNK
	LWLLLL	1,1|AFunc,A_PreFrag_Box+6,FRAG_EXPLOSION,80h,40000h
;	LWL	1,1|AFunc,A_START_MEDIUM_SHAKE
	LWL	1,26|AFunc,A_MULTI_METAL_CHUNK
	LWLLLL	1,1|AFunc,A_PreFrag_Box+6,FRAG_EXPLOSION,80h,40000h
;	LWL	1,1|AFunc,A_START_MEDIUM_SHAKE
	LWL	1,16|AFunc,A_MULTI_METAL_CHUNK
	LWLWW	1,1|AFunc,A_RAND_AnimSLP+2,1,10
	LW	1,0
;	LWL	1,1|AFunc,A_CHECK_IF_FINAL
	LWL	1,1|AFunc,A_CONTINUE_PART_FINAL
	LWL	1,1|AFunc,PULL_ANIM

ANIM_LITTLE_SHIT
	LWLWW	1,1|AFunc,A_RAND_AnimSLP+2,1,10
	LW	1,0
	LWLLLL	1,1|AFunc,A_PreFrag_Box+6,FRAG_EXPLOSION,80h,40000h
	LWL	1,1|AFunc,A_MULTI_METAL_CHUNK
	LWLWW	1,1|AFunc,A_RAND_AnimSLP+2,1,10
	LW	1,0
	LWL	1,1|AFunc,A_CONTINUE_PART_FINAL
	LWL	1,1|AFunc,PULL_ANIM

*
* BTR final explosion
* Start this on the head part
*
ANIM_FINAL_EXPLOSION
	LWLW	1,1|AFunc,A_Set_AnimLoop+1,3
AFE_LOOP
	LWLLLL	1,1|AFunc,A_PreFrag_Center+6,FRAG_EXPLOSION,0400h,40000h
	LWLLLL	1,1|AFunc,A_PreFrag_Center+6,FRAG_EXPLOSION,0400h,40000h
	LWLWW	1,1|AFunc,A_RAND_AnimSLP+2,10,25
	LWLL	1,0|AFunc,A_Anim_DSJ+2,AFE_LOOP

	LWLL	1,1|AFunc,A_START_PARTS+2,ANIM_PART_EXPLOSIONS

	LWLW	1,1|AFunc,A_Set_AnimLoop+1,8
AFE_CRAFT_BLOW
	LWLLLL	1,1|AFunc,A_PreFrag_Center+6,FRAG_EXPLOSION,0400h,40000h
	LWLWW	1,1|AFunc,A_RAND_AnimSLP+2,5,10
	LWLL	1,0|AFunc,A_Anim_DSJ+2,AFE_CRAFT_BLOW

	LWLL	1,1|AFunc,A_SOUND+2,SND_FINAL_EXPLODE3
	LWLLLL	1,1|AFunc,A_PreFrag_Center+6,FRAG_DESK_EXPLOSION,01000h,80000h
	LWLL	1,1|AFunc,A_SOUND+2,SND_FINAL_EXPLODE2
	LWLL	1,1|AFunc,A_SOUND+2,SND_FINAL_EXPLODE1
	LWLLLL	1,1|AFunc,A_PreFrag_Center+6,FRAG_DESK_METAL,01000h,80000h

	LWLLLL	1,1|AFunc,A_PreFrag_Rain+6,FRAG_TIRES,0,40000H

	LWLL	1,1|AFunc,A_START_PARTS+2,ANIM_DAMN_BLOW

	LWLLLL	1,1|AFunc,A_PreFrag_Rain+6,FRAG_DESK_RAIN,80H,40000H

	LWL	1,1|AFunc,DELAYED_PRAISE

	LWL	1,60|AFunc,OBJ_OFF_MULTI

	LWL	1,1|AFunc,A_DELETE_BTR

*
* Explosions from a given part
*
ANIM_PART_EXPLOSIONS
	LWLW	1,1|AFunc,A_Set_AnimLoop+1,5
APE_LOOP
	LWLLLL	1,1|AFunc,A_PreFrag_Center+6,FRAG_EXPLOSION_SMALL,0100h,40000h
	LWLWW	1,1|AFunc,A_RAND_AnimSLP+2,5,20
	LWLL	1,0|AFunc,A_Anim_DSJ+2,APE_LOOP
	LWL	1,1|AFunc,PULL_ANIM

*
*Final blow animations
*
ANIM_DAMN_BLOW
	LWLW	1,1|AFunc,A_Set_AnimLoop+1,5
ANIM_D1_LOOP
	LWL	1,5|AFunc,A_BLOW_DAMN
	LWLL	1,1|AFunc,A_Anim_DSJ+2,ANIM_D1_LOOP
	LWL	1,1|AFunc,PULL_ANIM

*Simple animation to check if we are off screen and delete.
ANIM_BLOW_SCREEN
	LWLL	1,5|AFunc,A_ONSCREEN+2,ANIM_BLOW_SCREEN
	LWL	1,1|AFunc,DELETE_OBJ

**************************************************************************
*								         *
* 		BTR Fragment scripts and such				 *
*								         *
**************************************************************************
FRAG_MISSLE_DOOR
	.long	PART_EXPLOSION,F_EXPLOSION_OUT
	.word	OID_JUNK,10*800H+5*40H+FRGPAL+FRGNOFLY
	.long	PART_EXPLOSION,F_EXPLOSION_OUT
	.word	OID_JUNK,10*800H+5*40H+FRGPAL+FRGNOFLY
	.long	PART_EXPLOSION,F_EXPLOSION_OUT
	.word	OID_JUNK,10*800H+5*40H+FRGPAL+FRGNOFLY
	.long	0

FRAG_TURRET
	.long	PART_EXPLOSION,F_EXPLOSION_UP
	.word	OID_JUNK,10*800H+5*40H+FRGPAL+FRGNOFLY
	.long	PART_EXPLOSION,F_EXPLOSION_UP
	.word	OID_JUNK,10*800H+5*40H+FRGPAL+FRGNOFLY
	.long	PART_EXPLOSION,F_EXPLOSION_UP
	.word	OID_JUNK,10*800H+5*40H+FRGPAL+FRGNOFLY
	.long	0

FRAG_TIRES
	.long	tirerotlft,F_TIRE
	.word	OID_JUNK,1*800H+1*40H+FRGPAL+FRGGCOL+FRGNOFLP

	.long	tirerotlft,F_TIRE
	.word	OID_JUNK,1*800H+1*40H+FRGPAL+FRGGCOL+FRGNOFLP

	.long	tirerotlft,F_TIRE
	.word	OID_JUNK,1*800H+1*40H+FRGPAL+FRGGCOL+FRGNOFLP

	.long	tirerotlft,F_TIRE
	.word	OID_JUNK,1*800H+1*40H+FRGPAL+FRGGCOL+FRGNOFLP

	.LONG	0


**************************************************************************
*								         *
* 	F_EXPLOSION_UP							 *
* 									 *
* 	Frag func that makes an explosion fly up.			 *
* 									 *
* 	A0 = Ptr to un-inserted object.					 *
* 									 *
* 	Note: Frag funcs must preserve A8-A11 and all B-File regs.	 *
*								         *
**************************************************************************
F_EXPLOSION_UP
	MOVE	*A0(OYVEL),A14,L
	ABS	A14
	NEG	A14
	MOVE	A14,*A0(OYVEL),L
	RETS

**************************************************************************
*								         *
* 	F_TIRE								 *
* 									 *
* 	Frag func for the BTR tire.					 *
* 									 *
* 	A0 = Ptr to un-inserted object.					 *
*								         *
* 	Note: Frag funcs must preserve A8-A11 and all B-File regs.	 *
*								         *
**************************************************************************
F_TIRE
	MOVI	M_FLIPH,A14
	CALLA	RANDFLIP		;Flip it left or right

	MOVE	*A0(OXVEL),A1,L
	ABS	A1
	CMPI	8000H,A1
	JRHS	FT_VELOK
	MOVI	8000H,A1
FT_VELOK
	MOVE	*A0(OCTRL),A14,W
	BTST	B_FLIPH,A14
	JRZ	FT_NOFLIP
	NEG	A1
FT_NOFLIP
	MOVE	A1,*A0(OXVEL),L

	MOVIM	FRAG_TIRE_CVECT,*A0(OCVECT),L

	ORIM	M_NOSCALE,*A0(OFLAGS),W

	MOVE	@RAND,A1,L
	SLL	24,A1
	SRL	24,A1
	ADDI	0A000H,A1		;Give a slightly unique Z
	MOVE	@ZBASE,A14,L		
	ADD	A14,A1
	MOVE	A1,*A0(OZVAL),L

	PUSH	A0
	MOVI	-60000H,A0
	MOVI	-40000H,A1
	CALLA	RANGERND
	MOVE	A0,A1
	PULLQ	A0

	MOVE	A1,*A0(OYVEL),L

	RETS

**************************************************************************
*								         *
* 	FRAG_TIRE_CVECT							 *
* 									 *
* 	BTR tire collision vector table					 *
*								         *
**************************************************************************
FRAG_TIRE_CVECT
	WWL	OID_GRND,0FFFFH,TIRE_GROUND_COLL
	WL	0,DUMCRETS

**************************************************************************
*								         *
* TIRE_GROUND_COLL - Collision routine for tire fragment.		 *
* A8 = Ptr to object							 *
*								         *
**************************************************************************
TIRE_GROUND_COLL
	MOVB	*A8(OFLAGS),A14		;Are we out of Range?
	JAN	DELETE_OBJ		;BR = Yes

	MOVE	*A8(OYVEL),A14,L
	MOVE	A14,A1
	SRA	1,A14			;Knock off 25% for the bounce.
	SUB	A14,A1
       	NEG	A1			;Turn it up
	MOVE	A1,*A8(OYVEL),L
	RETS

*
*	DETERMINE IF A BERZERKER SHOULD BE UNLEASHED UPON EXITING THE
*	ELEVATOR
*
S_SHOCKER
	MOVKM	1,@WAVE_WAIT,W
	MOVE	a14,@ENEMY_QUOTA,W
	move	@PLYR_SEEN,a14
	jaz	skipparm		; forget it if vidcam shot
	calla	SET_WAVE
	jauc	SCRL_DISPATCHER

skipparm:
	move	*a11+,a14,L	; skip over dispatch table
	jauc	SCRL_DISPATCHER



	.IF 0			;Snake graveyard

	.DEF	CREATE_A_SNAKE

	.bss	SNAKEPOS,4*16	; table of occupied snake positions

***************************************************
*
*               POP UP SNAKE
*
***************************************************
TngWrldZ	.set 5000h
TngHitZ		.set 3800h
TngStScl	.set 20000h>>Z2SCALE
TngEndScl	.set 0d0h
TngTiks		.set 13
TngZVel		.set (TngHitZ-TngWrldZ)/TngTiks
TngSlope	.set ((TngStScl-TngEndScl)*10000h)/(TngWrldZ-TngHitZ)
TngIntrcpt	.set ((TngStScl<<16)-(TngSlope*TngWrldZ))>>16

OBODYTNG	.set	ODATA+40h	; xlink between snake body and tongue

SNAKE_INIT:
	.byte	4,0,0,1
	.long	COBRA1_P
	.word	OID_DESK, OM_COLL|OM_POS|OM_SPOS|OM_INSERT
	.long	SNAKE_CVECT
	.long	[300,45],TngWrldZ

	.long	COBRAHED1
	.word	DMAWNZ, M_NOSCALE, 0, OM_ANIM | OM_GUNV 
	.long	DUMRETS
	.long	SNAKEMTHOPN
	.long	COBRAHED1
	.word	DMAWNZ| M_FLIPH, M_NOSCALE, 0, OM_PRVGUNV
	.long	COBRABOD1
	.word	DMAWNZ, M_NOSCALE, 2, OM_PRVGUNV
	.long	COBRABOD1
	.word	DMAWNZ|M_FLIPH, M_NOSCALE, 2, OM_PRVGUNV


TUNG_INIT:
	.byte	4,0,0,1
	.long	COBRAT_P
	.word	OID_CAT, OM_COLL
	.long	TUNG_CVECT

	.long	COBTUNG2A
	.word	DMAWNZ, M_MANSCALE, -4, OM_ANIM |OM_GUNV
	.long	TUNG_GUNVECT
	.long	SNAKETNG

	.long	COBTUNG2A
	.word	DMAWNZ| M_FLIPH, M_MANSCALE, -4, OM_PRVGUNV

	.long	COBTUNG1
	.word	DMAWNZ, M_MANSCALE, -2, OM_GUNV
	.long	DUMRETS

	.long	COBTUNG1
	.word	DMAWNZ|M_FLIPH, M_MANSCALE, -2, OM_PRVGUNV


SNAKEMTHOPN:
	LWLL	1,3|AFunc,A_SET_OYVEL+2,-60000h

	LWLW	1,1|AFunc,A_STAY_TIL_SY_LT+1,155

	LWLL	1,1|AFunc,A_SET_OYVEL+2,0

	LWL	1,1|AFunc,A_SET_ATTACK_TIME
	LW	1,0

	LW	COBRAHED2,3|AMulti
	LW	COBRAHED2,3

	LW	COBRAHED3,3|AMulti
	LW	COBRAHED3,3

	LW	COBRAHED4,3|AMulti
	LW	COBRAHED4,3

	LWL	1,1|AFunc,SNAKE_ATTACK

SNAKEMTHCLO:
	LWLL	COBRAHED3,3|AMulti|AFunc,A_SET_OYVEL+2,48000h
	LW	COBRAHED3,3

	LW	COBRAHED2,3|AMulti
	LW	COBRAHED2,3

	LW	COBRAHED1,3|AMulti
	LW	COBRAHED1,3

	LWL	1,7|AFunc,A_AnimGo+2,SNAKE_WAIT


SNAKETNG:
	LW	COBTUNG2B,2|AMulti
	LW	COBTUNG2B,2

	LW	COBTUNG2C,2|AMulti
	LW	COBTUNG2C,2

	LW	COBTUNG2B,2|AMulti
	LW	COBTUNG2B,2

	LW	COBTUNG2A,2|AMulti
	LW	COBTUNG2A,2

	.long	0

SNAKE_WAIT:
	LWL	1,7|AFunc,A_OFF_DELETE_OBJ
	.long	0


A_SET_ATTACK_TIME:
	move	@ATTACK_TIME,a14
	movb	a14,*a8(AnimSLP)
	cmpk	5,a14
	jrlt	lvit
	subk	4,a14
	move	a14,@ATTACK_TIME
lvit:
	rets


TUNG_GUNVECT:
	PUSH	a8
	move	*a8(OPART1),a8,L	; get tongue head
	move	*a8(ODATA),a14,L	; Z vel
	jrz	markit			; if stinging
	jrnn	noeffect		; if retracting

	movi	TngWrldZ,a5		; set it back
	move	a5,*a8(ODATA+20h),L	; new world Z
*
*	Store new tongue ZPOS
*
	move	@ZBASE,a14,L
	move	a5,a1
	add	a14,a1	   		; new univ Z in a1
	calla	STORE_ZVALH		; set new Z of TONGUE

noeffect:
	PULLQ	a8
	rets

markit:
	movk	1,a14			; if stinging player, 
	move	a14,*a8(ODATA+60h)	;   mark as hit
	jruc	noeffect

SNAKE_CVECT
TUNG_CVECT
	WWL	OID_PROCKET,~MASK_PLAYER,SNAKE_COLL
	WWL	OID_PEXPLOSION,~MASK_PLAYER,SNAKE_COLL
	WL	0,DUMCRETS


SNAKEBLOWCHK:
	move	*a8(OID),a14
	cmpi	OID_DESK,a14
	jrne	notbody
	MMTM	SP,B1,B2,B4,B5,B6,B8,B9,B10
	move	*a8(OPART1),a8,L	; spurt if body
	move	*a8(OPARTS),a8,L
	move	*a8(OPARTS),a8,L
	calla	A_RANDOM_MULTI_CHUNK	; do both halves of body
	move	*a8(OPARTS),a8,L
	calla	A_RANDOM_MULTI_CHUNK
	MMFM	SP,B1,B2,B4,B5,B6,B8,B9,B10
notbody:     
	move	*a8(OPART1),a0,L	; leave head in a0 regardless
	rets

SNAKE_COLL:
	MOVE	*A0(OID),A0,W			;GET PLAYER DATA ADDRESS
	CALLA	POID_TO_PDATA			;GET PDATA IN A2

	PUSH	a8
	callr	SNAKEBLOWCHK
	move	*a0(OBODYTNG),a8,L	; if snake body hit,
	jrz	skipit			; tongue may be gone already
	PUSH	a0
	callr	SNAKEBLOWCHK
	move	a0,a8
	calla	DELETE_OBJ_PROC
	PULLQ	a0
skipit:
	move	a0,a8
	calla	DELETE_OBJ_PROC
	PULLQ	a8
	rets


SNAKE_PARTS:
	LW	COBCHNK1A,2
	LW	COBCHNK1B,2
	LW	COBCHNK1C,2
	LW	COBCHNK1D,2
	LW	COBCHNK1E,2
	LW	COBCHNK1F,2
	LW	COBCHNK1G,2
	LWL	COBCHNK1H,2|AFunc,A_OFF_DELETE_OBJ
	.long	0

*
*	don't create snake near an object which is really close
*
*	Exit:  Carry clear - okay to create
*	       Carry set - don't create near UNIV X in a1
*
CHECK_CLOSE:
	movi	FGLIST,a0
	movi	5200h,a2	; limit
	move	@ZBASE,a3,L
	add	a3,a2		; get universe limit
	move	@XBASE,a3,L
	move	@YWORLD,a5,L
	move	@YBASE,a14,L
	add	a14,a5
	subi	30000h,a5	; buffer zone in Y
CC_lp:
	move	*a0(OLINK),a0,L
	move	*a0(OFLAGS),a14	
	jrn	CC_lp		; ignore SCRNOBJs
	move	*a0(OZVAL),a14,L
	cmp	a14,a2
	jrlt	scan_over
 	move	*a0(OYVAL),a4,L	; is it near ground
	cmp	a4,a5		
	jrgt	CC_lp		; if no, keep looking

	move	*a0(OXVAL),a1,L ; keep away from this place
	sub	a3,a1		; get in world
	move	@XSCROLL,a14,L
	xor	a1,a14		; positive if scroll neg and world neg or
	btst	31,a14		;             scroll pos and world pos
	jrnz	scan_over

	setc		 	; don't do it if blocking obj is crossing screen
	rets


scan_over:
	clrc
	rets


killme:
	dec	a1
	move	a1,@SCROLLKILL
	DIE


*	a9 = lower sleep time
*	a10 = upper sleep time
*
CREATE_A_SNAKE:
	movi	340,a9
	movi	900,a10
CRESNK:
	move	@RAND,a3
	andi	31,a3
	cmpk	3,a3
	jrgt	normslp
	sloop	30,skpa10adj	; periodically do another quick one

normslp:
	RANDSLPR	a9,a10
	cmpk	18,a9
	jrle	skpa9adj
	subk	5,a9
skpa9adj:
	cmpi	100,a10
	jrle	skpa10adj
	subk	18,a10
skpa10adj:

	move	@SCROLLKILL,a1
	jrnz	killme

	move	@XSACCEL,a14,L
	abs	a14
	cmpi	34000h,a14
	jrgt	CRESNK		; don't create if SCROLLING too fast

	callr	CHECK_CLOSE	; don't create if an object is really close
	jrc	CRESNK		

	movi	SNAKE_INIT,b0
	calla	MULTIMAKE

	movi	160*TngWrldZ*2,a0
	calla	RAND0			; random adjustment to X
	move	*a8(OXVAL),a14,L
	add	a14,a0
	move	a8,a5			; 
CSnxtprt: 
	move	a0,*a5(OXVAL),L		; adjust X VAL accordingly

	move	*a5(OPARTS),a5,L
	jrnz	CSnxtprt

	move	@XSCROLL,a14,L
	move	a14,*a8(OXVEL),L

	jruc	CRESNK



*
*	called from Snake body animation when fully popped up
*
SNAKE_ATTACK:
	PUSH	a8		; save snake obj
	movi	TUNG_INIT,b0
	calla	MULTIMAKE
	jrz	TUNGX
	PULLQ	a10

	move	a8,a0
	movi	1b1bh,a14
partslp:
	MOVE	a14,*a0(OCONST),W
	move	*a0(OPARTS),a0,L
	jrnz	partslp
	
	move	a10,*a8(OBODYTNG),L	; cross link body and tongue
	move	a8,*a10(OBODYTNG),L

	movi	TngWrldZ,a5	; world Z in a5
	move	a5,*a8(ODATA+20h),L
	callr	SetTonguePos	; match tongue position to body's

	move	a10,a0
	calla	PULLANIM	; snake body no longer animating

	movi	TngStScl,a5
	calla	SET_SCALE_MANUAL

	calla	INSERT_OBJ	; insert new multiparter

	CREATE	PID_IND,TUNG_ADJ_SCL
	move	a0,*a8(OPLINK),L

	movi	TngZVel,a3	; send tongue off in Z
	move	a3,*a8(ODATA),L

	CREATEP	PID_IND,TUNG_ADJ_POS
	move	a0,*a10(OPLINK),L

	SOUND1	SND_SNAKE_HISS

TUNGX:
	rets	

SND_SNAKE_HISS	.word	0f341h,86,0a3b6h,0


*
*	Set objects velocity to match scroll velocities
*
MatchScrollVel:
	move	@XSCROLL,a14,L
	move	a14,*a8(OXVEL),L

	move	@ZSCROLL,a14,L
	sra	ZFRAC,a14 		; convert to lores
	move	a14,*a8(OZVEL),L
	rets


*	ENTRY:
*	 a10 = obj of body
*	 a8 = obj of tongue
*	 a5 = world Z of tongue  (Set Tongue only)
*
ComputeTonguePos:
	move	*a8(ODATA+20h),a5,L	; world Z
	move	*a8(ODATA),a14,L	; Z VEL
	add	a14,a5
	move	a5,*a8(ODATA+20h),L	; new world Z
SetTonguePos:
	move	@ZBASE,a2,L
	move	a5,a1
	add	a2,a1	   		; new univ Z in a1
	calla	STORE_ZVALH		; set new Z of TONGUE

	movi	TngWrldZ,a1
	add	a2,a1			; keep snake at constant world Z
	move	a8,a2			; set new Z of Snake BODY
	move	a10,a8
	calla	STORE_ZVALH
	move	a2,a8

	move	*a10(ODAG),a0,L
	move	*a10(OANIOFF),a14,L
	addxyi	[-3,0],a14		; kludge adjustment
	addxy	a14,a0			; get anim pt SCRN X
	move	a0,a1
	sext	a0
	sra	16,a1			; get anim pt SCRN Y

	move	@YHALF,a14
	sub	a14,a1
	subi	HALFX,a0
	setf	16,1,1
	move	a5,a3
	mpys	a5,a1		; world Y
	mpys	a0,a3		; world X
	setf	32,0,1
	move	@XBASE,a14,L
	add	a14,a3
	move	@XSCROLL,a14,L
	add	a14,a3
	move	@YBASE,a14,L
	add	a14,a1

	move	a8,a0
CTPlp:
	move	a3,*a0(OXVAL),L
	move	a1,*a0(OYVAL),L
	move	*a0(OPARTS),a0,L
	jrnz	CTPlp

	rets


*	 a10 = obj of body
*	 a8 = obj of tongue
TUNG_ADJ_POS:
	callr	ComputeTonguePos
	sloop	1,TUNG_ADJ_POS



*	a8 = tung
*	a10 = body
TUNG_ADJ_SCL:
	movi	TngSlope,a9
	movi	TngIntrcpt,a11
TAS1:
	move	*a8(OZVAL),a5,L
	move	@ZBASE,a14,L
	sub	a14,a5			; world Y in a14
	mpys	a9,a5
	sra	16,a5			; lose fraction
	add	a11,a5			; get scale factor
	cmpi	TngEndScl,a5
	jrlt	sting
	calla	SET_SCALE_MANUAL

     	sloop	1,TAS1

sting:
	CLRM	*a8(ODATA),L   		; stop Z motion of tongue
*
*	10 TIKS OF IN YOUR FACE
*
	sleep	10

*
*	56 TIKS OF FLASH AND STING IN YOUR FACE
*
	movk	7,a11
stinglp:
	clr	a3
	movi	[1,4000h],a5
	calla	CK_PLAYER_HIT

	move	a8,a4
	callA	UNIV_FLASH		; flash 1st part
	move	*a8(OPARTS),a8,L
	callA	UNIV_FLASH		; flash flipped other half
	move	a4,a8

	movk	8,a9
waitlp:
	move	*a8(ODATA+60h),a14	; nonzero means hit by bullet
	jrz	nosave
	CLRM	*a8(ODATA+60h),W	; reset hit flag
	subk	3,a11			; save some zapping
	jrgt	nosave
	movk	1,a11			; for last dsjs
nosave:
	sleep	1
	dsjs	a9,waitlp

	dsj	a11,stinglp
*
*	START WITHDRAWING
*
	movi	-TngZVel,a3
	move	a3,*a8(ODATA),L

	calla	ALL_COLLS_OFF		; for tongue only
	movi	TngSlope,a9
	movi	TngIntrcpt,a11

TAS0:
	move	*a8(OZVAL),a5,L
	move	@ZBASE,a14,L
	sub	a14,a5			; world Z in a5
	mpys	a9,a5
	sra	16,a5			; lose fraction
	add	a11,a5			; get scale factor
	cmpi	TngStScl,a5
	jagt	TAS2
	calla	SET_SCALE_MANUAL

	sloop	1,TAS0

TAS2:
	CLRM	*a8(OPLINK),L
	move	*a10(OPLINK),a0,L	; kill TUNG_ADJ_POS
	move	a14,*a10(OPLINK),L
	move	a14,*a10(OBODYTNG),L	; remove link to tongue
	calla	KILL

	calla	DELETE_OBJ		; get rid of the tongue

	move	a10,a0			; pop snake down
	movi	SNAKEMTHCLO,a1
	calla	STRTANIM

	DIE

*******************************************  END OF SNAKE

	.ENDIF
	.END
