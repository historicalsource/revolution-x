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
	.include	"univtbl.glo"
	.include	"gxbeek1.tbl"
	.include	"gxnatv.h"

	.text

**
**	in place of .include gxglo.h...
**
	.ref	SCRL_DISPATCHER,EASYMAKE,SET_SCALE_WARREN,BOX_CHECK_OBJ
	.ref	XBASE,A_SOUNDZ,YWORLD,A_INIT_AnimSLP,A_PART_FIRE_FNC
	.ref	A_TAB_SOUNDZ,ZREL_OFF,FRG_BOX_8,ATTACH_CD
	.ref	A_CHANGE_PAL,A_STAY_TIL_ONSCRN,GLAS_GRND_COLL,IN_SECRET
	.ref	REVEAL_SBOMB,REVEAL_CD,ATTACH_PROCK,SET_ODAG,SCROLLKILL
	.ref	MAX_ALLOWED,NUM_OUT_THERE,OBJENEMIES,A_TOGGLE_OCTRL,ZBASE
	.ref	INSERT_ENEMY,DELETE_ENEMY,A_SOUNDZ_ONSCREEN, DEL_ENEMY_NOAUD
	.ref	A_STAY_TIL_YVEL_POS,A_STAY_TIL_GRND_HIT,ZSCROLL,SET_ANIPU
	.ref	A_SET_OYACCEL
	.REF	SCAN_FOR_DROPPERS,DO_SCHMOOTZ
**
**	end of globals from gxglo.h
**

	.DEF	S_CREATE_BEEKS,SET_GUNVECT,A_SET_GUNVECT
	.DEF	DROP_A_MASK_GUY,MORF_JUMP_OUT,MORF_JUMP_INIT
	.DEF	A_CHK_FIRE_FNC,CLR_BEEK_ODATA

	.ref	N_CHUNK		; from gxnonboy
	.ref	A_Set_LOOP_STRT	; from gxafunc

**** from GXD.ASM
	.REF	GET_SHAD_MULTI
**** from GXSND.ASM
	.REF	ONESND

**** from GXBLOOD.ASM
	.REF	GOOEY_BULLET_HIT, FRAG_GOOEY_SPLORCH
**** from GXAFUNC.ASM
	.REF	PreFrag_Offset
***** from GXRAM.ASM
	.REF	VIOLENCE_LEVEL

	.bss	DROP_STATE,16
	.bss	filler,16

MID_PLANT	.set	300h		; approx X of center hallway 


***************************************
*       BEEKEEPER ID's                *
***************************************
BID_ROPE1	.set	0
BID_WALK3	.set	1
BID_STND3	.set	2
BID_BUTN3	.set	3
BID_STND5	.set	4
BID_BUTN5	.set	5
BID_BOX3	.set	6
BID_MASK	.set	7	; meanie

*
*	These tables are based on BIDs
*

*
*	Normal animation
*
NORM_BANIM_TBL	
	.long	B3_WALK_ANIM,B3_WALK_ANIM,B3_STND_ANIM
	.long	B3_BUTN_ANIM,B5_STND_ANIM,B5_BUTN_ANIM
	.long	B3_BOX_ANIM

*
*	Transition to shooting
*
SHOOT_TRANS_TBL
	.long	BSHT_X1,BSHT_X3A,BSHT_X3A,BSHT_X3,BSHT_X5A,BSHT_X5
	.long	BSHT_X3

*
*	Transition from shooting to normal
*
BACK_TRANS_TBL
	.long	BSHT_XB1,BSHT_XB3,BSHT_XB3,BSHT_XB3,BSHT_XB5,BSHT_XB5
	.long	BSHT_XB3

BTRNPRC	.set	ODATA+060h	; turn monitor process (0 if none)
BHITS	.set	ODATA+080h
BID	.set	ODATA+090h	; which kind of beekeeper are we?
BTIME	.set	ODATA+090h	; FOR CLOBOX: timer 
BHISS	.set	ODATA+0a0h
BSVXVEL .set	ODATA+0c0h	; save motion when shooting
BTRANS	.set	ODATA+0e0H	; animation to get back to normal
				; this is a timer
OBOXLINK .set	ODATA+100H	; link between beek and box
BTURN	 .set	ODATA+120H	; for beeks: animation to turn for back/forth guys
BOX_ROUT .set	ODATA+120H	; for boxes: monitor routine
ANNOYED	.set	ODATA+140h	; if he's pissed, he's shooting



WHICH_BEEK_POS
	.word	4e0h,618h	; DROPPER Xmin, Xmax
	.long	-14000h,-7000h	; DROPPER Zmin, ZMAX
	.long	-13dd4h		; BOXERS start Z
	.long	[7a1h,-1200h]	; BOXERS start X : Xvel
	.long	[6dch,7ach]	; BOXERS limits
	.long	M_FLIPH		; state at which to drop box
	.long	BEEK_POS_TBL_OR	; outside chamber right


	.word	0h,200h		; DROPPER Xmin, Xmax
	.long	-14000h,-7000h	; DROPPER Zmin, ZMAX
	.long	-13fd0h		; BOXERS start Z
	.long	[-6dh,1200h]	; BOXERS start X : Xvel
	.long	[-70h,48h]	; limits
	.long	0		; state at which to drop box
	.long	BEEK_POS_TBL_OL	; outside chamber left


S_CREATE_BEEKS:
	CLRM	@NUM_OUT_THERE,W	; no boxers out there

	move	*a11+,a10	; index to get to POSITION TABLE
	sll	8,a10		; (valid values are 0,1,and 2, and 3)
	addi	WHICH_BEEK_POS,a10
	move	*a10+,a5	; X min
	move	*a10+,a6	; X max
	move	*a10+,a9,L	; Z min	(relative to inner3)
	move	*a10+,a8,L	; Z max (relative to inner3)
	calla	SCAN_FOR_DROPPERS	; do droppers

	move	*a10+,a8,L		; start Z
	move	*a10+,a9,L		; start X : Xvel
	move	*a10+,a7,L
	PUSH	a10
	move	a7,a10		  
	CREATE	PID_BEEKPR,GEN_BOXERS

	PULLQ	a14

	move	*a14+,a6,L		; get drop state from table
	move	a6,@DROP_STATE
	move	*a14,a6,L
	move	@YWORLD,a7,L
	move	*a6+,a14,L
	move	a14,b0
CREBEEKlp:
	calla	CREATE_BEEKS	; loop through table

	move	*a6+,a14,L
	move	a14,b0
	jrnz	CREBEEKlp

	jauc	SCRL_DISPATCHER


*	a8 = start Z
*	a9 = start X : Xvel shifted rt 4 bits
*	a10 = [left lim, right lim]
GEN_BOXERS:
	move	@ZREL_OFF,a3,L
	sra	ZFRAC,a3
	add	a3,a8		; start  Z in a11
	move	a9,a11
	sext	a11
	sll	4,a11		; XVEL in a6
	clr	a14
	movx	a14,a9		; X pos in a9
	move	a8,*-a12,L
*
*	a5 = number of boxers to create
*	a8 = object 
*	a9 = start X
*	a10 = left lim, right lim
*	a11 = start X VEL
*
GEN_BOXER_lp:		      
	move	@NUM_OUT_THERE,a14
	move	@MAX_ALLOWED,a0
	cmp	a14,a0
	jrle	GENBOXR_X		; there's enough of em now

	move	@OBJENEMIES,a14	 
	btst	B_OF_BOXERS,a14
	jrnz	GENBOX_NRML
*
*	BOXERS ARE DISABLED, GENERATE BOX ONLY
*
	callr	GEN_BOX_ONLY
	jruc	GENBOXR_X

GENBOX_NRML:		       
	movi	B3_BOX_INIT,b0
	calla	MULTIMAKE
	jrz	GENBOXR_X

	move	@NUM_OUT_THERE,a14
	inc	a14
	move	a14,@NUM_OUT_THERE

	callr	CLR_BEEK_ODATA

	clr	a4
	move	a11,a11
	jrnn	noflips
	movi	M_FLIPH,a14
noflips:
	move	a11,*a8(OXVEL),L
	move	@YWORLD,a1,L
	move	a8,a0
GFlpLp:
	move	*A0(OCTRL),A4
	or	A14,A4
	move	a4,*A0(OCTRL)
	move	a9,*a0(OXVAL),L
	move	a1,*a0(OYVAL),L
	move	*A0(OPARTS),A0,L
	jrnz	GFlpLp

	move	*a12,a1,L	; get start Z
	movk	12,a0
	calla	RAND0
	subk	8,a0
	sll	2,a0
	add	a0,a1		; randomly selected Z
	calla	STORE_ZVAL

; 	CALLA	GET_SHAD_MULTI		;Setup his shadow

	calla	INSERT_ENEMY

	CREATE	PID_IND,MON_BEEK_LIMSA
	move	a0,*a8(BTRNPRC),L
	MOVIM	B3_BOX_TURN_ANIM,*a8(BTURN),L
	callr	B_GEN_BOX_1	; put a box in his arms
GENBOXR_X:     
	sloop	120,GEN_BOXER_lp

*
*	a14 contains the INIT table, a6 points to position table
*
CREATE_A_BEEK:
	move	@YWORLD,a7,L
CREATE_BEEKS:
	calla	MULTIMAKE
	jrz	cant_beek

	callr	CLR_BEEK_ODATA

	move	*a6+,a3,L	; X:flip
	move	*a6+,a1,L	; Z relative to local universe
	move	@ZREL_OFF,a14,L
	sra	ZFRAC,a14	; convert to lo-res
	add	a14,a1		; get universe Z
*
*	Check flags
*
	clr	a5		; flip bit in a5
	btst	0,a3
	jrz 	nohflp
	movi	M_FLIPH,a5
nohflp:
	btst	1,a3
	jrz	nohvel
	move	*a6+,a14,L	; set a velocity
	move	a14,*a8(OXVEL),L
nohvel:
	btst	2,a3
	jrz	nolims
	move	*a6+,a9,W	; left lim
	move	*a6+,a10,W	; right lim
	PUSH	a1
	CREATE	PID_BEEKPR,MON_BEEK_LIMS
	move	a0,*a8(BTRNPRC),L
	move	*a6+,a1,L	; turning animation
	move	a1,*a8(BTURN),L
	PULLQ	a1
	move	@YWORLD,a7,L	; reset, since it has been trashed by CREATE
nolims:
	move	a8,a0
pblp:
	move	a3,*a0(OXVAL),L
	move	a7,*a0(OYVAL),L
	move	*a0(OCTRL),a2
	or	a5,a2			; set flip if need be
	move	a2,*a0(OCTRL)
	move	*a0(OPARTS),a0,L
	jrnz	pblp

	calla	STORE_ZVAL

; 	CALLA	GET_SHAD_MULTI		;Setup his shadow

	calla	INSERT_OBJ

cant_beek:
	rets

*	.long	INIT_TABLE for MULTIMAKE
*	WWL	flags,UX,UZ (Relative to current universe)
*	
*	Flags...   bit 0 =1  means HFLIP
*                  bit 1 =1  means give it an H VEL
*                  bit 2 =1  means give it back/forth limits and turning anim
*
BEEK_POS_TBL_OR:		; outside right
	.long	B5_BUTN_INIT
     	WWL	0,708h,-0a583h		; B5_BUTN
	.long	B5_BUTN_INIT
     	WWL	0,627h,-0a4e6h		; B5_BUTN
	.long	B5_BUTN_INIT
     	WWL	0,650h,-0a4e6h		; B5_BUTN
	.long	B5_BUTN_INIT
     	WWL	0,46dh,-13200h		; B5_BUTN
	.long	B5_BUTN_INIT
     	WWL	0,423h,-13200h		; B5_BUTN

	.long	B3_WALK_INIT
     	WWL	6,540h,-06a00h		; B3_WALK
	.long	12000h			; xvel
	.word	47bh,741h		; limits
	.long	0			; turn animation

	.long	B3_WALK_INIT
     	WWL	7,498h,-06800h		; B3_WALK
	.long	-12000h			; xvel
	.word	47bh,741h		; limits
	.long	0			; turn animation

	.long	B3_WALK_INIT
     	WWL	7,700h,-0dc00h		; B3_WALK
	.long	-12000h			; xvel
	.word	5d4h,741h		; limits
	.long	0			; turn animation

	.long	B3_WALK_INIT
     	WWL	6,448h,-010400h		; B3_WALK
	.long	12000h			; xvel
	.word	448h,561h		; limits
	.long	0			; turn animation

	.long	B5_STND_INIT
     	WWL	0,446h,-14003h		; B5_STAND

	.long	B3_WALK_INIT
     	WWL	6,4b8h,-08a00h		; B3_WALK
	.long	12000h			; xvel
	.word	478h,4f8h		; limits
	.long	0			; turn animation

	.long	B3_STND_INIT
     	WWL	0,56dh,-08800h		; B3_STAND

	.long	B3_STND_INIT
     	WWL	1,569h,-13ddch		; B3_STAND

	.long	0		; terminate


BEEK_POS_TBL_OL:		; outside left
	.long	B3_WALK_INIT
     	WWL	6,270h,-7000h		; B3_WALK
	.long	12000h			; xvel
	.word	-0bh,1d5h		; limits
	.long	0			; turn animation

	.long	B3_WALK_INIT
     	WWL	7,270h,-8200h		; B3_WALK
	.long	-12000h			; xvel
	.word	0a9h,1cdh		; limits
	.long	0			; turn animation

	.long	B3_STND_INIT
     	WWL	1,0ach,-0a000h		; B3_STAND

	.long	B3_STND_INIT
     	WWL	0,1c2h,-0a000h		; B3_STAND


	.long	B5_BUTN_INIT
     	WWL	0,1a6h,-13190h		; B5_BUTN
	.long	B5_BUTN_INIT
     	WWL	0,1e8h,-13190h		; B5_BUTN
	.long	B5_STND_INIT
     	WWL	0,1cch,-13363h		; B5_STAND

	.long	B5_BUTN_INIT
     	WWL	0,0h,-0c599h		; B5_BUTN
	.long	B5_BUTN_INIT
     	WWL	0,29h,-0c599h		; B5_BUTN

	.long	0		; terminate


C_SET_BID:
	move	*b0+,b14
	move	b14,a14
	move	a14,*a8(BID)
	rets

