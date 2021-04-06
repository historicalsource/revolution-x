   	.MLIB	"GXMACS.LIB"
	.FILE	"GXDUTL.ASM"
	.TITLE	"<<< GENERATION X - DIAGNOSTIC UTILITY ROUTINES >>>"
	.WIDTH	132
	.OPTION	B,D,L,T
	.MNOLIST

**************************************************************************
*								         *
* 	COPYRIGHT (C) 1992 MIDWAY MANUFACTURING COMPANY.		 *
* 		       ALL RIGHTS RESERVED.				 *
*								         *
**************************************************************************

	.INCLUDE	"GX.INC"
	.INCLUDE	"GXSTRING.H"
	.INCLUDE	"IMGTBL.GLO"

	.DEF	CIRCLE, HVLINE, POINT, DSCRCLR, INITCOLR
	.DEF	DIAG_SRT_CLR	

*SYMBOLS IN SYSFONT.ASM
	.REF	SYSFONT, SYSFONT_FLIP

        .TEXT
        .EVEN

	.sect	"COLDSTRT"

 ;****************************************************************************
;* POINT: FUNCTION DISPLAYS A POINT OF ANY COLOR.                           *
;*                                                                          *
;*            ENTRY: A0 = XY SCREEN ADDRESS OF THE POINT                    *
;*                   A1 = COLOR VALUE                                       *
;*                   B6 = RETURN ADDRESS                                    *
;*                                                                          *
;*            USES:  A0, A1, B2, B3, B4, B6, B10                            *
;****************************************************************************
POINT:

	MOVE	@DIPSWITCH,B10,L	;WHICH WAY TO DISPLAY
	ANDI	DPMIRROR_RAW,B10
	JRZ	POINT_NORM		;BR = NOT THROUGH THE LOOKING GLASS

*DO THIS WHEN WE ARE VIEWING THROUGH A MIRROR
	MOVE	A0,B10
	SLL	16,B10
	SRL	16,B10
	SUBI	(SCREEN_WIDTH - 1),B10	;ADJUST COORDINATE
	NEG	B10
	JRNN	POINT_GZERO
	CLR	B10
POINT_GZERO
	MOVE	A0,DPTCH
	MOVY	DPTCH,B10
	MOVE	B10,A0			;WE NOW HAVE AN ADJUSTED DESTINATION
POINT_NORM
        MOVI	SCRN_PTCH, DPTCH
	movi	OFFSETVAL,OFFSET

; THE FOLLOWING LINE WAS A BUG
;	CLR  OFFSET

        LMO	DPTCH, B10
        MOVE	B10, @CONVDP
        PIXT	A1,*A0.XY
        FRET	B6

;****************************************************************************
;* RECTANGLE: FUNCTION DISPLAYS A RECTANGLE OF ANY COLOR.                   *
;*                                                                          *
;*            ENTRY: A0 = XY SCREEN ADDRESS OF UPPER LEFT CORNER            *
;*                   A1 = XY RECTANGLE DIMENSIONS                           *
;*                   A2 = COLOR VALUE                                       *
;*                                                                          *
;*                   B6 = RETURN ADDRESS                                    *
;*                                                                          *
;*            USES:  A0, A1, A2, B2, B3, B4, B6, B7, B9, B10                *
;****************************************************************************

RECTANGLE:
	MOVE	@DIPSWITCH,B10,L	;WHICH WAY TO DISPLAY
	ANDI	DPMIRROR_RAW,B10
	JRZ	RECTANGLE_NORM		;BR = NOT THROUGH THE LOOKING GLASS
*DO THIS WHEN WE ARE VIEWING THROUGH A MIRROR
	MOVE	A0,DADDR
	MOVX	DADDR,B10		;SLIDE TO OTHER SIDE
	MOVE	A1,DYDX
	ADDXY	DYDX,B10
	SLL	16,B10
	SRL	16,B10

; THIS WAS A BUG - FIXED WITH LINE BELOW IT
;	SUBI	(SCREEN_WIDTH - 1),B10	;ADJUST COORDINATE
	SUBI	SCREEN_WIDTH,B10	;ADJUST COORDINATE

	NEG	B10
	JRNN	RECTANGLE_GZERO
	ZEXT	B10			;CLEAR TOP
	ADDXY	B10,DYDX		;DECREASE THE OBJECT SIZE
	CLR	B10
