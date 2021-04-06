 	.MLIB	"GXMACS.LIB"
	.FILE	"GXBGND.ASM"
	.TITLE	" <<< GENERATION X -- BACKGROUND MAINTENANCE >>>"
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

	;*** EXTERNAL GLOBAL SYMBOLS
	.ref	BAKPLANE,BAKTL,BAKBITS,BAKMODS

	;*** GLOBAL SYMBOLS IN THIS FILE
	.def	BGND_UD1,BAK_STRT,BAK_END,CLRBBIT
	.IF	IMGBGND
	   .def	InitBTbl,DnLdMods
	.ENDIF

************* Local Constants for UPD **************
DISP_PAD    	.set	00300030h	  ; Y:X
WIDEST_BLOCK	.set	250

;* Must keep the size of these structures a multiple of 16
map_zflagspal	.set 0
map_pal		.set 0		;size 4 - palette select
map_flags   	.set 4		;size 4 - bit 0 hflip, bit 1 yflip
map_z		.set 8		;size 8
map_x		.set 16		;size 16
map_y		.set 32		;size 16
map_hdr		.set 48		;size 16 - offset in long words from block_hdr_tbl
				; bits 12-15 are bits 4-7 of pal
				; map_hdr set to 0FFFFh if block is not allocated
block_size	.set 64		;* if changed must get rid of shifts by 6

;* Offsets for a BLOCK HDR structure
map_size	.set	0
map_w		.set	0	;size 16	  ; These fields can't be changed
map_h		.set	16	;size 16	  ; because they are used as the
map_animoff	.set 	32	;size 32	  ; OIMG block header
map_dataptr	.set	64	;size 32	  ;
block_hdr_size	.set 	96

BSIZE	.set	0
BSAG	.set	20h
BCTRL	.set	40h


;* Offsets for a MODULE definition
	.IF	IMGBGND
mod_w	.set	0	;UHW	width of module
mod_h	.set	010h	;UHW	height of module
mod_blkct .set	020h	;UHW	# blocks in module
mod_bindx .set	030h	;UHW	index into BLKTBLPTRS
mod_hindx .set	040h	;UHW	index into HDRTBLPTRS
mod_pals  .set	050h	;UHL	ptr to table of pals
	.ELSE
mod_w	.set	0	;UHW	width of module
mod_h	.set	010h	;UHW	height of module
mod_blkct .set	020h	;UHW	# blocks in module
mod_blks .set	030h	;UHL	ptr to BLOCKS
mod_hdrs .set	050h	;UHL	ptr to HDRS
mod_pals  .set	070h	;UHL	ptr to table of pals
	.ENDIF



MAXHDRTBLS	.set	50
MAXBLKTBLS	.set	200
BGNDTBLWORDS	.set	1000*4+150*4
 ;1000 Block table entries + 150 Block Headers
	.IF	IMGBGND
	.ref	BLKTBLPTRS,HDRTBLPTRS

	.BSS	TMPWORD,010h
	.BSS	BgdTIndx,020h
	.BSS	HdrTPtrs,MAXHDRTBLS*020h
	.BSS	BlkTPtrs,MAXBLKTBLS*020h
	.BSS	BgndTbls,BGNDTBLWORDS*010h
	.BSS	BgndTblX,0
	.ENDIF


************************************************************************
BGNDHGHT:
;Parms	A0 - XPOS for which height of BackGround needs to be determined
;Returns A0 -
;	Minimum YPOS (max height) of PRIMARY background which overlaps
;	specified XPOS
;	A0 = 0 if XPOS is invalid

;* Scan a Module list to find out which module contains blocks
;* which need to be checked
	mmtm	SP,A1,A2,A3,A4,A7,A8,A9,A10,A11
	move	A0,A1

	clr	A10			;init packed y:x starting position
	clr	A11

	move	@BAKMODS,A0,L		;* A0- ptr to the module list
ModLp0:
	move	*A0+,A8,L		;load module ptr
	cmpi	0FFFFFFFFh,A8
	jrz	ModX0			;end of the module tbl
	move	*A8+,A9,L		;load packed y:x size

	move	*A0+,A3,W		;X start position
	zext	A3,W
	cmpi	BLSTSTRT,A3
	jrnz	NotLstStrtX
	move	A11,A3	
	subxy	A9,A3
	jruc	GotNewX0
NotLstStrtX:
	cmpi	BLSTEND,A3
	jrnz	GotNewX0
	move	A11,A3
GotNewX0:
	move	*A0+,A4,W		;Y start position
	zext	A4,W
	cmpi	BLSTSTRT,A4
	jrnz	NotLstStrtY
	move	A11,A4	
	subxy	A9,A4
	jruc	GotNewY0
NotLstStrtY:
	cmpi	BLSTEND,A4
	jrnz	NotLstEndY
	move	A11,A4
	jruc	GotNewY0
