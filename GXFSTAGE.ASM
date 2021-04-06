 	.MLIB	"GXMACS.LIB"
	.FILE	"GXFSTAGE.ASM"
	.TITLE	" <<< GENERATION X -- FINAL STAGE >>>"
	.WIDTH	132
	.OPTION	B,D,L,T
	.MNOLIST

**************************************************************************
*								         *
* 	COPYRIGHT (C) 1992 MIDWAY MANUFACTURING COMPANY.		 *
* 		       ALL RIGHTS RESERVED.				 *
*								         *
**************************************************************************

	.INCLUDE	"GXENEMY.INC"
	.INCLUDE	"GXSCRL.H"
	.INCLUDE	"IMGTBL.GLO"
	.INCLUDE	"UNIVTBL.GLO"
	.INCLUDE	"GXFSTAGE.TBL"

* SYMBOLS IN HERE
	.DEF	FINAL_STAGE_SCROLL, FINAL_VECT_TABLE, CREATE_PICTURE  

* SYMBOLS FROM GXPLAYER.ASM
	.REF	VALID_PLAYER

* SYMBOLS FROM GXUNIV.ASM
	.REF	WXBUFFER, WYBUFFER, UNIVERR
	.ref	UNIV_DAMAGE_HANDLER
	.ref	FLOAT_ZFAR,MAKE_EXPLO_CENTER
	.REF	RAMREF0, RAMREF1

* SYMBOLS FROM GXLA2.ASM
	.ref	PASPEAKER_COLLVECT,PASPEAKER_GUNVECT
	.REF	SPOTLIGHT_COLLVECT,SPOTLIGHT_GUNVECT

* SYMBOLS FROM GXbus.ASM
	.ref	SNOZZ_COUNT	; use as wall count

* SYMBOLS FROM GXJUNGLE.ASM
	.ref	FRG_GL_12_2X,FLY_AWAY,TAB_SOUND

* SYMBOLS FROM GXSND.ASM
	.ref	ONESND_Z,ONESND

* SYMBOLS FROM GXAFUNC.ASM
	.ref	A_SOUNDZ,A_Set_LOOP_STRT

* SYMBOLS FROM GXUNISEQ.ASM
	.ref	HELGA_INUSE,A_MAKE_PART

* SYMBOLS FROM GXPALL.ASM
	.ref	A_CHANGE_PAL

* SYMBOLS FROM GXD.ASM
	.ref	WAVEIRQS,EASYMAKE,RAND,SETOFFPU
	.REF	SET_ANIPU, ZBASE, ZFAR, WORLD_GRNDOFF, XSCROLL
	.ref	YSCROLL, ZSCROLL, XBASE

* SYMBOLS FROM GXHELGA.ASM
	.REF	START_FINAL_HELGA

* SYMBOLS FROM GXSCROLL.ASM
	.REF	SCROLL_FLAG,CHNG_SCRL_TBL,SCROLLKILL

* SYMBOLS FROM GXRAM.ASM
	.REF	GUNS_OFF, BONUS_DIRECTION, SUPERGUN_AWARDS

* SYMBOLS FROM GXWAVE.ASM
	.REF	DSP_FINALE_1, WAVE1END

***** from GXMONDOR.ASM
	.REF	MONDOR_MORPH_FLAG, SND_WALK_XITION
	.REF	MONDOR_PROC

***** from GXENEMY.ASM
	.REF	PROC_DROP_PACK

***** from GX.ASM
	.REF	WAVE_END_IMM

* SYMBOLS FROM GXAERO.ASM
	.REF	MAKE_BS_AEROSMITH
	.REF	MAKE_BS_AEROSMITH_ANIM
	.REF	CREATE_AEROSMITH_WALK

* SYMBOLS FROM GXUNIV1.ASM
	.REF	UNIV_ROCKET_COLL, GOLD_DUST_PAL, UNIV_COLL_CHECK
	.REF	FRAG_ONE_CLOUD_X2, FRAG_U20_X2
	.REF	DEL_PROC_AND_OBJ

* SYMBOLS FROM GXMISC.ASM
	.REF	CYCLE16

* SYMBOLS FROM GXPOWER.ASM
	.REF	THROW_BOOBY_PRIZE,REVEAL_CD2, REVEAL_SUPERGUN2
	.REF	PROC_DELAYED_SBOMB

* SYMBOLS FROM GXNONBOY.ASM
	.REF	NONBOY_SHOOT_CHANCE

***** from GXDESK.ASM
	.REF	SND_FINAL_EXPLODE1, SND_FINAL_EXPLODE2, SND_FINAL_EXPLODE3

* SYMBOLS FROM GXUNILNK.ASM
	.REF	REMOVE_AND_FREE_LINK

	.TEXT
	.EVEN

CENTER_STAGE_X	EQU	019AH		;UNIVERSE X SHIFTED DOWN 16 BITS
STAGE_Y		equ	0c9h		;UNIVERSE Y SHIFTED DOWN 16 BITS
STAGE_WID	equ	140h		;UNIV WIDTH OF STAGE
STAGE_HT	equ	0a0h		;UNIV HEIGHT OF STAGE

CURTAIN_X_INC	EQU	0D00000H

CURTAIN_X_START	EQU	-01400000H

TOTAL_CURTAINS	EQU	9

BACKSTAGE_VECT_TABLE
;1, 2
	.LONG	0,0,MOLDING_COLLVECT,MOLDING_GUNVECT
;3, 4
	.LONG	BASE_COLLVECT,BASE_GUNVECT,0,0
;5, 6
	.LONG	0,0,0,0
;7, 8
	.LONG	0,0,0,0
;9, 10
	.LONG	0,0,0,0
;11, 12
	.LONG	0,0,0,0
;13, 14
	.LONG	0,0,0,0
;15, 16
	.LONG	0,0,0,0
;17, 18
	.LONG	0,0,0,0
;19, 20
	.LONG	0,0,0,0
;21, 22
	.LONG	0,0,0,0
;23, 24
	.LONG	0,0,0,0
;25, 26
	.LONG	0,0,0,0
;27, 28
	.LONG	0,0,0,0
