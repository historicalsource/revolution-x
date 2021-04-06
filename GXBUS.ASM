 	.MLIB	"GXMACS.LIB"
 	.FILE	"GXBUS.ASM"
	.TITLE	" <<< GENERATION X -- SCHOOL BUS MIDDLE EAST ROUTINES >>>"
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
	.INCLUDE	"GXCONTRL.H"
	.INCLUDE	"IMGTBL.GLO"
	.INCLUDE	"UNIVTBL.GLO"
	.INCLUDE	"GXBUS.TBL"
	.INCLUDE	"GXSCRL.h"
	.INCLUDE	"GXNONBOY.H"
	.INCLUDE	"GXS.H"
	.INCLUDE	"GXSTRING.H"
	.INCLUDE	"GXSCROLL.TBL"


BRIDGE_IN	.set	0		; no bridge for now

	.DEF	DESERT_SCROLL,DESERT_VECT_TABLE,SNOZZ_COUNT

* SYMBOLS FROM ???
	.ref	HOLD_ENEMY_DISPATCH,CURPLYRS,CURPLYR_ADJ,TAB_SOUND
	.ref	GUNS_OFF,P_SYMGRN,BONUS_DIRECTION,SND_SWEET_EMOTION
	.ref	WAVE_END_IMM,GAME_STATE,DELAYED_PRAISE ,BUS_ATTEMPTS
	.ref	S_DECEL_TO_POINTX_DELTA,WAVE_RESET,LM_PRINTF,PROC_COG_DESERT
	.ref	PCURSOR_OFF,REVEAL_CD_BUS,SEND_FLOAT_POWER,A_PERRY_SCORE
	.ref	A_OBJ_TO_POWERUP,CREATE_YJAK

* SYMBOLS FROM GXMONDR2.ASM
	.REF	BUS_EXPLOSION,BUS_EXPLOSION_SMALL

* SYMBOLS FROM GXBGFX.ASM
	.REF	SPRINKLE_POWERUPS

* SYMBOLS FROM GXfade.ASM
	.ref	BUSNOFADE,FADE_FULL2HALF,FADE_HALF2BLAK,FADEBLAK_TEXT

* SYMBOLS FROM GXBEEK1.ASM
	.REF	A_CHK_FIRE_FNC

* SYMBOLS FROM GXMISC.ASM
	.REF	CYCLE16,SKYDOWN

* SYMBOLS FROM GXUNIV.ASM and GXUNILNK.ASM
	.REF	UNIV_FLASH,WXBUFFER,UNIV_ID,BG_TO_FG
	.ref	RAMREF0,BGHEAD_ACTIVE,REMOVE_AND_FREE_LINK,RAMREF1
	.ref	UNIV_ROCKET_COLL,UNIV_COLL_CHECK,UNIV_DAMAGE_HANDLER

* SYMBOLS FROM GXUNIV1.ASM
	.REF	FRAG_U20_MIX,FRAG_S20,FRAG_U10,MAKE_EXPLO_GUN,MAKE_EXPLO_CENTER
	.ref	MAKE_EXPLO_OFF

* SYMBOLS FROM GXD.ASM
	.REF	XBASE, YBASE, ZBASE, XSCROLL, ZSCROLL, WAVEIRQS, ZSACCEL
	.REF	SET_ANIPZU, SET_ANIPU, A_SET_OYVEL, MULTIMAKE, EASYMAKE
	.REF	SET_SCALE_MANUAL,WAVEVEL,ZBASE_HR,YWORLD
	.REF	YHALF

* SYMBOLS FROM GXJUNGLE.ASM
	.ref	GREN_CVECT,GREN_GUNVECT,GREN_INIT,explode_gren
	.REF	BASIC_CVECT,BASIC_GUNVECT, STONE_BUL_SND
	.ref	FLY_AWAY,FRG_BR_12,FRG_GL_12

* SYMBOLS FROM GXAFUNC.ASM
	.ref	A_Set_LOOP_STRT,A_OFFSCRN_DEL,A_CHANGE_PAL
	.ref	A_Anim_DSJ, A_SOUND, A_PreFrag_Rain, A_PreFrag_Center
	.ref	A_Set_AnimLoop, A_AUDIT

* SYMBOLS FROM GXWARREN.ASM
	.ref  FRAG_DESK_EXPLOSION,FRAG_DESK_RAIN
	.ref  FRAG_EXPLOSION,FRAG_DESK_METAL,FRAG_EXPLOSION_SMALL

* SYMBOLS FROM gxscroll.asm & GXSCROL2.ASM
	.ref	MERGE_UNIV_OFF,SCROLL_FLAG

* SYMBOLS FROM GXSOUND.ASM
	.ref	ONESND_Z,ONESND

* SYMBOLS FROM GXPALL.ASM
	.ref	CHANGE_PAL_CHECK

* SYMBOLS FROM GXUTIL.ASM
	.ref	Fragger,PreFrag_Center,PreFrag_Gun,RAND

* SYMBOLS FROM GXNONBOY.ASM
	.ref	BUSPOP_INIT,BUSPOP_DEATH,A_ALL_FIRE_FNC
	.ref	NONTHR_CVECT,NONBOY_GUNVECT,NONTHR_DEATH

* SYMBOLS FROM GXENEMY.ASM
	.ref	CREATE_ENEMY,DELETE_ENEMY,DEL_ENEMY_NOAUD
	.ref	INSERT_ENEMY

* SYMBOLS FROM GXLA1.ASM
	.REF	PALMTREETOP_COLLVECTR,PALMTREETOP_GUNVECT

* SYMBOLS FROM GXDESK.ASM
	.ref	SND_FINAL_EXPLODE1,SND_FINAL_EXPLODE2,SND_FINAL_EXPLODE3


RL_INTENDED_OBJ	.EQU	ODATA+0A0H	;UHL Ptr to Object rocket is intended
					;	to hit.

NON2DOOR_OFF	.set	90	; Z dist from door to grenade thrower

STEADY_Z_VAL	.set 040h
BUS_CRUISING_X	.set 60000h
BUS_ACCEL	.set  2800h
PLYR_ACCEL	.set  4c00h	; was 4000h
BUS_MIN_SPD	.set 58000h
BUS_CATCHUP_MIN	.set 10000h
BUS_MAX_SPD	.set 090000h
BUS_CATCHUP_MAX	.set 0c0000h
MIN_X_SCROLL	.set 48000h
MAX_X_SCROLL	.set 0b0000h
TO_END_TIKS	.set	360


OBULCNT	.set	ODATA	   	;UHW how many bullet hits til next part
OROKCNT	.set	ODATA+10h   	;UHW how many rocket hits til next part
OATEROCKET .set	ODATA+20H	;UHW I just ate a rocket
OTOTHITS .set	ODATA+30h  	;UHW (HEAD ONLY) number of destroyed bus parts
OGUNSGONE .set	ODATA+40h	;UHW flag (0 or 1) (HEAD only)
OIDLETIM .set	ODATA+40h	;UHW ticks to idle (DOOR & TURRETS)
ONODAMTIM .set 	ODATA+50h	;UHW time when damage lockout started
OROCKTIM .set	ODATA+80h	;UHW time of last rocket hit
OTHRHAF	.set	ODATA+0A0h	;UHL obj of other door half (door only)
OTURIDLE .set	ODATA+0A0h	;UHW max idle time (TURRET ONLY)
ONONTHR .set	ODATA+0C0h	;UHL obj block of grenade thrower (DOOR only)
OBDAMTBL .set	ODATA+0E0h	;UHL DAMAGE TABLE for this part

	.bss	NEXT_X,32	; univ X of start of next merged uni
	.bss	BUS_HEAD_OBJ,32	; obj block of bus multiparter
	.bss	BUS_STEADY_Z,32	; hidden Z vel of bus and SCROLL
	.bss	BUS_STOP_X,32	; univ x where bus will stop
	.bss	GAUGE_DELTA_X,32 ; x dist to get from one line to next (>>4)
	.bss	MASTER_IDLE,16	; time door stays shut
	.bss	BUS_STATE,16	; see BUS_SMARTS routine
	.bss	SNOZZ_COUNT,16	; how many CDs from noses?
	.bss	filler,16	; to keep long word aligned


	.TEXT
	.EVEN


GUARD_TABLE:
	.word	3
	.long	-21240000h,118000h,0cba3h
	.long	-1f920000h,120000h,08801h
	.long	-1e670000h,130000h,05adfh


S_MAKE_GUARDS:
	movi	GUARD_TABLE,a9

	move	*a9+,a10		; how many guards
SMG_lp:
	move	*a9+,a4,L
	move	*a9+,a2,L
	move	*a9+,a3,L
	calla	CREATE_YJAK

	sleep	1

	dsjs	a10,SMG_lp
	jauc	SCRL_DISPATCHER	


*	ENTRY:	a0 = some limit
*
*	EXIT:	a0 = the limit adjusted based on
*			CURPLYRS
*	(Formula:  for each player, the limit is decreased by
*			25%)
* ****	NOTE!!!!  THIS TRASHES A1 and A14 !
*
CURPLYR_ADJ_DOWN:
	move	a0,a1
	cmpk	4,a1
	jrlt	adj_done
	srl	2,a1		; qrtr of max
	move	@CURPLYRS,a14
	dec	a14
	jrle	adj_done
	sub	a1,a0
	dec	a14
	jrle	adj_done
	sub	a1,a0
adj_done:
	rets


wait_for_obj:
	sleep	20

S_MAKE_BUS:	
	MOVKM	30,@MASTER_IDLE,W
	CLRM	@BUS_STEADY_Z,L

	movi	BUS_INIT,b0
	calla	MULTIMAKE
	jrz	wait_for_obj
	move	a8,@BUS_HEAD_OBJ,L

	MOVI	BUS_CRUISING_X,a9
	move	a9,*a8(OXVEL),L

	CREATE	PID_IND,BUS_GUN_MONITOR

	CLRM	@BUS_STATE,W
	move	a14,@SNOZZ_COUNT

	CREATE	PID_IND,BUS_SMARTS
	move	a0,*a8(OPLINK),L	; main bus intelligence


	SOUND1	SND_START_BUS

	JAUC	SCRL_DISPATCHER


SND_MY_WAY
	.word	0f3d0h,100,8833h,0

SND_HELGA_LAFF
	.word	0f3a0h,92,856ch,0

SND_START_BUS
	.word	0f390h,1,8552h,0

SND_BUS_BGND
	.word	0f330h,1,5553h,0

SND_BUS_BRAKE
	.word	0f290h,58,8554h,0

SND_SPDUP
	.word	0f350h,29,0a123h,0	; press the speedup control

SND_SLWDN
	.word	0f350h,29,0a120h,0	; press the slowdown control

SND_DESERT		      		
	.WORD	0F0FDH,1,0800aH,0

*
*	This process controls a pop up guy behind the window
*	a9 = X world offset from windo animation point
*	a10 = windo obj
*	a11 = Y world offset from windo animation point
BUS_POPUP:
*
*	DECIDE WHEN AND IF TO ATTACK 
*
	sleep	10
	move	*a10(OPART1),a0,L	; bus head
	move	*a0(OGUNSGONE),a14
	jrnz	skip_moslp
	RANDSLP	20,80
skip_moslp:
	move	*a10(OGUNVECT),a0,L	; can't shoot if window not
	jrz	nogunv
	cmpi	DUMRETS,a0		; destroyed
	jrne	BP_err	  

nogunv:
	move	@HOLD_ENEMY_DISPATCH,a14
	jrnz	BP_err

	move	*a10(OZVAL),a1,L
	move	@ZBASE,a14,L
	sub	a14,a1
	cmpi	011000h,a1		; don't pop unless somewhat
	jrgt	BP_err			; close

	move	*a10(OFLAGS),a14
	btst	B_OFSCRN,a14
	jrnz	BP_err			; don't pop up if offscreen

	movi	BUSPOP_INIT,b0
	calla	CREATE_ENEMY
	jrz	BP_err

	MOVK	M_WINDOW,A14		;SET TYPE
	MOVE	A14,*A8(OEFLAGS),W	;SAVE TYPE

	move	*a10(OZVAL),a1,L
	addk	20,a1
	move	a1,*a8(OZVAL),L

	move	*a10(OXVAL),a1,L
	add	a9,a1
	move	a1,*a8(OXVAL),L

	move	*a10(OYVAL),a1,L
	add	a11,a1
	move	a1,*a8(OYVAL),L
	MOVE	A1,*A8(OYSTART),L

	MOVK	1,A14
	MOVB	A14,*A8(OHITS)		;NUMBER OF ALLOWED HITS

	MOVI	127,A0			;RANDOM LIFE TIME
	MOVK	30,A1
	CALLA	RANGRAND
	SUBK	21,A0			;POPUP AND POPDOWN TIME
	MOVE	A0,*A8(OETIME),W

	CALLA	INSERT_ENEMY

	movi	-02b000h,a14		; yeah, pop up
	move	a14,*a8(OYVEL),L

	MOVIM	BUSPOP_DEATH,*a8(OEDEATH),L
					; force backwards death

	CREATE	PID_IND,MATCH_BUS
	move	a0,*a8(OPLINK),L

	sleep	90		; wait for attack and die

BP_err:	
	sloop	70,BUS_POPUP		; try again later	


*
*	This process is killed when popup guy is deleted
*
MATCH_BUS:
	move	*a10(OZVAL),a1,L	; keep same relative Z
	addk	20,a1
	move	a1,*a8(OZVAL),L

	move	*a10(OXVAL),a2,L	; keep same relative X
	add	a9,a2
	move	a2,*a8(OXVAL),L

	move	*a8(OPARTS),a0,L
	jrz	noflash
	
;	movb	*a0(OZOFF),a3
;	add	a1,a3
;	move	a3,*a0(OZVAL),L

	addi	25<<15,a2		; since guys are always flipped
	move	a2,*a0(OXVAL),L

noflash:
	sloop	1,MATCH_BUS		; nonboy death or popdown
					; breaks us out of here



*
*	This process monitors the two turrets and the midgun
*	
*	a10 = turret1
*	a9 = turret2
*	a8 = midgun
*
BUS_GUN_MONITOR:
	move	*a8(OPARTS),a8,L	; get objects in a8, a9 and a10
	movb	*a8(OPARTID),a0
	cmpk	PNUM_GUN,a0
	jrne	BUS_GUN_MONITOR

	move	*a8(OPARTS),a9,L
	move	*a9(OPARTS),a10,L
	move	a10,a11
FindDoor:
	move	*a11(OPARTS),a11,L	; Find door parts
	movb	*a11(OPARTID),a0
	cmpk	PNUM_DOOR,a0
	jrne	FindDoor
	move	*a11(OPARTS),a0,L
	move	a0,*a11(OTHRHAF),L
	move	a11,*a0(OTHRHAF),L	; xlink door parts
	clr	a14
	move	a14,*a0(ONONTHR),L	; init thrower obj field
	move	a14,*a11(ONONTHR),L	; 

BGM_1:
	move	a8,a0			; has object been destroyed?
	jrz	BGM_2			;    skip if yes
	move	*a8(OGUNVECT),a14,L	; has gunvect been cleared?
	jrnz	BGM_2			;    process if no
	clr	a8			;    else signal object destroyed

BGM_2:
	sleep	2
	move	a9,a0		       	; has object been destroyed?
	jrz	BGM_3		       	;    skip if yes
	move	*a9(OGUNVECT),a14,L    	; has gunvect been cleared?
	jrnz	BGM_3		       	;    process if no
	clr	a9		       	;    else signal object destroyed

BGM_3:
	sleep	2
	move	a10,a0		       	; has object been destroyed?
	jrz	BGM_lp		       	;    skip if yes
	move	*a10(OGUNVECT),a14,L    	; has gunvect been cleared?
	jrnz	BGM_lp		       	;    process if no
	clr	a10		       	;    else signal object destroyed

BGM_lp:
	move	a8,a0		        ; check for all guns destroyed
	or	a9,a0
	or	a10,a0
	jrz	BGM_die
	sloop	2,BGM_1			; if not, loop back
*
*	GET HERE ONLY IF ALL 3 GUNS ARE GONE!
*	(increase frequency of pop ups)
*
BGM_die:
	move	@BUS_HEAD_OBJ,a0,L
	MOVKM	1,*a0(OGUNSGONE),W	; set this flag for popups
	DIE


*
*	The bus does this...
*	Normally goes at a steady speed.
*	When a piece breaks, it slows or speeds to get away from player
*	If away from player too long, it tries to catch up to player
*			and wails on him for a period of time
*
*	BUS_STATE = variable with 3 values...
*			0 = go my normal speed
*			-1 = get away from player
*			1 = stick with player
*
*	a8 = bus object
*	a9 = how long before catching up to player
*	a10 = get away choice (0 none made, 1 fwd, -1 rev)
*	a11 = how long we been trying to get away or catch up
*
BUS_SMARTS:
	sleep	300
	movi	40,a9		; this many ticks before we try to catch up
	clr	a10
	clr	a11
BUS_SMRT_LP:
	move	*a8(OXVEL),a1,L
	move	@BUS_STATE,a0		; branch based on current state
	jrz	check_catchup
	jrn	get_away
