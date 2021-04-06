  	.MLIB	"GXMACS.LIB"
 	.FILE	"GXJUNGLE.ASM"
	.TITLE	" <<< GENERATION X -- JUNGLE UNIVERSE >>>"
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
	.INCLUDE	"GXENEMY.INC"
	.include	"univtbl.glo"
	.include	"gxjung.tbl"
	.include	"gxscrl.h"
	.include	"gxnonboy.h"
	.include	"gxnatv.h"
	.text

	.ref	RUBBLE2,RUBBLE3,RUBBLE4,RUBBLE5,RUBBLE6,RUBBLE7
	.ref	RUBBLE8,RUBBLE9,ROBBLE2,ROBBLE3,ROBBLE4,ROBBLE5
	.ref	NUM_SPEARS,MAX_SPEARS_ALLOWED,POWERUP_GUNVECT,REXPLO
	.ref	ROBBLE6,ROBBLE7,ROBBLE8,GLOW_BLUE,ENEMY_ZW_MAX,NOTICE_DAMAGE
	.ref	A_Set_LOOP_STRT,A_OFFSCRN_DEL,A_SET_OXVEL,JEWELB_P
	.ref	SECRET_SCROLL,CURPLYR_ADJ,METAL_GUNVECT,JOE_PERRY_TRIP
	.ref	DGV_FRAG_DUST_BRN,DGV_FRAG_DUST_GRY,SET_SCRN_POS
	.ref	SEC_DR_TABLE
	.ref	MAKE_EXPLO_OFF,MC_MAKE_GLASS,SND_MIRROR_CRACK, SND_METAL_HIT

	.def	S_START_GOOP,S_RESET_VIDCAM,S_CREATE_PILLAR_BOYS       
	.def	S_CREATE_ATRIUM_BOYS,S_WAIT_FOR_ZIPOK,MORFGLASOUT
	.def	PILLAR_ADV,SIGN_DOWN,S_INIT_JUNGLE,ADD_SKULL_PARTS,SAVE_ME
	.def	JXLIMIT,NMEEZ_GONE1,SKY_SND_TAB,FRG_GL_10,FRG_BRONLY_12
	.def	ATTACK_TIME,JUNGLE_VECT_TABLE,BLDG_VECT_TABLE,FRG_GL_12
	.def	CHEM_VECT_TABLE,HALL_LOCKOUT,VIDCAM_CVECT,VIDCAM_GUNVECT
	.def	VIDCAM_HOLDTIME,VIDCAM_Z,DO_FLASH_DINK,METAL_DR_GUNVECT
	.def	Do_Dink,MAX_ALLOWED,GLAS_GRND_COLL,S_INIT_POPQUO 
	.def	ROCK_IN_X,WARTHROW,PLYR_SEEN,NUM_PILLARS,NUM_OUT_THERE
	.def	A_RESTART_PILLBOY,JUNGDIECALL,WVSTRT_CHANCE,S_SET_IRQSTRT
	.def	S_SEND_ELEV_DOWN,A_CAN_I_POPUP,FRG_BOX_8,JEWEL_AWARD
	.def	S_PUSH_WALL_IN,FRG_GL_12_2X

	.def	GREN_CVECT,GREN_GUNVECT,GREN_INIT,explode_gren

	.def	MAKE_VIDCAM_SND,TAB_SOUND, BRIDGE_DESTROYED, SPIN_SIGN_GONE
	.def	MAKE_NOSCALE,S_CREATE_MASS_ATRIUM
	.DEF	BRK_ANIM_1, BRK_ANIM_2

	.DEF	BASIC_CVECT,BASIC_GUNVECT, STONE_BUL_SND
	.DEF	FLY_AWAY,FRG_BR_12,S_CLR_OU_OHITS


	.if GEORGE
	.REF	SCRLFLOW
	.ENDIF

	.bss	NUM_PILLARS,16	; how many pillars in the current corridor
	.bss	SIGN_DOWN,16	; which pieces of sign are down (lower byte)
				; which pices of sign are falling (upper byte)
	.bss	LEGOBJ,32	; object block of me to become leg
	.bss	PILLAR_ADV,32	; flags (16 upper=left pills, lower = rt pils)
	.bss	PILL_CNT,16	; num guys out there now
	.bss	PLYR_SEEN,16	; non-zero if VID CAM was shot promptly
	.bss	SKULLPROC,32	; process which does skull's little shuffle
	.bss	NUMIBALLS,16	; number of iballs out there
	.bss	SKULL_RETREAT,16; does skull go back up (1) or morph (0)
	.bss	JXLIMIT,16	; visible limit for sideways running guys
	.bss	NMEEZ_GONE1,16	; Count of enemies left before moving on
	.bss	ATTACK_TIME,16	; Attack Timer
	.bss	HALL_LOCKOUT,16	; secret hall entry control...
				; 0 = permanent disable
				; neg = temporary disable
				; pos = enabled
	.bss	VIDCAM_Z,32  	    ; WORLD Z at which VIDCAM anim continues
	.bss	VIDCAM_HOLDTIME,16  ; time vidcam will hold before animating
				    ; (Once it is onscreen and closer than
				    ;  VIDCAM_Z)
	.BSS	BRIDGE_DESTROYED,16	;1=Left 2=Right 3=Both pieces destroyed
	.BSS	SPIN_SIGN_GONE,16	;Flag set when spinning sign is gone
	.BSS	SKULL_HITS,16	;   num rocket hits taken by skull
	.bss	IRQSTRT,32	; WAVEIRQS at start of wave
	.bss	JEWEL_OWNER,32	; player data area of player who owns jewel

	.bss	ELEV_Z,32		; Z of elevator in universe
	.bss	ELEVTABLE,3*32
	.bss	EFLOOR,8		; what floor are we on
	.bss	ELEV_MOVING,8		; 0 not moving, pos = up, neg= down
	.bss	MORFGLASOUT,16		; 0 before, 1 after it's gone
;;;;;	.bss	filler,16

*
*	the following replace .include imgtbl.glo
*
	.ref  RUBBLE_P, P_WARLEG,  P_WARDUK,  P_LEVEL, P_ELEVBUT,G_B5SPxSHA4
	.ref  G_B5SPxSHA5,  G_B5SPxSHA6,  G_B5SPxSHA7,  MDSHRD1
	.ref  MDSHRD2,MDSHRD3,MDSHRD4,MDSHRD5,MDSHRD6,P_DESKDM1
	.ref  FLKWOBK_P,P_DESKDM2,P_EBUTS,WAVEIRQS,PLAYER_HIT,P_NONBOYY
	.ref	fshard1,fshard2,fshard3,fshard4,fshard5,fshard6
	.ref	SMSHRD1,fshard7,SMSHRD2,fshard8,SMSHRD3,fshard9
	.ref	SMSHRD4,SMSHRD5,SMSHRD6,SMSHRD7,SMSHRD8,SMSHRD9
	.ref	G_B1SHOOTA1,G_B1SHOOTA2,TREEB1A_P,P_SPOOGE,P_EYEB
	.ref	POINTDM_P,GRENEXP,GREN1,GREN2,GREN3,GREN4,REVEAL_PROCK
	.ref	GREN5,fshard10,GREN6,GREN7,SMSHRD10,SND_DIR_CHOSEN
*
*	end of imgtbl.glo
*

	.ref	TTOP4_CVECT,TTOP4_GUNV,LILP2_CVECT,LILP2_GUNV	
	.ref	PALM_GUNVECT,RUSTLE2_GUNVECT, RAMREF0, RAMREF1
;	.ref CTABLE_COLLVECT,CTABLE_GUNVECT,CHAIRBOY_COLLVECT,CHAIRBOY_GUNVECT
	.ref CTABLE_COLLVECT,CTABLE_GUNVECT
	.ref TRASHCAN_COLLVECT,TRASHCAN_GUNVECT,PHONE_COLLVECT,PHONE_GUNVECT
	.ref	RECEIVER_COLLVECT,RECEIVER_GUNVECT,COIN_DOOR_COLLVECT,COIN_DOOR_GUNVECT
	.ref	HOLD_ENEMY_DISPATCH,ROPE_BRIDGE

	.REF	KERRI_GUNVECT,TRKDR_GUNVECT,TRKDR_CVECT,POWERUP_DURATION
	.REF	MAGDR_GUNVECT,MAGDR_CVECT,HIT_SCREEN	
	.ref	HONEY_DESTROY					
	.REF	NONBOY_HEADON_SHOOT_ANIM,BIG_EXPLOSIONS
	.ref	FLICKER_PAL,RUSTLE_GUNVECT,RUSTLE_CVECT

	.ref   A_Anim_DSJ,OBJENEMIES,P_NONBOYR,WAVEVEL,  XSACCEL,  XSCROLL
	.ref  SND_CHAN0_OFF,  A_SOUND,  PILLAR_DEATH_ANIM,  EASYMAKE
	.ref  CK_PLAYER_HIT,  UNIV_DAMAGE_HANDLER,  ONESND,  BG_TO_FG
	.ref	UNIV_ROCKET_COLL,  UNIV_FLASH,  NONBOY_DROP_INIT,  WYBUFFER
	.ref	ZBASE_HR,  STRTANIM_OFF,  A_CHECK_OETIME,  RAND,  BOX_CHECK_OBJ
	.ref	A_SET_OYVEL,  FRAG_U10,  UNIV_COLL_CHECK,  DELETE_OBJ_PROC
	.ref	INSERT_ENEMY,  CREATE_ENEMY,  XBASE,  SET_SCALE_MANUAL
	.ref	DEL_OID_PART,  YBASE,  SCROLL_FLAG,  MAKE_EXPLOSION
	.ref	MAKE_SAFE_EXPLOSION, FRAG_U5	       
	.ref	ZSCROLL,  A_BRANCH_TRUE,  CURPLYRS,  ZBASE,  YWORLD, ZSACCEL
	.ref	DEL_ENEMY_NOAUD,  A_PART_FIRE_FNC,  YHALF,  A_DEL_NONBOY
	.ref	ZREL_OFF,  CYCLE16,  A_TAB_SOUNDZ,  A_Set_AnimLoop
	.ref	NONBOY_SHOOT_LUPE,  SET_ANIPU,  A_MISSLE_EXPL
	.ref	NONBOY_DROP_SHOOT_ANIM,  ONESND_Z,  P_NONBOYO,  UNIV_DISAB_ENEMY_GEN
	.ref	WXBUFFER,  A_TOGGLE_DIR,  GRUNT_HIT_TBL,  SCROLLKILL
	.ref	FLAMBUSH_CVECT

	.ref	PALSET,IN_SECRET,ENTER_SECRET_ROOM,MACH_FIRE
	.ref	ENTER_DEADEND,DGV_FRAG_SPARK,BUB_CVECT,BUB_GUNVECT
	.ref	CHNG_SCRL_TBL,A_STAY_TIL_SY_LT,A_CLR_OYVEL
	.ref	A_ADJ_RANDSLP, BASE_HIT

* SYMBOLS FROM GXSCROL2.ASM
	.REF	ELEVATOR_RIDE

***** From GXMONDR2.ASM
	.REF	PART_EXPLOSION

***** from GXUNIV1.ASM
	.REF	FRAG_DUST_CLOUD_ANIM

***** from GXPOWER.ASM
	.REF	REVEAL_CD

*
*	EQUATES FOR UNIV OBJECTS (MORPH CHAMBER, LOBBY SIGN CHAIN)
*
OU_OHITS .set	OU_ODATA+40h

*
*	This routine clears the OU_OHITS field of a universe object
*	based on its OID. it scans the FG list
*
*	.LONG	S_CLR_OU_OHITS
*	.word	lo UNIV_ID, hi UNIV_ID
*	.word	number to look for
*
S_CLR_OU_OHITS
	movi	FGLIST,a1
	move	a1,a2
	move	*a11+,a3		; lo Univ ID
	move	*a11+,a4		; hi Univ ID
	move	*a11+,a5
	clr	a6

SCOO_nxt:
	move	*a1,a1,L
	cmp	a1,a2
	jreq	SCOO_X			; cycled thru list, abort
	move	*a1(OID),a14
	cmp	a3,a14
	jrlt	SCOO_nxt
	cmp	a4,a14
	jrgt	SCOO_nxt
	move	a6,*a1(OU_OHITS)
	dsjs	a5,SCOO_nxt		; loop for more if necessary
SCOO_X:
	jauc	SCRL_DISPATCHER
     


**************************************************************************
*								         *
* 	Special routines for the Jungle universe 			 *
*								         *
**************************************************************************

BUSHIT_SLEEP	.macro
	move	@WAVEVEL,a14
	add	a0,a14
	move	a14,*-a12	; save desired WAVEIRQ
	calla	PRCSLP		; sleep half as long as we should
*
*	Kludge because when I want to sleep for a number, I don't always
*
WADAFUK?:
	move	*a12,a14	; desired WAVEIRQ
	move	@WAVEVEL,a1
	sub	a1,a14
	jrle	hokay?
      	sleep	1
	jruc	WADAFUK?
hokay?:
	addk	16,a12		; skip the WAVEVEL word
	.endm


S_INIT_JUNGLE:
	movi	FLICK_TAB,a9
	movi	FLKWOBK_P,a8
	CREATEP	PID_TCYCLE,FLICKER_PAL

	movk	1,a14
	move	a14,@EFLOOR		; on the first floor
	movk	7,a14
	move	a14,@SIGN_DOWN
	clr	a14
	move	a14,@MORFGLASOUT	; if non-zero, morph chamber glass
					; is gone
	move	a14,@NUM_OUT_THERE
	move	a14,@NUM_SPEARS
	move	a14,@SCROLL_FLAG,L
	move	a14,@NUM_PILLARS	; used first for desk colr cycle
	move	a14,@IN_SECRET		; not in secret room
	MOVE	A14,@SPIN_SIGN_GONE,W	; Spinning sign flag
	MOVE	A14,@BRIDGE_DESTROYED,W	; Clear bridge flag
	move	a14,@JEWEL_OWNER,L	; nobody owns it yet
	move	a14,@OBJENEMIES
	movi	30,a14
	move	a14,@ATTACK_TIME	; attack timer
	MOVKM	4,@MAX_ALLOWED,W
	movkm	6,@MAX_SPEARS_ALLOWED,W
	MOVIM	19000h,@ENEMY_ZW_MAX,L
	MOVKM	3,@HALL_LOCKOUT,W	; can enter 3 times

	.IF GEORGE
	MOVKM	4,@SCRLFLOW,W
	.ENDIF

	MOVIM	2000h,@WXBUFFER,L
	MOVIM	320000h,@WYBUFFER,L

	MOVIM	300,@POWERUP_DURATION,W

	MOVIM	5,@VIDCAM_HOLDTIME,W 	; goes into AnimSLP
	MOVIM	17800h,@VIDCAM_Z,L   

	move	@WAVEIRQS,@IRQSTRT,L

S_RESET_VIDCAM:
	clr	a14
	move	a14,@PLYR_SEEN
	jauc	SCRL_DISPATCHER




*
*	This routine calls RANDPER with a probability factor
*	based on when the wave started
*
*	RETURNS  Carry Set or Clear
*
WVSTRT_CHANCE
	move	@WAVEIRQS,a0,L
	move	@IRQSTRT,a14,L
	sub	a14,a0
	cmpi	1024,a0
	jalt	RANDPER		; determine random probability
	setc			; if factor > 1024 (about 17 seconds) 
	rets			;   then always true



ROCK_IN_X:
	move	@XBASE,a8,L
	move	a8,a9
	addi	200000h,a8
	subi	200000h,a9
	movi	100,a10	; ticks to rock

;	movi	-1800h,a10
;rockit:
;	neg	a10
;	move	a10,@XSACCEL,L
;keeponl:
;	sleep	1
;
;	move	@SCROLLKILL,a1
;	jrnz	killme
;
;	move	@XBASE,a0,L
;	cmp	a0,a8
;	jrgt	keeponl
;
;	neg	a10
;	move	a10,@XSACCEL,L
;keeponr:
;	sleep	1
;
;	move	@SCROLLKILL,a1
;	jrnz	killme
;
;	move	@XBASE,a0,L
;	cmp	a0,a9
;	jrgt	keeponr
;	jruc	rockit

ROCK_LP:
	movi	100*99,a7
;	move	a10,a7
;	dec	a7
;	mpys	a10,a7	; t * t-1

	move	@XSCROLL,a1,L
	mpys	a10,a1
	sra	1,a1		; vt
	move	@XBASE,a11,L
	sub	a8,a11
	jrz	comacc
	neg	a11
	sub	a1,a11		; d-vt
	sll	2,a11	
	divs	a7,a11		; 4d/t**2
comacc:
	move	a11,@XSACCEL,L

	move	a10,a0
	srl	1,a0		; divide time in half

	BUSHIT_SLEEP

	move	@SCROLLKILL,a1
	jrnz	killme

	neg	a11
	move	a11,@XSACCEL,L

	move	a10,a0
	srl	1,a0

	BUSHIT_SLEEP

	move	@SCROLLKILL,a1
	jrnz	killme

	SWAP	a8,a9
	jruc	ROCK_LP


killme:
	dec	a1
	move	a1,@SCROLLKILL
	DIE




PILLBOY_INIT
	.long	G_B5SPxSHA4
	.word   DMAWNZ,0,OM_GUNV | OM_OID | OM_COLL | OM_ANIM
	.word	OID_NONBOY	; OID
	.long	PILLBOY_CVECT	; COLL
	.LONG	PILLBOY_GUNVECT	; GUNV
	.long	PBOY_ANIM	; ANIM



PILLBOY_CVECT
;	WWL	OID_BLOWUP,0FFFFH,PILLBOY_SBOMB_COLLVECT
;	WWL	OID_GRND,0FFFFH,PILLBOY_GRND_COLLVECT
	WL	0,PILLBOY_COLLVECT


	.ref	WINBOY_INIT,WINJUN_ANIM	; from gxnonboy
	.bss	NUM_OUT_THERE,16	; num guys out there now
	.bss	MAX_ALLOWED,16		; for control

**********************************************************************
*
* 	ENEMY ROUTINES for OUTSIDE OF JUNGLE!!!
*
**********************************************************************

M_WINDOW	EQU	00001H


JUNGDIECALL:
	move	*a8(OGenObj),a9,L	; obj that generated me.
	.if DEBUG
	jrz	$	     
	.endif
	clr	a14
	move	a14,*a9(UEGenObj),L	; let it create another

	move	@NUM_OUT_THERE,a14
	dec	a14
	jrn	ng
	move	a14,@NUM_OUT_THERE
ng:
	rets



*
*	This routine is modeled after CREATE_SIDERUN_NONBOY0
*      
*      Direction taken from Hflip of generator
*      Position is offset from enemy position
*      Args:   xoff, yoff,  (words, all in pixels)	
*		minmax for shootcnt
*
AU_CREATE_SIDERUN:
	move	@OBJENEMIES,a14
	btst	B_OF_SIDER,a14
	jrz	CSN0_ABORT

	move	@HOLD_ENEMY_DISPATCH,a14
	jrnz	CSN0_ABORT

	PUSH	A8
	MOVI	NONBOY_SIDE_INIT,B0	;ALLOCATE OBJECT
	CALLA	CREATE_ENEMY
	PULL	A2			;A2=obj block of creator
	MOVE	A8,A8
	JRZ	CSN0_ABORT		;BR = ABORT! ABORT!
	MOVI	NB_SRUNVEL_MAX+4000h,A0	;GET RANDOM SIDE RUNNING SPEED
	MOVI	NB_SRUNVEL_MAX,A1
	CALLA	RANGRAND
	MOVE	A0,*A8(OSRUNVEL),L

	move	a0,a5

	movk	3,a1
	movk	7,a0
	CALLA	RANGRAND
	MOVB	A0,*A8(OSHOOTCNT)	;RANDOM SHOOTING CHECK COUNT

	move	*a2(OCTRL),a0
	andi	M_FLIPH,a0
	jrz	nonegxvel
	neg	a5
	calla	SET_FLPS
nonegxvel:

	MOVE	A5,*A8(OXVEL),L		;RUN MOTHERFUCKER!

	MOVI	NB_HRUNVEL,A14
	MOVE	A14,*A8(OHRUNVEL),L	;SET HEADON RUNNING SPEED
*
*	set position
*
	move	a8,a9
	move	a2,a8			; need a2 in a8 for GETAFARG_
	CALLA	GETAFARG_WORD		; get distance limit
	move	a0,a0
	jrnn	stufit
	move	@JXLIMIT,a0		; get from word
stufit:
	move	a0,*a9(OXLIMIT)

	calla	GETAFARG_LONG		; pixel Y:X in a0
	move	a0,a1

	move	a9,a8
	move	*a2(OZVAL),a3,L
	addk	8,a3 			; universe Z in a3

	move	*a2(OXVAL),a5,L
	move	*a2(OYVAL),a4,L
	move	a1,a2			; do X and Y
	sext	a1			; X in a1
	sra	16,a2			; Y in a2
	sll	15,a1			; convert to world
	sll	15,a2
	add	a5,a1			; get univ X in a1
	add	a4,a2			;     univ Y in a2
	move	a1,a5			; save upper word of X in
	sra	16,a5			; XORIG as well
	move	a5,*a8(OXORIG)
	calla	SET_ANIPU

	MOVI	NONBOY_SIDE_RUN_ANIM,A1
	CALLA	STRT_ANIM		;START ANIMATION

	MOVK	1,A14
	MOVB	A14,*A8(OHITS)		;NUMBER OF ALLOWED HITS

	MOVK	1,A14
	MOVB	A14,*A8(OSCRNOFFCNT)	;TIMES ALLOWED OFF SCREEN

	MOVI	M_SIDE,A0
	MOVE	A0,*A8(OEFLAGS),W	;SET ENEMY STATE FLAG

	movi	INSIDE_WIN_CHK,a14
	MOVE	A14,*A8(OANIMCHK),L	; no animchk table

	CALLA	INSERT_ENEMY		;INSERT AND COUNT ENEMY
CSN0_ABORT:
	RETS

INSIDE_WIN_CHK:
	move	*a8(OXPOS),a0
	move	*a8(OXORIG),a1
	sub	a0,a1
	abs	a1   			; distance traveled in a1
	move	*a8(OXLIMIT),a2		; distance allowed in a2
	cmp	a2,a1
	jagt	DEL_ENEMY_NOAUD
	rets


*
*	This sets all variables needed when popup guys
*	determine your moving on.
*
S_INIT_POPQUO:
	move	*a11+,a0
	move	a0,@NMEEZ_GONE1

	MOVKM	2,@MAX_ALLOWED,W

	MOVIM	M_OF_SIDER|M_OF_POPQUO,@OBJENEMIES,W

	CREATEP	PID_IND,DUMMY_DEFENSE

	jauc	SCRL_DISPATCHER

*
*	This process moves you on if you haven't killed all the popups
*	within a certain period of time.
*
DUMMY_DEFENSE:
 	move	@WAVEIRQS,@IRQSTRT,L
	movk	10,a9		; 10 5-second periods = 50 seconds
DD_chk:			; check every 5 seconds
	sleep	5*60 
	move	@NMEEZ_GONE1,a0
	jaz	SUCIDE
	jrnn	DD0
	clr	a14
	move	a14,@NMEEZ_GONE1	; shouldn't happen
DD0:
	dec	a9
	jrnz	DD_chk
hunh:
	clr	a14			; timeout
	move	a14,@NMEEZ_GONE1
	DIE



*
*	This routine is modeled after AU_CREATE_WINBOY
*	It creates nonboys who popup behind ENEMY generating
*	objects in the jungle wave.
*
* Args = X PIXEL Offset, Y pixel offset, Z offset
*               all words
*

AU_CREATE_JUNWIN:
	move	@OBJENEMIES,a1
	btst	B_OF_POPUP,a1
	jrz	AU_CW_DONE

	move	@HOLD_ENEMY_DISPATCH,a14
	jrnz	AU_CW_DONE

	move	*a8(UEGenObj),a14,L	; Am I linked to an object?
	jrnz	AU_CW_DONE		; If so, don't gen another
	move	*a8(OFLAGS),a14
	btst	B_OFSCRN,a14
	jrnz	AU_CW_DONE

	btst	B_OF_POPQUO,a1		; if not quota, go on & create him.
	jrz	yes_gen			;

	move	*a8(UENumber),a5	; how many times have we created
	cmpk	3,a5			; a new guy?
	jrle	yes_gen			; if enough, fall through
*
*	if UENumber >= 3, disable this enemy generator
*
	move	@NMEEZ_GONE1,a14	; mark this one disabled for
	jrz	ng2
	dec	a14			; scroller 
	move	a14,@NMEEZ_GONE1
ng2:
	jauc	UNIV_DISAB_ENEMY_GEN	; Disable Enemy Generator

yes_gen:
	MOVE	A8,A9
	MOVI	WINBOY_INIT,B0		;ALLOCATE OBJECT
	CALLA	CREATE_ENEMY
	JRZ	AU_CW_ERROR		;BR = ERROR! ERROR!

	move	a9,*a8(OGenObj),L	; save generating object
	move	a8,*a9(UEGenObj),L     
	movi	JUNGDIECALL,a10
	MOVE	A10,*A8(ODEATHCALL),L

	MOVK	M_WINDOW,A11		;SET TYPE
	MOVE	A11,*A8(OEFLAGS),W	;SAVE TYPE

	MOVE	@RAND,A0,W		;LEFTY OR RIGHTY?
	ANDI	M_FLIPH,A0
	MOVE	*A8(OCTRL),A10,W
	OR	A0,A10
	MOVE	A10,*A8(OCTRL),W

	MOVE	A8,A1
	MOVE	A9,A8
	CALLA	GETAFARG_WORD		;GET X OFFSET
	MOVE	A0,A2
	SLL	15,A2			;CONVERT TO WORLD OFFSET
	BTST	B_FLIPH,A10
	JRZ	AU_CW_NOROM		;BR=NO HORZ FLIP
	NEG	A2
	SUBI	17 << 15,A2		;FUDGE
AU_CW_NOROM
	CALLA	GETAFARG_LONG		;GET [Z, PIXEL Y] OFFSET
	MOVE	A1,A8

	MOVE	*A9(OXVAL),A1,L
	ADD	A2,A1			;OFFSET X
	MOVE	*A9(OYVAL),A2,L
	MOVE	A0,A14			;GET PIXEL Y OFFSET
	SLL	16,A14	
	SRA	1,A14			;CONVERT TO WORLD OFFSET			
	ADD	A14,A2			;ADD TO Y OF GENERATOR
	MOVE	A2,*A8(OYSTART),L
	MOVE	*A9(OZVAL),A3,L
	SRA	16,A0
	ADD	A0,A3			;OFFSET Z FROM GENERATOR
	CALLA	SET_ANIPU

	MOVI	WINJUN_ANIM,A1
	CALLA	STRT_ANIM		;START ANIMATION

	MOVI	-20 << 15,A14
	MOVE	A14,*A8(OGRNDOFF),L	;GROUND OFFSET UPON FALL

	MOVK	1,A14
	MOVB	A14,*A8(OHITS)		;NUMBER OF ALLOWED HITS

	move	@OBJENEMIES,a1		; 
	btst	B_OF_POPQUO,a1		; if not quota, go on & create him.
	jrz	CJ_nochgpal		; 

	move	*a9(UENumber),a5	; num recreations (indx for palette)
	jrnz	CJ_chgpal
