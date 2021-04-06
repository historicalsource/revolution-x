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
	.include	"gxnatv.h"
	.include	"gxbeek3.tbl"
	.text



	.DEF	S_START_MORFERS,SCAN_FOR_DROPPERS,DO_SCHMOOTZ

	.ref	SCRL_DISPATCHER,EASYMAKE,OBJENEMIES,CLR_BEEK_ODATA
	.ref	SET_ANIPU,ZREL_OFF,A_STAY_TIL_WY_GT,A_CHANGE_PAL
	.ref	ONESND,MORFGLASOUT,PALRAM,PALSET,BGHEAD_ACTIVE
	.ref	MORF_JUMP_INIT



	.bss	KMORF_X,32		; start position of morphing Kerri
	.bss	KMORF_Z,32		; 
	.bss	DROPPER_TAB,6*32	; can keep 3 droppers in table




*********************************************
*					    *
*         Spritzers			    *
*					    *
*********************************************
*
* Called from S_CREATE_BEEKS:  need to pass X range and Z range	
*
*	a10 points to table containing X min X max Z min Z max
*
DROP_ID	.set	30

*	a5 = X min
*	a6 = X max
*	a9 = Z min	(relative to inner3)
*	a8 = Z max (relative to inner3)
*
SCAN_FOR_DROPPERS:
	move	@ZREL_OFF,a14,L
	srl	ZFRAC,a14
	add	a14,a9
	add	a14,a8		; convert to universe
 
	movi	DROPPER_TAB,a4	; where to put it

	movi	DROP_ID<<B_BF_ID,a2	; ID to look for
	move	@BGHEAD_ACTIVE,a0,L
	move	a0,a1
Dscnlp:
	move	*a1(MAP_NEXT),a1,L

	move	*a1(MAP_Z),a7,L	; check for target Z
	cmp	a9,a7
	jrlt	nmatch
	cmp	a8,a7
	jrgt	DscnX		; abort when out of Z range

	move	*a1(MAP_FLAGS),a14	; check for target OID
	andi	M_BF_ID,a14
	cmp	a14,a2
	jrne	nmatch

	move	*a1(MAP_X+10h),a3	; check for target X
	cmp	a5,a3
	jrlt	nmatch
	cmp	a6,a3
	jrgt	nmatch
*
*	FOUND ONE!
*
	move	a1,*a4+,L		; link is in table
	jruc	sechalflp

nmatch:
	cmp	a1,a0
	jrne	Dscnlp
DscnX:
	rets


sechalflp:
	.if DEBUG
	cmp	a1,a0		; can't get to end yet
	LOCKON	Z
	.endif

	move	*a1(MAP_NEXT),a1,L

	.if	DEBUG
	move	*a1(MAP_Z),a14,L	; check for target Z
	cmp	a7,a14
	LOCKON	NE
	.endif

	move	*a1(MAP_FLAGS),a14	; check for target OID
	andi	M_BF_ID,a14
	cmp	a14,a2
	jrne	sechalflp

	move	*a1(MAP_X+10h),a14
	cmp	a14,a3
	jrne	sechalflp

	move	a1,*a4+,L		; found 2nd half
	jruc	Dscnlp


DROPPAL_TAB:
	.long	0,SPLOOTRP,SPLOOTBP


*
*	a box will call this routine to start some schmootz
*	a0 = index of dropper (0, 1, 2)
*
DO_SCHMOOTZ:
	move	*a8(OCVECT),a14,L	; is this box trashed?
	jrz	noobj			; if so, no schmootz