NotLstEndY:
	sll	16,A4
GotNewY0:
	movy	A4,A3
	move	A3,A10

;	cmpxy	A10,A1
;	jrv	ModX0 	;jump to exit loop if Mod start X > X sought

	;if Mod end X < X sought keep searching mod list
	move	A10,A11
	addxy	A9,A11	;A11 is module y:x end

	move	*A8+,A9,W		;load # of blocks
	add	A9,A7		;A7 is new BAKBITS ptr
	cmpxy	A11,A1
	jrnv	ModLp0		;skip if Ax < Bx

	move	A10,A0
	srl	16,A0
	jruc	GotHGHT

ModX0:
	clr	A0
GotHGHT:
	mmfm	SP,A1,A2,A3,A4,A7,A8,A9,A10,A11
	rets
************************************************************************

**************************** BSrch1stXB ********************************
BSrch1stXB:
;*** PARMS
;	A0 - x coordinate of a block
;	A1 - Start of background block table
;	A2 - end of block table
;*** Returns
;	A0 - address of first block with x coordinate >= parm
;		if new x is highest returns next empty block
;		if no blocks with >= X, return 0

;* A0 = X val being searched for
;* A1 = Block Table Base + offset to X val
;* A14 - Threshhold for switching from binary to linear search
;* A9 = Low # -- # greatest background block
;* A10 = Mid # -- (High + Low) >> 1
;* A2 = High # -- # of lowest background block

	mmtm	SP,A1,A2,A8,A9,A10
	clr	A9		;* set low = 0
	sub	A1,A2
	srl	6,A2	;* div by size of block (64)
	addi	map_x,A1	;* block tbl base + X offset
	movk	5,A14	;* threshhold for switching from binary to linear search
BSRCH:
	move	A2,A10
	sub	A9,A10	;* if (high - low) <= 5 finish with linear search
	cmp	A14,A10
	jrle	LSRCH

	srl	1,A10
	add	A9,A10	

	;* get mid->x
	move	A10,A8
	sll	6,A8		;* multiply by block size (64)
	add	A1,A8
	move	*A8,A8,W	;* get x coor of the block
	cmp	A0,A8
	jrlt	Blow
	move	A10,A2	;* high = mid
	jruc	BSRCH
Blow:
	move	A10,A9	;* low = mid
	jruc	BSRCH
LSRCH:
	;* finish with a linear search of block table from low to high
	;* ending with first block x coor that is >= A0
;* A0 = X val being searched for
;* A9 = Low Address -- pts to X offset of block
;* A2 = High Address -- pts to X offset of block
	sll	6,A9		;* low block # to low block offset
	sll	6,A2		;* high block # to high block offset
	add	A1,A9
	add	A1,A2
	movi	block_size,A8
LSRCHLP:
	move	*A9,A10,W	;* X coor
	cmp	A0,A10
	jrge	GotB		;* if low->x >= A0 goto found
	add	A8,A9
	cmp	A2,A9
	jrle	LSRCHLP
;* block not found, return 0
	clr	A0
	jruc BSrchDone
GotB:
	;* return a ptr to the block
	move	A9,A0
	subi	map_x,A0

BSrchDone:
	mmfm	SP,A1,A2,A8,A9,A10
	rets
**************************** BSrch1stXB ********************************


*********************** BAK END *******************************
;* Scan a Module list and return the packed Y:X end point
;PARMS
	;A0 - Module list
;RETURNS
	;A0 - PACKED Y:X end of wave
BAK_END:
	mmtm	SP,A3,A4,A8,A9,A10,A11

	clr	A10	;clr packed y:x starting position
	clr	A11
WEModLp:
	move	*A0+,A8,L		;load module ptr
	cmpi	0FFFFFFFFh,A8
	jrz	WEModX			;end of the module tbl
	move	*A8+,A9,L		;load packed y:x size

	move	*A0+,A3,W		;X start position
	zext	A3,W
	cmpi	BLSTSTRT,A3
	jrnz	WENotLastStartX
	move	A11,A3	
	subxy	A9,A3
	jruc	WEGotNewX
WENotLastStartX:
	cmpi	BLSTEND,A3
	jrnz	WEGotNewX
	move	A11,A3
WEGotNewX:
	move	*A0+,A4,W		;Y start position
	zext	A4,W
	cmpi	BLSTSTRT,A4
	jrnz	WENotLastStartY
	move	A11,A4	
	subxy	A9,A4
	jruc	WEGotNewY
WENotLastStartY:
	cmpi	BLSTEND,A4
	jrnz	WENotLastEndY
	move	A11,A4
	jruc	WEGotNewY
WENotLastEndY:
	sll	16,A4
WEGotNewY:
	movy	A4,A3
	move	A3,A10

	move	A10,A11
	addxy	A9,A11	;A11 is module y:x end
	jruc	WEModLp

