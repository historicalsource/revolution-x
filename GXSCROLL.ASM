 	.MLIB	"GXMACS.LIB"
	.FILE	"GXSCROLL.ASM"
	.TITLE	" <<< GENERATION X -- SCROLL ROUTINES >>>"
	.WIDTH	132
	.OPTION	B,D,L,T
	.MNOLIST

HDW_KLUDGE  .set 0

**************************************************************************
*								         *
* 	COPYRIGHT (C) 1992 MIDWAY MANUFACTURING COMPANY.		 *
* 		       ALL RIGHTS RESERVED.				 *
*								         *
**************************************************************************

OLD_WAY	.set	0		; omit old stuff

*	GET THE SYSTEM STUFF
	.INCLUDE	"GX.INC"
	.INCLUDE	"IMGTBL.GLO"
	.INCLUDE	"UNIVTBL.GLO"
	.INCLUDE	"GXSCROLL.TBL"
	.include	"gxscrl.h"

	.BSS	SCROLL_PROCESS,32
	.bss	PORTAL_LINK,MAX_UNI*32*2  	; Univ Link to portals (for checking states)
*
*	10/2 merge, PORTAL ENTRANCE changed to be pushed each time a
*			univ is pushed.	Warren
*
	.bss	PORTAL_ENTRANCE,32 	; Pointer to current PORTAL ENTRANCE
	.bss	PORT_ENT_STK,MAX_UNI*3*32 	; Univ Pos of starting location of universe
	
	.bss	PORTAL_LOCKOUT,16	; if nonzero, ignore gunshot to portal
	.bss	SCROLLKILL,16		; Set to 1 in scroll table to kill a process

	.BSS	NU_FLAG,16
	.BSS	WAIT_VAR,16		;Used for variable sleeps
;	.bss	UNUSED_WORD,16		;For alignment purposes

	.BSS	SCROLL_FLAG,32		; GENERAL PURPOSE FLAG

	.bss	ZREL_OFF,32		; Z relative offset of univ (Hires)
	.BSS	YREL_OFF,32

	.text

* SYMBOLS IN HERE
	.def	SUCK_INTO_DEADEND,DEADEND_RETURN,SET_WAVE,S_ADD_TMPOBJ 
	.DEF	PORTAL_LOCKOUT,S_DELETE_ENEMY_OID,S_BRNCH_ON_WORD_VAL
	.DEF	SECRET_PALETTE_TABLE

	.REF	WAVE_SUB,ADD_UNIVERSE

	.REF	CYCLE16,SKYDOWN,SKYUP,DUXNOFADE,FADEIN,FADEBLAK

***** from GXDESK.ASM

	.REF	A_ADD_YPOS

* SYMBOLS FROM GXTEXT.ASM
	.REF	LM_PRINTF

* SYMBOLS FROM GX.ASM
	.REF	GAME_OVER

***** from GXRAM.ASM

	.REF	IN_MAKE_DECISION, HOLD_ENEMY_DISPATCH


	.ref	HALL_LOCKOUT


**************************************************************************
*								         *
* S_DIE	- TERMINATE SCROLLER						 *
*								         *
**************************************************************************

S_DIE
	DIE

**************************************************************************
*								         *
* START_SCROLL - START THE SCROLL PROCESS				 *
*                IF WAVE_SCROLL:					 *
* 				0 = LEAVE OLD SCROLLER RUNNING		 *
* 			FFFFFFFFH = KILL OLD SCROLLER AND STOP		 *
*								         *
**************************************************************************
START_SCROLL
	MMTM	SP,A0,A1,A7
	MOVE	@WAVE_SCROLL,A11,L
	JRZ	SS_DONE			;BR=DO NUTIN'
	MOVI	PID_SCROLL,A0
	CMPI	-1,A11
	JRNE	SS_CREATE		;BR=START DA SCROLLER
	CALLA	KILLPROC_ALL
	JRUC	SS_DONE
SS_CREATE
	movi	PORT_ENT_STK,a14      	
	move	a14,@PORTAL_ENTRANCE,L	
	MOVE	A0,A1
	MOVI	SCROLL_DISPATCHER_INIT,A7
	CALLA	GETPPRC
SS_DONE
	MMFM	SP,A0,A1,A7
	RETS



S_CREATE_ALT_SCROLL:
	move	a11,a9
	move	*a9+,a11,L	; new scroll table in a11
	CREATEP	PID_IND,ALT_SCROLL_INIT
	move	a0,*a13(ALTSCRL),L	; store ALT SCROLL PROC
	move	a9,a11		; restore original scroll table
	jruc	SCRL_DISPATCHER


**************************************************************************
*								         *
* SCROLL_DISPATCHER_INIT - Control Flow For Scrolling based on Scroll	 *
*                          Table				         *
*								         *
* PASS:									 *
* A11 = SCROLL TABLE   (Each routine in this table is responsible for    *
*                       knowing what parameters it will grab)            *
*		       (Each routine in this table will terminate with   *
*		        a call to SCRL_DISPATCHER)                         *
*									 *
* 	Each routine in the Scroll Table can use a8, a9, or a10          *
*                                     but NOT a11!!!	  		 *
**************************************************************************

SCROLL_DISPATCHER_INIT
;HUH?	MOVE	A11,A2
	move	a13,@SCROLL_PROCESS,L

ALT_SCROLL_INIT:
	clr	a10			; "push counter" for SUBROUTINES
	move	a10,*a13(PUSHCNT)       
	move	a10,*a13(ALTSCRL),L	; mark no ALT SCROLLER
	move	a12,*a13(LAST_SP),L	; let's keep the PSP on track.
	move	a10,@SCROLLKILL		; clear kill flag
;	move	a10,@ZREL_OFF,L		; relative Z offset to get between
					; absolute Z to Z relative to local
					; universe
;	move	a10,@YREL_OFF,L	
;HUH?	MOVE	A2,A11


	
**************************************************************************
*								         *
* SCRL_DISPATCHER - Process Next entry in SCROLL TABLE                     *
*								         *
* PASS:									 *
* A11 = POINTER TO NEXT SCROLL TABLE ENTRY				 *
*	(if B_JUMP or B_CALL are appended, this entry is an address	 *
*         somewhere in the table.  Otherwise, it is a routine name)      *
*								         *
**************************************************************************

SCRL_DISPATCHER
	MOVE	*A11+,A14,L    		;GET FUNCTION OR JUMP POINT
	JrZ	SS_CHKRET		; ZERO ends table or subroutine			
	BTST	B_JUMP,A14
	JRnZ	SS_JUMP      		;BR = NOT A FUNCTION, jump to it
	btst	B_CALL,a14
	jrnz	SS_CALL	  		;BR = not a function, call it and return
	JUMP	A14

SS_CALL:
	move	a11,*-a12,L    		; if calling a sub., save a11
	move	*a13(PUSHCNT),a7       
	inc 	a7			; increment push counter
	move	a7,*a13(PUSHCNT)       
	move	a12,*a13(LAST_SP),L	; update stack ptr
SS_JUMP:
	SRL	4,A14	       		; entry for jump only
	SLL	4,A14
	move	a14,a11
	jruc	SCRL_DISPATCHER

SS_CHKRET:				; end, check for return from sub
	move	*a13(PUSHCNT),a14       
	jaz	SUCIDE			; if no pushes, table is done.
	dec	a14
	move	a14,*a13(PUSHCNT)       
	move	*a13(LAST_SP),a12,L	; restore SP in case it got fucked
	move	*a12+,a11,L  		; restore saved a11
	move	a12,*a13(LAST_SP),L	; update stack ptr
	jruc	SCRL_DISPATCHER		; see what's next



**************************************************************************
*								         *
* SET_WAVE - SET A NEW SUB WAVE						 *
*   Must be called as a subroutine from a SCROLL routine                 *
* 									 *
* PASS:									 *
* A11 = POINTER TO WAVE DISPATCH TABLE ENTRY				 *
*								         *
* RETURNS:								 *
* A11 = POINTER TO NEXT SCROLL TABLE PARAMETER	       			 *
*								         *
**************************************************************************
	
SET_WAVE
	MOVE	*A11+,A14,L
	JRZ	SW_NOWAVE			;BR = NO WAVE
	MOVE	A14,A0
	SLL	31,A14				;GET LOW BIT					
	SRL	31,A14
	MOVE	A14,@WAVE_WAIT,W		;SET WAVE_WAIT	
	SRL	1,A0
	SLL	1,A0
	MOVE	A0,@WAVE_SUB,L
	MOVKM	1,@ENEMY_QUOTA,W
SW_NOWAVE
	RETS


;	       ****************************************
;	       *				      *
;	       *           PORTAL ROUTINES            *
;	       *				      *
;	       ****************************************


**************************************************************************
*
*	.LONG	S_SET_PORTAL
*	.word	How long before animation starts      
*		(15 recommended if S_ENTER_PORTAL is used)
*
*   This routine searches for the portal(s) we would reach if we zoomed in
*   at our current position.
*
*	Objects which are in the following range are checked...
*		-4b.0000h < UNIVX-XBASE < 4b.0000
*	  GRND_Y-60.0000h-YBASE < UNIVY < GRND_Y-YBASE
*
*	Objects in this range whose Portal flags are set are
*	       animated (if their DANIM flag is set)
*
*	The Z value of the portal is stored in a10 for S_ENTER_PORTAL
*
*	The LINK of up to two portals found are stored in PORTAL_LINK.
*
**************************************************************************
S_SET_PORTAL:			       
	callr	SET_PORTAL_CORE
	move	a9,a9
	.if DEBUG
	jrz	$			; hang if none found
	.endif
	move	@UNIV_ID,a14
	dec	a14
	sll	6,a14
	addi	PORTAL_LINK,a14		; based on UNIV_ID
	dec	a9
	PULLPQ	a4	 		; get first portal
	move	a4,*a14+,L
	clr	a4			; may not be a second one
	dec	a9
	jrn	SetP_done3
	PULLPQ	a4      	
SetP_done3:
	move	a4,*a14,L		; save second one
	move	a9,a9
	jrle	SetP_done2    
setp_clean:
	PULLPQ	a4      		; pull any other portals found
	dsjs	a9,setp_clean		; without saving
SetP_done2:
	movk	1,a14
	move	a14,@NU_FLAG		; make sure it's 1 (into universe)
	jruc	SCRL_DISPATCHER
	

SET_PORTAL_CORE:
	move	@XBASE,a0,L		; X BASE
	move	@YBASE,a2,L		; Y BASE
	move	@YWORLD,a5,L		; Ground Y of UNIV
	addi	180000h,a5		; check a bit below ground  
	sub	a2,a5			; ground in world coord
	movi	4b0000h,a6		; X limit
	move	a5,a7
	subi	600000h,a7		; neg Y limit (size of screen in Y)
	move	@RAMREF0,a3,L
	move	@RAMREF1,a4,L
	clr	a10			; assume no portals

	move	*a11+,a2  		; ticks until animation starts  
	cmp	a3,a4
	jreq	SetP_Done

	clr	a9			; count of portals found
SetP_Lp:
	move	*a3(MAP_FLAGS),a14
	btst	B_BF_PORTAL,a14
	jrz	SetP_Lp2			; jump if obj is not a portal

	move	*a3(MAP_X),a1,L		; Is portal in X range?
	sub	a0,a1			; univ to world
	abs	a1
	cmp	a6,a1
	jrge	SetP_Lp2			; jump if no

	move	*a3(MAP_Y),a1,L		; Is portal in Y range?
	cmp	a7,a1
	jrlt	SetP_Lp2			; jump if no
	cmp	a5,a1
	jrgt	SetP_Lp2			; jump if no
*
*	FOUND a PORTAL IN THE RANGE
*
	move	*a3(MAP_OBJ),a8,L
	jrn	SetP_Lp2			; jump if no object
	srl	4,a8
	sll	4,a8			; strip off damage count
	move	*a3(MAP_Z),a10,L
	move	*a3(MAP_IMG),a1,L	
	move	a1,b1			; save in B1 reg
	btst	B_IF_DAM,a1		; Portal running off damage?
	jrz	no_port_dam
	move	a1,a14
	andi	M_IF_DANIM,a14
	srl	4,a1
	sll	4,a1
	move	*a1,a1,L		; get damage pointer
	or	a14,a1	      		; retain DANIM bit from MAP_IMG
no_port_dam:
	btst	B_IF_SEQ,a1
	jrz	SetP_Lp2
	btst	B_IF_DANIM,a1
	jrz	SetP_Lp2
*
*	Start animation going!
*
	srl	4,a1
	sll	4,a1
	calla	STRT_ANIM		; animate the object
	movb	a2,*a8(AnimSlp)		; don't open just yet
;	movk	4,a1			; bit 2 says this is a portal 
	clr	a1 			; bits 1-0 say	     (mark as closed to start)
					;      0 0  closed
					;      1 0  opening
					;      1 1  open
					;      0 1  closing
	movb	a1,*a3(MAP_ID+8)	; store portal state

	andni	M_IF_DANIM,b1		; clear DANIM bit
	move	b1,a14
	move	a14,*a3(MAP_IMG)	; only need to write lower half
	PUSHP	a3			; save portal link
	inc	a9			; adjust portal count

SetP_Lp2:
	cmp	a3,a4
	jreq	SetP_Done
	move	*a3(MAP_NEXT),a3,L
	jruc	SetP_Lp
	

SetP_Done:
	rets					 

**************************************************************************
*
*	.LONG	S_ENTER_PORTAL 
*	.long	universe+flags
*	.long	Z,X,Y
*
*	a10 = Z position of portal
*	a11 = scroll table
*
*	This routine creates the new universe starting at the
*	Z position in a10.  
*
*	The starting universe offsets for the NEW universe are stored in
*	PORTAL_ENTRANCE.  If you scroll in the new universe, you must return
*	here before EXITING from the PORTAL.  (see S_GOTO_PORTAL)
*
**************************************************************************
S_ENTER_PORTAL:
	sll	ZFRAC,a10		; convert Portal Z to Hires
	move	@UNIV_SP,a0,L
	move	a10,*a0(PU_ZPORTAL),L	; save Z of portal
	move	@XBASE,a3,L
	move	@YBASE,a4,L
	move	@ZBASE_HR,a1,L		; 

	move	a1,a14			; copy old ZBASE into a14
	move	*a11+,a8,L		; univ table
	btst	B_EP_SMOOTH,a8		; don't set SCROLL VELS 
	jrnz	EntP_smth		
*
*	Begin Zoom into portal
*
	addi	200h,a1		; (was 800h)
	sub	a10,a1
	neg	a1
	srl	5,a1		; scale down
	move	a1,a0
	srl	2,a0
	sub	a0,a1		; reduce by 1/8
;	srl	1,a1
;	subi	600,a1		; reduce a bit more (was 300)
	move	a1,@ZSCROLL,L
EntP_smth:			; 
	clr	a0
	move	a0,@XSCROLL,L
	move	a0,@YSCROLL,L
*
*	Delete all objects behind portal	
*
	move	a10,a0
	sub	a14,a0		; get a world referenced Z
	sra	ZFRAC,a0	; convert to lo res
	addi	80h,a0		; buffer zone
	calla	CHANGE_ZFAR	; let bg proc get rid of all
	sleep	8		;     objs past portal
*
*	Delete remaining objects behind portal
*
	move	a10,a5
	sra	ZFRAC,a5	; convert Z to lo res
	addi	100h,a5		; buffer zone
	move	@RAMREF0,a1,L
	movi	80000000h,a2
	move	@RAMREF1,a4,L
	jruc	EntP_lpA0
EntP_LpA1:
	move	*a1(MAP_NEXT),a1,L
EntP_lpA0:
	move	*a1(MAP_Z),a14,L
	cmp	a5,a14
	jrle	EntP_LpA2
	move	*a1(MAP_OBJ),a0,L
	jrn	EntP_LpA2
	move	a0,a7
	srl	4,a0
	sll	4,a0		; strip off hit count
	xor	a0,a7		; count only remains in a1
	calla	ZAPOBJ
	or	a2,a7  		; restore hit count
	move	a7,*a1(MAP_OBJ),L
EntP_LpA2:
	cmp	a1,a4
	jrne	EntP_LpA1
	sleep	1
*
*	Set universe (convert from old to new somehow)
*
	move	*a11,a0,L	; new ZBASE
	sll	ZFRAC,a0	; convert new ZBASE to hi res
	sub	a0,a10
*
*	Stall Background Process
*
	move	@UNIVPROC,a14,L
	movi	1000h,a0
	move	a0,*a14(PTIME)
*
*	Start to set new universe
*
	PUSHP	A8			;SAVE FLAGS
	SRL	4,A8			;SHIFT OUT FLAGS
	SLL	4,A8

	MOVE	A8,@WAVE_UNIV,L		;THIS IS THE UNIVERSE!

	PUSHP	A11

	move	*a8+,a9			; num_objs

	move	*a8+,a11		; halfy currently ignored
;	CREATEP	PID_JUNK,ADJUST_YHALF

	move	*a8+,a3,L			; colors
	move	a3,@GROUNDCOLOR
	srl	16,a3
	move	a3,@SKYCOLOR

	move	*a8+,a3,L			; ZFAR
	move	a3,@ZFAR,L

	move	@YWORLD,a14,L
	move	*a8+,a11,L		; WORLD Y
;	move	a1,@YWORLD,L
	sub	a14,a11		; new - old WORLD Y in a11
*
*	Create New LINKED LIST of universe pieces
*
	PUSHP	A10		; SAVE HI-RES Z	OFFSET
	sra	ZFRAC,a10  	; CREATE_UNIV needs lo res Z
	JSRP	CREATE_UNIVERSE	; new linked list

	PULLPQ	A10				;HI-RES Z OFFSET 
	MOVE	A10,@ZREL_OFF,L			;DA OFFSETS
	MOVE	A11,@YREL_OFF,L

	sleep	3			; chance to zoom in some more
*
*	Remove Infinity Plane  
*
	calla	KILL_ALL_BG		; Kill objects
	calla	KillBgnd		; Kill procs
	sleep	1

