 	.MLIB	"GXMACS.LIB"
 	.FILE	"GXUNIV1.ASM"
	.TITLE	" <<< GENERATION X -- GENERAL UNIVERSE ROUTINES PART 1 >>>"
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
	.INCLUDE	"GXCONTRL.H"
	.INCLUDE	"IMGTBL.GLO"
	.include	"univtbl.glo"
;	.INCLUDE	"GXUNIV1.TBL"

* SYMBOLS IN HERE
	.def	BOX_CHECK_OBJ2,FLOAT_ZFAR, F_UFRAG_STUFF_X2
	.DEF	FRAG_SHARD_ANIM
	.DEF	FRAG_ONE_CLOUD, FRAG_ONE_CLOUD_X2, GOLD_DUST_PAL
	.DEF	FRAG_DUST_CLOUD_ANIM
	.DEF	FRAG_DUST_CLOUD_ANIM,MAKE_EXPLO_OFF
	.DEF	FRAG_U1_X2

* SYMBOLS FROM GXAFUNC.ASM
	.REF	A_DELETE_ZBOT
	
MAX_RAND_TBL	EQU	11

	.BSS	RAND_RAM_TBL,(MAX_RAND_TBL+1)*010H
;	.bss	filler,16			   ; to keep long word aligned


**************************************************************************
*								         *
*    FLOAT_ZFAR								 *
*								         *
*	This process adjusts ZFAR to keep it just beyond a UNIVERSE Z.   *
*	This is useful if you have one universe with a room behind the	 *
*	room you're in.                                                  *
*								         *
*	a8 = UNIV Z to track  (relative to local universe)	         *
*								         *
**************************************************************************
FLOAT_ZFAR:
	addi	800h,a8			; buffer zone
	move	@ZREL_OFF,a14,L
	sra	ZFRAC,a14		; convert to lores
	add	a14,a8			; absolute universe
	move	@ZFAR,a9,L		; keep to restore
FZF_lp:	
	move	@ZBASE,a0,L
	sub	a8,a0
	neg	a0			; world Z
	move	a0,@ZFAR,L

	move	@SCROLLKILL,a1		; terminated when SCROLLKILL non-zero
	jrnz	im_dead

	sloop	3,FZF_lp

im_dead:
	move	a9,@ZFAR,L
	dec	a1
	move	a1,@SCROLLKILL
	DIE

**************************************************************************
*								         *
* GROUND_COLLVECT							 *
*								         *
**************************************************************************

GROUND_COLLVECT
	WWL	OID_GRND,0FFFFH,DEL_PROC_AND_OBJ
	WL	0,DUMCRETS

**************************************************************************
*								         *
* DEL_PROC_AND_OBJ - DELETE PROCESS AND OBJECT				 *
* 									 *
* PASS:									 *
* A8 = OBJECT								 *
* RETURN:								 *
* NUTIN'								 *
*								         *
**************************************************************************

DEL_PROC_AND_OBJ
	PUSH	A0
	MOVE	*A8(OPLINK),A0,L
	JRZ	DPAO_DEL				;BR=NO PROCESS
	CLR	A14
	MOVE	A14,*A8(OPLINK),L
	CALLA	KILL
DPAO_DEL
	CALLA	DELETE_OBJ
	PULLQ	A0
	RETS

**************************************************************************
*								         *
* UNIV_ROCKET_COLL - ROCKET COLLISION WITH UNIVERSE OBJECT		 *
*								         *
* PASS:									 *
* A0 = ROCKET OBJECT							 *
* A8 = UNIVERSE OBJECT							 *
*								         *
**************************************************************************

UNIV_ROCKET_COLL
	CALLA	GETHEADPART			;OF ROCKET
	MOVE	A0,*A8(OATEROCKET),L
	RETS

**************************************************************************
*								         *
* UNIV_COLL_CHECK - CHECK IF PLAYER'S EXPLOSION HIT AN UNIVERSE OBJECT	 *
* 									 *
* PASS:									 *
* A0 = EXPLOSION OBJECT							 *
* A8 = UNIVERSE OBJECT							 *
* RETURN:								 *
* Z, IF HIT IS VALID							 *
*								         *
**************************************************************************

UNIV_COLL_CHECK
	CALLA	GETHEADPART			;OF EXPLOSION
	MOVE	*A8(OATEROCKET),A14,L
	JRZ	UCC_NOHIT			;BR=NO ROCKET COLLISION
	CMP	A0,A14
	JRNE	UCC_NOHIT			;BR=DIFFERENT EXPLOSION

	MOVE	*A0(RL_INTENDED_OBJ),A14,L	;DO WE HAVE THE RIGHT TARGET?
	CMP	A8,A14
	JRNE	UCC_NOHIT			;BR=NOPE. NOT THE RIGHT TARGET.
	
;	MOVE	*A0(RL_TARGET_OBJ),A14,L	;DO WE HAVE THE RIGHT TARGET?
;	JRZ	UCC_NOHIT			;BR=NO SIGHT OBJECT
;	MOVE	*A14(SIGHT_TARGET_OBJ),A14,L	
;	CMP	A8,A14
;	JRNE	UCC_NOHIT			;BR=NOPE. NOT THE RIGHT TARGET.

	CLRM	*A8(OATEROCKET),L		;HIT! READY FOR ANOTHER!
	RETS
UCC_NOHIT
	CLR	A14
	NOT	A14				;RESET Z FOR NO HIT
	RETS

**************************************************************************
*								         *
* DUMMY VECTORS								 *
*								         *
**************************************************************************

DUM_COLLVECT
	.WORD	0
	.LONG	DUM_CVECT

DUM_CVECT
DUM_GUNVECT
	RETS

**************************************************************************
*								         *
* COPY_ROMTBL - COPY ZERO TERMINATED ROM TABLE TO RAM AND COUNT IT	 *
* 									 *
* PASS:									 *
* A1 = ZERO TERMINATED TABLE						 *
* 									 *
* RETURN:								 *
* A0 = NUMBER OF TABLE ENTRIES						 *
*								         *
**************************************************************************

COPY_ROMTBL
	MMTM	SP,A1,A2
	CLR	A0
	MOVI	RAND_RAM_TBL,A2
CR_LUPE
	MOVE	*A1+,A14,W		;READ ROM TABLE ENTRY
	CMPK	MAX_RAND_TBL,A0
	JRNE	CR_GO			;BR=WE STILL HAVE SPACE LEFT
	CLR	A14			;NO SPACE LEFT, SET ZERO TERMINATOR
CR_GO
	MOVE	A14,*A2+,W		;WRITE RAM TABLE ENTRY
	MOVE	A14,A14
	JRZ	CR_DONE			;BR=NOT THE ZERO TERMINATOR
	INC	A0			;COUNT IT
	JRUC	CR_LUPE
CR_DONE
	MMFM	SP,A1,A2	
	RETS

**************************************************************************
*								         *
* PICK_ENTRY - PICK ENTRY OUT OF A TABLE				 *
* 									 *
* PASS:									 *
* A0 = NUMBER OF TABLE ENTRIES						 *
* 									 *
* RETURN:								 *
* A0 = NUMBER OF TABLE ENTRIES LEFT (Z SET IF LAST)			 *
* A2 = ENTRY PICKED							 *
*								         *
**************************************************************************

PICK_ENTRY
	MMTM	SP,A0,A3
	CALLA	RAND0			;GET RANDOM INDEX
	SLL	4,A0			;CONVERT TO OFFSET
	ADDI	RAND_RAM_TBL,A0		;ADD OFFSET TO BEGINNING OF TABLE
	MOVE	*A0,A2,W		;GET ENTRY 
	
	MOVE	A0,A3			;NOW MOVE PROCEDING ENTRIES
	ADDK	010H,A3