;29, 30
	.LONG	0,0,0,0
;31, 32
	.LONG	0,0,0,0

SND_MOLDING_EXPLODE
	.WORD	0F320H,40,0A328H,0
SND_MOLDING_HIT
	.WORD	0F308H,31,0A15AH,0

**************************************************************************
*								         *
* GOLD SHIT VECTORS							 *
*								         *
**************************************************************************

MOLDING_COLLVECT
BASE_COLLVECT
	WWL	OID_PROCKET,~MASK_PLAYER,UNIV_ROCKET_COLL
	WWL	OID_PEXPLOSION,~MASK_PLAYER,MOLDING_CVECT
	WL	0,DUMCRETS

MOLDING_CVECT
	CALLA	UNIV_COLL_CHECK
	JRNZ	MOLDING_DONE

	MOVE	*A0(OID),A0,W			;GET PLAYER DATA ADDRESS
	CALLA	POID_TO_PDATA
MOLDING_GUNVECT
BASE_GUNVECT
	CLR	A3				;OTHER FACE PIECE FLAG
MOLD_DAMAGE
	MOVI	[-09H,0],A11			;[Y, X] VELOCITY LIMITS
	MOVE	*A8(OIMG),A4,L
	CMPI	PILLBOTD1,A4
	JRNE	MC_THROW_GO			;BR=NOT THE PILLAR BASE
	MOVI	[-020H,020H],A11		;[Y, X] VELOCITY LIMITS
MC_THROW_GO
	MOVI	(-2 << 16) + ((-10 << 8) & 0FF00H) + 0,A9  ;Z, Y, X OFFSET
	MOVI	[-010H,-0100H],A10		;[MAX, MIN] Z VELOCITY
	CREATE	PID_IND,THROW_BOOBY_PRIZE

	MOVI	1000,A5				;POINTS
	MOVK	M_NOMORE|M_LASTFRM|M_FLASHOBJ,A7	;LAST AND FLASH
	CLR	A9
	MOVE	A4,A11
	CMPI	TOPMOD1,A11
	JRNE	MOLD_GO					;BR=NOT A FACE PIECE
	MOVI	[0,-94],A9	
MOLD_GO
	CALLA	UNIV_DAMAGE_HANDLER

	MOVE	*A8(OXVAL),A10,L			;X POSITION FOR REF

	SOUND1	SND_MOLDING_EXPLODE

	MOVE	A3,A11
	MMTM	SP,B1,B2,B4,B5,B6,B8,B9,b10		;MAKE FRAGMENTS

	MOVI	040000H,A0
	CLR	A3
	CALLA	PreFrag_Box
	MOVI	-0FFH,B9			;MIN Z VEL
	MOVI	-01H,B10			;MAX Z VEL
	MOVI	FRAG_U20_X2,B14
	CALLA	Fragger

	MOVI	BIGTOPp2,A14
	MOVE	A14,*A0(FPDATA),L		;SET PALETTE

	CLR	A0
	CLR	A3
	CALLA	PreFrag_Center
	MOVI	-0FFH,B9			;MIN Z VEL
	MOVI	-01H,B10			;MAX Z VEL
	MOVI	FRAG_ONE_CLOUD_X2,B14
	CALLA	Fragger

	MOVI	GOLD_DUST_PAL,A14
	MOVE	A14,*A0(FPDATA),L		;SET PALETTE

	MMFM	SP,B1,B2,B4,B5,B6,B8,B9,b10

	MOVE	A9,A9
	JRZ	MOLDING_DONE			;BR=NOT A FACE PIECE

	MOVE	A11,A3
	JRNZ	MOLDING_DONE			;BR=WE DID THE OTHER HALF	
	MOVK	1,A3

	MOVI	FGLIST,A0
	MOVE	A0,A8
;	CLR	A5				;NO SCORE
MOLD_LUPE
	MOVE	*A8(OIMG),A14,L			;CHECK IMAGES
	CMPI	TOPMOD1,A14
	JRNE	MOLD_NEXT			;BR=NOT A FACE PIECE
	MOVE	*A8(OXVAL),A14,L
	SUB	A10,A14
	ABS	A14
	CMPI	0300000H,A14
	JRLT	MOLD_DAMAGE			;BR=THIS IS THE MATCH
MOLD_NEXT
	MOVE	*A8,A8,L
	CMP	A0,A8
	JRNE	MOLD_LUPE			;BR=NOT END OF LIST

	RETS
;MOLDING_GUNVECT
;BASE_GUNVECT
;	SOUNDZ	SND_MOLDING_HIT
MOLDING_DONE
	RETS


*************************************************************************
*								         *
* MAKE_CURTAIN								 *
*								         *
**************************************************************************

MAKE_CURTAIN
	MOVI	CURTAIN_X_START,A9
	MOVK	TOTAL_CURTAINS,A10
	CREATE	PID_IND,CURTAIN_UPDATE_PROC
	MOVE	A0,A11
	ADDI	PDATA,A11
MC_LUPE
	MOVI	CURTAIN_INIT,A5
	CALLA	CREATE_OBJ
	JRZ	MC_DONE
	MOVE	A0,A8
	MOVE	A8,*A11+,L

	MOVE	A9,A1
	MOVI	02C0000H,A2
	MOVI	016FFEH-400h,A3
	CALLA	SET_ANIPU

	MOVE	@ZBASE,A14,L
	SUB	A14,A3
	SRA	Z2SCALE+4,A14
	SRA	Z2SCALE+2,A3
	SUB	A14,A3
	MOVE	A3,*A8(ONuManScl),W

	MOVI	DUMRETS,A14
	MOVE	A14,*A8(OGUNVECT),L

	CMPI	CURTAIN_X_START+(CURTAIN_X_INC*5),A9
	JRNE	MC_INS
	MOVE	*A8(OCTRL),A14,W
	ORI	M_FLIPH,A14
	MOVE	A14,*A8(OCTRL),W
MC_INS	
	CALLA	INSERT_OBJ
	ADDI	CURTAIN_X_INC,A9
	DSJ	A10,MC_LUPE
