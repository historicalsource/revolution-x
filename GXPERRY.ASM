 	.MLIB	"GXMACS.LIB"
 	.FILE	"GXPERRY.ASM"
	.TITLE	" <<< GENERATION X -- JOE PERRY ROUTINES >>>"
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
	.INCLUDE	"GXPERRY.TBL"


* SYMBOLS IN HERE
	.DEF	PERRY_SKY_PROC,S_PERRY_FLY
	.DEF	A_PERRY_SCORE

* SYMBOLS IN GXD.ASM
	.REF	OBJ_ON_WNZ_MULTI

* SYMBOLS FROM GXPOWER.ASM
	.REF	A_OBJ_TO_POWERUP

**** from GXAFUNC.ASM
	.REF	A_CREATEP_R, A_AUDIT

	.TEXT
	.EVEN

MORPH	.set	1	    

SND_THRUSTER
	.WORD	0F180H,177,0A186H,0

SND_PERRY_FLY
	.WORD	0F380H,262,08062H,0

OPERRYDESTX	EQU	ODATA		;SHL PERRY'S FLYING DESTINATION X
OPERRYDESTY	EQU	ODATA+020H	;SHL PERRY'S FLYING DESTINATION Y

**************************************************************************
*								         *
* S_PERRY_FLY - MAKE JOE PERRY FLY ACROSS THE SCREEN	TO THE UPPER LEFT*
* 									 *
* .LONG   S_PERRY_FLY							 *
* .long   start x, start y						 *
*								         *
**************************************************************************
S_PERRY_FLY:
	move	*a11+,a9,L
	move	*a11+,a10,L
	MOVI	PERRY_FLY_INIT,B0
	CALLA	MULTIMAKE
	jrz	PERRY_ABT

	MOVE	A9,A1
	MOVE	A10,A2

	MOVE	@ZBASE,A3,L
	ADDI	08000H,A3
	MOVE	A3,A7

	CALLA	SET_ANIPU			;PLACE PERRY

	CALLA	INSERT_OBJ

	MOVE	A9,A2
	MOVE	A10,A4

	.if	MORPH

	MOVI	341,A1				;DESTINATION SCREEN X
	MOVI	106,A3				;DESTINATION SCREEN Y

	.else

	MOVI	461,A1				;DESTINATION SCREEN X
	MOVI	40,A3				;DESTINATION SCREEN Y

	.endif

	STOUXY	A7,A1,A3			;TRANSLATE TO UNIVERSE

	MOVE	A1,*A8(OPERRYDESTX),L		;DESTINATION
	MOVE	A3,*A8(OPERRYDESTY),L

	MOVI	60*3,A5				;AIR TIME

	CALLA	SLINEVEL_LOAD_2D

	MOVE	A8,A0

	MOVI	PERRY_FLY_START_ANIM,A1
	MOVI	PERRY_FLY_ANIM,A14
	CALLA	STRTANIM_OFF
PERRY_ABT:
	jauc	SCRL_DISPATCHER




**************************************************************************
*								         *
* PERRY_SKY_PROC - CHANGE SKY COLOR TO ORANGE, THEN BLACK		 *
*								         *
**************************************************************************
PERRY_SKY_PROC:
	movi	MOON_INIT,b0
	calla	EASYMAKE
	jrz	nomoon
	move	*a0(OZVAL),a1,L
	move	@ZREL_OFF,a14,L
	sra	ZFRAC,a14		; get to lores
	add	a14,a1
	move	a1,*a0(OZVAL),L
	calla	INSOBJ
	move	a0,a10
	CREATE	PID_IND,DEL_MOON

nomoon:
*
*	LOOP1, get to orange
*
	move	@SKYCOLOR,a8
	movk	18,a10		; number of iterations
PSPlp1:
	dec	a8		; reduce blue
	addi	1<<10,a8	; increase red
	move	a8,@IRQSKYE
	sleep	4
	dsjs	a10,PSPlp1

	
	move	a8,a9
	move	a9,a10
	srl	10,a8
	srl	5,a9
	movk	1fh,a0
	and	a0,a8
	and	a0,a9
	and	a0,a10		; isolate RGB components

*
*	LOOP2, get to blue
*
	sleep	10
	move	a8,@IRQGNDE
PSPlp2:
	dec	a9
	dec	a8
	inc	a10		; blue
	cmpk	7,a10
	jreq	nxtphase
	callr	SetSkyColor
	sloop	4,PSPlp2

nxtphase:
	sleep	4
	dec	a9
	jrnn	redok
	clr	a9
redok:
	dec	a8
	jrnn	grnok
	clr	a8
grnok:
	callr	SetSkyColor
	cmp	a0,a10
	jrne	nxtphase

	DIE

SetSkyColor:
	move	a8,a0
	sll	5,a0
	add	a9,a0
	sll	5,a0
	add	a10,a0
	move	a0,@IRQGNDE
	move	a0,@IRQSKYE
	rets

*
*	Wait a while , then delete the moon
*
DEL_MOON:
	move	a10,a8
	sleep	20*60		; 20 seconds oughta do it
	calla	DELETE_OBJ
	DIE