*
*	STATE = 1  Catch up to player
*
	move	*a8(ODAGX),a3		; want to get between 30 and 300
	subk	30,a3
	cmpi	270,a3
	jrls	get_norm		; if within range, steady speed
	jrn	inc_speed
	subi	BUS_ACCEL,a1
	cmpi	BUS_CATCHUP_MIN,a1	; can't let speed drop past min.
	jrlt	too_small2
	move	a1,*a8(OXVEL),L
too_small2:
	sloop	1,BUS_SMRT_LP
*
*	STATE = 0  Normal (should we catch up to player?)
*
check_catchup:
	move	*a8(ODAGX),a3
	cmpi	-70,a3
	jrlt	catchup
	cmpi	470,a3
	jrgt	catchup
	jruc	norm

catchup:
	inc	a11
	cmp	a9,a11
	jrlt	norm
	movi	70,a9		; this many ticks before we try to catch up
	MOVKM	1,@BUS_STATE,W		; catch up with player
	sloop	1,BUS_SMRT_LP

*
*	Get to cruising speed
*
get_norm:
	clr	a11
	clr	a10
	move	a10,@BUS_STATE
	move	@XSCROLL,a14,L
	move	a14,*a13(PDATA),L	; save speed for bus to match
norm:
	move	*a13(PDATA),a2,L		; bus tries to match player
	sub	a1,a2
	neg	a2
;	move	a1,a2			; OLD
;	subi	BUS_CRUISING_X,a2	; OLD
	jrlt	speed_up
	cmpi	BUS_ACCEL,a2
	jrgt	dec_speed
	sloop	1,BUS_SMRT_LP

dec_speed:
	subi	BUS_ACCEL,a1
	cmpi	BUS_MIN_SPD,a1		; can't let speed drop past min.
	jrlt	never_neg
	move	a1,*a8(OXVEL),L
never_neg:
	sloop	1,BUS_SMRT_LP

speed_up:
	abs	a2
	cmpi	BUS_ACCEL,a2
	jrgt	inc_speed
	sloop	1,BUS_SMRT_LP

inc_speed:
	addi	BUS_ACCEL,a1
	move	@XSCROLL,a14,L		; bus can't go faster than 
	addi	40000h,a14		; 40000h more than us
	cmp	a14,a1
	jrgt	too_fast
	move	a1,*a8(OXVEL),L
too_fast
	sloop	1,BUS_SMRT_LP

*
*	Get away from player
*
get_away:
	movi	90,a9		; this many ticks before we try to catch up
	cmpi	100,a11		; if we've been trying too long
	jrge	get_norm	; give up
	move	*a8(ODAGX),a3
	move	a10,a10
	jrn	slow_away
	jrz	make_choice

; made the choice to speed up

	movi	150<<16,a5	; DAG of bus center
	move	*a8(OZVAL),a4,L
	move	@ZBASE,a14,L
	sub	a14,a4		; world Z
	divu	a4,a5
	sub	a5,a3		; screen offset of bus back

	cmpi	350,a3 
	jrge	get_norm
	inc	a11
	jruc	inc_speed

; made the choice to slow down

slow_away:
	movi	150<<16,a5	; DAG of bus center
	move	*a8(OZVAL),a4,L
	move	@ZBASE,a14,L
	sub	a14,a4		; world Z
	divu	a4,a5
	add	a5,a3		; screen offset of bus front

	cmpi	50,a3
	jrle	get_norm
	inc	a11
	jruc	dec_speed

make_choice:
	clr	a11
	cmpi	(BUS_MIN_SPD+10000h),a1		; if speed is slow,
	jrlt	choose_fwd			;   choose fwd
	cmpi	(BUS_MAX_SPD-10000h),a1		; if speed is fast
	jrgt	choose_bak			;   choose bak
	cmpi	210,a3		; otherwise choice is based on which side of
	jrgt	choose_fwd	; screen bus is on
choose_bak:
	SOUND1	SND_BUS_BRAKE
	dec	a10
	jruc	dec_speed

choose_fwd:
	SOUND1	SND_START_BUS
	movk	1,a10
	jruc	inc_speed


*
*	When bus reaches end, it slows to a stop with the player
*
S_PLAYER_BLEW_IT:
	MOVKM	1,@HOLD_ENEMY_DISPATCH,W	; stop guys on bus

	move	@BUS_HEAD_OBJ,a0,L
	move	*a0(OPLINK),a1,L	; bus smarts process
	MOVIM	BUS_END_SMARTS,*a1(PWAKE),L
	jauc	SCRL_DISPATCHER

*
*	When bus reaches end of wave, it decelerates to a certain
*	point
*
BUS_END_SMARTS:
*
*	compute bus deceleration
*
	move	@BUS_STOP_X,a11,L
	move	@XBASE,a14,L  
	sub	a14,a11	      		; world distance in a11
	movi	TO_END_TIKS,a0
	movi	TO_END_TIKS*TO_END_TIKS,a2
;	move	*a8(OXVEL),a1,L		; vel in a1
;	mpys	a0,a1			; vt in a1
;	sub	a1,a11			; d-vt in a11
	sll	1,a11
	divs	a2,a11			; 2d/t**2 in a11
	move	a11,a1
	mpys	a0,a1
	move	a1,*a8(OXVEL),L		; stuff needed velocity
	neg	a11

*
*	get pretty slow
*
bus_slowing:
	move	*a8(OXVEL),a1,L
	add	a11,a1
	move	a1,*a8(OXVEL),L
	cmpi	28000h,a1
	jrle	bus_slowed
	sloop	1,bus_slowing

bus_slowed:
	move	a8,a0			; stop tire rotation
f_tire:
	move	*a0(OPARTS),a0,L
	jrz	outaparts
f_nxt_tire:
	movb	*a0(OZOFF),a14
	addk	2,a14
	jrnz	f_tire

	MOVKB	3,*a0(AnimSLP)
	movi	btirerotSlow,a1	 	; get tires rotating slower 
	move	a1,*a0(AnimScr),L
	PUSHP	a0 			; save obj block for later

	move	*a0(OPARTS),a0,L
	jrnz	f_nxt_tire
outaparts:

	sleep	1

bus_stopping:
	move	*a8(OXVEL),a1,L
	add	a11,a1
	jrle	bus_stopped
	move	a1,*a8(OXVEL),L
	sloop	1,bus_stopping

bus_stopped:
	SOUND1	SND_MUSICOFF

	MOVIM	1,@GUNS_OFF,W		;turn off guns

	ALLPLYR	PCURSOR_OFF

	PULLPQ	a0			; stop tires from rotating
	calla	PULLANIM
	PULLPQ	a0
	calla	PULLANIM
	PULLPQ	a0
	calla	PULLANIM

	CLRM	*a8(OXVEL),L

	CLRM	*a8(OPLINK),L

	sleep	25

	SOUND1	SND_BLEWIT_RIFF

	MOVI	BUSNOFADE,A0
	CALLA	FADE_FULL2HALF		;DROP THE PLAYFIELD BRIGHTNESS

	sleep	30

	MOVI	BLEWMESS,A8
	JSRP	LM_PRINTF

	sleep	130

	SOUND1	SND_HELGA_LAFF

	sleep	50
	JAUC	WAVE_RESET


SND_MUSICOFF
	.WORD	0F0FFH,1,083E3H,0		;TURN JUST MUSIC OFF

SND_BLEWIT_RIFF
	.WORD	0F0FDH,240,08016H,0		;Sweet emotion direct start

BLEWMESS:
	MESS_MAC RD20FONT,2,197,43+SKYTOPOF,COLOR_PRED,STRCNRMOS,OID_GAMEOVER
	.STRING	"YOU BLEW IT!\nThanks to you, another\n50 innocents will perish!\n"
	.STRING "TRY AGAIN!"
	.EVEN




*****************************************************************
*								*
*                    COLLISION HANDLERS				*
*								*
*****************************************************************

BUS_CVECT
	WWL	OID_PROCKET,~MASK_PLAYER,BUS_ROCKET_COLL
	WWL	OID_PEXPLOSION,~MASK_PLAYER,BUS_COLLVECT
DUMCVECT
	WL	0,DUMCRETS

BUS_GRND_CVECT
	WWL	OID_GRND,0FFFFH,BUS_GRND_COLL
	WL	0,DUMCRETS


BUS_GRND_COLL
	CLRM	*a8(OYVEL),L
	move	a14,*a8(OYACCEL)
	calla	COLLS_OFF

	movk	6,a9			; y range (+/-)
	CREATE	PID_IND,GROUND_SHAKE

	rets

*
*	a9 is the pixel range to adjust YHALF (+/-)
*	a10 is the world range to adjust DPYST (+/-)
*
GROUND_SHAKE
	move	@DPYST,a8,L
	andi	0fffh,a8
	movk	6,a10
	movk	20,a11			; number of iterations
	CREATE	PID_IND,GROUND_SHAKE_X
	move	@YHALF,a8
GROUND_SHAKE_Y:
	move	a9,a0
	calla	RANDU
	inc	a0
	add	a8,a0
	move	a0,@YHALF

	sleep	1

	move	a9,a0
	calla	RANDU
	inc	a0
	neg	a0
	add	a8,a0
	move	a0,@YHALF

	sleep	1

	dsj	a11,GROUND_SHAKE_Y

	move	a8,@YHALF

	DIE


GROUND_SHAKE_X:
	move	@DPYST,a3,L
	srl	12,a3
	sll	12,a3
	move	a10,a0
	calla	RANDU
	inc	a0
	sll	5,a0
	add	a8,a0
	add	a3,a0
	move	a0,@DPYST,L
	
	sleep	1

	move	@DPYST,a3,L
	srl	12,a3
	sll	12,a3
	move	a10,a0
	calla	RANDU
	inc	a0
	sll	5,a0
	neg	a0
	add	a8,a0
	add	a3,a0
	move	a0,@DPYST,L

	sleep	1

	dsj	a11,GROUND_SHAKE_X

	move	a10,@DPYST,L
	DIE



TIRE_GRND_CVECT
	WWL	OID_GRND,0FFFFH,TIRE_GRND_COLL
	WL	0,DUMCRETS

TIRE_GRND_COLL
	move	*a8(OPART1),a0,L
	move	*a8(OYVEL),a1,L
	jrn	goin_up		; ignore if bus flying up

	movi	TIRE_FLY_ANIM,a1
	move	a1,*a8(AnimScr),L
	callr	TIRE_FLY_AWAY
goin_up:
	rets


**************************************************************************
*								         *
* 	BUS_ROCKET_COLL							 *
* 									 *
* 	Collision vector for any BUS part and a player rocket.		 *
* 									 *
* 	A0 = Ptr to rocket						 *
* 	A8 = Ptr to BUS part						 *
*								         *
**************************************************************************
BUS_ROCKET_COLL
	MOVB	*A8(OATEROCKET),a14	;Flag for the explosion
	jrnz	BRC_X			; already ate one
	MOVE	*A0(RL_INTENDED_OBJ),A14,L
	CMP	A14,A8			;Is this the object we are after?
	JRNE	BRC_X			;BR = No
	MOVK	1,A14
	MOVB	A14,*A8(OATEROCKET)	;Flag for the explosion
BRC_X
	RETS

BUS_COLLVECT:
	move	@WAVEIRQS,a5		; current IRQ num
	move	*a8(ONODAMTIM),a14
	jrz	ok2damage0
	sub	a5,a14
	addi	50,a14	  		; ignore if damage sustained
	jrnn	BUS_GV_XIT		; within last 50 tiks
	CLRM	*a8(ONODAMTIM),W

ok2damage0:
	MOVB	*A8(OATEROCKET),A14
	JRZ	BUS_GV_XIT		;BR = We really didn't take it
	CLRM	*A8(OATEROCKET),W	;Reset for next rocket

	move	*a8(OROCKTIM),a14	; int num of last rocket
	sub	a5,a14	
	addk	8,a14
	jrnn	BUS_GV_XIT		; if we're within 8 ticks, no way
	move	a5,*a8(OROCKTIM)

	MOVE	*A0(OID),A0,W		; GET PLAYER DATA ADDRESS
	CALLA	POID_TO_PDATA		; GET PDATA IN A2

	SOUNDZ	SND_HIT_BY_ROCKET

	move	*a8(OBDAMTBL),a5,L	; if 0, no more damage
	jrz	BUS_GV_CLR

	movk	1,a7			; identify this as a rocket hit
	move	*a8(OROKCNT),a4
	inc	a4
	move	a4,*a8(OROKCNT)
	move	*a5(10h),a0		; hits needed to advance destruction
	calla	CURPLYR_ADJ		; adjust based on num players
	cmp	a0,a4
	jrge	BCV0

	calla	UNIV_FLASH
	rets

BCV0:
	MMTM	SP,B1,B2,B4,B5,B6,B8,B9,b10	 ; must save B regs
	callr	BUS_PART_HIT			 ; on a rocket hit
	MMFM	SP,B1,B2,B4,B5,B6,B8,B9,b10	 ; (but not a gun hit)
	rets

TURRET_GUNVECT:
	move	*a8(OPLINK),a4,L
	move	*a4(PA9),a0
	cmpk	1,a0			; is turret firing?
	jrne	BUS_GV_XIT


BUS_GUNVECT:
	move	@WAVEIRQS,a5		; current IRQ num
	move	*a8(ONODAMTIM),a14
	jrz	ok2damage1
	sub	a5,a14
	addi	50,a14			; ignore if damaged within last 50 tiks
	jrnn	BUS_GV_XIT
	CLRM	*a8(ONODAMTIM),W

ok2damage1:
	move	*a8(OBDAMTBL),a5,L	; if 0, no more damage
	jrz	BUS_GV_CLR

	clr	a7			; identify this as a bullet hit
	move	*a8(OBULCNT),a4
	inc	a4
	move	a4,*a8(OBULCNT)
	move	*a5,a0			; hits needed
	calla	CURPLYR_ADJ		; adjust based on num players
	cmp	a0,a4
	jrge	BUS_PART_HIT

	calla	UNIV_FLASH

	movk	5,a0
	movi	BUS_HIT_TAB,a1
	calla	TAB_SOUND

BUS_GV_XIT:
	rets

BUS_GV_CLR:
	calla	COLLS_OFF
;;;;	calla	PULL_SUPP		; do we need to do this?
	rets

BUS_HIT_TAB	
	.long	BUSHIT_S1,BUSHIT_S2,BUSHIT_S3,BUSHIT_S4,BUSHIT_S5

BUSHIT_S1	.word	0f334h,59,0a138h,0
BUSHIT_S2	.word	0f334h,56,0a135h,0
BUSHIT_S3	.WORD	0F334H,29,0A111H,0
BUSHIT_S4	.WORD	0F334H,59,0A147H,0
BUSHIT_S5	.WORD	0F334H,68,0A14aH,0



*
*	OBDAMTBL in a5
*	a7 = 0 if bullet hit, 1 if rocket hit
*	OBJ in a8
*
BUS_PART_HIT:
	addk	20h,a5		; get OBDAMTBL past hit counts
	move	@WAVEIRQS,a14
	move	a14,*a8(ONODAMTIM)	; lockout damage for a while
	move	*a5+,a1,L	; next img (seq)
	jrz	BPH_nochg
	move	*a8(OFLAGS),a14
	btst	0,a1		; is this a seq?
	jrz	BPH_noseq
*
*	New image IS animating
*
	move	a1,a4		; save flags
	srl	4,a1
	sll	4,a1		; clear flag bits
	btst	B_ANIM,a14	; was it animating?
	jrz	BPH_img2seq
	btst	1,a4		; if seq-to-seq, should we swap them?
	jrz	BPH_nosync
	move	*a8(AnimFrm),a14,L	; sync old seq to new one
	move	*a8(AnimScr),a3,L
	sub	a3,a14
	add	a1,a14
    	move	a14,*a8(AnimFrm),L
    	move	a1,*a8(AnimScr),L
BPH_getimg:
	move	*a14,a1,L	; get img
	jrz	BPH_frstimg	; ok if not 0
	cmpk	1,a1
	jrne	BPH_img2img
	subi	50h,a14		; ASSUMPTION HERE! (entries preceding ones
				; where the img is 1 consist of LWL)
	jruc	BPH_getimg

BPH_frstimg:
	srl	4,a4		; if at end of seq, get first img
	sll	4,a4
	move	*a4,a1,L
	jruc	BPH_img2img	; change image

BPH_nosync:
    	move	a1,*a8(AnimFrm),L
    	move	a1,*a8(AnimScr),L
	move	*a1,a1,L	; get img
	jruc	BPH_img2img	; change image

BPH_img2seq:
	calla	STRT_ANIM
	jruc	BPH_chkpal
*
*	New image is not animating
*
BPH_noseq:
	btst	B_ANIM,a14	; was it animating?
	jrz	BPH_img2img
	calla	PULL_ANIM	; PULL IT if it was
BPH_img2img:
	move	*a8(OCTRL),a4
	calla	ANI
	move	*a8(OSCALEX),a14	; force rescaling
	addk	4,a14
	move	a14,*a8(OSCALE)