*
*	Set New Universe Parameters
*
	PULLPQ	A11
	move	@PORTAL_ENTRANCE,a5,L	; save new universe start position
	addi	60h,a5			; 
	move	a5,@PORTAL_ENTRANCE,L	; 
	move	*a11+,a0,L	; new ZBASE
	sll	ZFRAC,a0	; convert to hi res
	add	a0,a10		; get original Z portal back

	move	@XBASE,a0,L
	move	*a11+,a2,L
	move	a2,*a5+,L
	move	a2,@XBASE,L
	sub	a0,a2

	move	@YBASE,a14,L
	move	*a11+,a6,L
	move	a6,*a5+,L
;	add	a1,a6 		; Adjust new YBASE
;	move	a6,a3
;	srl	4,a3
;	move	a3,@YSCROLL,L
 	move	a6,@YBASE,L
	sub	a14,a6
*
*	Copy pieces from old universe to new universe
*		(Note: the loop will process the obj pointed to by RAMREF0
*		       but NOT RAMREF1!!!)	
*
	move	@RAMREF0,a3,L		; from last universe
	move	@RAMREF1,a4,L
	move	*a4(MAP_OBJ),a14,L
	CMPI	-1,A14
	JREQ	GET_ACTIVE		;THIS IS THE 2ND DUMMY LINK
	move	*a4(MAP_NEXT),a4,L
GET_ACTIVE
	move	@BGHEAD_ACTIVE,a1,L	; start of NEW universe list

	.if	DEBUG
	CMPI	RAMLINKS,A3
	LOCKON	LT
	CMPI	BGHEAD_ACTIVE,A3
	LOCKON	GE   
	CMPI	RAMLINKS,A4
	LOCKON	LT
	CMPI	BGHEAD_ACTIVE,A4
	LOCKON	GE   
	CMPI	RAMLINKS,A1
	LOCKON	LT
	CMPI	BGHEAD_ACTIVE,A1
	LOCKON	GE   
	.endif	

	dint
	jruc	EntP_Lp2
EntP_Lp:
	move	*a3(MAP_NEXT),a3,L
EntP_Lp2:
	cmp	a3,a4
	jreq	EntP_Done

	move	*a3(MAP_OBJ),a5,L
	jrn	EntP_Lp			; jump if no object
	srl	4,a5
	sll	4,a5			; strip off hit count
*
*	Move block from old list into current
*
	move	a3,a0
	move	*a3(MAP_NEXT),a3,L

	move	*a0(MAP_NEXT),a14,L	; REMOVE LINK
	move	*a0(MAP_PREV),a7,L	;   reproduced so loop can stay
	move	a7,*a14(MAP_PREV),L	;   in cache
	move	a14,*a7(MAP_NEXT),L	; REMOVE LINK

	move	*a0(MAP_X),a14,L
	add	a2,a14
	move	a14,*a0(MAP_X),L
	move	a14,*a5(OXVAL),L

	move	*a0(MAP_Y),a14,L
	sub	a6,a14
	move	a14,*a0(MAP_Y),L
	move	a14,*a5(OYVAL),L
*
*	Place Link into New Universe
*
	move	*a1(MAP_NEXT),a14,L	; APPLINK
	move	a0,*a1(MAP_NEXT),L	; 	reproduced so loop can stay
	move	a14,*a0(MAP_NEXT),L	;	in cache
	move	a0,*a14(MAP_PREV),L	;
	move	a1,*a0(MAP_PREV),L	; APPLINK

	move	a0,a1			; keep in same order
	jruc	EntP_Lp2
EntP_Done:
	eint
*
*	Restart UNIV process
*
	calla	SET_REFS

	.IF DEBUG
	MOVE	@BGHEAD_ACTIVE,A14,L
	CMPI	RAMLINKS,A14
	LOCKON	LT
	CMPI	BGHEAD_ACTIVE,A14
	LOCKON	GE	
	MOVE	@RAMREF0,A14,L
	CMPI	RAMLINKS,A14
	LOCKON	LT
	CMPI	BGHEAD_ACTIVE,A14
	LOCKON	GE	
	MOVE	@RAMREF1,A14,L
	CMPI	RAMLINKS,A14
	LOCKON	LT
	CMPI	BGHEAD_ACTIVE,A14
	LOCKON	GE	
	.endif

	calla	INIT_HORIZON
	move	@UNIVPROC,a14,L
	movk	1,a0
	move	a0,*a14(PTIME)
	PULLPQ	A8	       

	btst	B_EP_WAIT,a8  		; wait for portal to open?
	jrz	webeopen      
	move	@SKYCOLOR,@IRQSKYE     	; if waiting for portal to open
	move	@GROUNDCOLOR,@IRQGNDE	; set new colors now
*
*	
*
wait4opening:
	sleep	1
	move	@UNIV_ID,a14
	dec	a14
	sll	6,a14
	addi	PORTAL_LINK,a14
	move	*a14+,a1,L
	movb	*a1(MAP_ID+8),a0		; portal state
	btst	0,a0			; if lo bit clr, closed or opening
	jrz	wait4opening 
	move	*a14,a1,L			; optional second portal
	jrz	webeopen
	movb	*a1(MAP_ID+8),a0		; portal state
	btst	0,a0
	jrz	wait4opening 
webeopen:
	move	@SKYCOLOR,@IRQSKYE     
	move	@GROUNDCOLOR,@IRQGNDE

keep_goin:
	move	@ZBASE_HR,a0,L	
	move	@ZSCROLL,a14,L		; if not moving through portal
	jrz	EntP_stayout		; don't wait til we get through it

keep_goin_lupe
	sleep	1
	move	@ZBASE_HR,a0,L
	cmp	a0,a10
	jrgt	keep_goin_lupe
EntP_stayout	 			; 
	move	@PORTAL_ENTRANCE,a14,L	  ; 
	move	a0,*a14(40h),L		  ; save portal Z (hi res)
;
; following done in SET_REFS now
;	MOVK	1,A0
;	MOVE	A0,@UNIVERR,W			;FORCE CREATION BY UPDATE_UNIV
;
	BTST	B_EP_DONT_STOP,A8
	JRNZ	SCRL_DISPATCHER			;BR = DON'T STOP ZSCROLL
	clr	a0
	move	a0,@ZSACCEL,L
	move	a0,@ZSCROLL,L
	jruc	SCRL_DISPATCHER




*
*	Place a number of links onto the free linked list
*	and patch up the list they came from.
*		a1 = first link
*		a14 = last link
*		a2 = link after last link
FREE_CHAIN:
	move	*a1(MAP_PREV),a7,L
	move	a7,*a2(MAP_PREV),L
	move	a2,*a7(MAP_NEXT),L	; tie up active list
	move	@FREE_LINKS,a6,L
	move	*a6(MAP_PREV),a7,L
	move	a7,*a1(MAP_PREV),L
	move	a1,*a7(MAP_NEXT),L	; tie up new head of free list
	move	a6,*a14(MAP_NEXT),L
	move	a14,*a6(MAP_PREV),L	; tie up old head of free list
	move	a1,@FREE_LINKS,L
	rets

**************************************************************************
*
*	.LONG	S_LEAVE_UNIV
*	.word	ticks until portal anim start  
*	.long	new_universe
*	.long	Z,X,Y
*	.word	ticks until new sky, ground and infinity planes are set
*
*	a10 = Z position of portal (lo res)
*	a11 = scroll table
*
*	This routine creates the new universe starting at the
*	Z position in a10.  
*
*	All preexisting BGLINKS which do not exist as objects are freed.
*       The preexisting blocks which DO exist as objects are left
*	
*	This routine DOES NOT MOVE YOU INTO THE NEW UNIVERSE!!
*	That is entirely up to your scroll table.
*
*       !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
*	MAKE SURE you do not zoom into the new universe before the
*	portal animation is complete.  That would be bad.
*	!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
*	
**************************************************************************
S_LEAVE_UNIV:
	callr	SET_PORTAL_CORE	      
	move	a10,a5			; keep lores Portal Z in a5
*
*	Stall Background Process
*
	move	@UNIVPROC,a14,L
	movi	1000h,a0
	move	a0,*a14(PTIME)
*
*	Delete all links up to RAMREF0
*
	move	@RAMREF0,a2,L
	move	@BGHEAD_ACTIVE,a1,L
	move	*a1(MAP_NEXT),a1,L	; skip dummy link
	move	a1,a14
DelChain:
	move	*a14(MAP_NEXT),a14,L
	cmp	a14,a2			; are we at RAMREF0 yet?
	jrne	DelChain
	move	*a14(MAP_PREV),a14,L	; one before
*
*	a1 = first link to move,  a14 = last link to move, a2 = link after
*
	callr	FREE_CHAIN

	move	*a11+,a8,L	; univ table

	move	*a11+,a9,L	; new ZBASE (lo res)
	sub	a9,a10		; Z offset for ADD_UNIV (lo res)

	move	@XBASE,a0,L	; current XBASE
	move	*a11+,a3,L	; XBASE in new universe
	move	a3,@XBASE,L
	sub	a0,a3	   	; delta to be added to old univ parts

	move	@YBASE,a14,L
	move	*a11+,a4,L
 	move	a4,@YBASE,L
	sub	a14,a4
*
*	new start of list is a2, move ahead to just past portal
*	Adjust X and Y values along the way
*	a3 = X adjust
*	a4 = Y adjust
*
	addi	80h,a5			; buffer zone
LU_lp:
	move	*a2(MAP_Z),a14,L
	cmp	a14,a5			; end of list?
	jrlt	LU_lp_X
	move	*a2(MAP_X),a6,L
	move	*a2(MAP_Y),a7,L
	add	a3,a6
	sub	a4,a7
	move	a6,*a2(MAP_X),L
	move	a7,*a2(MAP_Y),L
*
*	For now, keep links even if no obj exists (to make this faster)
*	In future, might want to free links for which no obj exists.
*
	move	*a2(MAP_OBJ),a1,L
	jrn	LU_nxt
	srl	4,a1
	sll	4,a1
	move	a6,*a1(OXVAL),L
	move	a7,*a1(OYVAL),L
LU_nxt:
	move	*a2(MAP_NEXT),a2,L
	jruc	LU_lp
LU_lp_X:
*
*	Delete all links and objects to end of list.
*
	movi	7fffffffh,a6		; most positive Z
	movi	80000000h,a7		; for MAP_OBJ
	move	a2,a4
	move	*a4(MAP_Z),a0,L
	cmp	a6,a0			; are we at end of list yet?
	jreq	DelChainX
DelChain2:
	move	*a4(MAP_OBJ),a0,L
	jrn	no_obj_del
	srl	4,a0
	sll	4,a0		; strip off hit count
	calla	ZAPOBJ		; Delete obj
	move	a7,*a4(MAP_OBJ),L	; set to unused value
no_obj_del:
	move	*a4(MAP_NEXT),a4,L
	move	*a4(MAP_Z),a0,L
	cmp	a6,a0			; are we at end of list yet?
	jrne	DelChain2
	move	a2,a1
	move	a4,a2
	move	*a2(MAP_PREV),a14,L
	callr	FREE_CHAIN
DelChainX:
	sleep	2
*
*	Start to set new universe
*
	MOVE	A8,@WAVE_UNIV,L		;THIS IS THE UNIVERSE!

	PUSHP	A11

	move	*a8+,a9			; num_objs

	move	*a8+,a11		; halfy currently ignored
;	CREATEP	PID_JUNK,ADJUST_YHALF

	move	*a8+,a3,L			; colors
	move	a3,@GROUNDCOLOR
	srl	16,a3
	move	a3,@SKYCOLOR

	move	*a8+,a3,L			; ZFAR
	move	a3,@ZFAR,L

	move	@YWORLD,a14,L		
	move	*a8+,a11,L		; WORLD Y
;	move	a1,@YWORLD,L
	sub	a14,a11		; new - old WORLD Y in a11
*
*	Create New LINKED LIST of universe pieces
*
	JSRP	ADD_UNIVERSE	; new linked list

	sleep	1

	sll	ZFRAC,a10		;HI-RES Z OFFSET 
	MOVE	A10,@ZREL_OFF,L		;DA OFFSETS
	MOVE	A11,@YREL_OFF,L
*
*	Remove Infinity Plane  
*
	calla	KILL_ALL_BG		; Kill objects
	calla	KillBgnd		; Kill procs
	sleep	1
*
*	Set New Universe Parameters
*
	PULLPQ	A11
*
*	Restart UNIV process
*
	calla	SET_REFS

	calla	INIT_HORIZON
	move	@UNIVPROC,a14,L		; restart opening
	movk	1,a0
	move	a0,*a14(PTIME)
*
*
*
*LU_wait:
*	sleep	1
*	move	@PORTAL_LINK,a14,L
*	movb	*a14(MAP_ID+8),a0		; portal state
*	subk	2,a0
*	jrne	LU_wait
*
	move	*a11+,a9		; time until sky,ground & infinity set
	jrz	do_it_now
	CREATE	PID_IND,WAIT_AND_SET
	jruc	SCRL_DISPATCHER

do_it_now:
	move	@SKYCOLOR,@IRQSKYE
	move	@GROUNDCOLOR,@IRQGNDE

	move	@WAVE_IPLANE,a10,L
	jrz	nobg
	calla	StrtBgnd
nobg:
	jruc	SCRL_DISPATCHER

WAIT_AND_SET:
	sleepr	a9
	move	@SKYCOLOR,@IRQSKYE
	move	@GROUNDCOLOR,@IRQGNDE

	move	@WAVE_IPLANE,a10,L
	jrz	wnobg
	calla	StrtBgnd
wnobg:
	DIE
	   
	
**************************************************************************
*								         *
* 	ADJUST_YHALF							 *
* 									 *
* 	Gradually, change from one YHALF to another			 *
* 									 *
* 	a11 = new YHALF (junk in upper)					 *
* 									 *
* 									 *
* 	ADJUST_YHALF_R							 *
* 									 *
* 	Same as ADJUST_YHALF except, you provide the sleep		 *
* 									 *
* 	A10 = Sleep between adjustments					 *
* 	A11 = New YHALF							 *
*								         *
**************************************************************************
ADJUST_YHALF_R
	MOVE	A10,*A13(PDATA),W
	JRUC	AY_G
ADJUST_YHALF:
	MOVKM	1,*A13(PDATA),W
AY_G
	move	@YHALF,a8	; old
	movk	3,a10
	movk	3,a9
	cmp	a11,a8
	jreq	nopoint
	jrlt	yah
	neg	a10
yah:
	move	a8,a0
	sub	a11,a0
	abs	a0
	cmp	a9,a0
	jrlt	nopoint
	add	a10,a8
	move	a8,@YHALF	; set new
	SLOOPR	*A13(PDATA),yah
nopoint:
	move	a11,@YHALF
	DIE

**************************************************************************
*									 *
*	S_GOTO_PORTAL_EXIT							 *
*									 *
* TABLE ENTRY:								 *
* 	.LONG	S_GOTO_PORTAL_EXIT						 *
* 	.WORD	DURATION						 *
* 	.WORD	SLEEP TIME UPON ARRIVAL					 *
*								         *
**************************************************************************
S_GOTO_PORTAL_EXIT:
	MOVE	*A11+,A14,W		;GET DURATION		

	move	@PORTAL_ENTRANCE,a6,L	
	mmfm	a6,a8,a9,a10
	jruc	GO_TO_POINT1H

*			 
*	Keep current Y and Z and go to portal X only!
*
S_GOTO_PORTAL_X:
	MOVE	*A11+,A14,W		;GET DURATION		

	move	@PORTAL_ENTRANCE,a6,L	
	move	*a6,a10,L		; PORTAL X
	move	@ZBASE_HR,a8,L
	move	@YBASE,a9,L
	JRUC	GTP_CLR_ACCEL

**************************************************************************
*
*	.LONG	S_EXIT_PORTAL 
*
*	This routine pulls out of a universe into the previous one.
*	You must be at the entry point to the universe before you get here.
*	If you have to, use S_GOTO_PORTAL_EXIT
*
**************************************************************************
S_EXIT_PORTAL:
	move	@PORTAL_ENTRANCE,a14,L	
	subi	60h,a14			
	move	a14,@PORTAL_ENTRANCE,L	
*
*	Back out of portal
*
	move	@UNIV_SP,a8,L		; universe stack
	CREATE	PID_IND,RESTORE_PU_ZBASE	; 
	clr	a0
	move	a0,@XSCROLL,L
	move	a0,@YSCROLL,L
	move	@UNIV_ID,a14
	dec	a14
	sll	6,a14
	addi	PORTAL_LINK,a14
	move	*a14+,a9,L
	move	*a14,a10,L	; optional second portal
*
*	wait for portal to close
*
notcloyet:
 	sleep	1
	movb	*a9(MAP_ID+8),a0	; break when it is marked as closed
	jrnz	notcloyet
	move	a10,a10
	jrz	webeclosed
	movb	*a10(MAP_ID+8),a0	; break when it is marked as closed
	jrnz	notcloyet
webeclosed:
*
*	Recompute speed to get to original Z
*
;	move	@ZBASE_HR,a0,L
;	move	*a8(PU_ZBASE),a1,L		; ZBASE to get to
;	sub	a0,a1
;	sra	4,a1
;	move	a1,@ZSCROLL,L
*
*	Stall Background Process
*
	move	@UNIVPROC,a14,L
	movi	1000h,a0
	move	a0,*a14(PTIME)
	move	*a8(PU_GNDCOL),a14
	move	a14,@GROUNDCOLOR
	move	*a8(PU_SKYCOL),a14
	move	a14,@SKYCOLOR
	sleep	1
