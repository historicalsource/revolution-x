	.MLIB	"GXMACS.LIB"
	.FILE	"GXCOLL.ASM"
	.TITLE	"<<< GENERATION X - SUPPLEMENTAL LIST COLLISIONS >>>"
	.WIDTH	132
	.OPTION	B,D,L,T
	.MNOLIST

**************************************************************************
*								         *
* 	COPYRIGHT (C) 1992 MIDWAY MANUFACTURING COMPANY.		 *
* 		       ALL RIGHTS RESERVED.				 *
*								         *
**************************************************************************

	.INCLUDE	"GX.INC"		;GET THE SYSTEM EQUATES

***** from GXD.ASM
	.REF	WORLD_GRNDOFF


	.BSS	GRNDOBJ,OBSIZ

**************************************************************************
*								         *
* LA_COLL - ROUTINE TO START COLLISION SCANNERS FOR LA WORLD		 *
*								         *
**************************************************************************
LA_COLL
	MMTM	SP,A0,A1,A7
	CREATE	PID_IND,LA_COLLPROC		;COLLISIONS FOR LA WORLD
	MMFM	SP,A0,A1,A7
	RETS
	
**************************************************************************
*								         *
* PRESENT_COLL - ROUTINE TO START COLLISION SCANNERS FOR PRESENT WORLD	 *
*								         *
**************************************************************************
PRESENT_COLL
	MMTM	SP,A0,A1,A7
	CREATE	PID_IND,PRESENT_COLLPROC ;COLLISIONS FOR PRESENT WORLD
	MMFM	SP,A0,A1,A7
	RETS

**************************************************************************
*								         *
* HIGHWAY_COLL - ROUTINE TO START COLLISION SCANNERS FOR HIGHWAY WAVE	 *
*								         *
**************************************************************************
HIGHWAY_COLL
	MMTM	SP,A0,A1,A7
	CREATE	PID_IND,HIGHWAY_COLLPROC ;COLLISIONS FOR HIGHWAY
	MMFM	SP,A0,A1,A7
	RETS

****************************************************************************
* When writing collision routines which are to be called from the
* supplemental list collision scanner or the ground collision scanner,
* the following should be taken into consideration:
*    The collision routines are called, not JSRPed|created..
*    The collision routine receives a ptr to the victims OBJ in A8
*    The collision routine receives a ptr to the killers OBJ in A0
*    The collision routine can destroy A0-A11,A14 but
*        must preserve all BREGS except B14
*    When OBJ1,OBJ2 collide, two routines are called, one with
*        OBJ1 in A8 and the other with OBJ2 in A8.  A collision routine
*        should only affect the victim, and not the killer.
*    To make sure an object isn't rescanned do any of the following:
*       DELETE it, change OID or clear OCVECT.
*    If any other object is deleted, the collision scan will be aborted.
*    To prevent multiple simultaneous collisions of the same victim
*       object, the object ID of the victim object should be modified
*       by the collision routine, if the victims nature is changed,
*	such as an enemy obj to be changed into an explosion.
****************************************************************************

****************************************************************************
* LA_COLLPROC
*
* PROCESS TO CALL SUPPCOLL WITH EACH OF THE LISTS TO BE COLLIDED
*	 		LA WORLD
LA_COLLPROC:
	movi	SUPPLSTS+1*020h,B1	;PLAYERS
	movi	SUPPLSTS+2*020h,B2	;ENEMIES
	callr	SUPPCOLL

	movi	SUPPLSTS+1*020h,B1	;PLAYERS
	movi	SUPPLSTS+4*020h,B2	;UNIVERSE
	callr	SUPPCOLL

	callr	GROUNDCOLL
	SLEEP	1
	callr	GROUNDCOLL
	SLEEP	1
	jruc	LA_COLLPROC

****************************************************************************
* PRESENT_COLLPROC
*
* PROCESS TO CALL SUPPCOLL WITH EACH OF THE LISTS TO BE COLLIDED
*	 		PRESENT WORLD
PRESENT_COLLPROC:
	movi	SUPPLSTS+1*020h,B1	;PLAYERS
	movi	SUPPLSTS+2*020h,B2	;ENEMIES
	callr	SUPPCOLL

	movi	SUPPLSTS+1*020h,B1	;PLAYERS
	movi	SUPPLSTS+4*020h,B2	;REBELS
	callr	SUPPCOLL

	callr	GROUNDCOLL
	SLEEP	1
	callr	GROUNDCOLL
	SLEEP	1
	jruc	PRESENT_COLLPROC