RECTANGLE_GZERO
	MOVX	B10,DADDR		;WE NOW HAVE AN ADJUSTED DESTINATION
	JRUC	RECTANGLE_READY
*WE ARE NOT VIEWING THROUGH A MIRROR
RECTANGLE_NORM
        MOVE A0, DADDR
        MOVE A1, DYDX
RECTANGLE_READY
        MOVI SCRN_PTCH, DPTCH
        MOVI OFFSETVAL, OFFSET

        LMO  DPTCH, B10
        MOVE B10, @CONVDP

        MOVE A2, COLOR1
	rpix	COLOR1

        FILL  XY

        FRET B6

;****************************************************************************
;* LINE: FUNCTION DRAWS HORIZONTAL OR VERTICAL LINES OF ANY COLOR.          *
;*                                                                          *
;*            ENTRY: A0 = BEGINNING XY SCREEN ADDRESS                       *
;*                   A1 = ENDING XY SCREEN ADDRESS                          *
;*                   A2 = COLOR VALUE                                       *
;*                                                                          *
;*                   B6 = RETURN ADDRESS                                    *
;*                                                                          *
;*            USES:  A0, A1, A2, A3, A4, B3, B4, B6, B9, B10                *
;****************************************************************************
HVLINE:

	MOVE	@DIPSWITCH,B10,L	;WHICH WAY TO DISPLAY
	ANDI	DPMIRROR_RAW,B10
	JRZ	HVLINE_NORM		;BR = NOT THROUGH THE LOOKING GLASS

*DO THIS WHEN WE ARE VIEWING THROUGH A MIRROR
	CLR	A3
	MOVX	A0,A3

	SUBI	(SCREEN_WIDTH - 1),A3	;ADJUST PNT. A COORDINATE

	NEG	A3
	JRNN	PNTA_GZERO		;BR = XLATED ADDR IS GREATER THAN 0
	CLR	A3
PNTA_GZERO
	MOVX	A3,A0			;WE NOW HAVE AN ADJUSTED DESTINATION

	CLR	A3
	MOVX	A1,A3

	SUBI	(SCREEN_WIDTH - 1),A3	;ADJUST PNT. B COORDINATE

	NEG	A3
	JRNN	PNTB_GZERO
	CLR	A3
PNTB_GZERO
	MOVX	A3,A1			;WE NOW HAVE AN ADJUSTED DESTINATION

HVLINE_NORM
	MOVI	SCRN_PTCH,DPTCH
	movi	OFFSETVAL,OFFSET

	LMO	DPTCH,B10
	MOVE	B10,@CONVDP

	MOVE	A2,COLOR1
	rpix	COLOR1

	MOVK	1H,A2			;DRAV DX: ASSUME HORIZONTAL LINE

	MOVE	A0,A3			;DETERMINE (P2 > P1) OR (P2 < P1)
	CVXYL	A3,A3

	MOVE	A1,A4
	CVXYL	A4,A4

	CMP	A3,A4			;IF (P2 < P1) ~(INCREMENT)
	JRP	$100

	NEG	A2			;INCREMENT IS A SIGNED WORD
	ZEXT	A2,0

$100:
	CMPXY	A0,A1			;IF VERTICAL LINE
	JRZ	$110			;DRAV DX -> DRAV DY
	SLL	16,A2
        
$110:
	DRAV	A2,A0			;DRAW LINE
	CMPXY	A0,A1
	JRNN	$110
	JRNZ	$110

	FRET	B6


;	.sect	"COLDSTRT"
**************************************************************************
*								         *
* STRING: FUNCTION DISPLAYS AN ASCIZ STRING OF ANY COLOR EITHER VERTICAL *
*         OR HORIZONTALLY.						 *
* 									 *
*            ENTRY: A0 = STARTING STRING ADDRESS			 *
*                   A1 = XY SCREEN ADDRESS				 *
*                   A2 = DIRECTION					 *
*                   A3 = COLOR						 *
* 									 *
*                   B6 = RETURN ADDRESS					 *
* 									 *
*            USES: A0 - A6, B0 - B4, B6 - B14				 *
*								         *
**************************************************************************
STRING:
	MOVI	SCRN_PTCH,DPTCH
	MOVI	OFFSETVAL,OFFSET

	LMO	DPTCH,B10
	MOVE	B10,@CONVDP

	MOVE	A3,COLOR1    
	rpix	COLOR1
	CLR	COLOR0

	SETF	8,0,0