*
*	Setup for transferring older links back into original active list
*
	dint
	move	*a8(PU_XPORTAL),a2,L
	move	@XBASE,a14,L
	move	a2,@XBASE,L
	sub	a14,a2
	move	*a8(PU_YPORTAL),a3,L
	move	@YBASE,a14,L
	move	a3,@YBASE,L
	sub	a14,a3
	move	@BGHEAD_ACTIVE,a6,L
	move	*a8(PU_BGHEAD),a9,L	; old universe list
	move	a9,@BGHEAD_ACTIVE,L
	move	@UNIV_ID,a5		; current UNIV ID
	move	@FREE_LINKS,a1,L
*
*	Place current active list entirely on the free list
*
	move	*a6(MAP_PREV),a4,L	; a7 = end of scan
	move	*a1(MAP_PREV),a14,L
	move	a1,*a4(MAP_NEXT),L
	move	a4,*a1(MAP_PREV),L
	move	a6,*a14(MAP_NEXT),L
	move	a14,*a6(MAP_PREV),L
	move	*a6(MAP_NEXT),a6,L	; a6 = start of scan
*
*	Transfer links from outer univ back into active list
*
LoseOldUni0:
	cmp	a6,a4		; check for end of scan
	jreq	LoseOldUni1
	move	a6,a0
	move	*a0(MAP_NEXT),a6,L	; next link
	movb	*a0(MAP_ID),a14
	sll	29,a14
	srl	29,a14		; leave only low 3 bits
	cmp	a14,a5
	jrne	olduni
*
*	This link is part of the universe we're moving out of
*
	move	*a0(MAP_OBJ),a0,L    ; if there's an object, delete it
	jrle	LoseOldUni0
	srl	4,a0
	sll	4,a0		     ; strip off hit count
	clr	a14
	move	a14,*a0(OULINK),L    ; clear out for safety
	calla	ZAPOBJ
	jruc	LoseOldUni0
*
*	Return old universe piece to previous list
*
olduni:
*	a0 = link to be inserted
*	a9 = current pointer in a linked list
*
	move	a0,b0
	move	a9,b1
	move	a9,b14			; to check for circular loop
*
*	Unlink link  b0  from free list
*
	move	*b0(MAP_NEXT),b14,L
	move	*b0(MAP_PREV),b2,L
	move	b2,*b14(MAP_PREV),L
	move	b14,*b2(MAP_NEXT),L
*
*	trashes b0,b1,b2,b4,b5,b14,a14
*
*INSERT_LINK_REL:
	move	*b0(MAP_Z),b4,L		; Z of new block

	move	*b1(MAP_Z),b5,L		; Z of next block
	cmp	b5,b4
	jrlt	look_back
	
look_fwd:
	move	*b1(MAP_NEXT),b1,L
	cmp	b1,b14			; have we looped to beginning?
	jreq	fwd_break		; (This should never happen)
	move	*b1(MAP_Z),b5,L		; Z of next block
	cmp	b5,b4
	jrgt	look_fwd	
	jruc	fwd_break

look_back:
	move	*b1(MAP_PREV),b1,L
	cmp	b1,b14
	jreq	back_break
	move	*b1(MAP_Z),b5
	cmp	b5,b4
	jrlt	look_back
back_break:
	move	*b1(MAP_NEXT),b1,L	; move forward one link, then insert
fwd_break:
*
*	Insert link  b0  before link  b1
*	
	move	*b1(MAP_PREV),b2,L
	move	b0,*b2(MAP_NEXT),L
	move	b0,*b1(MAP_PREV),L
	move	b2,*b0(MAP_PREV),L
	move	b1,*b0(MAP_NEXT),L
INSLNKREL_RET:
	move	b0,a9			; new start of search

	move	*a0(MAP_X),a14,L
	add	a2,a14
	move	a14,*a0(MAP_X),L
	move	*a0(MAP_Y),a7,L
	sub	a3,a7
	move	a7,*a0(MAP_Y),L
	move	*a0(MAP_OBJ),a0,L
	jrn	LoseOldUni0
	srl	4,a0
	sll	4,a0			; strip off hit count
	move	a7,*a0(OYVAL),L
	move	a14,*a0(OXVAL),L
	jruc	LoseOldUni0
	

LoseOldUni1:
	dec	a5
	move	a5,@UNIV_ID
	eint

; 	clr	a0
; 	move	a0,@ZSCROLL,L
	move	*a8(PU_ZFAR),a14,L
	move	a14,@ZFAR,L

	sleep	3
	calla	SET_REFS
	calla	INIT_HORIZON

	move	@SKYCOLOR,@IRQSKYE
	move	@GROUNDCOLOR,@IRQGNDE

	sleep	3		  
     
	clr	a0
	move	a0,@NU_FLAG
*
*	This restores the Universe offsets of a popped universe
*
	MOVE	*A8(PU_YOFF),A14,L		;RESTORE OFFSETS
	MOVE	A14,@YREL_OFF,L
	MOVE	*A8(PU_ZOFF),A14,L
	MOVE	A14,@ZREL_OFF,L

;	move 	*a8(PU_XBASE),a10,L
;	move 	*a8(PU_YBASE),a9,L
;	move 	*a8(PU_ZBASE),a14,L

	addi	UNIV_STK_SIZ,a8
	move	a8,@UNIV_SP,L

	move	@UNIVPROC,a14,L
	movk	1,a0
	move	a0,*a14(PTIME)

	MOVE	@WAVE_IPLANE,A10,L
	JRZ	NO_IPLANE			;BR=NO INFINITY PLANE
	calla	StrtBgnd 	       
	sleep	7  
NO_IPLANE  

;	move	a14,a8

	jruc	S_WAIT_HERE

*
*	When exiting a universe, this process gets you to the 
*	original Z in about a second.
*
RESTORE_PU_ZBASE:
	move	@ZBASE_HR,a0,L
	move	*a8(PU_ZBASE),a9,L     	; ZBASE to get to
	move	a9,a1
	move	a9,a10
	sra	ZFRAC,a10
	sub	a0,a1
	sra	6,a1		       
	move	a1,@ZSCROLL,L

	sleep	50		 	; 

	move	@ZBASE_HR,a0,L
	move	a9,a1
	sub	a0,a1
	sra	3,a1		       
	move	a1,@ZSCROLL,L

	sleep	7

	move	@ZBASE_HR,a0,L
	move	a9,a1
	sub	a0,a1
	move	a1,@ZSCROLL,L

	sleep	1

	CLRM	@ZSCROLL,L

	sleep	1

	move	a9,@ZBASE_HR,L
	sra	ZFRAC,a9
	move	a9,@ZBASE


	DIE


**************************************************************************
*
*	.LONG	S_START_DANIM
*
*     This routine starts any DANIM found within the current screen
*	limits of the universe.
*	(meaning       -4b.0000h <= WORLD X <= 4b.0000h
*       YWORLD+18.0000h-60.0000h <= WORLD Y <= YWORLD+18.0000h)
*
*    	a0 and a5-a7 are available for a special check routine whose
*    	address should be placed in a9
*    	If the special check determines a link is not suitable, it needs
*    	to set the carry bit before returning.
*
**************************************************************************
S_START_DANIM:
	move	@XBASE,a0,L		; X BASE
	move	@YBASE,a2,L		; Y BASE
	move	@YWORLD,a5,L		; Ground Y of UNIV
	addi	180000h,a5		; check a bit below ground  
	sub	a2,a5			; ground in world coord
	movi	4b0000h,a6		; X limit
	move	a5,a7
	subi	600000h,a7		; neg Y limit (size of screen in Y)
	movi	DA_CENTER_CORE,a9
	
StrDA_Hk:
	move	@RAMREF0,a3,L
	move	@RAMREF1,a4,L
	clr	a10			; assume no portals
StD_Lp:
	cmp	a3,a4
	jreq	StD_Done
StD_Lp2:
	move	*a3(MAP_NEXT),a3,L

	move	*a3(MAP_OBJ),a8,L
	jrn	StD_Lp			; jump if no object
	srl	4,a8
	sll	4,a8
	move	*a3(MAP_IMG),a1,L	
	btst	B_IF_DAM,a1		; Portal running off damage?
	jrz	no_dam
	move	a1,a14
	andi	M_IF_DANIM,a14
	srl	4,a1
	sll	4,a1
	move	*a1,a1,L		; get damage pointer
	or	a14,a1
no_dam:
	btst	B_IF_SEQ,a1
	jrz	StD_Lp
	btst	B_IF_DANIM,a1
	jrz	StD_Lp

	MOVE	*A3(MAP_FLAGS),A14,W
	BTST	B_BF_PORTAL,A14
	JRNZ	StD_Lp

	move	*a3(MAP_Z),a10,L
	call	a9			; do special check
	jrc	StD_Lp			; 

	move	*a3(MAP_IMG),a14	
	andni	M_IF_DANIM,a14
	move	a14,*a3(MAP_IMG)	; clear DANIM bit
*
*	Start animation going!
*
	srl	4,a1
	sll	4,a1
	calla	STRT_ANIM		; animate the object

	cmp	a3,a4
	jrne	StD_Lp2

StD_Done:
	jruc	SCRL_DISPATCHER
	


*
*	a0 = XBASE
*	a5 = Y range upper
*	a6 = X range abs
*	a7 = Y range lower
*
*
DA_CENTER_CORE:
	move	*a3(MAP_X),a2,L		; Is portal in X range?
	sub	a0,a2			; univ to world
	abs	a2
	cmp	a6,a2
	jrge	SetCarry		; jump if no

	move	*a3(MAP_Y),a2,L		; Is portal in Y range?
	cmp	a7,a2
	jrlt	SetCarry			; jump if no
	cmp	a5,a2
	jrgt	SetCarry			; jump if no
ClrCarry:
	clrc	
	rets

SetCarry:
	setc
	rets


*
*	Start DANIMS of any visible objects
*
S_START_DANIM_VISIBLE:
	movi	ClrCarry,a9
	jruc	StrDA_Hk

*
*	Start DANIMs of objects within a Z distance from ZBASE
*
S_START_DANIM_DELTAZ:
	move	@ZBASE,a0,L
	move	*a11+,a5,L
	add	a0,a5			; Z cutoff in a5
	movi	DA_DELTAZ_CORE,a9
	jruc	StrDA_Hk

DA_DELTAZ_CORE:
	cmp	a5,a10
	jrgt	SetCarry
	clrc
	rets





**************************************************************************
*								         *
* S_DISPATCH_SOON - AFTER A NAP, SET A NEW SUB WAVE			 *
*								         *
* TABLE ENTRY:							         *
* 	.LONG	S_DISPATCH_HERE						 *
* 	.WORD	SLEEP TIME						 *
* 	.LONG	SUB_WAVE						 *
*								         *
**************************************************************************
S_DISPATCH_SOON
	MOVE	*A11+,A8,W		;INITIAL SLEEP TIME
	CREATE	PID_IND,SCROLL_DISPATCH_PROC
	ADDK	020H,A11
	JRUC	SCRL_DISPATCHER

SCROLL_DISPATCH_PROC
	SLEEPR	A8
	CALLR	SET_WAVE
	DIE

**************************************************************************
*								         *
* S_DISPATCH_HERE - SET NEW SUB WAVE AND NAP				 *
*								         *
* TABLE ENTRY:							         *
* 	.LONG	S_DISPATCH_HERE						 *
* 	.LONG	SUB_WAVE						 *
* 	.WORD	SLEEP TIME						 *
*								         *
**************************************************************************

S_DISPATCH_HERE
	CALLR	SET_WAVE

**************************************************************************
*								         *
* S_WAIT_HERE - TAKE A NAP						 *
*								         *
* TABLE ENTRY:							         *
* 	.LONG	S_WAIT_HERE						 *
* 	.WORD	SLEEP TIME						 *
*								         *
**************************************************************************
S_WAIT_HERE
;	MOVKM	1,@WAVE_PAUSE,W			;DON'T ADVANCE TO NEXT WAVE
	MOVE	*A11+,A8,W
SWH_G
	BTST	B_QUOTA,A8
	JRZ	WH_CLEANUP_CHECK		;BR = CHECK FOR CLEANUP
	JSRP	WAIT_FOR_QUOTA
WH_CLEANUP_CHECK
	BTST	B_CLEANUP,A8
	JRZ	WH_TIME_CHECK			;BR = CHECK FOR SLEEP
;    	JSRP	WAIT_FOR_CLEANUP
	JSRP	ENEMY_WAIT
WH_TIME_CHECK
;	CLRM	@WAVE_PAUSE,W
	SLL	18,A8
	SRL	18,A8		; changed from SRA
	JRZ	SCRL_DISPATCHER			;NO TIME TO LOSE
	SLEEPR	A8
	JRUC	SCRL_DISPATCHER

**************************************************************************
*								         *
* 	S_WAIT_HERE_R							 *
* 									 *
* 	Scroll func to wait a specified amount of time.  That		 *
* 	time is stored in a RAM variable given to this routine.		 *
* 									 *
* 	*A11+,L = Address of variable containing wait time		 *
* 									 *
* 	Note:  M_QUOTA and M_CLEANUP must be attached to wait time.	 *
*								         *
**************************************************************************
S_WAIT_HERE_R
	MOVE	*A11+,A8,L		;Get the variable address
	MOVE	*A8,A8,W		;Now get the value
	JRUC	SWH_G


**************************************************************************
*								         *
* WAIT_FOR_QUOTA - WAIT FOR QUOTA TRUE					 *
*								         *
*     This routine must be called with a JSRP				 *				         *
*								         *
**************************************************************************

WAIT_FOR_QUOTA
	SLEEP	3
QUOTA_WAIT_LUPE
	SLEEP	1
	MOVE	@ENEMY_QUOTA,A14,W
	JRZ	QUOTA_WAIT_LUPE			;BR = QUOTA NOT REACHED YET
	RETP

;**************************************************************************
;*								         *
;* WAIT_FOR_CLEANUP - WAIT FOR ALL ENEMIES DELETED			 *
;*								         *
;*     This routine must be called with a JSRP				 *				         *
;*								         *
;**************************************************************************
;
;WAIT_FOR_CLEANUP
;	MOVK	1,A14
;	MOVE	A14,@NOENEMIES,W
;
;CLEANUP_LUPE
;	SLEEP	1
;	CALLA	GET_ACTIVE_ENEMIES
;	JRNZ	CLEANUP_LUPE		;BR = ENEMIES STILL LURKING ABOUT
;
;	CLR	A14
;	MOVE	A14,@NOENEMIES,W
;	RETP	

	
	
**************************************************************************
*
*	.LONG	S_GOTO_PORTAL_ENTRANCE
* 	.word	X, Y
* 	.word	ticks
*
*	called from SCROLL TABLE before S_SET_PORTAL when you want
*	to go to the zoom point of a portal.
*
*
S_GOTO_PORTAL_ENTRANCE:
	move	*a11+,a10,L	; Y:X in a10
	clr	a9
	movy	a10,a9
	sll	16,a10		; Y and X expanded to longs in a9 and a10	
	move	a10,a6		; Move X and Y into a5 and a6
	move	a9,a5		; for PushUniverse
	calla	PushUniverse
	LOCKON	C
	move	@ZBASE_HR,a8,L	; Z in a8
	move	*a11+,a14	; ticks

;WHY NOT JUST GO_TO_POINT0? THEN WE CAN GOTO A Z! -dOZER

	jruc	GO_TO_POINT1H	; go there before entering portal


**************************************************************************
*								         *
* S_GOTO_ZPOINT - SCROLL TO A Z DESTINATION				 *
*		  THIS ROUTINE USES S_GOTO_POINT			 *
* 									 *
* 	.LONG	S_GOTO_ZPOINT						 *
* 	.WORD	DURATION						 *
* 	.LONG	Z DESTINATION						 *
* 	.WORD	SLEEP TIME UPON ARRIVAL					 *
*								         *
**************************************************************************

S_GOTO_ZPOINT
	MOVE	*A11+,A14,W		;GET DURATION		

	MOVE	*A11+,A8,L		;X DESTINATION
	SLL	ZFRAC,A8		;CONVERT TO HI-RES
	MOVE	@YBASE,A9,L		
	MOVE	@XBASE,A10,L

	JRUC	GTP_CLR_ACCEL

**************************************************************************
*								         *
* S_GOTO_XPOINT - SCROLL TO A X DESTINATION				 *
*		  THIS ROUTINE USES S_GOTO_POINT			 *
* 									 *
* 	.LONG	S_GOTO_XPOINT						 *
* 	.WORD	DURATION						 *
* 	.LONG	X DESTINATION						 *
* 	.WORD	SLEEP TIME UPON ARRIVAL					 *
*								         *
**************************************************************************

S_GOTO_XPOINT
	MOVE	*A11+,A14,W		;GET DURATION		

	MOVE	@ZBASE_HR,A8,L
	MOVE	@YBASE,A9,L
	MOVE	*A11+,A10,L		;X DESTINATION

	JRUC	GTP_CLR_ACCEL

**************************************************************************
*								         *
* S_GOTO_POINT - SCROLL TO A SPECIFIC POINT (X, Y, Z) IN THE UNIVERSE	 *
* 									 *
* TABLE ENTRY:	
* 	.LONG	S_GOTO_POINT						 *
* 	.WORD	DURATION						 *
* 	.word	X, Y
*	.long	Z	DESTINATION					 *
* 	.WORD	SLEEP TIME UPON ARRIVAL					 *
*								         *
**************************************************************************

S_GOTO_POINT
	MOVE	*A11+,A14,W		;GET DURATION		

	MMFM	A11,a8,A9		;GET DESTINATION: A9  = Y:X
					;		  A8  = Z

	sll	ZFRAC,a8		;CONVERT TO HI-RES
	move	a9,a10
	sll	16,a10			; X in a10
	movx	a10,a9			; Y in a9

GTP_CLR_ACCEL
	move	a14,a14			; if duration is neg, Z is relative
	jrnn	GTP_skzadj
	move	@ZREL_OFF,a7,L	   ; if supplied Z is relative 
	add	a7,a8		   ; convert it to absolute
	neg	a14
GTP_skzadj:	

	CLR	b0			;CLEAR ACCELERATIONS
	MOVE	b0,@XSACCEL,L
	MOVE	b0,@YSACCEL,L
	MOVE	b0,@ZSACCEL,L

