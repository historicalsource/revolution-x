 	.MLIB	"GXMACS.LIB"
	.FILE	"GXKERRI.ASM"
	.TITLE	"<<< GENERATION X -- The lovely Kerri Hoskins >>>"
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
	.INCLUDE	"IMGTBL.GLO"
	.INCLUDE	"GXKLUDGE.H"
	.include	gxkerri.tbl

***** In this file
	.DEF	PROC_KERRI_KISS, AU_CREATE_KERRI_FLOSS
	.DEF	KERCAGE_COLLVECT, KERCAGE_GUNVECT
	.DEF	RN3B01, RN3B02, RN3B03, RN3B04, RN3B05, RN3B06, RN3B07
	.DEF	RN3B08

***** From GXAFUNC.ASM
	.REF	A_STAY_TIL_GRND_HIT, A_Set_LOOP_STRT, A_Set_Var_Word
	.REF	A_CLR_OYVEL, A_STAY_TIL_SY_LT, A_STAY_TIL_OFFSCRN

***** From GXRAM.ASM
	.REF	KISSING_KERRI

***** From GXUNISEQ.ASM
	.REF	dn1b,dn5b

***** From GXUNIFX.ASM
	.REF	KCAGE_EXPLO_INIT

***** From GXUNIV1.ASM
	.REF	BOX_CHECK_OBJ2

***** From GXPLAYER.ASM
	.REF	VALID_PLAYER, PLAYER_AWARD_GIRL

***** From GXJUNGLE.ASM
	.REF	MAKE_VIDCAM_SND

***** From GXDESK.ASM
	.REF	DGV_FRAG_SPARK

***** From GXUNIJP2.ASM
	.REF	METAL_GUNVECT

***** From GXBEEK2.ASM
	.REF	KERRI_RUNAWAY_ANIM

*
* Object data field
*
OGIRL_RESCUER	.EQU	OU_ODATA	;UHL Player that free'd Kerri
OKERRI_SEAT	.EQU	OU_ODATA+20H	;UHL This is the seat she's in

**************************************************************************
*								         *
* 	PROC_KERRI_KISS							 *
* 									 *
* 	Process to create a pop-up kissing Kerri.			 *
* 									 *
* 	A11 = Ptr to player data area that she is going to kiss		 *
*								         *
**************************************************************************
PROC_KERRI_KISS
	MOVE	@KISSING_KERRI,A14,W
	JRZ	PKK_KAN_KISS		;BR = No other Kissing Kerri's
	SLOOP	5,PROC_KERRI_KISS

PKK_KAN_KISS
	MOVI	KERRI_KISS_INIT,B0
	CALLA	MULTIMAKE
	JAZ	SUCIDE			;BR = We couldn't get one

	MOVE	*A11(PHITBOXUL),A1,W
	MOVE	*A11(PHITBOXLR),A2,W
	SUB	A1,A2
	SRA	1,A2			;Make her pop in the middle of player
	ADD	A2,A1
	ADDXYI	(256+130) << 16,A1
	
	MOVI	-60000000H,A2

	CALLA	SET_SCRNOBJ

	CLR	A14
	MOVE	A14,*A8(OCVECT),L
	MOVE	A14,*A8(OGUNVECT),L	;Clear vectors for sure

	MOVKM	1,@KISSING_KERRI,W

	CALLA	INSERT_OBJ

	DIE

**************************************************************************
*								         *
* 	A_BIG_KISS_SOUND						 *
* 									 *
* 	What to say, what to say.					 *
* 									 *
* 	A8 = ptr to speaking part					 *
*								         *
**************************************************************************
A_BIG_KISS_SOUND
	MOVE	@GAME_STATE,A14,W
	CMPI	INGAME,A14
	JREQ	ABKS_BONUS_SND
	SOUND1	SND_THANK_YOU
	MOVIB	25,*A8(AnimSLP)
	RETS
