 	.MLIB	"GXMACS.LIB"
	.FILE	"GXJSCROL.ASM"
	.TITLE	" <<< GENERATION X -- SCROLL TABLE FOR JUNGLE >>>"
	.WIDTH	132
	.OPTION	B,D,L,T
	.MNOLIST

	.include	"gx.inc"
	.INCLUDE	"GXSTRING.H"		;String processor
	.INCLUDE	"IMGTBL.GLO"
	.INCLUDE	"UNIVTBL.GLO"
	.include	"gxbax.tbl"
	.include	"gxscrl.h"
	.include	"gxnatv.h"

OLD_HONEY	.set	0	
YES_SNAKE	.set	0     
YES_BUG		.set	1
TEST_BUG	.set	0

**************************************************************************
*								         *
* 	COPYRIGHT (C) 1992 MIDWAY MANUFACTURING COMPANY.		 *
* 		       ALL RIGHTS RESERVED.				 *
*								         *
**************************************************************************

* SYMBOLS IN HERE
	.def	SUCK_ME_IN,BLOW_GLASS_OUT     	
	.def	ENTER_SECRET_ROOM,ENTER_DEADEND 	
	.def	JUNGLE_SCROLL,JOE_PERRY_TRIP
	.DEF	ELEVATOR_RIDE,ENTER_CHEM_RML 

	.DEF	BILL_SCROLL,END_JUNGLE

	.DEF	ATTRACT2

* SYMBOLS FROM ?
	.ref	SUCK_INTO_DEADEND,DEADEND_RETURN,BTR_HANG_TIME,S_ADD_TMPOBJ
	.ref	S_START_GOOP,S_RESET_VIDCAM,S_CREATE_PILLAR_BOYS,BRIDGE_STATE
	.ref	S_CREATE_ATRIUM_BOYS,S_WAIT_FOR_ZIPOK,MORFGLASOUT
	.ref	SIGN_DOWN,S_INIT_JUNGLE,NMEEZ_GONE1,CHECK4_CHEM_DAM 
	.ref	JXLIMIT,IN_SECRET,S_DELETE_ENEMY_OID,S_PUSH_WALL_IN
	.ref	CHEM_VECT_TABLE,FLOAT_ZFAR,BLDG_VECT_TABLE,S_WAIT_FOR_COUNTDOWN
	.ref	S_SET_IRQSTRT,S_MERGE_UNIV,MAX_ALLOWED,S_INIT_POPQUO
	.ref	SPRINKLE_POWERUPS,S_SHOCKER,BONUS_DIRECTION,S_KILL_ALL_PROCS
	.ref	S_SEND_ELEV_DOWN,S_INIT_NATIVES,PERRY_SKY_PROC,S_PERRY_FLY
	.ref	S_BRNCH_ON_WORD_VAL,S_CREATE_MASS_ATRIUM,S_CREATE_BZERKS

* SYMBOLS FROM GXBUG.ASM
	.REF	START_BUG_PROC, BLOW_COVER_PROC

***** from GXWAVE.ASM
	.REF	DSP_JUNG_3DOORS, DSP_JUNG_TREE1, DSP_JUNG_TREE2
	.REF	DSP_JUNG_ELEV,DSP_JUNG_ENDHALL ; ,DSP_JUNG_BIGWALL 

***** from GXJUNGLE.ASM
	.REF	SPIN_SIGN_GONE, JUNGLE_VECT_TABLE, S_CLR_OU_OHITS 

* SYMBOLS FROM GXUNISEQ.ASM
	.REF	SLDORCLOSE, DOORSWING_CLOSE

***** from GXSCROL3.ASM
	.REF	SND_SWEET_EMOTION

***** from GXRAM.ASM
	.REF	ENEMY_HITALL

***** from GXBEEK1.ASM
	.REF	S_START_MORFERS

***** from GXWARREN.ASM
	.IF	YES_SNAKE
	.REF	CREATE_A_SNAKE
	.ENDIF

	.data

**************************************************************************
*								         *
* 	SOUND TABLES
*								         *
**************************************************************************


SND_JUNGLE:	   
	.word	0F3fdh,1,5040h,0		; jungle bg
SND_JUNGLE_END:	   
	.word	0F3fdh,110,8041h,53e6h,0	; jungle bg
SND_NATIVE_TUNE
	.WORD	0F0FDH,1,08022H,0

SND_HONEY:	   
	.word	0F0FDh,1,8023h,0		; buzzing 
SND_PLANT_MUSIC:	   		
SND_HONEY_END:	   
;	.WORD	0F0dcH,1,08010H,0	; end of buzzing
	.WORD	0F0dcH,1,08022H,0	; end of buzzing
SND_CHEM_MUSIC
	.word	0f0dch,1,8011h,0
SND_FACTORY_MUSIC
	.word	0f0dch,1,8010h,0
SND_ESCAPE_MUSIC
;	.word	0f0dch,1,8014h,0
	.word	0f0dch,1,8004h,0

SND_NICE_SHOT
	.word	0f3a0h,67,8813h,0
SND_WHOA
	.word	0f3c4h,60,8805h,0
SND_KICKASS
	.word	0f3f2h,53,0881dh,0
SND_MAMBY_PAMBY
	.word	0f3f2h,58,08817h,0
SND_SQUASH:	   
	.word	0F3c0h,171,8832h,0		; squash em like bugs
SND_ST_GO:	   
	.word	0F3c0h,26,880eh,0		; Go!

SND_ELEV_MUSIC	.word	0f0dch,1,8018h,0
;SND_HALL_BONK	.word	0f3f0h,22,81ffh,0	
SND_HALL_BONK	.word	0f3c0h,22,0a40bh,0

SND_OUTA_HERE
	.word	0f3f2h,62,08809h,0


**************************************************************************
*								         *
* MESSAGE MACROS							 *
*								         *
**************************************************************************
**************************************************************************
*								         *
* 		SCROLL TABLE FOR THE AMAZON				 *
*								         *
**************************************************************************

	.ref	ENAB3DRS


JUMP_IF_SET	.macro   bit,addr
	.if	DEBUG
	.LONG	S_JUMP_IF_BIT_SET
	.long	addr
	.long	SCRLFLOW
	.word	bit
	.endif
	.endm


JUMP_IF_CLR	.macro   bit,addr
	.if	DEBUG
	.LONG	S_JUMP_IF_BIT_CLR
	.long	addr
	.long	SCRLFLOW
	.word	bit
	.endif
	.endm

	.if DEBUG
	.def    SCRLFLOW
	.bss	SCRLFLOW,16	; bit flags to dynamically control
				; scrolling through jungle
	.bss	dbgwaste,16	; to keep long word aligned
	.endif

	.def	SECRET_SCROLL
	.bss	SECRET_SCROLL,32	; scroll table to jump to.
	.bss	SAVPLYRSEEN,16		; for elevator
	.bss	filler,16


GET_BEFORE_MAIN_DOOR	.set 0		; go directly to main door
GET_TO_MAIN_DOOR	.set 1		; go directly to main door
GET_TO_OUTDECISION	.set 2		; go to decision point in jungle
SKIP_JUNGLE_CRUISE	.set 3		; go directly to first bldg
SKIP_FIRST_BLDG		.set 4		; skip first bldg and do honeycombs
SKIP_JUNG_BTR		.set 5		; no BTR in jungle
SKIP_FIRST_HALL		.set 6		; skip pillar guys
SKIP_SKULL		.set 7		; no skull
SKIP_GXHALL1		.set 8		; go to arch entrance left
GOTO_HONEYCOMBS		.set 9		;
SKIP_GXHALL2		.set 10		; go to arch entrance rt
SKIP_LOBBY		.set 11		; skip lobby 
SKIP_PLANT		.set 12		; skip chem plant 


**************************************************************************
*								         *
* 	S_MAKE_KICKASS							 *
* 									 *
* 	Scroll func to make the kick ass sound if we can.		 *
*								         *
**************************************************************************
S_MAKE_KICKASS
	ADJUST	ADJPROFANITY
	JRNZ	SMK_PG13

	SOUND1	SND_MAMBY_PAMBY		;Do mamby pamby sound
	JAUC	SCRL_DISPATCHER

SMK_PG13
	SOUND1	SND_KICKASS
	JAUC	SCRL_DISPATCHER
	
**************************************************************************
*								         *
* 	Special tables for the Jungle universe 	 
*								         *
**************************************************************************
SUCK_ME_IN:				; if you shoot the right door
	.LONG	S_MERGE_UNIV
	.long	gxjrtpt

	.LONG	S_SET_WORD
	.long	NMEEZ_GONE1
	.word	0			; forget those punks

	.LONG	S_SET_LONG		; don't enable enemy gens in dist yet
	.long	UEP_Z
	.long	8000h

	.LONG	S_DISABLE_ENEMY_GENS	; disab natives and cogs in center

	.LONG	S_CLR_XMOTION

;	.LONG	S_ACCEL_TO_POINT
;	.word	-48
;	.word	440h,0h
;	.long	-09000h
;	.word	0

	.LONG	S_SET_WORD
	.long	IN_SECRET
	.word	1			; in a secret room

	.long	S_SET_ENEMIES		; noone to bother you
	.word	0		   


	.LONG	S_GOTO_POINT0
	.word	-70
	.word	41ch,0
	.long	-1000h
	.word	0

	.LONG	S_DELETE_ENEMY_OID	; protection
	.word	OID_NONBOY

	.LONG	S_Z_ACCEL_BURST
	.word	20H				;Z DESTINATION
	.word	15				;DURATION

	.LONG	S_DELETE_ENEMY_OID	; protection
	.word	OID_BZERK

	.LONG	S_CREATE_PROCR
	.word	PID_POWERUPD0
	.word	3d0h,468h		; x range
	.long	0,17800h,18		; junk, zmax, num crates
	.LONG	SPRINKLE_POWERUPS
	.word	0


	.LONG	S_DECEL_TO_STOP
	.word	4

	.LONG	S_WAIT_HERE
	.word	160	     	; peruse the joint    

	.LONG	S_Z_ACCEL_LIMIT	
	.word	0ah     		      
	.long	00a0h				

JU_SECRET_HOOK:
	.long	S_WAIT_FOR_ZABS
	.long	19660H			 ; Stop at wall and ...
	.word	0

	.long	S_DECEL_TO_POINTZ
	.word	10
	.long	19660h				;Stop at wall and ...
	.word	0

	.LONG	S_GOTO_POINTXY		;GO THROUGH HOLE IN WALL
	.word	140
	.word	329h,0h
	.WORD	0    			; SLEEP UPON ARRIVAL

	.LONG	S_SET_WORD
	.long	IN_SECRET
	.word	0			; out of secret room

	.LONG	S_SET_WORD		; bonus for bypassing cameras
	.long	PLYR_SEEN
	.word	0

	.LONG	M_JUMP+JU_BTR_HOOK



