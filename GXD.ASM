 	.MLIB	"GXMACS.LIB"
	.FILE	"GXD.ASM"
	.TITLE	"<<< GENERATION X -- DISPLAY PROCESSOR VER. 5.0 >>>"
	.WIDTH	132
	.OPTION	B,D,L,T
	.MNOLIST

**************************************************************************
*								         *
* 	COPYRIGHT (C) 1992 MIDWAY MANUFACTURING COMPANY.		 *
* 		       ALL RIGHTS RESERVED.				 *
*								         *
**************************************************************************
NUM_SIZES	.set	3	; Full, Half and Qrtr and NOT Eighth



*
*GSP DMA OBJECT HANDLER
*VERSION 1.0 BY WARREN DAVIS 9/1/87
*VERSION 2.01 BY EUGENE JARVIS 10/25/87
*VERSION 3.0 BY EUGENE JARVIS 12/20/87
*VERSION 3.1 BY EUGENE JARVIS 7/4/88
*VERSION 3.2 BY EUGENE JARVIS 8/8/88
*VERSION 3.3 BY TODD ALLEN 3/26/89
*VERSION 4.0 BY TODD ALLEN 10/20/90
*VERSION 5.0 BY WARREN DAVIS & BILL DOZER 6/20/92
****************************************
*FILES REQUIRED FOR ASSEMBLY
	.include	"GX.INC"

***** In this file

	.if	DEBUG
	.DEF	CkOFREE
	.endif
	.DEF	INVELADD
	.DEF	OBJ_ON_WNZ_MULTI, REPOS_OBJ, GET_ANIPU, OBJ_CONST_MULTI
	.DEF	CALCULATE_HORIZON, SET_ODAG_MULTI, WORLD_GRNDOFF

***** In GXRAM.ASM

	.REF	SKIPDISP, DMACFIGCOPY

***** In GXPALL.ASM

	.REF	FREEPALCNT, FINDPAL

***** In GXC.ASM

	.ref	PULLANIMFUNC

***** In GXUNZIP.ASM
	.ref	SYNCIRQ,CLIPSND	

OLD_WAY	.set	0
;
*	GLOBAL VARIABLES
*
	.sect	"OFIXED"

;* OBJ PLANES HAVE FOLLOWING STUCTURE
;      ⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
;      ≥⁄ƒƒƒƒƒƒƒƒø⁄ƒƒƒƒƒƒƒƒƒƒø⁄ƒƒƒƒƒƒƒƒƒƒø≥
;     …ÕÀÕÕª   …ÕÀÕÕÀÕÕ   …ÕÀÕÕÀÕÕ   …ÕÀÕÕÀÕÕ
;     ∫  ∫  ∫   ∫  ∫  ∫     ∫  ∫  ∫     ∫  ∫  ∫  
;     »Õ ÕÕº   »Õ ÕÕ ÕÕ   »Õ ÕÕ ÕÕ   »Õ ÕÕ ÕÕ
;       ¿ƒƒ≈ƒƒƒƒƒƒ≈ƒƒŸ        ¿ƒƒ≈ƒƒƒƒƒƒƒƒ≈ƒƒŸ
;          ≥      ¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ        ≥
;          ¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ


L6	.MACRO			;No more L7, sorry Dozer.
	.LONG	0,0,0,0,0,0
	.word	0
	.ENDM
;P_LSTHD, P_LSTTL, P_XPOS, P_YPOS, P_XYOFF, P_XRATE, P_FLAGS
FGLIST
	L6
FGLISTX

BGLISTS
	L6
	L6
	L6
	L6
	L6
	L6
	L6
	L6
	L6
	L6
	L6
	L6
	L6
	L6
	L6
BGLISTSX

;# OF ENTRIES MUST = 2**#bits of SUPP field in OID
SUPPLSTS
	.long	0,0,0,0,0,0,0,0
	.long	0,0,0,0,0,0,0,0
	.long	0,0,0,0,0,0,0,0
	.long	0,0,0,0,0,0,0,0
SUPPLSTSX

OFREE		.long	0	;LIST OF FREE OBJECTS
ENDOFREE	.long	0	;PTR TO LAST OBJ ON FREE LIST
ANIOBJS		.long	0	;LIST OF OBJECTS for ANIM PROCESS
	.BSS	ANIFUNCS,040h*NOBJ+020h,1 ;list of ANIM FUNCTIONS TO BE CALLED
					;+020h for list terminating 0
	.BSS	ANIFUNCSX,0
	.def	ANIFUNCSX


	.IF DEBUG
	.def	CLIPTIM,VELTIM,SCALETIM,PROCTIM
	.ENDIF
*
	.IF DEBUG
	.bss	CLIPTIM,16 		; % of screen time for clip loop
	.bss	VELTIM,16		; % of screen time for vel loop
	.bss	SCALETIM,16		; % of screen time for scale
	.bss	PROCTIM,16		; % of screen time for processes
	.ENDIF
	.bss	DMATMP,16		; VLINE at which DMA is done for frame
	.bss	DMALFT,16		; % of DMA TIME left (0-1000)
	.bss	DMAAVG,16		; Average % DMA TIME left
	.bss	HORIZON,16		; VLINE separating sky from ground.
	.BSS	HORIZON_BASE,16		; INITIAL VALUE OF ABOVE LOCATION
	.BSS	SRT_HORIZON,16		; VERSION USED BY SRT_CLR ONLY
	.BSS	BGPLANECT,16		;# of bgnd planes
	.BSS	OFREECNT,16		;# objects on free list  
	.BSS	SCRNTL,32		;TOP LEFT [Y,X] SCREEN (SCRN COORD.)
	.BSS	SCRNBR,32		;LOWER RIGHT [Y,X] SCREEN (SCRN COORD.)
  	.BSS	OBJSTR,NOBJ*OBSIZ	;OBJECT SPACE START
	.BSS	OBJSTRX,0		;OBJECT SPACE END
	.BSS	DMAQCUR,32		;CURRENT DMAQ

QSIZE	.SET	NOBJ*BQCELL		;SIZE OF A QUEUE

	.BSS	DMAQ,QSIZE		;MISC. NON-SYNC DMA QUEUE
	.BSS	QDMAFLG,16		;SPECIAL DMAQ BEING UPDATED=1
	.BSS	DISPLAYON,16		;DO DISPLAY PROCESSING WHEN != 0
  	.BSS	DMAIQSTR,(5*NOBJ)*6*020h	;SPACE TO STORE DMAINT Q
	.BSS	DMAIQBOT,0		;
  	.BSS	DMAIQSTR2,(5*NOBJ)*6*020h	;SPACE TO STORE DMAINT Q
	.BSS	DMAIQBOT2,0		;
  	.BSS	DMAIQACT,32		;ACTIVE DMA Q

	.BSS	XBASE,32		;BASE POSITIONS
	.BSS	YBASE,32
	.BSS	ZBASE,32
	.BSS	XSCROLL,32		;SCROLL VELOCITIES
	.BSS	YSCROLL,32
	.BSS	ZSCROLL,32
	.BSS	XSACCEL,32		;SCROLL ACCELERATIONS
	.BSS	YSACCEL,32
	.BSS	ZSACCEL,32
	.BSS	YWORLD,32		;GROUND PLANE WORLD Y	
	.BSS	ZFAR,32			;FARTHEST Z POSITION ON SCREEN
;	.BSS	ZFARU,32		;FARTHEST Z UNIVERSE POSITION
	.BSS	ZCLOSE,32		;CLOSEST Z POSITION ON SCREEN
	.BSS	ZBASE_HR,32		;hi res version of ZBASE
	.BSS	YHALF,16		;HALF Y VALUE FOR TRANSLATION

	.BSS	WORLD_GRNDOFF,32	;Added in ground coll and Shadows

	.BSS	INVELADD,16		;we're VELADDing or we just did
*LOCAL VARS

	.text

**************************************************************************
CLRDMAQ
	;*** GET STUFF READY FOR DMAINTS ***
	PUSHST
	DINT
	movi	DMAREGS,B11
	movi	DMAIQBOT2,B13	;DMAQTL Assume Q2
	MOVE	@DMAIQACT,B12,L	;DMAQHD
	CMPI	DMAIQBOT,B12
	JRHI	DIS_THE_INT
	movi	DMAIQBOT,B13	;DMAQTL
DIS_THE_INT
	setf	1,0,0
	clr	B14
	move	B14,@(INTENB+B_X1E),0	;disable interrupt no that we're done
	POPST
	rets
**************************************************************************


**************************************************************************
*								         *
*  DISPLAY								 *
* 									 *
* 	DO MANUAL DMAs							 *
* 	PLOT ROAD							 *
*  	ADD VELOCITIES, GRAVITY						 *
* 	DISPLAY THE FOREGROUND & BACKGROUND PLANES			 *
* 									 *
* 	CALLED AT END OF SCREEN INTERRUPT				 *
* 									 *
* NOTE: IT IS ASSUMED THAT THE DMA IS STOPPED UPON ENTRY		 *
* 									 *
* DOUBLE NOTE: A14 IS USED THROUGHOUT THIS ROUTINE AS SCREEN TOP/LEFT,	 *
* 		THEREFORE, DO NOT USE MACROS THAT TRASH A14!!		 *
*								         *
**************************************************************************
DISPLAY:
	MOVE	@DISPLAYON,A0,W
	JREQ	DISPX	;BR = STOP ALL NEW DISPLAY PROCESSING

	callr	CLRDMAQ		

	;DELETED CALL TO SET_DAM_WINDOW

;	MOVE	@PAUSE_GAME,A14,W	;ARE WE IN PAUSE MODE?
;	JRNZ	SkSCROLL

	;ADJUST WORLD COORS FOR SCROLL
;	move	@SCROLLX,A14,L
;	move	@WORLDX,A1,L
;	add	A14,A1
;	move	A1,@WORLDX,L

;	move	@WORLDY,A0,L
;	srl	16,A1
;	movx	A1,A0
;	move	A0,@WORLDXY,L

;	callr	BgScroll	;update P_XPOS for backplanes
;SkSCROLL
	MOVE	@SCRNTL,A14,L	;GET SCREEN BOUNDARIES
	MOVE	@SCRNBR,A13,L	;THESE MUST STAY VALID FROM HERE THRU CLIP

	movi	DMAGOREG,B1

*
* Dump the MANUAL DMA Queue.  The DMA clip window will be opened all of
* the way.  Therefore these DMAs do not heed the normal	object world
* constraints.
*
	MOVE	@QDMAFLG,A2		;Q BEING MODIFIED?
	JRNE	DISPMANX		;YES, DON'T SCREW WITH IT
	MOVE	@DMAQCUR,A8,L
	MOVI	DMAQ+QSIZE,A1
	CMP	A1,A8			;ANYTHING IN THE QUEUE?
	JREQ	DISPMANX		;NONE
	MOVE	A1,@DMAQCUR,L		;RESET TOP OF QUEUE

	MOVI	[2*SCRHGHT,0],A2
 	MOVE	A2,@DMAWINDOW,L		;FULL HEIGHT WINDOW
 
 	MOVE	@DMACFIGCOPY,A2,L	; XUNIT
 	ANDNI	DMAWIN,A2
 	MOVE	A2,@DMACONFIG,L		; XUNIT CONFIGURE DMA TO ADJUST WINDOW WIDTH
 
 	.if	CENTER_SCREEN

	MOVI	[511,SCRLFT],A0

	.else

	MOVI	[SCRRGT,SCRLFT],A0

	.endif

	MOVE	A0,@DMAWINDOW,L		;FULL WIDTH
	ORI	DMAWIN,A2
;	MOVE	A2,@DMACFIGCOPY,L	; XUNIT
	MOVE	A2,@DMACONFIG,L		; XUNIT LEAVE CONFIG'D FOR TOP/BOT ADJUSTMENT

DMANLP:

	subi	32*6,A1

	move	A1,A0
	mmfm	A0,A9,A6,A5,A4,A3,A2

	movi	DMAREGS,A7

	;*** WAIT FOR DMA NOT BUSY ***

DMAWT1:	MOVE	*B1,B14,L	;DMA BUSY?
	JRN	DMAWT1		;BR = YES

	;STUFF DMA REGS
	mmtm	A7,A2,A3,A4,A5,A6,A9
				;A2  Y-SCALE:X-SCALE
				;A3  CONST:PALETTE
				;A4  Y-SIZE:X-SIZE
				;A5  DAG
				;A6  SAG
				;A9 CONTROL:OFFSET

DMAWT2:	MOVE	*B1,B14,L	;DMA BUSY?
	JRN	DMAWT2		;BR = YES

	CMP	A8,A1		;HAVE WE EMPTIED THE QUEUE?
	JRHI	DMANLP		;BR = NO, LET'S DO SOME MORE

DISPMANX:

	move	@NO_MIRROR,B5,W		;Are we mirroring
	jrz	SetMir			;BR = Yes
	movi	DCLIP_NOMIRROR,B5	;Clip routine for no mirror
	jruc	MirDun
SetMir
	movi	DCLIP_MIRROR,B5		;Clip routine for mirror
MirDun
*Note: B5 must stay valid from here through PutPlanes

*SET THE DMA WINDOW FOR OBJECT CLIPPING
	MOVE	A14,A0			;GET THE SCREEN WINDOW TOP
	SRL	16,A0			;POSITION IT PROPERLY
	MOVY	A13,A0			;GET THE SCREEN WINDOW BOTTOM Y
	move	@PAGE,A7,W
	jrz	DISP_DMA_WIN
	ADDI	[SCRHGHT,SCRHGHT],A0
DISP_DMA_WIN
	MOVE	A0,@DMAWINDOW,L		;SET WORLD HEIGHT

	MOVE	A13,A0
	SLL	16,A0
	MOVX	A14,A0			;Get the screen [Right,Left] values

	.if	CENTER_SCREEN

;	ADDXYI	[CENTER_XSHIFT,CENTER_XSHIFT],A0
	ADDXYI	[CENTER_XSHIFT+8,CENTER_XSHIFT-8],A0 ;Must buffer, so we don't see DMA
					;clipping bug. This only works when
					;Bitmap is centered
	.endif

	MOVE	@DMACFIGCOPY,A7,L
	ANDNI	DMAWIN,A7
	MOVE	A7,@DMACONFIG,L		;CONFIGURE DMA TO ADJUST WINDOW WIDTH
	MOVE	A0,@DMAWINDOW,L		;FULL WIDTH
 
	ORI	DMAWIN,A7
	MOVE	A7,@DMACONFIG,L		;LEAVE CONFIG'D FOR TOP/BOT ADJUSTMENT

	MOVE	@SKIPDISP,A0,W		;IS THE DISPLAY TURNED OFF?
	jrnz	CHK_SYNCSND		; was DISPX	;BR = YES

;BREGS USED IN DISPLAY LOOP
;B0 YMINTBL pointer
;B1 DMAGOREG
;B2 immediate val DMAREGS
;B3 non-zero to set new window
;B4 WORLDTL-in disp loop
;B5 MIRROR/NOMIRROR JUMP
;B6 is NOW USED for scale mama processing check
;B7 FGND PLANE TBL INDEX
;B8 BGND PLANE TBL INDEX
;B9 SCRATCH
;B10 SCREEN_WIDTH-1, used in DCLIP loop for MIRROR
;B11,B12,B13 ALWAYS USED FOR DMA INTERRUPT
;B14 SCRATCH

;AREGS FOR DISPLAY LOOP
*A0 CURRENT OBJ
*A1<-OFFSET
*A2<-AMOUNT TO CLIP OFF BOTTOM, RIGHT	(BC,RC)
*A3<-AMOUNT TO CLIP OFF TOP, LEFT	(TC,LC)
*A4 LIST START
*A5 Page Offset
*A6<-SCREEN TOP LEFT (SCREEN COORDINATES); THEN TOTAL HORIZ. SIZE
*A7=scratch register
*A8 M_FLIPH (used to set flags for mirror)
*A9<- VS : HS
*A10<- DAG (Y : X)
*A11<- SAG
*A12<- control word b0-15; offset b16-31
*A13 ENTERS AS the window BOTTOM RT
*A14 ENTERS AS the window TOP LEFT

***	MOVE	@SCRNTL,A14,L		;GET SCREEN BOUNDARIES 
***	MOVE	@SCRNBR,A13,L				       

;	MOVE	@ROADPAL,A7,W
;	JRZ	NO_ROAD1	;CHECK IF ROAD SHOULD BE PAVED
;	CALLA	START_ROAD	;YEAH! PAVE THE MOTHER!
;NO_ROAD1	

	;movi	M_FLIPH,A8	;I TOOK DIS OUT

	move	@PAGEADDR,A5,L

	movi	DMAREGS,B2

	callr	PrePutPlanes

****	move	@NO_MIRROR,B5,W
****	jrnz	SetNoMir
****	movi	DCLIP_MIRROR,B5
****	jruc	MirSet
****SetNoMir
****	movi	DCLIP_NOMIRROR,B5
****MirSet

	movi	SCREEN_WIDTH-1,B10	; for DCLIP_MIRROR

	calla	PutPlanes

DISPX:

	CALLR	VELADD			;VELOCITY UPDATE OF FOREGROUND OBJS


;	MOVE	@ROADPAL,A2,W
;	JRZ	NO_ROAD2	;CHECK IF ROAD SHOULD BE PAVED
;	CALLA	DO_ROAD		;FOR NEXT DISPLAY CALL
;	RETS
;NO_ROAD2
	move	@GAMERASE,A0,W	; negative indicates horizon method
	JRNN	D_NO_HORIZON
	CALLR	CALCULATE_HORIZON
D_NO_HORIZON
	RETS



*		   If the display system is turned off,
*		   check to see if a movie clip wants 
*		   to make a sound call
*
CHK_SYNCSND:
	move	@SYNCIRQ,a14
	jrz	DISPX		; not waiting
	move	@WAVEIRQS,a8
	cmp	a8,a14		; did we reach desired spot?
	jrgt	DISPX		; no
	move	@CLIPSND,a0,L
	calla	ONESND
	clr	a14
	move	a14,@SYNCIRQ	; clear it
	jruc	DISPX

**************************************************************************
*								         *
* 	BgScroll							 *
* 									 *
* 	Update all of the infinity planes' positions.			 *
* 									 *
* 	X is based on the current UNIVX position. (not implemented)	 *
* 	Y is based off of the HORIZON line.				 *
*								         *
**************************************************************************
BgScroll:
	movi	BGLISTS,A0
	move	@BGPLANECT,A1,W		;Get the current plane count
	jrz	ScrollPlnX		;BR = there are no infinity planes

	MOVE	@HORIZON,A14,W
	MOVE	@HORIZON_BASE,A13,W
	SUB	A14,A13
	SLL	16,A13			;Update the horizon offset

	MOVE	@XSCROLL,A14,L
ScrollLp
	;*** UPDATE SCROLL POSITION OF FGND PLANE ***
	MOVE	*A0(P_XRATE),A2,L	;plane X scroll multiplier
	JRZ	BGS_SKIP_XSCROLL
	MPYS	A14,A2			;64 bit mpy, result -> A2:A3
	SLL	16,A2			;16.16 * 16.16 -> 32.32, want 16.16
	SRL	16,A3
	MOVX	A3,A2
	MOVE	*A0(P_XPOS),A3,L	;old X position
	ADD	A2,A3
	MOVE	A3,*A0(P_XPOS),L	;new accumulated X value

BGS_SKIP_XSCROLL
	;*** Update Y position of plane
	move	A13,*A0(P_YPOS),L	;New horizon based Y position

	addi	PLNSIZ,A0
	dsjs	A1,ScrollLp
ScrollPlnX
	rets

**************************************************************************
PrePutPlanes:
;Set up B9 as index into BGLISTS

	move	@BGPLANECT,B14,W		;# of bgnd planes
	movi	PLNSIZ,B9
	mpyu	B14,B9
	addi	BGLISTS-PLNSIZ,B9
	move	B9,B8
;	calla	SET_FIRST_HILL		; set up first hill

	rets

**************************************************************************
*								         *
* INIT_HORIZON - INITIALIZE THE HORIZON LINE THIS WAVE.			 *
*								         *
**************************************************************************
INIT_HORIZON:
	clr	a0
	dec	a0
	move	a0,@GAMERASE	; negative indicates horizon method
	CALLR	CALCULATE_HORIZON
	CALLR	CALCULATE_HORIZON_BASE
	rets

**************************************************************************
*								         *
* CALCULATE_HORIZON - CALCULATE THE CURRENT HORIZON LINE, BASED		 *
* 			ON THE CURRENT STATE OF THE WORLD.		 *
* RETURNS:								 *
* 	A1 = CURRENT HORIZON						 *
* NOTE: TRASHES A0							 *
*								         *
**************************************************************************
CHANGE_ZFAR:
	move	a0,@ZFAR,L	;  (must be WORLD referenced!)
	
	MOVK	1,A14			;FORCE UNIVERSE UPDATE
	MOVE	A14,@UNIVERR,W

	jruc	CALC_HORZ_FROM_Z
CALCULATE_HORIZON
	MOVE	@ZFAR,A0,L
CALC_HORZ_FROM_Z:
	MOVE	@YWORLD,A1,L
	MOVE	@YBASE,A14,L
	ADD	A14,A1
	divs	a0,a1
	MOVE	@YHALF,A14,W
	ADD	A14,A1
;	srl	1,a1
;	sll	1,a1		; HORIZON MUST BE EVEN (for SRT_CLR)
	move	a1,@HORIZON,W	;THE REAL DEAL
	srl	1,a1
	sll	1,a1		; HORIZON MUST BE EVEN (for SRT_CLR)
	CMPI	0FEH,A1
	JRLE	IH_OK
	MOVI	0FEH,A1	
IH_OK
	MOVE	A1,@SRT_HORIZON,W	;SPECIAL CROPPED VERSION FOR SRT_CLEAR
	RETS



**************************************************************************
*								         *
* CALCULATE_HORIZON_BASE - CALCULATE THE CURRENT HORIZON BASE LINE, BASE *
* 			ON THE INTIAL STATE OF THE WORLD.		 *
* RETURNS:								 *
* 	A1 = HORIZON BASE						 *
* NOTE: TRASHES A0							 *
*								         *
**************************************************************************
CALCULATE_HORIZON_BASE
	MOVE	@YWORLD,A1,L
	MOVE	@ZFAR,A0,L
	divs	a0,a1
	MOVE	@YHALF,A14,W
	ADD	A14,A1
	move	a1,@HORIZON_BASE,W	;THE REAL DEAL
	RETS


**************************************************************************
*								         *
* VELOCITY ADD AND SCREEN BOUNDARY CHECK				 *
* 									 *
* 	a0  = Obj Block							 *
* 	a1  = ZFAR (univ)						 *
* 	a2  = End of Obj List						 *
* 	a3  = scratch							 *
* 	a4  = SCRATCH							 *
* 	a5  = XBASE							 *
* 	a6  = M_OFSCRN (const)						 *
* 	a7  = Multi part obj block					 *
* 	a8  = ZPOS							 *
* 	a9  = YPOS							 *
* 	a10 = XPOS							 *
* 	a11 = YVEL							 *
* 	a12 = XVEL							 *
* 	a13 = ZVEL							 *
* 	a14 = OFLAGS							 *
*								         *
* 	B0  = PRIMARY X LEFT SHIFT VALUE FOR UNIVERSE CHECK		 *
* 	B1  = PRIMARY Y LEFT SHIFT VALUE FOR UNIVERSE CHECK		 *
* 	B2  = SCRATCH							 *
* 	B3  = ZMAX_REAL2 (UNIVERSE)					 *
* 	B4  = ZMAX_KLUDGE (UNIVERSE)					 *
* 	b5  =   avail							 *
* 	B6  = SCRATCH							 *
* 	B7  = SECONDARY X LEFT SHIFT VALUE FOR UNIVERSE CHECK		 *
* 	B8  = SECONDARY Y LEFT SHIFT VALUE FOR UNIVERSE CHECK		 *
* 	B9  = YBASE							 *
* 	B14 = SCRATCH							 *
*								         *
**************************************************************************
VELADD:
 	MOVE	@PAUSE_GAME,A14,W	;ARE WE IN PAUSE MODE?
	JRNZ	VADDX

	MOVK	1,A14
	MOVE	A14,@INVELADD,W		;we're VELADDing

	INCM	@WAVEVEL,W		; tell the world we been here

	MOVE	@YBASE,B9,L

	MOVE	@ZFAR,A1,L
	MOVI	FGLIST,A0
	move	a0,a2
;	move	@ZSCROLL,b5,L
	move	@ZBASE,a4,L
	add	a4,a1
	MOVE	A4,B3
	MOVE	A4,B4
	ADDI	ZMAX_REAL2,B3
	ADDI	ZMAX_KLUDGE,B4
	move	@XBASE,a5,L
	movi	M_OFSCRN,a6
	jruc	VADD

	.align

;***** OBJECT VELOCITY ADD LOOP *****
DVEL
	move	*A0(OPART1),A3,L	; Is this a multi parter?
	jrz	SkMultiV		; jump if no

	cmp	A3,A0		;HEAD OBJ?
	jrne	VADD		;If No, go to next object

	;*** MULTI PART OBJ ***
	move	A3,A7
	ADDI	OZVEL,A3	;add in OZVEL
	MMFM	A3,A11,A12,A13	;LOAD A13:OZVEL, A12:OXVEL, A11:0YVEL

; 	MOVE	*A0(OFLAGS),A14,W
;	BTST	B_SCRNOBJ,A14
;	JRNZ	MultiVLp
;	
;	MOVE	B5,A3
;	sub	A3,A13			; Use ZSCROLL as ZVEL
MultiVLp
	move	A7,A3		;get obj base in A3 for pull of vals
	MOVE	*A7(OFLAGS),A14,W

	addi	OXVAL,A3
	MMFM	A3,A8,A9,A10	;LOAD A10:OXPOS, A9:OYPOS, A8:OZPOS
	andn	a6,a14		; Assume onscreen

	BTST	B_SCRNOBJ,A14
	JRNZ	zokM

	MOVE	B4,A4
	BTST	B_DBLSCL,A14
	JRZ	VAM_NODUB	;BR=NOT DOUBLE SCALE
	MOVE	B3,A4
VAM_NODUB
	ADD	A13,A8		;ADD Z VELOCITY TO ZVAL
	cmp	a4,a8		; Don't allow ZVAL to get too low
	jrlt	mrkoffM
	cmp	A1,a8		;COMPARE AGAINST ZFAR
	jrle	zokM
mrkoffM:
	or	a6,a14		; Mark as offscreen
zokM:
	ADD	A12,A10		;ADD X VELOCITY TO XVAL
	btst	B_SHAD,a14	; Shadows don't use Y vel
	jrnz	SkYVAdd1
	ADD	A11,A9		;ADD Y VELOCITY TO YVAL
SkYVAdd1
	MMTM	A3,A8,A9,A10

	BTST	B_SCRNOBJ,A14
	JRZ	NOT_SCRNOBJ_MULTI
	SRL	16,A10
	MOVY	A9,A10
	MOVE	A10,*A7(ODAG),L
NOT_SCRNOBJ_MULTI
*
*	removed off screen check from here... WARREN 1/7/94
*
	move	a14,*a7(OFLAGS)
NOFLAGS_SCRNOBJ
* Check to see if we got out of order
	MOVE	A13,A13
	JRZ	VAM_NO_ZMOTION		;BR = We did not move in Z
	JRP	VAM_ZPLUS
	
	MOVE	*A7(OBLINK),A14,L
	CMP	A2,A14
	JREQ	VAM_NO_ZMOTION

	MOVE	*A14(OZVAL),A14,L
	CMP	A14,A8
	JRGE	VAM_NO_ZMOTION		;BR = Still in line
	JRUC	VAM_SET_NOT_SORTED

VAM_ZPLUS
	MOVE	*A7,A14,L
	CMP	A2,A14
	JREQ	VAM_NO_ZMOTION
	MOVE	*A14(OZVAL),A14,L
	CMP	A14,A8
	JRLE	VAM_NO_ZMOTION		;BR = Still in line
VAM_SET_NOT_SORTED
	MOVE	A6,*A7(ONOT_SORTED),W
VAM_NO_ZMOTION
	move	*A7(OPARTS),A7,L
	jrnz	MultiVLp

	jruc	CkGrav_multi

SkMultiV:
*LOAD A13:OZVEL, A12:OXVEL, A11:0YVEL, A10:OXPOS, A9:OYPOS, A8:OZPOS
	move	A0,A3			;get obj base in A3 for pull of vals
	ADDI	OZVEL,A3		;ADD IN OZVEL

	MOVE	*A0(OFLAGS),A14,W
	andn	a6,a14		; Assume onscreen first 

	MMFM	A3,A8,A9,A10,A11,A12,A13

	BTST	B_SCRNOBJ,A14
	JRNZ	zok

	MOVE	B4,A4
	BTST	B_DBLSCL,A14
	JRZ	VA_NODUB	;BR=NOT DOUBLE SCALE
	MOVE	B3,A4
VA_NODUB
	ADD	A13,A8		;ADD Z VELOCITY TO ZVAL
	cmp	a4,a8		; Don't allow ZVAL to get too low
	jrlt	mrkoff
	cmp	A1,a8		;COMPARE AGAINST ZFAR
	jrle	zok
mrkoff:
	or	a6,a14		; Mark as offscreen
zok:
	ADD	A12,A10		;ADD X VELOCITY TO XVAL
	btst	B_SHAD,a14	; Shadows don't use Y vel
	jrnz	SkYVAdd0
	ADD	A11,A9		;ADD Y VELOCITY TO YVAL
SkYVAdd0
	MMTM	A3,A8,A9,A10

	BTST	B_SCRNOBJ,A14
	JRZ	NOT_SCRNOBJ
	SRL	16,A10
	MOVY	A9,A10
	MOVE	A10,*A0(ODAG),L
NOT_SCRNOBJ
*
*	removed off screen check from here... WARREN 1/7/94
*
	move	a14,*a0(OFLAGS)

* Check to see if we got out of order
	MOVE	A13,A13
	JRZ	VAS_NO_ZMOTION		;BR = We did not move in Z
	JRP	VAS_ZPLUS
	
	MOVE	*A0(OBLINK),A14,L
	CMP	A2,A14
	JREQ	VAS_NO_ZMOTION

	MOVE	*A14(OZVAL),A14,L
	CMP	A14,A8
	JRGE	VAS_NO_ZMOTION		;BR = Still in line
	JRUC	VAS_SET_NOT_SORTED

VAS_ZPLUS
	MOVE	*A0,A14,L
	CMP	A2,A14
	JREQ	VAS_NO_ZMOTION
	MOVE	*A14(OZVAL),A14,L
	CMP	A14,A8
	JRLE	VAS_NO_ZMOTION		;BR = Still in line
VAS_SET_NOT_SORTED
	MOVE	A6,*A0(ONOT_SORTED),W
VAS_NO_ZMOTION

CkGrav_multi
	move	*A0(OYACCEL),A3,W
	jrz	SkGrav
	add	A3,A11
	move	A11,*A0(OYVEL),L
SkGrav

VADD:
	move  	*A0,A0,L     	;GET NEXT ONE FOLKS
	cmp	A0,A2
	JRNE  	DVEL
*
*UPDATE SCROLL VALUES
*
	MOVI	XSCROLL,A7
	MMFM	A7,A4,A5,A6		;GET SCROLL VELOCITIES
	MOVI	XBASE,A14

	MMFM	A14,A2,A3	    	;GET BASE POSITIONS
	addk	32,a14		    
	move	@ZBASE_HR,a1,L	 	
	ADD	A4,A1			;UPDATE Z BASE
	move	a1,@ZBASE_HR,L	   
	sra	ZFRAC,a1     	   	; convert Z to lores
	ADD	A6,A3			;UPDATE X BASE
	ADD	A5,A2			;UPDATE Y BASE
	JRNN	D_YOK			;BR=NOT GOING UNDER GROUND
	CLR	A2			;RESET TO GROUND
D_YOK
	MMTM	A14,A1,A2,A3		;STORE BASE POSTIONS
	MOVI	XSACCEL,A14
	MMFM	A14,A1,A2,A3		;GET SCROLL ACCELERATIONS
	ADD	A1,A4			;UPDATE Z SCROLL
	ADD	A2,A5			;UPDATE Y SCROLL
	ADD	A3,A6			;UPDATE X SCROLL
	MMTM	A7,A4,A5,A6		;STORE SCROLL VELOCITIES

	callr	BgScroll		;Update positions for Infinity planes
VADDX
	RETS

	.text

