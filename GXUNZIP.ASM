 	.MLIB	"GXMACS.LIB"
	.FILE	"GXUNZIP.ASM"
	.TITLE	"<<< GENERATION X - UNZIPPER Warren B. Davis 9/3/91 >>>"
	.WIDTH	132
	.OPTION	B,D,L,T
	.MNOLIST
*
*
**************************************************************************
*								         *
* 	COPYRIGHT (C) 1992 MIDWAY MANUFACTURING COMPANY.		 *
* 		       ALL RIGHTS RESERVED.				 *
*
*	Mods made for XUNIT...   DMAPAL -> DMACMAPCON
*				 RAMBUFFER -> 20000000h			 *
*                                COLORPAL def removed (no references).
**************************************************************************

	.INCLUDE	"GX.INC"
	.INCLUDE	"GXSTRING.H"
	.INCLUDE	"IMGTBL.GLO"
	.include	gxboosh.tbl

***** In this file
	.DEF	STILL, GET_UNZIP_PAL, MOVIE_PROC  
	.DEF	SYNCIRQ,CLIPSND,VIDEO_PLAY,S_CAR_BEEPER
***** from GX.ASM
	.REF	MOVIE_KILL, DUXNOFADE, SLEEP_SWITCHX
***** from GXPALL.ASM
	.ref	PALSET
***** from GXAFUNC.ASM	   
	.ref	A_CLR_OYVEL,A_STAY_TIL_SY_LT,A_Set_LOOP_STRT 

	.ref	GUNS_OFF     

STILNOFADE:
	.long	T2FIXED, BLUPLAYR, REDPLAYR, 0

*
*	MONTENT	clipname,scrnX,scrnY,Text,Sndtable
*
MONTENT	.MACRO	P1,P2,P3,P4,P5
	.long	:P1:	    		
	.long	(:P2:*8)+(:P3:*SCRN_PTCH)
	.long	:P5:,:P4:
	.ENDM

*
*	GOOM	clipname,scrnX,scrnY
*
GOOMENT	.MACRO	P1,P2,P3,P4
	.long	:P1:	    		
	.long	(:P2:*8)+(:P3:*SCRN_PTCH)
	.long	:P4:
	.ENDM


LINE	.set	1
ART	.set	0
PREVIEW	.set	0


BPP		.set 	3
RAMBUFSIZ	.set	(4*1024)*8		; << BPP
SCRN_ST		.set	(170*SCRN_PTCH)+(150*8)
PXLS_PR_TIK	.set	10000


	.if	DEBUG
	.bss	NUM_LINES,32
	.endif

	.bss	CLIPSND,32
	.bss	MOVIE_SLEEP,32	; each bit is sleep extra tick or no
	.bss	SYNCIRQ,16	; When to issue clip sound
	.bss	HOLDFADE,16	; time to hold first frame
	.bss	FRAMENUM,16
	.BSS	UZ_DISPLAYON_TEMP,16	;Storage for real displayon value.

	.text

*
*	started from STILL
*
DELAYFADE:
	sleep	6
	movi	DUXNOFADE,a0
	dec	a11
	jrz	slfade
	calla	FADEIN
	DIE

slfade:
	calla	FADEINS
	DIE


*	a8 = ptr to frames
*	a10 = screen dest
*	a11 = controlling process  (0 if none)
MOVIE_PROC
	mmtm	a12,a11
	clr	a14
	move	a14,@FRAMENUM
	JSRP	MOVIE
*
*	Tell Montage Process to continue
*
	mmfm	a12,a11
	move	a11,a11			; is there a controlling process?
	jrz	nomontage
	clr	a14			; if yes, get clr reg a11 of that process
	move	a14,*a11(PA11),L	;	  (to tell it we are done)
	move	*a13(PTEMP1+16),*a11(PA10),L	; and put last palette slot in reg a10
nomontage:
	
	DIE


*
*	a8 = start of compressed picture data
*	a10 = screen address of picture start
*
MOVIE:
	move	@PAGE,a14
	jrnz	nopgchg
	addi	TOGGLE_PAGE_L,a10	; XUNIT start in page 1 if page 0 is currently displayed
nopgchg:
	callr	ParseHeader		; This will load colors
	callr	ALLOCPAL
	jrz	nostill			; and return... 	
					;	a6 = X size
					;	b3 = Y size
					;	a4 = # frames
					;	b4 = strtpal
	MOVIM	07fffh,*a13(PTEMP1),W
	JSRP	DECOMPRESS
	setf	32,0,1
	setf	16,1,0

	RETP