**************************************************************************
*								         *
* A_CHECK_PERRY_DEST - CHECK IF JOE REACHED HIS DESTINATION AND SMOKE	 *
*								         *
* PASS:									 *
* A8 = JOE'S HEAD OBJECT						 *
* RETURN:								 *
* NUTIN'								 *
*								         *
**************************************************************************

A_CHECK_PERRY_DEST

	MOVE	*A8(OPERRYDESTX),A0,L
	MOVE	*A8(OXVAL),A14,L
	CMP	A0,A14
	JRGE	ACPD_THERE			;BR=WE REACHED THE X DESTINATION
	MOVE	*A8(OPERRYDESTY),A0,L
	MOVE	*A8(OYVAL),A14,L
	CMP	A0,A14
	JRLE	ACPD_THERE			;BR=WE REACHED THE Y DESTINATION

	MOVE	A8,B14
	MOVE	*B14(OZVAL),B0,L
	DEC	B0				;OFFSET Z POSITION

	MOVE	*B14(OXVAL),B1,L
	SUBI	60 << 15,B1			;OFFSET X POSITION
	SRA	16,B1
	MOVE	B1,B2
	
	MOVI	-0180000H,B3			;MIN X VELOCITY	
	MOVI	-0180000H,B4			;MAX X VELOCITY

	MOVE	*B14(OYVAL),B5,L
	SUBI	12 << 15,B5			;OFFSET Y POSITION
	SRA	16,B5
	MOVE	B5,B6

	MOVI	016000H,B7			;MIN Y VELOCITY
	MOVI	016000H,B8			;MAX Y VELOCITY

	CLR	B9				;NO Z VELOCITY
	CLR	B10

	MOVI	FRAG_GUITAR_SMOKE,B14
	JAUC	Fragger
ACPD_THERE
	CLR	A14				;STOP MOVIN'
	MOVE	A14,*A8(OXVEL),L
	MOVE	A14,*A8(OYVEL),L

	.if	MORPH

	MOVI	PERRY_MORPH_ANIM,A1		;CHANGE DAMMIT!
	CALLA	STRT_ANIM

	.else 

	calla	DELETE_OBJ

	.endif

	RETS



FRAG_GUITAR_SMOKE
	.long	GUITAR_SMOKE,F_DOUBLE_SCALE
	.word	OID_JUNK,(1 << 11) + (1 << 6) + (FRGNOFLY+FRGPAL)
;	.long	GUITAR_SMOKE,F_DOUBLE_SCALE
;	.word	OID_JUNK,(1 << 11) + (1 << 6) + (FRGNOFLY+FRGPAL)
;	.long	GUITAR_SMOKE,F_DOUBLE_SCALE
;	.word	OID_JUNK,(1 << 11) + (1 << 6) + (FRGNOFLY+FRGPAL)
;	.long	GUITAR_SMOKE,F_DOUBLE_SCALE
;	.word	OID_JUNK,(1 << 11) + (1 << 6) + (FRGNOFLY+FRGPAL)
;	.long	GUITAR_SMOKE,F_DOUBLE_SCALE
;	.word	OID_JUNK,(1 << 11) + (0 << 6) + (FRGNOFLY+FRGPAL)
	.long	0

F_DOUBLE_SCALE
	MOVE	*A0(OFLAGS),A14,W
	ORI	M_DBLSCL,A14
	MOVE	A14,*A0(OFLAGS),W
	RETS

GUITAR_SMOKE
	LW	SMOKTR1,5
	LW	SMOKTR2,5
	LW	SMOKTR3,4
	LW	SMOKTR4,4
	LW	SMOKTR5,4
	LW	SMOKTR6,4
;	LW	SMOKTR7,4
	LWL	1,1|AFunc,DELETE_OBJ

**************************************************************************
*								         *
* A_CHECK_GUITAR_FIRE - CHECK IF FIRE SHOULD GO AWAT			 *
*								         *
* PASS:									 *
* A8 = FIRE OBJECT							 *
* RETURN:								 *
* NUTIN'								 *
*								         *
**************************************************************************

A_CHECK_GUITAR_FIRE
	CALLA	GET_HEAD_PART_A0
	MOVE	*A0(OXVEL),A14,L
	JAZ	DELETE_OBJ			;BR=WE'RE NOT MOVIN' KILL FIRE
	RETS

GUITAR_FIRE_ANIM
	LW	FHKE5F1FIRE1,1
	LW	FHKE5F1FIRE2,1
	LW	FHKE5F1FIRE3,1
	LW	FHKE5F1FIRE4,1
	LW	FHKE5F1FIRE5,1
	LWL	FHKE5F1FIRE6,1|AFunc,A_CHECK_GUITAR_FIRE
	.long	0

PERRY_FLY_INIT
	.byte	5, 0, 0, 2		;OBJCNT, PRCCNT, IMGPALCNT, PALCNT
	.long	PERRY			;IMGPAL
	.long	FX2			;IMGPAL
	.word	OID_JUNK, 0		;OID, GLOBAL_OPTIONS