**************************************************************************
*								         *
* INFINITY_PLANES - COMPUTE DAGs FOR ALL OF THE INFINITY OBJECTS	 *
* 		BASED ON THEIR PLANES CURRENT POSITION. ALSO HANDLES	 *
* 		THE HORIZON LINE OFFSET FOR US.				 *
* 									 *
* REGISTER USAGE:							 *
* 	A0 = OBJECT PTR							 *
* 	A4 = PLANE POINTER						 *
* 	A5 = BECOMES ODAG FOR EACH OBJECT				 *
* 	A6 = [Y,X] WORLD OFFSET						 *
* 	A14 = SCRATCH							 *
* 									 *
* 	B9 = PLANE COUNTER						 *
*								         *
**************************************************************************
INFINITY_PLANES
	MOVI	BGLISTS,A4
	MOVE	@BGPLANECT,B9,W		;GET THE NUMBER OF PLANES
	JRZ	IP_X			;BR = NONE, LET'S BOOK
;	MOVE	@HORIZON,A14,W
;	MOVE	@HORIZON_BASE,A7,W
;	SUB	A14,A7
;	SLL	16,A7			;ADD THIS HORIZON OFFSET TO EVERYTHING
	.ALIGN
IP_PLNLP
	move	*A4(P_YPOS),A6,L
	move	*A4(P_XPOS),A14,L
	srl	16,A14
	movx	A14,A6			;B4 = WORLD TOP LEFT [Y,X]
	move	*A4(P_XYOFF),A14,L

	addxy	A14,A6
;	ADDXY	A7,A6
	MOVE	A4,A0			;LIST TO PROCESS
	JRUC	IP_NEXT
IP_DOOBJ
	move	*A0(OYPOS),A5,W
	sll	16,A5
	move   	*A0(OXPOS),A14,W
	movx	A14,A5			;COMBINED WORLD COORDS
	subxy	A6,A5			;NOW ADJUST TO SCREEN
	MOVE	A5,*A0(ODAG),L		;STUFF THE NEW DAG
IP_NEXT
	MOVE	*A0,A0,L		;GET NEXT LINK
	CMP	A0,A4
	JRNE	IP_DOOBJ		;DONE?
	move	B8,A0			;Get Obj List Head
	ADDI	PLNSIZ,A4
	DSJ	B9,IP_PLNLP
IP_X
	RETS

**************************************************************************
*								         *
* SCALE_MAMA - compute scale factor algorithmically	, then Scrn Pos  *
*								         *
**************************************************************************
*
*	a0 = obj
*	a1 = scratch
*	a2 = new YSCALE
*	a3 = 10000h for inverse scale computation
*		B3 = OZVAL
*	a4 = start of FGLIST
*	a5 = SCRN TL	
*		B5 = OYVAL
*	a6 = new XSCALE
*	a7 = 
*		B7 = OXVAL
*		B8 = XBASE
*	a8 = OFLAGS
* 	a9 = scratch, then ODAG
*		B10 = YBASE
*	a10 = IHOFF change limit
*	a11 = scratch 
* 	a12 = Scrn BR	
*	a13 = inverse scale
*		B14 = ZBASE
*	a14 = IHDRSIZ	
	  
LIMIT1	.set	01C0h	; IHOFF grow limit


SCALE_MAMA:
	MOVI	FGLIST,A0		
	MOVE	A0,A4
	movi	LIMIT1,a10		; Change to next half size
	movi	IHDRSIZ,a14	
	movi	10000h,a3		; for inverse scale computation
	movi	OXVAL,B0
	movi	ZMAX,B2		; index base for ROADX and ROADY tables
	movi	HALFX,B4
	MOVE	@YHALF,B6,W
	move	@XBASE,b8,L	
	move	@YBASE,b10,L	
	move	@ZBASE,b14,L	
	MOVE	@SCRNTL,A5,L	;GET SCREEN BOUNDARIES
	MOVE	@SCRNBR,A12,L	; FOR OFSCRN COMPUTATION in COMP_SCRN_POS
	JRUC	SCL_NXT_OBJ
	.align
SCALE_LP
	MOVE	*A0(OFLAGS),A8,W

	btst	B_OFSCRN,a8	; if OFSCRN, do not scale or compute DEST
	jrnz	SCL_NXT_OBJ
	BTST	B_SCRNOBJ,A8
	JRNZ	SCL_NXT_OBJ
	move	A0,B1		;get obj base in b1 for pull of vals
	add	B0,B1		; offset by OXVAL
	MMFM	B1,B3,B5,B7	;LOAD B7:OXPOS, B5:OYPOS, B3:OZPOS
;	.if	DEBUG
;	LOCKON	N
;	.endif
	sub	b14,b3		; convert to world

	MOVE	*A0(OSCALEX),A7	 ; previous X scale in a7 

	BTST	B_NOSCALE,A8
	JRNZ	KEEP_OLD_SCALE

	BTST	B_MANSCALE,A8
	JRZ	SkpSclLod

	ORI	M_NOSCALE,a8	; reset rescale signal
	move	a8,*a0(OFLAGS)
	move	*a0(ONuManScl),a6
	clr	a7		; force new scale
	jruc	ManScaleSt
	
SkpSclLod:	
	move	B3,a6		; save ZPOS for DAG computation
	sra	Z2SCALE,a6 	; compute scale factor
	BTST	B_DBLSCL,A8
	JRZ	ManScaleSt
	srl	1,a6		; double the scale if DBLSCL set
*
*	Compute and Set IHOFF
*
ManScaleSt:			
	movk	NUM_SIZES-1,a1	; Full, Half, qrtr or eighth
	clr	a11   		; assume no new IHOFF at first
ihoflp:
	cmp	a10,a6		;
	jrlt	ihoff_fnd
	add	a14,a11		; IHOFF points to next img
	srl	1,a6		; adjust scale accordingly
	dsjs	a1,ihoflp

ihoff_fnd:
	move	*a0(OIHOFF),a1	; see if it has changed
	cmp	a1,a11
	jreq	ChkNxtScl
*
*	Set New IHOFF
*
	move	a11,*a0(OIHOFF)	; switch to smaller image
	move	*a0(OIMG),a9,L
	add	a11,a9

	addi	ISIZE,a9
	mmfm	a9,a1,a2,a11	; ISIZE in a11, ISAG in a2, IANIOFF in a1

	move	A11,*A0(OSIZE),L
	MOVE	A11,*A0(OUSIZE),L
	move	a2,*A0(OSAG),L
	MOVE	A1,*A0(OANIOFF),L
	MOVE	A1,*A0(OUANIOFF),L

ChkNxtScl:
	cmp	a6,a7		 ; new X scale in a6
	JRNE	DO_NEW_SCALE
KEEP_OLD_SCALE
	MOVE	*A0(OSIZE),a9,L
	MOVE	*A0(OANIOFF),a1,L
	JRUC	COMP_SCRN_POS

DO_NEW_SCALE
	MOVE	A6,*A0(OSCALEX)
	MOVE	A6,*A0(OSCALEY)

	MOVE	*A0(OUSIZE),A9,L	;Unscaled size in a1
	MOVE	*A0(OUANIOFF),A1,L	;Unscaled animation pnt in A1

	move	a3,a13			;10000h 
	divu	a6,a13	  		;Inverse of scale in a13

	BTST	B_SHAD,A8    	;Is this a shadow object?
	JRZ	NORMAL_SCALE 	;BR = No, then do normal calculation

	move	a3,a7			;10000h
	sll	SLL_SHADOW,a6		;Shrink it another 75% in Y
	MOVE	A6,*A0(OSCALEY),W	;Need to make sure this changes
	divu	a6,a7			;Inverse of Y scale in A7

	setf	12,1,1			;change FS1 to quicken multiplies
	clr	a11
	movx	A9,a11
	mpyu	A13,A11			;Scale the X size, result in A11
	srl	8,a11
	srl	8,A9
	mpyu	a7,A9			;Scale the Y size, result in A1
	movx	a11,A9			;Recombine sizes for storage

	move	A1,A11
	sext	a11
	mpys	A13,A11			;Scale the X animation pnt
	sra	8,a11
	sra	16,A1
	mpys	a7,A1			;Scale the Y animation pnt
	JRUC 	NORMAL_SCALE_FINISH

NORMAL_SCALE
	setf	12,1,1		; change FS1 to quicken multiplies
	clr	a11
	movx	A9,a11
	mpyu	A13,A11		  ; result in a11
	srl	8,a11
	srl	8,A9
	mpyu	a13,A9
	movx	a11,A9

	move	A1,A11
	sext	a11
	mpys	A13,A11		  ; result in a11
	sra	8,a11
	sra	16,A1
	mpys	a13,A1
NORMAL_SCALE_FINISH
	sll	8,A1
	movx	a11,A1
	setf	32,0,1		; restore FS1	 !!!
	MOVE	A1,*A0(OANIOFF),L
	MOVE	A9,*A0(OSIZE),L
nochg:

;	ANIOFF is in A1
;	SIZE is in a9

COMP_SCRN_POS:	   		; Compute Screen Position

	sub	B8,B7	       	; Universe to World X  
	add	B10,B5	       	; Universe to World Y  

	DIVS	B3,B5		;TRANSLATE 3-D WORLD IN SCRN COORDINATES
	ADD	B6,B5		; add YHALF
	MOVE	B5,B9
	SLL	16,B9	
	DIVS	B3,B7
	ADD	B4,B7		; add HALFX
	MOVX	B7,B9

;	ANIOFF is in A1
;	SIZE is in a9
;
;BIG NOTE: On 10/6/93 A slight change was made that requires
;		A1 to be ANIOFF and A9 to be OSIZE at this point.
;		This eliminates the need for the following two
;		lines.  If the road version of COMP_SCRN_POS is
;		re-instated it should be changed such that it does
;		not trash A1 and A9.
;
;	MOVE	*A0(OSIZE),a9,L
;	MOVE	*A0(OANIOFF),a1,L

	subi	10001h,a9
	move	a9,a7		; save for ofscrn check  12/22/93
	subxy	a1,a9		; adjusted anioff in a9

	move	*a0(OCTRL),a6
	btst	B_FLIPH,a6
	jrz	noh
	movx	a9,a1
noh:

	btst	B_FLIPV,a6
	jrz	nov
	movy	a9,a1
nov:
	move	b9,a9
	subxy	a1,a9

	move	a9,*a0(ODAG),L		; save DAG for Clipping computation
	CMPXY	A12,A9			; IS IT LOWER THAN LOWER RT?
	JRYGE	offs			; LOWER
	JRXGE	offs			; TO THE RIGHT
	addxy	a9,a7			; get lower right of obj in a7
	CMPXY	A5,A7
	JRYLE	offs			;ABOVE...
	JRXLE	offs			;TO THE LEFT..

SCL_NXT_OBJ:
	MOVE	*a0,a0,L		; save a word MOVE *A0(OLINK),A0,L
	CMP	A0,A4
	JRNE	SCALE_LP

	RETS

offs:
	ori	M_OFSCRN,a8
	move	a8,*a0(OFLAGS)

	MOVE	*a0,a0,L		; save a word MOVE *A0(OLINK),A0,L
	CMP	A0,A4
	JRNE	SCALE_LP

	RETS


**************************************************************************
*								         *
* SET_ODAG - SET THE ODAG FIELD						 *
* 									 *
* PASS:									 *
* A8 = OBJECT								 *
*								         *
**************************************************************************

SET_ODAG
	MMTM	SP,A0,A1,A2,A3,A4,A5

	MOVE	A8,A14
	ADDI	OXVAL,A14
	MMFM	A14,A0,A1,A3	;LOAD A3:OXPOS, A1:OYPOS, A0:OZPOS

	MOVI	XBASE,A14
	MMFM	A14,A2,A4,A5	;LOAD A5:XBASE, A4:YBASE, A2:ZBASE

	sub	A5,A3	       	; Universe to World X  
	add	A4,A1	       	; Universe to World Y  
	sub	A2,A0		; convert to world

	DIVS	A0,A1		;TRANSLATE 3-D WORLD IN SCRN COORDINATES
	MOVE	@YHALF,A14,W 
	ADD	A14,A1		; add YHALF
	MOVE	A1,A2
	SLL	16,A2	
	DIVS	A0,A3
	ADDI	HALFX,A3	; add HALFX
	MOVX	A3,A2

;	ANIOFF is in A1
;	SIZE is in a4

	MOVE	*A8(OSIZE),a4,L
	MOVE	*A8(OANIOFF),a1,L
	subi	10001h,a4
	subxy	a1,a4		; adjusted anioff in a4

	move	*a8(OCTRL),a5
	btst	B_FLIPH,a5
	jrz	SO_noh
	movx	a4,a1
SO_noh:

	btst	B_FLIPV,a5
	jrz	SO_nov
	movy	a4,a1
SO_nov:
	subxy	a1,a2

	move	a2,*a8(ODAG),L	; save DAG for Clipping computation

	MMFM	SP,A0,A1,A2,A3,A4,A5

	RETS

**************************************************************************
*								         *
* SET_ODAG_MULT - SET THE ODAG FIELD FOR AN ENTIRE MULTI-PARTER		 *
* 									 *
* PASS:									 *
* A8 = OBJECT								 *
*								         *
**************************************************************************

SET_ODAG_MULTI
	MMTM	SP,A0,A1,A2,A3,A4,A5,A8

	CALLA	GET_HEAD_PART
SOM_PART_LUPE
	MOVE	A8,A14
	ADDI	OXVAL,A14
	MMFM	A14,A0,A1,A3	;LOAD A3:OXPOS, A1:OYPOS, A0:OZPOS

	MOVI	XBASE,A14
	MMFM	A14,A2,A4,A5	;LOAD A5:XBASE, A4:YBASE, A2:ZBASE

	sub	A5,A3	       	; Universe to World X  
	add	A4,A1	       	; Universe to World Y  
	sub	A2,A0		; convert to world

	DIVS	A0,A1		;TRANSLATE 3-D WORLD IN SCRN COORDINATES
	MOVE	@YHALF,A14,W 
	ADD	A14,A1		; add YHALF
	MOVE	A1,A2
	SLL	16,A2	
	DIVS	A0,A3
	ADDI	HALFX,A3	; add HALFX
	MOVX	A3,A2

;	ANIOFF is in A1
;	SIZE is in a4

	MOVE	*A8(OSIZE),a4,L
	MOVE	*A8(OANIOFF),a1,L
	subi	10001h,a4
	subxy	a1,a4		; adjusted anioff in a4

	move	*a8(OCTRL),a5
	btst	B_FLIPH,a5
	jrz	SOM_noh
	movx	a4,a1
SOM_noh:

	btst	B_FLIPV,a5
	jrz	SOM_nov
	movy	a4,a1
SOM_nov:
	subxy	a1,a2

	move	a2,*a8(ODAG),L	; save DAG for Clipping computation

	MOVE	*A8(OPARTS),A8,L
	JRNZ	SOM_PART_LUPE		;BR=NO MORE PARTS

	MMFM	SP,A0,A1,A2,A3,A4,A5,A8

	RETS

**************************************************************************
*								         *
* REPOS_OBJ - REPOSITION AN EXISTING OBJECT IN THE UNIVERSE		 *
* 									 *
* PASS:									 *
* A1 = NEW UNIVERSE Z OF HEAD						 *
* A2 = NEW UNIVERSE Y OF HEAD						 *
* A3 = NEW UNIVERSE X OF HEAD						 *
* A8 = OBJECT (HEAD OR PART)						 *
*								         *
**************************************************************************
REPOS_OBJ
	MMTM	SP,A1,A2,A3,A4,A5,A6,A8
	CALLA	GET_HEAD_PART		;NICE HEAD!
	MOVE	A8,A14
	ADDI	OXVAL,A14
	MMFM	A14,A4,A5,A6		;A6=OXVAL, A5=OYVAL, A4=OZVAL
	MMTM	A14,A1,A2,A3					
	SUB	A1,A4			;Z DELTA				
	SUB	A2,A5			;Y DELTA
	SUB	A3,A6			;X DELTA
	JRUC	RO_NXT

RO_PART_LUPE

	MOVE	*A8(OFLAGS),A14,W
	BTST	B_SHAD,A14		;Is this a shadow object?
	JRZ	RO_NOSHAD		;BR = No, do it normally

	MOVE	*A8(OXVAL),A14,L
	SUB	A6,A14
	MOVE	A14,*A8(OXVAL),L

	MOVE	*A8(OZVAL),A14,L
	SUB	A4,A14
	MOVE	A14,*A8(OZVAL),L

	MOVE	*A8(OPARTS),A8,L
	JRNZ	RO_PART_LUPE		;BR = Got another to do
	JRUC	RO_DONE			;Jump out on done

RO_NOSHAD
	MOVE	A8,A14
	ADDI	OXVAL,A14
	MMFM	A14,A1,A2,A3		;A3=OXVAL, A2=OYVAL, A1=OZVAL
	SUB	A4,A1			;SUBTRACT Z DELTA
	SUB	A5,A2			;SUBTRACT Y DELTA
	SUB	A6,A3			;SUBTRACT Z DELTA
	MMTM	A14,A1,A2,A3		;A3=OXVAL, A2=OYVAL, A1=OZVAL

RO_NXT
	MOVE	*A8(OPARTS),A8,L
	JRNZ	RO_PART_LUPE		;BR = Got another to do

RO_DONE
	MMFM	SP,A1,A2,A3,A4,A5,A6,A8
	RETS

**************************************************************************
*								         *
* SET_SCALEZ - SCALE AN OBJECT DEPENDING ON IT'S Z, BUT DON'T SWITCH IMGS*
* SET_SCALEM - SCALE AN OBJECT, BUT DON'T SWITCH IMAGES			 *
* IN: A1, DA SCALE (ONLY FOR SET_SCALEM)			         *
* OUT: NUTIN'							         *
*								         *
**************************************************************************
SET_SCALEZ
	PUSH	A1
	MOVE	*A8(OZVAL),A1,L
	move	@ZBASE,a14,L			;CONVERT Z TO SCALE
	sub	a14,a1
	SRA	Z2SCALE,A1
	MOVE	A1,A14
	SLL	16,A1
	ADD	A14,A1
	CALLR	SET_SCALEM
	PULLQ	A1
	RETS
SET_SCALEM
	MMTM	SP,A2,A3,A4,A5,A8
	CLR	A2
	MOVX	A1,A2	; XSCALE in A2
	MOVE	A1,A3
	SRL	16,A3	; YSCALE IN A3
SET_PARTM
	MOVE	A1,*A8(OSCALE),L
	MOVE	*A8(OUSIZEX),A5,W
	SLL	8,A5
	clr	a4
	DIVU	A2,A4
	MOVE	A4,*A8(OSIZEX),W
	MOVE	*A8(OUANIOFFX),A5,W
	SLL	8,A5
	clr	a4
	divs	A2,A4
	MOVE	A4,*A8(OANIOFFX),W
	MOVE	*A8(OUSIZEY),A5,W
	SLL	8,A5
	clr	a4
	divu	A3,A4
	MOVE	A4,*A8(OSIZEY),W
	MOVE	*A8(OUANIOFFY),A5,W
	SLL	8,A5
	clr	a4
	divs	A3,A4
	MOVE	A4,*A8(OANIOFFY),W
	MOVE	*A8(OPARTS),A8,L
	JRNZ	SET_PARTM
	MMFM	SP,A2,A3,A4,A5,A8
	RETS


; NEW
*
*	a0 = obj
*	a14 = new IHOFF (0 or IHDRSIZ)
*
SwitchScaledImg:
	PUSH	A1
	move	a14,*a0(OIHOFF)	; switch to smaller image
	move	*a0(OIMG),a1,L
	add	a14,a1
	
	move	*A1(ISIZE),A14,L	
	MOVE	A14,*A0(OUSIZE),L
	move	*A1(ISAG),*A0(OSAG),L
	move	*A1(IANIOFF),A14,L
	move	A14,*A0(OUANIOFF),L
;	move	*a0(OFLAGS),a14
;	ori	M_OFSCRN,a14
;	move	a14,*a0(OFLAGS)
;	movi	2000h,a1
;	move	a1,*a0(ODAG),L		; place offscreen
	PULL	A1
	rets

**************************************************************************
*								         *
* 	SET_SCALE_WARREN						 *
* 									 *
* 	Scale an object (including switching images).			 *
* 	Handles multi or single parters					 *
*								         *
**************************************************************************
SET_SCALE_WARREN
	MMTM	SP,A0,A2,A3,A4,A5
	MOVE	A8,A0
SCALE_PART_LUPE
	MOVE	*A0(OZVAL),A5,L
	move	@ZBASE,a14,L
	sub	a14,a5
	sra	Z2SCALE,a5		; assume normal size image
;Bill start 11/12/1993
	MOVE	*A0(OFLAGS),A14,W
	BTST	B_DBLSCL,A14
	JRZ	SSW_IHOFF
	srl	1,a5			; double the scale if DBLSCL set
SSW_IHOFF
;Bill end 11/12/1993
*
*	Compute and Set IHOFF
*
	movk	NUM_SIZES-1,a2	; Full, Half, qrtr or eighth
	clr	a14   		; assume no new IHOFF at first
SSihoflp:
	cmpi	LIMIT1,a5		;
	jrlt	got_ihoff
	addi	IHDRSIZ,a14	; IHOFF points to next img
	srl	1,a5		; adjust scale accordingly
	dsjs	a2,SSihoflp
got_ihoff:
	move	*a0(OIHOFF),a4	; see if it has changed
	cmp	a4,a14
	jreq	noadj
	calla	SwitchScaledImg
noadj:  
	move	a5,a2	    ; turn scale into a long word
	sll	16,a2
	movx	a5,a2

	move	a2,*a0(OSCALE),L
	zext	a2
	move	*a0(OUSIZE),a3,L
	movx	a3,a5		; we know upper half of a5 is clear
	sll	8,a5		; X size in a5
	divu	a2,a5
	srl	16,a3		
	sll	8,a3		; Y size in a3
	divu	a2,a3
	sll	16,a3
	movy	a3,a5
	move	a5,*a0(OSIZE),L

	move	*a0(OUANIOFF),a3,L
	movx	a3,a5
	sext	a5
	sll	8,a5		; X ani off in a5
	divs	a2,a5
	sra	16,a3		
	sll	8,a3		; Y ani off in a3
	divs	a2,a3
	sll	16,a3
	movy	a3,a5
	move	a5,*a0(OANIOFF),L

	MOVE	*A0(OPARTS),A0,L
	JRNZ	SCALE_PART_LUPE	    	;BR=YES THIS IS A MULTIPARTER
	MMFM	SP,A0,A2,A3,A4,A5
	RETS


**************************************************************************
*								         *
* SET_SCALE_MANUAL							 *
*	Just like SET_SCALE_WARREN, but					 *
*	Instead of computing scale based on Z, you supply the scale      *
*	SCALE FACTOR in a5     						 *
*								         *
*       This routine stores OSCALE, sets and stores IHOFF and		 *
*	   sets the RESCALE FLAG					 *
*								         *
**************************************************************************

SET_SCALE_MANUAL: 

	move	*a8(OFLAGS),a14
	btst	B_SCRNOBJ,a14
	jrz	new_way

	MMTM	SP,A0,a1,A3,A4,A9
	MOVE	A8,A0

SSM_lkfrst:
	move	*a0(OFLAGS),a14
	btst	B_MANSCALE,a14
	jrnz	SSM_dofirst
	move	*a0(OPARTS),a0,L
	jrz	SSM_X
	jruc	SSM_lkfrst


SSM_dofirst:
*
*	Compute and Set IHOFF
*
	movk	NUM_SIZES-1,a14	; Full, Half, qrtr or eighth
	clr	a3   		; assume no new IHOFF at first
SSihoflpm:
	cmpi	LIMIT1,a5		;
	jrlt	got_ihoffm
	addi	IHDRSIZ,a3	; IHOFF points to next img
	srl	1,a5		; adjust scale accordingly
	dsjs	a14,SSihoflpm
got_ihoffm:
	move	*a0(OIHOFF),a1	; see if it has changed
	cmp	a1,a3
	jreq	noadjm
	move	a3,a14
	calla	SwitchScaledImg
noadjm:  
	movi	10000h,a3 		;10000h 
	divu	a5,a3	  		;Inverse of scale in a3
	move	a3,a4

SSM_multlpSO:
	move	*a0(OFLAGS),a14
	btst	B_MANSCALE,a14
	jrz	SSM_nxtSO

	move	a5,*a0(OSCALEX)
	move	a5,*a0(OSCALEY)

	MOVE	*A0(OUSIZE),A9,L	;Unscaled size in a9
	MOVE	*A0(OUANIOFF),A1,L	;Unscaled animation pnt in A1

	setf	12,1,1		; change FS1 to quicken multiplies
	clr	a3
	movx	A9,a3
	mpyu	A4,A3		  ; result in a3
	srl	8,a3
	srl	8,A9
	mpyu	a4,A9
	movx	a3,A9

	move	A1,A3
	sext	a3
	mpys	A4,A3		  ; result in a3
	sra	8,a3
	sra	16,A1
	mpys	a4,A1

	sll	8,A1
	movx	a3,A1
	setf	32,0,1		; restore FS1	 !!!
	MOVE	A1,*A0(OANIOFF),L
	MOVE	A9,*A0(OSIZE),L

SSM_nxtSO:
	MOVE	*A0(OPARTS),A0,L
	JRNZ	SSM_multlpSO    	;BR=YES THIS IS A MULTIPARTER
SSM_X
	MMFM	SP,A0,A1,A3,A4,A9
	RETS

new_way:
	PUSH	A7
	MOVE	*a8(OPART1),A7,L
	jrnz	SSM_multlp
	move	a8,a7
SSM_multlp:
	move	*a7(OFLAGS),a14
	btst	B_MANSCALE,a14
	jrz	SSM_nxt

	move	a5,*a7(ONuManScl)	; new manual scale

	andni	M_NOSCALE,a14		; force rescaling
	move	a14,*a7(OFLAGS)
SSM_nxt:
	MOVE	*A7(OPARTS),A7,L
	JRNZ	SSM_multlp    	;BR=YES THIS IS A MULTIPARTER

	PULLQ	A7
	RETS



;STBL:
;	.word	0B3H, 016EH, 0C7H, 0149H, 0DEH, 0127H, 0100H, 0100H
;	.word	0126H, 0DEH, 0149H, 0C7H, 016EH, 0B3H, 0196H, 0A1H
;	.word	01BAH, 094H, 01E5H, 087H, 0210H, 07CH, 0238H, 073H
;	.word	0266H, 06AH, 028FH, 064H, 02BDH, 05DH, 02F2H, 056H
;	.word	031AH, 052H, 0347H, 04EH, 0379H, 049H, 03B1H, 045H
;	.word	03F1H, 040H, 0415H, 03EH, 0463H, 03AH, 048FH, 038H
;	.word	04BFH, 035H, 052AH, 031H, 0567H, 02FH, 05ABH, 02DH
;	.word	05F5H, 02AH, 0647H, 028H, 0647H, 028H, 06A2H, 026H
;	.word	0709H, 024H, 077CH, 022H, 0800H, 020H


**************************************************************************
*								         *
* SET THE DAM DMA WINDOW ALREADY! 					 *
*								         *
**************************************************************************

SET_DAM_WINDOW

	MOVE	@DMAGOREG,A0,L	;DMA BUSY?
	JRN	SET_DAM_WINDOW

	MOVE	@(SCRNBR+16),B14,W	; bottom in b14
	SLL	16,B14
	MOVE	@(SCRNTL+16),B9,W	; top in b9
	MOVX	B9,B14			; bottom:top in b14
	move	@PAGE,B5,W
	jrz	SETWIN			;BR=NO THIS IS PAGE ONE
	ADDI	[SCRHGHT,SCRHGHT],B14
SETWIN	
	MOVE	b14,@DMAWINDOW,L
	RETS



OB_GUNV     .set    0
OB_COLL     .set    1
OB_ANIM     .set    2
OB_CFUNC    .set    3
OB_POS      .set    4
OB_WPOS     .set    5
OB_SPOS     .set    6
OB_GRND     .set    7
OB_OID      .set    8
OB_DUMCOLL  .set    9
OB_PRVANIM  .set   10
OB_INSERT   .set   11
OB_OPARTS   .set   12
OB_PRVGUNV  .set   13

****************************************************************************
*    The  "NEW"  MULTIMAKE
*
*    Uses a Create Script to allocate and initialize obj(s)
*
*    B0 = ptr to Create Script w/ following format
*
*        .byte OBJCNT, PRCCNT, IMGPALCNT, PALCNT
*             PRCCNT must be >= # of procs that will be allocated in CFUNCS
*     FOR each IMGPALCNT...
*        .long IMG->PAL        ;PAL TO BE FOUND OR HAVE AVAILABLE SLOT FOR
*     FOR each PALCNT...
*        .long PAL                ;PAL TO BE FOUND OR HAVE AVAILABLE SLOT FOR
*        .word OID, GLOBAL_OPTIONS (OM_COLL | OM_DUMCOLL,
*                                   OM_POS | OM_SPOS | OM_WPOS, OM_GRND
*                                   OM_INSERT )
*
*                   OM_COLL  to supply a default coll vector for all objects.
*                                otherwise, 0 is used.)
*                   OM_POS  if you want to supply a position (universe default). 
*                   OM_WPOS  if the supplied position is world.			 
*                  [OM_GRND  if you want the supplied world Y to be offset	 
*                                    from YWORLD]					 
*                   OM_SPOS  if the supplied position is screen.		 
*                                     OM_SPOS takes priority.
*                   OM_DUMCOLL to use DUMCOLL as the default collision vector.
*                   OM_INSERT  to call INSERT_OBJ when completed
*        
*     FOR each OBJCNT...
*        .long IMG
*        .word OCTRL, OFLAGS, OZOFF
*        .word OPTIONS 
*               (OM_OID, OM_OPARTS, OM_COLL, OM_GUNV, OM_ANIM,
*                OM_PRVANIM, OM_PRVGUNV, OM_CFUNC)
*
*                OM_OID requires a word to follow the option word.
*		 OM_OPARTS requires 2 words to follow (OPARTSX and Y)
*                OM_COLL, OM_GUNV, OM_ANIM, OM_CFUNC require a long word
*                         to follow the option word.
*                OM_PRVANIM requires that a previous object had OM_ANIM set.
*                OM_PRVGUNV requires that a previous GUN vect had OM_GUNV set.
*
*        NOTE:  DATA WHICH FOLLOWS THE OPTION WORD MUST APPEAR IN THE CORRECT
*               ORDER! (namely, OID, COLL, GUNV, ANIM, xPOS, CFUNC) 
*
* MULTIMAKE automatically links all objs together as multi-parter w/
* 1st obj as head obj
*
* A10-A11 passed to each PROC created unless they are modified by CFUNCS
*
* RETURNS
*   A8 = ptr to head obj of uninserted multi-parter.
*   Immediately follow with INSERT_OBJ to insert.
*   Zflag set if not enough OBJS, PROCS or PALS
* !!!!!!!!  assume ALL B REGS TRASHED  !!!!!!!!!
*
*
* CFUNC - Create Functions
*   A0 = new obj , initialized and linked into MULTI-PARTER
*   A8 = ptr to first obj of script (head of MULTI-PARTER)
*   B0 = ptr to Create Script, must adjust B0 as CFUNC parms read.
*   Can trash all A regs but A7,A8,A9,A10,A11,A12,A13
*		(and a2 if PRVGUNV is set)
*   Must preserve ALL BREGS except B14 and B0 which must point
*                 after CFUNC parms
*		 
MULTIMAKE:
	mmtm	sp,a2,a4,a6,a7,A9,a10,a11  
	clr	A8			;First Obj

	;*** CHECK OBJCNT
	movb	*B0,B7			;B7 # objs to allocate
	move	b7,a6
	move	@OFREECNT,a14,W
	cmp	a14,a6
	jrgt	MAKEX
	addk	8,B0

	;*** CHECK PRCCNT
	movb	*B0,B1			;B1 >= # of procs to allocate
	move	@PFREECNT,B2,W
	cmp	B2,B1
	jrgt	MAKEX
	addk	8,B0

	move	@FREEPALCNT,B3,W
	;FOR EACH PAL NOT FOUND, DEC FREEPALCNT - JRN MAKEX
	movb	*B0,B1			;IMGPALCNT
	addk	8,B0
	movb	*B0,B2			;PALCNT
	addk	8,B0

	inc	B1
ImgPalLp
	dec	B1
	jrle	SkImgPalCk
	move	*B0+,B4,L
	move	B4,A0
	move	*A0(ICMAP),A0,L
	calla	FINDPAL
	jrnz	ImgPalLp
	;*** PAL NOT FOUND ***
	dec	B3
	jrn	MAKEX
	jruc	ImgPalLp
SkImgPalCk

	inc	B2
PalLp
	dec	B2
	jrle	SkPalCk
	move	*B0+,B4,L
	move	B4,A0
	calla	FINDPAL
	jrnz	PalLp
	;*** PAL NOT FOUND ***
	dec	B3
	jrn	MAKEX
	jruc	PalLp
