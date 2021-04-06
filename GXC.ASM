 	.MLIB	"GXMACS.LIB"
	.FILE	"GXC.ASM"
	.TITLE	"<<< GENERATION X -- CACHE ALIGNED STUFF >>>"
	.WIDTH	132
	.OPTION	B,D,L,T
	.MNOLIST

**************************************************************************
*								         *
* 	COPYRIGHT (C) 1992 MIDWAY MANUFACTURING COMPANY.		 *
* 		       ALL RIGHTS RESERVED.				 *
*								         *
**************************************************************************


OFFSET_CLIP	.set 1		; if 0, use DMA's window clip

*	GET THE SYSTEM STUFF
	.INCLUDE	"GX.INC"

	.def	PULLANIMFUNC

	.ref	ANIFUNCSX 

	.if	DEBUG

	.BSS	LAST_DMA,32*6
	
	.endif

	.BSS	IN_ANIM,16	;UHB '1' when processing anim funcs
	.bss	filler,16	; to keep long word aligned
;	.BSS	ANIM_LIST_TEMP,32


;	.sect	"CACHE1"

	.text

*
*The following align encompasses a CACHE segement from here to the end
*of the DMAINT.
*
	.ALIGN

**************************************************************************
;*** DEPENDS ON A LOT OF REGISTERS BEING SET UP IN DISPLAY -- careful ***

PlaneLp
	;*** PLOT THE BGND PLANE ***
	move	B8,A0			;Get Obj List Head
	subi	PLNSIZ,B8
	move	A0,A4			;needs both A0,A4 start of list
	callr	DISPNEXT_FG		
PutPlanes:
	cmpi	BGLISTS,B8
	jrge	PlaneLp

*
*	DISPLAY FOREGROUND
*
DispFG:
	movi	FGLIST,a0		
	move	a0,a4
	callr	DISPNEXT_FG
	rets
**************************************************************************

**************************************************************************
*								         *
* DISPNEXT:								 *
* 									 *
* 	A4 is start of FGLIST						 *
* 	A9  becomes VS:HS						 *
* 	A10 becomes DAG Y:X						 *
* 	A11 becomes SAG							 *
* 	A12 becomes CTRL:OFSET						 *
* 									 *
* 	A2,A3,A6,A7 used						 *
*								         *
**************************************************************************
DISPNEXT_FG:

;	movi	YMINTBL+SIZYMINTBL,b6
	movi	SCRBOT<<16,b7
	clr	b8	 	; 0 for one page
	move	@PAGE,b14,W
	jrz	DISPNEXT
	movI	[SCRHGHT,SCRHGHT],b8	; constanst for other
	jruc	DISPNEXT
	
CLIP_LOOP:
	movb	*a0(OFLAGS),a1
	jrn	DISPNEXT	; dont bother if marked as offscreen
	btst	B_NODISP,a1	; 
	jrnz	DISPNEXT      	; dont bother if marked as NODISP

*	Check for flipping, necessity of clipping, adjust offset, SAG
*	a0 is the address of the object block
* 	a1 scratch
*	a2 = SCALE FACTORS
* 	A3=AMOUNT TO CLIP OFF TOP, LEFT	(TC:LC)
*	A4=LIST START
*	A5 Page Offset
*	a6=becomes scaled size
*	A7=TOTAL CLIPT	(TC+BC:LC+RC)
*	a8=Temp register used in the OFFSET clip loop
*	a9 becomes VS : HS
*	a10 is DAG (Y : X)
*	a11 is the SAG
*	a12 is the control word b0-15; offset b16-31
*	a13 is the window BOTTOM RT	
*	a14 is the window TOP LEFT
*
*	ROAD - TAKEN OUT b0 is ptr to YMINTBL
*	b2 is DMAREGS
*	b3 is non-zero when a new WINDOW is to be stored
*	b5 is MIRROR/NOMIRROR JUMP
*	ROAD - TAKEN OUT	b6    YMINTBL+SIZYMINTBL
*	B6 is NOW USED for scale mama processing check
*	b7    SCRBOT<<16
*	b8    [SCRHGHT,SCRHGHT] or 0 depending on PAGE
*	b9 used for hill/window
*	B10   SCREEN_WIDTH-1, used in DCLIP loop for MIRROR
*
*  COMPUTE LC, RC, TC, BC
*
	move	a0,a1
	addi	OFSET,a1
	mmfm	a1,a12,a11,a10,a9,a6,a3,a2
			; CTRL:OFSET in a12,
			; SAG in a11,
			; DAG in a10,
			; Unscaled size in a9,
			; SCALED SIZE in a6,
			; CONST:PAL in a3,
			; SCALE Y:X in a2
	MOVE	A12,A12
	JRNN	DISPNEXT		;BR = OBJECT IS OFF

;	MOVE	A2,B14
;	CMP	B6,B14		;Did scale_mama process us?
;	JREQ	DISPNEXT	;BR = No

	.if	BILL|NOBODY

;	MOVI	[3,4],A1
;	CMPXY	A1,A9
;	JRXLT	DISPNEXT
;	JRYLT	DISPNEXT

	.endif

*
*NOTE: Since OFFSET clipping is now being used again, the HILL code
*	will no longer work correctly.  It will have to be fixed to
*	make nice with the clip loop before it is used again. 6/19/93
*
*	a8=ZPOS of current hill	<--- That is the point of contention
*

