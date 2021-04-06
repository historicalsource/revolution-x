**************************************************************************
*																							    *
* 	         GENERATION X - Equate file for Scroller							 *
* 																								 *
* 			COPYRIGHT (C) 1993 MIDWAY MANUFACTURING COMPANY.					 *
* 		   		    ALL RIGHTS RESERVED.											 *
*																							    *
**************************************************************************
*
*Structure for RAM copy of decision table
*
MDec_Addr		.EQU	 0		;UHL ROM Address of decision table.
MDec_Left_Cnt	.EQU	20h	;UHW Number of LEFT choices left this table.
MDec_Right_Cnt	.EQU	30h	;UHW Number of RIGHT choices left this table.
MDec_Up_Cnt		.EQU	40h	;UHW Number of UP choices left this table.
MDec_Down_Cnt	.EQU	50h	;UHW Number of DOWN choices left this table.
MDec_Out_Cnt	.EQU	60h	;UHW Number of OUT choices left this table.
MDec_In_Cnt		.EQU	70h	;UHW Number of IN choices left this table.
MDec_Size		.EQU	80h	;Total size of one decision table entry

MDec_Num	.EQU	24				;Let's take a bunch right now
	
		.GLOBAL	MDec_RAM

;SUB WAVE FLAGS:
M_WAIT		EQU	00001H		;TELL THE MASTER DISPATCH PROCESS TO
					; WAIT FOR THE SCROLLER TO SET THE NEXT
					; SUB WAVE.
B_WAIT		EQU	0

;S_ENTER_PORTAL FLAGS:
M_EP_DONT_STOP	EQU	1			;DON'T STOP ZSCROLL WHEN INSIDE
M_EP_SMOOTH		EQU	2			;DON'T SET SCROLL VELS WHEN ENTERING
M_EP_WAIT		EQU	4			;WAIT FOR PORTAL TO OPEN BEFORE PROCEEDING 

B_EP_DONT_STOP	EQU	0
B_EP_SMOOTH		EQU	1
B_EP_WAIT		EQU	2	  

;S_START_UID_DANIM OR S_START_UID_ANIM
M_START_UID_PORTAL	EQU	08000H	;START PORTAL ANIMATIONS ONLY

;FUNCTION FLAGS used in SCROLL TABLE
M_JUMP		EQU	00001H		;THIS IS A FUNCTION FLAG

B_JUMP		EQU	0

M_CALL		EQU	00002H		;THIS IS A FUNCTION FLAG

B_CALL		EQU	1

PUSHCNT		equ	PTEMP1-30h	; for sub calls within scroll table
LAST_SP		equ	PTEMP1-20h	;Process SP save area
ALTSCRL	   equ   PTEMP1-60h  ; storage of alt scroll process

;SLEEP TIME FLAGS:
;DON'T EVEN THINK ABOUT CHANGIN' M_QUOTA
M_QUOTA		EQU	08000H		;WAIT FOR QUOTA FLAG
M_CLEANUP	EQU	04000H		;WAIT FOR ALL ENEMIES DELETED

B_QUOTA		EQU	15
B_CLEANUP	EQU	14

;COORDINATE FLAGS FOR S_DOZER_ACCEL

M_X			EQU	001H
M_Y			EQU	002H
M_Z			EQU	004H
M_ZREL		EQU	040H

B_X			EQU	0
B_Y			EQU	1
B_Z			EQU	2
B_ZREL		EQU	6