SkPalCk
	move	*B0+,B14,W		;Load OID
	move	b14,a11			; default OID
*
*	Process Options for All Parts of Multiparter (OID, COLL, POS)
*
	move	@ZBASE,b8,L
	clr	b10		; default collision vector
	move	*b0+,b2		; options for all objects
	btst	OB_DUMCOLL,b2
	jrz	NxtGopt1X
	movi	DUMCOLL,b10
	jruc	NxtGopt1
NxtGopt1X:
	btst	OB_COLL,b2
	jrz	NxtGopt1
	move	*b0+,b10,L	; user-supplied default collision vector
NxtGopt1:
	btst	OB_POS,b2	
	jrz	NxtGopt2
	btst	OB_SPOS,b2	
	jrz	world_or_uni
	mmfm	b0,b4,b5	; b5 contains screen XY, b4 contains world Z
	jruc	NxtGopt2
world_or_uni:	
	mmfm	b0,b4,b5,b6	; position (flag determines screen, world or univ)
	btst	OB_WPOS,b2	; universe if WPOS not set
	jrz	NxtGopt2a
	add	b8,b4
	move	@YBASE,b14,L
	sub	b14,b5
	move	@XBASE,b14,L
	add	b14,b6
NxtGopt2a:			; Allow Grnd offset on UNIV pos
	btst	OB_GRND,b2
	jrz	NxtGopt2	; reference Y to ground?
	MOVE	@WORLD_GRNDOFF,B14,L
	ADD	B14,B5
	move	@YWORLD,b14,L
	add	b14,b5
NxtGopt2:			; KEEP FLAGS IN B2 DURING OBJECT CREATION

	;THERE IS ENOUGH OBJS, PROCS AND PALS SO GO AHEAD AND ALLOCATE
	clr	a7		;OBJECT #
	clr	a2		; previous gunvector
MkObjLp
	inc	a7
	move	*B0+,B1,L
	move	B1,A1
	callr	GETOBJ
	callr	FPSTFOBJ0
	move	A0,B1
	movb	a7,*A0(OPARTID)		;store # of PART
      
	move	*B0+,B14,W		;Load OCTRL
	MOVE	*B0+,B9,W		;Load OFLAGS
	MOVE	B9,*B1(OFLAGS),W
	btst	B_FLIPH,B14
	jrnz	MkFlp
	btst	B_FLIPV,B14
	jrz	SkMkFlp
MkFlp
	move	B14,A4
	PUSH	A8
	move	A0,A8
	;A1 still set from above
	calla	ANI
	PULLQ	A8
	jruc	MkFlagsOk
SkMkFlp
	move	*B1(OCTRL),B3,W
	OR	B14,B3
	move	B3,*B1(OCTRL),W
MkFlagsOk
	clr	b3			; assume no OPARTSXY

	MOVE	*B0+,B14,W		; Load OZOFF
	MOVB	B14,*B1(OZOFF)
	sll	16,b14
	movy	b14,b2

	move	A8,A8			; is first obj in a0?
	jrnz	SkMkFirst		; jump if no
*
*	First part only (b9 = OFLAGS, b2 = GBL OPTION flgs)
*
	btst	OB_SPOS,b2
	jrz	noposadj
	btst	B_SCRNOBJ,b9	; translate from screen to univ if
	jrnz	onlyZadj	; NOT a screen object
	clr	b3
	movx	b5,b3
	TOWORLDX  b4,b3
	move	b3,b6
	move	@XBASE,b14,L
	add	b14,b6		; UNIV X in b6
	sra	16,b5
	move	@YHALF,b14	; TOWORLDY
	sub	b14,b5		; TOWORLDY
	mpys	b4,b5		; TOWORLDY
	move	@YBASE,b14,L
	sub	b14,b5		; UNIV Y in b5
onlyZadj:
	add	b8,b4
noposadj:	
	move	A0,A8
	jruc	SkINSPART
SkMkFirst
****	callr	INSPART
	MOVE	A0,*A9(OPARTS),L	;LINK NEW OBJECT AT END
SkINSPART
	MOVE	A8,*A0(OPART1),L	;VALIDATE HEAD PTR
	MOVE	A0,A9			;KEEP PREVIOUS PART FOR PART LINKUP
*
*	Process Optional parameters
*
	move	*b0+,b7		; option flags

	move	a11,a14
	btst	OB_OID,b7 		; check for:  SUPPLIED OID
	jrz	NxtOpt6			; jump if default
	move	*b0+,b14		; if not default
	move	b14,a14			 
NxtOpt6:
	move	a14,*a0(OID)

	clr	b3			 
	btst	OB_OPARTS,b7
	jrz	NxtOpt7
	move	*b0+,b3,L
	move	b3,*b1(OPARTSXY),L
NxtOpt7:
	move	b10,b14 	    	 
	btst	OB_COLL,b7		; check for:  COLLISION VECTOR
	jrz	NxtOpt2			; jump if default
	move	*b0+,b14,L		; if not default
NxtOpt2:
	move	b14,*b1(OCVECT),L

	clr	b14			;    	
	btst	OB_PRVGUNV,b7		;     check for:  USE PREVIOUS ANIMATION
	jrz	no_prev_gunv		;    
	move	a2,b14			;    
	jruc	NxtOpt1			;    
no_prev_gunv:
	btst	OB_GUNV,b7  		; check for:  GUNVECTOR
	jrz	NxtOpt1
	move	*b0+,b14,L
	move	b14,a2			;    
NxtOpt1:				;      switched with below
	move	b14,*b1(OGUNVECT),L	;      switched with above

	btst	OB_PRVANIM,b7		; check for:  USE PREVIOUS ANIMATION
	jrnz	prev_anim
	btst	OB_ANIM,b7		; check for:  SUPPLIED ANIMATION
	jrz	NxtOpt3
	move	*b0+,b14,L
	move	b14,a10
prev_anim:
	move	a10,a1
	callr	STRTANIM
NxtOpt3:

	btst	OB_POS,b2 		; was a position supplied?
	jrz	NxtOpt4
*
*	adjust position based on OPARTSXY (b3) and OZOFF (MSW b2)
*
	btst	OB_SPOS,b2		; set only if a screen object
	jrz	pos_is_uni		; coords are universe
	btst	B_SCRNOBJ,b9	; skip following if not screen obj
	jrz	pos_is_uni	
	addxy	b5,b3			; Y:X in b3
	move	b3,b6	
	move	*b1(OANIOFF),b14,L
	subxy	b14,b6
	move	b6,*b1(ODAG),L
;    
;       Future note:
;       The following should save the animation point adjusted by OPARTSXY
;       (b5) as the position of a screen obj, NOT THE DAG (b6)!	
;    
	move	b6,*b1(OXPOS),W
	srl	16,b6
	move	b6,*b1(OYPOS),W
	jruc	do_z
	
pos_is_uni:
	move	b3,b14	
	jrz	oparts_is_0
	btst	B_NOSCALE,b9		; OPARTSXY will need adjustment
	jrz	nodoadj			; if the NOSCALE bit is set
***	SCALE OPARTSXY
***	b4 = Z
***	b3 = OPARTSXY
	sub	b8,b4		; back to world
	cmpi	8000h,b4
	jrz	nodoadj		; skip multiplies in this case
	sext	b3		; OPARTSX in b3
	mpys	b4,b3		; multiply by Z
	add	b6,b3
	move	b3,*b1(OXVAL),L
	move	b14,b3		; OPARTSY in b3
	sra	16,b3
	mpys	b4,b3
	add	b5,b3
	move	b3,*b1(OYVAL),L
	add	b8,b4
	jruc	do_z

oparts_is_0:
	move	b6,*b1(OXVAL),L
	move	b5,*b1(OYVAL),L
	jruc	do_z

nodoadj:
	movx	b3,b14			; OPARTS X
	sext	b14
	sll	15,b14
	add	b6,b14			; adjust X by OPARTSX
	move	b14,*b1(OXVAL),L
	move	b3,b14
	sra	16,b14			; OPARTS Y
	sll	15,b14
	add	b5,b14			; adjust Y by OPARTSY
	move	b14,*b1(OYVAL),L
do_z:
	movy	b2,b14
	sra	16,b14			; OZOFF
	add	b4,b14			; adjust Z by ZOFF	
	move	b14,*b1(OZVAL),L

NxtOpt4:
	btst	OB_CFUNC,b7		; check for:  CREATE FUNCTION
	jrz	NxtOpt5
	move	*B0+,B7,L		; Load CFUNC
	jrz	NxtOpt5
	PUSH	A8
	call	B7			; DO CFUNC
	PULLQ	A8
NxtOpt5:

MkNxtObj
	dsj	a6,MkObjLp
	CMPK	1,a7		;MORE THAN ONE OBJECT CREATED?
	JRNE	MAKEX		;BR = YES, IT IS MULTI
	CLR	A14
	MOVE	A14,*A8(OPART1),L	;MAKE IT LOOK SINGLE
MAKEX
	mmfm	sp,a2,a4,a6,a7,A9,a10,a11  
	move	A8,A8		;Set Z Flag
	jrz	MM_ABT
        btst	OB_INSERT,b2
	jrnz	INSERT_OBJ
	inc	a14		; clr z flag
MM_ABT:	
	rets




****************************************************************************
*    EASYMAKE for single part objects
*
*    Uses a Create Script to allocate and initialize obj(s)
*
*    B0 = ptr to Create Script w/ following format
*        
*        .long IMG
*        .word OCTRL, OFLAGS
*        .word OPTIONS 
*               (OM_OID,  OM_COLL, OM_GUNV, OM_ANIM,
*		 OM_UPOS, OM_WPOS, OM_GRND, OM_SPOS,
*		 OM_DUMCOLL, OM_INSERT)
*
*                OM_OID requires a word to follow the option word.
*                OM_COLL, OM_GUNV, OM_ANIM require a long word
*                         to follow the option word.
*
*  		OM_OID     to supply an OID (otherwise, OID_JUNK is used)   
*               OM_COLL    to supply a coll vector.
*               OM_GUNV    to supply a gun vector.
*               OM_ANIM    to supply an animation script.
*               OM_UPOS    to supply a universe position.
*               OM_WPOS    to supply a world position.
*              [OM_GRND    if you want the supplied world Y to be offset
*                               from YWORLD]
*               OM_SPOS    to supply a screen position.
*		OM_DUMCOLL to use DUMCOLL as a coll. vector (if neither
*			    OM_COLL or OM_DUMCOLL are specified, 0 is used.)
*               OM_CFUNC   to call a special function.
*               OM_INSERT  to call INSERT_OBJ when completed
*
*        NOTE:  DATA WHICH FOLLOWS THE OPTION WORD MUST APPEAR IN THE CORRECT
*               ORDER! (namely, OID, COLL, GUNV, ANIM, xPOS, CFUNC) 
*
*
* RETURNS
*   A0 = ptr to obj
*   Immediately follow with INSERT_OBJ to insert if OM_INSERT not specified.
*
* !!!!!!!!  assume ALL B REGS TRASHED
* !!!!!!!!  also   A0, A1, and A14 TRASHED
*
* CFUNC - Create Functions
*   gets new obj in A0, it is initialized.
*   ptr to Create Script in B0, must inc B0 as CFUNC parms read.
*   Is free to trash all A regs but A8 - A13
*   Must preserve all BREGS except B14 and
*   B0 which must point after CFUNC parms
*
EASYMAKE:
	move	*B0+,B1,L	; get IMG
	move	B1,A1
	callr	GETOBJ
	jrz	EASY_ABT
	callr	FPSTFOBJ0
	mmtm	sp,a4,a8
	move	A0,B1
	move	@ZBASE,b8,L
      
	move	*B0+,B14,W		;Load OCTRL
	MOVE	*B0+,B2,W		;Load OFLAGS
	MOVE	B2,*B1(OFLAGS),W
	btst	B_FLIPH,B14
	jrnz	EMkFlp
	btst	B_FLIPV,B14
	jrz	ESkMkFlp
EMkFlp
	move	B14,A4
	move	A0,A8
	;A1 still set from above
	calla	ANI
	jruc	EMkFlagsOk
ESkMkFlp
	move	*B1(OCTRL),B3,W
	OR	B14,B3
	move	B3,*B1(OCTRL),W
EMkFlagsOk
*
*	Process Optional parameters
*
	move	*b0+,b9		; option flags

	movi	OID_JUNK,a14
	btst	OB_OID,b9 		; check for:  SUPPLIED OID
	jrz	ENxtOpt6			; jump if default
	move	*b0+,b14		; if not default
	move	b14,a14			 
ENxtOpt6:
	move	a14,*a0(OID)

	clr	b14
	btst	OB_DUMCOLL,b9
	jrz	ENxtOpt2A
	movi	DUMCOLL,b14
	jruc	ENxtOpt2
ENxtOpt2A:
	btst	OB_COLL,b9		; check for:  COLLISION VECTOR
	jrz	ENxtOpt2			; jump if default
	move	*b0+,b14,L		; if not default
ENxtOpt2:
	move	b14,*b1(OCVECT),L

	btst	OB_GUNV,b9  		; check for:  GUNVECTOR
	jrz	ENxtOpt1
	move	*b0+,b14,L
	move	b14,*b1(OGUNVECT),L
ENxtOpt1:

	btst	OB_ANIM,b9		; check for:  SUPPLIED ANIMATION
	jrz	ENxtOpt3
	move	*b0+,b14,L
	move	b14,a1
	callr	STRTANIM
ENxtOpt3:
	btst	OB_POS,b9 	; was a position supplied?
	jrz	ENxtOpt4

******************************
*		             *
*    Get supplied position   *
*		             *
******************************

	btst	OB_SPOS,b9	
	jrz	E_world_or_uni
	mmfm	b0,b4,b5	; b5 contains screen XY, b4 contains world Z
	btst	B_SCRNOBJ,b2	; translate from screen to univ if
	jrnz	E_do_scrnobj	; NOT a screen object
	clr	b3
	movx	b5,b3
	TOWORLDX  b4,b3
	move	b3,b6
	move	@XBASE,b14,L
	add	b14,b6		; UNIV X in b6
	sra	16,b5
	move	@YHALF,b14	; TOWORLDY
	sub	b14,b5		; TOWORLDY
	mpys	b4,b5		; TOWORLDY
	move	@YBASE,b14,L
	sub	b14,b5		; UNIV Y in b5
	add	b8,b4		; UNIV Z in b4

	jruc	ENxtOpt7  
	
E_do_scrnobj:
	move	b5,b6
	move	*b1(OANIOFF),b14,L
	subxy	b14,b6
	move	b6,*b1(ODAG),L
	move	b6,*b1(OXPOS),W
	srl	16,b6
	move	b6,*b1(OYPOS),W
	add	b8,b4			; turn world into univ
	jruc	E_do_z

E_world_or_uni:	
	mmfm	b0,b4,b5,b6	; position (flag determines screen, world or univ)
	btst	OB_WPOS,b9	; universe if WPOS not set
	jrz	ENxtOpt7a
	add	b8,b4
	move	@YBASE,b14,L
	sub	b14,b5
	move	@XBASE,b14,L
	add	b14,b6
ENxtOpt7a:				; allow Ground offset for Univ pos.
	btst	OB_GRND,b9
	jrz	ENxtOpt7		; reference Y to ground?
	MOVE	@WORLD_GRNDOFF,B14,L
	ADD	B14,B5
	move	@YWORLD,b14,L
	add	b14,b5
ENxtOpt7:		  
	move	b6,*b1(OXVAL),L
	move	b5,*b1(OYVAL),L
E_do_z:
	move	b4,*b1(OZVAL),L

ENxtOpt4:

	btst	OB_CFUNC,b9		; check for:  CREATE FUNCTION
	jrz	ENxtOpt5
	move	*B0+,B7,L		; Load CFUNC
	jrz	ENxtOpt5
	PUSH	A0
	call	B7			; DO CFUNC
	PULLQ	A0
ENxtOpt5:

;	CLR	A14
;	MOVE	A14,*A0(OPART1),L	;MAKE IT LOOK SINGLE

	mmfm	sp,a4,a8

	btst	OB_INSERT,b9
;	jrnz	INSOBJ
	JRZ	EM_NOINSERT
	CALLR	INSOBJ
EM_NOINSERT
;	inc	a14		; clr z flag
	MOVE	A0,A0			;Clear the Z flag
EASY_ABT:
	rets

**************************************************************************
*								         *
* SET_SCRNOBJ								 *
* IN:  A1, [Y,X]							 *
*      A2, long ZVAL							 *
*      a8, object							 *
* OUT: NUTN'								 *
*								         *
**************************************************************************

SET_SCRNOBJ
	MMTM	SP,A8,A0
	MOVE	A1,A0
SS_PART_LUPE
	MOVE	A0,A1
	MOVE	*A8(OANIOFF),A14,L
	SUBXY	A14,A1
	MOVE	A1,*A8(ODAG),L
	MOVE	A1,*A8(OXPOS),W
	SRL	16,A1
	MOVE	A1,*A8(OYPOS),W
	MOVE	A2,*A8(OZVAL),L
	MOVE	*A8(OPARTS),A8,L
	JRNZ	SS_PART_LUPE
	MMFM	SP,A8,A0
	RETS

**************************************************************************
*								         *
* SET_SCRNPOS								 *
* IN: A1, DA SCREEN POSITION					         *
*     A0, DA OBJECT							 *
* OUT: NUTN'							         *
*								         *
**************************************************************************

SET_SCRNPOS
	PUSH	A8
	MOVE	A0,A8
	CALLR	SET_SCRN_POS
	PULLQ	A8
	RETS

**************************************************************************
*								         *
* SET_SCRN_POS								 *
* IN: A1, DA SCREEN POSITION					         *
*     A8, DA OBJECT							 *
* OUT: NUTN'							         *
*								         *
**************************************************************************

SET_SCRN_POS
	MMTM	SP,A2,A3,A4,A5

	MOVE	A1,A3

	SEXT	A3,W
	MOVE	*A8(OZVAL),A2,L
	move	@ZBASE,a14,L
	sub	a14,a2		; get world Z in a2
 	TOWORLDX	A2,A3
	MOVE	@XBASE,A14,L
	ADD	A14,A3
	MOVE	A3,*A8(OXVAL),L

	MOVE	A1,A5
	SRA	16,A5
	TOWORLDY	A2,A5
	MOVE	@YBASE,A14,L
	SUB	A14,A5
	MOVE	A5,*A8(OYVAL),L
	MOVE	A8,A4
	move	@ZBASE,a14,L
	add	a14,a2

	PUSH	A1
	CALLR	SET_OBJSU
	PULLQ	A1

	MMFM	SP,A2,A3,A4,A5
	RETS


**************************************************************************
*								         *
* GET_SCALED_SIZE - RETURNS THE SCALED SIZE OF AN IMAGE.		 *
* A0 = SCALE FACTOR [Y,X]						 *
* A2 = UNSCALED SIZE [Y,X]						 *
* RETURNS								 *
* 	A6 = [Y,X] SCALED SIZE						 *
*								         *
**************************************************************************
GET_SCALED_SIZE
	PUSH	A5

	MOVX	A0,A14		;GET X-SCALE FACTOR
	SEXT	A14
	MOVX	A2,A5		;GET UNSCALED X-SIZE
	SEXT	A5
	SLL	8,A5
	DIVS	A14,A5		;(in case using for ani pts)
	MOVX	A5,A6		;SEND BACK SCALED X-SIZE

	MOVY	A0,A14		;GET Y-SCALE FACTOR
	SRA	16,A14
	MOVY	A2,A5		;GET UNSCALED Y-SIZE
	SRA	16,A5
	SLL	8,A5
	DIVS	A14,A5		;(in case using for ani pts)
	SLL	16,A5
	MOVY	A5,A6		;SEND BACK SCALED Y-SIZE

	PULLQ	A5
	RETS

**************************************************************************
*								         *
* TO_YSCALE - SCALE A VALUE TO THE SAME SCALE AS AN OBJECTS YSCALE	 *
* A1 = 12 BIT INTEGER VALUE TO SCALE					 *
* A8 = OBJECT								 *
* RETURNS:								 *
* 	A1 = [16.16] SCALE VALUE					 *
*								         *
**************************************************************************
TO_YSCALE
	MOVE	*A8(OSCALEY),A14,W
	SLL	20,A1
	DIVS	A14,A1
	SLL	4,A1
	RETS	

**************************************************************************
*								         *
* TO_XSCALE - SCALE A VALUE TO THE SAME SCALE AS AN OBJECTS XSCALE	 *
* A1 = 12 BIT INTEGER VALUE TO SCALE					 *
* A8 = OBJECT								 *
* RETURNS:								 *
* 	A1 = [16.16] SCALE VALUE					 *
*								         *
**************************************************************************
TO_XSCALE
	MOVE	*A8(OSCALEX),A14,W
	SLL	20,A1
	DIVS	A14,A1
	SLL	4,A1
	RETS	

**************************************************************************
*								         *
* 			MANUAL DMA ROUTINES				 *
* 			-------------------				 *
* 									 *
* 		THESE ROUTINES ARE USED TO FIRE OFF A SINGLE DMA	 *
* 		ALONG WITH THE NORMAL "OBJECTS" BEING DISPLAYED.	 *
* 		THEY ARE USED AS FOLLOWS:				 *
* 									 *
* 		QDMA (QDMA2) -						 *
* 			A1 = [CONSTANT COLOR,PALETTE]			 *
* 			A3 = DESTINATION [Y,X]				 *
* 			A5 = [CONTROL,OFFSET]				 *
* 			A14= ADDRESS OF IMAGE HEADER (THE REST OF	 *
* 				THE INFO WILL BE TAKEN FROM HERE).	 *
* 									 *
* 									 *
* 		QDMAN (QDMAN2) - 					 *
* 			A0 = SCALE [Y,X]				 *
* 			A1 = [CONSTANT COLOR,PALETTE]			 *
* 			A2 = [HEIGHT,WIDTH]				 *
* 			A3 = DESTINATION [Y,X]				 *
* 			A4 = SOURCE ADDRESS				 *
* 			A5 = [CONTROL,OFFSET]				 *
* 									 *
* 									 *
* 		NOTE: QDMA2 AND QDMAN2 DMA TWICE, ONE TO EACH DISPLAY	 *
* 			PAGE.						 *
*								         *
**************************************************************************
QDMAN:
	MMTM	SP,A0,A2,A3,A4,A5,A6,A13
	JRUC	QDMANE
QDMA:
	MMTM	SP,A0,A2,A3,A4,A5,A6,A13
	MOVI	[0100H,0100H],A0	;SCALE IS 1:1
	MOVE	*A14(ISIZE),A2,L    	;GET VSIZE:HSIZE
	MOVE	*A14(ISAG),A4,L		;GET SAG
	MOVE	*A14(ICTRL),A13,W
	SLL	16,A13
	OR	A13,A5			;OR IN THE VITAL SHIT
QDMANE:
	CALLR	GET_SCALED_SIZE		;GET THE SCALED SIZE FOR US
	MOVE	@NO_MIRROR,A13,W	;ARE WE MIRRORING?
	JRNZ	QDMANE_2			;BR = NO
	MOVX	A3,A13			;SLIDE TO OTHER SIDE
	ADDXY	A6,A13
	ZEXT	A13
	SUBI	(SCREEN_WIDTH - 1),A13	;ADJUST COORDINATE
	NEG	A13
	MOVX	A13,A3			;RETURN ADJUSTED X
	XORI	M_FLIPH << 16,A5	;FLIP THE SUCKER

QDMANE_2
	CLR	A13
	BTST	B_FLIPH+16,A5  
	JREQ	NOHF
	MOVX	A6,A13
	DEC	A13
NOHF	BTST	B_FLIPV+16,A5
	JREQ	NOVF
	MOVY	A6,A13
	SUBI	10000h,A13
NOVF	ADDXY	A13,A3

	MOVE	@PAGEADDR,A13,L		;GET THE CURRENT PAGE ADDRESS

	MOVE	@NOPGFLIP,A6,W		;IS PAGE FLIPPING ACTIVE?
	JRNZ	QD_NOPFLP		;BR = NO

	XORI	TOGGLE_PAGE_XY,A13	;XUNIT COMPENSATE FOR BEING 1 PAGE BEHIND

QD_NOPFLP
	addxy	A13,A3			;DO PAGE OFFSET

	MOVK	1,A13
	MOVE	A13,@QDMAFLG,W		;Q BEING MODIFIED
	MOVE	@DMAQCUR,A13,L
	CMPI	DMAQ,A13
	JRLS	QDMAX			;Q OVERLOAD, CAN IT

	MMTM	A13,A0,A1,A2,A3,A4,A5
	MOVE	A13,@DMAQCUR,L
QDMAX:
	CLR	A13
	MOVE	A13,@QDMAFLG,W
	MMFM	SP,A0,A2,A3,A4,A5,A6,A13
	RETS

**************************************************************************
*								         *
* THESE ARE THE DOUBLE-PAGE VERSIONS					 *
*								         *
**************************************************************************
QDMAN2:
	MMTM	SP,A0,A2,A3,A4,A5,A6,A13
	JRUC	QDMANE2
QDMA2:
	MMTM	SP,A0,A2,A3,A4,A5,A6,A13
	MOVI	[0100H,0100H],A0	;SCALE IS 1:1
	MOVE	*A14(ISIZE),A2,L     	;GET VSIZE:HSIZE
	MOVE	*A14(ISAG),A4,L		;GET SAG
	MOVE	*A14(ICTRL),A13,W
	SLL	16,A13
	OR	A13,A5			;OR IN THE VITAL SHIT
QDMANE2:
	CALLR	GET_SCALED_SIZE		;GET THE SCALED SIZE FOR US
	MOVE	@NO_MIRROR,A13,W	;ARE WE MIRRORING?
	JRNZ	QDMANE2_2		;BR = NO
	MOVX	A3,A13			;SLIDE TO OTHER SIDE
	ADDXY	A6,A13
	ZEXT	A13
	SUBI	(SCREEN_WIDTH - 1),A13	;ADJUST COORDINATE
	NEG	A13
QDMANE2_1A
	MOVX	A13,A3			;RETURN ADJUSTED X
	XORI	M_FLIPH << 16,A5	;FLIP THE SUCKER
QDMANE2_2
	CLR	A13
	BTST	B_FLIPH+16,A5  
	JREQ	NOHF2
	MOVX	A6,A13
	DEC	A13
NOHF2	BTST	B_FLIPV+16,A5
	JREQ	NOVF2
	MOVY	A6,A13
	SUBI	10000h,A13
NOVF2	ADDXY	A13,A3

	MOVK	1,A13
	MOVE	A13,@QDMAFLG,W		;Q BEING MODIFIED
	MOVE	@DMAQCUR,A13,L
	CMPI	DMAQ,A13
	JRLS	QDMA2X			;Q OVERLOAD, CAN IT

;XUNIT ST	
	ADDXYI	PAGE0ADR,A3

	MMTM	A13,A0,A1,A2,A3,A4,A5
	;*** Q it for PAGE 2 also

	ADDI	PAGE1ADR-PAGE0ADR,A3
;XUNIT END	

	CMPI	DMAQ,A13
	JRLS	QDMA2X			;Q OVERLOAD, CAN IT
	MMTM	A13,A0,A1,A2,A3,A4,A5
	MOVE	A13,@DMAQCUR,L
QDMA2X:
	CLR	A13
	MOVE	A13,@QDMAFLG,W
	MMFM	SP,A0,A2,A3,A4,A5,A6,A13
	RETS

**************************************************************************

	.ALIGN

**************************************************************************
* YZSORT
* SORT EACH SCREEN OBJECT LIST IN Z:Y PRIORITY
* IF OBJ DOESN'T HAVE NOAUTOZ SET, MOVE FROM LIST TO LIST BASED ON Z COOR
* CALL FROM EXEC LOOP
YZSORT:

	.IF DEBUG
	callr	CkOFREE
	callr	CkAnim
	.ENDIF

YZPlnLp	
;	MOVE	@ZSCROLL,A2,L

	movi	FGLIST,A10	;NEW   
	move	A10,A0		;A10 START OF LIST

	CLR	A9		;This will be our flag clear reg
	MOVE	A9,@INVELADD,W

	;PRESTUFF Z,Y OF PREVIOUS OBJ
;	MOVI	07FFFFFFFH,A6	;HIGHEST POSSIBLE Z (POS)
	MOVI	080000000H,A6	;LOWEST POSSIBLE Z
;	MOVI	080000000H,A5	;LOWEST POSSIBLE Y (NEG)
	MOVI	07FFFFFFFH,A5	;HIGHEST POSSIBLE Y
	MOVE	A5,A4
	JRUC	YZLP

YZLP0:
	MOVE	*A1(OZVAL),A8,L		;NEXT OBJ Z
	MOVE	*A1(OYVAL),A7,L		;NEXT OBJ Y

	CMP   	A6,A8
	JRGT  	priok
	JRLT	PRISWAP
;	JRLT  	priok
;	JRGT	PRISWAP

	CMP	A5,A7
	JRLE	priok			;BOTTOM OBJECTS TAKE PRIORITY OF TOP
PRISWAP:
*
* This is the other half of my fiendish plot
*
	MOVE	@INVELADD,A14,W
	JRNZ	YZPlnLp			;BR=we VELADDed, so restart

	PUSHST
	dint

;	MOVE	A2,A2
;	JRZ	NOTIMER_CHECK
;
;	MOVE	@TIMER,A14,W
;	JRNZ	YZ_ABORT
*
* George is trying something here. Take this out and try restarting
* the sort if a VELADD occurs.  Let's just see what the fuck happens 5/2/94.
*
;	MOVE	@INVELADD,A14,W
;	JRNZ	YZ_ABORT		;BR=we VELADDed, so get outta dodge

NOTIMER_CHECK
	;unlink A0 from list
	move	*A0(OBLINK),A14,L
	move  	A1,*A14,L		;LINK FORWARD OVER A0
	move	A14,*A1(OBLINK),L	;LINK BACKWARD OVER A0
		
	move  	*A1,A14,L
	move	A14,*A0,L		;INSERT A0 AFTER A1
	move	A0,*A1,L		;
	move	A1,*A0(OBLINK),L	;
	move  	A0,*A14(OBLINK),L	;

	POPST

	MOVE	A4,A5
	JRUC	YZLP
priok:

;	MOVE	A6,A9
	MOVE	A9,*A0(ONOT_SORTED),W	;Mark this object as sorted

	move  	A1,A0
	move  	A8,A6		;Z
	move	A7,A5		;Y
YZLP:
	move	*A0,A1,L	     	;next link in A1
	cmp	A1,A10
	jrne  	YZLP0

	RETS

;YZ_ABORT
;	POPST
;	RETS

**************************************************************************
* END OF DISPLAY SYSTEM
**************************************************************************

**************************************************************************
* DISPLAY UTILITY ROUTINES
**************************************************************************

**************************************************************************
*								         *
* GET_BPLANE - GET THE OBJ LIST FOR THE GIVEN BACKGROUND PLANE.		 *
* A1 = PLANE #								 *
* RETURNS								 *
* 	A0 = PLANE OBJ LIST						 *
*								         *
**************************************************************************
GET_BPLANE
	move	A1,A0
	movi	PLNSIZ,A14
	mpyu	A14,A1
	addi	BGLISTS,A1
	SWAP	A1,A0
	rets

****************************************************************************
* FINDOID
* A0 - SUPP LIST
* A1 - OID MASK
* A2 - PATTERN TO MATCH
* RETS  A0 pts to obj, else ZFLAG set
FINDOID:
	PUSH	A3
	and	A1,A2
FindLp:
	move	*A0(OSLINK),A0,L
	jrz	FindOidX
	move	*A0(OID),A3,W
	and	A1,A3
	cmp	A2,A3
	jrne	FindLp
FindOidX:
	PULLQ	A3
	move	A0,A0
	rets

**************************************************************************
*								         *
* SetOnGrnd - PLACE IMAGE SO THAT IS ON THE GROUND			 *
*								         *
* PASS:									 *
* A8 = PTR TO OBJECT							 *
*								         *
**************************************************************************
SetOnGrnd:
	PUSH	A0
	MOVE	@YWORLD,A14,L
	MOVE	@WORLD_GRNDOFF,A0,L
	ADD	A0,A14
	MOVE	*A8(OGRNDOFF),A0,L
	SUB	A0,A14
	MOVE	A14,*A8(OYVAL),L
	PULLQ	A0
	rets

