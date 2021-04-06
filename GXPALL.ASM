	.MLIB	"GXMACS.LIB"
	.FILE	"GXPALL.ASM"
	.TITLE	"<<< GENERATION X -- PALETTE ALLOCATOR V1.0 >>>"
	.WIDTH	132
	.OPTION	B,D,L,T
	.MNOLIST

**************************************************************************
*								         *
* 	COPYRIGHT (C) 1992 MIDWAY MANUFACTURING COMPANY.		 *
* 		       ALL RIGHTS RESERVED.				 *
*								         *
**************************************************************************

	.INCLUDE	"GX.INC"		;System equates

*IN THIS MODULE
	.DEF	PALSET, INIT_PAL, CHANGE_PAL_CHECK, A_CHANGE_PAL_MULTI

*
*PALETTE TRANSFER QUEUE EQUATES
*
PALQ_ENTRY_SIZE	.EQU	32+16+16		;SRC 32, DEST 16, # COLS 16
PALQ_MAX_ENTRY	.EQU	64			;MAX NUMBER OF ENTRIES
PALQ_SIZE	.EQU	PALQ_ENTRY_SIZE*PALQ_MAX_ENTRY
MAX_TRANSFERS	.EQU	18	;NUMBER OF TRANSFERS ALLOWED PER V-BLANK


	.BSS	PALTRANS_QUEUE,PALQ_SIZE	;PALETTE TRANSFER QUEUE
	.BSS	PALTRANS_START,32		;START PTR IN PALTRANS QUEUE
	.BSS	PALTRANS_END,32			;END PTR IN PALTRANS QUEUE
	.BSS	PALTRANS_COUNT,16
	.BSS	PALTRANS_FLAG,16
	.BSS	FREEPALCNT,16,1
		      			;  removed BLACKOUT
	.BSS	BLACKPAL,16*256
	.BSS	FILLER,16			;SET BACKPAL FLAG

	.TEXT

**************************************************************************
*								         *
* CLR_0PALS - ROUTINE CLEAR THE PALID FIELD OF ANY PALETTE THAT HAS	 *
* 	    ZERO PEOPLE USING IT.					 *
*								         *
**************************************************************************
CLR_0PALS
	PUSH	A1
	MOVI	NUMPAL,B14
	MOVI	PALRAM,A1	
C0_LP
	MOVE	*A1(PALCNT),A14,W	;CHECK ALLOCATION COUNT.
	JRNZ	C0_NXT			;BR = THIS ONE IS IN USE
	MOVE	A14,*A1(PALID),L	;CLEAR THE I.D.
C0_NXT
	ADDI	PALRSIZ,A1
	DSJS	B14,C0_LP
	PULLQ	A1
	RETS
	
**************************************************************************
*								         *
* INC_PALCNT -INCREMENT THE PALETTE COUNT BY WAY OF THE PALETTE #	 *
* A5 = PALETTE NUMBER							 *
*								         *
**************************************************************************
INC_PALCNT
	PUSH	A5
	SLL	24,A5
	SRL	24,A5		;MASK OFF ANY NON-SENSE
	sll	6,a5		; since PALRSIZ = 40h
************************************************************************
*   IF PALRSIZ IS NOT A POWER OF TWO, REPLACE THE ABOVE LINE WITH...	
*	MOVI	PALRSIZ,A14	; old way
*	MPYU	A14,A5
************************************************************************
	ADDI	PALRAM,A5
	INCM	*A5(PALCNT),W		;INCREMENT THAT PALETTE COUNT
	PULLQ	A5
	RETS

**************************************************************************
*								         *
* A_CHANGE_PAL - ANIM FUNC TO CHANGE THE PALETTE TO THE GIVEN		 *
* A8 = PTR TO OBJECT							 *
* *A8(AnimFrm),L = PTR TO PALETTE I.D.					 *
* NOTE: ANIM FUNCS DO NOT PUSH REGISTERS!				 *
*								         *
**************************************************************************
A_CHANGE_PAL
	CALLA	GETAFARG_LONG
	CALLR	CHANGE_PAL
	RETS

**************************************************************************
*								         *
* A_CHANGE_PAL_MULTI - ANIM FUNC TO CHANGE THE PALETTE TO THE GIVEN	 *
* A8 = PTR TO HEAD OBJECT						 *
* *A8(AnimFrm),L = PTR TO PALETTE I.D.					 *
* NOTE: ANIM FUNCS DO NOT PUSH REGISTERS!				 *
*								         *
**************************************************************************
A_CHANGE_PAL_MULTI
	CALLA	GETAFARG_LONG
	CALLR	CHANGE_PAL_MULTI
	RETS