;	move	*a0(OZVAL),a1,L		; ZPOS of obj
;	JRN	samehill		; !!!
;	cmp	a8,a1
;	jrge	samehill
;	move	a1,b14			; save in B file
;chknxtZ:
;	cmp	b6,b0
;	jrne	newhill
;	clr	b9			; full window
;	move	b7,b3
;	jruc	lasthill
;newhill:
;	move	*b0+,b9,L		; new Z pos
;	move	*b0+,b3,L		; new scrn Y:junk
;lasthill:
;	cmp	b9,b14			; is obj past this hill?
;	jrlt	chknxtZ
;	move	b9,a8
;	move	b3,a1
;	movy	a1,a13			; new window bottom
;	move	a14,b14
;	rl	16,b14			; get top in lower 16 bits
;	movx	b14,b3			; b3 contains bottom:top
;	ADD	b8,b3			; Page offset
;samehill:

	.if	OFFSET_CLIP==1
	cmpi	[40h,40h],a2		; guard against too much growing
	jrle	DISPNEXT

	move	a3,b9	; save CONST:PAL in B until needed

	jump	B5			;ARE WE MIRRORING?
DCLIP_MIRROR
	move	b10,a1
	subxy	A6,a1			;(SCREEN_WIDTH-1)-XWIDTH
	subxy	A10,a1			;(SCREEN_WIDTH-1)-XWIDTH-XPOS
	movx	a1,A10
	xori	M_FLIPH<<16,A12	 	;FLIP M_FLIPH (set when creating obj)
DCLIP_NOMIRROR

	BTST	B_COMPRESS+16,A12
	JRNZ	NOCLIP	      	;BR=OBJECT IS COMPRESSED

	clr	a1     	; use for clearing now, becomes offset later
	move	a10,a8 		; PT in a8
	addxy	a6,a8 		; lower right in a8
	subxy	a13,a8		; PT - WEND -> a8  ( BC : RC )
	JRYGE	dis_clp0	; JRYNN
	movy    a1,a8  		; clear BC if y negative
dis_clp0:
	JRXGE	dis_clp1	; JRXNN
	movx   	a1,a8  		; clear RC if x negative
dis_clp1:
	move   	a14,a7 		; move WSTART
	clr    	a3		
	subxy	a10,a7	    	; WSTART - PT -> a7 (TC : LC)
	JRYLT  	dis_clp2	; JRYN
	movy   	a7,a3	    	; TC in upper half of a3
	movy   	A14,a10	    	; adjust start position to window edge
dis_clp2:
	JRXLT  	dis_clp3	; JRXN
	movx   	a7,a3	    	; LC in lower half of a3
	movx   	A14,a10	    	; adjust start position to window edge
dis_clp3:
	move	a8,a7		; save BC:RC in case of swap

	add	a3,a7	    	; (TC+BC : LC+RC) in a7
	JREQ	NOCLIP		; TOTAL CLIP IS ZERO, NOCLIP

;	SUBK	2,A6		;Compensate for DMA bogusness
;	SUBK	4,A6		;Compensate for DMA bogusness

	SUBXY	A7,A6	    	; GET CLIPPED SIZE...TOTALLY CLIPPED?
	JRXLE	DISPNEXT 	; don't display it. It is completely offscreen
	JRYLE	DISPNEXT

;	ADDK	2,A6		;Compensate for DMA bogusness
;	ADDK	4,A6		;Compensate for DMA bogusness

DIS_CALC_OFFSET
******	ORI	M_LRCLIP<<16,A12	; SET CLIP BIT                      ;NEW
*
*	Adjust Clip for Flip
*
	BTST	B_FLIPH+16,A12
	JRZ	NOHLIP	     	;BR if OBJECT IS HORIZONTALLY (SP) FLIPPED 
	MOVX	A8,A3		; LC is actually RC
NOHLIP
	BTST	B_FLIPV+16,A12
	JRZ	NOVLIP		;BR if THE OBJECT IS NOT VERTICALLY FLIPPED
	MOVY	A8,a3	     	; TC is actually BC	
NOVLIP
*
*	OFFSET = (LC+RC)*SCALEX
*
	SETF	16,1,1
				; a1 known to be zero at this point
	move	a2,a8
	sext	a8		; XSCALE in a8
	movx	a7,a1		; LC+RC in a1
	mpyu	a8,a1		; offset (in pixels) 
	srl	8,a1
;	sll	8,a1		; WHY?
	movx	a1,a12		; Store OFSET for DMA
*
*	Y SIZE ADJ = (TC+BC)*SCALEY
*
	move	a2,a1
	srl	16,a1		; YSCALE in a1
	srl	16,a7		; TC+BC in a7
	jrz	no_yadj
	mpyu	a1,a7
	srl	8,a7
	sll	16,a7
	subxy	a7,a9		; sub # clipped lines from total Y size	
no_yadj:
*
*	SAG ADJUST = ( ((TC*SCALEY)*USIZEX) + (LC*SCALEX))*BPP
*
	move	a3,a7
	srl	16,a7	    	; TC in a7
	jryz	no_TC
	mpyu	a7,a1		; TC*SCALEY in a1
	srl	8,a1
	movx	a9,a7
	mpyu	a1,a7		; TC*SCALEY*XSIZE in a7
no_TC:
	sext	a3		; LC in a3
	mpyu	a8,a3		; LC*SCALEX in a3
	srl	8,a3
	add	a7,a3 		; (TC*SCALEY*XSIZE)+(LC*SCALEX) in a3
	jrz	no_SAGadj	
	move	a12,a1
	sll	1,a1		; isolate BPP field
	srl	29,a1		 
	jrnz	noadd8
	addk	8,a1
noadd8:
	mpyu	a3,a1
	add	a1,a11		; adjust SAG
