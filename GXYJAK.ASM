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
	.include	"gxyjak.tbl"
	.include	gxcontrl.h


	.def	AU_CREATE_YJAK, PROC_DESK_YJAK, CREATE_YJAK

	.ref	CREATE_ENEMY,INSERT_ENEMY,DELETE_ENEMY,SLINEVEL_LOAD_3D
	.ref	SET_GUNVECT,A_SET_GUNVECT,A_Set_LOOP_STRT,ZBASE,XBASE
	.ref	A_Unlink_Enemy,SET_ANIPU,EASYMAKE,SET_SCALE_MANUAL,YBASE
	.ref	XSCROLL,CK_PLAYER_HIT,ONESND,ONESND_Z,A_TAB_SOUNDZ
	.ref	A_Anim_DSJ,A_Set_AnimLoop,DELETE_OBJ_PROC,YSCROLL
	.ref	DEL_ENEMY_NOAUD,OBJ_UNIV_TO_SCRN, A_CHANGE_PAL, ZREL_OFF
	.REF	DESK_XFORM_FLAG, A_SOUND, A_Set_Var_Word, SetAnim, GUNS_OFF
	.REF	A_NOSCALE_NOSHAD, BASE_HIT, A_ONSCREEN

	.text


OWAITMIN	.set	ODATA+40h
OWAITMAX	.set	ODATA+50h

ODESK_FLAG	.EQU	ODATA+0F0H	;UHB Flag that says I trigger the desk

*
* Create the Yellow jacket behind the desk
*
PROC_DESK_YJAK:
	MOVI	YJAK_INIT,B0		;ALLOCATE OBJECT
	calla	CREATE_ENEMY
	JAZ	SUCIDE

	MOVIM	2,*a8(OWAITMIN),W	; times for random rest between 
	MOVIM	10,*a8(OWAITMAX),W	; firing

	MOVI	3870000H,A1
	MOVI	280000H,A2
	MOVI	3000H,A3
	MOVE	@ZREL_OFF,A14,L
	SRA	ZFRAC,A14
	ADD	A14,A3
	CALLA	SET_ANIPU

	MOVKB	1,*A8(ODESK_FLAG)

	MOVI	YJAK_DESK_INTRO,A1
	CALLA	STRT_ANIM

	CALLA	INSERT_ENEMY

	DIE

AU_CREATE_YJAK:
;	move	@OBJENEMIES,a14
;	btst	B_OF_YJAKH,a14
;	jrz	AU_CY_DONE

	move	*a8(OFLAGS),a14		; is generator off screen?
	btst	B_OFSCRN,a14
	JRNZ	AU_CY_DONE		; yes, don't make the guy

	move	*a8(UEGenObj),a14,L	; is there a guy here already?
	jrnz	AU_CY_DONE		; yes, don't make another
	move	a8,a9

	MOVI	YJAK_INIT,B0		;ALLOCATE OBJECT
	calla	CREATE_ENEMY
	jrz	AU_CY_DONE

	MOVIM	40,*a8(OWAITMIN),W	; times for random rest between 
	MOVIM	80,*a8(OWAITMAX),W	; firing

	move	a9,*a8(OGenObj),L	; save generating object
	move	a8,*a9(UEGenObj),L     

	MOVE	*A9(OXVAL),A1,L
	addi	44<<15,a1		 	; add offset in X
	MOVE	*A9(OYVAL),A2,L
	addi	140<<15,a2		 	; add offset in Y
	MOVE	*A9(OZVAL),A3,L
	addi	20h,a3
	CALLA	SET_ANIPU

	CLRB	*A8(ODESK_FLAG)

	jauc	INSERT_ENEMY		;INSERT AND COUNT ENEMY

AU_CY_DONE
	RETS
	