MC_DONE
	CLR	A14
	MOVE	A14,*A11,L
	RETS

CURTAIN_INIT
	.LONG	DHUNGA0, DUMCOLL
	.WORD	OID_JUNK, DMAWNZ, M_MANSCALE, 0
	.LONG	0

CURTAIN_OPEN_ANIM
	LW	DHUNGZ1,3
	LW	DHUNGZ3,3
	LWL	DHUNGZ5,3|AFunc,PULL_ANIM

**************************************************************************
*								         *
* REVEAL_SECRET_ENTRANCE						 *
*								         *
**************************************************************************

REVEAL_SECRET_ENTRANCE
	MOVI	FGLIST,A0
	MOVE	A0,A8
	MOVI	CURTAIN_OPEN_ANIM,A1
	MOVI	CURTAIN_X_START+(CURTAIN_X_INC*5),A2
	MOVI	CURTAIN_X_START+(CURTAIN_X_INC*6),A3
	MOVI	DHUNGA0,A4
	MOVK	2,A5
RSE_LUPE
	MOVE	*A8(OBLINK),A8,L
	CMP	A0,A8
	JREQ	RSE_DONE				;BR=END OF LIST

	MOVE	*A8(OIMG),A14,L
	CMP	A4,A14
	JRNE	RSE_LUPE				;BR=NOT A CURTAIN OBJECT

	MOVE	*A8(OXVAL),A14,L
	CMP	A2,A14
	JREQ	RSE_ANIM				;BR=FOUND THIS CURTAIN
	CMP	A3,A14
	JRNE	RSE_LUPE				;BR=NOT THE RIGHT ONE
RSE_ANIM
	CALLA	STRT_ANIM
	DEC	A5
	JRNZ	RSE_LUPE				;BR=MORE TO ANIMATE
RSE_DONE
	RETS

**************************************************************************
*								         *
* CURTAIN_UPDATE_PROC							 *
*								         *
**************************************************************************

CURTAIN_UPDATE_PROC
	MOVK	TOTAL_CURTAINS,A9			;NUMBER OF CURTAINS
	MOVK	M_NOSCALE,A10
	MOVI	-1,A11
CUP_RESTART	
	MOVE	A13,A0
	ADDI	PDATA,A0
CUP_LUPE
	MOVE	*A0,A8,L
	JRZ	CUP_NAP					;BR=NO MORE CURTAINS
	JRN	CUP_LUPE				;BR=NO CURTAIN AVAIL

	.if	DEBUG
	MOVB	*A8(OCTRL+B_INUSE-7),A14
	LOCKON	NN
	.endif	
	
	MOVE	*A8(OZVAL),A3,L
	MOVE	@ZBASE,A14,L
	SUB	A14,A3
	CMPI	ZMAX_REAL,A3
	JRGT	CUP_GO					;BR=DON'T DELETE
	MOVE	A11,*A0,L				;FLAG DELETED
	CALLA	DELETE_OBJ
	DEC	A9
	JAZ	SUCIDE					;BR=NO MORE OBJECTS
	ADDK	020H,A0
	JRUC	CUP_LUPE
CUP_GO
	ADDK	020H,A0

	MOVE	A3,A14
	SRA	Z2SCALE+4,A14
	SRA	Z2SCALE+2,A3
	SUB	A14,A3
	MOVE	*A8(ONuManScl),A14,W
	CMP	A14,A3
	JREQ	CUP_LUPE
	MOVE	A3,*A8(ONuManScl),W

	MOVE	*A8(OFLAGS),A14,W
	ANDN	A10,A14
	MOVE	A14,*A8(OFLAGS),W

	JRUC	CUP_LUPE

CUP_NAP
	SLEEP	1
	JRUC	CUP_RESTART

**************************************************************************
*								         *
* S_DEL_AND_REMOVE_ID							 *
*								         *
**************************************************************************

S_DEL_AND_REMOVE_ID
	MOVE	*A11+,a2,W			;ID
	SLL	6,A2				;ID << 6
	MOVE	@RAMREF0,A0,L
	MOVE	@RAMREF1,A1,L

SDARI_LUPE
	MOVE	*A0(MAP_OBJ),A8,L
	JRZ	SDARI_NEXT			;BR=THIS IS THE HEAD
	CMPI	-1,A0
	JAEQ	SCRL_DISPATCHER			;BR=THIS IS THE TAIL

	MOVE	*A0(MAP_FLAGS),A14,W
	ANDI	07C0H,A14			;MASK OUT ID
	CMP	A2,A14
	JRNE	SDARI_NEXT

	MOVE	A8,A8
	JRN	SDARI_REMOVE			;BR=JUST REMOVE LINK
	
	CLR	A14				;DELETE OBJECT
	MOVE	A14,*A8(OULINK),L
	CALLA	DEL_PROC_AND_OBJ
SDARI_REMOVE
	CMP	A1,A0
	JRNE	SDARI_MORE			;BR=NOT LAST ON SCREEN
	CALLA	REMOVE_AND_FREE_LINK		;REMOVE LINK
	JAUC	SCRL_DISPATCHER
SDARI_MORE
	MOVE	*A0(MAP_NEXT),A3,L		;GET NEXT LINK
	CALLA	REMOVE_AND_FREE_LINK		;REMOVE LINK
	MOVE	A3,A0
	JRUC	SDARI_LUPE
SDARI_NEXT
	CMP	A1,A0
	JAEQ	SCRL_DISPATCHER			;BR=DA LAST ON SCREEN

	MOVE	*A0(MAP_NEXT),A0,L

	JRUC	SDARI_LUPE

**************************************************************************
*								         *
* FINAL_STAGE_SCROLL							 *
*								         *
**************************************************************************

FINAL_STAGE_SCROLL

	.LONG	S_SET_WORD
	.long	HELGA_INUSE		; wait for mass speech start
	.word	-1

	LW	S_AUDIT, AUDWEMBLEY