GTP_lp
	dec	a14
	jrz	basically_there
	lmo	a14,a1		; ticks in a14
	jrnz	goodtix		; bits to shift in a1
	inc	a0
	movk	31,a1
goodtix:
	inc 	a14		
	move	@XBASE,a7,L	; compute velocity based on 
	sub	a10,a7		; distance to desired point
	neg	a7
	sra	a1,a7
	move	a7,@XSCROLL,L

	MOVE	@YBASE,A7,L
	SUB	A9,A7
	NEG	A7
	sra	a1,a7
	MOVE	A7,@YSCROLL,L

	MOVE	@ZBASE_HR,A7,L	
	SUB	A8,A7
	NEG	A7
	sra	a1,a7
	MOVE	A7,@ZSCROLL,L


	move	a14,a0
	movk	1,a2
	subk	31,a1
	neg	a1
	sll	a1,a2
	sub	a2,a0
	move	a2,a14
	move	a14,*-a12

	calla	PRCSLP

	move	*a12+,a14
	
	jruc	GTP_lp

basically_there:
	move	a8,@ZBASE_HR,L	
	sra	ZFRAC,a8	
	move	a8,@ZBASE,L
	move	a9,@YBASE,L
	move	a10,@XBASE,L

	move	a14,@XSCROLL,L
	move	a14,@YSCROLL,L
	move	a14,@ZSCROLL,L


GTP_ON_THE_MARK

	MOVE	*A11+,A8,W
	JRZ	SCRL_DISPATCHER		;BR = DON'T GO TO SLEEP
	JRNN	GTP_NOQUOTA		;BR = DON'T WAIT FOR QUOTA

	JSRP	WAIT_FOR_QUOTA

	SLL	17,A8
	SRA	17,A8
	JRZ	SCRL_DISPATCHER		;BR = DON'T GO TO SLEEP

GTP_NOQUOTA
      	SLEEPR	A8
	JRUC	SCRL_DISPATCHER


**************************************************************************
*								         *
* S_GOTO_POINTX - SCROLL TO A X DESTINATION				 *
*		  THIS ROUTINE USES S_GOTO_POINT0			 *
* 									 *
* 	.LONG	S_GOTO_POINTX						 *
* 	.WORD	DURATION						 *
* 	.LONG	X DESTINATION						 *
* 	.WORD	SLEEP TIME UPON ARRIVAL					 *
*								         *
**************************************************************************

S_GOTO_POINTX
	MOVE	*A11+,A14,W		;GET DURATION		

	move	@ZBASE_HR,a8,L
	MOVE	@YBASE,A9,L
	MOVE	*A11+,A10,L		;X DESTINATION

	jruc	GO_TO_POINT1H


*	THIS VERSION TAKES an X DISTANCE

S_GOTO_POINTX_DELTA:
	MOVE	*A11+,A14,W		;GET DURATION		

	MOVE	*A11+,A10,L		;X DELTA
	move	@XBASE,a8,L
	add	a8,a10
	move	@ZBASE_HR,a8,L
	MOVE	@YBASE,A9,L

	jruc	GO_TO_POINT1H


**************************************************************************
*								         *
* S_GOTO_POINTXY - SCROLL TO A SPECIFIC POINT (X, Y) IN THE UNIVERSE	 *
* 		 GIVEN n TICKS (DO NOT CHANGE Z)			 *
* TABLE ENTRY:								 *
* 	.LONG	S_GOTO_POINTXY						 *
* 	.WORD	DURATION						 *
* 	.word	X, Y
* 	.WORD	SLEEP TIME UPON ARRIVAL					 *
*								         *
**************************************************************************
S_GOTO_POINTXY:
	MOVE	*A11+,A14,W		;GET DURATION		

	move	*a11+,a9,L		;GET DESTINATION: A9  = Y:X
	move	a9,a10
	sll	16,a10			; X in a10
	movx	a10,a9			; Y in a9
	move	@ZBASE_HR,a8,L
	jruc	GO_TO_POINT1H
  
**************************************************************************
*								         *
* S_GOTO_POINTXZ - SCROLL TO A SPECIFIC POINT (X, Z) IN THE UNIVERSE	 *
* 		 GIVEN n TICKS (DO NOT CHANGE Y)			 *
* TABLE ENTRY:								 *
* 	.LONG	S_GOTO_POINTXZ						 *
* 	.WORD	DURATION						 *
* 	.word	X
*	.long	Z
* 	.WORD	SLEEP TIME UPON ARRIVAL					 *
*								         *
**************************************************************************
S_GOTO_POINTXZ:
	MOVE	*A11+,A14,W		;GET DURATION		

	move	*a11+,a10,W		;GET DESTINATION: A10  = X
	sll	16,a10
	move	*a11+,a8,L		;GET DESTINATION: A8  = Z

	move	@YBASE,a9,L
	jruc	GO_TO_POINT1

	
**************************************************************************
*								         *
* S_GOTO_POINTZ - SCROLL TO A SPECIFIC Z IN THE UNIVERSE		 *
* 		 GIVEN n TICKS	(SAME X,Y)				 *
* TABLE ENTRY:								 *
* 	.LONG	S_GOTO_POINTZ						 *
* 	.WORD	DURATION						 *
*	.long	Z	DESTINATION					 *
* 	.WORD	SLEEP TIME UPON ARRIVAL					 *
*								         *
**************************************************************************
S_GOTO_POINTZ:
	MOVE	*A11+,A14,W		;GET DURATION		

	move	*a11+,a8,L		;GET DESTINATION: A8  = Z
	move	@XBASE,a10,L
	move	@YBASE,a9,L
	jruc	GO_TO_POINT1


S_GOTO_POINTZ_DELTA:
	MOVE	*A11+,A14,W		;GET DURATION		

	move	@ZBASE,a8,L
	move	*a11+,a0,L		;GET DESTINATION: A8  = Z
	add	a0,a8
	move	@XBASE,a10,L
	move	@YBASE,a9,L
	jruc	GO_TO_POINT1


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


**************************************************************************
*								         *
* S_GOTO_POINT0 - SCROLL TO A SPECIFIC POINT (X, Y, Z) IN THE UNIVERSE	 *
* 		 GIVEN n TICKS						 *
* TABLE ENTRY:								 *
* 	.LONG	S_GOTO_POINT0						 *
* 	.WORD	DURATION						 *
* 	.word	X, Y
*	.long	Z	DESTINATION					 *
* 	.WORD	SLEEP TIME UPON ARRIVAL					 *
*								         *
**************************************************************************
S_GOTO_POINT0:
	MOVE	*A11+,A14,W		;GET DURATION		

	MMFM	A11,a8,A9		;GET DESTINATION: A9  = Y:X
					;		  A8  = Z
	move	a9,a10
	sll	16,a10			; X in a10
	movx	a10,a9			; Y in a9

GO_TO_POINT1:
	sll	ZFRAC,a8		;TRANSLATE TO HI-RES

GO_TO_POINT1H:				;
	CLR	b0			;CLEAR ACCELERATIONS
	MOVE	b0,@XSACCEL,L
	MOVE	b0,@YSACCEL,L
	MOVE	b0,@ZSACCEL,L

	.if 	OLD_WAY

	MOVE	@XBASE,A7,L
	SUB	A10,A7		    
	NEG	A7		    	; world pos in a7, univ in a10
	DIVS	A14,A7
	MOVE	A7,@XSCROLL,L

	MOVE	@YBASE,A7,L
	SUB	A9,A7
	NEG	A7
	DIVS	A14,A7
	MOVE	A7,@YSCROLL,L

	MOVE	@ZBASE,A7,L
	SUB	A8,A7
	NEG	A7
	DIVS	A14,A7
	MOVE	A7,@ZSCROLL,L

	JRUC	GTP_BILL_TRY_AGAIN

	.else

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

	move	a14,a7
	jrnn	skzadj0
	move	@ZREL_OFF,a7,L	   ; if supplied Z is relative 
	add	a7,a8		   ; convert it to absolute
	neg	a14
	move	a14,a7
skzadj0:	

	cmpi	90,a14
	jrge	use_fifth

	dec	a7
	mpys	a14,a7	; t * t-1

	COMP_ACC2	XBASE,a10,a5
	COMP_ACC2	YBASE,a9,a4
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
	
	COMP_ACC5	XSCROLL,XBASE,a10,a5
	COMP_ACC5	YSCROLL,YBASE,a9,a4
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

	movi	ZSACCEL+20h,a7
	mmtm	a7,a3,a4,a5	; stuff accelerations

;	mmtm	a12,a3,a4,a5,a14 ; save decel : cruise ticks
	move	a14,*-a12,L	

	BUSHIT_SLEEP

	move	*a12+,a0		; cruise ticks
;	move	*a12,a0		; cruise ticks
	jrz	nocruz
	add	a14,a0
	clr	a14
	move	a14,@XSACCEL,L
	move	a14,@YSACCEL,L
	move	a14,@ZSACCEL,L

	BUSHIT_SLEEP
nocruz:
*
*	DECELERATE TO STOP
*
	move	*a12+,a1		; decel ticks
	jauc	DECEL_TO_POINT_A

;	mmfm	a12,a3,a4,a5,a6 ; restore decel : cruise ticks
;	neg	a3
;	neg	a4
;	neg	a5
;	move	a5,@XSACCEL,L
;	move	a4,@YSACCEL,L
;	move	a3,@ZSACCEL,L
;	movy	a6,a0
;	srl	16,a0	  
;	add	a14,a0

;	BUSHIT_SLEEP

;;	move	a8,@ZBASE,L
;;	move	a9,@YBASE,L
;;	move	a10,@XBASE,L

;	clr	a14
;	move	a14,@XSCROLL,L
;	move	a14,@YSCROLL,L
;	move	a14,@ZSCROLL,L
;	move	a14,@XSACCEL,L
;	move	a14,@YSACCEL,L
;	move	a14,@ZSACCEL,L
;	jruc	GTP_ON_THE_MARK

	.endif

**************************************************************************
*								         *
* S_GOTO_WPOINT0 - SCROLL TO A SPECIFIC WORLD REFERENCED (X,Y,Z)	 *
* 		 GIVEN n TICKS	(SAME X,Y)				 *
* TABLE ENTRY:								 *
* 	.LONG	S_GOTO_WPOINT0						 *
* 	.WORD	DURATION						 *
* 	.word	X, Y
*	.long	Z	DESTINATION					 *
* 	.WORD	SLEEP TIME UPON ARRIVAL					 *
*								         *
**************************************************************************
S_GOTO_WPOINT0:				; Go to WORLD referenced point
	MOVE	*A11+,A14,W		;GET DURATION		

	MMFM	A11,A8,A9		;GET DESTINATION: A9  = World Y:World X
					;                 A10  = World Z
	sll	ZFRAC,a8		; 

	move	a9,a10
	sll	16,a10			; X in a10
	movx	a10,a9			; Y in a9

	move	a10,a7			; world X in a7
	MOVE	@XBASE,A10,L
	add	A7,A10			; univ X in a10

	move	a9,a7
	MOVE	@YBASE,A9,L
	add	A7,a9

	move	a8,a7
	MOVE	@ZBASE_HR,A8,L
	add	A7,a8

	JRUC	GO_TO_POINT1H


**************************************************************************
*								         *
* S_X_ACCEL_BURST	- SET X ACCELERATION in a timed burst		 *
*								         *
* 	.LONG	S_SET_XSACCEL						 *
*	.word	Xaccel_value	      					 *
*	.word	time until accel ends (0 to not end...dangerous)	 *
*									 *
**************************************************************************
S_X_ACCEL_BURST:
	MOVE	*A11+,A14,W
	MOVE	A14,@XSACCEL,L
	MOVE	*A11+,A0,W
	jrz	nobrstx
	CALLA   PRCSLP
	clr	a14
	MOVE	A14,@XSACCEL,L	
nobrstx:
	JRUC	SCRL_DISPATCHER


S_Y_ACCEL_BURST:
	MOVE	*A11+,A14,W
	MOVE	A14,@YSACCEL,L
	MOVE	*A11+,A0,W
	jrz	nobrsty
	CALLA   PRCSLP
	clr	a14
	MOVE	A14,@YSACCEL,L
nobrsty:
	JRUC	SCRL_DISPATCHER


S_Z_ACCEL_BURST:
	MOVE	*A11+,A14,W
	sll	ZFRAC,a14
	MOVE	A14,@ZSACCEL,L
	MOVE	*A11+,A0,W
	jrz	nobrstz
	CALLA   PRCSLP
	clr	a14
	MOVE	A14,@ZSACCEL,L
nobrstz:
	JRUC	SCRL_DISPATCHER


S_XYZ_ACCEL_BURST:
	MOVE	*A11+,A14,W
	MOVE	A14,@XSACCEL,L
	MOVE	*A11+,A14,W
	MOVE	A14,@YSACCEL,L
	MOVE	*A11+,A14,W
	sll	ZFRAC,a14
	MOVE	A14,@ZSACCEL,L
	MOVE	*A11+,A0,W	; length of burst
	jrz	nobrstxyz
	CALLA   PRCSLP
*
*	Fall through!
*

S_CLR_ACCELS:
	clr	a14
	move	A14,@XSACCEL,L
	move	A14,@YSACCEL,L
	move	A14,@ZSACCEL,L
nobrstxyz:
	JRUC	SCRL_DISPATCHER


S_CLR_ZMOTION:
	clr	a14
	move	a14,@ZSCROLL,L
	move	a14,@ZSACCEL,L
	jruc	SCRL_DISPATCHER

S_CLR_YMOTION:
	clr	a14
	move	a14,@YSCROLL,L
	move	a14,@YSACCEL,L
	jruc	SCRL_DISPATCHER

S_CLR_XMOTION:
	clr	a14
	move	a14,@XSCROLL,L
	move	a14,@XSACCEL,L
	jruc	SCRL_DISPATCHER


**************************************************************************
*								         *
* S_X_ACCEL_LIMIT	- SET XACCELERATION until a velocity is reached	 *
* S_X_DECEL_LIMIT							 *
*								         *
* 	.LONG	S_SET_XSACCEL						 *
*	.word	Xaccel_value	      					 *
*	.long	target velocity						 *
*									 *
**************************************************************************
S_X_ACCEL_LIMIT:
	MOVE	*A11+,A14,W
	MOVE	A14,@XSACCEL,L
	movi	XSCROLL,a9
	movi	XSACCEL,a0
	move	a0,*-a12,L	; push scroll accel address

acc_lim_hk:
	MOVE	*A11+,A8,L	; target
	jrn	neg_check
pos_check:
	sleep	1
	move	*a9,a14,L
	cmp	a8,a14		; target is positive
	jrlt	pos_check
	move	a8,*a9,L	; SET TARGET AND LEAVE
end_check:
	move	*a12+,a0,L	; pop scroll accel address
	clr	a14
	move	a14,*a0,L	; clear accel
	JRUC	SCRL_DISPATCHER
	

neg_check:
	sleep	1
	move	*a9,a14,L
	cmp	a8,a14		; target is negative
	jrgt	neg_check
	move	a8,*a9,L	; SET TARGET AND LEAVE
	jruc	end_check


S_Y_ACCEL_LIMIT:
	MOVE	*A11+,A14,W
	MOVE	A14,@YSACCEL,L
	movi	YSCROLL,a9
	movi	YSACCEL,a0
	move	a0,*-a12,L	; push scroll accel address
	jruc	acc_lim_hk

S_Z_ACCEL_LIMIT:
	MOVE	*A11+,A14,W
	sll	ZFRAC,a14
	MOVE	A14,@ZSACCEL,L
	movi	ZSCROLL,a9
	movi	ZSACCEL,a0
	move	a0,*-a12,L	; push scroll accel address

	MOVE	*A11+,A8,L	; target
	sll	ZFRAC,a8
	jrn	neg_check
	jruc	pos_check

S_X_DECEL_LIMIT:
	MOVE	*A11+,A14,W
	MOVE	A14,@XSACCEL,L
	movi	XSCROLL,a9
	movi	XSACCEL,a0
	move	a0,*-a12,L	; push scroll accel address

dec_lim_hk:
	MOVE	*A11+,A8,L	; target
	MOVE	*A9,A14,L
	CMP	A8,A14
	JRLT	pos_check
	JRUC	neg_check
;	jrnn	neg_check
;	jruc	pos_check
S_Y_DECEL_LIMIT:
	MOVE	*A11+,A14,W
	MOVE	A14,@YSACCEL,L
	movi	YSCROLL,a9
	movi	YSACCEL,a0
	move	a0,*-a12,L	; push scroll accel address
	jruc	dec_lim_hk

S_Z_DECEL_LIMIT:
	MOVE	*A11+,A14,W
	sll	ZFRAC,a14
	MOVE	A14,@ZSACCEL,L
	movi	ZSCROLL,a9
	movi	ZSACCEL,a0
	move	a0,*-a12,L	; push scroll accel address
	MOVE	*A11+,A8,L	; target
	sll	ZFRAC,a8
	MOVE	*A9,A14,L
	SLL	ZFRAC,A14
	CMP	A8,A14
	JRLT	pos_check
	JRUC	neg_check

**************************************************************************
*								         *
* S_XYZ_DECEL_LIMIT							 *
*								         *
**************************************************************************

S_XYZ_DECEL_LIMIT
	CLR	A8
	
	MMFM	A11,A1,A2			;GET DECELS
	MOVE	A2,A3
	SEXT	A3,W				;X DECEL
	SRA	16,A2				;Y DECEL
	SEXT	A1,W			
	SLL	ZFRAC,A1			;Z HI-RES DECEL
	SUBK	010H,A11
	MOVE	A11,A9
	MMFM	A11,A4,A5,A6			;GET TARGET VELOCITIES
	SLL	ZFRAC,A4			;Z HI-RES TARGET

	MOVE	A3,A3
	JRZ	SDL_SETUP_Y
	MOVK	1,A7				;INCREASING X
	MOVE	@XSCROLL,A14,L
	CMP	A6,A14
	JRLE	SDL_DO_X			;BR=INCREASING X
	MOVK	2,A7				;DECREASING X