*
*	CREATE_YJAK	(for desert wave)
*	a4 = XVAL
*	a2 = YVAL
*	a3 = ZVAL
*
CREATE_YJAK:
	MOVI	YJAK_INIT,B0		;ALLOCATE OBJECT
	calla	CREATE_ENEMY
	jrz	AU_CY_DONE

	MOVIM	40,*a8(OWAITMIN),W	; times for random rest between 
	MOVIM	80,*a8(OWAITMAX),W	; firing

	CLRM	*a8(OGenObj),L		; no generating object

	move	a4,a1
	CALLA	SET_ANIPU

	CLRB	*A8(ODESK_FLAG)

	movi	YJAK_OFF_ANIM,a14
	move	a14,*a8(AnimFrm),L
	move	a14,*a8(AnimScr),L

	jauc	INSERT_ENEMY		;INSERT AND COUNT ENEMY


YJAK_OFF_ANIM
	LWLL	1,10|AFunc,A_ONSCREEN+2,YJAK_IDLE_ANIM
	.long	0




A_WAIT_FOR_FIRE_TIME:
	move	*a8(OWAITMIN),a1
	move	*a8(OWAITMAX),a0
	calla	RANGRAND
	movb	a0,*a8(AnimSLP)
	rets

A_CK_DESK_GUY
	MOVB	*A8(ODESK_FLAG),A14
	JRZ	ACDG_X
	MOVI	YJAK_DESK_POUND,A1
	JAUC	SetAnim
ACDG_X
	RETS

YJAK_INIT:
	.byte	4,0,0,1
	.long	P_GXYJ
	.word	OID_YELJAK,OM_COLL
	.long	YJAK_CVECT
	LWWWW	YL1ST_A1,DMAWNZ,0,0,OM_GUNV|OM_ANIM
	.long	YJAK_GUNVECT
	.long	YJAK_IDLE_ANIM
	LWWWW	YT1ST_A1,DMAWNZ,0,0,OM_PRVGUNV
	LWWWW	YH1ST_A1_a,DMAWNZ,0,0,OM_PRVGUNV
	LWWWW	YH1ST_A1_a,DMAWNZ,M_NODISP,0,OM_PRVGUNV




YJAK_CVECT
	WWL	OID_PROCKET,~MASK_PLAYER,YJAK_ROCKET_COLL
	WWL	OID_PEXPLOSION,~MASK_PLAYER,YJAK_EXPLOSION_COLL
	WWL	OID_BLOWUP,0FFFFH,YJAK_SBOMB_COLL
	WL	0,DUMCRETS

**************************************************************************
*								         *
* same as NONBOY_ROCKET_COLL - Collision vector for Player rocket bomb.	 *
* A0 = Ptr to rocket object						 *
* A8 = Ptr to YELJAK object						 *
*								         *
**************************************************************************
YJAK_ROCKET_COLL
	MOVE	*A0(RL_INTENDED_OBJ),A14,L
	CMP	A14,A8			;Is this the object we are after?
	JRNE	NRC_X			;BR = No

	CALLA	GET_HEAD_PART
	ORIM	M_ATEROCKET,*A8(OEFLAGS),W	;Flag the rocket touch
NRC_X
	RETS



**************************************************************************
*								         *
* 	YJAK_SBOMB_COLL							 *
* 									 *
* 	Smart bomb service for Yellow Jacket				 *
* 									 *
* 	A2 = Ptr to player that smart bombed				 *
* 	A8 = Ptr to YelJak						 *
*								         *
**************************************************************************
YJAK_SBOMB_COLL
	CALLA	GET_HEAD_PART
	ORIM	M_ATEROCKET,*A8(OEFLAGS),W	;This will make him die
	JRUC	YJAK_GEN_COLL

**************************************************************************
*								         *
* YJAK_EXPLOSION_COLL - Collision vector for Player explosion.		 *
* A0 = Ptr to explosion object						 *
* A8 = Ptr to YELLOW JACKET object						 *
*								         *
**************************************************************************
YJAK_EXPLOSION_COLL:
	MOVE	*A0(OID),A0,W		;GET PLAYER DATA ADDRESS
	CALLA	POID_TO_PDATA		;GET PDATA IN A2

	CALLA	GET_HEAD_PART