*
*	First time, pick palette as follows
*	   index to first palette = 4-CURPLYRS-PLYR_SEEN
*
 	move	@PLYR_SEEN,a14
	move	@CURPLYRS,a1
	add	a1,a14
	movk	4,a5
	sub	a14,a5			; index of first palette
	jrgt	CJ_chgpal
	clr	a5
	jruc	first1
CJ_chgpal:
	move	a5,a1
	dec	a1
	sll	5,a1
	addi	PILLPAL_4,a1
	move	*a1,a0,L
	calla	CHANGE_PAL
first1:
	inc	a5
	move	a5,*a9(UENumber)	; num recreations
CJ_nochgpal:
	MOVI	127,A0			;RANDOM LIFE TIME
	MOVK	30,A1
	CALLA	RANGRAND
	MOVB	A0,*A9(AnimSLP)
	SUBK	21,A0			;POPUP AND POPDOWN TIME
	MOVE	A0,*A8(OETIME),W

	CALLA	INSERT_ENEMY		;INSERT AND COUNT ENEMY
	RETS
AU_CW_ERROR
	MOVE	A9,A8
AU_CW_DONE
	RETS



*
*	CALLED BY JUNWIN animation in gxnonboy.asm
*
*
A_CAN_I_POPUP:
	move	@OBJENEMIES,a14		; go away if this enemy not allowed
	btst	B_OF_POPUP,a14
	jrz	unlink_him

	move	*a8(OFLAGS),a14		; go away if offscreen
	btst	B_OFSCRN,a14
	jrnz	unlink_him

	move	@MAX_ALLOWED,a0
	calla	CURPLYR_ADJ
	move	@NUM_OUT_THERE,a1
	cmp	a0,a1
	jrgt	nah
	movi	-02b000h,a14		; yeah, pop up
	move	a14,*a8(OYVEL),L
	inc	a0
	move	a0,@NUM_OUT_THERE
	rets

nah:	
	move	*a8(AnimFrm),a14,L
	subi	50h,a14
	move	a14,*a8(AnimFrm),L	; wait a while
	rets

unlink_him:
	move	*a8(OGenObj),a0,L	; save generating object
	clr	a14
	move	a14,*a0(UEGenObj),L
	move	a14,*a8(OGenObj),L
	jauc	DEL_ENEMY_NOAUD

**************************************************************************
*								         *
* PILLBOY_GUNVECT - GUN VECTOR						 *
*								         *
* PASS:									 *
* A2 = PTR TO PLAYER						         *
* A8 = PTR TO OBJECT							 *
*								         *
**************************************************************************

;PILLBOY_SBOMB_COLLVECT
;	CLR	A2
;	JRUC	OUTCLUB_SBOMB			;LET SBOMB CODE AWARD POINTS
PILLBOY_COLLVECT
	MOVE	*A0(OID),A0,W			;GET PLAYER DATA ADDRESS
	CALLA	POID_TO_PDATA			;GET PDATA IN A2
PILLBOY_GUNVECT
	CALLA	GET_HEAD_PART
	MOVE	A2,*A8(OPLAYER),L
;OUTCLUB_SBOMB
	MOVB	*A8(OFLAGS+B_DEAD-7),A9		;IS THIS OBJECT DEAD?
	JRN	OG_DEAD				;BR = YES

	MOVB	*A8(OHITS),A14
	DEC	A14
	JRNZ	OG_STILL_ALIVE			;BR = NONBOY STILL ALIVE

	MOVI	OID_JUNK,A1
	CALLA	DEL_OID_PART			;GET RID OF GUN FLASH

	ADDI	M_DEAD >> 3,A9			;HE'S DEAD NOW
	MOVB	A9,*A8(OFLAGS+B_DEAD-7)

	MOVE	A2,A2
	JRZ	OG_NOSCORE			;BR = NO SCORE

	MOVI	1000,A1
	CALLA	SCORE

*A8 = PTR TO OBJECT BEING KILLED
OG_NOSCORE

	MOVK	NUM_GRUNT_SNDS,A0		;RANDOM GRUNT SOUND
	CALLA	RAND0
	SLL	5,A0
	ADDI	GRUNT_HIT_TBL,A0
	MOVE	*A0,A0,L
	CALLA	ONESND_Z			;Do the volume sound

	CLR	A14
	MOVE	A14,*A8(OXVEL),L
	MOVE	*A8(OYVEL),A3,W			;USE TO TEST WINDOW DUDE
	MOVE	A14,*A8(OYVEL),L
	MOVE	A14,*A8(OZVEL),L
	

OG_BW_NO_SIDE
	MOVI	PILLAR_DEATH_ANIM,A1		;DEFAULT TO FALLING BACKWARDS

	JAUC	STRT_ANIM			;BR=FALL BACKWARDS


OG_STILL_ALIVE
	MOVB	A14,*A8(OHITS)			;NUMBER OF HITS LEFT
OG_DEAD
	RETS


PILLPAL_4
	.long	P_NONBOYY,P_NONBOYO,P_NONBOYR,0

A_RESTART_PILLBOY:
	move	*a8(OPILLCNT),a1   	; how many times recreated?
	inc	a1
	move	a1,*a8(OPILLCNT)
	dec	a1
	sll	5,a1
	move	*a8(OPILLPAL),a2,L
	add	a2,a1
	move	*a1,a0,L		 
	jrz	advance
	calla	CHANGE_PAL

	move	*a8(OFLAGS),a14
	andni	M_DEAD,a14
	move	a14,*a8(OFLAGS)

	CLRM	*a8(OYVEL),L

	move	*a8(OSAVY),*a8(OYVAL),L

	movi	PBOY_ANIM,a1
	move	a1,*a8(AnimFrm),L
	move	a1,*a8(AnimScr),L
	rets


advance:
	move	*a8(OPILLID),a0
	movk	1,a1
	sll	a0,a1		; set bit for this pillar
	move	*a8(OCTRL),a14
	movi	PILL_CNT+8,a5
	btst	B_FLIPH,a14	; chk flip bit
	jrz	noflip
	subk	8,a5
	sll	16,a1		; set it for high word if flipped
noflip:
	movb	*a5,a6
	dec	a6
	movb	a6,*a5		; dec PILL_CNT for this side
	move	@PILLAR_ADV,a2,L	
	or	a1,a2
	move	a2,@PILLAR_ADV,L	; tell scroll routine we can advance
	jauc	A_DEL_NONBOY



*
*	Determines whether or not we can zip ahead down the hall a bit
*
S_WAIT_FOR_ZIPOK:
	move	@WAVEIRQS,a10,L		; for timeout
	movi	10001h,a8
	move	@NUM_PILLARS,a9		; current number of pillars
	sll	a9,a8
	dec	a9
sw4zlp:
	move	@PILLAR_ADV,a0,L	; flag bits
	and	a8,a0		; mask off desired bits
	cmp	a8,a0		; if eq, BINGO
	jrne	w4zmore
sw4z_exit:
	move	a9,@NUM_PILLARS
	jauc	SCRL_DISPATCHER

w4zmore:
	move	@WAVEIRQS,a0,L
	sub	a10,a0
	cmpi	60*60,a0 		; wait for a minute
	jrgt	sw4z_exit
	sloop	10,sw4zlp




***********************************************************************
*
*	       a8 end Z
*	need   a9 start Z
*              a10 right x - left x : right x
*	       a11 Y start : 0
*
S_CREATE_ATRIUM_BOYS:
	move	@WAVEIRQS,@IRQSTRT,L

	move	a11,a0
	mmfm	a0,a8,a9,a10,a11

	move	@ZREL_OFF,a14,L
	sra	ZFRAC,a14	; make it lores
	add	a14,a9
	add	a14,a8
	move	a0,*-a12,L	; save scrl table ptr

	CREATE	PID_IND,CREATE_ATRIUM_BOYS

	move	*a12+,a11,L
	jauc	SCRL_DISPATCHER



S_CREATE_MASS_ATRIUM:
	move	a11,a1
	mmfm	a1,a8,a9,a10,a11

	move	@ZREL_OFF,a14,L
	sra	ZFRAC,a14	; make it lores
	add	a14,a9
	add	a14,a8

	move	*a1+,a0		; how many guys
	move	a1,*-a12,L	; save scrl table ptr

	calla	CURPLYR_ADJ
AMassLp:
	move	a0,*-a12
	callr	CREATE_1_ATRIUM
	sleep	1
	move	*a12+,a0
 	dsjs	a0,AMassLp

	move	*a12+,a11,L
	sleep	90

	jauc	SCRL_DISPATCHER


CREATE_ATRIUM_BOYS:
*	       a8 end Z
*	need   a9 start Z
*              a10 right x - left x : right x
*	       a11 Y start : 0

	callr	CREATE_1_ATRIUM

	movi	60,a1
	movi	180,a0			; vid cam shot
	move	@PLYR_SEEN,a14
	jrnz	chkplyrs
	movi	30,a1
	movi	100,a0			; normal parameters

chkplyrs:
	move	@CURPLYRS,a14
sublp:
	dec	a14
;	jrz	CABok
	JRLE	CABok		;BR = Got player count
	subk	10,a1
	subk	30,a0
	jruc	sublp
CABok:
;	calla	WVSTRT_CHANCE
;	jrc	CABhard
;	sll	1,a0		; possibility of doubling delay early on
;CABhard:
	calla	RANGRAND
CAchklp:
	PUSHP	a0			; save tiks to sleep
	sleep	10
	PULLPQ	a0
	move	@SCROLLKILL,a1		; time to die?
	jrnz	kill_me			
	subk	10,a0			; if no, adjust tiks
	cmpk	10,a0			; if really low, finish up
	jrge	CAchklp			; else, loop back
	CALLA	PRCSLP

	move	@SCROLLKILL,a1		; time to die?
	jrz	CREATE_ATRIUM_BOYS

kill_me:
	dec	a1
	move	a1,@SCROLLKILL
	DIE



CREATE_1_ATRIUM:
	move	@HOLD_ENEMY_DISPATCH,a14
	jrnz	CABX
*
*	CREATE ONE DROPPING GUY
*

	PUSH	A8
	MOVI	NONBOY_DROP_INIT,B0	;ALLOCATE OBJECT
	CALLA	CREATE_ENEMY
	PULL	A4			;A4=delta Z
	MOVE	A8,A8
	JRZ	CABX			;BR = ABORT! ABORT!

	MOVE	A8,A0
	MOVI	NONBOY_DROP_SHOOT_ANIM,A1  ; frame pointer
	MOVI	NONBOY_SHOOT_LUPE,A14	; script pointer
	CALLA	STRTANIM_OFF		;START ANIMATION

	clr	a2
	movy	a11,a2			; start Y in a2
	move	a9,a1
	move	a4,a0
	calla	RANGRAND
	move	a0,a3			; random Z in a3
	move	@ZBASE,a14,L
	addi	08000h,a14
	cmp	a14,a3
	jrgt	ZrngOK
	move	a14,a9
	move	a14,a3
ZrngOK:
	clr	a1    			; compute random X
	movy	a10,a1			; left is lower bound
	move	a10,a0
	sll	16,a0			; right is upper bound
	calla	RANGRAND
	move	a0,a1			; start X in a1
	CALLA	SET_ANIPU

;	MOVE	@YWORLD,A0,L
;	SUB	A2,A0
;	MOVE	A0,*A8(OGRNDOFF),L

	MOVI	NB_SRUNVEL_MAX,A0	;GET RANDOM RUNNING SPEED		
	MOVI	NB_SRUNVEL_MIN,A1
	CALLA	RANGRAND
	MOVE	A0,*A8(OSRUNVEL),L

	MOVK	1,A14
	MOVB	A14,*A8(OHITS)		;NUMBER OF ALLOWED HITS

	MOVK	2,A14
	MOVB	A14,*A8(OSCRNOFFCNT)	;TIMES ALLOWED OFF SCREEN

	MOVE	@RAND,A6,W		;LEFTY OR RIGHTY?
	ANDI	M_FLIPH,A6
	MOVE	*A8(OCTRL),A14,W
	OR	A6,A14
	MOVE	A14,*A8(OCTRL),W

	MOVI	07000H,A14
	MOVE	A14,*A8(OYACCEL),W	;SET GRAVITY
	MOVI	01000H,A14
	MOVE	A14,*A8(OYVEL),W	;SET GRAVITY

	CALLA	INSERT_ENEMY		;INSERT AND COUNT ENEMY
	move	a4,a8
CABX:
	rets





***********************************************************************
*
*	       a8 delta Z
*	need   a9 start Z
*              a10 left x : right x
*	       a11 number of pillars : Y
*
S_CREATE_PILLAR_BOYS:
*
*	Kill desk color cycling processes and candle flicker
*
;	move	@NUM_PILLARS,a14
;	jrz	noneed
;	KILLIT	PID_TCYCLE,0ffffh
;noneed:
	CLRM	@PILLAR_ADV,L

	move	a11,a0
	mmfm	a0,a8,a9,a10,a11
	move	@ZREL_OFF,a14,L
	sra	ZFRAC,a14	; make it lores
	add	a14,a9
	move	a11,a6		; 
	srl	16,a6		; loop count in a6
	sll	16,a11		; Y in a11
	jrnz	Ycool
	move	@YWORLD,a11,L	; use ground as Y
Ycool:
	move	a0,*-a12,L	; save scrl table ptr

	move	a6,@NUM_PILLARS
	move	a6,a14
	sll	8,a14
	add	a6,a14
	move	a14,@PILL_CNT

CREATE_PILLBOY_lp:
*	       a6 = loop counter
*	       a8 = delta Z
*	       a9 = start Z
*              a10 = left x : right x
*	       a11 = Y
*
	mmtm	a12,a6,a8	; push onto stack

	calla	CREATE_PILLAR_BOY

	calla	CREATE_PILLAR_BOY

	sleep	4

	mmfm	a12,a6,a8	; restore delta Z and loop counter
	add	a8,a9		; next Z

	dsjs	a6,CREATE_PILLBOY_lp

	move	*a12+,a11,L	; restore scrl table ptr
	jauc	SCRL_DISPATCHER


***************************************************************
*
*	X in a10 upper
*	Y in a11
*	Z in a9
*
***************************************************************
CREATE_PILLAR_BOY:
	move	@HOLD_ENEMY_DISPATCH,a14
	jrnz	CPB_ABT
	MOVI	PILLBOY_INIT,B0		;ALLOCATE OBJECT
	CALLA	EASYMAKE	;Fire up the object
	JRZ	CPB_ERROR	;BR = No object created
	move	a0,a8
	CALLA	CLR_ODATA

	move	a6,*a8(OPILLID)	; pillar number

	movi	PILLPAL_4,a0
	move	a0,*a8(OPILLPAL),L

	movk	4,a5
	move	@PLYR_SEEN,a14
	move	@CURPLYRS,a1
	add	a1,a14
	sub	a14,a5
	jrgt	set_first_pal
	clr	a5
	jruc	toobadsucka
set_first_pal
	move	a5,a1
	dec	a1
	sll	5,a1
	add	a0,a1
	move	*a1,a0,L
	calla	CHANGE_PAL		; first pal is not yellow

toobadsucka:
	move	a5,*a8(OPILLCNT)	; num recreations

	MOVK	1,A14
	MOVB	A14,*A8(OHITS)		;NUMBER OF ALLOWED HITS

	MOVI	M_SIDE,A14
	MOVE	A14,*A8(OEFLAGS),W	;SET TYPE

	clr	a1
	movy	a10,a1			; X in a1
	CLR	A0
	move	@XBASE,a14,L
	sub	a1,a14
	jrn	CPB_FLIPSET
	MOVK	M_FLIPH,A0		;FLIP OUT ON THE LEFT HALF
CPB_FLIPSET:
	move	a11,a2			; Y in a2
	move	a9,a3			; Z in a3
	CALLA	SET_ANIPU

	NOT	A0			;INVERT DOOR FLIP
	ANDI	M_FLIPH,A0
	MOVE	*A8(OCTRL),A14,W	;SET OCTRL
	OR	A0,A14
	MOVE	A14,*A8(OCTRL),W

	movk	8,a0
	move	a0,*a8(OETIME),W	; initial time spent firing

	CLR	a14
	MOVE	A14,*A8(OGRNDOFF),L	;SET GROUND OFFSET FOR FALL

	CALLA	INSERT_ENEMY		;INSERT AND COUNT ENEMY

	move	*a8(OYVAL),*a8(OSAVY),L

CPB_ERROR
	rl	16,a10
CPB_ABT:
	rets


A_INC_OETIME
	move	*a8(OETIME),a0
	addk	4,a0
	move	a0,*a8(OETIME)
	rets


*
*	Turns obj on if fewer than 2 pillar guys are out there
*
A_PBOY_OBJ_ON:
	move	*a8(OZVAL),a1,L
	subi	ZMAX_REAL,a1
	move	@ZBASE,a14,L
	cmp	a14,a1
	jalt	DEL_ENEMY_NOAUD		; delete guy if we've passed him
	movi	PILL_CNT,a1
	move	*a8(OCTRL),a14
	btst	B_FLIPH,a14
	jrnz	adjfcnt
	addk	8,a1
adjfcnt:
	movb	*a1,a0
	move	@CURPLYRS,a14
	cmp	a14,a0
	jrge	notnow
	inc	a0
	movb	a0,*a1
	jauc	OBJ_ON

notnow:
	move	*a8(AnimFrm),a0,L	; wait here
	subi	32+16+32,a0
	move	a0,*a8(AnimFrm),L
	rets



A_PBOY_OBJ_OFF:
	movi	PILL_CNT+8,a1
	move	*a8(OCTRL),a14
	btst	B_FLIPH,a14
	jrz	adjnofcnt
	subk	8,a1
adjnofcnt:
	movb	*a1,a0
	dec	a0
	movb	a0,*a1
	jauc	OBJ_OFF


PBOY_ANIM
	LWL	G_B5SPxSHA4,3|AFunc,A_PBOY_OBJ_OFF
	LWL	1,3|AFunc,A_INC_OETIME
	LWLWW	1,1|AFunc,A_RAND_AnimSLP+2,70,270
	LW	1,0
	LW	1,0
	LWL	1,3|AFunc,A_PBOY_OBJ_ON
	LW	G_B5SPxSHA5,3
	LW	G_B5SPxSHA6,3
	LWL	G_B5SPxSHA7,3|AFunc,A_TOGGLE_DIR
PBOY_SHOOT_ANIM
	LW	G_B1SHOOTA1,1
	LWLWW	1,5|AFunc,A_PART_FIRE_FNC+2,-24,-80
	LW	G_B1SHOOTA2,6
	LWLL	1,1|AFunc,A_CHECK_OETIME+2,PBOY_SHOOT_ANIM
	LW	G_B5SPxSHA7,3
	LWL	G_B5SPxSHA6,3|AFunc,A_TOGGLE_DIR
	LW	G_B5SPxSHA5,3
	.long	0




**************************************************************************
*								         *
* EVERGREEN CHEMICAL SIGN						 *
*								         *
**************************************************************************
CHAIN_CVECT
	WWL	OID_PROCKET,~MASK_PLAYER,CHAIN_COLLVECT
DUMCVECT
	WL	0,DUMCRETS

SIGN_CVECT
	WWL	OID_GRND,0FFFFH,SIGN_GROUND_COLL
	WL	0,DUMCRETS


SIGN_GROUND_COLL
	clr	a14
	move	a14,*a8(OYVEL),L
	move	a14,*a8(OYACCEL),W
	calla	COLLS_OFF
	move	*a8(OID),a6	; OID identifies which sign piece
	movi	OID_JUNK,a1
	calla	CHANGE_OID
	move	@SIGN_DOWN,a14
	jrz	oops
	srl	3,a6
	andi	3,a6
	dec	a6
	movk	1,a5
	sll	a6,a5
	andn	a5,a14		; clear bit corres. to this sign piece
	sll	8,a5
	andn	a5,a14		; clear falling bit
	move	a14,@SIGN_DOWN
	jrnz	oops
*
*	Legs fly up
*
	sll	4,a6		; turn into index
	addi	arm_pos_tbl+90h,a6
	move	a8,a3
	move	@LEGOBJ,a8,L
	calla	BG_TO_FG	; not part of universe anymore
	movi	WARLEG,a14
	move	a14,*a8(AnimScr),L
	move	a14,*a8(AnimFrm),L
	movk	1,a14
	movb	a14,*a8(AnimSlp)
	calla	OBJ_ON
	movi	P_WARLEG,a0
	calla	CHANGE_PAL
	mmtm	sp,b0,b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11
	movi	LEG_INIT,b0
	calla	EASYMAKE
	mmfm	sp,b0,b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11

	move	*a6,a14		; XVAL of legs
	sll	16,a14
	addi	9<<16,a14
	move	a14,*a0(OXVAL),L
	subi	18<<16,a14
	move	a14,*a8(OXVAL),L
	move	*a8(OYVAL),*a0(OYVAL),L
	move	*a8(OZVAL),*a0(OZVAL),L
	calla	INSOBJ
	move	a3,a8
	SOUND1	LAST_SGN_DWN1
	SOUND1	LAST_SGN_DWN2

oops:
	calla	DELETE_OBJ	; don't be hangin round.
	
	SOUND1	A_SGN_DOWN
	rets

A_SGN_DOWN
	.word	0f3d0h,20,81b8h,0

LAST_SGN_DWN1
	.word	0f1d0h,20,0a1b9h,0
LAST_SGN_DWN2	
	.word	0f2d0h,20,0a201h,0

SND_CHAIN_HIT1	.word	0f341H,39,0a414h,0	
SND_CHAIN_HIT2	.word	0f341h,39,0a417h,0	


LEG_INIT
	.long	WARLEG7
	.word	M_FLIPH|DMAWNZ,0,OM_ANIM
	.long	WARLEG

CHAIN_COLLVECT
	MOVE	*A0(OID),A0,W			;GET PLAYER DATA ADDRESS
	CALLA	POID_TO_PDATA

	move	*a8(OU_OHITS),a5
	addk	2,a5
	jruc	chn_hk

CHAIN_GUNVECT
	move	*a8(OU_OHITS),a5
	inc	a5
chn_hk
	move	a8,a3		; save orig a8
	move	a5,*a8(OU_OHITS)

	calla	UNIV_FLASH

	cmpk	16,a5
	jrle	SGNDONE

	clr	a14			; chain is not collidable no mo
	move	a14,*a8(OCVECT),L
	move	a14,*a8(OGUNVECT),L

	MOVE	*A8(OCTRL),A1,W
	movk	2,a6
	MOVE	*a8(OID),a5
;	movi	MASK_ID,a7		
;	and	a7,a5
	addk	4,a5
	MOVI	FGLIST,A4
	MOVE	A4,A8
	JRUC	SGN_NEXT

SGN_LUPE
	MOVE	*A8(OID),A14			;CHECK OID
;	and	a7,a14
	cmp	a5,a14
	JRNE	SGN_NEXT

	dint
	andi	MASK_ID,a14		
	srl	3,a14		; get id to be 1,2,3
	dec	a14		; now 0,1,2
	movk	1,a5
	sll	a14,a5		; flag = 1,2 or 4
	movb	@SIGN_DOWN+8,a14
	or	a5,a14		; set bit corres. to this sign piece
	movb	a14,@SIGN_DOWN+8 ; to indicate it is falling

	calla	BG_TO_FG
	movi	7000h,a0
	move	a0,*a8(OYACCEL)
	movi	0c000h,a0
	move	a0,*a8(OYVEL),L
	move	*a8(OFLAGS),a14
	ORIM	M_GCOLL,*a8(OFLAGS),W

	eint
	jruc	SGNDONE

SGN_NEXT
	MOVE	A6,A6
	JRZ	SGNDONE   			;BR=CHANGED EVERYTHING
	MOVE	*A8,A8,L
	CMP	A4,A8
	JRNE	SGN_LUPE				;BR=NOT END OF LIST
SGNDONE
	move	a3,a8			; restore orig chain obj

	movi	SND_CHAIN_HIT1,a0
	move	@RAND,a14
	btst	11,a14
	jrnz	duh
	movi	SND_CHAIN_HIT2,a0
duh:
	calla	ONESND	
	RETS



DESK_COLLVECT:
	CALLA	UNIV_COLL_CHECK
	JRNZ	DESK_DONE

	MOVE	*A0(OID),A0,W			;GET PLAYER DATA ADDRESS
	CALLA	POID_TO_PDATA
	MOVK	M_NOMORE,A7  			;LAST FRAME 

	MOVI	500,A5				;500 POINTS
	CLR	A9				;NO OFFSET
	CALLA	UNIV_DAMAGE_HANDLER

	move	@NUM_PILLARS,a14
	jrnz	DESK_DONE		; cycles already started
	move	a8,a5
	movi	P_DESKDM1,a8     		; start color cycling process
	movk	5,a11
	movi	53,a9
	movi	57,a10
	CREATE	PID_TCYCLE,CYCLE16
	movi	P_DESKDM2,a8
	movk	5,a11
	movi	55,a9
	movi	60,a10
	CREATE	PID_TCYCLE,CYCLE16
	move	a0,@NUM_PILLARS		; indicate that colors are cycling

DESK_DONE	
	rets


SKY_SND_TAB
	.long	SKYBRK_S1,SKYBRK_S2,SKYBRK_S3

SKYBRK_S1   .word	0f340h,53,0a3c5h,0
SKYBRK_S2   .word	0f340h,64,0a32eh,0
SKYBRK_S3   .word	0f340h,85,0a129h,0

SKYLIT_COLLVECT:
	CALLA	UNIV_COLL_CHECK
	JRNZ	SKYLIT_DONE

	MOVE	*A0(OID),A0,W			;GET PLAYER DATA ADDRESS
	CALLA	POID_TO_PDATA