**************************************************************************
*								         *
* GET_PALID - ROUTINE TO RETURN THE I.D. OF AN ALLOCATED PALETTE.	 *
* A0 = CURRENT PALETTE NUMBER						 *
* RETURNS:								 *
* A0 = PALETTE I.D.							 *
*								         *
**************************************************************************
GET_PALID
;	PUSH	A1
	SLL	24,A0		;MASK OFF GARBAGE
	SRL	24,A0

	CMPI	NUMPAL,A0 	;ERROR...PALETTE NUMBER ERRONEOUS
	JRLO	GPID_1

	LOCKUP

GPID_1
	sll	6,a0		; since PALRSIZ = 40h
	ADDI	PALRAM,A0
	MOVE	*A0,A0,L

************************************************************************
*   IF PALRSIZ IS NOT A POWER OF TWO, REPLACE THE ABOVE 3 LINES WITH...	
*	MOVI	PALRSIZ,A1	; old way
*	MPYU	A0,A1
*	ADDI	PALRAM,A1
*	MOVE	*A1,A0,L
************************************************************************
;	PULL	A1
	RETS

**************************************************************************
*								         *
* 	CHANGE_PAL_CHECK						 *
* 									 *
* 	Same as CHANGE_PAL, except checks first to see if the		 *
* 	palette needs changing.						 *
*								         *
**************************************************************************
CHANGE_PAL_CHECK
	PUSH	A0
	MOVE	*A8(OPAL),A0,W
	CALLR	GET_PALID		;Get I.D. of current
	MOVE	A0,A14
	PULLQ	A0
	CMP	A0,A14			
	JRNE	CHANGE_PAL		;BR = Not the same, take new
	RETS

**************************************************************************
*								         *
* CHANGE_PAL - CHANGE AN OBJECTS CURRENT PALETTE TO A NEW ONE.		 *
* 		DELETES THE OBJECTS OLD PALETTE.			 *
* 		IF NO NEW PALETTES ARE AVAILABLE, THEN PALETTE		 *
* 		0 IS STUFFED.						 *
* A0 = I.D. OF NEW PALETTE						 *
* A8 = OBJECT								 *
* RETURNS:								 *
* 	 Z = FAILURE ALLOCATING NEW PALETTE				 *
* 		A0 = 0							 *
* 	NZ = PALETTE CHANGE SUCCESSFUL.					 *
* 		A0 = NEW PALETTE NUMBER					 *
*								         *
**************************************************************************
CHANGE_PAL
	CALLR	DELETE_PAL		;DELETE OLD
	CALLA	GETFPAL			;GET A COLOR MAP ASSIGNMENT
	JRNZ	CP_SUCCESS		;BR = USE IT
	MOVE	*A8(OPAL),A0,W		;GET THE OLD PALETTE
	CALLA	GET_PALID
	CALLA	GETFPAL			;RESTORE OLD ASSIGNMENT
CP_SUCCESS
	MOVE	A0,*A8(OPAL),W		;STORE THE NEW PALETTE
	RETS

**************************************************************************
*								         *
* CHANGE_PAL_MULTI - CHANGE THE PALETTE OF A MULTI-PART OBJECT		 *
* 		   FROM THE GIVEN OBJECT ON DOWN.			 *
* A0 = PTR TO NEW PALETTE						 *
* A8 = PTR TO PART							 *
*								         *
**************************************************************************
CHANGE_PAL_MULTI
	MMTM	SP,A1,A8
	MOVE	A0,A1
CPM_LP
	CALLR	CHANGE_PAL
	MOVE	A1,A0			;RESTORE PALETTE I.D.
	MOVE	*A8(OPARTS),A8,L
	JRNZ	CPM_LP
CPM_X
	MMFM	SP,A1,A8
	RETS

**************************************************************************
*								         *
* DELETE_PAL - DELETE AN OBJECTS PALETTE				 *
* A8 = PTR TO OBJECT							 *
*								         *
**************************************************************************
DELETE_PAL:
	PUSH	A0
	MOVE	*A8(OPAL),A0,W	; save extra push and pop of a0
	CALLR	FREEPAL		; and extra call
	PULL	A0
	RETS

**************************************************************************
*                                                                        *
* DELPAL - DELETE AN OBJECTS PALETTE					 *
* A0 = PTR TO OBJECT							 *
*                                                                        *
**************************************************************************
DELPAL
	PUSH	A0
	MOVE	*A0(OPAL),A0,W
	CALLR	FREEPAL
	PULLQ	a0		
	RETS