*
* Entrypoint for all explosion stuff
*	A8 = Ptr to YELJAK head part
*
YJAK_GEN_COLL
	MOVE	*A8(OEFLAGS),A14,W
	BTST	B_ATEROCKET,A14
	JRZ	NRC_X
YJ_BLOWBACK:
	PUSH	A8
YJ_COFFLP
	clr	a14
	move	a14,*a8(OCVECT),L
	move	a14,*a8(OGUNVECT),L
	move	*A8(OPARTS),A8,L
	jrnz	YJ_COFFLP
	PULLQ	A8

	MOVE	A2,*A8(OPLAYER),L	;Hang on to this address

	MOVI	2000,A1
	CALLA	SCORE			;Killing guys is always good for points

	CALLA	COUNT_PLAYER_KILL

	RANDENT	SND_YJAKDIE,2,5,L
	CALLA	ONESND_Z			;Give us a grunt

	MOVKB	1,*a8(AnimSlp)		; do it now
	MOVI	YJAK_DEATH_ANIM,A1   
	move	a1,*a8(AnimScr),L
	move	a1,*a8(AnimFrm),L
	rets

YJAK_DEATH_ANIM:
	LWLL	YL1DIEX_A1,1|AMulti|AFunc,A_CHANGE_PAL+2,P_YELJK
	LWLL	YT1DIEX_A1,1|AMulti|AFunc,A_CHANGE_PAL+2,P_YELJK
	LWLL	YA1DIEX_A1,1|AMulti|AFunc,A_CHANGE_PAL+2,P_YELJK
	LWL	1,3|AFunc,OBJ_OFF

	LW	YL1DIEX_A2,1|AMulti
	LW	YT1DIEX_A2,1|AMulti
	LW	YA1DIEX_A2,3

	LW	YL1DIEX_A3,1|AMulti
	LW	YT1DIEX_A3,1|AMulti
	LW	YA1DIEX_A2,3

	LW	YL1DIEX_A4,1|AMulti
	LW	YT1DIEX_A4,1|AMulti
	LW	YA1DIEX_A4,3

	LWL	YL1DIEX_A5,1|AMulti|AFunc,A_CK_DESK_GUY
	LW	YT1DIEX_A5,1|AMulti
	LW	YA1DIEX_A5,3

	LW	YL1DIEX_A6,1|AMulti
	LW	YT1DIEX_A6,1|AMulti
	LWL	1,3|AFunc,OBJ_OFF

	LW	YL1DIEX_A7,1|AMulti
	LW	YT1DIEX_A7,1|AMulti
	LWL	YA1DIEX_A7,3|AFunc,OBJ_ON

	LW	YB1DIEX_A8,1|AMulti
	LWL	1,1|AMulti|AFunc,OBJ_OFF
	LWL	1,3|AFunc,OBJ_OFF

	LWL	YB1DIEX_A9,30|AFunc,A_Unlink_Enemy

	LWL	1,1|AFunc,DELETE_ENEMY

*
* Do the office intro
*
YJAK_DESK_INTRO
	LWL	1,100|AFunc,COLLS_OFF
	LW	1,60
	LWLL	1,1|AFunc,A_SOUND+2,SND_YOUVE
	LW	1,100
	LW	1,100
	LW	1,85
	LWLLW	1,1|AFunc,A_Set_Var_Word+3,GUNS_OFF,0
	LWLL	1,1|AFunc,A_AnimGo+2,YJAK_IDLE_ANIM