****************************************************************************
* HIGHWAY_COLLPROC
*
* PROCESS TO CALL SUPPCOLL WITH EACH OF THE LISTS TO BE COLLIDED
*	 		HIGHWAY WORLD
HIGHWAY_COLLPROC:
	movi	SUPPLSTS+1*020h,B1	;PLAYERS
	movi	SUPPLSTS+2*020h,B2	;ENEMIES
	callr	SUPPCOLL

	movi	SUPPLSTS+1*020h,B1	;PLAYERS
	movi	SUPPLSTS+4*020h,B2	;REBELS
	callr	SUPPCOLL

	movi	SUPPLSTS+4*020h,B1	;REBELS
	movi	SUPPLSTS+2*020h,B2	;ENEMIES
	callr	SUPPCOLL

	callr	GROUNDCOLL
	SLEEP	1
	callr	GROUNDCOLL
	SLEEP	1
	jruc	HIGHWAY_COLLPROC


**************************************************************************
*								         *
* GROUNDCOLL - Scan foreground objects for Ground Collisions		 *
* 	     For each obj, if GCOLL flag set check if bottom of		 *
* 	     obj is lower than height of ground at objs ZVAL		 *
* 	     OBJ must have OCVECT set and a handler for OID_GRND.	 *
* Note: Needs to be Re-written for new 3-D world			 *
*								         *
**************************************************************************
GROUNDCOLL:
	;INIT BOGUS GROUND OBJECT FOR USE WITH COLLISIONS
	movi	GRNDOBJ,B0
	movi	OID_GRND,B14
	move	B14,*B0(OID),W
	clr	B14
	move	B14,*B0(OXVEL),L
	movi	-020000h,B14		;Make it look like ground moved up
	move	B14,*B0(OYVEL),L	; into obj for collision handler
	movi	[030h,030h],B14
	move	B14,*B0(OSIZE),L

	movi	FGLIST,B9
	move	B9,B8			;B8 Head of obj list
	move	@YWORLD,B3,L		;B3 HEIGHT OF PLANE
	MOVE	@WORLD_GRNDOFF,B14,L
	ADD	B14,B3
NoGColl
	move	*B8,B8,L
	cmp	B8,B9
	jreq	GCOLLX
GCollObjLp
	movb	*B8(OFLAGS+B_GCOLL-7),B14	;Not unless requested.
	jrnn	NoGColl

	move	*B8(OYVEL+010h),B14,W		;Not if we're going up.
	jrn	NoGColl

	;HOW HIGH ARE WE?
	move	*B8(OYVAL),B4,L
	MOVE	*B8(OGRNDOFF),B14,L	;GROUND WORLD OFFSET
	ADD	B14,B4
	cmp	B3,B4
	jrlt	NoGColl

	;WE HAVE A GROUND COLLSION
	move	B8,A8		;obj 1 VICTIM
	move	*A8(OCVECT),A1,L ;A1 - OCVECT FOR FALLING OBJ
	jrz	NoGColl
	move	B0,A0		;obj 2 KILLER
	move	*B8,B8,L	;get next obj in case current one gets deleted

	callr	DoColl

	cmp	B8,B9		;DID WE HIT THE END OF THE LIST
	jreq	GCOLLX		;BR = YES
	;CHECK THAT THE OBJ WE WISH TO KEEP SCANNING WITH IS VALID	
	movb	*B8(OCTRL+B_INUSE-7),B14
	jrn	GCollObjLp		;BR = IT'S O.K.
GCOLLX
	rets



****************************************************************************
* SUPPCOLL
* Collide two supplemental lists against each other
* For each object of supplemental list 1, scan against each obj of supp 2
* Eliminate collision if
*   Either obj has NOCOLL bit set
*   OPLANE fields don't match
*   LR of OBJ1 < TL of OBJ2
*   TL of OBJ1 > LR of OBJ2
* B1 ptr to supplemental list 1
* B2 ptr to supplemental list 2
SUPPCOLL:
	subi	OSLINK,B1
	subi	OSLINK,B2
	move	B2,B3

List1Lp
	move	B3,B2
	move	*B1(OSLINK),B1,L
	jrz	SupCollX
	movb	*B1(OFLAGS+B_NOCOLL-7),B14
	jrn	List1Lp
	move	*B1(OCVECT),B8,L	;B8 - OCVECT FOR OBJ 1
	jrz	List1Lp

	MOVE	*B1(OZVAL),B4,L
	MOVE	B4,B9
	MOVE	*B1(OZDEPTH),B14,L
;	MOVE	*B1(OZREAR),B14,W
;	MOVE	*B1(OZFRNT),B5,W
	MOVE	B14,B5
	SEXT	B14,W			;OZREAR
	SRA	16,B5			;OZFRNT
	ADD	B14,B9			;REAR Z LIMIT FOR OBJ 1
	SUB	B5,B4			;FRONT Z LIMIT FOR OBJ 1

	MOVE	*B1(ODAG),B5,L		;B5 - OBJ 1 TL

	move	*B1(OSIZE),B6,L
	addxy	B5,B6			;B6 - OBJ 1 LR