WEModX:
	move	A11,A0
	mmfm	SP,A3,A4,A8,A9,A10,A11
	rets
***********************************************************************

*********************** BAK START *******************************
;* Scan a Module list and return the packed Y:X starting point
;PARMS
	;A0 - Module list
;RETURNS
	;A0 - PACKED Y:X start of wave
BAK_STRT:
	mmtm	SP,A3,A4,A8,A9,A11

	clr	A11
	move	*A0+,A8,L		;load module ptr
	cmpi	0FFFFFFFFh,A8
	jrz	WSModX			;end of the module tbl
	move	*A8+,A9,L		;load packed y:x size

	move	*A0+,A3,W		;X start position
	zext	A3,W
	cmpi	BLSTSTRT,A3
	jrnz	WSNotLastStartX
	move	A11,A3	
	subxy	A9,A3
	jruc	WSGotNewX
WSNotLastStartX:
	cmpi	BLSTEND,A3
	jrnz	WSGotNewX
	move	A11,A3
WSGotNewX:
	move	*A0+,A4,W		;Y start position
	zext	A4,W
	cmpi	BLSTSTRT,A4
	jrnz	WSNotLastStartY
	move	A11,A4	
	subxy	A9,A4
	jruc	WSGotNewY
WSNotLastStartY:
	cmpi	BLSTEND,A4
	jrnz	WSNotLastEndY
	move	A11,A4
	jruc	WSGotNewY
WSNotLastEndY:
	sll	16,A4
WSGotNewY:
	movy	A4,A3
	move	A3,A0

WSModX:
	mmfm	SP,A3,A4,A8,A9,A11
	rets
***********************************************************************

****************  U P D A T E   D I S P   L I S T **********************
;* deletes all display objects which are not on the screen
;* insures all background blocks on screen are on the disp list
BGND_UD1:		;* call to update main background
;* input, SCRNTL, SCRNBR, BAKBITS, BAKMODS
;	BAKTL, BAKPLANE			
;	A8-PLANE PTR

	;* this protects DISP_MOD and DISP_DEL TOO!
;	mmtm	SP,A0,A1,A2,A3,A4,A5,A6,A7,A8,A9,A10,A11,A12,A13,A14
;	mmtm	SP,B0
	mmtm	SP,A8,A9,A10,A11,A12,A13

	move	A8,B0  		;B0 - plane ptr

	;* Get coors of area to be put on display list.
	move	@BAKTL,A3,1
	move	A3,A4
	move	@SCRNTL,A0,1
	addxy	A0,A3 	
	move	@SCRNBR,A0,1
	addxy	A0,A4	
	movi	DISP_PAD,A0
	subxy	A0,A3		;A3 - disp_tl
	addxy	A0,A4		;A4 - disp_lr

	callr	DSP_DEL		;SCREEN DOESN'T WRAP MAX/MIN DISCONTINUITY

AddEm:
	;* determine which module
	move	@BAKMODS,A0,L		;A0- ptr to the module list
	move	@BAKBITS,A7,L		;A7 - bit table for block being on disp list

	callr	DISP_MOD

	mmfm	SP,A8,A9,A10,A11,A12,A13
;	mmfm	SP,B0
;	mmfm	SP,A0,A1,A2,A3,A4,A5,A6,A7,A8,A9,A10,A11,A12,A13,A14
	rets
***********************************************************************


*********************** D I S P   M O D *******************************
;* Scan a Module list to find out which modules contain blocks
;* which need to be checked for addition to the display list.
;	B0 - plane ptr
;	A0 - Module list
;	A3 - disp_tl
;	A4 - disp_lr
;	A7 - BAKBITS	;A7 - bit table for block being on disp list

;PARMS For DISP_ADD
;	A1 - Background Block table
;	A2 - End of Background Block table
;	A5 - Background hdr table
;	A9 - Module Start Position Y:X
;	A10 - ptr to palette table for new block
;	    ;passed from above
;	A3 - disp_tl
;	A4 - disp_lr
;	A6 - which bakground insert routine primary|secondary
;	A7 - bit table for block being on disp list

;* caller is responsible for pushing and popping all A-registers

DISP_MOD:
	mmtm	SP,A0,A3,A4,A7

	clr	A9			;init y:x starting position
	clr	A11			;ending y:x pos
	move	A7,A6			;A6 will point to BakBits after Mod

ModLp:
SkDAdd:
	move	A6,A7
	move	*A0+,A8,L		;load module ptr
	cmpi	0FFFFFFFFh,A8
	jrz	ModX			;end of the module tbl
	move	*A8+,A10,L		;load y:x size

	move	*A0+,A14,W		;X start position
	zext	A14,W
	cmpi	BLSTSTRT,A14
	jrnz	NotLastStartX
	move	A11,A14	
	subxy	A10,A14
	jruc	GotNewX
