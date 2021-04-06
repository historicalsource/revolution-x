 	.MLIB	"GXMACS.LIB"
 	.FILE	"GXUNIV.ASM"
	.TITLE	" <<< GENERATION X -- UNIVERSE ROUTINES >>>"
	.WIDTH	132
	.OPTION	B,D,L,T
	.MNOLIST

**************************************************************************
*								         *
* 	COPYRIGHT (C) 1992 MIDWAY MANUFACTURING COMPANY.		 *
* 		       ALL RIGHTS RESERVED.				 *
*								         *
**************************************************************************
OLD_WAY	.set	0

*	GET THE SYSTEM STUFF
	.INCLUDE	"GX.INC"

* SYMBOLS IN HERE
	.DEF	UCHECK_TBL, INIT_UCHECK_TBL, VALID_LINK, GET_TOPY_OFFSCRN

**** from GXD.ASM
	.REF	WORLD_GRNDOFF

MAX_COPS	EQU	100 ;10	;MAXIMUM CREATION OPERATIONS IN UPDATE_UNIV
MAX_DOPS	EQU	50  ;32	;MAXIMUM DELETION OPERATIONS IN UPDATE_UNIV

	.BSS	RAMREF0,32			;TOP OF RAM ONSCREEN REGION
	.BSS	RAMREF1,32			;BOTTOM OF RAM ONSCREEN REGION

	.BSS	CREATE_STACK,MAX_COPS*32	;STACKS FOR UPDATE_UNIV
	.BSS	DELETE_STACK,MAX_DOPS*32

	.BSS	ENEMYDATA0,32	  	; Start of DATA AREA FOR IDLING ENEMIES
	.BSS	ENEMYDATA,32		; ptr to 1st free entry in DATA AREA

	.BSS	WVT_PTR,32			;CURRENT WAVE VECTOR TABLE

	.BSS	UEP_Z,32		;FARTHEST WORLD Z OF ENEMY GENERATOR

	.BSS	WXBUFFER,32			;WORLD X BUFFER
	.BSS	WYBUFFER,32			;WORLD Y BUFFER

	.BSS	UCHECK_TBL,111*(16+32)		;TABLE FOR UNIVERSE CHECK

	.BSS	UNIVERR,8			;CREATION FAILURE FLAG
	.BSS	UNIVSKIP,8			;SKIP NEXT UPDATE_UNIV FLAG

	.if DEBUG	      
	.ref	VALID_PLAYER
	.endif		      

	.TEXT
	.EVEN

**************************************************************************
*								         *
* GET_ONSCRN_TABLE_PTR - SET UP POINTER ROUNDING ON-SCREEN		 *
* 									 *
* PASS:									 *
* A3 = UNIVERSE Z							 *
* RETURN:								 *
* A2 = POINTER TO RIGHT WORLD X	ENTRY					 *
*								         *
**************************************************************************

GET_ONSCRN_TABLE_PTR
	MOVE	A3,A2
	MOVE	@ZBASE,A14,L
	SUBI	0FFFH,A14
	SUB	A14,A2				;A2 = Z WORLD ROUNDED DOWN
	SRA	12,A2				;GET INDEX
	SUBK	2-1,A2				;OFFSET INDEX
	JRNN	GONTP_INDEX_OK			;BR=INDEX IS OKAY!
	CLR    	A2				;CLEAR NEGATIVE VALUE				
GONTP_INDEX_OK
	MOVE	A2,A14
	SLL	5,A14				;CALCULATE TABLE OFFSET
	SLL	4,A2
	ADD	A14,A2
	ADDI	UCHECK_TBL,A2			;ADD OFFSET TO TABLE
	RETS

**************************************************************************
*								         *
* GET_OFFSCRN_TABLE_PTR - SET UP POINTER ROUNDING OFF-SCREEN		 *
* 									 *
* PASS:									 *
* A3 = UNIVERSE Z							 *
* RETURN:								 *
* A2 = POINTER TO RIGHT WORLD X	ENTRY					 *
*								         *
**************************************************************************

GET_OFFSCRN_TABLE_PTR
	MOVE	A3,A2
	MOVE	@ZBASE,A14,L
	ADDI	0FFFH,A14
	SUB	A14,A2				;A2 = Z WORLD ROUNDED UP
	SRA	12,A2				;GET INDEX
	SUBK	2,A2				;OFFSET INDEX
	JRNN	GOFFTP_INDEX_OK			;BR=INDEX IS OKAY!
	CLR    	A2				;CLEAR NEGATIVE VALUE				
GOFFTP_INDEX_OK
	MOVE	A2,A14
	SLL	5,A14				;CALCULATE TABLE OFFSET
	SLL	4,A2
	ADD	A14,A2
	ADDI	UCHECK_TBL,A2			;ADD OFFSET TO TABLE
	RETS

**************************************************************************
*								         *
* GET_TOPY_OFFSCRN - GET TOP UNIVERSE Y OFF-SCREEN POSITION		 *
* 									 *
* PASS:									 *
* A3 = UNIVERSE Z							 *
* RETURN:								 *
* A2 = UNIVERSE Y							 *
*								         *
**************************************************************************

GET_TOPY_OFFSCRN
	CALLR	GET_OFFSCRN_TABLE_PTR
	ADDK	010H,A2
	MOVE	*A2,A2,W
	SLL	12,A2
	MOVE	@YBASE,A14,L
	SUB	A14,A2
	RETS

**************************************************************************
*								         *
* INIT_UCHECK_TBL  - BUILD TABLE AT YHALF, SCRNTL, SCRNBR		 *
*								         *
* TABLE ENTRY FORMAT FOR EACH WORLD Z FROM 02000H TO 070000H:		 *
* 									 *
* 	.WORD	RIGHT WORLD X >> 12 (NOTE: TO GET THE LEFT JUST NEGATE)  *
* 	.WORD	TOP WORLD Y >> 12					 *
* 	.WORD	BOTTOM WORLD Y >> 12					 *
* 									 *
* PASS:									 *
* NUTIN'								 *
* RETURN:								 *
* NUTIN'								 *
*								         *
**************************************************************************

INIT_UCHECK_TBL

;	.IF	DEBUG
;	move	@VCOUNT,A14,W
;	PUSH	A14
;	.ENDIF

	MMTM	SP,A0,A1,A2,A3,A4,A5,A6,A7,A8,A9

	MOVI	02000H,A0		;STARTING WORLD Z

	MOVE	@YHALF,A1,W
	MOVE	A1,A2
	MOVE	@(SCRNTL+16),A14,W
	SUB	A14,A1
	NEG	A1			;(TOP SCREEN Y - YHALF)
	MOVE	@(SCRNBR+16),A14,W
	SUB	A14,A2
	NEG	A2			;(BOTTOM SCREEN Y - YHALF)

	MOVI	UCHECK_TBL,A4		;BEGINNING OF TABLE

	MOVI	01000H,A5		;Z INCREMENT
	MOVI	070000H,A6		;LAST WORLD Z

;	MOVI	56*08000H,A8		;WORLD DISTANCE

	MOVI	SCRRGT-HALFX,A9		;(RIGHT SCREEN X - XHALF)
IUT_LUPE
	MOVE	A0,A3
	MPYU	A9,A3			;(RIGHT SCREEN X - XHALF) * WORLD Z
;	ADD	A8,A3			;OFFSET WORLD DISTANCE
	SRA	12,A3			;THROW AWAY BOTTOM 12 BITS
	MOVE	A3,*A4+,W		;TABLE WRITE RIGHT X >> 12

	MOVE	A0,A3
	MPYS	A1,A3			;(TOP SCREEN Y - YHALF) * WORLD Z

;	SUB	A8,A3			;OFFSET WORLD DISTANCE

	SRA	12,A3			;THROW AWAY BOTTOM 12 BITS
	MOVE	A0,A7
	MPYS	A2,A7			;(BOTTOM SCREEN Y - YHALF) * WORLD Z

;	ADD	A8,A3			;OFFSET WORLD DISTANCE

	SRA	12,A7			;THROW AWAY BOTTOM 12 BITS
	SLL	16,A7			;SHIFT INTO UPPER WORD
	MOVX	A3,A7			;MOVE TOP BOUNDARY INTO LOWER WORD
	MOVE	A7,*A4+,L		;TBL WRITE [BOTTOM Y >> 12,TOP Y >> 12]

	ADD	A5,A0			;NEXT WORLD Z
	CMP	A6,A0
	JRLE	IUT_LUPE		;BR = WE'RE NOT DONE YET

	MMFM	SP,A0,A1,A2,A3,A4,A5,A6,A7,A8,A9

;	.IF DEBUG
;	PULLP	A14
;	move	@VCOUNT,A0,W
;	SUB	A14,A0
;	.ENDIF

	RETS

**************************************************************************
*								         *
* SET_REFS								 *
*								         *
* THE FOLLOWING ROUTINE SETS THE REFERENCE POINTERS BASED ON THE FIRST	 *
* ON-SCREEN AND THE LAST ON-SCREEN					 *
*								         *
* UPDATES:							         *
* A9 = CHUNK LENGTH COUNT						 *
*								         *
**************************************************************************
SET_REFS:

	.if	DEBUG
	MOVE	@BGHEAD_ACTIVE,A14,L
	CMPI	RAMLINKS,A14
	LOCKON	LT
	CMPI	BGHEAD_ACTIVE,A14
	LOCKON	GE   
	.endif

	MOVKM	1,@UNIVERR,W		; FORCE UPDATE

	MOVE	@ZBASE,A6,L		;GET Z OFFSET FROM UNIVERSE TO WORLD
	MOVE	@ZFAR,A5,L
	ADD	A6,A5
	ADDI	ZMAX_KLUDGE,A6

	MOVE	@ZSCROLL,A14,L
	MOVE	@ZSACCEL,A7,L
	ADD	A7,A14
	sra	ZFRAC,a14		; change to lo res
	JRN	SR_ZMAX_BUFFER		;BUFFER ZMAX FOR NEGATIVE ZSCROLL
	ADD	A14,A5
	CLR	A14		
SR_ZMAX_BUFFER
	ADD	A14,A6

	MOVE	@BGHEAD_ACTIVE,A0,L
	MOVE	*A0(MAP_PREV),A3,L	;Pointer to tail

;FIND FIRST ONSCREEN
SR_FIRST_LUPE
	MOVE	*A0(MAP_NEXT),A0,L
	cmp	a0,a3	  
	jrz	SR_NULL_CASE			;BR=SPECIAL CASE	

	MOVE	*A0(MAP_Z),A14,L

	MOVE	*A0(MAP_OBJ),A4,L
	JRNN	SR_FIRST_FOUND			;BR=OBJECT EXISTS

	CMP	A6,A14
	JRLT	SR_FIRST_LUPE			;BR=BELOW ZMAX_REAL
SR_FIRST_FOUND
;	MOVK	1,A9				;INIT BLOCK COUNT
;	MOVE	A9,A6
	MOVE	A0,@RAMREF0,L			;STORE POINTER
	MOVE	A0,A2
	JRUC	SR_LAST_START

;FIND LAST ONSCREEN
SR_LAST_LUPE
	MOVE	A0,A2				;NEW LAST