no_SAGadj:
	SETF	32,1,1

	MOVE	A12,A8
	SEXT	A8
	JRZ	NOCLIP		;BR = No horizontal clipping
	MOVE	A9,A8
	SUBXY	A12,A8		;Diff between the X size and offset
	SEXT	A8
	CMPK	4,A8		
	JRLE	DISPNEXT	;BR = It got way too small

NOCLIP:		    
	subi	10001h,a6
	clr	a1	
	BTST	B_FLIPH+16,A12
	JREQ	NOH	       		;BR=OBJECT IS NOT HORIZONTALLY FLIPPED
	MOVX	A6,A1
NOH 
	BTST	B_FLIPV+16,A12
	JREQ	NOV			;BR=OBJECT IS NOT VERTICALLY FLIPPED		     	
	MOVY	A6,A1
NOV
	ADDXY	A1,A10			;COMPENSATE

	;*** CLIPPING DONE, WHAT DO WE DO WITH IT?? ***
	addxy	A5,A10		; add PAGE OFFSET to dest Y:X
	move	b9,a3		; bring back PAL:CONST from B regs

	.else

*
*	BOX OVERLAP COLLISION
*
*	a10 = Top left, box 1 
*	a1 = Bottom right, box 1
*	a14 = Top left, box 2
*	a13 = Bottom right, box 2
*

	move	a10,a1
	addxy	a6,a1		; bottom right in a1	
	cmpxy	a10,a13	       
	jrxle	DISPNEXT       
	jryle	DISPNEXT
	cmpxy	a14,a1
	jrxle	DISPNEXT
	jryle	DISPNEXT

	jump	B5			;ARE WE MIRRORING?
DCLIP_MIRROR
	move	b10,a1
	SUBXY	A6,A1			;(SCREEN_WIDTH-1)-XWIDTH
	subxy	A10,a1			;(SCREEN_WIDTH-1)-XWIDTH-XPOS
	movx	a1,A10
	xori	M_FLIPH<<16,A12	 	;FLIP M_FLIPH (set when creating obj)
DCLIP_NOMIRROR

	clr	a1	
	BTST	B_FLIPH+16,A12
	JREQ	NOH	       		;BR=OBJECT IS NOT HORIZONTALLY FLIPPED
	MOVX	A6,A1
	dec	a1
NOH 
	BTST	B_FLIPV+16,A12
	JREQ	NOV			;BR=OBJECT IS NOT VERTICALLY FLIPPED		     	
	MOVY	A6,A1
	subi	10000h,a1
NOV
	ADDXY	A1,A10			;COMPENSATE

	;*** CLIPPING DONE, WHAT DO WE DO WITH IT?? ***
	addxy	A5,A10		; add PAGE OFFSET to dest Y:X

	.endif

	cmp	B12,B13		;Is Q Non-Empty?
	jrle	SkipQIt		; JUMP IF Q EMPTY, RIGHT?
QIt:	;*** WE HAVE ENOUGH TIME TO CLIP ANOTHER, PUSH THIS ONE ***
	move	b3,b3		; set new window bottom?
	jrz	nowin1
	neg	b3		; signal to DMAINT that it's a window
	move	b3,*-b12,L	; save on Q
nowin1:
	move	B12,A7

	MMTM	A7,A2,A3,A9,A10,A11,A12	;STORE THE DMA REGS

	move	A7,B12
	;**** ENABLE DMAINT ****
	setf	1,0,0		;field 0 is 1 bit
	movk	1,A7
	move	A7,@(INTENB+B_X1E),0

	setf	16,1,0
	jruc	DISPNEXT
SkipQIt:
	move	B2,A7		;DMAREGS
	;*** CHECK IF DMA IS BUSY ***
	MOVE	*B1,B14,L	;XUNIT @DMACTRL,  DMA BUSY?
	JRNN	STUFF		;JUMP IF IT NOT BUSY
	;COMPUTE WHETHER TO STACK THIS OBJ AND WORK AHEAD
;	move	B11,B14
;	zext	B11,W
;	srl	16,B14
;	lmo	B11,B11
;	lmo	B14,B14
;	add	B11,B14
;	subi	53,B14	 ;OBJ MUST BE BIGGER THAN 1024 PIX
	jrn	QIt	 ;Last obj plotted was big, Q this sucker..

*A2 = Y-SCALE:X-SCALE
*A3 = CONST:PALETTE XLATE
*A9 = VSIZE:HSIZE
*A10 = DESTINATION Y:X
*A11 = IMAGE SAG
*A12 = CONTROL:OFFSET
STUFF: 
	move	b3,b3		; new window to save?
	jrz	nowin2
	move	b3,@DMAWINDOW,L	; doit
nowin2:
	MMTM	A7,A2,A3,A9,A10,A11,A12	;STUFF THE DMA REGS
;	MOVE	A9,B11	  	; save unscaled size for next check

	.if	DEBUG

	MOVI	LAST_DMA+6*020H,A1
	MMTM	A1,A2,A3,A9,A10,A11,A12

	.endif

DISPNEXT:
	clr	b3			; no new window
	MOVE	*A0(OBLINK),A0,L 	;GET NEXT LINK
;	MOVE	*A0(OLINK),A0,L 	;GET NEXT LINK
	CMP	A0,A4
	JRNE	CLIP_LOOP
	RETS


**************************************************************************

DMAINT:
	;*** PULL FROM Q, PUSH ON DMA ***