*
*	First, do we really want to do this?
*
	move	a0,a6
	sll	5,a6
	addi	DROPPAL_TAB,a6	; which palette to use?
	sll	6,a0
	addi	DROPPER_TAB,a0
	move	*a0+,a1,L	; first dropper
	move	*a1(MAP_OBJ),a3,L
	jrle	noobj		; is there an object?
	srl	4,a3
	sll	4,a3
	move	*a3(OCVECT),a14,L	; is it totally damaged?
	jrz	noobj
	move	*a3(OPLINK),a4,L
	jrnz	noobj		; if process exists, ignore this request
	move	*a0+,a2,L
	move	*a2(MAP_OBJ),a5,L	; look for other half.
	jrle	noobj
	srl	4,a5
	sll	4,a5
	move	*a5(OCVECT),a14,L	; is it totally damaged?
	jrz	noobj
*
*	Okay, do the schmootz
*
	mmtm	sp,a8,a9,a10,a11
	move	*a6,a11,L
	move	a1,a10
	move	a3,a8		; contains damage level in bottom 4 bits
	move	a5,a9
	CREATE	PID_IND,SHPRITZ
	mmfm	sp,a8,a9,a10,a11
	move	a0,*a3(OPLINK),L	; save process in first half
	
noobj:
	rets

*
*	a8 , a9 = dropper objects
*	a10 = bglink
*	a11 = palette (0= use default)
SHPRITZ:
	movi	-5000h,a0
	move	a0,*a8(OYVEL),L
	move	a0,*a9(OYVEL),L		; moves up slow
	sleep	30
	clr	a0
	move	a0,*a8(OYVEL),L
	move	a0,*a9(OYVEL),L		; stop motion
	move	*a10(MAP_Y),a6,L
	move	a6,*a8(OYVAL),L
	move	a6,*a9(OYVAL),L		; return to orig position
	CLRM	*a8(OPLINK),L		; dissassociate proc with obj

	movi	SPRITZ_INIT,b0
	calla	MULTIMAKE
	move	*a9(OXVAL),a5,L
	move	*a9(OZVAL),a7,L

	move	a11,a0
	jrz	nopalchg
	calla	CHANGE_PAL_MULTI
nopalchg:


	move	a5,*a8(OXVAL),L
	move	a6,*a8(OYVAL),L
	move	a7,*a8(OZVAL),L
	move	*a8(OPARTS),a0,L
	move	a5,*a0(OXVAL),L
	move	a6,*a0(OYVAL),L
	move	a7,*a0(OZVAL),L

	calla	INSERT_OBJ


	DIE


SPLOOTBP:
   .word   32 
   .word   003e0h,05016h,05c19h,04814h,04414h,04013h,03c12h,03812h
   .word   03811h,03411h,03410h,03010h,02c0fh,0280fh,0280eh,0240eh
   .word   0240dh,0200dh,01c0ch,0200ch,0180bh,0140bh,0140ah,0100ah
   .word   01009h,00c09h,00808h,00407h,00007h,00006h,00006h,00005h



SPLOOTRP:
   .word   32 
   .word   0001fh,05a80h,066e0h,05240h,05220h,04e00h,049e0h,049c0h
   .word   045c0h,045a0h,041a0h,04180h,03d60h,03d40h,03940h,03920h
   .word   03520h,03500h,030e0h,03100h,02cc0h,02ca0h,028a0h,02880h
   .word   02480h,02460h,02040h,01c20h,01c00h,01800h,01800h,01400h

	
SPRITZ_INIT
	.byte	2,0,0,1
	.long	SPLOOTGP
	.word	OID_JUNK,0
	LWWWW	SPLOOT1,DMAWNZ,0,0,OM_ANIM
	.long	SPRITZ_ANIM
	LWWWW	SPLOOT1,DMAWNZ|M_FLIPH,0,0,0