PE_LUPE
	MOVE	*A3+,A14,W		;READ NEXT TABLE ENTRY
	MOVE	A14,*A0+,W		;WRITE IT ONE UP
	JRNZ	PE_LUPE			;BR=NOT THE ZERO TERMINATOR		
	
	MMFM	SP,A0,A3
	DEC	A0			;ONE LESS NUMBER OF ENTRIES
	RETS

**************************************************************************
*								         *
* A_SET_MAP_IMG								 *
* 									 *
* A8 = OBJECT								 *
* AARG+,L = SET MAP_IMG TO THIS						 *
*								         *
**************************************************************************

A_SET_MAP_IMG
	CALLA	GETAFARG_LONG
	MOVE	*A8(OULINK),A14,L
	MOVE	A0,*A14(MAP_IMG),L
	RETS

**************************************************************************
*								         *
* BOX_CHECK_OBJ	- CHECK IF PLAYER'S CURSOR POINTS TO AN AREA OF AN OBJ.  *
*		  THIS AREA IS DEFINED BY A OFFSET BOX.			 *
*								         *
* PASS:									 *
* A2 = PLAYER DATA							 *
* A3 = UPPER LEFT BOX OFFSET [Y, X] FROM THE ANIM PT OF THE OBJ	 	 *
* A4 = LOWER RIGHT BOX OFFSET [Y, X] FROM THE ANIM PT OF THE OBJ	 *
*									 *
*   NOTE: offsets must be doubled if image is double-scaled 		 *
*									 *
* A8 = OBJECT								 *
* RETURN:								 *
* Z IS CLEAR, IF PLAYER'S CURSOR IS IN THE BOX				 *
*								         *
*  CURSOR UNIV POSITION IS LEFT IS a1 (Y) AND a7 (X)	   		 *
*								         *
**************************************************************************

BOX_CHECK_OBJ
	MMTM	SP,A0,A3,A4,A5,A6
	clr	a0	
BCO_hk:			

	MOVE	A3,A5
	SEXT	A3,W
	SLL	15,A3			;WORLD LEFT X OFFSET
	SRA	16,A5
	SLL	15,A5			;WORLD UPPER Y OFFSET
	MOVE	A4,A6
	SEXT	A4,W
	SLL	15,A4			;WORLD RIGHT X OFFSET
	SRA	16,A6
	SLL	15,A6			;WORLD LOWER Y OFFSET
	MOVE	*A8(OCTRL),A14,W
	BTST	B_FLIPH,A14
	JRZ	BCO_NOFLIPH		;BR=NO FLIPH
	NEG	A3
	NEG	A4
	SWAP	a3,a4			;SWAP LEFT AND RIGHT
BCO_NOFLIPH
	BTST	B_FLIPV,A14
	JRZ	BCO_NOFLIPV		;BR=NO FLIPV
	NEG	A5
	NEG	A6
	SWAP	a5,a6			;SWAP UPPER AND LOWER
BCO_NOFLIPV
	MOVE	*A8(OXVAL),A14,L
	ADD	A14,A3			;UNIVERSE LEFT X BOUNDARY
	ADD	A14,A4			;UNIVERSE RIGHT X BOUNDARY

	MOVE	*A8(OYVAL),A14,L
	ADD	A14,A5			;UNIVERSE UPPER Y BOUNDARY
	ADD	A14,A6			;UNIVERSE LOWER Y BOUNDARY

	move	a0,a0 			; check to see if a point was
	jrnz	got_pt			; supplied. No? get player cursor
	MOVE	*A2(PCURSORXY),A7,L
	MOVE	A7,A1
	SEXT	A7,W			; X in a7
	SRA	16,A1			; Y in a1

	MOVE	*A8(OZVAL),A0,L

	STOUXY	A0,A7,A1		;CONVERT SCREEN TO UNIVERSE		
got_pt:					; 

	CMP	A3,A7
	JRLT	BCO_FAIL		;BR=LEFT

	CMP	A4,A7
	JRGT	BCO_FAIL		;BR=RIGHT

	CMP	A5,A1
	JRLT	BCO_FAIL		;BR=ABOVE

	CMP	A6,A1	
	JRGT	BCO_FAIL		;BR=BELOW

	MOVK	1,A14			;INSIDE DA BOX
	JRUC	BCO_DONE
BCO_FAIL
	CLR	A14			;OUTSIDE DA BOX
BCO_DONE
	MMFM	SP,A0,A3,A4,A5,A6
	RETS

**************************************************************************
*								         *
* BOX_CHECK_OBJ2- CHECK IF A SUPPLIED POINT IS INSIDE AN AREA OF AN OBJ. *
*		  THIS AREA IS DEFINED BY AN OFFSET BOX.  		 *
*								         *
* PASS:									 *
* A7 = UNIV X POS							 *
* A1 = UNIV Y POS							 *
* A3 = UPPER LEFT BOX OFFSET [Y, X] FROM THE ANIM PT OF THE OBJ	 	 *
* A4 = LOWER RIGHT BOX OFFSET [Y, X] FROM THE ANIM PT OF THE OBJ	 *
*									 *
*   NOTE: offsets must be doubled if image is double-scaled 		 *
*									 *
* A8 = OBJECT								 *
* RETURN:								 *
* Z IS CLEAR, IF POINT IS IN THE BOX					 *
*								         *
**************************************************************************
BOX_CHECK_OBJ2:
	MMTM	SP,A0,A3,A4,A5,A6
	movk	1,a0			; signal point already there
	jruc	BCO_hk


**************************************************************************
*								         *
* TABLE_BOX_CHECK - CHECK IF PLAYER'S CURSOR POINTS TO AN AREA OF AN OBJ.*
*		    THE POSSIBLE AREAS ARE DEFINED BY A TABLE OF OFFSET  *
*		    BOXES.						 *
*								         *
* PASS:									 *
* A0 = TABLE OF OFFSET BOXES						 *
* TABLE FORMAT:								 *
* 	.LONG	[UPPER Y OFFSET, LEFT X], [LOWER Y, RIGHT X] ;BOX #1	 *
* 		.							 *
* 		.							 *
* 		.							 *
* 	.LONG	-1	;TERMINATE LIST					 *
*								         *
* A2 = PLAYER DATA							 *
* A8 = OBJECT								 *
* RETURN:								 *
* A1 = BOX INDEX, IF NO BOX, THEN A1 = 0 AND Z IS SET			 *
*								         *
**************************************************************************

TABLE_BOX_CHECK
	MMTM	SP,A0,A3,A4,A5,A6,A7,A9,A10,A11

	MOVE	*A8(OIMG),A14,L
	MOVE	*A14(IANIOFF),A14,L
	MOVE	A14,A4
	SEXT	A14,W
	SLL	15,A14			;WORLD ANIOFFX

	MOVE	A4,A5
	SRA	16,A5
	SLL	15,A5			;WORLD ANIOFFY

	MOVE	*A8(OFLAGS),A1,W
	BTST	B_DBLSCL,A1
	JRZ	TABC_NODUB		;BR=NO DOUBLE SCALE ACTION
	SLL	1,A14
	SLL	1,A5
TABC_NODUB

	MOVE	*A8(OCTRL),A1,W
	BTST	B_FLIPH,A1
	JRZ	TABC_NOAFLIPH		;BR=NO FLIPH
	NEG	A14			;NEGATE X OFFSET