ABKS_BONUS_SND
	SOUND1	SND_BEST
	MOVIB	50,*A8(AnimSLP)
	RETS
*
* Init table for pop-up kissing Kerri
*
KERRI_KISS_INIT
	.BYTE	 3, 0, 0, 1	;OBJCNT, PRCCNT, IMGPALCNT, PALCNT
	.LONG	CUKRKIS_P
	.WORD	OID_JUNK, 0

*    .long IMG
*    .word OCTRL, OFLAGS, OZOFF, OPTION_BITS

	LWWWW	CUKERKIS2A, DMAWNZ, M_SCRNOBJ|M_NOSCALE, 0, OM_ANIM
	.LONG	KERRI_KISS_ANIM
	LWWWW	CUKERKIS2B, DMAWNZ, M_SCRNOBJ|M_NOSCALE, 0, 0
	LWWWW	CUKERKIS2C, DMAWNZ, M_SCRNOBJ|M_NOSCALE, 0, 0
*
* Pop-up and kiss animation
*
KERRI_KISS_ANIM
	LWLL	1,1|AFunc,A_SET_OYVEL+2,-60000h
	LWLW	1,1|AFunc,A_STAY_TIL_SY_LT+1,150
	LWL	1,2|AFunc,A_CLR_OYVEL

	LWL	1,1|AFunc,A_BIG_KISS_SOUND
	LW	1,0

	LWLL	CUKERKIS1A,1|AMulti|AFunc,A_SOUND+2,SND_KERRI_KISS
	LW	CUKERKIS1B,1|AMulti
	LW	CUKERKIS1C,30

	LW	CUKERKIS2A,1|AMulti
	LW	CUKERKIS2B,1|AMulti
	LW	CUKERKIS2C,1

	LWLL	1,20|AFunc,A_SET_OYVEL+2,60000h

	LWLLW	1,1|AFunc,A_Set_Var_Word+3,KISSING_KERRI,0

	LWL	1,1|AFunc,DELETE_OBJ

SND_THANK_YOU
	.WORD	0F244H,47,0A532H,0
SND_FREE_AT_LAST
	.WORD	0F244H,79,0A53BH,0
SND_BEST
	.WORD	0F244H,80,0A547H,0

SND_KERRI_KISS
	.WORD	0F144H,15,0A252H,0

**************************************************************************
*								         *
* 	FREE_CAGE_KERRI							 *
* 									 *
* 	Free Kerri from the dancing cage.				 *
* 									 *
* 	A8 = Cage front obj.						 *
* 	*A8(OGIRL_RESCUER),L = Ptr to player that free'd her		 *
*								         *
**************************************************************************
FREE_CAGE_KERRI:
	.IF AUSTRALIA
	RETS
	.ENDIF
	move	*a8(OULINK),a4,L
	move	*a4(MAP_Z),a10,L	; orig Z
	addi	5000h,a10		; range to look in
	move	*a4(MAP_X+10h),a1,W	; orig X pos of cage front
find_her_loop:
	move	*a4(MAP_NEXT),a4,L
	move	*a4(MAP_Z),a14,L
	cmp	a10,a14
	jrgt	give_up
	move	*a4(MAP_X+10h),a2,W
	move	*a4(MAP_X+10h),a2,W
	sub	a1,a2
	abs	a2
	cmpk	10,a2
	jrgt	find_her_loop		; she's close in X
	move	*a4(MAP_IMG),a3,L
	btst	0,a3
	jrz	find_her_loop		; she's animating
	move	*a4(MAP_OBJ),a0,L	
	jrn	find_her_loop		; she's created
	srl	4,a3
	sll	4,a3
	cmpi	dn5b,a3
	jrne	chk_fwd
*
*	She's dancing backwards, turn her around
*
	movi	FREE_FROM_5,a1
	jruc	found_her_hook
chk_fwd:
	cmpi	dn1b,a3
	jrne	find_her_loop
