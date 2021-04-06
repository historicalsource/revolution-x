	.MLIB	"GXMACS.LIB"
	.FILE	"GXUTIL.ASM"
	.TITLE	" <<< GENERATION X ---- GENERAL PURPOSE SUBROUTINES >>>"
	.WIDTH	132
	.OPTION	B,D,L
	.MNOLIST

**************************************************************************
*								         *
* 	COPYRIGHT (C) 1992 MIDWAY MANUFACTURING COMPANY.		 *
* 		       ALL RIGHTS RESERVED.				 *
*								         *
**************************************************************************

*	GET THE SYSTEM STUFF
	.INCLUDE	"GX.INC"
	.INCLUDE	"GXUNZIP.INC"
	.INCLUDE	"IMGTBL.GLO"

	.EVEN
	.TEXT
* SYMBOLS IN HERE
	.DEF	PASTE_ON_DAMAGE_OFFSET, PASTE_ON_DAMAGE_OFFSET_XYZ
	.DEF	FragCenterCoors, PreFrag_Box_Offset

***** from GXD.ASM
	.REF	WORLD_GRNDOFF

**************************************************************************
*                                                                        *
* CLRPDATA - CLEAR THE PDATA AREA OF A PROCESS BLOCK			 *
* A13 = PTR TO PROCESS BLOCK						 *
*                                                                        *
**************************************************************************
CLRPDATA
	MMTM	SP,A1,A6,A14
	MOVE	A13,A14
	CLR	A1
	ADDI	PDATA,A14
	MOVI	(PSDATA-PDATA)/16,A6
CLRSHL
	SRL	1,A6
	JRNC	CLRPDL
	MOVE	A1,*A14+,W	;STUFF THE ODD WORD	
CLRPDL
	MOVE	A1,*A14+,L		
	DSJS	A6,CLRPDL
	MMFM	SP,A1,A6,A14
	RETS

**************************************************************************
*                                                                        *
* MIDPOINT - RETURN THE MIDPOINT BETWEEN TWO POINTS			 *
* A0 = [Y,X] POINT 0							 *
* A1 = [Y,X] POINT 1							 *
* RETURNS								 *
* A0 = [Y,X] MIDPOINT							 *
*                                                                        *
**************************************************************************
MIDPOINT
	PUSH	a1
	addxy	a1,a0
	sra	1,a0
	movx	a0,a1
	sll	17,a1
	sra	17,a1
	movx	a1,a0
	PULLQ	a1
	rets
	
**************************************************************************
*                                                                        *
* GET BOTTOM Y OF AN OBJECT						 *
* A8 = OBJECT BLOCK PTR							 *
* RETURN(S)								 *
* A1 = 32 BIT UNIV BOTTOM Y						 *
* STATUS SET ACCORDING TO THE BOTTOM Y					 *
*NOTE: MAKE SURE OBLOCK IS INIT'D BEFORE CALLING			 *
*                                                                        *
**************************************************************************
GETBOTY
	PUSH	A2
	MOVE	*A8(OYPOS),A1,W		;GET Y POSITION
	move	*A8(OUSIZEY),A14,W
	move	*a8(OUANIOFFY),a2,W
	sub	a2,a14		; pixels from anim pt to bottom
	sll	15,a14		; from pixels to world
	add	a14,a1		; world Y of bottom
	PULLQ	A2
	RETS



**************************************************************************
*								         *
* GET_TSUL - TRUE SOUNDS UV LIBERTY					 *
*								         *
* GET THE TOTAL SIZE AND MOST UPPER LEFT SCREEN COORDINATE OF AN	 *
* OBJECT (HANDLES MULTIPART ALSO) IN UNIVERSE COORDINATES		 *
*								         *
* IN:									 *
* 									 *
* A8 = OBJECT								 *
* 									 *
* OUT:									 *
* 									 *
* A0 = LEFT X								 *
* A1 = UPPER Y								 *
* A2 = X SIZE								 *
* A3 = Y SIZE								 *
*								         *
**************************************************************************

GET_TSUL
	MMTM	SP,A4,A5,A6,A7,A8,A9,A10
	CALLA	GET_HEAD_PART

	MOVE	*A8(OCTRL),A14,W
	MOVE	*A8(OXVAL),A0,L
	MOVE	*A8(OYVAL),A1,L
	MOVE	*A8(OIMG),A3,L
	MOVE	*A3(IANIOFF),A4,L
	MOVE	A4,A5
	SEXT	A4,W
	SLL	15,A4			;CONVERT TO WORLD X
	SRA	16,A5
	SLL	15,A5			;CONVERT TO WORLD Y

	MOVE	*A3(ISIZE),A2,L
	MOVE	A2,A3
	SEXT	A2,W
	SLL	15,A2			;CONVERT TO WORLD X
	SRA	16,A3
	SLL	15,A3			;CONVERT TO WORLD Y

	BTST	B_FLIPH,A14
	JRZ	GTSUL_GOX		;BR=WE'RE NOT H-FLIPPED
	ADD	A4,A0			;DEFAULT LEFT X
	NEG	A2
	ADD	A0,A2			;DEFAULT RIGHT X
	SWAP	A0,A2			;SWAP 'EM
	JRUC	GTSUL_CHECK_HEADY
GTSUL_GOX
	SUB	A4,A0			;DEFAULT LEFT X
	ADD	A0,A2			;DEFAULT RIGHT X
GTSUL_CHECK_HEADY
	BTST	B_FLIPV,A14
	JRZ	GTSUL_GOY		;BR=WE'RE NOT V-FLIPPED
	ADD	A5,A1			;DEFAULT UPPER Y
	NEG	A3
	ADD	A1,A3			;DEFAULT LOWER Y
	SWAP	A1,A3			;SWAP 'EM
	JRUC	GTSUL_LUPE
GTSUL_GOY
	SUB	A5,A1			;DEFAULT UPPER Y
	ADD	A1,A3			;DEFAULT LOWER Y
GTSUL_LUPE
	MOVE	*A8(OPARTS),A8,L
	JRZ	GTSUL_DONE		;BR = NO MORE PARTS

	MOVE	*A8(OCTRL),A14,W
	MOVE	*A8(OXVAL),A4,L
	MOVE	*A8(OYVAL),A5,L
	MOVE	*A8(OIMG),A10,L
	MOVE	*A10(IANIOFF),A6,L
	MOVE	A6,A7
	SEXT	A6,W
	SLL	15,A6			;CONVERT TO WORLD X
	SRA	16,A7
	SLL	15,A7			;CONVERT TO WORLD Y

	MOVE	*A10(ISIZE),A9,L
	MOVE	A9,A10
	SEXT	A9,W
	SLL	15,A9			;CONVERT TO WORLD X
	SRA	16,A10
	SLL	15,A10			;CONVERT TO WORLD Y

	BTST	B_FLIPH,A14
	JRZ	GTSUL_PART_GOX		;BR=WE'RE NOT H-FLIPPED
	ADD	A6,A4			;LEFT X
	NEG	A9
	ADD	A4,A9			;RIGHT X
	SWAP	A4,A9
	JRUC	GTSUL_PART_CHECKY
GTSUL_PART_GOX
	SUB	A6,A4			;LEFT X
	ADD	A4,A9			;RIGHT X
GTSUL_PART_CHECKY
	BTST	B_FLIPV,A14
	JRZ	GTSUL_PART_GOY		;BR=WE'RE NOT V-FLIPPED
	ADD	A7,A5			;UPPER Y
	NEG	A10
	ADD	A5,A10			;LOWER Y
	SWAP	A5,A10
	JRUC	GTSUL_PART_CHECK
GTSUL_PART_GOY
	SUB	A7,A5			;UPPER Y
	ADD	A5,A10			;LOWER Y
GTSUL_PART_CHECK
	CMP	A0,A4
	JRGE	GTSUL_NOULX		;BR = LEAVE LEFT X ALONE
	MOVE	A4,A0
GTSUL_NOULX
	CMP	A1,A5	
	JRGE	GTSUL_NOULY		;BR = LEAVE UPPER Y ALONE
	MOVE	A5,A1
GTSUL_NOULY
	CMP	A2,A9
	JRLE	GTSUL_NOLRX		;BR = LEAVE RIGHT X ALONE
	MOVE	A9,A2
GTSUL_NOLRX
	CMP	A3,A10
	JRLE	GTSUL_LUPE		;BR = LEAVE LOWER Y ALONE
	MOVE	A10,A3
	JRUC	GTSUL_LUPE	
GTSUL_DONE
	SUB	A0,A2			;COMPUTE X SIZE
	SUB	A1,A3			;COMPUTE Y SIZE
	MMFM	SP,A4,A5,A6,A7,A8,A9,A10
	RETS

**************************************************************************
*                                                                        *
* GET_CPNTU - RETURNS THE CENTER XY UNIVERSE POSITION OF A GIVEN IMAGE	 *
* NOTE: ANIMATION POINT MUST BE IN THE CENTER OF THE OBJECT		 *
*                                                                        *
* PASS:                                                                  *
* A8 = IMAGE OBLOCK							 *
* RETURN(S)								 *
* A2 = CENTER X								 *
* A1 = CENTER Y								 *
*                                                                        *
**************************************************************************
GET_CPNTU
	MMTM	SP,A0,A3
	CALLR	GET_TSUL
	CALLR	GETCENTU
	MMFM	SP,A0,A3
	RETS

**************************************************************************
*                                                                        *
* GETCPNTU - RETURNS THE CENTER XY UNIVERSE POSITION OF A GIVEN IMAGE	 *
*		A0 VERSION.						 *
* A0 = IMAGE OBLOCK							 *
* RETURN(S)								 *
* A2 = CENTER X								 *
* A1 = CENTER Y								 *
*                                                                        *
**************************************************************************
GETCPNTU	
	PUSH	A8
	MOVE	A0,A8
	CALLR	GET_CPNTU
	PULLQ	A8
	RETS

**************************************************************************
*								         *
* GET_TSUL_SCRN - TRUE SOUNDS UV LIBERTY				 *
*								         *
* GET THE TOTAL SIZE AND MOST UPPER LEFT SCREEN COORDINATE OF AN	 *
* OBJECT (HANDLES MULTIPART ALSO) IN SCREEN COORDINATES			 *
*								         *
* IN:									 *
* 									 *
* A8 = OBJECT								 *
* 									 *
* OUT:									 *
* 									 *
* A0 = UPPER LEFT [Y, X]						 *
* A1 = TOTAL SIZE [Y, X]						 *
*								         *
**************************************************************************

GET_TSUL_SCRN
	MMTM	SP,A2,A8
	CALLA	GET_HEAD_PART
	MOVE	*A8(ODAG),A0,L		;ALWAYS THE UPPER LEFT
	MOVE	*A8(OSIZE),A2,L
	MOVE	A2,A1
	ADDXY	A0,A1
GTSULS_LUPE
	MOVE	*A8(OPARTS),A8,L
	JRZ	GTSULS_DONE		;BR = NO MORE PARTS
	MOVE	*A8(ODAG),A14,L
	CMPI	02000200H,A14
	JREQ	GTSULS_LUPE		;BR = OBJECT JUST CREATED
	CMPXY	A0,A14
	JRXGE	GTSULS_NOULX		;BR = LEAVE LEFT X ALONE
	MOVX	A14,A0
GTSULS_NOULX
	JRYGE	GTSULS_NOULY		;BR = LEAVE UPPER Y ALONE
	MOVY	A14,A0
GTSULS_NOULY
	MOVE	*A8(OSIZE),A2,L
	ADDXY	A2,A14
	CMPXY	A1,A14
	JRXLE	GTSULS_NOLRX		;BR = LEAVE RIGHT X ALONE
	MOVX	A14,A1
GTSULS_NOLRX
	JRYLE	GTSULS_LUPE		;BR = LEAVE LOWER Y ALONE
	MOVY	A14,A1
	JRUC	GTSULS_LUPE	
GTSULS_DONE
	SUBXY	A0,A1
	MMFM	SP,A2,A8
	RETS

**************************************************************************
*								         *
* GET_CPNT_SCRNREL - RETURNS THE SCREEN RELATIVE CENTER XY POSITION	 *
* 		OF A GIVEN IMAGE.					 *
* A8 = IMAGE OBLOCK							 *
* RETURN(S)								 *
* A3 = SCREEN RELATIVE CENTER Y:CENTER X				 *
*								         *
**************************************************************************
GET_CPNT
	PUSH	A3
	CALLR	GET_CPNT_SCRNREL
	MOVE	A1,A3
	PULL	A3
	RETS

GET_CPNT_SCRNREL
	PUSH	A0
	CALLR	GET_TSUL_SCRN
	CALLR	GETCENT
	MOVE	A1,A3
	SLL	16,A0
	MOVY	A0,A3
	PULLQ	A0
	RETS

**************************************************************************
*                                                                        *
* GETCPNT - RETURNS THE CENTER XY POSITION OF A GIVEN IMAGE		 *
*		A0 VERSION.						 *
* A0 = IMAGE OBLOCK							 *
* RETURN(S)								 *
* A1 = CENTER Y:CENTER X						 *
*                                                                        *
**************************************************************************
GETCPNT	
	PUSH	A8
	MOVE	A0,A8
	CALLR	GET_CPNT
	PULLQ	A8
	RETS