SDL_DO_X
	OR	A7,A8
	MOVE	A3,@XSACCEL,L
SDL_SETUP_Y
	MOVE	A2,A2
	JRZ	SDL_SETUP_Z
	MOVK	1 << 2,A7			;INCREASING Y
	MOVE	@YSCROLL,A14,L
	CMP	A5,A14
	JRLE	SDL_DO_Y			;BR=INCREASING Y
	MOVK	2 << 2,A7			;DECREASING Y
SDL_DO_Y
	OR	A7,A8
	MOVE	A2,@YSACCEL,L
SDL_SETUP_Z
	MOVE	A1,A1
	JRZ	SDL_GO
	MOVK	1 << 4,A7			;INCREASING Z
	MOVE	@ZSCROLL,A14,L
	CMP	A4,A14
	JRLE	SDL_DO_Z			;BR=INCREASING Z
	MOVK	2 << 4,A7			;DECREASING Z
SDL_DO_Z
	OR	A7,A8
	MOVE	A1,@ZSACCEL,L
SDL_GO
	SLEEP	1

	MOVE	A9,A14
	MMFM	A14,A1,A2,A3			;GET TARGET VELOCITIES

	MOVK	3,A4				;X MASK
	MOVE	A8,A14
	AND	A4,A14
	JRZ	SDL_CHECK_Y
	MOVE	@XSCROLL,A5,L
	BTST	0,A14
	JRZ	SDL_X_DEC
	CMP	A3,A5
	JRLT	SDL_CHECK_Y
	JRUC	SDL_X_DONE	
SDL_X_DEC
	CMP	A3,A5
	JRGT	SDL_CHECK_Y
SDL_X_DONE
	ANDN	A4,A8
	MOVE	A3,@XSCROLL,L
	CLR	A14
	MOVE	A14,@XSACCEL,L
SDL_CHECK_Y

	MOVK	12,A4				;Y MASK
	MOVE	A8,A14
	AND	A4,A14
	JRZ	SDL_CHECK_Z
	MOVE	@YSCROLL,A5,L
	BTST	0+2,A14
	JRZ	SDL_Y_DEC
	CMP	A2,A5
	JRLT	SDL_CHECK_Z
	JRUC	SDL_Y_DONE	
SDL_Y_DEC
	CMP	A2,A5
	JRGT	SDL_CHECK_Z
SDL_Y_DONE
	ANDN	A4,A8
	MOVE	A2,@YSCROLL,L
	CLR	A14
	MOVE	A14,@YSACCEL,L
SDL_CHECK_Z

	MOVI	48,A4				;Z MASK
	MOVE	A8,A14
	AND	A4,A14
	JRZ	SDL_CHECK_DONE
	MOVE	@ZSCROLL,A5,L
	BTST	0+4,A14
	JRZ	SDL_Z_DEC
	CMP	A1,A5
	JRLT	SDL_CHECK_DONE
	JRUC	SDL_Z_DONE	
SDL_Z_DEC
	CMP	A1,A5
	JRGT	SDL_CHECK_DONE
SDL_Z_DONE
	ANDN	A4,A8
	MOVE	A1,@ZSCROLL,L
	CLR	A14
	MOVE	A14,@ZSACCEL,L
SDL_CHECK_DONE
	MOVE	A8,A8
	JRNZ	SDL_GO
	JRUC	SCRL_DISPATCHER
	

**************************************************************************
*								         *
* S_DECEL_TO_STOP   - Decelerate scroll to a stop in a given # of ticks  *
*								         *
* 	.LONG	S_DECEL_TO_STOP						 *
*	.word	4-8  (16,32,64,128,256)	       				 *
*									 *
**************************************************************************
S_DECEL_TO_STOP:
	move	*a11+,a14		; power of 2
	movk	1,a0
	sll	a14,a0			; ticks to sleep
	neg	a14

	move	@XSCROLL,a1,L
	sra	a14,a1			; 256 seconds
	neg	a1
	move	a1,@XSACCEL,L

	move	@YSCROLL,a1,L
	sra	a14,a1
	neg	a1
	move	a1,@YSACCEL,L

	move	@ZSCROLL,a1,L
	sra	a14,a1
	neg	a1
	move	a1,@ZSACCEL,L

	move	@WAVEVEL,a8
	add	a0,a8		; desired WAVEVEL for stop
	srl	1,a0
	calla	PRCSLP			; sleep
SDTS_wait_accel	
	sleep	1

	move	@WAVEVEL,a0
	cmp	a0,a8
	jrgt	SDTS_wait_accel

;	calla	PRCSLP
	jruc	S_STOP_SCROLL


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


COMP_ACC1	.macro	base,rs,rd
	move	@base,a7,L
	sub	rs,a7
	jrz	comac1?
	neg	a7
	sll	1,a7
	divs	a2,a7
comac1?
	move	a7,rd
	.endm


STOP_CHK	.macro	scrl,accel
	move	@scrl,a14,L		; is abs(SCROLL) < abs(ACCEL)
	move	@accl,a0,L
	jrz	nochk?			; if accel == 0, no point, go on
	move	a0,a1
	xor	a14,a1			; if signs are equal, gone too far
	jrnn	stop?
	abs	a0
	abs	a14
	cmp	a0,a14
	jrgt	nostop?
stop?:
	move	a6,@scrl,L		; time to stop in X
	move	a6,@accl,L
	jruc	nochk?
nostop?:
	inc	a7			; indicate keep going
nochk?:
	.endm


**************************************************************************
*								         *
* S_DECEL_TO_POINTZ   - Decelerate to a stop at a given Z 	 	 *
*                       and the current X and Y	in a			 *
*			given # of ticks    				 *
*								         *
* 	.LONG	S_DECEL_TO_POINTZ					 *
*	.word	#ticks 			      				 *
*	.long	Z
*	.word	sleep upon arrival					 *
**************************************************************************
S_DECEL_TO_POINTZ:
	move	*a11+,a1		; ticks

	move	@XBASE,a10,L
	move	@YBASE,a9,L
	jruc	DECEL_HOOK1


	.def	S_DECEL_TO_POINTX_DELTA

**************************************************************************
*								         *
* S_DECEL_TO_POINTX_DELTA  - Decelerate to a stop at a given X	 	 *
*								         *
* 	.LONG	S_DECEL_TO_POINTX_DELTA					 *
*	.long	X							 *
**************************************************************************
S_DECEL_TO_POINTX_DELTA:
	move	*a11+,a10,L
	jrz	SCRL_DISPATCHER		; shouldn't be zero
*
*	formula is  a = v**2 / 2*d
*
	move	@XSCROLL,a2,L
	move	a2,a1
	mpys	a1,a2		; result in a3:a2
	sll	1,a10
	divs	a10,a2		; a2 has acceleration
	neg	a2		; check sign of accel
	move	a2,@XSACCEL,L
	jrn	SDTP_neg
SDTPwaitn:
*	accel is pos, wait for XBASE > targ or XSCROLL too slow
	move	@XSCROLL,a0,L
	cmpi	-4000h,a0
	jrgt	S_STOP_X_MOTION
	sloop	1,SDTPwaitn

*	accel is neg, wait for XBASE < targ or XSCROLL too slow
SDTP_neg:
	move	@XSCROLL,a0,L
	cmpi	4000h,a0
	jrlt	S_STOP_X_MOTION
	sloop	1,SDTP_neg

S_STOP_X_MOTION:
	CLRM	@XSCROLL,L
	move	a14,@XSACCEL,L
	jruc	SCRL_DISPATCHER

**************************************************************************
*								         *
* S_DECEL_TO_POINT   - Decelerate to a stop at a given point in a 	 *
*			given # of ticks    				 *
*								         *
* 	.LONG	S_DECEL_TO_POINT					 *
*	.word	#ticks 			      				 *
*	.word	X,Y
*	.long	Z
*	.word	sleep upon arrival					 *
**************************************************************************
S_DECEL_TO_POINT:
	move	*a11+,a1		; ticks

	move	*a11+,a10,L		; Y:X
	clr	a9
	movy	a10,a9			; Y in a9
	sll	16,a10			; X in a10
DECEL_HOOK1:			
	move	*a11+,a8,L		; Z in a8
	sll	ZFRAC,a8		;TRANSLATE TO HI-RES

DECEL_HOOK2:
	move	a1,a1			; if duration is neg, Z is relative
	jrnn	skzadj1
	move	@ZREL_OFF,a7,L	   ; if supplied Z is relative 
	add	a7,a8		   ; convert it to absolute
	neg	a1
skzadj1:	

DECEL_TO_POINT_A:
	move	a1,a0			;   in a0
	mpys	a0,a1			; t squared in a1
	move	a1,a2			; t squared in a2
*
*	a = 2(d-vt)/t*t
*
	COMP_DEC1	XSCROLL,XBASE,a10,a5
	COMP_DEC1	YSCROLL,YBASE,a9,a4
	COMP_DEC1	ZSCROLL,ZBASE_HR,a8,a3

	movi	ZSACCEL+20h,a7
	mmtm	a7,a3,a4,a5	; stuff accelerations

	move	@WAVEVEL,a8
	add	a0,a8		; desired WAVEVEL for stop
	srl	1,a0
	calla	PRCSLP			; sleep
wait_decel:	
	sleep	1

	move	@WAVEVEL,a0
	cmp	a0,a8
	jrgt	wait_decel

;	STOP_CHK	XSCROLL,XACCEL
;	STOP_CHK	YSCROLL,YACCEL
;	STOP_CHK	ZSCROLL,ZACCEL
;
;	or	a7,a7
;	jrnz	wait_decel

	clr	a14
	move	a14,@XSCROLL,L
	move	a14,@YSCROLL,L
	move	a14,@ZSCROLL,L
	move	a14,@XSACCEL,L
	move	a14,@YSACCEL,L
	move	a14,@ZSACCEL,L
	jruc	GTP_ON_THE_MARK


	
**************************************************************************
*								         *
* ACCEL_TO_POINT   - Accelerate to a point in a	given # of ticks    	 *
*		     Any final velocity will be possible	         *
*									 *
* 	.LONG	S_ACCEL_TO_POINT					 *
*	.word	#ticks			       				 *
*	.word	X,Y					
*	.long	Z
*	.word	sleep upon arrival					 *
**************************************************************************
S_ACCEL_TO_POINT:
	move	*a11+,a1		; ticks

	move	*a11+,a10,L  		; Y:X
	clr	a9
	movy	a10,a9			; Y in a9
	sll	16,a10			; X in a10
	move	*a11+,a8,L		; Z in a8
	sll	ZFRAC,a8		;TRANSLATE TO HI-RES

	move	a1,a1		   ; if duration is neg, Z is relative
	jrnn	skzadj2
	move	@ZREL_OFF,a7,L	   ; if supplied Z is relative 
	add	a7,a8		   ; convert it to absolute
	neg	a1
skzadj2:	

	move	a1,a0			;   in a0
;	dec	a1
	mpys	a0,a1			; t * t-1 in a1
	move	a1,a2			; t * t-1 in a2
*
*	a = 2(d-vt)/t*t
*
	COMP_DEC1	XSCROLL,XBASE,a10,a5
	COMP_DEC1	YSCROLL,YBASE,a9,a4
	COMP_DEC1	ZSCROLL,ZBASE_HR,a8,a3

same_as_accel:

	movi	ZSACCEL+20h,a7
	mmtm	a7,a3,a4,a5	; stuff accelerations

	move	@WAVEVEL,a8
	add	a0,a8		; desired WAVEVEL for stop
	srl	1,a0
	calla	PRCSLP			; sleep
wait_accel:	
	sleep	1

	move	@WAVEVEL,a0
	cmp	a0,a8
	jrgt	wait_accel

;	STOP_CHK	XSCROLL,XACCEL
;	STOP_CHK	YSCROLL,YACCEL
;	STOP_CHK	ZSCROLL,ZACCEL
;
;	or	a7,a7
;	jrnz	wait_accel

	clr	a14
	move	a14,@XSACCEL,L
	move	a14,@YSACCEL,L
	move	a14,@ZSACCEL,L
	jruc	GTP_ON_THE_MARK


**************************************************************************
*
* 	.LONG	S_AT_PORTAL_ENTRANCE
*
*	called from SCROLL TABLE before S_SET_PORTAL when you are
*	at the zoom point of a portal.
*
**************************************************************************
S_AT_PORTAL_ENTRANCE:
	move	@XBASE,a6,L
	move	@YBASE,a5,L
	calla	PushUniverse	       
	LOCKON	C		       	; should never happen
	jruc	SCRL_DISPATCHER

**************************************************************************
*								         *
*       PORTAL_GUNVECT							 *
*									 *
*	When a portal is shot, this routine checks to see if 		 *
*	the player who shot it has the power to enter.  If he		 *
*	does, the current scroll dispatch process is saved		 *
*	and the portal is entered.					 *
*									 *
*	A scroll table needs to be supplied which tells which		 *
*	universe to go into.  The OID of the portal is used to 		 *
*	index into a table of SCROLL_TABLES. 				 *
*						                         *
* A2 = PTR TO PLAYER						         *
* A8 = PTR TO OBJECT							 *
*							                 *
**************************************************************************

PORTAL_GUNVECT:
	move	@PORTAL_LOCKOUT,a0
	jrnz	IgunPortGV
*
*	Insert player check here.  For test, always allow
*
	move	*a8(OID),a0	; isolate sub-type bits
	andi	MASK_ID,a0
	srl	BIT_ID,a0	
	sll	5,a0		; table is long word aligned
	move	@WAVE_PORTAL_TBL,a14,L
	add	a14,a0		
	move	*a0,a7,L	; new SCROLL_DISPATCH TABLE in a7
	jrz	IgunPortGV
*
*	Interrupt current Scroller, but save
*
	move	@SCROLL_PROCESS,a14,L
	move	*a14(PSPTR),a6,L
	move	a14,a5
	addi	PA11,a5
	move	a2,b0
	mmfm	a5,a0,a1,a2,a3,a4
	mmtm	a6,a0,a1,a2,a3,a4	; save wake and regs on Proc stack
	move	*a14(PTIME),a3		; 
	move	a3,*-a6			; push PTIME
	move	a7,*a14(PA11),L		; new scroll table
	movi	SCRL_DISPATCHER,a0
	move	a0,*a14(PWAKE),L
 
	MOVK	1,A0
	move	a0,*a14(PTIME),W

	movi	DUMMY_SCROLL,a0
	move	a0,*-a6,L		; push onto stack
	move	a6,*a14(PSPTR),L	; save new stack pointer
	move	a6,*a14(LAST_SP),L	; update stack
	move	*a14(PUSHCNT),a3
	inc 	a3			; increment push counter
	move	a3,*a14(PUSHCNT)       	; to indicate CALL
	move	b0,a2
	move	a3,@PORTAL_LOCKOUT	; prevent further portal shooting
IgunPortGV:
	rets


DUMMY_SCROLL:
	.long	PORTAL_RETURN
*
*	All Gunvector SCROLL TABLES will automatically come here. 
*
PORTAL_RETURN:
	move	*a13(LAST_SP),a12,L	; restore in case it got fucked
	move	*a12+,a3		; 
	move	a3,*a13(PTIME)		; restore PTIME
	mmfm	a12,a7,a8,a9,a10,a11
	move	@UNIV_SP,a0,L
	subi	UNIV_STK_SIZ-PU_XSACCEL,a0     ; to get previous universe
	mmfm	a0,a1,a2,a3,a4,a5,a6  		; ACCELS a4-a6, VELS a1-a3
	movi	XSCROLL+60h,a0
	mmtm	a0,a1,a2,a3
	movi	XSACCEL+60h,a0
	mmtm	a0,a4,a5,a6
	clr	a0
	move	a0,@PORTAL_LOCKOUT	; allow further portal shooting
	move	a12,*a13(LAST_SP),L	; update stack ptr
	movk	1,a0			; sleep time
	jauc	PRCLSP

**************************************************************************
*								         *
* S_HILLFUNC - FORWARD HILL FUNCTION					 *
*								         *
**************************************************************************

S_HILLFUNC
	MOVI	0478H,A14
	MOVE	A14,@ZSCROLL,L
	SLEEP	40
*
*ENTRYPOINT: JUMP FOR CONVEYOR BELT IN THE MAIN EVERGREEN CHEMICAL ROOM
*
S_JUMP_CONVEYOR
	MOVI	0238E3H,A14
	MOVE	A14,@YSACCEL,L
	SLEEP	6

	MOVI	-0238E3H,A14
	MOVE	A14,@YSACCEL,L
	SLEEP	6*2

	MOVI	0238E3H,A14
	MOVE	A14,@YSACCEL,L
	SLEEP	6

	CLR	A14	
	MOVE	A14,@ZSCROLL,L
	MOVE	A14,@YSACCEL,L

	MOVK	2,A8
SHAKE_LUPE
	MOVI	080000H,A14
	MOVE	A14,@YSCROLL,L
	SLEEP	3
	MOVI	-080000H,A14
	MOVE	A14,@YSCROLL,L
	SLEEP	3
	DSJ	A8,SHAKE_LUPE

	CLR	A14	
	MOVE	A14,@YSCROLL,L

	JRUC	SCRL_DISPATCHER



S_HILLFUNC2
	MOVI	0480H,A14
	MOVE	A14,@ZSCROLL,L
	sleep	24


	MOVI	011000H,A14
	MOVE	A14,@YSACCEL,L
	SLEEP	10

	MOVI	-011000H,A14
	MOVE	A14,@YSACCEL,L
	SLEEP	10*2

	MOVI 	-40h,A14
	move	a14,@ZSACCEL,L

	MOVI	011000H,A14
	MOVE	A14,@YSACCEL,L
	SLEEP	10

	CLR	A14	
	MOVE	A14,@YSACCEL,L
	MOVE	A14,@YSCROLL,L