*
* Do the desk proud
*
YJAK_DESK_POUND
	LWL	1,1|AMulti|AFunc,OBJ_OFF
	LWL	1,1|AMulti|AFunc,OBJ_OFF
	LWL	1,20|AFunc,OBJ_OFF

	LWL	YJRISE1,1|AFunc,A_NOSCALE_NOSHAD

	LWL	1,3|AFunc,OBJ_ON

	LW	YJRISE2,4
	LW	YJRISE3,4
	LW	YJRISE4,4

	LWLLW	1,1|AFunc,A_Set_Var_Word+3,GUNS_OFF,1

	LW	YJSLAP2,4
	LW	YJSLAP3,4
	LW	YJSLAP4,4
	LW	YJSLAP5,4
	LWLL	YJSLAP6,6|AFunc,A_SOUND+2,SND_DESK_POUND

	LWLLW	1,1|AFunc,A_Set_Var_Word+3,DESK_XFORM_FLAG,1

	LW	YJRISE3,6
	LW	YJRISE2,6
	LW	YJRISE1,6

	LWL	1,1|AFunc,DELETE_ENEMY

**************************************************************************
*								         *
* 	YJAK_GUNVECT							 *
* 									 *
* 	A2 = Ptr to player that hit him					 *
* 	A8 = Ptr to YelJak						 *
*								         *
**************************************************************************
YJAK_GUNVECT:
	calla	GET_HEAD_PART
	movi	YJAK_FLINCH_ANIM,a1
	move	a1,*a8(AnimScr),L
	move	a1,*a8(AnimFrm),L
	MOVKB	1,*a8(AnimSlp)		; do it now

	move	*a8(OHITS),a0
	inc	a0
	move	a0,*a8(OHITS)
	cmpk	15,a0
	jrge	YJ_BLOWBACK

	movi	YJAK_HIT_GUNVECT,a0	; don't flinch, but count hit.
	calla	SET_GUNVECT	; turn off collisions during part of flinch
	rets	


YJAK_HIT_GUNVECT:
	calla	GET_HEAD_PART	; while flinching, just count hits
	move	*a8(OHITS),a0
	inc	a0
	move	a0,*a8(OHITS)
	cmpk	8,a0
	jrge	YJ_BLOWBACK	; kill him if it's time.
	rets


YJAK_FLINCH_ANIM:
	LWLLW	YL1STH_A1,1|AMulti|AFunc,A_TAB_SOUNDZ+3,SND_YJAKHIT,2
	LW	YT1STH_A1,1|AMulti
	LWL	YH1STH_A1,3|AFunc,OBJ_ON   ; may be off when this starts

	LW	YL1STH_A2,1|AMulti
	LW	YT1STH_A2,1|AMulti
	LW	YH1STH_A2,1|AMulti
	LWL	YA1STH_A2,3|AFunc,OBJ_ON

	LW	YL1STH_A3,1|AMulti
	LW	YT1STH_A3,1|AMulti
	LW	YH1STH_A3,1|AMulti
	LWL	1,3|AFunc,OBJ_OFF

	LWLL	YL1STH_A4,1|AMulti|AFunc,A_SET_GUNVECT+2,YJAK_GUNVECT
	LW	YT1STH_A4,1|AMulti
	LW	YH1STH_A4,3

	LW	YL1STH_A4,1|AMulti
	LW	YT1STH_A5,1|AMulti
	LW	YH1STH_A5,3

	LW	YL1ST_A1,1|AMulti
	LW	YT1ST_A1,1|AMulti
	LW	YH1ST_A1_a,3
	
	LWL	1,1|AFunc,A_Set_LOOP_STRT  ; FALL THROUGH TO IDLE and loop

YJAK_IDLE_ANIM:
	LWL	1,1|AFunc,A_WAIT_FOR_FIRE_TIME
	LW	1,0

	LW	YL1SH_A1,1|AMulti
	LW	YT1SH_A1,1|AMulti
	LW	YH1SH_A1,4

	LW	YL1SH_A1,1|AMulti
	LW	YA1SH_A2,1|AMulti
	LW	YT1SH_A2,1|AMulti
	LWL	YH1SH_A2,4|AFunc,OBJ_ON

	LW	YT1SH_A3,1|AMulti
	LW	YL1SH_A3,1|AMulti
	LW	YH1SH_A3,1|AMulti
	LWL	1,4|AFunc,OBJ_OFF

	LW	YT1SH_A4,1|AMulti
	LW	YL1SH_A4,1|AMulti
	LW	YH1SH_A4,4

	LWL	YT1SH_A5,1|AMulti|AFunc,FIRE_ZAP
	LW	YL1SH_A5,1|AMulti
	LWL	1,20|AFunc,OBJ_OFF

	LW	YT1SH_A1,1|AMulti
	LW	YL1SH_A1,1|AMulti
	LWL	YH1SH_A1,4|AFunc,OBJ_ON

	LW	YL1ST_A1,1|AMulti
	LW	YT1ST_A1,1|AMulti
	LW	YH1ST_A1_a,3

	.long	0