;	.LONG	S_CHANGE_ZFAR
;	.LONG	050000H

	.LONG	S_SET_LONG
	.LONG	WXBUFFER
	.LONG	0500000H

	.LONG	S_SET_LONG
	.LONG	WYBUFFER
	.LONG	0780000H

	.LONG	S_SET_WORD
	.LONG	UNIVERR
	.WORD	1

	.LONG	S_CREATE_PROCR				;DAMAGE COLOR CYCLES
	.WORD	PID_DAMCC
	.LONG	12,62,61,SPKR1p,CYCLE16			;SPEAKER LIGHT
	.WORD	PID_DAMCC
	.LONG	9,63,56,SPKDAM2p,CYCLE16		;SPEAKER DAMAGE
	.WORD	0

	.LONG	S_SET_WORD
	.long	SNOZZ_COUNT		; use as wall count
	.word	0

	.LONG	S_CREATE_PROCR
	.word	PID_IND
	.long	0,0,0,-10000h,FLOAT_ZFAR	; behind wall
	.word	0

	.LONG	S_WAIT_HERE
	.word	60

	.LONG	S_GOTO_POINT0
	.word	100
	.word	CENTER_STAGE_X,STAGE_Y
;	.word	CENTER_STAGE_X+(STAGE_WID>>1),STAGE_Y+(STAGE_HT>>1)
	.long	-2d000h
	.word	5

	.LONG	S_SET_WORD
	.long	HELGA_INUSE		; begin mass speech
	.word	0

	.LONG	S_SET_LONG, WORLD_GRNDOFF, -580000H

	.LONG	S_CREATE_PROC
	.word	PID_IND
	.long	SYNC_UP_WALL

;	.LONG	S_WAIT_HERE
;	.word	95

	.LONG	S_SET_WORD
	.LONG	NONBOY_SHOOT_CHANCE
	.WORD	512

	.LONG	S_DISPATCH_HERE			;Set quota for roof top
	.long	DSP_FINALE_1+M_WAIT
	.word	0

STAGE_LP:
	.LONG	S_GOTO_POINT0
	.word	140
	.word	0cah,108h
	.long	-21000h
	.word	0

	.LONG	S_GOTO_POINTXY
	.word	140
	.word	260h,70h
	.word	0

	.LONG	S_GOTO_POINT0
	.word	360
	.word	0f5h,0a4h
	.long	-27000h
	.word	0

	.LONG	S_GOTO_POINTXY
	.word	280
	.word	240h,0d5h
	.word	0

	.LONG	S_GOTO_POINT0
	.word	120
	.word	0258h,090h
	.long	-24000h
	.word	0

	.LONG	S_GOTO_POINTXY
	.word	120
	.word	0f0h,0ech
	.word	0

	.LONG	S_GOTO_POINT0
	.word	280
	.word	CENTER_STAGE_X,0c5h
	.long	-2C000h
	.word	0

	.LONG	S_GOTO_POINT0
	.word	280
	.word	260h,05ah
	.long	-1c000h
	.word	0

	.LONG	S_GOTO_POINTXY
	.word	220
	.word	0f0h,05ah
	.word	0

	.LONG	M_JUMP+STAGE_LP

WALL_DOWN:
	.LONG	S_SET_WORD		; kill float process
	.long	SCROLLKILL
	.word	1

	.LONG	S_CREATE_PROC
	.word	PID_IND
	.long	BLOW_WALL_PROC


	.LONG	S_DISPATCH_HERE
	.long	WAVE1END+M_WAIT
	.word	0

	.LONG	S_GOTO_POINT0
	.word	20
	.word	CENTER_STAGE_X,STAGE_Y
	.long	-2a000h
	.word	20

	.LONG	S_CALL
	.LONG	MAKE_CURTAIN

	.LONG	S_CREATE_PROCR
	.WORD  	PID_MONDOR
	.LONG	-010003H,-0788000H,019A0000H,1,MONDOR_PROC
	.WORD	0

	.LONG	S_SET_LONG
	.LONG	WXBUFFER
	.LONG	0

	.LONG	S_WAIT_HERE
	.word	35

	.LONG	S_CHANGE_ZFAR
	.LONG	050000H

	.LONG	S_CREATE_PROCR
	.word	PID_IND
	.long	0,0,0,16C80h,FLOAT_ZFAR	       	; behind curtain
	.word	0

	.LONG	S_WAIT_HERE
	.word	30

*
*	START HELGA FIGHT
*
;	.LONG	S_SET_WORD
;	.LONG	GUNS_OFF
;	.WORD	1

	.LONG	S_CLR_SCROLL_FLAG
	.LONG	-1

;	.LONG	S_WAIT_HERE
;	.WORD	90

	.LONG	S_GOTO_POINT
	.WORD	60*2				;DURATION
	.WORD	CENTER_STAGE_X,060H		;X, Y, Z DESTINATION
	.LONG	-01D06CH
	.WORD	0

	.LONG	S_DEL_AND_REMOVE_ID		;GET RID OF SPEAKERS
	.WORD	6

	.LONG	S_SET_WORD
	.LONG	GUNS_OFF
	.WORD	1

	.LONG	S_SET_LONG, WORLD_GRNDOFF, -5C0000H

	.LONG	S_SET_LONG
	.LONG	WXBUFFER
	.LONG	040000H

	.LONG	S_SET_LONG
	.LONG	WYBUFFER
	.LONG	0430000H

	.LONG	S_SET_WORD
	.LONG	UNIVERR
	.WORD	1

;	.LONG	S_WAIT_HERE
;	.WORD	2
;
;	.LONG	S_SET_WORD
;	.LONG	UNIVERR
;	.WORD	1
;
;	.LONG	S_WAIT_HERE
;	.WORD	2
;
;	.LONG	S_SET_WORD
;	.LONG	UNIVERR
;	.WORD	1