*
*	a9 = SCREEN Y : X  (If either is neg, center)
*	a10 = OFFSET TO START OF PAGE (0,100000h,PAGE2_START or PAGE3_START)
*	a8 = start of compressed picture data
*	a11 = 1 start faded do slow fade,
*	     2 start faded, do normal fade
*	     0 no fade
*
STILL:
;	MOVKM	1,@SUPRESS_PAGE_FLIP,W	; GOOD FOR DEBUGGING
;	move	a14,@SKIPDISP,W
;	move	a14,@NOAUTOE,W

	MOVE	@DISPLAYON,@UZ_DISPLAYON_TEMP,W
	CLRM	@DISPLAYON,W		;Kill all display processing
	CALLA	DMAQWAIT		;Wait on DMA to finish

	CLRM	@HOLDFADE,W
	callr	ParseHeader		; size into a6 (X) and a1 (Y)

	movy	a9,a2
	sra	16,a2
	jrnn	nocentery
	movi	SCRHGHT,a1
	sub	a1,a2
	sra	1,a2	  		
nocentery:
	add	a2,a1 
	dec	a1    			; get to start of LAST line
	sll	12,a1			; shift over to make address
	add	a1,a10
	
	sext	a9
	jrnn	nocenterx
	movi	SCRWIDTH,a9
	sub	a6,a9
	addk	5,a9
	srl	1,a9
nocenterx:
	srl	2,a9
	sll	4,a9		; get bit address (always starts on word)
	add	a9,a10		; center based on X size of picture
	
*
*	ColorPalette...  Start of Palette data in a8, Number of colors in a7
*
	callr	ALLOCPAL
	jrz	nostill		; and return... 	
					;	a6 = X size
					;	b3 = Y size
					;	a4 = # frames
					;	b4 = strtpal
	move	a11,a11
	jrz	nofade
	move	b3,a2
	move	b4,a3
	mmtm	a12,a2,a3,a4,a6
	clr	a0
	calla	FADEBLAK
	SLEEP	1
	CREATE	PID_PFADE,DELAYFADE
	mmfm	a12,a2,a3,a4,a6
	move	a2,b3
	move	a3,b4
	move	a6,b9
nofade:
	MOVIM	PXLS_PR_TIK,*a13(PTEMP1),W
	JSRP	DECOMPRESS
nostill:	
	setf	32,0,1
	setf	16,1,0
	MOVE	@UZ_DISPLAYON_TEMP,@DISPLAYON,W	;Restore display processing
	RETP

**************************************************************************
*								         *
* 	GET_UNZIP_PAL							 *
* 									 *
* 	Allocate a palette for a zipped image.  Can be used by		 *
* 	anyone to reserve palette space well before it is actually	 *
* 	needed.								 *
* 									 *
* 	A0 = Ptr to Compressed image					 *
* 									 *
* 	Returns:							 *
* 		 Z = No palette available, A0 = 0			 *
* 		NZ = Got one, A0 = DMA style palette number(i.e 0101)	 *
*								         *
**************************************************************************
GET_UNZIP_PAL
	MMTM	SP,A1,A2,A3,A4,A5,A6,A7,A8
	MMTM	SP,B3,B4,B9
	MOVE	A0,A8			;Goes here for Warren routines
	CALLR	ParseHeader		;Decipher header data
	CALLR	ALLOCPAL		;And allocate a palette
	MMFM	SP,B3,B4,B9
	MMFM	SP,A1,A2,A3,A4,A5,A6,A7,A8
	RETS

**************************************************************************
*								         *
* 	ALLOCPAL							 *
* 									 *
* 	Allocate a palette for a compressed picture.  This palette	 *
* 	will be put in the background palette area.  Background		 *
* 	palettes are not globally faded by the fade routines.		 *
* 	If you want to fade one, then use FADE_ONLY			 *
* 									 *
* 	A8 = Address of color data					 *
* 	A7 = Number of colors						 *
* 	Returns:							 *
* 		 Z = No palettes available, A0 = 0			 *
* 		NZ = Got palette, A0 = DMA ready palette number		 *
*								         *
**************************************************************************
ALLOCPAL:
*
* Check first to see if our palette is already out there
*
	MOVE	A8,A0		;Get start of color data
	SUBK	16,A0		;Back one to make things right
	CALLA	FINDPAL		;Is there one out there?
	JRZ	ALLP_GET_ONE	;BR = No, no need to allocate another
	MOVE	A0,B4		; adjust start palette
	SLL	4,A7
	ADD	A7,A8		; move source ptr past colors & clr Z
	RETS

ALLP_GET_ONE
*CHECK FOR A SPARE PALETTE
	MOVI	NMBPAL,A3
;	MOVI	PALRAM,A5	
	MOVI	BPALRAM,A5
ALLPL1:	
	MOVE	*A5(PALCNT),A2,W
	JRNE	CKNXTPAL		;PALETTE NOT EMPTY

	;CHECK TIME WHEN FREED, CAN'T REALLOCATE ON SAME TIK
	MOVE	*A5(PALTIME),A2,W
	JRZ	ALLPAL2
	MOVE	@WAVEDISPS,A14,W	;SAME DISPLAY TICK?
	CMP	A2,A14
	JRNE	ALLPAL2		;PALETTE OK TO GRAB
CKNXTPAL
	ADDI	PALRSIZ,A5
	DSJS	A3,ALLPL1

	CLR	A0		;NO PALETTES DEFAULT 0 AND 
	JRUC	uzabt		;SPLIT