**************************************************************************
*                                                                        *
* FINDPAL - FIND THE COLOR MAP # TO WHICH THE GIVEN PALETTE IS ASSIGNED. *
* A0 = 32 BIT PALETTE ADDRESS 						 *
* RETURNS:								 *
* Z BIT SET = PALETTE NOT FOUND ---> A0 = 0				 *
* Z BIT CLR = PALETTE FOUND ---> A0 = PALETTE #(CORRECT FORMAT FOR DMA)	 *
*                                                                        *
**************************************************************************
FINDPAL
	MMTM	SP,A1,A2,A3
	MOVI	NUMPAL,A3
	MOVI	PALRAM,A1	
FINDPAL0
	MOVE	*A1,A2,L	;GET PALETTE ID
	CMP	A0,A2
	JREQ	FINDPAL1	;FOUND
	ADDI	PALRSIZ,A1
	DSJS	A3,FINDPAL0
	CLR	A0		;SET Z BIT ---> FAILURE
	JRUC	FINDPALX
FINDPAL1
	SUBI	NUMPAL,A3	;COMPUTE PALETTE #
	NEG	A3

	MOVE	A3,A0 	      	;RETURN PALETTE #
	SLL	8,A3
	ADD	A3,A0 		;DOUBLE IT UP FOR LOFFREDO BRAIN DAMAGE
	INC	A3		;CLR Z BIT ---> SUCCESS
FINDPALX
	MMFM	SP,A1,A2,A3
	RETS

**************************************************************************
*                                                                        *
* INITPAL - GET A PALETTE FOR USE					 *
* A14 = POINTER TO OBJECT INITIALIZATION TABLE				 *
* RETURNS:								 *
* ZBIT SET = FAILURE							 *
* ZBIT CLR = SUCCESS --> VAR. CURPAL = PALETTE # JUST CREATED		 *
*                                                                        *
**************************************************************************
;INITPAL
;	MMTM	SP,A0
;  	MOVE	*A14(INITIMG),A0,L
;	MOVE	*A0(ICMAP),A0,L		;GET THE PALETTE NAME
;	CALLR	GETFPAL			;GET A PALETTE
;	JRZ	INITPALX		;SUCCESSFUL PALETTE CREATION
;	MOVE	A0,@CURPAL,W		;STUFF THIS IN CURRENT PAL
;INITPALX
;	MMFM	SP,A0
;	RETS

**************************************************************************
*								         *
* INIT_PAL - GET A PALETTE FOR USE. THIS IS THE NEW VERSION.		 *
* A1 = POINTER TO IMAGE HEADER						 *
* RETURNS:								 *
* 	 Z = FAILURE							 *
* 		A0 = 0							 *
* 	NZ = SUCCESS							 *
* 		A0 = PALETTE NUMBER					 *
*								         *
**************************************************************************
INIT_PAL
	MOVE	*A1(ICMAP),A0,L		;GET THE PALETTE NAME
	JRUC	GETFPAL			;GET A PALETTE

**************************************************************************
*                                                                        *
* INITBPAL - GET A BACKGROUND PALETTE FOR USE				 *
* A14 = POINTER TO OBJECT INITIALIZATION TABLE				 *
* RETURNS:								 *
* ZBIT SET = FAILURE							 *
* ZBIT CLR = SUCCESS --> VAR. CURPAL = PALETTE # JUST CREATED		 *
*                                                                        *
**************************************************************************
;INITBPAL
;	MMTM	SP,A0
;  	MOVE	*A14(INITIMG),A0,L
;	MOVE	*A0(ICMAP),A0,L		;GET THE PALETTE NAME
;	CALLR	GETBPAL			;GET A BACKGROUND PALETTE
;	JRZ	INITBPLX		;SUCCESSFUL PALETTE CREATION
;	MOVE	A0,@CURPAL,W		;STUFF THIS IN CURRENT PAL
;INITBPLX
;	MMFM	SP,A0
;	RETS

*
*CLEAR OUT PALETTE ALLOCATION RAM
*
CLRPAL:
	MMTM	SP,A0,A1,A2
	
	movi	NUMPAL,A0
	move	A0,@FREEPALCNT,W

	MOVI	FPALRAM,A0,L		;GET ADDRESS OF RAM
	MOVI	PALRSIZ*NUMPAL/16,A2	;GET # OF WORDS
	CLR	A1
CLRPALP:
	MOVE	A1,*A0+,W
	DSJS	A2,CLRPALP

	MOVE	A1,@PALTRANS_COUNT,W	;NOTHING IN QUEUE
	MOVI	PALTRANS_QUEUE,A0
	MOVE	A0,@PALTRANS_START,L	;EMPTY QUEUE (START = END = QSTART)
	MOVE	A0,@PALTRANS_END,L