SPRITZ_ANIM:
	LW	1,1|AMulti
	LW	1,2
	LW	SPLOOT2,1|AMulti
	LW	SPLOOT2,2
	LW	SPLOOT3,1|AMulti
	LW	SPLOOT3,2
	LW	SPLOOT4,1|AMulti
	LW	SPLOOT4,2
	LW	SPLOOT5,1|AMulti
	LW	SPLOOT5,2
	LW	SPLOOT6,1|AMulti
	LW	SPLOOT6,2
	LW	SPLOOT7,1|AMulti
	LW	SPLOOT7,2
	LW	SPLOOT8,1|AMulti
	LW	SPLOOT8,2
	LW	SPLOOT9,1|AMulti
	LW	SPLOOT9,2
	LW	SPLOOT10,1|AMulti
	LW	SPLOOT10,2
	LW	SPLOOT11,1|AMulti
	LW	SPLOOT11,2
	LW	SPLOOT12,1|AMulti
	LW	SPLOOT12,2
	LW	SPLOOT13,1|AMulti
	LW	SPLOOT13,2
	LWL	1,1|AFunc,DELETE_OBJ
	







******************************************************************
*								 *
*         KERRY MORPH						 *
*								 *
******************************************************************

*
*	.LONG	S_START_MORFERS
*	.word	Uni X
*	.long	Uni Z (relative to local univ)
*
S_START_MORFERS:
	move	*a11+,a0	; get uni x from scroll table
  	sll	16,a0
	move	a0,@KMORF_X,L	; Set X pos

	move	*a11+,a0,L    	; get uni Z from scroll table
	move	@ZREL_OFF,a1,L
	sra	ZFRAC,a1
	add	a1,a0
	move	a0,@KMORF_Z,L	; Set Z pos

	move	@OBJENEMIES,a14
	ori	M_OF_MORFRS,a14
	move	a14,@OBJENEMIES	; turn morfrs on

	callr	MAKE_A_MORFER	; make one and start animation going
	jauc	SCRL_DISPATCHER


KMRF_INIT:
	.LONG	SF1J05
	.word	DMAWNZ,0,OM_ANIM
	.long	KMRF_ANIM
	

MAKE_A_MORFER:
	move	@OBJENEMIES,a14
	btst	B_OF_MORFRS,a14
	jrz	no_morf_gen

	movi	KMRF_INIT,b0		; Make one morfer
	calla	EASYMAKE
	move	@KMORF_X,a1,L
	move	a1,*a0(OXVAL),L
	move	@KMORF_Z,a1,L
	move	a1,*a0(OZVAL),L
	movi	-600000h,a1
 	move	a1,*a0(OYVAL),L
	calla	INSOBJ
;	movi	310,a0
;	calla	RANDPER
;	jrnc	no_morf_gen

	movi	SND_SHREIK1,a1		
	movi	512,a0
	calla	RANDPER
	jrnc	othshrk
	movi	SND_SHREIK2,a1		
othshrk:
	move	a1,a0
	calla	ONESND
no_morf_gen:
	rets
		  
SND_SHREIK1
	.word	0f380h,187,0a568h,0

SND_SHREIK2
	.word	0f380h,179,0a56bh,0

;SND_SHRT_SHREIK
;	.word	0f380h,36,0a4fdh,0


KMRF_ANIM:
	LWLW	SF1J05,3|AFunc,A_SET_OYACCEL+1,2c00h
	LWLW	SF1J06,1|AFunc,A_STAY_TIL_WY_GT+1,8h
	LWL	SF1J07,4|AFunc,PSTOP
	LW	SF1J08,4
;	LWLL	SF1J08,4|AFunc,A_SOUNDZ+2,SND_SHRT_SHREIK
	LW	SF1J09,4
	LW	SF1J10,5
	LW	SF1J11,6
	LWL	SF1J12,30|AFunc,A_MORPH_GLOW
	LWLL	KERMORF01,7|AFunc,A_CHANGE_PAL+2,KERMRF_P
	LW	KERMORF02,7
	LW	KERMORF03,7
	LW	KERMORF02,6
	LW	KERMORF03,5
	LW	KERMORF04,6
	LW	KERMORF05,7
	LW	KERMORF06,7
	LW	KERMORF07,7
	LW	KERMORF06,6
	LW	KERMORF05,5
	LW	KERMORF04,6
	LW	KERMORF05,7
	LW	KERMORF06,7
	LW	KERMORF07,7
	LWLL	DRONE2,7|AFunc,A_CHANGE_PAL+2,P_GXBEEM
	LWL	1,60|AFunc,INIT_COSTUME