$200:
	MOVE	*A0+,A4			;GET CHARACTER
	JRZ	$230			;QUIT IFF NULL

	SUBK	32,A4			;GET POINTER TO CHARACTER HEADER
	SLL	5,A4

	MOVE	@DIPSWITCH,B10,L	;WHICH WAY TO DISPLAY
	ANDI	DPMIRROR_RAW,B10
	JRZ	STRING_NORMFONT		;BR = NOT THROUGH THE LOOKING GLASS

*DO THIS WHEN WE ARE VIEWING THROUGH A MIRROR
	ADDI	SYSFONT_FLIP,A4,L
	MOVE	*A4,A4,1
	MOVE	*A4+,A5,1		;CHAR DIMENSIONS

	MOVE	A1,DADDR
	MOVX	DADDR,B10		;SLIDE TO OTHER SIDE
	MOVE	A5,B11
	ADDXY	B11,B10
	SLL	16,B10
	SRL	16,B10

	SUBI	(SCREEN_WIDTH - 1),B10	;ADJUST COORDINATE

	NEG	B10
	JRNN	STRING_GZERO		;BR = XLATED ADDR IS GREATER THAN 0

	ZEXT	B10			;CLEAR TOP
	ADDXY	B10,B11			;DECREASE THE OBJECT SIZE
	CLR	B10
	MOVE	B11,A5			;ADJUSTED SIZE

STRING_GZERO
	MOVX	B10,DADDR		;WE NOW HAVE AN ADJUSTED DESTINATION
	JRUC	STRING_FONTSELD

STRING_NORMFONT
	ADDI	SYSFONT,A4,L
	MOVE	*A4,A4,1
	MOVE	*A4+,A5,1		;CHAR DIMENSIONS
	MOVE	A1,DADDR
STRING_FONTSELD

	MOVE	A5,DYDX

	CLR	A6			;A6 = CHAR WIDTH
	MOVX	A5,A6

	ADDK	7,A6			;ROUND UP WIDTH TO INTEGRAL NUMBER
	SRL	3,A6			;OF BYTES = SOURCE PITCH
	SLL	3,A6
	MOVE	A6,SPTCH

	MOVE	*A4,A6,1		;CHAR DATA
	MOVE	A6,SADDR
        
	PIXBLT	B,XY

	CLR	A6
	MOVE	A2,A2
	JRZ	$210

	MOVY	A5,A6			;A1 += (CHAR HEIGHT + SPACING)
	SRL	16,A6			;DIRECTION = DOWN
	ADDK	1H,A6
	SLL	16,A6
	ADD	A6,A1
	JRUC	$200
        
$210:
	MOVX	A5,A6			;A1 += (CHAR WIDTH + SPACING)
	ADDK	2H,A6			;DIRECTION = RIGHT
	ADD	A6,A1
	JRUC	$200

$230:
	SETF	16,1,0

	FRET	B6


STRINGCENTER:
	SETF 	8, 0, 0
	CLR	A1
	MOVE	A0,A2
SPLLOOP
	MOVE 	*A0+, A4 		; GET THE CHAR
        JRZ	SPLEND			; END OF STRING

        SUBK 	32, A4                     ; GET POINTER TO CHARACTER HEADER
        SLL  	5H, A4
        ADDI 	SYSFONT, A4, L
        MOVE 	*A4, A4, 1

        MOVE 	*A4+, A5, 1                ; CHAR DIMENSIONS
        MOVE  	A5, DYDX

        CLR  	A6                         ; A6 = CHAR WIDTH
        MOVX 	A5, A6

        ADDK 	7, A6                      ; ROUND UP WIDTH TO INTEGRAL NUMBER
        SRL  	3, A6                      ; OF BYTES = SOURCE PITCH
        SLL  	3, A6
        
	MOVX 	A5, A6                      ; A1 += (CHAR WIDTH + SPACING)
        ADDK 	2H, A6                      ; DIRECTION = RIGHT
        ADD  	A6, A1
        JRUC	SPLLOOP

SPLEND
	SETF 	16, 1, 0
	MOVE	A2,A0			; RESTORE STRING ADDRESS
	SRL	1,A1
	MOVI	SCREEN_WIDTH/2,A2
	SUB	A1,A2
	MOVE	A2,A1
        FRET 	B6