SKYLIT_GUNVECT:
	move	*a8(OZVAL),a7,L
	move	@ZBASE,a14,L
	sub	a14,a7
	cmpi	16000h,a7
	jrge	SKYLIT_DONE		; dont collide if too far away


	MOVK	M_NOMORE|M_FLASHOBJ,A7  ;LAST FRAME AND FLASH
	MOVI	0,A5				;500 POINTS
	CLR	A9				;NO OFFSET
	CALLA	UNIV_DAMAGE_HANDLER

	MMTM	SP,B1,B2,B4,B5,B6,B8,B9,B10	;MAKE STALL DOOR FRAGMENTS

	movi	SKY_SND_TAB,a1
	movk	3,a0
	CALLA	RAND0
	SLL	5,A0
	ADD	A0,A1
	MOVE	*A1,A0,L
	calla	ONESND_Z

	MOVI	07000H,A0
	MOVI	030H,A3
	CALLA	PreFrag_Box
	abs	b7
	movi	30000h,b8
	MOVI	FRG_GL_12,B14
	CALLA	Fragger

	MOVE	*A8(OIMG),A1,L
	MOVE	*A1(ICMAP),*A0(FPDATA),L	;SET PALETTE

	MMFM	SP,B1,B2,B4,B5,B6,B8,B9,b10	; 
SKYLIT_DONE	
	rets


CANDLE_CVECT
	WWL	OID_PROCKET,~MASK_PLAYER,UNIV_ROCKET_COLL
	WWL	OID_PEXPLOSION,~MASK_PLAYER,CANDLE_COLLVECT
	WL	0,DUMCRETS

CANDLE_COLLVECT:
	CALLA	UNIV_COLL_CHECK
	JRNZ	CANDLE_DONE

	MOVE	*A0(OID),A0,W			;GET PLAYER DATA ADDRESS
	CALLA	POID_TO_PDATA
	jruc	cand_hk
CANDLE_GUNVECT:
	movi	[68,43],a3
	movi	[86,51],a4
	calla	BOX_CHECK_OBJ	; did we shoot the candle?
	jrz	CANDLE_DONE	; ignore if no.
cand_hk:
	calla	BG_TO_FG
	calla	DELETE_OBJ

CANDLE_DONE	
	rets


CRSTONE_CVECT
	WWL	OID_PROCKET,~MASK_PLAYER,UNIV_ROCKET_COLL
	WWL	OID_PEXPLOSION,~MASK_PLAYER,CRSTONE_COLLVECT
	WL	0,DUMCRETS


HONEY_CVECT
	WWL	OID_PROCKET,~MASK_PLAYER,UNIV_ROCKET_COLL
	WWL	OID_PEXPLOSION,~MASK_PLAYER,HONEY_COLLVECT
	WL	0,DUMCRETS

*
*	HONEYCOMB coll vect routine, similar to STONE_COLLVECT
*	but must turn off enemy and kill bug if there is one.
*
HONEY_COLLVECT:
	CALLA	UNIV_COLL_CHECK
	JRNZ	STONE_DONE

	MOVE	*A0(OID),A0,W			;GET PLAYER DATA ADDRESS
	CALLA	POID_TO_PDATA
	movi	M_NOSTOPANIM|M_LASTFRM|M_NOMORE,a7

	callr	stg_hk
	jauc	HONEY_DESTROY


*
* Explosion vector for walls, inside chemical plant
*
CRSTONE_COLLVECT:
	CALLA	UNIV_COLL_CHECK
	JRNZ	STONE_DONE

	MOVE	*A0(OID),A0,W			;GET PLAYER DATA ADDRESS
	CALLA	POID_TO_PDATA

	movi	M_NOMORE|M_RANDFRM|M_NOSTOPANIM,a7
	MOVI	0,A5		       
	CLR	A9				;NO OFFSET
	CALLA	UNIV_DAMAGE_HANDLER

	movi	SND_STONE_EXP2,a0
	move	@RAND,a14
	btst	7,a14
	jrnz	CRC_DO_FRAG

	MOVI	[-70,0],A10			; screen Y,X offset
	MOVK	8,A11
	CREATE	PID_IND,REVEAL_CD

	movi	SND_STONE_EXP1,a0

CRC_DO_FRAG
	MOVI	FRG_BR_12_1X,A4
	JRUC	PT_DOFRAG

STONE_CVECT
	WWL	OID_PROCKET,~MASK_PLAYER,UNIV_ROCKET_COLL
	WWL	OID_PEXPLOSION,~MASK_PLAYER,STONE_COLLVECT
	WL	0,DUMCRETS


BRIDGE_CVECT
	WWL	OID_PROCKET,~MASK_PLAYER,UNIV_ROCKET_COLL
	WWL	OID_PEXPLOSION,~MASK_PLAYER,BRIDGE_COLLVECT
	WWL	OID_GRND,0FFFFH,BRIDGE_GRND_COLL
	WL	0,DUMCRETS

BRIDGE_COLLVECT:
	CALLA	UNIV_COLL_CHECK
	JRNZ	STONE_DONE

	MOVE	*A0(OID),A0,W			;GET PLAYER DATA ADDRESS
	CALLA	POID_TO_PDATA
	movi	M_NOSTOPANIM|M_LASTFRM,a7

	move	*a8(OIMG),a14,L
	cmpi	FOOTINGDM,a14
	JREQ	BCV_KNOCK_IT_OUT

	MOVI	0,A5		       
	CLR	A9				;NO OFFSET
	CALLA	UNIV_DAMAGE_HANDLER

	movi	SND_STONE_EXP2,a0
	move	@RAND,a14
	btst	11,a14
	jrnz	ptok
	movi	SND_STONE_EXP1,a0
	jruc	ptok				; point sound in a0

BCV_KNOCK_IT_OUT
	callr	stg_hk2		; send out fragments

	MOVK	1,A1
	MOVE	*A8(OCTRL),A14,W
	BTST	B_FLIPH,A14
	JRZ	BCV_LEFT		;BR = This is the left piece
	ADDK	1,A1
BCV_LEFT
	ORM	A1,@BRIDGE_DESTROYED,W	;Set the flag

	calla	BG_TO_FG		; dissassociate from BG
	MOVIM	0c000h,*a8(OYVEL),L
	MOVIM	2800h,*a8(OYACCEL),W	; drop it
	ORIM	M_GCOLL,*a8(OFLAGS),W
	MOVIM	-9<<15,*a8(OGRNDOFF),L

	rets

BRIDGE_GRND_COLL:
*
*	set variable,  blow out frags and dust, make a noise, then...
*
	MMTM	SP,B1,B2,B4,B5,B6,B8,B9,B10
	MOVI	037000H,A0
	MOVI	080H,A3
	movi	80008h,a4
	CALLA	PreFrag_Center
	MOVI	FRAG_BLOCK_BLOW,B14

	sub	b10,b9
	clr	b10

	sub	b8,b7
	clr	b8

	CALLA	Fragger
	MMFM	SP,B1,B2,B4,B5,B6,B8,B9,B10
	jauc	DELETE_OBJ



BASIC_CVECT
	WWL	OID_PROCKET,~MASK_PLAYER,UNIV_ROCKET_COLL
	WWL	OID_PEXPLOSION,~MASK_PLAYER,BASIC_COLLVECT
	WL	0,DUMCRETS

BASIC_COLLVECT:
	CALLA	UNIV_COLL_CHECK
	JRNZ	BASIC_DONE

	MOVE	*A0(OID),A0,W			;GET PLAYER DATA ADDRESS
	CALLA	POID_TO_PDATA
	movi	M_LASTFRM,a7 	; flags
	jruc	basic_hook

BASIC_GUNVECT:
	clr	a7
basic_hook:
	clr	a5		; SCORE
	CLR	A9		; OFFSET
	CALLA	UNIV_DAMAGE_HANDLER

;	SOUND1	SND_EXPLO_S
	SOUNDZ	SND_METAL_HIT

	move	a10,a10
	jrz	BASIC_DONE

	MMTM	SP,B1,B2,B4,B5,B6,B8,B9,B10

	PUSH	a2
	move	*a8(OUSIZEY),a2
	sll	13,a2		; change to universe (1/4 Y SIZE)
	neg	a2
	clr	a1		; no x offset
	clr	a3		; no dblscl
	calla	MAKE_EXPLO_OFF
	PULLQ	a2

;   	movi	FHKBEXP_INIT,b0
;	calla	EASYMAKE
;	move	*a8(ODAG),a1,L
;	move	*a8(OANIOFF),a5,L
;	subxy	a5,a1		; upper left
;	move	*a8(OSIZE),a5,L
;	srl	1,a5
;	andi	7fff7fffh,a5
;	addxy	a5,a1		; screen center
;	PUSH	a8
;	move	a0,a8
;	calla	SET_SCRN_POS
;	PULLQ	a8

	MMFM	SP,B1,B2,B4,B5,B6,B8,B9,B10

	calla	NOTICE_DAMAGE
BASIC_DONE:	
	rets


GRATE_CVECT
	WWL	OID_PROCKET,~MASK_PLAYER,UNIV_ROCKET_COLL
	WWL	OID_PEXPLOSION,~MASK_PLAYER,GRATE_COLLVECT
	WL	0,DUMCRETS

GRATE_COLLVECT:
	CALLA	UNIV_COLL_CHECK
	JRNZ	GRATE_DONE

	move	@PORTAL_LOCKOUT,a14
	jrnz	GRATE_DONE

	MOVE	*A0(OID),A0,W			;GET PLAYER DATA ADDRESS
	CALLA	POID_TO_PDATA

	calla	BG_TO_FG
	MOVIM	-20000h,*a8(OYVEL),L
	MOVIM	-3000h,*a8(OYACCEL),W
	MOVIM	-200h,*a8(OZVEL),L
	CLRM	*a8(OCVECT),L
	movi	GRATE_FLY,a1
	calla	STRT_ANIM

	move	@SCROLL_FLAG,a5
	jrz	NO_JOE
	movi	JOE_PERRY_TRIP,a0
	calla	CHNG_SCRL_TBL
NO_JOE:
	inc	a5
	move	a5,@SCROLL_FLAG,W
GRATE_DONE:
	rets


GRATE_FLY:
	LWLL	1,1|AFunc,A_SET_OXVEL+2,40000h
	LWL	1,1|AFunc,A_Set_LOOP_STRT
	LWL	1,1|AFunc,A_OFFSCRN_DEL
	.long	0

****************************************************************
*
*		SODA MACHINE/JEWEL
*
****************************************************************


SODA_CVECT
	WWL	OID_PROCKET,~MASK_PLAYER,UNIV_ROCKET_COLL
	WWL	OID_PEXPLOSION,~MASK_PLAYER,SODA_COLLVECT
	WL	0,DUMCRETS

SODA_COLLVECT:
	CALLA	UNIV_COLL_CHECK
	JRNZ	SODA_DONE

	MOVE	*A0(OID),A0,W			;GET PLAYER DATA ADDRESS
	CALLA	POID_TO_PDATA

	movi	M_LASTFRM,a7 	; flags
	movi	3000,a5		; SCORE
	CLR	A9		; OFFSET
	CALLA	UNIV_DAMAGE_HANDLER

	SOUND1	SND_VIDCAM_EXP

	MMTM	SP,B1,B2,B4,B5,B6,B8,B9,B10

	MOVI	040000H,A0
	MOVI	0100H,A3
	CALLA	PreFrag_Center
	MOVI	FRAG_CANS,B14

	sub	b10,b9			; force Z neg
	sub	b10,b9	
	neg	b10

	sub	b8,b7			; force Y neg
	sub	b8,b7	
	neg	b8

	CALLA	Fragger

	MMFM	SP,B1,B2,B4,B5,B6,B8,B9,B10

	MOVIM	DUMCOLL,*a8(OCVECT),L
SODA_DONE:	
	rets

SODA_GUNVECT:
	move	*a8(OU_ODATA),a0,L	; first time we hit the machine?
	cmpi	012345678h,a0
	jreq	gotcode	     		; BR if not
	movi	012345678h,a0
	move	a0,*a8(OU_ODATA),L	; store code to indicate
	CLRM	*a8(OU_OHITS),W
	movk	20,a1
	movi	60,a0
	calla	RANGRAND
	move	a0,*a8(OU_ODATA+20h)	; save number of hits til jewel 
gotcode:
	move	*a8(OU_OHITS),a0
	inc	a0
	move	a0,*a8(OU_OHITS)
	move	*a8(OU_ODATA+20h),a1	; check if correct number of hits
	cmp	a0,a1			; for jewel
	jrne	normcan
*
*	SEND OUT JEWEL
*
	movi	PJEWEL_INIT,b0		; shoot jewel out and wait
	calla	EASYMAKE		; for player to hit it
	jrz	SODAGUNX

	callr	CAN_POSITION
	move	a14,*a0(OYVAL),L

	move	*a0(OXVAL),a1,L
	move	@XBASE,a14,L
	sub	a14,a1		; world X
	neg	a1
	sra	6,a1
	move	a1,*a0(OXVEL),L

	MOVIM	-200h,*a0(OZVEL),L

	MOVIM	-28000h,*a0(OYVEL),L

	MOVIM	1800h,*a0(OYACCEL),W

	calla	INSOBJ

	move	a0,a8

	SOUNDZ	SND_JEWEL_UP

	CREATE	PID_IND,PJEWEL_PROC
	move	a0,*a8(OPLINK),L

	rets

normcan:
	SOUNDZ	SND_CAN_EJECT

	movi	FLYCAN_INIT,b0
	calla	EASYMAKE
	jrz	SODAGUNX

	callr	CAN_POSITION
	subi	47<<15,a14
	move	a14,*a0(OYVAL),L

	move	a0,a5

	movi	10000h,a0
	movi	-20000h,a1
	calla	RANGRAND
	move	a0,*a5(OXVEL),L

	movi	-10000h,a0
	movi	-40000h,a1
	calla	RANGRAND
	move	a0,*a5(OYVEL),L

	movi	-100h,a0
	movi	-280h,a1
	calla	RANGRAND
	move	a0,*a5(OZVEL),L

	MOVIM	2000h,*a5(OYACCEL),W

	move	a5,a0
	calla	INSOBJ
SODAGUNX:
	rets
	

FLYCAN_INIT
	.long	SODYcan1
	.word	DMAWNZ,M_GCOLL,OM_ANIM|OM_COLL
	.long	CAN_COLL
	.long	sodyfly



CAN_POSITION:
	move	*a8(OXVAL),a14,L
	addi	32<<15,a14
	move	a14,*a0(OXVAL),L

	move	*a8(OZVAL),a14,L
	dec	a14
	move	a14,*a0(OZVAL),L

	move	*a8(OYVAL),a14,L
	rets


CAN_COLL
	WWL	OID_GRND,0FFFFH,CAN_GRND_COLL
	WL	0,DUMCRETS

CAN_GRND_COLL
	MOVE	*A8(OYVEL),A14,L
	jrle	let_bounce
;	JAN	DELETE_OBJ			;BR=GOING UP
;	JAZ	DELETE_OBJ			;BR=STOPPED

	SRA	2,A14				;OYVEL=OYVEL/4

	CMPI	01000H,A14
	JALT	CAN_STOP			;BR=BELOW MINIMUM VELOCITY
	NEG	A14				;REVERSE VELOCITY
	MOVE	A14,*A8(OYVEL),L

	move	*a8(OXVEL),a14,L
	sra	1,a14
	move	a14,*a8(OXVEL),L

	move	*a8(OZVEL),a14,L
	sra	1,a14
	move	a14,*a8(OZVEL),L
let_bounce:
	RETS

CAN_STOP:
	MOVIM	CAN_STAY,*a8(AnimFrm),L
	CLRM	*a8(OCVECT),L
	calla	PSTOP
	rets

CAN_STAY:
	LW	1,60
	LWL	1,1|AFunc,DELETE_OBJ


sodyfly:
   LW   SODYcan1,5
   LW   SODY01,5
   LW   SODY02,5
   LW   SODY03,5
   LW   SODY04,5
   LW   SODY05,5
   LW   SODY06,5
   LW   SODY07,5
   LW   SODY08,5
   .long  0

FRAG_CANS
	.long	sodyfly,CAN_STUFF
	.word	OID_JUNK,(6 << 11) + (3 << 6) + (FRGGCOL+FRGPAL)
	.long	sodyfly,CAN_STUFF
	.word	OID_JUNK,(8 << 11) + (2 << 6) + (FRGGCOL+FRGPAL)
	.long	sodyfly,CAN_STUFF
	.word	OID_JUNK,(5 << 11) + (3 << 6) + (FRGGCOL+FRGPAL)
	.long	sodyfly,CAN_STUFF
	.word	OID_JUNK,(5 << 11) + (2 << 6) + (FRGBOG+FRGGCOL+FRGPAL)
	.long	sodyfly,CAN_STUFF
	.word	OID_JUNK,(6 << 11) + (0 << 6) + (FRGBOG+FRGGCOL+FRGPAL)
	.long	0


CAN_STUFF:
	MOVIM	CAN_COLL,*a0(OCVECT),L
	MOVIM	2000h,*a0(OYACCEL),W
	rets


PJEWEL_INIT:
	.long	JEWEL
	.word	DMAWNZ,0,OM_GUNV|OM_OID
	.word	OID_JEWEL
	.long	POWERUP_GUNVECT


PJEWEL_PROC:
	clr	a11
	sleep	4
	move	*a8(OFLAGS),a14
	btst	B_OFSCRN,a14
	jrz	PJEWEL_PROC

	CLR	a14
	move	a14,*a8(OPLINK),L
	calla	DELETE_OBJ
	DIE

SND_JEWEL_AWARD
	.word	0f3d8h,118,0843bh,0

SND_CAN_EJECT
	.word	0f338h,20,0834ch,0


JEWEL_AWARD:
	SOUND1	SND_JEWEL_AWARD
	move	a2,@JEWEL_OWNER,L
	rets

****************************************************************
*
*		STONE ROUTINES
*
****************************************************************


*
*	Stone pieces which are NOT damageable can come here.
*	Ignore them if they do
*
STONE_COLLVECT:
	move	*a8(OULINK),a14,L
	move	*a14(MAP_IMG),a14	; just need lo 4 bits
	btst	B_IF_DAM,a14
	jrz	SODA_DONE		; skip if not damageable
	CALLA	UNIV_COLL_CHECK
	JRNZ	STONE_DONE

	MOVE	*A0(OID),A0,W			;GET PLAYER DATA ADDRESS
	CALLA	POID_TO_PDATA
STONE_GUNVECT:
	movi	M_NOSTOPANIM|M_LASTFRM|M_NOMORE,a7
	jruc	stg_hk

POINTS_GUNVECT:
	clr	a3
	movi	[-16,0],a4
	jruc	pnt_hook2


PTBLOK_GUNVECT:
	movi	[-124,-41],a3
	movi	[-86,4],a4
	jruc	pnt_hook

NEWHOL_GUNVECT:
	move	*a8(OIMG),a14,L
	cmpi	NEWHOL4,a14
	jreq	nh4gv
	movi	[-39,-54],a3
	movi	[6,-16],a4
	jruc	pnt_hook
nh4gv:
	movi	[-91,-10],a3
	movi	[-49,13],a4


pnt_hook:
	calla	BOX_CHECK_OBJ	; did we shoot the point?
	jrz	STONE_BUL_SND	; ignore if no.
pnt_hook2:
	MOVI	M_NOSTOPANIM,A7 ; if not POINTSIN
	MOVI	0,A5		       
	CLR	A9				;NO OFFSET
	CALLA	UNIV_DAMAGE_HANDLER

	move	a10,a10
	jrz	STONE_BUL_SND		; jump if no damage change
*
*	REVEAL A POWERUP
*
	addxy	a3,a4
	movy	a4,a10
	sext	a4
	sra	1,a10
	sra	1,a4
	movx	a4,a10		; screen Y,X offset
	movk	8,a11
	CREATE	PID_IND,REVEAL_PROCK

	MOVIM	STONE_GUNVECT,*a8(OGUNVECT),L	

	movi	SND_POINT_EXP,a0
	MOVI	FRG_BRONLY_12,A4

	JRUC	PT_DOFRAG		; point sound in a0



stg_hk:
	MOVI	0,A5		       
	CLR	A9				;NO OFFSET
	CALLA	UNIV_DAMAGE_HANDLER

	move	a10,a10
	jrz	STONE_BUL_SND		; jump if no damage change

stg_hk2:
	movi	SND_STONE_EXP2,a0
	move	@RAND,a14
	btst	7,a14
	jrnz	ptok
	movi	SND_STONE_EXP1,a0
ptok:
	MOVI	FRG_BR_12,A4
*
* Entrypoint for brick blowup
*	A0 = Sound to make
*	A4 = Frag script to run
*
PT_DOFRAG
	MMTM	SP,B1,B2,B4,B5,B6,B8,B9,B10
	calla	ONESND_Z
	MOVI	DUMRETS,A14		; any damage means clear gunvect
	MOVE	A14,*A8(OGUNVECT),L

	MOVI	017000H,A0
	MOVI	080H,A3
;	movi	80008h,a4
	CALLA	PreFrag_Center
;	MOVI	FRG_BR_12,B14

	MOVE	A4,B14
PT_DOFRAG_2:			 
	sub	b10,b9
	clr	b10

	sub	b8,b7
	clr	b8

	CALLA	Fragger
	MOVE	*A8(OIMG),A1,L
	MOVE	*A1(ICMAP),*A0(FPDATA),L	;SET PALETTE
	MMFM	SP,B1,B2,B4,B5,B6,B8,B9,B10
STONE_DONE	
	rets


*
*	Generic stone gunvector, puts out
*
BRNSTONE_GUNVECT:
	calla	DGV_FRAG_DUST_BRN
	jruc	STONE_BUL_SND


GRYSTONE_GUNVECT:
	calla	DGV_FRAG_DUST_GRY
	jruc	STONE_BUL_SND


*
*	a3 and a4 are corners of box
*

STONE_BUL_SND:
	movk	3,a0
	movi	STONE_BUL_TAB,a1
	jruc	TAB_SOUND

STONE_BUL_TAB:
	.long	STB1,STB2,STB3

STB1	.word	0f320h,20,0A3b9h,0
STB2	.word	0f320h,20,0A3bch,0
STB3	.word	0f320h,24,0A3bfh,0


WOOD_GUNVECT:
	SOUNDZ	SND_WOOD_HIT
	rets

METAL_DR_GUNVECT
	CALLA	DGV_FRAG_SPARK
	SOUNDZ	SND_METAL_DOOR_HIT	      ;Give a little sound to ack
	RETS

SND_METAL_DOOR_HIT
	.WORD	0F308H,29,0A111H,0	;Metal door being hit

SND_WOOD_HIT
;	.WORD	0F308H,35,0A328H,0	;Wood door being hit
	.WORD	0F308H,17,0A102H,0	;Wood door being hit

;SND_STONE_EXP1	.word	0f390h,58,0a1d7h,0
SND_STONE_EXP1	.word	0f340h,103,0a3D1h,0

;SND_STONE_EXP2	.word	0f390h,75,0a170h,0
SND_STONE_EXP2	.word	0f340h,75,0a38Dh,0

;SND_POINT_EXP	.word	0f390h,22,0a1d4h,0
SND_POINT_EXP	.word	0f340h,22,0a1d7h,0

*************************************************************
*
*		DROPPER DAMAGE
*
***********************************************************

BOXMACH_CVECT:
	WWL	OID_PROCKET,~MASK_PLAYER,UNIV_ROCKET_COLL
	WWL	OID_PEXPLOSION,~MASK_PLAYER,BOXMACH_COLLVECT
	WL	0,DUMCRETS

PIPE_CVECT:
DROP_CVECT:
	WWL	OID_PROCKET,~MASK_PLAYER,UNIV_ROCKET_COLL
	WWL	OID_PEXPLOSION,~MASK_PLAYER,DROP_COLLVECT
	WL	0,DUMCRETS


DROP_COLLVECT:
	CALLA	UNIV_COLL_CHECK
	JRNZ	DROP_DONE

	MOVE	*A0(OID),A0,W			;GET PLAYER DATA ADDRESS
	CALLA	POID_TO_PDATA
	movi	M_NOMORE|M_NEXTFRM|M_NOSTOPANIM,a7
	jruc	drop_hk

*
*	EVENTUALLY, the 2 halves of the box machine will need to be
*			damaged together
*
BOXMACH_COLLVECT:
	CALLA	UNIV_COLL_CHECK
	JRNZ	DROP_DONE

	MOVE	*A0(OID),A0,W			;GET PLAYER DATA ADDRESS
	CALLA	POID_TO_PDATA
	movi	M_NOMORE|M_NEXTFRM,a7
	jruc	drop_hk

BOXMACH_GUNVECT:
	MOVI	M_NOMORE|M_FLASHOBJ,A7
	jruc	drop_hk



PIPE_GUNVECT:
DROP_GUNVECT:
	MOVI	M_NOSTOPANIM|M_NOMORE|M_FLASHOBJ,A7
drop_hk
	MOVI	100,A5		       
	CLR	A9				;NO OFFSET
	CALLA	UNIV_DAMAGE_HANDLER
	jrnc	nobigexpsnd
	movi	EXPLOSNDS,a1
	movk	3,a0
	callr	TAB_SOUND
	jruc	yesbigexpsnd
nobigexpsnd:

	move	a10,a10
	jrz	Do_Dink

	SOUNDZ	SND_POINT_EXP
yesbigexpsnd:
	MMTM	SP,B1,B2,B4,B5,B6,B8,B9,B10


	MOVI	017000H,A0		; X Y max abs val
	MOVI	080H,A3
	movi	0a000ah,a4
	CALLA	PreFrag_Gun
	MOVI	FRAG_U10,B14

	sub	b10,b9			; force Z neg
	clr	b10

	sub	b8,b7			; force Y neg
	clr	b8

	CALLA	Fragger
	MOVE	*A8(OIMG),A1,L
	MOVE	*A1(ICMAP),*A0(FPDATA),L	;SET PALETTE

	MMFM	SP,B1,B2,B4,B5,B6,B8,B9,B10

	calla	NOTICE_DAMAGE
DROP_DONE:
	rets

DO_FLASH_DINK
	CALLA	FlshWyte
Do_Dink:
	calla	DGV_FRAG_SPARK

	movi	MACHITSND,a1
	movk	4,a0
	jruc	TAB_SOUND


MACHITSND
	.long	MACHIT_S1,MACHIT_S4,MACHIT_S2,MACHIT_S3

MACHIT_S1	.word	0f334h,24,0a1e3h,0
MACHIT_S2	.word	0f334h,16,0a1ddh,0
MACHIT_S3	.word	0f334h,13,0a1e0h,0
MACHIT_S4	.WORD	0F334H,39,0A144H,0


*************************************************************
*
*		MORPH CHAMBER
*
***********************************************************


MACH_CVECT
	WWL	OID_PROCKET,~MASK_PLAYER,UNIV_ROCKET_COLL
	WWL	OID_PEXPLOSION,~MASK_PLAYER,MACH_COLLVECT
	WL	0,DUMCRETS


MACH_GRND_CVECT
	WWL	OID_GRND,0FFFFH,DELETE_OBJ
	WL	0,DUMCRETS