;	MOVE	A6,A9				;NEW COUNT
SR_LAST_NEXT
;	INC	A6				;UPDATE COUNT
	MOVE	A0,A7
	MOVE	*A7(MAP_NEXT),A0,L
	cmp	a0,a3	       
	jrz	SR_LAST_END			;BR=SPECIAL CASE  

	MOVE	*A0(MAP_OBJ),A14,L
	JRNN	SR_LAST_LUPE			;BR=OBJECT EXISTS

	MOVE	*A0(MAP_Z),A14,L
SR_LAST_START
	CMP	A5,A14
	JRLE	SR_LAST_LUPE			;BR=BELOW ZFAR	
	JRUC	SR_LAST_NEXT
SR_LAST_END
	MOVE	A2,@RAMREF1,L			;STORE POINTER
;	SRL	CHUNKS,A9
;	INC	A9
SR_ABORT
	RETS

SR_NULL_CASE
	MOVE	A0,@RAMREF0,L			;BOTH POINTERS AT END OF LIST
	MOVE	A0,@RAMREF1,L
	RETS


**************************************************************************
*								         *
* UNIV_ENEMY_PROC - UNIVERSE ENEMY DISPATCHER GENERATOR PROCESS		 *
*								         *
* OBJECTS ADDRESSES ARE PLACED IN PDATA UPON THE CREATION.		 *
* THIS PROCESS PULLS THEM AND STARTS THEIR ANIMATION WHEN THEY ARE	 *
* ON DA SCREEN. IF THE OBJECT MUST BE DELETED, THE THE ADDRESS MUST	 *
* BE PULLED.								 *
*								         *
* NOTE: THIS DOES NOT CHECK IF THE PDATA AREA IS OVER WRITTEN.		 *
*								         *
* NOTE: THIS CAN ONLY HANDLE 64 OBJECTS WHEN USING PDATA.		 *
*									 *
*	ENEMYDATA = points to next free entry	  			 *
*	ENEMYDATA0 = start of list		  			 *
*									 *
**************************************************************************

	.if	OLD_WAY==0		; this is new way

UNIV_ENEMY_PROC
;	CALLA	CLRPDATA
	MOVE	A13,A10
	ADDI	PDATA,A10		;Start of list
UEP_RESTART
	move	@ENEMYDATA,a6,L		;other routines may adjust this
	MOVE	A10,A5
	MOVE	@UEP_Z,a4,L		;GET FARTHEST WORLD Z
	MOVE	@ZBASE,a3,L
	ADD	a3,a4			;FARTHEST UNIVERSE Z
	ADDI	ZMAX_REAL,a3		;CLOSEST UNIVERSE Z
UEP_LUPE
	MOVE	*A5+,A0,L		;GET CONTENTS
	JRZ	UEP_DONE		;BR=NO MORE OBJECTS
UEP_TEST
	MOVE	*A0(OZVAL),A2,L		; perform Z check
	CMP	a3,a2
	JRLT	UEP_LUPE		; loop if out of range
	CMP	a4,a2
	JRGT	UEP_LUPE

	move	*a0(OFLAGS),a14		; check offscreen
	btst	B_OFSCRN,a14		; loop if so
	jrnz	UEP_LUPE

	MOVE	*A0(OCTRL),A14,W	; if object not on FGLIST
	BTST	B_INUSE,A14		; clear it away
	jrz	UEP_CLEAR

	MOVE	*A0(OULINK),A1,L	;TURN OFF DANIM FLAG
	callr	VALID_LINK
	jrnc	UEP_CLEAR		; link is not valid

	MOVE	*A1(MAP_FLAGS),A14,W
	JRNN	UEP_CLEAR		;BR=THIS OBJECT NO LONGER GENERATES

	MOVE	*A1(MAP_IMG),A14,L
	ANDNI	M_IF_DANIM,A14
	MOVE	A14,*A1(MAP_IMG),L
	MOVE	*A0(OENEMYANIM),A1,L	;START ANIMATION

;CHECK ENEMY TYPE FLAG IF ENABLED
;ALSO CHECK IF THIS BE A PROCESS INSTEAD OF AN ANIMATION

	CALLA	STRTANIM
UEP_CLEAR
	clr	a14			; clear the last entry
	cmp	a6,a5			; compare next ptr with last
	jreq	UEP_islast		; BR=this was not the last one

	move	*-a6,*-a5,L		; move the last entry
					; adjust a5 to process it next
	move	a14,*a6,L
	MOVE	A6,@ENEMYDATA,L		;    and adjust ENEMYDATA
	jruc	UEP_LUPE

UEP_islast:	
	move	a14,*-a6,L
	MOVE	A6,@ENEMYDATA,L		;    and adjust ENEMYDATA

UEP_DONE
	SLOOP	13,UEP_RESTART


	.else


UNIV_ENEMY_PROC
;	CALLA	CLRPDATA
	MOVK	1,A8
	SLL	31,A8			;A8 = 080000000H
	MOVK	9,A9			;INIT LOOP COUNT
	MOVE	A13,A10
	ADDI	PDATA,A10		;OBJECT ADDRESS AREA	 
UEP_RESTART
	CLR	A6			;INIT FIRST EMPTY LOCATION
	MOVE	A10,A7
	MOVE	@UEP_Z,B1,L		;GET FARTHEST WORLD Z
	MOVE	@ZBASE,B0,L
	ADD	B0,B1			;FARTHEST UNIVERSE Z
	ADDI	ZMAX_REAL,B0		;CLOSEST UNIVERSE Z
UEP_LUPE
	MOVE	A7,A5			;SAVE LAST
	MOVE	*A7+,A0,L		;GET CONTENTS
	JRZ	UEP_DONE		;BR=NO MORE OBJECTS
	JRNN	UEP_TEST		;BR=FOUND OBJECT
UEP_CHECK_FREE
	MOVE	A6,A6
	JRNZ	UEP_LUPE		;BR=FIRST EMPTY ALREADY FOUND
	MOVE	A5,A6			;SET FIRST EMPTY LOCATION
	JRUC	UEP_LUPE
UEP_TEST
	MOVE	*A0(OZVAL),A4,L
	MOVE	A4,B14
	CMP	B0,B14
	JRLT	UEP_LUPE
	CMP	B1,B14
	JRGT	UEP_LUPE

	MOVE	*A0(ODAG),A4,L

	CMPXY	A3,A4			;IS IT LOWER THAN LOWER RT?
	JRYGE	UEP_LUPE		;LOWER
	JRXGE	UEP_LUPE		;TO THE RIGHT

	MOVE	*A0(OSIZE),A14,L
	ADDXY	A4,A14			;GET LOWER RT OF OBJECT

	CMPXY	A2,A14
	JRYLE	UEP_LUPE		;ABOVE...
	JRXLE	UEP_LUPE		;TO THE LEFT..

	MOVE	*A0(OULINK),A1,L	;TURN OFF DANIM FLAG

	MOVE	*A1(MAP_FLAGS),A14,W
	JRNN	UEP_CLEAR		;BR=THIS OBJECT NO LONGER GENERATES

	MOVE	*A1(MAP_IMG),A14,L
	ANDNI	M_IF_DANIM,A14
	MOVE	A14,*A1(MAP_IMG),L
	MOVE	*A0(OENEMYANIM),A1,L	;START ANIMATION

;CHECK ENEMY TYPE FLAG IF ENABLED
;ALSO CHECK IF THIS BE A PROCESS INSTEAD OF AN ANIMATION

	CALLA	STRTANIM
UEP_CLEAR
	MOVE	A8,*A5,L		;CLEAR OBJECT
	JRUC	UEP_CHECK_FREE
UEP_DONE
	MOVE	A6,A6
	JRNZ	UEP_FREE		;BR=FOUND EMPTY LOCATION
	MOVE	A5,A6			;SET EMPTY LOCATION
UEP_FREE
	MOVE	A6,@ENEMYDATA,L
UEP_NAP
	SLEEP	16
	DSJ	A9,UEP_RESTART		;BR=SCAN LIST AGAIN

	MOVK	10,A9			;INIT LOOP COUNT + 1 FOR CLEANUP
					;LET'S CLEANUP
	MOVE	A10,A7
UEP_OPT_LUPE
	MOVE	A7,A6
	MOVE	*A7+,A0,L		;FIND EMPTY LOCATION
	JRZ	UEP_FREE		;BR=END OF DATA AREA
	JRNN	UEP_OPT_LUPE		;BR=NOT EMPTY
	MOVE	A7,A1
UEP_OPT_LUPE2
	MOVE	A1,A4
	MOVE	*A1+,A2,L		;FIND OBJECT
	JRZ	UEP_OPT_RESET		;BR=END OF DATA AREA
	JRN	UEP_OPT_LUPE2		;BR=EMPTY
	MOVE	A2,*A6,L		;SWAP LOCATIONS
	MOVE	A0,*A4,L
	JRUC	UEP_OPT_LUPE
UEP_OPT_RESET				;DELETE EMPTY LOCATIONS
	MOVE	A6,A7
UEP_OPT_RESET_LUPE
	CLR	A14
	MOVE	A14,*A7+,L
	CMP	A4,A7
	JRNE	UEP_OPT_RESET_LUPE	;BR=NOT DONE YET
	JRUC	UEP_FREE

	.endif

*************************************************************
*							    *
*	ENTRY: link in a1				    *
*							    *
*	This returns Carry Clr if the link is not valid	    *
*							    *
*************************************************************
VALID_LINK:
	CMPI	RAMLINKS,A1
	jrlt	notvalid
	CMPI	BGHEAD_ACTIVE,A1
	jrge	notvalid
	setc
	rets
notvalid
	clrc
	rets

**************************************************************************
*								         *
* START_UNIVERSE - START A UNIVERSE.					 *
*								         *
* A0 = UNIVERSE							         *
*								         *
**************************************************************************

START_UNIVERSE
	MOVK	1,A14
	MOVE	A14,@NU_FLAG,L			;SET NEW UNIVERSE FLAG

	movi	UNIV_SP,a14
	move	a14,@UNIV_SP,L
	
	clr	a14
	move	a14,@UNIV_ID
	MOVE	A14,@WORLD_GRNDOFF,L

	MOVE	*A0+,A1,W			;NUMBER OF BLOCKS
	MOVE	*A0+,A14,W
	MOVE	A14,@YHALF,W			;YHALF

	MOVE	*A0+,A14,W	
	MOVE	A14,@GROUNDCOLOR,W		;GROUND COLOR
	MOVE	*A0+,A14,W	
	MOVE	A14,@SKYCOLOR,W			;SKY COLOR
	MOVE	*A0+,A14,L
	MOVE	A14,@ZFAR,L			;ZFAR

	MOVE	*A0+,A14,L
	MOVE	A14,@YWORLD,L			;YWORLD

	move	a1,a9
	move	a0,a8
	clr	a10			; no z off for initial univ
	clr	a11			; no Y off for initial univ
	JSRP	CREATE_UNIVERSE		; copy ROM to RAM LINKED LIST

	CALLR	SET_REFS			;SET REFERENCE POINTERS
	CALLA	INIT_HORIZON   

	CALLR	INIT_UCHECK_TBL

	CREATEP	PID_UNIV,UNIV_MANAGER
	move	a0,@UNIVPROC,L
	CLR	A14
	MOVE	A14,*A0(UZDIR),W
	MOVE	A14,*A0(ULINKCONT),L
	MOVE	A14,@UNIVERR,W

	CREATE	PID_UNIV,UNIV_ENEMY_PROC
	PUSH	A13
	MOVE	A0,A13
	CALLA	CLRPDATA
	PULLQ	A13
	ADDI	PDATA,A0
	MOVE	A0,@ENEMYDATA0,L
	MOVE	A0,@ENEMYDATA,L

	RETP