;	.LONG	SKIP_HELGA+M_JUMP

	.LONG	S_CALL
	.LONG	START_FINAL_HELGA

	LW	S_WAIT_HERE,200

	.LONG	S_CREATE_PROCR		;Start the powerups
	.WORD	PID_POWERUPD0
	.LONG	0A000H,06000H,60*5,60*5,PROC_DROP_PACK
	.WORD	0

	.LONG	S_WAIT_UNTIL_TRUE
	.LONG	SCROLL_FLAG			;HELGA IN THRONE?

	.LONG	S_KILL_POWERUPS			;Whack those powers

	.LONG	S_SET_LONG, WORLD_GRNDOFF, -700000H

	.LONG	S_GOTO_POINT
	.WORD	60				;DURATION
	.WORD	CENTER_STAGE_X,078H		;X, Y, Z DESTINATION
	.LONG	-018004H
	.WORD	0

	.LONG	S_WAIT_UNTIL_TRUE, MONDOR_MORPH_FLAG	;Wait until Mondor morphs

	.LONG	S_LOAD_BOSS_PUNISH

	.LONG	S_SOUND, SND_WHOAH

	.LONG	S_GOTO_POINT
	.WORD	30				;DURATION
	.WORD	CENTER_STAGE_X,060H		;X, Y, Z DESTINATION
	.LONG	-01D06CH
	.WORD	0

	LW	S_WAIT_HERE,30

	.LONG	S_CREATE_PROCR		;Start the powerups
	.WORD	PID_POWERUPD0
	.LONG	08000H,05800H,60*3,60*3,PROC_DROP_PACK
	.WORD	0

	.LONG	S_CLR_SCROLL_FLAG
	.LONG	-1

	.LONG	S_WAIT_UNTIL_TRUE
	.LONG	SCROLL_FLAG			;GO BACKSTAGE?
SKIP_HELGA
	.LONG	S_SET_WORD
	.LONG	GUNS_OFF
	.WORD	1

	.LONG	S_CALL
	.LONG	CREATE_AEROSMITH_WALK

	LW	S_WAIT_HERE,200

	.LONG	S_SOUND, SND_WALK_XITION

	.LONG	S_SET_WORD		; kill float process
	.long	SCROLLKILL
	.word	1

	LW	S_WAIT_HERE,500

	.LONG	S_SET_LONG
	.LONG	WXBUFFER
	.LONG	0700000H

	.LONG	S_SET_LONG
	.LONG	WYBUFFER
	.LONG	09C0000H

	.LONG	S_SET_LONG
	.LONG	XSCROLL
	.LONG	046000H

	LLLW	S_WAIT_FOR_COORD,XBASE,02910000H,1 ;Scroll to entrance aisle

;	.LONG	S_SET_LONG
;	.LONG	ZSCROLL
;	.LONG	06800H

	.LONG	S_DOZER_ACCEL
;	.WORD	150 << 8 + M_X << 3 + M_Z + M_X
	.WORD	75 << 8 + M_X << 3 + M_Z + M_X
	.LONG	03360000H				;X BOUNDARY
	.LONG	0					;X TARGET VELOCITY
	.LONG	08000H					;Z TARGET VELOCITY

	.LONG	S_WAIT_FOR_COORD
	.LONG	ZBASE
	.LONG	08C80H
	.WORD	1

	.LONG	S_CALL
	.LONG	REVEAL_SECRET_ENTRANCE

	.LONG	S_SET_LONG, WORLD_GRNDOFF, 0

	.LONG	S_SET_VECTOR_TABLE
	.LONG	BACKSTAGE_VECT_TABLE

	.LONG	S_CREATE_PROCR				;DAMAGE COLOR CYCLES
	.WORD	PID_DAMCC
	.LONG	10,63,56,pdpal1,CYCLE16			;PROSCENIUM DAMAGE
	.WORD	PID_DAMCC
	.LONG	10,63,58,PILBOT2,CYCLE16		;PILLAR BOTTOM DAMAGE
	.WORD	0

	.LONG	S_AT_PORTAL_ENTRANCE

	.LONG	S_SET_PORTAL		; Search For Portal we are centered on
	.WORD	15

	.LONG	S_ENTER_PORTAL		; Set up and enter new universe
	.long	GXPLSAL1+M_EP_DONT_STOP		; name of universe
	.long	-0D200H,-047F0000H,0		; Z, X, Y offsets

	.LONG	S_SET_WORD
	.LONG	GUNS_OFF
	.WORD	0

	.LONG	S_WAIT_FOR_COORD
	.LONG	ZBASE
	.LONG	019000H
	.WORD	0

	.LONG	S_GOTO_POINT
	.WORD	10				;DURATION
	.WORD	-047FH,0			;X, Y, Z DESTINATION
	.LONG	019000H
	.WORD	0

	.LONG	S_SET_LONG
	.LONG	WXBUFFER
	.LONG	0200000H

	.LONG	S_SET_LONG
	.LONG	WYBUFFER
	.LONG	0200000H

;	.LONG	S_GOTO_POINT0
;	.WORD	60*60				;DURATION
;	.WORD	04CH,0				;X, Y, Z DESTINATION
;	.LONG	019000H
;	.WORD	0

	.LONG	S_X_ACCEL_LIMIT
	.WORD	0100H
	.LONG	08000H

	LLLW	S_WAIT_FOR_COORD,XBASE,-0AC0000H,1 ;Scroll to entrance aisle

	.LONG	S_SET_WORD
	.LONG	GUNS_OFF
	.WORD	1

	.LONG	S_CALL
	.LONG	MAKE_BS_AEROSMITH

	.LONG	S_GOTO_POINT0
	.WORD	90				;DURATION
	.WORD	04CH,0				;X, Y, Z DESTINATION
	.LONG	019000H
	.WORD	0

	.LONG	S_GOTO_POINT
	.WORD	10				;DURATION
	.WORD	04CH,0				;X, Y, Z DESTINATION
	.LONG	019000H
	.WORD	0

	LW	S_WAIT_HERE,15

	.LONG	S_CALL
	.LONG	MAKE_BS_AEROSMITH_ANIM

	LW	S_AUDIT, AUDBACKSTAGE

	.LONG	S_CLR_SCROLL_FLAG
	.LONG	-1

	.LONG	S_WAIT_UNTIL_TRUE
	.LONG	SCROLL_FLAG			;Wait for backstage to finish

;	LLW	S_SET_WORD, BONUS_DIRECTION, 3
	LLW	S_SET_WORD, BONUS_DIRECTION, 0

	LWL	S_CREATE_PROC, PID_IND, WAVE_END_IMM

	.LONG	S_DIE