**************************************************************************
*								         *
* GET_BOTTOM_MID - GET THE MID POINT OF THE BOTTOM LINE OF AN IMAGE	 *
* A8 = PTR TO IMAGE							 *
* RETURNS:								 *
* A1 = [Y,X] BOTTOM LINE MIDPOINT					 *
*								         *
**************************************************************************
GET_BOTTOM_MID:
	PUSH	A0
	CALLR	GETBOTY
	MOVE	A1,A0
	CALLR	GET_CPNT
	SLL	16,A0
	MOVY	A0,A1			;GET THE BOTTOM MIDPOINT
	PULL	A0
	RETS

**************************************************************************
*								         *
* GET_INIT_CPNT - GET THE CENTER POINT OF AN OBJECT STORED WITHIN AN	 *
* 	INITIALIZATION TABLE WITH RESPECT TO ITS CURRENT ANIMATION	 *
* 	POINT.								 *
* A8 = PTR TO OBJECT							 *
* RETURNS:								 *
* A1 = [Y,X] CENTER POINT						 *
*								         *
**************************************************************************
GET_INIT_CPNT:
	MMTM	SP,A0,A2,A3,A5,A6
	CALLA	GETANIXY		;OBJECT ANI PNT, A2=Y A3=X
	SRL	16,A3
	MOVX	A3,A2			;PACK [Y,X] INTO A2
	MOVE	*A4(NEWIIMG),A5,L	;AND NOW THE IMAGE PTR
	MOVE	*A5(IANIOFF),A6,L
	SUBXY	A6,A2			;FIND CORRECT UPPER LEFT CORNER
	MOVE	A2,A0
	MOVE	*A5(ISIZE),A1,L
	CALLA	GETCENT			;GET THE CENTER PNT OF THIS BOX
	SLL	16,A0
	MOVY	A0,A1			;PACK IT UP IN A1
	MMFM	SP,A0,A2,A3,A5,A6
	RETS



**************************************************************************
* GETCENTU - RETURNS THE CENTER POINT (UNIVERSE) OF A BOX      		 *
*								         *
* PASS:									 *
* A0 = LEFT X								 *
* A1 = UPPER Y								 *
* A2 = X SIZE								 *
* A3 = Y SIZE								 *
*								         *
* RETURNS:								 *
* A2 = CENTER X								 *
* A1 = CENTER Y								 *
*								         *
* DESTROYS:								 *
* A3									 *
*								         *
**************************************************************************
GETCENTU
	SRL	1,A2
	ADD	A0,A2
	SRL	1,A3
	ADD	A3,A1
	RETS


**************************************************************************
*                                                                        *
* GETCENT - RETURNS THE CENTER POINT OF A BOX		      		 *
* A0 = UPPER LEFT Y:UPPER LEFT X					 *
* A1 = Y_SIZE:X_SIZE   							 *
* RETURN(S)								 *
* A0 = CENTER Y(LSW)							 *
* A1 = CENTER X(LSW)							 *
*                                                                        *
**************************************************************************
GETCENT
	MOVE	A2,-*SP,L
	MOVY	A1,A2
	SRL	17,A2		;YSIZE/2
	SLL	16,A2		;BACK TO Y HALF
	SLL	16,A1		;CLEAR Y
	SRL	17,A1		;XSIZE/2
	MOVY	A2,A1
	ADDXY	A1,A0		;OFFSET TO CENTER
	CLR	A1
	MOVX	A0,A1		;RETURN THESE IN USEFUL POSITIONS
	SRL	16,A0
	MOVE	*SP+,A2,L
	RETS

**************************************************************************
*								         *
* SLINEVEL_LOAD - USE SLINEVEL TO GET VELOCITIES FOR AN OBJECT AND	 *
* 		LOAD THEM INTO THAT OBJECT.				 *
* SAME AS SLINEVEL INPUTS AND						 *
* A8 = PTR OBJECT							 *
* RETURNS								 *
* 	NOTHING								 *
*								         *
**************************************************************************
SLINEVEL_LOAD
	MMTM	SP,A1,A2
	CALLR	SLINEVEL
	MOVE	A1,*A8(OXVEL),L
	MOVE	A2,*A8(OYVEL),L
	MMFM	SP,A1,A2
	RETS