TABC_NOAFLIPH

	MOVE	*A8(OXVAL),A3,L
	SUB	A14,A3			;LEFT (RIGHT) X OF OBJECT	

	BTST	B_FLIPV,A1
	JRZ	TABC_NOAFLIPV		;BR=NO FLIPV
	NEG	A5			;NEGATE Y OFFSET
TABC_NOAFLIPV
	MOVE	*A8(OYVAL),A4,L
	SUB	A5,A4			;UPPER (LOWER) Y OF OBJECT

	MOVE	*A2(PCURSORXY),A5,L
	MOVE	A5,A7
	SEXT	A5,W
	SRA	16,A7

	MOVE	*A8(OZVAL),A6,L

	STOUXY	A6,A5,A7		;CONVERT SCREEN TO UNIVERSE		

	CLR	A14
TABC_LUPE
	MOVE	*A0+,A6,L		;GET [UPPER Y, LEFT X] OFFSET
	JRN	TABC_FAIL

	INC	A14

	MOVE	A6,A9
	SEXT	A6,W
	SLL	15,A6			;WORLD LEFT X OFFSET
	SRA	16,A9
	SLL	15,A9			;WORLD UPPER Y OFFSET
	MOVE	*A0+,A10,L		;GET [LOWER Y, RIGHT X] OFFSET
	MOVE	A10,A11
	SEXT	A10,W
	SLL	15,A10			;WORLD RIGHT X OFFSET
	SRA	16,A11
	SLL	15,A11			;WORLD LOWER Y OFFSET
	BTST	B_FLIPH,A1
	JRZ	TABC_NOFLIPH		;BR=NO FLIPH
	NEG	A6
	NEG	A10
	XOR	A6,A10			;SWAP LEFT AND RIGHT
	XOR	A10,A6
	XOR	A6,A10
TABC_NOFLIPH
	BTST	B_FLIPV,A1
	JRZ	TABC_NOFLIPV		;BR=NO FLIPV
	NEG	A9
	NEG	A11
	XOR	A9,A11			;SWAP UPPER AND LOWER
	XOR	A11,A9
	XOR	A9,A11
TABC_NOFLIPV
	ADD	A3,A6			;UNIVERSE LEFT X BOUNDARY
	ADD	A3,A10			;UNIVERSE RIGHT X BOUNDARY

	ADD	A4,A9			;UNIVERSE UPPER Y BOUNDARY
	ADD	A4,A11			;UNIVERSE LOWER Y BOUNDARY

	CMP	A6,A5
	JRLT	TABC_LUPE		;BR=LEFT

	CMP	A10,A5
	JRGT	TABC_LUPE		;BR=RIGHT

	CMP	A9,A7
	JRLT	TABC_LUPE		;BR=ABOVE

	CMP	A11,A7	
	JRGT	TABC_LUPE		;BR=BELOW

	JRUC	TABC_DONE
TABC_FAIL
	CLR	A14			;OUTSIDE DA BOXES
TABC_DONE
	MMFM	SP,A0,A3,A4,A5,A6,A7,A9,A10,A11
	MOVE	A14,A1			;RETURN INDEX OR SET Z FLAG
	RETS

**************************************************************************
*								         *
* MAKE_ONE_EXPLOSION - MAKE AN EXPLOSION ON AN OBJECT AT IT'S ANIMP  	 *
*								         *
* PASS:									 *
* A8 = OBJECT								 *
* RETURN:								 *
* Z IS SET, IF WE FAILED						 *
*								         *
**************************************************************************

MAKE_ONE_EXPLOSION
	MMTM	SP,A0,A3,A4,A5
	MOVI	ONE_EXPLO_INIT,A5		;MAKE DA EXPLOSION
	CALLA	CREATE_OBJ
	JRZ	MOE_DONE			;BR=WHOOPS!

	MOVE	A8,A14
	ADDI	OXVAL,A14			;GET POSITION
	MMFM	A14,A3,A4,A5			;A5,A4,A3 = OXVAL, OYVAL, OZVAL

MOE_HOOK:
	DEC	A3

	MOVE	A0,A14
	ADDI	OZVAL+020H,A14			;SET POSITION
	MMTM	A14,A3,A4,A5			;A5,A4,A3 = OXVAL, OYVAL, OZVAL

	CALLA	INSOBJ
MOE_DONE
	MMFM	SP,A0,A3,A4,A5
	RETS


	.ref	FragCenterCoors
	.DEF	MAKE_EXPLO_GUN,MAKE_EXPLO_CENTER

*
*	Make an explosion at the player's cursor
*	a2 = player
*	a3 = 0 or M_DBLSCL 
*	a8 = object
*
MAKE_EXPLO_GUN:
	MMTM	SP,A0,A3,A4,A5
	MOVI	ONE_EXPLO_INIT,A5		;MAKE DA EXPLOSION
	CALLA	CREATE_OBJ
	JRZ	MOE_DONE			;BR=WHOOPS!
	
	move	*a0(OFLAGS),a14
	or	a3,a14
	move	a14,*a0(OFLAGS)
							
	move	*A2(PCURSORXY),A3,L	;Get [Y,X] Screen relative point.
	movx	A3,A5
	sext	A5
	sra	16,A3			;Now we have 16.16 screen X

	MOVE	*A8(OZVAL),A1,L		; Z of explo
	subk	4,a1
	STOUXY	A1,A5,A3		;UNIV X in a5, Y in a3

	move	a3,a4
	move	a1,a3

MOE_HOOK_V:
	move	*a8(OPART1),a14,L
	jrnz	MEGmulti
	move	a8,a14
MEGmulti:
	move	*a14(OXVEL),a1,L	; X vel
	move	a1,*a0(OXVEL),L

	jruc	MOE_HOOK


*
*	Make an explosion at the center of an object
*	a3 = 0 or M_DBLSCL 
*	a8 = object
*
MAKE_EXPLO_CENTER:
	MMTM	SP,A0,A3,A4,A5
	MOVI	ONE_EXPLO_INIT,A5		;MAKE DA EXPLOSION
	CALLA	CREATE_OBJ
	JRZ	MOE_DONE			;BR=WHOOPS!

	move	*a0(OFLAGS),a14
	or	a3,a14
	move	a14,*a0(OFLAGS)

	MMTM	SP,B1,B2,B5,B6,B8
	calla	FragCenterCoors		;leaves X in B1, Y in B5
	move	b5,a4
	sll	16,a4
	move	b1,a5
	sll	16,a5
	MMfM	SP,B1,B2,B5,B6,B8
	MOVE	*A8(OZVAL),A3,L		; Z of explo
	subk	4,a3
	jruc	MOE_HOOK_V



*
*	Make an explosion with offsets from object's animation point
*	a1 = X off (world)
*	a2 = Y off (world)
*	a3 = 0 or M_DBLSCL 
*
MAKE_EXPLO_OFF:
	MMTM	SP,A0,A3,A4,A5
	MOVI	ONE_EXPLO_INIT,A5		;MAKE DA EXPLOSION
	CALLA	CREATE_OBJ
	JRZ	MOE_DONE			;BR=WHOOPS!

	move	*a0(OFLAGS),a14
	or	a3,a14
	move	a14,*a0(OFLAGS)

	MOVE	A8,A14
	ADDI	OXVAL,A14			;GET POSITION
	MMFM	A14,A3,A4,A5			;A5,A4,A3 = OXVAL, OYVAL, OZVAL

	add	a2,a4
	add	a1,a5
	jruc	MOE_HOOK


ONE_EXPLO_INIT
	.LONG	FHKEXPLOB1, 0
	.WORD	OID_JUNK, DMAWNZ, 0, 0
	.LONG	C_STRTANIM
	.LONG	ONE_EXPLO_ANIM