;CLRPTR:
;	MOVI	PTRRAM,A0,L		;GET ADDRESS OF RAM
;	MOVI	PTRSIZ*NUMPTR/16,A2	;GET # OF WORDS
;CLRPLP1:
;	MOVE	A1,*A0+,W
;	DSJS	A2,CLRPLP1

	CLRM	@BLACKOUT,W

	MMFM	SP,A0,A1,A2
	RETS
*
*CLEAR ONLY FOREGROUND PALETTES
CLRFPAL:
	MMTM	SP,A0,A1,A2
	MOVI	FPALRAM,A0,L		;GET ADDRESS OF RAM
	MOVI	PALRSIZ*NMFPAL/16,A2	;GET # OF WORDS
	CLR	A1
	JRUC	CLRPALP
*
*CLEAR ONLY BACKGROUND PALETTES
CLRBPAL:
	MMTM	SP,A0,A1,A2
	MOVI	BPALRAM,A0,L		;GET ADDRESS OF RAM
	MOVI	PALRSIZ*NMBPAL/16,A2	;GET # OF WORDS
	CLR	A1
	JRUC	CLRPALP

**************************************************************************
*								         *
* GETFPAL - ALLOCATE A FOREGROUND PALETTE, IF THERE ARE NO FOREGROUND	 *
* 	  PALETTES LEFT, THEN IT WILL ATTEMPT TO ALLOCATE A		 *
* 	  BACKGROUND PALETTE.						 *
* A0 = PALETTE ID (ADDRESS OF COLOR DATA)				 *
* RETURNS:								 *
* 	 Z = FAILURE, NO PALETTES FREE					 *
* 		A0 = 0							 *
* 	NZ = PALETTE ALLOCATED						 *
* 		A0 = COLOR MAP (0000 - 0F0F)				 *
*								         *
**************************************************************************
GETFPAL:
	MMTM	SP,A1,A2,A3
	CMPI	ROM,A0
	JRHS	GETFPAL_OK
	LOCKUP
	CLR	A0
	JRUC	GETPLX

GET_SPARE_PAL:			; skip check to see if already loaded
	MMTM	SP,A1,A2,A3	; 
	JRUC	GETSPARE	; 

GETFPAL_OK:
*CHECK IF PALETTE ALREADY EXISTS
	MOVI	NUMPAL,A3
	MOVI	PALRAM,A1	
GETPL0:
	MOVE	*A1,A2,L	;GET PALETTE ID
	CMP	A0,A2
	JREQ	GETPL3		;ALREADY IN COLOR RAM
	ADDI	PALRSIZ,A1
	DSJS	A3,GETPL0

GETSPARE:		
*CHECK FOR A SPARE PALETTE
	MOVI	FPALRAM,A1
	MOVI	NMFPAL,A3      	;CHECK ALL PALETTES
GETPL1:	
	MOVE	*A1(PALCNT),A2,W
	JRNE	CKNXTFPAL		;PALETTE NOT EMPTY

	;CHECK TIME WHEN FREED, CAN'T REALLOCATE ON SAME TIK
	MOVE	*A1(PALTIME),A2,W
	JRZ	GTFPL2
	MOVE	@WAVEDISPS,A14,W	;ENOUGH TIME ELAPSED?
	CMP	A2,A14
	JRNE	GTFPL2		;PALETTE OK TO GRAB
CKNXTFPAL
	ADDI	PALRSIZ,A1
	DSJS	A3,GETPL1
	CLR	A0		;NO PALETTES DEFAULT 0 AND 
	JRUC	GETPLX		;SPLIT

;	JRUC	GETFPAL_2ND	;NO FOREGROUND PALETTES, STEAL A BACKGROUND

**************************************************************************
*								         *
* GETBPAL - ALLOCATE A BACKGROUND PALETTE				 *
* A0 = PALETTE ID (ADDRESS OF COLOR DATA)				 *
* RETURNS:								 *
* 	 Z = FAILURE, NO PALETTES FREE					 *
* 	NZ = PALETTE ALLOCATED (A0 = COLOR MAP (0000 - 0F0F))		 *
*								         *
**************************************************************************
GETBPAL:
	MMTM	SP,A1,A2,A3
	CMPI	ROM,A0
	JRHS	GETBPAL_OK
	LOCKUP
	CLR	A0
	JRUC	GETPLX
GETBPAL_OK:
*CHECK IF PALETTE ALREADY EXISTS
	MOVI	NUMPAL,A3
	MOVI	PALRAM,A1	
GTBPL0:
	MOVE	*A1,A2,L	;GET PALETTE ID
	CMP	A0,A2
	JREQ	GETPL3		;ALREADY IN COLOR RAM
	ADDI	PALRSIZ,A1
	DSJS	A3,GTBPL0