**************************************************************************
*								         *
* START_UNIVERSE0							 *
* 									 *
* PASS:									 *
* A0  = UNIVERSE							 *
* A10 = Z OFFSET							 *
* A11 = Y OFFSET							 *
*								         *
**************************************************************************

START_UNIVERSE0
	MOVK	1,A14
	MOVE	A14,@NU_FLAG,L			;SET NEW UNIVERSE FLAG

	movi	UNIV_SP,a14
	move	a14,@UNIV_SP,L
	
	clr	a14
	move	a14,@UNIV_ID
	MOVE	A14,@WORLD_GRNDOFF,L

	MOVE	*A0+,A1,W			;NUMBER OF BLOCKS

	ADDK	010H,A0

;	MOVE	*A0+,A14,W
;	MOVE	A14,@YHALF,W			;YHALF

	MOVE	*A0+,A14,W	
	MOVE	A14,@GROUNDCOLOR,W		;GROUND COLOR
	MOVE	*A0+,A14,W	
	MOVE	A14,@SKYCOLOR,W			;SKY COLOR
	MOVE	*A0+,A14,L
	MOVE	A14,@ZFAR,L			;ZFAR

	ADDK	020H,A0

;	MOVE	*A0+,A14,L
;	MOVE	A14,@YWORLD,L			;YWORLD

	move	a1,a9
	move	a0,a8
	JSRP	CREATE_UNIVERSE		; copy ROM to RAM LINKED LIST

	CALLR	SET_REFS			;SET REFERENCE POINTERS
	CALLA	INIT_HORIZON			

	CALLR	INIT_UCHECK_TBL

	CREATEP	PID_UNIV,UNIV_MANAGER
	move	a0,@UNIVPROC,L
	CLR	A14
	MOVE	A14,*A0(UZDIR),W
	MOVE	A14,*A0(ULINKCONT),L
	MOVE	A14,@UNIVERR,W

	CREATE	PID_UNIV,UNIV_ENEMY_PROC
	PUSH	A13
	MOVE	A0,A13
	CALLA	CLRPDATA
	PULLQ	A13
	ADDI	PDATA,A0
	MOVE	A0,@ENEMYDATA0,L
	MOVE	A0,@ENEMYDATA,L

	RETP



**************************************************************************
*								         *
* 									 *
* INIT_DUMMY_UNIVERSE - Initialize the Psuedo-3D system to some		 *
* 			default values without actually loading		 *
* 			a real universe.  This will allow the		 *
* 			display system to scale properly.		 *
* 									 *
* NOTE: This is called from OINIT.					 *
*								         *
**************************************************************************
INIT_DUMMY_UNIVERSE

	MOVIM	SCRHGHT/2,@YHALF,W		;YHALF = MidScreen

	MOVIM	70000H,@ZFAR,L

	MOVIM	2A0000H,@YWORLD,L

	CLRM	@GROUNDCOLOR,W
	CLRM	@SKYCOLOR,W

	RETS

**************************************************************************
*								         *
* UNIV_MANAGER								 *
*								         *
* NOTE: A9 CONTAINS CHUNK LENGTH COUNT					 *
*								         *
**************************************************************************

UZDIR			EQU	PDATA		;UHW Z-DIRECTION
ULINKCONT		EQU	PDATA+010H	;UHL CONTINUE WITH THIS LINK

UNIV_MANAGER
	
	.IF DEBUG
	move	@VCOUNT,A14,W
	PUSHP	A14

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

	MOVE	@ZBASE,B5,L
	MOVE	@ZFAR,B4,L	       	;SETUP COMMON REGS
	ADD	B5,B4
	ADDI	ZMAX_KLUDGE,B5

	MOVE	@ZSCROLL,B14,L
	GETST	A1
	MOVE	@ZSACCEL,B0,L
	MOVE	B14,B1
	ADD	B0,B1
	sra	ZFRAC,B1		; change to lores
	JRN	UM_ZMAX_BUFFER		;BUFFER ZMAX FOR NEGATIVE ZSCROLL
	ADD	B1,B4
	CLR	B1
UM_ZMAX_BUFFER
	ADD	B1,B5

	SRL	31,A1
	MOVE	*A13(UZDIR),A0,W 
	XOR	A1,A0
	JRZ	UM_SAME			;BR=SAME Z SCROLLING DIRECTION
	MOVE	A1,*A13(UZDIR),W
	CLR	A9			;CLEAR COUNT WHEN CHANGING DIRECTIONS
UM_SAME
	CALLR	UPDATE_REFS			;CHANGE REFERENCE POINTERS

	MOVE	@ZSCROLL,B14,L		      

	CALLR	UPDATE_UNIV			;CREATE AND DELETE BLOCKS

;	CALLR	DOZER_CHECK

	.IF DEBUG
	PULLP	A14
	move	@VCOUNT,A0,W
	SUB	A14,A0
	.ENDIF

;	SLEEP	1
	SLEEP	2
	JRUC	UNIV_MANAGER

**************************************************************************
*								         *
* UPDATE_REFS								 *
*								         *
* THE FOLLOWING ROUTINE UPDATES THE POSITIONS OF THE REFERENCE POINTERS	 *
* ACCORDING TO THE Z RANGE.						 *
*								         *
* B4  = ZFAR+ZBASE  (UNIVERSE LIMIT)					 *
* B5  = ZMAX_REAL+ZBASE (UNIVERSE LIMIT)				 *
* B14 = ZSCROLL								 *
* UPDATES:							         *
* A9  = CHUNK LENGTH COUNT						 *
*								         *
**************************************************************************

UPDATE_REFS
	MOVE	@RAMREF0,B7,L
	MOVE	B7,B1
	MOVE	@RAMREF1,B0,L

;	MOVE	@ZSCROLL0,A14,L
;	JRZ	UR_LAST_ABORT

	MOVE	@BGHEAD_ACTIVE,B2,L
	MOVE	*B2(MAP_PREV),B8,L		;DA TAIL

	MOVE	B7,B6
	MOVE	*B7(MAP_OBJ),B10,L
	JRNZ	UR_FIRST_START			;BR=NEITHER HEAD OR TAIL
	MOVE	B14,B14
	JRNN	UR_ZPOS0			;BR=POSITIVE ZSCROLL
	CMP	B2,B7				;NEGATIVE ZSCROLL
	JREQ	UR_FIRST_ABORT			;BR=DON'T GO OFF TOP
	JRUC	UR_BGT_PREV1
UR_ZPOS0
	CMP	B0,B7				;POSITVE ZSCROLL
	JREQ	UR_FIRST_ABORT			;BR=AT REF1
UR_FIRST_LUPE
	MOVE	B7,B6
	MOVE	B14,B14				;NEXT BLOCK
	JRN	UR_BGT_PREV1			;BR=NEGATIVE ZSCROLL
	CMP	B0,B7				;POSITIVE ZSCROLL
	JREQ	UR_FIRST_END			;BR=AT REF1
	MOVE	*B7(MAP_NEXT),B7,L
	JRUC	UR_BGT_CONT1
UR_BGT_PREV1
	MOVE	*B7(MAP_PREV),B7,L
UR_BGT_CONT1
	MOVE	*B7(MAP_OBJ),B2,L
	JRZ	UR_BGT_OUT			;BR=OFF THE LIST (NEG ZSCROLL)
UR_FIRST_START
	JRN	UR_FIRST_CHECK			;BR=NOT CREATED (POS ZSCROLL)
	MOVE	B14,B14
	JRNN	UR_FIRST_END			;BR=PREVENT BOUNDARY VIOLATION
UR_FIRST_CHECK

	MOVE	*B7(MAP_Z),B2,L
	
	MOVE	B14,B14
	JRN	UR_FIRST_IN			;BR=NEGATIVE ZSCROLL CHECK
						;POSITIVE ZSCROLL
	CMP	B5,B2				;LUPE IF OUT
	JRLT	UR_FIRST_LUPE			;BR=BELOW ZMAX_REAL
	JRUC	UR_FIRST_END
UR_FIRST_IN					;NEGATIVE ZSCROLL
	CMP	B5,B2				;LUPE IF IN
	JRGT	UR_FIRST_LUPE			;BR=ABOVE ZMAX_REAL

UR_BGT_OUT
	MOVE	B6,B7
UR_FIRST_END

	MOVE	B7,B1				;SAVE FOR FINDING RAMREF1
	MOVE	B7,@RAMREF0,L

UR_FIRST_ABORT

	MOVE	B0,B6
	MOVE	*B0(MAP_OBJ),B10,L
	JRNZ	UR_LAST_START
	MOVE	B14,B14
	JRNN	UR_ZPOS1			;BR=NON NEGATIVE ZSCROLL
	CMP	B1,B0				;POSITIVE ZSCROLL
	JREQ	UR_LAST_ABORT			;BR=AT REF0
	JRUC	UR_BGT_PREV6
UR_ZPOS1
	CMP	B0,B8				;NEGATIVE ZSCROLL
	JREQ	UR_LAST_ABORT			;BR=DON'T GO OFF BOTTOM

UR_LAST_LUPE
	MOVE	B0,B6
	MOVE	B14,B14				;NEXT BLOCK
	JRN	UR_BGT_PREV6			;BR=NEGATIVE ZSCROLL
	MOVE	*B0(MAP_NEXT),B0,L		;POSITIVE ZSCROLL
	JRUC	UR_BGT_CONT6
UR_BGT_PREV6
	CMP	B1,B0				;NEGATIVE ZSCROLL
	JREQ	UR_LAST_END			;BR=AT REF0
	MOVE	*B0(MAP_PREV),B0,L
UR_BGT_CONT6
	MOVE	*B0(MAP_OBJ),B2,L
	JRZ	UR_LAST_OUT			;BR=OFF THE LIST (POS ZSCROLL)
UR_LAST_START
	JRN	UR_LAST_CHECK			;BR=NOT CREATED (NEG ZSCROLL)
	MOVE	B14,B14
	JRN	UR_LAST_END			;BR=PREVENT BOUNDARY VIOLATION
UR_LAST_CHECK

	MOVE	*B0(MAP_Z),B2,L

	MOVE	B14,B14
	JRNN	UR_LAST_IN			;BR=POSITIVE ZSCROLL CHECK
	
	CMP	B4,B2				;NEGATIVE ZSCROLL
	JRGT	UR_LAST_LUPE			;BR=ABOVE ZFAR	
	JRUC	UR_LAST_END
UR_LAST_IN
	CMP	B4,B2				;POSITIVE ZSCROLL
	JRLT	UR_LAST_LUPE			;BR=BELOW ZFAR	
UR_LAST_OUT
	MOVE	B6,B0
UR_LAST_END
	MOVE	B0,@RAMREF1,L			;STORE ADDRESS
UR_LAST_ABORT
	MOVE	A9,B2
	JRNZ	UR_ABORT			;BR=DON'T RECALCULATE

	CLR	B7
	JRUC	UR_COUNT_START