INIT_COSTUME:
	CREATE	PID_IND,COSTUME_PROC
	jauc	PULL_ANIM


*
*	a8 = object blk of drone in morph chamber
*
COSTUME_PROC
	movi	COSTLH_INIT,b0
	calla	EASYMAKE
	move	*a8(OXVAL),a14,L
	subi	0f0000h,a14
	move	a14,*a0(OXVAL),L
	movi	8000h,a14
	move	a14,*a0(OXVEL),L

	move	*a8(OZVAL),a14,L
	subk	2,a14
	move	a14,*a0(OZVAL),L

	move	*a8(OYVAL),a14,L
	addi	1e0000h,a14
	move	a14,*a0(OYVAL),L
	movi	-10000h,a14
	move	a14,*a0(OYVEL),L

	calla	INSOBJ
	move	a0,a9

	movi	COSTLR_INIT,b0
	calla	EASYMAKE
	move	*a8(OXVAL),a14,L
	addi	0f0000h,a14
	move	a14,*a0(OXVAL),L
	movi	-8000h,a14
	move	a14,*a0(OXVEL),L

	move	*a8(OZVAL),a14,L
	dec	a14
	move	a14,*a0(OZVAL),L

	move	*a8(OYVAL),a14,L
	addi	1e0000h,a14
	move	a14,*a0(OYVAL),L
	movi	-10000h,a14
	move	a14,*a0(OYVEL),L

	calla	INSOBJ
	move	a0,a10

	sleep	30

	clr	a0	  		; stick costume to drone
	move	a0,*a9(OXVEL),L
	move	a0,*a9(OYVEL),L
	move	a0,*a10(OXVEL),L
	move	a0,*a10(OYVEL),L
	move	*a8(OXVAL),a14,L
	move	a14,*a9(OXVAL),L
	move	a14,*a10(OXVAL),L
	move	*a8(OYVAL),a14,L
	move	a14,*a9(OYVAL),L
	move	a14,*a10(OYVAL),L


	move	@MORFGLASOUT,a14	; has glass been taken out?
	jrz	glass_in
*
*	If glass is out, no helmet, he jumps out of chamber
*
	sleep	20			; see him

	move	a8,a11

	move	@OBJENEMIES,a14		; can we make morfers?
	btst	B_OF_MORFRS,a14
	jrz	COSTdel			; if no, wait til offscreen, then del

	movi	MORF_JUMP_INIT,b0	; make new guy
	calla	MULTIMAKE
	CALLA	CLR_BEEK_ODATA

	move	*a9(OXVAL),a1,L
	move	*a9(OYVAL),a2,L
	move	*a9(OZVAL),a3,L
	calla	SET_ANIPU
	calla	INSERT_OBJ
;	MOVIM	-0d0h,*a8(OZVEL),L	; start imm. move in Z
;	movi	18000h,a0
;	movi	-18000h,a1
;	calla	RANGRAND  		; spread em out in X
;	move	a0,*a8(OXVEL),L

	sleep	1

	move	a11,a0
	calla	DELOBJ			; delete drone body
	move	a9,a0
	calla	DELOBJ			; delete cost half
	move	a10,a0
	calla	DELOBJ			; delete cost half

	sloop	80,COSThk		; wait, start another morfer

*
*	If glass is in, lower a helmet, then drop the guy away
*
glass_in:
	movi	COSTH_INIT,b0		; lower helmet
	calla	EASYMAKE
	move	*a8(OXVAL),*a0(OXVAL),L

	move	*a8(OZVAL),a14,L
	dec	a14
	move	a14,*a0(OZVAL),L

	move	*a8(OYVAL),a14,L
	subi	1e0000h,a14
	move	a14,*a0(OYVAL),L
	movi	0c000h,a14
	move	a14,*a0(OYVEL),L

	calla	INSOBJ
	move	a0,a11