*
*	HEAD in a8
*
CLR_BEEK_ODATA:
	clr	a14
	move	a14,*a8(BHISS),L
	move	a14,*a8(BHITS)
	move	a14,*a8(OBOXLINK),L
	move	a14,*a8(BTRNPRC),L
	move	a14,*a8(BTURN),L
	rets

* 	a10 = left:rt lim
MON_BEEK_LIMSA:
	move	a10,a9
	srl	16,a9
	sext	a10
*
*	a8 = object
*	a9 = left lim
* 	a10 = rt lim
*	a11 = vel
*
MON_BEEK_LIMS:
	move	*a8(OXVEL),a11,L
	jrn	chkleft
chkrt:
	move	*a8(OPLINK),a14,L	; is he pissed?
	jrnz	skpchk			; jump if yes
	move	*a8(OXPOS),a0
	cmp	a0,a10
	jrle	flopem
skpchk:	     
	sloop	2,chkrt

flopem:	
	move	*a8(BTURN),a1,L
	jrz	noturnanim
	move	a1,*a8(AnimFrm),L
	move	a1,*a8(AnimScr),L
;	movi	DUMRETS,a0	; turn off collisions during turn
	movi	GOO_GUNVECT,a0	;Allow some effect
	callr	SET_GUNVECT	
	sloop	50,MON_BEEK_LIMS

noturnanim:
	move	a8,a0
	movi	M_FLIPH,a5
flplp:
	move	*a0(OCTRL),a2
	xor	a5,a2			;toggle flip
	move	a2,*a0(OCTRL)
	move	*a0(OPARTS),a0,L
	jrnz	flplp

	neg	a11
	move	a11,*a8(OXVEL),L
	jrnn	chkrt

chkleft:
	move	*a8(OPLINK),a14,L	; is he pissed?
	jrnz	skpchk2			; jump if yes
	move	*a8(OXPOS),a0
	cmp	a0,a9
	jrge	flopem
skpchk2:    
	sloop	2,chkleft


*
*	When beekeeper is shot, he must drop a box if he's carrying one.
*
*	a1 = BID
*	a9 = head of beek
*
CHECK_HOLDING_BOX:
	move	*a9(OBOXLINK),a3,L
	jrz	BOX_X		; no box connected to him
	CLRM	*a9(OBOXLINK),L	; sever link
	move	a14,*a3(OBOXLINK),L
	move	*a3(OXVEL),a14,L
	sra	1,a14			; slow in X
	move	a14,*a3(OXVEL),L
	MOVIM	-1,*a3(OZVEL),L	    
	MOVIM	3000h,*a3(OYACCEL),W  ; start box a droppin.
	MOVIM	BOX_FALL,*a3(BOX_ROUT),L	; look for ground.
BOX_X:
	rets


BEEK_EXPLODE_ANIM
	LWL	1,1|AFunc,A_SPLORCH
	LWL	1,2|AFunc,CLR_VEL
;	LW	1,3
	LWL	1,3|AFunc,A_PreFrag_BEEK
	LWL	1,1|AFunc,DELETE_ENEMY


A_SPLORCH:
	MOVE	@VIOLENCE_LEVEL,A14,W
	JRZ	ASPL_X
	clr	a0
	clr	a3
	movi	[-40h,0],a4
	calla	PreFrag_Offset
	movi	FRAG_GOOEY_SPLORCH,b14
	calla	Fragger
	move	a8,*a0(FPDATA),L
ASPL_X
	rets


A_PreFrag_BEEK:
	.IF AUSTRALIA

	RETS

	.ELSE

	movi	080h,a3	 	; Abs v Z
	movi	40000h,a0	; Abs v X and Y
	calla	PreFrag_Center	      
	sra	1,b10		; halve max Z
	sll	1,b9		; double min Z
	sll	1,b7		; double min Y
	clr	b8		; y go up only
	movi	BEEK_PARTS,b14
	JAUC	Fragger			;And get it goin' Boy

	.ENDIF

*
*BEEK blows up a little bit
*
BEEK_PARTS
	.long	GLOVE_SPIN,N_CHUNK
	.word	OID_JUNK,1*800H+1*40H+FRGPAL+FRGGCOL

	.long	BOOT_SPIN,N_CHUNK
	.word	OID_JUNK,1*800H+2*40H+FRGPAL+FRGGCOL

	.long	ARM_SPIN,N_CHUNK
	.word	OID_JUNK,1*800H+1*40H+FRGPAL+FRGGCOL

	.long	HEAD_SPIN,N_CHUNK
	.word	OID_JUNK,1*800H+1*40H+FRGPAL+FRGGCOL

	.long	TANK_SPIN,N_CHUNK
	.word	OID_JUNK,1*800H+2*40H+FRGPAL+FRGGCOL
	
	.long	LEG_SPIN,N_CHUNK
	.word	OID_JUNK,1*800H+1*40H+FRGPAL+FRGGCOL

	.long	0



*
*BEEK arm spin animation
*
ARM_SPIN
	LWL	B1ARMEX1,1|AFunc,A_RAND_FLIP
	LWLW	1,1|AFunc,A_INIT_AnimSLP+1,2
	LWL	1,1|AFunc,A_Set_LOOP_STRT
; loop here
	LW	B1ARMEX2,0
	LW	B1ARMEX6,0
	LW	B1ARMEX7,0
	LW	B1ARMEX8,0
	LW	B1ARMEX9,0
	LW	B1ARMEX10,0
	LW	B1ARMEX5,0
	LWLW	B1ARMEX1,0|AFunc,A_INC_AnimSLP+1,4
	.long	0


*
*BEEK leg spin animation
*
LEG_SPIN
	LWL	B3LEGEX1,1|AFunc,A_RAND_FLIP
	LWLW	1,1|AFunc,A_INIT_AnimSLP+1,2
	LWL	1,1|AFunc,A_Set_LOOP_STRT
; loop here
	LW	B3LEGEX2,0
	LW	B3LEGEX3,0
	LW	B3LEGEX4,0
	LW	B3LEGEX5,0
	LW	B3LEGEX6,0
	LW	B3LEGEX7,0
	LWLW	B3LEGEX1,0|AFunc,A_INC_AnimSLP+1,4
	.long	0


*
*BEEK helmet spin animation
*
HEAD_SPIN
	LWL	BKHEAD1,1|AFunc,A_RAND_FLIP
	LWLW	1,1|AFunc,A_INIT_AnimSLP+1,2
	LWL	1,1|AFunc,A_Set_LOOP_STRT
; loop here
	LW	BKHEAD2,0
	LW	BKHEAD3,0
	LW	BKHEAD4,0
	LW	BKHEAD5,0
	LW	BKHEAD6,0
	LW	BKHEAD7,0
	LWLW	BKHEAD1,0|AFunc,A_INC_AnimSLP+1,4
	.long	0



*
*BEEK tank spin animation
*
TANK_SPIN
	LWL	BKTANK1,1|AFunc,A_RAND_FLIP
	LWLW	1,1|AFunc,A_INIT_AnimSLP+1,2
	LWL	1,1|AFunc,A_Set_LOOP_STRT
; loop here
	LW	BKTANK2,0
	LW	BKTANK3,0
	LW	BKTANK4,0
	LW	BKTANK5,0
	LW	BKTANK6,0
	LW	BKTANK7,0
	LW	BKTANK8,0
	LWLW	BKTANK1,0|AFunc,A_INC_AnimSLP+1,4
	.long	0


*BEEK glove spin animation
*
GLOVE_SPIN
	LWL	BKGLOVE1,1|AFunc,A_RAND_FLIP
	LWLW	1,1|AFunc,A_INIT_AnimSLP+1,2
	LWL	1,1|AFunc,A_Set_LOOP_STRT
; loop here
	LW	BKGLOVE2,0
	LW	BKGLOVE3,0
	LW	BKGLOVE4,0
	LW	BKGLOVE5,0
	LW	BKGLOVE6,0
	LW	BKGLOVE7,0
	LWLW	BKGLOVE1,0|AFunc,A_INC_AnimSLP+1,4
	.long	0


*BEEK boot spin animation
*
BOOT_SPIN
	LWL	BKBOOT1,1|AFunc,A_RAND_FLIP
	LWLW	1,1|AFunc,A_INIT_AnimSLP+1,2
	LWL	1,1|AFunc,A_Set_LOOP_STRT
; loop here
	LW	BKBOOT9,0
	LW	BKBOOT10,0
	LW	BKBOOT11,0
	LW	BKBOOT12,0
	LW	BKBOOT13,0
	LW	BKBOOT14,0
	LW	BKBOOT15,0
	LWLW	BKBOOT1,0|AFunc,A_INC_AnimSLP+1,4
	.long	0


BEEK_CVECT
	WWL	OID_PROCKET,~MASK_PLAYER,BEEK_ROCKET_COLL
	WWL	OID_PEXPLOSION,~MASK_PLAYER,BEEK_EXPLOSION_COLL
;	WWL	OID_BLOWUP,0FFFFH,BEEK_SBOMB_COLLVECT
;	WWL	OID_GRND,0FFFFH,BEEK_GRND_COLLVECT
	WL	0,DUMCRETS

MASK_CVECT
	WWL	OID_PROCKET,~MASK_PLAYER,BEEK_ROCKET_COLL
	WWL	OID_PEXPLOSION,~MASK_PLAYER,MASK_EXPLOSION_COLL
	WWL	OID_BLOWUP,0FFFFH,MASK_SBOMB_COLL
	WL	0,DUMCRETS

MASK_SBOMB_COLL:
	CALLA	GET_HEAD_PART
	MOVKM	1,*a8(OATEROCKET),W

	calla	PSTOP		   

	move	*a8(OPLINK),a0,L	; if he was shooting, kill proc
	jrz	nobproc1
	clr	a14
	move	a14,*a8(OPLINK),L	; he ain't pissed no more.
	calla	KILL
nobproc1:
	calla	COUNT_PLAYER_KILL

	MOVE	A2,*A8(OPLAYER),L	;Hang on to this address

	MOVI	1000,A1
	CALLA	SCORE			;Explosions are always good for points

	MOVI	BEEK_EXPLODE_ANIM,A1	;Die like a mutant
	calla	STRT_ANIM

	rets

MASK_EXPLOSION_COLL
	move	*a8(OPART1),a9,L	; head in a9
	MOVE	*A9(OATEROCKET),A14,W	;Did he get hit by a rocket?
	JRZ	MEC_X			;BR = NO

	SWAP	A0,A8
	CALLA	GET_HEAD_PART
	CALLA	OBJ_OFF_MULTI		;Turn explosion object off
	SWAP	A0,A8

	MOVE	*A0(OID),A0,W		;GET PLAYER DATA ADDRESS
	CALLA	POID_TO_PDATA		;GET PDATA IN A2

	PUSH	a8
	move	a9,a8			; head back into a8
	calla	PSTOP		   

	move	*a8(OPLINK),a0,L	; if he was shooting, kill proc
	jrz	nobproc2
	clr	a14
	move	a14,*a8(OPLINK),L	; he ain't pissed no more.
	calla	KILL
nobproc2:
	calla	COUNT_PLAYER_KILL

	CALLA	ALL_COLLS_OFF		;Turn all collisions off now!
	movi	OID_JUNK,a1	   
	calla	CHANGE_OID     

	MOVE	A2,*A8(OPLAYER),L	;Hang on to this address

	MOVI	1000,A1
	CALLA	SCORE			;Explosions are always good for points

	MOVI	BEEK_EXPLODE_ANIM,A1	;Die like a mutant
	calla	STRT_ANIM
	PULLQ	a8
MEC_X:
	rets

**************************************************************************
*								         *
* BEEK_ROCKET_COLL - Collision vector for Player rocket bomb.		 *
* A0 = Ptr to rocket object						 *
* A8 = Ptr to NON-BOY object						 *
*								         *
**************************************************************************
BEEK_ROCKET_COLL
	CALLA	GET_HEAD_PART
	MOVKM	1,*a8(OATEROCKET),W
	RETS


**************************************************************************
*								         *
* BEEK_EXPLOSION_COLL - Collision vector for Player explosion.	 *
* A0 = Ptr to explosion object						 *
* A8 = Ptr to NON-BOY object						 *
*								         *
**************************************************************************
BEEK_EXPLOSION_COLL
	move	*a8(OPART1),a9,L	; head in a9
	MOVE	*A9(OATEROCKET),A14,W	;Did he get hit by a rocket?
	JRNZ	BEC_NOT_PISSED		;BR = Yes

	CLR	A4
	MOVE	*A0(OID),A0,W		;GET PLAYER DATA ADDRESS
	CALLA	POID_TO_PDATA		;GET PDATA IN A2
	JRUC	PISS_HIM_OFF

BEC_NOT_PISSED
	SWAP	A0,A8
	CALLA	GET_HEAD_PART
	CALLA	OBJ_OFF_MULTI		;Turn explosion object off
	SWAP	A0,A8

	MOVE	*A0(OID),A0,W		;GET PLAYER DATA ADDRESS
	CALLA	POID_TO_PDATA		;GET PDATA IN A2

;	move	*a8(OPART1),a9,L	; head in a9
;	clr	a4			; indicate explo entry to PISS_HIM_OFF
;	MOVE	*A9(OATEROCKET),A14,W	;Did he get hit by a rocket?
;	JRZ	PISS_HIM_OFF		;BR = No, just do generic for now.
	move	*a9(BID),a6		; which beekeeper are we?
	cmpk	BID_BOX3,a6	      
	jrne	noboxer
	callr	CHECK_HOLDING_BOX	; is he holding a box?
noboxer:
	PUSH	a8
	move	a9,a8			; head back into a8
	calla	PSTOP		   

	callr	KILL_TURN_PROC

	move	*a8(OPLINK),a0,L	; if he was shooting, kill proc
	jrz	nobproc
	clr	a14
	move	a14,*a8(OPLINK),L	; he ain't pissed no more.
	calla	KILL
nobproc:
	calla	COUNT_PLAYER_KILL

	CALLA	ALL_COLLS_OFF		;Turn all collisions off now!
	movi	OID_JUNK,a1	   
	calla	CHANGE_OID     

	MOVE	A2,*A8(OPLAYER),L	;Hang on to this address

	MOVI	1000,A1
	CALLA	SCORE			;Explosions are always good for points


	move	*a8(BID),a6		; which beekeeper are we?
	cmpK	BID_BOX3,a6
	jrne	NO_Boxer2
	move	@NUM_OUT_THERE,a14
	dec	a14
	move	a14,@NUM_OUT_THERE
	