stillok:
	sleep	1
	move	@ZSCROLL,a14,L
	jrnn	stillok
	clr	a14
	move	a14,@ZSACCEL,L
	move	a14,@ZSCROLL,L


	JRUC	SCRL_DISPATCHER


**************************************************************************
*								         *
* S_HILLFUNC_REV - REVERSE HILL FUNCTION					 *
*								         *
**************************************************************************

S_HILLFUNC_REV
	MOVI	-0478H,A14
	MOVE	A14,@ZSCROLL,L
	MOVI	0238E3H,A14
	MOVE	A14,@YSACCEL,L
	SLEEP	6

	MOVI	-0238E3H,A14
	MOVE	A14,@YSACCEL,L
	SLEEP	6

	CLR	A14	
	MOVE	A14,@YSCROLL,L
	MOVE	A14,@YSACCEL,L
	SLEEP	10

	MOVI	-0238E3H,A14
	MOVE	A14,@YSACCEL,L
	SLEEP	6

	MOVI	0238E3H,A14
	MOVE	A14,@YSACCEL,L
	SLEEP	6

	CLR	A14	
	MOVE	A14,@YSCROLL,L
	MOVE	A14,@YSACCEL,L
	SLEEP	30

	CLR	A14	
	MOVE	A14,@ZSCROLL,L

	JRUC	SCRL_DISPATCHER

**************************************************************************
*								         *
* S_SET_XSCROLL	- SET XSCROLL						 *
*								         *
* 	.LONG	S_SET_XSCROLL						 *
*	.long	Xscroll_value						 *
*									 *
**************************************************************************
S_SET_XSCROLL
	MOVE	*A11+,A14,L
	MOVE	A14,@XSCROLL,L
	JRUC	SCRL_DISPATCHER

**************************************************************************
*								         *
* S_SET_YSCROLL	- SET YSCROLL						 *
*								         *
* 	.LONG	S_SET_YSCROLL						 *
*	.long	Yscroll_value						 *
*									 *
**************************************************************************

S_SET_YSCROLL
	MOVE	*A11+,A14,L
	MOVE	A14,@YSCROLL,L
	JRUC	SCRL_DISPATCHER

**************************************************************************
*								         *
* S_SET_ZSCROLL	- SET ZSCROLL						 *
*								         *
* 	.LONG	S_SET_ZSCROLL						 *
*	.word	Zscroll_value (lo res)					 *
*	.word	ticks to wait         					 *
*									 *
**************************************************************************

S_SET_ZSCROLL
	MOVE	*A11+,A14,W
	sll	ZFRAC,a14	       	; convert to hires
	MOVE	A14,@ZSCROLL,L
	JRUC	S_WAIT_HERE

**************************************************************************
*								         *
* S_STOP_SCROLL	- STOP SCROLLING!					 *
*								         *
* 	.LONG	S_STOP_SCROLL						 *
*								         *
**************************************************************************

S_STOP_SCROLL
	CLR	A1
	CLR	A2
	CLR	A3
	CLR	A4
	CLR	A5
	CLR	A6
	MOVI	ZSACCEL+020H,A14
	MMTM	A14,A1,A2,A3,A4,A5,A6
	JRUC	SCRL_DISPATCHER

**************************************************************************
*
*	.long  S_WAIT_FOR_Z_DELTA
*	.long	Delta Z to wait for (lo res)
*	.word	0 to stop, non-zero to leave scrolling in Z
*
**************************************************************************
S_WAIT_FOR_Z_DELTA:
	move	*a11+,a9,L	; Z DELTA
	move	@ZBASE,a14,L
	add	a14,a9
	JRUC	skip_zadj


**************************************************************************
*
*	.long  S_WAIT_FOR_Z		Relative to this universe
*	.long  S_WAIT_FOR_ZREL	 	Relative to this universe
*	.long  S_WAIT_FOR_ZABS		Absolute
*	.long	Z to wait for (lo res)
*	.word	0 to stop, non-zero to leave scrolling in Z
*
**************************************************************************
S_WAIT_FOR_ZABS:
	move	*a11+,a9,L	; Univ abs Z
	JRUC	skip_zadj
S_WAIT_FOR_ZREL:		 
	move	*a11+,a9,L	; Univ rel Z
	move	@ZREL_OFF,a14,L	 
	sra	ZFRAC,a14
	add	a14,a9
	JRUC	skip_zadj	 
S_WAIT_FOR_Z:
	move	*a11+,a9,L	; Univ Z
	move	@UNIV_ID,a14
	jrz	skip_zadj
	move	@PORTAL_ENTRANCE,a0,L	; 
	move	*a0(40h),a14,L		; 
	sra	ZFRAC,a14
	add	a14,a9
skip_zadj:
	move	@ZBASE,a0,L
	sub	a9,a0
	jreq	just_right
	jrlt	toosmall
toobig:
	MOVE	@ZSACCEL,A14,L		;Are we accelerating the right way
	JRN	TOOBIG_SLP		;BR = Yes.  Then that's good enuff.
	MOVE	@ZSCROLL,A14,L
	JRP	just_right		;BR = We're all wrong, let's bail
TOOBIG_SLP
	sleep	1
	move	@ZBASE,a0,L
	sub	a9,a0
	jrgt	toobig
just_right:
	move	*a11+,a0
	jrnz	SCRL_DISPATCHER
	move	a0,@ZSACCEL,L
	move	a0,@ZSCROLL,L
	jruc	SCRL_DISPATCHER

toosmall:
	MOVE	@ZSACCEL,A14,L		;Are we accelerating the right way
	JRP	TOOSMALL_SLP		;BR = Yes.  Then that's good enuff.
	MOVE	@ZSCROLL,A14,L
	JRN	just_right		;BR = We're all wrong, let's bail
TOOSMALL_SLP
	sleep	1
	move	@ZBASE,a0,L
	sub	a9,a0
	jrlt	toosmall
	jruc	just_right

**************************************************************************
*
*	.long  S_WAIT_FOR_COORD
*	.LONG	COORD ADDRESS TO WAIT FOR
*	.long	COORD VALUE to wait for
*	.word	0 to stop, non-zero to leave scrolling in COORD
*
**************************************************************************

*	.long  S_WAIT_FOR_X_DELTA
*	.long	VALUE to wait for  (handles wraparound from pos to neg)
*
S_WAIT_FOR_X_DELTA:
	movi	XBASE,a10
	movi	XSCROLL,a8	; XSCROLL assumed positive (for wrap chk)
	move	*a11+,a9,L	; X DELTA
	move	*a10,a0,L	; XBASE
	add	a0,a9
	xor	a9,a0		; do they have the same sign bit?
	move	a0,a0
	jrnn	SWFC_GO		; process normally if yes
	move	a9,a9
	jrnn	SWFC_GO		; if dest is positive, process normally
*
*	WRAPAROUND CASE!!!  wait til XBASE is negative, then process normally
*
wrapchk:
	sleep	1
	move	*a10,a0,L	; check XBASE
	jrnn	wrapchk
	jruc	SWFC_GO

S_WAIT_FOR_X:
	move	*a11+,a9,L
	movi	XSCROLL,a8
	movi	XBASE,a10
	jruc	SWFC_GO


S_WAIT_FOR_COORD_ZREL:
	MOVI	ZBASE_HR,A10
	MOVI	ZSCROLL,A8
	move	*a11+,a9,L		; COORD VALUE
	SLL	ZFRAC,A9
	move	@ZREL_OFF,a14,L	 
	add	a14,a9
	JRUC	SWFC_GO
S_WAIT_FOR_COORD:
	move	*a11+,a10,L		; COORD ADDRESS
	move	*a11+,a9,L		; COORD VALUE
	CMPI	ZBASE,A10
	JRNE	SWFC_NOZ
	MOVI	ZBASE_HR,A10
	MOVI	ZSCROLL,A8
	SLL	ZFRAC,A9
	JRUC	SWFC_GO
SWFC_NOZ
	MOVE	A10,A8
	SUBI	XBASE,A8		;GET OFFSET
	ADDI	XSCROLL,A8		;GET SCROLL ADDRESS
SWFC_GO
	move	*A10,a0,L
	sub	a9,a0
	jreq	Cjust_right
	jrlt	Ctoosmall
Ctoobig:
	sleep	1

	MOVE	*A8,A14,L	
	JRNN	Cjust_right		;BR=WRONG OR NO SCROLL DIRECTION
	move	*A10,a0,L
	ADD	A14,A0
	sub	a9,a0
	jrgt	Ctoobig			;BR=NOT THERE YET!
Cjust_right:
	move	*a11+,a0
	jrnz	SCRL_DISPATCHER
	MOVE	A0,*A8,L		;SHOVE SCROLL
	ADDI	060H,A8			;ADD OFFSET TO ACCELS
	MOVE	A0,*A8,L		;SHOVE ACCEL
	jruc	SCRL_DISPATCHER

Ctoosmall:
	sleep	1

	MOVE	*A8,A14,L	
	JRN	Cjust_right		;BR=WRONG SCROLL DIRECTION
	JRZ	Cjust_right		;BR=WE'RE NOT GOIN' MAKE IT! WE'RE DOOMED!
	move	*A10,a0,L
	ADD	A14,A0
	sub	a9,a0
	jrlt	Ctoosmall		;BR=NOT THERE YET!			
	jruc	Cjust_right

**************************************************************************
*
*	.long  S_WAIT_FOR_VALUE
*	.LONG	VALUE ADDRESS TO WAIT FOR
*	.long	VALUE to wait for
*
**************************************************************************
S_WAIT_FOR_VALUE:
	move	*a11+,a10,L	; VALUE ADDRESS
	move	*a11+,a9,L	; VALUE VALUE
	move	*A10,a0,L
	sub	a9,a0
	jreq	SCRL_DISPATCHER
	jrlt	Vtoosmall
Vtoobig:
	sleep	1
	move	*A10,a0,L
	sub	a9,a0
	jrgt	Vtoobig
	jruc	SCRL_DISPATCHER

Vtoosmall:
	sleep	1
	move	*A10,a0,L
	sub	a9,a0
	jrlt	Vtoosmall
	jruc	SCRL_DISPATCHER

**************************************************************************
*
*    .LONG   S_CHANGE_ZFAR
*    .long   new_ZFAR
*
**************************************************************************
S_CHANGE_ZFAR:
	move	*a11+,a0,L
	calla	CHANGE_ZFAR
	jruc	SCRL_DISPATCHER


**************************************************************************
*
*    .LONG   S_CREATE_PROC
*    .word   PID
*    .long   Process_address
*
**************************************************************************
S_CREATE_PROC
	move	*a11+,a1
	move	*a11+,a7,L
	calla	GETPRC
	jruc	SCRL_DISPATCHER

**************************************************************************
*
* S_CREATE_PROCR - CREATE MULTIPLE PROCESSES WITH REGISTER PARAMETERS
*                  A WORD OF 0 TERMINATES THE LIST
*
*    .LONG   S_CREATE_PROCR
* A11 POINTS TO:
*    .word   PID
*    .LONG   A11
*    .LONG   A10
*    .LONG   A9
*    .LONG   A8
*    .long   Process_address
*	.
*	.
*	.
*    .WORD   0
*
**************************************************************************

S_CREATE_PROCR
	move	*a11+,a1,W
	JRZ	S_CPR_END
	MOVE	A11,A14
	MMFM	A14,A7,A8,A9,A10,A11
	MOVE	A14,A2
	calla	GETPRC
	MOVE	A2,A11
	JRUC	S_CREATE_PROCR
S_CPR_END
	jruc	SCRL_DISPATCHER


**************************************************************************
*
*    .LONG   S_LOCKOUT_PORTALS
*
*	So no portal will respond to gunfire
*
**************************************************************************
S_LOCKOUT_PORTALS:
	movk	1,a14
	move	a14,@PORTAL_LOCKOUT
	jruc	SCRL_DISPATCHER


**************************************************************************
*
*    .LONG   S_ALLOW_PORTALS
*
*	So portals whose OIDs permit GUNVECT entry can respond to gunfire
*
**************************************************************************
S_ALLOW_PORTALS:
	clr	a14
	move	a14,@PORTAL_LOCKOUT
	jruc	SCRL_DISPATCHER

**************************************************************************
* DOZER'S TEST STUFF
**************************************************************************
**************************************************************************
**************************************************************************

**************************************************************************
*								         *
* S_WAIT_UNTIL_TRUE - WAIT UNTIL A RAM BYTE IS NON-ZERO (TRUE)		 *
* 									 *
* 	.LONG	RAM BYTE ADDRESS					 *
*								         *
**************************************************************************

S_WAIT_UNTIL_TRUE
	MOVE	*A11+,A8,L
WUT_LUPE
	SLEEP	1
	MOVB	*A8,A14
	JRZ	WUT_LUPE
	JRUC	SCRL_DISPATCHER

	
**************************************************************************
*								         *
* S_WAIT_UNTIL_FALSE - WAIT UNTIL A RAM BYTE IS ZERO (FALSE)		 *
* 									 *
* 	.LONG	RAM BYTE ADDRESS					 *
*								         *
**************************************************************************

S_WAIT_UNTIL_FALSE
	MOVE	*A11+,A8,L
WUF_LUPE
	SLEEP	1
	MOVB	*A8,A14
	JRNZ	WUF_LUPE
	JRUC	SCRL_DISPATCHER

**************************************************************************
*								         *
* S_WAIT_FOR_COUNTDOWN - WAIT UNTIL A RAM BYTE IS <= ZERO		 *
* 									 *
* 	.LONG	RAM BYTE ADDRESS					 *
*								         *
**************************************************************************

S_WAIT_FOR_COUNTDOWN
	MOVE	*A11+,A8,L
WFC_LUPE
	SLEEP	1
	MOVB	*A8,A14
	JRGT	WFC_LUPE
	JRUC	SCRL_DISPATCHER


**************************************************************************
*								         *
* S_KILL_POWERUPS - KILL POWERUP DISPATCHER #0				 *
*								         *
**************************************************************************

S_KILL_POWERUPS
	MOVI	PID_POWERUPD0,A0
	CALLA	KILLPROC_ALL
	MOVI	PID_POWERUPD1,A0
	CALLA	KILLPROC_ALL
	MOVI	PID_POWERUPD2,A0
	CALLA	KILLPROC_ALL
	JRUC	SCRL_DISPATCHER

**************************************************************************
*								         *
* S_SOUND - MAKE SOME NOISE!						 *
*								         *
**************************************************************************

S_SOUND
	MOVE	*A11+,A0,L
	CALLA ONESND
	JRUC	SCRL_DISPATCHER

**************************************************************************
*								         *
* S_SET_ENEMIES - SET STATE OF OBJENEMIES				 *
*								         *
**************************************************************************

S_SET_ENEMIES
	MOVE	*A11+,A14,W
	MOVE	A14,@OBJENEMIES,W
	JRUC	SCRL_DISPATCHER

**************************************************************************
*								         *
* S_START_BGND - START A BACKGROUND INFINITY PLANE			 *
*								         *
**************************************************************************
S_START_BGND	
	PUSH	A10
	MOVE	*A11+,A10,L
	CALLA	StrtBgnd		;FIRE UP THE BACKGROUND	INFINITY PLANE
	PULLQ	A10
	JRUC	SCRL_DISPATCHER

**************************************************************************
*								         *
* S_START_UNIVERSE - START A UNIVERSE					 *
*								         *
* 	.long	UNIVERSE						 *
* 	.long	UNIVERSE X, UNIVERSE Y, UNIVERSE Z			 *
*								         *
**************************************************************************

S_START_UNIVERSE
	CALLA	RMV_OBJS_FROM_UNIVERSE
	CALLA	INIT_LINKED_LIST
	
	MOVI	PID_UNIV,A0
	CALLA	KILLPROC_ALL

	CREATEP	PID_IND,START_UNIVERSE_PROC

	ADDI	020H*4,A11
	JRUC	SCRL_DISPATCHER

START_UNIVERSE_PROC
	MOVE	*A11+,A0,L			;NEW UNIVERSE ADDRESS

	MOVE	A0,@WAVE_UNIV,L		;THIS IS THE UNIVERSE!

	MOVE	*A11+,A14,L
	MOVE	A14,@XBASE,L			;NEW UNIVERSE X
	MOVE	*A11+,A14,L
	MOVE	A14,@YBASE,L			;NEW UNIVERSE Y
	MOVE	*A11,A14,L
	MOVE	A14,@ZBASE,L			;NEW UNIVERSE Z
	sll	ZFRAC,a14		
	MOVE	A14,@ZBASE_HR,L		

	MOVE	*A11,A10,L			;Z OFFSET
	MOVE	A10,A14
	SLL	ZFRAC,A14			;SAVE AS HI-RES Z OFFSET
	MOVE	A14,@ZREL_OFF,L

	MOVE	@YWORLD,A14,L
	MOVE	*A0(010H*4 + 020H),A11,L
	SUB	A14,A11				;Y OFFSET
	MOVE	A11,@YREL_OFF,L

	JSRP	START_UNIVERSE

	MOVE	@SKYCOLOR,@IRQSKYE,W
	MOVE	@GROUNDCOLOR,@IRQGNDE,W

	DIE

**************************************************************************
*								         *
* S_START_UNIVERSE0							 *
*								         *
*  	.long	UNIVERSE						 *
*  	.long	UNIVERSE X, UNIVERSE Y (NEW FROM THE NEW UNIVERSE)	 *
* 	.LONG	UNIVERSE Z (CONTINUOUS FROM THE CURRENT UNIVERSE) 	 *
* 	.LONG	WORLD Z OFFSET (Z DIFFERENCE BETWEEN UNIVERSES)		 *
*								         *
**************************************************************************

S_START_UNIVERSE0
	CALLA	RMV_OBJS_FROM_UNIVERSE
	CALLA	INIT_LINKED_LIST
	
	MOVI	PID_UNIV,A0
	CALLA	KILLPROC_ALL

	CREATEP	PID_IND,START_UNIVERSE0_PROC

	ADDI	020H*5,A11
	JRUC	SCRL_DISPATCHER