*SCRCLR - CLEAR ENTIRE BIT MAP
*	USES:B2,B3,B4	CALL WITH B6
DSCRCLR
	CLR	B2
	MOVI	SCREEN,B3,L
	MOVI	(SCRNE-SCREEN)/32,B4,L
SCRLP	MOVE	B2,*B3+,L
	DSJS	B4,SCRLP
	FRET	B6

;****************************************************************************
;* INITCOLR: INITIALIZE COLORS; ROUTINE LOADS PALETTE 0 WITH THE COLOR      *
;*           PALETTE USED BY DIAGNOSTIC TESTS.                              *
;****************************************************************************

INITCOLR:
;
;	KLUDGE TO LOAD SYSTEM PALETTE IN PALETTE SLOT 0
;
	MOVI	COLRAM,A0,L		; PALETTE LOCATION
	MOVI	DIAGPAL,A1,L
	MOVE	*A1+,A2,W		; LENGTH OF PALETTE
LPLP1
	MOVE	*A1+,a14,W
	move	a14,*A0+,L		; XUNIT
	DSJS	A2,LPLP1		; KEEP ON CHUGGIN, BABY

        CLR  A14
        MOVE A14, @CMAPSEL

        FRET B5

DIAGPAL
	.word	25
	.word	00H,07C00H,06739H,01FH,035ADH,077A0H,0741AH,03A0H
	.word	00H,010H,07E3H,07FFFH,07DADH,06420H,02108H,03DEFH
	.word	04210H,05AD6H,05EF7H,0C0H,0120H,0982H,0221H,0782H
	.word	047F1H

;	.text

;****************************************************************************
;* CIRCLE: FUNCTION DRAWS OUTLINE OR FILLED CIRCLES.                        *
;*                                                                          *
;*       ENTRY: A0 = radius                                                 *
;*              A1 = center  (Y:X)                                          *
;*              A6 = <00:15> = color                                        *
;*              A6 = <15:31> = fill: 0=no fill, 1=fill                      *
;*                                                                          *
;*       USES:  A0 - A8, B0, B10                                            *
;**************************************************************************** 

CIRCLE:
	movi	OFFSETVAL,OFFSET

	MOVE	@DIPSWITCH,B10,L	;WHICH WAY TO DISPLAY
	ANDI	DPMIRROR_RAW,B10
	JRZ	CIRCLE_NORM		;BR = NOT THROUGH THE LOOKING GLASS

	MOVE	A1,A7
	SLL	16,A7
	SRL	16,A7

	SUBI	(SCREEN_WIDTH - 1),A7	;ADJUST COORDINATE

	NEG	A7
	JRNN	CIRCLE_GZERO
	CLR	A7
CIRCLE_GZERO
	MOVX	A7,A1			;WE NOW HAVE AN ADJUSTED DESTINATION

CIRCLE_NORM
        movi  plot8,a7               ; assume no fill
        btst  16,a6
        jrz   CIRC0
        movi  fill4,a7
CIRC0:
        movi  SCRN_PTCH,DPTCH        ; Restore screen pitch and convdp
        MOVI  13h,B10                ; THIS IS FASTER
        MOVE  B10,@CONVDP
        MOVE  A6,COLOR1
	rpix	COLOR1
        movi  [1,0],DYDX                 ; Y width always 1

        clr   a2                      ; x = 0
        move  a0,a3                   ; y = r
        move  a0,a4
        sll   1,a4
        subk  3,a4
        neg   a4                     ; d = 3 - 2*r
cloop:
        cmp   a3,a2                  ; if x > y, we are done
        jrgt  done

        MOVE  A7, B0                 ; PLOT ROUTINE
        EXGPC B0

        move  a2,a5                  ; x -> a5
        btst  31,a4
        jrz   dpos                   ; branch if d is positive

;             d negative

        sll   2,a5                   ; 4*x -> a5
        addk  6,a5                   ; 4*x+6 -> a5
        jruc  cont

;             d positive

dpos:                

        sub   a3,a5                  ; x-y -> a5
        sll   2,a5                   ; 4*(x-y) -> a5
        addk  10,a5                  ; 4*(x-y)+10 -> a5
        subk  1,a3                   ; y = y - 1

cont:
        add   a5,a4                  ; d = d + a5
        addk  1,a2                   ; x = x + 1
        jruc  cloop

done:
	FRET B6