NO_Boxer2:	 
	MOVI	BEEK_EXPLODE_ANIM,A1	;Die like a mutant
	calla	STRT_ANIM
	PULLQ	a8
	rets


KILL_TURN_PROC:
	move	*a9(BTRNPRC),a0,L	; MON_BEEK_LIM proc
	jrz	notrnproc
	CLRM	*a9(BTRNPRC),L		; kill it if it exists
	move	a14,*a9(BTURN),L
	calla	KILL
notrnproc:
	rets


BEEK_GUNVECT:
	movk	1,a4			; indicates gun vector entry
	move	*a8(OPART1),a9,L	; get head

PISS_HIM_OFF:				; entry point from explosiont
	move	*a9(OPLINK),a14,L	; if there is one,
	jrnz	ALREADY_PISSED		; he's pissed

	move	*a9(BID),a6		; which beekeeper are we?
	cmpi	BID_BOX3,a6
	jrne	NO_Boxer
	callr	CHECK_HOLDING_BOX	; is he holding a box?
NO_Boxer:
	move	a4,a4	    		; skip tank check if got here
	jrz	explo_entry		; 	from an explosion
	callr	CHECK_TANK_HIT		; leave animation in a6 and Z set
	jrc	SendHimOff
explo_entry:

	sll	5,a6
	move	a6,a3
	addi	SHOOT_TRANS_TBL,a6	; which table gets us shooting?
	move	*a6,a1,L
	MOVE	A1,*a9(AnimFrm),L	; jump to transition animation
	MOVE	A1,*a9(AnimScr),L
	addi	BACK_TRANS_TBL,a3
	move	*a3(0),*a9(BTRANS),L	; seq to get back to normal

	MOVKB	1,*a9(AnimSlp)
	CREATE	PID_IND,HE_BE_PISSED
	move	a0,*a9(OPLINK),L
	movi	PISSED_BEEK_GUNV,a14
	move	a9,a5
chgvlp:
	move	a14,*a5(OGUNVECT),L
	move	*a5(OPARTS),a5,L
	jrnz	chgvlp


PISSED_BEEK_GUNV:
	move	*a8(OPART1),a9,L
ALREADY_PISSED:
	SOUND1	SND_BODY_HIT

	MOVIM	100,*a9(ANNOYED),W	; set annoyance level
	move	*a9(BHITS),a14
	inc	a14
	move	a14,*a9(BHITS)

;	After a certain number of hits, knock him back (becomes masked guy)

	cmpk	5,a14
	jrlt	BEEK_GUNX

	callr	KILL_TURN_PROC

	MOVE	*A9(OPLINK),A0,L	; kill the pissed process if it exists
	JRZ	PGV0
	CLRM	*A9(OPLINK),L		;WASTE THE OPLINK
	CALLA	KILL
PGV0:
	CALLA	GOOEY_BULLET_HIT

;	movi	DUMRETS,a0	; no real gunvect if he's falling
	movi	GOO_GUNVECT,a0	;Just jizm if he's on the ground
	callr	SET_GUNVECT

	move	*a9(BID),a14
	cmpi	BID_BOX3,a14
	jrne	NO_Boxer3
	move	@NUM_OUT_THERE,a14	; if he was a box carrier...
	dec	a14			; he ain't no more
	move	a14,@NUM_OUT_THERE
	
NO_Boxer3:				
	MOVIM	BID_MASK,*a9(BID),W	; Now he's Mr. Meanie 

	movi	BEEK_HIT_ANIM,a1
	move	a1,*a9(AnimFrm),L
	move	a1,*a9(AnimScr),L

BEEK_GUNX:
	rets



MASK_GUNVECT:
	move	*a8(OPART1),a9,L

;	move	*a9(BHITS),a14
;	inc	a14
;	move	a14,*a9(BHITS)
;
;	After a certain number of hits, knock him back (becomes masked guy)
;
;	cmpk	5,a14
;	jrlt	MASK_GUNX
;
;	clr	a14
;	move	a14,*a9(BHITS)	; reset hit count

	SOUND1	SND_BODY_HIT
	CALLA	GOOEY_BULLET_HIT

;	movi	DUMRETS,a0	; no real gunvect if he's falling
	movi	GOO_GUNVECT,a0	;Just jizm if he's on the ground
	callr	SET_GUNVECT

	movi	MASK_HIT_ANIM,a1
	move	a1,*a9(AnimFrm),L
	move	a1,*a9(AnimScr),L

MASK_GUNX:
	rets

*
* Gun vector to just spurt goo
*
GOO_GUNVECT
	SOUND1	SND_BODY_HIT
	JAUC	GOOEY_BULLET_HIT


SND_BEEKHIT
	.word	0f342h,64,0a465h,0
SND_BODY_HIT
	.WORD	0F120H,32,0A49FH,0	;Bullet hits his body


BEEK_HIT_ANIM:
	LWLL	ML1D_A1,1|AMulti|AFunc,A_CHANGE_PAL+2,P_GXBEEM
	LWLL	MT1D_A1,1|AMulti|AFunc,A_CHANGE_PAL+2,P_GXBEEM
	LWLL	BH1D_A1,1|AMulti|AFunc,A_SOUNDZ_ONSCREEN+2,SND_BEEKHIT
	LWL	1,3|AFunc,OBJ_OFF
	
	LW	ML1D_A2,1|AMulti
	LW	MT1D_A2,1|AMulti
	LW	BH1D_A2,1|AMulti
	LWL	MA1D_A2,3|AFunc,OBJ_ON
	
	LW	ML1D_A3,1|AMulti
	LW	MT1D_A3,1|AMulti
	LW	BH1D_A3,1|AMulti
	LWLL	MA1D_A3,3|AFunc,A_CHANGE_PAL+2,P_GXBEEM

	LW	ML1D_A4,1|AMulti
	LW	MT1D_A4,1|AMulti
	LW	BH1D_A4,1|AMulti
	LW	MA1D_A4,3

	LW	ML1D_A5,1|AMulti
	LW	MT1D_A5,1|AMulti
	LW	BH1D_A5,1|AMulti
	LW	MA1D_A5,3

	LW	ML1D_A6,1|AMulti
	LW	MT1D_A6,1|AMulti
	LW	BH1D_A6,1|AMulti
	LW	MA1D_A6,3

	LW	ML1D_A7,1|AMulti
	LW	MT1D_A7,1|AMulti
	LW	BH1D_A7,1|AMulti
	LW	MA1D_A7,5

	LW	ML1D_A8,1|AMulti
	LW	MT1D_A8,1|AMulti
	LW	BH1D_A8,1|AMulti
	LWL	1,90|AFunc,OBJ_OFF

	LW	1,1|AMulti
	LW	1,1|AMulti
	LWLL	1,1|AFunc,A_CHANGE_PAL+2,P_GXBEEM

	LWLL	1,1|AFunc,A_AnimGo+2,MASK_GET_UP

MASK_HIT_ANIM:
	LWL	ML1D_A1,1|AMulti|AFunc,DEATH_TAKE_OFF
	LWLL	MT1D_A1,1|AMulti|AFunc,A_SOUNDZ_ONSCREEN+2,SND_BEEKHIT
	LW	MH1D_A1,1|AMulti
	LWL	1,3|AFunc,OBJ_OFF
	
	LW	ML1D_A2,1|AMulti
	LW	MT1D_A2,1|AMulti
	LW	MH1D_A2,1|AMulti
	LWL	MA1D_A2,3|AFunc,OBJ_ON
	
	LW	ML1D_A3,1|AMulti
	LW	MT1D_A3,1|AMulti
	LW	MH1D_A3,1|AMulti
	LW	MA1D_A3,3

	LW	ML1D_A4,1|AMulti
	LW	MT1D_A4,1|AMulti
	LW	MH1D_A4,1|AMulti
	LW	MA1D_A4,3

	LW	ML1D_A5,1|AMulti
	LW	MT1D_A5,1|AMulti
	LW	MH1D_A5,1|AMulti
	LW	MA1D_A5,2

	LWL	1,1|AFunc,A_STAY_TIL_GRND_HIT

	LWL	ML1D_A6,1|AMulti|AFunc,PSTOP
	LW	MT1D_A6,1|AMulti
	LW	MH1D_A6,1|AMulti
	LW	MA1D_A6,3

	LW	ML1D_A7,1|AMulti
	LW	MT1D_A7,1|AMulti
	LW	MH1D_A7,1|AMulti
	LW	MA1D_A7,5

	LW	ML1D_A8,1|AMulti
	LW	MT1D_A8,1|AMulti
	LW	MH1D_A8,1|AMulti
	LWL	1,120|AFunc,OBJ_OFF

MASK_GET_UP
	LWLL	ML1RISE_A1,1|AMulti|AFunc,A_SOUNDZ_ONSCREEN+2,SND_T800
	LW	MT1RISE_A1,1|AMulti
	LW	MH1RISE_A1,1|AMulti
	LWL	MA1RISE_A1,6|AFunc,OBJ_ON

	LW	ML1RISE_A2,1|AMulti
	LW	MT1RISE_A2,1|AMulti
	LW	MH1RISE_A2,1|AMulti
	LWL	1,3|AFunc,OBJ_OFF

	LW	ML1RISE_A3,1|AMulti
	LW	MB1RISE_A3,1|AMulti
	LWL	1,3|AFunc,OBJ_OFF

	LW	MH1RISE_A4,1|AMulti
	LW	MT1RISE_A4,1|AMulti
	LWL	ML1RISE_A4,3|AFunc,OBJ_ON

	LW	MH1RISE_A5,1|AMulti
	LW	MB1RISE_A5,1|AMulti
	LWL	1,3|AFunc,OBJ_OFF

	LW	MB1K_A2,1|AMulti
	LW	MH1K_A2,3

	LWLL	1,1|AFunc,A_SET_CVECT+2,MASK_CVECT

	LW	ML1K_A1,1|AMulti
	LW	MT1K_A1,1|AMulti
	LWL	MH1K_A1,2|AFunc,OBJ_ON

	LWLL	1,1|AFunc,A_SET_GUNVECT+2,MASK_GUNVECT

	LW	ML1ST_A1,1|AMulti
	LW	MT1ST_A1,1|AMulti
	LW	MH1ST_A1,3

MASK_FIRE_LOOP:
	LWL	1,1|AFunc,A_Set_LOOP_STRT	; loop while firing
	LW	ML1SH_A1,1|AMulti
	LWLWW	MH1SH_A1,1|AMulti|AFunc,A_CHK_FIRE_FNC+2,-9,-91 
	LW	MT1SH_A1,5

	LWL	ML1SH_A2,1|AMulti|AFunc,A_INC_LOOP_CNT
	LW	MH1SH_A2,1|AMulti
	LW	MT1SH_A2,4
	
	LWL	1,1|AFunc,SHOULD_I_STAY_PUT

	.long	0


MORF_JUMP_INIT:
	.byte	4,0,0,1
	.long	P_GXBEEM
	.word	OID_BEEKPR,OM_COLL
	.long	MASK_CVECT
	LWWWW	ML1LP_C5,DMAWNZ,0,1,OM_ANIM|OM_GUNV|OM_CFUNC
	.long	MASK_GUNVECT
	.long	MORF_JUMP_OUT
	.long	C_SET_BID
	.word	BID_MASK
	LWWWW	MH1K_A1,DMAWNZ,0,0,OM_PRVGUNV
	LWWWW	MT1K_A1,DMAWNZ,0,1,OM_PRVGUNV
	LWWWW	ML1K_A1,DMAWNZ,M_NODISP,1,OM_PRVGUNV


MORF_JUMP_OUT:
	LW	ML1K_A1,1|AMulti
	LW	MH1K_A1,1|AMulti
	LW	MT1K_A1,8

	LW	ML1J_A1,1|AMulti
	LW	MH1J_A1,1|AMulti
	LW	MT1J_A1,2

	LWL	ML1J_A2,1|AMulti|AFunc,MORF_TAKE_OFF
	LW	MH1J_A2,1|AMulti
	LW	MT1J_A2,2

	LWLL	1,1|AFunc,A_AnimGo+2,MASK_FWD_HOOK

MASK_FWD_LEAP
	LW	ML1K_A1,1|AMulti
	LW	MH1K_A1,1|AMulti
	LW	MT1K_A1,5

	LW	ML1J_A1,1|AMulti
	LW	MH1J_A1,1|AMulti
	LW	MT1J_A1,3

	LWL	ML1J_A2,1|AMulti|AFunc,TAKE_OFF_Z
	LW	MH1J_A2,1|AMulti
	LW	MT1J_A2,3

MASK_FWD_HOOK:
	LW	ML1J_A3,1|AMulti
	LW	MH1J_A3,1|AMulti
	LW	MT1J_A3,2

	LWL	1,1|AFunc,A_STAY_TIL_YVEL_POS

	LW	ML1J_A4,1|AMulti
	LW	MH1J_A4,1|AMulti
	LW	MT1J_A4,3

MASK_DROP_ANIM:
	LW	ML1J_A5,1|AMulti
	LW	MH1J_A5,1|AMulti
	LW	MT1J_A5,1|AMulti
	LWL	MA1J_A5,2|AFunc,OBJ_ON

	LWL	1,1|AFunc,A_STAY_TIL_GRND_HIT

	LWL	ML1J_A6,1|AMulti|AFunc,PSTOP
	LW	MH1J_A6,1|AMulti
	LW	MT1J_A6,1|AMulti
	LWL	1,3|AFunc,OBJ_OFF

	LW	MH1J_A7,1|AMulti
	LW	MB1J_A7,1|AMulti
	LWL	1,3|AFunc,OBJ_OFF

	LW	ML1K_A1,1|AMulti
	LW	MH1K_A1,1|AMulti
	LWL	MT1K_A1,2|AFunc,OBJ_ON

	LWLL	1,1|AFunc,A_AnimGo+2,MASK_FIRE_LOOP



A_SET_HFLIP:
	movi	M_FLIPH,a0
A_SET_FLIPS:
	move	*a8(OPART1),a14,L
	jaz	SET_FLPS
	move	a14,a8
	jauc	SET_FLPS


A_CLR_FLIPS:
	clr	a0
	jruc	A_SET_FLIPS



MASK_RT_LEAP:
	LWL	ML1LP_C1,1|AMulti|AFunc,A_CLR_FLIPS
	LW	MH1LP_C1,1|AMulti
	LW	MT1LP_C1,2

	LWLL	1,1|AFunc,A_AnimFrm+2,MASK_SIDE_HOOK