NotLastStartX:
	cmpi	BLSTEND,A14
	jrnz	GotNewX
	move	A11,A14
GotNewX:
	move	*A0+,A5,W		;Y start position
	zext	A5,W
	cmpi	BLSTSTRT,A5
	jrnz	NotLastStartY
	move	A11,A5	
	subxy	A10,A5
	jruc	GotNewY
NotLastStartY:
	cmpi	BLSTEND,A5
	jrnz	NotLastEndY
	move	A11,A5
	jruc	GotNewY
NotLastEndY:
	MOVE	@HORIZON_BASE,A9,W	;GET THE HORIZON LINE
	ADD	A9,A5			;ADD IT TO THE GIVEN OFFSET
	sll	16,A5
	SUBXY	A10,A5			;SUBTRACT HEIGHT OF THIS MODULE
GotNewY:
	movy	A5,A14
	move	A14,A9

	move	A9,A11
	addxy	A10,A11			;A11 is module y:x end
	move	*A8+,A10,W		;load # of blocks
	add	A10,A6			;A6 is new BAKBITS ptr

	move	A9,B1
	move	A4,B2
	sext	B1,W
	sext	B2,W
	cmp	B1,B2
	jrle	ModX  	;jump to exit loop if Mod start X > Screen End X
 	cmpxy	A9,A4
;	jrxle	ModX  	;jump to exit loop if Mod start X > Screen End X
	jrylt	SkDAdd		;skip if Mod Y Start > BR Y


	move	A3,B1
	move	A11,B2
	sext	B1,W
	sext	B2,W
	cmp	B1,B2
	jrlt	SkDAdd  	;jump to exit loop if Mod start X > Screen End X
	cmpxy	A3,A11
;	jrxlt	SkDAdd		;skip if Mod X End < TL X
	jrylt	SkDAdd		;skip if Mod Y End < TL Y

;	cmpxy	A9,A4
;	jrxlt	SkDAdd  ;use this if modules aren't sorted left to right
				;jump to if Mod start X > Screen End X
;	jrylt	SkDAdd		;skip if Mod Y Start > BR Y

	.IF	IMGBGND
	move	*A8+,A1,W		;A1-index into block ptr table
	sll	5,A1
	addi	BlkTPtrs,A1
	move	*A1,A1,L
	.ELSE
	move	*A8+,A1,L		;A1-ptr to block table
	.ENDIF
	move	A10,A2
	sll	6,A2			;each block is 4 words long
	add	A1,A2			;A2-block table end

	.IF	IMGBGND
	move	*A8+,A5,W		;A5-index into hdr ptr table
	sll	5,A5
	addi	HdrTPtrs,A5
	move	*A5,A5,L
	.ELSE
	move	*A8+,A5,L		;A5-Hdrs
	.ENDIF

	move	*A8+,A10,L		;A10-Pal tbl

	subxy	A9,A3
	subxy	A9,A4

	callr	DISP_ADD
	addxy	A9,A3
	addxy	A9,A4
	jruc	ModLp

ModX:
	mmfm	SP,A0,A3,A4,A7
	rets
***********************************************************************

*********************** D I S P   A D D *******************************
;* This function adds all module blocks in the given range of Module
;* relative coors to the display list.
;* The boundries are included in the group to add.
DISP_ADD:
;***	PARMS:
;       B0 - plane ptr
;	A5 - Background hdr table
;	A7 - bit table for block being on disp list
;	A9 - Module Start Position Y:X
;	A10 - ptr to palette table for new block
;	A1 - Background Block table
;	A2 - End of Background Block table
;	A3 - disp_tl	- relative to the Module start POS
;	A4 - disp_lr	- "
;*** RETURNS nothing

;thrashes A1,A14
	mmtm	SP,A0,A6,A7,A8,A11

	;* Find first universe block with an X coor >= A9
	movx	A3,A0
	sext	A0,W
	subi	WIDEST_BLOCK,A0
;A0 - x coordinate of a block
;A1 - Start of background block table
;A2 - end of block table
	callr	BSrch1stXB
;A0 is now the address of a block
	jrz	DADONE	;* no blocks with gtr Xcoor

	movi	block_size,A6

	move	A0,A8
	sub	A1,A8	;* subtract off start of table
	srl	6,A8	;* divide by block size (64)
	add	A7,A8	;* A8 - ptr to bit which indicates block on list
	subk	8,A8	;* after inc A8, use movb *A8 to load sign bit
	sub	A6,A0	;subtract block size
