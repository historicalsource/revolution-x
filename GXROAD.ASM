	.MLIB	"GXMACS.LIB"
	.FILE	"GXROAD.ASM"
	.TITLE	" <<< GENERATION X -- ROAD GENERATION ROUTINES >>>"
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
	.INCLUDE	"GXSTRING.H"
	.INCLUDE	"IMGTBL.GLO"
	.INCLUDE	"BGNDTBL.GLO"	;Background equates
	.INCLUDE	"GXROAD.TBL"

	.EVEN

;WARREN FIX ZMIN, ROAD_WORLD_Y, HALFY - DOZER 10/26/92

ZMIN		.EQU	0
ROAD_WORLD_Y	.EQU	0
HALFY		.EQU	0


ROADBITS	.set	9
ROADWD	 	.set	(1<<ROADBITS)			;ROAD WIDTH
NUM_ZENT	.set  ((ZMIN-ZMAX)>>Z2INDX)+1	;number of Z entries in table
WRLD2SCRN	.set	15

;	.BSS	ROADZPOS,32		;WORLD Z POSITION
	.BSS	ROADPAL,16*6		;ROAD PALETTES
	.BSS	ROADADDR,32	 	;CURRENT SAG OF ROAD FULL
	.BSS	ROAD2ADDR,32		;CURRENT SAG OF ROAD QRTR
	.BSS	ROADSAG,32	 	;SAG OF FULL ROAD IMAGE
	.BSS	ROADSAGQ,32		;SAG OF QRTR ROAD IMAGE
	.bss	ROADWID,16		;unscaled screen width of road
	.bss	DESTROADWID,16		;desired screen width of road
	.bss	ROADCHGST,32		; start z of road grow/shrink
	.bss	ROADWIDDELTA,16		;change in roadwid (3 bit fraction)
	.bss	ROADX,32		;start of ROAD X table in crculr bufr
	.bss	ROADY,32		;start of ROAD Y table in crculr bufr
	.bss	YMINTBL,SIZYMINTBL	;save info on hills, i.e.
					; word 0   garbage
					; word 1   Screen Y
					; words 2,3  Z
	.bss	YMINPTR,32		; first entry of YMINTBL
; 	.bss	YSKEW,16		; observer height adjustment
	.bss	ROADFLG,16		; defines below
	.bss	ROAD_EDGE,32		; EDGE of road in WORLD X

 	.bss	SQIG,16			; SQUIGGLE TURN	FLAG


ADDIR	.macro  P1,REG
	.if P1 == 0
	.elseif P1 < 33
	addk	:P1:,REG
	.else
	addi	:P1:,REG
	.endif
	.endm


	.TEXT
	.EVEN

;TEST EQUATES
FINISH_LINE	.EQU	02000000H
JOHN_TEST	.EQU	0		;TESTING FOR T-UNIT

ROAD_TEST
*	MOVI	hardrd,a0
*	MOVI	WROAD,a0
*	MOVI	TSTROAD2,a0
	movi	road16PAL,a0
	CALLA	GETFPAL
	CLR	A0
	MOVE	A0,@ROADPAL,W

;	CREATEP	PID_IND,SCROLL_ROAD

	.if	BILL

	SLEEP	100

	.if	JOHN_TEST = 0

;	JRUC	NO_CURVES
	CREATEP	PID_IND,DISPATCH_CURVES
NO_CURVES
;	JRUC	NO_HILLS
	CREATEP	PID_IND,DISPATCH_HILLS
NO_HILLS

;	CREATE	PID_IND,ROAD_SURFACE_PROC

	.endif

	.else

	sleep	100
	CREATEP	PID_IND,DISPATCH_CURVES
	CREATEP	PID_IND,DISPATCH_HILLS
	.endif

	RETP

OLDWAY	.set 0

INIT_ROAD:
	CLR	A14
	MOVE	A14,@(XBASE+16),W
	move	a14,@(YBASE+16),W
	move	a14,@ROADFLG,W
	move	a14,@ZBASE,L	; start line of road image 
				; varies from 0 to 10000
	movi	ROADOFFY,a9
	move	a9,@ROADY,L
	movi	ROADOFFX,a7
	move	a7,@ROADX,L
	movi	512,a0		; number of long words
initrdoff:
	move	a14,*a9+,L 	; clear 2 words at a time
	move	a14,*a7+,L 	; clear 2 words at a time
	dsjs	a0,initrdoff
	
*	MOVI	banrd64,a14
*	MOVI	WROAD64,A14
*	MOVI	TSTROAD64,A14
	movi	road16Q,a14
	ADDIR	PIX_TO_LOSE<<1,a14
	MOVE	A14,@ROADSAGQ,L
	MOVE	A14,@ROADADDR,L

*	movi	banrd256,a14
*	MOVI	WROAD256,a14
*	MOVI	TSTROAD256,a14
	movi	road16,a14
	ADDIR	PIX_TO_LOSE<<3,a14
	MOVE	A14,@ROADSAG,L
	MOVE	A14,@ROAD2ADDR,L

	movi	ROADWD-PIX_TO_LOSE,a14
	move	a14,@ROADWID

	sll	WRLD2SCRN,a14
	move	a14,@ROAD_EDGE,L	; WORLD X of ROAD EDGE
	
	RETS



SQ2STRAIT	.set	0
SQ2LCURV	.set	1
SQ2RCURV	.set	5
SQ2LSQUIG	.set	2
SQ2RSQUIG	.set	6

DP2LEVL		.set	0
DP2DHILL	.set	1
DP2UHILL	.set	5
DP2DDIP		.set	2
DP2UDIP		.set	6
DP2DSQUIG	.set	2+8
DP2USQUIG	.set	6+8


BOUNCE_TABLE
	.WORD	0100H,080H,040H,020H,0

DISPATCH_HILLS:

	.if	BILL

	SLEEP	1
	MOVE	@ZBASE,A14,L
	CMPI	9 * FINISH_LINE / 16,A14
	JRLT	DISPATCH_HILLS

	movi	DIPTBL,a8
	movi	DP2LEVL,a10
	JSRP	UP_DIP

	MOVI	BOUNCE_TABLE,A10
BOUNCE_START
	MOVE	*A10+,A8,W
	JRZ	BDONE
	CLR	A9
BOUNCE_UP
	ADDK	16,A9
	MOVE	A9,@(YBASE+16),W
	SLEEP	1
	CMP	A8,A9
	JRNE	BOUNCE_UP
BOUNCE_DOWN
	SUBK	16,A9
	MOVE	A9,@(YBASE+16),W
	SLEEP	1
	MOVE	A9,A9
	JRNZ	BOUNCE_DOWN
	JRUC	BOUNCE_START
BDONE

HILL_WAIT
	SLEEP	1
	MOVE	@ZBASE,A14,L
	CMPI	9 * FINISH_LINE / 16,A14
	JRGT	HILL_WAIT

	JRUC	DISPATCH_HILLS

	.else

;	movi	ZMIN*5,a10
;	JSRP	UP_HILL	

;	sleep	300

	movi	YSQUIGTBL,a8
	movi	DP2LEVL,a10
	JSRP	UP_DIP

	sleep	300

	movi	DIPTBL,a8
	movi	DP2LEVL,a10
	JSRP	UP_DIP

	sleep	200

	movi	YSQUIGTBL,a8
	movi	DP2USQUIG,a10
	JSRP	DN_DIP
 
	sleep	200
	
	movi	YSQUIGTBL,a8
	movi	DP2DDIP,a10
	JSRP	UP_DIP

	sleep	200

	movi	DIPTBL,a8
	movi	DP2UDIP,a10
	JSRP	DN_DIP
 
	sleep	200
	
	jruc	DISPATCH_HILLS

	.endif
	
CAR_CURVES:
	movi	ZMIN,a10
	JSRP	RT_CURVE
	
;	sleep	40

;	movi	SQ2RSQUIG,a10
;	JSRP	LFT_SQUIG

	movi	RD_FRK_LFT,a10	
	JSRP	DO_FORK

	sleep	30

	movi	RD_FRK_RT,a10	
	JSRP	DO_FORK

	sleep	30

	movi	RD_FRK_BOTH,a10	
	JSRP	DO_FORK

	sleep	30

	movi	RD_FRK_LFT,a10	
	JSRP	DO_FORK

	sleep	30

	movi	RD_FRK_RT,a10	
	JSRP	DO_FORK

	sleep	30

	movi	RD_FRK_BOTH,a10	
	JSRP	DO_FORK

	sleep	30

	movi	512-66,a10
	JSRP	CHANGE_ROAD_SIZE

	movi	ZMIN*2,a10
	JSRP	LFT_CURVE

	movi	512,a10
	JSRP	CHANGE_ROAD_SIZE

	JRUC	CAR_CURVES


DISPATCH_CURVES:

	.IF	BILL

;	MOVIM	STRAIGHT_AWAY,@SKID_FACTOR,W
NOC1
	SLEEP	1
	MOVE	@ZBASE,A14,L
	CMPI	FINISH_LINE / 8,A14
	JRLT	NOC1

;	MOVIM	NORMAL_TURN,@SKID_FACTOR,W

	MOVI	FINISH_LINE / 4,A10
	JSRP	LFT_CURVE

;	MOVIM	STRAIGHT_AWAY,@SKID_FACTOR,W
NOC15
	SLEEP	1
	MOVE	@ZBASE,A14,L
	CMPI	7 * FINISH_LINE / 16,A14
	JRLT	NOC15

;	MOVIM	NORMAL_TURN,@SKID_FACTOR,W

	MOVKM	1,@SQIG,W

	movi	SQ2RSQUIG,a10
	JSRP	RT_SQUIG

	CLRM	@SQIG,W

;	MOVIM	STRAIGHT_AWAY,@SKID_FACTOR,W
NOC2
	SLEEP	1
	MOVE	@ZBASE,A14,L
	CMPI	5 * FINISH_LINE / 8,A14
	JRLT	NOC2

;	MOVIM	NORMAL_TURN,@SKID_FACTOR,W

	MOVI	FINISH_LINE / 4,A10
	JSRP	LFT_CURVE

;	MOVIM	STRAIGHT_AWAY,@SKID_FACTOR,W

CWAIT
	SLEEP	1
	MOVE	@ZBASE,A14,L
	CMPI	FINISH_LINE / 8,A14
	JRGT	CWAIT

	JRUC	DISPATCH_CURVES	

	movi	01000000H,a10
	JSRP	RT_CURVE

	JSRP	LFT_SQUIG
	movi	SQ2STRAIT,a10
	JSRP	UNSQUIGGLE
	sleep	40

	jruc	DISPATCH_CURVES

	.ELSE

	movi	SQ2STRAIT,a10
	JSRP	LFT_SQUIG

	movi	ZMIN,a10
	JSRP	RT_CURVE
	
	sleep	40

	movi	SQ2RSQUIG,a10
	JSRP	LFT_SQUIG

	movi	RD_FRK_BOTH,a10	
	JSRP	DO_FORK

	movi	512-66,a10		; desired width of road
	JSRP	CHANGE_ROAD_SIZE

;	movi	SQ2RSQUIG,a10
;	JSRP	RT_SQUIG

 	sleep	200

	movi	512-133,a10		; desired width of road
	JSRP	CHANGE_ROAD_SIZE

	movi	ZMIN*6,a10
	JSRP	LFT_CURVE

	movi	RD_FRK_RT,a10	
	JSRP	DO_FORK

	movi	512-66,a10		; desired width of road
	JSRP	CHANGE_ROAD_SIZE

	sleep	40

	movi	ZMIN,a10
	JSRP	LFT_CURVE

	movi	512-(132+66),a10		; desired width of road
	JSRP	CHANGE_ROAD_SIZE

	movi	SQ2RCURV,a10
	JSRP	RT_SQUIG

	movi	512,a10		; desired width of road
	JSRP	CHANGE_ROAD_SIZE

	movi	RD_FRK_LFT,a10	
	JSRP	DO_FORK

	movi	SQ2LCURV,a10
	JSRP	RT_SQUIG

	movi	512,a10		; desired width of road
	JSRP	CHANGE_ROAD_SIZE

;	movi	SQ2LSQUIG,a10
;	JSRP	RT_SQUIG

;	movi	ZMIN>>1,a10
;	JSRP	RT_CURVE

;	movi	18000h,a10
;	JSRP	LFT_CURVE

;	movi	(ZMIN-ZMAX)<<1,a10
;	JSRP	RT_CURVE


	jruc	DISPATCH_CURVES

	.ENDIF

********************************************************************************
*									       *
*     Process to make road Wider or Thinner                                    *
*									       *
*	ENTRY:   a8 =  Desired Road Width				       *
*									       *
********************************************************************************
*
*	a8 = ROADWID (with 3 bit fraction)
*	a9 = ZBASE of start of grow/shrink
*	a10 = desired size of road
*	a11 = delta ROADWID per index of Z (3 bit fraction)
CHANGE_ROAD_SIZE:
	move	@ROADFLG,a0

	btst	RD_B_INHILL,a0
	jrnz	CRS_notyet
	ori	RD_INGRSH,a0
	move	a0,@ROADFLG
	jruc	OK2ChgRd