*SETUP YOUR NEW PALETTE
ALLPAL2:
	move	a7,a2		; # colors into a2 for PALSET
	DECM	@FREEPALCNT,W

	MOVE	A3,A1		;PALETTE #
	SUBI	NUMPAL,A1	;COMPUTE PALETTE #
	NEG	A1
	move	a1,*a13(PTEMP1+16) ; save slot number

	SLL	8,A1		;X 256

	move	a8,a0
	calla	PALSET
	jreq	uzabt
	sll	4,a2
	add	a2,a8		; move source ptr past colors

	subk	16,a0		; include word with num colors
	MOVE	A0,*A5,L	;STUFF PALETTE I.D.
ALLPL3:
	move	a1,a0
	srl	8,a0
	add	a1,a0		; dup slot # in upper and lower byte
	
	MOVE	*A5(PALCNT),A14,W	;INCREMENT COUNT
	ADDK	1,A14 
	MOVE	A14,*A5(PALCNT),W

	move	a0,b4		; adjust start palette

	movk	1,b14		; clear z flg
uzabt:
	rets	





****************************************************************
*
*	a8 = Ptr to compressed data
*
*	Returns:  a6 and b9 = X
*		  b3 = Y
*		  a4 = # frames
*                 a7 = # colors in palette
*
ParseHeader:
	move	*a8+,a6		; X size of frames
	move	*a8+,a1		; Y size of frames
	move	*a8+,a4		; number of frames
	move	*a8+,a7		; number of colors in palette
	move	a1,b3
	move	a6,b9
	rets	

;LengthTree	.set	RamBuffer+RAMBUFSIZ
;DistTree	.set	LengthTree+(256*32)
;MinPtrTbl	.set	DistTree+(256*32)
;	.bss 	RamBuffer,RAMBUFSIZ

RamBuffer	.set	20000000h
	.bss	LengthTree,256*32
	.bss	DistTree,256*32
	.bss	MinPtrTbl,256*32


	.sect	"UNZIP"

*
*	GSP Decompression routine
*
*	ASSUMPTIONS:  1) There is no literal table
*	              2) the size of the sliding window is 4K
*
*	Needs the following Data Tables:
*		CompressedDataTable will contain the following once
*		it is uncompressed:
*			# frames            (1 byte)
*			# colors in palette (1 byte)
*			X size of frame     (1 byte)
*			Y Size of frame     (1 byte)
*			variable length palette data
*			data for each frame
*
*	Needs the following RAM variables:
*		LengthTree   256 long words
*		DistanceTree 256 long words
*		MinPtrTable  256 long words (used for sort)
*		RamBuffer    circular buffer
*	        Tree layout is as follows...
*			low 16 bits = Code
*			next 8 bits = Bit length
*
*	B reg usage...
*		b5 = used for outputting pal bits to DMACMAPCON
*		b6 = pixel sleep count
*		b7 = constant mask for pxl palette split
*		b8 = DMACMAPCON
*		b9  = Master X storage
*		b0 = Ptr to Length tree
*		b1 = Ptr to Distance tree
*		b3 = start of line
*		b4 = start palette duped to fill 16 bits 
*                               (bit 31 set if only 1 palette used)
*		b14 = temp storage in ReadTree and UncompressTree
*


****************************************************************
*
*	a8 = Ptr to compressed data
*	a7 = Ptr to tree table
*
UncompressTree:
*
*	Determine how many codes of each bit length
*
	setf	8,0,0
	move	*a8+,a0		; # compressed bytes to describe tree - 1;
	inc	a0
	movk	0fh,a3		; constant 0xF
	clr	a6		; total number of codes in tree
	move	a7,a5		; save start of tree