UR_COUNT_LUPE
	MOVE	*B1(MAP_NEXT),B1,L
UR_COUNT_START
	INC	B7
	CMP	B1,B0
	JRNE	UR_COUNT_LUPE
;	SRL	CHUNKS,B7
;	INC	B7
	MOVE	B7,A9				;A9 HOLDS COUNT

	CLR	A14
	MOVE	A14,*A13(ULINKCONT),L		;FLAG ULINKCONT
UR_ABORT
	RETS


**************************************************************************
*								         *
* UPDATE_UNIV								 *
*								         *
* THE FOLLOWING ROUTINE CREATES AND DELETES UNIVERSE BLOCKS		 *
*								         *
* B4  = ZFAR+ZBASE  (UNIVERSE LIMIT)					 *
* B5  = ZMAX_REAL+ZBASE (UNIVERSE LIMIT)				 *
* B14 = ZSCROLL								 *
* UPDATES:							         *
* A9  = CHUNK LENGTH COUNT						 *
*								         *
**************************************************************************

UPDATE_UNIV
	MOVE	@RAMREF0,A5,L		;SET UP DEFAULTS FOR
	MOVE	@RAMREF1,A7,L		;POSITIVE LIST DIRECTION
	MOVE	@ZBASE,B3,L

	CLR	A4
	DEC	A4			;A4 = -1

	MOVE	B14,B14
	JRNN	UU_NOZ			;BR=POSITIVE LIST DIRECTION

	MOVE	A7,A14			;SWAP RAMREFS
	MOVE	A5,A7
	MOVE	A14,A5
	NEG	A4			;NEGATE LIST DIRECTION
UU_NOZ
	MOVE	*A13(ULINKCONT),A14,L
	JRNZ	UU_CONT			;BR=CONTINUE LIST SCAN
	MOVB	@UNIVSKIP,A10
	JRZ	UU_CLEAR_ERR		;BR=DO THIS UPDATE
	MOVI	XSCROLL,A10
	MMFM	A10,A0,A1,A2		;GET SCROLL VELOCITIES
	MOVE	A0,A0
	JRNZ	UU_CLEAR_ERR		;BR=DO THIS UPDATE
	MOVE	A1,A1
	JRNZ	UU_CLEAR_ERR		;BR=DO THIS UPDATE
	MOVE	A2,A2
	JRZ	UU_DONE			;BR=SKIP THIS UPDATE
UU_CLEAR_ERR
	MOVE	A14,@UNIVERR,W		;CLEAR UNIVERR AND UNIVSKIP
	JRUC	UU_GET_STUFF
UU_CONT
;WFD start 5/23/1994
	MOVE	*A14(MAP_IMG),A2,L
	JRN	UU_GET_STUFF		;BR=ON FREE LIST OR HEAD OR TAIL
	JRZ	UU_GET_STUFF		;BR=ON FREE LIST OR HEAD OR TAIL
;WFD end 5/23/1994
	MOVE	A14,A7			;CONTINUE LIST SCAN
UU_GET_STUFF

	MOVI	CREATE_STACK,A2		;GET TOPS OF STACKS
	MOVI	DELETE_STACK,A6

;	MOVI	MAP_X,B6
	MOVE	@XBASE,B9,L
	MOVE	@YBASE,B10,L

	PUSH	A12			;SAVE PROCESS STACK POINTER

	CLR	A3			;CLEAR LOOP COUNT
	CLR	B7			;CLEAR CREATION OPERATION COUNT
	CLR	A12			;CLEAR DELETION OPERATION COUNT

	MOVK	1,A0
	SLL	31,A0			;A0 = 080000000H
	MOVE	A0,A1
	DEC	A1			;A1 = 07FFFFFFFH


	MOVE	@WYBUFFER,A11,L		;WORLD Y BUFFER DISTANCE
	MOVE	@WXBUFFER,A10,L		;WORLD X BUFFER DISTANCE

	JRUC	UU_BGT_CONT1
	.align
UU_LUPE
	CMP	A5,A7
	JREQ	UU_SCAN_DONE		;BR=BOTH RAMREFS EQUAL
	CMP	A9,A3
	JRGT	UU_SCAN_CONT		;BR=DONE WITH THIS CHUNK

;	CMPI	MAX_COPS,B7
; ;	LOCKON	HI			;THIS SHOULD NEVER HAPPEN!
;	JREQ	UU_SCAN_CONT		;BR=MAX NUMBER OF OPERATIONS

	MOVE	*A7(MAP_Z),A8,L
	MOVE	A4,A4			;NEXT LIST ENTRY
	JRN	UU_BGT_PREV1		;BR=NEGATIVE LIST DIRECTION
	CMP	A1,A8
	JREQ	UU_SCAN_DONE		;BR=AT THE TAIL
	MOVE	*A7(MAP_NEXT),A7,L
	JRUC	UU_BGT_CONT1
UU_BGT_PREV1
	CMP	A0,A8
	JREQ	UU_SCAN_DONE		;BR=AT THE HEAD
	MOVE	*A7(MAP_PREV),A7,L
UU_BGT_CONT1

	INC	A3			;COUNT

	MOVE	A7,B14
	ADDI	MAP_X,B14
	MMFM	B14,B0,B1,B2		;B2 = X UNIVERSE
					;B1 = Y UNIVERSE
					;B0 = Z UNIVERSE

;	MOVE	*B14(MAP_Z),B0,L	;B0 = Z UNIVERSE

	MOVE	B0,B14
	SUB	B3,B14			;B14 = Z WORLD
	ADDI	0FFFH,B14		;ROUND UP
	SRA	12,B14			;GET INDEX
	SUBK	2,B14			;OFFSET INDEX
	JRNN	UU_CHECK_HI		;BR=INDEX IS OKAY ON THE LOW END
	CLR	B14			;CLEAR NEGATIVE VALUE				
UU_CHECK_HI
	CMPI	070H-2,B14
	JRLE	UU_CALC_OFFSET		;BR=INDEX IS OKAY ON THE HI END
	MOVI	070H-2,B14		;HIGHEST INDEX
UU_CALC_OFFSET
	MOVE	B14,B6
	SLL	5,B14			;CALCULATE TABLE OFFSET
	SLL	4,B6
	ADD	B14,B6
	ADDI	UCHECK_TBL,B6		;ADD OFFSET TO TABLE
	MOVE	*B6+,B8,W		;GET PACKED WORLD X BOUNDARY
	SLL	12,B8			;UNPACK WORLD X BOUNDARY

	MOVE	A10,B14
	ADD	B14,B8			;WORLD X BUFFER DISTANCE

	MOVE	*B6,B6,L		;GET PACKED WORLD Y [BOT, TOP]

	MOVE	B6,A14				
	SEXT	B6,W				
	SLL	12,B6			;UNPACK WORLD Y TOP BOUNDARY
	MOVE	A11,B14
	SUB	B14,B6			;WORLD Y BUFFER DISTANCE
	SRA	16,A14
	SLL	12,A14			;UNPACK	WORLD Y BOTTOM BOUNDARY
	ADD	A11,A14			;WORLD Y BUFFER DISTANCE

;UU_GET_WORLDS
;	MOVE	A7,B14
;	ADDI	MAP_X,B14
;	MMFM	B14,B1,B2		;B2 = X UNIVERSE
					;B1 = Y UNIVERSE
	ADD	B10,B1

	SUB	B9,B2
	ABS	B2			;X CHECK VALUE

	MOVE	*A7(MAP_OBJ),A8,L
	JRZ	UU_LUPE			;BR=END OF RAM LIST
	JRN	UU_CREATE_CHECK		;BR=OBJECT NOT CREATED

	CMP	B5,B0
	JRLT	UU_FOUND		;BR=BELOW ZMAX_REAL
	CMP	B4,B0
	JRGT	UU_FOUND		;BR=ABOVE ZFAR	

	CMP	B2,B8
	JRLT	UU_FOUND		;BR=OUT OF X

	CMP	B1,B6
	JRGT	UU_FOUND		;BR=ABOVE OF TOP Y

	MOVE	A14,B6
	CMP	B1,B6
	JRGE	UU_LUPE			;BR=ABOVE OF BOTTOM Y

UU_FOUND
;	CMPI	MAX_DOPS,A12
;;	LOCKON	HI			;THIS SHOULD NEVER HAPPEN!
;	JREQ	UU_LUPE			;BR=STACK IS FULL

	MOVE	A7,*A6+,L		;PUSH LIST ADDRESS
	INC	A12			;COUNT OPERATION

	CMPI	MAX_DOPS,A12
;	LOCKON	HI			;THIS SHOULD NEVER HAPPEN!
	JREQ	UU_SCAN_CONT		;BR=MAX NUMBER OF OPERATIONS

	JRUC	UU_LUPE
UU_CREATE_CHECK
	CMP	B5,B0
	JRLT	UU_LUPE			;BR=BELOW ZMAX_REAL
	CMP	B4,B0
	JRGT	UU_LUPE			;BR=ABOVE ZFAR	

	CMP	B2,B8
	JRLT	UU_LUPE			;BR=OUT OF X 	

	CMP	B1,B6
	JRGT	UU_LUPE			;BR=ABOVE OF TOP Y

	MOVE	A14,B6
	CMP	B1,B6
	JRLT	UU_LUPE			;BR=BELOW OF BOTTOM Y

	MOVE	A7,*A2+,L		;PUSH RAM LIST ADDRESS   
	INC	B7			;COUNT OPERATION

	CMPI	MAX_COPS,B7
;	LOCKON	HI			;THIS SHOULD NEVER HAPPEN!
	JREQ	UU_SCAN_CONT		;BR=MAX NUMBER OF OPERATIONS

	JRUC	UU_LUPE
UU_SCAN_DONE

	CLR	A9			;FLAG COUNT
	JRUC	UU_DEL_SETUP
UU_SCAN_CONT
	MOVE	A7,*A13(ULINKCONT),L	;STORE WHERE WE LEFT OFF
UU_DEL_SETUP
	PULLQ	A12			;RESTORE PROCESS STACK POINTER

	MOVE	@ENEMYDATA0,A3,L 	; start of free area
;
;	MOVE	A3,A10
;	ADDI	PSDATA-PDATA,A10

	.if	BILL

;	CLR	A10
;	CALLA	READ_SW1_SW2
;	BTST	P3TRIGGER,A0
;	JRNZ	UU_ONESHOT
;	MOVK	1,A10
;UU_ONESHOT
	.endif

	CLR	B7

	MOVE	A6,B6			;BOTTOM OF LINK STACK
	MOVE	A6,A10			;START LINK STACK AT DA BOTTOM

	MOVI	DELETE_STACK,A5
	move	@ENEMYDATA,a8,L		; don't need 80000000h anymore
	.align
UU_DEL_LUPE
	CMP	A5,A6
	JREQ	UU_DEL_DONE

	MOVE	-*A6,A7,L		;PULL LIST ADDRESS

	MOVE	*A7(MAP_OBJ),A1,L	;GET LIST ENTRY

	MOVE	A1,A0
	SRL	4,A0				
	SLL	4,A0			;SHIFT OUT DAMAGE COUNT