MASK_LFT_LEAP:
	LWL	ML1LP_C1,1|AMulti|AFunc,A_SET_HFLIP
	LW	MH1LP_C1,1|AMulti
	LW	MT1LP_C1,3

MASK_SIDE_HOOK:	
	LWL	ML1LP_C2,1|AMulti|AFunc,TAKE_OFF_X
	LW	MH1LP_C2,1|AMulti
	LW	MT1LP_C2,3

	LWL	1,1|AFunc,A_STAY_TIL_YVEL_POS

	LW	ML1LP_C3,1|AMulti
	LW	MH1LP_C3,1|AMulti
	LW	MT1LP_C3,2

	LWL	1,1|AFunc,A_STAY_TIL_GRND_HIT

	LWL	ML1LP_C4,1|AMulti|AFunc,PSTOP
	LW	MH1LP_C4,1|AMulti
	LW	MT1LP_C4,3

	LW	ML1LP_C5,1|AMulti
	LW	MH1LP_C5,1|AMulti
	LW	MT1LP_C5,3

	LW	ML1K_A1,1|AMulti
	LW	MH1K_A1,1|AMulti
	LWL	MT1K_A1,2|AFunc,OBJ_ON

	LWLL	1,1|AFunc,A_AnimGo+2,MASK_FIRE_LOOP


*
*	This keeps a record of how many shots the masked guy has fired
*	so that SHOULD_I_STAY_PUT can decide if he should move or shoot more.
*
A_INC_LOOP_CNT:
	movb	*a8(AnimLoop),a14
	inc	a14
	jrnn	itscool
	movk	14,a14			; make it a number > 10
itscool:
	movb	a14,*a8(AnimLoop)
	rets

*
*	beekeeper may decide to leap forward or sideways
*
SHOULD_I_STAY_PUT:
	move	@OBJENEMIES,a14
	btst	B_OF_MORFRS,a14
	jrz	SISPnorm
*
*	special logic if at morph chamber
*
	move	*a8(OZVAL),a5,L	; where are we in Z
	move	@ZREL_OFF,a6,L
	sra	ZFRAC,a6
	move	*a8(OXPOS),a4	; get his x position
	cmpi	MID_PLANT,a4	; which side are we on?
	jrgt	RMC
*
*	left side
*
	addi	-120d1h,a6	; Univ Z we must clear
	cmp	a6,a5
	jrlt	MorphSideChk
	cmpi	172h-30H,a4
	jrlt	move_fwd
	movi	MASK_LFT_LEAP,a14
	jruc	set_move

*
*	right side
*
RMC:
	addi	-128e4h,a6	; Univ Z we must clear
	cmp	a6,a5
	jrlt	MorphSideChk
	cmpi	4b0h+30H,a4
	jrgt	move_fwd
	movi	MASK_RT_LEAP,a14
	jruc	set_move


SISPnorm:
	move	@ZBASE,a0,L
	move	*a8(OZVAL),a1,L
	sub	a0,a1		; get world Z in a1
	move	@ZSCROLL,a2,L	; no leap if player scrolling toward beek
	jrgt	no_fwd
	cmpi	0f000h,a1  	; if real far, jump more
	jrgt	move_fwd

	movb	*a8(AnimLoop),a14	; must have fired a while
	cmpk	10,a14
	jrle	no_move

	callr	SideCheck	; see if a sideways move is appropriate
	jrc	move_side
	cmpi	0a000h,a1
	jrlt	no_move
	movi	700,a0 		; between a000h and 0f000h
	calla	RANDPER		; decide randomly to move fwd or not
	jrnc	no_move
move_fwd:
	move	@WORLD_GRNDOFF+10h,a14	; no fwd move if FINALE
	jrnz	no_move

	movi	MASK_FWD_LEAP,a14
	jruc	set_move


*
*	Check if a sideways jump is appropriate
*
no_fwd:
	callr	SideCheck
	jrnc	no_move	
move_side:
	movi	MASK_LFT_LEAP,a14
	move	*a8(ODAGX),a0
	cmpi	200,a0
	jrgt	set_move
	movi	MASK_RT_LEAP,a14
set_move:
	move	a14,*a8(AnimFrm),L
	move	a14,*a8(AnimScr),L
no_move:
	rets

*
*	world Z in a1
*
SideCheck:
	cmpi	ZMAX_REAL,a1		; no side jump if too close
	jrlt	noside			; to be seen
	move	*a8(OFLAGS),a4
	btst	B_OFSCRN,a4   		; side jump if offscreen
	jrnz	yesside
*
*	if close to an edge, jump more
*
	move	*a8(ODAGX),a14
	subi	100,a14
	cmpi	200,a14
	jrlo	noside 		; if within range 100-300, no side jump
	movi	900,a0
	calla	RANDPER
	jrnc	noside
yesside:
	setc
	rets

noside:
	clrc
	rets

MorphSideChk:
	movb	*a8(AnimLoop),a14	; must have fired a while
	cmpk	10,a14
	jrle	no_move
	jruc	move_side



*
*	To give the mask guy a little lift before he drops
*	and handle the shooting of a falling or leaping mask guy
*
DEATH_TAKE_OFF:
	MOVIM	-1c000h,*a8(OYVEL),L
	MOVIM	3000h,*a8(OYACCEL),W
	rets

MORF_TAKE_OFF:
	movi	1a000h,a0
	movi	-1a000h,a1
	calla	RANGRAND  		; spread em out in X
	move	a0,*a8(OXVEL),L

	CLRB	*a8(AnimLoop)

	MOVIM	-100h,*a8(OZVEL),L

	MOVIM	-20000h,*a8(OYVEL),L
	MOVIM	3000h,*a8(OYACCEL),W
	rets

TAKE_OFF_Z:
	CLRB	*a8(AnimLoop)

	MOVIM	-0d0h,*a8(OZVEL),L

	MOVIM	-42000h,*a8(OYVEL),L
	MOVIM	3000h,*a8(OYACCEL),W
	rets


TAKE_OFF_X:
	CLRB	*a8(AnimLoop)

	movi	10000h,a0
	MOVE	*A8(OCTRL),A14,W	
	BTST	B_FLIPH,A14
	JRZ	ASO_NOW
	NEG	A0
ASO_NOW
	MOVE	A0,*A8(OXVEL),L			

	MOVIM	-42000h,*a8(OYVEL),L
	MOVIM	3000h,*a8(OYACCEL),W
	rets


MASK_DROP_INIT:
	.byte	4,0,0,1
	.long	P_GXBEEM
	.word	OID_BEEKPR,OM_COLL
	.long	MASK_CVECT
	LWWWW	ML1J_A5,DMAWNZ,0,1,OM_ANIM|OM_GUNV|OM_CFUNC
	.long	MASK_GUNVECT
	.long	MASK_DROP_ANIM
	.long	C_SET_BID
	.word	BID_MASK
	LWWWW	MH1J_A5,DMAWNZ,0,0,OM_PRVGUNV
	LWWWW	MT1J_A5,DMAWNZ,0,1,OM_PRVGUNV
	LWWWW	MA1J_A5,DMAWNZ,0,1,OM_PRVGUNV

	.def	PROC_DROP_BEEM
	.ref	WORLD_GRNDOFF

*	a9 = UNIV Z
*	a10 = UNIV X min 
*	a11 = UNIV X max
*
PROC_DROP_BEEM:
	MOVI	OID_BEEKPR,A0
	CALLA	GET_ENEMY_COUNT
	CMPK	4,A0
	JAHS	SUCIDE

	movi	MASK_DROP_INIT,b0
	calla	MULTIMAKE
	jaz	SUCIDE

	CALLR	CLR_BEEK_ODATA

	move	a10,a1
	move	a11,a0
	calla	RANGRAND
	sll	16,a0
	move	a0,a1			; univ X in a1

	move	@WORLD_GRNDOFF,a2,L
	subi	1000000h,a2		; univ Y in a2
	move	a9,a3			; univ Z in a3
	calla	SET_ANIPU

	calla	GET_SHAD_MULTI

	calla	INSERT_ENEMY

	MOVIM	2800h,*a8(OYACCEL),W

	DIE


*
*	If players aren't causing any damage, these guys
*	come down.
*
DROP_A_MASK_GUY:
	movi	MASK_DROP_INIT,b0
	calla	MULTIMAKE