BPH_chkpal:
	move	*a8(OIMG),a14,L
	move	*a14(ICMAP),a0,L
	calla	CHANGE_PAL_CHECK	; change pal if neccessary

BPH_nochg:
	move	*a5+,a6,L	; routine to call
	btst	0,a6		; bus reacts?
	jrz	BPH_no
	clr	a14
	dec	a14
	move	a14,@BUS_STATE
BPH_no:
	srl	1,a6
	sll	1,a6
	jrz	BPH_noexec	; if 0, there ain't none
	call	a6
BPH_noexec:
	move	*a5,a4,L	; next rocket,bullet hit count
	jrn	BPH_lastdam
	move	a5,*a8(OBDAMTBL),L	; store new damtbl ptr
	CLRM	*a8(OBULCNT),L		; reset hit counts
	movi	1000,a1
	calla	SCORE
	rets

BPH_lastdam:
	clr	a5
	move	a5,*a8(OBDAMTBL),L

	MOVIM	DUMRETS,*a8(OGUNVECT),L
	MOVIM	DUMCVECT,*a8(OCVECT),L

	movi	5000,a1
	calla	SCORE

	move	*a8(OIMG),a14,L
	cmpi	WSTEPd,a14		; this piece doesn't count
	jreq	BPH_skip

	move	@BUS_HEAD_OBJ,a0,L
	move	*a0(OTOTHITS),a1	; number of destroyed pieces
	inc	a1
	move	a1,*a0(OTOTHITS)
*
*	CHECK TO SEE IF BUS IS TOTALLY GONE!
*
	cmpk	23,a1
	jrlt	BPH_skip
*
*	BUS BLOWUP!!!
*
	MOVKM	1,@HOLD_ENEMY_DISPATCH,W	; stop coggers
	move	a0,a4
BPH_elp
	move	a4,a0
	calla	CKPULLANIM
	move	*a4(OPLINK),a0,L	; go thru bus and stop all anims
	jrz	BPH_noproc		; and kill all processes
	CLRM	*a4(OPLINK),L
	calla	KILL
BPH_noproc:
	move	*a4(OPARTS),a4,L
	jrnz	BPH_elp

	CREATE	PID_IND,BUS_BLOWUP_PROC
	CREATE	PID_IND,MOVE_CTRLS_UP
	movi	BUS_END_SCROLL,a0
	calla	CHNG_SCRL_TBL

	move	@SCROLL_PROCESS,a0,L
	CLRM	*a0(PUSHCNT),L		; Crude way to pop us from scroll sub

BPH_skip:
	rets


BUS_END_SCROLL:
	.long	S_KILL_ALT_SCROLL

	.LONG	S_KILL_POWERUPS			;Whack those powers

	.LONG	S_CREATE_PROC
	.word	PID_IND
	.long	BUS_SYNC_PROC		; sync player to bus

	.LONG	S_CLR_ZMOTION

	.LONG	S_BUS_GOTO_ZPT
	.word	30		; how long
	.long	010000h		; WZ
	.word	0		; ticks to sleep

	.LONG	S_WAIT_FOR_BUS_GONE

	LLW	S_SET_WORD, GAME_STATE, INGAME

	.LONG	S_WAIT_HERE
	.WORD	90

	.LONG	S_SOUND,SND_SCHOOLZOUT

	.LONG	S_WAIT_HERE
	.WORD	90

	.LONG	S_SOUND,SND_SWEET_EMOTION

	LW	S_AUDIT, AUDMIEND

	LLW	S_SET_WORD, BONUS_DIRECTION, 2	; END THE WAVE

	.LONG	S_CREATE_PROC
	.word	PID_IND
	.LONG	WAVE_END_IMM			;Force the wave to end

	.long	0

SND_SCHOOLZOUT
	.word	0f390h,47,8835h,0

S_WAIT_FOR_BUS_GONE:
	move	@BUS_HEAD_OBJ,a8,L
WaitGonelp:
	move	*a8(OCTRL),a14
	btst	B_INUSE,a14
	jaz	SCRL_DISPATCHER		; leave when bus gets deleted

	sloop	4,WaitGonelp


*
*	Gets player in sync with bus and come to a stop
*
BUS_SYNC_PROC
	clr	a14
	move	a14,@BUS_STEADY_Z,L

	move	@BUS_HEAD_OBJ,a9,L
	CLRM	*a9(OZVEL),L

	CREATE	PID_IND,SLOW_BUS_TO_STOP
BES_synclp:
	sleep	1
	move	*a9(ODAGX),a0
	move	a0,a1
	subi	150,a0
	cmpi	100,a0
	jrls	in_sync

	cmpi	200,a1
	jrgt	wait_4_it
*
*	bus is in right half
*
	move	@XSCROLL,a0,L
	subi	PLYR_ACCEL,a0,L
	move	a0,@XSCROLL,L
wait_4_it:
	sloop 	1,BES_synclp

in_sync:
	move	*a9(OXVEL),a0,L
	move	a0,@XSCROLL,L		; bus's velocity becomes scroll rate
	jaz	SUCIDE			; leave when got to a stop
	sloop	1,in_sync



SLOW_BUS_TO_STOP:
	move	*a9(OXVEL),a4,L
	cmpi	BUS_ACCEL,a4
	jrlt	SBTS_clr
	subi	BUS_ACCEL,a4
	move	a4,*a9(OXVEL),L		; slow bus to a stop
	sloop	1,SLOW_BUS_TO_STOP

SBTS_clr:
	clr	a4
	move	a4,*a9(OXVEL),L
	DIE



*
*	1) Turn guns off
*	2) make the wheels fly
*	3) start explosions inside the bus
*	4) start explosions outside the bus
*	5) send out fragments
*	7) have the body of the bus fly up and land with a thump
*	8) have the pieces disperse
*
BUS_BLOWUP_PROC
	sleep	14
 	move	@BUS_HEAD_OBJ,a8,L
	MOVIM	-0c0000h,*a8(OYVEL),L
	MOVIM	7800h,*a8(OYACCEL),W
	MOVIM	BUS_GRND_CVECT,*a8(OCVECT),L
	ORIM	M_GCOLL,*a8(OFLAGS),W
	MOVIM	-(14<<16),*a8(OGRNDOFF),L

	movi	100,a5
find_inner:
	move	*a8(OPARTS),a8,L
	movb	*a8(OZOFF),a14
	cmp	a5,a14
	jrlt	find_inner
	move	a8,a11			; save inner

	MOVIM	1,@GUNS_OFF,W		;turn off guns


find_tire:
	move	*a8(OPARTS),a8,L
	jrz	nomotires
find_nxt_tire:
	movb	*a8(OZOFF),a14
	jrnn	find_tire

	MOVIM	TIRE_GRND_CVECT,*a8(OCVECT),L
	ORIM	M_GCOLL,*a8(OFLAGS),W
	CLRM	*a8(OGRNDOFF),L
	MOVIM	9*2,*a8(OPARTSXY+10h),W

	move	*a8(OPARTS),a8,L
	jrnz	find_nxt_tire

nomotires:

	sleep	45

	move	a11,a8			; restore inner
	movi	30,a9
inside_lp:
	clr	a3
	movi	(135-200)<<16,a0
	movi	(118-200)<<16,a1
	calla	RANGERND
	move	a0,a2			; Y off in a2
	
	movi	(70-200)<<16,a0
	movi	(222-200)<<16,a1
	calla	RANGERND		; X off in a0
	move	a0,a1

	calla	MAKE_EXPLO_OFF

	movk	3,a0
	movi	FINAL_EXPLO_TAB,a1
	calla	TAB_SOUND

	RANDSLP	1,4

	dsj	a9,inside_lp

 	move	@BUS_HEAD_OBJ,a0,L
	movi	BUS_FINAL_EXPLO,a1
	calla	STRTANIM

 	move	@BUS_HEAD_OBJ,a0,L
	movi	BUS_PART_EXPLOSIONS,a1
loopy:
	move	*a0(OPARTS),a0,L
	jrz	done
	movb	*a0(OPARTID),a14
	cmpk	PNUM_WNDO,a14
	jrge	done
	cmpk	PNUM_WSTEP,a14
	jreq	done
	calla	STRTANIM
	jruc	loopy
done:

	DIE

BUS_PART_EXPLOSIONS
	LW	1,60
	LWLW	1,1|AFunc,A_Set_AnimLoop+1,7
BPE_LOOP
	LWLLLL	1,1|AFunc,A_PreFrag_Center+6,BUS_EXPLOSION_SMALL,020h,10000h
	LWLWW	1,1|AFunc,A_RAND_AnimSLP+2,10,15
	LWLL	1,0|AFunc,A_Anim_DSJ+2,BPE_LOOP
	LWL	1,1|AFunc,PULL_ANIM


BUS_FINAL_EXPLO
	LWLW	1,1|AFunc,A_Set_AnimLoop+1,10
AFE_CRAFT_BLOW
	LWLLLL	1,1|AFunc,A_PreFrag_Center+6,BUS_EXPLOSION,0400h,40000h
	LWLWW	1,1|AFunc,A_RAND_AnimSLP+2,5,10
	LWLL	1,0|AFunc,A_Anim_DSJ+2,AFE_CRAFT_BLOW

	LWLL	1,1|AFunc,A_SOUND+2,SND_FINAL_EXPLODE3
	LWLLLL	1,1|AFunc,A_PreFrag_Center+6,FRAG_DESK_EXPLOSION,01000h,80000h
	LWLL	1,1|AFunc,A_SOUND+2,SND_FINAL_EXPLODE2
	LWLLLL	1,1|AFunc,A_PreFrag_Center+6,FRAG_DESK_METAL,01000h,80000h

	LWLLLL	1,40|AFunc,A_PreFrag_Rain+6,FRAG_DESK_RAIN,80H,40000H

	LWLL	1,1|AFunc,A_SOUND+2,SND_MUSICOFF

	LWLL	1,2|AFunc,A_SOUND+2,SND_FINAL_EXPLODE1

	LWL	1,50|AFunc,OBJ_OFF_MULTI

	LWL	1,1|AFunc,DELETE_OBJ


FINAL_EXPLO_TAB:
	.long	SND_FINAL_EXPLODE1,SND_FINAL_EXPLODE2,SND_FINAL_EXPLODE3


BTIRE_GUNVECT:
	rets


SND_BUS_FIRE
	.WORD	0F310H,39,0A328H,0	;BUS fire sound
SND_TURRET_SPIN
	.WORD	0F341H,10,0A42FH,0	;Turret spin
SND_TURRET_HIT

	.WORD	0F341H,56,0A135H,0	;Turret takes a CD hit
SND_HIT_BY_ROCKET
	.WORD	0E340H,60,0A38DH,0	;BUS takes a hit by the players rocket
SND_PART_EXPLO
	.WORD	0E342H,80,0A390H,0	;BUS part explodes
SND_WINDO_BRK
	.word	0E342H,53,0a3c5h,0	;WINDOW SHATTERS


C_INIT_MIDGUN:
	move	a8,a3
	move	a7,a4
	move	a0,a8
	CREATE	PID_IND,MON_MIDGUN
	move	a8,a0
	move	a3,a8
	move	a4,a7
	jruc	C_INIT_BUS_PART

C_INIT_TURRET:
	MOVIM	175,*a0(OTURIDLE),W	; initial max idle time
	move	a8,a3
	move	a7,a4
	move	a0,a8
	CREATE	PID_IND,MON_TURRET
	move	a8,a0
	move	a3,a8
	move	a4,a7
	jruc	C_INIT_BUS_PART

C_INIT_BUS_WINDO:
	MMTM	sp,a7,a9,a10,a11
	move	a0,a10
	movi	61<<16,a11
	clr	a9
	CREATE	PID_IND,BUS_POPUP
	move	a0,*a10(OPLINK),L	; link process with windo
	move	a10,a0
	MMfM	sp,a7,a9,a10,a11

C_INIT_BUS_PART:
	MOVI	0101h,A14
	MOVE	A14,*A0(OCONST),W

	move	@WAVEIRQS,a5		; current int num
	move	a5,*a0(OROCKTIM)


	clr	a14
	move	a0,a1
	addi	ODATA,a1
	move	a14,*a1+,L	; clear 2 words
	move	a14,*a1+,L	; clear 2 words
	move	a14,*a1+,L	; clear 2 words

	move	*b0+,b14,L
	move	b14,a1		; damage table
	move	a1,*a0(OBDAMTBL),L
	CLRM	*a0(OBULCNT),L

	RETS




BUS_INIT
	.byte	30, 0, 0, 10	;OBJCNT, PRCCNT, IMGPALCNT, PALCNT
	.long	WINDOGR_P,BUSTAG1_P,BDOOR_P,BTIROT_P,BUSWIND_P
	.long	INNERB_P,MIDGUN_P,ROOFB_P,BHOOD_P,BTURRET_P
	.word	OID_BUS, OM_COLL | (OM_WPOS | OM_GRND) | OM_INSERT
			     ; world position, call INSERT_OBJ when done
	.long	BUS_CVECT
	.long	-1800000h,0H,10000h	; X,Y,Z  
;	.long	0000h,0H,10000h	; X,Y,Z  
*
*    .long IMG
*    .word DMAFLAGS, OFLAGS, OZOFF, OPTION_BITS
*
       LWWWW	PANELA, DMAWNZ, M_DBLSCL|M_NOPARTANI, 0, OM_GUNV|OM_CFUNC
       .long	BUS_GUNVECT
	.long	C_INIT_BUS_PART,PAN_DAM
       LWWWW	AXELA1, DMAWNZ, M_DBLSCL|M_NOPARTANI, 0, OM_CFUNC|OM_PRVGUNV
	.long	C_INIT_BUS_PART,AX1_DAM
       LWWWW	AXELA2, DMAWNZ, M_DBLSCL|M_NOPARTANI, 0, OM_CFUNC|OM_PRVGUNV
	.long	C_INIT_BUS_PART,AX2_DAM
       LWWWW	TAILA, DMAWNZ, M_DBLSCL|M_NOPARTANI, 0, OM_CFUNC|OM_PRVGUNV
	.long	C_INIT_BUS_PART,TAIL_DAM
       LWWWW	CAPA, DMAWNZ, M_DBLSCL|M_NOPARTANI, 0, OM_CFUNC|OM_PRVGUNV
	.long	C_INIT_BUS_PART,CAP_DAM
       LWWWW	DORPA, DMAWNZ, M_DBLSCL|M_NOPARTANI, 0, OM_CFUNC|OM_PRVGUNV
	.long	C_INIT_BUS_PART,DORP_DAM
PNUM_WSTEP  .set	7
       LWWWW	WSTEP, DMAWNZ, M_DBLSCL|M_NOPARTANI, 0, OM_CFUNC|OM_PRVGUNV
	.long	C_INIT_BUS_PART,STEP_DAM
       LWWWW	ENGINEA, DMAWNZ, M_DBLSCL|M_NOPARTANI, 0, OM_CFUNC|OM_PRVGUNV
	.long	C_INIT_BUS_PART,ENG_DAM
       LWWWW	HOODBASIC, DMAWNZ, M_DBLSCL|M_NOPARTANI, -1, OM_CFUNC|OM_PRVGUNV|OM_OPARTS
       .word	128*2,-81*2
	.long	C_INIT_BUS_PART,HOOD_DAM
PNUM_GUN  .set	10
       LWWWW	MIDGUN1, DMAWNZ, M_DBLSCL|M_NOPARTANI, 0, OM_CFUNC|OM_GUNV
       .long	TURRET_GUNVECT
	.long	C_INIT_MIDGUN,MIDG_DAM

       LWWWW	BTURRET03, DMAWNZ, M_DBLSCL|M_NOPARTANI, 0, OM_CFUNC|OM_PRVGUNV|OM_ANIM|OM_OPARTS
       .word	-4*2,-114*2
       .long	BTURRET_IDLE
       .long	C_INIT_TURRET,TUR_DAM
       LWWWW	BTURRET03, DMAWNZ, M_DBLSCL|M_NOPARTANI, 0, OM_CFUNC|OM_PRVGUNV|OM_ANIM|OM_OPARTS
       .word	-103*2,-114*2
       .long	BTURRET_IDLE
       .long	C_INIT_TURRET,TUR_DAM

       LWWWW	ROOFBASE, DMAWNZ, M_DBLSCL|M_NOPARTANI, 0, OM_CFUNC|OM_GUNV|OM_OPARTS
       .word	-49*2,-95*2
	.LONG	BUS_GUNVECT
	.long	C_INIT_BUS_PART,ROOF_DAM
       LWWWW	ROOFBASE, DMAWNZ|M_FLIPH, M_DBLSCL|M_NOPARTANI, 0, OM_CFUNC|OM_PRVGUNV|OM_OPARTS
       .word	-49*2,-95*2
	.long	C_INIT_BUS_PART,ROOF_DAM