CRS_notyet:
	sloop	5,CHANGE_ROAD_SIZE
OK2ChgRd:
	move	@ZBASE,a9,L
	addi	ZMIN,a9
	move	a9,@ROADCHGST,L
	move	a10,@DESTROADWID
	move	@ROADWID,a8
	movk	1,a11
	cmp	a10,a8			; if desired less than current...
	jrlt	nonegate
	neg	a11			;	negate delta
nonegate:
	move	a11,@ROADWIDDELTA
	sll	3,a8			; 3 bit fraction on starting ROADWID


ChgRdLoop:
	move	@ZBASE,a1,L
	cmp	a9,a1
	jrle	notstarted		; ROADWID unchanged at ZBASE
*
*	adjust ROADWID at ZBASE
*
	sub	a9,a1
	sra	Z2INDX,a1
	move	a11,a11
	jrn	crs_shrink
*
*	road is growing
*
	add	a8,a1
	srl	3,a1		; lose 3 bit fraction
	cmp	a10,a1
	jrge	road_finis
	jruc	gowon

crs_shrink:
	neg	a1
	add	a8,a1
	srl	3,a1
	cmp	a10,a1
	jrle	road_finis
gowon:
	move	a1,@ROADWID	; save ROADWID at ZBASE
	subi	ROADWD,a1	; diff from constant ROADWD
	neg	a1
	sll	3,a1		; scale to pixel
	move	@ROADSAG,a3,L
	add	a1,a3
	move	a3,@ROAD2ADDR,L
	srl	5,a1
	jrz	notstarted
	sll	3,a1		; scale to pixel
	move	@ROADSAGQ,a3,L
	add	a1,a3
	move	a3,@ROADADDR,L
notstarted:
	sloop	1,ChgRdLoop

road_finis:
	move	a10,@ROADWID
	move	@ROADFLG,a0
	andni	RD_INGRSH,a0
	move	a0,@ROADFLG
	RETP


********************************************************************************
*									       *
*     Process to Do a FORK in the road.                                        *
*									       *
*	ENTRY:   a10 =  flags to indicate type of fork			       *
*									       *
********************************************************************************
DO_FORK:
	move	@ROADFLG,a0
	andi	RD_FRK_LFT|RD_FRK_RT|RD_FRK_BOTH,a10

FRK_wait:
	move	@ROADFLG,a0
	btst	RD_B_INHILL,a0
	jrz	DoFrk
FRK_notyet:
	sloop	3,FRK_wait

DoFrk:
	or	a10,a0
	ori	RD_INFORK,a0
	move	a0,@ROADFLG
	move	a0,a9

	movi	ZMIN*4,a10
	movk	1,a5		; flag not to do in upper, flag to do in lower

	move	@NO_MIRROR,a14
	jrnz	swapcore_frk
	rl	16,a5		
swapcore_frk:
	move	a5,*a13(PDATA)	; for undo curve
	movi	CURVETBL,a8
	move	@ZBASE,a11,L	; start of curve
	clr	a3
	srl	Z2INDX+1,a10	; number of Z entries to do
	move	a10,a3			; else compute number of Z's
	movi	NUM_ZENT,a10		; to stay in curve when done.
	sub	a10,a3	  		; (inc is so it's never zero for
	srl	1,a3			;    a full curve)
	inc 	a3
	move	a3,*a13(PDATA+010h)	; save for sleep computation
	move	a10,*a13(PDATA+020h)	; save for undo_curve computation

trytry_frk:
	move	@ROADX,a7,L
	move	@ZBASE,a0,L	; current road pos
	sub	a11,a0		; index delta
	srl	Z2INDX+1,a0	; scale to index
	jrz	skpchg_frk
;	jrgt	forward
;
;forward:
	move	a0,a1		; save
	sll	Z2INDX+1,a1
	add	a1,a11		; new ZBASE as index
	movi	CIRC_MASK,a4	; circular mask
	movi	NUM_ZENT<<4,a6	; new values go at end of table
	sub	a0,a10		; update num entries
	jrge	adjnum_frk
	add	a10,a0
	sll	Z2INDX+1,a10
	add	a10,a11
	clr	a10		; signal end
adjnum_frk:
	sll	4,a0
	sub	a0,a6
	add	a0,a7 		; adjust ROADX
	and	a4,a7
	move	a7,@ROADX,L
	move	a7,a5
	addi	ROADOFFY-ROADOFFX,a5   ; a5 contains right pointer	
	move	a5,@ROADY,L
	add	a6,a7		; a7 contains left pointer
	add	a6,a5
	srl	4,a0

FRKLP:
	move	*a8+,a1
	btst	RD_B_FRKLFT,a9
	jrz	notlft
	and	a4,a7		; handle circularness of buffer
	move	a1,*a7+
notlft:
	btst	RD_B_FRKRT,a9
	jrz	notrt
	neg	a1
	and	a4,a5		; handle circularness of buffer
	move	a1,*a5+
notrt:
	dsjs	a0,FRKLP

	move	a10,a10		; check for end signal
	jrz	forkdun
	
skpchg_frk:	
	sloop	1,trytry_frk
	
forkdun:
	movi	ROADX,a8,L	; assume right side chosen, fade left
	move	@(XBASE+16),a0	; which lane we are in. (pos = rt, neg = lft)
	jrnn	endofrk
	movi	ROADY,a8	; left side chosen, fade right
	btst	RD_B_FRKRT,a9
	jrz	fadeslope
	movi	-1000h,a0	; place new lines offscreen
	jruc	fadecurve
endofrk:
	btst	RD_B_FRKLFT,a9
	jrz	fadeslope
	movi	1000h,a0		; place new lines offscreen
	
*
*	Leg to fade away is curved.
*	
fadecurve:
	move	a0,a9
	move	@ZBASE,a11,L	; start of curve fade
	movi	NUM_ZENT,a10	; to know when we're done
try_fade:	
	move	*a8,a7,L	; ROADX or ROADY
	move	@ZBASE,a0,L	; current road pos
	sub	a11,a0		; index delta
	srl	Z2INDX,a0	; scale to index
	jrz	skpchg_fade
;	jrgt	forward
;
;forward:
	move	a0,a1		; save
	sll	Z2INDX,a1
	add	a1,a11		; new ZBASE as index
	movi	CIRC_MASK,a4	; circular mask
	movi	NUM_ZENT<<4,a6	; new values go at end of table
	sub	a0,a10		; update num entries
	jrge	adjnum_fade
	add	a10,a0
	sll	Z2INDX+1,a10
	add	a10,a11
	clr	a10		; signal end
adjnum_fade:
	sll	4,a0
	sub	a0,a6
	add	a0,a7 		; adjust ROADX
	and	a4,a7
	move	a7,*a8,L
	add	a6,a7		; ptr to new entries
	srl	4,a0

FADELP:
	and	a4,a7
	move	a9,*a7+
	dsjs	a0,FADELP

	move	a10,a10		; check for end signal
	jrz	fadedun

skpchg_fade:	
	sloop	1,try_fade

*
*	Leg to fade away is straitaway.
*	
fadeslope:
	move	@ZBASE,a11,L	; start of curve fade
	move	a11,a9
	movi	NUM_ZENT,a10	; to know when we're done
try_slfade:	
	move	*a8,a7,L	; ROADX or ROADY
	move	@ZBASE,a0,L	; current road pos
	sub	a11,a0		; index delta
	srl	Z2INDX,a0	; scale to index
	jrz	skpchg_slfade
;	jrgt	forward
;
;forward:
	move	a0,a1		; save
	sll	Z2INDX,a1
	add	a1,a11		; new ZBASE as index
	movi	CIRC_MASK,a4	; circular mask
	sub	a0,a10		; update num entries
	jrge	adjnum_slfade
	add	a10,a0
	sll	Z2INDX+1,a10
	add	a10,a11
	clr	a10		; signal end
adjnum_slfade:
	move	a1,a5
	movi	355h,a1		; compute first entry of ROAD table
	sub	a10,a1
	sll	18-4,a1		; 10 bit fraction
	move	a1,a2
	sra	2,a2
	add	a2,a1		; 1.25 times diff between indices
	sub	a9,a5		; diff bet. orig ZBASE and current
	cmpi	ROADX,a8	; becomes slope with 10 bit fraction
	jreq	xxx
	neg	a5	     	; negate for right leg 
	neg	a1
xxx:
	movi	NUM_ZENT,a0
SLFADELP:
	move	a1,a2	 	; value with fraction
	sra	18,a2		; lose fraction
	and	a4,a7
	move	a2,*a7+		; store value
	add	a5,a1	 	; add slope to value with fraction
	dsjs	a0,SLFADELP

	move	a10,a10		; check for end signal
	jrz	fadedun

skpchg_slfade:	
	sloop	1,try_slfade
;
;	Check to see if we must undo remaining leg.
;
fadedun:
	move	@ROADFLG,a0
	cmpi	ROADX,a8	; what did we just fade
	jreq	tstrt		;
	btst	RD_B_FRKLFT,a0	; is left fork a curve?
	jrz	undodun		; skip undo if no.
	move	@ROADX,a9,L
	jruc	do_undo
	
tstrt:
	btst	RD_B_FRKRT,a0	; is right fork a curve?
	jrz	undodun		; skip undo if no.
	move	@ROADY,a9,L
	move	*a13(PDATA),a5
	xori	1,a5
	move	a5,*a13(PDATA)	; toggle if right curve

do_undo:	
	JSRP	UNDO_FORK_CURVE

undodun:
	clr	a14
	movi	ROADOFFY,a9
	move	a9,@ROADY,L
	movi	ROADOFFX,a10
	move	a10,@ROADX,L
	movi	512,a0		; number of long words
clr_rdtabs:
	move	a14,*a9+,L 	; clear 2 words at a time
	move	a14,*a10+,L 	; clear 2 words at a time
	dsjs	a0,clr_rdtabs

	move	@ROADFLG,a0
	andni	RD_INFORK|RD_FRK_BOTH,a0
	move	a0,@ROADFLG
	RETP



********************************************************************************
*									       *
*     Process to start a DIP                                                   *
*									       *
*	ENTRY:   a8 =  DIPTBL  for a complete dip			       *
*		    or YSQUIGTBL for a half dip				       *
*		 a10 = indicator for what to do after dip		       *
*                               ... level  (0)				       *
*                               ... hill      (1 or 5)			       *
*                               ... another dip  (2 or 6)		       *
*                               ... squiggle  (10 or 14)		       *
*									       *
********************************************************************************
UP_DIP:
	movi	UPCORE,a9	; one to do
	jruc	DO_DIP

DN_DIP:
	movi	DNCORE,a9	; one to do

DO_DIP:
	move	@ROADFLG,a0
	btst	RD_B_INFORK,a0
	jrnz	nododip
	btst	RD_B_INGRSH,a0
	jrz	dodip
nododip:
	sloop	10,DO_DIP
dodip:
	move	a10,*a13(PDATA)	; save indicator for UNDIP
	ori	RD_INHILL,a0
	move	a0,@ROADFLG
	move	@ZBASE,a11,L	; start of curve
	movi	NUM_ZENT,a10	; to stay in curve when done.

Dtry:
	move	@ROADY,a7,L
	move	@ZBASE,a0,L	; current road pos
	sub	a11,a0		; index delta
	srl	Z2INDX+1,a0	; scale to index
	jrz	Dskpchg
;	jrgt	forward
;
;forward:
	move	a0,a1		; save
	sll	Z2INDX+1,a1
	add	a1,a11		; new ZBASE as index
	movi	CIRC_MASK,a4	; circular mask
	move	a7,a6 		; copy of ROADX
	addi	NUM_ZENT<<4,a6	; new values go at end of table
	sub	a0,a10		; update num entries
	jrge	Dadjnum
	add	a10,a0
	sll	Z2INDX+1,a10
	add	a10,a11
	clr	a10		; signal end
Dadjnum:
	sll	4,a0
	add	a0,a7
	and	a4,a7
	move	a7,@ROADY,L
	srl	4,a0

	call	a9

	move	a10,a10		; check for end signal
	jrz	UNDIP
	
Dskpchg:	
	sloop	1,Dtry


UNDIP:
	move	*a13(PDATA),a10	; restore indicator for UNDIP
	clr	a6
	movi	DIPLEVCORE,a9	; level out routine
	btst	0,a10
	jrz	nohillnxt
	movi	HILLTBL,a8
	movi	UNDO_FULL_HILL,a6
	jruc	UDIPhook