;*CHECK FOR A SPARE BACKGROUND PALETTE
;*ALSO A SECOND CHANCE FOR FOREGROUND ALLOCATION
;GETFPAL_2ND:
	MOVI	BPALRAM,A1
	MOVI	NMBPAL,A3      	;CHECK ALL PALETTES
GTBPL1:	
	MOVE	*A1(PALCNT),A2,W
	JRNE	CKNXTBPAL		;PALETTE NOT EMPTY

	;CHECK TIME WHEN FREED, CAN'T REALLOCATE ON SAME TIK
	MOVE	*A1(PALTIME),A2,W
	JRZ	GETPL2
	MOVE	@WAVEDISPS,A14,W	;ENOUGH TIME ELAPSED?
	CMP	A2,A14
	JRNE	GETPL2		;PALETTE OK TO GRAB
CKNXTBPAL

	ADDI	PALRSIZ,A1
	DSJS	A3,GTBPL1
***	MOVE	A3,A3		;NO PALETTES LEFT SET ZERO BIT
	CLR	A0		;NO PALETTES DEFAULT 0 AND 
	JRUC	GETPLX		;SPLIT
*SETUP YOUR NEW PALETTE
GTFPL2:
	ADDI	NMBPAL,A3
GETPL2:
	DECM	@FREEPALCNT,W
	MMTM	SP,A0,A1,A2
	MOVE	A3,A1		;PALETTE #
	SUBI	NUMPAL,A1	;COMPUTE PALETTE #
	NEG	A1

	SLL	8,A1		;X 256
	MOVE	*A0+,A2,W	;GET # COLORS IN PALETTE
	MOVE	@BLACKOUT,A14,W
;	DEC	A14		;IF 1, THEN USE BLACKPAL
;	JRNZ	GP_NOBO		;BR=DON'T USE BLACKPAL
	JRZ	GP_NOBO		;BR=DON'T USE BLACKPAL
	MOVI	BLACKPAL,A0
GP_NOBO
	CALLR	PALSET		;SETUP PALETTE TRANSFER
	MMFM	SP,A0,A1,A2
	JREQ	GETPLX		;FAILED TO GET TRANSFER
	MOVE	A0,*A1,L	;STUFF PALETTE I.D.
GETPL3:
	SUBI	NUMPAL,A3	;COMPUTE PALETTE #
	NEG	A3

	MOVE	A3,A0 	      	;RETURN PALETTE #
	SLL	8,A3
	ADD	A3,A0	      		;DOUBLE IT UP FOR LOFREDO BRAIN DAMAGE
	MOVE	*A1(PALCNT),A2,W	;INCREMENT COUNT
	ADDK	1,A2			;SET NE FOR SUCCESS 
	MOVE	A2,*A1(PALCNT),W
GETPLX:
	MMFM	SP,A1,A2,A3
	RETS
*	
*FREE A PALETTE	
*A0=PALETTE # (0-NUMPAL) TO FREE
*
FREEPAL:	
	MMTM	SP,A0,A1
	SLL	24,A0		;MASK OFF GARBAGE
	SRL	24,A0

	CMPI	NUMPAL,A0 	;ERROR...PALETTE NUMBER ERRONEOUS
	JRLO	FREEPAL1

	LOCKUP

FREEPAL1
	move	a0,a1
	sll	6,a1		; since PALRSIZ=40h
************************************************************************
*   IF PALRSIZ IS NOT A POWER OF TWO, REPLACE THE ABOVE LINE WITH...	
*	MOVI	PALRSIZ,A1	; old way
*	MPYU	A0,A1
************************************************************************
	ADDI	PALRAM,A1
	MOVE	*A1(PALCNT),A0,W
	DEC	A0    			;DECREMENT ITS COUNT
	JRNN	FREEPAL2

	LOCKUP

	CLR	A0
	MOVE	A0,*A1(PALCNT),W
	JRUC	FREE_PAL_SKIP_CNT_INC

FREEPAL2
	MOVE	A0,*A1(PALCNT),W
	JRP	SkPalFree

	INCM	@FREEPALCNT,W

FREE_PAL_SKIP_CNT_INC
	;RECORD TIME WHEN FREED, CAN'T REALLOCATE ON SAME TIK
	MOVE	@WAVEDISPS,A0,W		;CLOCK IT BOYEEE!
	MOVE	A0,*A1(PALTIME),W
SkPalFree

FREPLX:
	MMFM	SP,A0,A1
	RETS