PNUM_DOOR  .set	15
       LWWWW	BDOOR1, DMAWNZ, M_DBLSCL|M_NOPARTANI, -1, OM_CFUNC|OM_PRVGUNV|OM_OPARTS|OM_ANIM
       .word	63*2,-18*2
       .long	BDROPEN
	.long	C_INIT_BUS_PART,DOOR_DAM
       LWWWW	BDOOR1, DMAWNZ|M_FLIPH, M_DBLSCL|M_NOPARTANI, -1, OM_CFUNC|OM_PRVGUNV|OM_OPARTS|OM_ANIM
       .word	63*2,-18*2
       .long	BDROPEN
	.long	C_INIT_BUS_PART,DOOR_DAM

PNUM_WNDO  .set	17
       LWWWW	BUSWINDO, DMAWNZ, M_DBLSCL|M_NOPIXSCAN|M_NOPARTANI, 0, OM_CFUNC|OM_PRVGUNV|OM_OPARTS
       .word	-124*2,-61*2
	.long	C_INIT_BUS_WINDO,WIND_DAM
       LWWWW	BUSWINDO, DMAWNZ, M_DBLSCL|M_NOPIXSCAN|M_NOPARTANI, 0, OM_CFUNC|OM_PRVGUNV|OM_OPARTS
       .word	-88*2,-61*2
	.long	C_INIT_BUS_WINDO,WIND_DAM
       LWWWW	BUSWINDO, DMAWNZ, M_DBLSCL|M_NOPIXSCAN|M_NOPARTANI, 0, OM_CFUNC|OM_PRVGUNV|OM_OPARTS
       .word	-11*2,-61*2
	.long	C_INIT_BUS_WINDO,WIND_DAM
       LWWWW	BUSWINDO, DMAWNZ, M_DBLSCL|M_NOPIXSCAN|M_NOPARTANI, 0, OM_CFUNC|OM_PRVGUNV|OM_OPARTS
       .word	26*2,-61*2
	.long	C_INIT_BUS_WINDO,WIND_DAM
       LWWWW	WINDOGRATE1, DMAWNZ, M_DBLSCL|M_NOPARTANI, -1, OM_CFUNC|OM_PRVGUNV|OM_OPARTS
       .word	-124*2,-61*2
	.long	C_INIT_BUS_PART,GRAT_DAM
       LWWWW	WINDOGRATE1, DMAWNZ, M_DBLSCL|M_NOPARTANI, -1, OM_CFUNC|OM_PRVGUNV|OM_OPARTS
       .word	-88*2,-61*2
	.long	C_INIT_BUS_PART,GRAT_DAM
       LWWWW	WINDOGRATE1, DMAWNZ, M_DBLSCL|M_NOPARTANI, -1, OM_CFUNC|OM_PRVGUNV|OM_OPARTS
       .word	-11*2,-61*2
	.long	C_INIT_BUS_PART,GRAT_DAM
       LWWWW	WINDOGRATE1, DMAWNZ, M_DBLSCL|M_NOPARTANI, -1, OM_CFUNC|OM_PRVGUNV|OM_OPARTS
       .word	26*2,-61*2
	.long	C_INIT_BUS_PART,GRAT_DAM

PNUM_INNR  .set	25
       LWWWW	INNERBUS1, DMAWNZ, M_DBLSCL, 110, OM_COLL |OM_GUNV
	.LONG	DUMCOLL
	.long	DUMRETS
       LWWWW	INNERBUS2, DMAWNZ, M_DBLSCL, 110, OM_COLL|OM_PRVGUNV
	.LONG	DUMCOLL
       LWWWW	INNERBUS3, DMAWNZ, M_DBLSCL, 110, OM_COLL|OM_PRVGUNV
	.LONG	DUMCOLL


       LWWWW	BTIROT1, DMAWNZ, M_DBLSCL|M_NOPARTANI, -2, OM_OPARTS|OM_COLL|OM_GUNV|OM_ANIM 
       .word	-114*2, 0
	.LONG	DUMCOLL
	.LONG	BTIRE_GUNVECT
       .long	btirerotStart
       LWWWW	BTIROT1, DMAWNZ, M_DBLSCL|M_NOPARTANI, -2, OM_OPARTS|OM_COLL|OM_PRVANIM|OM_PRVGUNV
       .word	-58*2, 0
	.LONG	DUMCOLL
       LWWWW	BTIROT1, DMAWNZ, M_DBLSCL|M_NOPARTANI, -2, OM_OPARTS|OM_COLL|OM_PRVANIM|OM_PRVGUNV
       .word	125*2, 0
	.LONG	DUMCOLL


************************************
*				   *
*   DAMAGE TABLES for bus parts    *
*				   *
************************************


PAN_DAM:
       WWLL	30,4,PANELB,MAKE_BUS_FRAGS+1
       WWLL	30,4,PANELC,MAKE_BUS_FRAGS+1
       .long	-1

AX1_DAM:
       WWLL	30,4,AXELB1,MAKE_BUS_FRAGS+1
       WWLL	30,4,AXELC1,MAKE_BUS_FRAGS+1
       .long	-1		  

AX2_DAM:
       WWLL	30,4,AXELB2,MAKE_BUS_FRAGS+1
       WWLL	30,4,AXELC2,MAKE_BUS_FRAGS+1
       .long	-1

TAIL_DAM:
       WWLL	30,4,TAILB,MAKE_BUS_FRAGS+1
       WWLL	30,4,TAILC,MAKE_BUS_FRAGS+1
       .long	-1

DORP_DAM:
       WWLL	30,4,DORPB,MAKE_BUS_FRAGS+1
       WWLL	30,4,DORPC,MAKE_BUS_FRAGS+1
       .long	-1

CAP_DAM:
       WWLL	30,4,CAPB,MAKE_BUS_FRAGS+1
       WWLL	30,4,CAPC,MAKE_BUS_FRAGS+1
       .long	-1

MIDG_DAM:
       WWLL	6,1,0,STALL_MIDGUN
       WWLL	6,1,0,STALL_MIDGUN
       WWLL	6,1,0,STALL_MIDGUN
       WWLL	6,1,0,STALL_MIDGUN
       WWLL	6,1,0,STALL_MIDGUN
       WWLL	6,1,0,STALL_MIDGUN
	WWLL	6,1,MIDGUNd,MIDGUN_DESTROY+1
	.long	-1

STEP_DAM:
	WWLL	30,4,WSTEPd,MAKE_BUS_FRAGS_SM
	.long	-1

ENG_DAM:
       WWLL	30,4,ENGINEB,MAKE_BUS_FRAGS+1
       WWLL	30,4,ENGINEC,MAKE_BUS_FRAGS+1
       .long	-1

TUR_DAM:
       WWLL	6,1,0,STALL_TURRET
       WWLL	6,1,0,STALL_TURRET
       WWLL	6,1,0,STALL_TURRET
       WWLL	6,1,0,STALL_TURRET
       WWLL	6,1,0,STALL_TURRET
       WWLL	6,1,0,STALL_TURRET
       WWLL	6,1,TURRETFLY+1,TURRET_FLY_AWAY+1
       .long	-1


ROOF_DAM:
       WWLL	30,4,ROOFBASEd,MAKE_BUS_FRAGS+1
       .long	-1

DOOR_DAM:
       WWLL	30,4,DAMDOOR+3,MAKE_BUS_FRAGS+1
       .long	-1

HOOD_DAM:
       WWLL	30,4,HOODFLY+1,PART_FLY_AWAY+1
       .long	-1

WIND_DAM:
       WWLL	15,2,BUSWINDOd,MAKE_GLAS_FRAGS
       .long	-1

GRAT_DAM:
       WWLL	20,2,WINDOGRATEd,EXPLO_NO_FRAGS
       WWLL	20,2,0,STATIC_FLY_AWAY+1
       .long	-1



*===========================================================================


MAKE_BUS_FRAGS_SM:			; make small frags and explo
	mmtm	sp,a2,a5
	movi	50000h,a0		; MAX X,Y vel
	movi	0a0h,a3			; MAX Z vel
	move	a7,a7
	jrz	MBFS1
	calla	PreFrag_Center
	jruc	MBFShk1
MBFS1:
	movi	[5,8],a4		; box radius
	calla	PreFrag_Gun
MBFShk1:
	
	sub	b10,b9
	sub	b10,b9
	neg	b10			; Z vel negative
	move	*a8(OPART1),a0,L	; bus head
	move	*a8(OXVEL),a14,L	; bus vel
	move	a14,b14
	add	b14,b3
	add	b14,b4			; adjust by speed of bus
	movi	FRAG_U10,b14
	calla	Fragger

	MOVE	*A8(OIMG),A1,L
	MOVE	*A1(ICMAP),*A0(FPDATA),L	;SET PALETTE

	clr	a3
	jruc	EXPLO_NO_FRAGShk


MIDGUN_DESTROY:
	calla	OBJPROC_KILL	; kill midgun intelligence

MAKE_BUS_FRAGS:				; make 2X frags and explo
	mmtm	sp,a2,a5
	movi	50000h,a0		; MAX X,Y vel
	movi	0a0h,a3			; MAX Z vel
	move	a7,a7
	jrz	MBF1
	calla	PreFrag_Center
	jruc	MBFhk1
MBF1:
	movi	[10,10],a4		; box radius
	calla	PreFrag_Gun
MBFhk1:
	sub	b10,b9
	sub	b10,b9
	neg	b10			; Z vel negative
	move	*a8(OPART1),a0,L	; bus head
	move	*a0(OXVEL),a14,L	; bus vel
	move	a14,b14
	add	b14,b3
	add	b14,b4			; adjust by speed of bus
	movi	FRAG_U20_MIX,b14
	calla	Fragger

	MOVE	*A8(OIMG),A1,L
	MOVE	*A1(ICMAP),*A0(FPDATA),L	;SET PALETTE
	jruc	MBF_cont

EXPLO_NO_FRAGS:
	mmtm	sp,a2,a5
MBF_cont:
	movi	M_DBLSCL,a3		; make explo 2X
EXPLO_NO_FRAGShk:
	move	a7,a7
	jrz	MBF0
	calla	MAKE_EXPLO_CENTER
	jruc	MBFhk
MBF0:
	calla	MAKE_EXPLO_GUN
MBFhk:
	SOUND1	SND_PART_EXPLO
	mmfm	sp,a2,a5
	rets


CLR_GUNVECT:
	CLRM	*a8(OGUNVECT),L
	DIE


MAKE_GLAS_FRAGS:
	CREATE	PID_IND,CLR_GUNVECT	; clear gunvect next tik

	mmtm	sp,a2,a5
	movi	50000h,a0		; MAX X,Y vel
	movi	0a0h,a3			; MAX Z vel
	calla	PreFrag_Center

	sub	b10,b9
	sub	b10,b9
	neg	b10			; Z vel negative
	move	*a8(OPART1),a0,L	; bus head
	move	*a0(OXVEL),a14,L	; bus vel
	subi	20000h,a14
	move	a14,b14
	add	b14,b3
	add	b14,b4			; adjust by speed of bus
	movi	FRAG_S20,b14
	calla	Fragger

	MOVE	*A8(OIMG),A1,L
	MOVE	*A1(ICMAP),*A0(FPDATA),L	;SET PALETTE

	SOUND1	SND_WINDO_BRK
	mmfm	sp,a2,a5
	rets


FLY_GCOLL
	WWL	OID_GRND,0FFFFH,FLY_GRND_COLL
	WL	0,DUMCRETS

FLY_GRND_COLL
	MOVE	*A8(OYVEL),A14,L
	JAN	FGC_ign				;BR=GOING UP

	SRA	1,A14				;OYVEL=OYVEL/2

	NEG	A14				;REVERSE VELOCITY
	MOVE	A14,*A8(OYVEL),L
FGC_ign:
	RETS


STATIC_FLY_AWAY:
	movi	STATIC_FLY_ANIM,a1
	calla	STRT_ANIM
	jruc	PART_FLY_AWAY


TURRET_FLY_AWAY:
	calla	DELAYED_PRAISE
	calla	OBJPROC_KILL		; kill turret monitor process

PART_FLY_AWAY:
	callr	MAKE_BUS_FRAGS
TIRE_FLY_AWAY:
	calla	PULL_PART

	movi	-2800h,a9		; x accel
	CREATE	PID_IND,DECEL_X
	move	a0,*a8(OPLINK),L

	MOVIM	DUMRETS,*a8(OGUNVECT),L
	MOVIM	FLY_GCOLL,*a8(OCVECT),L
	ORIM	M_GCOLL,*a8(OFLAGS),W

	MOVIM	-080h,*a8(OZVEL),L
	MOVIM	-44000h,*a8(OYVEL),L
	MOVIM	2c00h,*a8(OYACCEL),W

	rets


*
*	This process is killed from AFUNC when obj gets offscreen
*
DECEL_X:
	move	*a8(OXVEL),a0,L
	add	a9,a0
	move	a0,*a8(OXVEL),L	
	sloop	1,DECEL_X


**********************************
*				 *
*           TURRET		 *
*				 *
**********************************

*
*	a8 = obj block of turret
*	a9 = state flags (0 = idle, 1 = firing, -1=stunned)
MON_TURRET:
	move	a13,*a8(OPLINK),L
	clr	a9			; state
	sleep	200

MON_TUR_LP:
	move	a9,a9			; check state
	jrz	MT_attack 		; if idling, try to attack
	jrnn	MT_waitoff		; if attacking, check for offscreen
	RANDSLP	120,200			; if stunned, begin recovery
MT_waithome1:
	move	*a8(OIMG),a4,L
	cmpi	BTURRET03,a4
	jreq	MT_rdy1
	sloop	2,MT_waithome1

MT_waitoff:
	move	@HOLD_ENEMY_DISPATCH,a14  ; stop attacking if he say so
	jrnz	MT_rdy1

	move	*a8(OFLAGS),a0		; if attacking and offscreen
	btst	B_OFSCRN,a0		; stop attacking
	jrz	MT_wait			; otherwise, wait for player to react
MT_rdy1:
	clr	a9
	movi	BTURRET_IDLE,a1
	move	a1,*a8(AnimFrm),L
	move	a1,*a8(AnimScr),L
	sloop	1,MON_TUR_LP


MT_attack:
	movk	10,a1
	move	*a8(OTURIDLE),a0
	calla	RANGRAND
	calla	PRCSLP
MT_waithome2:
	move	*a8(OIMG),a4,L
	cmpi	BTURRET05,a4
	jreq	MT_rdy2
	sloop	2,MT_waithome2
MT_rdy2:
	move	*a8(OZVAL),a14,L	; no turret action if too close
	move	@ZBASE,a0,L
	sub	a0,a14
	cmpi	0c000h,a14
	jrlt	MT_wait
	
	move	@HOLD_ENEMY_DISPATCH,a14	; no attack if he say so
	jrnz	MT_wait

	move	*a8(OFLAGS),a14		; or if off screen.
	btst	B_OFSCRN,a14
	jrnz	MT_wait
	
	movk	1,a9

	movi	BTURRET_ATTACK_CCW,a1
	move	@RAND,a14
	btst	7,a14
	jrnz	MT_ccw0
	movi	BTURRET_ATTACK_CW,a1
MT_ccw0:
	move	a1,*a8(AnimScr),L
	move	a1,*a8(AnimFrm),L
	MOVKB	1,*a8(AnimSlp)

MT_wait:
	sloop	1,MON_TUR_LP


STALL_TURRET:
	move	*a8(OPLINK),a4,L
	move	*a4(PA9),a6		; are we firing?
	cmpk	1,a6
	jrne	ignore_hit
*
*	IF TURRET IS FIRING, send it spinning and allow
*	damage table to advance
*
	movi	BTURRET_CCW,a1
	move	@RAND,a14
	btst	5,a14
	jrnz	ST0
	movi	BTURRET_CW,a1
ST0:
	move	a1,*a8(AnimScr),L
	move	a1,*a8(AnimFrm),L
	MOVKB	1,*a8(AnimSlp)

	move	*a8(OPLINK),a4,L	; turret proc
	clr	a0
	dec	a0
	move	a0,*a4(PA9),L		; signal wild spin

	move	*a8(OTURIDLE),a14
	subk	25,a14
	move	a14,*a8(OTURIDLE)	; idle less next time

	rets


ignore_hit:
	CLRM	*a8(ONODAMTIM),W	; allow more hits
	subi	60h,a5			; adjust damage table
	rets



**********************************
*				 *
*           MIDGUN		 *
*				 *
**********************************

*
*	a8 = obj block of midgun
*	a9 = state flags (0 = idle, 1 = firing, -1=stunned)
MON_MIDGUN:
	move	a13,*a8(OPLINK),L
	clr	a9			; state
	sleep	270

MON_MIDG_LP:
	move	a9,a9			; check state
	jrz	MM_attack 		; if idling, try to attack
	jrnn	MM_waitoff		; if attacking, check for offscreen
	move	*a8(OPART1),a0,L	; get bus head
	move	*a0(OTOTHITS),a2
	movi	100,a1			; starting min
	movi	200,a0			; starting max
	sll	1,a2
	sub	a2,a1			; adj min by TOTHITS * 2
	sll	1,a2
	sub	a2,a0			; adj max by TOTHITS * 4
	calla	RANGRAND
	calla	PRCSLP