*
*	MACHINE PARTS:  
*		OID=9,  back of morph chamber, no damage
*		OID=10,  top of morph chamber, damageable
*		OID=11,  flyaway pieces (when rocketed)
*		OID=12,  control panel, damageable, 2 fires
*		OID=14,  remaing pieces, no damage
*
*	NUM_PILLARS used as 2 bytes to count
*		1) num flown away pieces
*		2) num damaged pieces
*
MACH_COLLVECT:
	CALLA	UNIV_COLL_CHECK
	JRNZ	MACHX

	MOVE	*A0(OID),A0,W			;GET PLAYER DATA ADDRESS
	CALLA	POID_TO_PDATA
	movi	M_NEXTFRM|M_NOMORE,a7
*
*	if rocket hits a piece with ID_12, it flies away
*
	clr	a4			; assume no fly
	move	*a8(OID),a14
	cmpi	OID_UNIV|ID_9,a14	; did we rocket the inside?
	jreq	hit_inside
	cmpi	OID_UNIV|ID_11,a14	; is it a flying piece?
	jrne	mach_hk
	movk	1,a4
	jruc	mach_hk


MACH_GUNVECT:
	clr	a4			; don't fly away
	MOVI	M_FLASHOBJ,A7
	move	*a8(OID),a14
	cmpi	OID_UNIV|ID_11,a14	; is it a flying piece?
	jreq	mach_hk			; if so, don't set NOMORE flag
	ori	M_NOMORE,a7
mach_hk:
	MOVI	100,A5		       
	CLR	A9				;NO OFFSET
	CALLA	UNIV_DAMAGE_HANDLER
	
	move	a4,a4			; should we fly away?
	jrz	noflyaway
*
*	Make this piece fly away
*
	callr	FLY_AWAY

	movb	@NUM_PILLARS,a14	; increase count of flyaways
	inc	a14
	movb	a14,@NUM_PILLARS

	jruc	MACHX
noflyaway:
	move	a10,a10			; if not a new frame, gbye
	jrz	Do_Dink

	MMTM	SP,B1,B2,B4,B5,B6,B8,B9,B10
	SOUNDZ	SND_POINT_EXP

	cmpk	15,a10
	jrne	not_last_frm

	movb	@NUM_PILLARS+8,a14	; increase count of damageables
	inc	a14
	movb	a14,@NUM_PILLARS+8
not_last_frm:
	MOVI	017000H,A0		; X Y max abs val
	MOVI	080H,A3
	movi	80008h,a4
	CALLA	PreFrag_Gun
	MOVI	FRAG_U10,B14

	sub	b10,b9			; force Z neg
	clr	b10

	sub	b8,b7			; force Y neg
	clr	b8

	CALLA	Fragger
	MOVE	*A8(OIMG),A1,L
	MOVE	*A1(ICMAP),*A0(FPDATA),L	;SET PALETTE

	move	*a8(OID),a14
	cmpi	OID_UNIV|ID_12,a14			; is it a flamer?
	jrne	MACHXX
*
*	start some flames going behind it
*
	calla	NOTICE_DAMAGE
	calla	MACH_FIRE
MACHXX:
	MMFM	SP,B1,B2,B4,B5,B6,B8,B9,B10
MACHX:	
	rets


*
*	If we hit inside of morph chamber after 4 flyaways and
*	7 damageables, we can destroy the entire chamber
*	Otherwise, just flash it.
*
hit_inside:
	move	@SCROLL_FLAG,a14,L	 
	jrz	inside_spent		 
	move	@NUM_PILLARS,a14     ; contains counts of damaged parts
	move	a14,a0
	zext	a0
	srl	8,a0		; number damageables
	cmpk	7,a0
	jrlt	justflash

	sll	24,a14
	srl	24,a14		; number flyaways
	cmpk	4,a14
	jrlt	justflash
*
*	MONDO DESTRUCTO EL CHAMBERO DE MORPHO
*
*	find OBJECTS with the proper OIDS and handle them as follows
*		OID_10	(top pieces) get gravity and ground collisions
*		OID_14  (side pieces) fly offscreen
*		OID_9	(inside)  same as OID_10
*
MondoDestructo:
	move	@XSCROLL,a14,L		; are we moving?
	jrnz	inside_spent		; can't blow up if so
	clr	a14			 
	move	a14,@SCROLL_FLAG,L	; not okay to do this again
	move	*a8(OZVAL),a6,L
	
	CLRM	@OBJENEMIES,W		; stop morph chamber guys

	mmtm	sp,a8,a9,a10
	movi	FGLIST,a8
findclose:
	move	*a8,a8,L	; next link
*
	move	*a8(OID),a14
	cmpi	OID_UNIV|ID_10,a14 	; is this a top piece
	jreq	givegrav	; if yes, give it gravity and ground coll
	cmpi	OID_UNIV|ID_9,a14 	; is this an inside piece
	jrne	chkfly		; if no check for a fly away piece
*
*	START SOME MAJOR EXPLOSIONS for inside pieces
*
	CREATE	PID_IND,MASSIVE_EXPLO
	calla	BG_TO_FG
	MOVIM	300h,*a8(OYACCEL),W
	MOVIM	MACH_GRND_CVECT,*a8(OCVECT),L
	MOVIM	DUMRETS,*a8(OGUNVECT),L
	ORIM	M_GCOLL,*a8(OFLAGS),W
	move	*a8(OZVAL),a6,L
	jruc	findclose
givegrav:
	calla	BG_TO_FG
	MOVIM	500h,*a8(OYACCEL),W
	MOVIM	MACH_GRND_CVECT,*a8(OCVECT),L
	MOVIM	DUMRETS,*a8(OGUNVECT),L
	ORIM	M_GCOLL,*a8(OFLAGS),W
	jruc	findclose
chkfly:
	cmpi	(OID_UNIV|ID_14)&(~SUPP_4),a14
	jrne	chkendscan	; is this a flyaway piece?
	CREATE	PID_IND,FLY_AWAY_PROC	; if yes, fly away
	jruc	findclose
chkendscan:
	move	*a8(OZVAL),a14,L
	cmp	a6,a14		; don't look any further
	jrle	findclose
*
*	Get sucked into secret room
*
	move	@SECRET_SCROLL,a0,L	; which room to enter (R or L)
	calla	CHNG_SCRL_TBL

	clr	a14
	move	a14,@ZSCROLL,L
	move	a14,@ZSACCEL,L
	move	a14,@XSCROLL,L
	move	a14,@XSACCEL,L

	mmfm	sp,a8,a9,a10
	rets
*
*	Zap flash the inside of the morph chamber
*
justflash:	      
	movk	20,a0			; dummy hits
	calla	CURPLYR_ADJ
	move	*a8(OU_OHITS),a14
	inc	a14
	move	a14,*a8(OU_OHITS)

	cmp	a0,a14
	jrge	MondoDestructo

	MOVIM	(36<<8)+36,*a8(OCONST),W
	CREATE	PID_IND,STATIC_ZAP_FLASH
inside_spent:			      
	rets


*
*	make a BG piece fly off screen and get deleted
*
FLY_AWAY:
	PUSH	a0

	movi	-50000h,a1
	movi	-20000h,a0
	calla	RANGRAND		; get a random X and Y Val
	move	@RAND,a14
	move	a0,*a8(OYVEL),L
	btst	12,a14
	jrnz	noneg
	neg	a0
noneg:
	move	a0,*a8(OXVEL),L
	MOVIM	1800h,*a8(OYACCEL),W
	calla	BG_TO_FG		; not part of BG anymore
	calla	COLLS_OFF
	movi	OID_JUNK,a1	   
	calla	CHANGE_OID     
	CREATE	PID_IND,DELETE_WHEN_OFFSCRN
	PULLQ	a0
	rets


FLY_AWAY_PROC:
	calla	COLLS_OFF
	movi	OID_JUNK,a1	   
	calla	CHANGE_OID     

	RANDSLP	      10,50

	movi	-50000h,a1
	movi	-20000h,a0
	calla	RANGRAND		; get a random X and Y Val
	move	@RAND,a14
	move	a0,*a8(OYVEL),L
	btst	12,a14
	jrnz	nonegp
	neg	a0
nonegp:
	move	a0,*a8(OXVEL),L
	MOVIM	1800h,*a8(OYACCEL),W
	calla	BG_TO_FG		; not part of BG anymore

DELETE_WHEN_OFFSCRN:
	move	*a8(OCTRL),a14
	jrnn	ibedone		; if INUSE is clear, just die
	move	*a8(OFLAGS),a14
	btst	B_OFSCRN,a14
	jrnz	itsoff
      	sloop	4,DELETE_WHEN_OFFSCRN

itsoff:
	calla	DELETE_OBJ
ibedone:
	DIE


EXPLOSNDS
	.long	EXPLO1,EXPLO2,EXPLO3

EXPLO1		.word	0f3d0h,120,0a38dh,0
EXPLO2		.word	0f3d0h,88,0a390h,0
EXPLO3		.word	0f3d0h,103,0a3d1h,0

*
*	This creates 3 groups of 3 explosions on top of an object
*	a8 = object
*
MASSIVE_EXPLO:
	callr	COMPUTE_UNIV_BOX	; limits in a3,a4,a5,a7
	mmtm	a12,a3,a4,a5,a7

	movk	6,a11
MASS_EXP_LP:
	movi	EXPLOSNDS,a1
	movk	3,a0
	callr	TAB_SOUND

	mmfm	a12,a3,a4,a5,a7
	subi	4*20h,a12

	move	*a8(OZVAL),a6,L
	movi	1000h,a0
	calla	RANDU
	sub	a0,a6		; random Z within 1000h of back piece

	movk	4,a10		; make 3 explosions
	calla	BIG_EXPLOSIONS

	movi	35,a0
	calla	RANDU
	addk	15,a0
	calla	PRCSLP

	dsj	a11,MASS_EXP_LP
	DIE


*
*	Static Zap effect
*
*
STATIC_ZAP_FLASH:
	movk	5,a10		; number of flashes
ST_FL_LP:
	SETF	4,0,0				;FIELD 0 IS 4 BITS
	MOVK	8,A14				;DMACNZ
	MOVE	A14,*A8(OCTRL),0
	SETF	16,1,0				;WORD SIGN EXTEND

	movk	7,a0
	calla	RAND0
	addk	2,a0
	calla	PRCSLP


	SETF	4,0,0				;FIELD 0 IS 4 BITS
	MOVK	2,A14				;DMAWNZ
	MOVE	A14,*A8(OCTRL),0
	SETF	16,1,0				;WORD SIGN EXTEND

	movk	10,a0
	calla	RAND0
	addk	4,a0
	calla	PRCSLP

	dsjs	a10,ST_FL_LP

	DIE



*
*	compute the box of an object in universe coordinates
*
*	a8 = object
*	X range left in a3, a4
*	Y range left in a5, a7
*
COMPUTE_UNIV_BOX:
	move	*a8(OUANIOFF),a4,L
	move	a4,a7
	zext	a4
	srl	16,a7
	sll	15,a4
	sll	15,a7		; convert from pixel to world

	move	*a8(OXVAL),a3,L
	sub	a4,a3		; upper left X in univ
	move	*a8(OYVAL),a5,L
	sub	a7,a5		; upper left Y in univ

	move	*a8(OUSIZE),a4,L
	move	a4,a7
	zext	a4
	srl	16,a7
	sll	15,a4
	sll	15,a7		; convert from pixel to world

	add	a3,a4		; bottom right X in univ
	add	a5,a7		; bottom right Y in univ

	rets


*************************************************************
*
*		VIDEO CAMERA 
*
***********************************************************

SND_VIDCAM_EXP	.word	0f390h,85,0a129h,0
	
VIDCAMSND
	.long	VCHIT_S1,VCHIT_S2,VCHIT_S3,VCHIT_S4

VCHIT_S1	.word	0f388h,24,0a1e3h,0
VCHIT_S2	.word	0f388h,22,0a194h,0
VCHIT_S3	.word	0f388h,16,0a1ddh,0
VCHIT_S4	.word	0f388h,13,0a1e0h,0


VIDCAM_COLLVECT
	CALLA	UNIV_COLL_CHECK
	JRNZ	VIDCX
	MOVE	*A0(OID),A0,W			;GET PLAYER DATA ADDRESS
	CALLA	POID_TO_PDATA

	movi	80,a5
	movk	M_FLASHOBJ|M_NEXTFRM|M_NOMORE,a7
	jruc	vchk
VIDCAM_GUNVECT
	movk	10,a5
	movk	M_FLASHOBJ|M_NOMORE,a7
vchk:
	clr	a9
	CALLA	UNIV_DAMAGE_HANDLER
	jrnc	VIDCX

	MMTM	SP,B1,B2,B4,B5,B6,B8,B9,B10		;MAKE STALL DOOR FRAGMENTS

	SOUNDZ	SND_VIDCAM_EXP

	MOVI	030000H,A0
	MOVI	07FH,A3
	CALLA	PreFrag_Center
	MOVI	FRAG_U10,B14
	CALLA	Fragger

	MOVE	*A8(OIMG),A1,L
	MOVE	*A1(ICMAP),*A0(FPDATA),L	;SET PALETTE

	MMFM	SP,B1,B2,B4,B5,B6,B8,B9,B10
	rets

VIDCX:
MAKE_VIDCAM_SND:
	PUSH	a1
	movi	VIDCAMSND,a1
	movk	4,a0
	callr	TAB_SOUND
	PULLQ	a1
	rets

*****************************************************************
*
*	ARM GRENADE THROW
*
*****************************************************************

WARTHROW:
	LWL	1,2|AFunc,OBJ_OFF
	LWL	1,2|AFunc,A_ADJ_RANDSLP
	LW	1,0
	LWL	1,1|AFunc,ARM_SELECT_POSITION
	LWL	WARTRO1,2|AFunc,OBJ_ON
	LW	WARTRO2,2
	LW	WARTRO3,2
	LWL	WARTRO4,3|AFunc,THROW_GRENADE
	LW	WARTRO5,3
	LW	WARTRO6,3
	LW	WARTRO8,3
	LW	WARTRO10,3
	.long	0

GRENANIM:
	LW	GREN1,3
	LW	GREN2,3
	LW	GREN3,3
	LW	GREN4,3
	LW	GREN5,3
	LW	GREN6,3
	LW	GREN7,3
	.long	0

GRENEXPL:
	LWLW	GRENEXP,1|AFunc,A_MISSLE_EXPL+1,3f3fh
	


WARLEG:
	LW	WARLEG7,2
	LW	WARLEG4,2
	LW	WARLEG1,10
	LW	WARLEG2,7
	LW	WARLEG3,5
	LW	WARLEG4,4
	LW	WARLEG5,3
	LW	WARLEG7,3
	LWL	1,1|AFunc,DELETE_OBJ


ALPOS	.set	-6h	;-9
ACPOS	.set	17h
ARPOS	.set	39h	; 3c



*
*	Save object of receptionist (& arm throwing)
*
SAVE_ME:
	move	a8,@LEGOBJ,L
	rets


arm_pos_tbl:		
;    0      = no positions available
;    1,2,4  = only one position available
;    3,5,6  = two positions available
;    7      = any of three positions

	.word	ALPOS,0		; 1
	.word	ACPOS,0		; 2
	.word	ACPOS,ALPOS	; 3
	.word	ARPOS,0		; 4
	.word	ARPOS,ALPOS	; 5
	.word	ACPOS,ARPOS	; 6


ARM_SELECT_POSITION:
	movk	2,a3		; assume choice of 2 for now
	clr	a2
	move	@SIGN_DOWN,a14
	jrz	no_pos_avail
	move	a14,a1
	srl	8,a1		; clear off bottom bits
	sll	24,a14		; clear off top bits
	srl	24,a14
	xor	a1,a14
	jrz	no_pos_avail
	cmpk	7,a14
	jrne	get_2
	movi	ARPOS,a2
	dec	a14
	inc	a3		; can choose from 3
get_2:
	dec	a14
	sll	5,a14		; turn into index
	addi	arm_pos_tbl,a14
	move	*a14+,a4
	move	*a14+,a1
	jrz	got_pos
	move	a3,a0
	calla	RANDU		; get random #
	cmpk	1,a0
	jreq	got_pos
	move	a1,a4
	cmpk	2,a0
	jreq	got_pos
	move	a2,a4
*
*	ARM POSITION is in a4
*
got_pos:
	move	a4,*a8(OXPOS)
	rets

no_pos_avail:
	move	*a8(AnimScr),*a8(AnimFrm),L
	rets


GREN_INIT:
	LWWWW	GREN1,DMAWNZ,M_MANSCALE|M_NOSCALE,OM_ANIM|OM_OID|OM_GUNV|OM_COLL, OID_EROCKET
	.long	GREN_CVECT,GREN_GUNVECT
	.long	GRENANIM

GREN_CVECT
	WWL	OID_PROCKET,~MASK_PLAYER,GREN_COLL
	WL	0,DUMCRETS


THROW_GRENADE:
	movi	GREN_INIT,b0
	calla	EASYMAKE
*
*	Set position relative to arm
*
	move	*a8(OZVAL),*a0(OZVAL),L
	move	*a8(OYVAL),a14,L
	subi	30<<15,a14
	move	a14,*a0(OYVAL),L
	move	*a8(OXVAL),a14,L
	addi	30<<15,a14
	move	a14,*a0(OXVAL),L

	calla	INSOBJ
	PUSH	a8
	move	a0,a8

	movi	-240000h,a1
	movi	-080000h,a0
	calla	RANGRAND	; get random Y
	move	a0,a4

	move	*a8(OYVAL),a5,L
	move	@YBASE,a14,L
	sub	a14,a5		; world Y in a5
	sub	a5,a4
	sra	6,a4
	subi	24000h,a4
	move	a4,*a8(OYVEL),L	

	movi	-01b0000h,a1
	movi	01e0000h,a0
	calla	RANGRAND	; get random X
	move	a0,a3		; World Target X in a0, Y in a1

	move	*a8(OXVAL),a5,L
	move	@XBASE,a14,L
	sub	a14,a5		; world x in a5
	sub	a5,a3
	sra	6,a3
	move	a3,*a8(OXVEL),L	

	movi	1800h,a14
	move	a14,*a8(OYACCEL)

	move	*a8(OZVAL),a5,L
	move	@ZBASE,a14,L
	sub	a14,a5	      	; WORLD Z
	sra	8,a5	  	; compute pseudo Z
	movi	5c0h,a0
	mpys	a0,a5
	subi	0d4d9h,a5
	sra	Z2SCALE,a5	; compute scale from pseudo Z
	move	a5,a9
	calla	SET_SCALE_MANUAL

	CREATE	PID_IND,GREN_ADJ_SCL
	move	a0,*a8(OPLINK),L

	movi	-140h,a14
	move	a14,*a8(OZVEL),L
	PULLQ	a8
	rets

*	a8 = obj
*	a9 = last scale set
*
GREN_ADJ_SCL:
	move	*a8(OZVAL),a5,L
	move	@ZBASE,a14,L
	sub	a14,a5	      	; WORLD Z
	cmpi	ZMAX_REAL+380h,a5
	jrle	explode_gren
	sra	8,a5	  	; compute pseudo Z
	movi	5c0h,a0
	mpys	a0,a5
	subi	0d4d9h,a5
	sra	Z2SCALE,a5	; compute scale from pseudo Z
	cmp	a5,a9
	jreq	notnew
	move	a5,a9
	calla	SET_SCALE_MANUAL
notnew:
	sloop	3,GREN_ADJ_SCL


explode_gren:
	clr	a14
	move	a14,*a8(OPLINK),L
	movi	GRENEXPL,a1
	move	a1,*a8(AnimScr),L
	move	a1,*a8(AnimFrm),L
	DIE


GREN_COLL:
	MOVE	*A0(OID),A0,W			;GET PLAYER DATA ADDRESS
	CALLA	POID_TO_PDATA			;GET PDATA IN A2
	mmtm	sp,b0,b1,b2,b3,b4,b5,b6,b7,b8,b9,b10
	callr	GREN_GUNVECT
	mmfm	sp,b0,b1,b2,b3,b4,b5,b6,b7,b8,b9,b10
	rets


*
* GRENADE Gun Vector
*
* PASS:									 
* A2 = PTR TO PLAYER						         
* A8 = PTR TO OBJECT							 
*
GREN_GUNVECT:
	move	*a8(OSCALE),a0,L
	move	*a8(OIHOFF),a1
	jrz	noihoffadj
iii:
	sll	1,a0
	subi	IHDRSIZ,a1
	jrnz	iii
noihoffadj:
	move	a0,a14 		; adjust scale to make explo slightly bigger
	srl	2,a14		; 
	andi	0fff0fffh,a14	; 
	sub	a14,a0		; 
	PUSH	a2
	calla	MAKE_SAFE_EXPLOSION   
	PULLQ	a2
	movi	200,a1
	calla	SCORE
	calla	DELETE_OBJ_PROC		; delete the missle
;	ADDSOUND	player destroys missle
	SOUND1	SND_GREN_EXPLODE
	rets

SND_GREN_EXPLODE
	.WORD	0F341H,80,0A38DH,0	;grenade blows up in mid-air


DOCPILE_CVECT
	WWL	OID_PROCKET,~MASK_PLAYER,UNIV_ROCKET_COLL
	WWL	OID_PEXPLOSION,~MASK_PLAYER,DOCPILE_COLLVECT
	WL	0,DUMCRETS


DOCPILE_COLLVECT
	move	@OBJENEMIES,a14
	btst	B_OF_PILE,a14
	jrz	DPX
	CALLA	UNIV_COLL_CHECK
	JRNZ	DPX
	MOVE	*A0(OID),A0,W			;GET PLAYER DATA ADDRESS
	CALLA	POID_TO_PDATA

	movi	80,a5
	movk	M_FLASHOBJ|M_NEXTFRM|M_NOMORE,a7
	jruc	dchk
DOCPILE_GUNVECT
	move	@OBJENEMIES,a14
	btst	B_OF_PILE,a14
	jrz	DPX
	movk	10,a5
	movk	M_FLASHOBJ|M_NOMORE,a7
dchk:
	clr	a9
	CALLA	UNIV_DAMAGE_HANDLER
	jrc	DOCP_EXPLO

	MMTM	SP,B1,B2,B4,B5,B6,B8,B9,B10

	SOUNDZ	SND_DOCP_HIT

	MOVI	030000H,A0
	MOVI	07FH,A3
	btst	B_NEXTFRM,a7		; coming from rocket or gun?
	jrz	dc_gun
	CALLA	PreFrag_Center
	jruc	dc_rocket
dc_gun:
	movi	[10,10],a4
	CALLA	PreFrag_Gun
dc_rocket:
	MOVI	FRAG_U5,B14
	CALLA	Fragger

	MOVE	*A8(OIMG),A1,L
	MOVE	*A1(ICMAP),*A0(FPDATA),L	;SET PALETTE

	MMFM	SP,B1,B2,B4,B5,B6,B8,B9,B10
DPX:
	rets


DOCP_EXPLO:
	MMTM	SP,B1,B2,B4,B5,B6,B8,B9,B10
	PUSH	a2
	clr	a1
	move	*a8(OUANIOFFY),a2
	sll	15,a2
	neg	a2
	movi	M_DBLSCL,a3
	calla	MAKE_EXPLO_OFF
	SOUND1	SND_EXPLO_L

	calla	ROPE_BRIDGE		; check toppling of bridge

	PULLQ	a2
	MMFM	SP,B1,B2,B4,B5,B6,B8,B9,B10
	rets


SND_DOCP_HIT
	.WORD	0F341H,62,0A1a3H,0	;ricochet when docpile hit



VIDCAM_CVECT
	WWL	OID_PROCKET,~MASK_PLAYER,UNIV_ROCKET_COLL
	WWL	OID_PEXPLOSION,~MASK_PLAYER,VIDCAM_COLLVECT
	WL	0,DUMCRETS

DESK_CVECT
	WWL	OID_PROCKET,~MASK_PLAYER,UNIV_ROCKET_COLL
	WWL	OID_PEXPLOSION,~MASK_PLAYER,DESK_COLLVECT
	WL	0,DUMCRETS

SKYLIT_CVECT
	WWL	OID_PROCKET,~MASK_PLAYER,UNIV_ROCKET_COLL
	WWL	OID_PEXPLOSION,~MASK_PLAYER,SKYLIT_COLLVECT
	WL	0,DUMCRETS

DSKSTUF_CVECT
	WWL	OID_PROCKET,~MASK_PLAYER,UNIV_ROCKET_COLL
	WWL	OID_PEXPLOSION,~MASK_PLAYER,DSKSTUF_COLLVECT
	WL	0,DUMCRETS



DSKSTUF_COLLVECT:
	CALLA	UNIV_COLL_CHECK
	JRNZ	DSKSTUF_DONE

	MOVE	*A0(OID),A0,W			;GET PLAYER DATA ADDRESS
	CALLA	POID_TO_PDATA

DSKSTUF_GUNVECT:
	MOVK	M_NOMORE|M_FLASHOBJ,A7  ;LAST FRAME AND FLASH
	MOVI	0,A5  
	CLR	A9				;NO OFFSET
	CALLA	UNIV_DAMAGE_HANDLER

	SOUND1	SND_DESK_DAM

	calla	BG_TO_FG

	movi	-100h,a14
	move	a14,*a8(OZVEL),L

	movi	-40000h,a14
	move	a14,*a8(OYVEL),L

	movi	2800h,a14
	move	a14,*a8(OYACCEL)

	movi	-20000h,a1
	movi	20000h,a0
	calla	RANGRAND
	move	a0,*a8(OXVEL),L

	movi	DUMRETS,a14
	move	a14,*a8(OGUNVECT),L
	movi	GLAS_COLL,a14
	move	a14,*a8(OCVECT),L

DSKSTUF_DONE:	
	rets

SND_DESK_DAM
	.word	0f350h,47,0a166h,0

***********************************************************
*
*	BUGHEAD for entering dead end hallways
*
***********************************************************


BUGHEAD_CVECT
	WWL	OID_PROCKET,~MASK_PLAYER,UNIV_ROCKET_COLL
	WWL	OID_PEXPLOSION,~MASK_PLAYER,BUGHEAD_COLLVECT
	WL	0,DUMCRETS

*
*	If you rocket the bughead, it will be gone.
*
*
BUGHEAD_COLLVECT:
	CALLA	UNIV_COLL_CHECK
	JRNZ	BUGHEAD_DONE

	MOVE	*A0(OID),A0,W			;GET PLAYER DATA ADDRESS
	CALLA	POID_TO_PDATA
Bughdstry:
	callr	FindMatch	; find other half
	jrnz	BUGHEAD_DONE	; should return with Z set
	PUSH	a8
	move	a1,a8
	calla	BG_TO_FG

	callr	stg_hk2		; make stone sound and send fragments

	calla	DELETE_OBJ

	PULLQ	a8

	calla	BG_TO_FG

	callr	stg_hk2		; make stone sound and send fragments

	calla	DELETE_OBJ

	CLRM	@HALL_LOCKOUT,W	