*
utr0:
	move	*a8+,a1		; (# codes - 1 << 4) | bit lngth - 1
	move	a1,a2
	srl	4,a2
	inc	a2		; number of codes of this bit length
	add	a2,a6		; adjust total
	and	a3,a1
	inc	a1		; bit length
	move	a1,a11
	sll	16,a11
	movy	a11,a1		; duplicate bit length for sort
utr1:
	move	a1,*a7+,L
	dsjs	a2,utr1		; fill table

	dsjs	a0,utr0		; a6 now contains size of tree
	setf	16,1,0
*
*	Sort Tree by increasing Bit Length.
*		The translation index is placed in the upper byte 
*		of the long word. 
*
	movi	MinPtrTbl,a0	; for placing translation ptrs
	move	a6,a9		; outer loop count (# entries in tree table)
*
*	Outer loop, after each pass, we have found the next minimum
*
utr2:
	move	a5,a7		; restore start of tree
	movi	06543h,a14	; current minimum
	move	a6,b14		; inner loop count	
	movi	07654h,a1	; constant
*
*	Inner loop, go through all values in table and find min.
*	When we find it, we set it to a high value so we don't detect
*	it again.
*
utr3:
	move	*a7,a2		; look at next bit length
	cmp	a14,a2		; is it less than the last minimum
	jrge	nonewmin
	move	a2,a14		; if yes, save new minimum
	move	a7,a11		;         save pointer to minimum
nonewmin:
	addk	32,a7		; point to next entry
	dsjs	b14,utr3
*
*	end of inner loop: min is in a14, ptr to min is in a7
*
	move	a1,*a11		; set this minimum high.
	move	a11,*a0+,L	; place translation ptr in MinPtrTbl.

	dsjs	a9,utr2
*
*	END OF SORT,  Now compute the codes
*
	clr	a11		; Code
	clr	a1		; CodeInc
	clr	a2		; LastBitLength
	move	a6,a14		; loop counter
utr4:
	move	*-a0,a7,L	; translated pointer
	add	a1,a11
	movb	*a7(16),a3	; bit length
	cmp	a3,a2
	jreq	samebitlng
	move	a3,a2		; set new LastBitLength
	movk	16,a3
	sub	a2,a3		; 16-LastBitLength
	movk	1,a1
	sll	a3,a1		; CodeInc = 1 << (16-LastBitLength)
samebitlng:
	move	a11,a5		; copy of Code in a5
	movk	16,a9		; reverse bit loop count
rvrsbts:
	sll	1,a5		; Reverse bits of word
	movy	a5,a3
	srl	1,a3
	zext	a5
	dsjs	a9,rvrsbts

	move	a3,*a7		; store code with bits reversed
	dsjs	a14,utr4
	
	rets


*	a8 = (sgn bit = 1, 1 pal, otherwise 4 pals)
*		(low 16 bits contain repeated palette slot number
*
HOLD_FADE_PROC:
	sleep	2		; let palette get loaded
	move	a8,a0
;	calla	FADE_256_BLAK	; bring to zero
	MOVI	FadeBlak,a11
	CLR	A10
	CALLA	FADE_ONLY	; bring to zero
	sleep	4		; let it fade
	move	a8,a0
;	calla	FADE_256_IN	; fade in
	MOVI	FadeIn,a11
	CALLA	FADE_ONLY
	DIE


SetConstants:
	movi	LengthTree,b0
	movi	DistTree,b1
SetConstX:
	movi	RamBuffer+RAMBUFSIZ-1,a0	; mask for rambuf ptr
	movi	RamBuffer,a6 	; used for negative wraparound
	movi	0c0c0h,b7	; for blowing words of 
	movi	DMACMAPCON,b8     
	move	*a13(PTEMP1),a14   	; pixels between sleep
	move	a14,b6
	movi	BlowLine,b10
	rets


MovieSleep:
	move	@MOVIE_SLEEP,a14,L
	movb	*a14,a0
	jrn	onetikslp
	addk	8,a14
	move	a14,@MOVIE_SLEEP,L
	inc	a0
	jruc	multitik
onetikslp:
	movk	1,a0
multitik:
	move	@FRAMENUM,a14	; if 1st frame, check for hold
	jrz	chk4hold
	dec	a14
	jrnz	nonono
	move	@HOLDFADE,a14	; on second frame, wait for hold time
	add	a14,a0
	jruc	nonono

chk4hold:
	move	@HOLDFADE,a14
	jrz	nonono		; if need to hold, create fade process
	PUSH	a8
	move	b4,a8
	CREATE	PID_IND,HOLD_FADE_PROC
	PULLQ	a8
	movk	6,a0		; sleep longer if we are fading palette
nonono:
	movi	swappg,a14
	jruc	GoToSleep
swappg:
	move	@VCOUNT,a4
	cmpi	200,a4
	jrle	swappg
	mmfm	a12,a4,a10
*
*	Swap Display Pages between frames
*
	btst	20,a10		;which page are we on?
	jrnz	top1		
	movi	DPYSTRT0,a14		; wrote to p0, switch there
	clr	a3    			; new page 0
	addi	TOGGLE_PAGE_L,a10	; write to p1 now
	jruc	top0
top1:	
	movk	1,a3			; wrote to p1, switch there
	movi	DPYSTRT1,a14
	subi	TOGGLE_PAGE_L,a10	; write to p0 now
top0:					; 
	setf	16,1,0
;NOTE: Must add check for SUPRESS_PAGE_FLIP here. If it is non-zero then
;	do not stuff DPYST.
	move	A14,@DPYST,L
	move	a3,@PAGE,W

;	move	@FRAMENUM,a14	; sound only on first frame
;	jrnz	nono
;	PUSH	a0
;	move	@CLIPSND,a0,L	; sound from sound table
;	jrz	no
;	calla	ONESND
;no:
;	PULLQ	a0
;nono:
	inc	a14
	move	a14,@FRAMENUM		; save next frame number

	move	*a13(PTEMP3),a14,L	; number of pixels in a frame
	add	a14,a11			; adjust by extra pixels done last time

	cmpi	2,a4
	jrne	nxtfrm
	movi	BlowLineLastFrm,b10
	jruc	nxtfrm



StillSleep:
	movk	1,a0
	movi	us0,a14			; return address
GoToSleep:
	getst	b2
	move	a12,b14
	mmtm	b14,b2,b3,b4,b5,b9
	move	b14,a12
	setf	32,0,1
	setf	16,1,0
	move	a14,*a13(PTEMP2),L
	calla	PRCSLP

	move	a12,b14
	mmfm	b14,b2,b3,b4,b5,b9
	move	b14,a12

	callr	SetConstants
	move	*a13(PTEMP2),a14,L

	putst	b2
	exgpc	a14


*
*	ENTERING:
*		a4 = Number of frames
*		a8 = Ptr to Compressed Data Table
*		b3 = Y size
*		b4 = strt pal
*		b9 = X size
*		a10 = Screen destination (Linear)
*
DECOMPRESS:
	.if CENTER_SCREEN
	addi	BITMAP_OFFSET,a10	; XUNIT
	.endif
	movi	LengthTree,b0
	movi	DistTree,b1

	move	b0,a7			; Length Tree
	callr	UncompressTree

	move	b1,a7			; Distance Tree
	callr	UncompressTree
*
*	clear upper 4K of RamBuffer to take care of initial wraparound
*
	movi	RamBuffer+RAMBUFSIZ,a1		; end of buffer
	movi	1024,a2				; 4K bytes = 1K long words
	clr	a3
clrbuf:
	move	a3,*-a1,L
	dsjs	a2,clrbuf
*
*	Do some initializing
*
	mpyu	b9,b3
	move	b3,a11		; total # bytes in frame in a11
	move	a11,*a13(PTEMP3),L
	callr	SetConstX
	move	a6,a9		; Where to uncompress to
	move	a9,b3		; first frame start
	clr	b5		; pixel count for Stills only
	cmpi	1,a4
	jreq	UncompressFrame
*	   .align
nutha1:
	.if DEBUG	
	CLRM	@NUM_LINES,L
	.endif
	mmtm	a12,a4,a10
	JSRP	UncompressFrame	; a7 is available
	jruc	MovieSleep	; to swap display pages and sleep
nxtfrm:
	dsjs	a4,nutha1	; loop once for each frame

	RETP


*******************************************************************
*
*	Entry:	Table in a5
*		Compressed data ptr in a8
*
*	Uses:	a2 = bits read
*		a3 = Code
*		a4 = Blngth
*		a14 = temp storage
*		a7 = data parsed from input stream
*
*	Must preserve:
*		a9, a1, a6, a11, a8, a0, a10 
*
ReadTree:
	movk	1,a2		; bits_read
	clr	b14		; result
	setf	1,0,0
	move	*a8+,a7	; read a bit
	rl	31,a7		; rotate right one more bit
rtlp:
	move	*a5,a3,L	; Code in a3
	move	*a5(16),a4,L	; Blngth in a4
	movk	32,a14
	sub	a2,a14
	rl	a14,a3		; rotate right as many bits have been read
rtlp2:
	cmpxy	a3,a7
	jryz	ident
	addk	32,a5
	inc	b14
	jruc	rtlp
ident:
	cmp	a2,a4
	jrz	finis
	move	*a8+,a14	; read a bit
	or	a14,a7		; accumulate with other bits
	inc	a2		; inc bits_read
	rl	31,a7		; rotate right one more bit
	rl	31,a3		; shift code for check of next bit
	jruc	rtlp2

finis:
	move	b14,a7		; leave result in a7
	rets			; Result returned in a7



******************************************************************************
*
*	BlowLine  is used during decompression of a Still Picture to blow out
*	a single line of data.  Since only a single line needs to be stored at
*	once, the RamBuffer can be as small as 4K.
*
BlowLine:
	.if DEBUG
	INCM	@NUM_LINES,L
	.endif
	move	a10,a3 		; where on screen to put
	move	b3,a1		; start of line
	move	b9,a5		; X size
	srl	1,a5		; X/2 = loop counter

	move	b4,*b8,L		; Set Pallette Register
SPBlowL1:
	move	*a1+,*a3+,L		; write into both screens
	and	a0,a1
	dsjs	a5,SPBlowL1

EndBlowLine:
	subi	SCRN_PTCH,a10
	move	a1,b3		; save for next frame
	sub	b9,b5		; readjust pixels for next line
	CMP	B9,B5		; ADDED 6/92. If there are enough pixels
	JRGE	NUTHER		; left to do another line, do it.
	sub	b9,b6		; pixel sleep count
	jrgt	noslp
      	clr	b6		; set zero flag to indicate sleepytime
noslp:
      	rets

NUTHER:
	SUB	B9,B6
	JRUC	BlowLine




****************************************************************
*
*	a8 = Ptr to compressed data
*	a9 = Where to put uncompressed bytes
*	a11 = How many to place before returning.
*	a0 = mask for a9
*
*	Uses:	a4 = Length
*		a1 = Distance
*		a2 = ptr to leftover data if there is any
*
*	ReadTree uses a2-a5,a7,a14
*	Need to Preserve: 	B9-B13
*	 			a0 = Ram Buffer addr mask
UncompressFrame:
	setf	16,0,1		; FIELD 1 IS 16 BITS!!!
UncFr0:
	setf	1,0,0
	move	*a8+,a14	; if bit = 1, read 8 bits and copy		
	jrz	decode_still
	setf	8,0,0

	move	*a8+,*a9+
	and	a0,a9
	
	inc	b5		; pixel count
	dec	a11
us1:
	cmp	b5,b9		; have we filled a line yet?	
	jrgt	us0
    	call	b10		; Blow Line Routine
	jrz	StillSleep
us0:	
	move	a11,a11
	jrgt	UncFr0
	setf	32,0,1
	RETP

decode_still:		 	; if bit = 0, decode from trees
	setf	6,0,0
	move	*a8+,a1		; lower 6 bits of distance
	move	b1,a5		; Distance Tree in a5
	callr	ReadTree	; Result in a7
	sll	6,a7
	or	a7,a1			
	inc	a1		; DISTANCE in a1
	sll	BPP,a1		; turn it into a pointer

	move	b0,a5		; Length Tree in a5
	callr	ReadTree	; Result in a7
	move	a7,a4
	cmpi	63,a4
	jrne	notmaxs
	setf	8,0,0		; If length is 63,
	move	*a8+,a3		; get next byte, and 
	add	a3,a4		; add it to the length
notmaxs:
	addk	2,a4		; add MML, LENGTH in a4
	setf	8,0,0
*
*	We now have Length and Distance,  now determine where to copy from
*
	move	a9,a2		; copy of current position in a2
	sub	a1,a2  		; initial attempt
	and	a0,a2		; handle wraparound
	or	a6,a2
*
*	COPY POINTER is now in a2, do the copying
*
	move	a4,a14
copys:
	move	*a2+,*a9+
	and	a0,a9
	and	a0,a2
	dsjs	a14,copys

	move	a4,b14
	add	b14,b5	    	; adjust pixel counter for this line
	sub	a4,a11		; adjust total pixel count
	jruc	us1


******************************************************************************
*
*	Same as BlowLine, but blows to both screens
*
BlowLineLastFrm:
	move	a10,a3 		; where on screen to put
	movi	TOGGLE_PAGE_L,a4 	;  assume on p0
	btst	20,a10		;
	jrz	onp0
	neg	a4
onp0:
	add	a3,a4		;  other page address in a4
	move	b3,a1		; start of line
	move	b9,a5		; X size
	srl	1,a5		; X/2 = loop counter

	move	b4,*b8,L		; Set Pallette Register
SPBL1:
	move	*a1+,a14,L		; write into both screens
	move	a14,*a3+,L
	move	a14,*a4+,L		; write into both screens
	and	a0,a1
	dsjs	a5,SPBL1

	jruc	EndBlowLine



	

	.text

VIDEO_PLAY
   LW      1,5
   LWLWL   1,10|AFunc,A_CREATEP+3,PID_JUNK,DRESS_MOVIE	
   LWLL	   TWAL,10|AFunc,A_CHANGE_PAL+2,Backdrop
LOOPY2:
   LWLL	   1,127|AFunc,A_AnimFrm+2,LOOPY2
UNLOOPY2:
   LWLL    SNOWSCRN,1|AFunc,A_CHANGE_PAL+2,SNOWp
   LWLLW   1,1|AFunc,A_Set_Var_Word+3,GUNS_OFF,0
   LWLLW   1,1|AFunc,A_Set_Var_Word+3,SCROLL_FLAG,1

   LWL	   1,1|AFunc,PULL_ANIM



SND_TAKENOVER:	
	.WORD	0F3F0H,160,882bh,0
SND_STOPEM:	
	.WORD	0F3F0H,1903,0882CH,0
SND_REMEMBER
	.WORD	0F3F0H,140,0882DH,0


C1SLPTAB	.byte	2,2,2,2,2,2,2,2,2,2,2,3,4,5,6,10
		.byte	6,6,6,6,7,7,7,8,8,-1

C2SLPTAB	.byte	0,0,0,0,1,1,2,2,3,3,4,5,6,7,7,7
		.byte	6,6,6,6,6,7,7,7,7,7,7,7,7,7,7,7,7,-1

C3SLPTAB	.byte	0,0,1,1,2,3,3,3,3,3,3,3,3,4,4,5
		.byte	6,6,6,7,7,7,7,7,7,7,6,6,6,-1

SCREENORG	.set	0b73d8h	
SCREENORG_UNF	.set	0b7458h	

DRESS_MOVIE:
	PUSHP	a8		; save object
DRESS_MOVIE_lp:
 	movk	2,a11
	JSRP	DO_STATIC

	movi	LFrame_INIT,b0
	calla	EASYMAKE
	move	a0,a8

	move	a13,*a8(OPLINK),L

	sleep	800			; let backdrop get written

	MOVIM	C3SLPTAB+18h,@MOVIE_SLEEP,L
	movk	1,a11
	JSRP	DO_STATIC

	sleep	800			; do clip b
	
	MOVIM	C1SLPTAB,@MOVIE_SLEEP,L
	movk	1,a11
	JSRP	DO_STATIC

	sleep	800			; throw keys

	MOVIM	C2SLPTAB,@MOVIE_SLEEP,L
	movk	1,a11
	JSRP	DO_STATIC

	sleep	800			; do clip c

	movk	2,a11
	JSRP	DO_STATIC

	PULLP	a0
	MOVIM	UNLOOPY2,*a0(AnimFrm),L
	MOVKB	1,*a0(AnimSlp)


	DIE

*
*	Display system starts on and ends on
*	a11 = number of static loops
*
DO_STATIC:
	MOVKM	1,@SUPRESS_PAGE_FLIP,W	; STOP DISPLAY
	move	a14,@SKIPDISP,W
	move	a14,@NOAUTOE,W

	calla	DMAQWAIT

stat_lp
	PUSHP	a11
	SOUND1	SND_CONELRAD
	movi	gxstat,a8
	movi	SCREENORG,a10
	move	@NO_MIRROR,a14,W		;Are we mirroring
	jrz	UseFlipped		;BR = Yes
	movi	SCREENORG_UNF,a10
UseFlipped
	JSRP	MOVIE
	PULLP	a11
	sleep	1
	dsj	a11,stat_lp


	CLRM	@SUPRESS_PAGE_FLIP,W	; Restart display
	move	a14,@SKIPDISP,W
	move	a14,@NOAUTOE,W
	RETP



START_KEYS
	movi	keys_INIT,b0
	calla	EASYMAKE

	move	*a8(OXVAL),*a0(OXVAL),L
	move	*a8(OYVAL),*a0(OYVAL),L
	move	*a8(OZVAL),*a0(OZVAL),L

	MOVIM	8c00h,*a0(OXVEL),L
	MOVIM	-24000h,*a0(OYVEL),L
	MOVIM	0f00h,*a0(OYACCEL),W
	MOVIM	-100h,*a0(OZVEL),L

	move	a0,a8
	movi	580h,a5
	calla	SET_SCALE_MANUAL

	calla	INSERT_OBJ

	clr	a9			; hand not created yet
	CREATE	PID_IND,MON_KEYS

	SOUND1	SND_THROW_KEYS

	rets




MON_KEYS:
	move	a9,a9
	jrnz	hand_there
	move	*a8(OYVEL),a14,L	; hand up when keys start to drop
	jrn	hand_there
	movi	CATCH_INIT,b0
	move	a8,a9
	calla	MULTIMAKE
	SWAP	a8,a9			; hand in a9
hand_there:
	move	*a8(OZVAL),a0,L
	move	@ZBASE,a14,L
	sub	a14,a0
	cmpi	ZMAX_REAL-100h,a0
	jrlt	keys_close_enuf

			; needs to have a world Z in a0
			; uses a5 and calls SET_SCALE_MANUAL
	CMANSCL	3200h,8000h,0c0h,580h

	sloop	1,MON_KEYS
keys_close_enuf:
	calla	DELETE_OBJ
	DIE
		     

LFrame_INIT
	.long	STA01
	.word	DMAWNZ,M_NOSCALE,OM_WPOS|OM_INSERT|OM_ANIM
	.long	ST_clipA
	.long	-130000h,-0b0000h,0801fh


ST_clipA:
	LW	STA01,6
	LW	STA02,6
	LW	STA03,6
	LW	STA04,1
	LWLL	1,5|AFunc,A_SOUND+2,SND_TAKENOVER
	LW	STA05,7
	LW	STA06,7
	LW	STA07,7
	LW	STA08,7
	LW	STA09,7
	LW	STA10,7
	LW	STA11,7
	LW	STA12,7
	LW	STA13,7
	LW	STA14,7
	LW	STA15,7
	LW	STA16,7
	LW	STA17,7
	LW	STA18,7
	LW	STA19,7
	LW	STA20,7
	LW	STA21,7
	LW	STA22,7
	LW	STA23,7
	LW	STA24,7
	LW	STA25,7
	LW	STA26,7
	LW	STA27,7
	LW	STA28,7
	LW	STA29,7
	LWL	1,1|AFunc,WAKE_PROC

ST_clipB:
	LWLL	STB01,6|AFunc,A_CHANGE_PAL+2,STBP
	LW	STB02,6
	LW	STB03,6
	LW	STB04,4
	LWLL	1,3|AFunc,A_SOUND+2,SND_STOPEM
	LW	STB05,7
	LW	STB06,7
	LW	STB07,7
	LW	STB08,7
	LW	STB09,7
	LW	STB10,7
	LW	STB11,7
	LW	STB12,7
	LW	STB13,7
	LW	STB14,7
	LW	STB15,7
	LW	STB16,7
	LW	STB17,7
	LW	STB18,7
	LW	STB19,7
	LW	STB20,7
	LW	STB21,7
	LW	STB22,7
	LW	STB23,7
	LW	STB24,8
	LW	STB25,7
	LW	STB26,7
	LW	STB27,7
	LW	STB28,7
	LW	STB29,7
	LW	STB30,7
	LW	STB31,7
	LW	STB32,7
	LW	STB33,7
	LW	STB34,7
	LWL	1,1|AFunc,WAKE_PROC

ST_throwk:
	LWLL	STKEYS01,5|AFunc,A_CHANGE_PAL+2,STKEYSP
	LW	STKEYS03,5
	LW	STKEYS04,4
	LW	STKEYS05,4
	LW	STKEYS06,4
	LW	STKEYS07,4
	LW	STKEYS08,4
	LWL	STKEYS10,4|AFunc,START_KEYS
	LW	STKEYS11,4
	LW	STKEYS12,4
	LW	STKEYS13,4
	LW	STKEYS14,4
	LW	STKEYS15,4
	LW	STKEYS16,4
	LW	STKEYS17,4
	LW	STKEYS18,4
	LW	STKEYS19,4
	LW	STKEYS20,4
	LW	STKEYS21,5
	LW	STKEYS22,90
	LWL	1,1|AFunc,WAKE_PROC

ST_clipC:
	LWLL	STC01,6|AFunc,A_CHANGE_PAL+2,STC31P
	LW	STC02,6
	LW	STC03,6
	LW	STC04,7
	LWLL	STC05,7|AFunc,A_SOUND+2,SND_REMEMBER
	LW	STC06,6
	LW	STC07,8
	LW	STC08,8
	LW	STC09,7
	LW	STC10,7
	LW	STC11,7
	LW	STC12,7
	LW	STC13,7
	LW	STC14,6
	LW	STC15,6
	LW	STC16,7
	LW	STC17,7
	LW	STC18,7
	LW	STC19,7
	LW	STC20,7
	LW	STC21,6
	LW	STC22,6
	LW	STC23,6
	LW	STC24,6
	LW	STC25,6
	LW	STC26,7
	LW	STC27,7
	LW	STC28,7
	LW	STC29,7
	LW	STC30,7
	LW	STC31,7
	LWL	1,1|AFunc,WAKE_PROC

	LWL	1,1|AFunc,DELETE_STEVEN

WAKE_PROC:
	move	*a8(OPLINK),a1,L
	LOCKON	Z
	MOVKM	1,*a1(PTIME),W		; wake him up to start last clip
	rets

DELETE_STEVEN:
	CLRM	*a8(OPLINK),L
	jauc	DELETE_OBJ		; delete me


keys_INIT
	.long	rkey1
	.word	DMAWNZ,M_MANSCALE,OM_ANIM
	.long	KeyAnim

KeyAnim:
	LW	rkey1,4
	LW	rkey2,4
	LW	rkey4,4
	LW	rkey5,4
	LW	rkey6,4
	LW	rkey8,4
	LW	rkey9,4
	.long	0


CATCH_INIT
	.byte	2,0,0,2
	.long	P_RSLO_C,P_RCATCH
	.word	OID_JUNK,OM_WPOS|OM_INSERT
	.long	100000h,1a0000h,2f00h
	LWWWW	OPENH,DMAWNZ,M_NOCOLL|M_NOSCALE,0,OM_ANIM
	.long	CATCH_KEYS_ANIM
	LWWWW	RSLVO_C,DMAWNZ,M_NOCOLL|M_NOSCALE,0,0

CATCH_KEYS_ANIM:
	LW	1,30
	LWLL	1,1|AFunc,A_SET_OYVEL+2,-30000h
	LWLW	1,1|AFunc,A_STAY_TIL_SY_LT+1,150
	LWL	1,2|AFunc,A_CLR_OYVEL
	LWLL	CLOSEDH,20|AFunc,A_SOUND+2,SND_CATCH_KEYS
	LWLL	1,1|AFunc,A_SET_OYVEL+2,10000h
	LWL	1,1|AFunc,A_Set_LOOP_STRT
	LWL	1,10|AFunc,A_OFFSCRN_DEL
	.long	0


S_CAR_BEEPER:
	movi	BEEP_INIT,b0
	calla	MULTIMAKE

	jauc	SCRL_DISPATCHER


BEEP_INIT
	.byte	2,0,0,2
	.long	P_RSLBEEP,P_RHDBEEP
	.word	OID_JUNK,OM_WPOS|OM_INSERT
	.long	00000h,1a0000h,2f00h
	LWWWW	RHNDBEEP,DMAWNZ,M_NOCOLL|M_NOSCALE,0,OM_ANIM
	.long	BEEP_KEYS_ANIM
	LWWWW	RSLVBEEP,DMAWNZ,M_NOCOLL|M_NOSCALE,0,0

BEEP_KEYS_ANIM:
	LWLL	1,1|AFunc,A_SET_OYVEL+2,-20000h
	LWLW	1,1|AFunc,A_STAY_TIL_SY_LT+1,170
	LWL	1,60|AFunc,A_CLR_OYVEL
	LWLL	1,1|AFunc,A_SET_OYVEL+2,20000h
	LWL	1,1|AFunc,A_Set_LOOP_STRT
	LWL	1,10|AFunc,A_OFFSCRN_DEL
	.long	0

SND_THROW_KEYS
	.word	0f3f0h,36,0842bh,0
SND_CATCH_KEYS
	.word	0f3f0h,10,0842ch,0
SND_CONELRAD
	.word	0f3f0h,58,0842ah,0