MM_waithome1:
	move	*a8(OIMG),a4,L
	cmpi	MIDGUN1,a4
	jreq	MM_rdy1
	sloop	1,MM_waithome1

MM_waitoff:
	move	@HOLD_ENEMY_DISPATCH,a14  ; stop attacking if he say so
	jrnz	MM_rdy1

	move	*a8(OFLAGS),a0		; if attacking and offscreen
	btst	B_OFSCRN,a0		; stop attacking
	jrz	MM_wait			; otherwise, wait for player to react
MM_rdy1:
	clr	a9
	movi	MIDGUN_IDLE,a1
	calla	STRT_ANIM
	sloop	1,MON_MIDG_LP


MM_attack:
	move	*a8(OPART1),a0,L	; get bus head
	move	*a0(OTOTHITS),a2
	movi	60,a1			; starting min
	movi	180,a0			; starting max
	sub	a2,a1			; adj min by TOTHITS
	sll	1,a2
	sub	a2,a0			; adj max by TOTHITS * 2
	calla	RANGRAND
	calla	PRCSLP

MM_waithome2:
	move	*a8(OIMG),a4,L
	cmpi	MIDGUN1,a4
	jreq	MM_rdy2
	sloop	2,MM_waithome2
MM_rdy2:
	move	*a8(OFLAGS),a14		; or if off screen.
	btst	B_OFSCRN,a14
	jrnz	MM_wait

	move	@HOLD_ENEMY_DISPATCH,a14  ; or if he say so
	jrnz	MM_wait

	move	*a8(OPART1),a0,L	; get bus head
	move	*a0(OTOTHITS),a2
	cmpk	20,a2  			; if close to end, no Z restriction
	jrge	ignZval
	
	move	*a8(OZVAL),a14,L	; no midgun action if too far
	move	@ZBASE,a0,L
	sub	a0,a14
	cmpi	13000h,a14
	jrgt	MM_wait
ignZval:
	movk	1,a9

	movi	MIDGUN_ATTACK,a1
	calla	STRT_ANIM

MM_wait:
	sloop	1,MON_MIDG_LP


STALL_MIDGUN:
	move	*a8(OPLINK),a4,L
	move	*a4(PA9),a6		; are we firing?
	cmpk	1,a6
	jrne	ignore_hit
*
*	IF MIDGUN IS FIRING, make it nutty and allow
*	damage table to advance
*
	movi	MIDGUN_NUTTY,a1
	move	a1,*a8(AnimScr),L
	move	a1,*a8(AnimFrm),L
	MOVKB	1,*a8(AnimSlp)

	move	*a8(OPLINK),a4,L	; turret proc
	clr	a0
	dec	a0
	move	a0,*a4(PA9),L		; signal wild spin

	rets




**********************************
*				 *
*           BUS DOOR		 *
*				 *
**********************************

BDROPEN:
	LWL	BDOOR1,10|AFunc,DOOR_IDLE
	LWL	BDOOR3,3|AFunc,UPDATE_MIRROR
	LWL	BDOOR4,3|AFunc,UPDATE_MIRROR
	LWL	BDOOR5,3|AFunc,UPDATE_MIRROR
	LWL	BDOOR6,60|AFunc,UPDATE_MIRROR
	LWL	1,3|AFunc,CHECK_DOOR_CLOSE
	LWL	BDOOR5,3|AFunc,UPDATE_MIRROR
	LWL	BDOOR4,3|AFunc,UPDATE_MIRROR
	LWL	BDOOR3,3|AFunc,UPDATE_MIRROR
	LWL	BDOOR1,10|AFunc,UPDATE_MIRROR
	.long	0


DAMDOOR:
	LWL	BDOORd1,10|AFunc,DOOR_IDLE
	LWL	BDOORd3,3|AFunc,UPDATE_MIRROR
	LWL	BDOORd4,3|AFunc,UPDATE_MIRROR
	LWL	BDOORd5,3|AFunc,UPDATE_MIRROR
	LWL	BDOORd6,60|AFunc,UPDATE_MIRROR
	LWL	1,3|AFunc,CHECK_DOOR_CLOSE
	LWL	BDOORd5,3|AFunc,UPDATE_MIRROR
	LWL	BDOORd4,3|AFunc,UPDATE_MIRROR
	LWL	BDOORd3,3|AFunc,UPDATE_MIRROR
	LWL	BDOORd1,50|AFunc,UPDATE_MIRROR
	.long	0

DOOR_IDLE:
	move	*a8(OTHRHAF),a0,L
	cmp	a0,a8
	jrlt	stay_closed

	move	*a8(OFLAGS),a14		; both halfs must be onscreen.
	btst	B_OFSCRN,a14
	jrnz	stay_closed
	move	*a0(OFLAGS),a14
	btst	B_OFSCRN,a14
	jrnz	stay_closed

	move	*a8(OIDLETIM),a5	; a8 contains master
	jrz	reset_idle
	dec	a5
	jrnz	store_idle		; if 0, fall through (move on)

	move	*a8(OZVAL),a14,L
	move	@ZBASE,a1,L
	sub	a1,a14
	cmpi	8c00h,a14		; if bus is too close to player,
	jrlt	stay_closed		;   don't throw grenade

	move	@HOLD_ENEMY_DISPATCH,a14
	jrnz	stay_closed

	PUSH	a8
	movi	NONTHRW_INIT,b0
	calla	CREATE_ENEMY
	jrz	DrIdleAbt
	PULLQ	a0		

	move	a8,*a0(ONONTHR),L	; door keeps thrower object

	MOVKB	1,*a8(OHITS)

	MOVIM	NONTHR_DEATH,*a8(OEDEATH),L

	MOVIM	-0a0000h,*A8(OGRNDOFF),L

	move	*a0(OXVAL),a14,L
	addi	20000h,a14
	move	a14,*a8(OXVAL),L
	move	*a0(OYVAL),*a8(OYVAL),L
	move	*a0(OZVAL),a14,L
	addi	NON2DOOR_OFF,a14
	move	a14,*a8(OZVAL),L
	MOVIM	NON2DOOR_OFF,*a8(ODATA+100h),W	; set offset from doors

	move	*a0(OPART1),a10,L	; bus head
;	move	*a10(OXVEL),*a8(OXVEL),L
;	move	*a10(OZVEL),*a8(OZVEL),L	; this guy must match bus

	move	a0,a9
	CREATEP	PID_IND,MATCH_DOOR_POS	; keep him on the bus
	move	a0,*a8(OPLINK),L
	move	a9,a0

	calla	INSERT_ENEMY

	CLRM	*a0(OIDLETIM),W		; master is in a0

	move	*a0(OTHRHAF),a8,L	; slave is in a8
	jruc	UPDATE_MIRROR_hk

reset_idle:
	move	@MASTER_IDLE,a0
	dec	a0
	jrnz	new_ok
	inc	a0
new_ok:
	move	a0,@MASTER_IDLE		; master never goes to 0
	calla	CURPLYR_ADJ_DOWN	; 
	calla	RANDU
	move	a0,a5		
store_idle:
	move	a5,*a8(OIDLETIM),W
stay_closed:
	move	*a8(AnimScr),*a8(AnimFrm),L	; stay here
	rets

DrIdleAbt:
	PULLQ	a0
	CLRM	*a0(ONONTHR),L		; no thrower object
	jruc	stay_closed		; safety abort if CREATE_ENEMY fails

*
*	close door only if guy not falling out of it
*
CHECK_DOOR_CLOSE:
	move	a8,a0	 		; if this is the slave,
	move	*a0(OTHRHAF),a8,L	; stick at this frame
	cmp	a8,a0
	jrlt	stay_here
	move	*a0(ONONTHR),a1,L
	jrz	UPDATE_MIRROR_hk	; move on if no guy (safety)
	move	*a1(ODATA+100h),a2	; offset from door
	cmpi	NON2DOOR_OFF,a2
	jreq	UPDATE_MIRROR_hk	; he's not dying
	move	a2,a2
	jrnn	stay_here		; wait if he's not out door yet
	jruc	UPDATE_MIRROR_hk	; move on if he's out the door



UPDATE_MIRROR:
	move	a8,a0	 		; if this is the slave,
	move	*a0(OTHRHAF),a8,L	; stick at this frame
	cmp	a8,a0
	jrlt	stay_here
UPDATE_MIRROR_hk:
	move	*a0(AnimFrm),a1,L	; a0 contains master
	move	*a0(AnimScr),a3,L
	sub	a3,a1
	move	*a8(AnimScr),a14,L	; update frame of slave
	add	a1,a14
	move	a14,*a8(AnimFrm),L
	MOVKB	1,*a8(AnimSlp)
	rets

stay_here:
	move	*a0(AnimFrm),a14,L
	subi	50h,a14
	move	a14,*a0(AnimFrm),L
	MOVKB	1,*a0(AnimSlp)
	rets


******************************************
*			        	 *
*       GRENADE THROWING NONBOY	         *
*				  	 *
******************************************

NONTHRW_INIT
	.byte	1, 0, 0, 1	;OBJCNT, PRCCNT, IMGPALCNT, PALCNT
	.long	P_NONBOYY
	.word	OID_NONBOY, OM_COLL
	.long	NONTHR_CVECT	
*
*    .long IMG
*    .word DMAFLAGS, OFLAGS, OZOFF, OPTION_BITS
*
       LWWWW	G_B1GRNTHA1, DMAWNZ, 0, 0, OM_ANIM | OM_GUNV
        .long	NONBOY_GUNVECT
	.long	NON_THROW_ANIM



NON_THROW_ANIM:
	LW	G_B1GRNTHA1,15
	LW	G_B1GRNTHA2,12
	LW	G_B1GRNTHA3,9
	LW	G_B1GRNTHA4,7
	LW	G_B1GRNTHA5,6
	LW	G_B1GRNTHA6,6
	LW	G_B1GRNTHA7,6
	LWL	G_B1GRNTHA8,6|AFunc,THROW_GRENADE
	LW	G_B1GRNTHA9,6
	LW	G_B1GRNTHA10,6
	LW	G_B1GRNTHA11,6
	LW	G_B1GRNTHA12,7
	LW	G_B1GRNTHA13,7
	LWL	G_B1GRNTHA14,15|AFunc,DEL_ENEMY_NOAUD



*	a10 = bus head obj
*	a9 = bus door obj
*	a8 = nonboy obj
MATCH_DOOR_POS:
;	move	*a10(OXVEL),*a8(OXVEL),L	
;	move	*a10(OZVEL),*a8(OZVEL),L	

	move	*a9(OXVAL),a0,L
	addi	0a0000h,a0
	move	a0,*a8(OXVAL),L
	move	*a9(OZVAL),a2,L		; Bus Z
	move	*a8(ODATA+100h),a5
	add	a5,a2
	move	a2,*a8(OZVAL),L

	move	*a8(OPARTS),a3,L
	jrz	nolegs
mtch_parts:
	move	a0,*a3(OXVAL),L
	move	a2,*a3(OZVAL),L
	move	*a3(OPARTS),a3,L
	jrnz	mtch_parts
nolegs:
	sloop	1,MATCH_DOOR_POS


CMANSCL2	.macro	Z1,Z2,S1,S2
	subi	Z2-((Z2-Z1)*S2)/(S2-S1),a0
	movi	((S2-S1)*65536)/(Z2-Z1),a5
	mpys	a0,a5
	sra	16,a5
	.endm

GREN_MAX_Z	.set	16400h


THROW_GRENADE:
	move	*a8(OFLAGS),a14
	btst	B_OFSCRN,a14
	jrnz	nothrow

	movi	GREN_INIT,b0
	calla	EASYMAKE
	jrz	nothrow
*
*	Set position relative to arm
*
	move	*a8(OZVAL),a6,L
	move	a6,*a0(OZVAL),L
	move	@ZBASE,a14,L
	sub	a14,a6			; world Z in a6
	move	*a8(OYVAL),a14,L
	subi	138<<15,a14
	move	a14,*a0(OYVAL),L
	move	*a8(OXVAL),a14,L
	subi	21<<15,a14
	move	a14,*a0(OXVAL),L

	calla	INSOBJ
	PUSH	a8
	move	a0,a8

	movi	-1c0000h,a1
	movi	-080000h,a0
	calla	RANGRAND	; get random Y
	move	a0,a4

	move	a6,a7
	subi	9000h,a7	; index between 0 and 10000h (approx)

	move	*a8(OYVAL),a5,L
	move	@YBASE,a14,L
	sub	a14,a5		; world Y in a5
	sub	a5,a4
	sra	6,a4
	subi	1c000h,a4
	sub	a7,a4
	move	a4,*a8(OYVEL),L	

	movi	0300000h,a1
	move	a1,a0
	neg	a1
	calla	RANGRAND	; get random X
	move	a0,a3		; World Target X in a0, Y in a1

	move	*a8(OXVAL),a5,L
	move	@XBASE,a14,L
	sub	a14,a5		; world x in a5
	move	@XSCROLL,a14,L	; X scroll
	sub	a5,a3
	sra	6,a3
	move	a3,a10
	add	a14,a3		; match X scroll
	move	a3,*a8(OXVEL),L	

	sra	6,a7		; shift 6 (+ compensate for prev shift 4)
	move	a7,a14
	sra	1,a14
	add	a14,a7
	addi	1000h,a7
	move	a7,*a8(OYACCEL)

	cmpi	GREN_MAX_Z,a6	; fix scale if too far away
	jrlt	formscl
	movi	800h,a5
	jruc	scl_hk

formscl:
	move	a6,a0
	CMANSCL2	8000h,GREN_MAX_Z,300h,800h
;	CMANSCL2	8000h,18060h,2aah,800h
scl_hk:
	move	a5,a9
	calla	SET_SCALE_MANUAL

	move	a9,a11
	subi	0a0h,a11	; final scale
	sll	16,a9
	sll	16-5,a11 	; get a fraction
	CREATE	PID_IND,GREN_ADJ_SCL
	move	a0,*a8(OPLINK),L
	MOVKM	32,*a0(PDATA),W		;counter

;	movi	-100h,a14
	subi	4000h,a6		; world Z to travel
	move	@BUS_STEADY_Z,a14,L
	.if	ZFRAC>6
	sll	ZFRAC-6,a14    		; distance we will scroll in 64 ticks
	.endif
	sub	a14,a6			; grenade won't travel that part
	sra	6,a6			; get vel from distance
	neg	a6
	move	a6,*a8(OZVEL),L
	PULLQ	a8
nothrow:
	rets


	
*	a8 = obj
*	a9 = last scale set (shifted left 16 bits)
*	a10 = XVEL not adjusted for XSCROLL
*	a11 = adjustment to scale (shifted left 16 bits)
*
GREN_ADJ_SCL:
	move	@XSCROLL,a0,L
	add	a10,a0
	move	a0,*a8(OXVEL),L

	sleep	1
	
	move	@XSCROLL,a0,L
	add	a10,a0
	move	a0,*a8(OXVEL),L
	
	sub	a11,a9			; scale adjusted every other tick
	move	a9,a5
	srl	16,a5
	calla	SET_SCALE_MANUAL

	move	*a13(PDATA),a0
	dec	a0
	move	a0,*a13(PDATA)
	jaz	explode_gren

	sloop	1,GREN_ADJ_SCL


********************************
*			       *
*         Animations	       *
*			       *
********************************

HOODFLY:
	LW	HOODMID,3
	LW	HOODSP01,3
	LW	HOODSP02,3
	LW	HOODSP03,3
	LW	HOODSP04,3
	LW	HOODSP05,3
	LW	HOODSP06,3
	LW	HOODSP07,3
	LW	HOODSP08,3
	LW	HOODSP09,3
	LW	HOODSP10,3
	LW	HOODSP11,3
	LWL	HOODSP12,3|AFunc,A_OFFSCRN_DEL
	.long	0


TURRETFLY:
	LW	BTURBLO01,5
	LW	BTURBLO03,5
	LW	BTURBLO05,5
	LW	BTURBLO07,5
	LW	BTURBLO09,5
	LW	BTURBLO11,5
	LWL	BTURBLO13,5|AFunc,A_OFFSCRN_DEL
	.long	0


btirerotStart:
	LW	BTIROT1,20
	LW	BTIROT2,18
	LW	BTIROT3,16
	LW	BTIROT1,14
	LW	BTIROT2,12
	LW	BTIROT3,10
	LW	BTIROT1,8
	LW	BTIROT2,7
	LW	BTIROT3,6
	LW	BTIROT1,5
	LW	BTIROT2,4
	LWL	BTIROT3,3|AFunc,A_Set_LOOP_STRT

	LW	BTIROT1,3
	LW	BTIROT2,3
	LW	BTIROT3,3
	.long	0


btirerotSlow:
   LW   BTIROT1,0
   LWLW BTIROT2,0|AFunc,A_INC_AnimSLP+1,12
   LW   BTIROT3,0
   LWLW BTIROT1,0|AFunc,A_INC_AnimSLP+1,12
   LW   BTIROT2,0
   LWLW BTIROT3,0|AFunc,A_INC_AnimSLP+1,12
	.long	0