*
	CALLR	CLR_BEEK_ODATA

	movi	4bh,a0
	movi	-4bh,a1
	calla	RANGRAND		; random world X
	sll	16,a0
	move	@XBASE,a1,L		; univ X in a1
	add	a0,a1
	movi	-1000000h,a2,L		; univ Y in a2
	move	@ZBASE,a3,L
	addi	9000h,a3		; univ Z in a3
	movi	-4040h,a4		; back wall relative
	move	@ZREL_OFF,a5,L
	sra	ZFRAC,a5		; check creation Z against
	add	a5,a4			; back wall
	cmp	a4,a3			; if a3 > a4, change a3
	jrle	DAMZok
       	move	a4,a3			; (we don't want him to be behind wall)
DAMZok:
	calla	SET_ANIPU

	calla	INSERT_OBJ

	MOVIM	2800h,*a8(OYACCEL),W

	rets



SND_T800
	.word	0f342h,116,0a4aah,0	; masked guy gets up

*
*	if hit in tank, blast off!
*	a1 = animation
SendHimOff:
*
*	Create tank hiss
*	
	mmtm	sp,b0,b1,b2,b3,b4,b5,b6,b7,b8,b9,b10
	move	a1,a3
	movi	HISS_INIT,b0
	calla	EASYMAKE
	jrz	nohiss
	mmfm	sp,b0,b1,b2,b3,b4,b5,b6,b7,b8,b9,b10

	move	a3,*a0(OYVAL),L
	move	a7,*a0(OXVAL),L
	move	*a9(OZVAL),a14,L
	dec	a14
	move	a14,*a0(OZVAL),L
	move	a0,*a9(BHISS),L		; save HISS obj in ODATA
	calla	INSOBJ
	calla	INSPART		; make hiss part of beek
nohiss:
	move	a6,*a9(AnimFrm),L	
	move	a6,*a9(AnimScr),L	
	MOVIM	-1000h,*a9(OYACCEL),W	; take off
	move	a9,a8

;	movi	DUMRETS,a0		; can't shoot him no mo
	movi	GOO_GUNVECT,a0		;Always allow the funk
	callr	SET_GUNVECT		

	callr	KILL_TURN_PROC


	MOVE	A2,*A8(OPLAYER),L	;Hang on to this address

	movi	20000,a1
	calla	SCORE

	calla	COUNT_PLAYER_KILL

	CLRM	*a9(BTURN),L		; clear turn animation
	rets

HISS_INIT
	.long	RKTSPR2
	.word	DMAWNZ,M_NOPARTANI,OM_ANIM
	.long	HISS_ANIM

SND_TNKHISS	.word	0f348h,77,0a408h,0
SND_BEEKRISE	.long	SND_BKRISE1,SND_BKRISE2
SND_BKRISE1	.word	0f346h,64,0a215h,0
SND_BKRISE2	.word	0f346h,81,0a21bh,0

HISS_ANIM
	LW	RKTSPR2,2
	LWLL	RKTSPR3,2|AFunc,A_SOUNDZ+2,SND_TNKHISS
	LW	RKTSPR4,2
	LW	RKTSPR5,2
	LW	RKTSPR6,2
	LW	RKTSPR7,2
	LW	RKTSPR8,2
	LWLLW	RKTSPR7,2|AFunc,A_TAB_SOUNDZ+3,SND_BEEKRISE,2
	LW	RKTSPR8,2

	LWL	1,1|AFunc,A_Set_LOOP_STRT	; start looping

	LW	RKTSPR10,2
	LW	RKTSPR11,2
	LW	RKTSPR12,2
	LW	RKTSPR11,2
	LW	RKTSPR10,2
	LW	RKTSPR12,2
	.long	0
	


*
*	Tank take off animations based on BID
*
TankAniTbl:
	.long  0		; BID 0 = facing player, can't hit tank
	.long  B_TANK_ANIM4	; BID 1 = WALK3
	.long  B_TANK_ANIM4	; BID 2 = STND3
	.long  B_TANK_ANIM5	; BID 3 = BUTN3
	.long  B_TANK_ANIM4	; BID 4 = STND5
	.long  B_TANK_ANIM5	; BID 5 = BUTN5
	.long  B_TANK_ANIM5	; BID 6 = BOX3

*
*	Tank positions based on BID
*
TankOffTbl:
	.long	0DEADBEEFH,0	; BID 0 = facing player, can't hit tank
	.word	-27,-110, -13,-77	; BID 1 = WALK3
	.word	-35,-114, -16,-86	; BID 2 = STND3
	.word	-33,-115, -18,-80	; BID 3 = BUTN3
	.word	-10,-114, 5,-79		; BID 4 = STND5
	.word	-7,-113, 8,-80		; BID 5 = BUTN5
	.word	-23,-110, -11,-78	; BID 6 = BOX3
	
*
*	called from BEEK_GUNVECT to determine if bullet hit the
*	beekeeper's tank.
*
*	must preserve a2 (player data area)
*
*	Entry: a6 = BID
*	       a9 = head obj of beekeeper	
*
*	Exit:	If tank hit,   Carry set and a6 = animation
*		If tank not hit, Carry clr and a6 = BID
*
CHECK_TANK_HIT:
	move	a6,a14
	sll	6,a14
	addi	TankOffTbl,a14
	move	*a14+,a3,L 	; get box limits to check
	move	*a14,a4,L
	cmpi	0deadbeefh,a3	; look for abort code
	jreq	no_tank_hit
	calla	BOX_CHECK_OBJ	
	jrz	no_tank_hit
	sll	5,a6
	addi	TankAniTbl,a6
	move	*a6,a6,L	; get ani script
	setc
	rets


no_tank_hit:
	clrc	
	rets


*	a8 contains obj hit
*	a9 contains head
*
HE_BE_PISSED:
	move	*a9(ANNOYED),a0
	subk	5,a0
	move	a0,*a9(ANNOYED)
	jrz	he_be_cool
	sloop	5,HE_BE_PISSED

he_be_cool:
	move	*a9(BTRANS),a1,L	; how to get back to normal
	MOVE	A1,*A9(AnimFrm),L	; jump to transition back to mundane
	MOVE	A1,*A9(AnimScr),L
	MOVKB	1,*a9(AnimSlp)
	CLRM	*a9(OPLINK),L
	movi	BEEK_GUNVECT,a14
chgvlp2:
	move	a14,*a9(OGUNVECT),L
	move	*a9(OPARTS),a9,L
	jrnz	chgvlp2
	DIE	


A_SELECT_BK_ANIM:
	move	*a8(OPART1),a0,L
	move	*a0(BID),a1		; which beekeeper are we?
	sll	5,a1	
	addi	NORM_BANIM_TBL,a1	; which table is normal?
	move	*a1,a1,L
	MOVE	A1,*A0(AnimFrm),L	; jump to normal animation
	MOVE	A1,*A0(AnimScr),L
	rets

Set_HISS_ZOFF:
	calla	GETAFARG_WORD
	move	*a8(BHISS),a3,L
	move	*a8(OZVAL),a14,L
	add	a0,a14
	move	a14,*a3(OZVAL),L
	rets


SET_HISS_POS1:
	MOVIM	B_TANK_LOOP,*a8(AnimScr),L	; loop back to here now
	MOVIM	B_TANK_HOOK,*a8(AnimFrm),L	; this is next frame


SET_HISS_POS:
	move	*a8(BHISS),a3,L		; move hiss to a fixed position
					; relative to spinning guy.
	move	*a8(OXVAL),a1,L
	subi	2<<15,a1
	move	a1,*a3(OXVAL),L

	move	*a8(OYVAL),a1,L
	subi	98<<15,a1
	move	a1,*a3(OYVAL),L

	move	*a8(OZVAL),a1,L		; put behind guy for start
	addk	2,a1
	move	a1,*a3(OZVAL),L

	calla	DELETE_SHADOW		; for flying beek 

	rets




DELETE_PART:
	calla	PULL_PART
	jauc	DELETE_OBJ


****************************
*			   *
*  Flying after tank hit   *
*			   *
****************************
B_TANK_ANIM5:

	LWL	ML1SP_A1,1|AMulti|AFunc,SET_HISS_POS1			     
	LW	BH1SP_A1,1|AMulti		; frame 1 of 8
	LW	MT1SP_A1,1|AMulti
	LWL	MA1SP_A1,1|AMulti|AFunc,OBJ_ON
	LWL	1,5|AFunc,DELETE_PART


B_TANK_ANIM4:
	LWL	1,1|AFunc,SET_HISS_POS
	LWL	1,1|AFunc,A_Set_LOOP_STRT
B_TANK_LOOP:
	LW	ML1SP_A1,1|AMulti
	LW	BH1SP_A1,1|AMulti		; frame 1 of 8
	LW	MT1SP_A1,1|AMulti
	LWL	MA1SP_A1,5|AFunc,OBJ_ON

B_TANK_HOOK:
	LW	ML2SP_B1,1|AMulti
	LW	BH2SP_B1,1|AMulti		; frame 2 of 8
	LW	MT2SP_B1,1|AMulti
	LW	MA2SP_B1,5

	LW	ML3SP_C1,1|AMulti
	LW	BH3SP_C1,1|AMulti		; frame 3 of 8
	LW	MT3SP_C1,1|AMulti
	LW	MA3SP_C1,4

	LWLW	1,1|AFunc,Set_HISS_ZOFF+1,-1

	LW	ML4SP_D1,1|AMulti
	LW	BH4SP_D1,1|AMulti		; frame 4 of 8
	LW	MT4SP_D1,1|AMulti
	LWL	1,5|AFunc,OBJ_OFF

	LW	ML5SP_E1,1|AMulti
	LW	BH5SP_E1,1|AMulti		; frame 5 of 8
	LW	MT5SP_E1,5

	LW	ML6SP_F1,1|AMulti
	LW	BH6SP_F1,1|AMulti		; frame 6 of 8
	LW	MT6SP_F1,5				

	LW	ML7SP_G1,1|AMulti
	LW	BH7SP_G1,1|AMulti		; frame 7 of 8
	LW	MT7SP_G1,4

	LWLW	1,1|AFunc,Set_HISS_ZOFF+1,2

	LWL	ML8SP_H1,1|AMulti|AFunc,A_OFFSCRN_DELENEMY
	LW	BH8SP_H1,1|AMulti		; frame 8 of 8
	LW	MT8SP_H1,5

	.long	0

*************************************
*			            *
*  Facing away pushing buttons      *
*			            *
*************************************
B5_BUTN_INIT:
	.byte	5,0,0,1
	.long	P_GXBEE
	.word	OID_BEEKPR,OM_COLL
	.long	BEEK_CVECT
	LWWWW	BL5PT_E6,DMAWNZ,0,1,OM_ANIM|OM_GUNV|OM_CFUNC
	.long	BEEK_GUNVECT
	.long	B5_BUTN_ANIM
	.long	C_SET_BID
	.word	BID_BUTN5
	LWWWW	BH5PT_E1,DMAWNZ,0,-1,OM_PRVGUNV
	LWWWW	BT5PT_E1,DMAWNZ,0,0,OM_PRVGUNV
	LWWWW	BA5PT_E1,DMAWNZ,0,0,OM_PRVGUNV
	LWWWW	BZ5PT_E3,DMAWNZ,M_NODISP,0,OM_PRVGUNV

B5_BUTN_ANIM:
	LW	BL5PT_E6,1|AMulti
	LW	BH5PT_E1,1|AMulti
	LW	BT5PT_E1,1|AMulti
	LWL	BA5PT_E1,1|AMulti|AFunc,OBJ_ON
	LWL	1,5|AFunc,OBJ_OFF

	LW	1,1|AMulti
	LW	1,1|AMulti
	LW	BT5PT_E2,1|AMulti
	LW	BA5PT_E2,1|AMulti
	LW	1,5

	LW	1,1|AMulti
	LW	BH5PT_E2,1|AMulti
	LW	BT5PT_E3,1|AMulti
	LW	BA5PT_E3,1|AMulti
	LWL	BZ5PT_E3,5|AFunc,OBJ_ON

	LW	1,1|AMulti
	LW	1,1|AMulti
	LW	BT5PT_E4,1|AMulti
	LW	BA5PT_E4,1|AMulti
	LW	BZ5PT_E4,5

	LW	1,1|AMulti
	LW	BH5PT_E4,1|AMulti
	LW	BT5PT_E5,1|AMulti
	LW	BA5PT_E5,1|AMulti
	LWL	1,5|AFunc,OBJ_OFF

	LW	1,1|AMulti
	LW	1,1|AMulti
	LW	BT5PT_E6,1|AMulti
	LW	BA5PT_E6,1|AMulti
	LWL	BZ5PT_E6,5|AFunc,OBJ_ON

	LW	1,1|AMulti
	LW	BH5ST_E1,1|AMulti
	LW	BT5PT_E7,1|AMulti
	LW	BA5PT_E7,1|AMulti
	LW	BZ5PT_E7,5

	LW	1,1|AMulti
	LW	1,1|AMulti
	LW	BT5PT_E8,1|AMulti
	LW	BA5PT_E8,1|AMulti
	LW	BZ5PT_E8,5

	.long 0

*************************************
*			            *
*  Facing away standing sentry      *
*			            *
*************************************
B5_STND_INIT:
	.byte	4,0,0,1
	.long	P_GXBEE
	.word	OID_BEEKPR,OM_COLL
	.long	BEEK_CVECT
	LWWWW	BL5ST_E1,DMAWNZ,0,0,OM_ANIM|OM_GUNV|OM_CFUNC
	.long	BEEK_GUNVECT
	.long	B5_STND_ANIM
	.long	C_SET_BID
	.word	BID_STND5
	LWWWW	BH5ST_E1,DMAWNZ,0,-1,OM_PRVGUNV
	LWWWW	BT5ST_E1,DMAWNZ,0,0,OM_PRVGUNV
	LWWWW	BA5SH_A2,DMAWNZ,M_NODISP,0,OM_PRVGUNV	; dummy

B5_STND_ANIM:
	LW	BL5ST_E1,1|AMulti
	LW	BH5ST_E1,1|AMulti
	LW	BT5ST_E1,60

	LW	1,1|AMulti
	LW	BH5ST_E2,1|AMulti
	LW	BT5ST_E2,15

	LW	1,1|AMulti
	LW	BH5ST_E1,1|AMulti
	LW	BT5ST_E1,90

	LW	1,1|AMulti
	LW	BH5ST_E3,1|AMulti
	LW	BT5ST_E3,30

	.long 0

*************************************
*			            *
*  Facing sideways standing sentry  *
*      (twists twd plyr)            *
*			            *
*************************************
B3_STND_INIT:
	.byte	4,0,0,1
	.long	P_GXBEE
	.word	OID_BEEKPR,OM_COLL
	.long	BEEK_CVECT
	LWWWW	BL3ST_C1,DMAWNZ,0,1,OM_ANIM|OM_GUNV|OM_CFUNC
	.long	BEEK_GUNVECT
	.long	B3_STND_ANIM
	.long	C_SET_BID
	.word	BID_STND3
	LWWWW	BH3ST_C1,DMAWNZ,0,-1,OM_PRVGUNV
	LWWWW	BT3ST_C1,DMAWNZ,0,0,OM_PRVGUNV
	LWWWW	BA3ST_C1,DMAWNZ,0,0,OM_PRVGUNV 

B3_STND_ANIM:
	LW	BL3ST_C1,1|AMulti
	LW	BH3ST_C1,1|AMulti
	LW	BT3ST_C1,1|AMulti
	LWL	BA3ST_C1,60|AFunc,OBJ_ON

	LW	BL3ST_C2,1|AMulti
	LW	BH3ST_C2,1|AMulti
	LW	BT3ST_C2,1|AMulti
	LW	BA3ST_C2,25

	.long	0



*************************************
*			            *
*  Facing sideways walking          *
*			            *
*************************************
B3_WALK_INIT:
	.byte	4,0,0,1
	.long	P_GXBEE
	.word	OID_BEEKPR,OM_COLL
	.long	BEEK_CVECT
	LWWWW	BL3WK_C1,DMAWNZ,0,0,OM_ANIM|OM_GUNV|OM_CFUNC
	.long	BEEK_GUNVECT
	.long	B3_WALK_ANIM
	.long	C_SET_BID
	.word	BID_WALK3
	LWWWW	BH3WK_C1,DMAWNZ,0,-1,OM_PRVGUNV
	LWWWW	BT3WK_C1,DMAWNZ,0,0,OM_PRVGUNV
	LWWWW	BA3PT_C1,DMAWNZ,M_NODISP,0,OM_PRVGUNV		; dummy

B3_WALK_ANIM:
	LW	BL3WK_C1,1|AMulti
	LW	BH3WK_C1,1|AMulti
	LW	BT3WK_C1,4

	LW	BL3WK_C2,1|AMulti
	LW	1,1|AMulti
	LW	BT3WK_C2,4

	LW	BL3WK_C3,1|AMulti
	LW	BH3WK_C4,1|AMulti
	LW	BT3WK_C3,4

	LW	BL3WK_C4,1|AMulti
	LW	1,1|AMulti
	LW	BT3WK_C4,4

	LW	BL3WK_C5,1|AMulti
	LW	1,1|AMulti
	LW	BT3WK_C5,4

	LW	BL3WK_C6,1|AMulti
	LW	1,1|AMulti
	LW	BT3WK_C6,4

	LW	BL3WK_C7,1|AMulti
	LW	BH3WK_C9,1|AMulti
	LW	BT3WK_C7,4

	LW	BL3WK_C8,1|AMulti
	LW	1,1|AMulti
	LW	BT3WK_C8,4

	LW	BL3WK_C9,1|AMulti
	LW	1,1|AMulti
	LW	BT3WK_C9,4

	LW	BL3WK_C10,1|AMulti
	LW	BH3WK_C1,1|AMulti
	LW	BT3WK_C10,4

	.long	0

*************************************
*			            *
*  Facing sideways pushing buttons  *
*			            *
*************************************
B3_BUTN_INIT:
	.byte	5,0,0,1
	.long	P_GXBEE
	.word	OID_BEEKPR,OM_COLL
	.long	BEEK_CVECT
	LWWWW	BL3ST_C1,DMAWNZ,0,1,OM_ANIM|OM_GUNV|OM_CFUNC
	.long	BEEK_GUNVECT
	.long	B3_BUTN_ANIM
	.long	C_SET_BID
	.word	BID_BUTN3
	LWWWW	BH3WK_C1,DMAWNZ,0,-1,OM_PRVGUNV
	LWWWW	BT3PT_C1,DMAWNZ,0,0,OM_PRVGUNV
	LWWWW	BA3PT_C1,DMAWNZ,0,0,OM_PRVGUNV
	LWWWW	BZ3PT_C1,DMAWNZ,0,0,OM_PRVGUNV

B3_BUTN_ANIM:
	LW	BL3ST_C1,1|AMulti
	LW	BH3WK_C1,1|AMulti
	LW	BT3PT_C1,1|AMulti
	LWL	BA3PT_C1,1|AMulti|AFunc,OBJ_ON
	LWL	BZ3PT_C1,4|AFunc,OBJ_ON

	LW	1,1|AMulti
	LW	1,1|AMulti
	LW	BT3PT_C2,1|AMulti
	LW	BA3PT_C2,1|AMulti
	LWL	1,4|AFunc,OBJ_OFF

	LW	1,1|AMulti
	LW	BH3WK_C4,1|AMulti
	LW	BT3PT_C3,1|AMulti
	LW	BA3PT_C3,1|AMulti
	LWL	BZ3PT_C3,4|AFunc,OBJ_ON

	LW	1,1|AMulti
	LW	1,1|AMulti
	LW	BT3PT_C4,1|AMulti
	LW	BA3PT_C4,1|AMulti
	LWL	1,4|AFunc,OBJ_OFF

	LW	1,1|AMulti
	LW	BH3PT_C8,1|AMulti
	LW	BT3PT_C5,1|AMulti
	LW	BA3PT_C5,1|AMulti
	LW	1,4

	LW	1,1|AMulti
	LW	1,1|AMulti
	LW	BT3PT_C6,1|AMulti
	LW	BA3PT_C6,1|AMulti
	LWL	BZ3PT_C6,4|AFunc,OBJ_ON

	LW	1,1|AMulti
	LW	BH3PT_C10,1|AMulti
	LW	BT3PT_C7,1|AMulti
	LW	BA3PT_C7,1|AMulti
	LW	BZ3PT_C7,4

	LW	1,1|AMulti
	LW	1,1|AMulti
	LW	BT3PT_C8,1|AMulti
	LW	BA3PT_C8,1|AMulti
	LWL	1,4|AFunc,OBJ_OFF

	LW	1,1|AMulti
	LW	BH3PT_C8,1|AMulti
	LW	BT3PT_C9,1|AMulti
	LW	BA3PT_C9,1|AMulti
	LWL	BZ3PT_C9,4|AFunc,OBJ_ON

	LW	1,1|AMulti
	LW	1,1|AMulti
	LW	BT3PT_C10,1|AMulti
	LW	BA3PT_C10,1|AMulti
	LW	BZ3PT_C10,4

	.long 0


*************************************
*			            *
*  Facing sideways carrying box     *
*			            *
*************************************

B3_BOX_INIT:
	.byte	5,0,0,1
	.long	P_GXBEE
	.word	OID_BEEKPR,OM_COLL
	.long	BEEK_CVECT
	LWWWW	BL3WKG_C7,DMAWNZ,0,0,OM_ANIM|OM_GUNV|OM_CFUNC
	.long	BEEK_GUNVECT
	.long	B3_BOX_ANIM
	.long	C_SET_BID
	.word	BID_BOX3
	LWWWW	BH3WKG_C7,DMAWNZ,0,-1,OM_PRVGUNV
	LWWWW	BT3WKG_C7,DMAWNZ,0,0,OM_PRVGUNV
	LWWWW	BA3WKG_C7,DMAWNZ,0,-5,OM_PRVGUNV   
	LWWWW	BZ3WKG_C7,DMAWNZ,0,0,OM_PRVGUNV   

B3_BOX_ANIM:
	LW	BL3WKG_C7,1|AMulti
	LW	BH3WKG_C7,1|AMulti
	LW	BT3WKG_C7,1|AMulti
	LWL	BA3WKG_C7,1|AMulti|AFunc,OBJ_ON
	LWL	BZ3WKG_C7,4|AFunc,OBJ_ON

	LW	BL3WKG_C8,1|AMulti
	LW	BH3WKG_C8,1|AMulti
	LW	BT3WKG_C8,1|AMulti
	LW	BA3WKG_C8,1|AMulti
	LW	BZ3WKG_C8,4

	LW	BL3WKG_C9,1|AMulti
	LW	BH3WKG_C9,1|AMulti
	LW	BT3WKG_C9,1|AMulti
	LW	BA3WKG_C9,1|AMulti
	LW	BZ3WKG_C9,4

	LW	BL3WKG_C1,1|AMulti
	LW	BH3WKG_C1,1|AMulti
	LW	BT3WKG_C1,1|AMulti
	LW	BA3WKG_C1,1|AMulti
	LW	BZ3WKG_C1,4

	LW	BL3WKG_C2,1|AMulti
	LW	BH3WKG_C2,1|AMulti
	LW	BT3WKG_C2,1|AMulti
	LW	BA3WKG_C2,1|AMulti
	LW	BZ3WKG_C2,4

	LW	BL3WKG_C3,1|AMulti
	LW	BH3WKG_C3,1|AMulti
	LW	BT3WKG_C3,1|AMulti
	LW	BA3WKG_C3,1|AMulti
	LW	BZ3WKG_C3,4
	
	LW	BL3WKG_C4,1|AMulti
	LW	BH3WKG_C4,1|AMulti
	LW	BT3WKG_C4,1|AMulti
	LW	BA3WKG_C4,1|AMulti
	LWL	1,4|AFunc,OBJ_OFF

	LW	BL3WKG_C5,1|AMulti
	LW	BH3WKG_C5,1|AMulti
	LW	BT3WKG_C5,1|AMulti
	LW	BA3WKG_C5,4

	LW	BL3WKG_C6,1|AMulti
	LW	BH3WKG_C6,1|AMulti
	LW	BT3WKG_C6,1|AMulti
	LW	BA3WKG_C6,4

	.long	0


B3_BOX_TURN_ANIM:
	LWL	BL3WKTR_E1,1|AMulti|AFunc,B_SAV_NEGXVEL
	LWL	BH3WKTR_E1,1|AMulti|AFunc,B_DROP_BOX
	LW	BT3WKTR_E1,1|AMulti
	LW	BA3WKTR_E1,1|AMulti
	LWL	1,4|AFunc,OBJ_OFF

	LWL	BL3WKTR_E2,1|AMulti|AFunc,B_Adj_Z_For_Turn
	LW	BH3WKTR_E2,1|AMulti
	LW	BT3WKTR_E2,1|AMulti
	LWL	1,4|AFunc,OBJ_OFF

	LWLW	BL5WKG_E5,1|AMulti|AFunc,A_TOGGLE_FLPS+1,M_FLIPH
	LW	BH5WKG_E5,1|AMulti
	LW	BT5WKG_E5,4

	LW	BL3WKTR_E2,1|AMulti
	LW	BH3WKTR_E2,1|AMulti
	LW	BT3WKTR_E2,4

	LWL	1,3|AFunc,B_RST_XVEL

	LW	BL3WKTR_E1,1|AMulti
	LWLL	BH3WKTR_E1,1|AMulti|AFunc,A_SET_GUNVECT+2,BEEK_GUNVECT
	LW   	BT3WKTR_E1,1|AMulti
;;;;	LWLW   	BT3WKTR_E1,1|AMulti|AFunc,B_GEN_BOX+1,M_FLIPH
	LWL	BA3WKTR_E1,1|AFunc,OBJ_ON

	LWLL	1,1|AFunc,A_AnimGo+2,B3_BOX_ANIM


*
*	push or pull in Z during turn
*	a8 = side beekeeper head object
*
B_Adj_Z_For_Turn:
	movi	80h,a14			; sign of delta is based on direction
	move	*a8(BSVXVEL),a1,L	; check vel
	jrnn	BAZ
	neg	a14
BAZ:
	move	a8,a0
BZTlp:
	move	*a0(OZVAL),a1,L
	add	a14,a1
	move	a1,*a0(OZVAL),L
	move	*a0(OPARTS),a0,L
	jrnz	BZTlp
	rets


*
*	Drop a carried box if my flip bit = the supplied argument
*
B_DROP_BOX:
	move	@DROP_STATE,a0		; state in which to drop	
	move	*a8(OCTRL),a14
	andi	M_FLIPH,a14
	cmp	a14,a0
	jrne	Delete_Boxer
	move	*a8(OPART1),a10,L	; get head of beek
	move	*a10(OBOXLINK),a0,L	; head of box in a0
	jrz	Dnodoit
	CLRM	*a10(OBOXLINK),L	; clear boxer link
	move	a14,*a0(OBOXLINK),L	; clear box link

	MOVIM	3000h,*a0(OYACCEL),W
	MOVIM	-6000h,*a0(OYVEL),L
	MOVIM	BOX_ONTO_BELT,*a0(BOX_ROUT),L

Dnodoit:
	rets

Delete_Boxer:
	move	@NUM_OUT_THERE,a14
	dec	a14
	move	a14,@NUM_OUT_THERE
	move	*a8(OPART1),a8,L
	move	a8,a9
	callr	KILL_TURN_PROC
;	calla	DELETE_OBJ
	calla	DEL_ENEMY_NOAUD
	rets

*
*
*	GENERATE A BOX as if a beek was carrying it, but he ain't needed
*
*	a9 = start X
*	a10 = left lim, right lim
*	a11 = start X VEL
*
GEN_BOX_ONLY:
	mmtm	sp,a8,a10
	movi	BOX_INIT,b0	; A box is three parts
	calla	MULTIMAKE
	jrz	Gnodoit

	CLRM	*a8(OBOXLINK),L		; no xlink

	movi	SIM_CARRY_LFT,a14
	move	a11,a11
	jrnn	inlft
	rl	16,a10
	movi	SIM_CARRY_RT,a14
inlft:
	move	a14,*a8(BOX_ROUT),L ; simulate being carried by beek

	CREATE	PID_IND,MON_BOX_PROC
	move	a0,*a8(OPLINK),L
	move	a10,*a0(PDATA+40h)	; keep limit in process

	move	a11,*a8(OXVEL),L	; let box move
	move	*a12,a3,1	; start Z
	move	@YWORLD,a4,L	; start Y
	move	a9,a5		; start X
	jruc	GenBoxHk

*
*	Generate a box to carry if my flip bit = the supplied argument
*
B_GEN_BOX:
	calla	GETAFARG_WORD
	move	*a8(OCTRL),a14
	andi	M_FLIPH,a14
	cmp	a14,a0
	jrne	Gnodoit
	move	*a8(OBOXLINK),a0,L
	jrnz	Gnodoit
B_GEN_BOX_1:
	mmtm	sp,a8,a10
	move	*a8(OPART1),a10,L
	movi	BOX_INIT,b0	; A box is three parts
	calla	MULTIMAKE
	jrz	Gnodoit

	CREATE	PID_IND,MON_BOX_PROC
	move	a0,*a8(OPLINK),L

	move	a10,*a8(OBOXLINK),L	; xlink boxer and box
	move	a8,*a10(OBOXLINK),L
	clr	a14
	move	a14,*a8(BOX_ROUT),L	; no special box processing while being
					; carried by beekeeper
	move	*a10(OXVEL),*a8(OXVEL),L	; let box move
	move	*a10(OCTRL),a14
	movi	56<<15,a6
	btst	B_FLIPH,a14
	jrz	noflpbox
	neg	a6
noflpbox:

	addi	OXVAL,a10	; Set Box position
	mmfm	a10,a3,a4,a5	; boxer position
	add	a6,a5		; X adj
GenBoxHk:
	subk	3,a3		; Z adj
	subi	74<<15,a4	; Y adj
	move	a8,a0
set_box_pos_lp:
	move	a0,a2
	addi	OZVAL+20h,a2
	mmtm	a2,a3,a4,a5
	move	*a0(OPARTS),a0,L
	jrnz	set_box_pos_lp

	calla	INSERT_OBJ

	clr	a14
	move	a14,*a8(BHITS)
	move	a14,*a8(OATEROCKET)

	mmfm	sp,a8,a10
Gnodoit:
	rets

BOX_INIT
	.byte	3,0,0,2
	.long	CLOBOXF_P,CLOBXST_P
	.word	OID_DESK,0
	LWWWW	CLOBOXFRONT,DMAWNZ,0,0,OM_GUNV|OM_COLL
	.long	CLOBX_CVECT
	.long	CLOBX_GUNVECT
	LWWWW	BOXSIDA2,DMAWNZ,0,1,0
	LWWWW	BOXTOPC,DMAWNZ,0,1,0
	

CLOBX_CVECT:
	WWL	OID_PROCKET,~MASK_PLAYER,BEEK_ROCKET_COLL
	WWL	OID_PEXPLOSION,~MASK_PLAYER,CLOBX_COLL
;	WWL	OID_BLOWUP,0FFFFH,BEEK_SBOMB_COLLVECT
;	WWL	OID_GRND,0FFFFH,BEEK_GRND_COLLVECT
	WL	0,DUMCRETS



CLOBX_COLL
	MOVE	*A0(OID),A0,W		;GET PLAYER DATA ADDRESS
	CALLA	POID_TO_PDATA		;GET PDATA IN A2
	MOVE	*A8(OATEROCKET),A14,W	;Did he get hit by a rocket?
	JRNZ	CLOBX_hk		;BR = YES
	rets

CLOBX_hk:
	PUSH	a0
	move	*a8(OPARTS),a0,L	; second part
CLOBX_lp:
	move	*a0(OPARTS),a3,L	; REMOVE all but head part
	calla	PULLPART
	calla	DELOBJ
	move	a3,a0
	jrnz	CLOBX_lp

	CLRM	*a8(OPART1),L	; head is not a multi no more

	CALLA	COLLS_OFF		;Turn collisions off now!
	movi	OID_JUNK,a1	
	calla	CHANGE_OID	

	MOVI	3000,A1
	CALLA	SCORE			;Explosions are always good for points

	MMTM	SP,B1,B2,B4,B5,B6,B8,B9,B10

	move	*a8(OZVAL),a0,L
	move	@ZBASE,a14,L
	sub	a14,a0		; world Z
	cmpi	018000h,a0
	jrgt	nofrags		; no frags if too far away

	MOVI	030000H,A0
	MOVI	07FH,A3
	CALLA	PreFrag_Box
	MOVI	FRG_BOX_8,B14
	clr	b10		; shoot towards player only
	CALLA	Fragger
	MOVE	*A8(OIMG),A1,L
	MOVE	*A1(ICMAP),*A0(FPDATA),L	;SET PALETTE

nofrags:
	move	*a8(OATEROCKET),a14		; no power up for a blowup
	jrnz	nopowerup

	movk	16,a0
	callA	RAND0
	sll	5,a0
	addi	BOX_POWER_TAB,a0
	move	*a0,a0,L
	call	a0			; call a routine to attach something
nopowerup:

	MMFM	SP,B1,B2,B4,B5,B6,B8,B9,B10

	move	*a8(BOX_ROUT),a14,L
	cmpi	BOX_TIMEOUT,a14
	jrne	gotamission
*
*	If box is waiting to time out anyway, give more time
*
	MOVIM	400,*a8(BTIME),W		; increase timer
gotamission:
	move	*a8(OCTRL),a4,W	     
	movi	CLOBOXDAM,a1
	calla	ANI
	calla	SET_SCALE_WARREN
	calla	SET_ODAG

	PULLQ	a0	   
 	rets


CLOBX_GUNVECT:
	move	*a8(BHITS),a14		; hit count
	inc	a14
	move	a14,*a8(BHITS)
	cmpk	8,a14
	jrge	CLOBX_hk
	rets

****************************************************************
*
*                 STUFF IN BOXES
*
****************************************************************



BOX_POWER_TAB:			; 16 entries
	.long	ATTACH_1_CD,ATTACH_1_ROCKET
	.long	ATTACH_1_CD,ATTACH_2_ROCKETS
	.long	ATTACH_1_CD,ATTACH_3_ROCKETS
	.long	ATTACH_1_CD,ATTACH_1_ROCKET
	.long	ATTACH_1_CD,ATTACH_2_ROCKETS
	.long	ATTACH_1_CD,ATTACH_3_ROCKETS
	.long	ATTACH_1_CD,ATTACH_1_ROCKET
	.long	ATTACH_1_CD,ATTACH_3_ROCKETS


ATTACH_3_ROCKETS:
	movi	[-30,12],a10
	clr	a11
	CREATE	PID_IND,ATTACH_PROCK
	movi	[-30,-12],a10
	clr	a11
	CREATE	PID_IND,ATTACH_PROCK
	movi	[-45,0],a10
	clr	a11
	CREATE	PID_IND,ATTACH_PROCK
	rets


ATTACH_2_ROCKETS:
	movi	[-35,10],a10
	clr	a11
	CREATE	PID_IND,ATTACH_PROCK
	movi	[-35,-10],a10
	clr	a11
	CREATE	PID_IND,ATTACH_PROCK
	rets


ATTACH_1_ROCKET:
	movi	[-35,0],a10
	clr	a11
	CREATE	PID_IND,ATTACH_PROCK
	rets

ATTACH_1_CD:
	movi	[-40,0],a10
	clr	a11
	CREATE	PID_IND,ATTACH_CD
	rets



*
*	This process monitors the box position so its side and top
*	match its position in the world. Then calls a variable BOX
*	monitoring routine stored in the BOX object block.
*
MON_BOX_PROC:
	move	*a8(OPARTS),a5,L	; 2nd part (side)
	move	*a5(OPARTS),a6,L	; 3rd part (top)
	movi	BOXSIDA2,a9
	movi	BOXTOPC,a10
	move	a5,*a13(PDATA+60h),L
	move	a6,*a13(PDATA+80h),L

*
* 	a8 = box obj (head)
* 	a9 = current side img (0 if none)
* 	a10 = current top img (0 if none)
*	a11 becomes ZREL_OFF adjusted to lo-res
*
MON_BOX_lp:
	move	*a8(OCVECT),a14,L
	jrz	noperschk
	callr	CHECK_BOX_PERS		; check box perspective
noperschk:
	move	*a8(BOX_ROUT),a0,L	; get current task
	jrz	BOX_RET			; skip if none
	jump	a0			; execute box task

BOX_RET:
	sloop	3,MON_BOX_lp


SIDATAB	.long	0,BOXSIDA2,BOXSIDA4,BOXSIDA6,BOXSIDA8,BOXSIDA10,BOXSIDA12
SIDBTAB	.long	0,BOXSIDB2,BOXSIDB4,BOXSIDB6,BOXSIDB8,BOXSIDB10,BOXSIDB12
SIDCTAB	.long	0,BOXSIDC1,BOXSIDC3,BOXSIDC5,BOXSIDC7,BOXSIDC9,BOXSIDC11
TOPCTAB	.long	BOXTOPC,BOXTOPC1,BOXTOPC3,BOXTOPC5,BOXTOPC7,BOXTOPC9,BOXTOPC11

*
*	This routine monitors a box's world position and adjusts
*	its top and side accordingly
*
CHECK_BOX_PERS:
	move	*a8(OIHOFF),a14
	jrz	ihok
;	cmpi	IHDRSIZ,a14
;	jrle	ihok
	clr	a1     		; if IHOFF too big, automatically no side
	clr	a2		; or top
	jruc	no_top2

ihok:
	move	*a8(OYPOS),a14
	subi	1dh,a14
	jrn	no_top
	movi	TOPCTAB,a4
	movi	SIDCTAB,a7
	jruc	check_X

no_top:
	clr	a4		; no top table
	movi	SIDATAB,a7	; assume A height
	addk	10h,a14
	jrn	check_X
	movi	SIDBTAB,a7
check_X:

	move	*a8(OXVAL),a14,L
	move	@XBASE,a0,L
	sub	a0,a14		; world X in a14
	movi	20h,a2
	clr	a0		; index
	sra	16,a14
	move	a14,a1		; integer world X in a14 and a1
	abs	a1		; abs value of world X in a1
	subi	10h,a1		; check for index 0 first
	jrn	gotX
Xlp:
	inc	a0
	cmpk	6,a0
	jreq	gotX
	sub	a2,a1
	jrnn	Xlp
gotX:
	clr	a1		; assume no top image
	neg	a14		; flip sign bit
     	srl	31,a14		; sign bit in bit 0 position
	sll	B_FLIPH,a14	; flip bit isolated in a14
	sll	5,a0
	add	a0,a7		; get table pointer in a5
	move	*a7,a2,L	; side image in a2
	move	a4,a4
	jrz	no_top2
	add	a0,a4
	move	*a4,a1,L	;top image in a1
no_top2:
	cmp	a1,a10		; has top changed?
	jreq	notopchg
	move	a1,a10		; record new top image
	jrz	no_top3
*
*	There is a top image and it's in a1
*	
	move	a8,a6
	move	*a13(PDATA+80h),a8,L
	PUSHW	a14
	movi	DMAWNZ,a4
	or	a14,a4
	calla	ANI   
	calla	SET_SCALE_WARREN
	move	*a8(OFLAGS),a14
	andni	M_NODISP,a14
	move	a14,*a8(OFLAGS)
	PULLW	a14
	move	a6,a8
	jruc	topchghk
*
*	There is no top image, but there was before
*	
no_top3:
	move	*a13(PDATA+80h),a6,L
	move	*a6(OFLAGS),a1
	ori	M_NODISP,a1
	move	a1,*a6(OFLAGS)
topchghk:

notopchg:
	cmp	a2,a9		; has side changed?
	jreq	nosidchg
	move	a2,a9
	jrz	no_sid
*
*	There is a side image and it's in a2
*	
	move	a8,a6
	move	*a13(PDATA+60h),a8,L
	movi	DMAWNZ,a4
	or	a14,a4
	move	a2,a1
	calla	ANI
	calla	SET_SCALE_WARREN
	move	*a8(OFLAGS),a1
	andni	M_NODISP,a1
	move	a1,*a8(OFLAGS)
	move	a6,a8
	jruc	sidchghk
*
*	There is no side image, but there was before
*	
no_sid:
	move	*a13(PDATA+60h),a6,L
	move	*a6(OFLAGS),a1
	ori	M_NODISP,a1
	move	a1,*a6(OFLAGS)
sidchghk:

nosidchg:
	rets


*
*	a10 = limit
*
SIM_CARRY_RT	     			; in right chamber
	move	*a8(OXPOS),a0,W
	move	*a13(PDATA+40h),a1	; limit
	cmp	a1,a0
	jrge	SC_drop
	jruc	BOX_RET

SIM_CARRY_LFT	     			; in left chamber
	move	*a8(OXPOS),a0,W
	move	*a13(PDATA+40h),a1	; limit
	cmp	a1,a0
	jrge	BOX_RET
SC_drop:
	MOVIM	3000h,*a8(OYACCEL),W
	MOVIM	-6000h,*a8(OYVEL),L
	MOVIM	BOX_ONTO_BELT,*a8(BOX_ROUT),L
	jruc	BOX_RET


*
*	After beekeeper drops box, it falls onto conveyor belt
*
BOX_ONTO_BELT:
	movk	7,a14			; desired YPOS
	move	*a8(OYPOS),a0,W
	cmp	a14,a0
	jrle	BOX_RET
	sll	16,a14
	move	a14,*a8(OYVAL),L
	move	*a8(OPARTS),a0,L
	move	a14,*a0(OYVAL),L	; store Y for part2
	move	*a0(OPARTS),a0,L	
	move	a14,*a0(OYVAL),L	; store Y for part3
	clr	a14
	move	a14,*a8(OXVEL),L	; stop box from moving
	move	a14,*a8(OYVEL),L
	move	a14,*a8(OYACCEL),W
	move	@DROP_STATE,a14
	jrz	left_side

	MOVIM	-10000h,*a8(OXVEL),L
	MOVIM	BOX_ON_LEG0,*a8(BOX_ROUT),L
	jruc	BOX_RET		; all BOX_ROUTs need to end this way


left_side:
	movi	70h,a14
	move	a14,*a8(OZVEL),L	; start off in Z
	move	@ZREL_OFF,a11,L
	sra	ZFRAC,a11
	MOVIM	BOX_ON_LEGL1,*a8(BOX_ROUT),L
	jruc	BOX_RET
	
BOX_ON_LEGL1:
	move	*a8(OZVAL),a0,L
	sub	a11,a0			; get relative to this univ.
	cmpi	-0de00h,a0
	jrle	BOX_RET
	clr	a0		; index of dropper
	calla	DO_SCHMOOTZ
	MOVIM	BOX_ON_LEGL2,*a8(BOX_ROUT),L
	jruc	BOX_RET		; all BOX_ROUTs need to end this way

*
*	Box is going into distance waiting for turn
*
BOX_ON_LEGL2:
	move	*a8(OZVAL),a0,L
	sub	a11,a0			; get relative to this univ.
	cmpi	-7b68h,a0
	jrle	BOX_RET
	CLRM	*a8(OZVEL),L
	MOVIM	10000h,*a8(OXVEL),L
	MOVIM	BOX_ON_LEGL3,*a8(BOX_ROUT),L
	jruc	BOX_RET		; all BOX_ROUTs need to end this way


BOX_ON_LEGL3:
	move	*a8(OXPOS),a0,W
	move	@IN_SECRET,a14
	jrz	lfarther
	cmpi	1beh,a0		; cut off sooner if in secret room
	jrgt	BOX_DIE

lfarther:
	cmpi	298h,a0
	jrle	BOX_RET
	jruc	BOX_DIE

*
*	Box is going left waiting for spritz 1
*
BOX_ON_LEG0:
	move	*a8(OXPOS),a0
	cmpi	648h,a0
	jrge	BOX_RET
	clr	a0		; index of dropper
	calla	DO_SCHMOOTZ
	MOVIM	BOX_ON_LEG1,*a8(BOX_ROUT),L
	jruc	BOX_RET		; all BOX_ROUTs need to end this way



*
*	Box is going left waiting for a certain X
*
BOX_ON_LEG1:
	move	*a8(OXPOS),a0
	cmpi	59ah,a0
	jrge	BOX_RET
	CLRM	*a8(OXVEL),L
	movi	70h,a14
	move	a14,*a8(OZVEL),L	; start off in Z
	move	@ZREL_OFF,a11,L
	sra	ZFRAC,a11
	MOVIM	BOX_ON_LEG1A,*a8(BOX_ROUT),L
	jruc	BOX_RET


*
*	Box is going into distance waiting for spritz
*
BOX_ON_LEG1A:
	move	*a8(OZVAL),a0,L
	sub	a11,a0			; get relative to this univ.
	cmpi	-12F40h,a0
	jrle	BOX_RET
	movk	1,a0		; index of dropper
	calla	DO_SCHMOOTZ
	MOVIM	BOX_ON_LEG1B,*a8(BOX_ROUT),L
	jruc	BOX_RET		; all BOX_ROUTs need to end this way


*
*	Box is going into distance waiting for turn
*
BOX_ON_LEG1B:
	move	*a8(OZVAL),a0,L
	sub	a11,a0			; get relative to this univ.
	cmpi	-7b68h,a0
	jrle	BOX_RET
	CLRM	*a8(OZVEL),L
	MOVIM	-10000h,*a8(OXVEL),L
	MOVIM	BOX_ON_LEG2A,*a8(BOX_ROUT),L
	jruc	BOX_RET		; all BOX_ROUTs need to end this way


*
*	Box is going left waiting for spritz 
*
BOX_ON_LEG2A:
	move	*a8(OXPOS),a0
	cmpi	518h,a0	     
	jrge	BOX_RET
	movk	2,a0		; index of dropper
	calla	DO_SCHMOOTZ
	MOVIM	BOX_ON_LEG2,*a8(BOX_ROUT),L
	jruc	BOX_RET		; all BOX_ROUTs need to end this way


BOX_TIMEOUT:
	move	*a8(BTIME),a0
	subk	3,a0
	move	a0,*a8(BTIME)
	jrle	BOX_DIE
	jruc	BOX_RET


BOX_ON_LEG2:
	move	*a8(OXPOS),a0,W
	move	@IN_SECRET,a14
	jrz	farther
	cmpi	460h,a0		; cut off sooner if in secret room
	jrlt	BOX_DIE

farther:
	cmpi	400h,a0
	jrge	BOX_RET
*
*	Box may have a powerup (with a process) attached.
*	Check for that and clear those processes before deleting
*
BOX_DIE:
	CLRM	*a8(OPLINK),L		; box is off, we're going to die
	move	*a8(OPART1),a1,L
	jrz	not_multi
BxDieLp:
	move	*a1(OPLINK),a0,L
	jrz	BxDieNxt
	move	a14,*a1(OPLINK),L
	calla	KILL			; if there is a process, kill it
BxDieNxt:
	move	*a1(OPARTS),a1,L
	jrnz	BxDieLp

not_multi:
	calla	DELETE_OBJ
	DIE





BOX_FALL:
	move	*a8(OYVAL),a14,L
	move	a14,a1
	subi	2a0000h,a14
	jrlt	BOX_RET
	sub	a14,a1
	move	a1,*a8(OYVAL),L
	move	*a8(OPARTS),a0,L
	jrz	noparts
nxtpart:
	move	*a0(OYVAL),a1,L
	sub	a14,a1
	move	a1,*a0(OYVAL),L		; store Y for next
	move	*a0(OPARTS),a0,L
	jrnz	nxtpart
noparts:
	clr	a14
	move	a14,*a8(OZVEL),L 
	move	a14,*a8(OXVEL),L	; stop box from moving
	move	a14,*a8(OYVEL),L
	move	a14,*a8(OYACCEL),W
	MOVIM	400,*a8(BTIME),W		; becomes timer
	MOVIM	BOX_TIMEOUT,*a8(BOX_ROUT),L
	jruc	BOX_RET		; all BOX_ROUTs need to end this way


*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
*
*	Transition/shooting animations, helmeted
*
*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
BSHT_X5:				; when 5 objs created
	LW	BL5SH_A1,1|AMulti
	LW	BH5SH_A1,1|AMulti
	LW	BT5SH_A1,1|AMulti
	LWL	1,1|AMulti|AFunc,OBJ_OFF
	LWL	1,3|AFunc,OBJ_OFF

	LWLL	1,1|AFunc,A_AnimGo+2,bsht_x5hk


BSHT_X5A:				; when 4 objs created
	LW	BL5SH_A1,1|AMulti
	LW	BH5SH_A1,1|AMulti
	LW	BT5SH_A1,1|AMulti
	LWL	1,3|AFunc,OBJ_OFF

bsht_x5hk:

	LW	BL5SH_A2,1|AMulti
	LW	BH5SH_A2,1|AMulti
	LW	BT5SH_A2,1|AMulti
	LWL	BA5SH_A2,3|AFunc,OBJ_ON

	LW	BL5SH_A3,1|AMulti
	LW	BH5SH_A3,1|AMulti
	LW	BT5SH_A3,1|AMulti
	LW	BA5SH_A3,3

	LW	BL5SH_A4,1|AMulti
	LW	BH5SH_A4,1|AMulti
	LW	BT5SH_A4,1|AMulti
	LWL	1,3|AFunc,OBJ_OFF

	LW	BL1SH_A1,1|AMulti
	LW	BH1SH_A1,1|AMulti
	LW	BT1SH_A1,1|AMulti
	LWL	1,2|AFunc,OBJ_OFF

	LWLL	1,1|AFunc,A_AnimGo+2,B1_SHOOT

BSHT_X1:
	LW	BL1SH_A1,1|AMulti
	LW	BH1SH_A1,1|AMulti
	LW	BT1SH_A1,1|AMulti
	LWL	1,1|AMulti|AFunc,OBJ_OFF
	LWL	1,3|AFunc,OBJ_OFF

	LWL	1,1|AFunc,A_Set_LOOP_STRT

B1_SHOOT:
	LW	BL1SH_A2,1|AMulti
	LWLWW	BH1SH_A2,1|AMulti|AFunc,A_CHK_FIRE_FNC+2,-14,-81 
	LW	BT1SH_A2,3
	
	LW	1,1|AMulti
	LW	BH1SH_A3,1|AMulti
	LW	BT1SH_A3,3

	LW	BL1SH_A2,1|AMulti
	LW	BH1SH_A2,1|AMulti
	LW	BT1SH_A2,2

	LWL	1,1|AFunc,A_STAY_TIL_ONSCRN	; no shoot if off
	
	LW	1,1|AMulti
	LW	BH1SH_A3,1|AMulti
	LW	BT1SH_A3,3
	.long	0	


BSHT_XB1:
	LW	BL1SH_A1,1|AMulti
	LW	BH1SH_A1,1|AMulti
	LW	BT1SH_A1,1|AMulti
	LWL	1,1|AMulti|AFunc,OBJ_ON
	LWL	1,3|AFunc,OBJ_ON

	LWL	1,1|AFunc,A_SELECT_BK_ANIM


BSHT_XB5:
	LW	BL1SH_A1,1|AMulti
	LW	BH1SH_A1,1|AMulti
	LW	BT1SH_A1,2

	LW	BL5SH_A4,1|AMulti
	LW	BH5SH_A4,1|AMulti
	LW	BT5SH_A4,2

	LW	BL5SH_A3,1|AMulti
	LW	BH5SH_A3,1|AMulti
	LW	BT5SH_A3,1|AMulti
	LWL	BA5SH_A3,2|AFunc,OBJ_ON

	LW	BL5SH_A2,1|AMulti
	LW	BH5SH_A2,1|AMulti
	LW	BT5SH_A2,1|AMulti
	LW	BA5SH_A2,2

	LW	BL5SH_A1,1|AMulti
	LW	BH5SH_A1,1|AMulti
	LW	BT5SH_A1,1|AMulti
	LWL	1,2|AFunc,OBJ_OFF

	LWL	1,1|AFunc,A_SELECT_BK_ANIM


B_SAV_XVEL:
	move	*a8(OXVEL),a14,L
	jrz	negSVXVEL
	move	a14,*a8(BSVXVEL),L
	clr	a14
	move	a14,*a8(OXVEL),L
	rets

negSVXVEL:
	neg	a14
	move	a14,*a8(BSVXVEL),L
	rets

B_SAV_NEGXVEL:
	move	*a8(OXVEL),a14,L
	neg	a14
	move	a14,*a8(BSVXVEL),L
	clr	a14
	move	a14,*a8(OXVEL),L
	rets

B_RST_XVEL:
	move	*a8(BSVXVEL),*a8(OXVEL),L
	rets


BSHT_X3:				; when 5 objs created
	LW	BL3SH_A1,1|AMulti
	LW	BH3SH_A1,1|AMulti
	LW	BT3SH_A1,1|AMulti
	LWL	1,1|AMulti|AFunc,OBJ_OFF
	LWL	1,2|AFunc,OBJ_OFF

	LWLL	1,1|AFunc,A_AnimGo+2,bsht_x3hk


BSHT_X3A:				; when 4 objs created
	LW	BL3SH_A1,1|AMulti
	LW	BH3SH_A1,1|AMulti
	LW	BT3SH_A1,1|AMulti
	LWL	1,3|AFunc,OBJ_OFF

bsht_x3hk:	
	LWL	BL3SH_A2,1|AMulti|AFunc,B_SAV_XVEL
	LW	BH3SH_A2,1|AMulti
	LW	BT3SH_A2,1|AMulti
	LWL	BA3SH_A2,3|AFunc,OBJ_ON

	LW	BL3SH_A3,1|AMulti
	LW	BH3SH_A3,1|AMulti
	LW	BT3SH_A3,1|AMulti
	LW	BA3SH_A3,3

	LW	BL3SH_A4,1|AMulti
	LW	BH3SH_A4,1|AMulti
	LW	BT3SH_A4,1|AMulti
	LW	BA3SH_A4,3

	LW	BL3SH_A5,1|AMulti
	LW	BH3SH_A5,1|AMulti
	LW	BT3SH_A5,1|AMulti
	LWL	1,2|AFunc,OBJ_OFF

	LWL	1,1|AFunc,A_Set_LOOP_STRT


B3_SHOOT:
	LW	BL3SH_A6,1|AMulti
	LWLWW	BH3SH_A6,1|AMulti|AFunc,A_CHK_FIRE_FNC+2,-14,-94
	LW	BT3SH_A6,3
	
	LW	1,1|AMulti
	LW	BH3SH_A7,1|AMulti
	LW	BT3SH_A7,3

	LW	BL3SH_A6,1|AMulti
	LW	BH3SH_A6,1|AMulti
	LW	BT3SH_A6,3
	
	LW	1,1|AMulti
	LW	BH3SH_A7,1|AMulti
	LW	BT3SH_A7,3

	.long	0	


BSHT_XB3:
	LW	BL3SH_A5,1|AMulti
	LW	BH3SH_A5,1|AMulti
	LW	BT3SH_A5,1|AMulti
	LWL	1,3|AFunc,OBJ_OFF

	LW	BL3SH_A4,1|AMulti
	LW	BH3SH_A4,1|AMulti
	LW	BT3SH_A4,1|AMulti
	LWL	BA3SH_A4,3|AFunc,OBJ_ON

	LW	BL3SH_A3,1|AMulti
	LW	BH3SH_A3,1|AMulti
	LW	BT3SH_A3,1|AMulti
	LW	BA3SH_A3,3
	
	LW	BL3SH_A2,1|AMulti
	LW	BH3SH_A2,1|AMulti
	LW	BT3SH_A2,1|AMulti
	LW	BA3SH_A2,3

	LWL	BL3SH_A1,1|AMulti|AFunc,B_RST_XVEL
	LW	BH3SH_A1,1|AMulti
	LW	BT3SH_A1,1|AMulti
	LWL	1,1|AFunc,OBJ_OFF

	LWL	1,1|AFunc,A_SELECT_BK_ANIM



A_SET_GUNVECT:
	calla	GETAFARG_LONG
SET_GUNVECT:
	move	*a8(OPART1),a1,L
SGlp:
	move	a0,*a1(OGUNVECT),L
	move	*a1(OPARTS),a1,L
	jrnz	SGlp
	rets


A_SET_CVECT:
	calla	GETAFARG_LONG
SET_CVECT:
	move	*a8(OPART1),a1,L
SClp:
	move	a0,*a1(OCVECT),L
	move	*a1(OPARTS),a1,L
	jrnz	SClp
	rets


A_CHK_FIRE_FNC:
	move	*a8(OFLAGS),a14		; skip shoot if off screen
	btst	B_OFSCRN,a14
	jaz	A_PART_FIRE_FNC
	rets


**************************************************************************
*								         *
* A_OFFSCRN_DELENEMY - ANIM FUNC TO DELETE AN OBJ IF ITS OFSCRN BIT IS SET	 *
* 	                 						 *
* A8 = PTR TO AN OBJ							 *
*								         *
**************************************************************************
A_OFFSCRN_DELENEMY
	move	*a8(OPART1),a0,L	; multi?
	jrnz	aof_multi
	move	*a8(OFLAGS),a14
	btst	B_OFSCRN,a14
	janz	DELETE_ENEMY
aofX:
	RETS

aof_multi:
	move	*a0(OFLAGS),a14
	btst	B_OFSCRN,a14
	jrz	aofX			; don't delete if any part onscreen
	move	*a0(OPARTS),a0,L
	jrnz	aof_multi
	move	*a8(OPART1),a8,L	; multi?
	jauc	DELETE_ENEMY



	.if 0			; FOOD IS OUT!

FOOD_TAB:
	.long	BURG_INIT,HOTD_INIT,FRIE_INIT,BURG_INIT


*
*	Put 3 pcs of food in a box to be shot
*
ATTACH_FOOD:
	movi	[-35,10],a5
	callr	ATTACH_1_FOOD
	movi	[-35,-10],a5
	callr	ATTACH_1_FOOD
	movi	[-45,0],a5
	callr	ATTACH_1_FOOD
 	rets


*
*	a8 = box object
*
*
ATTACH_1_FOOD:
	movk	4,a0
	calla	RAND0
	sll	5,a0
	addi	FOOD_TAB,a0
	move	*a0,a0,L	; init table
	move	a0,b0
	calla	EASYMAKE
	jrz	nofood
	move	*a8(OXVAL),a3,L
	clr	a6
	movx	a5,a6
	sll	15,a6		; convert to world
	add	a6,a3
	move	a3,*a0(OXVAL),L
	move	*a8(OYVAL),a4,L
	sra	16,a5
	sll	15,a5
	add	a5,a4
	move	a4,*a0(OYVAL),L
	move	*a8(OZVAL),*a0(OZVAL),L
	calla	INSOBJ
	calla	INSPART			; make food part of box
nofood:
	rets


FOOD_CVECT
	WWL	OID_PEXPLOSION,~MASK_PLAYER,FOOD_COLL
	WWL	OID_GRND,0FFFFH,GLAS_GRND_COLL
	WL	0,DUMCRETS


FOOD_GUNVECT:
	MOVI	1000,A1
	CALLA	SCORE			;Points for food
FOOD_COLL:
	move	*a8(OPART1),a4,L
	jrz	FOODX
	calla	PULL_PART
	calla	COLLS_OFF
	move	*a8(ODATA),a1,L
	calla	STRT_ANIM
	movi	-0b000h,a1
	movi	0b000h,a0
	calla	RANGRAND
	move	a0,*a8(OXVEL),L
	movi	-10000h,a0
	movi	-40000h,a1
	calla	RANGRAND
	move	a0,*a8(OYVEL),L
	movi	0c0h,a0
	movi	-0c0h,a1
	calla	RANGRAND
	move	a0,*a8(OZVEL),L
	MOVIM	2400h,*a8(OYACCEL),W
FOODX:
	rets


BURG_INIT
	.long	BURGER1
	.word	DMAWNZ,M_NOPARTANI,OM_CFUNC|OM_GUNV|OM_COLL
	.long	FOOD_CVECT,FOOD_GUNVECT
	.long	C_SET_HIT_ANIM
	.long	BURGER_ANIM


HOTD_INIT
	.long	HOTDOG1
	.word	DMAWNZ,M_NOPARTANI,OM_CFUNC|OM_GUNV|OM_COLL
	.long	FOOD_CVECT,FOOD_GUNVECT
	.long	C_SET_HIT_ANIM
	.long	HOTDOG_ANIM


FRIE_INIT
	.long	FRIES1
	.word	DMAWNZ,M_NOPARTANI,OM_CFUNC|OM_GUNV|OM_COLL
	.long	FOOD_CVECT,FOOD_GUNVECT
	.long	C_SET_HIT_ANIM
	.long	FRIES_ANIM


C_SET_HIT_ANIM:
	move	*b0+,b14,L
	move	b14,a14
	move	a14,*a0(ODATA),L	; save hit animation
	rets


BURGER_ANIM:
	LW	BURGER1,2
	LW	BURGER2,3
	LWL	BURGER3,3|AFunc,A_OFFSCRN_DEL
	LW	BURGER4,3
	LW	BURGER5,3
	LWLW	BURGER4,3|AFunc,A_TOGGLE_OCTRL+1,M_FLIPV
	LW	BURGER3,3
	LW	BURGER2,3
	LW	BURGER1,3
	LWLW	BURGER2,3|AFunc,A_TOGGLE_OCTRL+1,M_FLIPH
	LW	BURGER3,3
	LWL	BURGER4,3|AFunc,A_OFFSCRN_DEL
	LW	BURGER5,3
	LWLW	BURGER4,3|AFunc,A_TOGGLE_OCTRL+1,M_FLIPV
	LW	BURGER3,3
	LW	BURGER2,3
	LWLW	BURGER1,1|AFunc,A_TOGGLE_OCTRL+1,M_FLIPV
	.long	0


HOTDOG_ANIM:
	LW	HOTDOG1,2
	LW	HOTDOG2,3
	LWL	HOTDOG3,3|AFunc,A_OFFSCRN_DEL
	LW	HOTDOG4,3
	LW	HOTDOG5,3
	LWLW	HOTDOG4,3|AFunc,A_TOGGLE_OCTRL+1,M_FLIPV
	LW	HOTDOG3,3
	LW	HOTDOG2,3
	LW	HOTDOG1,3
	LWLW	HOTDOG2,3|AFunc,A_TOGGLE_OCTRL+1,M_FLIPH
	LW	HOTDOG3,3
	LWL	HOTDOG4,3|AFunc,A_OFFSCRN_DEL
	LW	HOTDOG5,3
	LWLW	HOTDOG4,3|AFunc,A_TOGGLE_OCTRL+1,M_FLIPV
	LW	HOTDOG3,3
	LW	HOTDOG2,3
	LWLW	HOTDOG1,1|AFunc,A_TOGGLE_OCTRL+1,M_FLIPV
	.long	0

FRIES_ANIM:
	LW	FRIES1,3
	LW	FRIES2,3
	LW	FRIES3,3
	LWL	FRIES4,3|AFunc,A_OFFSCRN_DEL
	LW	FRIES5,3
	LW	FRIES4,3
	LW	FRIES3,3
	LW	FRIES2,3
	.long	0

	.endif



	.END