****DMAINTY:
****	move	-*B13,b11,L	; Is it a scale or a window?
****	jrn	its_a_window
****	addk	32,b13
****	movi	DMAREGS,B11

	.if	DEBUG

	MMTM	SP,B0,B1

	MOVI	LAST_DMA+6*020H,B0

	move	-*b13,B1,L
	MOVE	B1,-*B0,L
	MOVE	B1,-*B11,L	;Y-SCALE:X-SCALE
	move	-*B13,B1,L
	MOVE	B1,-*B0,L
	MOVE	B1,-*B11,L	;CONST:PALETTE XLATE
	move	-*B13,B1,L
	MOVE	B1,-*B0,L
	MOVE	B1,-*B11,L	;VSIZE:HSIZE, NO, B11 IS not FOR THE DMAQ SIZE
	move	-*B13,B1,L
	MOVE	B1,-*B0,L
	MOVE	B1,-*B11,L	;DESTINATION Y:X
	move	-*B13,B1,L
	MOVE	B1,-*B0,L
	MOVE	B1,-*B11,L	;IMAGE SAG
	MOVE	-*B13,B1,L
	MOVE	B1,-*B0,L
	MOVE	B1,-*B11,L	;CTRL:OFFSET

	MMFM	SP,B0,B1

	.else

	move	-*b13,-*B11,L	;Y-SCALE:X-SCALE
	move	-*B13,-*B11,L	;CONST:PALETTE XLATE
	move	-*B13,-*B11,L	;VSIZE:HSIZE, NO, B11 IS not FOR THE DMAQ SIZE
	move	-*B13,-*B11,L	;DESTINATION Y:X
	move	-*B13,-*B11,L	;IMAGE SAG
	MOVE	-*B13,-*B11,L	;CTRL:OFFSET

	.endif

	cmp	B12,B13		;Is Q Non-Empty?
	jrgt	DMAINTX
****DMAINTZ:
	move	@VCOUNT,@DMATMP
	;*** DISABLE DMA INTERRUPT ***
	setf	1,0,0		;field 0 is 1 bit
	clr	B11
	move	B11,@(INTENB+B_X1E),0
DMAINTX
	movi	DMAREGS,B11
	reti

****its_a_window:
****	neg	b11
****	move	b11,@DMATPLFT,L
****	cmp	b12,b13		; if Q non-empty
****	jrgt	DMAINTY		;   see what's next
****	jruc	DMAINTZ		; else disable more interrupts 


**************************************************************************
*								         *
* The following align contains the entire Animation loop.		 *
*								         *
**************************************************************************

	.ALIGN

**************************************************************************
;PROCESS TO ANIMATE, EXECUTE FUNCTIONS for OBJECTS/MULTIPARTERS on ANIOBJS
NxtAni:
	move	A8,B8
	movb	*A8(AnimSlp),A6
	SUB	A4,A6	    	;A4 SHOULD = LAST_TIMER, HERE
****	dec	A6
	jrp	Sleeping

	;***** PROCESS AN ANIMATION SCRIPT ENTRY *******
	move	*A8(AnimFrm),A0,L
	move	*A0+,A1,L		;grab frame ptr
	jrnz	SkLpFrm
	move	*A8(AnimScr),A0,L
NxtMultiAni
	move	*A0+,A1,L
SkLpFrm:
*FOR ANY FLAG PROCESSING, DO NOT ACTUALLY AFFECT THE OBJECT WITH
* THE CHANGES UNTIL AFTER SkDead, IN CASE OF NOPARTANI.
 	move	*A8(OFLAGS),A4,W
	MOVE	*A8(OCTRL),A7,W		;GET THE DMA CONTROL, CHANGES IN ANI
	move	*A0+,A6,W		;get flags:Sleep

;;	jrn	OPARTSXY_PREFUDGE	;jump out to normally preserve cache
;;OPARTSXY_PREFUDGE_RET			;routine jumps back here
;	jrnn	SkSetFlp
;	move	*A0+,A5,W		;get flip bits
;	andn	A12,A7			;mask out M_FLIPH|M_FLIPV
;	or	A5,A7			;AND PUT THEM IN CONTROL
;SkSetFlp:

	jrnN	SkOpartsYAdj0

;*** FIX OPARTSXY FOR CHANGING FLIP BITS
	move	*A0+,A5,W		;get flip bits from script
	move	A5,A14
	xor	A7,A14			;which flip bits are changing??
	andn	A12,A7			;mask out M_FLIPH|M_FLIPV
	or	A5,A7			;set for animator code

;	btst	B_FLIPH,A14
;	jrz	SkOpartsXAdj0
;	move	*A8(OPARTSXY),A3,W		;ADJUST X PARTS
;	NEG	A3
;	move	A3,*A8(OPARTSXY),W
;SkOpartsXAdj0
;	btst	B_FLIPV,A14
;	jrz	SkOpartsYAdj0
;	move	*A8(OPARTSXY+010H),A3,W		;ADJUST Y PARTS
;	NEG	A3
;	move	A3,*A8(OPARTSXY+010H),W
SkOpartsYAdj0

	MOVE	B8,A14
	CMP	A8,A14			;ALWAYS PROCESS SINGLE/HEAD OBJECT?
	JREQ	DoEverything		;BR = YES, NO PART CHECK
	btst	B_NOPARTANI,A4		;SHOULD WE ANIMATE THIS PART OF MULTI
	jrz	DoEverything

	;IF OBJ IS IN MULTI-SCRIPT, BUT MARKED NOPARTANI
	;   SKIP FUNCTION, ARGS & ANIMATION(flag stuff too)
	btst	B_AFunc,A6		;Skip over func?
	jrz	SkANI0
	move	*A0+,A14,L		;Load function from script
	sll	28,A14			;just want arg count bits
	srl	24,A14			; arg count is in words
	add	A14,A0			;skip script ptr past args
	jruc	SkANI0	