**************************************************************************
**************************************************************************
* IsAnObj
**************************************************************************
;	.if	DEBUG
;
;	MOVE	A0,A4
;	subi	OBJSTR,A4
;	LOCKON	N
;	cmpi	OBJSTRX,A4
;	LOCKON	GE
;	movi	OBSIZ,A14
;	modu	A14,A4
;	LOCKON	NZ
;
;	.endif
**************************************************************************
**************************************************************************

	MOVE	*A7(MAP_FLAGS),A11,W
	JRNN	UU_DEL_NOENEMY			;BR=NOT AN ENEMY GENERATOR

	MOVE	*A0(OFLAGS),A14,W
	BTST	B_ANIM,A14
	JRNZ	UU_DEL_NOENEMY			;BR=IT'S ANIMATING

	MOVE	*A7(MAP_IMG),A14,L		;TURN ON DANIM FLAG
	ORI	M_IF_DANIM,A14
	MOVE	A14,*A7(MAP_IMG),L


	.if	OLD_WAY

	MOVE	A3,A4
UU_DEL_ENEMY_LUPE
	MOVE	*A4+,A14,L
	LOCKON	Z
	CMP	A0,A14
	JRNE	UU_DEL_ENEMY_LUPE		;BR=NO MATCH

	MOVE	A8,-*A4,L			;CLEAR LOCATION

	.else

	MOVE	A3,A4
UU_DEL_ENEMY_LUPE
	MOVE	*A4+,A14,L
	.if	DEBUG
	LOCKON	Z
	.else
	JRZ	UU_DEL_NOENEMY
	.endif
	CMP	A0,A14
	JRNE	UU_DEL_ENEMY_LUPE	;BR=NO MATCH

	cmp	a8,a4
	jreq	UU_UPD_ED

	move	*-a8,*-a4,L 		; move last entry into current
	addk	20h,a8
UU_UPD_ED:
	clr	a14
	move	a14,*-a8,L		; clear last entry

	.endif


UU_DEL_NOENEMY
	XOR	A0,A1	  	;CLEAR OUT OBJECT ADDRESS AND GET DAMAGE COUNT
	ori	80000000h,a1	; set high bit (80000000h + damage count in a1)
	MOVE	A1,*A7(MAP_OBJ),L		;STORE ENTRY

	.if	BILL

;	JRUC	UU_DEL_ZAPOBJ			;BR=NOT A 1-SHOT OBJECT

;	BTST	B_BF_ONEUSE,A11
;	JRNZ	UU_DEL_ONESHOT			;BR=A 1-SHOT OBJECT

	BTST	B_BF_ONEUSE,A11
	JRZ	UU_DEL_ZAPOBJ			;BR=NOT A 1-SHOT OBJECT

;	BTST	2,A11
;	JRZ	UU_DEL_ZAPOBJ			;BR=NEVER ON SCREEN

	MOVE	A7,-*A10,L			;STICK IT ON DA LINK STACK

;	INC	B7

	.else

	BTST	B_BF_ONEUSE,A11
	JRZ	UU_DEL_ZAPOBJ			;BR=NOT A 1-SHOT OBJECT

	MOVE	A7,-*A10,L			;STICK IT ON DA LINK STACK

	.endif

;	JRZ	UU_DEL_ZAPOBJ			;BR=NOT A 1-SHOT OBJECT
;	MOVE	A0,A3
;	MOVE	A7,A0
;	CALLA	RAFL_NO_OBJ
;	MOVE	A3,A0

UU_DEL_ZAPOBJ

**************************************************************************
**************************************************************************
* ZAPOBJ
**************************************************************************

**************************************************************************
**************************************************************************
* KILL
**************************************************************************

	.if	DEBUG

	MOVE	*A0(OPLINK),A4,L
	JRZ	UU_NOKILL
	CLR	A14
	MOVE	A14,*A0(OPLINK),L
	MOVE	A0,A7
	MOVE	A4,A0
	CALLA	KILL
	MOVE	A7,A0
UU_NOKILL

	.else

	MOVE	*A0(OPLINK),A4,L
	JRZ	UU_KILLPX			;BR=NO PROCESS TO KILL

        CMP	A4,A13				;KILLING YOURSELF?
	JREQ	UU_KILLPX			;BR = YES, JUST ESCAPE

	MOVI	ACTIVE,A7,L
UU_KILLP:
	MOVE	A7,A14       			;SAVE PREVIOUS
	MOVE	*A7,A7,L
	JRZ	UU_KILLPX
	CMP	A7,A4
	JRNE	UU_KILLP			;NOT FOUND KEEP LOOKING

	;*** KILL IT ***
	MOVE	*A4,*A14,L			;LINK AROUND IN ACTIVE LIST
	MOVE	@FREE,A7,L			;LINK INTO FREE LIST AT START
	MOVE	A7,*A4,L
	MOVE	A4,@FREE,L

	move	@NXTPRC,A7,L
	cmp	A7,A4
	jrne	UU_SkNewNxt
	movi	ACTIVE,A7
	move	A7,@NXTPRC,L
UU_SkNewNxt:
	move	@PFREECNT,A14,W	;inc count of free processes
	inc	A14
	move	A14,@PFREECNT,W	;also clears Z bit
UU_KILLPX:

	.endif

**************************************************************************
**************************************************************************

	;CLEAR INUSE BIT TO MARK OBJ AS ON FREE LIST
	move	*A0(OCTRL),A14,W
	btst	B_INUSE,A14
	.if	DEBUG
	LOCKON	Z
	.else
	JRZ	UU_DEL_LUPE
	.endif
	andni	M_INUSE,A14
	move	A14,*A0(OCTRL),W
	move	*A0(OFLAGS),A14,W
	;PULL FROM ANIM IF NECESSARY
	btst	B_ANIM,A14
	jrz	UU_ZO_NoAnim

**************************************************************************
**************************************************************************
* PULLANIM
**************************************************************************
	;**** MARK OBJ AS BEING OFF ANIM LIST ****
;	move	*A0(OFLAGS),A14,W
;	btst	B_ANIM,A14
;	LOCKON	Z
	andni	M_ANIM,A14
	move	A14,*A0(OFLAGS),W

	MOVE	@ANIOBJS,A14,L
	cmp	A0,A14
	jrne	UU_ZO_PullLp
	;*** PULLING FIRST OBJ ***
	move	*A0(AnimNxt),A14,L
	MOVE	A14,@ANIOBJS,L
	jruc	UU_ZO_NoPull
UU_ZO_PullLp:
	MOVE 	A14,A4			;PTR TO PREVIOUS IN A4
	MOVE 	*A4(AnimNxt),A14,L	;PTR TO NEXT IN A14
	.if	DEBUG
	LOCKON	Z
	.else
	JRZ	UU_ZO_NoPull
	.endif
	CMP  	A14,A0			;IS THIS THE GUY?
	JRNE 	UU_ZO_PullLp
	MOVE 	*A0(AnimNxt),*A4(AnimNxt),L 	;LINK AROUND THIS OBJECT
UU_ZO_NoPull:

**************************************************************************
**************************************************************************
* CkAnim
**************************************************************************
	.IF	DEBUG
	move	@ANIOBJS,A4,L
	jrz	UU_ZO_AniCkLpX
UU_ZO_AniCkLp:
	move	*A4(OFLAGS),A14,W
	btst	B_ANIM,A14
	LOCKON	Z
	move	*A4(OCTRL),A14,W
	btst	B_INUSE,A14
	LOCKON	Z

;	callr	IsAnObj

	move	*A4(AnimNxt),A4,L
	jrnz	UU_ZO_AniCkLp
UU_ZO_AniCkLpX:
	.ENDIF
**************************************************************************
**************************************************************************

**************************************************************************
**************************************************************************

UU_ZO_NoAnim

**************************************************************************
**************************************************************************
* PULLOBJ
**************************************************************************
	;PULL OBJ OUT OF ACTIVE OBJ LIST
;No zero checks needed because there will always be ptrs from both ends
	move	*A0(OLINK),A14,L	;IS OBJ INSERTED?
	jrz	UU_ZO_SkPULLOBJ
	PUSHST	
	DINT
	move	*A0(OBLINK),A4,L	;A1 - Prev Obj
	move	*A0,A14,L		;A14 - Next Obj
	move	A14,*A4,L		;LINK FORWARD AROUND OBJ A0
	move	A4,*A14(OBLINK),L	;LINK BACKWARD AROUND OBJ A0
	clr	A14
	move	A14,*A0(OLINK),L	;OBJ NOT INSERTED
	POPST	

**************************************************************************
**************************************************************************
* PULLSUPP
**************************************************************************

**************************************************************************
**************************************************************************
* GETSUPP
**************************************************************************

	move	*A0(OID),A14,W
	srl	SR_SUPP,A14
	jrz	UU_ZO_NoSupp
	sll	5,A14			;convert to offset, multiple of 020H
	addi	SUPPLSTS-OSLINK,A14
UU_ZO_NoSupp
**************************************************************************
**************************************************************************
	jrz	UU_ZO_SkPullSupp

UU_ZO_PulSupLp
	move	A14,A4
	move	*A14(OSLINK),A14,L
	.if	DEBUG
	LOCKON	Z
	.else
 	JRZ	UU_ZO_SkPullSupp
	.endif
	cmp	A14,A0
	jrne	UU_ZO_PulSupLp

	move	*A0(OSLINK),*A4(OSLINK),L	;link around A0
	clr	A4
	move	A4,*A0(OSLINK),L
UU_ZO_SkPullSupp
**************************************************************************
**************************************************************************

UU_ZO_SkPULLOBJ
**************************************************************************
**************************************************************************

**************************************************************************
**************************************************************************
* DELPAL
**************************************************************************
	MOVE	*A0(OPAL),A4,W

**************************************************************************
**************************************************************************
* FREEPAL
**************************************************************************
	SLL	24,A4		;MASK OFF GARBAGE
	SRL	24,A4

	CMPI	NUMPAL,A4 	;ERROR...PALETTE NUMBER ERRONEOUS
	JRLO	UU_ZO_FREEPAL1
	LOCKUP
UU_ZO_FREEPAL1
	move	a4,a7
	sll	6,a7		; since PALRSIZ = 40h
************************************************************************
*   IF PALRSIZ IS NOT A POWER OF TWO, REPLACE THE ABOVE LINE WITH...	
*	MOVI	PALRSIZ,A7	; old way
*	MPYU	A4,A7
************************************************************************
	ADDI	PALRAM,A7
	MOVE	*A7(PALCNT),A4,W
	DEC	A4    			;DECREMENT ITS COUNT
	JRNN	UU_ZO_FREEPAL2

	LOCKUP

UU_ZO_FREEPAL2
	MOVE	A4,*A7(PALCNT),W
	JRP	UU_ZO_SkPalFree
	INCM	@FREEPALCNT,W
	;RECORD TIME WHEN FREED, CAN'T REALLOCATE ON SAME TIK
	MOVE	@WAVEDISPS,A14,W	;CLOCK IT BOYEEE!
	MOVE	A14,*A7(PALTIME),W
UU_ZO_SkPalFree

**************************************************************************
**************************************************************************

**************************************************************************
**************************************************************************

	;PUT OBJ ON FREE LIST
	move	@OFREECNT,A14,W	;inc obj free list count
	inc	A14		;
	move	A14,@OFREECNT,W	;

	move	@ENDOFREE,A14,L
	jrz	UU_ZO_HdLink1
	move	A0,*A14,L
	jruc	UU_ZO_DidLink1