*	
*UNGETPAL - Clears out a palettes allocation count
*A0=PALETTE # (0-NUMPAL) TO UNALLOCATE
*
UNGETPAL:	
	MMTM	SP,A0,A1
	SLL	24,A0		;MASK OFF GARBAGE
	SRL	24,A0

	CMPI	NUMPAL,A0 	;ERROR...PALETTE NUMBER ERRONEOUS
	JRLO	UNGPAL1

	LOCKUP
	
UNGPAL1
	move	a0,a1
	sll	6,a1		; since PALRSIZ=40h
************************************************************************
*   IF PALRSIZ IS NOT A POWER OF TWO, REPLACE THE ABOVE 2 LINES WITH...	
*	MOVI	PALRSIZ,A1	; old way
*	MPYU	A0,A1
************************************************************************
	ADDI	PALRAM,A1
	MOVE	*A1(PALCNT),A14,W
	JRZ	UNGPALX
	INCM	@FREEPALCNT,W

	clr	A0
	MOVE	A0,*A1(PALCNT),W
	;RECORD TIME WHEN FREED, CAN'T REALLOCATE ON SAME TIK
	MOVE	@WAVEDISPS,A0,W		;CLOCK'N TIME WITH FLAVOR
	MOVE	A0,*A1(PALTIME),W
UNGPALX
	MMFM	SP,A0,A1
	RETS

**************************************************************************
*								         *
* PALSET - SETUP PALETTE TRANSFER FOR THE NEXT VERTICAL BLANK		 *
* A0 = ADDRESS OF PALETTE COLOR DATA					 *
* A1 = BIT 8-15 DESTINATION PALETTE | BIT 0-7 START COLOR		 *
* A2 = 16 BIT COLOUR COUNT						 *
* RETURNS:								 *
* 	NZ = FOR COMPATIBILTY						 *
* 									 *
* NOTE: THIS NOW USES THE JAMIE CIRCULAR QUEUE METHOD			 *
*								         *
**************************************************************************
PALSET
	PUSH	A3

	MOVK	1,A3
	MOVE	A3,@PALTRANS_FLAG,W	;YES WE ARE FUCKING WITH THIS QUEUE

	MOVE	@PALTRANS_COUNT,A14,W
	CMPI	PALQ_MAX_ENTRY,A14	;DOES OUR QUEUE RUNNETH OVER?
	JRHS	PS_OVERFLOW		;BR = YES

	INC	A14
	MOVE	A14,@PALTRANS_COUNT,W

	MOVE	@PALTRANS_END,A3,L

	MOVE	A0,*A3+,L		;PAL SOURCE ADDRESS
	MOVE	A1,*A3+,W		;PAL DEST ADDRESS
	MOVE	A2,*A3+,W		;NUMBER COLOURS

	.IF DEBUG
	CMPI	256,A2		;Sanity check on number of colors
	JRHI	$		;ERROR! color count fucked
	.ENDIF

	CMPI	PALTRANS_QUEUE+PALQ_SIZE,A3	;IF PTR RUNS OFF END OF
	JRLT	NO_WRAP				;QUEUE THEN WRAP AROUND
	MOVI	PALTRANS_QUEUE,A3		;TO THE START
NO_WRAP
	MOVE	A3,@PALTRANS_END,L

PS_FINIS
	CLR	A14
	MOVE	A14,@PALTRANS_FLAG,W	;WE STOPPED FUCKING WITH THIS QUEUE

	MOVE	A3,A3			;MAKE SURE WE'RE NON-ZERO

	PULL	A3
	RETS

PS_OVERFLOW
	CLR	A3			;MAKE SURE WE RETURN FAILURE
	JRUC	PS_FINIS

**************************************************************************
*								         *
* PALTRANS - ROUTINE TO TRANSFER ANY QUEUED PALETTES TO COLOR RAM.	 *
* 	   CALLED DURING VBLANK.					 *
* 	   ONLY ALLOWED TO TRANSFER "MAX_TRANFERS" PALETTES AT A TIME.	 *
* NOTE: TRASHES   : A0-A7						 *
* INTERNAL REGISTER USAGE:						 *
* A0 = Q_START								 *
* A1 = Q_COUNT								 *
* A2 = SRC								 *
* A3 = DEST								 *
* A4 = COL_COUNT							 *
* A5 = COLOR_BASELTRANS							 *
* A6 = TEMP								 *
* A7 = TRANSFER COUNT							 *
*								         *
**************************************************************************
PALTRANS:
	MOVE	@PALTRANS_FLAG,A0,W	;IS THE QUEUE IN FLUX?
	JRNZ	PT_QUEUE_EMPTY		;BR = YES, DON'T FUCK AROUND

	MOVE	@PALTRANS_COUNT,A1,W	;GET THE COUNT
	JREQ	PT_QUEUE_EMPTY
	
	MOVE	@PALTRANS_START,A0,L	;QUEUE START POS