FIRE_ZAP:
	calla	SCRTST
	jrnz	me_go_way
	movi	RING_INIT,b0
	calla	EASYMAKE
	jrz	noring
	move	*a8(OXVAL),*a0(OXVAL),L
	move	*a8(OYVAL),a14,L
	subi	95<<15,a14
	move	a14,*a0(OYVAL),L
	move	*a8(OZVAL),a5,L
	subk	3,a5
	move	a5,*a0(OZVAL),L
	calla	INSOBJ
	move	@ZBASE,a3,L
	sub	a3,a5			; world Z in a5
	sra	Z2SCALE-1,a5  
	move	a8,a11
	move	a0,a8
	calla	SET_SCALE_MANUAL

noring:
	movi	ZAP_INIT,b0
	calla	EASYMAKE
	jrz	nozap

	move	*a11(OXVAL),a2,L
	move	a2,*a0(OXVAL),L
	move	*a11(OYVAL),a4,L
	subi	95<<15,a4
	move	a4,*a0(OYVAL),L
	move	*a11(OZVAL),a6,L
	subk	3,a6
	move	a6,*a0(OZVAL),L

	calla	INSOBJ
	move	a0,a8

	move	a6,a9
	move	@ZBASE,a5,L
	sub	a5,a9			; world Z in a9
	addi	ZMAX_REAL,a5		; dest Z
	move	@YBASE,a3,L
	neg	a3
	move	@XBASE,a0,L
	move	a0,a1
	addi	180*ZMAX_REAL,a0
	subi	180*ZMAX_REAL,a1
	calla	RANGRAND
	move	a0,a1			; dest X
	movi	70,a7
	calla	SLINEVEL_LOAD_3D

	move	*a8(OXVEL),a14,L	; compensate for scroll
	move	@XSCROLL,a1,L
	add	a1,a14
	move	a14,*a8(OXVEL),L

	move	*a8(OYVEL),a14,L	; compensate for scroll
	move	@YSCROLL,a1,L
	sub	a1,a14
	move	a14,*a8(OYVEL),L

	move	a9,a10
	sra	Z2SCALE-1,a10		; start scale
	move	a10,a5

	calla	SET_SCALE_MANUAL

	CREATE	PID_IND,MON_ZAP
	move	a0,*a8(OPLINK),L

	SOUNDZ	SND_MAKE_ZAP
nozap:
	rets


me_go_way:
	calla	A_Unlink_Enemy
	jauc	DEL_ENEMY_NOAUD


RING_INIT:
	.LONG	NRGRING1
	.word	DMAWNZ,M_MANSCALE,OM_ANIM
	.long	RINGANIM


RINGANIM:
	LW	NRGRING1,3
	LW	NRGRING3,3
	LW	NRGRING5,3
	LW	NRGRING7,3
	LWL	1,1|AFunc,DELETE_OBJ



ZAP_INIT:
	.LONG	PHOTON1
	.word	DMAWNZ,M_MANSCALE,OM_ANIM|OM_GUNV
	.long	ZAP_GUNVECT
	.long	PHOTONANIM



ZAP_GUNVECT
	CALLA	COLLS_OFF
	MOVIM	-8,*A8(OYVEL+16),L
	MOVIM	800H,*A8(OZVEL),L
	SOUNDZ	SND_ZAP_ZAPPED
	MOVI	250,A1
	CALLA	SCORE			;Score points for neutralizing
	MOVI	ZAP_FLYAWAY,A1
	move	a1,*a8(AnimFrm),L
	rets