**************************************************************************
*								         *
* SET_ONGRND - SAME AS SetOnGrnd EXCEPT ALIGNS A MULTI-PARTER, ASSUMING	 *
* 		THAT THE HEAD OBJECT IS PASSED.				 *
* A8 = PTR TO OBJECT (HEAD IF MULTI-PARTER)				 *
*								         *
**************************************************************************
SET_ONGRND
	MMTM	SP,A1,A2,A3
	MOVE	*A8(OXVAL),A3,L
	MOVE	@YWORLD,A2,L
	MOVE	@WORLD_GRNDOFF,A0,L
	ADD	A0,A2
	MOVE	*A8(OGRNDOFF),A0,L
	SUB	A0,A2
	MOVE	*A8(OZVAL),A1,L
	CALLR	REPOS_OBJ
	MMFM	SP,A1,A2,A3
	RETS

**************************************************************************
*								         *
* DIST_FROM_GROUND - RETURNS THE DISTANCE BETWEEN THE BOTTOM OF THE	 *
* 		GIVEN OBJECT AND THE GROUND AT THE OBJECTS CURRENT	 *
* 		ZVAL.							 *
* A8 = PTR TO OBJECT							 *
* RETURNS								 *
* 	A1 = SHL DISTANCE (STATUS BITS REFLECT THE SIGN OF A1)		 *
* 									 *
**************************************************************************
DIST_FROM_GROUND
	PUSH	A0
	MOVE	*A8(OYVAL),A14,L
	MOVE	*A8(OGRNDOFF),A1,L
	SUB	A1,A14
	MOVE	@YWORLD,A1,L
	MOVE	@WORLD_GRNDOFF,A0,L
	ADD	A0,A1
	SUB	A14,A1
	PULL	A0
	RETS

*REMOVED SetPlaneXPos:

*REMOVED SETPLANE

*REMOVED SET_PLANE

*REMOVED SETPLANE_FB

**************************************************************************
*								         *
* SETPLANE_BB - ROUTINE TO SET AN OBJECT ON AN ARBITRARY PLANE. COORDINA *
* 		AND VELOCITY ADJUSTED ACCORDINGLY.			 *
* 		FOR OBJECTS CURRENTLY ON BACKGROUND TO BE SET ON	 *
* 		BACKGROUND.						 *
* 		(FOR NOAUTOZ OBJECTS ONLY!)				 *
* A0 = PTR TO OBJECT							 *
* A2 = NEW BACKGROUND PLANE #						 *
*								         *
**************************************************************************
SETPLANE_BB
	PUSH	A1
	callr	PULLOBJ			;PULL FROM CURRENT FOREGROUND
	move	A0,A1
	callr	CHGPLANE_BB		;SWITCH TO THE BACKGROUND
	callr	INSBOBJ			;NOW INSERT ON THE BACKGROUND
	PULLQ	A1
	rets

*REMOVED SETPLANE_BF

*REMOVED SETPLANE_BF_MULTI

*REMOVED ChgPlane

*ENTRY JUST TO CHANGE THE VALUES
*A3 = DESTINATION PLANE OBJ LIST
*A5 = CURRENT PLANE OBJ LIST
ChgPlane_G
	move	*A1(OXPOS),A7,W
	move	*A5(P_XPOS+010h),A6,W	;A5 X POSITION OF CURRENT PLANE
	sub	A6,A7			;X position now screen rel
	move	*A3(P_XPOS+010h),A6,W	;A5 X POSITION OF NEW PLANE
	add	A6,A7			;X position adjusted to new plane
	MOVE	A7,*A1(OXPOS),W		;STUFF ME BABY!

	move	*A5(P_XRATE),A5,L	;A5 XRATE OF CURRENT PLANE
	move	*A3(P_XRATE),A3,L	;A3 XRATE OF NEW PLANE
	move	*A1(OXVEL),A6,L
	mpys	A3,A6			;A6,A7 = 16.16 x 16.16 XVAL
	divs	A5,A6
	move	A6,*A1(OXVEL),L

	mmfm	SP,A3,A5,A6,A7
	rets
	
*REMOVED CHGPLANE_FB