**************************************************************************
*                                                                        *
* SLINEVEL - GET THE X & Y VELOCITIES TO MAKE AN OBJECT TRAVEL		 *
* 	   FROM PNT. A TO PNT. B ALONG THE SHORTEST PATH.		 *
* A2 = PNT. A [Y,X] POSITION						 *
* A3 = PNT. B [Y,X] POSITION						 *
* A4 = DURATION(# OF TICKS TO GET FROM A TO B)				 *
* RETURNS:								 *
* A1 = X VEL (32 BITS)							 *
* A2 = Y VEL (32 BITS)							 *
* NOTE: DON'T CALL WITH THE A=B, IT'S A WAIST OF TIME AND UNDEFINED.	 *
*                                                                        *
**************************************************************************
SLINEVEL
	PUSH	A3
	SUBXY	A2,A3		;GET THE DIFFERENCE
	MOVX	A3,A1		;A1 = X DISTANCE
	SRL	16,A3
	SLL	16,A3		;CLEAR OUT THE X PART
	DIVS	A4,A3		;A3 = Y VELOCITY(32 BITS)
	SLL	16,A1
	DIVS	A4,A1		;A1 = X VELOCITY(32 BITS)
	MOVE	A3,A2		;RETURN Y VEL HERE FOR CONSISTENCY
	PULLQ	A3
	RETS

**************************************************************************
*								         *
* SLINEVEL_LOAD_2D - USE SLINEVEL TO GET VELOCITIES FOR AN OBJECT AND	 *
* 		LOAD THEM INTO THAT OBJECT.				 *
* SAME AS SLINEVEL_2D INPUTS						 *
* A8 = PTR OBJECT							 *
* RETURNS								 *
* 	NOTHING								 *
*								         *
**************************************************************************
SLINEVEL_LOAD_2D
	MMTM	SP,A1,A3
	CALLR	SLINEVEL_2D
	MOVE	@XSCROLL,A14,L
	ADD	A14,A1			;COMPENSATE FOR XSCROLL
	MOVE	A1,*A8(OXVEL),L
	MOVE	@YSCROLL,A14,L
	SUB	A14,A3			;		YSCROLL
	MOVE	A3,*A8(OYVEL),L
	MMFM	SP,A1,A3
	RETS

**************************************************************************
*                                                                        *
* SLINEVEL_2D - GET THE X & Y VELOCITIES TO MAKE AN OBJECT TRAVEL	 *
* 	   FROM PNT. A TO PNT. B ALONG THE SHORTEST PATH.		 *
* A1 = PNT. B X POSITION (32 BITS)					 *
* A2 = PNT. A X POSITION (32 BITS)					 *
* A3 = PNT. B Y POSITION (32 BITS)					 *
* A4 = PNT. A Y POSITION (32 BITS)					 *
* A5 = DURATION(# OF TICKS TO GET FROM A TO B)				 *
* RETURNS:								 *
* A1 = X VEL (32 BITS)							 *
* A3 = Y VEL (32 BITS)							 *
* NOTE: DON'T CALL WITH THE A=B, IT'S A WAIST OF TIME AND UNDEFINED.	 *
*                                                                        *
**************************************************************************
SLINEVEL_2D
	SUB	A2,A1		;GET THE DIFFERENCES
	SUB	A4,A3		
	DIVS	A5,A1		;A1 = X VELOCITY (32 BITS)
	DIVS	A5,A3		;A3 = Y VELOCITY (32 BITS)
	RETS

**************************************************************************
*								         *
* SLINEVEL_LOAD_3D - USE SLINEVEL_3D TO GET VELOCITIES FOR AN OBJECT AND *
* 		LOAD THEM INTO THAT OBJECT.				 *
* SAME AS SLINEVEL_3D INPUTS AND					 *
* A8 = PTR OBJECT							 *
* RETURNS								 *
* 	NOTHING								 *
*								         *
**************************************************************************
SLINEVEL_LOAD_3D
	MMTM	SP,A1,A2,A3,A4,A5,A6
	CALLR	SLINEVEL_3D
;	MOVI	XSCROLL,A14
;	MMFM	A14,A2,A4,A6
;	sra	ZFRAC,a2		; compensate for new fraction
;	ADD	A6,A1			;COMPENSATE FOR XSCROLL
;	SUB	A4,A3			;		YSCROLL
;	ADD	A2,A5			;		ZSCROLL
	MOVE	A1,*A8(OXVEL),L
	MOVE	A3,*A8(OYVEL),L
	MOVE	A5,*A8(OZVEL),L
	MMFM	SP,A1,A2,A3,A4,A5,A6
	RETS

**************************************************************************
*                                                                        *
* SLINEVEL_3D - GET THE X & Y & Z VELOCITIES TO MAKE AN OBJECT TRAVEL	 *
* 	   FROM PNT. A TO PNT. B ALONG THE SHORTEST PATH.		 *
* A1 = PNT. B X POSITION (32 BITS)					 *
* A2 = PNT. A X POSITION (32 BITS)					 *
* A3 = PNT. B Y POSITION (32 BITS)					 *
* A4 = PNT. A Y POSITION (32 BITS)					 *
* A5 = PNT. B Z POSITION (32 BITS)					 *
* A6 = PNT. A Z POSITION (32 BITS)					 *
* A7 = DURATION(# OF TICKS TO GET FROM A TO B)				 *
* RETURNS:								 *
* A1 = X VEL (32 BITS)							 *
* A3 = Y VEL (32 BITS)							 *
* A5 = Z VEL (32 BITS)							 *
* NOTE: DON'T CALL WITH THE A=B, IT'S A WAIST OF TIME AND UNDEFINED.	 *
*                                                                        *
**************************************************************************
SLINEVEL_3D
	SUB	A2,A1		;GET THE DIFFERENCES
	SUB	A4,A3		
	SUB	A6,A5		
	DIVS	A7,A1		;A1 = X VELOCITY (32 BITS)
	DIVS	A7,A3		;A3 = Y VELOCITY (32 BITS)
	DIVS	A7,A5		;A5 = Z VELOCITY (32 BITS)
	RETS


**************************************************************************
*								         *
* X_ETA - ROUTINE TO FIGURE THE NUMBER OF TICKS IT WILL TAKE TO COVER	 *
* 	THE X DISTANCE FROM PNT. A TO PNT B.				 *
* 	THE RESULTING VELOCITY IS SIGNED:				 *
* 		POSITIVE IF PNT. A < PNT. B				 *
* 		NEGATIVE IF PNT. A > PNT. B				 *
* A1 = ABSOLUTE X VEL (32 BITS)						 *
* A2 = PNT. A [Y,X] POSITION						 *
* A3 = PNT. B [Y,X] POSITION						 *
* RETURNS:								 *
* 	 Z = TIME IN TICKS IS LESS THAN ONE				 *
* 		A1 = UNCHANGED						 *
* 		A4 = 0							 *
* 	NZ = IT WILL TAKE 1 OR MORE TICKS				 *
* 		A1 = VELOCITY OF CORRECT SIGN				 *
* 		A4 = DURATION IN TICKS					 *
*								         *
**************************************************************************
X_ETA
	PUSH	A3
	SUBXY	A2,A3		;GET THE DIFFERENCE
	SLL	16,A3
	DIVS	A1,A3		;A3 = WE NOW HAVE A TIME
	JRNN	XETA_NN		;BR = NUMBER IS OK
	NEG	A3		;NEGATE THE TICKS FOR REAL
	NEG	A1		;NEGATE THE VELOCITY
XETA_NN
	MOVE	A3,A4		;RETURN CORRECTLY
	PULL	A3
	RETS

**************************************************************************
*								         *
* CK_OBJ_CENT - DETERMINE IF CENTER POINTS OF TWO OBJECTS ARE CLOSE.	 *
* A0 = ONE OBJECT							 *
* A8 = THE OTHER OBJECT							 *
* RETURNS:								 *
* 	NC = NOT EVEN CLOSE						 *
* 	 C = CLOSE							 *
*								         *
**************************************************************************
CK_OBJ_CENT:
	MMTM	SP,A1,A2,A3,A8
	CALLR	GET_CPNT			;CENTER POINT OF FIRST OBJECT
	MOVE	A1,A3
	MOVE	A0,A8
	CALLR	GET_CPNT			;AND CENTER POINT OF THE SECOND
	MOVI	[8,8],A2		;FIX THE RANGE	
	CALLR	PNT_IN_RANGE
	MMFM	SP,A1,A2,A3,A8
	RETS

**************************************************************************
*								         *
* CK_BOTTOM_CENT - DETERMINE IF BOTTOM MID POINT OF ONE OBJECT IS	 *
*		CLOSE TO THE CENTER OF ANOTHER OBJECT.			 *
* A0 = ONE OBJECT							 *
* A8 = THE OTHER OBJECT							 *
* RETURNS:								 *
* 	NC = NOT EVEN CLOSE						 *
* 	 C = CLOSE							 *
*								         *
**************************************************************************
CK_BOTTOM_CENT:
	MMTM	SP,A0,A1,A2,A3,A8
	CALLR	GET_CPNT			;GET THE CENTER POINT
	MOVE	A1,A3
	MOVE	A0,A8
	CALLR	GETBOTY
	MOVE	A1,A0
	CALLR	GET_CPNT
	SLL	16,A0
	MOVY	A0,A1			;GET THE BOTTOM MIDPOINT
	MOVI	[6,6],A2		;FIX THE RANGE	
	CALLR	PNT_IN_RANGE
	MMFM	SP,A0,A1,A2,A3,A8
	RETS

**************************************************************************
*                                                                        *
* PNT_IN_RANGE - SEE IF ONE POINT IS IN A GIVEN [Y,X] RANGE OF ANOTHER	 *
* 	POINT.								 *
* A1 = [Y,X] POINT TO CHECK						 *
* A2 = [Y RANGE,X RANGE]						 *
* A3 = [Y,X] CENTER POINT OF RANGE					 *
* RETURNS:								 *
* 	NC = NOT IN RANGE						 *
* 	 C = IN RANGE							 *
*                                                                        *
**************************************************************************
PNT_IN_RANGE:
	MMTM	SP,A2,A3
	CALLR	MAKEBOX		;MAKE A RANGE AREA
	CALLR	PNTINBOX
	MMFM	SP,A2,A3
	RETS

**************************************************************************
*                                                                        *
* MAKEBOX - GIVEN THE CENTER POINT OF A BOX AND HALF THE LENGTH AND	 *
* 	WIDTH THIS FUNCTION WILL RETURN THE UL AND LR OF A BOX		 *
* A2 = [HALF HEIGHT,HALF WIDTH]						 *
* A3 = CENTER POINT OF BOX						 *
* RETURNS:								 *
* A2 = UPPER LEFT [Y,X] OF BOX						 *
* A3 = LOWER RIGHT [Y,X] OF BOX						 *
*                                                                        *
**************************************************************************
MAKEBOX:
	PUSH	A1
	MOVE	A3,A1
	ADDXY	A2,A3		;MAKE LOWER RIGHT
	SWAP	A1,A2
	SUBXY	A1,A2		;MAKE UPPER LEFT
	PULL	A1
	RETS

**************************************************************************
*                                                                        *
* PNTINBOX - SEE IF THE GIVEN POINT IS CONTAINED WITHIN OR ON THE	 *
* 		THE EDGE OF A GIVEN BOX.				 *
* A1 = [Y,X] POINT							 *
* A2 = UPPER LEFT [Y,X] OF BOX						 *
* A3 = LOWER RIGHT [Y,X] OF BOX						 *
* RETURNS:								 *
*        NC = NOT CONTAINED						 *
* 	  C = CONTAINED							 *
*                                                                        *
**************************************************************************
PNTINBOX:
	CMPXY	A2,A1
	JRXLT	PNTNOTINBOX
	JRYLT	PNTNOTINBOX
	CMPXY	A3,A1
	JRXGT	PNTNOTINBOX
	JRYGT	PNTNOTINBOX
	SETC
	RETS
PNTNOTINBOX:
	CLRC
	RETS
**************************************************************************
*								         *
* CHKRANGE - CHECK TO SEE IF AN UNSIGNED 32 BIT VALUE IS IN A		 *
* 		GIVEN RANGE (INCLUSIVE)					 *
* A1 = #								 *
* A2 = LOWER BOUND							 *
* A3 = UPPER BOUND							 *
* RETURN(S)								 *
* CARRY CLEAR (JxNC) = OUT OF RANGE					 *
* CARRY SET   (JxC)  = IN RANGE						 *
*								         *
**************************************************************************
CHKRANGE
	CMP	A2,A1			;CHECK LOWER BOUND
	JRLO	OUTOFRNG		;BR = # TOO LOW
	CMP	A3,A1
	JRHI	OUTOFRNG		;BR = # TOO HIGH

	SETC				;# IN RANGE, YEAH!
	RETS
OUTOFRNG
	CLRC
	RETS

**************************************************************************
*                                                                        *
* ALIGNOBJ - ALIGN OBJECT FROM PTA. TO PTB.				 *
* A0 = POINT B [Y,X]							 *
* A1 = POINT A [Y,X]							 *
* A8 = PTR TO OBJECT							 *
*                                                                        *
**************************************************************************
ALIGNOBJ
	MMTM	SP,A0,A1,A2
	SUBXY	A1,A0
	MOVY	A0,A1
	SRA	16,A1		;ISOLATE THE Y COMPONENT
	SEXT	A0		;AND THE X
	MOVE	*A8(OXPOS),A2,W
	ADD	A0,A2
	SLL	16,A2	       	;ZERO ALL FRACTIONALS
	MOVE	A2,*A8(OXVAL),L
	MOVE	*A8(OYPOS),A2,W
	ADD	A1,A2
	SLL	16,A2	       	;ZERO ALL FRACTIONALS
	MOVE	A2,*A8(OYVAL),L
	MMFM	SP,A0,A1,A2
	RETS

**************************************************************************
*								         *
* CENTEROBJ - CENTER AN OBJECT ON A POINT.				 *
* A0 = POINT TO CENTER UPON						 *
* A8 = OBJECT								 *
*								         *
**************************************************************************
CENTEROBJ:
	PUSH	A1
	CALLR	GET_CPNT
	CALLR	ALIGNOBJ
	PULL	A1
	RETS

**************************************************************************
*                                                                        *
* MYOINIT - INITIALIZE SUPPLEMENTAL OBJECT LIST HEADERS			 *
*                                                                        *
**************************************************************************
MYOINIT
	MMTM	SP,A0,A1,A2,A3,A4,A5
   
	PUSHST

	CALLA	CLRPAL

	MOVI	T2FIXED,A0
	CALLA	GETFPAL			;GET THE FIXED FOREGROUND PALETTE

	MOVI	REDPLAYR,A0
	CALLA	GETFPAL			;FIX THE PLAYER 1 PALETTE

	MOVI	YELPLAYR,A0		
	CALLA	GETFPAL			;FIX THE PLAYER 2 PALETTE

	MOVI	BLUPLAYR,A0
	CALLA	GETFPAL			;FIX THE PLAYER 3 PALETTE

	MOVI	TEXTPAL,A0		;FIX THE TEXT PALETTE
	CALLA	GETFPAL			;IF YOU CHANGE THIS, CHANGE TEXT_PAL
	DINT
	MOVE	@INTENB,A0,W
	ANDNI	X1E,A0			;NO MORE DMA INTERRUPTS
	MOVE	A0,@INTENB,W
	POPST
	CLR	A0
	MOVE	A0,@GAMERASE
	CALLR	DMAWAIT			;WAIT ON DMA
	MOVI	GXBOOM,A0    		;Fix the Smart Bomb effect palette
	CALLA	GET_UNZIP_PAL
	CALLA	IAUTOE

*INITIALIZE SUPPLEMENTAL LIST HEADERS
	MOVI	SUPPLSTS,A1		 ;GET THE SUPPLEMENTAL LIST AREA
	CLR	A0
MYOINITS:
	MOVE	A0,*A1+,L
	CMPI	SUPPLSTSX,A1
	JRLO	MYOINITS

	MMFM	SP,A0,A1,A2,A3,A4,A5
	JAUC	OINIT

**************************************************************************
*                                                                        *
* RANDOM - GENERATE A RANDOM NUMBER					 *
* RETURNS:								 *
* A0 = 32 BIT RANDOM #							 *
*                                                                        *
**************************************************************************
RANDOM:
;	PUSH	A1
	MOVE	@RAND,A0,L
	SLA	1,A0
	JRV	RND2
	ORI	2,A0
RND2:	MOVE	A0,@RAND,L
	CLR	A14
	ADDC	A14,A0	;GET LAST BIT BACK TO MAKE 32
	MOVE	@HCOUNT,A14,W
	RL	A14,A0	;RANDOM ROTATION
	MOVE	A0,A0	;SET STATUS BITS
;	MMFM	SP,A1
	RETS	

**************************************************************************
*                                                                        *
* RANDU - GENERATE A UNIFORMLY DISTRIBUTED RANDOM # BETWEEN 1 AND [A0]	 *
* A0 = RANGE INPUT							 *
* RETURNS:								 *
* A0 = RANDOM #								 *
*                                                                        *
**************************************************************************
RANDU:	PUSH	A1
	MOVE	A0,A1
	CALLR	RANDOM
	MPYU	A1,A0
	INC	A0
	MMFM	SP,A1
	RETS		

**************************************************************************
*								         *
* 	RAND0								 *
* 									 *
* 	Generate a uniformly distributed random # between 0 and		 *
* 	[A0 - 1].							 *
* 									 *
* 	A0 = Distribution range						 *
* 									 *
* 	Returns:							 *
* 		A0 = Number (Status bits reflect value in A0)		 *
*								         *
**************************************************************************
RAND0:
	PUSH	A1
	MOVE	A0,A1
	CALLR	RANDOM
	MPYU	A1,A0
	MOVE	A0,A0
	MMFM	SP,A1
	RETS	

*
*GET SIGNED RANDOM # IN RANGE +/- A0
*CALLING PARAMETERS: A0
*RETURNS A0
*
SRAND:
	PUSH	A0
	SLL	1,A0
	CALLA	RANDU
	PULLQ	A14
	SUB	A14,A0
	RETS
**************************************************************************
*                                                                        *
* RANGRAND - GENERATE A RANDOM NUMBER IN A GIVEN RANGE.			 *
* A0 = UPPER BOUND							 *
* A1 = LOWER BOUND							 *
* RETURNS								 *
* A0 = RANDOM #								 *
*                                                                        *
**************************************************************************
RANGRAND
	SUB	A1,A0		;NORMALIZE THE RANGE
	CALLR	RANDU
	ADD	A1,A0
	RETS

**************************************************************************
* RANGERND - GENERATE A RANDOM NUMBER IN A GIVEN RANGE.
* A0 = VAL 1 (SIGNED, UPPER BOUND)
* A1 = VAL 2 (SIGNED, LOWER BOUND)
* RETURNS
* A0 = RANDOM #	BETWEEN VAL 1 AND VAL 2
* CLOBBERS A1
RANGERND
	CMP	A1,A0
	JRGE	VALSOK	;WANT A0 > A1
	SWAP	A1,A0
VALSOK
	SUB	A1,A0
	CALLR	RAND0
	ADD	A1,A0
	RETS

*
*RANDPER - RANDOM % ROUTINE
*CALLING PARAMETERS:
*A0=PROBABILITY OF EVENT (0-1023) P(A0=1024) = 1; P(A0=1) = 1/1024.
*RETURNS CS IF PROBABILITY IS TRUE, CC FOR FALSE
*RETURNS A0 = ACTUAL RANDOM # 0-1023
RANDPER:
	PUSH	A0
	CALLA	RANDOM
	SRL	22,A0
	PULLQ	A14
	CMP	A14,A0
	RETS		

**************************************************************************
*                                                                        *
* FILLAREA - FILL A GIVEN SQUARE AREA ON THE SCREEN WITH A COLOR	 *
* A1 = [COLOR,PALETTE]							 *
* A3 = DAG OF AREA [YPOS,XPOS]						 *
* A4 = [Y,X] SIZE OF AREA						 *
*                                                                        *
**************************************************************************
FILLAREA
	MMTM	SP,A0,A1,A2,A4,A5,A7
	MOVI	QDMAN,A7
	JRUC	AREACON

**************************************************************************
*								         *
* FILLAREA2 - FILL A GIVEN SQUARE AREA ON THE SCREEN WITH A COLOR	 *
* 		ON BOTH DISPLAY PAGES.					 *
* A1 = [COLOR,PALETTE]							 *
* A3 = DAG OF AREA [YPOS,XPOS]						 *
* A4 = [Y,X] SIZE OF AREA						 *
*								         *
**************************************************************************
FILLAREA2
	MMTM	SP,A0,A1,A2,A4,A5,A7
	MOVI	QDMAN2,A7
	JRUC	AREACON

**************************************************************************
*                                                                        *
* BLNKAREA - BLANK A GIVEN SQUARE AREA ON THE SCREEN			 *
* A3 = DAG OF AREA [YPOS,XPOS]						 *
* A4 = [Y,X] SIZE OF AREA						 *
*                                                                        *
**************************************************************************
BLNKAREA
	MMTM	SP,A0,A1,A2,A4,A5,A7
	MOVI	QDMAN,A7
	CLR	A1			;CONSTANT 0:PALETTE 0
	JRUC	AREACON

**************************************************************************
*                                                                        *
* BLNKAREA2 - BLANK A GIVEN SQUARE AREA ON BOTH DISPLAY PAGES.		 *
* A3 = DAG OF AREA [YPOS,XPOS]						 *
* A4 = [Y,X] SIZE OF AREA						 *
*                                                                        *
**************************************************************************
BLNKAREA2
	MMTM	SP,A0,A1,A2,A4,A5,A7
	MOVI	QDMAN2,A7
	CLR	A1			;CONSTANT 0:PALETTE 0
	JRUC	AREACON

AREACON
	MOVI	[0100H,0100H],A0
	MOVE	A4,A2
	MOVI	IROM,A4		;SOMEWHERE IN IMAGE ROM
	MOVI	DMACAL,A5
	SLL	16,A5
	CALL	A7
	MMFM	SP,A0,A1,A2,A4,A5,A7
	RETS


**************************************************************************
*                                                                        *
* OBJECT VELOCITY STOP ROUTINES						 *
*                                                                        *
**************************************************************************

**************************************************************************
*								         *
* PSTOP - STOP AN OBJECT, BY ZEROING ALL OF IT'S VELOCITIES		 *
* A8 = PTR TO OBJECT							 *
*								         *
**************************************************************************
PSTOP
	JAUC	CLR_VEL

**************************************************************************
*                                                                        *
* DRAWBOX - DRAW A BOX USING THE DMA					 *
* A0 = [H,W] SIZE OF BOX						 *
* A1 = [COLOR,PALETTE]							 *
* A2 = LINE THICKNESS IN PIXELS						 *
* A3 = [Y,X] SCREEN ADDRESS OF BOX					 *
*                                                                        *
**************************************************************************
DRAWBOX
	MMTM	SP,A0,A2,A3,A4,A5,A6,A7,A8,A9
	MOVE	A0,A9
	MOVI	DMACAL,A5		;ALWAYS THIS COLOR
	SLL	16,A5
	MOVI	IROM,A4		;LET'S USE THIS AS DATA
	MOVI	[0100H,0100H],A0	;SET SCALE 1:1
	MOVE	A3,A7
	MOVE	A2,A8			;KEEP PIXEL THICKNESS HERE
	SLL	16,A2
	MOVX	A9,A2
	MOVE	A2,A6
	CALLA	QDMAN			;DRAW TOP LINE
	RL	16,A2
	MOVY	A9,A2
	MOVE	A2,A9
	CALLA	QDMAN			;DRAW LEFT LINE
	SRL	16,A2
	SLL	16,A2
	RL	16,A8
	SUBXY	A8,A2			;ADJUST FOR PIXEL THICKNESS
	ADDXY	A2,A3			;MOVE TO LL CORNER
	MOVE	A6,A2	
	CALLA	QDMAN			;DRAW BOTTOM LINE
	ZEXT	A2
	DEC	A2
	RL	16,A8
	SUBK	1,A8			;BASE ON 1 PIXEL
	SUBXY	A8,A2			;ADJUST FOR PIXEL THICKNESS
	ADDXY	A2,A7			
	MOVE	A7,A3			;MOVE TO UR CORNER
	MOVE	A9,A2
	CALLA	QDMAN			;DRAW RIGHT LINE
	MMFM	SP,A0,A2,A3,A4,A5,A6,A7,A8,A9
	RETS

**************************************************************************
*								         *
* DRAWBOX_OBJ - DRAW A BOX AS OBJECTS USING THE DISPLAY SYSTEM		 *
* A0 = [H,W] SIZE OF BOX						 *
* A1 = [COLOR,PALETTE]							 *
* A2 = LINE THICKNESS IN PIXELS						 *
* A3 = [Y,X] SCREEN ADDRESS OF BOX					 *
*								         *
**************************************************************************
DRAWBOX_OBJ
	MMTM	SP,A0,A2,A3,A4,A5,A6,A7,A8
	MOVE	A0,A4
	MOVE	A3,A7
	MOVE	A2,A8			;KEEP PIXEL THICKNESS HERE
	SLL	16,A2
	MOVX	A4,A2
	MOVE	A2,A6

	MOVI	BOXLINE_INIT,A5
	CALLA	CREATE_OBJ
	JRZ	DBO_X
	MOVE	A1,*A0(OPAL),L
	MOVE	A3,*A0(OXPOS),W
	MOVE	A3,*A0(OYVAL),L
	MOVE	A2,*A0(OSIZE),L
	CALLA	INSOBJ

	RL	16,A2
	MOVY	A4,A2
	MOVE	A2,A4

	MOVI	BOXLINE_INIT,A5
	CALLA	CREATE_OBJ
	JRZ	DBO_X
	MOVE	A1,*A0(OPAL),L
	MOVE	A3,*A0(OXPOS),W
	MOVE	A3,*A0(OYVAL),L
	MOVE	A2,*A0(OSIZE),L
	CALLA	INSOBJ

	SRL	16,A2
	SLL	16,A2
	RL	16,A8
	SUBXY	A8,A2			;ADJUST FOR PIXEL THICKNESS
	ADDXY	A2,A3			;MOVE TO LL CORNER
	MOVE	A6,A2	

	MOVI	BOXLINE_INIT,A5
	CALLA	CREATE_OBJ
	JRZ	DBO_X
	MOVE	A1,*A0(OPAL),L
	MOVE	A3,*A0(OXPOS),W
	MOVE	A3,*A0(OYVAL),L
	MOVE	A2,*A0(OSIZE),L
	CALLA	INSOBJ

	ZEXT	A2
	DEC	A2
	RL	16,A8
	SUBK	1,A8			;BASE ON 1 PIXEL
	SUBXY	A8,A2			;ADJUST FOR PIXEL THICKNESS
	ADDXY	A2,A7			
	MOVE	A7,A3			;MOVE TO UR CORNER
	MOVE	A4,A2

	MOVI	BOXLINE_INIT,A5
	CALLA	CREATE_OBJ
	JRZ	DBO_X
	MOVE	A1,*A0(OPAL),L
	MOVE	A3,*A0(OXPOS),W
	MOVE	A3,*A0(OYVAL),L
	MOVE	A2,*A0(OSIZE),L
	CALLA	INSOBJ

DBO_X
	MMFM	SP,A0,A2,A3,A4,A5,A6,A7,A8
	RETS

BOXLINE_INIT
	.LONG	BOXLINE,0
	.WORD	OID_JUNK,DMACAL,M_SCRNOBJ|M_NOSCALE,0
	.LONG	0

	.long	T2FIXED
BOXLINE:
	.word	4,4
	.long	IROM
	.word   0,0,00H

**************************************************************************
*								         *
* DTIME - USED TO DMA AN IMAGE						 *
* DTIME2 - USED TO DMA AN IMAGE TO BOTH PAGES AT ONCE			 *
* A1 = [CONSTANT COLOR,PALETTE(STUFFED IN DTIME)]			 *
* A3 = DAG [Y,X]							 *
* A5 = [CONTROL,OFFSET]							 *
* A7 = ADDRESS OF IMAGE HEADER						 *
* NOTE: SCALE IS ALWAYS 1:1						 *
*								         *
**************************************************************************
DTIME
	MMTM	SP,A0,A1,A2,A4,A6
	MOVI	QDMAN,A6
	JRUC	DTIME_G
DTIME2
	MMTM	SP,A0,A1,A2,A4,A6
	MOVI	QDMAN2,A6

DTIME_G	
	MOVE	*A7(ICMAP),A0,L		;GET THE PALETTE
	CALLA	FINDPAL			;GET THE CORRECT COLOR MAP #
	JRNZ	DTIME1			;BR = PALETTE WAS FOUND
	CLR	A0			;DEFAULT TO FIXED PALETTE
DTIME1
	MOVX	A0,A1

	MOVI	[0100H,0100H],A0	;SCALE IS 1:1

	PUSH	A1
	MOVE	A7,A1
	MOVE	*A1(ISIZE),A2,L		;GRAB THE UNSCALED SIZE
	MOVE	*A1(ICTRL),A14,W	;GET BPP AND COMPRESSION
	SLL	16,A14
	OR	A14,A5
	PULLQ	A1
	MOVE	*A7(ISAG),A4,L

	CALL	A6			;Q THIS SUCKAH!

	MMFM	SP,A0,A1,A2,A4,A6
	RETS

**************************************************************************
*								         *
* DMAWPAL - DMA AN OBJECT, ALLOCATING IT'S PALETTE			 *
* A1 = [CONSTANT, 0]							 *
* A3 = POSITION(DAG)							 *
* A5 = [CONTROL,OFFSET]							 *
* A7 = PTR TO IMAGE HEADER						 *
*								         *
**************************************************************************
DMAWPAL:
	MMTM	SP,A0,A1,A2,A4
	MOVE	*A7(ICMAP),A0,L		;GET THE COLOR MAP WE WANT
	CALLA	GETFPAL			;GET A PALETTE
	JRZ	DMANOPAL
	MOVX	A0,A1			;TACK ON THE PALETTE
	JRUC	DMAWPNOW
DMANOPAL:
	SRL	16,A1
	SLL	16,A1			;DEFAULT TO ZERO PALETTE
DMAWPNOW:
	MOVE	*A7(ISIZE),A2,L
	MOVE	*A7(ISAG),A4,L
	MOVI	[0100H,0100H],A0	;SCALE IS 1:1
	CALLA	QDMAN			;DMA THIS GUY
	MMFM	SP,A0,A1,A2,A4
	RETS

**************************************************************************
*                                                                        *
* DMAWAIT - WAIT ON THE DMA BUSY BIT TO CLEAR				 *
*                                                                        *
**************************************************************************
DMAWAIT
;	MOVE	@DMAGOREG,A14,W	;DMA BUSY?
;	JRN	DMAWAIT		;BR = YES
;	RETS

	PUSH	A1
	MOVI	(4096*MICRO_SECOND)/4,A1	;MAX WAIT FOR 400X256 DMA
DW_DMA_WT	
	MOVE	@DMAGOREG,A14,L		;DMA STILL BUSY?
	JRNN	DW_DMA_READY		;BR = NO, READY
	DSJS	A1,DW_DMA_WT
	LOCKUP

	CLR	A14
	MOVE	A14,@DMAGOREG,L
	MOVE	A14,@DMAGOREG,L		;DMA off for sure

	CALLA	CLRDMAQ

DW_DMA_READY
	PULL	A1
	RETS

**************************************************************************
*								         *
* DMAQWAIT - WAIT ON DMA QUEUE TO EMPTY, THEN DMA BUSY TO CLEAR		 *
*								         *
**************************************************************************
DMAQWAIT
;	cmp	B12,B13		;Is Q Empty?
;	jrgt	DMAQWAIT
;	MOVE	@DMAGOREG,A14,W	;DMA BUSY?
;	JRN	DMAQWAIT	;BR = YES
;	RETS

	MMTM	SP,B1,B2

DQW_DMA_NEXT_EL
	MOVI	(4096*MICRO_SECOND)/4,B1	;Max wait
	MOVE	B13,B2
DQW_Q_WT
	CMP	B12,B13		;Is Q Empty?
	JRLE	DQW_Q_EMPTY

	CMP	B2,B13
	JRNE	DQW_DMA_NEXT_EL			;BR = Queue is changing

	DSJS	B1,DQW_Q_WT

	LOCKUP

	CLR	B2
	MOVE	B2,@DMAGOREG,L
	MOVE	B2,@DMAGOREG,L		;DMA off for sure

	CALLA	CLRDMAQ
	JRUC	DQW_X

DQW_Q_EMPTY

	MOVI	(4096*MICRO_SECOND)/4,B1	;MAX WAIT FOR 400X256 DMA
DQW_DMA_WT	
	MOVE	@DMAGOREG,B2,L
	JRNN	DQW_X			;BR = DMA is ready
	DSJS	B1,DQW_DMA_WT

	LOCKUP

	CLR	B2
	MOVE	B2,@DMAGOREG,L
	MOVE	B2,@DMAGOREG,L		;DMA off for sure

	CALLA	CLRDMAQ

DQW_X
	MMFM	SP,B1,B2
	RETS

**************************************************************************
*                                                                        *
* DMAHALT - HALT THE DMA						 *
*                                                                        *
**************************************************************************
DMAHALT
	CLR	A14
	MOVE	A14,@DMAGOREG,L		;HALT THE DMA			 
	MOVE	A14,@DMAGOREG,L		;CLEAR THE DMA
	RETS


*
*CMAPRS - RESET THE COLOR MAP SELECT
CMAPRS	CLR	A0
*CMAPSL - SELECT THE COLOR MAP(0-15 IN A0)
CMAPSL	MOVE	A1,-*SP,L
	CALLA	DMAWAIT
	MOVE	A0,@CMAPSEL
	MOVE	*SP+,A1,L
	RETS

*
*SCRCLR - CLEAR THE SCREEN WITH EUGENE
*ONLY CALL WITH INTERRUPTS DISABLED AND THE DMA SHUT DOWN, OTHERWISE
*	USE CLR_SCRN
SCRCLR	CLR	A0
*SCRFIL - FILL SCREEN WITH A0
SCRFIL:
	MMTM	SP,A1,A2
	CLR	A1
	MOVE	A1,@CMAPSEL,W			;SELECT COLOR MAP 0
	MOVI	SCREEN,A1,L
	MOVI	(SCRNE-SCREEN)/32,A2,L
SCRLP	MOVE	A0,*A1+,L
	DSJS	A2,SCRLP
	MMFM	SP,A1,A2
	RETS

*
*LAST2CLR - CLEAR LAST TWO LINES OF BIT MAP(I.E. SET AUTO ERASE COLOR)
LAST2CLR
	CLR	A0
*
*LAST2FIL - FILL LAST TWO LINES OF BIT MAP
*A0 = FILL COLOR
LAST2FIL
	MOVE	A0,@ERASELOC,W			;STUFF DA COLOR
	RETS
**************************************************************************
*                                                                        *
* SETPPROC - SETUP TI'S PIXEL PROCESSING REGISTER'S (BFILE), TO MATCH 	 *
* 	   THE ZUNIT SYSTEM.						 *
* NOTE:	   IF YOU WANT TO DO ANY SPECIAL TRICKS, DON'T USE THIS. 	 *
*                                                                        *
**************************************************************************
SETPPROC
	PUSH	A0
	MOVI	OFFSETVAL,B4	;Set up OFFSET register
	MOVI	0,B8		 	;Set background color
	MOVI	SCRN_PTCH,A0 		;Get Screen Pitch
	MOVE	A0,B1
	MOVE	A0,B3
	LMO	A0,A0			;Convert in temporary register
	MOVE	A0,@CONVSP		;Move to CONVSP io register
	MOVE	A0,@CONVDP		;Move to CONVDP io register
	PULL	A0
	RETS


**************************************************************************
*                                                                        *
* CLRBLOCK - CLEAR A BLOCK OF MEMORY. SIZE MUST BE A FACTOR OF 16	 *
*	     MAKE SURE BLOCK SIZE IS 32 BITS OR GREATER.		 *
* A1 = START ADDRESS							 *
* A2 = END ADDRESS							 *
*                                                                        *
**************************************************************************
CLRBLOCK:
	PUSH	A3
	CLR	A3
	CALLR	FILBLOCK
	PULL	A3
	RETS

**************************************************************************
*                                                                        *
* FILBLOCK - FILL A BLOCK OF MEMORY. SIZE MUST BE A FACTOR OF 16	 *
*	     MAKE SURE BLOCK SIZE IS 32 BITS OR GREATER.		 *
* A1 = START ADDRESS							 *
* A2 = END ADDRESS							 *
* A3 = FILL VALUE							 *
*                                                                        *
**************************************************************************
FILBLOCK:
	MMTM	SP,A1,A2
	SUB	A1,A2
	SRL	5,A2
	JRNC	FIL32LP
	MOVE	A3,*A1+,W		;MOVE THE ODD WORD
FIL32LP:	
	MOVE	A3,*A1+,L		;JUST MOVE LONG
	DSJS	A2,FIL32LP
	MMFM	SP,A1,A2
	RETS
	
**************************************************************************
*                                                                        *
* CLR_SCRN - CLEAR THE WHOLE BIT MAP					 *
* NOTE : TRASHES A0							 *
*                                                                        *
**************************************************************************
CLR_SCRN:
	CLR	A0
*
*YOU PROVIDE THE COLOR IN A0
FILL_SCRN:
	MMTM	SP,A1,A2,A3
	MOVE	@DISPLAYON,A3,W
	CLR	A1
	MOVE	A1,@DISPLAYON,W
	CALLR	DMAQWAIT			;WAIT ON DMA
	CLR	A1
	MOVE	A1,@CMAPSEL,W			;SELECT COLOR MAP 0
	MOVI	SCREEN,A1,L
	MOVI	((SCRNE-2000H)-SCREEN)/32,A2,L
CLRLP	MOVE	A0,*A1+,L
	DSJS	A2,CLRLP
	MOVE	A3,@DISPLAYON,W
	MMFM	SP,A1,A2,A3
	RETS

*
*CLEAR EVERYTHING UNDERNEATH THE STATUS AREA
CLRPLAY
	CALLR	CLRP_P0
	JRUC	CLRP_P1

*
*CLEAR EVERYTHING UNDERNEATH THE STATUS AREA ON PAGE 0 ONLY
CLRP_P0
	MMTM	SP,A0,A1,A2,A3
	CLR	A0
	MOVE	@DISPLAYON,A3,W
	MOVE	A0,@DISPLAYON,W
	CALLA	DMAQWAIT			;WAIT ON DMA
	CLR	A1
	MOVE	A1,@CMAPSEL,W			;SELECT COLOR MAP 0
	MOVI	SCREEN+(SKYTOPOF*1000H),A1,L
	MOVI	(PAGE0E-(SCREEN+(SKYTOPOF*1000H)))/32,A2,L
CLRP0LP	MOVE	A0,*A1+,L
	DSJS	A2,CLRP0LP
	MOVE	A3,@DISPLAYON,W
	MMFM	SP,A0,A1,A2,A3
	RETS

*
*CLEAR EVERYTHING UNDERNEATH THE STATUS AREA ON PAGE 1 ONLY
CLRP_P1
	MMTM	SP,A0,A1,A2,A3
	CLR	A0
	MOVE	@DISPLAYON,A3,W
	MOVE	A0,@DISPLAYON,W
	CALLA	DMAQWAIT			;WAIT ON DMA
	CLR	A1
	MOVE	A1,@CMAPSEL,W			;SELECT COLOR MAP 0
	MOVI	PAGE0E+(SKYTOPOF*1000H),A1,L
	MOVI	(SCRNE-(PAGE0E+(SKYTOPOF*1000H)))/32,A2,L
	JRUC	CLRP0LP

**************************************************************************
*								         *
* 	FILL_PAGE2							 *
* 									 *
* 	Fill screen page 2 with a given value				 *
* 									 *
* 	A0 = Long word value to store					 *
*								         *
**************************************************************************
FILL_PAGE2
	MMTM	SP,A0,A1,A2,A3
	JRUC	CP2_G

**************************************************************************
*								         *
* 	CLEAR_PAGE2							 *
* 									 *
* 	Clear just screen page 2					 *
*								         *
**************************************************************************
CLEAR_PAGE2
	MMTM	SP,A0,A1,A2,A3
	CLR	A0
CP2_G
	MOVE	@DISPLAYON,A3,W
	CLRM	@DISPLAYON,W
	CALLA	DMAQWAIT			;WAIT ON DMA
	CLR	A1
	MOVE	A1,@CMAPSEL,W			;SELECT COLOR MAP 0
	MOVI	PAGE2_START,A1,L
	MOVI	((PAGE2_END + 1) - PAGE2_START)/32,A2,L
	JRUC	CLRP0LP

**************************************************************************
*								         *
* 	CLEAR_PAGE3							 *
* 									 *
* 	Clear just screen page 2					 *
*								         *
**************************************************************************
CLEAR_PAGE3
	MMTM	SP,A0,A1,A2,A3
	CLR	A0
	MOVE	@DISPLAYON,A3,W
	MOVE	A0,@DISPLAYON,W
	CALLA	DMAQWAIT			;WAIT ON DMA
	CLR	A1
	MOVE	A1,@CMAPSEL,W			;SELECT COLOR MAP 0
	MOVI	PAGE3_START,A1,L
	MOVI	((PAGE3_END + 1) - PAGE3_START)/32,A2,L
	JRUC	CLRP0LP

**************************************************************************
*								         *
* 	FlshWyte							 *
* 									 *
* 	Flash an object to a constant color using Anim to unflash.	 *
* 	To use this function, obj must not be using OVAR5 or OVAR6.	 *
*								         *
**************************************************************************
FlshWyte:
	PUSH	A1
	movb	*A8(OFLAGS+B_ANIM-7),A14	;already animating??
	jrnn	FlashIt0			;NO..

	;save current anim info in OVAR5,OVAR6
	move	*A8(AnimScr),A14,L
	cmpi	UNFLASH,A14
	jreq	SkWhite				;BR = already unflashing..
	move	A14,*A8(OVAR5),L
	move	*A8(AnimFrm),*A8(OVAR6),L
	jruc	FlashIt
FlashIt0
	CLRM	*A8(OVAR6),L
FlashIt
;	move	A1,*A8(OCONST),W
	movi	UNFLASH,A1
	calla	STRT_ANIM
	CALLA	OBJ_CONST
SkWhite:
	PULLQ	A1
	rets

*FLASH ANIM SCRIPT
UNFLASH
	LW	1,4
	LWL	1,1|AFunc,UnFlash

****************************************************************************
* UnFlash
* Anim function used by FlshWyte to unflash an object and restore its
* previous action
UnFlash:
	move	*A8(OCTRL),A1,W
;	move	*A8(OFLAGS),A1,W
	ori	M_WRNONZ,A1	;Do Write Non-Zero Data
	andni	M_CONNON,A1	;Don't Replace Non-Zero Data with constant
	move	A1,*A8(OCTRL),W
;	move	A1,*A8(OFLAGS),W

	move	*A8(OVAR6),A1,L
	jrz	UFPul
	;*** JUST RESTORE TO OLD ANIM SCRIPT ***
	move	A1,*A8(AnimFrm),L
	move	*A8(OVAR5),*A8(AnimScr),L
	jruc	UnFlashX

UFPul	calla	PULL_ANIM
UnFlashX
	rets

FRAGZOFF	.set	0

**************************************************************************
FragCoorsSetup:
;CLOBBERS A1,A2,A4
	MOVE	*A8(OIMG),A4,L		;We must get ani pnt from 1:1 image
	MOVE	*A4(IANIOFF),A2,L	;Got it
	MOVE	*A4(ISIZE),A14,L

	MOVE	*A8(OFLAGS),A1,W
	BTST	B_DBLSCL,A1
	JRZ	FCS_NODUB		;BR=NO DOUBLE SCALE

	MOVE	A2,A1			;DOUBLE SCALE ACTION ON THE ANIOFF
	SLL	1,A2			;DOUBLE ANIOFFX
	SRA	16,A1
	SLL	1+16,A1			;DOUBLE ANIOFFY
	MOVY	A1,A2

	MOVE	A14,A4			;DOUBLE SCALE ACTION ON THE SIZE
	SLL	1,A14			;DOUBLE SIZEX
	SRA	16,A4
	SLL	1+16,A4			;DOUBLE	SIZEY
	MOVY	A4,A14
FCS_NODUB
	MOVE	*A8(OCTRL),A1,W		;Do the flip thang

	MOVE	A14,B6
	SUBI	10001h,A14
	SUBXY	A2,A14		; adjusted anioff in a9

	BTST	B_FLIPH,A1
	JRZ	FCS_NOHFLIP
	MOVX	A14,A2
FCS_NOHFLIP
	BTST	B_FLIPV,A1
	JRZ	FCS_NOVFLIP
	MOVY	A14,A2
FCS_NOVFLIP
	MOVE	A2,A14
	SEXT	A14,W
	SLL	15,A14			;Multiply for world coords
	MOVE	*A8(OXVAL),A1,L
	SUB	A14,A1

	MOVE	B6,A14
	SEXT	A14,W

	RETS

**************************************************************************
FragCenterCoors:
;CLOBBERS A1,A2,A4
	;*** SET COORS ***
	CALLR	FragCoorsSetup

;A1  = OXVAL - SIZEX - 1 - ANIOFFX	
;A2  = SIZE - [1,1] - ANIOFF
;A14 = SIZEX - 1 - ANIOFFX 
;B6  = UNFLIPPED SIZE

	SLL	15-1,A14		;TRANSLATE AND DIVIDE BY 2
	ADD	A14,A1
	SRA	16,A1
	move	A1,B1			;Minimum X
	move	A1,B2			;Maximum X

	SRA	16,A2
	SLL	15,A2
	MOVE	*A8(OYVAL),A1,L
	SUB	A2,A1
	MOVE	B6,A2
	SRA	16,A2
	SLL	15-1,A2			;TRANSLATE AND DIVIDE BY 2
	ADD	A2,A1
	SRA	16,A1
	move	A1,B5			;Minimum Y
	move	A1,B6			;Maximum Y

	rets

**************************************************************************
FragLRCoors:
;CLOBBERS A1,A2,A4
	;*** SET COORS ***
	CALLR	FragCoorsSetup

;A1  = OXVAL - SIZEX - 1 - ANIOFFX	
;A2  = SIZE - [1,1] - ANIOFF
;A14 = SIZEX - 1 - ANIOFFX 
;B6  = UNFLIPPED SIZE

	SLL	15,A14			;TRANSLATE
	ADD	A14,A1
	SRA	16,A1
	move	A1,B1			;Minimum X
	move	A1,B2			;Maximum X

	SRA	16,A2
	SLL	15,A2
	MOVE	*A8(OYVAL),A1,L
	SUB	A2,A1
	MOVE	B6,A2
	SRA	16,A2
	SLL	15,A2			;TRANSLATE
	ADD	A2,A1
	SRA	16,A1
	move	A1,B5			;Minimum Y
	move	A1,B6			;Maximum Y

	rets

**************************************************************************
FragBoxCoors:
;CLOBBERS A1,A2,A4
	;*** SET COORS ***
	CALLR	FragCoorsSetup

;A1  = OXVAL - SIZEX - 1 - ANIOFFX	
;A2  = SIZE - [1,1] - ANIOFF
;A14 = SIZEX - 1 - ANIOFFX 
;B6  = UNFLIPPED SIZE

	move	A1,B1			;Minimum X
	SRA	16,B1
	SLL	15,A14
	ADD	A14,A1
	move	A1,B2			;Maximum X
	SRA	16,B2

	SRA	16,A2
	SLL	15,A2
	MOVE	*A8(OYVAL),A1,L
	SUB	A2,A1
	move	A1,B5			;Minimum Y
	SRA	16,B5
	MOVE	B6,A2
	SRA	16,A2
	SLL	15,A2
	ADD	A2,A1
	move	A1,B6			;Maximum Y
	SRA	16,B6

	rets

**************************************************************************
*								         *
* 		All PreFrag routines merely setup up the 		 *
* 		registers for Fragger.  This is so that			 *
* 		you may tweak any necessary parameters.			 *
* 		So after PreFrag, call Fragger to kick			 *
* 		the jams.						 *
*								         *
**************************************************************************

**************************************************************************
*								         *
* PreFrag_Gun - Setup a Fragger explosion from random points within	 *
* 		the box centered around the players current		 *
* 		cursor position. Uses Z position and all velocities	 *
* 		of the given object.					 *
* 									 *
* A0 = Absolute value of Max X and Y Velocity (16.16) of chunks.	 *
* A2 = Ptr to player data (has pt of gun)				 *
* A3 = Absolute value of Max Z Velocity (16.16)				 *
* A4 = Y:X "Radius" of box.						 *
* A8 = Ptr to Object about which fragments are to be created.		 *
* 									 *
* Returns:								 *
* 	B0 ZVal   	16.16						 *
* 	B1 min Xpos	16 bit integer only				 *
* 	B2 max Xpos	16 bit integer only				 *
* 	B3 min Xvel	16.16						 *
* 	B4 max Xvel	16.16						 *
* 	B5 min Ypos	16 bit integer only				 *
* 	B6 max Ypos	16 bit integer only				 *
* 	B7 min Yvel	16.16						 *
* 	B8 max Yvel	16.16						 *
* 	B9 min Zvel	16.16						 *
* 	B10 max Zvel	16.16						 *
* 									 *
* Note: If the velocities aren't quite correct for your application,	 *
* 	then use the Fragment function to adjust.			 *
*								         *
**************************************************************************
PreFrag_Gun
	mmtm	SP,A0,A1,A2,A4

	mmtm	SP,A5,A7

	MOVE	*A8(OZVAL),A1,L		;Make point Universe rel. at this Z
								
	move	*A2(PCURSORXY),A7,L	;Get [Y,X] Screen relative point.
	movx	A7,A5
	sext	A5
	sra	16,A7			;Now we have 16.16 screen X

	STOUXY	A1,A5,A7		;Use that funky Bill macro to convert
	
	srl	16,A5
	movy	A7,A5			;Pack it up, Pack it in, Let me begin...

	move	A5,A14

	subxy	A4,A14
	move	A14,B1			;B1 min Xpos
	sext	B1,W
	move	A14,B5			;B5 min Ypos
	sra	16,B5
	addxy	A4,A5
	move	A5,B2			;B2 max Xpos
	sext	B2,W
	move	A5,B6			;B6 max Ypos
	sra	16,B6

	mmfm	SP,A5,A7
	jruc	CoorSet1		;Finish off inside PreFrag_Center

**************************************************************************
*								         *
* PreFrag_Offset - Setup a Fragger explosion offset from the animation   *
* 		point of the given object. Max velocity is relative to	 *
* 		the objects current velocity in a given direction.	 *
* 		If the object is in the AIR then blow fragments		 *
* 		in all directions.					 *
* 		If the object is on the GROUND then blow fragments	 *
* 		up.							 *
* 									 *
* A0 = Absolute value of Max X and Y Velocity (16.16) of chunks.	 *
* A3 = Absolute value of Max Z Velocity (16.16)				 *
* A4 = [Y, X] PIXEL OFFSET						 *
* A8 = Ptr to Object about which fragments are to be created.		 *
* 									 *
* Returns:								 *
* 	B0 ZVal   	16.16						 *
* 	B1 min Xpos	16 bit integer only				 *
* 	B2 max Xpos	16 bit integer only				 *
* 	B3 min Xvel	16.16						 *
* 	B4 max Xvel	16.16						 *
* 	B5 min Ypos	16 bit integer only				 *
* 	B6 max Ypos	16 bit integer only				 *
* 	B7 min Yvel	16.16						 *
* 	B8 max Yvel	16.16						 *
* 	B9 min Zvel	16.16						 *
* 	B10 max Zvel	16.16						 *
* 									 *
* Note: If the velocities aren't quite correct for your application,	 *
* 	then use the Fragment function to adjust.			 *
*								         *
**************************************************************************

PreFrag_Offset
	mmtm	SP,A0,A1,A2,A4

	MOVE	A4,B0
	SEXT	B0,W
	SRA	1,B0			;TRANSLATE SCREEN X TO WORLD INTEGER
	MOVE	A8,B3
	MOVE	*B3(OXPOS),B1,W
	ADD	B0,B1
	MOVE	B1,B2

	MOVE	A4,B0
	SRA	17,B0			;TRANSLATE SCREEN Y TO WORLD INTEGER
	MOVE	*B3(OYPOS),B5,W
	ADD	B0,B5
	MOVE	B5,B6

	jruc	CoorSet1

**************************************************************************
*								         *
* 	PreFrag_Box_Offset						 *
* 									 *
* 	Set up a Fragger explosion making a box based on the offsets	 *
* 	given.  Each offset is from the animation pnt of the calling	 *
* 	object.								 *
* 									 *
* 	A0 = Absolute value of Max X and Y Velocity (16.16) of chunks.	 *
* 	A3 = Absolute value of Max Z Velocity (16.16)			 *
* 	A4 = [Y,X] PIXEL OFFSET of Upper Left				 *
* 	A5 = [Y,X] PIXEL OFFSET of Lower Right				 *
* 	A8 = Ptr to Object about which fragments are to be created.	 *
* 									 *
* 	Returns:							 *
* 		B0 ZVal   	16.16					 *
*  		B1 min Xpos	16 bit integer only			 *
*  		B2 max Xpos	16 bit integer only			 *
*  		B3 min Xvel	16.16					 *
*  		B4 max Xvel	16.16					 *
*  		B5 min Ypos	16 bit integer only			 *
*  		B6 max Ypos	16 bit integer only			 *
*  		B7 min Yvel	16.16					 *
*  		B8 max Yvel	16.16					 *
*  		B9 min Zvel	16.16					 *
*  		B10 max Zvel	16.16					 *
*								         *
**************************************************************************
PreFrag_Box_Offset
	mmtm	SP,A0,A1,A2,A4

	MOVE	A4,B0
	SEXT	B0,W
	SRA	1,B0			;TRANSLATE SCREEN X TO WORLD INTEGER
	MOVE	A8,B3
	MOVE	*B3(OXPOS),B1,W
	MOVE	B1,B2
	ADD	B0,B1
	MOVE	A5,B0
	SEXT	B0,W
	SRA	1,B0			;TRANSLATE SCREEN X TO WORLD INTEGER
	ADD	B0,B2

	MOVE	A4,B0
	SRA	17,B0			;TRANSLATE SCREEN Y TO WORLD INTEGER
	MOVE	*B3(OYPOS),B5,W
	MOVE	B5,B6
	ADD	B0,B5
	MOVE	A5,B0
	SRA	17,B0			;TRANSLATE SCREEN Y TO WORLD INTEGER
	ADD	B0,B6

	jruc	CoorSet1

**************************************************************************
*								         *
* PreFrag_Center - Setup a Fragger explosion from the center of		 *
* 		the given object. Max velocity is relative to		 *
* 		the objects current velocity in a given direction.	 *
* 		If the object is in the AIR then blow fragments		 *
* 		in all directions.					 *
* 		If the object is on the GROUND then blow fragments	 *
* 		up.							 *
* 									 *
* A0 = Absolute value of Max X and Y Velocity (16.16) of chunks.	 *
* A3 = Absolute value of Max Z Velocity (16.16)				 *
* A8 = Ptr to Object about which fragments are to be created.		 *
* 									 *
* Returns:								 *
* 	B0 ZVal   	16.16						 *
* 	B1 min Xpos	16 bit integer only				 *
* 	B2 max Xpos	16 bit integer only				 *
* 	B3 min Xvel	16.16						 *
* 	B4 max Xvel	16.16						 *
* 	B5 min Ypos	16 bit integer only				 *
* 	B6 max Ypos	16 bit integer only				 *
* 	B7 min Yvel	16.16						 *
* 	B8 max Yvel	16.16						 *
* 	B9 min Zvel	16.16						 *
* 	B10 max Zvel	16.16						 *
* 									 *
* Note: If the velocities aren't quite correct for your application,	 *
* 	then use the Fragment function to adjust.			 *
*								         *
**************************************************************************
PreFrag_Center
	mmtm	SP,A0,A1,A2,A4
	callr	FragCenterCoors

CoorSet1:
	;*** SET ZVAL
	move	*A8(OZVAL),A1,L
	move	A1,B0			;Give us our starting Z value
****	addi	FRAGZOFF,B0

	;*** SET VELOCITIES ***
	move	A0,A2			;A2 = Base speed of the fragments

	move	*A8(OXVEL),A0,L		;Get objects current X velocity
	move	A0,A1
	sub	A2,A0
	move	A0,B3			;MIN XVel
	add	A2,A1
	move	A1,B4			;MAX XVel

	calla	DIST_FROM_GROUND	;Is this object close to the ground?
	SUBI	010000H,A1
	jrn	GrndFrag		;BR = Yes

	;AIR BURST
	move	*A8(OYVEL),A0,L		;Get objects current Y velocity
	move	A0,A1
	sub	A2,A0
	move	A0,B7			;MIN YVel
	add	A2,A1
	move	A1,B8			;MAX YVel
	jruc	PreFrgC_SetZ

	;GROUND BURST - Do not incorporate objects YVel and decrease Maximum
	;		downward velocity.
GrndFrag:
	move	A2,B7			;MIN YVel - Remember, negative is UP
	neg	B7
	move	B7,B8			;MAX YVel
	sra	2,B8
PreFrgC_SetZ:

	move	*A8(OZVEL),A0,L		;Get objects current Z velocity
	move	A0,A1
	sub	A3,A0
	move	A0,B9			;MIN ZVel
	add	A3,A1
	move	A1,B10			;MAX ZVel

	mmfm	SP,A0,A1,A2,A4
	rets


**************************************************************************
*								         *
* PreFrag_LR - Setup Fragger input to start fragments from LOWER RIGHT	 *
* 		corner of given object.					 *
* 									 *
* A0 = Absolute value of Max X and Y Velocity (16.16) of chunks.	 *
* A3 = Absolute value of Max Z Velocity (16.16)				 *
* A8 = Ptr to Object about which fragments are to be created.		 *
* 									 *
* Returns:								 *
* 	B0 ZVal   	16.16						 *
* 	B1 min Xpos	16 bit integer only				 *
* 	B2 max Xpos	16 bit integer only				 *
* 	B3 min Xvel	16.16						 *
* 	B4 max Xvel	16.16						 *
* 	B5 min Ypos	16 bit integer only				 *
* 	B6 max Ypos	16 bit integer only				 *
* 	B7 min Yvel	16.16						 *
* 	B8 max Yvel	16.16						 *
* 	B9 min Zvel	16.16						 *
* 	B10 max Zvel	16.16						 *
* 									 *
* Note: If the velocities aren't quite correct for your application,	 *
* 	then use the Fragment function to adjust.			 *
*								         *
**************************************************************************
PreFrag_LR
	mmtm	SP,A0,A1,A2,A4
	callr	FragLRCoors
	jruc	CoorSet1


**************************************************************************
*								         *
* PreFrag_Box - Setup Fragger input to start fragments from random	 *
* 		points within the Bounding Box of the given object.	 *
* 									 *
* A0 = Absolute value of Max X and Y Velocity (16.16) of chunks.	 *
* A3 = Absolute value of Max Z Velocity (16.16)				 *
* A8 = Ptr to Object about which fragments are to be created.		 *
* 									 *
* Returns:								 *
* 	B0 ZVal   	16.16						 *
* 	B1 min Xpos	16 bit integer only				 *
* 	B2 max Xpos	16 bit integer only				 *
* 	B3 min Xvel	16.16						 *
* 	B4 max Xvel	16.16						 *
* 	B5 min Ypos	16 bit integer only				 *
* 	B6 max Ypos	16 bit integer only				 *
* 	B7 min Yvel	16.16						 *
* 	B8 max Yvel	16.16						 *
* 	B9 min Zvel	16.16						 *
* 	B10 max Zvel	16.16						 *
* 									 *
* Note: If the velocities aren't quite correct for your application,	 *
* 	then use the Fragment function to adjust.			 *
*								         *
**************************************************************************
PreFrag_Box
	mmtm	SP,A0,A1,A2,A4
	callr	FragBoxCoors
	jruc	CoorSet1

**************************************************************************
*								         *
* PreFrag_Up - Setup Fragger input to start fragments from the Center	 *
* 		of the given object and blow fragments UP.		 *
* 									 *
* A0 = Absolute value of Max X and Y Velocity (16.16) of chunks.	 *
* A3 = Absolute value of Max Z Velocity (16.16)				 *
* A8 = Ptr to Object about which fragments are to be created.		 *
* 									 *
* Returns:								 *
* 	B0 ZVal   	16.16						 *
* 	B1 min Xpos	16 bit integer only				 *
* 	B2 max Xpos	16 bit integer only				 *
* 	B3 min Xvel	16.16						 *
* 	B4 max Xvel	16.16						 *
* 	B5 min Ypos	16 bit integer only				 *
* 	B6 max Ypos	16 bit integer only				 *
* 	B7 min Yvel	16.16						 *
* 	B8 max Yvel	16.16						 *
* 	B9 min Zvel	16.16						 *
* 	B10 max Zvel	16.16						 *
* 									 *
* Note: If the velocities aren't quite correct for your application,	 *
* 	then use the Fragment function to adjust.			 *
*								         *
**************************************************************************
PreFrag_Up
	mmtm	SP,A0,A1,A2,A4
	callr	FragBoxCoors		;clobbers A1,A2

	;*** SET ZVAL
	move	*A8(OZVAL),A1,L
	move	A1,B0			;Give us our ZVAL
****	addi	FRAGZOFF,B0

	;*** SET VELOCITIES ***
	move	*A8(OXVEL),A1,L
	move	A1,B14
	move	A0,B3			;MIN XVel
	neg	B3
	add	B14,B3
	move	A0,B4
	add	B14,B4			;MAX XVel

	move	A0,B7			;MIN YVel
	abs	B7
	neg	B7
	move	B7,B8			;MAX YVel
	sra	2,B8

	move	*A8(OZVEL),A0,L		;Get objects current Z velocity
	move	A0,A1
	sub	A3,A0
	move	A0,B9			;MIN ZVel
	add	A3,A1
	move	A1,B10			;MAX ZVel

	mmfm	SP,A0,A1,A2,A4
	rets


**************************************************************************
*								         *
* PreFrag_Rain - Setup a Fragger explosion from above.			 *
* 									 *
* A0 = Absolute value of Max X and Y Velocity (16.16) of chunks.	 *
* A3 = Absolute value of Max Z Velocity (16.16)				 *
* 									 *
* Returns:								 *
* 	B0 ZVal   	16.16						 *
* 	B1 min Xpos	16 bit integer only				 *
* 	B2 max Xpos	16 bit integer only				 *
* 	B3 min Xvel	16.16						 *
* 	B4 max Xvel	16.16						 *
* 	B5 min Ypos	16 bit integer only				 *
* 	B6 max Ypos	16 bit integer only				 *
* 	B7 min Yvel	16.16						 *
* 	B8 max Yvel	16.16						 *
* 	B9 min Zvel	16.16						 *
* 	B10 max Zvel	16.16						 *
* 									 *
* Note: If the velocities aren't quite correct for your application,	 *
* 	then use the Fragment function to adjust.			 *
*								         *
**************************************************************************
PreFrag_Rain

	MOVE	@ZBASE,B0,L
	ADDI	0E000H,B0
	MOVE	@XBASE+16,B1,W
	MOVE	B1,B2
	SUBI	85H,B1
	ADDI	85H,B2
	MOVE	A0,B4
	MOVE	B4,B3
	NEG	B3
	MOVE	@YBASE+16,B5,W
	SUBI	0B0H,B5
	MOVE	@WORLD_GRNDOFF+16,B6,W
	ADD	B6,B5
	MOVE	B5,B6
	MOVE	B3,B7
	MOVE	B4,B8
	MOVE	A3,B10
	MOVE	B10,B9
	NEG	B9

	RETS

**************************************************************************
*								         *
* Fragger - Create a fragment explosion process with the given		 *
* 		parameters.						 *
* 									 *
* PASS:									 *
* B0 = OZVAL								 *
* B1 = min Xpos								 *
* B2 = max Xpos								 *
* B3 = min Xvel								 *
* B4 = max Xvel								 *
* B5 = min Ypos								 *
* B6 = max Ypos								 *
* B7 = min Yvel								 *
* B8 = max Yvel								 *
* B9 = min Zvel								 *
* B10 = max Zvel							 *
* 									 *
* NOTE: min/max vals get sorted here, so you can pass them out of order. *
* 									 *
* B14 = Ptr to explosion script, it is NULL terminated with each entry	 *
* 	as follows:							 *
* 									 *
* 	.long	anim script (first frame of script used for init)	 *
* 	.long	func called after obj set up				 *
* 			A0 = obj (0 for none).				 *
* 			Must not trash: A8-A11 and ALL of B-File.	 *
* 	.word	OID							 *
* 	.word	# to create.5:# sleep tiks before next group.5:flags.6	 *
* 									 *
* flags:								 *
* 	FRGBOG		;IF SET, THEN CHECK BOG, IF BOGGED, KILL SCRIPT	 *
* 	FRGGCOL		;DO SET M_GCOLL (not set by default)		 *
* 	FRGNOFLY	;DON'T SET OYACCEL (set by default)		 *
* 	FRGNOFLP	;DON'T USE RndFlpX,RndFlpY of OBJECTS		 *
*	FRGRND		;Random frag count, between 0 and #-1 given.	 *
* 	FRGPAL		;CALL FPSTFOBJ					 *
* script flags that are currently undefined are reserved for future use	 *
* script is teminated w/ .long 0					 *
* 									 *
* NOTE: if Sleep longer than 31 needed, set # to create to 0		 *
*       if need to create more than 31, use sleep of 0			 *
* 									 *
* BIG NOTE:								 *
* ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ *
* IF POSSIBLE, USE PreFrag routines to set up the BREGs for this func	 *
* If a new case is needed, create another PreFrag function so		 *
* that it may be shared by others in the future.			 *
* ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ *
* 									 *
* Algorithm:								 *
* 									 *
* IF (min Xpos = max Xpos)						 *
* 	Xpos = min Xpos							 *
* 	Xvel = RANGERND (min Xvel, max Xvel)				 *
* ELSE									 *
* 	Xpos = RANGERND (min Xpos, max Xpos)				 *
* 									 *
* 	                    (Xpos - min Xpos)				 *
* 	Xvel = min Xvel + --------------------- * (max Xvel - min Xvel)  *
* 	                  (max Xpos - min Xpos)				 *
* 	   SRAND ((max Xvel - min Xvel)/4)				 *
* 									 *
* *** Y HANDLED SAME AS X ***						 *
*								         *
* RETURN:								 *
* A0 = FragProc PROCESS ADDRESS						 *
*      IF PROCESS CREATION FAILED, THEN A0 = 0 AND Z FLAG IS SET	 *
*								         *
**************************************************************************

;THESE OFFSETS ARE FOR Fragger TO REFERENCE SCRIPT ENTRIES
FRGFNC	.set	20H
FRGOID	.set	40H
FRGFLG	.set	50H
FRGSLP	.set	56H
FRGCNT	.set	5BH
FRGSIZE	.set	60H

Fragger
	mmtm	SP,A1,A7,A8
	cmp	B1,B2
	jrge	SkSwp1
	SWAP	B1,B2
SkSwp1:
	cmp	B3,B4
	jrge	SkSwp2
	SWAP	B3,B4
SkSwp2:
	cmp	B5,B6
	jrge	SkSwp3
	SWAP	B5,B6
SkSwp3:
	cmp	B7,B8
	jrge	SkSwp4
	SWAP	B7,B8
SkSwp4:
	cmp	B9,B10
	jrge	SkSwp5
	SWAP	B9,B10
SkSwp5
	move	B14,A8				;Script goes over in A8
	CREATE	PID_FRAG,FragProc
	jrz	Fragger_NoProc

	move	A0,B14
	addi	FPDATA,B14
	mmtm	B14,B0,B1,B2,B3,B4,B5,B6,B7,B8,B9,B10	;Push the pos and vel

	MOVE	A0,A0				;CLEAR Z FLAG 
Fragger_NoProc
	mmfm	SP,A1,A7,A8
	rets

**************************************************************************
*								         *
* FragProc - Process created by Fragger to actually do all of the	 *
* 		dirty work of creating the fragments.			 *
* A8 = Fragger script ptr						 *
*								         *
**************************************************************************
FragProc:
	move	A13,B14
	addi	PDATA,B14
	mmfm	B14,B0,B1,B2,B3,B4,B5,B6,B7,B8,B9,B10	;load 'em all

FrgNoSlp:
	move	*A8,A11,L		;get ptr to anim script
	jaz	SUCIDE			;no script -> frag process is done

	movb	*A8(FRGCNT),A0		;Load the fragment count this tick
	sll	27,A0
	srl	27,A0
	jrz	FrgSlp			;BR = Count is 0 -> Try sleeping

	movb	*A8(FRGFLG),A10
	btst	B_FRGBOG,A10		;Should we heed the BOG state?
	JRZ	FrgNoBogCk		;BR = No
	MOVE	@CPUAVG,A14,W
	CMPI	200,A14			;Are we Bogged?
	JALS	SUCIDE			;BR = Yes, cancel the script

	MOVE	@DMAAVG,A14,W
	CMPI	100,A14			;Are we Bogged?
	JALS	SUCIDE			;BR = Yes, cancel the script

FrgNoBogCk
	btst	B_FRGRND,A10		;Random fragment count?
	jrz	PreFragPLp		;BR = No, use the given value
	callr	RAND0			;Get the random value
	MOVE	A0,A0
	jrz	FrgSlp			;BR = Count is 0 -> Try sleeping
PreFragPLp
	move	A0,A9
FragPLp:
	calla	GETOBJ			;Grab an object
	jaz	SUCIDE			;BR = There are no more, bail out.
	move	B0,A3			;OZVAL
	move	A3,*A0(OZVAL),L

	move	*A11,A1,L		;Get the first frame of the animation

	btst	B_FRGPAL,A10		;Is somebody else providing the pal?
	jrz	NoPal			;BR = Yes, then don't stuff
	calla	FPSTFOBJ0		;Initialize object and allocate palette
	jruc	DidPal
NoPal
	calla	STFOBJ0			;Initialize object with no palette
DidPal

	orim	DMAWNZ,*A0(OCTRL),W	;Setup the correct bitz

	btst	B_FRGNOFLP,A10		;Should we randomly flip the object?
	jrnz	SkFlps			;BR = No. How boring
	movi	M_FLIPH|M_FLIPV,A14
	callr	RANDFLIP		;Flip it any which way
SkFlps:
	move	A11,*A0(AnimScr),L	;Initialize the animation fields
	move	A11,*A0(AnimFrm),L
	clr	A1
	movb	A1,*A0(AnimSlp)

	btst	B_FRGNOFLY,A10		;Should we give this frag gravity?
	jrnz	NoFly			;BR = No
	movi	02800H,A1
	move	A1,*A0(OYACCEL),W	;Stuff a gravity value
NoFly
****	btst	B_FRGCOL,A10
****	jrnz	SkNoColl
	ORIM	M_NOCOLL,*A0(OFLAGS),W	;Object NOT collidable
****SkNoColl:
	btst	B_FRGGCO,A10		;Make this object ground collidable?
	jrz	SkNoGCol		;BR = No
	ORIM	M_GCOLL,*A0(OFLAGS),W	;Stuff the ground coll flag
SkNoGCol:
	calla	INSANIM			;Set to animating

	;*** SET X-POSITION, X-VELOCITY ***
	move	B1,A4
	move	B2,A5
	move	B3,A6
	move	B4,A7
	callr	FrgPosVl	;rets A1 pos 16., A2 Vel 16.16
	move	A1,*A0(OXPOS),W
	move	A2,*A0(OXVEL),L
	;*** SET Y-POSITION, Y-VELOCITY ***
	move	B5,A4
	move	B6,A5
	move	B7,A6
	move	B8,A7
	callr	FrgPosVl	;rets A1 pos 16., A2 Vel 16.16
	move	A1,*A0(OYPOS),W
	move	A2,*A0(OYVEL),L
	;*** Set Z-Position, Z-velocity
	move	B0,A4
	move	B0,A5
	move	B9,A6
	move	B10,A7
	callr	FrgPosVl
	move	A2,*A0(OZVEL),L

	move	*A8(FRGOID),*A0(OID),W	;Give this thing an I.D.

	move	*A8(FRGFNC),A14,L	;Grab the function vector.
	jrz	NoFrgFnc		;Br = No function, No call
	call	A14			;Call the function
NoFrgFnc:
	calla	INSOBJ
	dsj	A9,FragPLp
FrgSlp:
	addi	FRGSIZE,A8
	movb	*A8(-FRGSIZE+FRGSLP),A0
	sll	27,A0
	srl	27,A0
	jrz	FrgNoSlp		;If sleep is 0 -> CONTINUE W/ SCRIPT

	calla	PRCSLP
	jruc	FragProc

**************************************************************************

**************************************************************************
FrgPosVl:
;A4 min pos
;A5 max pos
;A6 min vel
;A7 max vel
;RETS A1 pos, A2 vel

;IF (min pos = max pos)
;	pos = min pos
;	vel = RANGERND (min vel, max vel)
;ELSE
;	pos = RANGERND (min pos, max pos)
;
;	                    (pos - min pos)
;	vel = min vel + --------------------- * (max vel - min vel) +
;	                  (max pos - min pos)
;	   SRAND ((max vel - min vel)/4)
	PUSH	A0
	cmp	A4,A5
	jreq	FixedPos

	move	A4,A0
	move	A5,A1
	callr	RANGERND
	move	A0,A14		;A14 = Pos
	sub	A4,A0		;A0 = pos-minpos
	sub	A6,A7		;A7 = maxvel - minvel
	mpys	A7,A0	
	sub	A4,A5		;A5 = maxpos-minpos
	divs	A5,A0	
	add	A6,A0		;A0 = top line of vel func above

	;DO SRAND PORTION OF VEL FUNC
	move	A0,A2
	move	A14,A1
	sra	2,A7
	move	A7,A0
	abs	A0
	callr	SRAND
	add	A0,A2
	jruc	FrgPVX
FixedPos:
	move	A6,A0
	move	A7,A1
	callr	RANGERND
	move	A0,A2
	move	A4,A1
FrgPVX:
	move	A1,A4
	move	A2,A0
	movi	60000H,A1
	callr	ABSMAX
	move	A0,A2
	move	A4,A1

	PULLQ	A0
	rets

**************************************************************************
* RANDFLIP
* A0 OBJ
* A14 M_FLIPH or M_FLIPV or both
RANDFLIP
	mmtm	sp,a3,a4
	move	@RAND,a4,W
	and	a14,a4
	move	*a0(OCTRL),a3,W
	andn	a14,a3
	or	a4,a3
	move	a3,*a0(OCTRL),W
	mmfm	sp,a3,a4
	rets



**************************************************************************
MAX:
;* returns max of A0,A1 in A0
	cmp	A1,A0
	jrge	GotMax
	move	A1,A0
GotMax:
	rets

**************************************************************************
MIN:
;* returns min of A0,A1 in A0
	cmp	A1,A0
	jrle	GotMin
	move	A1,A0
GotMin:
	rets

**************************************************************************
*	With a pos or neg value if neg must be < -X
*	if pos must be > X
ABSMIN:
;parm A1 must be pos
;A0 will be negated if A1 is neg
	move	A0,A0
	jrn	NegMinE
	cmp	A1,A0
	jrge	MINOKE
	move	A1,A0
	rets
NegMinE:
	neg	A1
	cmp	A1,A0
	jrle	MINOKE
	move	A1,A0
MINOKE:
	rets

**************************************************************************
ABSMAX:
;* returns A0 Clipped at the value A1 in either pos or neg direction
;parm A1 must be pos
;A0 will be negated if A1 is neg
	move	A0,A0
	jrn	NegMax
	cmp	A1,A0
	jrle	MAXOK
	move	A1,A0
	rets
NegMax:
	neg	A1
	cmp	A1,A0
	jrge	MAXOK
	move	A1,A0
MAXOK:
	rets

**************************************************************************
ABSINC:
	move	A0,A0
	jrn	DECX
	inc	A0
	rets
DECX:
	dec	A0
	rets

**************************************************************************
ABSDEC:
	move	A0,A0
	jrz	ABSDECX
	jrn	INCX
	dec	A0
	rets
INCX:
	inc	A0
ABSDECX:
	rets

**************************************************************************
ABSSUB:
;* absolutely subtracts A1 from A0, A0 can't change signs
	move	A0,A0
	jrz	ABSSUBX
	jrn	SUBX
	sub	A1,A0
	jrp	SUBX1
	clr	A0
SUBX1:
	rets
SUBX:
	add	A1,A0
	jrn	SUBX2
	clr	A0
SUBX2:
ABSSUBX:
	rets

**************************************************************************
ABSADD:
;* absolutely ADD A1 to A0
	move	A0,A0
	jrn	ADDX
	add	A1,A0
	rets
ADDX:
	sub	A1,A0
	rets

**************************************************************************
MpyVel:
;A0 16.16 val to multiply velocity by
	mmtm	SP,A2,A3

	move	*A8(OXVEL),A2,L
	mpys	A0,A2		;A2 16.16, A0 16.16
	sll	16,A2		;16 bit mantissa
	srl	16,A3		;16 frac
	movy	A2,A3		;16.16 result
	move	A3,*A8(OXVEL),L

	move	*A8(OYVEL),A2,L
	mpys	A0,A2		;A2 16.16, A0 16.16
	sll	16,A2		;16 bit mantissa
	srl	16,A3		;16 frac
	movy	A2,A3		;16.16 result
	move	A3,*A8(OYVEL),L

	mmfm	SP,A2,A3
	rets

**************************************************************************
MpyXVel:
;A0 16.16 val to multiply velocity by
	mmtm	SP,A2,A3
	move	*A8(OXVEL),A2,L
	mpys	A0,A2		;A2 16.16, A0 16.16
	sll	16,A2		;16 bit mantissa
	srl	16,A3		;16 frac
	movy	A2,A3		;16.16 result
	move	A3,*A8(OXVEL),L
	mmfm	SP,A2,A3
	rets

**************************************************************************
MpyYVel:
	mmtm	SP,A2,A3
	move	*A8(OYVEL),A2,L
	mpys	A0,A2		;A2 16.16, A0 16.16
	sll	16,A2		;16 bit mantissa
	srl	16,A3		;16 frac
	movy	A2,A3		;16.16 result
	move	A3,*A8(OYVEL),L
	mmfm	SP,A2,A3
	rets

**************************************************************************
ALL_COLLS_OFF:
;REALLY MAKE SURE PART CAN NO LONGER COLLIDE
;A8 ptr to OBJ
	PUSH	A0
	move	A8,A0
COLLSOFFLP
	callr	COLLSOFF
	move	*A0(OPARTS),A0,L
	jrnz	COLLSOFFLP
	PULLQ	A0
	rets

**************************************************************************
COLLS_OFF:
;REALLY MAKE SURE PART CAN NO LONGER COLLIDE
;A8 ptr to OBJ
;OLD	PUSH	A0
;OLD	move	A8,A0
;OLD	callr	COLLSOFF
;OLD	PULLQ	A0
;OLD	rets

	ORIM	M_NOCOLL,*A8(OFLAGS),W
	CLRM	*A8(OCVECT),L
	move	a14,*A8(OGUNVECT),L
	rets

**************************************************************************
COLLSOFF:
;MAKE COMPLETELY SURE PART CAN NO LONGER COLLIDE
;A0 ptr to OBJ
	ORIM	M_NOCOLL,*A0(OFLAGS),W
	CLRM	*A0(OCVECT),L
	move	a14,*A0(OGUNVECT),L
	rets

**************************************************************************
*								         *
* SET_VECTORS - SET GUN AND COLLISION VECTORS OF HEAD AND PARTS		 *
* 									 *
* PASS:									 *
* A1 = GUNVECT								 *
* A2 = CVECT								 *
* A8 = HEAD OBJECT							 *
*								         *
* RETURN:								 *
* NUTIN'								 *
*								         *
**************************************************************************

SET_VECTORS
	PUSH	A0
	MOVE	A8,A0
SV_LUPE
	MOVE	A1,*A0(OGUNVECT),L	;GUN VECTOR
	MOVE	A2,*A0(OCVECT),L	;COLLISION VECTOR
	MOVE	*A0(OPARTS),A0,L
	JRNZ	SV_LUPE			;BR = YET ANOTHER PART
	PULLQ	A0
	RETS

**************************************************************************
*								         *
* 	PASTE_ON_DAMAGE							 *
* 	PASTE_ON_DAMAGE_XYZ						 *
* 									 *
* 	Paste on a piece of damage to an object.  This piece will	 *
* 	become part of the multi-parter.  Animation pnt of damage	 *
* 	will be set at the current cursor pnt of the gun causing	 *
* 	the damage.							 *
* 									 *
* 	A2 = Ptr to player that did damage				 *
* 	A8 = Object to paste damage onto				 *
* 	B0 = Ptr to init table of damage piece				 *
*								         *
* NOTE:									 *
* PASTE_ON_DAMAGE_XYZ DOES NOT USE THE CURSOR POSITION YOU MUST ALSO	 *
* PROVIDE:								 *
* 	A3 = UNIVERSE Z OF OBJECT TO PASTE ONTOP			 *
* 	A5 = UNIVERSE X							 *
* 	A9 = UNIVERSE Y							 *
* 									 *
* 	Returns:							 *
* 									 *
* 		B0 = Pointing to the next word after init table		 *
*								         *
**************************************************************************
PASTE_ON_DAMAGE_XYZ
	MMTM	SP,A0,A1,A2,A3,A5,A8,A9
	MMTM	SP,B1,B2,B3,B4,B5,B6,B7,B8,B9,B10
	JRUC	POD_XYZ
PASTE_ON_DAMAGE
	MMTM	SP,A0,A1,A2,A3,A5,A8,A9
	MMTM	SP,B1,B2,B3,B4,B5,B6,B7,B8,B9,B10

	MOVE	*A8(OZVAL),A3,L		;Make point Universe rel. at this Z
								
	MOVE	*A2(PCURSORXY),A9,L	;Get [Y,X] Screen relative point.
	MOVX	A9,A5
	SEXT	A5
	SRA	16,A9			;Now we have 16.16 screen X

	STOUXY	A3,A5,A9		;Use that funky Bill macro to convert
POD_XYZ	
	CALLA	EASYMAKE
	JRZ	POD_X			;BR = Creation failed, exit.

	MOVE	A5,A1			;UNIVERSE X
	MOVE	A9,A2			;UNIVERSE Y
	SUBK	32,A3			;ADJUST UNIVERSE Z

	CALLA	SETANIPU

	CALLA	INSPART

	CALLA	INSOBJ
POD_X
	MMFM	SP,B1,B2,B3,B4,B5,B6,B7,B8,B9,B10
	MMFM	SP,A0,A1,A2,A3,A5,A8,A9
	RETS

**************************************************************************
*								         *
* 	PASTE_ON_DAMAGE_OFFSET						 *
* 	PASTE_ON_DAMAGE_OFFSET_XYZ					 *
* 									 *
* 	Paste on a piece of damage to an object.  This piece will	 *
* 	become part of the multi-parter.  Animation pnt of damage	 *
* 	will be set at the current cursor pnt of the gun causing	 *
* 	the damage. OZOFF AND OPARTSXY WILL ALSO BE SET.		 *
* 									 *
* 	A2 = Ptr to player that did damage				 *
* 	A8 = Object to paste damage onto				 *
* 	B0 = Ptr to init table of damage piece				 *
*								         *
* NOTE:									 *
* PASTE_ON_DAMAGE_OFFSET_XYZ DOES NOT USE THE CURSOR POSITION YOU MUST	 *
* ALSO PROVIDE:								 *
* 	A5 = UNIVERSE X							 *
* 	A9 = UNIVERSE Y							 *
* 									 *
* 	Returns:							 *
* 									 *
* 		B0 = Pointing to the next word after init table		 *
*								         *
**************************************************************************

PASTE_ON_DAMAGE_OFFSET_XYZ
	MMTM	SP,A0,A1,A2,A3,A5,A8,A9
	MMTM	SP,B1,B2,B3,B4,B5,B6,B7,B8,B9,B10
	CALLA	GET_HEAD_PART
	MOVE	*A8(OZVAL),A3,L		;Make point Universe rel. at this Z
	JRUC	PODO_XYZ
PASTE_ON_DAMAGE_OFFSET
	MMTM	SP,A0,A1,A2,A3,A5,A8,A9
	MMTM	SP,B1,B2,B3,B4,B5,B6,B7,B8,B9,B10

	CALLA	GET_HEAD_PART

	MOVE	*A8(OZVAL),A3,L		;Make point Universe rel. at this Z
								
	MOVE	*A2(PCURSORXY),A9,L	;Get [Y,X] Screen relative point.
	MOVX	A9,A5
	SEXT	A5
	SRA	16,A9			;Now we have 16.16 screen X

	STOUXY	A3,A5,A9		;Use that funky Bill macro to convert
PODO_XYZ	
	CALLA	EASYMAKE
	JRZ	PODO_X			;BR = Creation failed, exit.

	MOVE	*A8(OXVAL),A1,L
	SUB	A1,A5			;X WORLD OFFSET
	SRA	15,A5			;X SCREEN OFFSET

	MOVE	*A8(OYVAL),A2,L
	SUB	A2,A9			;Y WORLD OFFSET
	SRA	15,A9			;Y SCREEN OFFSET
	SLL	16,A9
	MOVY	A9,A5			;OPARTSXY

	MOVE	*A8(OPARTSXY),A14,L
	ADD	A14,A5			;FROM OPARTSXY OF HEAD
	MOVE	A5,*A0(OPARTSXY),L

	MOVB	*A8(OZOFF),A14
	SUBK	32,A14			;FROM OZOFF OF HEAD
	MOVB	A14,*A0(OZOFF)

	CALLA	SETOFFPU

	CALLA	INSPART

	CALLA	INSOBJ
PODO_X
	MMFM	SP,B1,B2,B3,B4,B5,B6,B7,B8,B9,B10
	MMFM	SP,A0,A1,A2,A3,A5,A8,A9
	RETS


	.END