BLOW_GLASS_OUT:				; if you shoot the right door
	.LONG	S_MERGE_UNIV
	.long	gxjltpt

	.LONG	S_SET_LONG		; don't enable enemy gens in dist yet
	.long	UEP_Z
	.long	8000h

	.LONG	S_DISABLE_ENEMY_GENS	; disab natives and cogs in center

	.LONG	S_SET_WORD
	.long	IN_SECRET
	.word	1			; in a secret room

	.long	S_SET_ENEMIES		; noone to bother you
	.word	0		   

	.LONG	S_START_DANIM_VISIBLE	; open stained glass portals

	.LONG	S_STOP_SCROLL

	.LONG	S_GOTO_POINT0		; get in front of stained glass
	.word	-60
	.word	238h,20h
	.long	-05000h
	.word	40			; wait

	.LONG	S_Z_ACCEL_BURST
	.word	70
	.word	10

	.LONG	S_Y_ACCEL_BURST
	.word	-1000h			; neg means down
	.word	30

;	.LONG	S_WAIT_FOR_ZREL
;	.long	-1700h
;	.word	1		; keep going

	.LONG	S_CREATE_PROCR
	.word	PID_POWERUPD0
	.word	1e0h,280h
	.long	0,17800h,18,SPRINKLE_POWERUPS
	.word	0

	.LONG	S_DECEL_TO_STOP
	.word	4

	.LONG	S_SOUND	  		 
	.long	SND_HONEY_END

	.LONG	S_WAIT_HERE
	.word	110	     	; peruse the joint    

	.LONG	S_Z_ACCEL_LIMIT	
	.word	12     		      
	.long	0120h				


	.LONG	M_JUMP+JU_SECRET_HOOK


********************************************************
*						       *
* 	START OF JUNGLE				       *
*						       *
********************************************************
JUNGLE_SCROLL:
	

********************************** TEST SHIT
;	.ref	SYNC_SOUND_TEST
;
;	.LONG	S_CREATE_PROC
;	.word	PID_JUNK
;	.long	SYNC_SOUND_TEST
;
;	.long	0
;
********************************** TEST SHIT


	.LONG	S_INIT_JUNGLE

	LW	S_AUDIT, AUDJUNGLE

	.LONG	S_SET_LONG
	.long	UEP_Z			; world Z for enemies
	.long	22000h

	.LONG	S_WAIT_HERE
	.word	15	 

;	.LONG	S_ACCEL_TO_POINT	; cross bridge
;	.word	(60*3)+30
;	.word	-3e8h,0
;	.long	-28000h
;	.word 	0

	.LONG	S_Z_ACCEL_BURST
	.word	6	
	.word	80	

	.LONG	S_WAIT_FOR_ZABS
	.long	-28000h
	.word	1

	.LONG	S_DECEL_TO_STOP
	.word	6

	.LONG	S_AT_PORTAL_ENTRANCE

	.LONG	S_SET_PORTAL		; Search For Portal we are centered on
	.word	18			; tiks til portal animation starts     

	.LONG	S_ENTER_PORTAL		; Set up and enter new universe
	.long	GXJUNG3+M_EP_SMOOTH	; name of universe
	.long	-1e000h,-3e80000h,0 	; Z, X, Y offsets

	.LONG	S_INIT_NATIVES
	.word	4,6			; natives allowed,spears allowed

	.LONG	S_Z_ACCEL_BURST
	.word	1
	.word	200

	.LONG	S_SET_LONG
	.LONG	WXBUFFER
	.LONG	0200000H

**********************************************************
	JUMP_IF_CLR	GET_TO_OUTDECISION,JCONTIN1

	.if	DEBUG

	.LONG	S_SET_LONG
	.long	UEP_Z			; world Z for enemies
	.long	14000h

	.LONG	S_SET_WORD
	.long	ENAB3DRS
	.word	0			; disable door shooting

	.LONG	S_GOTO_POINT0		; goto decision point
	.word	-60*4
	.word	0329h,30h      
	.long	-0f000h	       
	.word 	10

;	.long	S_SET_VECTOR_TABLE
;	.long	BLDG_VECT_TABLE

	.LONG	S_CREATE_PROCR
	.word	PID_IND
	.long	0,0,0,28000h,FLOAT_ZFAR	; behind wall
	.word	0

	.LONG	M_JUMP+DECIS_PT

	.endif
JCONTIN1:
	JUMP_IF_CLR	GOTO_HONEYCOMBS,JCONTIN5

	.if	DEBUG

JCONTIN5A:
	.LONG	S_SET_LONG
	.LONG	WYBUFFER
	.LONG	0500000H

;	.long	S_SET_VECTOR_TABLE
;	.long	BLDG_VECT_TABLE

	.LONG	M_JUMP+DO_HONEY
	.endif
JCONTIN5:
**********************************************************

**********************************************************
	JUMP_IF_CLR	GET_BEFORE_MAIN_DOOR,JCONTIN2
	.if	DEBUG

	.LONG	S_GOTO_POINT0
	.word	-200
	.word	329h,0
	.long	26000h
	.word	60	

	.LONG	S_SET_IRQSTRT

;	.long	S_SET_VECTOR_TABLE
;	.long	BLDG_VECT_TABLE

	.LONG	M_JUMP+JU_DO_BTR
	.endif

JCONTIN2:
	JUMP_IF_CLR	GET_TO_MAIN_DOOR,JCONTIN3
	.if	DEBUG

	.LONG	S_GOTO_POINT0
	.word	-200
	.word	329h,22h
	.long	30000h
	.word	0

;				DUPLICATE CHANGE
;	.LONG	S_GOTO_POINT0
;	.word	-200
;	.word	329h,0
;	.long	033000H
;	.word	0	
;
;	.LONG	S_GOTO_ZPOINT
;	.WORD	-10
;	.LONG	033000H
;	.WORD	60

;	.long	S_SET_VECTOR_TABLE
;	.long	BLDG_VECT_TABLE

	.LONG	M_JUMP+AT_MAIN_DOOR

	.endif
JCONTIN3:
**********************************************************

	JUMP_IF_SET	SKIP_JUNGLE_CRUISE,JCONTIN4

	.LONG	S_SOUND
	.long	SND_JUNGLE

	.LONG	S_SOUND, SND_NATIVE_TUNE

	.long	S_SET_ENEMIES			; set to tell natives and
	.word	M_OF_BUSH|M_OF_TREE|M_OF_SNAKE  ; snake to activate
*
*	START OF JUNGLE CRUISE
*
	.if YES_SNAKE	   
	.LONG	S_CREATE_PROC
	.word	PID_IND
	.long	CREATE_A_SNAKE
	.endif		   

	.LONG	S_DISPATCH_HERE, DSP_JUNG_TREE1+M_WAIT
	.WORD	0

	.LONG	S_GOTO_POINT0
	.word	-3*60
	.word	-3f8h,0
	.long	-1f000h
	.word	60			; FIrst lockdown

	LW	S_WAIT_HERE,10

	LW	S_WAIT_HERE, 1+M_QUOTA	;Wait for quota on Natives

	.LONG	S_DISPATCH_HERE, DSP_JUNG_TREE2+M_WAIT
	.WORD	0

JUNGLE_JUMP:
	.LONG	S_GOTO_POINT0		; move in past vinetree
	.word	-6*60
	.word	-42eh,0
	.long	-13000h
	.word 	0

	.LONG	S_GOTO_POINT0		; cut left and back
	.word	-6*60
	.word	-500h,0
	.long	-17000h
	.word 	0

	.LONG	S_GOTO_POINT0		; move	back
	.word	-12*60
	.word	-66bh,0
	.long	-1da1ch
	.word 	0
	
	LLW	S_SET_WORD, MAX_ALLOWED, 6

	.LONG	S_GOTO_POINT0
	.word	-12*60
	.word	-445h,0
	.long	-14000h		   
	.word 	0

	LLW	S_SET_WORD, MAX_ALLOWED, 8

	.LONG	S_GOTO_POINT0		; first vidcam
	.word	-10*60 
	.word	-231h,0
	.long	-1ca1ch
	.word 	200		   	; 2nd lockdown

	.LONG	S_GOTO_POINT0		; 2nd vidcam
	.word	-7*60
	.word	-139h,0
	.long	-2121ch
	.word 	0

	.if YES_SNAKE  
	.LONG	S_SET_WORD
	.long	SCROLLKILL	
	.word	1		; number of processes to die now
				;  (CREATE_A_SNAKE)
	.endif 

	LW	S_WAIT_HERE, 1+M_QUOTA	;Wait for quota on Natives

JCONTIN4:

	.LONG	S_RESET_VIDCAM

	JUMP_IF_SET	SKIP_FIRST_BLDG,JCONTIN5A

	.LONG	S_SET_WORD
	.long	NUM_OUT_THERE
	.word	0

	.long	S_SET_ENEMIES		; set to tell natives and
	.word	0			; snake to deactivate

	.LONG	S_GOTO_POINT0		; get to bldg
	.word	-60*2	       
	.word   -0a0h,0
	.long	-1f000h
	.word	0

;	.long	S_SET_VECTOR_TABLE
;	.long	BLDG_VECT_TABLE

	.LONG	S_GOTO_POINT0		; move in to spinning sign
	.word	-60*4
	.word   0bh,0	       
	.long	-10a00h
	.word	1

	.LONG	S_SETUP_DSJ
	.word	5
SPINSIGN_LP:
	.LONG	S_JUMP_IF_TRUE, GO_PAST_SIGN, SPIN_SIGN_GONE
	LW	S_WAIT_HERE, 20

	.LONG	S_DSJ,SPINSIGN_LP

GO_PAST_SIGN
	.LONG	S_SET_LONG
	.long	UEP_Z			; world Z for enemies
	.long	1e000h

	.LONG	S_SET_WORD
	.long	JXLIMIT			; X dist for sideways runners
	.word	88h

	.LONG	S_SET_LONG
	.LONG	WYBUFFER
	.LONG	0500000H

	.LONG	S_INIT_POPQUO		; sets NMEEZ_GON,MAX_ALLOWED,OBJENEMIES
	.word	3			; number

	.LONG	S_KILL_POWERUPS			;Whack those powers

	.LONG	S_CREATE_PROC
	.word	PID_IND
	.long	SomeSoundStuff

	.LONG	S_GOTO_POINT0		; go in towards bldg
	.word	-60*2
	.word   0beh,64h
	.long	-9000h
	.word	1*60


	.LONG	S_WAIT_FOR_COUNTDOWN	; wait until popup quotas done 
	.long	NMEEZ_GONE1

	.long	S_SET_ENEMIES		; set to tell popups and
	.word	0			; siderunners to stop

DO_HONEY:
	LLW	S_SET_WORD, MAX_ALLOWED, 4     

	.LONG	S_SET_LONG
	.long	UEP_Z			; world Z for enemies
	.long	14000h

	.LONG	S_CREATE_PROCR
	.word	PID_IND
	.long	0,0,0,28000h,FLOAT_ZFAR	; behind wall
	.word	0

	.long	S_SET_ENEMIES		; set to tell honeycombs
	.word	M_OF_HONEY		; to activate (AU_CREATE_BUGEYZ)

	.LONG	S_SET_WORD
	.long	ENAB3DRS	   ; use for counting destroyed honeycombs
	.word	0		   ; to enable secret portal entry

	.LONG	S_GOTO_POINT0		; go to honeycombs
	.word	-100
	.word	01b8h,20h
	.long	-0b080h
	.word 	0

	.LONG	S_SET_WORD
	.long	NUM_OUT_THERE
	.word	0

	.LONG	S_SOUND	  		 
	.long	SND_HONEY

	.LONG	S_DELETE_ENEMY_OID	; protection
	.word	OID_NONBOY

	.LONG	S_SOUND	  		 
	.long	SND_SQUASH