List2Lp
	move	*B2(OSLINK),B2,L
ContScan
	jrz	List1Lp
	movb	*B2(OFLAGS+B_NOCOLL-7),B14
	jrn	List2Lp
	move	*B2(OCVECT),B0,L	;B0 - OCVECT FOR OBJ 2
	jrz	List2Lp

	MOVE	*B2(OZVAL),B14,L

	MOVE	*B2(OZDEPTH),B7,L
;	MOVE	*B2(OZREAR),B7,W
;	MOVE	*B2(OZFRNT),B10,W
	MOVE	B7,B10
	SEXT	B7,W			;OZREAR

	SUB	B7,B14			;REAR Z LIMIT FOR OBJ 2
	CMP	B9,B14
	JRGT	List2Lp			;BR=NO Z COLLISION
	ADD	B7,B14
	SRA	16,B10			;OZFRNT
	ADD	B10,B14			;FRONT Z LIMIT FOR OBJ 2
	CMP	B4,B14
	JRLT	List2Lp			;BR=NO Z COLLISION

	;SKIP IF OBJ 2 TL > OBJ 1 LR

	MOVE	*B2(ODAG),B7,L		;B7 - OBJ 2 TL

	cmpxy	B6,B7
	jrxgt	List2Lp
	jrygt	List2Lp
		      	
	;SKIP IF OBJ 2 LR < OBJ 1 TL
	move	*B2(OSIZE),B14,L
	addxy	B14,B7			;B7 - OBJ 2 LR			
	cmpxy	B5,B7
	jrxlt	List2Lp
	jrylt	List2Lp
	
	;*** WE HAVE A BOX COLLISION BETWEEN B1, B2 ***
	
	MOVE	B0,A1		;obj 2's COLL VECT

	;*** PUSH INFO NECESSARY TO DETERMINE IF SCAN MUST BE STOPPED ***
	move	*B1(OID),B7,W
	move	*B2(OSLINK),B0,L
	move	*B0(OID),B10,W

	;*** PROCESS COLL FOR OBJ 2 ***
	move	B1,A0		;obj 1 KILLER
	move	B2,A8		;obj 2 VICTIM
	callr	DoColl
	;*** PROCESS COLL FOR OBJ 1 ***
	move	B1,A8		;obj 1 VICTIM
	move	B2,A0		;obj 2 KILLER
	move	B8,A1		;obj 1's COLL VECT
	callr	DoColl

	;*** DO WE HAVE TO ABORT THE SCAN? ***
	; HAS OBJ 1 BEEN DELETED, OID CHANGED?
	movb	*B1(OCTRL+B_INUSE-7),B14
	jrnn	SupCollX			;OBJ 1 DELETED?
	move	*B1(OID),B14,W
	cmp	B14,B7				
	jrne	SupCollX			;OID CHANGED?
	move	*B1(OCVECT),B8,L
	jrz	SupCollX			;OCVECT CLEARED?
	movb	*B1(OFLAGS+B_NOCOLL-7),B14
	jrn	SupCollX
	
	; HAS OBJ AFTER OBJ 2 BEEN DELETED, OID CHANGED?
	movb	*B0(OCTRL+B_INUSE-7),B14
	jrnn	SupCollX			;NEXT OBJ 2 DELETED?
	move	*B0(OID),B14,W
	cmp	B10,B14
	jrne	SupCollX			;NEXT OBJ 2 OID CHANGED?
	movb	*B0(OFLAGS+B_NOCOLL-7),B14
	jrn	SupCollX
	move	B0,B2
	jruc	ContScan

SupCollX
	rets


****************************************************************************
* DoColl
* PROCESS COLLISION VECTOR
* COLLISION VECTOR HAS FOLLOWING FORMAT
*   .word   PATTERN, [MASK]	;IF PATTERN ZERO, NO MASK, JUST CALL FUNC
*   .long   FUNC		; MASK ANDED W/ PATTERN AND OID OF KILLER
*  				; FUNC CALLED IF MATCH
* A0 - KILLER
* A8 - VICTIM
* A1 - COLL VECT
CkNxtCol
	addk	32,A1		;Skip FUNC, try next vector
DoColl:;***** MAIN ENTRY POINT OF FUNCTION *****
	move	*A1+,A3,W	;PATTERN?
	jrz	DoColFnc
	move	*A1+,A14,W	;MASK
	move	*A0(OID),A2,W
	and	A14,A2
	and	A14,A3
	cmp	A2,A3
	jrne	CkNxtCol
DoColFnc
	move	*A1,A1,L
	JUMP	A1		;EXECUTE THE COLLISION!
				;  will RETS back to scanner..