*
*	She's dancing forwards, turn her around
*
	movi	FREE_FROM_1,a1
found_her_hook:
	move	a8,a9  		; save cage obj
	move	a0,a8		; kerri obj into a8
	calla	BG_TO_FG		; no longer part of universe
	move	a8,a0
	MOVE	*A9(OGIRL_RESCUER),*A8(OGIRL_RESCUER),L	;Transfer for kiss
	move	a9,a8		; restore cage obj
	calla	STRTANIM
give_up:
	rets


PICK_A_DIRECTION:
	move	*a8(OCTRL),a5		; is she unflipped?
	move	*a8(OXVAL),a0,L
	move	@XBASE,a14,L
	sub	a14,a0		; world X in a0
	jrn	run_right
*
*	if off to right, run left (i.e. flip me)
*
	btst	B_FLIPH,a5
	jrnz	she_cool
flip_her:
	XORI	M_FLIPH,a5
	move	a5,*a8(OCTRL)
	rets
*
*	if off to left, run right (i.e. no flip)
*
run_right:
	btst	B_FLIPH,a5		; if not, unflip her
	jrnz	flip_her
she_cool:
	rets

**************************************************************************
*								         *
* 	A_KERRI_AWARD							 *
* 									 *
* 	Anim func to award the save for Kerri by putting the		 *
* 	big pop-up girl on the screen.  Deletes object when		 *
* 	done								 *
* 									 *
* 	A8 = Ptr to universe Kerri object				 *
* 	*A8(OGIRL_RESCUER),L = Player that should be awarded with	 *
* 				the kill.				 *
*								         *
**************************************************************************
A_KERRI_AWARD
	MOVE	*A8(OGIRL_RESCUER),A11,L
	CREATE	PID_IND, PROC_KERRI_KISS
	JAUC	DELETE_OBJ

FREE_FROM_5:
	LW	TR53B01,5
	LW	TR53B02,5
	LW	TR53B03,5
	LW	TR13B02,5
FREE_FROM_1:
	LW	SF1BA01,5
	LWLL	SF1BA02,5|AFunc,A_SOUND+2,SND_FREE_AT_LAST
	LWLL	SF1BA03,5|AFunc,A_SET_OZVEL+2,-90h
	LWLW	SF1BA04,5|AFunc,A_SET_OYACCEL+1,3400h
	LW	SF1BA05,5
	LWL	SF1BA06,1|AFunc,A_STAY_TIL_GRND_HIT
	LWL	SF1BA07,4|AFunc,PSTOP
	LWL	SF1BA08,4|AFunc,DELAYED_PRAISE
	LW	SF1BA09,4
	LWL	SF1BA10,4|AFunc,PICK_A_DIRECTION
	LW	SF1BA11,4
	LW	SF1BA12,4
	LW	SF1BA13,4
	LW	SF1BA14,4
	LW	SF1BA15,4

	LW	TR13B01,5
	LW	TR13B02,5
	LWLL	TR13B03,5|AFunc,A_SET_OXVEL+2,10000h
	LW	TR13B04,5
	LWLL	TR13B05,4|AFunc,A_SET_OXVEL+2,20000h
	LWL	1,1|AFunc,A_Set_LOOP_STRT

	LW	RN3B02,5
	LW	RN3B03,5
	LW	RN3B04,5
	LW	RN3B05,5
	LW	RN3B06,5
	LW	RN3B07,5
	LW	RN3B08,5
	LWLL	RN3B01,5|AFunc,A_OFFSCREEN+2,KER_FREE_DONE
	.long	0

KER_FREE_DONE
	LW	1,30
	LWL	1,1|AFunc,A_KERRI_AWARD

**************************************************************************
*								         *
* KERRI CAGE VECTORS							 *
*								         *
**************************************************************************
KERCAGE_COLLVECT
	WWL	OID_PROCKET,~MASK_PLAYER,UNIV_ROCKET_COLL
	WWL	OID_PEXPLOSION,~MASK_PLAYER,KERCAGE_CVECT
	WL	0,DUMCRETS