HONEY_LOOP:
	.LONG	S_GOTO_POINTXY	   ; go to honeycombs
	.word	60*8
	.word	0208h,180h
	.word 	0

	.LONG	S_GOTO_POINTXY	   ; go to honeycombs
	.word	60*8
	.word	0258h,20h
	.word 	0

	.LONG	S_SOUND	  		 
	.long	SND_HONEY_END

	.LONG	S_WAIT_HERE
	.word	20

	.LONG	S_SET_WORD
	.long	ENAB3DRS
	.word	0			; disable door shooting

	.long	S_SET_ENEMIES		; set to tell honeycombs
	.word	0			; to disable (AU_CREATE_BUGEYZ)

	.LONG	S_GOTO_POINT0		; goto decision point
	.word	-60*2
	.word	0329h,30h	     
	.long	-0f000h		     
	.word 	10

DECIS_PT:
	.LONG	S_RESET_VIDCAM

	.LONG	S_MAKE_DECISION			;FUNCTION
	LW	0,0				;-X, Count
	LW	JU_3DOORS,1			;+X, Count
	LW	0,0				;-Y, Count
	LW	0,0				;+Y, Count
	LW	0,0				;-Z, Count
	LW	JU_TOMAIN,1 			;+Z, Count


JU_3DOORS:
	.LONG	S_SET_WORD
	.long	JXLIMIT			; X dist for sideways runners
	.word	120h

	.LONG	S_SET_WORD
	.long	NUM_OUT_THERE
	.word	0

	.LONG	S_SET_WORD
	.long	NMEEZ_GONE1		; tell us how many guys are out there
	.word	5	       

	LLW	S_SET_WORD, MAX_ALLOWED, 1	; for popups
	
	.long	S_SET_ENEMIES		; set to tell popups
	.word	M_OF_POPUP|M_OF_SIDER	; to activate 

	.LONG	S_X_ACCEL_BURST		; goto window above 3 doors
	.word	800h
	.word 	40

	.LONG	S_WAIT_FOR_COORD
	.long	XBASE
	.long	4a00000h
	.word	1

	.LONG	S_DECEL_TO_STOP
	.word	6

	.LONG	S_GOTO_POINT0		; back away
	.word	60*2
	.word	04A0h,0h
	.long	-10000h
	.word 	0

	.LONG	S_CREATE_PROCR
	.WORD	PID_POWERUPD0
	.long	0b000h,07000h,300,200,PROC_DROP_PACK	; by berzerkers
	.word	0

	.long	S_SET_ENEMIES	; set to tell popups to stop
	.word	M_OF_SIDER  

	.LONG	S_DISPATCH_HERE
	.LONG	DSP_JUNG_3DOORS+M_WAIT	;Do the dispatch
	.WORD	0
	
	.LONG	S_SET_WORD
	.long	ENAB3DRS
	.word	1			; enable door shooting

	LW	S_WAIT_HERE, 1+M_QUOTA	;Wait for all enemies to go

	.LONG	S_KILL_POWERUPS

	.LONG	S_GOTO_POINT0		; goto decision point
	.word	60*3
	.word	0329h,3ch
	.long	-0f000h
	.word 	18

	.long	S_SET_ENEMIES		; set to tell popups
	.word	0			; to disable

	.LONG	S_SET_WORD
	.long	ENAB3DRS
	.word	0			; disable door shooting

	.LONG	S_DELETE_ENEMY_OID	; protection
	.word	OID_NONBOY

	.LONG	S_DELETE_ENEMY_OID	; protection
	.word	OID_BZERK

JU_TOMAIN:
	LLW	S_SET_WORD, MAX_ALLOWED, 5	; for natives
	LLW	S_SET_WORD, NUM_OUT_THERE, 0	; for natives

	.long	S_SET_ENEMIES		; set to tell natives
	.word	M_OF_CNATV		; to jump out (AU_CREATE_NATIVE)

	.LONG	S_SET_LONG
	.long	UEP_Z
	.long	28000h

	.LONG	S_SET_WORD
	.long	JXLIMIT			; X dist for sideways runners
	.word	1b0h

	.LONG	S_Z_ACCEL_BURST
	.word	4
	.word	25

	LW	S_WAIT_HERE,400

	.LONG	S_SET_LONG
	.long	UEP_Z			; cut it short
	.long	8000h

	LLW	S_OR_WORD,OBJENEMIES,M_OF_BCOG	;Start the COGs

	.LONG	S_WAIT_FOR_ZREL
	.long	0e000h
	.word	1		; keep going

	.long	S_SET_ENEMIES	; stop em all
	.word	0		; 

	.LONG	S_DELETE_ENEMY_OID	; protection
	.word	OID_COG

JU_BTR_HOOK:
	.LONG	S_SET_LONG
	.long	WXBUFFER
	.long	600000h

	.LONG	S_GOTO_POINT0
	.word	-60
	.word	329h,0
	.long	17800h
	.word	0

	.LONG	S_SET_WORD		; kill float process
	.long	SCROLLKILL
	.word	1

	.LONG	S_GOTO_POINT
	.word	-10
	.word	329h,0
	.long	17800h
	.word	0

	; SCALE THE WALL
	;  ALSO this is where you come if you got out of the secret rooms

;	.LONG	S_MAKE_DECISION			;FUNCTION
;	LW	LFT_MISTAKE,1			;-X, Count
;	LW	RT_MISTAKE,1			;+X, Count
;	LW	SCALE_WALL,1 			;-Y, Count
;	LW	0,0				;+Y, Count
;	LW	0,0				;-Z, Count
;	LW	0,0 				;+Z, Count
;
;	.LONG	SCALE_WALL+M_JUMP
;
;LFT_MISTAKE:
;	.long	S_GOTO_POINTXY
;	.word	120
;	.word	328h-180h,0
;	.word	120
;
;;	.LONG	S_DISPATCH_HERE
;;	.LONG	DSP_JUNG_BIGWALL+M_WAIT	;Do the dispatch
;;	.WORD	0
;;
;;	LW	S_WAIT_HERE, 1+M_QUOTA	;Wait for quota on Berzerkers
;
;	.LONG	M_JUMP+MISTAKE_HOOK
;
;
;RT_MISTAKE:
;	.long	S_GOTO_POINTXY
;	.word	120
;	.word	328h+180h,0
;	.word	120
;

;MISTAKE_HOOK
;	.long	S_GOTO_POINTXY
;	.word	120
;	.word	328h,0
;	.word	0

SCALE_WALL:
	.long	S_SET_LONG
	.long	WYBUFFER
	.long	1320000h

	.LONG	S_SET_LONG
	.long	ZSACCEL
	.long	500

	.LONG	S_SET_LONG     
	.long	YSACCEL			; POS MEANS UP!
	.long	3000h

	.LONG	S_WAIT_FOR_COORD
	.long	YBASE
	.long	7e0000h	   
	.word	1

	.LONG	S_SET_LONG
	.long	YSACCEL
	.long	-3000h

	.LONG	S_WAIT_FOR_ZREL
	.long	23800h
	.word	1

	.LONG	S_SET_LONG
	.long	ZSACCEL
	.long	-800

	.LONG	S_WAIT_FOR_COORD
	.long	YBASE
	.long	7e0000h	     
	.word	1		; maintain Y motion

	.long	S_CLR_ZMOTION

	.LONG	S_SET_LONG
	.long	YSACCEL
	.long	3000h

	.LONG	S_WAIT_FOR_COORD
	.long	YBASE
	.long	0h
	.word	0	     	; stop Y motion

	.long	S_SET_LONG
	.long	WYBUFFER
	.long	320000h

	.LONG	S_SET_LONG
	.long	WXBUFFER
	.long	200000h

JU_DO_BTR:

	.LONG	S_CREATE_PROCR
	.WORD	PID_POWERUPD0
	.long	0b000h,07000h,200,100,PROC_DROP_PACK	; behind wall
	.word	0

	JUMP_IF_SET	SKIP_JUNG_BTR,JCONTIN6

	.LONG	S_SET_LONG,UEP_Z,28000h

	LLW	S_SET_WORD, MAX_ALLOWED, 1	; for popups

	.long	S_SET_ENEMIES		; set to tell popups and
	.word	M_OF_SIDER|M_OF_POPUP	; siderunners to activate 

	.LONG	S_GOTO_POINT0
	.word	90
	.word	329h,0h
	.long	2e000h
	.word	0

	.LONG	S_CREATE_PROC			;BTR
	.word	PID_IND
	.long	CREATE_TROOPTRANS	; sets BTR_HANG_TIME to 1

	LW	S_AUDIT, AUDJUBTR

	.LONG	S_SET_WORD
	.long	BTR_HANG_TIME
	.word	200h

BTR_LOOP:				      
	.long	S_WAIT_HERE
	.word	150		      

	.long	S_SET_ENEMIES		; set to
	.word	M_OF_SIDER		; kill popups

	.LONG	S_SET_WORD
	.long	JXLIMIT			; X dist for sideways runners
	.word	1b0h

	.LONG	S_WAIT_UNTIL_TRUE		;IS THE BTR GONE YET?
	.long	BTR_GONE

;;;;	.LONG	S_SET_WORD			; Kill it (0)	 or
;;;;	.long	BTR_GONE			; Bring it back (neg)
;;;;	.word	-1     				; Triggered by setting 
						; BTR_GONE to zero

;;;;	.LONG	S_WAIT_HERE
;;;;	.word	300


	.LONG	S_SET_WORD     
	.long	BTR_GONE       
	.word	0
     	
;;;;;;      	.LONG	M_JUMP+BTR_LOOP


JCONTIN6:
	.long	S_SET_ENEMIES		; set to tell popups and
	.word	M_OF_SIDER|M_OF_POPUP	; siderunners to activate 

	.LONG	S_SET_LONG
	.long	UEP_Z			; world Z for enemies
	.long	22000h

	.LONG	S_KILL_POWERUPS			;Whack those powers

	.LONG	S_GOTO_POINT0
	.word	-6*60
	.word	329h,22h
	.long	30000h
	.word	30

AT_MAIN_DOOR:
	.LONG	S_SET_ENEMIES	; set to tell popups and
	.word	0		; siderunners to stop

	.LONG	S_SET_WORD
	.long	NUM_OUT_THERE
	.word	0

	.LONG	S_WAIT_HERE
	.word	20

	.LONG	S_SET_LONG
	.long	YSACCEL
	.long	-1800h

	.LONG	S_Z_ACCEL_LIMIT			;MOVE TOWARD DOORS
	.WORD	020H				;Z ACCEL
	.LONG	02c0H				;Z MAX. VELOCITY

	.LONG	S_CLR_ACCELS		; really for Y

	.LONG	S_WAIT_FOR_ZREL
	.LONG	033000H		 
	.WORD	1