nohillnxt:
	btst	1,a10
	jrz	nodipnxt
	movi	UNDIP,a6
	movi	YSQUIGTBL,a8
	btst	3,a10
	jrnz	UDIPhook
	movi	DIPTBL,a8
UDIPhook:
	movk	1,a5	  
	movi	XDNCORE,a9
	btst	2,a10
	jrz	upnxt
	movi	10000h,a5 
	movi	XUPCORE,a9
upnxt:
	move	a5,*a13(PDATA)	; for undo hill
nodipnxt:
	move	a6,*a13(PDATA+20h),L	; what to do when done
	move	@ROADY,a14,L
	addi	(NUM_ZENT-1)<<4,a14	; last entry becomes base
	andi	CIRC_MASK,a14
	move	*a14,a3
	move	@ZBASE,a11,L	; start of curve
	movi	NUM_ZENT,a10		; to stay in curve when done.

UDtry:
	move	@ROADY,a7,L
	move	@ZBASE,a0,L	; current road pos
	sub	a11,a0		; index delta
	srl	Z2INDX+1,a0	; scale to index
	jrz	UDskpchg
;	jrgt	forward
;
;forward:
	move	a0,a1		; save
	sll	Z2INDX+1,a1
	add	a1,a11		; new ZBASE as index
	movi	CIRC_MASK,a4	; circular mask
	move	a7,a6 		; copy of ROADY
	addi	NUM_ZENT<<4,a6	; new values go at end of table
	and	a4,a6
	sub	a0,a10		; update num entries
	jrge	UDadjnum
	add	a10,a0
	sll	Z2INDX+1,a10
	add	a10,a11
	clr	a10		; signal end
UDadjnum:
	sll	4,a0
	add	a0,a7
	and	a4,a7
	dint
	move	a7,@ROADY,L
	srl	4,a0
	move	*a7,a2		; amount to shift all
	jrz	UDskpshift	; no need if first entry is 0
UDCORE:
	move	*a7,a1
	sub	a2,a1
	move	a1,*a7+
	and	a4,a7
	cmp	a7,a6
	jrne	UDCORE
	sub	a2,a3		; adjust base for new values
UDskpshift:
	call	a9
	eint
	
	move	a10,a10
	jrz	UDdun
	
UDskpchg:	
	move	a3,*-a12
	sleep	1
	move	*a12+,a3
	jruc	UDtry

UDdun:
	move	*a13(PDATA+20h),a6,L
	jrz	UDallclean
	clr	a8
	jump	a6		; undo squiggle or curve just done
UDallclean:
	move	@ROADFLG,a0
	andni	RD_INHILL,a0 	; signal cleanup
	move	a0,@ROADFLG
	RETP





*==================================================================================
*	a10 = indicator to go from squiggle into... straightaway  (0)
*                                              ... curve      (1 or 5)
*                                              ... another squiggle  (2 or 6)

LFT_SQUIG:
	movi	RTCORE,a3	; one not to do
	movi	LFTCORE,a9	; one to do
	jruc	SQUIGGLE

RT_SQUIG:
	movi	LFTCORE,a3	; one not to do
	movi	RTCORE,a9	; one to do

SQUIGGLE:
	move	a10,*a13(PDATA)
	move	@ROADFLG,a0
	ori	RD_INCURV,a0
	move	a0,@ROADFLG
	move	@NO_MIRROR,a14
	jrnz	SQswpcor
	move	a3,a9
SQswpcor:
	movi	SQUIGTBL,a8
	move	@ZBASE,a11,L	; start of curve
	movi	NUM_ZENT,a10	; to stay in curve when done.

SQtry:
	move	@ROADX,a7,L
	move	@ZBASE,a0,L	; current road pos
	sub	a11,a0		; index delta
	srl	Z2INDX+1,a0	; scale to index
	jrz	SQskpchg
;	jrgt	forward
;
;forward:
	move	a0,a1		; save
	sll	Z2INDX+1,a1 
	add	a1,a11		; new ZBASE as index
	movi	CIRC_MASK,a4	; circular mask
	move	a7,a6 		; copy of ROADX
	addi	NUM_ZENT<<4,a6	; new values go at end of table
	sub	a0,a10		; update num entries
	jrge	SQadjnum
	add	a10,a0
	sll	Z2INDX+1,a10
	add	a10,a11
	clr	a10		; signal end
SQadjnum:
	sll	4,a0
	add	a0,a7
	and	a4,a7
	move	a7,@ROADX,L
	srl	4,a0

	call	a9

	move	a10,a10		; check for end signal
	jrz	UNSQUIGGLE
	
SQskpchg:	
	sloop	1,SQtry



XRTCORE:
	and	a4,a6		; handle circularness of buffer
	move	*a8+,a1
	add	a3,a1
	move	a1,*a6+
	dsjs	a0,XRTCORE
	rets

XLFTCORE:
	move	*a8+,a1
	neg	a1 		; table value = ROADWID-tablevalue
	and	a4,a6		; handle circularness of buffer
	add	a3,a1
	move	a1,*a6+
	dsjs	a0,XLFTCORE
	rets


XUPCORE:
	and	a4,a6		; handle circularness of buffer
;	or	a5,a6
	move	*a8+,a1
	neg	a1 		; table value = ROADWID-tablevalue
;	srl	1,a1
	add	a3,a1
	move	a1,*a6+
	dsjs	a0,XUPCORE
	rets

XDNCORE:
	move	*a8+,a1
;	srl	1,a1
	and	a4,a6		; handle circularness of buffer
;	or	a5,a6
	add	a3,a1
	move	a1,*a6+
	dsjs	a0,XDNCORE
	rets



UNSQUIGGLE:
	move	*a13(PDATA),a10		; restore indicator
	clr	a6
	movi	SQSTCORE,a9
	btst	0,a10
	jrz	nocurvnxt
	movi	CURVETBL,a8
	movi	UNDO_FULL_CURVE,a6
	jruc	USQhook
nocurvnxt:
	btst	1,a10
	jrz	nosquignxt
	movi	UNSQUIGGLE,a6
	movi	SQUIGTBL,a8
USQhook:
	movk	1,a5		; flag not to do in upper, flag to do in lower
	movi	XLFTCORE,a9
	btst	2,a10
	jrz	lftnxt
	movi	10000h,a5	; flag not to do in upper
	movi	XRTCORE,a9
lftnxt:
	move	a5,*a13(PDATA)	; for undo curve
nosquignxt:
	move	a6,*a13(PDATA+20h),L	; what to do when done
	move	@ROADX,a14,L
	addi	(NUM_ZENT-1)<<4,a14	; last entry becomes base
	andi	CIRC_MASK,a14
	move	*a14,a3
	move	@ZBASE,a11,L	; start of curve
	movi	NUM_ZENT,a10		; to stay in curve when done.

UNSQtry:
	move	@ROADX,a7,L
	move	@ZBASE,a0,L	; current road pos
	sub	a11,a0		; index delta
	srl	Z2INDX+1,a0	; scale to index
	jrz	UNSQskpchg
;	jrgt	forward
;
;forward:
	move	a0,a1		; save
	sll	Z2INDX+1,a1
	add	a1,a11		; new ZBASE as index
	movi	CIRC_MASK,a4	; circular mask
	move	a7,a6 		; copy of ROADX
	addi	NUM_ZENT<<4,a6	; new values go at end of table
	and	a4,a6
	sub	a0,a10		; update num entries
	jrge	UNSQadjnum
	add	a10,a0
	sll	Z2INDX+1,a10
	add	a10,a11
	clr	a10		; signal end
UNSQadjnum:
	sll	4,a0
	add	a0,a7
	and	a4,a7
	move	a7,@ROADX,L
	srl	4,a0
	move	*a7,a2		; amount to shift all
	jrz	skpshift	; no need if first entry is 0
UNSQCORE:
	move	*a7,a1
	sub	a2,a1
	move	a1,*a7+
	and	a4,a7
	cmp	a7,a6
	jrne	UNSQCORE
	sub	a2,a3		; adjust base for new values
skpshift:
	call	a9

	move	a10,a10
	jrz	UNSQdun
	
UNSQskpchg:	
	move	a3,*-a12
	sleep	1
	move	*a12+,a3
	jruc	UNSQtry

UNSQdun:
	move	*a13(PDATA+20h),a6,L
	jrz	allclean
	clr	a8
	jump	a6		; undo squiggle or curve just done
allclean:
	move	@ROADFLG,a0
	andni	RD_INCURV,a0 	; signal cleanup
	move	a0,@ROADFLG
	RETP



*	Assumption... straightaway
SQSTCORE:
	and	a4,a6
	move	a3,*a6+
	dsjs	a0,SQSTCORE
	rets

*	Assumption... level
DIPLEVCORE:
	and	a4,a6
;	or	a5,a6
	move	a3,*a6+
	dsjs	a0,DIPLEVCORE
	rets



DN_HILL:
	clr	a5		; flag not to do in upper, flag to do in lower
	movi	DNCORE,a9	; one to do
	jruc	DO_HILL

UP_HILL:
	movk	1,a5	; flag not to do in upper
	movi	UPCORE,a9	; one to do

DO_HILL:
	move	@ROADFLG,a0
	btst	RD_B_INFORK,a0
	jrnz	nodohill
	btst	RD_B_INGRSH,a0
	jrz	dohill
nodohill:
      	sloop	10,DO_HILL
dohill:
	ori	RD_INHILL,a0
	move	a0,@ROADFLG
	move	a5,*a13(PDATA)	; for undo HILL
	movi	HILLTBL,a8
	move	@ZBASE,a11,L	; start of hill
	clr	a3
	srl	Z2INDX+1,a10	; number of Z entries to do
	cmpi	NUM_ZENT,a10	; if less than full hill, jump
	jrlt	Hdopartial
	move	a10,a3			; else compute hill of Z's
	movi	NUM_ZENT,a10		; to stay in curve when done.
	sub	a10,a3	  		; (inc is so it's never zero for
	srl	1,a3			;    a full curve)
	inc 	a3
Hdopartial:
	move	a3,*a13(PDATA+010h)	; save for sleep computation
	move	a10,*a13(PDATA+020h)	; save for undo_curve computation

Htrytry:
	move	@ROADY,a7,L
	move	@ZBASE,a0,L	; current road pos
	sub	a11,a0		; index delta
	srl	Z2INDX+1,a0	; scale to index
	jrz	Hskpchg
;	jrgt	forward
;
;forward:
	move	a0,a1		; save
	sll	Z2INDX+1,a1	; scale to index
	add	a1,a11		; new ZBASE as index
;	movi	ROADOFFY,a5	; buffer start
	movi	CIRC_MASK,a4	; circular mask
	move	a7,a6 		; copy of ROADX
	addi	NUM_ZENT<<4,a6	; new values go at end of table
	sub	a0,a10		; update num entries
	jrge	Hadjnum
	add	a10,a0
	sll	Z2INDX+1,a10
	add	a10,a11
	clr	a10		; signal end
Hadjnum:
	sll	4,a0
	add	a0,a7 		; adjust ROADX
	and	a4,a7
	move	a7,@ROADY,L
	srl	4,a0

	call	a9

	move	a10,a10		; check for end signal
	jrz	hilldun
	
Hskpchg:	
	sloop	1,Htrytry

hilldun:
	move	@ZBASE,a11,L
	move	*a13(PDATA+16),a9	; if 0, we did a partial curve
	jrz	UNDO_PARTIAL_HILL
	sll	Z2INDX+1,a9	; back to Z position
	add	a11,a9
hillwait:
	sleep	1
	move	@ZBASE,a11,L
	cmp	a11,a9
	jrgt	hillwait		; if desired ZBASE is passed, fall through
	      	

UNDO_FULL_HILL:
	movi	HSLOPETBL+(NUM_ZENT<<4),a8 ; 
	move	@ZBASE,a11,L	; start of straitaway
	movi	NUM_ZENT,a10		; entry count
	move	@ROADY,a9,L
UFHtry:
	move	@ZBASE,a0,L	; current road pos
	sub	a11,a0		; index delta
	srl	Z2INDX+1,a0 	; scale to index
	jrz	UFHskpchg
;	jrgt	forward
;
;forward:
	move	a0,a1		; save
	sll	Z2INDX+1,a1
	add	a1,a11		; new ZBASE as index
	movi	CIRC_MASK,a4	; circular mask
;	movi	ROADOFFY,a5	; buffer start
	sub	a0,a10		; update num entries
	jrle	UFHdun

	move	a10,a3
	dec	a3		
	sll	4,a3
	add	a9,a3		; where in ROADX to start fixed slope
	and	a4,a3
;	or	a5,a3
	move	*a3+,a6		; value to start from
	sll	16,a6		; adjust to full scale
	sll	4,a0
	sub	a0,a8		; get ptr to slope.
	move	*a8,a2		; slope
	sll	8,a2		; adjust to full scale

	movi	NUM_ZENT,a0
	sub	a10,a0		; number of entries to fill	

	move	*a13(PDATA),a1
	jrz	UFHCORE
	neg	a2