BUGHEAD_DONE:	
	rets

JEWEL_INIT:
	.long	JEWEL
	.word	DMAWNZ,M_MANSCALE,OM_WPOS|OM_GRND
	.long	0,0h,ZMAX_REAL		; X,Y,Z world

*
*	There are bugheads which suck you into the dead end hall
*	and bugheads at the end of the dead end halls.
*		
BUGHEAD_GUNVECT:
	move	*a8(OULINK),a14,L
	jrz	GnorPortGV
	move	*a14(MAP_IMG),a14
	btst	B_IF_DANIM,a14		; if danim, check end of hall
	jrz	do_PORTLGUN   		; if static, check hall entrance
*
*	DANIM is set
*

	move	@HALL_LOCKOUT,a14	; allowed to enter?
	jrge	GnorPortGV		; if pos, we are not in hallway

	move	@ZSCROLL,a14,L		; ignore if we are backing out
	jrle	GnorPortGV
	move	@ZBASE,a14,L
	move	*a8(OZVAL),a0,L
	sub	a14,a0			; world Z
	cmpi	18000h,a0
	jrgt	GnorPortGV

	move	*a8(OFLAGS),a14		; are we currently animating?
	btst	B_ANIM,a14
	jrnz	GnorPortGV		; ignore hit if we are animating

*
*	Check to see if we possess jewel
*	
	move	@JEWEL_OWNER,a14,L	; did the owner shoot the head?
	cmp	a14,a2
	jrne	GnorPortGV

	CREATE	PID_IND,SEND_JEWEL	

	movi	80000,a1		; award points for player with jewel
	clr	a9
	calla	PRINT_SCORE

*
*	Change scroll table to Open secret door
*
	movi	ENTER_SECRET_ROOM,a0
	calla	CHNG_SCRL_TBL


	CLRM	@HALL_LOCKOUT,W

	rets


S_PUSH_WALL_IN:
	move	@JEWEL_OWNER,a14,L	; does anyone own jewel?
	janz	SCRL_DISPATCHER	  	; jump if no
	
	move	@RAMREF0,a0,L
	move	@RAMREF1,a5,L
	movi	M_BF_ID,a2
	movi	6<<B_BF_ID,a3
	movk	2,a6			; num pieces to find
SPWI_lp:
	move	*a0(MAP_FLAGS),a4
	and	a2,a4
	cmp	a3,a4			; is this the right OID?
	jrne	SPWI_nxt		; br if no		
	move	*a0(MAP_OBJ),a8,L	; get obj
	jrn	SPWI_nxt		; BR if no obj
	move	*a0(MAP_IMG),a9,L	; get img
	move	a9,a10
	sll	30,a10
	srl	30,a10
	cmpk	3,a10
	jrne	SPWI_nxt		; br if not a DANIM seq
*
*	advance one image
*
	move	@HALL_LOCKOUT,a1	; number of BONKS
	neg	a1
	cmpk	3,a1
	jahi	SCRL_DISPATCHER		; bad index
	sll	5,a1
	addi	SEC_DR_TABLE,a1
	move	*a1,a1,L
	move	*a8(OCTRL),a4
	calla	ANI
	dsj	a6,SPWI_nxt
	JAUC	SCRL_DISPATCHER

SPWI_nxt
	move	*a0(MAP_NEXT),a0,L
	cmp	a0,a5
	jrne	SPWI_lp
	JAUC	SCRL_DISPATCHER



do_PORTLGUN:
	move	@HALL_LOCKOUT,a14	; allowed to enter?
	jrz	Bughdstry		; if 0, destroy
	jrn	GnorPortGV		; if neg, we are already in hallway
	neg	a14			; make it neg (temporary disable)
	move	a14,@HALL_LOCKOUT
	movi	ENTER_DEADEND,a7	; suck us in
*
*	Interrupt current Scroller, but save
*
	move	@SCROLL_PROCESS,a14,L
	move	*a14(LAST_SP),a6,L
	move	a14,a5
	addi	PA11,a5
	move	a2,b14
	mmfm	a5,a0,a1,a2,a3,a4
	mmtm	a6,a0,a1,a2,a3,a4	; save wake and regs on Proc stack
	move	a6,*a14(PSPTR),L	; save new stack pointer
	move	a6,*a14(LAST_SP),L	; save new stack pointer
	move	a7,*a14(PA11),L		; new scroll table
	movi	SCRL_DISPATCHER,a0
	move	a0,*a14(PWAKE),L
 
	MOVK	1,A0
	move	a0,*a14(PTIME),W

	SOUND1	SND_DIR_CHOSEN

	move	b14,a2
GnorPortGV:
	rets


FindMatch:
	move	*a8(OID),a7
	move	*a8(OXVAL),a6,L
	move	*a8(OZVAL),a5,L

	movi	FGLIST,a1
	move	a1,a3
FMlp:
	move	*a1+,a1,L
	cmp	a1,a3			; end of list?
	jreq	FM_nope
	move	*a1(OID),a14
     	cmp	a14,a7
	jrne	FMlp
	cmp	a1,a8
	jreq	FMlp
	move	*a1(OZVAL),a14,L	
	cmp	a14,a5
	jrne	FMlp
*
*	OID and ZPOS are sufficient for the Bughead
*
	rets		; with Z set	

FM_nope:
	movk	1,a1	; with Z clr
	rets



*
*	a8 = jewel
*	a9 = target obj (bughead hole)
*
SEND_JEWEL:
	move	a8,a9
	sleep	30

	SOUND1	SND_JEWEL_UP

	movi	JEWEL_INIT,b0
	calla	EASYMAKE
	move	a0,a8

	CREATE	PID_IND,ADJ_JEWEL_SCALE
	move	a0,a10

	move	a8,a0
	calla	INSOBJ

	calla	GLOW_BLUE		; glow palette

	movi	050h,a5
	calla	SET_SCALE_MANUAL

	movk	30,a11
SJlp:
	move	*a9(OXVAL),a1,L		; target X
	move	*a8(OXVAL),a2,L		; current X
	sub	a2,a1
	sra	4,a1
	move	a1,*a8(OXVEL),L

	move	*a9(OYVAL),a1,L		; target Y
	move	*a8(OYVAL),a2,L		; current Y
	sub	a2,a1
	sra	4,a1
	move	a1,*a8(OYVEL),L

	move	*a9(OZVAL),a1,L		; target Z
	move	*a8(OZVAL),a2,L		; current Z
	sub	a2,a1
	sra	4,a1
	move	a1,*a8(OZVEL),L


	sleep	5

	dsj	a11,SJlp

	move	*a9(OXVAL),*a8(OXVAL),L
	move	*a9(OYVAL),*a8(OYVAL),L
	move	*a9(OZVAL),a0,L
	subk	3,a0
	move	a0,*a8(OZVAL),L

	clr	a14
	move	a14,*a8(OXVEL),L
	move	a14,*a8(OYVEL),L
	move	a14,*a8(OZVEL),L

	move	a10,a0
	calla	KILL

	move	*a8(OFLAGS),a14
	andni	M_MANSCALE|M_NOSCALE,a14
	move	a14,*a8(OFLAGS)		; scale normally now

	sleep	60*60		; sleep 1 minute

	calla	DELETE_OBJ	; delete jewel
	movi	PID_TCYCLE,a0
	calla	KILLPROC_ALL	; kill blue glow

	DIE


SND_JEWEL_UP
	.word	0f3d0h,153,0a43eh,0

*
*	SCALE = Targ Scale + (ZCUR - TargZ) * SLOPE
*
ADJ_JEWEL_SCALE:
	move	*a8(OZVAL),a1,L		; Z1
	move	*a9(OZVAL),a10,L 	; Z2 (Target) in a10

	movi	0902eh>>Z2SCALE,a11	; S2 (Target Scale) in a11

	move	a11,a9
	subi	050h,a9			; S2-S1 in a9

	sub	a10,a1			; Z1-Z2 
	neg	a1			; Z2-Z1 in a1

	sll	16,a9
	divs	a1,a9			; slope in a9

ADJ_JSCL_lp:
	move	*a8(OZVAL),a5,L
	sub	a10,a5			; Zcur - Ztarg
	mpys	a9,a5			;  * slope
	sra	16,a5
	add	a11,a5
	calla	SET_SCALE_MANUAL
	sloop	1,ADJ_JSCL_lp


****************************************************************
*
*		SKULL ROUTINES
*
****************************************************************
SKUL1Z	.set	0b491h		; world Z of retreating SKULL
SKUL2Z	.set	14000h		; world Z of morphing SKULL

morph1:
   LW	LEAK1,4
   LWL	LEAK2,4|AFunc,A_ADJ_GOOPY
   LWL	LEAK3,4|AFunc,A_ADJ_GOOPY
   LWL	LEAK4,4|AFunc,A_ADJ_GOOPY
   LWL	LEAK5,4|AFunc,A_ADJ_GOOPY
   LWL	LEAK6,4|AFunc,A_ADJ_GOOPY
   LWL	LEAK7,4|AFunc,A_ADJ_GOOPY
   LWL	LEAK8,4|AFunc,A_ADJ_GOOPY
   LWL	LEAK9,4|AFunc,A_ADJ_GOOPY
   LW	LEAK10,4
   LW	LEAK11,4
   LW	LEAK12,4
   LW	LEAK13,5
   LW	LEAK14,7
   LW	LEAK15,10
   LW	LEAK16,16
   LW   PUDDLE1,7
   LW	MORPH01,5
   LW   PUDDLE1,3
   LW	MORPH01,2
   LWL  PUDDLE1,3|AFunc,A_CREATE_NOSCALE_PROC
SKULLGROW:
   LW	MORPH01,2
   LW	MORPH02,2
   LW	MORPH01,2
   LW   PUDDLE1,2
   LW	MORPH01,3
   LW   PUDDLE1,3
   LW	MORPH01,3
   LW	MORPH02,3
   LW   MORPH03,3
   LW   MORPH04,3
   LW   MORPH05,3
   LW   MORPH06,3
   LW   MORPH07,3
   LW   MORPH08,3
   LW   MORPH09,3
   LW   MORPH10,3
morph2:
   LWL	MOUTHOPEN,40|AFunc,ADD_SKULL_PARTS

SKULL_RISE:
   LWLL	1,1|AFunc,A_SET_OYVEL+2,-40000h
   LWLW	1,1|AFunc,A_STAY_TIL_SY_LT+1,68
   LWL	1,1|AFunc,A_CLR_OYVEL
   LWL	1,1|AFunc,START_SKULL


SKULLSHRINK:
	LW	MORPH10,2
	LW   	MORPH09,2
	LW   	MORPH08,2
	LW   	MORPH07,2
	LW   	MORPH06,2
	LW   	MORPH05,3
	LW   	MORPH04,3
	LW   	MORPH03,3
	LW   	MORPH02,3
	LW   	MORPH01,4
	LW   	PUDDLE1,4
	LW   	LEAK16,4
	LW   	LEAK15,4
	LW   	LEAK14,4
	LW   	LEAK13,4
	LW   	LEAK12,3
	LW   	LEAK11,3
	LW   	LEAK10,3
	LWLL   	LEAK9,3|AFunc,A_SET_OYVEL+2,-10000h
	LW   	LEAK8,2
	LW   	LEAK7,2
	LW   	LEAK6,2
	LW   	LEAK5,2
	LW   	LEAK4,2
	LW   	LEAK3,2
	LWLW  	LEAK2,2|AFunc,A_CLR_SCRLFLG_BIT+1,1
	LWL   	LEAK1,2|AFunc,DELETE_OBJ



SKLAFF:
   LWLWW 1,1|AMulti|AFunc,A_RAND_AnimSLP+2,3,45
   LW	 1,1|AMulti
   LW	 1,1|AMulti
   LW	 1,1|AMulti
   LW	 MOUTHCLOS,1|AMulti
   LW	 MOUTHCLOS,1
   LW	1,0

   LWLWW 1,1|AMulti|AFunc,A_RAND_AnimSLP+2,3,45
   LW	 1,1|AMulti
   LW	 1,1|AMulti
   LW	 1,1|AMulti
   LW	 MOUTHOPEN,1|AMulti
   LW    MOUTHOPEN,1
   LW	1,0

   .long 0



SKSPLIT:
	LWLW	1,1|AFunc,A_Set_AnimLoop+1,9
SKSPLIT_lp:
	LW	SHUD1CAP,1|AMulti	; SHUDDER for a while
	LWLL	SHUD1PUD,1|AMulti|AFunc,A_SOUND+2,SND_SKGRNT2
	LW	SHUD1CAP,1|AMulti
	LW	SHUD1PUD,1|AMulti
	LW	SHUD1MTH,3|AMulti
	LW	SHUD1MTH,3

	LW	SHUD2CAP,1|AMulti
	LW	SHUD2PUD,1|AMulti
	LW	SHUD2CAP,1|AMulti
	LW	SHUD2PUD,1|AMulti
	LW	SHUD2MTH,1|AMulti
	LW	SHUD2MTH,2

	LWLL	1,1|AFunc,A_Anim_DSJ+2,SKSPLIT_lp
	LWL	1,1|AFunc,SK_INTO_IBALLS

   LW   SKEYE1,1|AMulti
   LW   SKEYE1,1|AMulti
   LW   CHEYE1,1|AMulti
   LW   CHEYE1,5
   LW   SKEYE2,1|AMulti
   LW   SKEYE2,1|AMulti
   LW   CHEYE2,1|AMulti
   LW   CHEYE2,5
   LW   SKEYE3,1|AMulti
   LW   SKEYE3,1|AMulti
   LW   CHEYE3,1|AMulti
   LW   CHEYE3,5
   LW   SKEYE4,1|AMulti
   LW   SKEYE4,1|AMulti
   LW   CHEYE4,1|AMulti
   LW   CHEYE4,5
   LW   SKEYE5,1|AMulti
   LW   SKEYE5,1|AMulti
   LW   CHEYE5,1|AMulti
   LW   CHEYE5,5
   LW   SKEYE6,1|AMulti
   LW   SKEYE6,1|AMulti
   LW   CHEYE6,1|AMulti
   LW   CHEYE6,5
   LW   SKEYE7,1|AMulti
   LW   SKEYE7,1|AMulti
   LW   CHEYE7,1|AMulti
   LW   CHEYE7,5
   LW   SKEYE8,1|AMulti
   LW   SKEYE8,1|AMulti
   LW   CHEYE8,1|AMulti
   LW   CHEYE8,5
   LW   SKEYE9,1|AMulti
   LW   SKEYE9,1|AMulti
   LW   CHEYE9,1|AMulti
   LW   CHEYE9,5
   LW   SKEYE10,1|AMulti
   LW   SKEYE10,1|AMulti
   LW   CHEYE10,1|AMulti
   LW   CHEYE10,5
   LWL	1,1|AFunc,SKUL2EYZ_DONE

A_ADJ_GOOPY:
	move	*a8(OYPOS),a0
	addk	4,a0
	move	a0,*a8(OYPOS)
	rets


A_CREATE_NOSCALE_PROC:
	move	*a8(OPART1),a1,L	; is this head?
	cmp	a1,a8
	jrne	nope
mulp:
	move	*a1(OFLAGS),a0
	ori	M_MANSCALE|M_NOSCALE,a0
	move	a0,*a1(OFLAGS)
	move	*a1(OPARTS),a1,L
	jrnz	mulp
	move	*a8(OSCALEX),a9
	CREATE	PID_IND,GET_TO_NOSCALE
nope:
	rets

GET_TO_NOSCALE:
	subk	10,a9
	cmpi	100h,a9
	jrlt	mk_noscl

	move	a9,a5
	calla	SET_SCALE_MANUAL
	sloop	1,GET_TO_NOSCALE
	

mk_noscl:
	callr	MAKE_NOSCALE
*
*	SHIFT SKULL AROUND IN X
*
	DIE


MAKE_NOSCALE:
	move	*a8(OPART1),a0,L
	jrnz	nxtpart
	move	a8,a0
nxtpart:
	move	*a0(OFLAGS),a14
	andni	M_MANSCALE,a14
	ori	M_NOSCALE,a14
	move	a14,*a0(OFLAGS)
	movi	1000100h,a14
	move	a14,*a0(OSCALE),L
	move	*a0(OUANIOFF),*a0(OANIOFF),L
	move	*a0(OUSIZE),*a0(OSIZE),L
	move	*a0(OPARTS),a0,L
	jrnz	nxtpart
	rets

**************  for IBALL

SavYVEL	  .set	ODATA+120h
SavZVEL	  .set	ODATA+0c0h
GndHitFlg .set	ODATA+0e0h
LastHt	.set	ODATA+0f0h

SKULL_INIT:
	.byte	2,0,0,1
	.long	P_EYEB
	.word	OID_BTR,OM_POS|OM_WPOS|OM_GRND
	.long	0,600000h,0f400h		; X,Y,Z world
	LWWWW	MOUTHOPEN,DMAWNZ,M_NOSCALE,0,OM_GUNV|OM_ANIM
	.long	SKULL_GUNVECT,morph2
	LWWWW	MOUTHOPEN,DMAWNZ|M_FLIPH,M_NOSCALE,0,OM_PRVGUNV|OM_PRVANIM



GOOP_INIT:
	.byte	2,0,0,1
	.long	P_EYEB
	.word	OID_BTR,OM_POS|OM_WPOS|OM_GRND
	.long	0,-200000h,0f400h		; X,Y,Z world
	LWWWW	LEAK1,DMAWNZ,0,0,OM_GUNV|OM_ANIM
	.long	SKULL_GUNVECT,morph1
	LWWWW	LEAK1,DMAWNZ|M_FLIPH,0,0,OM_PRVGUNV|OM_PRVANIM


SND_GOOP_FALL	.word	0f3c1h,80,839ah,0
SND_SLIME_HIT	.word	0f320h,20,0a1c4h,0	
SND_SHUDDER  	.word	0e3a0h,68,0a1c1h,0	
SND_IBALL_ST 	.word	0f370h,40,0a1c7h,0	
SND_SKLAFF1 	.word	0e390h,114,082b7h,0	
SND_SKLAFF2 	.word	0e390h,121,082b9h,0	
SND_SKGRNT1 	.word	0e3b0h,33,082bch,0
SND_SKGRNT2 	.word	0e3b0h,61,082bdh,0	
SND_SKGRNT3 	.word	0e3b0h,33,082bah,0

SK_GRNT_TAB	.long	SND_SKGRNT1,SND_SKGRNT2,SND_SKGRNT3


SND_IBALL_POP		.word	0f382h,71,0a12fh,0
SND_IBALL_EXPL1		.word	0f3a4h,71,0a12fh,0
SND_IBALL_EXPL2		.word	0f3a4h,63,0a14dh,0
SND_BIGI_EXPL		.word	0f3b4h,88,0a390h,0



*
*	GOOP falls from skylight and turns into skull
*			or
*	SKULL rises from the wave pool
*
S_START_GOOP:
	movi	SKULL_INIT,b0		; assume out of pool
	move	*a11+,a3,L
	move	a3,a5
	andi	1,a5
	jrz	out_of_pool
	movi	GOOP_INIT,b0		; down from skylight
out_of_pool:
	move	a5,@SKULL_RETREAT
	xor	a5,a3			; clear retreat flag out of Z
	move	@ZREL_OFF,a14,L
	sra	ZFRAC,a14	; get to lo res
	add	a14,a3		; get absolute universe Z
	calla	MULTIMAKE

	move	*a8(OPART1),a0,L
multlp:
	move	a3,*a0(OZVAL),L
	move	*a0(OPARTS),a0,L
	jrnz	multlp

	clr	a14  	       
	move	a14,@SKULL_HITS	
	move	@WAVEIRQS,a14,L
	move	a14,*a8(OSROCKET),L 

	calla	INSERT_OBJ

	btst	0,a5		; check RETREAT/MORPH flag
	jrnz	retreatmode
	SOUND1	SND_SKLAFF1
	jauc	S_WAIT_HERE

retreatmode:
	SOUND1	SND_GOOP_FALL
	jauc	S_WAIT_HERE
	

*
*	SKULL CAP = OPARTID 1
*	SKULL MOUTH = OPARTID 3
*	SKULL PUDDLE = OPARTID 2
*
SKULPRTS_INIT:
	.byte	2,0,0,1
	.long	P_EYEB
	.word	OID_BTR,OM_COLL
	.long	SKULL_CVECT
	LWWWW	SKULLCAP, DMAWNZ, M_NOSCALE, 0, OM_GUNV
	.long	SKULL_GUNVECT
	LWWWW	PUDDLEBOT, DMAWNZ, M_NOSCALE, 0, OM_PRVGUNV


SKULL_CVECT:
	WWL	OID_PROCKET,~MASK_PLAYER,SKULL_COLL
	WL	0,DUMCRETS


OSROCKET .set ODATA+100h

*
*	SKULL HIT BY ROCKET causes JIGGLE
*
SKULL_COLL:
	move	a8,a9
	move	*a8(OPART1),a8,L	; get head

	move	*a8(OSROCKET),a14,L
	move	@WAVEIRQS,a3,L
	move	a3,a0
	sub	a14,a3
	JRN	SC_HIT_IT		;Condom for some garbage bullshit
	cmpi	50,a3			; one hit allowed every 50 ticks
	jrlt	nocando			; if less, no coll
SC_HIT_IT
	move	a0,*a8(OSROCKET),L	; else  set new time

	move	*a8(AnimScr),a1,L
	cmpi	SKLAFF,a1
	jrne	nocando
*
*	The reason this is done each time a collision occurs is in
*	case players buy in while you are battling the skull
*
	movk	18,a0		; max hits for one player
	calla	CURPLYR_ADJ

	move	@SKULL_RETREAT,a14	; in pool?
	jrnz	got_limit2
	move	a0,a14
	srl	1,a14
	add	a14,a0			; increase by 50%
got_limit2:
	sll	4,a0			; 1 rocket = 16 bullet hits
	move	@SKULL_HITS,a5
	addk	16,a5	   
	move	a5,@SKULL_HITS
	cmp	a0,a5
	jrle	justshud

	move	@SKULLPROC,a7,L
	.if	DEBUG		       
	jrz	$
	.endif			      
	MOVIM	SK_BACK_TO_CTR,*a7(PWAKE),L

	move	A8,A7
	clr	a14
COLLSOFFLP
	move	a14,*A7(OCVECT),L
	move	*A7(OPARTS),A7,L
	jrnz	COLLSOFFLP

	calla	PULL_ANIM_ALL

	move	*a8(OPLINK),a14,L	; IBALL generator
	clr	a7
	move	a7,*a8(OPLINK),L	; remove process link

	move	@SKULL_RETREAT,a6
	jrz	remorph

	movi	WAIT_FOR_NO_IBALLS,a7
	move	a7,*a14(PWAKE),L	; wake up somewhere new

	movk	2,a7
	move	a7,*a14(PTIME)
*
*	SKULL RETREATS INTO CEILING
*
	movb	*a8(OPARTID),a6	    	; OPARTID of head in a6 (1=cap)
	move	a8,a0
lklp:
	movb	*a0(OPARTID),a5		; delete cap and puddle
	cmp	a6,a5			; animate mouth only
	jrne	getrid
	movi	SKULLSHRINK,a1
	calla	STRTANIM
	move	*a0(OPARTS),a0,L
	jrnz	lklp
	move	a9,a8
	rets
getrid:
	move	*a0(OPARTS),a3,L
	calla	PULLPART
	calla	DELOBJ
	move	a3,a0
	jrnz	lklp
	move	a9,a8
	rets

*
*	SKULL MORPHS INTO EYEBALLS
*
remorph:
	movi	200,a7	      		; don't WAIT_FOR_NO_IBALLS
	move	a7,*a14(PTIME)		; till after skull morphs
	movi	WAIT_FOR_NO_BIGIZ,a7
	move	a7,*a14(PWAKE),L	; wake up somewhere new

	movi	SKSPLIT,a1		; start morph animation
	calla	STRT_ANIM

	move	a9,a8
	rets
	

justshud:
	SOUND1	SND_SHUDDER

	CREATE	PID_IND,SKULL_GRUNT

	movi	SHUDDER,a1
	move	a1,*a8(AnimFrm),L
	move	a1,*a8(AnimScr),L
	movk	1,a1
	movb	a1,*a8(AnimSlp)
nocando
	move	a9,a8
	rets


SKULL_GRUNT:
	sleep	20
	movk	3,a0
	movi	SK_GRNT_TAB,a1
	callr	TAB_SOUND
	DIE


*	remove 2 of the 6 skull parts before continuing with 
*	SKSPLIT animation
*
SK_INTO_IBALLS:
	move	a8,a0			; head
molp:
	movb	*a0(OPARTID),a5		; delete puddle only (PARTID=2)
	cmpk	2,a5			
	jreq	getridA
	move	*a0(OPARTS),a0,L
	jrnz	molp
	rets
getridA:
	move	*a0(OPARTS),a3,L
	calla	PULLPART
	calla	DELOBJ
	move	a3,a0
	jrnz	molp
	rets


	

	.bss	sk_off_tab,8*20h		; new tab in ram

;	.long	25*SKUL2Z,-83*SKUL2Z		; old hard coded
;	.long	25*SKUL2Z,-17*SKUL2Z
;	.long	-25*SKUL2Z,-83*SKUL2Z
;	.long	-25*SKUL2Z,-17*SKUL2Z

BUILD_SKOFFTAB:
	move	*a8(OZVAL),a9,L
	move	@ZBASE,a14,L
	sub	a14,a9		; World Z

	movi	sk_off_tab,a14

	movk	25,a3
	mpys	a9,a3		
	move	a3,*a14,L
	move	a3,*a14(40h),L
	neg	a3
	move	a3,*a14(80h),L
	move	a3,*a14(0c0h),L

	movi	-83,a3
	mpys	a9,a3
	move	a3,*a14(20h),L
	move	a3,*a14(0a0h),L

	movi	-17,a3
	mpys	a9,a3
	move	a3,*a14(60h),L
	move	a3,*a14(0e0h),L
	rets

*
*	called from SKSPLIT anim sequence.
*
SKUL2EYZ_DONE:
	movk	5,a10
	move	a8,a2			; keep head in a2
	calla	PULL_ANIM		; head no longer animates
	callr	BUILD_SKOFFTAB
	movi	sk_off_tab,a9
	movi	[11ch,11ch],a3		; ninety percent shrink
	jruc	sk2iz2
sk2iz:
	calla	PULL_PART