START_UNIVERSE0_PROC
	MOVE	*A11+,A0,L			;NEW UNIVERSE ADDRESS

	MOVE	A0,@WAVE_UNIV,L		;THIS IS THE UNIVERSE!

	MOVE	*A11+,A14,L
	MOVE	A14,@XBASE,L			;NEW UNIVERSE X
	MOVE	*A11+,A14,L
	MOVE	A14,@YBASE,L			;NEW UNIVERSE Y

	MOVE	*A11+,A14,L			
	MOVE	A14,@ZBASE,L			;CONTINUOUS UNIVERSE Z
	sll	ZFRAC,a14		
	MOVE	A14,@ZBASE_HR,L		

	MOVE	*A11,A10,L			;Z OFFSET

	MOVE	@YWORLD,A14,L
	MOVE	*A0(010H*4 + 020H),A11,L
	SUB	A14,A11				;Y OFFSET

	JSRP	START_UNIVERSE0

;	MOVE	@SKYCOLOR,@NewAECol,L
;	MOVE	@GROUNDCOLOR,@NewGNDCol,L

	DIE


**************************************************************************
*								         *
* S_SET_VECTOR_TABLE - SET WAVE VECTOR TABLE				 *
*								         *
* 	.LONG	TABLE ADDRESS						 *
*								         *
**************************************************************************

S_SET_VECTOR_TABLE
	MOVE	*A11+,A14,L
	MOVE	A14,@WVT_PTR,L
	JRUC	SCRL_DISPATCHER

**************************************************************************
*								         *
* S_SET_BYTE								 *
* S_SET_WORD - STUFF AN ADDRESS WITH SOMETHING				 *
* S_SET_LONG								 *
*								         *
* 	.LONG	ADDRESS	TO STUFF					 *
*	FOR BYTE:						         *
*		.WORD	STUFF TO STUFF (CONTENTS)		         *
*	FOR WORD:						         *
*		.WORD	STUFF TO STUFF (CONTENTS)		         *
*	FOR LONG:						         *
*		.LONG	STUFF TO STUFF (CONTENTS)		         *
*								         *
**************************************************************************

S_SET_BYTE
	MOVE	*A11+,A0,L
	MOVE	*A11+,A14,W
	MOVB	A14,*A0
	JRUC	SCRL_DISPATCHER

S_SET_WORD
	MOVE	*A11+,A0,L
	MOVE	*A11+,A14,W
	MOVE	A14,*A0,W
	JRUC	SCRL_DISPATCHER

S_SET_LONG
	MOVE	*A11+,A0,L
	MOVE	*A11+,A14,L
	MOVE	A14,*A0,L
	JRUC	SCRL_DISPATCHER

**************************************************************************
*								         *
* 	S_OR_WORD							 *
* 									 *
* 	OR a value into WORD sized memory.				 *
* 									 *
* 	.LONG	Address of memory					 *
* 	.WORD	Value to OR						 *
*								         *
**************************************************************************
S_OR_WORD
	MOVE	*A11+,A0,L
	MOVE	*A11+,A1,W
	ORM	A1,*A0,W
	JRUC	SCRL_DISPATCHER

**************************************************************************
*								         *
* S_DEL_ALL_UNIVOBJ_WAIT - WAIT TIL ALL UNIVERSE OBJECTS DELETED	 *
*								         *
**************************************************************************

S_DEL_ALL_UNIVOBJ_WAIT
	MOVI	60,A8				;TIMEOUT TIME
	MOVI	OID_UNIV & ~MASK_SUPP,A9
SDAUW_RESTART
	MOVI	FGLIST,A1
	MOVE	A1,A0
SDAUW_LUPE
	MOVE	*A0,A0,L
	CMP	A1,A0
	JREQ	SCRL_DISPATCHER			;BR=END OF LIST, DONE
	
	MOVE	*A0(OID),A14,W
	AND	A9,A14
	JRZ	SDAUW_LUPE			;BR=NO UNIVERSE MATCH
	DEC	A8
	JRZ	SCRL_DISPATCHER			;BR=TIMEOUT! LOST OBJECTS!
	SLEEP	1
	JRUC	SDAUW_RESTART

**************************************************************************
*								         *
* S_BLACKOUT - BLACK OUT UNIVERSE					 *
*								         *
**************************************************************************

S_BLACKOUT
	CALLA	CLR_0PALS

	CLR	A14
	MOVE	A14,@IRQSKYE,W		;CLR THE AUTO-ERASE COLOR
	MOVE	A14,@IRQGNDE,W		;CLR THE AUTO-ERASE COLOR

	MOVK	1,A14
	MOVE	A14,@BLACKOUT,W
	JRUC	SCRL_DISPATCHER

**************************************************************************
*								         *
* FADING ROUTINES							 *
*								         *
**************************************************************************

**************************************************************************
*								         *
* FADING ROUTINES							 *
*								         *
**************************************************************************

S_SECRET_PALS
	MOVE	A11,A1			;FADE IN THE LIGHT SWITCH IN ONLY
	MOVI	SWITCH1p,A0
	CLR	A10
	MOVI	FadeIn,A11
	CALLA	FADE_ONLY

	CLR	A14
	MOVE	A14,@BLACKOUT,W

	MOVI	SECRET_PALETTE_TABLE,A2
SSP_LUPE
	MOVE	*A2+,A0,L
	JRZ	SSP_GO			;BR=NO MORE PALETTES
	CALLA	GETFPAL			;ALLOCATE PALETTE
	JRUC	SSP_LUPE
SSP_GO
	MOVK	1,A14
	MOVE	A14,@BLACKOUT,W
	MOVE	A14,@SCROLL_FLAG,L

	MOVE	A1,A11
	JRUC	SCRL_DISPATCHER

S_FADE_TO_BLACK
	MOVI	01000H,A9
	CREATE	PID_SKY,SKYDOWN
	MOVI	DUXNOFADE,A0		;FADE OUT ALL EXCEPT DUXNOFADE LIST
	CALLA	FADEOUT
	JRUC	SCRL_DISPATCHER

SECRET_PALETTE_TABLE
	.LONG	P_NONBOYY, GUNFIREp, GCDS_P, REXPLO, P_BLOODRD
	.LONG	ARMROT, HEDEXPLOS, CHESTROT, LEGOFF
	.LONG	0

**************************************************************************
*								         *
* S_LM_PRINTF								 *
* 	.LONG	MESSAGE MACRO						 *
*								         *
**************************************************************************

S_LM_PRINTF
	MOVE	*A11+,A8,L
	PUSHP	A11
	JSRP	LM_PRINTF
	PULLPQ	A11
	JRUC	SCRL_DISPATCHER

**************************************************************************
*								         *
* S_DELETE_TEXT								 *
*								         *
**************************************************************************

S_DELETE_TEXT
	MOVI	OID_TEXT,A0
	CALLA	KILOBJ_ALL
	JRUC	SCRL_DISPATCHER

**************************************************************************
*								         *
* S_GAME_OVER								 *
*								         *
**************************************************************************

S_GAME_OVER
	JAUC	GAME_OVER

**************************************************************************
*								         *
* S_JUMP_IF_TRUE - JUMP TO AN ADDRESS IF VAR IS NON-ZERO		 *
* 									 *
* 	.LONG	ADDRESS TO JUMP TO					 *
* 	.LONG	VAR TO CHECK						 *
*								         *
**************************************************************************

S_JUMP_IF_TRUE
	MOVE	*A11+,A0,L
	MOVE	*A11+,A14,L

	MOVB	*A14,A14
	JRZ	SCRL_DISPATCHER

	MOVE	A0,A11	
	JRUC	SCRL_DISPATCHER
  
**************************************************************************
*								         *
* S_JUMP_IF_FALSE - Jump to given address if given variable is 0.	 *
* A11 = Ptr to:								 *
* 	.LONG	Jump address						 *
* 	.LONG	Address of variable to test				 *
*								         *
**************************************************************************
S_JUMP_IF_FALSE
	move	*A11+,A0,L		;Get jump vector
	move	*A11+,A14,L		;Get address of variable

	movb	*A14,A14		;Variable = 0 ?
	jrnz	SCRL_DISPATCHER		;BR = No, continue

	move	A0,A11	
	jruc	SCRL_DISPATCHER		;Jump to new address


**************************************************************************
*								         *
* S_JUMP_IF_BIT_SET - JUMP TO AN ADDRESS IF BIT n IN VAR IS SET		 *
* 									 *
* A11 = Ptr to:								 *
* 	.LONG	ADDRESS TO JUMP TO					 *
* 	.LONG	VAR TO CHECK						 *
* 	.WORD	BIT POSITION n						 *
*								         *
**************************************************************************
S_JUMP_IF_BIT_SET
	MOVE	*A11+,A0,L		;JUMP ADDRESS
	MOVE	*A11+,A14,L		;VAR ADDRESS		
	MOVE	*A11+,A1,W		;BIT POSITION
	MOVE	*A14,A14,L		;GET CONTENTS 
	BTST	A1,A14
	JRZ	SCRL_DISPATCHER		;BR=NOT SET
	MOVE	A0,A11
	JRUC	SCRL_DISPATCHER
	
**************************************************************************
*								         *
* S_JUMP_IF_BIT_CLR - JUMP TO AN ADDRESS IF BIT n IN VAR IS CLEAR	 *
* 									 *
* A11 = Ptr to:								 *
* 	.LONG	ADDRESS TO JUMP TO					 *
* 	.LONG	VAR TO CHECK						 *
* 	.WORD	BIT POSITION n						 *
*								         *
**************************************************************************
S_JUMP_IF_BIT_CLR
	MOVE	*A11+,A0,L		;JUMP ADDRESS
	MOVE	*A11+,A14,L		;VAR ADDRESS		
	MOVE	*A11+,A1,W		;BIT POSITION
	MOVE	*A14,A14,L		;GET CONTENTS 
	BTST	A1,A14
	JRNZ	SCRL_DISPATCHER		;BR=NOT CLEAR
	MOVE	A0,A11
	JRUC	SCRL_DISPATCHER


**************************************************************************
*								         *
* S_START_UID_ANIM - START A UNIVERSE ANIMATION OF A SPECIFIC ID	 *
* 		      WITH A SPECIFIC ANIMATION				 *
* 		      ADD M_START_UID_PORTAL TO JUST START PORTAL ANIMS	 *
* 									 *
* A11 = PTR TO:								 *
* 									 *
* 	.LONG	ANIMATION						 *
* 	.WORD	NUMBER OF ANIMS TO START << 8 + ID			 *
* NOTE: TO START PORTAL ANIMATIONS ONLY!				 *
* 	.WORD	NUMBER OF ANIMS TO START << 8 + ID + M_START_UID_PORTAL	 *
*								         *
**************************************************************************

**************************************************************************
*								         *
* S_START_UID_DANIM - START A UNIVERSE ANIMATION OF A SPECIFIC ID	 *
* 		       ADD M_START_UID_PORTAL TO JUST START PORTAL ANIMS *
* 									 *
* A11 = PTR TO:								 *
* 									 *
* 	.WORD	NUMBER OF ANIMS TO START << 8 + ID			 *
* NOTE: TO START PORTAL ANIMATIONS ONLY!				 *
* 	.WORD	NUMBER OF ANIMS TO START << 8 + ID + M_START_UID_PORTAL	 *
*								         *
**************************************************************************

S_START_UID_ANIM
	MOVE	*A11+,A5,L
	JRUC	S_SUD_GO
S_START_UID_DANIM
	CLR	A5
S_SUD_GO
	MOVE	*A11+,A0,W
	MOVE	A0,A6
	MOVE	A0,A2
	SLL	16+8,A0
	SRL	16+8-2,A0
	ORI	OID_UNIV & ~MASK_SUPP,A0
	SRL	8,A2

	MOVI	FGLIST,A3
	MOVE	A3,A8
	movi	MASK_SUPP,a9	       
S_SUD_LUPE
	MOVE	*A8(OID),A14,W
	andn	a9,a14			; get rid of MASK_SUPP
	CMP	A0,A14
	JRNE	S_SUD_NEXT			;BR=NO OID MATCH
	
	MOVB	*A8(OFLAGS+B_ANIM-7),A14
	JRN	S_SUD_NEXT			;BR=IT'S ANIMATING

	MOVE	*A8(OULINK),A4,L
	MOVE	*A4(MAP_IMG),A7,L
	BTST	B_IF_SEQ,A7
	JRZ	S_SUD_NEXT			;BR=NOT A SEQUENCE
	MOVE	A6,A6
	JRNN	S_SUD_NO_PORTAL
	MOVE	*A4(MAP_FLAGS),A14,W
	BTST	B_BF_PORTAL,A14
	JRZ	S_SUD_NEXT			;BR=NOT A PORTAL
S_SUD_NO_PORTAL
	MOVE	A5,A1
	JRNZ	S_SUD_START_ANIM		;BR=ANIMATION PROVIDED
	MOVE	A7,A1
	BTST	B_IF_DAM,A1
	JRZ	S_SUD_ANIM			;BR=NO DAMAGE	
	SRL	4,A1
	SLL	4,A1
	MOVE	*A1,A1,L
S_SUD_ANIM
	ANDNI	M_IF_DANIM,A7
	MOVE	A7,*A4(MAP_IMG)

	SRL	4,A1
	SLL	4,A1
S_SUD_START_ANIM
	CALLA	STRT_ANIM

	DEC	A2
	JRZ	SCRL_DISPATCHER			;BR=START MORE
S_SUD_NEXT
	MOVE	*A8,A8,L
	CMP	A3,A8
	JRNE	S_SUD_LUPE			;BR=NOT END OF LIST
	JRUC	SCRL_DISPATCHER


**************************************************************************
*								         *
* S_KILL_ALL_PROCS - KILL ALL PROCESSES OF A GIVEN ID			 *
* 									 *
* 	.LONG	S_KILL_ALL_PROCS					 *
* A11 POINTS TO:							 *
* 	.WORD	PROCESS ID						 *
*								         *
**************************************************************************

S_KILL_ALL_PROCS
	MOVE	*A11+,A0,W
	CALLA	KILLPROC_ALL
	JRUC	SCRL_DISPATCHER
	
**************************************************************************
*
*	.long  S_AT_Z
*	.LONG	JUMP ADDRESS IF AT OR EXCEEDED Z DESTINATION
*	.long	DESTINATION Z
*	.word	0 to stop, non-zero to leave scrolling in Z
*
**************************************************************************
S_AT_Z
	MOVE	*A11+,A0,L		;JUMP ADDRESS
	MOVE	*A11+,A1,L		;DESTINATION Z
	MOVE	*A11+,A2,W		;STOP OR CONTINUE FLAG 

	MOVE	@ZBASE,A3,L

	MOVE	@ZSCROLL,A14,L
	JRN	S_AZ_REVERSE			;BR=GOIN' IN REVERSE
	CMP	A1,A3
	JRLT	SCRL_DISPATCHER
	JRUC	S_AZ_THERE
S_AZ_REVERSE
	CMP	A1,A3
	JRGT	SCRL_DISPATCHER
S_AZ_THERE
	MOVE	A0,A11
	MOVE	A2,A2
	JRNZ	SCRL_DISPATCHER
	MOVE	A2,@ZSACCEL,L
	MOVE	A2,@ZSCROLL,L
	JRUC	SCRL_DISPATCHER

**************************************************************************
*								         *
* S_CLR_SCROLL_FLAG - CLEAR SPECIFIED BITS IN SCROLL_FLAG		 *
* 									 *
* 	.LONG	S_CLR_SCROLL_FLAG					 *
* 	.LONG	BITS TO CLEAR (-1 = ALL)				 *
*								         *
**************************************************************************

S_CLR_SCROLL_FLAG
	MOVE	*A11+,A14,L		;BITS TO CLEAR
	MOVE	@SCROLL_FLAG,A0,L	
	ANDN	A14,A0
	MOVE	A0,@SCROLL_FLAG,L	
	JRUC	SCRL_DISPATCHER

**************************************************************************
*								         *
* S_SET_SCROLL_FLAG - SET SPECIFIED BITS IN SCROLL_FLAG			 *
* 									 *
* 	.LONG	S_CLR_SCROLL_FLAG					 *
* 	.LONG	BITS TO SET (-1 = ALL)					 *
*								         *
**************************************************************************

S_SET_SCROLL_FLAG
	MOVE	*A11+,A14,L		;BITS TO CLEAR
	MOVE	@SCROLL_FLAG,A0,L	
	OR	A14,A0
	MOVE	A0,@SCROLL_FLAG,L	
	JRUC	SCRL_DISPATCHER

**************************************************************************
*								         *
* S_STAGE_ZFAR_PROC - UPDATE ZFAR IN GXSTAGE3				 *
*								         *
**************************************************************************

S_STAGE_ZFAR_PROC
	MOVI	06F385H+0800H,A8	;FARTHEST Z = SPEAKER Z + ERROR
S_SZP_LUPE
	MOVE	@YBASE,A14,L
	CMPI	011C0000H,A14
	JRGE	S_SZP_DIE		;BR=WE'RE ON THE SCAFFOLD
	MOVE	@ZBASE,A0,L
	SUB	A8,A0
	NEG	A0
	move	a0,@ZFAR,L
	SLOOP	3,S_SZP_LUPE
S_SZP_DIE
	CLR	A14
	MOVE	A14,@GROUNDCOLOR,W
	MOVE	A14,@IRQGNDE,W
	MOVI	070000H,A0
	CALLA	CHANGE_ZFAR
	DIE

**************************************************************************
*								         *
* S_SET_GRND_COLOR							 *
* S_SET_SKY_COLOR  - SET THE COLOR OF THE GROUND AND SKY		 *
* 									 *
* 	.WORD	COLOR							 *
*								         *
**************************************************************************

S_SET_GRND_COLOR
	MOVE	*A11+,A14,W			;COLOUR
	MOVE	A14,@GROUNDCOLOR,W
	MOVE	A14,@IRQGNDE,W
	JRUC	SCRL_DISPATCHER