KERCAGE_CVECT
	PUSH	a1
	CHKZLIM	015000H+010H,KCAGE_DONE

	CALLA	UNIV_COLL_CHECK
	JRNZ	KCAGE_DONE

	move	*a8(ODATA+70h),a14
	cmpi	0BADh,a14
	jreq	already_init1
	movi	[0BADh,0808h],a14
	move	a14,*a8(ODATA+60h),L
already_init1:

*
*	Where did rocket hit?
*
	move	*a0(OXVAL),a7,L	; target univ position
	move	*a0(OYVAL),a1,L
	movi	[-82,-45],a3
	movi	[-72,-33],a4
	calla	BOX_CHECK_OBJ2
	jrz	othr_side_chk
*
*	Hit Left Side
*
	movb	*a8(ODATA+60h),a3
	jrz	KCAGE_DONE
	PUSH	a0
	calla	UNIV_FLASH
	calla	MAKE_VIDCAM_SND
	movi	-39<<15,a14
	mmtm	sp,b0,b1,b2,b4,b5,b6,b8,b9
	callr	MAKE_BLAST
	mmfm	sp,b0,b1,b2,b4,b5,b6,b8,b9
	PULLQ	a0
	clr	a14		   ; we're gonna flip over all the cards
	movb	a14,*a8(ODATA+60h)
	jrnz	KCAGE_DONE
	movb	*a8(ODATA+68h),a3
	jrz	BCO_ROCKET
	PULLQ	a1
	rets

othr_side_chk:
	movi	[-82,34],a3
	movi	[-72,463],a4
	calla	BOX_CHECK_OBJ2
	jrz	KCAGE_DONE
*
*	Hit Right Side
*
	movb	*a8(ODATA+68h),a3
	jrz	KCAGE_DONE
	PUSH	a0
	calla	UNIV_FLASH
	calla	MAKE_VIDCAM_SND
	movi	39<<15,a14
	mmtm	sp,b0,b1,b2,b4,b5,b6,b8,b9
	callr	MAKE_BLAST
	mmfm	sp,b0,b1,b2,b4,b5,b6,b8,b9
	PULLQ	a0
	clr	a14		   ; we're gonna flip over all the cards
	movb	a14,*a8(ODATA+68h)
	jrnz	KCAGE_DONE
	movb	*a8(ODATA+60h),a3
	jrz	BCO_ROCKET
	PULLQ	a1
	rets


KERCAGE_GUNVECT
	PUSH	a1

	CHKZLIM	015000H+010H,KCAGE_DONE

	move	*a8(ODATA+70h),a14
	cmpi	0BADh,a14
	jreq	already_init2
	movi	[0BADh,0808h],a14
	move	a14,*a8(ODATA+60h),L
already_init2:

	movi	[-82,-45],a3
	movi	[-72,-33],a4
	calla	BOX_CHECK_OBJ
	jrz	chk_othr_side
*
*	Hit Left Side
*
	movb	*a8(ODATA+60h),a3
	jrz	KCAGE_DEFAULT_DING
	calla	UNIV_FLASH
;	calla	MAKE_VIDCAM_SND
	SOUNDZ	SND_LOCK_HIT
	calla	DGV_FRAG_SPARK	
	dec	a3
	movb	a3,*a8(ODATA+60h)
	jrnz	KCAGE_DONE
	movi	-39<<15,a14
	callr	MAKE_BLAST
	movb	*a8(ODATA+68h),a3
	jrz	BLAST_CAGE_OPEN
	PULLQ	a1
	rets

chk_othr_side:
	movi	[-82,34],a3
	movi	[-72,46],a4
	calla	BOX_CHECK_OBJ
	jrz	KCAGE_DEFAULT_DING