BScanLP0:
	inc	A8
	add	A6,A0	;* get next block
	;* check if there are no more bgnd blocks
	cmp	A2,A0
	jrge	DADONE

	;* if block already on display list try again
	movb	*A8,A11
	jrn	BScanLP0

	;* check if x to big
	move	*A0(map_x),A11,W
	cmpxy	A3,A11
	jrxge	BScan1	   	;* Jump if BlockX >= TL X

	;* load map header
	move	*A0(map_hdr),A14,W
	sll	20,A14	;* only want bottom 12 bits, top 4 are pal bits
	srl	14,A14	;* leaves B9 << 5 == double long word offset
	MOVE	A14,A1
	add	A5,A14	;* A14 now almost points to block header
	SRL	2,A1	;We must add another word
	ADD	A1,A14	;* A14 now points to block header

	;* check if right end of block hangs onto screen
	move	*A14,A1,W	;A1 is now the width of the block
	add	A11,A1
	cmpxy	A3,A1	;* right end of block doesn't hang on to screen
	jrxlt	BScanLP0		;* jump if Block X+W < TL X

	;* if ycoor to big try again
	move	*A0(map_y),A1,0
	sll	16,A1
	cmpxy	A1,A4
	jrylt BScanLP0		;* Jump if Block Y > BR Y

	;* if ycoor+height to small try again
	move	*A14(map_h),A11,0
	sll	16,A11
	add	A11,A1
	cmpxy	A3,A1
	jrylt BScanLP0		;* Jump if Block Y+H < TL Y

	move	A0,A7
	callr	ADDBLOCK	;Thrashes A1,A14
	jrnc BScanLP0
	jruc	DADONE		;* was unable to add block - no blocks left

BScan1:
	dec	A8		;* bit ptr for block on disp list
	sub	A6,A0		;subtract off block size
BScanLP1:
	inc	A8
	add	A6,A0	;Get next block
	;* check if there are no more bgnd blocks
	cmp	A2,A0
	jrge	DADONE

	;* if block already on display list try again
	movb	*A8,A11
	jrn	BScanLP1

	;* if ycoor to big try again
	move	*A0(map_y),A1,W
	sll	16,A1
	cmpxy	A1,A4
	jrylt BScanLP1		;* Jump if Block Y > BR Y

	;* if ycoor+height to small try again
	move	*A0(map_hdr),A14,W
	sll	20,A14	;* only want bottom 12 bits, top 4 are pal bits
	srl	14,A14	;* leaves A14 << 6 == double long word offset
	MOVE	A14,A11
	add	A5,A14	;* A14 now almost points to block hdr
	SRL	2,A11	;We must add another word
	ADD	A11,A14	;* A14 now points to block hdr
	move	*A14(map_h),A11,W
	sll	16,A11
	add	A11,A1
	cmpxy	A3,A1
	jrylt BScanLP1		;* Jump if Block Y+H < TL Y

	;* if xcoor to big quit
	move	*A0(map_x),A1,W
	cmpxy	A1,A4
	jrxlt DADONE	;* Jump if Block X > BR X

	move	A0,A7
	callr	ADDBLOCK
	jrnc	BScanLP1

DADONE:
	mmfm	SP,A0,A6,A7,A8,A11
	rets
***********************************************************************

***********************************************************************

ADDBLOCK:
;* PARMS
; B0 - plane ptr
; A5 - base of background block hdr
; A7 - ptr to background block
; A8 - ptr to bit map for block on disp list
; A9 - Module Start Position Y:X
; A10 - ptr to palette table for new block

;* Returns carry set if GETOBJ fails...
	;* Also Destroys A1,A14 but they are used as temps in DISP_ADD
	mmtm	SP,A0,A2,A3,A4,A5,A6,A7,A8

	calla	GETOBJ
	jrz  	ADDX

	;* set bit in bitmap for block on list
	movb	*A8,A14
	ori	080h,A14
	movb	A14,*A8
	move	A8,*A0(OPLINK),L ;set OPLINK to be a ptr to the disp list bit

	MOVE	B0,A1			;Grab the plane ptr
	MOVE	*A1(P_YPOS),A3,L
	MOVE	*A1(P_XPOS),A14,L
	SRL	16,A14
	MOVX	A14,A3			;WORLD TOP LEFT [Y,X]

	move	*A7(map_x),A1,L	;A1 ypos:xpos of block from Mod Base
	addxy	A9,A1		;Add in Module Base Position
	MOVE	A1,A6		;TEMP COMBINATION FOR THE DAG-SKI
	SUBXY	A3,A6			;DAG is correct for initial viewing
	move	A1,*A0(OXPOS),W
	srl	16,A1
	move	A1,*A0(OYPOS),W

	move	*A7(map_zflagspal),A4,W	;A4 - map_z,8:map_flags,4:map_pal,4
	move	A4,A3
	srl	8,A3
	sll	24,A3
	srl	8,A3
	move	@ZBASE,a14,L
	add	a14,a3
	move	A3,*A0(OZVAL),L

	move	*A7(map_hdr),A1,W
	movx	A1,A14
	sll	16,A14
	srl	28,A14
	sll	4,A14		;* bits 12-15 are bits 4-7 of pal index

	sll	20,A1		;* bits 0-11 are hdr ptr;
	srl	14,A1		;* A1 = double long word offset into block hdr tbl
	MOVE	A1,A3
	add	A5,A1		;* A1 = Almost ptr to header
	SRL	2,A3		;We must add another word for to make 50H
	ADD	A3,A1		;Now we've got it	

	;A4 - map_z,8:map_DMA_flags,4:map_pal,4
	move	A4,A3
	sll	28,A4		;* last four bits for pal
	srl	28,A4
	add	A14,A4
	sll	5,A4   		;* A4 is lword ptr from pal tbl
	add	A10,A4		;* add in pal tbl
	move	A0,A2		;save A0
	move	*A4,A0,L	;* get palette