UFHCORE:
	add	a2,a6
	move	a6,a1
	srl	16,a1
	and	a4,a3
;	or	a5,a3
	move	a1,*a3+
	dsjs	a0,UFHCORE

UFHskpchg:	
	sloop	1,UFHtry

UFHdun:
	sleep	1
	movi	CIRC_MASK,a4	; circular mask
;	movi	ROADOFFY,a5	; buffer start
	movi	NUM_ZENT,a0
	clr	a1
UFHclnup:
	move	a1,*a9+
	and	a4,a9
;	or	a5,a9
	dsjs	a0,UFHclnup

	move	@ROADFLG,a0
	andni	RD_INHILL,a0 	; signal cleanup
	move	a0,@ROADFLG
	RETP




UNDO_PARTIAL_HILL:
	move	*a13(PDATA+020h),a10	; number of entries of curve done
	movi	NUM_ZENT,a8	; number in a full curve
	sub	a10,a8		; if no, how many entries undone?

	sll	4,a10
	addi	HSLOPETBL,a10
	move	a10,*a13(PDATA+40h),L	; save for jump to UNDO_FULL
	move	*a10,a10	; slope in a10
	sll	8,a10
	move	*a13(PDATA),a1
	jrz	Hrvsl
	neg	a10
Hrvsl:
	move 	@ROADY,a9,L
	addi	(NUM_ZENT-1)<<4,a9  ; last entry
	andi	CIRC_MASK,a9
;	ori	ROADOFFY,a9
	move	*a9+,a2		; base for slope addition
	sll	16,a2

UHtry1:
	move	@ROADY,a7,L
	move	@ZBASE,a0,L	; current road pos
	sub	a11,a0		; index delta
	srl	Z2INDX+1,a0 	; scale to index
	jrz	UHskpchg
;	jrgt	forward
;
;forward:
	move	a0,a1		; save
	sll	Z2INDX+1,a1
	add	a1,a11		; new ZBASE as index
	movi	CIRC_MASK,a4	; circular mask
;	movi	ROADOFFY,a5
*
*	Adjust ROADX
*
	sub	a0,a8
	jrge	UHovrrun
	add	a8,a0
	sll	Z2INDX+1,a8
	add	a8,a11
	clr	a8
UHovrrun:
	sll	4,a0
	add	a0,a7 		; adjust ROADX
	and	a4,a7
;	or	a5,a7
	move	a7,@ROADY,L
	srl	4,a0
*
*	stuff straight line
*
UHCORE1:
	add	a10,a2
	move	a2,a1
	srl	16,a1
	and	a4,a9
;	or	a5,a9
	move	a1,*a9+
	dsjs	a0,UHCORE1

	move	a8,a8
	jrz	moveon

UHskpchg:	
	mmtm	a12,a2
	sleep	1
	mmfm	a12,a2
	jruc	UHtry1

UHmoveon:
	move	@ROADY,a9,L
	move	*a13(PDATA+40h),a8,L
	move	*a13(PDATA+20h),a10	; number of entries of curve done
	jruc	UFHskpchg





LFT_CURVE:
	movk	1,a5		; flag not to do in upper, flag to do in lower
	movi	RTCORE,a3	; one not to do
	movi	LFTCORE,a9	; one to do
	jruc	DO_CURVE

RT_CURVE:
	movi	10000h,a5	; flag not to do in upper
	movi	LFTCORE,a3	; one not to do
	movi	RTCORE,a9	; one to do

DO_CURVE:
	move	@ROADFLG,a0
	ori	RD_INCURV,a0
	move	a0,@ROADFLG
	move	@NO_MIRROR,a14
	jrnz	swapcore
	rl	16,a5		
	move	a3,a9
swapcore:
	move	a5,*a13(PDATA)	; for undo curve
	movi	CURVETBL,a8
	move	@ZBASE,a11,L	; start of curve
	clr	a3
	srl	Z2INDX+1,a10	; number of Z entries to do
	cmpi	NUM_ZENT,a10	; if less than full curve, jump
	jrlt	dopartial
	move	a10,a3			; else compute number of Z's
	movi	NUM_ZENT,a10		; to stay in curve when done.
	sub	a10,a3	  		; (inc is so it's never zero for
	srl	1,a3			;    a full curve)
	inc 	a3
dopartial:
	move	a3,*a13(PDATA+010h)	; save for sleep computation
	move	a10,*a13(PDATA+020h)	; save for undo_curve computation

trytry:
	move	@ROADX,a7,L
	move	@ZBASE,a0,L	; current road pos
	sub	a11,a0		; index delta
	srl	Z2INDX+1,a0	; scale to index
	jrz	skpchg
;	jrgt	forward
;
;forward:
	move	a0,a1		; save
	sll	Z2INDX+1,a1
	add	a1,a11		; new ZBASE as index
	movi	CIRC_MASK,a4	; circular mask
	move	a7,a6 		; copy of ROADX
	addi	NUM_ZENT<<4,a6	; new values go at end of table
	sub	a0,a10		; update num entries
	jrge	adjnum
	add	a10,a0
	sll	Z2INDX+1,a10
	add	a10,a11
	clr	a10		; signal end
adjnum:
	sll	4,a0
	add	a0,a7 		; adjust ROADX
	and	a4,a7
	move	a7,@ROADX,L
	srl	4,a0

	call	a9

	move	a10,a10		; check for end signal
	jrz	curvdun
	
skpchg:	
	sloop	1,trytry


DNCORE:
RTCORE:
	and	a4,a6		; handle circularness of buffer
	move	*a8+,*a6+
	dsjs	a0,RTCORE
	rets

UPCORE:
LFTCORE:
	move	*a8+,a1
	neg	a1 		; table value = ROADWID-tablevalue
	and	a4,a6		; handle circularness of buffer
	move	a1,*a6+
	dsjs	a0,LFTCORE
	rets



curvdun:
	move	@ZBASE,a11,L
	move	*a13(PDATA+16),a9	; if 0, we did a partial curve
	jrz	UNDO_PARTIAL_CURVE
	sll	Z2INDX+1,a9	; back to Z position
	add	a11,a9
crvwait:
	sleep	1
	move	@ZBASE,a11,L
	cmp	a11,a9
	jrgt	crvwait		; if desired ZBASE is passed, fall through
	      	

UNDO_FULL_CURVE:
	move	@ROADX,a9,L
UNDO_FORK_CURVE:
	movi	SLOPETBL+(NUM_ZENT<<4),a8 ; 
	move	@ZBASE,a11,L	; start of straitaway
	movi	NUM_ZENT,a10		; entry count
UFCtry:
	move	@ZBASE,a0,L	; current road pos
	sub	a11,a0		; index delta
	srl	Z2INDX+1,a0 	; scale to index
	jrz	UFCskpchg
;	jrgt	forward
;
;forward:
	move	a0,a1		; save
	sll	Z2INDX+1,a1   
	add	a1,a11		; new ZBASE as index
	movi	CIRC_MASK,a4	; circular mask
	sub	a0,a10		; update num entries
	jrle	UFCdun

	move	a10,a5
	dec	a5		
	sll	4,a5
	add	a9,a5		; where in ROADX to start fixed slope
	and	a4,a5
	move	*a5+,a6		; value to start from
	sll	16,a6		; adjust to full scale
	sll	4,a0
	sub	a0,a8		; get ptr to slope.
	move	*a8,a2		; slope
	sll	8,a2		; adjust to full scale

	movi	NUM_ZENT,a0
	sub	a10,a0		; number of entries to fill	

	move	*a13(PDATA),a1
	jrz	UFCORE
	neg	a2
UFCORE:
	add	a2,a6
	move	a6,a1
	srl	16,a1
	and	a4,a5
	move	a1,*a5+
	dsjs	a0,UFCORE

UFCskpchg:	
	sloop	1,UFCtry

UFCdun:
	sleep	1
	movi	CIRC_MASK,a4	; circular mask
	movi	NUM_ZENT,a0
	clr	a1
UFCclnup:
	move	a1,*a9+
	and	a4,a9
	dsjs	a0,UFCclnup

	move	@ROADFLG,a0
	andni	RD_INCURV,a0 	; signal cleanup
	move	a0,@ROADFLG
	RETP



UNDO_PARTIAL_CURVE:
	move	*a13(PDATA+020h),a10	; number of entries of curve done
	movi	NUM_ZENT,a8	; number in a full curve
	sub	a10,a8		; if no, how many entries undone?

	sll	4,a10
	addi	SLOPETBL,a10
	move	a10,*a13(PDATA+40h),L	; save for jump to UNDO_FULL
	move	*a10,a10	; slope in a10
	sll	8,a10
	move	*a13(PDATA),a1
	jrz	rvsl
	neg	a10
rvsl:
	move 	@ROADX,a9,L
	addi	(NUM_ZENT-1)<<4,a9  ; last entry
	andi	CIRC_MASK,a9
	move	*a9+,a2		; base for slope addition
	sll	16,a2

UCtry1:
	move	@ROADX,a7,L
	move	@ZBASE,a0,L	; current road pos
	sub	a11,a0		; index delta
	srl	Z2INDX+1,a0 	; scale to index
	jrz	UCskpchg
;	jrgt	forward
;
;forward:
	move	a0,a1		; save
	sll	Z2INDX+1,a1   
	add	a1,a11		; new ZBASE as index
	movi	CIRC_MASK,a4	; circular mask
*
*	Adjust ROADX
*
	sub	a0,a8
	jrge	ovrrun
	add	a8,a0
	sll	Z2INDX+1,a8
	add	a8,a11
	clr	a8
ovrrun:
	sll	4,a0
	add	a0,a7 		; adjust ROADX
	and	a4,a7
	move	a7,@ROADX,L
	srl	4,a0
*
*	stuff straight line
*
UCORE1:
	add	a10,a2
	move	a2,a1
	srl	16,a1
	and	a4,a9
	move	a1,*a9+
	dsjs	a0,UCORE1

	move	a8,a8
	jrz	moveon

UCskpchg:	
	mmtm	a12,a2
	sleep	1
	mmfm	a12,a2
	jruc	UCtry1

moveon:
	move	@ROADX,a9,L
	move	*a13(PDATA+40h),a8,L
	move	*a13(PDATA+20h),a10	; number of entries of curve done
	jruc	UFCskpchg





	.include "curvtbl.src"
	.include "squigtbl.src"
	.include "ysquig.src"
	.include "diptbl.src"
	.include "hilltbl.src"


PIX_TO_LOSE  .set	0

SCROLL_ROAD

;	CREATE	PID_IND,SKEW_IN_Y

;	CREATE	PID_IND,SKEW_IN_X


	move	@ZBASE,a8,L
	sleep	1
RLOOP
	MOVE	@(ZSCROLL+16),A10
	add	a10,a8
	move	a8,@ZBASE,L

	SLEEP	1
	JRUC	RLOOP


LOGROADPITCH	.set	ROADBITS+3
ROADPITCH	.set	ROADWD*8	; Road is 256 pixels wide, 8 bpp


;ROAD_Z_ENT	.macro
;	.asg 253,line
;	.asg 400h,cmpval
;	.loop ROADH0
;	.eval WORLD_Y/(line-HALFY+1),ZVAL
;	.long ZVAL
;	.if line==253
;LNGST	.equ	10000h/(ZVAL>>7)	; length of longest line
;	.endif
;	.if (ZVAL>>7)>=cmpval
;	.eval 100000h,cmpval
;	.endif
;	.eval	line-1,line
;	.endloop
;SHRTST	.equ	10000h/(ZVAL>>7)	; length of shortest line
;	.endm
;
;ROAD_Z_TBL:
;	ROAD_Z_ENT	


BASE_TRYAGAIN	.set	200h
DELTA_TRYAGAIN	.set	5


	.if	OLDWAY==1