UU_ZO_HdLink1
	move	A0,@OFREE,L
UU_ZO_DidLink1
	move	A0,@ENDOFREE,L

**************************************************************************
**************************************************************************

	JRUC	UU_DEL_LUPE

;OUT OF CACHE
;UU_DEL_ONESHOT

;	INC	B7

;	MOVE	A0,A3				;DELETE THE LINK OF A 1-SHOT
;	MOVE	A7,A0
;	CALLA	RAFL_NO_OBJ
;	MOVE	A3,A0
;	JRUC	UU_DEL_ZAPOBJ
;OUT OF CACHE

UU_DEL_DONE
	move	a8,@ENEMYDATA,L		; update this

;	JRUC	UU_MAKE_SETUP			;SKIP CACHE METHOD

	MOVE	B6,A6
;	ADDK	020H,A6
	CMP	A6,A10
	JREQ	UU_MAKE_SETUP			;BR=NO LINKS TO DELETE

	MOVE	@RAMREF0,A1,L
	MOVE	@RAMREF1,A3,L
	MOVE	@FREE_LINKS,A4,L

	.align
UU_DEL_LINKS_LUPE
	CMP	A6,A10
	JREQ	UU_DEL_LINKS_DONE		;BR=NO LINKS TO DELETE

	MOVE	-*A6,A0,L

**************************************************************************
**************************************************************************
* REMOVE_AND_FREE_LINK
**************************************************************************

**************************************************************************
**************************************************************************
* UNLINK_LINK
**************************************************************************
;	move	a0,b0
	move	*A0(MAP_NEXT),A14,L
	move	*A0(MAP_PREV),A5,L
	move	A5,*A14(MAP_PREV),L
	move	A14,*A5(MAP_NEXT),L
**************************************************************************
**************************************************************************

;	move	@RAMREF0,a14,L		; are we removing RAMREF0?
	cmp	a0,a1
	jrne	UU_noadj0

	MOVE	A14,A1
;	move	*a0(MAP_NEXT),a1,L	; if so, point to next one

;	move	a14,@RAMREF0,L
UU_noadj0:
;	move	@RAMREF1,a14,L		; are we removing RAMREF1?
	cmp	a0,a3
	jrne	UU_RETURN_TO_FREE

	MOVE	A14,A3
;	move	*a0(MAP_NEXT),a3,L	; if so, point to next one

;	move	a14,@RAMREF1,L		; FALL THROUGH TO RETURN_TO_FREE

**************************************************************************
**************************************************************************
* RETURN_TO_FREE
**************************************************************************
;
;	a0 = Universe link to return to list of free universe links
;	trashes a14
;	
UU_RETURN_TO_FREE:
;	PUSH	a1
;	move	@FREE_LINKS,a1,L
	MOVE	A4,A5

**************************************************************************
**************************************************************************
* INSLINK
**************************************************************************
	move	*a5(MAP_PREV),a14,L
	move	a0,*a5(MAP_PREV),L
	move	a14,*a0(MAP_PREV),L
	move	a0,*a14(MAP_NEXT),L
	move	a5,*a0(MAP_NEXT),L
**************************************************************************
**************************************************************************

	MOVE	A0,A4
;	move	a0,@FREE_LINKS,L
;	PULLQ	a1
**************************************************************************
**************************************************************************

**************************************************************************
**************************************************************************

	JRUC	UU_DEL_LINKS_LUPE

UU_DEL_LINKS_DONE
	MOVE	A1,@RAMREF0,L
	MOVE	A3,@RAMREF1,L
	MOVE	A4,@FREE_LINKS,L

UU_MAKE_SETUP
	MOVE	@ENEMYDATA,B5,L		; Next free entry
;	MOVI	MAP_X,B6
	MOVI	01010000H,B6
	MOVE	@WVT_PTR,B7,L			;CURRENT WAVE VECTOR TABLE
	MOVI	01000100H,B8
	MOVI	M_FLIPV|M_FLIPH,B9
	.align
UU_MAKE_LUPE
	CMPI	CREATE_STACK,A2
	JREQ	UU_CHECK

;	MOVE	@VCOUNT,A14,W
;	PUSHP	A14

	MOVE	-*A2,A7,L			;PULL LIST ADDRESS

	MOVE	A7,B14

;	ADD	B6,B14
	ADDI	MAP_X,B14

	MMFM	B14,B0,B1,B2				;B2 = X UNIVERSE
							;B1 = Y UNIVERSE
							;B0 = Z UNIVERSE

;	MOVE	*A7(MAP_OBJ),A1,L		;GET CURRENT LIST FLAGS
;	.if	DEBUG
;	LOCKON	NN
;	.else
;	JRNN	UU_MAKE_LUPE			;BR=ALREADY CREATED
;	.endif

	CALLA	GETOBJ
	JRZ	UU_ABORT			;BR=NO OBJECT BLOCK AVAILABLE
	MOVE	A0,A11

;	CALLA	CLRODATA

	MOVE	A0,*A7(MAP_OBJ),L		;PUT IN LIST

	MOVE	*A7(MAP_IMG),A1,L			;A1  - OIMG/ANIM SCRIPT
;WFD start 5/23/1994
;	JRN	UU_MAKE_LUPE			;BR=BOGUS! ON THE FREE LIST
;	JRZ	UU_MAKE_LUPE			;BR=BOGUS! ON THE FREE LIST
	JRN	UU_FREE_OBJ			;BR=BOGUS! ON THE FREE LIST
	JRZ	UU_FREE_OBJ			;BR=BOGUS! ON THE FREE LIST
	
;WFD end 5/23/1994

	MOVE	*A7(MAP_FLAGS),A3,W		;GET BLOCK FLAGS

	MOVE	A3,A5					;GET OID SUB-TYPE
	ANDI	M_BF_ID,a5  		; replace shifts for clarity
	SRL	B_BF_ID-BIT_ID,a5	; align for OID placement
	MOVE	A5,A6
	ORI	OID_UNIV,A6

	BTST	B_BF_PORTAL,a3
	jrz	UU_nxtchk			;BR=NOT A PORTAL
	PUSH	a5
	move	@WAVE_PORTAL_TBL,a14,L
	sll	3,a5			; long word align
	add	a5,a14
	PULLQ	a5			; don't change status bits!!
	move	*a14,a14,L		; is there a portal to zoom into?
	jrz	UU_nxtchk		; if no, treat normally
	movi	PORTAL_GUNVECT,a14
	jruc	UU_NOSUPP
UU_nxtchk:
	CLR	A14
	BTST	B_BF_NOVECT,A3				;TEST NOVECTOR FLAG
	JRNZ	UU_NOSUPP				;BR=NO VECTOR HERE

	SLL	4,A5					;GET OFFSET INTO TABLE
	JRNZ	UU_GETVECT				;BR=GET TABLE VECTOR
UU_DUMVECT
	MOVI	DUMRETS,A14				;SET DUM GUN VECTOR
UU_NOSUPP
	ANDNI	MASK_SUPP,A6		;CLEAR SUPP LIST
					; TO REDUCE TIME DURING COLLISION CHECK
	JRUC	UU_SETVECT
UU_GETVECT
	SETF	4,1,0				;FIELD 0 IS 4 BITS
	MOVE	*A7(MAP_ID+8),A14,0		;GET CURRENT DAMAGE LEVEL
	SETF	16,1,0				;WORD SIGN EXTEND
	INC	A14
	JRC	UU_DUMVECT			;BR=MAX. DAMAGE LEVEL FLAG SET

	MOVE	B7,A14
	ADD	A5,A14					;SET TABLE ADDRESS
	MOVE	*A14+,A5,L				;GET COLLISION VECTOR
;	JRZ	UU_DUMVECT				;BR=DUM VECTOR
	MOVE	A5,*A0(OCVECT),L			;SET OCVECT
	MOVE	*A14,A14,L				;GET GUN VECTOR
	JRZ	UU_DUMVECT				;BR=DUM VECTOR
UU_SETVECT
	MOVE	A14,*A0(OGUNVECT),L			;SET OGUNVECT
UU_NOVECT
	MOVE	A6,*A0(OID),W				;SET OID

	MOVE	A3,A5

	ANDI 	M_NOSCALE|M_DBLSCL|M_NOPIXSCAN,A5
	ORI	M_OFSCRN,A5			;ADD DEFAULT FLAGS
	MOVE	A5,*A0(OFLAGS),W

	MOVE	A1,A5
	SRL	4,A1
	SLL	4,A1
	move	a1,a4		; save for static enemy

	BTST	B_IF_DAM,A5
	JRZ	UU_NO_DAM		;BR=NO DAMAGE TABLE
*
*	HANDLE DAMAGE
*
	CLR	A14	
	MOVB	A14,*A0(OATEROCKET)	;RESET ROCKET COLLISION
	MOVE	A14,*A0(OGTIME),L	;RESET LAST GUN HIT TIME

	MOVE	*A1,A1,L		;GET FRAME OF DAMAGE SEQUENCE
	ANDI	M_IF_DANIM,A5
	OR	A1,A5
	SRL	4,A1
	SLL	4,A1
	BTST	B_BF_ENEMY,A3
	JRZ	UU_NOENEMY		;BR=NOT AN ENEMY GENERATOR
	BTST	B_IF_SEQ,a5
	JRZ	UU_STAT_ENEMY
	move	a1,a4			; for a seq, get seq into a4
	jruc	UU_SEQ_ENEMY
UU_NO_DAM
	BTST	B_BF_ENEMY,A3
	JRZ	UU_NOENEMY		;BR=NOT AN ENEMY GENERATOR
UU_SEQ_ENEMY:
*
* 	ENEMY, MUST BE SEQUENCE IF NO DAMAGE (LOAD20 makes it so)
*	       MAY BE SEQ IF DAMAGE
*
	move	*a4,a1,L		; a1 = img
	srl	4,a1
	sll	4,a1
	JRUC	UU_ENEMY
*
*	ENEMY, DAMAGE, BUT NOT A SEQUENCE
*
UU_STAT_ENEMY:
	addk	20h,a4
	btst	B_IF_LAST,a5		; check for end of table
	jrnz	UU_got_Eanim
UU_ENEMY_lp:
	move	*a4+,a14		; get past hit count
	move	*a4+,a14,L		; next image
	btst	B_IF_LAST,a14
	jrz	UU_ENEMY_lp
UU_got_Eanim:
	move	*a4,a4,L       		; image independent enemy anim
UU_ENEMY
	MOVE	A4,*A0(OENEMYANIM),L		;SAVE FOR LATER
	MOVE	B5,A14
	MOVE	A0,*A14+,L			;STUFF ADDRESS

;UU_ENEMY_LUPE					;FIND NEXT AVAILABLE LOCATION
;	MOVE	*A14+,A5,L
;	JRZ	UU_FREE				;BR=AT DA END
;	JRNN	UU_ENEMY_LUPE			;BR=OCCUPIED
;UU_FREE
;	SUBK	020H,A14

	MOVE	A14,B5				;SAVE FOR NEXT GUY
	JRUC	UU_NO_ANIM	       
UU_NOENEMY
	BTST	B_IF_SEQ,A5
	JRZ	UU_NO_ANIM			;BR=AN IMG	