;	.if	BILL
;
;	.LONG	BILL_REVERSE_TEST+M_JUMP
;
;	.endif

	.LONG	S_RESET_VIDCAM

	.LONG	S_SET_LONG
	.long	WAVE_IPLANE,0		; no infinity plane when we enter

	.long	S_SET_VECTOR_TABLE
	.long	BLDG_VECT_TABLE

	.LONG	S_AT_PORTAL_ENTRANCE

	.LONG	S_SET_PORTAL		; Search For Portal we are centered on
	.word	19	

	.LONG	S_ENTER_PORTAL		; Set up and enter new universe
	.long	GXEVLOB3+M_EP_SMOOTH+M_EP_WAIT  	; name of universe
;	.long	-1c800h,188000h,0 	; Z, X, Y offsets
	.long	-1c000h,188000h,0 	; Z, X, Y offsets

	.LONG	S_SOUND	  		 
	.long	SND_CHEM_MUSIC

	.LONG	S_DELETE_ENEMY_OID	; protection
	.word	OID_NONBOY

JUNGLE_SCROLL_LOOP:
;	.LONG	S_WAIT_HERE
;	.word	30

	.LONG	S_ALLOW_PORTALS

	JUMP_IF_SET	SKIP_LOBBY,AT_HALL1_ENTRANCE

	.LONG	S_CLR_OU_OHITS		; for hit counting
	.word	OID_UNIV|(1<<BIT_ID),OID_UNIV|(6<<BIT_ID)
					; universe ID range of chains
	.word	6			; number of pieces to look for

	.LONG	S_DECEL_TO_POINTZ   	; Lock down in front of desk
	.word	-90
	.long	-1c000h		;-1c400h
	.word	0

	LW	S_AUDIT, AUDJUDESK

	.LONG	S_WAIT_UNTIL_FALSE
	.long	SIGN_DOWN

	.LONG	S_WAIT_HERE
	.word	50

	.LONG	S_SOUND
	.long	SND_NICE_SHOT

	.LONG	S_WAIT_HERE
	.word	50

	.LONG	S_ACCEL_TO_POINT	; start over desk
	.word	-25
	.word	18h,20h
	.long	-19000h
	.word	0

	.LONG	S_DECEL_TO_POINT	; come back down
	.word	-35
	.word	18h,0
	.long	-016000h
	.word	0

	.LONG	S_GOTO_POINTZ
	.word	-90
	.long	-10d00h
	.word	0

	JUMP_IF_SET	SKIP_FIRST_HALL,JCONTIN7

	.LONG	S_CREATE_PROCR
	.WORD	PID_POWERUPD0
	.long	0b000h,07000h,300,100,PROC_DROP_PACK	; behind wall
	.word	0

	.LONG	S_BRNCH_ON_WORD_VAL	; branch based on value
	LW	PLYR_SEEN,2		; variable, num choices
	.long	FH_0			; if PLYR_SEEN = 0
	.long	FH_1			; if PLYR_SEEN = 1
					; fall through if none of the above
	.LONG	S_CREATE_BZERKS
	.word	4		; how many (subject to CURPLYR adjustment)
	.word	30		; ticks between creation
	.word	-2ch,2ch	; world X range
	.long	9000h,18000h	; Z range

FH_1:
	.LONG	S_CREATE_MASS_ATRIUM
	.word	0,-67h	    ; avail : Y
	.word	46h,-12h    ; right x ,left x range 
	.long	-6000h	    ; start z
	.long	-6000h+(8*1800h)    ; end Z
	.word	18

FH_0:
	.LONG	S_RESET_VIDCAM

	.LONG	S_CREATE_PILLAR_BOYS
	.word	0,6	    ; Y, # pillars
	.word	46h,-12h    ; right x , left x
	.long	-8800h	    ; start z
	.long	3000h	    ; delta Z

	.LONG	S_CREATE_ATRIUM_BOYS
	.word	0,-67h	    ; avail : Y
	.word	46h,-12h    ; right x ,left x range 
	.long	-6000h	    ; start z
	.long	-6000h+(8*1800h)    ; end Z

	.LONG	S_KILL_ALL_PROCS	; kill flicker
	.word	PID_TCYCLE

	.LONG	S_CREATE_PROC
	.word	PID_IND
	.long	ROCK_IN_X

	.LONG	S_WAIT_FOR_ZIPOK

ZIP_LOOP:
	.LONG	ZIP_FWD+M_CALL

	.LONG	S_JUMP_IF_TRUE
	.long	ZIP_LOOP
	.long	NUM_PILLARS

	.LONG	S_SET_WORD
	.long	SCROLLKILL	
	.word	2		; number of processes to die now
				;  (They know who they are)

JCONTIN7:

	.LONG	S_GOTO_POINT0
	.word	-30
	.word	18h,0
	.long	-10d00h+(6*3000h)+1000h
	.word	0

***********************************************************
	JUMP_IF_CLR	SKIP_FIRST_HALL,JCONTIN8

	.if	DEBUG

AT_HALL1_ENTRANCE:
	.LONG	S_GOTO_POINTZ
	.word	-90
	.long	-10d00h+(6*3000h)+1000h
	.word	0

	.endif
JCONTIN8:
***********************************************************
	.LONG	S_LOCKOUT_PORTALS	; disable elevator button

	.LONG	S_AT_PORTAL_ENTRANCE

	.LONG	S_SET_PORTAL		; Search For Portal we are centered on
	.word	30	

	.LONG	S_ENTER_PORTAL		; Set up and enter new universe
	.long	GXHALL3M+M_EP_SMOOTH+M_EP_WAIT	; name of universe 
	.long	-18000h,105000h,0 	; Z, X, Y offsets

	.LONG	S_CREATE_PROCR
	.word	PID_IND
	.long	0,0,0,0b040h,FLOAT_ZFAR
	.word	0

	.LONG	S_RESET_VIDCAM

	.LONG	S_WAIT_HERE
	.word	60

***********************************************************
	JUMP_IF_CLR	SKIP_GXHALL1,JCONTIN9
	.if	DEBUG

	.LONG	S_SET_WORD
	.long	SCROLLKILL	
	.word	1		; kill float process

	.LONG	S_MERGE_UNIV
	.long	GXHALL3L

	.LONG	S_KILL_POWERUPS		;Whack those powers 

	.LONG	S_GOTO_POINT0
	.word	-200
	.word	-33eh,0
	.long	1b000h	  
	.word	0

	.LONG	S_SET_WORD
	.long	ENEMY_QUOTA
	.word	0

	.LONG	M_JUMP+TEST_KLUDGE_LFT

	.endif
JCONTIN9:
***********************************************************

***********************************************************
	JUMP_IF_CLR	SKIP_GXHALL2,JCONT1
	.if	DEBUG

	.LONG	S_SET_WORD
	.long	SCROLLKILL	
	.word	1		; kill float process

	.LONG	S_MERGE_UNIV
	.long	GXHALL3R

	.LONG	S_KILL_POWERUPS		;Whack those powers 

	.LONG	S_GOTO_POINT0
	.word	-200
	.word	306h,0	 
	.long	1b000h	 
	.word	0

	.LONG	S_SET_WORD
	.long	ENEMY_QUOTA
	.word	0

	.LONG	M_JUMP+TEST_KLUDGE_RT

	.endif
JCONT1:
***********************************************************

	.LONG	S_WAIT_HERE
	.word	80		; give player time to shoot VIDCAM

	.LONG	S_Z_ACCEL_BURST
	.word	60h
	.word	20

***********************************************************
	JUMP_IF_CLR	SKIP_SKULL,JCONTIN10
	.if	DEBUG

	.LONG	S_WAIT_FOR_ZREL
	.long	-4801h-3800h
	.word	0		; stop

	.LONG	S_WAIT_HERE
	.word	15

	.LONG	S_GOTO_POINTZ
	.word	-60
	.long	-0fa0ch		;15694h
	.word	90

	.LONG	M_JUMP+PAST_SKULL
	.endif
***********************************************************

JCONTIN10:
	.LONG	S_SET_WORD    
	.long	SCROLL_FLAG	; will be cleared by skull dying and last iball
	.word	3			      

	.LONG	S_WAIT_HERE
	.word	10

	.LONG	S_START_GOOP
	.long	-4801h		; ZPOS (lo bit is RETREAT flag, 0=morph to iballs)
	.word	8	   	; wait 8 tiks

	.LONG	S_WAIT_FOR_ZREL
	.long	-4801h-3800h
	.word	0		; stop

;	.LONG	S_DECEL_TO_STOP	; hit the brakes
;	.word	5

	.LONG	S_SOUND
	.long	SND_WHOA

	.LONG	S_WAIT_HERE
	.word	15

	.LONG	S_GOTO_POINTZ
	.word	-60
	.long	-0fa0ch		;15694h
	.word	90

	.long	S_WAIT_UNTIL_FALSE	; bits cleared by skull retreat
	.long	SCROLL_FLAG		; and last eyeball gone

PAST_SKULL:
	.LONG	S_KILL_POWERUPS

	LW	S_AUDIT, AUDJUELEV

	.LONG	S_SET_ELEVATOR			; kills float proc,too.
	.long	EXIT_ELEVATOR,HALL1FLR2,HALL1FLR3

	.LONG	S_GOTO_POINTZ
	.word	-90
	.long	-1f00h		;20000h 
	.word	0      


	.LONG	S_ALLOW_PORTALS

	.LONG	S_WAIT_HERE
	.word	25		; time to hit elevator button

	.LONG	S_LOCKOUT_PORTALS

	.LONG	S_CHANGE_ZFAR
	.long	2a000h

	.LONG	S_MAKE_DECISION			;FUNCTION
	LW	J_LEFT,5			;-X, Count
	LW	J_RT,5				;+X, Count
	LW	0,0				;-Y, Count
	LW	0,0				;+Y, Count
	LW	0,0				;-Z, Count
	LW	0,0				;+Z, Count

*
*	NOTE:  Deadend hallway boundaries...  -204h, -15eh left of elev.
*					       133h,  1d8h rt of elev.
*
*


J_RT:
	.long	S_MERGE_UNIV
	.long	GXHALL3R

	.LONG	S_GOTO_POINTXY
	.word	330
	.word	306h,0	
	.word	2

	.LONG	S_BRNCH_ON_WORD_VAL	; branch based on value
	LW	PLYR_SEEN,2		; variable, num choices
	.long	RH_0			; if PLYR_SEEN = 0
	.long	RH_1			; if PLYR_SEEN = 1
					; fall through if none of the above
	.LONG	S_CREATE_MASS_ATRIUM
	.word	0,-67h	    ; avail : Y
	.word	32eh,2e2h   ; right x ,left x range 
	.long	9000h	    ; start z 
	.long	1f000h	    ; end Z   
	.word	20