sk2iz2:
	move	*a8(OFLAGS),a14
	ori	M_MANSCALE|M_NOSCALE,a14
	move	a14,*a8(OFLAGS)
	move	a3,*a8(OSCALE),L

	movi	GOOEYE1,a1
	move	*a8(OCTRL),a4
	calla	ANI

	move	*a8(OXVAL),a5,L		; offset in X
	move	*a9+,a6,L
	add	a6,a5
	move	a5,*a8(OXVAL),L

	move	*a8(OYVAL),a5,L		; offset in Y
	move	*a9+,a6,L
	add	a6,a5
	move	a5,*a8(OYVAL),L

	MOVIM	SKULL_GUNVECT,*a8(OGUNVECT),L	; take splooge hits
	MOVIM	IBALL_CVECT,*a8(OCVECT),L	; EXPLODE WHEN HIT

	CREATE	PID_DESK,MON_BIGEYE	; PID_DESK used for search
	move	a0,*a8(OPLINK),L
	addi	60,a10

	move	*a2(OPARTS),a8,L
	jrnz	sk2iz

sk2X:
	move	*a8(OPART1),a8,L	; clear head part
	clr	a14
	move	a14,*a8(OPART1),L
	move	a14,*a8(OPARTS),L

	move	@SCROLL_PROCESS,a4,L	; WAKE UP!!!
	MOVKM	8,*a4(PTIME),W

	rets


A_CLR_SCRLFLG_BIT:
	calla	GETAFARG_WORD
*
*	bit to clear in a0
*
CLR_SCRLFLG_BIT:
	move	@SCROLL_FLAG,a14
	andn	a0,a14
	move	a14,@SCROLL_FLAG		; signal scroller to move on
nodec:				       
	rets

MON_BIGEYE:
	SLEEPR	a10

	move	*a8(OXVAL),a9,L
	move	@XBASE,a14,L
	sub	a14,a9		; world X
	neg	a9
	sra	9,a9

	move	*a8(OYVAL),a10,L
	move	@YBASE,a14,L
	sub	a14,a10		; world Y
	neg	a10
	sra	9,a10
	move	a10,*a8(OYACCEL),W

	movi	ZMAX_KLUDGE+400h-SKUL2Z,a11
	sra	9,a11
	sleep	1

BIGEYE_lp:
	move	*a8(OXVEL),a0,L
	add	a9,a0
	move	a0,*a8(OXVEL),L

	move	*a8(OZVEL),a0,L
	add	a11,a0
	move	a0,*a8(OZVEL),L

	move	*a8(OZVAL),a0,L
	move	@ZBASE,a14,L
	sub	a14,a0

	move	*a8(OCVECT),a1,L
	jrz	bignoexplo
	cmpi	2e00h,a0
	jrle	explode_bigi
bignoexplo:
	CMANSCL	2e00h,SKUL2Z,050h,11ch
	sloop	1,BIGEYE_lp


explode_bigi:
	movi	2e00h,a0
	add	a0,a14
	move	a14,*a8(OZVAL),L
	movi	80h,a5
	calla	SET_SCALE_MANUAL

	clr	a1
	move	a1,*a8(OXVEL),L
	move	a1,*a8(OZVEL),L
	move	a1,*a8(OYVEL),L
	move	a1,*a8(OYACCEL),W

	clr	a14
	move	a14,*a8(OPLINK),L

	movi	BIGIEXPL,a1
	calla	STRT_ANIM
	DIE


BIGIEXPL:
	LWL	SPLAT3,1|AFunc,A_BIGI_EXPL

A_BIGI_EXPL:
	movi	[100h,100h],a0
	calla	IBALL_EXPLOSION		; decs NUM_IBALLS

	move	*a8(OYPOS),a5,W		; adjust SPLAT alignment
	subk	12,a5
	move	a5,*a8(OYPOS),W

;	movi	[4,1],a5
	MOVE	@BASE_HIT,A5,W
	ADDI	2800H,A5
	SLL	4,A5

	ALLPLYR	PLAYER_HIT

	move	*a8(OZVAL),a14,L
	subk	10,a14
	move	a14,*a8(OZVAL),L
	movi	2f2fh,a1
	calla	HIT_SCREEN

	movi	SND_BIGI_EXPL,a0
	calla	ONESND

	DECM	@NUMIBALLS,W

	rets

*
*	SKULL HIT BY BULLET causes SPLOOGE
*
SKULL_GUNVECT:
	SOUND1	SND_SLIME_HIT

	move	@SKULL_HITS,a3
	inc	a3
	move	a3,@SKULL_HITS

	movi	SPOOGE_INIT,b0
	calla	EASYMAKE	; spooge obj in a0
	move	*a2(PCURSORXY),a7,L
	move	a7,a5
	sext	a5   		; screen X in a5
	move	@ZBASE,a14,L
	move	*a8(OZVAL),a6,L
	subk	4,a6
	move	a6,*a0(OZVAL),L
	sub	a14,a6		; world Z
	subi	HALFX,a5
	mpys	a6,a5
	move	@XBASE,a14,L
	add	a14,a5
	move	a5,*a0(OXVAL),L	; store univ X

	MOVE	@YHALF,A14,W
	sra	16,a7		; screen Y in a7
	sub	a14,a7
	mpys	a6,a7
	move	@YBASE,a14,L
	sub	a14,a7
	move	a7,*a0(OYVAL),L	; store universe Y

	calla   INSOBJ
	move	*a8(OYVAL),a9,L
	sub	a7,a9
	move	*a8(OXVAL),a10,L
	sub	a5,a10
	move	a0,a11
	CREATE	PID_IND,STICK_XY
	move	a0,*a11(OPLINK),L
	rets
	

STICK_XY:
*
*	a8 = target object (obj to stick to)
*	a9 = Y delta
*	a10 = X delta
*	a11 = obj to stick
*	
	move	*a8(OXVAL),a0,L
	sub	a10,a0
	move	a0,*a11(OXVAL),L

	move	*a8(OYVAL),a1,L
	sub	a9,a1
	move	a1,*a11(OYVAL),L
	sloop	1,STICK_XY



SPOOGE_INIT:
	.long	SPOOGE7
	.word	DMAWNZ, 0, OM_ANIM
	.long	Spooge
	

Spooge:
	LW	SPOOGE7,2
	LW	SPOOGE5,2
	LW	SPOOGE3,2
	LW	SPOOGE1,2
	LW	SPOOGE2,2
	LW	SPOOGE1,2
	LW	SPOOGE3,2
	LW	SPOOGE4,2
	LW	SPOOGE5,2
	LW	SPOOGE6,2
	LW	SPOOGE7,2
;	LW	SPOOGE8,1		too small
	LWL	1,1|AFunc,DELETE_OBJ_PROC


SHUDDER:
        LWLW	1,1|AFunc,A_Set_AnimLoop+1,3
ShudLp:
	LW	SHUD1CAP,1|AMulti
	LW	SHUD1PUD,1|AMulti
	LW	SHUD1CAP,1|AMulti
	LW	SHUD1PUD,1|AMulti
	LW	SHUD1MTH,3|AMulti
	LW	SHUD1MTH,3

	LW	SHUD2CAP,1|AMulti
	LW	SHUD2PUD,1|AMulti
	LW	SHUD2CAP,1|AMulti
	LW	SHUD2PUD,1|AMulti
	LW	SHUD2MTH,1|AMulti
	LW	SHUD2MTH,2

	LWLL	1,1|AFunc,A_Anim_DSJ+2,ShudLp

	LWLL	SKULLCAP,1|AMulti|AFunc,A_AnimGo+2,SKLAFF
	LW	PUDDLEBOT,1|AMulti
	LW	SKULLCAP,1|AMulti
	LW	PUDDLEBOT,1|AMulti
	LW	MOUTHOPEN,1|AMulti
	LW	MOUTHOPEN,1




ADD_SKULL_PARTS:
	movk	3,a14
	movb	a14,*a8(OPARTID)	; set mouth to ID 3
	movi	SKULL_CVECT,a14
	move	a14,*a8(OCVECT),L
	movi	SKULPRTS_INIT,b0	
	PUSH	a8
	calla	MULTIMAKE
	PULLQ	a0
	move	*a8(OPARTS),a1,L
	move	*a0(OXVAL),a14,L
	move	a14,*a8(OXVAL),L
	move	a14,*a1(OXVAL),L
	move	*a0(OYVAL),a14,L
	move	a14,*a8(OYVAL),L
	move	a14,*a1(OYVAL),L
	move	*a0(OZVAL),a14,L
	move	a14,*a8(OZVAL),L
	move	a14,*a1(OZVAL),L

	move	*a0(OCTRL),a3
	andi	M_FLIPH,a3	; isolate FLIP bit
	move	*a8(OCTRL),a14
	or	a3,a14
	move	a14,*a8(OCTRL)
	move	*a1(OCTRL),a14
	or	a3,a14
	move	a14,*a1(OCTRL)

	calla	INSERT_OBJ

	calla	INSPART

	move	a8,a0
	calla	CNTMPART	; how many parts
	cmpk	6,a1		; not all yet, return
	jrne	notdun

	move	@SKULL_RETREAT,a14	; proceed only if you have come
	jrz	skrise			; down from skylite

	movi	-83,a9
	movi	20,a10
	movi	-23,a11
	CREATE	PID_IND,GENERATE_IBALLS
	move	*a8(OPART1),a8,L
	move	a0,*a8(OPLINK),L	; link iball proc w/skull

	CREATE	PID_IND,KEEP_SKULL_MOVING
	move	a0,@SKULLPROC,L

	calla	PULL_ANIM_ALL

	SOUND1	SND_SKLAFF1

	movi	SKLAFF,a1
	calla	STRT_ANIM
notdun:
	rets

skrise:
	calla	PULL_ANIM_ALL

	movi	SKULL_RISE,a1
	calla	STRT_ANIM
	rets


START_SKULL:
	movi	-83,a9
	movi	20,a10
	movi	-23,a11
	CREATE	PID_IND,GENERATE_IBALLS
	move	a0,*a8(OPLINK),L	; link iball proc w/skull

	CREATE	PID_IND,KEEP_SKULL_MOVING
	move	a0,@SKULLPROC,L
	move	a0,a6			; save a minute

	CREATE	PID_IND,KEEP_SKULL_BOBBING
	move	a0,*a6(PDATA+20h),L	; save this 

	SOUND1	SND_SKLAFF1

	movi	SKLAFF,a1
	move	a1,*a8(AnimScr),L
	move	a1,*a8(AnimFrm),L
	rets

*
*	While skull is around, move him in X
*
KEEP_SKULL_MOVING:
	clr	a1
	movi	400000h,a0 	; world X target range in a0,a1
	movi	0e00h,a9		; X accel
	move	*a8(OXVAL),a2,L
	move	@XBASE,a4,L 
	sub	a4,a2	    	; current world X
	jrn	left_side
	neg	a0
	SWAP	a0,a1
	neg	a9
left_side:
	calla	RANGRAND	; random world X
	add	a4,a0		; target univ X
	move	a0,a10		; 

	move	a9,*a8(OXVEL),L
skmvlp:
	move	*a8(OXVAL),a0,L
	move	*a8(OXVEL),a1,L
	add	a9,a1
	move	a1,*a8(OXVEL),L
	jrn	chklft

	cmp	a10,a0
	jrgt	hittarg
nitenite:
	sloop	1,skmvlp

chklft:
	cmp	a10,a0
	jrge	nitenite
hittarg:
	movi	SND_SKLAFF1,a1
	calla	RANDOM
	btst	13,a0
	jrz	randlaff
	movi	SND_SKLAFF2,a1
randlaff:
	move	a1,a0
	calla	ONESND
	

	CLRM	*a8(OXVEL),L
	sloop	3,KEEP_SKULL_MOVING


	
*
*	While skull is in pool, move him in Y
*
KEEP_SKULL_BOBBING:
	movi	1e00h,a0 	; Y accel range in a0,a1
	move	a0,*a8(OYACCEL)
KSB1
	move	*a8(ODAGY),a0
	cmpi	170,a0
	jrgt	ComeBackUp
	sloop	3,KSB1
ComeBackUp:
	CLRM	*a8(OYACCEL),W

	movi	-10000h,a0
	movi	-40000h,a1
	calla	RANGRAND
	move	a0,*a8(OYVEL),L
KSB2:
	move	*a8(ODAGY),a0
	cmpi	90,a0
	jrlt	KEEP_SKULL_BOBBING
	sloop	3,KSB2



*
*	The process in SKULLPROC is normally KEEP_SKULL_MOVING
*	but when the skull dies, it wakes up here.
*
SK_BACK_TO_CTR:
	clr	a10
	move	@SKULL_RETREAT,a14	; if morphing, get to a nice Y
	jrnz	just_do_x
	move	*a13(PDATA+20h),a0,L	; BOUNCE process
	calla	KILL
	move	*a8(OYVAL),a3,L
	move	@YWORLD,a4,L
	sra	1,a4			; dest Y is YWORLD/2
	sub	a3,a4
	sra	4,a4
	move	a4,*a8(OYVEL),L
	move	a10,*a8(OYACCEL),W
just_do_x:
	move	*a8(OXVAL),a2,L
	move	@XBASE,a4,L
	sub	a4,a2		; world X
	neg	a2
	sra	2,a2
	move	a2,*a8(OXVEL),L
	sleep	5
	move	a10,@SKULLPROC,L
	move	a10,*a8(OXVEL),L
	sleep	10
	move	a10,*a8(OYVEL),L
	DIE




*
*	a8 = skull obj blk
*	a9 = y pixel offset of iballs
*	a10 = x pixel offset of iballs right
*	a11 = x pixel offset of iballs left
*
*	a9 becomes univ Y of iballs
*	a10 becomes univ Z of iballs
*	a11 becomes  univ X offset left (Shifted 4) : univ X offset right (shifted 4)
*
GENERATE_IBALLS
*
*	compute offsets at current Z
*
	movi	[160,40],a4 		; sleep parameters to start
	PUSHP	a4
	sleep	20
	move	a10,a5			; save X pixel offset
	move	*a8(OZVAL),a10,L	; univ Z in a3
	subk	3,a10
	move	@ZBASE,a4,L
	sub	a10,a4
	neg	a4			; world Z in a4
	mpys	a4,a5
	mpys	a4,a9
	mpys	a4,a11
	sll	4,a11
	sra	12,a5
	movx	a5,a11			; regs all set up
*
genIlp:
	move	*a8(OYPOS),a14
	cmpi	40h,a14
	jrlt	GIok
	cmpi	58h,a14
	jrge	GInotok
	move	*a8(OYVEL),a14,L
	jrn	GIok
GInotok:
     	sloop	3,genIlp
GIok:

	movk	2,a7
genIlp2:
	PUSHP	a7

	movi	IBALL_INIT,b0
	calla	EASYMAKE
	jrz	GENIBX

	clr	a14
	move	a14,*a0(OHITS)		; hit count
	move	a14,*a0(GndHitFlg)
	move	a14,*a0(LastHt)
	.if	DEBUG
	MOVIM	0DEADBEEFh,*a0(SavYVEL),L
	MOVIM	0BADF00Dh,*a0(SavZVEL),L
	.endif

	move	*a8(OYVAL),a5,L
	add	a9,a5
	move	*a8(OXVAL),a2,L
	clr	a3
	movy	a11,a3
	sra	4,a3
	rl	16,a11
	add	a2,a3
	move	a3,*a0(OXVAL),L
	move	a5,*a0(OYVAL),L
	move	a10,*a0(OZVAL),L
	calla	INSOBJ
	calla	INSPART			; make part of skull
	MOVKB	2,*a0(OPARTID)		; so it will go bye bye when
					; the skull turns into big i'z
GENIBX:
	movk	30,a0		; delay of up to 30 tiks between generated
	calla	RAND0		; pair
	move	a0,a0
	jrz	skpslp
	calla	PRCSLP
skpslp:
	PULLP	a7
	dsj	a7,genIlp2

	SOUND1	SND_IBALL_ST

	move	*a12,a4,L	; sleep parameters
	jrz	bother0
	clr	a1		; smaller (low) in a1
	movx	a4,a1
	movy	a4,a0		; larger (high) in a0
	srl	16,a0
	addxyi	[-8,-2],a4	; reduce for next time
	jrxnn	GENxok		; but if they turn neg, zero them
	srl	16,a4
	sll	16,a4		; clear if neg
GENxok:
	move	a4,*a12,L	; resave without repushing
	move	a4,a4
	jrz	bother0
	jrnn	GENyok
	zext	a4
	move	a4,*a12,L	; oops I was hasty before
GENyok:

	move	@CURPLYRS,a14
gIslp2:
	dec	a14
;	jrz	CABok2
	JRLE	CABok2
	subk	10,a1
	subk	30,a0
	jruc	gIslp2
CABok2:
	calla	RANGRAND	; sleep time for next two eyes
	move	@SKULL_RETREAT,a14
	jrnz	usea0
      	sra	1,a0		; cut time in half for end
	inc	a0
usea0:
	cmpi	500,a0
	jrgt	bother0
	cmpk	14,a0
	jrgt	SLPok
bother0:
	movk	14,a0
SLPok:
	movi	genIlp,a7
	jauc	PRCLSP


WAIT_FOR_NO_BIGIZ:
	move	@ACTIVE,a0,L
W4NBlp:
	move	*a0(PROCID),a14
	cmpi	PID_DESK,a14
	jreq	notgone		; jump if any left
	move	*a0(PLINK),a0,L
	jrnz	W4NBlp
*
*	if we scan through entire list and none found,
*	then eyeballs are all taken care of.
*
	jruc	IBtimeout	

notgone:
	sloop	4,WAIT_FOR_NO_BIGIZ


WAIT_FOR_NO_IBALLS:
	movi	60*6,a9		; timeout 6 secs after SKULL goes away
W4NOIBlp:
	sleep	20

	move	@SCROLL_FLAG,a14
	btst	0,a14
	jrnz	chkcnt
	subk	20,a9			; start decrementing time
	jrle	IBtimeout
chkcnt:
	move	@NUMIBALLS,a0
	jrgt	W4NOIBlp
	sleep	60		; allow explosion to finish

*
*	When skull is retreating, clr bit in SCROLL_FLAG to signal scroller
*
IBtimeout:
	movk	2,a0		; mask of bit to clear
	callr	CLR_SCRLFLG_BIT
awl_dun:
	DIE





IBALL_INIT
	.long	LILEYE1
	.word	DMAWNZ,M_GCOLL|M_NOSCALE|M_NOPARTANI,OM_ANIM|OM_OID
	.word	OID_EROCKET
	.long	IBALL


IBALL_CVECT:
	WWL	OID_PROCKET,~MASK_PLAYER,UNIV_ROCKET_COLL
	WWL	OID_PEXPLOSION,~MASK_PLAYER,IBALL_COLL
	WWL	OID_GRND,0FFFFH,IBALL_GROUND_COLL
	WL	0,DUMCRETS


IBALL:
	LW	LILEYE1,2
	LW	LILEYE2,2
	LW	LILEYE3,2
	LW	LILEYE4,2
	LW	LILEYE5,2
	LW	LILEYE6,2
	LW	LILEYE7,2
	LW	LILEYE8,2
	LW	LILEYE9,2
	LW	LILEYE10,2
	LW	LILEYE11,8
	LWL	1,1|AFunc,A_SWITCHEYE
BOUNCEEYE:
	LW	GOOEYE4,3
	LW	GOOEYE1,3
	LW	GOOEYE4,3
	LW	GOOEYE5,3
	LW	GOOEYE6,1
	LWL	1,1|AFunc,A_WAIT_FOR_GNDHIT
	LWLLW	GOOEYE7,2|AFunc,A_TAB_SOUNDZ+3,IBNCSND,3
	LW	GOOEYE8,6
	LWL	GOOEYE5,2|AFunc,A_RESTORE_YVEL
	LW	GOOEYE4,3
	LWL	GOOEYE1,3|AFunc,A_CLR_GNDHIT
	LW	GOOEYE4,3
	LW	GOOEYE2,3
	LW	GOOEYE3,1
	LWL	1,1|AFunc,A_WAIT_FOR_VELCHG
	LW	GOOEYE2,3
	LW	GOOEYE1,3
	.long	0

IBNCSND
	.long	IBNC_S1,IBNC_S2,IBNC_S3

IBNC_S1	.word	0f342h,26,0a19ah,0
IBNC_S2	.word	0f342h,24,0a19dh,0
IBNC_S3	.word	0f342h,19,0a1a0h,0

IHITSND
	.long	IHIT_S1,IHIT_S2,IHIT_S3

IHIT_S1	.word	0f343h,26,0a49eh,0
IHIT_S2	.word	0f343h,32,0a4a1h,0
IHIT_S3	.word	0f343h,15,0a4a4h,0




A_SWITCHEYE:
	calla	PULL_PART		; remove from skull

	move	@NUMIBALLS,a14		; keep track
	inc	a14			; when they are not part of skull,
	move	a14,@NUMIBALLS		; count them

	movi	GOOEYE1,a1		; Change image
	move	*a8(OCTRL),a4
	calla	ANI

	move	*a8(OFLAGS),a14		; change to manual scaling
	ori	M_MANSCALE|M_OFSCRN,a14
	move	a14,*a8(OFLAGS)

	clr	a9			; force new scale detection
	callr	COMP_IBALL_SCL

	CREATE	PID_IND,IBALL_ADJ_SCL	; start monitor process
	move	a0,*a8(OPLINK),L

	CLRM	*a8(OXVEL),L

;	movi	0c000h,a14
;	move	a14,*a8(OYVEL),L

	movi	BOUNCEEYE,a14		; Change to bounce anim
	move	a14,*a8(AnimFrm),L
	move	a14,*a8(AnimScr),L

	movi	IBALL_CVECT,a14
	move	a14,*a8(OCVECT),L
	movi	IBALL_GUNVECT,a14
	move	a14,*a8(OGUNVECT),L

	movi	3300h,a14
	move	a14,*a8(OYACCEL)

	movi	-200h,a14		; Give a Z vel (was -120h)
	move	a14,*a8(OZVEL),L

	move	@SKULL_RETREAT,a14
	jrz	no_ib_shad		; no shadow for iballs in pool

	movi	3000h,a14
	move	a14,*a8(OYACCEL)

	movi	-0ceh,a14		; Give a Z vel (was -120h)
	move	a14,*a8(OZVEL),L

	calla	GET_SHAD
	jrz	no_ib_shad
	calla	INSOBJ
no_ib_shad:
	rets


A_WAIT_FOR_GNDHIT:
	move	*a8(GndHitFlg),a0	; flag says ground hit, continue
	jrnz	didhit
didntchg:
	move	*a8(AnimFrm),a1,L	; no hit, back up script
	subi	50h,a1
	move	a1,*a8(AnimFrm),L
	rets

didhit:
	move	*a8(OYVEL),a14,L
	LOCKON	NZ
	move	*a8(SavYVEL),a0,L
	LOCKON	Z
	rets

A_RESTORE_YVEL:
	move	*a8(SavYVEL),a1,L	; restore YVEL
	move	*a8(LastHt),a0		; YPOS of last apex
	sll	9,a0
	move	@SKULL_RETREAT,a14
	jrnz	no_yv_adj    
	sll	2,a0	     		; addl YVEL adjust if pool
no_yv_adj:
	add	a0,a1			; adjust YVEL
	neg	a1
	move	a1,*a8(OYVEL),L
	movi	3000h,a14		; keep off ground
	move	a14,*a8(OYACCEL)
	movi	040h,a0
	calla	RAND0
	subi	20h,a0		; world X target
	move	*a8(OXVAL),a1,L
	move	@XBASE,a14,L	; 
	sub	a14,a1		; current world X
	sll	16,a0		
	sub	a1,a0		; delta X to travel
	sra	7,a0		
	move	a0,*a8(OXVEL),L
	rets


A_CLR_GNDHIT:
	clr	a0
	move	a0,*a8(GndHitFlg)	; clear ground hit flag
	move	*a8(OFLAGS),a14
	ori	M_GCOLL,a14
	move	a14,*a8(OFLAGS)		; reenable ground colls
	move	*a8(SavZVEL),*a8(OZVEL),L	; restore ZVEL
	rets


A_WAIT_FOR_VELCHG:
	move	*a8(OYVEL),a0,L
	jrle	didntchg
*
*	heading down, now save height
*
	move	*a8(OYPOS),a14
	move	a14,*a8(LastHt)		; save position for recomputing YVEL
	rets


COMP_IBALL_SCL:
	move	*a8(OZVAL),a5,L
	move	@ZBASE,a14,L
	sub	a14,a5	      	; WORLD Z
COMP_IBALL_SCL2:
	move	@SKULL_RETREAT,a14
	jrnz	rscale

	subi	SKUL2Z-((SKUL2Z-3200h)*294h)/(294h-0a0h),a5
	movi	((294h-0a0h)*65536)/(SKUL2Z-3200h),a0
	jruc	CIShk

rscale:
	subi	SKUL1Z-((SKUL1Z-3200h)*294h)/(294h-0a0h),a5
	movi	((294h-0a0h)*65536)/(SKUL1Z-3200h),a0

CIShk:
	mpys	a0,a5
	sra	16,a5
	cmp	a5,a9
	jreq	inotnew
	move	a5,a9
	jauc	SET_SCALE_MANUAL
inotnew:
	rets


;	srl	Z2SCALE,a5   	; assume normal size image
;	movi	1c0h,a1
;	mpys	a1,a5		; adjust scale by constant factor
;	srl	8,a5		; readjust fraction

*	a8 = obj
*	a9 = last scale set
*
IBALL_ADJ_SCL:
	move	*a8(OZVAL),a5,L
	move	@ZBASE,a14,L
	sub	a14,a5	      	; WORLD Z

	move	*a8(OPART1),a1,L
	jrz	nadamulti
	move	a1,a8
nadamulti:
	move	*a8(OCVECT),a1,L
	jrz	cantexplo
	cmpi	3800h,a5
	jrge	cantexplo
*
*	iball is close enough, is it on screen?
*
	cmpi	2d00h,a5     	; too close, must explode him
	jrle	explode_iball
	move	*a8(ODAG),a14,L
	move	*a8(OSIZE),a0,L
	srl	1,a0
	andi	0fff0fffh,a0
	add	a0,a14		; get center of iball
	movi	[SKYTOPOF,CENTER_XSHIFT],b5
	movi	[SCREEN_HEIGHT,SCREEN_WIDTH+CENTER_XSHIFT],b6
	cpw	a14,a14
	jrnv	explode_iball

cantexplo:
	callr	COMP_IBALL_SCL2
	sloop	2,IBALL_ADJ_SCL


explode_iball:
	clr	a1
	move	a1,*a8(OXVEL),L
	move	a1,*a8(OZVEL),L
	move	a1,*a8(OYVEL),L

	clr	a14
	move	a14,*a8(OPLINK),L

	move	*a8(OFLAGS),a14		; don't allow a ground coll
	andni	M_GCOLL,a14
	move	a14,*a8(OFLAGS)		; disable ground colls

	move	@NUMIBALLS,a14		; keep track
	dec	a14
	move	a14,@NUMIBALLS

	movi	IBALLEXPL,a1
	move	a1,*a8(AnimScr),L
	move	a1,*a8(AnimFrm),L
	DIE