DoEverything
	;**** CHECK FOR ANIM FUNCTION ****
	btst	B_AFunc,A6
	jrz	SkAFunc
	move	*A0+,A14,L
	move	A14,*A10+,L	;QUEUE UP FUNCTION CALL
	move	A8,*A10+,L	;QUEUE UP OBJ PTR FOR FUNCTION CALL
	sll	28,A14		;just want arg count bits
	srl	24,A14		; arg count is in words
	jrz	SkAFunc
	move	A0,*A8(AnimArg),L
	add	A14,A0		;skip script ptr past args
SkAFunc

;*** NOTE A0 MUST BE KEPT VALID THROUGH ANIMATION TO PROCESS MULTI ***

	btst	0,A1		;if bottom bit of frame ptr, skip ani
	jrnz	SkANI0

*****************************  ANI  *********************************
* ANIMATION SUBROUTINE
* A1=NEW IMAGE POINTER
* A8=OBJECT STRUCTURE POINTER TO BE UPDATED

	;GET AND STUFF NEW SIZE,SAG,OFFSET

;	MOVE	A1,A14
	move	*a8(OIHOFF),a14		; keep current IHOFF
	add	a1,a14

	BTST	B_MANSCALE,A4		;IS THIS A MANUALLY SCALED OBJECT?
	jrz	nomanscl
;	move	*a8(OIHOFF),a14		; keep current IHOFF
;	add	a1,a14
	andni	M_NOSCALE,a4		; force RESCALE
	move	a4,*a8(OFLAGS)		; 
nomanscl:

	.if ICTRL != 0
	ADDk	ICTRL,a14
	.endif
	MOVE	*A14+,A2,W	;GET NEW FRAMES ICTRL IN A2
	AND	A11,A7		;MASK OUT OLD CONTROL PARMS, KEEP FLIP
	OR	A7,A2		;SETUP CONTROL AND FLIP FOR NEW FRAME

	MMFM	A14,A3,A5,A7	;A7, SIZE
				;A5, SAG
				;A3, ANIP

	MOVE	A8,A14
;	ADDI	OANIOFF,A14
;	MOVE	A3,*A14+,L		;OANIOFF
;	ADDK	010H,A14
	ADDI	OCTRL,A14
	MOVE	A2,*A14+,W		;OCTRL
	MOVE	A5,*A14+,L		;OSAG
	ADDK	020H,A14
	MOVE	A7,*A14+,L		;OUSIZE
	MOVE	A7,*A14,L		;OSIZE
 	MOVE	A1,*A8(OIMG),L

	BTST	B_SCRNOBJ,A4		;IS THIS A SCREEN RELATIVE OBJECT?
	JRZ	ANIMP_WORLD		;BR = NO

	MOVE	*A8(OUANIOFF),A5,L	;WE MUST DO ANIMATION PNT OURSELVES
	MOVE	*A8(ODAG),A14,L
	ADDXY	A5,A14			;GET POSITION OF ANIMATION PNT ONSCREEN
	SUBI	10001H,A7		;GET SIZE READY FOR FLIPS
	SUBXY	A3,A7

	BTST	B_FLIPH,A2
	JREQ	ANIMP_NOFLIPH		
	MOVX	A7,A3
ANIMP_NOFLIPH
	BTST	B_FLIPV,A2
	JREQ	ANIMP_NOFLIPV
	MOVY	A7,A3
ANIMP_NOFLIPV		
	SUBXY	A3,A14
	MOVE	A14,*A8(ODAG),L
	MOVE	A14,*A8(OXPOS),W
	SRL	16,A14
	MOVE	A14,*A8(OYPOS),W

ANIMP_WORLD
	MOVE	A3,*A8(OUANIOFF),L
	move	a3,*a8(OANIOFF),L	; assume same for NOSCALE objects

	BTST	B_MANSCALE,A4
	JRNZ	ANIMP_MAN_SCALE	     

	BTST	B_NOSCALE,A4
	JRNZ	ANIMP_CK_SHADOW

	MOVE	A9,*A8(OSCALE),L	;FOOL SCALE MAMA INTO DOIN' US
;	CLR	A14
;	MOVE	A14,*A8(OIHOFF),W

;	MOVE	A4,*A8(OFLAGS),L
;	MOVE	A3,*A8(OUPARTSXY),L
;	MOVE	A3,*A8(OPARTSXY),L
ANIMP_CK_SHADOW
	MOVE	*A8(OSHAD),A14,L	;Is there a shadow?
	JRZ	SkANI0			;BR = NO
;Just shove copies of all this shit to the shadow
	SRL	4,A2
	SLL	4,A2
	ADDK	DMACNZ&0Fh,A2		;Fix up the new OCTRL for the shadow

	MOVE	A3,*A14(OANIOFF),L
	MOVE	A3,*A14(OUANIOFF),L

;	CLR	A3
;	MOVE	A3,*A14(OIHOFF),W	;This'll fuck with SCALE_MAMA

	ADDI	OCTRL,A14
	MOVE	A2,*A14+,W		;OCTRL
	MOVE	A5,*A14+,L		;OSAG
	ADDK	020H,A14
	MOVE	A7,*A14+,L		;OUSIZE
	MOVE	A7,*A14+,L		;OSIZE
	ADDK	020H,A14
	MOVE	A9,*A14+,L		;OSCALE
	MOVE	A1,*A14,L		;OIMG
	jruc	SkANI0