UU_ANIM
	BTST	B_IF_DANIM,A5
	JRNZ	UU_GET_IMG			;BR=SPECIAL DANIM CASE

	move	a1,a14				; move script start to a14

	btst	B_BF_PORTAL,a3
	jrz	UV_SKP_FRMADJ
;	move	a1,a14				; move script start to a14
	move	*a7(MAP_SPAREL1),a1,W		; delta
	add	a14,a1				; frame start in a1
;	calla	STRTANIM_OFF
;	jruc	UU_NORM_ANIM
UV_SKP_FRMADJ:
;	CALLA	STRTANIM
	calla	STRTANIM_OFF
UU_NORM_ANIM
;	MOVE	@WAVEDISPS,A14,W		;SYNC ANIMS

;	ANDI	3,A14				;MASK OUT LOW 2 BITS
;	SUBK	4,A14				;GET TIME TIL NEXT 4TH COUNT

;;	ANDI	15,A14				;MASK OUT LOW 4 BITS
;;	SUBK	16,A14				;GET TIME TIL NEXT 16TH COUNT

;;	ANDI	31,A14				;MASK OUT LOW 5 BITS
;;	SUBK	32,A14				;GET TIME TIL NEXT 32TH COUNT

;	NEG	A14
;	MOVB	A14,*A0(AnimSlp)		
UU_GET_IMG
	MOVE	*A1,A1,L				;A1  - OIMG
	CMPK	1,A1
	JREQ	UU_FREE_OBJ			;BR = No image header
UU_NO_ANIM
	MOVE	*A1(ICMAP),A0,L
	CALLA	GETFPAL
	JRNZ	UU_PAL_AVAIL			;BR=PALETTE NOT D'ARE
;	LOCKON
	CLR	A0
	MOVE	A0,A5
	CALLA	INC_PALCNT
UU_PAL_AVAIL
;	MOVE	A0,A4					;A4  - OCONST|OPAL
	MOVE	B6,A4
	MOVX	A0,A4					;A4  - OCONST|OPAL
	MOVE	A11,A0

	MOVE	A7,*A0(OULINK),L	;STORE LIST POINTER ADDRESS	

	MOVE	A1,A7		       

	.if ICTRL != 0
	addk	ICTRL,a7
	.endif
		
	MOVE	*A7+,A10,W  				;A10 - ICTRL
	MOVE	*A7+,A5,L   				;A5  - ISIZE
	MOVE	*A7+,A8,L   				;A8  - ISAG
	MOVE	*A7,A11,L   				;A11 - IANIP
	
	MOVE	B9,A14	
	AND	A14,A3				;MASK OUT NON-DMA FLAGS
	ADD	A3,A10				;ADD TO ICTRL
	ADDI	DMAWNZ,A10			;ADD DEFAULT PIXOP AND GO 
	SLL	16,A10					;A10 - OCTRL|OFSET

	MOVE	A11,*A0(OUANIOFF),L			;A11 - OANIOFF

	MOVE	B8,A3					;A3  - OSCALE
	MOVE	A3,A7
	SLL	2,A7					;A7  - ODAG
	MOVE	A5,A6					;A6  - OUSIZE

	MOVE	A0,A14
	ADDI	OIMG+020H,A14
	MMTM	A14,A1,A3,A4,A5,A6,A7,A8,A10,A11	;A1  - OIMG
							;A3  - OSCALE
							;A4  - OCONST|OPAL
							;A5  - OSIZE
							;A6  - OUSIZE
							;A7  - ODAG
							;A8  - OSAG
							;A10 - OCTRL|OFSET
							;A11 - OANIOFF
	MOVE	A0,B14
	ADDI	OZVAL+020H,B14
	MMTM	B14,B0,B1,B2				;B0 - OZVAL
							;B1 - OYVAL
							;B2 - OXVAL
	CALLA	INSOBJ

;	PULLPQ	A14
;	MOVE	@VCOUNT,A1,W
;	SUB	A14,A1

	JRUC	UU_MAKE_LUPE
UU_ABORT
	MOVK	1,A14
	MOVB	A14,@UNIVERR
UU_CHECK
	MOVE	B5,@ENEMYDATA,L		; update this
	MOVE	A9,A9
	JRNZ	UU_DONE			;BR=NOT DONE WITH LIST	
	MOVE	@UNIVERR,A14,W
	JRNZ	UU_DONE			;BR=CREATION ERROR
	MOVI	XSCROLL,A14
	MMFM	A14,A0,A1,A2		;GET SCROLL VELOCITIES
	MOVE	A0,A0
	JRNZ	UU_DONE			;BR=MOVIN' IN Z
	MOVE	A1,A1
	JRNZ	UU_DONE			;BR=MOVIN' IN Y
	MOVE	A2,A2
	JRNZ	UU_DONE			;BR=MOVIN' IN X
	MOVK	1,A14			
	MOVB	A14,@UNIVSKIP		;SKIP NEXT UPDATE_UNIV
UU_DONE
	RETS

*
* Come here after object has been allocated, but an error occured
*
UU_FREE_OBJ
	MOVE	*A7(MAP_OBJ),a0,L		;PUT IN LIST\
	MOVE	A0,A1
	SRL	4,A0
	SLL	4,A0				;SHIFT OUT DAMAGE COUNT
	CALLA	FREEOBJ
	XOR	A0,A1	  	;CLEAR OUT OBJECT ADDRESS AND GET DAMAGE COUNT
	ori	80000000h,a1	; set high bit (80000000h + damage count in a1)
	MOVE	A1,*A7(MAP_OBJ),L		;STORE ENTRY

	LOCKUP				;Log it
	
	JRUC	UU_MAKE_LUPE

**************************************************************************
*								         *
* UNIVERSE DAMAGE HANDLER - CHANGE THE DAMAGE FRAME			 *
*								         *
* PASS:									 *
* A2 = PLAYER								 *
* A5 = SCORE UPON LAST DAMAGE FRAME					 *
*      SET LOW BIT TO SCORE ON DAMAGE LEVEL CHANGE OTHER THAN LAST FRAME *
* A7 = FLAGS								 *
* 	M_ANIMSYNC   (OFFSET NEW ANIMATION TO SYNC WITH OLD,		 *
*		      ACTUALLY IT IS SET ONE FRAME AHEAD)		 *
* 	M_FLASHOBJ   (FLASH OBJECT CONSTANT COLOR #1)		  	 *
* 	M_LASTFRM    (GO STRAIGHT TO LAST FRAME)		  	 *
* 	M_NOMORE     (NO MORE DAMAGE IF LAST FRAME)			 *
* 	M_NEXTFRM    (GO TO NEXT FRAME REGARDLESS OF HIT COUNT)		 *
* 	M_STAY	     (STAY AT CURRENT DAMAGE FRAME)			 *
*	M_NOSTOPANIM (DON'T STOP THE ANIM WHEN CHANGING TO STATIC FRAME) *
* A8 = OBJECT								 *
* A9 = SCREEN OFFSET OF SCORE FROM CENTER OF OBJECT IN [Y,X] FORMAT	 *
*								         *
* RETURN:								 *
* C FLAG SET IF LAST DAMAGE ENTRY WAS SET				 *
* A10 = DAMAGE LEVEL COUNT (IF 0, THEN NO CHANGE IN DAMAGE LEVEL)	 *
*								         *
**************************************************************************

;
;  NOTES TO BILL:
;	1) What is the purpose of the NOMORE flag?
;	2) Default should be that when last frame is reached, the
;		uni link is adjusted to show a static img(or seq)
;		which is NOT damageable.
;	3) Unravel spaghetti by having different front end routines
;	   (i.e. UNIV_DMG_LAST_FRM,  UNIV_DMG_NEXT_FRM, UNIV_DMG_STAY, etc.)
;

UNIV_DAMAGE_HANDLER
	MMTM	SP,A0,A1,A3,A4,A6,A7,A11

;	MOVE	*A2(PPLASMASHOTS),A14,W
;	JRZ	UDH_GOO				;BR=NO BIG GUN
;	ORI	M_NEXTFRM,A7
;UDH_GOO
	CLR	A3				;DEFAULT TO LAST DAMAGE ENTRY
	MOVE	*A8(OULINK),A0,L
	JRZ	UDH_DONE			;BR=THIS IS BAD! NO LINK
	MOVE	*A0(MAP_IMG),A1,L
;WFD start 5/23/1994
	JRN	UDH_DONE			;BR=BOGUS! ON THE FREE LIST
	JRZ	UDH_DONE			;BR=BOGUS! ON THE FREE LIST
;WFD end 5/23/1994

	BTST	B_IF_DAM,A1
	.if	DEBUG
	LOCKON	Z				;WE'RE FUCKED IF NO DAMAGE TABLE
	.else
	JRZ	UDH_DONE
	.endif

	CLR	A10				;DEFAULT TO NO DAMAGE CHANGE

	MOVE	A1,A6
	SRL	4,A1				;CLEAR LOW FLAGS
	SLL	4,A1
	MOVE	*A1+,A4,L
	BTST	B_IF_LAST,A4
	JRNZ	UDH_DONE			;BR=LAST DAMAGE FRAME

	SETF	4,0,0				;FIELD 0 IS 4 BITS
	MOVE	*A0(MAP_ID+8),A11,0		;GET CURRENT DAMAGE LEVEL
	SETF	16,1,0				;WORD SIGN EXTEND

	BTST	B_RANDFRM,a7
	jrnz	UDH_RAND_FRM			; pick a random frame

	BTST	B_LASTFRM,A7
	JRZ	UDH_CHECK_NEXT			;BR=DON'T GO TO LAST FRAME
	SUBK	020H,A1				;HEY NOW! BACK UP THERE.
UDH_LAST_LUPE
	INC	A11				;NEXT DAMAGE LEVEL
	ADDI	030H,A1				;SKIP FRAME AND COUNT			
	MOVE	*A1,A4,L
	BTST	B_IF_LAST,A4
	JRZ	UDH_LAST_LUPE			;BR=NOT LAST DAMAGE FRAME

	JRUC	UDH_SAVE_FRAME
;	ANDI	M_IF_DAM|M_IF_DANIM,A6		;SAVE LAST DAMAGE STATE		
;	OR	A1,A6
;	MOVE	A6,*A0(MAP_IMG),L
;
;	JRUC	UDH_LAST_FRAME
UDH_CHECK_NEXT
	BTST	B_NEXTFRM,A7
	JRZ	UDH_COUNT			;BR=DON'T GO TO NEXT FRAME NOW!
	ADDK	010H,A1
	SETF	4,0,0				;FIELD 0 IS 4 BITS
	JRUC	UDH_NEXT_FRAME
UDH_COUNT
	MOVB	*A1,A14				;GET DAMAGE COUNT
	JRN	UDH_DONE			;BR=NO DAMAGE ALLOWED

	ADDK	010H,A1
	SETF	4,0,0				;FIELD 0 IS 4 BITS

	MOVE	*A0(MAP_OBJ),A4,0		;GET CURRENT COUNT
	INC	A4				;YES WE HIT IT!

	MOVE	A14,B14
	MOVB	*A2(PPLASMASHOTS),A14
	JRZ	UDH_NO9				;BR=NO BIG GUN
	ADDK	9,A4