RH_1:
	.LONG	S_CREATE_MASS_ATRIUM
	.word	0,-67h	    ; avail : Y
	.word	32eh,2e2h   ; right x ,left x range 
	.long	9000h	    ; start z  
	.long	1f000h	    ; end Z    
	.word	20

RH_0:
	.LONG	S_CREATE_PILLAR_BOYS
	.word	0,7	    ; Y, # pillars
	.word	336h,2dah    ; right x , left x
	.long	0b001h    ; start z	 
	.long	3000h	    ; delta Z

	.LONG	S_CREATE_ATRIUM_BOYS
	.word	0,-67h	    ; avail : Y
	.word	32eh,2e2h    ; right x ,left x range 
	.long	9000h    ; start z	  
	.long	1e000h              ; end Z 

	.LONG	S_GOTO_POINTZ_DELTA
	.word	50
	.long	3000h
	.word	0

	.LONG	LAST_HALL+M_CALL

	.LONG	S_GOTO_POINT0
	.word	-60
	.word	306h,0	 
	.long	1a800h	 	
	.word	0

TEST_KLUDGE_RT:
	.LONG	S_GOTO_POINT
	.word	-10
	.word	306h,0
	.long	1a800h	 
	.word	0

	.long	S_SET_VECTOR_TABLE
	.long	CHEM_VECT_TABLE

	.LONG	S_AT_PORTAL_ENTRANCE

	.LONG	S_SET_PORTAL		; Search For Portal we are centered on
	.word	25

	.LONG	S_ENTER_PORTAL		; Set up and enter new universe
	.long	GXINNR+M_EP_SMOOTH	; name of universe  
	.long	-1e900h,70c0000h,0 	; Z, X, Y offsets

	.LONG	S_SOUND, SND_FACTORY_MUSIC

	.LONG	S_SET_WORD
	.long	NUM_PILLARS		;use as morph chamber count
	.word	0

	.LONG	S_DELETE_ENEMY_OID
	.word	OID_NONBOY

	.if	TEST_BUG

	.LONG	S_WAIT_HERE
	.word	40

	.LONG	M_JUMP+J_HOOK	; TEST KLUDGE FOR BILL

	.endif

	.LONG	S_CREATE_PROCR
	.word	PID_IND
	.long	0,0,0,-03c00h,FLOAT_ZFAR
	.word	0

	.LONG	S_RESET_VIDCAM
;	.LONG	S_LOCKOUT_PORTALS


	.long	S_SET_ENEMIES		; set to tell popups and   
	.word	M_OF_BOXERS		; siderunners to stop 

	.LONG	S_SET_WORD
	.long	MAX_ALLOWED
	.word	8			; set number of box carriers

	.LONG	S_CREATE_BEEKS	; create beekeepers
	.word	0		; index 0 = outside chamber right

	.LONG	S_Z_ACCEL_BURST	; move in
	.word	6
	.word	20

	.LONG	S_SOUND	  		 
	.long	SND_PLANT_MUSIC

	.LONG	S_WAIT_FOR_ZREL
	.long	-13000h
	.word	1

	.LONG	S_CREATE_PROC
	.word	PID_BEEKPR
	.long	CHECK4_CHEM_DAM

*
* CHEM PLANT OUTER RIGHT CHAMBER    START
*
	.LONG	S_DECEL_TO_STOP
	.word	7

	JUMP_IF_CLR	SKIP_PLANT,JCONTIN11
	.if	DEBUG
	
	.long	S_SET_ENEMIES		; set to kill box carriers 
	.word	0			; 

	.LONG	M_JUMP+J_WARTEST		; TEST ONLY
	.endif

JCONTIN11:
	.LONG	S_WAIT_HERE
	.word	160

	.LONG	S_XYZ_ACCEL_BURST
	.word	-0a00h,0,15
	.word 	28

;	.LONG	S_GOTO_POINT0
;	.word	-200
;	.word	670h,0
;	.long	-0b800h			; move in to wall between consoles
;	.word	0

	.LONG	S_WAIT_HERE
	.word	30

	.LONG	S_Z_ACCEL_BURST
	.word	-15
	.word 	28

	.LONG	S_WAIT_FOR_COORD
	.long	XBASE
	.long	5e80000h
	.word	1

;	.LONG	S_GOTO_POINT0		; in closer
;	.word	-150
;	.word	5ddh,0
;	.long	-0b000h
;	.word	0

	.LONG	S_GOTO_POINT0		; out to second console
	.word	-200
	.word	637h,0
	.long	-12eebh		  
	.word	90

	.LONG	S_Z_ACCEL_BURST		; back off
	.word	-30
	.word	15

;	.LONG	S_WAIT_FOR_ZREL
;	.long	-15eebh
;	.word	1		; keep scrolling

	.LONG	S_SET_LONG     
	.long	YSACCEL			; POS MEANS UP!
	.long	1000h

	.LONG	S_WAIT_FOR_COORD
	.long	YBASE
	.long	240000h		
	.word	1

;	.LONG	S_SET_LONG
;	.long	YSACCEL
;	.long	-2000h

	.LONG	S_GOTO_POINT0		; after backwards jump over belt
	.word	-90
	.word	6a0h,0
	.long	-1d000h
	.word	300			; shoot beeks and boxes

	.LONG	S_GOTO_POINTXY		; move left slowly
	.word	500
	.word	529h,0
	.word	90

	.long	S_SET_ENEMIES		; set to kill box carriers 
	.word	0			; 

	.LONG	S_GOTO_POINT0	      
	.word	-300
	.word	4b3h,0
	.long	-13000h			; bubblers
	.word	90

	.LONG	S_GOTO_POINTZ		; move in between bubblers
	.word	-300
	.long	-0ec00h	
	.word	0

	.LONG	S_GOTO_POINTXY
	.word	300
	.word	53bh,0
	.word	0

	.LONG	S_GOTO_POINTZ
	.word	-400
	.long	-136ebh	
	.word	0
J_WARTEST:
	.LONG	S_GOTO_POINT0
	.word	-400
	.word	4e1h,0
	.long	-1c400h		; was -1c800h
	.word	0

	.LONG	S_SET_LONG
	.long	SECRET_SCROLL
	.long	ENTER_CHEM_RMR

	.LONG	S_START_MORFERS
	.word	44dh
	.long	-11800h

	.LONG	S_SET_SCROLL_FLAG      
	.long	-1			; set to all 1's to say it's okay

	.LONG	S_GOTO_POINTXY
	.word	120
	.word	448h,0			; lock on morph chamber
	.word	0

	.LONG	M_CALL+MORPH_CHMBR

*
* CHEM PLANT OUTER RIGHT CHAMBER    END
*

	.LONG	J_HOOK+M_JUMP

J_LEFT:
	.long	S_MERGE_UNIV
	.long	GXHALL3L

	.LONG	S_GOTO_POINTXY
	.word	330
	.word	-33eh,0	      
	.word	2

	.LONG	S_GOTO_POINTZ_DELTA
	.word	50
	.long	3000h
	.word	0

	.LONG	S_BRNCH_ON_WORD_VAL	; branch based on value
	LW	PLYR_SEEN,2		; variable, num choices
	.long	LH_0			; if PLYR_SEEN = 0
	.long	LH_1			; if PLYR_SEEN = 1
					; fall through if none of the above
	.LONG	S_CREATE_BZERKS
	.word	4		; how many (subject to CURPLYR adjustment)
	.word	55		; ticks between creation
	.word	-2ch,2ch	; world X range
	.long	9000h,18000h	; Z range
LH_1:
	.LONG	S_CREATE_BZERKS
	.word	4		; how many (subject to CURPLYR adjustment)
	.word	25		; ticks between creation
	.word	-2ch,2ch	; world X range
	.long	9000h,18000h	; Z range
LH_0:

	.LONG	S_CREATE_PILLAR_BOYS
	.word	0,7	    ; Y, # pillars
	.word	-30ah,-373h    ; right x , left x
	.long	0b003h	    ; start z	     
	.long	3000h	    ; delta Z

	.LONG	S_CREATE_ATRIUM_BOYS
	.word	0,-67h	    ; avail : Y
	.word	-30dh,-370h    ; right x ,left x range 
	.long	09000h		    ; start z  
	.long	1e000h              ; end Z  


	.LONG	LAST_HALL+M_CALL

	.LONG	S_GOTO_POINT0
	.word	-60
	.word	-33eh,0	       
	.long	1a800h	  
	.word	0
TEST_KLUDGE_LFT:
	.LONG	S_GOTO_POINT
	.word	-10
	.word	-33eh,0	       
	.long	1a800h	 
	.word	0

	.long	S_SET_VECTOR_TABLE
	.long	CHEM_VECT_TABLE

	.LONG	S_AT_PORTAL_ENTRANCE

	.LONG	S_SET_PORTAL		; Search For Portal we are centered on
	.word	25

	.LONG	S_ENTER_PORTAL		; Set up and enter new universe
	.long	GXINNL+M_EP_SMOOTH	; name of universe 
	.long	-1e900h,0b0000h,0 	; Z, X, Y offsets

	.LONG	S_SOUND, SND_FACTORY_MUSIC

	.LONG	S_SET_WORD
	.long	NUM_PILLARS		;use as morph chamber count
	.word	0

	.LONG	S_DELETE_ENEMY_OID
	.word	OID_NONBOY

	.LONG	S_CREATE_PROCR
	.word	PID_IND
	.long	0,0,0,-03c00h,FLOAT_ZFAR
	.word	0

	.LONG	S_RESET_VIDCAM
;	.LONG	S_LOCKOUT_PORTALS

	.long	S_SET_ENEMIES		; set to tell popups and   
	.word	M_OF_BOXERS		; siderunners to stop 

	.LONG	S_SET_WORD
	.long	MAX_ALLOWED
	.word	8			; set number of box carriers

	.LONG	S_CREATE_BEEKS	; create beekeepers
	.word	1		; index 1 = outside chamber left

	.LONG	S_Z_ACCEL_BURST	; move in
	.word	10
	.word	20

	.LONG	S_SOUND	  		 
	.long	SND_PLANT_MUSIC

	.LONG	S_WAIT_HERE
	.word	40


*
* CHEM PLANT OUTER LEFT CHAMBER    START
*

	.LONG	S_WAIT_FOR_ZREL
	.long	-13c00h
	.word	1

	.LONG	S_CREATE_PROC
	.word	PID_BEEKPR
	.long	CHECK4_CHEM_DAM

	.LONG	S_DECEL_TO_STOP
	.word	6

	JUMP_IF_CLR	SKIP_PLANT,JCONTIN12
	.if	DEBUG
	
	.long	S_SET_ENEMIES		; set to kill box carriers 
	.word	0			; 

	.LONG	M_JUMP+J_WARTESTL		; TEST ONLY
	.endif

JCONTIN12:

	.LONG	S_WAIT_HERE
	.word	160

	.LONG	S_GOTO_POINTZ
	.word	-250
	.long	-1d368h
	.word	0

	.LONG	S_GOTO_POINTXY
	.word	300
	.word	0cbh,0
	.word	0

	.LONG	S_GOTO_POINTZ
	.word	-400
	.long	-10e68h
	.word	0

	.long	S_SET_ENEMIES		; set to kill box carriers 
	.word	0			; 

	.LONG	S_GOTO_POINTXY
	.word	500
	.word	018dh,0
	.word	0