;	calla	GETBPAL
	CALLA	GETFPAL
	jrnz	BSetPal
	clr	A0
	MOVE	A0,A5
	CALLA	INC_PALCNT
BSetPal:
;	move	A0,*A2(OPAL),W
*GET FLIP BITS
	movi	08002h,A8	;08000h DMA GO, 2
	srl	4,A3		;* remove palette bits
	sll	30,A3	
	jrc	SKIP0		;* carry bit is the transparency bit
	addk	1,A8
SKIP0:
	srl	26,A3		;* line up flip h,v bits
	add	A3,A8		;A8 - Flags for DMA OP

	MOVE	A0,A3
	move	A2,A0		;restore A0

	;just for now...
	clr	A2
	move	A2,*A0(OID),W

	MOVE	*A1(BSIZE),A5,L		;GRAB THE UNSCALED SIZE        
	MOVE	A5,A4			;MAKE IT THE SCALED SIZE ALSO

	MOVE	*A1(BCTRL),A14,W	;GET BPP AND COMPRESSION       
	OR	A14,A8

	MOVI	001000100H,A2		;NEED THAT SCALE FACTOR
	MOVE	*A1(BSAG),A7,L		;GET THE STARTING ADDRESS      

	SLL	16,A8			;A8 IS IN FULL CONTROL, BOYEEE!

*A1 = OIMG
*A2 = OSCALE
*A3 = OCONST:OPAL
*A4 = OSIZE
*A5 = OUSIZE
*A6 = ODAG
*A7 = OSAG
*A8 = OCTRL:OFSET
	move	A0,A14
	addi	OIMG+020h,A14
	mmtm	A14,A1,A2,A3,A4,A5,A6,A7,A8 ;STUFF IT ALL THE WAY IN

	MOVIM	M_SCRNOBJ,*A0(OFLAGS),W	;WE'LL WORK OUT HIS POSITION
	MOVIM	DUMRETS,*A0(OGUNVECT),L	;TEMPORARY GUN VECTOR FOR NOW
	movb	@BAKPLANE,A14
;	movb	A14,*A0(OPLANE)		;INSPLANE DOES NOT SET OPLANE
	calla	INSPLANE		;B0 plane ptr
	clrc
	MMFM	SP,A0,A2,A3,A4,A5,A6,A7,A8
	rets
ADDX: ;failure to get object
	setc
	MMFM	SP,A0,A2,A3,A4,A5,A6,A7,A8
	rets
**********************************************************************

**********************************************************************
CLRBBIT
;CLR THE BGND BLOCK BIT
	mmtm	SP,A0,A14
	move	*A8(OPLINK),A0,L
	LOCKON	Z
	movb	*A0,A14
	andi	07Fh,A14
	movb	A14,*A0
	clr	A14
	move	A14,*A8(OPLINK),L
	mmfm	SP,A0,A14
	rets
**********************************************************************


************************ D I S P   D E L *****************************
;* This function deletes all objs outside the given range
;* of coors from the display list.
;* The boundries are not included in the group to delete.

;***	PARMS:
;	A8 - bak list
;	A3 - disp_tl
;	A4 - disp_lr
;*** RETURNS nothing
;Thrashes A0,A1,A2,A5,A6,A7,A8,A9,A13,A14	;all of which are pushed by caller

DSP_DEL:
;* USES SIGNED ARITHMETIC
;*** THE SCREEN WRAPS THE -/+ DISCONTINUITY
	move	A3,A13
	sext	A13,W
	move	A4,A2
	sext	A2,W
	

	move	A8,A5		;A5 ptr to start of list