TIRE_FLY_ANIM
	LW	BTIROT1,8
	LW	BTIROT2,8
	LWL	BTIROT3,8|AFunc,A_OFFSCRN_DEL
	.long	0


STATIC_FLY_ANIM
	LWL	1,10|AFunc,A_OFFSCRN_DEL
	.long	0


MIDGUN_NUTTY:
	LW	MIDGUN1,2
	LW	MIDGUN2,2
	LW	MIDGUN3,2
	LW	MIDGUN4,2
	LW	MIDGUN5,2
	LW	MIDGUN4,2
	LW	MIDGUN3,2
	LW	MIDGUN2,2
	.long	0

MIDGUN_IDLE:			; return to starting pos
	LW	MIDGUN2,2
	LWL	MIDGUN1,1|AFunc,PULL_ANIM


MIDGUN_ATTACK:
	LW	MIDGUN2,5
	LW	MIDGUN3,5
	LW	MIDGUN4,5
	LW	MIDGUN5,5
	LWL	MIDGUN4,5|AFunc,A_Set_LOOP_STRT
	LWLWW	MIDGUN3,9|AFunc,A_ALL_FIRE_FNC+2,-49*2,-72*2
	.long	0


BTURRET_IDLE:
	LW	BTURRET03,30
	LW	BTURRET04,8
	LW	BTURRET05,8
	LW	BTURRET06,8
	LW	BTURRET07,30
	LW	BTURRET06,8
	LW	BTURRET05,8
	LW	BTURRET04,8
	.long	0

BTURRET_ATTACK_CW:
	LW	BTURRET04,3
	LW	BTURRET03,3
	LW	BTURRET02,3
	LW	BTURRET01,2
	LWL	BTURRET10,1|AFunc,A_Set_LOOP_STRT
	LWLWW	BTURRET10,14|AFunc,A_CHK_FIRE_FNC+2,0,-5
	.long	0
	

BTURRET_ATTACK_CCW:
	LW	BTURRET06,3
	LW	BTURRET07,3
	LW	BTURRET08,3
	LW	BTURRET09,3
	LWL	BTURRET10,1|AFunc,A_Set_LOOP_STRT
	LWLWW	BTURRET10,14|AFunc,A_CHK_FIRE_FNC+2,0,-5
	.long	0


BTURRET_CCW:
	LW	BTURRET01,3
	LW	BTURRET02,3
	LW	BTURRET03,3
	LW	BTURRET04,3
	LW	BTURRET05,3
	LW	BTURRET06,3
	LW	BTURRET07,3
	LW	BTURRET08,3
	LW	BTURRET09,3
	LW	BTURRET10,3
	.long	0


BTURRET_CW:
	LW	BTURRET09,3
	LW	BTURRET08,3
	LW	BTURRET07,3
	LW	BTURRET06,3
	LW	BTURRET05,3
	LW	BTURRET04,3
	LW	BTURRET03,3
	LW	BTURRET02,3
	LW	BTURRET01,3
	LW	BTURRET10,3
	.long	0


***************************************************
*						  *
*                  SPEED CONTROLS                 *   
*						  *
***************************************************

SLOWDWN_INIT
	.byte	 2, 0, 0, 0	;OBJCNT, PRCCNT, IMGPALCNT, PALCNT
	.word	OID_SOLO_DIR, OM_SPOS | OM_INSERT
	.long	[0,60],ZMAX_REAL	; screen position

*    .long IMG
*    .word OCTRL, OFLAGS, OZOFF, OPTION_BITS

	LWWWW	SLOWDOWNLIL, DMAWNZ, M_SCRNOBJ|M_NOSCALE, -1, OM_GUNV
	.long	SLOWDWN_GUNVECT
	LWWWW	SOLO_BUTTON, DMAWNZ, M_SCRNOBJ|M_NOSCALE, 0, OM_PRVGUNV

SPEEDUP_INIT
	.byte	 2, 0, 0, 0	;OBJCNT, PRCCNT, IMGPALCNT, PALCNT
	.word	OID_SOLO_DIR, OM_SPOS | OM_INSERT
	.long	[0,340],ZMAX_REAL	; screen position

*    .long IMG
*    .word OCTRL, OFLAGS, OZOFF, OPTION_BITS

	LWWWW	SPEEDUPLIL, DMAWNZ, M_SCRNOBJ|M_NOSCALE, -1, OM_GUNV
	.long	SPEEDUP_GUNVECT
	LWWWW	SOLO_BUTTON, DMAWNZ, M_SCRNOBJ|M_NOSCALE, 0, OM_PRVGUNV


S_MAKE_SPDCTRLS:
	movi	SPEEDUP_INIT,b0
	calla	MULTIMAKE
	move	a8,a9

	movi	SLOWDWN_INIT,b0
	calla	MULTIMAKE

	CREATE	PID_IND,MOVE_CTRLS_DWN

	jauc	SCRL_DISPATCHER


MOVE_CTRLS_DWN:
	movi	20000h,a0
	move	a0,*a8(OYVEL),L
	move	a0,*a9(OYVEL),L

	sleep	27

	clr	a0
	move	a0,*a8(OYVEL),L
	move	a0,*a9(OYVEL),L

;	movi	54,a0
;	move	a0,*a8(OYPOS)
;	move	a0,*a9(OYPOS)
;
;	move	*a8(OPARTS),a1,L
;	move	a0,*a1(OYPOS)
;	move	*a9(OPARTS),a1,L
;	move	a0,*a1(OYPOS)

*
*	Become a monitor process which doesn't let us stray too far from the
*	bus
*
*	if bus if off screen, force our speed to match bus's
*


	DIE


MOVE_CTRLS_UP:
	movi	OID_SOLO_DIR,a4		; OID to look for
	movi	-20000h,a5		; new YVEL
	clr	a6
	movi	FGLIST,a10
	move	a10,a0
	clr	a8
	clr	a9
MCU_chknxt:
	move	*a0,a0,L
	cmp	a0,a10
	jreq	MCU_kill		; BR = couldn't find any

	move	*a0(OID),a14
	cmp	a4,a14
	jrne	MCU_chknxt

	move	a0,a9		  	; save obj
	move	a5,*a9(OYVEL),L		; give velocity
	move	a6,*a9(OGUNVECT),L	; clear gunvect

MCU_chknxt2:
	move	*a0,a0,L
	cmp	a0,a10
	jreq	MCU_cont		; BR = couldn't find second

	move	*a0(OID),a14
	cmp	a4,a14
	jrne	MCU_chknxt2

	move	a0,a8		  	; save obj
	move	a5,*a8(OYVEL),L		; give velocity
	move	a6,*a8(OGUNVECT),L	; clear gunvect

MCU_cont:
	sleep	30

	move	a8,a8
	jrz	MCU_skpa8
	movb	*A8(OCTRL+B_INUSE-7),A14
	jrnn	MCU_skpa8
	calla	DELETE_OBJ
MCU_skpa8:
	move	a9,a8
	jrz	MCU_kill
	movb	*A8(OCTRL+B_INUSE-7),A14
	jrnn	MCU_kill
	calla	DELETE_OBJ
MCU_kill:
	DIE


ANIM_SOLO_FLASH
	LWLL	1,4|AFunc,A_CHANGE_PAL+2,P_SYMGRN
	LWLL	1,2|AFunc,A_CHANGE_PAL+2,P_SYMNORM
	LWL	1,1|AFunc,PULL_ANIM


SPEEDUP_GUNVECT:
	move	@HOLD_ENEMY_DISPATCH,a14
	jrnz	ignor
	SOUND1	SND_SPDUP
	move	@XSCROLL,a0,L
	addi	PLYR_ACCEL,a0,L
	movi	MAX_X_SCROLL,a1
	cmp	a1,a0
	jrle	nomofast
spdgunhk:
	move	a1,a0
nomofast:	  
	move	a0,@XSCROLL,L
	
	move	*a8(OPART1),a0,L
	move	*a8(OFLAGS),a14
	btst	B_ANIM,a1
	jrz	animagain
ignor:
	rets

animagain:
	movi	ANIM_SOLO_FLASH,a1
	jauc	STRTANIM


SLOWDWN_GUNVECT:
	move	@HOLD_ENEMY_DISPATCH,a14
	jrnz	ignor
	SOUND1	SND_SLWDN
	move	@XSCROLL,a0,L
	subi	PLYR_ACCEL,a0,L
	movi	MIN_X_SCROLL,a1
	cmp	a1,a0
	jrge	nomofast
	jruc	spdgunhk


MK_CVECT
	WWL	OID_PROCKET,~MASK_PLAYER,UNIV_ROCKET_COLL
	WWL	OID_PEXPLOSION,~MASK_PLAYER,MK_COLLVECT
	WL	0,DUMCRETS


MK_COLLVECT
	CALLA	UNIV_COLL_CHECK
	JRNZ	MKX
	MOVE	*A0(OID),A0,W			;GET PLAYER DATA ADDRESS
	CALLA	POID_TO_PDATA
*
*	Find TV and delete
*
	movi	M_BF_ID,a4
	movi	2<<B_BF_ID,a3
	move	*a8(OULINK),a0,L
	move	*a8(OXVAL),a5,L		; for position comparison
	move	*a8(OZVAL),a6,L		; for position comparison
	move	@RAMREF1,a1,L		; terminator
	move	a8,a9			; save this guy
MKC_nxt:
	move	*a0(MAP_NEXT),a0,L
	cmp	a0,a1
	jreq	MKC_abt
	move	*a0(MAP_FLAGS),a14
	and	a4,a14
	cmp	a3,a14			; is it a TV of OID 2?
	jrne	MKC_nxt			; BRANCH = no
	move	*a0(MAP_Y),a14,L	; is Y neg?
	jrnn	MKC_nxt			; BR = no
	move	*a0(MAP_OBJ),a8,L
	jrn	MKC_abt			; no object (fishy)
	srl	4,a8
	sll	4,a8			; clear hit count
	move	*a0(MAP_X),a14,L	; compare X positions
	sub	a5,a14
	abs	a14
	cmpi	30000h,a14
	jrgt	MKC_nxt			; BR=too far apart
	move	*a0(MAP_Z),a14,L
	sub	a6,a14
	abs	a14
	cmpk	6,a14
	jrgt	MKC_nxt			; BR=too far apart
*
*	Found it.  Delete it.
*
	calla	BG_TO_FG
	calla	DELETE_OBJ

MKC_abt:
	move	a9,a8			; restore orig obj

	calla	BG_TO_FG

	movi	STATIC_FLY_ANIM,a1
	calla	STRT_ANIM

	movi	5000,a1
	clr	a9
	calla	PRINT_SCORE

	MOVIM	FLY_GCOLL,*a8(OCVECT),L
	ORIM	M_GCOLL,*a8(OFLAGS),W

	MOVIM	-30000h,*a8(OXVEL),L
	MOVIM	040h,*a8(OZVEL),L
	MOVIM	-60000h,*a8(OYVEL),L
	MOVIM	3800h,*a8(OYACCEL),W

MKX:
	rets




TV_CVECT
	WWL	OID_PROCKET,~MASK_PLAYER,UNIV_ROCKET_COLL
	WWL	OID_PEXPLOSION,~MASK_PLAYER,TV_COLLVECT
	WL	0,DUMCRETS


TV_COLLVECT
	CALLA	UNIV_COLL_CHECK
	JRNZ	TVX
	MOVE	*A0(OID),A0,W			;GET PLAYER DATA ADDRESS
	CALLA	POID_TO_PDATA

	movi	M_LASTFRM|M_NOMORE,a7 	; flags
	jruc	tvchk
TV_GUNVECT
	movk	M_FLASHOBJ|M_NOMORE,a7
tvchk:
	clr	a9
	movi	2000,a5
	CALLA	UNIV_DAMAGE_HANDLER
	jrnc	TVX

	MMTM	SP,B1,B2,B4,B5,B6,B8,B9,B10		;MAKE STALL DOOR FRAGMENTS

	SOUNDZ	SND_TV_POP

	MOVI	030000H,A0
	MOVI	020H,A3
	CALLA	PreFrag_Center
	abs	b9
	addi	0a0h,b10
	MOVI	FRG_GL_12,B14
	CALLA	Fragger

	MOVE	*A8(OIMG),A1,L
	MOVE	*A1(ICMAP),*A0(FPDATA),L	;SET PALETTE

	MMFM	SP,B1,B2,B4,B5,B6,B8,B9,B10
TVX:
	rets


SND_TV_POP
	.word	0f370h,74,0a3ceh,0

DESERT_VECT_TABLE:
; 1
	.LONG	0,0
;2, 3		       
	.LONG	0,0,TV_CVECT,TV_GUNVECT
;4, 5		       
	.LONG	MK_CVECT,DUMRETS,BASIC_CVECT,BASIC_GUNVECT
;6, 7		       
	.LONG	0,0,0,0
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
	.LONG	0,0,BASIC_CVECT,BASIC_GUNVECT
;22, 23
	.LONG	0,0,0,0
;24, 25				; nose and chin
	.LONG	SNOZZ_CVECT,SNOZZ_GUNVECT,0,0
;26, 27
	.LONG	0,STONE_BUL_SND,PALMTREETOP_COLLVECTR,PALMTREETOP_GUNVECT
;28, 29
	.LONG	0,STONE_BUL_SND,0,0
;30, 31
	.LONG	0,0,0,0
;32
	.LONG	0,0



SNOZZ_CVECT
	WWL	OID_PROCKET,~MASK_PLAYER,UNIV_ROCKET_COLL
	WWL	OID_PEXPLOSION,~MASK_PLAYER,SNOZZ_COLLVECT
	WL	0,DUMCRETS

SNOZZ_GUNVECT:
	move	*a8(OULINK),a1,L
	setf	4,0,0
	move	*a1(MAP_ID+8),a0
	inc	a0
	move	a0,*a1(MAP_ID+8)
	setf	16,1,0
	cmpk	12,a0
	jrgt	Snozz_hk
	rets


SND_SNOZZ_EXP	.word	0f390h,103,0a3D1h,0

*
*	If you rocket the bughead, it will be gone.
*
*
SNOZZ_COLLVECT:
	CALLA	UNIV_COLL_CHECK
	JRNZ	SNOZZ_DONE

	MOVE	*A0(OID),A0,W			;GET PLAYER DATA ADDRESS
	CALLA	POID_TO_PDATA
Snozz_hk:
	MOVI	10000,A1
	movi	[-750,0],a9
	CALLA	PRINT_SCORE

	SOUND1	SND_SNOZZ_EXP

	MMTM	SP,B1,B2,B4,B5,B6,B8,B9,B10

	MOVI	050000H,A0
	MOVI	040H,A3
	CALLA	PreFrag_Center
	move	*a8(OYPOS),a0,W
	subi	1d0h,a0
	move	a0,b5
	move	a0,b6
	MOVI	FRG_BR_12,B14

	sub	b10,b9
	clr	b10

	sub	b8,b7
	clr	b8

	CALLA	Fragger
	MOVE	*A8(OIMG),A1,L
	MOVE	*A1(ICMAP),*A0(FPDATA),L	;SET PALETTE
	MMFM	SP,B1,B2,B4,B5,B6,B8,B9,B10

	move	*a8(OULINK),a6,L
	move	*a6(MAP_NEXT),a6,L

	calla	FLY_AWAY

	move	*a8(OYVEL),a14,L
	sll	1,a14
	move	a14,*a8(OXVEL),L
	move	a14,*a8(OYVEL),L
	MOVIM	3800h,*a8(OYACCEL),W

findchin:
	move	*a6(MAP_FLAGS),a3
	andi	M_BF_ID,a3
	srl	B_BF_ID,a3
	cmpk	24,a3			; ID of chin
	jreq	foundchin
	move	*a6(MAP_NEXT),a6,L
	jrnz	findchin

foundchin:
	move	*a6(MAP_IMG),a1,L
	srl	4,a1
	sll	4,a1
	move	*a6(MAP_OBJ),a0,L
	jrn	SNOZZ_DONE
	calla	STRTANIM
	move	*a8(OZVAL),a9,L		; 1 pixel X offset = Z world
	move	@ZBASE,a14,L
	sub	a14,a9
	move	a9,a11			; save Zwrld in a10 
	move	*a8(OXVAL),a14,L
	add	a14,a9
	move	*a0(ODAGY),a3		; 
	addk	10,a3			; desired screen position of CD
	move	@YHALF,a14
	sub	a14,a3
	mpys	a3,a11			; to get world Y
	move	a11,a10
	clr	a11
	CREATE	PID_IND,REVEAL_CD_BUS

SNOZZ_DONE:	
	rets