*
*	Hit Right Side
*
	movb	*a8(ODATA+68h),a3	; get left count
	jrz	KCAGE_DEFAULT_DING	; been opened already
	calla	UNIV_FLASH
;	calla	MAKE_VIDCAM_SND
	SOUNDZ	SND_LOCK_HIT
	calla	DGV_FRAG_SPARK	
	dec	a3
	movb	a3,*a8(ODATA+68h)
	jrnz	KCAGE_DONE
	movi	39<<15,a14
	callr	MAKE_BLAST
	movb	*a8(ODATA+60h),a3	; if newly opened, check other side
	jrz	BLAST_CAGE_OPEN

KCAGE_DONE:
	PULLQ	a1
	RETS
*
* Just make sound and spark here
*
KCAGE_DEFAULT_DING
	calla	MAKE_VIDCAM_SND
	calla	DGV_FRAG_SPARK	
	JRUC	KCAGE_DONE


SND_CAGE_BLAST
	.WORD	0F342h,88,0A390H,0
SND_CAGE_BOUNCE
	.word	0F310h,44,0A1E6h,0
SND_LOCK_HIT
	.WORD	0F141H,62,0A1A1H,0	;Hit the lock of the cage

BCO_ROCKET:
	MOVE	*A0(OID),A0,W			;GET PLAYER DATA ADDRESS
	CALLA	POID_TO_PDATA
BLAST_CAGE_OPEN:
	CLRM	*a8(ODATA+70h),W	; reset for future objects

	MOVIM	DUMCOLL,*A8(OCVECT),L
	MOVIM	METAL_GUNVECT,*A8(OGUNVECT),L

	.IF DEBUG
	CALLA	VALID_PLAYER
	.ENDIF
	.IF	AUSTRALIA

	.ELSE
	CALLA	PLAYER_AWARD_GIRL
	.ENDIF

	MOVE	A2,*A8(OGIRL_RESCUER),L	;Store here for the kiss
	CREATE	PID_IND,CAGE_LIFT_OFF
	PULLQ	a1
	rets


MAKE_BLAST:
	move	*a8(OXVAL),a3,L		; get position of explosions
	add	a14,a3
	move	*a8(OYVAL),a4,L
	subi	77<<15,a4
	move	*a8(OZVAL),a6,L
	subk	5,a6
	move	a6,a5
	move	@ZBASE,a14,L
	sub	a14,a5
	sra	Z2SCALE-1,a5	; quarter size
	move	a5,a9		; start scale exists in process at a9

	PUSH	a8
*
*	Start some explosion effect over locks
*
	movi	KCAGE_EXPLO_INIT,b0
	calla	MULTIMAKE

	calla	SET_SCALE_MANUAL

	CREATE	PID_IND,KEXP_ADJ_SCL
	move	a0,*a8(OPLINK),L

	move	a3,*a8(OXVAL),L
	move	a4,*a8(OYVAL),L
	move	a6,*a8(OZVAL),L
	move	*a8(OPARTS),a14,L
	move	a3,*a14(OXVAL),L
	move	a4,*a14(OYVAL),L
	move	a6,*a14(OZVAL),L

	calla	INSERT_OBJ

	SOUND1	SND_CAGE_BLAST

	PULLQ	a8
	rets


KEXP_ADJ_SCL:
	move	*a8(OZVAL),a5,L	; assume all parts have same scale
	move	@ZBASE,a14,L
	sub	a14,a5	      	; WORLD Z
	sra	Z2SCALE-1,a5   	; assume normal size image
;	move	a5,a7
;	srl	1,a7
;	add	a7,a5		; add back 1/8
	cmp	a5,a9
	jreq	scl_notnew
	move	a5,a9
	calla	SET_SCALE_MANUAL
scl_notnew:
	sloop	2,KEXP_ADJ_SCL