del_loop:
	move	A8,A9	   	; ptr to PREV in A9
	move	*A9,A8,L   	; ptr to NEXT in A8
	cmp	A8,A5
	jreq	del_done	   	;QUIT if at end of list

	movb	*A8(OFLAGS+B_BNODEL-7),A7
	jrn	del_loop

	;if X > Xmax continue
	move	*A8(OXPOS),A7,W
	cmp	A7,A2
	jrlt	DEL_IT		;* jump if BR X < Block X

	move	*A8(OIMG),A1,L
	move	*a8(OIHOFF),a14		; NEW
	add	a14,a1			; NEW
	;if X+width < Xmin continue
	move	*A1(map_w),A6,W    	;A6 block width 
	add	A6,A7
	cmp	A13,A7
	jrlt	DEL_IT		;* jump if TL X > Block X+W

	;if Y > Ymax continue
	move	*A8(OYPOS),A0,W
	sll	16,A0
	cmpxy	A0,A4
	jrylt	DEL_IT		;* jump if BR Y < Block y

	;if Y+height < Ymin continue
	move	*A1(map_h),A7,0		;A7 block height
	sll	16,A7
	add	A7,A0
	cmpxy	A3,A0
	jrylt	DEL_IT		;* jump if TL Y > Block Y+H

	jruc	del_loop

DEL_IT:	;* DELETE the OBJ
	;* unset the on display list bit
	move	*A8(OPLINK),A0,L
	movb	*A0,A7
	andi	07Fh,A7
	movb	A7,*A0
	
	CALLA	ZAP_OBJ		;DO IT MULTI-STYLE
	move	A9,A8		;A9- points to last obj

	CMP	A9,A5		;Are we stuck at the head?
	JRNE	DEL_TRY_NEXT	;BR = No
	MOVE	*A9,A7,L	;Then get the next real object
	CMP	A7,A5		;List empty?
	JREQ	del_done	;BR = Yes
	MOVB	*A7(OFLAGS+B_INUSE-7),A7	;SOMETHING HAPPEN TO OBJECT?
	JRN	del_loop	;BR = no, everyting gonna be alright
	JRUC	del_done

DEL_TRY_NEXT
	movb	*A8(OFLAGS+B_INUSE-7),A7	;SOMETHING HAPPEN TO OBJECT?
	jrn	del_loop	;BR = NO, KEEP GOING

del_done:
	rets


	.IF	IMGBGND
************************************************************************
BLOWADR	.set	254*010000h	;line 254 is a dead line that is not displayed
BLOWADD	.set	254*01000h	;or used in any fashion..
ROMTORAM
*A0 - Start of image ROM memory to read
*A1 - Number of WORDs to read
*A2 - RAM target address
* rets A0 pointing right after the end
	MMTM	SP,A1,A2,A3,A4,A5,A6
	MOVE	A1,A1
	JRZ	WORMX

	PUSHST
	DINT

	;***  SAVE THE STUFF
	MOVE	@DISPLAYON,A3,W
	MOVE	@GAMERASE,A4,W
;	MOVE	@NOPGFLIP,A5,W
	MOVE	@STARSON,A6,W
;	MMTM	SP,A3,A4,A5,A6
	MMTM	SP,A3,A4,A6

	;***  SET THE STUFF
	CLR	A3
	MOVE	A3,@DISPLAYON,W
	MOVE	A3,@GAMERASE,W
;	MOVK	1,A3
;	MOVE	A3,@NOPGFLIP,W
;	PUSH	A0
;	CALLA	SwapPgA
;	PULLQ	A0
	CALLA	DMAQWAIT			;ALLOW Q TO BE BLOWN

	;A0 - ROM
	;A1 - words to read
	;A2 - RAM

NEXTWRM	CMPI	127,A1		    ;find out how much we should decode
	JRGE	REGDMP		    ;127 because 127*4 < 511 (max dma width)
	MOVE	A1,A4
	JRUC	IREGDMP
REGDMP	MOVI	127,A4
IREGDMP	SUB	A4,A1			;words remaining after this iteration

	MOVE	A4,A5
	SLL	2,A5			;WORD CT -> BYTE CT * 2 for YUNIT
	MOVI	BLOWADR,A3
	MOVE	A3,@DMAHORIZ,L		;set the destination
	MOVE	A5,@DMAHSIZE,W		;length of 2*#words to read (#bytes)
	MOVK	1,A3
	MOVE	A3,@DMAVSIZE,W		;thickness of 1	
	MOVE	A0,@DMASAGL,L		;set the origin
	;DMACMAP is dont care
	;DMACONST is dont care
	CLR	A3
	MOVE	A3,@DMAOFFST,W		;offset must be clear
	MOVI	DMAWAL,A3,W		;set control word
	MOVE	A3,@DMACTRL,W		;fire it off

	MOVE	A4,A5
	SLL	5,A5			;increment ROM ptr by length of last
	ADD	A5,A0			;iteration (twice as long)

DMWTA	MOVE	@DMACTRL,A3,W		;wait for it to finish
	JRN	DMWTA

	PUSH	A0
	MOVI	BLOWADD,A0		;get a new destination