IBALL_EXPLOSION:
	calla	MAKE_EXPLOSION	  
	move	a8,a7
	move	a0,a8
	movi	REXPLO,a0
	calla	CHANGE_PAL
	move	*a8(OYPOS),a14
	subk	10,a14	
	move	a14,*a8(OYPOS)
	move	*a8(OPARTS),a8,L
	move	*a8(OYPOS),a14
	subk	10,a14	
	move	a14,*a8(OYPOS)
	movi	REXPLO,a0
	calla	CHANGE_PAL
	move	a7,a8
	rets


IBALLEXPL:
	LWLLW	GOOEYE4,2|AFunc,A_TAB_SOUNDZ+3,IHITSND,3
	LW	GOOEYE1,2
	LW	GOOEYE4,2
	LW	GOOEYE1,2
	LWL	SPLAT3,1|AFunc,A_IBALL_EXPL


A_IBALL_EXPL:
*
*	check for player hit and enery drain
*
	move	*a8(OYVAL),a14,L	; align splat image
	subi	27<<15,a14
	move	a14,*a8(OYVAL),L

	clr	a3
;	movi	[8,0],a5
	MOVE	@BASE_HIT,A5,W
	ADDI	6800H,A5
	SLL	4,A5

	calla	CK_PLAYER_HIT

	CLRM	*a8(OXVEL),L
	move	a14,*a8(OYVEL),L
	move	a14,*a8(OYACCEL)

	move	*a8(OZVAL),a14,L
	subk	30,a14
	move	a14,*a8(OZVAL),L
	movi	2f2fh,a1
	calla	HIT_SCREEN

	movi	SND_IBALL_EXPL1,a0
	move	@RAND,a14
	btst	11,a14
	jrz	duhh
	movi	SND_IBALL_EXPL2,a0
duhh:
	calla	ONESND

	rets



IBALL_GROUND_COLL:
	move	*a8(GndHitFlg),a1
	jrnz	ignthis
	move	*a8(OYVEL),a14,L
	LOCKON	Z
	cmpi	15000h,a14		; minimum acceptable
	jrgt	IGCok
      	movi	44000h,a14
IGCok:
	move	a14,*a8(SavYVEL),L
	move	*a8(OZVEL),*a8(SavZVEL),L
	clr	a1
	move	a1,*a8(OYVEL),L
	move	a1,*a8(OZVEL),L
	move	a1,*a8(OYACCEL)			; stick it
	movk	1,a1
	move	a1,*a8(GndHitFlg)		; set ground hit flag
	move	*a8(OFLAGS),a14
	andni	M_GCOLL,a14
	move	a14,*a8(OFLAGS)		; disable ground colls
ignthis:
	rets


	


IBALL_COLL:
	CALLA	UNIV_COLL_CHECK
	jrnz	nocollyet
	MOVE	*A0(OID),A0,W			;GET PLAYER DATA ADDRESS
	CALLA	POID_TO_PDATA			;GET PDATA IN A2
	jruc	IBALL_HIT_HOOK

IBALL_GUNVECT:
	move	*a8(OHITS),a0
	inc	a0
	move	a0,*a8(OHITS)
	cmpk	2,a0
	jrlt	nocollyet

IBALL_HIT_HOOK:
	mmtm	sp,b0,b1,b2,b3,b4,b5,b6,b7,b8,b9,b10
	
*
* PASS:									 
* A2 = PTR TO PLAYER						         
* A8 = PTR TO OBJECT							 
*
	PUSH	a0
	move	a8,a0
	calla	DELSHAD
	PULLQ	a0

	clr	a14
;	move	a14,*a8(OXVEL),L
	move	a14,*a8(OYVEL),L
;	move	a14,*a8(OZVEL),L
	move	a14,*a8(OYACCEL)

	movi	ISPLAT,a1
	move	*a8(OFLAGS),a14
	andni	M_GCOLL,a14
	move	a14,*a8(OFLAGS)		; disable ground colls
	btst	B_ANIM,a14
	jrnz	normball
	calla	STRT_ANIM		; big iball is not animating.
	jruc	IHH
normball:
	move	a1,*a8(AnimScr),L
	move	a1,*a8(AnimFrm),L
IHH:
	movi	1000,a1
	calla	SCORE

;	move	*a8(OPLINK),a0,L
;	jrz	gskpkill
;	clr	a14
;	move	a14,*a8(OPLINK),L
;	calla	KILL
;gskpkill:

	SOUNDZ	SND_IBALL_POP

	DECM	@NUMIBALLS,W

;	calla	ALL_COLLS_OFF
	clr	a14
	move	a14,*a8(OCVECT),L	; disable further colls
	move	a14,*a8(OGUNVECT),L	; disable further colls
	mmfm	sp,b0,b1,b2,b3,b4,b5,b6,b7,b8,b9,b10
nocollyet:
	rets



ADD_ISPLAT_PARTS:
	calla	PULL_ANIM

	movi	NSPARTS1,a1
	move	*a8(OCTRL),a4
	calla	ANI

	movi	ISPLAT_INIT,b0
	PUSH	a8
	calla	MULTIMAKE	; orig in a0, new multi in a8
	PULLQ	a0
	move	*a0(OXVAL),a14,L
	move	*a0(OYVAL),a6,L
	move	*a0(OZVAL),a4,L
	move	*a0(OSCALE),a5,L
	move	a8,a7
add_ip_lp:
	move	*a7(OPARTSXY),a3
	sll	15,a3
	add	a14,a3
	move	a3,*a7(OXVAL),L
	move	*a7(OPARTSXY+10h),a3
	sll	15,a3
	add	a6,a3
	move	a3,*a7(OYVAL),L
	move	a4,*a7(OZVAL),L
	move	a5,*a0(OSCALE),L

	move	*a7(OPARTS),a7,L
	jrnz	add_ip_lp

	move	*a0(OPLINK),*a8(OPLINK),L
	CLRM	*a0(OPLINK),L
	calla	INSERT_OBJ
	calla	INSPART

	zext	a5
	move	*a0(OIHOFF),a14
	jrz	hokay
hlp:
	sll	1,a5
	subi	IHDRSIZ,a14
	jrnz	hlp
hokay:
	calla	SET_SCALE_MANUAL

	movi	ISPLAT_FINIS,a1
	calla	STRT_ANIM


    	rets



ISPLAT:
;        LWLW	1,1|AFunc,A_Set_AnimLoop+1,2
;spltlp:
	LW	SPLAT2,2
	LW	SPLAT3,2
;	LWLL	1,1|AFunc,A_Anim_DSJ+2,spltlp
	LW	SPLAT4,2
	LW	SPLAT5,2
	LWL	1,1|AFunc,ADD_ISPLAT_PARTS

ISPLAT_FINIS:
	LW     SPLAA1,1|AMulti
	LW     SPLEE1,1|AMulti
	LW     SPLOO1,2

	LW     SPLAA2,1|AMulti
	LW     SPLEE2,1|AMulti
	LW     SPLOO2,2

	LW     SPLAA3,1|AMulti
	LW     SPLEE3,1|AMulti
	LWL    SPLOO3,2|AFunc,DEL_PARTS_TO_END

	LW     SPLAA4,1|AMulti
	LW     SPLEE4,1|AMulti
	LW     SPLOO4,2

	LW     SPLAA5,1|AMulti
	LW     SPLEE5,1|AMulti
	LW     SPLOO5,2

	LW     SPLAA6,1|AMulti
	LW     SPLEE6,1|AMulti
	LW     SPLOO6,2

	LW     SPLAA7,1|AMulti
	LW     SPLEE7,1|AMulti
	LW     SPLOO7,2

	LWL   SPLAA8,2|AFunc,DEL_PARTS_TO_END

	LW     SPLAA9,2

	LWL	1,1|AFunc,DELETE_OBJ_PROC


ISPLAT_INIT:
	.byte	4,0,0,1
	.long	P_EYEB
	.word	OID_JUNK,0
	LWWWW	SPLAA1, DMAWNZ, M_MANSCALE, 0, OM_OPARTS
	.word	-64*90/100,60*90/100
	LWWWW	SPLEE1, DMAWNZ, M_MANSCALE, 0, OM_OPARTS
	.word	45*90/100,-42*90/100
	LWWWW	SPLOO1, DMAWNZ, M_MANSCALE, 0, OM_OPARTS
	.word	-52*90/100,-66*90/100
	LWWWW	NSPARTS2, DMAWNZ, M_MANSCALE, 0, 0



DEL_PARTS_TO_END:
	move	*a8(OPARTS),a8,L
	jrz	DLPX
DLPlp:
	move	*a8(OPARTS),a5,L
	calla	DELETE_OBJ
	move	a5,a8
	jrnz	DLPlp

DLPX:
	rets

****************************************************************
*
*	ELEVATOR ROUTINES
*
****************************************************************


UPGREEN	.word	2a0h,0

S_SET_ELEVATOR:
	movi	ELEVTABLE,a0
	move	*a11+,*a0+,L	; scroll table for first floor
	move	*a11+,*a0+,L	; scroll table for second floor
	move	*a11+,*a0+,L	; scroll table for third floor

	movk	30,a8		; when to set SCROLLKILL
	movk	1,a9		; what to set it to.
	CREATE	PID_IND,SCROLLKILL_DELAY	; to kill float zfar proc

	CLRM	@NUM_PILLARS,W	; use as number of floors visited

	jauc	SCRL_DISPATCHER


*
*	This process sets SCROLLKILL after a delay
*	a8 = delay in ticks
*	a9 = value to set SCROLLKILL to
*
SCROLLKILL_DELAY:
	SLEEPR	a8
	move	a9,@SCROLLKILL,W
	DIE



ELEVBUT_GUNVECT
	move	@ZSCROLL,a14,L
	jrnz	onitsway

	move	@PORTAL_LOCKOUT,a3	; can't use elev if locked out
	jrnz	onitsway

	SOUND1	SND_FLR_SEL

	move	a2,a5
	movi	UPGREEN,a0
	move	*a8(OPAL),a1
	sll	8,a1
	zext	a1
	addk	24,a1		; color # 24 is the up arrow
	movk	1,a2		; 1 color
	calla	PALSET

	callr	SET_EFLR_COLOR	; Mark current floor
	move	a5,a2

	clr	a14			; Disable collisions
	move	a14,*a8(OGUNVECT),L

*
*	Interrupt current Scroller, but save
*
	move	@SCROLL_PROCESS,a14,L
	move	*a14(LAST_SP),a6,L

	movk	3,a0
	move	a0,*a14(PTIME)		; wake up in three ticks
	move	*a14(PA11),a0,L
	move	a0,*-a6,L		; push old scroll onto stack
	move	a6,*a14(PSPTR),L	; save new stack pointer
	move	a6,*a14(LAST_SP),L	; update stack ptr  
	movi	ELEVATOR_RIDE,a7	; Scroll table for elevator
	move	a7,*a14(PA11),L		; save new scroll table
	movi	SCRL_DISPATCHER,a0
	move	a0,*a14(PWAKE),L
	move	*a14(PUSHCNT),a3
	inc 	a3			; increment push counter
	move	a3,*a14(PUSHCNT)       	; to indicate CALL
onitsway:
	rets

S_UNGREEN:
	clr	a0
	movb	a0,@ELEV_MOVING	; signal it's stopped

	movi	P_EBUTS,a0
	calla	FINDPAL
	jrz	nogreen
	move	a0,a1
	sll	8,a1
	zext	a1
	addk	24,a1
	movi	UPGREEN+16,a0
	movk	1,a2		; 1 color
	calla	PALSET
	subk	8,a1		; from 24 to 16
	calla	PALSET
nogreen:
	jauc	SCRL_DISPATCHER


SND_FLR_SEL	.word	0f3d8h,12,081cbh,0
SND_ELEV_MOTR	.word	0f3c8h,380,081c9h,0


EFLR_SEL_GUNVECT:
	move	@NUM_PILLARS,a14	; been to 2 floors already
	cmpk	2,a14
	jrge	cant_select

	movb	@ELEV_MOVING,a14     	; pos if moving up, neg if down
	jrnz	cant_select

	move	@ZSCROLL,a14,L
	jrnz	cant_select

	move	@ZBASE_HR,@ELEV_Z,L	;save ZBASE of elevator interior

	move	*a8(ODAGY),a4		; top
	move	*a8(OSIZEY),a3
	movk	3,a1
	divu	a1,a3			; 1/3 size in a3

	move	*a2(PCURSORXY+10h),a1	; scrn Y of hit in a1

	movk	1,a6			; floor button hit
	add	a3,a4
	cmp	a4,a1
	jrlt	hit_3

	add	a3,a4
	cmp	a4,a1
	jrlt	hit_2

	jruc	hit_1

hit_3:	inc	a6
hit_2:	inc	a6
hit_1:
	movb	@EFLOOR,a5		; floor you're on
	movk	1,a4			; 1 for going up
	cmp	a6,a5
	jreq	cant_select		; cant select same floor  
	jrlt	going_up
	subk	2,a4			; -1 for going down
going_up:
	movb	a4,@ELEV_MOVING		;tell world we are moving

	move	a5,a7		; current floor
	dec	a7
	sll	4,a7
	addi	LevColTab,a7	; get start color
	move	*a7,a7		; start color in a7
*
*	Light the floor we selected
*
	move	*a8(OPAL),a0
	sll	8,a0
	zext	a0   
	move	a0,a1 

	move	a6,a0		; selected floor
	dec	a0
	sll	4,a0
	addi	SelColTab,a0	; get start color
	move	*a0,a0
	add	a0,a1

	move	a2,a3
	movi	FlrSelCol,a0
	movk	1,a2		; change one color
	calla	PALSET
	move	a3,a2

	SOUND1	SND_FLR_SEL

	move	@SCROLL_PROCESS,a14,L
	movi	PWAKE+20h,a3
	add	a14,a3
	sll	16,a5		; current floor up in high
	movx	a6,a5		; target in low
	movi	ELEVATOR_MOVE,a0
	mmtm	a3,a0,a4,a5,a7
	movk	15,a0			; give time for ding
	move	a0,*a14(PTIME)

	MOVKM	0,@PLYR_SEEN,W	; RESET VIDCAM

	INCM	@NUM_PILLARS,W	; another floor visited

cant_select:
	rets

*
*	Force us to choose 1st floor upon reentering elevator
*
S_SEND_ELEV_DOWN:
	clr	a8
	dec	a8
	movb	a8,@ELEV_MOVING	; going down

	movb	@EFLOOR,a10
	dec	a10
	sll	4,a10
	addi	LevColTab,a10	; get start color
	move	*a10,a10		; start color in a7

	movi	P_ELEVBUT,a0
	calla	FINDPAL
	sll	8,a0
	zext	a0   
	move	a0,a1 

	move	@SelColTab,a0
	add	a0,a1

	movi	FlrSelCol,a0
	movk	1,a2		; change one color
	calla	PALSET

	SOUND1	SND_FLR_SEL

	movb	@EFLOOR,a9		; floor you're on
	sll	16,a9		; current floor up in high
	inc	a9		; target in low

	sleep	15
	
;	*
;	*   Fall through to ELEVATOR_MOVE!
;	*

*
*	a8 = neg if going down, pos if going up
*	a9 = current floor  : target floor
*	a10 = slot : start color
*
ELEVATOR_MOVE:
	move	a9,a0
	move	a9,a1
	zext	a0
	srl	16,a1
	cmp	a0,a1
	jreq	werethere

	movk   	9,a2		; assume one floor travel
	sub	a0,a1
	abs	a1
	dec	a1
	jrz	oneflr
	movk	5,a2
oneflr:
	move	a2,*a13(PDATA+20h)	; ticks to hold on each light

	PUSHP	a9
*
*	a9 = next color value : this color value
*	a10 = palette slot : start color
*
	SOUND1	SND_ELEV_MOTR		;elevator moving noise

	movi	[0,31<<10],a9	; actual color values
	movi	P_LEVEL,a0
	calla	FINDPAL
	jrz	werethere
	sll	8,a0
	zext	a0
	add	a0,a10		; slot : color

	movi	[1<<10,-(1<<10)],a4	; color delta (one up, one down)
	move	a8,a6
	jrnn	posdelta
	rl	16,a4			; reverse if going down
	rl	16,a9			; 
	dec	a10			; start one color down
posdelta:
	move	a4,a8

keepgoin:
	movk	4,a5
flshlp1:			
	mmtm	a12,a5,a6		; save loop count and direction
	movk	31,a11
flshlp2:
	addxy	a8,a9			; change color
	move	a9,*a13(PDATA),L

	movk	2,a2 			; request pallette transfer
	move	a10,a1
	move	a13,a0
	addi	PDATA,a0
	calla	PALSET

	sleep	1
	dsjs	a11,flshlp2		; fade 2 colors thru 31 values

	move	*a13(PDATA+20h),a0	; SLEEP a bit
	calla	PRCSLP

	mmfm	a12,a5,a6
	add	a6,a10			; go to next color
	rl	16,a9			; restart color

	dsjs	a5,flshlp1


	move	*a12,a0		; take target, but leave on stack
	move	*a12(10h),a1	; take current
	add	a6,a1		; update current
	cmp	a0,a1
	jreq	werethere

	move	a1,*a12(10h)	; store new current
	jruc	keepgoin

werethere:
*
*	DING!  everybody out, please
*
	move	a1,a9
	movb	a1,@EFLOOR
	addk	32,a12			; clean up stack

	SOUND1	SND_CHAN0_OFF
	SOUND1	SND_ELEV_ARRIVE

	movi	P_ELEVBUT,a0
	calla	FINDPAL		; in a0 if found
	sll	8,a0
	zext	a0   
	move	a0,a1 

	move	a9,a0		; current floor
	dec	a0
	sll	4,a0
	move	a0,a11		; save for a moment
	addi	SelColTab,a0	; get start color
	move	*a0,a0
	add	a0,a1

	movi	FlrDeselCol,a0
	movk	1,a2		; change one color
	calla	PALSET		; turn off selected floor light

	sll	1,a11		    ; make long word index
	addi	ELEVTABLE,a11	    ;  
	move	*a11,a11,L	    ; where to scroll to upon exit
	jauc	SCRL_DISPATCHER	    ;

	
SND_ELEV_ARRIVE		   
	.word	0f3E2h,60,081cah,0	



LevColTab:
	.word	7,11,15		; color number for each floor
SelColTab:
	.word	8,18,45		; color number for each floor

FlrSelCol:	.word  (31<<10)+(31<<5)		; yellow
LevIndCol:	.word  (31<<10)			; red
FlrDeselCol:	.word	0

*
*	Light the level indicator for the current floor
*
SET_EFLR_COLOR:
	movi	P_LEVEL,a0
	calla	FINDPAL		; in a0 if found
	jrz	notfound
	sll	8,a0
	zext	a0		; 
	move	a0,a1		; Dest pal
	movb	@EFLOOR,a14  	; 0 is all off
	jrz	noefdec
	dec	a14
noefdec:
	sll	4,a14
	addi	LevColTab,a14
	move	*a14,a14
	add	a14,a1		; DestPal : start col

	movi	LevIndCol,a0
	movk	1,a2
	calla	PALSET
notfound:
	rets


SPSIGN_CVECT
	WWL	OID_PROCKET,~MASK_PLAYER,UNIV_ROCKET_COLL
	WWL	OID_PEXPLOSION,~MASK_PLAYER,SPSIGN_COLLVECT
	WL	0,DUMCRETS

SPSIGN_GUNVECT:
	move	*a8(OFLAGS),a14
	btst	B_ANIM,a14
	jrnz	frsthook
	move	*a8(OULINK),a3,L
  	move	*a3(MAP_IMG),a1,L
	CLRM	*a3(MAP_FLAGS),W	; junk oid when recreated
	btst	1,a1
	jrnz	frsttime
	move	*a8(AnimFrm),a1,L
	move	*a8(AnimScr),a14,L
	move	a8,a0
	calla	STRTANIM_OFF
	jruc	frsthook
*
*	Start animation going!
*
frsttime:
	srl	4,a1
	sll	4,a1
	calla	STRT_ANIM		; animate the object

frsthook:
	MOVKB	1,*a8(AnimSLP)
	SOUND1  SND_SPSIGN_HIT
	rets	


SPSIGN_COLLVECT:
	PUSH	a0
	CALLA	UNIV_COLL_CHECK
	JRNZ	SPSX

	MMTM	SP,B1,B2,B4,B5,B6,B8,B9,B10

	SOUND1	SND_SIGN_SMASH

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

	calla	BG_TO_FG
	calla	DELETE_OBJ

	MMFM	SP,B1,B2,B4,B5,B6,B8,B9,B10

	MOVKM	1,@SPIN_SIGN_GONE,W

SPSX:
	PULLQ	a0
	rets

SND_SIGN_SMASH:
;	.WORD	0f3c4H,39,0A328h,0
	.WORD	0F330H,31,0A15AH,0

SND_SPSIGN_HIT:
	.WORD	0f370H,47,0A166h,0

SND_EXPLO_S:
	.word	0f370h,88,0a390h,0	; generic explo

SND_EXPLO_L:
	.word	0f370h,120,0a38dh,0	; generic explo

MGLASS_CVECT
	WWL	OID_PROCKET,~MASK_PLAYER,UNIV_ROCKET_COLL
	WWL	OID_PEXPLOSION,~MASK_PLAYER,MGLASS_COLL
	WL	0,DUMCRETS


MGLASS_COLL
	CALLA	UNIV_COLL_CHECK
	JRNZ	MG_DONE				;BR=NO GOOD
	MOVE	*A0(OID),A0,W			;GET PLAYER DATA ADDRESS
	CALLA	POID_TO_PDATA
	MOVI	500,A5				;500 POINTS
	MOVK	M_NOMORE|M_LASTFRM|M_FLASHOBJ,A7	;LAST FRAME AND FLASH
	jruc	MGLASS_hk


MGLASS_GUNVECT
	SOUNDZ	SND_MIRROR_CRACK

	MOVK	M_NOMORE|M_FLASHOBJ,A7		;FLASH
MGLASS_hk:
	MOVI	500,A5				;500 POINTS
	CLR	A9				;NO OFFSET
	CALLA	UNIV_DAMAGE_HANDLER
	JRC	MG_MAKE_GLASS			;BR=LAST DAMAGE FRAME

MG_DONE
	RETS


MG_MAKE_GLASS:
;	MOVE	*A8(OFLAGS),A14,W		;TURN ON PIXEL SCANNING
;	ANDNI	M_NOPIXSCAN,A14
;	MOVE	A14,*A8(OFLAGS),W
	calla	MC_MAKE_GLASS	
	MOVKM	1,@MORFGLASOUT,W	; tell others glass is out
	calla	BG_TO_FG
	calla	DELETE_OBJ
	rets


**************************************************************************
*								         *
* DAMAGE VECTORS							 *
*								         *
**************************************************************************
JUNGLE_VECT_TABLE:
; 1
	.LONG	0,0
;2, 3		       
	.LONG	TTOP4_CVECT,TTOP4_GUNV,LILP2_CVECT,LILP2_GUNV
;4, 5		       
	.LONG	DUMCVECT,WOOD_GUNVECT,DOCPILE_CVECT,DOCPILE_GUNVECT
;6, 7		       
	.LONG	DUMCVECT,GRYSTONE_GUNVECT,DUMCVECT,WOOD_GUNVECT
;8, 9
	.LONG	VIDCAM_CVECT,VIDCAM_GUNVECT,0,0
;10, 11
	.LONG	DUMCVECT,METAL_DR_GUNVECT,DUMCVECT,PALM_GUNVECT
;12, 13
	.LONG	MAGDR_CVECT,MAGDR_GUNVECT,DESK_CVECT,DUMRETS
;14, 15
	.LONG	SKYLIT_CVECT,SKYLIT_GUNVECT,DSKSTUF_CVECT,DSKSTUF_GUNVECT
;16, 17
	.LONG	0,KERRI_GUNVECT,DUMCVECT,BRNSTONE_GUNVECT
;18, 19
	.LONG	TRKDR_CVECT,TRKDR_GUNVECT,BUGHEAD_CVECT,BUGHEAD_GUNVECT
;20, 21
	.LONG	HONEY_CVECT,DUMRETS,STONE_CVECT,POINTS_GUNVECT
;22, 23
	.LONG	STONE_CVECT,PTBLOK_GUNVECT,STONE_CVECT,NEWHOL_GUNVECT
;24, 25
	.LONG	BASIC_CVECT,BASIC_GUNVECT,SPSIGN_CVECT,SPSIGN_GUNVECT
;26, 27
	.LONG	CANDLE_CVECT,CANDLE_GUNVECT,FLAMBUSH_CVECT,RUSTLE2_GUNVECT
;28, 29
	.LONG	BRIDGE_CVECT,STONE_BUL_SND,CRSTONE_CVECT,STONE_BUL_SND
;30, 31
	.LONG	STONE_CVECT,STONE_BUL_SND,RUSTLE_CVECT,RUSTLE_GUNVECT
;32
	.LONG	DUMCVECT,METAL_DR_GUNVECT	      



BLDG_VECT_TABLE:
; 1
	.LONG	0,0
;2, 3			     chain, sign left
	.LONG	CHAIN_CVECT,CHAIN_GUNVECT,SIGN_CVECT,DUMRETS
;4, 5			     chain, sign center
	.LONG	CHAIN_CVECT,CHAIN_GUNVECT,SIGN_CVECT,DUMRETS
;6, 7			     chain, sign right
	.LONG	CHAIN_CVECT,CHAIN_GUNVECT,SIGN_CVECT,DUMRETS
;8, 9
	.LONG	VIDCAM_CVECT,VIDCAM_GUNVECT,0,ELEVBUT_GUNVECT
;10, 11
	.LONG	DUMCVECT,METAL_DR_GUNVECT,DUMCVECT,RUSTLE_GUNVECT
;12, 13
	.LONG	MAGDR_CVECT,MAGDR_GUNVECT,DESK_CVECT,DUMRETS
;14, 15
	.LONG	SKYLIT_CVECT,SKYLIT_GUNVECT,DSKSTUF_CVECT,DSKSTUF_GUNVECT
;16, 17
	.LONG	0,KERRI_GUNVECT,0,EFLR_SEL_GUNVECT
;18, 19
	.LONG	TRKDR_CVECT,TRKDR_GUNVECT,BUGHEAD_CVECT,BUGHEAD_GUNVECT
;20, 21
	.LONG	HONEY_CVECT,DUMRETS,STONE_CVECT,POINTS_GUNVECT
;22, 23
	.LONG	STONE_CVECT,PTBLOK_GUNVECT,STONE_CVECT,NEWHOL_GUNVECT