*
*      Start cage moving
*	
CAGE_LIFT_OFF:
	sleep	3

	CALLR	FREE_CAGE_KERRI

	MOVIM	-20h,*a8(OZVEL),L
	MOVIM	-40000h,*a8(OYVEL),L
	movi	-18000h,a1
	movi	-0c000h,a0
	calla	RANGRAND
	move	*a8(OXVAL),a3,L
	move	@XBASE,a14,L
	sub	a14,a3
	jrn	negxvel
	neg	a0
negxvel:
	move	a0,*a8(OXVEL),L
	MOVIM	3800h,*a8(OYACCEL),W

	movi	0c0000h,a9		; dest Y

	jruc	CLO_st
CLO_lp:
	move	*a8(OYVAL),a1,L
	cmp	a9,a1
	jrlt	CLO_st
	move	*a8(OYVEL),a2,L
	jrn	CLO_st			; on the way up, ignore
*
*	Hit ground, going down
*	
	SOUNDZ	SND_CAGE_BOUNCE
	sra	2,a2
	cmpi	800h,a2
	jrlt	stop_for_good
	neg	a2
	move	a2,*a8(OYVEL),L		; bounce

CLO_st:
	sloop	1,CLO_lp

stop_for_good:
	calla	PSTOP
	CLRM	*a8(OPLINK),L

	move	*a8(OULINK),a0,L
	move	*a8(OXVAL),*a0(MAP_X),L	; update position in link
	move	*a8(OYVAL),*a0(MAP_Y),L
	move	*a8(OZVAL),*a0(MAP_Z),L

	DIE

**************************************************************************
*								         *
* 		Kerri sitting in the brain machine			 *
*								         *
**************************************************************************
**************************************************************************
*								         *
* 	Universe anim func to create a Kerri tied to a chair		 *
* 	Direction is taken from H-flip of generator.			 *
* 	Position is offset from generator position.			 *
* 									 *
* 	AARG+,W	= X offset						 *
* 	AARG+,W	= Y offset						 *
*								         *
**************************************************************************
AU_CREATE_KERRI_FLOSS
	PUSH	A8
	MOVI	KERRI_FLOSS_INIT,B0	;Get us one
	CALLA	CREATE_ENEMY
	PULL	A2			;A2=obj block of creator, 
					;pull must preserve status.
	JRZ	ACKF_ABORT		;BR = Object not created.

	CALLA	CLR_ODATA

	CLRM	*A2(OPLAYER),L		;Make sure seat OPLAYER field is gone

	MOVE	A2,*A8(OKERRI_SEAT),L	;This is her seat ptr
	MOVE	*A8(OPARTS),A14,L
	MOVE	A2,*A14(OKERRI_SEAT),L	;Keep it in this guy also

	MOVE	*A2(OCTRL),A14
	BTST	B_FLIPH,A14
	JRZ	ACKF_NOFLIP

	MOVI	M_FLIPH,A0	
	CALLA	SET_FLPS

ACKF_NOFLIP
*
*	set position
*
	MOVE	A8,A9
	MOVE	A2,A8

	CALLA	GETAFARG_LONG		; pixel Y:X in a0
	MOVE	A0,A4

	MOVE	*A8(OZVAL),A3,L
	SUBK	8,A3			;Hold Z for set

	MOVE	*A8(OXVAL),A1,L
	MOVE	*A8(OYVAL),A2,L
	MOVE	A4,A5			; do X and Y
	SEXT	A5

	MOVE	*A8(OCTRL),A14
	BTST	B_FLIPH,A14
	JRZ	ACKF_NO_FLIPXOFF

	NEG	A5

ACKF_NO_FLIPXOFF
	SRA	16,A4
	SLL	15,A5
	SLL	15,A4
	ADD	A5,A1
	ADD	A4,A2

	MOVE	A9,A8

	MOVE	@YWORLD,A14,L
	MOVE	A2,A4
	SUB	A14,A4
	MOVE	A4,*A8(OGRNDOFF),L

	CALLA	SET_ANIPU

	CALLA	INSERT_OBJ		;Insert Kerri