;	MOVE	@PALTRANS_END,A1,L	;QUEUE END POS
;	CMP	A0,A1			;START = END ?
;	JREQ	PT_QUEUE_EMPTY

   	MOVK	MAX_TRANSFERS,A7	;MAXIMUM TRANSFERS THIS V-BLANK
	MOVI	COLRAM,A5		;BASE ADDRESS OF COLOR RAM

PT_NEXT_PAL
	MOVE	*A0+,A2,L	;PALETTE SOURCE ADDRESS
	MOVE	*A0+,A3,W	;PALETTE DESTINATION ADDRESS
	MOVE	*A0+,A4,W	;NUMBER OF COLORS IN PALETTE

	CMPI	256,A4		;Sanity check on number of colors
	.IF DEBUG
	JRHI	$		;ERROR! color count fucked
	.ELSE
	JRLS	PT_COLCOUNT_OK	;BR = Color count O.K.
	MOVI	256,A4		;Top it off for safety-kleen
	.ENDIF

PT_COLCOUNT_OK
	ZEXT	A3

	SLL	5,A3		; XUNIT

	ADD	A5,A3		; + COLOR RAM BASE ADDRESS

	SRL	1,A4		;/2
	JRNC	PT_NO_1
	MOVE	*A2+,A14,W	; XUNIT
	move	a14,*A3+,L	; XUNIT  DO 1 COLOR
PT_NO_1
	SRL	1,A4		;/4
	JRNC	PT_NO_2
	MOVE	*A2+,a14,L	; XUNIT
	move	a14,*A3+,L	; XUNIT DO 2 COLORS
	srl	16,a14		; XUNIT
	move	a14,*A3+,L	; XUNIT 
PT_NO_2
	SRL	1,A4		;/8
	JRNC	PT_NO_4
	MOVE	*A2+,A14,L	; XUNIT
	move	a14,*A3+,L	; XUNIT DO 4 COLORS
	srl	16,a14		; XUNIT
	move	a14,*a3+,L	; XUNIT
	MOVE	*A2+,A14,L	; XUNIT
	move	a14,*A3+,L	; XUNIT
	srl	16,a14		; XUNIT
	move	a14,*a3+,L	; XUNIT
	move	a4,a4		; XUNIT
PT_NO_4
	JRZ	PT_PAL_DONE	;COUNT = 0 ?
PT_XFER_LOOP
	MOVE	*A2+,A14,L	; XUNIT
	move	a14,*A3+,L	; XUNIT DO 8 COLORS
	srl	16,a14		; XUNIT
	move	a14,*a3+,L	; XUNIT
	MOVE	*A2+,A14,L	; XUNIT
	move	a14,*A3+,L	; XUNIT
	srl	16,a14		; XUNIT
	move	a14,*a3+,L	; XUNIT
	MOVE	*A2+,A14,L	; XUNIT
	move	a14,*A3+,L	; XUNIT
	srl	16,a14		; XUNIT
	move	a14,*a3+,L	; XUNIT
	MOVE	*A2+,A14,L	; XUNIT
	move	a14,*A3+,L	; XUNIT
	srl	16,a14		; XUNIT
	move	a14,*a3+,L	; XUNIT
	DSJS	A4,PT_XFER_LOOP
PT_PAL_DONE
	CMPI	PALTRANS_QUEUE+PALQ_SIZE,A0	;IF PTR RUNS OFF END OF
	JRLT	PT_NO_WRAP			;QUEUE THEN WRAP AROUND
	MOVI	PALTRANS_QUEUE,A0		;TO THE START
PT_NO_WRAP
	DEC	A1			;HAVE WE DONE ALL TRANSFERS?
	JRZ	PT_DONE			;BR = YES
	DSJ	A7,PT_NEXT_PAL		;DO NEXT IF WE DIDN'T MAX OUT FOR VBLK

;	CMP	A0,A1			;START=END=QUEUE EMPTY?
;	JRNE	PT_NEXT_PAL		;BR = NO

PT_DONE
	MOVE	A1,@PALTRANS_COUNT,W	;SAVE THE COUNTER
	MOVE	A0,@PALTRANS_START,L	;SAVE QUEUE START POS

PT_QUEUE_EMPTY
	RETS