*        .long IMG
*        .word OCTRL, OFLAGS, OZOFF
*        .word OPTIONS 
	LWWWW	JP151TOR1, DMAWNZ, M_NOSCALE, 0, 0
	LWWWW	JP151ARM3, DMAWNZ, M_NOSCALE|M_NODISP, 0, 0
	LWWWW	JP151RLEG1, DMAWNZ, M_NOSCALE, 2, 0
	LWWWW	JP151LLEG1, DMAWNZ, M_NOSCALE, 2, 0
	LWWWW	FHKE5F1FIRE1, DMAWNZ, M_NOSCALE|M_NOPARTANI,1,OM_OPARTS|OM_ANIM
	.LONG	[-101, 4]
	.LONG	GUITAR_FIRE_ANIM

PERRY_FLY_START_ANIM
	LWLW	1,1|AFunc,A_CREATEP_R+9,PID_IND
	.LONG	PROC_SND,0,30,SND_PERRY_FLY
	LWLL	1,1|AFunc,A_SOUND+2,SND_THRUSTER
PERRY_FLY_ANIM
	LWL	JP151TOR1,1|AFunc|AMulti,A_CHECK_PERRY_DEST
	LWL	1,4|AFunc,OBJ_OFF

	LWL	JP151TOR2,4|AFunc,A_CHECK_PERRY_DEST

	LWL	JP151TOR3,1|AFunc|AMulti,A_CHECK_PERRY_DEST
	LWL	JP151ARM3,4|AFunc,OBJ_ON_WNZ

	LWL	JP151TOR4,1|AFunc|AMulti,A_CHECK_PERRY_DEST
	LW	JP151ARM4,4

	LWL	JP151TOR6,1|AFunc|AMulti,A_CHECK_PERRY_DEST
	LW	JP151ARM6,4

	LWL	JP151TOR7,1|AFunc|AMulti,A_CHECK_PERRY_DEST
	LW	JP151ARM7,4

	LWL	JP151TOR8,1|AFunc|AMulti,A_CHECK_PERRY_DEST
	LW	JP151ARM8,4

	LWL	JP151TOR9,1|AFunc|AMulti,A_CHECK_PERRY_DEST
	LW	JP151ARM9,4

	.long	0

A_PERRY_SCORE:
	clr	a9
	MOVE	@NPLAYERS,A7,W
	movi	P1DATA,a2
SCR_PERRY_LP:
	MOVE	*A2(POBJ),A0,L		;IS THE PLAYER ALIVE?
	jrz	nop1
     	movi	80000,a1
	calla	PRINT_SCORE
nop1:
	ADDI	PDSIZE,A2
	DEC	A7
	JRNN	SCR_PERRY_LP
        rets


	.if MORPH

PERRY_MORPH_ANIM
	LWLL	PERRYMRPH_01,1|AMulti|AFunc,A_CHANGE_PAL+2,PMORPH2
	LWL	1,1|AMulti|AFunc,OBJ_OFF
	LWL	1,1|AMulti|AFunc,OBJ_OFF
	LWL	1,1|AMulti|AFunc,OBJ_OFF
	LWL	1,7|AFunc,OBJ_OFF

	LWLW	PERRYMRPH_03,7|AFunc,A_AUDIT+1,AUDPERRY

	LW	PERRYMRPH_05,7

	LW	PERRYMRPH_07,7

	LWLL	P_AEROLOGO,10|AFunc,A_CHANGE_PAL+2,AROLOGO2

	LWL	1,1|AFunc,A_PERRY_SCORE
	LWLW	1,1|AFunc,A_OBJ_TO_POWERUP+1,OID_WINGS

	.else

PERRY_MORPH_ANIM
	LW	1,10

	LWL	1,10|AFunc,OBJ_OFF_MULTI
	LWL	1,10|AFunc,OBJ_ON_WNZ_MULTI
	
	LWL	1,10|AFunc,OBJ_OFF_MULTI
	LWL	1,10|AFunc,OBJ_ON_WNZ_MULTI

	LWL	1,10|AFunc,OBJ_OFF_MULTI
	LWL	1,10|AFunc,OBJ_ON_WNZ_MULTI

	LWL	1,9|AFunc,OBJ_OFF_MULTI
	LWL	1,9|AFunc,OBJ_ON_WNZ_MULTI

	LWL	1,8|AFunc,OBJ_OFF_MULTI
	LWL	1,8|AFunc,OBJ_ON_WNZ_MULTI

	LWL	1,7|AFunc,OBJ_OFF_MULTI
	LWL	1,7|AFunc,OBJ_ON_WNZ_MULTI

	LWL	1,6|AFunc,OBJ_OFF_MULTI
	LWL	1,6|AFunc,OBJ_ON_WNZ_MULTI

	LWL	1,5|AFunc,OBJ_OFF_MULTI
	LWL	1,5|AFunc,OBJ_ON_WNZ_MULTI

	LWL	1,1|AFunc,DELETE_OBJ

	.endif


MOON_INIT	
	.long	YELMOON
	.word	DMAWNZ,M_NOSCALE,OM_POS
	.long	-2a30000h,-016d0000h,304b2h


	.END