ACKF_ABORT
	RETS


**************************************************************************
*								         *
* 	A_SEAT_CHECK							 *
* 									 *
* 	Anim func to check if the seat we are sitting in is		 *
* 	destroyed.							 *
* 									 *
* 	A8 = Ptr to Kerri part						 *
*								         *
**************************************************************************
A_SEAT_CHECK
	MOVE	*A8(OKERRI_SEAT),A0,L
	JRZ	ASC_X
	MOVE	*A0(OCTRL),A14,W
	JRNN	ASC_X			;BR = The seat is gone

	MOVE	*A0(OIMG),A14,L	
	CMPI	STATIC5bd,A14
	JRNE	ASC_X			;BR = The seat is still cool
	
	MOVE	*A0(OPLAYER),A2,L

	CALLA	PULL_ANIM		;Pull this part

	CALLA	GET_HEAD_PART

	MOVI	[-30,0],A9
	MOVI	8000,A1
	CALLA	PRINT_SCORE

	CALLA	PLAYER_AWARD_GIRL

	MOVI	ANIM_GET_UP,A1

	CALLA	STRT_ANIM

ASC_X
	RETS

KERRI_FLOSS_INIT
	.byte	 3, 0, 0, 1	;OBJCNT, PRCCNT, IMGPALCNT, PALCNT
	.long	KERTIE_P		;Discrete palette
	.word	OID_JUNK,OM_COLL
	.LONG	DUMCOLL
*        .long IMG
*        .word OCTRL, OFLAGS, OZOFF
*        .word OPTIONS 
	LWWWW	TOPHELP01, DMAWNZ, 0, 0, OM_GUNV|OM_ANIM
	.LONG	DUMRETS
	.LONG	ANIM_FLOSS_STRUGGLE
	LWWWW	BOTHELP01, DMAWNZ, 0, 1, OM_ANIM|OM_PRVGUNV
	.LONG	ANIM_WATCH_SEAT
	LWWWW	BOTHELP02, DMAWNZ, 0, 1, OM_PRVGUNV


ANIM_FLOSS_STRUGGLE
	LWL	1,1|AFunc,A_STAY_TIL_ONSCRN

FLOSS_ME
	LWLWW	1,1|AFunc,A_RAND_AnimSLP+2,15,100

	LW	1,0

	LW	TOPHELP02,4
	LW	TOPHELP03,4
	LW	TOPHELP04,4
	LW	TOPHELP05,4
	LW	TOPHELP06,4
	LW	TOPHELP07,4
	LWLL	TOPHELP01,4|AFunc,A_ONSCREEN+2,FLOSS_ME

;	LWL	1,1|AFunc,A_STAY_TIL_OFFSCRN

	LWL	1,1|AFunc,DELETE_OBJ


ANIM_WATCH_SEAT
	LWL	1,1|AFunc,A_SEAT_CHECK
	.LONG	0


ANIM_GET_UP
	LWLL	KERSFD01,1|AMulti|AFunc,A_CHANGE_PAL+2,KERTIE_P
	LWLL	KERSFD02,1|AMulti|AFunc,A_CHANGE_PAL+2,KERTIE_P
	LWLL	KERSFD03,6|AFunc,A_CHANGE_PAL+2,KERTIE_P

	LW	KERSFE01,1|AMulti
	LW	KERSFE02,1|AMulti
	LW	KERSFE03,6

	LW	KERSFI01,1|AMulti
	LW	KERSFI02,1|AMulti
	LW	KERSFI03,6

	LWLL	1,1|AMulti|AFunc,A_AnimGo+2,KERRI_RUNAWAY_ANIM
	LWL	1,1|AMulti|AFunc,OBJ_OFF
	LWL	1,1|AFunc,OBJ_OFF

	.END