*
*	make all objs into a single multiparter
*
;	PUSH	a8			; drone body
;	move	a8,a0
;	move	a11,a8			; helmet becomes head
;	calla	INSPART
;	move	a10,a0
;	calla	INSPART
;	move	a9,a0
;	calla	INSPART
;	PULLQ	a8

	sleep	40

	clr	a0	  		; stick helmet to drone
	move	a0,*a11(OYVEL),L
	move	*a8(OYVAL),*a11(OYVAL),L

	calla	DELETE_OBJ		; original body

	sleep	20
*
*	lower helmeted guy
*
	movi	1c000h,a14
	move	a14,*a9(OYVEL),L
	move	a14,*a10(OYVEL),L
	move	a14,*a11(OYVEL),L

	sleep	20

	move	a9,a0
	calla	DELOBJ
	move	a10,a0
	calla	DELOBJ

	sleep	10
	move	a11,a0
	calla	DELOBJ
COSThk:
	sleep	10
	calla	MAKE_A_MORFER
COSTdie:
	DIE

COSTdel:
	move	*a9(OFLAGS),a14
	btst	B_OFSCRN,a14
	jrnz	COSTdel1
	sloop	3,COSTdel

COSTdel1:
	move	a11,a0
	calla	DELOBJ			; delete drone body
	move	a9,a0
	calla	DELOBJ			; delete cost half
	move	a10,a0
	calla	DELOBJ			; delete cost half

	DIE


COSTLH_INIT
	.LONG	DCOSTHAF1
	.word	DMAWNZ,0,0

COSTLR_INIT
	.LONG	DCOSTHAF2
	.word	DMAWNZ,0,0


COSTH_INIT
	.LONG	DCOSTHEL1
	.word	DMAWNZ,0,0



A_MORPH_GLOW:
	movi	MOBACK_P,a8
	move	a8,a0
	calla	FINDPAL
	jrz	notfound
	sll	24,a0
	srl	24,a0		; slot of palette
	move	a0,a9
	sll	16,a9
	addi	56-14+1,a9	; slot : num cols
	movk	19,a10		; delta 
	movk	14,a11		; st color
	CREATE	PID_TCYCLE,GLOW_GREEN_PROC
notfound:
	rets


**************************************************************
*
*   GLOW_GREEN_PROC  -   make a palette glow GREEN by 
*			decreasing its green
*
*   a8 = PALID				 (passed when created)
*   a9 = palette slot : number of colors (slot passed when created)
*   a10 = CUR : max delta before reversing	 (passed when created)
*   a11 = direction (1 or -1) shifted to upper 6 bits
*
**************************************************************
GLOW_GREEN_PROC:
	move	a11,*-a12	; save start color on proc stack
	movi	1<<26,a11   	; initial delta

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
*
*	adjust palette and set up transfer
*
	move	a8,a6
	move	*a12,a14	; start color
	sll	4,a14
	add	a14,a6		; pointer to source data
	move	a13,a4
	addi	PDATA+10h,a4	; RAM location of palette's current state
	move	a4,a0		; for PALSET
	move	a9,a5
	zext	a5		; # colors in a5
	clr	a7
	movy	a10,a7		; current delta

GG_lp2:
	move	*a6+,a1
	move	a1,a3
	srl	5,a1		; lose blue
	sll	32-5,a1		; green
	srl	1,a1		; leave a sign bit
	sub	a7,a1
	jrnn	nosatgrn
	clr	a1
nosatgrn:
	srl	32-11,a1		; final green

	andi	01fh+07c00h,a3
	add	a3,a1
	move	a1,*a4+
	dsjs	a5,GG_lp2

	move	*a12,a1
	sll	8,a1
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
	jrn	adja11
	abs	a14
	cmpxy	a10,a14
	jrxne	skpa11adj	; if cur count = max, make a11 neg
adja11:
	neg	a11
	jann	SUCIDE
skpa11adj:

	sloop	1,GG_lp1




	.END