DESERT_SCROLL:
	.LONG	S_SET_LONG
	.long	WXBUFFER
	.long	500000h

	.long	S_CREATE_PROCR
	.word	PID_TCYCLE
	.long	4,31,26,DTVZAP1p,CYCLE16
	.word	0

	.LONG	S_MAKE_GUARDS

	.LONG	S_WAIT_HERE
	.word	30

	.LONG	S_CREATE_PROCR
	.word	PID_POWERUPD0
	.word	-21d0h,-2070h		; x range
	.long	0,9800h,12		; junk, zmax, num crates
	.LONG	SPRINKLE_POWERUPS
	.word	0

	.LONG	S_CREATE_PROCR
	.word	PID_TCYCLE
	.long	2,55,44,FTV2
	.long	CYCLE16
	.word	0

	.LONG	S_CREATE_PROCR
	.word	PID_TCYCLE
	.long	2,55,44,FTV3bw
	.long	CYCLE16
	.word	0

	.LONG	S_CREATE_PROC
	.word	PID_IND
	.long	ADDL_BG_CLEANUP_PROC

	.LONG	S_X_ACCEL_LIMIT
	.word	100h
	.long	10000h

	.LONG	S_WAIT_HERE
	.word	220

	.LONG	S_CREATE_PROCR
	.word	PID_POWERUPD0
	.word	-2070h,-1f10h   	; x range
	.long	0,9800h,12		; junk, zmax, num crates
	.LONG	SPRINKLE_POWERUPS
	.word	0

	.LONG	S_WAIT_HERE
	.word	350	 

	.LONG	S_CREATE_PROCR
	.word	PID_POWERUPD0
	.word	-1f10h,-1db0h   	; x range
	.long	0,9800h,12		; junk, zmax, num crates
	.LONG	SPRINKLE_POWERUPS
	.word	0

	.LONG	S_WAIT_HERE
	.word	350	 

	.LONG	S_MAKE_BUS

	.LONG	S_CREATE_ALT_SCROLL
	.long	BUS_Z_SCROLLER

	.LONG	S_WAIT_HERE
	.word	60h

	.LONG	S_X_ACCEL_LIMIT
	.word	1000h
	.long	70000h

	.LONG	S_SOUND
	.long	SND_DESERT

	.LONG	S_MAKE_GAUGE

	.LONG	S_MAKE_SPDCTRLS

	.LONG	S_KILL_ALL_PROCS	; kill busted TV cycle
	.word	PID_TCYCLE

	.LONG	S_WAIT_FOR_X
	.long	-165c0000h
	.word	1		; keep going

	.LONG	S_KILL_ALL_PROCS	; kill cycle
	.word	PID_TCYCLE

*********************************************start Z moving

	.LONG	S_SET_ZSCROLL
	.word	STEADY_Z_VAL
	.word	0

	.LONG	S_SET_LONG
	.long	BUS_STEADY_Z
	.long	STEADY_Z_VAL<<ZFRAC

	.LONG	S_SET_BUS_ZVEL
	.long	STEADY_Z_VAL		; speed

	.LONG	S_WAIT_FOR_X		; where to merge next uni
	.long	-14000000h
	.word	1		; keep going

	.LONG	S_SET_LONG
	.long	NEXT_X
	.long	-14000000h

;	.LONG	S_CREATE_PROC
;	.word	PID_POWERUPD0
;	.long	BUS_POWERUPS

	.LONG	DESERT_SUB+M_CALL		; FIRST SET OF BACKGROUNDS

	.LONG	S_INC_BUS_ATTMPTS

********************************************* start CANYON 

	.LONG	S_KILL_ALT_SCROLL

	.LONG	S_CREATE_ALT_SCROLL
	.long	BUS_Z_STATIC

	.LONG	S_SET_BUS_ZVEL
	.long	0			; bus Z speed

	.LONG	S_SET_LONG  
	.long	BUS_STEADY_Z
	.long	0

	.LONG	S_INC_UNIV_ID

	.if	BRIDGE_IN

	.LONG	S_WAIT_HERE
	.word	40

	.LONG	S_MERGE_UNIV_DESERT   		; DO BRIDGE	
	.long	GXCANYN1,CANYN_STX,CANYN_STZ

	.LONG	S_WAIT_FOR_X_DESERT		; CANYON/BRIDGE
	.long	CANYN_XSZ
	.word	1		; keep going

	.else

	.LONG	S_MERGE_UNIV_DESERT   		; DO generic
	.long	GXDESMID,DESMID_STX,DESMID_STZ1

	.LONG	S_WAIT_FOR_X_DESERT
	.long	DESMID_XSZ
	.word	1		; keep going
	
	.LONG	S_SET_LONG
	.long	WXBUFFER
	.long	0e00000h

	.LONG	S_INC_UNIV_ID

	.LONG	S_GIVE_BUS_DISTANCE

	.LONG	S_MERGE_UNIV_DESERT
	.long	GXSPINX1,SPINX_STX,SPINX_STZ

	.LONG	S_WAIT_FOR_X_DESERT
	.long	SPINX_XSZ
	.word	1		; keep going

	.LONG	S_SET_LONG
	.long	WXBUFFER
	.long	0500000h

	.endif

	.LONG	S_CREATE_BUS_COGS
	.word	5,120		; 10 guys 90 ticks apart

	.LONG	S_KILL_ALT_SCROLL

	.LONG	S_CREATE_ALT_SCROLL
	.long	BUS_Z_LOOP

	.LONG	S_SET_ZSCROLL			; restart Z SCROLL
	.word	STEADY_Z_VAL
	.word	0

	.LONG	S_SET_BUS_ZVEL
	.long	STEADY_Z_VAL			; speed

	.LONG	S_SET_LONG
	.long	BUS_STEADY_Z
	.long	STEADY_Z_VAL<<ZFRAC

;	.LONG	S_CREATE_PROC
;	.word	PID_POWERUPD0
;	.long	BUS_POWERUPS

********************************************* end CANYON 

	.LONG	DESERT_SUB+M_CALL

********************************************* start final

	.LONG	S_KILL_ALT_SCROLL

	.LONG	S_CREATE_ALT_SCROLL
	.long	BUS_Z_STATIC

	.LONG	S_SET_BUS_ZVEL
	.long	0			; bus Z speed

	.LONG	S_SET_LONG  
	.long	BUS_STEADY_Z
	.long	0

	.LONG	S_WAIT_HERE
	.word	40

	.LONG	S_INC_UNIV_ID

	.LONG	S_MERGE_UNIV_DESERT   		; DO BRIDGE	
	.long	GXDESPEN,DESPEN_STX,DESPEN_STZ

	.LONG	S_COMPUTE_BUS_STOP_X

	.LONG	S_KILL_POWERUPS			;Whack those powers

	.LONG	S_WAIT_FOR_X_DELTA		; END OF WAVE
	.long	DESPEN_XSZ
	.word	1		; keep going

	.LONG	S_KILL_ALT_SCROLL

	.LONG	S_PLAYER_BLEW_IT

	.LONG	S_CREATE_PROC
	.word	PID_IND
	.long	MOVE_CTRLS_UP

	.LONG	S_DECEL_TO_POINTX_DELTA	
;	.word	TO_END_TIKS-60
	.long	DESPEN_DELTA
;	.word	0

	.long	0

S_COMPUTE_BUS_STOP_X:
	move	@XBASE,a14,L
	addi	0e000000h,a14
	move	a14,@BUS_STOP_X,L	; X where bus will stop
	jauc	SCRL_DISPATCHER


SPINX_STX	.set 	-2ac0000h
SPINX_STZ	.set	-0d800h
SPINX_XSZ	.set	0c800000h-(SPINX_STX)

DESMID_STX	.set 	-2870000h
DESMID_STZ1	.set	-18000h
DESMID_STZ2	.set	-9000h
DESMID_XSZ	.set	015ba0000h-(DESMID_STX)

CANYN_STX	.set 	5d00000h
CANYN_STZ	.set	-10801h
CANYN_XSZ	.set	0211c0000h-(CANYN_STX)

DESPEN_STX	.set 	-1ba80000h
DESPEN_STZ	.set	-7d56h
DESPEN_XSZ	.set	-11e00000h-(DESPEN_STX)
DESPEN_DELTA	.set	-0ea00000h-(-11e00000h)


DESERT_SUB:
	.LONG	S_SEND_FLOAT_POWER
	.word	30,30,180		; num, min tiks, max tiks

	.LONG	S_SET_LONG
	.long	WXBUFFER
	.long	0500000h

	.LONG	S_INC_UNIV_ID

	.LONG	S_MERGE_UNIV_DESERT
	.long	GXDESMID,DESMID_STX,DESMID_STZ1

	.LONG	S_WAIT_FOR_X_DESERT
	.long	DESMID_XSZ
	.word	1		; keep going

	.LONG	S_SET_LONG
	.long	WXBUFFER
	.long	0e00000h

	.LONG	S_INC_UNIV_ID

	.LONG	S_GIVE_BUS_DISTANCE

	.LONG	S_MERGE_UNIV_DESERT
	.long	GXSPINX1,SPINX_STX,SPINX_STZ

	.LONG	S_WAIT_FOR_X_DESERT
	.long	SPINX_XSZ
	.word	1		; keep going

	.LONG	S_SET_LONG
	.long	WXBUFFER
	.long	0500000h

	.LONG	S_INC_UNIV_ID

	.LONG	S_MERGE_UNIV_DESERT
	.long	GXDESMID,DESMID_STX,DESMID_STZ2

	.LONG	S_JOEY_CHECK

	.LONG	S_CREATE_BUS_COGS
	.word	8,70		; # guys, # ticks apart

JOEY_END:
	.LONG	S_WAIT_FOR_X_DESERT
	.long	DESMID_XSZ
	.word	1		; keep going

	LW	S_CHECK_SUB_END,0

	.LONG	S_SET_LONG
	.long	WXBUFFER
	.long	0e00000h

	.LONG	S_INC_UNIV_ID

	.LONG	S_GIVE_BUS_DISTANCE

	.LONG	S_MERGE_UNIV_DESERT
	.long	GXSPINX1,SPINX_STX,SPINX_STZ

	.LONG	S_WAIT_FOR_X_DESERT
	.long	SPINX_XSZ
	.word	1		; keep going

	.LONG	S_SET_LONG
	.long	WXBUFFER
	.long	0500000h

	LW	S_CHECK_SUB_END,1

	.LONG	S_INC_UNIV_ID

	.LONG	S_MERGE_UNIV_DESERT
	.long	GXDESMID,DESMID_STX,DESMID_STZ1

	.LONG	S_WAIT_FOR_X_DESERT
	.long	DESMID_XSZ
	.word	1		; keep going

	LW	S_CHECK_SUB_END,2

	.LONG	S_INC_UNIV_ID

	.LONG	S_MERGE_UNIV_DESERT
	.long	GXDESMID,DESMID_STX,DESMID_STZ1

	.LONG	S_WAIT_FOR_X_DESERT
	.long	DESMID_XSZ
	.word	1		; keep going


END_O_SUB:
	.long	0


PASS_JOEY:
	.LONG	S_CREATE_BUS_COGS
	.word	8,70		; # guys, # ticks apart

DO_JOEY:
	.LONG	S_GIVE_BUS_DISTANCE

	.LONG	S_SET_BUS_ZVEL
	.long	0			; bus Z speed

	.LONG	S_SET_LONG  
	.long	BUS_STEADY_Z
	.long	0

	.LONG	S_CREATE_JOEY

	.LONG	S_DECEL_TO_POINTX_DELTA
	.long	1220000h

	.LONG	S_WAIT_HERE
	.word	25

	.LONG	S_SOUND
	.long	SND_MY_WAY

	.LONG	S_WAIT_HERE
	.word	125

	.LONG	S_SET_WORD
	.long	HOLD_ENEMY_DISPATCH	; reset this (CREATE_JOEY sets it)
	.word	0

	.LONG	S_X_ACCEL_LIMIT
	.word	5000h
	.long	MIN_X_SCROLL

PASSED_JOEY:
	.LONG	S_SET_ZSCROLL
	.word	STEADY_Z_VAL
	.word	0

	.LONG	S_SET_LONG
	.long	BUS_STEADY_Z
	.long	STEADY_Z_VAL<<ZFRAC

	.LONG	S_SET_BUS_ZVEL
	.long	STEADY_Z_VAL		; speed

	.LONG	M_JUMP+JOEY_END



*
*	You get to see Joey Kramer if...
*	BUS_ATTEMPTS == 1   AND
*	some player has successfully gotten the powerup out of 3 sphinxs
*	(in other words, all of them up to now)
*
S_JOEY_CHECK:
  	move	@BUS_ATTEMPTS,a1
	cmpk	1,a1
	jane	SCRL_DISPATCHER		; not if BUS_ATTEMPTS not=1
	move	@UNIV_ID,a14
	cmpk	4,a14
	jale	SCRL_DISPATCHER		; not if in first 4 unis

*
*	You get to see JOEY!!!
*
  	CLRM	@SCROLL_FLAG,L			; not ok to create yet

	movi	PASS_JOEY,a11			; use new scroll table
	move	@SNOZZ_COUNT,a2
	cmpk	3,a2
	jane	SCRL_DISPATCHER

	movi	DO_JOEY,a11			; use new scroll table
	jauc	SCRL_DISPATCHER


S_CREATE_JOEY:
*
*	First, wait til bus given distance
*
	move	@SCROLL_FLAG,a14,L	; wait til bus given special distance
	jrnz	ok2create
	sloop	3,S_CREATE_JOEY

ok2create:
	movi	PUMP_INIT,b0
	calla	EASYMAKE
	jaz	SCRL_DISPATCHER
	move	a0,a8
	CREATE	PID_IND,DELETE_OFFLFT
	movi	JOEY_INIT,b0
	calla	EASYMAKE
	jaz	SCRL_DISPATCHER
	move	@SNOZZ_COUNT,a2
	cmpk	3,a2
	jreq	lvalon
*
*	if we are just passing him by, do thing a little different
*
	move	a0,a8
	CREATE	PID_IND,DELETE_OFFLFT
	movi	PASS_JOEY_ANIM,a14
	move	a14,*a8(AnimScr),L
	move	a14,*a8(AnimFrm),L
	movi	PASSED_JOEY,a11
	jauc	SCRL_DISPATCHER

*
*	get here if we are can see him.
*
lvalon:
	MOVKM	1,@HOLD_ENEMY_DISPATCH,W	;temporarily hold enemies
	JAUC	SCRL_DISPATCHER



PUMP_INIT
	.long	PUMP1A
	.word	DMAWNZ,M_NOSCALE,OM_WPOS|OM_INSERT
	.long	1000000h,0a8000h,0ae00h

	
JOEY_INIT
	.long	K141_1
	.word	DMAWNZ,M_NOSCALE,OM_WPOS|OM_INSERT|OM_ANIM
	.long	K141
	.long	1320000h,118000h,7000h

K141:
	LW	K141_1,6
	LW	K141_2,6
	LW	K141_3,6
	LW	K141_4,6
	LWLW	K141_5,6|AFunc,A_LOOP_IF_SX_GT+1,370
	LW	K141_1,6
	LW	K141_2,6
	LW	K141_3,6
	LW	K141_4,6
	LW	K141_5,6
	LWLL	KRAMRMRPH_01,10|AFunc,A_CHANGE_PAL+2,KMORPH
	LW	KRAMRMRPH_02,10
	LWLW	KRAMRMRPH_03,10|AFunc,A_AUDIT+1,AUDKRAMER
	LWLL	K_AEROLOGO,10|AFunc,A_CHANGE_PAL+2,AROLOGO2
	LWL	1,1|AFunc,A_PERRY_SCORE
	LWLW	1,1|AFunc,A_OBJ_TO_POWERUP+1,OID_WINGS


PASS_JOEY_ANIM:
	LW	K141_1,6
	LW	K141_2,6
	LW	K141_3,6
	LW	K141_4,6
	LW	K141_5,6
	.long	0


A_LOOP_IF_SX_GT
	calla	GETAFARG_WORD
	move	*a8(ODAGX),a14
	cmp	a0,a14
	jrlt	fallthru
	move	*a8(AnimScr),*a8(AnimFrm),L	
fallthru:
	rets


DELETE_OFFLFT:
	sleep	60
DELOFFLFTlp:
	move	*a8(ODAGX),a14	; upper left
	move	*a8(OSIZEX),a0	; X size
	add	a14,a0		; get screen right
	jan	DO_done
	sloop	60,DELOFFLFTlp
DO_done:
	calla	DELETE_OBJ
	DIE


S_INC_BUS_ATTMPTS:
	move	@BUS_ATTEMPTS,a14
	inc	a14
	move	a14,@BUS_ATTEMPTS
	JAUC	SCRL_DISPATCHER

*
*	the number of backgrounds you scroll through is based
*	on BUS_ATTEMPTS.  (if 0, you return after DESMID and SPINX1.
*	if 1, you do an additional DESMID.  if 2, you do an addl SPINX1, etc)
*
S_CHECK_SUB_END:
	move	*a11+,a0	; exit if BUS_ATTEMPTS == this number
	move	@BUS_ATTEMPTS,a1
	cmp	a0,a1
	jane	SCRL_DISPATCHER
	movi	END_O_SUB,a11
	jauc	SCRL_DISPATCHER


S_INC_UNIV_ID:
	move	@UNIV_ID,a14
	inc	a14
	move	a14,@UNIV_ID
	JAUC	SCRL_DISPATCHER


BUS_Z_SCROLLER:
	.LONG	S_WAIT_FOR_X
	.long	-181e0000h
	.word	1