**************************************************************************
*								         *
* CHGPLANE_BB - CHANGE OBJECT FROM A BACKGROUND TO A BACKGROUND PLANE.	 *
* 	Adjust the X position of an object for changing planes		 *
* 	Adjust the X velocity of an objext for changing planes		 *
* 	Stuff the new plane #.						 *
* 	Caller must take care of changing links (PULLOBJ, INSOBJ)..	 *
* A1 obj (*A1(OPLANE) gives current BACKGROUND plane #)			 *
* A2 BACKGROUND plane # to go to					 *
*								         *
**************************************************************************
CHGPLANE_BB
	mmtm	SP,A3,A5,A6,A7
;	movb	*A1(OPLANE),A5
;	movb	A2,*A1(OPLANE)
	movi	PLNSIZ,A3
	mpyu	A3,A5
	addi	BGLISTS,A5
	mpyu	A2,A3
	addi	BGLISTS,A3
	JRUC	ChgPlane_G

*REMOVED CHGPLANE_BF

**************************************************************************
*								         *
* STOREOPLANE - STORE THE GIVEN VALUE IN ALL OF THE OPLANE FIELDS OF	 *
* 		THE GIVEN OBJECT, MULTI-PART OR NOT.			 *
* A0 = PTR TO STARTING PART						 *
* A1 = OPLANE VALUE							 *
*								         *
**************************************************************************
STOREOPLANE
;	MOVB	A1,*A0(OPLANE)
	MOVE	*A0(OPARTS),A14,L
	JRZ	SP_X
SP_LP
;	MOVB	A1,*A14(OPLANE)
	MOVE	*A14(OPARTS),A14,L
	JRNZ	SP_LP
SP_X
	RETS

**************************************************************************
*								         *
* STORE_OPLANE - STORE THE GIVEN VALUE IN ALL OF THE OPLANE FIELDS OF	 *
* 		THE GIVEN OBJECT, MULTI-PART OR NOT.			 *
* 		A8 VERSION						 *
* A1 = OPLANE VALUE							 *
* A8 = PTR TO STARTING PART						 *
*								         *
**************************************************************************
STORE_OPLANE
	PUSH	A0
	MOVE	A8,A0
	CALLR	STOREOPLANE
	PULL	A0
	RETS

**************************************************************************
*								         *
* 	SCRTST								 *
* 									 *
* 	Test if an object is on-screen.  If object is head of a		 *
* 	multi-parter, then the whole thing must be on/off the screen.	 *
* 									 *
* 	A8 = Ptr to object						 *
* 									 *
* 	Returns:							 *
* 									 *
* 		 Z = Onscreen						 *
*								         *
**************************************************************************
SCRTST:
	PUSH	A8

	MOVE	*A8(OPART1),A14,L	;Is this a multi-part object?
	JRZ	ST_SINGLE_TEST		;BR = No
	CMP	A14,A8			;Do we have the head part
	JRNE	ST_SINGLE_TEST		;BR = No, just check this part
*
* We are checking a multi-parter here
*
ST_MULTI_LOOP
	MOVE	*A8(OLINK),A14,L	;Is the object inserted?
	JRZ	ST_NEXT_PART		;BR = No

	MOVB	*A8(OFLAGS),A14		;Is this part on-screen?
	JRNN	ST_ONSCREEN		;BR = Yes, then that's good enough

ST_NEXT_PART
	MOVE	*A8(OPARTS),A8,L	;Get the next part
	JRNZ	ST_MULTI_LOOP		;BR = We got it and we're going in
	JRUC	ST_OFF			;The whole thing is off
*
* Checking just the given object
*
ST_SINGLE_TEST
	MOVB	*A8(OFLAGS),A14
	JRNN	ST_ONSCREEN
ST_OFF
	CLRZ	    			;Return NZ when off screen
	JRUC	ST_X
ST_ONSCREEN
	SETZ
ST_X
	PULL	A8			;Pull must preserve the Status
	RETS

**************************************************************************
* OINIT
* INITIALIZE FREE LIST, OBJ PLANES, ANIOBJS, QUEUES
OINIT:
	MMTM	SP,A0,A1,A2,A3	;SAVE REG

	PUSHST
	DINT
	MOVE	@INTENB,A0,W
	ANDNI	X1E,A0		;NO MORE DMA INTERRUPTS
	MOVE	A0,@INTENB,W
	POPST

	MOVI	SCRNST,A0,L	;INIT SCREEN TOP LEFT [Y,X]
	MOVE	A0,@SCRNTL,L
	MOVI	SCRNEND,A0,L	;INIT SCREEN LOWER RIGHT [Y,X]
	MOVE	A0,@SCRNBR,L

	movi	DMAIQBOT,B12
	move	B12,B13		;set dma Q to be clear so DMAWAIT won't hang
	MOVE	B12,@DMAIQACT,L	;INIT ACTIVE DMA Q

	MOVI	DMAQ+QSIZE,A1
	MOVE	A1,@DMAQCUR,L		;INIT MISC DMA QUEUE

	MOVI	DEFAULT_WXBUFFER,A14
	MOVE	A14,@WXBUFFER,L

	MOVI	DEFAULT_WYBUFFER,A14
	MOVE	A14,@WYBUFFER,L

	CLR     A0
	MOVE	A0,@ANIOBJS,L

	MOVE	A0,@XBASE,L
	MOVE	A0,@YBASE,L
	MOVE	A0,@ZBASE,L
	MOVE	A0,@ZBASE_HR,L
	MOVE	A0,@XSCROLL,L
	MOVE	A0,@YSCROLL,L
	MOVE	A0,@ZSCROLL,L
	MOVE	A0,@XSACCEL,L
	MOVE	A0,@YSACCEL,L
	MOVE	A0,@ZSACCEL,L

	MOVE	A0,@BGPLANECT,W

	MOVE	A0,@HORIZON,W
	MOVE	A0,@HORIZON_BASE,W

	MOVE	A0,@INVELADD,W	;INIT VELADD FLAG

	MOVE	A0,@WORLD_GRNDOFF,L	;Clear this thing

;	MOVE	A0,@ROADPAL,W
;	move	a0,@ROADFLG,W
;
;	movi	ROADOFFY,a1
;	move	a1,@ROADY,L
;	movi	ROADOFFX,a2
;	move	a2,@ROADX,L
;	movi	512,a3		; number of long words
;oinitrdoff:
;	move	a0,*a1+,L 	; clear 2 words at a time
;	move	a0,*a2+,L 	; clear 2 words at a time
;	dsjs	a3,oinitrdoff


	PUSHST
	DINT

	;*** CLEAR OUT FG PLANE, BG PLANES ***
	movi	FGLIST,A1
	movi	(BGLISTSX-FGLIST)/010h,A2
ClrFGLp
	move	A0,*A1+,W
	dsjs	A2,ClrFGLp

	;*** INITIALIZE LINK FIELDS OF PLNS ***
	movi	FGLIST,A1
	movi	BGLISTSX,A2
InitPlns
	move	A1,*A1,L		;Make P_LSTHD point at P_LSTHD
	move	A1,*A1(020h),L		;Make P_LSTTL point at P_LSTHD
	addi	PLNSIZ,A1
	cmp	A2,A1
	jrlt	InitPlns

	POPST

	;*** CLEAR OUT OBJ SPACE ***
	movi	OBJSTR,A1
  	movi	NOBJ*OBSIZ/010h,A2
CLROBST	move	A0,*A1+,W
	dsjs	A2,CLROBST

	MOVI	OBJSTR,A1,L
	MOVE	A1,@OFREE,L	;SETUP FREE LIST
  	movi	NOBJ,A3			;Init FREECNT to # of objs
	move	A3,@OFREECNT		;
oinitl:
	MOVE	A1,A2
	ADDI	OBSIZ,A1,W
	MOVE	A1,*A2,L		;LINK EM UP
	DSJS	A3,oinitl		;CONTINUE FOR NPROC
    	MOVE	A0,*A2,L		;ZERO LAST LINK
	move	A2,@ENDOFREE,L		;keep ptr to last obj on free list

	CALLA	INIT_DUMMY_UNIVERSE

	MMFM	SP,A0,A1,A2,A3	;RESTORE REGS
	RETS


**************************************************************************
* CkOFREE
* WALK FREE LIST, VERIFY LENGTH AND THAT EACH OBJ'S INUSE BIT IS CLEAR
* LOCKUP ON ERROR
	.IF DEBUG
CkOFREE:
	mmtm	SP,A0,A1,A2
	clr	A1
	move	@OFREE,A0,L
	jrz	GotFreCt
CntFree	inc	A1
	movb	*A0(OCTRL+B_INUSE-7),A2
	LOCKON	N
	move	*A0,A0,L
	jrnz	CntFree
GotFreCt:
	move	@OFREECNT,A0,W
	cmp	A0,A1
	LOCKON	NE
	mmfm	SP,A0,A1,A2
	rets
	.ENDIF


**************************************************************************
* IsAnObj
* CHECK A0 FOR BEING AN OBJECT PTR
* LOCKS UP IF BAD OBJ
IsAnObj:
	PUSH	A0
	subi	OBJSTR,A0
	LOCKON	N
	cmpi	OBJSTRX,A0
	LOCKON	GE
	movi	OBSIZ,A14
	modu	A14,A0
	LOCKON	NZ
	PULLQ	A0
	rets

**************************************************************************
* GETOBJ
* GET A FREE OBJECT BLOCK FOR USE
*
* RETURNS A0 = PTR TO OBJECT BLOCK
*    IF NO BLOCKS WERE AVAILABLE THEN THE Z FLAG IS SET
GETOBJ:
 	MOVE  	@OFREE,A0,L	; pointer to next available obj block
	jreq  	getox
	.IF DEBUG
	callr	IsAnObj
	movb	*A0(OCTRL+B_INUSE-7),A14
	LOCKON	N
	.ENDIF
	move	@OFREECNT,A14,W	;dec obj free list count
	dec	A14		;
	move	A14,@OFREECNT,W	;
	LOCKON	N
	jrp	SkClrEnd
	move	@ENDOFREE,A14,L
	cmp	A14,A0
	LOCKON	NE
	clr	A14
	move	A14,@ENDOFREE,L
SkClrEnd:
	move  	*A0,A14,L
	move  	A14,@OFREE,L	; adjust pointer to free list

	;*** CLEAR OUT THE VITAL PART OF THE OBJECT BLOCK ***
	clr	A14
	movi	OCLRSIZ,B14
	srl	5,B14
	jrnc	SkObjWord
	move	A14,*A0+,W
SkObjWord
	srl	1,B14
	jrnc	SkObjLong
	move	A14,*A0+,L
SkObjLong
ObjClrLp
	move	A14,*A0+,L
	move	A14,*A0+,L
	dsjs	B14,ObjClrLp
	subi	OCLRSIZ,A0

;	move	@TIME,A14,W
;	move	A14,*A0(OTIME),W

	MOVKM	1,*A0(ONOT_SORTED),W	;Flag object as out of order

	movi	DMAWNZ|M_INUSE,A14
	move	A14,*A0(OCTRL),L	;init offset:flags

	move	A0,A0		; clear Z flag
getox:
	rets

**************************************************************************
*								         *
* CLRODATA - ROUTINE TO CLEAR THE ODATA AREA OF AN OBJECT.		 *
* 		A0 VERSION						 *
* A0 = PTR TO OBJECT							 *
*								         *
**************************************************************************
CLRODATA
	PUSH	A8
	MOVE	A0,A8
	CALLR	CLR_ODATA
	PULLQ	A8
	RETS

**************************************************************************
*								         *
* CLR_ODATA - ROUTINE TO CLEAR THE ODATA AREA OF AN OBJECT		 *
* A8 = PTR TO OBJECT							 *
* RETURNS								 *
* 	Z bit Clear							 *
*								         *
**************************************************************************
CLR_ODATA
	MMTM	SP,A1,A2
	MOVE	A8,A1
	MOVE	A1,A2
	ADDI	ODATA,A1
	ADDI	ODATAX,A2
	CALLA	CLRBLOCK
	CLRM	*A8(OPLAYER),L
	MOVE	A8,A8			;Clear Z for compatability
	MMFM	SP,A1,A2
	RETS

****************************************************************************
* SET_OPLANE
*
* set OPLANE field for each obj of a multi-parter
* A8 ptr to head obj
* A1 OPLANE value
SET_OPLANE:
	move	A8,A14
SETPLNLP
;	movb	A1,*A14(OPLANE)
	move	*A14(OPARTS),A14,L
	jrnz	SETPLNLP
	rets

**************************************************************************
*								         *
* INSERT_OBJ - If head of multi-parter, entire multi-parter inserted.	 *
* 	     If sub-part of multi-parter, just sub-part inserted.	 *
* 	     OID is checked to insert object on supplemental list.	 *
* A8 = OBJ								 *
* RETURNS								 *
* 	nothing								 *
*								         *
**************************************************************************
INSERT_OBJ:
	PUSH	A0
	move	*A8(OPART1),A0,L
	jrz	SkInsMulti
	cmp	A0,A8			;Is Part Head Obj
	jrne	SkInsMulti

InsMulti
;* TO INSERT A HEAD OBJECT, INSERT SUBPARTS FIRST
;* THIS COULD BE MADE MORE EFFICIENT BY INSERTING ENTIRE MULTI-PARTER
;* TOGETHER INSTEAD OF CALLING INSOBJ FOR EACH PIECE
	move	*A0(OPARTS),A0,L
	jrz	SkInsMulti
	callr	INSOBJ			;INSERT Sub-Part
	jruc	InsMulti
SkInsMulti
	move	A8,A0
	callr	INSOBJ
	PULLQ	A0
	rets
****************************************************************************

**************************************************************************
*								         *
* INSERT_ON_OBJ - SAME AS INSERT_OBJ, EXCEPT, SUB-PARTS WILL ONLY BE	 *
* 		INSERTED IF THEY ARE ON, I.E. DMA WILL WRITE.		 *
* A8 = PTR TO OBJ							 *
*								         *
**************************************************************************
INSERT_ON_OBJ
	PUSH	A0
	MOVE	*A8(OPART1),A0,L	;CHECK FOR HEAD
	JRZ	SkInsMulti
	CMP	A0,A8			;IS IT?
	JRNE	SkInsMulti		;BR = NO
IOO_LP
;* TO INSERT A HEAD OBJECT, INSERT SUBPARTS FIRST, IF THEY'RE ON.
;* THIS COULD BE MADE MORE EFFICIENT BY INSERTING ENTIRE MULTI-PARTER
;* TOGETHER INSTEAD OF CALLING INSOBJ FOR EACH PIECE
	MOVE	*A0(OPARTS),A0,L	;GET SUB-PART
	JRZ	SkInsMulti		;BR = NO MORE

;	MOVE	*A0(OCTRL),A14,W	; OLD WAY
;	SLL	28,A14			;IS THIS OBJECT ON?
;	JRZ	IOO_LP			;BR = NO, THEN DON'T INSERT YET

	move	*a0(OFLAGS),a14
	btst	B_NODISP,a14
	jrnz	IOO_LP

	CALLR	INSOBJ			;INSERT LOS SUB-PART
	JRUC	IOO_LP			;AND DO NEXT

**************************************************************************
*								         *
* REINSBOBJ - INSERT AN OBJECT ON THE BACKGROUND LIST.			 *
* A0 = PTR TO OBJECT							 *
* *A0(OPLANE) = PLANE NUMBER TO INSERT UPON				 *
*								         *
**************************************************************************
REINSBOBJ:
	mmtm 	SP,A1,A2,A3,A4,A5
	   ;tell background system to delete
	move	*A0(OFLAGS),A4,W
	andni	M_BNODEL,A4
	move	A4,*A0(OFLAGS),W
	jruc	INSBOBJE

**************************************************************************
*								         *
* INSBOBJ - INSERT AN OBJECT ON THE BACKGROUND LIST.			 *
* A0 = PTR TO OBJECT							 *
* *A0(OPLANE) = PLANE NUMBER TO INSERT UPON				 *
*								         *
**************************************************************************
INSBOBJ:
	mmtm 	SP,A1,A2,A3,A4,A5
	   ;tell background system not to delete
	move	*A0(OFLAGS),A4,W
	ori	M_BNODEL,A4
	move	A4,*A0(OFLAGS),W
INSBOBJE
*DO SOME ERROR CHECKING FIRST
	callr	IsAnObj
	move	*A0,A4,L
	LOCKON	NZ			;obj is already inserted

	movi	BGLISTS,A3
;	movb	*A0(OPLANE),A1
	movi	PLNSIZ,A14
	mpyu	A14,A1		;Plane # * planesize
	add	A1,A3		; + base of plane table

	jruc	InsGotPln

**************************************************************************
*								         *
* INSPLANE - INSERT AN OBJECT ON A GIVEN PLANE, DISREGARDS OPLANE	 *
* 	   AND ZVAL.							 *
* A0 = OBJ to insert							 *
* B0 = ptr to plane							 *
* RETURNS								 *
* 	nothing								 *
*								         *
**************************************************************************
INSPLANE:
	mmtm 	SP,A1,A2,A3,A4,A5
	move	B0,A3
	jruc	InsGotPln

**************************************************************************
*								         *
* INSOBJ - Insert obj into doubly linked object list			 *
* 	 List is sorted by increasing Z and increasing Y		 *
* 	 OID is checked to insert object on supplemental list		 *
* A0 = OBJ								 *
* *A0(OPLANE) = Plane # if no AUTOZ					 *
* RETURNS								 *
* 	nothing								 *
*								         *
**************************************************************************
INSOBJ:
	mmtm 	SP,A1,A2,A3,A4,A5
	;ERROR CHECKS
	callr	IsAnObj

	move	*A0,A4,L
	jrnz	INSOBJX		;obj is already inserted

	movi	FGLIST,A3
InsGotPln
	move	A3,A4
	move 	*A0(OZVAL),A1,L		; GET Z POSITION
ins_zloop:
	move  	*A3,A3,L
	cmp	A3,A4
	jreq 	do_ins			; bra if at end of list

	MOVE	*A3(ONOT_SORTED),A2,W
	JRNZ	ins_zloop		;BR = Don't base off un-sorted object

	move 	*A3(OZVAL),A2,L		; ZPOS in A3
	cmp    	A2,A1
	jrgt 	ins_zloop
	jrlt	do_ins

	move	*A0(OYVAL),A5,L		; GET Y POSITION
	jruc	ins_ytest
ins_yloop
	move  	*A3,A3,L
	cmp	A3,A4
	jreq 	do_ins			; bra if at end of list

	MOVE	*A3(ONOT_SORTED),A2,W
	JRNZ	ins_yloop		;BR = Don't base off un-sorted object

	move 	*A3(OZVAL),A2,L		; ZPOS in A3
	cmp    	A2,A1
	jrlt 	do_ins
ins_ytest
	move	*A3(OYVAL),A2,L		;TEST Y POSITION
	cmp	A2,A5
	jrlt	ins_yloop
do_ins
	PUSHST	
	DINT	
	move 	*A3(OBLINK),A2,L	; get ptr to previous

	move	A3,*A0,L		;IF BACK LINKS USED FROM INTERRUPT
	move	A0,*A2,L		; THIS WILL NEED TO BE DINT
	move	A0,*A3(OBLINK),L	;
	move	A2,*A0(OBLINK),L	;
	CLR	A4
	MOVE	A4,*A0(ONOT_SORTED),W	;Mark object as sorted
	POPST

	callr	INSSUPP			;INSERT ON SUPPLEMENTAL LIST
INSOBJX
	mmfm 	SP,A1,A2,A3,A4,A5
	rets


**************************************************************************
* PULL_OBJ
* PULLS OBJECT FROM A DOUBLY LINKED OBJECT LIST
* MULTI-PART PIECES ARE NOT UNLINKED
* IF HEAD OF MULTI-PARTER, ENTIRE MULTI-PARTER PULLED
* IF SUB-PART OF MULTI-PARTER, JUST SUB-PART PULLED
* OID IS CHECKED TO PULL OBJECT FROM SUPPLEMENTAL LIST
*
* A8 = OBJ to be pulled
* RETS nothing
PULL_OBJ:
	PUSH	A0
	move	*A8(OPART1),A0,L
	jrz	SkPullMulti
	cmp	A0,A8			;Is Part Head Obj
	jrne	SkPullMulti

PullMulti ;* TO PULL A HEAD OBJECT, PULL ANY SUBPARTS FIRST
	move	*A0(OPARTS),A0,L
	jrz	SkPullMulti
	callr	PULLOBJ			;Pull Sub-Part
	jruc	PullMulti
SkPullMulti
	move	A8,A0
	callr	PULLOBJ
	PULLQ	A0
	rets

**************************************************************************
*								         *
* 	PULLOBJ								 *
* 									 *
* 	Pull an object from the Doubly linked object list.		 *
* 	If object is not inserted, then nothing is done.		 *
* 	Object is also pulled from the supplemental list		 *
* 	defined by its OID.						 *
* 	OLINK is cleared to mark object as not inserted.		 *
* 									 *
* 	A0 = Ptr to object						 *
* 									 *
* 	Returns:							 *
* 									 *
* 		Nothing							 *
*								         *
**************************************************************************
PULLOBJ:
	;PULL OBJ OUT OF ACTIVE OBJ LIST
;No zero checks needed because there will always be ptrs from both ends
	move	*A0(OLINK),A14,L	;IS OBJ INSERTED?
	jrz	SkPULLOBJ
	PUSH	A1
	PUSHST	
	DINT				;Interrupts off now
	move	*A0(OBLINK),A1,L	;A1 - Prev Obj
	move	*A0,A14,L		;A14 - Next Obj
	move	A14,*A1,L		;LINK FORWARD AROUND OBJ A0
	move	A1,*A14(OBLINK),L	;LINK BACKWARD AROUND OBJ A0
	clr	A14
	move	A14,*A0(OLINK),L	;OBJ NOT INSERTED
	POPST	

;	callr	PULLSHAD

	callr	PULLSUPP	;PULL FROM SUPPLEMENTAL LIST
	PULLQ	A1
SkPULLOBJ
	rets

**************************************************************************
*								         *
* 	DELETE_OBJ							 *
* 									 *
* 	Delete an object from the object list and put it on the		 *
* 	end of the FREE list.						 *
* 									 *
* 	If object is HEAD of a multi-parter the entire multi-parter	 *
* 	is pulled from the object list and put on the FREE list		 *
* 	but it is not disassembled as a multi-parter.			 *
* 									 *
* 	If object is a sub-part of a multi-parter, object is		 *
* 	unlinked from the multi-parter, pulled from the object list	 *
* 	and put on the FREE list.					 *
* 									 *
* 	If object is solo then it is pulled from the object list and	 *
* 	put on the FREE list.						 *
* 									 *
* 	All objects:							 *
* 									 *
* 		- Pulled from the Animation list, if Animating.		 *
* 		- Shadow pulled and freed, if object has a shadow.	 *
* 		- Palette is deallocated.				 *
* 									 *
* 	Entrypoints:							 *
* 									 *
* 		DELETE_OBJ_PROC - Kills controlling process.		 *
* 		ZAP_OBJ - Skips the OPLINK safety check.		 *
* 									 *
* 	A8 = Ptr to object to be freed					 *
* 									 *
* 	Returns:							 *
* 		Nothing							 *
*								         *
**************************************************************************
DELETE_OBJ:
;Delete this symbol - FREE_OBJ:
	.IF DEBUG
	move	*A8(OPLINK),A14,L
	jrz	ZAP_OBJ
	cmp	A14,A13
	LOCKON	NE
	.ENDIF
	JRUC	ZAP_OBJ

*
*Entrypoint: Kills linked process before deleting
*
DELETE_OBJ_PROC
	CALLA	OBJPROC_KILL
*
*	Fall through to ZAP_OBJ!

*
*Entrypoint: If OPLINK should not be checked
*
ZAP_OBJ:
	PUSH	A0
	move	*A8(OPART1),A0,L
	jrz	SkFreeMulti
	cmp	A0,A8			;Is Part Head Obj
	jreq	FreeMulti
	callr	PULL_PART		;SubPart just gets unlinked
	jruc	SkFreeMulti
FreeMulti ;* TO FREE A HEAD OBJECT, FREE ANY SUBPARTS FIRST (don't unlink)
	move	*A0(OPARTS),A0,L
	jrz	SkFreeMulti
	MOVE	*A0(OFLAGS),A14,W	
	BTST	B_SHAD,A14		;This wouldn't happen to be a shadow?
	JRNE	FreeMulti		;BR = Yes, let it's source sweat it
	callr	ZAPOBJ			;Delete Sub-Part
	jruc	FreeMulti
SkFreeMulti
	move	A8,A0
	callr	ZAPOBJ
	PULLQ	A0
	rets


**************************************************************************
* DELOBJ
* FREEOBJ
* FREEGOBJ
* IF OPLINK SET, IT MUST POINT TO CURRENT PROCESS
* OID IS CHECKED TO PULL OBJECT FROM SUPPLEMENTAL LIST
* PUTS OBJ ON END OF FREE LIST
* INUSE BIT CLEARED
* FREEGOBJ (free garbage obj) Skips the following checks
*   IF PART ON AN OBJLST, IT IS PULLED
*   IF PART WAS ON ANIM, IT IS PULLED
*   SHADOW OBJ IS FREED
*   PALETTE IS DEALLOCATED
* ERRORS if obj not valid ptr, obj is already free
*
* A0 = OBJ to be deleted/freed
* RETS nothing
**************************************************************************
FREEGOBJ:
	callr	IsAnObj
	move	*A0(OCTRL),A14,W
	andni	M_INUSE,A14
	move	A14,*A0(OCTRL),W
	clr	A14
	move	A14,*A0,L	;OBJ GOES TO END OF FREE LIST, PTS AT NOTHING
	jruc	DOFREE
**************************************************************************
DELOBJ:
FREEOBJ:
	.IF DEBUG
;	MOVE	*A0(OID),A14,W
;	CMPI	OID_UNIV,A14
;	JREQ	ZAPOBJ
	move	*A0(OPLINK),A14,L
	jrz	ZAPOBJ
	cmp	A14,A13
	LOCKON	NE
	.ENDIF
ZAPOBJ:
* ENTRY POINT IF PLINK SHOULD NOT BE CHECKED

	callr	IsAnObj

	;CLEAR INUSE BIT TO MARK OBJ AS ON FREE LIST
	move	*A0(OCTRL),A14,W
	btst	B_INUSE,A14

	jrnz	inuse_ok
	CALLA	DUMPPRINT
	rets
inuse_ok:

	andni	M_INUSE,A14
	move	A14,*A0(OCTRL),W
	move	*A0(OFLAGS),A14,W
	;PULL FROM ANIM IF NECESSARY
	btst	B_ANIM,A14
	jrz	NoAnim
	callr	PULLANIM
NoAnim
	callr	PULLOBJ
	callr	DELSHAD
	calla	DELPAL

DOFREE
	;PUT OBJ ON FREE LIST
	move	@OFREECNT,A14,W	;inc obj free list count
	inc	A14		;
	move	A14,@OFREECNT,W	;

	move	@ENDOFREE,A14,L
	jrz	HdLink1
	move	A0,*A14,L
	jruc	DidLink1
HdLink1
	move	A0,@OFREE,L
DidLink1
	move	A0,@ENDOFREE,L

	rets


**************************************************************************
*								         *
* 	DELSHAD								 *
* 									 *
* 	Delete a given objects shadow.					 *
* 									 *
* 	A0 = Ptr to the object that is being shadowed.			 *
* 									 *
* 	Returns:							 *
* 									 *
* 		Nothing							 *
*								         *
**************************************************************************
DELSHAD
	move	*A0(OSHAD),A14,L
	jreq	DELSHADX 		;BR = NO SHADOW EXISTS

	PUSH	A1

	MOVE	*A0(OFLAGS),A1,W
	BTST	B_SHAD,A1    		;Is calling object a shadow?
	LOCKON	NE			;Shadows can't have shadows!

	move	*A14(OSHAD),A1,L
	cmp	A1,A0			;Do these objects belong together?
	LOCKON	NE			;Shadow doesn't belong to this object

	clr	A1
	move	A1,*A14(OSHAD),L
	move	A1,*A0(OSHAD),L

	move	A0,A1
	move	A14,A0
	CALLR	PULLPART
	callr	DELOBJ
	move	A1,A0

	PULLQ	A1
DELSHADX
	rets

**************************************************************************
*								         *
* 	PULLSHAD							 *
* 									 *
* 	Pull a given objects shadow from the display list.		 *
* 									 *
* 	A0 = Ptr to the object that is being shadowed.			 *
* 									 *
* 	Returns:							 *
* 									 *
* 		Nothing							 *
*								         *
**************************************************************************
PULLSHAD
	move	*A0(OSHAD),A14,L
	jreq	PULLSHADXX 		;BR = NO SHADOW EXISTS

	PUSH	A1

	MOVE	*A0(OFLAGS),A1,W
	BTST	B_SHAD,A1    		;Is calling object a shadow?
	LOCKON	NE			;Shadows can't have shadows!

	move	*A14(OSHAD),A1,L
	cmp	A1,A0
	LOCKON	NE

	move	*A14,A1,L		;IS SHADOW INSERTED?
	jrz	PULLSHADX

	move	A0,A1
	move	A14,A0
	callr	PULLOBJ
	move	A1,A0
PULLSHADX
	PULLQ	A1
PULLSHADXX
	rets

**************************************************************************
*								         *
* 	DELETE_SHADOW							 *
* 									 *
* 	Delete the entire shadow of an object.  Object may		 *
* 	be a single or multi parter.					 *
* 									 *
* 	A8 = Ptr to object being shadowed.				 *
*								         *
**************************************************************************
DELETE_SHADOW
	PUSH	A0
	MOVE	A8,A0
DS_LOOP
	MOVE	*A0(OFLAGS),A1,W
	BTST	B_SHAD,A1    		;Is this a shadow?
	JRNZ	DS_NXT			;BR = Yes

	CALLR	DELSHAD			;Delete shadow for this object
DS_NXT
	MOVE	*A0(OPARTS),A0,L	;Get next
	JRNZ	DS_LOOP			;Br = And there is one to do
	PULLQ	A0
	RETS

**************************************************************************
*								         *
* 	GET_SHAD							 *
* 									 *
* 	Routine to create a shadow object for a given object.		 *
* 	Shadow object is doubly linked to its parent via OSHAD.		 *
* 	Shadow object is also added as a sub-part to the parent		 *
* 	object or multi-parter.						 *
* 	Shadow is inserted on the object list.				 *
* 									 *
* 	A8 = Ptr to object that needs to be shadowed.			 *
* 									 *
* 	Returns								 *
* 		 Z = No shadow created (A0 = 0)				 *
* 		NZ = Shadow success (A0 = Ptr to shadow object)		 *
*								         *
**************************************************************************
GET_SHAD
	PUSH	A2
	MOVE	*A8(OZVAL),A2,L
	INC	A2
	CALLR	SHADOW_INIT
	JRZ	GS_X
    	MOVKB	1,*A0(OZOFF)		;We do this just in case
	MOVE	A0,A0
GS_X
	PULL	A2
	RETS

**************************************************************************
*								         *
* 	GET_SHAD_MULTI							 *
* 									 *
* 	Routine to create a shadow made of many parts, from an		 *
* 	object of many parts.  Each shadow is created to the		 *
* 	description of GET_SHAD.					 *
* 									 *
* 	A8 = Ptr to head of multi-parter				 *
* 									 *
* 	Returns								 *
* 		Z = Not all shadows created 				 *
* 	       NZ = All shadows created 				 *
*								         *
**************************************************************************
GET_SHAD_MULTI
	MMTM	SP,A2,A3,A4,A8
	CLR	A3			;This will become max OZOFF
	CLR	A4			;This will be a part counter
	MOVE	A8,A0
;First we must find the largest ZOFF of all the parts and up it 1
GSM_Z_LOOP
	MOVE	*A0(OFLAGS),A14,W
	BTST	B_SHAD,A14  		;Did we hit a previous shadow?
	JRNZ	GSM_NO_COUNT		;BR = Yes, then just skip it
	MOVB	*A0(OZOFF),A14
	CMP	A3,A14			;Is this ZOFF greater?
	JRLE	GSM_NOT_GREATER		;BR = No, let's not worry about it
	MOVE	A14,A3			;Keep it, we may use it.
GSM_NOT_GREATER
	INC	A4
GSM_NO_COUNT
	MOVE	*A0(OPARTS),A0,L
	JRNZ	GSM_Z_LOOP
	INC	A3
;Now we have the OZOFF that we want
	MOVE	*A8(OZVAL),A2,L
	MOVB	*A8(OZOFF),A14
	SUB	A14,A2
	ADD	A3,A2			;Offset for the correct Z
GSM_SHADOW_LOOP
	MOVE	*A8(OFLAGS),A14,W
	BTST	B_SHAD,A14  		;Did we hit a previous shadow?
	JRNZ	GSM_NO_CREATE		;BR = Yes, then just skip it

	CALLR	SHADOW_INIT		;Get a shadow for this part
	JRZ	GSM_X			;BR = We are out of shadows for today
	JRC	GSM_NO_SHADOW		;BR = Shadow no allowed
	MOVB	A3,*A0(OZOFF)
GSM_NO_SHADOW
	DEC	A4
	JRZ	GSM_X
GSM_NO_CREATE
	MOVE	*A8(OPARTS),A8,L
	JRNZ	GSM_SHADOW_LOOP
GSM_X
	MOVE	A0,A0
	MMFM	SP,A2,A3,A4,A8
	RETS


*
*Entrypoint: Used for shadow creation. You provide the ZVAL
*A2 = OZVAL
*Returns:
*	 Z = No shadow object could be created
*	NZ & NC = Everthing went O.K. Shadow is in A0
*	NZ &  C = No shadow created for some reason.  A0 is bogus
*
SHADOW_INIT
	MOVE	*A8(OFLAGS),A14,W	
	BTST	B_NOSHADOW,A14		;Object allowed to have a shadow?
	JRNZ	GS_NO_CREATE		;BR = No

	;Can't already have a shadow, or be a shadow
	MOVE	*A8(OSHAD),A14,L	;Do we have, or are, a shadow?
	JRNZ	GS_NO_CREATE

	callr	GETOBJ			;Grab an object
	jrz	GETSHADX		;BR = No objects left

	;INIT SHADOW OBJ

	CALLR	COPY_OBJ		;Make a copy of 'da mastah

	MMTM	SP,A1,A5

	CLR	A5
	CALLA	INC_PALCNT		;Mark use of palette 0 to remain sane

	MOVE	A5,*A0(OGUNVECT),L
	MOVE	A5,*A0(OCVECT),L

	MOVI	COLOR_BLACK,A14
	SLL	16,A14
	MOVE	A14,*A0(OPAL),L		;Shadow will be constant color

	MOVE	*A0(OCTRL),A5,W	
;	MOVE	*A0(OCTRL),A14,W
;	MOVE	A14,A5
;	SLL	28,A14			;Is the object turned on?
;	JRZ	SI_STUF_CTRL		;BR = No, just stuff as is
	
	SRL	4,A5
	SLL	4,A5
	ADDK	DMACNZ&0Fh,A5
SI_STUF_CTRL
	MOVE	A5,*A0(OCTRL),W
	
	MOVE	@YWORLD,A5,L
	MOVE	@WORLD_GRNDOFF,A14,L	
	ADD	A14,A5
	MOVE	A5,*A0(OYVAL),L		;Set this sucker on the ground

	MOVE	A2,*A0(OZVAL),L		;Stuff the given Z Position

	;Do the initial scaling in case the object doesn't move in Z

	MOVI	10000H,a5		;10000h
	MOVE	*A0(OSCALEY),A1,W
	SLL	SLL_SHADOW,A1		;Shrink it another 75% in Y
	MOVE	A1,*A0(OSCALEY),W	;Need to make sure this changes
	DIVU	A1,A5			;Inverse of Y scale in A5

	MOVE	*A0(OUSIZEY),A1,W
	MPYU	a5,a1			;Scale the Y size, result in A1
	SRL	8,A1
	MOVE	A1,*A0(OSIZEY),W

	MOVE	*A0(OUANIOFFY),A1,W
	MPYS	A5,A1			;Scale the Y animation pnt
	SRA	8,a1
	MOVE	A1,*A0(OANIOFFY),W

	MMFM	SP,A1,A5

	;STUFF FLAGS FOR SHAD
	move	*A0(OFLAGS),A14,W
	ori	M_SHAD,A14
	move	A14,*A0(OFLAGS),W

	;I.D. PLEASE
	MOVIM	OID_SHAD,*A0(OID),W

	;DOUBLY LINK OSHADS
	move	A8,*A0(OSHAD),L
	move	A0,*A8(OSHAD),L

	;LINK SHADOW TO PARENT AS MULTI-PARTER
	callr	INSPART

	callr	INSOBJ

	MOVE	A0,A0			;Set return flags
	CLRC
GETSHADX
	rets
*
*Z must be set here
*
GS_NO_CREATE
	SETC				;Flag the failure
	RETS

;6/17
**************************************************************************
*								         *
* FPSTFOBJ0								 *
* FIND PAL AND THEN..							 *
* STFOBJ0								 *
* INIT OBJ W/ STARTING FRAME						 *
* A0 = PTR TO THE OBJ							 *
* A1 = PTR TO 1st Frame							 *
* 									 *
* 	  Z = FAILURE IN SOME WAY OR ANOTHER.				 *
*        NZ = SUCCESS							 *
*								         *
**************************************************************************
FPSTFOBJ0:
	PUSH	A2
	move	A0,A2
	move	*A1(ICMAP),A0,L
	calla	GETFPAL
	JRNZ	STFOBJ_PAL		;BR = WE HAVE PALETTE!
	MOVE	A2,A0			;ERROR CONDITION, RESTORE OBJECT
	SETZ				;Z TO FLAG ERROR
	JRUC	STFOBJX			;RETURN
STFOBJ_PAL
	move	A0,*A2(OPAL),W
	move	A2,A0
	jruc	STFOBJE
STFOBJ0
	PUSH	A2
STFOBJE
	move	A1,*A0(OIMG),L

;*A0(OIHOFF) IS ZERO.
;	move	*a0(OIHOFF),a14	
;	add	a14,a1		

	move	*A1(ISIZE),A14,L
	move	A14,*A0(OSIZE),L
	MOVE	A14,*A0(OUSIZE),L
	move	*A1(ISAG),*A0(OSAG),L
	MOVE	*A1(ICTRL),*A0(OCTRL),W

	MOVE	*A1(IANIOFF),A14,L
	MOVE	A14,*A0(OANIOFF),L
	move	A14,*A0(OUANIOFF),L
	clr	a14
	move	A14,*A0(OPARTSXY),L

	MOVI	01000100H,A14
	MOVE	A14,*A0(OSCALE),L
	sll	1,a14
	move	a14,*a0(ODAG),L		; place offscreen

	MOVE	A0,A0
STFOBJX
	PULL	A2
	RETS

****************************************************************************
* CFUNCS (creation funcs) for MULTIMAKE
****************************************************************************

**************************************************************************
*								         *
* C_SET_GUNVECT								 *
* 									 *
* THE FOLLOWING STUFFS THE OGUNVECT FIELD.				 *
* 									 *
* REQUIRES:								 *
* 									 *
* .LONG	GUN VECTOR							 *
*								         *
**************************************************************************

C_SET_GUNVECT
	MOVE	*B0+,B14,L
	MOVE	B14,A14
	MOVE	A14,*A0(OGUNVECT),L
	RETS

**************************************************************************
*								         *
* C_SET_SCRNOBJ								 *
*								         *
* THE FOLLOWING SETS UP A SINGLE SCREEN OBJECT.				 *
* 									 *
* REQUIRES:								 *
* 									 *
* .WORD	X POSITION							 *
* .WORD	Y POSITION							 *
* .WORD	Z POSITION 							 *
*								         *
**************************************************************************

C_SET_SCRNOBJ
	MOVE	*B0+,B14,L
	MOVE	B14,A1			;[Y,X] POSITION
	MOVE	*A0(OANIOFF),A14,L
	SUBXY	A14,A1
	MOVE	A1,*A0(ODAG),L
	MOVE	A1,*A0(OXPOS),W
	SRL	16,A1
	MOVE	A1,*A0(OYPOS),W
	MOVE	*B0+,B14,W		;Z INTEGER POSITION
	MOVE	B14,A1
	MOVE	A1,*A0(OZPOS),W
	RETS


****************************************************************************
* C_GETPRC
* MULTIMAKE CFUNC - GET A PROCESS AND LINK IT TO THE OBJECT JUST MADE
* REQUIRES
*  .word  PROCID
*  .long  WAKEUP
* After CFUNC entry of MULTIMAKE script
C_GETPRC
	move	*B0+,B14,W	;PROCID
	move	B14,A1
	move	*B0+,B14,L	;WAKEUP
	move	B14,A7
	PUSH	A8
	move	A0,A8
	calla	GETPRC
	move	A0,*A8(OPLINK),L
	PULLQ	A8
	rets

****************************************************************************
* C_ANIM
* MULTIMAKE CFUNC - PUT OBJ JUST MADE ON ANIM
*
* REQUIRES
*  .long  ANIM_INIT_TABLE w/ format of
* After CFUNC entry of MULTIMAKE script
C_ANIM
	move	*B0+,B14,L	;ANIM_INIT_TABLE
	move	B14,A1
	callr	STFANIM
	rets

**************************************************************************
*								         *
* C_STRTANIM - OBJECT CREATE CFUNC TO DO A QUICK START OF AN ANIM.	 *
* 		CLEARS STUFFS SCRIPT AND LOOP BACK THE SAME. CLEARS	 *
* 		ANISLP.							 *
* REQUIRES								 *
* 	.LONG	ANIM SCRIPT PTR						 *
*								         *
**************************************************************************
C_STRTANIM		
	MOVE	*B0+,B14,L
	MOVE	B14,A1
	CALLR	STRTANIM
	RETS
**************************************************************************
*								         *
* C_STRTANIM_GUNVECT - START AN ANIMATION AND STUFF A GUN VECTOR	 *
* 									 *
* REQUIRES:								 *
* .LONG	ANIM SCRIPT PTR, GUN VECTOR					 *
*								         *
**************************************************************************
C_STRTANIM_GUNVECT
	CALLR	C_STRTANIM
	JRUC	C_SET_GUNVECT

**************************************************************************
*								         *
* SET_FLPS - SET THE FLIP BITS OF ALL OBJECTS IN A MULTI-PARTER.	 *
* A8 ptr to HEAD OBJ of MULTI-PARTER					 *
* A0 New flip bits							 *
*								         *
**************************************************************************
SET_FLPS
	mmtm	SP,A4,A8
FlpLp
	move	*A8(OCTRL),A4,L
	andni	M_FLIPH|M_FLIPV,A4
	or	A0,A4
	CALLR	SET_OCTRL_OPARTSXY
	move	*A8(OPARTS),A8,L
	jrnz	FlpLp
	mmfm	SP,A4,A8

	MMTM	SP,A1,A2,A3
	CALLR	SET_OBJSU
	MMFM	SP,A1,A2,A3
	rets

**************************************************************************
*								         *
* TOGGLE_FLPS - ROUTINE TO TOGGLE THE SPECIFIED FLIP BITS OF AN OBJECT.	 *
* A0 = FLIP BITS TO TOGGLE						 *
* A8 = PTR TO HEAD OBJECT OF MULTI-PARTER				 *
*								         *
**************************************************************************
TOGGLE_FLPS
	MMTM	SP,A4,A8
TF_LP
	MOVE  	*A8(OCTRL),A4,W
	XOR	A0,A4
	CALLR	SET_OCTRL_OPARTSXY
	MOVE	*A8(OPARTS),A8,L
	JRNZ	TF_LP
	MMFM	SP,A4,A8

	MMTM	SP,A1,A2,A3
	CALLR	SET_OBJSU
	MMFM	SP,A1,A2,A3
	rets

**************************************************************************
*								         *
* SET_FLIP - SET THE FLIP BITS OF ONE OBJECT.				 *
* A8 = PTR TO OBJECT							 *
* A0 = NEW FLIP BITS							 *
*								         *
**************************************************************************
SET_FLIP
	PUSH	A4
	MOVE	*A8(OCTRL),A4,L
	ANDNI	M_FLIPH|M_FLIPV,A4
	OR	A0,A4
	CALLR	SET_OCTRL_OPARTSXY
	PULLQ	A4
	RETS

**************************************************************************
*								         *
* TOGGLE_FLIP - ROUTINE TO TOGGLE THE SPECIFIED FLIP BITS OF AN OBJECT.	 *
* A0 = FLIP BITS TO TOGGLE						 *
* A8 = PTR TO OBJECT							 *
*								         *
**************************************************************************
TOGGLE_FLIP
	PUSH	A4
	MOVE	*A8(OCTRL),A4,L
	XOR	A0,A4
	CALLR	SET_OCTRL_OPARTSXY
	PULLQ	A4
	RETS


**************************************************************************
*								         *
* SET_OCTRL_OPARTSXY - SET NEW OCTRL AND ADJUST OPARTSXY FOR FLIPPING	 *
* PASS:									 *
* A4 = NEW OCTRL							 *
* RETURNS:								 *
* NUTIN'								 *
*								         *
**************************************************************************

SET_OCTRL_OPARTSXY
	PUSH	A0
	move	*A8(OCTRL),A0,W
	xor	A4,A0
	btst	B_FLIPH,A0
	jrz	SOO_NOX

	move	*A8(OPARTSXY),A14,W
	NEG	A14
	move	A14,*A8(OPARTSXY),W
SOO_NOX
	btst	B_FLIPV,A0
	jrz	SOO_NOY

	move	*A8(OPARTSXY+010H),A14,W
	NEG	A14
	move	A14,*A8(OPARTSXY+010H),W
SOO_NOY
	MOVE	A4,*A8(OCTRL),W
	PULLQ	A0
	RETS



****************************************************************************
* CNTRANIP
* Stuff ANIOFF W/ center point of object
* A0 = OBJ
CNTRANIP
	move	*A0(OSIZEX),A14,W
	srl	1,A14
	move	A14,*A0(OANIOFFX),W
	move	*A0(OSIZEY),A14,W
	srl	1,A14
	move	A14,*A0(OANIOFFY),W
	rets


**************************************************************************
* GETANIXY
* GET THE X AND Y POSITIONS OF AN OBJECTS ANIMATION PT.
* A8 = OBJ
* RETS	A2=ANI OYPOS (16), A3=ANI OXPOS (16)
GETANIXY
	move	*A8(OYPOS),A2,W
	sll	16,A2
	move	*A8(OXPOS),A3,W
	movx	A3,A2
	move	*A8(OANIOFF),A3,L
	addxy	A3,A2
	move	A2,A3
	sra	16,A2
	sext	A3,W
	rets

**************************************************************************
* GETANIXYL
* GET THE X AND Y LONG POSITIONS OF AN OBJECTS ANIMATION PT.
* A8 = OBJ
* RETS	A2=ANI OYPOS (16.16), A3=ANI OXPOS (16.16)
GETANIXYL
	move	*A8(OANIOFFX),A14,W
	sll	16,A14
	move	*A8(OXVAL),A3,L
	add	A14,A3
	move	*A8(OANIOFFY),A14,W
	sll	16,A14
	move	*A8(OYVAL),A2,L
	add	A14,A2
	rets

**************************************************************************
* GETANIXL
* GET THE X ANIMATION PT OF AN OBJ (16.16).
* A8 = OBJ
* RETS	A0=ANI OXPOS (16.16)
GETANIXL
	move	*A8(OXVAL),A0,L
	move	*A8(OANIOFFX),A14,W
	sll	16,A14
	add	A14,A0
	rets

**************************************************************************
* GETANIX
* GET ANIMATION POINT X COOR (16)
* A8 = OBJ
* RETS	A0=ANI OXPOS (16)
GETANIX
	move	*A8(OXPOS),A0,W
	move	*A8(OANIOFFX),A14,W
	add	A14,A0
	rets

**************************************************************************
* GETANIYL
* GET THE Y ANIMATION PT OF AN OBJ (16.16).
* A8 = OBJ
* RETS	A0=ANI OYPOS (16.16)
GETANIYL
	move	*A8(OYVAL),A0,L
	move	*A8(OANIOFFY),A14,W
	sll	16,A14
	add	A14,A0
	rets

**************************************************************************
* GETANIY
* GET ANIMATION POINT Y COOR (16)
* A8 = OBJ
* RETS	A0=ANI OYPOS (16)
GETANIY
	move	*A8(OYPOS),A0,W
	move	*A8(OANIOFFY),A14,W
	add	A14,A0
	rets

**************************************************************************
* MATCHOPARTSXY
* Parms
* A8 ptr to BASE OBJ
* A0 ptr to obj which is to have its OPARTSXY set so that its offset pt
* is at the same point as the BASE OBJ
MATCHOPARTSXY
	PUSH	A1
	move	*A8(OPARTSXY),A1,W
	move	*A0(OXPOS),A14,W
	sub	A14,A1
	move	*A8(OXPOS),A14,W
	add	A14,A1
	move	A1,*A0(OPARTSXY),W

	move	*A8(OPARTSXY+010h),A1,W
	move	*A0(OYPOS),A14,W
	sub	A14,A1
	move	*A8(OYPOS),A14,W
	add	A14,A1
	move	A1,*A0(OPARTSXY+010h),W
	PULLQ	A1
	rets

**************************************************************************
* MATCHANIP
* Parms
* A8 ptr to BASE OBJ
* A0 ptr to obj which is to have its position set so that its anim pt
* is at the same coors as the BASE OBJ
MATCHANIP:
	PUSH	A1
	move	*A8(OANIOFF),A1,L
	move	*A0(OANIOFF),A14,L
	subxy	A14,A1
	move	*A8(OYPOS),A14,W
	rl	16,A1
	addxy	A1,A14
	move	A14,*A0(OYPOS),W
	rl	16,A1

	move	*A8(OXPOS),A14,W
	addxy	A1,A14
	move	A14,*A0(OXPOS),W

	;UPDATE FRACTIONAL PORTIONS TOO!
	move	*A8(OXVAL),*A0(OXVAL),W
	move	*A8(OYVAL),*A0(OYVAL),W
	PULLQ	A1
	rets

**************************************************************************
* GETANIP
* A0 PTR TO OBJ
* RETURNS  A1 = Y:X ANI POINT
GETANIP:
	MOVE	*A0(ODAG),A1,L
	move	*A0(OANIOFF),A14,L
	addxy	A14,A1
	rets

**************************************************************************
* GET_ANIP
* A8 PTR TO OBJ
* RETURNS  A1 = Y:X ANI POINT
GET_ANIP:
	MOVE	*A8(ODAG),A1,L
	move	*A8(OANIOFF),A14,L
	addxy	A14,A1
	rets

**************************************************************************
*								         *
* GET_ANIP_SCRNREL - ROUTINE TO GET THE SCREEN RELATIVE ANIMATION POINT	 *
* 			OF AN OBJECT.					 *
* A8 PTR TO OBJ								 *
* RETURNS  A1 = Y:X SCREEN RELATIVE ANI POINT				 *
*								         *
**************************************************************************
GET_ANIP_SCRNREL:
	PUSH	A2
	CALLR	GET_SCRNREL
	SRL	16,A1
	MOVY	A2,A1
	MOVE	*A8(OANIOFF),A14,L
	ADDXY	A14,A1
	PULLQ	A2
	RETS

**************************************************************************
*								         *
* GETANIP_SCRNREL - ROUTINE TO GET THE SCREEN RELATIVE ANIMATION POINT	 *
* 			OF AN OBJECT (A0 VERSION)			 *
* A0 = PTR TO OBJECT							 *
* RETURNS								 *
* 	A1 = Y:X SCREEN RELATIVE ANI POINT				 *
*								         *
**************************************************************************
GETANIP_SCRNREL
	PUSH	A8
	MOVE	A0,A8
	CALLR	GET_ANIP_SCRNREL
	PULLQ	A8
	RETS

**************************************************************************
*								         *
* ADD_OFF2ANIP - ROUTINE TO ADD A GIVEN OFFSET TO THE ANIMATION PNT	 *
* 		OF AN OBJECT, AND RETURN THAT POINT.  FLIPS ARE		 *
* 		ACCOUNTED FOR.						 *
* A4 = [Y,X] OFFSET POINT						 *
* A8 = PTR TO OBJECT WE ARE OFFSETING FROM				 *
* RETURNS								 *
* 	A3 = [Y,X] POINT						 *
*								         *
**************************************************************************
ADD_OFF2ANIP
	MMTM	SP,A1,A4
	MOVE	*A8(OCTRL),A1,W		;ADJUST LAUNCH OFFSET IF NECESSARY
	BTST	B_FLIPH,A1
	JREQ	AO_CKV
	NEGX	A4
AO_CKV
	BTST	B_FLIPV,A1
	JREQ	AO_OFF
	NEGY	A4
AO_OFF
	CALLA	GET_ANIP
	MOVE	A1,A3
	ADDXY	A4,A3
	MMFM	SP,A1,A4
	RETS

**************************************************************************
* GETOFFP
* Get object's position using offset point.
* Uses OPARTSXY if M_OPARTSXY of OFLAGS2 set.
* Else uses OANIOFF (GETANIP).
* A0 OBJ
* RETURNS  A1 = Y:X OBJECT OFFSET POINT
GETOFFP:
	movb	*A0(OFLAGS+B_OPARTSXY-7),A14
	jrnn	GETANIP

	;USE OPARTSXY
	move	*A0(OYPOS),A1,W
	sll	16,A1
	move	*A0(OXPOS),A14,W
	movx	A14,A1
	move	*A0(OPARTSXY),A14,L
	addxy	A14,A1
	rets

**************************************************************************
* SET_OPARTSXY
* A8 obj
* A1 OPARTSXY OFFSET
* ADJUSTS OFFSET FOR CURRENT FLIP
SET_OPARTSXY
	PUSH	A0
	move	A8,A0
	callr	SETOPARTSXY
	PULLQ	A0
	rets

**************************************************************************
*								         *
* 	SETOPARTSXY							 *
* 									 *
* 	Set the OPARTSXY field of an object to the given values.	 *
* 	Adjusts for current flip.					 *
* 									 *
* 	A0 = Ptr to object						 *
* 	A1 = New OPARTSXY						 *
* 									 *
* 	Returns:							 *
* 		A1 = *A0(OPARTSXY),L = New OPARTSXY, flip adjusted	 *
*								         *
**************************************************************************
SETOPARTSXY:
	movb	*A0(OCTRL+B_FLIPH-7),A14
	jrnn	SkHFlpOf
	NEGX	A1
SkHFlpOf
	movb	*A0(OCTRL+B_FLIPV-7),A14
        jrnn	SkVFlpOf
	NEGY	A1
SkVFlpOf
	move	A1,*A0(OPARTSXY),L
	rets

**************************************************************************
* GET_OFFP
* Get object's position using offset point.
* Uses OPARTSXY if M_OPARTSXY of OFLAGS2 set.
* Else uses OANIOFF (GETANIP).
* A8 OBJ
* RETURNS  A1 = Y:X OBJECT OFFSET POINT
GET_OFFP:
	PUSH	A0
	move	A8,A0
	callr	GETOFFP
	PULLQ	A0
	rets
	
**************************************************************************
* SETANIP
* SET OBJ POSITION SO ANIPT IS ON A POINT.
*
* A1 = Y:X POINT
* A0 = PTR TO OBJECT
SETANIP:
	PUSH	A1
	move	*A0(OANIOFF),A14,L
	subxy	A14,A1
	move	A1,*A0(OXPOS),W
	srl	16,A1
	move	A1,*A0(OYPOS),W
	PULLQ	A1
	rets

**************************************************************************
*								         *
* SET_ANIXP - SET OBJ POSITION SO ANIPT IS ON AN X POINT.		 *
* 	    WILL ADJUST ENTIRE MULTI-PARTER.				 *
* A1 = X POINT								 *
* A8 = PTR TO OBJECT							 *
* RETURNS								 *
* 	A1 = [Y,X] WORLD ANIMATION POINT				 *
*								         *
**************************************************************************
SET_ANIXP:
	PUSH	A0
	callr	GETANIY	;A0 ANI OYPOS
	sll	16,A0
	movy	A0,A1
	jruc	SET_ANIPe

**************************************************************************
*								         *
* SET_ANIYP - SET OBJ POSITION SO ANIPT IS ON A Y POINT.		 *
* 	    WILL ADJUST ENTIRE MULTI-PARTER.				 *
* A1 = Y POINT								 *
* A8 = PTR TO OBJECT							 *
* RETURNS								 *
* 	A1 = [Y,X] WORLD ANIMATION POINT				 *
*								         *
**************************************************************************
SET_ANIYP:
	PUSH	A0
	CALLR	GETANIX		;A0 ANI OXPOS
	SLL	16,A1
	MOVX	A0,A1
	JRUC	SET_ANIPe

**************************************************************************
* SET_ANIP
* SET OBJ POSITION SO ANIPT IS ON A POINT.
* WILL ADJUST ENTIRE MULTI-PARTER.
*
* A1 = Y:X POINT
* A8 = PTR TO OBJECT
SET_ANIP:
	PUSH	A0
SET_ANIPe
	move	A8,A0
	callr	SETANIP
	callr	SETOBJS
	PULLQ	A0
	rets

**************************************************************************
* MATCHOFFP
* Parms
* A8 ptr to BASE OBJ
* A0 ptr to obj which is to have its position set so that its anim pt
* is at the same coors as the BASE OBJ
MATCHOFFP:
	PUSH	A1
	callr	GET_OFFP
	callr	SETOFFP

	;UPDATE FRACTIONAL PORTIONS TOO!
	move	*A8(OXVAL),*A0(OXVAL),W
	move	*A8(OYVAL),*A0(OYVAL),W
	PULLQ	A1
	rets

**************************************************************************
* SETOFFP
* Set object's position using offset point.
* Uses OPARTSXY if M_OPARTSXY of OFLAGS2 set.
* Else uses OANIOFF (SETANIP).
* A0 OBJ
* A1 = Y:X OBJECT OFFSET POINT
* RETURNS nothing
SETOFFP:
	movb	*A0(OFLAGS+B_OPARTSXY-7),A14
	jrnn	SETANIP

	PUSH	A1
	;USE OPARTSXY
	move	*A0(OPARTSXY),A14,L
	subxy	A14,A1
	move	A1,*A0(OXPOS),W
	srl	16,A1
	move	A1,*A0(OYPOS),W
	PULLQ	A1
	rets

**************************************************************************
* SET_OFFP
* Set object's position using offset point.
* Uses OPARTSXY if M_OPARTSXY of OFLAGS2 set.
* Else uses OANIOFF (SETANIP).
* A8 OBJ
* A1 = Y:X OBJECT OFFSET POINT
* RETURNS nothing
SET_OFFP:
	PUSH	A0
	move	A8,A0
	callr	SETOFFP
	callr	SETOBJS
	PULLQ	A0
	rets


**************************************************************************
SET_OBJS:
;UPDATE POS AMONG PARTS OF A MULTI-PART OBJ
;A8 ptr to an obj
	mmtm	SP,A0,A1,A8
	jruc	SetObjE
SETOBJS:
;UPDATE POS AMONG PARTS OF A MULTI-PART OBJ
;A0 ptr to an obj
	mmtm	SP,A0,A1,A8
	move	A0,A8

SetObjE
	callr	GET_OFFP		;A1 OBJ OFFSET OF A8
	move	*A8(OPART1),A0,L
	jruc	Part1

PartsLp:
	move	*A0(OPARTS),A0,L
Part1:
	jrz	PartsX
	cmp	A0,A8
	jreq	PartsLp

	;* UPDATE THE POSITIONS
	callr	SETOFFP
	;UPDATE FRACTIONAL PORTIONS TOO!
	move	*A8(OXVAL),*A0(OXVAL),W
	move	*A8(OYVAL),*A0(OYVAL),W
	jruc	PartsLp

PartsX:
	mmfm	SP,A0,A1,A8
	rets
**************************************************************************


**************************************************************************
**************************************************************************
**************************************************************************

**************************************************************************
*								         *
* SET_ANIPXU								 *
* SET OBJ POSITION'S X ANIMATION POINT IN THE UNIVERSE			 *
* WILL ADJUST ENTIRE MULTI-PARTER					 * 									 *
*								         *
* PASS:									 *
* A1 = UNIVERSE X							 *
* A8 = OBJECT (HEAD OR PART)						 *
*								         *
**************************************************************************
SET_ANIPXU
	MMTM	SP,A2,A3
	MOVE	*A8(OYVAL),A2,L
	MOVE	*A8(OZVAL),A3,L
	CALLR	SET_ANIPU
	MMFM	SP,A2,A3
	RETS

**************************************************************************
*								         *
* SET_ANIPYU								 *
* SET OBJ POSITION'S Y ANIMATION POINT IN THE UNIVERSE			 *
* WILL ADJUST ENTIRE MULTI-PARTER					 * 									 *
*								         *
* PASS:									 *
* A1 = UNIVERSE Y							 *
* A8 = OBJECT (HEAD OR PART)						 *
*								         *
**************************************************************************
SET_ANIPYU
	MMTM	SP,A1,A2,A3
	MOVE	A1,A2
	MOVE	*A8(OXVAL),A1,L
	MOVE	*A8(OZVAL),A3,L
	CALLR	SET_ANIPU
	MMFM	SP,A1,A2,A3
	RETS

**************************************************************************
*								         *
* SET_ANIPZU								 *
* SET OBJ POSITION'S Z ANIMATION POINT IN THE UNIVERSE			 *
* WILL ADJUST ENTIRE MULTI-PARTER					 * 									 *
*								         *
* PASS:									 *
* A1 = UNIVERSE Z							 *
* A8 = OBJECT (HEAD OR PART)						 *
*								         *
**************************************************************************
SET_ANIPZU
	MMTM	SP,A1,A2,A3
	MOVE	A1,A3
	MOVE	*A8(OXVAL),A1,L
	MOVE	*A8(OYVAL),A2,L
	CALLR	SET_ANIPU
	MMFM	SP,A1,A2,A3
	RETS

**************************************************************************
*								         *
* SET_ANIPU								 *
* SET OBJ POSITION'S ANIMATION POINT IN THE UNIVERSE			 *
* WILL ADJUST ENTIRE MULTI-PARTER					 * 									 *
*								         *
* PASS:									 *
* A1 = UNIVERSE X							 *
* A2 = UNIVERSE Y							 *
* A3 = UNIVERSE Z							 *
* A8 = OBJECT (HEAD OR PART)						 *
*								         *
**************************************************************************
SET_ANIPU
	PUSH	A0
	MOVE	A8,A0
	callr	SETOFFPU
	move	*A8(OPART1),A0,L
	JRUC	Part1U

**************************************************************************
SET_OBJSU
;UPDATE POS AMONG PARTS OF A MULTI-PART OBJ
;A8 ptr to an obj
	PUSH	A0
	callr	GET_OFFPU		;A1 OBJ OFFSET OF A8
	move	*A8(OPART1),A0,L
	jruc	Part1U
PartsLpU
	move	*A0(OPARTS),A0,L
Part1U
	jrz	PartsXU
	cmp	A0,A8
	jreq	PartsLpU
	;* UPDATE THE POSITIONS
	callr	SETOFFPU
	jruc	PartsLpU
PartsXU
	PULLQ	A0
	rets
SETOBJSU
;UPDATE POS AMONG PARTS OF A MULTI-PART OBJ
;A0 ptr to an obj
	MMTM	SP,A1,A2,A3,A8
	move	A0,A8
	CALLR	SET_OBJSU
	MMFM	SP,A1,A2,A3,A8
	RETS
**************************************************************************

**************************************************************************
*								         *
* SETOFFPU								 *
* Set object's position in the UNIVERSE using offset point.		 *
* Uses OPARTSXY if M_OPARTSXY of OFLAGS set.				 *
*								         *
* PASS:									 *
* A0 = OBJECT								 *
* A1 = UNIVERSE X							 *
* A2 = UNIVERSE Y							 *
* A3 = UNIVERSE Z							 *
*								         *
**************************************************************************
SETOFFPU
	move	*A0(OPARTSXY),A14,L
	JRZ	SETOFFPU_NOPARTSXY		;BR=NO OPARTSXY
	;USE OPARTSXY
	PUSH	A4
	MOVE	A14,A4

	SEXT	A14,W
	SLL	15,A14
	ADD	A1,A14
	move	A14,*A0(OXVAL),L

	MOVE	*A0(OFLAGS),A14,W
	BTST	B_SHAD,A14		;Is this a shadow object?
	JRNZ	SOFFP_SKIPY		;BR = Yes, don't fuck with Y

	SRA	16,A4
	SLL	15,A4
	ADD	A2,A4
	move	A4,*A0(OYVAL),L
SOFFP_SKIPY

	MOVB	*A0(OZOFF),A14	
	ADD	A3,A14
	move	A14,*A0(OZVAL),L

	PULLQ	A4
	rets
SETOFFPU_NOPARTSXY
	move	A1,*A0(OXVAL),L
	MOVE	*A0(OFLAGS),A14,W
	BTST	B_SHAD,A14		;Is this a shadow object?
	JRNZ	SOFFPNP_SKIPY		;BR = Yes, don't fuck with Y
	move	A2,*A0(OYVAL),L
SOFFPNP_SKIPY
	MOVB	*A0(OZOFF),A14	
	ADD	A3,A14
	move	A14,*A0(OZVAL),L
	RETS

**************************************************************************
*								         *
* SETANIPU								 *
* SET OBJ POSITION'S ANIMATION POINT IN THE UNIVERSE			 *
* 									 *
* PASS:									 *
* A0 = OBJECT								 *
* A1 = UNIVERSE X							 *
* A2 = UNIVERSE Y							 *
* A3 = UNIVERSE Z							 *
*								         *
**************************************************************************
SETANIPU
	move	A1,*A0(OXVAL),L
	move	A2,*A0(OYVAL),L
	move	A3,*A0(OZVAL),L
	rets

**************************************************************************
* GET_ANIPU
* GET_OFFPU
* Get object's UNIVERSE position (USES OPARTSXY IF SET IN OFLAGS)
* A8 OBJ
* RETURNS
* A1 = UNIVERSE X							 *
* A2 = UNIVERSE Y							 *
* A3 = UNIVERSE Z							 *
GET_ANIPU:
GET_OFFPU:
	PUSH	A0
	move	A8,A0
	callr	GETOFFPU
	PULLQ	A0
	rets

**************************************************************************
* GETANIPU
* GETOFFPU
* Get object's UNIVERSE position (USES OPARTSXY IF SET IN OFLAGS)
* A0 OBJ
* RETURNS
* A1 = UNIVERSE X							 *
* A2 = UNIVERSE Y							 *
* A3 = UNIVERSE Z							 *
GETANIPU:
GETOFFPU:
	move	*A0(OXVAL),A1,L
	move	*A0(OYVAL),A2,L
	move	*A0(OZVAL),A3,L
	MOVB	*A0(OZOFF),A14
	SUB	A14,A3

;	movb	*A0(OFLAGS+B_OPARTSXY-7),A14
;	jrnn	GET_U_DONE

	move	*A0(OPARTSXY),A14,L
	JRZ	GET_U_DONE			;BR=NO OPARTSXY	

	PUSH	A4
	MOVE	A14,A4
	SEXT	A14,W
	SLL	15,A14
	SUB	A14,A1

	SRA	16,A4
	SLL	15,A4
	SUB	A4,A2
	PULLQ	A4

GET_U_DONE
	rets

**************************************************************************
**************************************************************************
**************************************************************************


**************************************************************************
* INITPART
* Makes obj a multi-parter w/ self
* A8 = OBJ to be made the head object of a multi-parter
INITPART
	clr	A14
	move	A14,*A8(OPARTS),L
	move	A8,*A8(OPART1),L
	rets

**************************************************************************
*								         *
* CNTMPART - COUNT THE NUMBER OF PARTS CONTAINED IN THIS		 *
* 		MULTI-PARTER. RETURNS 0 IF NOT A MULTI-PARTER.		 *
* A0 = PTR TO ANY PART							 *
* RETURNS								 *
* 	 Z = NOT A MULTI-PARTER						 *
* 		A1 = 0							 *
* 	NZ = MULTI-PARTER						 *
* 		A1 = NUMBER OF PARTS					 *
*								         *
**************************************************************************
CNTMPART:
	PUSH	A0
	clr	A1
	move	*A0(OPART1),A0,L
	jrz	CntPartsX
CntParts:
	inc	A1
	move	*A0(OPARTS),A0,L
	jrnz	CntParts
CntPartsX
	MOVE	A1,A1
	PULL	A0
	rets
**************************************************************************

**************************************************************************
* INSPART
* A0 ptr to an obj (or multi-parter) to be added to a multi-parter
* A8 obj to be head or obj in a multiparter, which contains head obj
INSPART:
	mmtm	SP,A0,A1,A2,A3,A8
	move	*A8(OPART1),A1,L
	jrnz	SkMkHd
	callr	INITPART
	jruc	IGotHd
SkMkHd
	move	A1,A8
IGotHd
	.IF	DEBUG
	callr	CkMPART
	.ENDIF

	move	*A8(OPART1),A1,L
	move	*A0(OPART1),A2,L
	jrnz	InsParts
	move	A0,A2

InsParts
	;*** ADD A LIST OF OBJS TO ANOTHER LIST ***
	move	A2,A3
InsPLp
	move	A2,A0
	move	A1,*A0(OPART1),L
	move	*A0(OPARTS),A2,L
	jrnz	InsPLp
*THIS MAKES ANY NEWLY INSERTED PARTS GO TO THE END OF THE MULTI-PARTER
INS_TO_END_LP
	MOVE	A1,A2				;KEEP PREVIOUS PART
	MOVE	*A1(OPARTS),A1,L		;ANY MORE PARTS?
	JRNZ	INS_TO_END_LP			;BR = YES
****	move	*A1(OPARTS),*A0(OPARTS),L
****	move	A3,*A1(OPARTS),L
	MOVE	A3,*A2(OPARTS),L		;WE KNOW WE'RE AT THE END

	.IF	DEBUG
	callr	CkMPART
	.ENDIF

	mmfm	SP,A0,A1,A2,A3,A8
	rets
**************************************************************************

**************************************************************************
* CkMPART1
* Checks if obj is part of invalid multi-parter
* checks that obj is valid head obj
*
* A8 = OBJ to be checked
CkMPART1
	mmtm	SP,A6,A7,A8
	move	*A8(OPART1),A7,L
	jrz	CkMPARTX
	cmp	A8,A7
	LOCKON	NZ
	jruc	CkMPARTE
**************************************************************************
* CkMPART
* Checks if obj is part of invalid multi-parter
*
* A0 = OBJ to be checked
CkMPART:
	mmtm	SP,A6,A7,A8
	move	*A0(OPART1),A7,L
	jrz	CkMPARTX		;NOT IN MULTI-PARTER -> OK
CkMPARTE:
	move	A7,A8
CkMPLp
	move	*A8(OPART1),A6,L
	cmp	A6,A7
	LOCKON	NE
	move	*A8(OPARTS),A8,L
	jrnz	CkMPLp
CkMPARTX
	mmfm	SP,A6,A7,A8
	rets

**************************************************************************
* PULL_PART
* REMOVE OBJ FROM A MULTI PARTER
* A8 = piece of a multi-part obj
* PULLPART
* A0 = piece of a multi-part obj
PULL_PART:
	PUSH	A0
	move	A8,A0
	callr	PULLPART
	PULLQ	A0
	rets
PULLPART:
;A0 ptr to a piece of a multi-part obj
	PUSH	A2
	move	*A0(OPART1),A14,L
	LOCKON	Z
	cmp	A14,A0		;CAN'T USE TO PULL HEAD
	LOCKON	EQ
	callr	CkMPART

FindPrev
	move	A14,A2
	move	*A2(OPARTS),A14,L
	LOCKON	Z
	jrz	PullPrtX
	cmp	A14,A0
	jrne	FindPrev

	;*** GOT THE PTR TO THE PREVIOUS OBJ IN A2
	move	*A0(OPARTS),*A2(OPARTS),L	;link around A0

	move	*A0(OPART1),A14,L
	move	*A14(OXVEL),*A0(OXVEL),L
	move	*A14(OYVEL),*A0(OYVEL),L
	move	*A14(OZVEL),*A0(OZVEL),L
	clr	A14
	move	A14,*A0(OPART1),L
	move	A14,*A0(OPARTS),L

PullPrtX
	PULLQ	A2
	rets

**************************************************************************
* PULL_PART1
* PULLS HEAD OBJ FROM MULTI-PARTER, MAKES NEXT OBJ NEW HEAD
* A8 = Head obj of a multi-part obj
* RETS A0 new Head Obj
PULL_PART1:
	PUSH	A2
	.IF DEBUG
	callr	CkMPART1
	.ENDIF
	move	A8,A0

	move	*A0(OPARTS),A14,L
	jrz	NoPull1
	move	A14,A2
HdLnks
	move	A14,*A2(OPART1),L
	move	*A2(OPARTS),A2,L
	jrnz	HdLnks

NoPull1
	clr	A2
	move	A2,*A0(OPART1),L
	move	A2,*A0(OPARTS),L

	move	A14,A0
	PULL	A2
	rets

****************************************************************************
* FINDPART
* A1 # of part to be found
* A8 ptr to obj in multiparter
* RETS A0 if part found, Z set if not
FINDPART:
	andi	0FFh,A1
	move	*A8(OPART1),A0,L
FindMPLp
	movb	*A0(OPARTID),A14
	andi	0FFh,A14
	cmp	A14,A1
	jreq	FoundMP
	move	*A0(OPARTS),A0,L
	jrnz	FindMPLp
FoundMP
	move	A0,A0
	rets

**************************************************************************
*								         *
* 	EXIST_PART							 *
* 									 *
* 	Search for an object of certain OID contained in a		 *
* 	multi-parter.							 *
* 									 *
* 	A1 = OID 							 *
* 	A8 = Ptr to any part of multi-parter				 *
* 									 *
* 	Returns:							 *
* 									 *
* 		 Z = No object found, A0 = 0				 *
* 		NZ = Matching object found, A0 = Ptr to object		 *
*								         *
**************************************************************************
EXIST_PART
	MOVE	*A8(OPART1),A0,L
	SEXT	A1
EP_LP	
	MOVE	*A0(OID),A14,W
	CMP	A1,A14
	JREQ	EP_X		;BR = Found one

	MOVE	*A0(OPARTS),A0,L
	JRNZ	EP_LP		;BR = Got another part to check
EP_X	
	MOVE	A0,A0
	RETS

**************************************************************************
*								         *
* GET_HEAD_PART - ROUTINE TO GET THE PTR TO THE HEAD OBJECT OF A	 *
* 		MULTI-PARTER, IF THE OBJECT IS SOLO THEN NOTHING	 *
* 		CHANGES.						 *
* A8 = PTR TO PART							 *
* RETURNS								 *
* 	 Z = NOT A MULTI-PARTER						 *
* 		A8 = SAME						 *
* 	NZ = MULTI-PARTER						 *
* 		A8 = PTR TO HEAD OBJECT					 *
*								         *
**************************************************************************
GET_HEAD_PART
	MOVE	*A8(OPART1),A14,L	;GET HEAD PART
	JRZ	GHP_X			;BR = SOLO OBJECT
	MOVE	A14,A8			;RETURN PART
GHP_X
	RETS

**************************************************************************
*								         *
* GETHEADPART - A0 Version of GET_HEAD_PART				 *
* A0 = Ptr to part							 *
* Returns:								 *
* 	 Z = Not a Multi-Parter						 *
* 		A0 = Same						 *
* 	NZ = Object is part of a Multi-Parter				 *
* 		A0 = Ptr to HEAD object					 *
*								         *
**************************************************************************
GETHEADPART
	MOVE	*A0(OPART1),A14,L	;GET HEAD PART
	JRZ	GHPA0_X			;BR = SOLO OBJECT
	MOVE	A14,A0			;RETURN PART
GHPA0_X
	RETS

**************************************************************************
*								         *
* GET_HEAD_PART_A0 - ROUTINE TO GET THE PTR TO THE HEAD OBJECT OF A	 *
* 		MULTI-PARTER, IF THE OBJECT IS SOLO THEN NOTHING	 *
* 		CHANGES.						 *
* A8 = PTR TO PART							 *
* RETURNS								 *
* 	A0 = PTR TO HEAD OBJECT						 *
*								         *
**************************************************************************
GET_HEAD_PART_A0
	MOVE	*A8(OPART1),A14,L	;GET HEAD PART
	JRZ	GHPA_NOMULTI		;BR = SOLO OBJECT
	MOVE	A14,A0			;RETURN PART
	RETS
GHPA_NOMULTI
	MOVE	A8,A0			;RETURN "HEAD" PART REGARDLESS
	SETZ				;FLAG IT.
	RETS



	.align		;This replaces the old CACHE4 section

**************************************************************************
*								         *
* GANIOF - RETURN ANIMATION PNT. OF GIVEN IMAGE				 *
* A2 = [HEIGHT,WIDTH]							 *
* A5 = OFLAGS								 *
* GARBOF - SAME AS GANIOF EXCEPT YOU PROVIDE				 *
* A6 = OFFSET								 *
* RETURNS								 *
*  	A6 = X ANIMATION OFFSET (32 BIT)				 *
* 	A7 = Y ANIMATION OFFSET (32 BIT)				 *
*								         *
**************************************************************************
GANIOF:
	MMTM	SP,A2,A3
	MOVE	*A1(IANIOFF),A6,L
	jruc	GotOf
GARBOF:
;A6 has offset from TL
	MMTM	SP,A2,A3
GotOf	CLR	A7		;MAKE SURE A7 IS 0
	MOVY	A6,A7
	SLL	16,A6		;MOVE TO UPPER WORD
	SUBI	00010001h,A2	;ADJUST FOR -1
	CLR	A3
	MOVY	A2,A3
	SLL	16,A2		;MOVE TO UPPER WORD
	BTST	B_FLIPH,A5
        JRZ	GANI1
	NEG	A6
	ADD	A2,A6		;SUB THS-1 FOR H-FLIP
GANI1:
	BTST	B_FLIPV,A5
	JRZ	GANI2
	NEG	A7
	ADD	A3,A7		;SUB TVS-1 FOR V-FLIP
GANI2:
	MMFM	SP,A2,A3
	RETS

**************************************************************************
* SetArbP
* A8 ptr to BASE OBJ
* A7 BASE OBJ TL offset
* A0 ptr to obj which is to have its position set so that its offset pt
*	is at the same coors as the BASE OBJ offset pt
* A1 SUBORDINATE OBJ TL offset
SetArbP:
	mmtm	SP,A2,A3,A4,A5,A6,A7
;* get POSITION from first obj..
	move	*A8(OSIZE),A2,L
	move	*A8(OCTRL),A4,W
*GARBOF: A6=ANIOFF, A2=H:W, A4=OCTRL -> A6=X ANIOFF<<16, A7=Y ANIOFF<<16
	move	A7,A6
	callr	GARBOF
	move	A6,A3
	move	A7,A5

	move	*A0(OSIZE),A2,L
	move	*A8(OCTRL),A4,W
*GARBOF: A6=ANIOFF, A2=H:W, A4=OCTRL -> A6=X ANIOFF<<16, A7=Y ANIOFF<<16
	move	A1,A6
	callr	GARBOF
	sub	A7,A5
	sub	A6,A3

	move	*A8(OYVAL),A7,L
	add	A7,A5
	move	A5,*A0(OYVAL),L
	move	*A8(OXVAL),A6,L
	add	A6,A3
	move	A3,*A0(OXVAL),L
	mmfm	SP,A2,A3,A4,A5,A6,A7
	rets



**************************************************************************
* STRT_ANIM
* A1 SCRIPT PTR
* A8 OBJ TO BE STARTED ON ANIM 
STRT_ANIM:
	PUSH	A0
	move	A8,A0
	callr	STRTANIM
	PULLQ	A0
	rets
* STRTANIM
* A1 SCRIPT PTR
* A0 OBJ TO BE STARTED ON ANIM 



STRTANIM:
;	PUSH	A1
	move	A1,*A0(AnimFrm),L
	move	A1,*A0(AnimScr),L
	clr	A14
	movb	A14,*A0(AnimSlp)
	callr	CKINSANI
;	PULLQ	A1
	rets

*
* Same as STRTANIM, but starts in middle of sequence
* A1 START FRAME
* A14 SCRIPT PTR
* A0 OBJ TO BE STARTED ON ANIM 
*
STRTANIM_OFF:
	PUSH	A1
	move	A14,*A0(AnimScr),L
	move	A1,*A0(AnimFrm),L
	clr	A1
	movb	A1,*A0(AnimSlp)
	callr	CKINSANI
	PULLQ	A1
	rets

**************************************************************************
* STFANIM
* A1 = Ptr to ANIM Structure (see below)
* A0 = Ptr to Object to be inserted
*   STRUCT .long FRAME (ptr), SCRIPT (reset)
*	   .byte AnimSLP (reset), AnimSlp (ctr)
*          .word RESERVED (set to 0)
*
STFANIM:
	mmtm	SP,A1,A2
	move	A0,A2
	addi	AnimFrm,A2
	move	*A1+,*A2+,L
	move	*A1+,*A2+,L
	move	*A1+,*A2+,L
	callr	CKINSANI
	mmfm	SP,A1,A2
	rets

****************************************************************************
* INSANIM - errors if already on
* CKINSANI - only inserts if not already on
* A0 = OBJ to be Animated/Flown by ANIMP
* ***NOTE***
* the following obj fields must be appropriately initialized before insertion.
* AnimScr 	-ptr to longnull terminated animation script w/ format of
*  .long	frame		;if Bit 0 of frame ptr = '1' don't animate..
*  .word (FlipFlag.1:unusedFlag.1:FuncFlag.1:MultiFlag.1:0.4 : SleepTime.8)
*  [.word FlipBits] if FlipFlag set
*  [.long Function|# of ARG words (0-15)] if FuncFlag set
*	!!!!! WARNING WARNING WARNING WARNING WARNING WARNING !!!!!
*	!!!!! 						      !!!!!
*	!!!!! The low four bits of the animation function     !!!!!
*	!!!!! Address are used to indicate the number of      !!!!!
*	!!!!! WORD arguments used by this function.	      !!!!!
*	!!!!! ALWAYS use GETAFARG_xxxx to grab arguments.     !!!!!
*	!!!!! 						      !!!!!
*	!!!!! WARNING WARNING WARNING WARNING WARNING WARNING !!!!!
*  if MultiFlag Set, loop on OPARTS & process another script entry
*    this causes stuffing of sleep time to be skipped, thus sleep value of
*    last entry of multiscript will be used.
*	If the NOPARTANI Bit of OFLAGS is set for a subpart, that
*	part will not be processed during the Multi-Script. 
* 	Function can clobber all but A12,A13
*	!!!!! WARNING WARNING WARNING WARNING WARNING WARNING !!!!!
*          A12 must stay untouched throughout anim func because a call
*          to DELOBJ or PULLANIM will scan to pull QUEUED(A12) Anim func.
*	!!!!! WARNING WARNING WARNING WARNING WARNING WARNING !!!!!
* AnimFrm	-ptr to current entry in animation script
* AnimSlp	-byte, # tiks before next ani
* AnimSLP -byte, overlayed on AnimScr, resets AnimSlp when SleepTime=0
* AnimGrv	-word, amount to add to Yvel each tik
*
* AnimArg	-set by AnimP, used by GETAFARG_xxxx

CKINSANI:
;*** ONLY INSERT OBJ IF IT ISN'T ALREADY ON ***
	movb	*A0(OFLAGS+B_ANIM-7),A14
	jrn	SkInsAni
INSANIM:
	.IF	DEBUG
	callr	IsAnObj
	callr	CkAnim
	callr	OnAnim
	.ENDIF

;	PUSH	A1

	;**** MARK OBJ AS BEING ON ANIM LIST ****
	PUSHST
	DINT

	move	*A0(OFLAGS),A14,W
	btst	B_ANIM,A14
	LOCKON	NZ
	ori	M_ANIM,A14
	move	A14,*A0(OFLAGS),W

	;LINK OBJ INTO HEAD OF ANIOBJS LIST
	move	@ANIOBJS,A14,L
	move	A14,*A0(AnimNxt),L
	move	A0,@ANIOBJS,L
    	POPST
****	EINT

;	PULLQ	A1
	.IF	DEBUG
;	callr	CkAnim
	.ENDIF
SkInsAni
	rets

**************************************************************************
*								         *
* 	CLEAR_ANIMS							 *
* 									 *
* 	Clear ANIM list of all animating objects.			 *
*								         *
**************************************************************************
CLEAR_ANIMS
	MMTM	SP,A0,A8
	MOVE	@ANIOBJS,A8,L
	JRZ	CA_X			;BR = Nothing animating

CA_LOOP
	MOVE	A8,A0
	MOVE	*A8(AnimNxt),A8,L	;Grab next right now
	CALLR	PULLANIM		;Pull this one off of the list
	MOVE	A8,A8
	JRNZ	CA_LOOP			;BR = There's more to do
CA_X
	MMFM	SP,A0,A8
	RETS
	
**************************************************************************
* PULL_ANIM
* A8 = OBJ to be pulled from ANIOBJS
* NOTE, CURRENTLY DOESN'T PULL ALL OF MULTI-PARTER IF HEAD
PULL_ANIM:
	PUSH	A0
	move	A8,A0
	callr	PULLANIM
	PULLQ	A0
	rets

**************************************************************************
*								         *
* PULL_ANIM_ALL - PULL OBJECT FROM ANIOBJS ALONG WITH ALL OF ITS	 *
* 		PARTS.							 *
* A8 = PTR TO HEAD OBJECT OF MULTI-PARTER				 *
*								         *
**************************************************************************
PULL_ANIM_ALL
	PUSH	A1
	CLR	A1
	CALLR	PULL_ANIM_MULTI
	PULLQ	A1
	RETS

**************************************************************************
*								         *
* PULL_ANIM_MULTI - PULL GIVEN NUMBER OF OBJECTS OF A MULTI-PARTER	 *
* 			STARTING WITH THE GIVEN OBJECT.			 *
* 			THE NOPARTANI FLAG OF EACH OBJECT WILL		 *
* 			BE CLEARED AT THIS POINT.			 *
* A1 = # OF OBJECTS TO PULL (IF A1 IS 0 PULL ALL FROM THIS POINT)	 *
* A8 = PTR TO PART OF MULTI-PARTER					 *
* RETURNS								 *
* 	A1 = DECREMENTED TO REFLECT NUMBER OF PARTS PULLED		 *
*								         *
**************************************************************************
PULL_ANIM_MULTI
	PUSH	A0
	MOVE	A8,A0			;PULL THE FIRST OBJECT
PAM_LP
	MOVB	*A0(OFLAGS+B_DEAD-7),A14	;IS THIS OBJECT DEAD?
	JRN	PAM_SKIP_NOPART			;BR = YES, DO NOT FOOL AROUND
	MOVB	*A0(OFLAGS+B_ANIM-7),A14	;IS HE ON ANIOBJS?
	JRNN	PAM_SKIP		;BR = NO
	CALLR	PULLANIM
PAM_SKIP
****	MOVB	*A0(OFLAGS2+B_DEAD-7),A14	;IS THIS OBJECT DEAD?
****	JRN	PAM_SKIP_NOPART			;BR = YES, DO NOT FOOL AROUND
	ANDNIM	M_NOPARTANI,*A0(OFLAGS),W	;REVOKE HIS INDEPENDENCE
PAM_SKIP_NOPART
	DEC	A1			;ARE WE FINISHED?
	JRZ	PAM_X			;BR = YES
	MOVE	*A0(OPARTS),A0,L	;GET THE NEXT OBJECT TO PULL
	JRNZ	PAM_LP			;IF THERE ARE NO MORE, EXIT
PAM_X
	PULLQ	A0
	RETS

**************************************************************************
* PULLANIM
* A0 = OBJ to be pulled from ANIOBJS
;A12 if IN_ANIM, A12 must be pointing to ANIM FUNC QUEUE
CKPULLANIM	;PULL FROM ANIM IF NECESSARY
	movb	*A0(OFLAGS+B_ANIM-7),A14
	jrnn	SkPullAnim
PULLANIM:
	PUSH	A2
	.IF	DEBUG
;	callr	CkAnim
	.ENDIF

	;**** MARK OBJ AS BEING OFF ANIM LIST ****
	move	*A0(OFLAGS),A2,W
	btst	B_ANIM,A2
	LOCKON	Z
	andni	M_ANIM,A2
	move	A2,*A0(OFLAGS),W

	calla	PULLANIMFUNC	;stop any queued anim func

	MOVE	@ANIOBJS,A14,L
	cmp	A0,A14
	jrne	PullLp
	;*** PULLING FIRST OBJ ***
	move	*A0(AnimNxt),A14,L
	MOVE	A14,@ANIOBJS,L
	jruc	NoPull

PullLp:
	MOVE 	A14,A2			;PTR TO PREVIOUS IN A2
	MOVE 	*A2(AnimNxt),A14,L	;PTR TO NEXT IN A14
	LOCKON	Z
	CMP  	A14,A0			;IS THIS THE GUY?
	JRNE 	PullLp
	MOVE 	*A0(AnimNxt),*A2(AnimNxt),L 	;LINK AROUND THIS OBJECT

NoPull:

	.IF	DEBUG
	callr	CkAnim
	.ENDIF
	PULLQ	A2
SkPullAnim
	RETS

**************************************************************************
* CkAnim
* Walk ANIOBJS list, hang if anything is wrong
	.IF DEBUG
CkAnim:
	mmtm	SP,A0,A2
	move	@ANIOBJS,A0,L
	jrz	AniCkLpX
AniCkLp:
	move	*A0(OFLAGS),A2,W
	btst	B_ANIM,A2
	LOCKON	Z
	move	*A0(OCTRL),A2,W
	btst	B_INUSE,A2
	LOCKON	Z

;	callr	IsAnObj

	move	*A0(AnimNxt),A0,L
	jrnz	AniCkLp
AniCkLpX:
	mmfm	SP,A0,A2
	rets
	.ENDIF

**************************************************************************
* OnAnim
* hang if A0 is on ANIOBJS LIST
	.IF DEBUG
OnAnim:
	move	@ANIOBJS,A14,L
	jrz	AniOnLpX
AniOnLp:
	cmp	A0,A14
	LOCKON	Z
	move	*A14(AnimNxt),A14,L
	jrnz	AniOnLp
AniOnLpX:
	rets
	.ENDIF

**************************************************************************
*								         *
* GETAFARG_WORD - GET A WORD ARGUMENT FOR AFunc, IT IS PULLED FROM THE	 *
* 		ANIM SCRIPT.						 *
* A8 = PTR TO OBJECT ANIMATING						 *
* *A8(AnimArg),L = PTR TO ARGUMENT TO BE PULLED				 *
* RETURNS								 *
* 	A0 = ARGUMENT							 *
*	N & Z = SET TO REFLECT ARGUMENT	     				 *
* 	*A8(AnimArg),L = POINTING TO NEXT				 *
*								         *
**************************************************************************
GETAFARG_WORD
	MOVE	*A8(AnimArg),A14,L
	MOVE	*A14+,A0,W
	MOVE	A14,*A8(AnimArg),L
	RETS

**************************************************************************
*								         *
* GETAFARG_LONG - GET A LONG ARGUMENT FOR AFunc, IT IS PULLED FROM THE	 *
* 		ANIM SCRIPT.						 *
* A8 = PTR TO OBJECT ANIMATING						 *
* *A8(AnimArg),L = PTR TO ARGUMENT TO BE PULLED				 *
* RETURNS								 *
* 	A0 = ARGUMENT							 *
*	N & Z = SET TO REFLECT ARGUMENT	     				 *
* 	*A8(AnimArg),L = POINTING TO NEXT				 *
*								         *
**************************************************************************
GETAFARG_LONG
	MOVE	*A8(AnimArg),A14,L
	MOVE	*A14+,A0,L
	MOVE	A14,*A8(AnimArg),L
	RETS

**************************************************************************
* A_GOTO - Anim Func
* takes two args from anim script
* .long label to branch to.
* .word %chance (RANDPER) to take branch
A_GOTO
	callr	GETAFARG_LONG	;Arg in A0
	move	A0,A1
	callr	GETAFARG_WORD	;Arg in A0
	calla	RANDPER
	jrnc	A_GOTOX
	move	A1,*A8(AnimFrm),L
A_GOTOX
	rets


**************************************************************************
* A_AnimGo - ANIM FUNC TO GO TO NEW ANIM SCRIPT/FRAME			 *
* A8 = PTR TO OBJECT							 *
*								         *
**************************************************************************
A_AnimGo
	CALLR	GETAFARG_LONG		;GET NEW PTR OFF OF SCRIPT
	MOVE	A0,*A8(AnimFrm),L
	MOVE	A0,*A8(AnimScr),L
	RETS

**************************************************************************
*								         *
* A_AnimFrm - ANIM FUNC TO GO TO NEW ANIM FRAME				 *
* A8 = PTR TO OBJECT							 *
*								         *
**************************************************************************
A_AnimFrm
	CALLR	GETAFARG_LONG		;GET NEW PTR OFF OF SCRIPT
	MOVE	A0,*A8(AnimFrm),L
	RETS

**************************************************************************
*								         *
* A_AnimScr - ANIM FUNC TO SET A NEW LOOP BACK PTR FOR AN ANIMATION	 *
* 		SCRIPT.							 *
* A8 = PTR TO OBJECT							 *
*								         *
**************************************************************************
A_AnimScr
	CALLR	GETAFARG_LONG		;GET NEW PTR OFF OF SCRIPT
	MOVE	A0,*A8(AnimScr),L
	RETS

**************************************************************************
*								         *
* A_CHANGE_OID - ANIM FUNC TO STUFF A NEW OID INTO AN OBJECT		 *
* A8 = PTR TO OBJECT							 *
* AARG+,W = NEW OID TO STUFF						 *
*								         *
**************************************************************************
A_CHANGE_OID
	CALLA	GETAFARG_WORD
	MOVE	A0,A1
	JRUC	CHANGE_OID

**************************************************************************
*								         *
* A_CLR_GUNVECT - ANIM FUNC TO CLEAR AN OBJECTS GUN VECTOR.		 *
* A8 = PTR TO OBJECT							 *
*								         *
**************************************************************************
A_CLR_GUNVECT
	CLRM	*A8(OGUNVECT),L
	RETS

**************************************************************************
*                                                                        *
* KILOBJ_XA8 - KILL A CLASS OF OBJECTS FROM THE OBJECT LIST EXCEPT	 *
* 		FOR THE ONE POINTED TO BY A8.				 *
* A0 = OID (16 BITS)							 *
* A1 = MASK: MASK BITS OF ZERO ARE DONT CARES (16 BITS)			 *
* A8 = PTR TO OBJECT NOT TO KILL (0 = NO OBJECT TO WORRY ABOUT)		 *
*                                                                        *
* NEEDS TO BE REDONE
**************************************************************************
;KILOBJ_XA8:
;	MMTM	SP,A0,A2,A3,A4,A5,A8
;	MOVI	OBJLST,A2,L
;	JRUC	KILGEN

**************************************************************************
*								         *
* KILBOBJ - KILL A CLASS OF OBJECTS FROM THE PRIMARY BACKGROUND LIST.	 *
* A0 = OID (16 BITS)							 *
* A1 = MASK: MASK BITS OF ZERO ARE DONT CARES (16 BITS)			 *
*								         *
* NEEDS TO BE REDONE
**************************************************************************
;KILBOBJ:
;	MMTM	SP,A0,A2,A3,A4,A5,A8
;	CLR	A8
;	MOVI	BAKLST,A2,L
;	JRUC	KILGEN
	nop

**************************************************************************
*								         *
* CREATE_OBJ - CREATE AN OBJECT AND STUFF IT, LEAVE IT UNINSERTED.	 *
* 		USES THE "NEW" (11/15/90) INITIALIZATION TABLE.		 *
* A5 = PTR TO INIT TABLE						 *
* RETURNS								 *
* 	 Z = FAILURE TO CREATE EITHER OBJECT OR PALETTE.		 *
* 		A0 = 0							 *
* 	NZ = O.K.							 *
* 		A0 = POINTER TO OBJECT					 *
* 		A5 = NEXT WORD AFTER INITIALIZATION			 *
*								         *
**************************************************************************
CREATE_OBJ
	CALLR	GETOBJ
	JRZ	CO_X			;OBJECT BLOCK FAILURE
	CALLR	INIT_OBJ
	JRNZ	CO_X
	CALLR	FREEOBJ			;DO THIS ON MASTER PALETTE FAILURE
	CLR	A0			;SET THE Z FLAG
CO_X:
	RETS
**************************************************************************
*								         *
* INIT_OBJ - INITIALIZE AN OBJECT BLOCK USING AN INITIALIZATION TABLE.	 *
* A0 = OBJECT BLOCK TO INITIALIZE					 *
* A5 = PTR TO "NEW" INITIALIZATION TABLE				 *
* A8 - A11 = MUST BE PASSED TO CREATE FUNC IF CALLED.			 *
* RETURNS:								 *
* 	 Z = PALETTE ALLOCATE FAILURE, OBJECT NOT STUFFED		 *
* 	NZ = ALL IS WELL						 *
* A5 = POINTING TO NEXT WORD AFTER INITIALIZATION TABLE			 *
* 									 *
* 		 INITIALIZATION TABLE					 *
* 		 --------------------					 *
* 	.LONG	OIMG,OCVECT						 *
* 	.WORD	OID,OCTRL,OFLAGS,OZOFF					 *
* 	.LONG	CFUNC							 *
*								         *
**************************************************************************
INIT_OBJ
	PUSH	A1
	MMTM	SP,B0,B1,B2,B3

	MOVE	*A5+,A1,L
	CALLR	FPSTFOBJ0
	JRZ	IO_X

	MOVE	A5,B0
	move	A0,B1
	move	*B0+,B2,L		;Load OCVECT
	move	B2,*B1(OCVECT),L
	move	*B0+,B2,W		;Load OID
	move	B2,*B1(OID),W

	move	*B0+,B2,W		;Load OCTRL
	MOVE	*B0+,B3,W		;Load OFLAGS
	MOVE	B3,*B1(OFLAGS),W
	btst	B_FLIPH,B2
	jrnz	IO_FLIP
	btst	B_FLIPV,B2
	jrz	IO_SKIPFLIP
IO_FLIP
	MMTM	SP,A4,A8
	move	B2,A4
	move	A0,A8
	;A1 still set from above
	calla	ANI
	MMFM	SP,A4,A8
	jruc	IO_FLAGSOK
IO_SKIPFLIP
	MOVE	*B1(OCTRL),B3,W
	OR	B2,B3
	move	B3,*B1(OCTRL),W
IO_FLAGSOK
	MOVE	*B0+,B2,W		;Load OZOFF

	MOVB	B2,*B1(OZOFF)

	MOVE	*B0+,B2,L		;GET THE CFUNC
	JRZ	IO_NOCFUNC
	CALL	B2			;CALL IT
IO_NOCFUNC
	MOVE	B0,A5
IO_X
	MMFM	SP,B0,B1,B2,B3
	PULL	A1
	RETS

**************************************************************************
* GET_SUPP
* Returns ptr to supplemental list header
*
* A8 = obj
* RETURNS A0 = supp list header - OSLINK (Z set if not on any list)
GET_SUPP:
	move	A8,A0
	callr	GETSUPP
	move	A14,A0
	rets

**************************************************************************
* GETSUPP
* GETSUPP_FROM_OID
* Returns ptr to supplemental list header
*
* A0 = obj
* A14 = OID FOR GETSUPP_FROM_OID
* RETURNS A14 = supp list header - OSLINK (Z set if not on any list)
GETSUPP
	move	*A0(OID),A14,W
GETSUPP_FROM_OID
	srl	SR_SUPP,A14
	jrz	NoSupp
	sll	5,A14			;convert to offset, multiple of 020H
	addi	SUPPLSTS-OSLINK,A14
NoSupp
	rets

**************************************************************************
* INSSUPP
* Inserts object onto a supplemental list
* List is selected by the SUPP field of the OID
*
* A0 = OBJ to insert
* RETURNS nothing
INSSUPP:
	callr	GETSUPP
	jrz	SkInsSupp

	.IF DEBUG
	;***** CHECK IF OBJECT IS ALREADY ON SUPPLEMENTAL LIST ******
	PUSH	A14
CkSupp:
	cmp	A14,A0
	jreq	$
	move	*A14(OSLINK),A14,L
	jrnz	CkSupp	
	PULLQ	A14
	.ENDIF

	MOVE	*A0(OID),A4,W
	ANDI	MASK_TYPE,A4
	CMPI	TYPE_UNIV & MASK_TYPE,A4
	JREQ	inssupp_sort
	
	move	*A14(OSLINK),*A0(OSLINK),L
	move	A0,*A14(OSLINK),L
	rets

inssupp_sort
	move 	*A0(OZVAL),A1,L		; GET Z POSITION
inssupp_zloop:
	MOVE	A14,A4
	move  	*A14(OSLINK),A14,L	;what 'supp?
	JRZ	do_inssupp		; BR = END OF SUPP LIST
	move 	*A14(OZVAL),A2,L
	cmp    	A2,A1
	jrgt 	inssupp_zloop
	jrlt	do_inssupp

	move	*A0(OYVAL),A5,L		; GET Y POSITION
	jruc	inssupp_ytest
inssupp_yloop
	MOVE	A14,A4
	move  	*A14(OSLINK),A14,L
	JRZ	do_inssupp
	move 	*A14(OZVAL),A2,L
	cmp    	A2,A1
	jrlt 	do_inssupp
inssupp_ytest
	move	*A14(OYVAL),A2,L	;TEST Y POSITION
	cmp	A2,A5
	JRLT	inssupp_yloop
do_inssupp
	move	*A4(OSLINK),*A0(OSLINK),L
	move	A0,*A4(OSLINK),L

SkInsSupp
	rets


**************************************************************************
* INSERT_SUPP
* Inserts object onto a supplemental list
* List is selected by the SUPP field of the OID
*
* A8 = OBJ to insert
INSERT_SUPP:
  	PUSH	A0
	move	A8,A0
	callr	INSSUPP
	PULLQ	A0
	RETS


**************************************************************************
* PULLSUPP
* pulls object from a supplemental list
* List is selected by the SUPP field of the OID
*
* A0 = OBJ to pull
* RETURNS nothing
PULLSUPP:
	PUSH	A1
	callr	GETSUPP
	jrz	SkPullSupp

PulSupLp
	move	A14,A1
	move	*A14(OSLINK),A14,L
	LOCKON	Z
	cmp	A14,A0
	jrne	PulSupLp

	move	*A0(OSLINK),*A1(OSLINK),L	;link around A0
	clr	A1
	move	A1,*A0(OSLINK),L
SkPullSupp
	PULLQ	A1
	rets

**************************************************************************
* PULL_SUPP
* pulls object from a supplemental list
* List is selected by the SUPP field of the OID
*
* A8 = OBJ to insert
PULL_SUPP:
	PUSH	A0
	move	A8,A0
	callr	PULLSUPP
	PULLQ	A0
	RETS


**************************************************************************
* CNTSUPP
* COUNT THE NUMBER OF OBJECTS ON GIVEN SUPPLEMENTAL LIST.
*
* A14 = SUPPLEMENTAL LIST HEADER - OSLINK
* RETURNS A0 = OBJECT CNT (SETS THE Z BIT)
*         A14 = TRASHED
CNTSUPP:
	clr	A0
CntSupLp
	move	*A14(OSLINK),A14,L
	jrz	CNTSUPPX
	inc	A0
	cmpi	NOBJ,A0
	LOCKON	GE		;WE'VE MAXED, SOMETHING IS WRONG
	jruc	CntSupLp
CNTSUPPX
	move	A0,A0
	rets

**************************************************************************
*								         *
* 	CHANGEZPOS							 *
* 									 *
* 	CHANGE THE Z POSITION OF A WHOLE TYPE OF OBJECTS		 *
* 									 *
* 	ENTRY								 *
* 		A0	OID TO CHANGE					 *
* 		A1	NEW ZPOS ( 32 BITS WORTH )			 *
* 									 *
* 	EXIT								 *
* 		NOTHING							 *
*								         *
* NEEDS TO BE REDONE
**************************************************************************

;CHANGEZPOS:
;	MMTM	SP,A2,A3
;	SEXT	A0
;	MOVI	OBJLST,A2
;CHNGZLP
;	MOVE	*A2,A2,L
;	JRZ	CHNGZPOSX		;BR = DONE WITH THE LIST
;	MOVE	*A2(OID),A3,W
;	CMP	A0,A3
;	JRNE	CHNGZLP			;THIS IS NOT ONE OF THEM
;	MOVE	A1,*A2(OZVAL),L		; STUFF THE NEW ZPOS
;	JRUC	CHNGZLP
;CHNGZPOSX
;	MMFM	SP,A2,A3
;	RETS

**************************************************************************
*								         *
* 	DECZPOS								 *
* 									 *
* 	DECREMENT THE Z POSITION OF A WHOLE TYPE OF OBJECTS		 *
* 									 *
* 	ENTRY								 *
* 		A0	OID TO CHANGE					 *
* 		A1	Z POSITION DECREMENT VALUE			 *
* 									 *
* 	EXIT								 *
* 		NOTHING							 *
* 									 *
* 	CALL								 *
* 		CALL							 *
*								         *
* NEEDS TO BE REDONE
**************************************************************************

;DECZPOS:
;	MMTM	SP,A2,A3
;	SEXT	A0
;	MOVI	OBJLST,A2
;DECZLP
;	MOVE	*A2,A2,L
;	JRZ	DECZPOSX		;BR = DONE WITH THE LIST
;	MOVE	*A2(OID),A3,W
;	CMP	A0,A3
;	JRNE	DECZLP			;THIS IS NOT ONE OF THEM
;	MOVE	*A2(OZVAL),A14,L
;	SUB	A1,A14
;	MOVE	A14,*A2(OZVAL),L	; STUFF THE NEW ZPOS
;	JRUC	DECZLP
;DECZPOSX
;	MMFM	SP,A2,A3
;	RETS


**************************************************************************
*                                                                        *
* OBJ_OFF - TURN AN OBJECT "OFF" I.E. SET DMA OUTPUT = 0		 *
* A8 = PTR TO OBJECT BLOCK						 *
*                                                                        *
**************************************************************************
OBJ_OFF:
	.if OLD_WAY
	MOVE	*A8(OCTRL),A14,W
	SRL	4,A14
	SLL	4,A14
	MOVE	A14,*A8(OCTRL),W
	MOVE	*A8(OSHAD),A14,L	;Does this object have a shadow?
	JRZ	OBJ_OFF_X		;BR = No, then don't worry
	PUSH	A8
	MOVE	A14,A8
	MOVE	*A8(OCTRL),A14,W
	SRL	4,A14			;Shut the shadow down
	SLL	4,A14
	MOVE	A14,*A8(OCTRL),W
	PULLQ	A8

	.else

	move	*a8(OFLAGS),a14
	ori	M_NODISP,a14
	move	a14,*a8(OFLAGS)

	MOVE	*A8(OSHAD),A14,L	;Does this object have a shadow?
	JRZ	OBJ_OFF_X		;BR = No, then don't worry
	PUSH	A8
	MOVE	A14,A8
	move	*a8(OFLAGS),a14
	ori	M_NODISP,a14
	move	a14,*a8(OFLAGS)
	PULLQ	A8
	
	.endif
OBJ_OFF_X
	RETS

**************************************************************************
*								         *
* OBJOFF - TURN AN OBJECT "OFF" I.E. SET DMA OUTPUT = 0			 *
* 	 A0 VERSION							 *
* A0 = PTR TO OBJECT							 *
*								         *
**************************************************************************
OBJOFF
	PUSH	A8
	MOVE	A0,A8
	CALLR	OBJ_OFF
	PULLQ	A8
	RETS

**************************************************************************
*                                                                        *
* OBJ_ON - TURN AN OBJECT "ON" I.E. SET DMA OUTPUT TO WRITE <> 0	 *
* A8 = PTR TO OBJECT BLOCK						 *
*                                                                        *
**************************************************************************
OBJ_ON:
	.if OLD_WAY
	MOVE	*A8(OCTRL),A14,W
	SRL	4,A14
	SLL	4,A14
	ADDK	DMAWNZ&0FH,A14
	MOVE	A14,*A8(OCTRL),W

	MOVE	*A8(OSHAD),A14,L	;Does this object have a shadow?
	JRZ	OON_X			;BR = No, then don't worry
	PUSH	A8
	MOVE	A14,A8
	MOVE	*A8(OCTRL),A14,W
	SRL	4,A14			
	SLL	4,A14
	ADDK	DMACNZ&0FH,A14		;Turn the shadow on
	MOVE	A14,*A8(OCTRL),W
	PULLQ	A8

	.else

	move	*a8(OFLAGS),a14
	andni	M_NODISP,a14
	move	a14,*a8(OFLAGS)

	MOVE	*A8(OSHAD),A14,L	;Does this object have a shadow?
	JRZ	OON_X			;BR = No, then don't worry
	PUSH	A8
	MOVE	A14,A8
	move	*a8(OFLAGS),a14
	andni	M_NODISP,a14
	move	a14,*a8(OFLAGS)
	PULLQ	A8

	.endif
OON_X
	RETS

**************************************************************************
*								         *
* OBJON - TURN AN OBJECT "ON" I.E. SET DMA OUTPUT TO WRITE <> 0		 *
* 	 A0 VERSION							 *
* A0 = PTR TO OBJECT							 *
*								         *
**************************************************************************
OBJON
	PUSH	A8
	MOVE	A0,A8
	CALLR	OBJ_ON
	PULLQ	A8
	RETS

**************************************************************************
*								         *
* 	OBJ_WNZ								 *
* 									 *
* 	Turn an object to Constant on non-zero pixels.			 *
* 									 *
* 	A8 = Ptr to object						 *
*								         *
**************************************************************************
OBJ_WNZ
	MOVE	*A8(OCTRL),A14,W
	SRL	4,A14
	SLL	4,A14
	addk	DMAWNZ&0Fh,A14
	MOVE	A14,*A8(OCTRL),W
	RETS

**************************************************************************
*								         *
* 	OBJWNZ								 *
* 									 *
* 	Turn an object to Constant on non-zero pixels.			 *
* 	A0 Version.							 *
* 									 *
* 	A0 = Ptr to object						 *
*								         *
**************************************************************************
OBJWNZ
	PUSH	A8
	MOVE	A0,A8
	CALLR	OBJ_WNZ
	PULLQ	A8
	RETS
**************************************************************************
*								         *
* 									 *
* 	OBJ_WNZ_ON							 *
* 									 *
* 	Not only does this set the DMA flags to Write Non-Zero, but	 *
* 	it also ensures that the object is on.				 *
* 									 *
* 	A8 = Ptr to object						 *
*								         *
**************************************************************************
OBJ_ON_WNZ
	CALLR	OBJ_WNZ
	JRUC	OBJ_ON

**************************************************************************
*                                                                        *
* OBJ_CONST - Turn an object to Constant on non-zero pixels.		 *
* A8 = Ptr to object							 *
*                                                                        *
**************************************************************************
OBJ_CONST
	MOVE	*A8(OCTRL),A14,W
	SRL	4,A14
	SLL	4,A14
	addk	DMACNZ&0Fh,A14
	MOVE	A14,*A8(OCTRL),W
	RETS

**************************************************************************
*								         *
* 	OBJCONST							 *
* 									 *
* 	Turn an object to Constant on non-zero pixels.			 *
* 	A0 Version.							 *
* 									 *
* 	A0 = Ptr to object						 *
*								         *
**************************************************************************
OBJCONST
	PUSH	A8
	MOVE	A0,A8
	CALLR	OBJ_CONST
	PULLQ	A8
	RETS

**************************************************************************
*								         *
* OBJ_OFF_MULTI - TURN ALL OF THE PARTS OF A MULTI-PARTER "OFF" FROM	 *
* 		THIS OBJECT ON DOWN.					 *
* A8 = PTR TO FIRST PART TO TURN "OFF"					 *
*								         *
**************************************************************************
OBJ_OFF_MULTI
	PUSH	A8
OOFFM_LP
	CALLR	OBJ_OFF
	MOVE	*A8(OPARTS),A8,L
	JRNZ	OOFFM_LP
	PULLQ	A8
	RETS

**************************************************************************
*								         *
* OBJ_ON_MULTI - TURN ALL OF THE PARTS OF A MULTI-PARTER "ON" FROM	 *
* 		THIS OBJECT ON DOWN.					 *
* A8 = PTR TO FIRST PART TO TURN "ON"					 *
*								         *
**************************************************************************
OBJ_ON_MULTI
	PUSH	A8
OONM_LP
	CALLR	OBJ_ON
	MOVE	*A8(OPARTS),A8,L
	JRNZ	OONM_LP
	PULLQ	A8
	RETS

**************************************************************************
*								         *
* OBJ_ON_WNZ_MULTI - TURN ALL OF THE PARTS OF A MULTI-PARTER "ON" FROM	 *
* 		THIS OBJECT ON DOWN.					 *
* A8 = PTR TO FIRST PART TO TURN "ON"					 *
*								         *
**************************************************************************
OBJ_ON_WNZ_MULTI
	PUSH	A8
OOWM_LP
	CALLR	OBJ_ON_WNZ
	MOVE	*A8(OPARTS),A8,L
	JRNZ	OOWM_LP
	PULLQ	A8
	RETS

**************************************************************************
*								         *
* OBJ_CONST_MULTI - TURN ALL OF THE PARTS OF A MULTI-PARTER "CONSTANT" FROM*
* 		THIS OBJECT ON DOWN.					 *
* A8 = PTR TO FIRST PART TO TURN "CONSTANT"				 *
*								         *
**************************************************************************
OBJ_CONST_MULTI
	PUSH	A8
OCONSTM_LP
	CALLR	OBJ_CONST
	MOVE	*A8(OPARTS),A8,L
	JRNZ	OCONSTM_LP
	PULLQ	A8
	RETS

**************************************************************************
*								         *
* IS_OBJ_OFF - DETERMINE IF GIVEN OBJECT IS "TURNED OFF"		 *
* A8 = PTR TO OBJECT							 *
* RETURNS								 *
* 	 Z = OBJECT IS OFF						 *
* 	NZ = OBJECT IS ON						 *
* NOTE: TRASHES A14							 *
*								         *
**************************************************************************
IS_OBJ_OFF
	.if OLD_WAY
	MOVE	*A8(OCTRL),A14,W
	SLL	28,A14

	.else

	move	*a8(OFLAGS),a14
	btst	B_NODISP,a14

	.endif
	RETS

**************************************************************************
*								         *
* OBJECTS_ON - TURN A CLASS OF OBJECTS "ON"				 *
* A0 = OID OF OBJECTS TO TURN ON					 *
* A1 = MASK (0 BITS = DON'T CARE)					 *
* A4 = DMA WRITE FLAGS (LOW FOUR BITS) TO USE.				 *
* NOTE: TRASHES A14							 *
*								         *
**************************************************************************
OBJECTS_ON:
	MMTM	SP,A2,A3,A4
	MOVI	FGLIST,A3		
	MOVE	*A3(P_LSTHD),A2,L		;GET THE OBJECT LIST	
	CMP	A2,A3
	JREQ	OBJSON_X
	SEXT	A0
	AND	A1,A0				;FORM MATCH
	SLL	28,A4
	SRL	28,A4				;ONLY CONCERNED WITH WRITES
OBJSON_LP:
	MOVE	*A2(OID),A14,W
	AND	A1,A14				;MASK OFF THE DON'T CARES
	CMP	A0,A14
	JRNE	OBJSON_NXT			;BR = THIS IS NOT ONE OF THEM
	ORM	A4,*A2(OCTRL),W			;ON WITH YOU
OBJSON_NXT:
	MOVE	*A2,A2,L
	CMP	A2,A3
	JRNE	OBJSON_LP			;BR = NOT FINISHED YET
OBJSON_X:
	MMFM	SP,A2,A3,A4
	RETS

**************************************************************************
*								         *
* OBJECTS_OFF - TURN A CLASS OF OBJECTS "OFF"				 *
* A0 = OID OF OBJECTS TO TURN OFF					 *
* A1 = MASK (0 BITS = DON'T CARE)					 *
* NOTE: TRASHES A14							 *
*								         *
**************************************************************************
OBJECTS_OFF:
	MMTM	SP,A2,A3

	MOVI	FGLIST,A3			
	MOVE	*A3(P_LSTHD),A2,L		;GET THE OBJECT LIST
	CMP	A2,A3
	JREQ	OOFF_X
	SEXT	A0
	AND	A1,A0				;FORM MATCH
OOFF_LP:
	MOVE	*A2(OID),A14,W
	AND	A1,A14				;MASK OFF THE DON'T CARES
	CMP	A0,A14
	JRNE	OOFF_NXT			;BR = THIS IS NOT ONE OF THEM

	.if	OLD_WAY
	MOVE	*A2(OCTRL),A14,W
	SRL	4,A14
	SLL	4,A14				;OFLAGS SAY OFF!
	MOVE	A14,*A2(OCTRL),W
	.else
	move	*a2(OFLAGS),a14
	ori	M_NODISP,a14
	move	a14,*a2(OFLAGS)
	.endif

OOFF_NXT:
	MOVE	*A2,A2,L
	CMP	A2,A3
	JRNE	OOFF_LP				;BR = NOT FINISHED YET
OOFF_X:
	MMFM	SP,A2,A3
	RETS

**************************************************************************
*                                                                        *
* GANISAG - ADJUST CURRENT OBJECT IMAGE WITH RESPECT TO IT'S		 *
* 	   ANIMATION PNT. AND FLIP FLAGS 				 *
* NOTE: CALL ONLY AFTER INITIALIZING WITH STFOBJ, OR SOMETHING.		 *
* A0 = PTR TO OBJECT BLOCK						 *
* A2 = NEW OYVAL							 *
* A3 = NEW OXVAL							 *
* A4 = NEW FLAGS							 *
* RETURNS								 *
* A2 = ADJUSTED OYVAL							 *
* A3 = ADJUSTED OXVAL							 *
*                                                                        *
**************************************************************************
;GANISAG
;	MMTM	SP,A1,A4,A6,A7
;	MMTM	SP,A2,A3
;	MOVE	*A0(OIMG),A1,L
;	CALLR	GSAGOF
;	MOVE	A3,*A0(OSAG),L
;	MOVE	A2,*A0(OSIZE),L
;	MOVE	A4,*A0(OFLAGS),L
;	CALLR	GANIOF
;	MMFM	SP,A2,A3
;	SUB	A6,A3
;	SUB	A7,A2			;ADJUST UPPER LEFT CORNER
;	MOVE	A3,*A0(OXVAL),L
;	MOVE	A2,*A0(OYVAL),L
;	MMFM	SP,A1,A4,A6,A7
;	RETS

**************************************************************************
*                                                                        *
* SCREXP32 - SHRINK OR EXPAND THE SCREEN WINDOW FROM THE CURRENT SIZE	 *
*	      TO THE GIVEN IN A GIVEN AMOUNT OF TICKS			 *
* A0 = # OF TICKS							 *
* A10 = NEW SCRNTL							 *
* A11 = NEW SCRNBR							 *
* NOTE: CALL WITH JSRP							 *
*	TRASHES A8 & A9							 *
*                                                                        *
**************************************************************************
SCREXP32
	MOVE	@SCRNTL,A14,L
	MOVX	A14,A1
	SLL	16,A1
	CLR	A2
	MOVY	A14,A2
	SUBXY	A10,A14
	MOVX	A14,A5
	SLL	16,A5
	DIVS	A0,A5
	NEG	A5
	MOVE	A5,A6
	CLR	A5
	MOVY	A14,A5
	DIVS	A0,A5
	NEG	A5
	MOVE	A5,A7

	MOVE	@SCRNBR,A14,L
	MOVX	A14,A3
	SLL	16,A3
	CLR	A4
	MOVY	A14,A4
	SUBXY	A11,A14
	MOVX	A14,A5
	SLL	16,A5
	DIVS	A0,A5
	NEG	A5
	MOVE	A5,A8
	CLR	A5
	MOVY	A14,A5
	DIVS	A0,A5
	NEG	A5
	MOVE	A5,A9
	MOVE	A0,A5
SHTIMLP
	ADD	A6,A1			;ADD THE TLX INCREMENT
	ADD	A7,A2			;ADD THE TLY INCREMENT
	ADD	A8,A3			;ADD THE LRX INCREMENT
	ADD	A9,A4			;ADD THE LRY INCREMENT
	MMTM	A12,A1,A2,A3,A4,A5,A6,A7
	SRL	16,A1
	MOVY	A2,A1
	MOVE	A1,@SCRNTL,L
	SRL	16,A3
	MOVY	A4,A3
	MOVE	A3,@SCRNBR,L
	SLEEP	1
	MMFM	A12,A1,A2,A3,A4,A5,A6,A7
	DSJS	A5,SHTIMLP
SHTIMR
	MOVE	A10,@SCRNTL,L		;MATCH WHAT THE CALLER WANTED
	MOVE	A11,@SCRNBR,L
	RETP


**************************************************************************
*								         *
* DELETE_SUPP_ID - DELETE ALL OF THE OBJECTS ON A GIVEN SUPPLEMENTAL	 *
* 		LIST FROM THE OBJECT AND SUPP LIST AND KILL		 *
* 		THEIR CONTROLLING PROCESS.				 *
* A0 = I.D. TO DELETE							 *
* A1 = MASK								 *
* A8 = SUPPLEMENTAL LIST TO TRAVERSE					 *
*								         *
* NEEDS TO BE REDONE
**************************************************************************
;DELETE_SUPP_ID:
;	MMTM	SP,A0,A1,A2,A3,A4,A8
;	MOVE	A1,A2			;STORE MASK HERE
;	AND	A2,A0			;MATCH THIS
;	MOVE	A8,A1			;KEEP SUPP LIST
;	MOVE	*A8,A8,L		;GET FIRST ELEMENT
;	JRZ	DSUPPID_X		;BR = LIST IS EMPTY
;DSUPPID_LP:
;	MOVE	*A8(OSLINK),A4,L	;GET NEXT IN CASE OF DELETE
;	MOVE	*A8(OID),A3,W
;	AND	A2,A3
;	CMP	A3,A0			;MATCHING I.D.s
;	JRNE	DSUPPID_NXT		;BR = NO
;	CALLA	OBJPROC_KILL		;KILL DUDES PROCESS
;	CALLA	DELETE_OBJ_SUPP		;AND WASTE HIM FROM THE LIST
;DSUPPID_NXT:
;	MOVE	A4,A8			;CHECK NEXT
;	JRNZ	DSUPPID_LP
;DSUPPID_X:
;	MMFM	SP,A0,A1,A2,A3,A4,A8
;	RETS



*REMOVED GET_PT_SCRNREL

*REMOVED GET_Y_SCRNREL

*REMOVED GET_PT_PLANEREL

**************************************************************************
*                                                                        *
* GET_SCRNREL - GET THE SCREEN RELATIVE X,Y COORDINATES OF AN OBJECT	 *
* 	   IT IS ASSUMED THATE THE CURRENT X,Y COORDINATES ARE		 *
* 	   WORLD ABSOLUTE.						 *
* A8 = PTR TO THE OBJECT BLOCK			 			 *
* RETURNS								 *
* A1 = X SCREEN RELATIVE, 32 BITS					 *
* A2 = Y SCREEN RELATIVE, 32 BITS					 *
*                                                                        *
**************************************************************************
GET_SCRNREL
	MOVE	*A8(ODAG),A1,L
	CLR	A2
	MOVY	A1,A2
	SLL	16,A1
	RETS

**************************************************************************
*								         *
* MAKE_SCRNREL - MAKE A GIVEN OBJECT HAVE SCREEN RELATIVE COORDINATES.	 *
* 	   THEY ARE PASSED BACK FOR YOUR USE.				 *
* A8 = PTR TO THE OBJECT BLOCK						 *
* RETURNS								 *
* A1 = X SCREEN RELATIVE, 32 BITS					 *
* A2 = Y SCREEN RELATIVE, 32 BITS					 *
*								         *
**************************************************************************
MAKE_SCRNREL
*REWRITE NEEDED HERE
	RETS

**************************************************************************
*								         *
* MAKE_WORLDREL - MAKE A GIVEN OBJECT HAVE WORLD RELATIVE COORDINATES.	 *
* 	   THEY ARE PASSED BACK FOR YOUR USE.				 *
* A8 = PTR TO THE OBJECT BLOCK						 *
* RETURNS								 *
* A1 = X SCREEN RELATIVE, 32 BITS					 *
* A2 = Y SCREEN RELATIVE, 32 BITS					 *
*								         *
**************************************************************************
MAKE_WORLDREL
*REWRITE NEEDED HERE
	RETS

**************************************************************************
*								         *
* MAKEWORLDREL - MAKE A GIVEN OBJECT HAVE WORLD RELATIVE COORDINATES.	 *
* 	   THEY ARE PASSED BACK FOR YOUR USE. (A0 VERSION)		 *
* A0 = PTR TO THE OBJECT BLOCK						 *
* RETURNS								 *
* A1 = X SCREEN RELATIVE, 32 BITS					 *
* A2 = Y SCREEN RELATIVE, 32 BITS					 *
*								         *
**************************************************************************
MAKEWORLDREL
	PUSH	A8
	MOVE	A0,A8
	CALLR	MAKE_WORLDREL
	PULLQ	A8
	RETS

**************************************************************************
*								         *
* PNT_WORLDREL - MAKE A GIVEN POINT WORLD RELATIVE IN A GIVEN PLANE.	 *
* 		POINT IS ASSUMED TO BE SCREEN RELATIVE.			 *
* A1 = ZVAL AT WHICH TO PLACE POINT					 *
* A3 = [Y,X] SCREEN RELATIVE POINT					 *
* RETURNS								 *
* 	A3 = [Y,X] WORLD RELATIVE					 *
*								         *
**************************************************************************
PNT_WORLDREL
	PUSH	A5

	SEXT	A5			;ISOLATE X COORDINATE
	TOWORLDX A1,A5			;CONVERT IT TO THE WORLD VIA Z

	SRA	16,A3			;ISOLATE Y COORDINATE
	TOWORLDY A1,A3			;CONVERT IT TO THE WORLD VIA Z
	SLL	16,A3
	MOVX	A5,A3			;COMBINE FOR RETURN

	PULLQ	A5
	RETS

**************************************************************************
*                                                                        *
* COPY_OBJ - COPIES THE CONTENTS OF ONE OBJECT BLOCK TO THE OTHER.	 *
* A0 = PTR TO DESTINATION BLOCK						 *
* A8 = PTR TO SOURCE BLOCK						 *
* NOTE: TRASHES A14							 *
*                                                                        *
**************************************************************************
COPY_OBJ:
	MMTM	SP,B0,B2,B7

	MOVE	A0,B2
	MOVE	A8,B0
	ADDI	OZVEL,B2
	ADDI	OZVEL,B0
	MOVI	OBSIZ-OZVEL,B7

	BLMOVE	1,1

	MOVE	*A0(OFLAGS),A14,W
	ANDNI	M_ANIM,A14		;CLEAR ANY IRRELEVANT FLAGS HERE
	MOVE	A14,*A0(OFLAGS),W

	MMFM	SP,B0,B2,B7
	RETS

****	MMTM	SP,A0,A8

****	MOVI	OBSIZ-OZVEL,A14,W	;GET THE SIZE OF THE BLOCK IN WORDS
****	ADDI	OZVEL,A0
****	ADDI	OZVEL,A8		;DON'T COPY THE LINKS

****	SRL	5,A14			;DIVIDE BY 32
****	JRNC	SKIP_COPYOBJ_WRD	;BR = NO ODD WORDS
****	MOVE	*A8+,*A0+,W		;TAKE CARE OF ODD MAN
****SKIP_COPYOBJ_WRD:
****	SRL	1,A14
****	JRNC	COPYOBJ_LP
****	MOVE	*A8+,*A0+,L		;MOVE A LONG
****COPYOBJ_LP
****	move	*A8+,*A0+,L
****	move	*A8+,*A0+,L
****	DSJS	A14,COPYOBJ_LP

****	MMFM	SP,A0,A8
****	MOVE	*A0(OFLAGS),A14,W
****	ANDNI	M_ANIM,A14		;CLEAR ANY IRRELEVANT FLAGS HERE
****	MOVE	A14,*A0(OFLAGS),W
****	RETS

**************************************************************************
*								         *
* 	CREATE_COPY							 *
* 									 *
* 	Create an exact copy of the given object.			 *
* 									 *
* 	A8 = Ptr to object to copy					 *
* 									 *
* 	Returns:							 *
* 		 Z = Failure allocating copy, A0 = 0			 *
* 		NZ = Copy created successfully, A0 = Ptr to copy	 *
*								         *
**************************************************************************
CREATE_COPY
	CALLR	GETOBJ
	JRZ	CC_X
	CALLR	COPY_OBJ
	PUSH	A5
	MOVE	*A0(OPAL),A5,W
	CALLA	INC_PALCNT
	PULLQ	A5
	MOVE	A0,A0
CC_X
	RETS

**************************************************************************
*								         *
* 	CREATE_MULTI_COPY						 *
* 									 *
* 	Same as CREATE_COPY, except for a multi-parter			 *
* 									 *
* 	A8 = Ptr to Multi-parter to copy				 *
*								         *
**************************************************************************
CREATE_MULTI_COPY
	MMTM	SP,A8,A9,A10
	MOVE	A8,A9

	CALLR	CREATE_COPY
	MOVE	A0,*A0(OPART1),L
	MOVE	A0,A9
	MOVE	A0,A10
	MOVE	*A8(OPARTS),A8,L
	JRZ	CMC_X
	PUSH	A0
	
CREATE_MULTI_COPY_LOOP
	CALLR	CREATE_COPY
	MOVE	A10,*A0(OPART1),L
	MOVE	A0,*A9(OPARTS),L
	MOVE	A0,A9
	MOVE	*A8(OPARTS),A8,L
	JRNZ	CREATE_MULTI_COPY_LOOP
	PULLQ	A0
CMC_X
	MMFM	SP,A8,A9,A10
	RETS

**************************************************************************
*								         *
* OBJ_TO_PNT - PUT AN OBJECT DIRECTLY ON A POINT.			 *
* 		WILL ALSO ADJUST THE SLAVE OBJECTS HANGING		 *
* 		OFF OF THIS OBJECT.					 *
* A3 = [Y,X] POINT							 *
* A8 = PTR TO OBJECT							 *
*								         *
**************************************************************************
OBJ_TO_PNT:
	PUSH	A1
	MOVE	A3,A1
	CALLR	SET_ANIP
	PULLQ	A1
	RETS

**************************************************************************
*								         *
* OBJTOPNT - PUT AN OBJECT DIRECTLY ON A POINT (A0 VERSION)		 *
* A0 = PTR TO OBJECT							 *
* A3 = [Y,X] POINT							 *
*								         *
**************************************************************************
OBJTOPNT:
	PUSH	A1
	MOVE	A3,A1
	CALLR	SETANIP
	PULLQ	A1
	RETS

**************************************************************************
*								         *
* CLEAR_OPLINKS - ROUTINE TO CLEAR THE OPLINKS FOR ALL ACTIVE OBJECTS	 *
* 		ON ALL PLANES.						 *
*								         *
**************************************************************************
CLEAR_OPLINKS
	PUSH	A7
	MOVI	CLEAR_OPLINK,A7
	CALLR	FGPLANE_LP
	PULLQ	A7
	RETS

CLEAR_OPLINK
	CLR	A14
	MOVE	A14,*A8(OPLINK),L
	RETS

**************************************************************************
*								         *
* STOPOBJS - ROUTINE TO CLEAR VELOCITIES OF ALL OBJECTS ON ALL PLANES.	 *
*								         *
**************************************************************************
STOPOBJS
	PUSH	A7
	MOVI	STOPOBJ,A7
	CALLR	FGPLANE_LP
	PULLQ	A7
	RETS

**************************************************************************
*								         *
* CLR_VEL - CLEAR ALL VELOCITIES OF OBJECT				 *
* A8 = PTR TO OBJECT							 *
*								         *
**************************************************************************
CLR_VEL
STOPOBJ
	CLR	A14
	MOVE	A14,*A8(OYACCEL),W
	MOVE	A14,*A8(OXVEL),L
	MOVE	A14,*A8(OYVEL),L
	MOVE	A14,*A8(OZVEL),L
	RETS

**************************************************************************
*								         *
* CLRVEL - CLEAR VELOCITIES OF OBJECT IN A0				 *
* A0 = PTR TO OBJECT							 *
*								         *
**************************************************************************
CLRVEL
	PUSH	A8
	MOVE	A0,A8
	CALLR	CLR_VEL
	PULLQ	A8
	RETS

**************************************************************************
*								         *
* CHANGE_OID - ROUTINE TO CHANGE THE OID OF AN ACTIVE OBJECT.  THIS	 *
* 		MUST BE USED TO HANDLE CORRECT SUPP LIST		 *
* 		SWITCHING.						 *
* A1 = NEW OID								 *
* A8 = PTR TO OBJECT							 *
*								         *
**************************************************************************
CHANGE_OID
	CALLR	PULL_SUPP		;GET IT OFF ITS CURRENT LIST
	MOVE	A1,*A8(OID),W		;SHOW US THE WAY
	JRUC	INSERT_SUPP		;AND PUT IT ON THE NEW LIST


**************************************************************************
*								         *
* CHANGE_OID_MULTI - Change the OID of every object in a Multiparter	 *
* 			including and after the given object.		 *
* A1 = New OID								 *
* A8 = Ptr to first part to change					 *
*								         *
**************************************************************************
CHANGE_OID_MULTI
	PUSH	A8
COM_LP
	CALLR	CHANGE_OID
	MOVE	*A8(OPARTS),A8,L
	JRNZ	COM_LP
	PULLQ	A8
	RETS

**************************************************************************
*								         *
* CHANGEOID - ROUTINE TO CHANGE THE OID OF AN ACTIVE OBJECT.  THIS	 *
* 		MUST BE USED TO HANDLE CORRECT SUPP LIST		 *
* 		SWITCHING.						 *
* 		A0 VERSION.						 *
* A0 = PTR TO OBJECT							 *
* A1 = NEW OID								 *
*								         *
**************************************************************************
CHANGEOID
	CALLR	PULLSUPP		;GET IT OFF ITS CURRENT LIST
	MOVE	A1,*A0(OID),W		;SHOW US THE WAY
	JRUC	INSSUPP			;AND PUT IT ON THE NEW LIST

**************************************************************************
*								         *
* CHANGE_OIDS - CHANGE ALL MATCHING OID'S ON EVERY PLANE TO A NEW ONE.	 *
* A0 = OID TO CHANGE							 *
* A1 = NEW OID								 *
*								         *
**************************************************************************
CHANGE_OIDS
	PUSH	A7
	MOVI	CHANGE1OID,A7
	CALLR	FGPLANE_LP
	PULLQ	A7
	RETS

CHANGE1OID
	MOVE	*A8(OID),A14,W
	CMP	A0,A14
	JRNE	CHNG1X			;THIS IS NOT ONE OF THEM
	CALLR	PULL_SUPP
	MOVE	A1,*A8(OID),W		;STUFF THE NEW ONE
	CALLR	INSERT_SUPP
CHNG1X
	RETS

**************************************************************************
*								         *
* FGPLANE_LP - VERY GENERIC ROUTINE TO APPLY A FUNCTION TO EVERY	 *
* 		OBJECT ON THE FOREGROUND PLANE.				 *
* A7 = PTR TO FUNCTION							 *
*								         *
**************************************************************************
FGPLANE_LP
	MMTM	SP,A8,A9
	MOVI	FGLIST,A8
	MOVE	A8,A9
	JRUC	FGP_TST
FGP_LP
	CALL	A7
FGP_TST
	MOVE	*A8,A8,L
	CMP	A8,A9
	JRNZ	FGP_LP

	MMFM	SP,A8,A9
	RETS
	
**************************************************************************
*								         *
* STORE_ZVAL - STORE THE GIVEN 32 BIT Z VALUE IN THE OBJECT AND ALL	 *
* 		OF ITS PARTS. PARTS WILL HAVE ZVAL CHANGED BY OZOFF.	 *
* A1 = ZVAL								 *
* A8 = OBJECT (HEAD IF MULTI-PARTER)					 *
*								         *
**************************************************************************
STORE_ZVALH
;alternate entry point to use OZOFF for head obj
	PUSH	A8
	jruc	SZ_LP
STORE_ZVAL
	PUSH	A8
	MOVE	A1,*A8(OZVAL),L		;SET HEAD OBJECT, NO OZOFF USED
	MOVE	*A8(OPARTS),A8,L	;MORE PARTS?
	JRZ	SZ_X			;BR = NO
SZ_LP
	MOVB	*A8(OZOFF),A14	
	ADD	A1,A14
	MOVE	A14,*A8(OZVAL),L
	MOVE	*A8(OPARTS),A8,L	;IS THERE ANOTHER PART?
	JRNZ	SZ_LP			;BR = YES
SZ_X
	PULLQ	A8
	RETS

**************************************************************************
*								         *
* STOREZVAL - STORE THE GIVEN 32 BIT Z VALUE IN THE OBJECT AND ALL	 *
* 		OF ITS PARTS. ALL WILL HAVE ZVAL CHANGED BY OZOFF.	 *
* 		A0 VERSION						 *
* A0 = OBJECT (HEAD IF MULTI-PARTER)					 *
* A1 = ZVAL								 *
*								         *
**************************************************************************
STOREZVAL
	PUSH	A8
	MOVE	A0,A8
	CALLR	STORE_ZVALH
	PULLQ	A8
	RETS

**************************************************************************
*								         *
* KILOBJ_ALL - KILL ALL OBJECTS OF THE GIVEN I.D.			 *
* A0 = OID (16 BITS)							 *
*								         *
**************************************************************************
KILOBJ_ALL:	
	PUSH	A1
	CLR	A1
	NOT	A1
	CALLR	KILOBJ
	PULLQ	A1
	RETS


**************************************************************************
*								         *
* KILOBJ - KILL A CLASS OF OBJECTS ON ALL FOREGROUND PLANES		 *
* A0 = OID (16 BITS)							 *
* A1 = MASK: MASK BITS OF ZERO ARE DONT CARES (16 BITS)			 *
*								         *
**************************************************************************
KILOBJ
	MMTM	SP,A0,A2,A3,A8
	MOVI	FGLIST,A8

	MOVE	A0,A2
	SEXT	A2
	AND	A1,A2		;FORM MATCH

	MOVE	A8,A0
	JRUC	KO_TST
KO_LP	
	MOVE	*A0(OID),A14,W
	AND	A1,A14		;CAN DONT CARE BITS
	CMP	A2,A14		;MATCH?
	JRNE	KO_TST		;NO

	MOVE	*A0,A3,L
	CALLR	DELOBJ
	MOVE	A3,A0
	JRUC	KO_TST2
KO_TST
	MOVE	*A0,A0,L
KO_TST2
	CMP	A0,A8
	JRNE	KO_LP

	MMFM	SP,A0,A2,A3,A8
	RETS

**************************************************************************
*								         *
* EXISTOBJ_ALL - FIND ANY OCCURANCE OF AN OBJECT OF GIVEN I.D.		 *
* A0 = OID								 *
* RETURNS:								 *
* 	Z BIT SET = NO OBJECT, A0 = 0					 *
* 	Z BIT CLR = OBJECT, A0 = PTR TO OBJECT				 *
*								         *
**************************************************************************
EXISTOBJ_ALL
	PUSH	A1
	CLR	A1
	NOT	A1
	CALLR	EXISTOBJ
	PULL	A1
	RETS

**************************************************************************
*								         *
* 	EXIST_OBJ_ALL							 *
* 									 *
* 	Find any occurance of an object of Given I.D.			 *
* 									 *
* 	A0 = OID							 *
* 									 *
* 	Returns:							 *
* 		 Z = No object found, A8 = 0				 *
* 		NZ = Found match, A8 = Ptr to object			 *
*								         *
**************************************************************************
EXIST_OBJ_ALL
	PUSH	A0
	CALLA	EXISTOBJ_ALL
	MOVE	A0,A8
	PULL	A0
	RETS

**************************************************************************
*								         *
* 	RESUME_EXIST_OBJ_ALL						 *
* 									 *
* 	Resume search for objects of given I.D.				 *
* 									 *
* 	A0 = OID							 *
* 	A8 = Last object found						 *
* 									 *
* 	Returns:							 *
* 		 Z = No more objects found, A8 = 0			 *
* 		NZ = Found another one, A8 = Ptr to object		 *
*								         *
**************************************************************************
RESUME_EXIST_OBJ_ALL
	MMTM	SP,A0,A1
	CLR	A1
	NOT	A1
	CALLR	RESUME_EXIST_OBJ
	MOVE	A0,A8
	MMFM	SP,A0,A1
	RETS

**************************************************************************
*								         *
* 	RESUME_EXISTOBJ							 *
* 									 *
* 	Entrypoint to EXISTOBJ, where you give the starting		 *
* 	point of the search.						 *
* 									 *
* 	A0 = OID to search for						 *
* 	A1 = OID mask (0 bits mean "don't care")			 *
* 	A8 = Search entrypoint, non-inclusive				 *
* 									 *
* 	Returns:							 *
* 									 *
* 		 Z = No object found, A0 = 0				 *
* 		NZ = Matching object found, A0 = Ptr to object		 *
*								         *
**************************************************************************
RESUME_EXIST_OBJ
	MMTM	SP,A2,A8
	MOVE	A0,A2
	SEXT	A2
	AND	A1,A2		;FORM MATCH
	MOVE	A8,A0
	MOVI	FGLIST,A8
	JRUC	EO_TST

**************************************************************************
*								         *
* 	EXIST_OBJ							 *
* 									 *
* 	Find any occurance of an object of Given I.D.			 *
* 									 *
* 	A0 = OID							 *
* 	A1 = OID mask (0 bits mean "don't care")			 *
* 									 *
* 	Returns:							 *
* 		 Z = No object found, A8 = 0				 *
* 		NZ = Found match, A8 = Ptr to object			 *
*								         *
**************************************************************************
EXIST_OBJ
	PUSH	A0
	CALLA	EXISTOBJ
	MOVE	A0,A8
	PULL	A0
	RETS

**************************************************************************
*								         *
* 	EXISTOBJ							 *
* 									 *
* 	Search for an object of certain class on the foreground		 *
* 	list.								 *
* 									 *
* 	A0 = OID							 *
* 	A1 = OID Mask (0 bits mean "don't care")			 *
* 									 *
* 	Returns:							 *
* 									 *
* 		 Z = No object found, A0 = 0				 *
* 		NZ = Matching object found, A0 = Ptr to object		 *
*								         *
**************************************************************************
EXISTOBJ
	MMTM	SP,A2,A8
	MOVI	FGLIST,A8

	MOVE	A0,A2
	SEXT	A2
	AND	A1,A2		;FORM MATCH

	MOVE	A8,A0
	JRUC	EO_TST

EO_LP	
	MOVE	*A0(OID),A14,W
	AND	A1,A14		;CAN DONT CARE BITS
	CMP	A2,A14		;MATCH?
	JREQ	EO_X		;YES!

EO_TST
	MOVE	*A0,A0,L	;GET NEXT OBJECT
	CMP	A0,A8		;IS THAT ALL?
	JRNE	EO_LP		;BR = NO, TRY MORE
	CLR	A0		;FAILED
EO_X	
	MOVE	A0,A0

	MMFM	SP,A2,A8
	RETS

*REMOVED EXISTOBJ_PLANE

**************************************************************************
*								         *
* COUNT_HEADS - COUNT ONLY THE HEAD PARTS OF MULTI-PART OBJECTS.	 *
* A0 = OID (16 BITS) TO COUNT						 *
* A1 = MASK: MASK BITS OF ZERO ARE DONT CARES (16 BITS)			 *
* RETURNS								 *
* 	A6 = COUNT							 *
*								         *
**************************************************************************
COUNT_HEADS
	MMTM	SP,A0,A2,A3

	MOVE	A0,A3
	SEXT	A3
	AND	A1,A3		;FORM MATCH

	CLR	A6

	MOVI	FGLIST,A2

	MOVE	A2,A0
	JRUC	CHP_TST

CHP_LP	
	MOVE	*A0(OID),A14
	AND	A1,A14		;CAN DONT CARE BITS
	CMP	A3,A14		;MATCH?
	JRNE	CHP_TST		;NO

	MOVE	*A0(OPART1),A14,L
	JRNZ	CHP_HEAD_TST	;BR = A MULTI-PARTER
	INC	A6		;COUNT THE SOLO OBJECT
	JRUC	CHP_TST
CHP_HEAD_TST
	CMP	A0,A14		;IS THIS THE HEAD?
	JRNE	CHP_TST		;BR = NO
	INC	A6
CHP_TST
	MOVE	*A0,A0,L
	CMP	A0,A2
	JRNE	CHP_LP

	MMFM	SP,A0,A2,A3
	RETS

**************************************************************************
*								         *
* FIND_HEAD - FIND A HEAD PART ON A PLANE THAT MATCHES THE		 *
* 		  GIVEN I.D.						 *
* A0 = OID (16 BITS) TO COUNT						 *
* A1 = MASK: MASK BITS OF ZERO ARE DONT CARES (16 BITS)			 *
* RETURNS								 *
* 	 Z = NONE FOUND							 *
* 		A0 = 0							 *
* 	NZ = FOUND ONE							 *
* 		A0 = PTR TO OBJECT					 *
*								         *
**************************************************************************
FIND_HEAD
	MMTM	SP,A2,A3

	MOVE	A0,A3
	SEXT	A3
	AND	A1,A3		;FORM MATCH
	MOVI	FGLIST,A2
	MOVE	A2,A0
	JRUC	FHP_TST

FHP_LP	
	MOVE	*A0(OID),A14
	AND	A1,A14		;CAN DONT CARE BITS
	CMP	A3,A14		;MATCH?
	JRNE	FHP_TST		;NO

	MOVE	*A0(OPART1),A14,L
	JRZ	FHP_TST		;BR = NOT A MULTI-PARTER
	CMP	A0,A14		;IS THIS THE HEAD?
	JRNE	FHP_TST		;BR = NO
	MOVE	A0,A0
	JRUC	FHP_X
FHP_TST
	MOVE	*A0,A0,L
	CMP	A0,A2
	JRNE	FHP_LP
     	CLR	A0
FHP_X
	MMFM	SP,A2,A3
	RETS

**************************************************************************
*								         *
* 	OBJ_UNIV_TO_SCREEN						 *
* 									 *
* 	Turn a universe object into a screen object right where		 *
* 	it is.  This assumes that the object is currently onscreen.	 *
* 									 *
* 	A8 = Ptr to universe object					 *
* 									 *
* 	Returns:							 *
* 		Nothing							 *
*								         *
**************************************************************************
OBJ_UNIV_TO_SCRN
	MMTM	SP,A2,A3,A5
	MOVE	A8,A14
	ADDI	OXVAL,A14
	MMFM	A14,A2,A3,A5		;A2 = OZVAL; A3 = OYVAL; A5 = OXVAL

	UTOSXY	A2,A5,A3

	SLL	16,A3
	MOVX	A5,A3

	ORIM	M_SCRNOBJ,*A8(OFLAGS),W

	CALLR	OBJ_TO_PNT
	
	MMFM	SP,A2,A3,A5
	RETS

************************************************************************
*
*                   CONVERSION ROUTINES
*
*	Also available in MACRO form (TOWORLDX,TOWORLDY,TOSCRNX,TOSCRNY)
*
*	Remember,   SCRN = WORLD/Z + HALF
*
************************************************************************
*
* ENTRY:
*	a0 = Z	 
*	a1 = world Y or univ Y
*
*  EXIT:
*	a0,a14 = trashed
*	a1 = screen Y 
*
UNIV_TO_SCRN_Y:
	move	@YBASE,a14,L
	add	a14,a1		; convert from univ to world
WRLD_TO_SCRN_Y:
	DIVS	a0,a1		;TRANSLATE 3-D WORLD IN SCRN COORDINATES
	move	@YHALF,a0
	ADD	a0,a1		; add HALFY
	rets

*
* ENTRY:
*	a0 = Z   
*	a1 = world X or univ X
*
*  EXIT:
*	a0,a14 = trashed
*	a1 = screen X 
*
UNIV_TO_SCRN_X:
	move	@XBASE,a14,L
	sub	a14,a1		; convert from univ to world
WRLD_TO_SCRN_X:
	DIVS	a0,a1		;TRANSLATE 3-D WORLD IN SCRN COORDINATES
	ADDI	HALFX,a1	; add HALFX
	rets

*
* ENTRY:
*	a0 = desired screen Y
*	a1 = Z pos
*
*  EXIT:
*	a0,a14 = trashed
*	a1 = world Y 
*
SCRN_TO_WRLD_Y:
	move	@YHALF,a14
	sub	a14,a0
	setf	10,1,1		
	mpys	a0,a1		; result in a1
	setf	32,0,1		
	rets

	
*
* ENTRY:
*	a0 = desired screen X
*	a1 = Z pos
*
*  EXIT:
*	a0,a14 = trashed
*	a1 = world X 
*
SCRN_TO_WRLD_X:
	subi	HALFX,a0
	setf	10,1,1	       
	mpys	a0,a1		; result in a1
	setf	32,0,1	       
	rets
	

;
;*	a0 = screen y
;*	a1 = universe Y
;GET_Z_FRM_UY:
;	move	@YHALF,a14
;	sub	a14,a0		; screen Y - half Y
;	move	@YBASE,a14,L
;	add	a14,a1		; world Y
;	divs	a0,a1
;	rets





	.if OLD_WAY==1

**************************************************************************
*								         *
* SCRTST - TEST IF OBJECT IS ON SCREEN.  IF THIS IS THE HEAD OF A MULTI- *
* 	  PART OBJECT, THEN THE WHOLE THING IS TESTED.			 *
* 	  *** NOTE **** ALL PARTS OF A MULTI-PARTER ARE ASSUMED TO EXIST *
* 			ON THE SAME PLANE.				 *
* A8 = OBJECT								 *
* RETURNS								 *
* 	EQ IF ON SCREEN							 *
*								         *
**************************************************************************
*
*SCRTSTG - PARMS A2=TL, A3=LR
*
SCRTSTG
	MMTM	SP,A0,A2,A3,A7,A8
	JRUC	SCRTST_CKM
*NORMAL SCREEN BOUNDRIES
SCRTST:
	MMTM	SP,A0,A2,A3,A7,A8

	MOVE	@SCRNTL,A2,L		;GET SCREEN TOP LEFT
	MOVE	@SCRNBR,A3,L		;GET SCREEN LOWER RT.
SCRTST_CKM
	MOVE	*A8(OPART1),A7,L	;ARE WE A MULTI-PARTER
	JRZ	SCRTST1			;BR = NO
	CMP	A7,A8			;IS THIS THE HEAD PART?
	JREQ	SCRTST1			;BR = YES
	CLR	A7			;DO NOT DO A MULTI-PART CHECK
SCRTST1
SCRTST_MULTI_LP
	MOVE	*A8(ODAG),A0,L

	CMPXY	A3,A0			;IS IT LOWER THAN LOWER RT?
	JRYGE	SCRTF			;LOWER
	JRXGE	SCRTF			;TO THE RIGHT

	MOVE	*A8(OSIZE),A14,L
	ADDXY	A0,A14			;GET LOWER RT OF OBJECT

	CMPXY	A2,A14
	JRYLE	SCRTF			;ABOVE...
	JRXLE	SCRTF			;TO THE LEFT..

	CLR	A0
	JRUC	SCRTX		;RETURN EQ (ON SCREEN)
SCRTF:
	MOVE	A7,A7			;MULTI-PART CHECK?
	JRZ	SCRT_DONE		;BR = NO
*GET THE NEXT PART OF A MULTI-PART OBJECT.
* IF IT IS TURNED "OFF" OR NOT ACTIVE, THEN NO CHECK IS PERFORMED.
SCRTST_PART_LP
	MOVE	*A8(OPARTS),A8,L	;NEXT?
	JRZ	SCRT_DONE		;BR = NO MORE PATIENTS

;	MOVE	*A8(OCTRL),A14,W	; OLD WAY
;	SLL	28,A14			;IS THIS OBJECT ON?
;	JRZ	SCRTST_PART_LP		;BR = NO

	move	*a8(OFLAGS),a14
	btst	B_NODISP,a14
	JRNZ	SCRTST_PART_LP		;BR = NO

	MOVE	*A8(OLINK),A14,L	;IS OBJECT INSERTED?
	JRZ	SCRTST_PART_LP		;BR = NO
	JRUC	SCRTST_MULTI_LP
SCRT_DONE
	MOVK	1,A0
	MOVE	A0,A0		;RETURN NE (NOT ON SCREEN)
SCRTX:
	MMFM	SP,A0,A2,A3,A7,A8
	RETS

****************************************************************************
* MULTIMAKE
* Use a Create Script to allocate and initialize obj(s)
* B0 ptr to Create Script w/ following format
*    .byte OBJCNT, PRCCNT, IMGPALCNT, PALCNT
*        PRCCNT must be >= # of procs that will be allocated in CFUNCS
*        FOR IMGPALCNT
*    .long IMG->PAL	;PAL TO BE FOUND OR HAVE AVAILABLE SLOT FOR
*        FOR PALCNT
*    .long PAL		;PAL TO BE FOUND OR HAVE AVAILABLE SLOT FOR
*        FOR OBJCNT, FOLLOWING ENTRIES NEEDED
* use MACRO LLWWWL to place following items on single line
*    .long IMG, OCVECT
*    .word OID, OCTRL, OFLAGS, OZOFF
*    .long CFUNC
*    [.word/.long parms to CFUNC]
*
* MULTIMAKE automatically links all objs together as multi-parter w/
* 1st obj as head obj
*
* PARMS B0 script ptr, A10-A11 passed to each PROC created unless
*          they are modified by CFUNCS
*
* RETURNS
*   A8 ptr to head obj of uninserted multi-parter.
*   Immediately follow with INSERT_OBJ to insert.
*   Zflag set if not enough OBJS, PROCS or PALS
* !!!!!!!!  assume ALL REGS (A&B) TRASHED but A9,A10,A11,A12,A13  !!!!!!!!!
*
*
* CFUNC - Create Functions
*   gets new obj in A0, initialized and linked into MULTI-PARTER
*   A8 ptr to first obj of script (head of MULTI-PARTER)
*   ptr to Create Script in B0, must inc B0 as CFUNC parms read.
*   Is free to trash all A regs but A8,A9,A10,A11,A12,A13
*   Must preserve all BREGS except B14 and
*   B0 which must point after CFUNC parms
*
*
MULTIMAKE
	PUSH	A9			;THIS WILL BE THE PREVIOUS OBJ PTR
	clr	A8			;First Obj

	;*** CHECK OBJCNT
	movb	*B0,B7			;B7 # objs to allocate
	move	@OFREECNT,B2,W
	cmp	B2,B7
	jrgt	MAKEX
	addk	8,B0

	;*** CHECK PRCCNT
	movb	*B0,B1			;B1 >= # of procs to allocate
	move	@PFREECNT,B2,W
	cmp	B2,B1
	jrgt	MAKEX
	addk	8,B0

	move	@FREEPALCNT,B3,W
	;FOR EACH PAL NOT FOUND, DEC FREEPALCNT - JRN MAKEX
	movb	*B0,B1			;IMGPALCNT
	addk	8,B0
	movb	*B0,B2			;PALCNT
	addk	8,B0

	inc	B1
ImgPalLp
	dec	B1
	jrle	SkImgPalCk
	move	*B0+,B4,L
	move	B4,A0
	move	*A0(ICMAP),A0,L
	calla	FINDPAL
	jrnz	ImgPalLp
	;*** PAL NOT FOUND ***
	dec	B3
	jrn	MAKEX
	jruc	ImgPalLp
SkImgPalCk

	inc	B2
PalLp
	dec	B2
	jrle	SkPalCk
	move	*B0+,B4,L
	move	B4,A0
	calla	FINDPAL
	jrnz	PalLp
	;*** PAL NOT FOUND ***
	dec	B3
	jrn	MAKEX
	jruc	PalLp
SkPalCk


	;THERE IS ENOUGH OBJS, PROCS AND PALS SO GO AHEAD AND ALLOCATE
	clr	B3		;OBJECT #
MkObjLp
	inc	B3
	move	*B0+,B1,L
	move	B1,A1
	callr	GETOBJ
	callr	FPSTFOBJ0
	move	A0,B1
	movb	B3,*B1(OPARTID)		;store # of PART
	move	*B0+,B2,L		;Load OCVECT
	move	B2,*B1(OCVECT),L
	move	*B0+,B2,W		;Load OID
	move	B2,*B1(OID),W
      
	move	*B0+,B2,W		;Load OCTRL
	MOVE	*B0+,B4,W		;Load OFLAGS
	MOVE	B4,*B1(OFLAGS),W
	btst	B_FLIPH,B2
	jrnz	MkFlp
	btst	B_FLIPV,B2
	jrz	SkMkFlp
MkFlp
	move	B2,A4
	PUSH	A8
	move	A0,A8
	;A1 still set from above
	calla	ANI
	PULLQ	A8
	jruc	MkFlagsOk
SkMkFlp
	move	*B1(OCTRL),B4,W
	OR	B2,B4
	move	B4,*B1(OCTRL),W
MkFlagsOk
	MOVE	*B0+,B2,W		;Load OZOFF

	MOVE	B2,A2			;A2 WILL BE TEMP OZOFF STORAGE
	MOVB	B2,*B1(OZOFF)
	move	A8,A8
	jrnz	SkMkFirst
	move	A0,A8
	jruc	SkINSPART
SkMkFirst
****	callr	INSPART
	MOVE	A0,*A9(OPARTS),L	;LINK NEW OBJECT AT END
;	movb	*A8(OPLANE),*A0(OPLANE)
	move	*A8(OZVAL),A14,L
	move	*A8(OZOFF),A9,W
	sub	A9,A14
	ADD	A2,A14
	MOVE	A14,*A0(OZVAL),L
SkINSPART
	MOVE	A8,*A0(OPART1),L	;VALIDATE HEAD PTR
	MOVE	A0,A9			;KEEP PREVIOUS PART FOR PART LINKUP
	move	*B0+,B2,L		;Load CFUNC
	jrz	MkNxtObj
	PUSH	A8
	call	B2			;DO CFUNC
	PULLQ	A8
MkNxtObj
	cmp	B7,B3
	jrlt	MkObjLp
	CMPK	1,B3		;MORE THAN ONE OBJECT CREATED?
	JRNE	MAKEX		;BR = YES, IT IS MULTI
	CLR	A14
	MOVE	A14,*A8(OPART1),L	;MAKE IT LOOK SINGLE
MAKEX
	PULLQ	A9
	move	A8,A8		;Set Z Flag
	rets


	.endif


.END