UDH_NO9
	MOVE	B14,A14
	CMP	A14,A4
	JRLT	UDH_NOT_READY			;BR=NOT ENOUGH DAMAGE YET
UDH_NEXT_FRAME
	INC	A11				;NEXT DAMAGE LEVEL
	CLR	A4				;RESET COUNT FOR NEW FRAME
UDH_NOT_READY
	GETST	A14	
	BTST	B_STAY,A7
	JRNZ	UDH_WORD_FIELD			;BR=STAY AT CURRENT COUNT
	MOVE	A4,*A0(MAP_OBJ),0		;SAVE CURRENT COUNT
UDH_WORD_FIELD
	PUTST	A14
	SETF	16,1,0				;WORD SIGN EXTEND
	JRNZ	UDH_DONE			;BR=NO DAMAGE

	MOVE	A11,A10				;RETURN DAMAGE LEVEL

	MOVE	*A1,A4,L
UDH_SAVE_FRAME
	ANDI	M_IF_DAM|M_IF_DANIM|M_IF_SEQ,A6	;SAVE DAMAGE STATE
	OR	A1,A6

	BTST	B_STAY,A7
	JRNZ	UDH_CHECK_NOMORE		;BR=STAY AT CURRENT FRAME
	MOVE	A6,*A0(MAP_IMG),L

	btst	B_IF_LAST,a4	  		;is this the last in table?
	jrz	UDH_CHECK_NOMORE
*
*	insert damage count here
*
	MOVE	A2,A2
	JRZ	UDH_NO_PLAYER_DAMAGE
	.if 	DEBUG
	calla	VALID_PLAYER
	.endif
	INCM	*a2(PDAMAGE),W
UDH_NO_PLAYER_DAMAGE
*
UDH_CHECK_NOMORE
	BTST	B_NOMORE,A7
	JRZ	UDH_SAVE_LEVEL			;BR=STILL HAVE DAMAGE
	BTST	B_IF_LAST,A4
	JRZ	UDH_SAVE_LEVEL			;BR=THERE'S STILL MORE TO DAMAGE
	CLR	A14				;CLEAR VECTORS
	MOVE	A14,*A8(OCVECT),L
	MOVI	DUMRETS,A14
	MOVE	A14,*A8(OGUNVECT),L
	MOVK	0FH,A10				;FLAG NO MORE DAMAGE
UDH_SAVE_LEVEL
	BTST	B_STAY,A7
	JRNZ	UDH_CHECK_SCORE			;BR=STAY AT CURRENT LEVEL
	SETF	4,0,0				;FIELD 0 IS 4 BITS
	MOVE	A10,*A0(MAP_ID+8),0		;SAVE DAMAGE LEVEL
	SETF	16,1,0				;WORD SIGN EXTEND
UDH_CHECK_SCORE
	MOVE	A4,A3
	SRL	4,A4				;CLEAR LOW FLAGS
	SLL	4,A4

	MOVE	A5,A1
	JRZ	UDH_NOSCORE			;BR=ZERO SCORE
	BTST	0,A5
	JRNZ	UDH_SCORE			;BR=SCORE ON THIS DAMAGE
	BTST	B_IF_LAST,A3
	JRZ	UDH_NOSCORE			;BR=NO SCORE HOSER

;	ORI	M_DEAD >> 3,A14
;	MOVB	A14,*A8(OFLAGS+B_DEAD-7)
	
UDH_SCORE
	SRL	1,A1				;SHIFT OUT SCORE FLAG
	SLL	1,A1
	CALLA	PRINT_SCORE
UDH_NOSCORE
	MOVE	A4,A1
	BTST	B_IF_SEQ,A3
	JRZ	UDH_IMG				;BR=AN IMAGE

	MOVE	A1,*A8(OENEMYANIM),L		;JUST IN CASE IT'S AN ENEMY

	MOVE	*A1,A4,L			;GET IMAGE
	BTST	B_IF_DANIM,A6
	JRNZ	UDH_DANIM			;BR=IN DANIM STATE
UDH_NODANIM
	BTST	B_ANIMSYNC,A7
	JRZ	UDH_NOSYNC			;BR=DON'T BOTHER SYNCING ANIM
	MOVE	*A8(AnimScr),A3,L
	MOVE	*A8(AnimFrm),A14,L
	SUB	A3,A14				;GET DIFF
	.if	DEBUG
	LOCKON	N
	.else
	JRNN	UDH_NOTNEG
	CLR	A14
UDH_NOTNEG
	.endif
	move	A1,*A8(AnimScr),L
	ADD	A14,A1				;OFFSET NEW ANIM
	JRUC	UDH_ACONT
UDH_NOSYNC
	move	A1,*A8(AnimScr),L		;RESTART ANIMATION
	clr	A14
	movb	A14,*A8(AnimSlp)
UDH_ACONT
	move	A1,*A8(AnimFrm),L
	MOVE	A8,A0
	CALLA	CKINSANI

	MOVE	*A1,A1,L
	JRUC	UDH_DOIT
UDH_DANIM
	MOVE	A4,A1
UDH_IMG
	MOVE	*A8(OFLAGS),A14,W
	BTST	B_ANIM,A14
	JRZ	UDH_DOIT			;BR=NOT CURRENTLY ANIMATING
	BTST	B_NOSTOPANIM,A7
	JRNZ	UDH_DOIT			;BR=DON'T STOP ANIMATING
	CALLA	PULL_ANIM
UDH_DOIT
	MOVE	A1,A1
	JRNZ	UDH_GO				;BR=NO LOOP ON NEXT FRAME
	MOVE	*A8(AnimScr),A1,L
	MOVE	*A1,A1,L
UDH_GO
	MOVE	*A1(ICMAP),A0,L			;NEW PALETTE
	CALLA	CHANGE_PAL
	MOVE	*A8(OCTRL),A4,W

	BTST	B_FLASHOBJ,A7
	JRZ	UDH_NOFLASH			;BR=DON'T FLASH

	MOVE	*A8(OPLINK),A14,L	
	JRNZ	UDH_NOFLASH			;BR=PROCESS ALREADY RUNNING!

	ANDI	M_LRCLIP|M_FLIPV|M_FLIPH,A4
	ADDI	DMACNZ,A4			;SET CONSTANT ON NON-ZERO DATA
	MOVE	A1,A6

	CREATE	PID_IND,TURN_OFF_CONSTANT_PROC	;RESTORE IT IN A LITTLE WHILE
;	MOVE	A0,*A8(OPLINK),L		;SAVE PROCESS ADDRESS
	MOVE	A6,A1
UDH_NOFLASH

	CALLA	ANI				;NEW IMAGE
	CALLA	SET_SCALE_WARREN			;SCALE THE MOTHER
	CALLA	SET_ODAG			;COMPUTE ODAG AGAIN

	;SET C ON SHIFT
UDH_DONE
	SRL	4,A3				;SET THE C FLAG
	MMFM	SP,A0,A1,A3,A4,A6,A7,A11
	RETS		
;UDH_DEAD
;	CLRC
;	RETS


; 	Handle random damage
;	Count = number of frames to choose from
;	after frame chosen, table points past last choice
;
UDH_RAND_FRM:
	PUSH	a0
	move	*a1+,a0		; count (# frames to choose from)
	add	a0,a11		; update damage level
	move	a0,a3		; to get to end of choices later
	calla	RAND0		; get random index
UDH_rand_lp1:
	dec 	a3
	dec	a0
	jrn	UDH_rand_there
	addi	30h,a1
	jruc	UDH_rand_lp1
UDH_rand_there:
*
*	A1 points to desired entry in damage table
*
	move	*a1,a4,L	; get pointer to img/seq (flags in lower 4 bits)

UDH_rand_lp2:
	dec 	a3
	jrn	UDH_rand_end
	addi	30h,a1
	jruc	UDH_rand_lp2
*
*	A1 points to last entry of choices
*
UDH_rand_end:
	move	*a1,a14,L
	andi	M_IF_LAST,a14
	or	a14,a4		; mark as last if it is.
	clr	a3		; restore assumption
	PULLQ	a0		;
	jruc	UDH_SAVE_FRAME
	


**************************************************************************
*								         *
* UNIV_FLASH - FLASH UNIVERSE OBJECT					 *
* 									 *
* PASS:									 *
* A8 = OBJECT								 *
*								         *
**************************************************************************

UNIV_FLASH
;	MOVE	*A8(OPLINK),A14,L	
;	JRNZ	UF_NOFLASH			;BR=PROCESS ALREADY RUNNING!

	SETF	4,0,0				;FIELD 0 IS 4 BITS
	MOVK	M_CONNON,A14			;DMACNZ	
	MOVE	A14,*A8(OCTRL),0
	SETF	16,1,0				;WORD SIGN EXTEND

	MMTM	SP,A0,A1,A7
	CREATE	PID_IND,TURN_OFF_CONSTANT_PROC	;RESTORE IT IN A LITTLE WHILE
;	MOVE	A0,*A8(OPLINK),L		;SAVE PROCESS ADDRESS
	MMFM	SP,A0,A1,A7
UF_NOFLASH
	RETS

**************************************************************************
*								         *
* TURN_OFF_CONTSTANT_PROC - RESTORE OBJECT OCTRL TO DMAWNZ		 *
* 									 *
* A8 = OBJECT								 *
*								         *
**************************************************************************

TURN_OFF_CONSTANT_PROC
	SLEEP	3

	SETF	4,0,0				;FIELD 0 IS 4 BITS
	MOVK	M_WRNONZ,A14			;DMAWNZ
	MOVE	A14,*A8(OCTRL),0
	SETF	16,1,0				;WORD SIGN EXTEND

;	CLR	A14
;	MOVE	A14,*A8(OPLINK),L		;CLEAR PROCESS ADDRESS

	DIE

**************************************************************************
*								         *
* UNIV_MAKE_STATIC - MAKE A UNIVERSE OBJECT STATIC			 *
* 									 *
* A8 = OBJECT								 *
*								         *
**************************************************************************

UNIV_MAKE_STATIC
	MOVE	*A8(OULINK),A14,L
	MOVE	*A8(OIMG),*A14(MAP_IMG),L
	JAUC	PULL_ANIM


**************************************************************************
*								         *
* UNIV_DISAB_ENEMY_GEN - MAKE A UNIVERSE OBJECT STATIC & NOT AN		 *
*				ENEMY GENERATOR				 *
* 		   	 Call from an enemy generating animation	 *
* A8 = OBJECT								 *
*								         *
**************************************************************************
UNIV_DISAB_ENEMY_GEN:
	MOVE	*A8(OULINK),A14,L
	move	*a14(MAP_FLAGS),a0
	btst	B_BF_ENEMY,a0		; has it been cleared already?
	jrnz	is_an_enemy
	rets
is_an_enemy:
	andni	M_BF_ENEMY,a0
	move	a0,*a14(MAP_FLAGS)
*
*	If this is damageable, retain the damage table
*
	move	*a14(MAP_IMG),a0,L
	btst	B_IF_DAM,a0
	jrnz	yes_dam
	MOVE	*A8(OIMG),*A14(MAP_IMG),L
yes_dam:
	PUSH	A0
	MOVE	A8,A0
	CALLA	CKPULLANIM
	PULLQ	A0
	RETS

	.END