ONE_EXPLO_ANIM
	LW	FHKEXPLOB1,6
	LW	FHKEXPLOB2,8
	LW	FHKEXPLOB3,6
	LW	FHKEXPLOB4,4
	LW	FHKEXPLOB5,4
	LW	FHKEXPLOB6,3
	LW	FHKEXPLOB7,3
	LW	FHKEXPLOB8,2
	LW	FHKEXPLOB9,2
	LW	FHKEXPLOB10,2
	LW	FHKEXPLOB11,2
	LWL	1,1|AFunc,DELETE_OBJ

**************************************************************************
*								         *
* THING_FLY_START - LAUNCH A UNIVERSE OBJECT INTO THE AIR, PLAY		 *
*		    PING-PONG, AND DELETE IT WHEN IN LANDS	 	 *
* 									 *
* PASS:									 *
* A0 = POINTER TO SCRIPT						 *
* A3 = CURSOR POSITION FROM GUN COLLISION OR FLAG ZERO FOR ROCKET COLLIS *
* A8 = OBJECT								 *
*								         *
* THING FLY SCRIPT:							 *
* 	.WORD	OFLYSCORE, OFLYSCOREINC					 *
* 	.LONG	OFLYHITSND, OFLYYVEL					 *
* 	.WORD	OFLYXSLL, OYACCEL, OZVEL				 *
* 									 *
* OFLYSCORE    = INITIAL SCORE ON NEXT HIT				 *
* OFLYSCOREINC = INCREMENT SCORE FOR NEXT HIT				 *
* OFLYHITSND   = SOUND ON HIT						 *
* OFLYYVEL     = Y VELOCITY ON HIT					 *
* OFLYXSLL     = X VELOCITY SHIFT VALUE ON HIT				 *
* OYACCEL      = INITIAL Y ACCELERATION					 *
* OZVEL        = INITIAL Z VELOCITY					 *
*								         *
**************************************************************************

OFLYSCORE	EQU	ODATA		;UHW NEXT SCORE
OFLYSCOREINC	EQU	ODATA+010H	;UHW SCORE INCREMENT
OFLYHITSND	EQU	ODATA+020H	;UHL HIT SOUND
OFLYYVEL	EQU	ODATA+040H	;UHL Y VELOCITY
OFLYXVELMAX	EQU	ODATA+060H	;UHL MAXIMUM X VELOCITY
OFLYXSLL	EQU	ODATA+080H	;UHW X VELOCITY LEFT SHIFT VALUE

THING_FLY_START
	MMTM	SP,A0,A1,A4,A5
	MMFM	A0,A1,A4,A5		;READ SCRIPT
	MOVE	A8,A14
	ADDI	ODATA+020H*3,A14
	MMTM	A14,A1,A4,A5		;LOAD PARAMETERS
	MOVE	*A0+,A1,W
	MOVE	A1,*A8(OFLYXSLL),W
	MOVE	*A0(0),*A8(OYACCEL),W
	ADDK	010H,A0
	MOVE	*A0,A14,W
	MOVE	A14,*A8(OZVEL),L

	MOVE	*A8(OIMG),A14,L		;COMPUTE MAXIMUM X VELOCITY
	MOVE	*A14(ISIZEX),A14,W
	DEC	A1
	SLL	A1,A14
	MOVE	A14,*A8(OFLYXVELMAX),L
	
	MOVE	*A8(OULINK),A0,L	;REMOVE FROM UNIVERSE
	CLR	A14
	MOVE	A14,*A8(OULINK),L
	CALLA	REMOVE_AND_FREE_LINK

	MOVI	THING_FLY_COLLVECT,A14	;NEW VECTORS
	MOVE	A14,*A8(OCVECT),L
	MOVI	THING_FLY_GUNVECT,A14
	MOVE	A14,*A8(OGUNVECT),L

	MOVE	*A8(OFLAGS),A14,W
	ORI	M_GCOLL,A14		;SET GROUND COLL FLAG
	MOVE	A14,*A8(OFLAGS),W

	CALLR	TFG_GO			;LAUNCH!
	MMFM	SP,A0,A1,A4,A5
	RETS

THING_FLY_COLLVECT
	WWL	OID_GRND,0FFFFH,DEL_PROC_AND_OBJ
	WWL	OID_PROCKET,~MASK_PLAYER,UNIV_ROCKET_COLL
	WWL	OID_PEXPLOSION,~MASK_PLAYER,THING_FLY_CVECT
	WL	0,DUMCRETS

THING_FLY_CVECT
	CALLR	UNIV_COLL_CHECK
	JRNZ	TF_ABORT

	MOVE	*A0(OID),A0,W			;GET PLAYER DATA ADDRESS
	CALLA	POID_TO_PDATA
	
	CLR	A3				;NO CURSOR POSITION, FLY RANDOM

THING_FLY_GUNVECT
	MOVE	*A8(OFLYSCORE),A1,W		;SCORE
	CLR	A9
	CALLA	PRINT_SCORE

	CALLA	UNIV_FLASH			;FLASH IT!

	MOVE	*A8(OFLYSCOREINC),A14,W		;SET NEXT SCORE
	ADD	A14,A1
	MOVE	A1,*A8(OFLYSCORE),W	
TFG_GO
	MOVE	*A8(OFLYHITSND),A0,L		;MAKE SOME NOISE!
	CALLA	ONESND_Z

	MOVE	*A8(OFLYYVEL),*A8(OYVEL),L	;SET Y VELOCITY

	SEXT	A3,W
	JRNZ	TFG_XOK				;BR=NO RANDOM DIRECTION
	MOVE	*A8(OFLYXVELMAX),A0,L
	MOVE	A0,A1
	NEG	A1
	CALLA	RANGERND			;GET RANDOM X VELOCITY
	MOVE	A0,A1
	JRUC	TFG_XSET
TFG_XOK
	MOVE	*A8(ODAGX),A1,W			;COMPUTE VELOCITY FROM OFFSET
	MOVE	*A8(OSIZEX),A14,W		; FROM THE CENTER OF THE OBJ
	SRA	1,A14
	ADD	A14,A1				;CENTER OF THE LID (SCREEN X)
	SUB	A3,A1				;DIFFERENCE FROM GUN (SCREEN X)
	MOVE	*A8(OFLYXSLL),A14,W
	SLL	A14,A1				;CONVERT TO VELOCITY
	MOVE	*A8(OZVAL),A4,L
	MOVE	@ZBASE,A14,L
	SUB	A14,A4
	SRA	Z2SCALE,A4	
	SETF	16,1,1
	MPYS	A4,A1				;SCALE X VELOCITY	
	SETF	32,1,1
	SRA	8,A1
TFG_XSET
	MOVE	A1,*A8(OXVEL),L			;SET X VELOCITY
TF_ABORT
	RETS

**************************************************************************
*								         *
* FRAGMENT STUFF							 *
*								         *
**************************************************************************

;UNIVERSAL FRAGMENT

FRAG_U1		     
	.long	FRAG_UANIM,F_UFRAG_STUFF
	.word	OID_JUNK,(1 << 11) + (0 << 6) + (FRGGCOL)
	.long	0

FRAG_U2		     
	.long	FRAG_UANIM,F_UFRAG_STUFF
	.word	OID_JUNK,(2 << 11) + (0 << 6) + (FRGGCOL)
	.long	0

FRAG_U3		     
	.long	FRAG_UANIM,F_UFRAG_STUFF
	.word	OID_JUNK,(3 << 11) + (0 << 6) + (FRGGCOL)
	.long	0