;24, 25
	.LONG	BASIC_CVECT,BASIC_GUNVECT,SPSIGN_CVECT,SPSIGN_GUNVECT
;26, 27
	.LONG	CANDLE_CVECT,CANDLE_GUNVECT,FLAMBUSH_CVECT,RUSTLE2_GUNVECT
;28, 29
	.LONG	PIPE_CVECT,PIPE_GUNVECT,CRSTONE_CVECT,STONE_BUL_SND
;30, 31
	.LONG	STONE_CVECT,STONE_BUL_SND,RUSTLE_CVECT,RUSTLE_GUNVECT
;32
	.LONG	DUMCVECT,METAL_DR_GUNVECT     



CHEM_VECT_TABLE:
; 1
	.LONG	0,0
;2, 3		       
;	.LONG	CTABLE_COLLVECT,CTABLE_GUNVECT,CHAIRBOY_COLLVECT,CHAIRBOY_GUNVECT
	.LONG	CTABLE_COLLVECT,CTABLE_GUNVECT,0,0
;4, 5		       
	.LONG	TRASHCAN_COLLVECT,TRASHCAN_GUNVECT,PHONE_COLLVECT,PHONE_GUNVECT
;6, 7		       
	.LONG	RECEIVER_COLLVECT,RECEIVER_GUNVECT,COIN_DOOR_COLLVECT,COIN_DOOR_GUNVECT
;8, 9
	.LONG	VIDCAM_CVECT,VIDCAM_GUNVECT,SODA_CVECT,SODA_GUNVECT
;10, 11			 top of machine
	.LONG	MACH_CVECT,DUMRETS,MACH_CVECT,MACH_GUNVECT
;12, 13            flying machine parts,  flaming machine parts
	.LONG	MACH_CVECT,MACH_GUNVECT,MACH_CVECT,MACH_GUNVECT
;14, 15		                             
	.LONG	SKYLIT_CVECT,SKYLIT_GUNVECT,0,0
;16, 17
	.LONG	0,KERRI_GUNVECT,0,EFLR_SEL_GUNVECT
;18, 19
	.LONG	0,0,DSKSTUF_CVECT,DSKSTUF_GUNVECT
;20, 21
	.LONG	GRATE_CVECT,METAL_GUNVECT,BOXMACH_CVECT,BOXMACH_GUNVECT	
;22, 23
	.LONG	MGLASS_CVECT,MGLASS_GUNVECT,0,0
;24, 25
	.LONG	BASIC_CVECT,BASIC_GUNVECT,DUMCVECT,BRNSTONE_GUNVECT 
;26, 27
	.LONG	CANDLE_CVECT,CANDLE_GUNVECT,PIPE_CVECT,PIPE_GUNVECT
;28, 29
	.LONG	BUB_CVECT,BUB_GUNVECT,CRSTONE_CVECT,STONE_BUL_SND
;30, 31
	.LONG	STONE_CVECT,STONE_BUL_SND,DROP_CVECT,DROP_GUNVECT
;32
	.LONG	DUMCVECT,METAL_DR_GUNVECT     


GLS_ANIM_SM
	LW	SMSHRD1,2
	LW	SMSHRD2,2
	LW	SMSHRD3,2
	LW	SMSHRD4,2
	LW	SMSHRD5,2
	LW	SMSHRD6,2
	LW	SMSHRD7,2
	LW	SMSHRD8,2
	LW	SMSHRD9,2
	LWL	SMSHRD10,2|AFunc,A_OFF_DELETE_OBJ
	.long	0


GLS_ANIM_ME
	LW	MDSHRD1,2
	LW	MDSHRD2,2
	LW	MDSHRD3,2
	LW	MDSHRD4,2
	LW	MDSHRD5,2
	LWL	MDSHRD6,2|AFunc,A_OFF_DELETE_OBJ
	.long	0


GLS_ANIM_LG
	LW	fshard1,2
	LW	fshard2,2
	LW	fshard3,2
	LW	fshard4,2
	LW	fshard5,2
	LW	fshard6,2
	LW	fshard7,2
	LW	fshard8,2
	LW	fshard9,2
	LWL	fshard10,2|AFunc,A_OFF_DELETE_OBJ
	.long	0

BRK_ANIM_1
	LW	RUBBLE1,3
	LW	RUBBLE2,3
	LW	RUBBLE3,3
	LW	RUBBLE4,3
	LW	RUBBLE5,3
	LW	RUBBLE6,3
	LW	RUBBLE7,3
	LW	RUBBLE8,3
	LWL	RUBBLE9,3|AFunc,A_OFF_DELETE_OBJ
	.long	0

BRK_ANIM_2
	LW	ROBBLE1,2
	LW	ROBBLE2,2
	LW	ROBBLE3,2
	LW	ROBBLE4,2
	LW	ROBBLE5,2
	LW	ROBBLE6,2
	LW	ROBBLE7,2
	LWL	ROBBLE8,2|AFunc,A_OFF_DELETE_OBJ
	.long	0


*
* Frag script for when a block totally blow up
*
FRAG_BLOCK_BLOW
	.long	PART_EXPLOSION,F_X2
	.word	OID_JUNK,(1 << 11) + (1 << 6) + (FRGPAL|FRGNOFLY)
	.long	BRK_ANIM_1,B_STUFF_X2
	.word	OID_JUNK,(4 << 11) + (1 << 6) + (FRGPAL|FRGGCOL)
	.long	BRK_ANIM_2,B_STUFF_X2
	.word	OID_JUNK,(4 << 11) + (1 << 6) + (FRGPAL|FRGGCOL)
	.long	BRK_ANIM_1,B_STUFF_X2
	.word	OID_JUNK,(4 << 11) + (1 << 6) + (FRGPAL|FRGGCOL)
	.long	BRK_ANIM_2,B_STUFF_X2
	.word	OID_JUNK,(4 << 11) + (1 << 6) + (FRGPAL|FRGGCOL)
	.long	0

FRG_BR_12
	.long	FRAG_DUST_CLOUD_ANIM,F_BLOCK_DUST
	.word	OID_JUNK,(1 << 11) + (0 << 6) + (FRGNOFLY+FRGNOFLP)
FRG_BRONLY_12
	.long	BRK_ANIM_1,B_STUFF_X2
	.word	OID_JUNK,(4 << 11) + (1 << 6) + (FRGPAL|FRGGCOL)
	.long	BRK_ANIM_2,F_X2
	.word	OID_JUNK,(4 << 11) + (1 << 6) + (FRGBOG|FRGPAL)
	.long	GLS_ANIM_LG,G_STUFF_X2
	.word	OID_JUNK,(4 << 11) + (0 << 6) + (FRGBOG|FRGGCOL|FRGNOFLY)
	.long	0

FRG_BR_12_1X
	.long	FRAG_DUST_CLOUD_ANIM,F_BLOCK_DUST_1X
	.word	OID_JUNK,(1 << 11) + (0 << 6) + (FRGNOFLY+FRGNOFLP)
	.long	BRK_ANIM_1,B_STUFF_X2
	.word	OID_JUNK,(4 << 11) + (1 << 6) + (FRGPAL|FRGGCOL)
	.long	BRK_ANIM_2,F_X2
	.word	OID_JUNK,(4 << 11) + (1 << 6) + (FRGBOG|FRGPAL)
	.long	GLS_ANIM_LG,G_STUFF_X2
	.word	OID_JUNK,(4 << 11) + (0 << 6) + (FRGBOG|FRGGCOL|FRGNOFLY)
	.long	0

FRG_BR_6_1X
	.long	FRAG_DUST_CLOUD_ANIM,F_BLOCK_DUST_1X
	.word	OID_JUNK,(1 << 11) + (0 << 6) + (FRGNOFLY+FRGNOFLP)
	.long	BRK_ANIM_1,B_STUFF
	.word	OID_JUNK,(3 << 11) + (1 << 6) + (FRGPAL|FRGGCOL)
	.long	BRK_ANIM_2,0
	.word	OID_JUNK,(3 << 11) + (1 << 6) + (FRGBOG|FRGPAL)
	.long	0


FRG_GL_12
	.long	GLS_ANIM_SM,G_STUFF
	.word	OID_JUNK,(6 << 11) + (1 << 6) + (FRGBOG|FRGGCOL|FRGNOFLY)
	.long	GLS_ANIM_ME,G_STUFF
	.word	OID_JUNK,(3 << 11) + (2 << 6) + (FRGGCOL|FRGNOFLY)
	.long	GLS_ANIM_LG,G_STUFF
	.word	OID_JUNK,(2 << 11) + (0 << 6) + (FRGBOG|FRGGCOL|FRGNOFLY)
	.long	0

FRG_GL_12_2X
	.long	GLS_ANIM_SM,G_STUFF_X2
	.word	OID_JUNK,(6 << 11) + (1 << 6) + (FRGBOG|FRGGCOL|FRGNOFLY)
	.long	GLS_ANIM_ME,G_STUFF_X2
	.word	OID_JUNK,(3 << 11) + (2 << 6) + (FRGGCOL|FRGNOFLY)
	.long	GLS_ANIM_LG,G_STUFF_X2
	.word	OID_JUNK,(2 << 11) + (0 << 6) + (FRGBOG|FRGGCOL|FRGNOFLY)
	.long	0



FRG_GL_10
	.long	GLS_ANIM_LG,S_STUFF
	.word	OID_JUNK,(2 << 11) + (2 << 6) + (FRGNOFLY)
	.long	GLS_ANIM_ME,S_STUFF
	.word	OID_JUNK,(4 << 11) + (2 << 6) + (FRGNOFLY)
	.long	GLS_ANIM_SM,S_STUFF
	.word	OID_JUNK,(4 << 11) + (0 << 6) + (FRGNOFLY|FRGBOG)
	.long	0

FRG_BOX_8
	.long	BRK_ANIM_1,G_STUFF
	.word	OID_JUNK,(3 << 11) + (1 << 6) + (FRGGCOL|FRGNOFLY)
	.long	BRK_ANIM_2,G_STUFF
	.word	OID_JUNK,(3 << 11) + (1 << 6) + (FRGBOG|FRGGCOL|FRGNOFLY)
	.long	GLS_ANIM_LG,G_STUFF
	.word	OID_JUNK,(2 << 11) + (0 << 6) + (FRGBOG|FRGGCOL|FRGNOFLY)
	.long	0


*
* Fragger func to double scale the image
* A0 = Ptr to uninserted object
F_X2
	ORIM	M_DBLSCL,*A0(OFLAGS),W
	RETS

B_STUFF_X2
	ORIM	M_DBLSCL,*A0(OFLAGS),W
B_STUFF:
	MOVI	GLAS_COLL,A14
	MOVE	A14,*A0(OCVECT),L	;Set up chunk with Vectors	
	RETS


S_STUFF:
	movi	0e00h,a14
	move	a14,*a0(OYACCEL)

	move	*a0(OFLAGS),a14
	ori	M_DBLSCL,a14
	move	a14,*a0(OFLAGS)

	jruc	stufhk

G_STUFF_X2
	ORIM	M_DBLSCL,*A0(OFLAGS),W
G_STUFF:
	movi	2800h,a14
	move	a14,*a0(OYACCEL)

	MOVI	GLAS_COLL,A14
	MOVE	A14,*A0(OCVECT),L	;Set up chunk with Vectors	
stufhk:
	move	A0,A2
	MOVE	*A13(FPDATA),A0,L	;GET PALETTE
	calla	GETFPAL
	JRNZ	FS_PAL			;BR = WE HAVE PALETTE!
	CLR	A0
FS_PAL
	move	A0,*A2(OPAL),W
	move	A2,A0
	RETS


GLAS_COLL
	WWL	OID_GRND,0FFFFH,GLAS_GRND_COLL
	WL	0,DUMCRETS

**************************************************************************
*								         *
* 	F_BLOCK_DUST							 *
* 									 *
* 	Frag func to initialize the block dust cloud			 *
* 									 *
* 	A0 = Ptr to un-inserted object					 *
*								         *
**************************************************************************
F_BLOCK_DUST
	ORIM	M_DBLSCL,*A0(OFLAGS),W
F_BLOCK_DUST_1X
	MOVE	A0,A2
	MOVI	P_DUSTEV,A0
	CALLA	GETFPAL
	MOVE	A0,*A2(OPAL),W
	MOVE	A2,A0
	RETS

P_DUSTEV:
   .word   64 
   .word   00000h,01c01h,00c01h,01401h,02441h,02021h,01801h,034c1h
   .word   02861h,01801h,01001h,02c81h,03d03h,01c01h,01401h,030a1h
   .word   04545h,02021h,01c01h,055c9h,04d87h,05e0bh,038e2h,04124h
   .word   04966h,0624ch,034c3h,02c81h,02441h,01401h,02021h,01006h
   .word   03d05h,02865h,0628ch,04125h,04546h,03d04h,051a8h,04126h
   .word   02441h,034c2h,038e3h,04547h,030a6h,01c01h,034c8h,04d89h
   .word   059eah,04967h,030a2h,0140bh,0412bh,030a1h,04968h,00c08h
   .word   02c84h,04129h,038eah,04d88h,02021h,062cch,059e8h,0622ah

**************************************************************************
*								         *
* GLAS_GRND_COLL - FRAGMENT GROUND COLLISION VECTOR			 *
*								         *
* PASS:									 *
* A8 = OBJECT								 *
*								         *
**************************************************************************

GLAS_GRND_COLL
	MOVE	*A8(OYVEL),A14,L
	JAN	DELETE_OBJ			;BR=GOING UP
	JAZ	DELETE_OBJ			;BR=STOPPED

	SRA	2,A14				;OYVEL=OYVEL/4

	CMPI	010000H,A14
	JALT	DELETE_OBJ			;BR=BELOW MINIMUM VELOCITY
	NEG	A14				;REVERSE VELOCITY
	MOVE	A14,*A8(OYVEL),L
	RETS


FLICK_TAB:
	.long	FLK_m5_P,FLK_m4_P,FLK_m3_P,FLK_m2_P
	.long	FLK_m5_P,FLK_m4_P,FLK_m3_P,FLK_m4_P
	.long	FLK_m1_P,FLKWOBK_P,FLK_p1_P,FLK_p2_P
	.long	FLK_m1_P,FLKWOBK_P,FLK_p1_P,FLKWOBK_P


FLK_m1_P:
   .word   61 
   .word   0185bh,02528h,03128h,03525h,03d69h,03d25h,00842h,01862h
   .word   01ca2h,02482h,02062h,01062h,028a5h,030c5h,01ca5h,02c82h
   .word   01040h,014a5h,03cc2h,044e5h,00c20h,034a2h,02c60h,03ca2h
   .word   014a2h,01440h,00000h,00420h,00841h,00c81h,01083h,02107h
   .word   039cch,01c60h,039cah,04a0fh,02880h,041aah,02462h,04a72h
   .word   05651h,0524eh,045ech,038c2h,01420h,02460h,02c80h,034a0h
   .word   038c1h,040c1h,05a93h,048e2h,05a8fh,05a4ah,03ca1h,044c1h
   .word   04ce2h,04120h,049a0h,066cch,06b52h

FLK_m2_P:
   .word   61 
   .word   0185bh,02128h,02d28h,03125h,03969h,03925h,00442h,01462h
   .word   018a2h,02082h,01c62h,00c62h,024a5h,02cc5h,018a5h,02882h
   .word   00c40h,010a5h,038c2h,040e5h,00820h,030a2h,02860h,038a2h
   .word   010a2h,01040h,00000h,00020h,00441h,00881h,00c83h,01d07h
   .word   035cch,01860h,035cah,0460fh,02480h,03daah,02062h,04672h
   .word   05251h,04e4eh,041ech,034c2h,01020h,02060h,02880h,030a0h
   .word   034c1h,03cc1h,05693h,044e2h,0568fh,0564ah,038a1h,040c1h
   .word   048e2h,03d20h,045a0h,062cch,06752h
FLK_m3_P:
   .word   61 
   .word   0185bh,01d28h,02928h,02d25h,03569h,03525h,00042h,01062h
   .word   014a2h,01c82h,01862h,00862h,020a5h,028c5h,014a5h,02482h
   .word   00840h,00ca5h,034c2h,03ce5h,00420h,02ca2h,02460h,034a2h
   .word   00ca2h,00c40h,00000h,00020h,00041h,00481h,00883h,01907h
   .word   031cch,01460h,031cah,0420fh,02080h,039aah,01c62h,04272h
   .word   04e51h,04a4eh,03dech,030c2h,00c20h,01c60h,02480h,02ca0h
   .word   030c1h,038c1h,05293h,040e2h,0528fh,0524ah,034a1h,03cc1h
   .word   044e2h,03920h,041a0h,05ecch,06352h
FLK_m4_P:
   .word   61 
   .word   0185bh,01928h,02528h,02925h,03169h,03125h,00042h,00c62h
   .word   010a2h,01882h,01462h,00462h,01ca5h,024c5h,010a5h,02082h
   .word   00440h,008a5h,030c2h,038e5h,00020h,028a2h,02060h,030a2h
   .word   008a2h,00840h,00000h,00020h,00041h,00081h,00483h,01507h
   .word   02dcch,01060h,02dcah,03e0fh,01c80h,035aah,01862h,03e72h
   .word   04a51h,0464eh,039ech,02cc2h,00820h,01860h,02080h,028a0h
   .word   02cc1h,034c1h,04e93h,03ce2h,04e8fh,04e4ah,030a1h,038c1h
   .word   040e2h,03520h,03da0h,05acch,05f52h
FLK_m5_P:
   .word   61 
   .word   0185bh,01528h,02128h,02525h,02d69h,02d25h,00042h,00862h
   .word   00ca2h,01482h,01062h,00062h,018a5h,020c5h,00ca5h,01c82h
   .word   00040h,004a5h,02cc2h,034e5h,00020h,024a2h,01c60h,02ca2h
   .word   004a2h,00440h,00000h,00020h,00041h,00081h,00083h,01107h
   .word   029cch,00c60h,029cah,03a0fh,01880h,031aah,01462h,03a72h
   .word   04651h,0424eh,035ech,028c2h,00420h,01460h,01c80h,024a0h
   .word   028c1h,030c1h,04a93h,038e2h,04a8fh,04a4ah,02ca1h,034c1h
   .word   03ce2h,03120h,039a0h,056cch,05b52h
FLK_p1_P:
   .word   61 
   .word   0185bh,02d28h,03928h,03d25h,04569h,04525h,01042h,02062h
   .word   024a2h,02c82h,02862h,01862h,030a5h,038c5h,024a5h,03482h
   .word   01840h,01ca5h,044c2h,04ce5h,01420h,03ca2h,03460h,044a2h
   .word   01ca2h,01c40h,00800h,00c20h,01041h,01481h,01883h,02907h
   .word   041cch,02460h,041cah,0520fh,03080h,049aah,02c62h,05272h
   .word   05e51h,05a4eh,04dech,040c2h,01c20h,02c60h,03480h,03ca0h
   .word   040c1h,048c1h,06293h,050e2h,0628fh,0624ah,044a1h,04cc1h
   .word   054e2h,04920h,051a0h,06ecch,07352h
FLK_p2_P:
   .word   61 
   .word   0185bh,03128h,03d28h,04125h,04969h,04925h,01442h,02462h
   .word   028a2h,03082h,02c62h,01c62h,034a5h,03cc5h,028a5h,03882h
   .word   01c40h,020a5h,048c2h,050e5h,01820h,040a2h,03860h,048a2h
   .word   020a2h,02040h,00c00h,01020h,01441h,01881h,01c83h,02d07h
   .word   045cch,02860h,045cah,0560fh,03480h,04daah,03062h,05672h
   .word   06251h,05e4eh,051ech,044c2h,02020h,03060h,03880h,040a0h
   .word   044c1h,04cc1h,06693h,054e2h,0668fh,0664ah,048a1h,050c1h
   .word   058e2h,04d20h,055a0h,072cch,07752h


*
*	a0 = # of sounds
*	a1 = sound table
*
TAB_SOUND
	CALLA	RAND0
	SLL	5,A0
	ADD	A0,A1
	MOVE	*A1,A0,L
	JAUC	ONESND_Z

 	
S_SET_IRQSTRT:
	move	@WAVEIRQS,@IRQSTRT,L
	jauc	SCRL_DISPATCHER





	      .if 0	      


***********************************************************************
*
*	       a8 delta Z
*	need   a9 start Z
*              a10 left x : right x
*	       a11 Y start (0=YWORLD) : # pillars
*
S_CREATE_DIAGPBOYS:

	move	a11,a0
	mmfm	a0,a8,a9,a10,a11
	move	a0,*-a12,L	; save scrl table ptr
	move	@ZREL_OFF,a14,L
	sra	ZFRAC,a14	; make it lores
	add	a14,a9
	move	a11,a1
	sra	16,a1
	jrnz	DYcool
	move	@YWORLD,a1,L
	movy	a1,a11
DYcool:

	CREATE	PID_IND,CREATE_DIAGPBOYS

	move	*a12+,a11,L
	jauc	SCRL_DISPATCHER


CREATE_DIAGPBOYS:
*	       a8 delta Z between pillars
*	need   a9 start Z
*              a10 left x : right x
*	       a11 Y start : # pillars 

*
*	CREATE ONE DIAG GUY
*

	PUSH	A8
	MOVI	DIAG_PBOY_INIT,B0	;ALLOCATE OBJECT
	CALLA	CREATE_ENEMY
	PULL	A4			;A4=delta Z
	MOVE	A8,A8
	JRZ	CPBX			;BR = ABORT! ABORT!

	MOVE	A8,A0
	MOVI	DIAG_PBOY_ANIM,A1  ; frame pointer
	CALLA	STRTANIM		;START ANIMATION

	MOVK	1,A14
	MOVB	A14,*A8(OHITS)		;NUMBER OF ALLOWED HITS

	move	a10,a1
	sll	16,a1
	clr	a0
	movy	a10,a0
	sub	a1,a0
	sra	6,a0		; go dist in 64 ticks

	move	a10,a1
	MOVE	@RAND,A14,W		;LEFTY OR RIGHTY?
	move	a14,a6
	ANDI	M_FLIPH,A6
	jrnz	use_rt
	srl	16,a1
	neg	a0
use_rt:
	move	a0,*a8(OXVEL),L
	move	a4,a5
	sra	6,a5
	move	a5,*a8(OZVEL),L
	sll	16,a1
	MOVE	*A8(OCTRL),A7,W
	OR	A6,A7
	MOVE	A7,*A8(OCTRL),W
	clr	a2
	movy	a11,a2			; Y in a2
	move	a9,a3			; Z in a3
	clr	a6
	andi	0e00h,a14
	jrz	noadjZ
	srl	9,a14			; isolate 2 bit field in RAND
adjZlp:
	add	a4,a3
	inc	a6
	dec	a11
	jrz	noadjZ
	dsjs	a14,adjZlp		; place guy closer
noadjZ:
	add	a11,a6			; restore full number

	move	a11,a0
        zext	a0
	dec	a0
	calla	RANDU
	inc	a0
	move	a0,a11			; number of crosses before headon

	CALLA	SET_ANIPU
	add	a4,a3
	move	a3,*a8(ODATA),L		; target Z

	MOVI	M_SIDE,A14
	MOVE	A14,*A8(OEFLAGS),W	;SET TYPE

	move	a9,a5
	move	a4,a9
	CREATE	PID_IND,MON_DIAG_PBOY
	move	a0,*a8(OPLINK),L

	CALLA	INSERT_ENEMY		;INSERT AND COUNT ENEMY
	move	a9,a8
	move	a5,a9
	move	a6,a11			; restore a11 to full number

CPBX:
	movi	70,a0
	calla	RANDU
	addi	10,a0
	calla	PRCSLP

	move	@SCROLLKILL,a1
	jrz	CREATE_DIAGPBOYS

	dec	a1
	move	a1,@SCROLLKILL
	DIE


*
*	a8 = object
*	a9 = delta Z
*       a10 left x : right x
*	a11 Y start : # pillars 
*
MON_DIAG_PBOY:
	zext	a11		; lose Y start
	dec	a11
	move	*a8(OXVEL),a14,L
	jrnn	MDP_LP
	rl	16,a10		; get first target right

MDP_LP:
	move	*a8(ODATA),a0,L		; target univ Z
	move	*a8(OZVAL),a1,L		; 
	cmp	a1,a0
	jrlt	check_close
	clr	a14
	move	a14,*a8(OZVEL),L	; clr Z motion
	move	*a8(OXPOS),a1		; check target X
	subxy	a10,a1
	jrxz	there
	move	*a8(OXVEL+10h),a2
	xor	a2,a1
	sext	a1
	jrn	nothereyet

*
*	time to flip the guy
*
there:
	rl	16,a10		; new X targ
*
*	Is guy close?
*
	dec	a11
	jrn	run_at_ya
	jrnz	usual
*
*	get out to middle
*
	sra	1,a9	; cut Z delta in half
	move	a10,a1
	sra	16,a1
	sext	a10
	add	a1,a10
	sra	1,a10
usual:
	add	a9,a0
	move	a0,*a8(ODATA),L	;new Z targ
	move	*a8(OZVAL),a14,L
	sub	a14,a0
	sra	6,a0
	move	a0,*a8(OZVEL),L


	movi	40,a0
	calla	RANDU
	addk	3,a0
	calla	PRCSLP
	move	*a8(OXVEL),a0,L
	neg	a0
	move	a0,*a8(OXVEL),L
	movi	M_FLIPH,a0
	calla	TOGGLE_FLIP
nothereyet:
	sloop	1,MDP_LP

check_close:
	move	@ZSCROLL,a14,L	; are we scrolling?
	jrz	nothereyet	; jump if no
	move	@ZBASE,a14,L
	sub	a14,a1		; world Z
	cmpi	5000h,a1	; are we close?
	jrgt	nothereyet	; jump if  no
	movi	NONBOY_HEADON_SHOOT_ANIM,a1
	jruc	finish_up
*
*	guy is close, have him shoot and run
*
run_at_ya:
	movi	-140h,a14
	move	a14,*a8(OZVEL),L

	movi	NONBOY_HEADON_RUN_ANIM,a1
finish_up:
	move	a1,*a8(AnimFrm),L
	move	a1,*a8(AnimScr),L

	MOVK	1,A14
	MOVB	A14,*A8(OHITS)		;NUMBER OF ALLOWED HITS

	MOVK	1,A14
	MOVB	A14,*A8(OSCRNOFFCNT)	;TIMES ALLOWED OFF SCREEN

	MOVK	1,A1
	MOVK	5,A0
	CALLA	RANGRAND
	MOVB	A0,*A8(OSHOOTCNT)	;RANDOM SHOOTING CHECK COUNT

	clr	a14
	move	a14,*a8(OXVEL),L

	CLRM	*a8(OPLINK),L
	move	a14,*a8(OANIMCHK),L
	DIE

	.endif	      

	.END