plot8:
        move  a3,a5
        neg   a5                   ; -y into a5; +y in a3
        sll   16,a5
        sll   16,a3
        movx  a2,a5                ; a3 = (y:x)
        movx  a2,a3                ; a5 = (-y:x)

        movk  2,a8
put4:
        move  a1,a0                ; center (Y:X) in a0
        addxy a3,a0                ; (cx+x),(cy+y)
        pixt  a6,*a0.XY
        move  a1,a0                ; center (Y:X) in a0
        addxy a5,a0                ; (cx+x),(cy-y)
        pixt  a6,*a0.XY
        move  a1,a0                ; center (Y:X) in a0
        subxy a3,a0                ; (cx-x),(cy-y)
        pixt  a6,*a0.XY
        move  a1,a0                ; center (Y:X) in a0
        subxy a5,a0                ; (cx-x),(cy+y)
        pixt  A6,*a0.XY
        rl    16,a3
        rl    16,a5                ; transpose x and y        
        dsj   a8,put4
        sra   16,a3                ; restore y

        FRET B0

fill4:
        move  a2,b10               ; x
        sll   1,b10                ; 2x
        movx  b10,DYDX             ; delta x = 2x
        move  a3,a5
        neg   a5                   ; -y into a5      +y in a3
        sll   16,a5
        sll   16,a3
        movx  a2,a5                ; a3 = (y:x)
        movx  a2,a3                ; a5 = (-y:x)
        movk  2,a8
put2:        
        move  a1,a0
        subxy a5,a0
        move  a0,DADDR
        fill  XY

        move  a1,a0
        subxy a3,a0
        move  a0,DADDR
        fill  XY
        rl    16,a3                ; a3 = (x:y)
        rl    16,a5                ; transpose x and y        
        clr   a6
        subxy a5,a6
        move  a6,a5                ; a5 = (-x:y)
        move  a3,b10               ; y
        sll   1,b10                ; 2y
        movx  b10,DYDX             ; delta x = 2y
        dsj   a8,put2
        sra   16,a3                ; restore y

        FRET B0

;****************************************************************************
;* ADV_BUTTON: FUNCTION READS THE STATE OF THE ADVANCE BUTTON.              *
;*                                                                          *
;*          ENTRY -- B6 = RETURN ADDRESS.                                   *
;*          EXIT  -- C  = SET IFF BUTTON PRESSED.                           *
;*          USES  -- B2                                                     *
;****************************************************************************

ADV_BUTTON:

;       ===========================
;       | ENTRY WITH BUTTON DOWN  |
;       ===========================

        MOVE @COINS, B2
        BTST 04, B2
        JRNZ ADVANCE_FALSE

;        PAUSE ADV_UP_TIME, B2		;ELIMINATE NOISE POSSIBILITY	

        MOVE @COINS, B2
        BTST 04, B2
        JRNZ ADVANCE_FALSE

ADVANCE_TRUE:

        SETC
        FRET B6

ADVANCE_FALSE:

        CLRC
        FRET B6

;****************************************************************************
;* ADV_BUTTON_2: FUNCTION READS THE STATE OF THE ADVANCE BUTTON. ROUTINE IS *
;*               IDENTICAL TO ADV_BUTTON EXCEPT THAT IT MAY BE CALLED ONLY  *
;*               WITHIN THE ERROR LED ROUTINE.                              *
;*                                                                          *
;*               ENTRY -- B3 = RETURN ADDRESS.                              *
;*               EXIT  -- C  = SET IFF BUTTON PRESSED.                      *
;*               USES  -- B2                                                *
;****************************************************************************

ADV_BUTTON_2

        MOVE @COINS, B2
        BTST 04, B2
        JRNZ ADVANCE_FALSE_2

;        PAUSE ADV_UP_TIME, B2		;ELIMINATE NOISE POSSIBILITY	

        MOVE @COINS, B2
        BTST 04, B2
        JRNZ ADVANCE_FALSE_2
        
ADVANCE_TRUE_2:

        SETC
        FRET B3

ADVANCE_FALSE_2:

        CLRC
        FRET B3