S_SET_SKY_COLOR
	MOVE	*A11+,A14,W			;COLOUR
	MOVE	A14,@SKYCOLOR,W
	MOVE	A14,@IRQSKYE,W
	JRUC	SCRL_DISPATCHER

**************************************************************************
*								         *
* 	A_CHNG_SCRL_TBL							 *
* 									 *
* 	   This animation func, lets you change the scroll table.	 *
* 	   The argument is a pointer to the new scroll table.		 *
* 									 *
* 	CHNG_SCRL_TBL							 *
* 									 *
* 	   Same as A_CHNG_SCRL_TABLE except, you provide the pointer	 *
* 	   to the new scroll table.					 *
* 									 *
* 	   A0 = Ptr to new scroll table					 *
* 									 *
* 	Example:  When you shoot one of 3 doors, it opens and sucks	 *
*                   the player inside.					 *
*								         *
**************************************************************************
A_CHNG_SCRL_TBL:
	calla	GETAFARG_LONG
*
*Entrypoint: You provide the scroll table in A0
*
CHNG_SCRL_TBL
	PUSH	A1
	move	@SCROLL_PROCESS,a1,L
	move	a0,*a1(PA11),L
	MOVIM	SCRL_DISPATCHER,*a1(PWAKE),L
	MOVKM	1,*a1(PTIME),W

	MOVE	@IN_MAKE_DECISION,A14,W	;Did we get caught during MAKE_DECISION?
	JRZ	CST_NOT_DECIDING	;BR = No
	PUSH	A0
	CLR	A14			;Well a decision has been made so...
	MOVE	A14,@IN_MAKE_DECISION,W	;Clear proper flag
	MOVE	A14,@HOLD_ENEMY_DISPATCH,W	;Clear the dispatch hold as well
	MOVI	OID_DIR,A0		;Kill all buttons
	CALLA	KILOBJ_ALL
	PULLQ	A0
CST_NOT_DECIDING						  

	move	*a1(LAST_SP),*a1(PSPTR),L	; restore stack ptr
	PULLQ	A1
	rets

S_KILL_ALT_SCROLL:
	move	*a13(ALTSCRL),a0,L
	jrz	SCRL_DISPATCHER
	calla	KILL
	CLRM	*a13(ALTSCRL),L
	jruc	SCRL_DISPATCHER

**************************************************************************
*								         *
* S_SETUP_DSJ  - SET COUNT FOR DSJ USING REGISTER A10			 *
* 									 *
* 	.WORD	COUNT							 *
*								         *
**************************************************************************

S_SETUP_DSJ
	MOVE	*A11+,A10,W			;COUNT
	JRUC	SCRL_DISPATCHER

**************************************************************************
*								         *
* S_DSJ  - DECREMENT SKIP JUMP ON REGISTER A10				 *
* 									 *
* 	.LONG	JUMP ADDRESS						 *
*								         *
**************************************************************************

S_DSJ
	MOVE	*A11+,A14,L			;COUNT
	DEC	A10
	JRZ	SCRL_DISPATCHER
	MOVE	A14,A11
	JRUC	SCRL_DISPATCHER

**************************************************************************
*								         *
* S_CALL - CALL A ROUTINE						 *
* 									 *
* 	.LONG	ROUTINE ADDRESS						 *
*								         *
**************************************************************************

S_CALL
	MOVE	*A11+,A14,L			;ROUTINE ADDRESS
	PUSHP	A11
	CALL	A14
	PULLPQ	A11
	JRUC	SCRL_DISPATCHER


**************************************************************************
*								         *
* S_DISABLE_ENEMY_GENS							 *
* 									 *
* 	This scroll function disables all enemy generators which	 *
*       are currently defined as objects				 *
*								         *
**************************************************************************
S_DISABLE_ENEMY_GENS:
	move	@RAMREF0,a4,L
	move	@RAMREF1,a5,L

	cmp	a4,a5
	jreq	SDEG_done
SDEG_lp:
	move	*a4(MAP_OBJ),a8,L	; process only ones which are objects
	jrn	SDEG_nxt	

	move	*a4(MAP_FLAGS),a14
	btst	B_BF_ENEMY,a14		; are we an enemy generator?
	jrz	SDEG_nxt
	ANDNI	M_BF_ENEMY,A14
	MOVE	A14,*A4(MAP_FLAGS),W	; clear this flag
	
	MOVE	*A4(MAP_IMG),A14,L	   ;MAKE STATIC
;	ANDNI	M_IF_DANIM|M_IF_SEQ,A14
;	MOVE	A14,*A4(MAP_IMG),L

	btst	B_IF_DAM,a14
	jrnz	yes_dam
	MOVE	*A8(OIMG),*A4(MAP_IMG),L
yes_dam:

	move	*a8(OFLAGS),a14
	btst	B_ANIM,a14
	jrz	SDEG_idle

	CALLA	PULL_ANIM		; stop animating
	JRUC	SDEG_nxt
SDEG_idle:
	MOVE	@ENEMYDATA0,A0,L
SDEG_RMV_LUPE
	MOVE	*A0+,A14,L
	.if	DEBUG
	LOCKON	Z
	.else
	JRZ	SDEG_done
	.endif
	CMP	A8,A14
	JRNE	SDEG_RMV_LUPE		;BR=NO MATCH
	move	@ENEMYDATA,a14,L
	cmp	a0,a14
	jreq	SDEG_last
	move	*-a14,*-a0,L
	addk	20h,a14
SDEG_last:
	clr	a0
	move	a0,*-a14,L
	move	a14,@ENEMYDATA,L
SDEG_nxt:
	move	*a4(MAP_NEXT),a4,L
	cmp	a4,a5
	jrne	SDEG_lp
SDEG_done:


;	movi	FGLIST,a9
;	move	*a9(OLINK),a8,L
;SDEG_lp:
;	move	*a8(OFLAGS),a14
;	btst	B_ANIM,a14		; are we animating?
;	jrz	SDEG_nxt
;	move	*a8(OID),a14
;	andi	MASK_TYPE,a14
;	cmpi	TYPE_UNIV & MASK_TYPE,a14   ; are we a universe object?
;	jrne	SDEG_nxt
;	move	*a8(OULINK),a14,L
;	move	*a14(MAP_FLAGS),a0
;	btst	B_BF_ENEMY,a0		; are we an enemy generator?
;	jrz	SDEG_nxt
;	andni	M_BF_ENEMY,a0		; if yes to all, disable enemies
;	move	a0,*a14(MAP_FLAGS)
;	btst	B_IF_DAM,a0	       
;	jrnz	SDEG_dam
;	MOVE	*A8(OIMG),*A14(MAP_IMG),L
;SDEG_dam:			       
;	calla	PULL_ANIM
;
;SDEG_nxt:
;	move	*a8(OLINK),a8,L
;	cmp	a8,a9
;	jrne	SDEG_lp

	jruc	SCRL_DISPATCHER

**************************************************************************
*								         *
* S_DOZER_ACCEL - TURN IN A CERTAIN DIRECTION					 *
* 									 *
* .WORD	TIME << 8 + COORDINATE FLAGS					 *
* 	NOTE: THE COORDINATE FLAGS SPECIFY WHICH COORDINATES TO AFFECT.	 *
* 									 *
* .LONG	COORDINATE BOUNDARY						 *
* 	NOTE: IF THE COORDINATE SPECIFIED VIOLATES THE BOUNDARY, THEN	 *
* 	      ALL ACCELERATIONS ARE CLEARED AND TARGET VELOCITIES SET.	 *
* 									 *
* .LONG	XSCROLL TARGET IF USED						 *
* .LONG	YSCROLL TARGET IF USED						 *
* .LONG	ZSCROLL TARGET IF USED						 *
* 	NOTE: A TARGET VELOCITY IS ONLY REQUIRED IF THE COORDINATE FLAG	 *
* 	      IS SET IN THE FIRST PARAMETER.				 *
*								         *
**************************************************************************

;PTARGET_VELS	EQU	PDATA
PBOUNDS_COORD	EQU	PDATA	;PDATA+020H
PTTIME		EQU	PDATA+020H

S_DOZER_ACCEL
	MOVE	*A11+,A8,W			;TIME << 8 + FLAGS
	MOVE	A8,A9				;FLAGS
	ZEXT	A8,W				;GIVE TIME RANGE 0 TO 255
	SRL	8,A8				;TIME

	MOVE	*A11+,A10,L			;BOUNDARY

;	MOVE	A11,*A13(PTARGET_VELS),L	;POINTER TO TARGET VELOCITIES

	MOVE	@WAVEIRQS,A14,L
	MOVE	A14,*A13(PTTIME),L

	MOVI	XBASE,A1

	BTST	B_X+3,A9
	JRNZ	SDA_BOUNDS_ADDR
	ADDK	020H,A1
	BTST	B_Y+3,A9
	JRNZ	SDA_BOUNDS_ADDR
	SLL	ZFRAC,A10
	BTST	B_ZREL,A9
	JRZ	SDA_GET_Z
	MOVE	@ZREL_OFF,A14,L
	ADD	A14,A10
	JRUC	SDA_GET_Z
SDA_BOUNDS_ADDR
	MOVE	A1,*A13(PBOUNDS_COORD),L
	JRUC	SDA_GET_EM
SDA_LUPE
	BTST	B_Z+3,A9
	JRZ	SDA_GET_EM
SDA_GET_Z
	MOVE	@ZBASE_HR,A2,L
	MOVE	@ZSCROLL,A1,L
	JRUC	SDA_CHECK
SDA_GET_EM
	MOVE	*A13(PBOUNDS_COORD),A1,L
	MOVE	*A1,A2,L			;BASE
	MOVE	*A1(060H),A1,L			;SCROLL
SDA_CHECK	
	ADD	A1,A2

	MOVE	A1,A1
	JRN	SDA_DEC

	CMP	A10,A2

;	JRLT	SDA_UPDATE
;	LOCKON
;	JRUC	SDA_WERE_THERE

	JRGT	SDA_WERE_THERE
	JRUC	SDA_UPDATE

SDA_DEC
	CMP	A10,A2

;	JRGT	SDA_UPDATE
;	LOCKON
;	JRUC	SDA_WERE_THERE

	JRLT	SDA_WERE_THERE

SDA_UPDATE
	CLR	A1
	MOVI	XSCROLL,A2
;	MOVE	*A13(PTARGET_VELS),A3,L
	MOVE	A11,A3
SDA_UPDATE_LUPE
	MOVE	*A3,A5,L

	BTST	A1,A9
	JRZ	SDA_NO_NO

	ADDK	020H,A3
	MOVE	*A2,A14,L
	SUB	A14,A5
	DIVS	A8,A5

	MOVE	A5,*A2(060H),L
SDA_NO_NO
	INC	A1
	ADDK	020H,A2
	CMPK	3,A1
	JRLT	SDA_UPDATE_LUPE
SDA_NAP	
	SLEEP	1

	MOVE	*A13(PTTIME),A1,L
	MOVE	@WAVEIRQS,A2,L
	MOVE	A2,*A13(PTTIME),L
	SUB	A1,A2
	SUB	A2,A8
	JRP	SDA_LUPE
SDA_WERE_THERE
	CLR	A1
	MOVI	XSCROLL,A2
;	MOVE	*A13(PTARGET_VELS),A11,L
	CLR	A4
SDA_TARGET_LUPE
	MOVE	*A11,A5,L

	BTST	A1,A9
	JRZ	SDA_NO_TARGET

	ADDK	020H,A11
	MOVE	A5,*A2,L

	MOVE	A4,*A2(060H),L
SDA_NO_TARGET
	INC	A1
	ADDK	020H,A2
	CMPK	3,A1
	JRLT	SDA_TARGET_LUPE

	JRUC	SCRL_DISPATCHER

**************************************************************************
*								         *
* S_SET_TRACK_VOLUME							 *
* 	.BYTE	CHANNEL							 *
* 	.BYTE	VOLUME (0-255)						 *
*								         *
**************************************************************************

S_SET_TRACK_VOLUME
	MOVE	*A11+,A0,W
	MOVE	A0,A1
	SLL	24,A0
	SRL	24,A0					;CHANNEL
	SLL	16,A1
	SRL	24,A1					;VOLUME
	CALLA	SET_TRACK_VOLUME
	JRUC	SCRL_DISPATCHER

**************************************************************************
*								         *
* S_SOUND0 - START SOUND SCRIPT WITH 0 VOLUME				 *
* 	.LONG	SCRIPT							 *
*								         *
**************************************************************************
	
S_SOUND0
	MOVE	*A11+,A0,L
	MOVK  1,A1
	MOVI  0FF00H,A10	
	CALLA SNDLD
	JRUC	SCRL_DISPATCHER



**************************************************************************
*
*	This scroll function is used for entering secret
*	halls in the Evergreen Chemical wave
*
**************************************************************************
SUCK_INTO_DEADEND:
*
*	Scan objects for BUGHEAD
*
	movi	FGLIST,a0
keeplking:
	move	*a0+,a0,L
	move	*a0(OID),a14		; 
	cmpi	OID_UNIV|ID_18,a14
	jrne	keeplking
;
	move	*a0(OXVAL),a10,L
	move	@YBASE,a9,L
	movi	2000h,a8	; Z destination (relative)

	clr	a14
	move	a14,@XSCROLL,L
	move	a14,@YSCROLL,L
	move	a14,@ZSCROLL,L

	movi	-40,a14		; duration of pull
	jauc	GO_TO_POINT1

**************************************************************************
*
*	This scroll function is called to return from a deadend hallway
*	in the Evergreen Chemical Wave
*
**************************************************************************
DEADEND_RETURN:
	move	@HALL_LOCKOUT,a14
	jrz	nofudge
	neg	a14			; restore
	dec	a14			; one less opportunity next time
	move	a14,@HALL_LOCKOUT	 
nofudge:
	mmfm	a12,a7,a8,a9,a10,a11
	movi	120,a14
	move	a12,*a13(LAST_SP),L
*
*	Target in a8,a9,a10   ticks in a14
*
	jauc	GO_TO_POINT1H


****************************************************************
*
*	DELETE A CLASS OF ENEMY BASED ON THEIR OIDS
*
*	.LONG	S_DELETE_ENEMY_OID
*	.word	OID to delete
*
*	handles multi as well as single parters
*
S_DELETE_ENEMY_OID:
	move	*a11+,a1		; OID to delete
	movi	FGLIST,a4
	MOVE	*A4(OLINK),A0,L
DELENM_lp:
	move	*a0(OID),a14   		; get OID
	cmp	a14,a1			; if wrong OID, keep going
	jrne	DELENM_NEXT
	move	*a0(OPART1),a14,L	; is it a multi?
	jrz	DELENM_nomult
	cmp	a0,a14			; is this the head
	jrne	DELENM_NEXT		; wait for head
	move	a0,a8
DELENM_multlp:
	move	*a0(OLINK),a0,L		; get next obj which is NOT part
	move	*a0(OPART1),a14,L	; of this multiparter
	cmp	a8,a14
	jreq	DELENM_multlp
	jruc	DELENM_hook		; do the delete
DELENM_nomult:
	move	a0,a8
	move	*a0(OLINK),a0,L		; get link to next
DELENM_hook:
	calla	DEL_ENEMY_NOAUD		; otherwise, delete
	cmp	a0,a4			; quit when wrap to beginning of list.
	jrne	DELENM_lp
DELENM_NEXT:	
	move	*a0(OLINK),a0,L		; get link to next
	cmp	a0,a4			; quit when wrap to beginning of list.
	jrne	DELENM_lp
	jauc	SCRL_DISPATCHER


******************************************************************
*								 *
*	S_BRNCH_ON_WORD_VAL					 *
*								 *
*	.LONG S_BRNCH_ON_WORD_VAL				 *
*	.long variable						 *
*	.word num (how many branch choices)			 *
*	.long BRANCH_ADDR_FOR_VARIABLE==0			 *
*	.long BRANCH_ADDR_FOR_VARIABLE==1			 *
*	.long BRANCH_ADDR_FOR_VARIABLE==2			 *
*								 *
*	.long BRANCH_ADDR_FOR_VARIABLE==num-1			 *
*								 *
******************************************************************
S_BRNCH_ON_WORD_VAL:
	move	*a11+,a0,L	; address of variable
	move	*a11+,a1	; number of choices
	move	*a0,a2		; value of variable
	inc	a2
looklp:
	move	*a11+,a5,L	; next branch point
	dec	a2
	jrz	do_branch
	dsjs	a1,looklp	; decrement choice count

	jruc	SCRL_DISPATCHER	; if you fall through
	
do_branch:
	move	a5,a11
	jruc	SCRL_DISPATCHER



**********************************************************
*				      			 *
*	S_ADD_TMPOBJ		      		 	 *
*				      			 *
*	.LONG S_ADD_TMPOBJ	      		 	 *
*	.long init_table	      			 *
*	.word xval>>4, yval>>4	      			 *
*	.long zval		      			 *
*	.word ticks til delete	      			 *
*				      			 *
**********************************************************
S_ADD_TMPOBJ:
	move	*a11+,a14,L
	move	a14,b0
	calla	EASYMAKE

	move	*a11+,a3       ; set X position
	sll	16,a3
	sra	4,a3
	move	a3,*a0(OXVAL),L
	
	move	*a11+,a3       ; set Y position
	sll	16,a3
	sra	4,a3
	move	a3,*a0(OYVAL),L
	
	move	*a11+,a3,L     ; set Z position
	move	@ZREL_OFF,a14,L
	sra	ZFRAC,a14
	add	a14,a3
	move	a3,*a0(OZVAL),L
	
	calla	INSOBJ

	move	a0,a8
	move	*a11+,a9
	CREATE	PID_IND,TIMEOUT_OBJ

	jruc	SCRL_DISPATCHER

TIMEOUT_OBJ:
	SLEEPR	a9
	calla	DELETE_OBJ
	DIE



	.end