J_WARTESTL:
	.LONG	S_GOTO_POINT0
	.word	-400
	.word	0133h,0
	.long	-17368h
	.word	40

	.LONG	S_SET_LONG
	.long	SECRET_SCROLL
	.long	ENTER_CHEM_RML

	.LONG	S_START_MORFERS
	.word	1c9h
	.long	-10fedh

	.LONG	S_SET_SCROLL_FLAG      
	.long	-1			; set to all 1's to say it's okay
					; to destroy morph chamber
	.LONG	S_GOTO_POINT0
	.word	-400
	.word	01d2h,0
	.long	-1c000h
	.word	0

	.LONG	M_CALL+MORPH_CHMBR

*
* CHEM PLANT OUTER LEFT CHAMBER    END
*

J_HOOK:
	.LONG	S_MERGE_UNIV		; add center part
	.long	GXINNM
J_HOOK2:
	.long	S_SET_ENEMIES		; stop morph chamber guys
	.word	0			; 

	.LONG	S_GOTO_POINT0
	.word	-200
	.word	31bh,0
	.long	-1c800h
	.word	0      

	.LONG	S_DELETE_ENEMY_OID
	.word	OID_BEEKPR

	.LONG	S_KILL_ALL_PROCS	; kill related processes
	.word	PID_BEEKPR

	LW	S_AUDIT, AUDJUBZERK

	.if	TEST_BUG==0

	.LONG	S_DISPATCH_HERE
	.LONG	DSP_JUNG_ENDHALL+M_WAIT	;Do the dispatch
	.WORD	0

	LW	S_WAIT_HERE, 1+M_QUOTA	;Wait for quota on Berzerkers

	.endif

	.LONG	S_Z_ACCEL_BURST			;PULL BACK AND DOWN TO THE WALL
	.word	20h		
	.word	10

	.LONG	S_CHANGE_ZFAR
	.long	02e000h

	.long	S_WAIT_FOR_ZREL
	.long	-0d800H				;Open doors
	.word	1

	.LONG	S_CREATE_PROC
	.word	PID_BOSSBUG
	.LONG	START_BUG_PROC

	.LONG	S_KILL_POWERUPS

	.LONG	S_START_DANIM_VISIBLE

	.long	S_WAIT_FOR_ZREL
	.long	-1500H				;Stop at wall and ...
	.word	0

	.LONG	S_DELETE_ENEMY_OID		; protection
	.word	OID_BZERK

BILL_SCROLL
	.LONG	S_SET_LONG
	.LONG	WXBUFFER
	.LONG	0180000H

	.LONG	S_SET_WORD
	.LONG	UNIVERR
	.WORD	1

	.LONG	S_GOTO_POINT
	.WORD	-10
	.WORD	0318H,0
	.LONG	-013EFH
	.WORD	0

	.LONG	S_SET_WORD
	.long	SCROLL_FLAG	; will be cleared by big iballs 
	.word	2	   

	.if	TEST_BUG==0

	.LONG	S_LOAD_BOSS_PUNISH

	.LONG	S_START_GOOP
	.long	0d9c0h		; ZPOS (lo bit is RETREAT flag, 0=morph to iballs)
	.word	0fffh	   	; wait forever (until external force moves us on)

	.LONG	S_WAIT_UNTIL_FALSE
	.long	SCROLL_FLAG    	; wait for big iballs to be killed

	.endif

	.if	YES_BUG==0

	LLW	S_SET_WORD, GAME_STATE, INGAME

	.LONG	S_WAIT_HERE
	.WORD	60

	.LONG	S_SOUND,SND_SWEET_EMOTION

	LLW	S_SET_WORD, BONUS_DIRECTION, 3	; END THE WAVE

	.LONG	S_CREATE_PROC
	.word	PID_IND
	.LONG	WAVE_END_IMM			;Force the wave to end

	.LONG	0

	.endif

	.LONG	S_SET_LONG
	.LONG	WAVE_UNIV
	.LONG	GXINNM

	.LONG	S_WAIT_HERE
	.WORD	35


;	.LONG	S_SOUND
;	.long	SND_KICKASS

	.LONG	S_MAKE_KICKASS

	.LONG	S_WAIT_HERE
	.WORD	75
	
	LW	S_AUDIT, AUDJUBUG

	.LONG	S_CREATE_PROC
	.word	PID_IND
	.LONG	BLOW_COVER_PROC

	.LONG	S_CLR_SCROLL_FLAG
	.LONG	-1

	.LONG	S_WAIT_UNTIL_TRUE
	.LONG	SCROLL_FLAG

	.LONG	S_SOUND	  		 
	.long	SND_ESCAPE_MUSIC


	.long	S_Z_ACCEL_LIMIT
	.WORD	-014H
	.LONG	-08800H	>> ZFRAC

	.LONG	S_SOUND	  		 
	.long	SND_OUTA_HERE

	.LONG	S_WAIT_FOR_COORD_ZREL
;	.LONG	-0CC6FH
	.LONG	-0AC6FH
	.WORD	1

	.LONG	S_WAIT_HERE
	.word	30

	.LONG	S_START_DANIM_VISIBLE

	.LONG	S_WAIT_FOR_COORD_ZREL
	.LONG	-0ED6FH
	.WORD	1

	.LONG	S_SET_LONG
	.LONG	WXBUFFER
	.LONG	060000H

	.LONG	S_WAIT_FOR_COORD_ZREL
	.LONG	-01C52FH
	.WORD	0

	.LONG	S_GOTO_POINT
	.WORD	-10
	.WORD	0318H,0
	.LONG	-01C52FH
	.WORD	0

;	.LONG	BILL_LUPE+M_JUMP
;
;	.LONG	S_GOTO_POINT
;	.WORD	-240
;	.WORD	070CH,0
;	.LONG	-01C52FH
;	.WORD	0
;
;	.LONG	BILL_LUPE+M_JUMP

	.LONG	S_SET_LONG
	.LONG	WXBUFFER
	.LONG	0200000H

	.LONG	S_SET_LONG
	.LONG	WYBUFFER
	.LONG	0320000H

	.LONG	S_GOTO_PORTAL_X
	.word	160		; how long to get there (ticks)
;	.word	240		; how long to get there (ticks)
	.word	0		; sleep upon arrival

	.LONG	S_SET_WORD		; kill float process
	.long	SCROLLKILL
	.word	1

	.long	S_SET_VECTOR_TABLE
	.long	BLDG_VECT_TABLE

	.LONG	S_EXIT_PORTAL
	.word	0		; sleep upon exit

	.LONG	S_CREATE_PROCR
	.word	PID_IND
	.long	0,0,0,024000H,FLOAT_ZFAR
	.word	0

	.LONG	S_SET_WORD
	.LONG	SKYCOLOR
	.WORD	0

	.LONG	S_SET_WORD
	.LONG	IRQSKYE
	.WORD	0

	.LONG	S_SET_LONG
	.LONG	WXBUFFER
	.LONG	080000H

	.long	S_Z_ACCEL_LIMIT
	.WORD	-016H
	.LONG	-09000H	>> ZFRAC

	.LONG	S_SET_LONG		; place bug at next spot
	.LONG	WAVE_UNIV
	.LONG	GXHALL3M

	.LONG	S_JUMP_IF_BIT_SET	; jump if XBASE neg
	.long	PlaceINNL
	.long	XBASE+16
	.word	15

	.LONG	S_ADD_TMPOBJ
	.long	INNR_INIT
	.word	30c8h,310h
	.long	24365h
	.word	100

	.LONG	PlaceINNR+M_JUMP

PlaceINNL:

	.LONG	S_ADD_TMPOBJ
	.long	INNL_INIT
	.word	-33a0h,2d8h
	.long	244fdh
	.word	100

PlaceINNR:

	.LONG	S_START_UID_DANIM		; reopen doors to chem plant
	.WORD	2 << 8 + (32-1) + M_START_UID_PORTAL

;	.LONG	S_START_UID_DANIM
;	.WORD	2 << 8 + (6-1) + M_START_UID_PORTAL

	.LONG	S_WAIT_HERE
	.WORD	60

	.LONG	S_START_UID_ANIM
	.LONG	SLDORCLOSE
	.WORD	2 << 8 + (32-1) + M_START_UID_PORTAL

;	.LONG	S_START_UID_ANIM
;	.LONG	SLDORCLOSE
;	.WORD	2 << 8 + (6-1) + M_START_UID_PORTAL

	.LONG	S_WAIT_HERE
	.WORD	40
	
	.LONG	S_SET_WORD
	.LONG	SKYCOLOR
	.WORD	024A0H

	.LONG	S_SET_WORD
	.LONG	IRQSKYE
	.WORD	024A0H

	.LONG	S_WAIT_FOR_COORD_ZREL
	.LONG	-01F00H
	.WORD	0

	.LONG	S_GOTO_ZPOINT
	.WORD	-10
	.LONG	-01F00H
	.WORD	0

	.LONG	S_SET_LONG
	.LONG	WXBUFFER
	.LONG	0100000H

	.LONG	S_CLR_SCROLL_FLAG
	.LONG	-1

	.LONG	S_GOTO_POINTXY		;GO TO ELEVATOR
	.word	120
	.word	010H,0
	.WORD	0    			; SLEEP UPON ARRIVAL

	.LONG	S_SET_WORD		; kill float process
	.long	SCROLLKILL
	.word	1

	.LONG	S_GOTO_POINT
	.WORD	-10
	.WORD	010H,0
	.LONG	-01F00H
	.WORD	0

	.LONG	S_CREATE_PROCR
	.word	PID_IND
	.long	0,0,0,10000H,FLOAT_ZFAR
	.word	0

	.LONG	S_SET_SCROLL_FLAG
	.LONG	1

	.LONG	S_SET_LONG
	.LONG	WXBUFFER
	.LONG	080000H

	.LONG	S_GOTO_POINT
	.WORD	-240
	.WORD	010H,0
	.LONG	-0197B4H
	.WORD	0