ANIMP_MAN_SCALE:
	MOVE	*A8(OSHAD),A14,L	;Is there a shadow?
	JRZ	SkANI0			;BR = NO
;
; Set SHADOW to Rescale in SCALE_MAMA
; DON'T CHANGE THE SCALE OR IHOFF HERE! 
;
	SRL	4,A2
	SLL	4,A2
	ADDK	DMACNZ&0Fh,A2		;Fix up the new OCTRL for the shadow
	
	MOVE	A3,*A14(OANIOFF),L

	move	*a14(OFLAGS),a3
	andni	M_NOSCALE,a3		;force RESCALE
	move	a3,*a14(OFLAGS)

	ADDI	OCTRL,A14
	MOVE	A2,*A14+,W		;OCTRL
	MOVE	A5,*A14+,L		;OSAG
	ADDK	020H,A14
	MOVE	A7,*A14+,L		;OUSIZE
	addi	OIMG-OSIZE,a14
	MOVE	A1,*A14,L		;OIMG
	
****************************************************************

SkANI0	
	btst	B_AMulti,A6	;DO WE ANIMATE DOWN MULTI-PARTER LIST
	jrz	SkAFMulti
	move	*A8(OPARTS),A8,L
	jrnz	NxtMultiAni
SkAFMulti

	move	B8,A8
	move	A0,*A8(AnimFrm),L

	sll	24,A6
	srl	24,A6		
	jrnz	GotSlp		
	movb	*A8(AnimSLP),A6	
GotSlp				
	MOVE	@LAST_TIMER,A4,W	;RELOAD THE TIME FACTOR
Sleeping:			
	movb	A6,*A8(AnimSlp)	
	move	*A8(AnimNxt),A8,L
	jrnz	NxtAni
;******************* END OF 1st CACHEABLE BLOCK OF CACHE3 ***************

ANISCALE
	clr	A0	  	;MARK END OF ANIM FUNC LIST
	move	A0,*A10+,L

	CALLA	SCALE_MAMA		;UPDATE SCALES and compute SCREEN POS

**** NOTE: Should we put an EINT here? (See DINT NOTE)

	MOVI	ACTIVE,A13

****	.align

;******************* Start OF 2d Block (only 040h words long) *************
	;**** PROCESS QUEUED UP ANIM FUNCS ****
	movk	1,A0
	movb	A0,@IN_ANIM

;	clr	A0	  	;MARK END OF ANIM FUNC LIST
;	move	A0,*A10+,L
;	move	A12,@ANIM_LIST_TEMP,L
	movi	ANIFUNCS,A12	;reset to top of list to pull funcs

	;**** PULL OUT NEXT ANIM FUNCTION ****
ANIFNCLP:				;MAKE SURE THIS LOOP DOESN'T
	move	*A12+,A0,L		;SPAN CACHE BLOCK BOUNDARY
	jrz	ANIFNCX			;
	srl	4,A0			;mask out arg count
	sll	4,A0			;
	move	*A12+,A8,L		;
	call	A0			;
	jruc	ANIFNCLP		;
ANIFNCX:
	clr	A0
	movb	A0,@IN_ANIM

;	move	@ANIM_LIST_TEMP,A12,L
AniLpX:
	rets

;	movk	1,A0
;	calla	PRCSLP

**************************************************************************
*								         *
* ANIMP - FUNCTION TO PROCESS THE ANIMATION LIST.			 *
* 	CALLED ONCE EVERY TICK.						 *
*								         *
**************************************************************************
ANIMP:
*THE FOLLOWING REGISTERS MUST REMAIN UNCHANGED UNTIL THE ANIM FUNCS ARE CALLED
	movi	M_FLIPH|M_FLIPV,A12	;used to mask out M_FLIPH|M_FLIPV
	MOVI	0807FH,A11		;MASK FOR CONTROL WORD
	movi	ANIFUNCS,A10		;GET READY TO QUEUE UP ANIM FUNCS
	MOVE	@LAST_TIMER,A4,W	;LOAD THE TIME FACTOR

*** NOTE:  Should we put a DINT here? to make sure DIRQ doesn't happen before
***            Ani is done and SCALE_MAMA is called?

	move	@ANIOBJS,A8,L
	jrnz	NxtAni
;	jruc	AniLpX
	JRUC	ANISCALE

*MAKE SURE OPARTSXY_PREFUDGE STAYS IN ITS OWN CACHE BLOCK
;	.WORD	0,0,0,0,0,0,0,0,0,0,0,0

;	.align
;
;OPARTSXY_PREFUDGE:
;;*** FIX OPARTSXY FOR CHANGING FLIP BITS
;	move	*A0+,A5,W		;get flip bits from script
;	move	A5,A14
;	xor	A7,A14			;which flip bits are changing??
;	andn	A11,A7			;mask out M_FLIPH|M_FLIPV
;	or	A5,A7			;set for animator code
;
;	btst	B_FLIPH,A14
;	jrz	SkOpartsXAdj0
;	;*** SEE EXPLANATION OF THIS EQUATION IN ANI ***
;	move	*A8(OANIOFFX),A5,W
;	sll	1,A5
;	move	*A8(OPARTSXY),A2,W
;	sub	A2,A5
;	move	A5,*A8(OPARTSXY),W
;SkOpartsXAdj0
;	btst	B_FLIPV,A14
;	jrz	SkOpartsYAdj0
;	;SAME AS ABOVE FOR Y
;	move	*A8(OANIOFFY),A5,W
;	sll	1,A5
;	move	*A8(OPARTSXY+010h),A2,W
;	sub	A2,A5
;	move	A5,*A8(OPARTSXY+010h),W
;SkOpartsYAdj0
;	jruc	OPARTSXY_PREFUDGE_RET