SND_WHOAH
	.WORD	0F3D1H,67,08805H,0		;"Whoah"

SYNC_UP_WALL:
	movk	3,a9
SUW_lp:
	RANDSLP	1200,2000
	movi	-1,a0			; sync em up
	move	a0,@HELGA_INUSE

	sleep	120

	clr	a0
	move	a0,@HELGA_INUSE

	dsjs	a9,SUW_lp
	DIE


*****************************************************
*						    *
*	 TV Collision handling			    *
*						    *
*****************************************************

TV_CVECT
	WWL	OID_PROCKET,~MASK_PLAYER,UNIV_ROCKET_COLL
	WWL	OID_PEXPLOSION,~MASK_PLAYER,TV_COLLVECT
	WL	0,DUMCRETS


TV_COLLVECT
	CALLA	UNIV_COLL_CHECK
	JRNZ	TVX
	MOVE	*A0(OID),A0,W			;GET PLAYER DATA ADDRESS
	CALLA	POID_TO_PDATA

	movi	M_NEXTFRM|M_NOMORE,a7 	; flags
	jruc	tvchk
TV_GUNVECT
	movk	M_FLASHOBJ|M_NOMORE,a7
tvchk:
	clr	a9
	movi	2000,a5
	CALLA	UNIV_DAMAGE_HANDLER
	jrc	TV_lstfrm

	move	a10,a10		; any change?
	jrz	TVX		; BR = no

	SOUNDZ	SND_TV_CRACK
	rets

TV_lstfrm:
	MMTM	SP,B1,B2,B4,B5,B6,B8,B9,B10		;MAKE STALL DOOR FRAGMENTS

	SOUNDZ	SND_TV_POP
*
*	Remove picture
*
	move	*a8(OULINK),a3,L
	move	*a3(MAP_SPAREL1),a6,L 	; picture object
	jrz	TV_skpdel
	move	a8,a5		; save
	move	*a6(OPARTS),a1,L
	move	*a1(OFLAGS),a14
	btst	B_ANIM,a14  	; is this monitor speaking to us?
	jrz	TV_notspking

	clr	a10
	movk	20,a11

	MOVI	256,A0
	CALLA	RANDPER
	JRNC	TV_GIVE_CD

	MOVE	@SUPERGUN_AWARDS,A14,W
	JRNZ	TV_GIVE_CD

	CREATE	PID_IND,REVEAL_SUPERGUN2
	JRUC	TV_GIVEN

TV_GIVE_CD
	CREATE	PID_IND,REVEAL_CD2
TV_GIVEN

	move	@HELGA_INUSE,a14	; don't clear if trying to sync
	jrle	TV_noclr
	cmpi	0abch,a14		; special code means they are in sync
	jreq	TV_notspking
	CREATE	PID_IND,CLR_HELGA_INUSE
TV_noclr:
	movi	HELG_CUTOFF_TBL,a1
	movk	11,a0
	calla	TAB_SOUND
TV_notspking:
	move	a6,a8		; picture object in a8
	calla	DELETE_OBJ
	move	a5,a8		; restore
	CLRM	*a3(MAP_SPAREL1),L
TV_skpdel:

	MOVI	040000H,A0
	clr	a3
	CALLA	PreFrag_Box
	MOVI	-0FFH,B9			;MIN Z VEL
	MOVI	-01H,B10			;MAX Z VEL
	MOVI	FRG_GL_12_2X,B14
	CALLA	Fragger

	MOVE	*A8(OIMG),A1,L
	MOVE	*A1(ICMAP),*A0(FPDATA),L	;SET PALETTE

	MMFM	SP,B1,B2,B4,B5,B6,B8,B9,B10

	move	@SNOZZ_COUNT,a14
	inc	a14
	move	a14,@SNOZZ_COUNT
	cmpi	35,a14
	jrlt	TVX
*
*	ALL WALL PIECES DESTROYED.  NOW WHAT?
*
	.IF DEBUG
	CALLA	VALID_PLAYER
	.ENDIF
	MOVI	20,A10				;Delay for smart bomb
	MOVE	A2,A11
	CREATE	PID_IND,PROC_DELAYED_SBOMB	;Smart bomb effect for landing

	movi	WALL_DOWN,a0
	calla	CHNG_SCRL_TBL

TVX:
	rets


SND_TV_POP
	.word	0f270h,74,0a3cdh,0

SND_TV_CRACK
	.WORD	0F20BH,47,0A32aH,0



*****************************************************
*						    *
*	 VECTOR TABLE				    *
*						    *
*****************************************************

FINAL_VECT_TABLE:
; 1
	.LONG	0,0
;2, 3		       
	.LONG	DUMCOLL,DUMRETS,SPOTLIGHT_COLLVECT,SPOTLIGHT_GUNVECT
;4, 5		       
	.LONG	0,0,0,0
;6, 7		       			; tv = 6, speakers = 7
	.LONG	TV_CVECT,TV_GUNVECT,PASPEAKER_COLLVECT,PASPEAKER_GUNVECT
;8, 9
	.LONG	0,0,0,0
;10, 11
	.LONG	0,0,0,0
;12, 13
	.LONG	0,0,0,0
;14, 15
	.LONG	0,0,0,0
;16, 17
	.LONG	0,0,0,0
;18, 19
	.LONG	0,0,0,0
;20, 21
	.LONG	0,0,0,0
;22, 23
	.LONG	0,0,0,0
;24, 25		   
	.LONG	0,0,0,0
;26, 27
	.LONG	0,0,0,0
;28, 29
	.LONG	0,0,0,0
;30, 31
	.LONG	0,0,0,0
;32
	.LONG	0,0


*****************************************************
*						    *
*	 HELGA PICTURE IN TV			    *
*						    *
*****************************************************