;
;	ROADPAL in a2 upon entry
;
;	b0 = ZPOS
;       b1 = WORLD_Y
;       b2 = ROADY
;	b3 = flag for min saving
;	b4 = last min : last WORLDY
;       b6 = XBASE
;	b7 = ROADX
;	b8 =  delta for Z
;	b5,b9 = scratch
;	b10 = PAGE offset to DAG
;	b14 = CIRC_MASK
;
;	a0 = ZBASE (to get start of road image)
;	a1 = scale
;	a2 = const:pal
;	a3 = Y:X size
;	a4 = DAG
;	a5 = SAG
;	a6 = control word
;	a7 = last SCRN Y MIN: line repeat factor
;	a8 = 0ff0h (for getting line # within road img)
;	a9 = ZPOS of last min (for YMINTBL)
;	a10 = ROAD2ADDR (base SAG for road)
;	a11 = DMA Q ptr
;	a12 = bits to shift per line of road for SAG adjust
;	a13 = where to store Y mins (YMINTBL ptr)
;	a14 = bits to shift to get from ZPOS to scale
DO_ROAD:				; original one... ignore
	MOVI	DMAIQBOT2,A11
	CMPI	DMAIQBOT,B12
	JRLS	TRYAGAIN
	MOVI	DMAIQBOT,A11	; Q in A11
TRYAGAIN:			
	movi	BASE_TRYAGAIN,b8 	; change in Z between iterations
	movi	[0feh,BASE_TRYAGAIN],b4	; last min Y : tryagain factor
	movi	CIRC_MASK,b14
	move	@FORKFLG,b3
	sll	31,b3
	or	b3,b14
	movk	3,b3     		; do not write min to table
	movi	YMINTBL+SIZYMINTBL,a13  ; where to store Y MINS
	MOVI	[08002H,0],a6 		;CONTROL WORD 				
	move	@ROADWID,a3
	addi	10000h,a3		; Y:X Unscaled Size
			
	move	@ZBASE,a0,L	; first line of image

	movk	32-Z2SCALE,a14	; bits to shift to get from Zpos to scale
	MOVE	@PAGEADDR,b10,L

	.if	PUNKROCKER

	SRL	16,B10

	.else

	srl	12,b10     	; convert to line number

	.endif

	xori	SCRHGHT,b10
	sll	16,b10
	movi	[100h,0h],A1 	     ; upper 16 is Y scale factor
	movi    LOGROADPITCH-8,a12   ; bits to shift per line of road for SAG adjust

	move	@ROAD2ADDR,a10,L	; SAG of large road piece in A10
	movi	ZMAX,b0			; Z position to work on
	movi	0ff00h,a8
	move	@ROADY,b2,L
	move	@ROADX,b7,L
	move	@(YBASE+16),b1
	sll	18,b1
	addi	ROAD_WORLD_Y<<2,b1	; shift by 2 for rounding
	move	@(XBASE+16),b6		; skew factor
	sll	17,b6			; 16 + 1 for rounding
	.align
DO_ROAD_LOOP:
*	handle Y
	move	b0,b5		; ZPOS
	subi	ZMAX,b5 	; adjusted ZPOS
	srl	Z2INDX,b5	; turn into table index	
	sll	4,b5		; indexed by words into ROADOFFX
	move	b5,b9		; save for X handling
	add	b2,b5
	and	b14,b5
;	ori	ROADOFFY,b5    	; handle circularness
	move	*b5,b5		; WORLD Y OFFSET for this Z
	sll	18,b5		; *4 to get rounding bits
	add	b1,b5  		; add base WORLD_Y 
	divs	b0,b5
	addi	(HALFY<<2)+2,b5	; round
	sll	14,b5		; rounded unscaled in upper
	cmpxy	b5,b4		; is new scrnY less than prev min?
	jrygt	newmin		; if yes, replace min
	jryz	keepmin
	addk	1,b3
	cmpi	3,b3
	jrne	keepmin
	.if	DEBUG
	cmpi	YMINTBL,a13
	LOCKON	EQ
	.endif
	mmtm	a13,a7,a9	; save bump in table
	jruc	keepmin
newmin:
	subxy	b5,b4		; dy in a4
;	cmpi	40000h,b4
;	jrlt	upto3
;	addxy	b5,b4		; restore min in upper a4
;	move	b4,b5		; previous tryagain factor in b5
;	zext	b5		; b5 has half of prev. tryagain fac
;	srl	1,b5
;	inc	b5
;	sub	b5,b0		; adjust Z
;	movx	b5,b4		; save new tryagain factor
;	jruc	DO_ROAD_LOOP	; try again
;upto3:
;	movk	1,b4
	srl	16,b4		; repeat number in b4 lower
	movy	b5,b4		; new min in b4 upper
	move	b4,a7		; new min: repeat factor in a7
	clr	b3		; clr counter/flag
	move	b0,a9		; Z in a9
	add	b7,b9
	and	b14,b9 		; handle circularness
	move	*b9,b9		; WORLD X OFFSET FOR THIS Z
	sll	17,b9		; *2 to get rounding bit
	btst	31,b14		; test FORKFLG
	jrz	nofork
	move	b9,a5		; save orig b9
	neg	b9
	add	b6,b9
	divs	b0,b9
	addi	(HALFX<<1)+1,b9     	; DAG X * 2 with rounding
	srl	1,b9		; back to normal scale
	movy	b5,b9		; DAG Y:X in b9
	move	b9,*-sp		; PUSH b9	
	move	a5,b9		; restore b9
nofork:
	add	b6,b9		; add base ROAD XPOS
	divs	b0,b9	    	; WORLD X / ZPOS
	addi	(HALFX<<1)+1,b9 ; DAG X * 2 with rounding
	srl	1,b9		; back to normal scale
	movy	b5,b9		; DAG Y:X in b9
	addxy	b10,b9		; final DAG in b9
	
	move	b0,a5		; for XOFF computation
	srl	a14,a5		; X scale factor for this line in A1
	cmpi	400h,a5
	jrle	notqln
	movx	a3,a4
	srl	2,a4
	movx	a4,a3		; don't erase y size
	move	@ROADADDR,a10,L	; SAG of small road piece in A10
	subk	2,a14  		; shift scale by 2 more from now on
	subk	2,a12		; change pitch of road image
	srl	2,a5		; adjust scale just computed
	sll	1,b8
notqln:
	movx	a5,a1		; y scale is 100
	move	b9,a4		; complete DAG in a4

	move	b0,a5		; restore ZPOS for SAG computation
	add	a0,a5		; add to start ZPOS for this image
	and	a8,a5 		; line number within 256 line block	
	sll	a12,a5 		; offset to SAG
	add	a10,a5		; SAG in a5 

*
*	A1 = SCALE
*	A2 = CONST:PAL	  (const)
*	A3 = VSIZE:HSIZE  (const)
*	A4 = DAG Y:X
*	A5 = SAG
*	A6 = CTRL:OFSET	  (const)
*			  	Q THIS DMA REQUEST
	move	a7,b9		; repeat count
	zext	b9
	movi	M_FLIPH<<16,a8
linloop:
	MMTM	A11,A1,A2,A3,A4,A5,A6		;STORE THE DMA REGS
	btst	31,b14
	jrz	nofrk2
       	move	*sp+,a8
	movx	a8,a4			; different dag on fork
	movi	M_FLIPH<<16,a8
nofrk2:
	xor	a8,a6
	MMTM	A11,A1,A2,A3,A4,A5,A6		;STORE THE DMA REGS
	addi	10000h,a4	
	xor	a8,a6
	dsjs	b9,linloop
	movi	0ff00h,a8		; restore a8
keepmin:
	movx	b8,b4			; restore tryagain factor
	ADDIR	DELTA_TRYAGAIN,b8
;	cmpi	2000h,b8
;	jrge	$
	add	b8,b0
	cmpi	ZMIN,b0
	jrle	DO_ROAD_LOOP

	srl	16,b4			; save new horizon (must be even)
	andi	01feh,b4		; must be even
	move	b4,@HORIZON
	MOVE	A11,@DMAIQACT,L
	move	a13,@YMINPTR,L
	rets

	.endif


; YMINPTR table contains...  .long ZPOS of Y
;			     .word junk_word
;                            .word Screen Y at that Z


*
*	For each line of the road this tbl gives the WORLD Z.
*
;   .long     6822,  6906,  69ee,  6ada,  6bca,  6cbe,  6db6,  6eb3   ; 253 to 246
;   .long     6fb5,  70bb,  71c7,  72d7,  73ec,  7507,  7627,  774d   ; 245 to 238
;   .long     7878,  79a9,  7ae1,  7c1f,  7d63,  7eae,  8000,  8158   ; 237 to 230
;   .long     82b9,  8421,  8590,  8708,  8888,  8a11,  8ba2,  8d3d   ; 229 to 222
;   .long     8ee2,  9090,  9249,  940c,  95da,  97b4,  9999,  9b8b   ; 221 to 214
;   .long     9d89,  9f95,  a1af,  a3d7,  a60d,  a854,  aaaa,  ad12   ; 213 to 206
;   .long     af8a,  b216,  b4b4,  b767,  ba2e,  bd0b,  c000,  c30c   ; 205 to 198
;   .long     c631,  c971,  cccc,  d045,  d3dc,  d794,  db6d,  df6b   ; 197 to 190
;   .long     e38e,  e7d9,  ec4e,  f0f0,  f5c2,  fac6, 10000, 10572   ; 189 to 182
;   .long    10b21, 11111, 11745, 11dc4, 12492, 12bb5, 13333, 13b13   ; 181 to 174
;   .long    1435e, 14c1b, 15555, 15f15, 16969, 1745d, 18000, 18c63   ; 173 to 166
;   .long    19999, 1a7b9, 1b6db, 1c71c, 1d89d, 1eb85, 20000, 21642   ; 165 to 158
;   .long    22e8b, 24924, 26666, 286bc, 2aaaa, 2d2d2, 30000, 33333   ; 157 to 150
;   .long    36db6, 3b13b, 40000, 45d17, 4cccc, 55555, 60000          ; 149 to 143

*
*
SKEW_IN_Y:
	movi	(YBASE+16),a8
	movi	18000h,a9 	; acceleration
	clr	a10		; current value
	movi	1800000h,a11	; limit
SkewY0:
	add	a9,a10
	move	a10,a1
	jrge	SkewY2
       	clr	a1		; never becomes negative
SkewY2:
	sra	16,a1
	move	a1,*a8
	move	a10,a1
	abs	a1
	cmp	a1,a11
	jrgt	SkewY1
	neg	a9
SkewY1:
	sloop	1,SkewY0
	

SKEW_IN_X:
	movi	XBASE+16,a8
	movi	0c000h,a9 	; acceleration
	clr	a10		; current value
	movi	0c0h,a11	; limit
SkewX0:
	add	a9,a10
	move	a10,a1
	sra	16,a1
	move	a1,*a8
	move	a1,a1
	jrp	SkewX1
	abs	a1
SkewX1:
	cmp	a1,a11
	jrgt	SkewX2
	neg	a9
SkewX2:
	sloop	1,SkewX0






**************************************************************************
*								         *
* START_ROAD								 *
*								         *
**************************************************************************

START_ROAD
	CMP	B12,B13
	JRLS	ABORT_ROAD
	
	setf	1,0,0		;field 0 is 1 bit
	movk	1,B14
	move	B14,@(INTENB+B_X1E),0
	setf	16,1,0
JS_WAIT
	MOVE	@DMACTRL,B14,W	;@DMACTRL,  DMA BUSY?
	JRN	JS_WAIT		;BR = YES

	movi	DMAREGS,B14
	move	-*B13,-*B14,L	;Y-SCALE:X-SCALE
	move	-*B13,-*B14,L	;CONST:PALETTE XLATE
	move	-*B13,B11,L	;VSIZE:HSIZE
	move	B11,-*B14,L	;VSIZE:HSIZE
	move	-*B13,-*B14,L	;DESTINATION Y:X
	move	-*B13,-*B14,L	;IMAGE SAG
	MOVE	-*B13,-*B14,L	;CTRL:OFFSET
ABORT_ROAD
	RETS


*	This is not a general purpose routine!
*	It is intended to be called from PrePutPlanes and DISPNEXT
*		where a8 is maintained as a ZPOS, and a13 and a14
*		are maintained as the DMA window.
*		b0 must have been set to contain YMINPTR before the FIRST
*		time this is called.
*		b12 is the current DMA Q pointer
SET_FIRST_HILL:
	move	@YMINPTR,b0,L
	clr	a8				; ZPOS of current min
	cmpi	YMINTBL+SIZYMINTBL,b0
	jreq	nohills
	move	b0,a7
	move	*a7+,a8,L		; new Z pos
	move	*a7+,a1,L		; new scrn Y:junk
	move	a7,b0
	movy	a1,a13			; new window bottom

	move	a14,a7
	rl	16,a7			; get top in lower 16 bits
	movx	a7,a1			; a1 contains bottom:top
	move	@PAGE,b5,W
	jrz	zpage
	ADDI	[SCRHGHT,SCRHGHT],a1
zpage:
	move	b12,a7		; place window change on Q
	neg	a1
	move	a1,*-a7,L
	move	a7,b12
nohills:
	rets



	.if	OLDWAY==0

*********************************************************************
*
*	ENTRY:  nothing
*
*	COMPUTED:
*       b0 = index
*	b1 = scratch
* 	b2   becomes Z
*	b3  = Start of ROADY table
*       b4 =  index delta
*	b5   becomes Scrn Y
*       b6 = XBASE
* 	b7 = ptr to ROADX
*	b8 = PAGE offset to DAG
*	b9  = Base of WORLD Y
*	b10 = ZMAX
*	b14 = CIRC_MASK
*
*	a0 = ZBASE (to get start of road image)
*	a1 = scale
*	a2 = const:pal
*	a3 = Y:X size
*	a4 = DAG when ready to DMA, otherwise last SCRN Y MIN:next hill indx
*	a5 = SAG
*	a6 = control word
*	a7 = number of lines to Q
*	a8 = M_FLIPH<<16
*	a9 = ZPOS of last min (for YMINTBL)
*	a10 = ROAD2ADDR (base SAG for road)
*	a11 = DMA Q ptr
*	a12 = bits to shift per line of road for SAG adjust
*	a13 = where to store Y mins (YMINTBL ptr)
*	a14 = bits to shift to get from ZPOS to scale
*
DO_ROAD:

*	Set up A regs

	move	@ZBASE,a0,L     ; first line of image
	movi	[100h,0h],A1 	   ; upper 16 is Y scale factor
	move	@ROADWID,a3
	addi	10000h,a3	   ; Y:X Unscaled Size
	movi	[0feh,1],a4	; last min Y : hill flag
	MOVI	[08002H,0],a6  ; CONTROL WORD 				
	movi	M_FLIPH<<16,a8
	move	@ROAD2ADDR,a10,L   ; SAG of large road piece in A10
	MOVI	DMAIQBOT2,A11
	CMPI	DMAIQBOT,B12
	JRLS	TRYAGAIN
	MOVI	DMAIQBOT,A11	; Q in A11
TRYAGAIN:			
	movi    LOGROADPITCH-8,a12 ; bits to shift per line of road for SAG adjust
	movi	YMINTBL+SIZYMINTBL,a13  ; where to store Y MINS
	movk	32-Z2SCALE,a14     ; bits to shift to get from Zpos to scale

*	Set up B regs

	clr	b0		; Z index
	movk	16,b4		; delta for index
	move	@XBASE+16,b6	; skew factor
	sll	17,b6		; 16 + 1 for rounding
	MOVE	@PAGEADDR,b8,L


	.if	PUNKROCKER

	SRL	16,B8

	.else

	srl	12,b8     	; convert to line number

	.endif

	xori	SCRHGHT,b8
	sll	16,b8
	move	@(YBASE+16),b9
	sll	18,b9
	addi	ROAD_WORLD_Y<<2,b9	; shift by 2 for rounding
	movi	ZMAX,b10

	move	@ROADFLG,b1	; ForkFlg becomes hi bit of b14
	btst	RD_B_INFORK,b1
	jrnz	DO_ROAD_FORK
	btst	RD_B_INGRSH,b1
	jrnz	DO_ROAD_CHWID

	move	@ROADX,b7,L
	movi	CIRC_MASK,b14
	move	@ROADY,b3,L
	.align
DO_ROAD_LOOP:
* New point in b0 (indx)
*
*	Compute scrn Y of new point
*
	move	b0,b5

	move	b5,b2
	sll	Z2INDX-4,b2
	add	b10,b2		; convert index to ZPOS
	cmpi	ZMIN,b2
	jrgt	DO_ROAD_END
	add	b3,b5		; add ROAD OFFSET
	and	b14,b5		; handle circularness
	move	*b5,b5		; Y Offset for this Z
	sll	18,b5		; *4 to get rounding bits
	add	b9,b5  		; add base WORLD_Y 
	divs	b2,b5
	addi	(HALFY<<2)+2,b5	; round
	sll	14,b5		; rounded unscaled in b5 upper
*
*	See if diff bet scrn Y's is less than 1.
*
	move	b5,a7		; move new scrn Y to A file

	subxy	a4,a7		; is new scrnY less than prev min?
	jryle	newmin		; if yes, replace min
*
*	new SCRN Y greater than previous min
*
	cmpxy	a6,a4
	jrxne	incdelta2	; keep waiting for hill
	mmtm	a13,a4,a9	; save scrn Y and Z in table
	inc	a4		; set hill flag.
incdelta2:
	addi	64,b4		; increase index delta	
incdelta:
	addk	20,b4		; increase index delta	
	jruc	keepmin
newmin:
	jryz	incdelta	; need to increase delta
	sra	16,a7
	neg	a7
	subk	3,a7
	jrle	dif1lin		; if difference 1 or 2 lines, do it
	srl	1,b4		; otherwise, adjust index delta
	jrz	cant_nomo	;  if you can
	sub	b4,b0		;  then go back and try again
	jruc	DO_ROAD_LOOP

cant_nomo:
	movk	16,b4
dif1lin:
	addk	3,a7		; a7 = num lines to draw
	move	b0,b1		; get index in b1
*
*	b5 = scrn Y
*	b1 = index
*	b2 = ZPOS
*
Qline:
	add	b7,b1
	and	b14,b1 		; handle circularness
	move	*b1,b1		; WORLD X OFFSET FOR THIS Z
	sll	17,b1		; *2 to get rounding bit
	move	b1,a5		; save orig b1 in case of fork

	add	b6,b1
	divs	b2,b1
	addi	(HALFX<<1)+1,b1 ; DAG X * 2 with rounding
	srl	1,b1		; back to normal scale
	movx	b1,b5		; save first DAG X

;	btst	31,b14		; test FORKFLG
;	jrz	nofork
;
;	move	a5,b1
;	neg	b1		; to get other DAG X if forked
;	add	b6,b1		; add base ROAD XPOS
;	divs	b2,b1	    	; WORLD X / ZPOS
;	addi	(HALFX<<1)+1,b1 ; DAG X * 2 with rounding
;	srl	1,b1		; back to normal scale
;nofork:
;	subxy	b5,b1		; delta between x's in b1
;	move	b1,a9
;	neg	a9
;	zext	a9		; 0:delta X in a9	
	
	move	b2,a5		; for XOFF computation
	srl	a14,a5		; X scale factor for this line in A1
	cmpi	400h,a5
	jrle	notqln
	srl	2,a3
	addi	0c000h,a3	; don't erase y size
	move	@ROADADDR,a10,L	; SAG of small road piece in A10
	subk	2,a14  		; shift scale by 2 more from now on
	subk	2,a12		; change pitch of road image
	srl	2,a5		; adjust scale just computed
notqln:
	movx	a5,a1		; y scale is 100

	move	b2,a5		; restore ZPOS for SAG computation
	add	a0,a5		; add to start ZPOS for this image
	andi	0ff00h,a5 		; line number within 256 line block	
	sll	a12,a5 		; offset to SAG
	add	a10,a5		; SAG in a5 

	addxy	b8,b5		; final DAG Y in b5
	move	b5,a4		; DAG Y in a4 upper
	subxy	b8,b5		; restore scrn Y in b5

	clr	a9		; prevent offscreen skewing
	cmpxy	a9,a4
	jrxlt	unfonly
	movi	400,a9
	cmpxy	a4,a9
	jrxlt	flponly
		
*
*	A1 = SCALE
*	A2 = CONST:PAL	  (const)
*	A3 = VSIZE:HSIZE  (const)
*	A4 = DAG Y:X
*	A5 = SAG
*	A6 = CTRL:OFSET	  (const)
*			  	Q THIS DMA REQUEST
linloop:
	MMTM	A11,A1,A2,A3,A4,A5,A6		;STORE THE DMA REGS
	xor	a8,a6
	MMTM	A11,A1,A2,A3,A4,A5,A6		;STORE THE DMA REGS
	xor	a8,a6
	addi	10000h,a4		; next line
	dsjs	a7,linloop
	jruc	linhook

flponly:
	or	a8,a6
unfonly:
	MMTM	A11,A1,A2,A3,A4,A5,A6		;STORE THE DMA REGS
	addi	10000h,a4		; next line
	dsjs	a7,unfonly

linhook:
	move	b5,a4		; set up for next hill
	movx	a6,a4		; clear hill flag
	move	b2,a9		; save Z pos
keepmin:
	add	b4,b0
	jruc	DO_ROAD_LOOP	


DO_ROAD_END:
	srl	16,a4			; save new horizon (must be even)
	andi	01feh,a4		; must be even
	move	a4,@HORIZON
	MOVE	A11,@DMAIQACT,L
	move	a13,@YMINPTR,L
	rets


*********************************************************************
*
*	ENTRY:  nothing
*
*	COMPUTED:
*       b0 = index
*	b1 = scratch
* 	b2   becomes Z
*		b3 = ROADWID delta (per index)
*       b4 =  index delta
*	b5   becomes Scrn Y
*       b6 = XBASE
*		b7 = index of last line written
*	b8 = PAGE offset to DAG
*	b9  = Base of WORLD Y
*	b10 = ZMAX
*		b14 = current roadwid (3 bit fraction)
*
*
*	a0 = ZBASE (to get start of road image)
*	a1 = scale
*	a2 = const:pal
*	a3 = Y:X size
*	a4 = DAG when ready to DMA, otherwise last SCRN Y MIN:next hill indx
*	a5 = SAG
*	a6 = control word
*	a7 = number of lines to Q
*	a8 = M_FLIPH<<16
*		a9 = destination ROADWID 
*	a10 = ROAD2ADDR (base SAG for road)
*	a11 = DMA Q ptr
*	a12 = bits to shift per line of road for SAG adjust
*	a13 = used for off screen check
*	a14 = bits to shift to get from ZPOS to scale
*
DO_ROAD_CHWID:
	move	@ROADWIDDELTA,b3
	move	@ROADCHGST,a9,L		; where grow/shrink starts in Z
	sub	a0,a9			; Z diff in a9
	sra	Z2INDX-4,a9		; index at which it starts in a9
	jrnn	not_started
	clr	a9
not_started:
	move	a9,b7			; use start index as prev index

	move	@DESTROADWID,a9
	move	a3,b14
	zext	b14
	sll	3,b14			; ROADWID with 3 bit fraction in b14

	.align
DO_ROAD_LOOP_CHW:
* New point in b0 (indx)
*
*	Compute scrn Y of new point
*
;	move	b0,b5

	move	b0,b2
	sll	Z2INDX-4,b2
	add	b10,b2		; convert index to ZPOS
	cmpi	ZMIN,b2
	jrgt	DO_ROAD_END_CHW
;	add	b3,b5		; add ROAD OFFSET
;	and	b14,b5		; handle circularness
;	move	*b5,b5		; Y Offset for this Z
;	sll	18,b5		; *4 to get rounding bits
;	add	b9,b5  		; add base WORLD_Y 
	move	b9,b5  		; base WORLD_Y 
	divs	b2,b5
	addi	(HALFY<<2)+2,b5	; round
	sll	14,b5		; rounded unscaled in b5 upper
*
*	See if diff bet scrn Y's is less than 1.
*
	move	b5,a7		; move new scrn Y to A file

	subxy	a4,a7		; is new scrnY less than prev min?
	jryle	newminCHW		; if yes, replace min
*
*	new SCRN Y greater than previous min
*
	addk	32,b4		; increase index delta	
incdeltaCHW:
	addk	20,b4		; increase index delta	
	jruc	keepminCHW
newminCHW:
	jryz	incdeltaCHW	; need to increase delta
	sra	16,a7
	neg	a7
	subk	3,a7
	jrle	dif1linCHW		; if difference 1 or 2 lines, do it
	srl	1,b4		; otherwise, adjust index delta
	jrz	cant_nomoCHW	;  if you can
	sub	b4,b0		;  then go back and try again
	jruc	DO_ROAD_LOOP_CHW

cant_nomoCHW:
	movk	16,b4
dif1linCHW:
	addk	3,a7		; a7 = num lines to draw
	move	b0,b1		; get index in b1
*
*	Compute new roadwid
*
	move	b3,b3
	jrz	nochgrw
	sub	b7,b1		; difference from last index		
	jrle	nochgrw		; skip if new is <= previous
	sra	4,b1		; compensate for index scaling
	jrz	nochgrw
	move	b3,b3
	jrn	shrnkrd
*			road is growing
	add	b1,b14		; scaled roadwid
	move	b14,a4
	srl	3,a4		; lose 3 bit fraction on new
	cmp	a9,a4
	jrlt	rwnotdone
rwdone:

	move	a9,a4
	clr	b3		; delta becomes 0
	jruc	rwnotdone
*			 road is shrinking
shrnkrd:
	neg	b1
	add	b1,b14		; scaled roadwid
	move	b14,a4
	srl	3,a4		; lose 3 bit fraction on new
	cmp	a9,a4
	jrle	rwdone
rwnotdone:	
	addk	Z2SCALE,a14
	srl	a14,a4		; adjust for big or small road
	subxy	a3,a4
	jrxeq	noSAGadj
	zext	a4
	addxy	a4,a3
	sext	a4
	sll	3,a4		; turn into pixels
	sub	a4,a10		; adjust SAG accordingly
noSAGadj:
	subk	Z2SCALE,a14
	move	b0,b7
*
*	b5 = scrn Y
*	b1 = index
*	b2 = ZPOS
*
nochgrw:
	move	b6,b1
	divs	b2,b1
	addi	(HALFX<<1)+1,b1 ; DAG X * 2 with rounding
	srl	1,b1		; back to normal scale
	movx	b1,b5		; save first DAG X

	move	b2,a5		; for XOFF computation
	srl	a14,a5		; X scale factor for this line in A1
	cmpi	400h,a5
	jrle	notqlnCHW
	srl	2,a3
	addi	0c000h,a3	; don't erase y size
	move	@ROAD2ADDR,a4,L
	sub	a10,a4		; diff from orig SAG
	sra	5,a4
	sll	3,a4		; diff in pixels
	move	@ROADADDR,a10,L	; SAG of small road piece in A10
	sub	a4,a10
	subk	2,a14  		; shift scale by 2 more from now on
	subk	2,a12		; change pitch of road image
	srl	2,a5		; adjust scale just computed
notqlnCHW:
	movx	a5,a1		; y scale is 100

	move	b2,a5		; restore ZPOS for SAG computation
	add	a0,a5		; add to start ZPOS for this image
	andi	0ff00h,a5 	; line number within 256 line block	
	sll	a12,a5 		; offset to SAG
	add	a10,a5		; SAG in a5 

	addxy	b8,b5		; final DAG Y in b5
	move	b5,a4		; DAG Y in a4 upper
	subxy	b8,b5		; restore scrn Y in b5

	cmpxy	a8,a4 		; lower half of a8 is 0
	jrxlt	unfonlyCHW
	movi	400,a13
	cmpxy	a4,a13
	jrxlt	flponlyCHW

*
*	A1 = SCALE
*	A2 = CONST:PAL	  (const)
*	A3 = VSIZE:HSIZE  (const)
*	A4 = DAG Y:X
*	A5 = SAG
*	A6 = CTRL:OFSET	  (const)
*			  	Q THIS DMA REQUEST

linloopCHW:
	MMTM	A11,A1,A2,A3,A4,A5,A6		;STORE THE DMA REGS
	xor	a8,a6
	MMTM	A11,A1,A2,A3,A4,A5,A6		;STORE THE DMA REGS
	xor	a8,a6
	addi	10000h,a4		; next line
	dsjs	a7,linloopCHW

	jruc	linhookCHW

flponlyCHW:
	or	a8,a6
unfonlyCHW:
	MMTM	A11,A1,A2,A3,A4,A5,A6		;STORE THE DMA REGS
	addi	10000h,a4		; next line
	dsjs	a7,unfonlyCHW

linhookCHW:
	move	b5,a4		; set up for next hill

keepminCHW:
	add	b4,b0
	jruc	DO_ROAD_LOOP_CHW


DO_ROAD_END_CHW:
	zext	a3	   		; Unscaled Hsize of smallest line
	sll	WRLD2SCRN+2,a3 		; convert to world X
	move	a3,@ROAD_EDGE,L		; replace ROAD EDGE at distance
DO_ROAD_END_FRK:
	movi	YMINTBL+SIZYMINTBL,a13  ; where to store Y MINS
	jruc	DO_ROAD_END



*********************************************************************
*
*	ENTRY:  nothing
*
*	COMPUTED:
*       b0 = index
*	b1 = scratch
* 	b2   becomes Z
* 	b3 = ptr to ROADY
*       b4 =  index delta
*	b5   becomes Scrn Y
*       b6 = XBASE
* 	b7 = ptr to ROADX
*	b8 = PAGE offset to DAG
*	b9  = Base of WORLD Y
*	b10 = ZMAX
*	b14 = CIRC_MASK
*      
*
*	a0 = ZBASE (to get start of road image)
*	a1 = scale
*	a2 = const:pal
*	a3 = Y:X size
*	a4 = DAG when ready to DMA, otherwise last SCRN Y MIN:next hill indx
*	a5 = SAG
*	a6 = control word
*	a7 = number of lines to Q
*	a8 = M_FLIPH<<16
*      	 	a9 = delta from left fork to right fork
*	a10 = ROAD2ADDR (base SAG for road)
*	a11 = DMA Q ptr
*	a12 = bits to shift per line of road for SAG adjust
*	a13 = used for offscreen check
*	a14 = bits to shift to get from ZPOS to scale
*
DO_ROAD_FORK:
	move	@ROADY,b3,L	; to determine which sides are curving
	move	@ROADX,b7,L
	movi	CIRC_MASK,b14  
	.align
DO_ROAD_LOOP_FRK:
* New point in b0 (indx)
*
*	Compute scrn Y of new point
*
	move	b0,b2
	sll	Z2INDX-4,b2
	add	b10,b2		; convert index to ZPOS
	cmpi	ZMIN,b2
	jrgt	DO_ROAD_END_FRK
	move	b9,b5  		; base WORLD_Y 
	divs	b2,b5
	addi	(HALFY<<2)+2,b5	; round
	sll	14,b5		; rounded unscaled in b5 upper
*
*	See if diff bet scrn Y's is less than 1.
*
	move	b5,a7		; move new scrn Y to A file

	subxy	a4,a7		; is new scrnY less than prev min?
	jryle	newminFRK	; if yes, replace min
*
*	new SCRN Y greater than previous min
*
	addk	32,b4		; increase index delta	
incdeltaFRK:
	addk	20,b4		; increase index delta	
	jruc	keepminFRK
newminFRK:
	jryz	incdeltaFRK	; need to increase delta
	sra	16,a7
	neg	a7
	subk	3,a7
	jrle	dif1linFRK		; if difference 1 or 2 lines, do it
	srl	1,b4		; otherwise, adjust index delta
	jrz	cant_nomoFRK	;  if you can
	sub	b4,b0		;  then go back and try again
	jruc	DO_ROAD_LOOP_FRK

cant_nomoFRK:
	movk	16,b4
dif1linFRK:
	addk	3,a7		; a7 = num lines to draw
	move	b0,b1		; get index in b1
*
*	b5 = scrn Y
*	b1 = index
*	b2 = ZPOS
*

	add	b7,b1
	and	b14,b1	 	; handle circularness
	move	*b1,b1		; WORLD X OFFSET FOR THIS Z... LEFT SIDE
	sll	17,b1		; *2 to get rounding bit
	add	b6,b1
	divs	b2,b1
	addi	(HALFX<<1)+1,b1 ; DAG X * 2 with rounding
	srl	1,b1		; back to normal scale
	movx	b1,b5		; save first DAG X

	move	b0,b1
	add	b3,b1
	and	b14,b1	 	; handle circularness
	move	*b1,b1		; WORLD X OFFSET FOR THIS Z... RIGHT SIDE
	sll	17,b1		; *2 to get rounding bit
	add	b6,b1		; add base ROAD XPOS
	divs	b2,b1	    	; WORLD X / ZPOS
	addi	(HALFX<<1)+1,b1 ; DAG X * 2 with rounding
	srl	1,b1		; back to normal scale

	subxy	b5,b1		; delta between x's in b1
	move	b1,a9
	neg	a9
	zext	a9		; 0:delta X in a9	
	
	move	b2,a5		; for XOFF computation
	srl	a14,a5		; X scale factor for this line in A1
	cmpi	400h,a5
	jrle	notqlnFRK
	srl	2,a3
	addi	0c000h,a3	; don't erase y size
	move	@ROADADDR,a10,L	; SAG of small road piece in A10
	subk	2,a14  		; shift scale by 2 more from now on
	subk	2,a12		; change pitch of road image
	srl	2,a5		; adjust scale just computed
notqlnFRK:
	movx	a5,a1		; y scale is 100

	move	b2,a5		; restore ZPOS for SAG computation
	add	a0,a5		; add to start ZPOS for this image
	andi	0ff00h,a5 		; line number within 256 line block	
	sll	a12,a5 		; offset to SAG
	add	a10,a5		; SAG in a5 

	addxy	b8,b5		; final DAG Y in b5
	move	b5,a4		; DAG Y in a4 upper
	subxy	b8,b5		; restore scrn Y in b5

	movi	400,a13		; for offscreen check
	cmpxy	a4,a13
	jrxle	nolftleg
	subxy	a9,a4
	jrxn	nortleg
	addxy	a9,a4
*
*	A1 = SCALE
*	A2 = CONST:PAL	  (const)
*	A3 = VSIZE:HSIZE  (const)
*	A4 = DAG Y:X
*	A5 = SAG
*	A6 = CTRL:OFSET	  (const)
*			  	Q THIS DMA REQUEST
linloopFRK:
	MMTM	A11,A1,A2,A3,A4,A5,A6		;STORE THE DMA REGS
	xor	a8,a6
	zext	a9			; put 0 into a9 upper
	subxy	a9,a4			; 0:xdelta in a9
	MMTM	A11,A1,A2,A3,A4,A5,A6	; STORE THE DMA REGS
	xor	a8,a6
	movy	a3,a9			; put 1 into a9 upper
	addxy	a9,a4			; 1:xdelta in a9
	dsjs	a7,linloopFRK
	jruc	linhookFRK

nortleg:
	addxy	a9,a4			; compensate for prev subxy
	jruc	noleghook
nolftleg:
	or	a8,a6
	subxy	a9,a4
noleghook:
	MMTM	A11,A1,A2,A3,A4,A5,A6		;STORE THE DMA REGS
	addi	10000h,a4		; next line
	dsjs	a7,noleghook
	andn	a8,a6	    		; clear in case it was set

linhookFRK:
	move	b5,a4		; set up for next hill
	movx	a6,a4		; clear hill flag
keepminFRK:
	add	b4,b0
	jruc	DO_ROAD_LOOP_FRK	

	.endif


road16PAL:
   .word   240
   .word   00000h,056b5h,0294ah,02927h,02e07h,05ef7h,05605h,052efh
   .word   018c6h,05294h,03a6ah,042aah,03a69h,04631h,01d81h,029a5h
   .word   0424ah,02e06h,03a68h,0428ah,04289h,03966h,02182h,031c6h
   .word   031c5h,0318ch,01ce6h,02e04h,02d27h,03a67h,02de5h,0254ah
   .word   029a3h,03a66h,020e8h,01da3h,0426bh,018c5h,02549h,03607h
   .word   03124h,0426ah,02a04h,01084h,031c4h,03666h,02de4h,04269h
   .word   04a73h,018a6h,01cc7h,03606h,03605h,03a48h,03604h,035e7h
   .word   02507h,02d65h,029a4h,029a0h,02905h,02163h,02162h,02505h
   .word   01d42h,031a6h,029a2h,0252ah,021e4h,03e8bh,01d62h,021c2h
   .word   03e89h,035e6h,03a49h,01962h,03a47h,02528h,03e88h,02984h
   .word   02128h,021a3h,01121h,052edh,04aebh,03e6ah,03a46h,03e66h
   .word   03c84h,03626h,01942h,01da0h,01960h,05ad6h,02d24h,04ecch
   .word   01921h,03e69h,03a29h,03a28h,02529h,02906h,03585h,02a24h
   .word   03a26h,021a2h,02dc7h,01d41h,03e68h,03a07h,03e67h,03e4ah
   .word   03566h,02dc6h,03565h,04aach,03546h,025c5h,046abh,02a06h
   .word   0468ch,04689h,02109h,025c4h,03544h,02a03h,03226h,03e49h
   .word   029e5h,041a5h,02dc5h,029e2h,03e29h,03d86h,02dc3h,02108h
   .word   03a27h,03224h,03a08h,03a06h,039efh,02107h,025a4h,02da5h
   .word   025a3h,02508h,03647h,03628h,03207h,03205h,02943h,03545h
   .word   03246h,018e6h,020e7h,03206h,03986h,02583h,014c6h,03165h
   .word   02e05h,02e03h,03985h,02dc4h,01d07h,02da4h,02d25h,03e48h
   .word   029e3h,02582h,029c5h,031e7h,02983h,031e6h,03965h,02964h
   .word   02da3h,02949h,03145h,0292ah,02d45h,029c6h,02907h,025e4h
   .word   03144h,025c3h,025a5h,025a2h,02584h,02509h,03125h,03648h
   .word   02e25h,021a4h,02185h,02183h,02929h,02129h,029c4h,029c3h
   .word   03646h,01d82h,01d63h,018e7h,01d08h,01ce7h,01cc6h,01ce8h
   .word   03627h,03e28h,01520h,03625h,014a5h,01100h,03defh,055e5h
   .word   052eeh,01da2h,05205h,051e5h,01140h,04ecdh,029a6h,04e73h
   .word   04dc5h,018c7h,04aabh,04aaah,04a8ch,03d87h,049c5h,03d85h
   .word   02184h,046ach,046aah,03624h,0468bh,0468ah,03608h,045a5h


*
*	This routine takes a Z value (relative to ZBASE) as input and returns the
*	curve offset of the road at that Z position
*
*	Entry:	a2 = Z value (ZMAX already subtracted)
*	Exit	a4 contains offset
*
GET_CURV_OFF:
	SRA	Z2INDX,A2    	; convert Z to index
	SLL	4,A2		; table is words
	MOVE	@ROADX,A4,L
	move	@ROADFLG,a14
	btst	RD_B_INFORK,a14
	jrz	nofrk
	move	@XBASE+16,a14
	jrn	nofrk
	move	@ROADY,a4,L
nofrk:
	ADD	A4,A2		; add ROADOFFX
	ANDI	CIRC_MASK,A2
	MOVE	*A2,A4,W	; value is sign-extended
	rets


**************************************************************************
*								         *
* ROAD_SURFACE_PROC							 *
*								         *
* THE FOLLOWING PROCESS CHANGES THE DRIVING CONDITION OF THE ROAD.	 *
* THIS MAY NOT WORK PROPERLY.						 *
*								         *
**************************************************************************

ROAD_SURFACE_PROC
;	MOVI	nuroad,A0
	CALLA	GETFPAL
	MOVE	A0,@ROADPAL,W

	MOVI	ROAD_CONDITION_TABLE,A10
RS_LUPE
	MOVE	*A10+,A0,W
;	MOVE	A0,@SKID_FACTOR,W
	MOVE	@ROADPAL,A0,W
	CALLA	FREEPAL
	MOVE	*A10+,A0,L
	CALLA	GETFPAL
	MOVE	A0,@ROADPAL,W
	MOVE	*A10+,A0,W
;	MOVE	A0,@IRQSKYE,W
	MOVE	*A10+,A0,W
	MOVE	A0,@IRQGNDE,W
	MOVE	*A10+,A0,W
	JRZ	BYE_BYE
	SLEEPR	A0
	JRUC	RS_LUPE
BYE_BYE
	DIE

CINC	EQU	3

ROAD_CONDITION_TABLE
	.WORD	12
;	.LONG	nuroad
	.WORD	( 8+CINC*0)+( 0+CINC*0)*32+( 0+CINC*0)*32*32
	.WORD	( 0+CINC*0)+( 6+CINC*0)*32+( 0+CINC*0)*32*32
	.WORD	1000
	.WORD	11
	.LONG	ice1
	.WORD	( 8+CINC*1)+( 0+CINC*1)*32+( 0+CINC*1)*32*32
	.WORD	( 0+CINC*1)+( 6+CINC*1)*32+( 0+CINC*1)*32*32
	.WORD	100
	.WORD	10
	.LONG	ice2
	.WORD	( 8+CINC*2)+( 0+CINC*2)*32+( 0+CINC*2)*32*32
	.WORD	( 0+CINC*2)+( 6+CINC*2)*32+( 0+CINC*2)*32*32
	.WORD	200
	.WORD	9
	.LONG	ice3
	.WORD	( 8+CINC*3)+( 0+CINC*3)*32+( 0+CINC*3)*32*32
	.WORD	( 0+CINC*3)+( 6+CINC*3)*32+( 0+CINC*3)*32*32
	.WORD	300
	.WORD	8
	.LONG	ice4
	.WORD	( 8+CINC*4)+( 0+CINC*4)*32+( 0+CINC*4)*32*32
	.WORD	( 0+CINC*4)+( 6+CINC*4)*32+( 0+CINC*4)*32*32
	.WORD	400
	.WORD	8
	.LONG	ice5
	.WORD	( 8+CINC*5)+( 0+CINC*5)*32+( 0+CINC*5)*32*32
	.WORD	( 0+CINC*5)+( 6+CINC*5)*32+( 0+CINC*5)*32*32
	.WORD	1000
	.WORD	8
	.LONG	ice4
	.WORD	( 8+CINC*4)+( 0+CINC*4)*32+( 0+CINC*4)*32*32
	.WORD	( 0+CINC*4)+( 6+CINC*4)*32+( 0+CINC*4)*32*32
	.WORD	400
	.WORD	9
	.LONG	ice3
	.WORD	( 8+CINC*3)+( 0+CINC*3)*32+( 0+CINC*3)*32*32
	.WORD	( 0+CINC*3)+( 6+CINC*3)*32+( 0+CINC*3)*32*32
	.WORD	300
	.WORD	10
	.LONG	ice2
	.WORD	( 8+CINC*2)+( 0+CINC*2)*32+( 0+CINC*2)*32*32
	.WORD	( 0+CINC*2)+( 6+CINC*2)*32+( 0+CINC*2)*32*32
	.WORD	200
	.WORD	11
	.LONG	ice1
	.WORD	( 8+CINC*1)+( 0+CINC*1)*32+( 0+CINC*1)*32*32
	.WORD	( 0+CINC*1)+( 6+CINC*1)*32+( 0+CINC*1)*32*32
	.WORD	100
	.WORD	12
;	.LONG	nuroad
	.WORD	( 8+CINC*0)+( 0+CINC*0)*32+( 0+CINC*0)*32*32
	.WORD	( 0+CINC*0)+( 6+CINC*0)*32+( 0+CINC*0)*32*32
	.WORD	0

**************************************************************************
*								         *
* ICE PALETTES								 *
*								         *
**************************************************************************

ice1:
   .word   114
   .word   00000h,06318h,035adh,07bdeh,07fffh,06739h,06266h,02149h
   .word   0212ah,045e8h,02129h,02108h,03d89h,031ach,0250ah,01ce7h
   .word   0294bh,02548h,035aeh,0358ah,0316ch,077bdh,06b5ah,02d8bh
   .word   02929h,062f7h,04e53h,04a07h,041c9h,039a9h,0358dh,02d2ah
   .word   0296ah,06f7bh,06738h,06246h,05ef7h,05e46h,05ad6h,056b5h
   .word   05646h,05626h,04e07h,04a52h,049e7h,04210h,041c8h,03da9h
   .word   03da8h,039ceh,039adh,03989h,035ach,0358ch,03589h,0356ah
   .word   031adh,0318dh,0318ch,0318bh,0316bh,03169h,02d8ch,02d6ch
   .word   02d6bh,02d6ah,02d4bh,02d4ah,0296bh,0294ah,02949h,0292ah
   .word   0254bh,0254ah,02549h,0252ah,02529h,02528h,02509h,0737bh
   .word   052b5h,05226h,02d69h,05a46h,04652h,0214ah,05293h,0314ah
   .word   0739ch,05207h,04e94h,04a73h,04631h,041a8h,03569h,05e66h
   .word   05a26h,05294h,04e73h,04e52h,04630h,045e7h,045c8h,041a9h
   .word   03dc9h,039a8h,035cdh,0316ah,02d8ah,02d49h,02909h,05ef6h
   .word   04230h,03dc8h
ice2:
   .word   114
   .word   00000h,06f7bh,04210h,07fffh,07fffh,0739ch,06ec9h,02dach
   .word   02d8dh,0524bh,02d8ch,02d6bh,049ech,03e0fh,0316dh,0294ah
   .word   035aeh,031abh,04211h,041edh,03dcfh,07fffh,077bdh,039eeh
   .word   0358ch,06f5ah,05ab6h,0566ah,04e2ch,0460ch,041f0h,0398dh
   .word   035cdh,07bdeh,0739bh,06ea9h,06b5ah,06aa9h,06739h,06318h
   .word   062a9h,06289h,05a6ah,056b5h,0564ah,04e73h,04e2bh,04a0ch
   .word   04a0bh,04631h,04610h,045ech,0420fh,041efh,041ech,041cdh
   .word   03e10h,03df0h,03defh,03deeh,03dceh,03dcch,039efh,039cfh
   .word   039ceh,039cdh,039aeh,039adh,035ceh,035adh,035ach,0358dh
   .word   031aeh,031adh,031ach,0318dh,0318ch,0318bh,0316ch,07fdeh
   .word   05f18h,05e89h,039cch,066a9h,052b5h,02dadh,05ef6h,03dadh
   .word   07fffh,05e6ah,05af7h,056d6h,05294h,04e0bh,041cch,06ac9h
   .word   06689h,05ef7h,05ad6h,05ab5h,05293h,0524ah,0522bh,04e0ch
   .word   04a2ch,0460bh,04230h,03dcdh,039edh,039ach,0356ch,06b59h
   .word   04e93h,04a2bh
ice3:
   .word   114
   .word   00000h,07bdeh,04e73h,07fffh,07fffh,07fffh,07b2ch,03a0fh
   .word   039f0h,05eaeh,039efh,039ceh,0564fh,04a72h,03dd0h,035adh
   .word   04211h,03e0eh,04e74h,04e50h,04a32h,07fffh,07fffh,04651h
   .word   041efh,07bbdh,06719h,062cdh,05a8fh,0526fh,04e53h,045f0h
   .word   04230h,07fffh,07ffeh,07b0ch,077bdh,0770ch,0739ch,06f7bh
   .word   06f0ch,06eech,066cdh,06318h,062adh,05ad6h,05a8eh,0566fh
   .word   0566eh,05294h,05273h,0524fh,04e72h,04e52h,04e4fh,04e30h
   .word   04a73h,04a53h,04a52h,04a51h,04a31h,04a2fh,04652h,04632h
   .word   04631h,04630h,04611h,04610h,04231h,04210h,0420fh,041f0h
   .word   03e11h,03e10h,03e0fh,03df0h,03defh,03deeh,03dcfh,07fffh
   .word   06b7bh,06aech,0462fh,0730ch,05f18h,03a10h,06b59h,04a10h
   .word   07fffh,06acdh,0675ah,06339h,05ef7h,05a6eh,04e2fh,0772ch
   .word   072ech,06b5ah,06739h,06718h,05ef6h,05eadh,05e8eh,05a6fh
   .word   0568fh,0526eh,04e93h,04a30h,04650h,0460fh,041cfh,077bch
   .word   05af6h,0568eh
ice4:
   .word   114
   .word   00000h,07fffh,05ad6h,07fffh,07fffh,07fffh,07f8fh,04672h
   .word   04653h,06b11h,04652h,04631h,062b2h,056d5h,04a33h,04210h
   .word   04e74h,04a71h,05ad7h,05ab3h,05695h,07fffh,07fffh,052b4h
   .word   04e52h,07fffh,0737ch,06f30h,066f2h,05ed2h,05ab6h,05253h
   .word   04e93h,07fffh,07fffh,07f6fh,07fffh,07f6fh,07fffh,07bdeh
   .word   07b6fh,07b4fh,07330h,06f7bh,06f10h,06739h,066f1h,062d2h
   .word   062d1h,05ef7h,05ed6h,05eb2h,05ad5h,05ab5h,05ab2h,05a93h
   .word   056d6h,056b6h,056b5h,056b4h,05694h,05692h,052b5h,05295h
   .word   05294h,05293h,05274h,05273h,04e94h,04e73h,04e72h,04e53h
   .word   04a74h,04a73h,04a72h,04a53h,04a52h,04a51h,04a32h,07fffh
   .word   077deh,0774fh,05292h,07f6fh,06b7bh,04673h,077bch,05673h
   .word   07fffh,07730h,073bdh,06f9ch,06b5ah,066d1h,05a92h,07f8fh
   .word   07f4fh,077bdh,0739ch,0737bh,06b59h,06b10h,06af1h,066d2h
   .word   062f2h,05ed1h,05af6h,05693h,052b3h,05272h,04e32h,07fffh
   .word   06759h,062f1h
ice5:
   .word   114
   .word   00000h,07fffh,06739h,07fffh,07fffh,07fffh,07ff2h,052d5h
   .word   052b6h,07774h,052b5h,05294h,06f15h,06338h,05696h,04e73h
   .word   05ad7h,056d4h,0673ah,06716h,062f8h,07fffh,07fffh,05f17h
   .word   05ab5h,07fffh,07fdfh,07b93h,07355h,06b35h,06719h,05eb6h
   .word   05af6h,07fffh,07fffh,07fd2h,07fffh,07fd2h,07fffh,07fffh
   .word   07fd2h,07fb2h,07f93h,07bdeh,07b73h,0739ch,07354h,06f35h
   .word   06f34h,06b5ah,06b39h,06b15h,06738h,06718h,06715h,066f6h
   .word   06339h,06319h,06318h,06317h,062f7h,062f5h,05f18h,05ef8h
   .word   05ef7h,05ef6h,05ed7h,05ed6h,05af7h,05ad6h,05ad5h,05ab6h
   .word   056d7h,056d6h,056d5h,056b6h,056b5h,056b4h,05695h,07fffh
   .word   07fffh,07fb2h,05ef5h,07fd2h,077deh,052d6h,07fffh,062d6h
   .word   07fffh,07f93h,07fffh,07bffh,077bdh,07334h,066f5h,07ff2h
   .word   07fb2h,07fffh,07fffh,07fdeh,077bch,07773h,07754h,07335h
   .word   06f55h,06b34h,06759h,062f6h,05f16h,05ed5h,05a95h,07fffh
   .word   073bch,06f54h

	.END