FRAG_U5		     
	.long	FRAG_UANIM,F_UFRAG_STUFF
;	.word	OID_JUNK,(3 << 11) + (0 << 6) + (FRGGCOL+FRGNOFLY)
	.word	OID_JUNK,(3 << 11) + (1 << 6) + (FRGGCOL)
	.long	FRAG_UANIM,F_UFRAG_STUFF
;	.word	OID_JUNK,(2 << 11) + (0 << 6) + (FRGBOG+FRGGCOL+FRGNOFLY)
	.word	OID_JUNK,(2 << 11) + (0 << 6) + (FRGBOG+FRGGCOL)
	.long	0

FRAG_U10
	.long	FRAG_UANIM,F_UFRAG_STUFF
;	.word	OID_JUNK,(6 << 11) + (0 << 6) + (FRGGCOL+FRGNOFLY)
	.word	OID_JUNK,(6 << 11) + (1 << 6) + (FRGGCOL)
	.long	FRAG_UANIM,F_UFRAG_STUFF
;	.word	OID_JUNK,(4 << 11) + (0 << 6) + (FRGBOG+FRGGCOL+FRGNOFLY)
	.word	OID_JUNK,(4 << 11) + (0 << 6) + (FRGBOG+FRGGCOL)
	.long	0

FRAG_U1_X2		     
	.long	FRAG_UANIM,F_UFRAG_STUFF_X2
	.word	OID_JUNK,(1 << 11) + (0 << 6) + (FRGGCOL)
	.long	0

FRAG_U10_X2
	.long	FRAG_UANIM,F_UFRAG_STUFF_X2
	.word	OID_JUNK,(6 << 11) + (1 << 6) + (FRGGCOL)

	.long	FRAG_UANIM,F_UFRAG_STUFF_X2
	.word	OID_JUNK,(4 << 11) + (0 << 6) + (FRGBOG+FRGGCOL)
	.long	0

FRAG_U10_MIX
	.long	FRAG_UANIM,F_UFRAG_STUFF
	.word	OID_JUNK,(6 << 11) + (1 << 6) + (FRGGCOL)

	.long	FRAG_UANIM,F_UFRAG_STUFF_X2
	.word	OID_JUNK,(4 << 11) + (0 << 6) + (FRGBOG+FRGGCOL)
	.long	0


FRAG_U20
;	.long	FRAG_UANIM,F_UFRAG_STUFF
;;	.word	OID_JUNK,(12 << 11) + (0 << 6) + (FRGGCOL+FRGNOFLY)
;	.word	OID_JUNK,(12 << 11) + (0 << 6) + (FRGGCOL)
	.long	FRAG_UANIM,F_UFRAG_STUFF
	.word	OID_JUNK,(5 << 11) + (1 << 6) + (FRGGCOL)
	.long	FRAG_UANIM,F_UFRAG_STUFF
	.word	OID_JUNK,(5 << 11) + (1 << 6) + (FRGGCOL)

;	.long	FRAG_UANIM,F_UFRAG_STUFF
;;	.word	OID_JUNK,(8 << 11) + (0 << 6) + (FRGBOG+FRGGCOL+FRGNOFLY)
;	.word	OID_JUNK,(8 << 11) + (0 << 6) + (FRGBOG+FRGGCOL)
	.long	FRAG_UANIM,F_UFRAG_STUFF
	.word	OID_JUNK,(5 << 11) + (1 << 6) + (FRGBOG+FRGGCOL)

	.long	0

FRAG_U20_X2
	.long	FRAG_UANIM,F_UFRAG_STUFF_X2
	.word	OID_JUNK,(5 << 11) + (1 << 6) + (FRGGCOL)
	.long	FRAG_UANIM,F_UFRAG_STUFF_X2
	.word	OID_JUNK,(5 << 11) + (1 << 6) + (FRGGCOL)

	.long	FRAG_UANIM,F_UFRAG_STUFF_X2
	.word	OID_JUNK,(5 << 11) + (1 << 6) + (FRGBOG+FRGGCOL)

	.long	0

FRAG_U20_MIX
	.long	FRAG_UANIM,F_UFRAG_STUFF_X2
	.word	OID_JUNK,(5 << 11) + (1 << 6) + (FRGGCOL)

	.long	FRAG_UANIM,F_UFRAG_STUFF
	.word	OID_JUNK,(5 << 11) + (1 << 6) + (FRGGCOL)

	.long	FRAG_UANIM,F_UFRAG_STUFF_X2
	.word	OID_JUNK,(5 << 11) + (1 << 6) + (FRGBOG+FRGGCOL)

	.long	0


FRAG_U30
;	.long	FRAG_UANIM,F_UFRAG_STUFF
;;	.word	OID_JUNK,(18 << 11) + (0 << 6) + (FRGGCOL+FRGNOFLY)
;	.word	OID_JUNK,(18 << 11) + (0 << 6) + (FRGGCOL)
	.long	FRAG_UANIM,F_UFRAG_STUFF
	.word	OID_JUNK,(5 << 11) + (1 << 6) + (FRGGCOL)
	.long	FRAG_UANIM,F_UFRAG_STUFF
	.word	OID_JUNK,(5 << 11) + (1 << 6) + (FRGGCOL)
	.long	FRAG_UANIM,F_UFRAG_STUFF
	.word	OID_JUNK,(5 << 11) + (1 << 6) + (FRGGCOL)

;	.long	FRAG_UANIM,F_UFRAG_STUFF
;;	.word	OID_JUNK,(12 << 11) + (0 << 6) + (FRGBOG+FRGGCOL+FRGNOFLY)
;	.word	OID_JUNK,(12 << 11) + (0 << 6) + (FRGBOG+FRGGCOL)
	.long	FRAG_UANIM,F_UFRAG_STUFF
	.word	OID_JUNK,(5 << 11) + (1 << 6) + (FRGBOG+FRGGCOL)
	.long	FRAG_UANIM,F_UFRAG_STUFF
	.word	OID_JUNK,(5 << 11) + (1 << 6) + (FRGBOG+FRGGCOL)

	.long	0

FRAG_U40
;	.long	FRAG_UANIM,F_UFRAG_STUFF
;;	.word	OID_JUNK,(24 << 11) + (0 << 6) + (FRGGCOL+FRGNOFLY)
;	.word	OID_JUNK,(24 << 11) + (0 << 6) + (FRGGCOL)
	.long	FRAG_UANIM,F_UFRAG_STUFF
	.word	OID_JUNK,(5 << 11) + (1 << 6) + (FRGGCOL)
	.long	FRAG_UANIM,F_UFRAG_STUFF
	.word	OID_JUNK,(5 << 11) + (1 << 6) + (FRGGCOL)
	.long	FRAG_UANIM,F_UFRAG_STUFF
	.word	OID_JUNK,(5 << 11) + (1 << 6) + (FRGGCOL)
	.long	FRAG_UANIM,F_UFRAG_STUFF
	.word	OID_JUNK,(5 << 11) + (1 << 6) + (FRGGCOL)

;	.long	FRAG_UANIM,F_UFRAG_STUFF
;;	.word	OID_JUNK,(16 << 11) + (0 << 6) + (FRGBOG+FRGGCOL+FRGNOFLY)
;	.word	OID_JUNK,(16 << 11) + (0 << 6) + (FRGBOG+FRGGCOL)
	.long	FRAG_UANIM,F_UFRAG_STUFF
	.word	OID_JUNK,(5 << 11) + (1 << 6) + (FRGBOG+FRGGCOL)
	.long	FRAG_UANIM,F_UFRAG_STUFF
	.word	OID_JUNK,(5 << 11) + (1 << 6) + (FRGBOG+FRGGCOL)
	.long	FRAG_UANIM,F_UFRAG_STUFF
	.word	OID_JUNK,(5 << 11) + (1 << 6) + (FRGBOG+FRGGCOL)

	.long	0