**************************************************************************
*								         *
* End of Animation cache loop						 *
*								         *
**************************************************************************

	.text
**************************************************************************
PULLANIMFUNC:
;*** CALLED FROM PULLANIM TO ALSO PULL A QUEUED UP ANIM FUNC
;A0 obj being pulled from anim
;A12 if IN_ANIM, A12 must be pointing to ANIM FUNC QUEUE
	mmtm	SP,A1,A12
	;** CAN ONLY BE A QUEUED UP FUNCTION IF CURRENTLY IN ANIM LIST **
	movb	@IN_ANIM,A14
	jrz	PULANIFNCX

	.IF DEBUG
	;MAKE SURE NO ONE HAS FUCKED WITH A12
	cmpi	ANIFUNCS,A12
	jrlo	$
	cmpi	ANIFUNCSX,A12
	jrhi	$
	.ENDIF

	;SCAN REST OF ANIM FUNC QUEUE FOR FUNC WITH THIS OBJ.
PULANIFNCLP:
	move	*A12+,A14,L	;another func?
	jrz	PULANIFNCX
	move	*A12+,A14,L	;check the obj to match A0
	cmp	A0,A14
	jrne	PULANIFNCLP

	;*** WE HAVE A QUEUED UP ANIM FUNC FOR THIS OBJ, PULL IT ***
	;*** Pull by shifting other funcs up queue ***
SHIFTANIFNCLP
	move	A12,A14		;A12 src, A14 dest
	subi	040h,A14
	move	*A12+,A1,L	;FUNC, set the ZFLAG
	move	A1,*A14+,L
	move	*A12+,*A14+,L	;OBJ
	move	A1,A1
	jrnz	SHIFTANIFNCLP
	
PULANIFNCX
	mmfm	SP,A1,A12
	rets

****	.sect	"CACHE5"

	.ALIGN

**************************************************************************
*								         *
* 	ANI								 *
* 									 *
* 	Single frame animation subroutine.				 *
* 									 *
* 	A1 = New IMAGE pointer						 *
* 	A4 = New OCTRL							 *
* 	A8 = Ptr to object to animate					 *
* 									 *
* 	Returns:							 *
* 		Nothing							 *
*								         *
**************************************************************************
ANI:
	mmtm	SP,A0,A2,A3,A5,A7

	;CHECK IF FLIP BITS CHANGE FOR OPARTSXY FUDGE
	move	*A8(OCTRL),A2,W
	xor	A4,A2
	btst	B_FLIPH,A2
	jrz	SkOpartsXAdj			;BR=FLIPH DIDN'T CHANGE

	move	*A8(OPARTSXY),A3,W		;ADJUST X PARTS
	NEG	A3
	move	A3,*A8(OPARTSXY),W

SkOpartsXAdj
	btst	B_FLIPV,A2
	jrz	SkOpartsYAdj			;BR=FLIPV DIDN'T CHANGE

	move	*A8(OPARTSXY+010H),A3,W		;ADJUST Y PARTS
	NEG	A3
	move	A3,*A8(OPARTSXY+010H),W

SkOpartsYAdj

	;GET AND STUFF NEW SIZE,SAG,OFFSET

;Bill- start 11/12/1993
;	MOVE	A1,A14
	move	*a8(OIHOFF),a14		; keep current IHOFF
	add	a1,a14
;Bill- end 11/12/1993

	.if ICTRL != 0
	ADDk	ICTRL,a14
	.endif

	MOVE	*A14+,A2,W	; ICTRL IN A2
	MMFM	A14,A3,A5,A7	;A7, SIZE
				;A5, SAG
				;A3, ANIP

	ANDI	0807FH,A4
	OR	A2,A4


	MOVE	A1,*A8(OIMG),L
	MOVE	A7,*A8(OUSIZE),L
	MOVE	A7,*A8(OSIZE),L
	MOVE	A5,*A8(OSAG),L
	MOVE	A4,*A8(OCTRL),W

	MOVE	*A8(OFLAGS),A2,W

	BTST	B_SCRNOBJ,A2		;IS THIS A SCREEN RELATIVE OBJECT?
	JRZ	ANI_WORLD		;BR = NO

;This is the added computation for a screen object

	MOVE	*A8(OUANIOFF),A5,L	;WE MUST DO ANIMATION PNT OURSELVES
	MOVE	*A8(ODAG),A14,L
	ADDXY	A5,A14			;GET POSITION OF ANIMATION PNT ONSCREEN
	SUBI	10001H,A7		;GET SIZE READY FOR FLIPS
	SUBXY	A3,A7

	BTST	B_FLIPH,A4
	JREQ	ANI_NOFLIPH
	MOVX	A7,A3
ANI_NOFLIPH
	BTST	B_FLIPV,A4
	JREQ	ANI_NOFLIPV
	MOVY	A7,A3
ANI_NOFLIPV		
	SUBXY	A3,A14
	MOVE	A14,*A8(ODAG),L
	MOVE	A14,*A8(OXPOS),W
	SRL	16,A14
	MOVE	A14,*A8(OYPOS),W
	JRUC	ANI_FINISH		;Skip shadow stuff for screen object