;	.LONG	S_GOTO_PORTAL_EXIT
;	.word	300		; how long to get there (ticks)
;	.word	0		; sleep upon arrival

	.LONG	S_SET_WORD	; kill float process
	.long	SCROLLKILL
	.word	1

	.LONG	S_EXIT_PORTAL
	.word	3		; sleep upon exit

	.LONG	S_CREATE_PROCR
	.word	PID_IND
	.long	0,0,0,10000H,FLOAT_ZFAR
	.word	0

	.long	S_Z_ACCEL_LIMIT
	.WORD	-010H
	.LONG	-08000H	>> ZFRAC

	.LONG	S_SET_LONG	; set bug at new position
	.LONG	WAVE_UNIV
	.LONG	GXEVLOB3

	.LONG	S_ADD_TMPOBJ
	.long	HALL3M_INIT
	.word	170h,338h
	.long	0cba8h
	.word	100

	.LONG	S_START_UID_DANIM	; reopen door to hallway?
	.WORD	2 << 8 + (32-1) + M_START_UID_PORTAL

	.LONG	S_WAIT_HERE
	.WORD	60

	.LONG	S_START_UID_ANIM
	.LONG	SLDORCLOSE
	.WORD	2 << 8 + (32-1) + M_START_UID_PORTAL

	.LONG	S_WAIT_FOR_COORD_ZREL
	.long	-014000H
	.WORD	1

	.LONG	S_CLR_SCROLL_FLAG
	.LONG	-1

	.LONG	S_SET_LONG			      ; go over desk
	.LONG	YSCROLL
	.LONG	020000H

	.LONG	S_DOZER_ACCEL
	.WORD	25 << 8 + M_Y << 3 + M_Y + M_Z
	.LONG	0200000H				;Y BOUNDARY
	.LONG	-1					;Y TARGET VELOCITY
	.LONG	-08000H					;Z TARGET VELOCITY

	.LONG	S_DOZER_ACCEL
	.WORD	35 << 8 + M_Y << 3 + M_Y
	.LONG	0					;Y TARGET VELOCITY
	.LONG	-030000H				;Y BOUNDARY

	.LONG	S_SET_LONG
	.LONG	YBASE
	.LONG	0

	.LONG	S_SET_LONG
	.LONG	YSCROLL
	.LONG	0

	.LONG	S_WAIT_FOR_COORD_ZREL
;	.long	-01EDEAH
	.long	-01b800H		; was -1b000h
	.WORD	0

	.LONG	S_WAIT_UNTIL_TRUE
	.LONG	SCROLL_FLAG


	.LONG	S_SET_WORD	; kill float process
	.long	SCROLLKILL
	.word	1

	.long	S_SET_LONG
	.long	WXBUFFER
	.long	800000h

	.LONG	S_EXIT_PORTAL
	.word	25		; sleep upon exit

BILL_REVERSE_TEST

;	.LONG	S_CREATE_PROCR
;	.word	PID_IND
;;	.long	0,0,0,03C801H,FLOAT_ZFAR
;;	.long	0,0,0,03DFFFH,FLOAT_ZFAR
;	.long	0,0,0,044000H,FLOAT_ZFAR
;	.word	0

	.LONG	S_SET_WORD
	.LONG	SKYCOLOR
	.WORD	0

	.LONG	S_SET_WORD
	.LONG	IRQSKYE
	.WORD	0

	.LONG	S_SET_LONG	; set bug at new position
	.LONG	WAVE_UNIV
	.LONG	GXJUNG3

	.long	S_SET_VECTOR_TABLE
	.long	JUNGLE_VECT_TABLE

	.long	S_Z_ACCEL_LIMIT
	.WORD	-014H
	.LONG	-08000H	>> ZFRAC

	.LONG	S_ADD_TMPOBJ
	.long	EVLOB_INIT
	.word	3270h,310h
	.long	0404cbh
	.word	100

	.LONG	S_START_UID_DANIM	   ; reopen main doors?
	.WORD	2 << 8 + (32-1) + M_START_UID_PORTAL

	.LONG	S_WAIT_HERE
	.WORD	60

	.LONG	S_START_UID_ANIM
	.LONG	DOORSWING_CLOSE
	.WORD	2 << 8 + (32-1) + M_START_UID_PORTAL

;	.LONG	S_WAIT_HERE
;	.WORD	20

	.LONG	S_SET_WORD
	.LONG	SKYCOLOR
	.WORD	02974H

	.LONG	S_SET_WORD
	.LONG	IRQSKYE
	.WORD	02974H

;	.LONG	S_SET_WORD	; kill float process
;	.long	SCROLLKILL
;	.word	1

	.LONG	S_WAIT_FOR_COORD_ZREL
	.LONG	024931H
	.WORD	0

	.LONG	S_GOTO_ZPOINT
	.WORD	-10
	.LONG	024931H
	.WORD	0

	.long	S_SET_LONG		; go over wall
	.long	WYBUFFER
	.long	1320000h

	.LONG	S_SET_LONG
	.long	ZSACCEL
	.long	-500

	.LONG	S_SET_LONG     
	.long	YSACCEL			; POS MEANS UP!
	.long	3000h

	.LONG	S_WAIT_FOR_COORD
	.long	YBASE
	.long	780000h
	.word	1

	.LONG	S_SET_LONG
	.long	YSACCEL
	.long	-3000h

	.LONG	S_WAIT_FOR_ZREL
	.long	0199A8H+024931H-023800H
	.word	1

	.LONG	S_SET_LONG
	.long	ZSACCEL
	.long	800

	.LONG	S_WAIT_FOR_COORD
	.long	YBASE
	.long	780000h
	.word	1		; maintain Y motion

	.long	S_CLR_ZMOTION

	.LONG	S_SET_LONG
	.long	YSACCEL
	.long	3000h

	.LONG	S_WAIT_FOR_COORD
	.long	YBASE
	.long	0h
	.word	0	     	; stop Y motion

	.LONG	S_SET_LONG
	.LONG	YBASE
	.LONG	0

	.long	S_SET_LONG
	.long	WYBUFFER
	.long	320000h

	.LONG	S_SET_LONG
	.long	WXBUFFER
	.long	200000h

	.LONG	S_CREATE_PROCR
	.word	PID_IND
	.long	0,0,0,024000H,FLOAT_ZFAR
	.word	0

	.long	S_Z_ACCEL_LIMIT
	.WORD	-016H
	.LONG	-09000H	>> ZFRAC

	.LONG	S_WAIT_FOR_COORD_ZREL
	.LONG	-0CCD9H
	.WORD	0

	.LONG	S_GOTO_ZPOINT
	.WORD	-10
	.LONG	-0CCD9H
	.WORD	0

	.LONG	S_CLR_SCROLL_FLAG
	.LONG	-1

	.LONG	S_GOTO_POINT
	.WORD	-210			; was 240
	.WORD	-03E8H,0
;	.LONG	-0CCD9H
	.LONG	-020CF0H
	.WORD	0

	.long	S_SET_ENEMIES		; set to tell popups and
	.word	M_OF_PILE		; ok to destroy rope bridge

	.LONG	S_EXIT_PORTAL
	.word	0		; sleep upon exit

	.LONG	S_SET_SCROLL_FLAG
	.LONG	1

	.LONG	S_SET_WORD    
	.long	BRIDGE_STATE	; initialize 
	.word	0

	.LONG	S_GOTO_POINT
	.WORD	-680			; was 640
	.WORD	-03E8H,0
	.LONG	-03F800H
	.WORD	0

BILL_LUPE
	.LONG	S_WAIT_HERE
	.WORD	1
	.LONG	BILL_LUPE+M_JUMP


END_JUNGLE:
	.LONG	S_SET_SCROLL_FLAG
	.long	0deadbeefh			; set some bits

	.LONG	S_DECEL_TO_STOP
	.word	3

	.long	S_WAIT_UNTIL_FALSE	; wait for bug gone signal
	.long	SCROLL_FLAG	  

	LLW	S_SET_WORD, GAME_STATE, INGAME

	.LONG	S_SOUND,SND_SWEET_EMOTION

	LW	S_AUDIT, AUDJUEND

	LLW	S_SET_WORD, BONUS_DIRECTION, 3	; END THE WAVE

	.LONG	S_CREATE_PROC
	.word	PID_IND
	.LONG	WAVE_END_IMM			;Force the wave to end



MORPH_CHMBR:
	.LONG	S_CLR_OU_OHITS		; for dummy-mode hit counting
	.word	OID_UNIV|(9<<BIT_ID),OID_UNIV|(9<<BIT_ID)
					; universe ID of inside of chamber
	.word	2			; number of pieces to look for

	.LONG	S_SET_WORD	
	.long	SCROLLKILL		; kill FLOAT_ZFAR proc,CHECK4_DAM proc
	.word	3			; and GEN_BOXER proc

	.LONG	S_SET_ZSCROLL		; move in toward chamber
	.word	50
	.word	300

	.LONG	S_CLR_ZMOTION

	.LONG	S_JUMP_IF_TRUE		; if glass shot out, back off
	.long	MC_1	 		; quicker and wait longer
	.long	MORFGLASOUT

	.LONG	S_WAIT_HERE
	.word	300
MC_1:
	.LONG	S_SET_ZSCROLL
	.word	-500
	.word	30

	.LONG	S_CLR_ZMOTION

	.LONG	S_JUMP_IF_FALSE		; if glass shot out, 
	.long	MC_2	 		; wait longer
	.long	MORFGLASOUT

	.LONG	S_WAIT_HERE
	.word	300
MC_2:
	.LONG	S_WAIT_HERE
	.word	600

	.LONG	S_CLR_SCROLL_FLAG      
	.long	-1			; set to all 0's to say it's too late
					; to destroy morph chamber
	.LONG	0		; return


ZIP_FWD:
	.LONG	S_Z_ACCEL_BURST
	.word	20h
	.word	20

	.LONG	S_Z_ACCEL_BURST
	.word	-20h
	.word	20

	.LONG	S_CLR_ZMOTION

	.LONG	S_WAIT_FOR_ZIPOK

	.LONG	0	; terminate call


LAST_HALL:

	.LONG	S_CREATE_PROCR
	.WORD	PID_POWERUPD0
	.long	0b000h,07000h,200,70,PROC_DROP_PACK	; behind wall
	.word	0

	.LONG	S_CREATE_PROC
	.word	PID_IND
	.long	ROCK_IN_X

	.LONG	S_WAIT_FOR_ZIPOK

ZIP_LOOP2:
	.LONG	ZIP_FWD+M_CALL

	.LONG	S_JUMP_IF_TRUE
	.long	ZIP_LOOP2
	.long	NUM_PILLARS

	.LONG	S_KILL_POWERUPS			;Whack those powers

	.LONG	S_SET_WORD
	.long	SCROLLKILL	
	.word	2		; kill ROCK & ATRIUM boy proc and reset SCROLLKILL

	.LONG	0		; terminate call


ELEVATOR_RIDE:
	.LONG	S_PUSH_PLYRSEEN

	LLW	S_SET_WORD,ENEMY_HITALL,1

	.LONG	S_START_DANIM_DELTAZ
	.long	13000h

	.LONG	S_GOTO_POINTZ_DELTA
	.word	60
	.long	6e00h+0900h
	.word	0 

	.LONG	S_SOUND
	.long	SND_ELEV_MUSIC

	.LONG	S_WAIT_HERE
	.word	200	; wait for floor to be hit
*
*	Get Out Of elevator
*
EXIT_ELEVATOR:
	.LONG	S_PULL_PLYRSEEN

	LLW	S_SET_WORD,ENEMY_HITALL,0

	.LONG	S_LOCKOUT_PORTALS	; can't go back in

	.LONG	S_GOTO_POINTZ_DELTA
	.word	40
	.long	-6e00h
	.word	0

	.LONG	S_SOUND	  		 
	.long	SND_CHEM_MUSIC

	.LONG	S_WAIT_HERE
	.word	10

	.LONG	S_UNGREEN

	.LONG	0