FRAG_U40_X2
	.long	FRAG_UANIM,F_UFRAG_STUFF_X2
	.word	OID_JUNK,(5 << 11) + (1 << 6) + (FRGGCOL)
	.long	FRAG_UANIM,F_UFRAG_STUFF_X2
	.word	OID_JUNK,(5 << 11) + (1 << 6) + (FRGGCOL)
	.long	FRAG_UANIM,F_UFRAG_STUFF_X2
	.word	OID_JUNK,(5 << 11) + (1 << 6) + (FRGGCOL)
	.long	FRAG_UANIM,F_UFRAG_STUFF_X2
	.word	OID_JUNK,(5 << 11) + (1 << 6) + (FRGGCOL)

	.long	FRAG_UANIM,F_UFRAG_STUFF_X2
	.word	OID_JUNK,(5 << 11) + (1 << 6) + (FRGBOG+FRGGCOL)
	.long	FRAG_UANIM,F_UFRAG_STUFF_X2
	.word	OID_JUNK,(5 << 11) + (1 << 6) + (FRGBOG+FRGGCOL)
	.long	FRAG_UANIM,F_UFRAG_STUFF_X2
	.word	OID_JUNK,(5 << 11) + (1 << 6) + (FRGBOG+FRGGCOL)

	.long	0

FRAG_UANIM
	LW	FHKI1SHRAPB1,3
	LW	FHKI1SHRAPB2,3
	LW	FHKI1SHRAPB3,3
	LW	FHKI1SHRAPB4,3
	LW	FHKI1SHRAPB5,3
	LW	FHKI1SHRAPB6,3
	LWL	FHKI1SHRAPB7,3|AFunc,A_DELETE_ZBOT
	.long	0

;LARGE GLASS SHARD FRAGMENT

FRAG_S10
;	.long	FRAG_SHARD_ANIM,F_UFRAG_STUFF
;;	.word	OID_JUNK,(6 << 11) + (0 << 6) + (FRGGCOL+FRGNOFLY)
;	.word	OID_JUNK,(6 << 11) + (0 << 6) + (FRGGCOL)
	.long	FRAG_SHARD_ANIM,F_UFRAG_STUFF
	.word	OID_JUNK,(5 << 11) + (1 << 6) + (FRGGCOL)

	.long	FRAG_SHARD_ANIM,F_UFRAG_STUFF
;	.word	OID_JUNK,(4 << 11) + (0 << 6) + (FRGBOG+FRGGCOL+FRGNOFLY)
	.word	OID_JUNK,(4 << 11) + (1 << 6) + (FRGBOG+FRGGCOL)
	.long	0

FRAG_S20
;	.long	FRAG_SHARD_ANIM,F_UFRAG_STUFF
;;	.word	OID_JUNK,(12 << 11) + (0 << 6) + (FRGGCOL+FRGNOFLY)
;	.word	OID_JUNK,(12 << 11) + (0 << 6) + (FRGGCOL)
	.long	FRAG_SHARD_ANIM,F_UFRAG_STUFF
	.word	OID_JUNK,(5 << 11) + (1 << 6) + (FRGGCOL)
	.long	FRAG_SHARD_ANIM,F_UFRAG_STUFF
	.word	OID_JUNK,(5 << 11) + (1 << 6) + (FRGGCOL)

;	.long	FRAG_SHARD_ANIM,F_UFRAG_STUFF
;;	.word	OID_JUNK,(8 << 11) + (0 << 6) + (FRGBOG+FRGGCOL+FRGNOFLY)
;	.word	OID_JUNK,(8 << 11) + (0 << 6) + (FRGBOG+FRGGCOL)
	.long	FRAG_SHARD_ANIM,F_UFRAG_STUFF
	.word	OID_JUNK,(5 << 11) + (1 << 6) + (FRGBOG+FRGGCOL)

	.long	0

FRAG_SHARD_ANIM
	LW	fshard2,1
	LW	fshard3,1
	LW	fshard4,1
	LW	fshard5,1
	LW	fshard6,1
	LW	fshard7,1
	LW	fshard8,1
	LW	fshard9,1
	LWL	fshard10,1|AFunc,A_DELETE_ZBOT
	.long	0

;SMALL GLASS SHARD FRAGMENT

FRAG_SS5
	.long	FRAG_SMALL_SHARD_ANIM,F_UFRAG_STUFF
;	.word	OID_JUNK,(3 << 11) + (0 << 6) + (FRGGCOL+FRGNOFLY)
	.word	OID_JUNK,(3 << 11) + (1 << 6) + (FRGGCOL)
	.long	FRAG_SMALL_SHARD_ANIM,F_UFRAG_STUFF
;	.word	OID_JUNK,(2 << 11) + (0 << 6) + (FRGBOG+FRGGCOL+FRGNOFLY)
	.word	OID_JUNK,(2 << 11) + (1 << 6) + (FRGBOG+FRGGCOL)
	.long	0

FRAG_SS10
	.long	FRAG_SMALL_SHARD_ANIM,F_UFRAG_STUFF
;	.word	OID_JUNK,(6 << 11) + (0 << 6) + (FRGGCOL+FRGNOFLY)
	.word	OID_JUNK,(5 << 11) + (1 << 6) + (FRGGCOL)
	.long	FRAG_SMALL_SHARD_ANIM,F_UFRAG_STUFF
;	.word	OID_JUNK,(4 << 11) + (0 << 6) + (FRGBOG+FRGGCOL+FRGNOFLY)
	.word	OID_JUNK,(4 << 11) + (1 << 6) + (FRGBOG+FRGGCOL)
	.long	0

FRAG_SS20
;	.long	FRAG_SMALL_SHARD_ANIM,F_UFRAG_STUFF
;;	.word	OID_JUNK,(12 << 11) + (0 << 6) + (FRGGCOL+FRGNOFLY)
;	.word	OID_JUNK,(12 << 11) + (0 << 6) + (FRGGCOL)
	.long	FRAG_SMALL_SHARD_ANIM,F_UFRAG_STUFF
	.word	OID_JUNK,(5 << 11) + (1 << 6) + (FRGGCOL)
	.long	FRAG_SMALL_SHARD_ANIM,F_UFRAG_STUFF
	.word	OID_JUNK,(5 << 11) + (1 << 6) + (FRGGCOL)

	.long	FRAG_SMALL_SHARD_ANIM,F_UFRAG_STUFF
;	.word	OID_JUNK,(8 << 11) + (0 << 6) + (FRGBOG+FRGGCOL+FRGNOFLY)
	.word	OID_JUNK,(5 << 11) + (1 << 6) + (FRGBOG+FRGGCOL)
	.long	0

FRAG_SS30
;	.long	FRAG_SMALL_SHARD_ANIM,F_UFRAG_STUFF
;;	.word	OID_JUNK,(18 << 11) + (0 << 6) + (FRGGCOL+FRGNOFLY)
;	.word	OID_JUNK,(18 << 11) + (0 << 6) + (FRGGCOL)
	.long	FRAG_SMALL_SHARD_ANIM,F_UFRAG_STUFF
	.word	OID_JUNK,(5 << 11) + (1 << 6) + (FRGGCOL)
	.long	FRAG_SMALL_SHARD_ANIM,F_UFRAG_STUFF
	.word	OID_JUNK,(5 << 11) + (1 << 6) + (FRGGCOL)
	.long	FRAG_SMALL_SHARD_ANIM,F_UFRAG_STUFF
	.word	OID_JUNK,(5 << 11) + (1 << 6) + (FRGGCOL)