**************************************************************************
*								         *
* PALTRANS - ROUTINE TO XFER ANY PALETTES TO COLOR RAM.			 *
* 	   CALLED DURING VBLANK.					 *
* PTRRAM = PALETTE TRANSFER AREA					 *
* NOTE: TRASHES A0 - A13						 *
*								         *
**************************************************************************
*PALTRANS:
*	MOVI	PTRRAM,A0
*	MOVI	NUMPTR,A3 	;# OF PALETTES
*PLTLP:
*	MOVE	*A0,A4,W	;XFER TO DO
*	JREQ	PLTX		;NO, QUIT
*PLTGO:
*	CLR	A1
*	MOVE	A1,*A0+,W		;CLEAR OUT TRANFER COUNT
*	MOVE	*A0+,A1,L		;SOURCE ADDRESS
*	MOVE	*A0+,A2,W		;DESTINATION PALETTE
*
*	SLL	4,A2			;ADJUST FOR BIT ADDR
*	ADDI	COLRAM,A2		;ADD IN COLOR RAM BASE ADDRESS
*
*	SRL	1,A4			;ODD DATA COUNT
*	JRNC	PLTGO1			;NOPE
*	MOVE	*A1+,*A2+,W
*PLTGO1:
*	SRL	1,A4			;/2 DATA COUNT
*	JRNC	PLTGO2			;NOPE
*	MOVE	*A1+,*A2+,L
*PLTGO2:
*	SRL	1,A4			;/2 DATA COUNT
*	JRNC	PLTGO3			;NOPE
*	MOVE	*A1+,*A2+,L
*	MOVE	*A1+,*A2+,L
*PLTGO3:
*	JREQ	PLTGO4			;DONE
*	MOVE	*A1+,*A2+,L
*	MOVE	*A1+,*A2+,L
*	MOVE	*A1+,*A2+,L
*	MOVE	*A1+,*A2+,L
*	DSJS	A4,PLTGO3
*PLTGO4:
*	DSJ	A3,PLTLP	;DONE
*PLTX:	
*	RETS
*
*	
*SETUP PALETTE TRANSFER
*CALLING PARAMETERS:
*A0= PALSRC = 32 BIT SOURCE ADDRESS OF PALETTE COLOR DATA 	
*A1= PALDEST = BIT 8-15 DESTINATION PALETTE | BIT 0-7 START COLOR
*A2= PLDCNT = 16 BIT COLOR COUNT
*RETURNS: EQ IF UNABLE TO SETUP TRANSFER, NE IF TRANSFER O.K.
*
*PALSET:
*	MMTM	SP,A3,A4,A5
*	MOVI	PTRRAM,A4
*	MOVI	NUMPTR,A3	;# OF PALETTE TRANSFERS ALLOWED
*PALSTL:
*	MOVE	*A4,A5,W	;CELL TAKEN ?
*	JRNE	PALST1		;YES, KEEP LOOKING
*	MOVE	A0,*A4(PALSRC),L	;NO, LOAD IT UP
*	MOVE	A1,*A4(PALDEST),W
*	MOVE	A2,*A4(PLDCNT),W
*	JRUC	PALSTX
*PALST1:	
*	ADDI	PTRSIZ,A4
*	DSJS	A3,PALSTL
*PALSTX:	
*	MOVE	A3,A3		;RETURN EQ(NOT ABLE TO LOAD) OR NE (OK)
*	MMFM	SP,A3,A4,A5
*	RETS


	.DEF FLICKER_PAL

*	a8 = palette
*	a9 = palette table
*
FLICKER_PAL:
	MOVI	NUMPAL,A3
	MOVI	PALRAM,A11	
	clr	a10
	movI	PALRSIZ,A2
FLKPL0:
	MOVE	*A11,A14,L	;GET PALETTE ID
	CMP	A8,A14
	JReq	FLKPL3		;ALREADY IN COLOR RAM
	ADD	a2,A11
	inc	a10
	DSJS	A3,FLKPL0
*
*	not yet allocated
*
FLKPAL2:
	sloop	30,FLICKER_PAL
*
*	It IS allocated
*	a11 = ptr to palette block
* 	a10 = palette number
*
FLKPL3:
	clr	a14
	move	a14,*a13(PDATA)	; last index
	sll	8,a10
FLK_lp:
	move	*a11(PALCNT),a14
	jrz	FLKPAL2			; got deleted
*
*	Pick a random palette and set up transfer
*
	calla	RANDOM
	andi	0E0h,a0		; 8 choices indexed by long words
	move	*a13(PDATA),a1	; last bank
	xori	100h,a1
	move	a1,*a13(PDATA)
	or	a1,a0
	add	a9,a0		; add table start
	move	*a0,a0,L
	move	*a0+,a2		; a2 = count
	dec	a2
	addk	16,a0		; a0 = start of new data
	move	a10,a1
	inc	a1
	callr	PALSET

	movk	9,a0
	calla	RAND0
	inc 	a0
	movi	FLK_lp,a7
	jauc	PRCLSP

	.END