HALL1FLR2:
	.long	S_SET_VECTOR_TABLE
	.long	CHEM_VECT_TABLE

	.LONG	S_AT_PORTAL_ENTRANCE
	.LONG	S_SET_PORTAL
	.word	20	

	.LONG	S_SET_LONG
	.long	ZSACCEL
	.long	200

	.LONG	S_SET_ZSCROLL
	.word	100
	.word	0

	.LONG	S_SHOCKER	; if vidcam not hit, start a scary guy
	.long	DSP_JUNG_ELEV+M_WAIT

	.LONG	S_ENTER_PORTAL		; Set up and enter new universe
	.long	GXELRM2+M_EP_SMOOTH+M_EP_WAIT	; name of universe   
	.long	-0a800h,-0bd0000h,0h 	; Z, X, Y offsets 

	.LONG	S_SOUND
	.long	SND_CHEM_MUSIC

	.LONG	S_WAIT_HERE
	.word	300+M_QUOTA

	.LONG	M_JUMP+JOE_PERRY_HOOK

;	.LONG	S_WAIT_HERE
;	.word	300	; sleep upon exit, wait for floor sel hit
;
;	.LONG	M_JUMP+HALL1FLR2


HALL1FLR3:
	.long	S_SET_VECTOR_TABLE
	.long	CHEM_VECT_TABLE

	.LONG	S_AT_PORTAL_ENTRANCE
	.LONG	S_SET_PORTAL
	.word	20	

	.LONG	S_SET_LONG
	.long	ZSACCEL
	.long	200

	.LONG	S_SET_ZSCROLL
	.word	100
	.word	0

	.LONG	S_ALLOW_PORTALS		; for grate shooting

	.LONG	S_CLR_SCROLL_FLAG     
	.long	-1			; set to all 0's to say it's too late

	.LONG	S_SHOCKER	; if vidcam not hit, start a scary guy
	.long	DSP_JUNG_ELEV+M_WAIT

	.LONG	S_ENTER_PORTAL		; Set up and enter new universe
	.long	GXELRM1+M_EP_SMOOTH+M_EP_WAIT	; name of universe   
	.long	-0b000H,-0be0000H,0	; Z, X, Y offsets

	.LONG	S_SOUND
	.long	SND_CHEM_MUSIC

	.LONG	S_WAIT_HERE
	.word	1+M_QUOTA

	.LONG	S_GOTO_POINT0
	.word	-90
	.word	-0d8h,0
	.long	-380h
	.word	0

	.LONG	S_GOTO_POINTXY
	.word	90
	.word	-090h,0
	.word	0

	.LONG	S_GOTO_POINT0
	.word	90
	.word	-0beh,0
	.long	8c000h
	.word	0

	.LONG	S_LOCKOUT_PORTALS 	; for grate shooting

JOE_PERRY_HOOK:
	.LONG	S_SET_VECTOR_TABLE
	.LONG	BLDG_VECT_TABLE

	.LONG	S_EXIT_PORTAL
	.word	0	      

	.LONG	S_SOUND
	.long	SND_ELEV_MUSIC

	.LONG	S_SET_BYTE
	.long	ELEV_MOVING
	.word	0		; short time to select another floor

	.LONG	S_WAIT_HERE
	.word	30			; time to select other floor


	.LONG	S_SEND_ELEV_DOWN	; 1 room only, then you go back

;	.LONG	S_WAIT_HERE
;	.word	300	; sleep upon exit, wait for floor sel hit
;
;	.LONG	M_JUMP+HALL1FLR3


JOE_PERRY_TRIP:
	.LONG	S_CREATE_PROC
	.word	PID_IND
	.long	PERRY_SKY_PROC

	.LONG	S_SET_LONG
	.LONG	WYBUFFER
	.LONG	0640000H

	.LONG	S_START_DANIM_VISIBLE

	.LONG	S_GOTO_POINT0
	.word	-120
	.word	-0c4h,3ch
	.long	4000h
	.word	0

	.LONG	S_SOUND,SND_SWEET_EMOTION

	.LONG	S_PERRY_FLY
	.long	-1600000h,2a0000h

	.LONG	S_WAIT_HERE
	.word	300	       

	.LONG	S_CREATE_PROC
	.word	PID_IND
	.long	RESTORE_GRNDCOL_PROC

	.LONG	S_GOTO_POINT0
	.word	110
	.word	-0beh,0
	.long	8c000h
	.word	0

	.LONG	M_JUMP+JOE_PERRY_HOOK

RESTORE_GRNDCOL_PROC:
	sleep	40

	SOUND1	SND_CHEM_MUSIC
	move	@GROUNDCOLOR,@IRQGNDE
	MOVIM	320000h,@WYBUFFER,L
	DIE



************************************
*
*	SCROLL TABLE TO ENTER SECRET ROOMS IN CHEM PLANT
*
************************************
ENTER_CHEM_RML:
	.LONG	S_MERGE_UNIV		; add center part
	.long	GXINNM

	.LONG	S_WAIT_HERE
	.word	35

	.LONG	S_SET_WORD
	.long	IN_SECRET
	.word	1			; in a secret room

	.LONG	S_SET_LONG
	.long	XSACCEL
	.long	0a00h

	.LONG	S_WAIT_HERE
	.word	35

	.LONG	S_Z_ACCEL_BURST
	.word	10h
	.word	15

	.LONG	S_X_ACCEL_BURST
	.word	-0a00h
	.word	50

	.LONG	S_START_DANIM

	.LONG	S_GOTO_POINT0
	.word	-100
	.word	25eh,0
	.long	-0d900h
	.word	0

	.LONG	M_JUMP+CHEM_RM_HK      


ENTER_CHEM_RMR:
	.LONG	S_MERGE_UNIV		; add center part
	.long	GXINNM

	.LONG	S_WAIT_HERE
	.word	35

	.LONG	S_SET_WORD
	.long	IN_SECRET
	.word	1			; in a secret room

	.LONG	S_SET_LONG
	.long	XSACCEL
	.long	-0a00h

	.LONG	S_WAIT_HERE
	.word	35

	.LONG	S_Z_ACCEL_BURST
	.word	10h
	.word	15

	.LONG	S_X_ACCEL_BURST
	.word	0a00h
	.word	50

	.LONG	S_START_DANIM


	.LONG	S_GOTO_POINT0
	.word	-85
	.word	3d6h,0
	.long	-0fc00h
	.word	0
CHEM_RM_HK:
	.LONG	S_CREATE_PROCR
	.word	PID_POWERUPD0
	.word	-40h,40h		; x range (world)
	.long	1,-5000h,12		; (world flg), zmax, num crates
	.LONG	SPRINKLE_POWERUPS
	.word	0

	.LONG	S_WAIT_HERE
	.word	180

;	.LONG	S_DECEL_TO_STOP
;	.word	7
;
;	.LONG	S_WAIT_HERE
;	.word	180

	.LONG	S_Z_ACCEL_BURST
	.word	-15
	.word	45

	.LONG	S_WAIT_FOR_ZREL
	.long	-1b000h
	.word	0

	.LONG	S_SET_WORD
	.long	IN_SECRET
	.word	0

	.LONG	M_JUMP+J_HOOK2


************************************
*
*	SUBROUTINE TO ENTER DEAD END HALLWAYS
*
************************************
ENTER_DEADEND:
	.long	SUCK_INTO_DEADEND
	.word	0		; sleep upon arrival
	
	.long	S_Z_ACCEL_BURST
	.word	40h
	.word	40

	.long	S_WAIT_FOR_ZREL
	.long	1c000h
	.word	1			; don't stop

	.long	S_SOUND
	.long	SND_HALL_BONK
	.long	S_PUSH_WALL_IN
	.long	S_REVERSE_Z

	.LONG	S_DECEL_TO_STOP
	.word	5

	.LONG	S_WAIT_HERE
	.word	30

	.long	S_GOTO_POINTZ
	.word	-130
	.long	-1f00h
	.word	0

	.long	DEADEND_RETURN


S_REVERSE_Z:
	move	@ZSCROLL,a14,L
	neg	a14
	move	a14,@ZSCROLL,L
	jauc	SCRL_DISPATCHER

ENTER_SECRET_ROOM:
	.long	S_DECEL_TO_STOP
	.word	4

	.long	S_GOTO_POINTZ
	.word	-30
	.long	17000h			; stop at door
	.word	0

	.long	S_WAIT_HERE		; give jewel time to get in place
	.word	60

	.long	S_START_DANIM_VISIBLE	; end of DANIM clears SCROLL_FLAG

	.long	S_SET_SCROLL_FLAG
	.long	-1

	.LONG	S_SET_WORD
	.long	IN_SECRET
	.word	1			; in a secret room

	.long	S_WAIT_UNTIL_FALSE
	.long	SCROLL_FLAG

	.long	S_GOTO_POINTZ		; go into room
	.word	-60
	.long	1d000h
	.word	200

	.long	S_GOTO_POINTZ		; 
	.word	-150
	.long	-01f00h
	.word	0

	.LONG	S_SET_WORD
	.long	IN_SECRET
	.word	0			; in a secret room

	.long	DEADEND_RETURN


ATTRACT2
	.LONG	S_INIT_JUNGLE

	.LONG	S_SET_LONG
	.long	UEP_Z			; world Z for enemies
	.long	22000h

	.LONG	S_INIT_NATIVES
	.word	4,6			; natives allowed,spears allowed

	.LONG	S_SET_LONG
	.LONG	WXBUFFER
	.LONG	0200000H

	.long	S_SET_ENEMIES			; set to tell natives and
	.word	M_OF_BUSH|M_OF_TREE|M_OF_SNAKE  ; snake to activate

	.LONG	S_GOTO_POINT0
	.word	-3*60
	.word	-3f8h,0
	.long	-1f000h
	.word	60			; FIrst lockdown


	.LONG	JUNGLE_JUMP+M_JUMP


DUMMY_VEC_TABLE:
	.long	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.long	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.long	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.long	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

S_PUSH_PLYRSEEN:
	move	@PLYR_SEEN,@SAVPLYRSEEN
	CLRM	@PLYR_SEEN,W
	jauc	SCRL_DISPATCHER

S_PULL_PLYRSEEN:
	move	@SAVPLYRSEEN,@PLYR_SEEN
	jauc	SCRL_DISPATCHER

SomeSoundStuff:
	SOUND1	SND_ST_GO

	sleep	30

	SOUND1  SND_JUNGLE_END

	sleep	160

	SOUND1  SND_BGND3_OFF

	DIE


EVLOB_INIT
	.long	EVLOBbak
	.word	DMAWNZ,M_DBLSCL,0

HALL3M_INIT
	.long	HALL3Mbak
	.word	DMAWNZ,M_DBLSCL,0

INNR_INIT
	.long	INNRbak
	.word	DMAWNZ,M_DBLSCL,0

INNL_INIT
	.long	INNLbak
	.word	DMAWNZ,M_DBLSCL,0


	.end