WORMLP	MOVE	*A0+,A3,L
	MOVE	A3,A5		;decode routine
	ANDI	00Fh,A5
	MOVE	A3,A6
	ANDI	0F00h,A6
	OR	A6,A5
	MOVE	A3,A6
	SRL	12,A6
	ANDI	00F0h,A6
	OR	A6,A5
	SRL	12,A3
	ANDI	0F000h,A3
	OR	A3,A5
	MOVE	A5,*A2+,W
	DSJ	A4,WORMLP	;decrement on amount decoded
	PULL	A0

	MOVE	A1,A1		;do we still have words left?
	JRGT	NEXTWRM

	;*** RESTORE THE LOST SOUL
;	MMFM	SP,A3,A4,A5,A6
	MMFM	SP,A3,A4,A6
	MOVE	A3,@DISPLAYON,W
	MOVE	A4,@GAMERASE,W
;	MOVE	A5,@NOPGFLIP,W
	MOVE	A6,@STARSON,W

	POPST
WORMX
	MMFM	SP,A1,A2,A3,A4,A5,A6
	RETS
************************************************************************





************************************************************************
InitBTbl:
	mmtm	SP,A0,A1,A2

;*** INITIALIZE  BGNDTBL INDEX AND CLEAR OUT BLK+HDR PTR TABLES
	movi	BgndTbls,A0
	move	A0,@BgdTIndx,L

	clr	A1

	movi	HdrTPtrs,A0
	movi	MAXHDRTBLS,A2
ClrHdrs	move	A1,*A0+,L
	dsjs	A2,ClrHdrs

	movi	BlkTPtrs,A0
	movi	MAXBLKTBLS,A2
ClrBlks	move	A1,*A0+,L
	dsjs	A2,ClrBlks

	mmfm	SP,A0,A1,A2
	rets
************************************************************************

************************************************************************
AlocBTbl:
;A1 # words -> A2 ptr to ram space alloced
	PUSH	A1
	move	@BgdTIndx,A2,L
	sll	4,A1
	add	A2,A1
	cmpi	BgndTblX,A1
	LOCKON	GE
	move	A1,@BgdTIndx,L
	PULLQ	A1
	rets
************************************************************************

************************************************************************
DnLdMod:
;A0 ptr to a MODULE
;DOWN LOADS from IMAGE ROM to RAM:  HEADER TABLE, BLOCK TABLE
	mmtm	SP,A0,A1,A2,A3,A4,A5
	move	A0,A3

	;**** CHECK TO DOWN LOAD THE HEADERS ****
	move	*A3(mod_hindx),A4,W
	cmpi	MAXHDRTBLS,A4
	LOCKON	GE
	sll	5,A4
	move	A4,A5
	addi	HdrTPtrs,A5,L
	move	*A5,A2,L
	jrnz	SkLdHdrT	;IF HdrTPtr SET, HDRS ALREADY LOADED
	addi	HDRTBLPTRS,A4	;hdr table pointers
	move	*A4,A0,L	;Get Ptr to hdr tbl in IMAGE ROM
	movk	1,A1		;JUST READ THE COUNT
	movi	TMPWORD,A2
	callr	ROMTORAM	;get total # of headers
	move	*A2,A1,W	;
	;ALLOCATE SPACE IN BGNDTBLS
	sll	2,A1		;A HEADER IS 4 WORDS LONG
	callr	AlocBTbl	;A1 # words -> A2 ptr to ram space alloced
	move	A2,*A5,L	;STORE PTR TO RAM IN HdrTPtrs
	callr	ROMTORAM	;download the headers
SkLdHdrT

	;**** CHECK TO DOWN LOAD THE BLOCKS ****
	move	*A3(mod_bindx),A4,W
	cmpi	MAXBLKTBLS,A4
	LOCKON	GE
	sll	5,A4
	move	A4,A5
	addi	BlkTPtrs,A5,L
	move	*A5,A2,L
	jrnz	SkLdBlkT	;IF BlkTPtr SET, HDRS ALREADY LOADED
	addi	BLKTBLPTRS,A4	;block table pointers
	move	*A4,A0,L	;Get Ptr to blk tbl IMAGE ROM
 	;ALLOCATE SPACE IN BGNDTBLS
	move	*A3(mod_blkct),A1,W
	sll	2,A1		;A BLOCK IS 4 WORDS LONG
	callr	AlocBTbl	;A2 # words -> A2 ptr to ram space alloced
	move	A2,*A5,L	;STORE PTR TO RAM IN HdrTPtrs
	callr	ROMTORAM	;download the headers
SkLdBlkT
	mmfm	SP,A0,A1,A2,A3,A4,A5
	rets
************************************************************************
DnLdMods:
;A0 ptr to a MODULE LIST
;* find end of module list
	mmtm	SP,A0,A1
	move	A0,A1
DnLdLp:
	move	*A1,A0,L
	cmpi	-1,A0		;looking for 0FFFFFFFFh
	jreq	DLModsX
	callr	DnLdMod
	addi	64,A1		;Look at next Module
	jruc	DnLdLp
DLModsX
	mmfm	SP,A0,A1
	rets
************************************************************************
	.ENDIF


	.END