**************************************************************************
*                                                                        *
* ADVANCE_WAIT: FUNCTION RETURNS WHEN THE ADVANCE BUTTON HAS GONE FROM   *
*			OFF TO ON, WITH DEBOUNCE.			 *
* 	USE THIS WHEN WAITING ON THE ADVANCE BUTTON TO CONTINUE.         *
*          ENTRY -- B6 = RETURN ADDRESS.                                 *
*          EXIT  -- C  = SET IFF BUTTON PRESSED.                         *
*          USES  -- B2                                                   *
*                                                                        *
**************************************************************************
ADVANCE_WAIT:
	MOVE	@COINS,B2
	BTST	04,B2
	JRZ	ADVANCE_WAIT		;BR = SWITCH IS DOWN
;	PAUSE	ADV_UP_TIME,B2		;DEBOUNCE	
	MOVE	@COINS,B2
	BTST	04,B2
	JRZ	ADVANCE_WAIT		;BR = SPURIOUS SWITCH UP
ADVW1
	MOVE	@COINS,B2
	BTST	04,B2
	JRNZ	ADVW1			;BR = SWITCH IS UP 	
;	PAUSE	ADV_UP_TIME,B2		;DEBOUNCE	
	MOVE	@COINS,B2
	BTST	04,B2
	JRNZ	ADVW1			;BR = SWITCH IS UP 	
	FRET	B6

**************************************************************************
*								         *
* DIAG_SRT_CLR - STRIPPED DOWN SRT_CLR FOR DIAGNOSTICS ONLY!		 *
* 		 WHEN THE DMA IS NOT RUNNING AND DIRQ IS		 *
* 		 TURNED ON WITH DIAG_DFLAG SET				 *
* NOTE: TRASHES MANY A AND B FILE REGISTERS				 *
*								         *
**************************************************************************
DIAG_SRT_CLR:
	CLRM	@TIMER,W
DSC_VBLNK_WAIT
	MOVE	@TIMER,A14,W
	JRZ	DSC_VBLNK_WAIT
*	color to clear to stored in Lines 510 and 511
	movi	255,B2			;GET AUTO ERASE LINE
	MOVI	SCRTOP*1000h,B8
	MOVI	[((SCRBOT)-(SCRTOP)+1)>>1,1],B7

	sll	12,b8			;CONVERT TO LINEAR
	move	@CONVDP,A12,W
	movk	012H,B9
	move	B9,@CONVDP		;Move to CONVDP io register

* Set SRT=1.  This converts pixel accesses to VRAM SR transfer cycles.

	MOVE	@DPYCTL,B10,W		;Copy display control reg.
	move	B10,A13			; save in A file
	ANDNI	SRE+ENV,B10	     	;Turn off screen refresh
	ORI	CST,B10		     	; XUNIT Enable SR transfers
SrtDmaWt:
	move	@DMAGOREG,A0,L
	jrn	SrtDmaWt

*
*WARNING! KEEP INTERRUPTS OFF UNTIL AFTER THE FILL INSTRUCTION
*	ASYNCHRONOUS BREAKS MAY CAUSE DMA INTERRUPT TO OCCUR
*	DURING FILL INSTRUCTION TRASHING THE B REGISTERS THAT
*	DETERMINE FILL RESTART AFTER INTERRUPT.
*	WHEN DEBUGGING THIS CAUSES SPURIOUS ILLEGAL OPCODES AND TRASHING
*	OF CODE SPACE.
*
	move	a0,*-SP,1
	MOVK	1,A0
	MOVE	A0,@060000000H,1

	PUSHST
	DINT
	MOVE	B10,@DPYCTL,0 		;Load new display control

;	MOVE	@DPYCTL,B10,0 		;Read back to be safe!
	movi	SCRN_PTCH*2,B3	 	;Get Screen Pitch

* Load frame buffer for 1st line into VRAM shift registers.
	CLR	B4		     	;Origin at start of memory
	sll	13,b2 		; change line number into address
	PIXT	*B2,B2		;Load VRAM shift registers

* Transfer contents of VRAM shift registers to rest of frame buffer.
	move	@PAGEADDR,B4,L

	SRL	4,B4

	ADD	B8,B4
	clr	B2
	MMTM	SP,B11,B12,B13
	FILL	 XY				;200 SR-to-memory transfers
	MMFM	SP,B11,B12,B13
	POPST

	CLR	A0
	MOVE	A0,@060000000H,1
	move	*SP+,A0,1
*END OF INTERRUPT DISABLE 

	move	A12,@CONVDP,W
   	MOVE 	A13,@DPYCTL,W		;Copy display control reg.
	rets

	.END