*
*	Anim Func called by static TV set upon creation
*	This creates the COLORBAR/HELGA PICTURE
*
CREATE_PICTURE:
	movi	HELG_PIC_INIT,b0
	calla	EASYMAKE
	jrz 	CP_fail
	move	*a8(OXVAL),a1,L
	move	*a8(OYVAL),a2,L
	move	*a8(OZVAL),a3,L
	addi	100h,a3
	calla	SETOFFPU
	calla	INSOBJ

	move	*a8(OULINK),a4,L	; change TV's damage table
	move	a0,*a4(MAP_SPAREL1),L	; save this
	movi	TV_dam_tbl+4,a1
	move	a1,*a4(MAP_IMG),L

	jauc	PULL_ANIM

TV_dam_tbl:
	.long  TV1+0
	.word  10
;	.word  1
	.long  TV2
	.word  10
;	.word  1
	.long   TV3+8


*
*	Init table for helga picture
*
HELG_PIC_INIT:
	.long	COLRBAR
	.word	DMAWNZ,0,OM_ANIM
	.long	PicTubeAnim


*
*	Animation of COLORBAR/HELGA PICTURE
*
PicTubeAnim:
   LW    COLRBAR,120
   LW    1,120
   LWLL  1,120|AFunc,A_MAKE_PART+2,HELG_MOUTH_INIT
SyncLoopAnim:
   LWL   1,1|AFunc,WAIT_FOR_HELTALK_SIGNAL
   LWLL  IWILLDESTROY,1|AFunc,A_CHANGE_PAL+2,IWDY_GRN
   LWL   1,100|AFunc,START_SYNC_TALK
   LWL   1,10|AFunc,A_Set_LOOP_STRT

   LWLL  COLRBAR,120|AFunc,A_CHANGE_PAL+2,COLRBAR_P
   LW	 1,120
   LWL   1,5|AFunc,A_HELGA_SPEECH_WAIT
   LWL	 IWILLDESTROY,110|AFunc,START_HELGA_TALK
   .long  0


WAIT_FOR_HELTALK_SIGNAL:
	move	@HELGA_INUSE,a14	; wait til zero to sync all monitors
	jrz	AWFSH_proceed
	jruc	AHSW_X



HELG_MOUTH_INIT:
	.long	NDEST01
	.word	DMAWNZ,M_NODISP|M_NOPARTANI,OM_CFUNC
	.long	C_SET_OZOFF
	.word	-1


HELG_DEST_ANIM:
	LWLL	NDEST01,1|AFunc,A_SOUNDZ+2,SND_HELG_DEST
	LWL	1,10|AFunc,OBJ_ON
	LW	NDEST02,10
	LW	NDEST03,10
	LW	NDEST04,10
	LW	NDEST05,10
	LW	NDEST06,10
	LW	NDEST07,10
	LWL	1,20|AFunc,OBJ_OFF
	LWL	1,1|AFunc,END_HELGA_TALK


HELG_OBEY_ANIM:
	LWLL	NOBEY01,1|AFunc,A_SOUNDZ+2,SND_HELG_OBEY
	LWL	1,8|AFunc,OBJ_ON
	LW	NOBEY02,6
	LW	NOBEY03,11
	LW	NOBEY04,12
	LW	NOBEY05,11
	LW	NOBEY06,10
	LW	NOBEY07,10
	LW	NOBEY08,10
	LWL	1,20|AFunc,OBJ_OFF
	LWL	1,1|AFunc,END_HELGA_TALK


IWD_PALS
	.long	IWDY_GRN,IWDY_BLU,IWDY_RED,IWDY_YEL



START_SYNC_TALK:		; always I will destroy you in Green
	movi	0abch,a0
	move	a0,@HELGA_INUSE		; set flag and go to next frame
	jruc	HelTalkHk


START_HELGA_TALK:
	movk	4,a0
	calla	RAND0
	sll	5,a0
	addi	IWD_PALS,a0
	move	*a0,a0,L
	calla	CHANGE_PAL		; pick a palette

	movi	HELG_OBEY_ANIM,a1
	move	@RAND,a14
	btst	12,a14
	jrnz	SHTrand
HelTalkHk:
	movi	HELG_DEST_ANIM,a1
SHTrand:
	move	*a8(OPARTS),a0,L
	jrz	SHTX
	calla	STRTANIM
CP_fail:
SHTX:
	rets


END_HELGA_TALK:
;	move	*a8(OPART1),a1,L
;	move	@WAVEIRQS,a0
;	move	a0,*a1(ODATA)		; save time, can't talk again for 5 sec
	move	@HELGA_INUSE,a14
	jan	PULL_ANIM		; don't reset if trying to sync all
	clr	a14
	move	a14,@HELGA_INUSE
	jauc	PULL_ANIM


CLR_HELGA_INUSE:
	sleep	75		; time before another helga taunt
	move	@HELGA_INUSE,a14
	jan	SUCIDE
	jaz	SUCIDE
	clr	a0
	move	a0,@HELGA_INUSE
	DIE


C_SET_OZOFF:
	move	*b0+,b14
	move	b14,a1
	movb	a1,*a0(OZOFF)
	rets

HELG_CUTOFF_TBL
	.long	SND_HELG_G0,SND_HELG_G1,SND_HELG_G2,SND_HELG_SML
	.long	SND_HELG_MED1
	.long	SND_HELG_G0,SND_HELG_G1,SND_HELG_G2,SND_HELG_SML
	.long	SND_HELG_MED1,SND_HOW_DARE

SND_HOW_DARE
	.word	0e39ch,78,08575h,0

SND_HELG_G0
	.word	0e39ch,17,08579h,0

SND_HELG_G1
	.word	0e39ch,16,0857ch,0

SND_HELG_G2
	.word	0e39ch,16,0857fh,0

SND_HELG_SML
	.word	0e39ch,19,08582h,0

SND_HELG_MED1
	.word	0e39ch,31,08588h,0

SND_HELG_OBEY
	.word	0e39bh,81,0859dh,0

SND_HELG_DEST
	.word	0e39bh,93,0859ch,0


SYNC_MONITORS:
	movi	SyncLoopAnim,a1		; return to start of sequence
	move	a1,*a8(AnimFrm),L
	move	a1,*a8(AnimScr),L
	MOVKB	1,*a8(AnimSlp)
	rets