;	.long	FRAG_SMALL_SHARD_ANIM,F_UFRAG_STUFF
;;	.word	OID_JUNK,(12 << 11) + (0 << 6) + (FRGBOG+FRGGCOL+FRGNOFLY)
;	.word	OID_JUNK,(12 << 11) + (0 << 6) + (FRGBOG+FRGGCOL)
	.long	FRAG_SMALL_SHARD_ANIM,F_UFRAG_STUFF
	.word	OID_JUNK,(5 << 11) + (1 << 6) + (FRGBOG+FRGGCOL)
	.long	FRAG_SMALL_SHARD_ANIM,F_UFRAG_STUFF
	.word	OID_JUNK,(5 << 11) + (1 << 6) + (FRGBOG+FRGGCOL)

	.long	0

FRAG_SMALL_SHARD_ANIM
	LW	SMSHRD1,1
	LW	SMSHRD2,1
	LW	SMSHRD3,1
	LW	SMSHRD4,1
	LW	SMSHRD5,1
	LW	SMSHRD6,1
	LW	SMSHRD7,1
	LW	SMSHRD8,1
	LW	SMSHRD9,1
	LWL	SMSHRD10,1|AFunc,A_DELETE_ZBOT
	.long	0

FRAG_ONE_SPARK
	.long	FRAG_SPARK_ANIM,0
	.word	OID_JUNK,(1 << 11) + (0 << 6) + (FRGNOFLP+FRGPAL)
	.long	0

FRAG_SPARK_ANIM
	LW	FWORKS1,4
	LW	FWORKS2,4
	LW	FWORKS3,4
	LW	FWORKS4,4
	LW	FWORKS5,4
	LWL	1,1|AFunc,DELETE_OBJ

FRAG_ONE_CLOUD
	.long	FRAG_DUST_CLOUD_ANIM,F_UFRAG_STUFF
	.word	OID_JUNK,(1 << 11) + (0 << 6) + (FRGGCOL+FRGNOFLY+FRGNOFLP)
	.long	0

FRAG_ONE_CLOUD_X2
	.long	FRAG_DUST_CLOUD_ANIM,F_UFRAG_STUFF_X2
	.word	OID_JUNK,(1 << 11) + (0 << 6) + (FRGGCOL+FRGNOFLY+FRGNOFLP)
	.long	0

FRAG_DUST_CLOUD_ANIM
	LW	dstcld1,4
	LW	dstcld2,4
	LW	dstcld3,4
	LW	dstcld4,4
	LW	dstcld5,4
	LW	dstcld6,4
	LW	dstcld7,4
	LW	dstcld8,4
	LWL	1,1|AFunc,DELETE_OBJ

;DUST CLOUD PALETTES
;
;use P_DUSTCLD for a gray cloud

GOLD_DUST_PAL:
   .word   64 
   .word   0001fh,038c0h,02840h,03080h,04100h,03ce0h,034a0h,05180h
   .word   04520h,034a0h,02c60h,04940h,059c2h,038c0h,03080h,04d60h
   .word   06204h,03ce0h,038c0h,07288h,06a46h,07acah,055a1h,05de3h
   .word   06625h,07f0bh,05182h,04940h,04100h,03080h,03ce0h,02c65h
   .word   059c4h,04524h,07f4bh,05de4h,06205h,059c3h,06e67h,05de5h
   .word   04100h,05181h,055a2h,06206h,04d65h,038c0h,05187h,06a48h
   .word   076a9h,06626h,04d61h,0308ah,05deah,04d60h,06627h,02847h
   .word   04943h,05de8h,055a9h,06a47h,03ce0h,07f8bh,076a7h,07ee9h

**************************************************************************
*								         *
* F_UFRAG_STUFF - DO STUFF						 *
*								         *
* A0 = Ptr to un-inserted object.					 *
* 									 *
* Note: Frag funcs must preserve A8-A11 and all B-File regs.		 *
*								         *
**************************************************************************
**************************************************************************
*								         *
* 	F_UFRAG_STUFF_X2						 *
* 									 *
* 	Frag create func to make the fragment X2 scale then		 *
* 	jump to the usual UFRAG_STUFF					 *
* 									 *
* 	A0 = Ptr to un-inserted object.					 *
*								         *
**************************************************************************
F_UFRAG_STUFF_X2
	ORIM	M_DBLSCL,*A0(OFLAGS),W
F_UFRAG_STUFF
	MOVI	FRAG_UCOLL,A14
	MOVE	A14,*A0(OCVECT),L	;Set up chunk with Vectors	

	move	A0,A2
	MOVE	*A13(FPDATA),A0,L	;GET PALETTE
	JRZ	FUS_NOPAL		;BR = NO PALETTE TO SET!
	calla	GETFPAL
	JRNZ	FUS_PAL			;BR = WE HAVE PALETTE!
	CLR	A0
FUS_PAL
	move	A0,*A2(OPAL),W
FUS_NOPAL
	move	A2,A0
	RETS

FRAG_UCOLL
	WWL	OID_GRND,0FFFFH,FRAG_UGRND_COLL
	WL	0,DUMCRETS

**************************************************************************
*								         *
* FRAG_UGRND_COLL - FRAGMENT GROUND COLLISION VECTOR			 *
*								         *
* PASS:									 *
* A8 = OBJECT								 *
*								         *
**************************************************************************

FRAG_UGRND_COLL
	MOVE	*A8(OYVEL),A14,L
	JAN	DELETE_OBJ			;BR=GOING UP
	JAZ	DELETE_OBJ			;BR=STOPPED

;	MOVE	A14,A0
;	SRA	2,A0
;	SUB	A0,A14				;OYVEL=OYVEL*3/4 

;	SRA	1,A14				;OYVEL=OYVEL/2

	SRA	2,A14				;OYVEL=OYVEL/4

	CMPI	010000H,A14
	JALT	DELETE_OBJ			;BR=BELOW MINIMUM VELOCITY
	NEG	A14				;REVERSE VELOCITY
	MOVE	A14,*A8(OYVEL),L
	RETS

**************************************************************************
*								         *
* STOP_ENEMIES - TERMINATE AN ENEMY GENERATOR				 *
*								         *
* PASS:									 *
* A8 = OBJECT								 *
*								         *
**************************************************************************

STOP_ENEMIES
	PUSH	A0
	MOVE	*A8(OULINK),A0,L

	MOVE	*A0(MAP_FLAGS),A14,W
	JRNN	SE_NOENEMY			;BR=NOT AN ENEMY GENERATOR

	ANDNI	1 << B_BF_ENEMY,A14
	MOVE	A14,*A0(MAP_FLAGS),W

	MOVE	*A0(MAP_IMG),A14,L		;TURN OFF FLAGS
	ANDNI	M_IF_DANIM|M_IF_SEQ,A14
	MOVE	A14,*A0(MAP_IMG),L

	MOVE	*A8(OFLAGS),A14,W
	BTST	B_ANIM,A14
	JRZ	SE_IDLE				;BR=NOT ANIMATING
	CALLA	PULL_ANIM
	JRUC	SE_DONE
SE_IDLE
	MOVE	@ENEMYDATA0,A0,L