;Added support for shadows is used in world objects only
ANI_WORLD
	MOVE	*A8(OSHAD),A0,L		;Is there a shadow?
	JRZ	ANI_FINISH		;BR = NO  

	SRL	4,A4
	SLL	4,A4
	ADDK	DMACNZ&0Fh,A4		;Fix up the new OCTRL for the shadow

	MOVE	A1,*A0(OIMG),L
	MOVE	A7,*A0(OUSIZE),L
	MOVE	A7,*A0(OSIZE),L
	MOVE	A5,*A0(OSAG),L
	MOVE	A4,*A0(OCTRL),W

	MOVE	A3,*A0(OANIOFF),L
	MOVE	A3,*A0(OUANIOFF),L

ANI_FINISH:
	MOVE	A3,*A8(OUANIOFF),L
	MOVE	A3,*A8(OANIOFF),L

	mmfm	SP,A0,A2,A3,A5,A7
	rets


**************************************************************************
* ANINP - ANIMATION SUBROUTINE (no position update)			 *
* A1=NEW IMAGE POINTER							 *
* A4=NEW OFLAGS								 *
* A8=OBJECT STRUCTURE POINTER TO BE UPDATED				 *
ANINP:
	mmtm	SP,A2,A3,A5
	;GET AND STUFF NEW SIZE,SAG,OFFSET
	zext	A4,W		;ZERO OFFSET IN A4
	move	*A1(ISIZE),A2,L	;A2 ISIZE
	addk	3,A2		;ADJUST HOR SIZE FOR MORSEL
	srl	2,A2
	sll	2,A2
	MOVE	*A1(ISAG),A3,L	;GET TOP LEFT SAG (here to use hidden cycles)
	clr	A5
	movx	A2,A5
	sll	3,A5		;A5 = IMAGE WIDTH IN BITS

	;HORIZONTAL FLIP CASE
	move	@NO_MIRROR,A14,W		;ARE WE MIRRORING THESE OBJECTS?
	jrnz	SAGN_NO_MIRROR		;BR = NO
	btst	B_FLIPH,A4
	jrz	SagHN		;NO H FLIP, TRY VERT FLIP
	jruc	SkSagHN
SAGN_NO_MIRROR

	btst	B_FLIPH,A4
	jrz	SkSagHN		;NO H FLIP, TRY VERT FLIP
SagHN
	;FIX SAG FOR HFLIP
	add	A5,A3		;ADD THS-1 TO SAG
	subk	8,A3
	;FIX OFFSET FOR HFLIP
	move	A5,A14		;A5=THS*8, 2*THS-1 TO OFFSET
	subk	4,A14
	sll	14,A14		;ADJUST FOR B16-31
	addxy	A14,A4
SkSagHN

*VERTICAL FLIP CASE
	btst	B_FLIPV,A4
	jrz	SkSagVN		;NO VERT FLIP
	;FIX SAG FOR VFLIP
	movy	A2,A14		;GET HEIGHT
	srl	16,A14
	dec	A14		;FIRST ENTRY LAST ROW
	mpyu	A14,A5		;THS*(TVS-1)
	add	A5,A3		;ADD TO SAG
	;FIX OFFSET FOR VFLIP
	movx	A2,A5
	sll	17,A5		;*2, offset in top 16 of A4
	subxy	A5,A4		;offset -= 2*THS
SkSagVN
	move	A8,A14
	addi	OFLAGS+080h,A14
	mmtm	A14,A1,A2,A3,A4 ;IMG,SIZE,SAG,FLAGS
	mmfm	SP,A2,A3,A5
	rets
**************************************************************************

**************************************************************************
* SETANIOF
* A0 obj
* SETS OANIOFF FIELD BASED ON OIMG FIELD AND CURRENT FLIP BITS
* SETANIOF0
* INSTEAD OF LOADING IANIOFF FROM *A0(OIMG), ASSUMES 0
SETANIOF0:
;* ENTRY POINT FOR OBJS WITHOUT AN ANIMATION POINT
	mmtm	SP,A4,A5,A6
	move	*A0(OIMG),A14,L
	move	*a8(OIHOFF),a5
	add	a5,a14
	clr	A5			;NO ANI OFFSET
	jruc	aniofe
SETANIOF:
;**** SET OANIOFF FIELD OF OBJECT IN A0 ****
	mmtm	SP,A4,A5,A6
	move	*A0(OIMG),A14,L
	move	*a8(OIHOFF),a5
	add	a5,a14
	move	*A14(IANIOFF),A5,L	;A5 = X COMPONENT OF IANIOFF
aniofe:
	move	A5,A6			;A6 = Y COMPONENT OF IANIOFF
	move	*A0(OFLAGS),A4,W
	move	*A14(ISIZE),A14,L	;A14 ISIZE
	addk	3,A14		;ADJUST HOR SIZE FOR MORSEL
	srl	2,A14
	sll	2,A14

	btst	B_FLIPH,A4
        jrz	SkSAHF
	;ADJUST X COMPONENT OF ANIOFF
	subxy	A14,A5		;bottom 16 of A14 has X SIZE
	sext	A5
	neg	A5
	dec	A5		;SUB THS-1 FROM ANIOFFX FOR H-FLIP
SkSAHF
	btst	B_FLIPV,A4
	jrz	SkSAVF
	;ADJUST Y COMPONENT OF ANIOFF
	neg	A6
	addxy	A14,A6		;SUB TVS-1 FOR V-FLIP
	subi	010000h,A6
SkSAVF
	movy	A6,A5		;A5 = OANIOFF
	move	A5,*A0(OANIOFF),L

	mmfm	SP,A4,A5,A6
	rets
**************************************************************************

	.END