A_HELGA_SPEECH_WAIT:
	move	@HELGA_INUSE,a14	; can't talk if someone else is
	jrn	SYNC_MONITORS
	jrnz	AHSW_X

;	move	*a8(ODATA),a1		; get time of last speech
;	move	@WAVEIRQS,a0
;	sub	a1,a0
;	cmpi	300,a0			; can't do another for 5 secs.
;	jrle	AHSW_X

	move	*a8(ODAG),a0,L		; upper left
	movi	[SKYTOPOF+20,22],a2   	; allowable upper left
	movi	[252,398],a3	    	; allowable lower rt
	clr	a4
	move	@XSCROLL,a14,L
	jrge	AHSW_Xadj
	movk	20,a4
AHSW_Xadj:
	move	@YSCROLL,a14,L
	jrge	AHSW_Yadj
	addi	[20,0],a4
AHSW_Yadj:
	subxy	a4,a2
	subxy	a4,a3
	cmpxy	a2,a0
	jrxle	AHSW_X
	jryle	AHSW_X
	move	*a8(OSIZE),a1,L
	addxy	a0,a1			; lower rt in a1
	cmpxy	a3,a1
	jrxgt	AHSW_X
	jrygt	AHSW_X

	movk	1,a0
	move	a0,@HELGA_INUSE		; set flag and go to next frame
	rets

AHSW_X:	
	move	*a8(AnimFrm),a14,L	; stay on this frame
	subi	50h,a14
	move	a14,*a8(AnimFrm),L
AWFSH_proceed:
	rets
	

IWDY_RED:
   .word   64 
   .word   00000h,07fffh,00000h,072f4h,06ed3h,06a91h,06ab2h,066b2h
   .word   06691h,06270h,0626fh,05e70h,05e4fh,05a2eh,0560dh,0562eh
   .word   051edh,04deeh,04dech,049cbh,049a9h,045cch,044c6h,041aah
   .word   03d8ah,03d89h,03d68h,03947h,03568h,03442h,03126h,03105h
   .word   02d07h,02cc3h,028e4h,024c4h,020a3h,01c61h,01883h,01063h
   .word   01041h,00821h,073bch,02549h,02128h,01d07h,018e6h,014c5h
   .word   010a4h,00c83h,00862h,00441h,06b59h,05ef6h,04a51h,03deeh
   .word   01083h,00841h,00442h,04732h,05ca0h,050a0h,03480h,02440h


IWDY_BLU:
   .word   64 
   .word   00000h,07fffh,00000h,072f4h,06ed3h,06a91h,06ab2h,066b2h
   .word   06691h,06270h,0626fh,05e70h,05e4fh,05a2eh,0560dh,0562eh
   .word   051edh,04deeh,04dech,049cbh,049a9h,045cch,044c6h,041aah
   .word   03d8ah,03d89h,03d68h,03947h,03568h,03442h,03126h,03105h
   .word   02d07h,02cc3h,028e4h,024c4h,020a3h,01c61h,01883h,01063h
   .word   01041h,00821h,073bch,02549h,02128h,01d07h,018e6h,014c5h
   .word   010a4h,00c83h,00862h,00441h,06b59h,05ef6h,04a51h,03deeh
   .word   01083h,00841h,00442h,00259h,000b7h,000d4h,000adh,00049h


IWDY_YEL:
   .word   64 
   .word   00000h,07fffh,00000h,072f4h,06ed3h,06a91h,06ab2h,066b2h
   .word   06691h,06270h,0626fh,05e70h,05e4fh,05a2eh,0560dh,0562eh
   .word   051edh,04deeh,04dech,049cbh,049a9h,045cch,044c6h,041aah
   .word   03d8ah,03d89h,03d68h,03947h,03568h,03442h,03126h,03105h
   .word   02d07h,02cc3h,028e4h,024c4h,020a3h,01c61h,01883h,01063h
   .word   01041h,00821h,073bch,02549h,02128h,01d07h,018e6h,014c5h
   .word   010a4h,00c83h,00862h,00441h,06b59h,05ef6h,04a51h,03deeh
   .word   01083h,00841h,00442h,04732h,05ee0h,05280h,035a0h,02520h


*****************************************************
*						    *
*	 BLOW AWAY THE WALL			    *
*						    *
*****************************************************
BLOW_WALL_PROC:
	sleep	80
	movi	35,a9		; number of sets to blow
restart_list:
	movi	FGLIST,a8
	move	a8,a11
	movi	OID_UNIV,a5
nutherTV:
	move	*a8+,a8,L
	cmp	a8,a11
	jrne	BWP_cont
	sloop	1,restart_list	; sleep and start again at beginning of list

BWP_cont:
	move	*a8(OID),a14
	andn	a5,a14
	cmpi	ID_5,a14
	jrne	nutherTV
*
*	Found a TV
*	
	CREATE	PID_IND,FOLLOW_EXPLOS
	calla	FLY_AWAY
	MOVIM	2800h,*a8(OYACCEL),W
	move	*a8(OYVEL),a14,L
	subi	50000h,a14
	move	a14,*a8(OYVEL),L
	movi	-200h,a1
	movi	-0c0h,a0
	calla	RANGRAND		; get a random Z vel
	move	a0,*a8(OZVEL),L
	dec	a9
	jrnz	nutherTV

	SOUND1	SND_FINAL_EXPLODE3
	SLEEP	1
	SOUND1	SND_FINAL_EXPLODE2
	SLEEP	1
	SOUND1	SND_FINAL_EXPLODE1

	DIE


FOLLOW_EXPLOS:
	RANDSLP	5,20

	move	*a8(OFLAGS),a14
	btst	B_OFSCRN,a14
	janz	SUCIDE

	move	*a8(OCTRL),a14
	btst	B_INUSE,a14
	jaz	SUCIDE

	movi	M_DBLSCL,a3
	calla	MAKE_EXPLO_CENTER
	SOUND1	SND_EXPLO_L
 	DIE

;;;	jruc	FOLLOW_EXPLOS

SND_EXPLO_L:
	.word	0e370h,120,0a38dh,0	; generic explo

	.END