SE_DEL_ENEMY_LUPE
	MOVE	*A0+,A14,L
	.if	DEBUG
	LOCKON	Z
	.else
	JRZ	SE_DONE
	.endif
	CMP	A8,A14
	JRNE	SE_DEL_ENEMY_LUPE		;BR=NO MATCH
	move	@ENEMYDATA,a14,L
	cmp	a0,a14
	jreq	SE_last
	move	*-a14,*-a0,L
	addk	20h,a14
SE_last:
	clr	a0
	move	a0,*-a14,L
	move	a14,@ENEMYDATA,L
SE_NOENEMY
SE_DONE
	PULLQ	A0
	RETS

**************************************************************************
*								         *
* 500 POINT AWARD VECTORS						 *
*								         *
**************************************************************************

PTS_500_COLLVECT
	.WORD	0
	.LONG	PTS_500_CVECT

PTS_500_COLLVECTR
	WWL	OID_PROCKET,~MASK_PLAYER,UNIV_ROCKET_COLL
	WWL	OID_PEXPLOSION,~MASK_PLAYER,PTS_500_CVECTR
	WL	0,DUMCRETS

PTS_500_CVECTR
	CALLR	UNIV_COLL_CHECK
	JRNZ	PTS_500_DONE
PTS_500_CVECT
	MOVE	*A0(OID),A0,W			;GET PLAYER DATA ADDRESS
	CALLA	POID_TO_PDATA
	MOVK	M_NOMORE|M_LASTFRM|M_FLASHOBJ,A7	;LAST FRAME AND FLASH
	JRUC	PTS_500_GO
PTS_500_GUNVECT
	MOVK	M_NOMORE|M_FLASHOBJ,A7		;FLASH
PTS_500_GO
	MOVI	500,A5				;500 POINTS
	CLR	A9				;NO OFFSET
	CALLA	UNIV_DAMAGE_HANDLER
;	JRNC	PTS_500_DONE
PTS_500_DONE	
	RETS

**************************************************************************
*								         *
* PORTAL DAMAGE VECTORS							 *
*								         *
**************************************************************************

PORTAL_DAMAGE_COLLVECT
	WWL	OID_PROCKET,~MASK_PLAYER,UNIV_ROCKET_COLL
	WWL	OID_PEXPLOSION,~MASK_PLAYER,PORTAL_DAMAGE_CVECT
	WL	0,DUMCRETS

PORTAL_DAMAGE_CVECT
	CALLR	UNIV_COLL_CHECK
	JRNZ	PD_DONE

	MOVE	*A0(OID),A0,W			;GET PLAYER DATA ADDRESS
	CALLA	POID_TO_PDATA

PORTAL_DAMAGE_GUNVECT
	MOVI	1000,A5				;500 POINTS
	MOVK	M_NOMORE|M_FLASHOBJ,A7		;NO MORE DAMAGE AND FLASH
	CLR	A9				;NO OFFSET
	CALLA	UNIV_DAMAGE_HANDLER
	JRNC	PD_DONE
	JAUC	PORTAL_GUNVECT
PD_DONE
	RETS

**************************************************************************
*								         *
* OBJ_KILL_ENEMIES - KILL ALL ENEMIES IN AN AREA DEFINED BY X AND Y	 *
*                     BOUNDARIES FROM THE ANIMATION POINT EITHER IN	 *
*                     FRONT OF OR BEHIND THE OBJECT			 *
* 									 *
* PASS:									 *
* 									 *
* A1  = Z WORLD BOUNDARY OFFSET (USE NEGATIVE FOR IN FRONT OF OBJECT,	 *
*                               POSITIVE FOR BEHIND OBJECT)		 *
* A8  = DA OBJECT							 *
* A9  = [Y TOP, Y BOTTOM] SCREEN BOUNDARY OFFSET FROM ANIMATION POINT	 *
* A11 = [X LEFT, X RIGHT] SCREEN BOUNDARY OFFSET FROM ANIMATION POINT	 *
*								         *
**************************************************************************

OBJ_KILL_ENEMIES
	PUSH	A8

	MOVI	FGLIST,A0

	MOVE	A11,A3
	SRA	16,A11
	SLL	15,A11			;X LEFT	OFFSET
	SEXT	A3,W
	SLL	15,A3			;X RIGHT OFFSET

	MOVE	A9,A10
	SRA	16,A9
	SLL	15,A9			;Y TOP OFFSET
	SEXT	A10,W
	SLL	15,A10			;Y BOTTOM OFFSET

	MOVE	*A8(OCTRL),A14,W
	BTST	B_FLIPH,A14
	JRZ	OKE_CHECK_FLIPV		;BR = NO HORIZONTAL FLIP
	SWAP	A11,A3			;3 XORS
	NEG	A11
	NEG	A3
OKE_CHECK_FLIPV
	BTST	B_FLIPV,A14
	JRZ	OKE_GET_BOUNDS		;BR = NO VERTICAL FLIP
	SWAP	A9,A10			;3 XORS
	NEG	A9
	NEG	A10
OKE_GET_BOUNDS
	MOVE	*A8(OXVAL),A14,L
	ADD	A14,A11			;LEFT BOUNDARY
	ADD	A14,A3			;RIGHT BOUNDARY

	MOVE	*A8(OYVAL),A14,L
	ADD	A14,A9			;TOP BOUNDARY
	ADD	A14,A10			;BOTTOM BOUNDARY

	MOVI	MASK_TYPE|MASK_SUPP,A4
	MOVI	TYPE_ENEMY,A5

	MOVE	*A8(OZVAL),A6,L

	MOVI	OKE_BEHIND_CHECK,A7
	ABS	A1
	JRN	OKE_NEXT			;BR = CHECK BEHIND		
	MOVI	OKE_INFRONT_CHECK,A7
	JRUC	OKE_NEXT
OKE_LUPE
	MOVE	*A8(OZVAL),A14,L
	SUB	A6,A14
	ABS	A14
	CMP	A1,A14
	JRGT	OKE_DONE			;BR = OUT OF Z RANGE
	
	MOVE	*A8(OID),A14,L
	AND	A4,A14
	CMP	A5,A14
	JRNE	OKE_NEXT			;BR = NOT AN ENEMY

	MOVE	*A8(OXVAL),A14,L
	CMP	A11,A14
	JRLT	OKE_NEXT			;BR = OUT OF LEFT BOUNDS
	CMP	A3,A14
	JRGT	OKE_NEXT			;BR = OUT OF RIGHT BOUNDS

	MOVE	*A8(OYVAL),A14,L
	CMP	A9,A14
	JRLT	OKE_NEXT			;BR = OUT OF TOP BOUNDS
	CMP	A10,A14
	JRGT	OKE_NEXT			;BR = OUT OF BOTTOM BOUNDS

	MOVE	*A8(OGUNVECT),A14,L
;WFD start 6/14/1994
	JRZ	OKE_NEXT			;BR = NO GUN VECTOR
;WFD end 6/14/1994
	MMTM	SP,A0,A1,A2,A3,A4,A5,A6,A7,A8,A9,A10,A11
	CALL	A14				;CALL GUN VECTOR
	MMFM	SP,A0,A1,A2,A3,A4,A5,A6,A7,A8,A9,A10,A11
OKE_NEXT
	CALL	A7
	CMP	A0,A8
	JRNE	OKE_LUPE			;BR=NOT END OF LIST
OKE_DONE
	PULLQ	A8
	RETS

OKE_BEHIND_CHECK
	MOVE	*A8,A8,L			;NEXT FARTHER OBJECT
	RETS

OKE_INFRONT_CHECK
	MOVE	*A8(OBLINK),A8,L		;NEXT CLOSER OBJECT
	RETS

	.END