**************************************************************************
*																							    *
* REFERENCES																				 *
*																							    *
**************************************************************************
	.GLOBAL	S_DIE
	.GLOBAL	S_DEL_ALL_UNIVOBJ_WAIT
	.GLOBAL	S_GOTO_ZPOINT
	.GLOBAL	S_WAIT_FOR_COORD_ZREL
	.GLOBAL	S_START_UID_ANIM
	.GLOBAL	S_GOTO_POINTZ_DELTA
	.GLOBAL	S_MAKE_SOLO_BUTTON
	.GLOBAL	S_DECEL_TO_POINTZ
	.GLOBAL	S_SET_TRACK_VOLUME
	.GLOBAL	S_SOUND0
	.GLOBAL	S_DELETE_TEXT
	.GLOBAL	S_GAME_OVER
	.GLOBAL	S_LM_PRINTF
	.GLOBAL	S_FADE_TO_BLACK
	.GLOBAL	S_DOZER_ACCEL
	.GLOBAL	S_XYZ_DECEL_LIMIT
	.GLOBAL	S_CALL
	.GLOBAL	S_SETUP_DSJ
	.GLOBAL	S_DSJ
	.global	PORTAL_LOCKOUT
	.global	SCROLL_PROCESS
	.GLOBAL	 S_SET_GRND_COLOR
	.GLOBAL	 S_SET_SKY_COLOR
	.GLOBAL	 S_STAGE_ZFAR_PROC
	.GLOBAL	 S_SET_SCROLL_FLAG
	.GLOBAL	 S_CLR_SCROLL_FLAG
	.GLOBAL	 S_AT_Z
	.GLOBAL	 S_GOTO_XPOINT
	.GLOBAL	 S_GOTO_POINTX
	.GLOBAL	 S_GOTO_POINTX_DELTA
	.GLOBAL	 S_X_DECEL_LIMIT
	.GLOBAL	 S_Y_DECEL_LIMIT
	.GLOBAL	 S_Z_DECEL_LIMIT
	.GLOBAL	 S_KILL_ALL_PROCS
	.GLOBAL	 S_START_UID_DANIM
	.GLOBAL   S_JUMP_IF_BIT_SET
	.GLOBAL   S_JUMP_IF_BIT_CLR
	.GLOBAL   S_DISPATCH_SOON
	.global	 S_SET_PORTAL
	.global	 S_ENTER_PORTAL
	.global	 S_LEAVE_UNIV	
   .global   S_GOTO_PORTAL_EXIT
   .global   S_GOTO_PORTAL_X	
   .global   S_EXIT_PORTAL
   .global   S_START_DANIM
   .global   S_START_DANIM_VISIBLE
   .global   S_START_DANIM_DELTAZ
   .global   S_DISPATCH_HERE
   .global   S_WAIT_HERE
   .global   S_GOTO_PORTAL_ENTRANCE
   .global   S_GOTO_POINT
   .global   S_GOTO_POINTXY
   .global   S_GOTO_POINTXZ
   .global   S_GOTO_POINTZ
   .global   S_GOTO_POINT0
   .global   S_GOTO_WPOINT0	
   .global   S_X_ACCEL_BURST
   .global   S_Y_ACCEL_BURST
   .global   S_Z_ACCEL_BURST
   .global   S_XYZ_ACCEL_BURST
   .global   S_CLR_ZMOTION
   .global   S_CLR_YMOTION
   .global   S_CLR_XMOTION
   .global   S_CLR_ACCELS
   .global   S_X_ACCEL_LIMIT
   .global   S_Y_ACCEL_LIMIT
   .global   S_Z_ACCEL_LIMIT
   .global   S_DECEL_TO_STOP
   .global   S_DECEL_TO_POINT
   .global   S_DECEL_TO_POINT_A
   .global   S_ACCEL_TO_POINT
   .global   S_AT_PORTAL_ENTRANCE
   .global   S_MAKE_DECISION
   .global   S_CLEAR_CHOICE_COUNT
   .global   S_BRANCH_NO_CHOICE
   .global   S_HILLFUNC
   .global   S_JUMP_CONVEYOR
   .global   S_HILLFUNC2
   .global   S_HILLFUNC_REV
   .global   S_SET_XSCROLL
   .global   S_SET_YSCROLL
   .global   S_SET_ZSCROLL
   .global   S_STOP_SCROLL
   .global   S_WAIT_FOR_Z_DELTA
   .global   S_WAIT_FOR_ZREL		
   .global   S_WAIT_FOR_ZABS
   .global   S_WAIT_FOR_Z
   .global   S_WAIT_FOR_COORD
   .global   S_WAIT_FOR_VALUE
   .global   S_CHANGE_ZFAR
   .global   S_CREATE_PROC
   .global   S_CREATE_PROCR
   .global   S_LOCKOUT_PORTALS
   .global   S_ALLOW_PORTALS
   .global   S_WAIT_UNTIL_TRUE
   .global   S_WAIT_UNTIL_FALSE
   .global   S_KILL_POWERUPS
   .global   S_SOUND
   .global   S_SET_ENEMIES
   .global   S_START_BGND	
   .global   S_START_UNIVERSE
   .global   S_START_UNIVERSE0
   .global   S_SET_VECTOR_TABLE
   .global   S_SET_BYTE
   .global   S_SET_WORD
   .global   S_SET_LONG
   .global   S_BLACKOUT
   .global   S_SECRET_PALS
	.GLOBAL	 S_DEL_ENEMY_NOAUD_OID
   .global   S_JUMP_IF_TRUE
   .global   S_JUMP_IF_FALSE
	.global	S_SET_ELEVATOR,S_UNGREEN,EXIT_ELEVATOR,ELEV_MOVING
	.global	S_DISABLE_ENEMY_GENS
	.GLOBAL	SCRL_DISPATCHER
	.GLOBAL	A_CHNG_SCRL_TBL
	.GLOBAL	CHNG_SCRL_TBL
	.GLOBAL  ADJUST_YHALF_R
	.GLOBAL	S_MAKE_DUAL_BUTTONS
	.GLOBAL	S_ACCEL_LIMIT_TO_POINT
	.GLOBAL	S_OR_WORD
	.GLOBAL	S_WAIT_HERE_R
	.GLOBAL	WAIT_VAR
	.global	S_WAIT_FOR_COUNTDOWN
	.GLOBAL	S_AUDIT
	.global	S_WAIT_FOR_X	
	.global	S_WAIT_FOR_X_DELTA
	.global	S_CREATE_ALT_SCROLL	
	.GLOBAL	S_PRAISE
	.GLOBAL	S_LOAD_BOSS_PUNISH
	.global	S_KILL_ALT_SCROLL