PHOTONANIM
	LW	PHOTON1,3
	LW	PHOTON2,3
	LW	PHOTON3,3
	.long	0

ZAP_FLYAWAY:
	LWLW	1,1|AFunc,A_Set_AnimLoop+1,4
ZF_LOOP
	LW	PHOTON1,3
	LW	PHOTON2,3
	LWLL	PHOTON3,3|AFunc,A_Anim_DSJ+2,ZF_LOOP
	LWL	1,1|AFunc,DELETE_OBJ_PROC

ZAP_FLASH_ANIM:
	LWL	1,1|AFunc,OBJ_UNIV_TO_SCRN
	LWLW	1,1|AFunc,A_Set_AnimLoop+1,4
ZF_LP
	LWL	PHOTON1,2|AFunc,OBJ_ON
	LWL	1,2|AFunc,OBJ_OFF
	LWL	PHOTON2,2|AFunc,OBJ_ON
	LWL	1,2|AFunc,OBJ_OFF
	LWL	PHOTON3,2|AFunc,OBJ_ON
	LWL	1,1|AFunc,OBJ_OFF
	LWLL	1,1|AFunc,A_Anim_DSJ+2,ZF_LP
	LWL	1,1|AFunc,DELETE_OBJ_PROC


*
*	a8 = obj 
*	a9 = world Z to start
*	a10 = start scale
*
MON_ZAP:
	movi	50h,a11		; S2 (Target) in a11
	move	a10,a1		; S1 (Start scale) in a1
	sub	a11,a1	  	; S1 - S2 in a1
	neg	a1		; S2 - S1
	subi	ZMAX_REAL,a9	; Z1- Z2 in a9
	neg	a9		; Z2 - Z1 in a9

	sll	16,a1
	divs	a9,a1		; slope in a1
	move	a1,a9
*
*	SCALE = Targ Scale + (ZCUR - TargZ) * SLOPE
*
ADJ_ZSCL_lp:
	move	*a8(OZVAL),a5,L
	move	@ZBASE,a14,L
	sub	a14,a5			; Zcur in a5
	subi	ZMAX_REAL,a5		; Zcur - Ztarg
	jrle	hitplyr
	mpys	a9,a5			;  * slope
	sra	16,a5
	add	a11,a5
	calla	SET_SCALE_MANUAL
	sloop	1,ADJ_ZSCL_lp

hitplyr:
	calla	PSTOP
	calla	COLLS_OFF

	clr	a3

;	movi	[8,0],a5
	MOVE	@BASE_HIT,A5,W
	ADDI	6800H,A5
	SLL	4,A5

	calla	CK_PLAYER_HIT

	SOUND1	SND_ZAP_HIT

	CLRM	*a8(OPLINK),L
	movi	ZAP_FLASH_ANIM,a1
	move	a1,*a8(AnimFrm),L
	DIE


SND_ZAP_HIT
	.word	0f360h,23,0a325h,0

SND_ZAP_ZAPPED
	.word	0e348h,19,0a322h,0

SND_DESK_POUND
	.WORD	0E340H,16,0A3A1H,0	;Manager pounds desk
SND_YOUVE
	.WORD	0E342H,157,084C3H,128,084C5h,0	;"You've destroyed New Order

SND_YJAKHIT	.long	SND_YJAK_HIT1,SND_YJAK_HIT2

SND_YJAK_HIT1	.word	0e346h,23,0a46eh,0
SND_YJAK_HIT2	.word	0e346h,20,0a471h,0

SND_YJAKDIE	.long	SND_YJAK_DIE1,SND_YJAK_DIE2

SND_YJAK_DIE1	.word	0f34eh,46,0a474h,0
SND_YJAK_DIE2	.word	0f34eh,41,0a477h,0
	
SND_MAKE_ZAP	.word	0f348h,21,0a31ch,116,0a4aah,0

	.END