BUS_Z_LOOP:
	.LONG	S_BUS_GOTO_ZPT
	.word	50		; how long
	.long	15000h		; WZ
	.word	4		; ticks to sleep

	.LONG	S_BUS_GOTO_ZPT
	.word	85		; how long
	.long	0d000h		; WZ
	.word	600		; ticks to sleep

	.LONG	S_BUS_GOTO_ZPT
	.word	70		; how long
	.long	08000h		; WZ
	.word	100		; ticks to sleep

	.LONG	S_BUS_GOTO_ZPT
	.word	100		; how long
	.long	10000h		; WZ
	.word	300		; ticks to sleep

	.LONG	S_BUS_GOTO_ZPT
	.word	300		; how long
	.long	17000h		; WZ
	.word	400		; ticks to sleep

	.LONG	S_BUS_GOTO_ZPT
	.word	200		; how long
	.long	0e000h		; WZ
	.word	500		; ticks to sleep

	.LONG	S_BUS_GOTO_ZPT
	.word	200		; how long
	.long	08000h		; WZ
	.word	250		; ticks to sleep

	.LONG	S_BUS_GOTO_ZPT
	.word	120		; how long
	.long	0f000h		; WZ
	.word	30		; ticks to sleep

	.LONG	S_BUS_GOTO_ZPT
	.word	100		; how long
	.long	0a000h		; WZ
	.word	400		; ticks to sleep

	.LONG	S_BUS_GOTO_ZPT
	.word	200		; how long
	.long	13000h		; WZ
	.word	300		; ticks to sleep

	.LONG	BUS_Z_LOOP+M_JUMP

BUS_Z_STATIC:
	.LONG	S_BUS_GOTO_ZPT
	.word	40		; how long
	.long	10800h		; WZ
	.word	1fffh		; ticks to sleep

	.long	0

*
*	parm:	.long	ZVELOCITY
*
S_SET_BUS_ZVEL:
	move	@BUS_HEAD_OBJ,a8,L
	move	*a11+,a1,L
	move	a1,*a8(OZVEL),L
	JAUC	SCRL_DISPATCHER



******************************************************************
*  MACROS  *
************

COMP_ACC5	.macro	vel,base,rs,rd
	move	@base,a0,L
	sub	rs,a0
	jrz	comacc?
	neg	a0
	move	@vel,a1,L	; vel in a1
	mpys	a14,a1		; vt in a1
	sub	a1,a0		; d-vt in a0
	mpys	a2,a0
	divs	a7,a0
comacc?
	move	a0,rd
	.endm


COMP_ACC2	.macro	base,rs,rd
	move	@base,a1,L
	sub	rs,a1
	jrz	comacc?
	neg	a1
	sll	2,a1
	divs	a7,a1
comacc?
	move	a1,rd
	.endm


COMP_DEC1	.macro	vel,base,rs,rd
	move	@base,a7,L
	sub	rs,a7
	jrz	comac1?
	neg	a7		; dist in a7
	move	@vel,a1,L	; vel in a1
	mpys	a0,a1		; vt in a1
	sub	a1,a7		; d-vt in a7
	sll	1,a7
	divs	a2,a7
comac1?
	move	a7,rd
	.endm

BUSHIT_SLEEP	.macro
	move	@WAVEVEL,a14
	add	a0,a14
	move	a14,*-a12	; save desired WAVEIRQ
;	srl	1,a0
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

******************************************************************


*
*	parm:	.word	duration of move
*		.long	desired world Z of bus
*		.word   ticks to sleep
*
S_BUS_GOTO_ZPT:
	MOVKM	1,*a13(PDATA+20h),W	; tell others we are busy

	MOVE	*A11+,A14,W		;GET DURATION		
	move	*a11+,a1,L		; desired world distance to bus
	move	@BUS_HEAD_OBJ,a0,L
	move	*a0(OZVAL),a8,L
	sub	a1,a8			; appartent delta Z desired
	sll	ZFRAC,a8		;TRANSLATE TO HI-RES
	move	@BUS_STEADY_Z,a1,L
	jrz	nomult
	mpys	a14,a1			
	add	a1,a8			; actual delta Z needed
nomult:

	CLR	b0			;CLEAR ACCELERATIONS
	MOVE	b0,@ZSACCEL,L

	move	a14,a7

	cmpi	30,a14
	jrge	use_fifth

	dec	a7
	mpys	a14,a7	; t * t-1

	COMP_ACC2	ZBASE_HR,a8,a3

	move	a14,a1
	srl	1,a1		; divide time in half
	clr	a14		; no cruise time
	jruc	use_half_hook

*
*	Take 1/6 total time to accel, 1/6 total time to decel
*	2/3 time to cruise
*
*	a = 36d/5(t*(t-1))
*
*	for 1/8 accel,   a =  64d/7t**2	   6/8 cruise
*	for 1/7 accel,   a =  49d/6t**2	   5/7 cruise
*	for 1/6 accel,   a =  36d/5t**2	   4/6 cruise
*	for 1/5 accel,   a =  25d/4t**2	   3/5 cruise
*	for 1/4 accel,   a =  16d/3t**2	   2/4 cruise
*	for 1/3 accel,   a =  9d/2t**2	   1/3 cruise
*	for 1/2 accel,   a =  4d/t**2	   no cruise
*
*
use_fifth:
 	sll	2,a7	; 4t
	subk	5,a7	; 4t-5 in a7
	mpys	a14,a7	; 4t**2 - 5t in a7

	movk	25,a2
	
	COMP_ACC5	ZSCROLL,ZBASE_HR,a8,a3

	move	a14,a1
	movk	5,a0		; divide time in fifths
	divs	a0,a1	

	sub	a1,a14		; cruise time (3/5)
	sub	a1,a14		; cruise time (3/5)
use_half_hook:
	move	a1,a0
	sll	16,a1
	movy	a1,a14

	move	a3,@ZSACCEL,L

	move	a14,*-a12,L	

	BUSHIT_SLEEP

	move	*a12+,a0		; cruise ticks
;	move	*a12,a0		; cruise ticks
	jrz	nocruz
	add	a14,a0
	clr	a14
	move	a14,@ZSACCEL,L

	BUSHIT_SLEEP
nocruz:
*
*	DECELERATE TO STOP
*
	move	*a12+,a1		; decel ticks

	move	a1,a0			;   in a0
	mpys	a0,a1			; t squared in a1
	move	a1,a2			; t squared in a2
*
*	a = 2(d-vt)/t*t
*
	COMP_DEC1	ZSCROLL,ZBASE_HR,a8,a3

	move	a3,@ZSACCEL,L

	move	@WAVEVEL,a8
	add	a0,a8		; desired WAVEVEL for stop
	srl	1,a0
	calla	PRCSLP			; sleep
wait_decel:	
	sleep	1

	move	@WAVEVEL,a0
	cmp	a0,a8
	jrgt	wait_decel

	clr	a14
	move	a14,@ZSACCEL,L
	MOVE	@BUS_STEADY_Z,@ZSCROLL,L

	CLRM	*a13(PDATA+20h),W	; tell others we are NOT busy

	jauc	S_WAIT_HERE


*
*	interrupt alternate scroller to make sure bus is far away for 
*	SPINX
*
S_GIVE_BUS_DISTANCE:
	move	*a13(ALTSCRL),a9,L	; alt scroll process in a0
	jaz	SCRL_DISPATCHER
	CREATE	PID_IND,GIVE_DISTANCE
	jauc	SCRL_DISPATCHER


GIVE_DISTANCE:
	move	*a9(PDATA+20h),a1	; are we changing Z?
	jrz	ok2intrpt
	sloop	3,GIVE_DISTANCE
*
*	simulate a scroll call
*
ok2intrpt:
	move	*a9(PA11),a0,L
	move	*a9(PSPTR),a1,L
	move	a0,*-a1,L		; push old on process stack
	move	*a9(PUSHCNT),a4       
	inc 	a4			; increment push counter
	move	a4,*a9(PUSHCNT)       
	move	a1,*a9(PSPTR),L
	move	a1,*a9(LAST_SP),L	; update stack ptr

	movi	SPINX_SPECIAL_Z,a3
	move	a3,*a9(PA11),L
	DIE


SPINX_SPECIAL_Z:
	.LONG	S_BUS_GOTO_ZPT
	.word	70		; how long
	.long	16000h		; WZ
	.word	0		; ticks to sleep

	.LONG	S_SET_SCROLL_FLAG
	.long	-1		; mark ok to create joey

	.LONG	S_WAIT_HERE
	.word	300

	.LONG	S_CLR_SCROLL_FLAG
	.long	-1		; mark not ok to create joey

	.long	0


*
*	This process gets rid of BG blocks which for one reason or another
*	have never become objects and never will. (They just accumulate
*	harmlessly until no free blocks are available)
*
ADDL_BG_CLEANUP_PROC:
	MOVE	@BGHEAD_ACTIVE,A0,L
	move	@RAMREF0,a1,L

	move	@ZBASE,a2,L
	subi	18000h,a2

	move	*a0(MAP_NEXT),a0,L
	cmp	a0,a1
	jreq	finito
	move	*a0(MAP_Z),a3,L
	cmp	a2,a3
	jrge	finito
	move	*a0(MAP_OBJ),a14,L
	jrnn	finito
*
*	If we got here, we have found a link which
*		1) comes before RAMREF0 in the list
*		2) is less than 20000h less than ZBASE
*		3) is not defined as an object
*
 	calla	REMOVE_AND_FREE_LINK	; get rid of it!

finito:
	sloop	2,ADDL_BG_CLEANUP_PROC



**************************************************************************
*								         *
* FILLBOX_OBJ - DRAW A BOX AS 1 OBJECT USING THE DISPLAY SYSTEM		 *
* A1 = [COLOR,PALETTE]							 *
* A2 = [H,W] SIZE OF BOX						 *
* A3 = [Y,X] SCREEN ADDRESS OF BOX					 *
*								         *
**************************************************************************
FILLBOX_OBJ
	MMTM	SP,A3,A7,A8
	clr	a7
	MOVX	A3,A7			; X in a7
	sra	16,a3			; Y in a3

	MOVI	BOXFILL_INIT,A5
	CALLA	CREATE_OBJ
	JRZ	DBO_X
	MOVE	A1,*A0(OPAL),L
	MOVE	A7,*A0(OXPOS),W
	MOVE	A3,*A0(OYPOS),W
	MOVE	A2,*A0(OSIZE),L
	MOVE	A2,*A0(OUSIZE),L
	CALLA	INSOBJ

DBO_X
	MMFM	SP,A3,A7,A8
	RETS


BOXFILL_INIT
	.LONG	BOXFILL,0
	.WORD	OID_JUNK,DMACAL,M_SCRNOBJ|M_NOSCALE,0
	.LONG	0

	.long	T2FIXED
BOXFILL:
	.word	4,4
	.long	IROM
	.word   0,0,00H


S_MAKE_GAUGE:
	movi	[0f0fh,0000],a1
	movi	[10,128],a2
	movi	[SKYTOPOF+3,(400-128)/2],a3
	calla	FILLBOX_OBJ
	move	a0,a8
	move	@XBASE,a9,L		; starting XBASE
	clr	a10
	CREATEP	PID_IND,GAUGE_PROC

	movi	YDSMSG_INIT,b0
	calla	EASYMAKE

	jauc	SCRL_DISPATCHER

YDSMSG_INIT
	.long	YDS2GO
	.word	DMAWNZ,M_SCRNOBJ|M_NOSCALE,OM_SPOS|OM_INSERT
	.word	200,2ch
	.long	6000h



	.if	BRIDGE_IN

TOT_DIST_TBL
	.long	0c9b4000h	; first attempt
	.long	0f300000h	; 2nd attempt
	.long	11b28000h	; 3rd attempt
	.long	13372000h	; 4th and more

	.else
TOT_DIST_TBL
	.long	0cc80000h				; first attempt
	.long	0cc80000h+2840000h			; 2nd attempt
	.long	0cc80000h+2840000h+3120000h		; 3rd attempt
	.long	0cc80000h+2840000h+3120000h+1970000h	; 4th attempt

	.endif


*	a8 = obj of first box
*	a9 = starting XBASE
*	a10 = obj of second box (0 before second created)
*	a11 = next transition value
GAUGE_PROC:
	move	@BUS_ATTEMPTS,a0
	cmpk	3,a0
	jrle	limit_ok
	movk	3,a0
limit_ok:
	sll	5,a0
	addi	TOT_DIST_TBL,a0
	move	*a0,a11,L
	srl	7,a11			; divide by 128 to get transition val
	move	a11,@GAUGE_DELTA_X,L
GAUGE_lp:
	clr	a2
	move	@XBASE,a0,L		; current XBASE
	sub	a9,a0	 		; normalize it
	jrn	no_wrap
	btst	28,a11
	jrz	no_wrap
	movi	10000000h,a2		; handle wrap case
no_wrap:
	srl	4,a0
	add	a2,a0			; possibly 0, possibly wrap val
	cmp	a0,a11
	jrhi	no_change
	move	a10,a10
	jrnz	boxes_already

	movi	[0101h,0000],a1
	movi	[10,1],a2
	
	movi	[SKYTOPOF+3,(400-128)/2],a3
	calla	FILLBOX_OBJ
	move	a0,a10

boxes_already:
	move	*a8(OUSIZEX),a1
	dec	a1
	jrz	remove_gauge
	move	a1,*a8(OSIZEX)
	move	a1,*a8(OUSIZEX)
	subi	128,a1
	neg	a1
	move	a1,*a10(OSIZEX)
	move	a1,*a10(OUSIZEX)
	move	*a8(OXPOS),a14
	inc	a14
	move	a14,*a8(OXPOS)

	move	@GAUGE_DELTA_X,a3,L	
	add	a3,a11			; next transition val
no_change:
	sloop	1,GAUGE_lp


remove_gauge:
	calla	DELETE_OBJ
	movi	128,a1
	move	a1,*a10(OSIZEX)
	move	a1,*a10(OUSIZEX)
*
*	put out a nasty sound
*
	sleep	30
	move	a10,a8
	calla	DELETE_OBJ

	DIE


S_CREATE_BUS_COGS
	move	*a11+,a0		; number of guys to dispatch
	calla	CURPLYR_ADJ
	move	a0,a9
	move	*a11+,a10		; ticks
	CREATE	PID_IND,CREATE_BUS_COGS
	JAUC	SCRL_DISPATCHER


*	Send a bunch of cog guys out
*
*	a9 = number of guys to dispatch
*	a10 = ticks between dispatching
*
CREATE_BUS_COGS
	move	@BUS_HEAD_OBJ,a8,L

CBClp:
	move	@HOLD_ENEMY_DISPATCH,a14
	janz	SUCIDE
	move	*a8(OZVAL),a0,L
	move	a0,a1
	subi	200h,a0
	subi	1000h,a1
	calla	RANGRAND
	move	a0,a11
	CREATE	PID_IND,PROC_COG_DESERT

	SLEEPR	a10
	dsj	a9,CBClp

	DIE


*
*	Used in desert only as preface to S_WAIT_FOR_X_DELTA
*	delta value is used to compute NEXT_X, univ X at which
*	next universe is to be merged
*
S_WAIT_FOR_X_DESERT:
	move	*a11,a0,L	; get X delta
	move	@XBASE,a14,L
	add	a14,a0
	move	a0,@NEXT_X,L	; save
	jauc	S_WAIT_FOR_X_DELTA



*
*	used in desert only
*	uses difference from XBASE to NEXT_X as merge offset
*
S_MERGE_UNIV_DESERT:
	move	*a11+,a8,L		; univ table
	move	*a11+,a0,L		; X off
	move	@NEXT_X,a9,L
	move	@XBASE,a14,L
	sub	a14,a9			; next X relative to current pos.
	add	a0,a9
	clr	a10
	move	*a11+,a14,L		; Z off
	move	a11,*-a12,L
	move	a14,a11
	JSRP	MERGE_UNIV_OFF
	move	*a12+,a11,L
	jauc	SCRL_DISPATCHER


*
*	params: num, min, max
*
S_SEND_FLOAT_POWER:
	move	*a11+,a8
	move	*a11+,a9
	move	*a11+,a10
	CREATE	PID_POWERUPD0,SEND_FLOAT_POWER
	JAUC	SCRL_DISPATCHER	


  	  .if 0
*
*	parm:	.word	1-8	(translated to ticks 1=2,2=4,3=8,4=16,etc.)
*		.word   ticks to sleep
*
S_BUS_ZDECEL:
	move	*a11+,a14		; power of 2
	movk	1,a0
	sll	a14,a0			; ticks to sleep
	neg	a14

	move	@ZSCROLL,a1,L
	subi	STEADY_Z_VAL<<ZFRAC,a1
	sra	a14,a1
	neg	a1
	move	a1,@ZSACCEL,L

	calla	PRCSLP
	
	CLRM	@ZSACCEL,L
	MOVE	@BUS_STEADY_Z,@ZSCROLL,L
	jauc	S_WAIT_HERE

	.endif

	.END




