 	.MLIB	"GXMACS.LIB"
 	.FILE	"GXUNILNK.ASM"
	.TITLE	" <<< GENERATION X -- UNIVERSE LINK ROUTINES >>>"
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

	.BSS	RAMLINKS,(MAX_UNIV_OBJS*BLOCK_SIZE)
	.BSS	BGHEAD_ACTIVE,32
	.bss	UNIV_STACK,MAX_UNI*UNIV_STK_SIZ	       
	.bss	UNIV_SP,32
	.BSS	FREE_LINKS,32

	.bss	UNIVPROC,32
	.bss	UNIV_ID,16		; 0 1 2 or 3

	.bss	filler,16		; to keep long word aligned

	.TEXT
	.EVEN

	.DEF	ADD_UNIVERSE		

LEAVE_IT_IN	.set 0

A_BRANCH:
	calla	GETAFARG_LONG
	move	a0,*a8(AnimFrm),L
	move	a0,*a8(AnimScr),L
	rets

*
*	Anim func to see if portal is opening to a new univ.
*
*	IF NU_FLG == 0 then do nothing, proceed with animation.
*	IF NU_FLG == 1 then check portal state and process
*	IF NU_FLG <  0 then stay on current frame.
*
*	PORTAL STATES    0 = closed
*			 1 = closing
*			 2 = opening
*			 3 = open
*
	.if LEAVE_IT_IN==1
AU_PORTAL_OPEN_CHECK:		; START HERE when doors are open. Pull if was opening
	movk	1,a1  		; Clr DAnim bit if it was opening and is open
	movk	1,a2	  	; Mark as closing if you pull it.
	move	@NU_FLAG,a14
	jrz	PorChkX
	jrn	stick
	move	*a8(OULINK),a14,L	; link
	movb	*a14(MAP_ID+8),a3
	subk	2,a3			; was it opening?
	jrz	pullit			; pull if it's been opening
	movk	1,a2			; otherwise, mark it as closing
	movb	a2,*a14(MAP_ID+8)
	rets
*
pullit:
	movb	a2,*a14(MAP_ID+8)	; opening becomes open, closing becomes closed
	move	*a8(AnimFrm),a0,L
	or	a1,a0	  		; set ANIM and possibly DANIM
	move	a0,*a14(MAP_IMG),L
	calla	PULL_ANIM
PorChkX:
	rets

stick:
	move	*a8(AnimFrm),a0,L
	subi	50h,a0
	move	a0,*a8(AnimFrm),L
	rets

AU_PORTAL_CLOSE_CHECK:		; START HERE when doors are open
	movk	3,a1		; Set DAnim bit if it was closing and is closed
	movk	2,a2		; Mark as opening if you pull it
	move	@NU_FLAG,a14
	jrz	PorChkX
	jrn	stick
	move	*a8(OULINK),a14,L	; link
	movb	*a14(MAP_ID+8),a3	; if closing, pull it
	subk	1,a3			; was it closing?
	jrz	pullit			; pull if it's been closing
	movk	2,a2			; otherwise, mark it as opening
	movb	a2,*a14(MAP_ID+8)
goon:
	rets


	.else
****>>>
*
*   WHEN A PORTAL IS ENTERED, IT OPENS and  THE DANIM FLAG GETS CLEARED
*   THE OBJECT WILL GET DELETED IN THIS STATE.  WHEN WE RETURN TO THE
*   UNIVERSE THE PORTAL OBJECT WILL GET RECREATED WITH ITS DANIM OFF SO
*   THE ANIMATION WILL BEGIN IMMEDIATELY.  IN THIS CASE (DANIM off AND
*   PORTAL on), UPDATE_UNIV WILL START THE ANIMATION AT THE PROPER PLACE.
*   (i.e. closing)
*
*   In other words,  when a universe object is created by UPDATE_UNIV,
*   IF it is a PORTAL and the DANIM bit is OFF, then the script is started
*   at an offset which is found in the lower 16 bits of MAP_SPAREL1.
*
*   I have deemed this technique better than rewriting MAP_IMG with a
*   new script start
*
*
****>>>

********************************************************
*
*	This simply marks the portal as opening or closing 
*
AU_PORTAL_START:
	move	*a8(OULINK),a5,L
	movb	*a5(MAP_ID+8),a3   
	xori	2,a3
	movb	a3,*a5(MAP_ID+8)	; from closed to opening or open to closing
	rets	


********************************************************
*
*	This marks the portal as open and sets the offset of the animation
*	sequence for when the portal gets recreated
*
AU_PORTAL_SET_OPEN:
	move	*a8(OULINK),a1,L
	move	*a1(MAP_X),a14,L
	sra	14,a14			; save 2 bits of fraction
	move	a14,*a1(MAP_SPAREL1+10h),W	; for sliding portals
	move	*a8(OXVAL),*a1(MAP_X),L	 
	move	*a8(AnimFrm),a2,L
	move	*a8(AnimScr),a3,L
	sub	a3,a2
	move	a2,*a1(MAP_SPAREL1),W	; store offset from frame
	MOVKB 	3,*a1(MAP_ID+8)		; mark as open
	jauc	PULL_ANIM		; DANIM bit is clear so it automatically
					; starts when universe is exited

********************************************************
*
*	This marks the portal as closed and sets the offset of the animation
*	sequence for when the portal gets recreated
*
AU_CHANGE_PAL_SET_CLOSED:
	calla	GETAFARG_LONG
	calla	CHANGE_PAL
AU_PORTAL_SET_CLOSED:
	move	*a8(OULINK),a1,L
	clr	a14
	movb	a14,*a1(MAP_ID+8)	; mark as closed
	move	*a1(MAP_SPAREL1+10h),a14,W	; for sliding portals
	sll	14,a14			; restore 2 bits of fraction
	move	a14,*a8(OXVAL),L	; for sliding portals
	move	a14,*a1(MAP_X),L	; for sliding portals
	move	*a1(MAP_IMG),a2,W
	ori	M_IF_DANIM,a2
	move	a2,*a1(MAP_IMG),W	; just need to operate on word to change flag
	jauc	PULL_ANIM		; DANIM bit is set so it doesn't automatically
					; start if it scrolls off and back on.


	.endif



**************************************************************************
*								         *
* AU_CHANGE_MAP_IMG							 *
*								         *
**************************************************************************
AU_CHANGE_MAP_IMG:
	calla	GETAFARG_LONG		; new sequence or image pointer in a0
	move	*a8(OULINK),a14,L	; link
	move	a0,*a14(MAP_IMG),L
	jauc	PULL_ANIM


AU_ELEV_OPEN:
	calla	GETAFARG_LONG		; new sequence or image pointer in a0
	move	*a8(OULINK),a14,L	; link
	move	a0,*a14(MAP_IMG),L
  
	move	*a14(MAP_X),a1,L	; 
	sra	14,a1			; save 1st bit of fraction
	move	a1,*a14(MAP_SPAREL1+10h),W	; for elevator
	move	*a8(OXVAL),*a14(MAP_X),L  

	jauc	PULL_ANIM


AU_ELEV_CLOSED:
	calla	GETAFARG_LONG		; new sequence or image pointer in a0
	move	*a8(OULINK),a14,L	; link
	move	a0,*a14(MAP_IMG),L
  
	move	*a14(MAP_SPAREL1+10h),a1,W	; for elevator
	sll	14,a1			; restore 1st bit of fraction
	move	a1,*a8(OXVAL),L		; for elevator
	move	a1,*a14(MAP_X),L	; for elevator

	jauc	PULL_ANIM


********************************************************************
*								   *
*	             LINKED LIST ROUTINES                          *
*								   *
********************************************************************


INIT_LINKED_LIST:
	movi	MAX_UNIV_OBJS,a3	; number of free links to create
	clr	a4			; prev
	movi	RAMLINKS,a0		; curr
	move	a0,a1			; almost next	
iniloop:
	addi	BLOCK_SIZE,a1		; next
	move	a1,*a0(MAP_NEXT),L
	move	a4,*a0(MAP_PREV),L
	move	a0,a4			; curr becomes prev
	move	a1,a0			; next becomes curr
	dsjs	a3,iniloop
;
;	Free list is now linked.  Set the free list header.
;
	movi	RAMLINKS,a3	   
	move	a3,@FREE_LINKS,L
	move	a4,*a3(MAP_PREV),L	; make adjustments to last and first
	move	a3,*a4(MAP_NEXT),L	; so list is circular

	rets
	
********************************************************
*
*	a8 = pointer to first obj entry in ROM table
*	a9 = number of objects
*	a10 = Z offset (lo res)
*	a11 = Y offset
*
*	Use to add a universe to an existing set of BG BLOCKS
ADD_UNIVERSE:	
	move	@BGHEAD_ACTIVE,a1,L	; first dummy link
	move	*a1(MAP_PREV),a0,L	; last dummy link
	move	*a0(MAP_PREV),a1,L	; where to start inserting
	move	@UNIV_ID,a4
	jruc	add_uni_hk


********************************************************
*
*	a8 = pointer to first obj entry in ROM table
*	a9 = number of objects
*	a10 = Z offset (lo res)
*	a11 = Y offset
*
CREATE_UNIVERSE:	
;
;	Create active universe list
;
;	a14 is the pointer to the Z sorted universe list.
;	The list must always contain a dummy object at start and end.
;	First dummy object:   MAP_OBJ = 0
;                             MAP_Z = 80000000h	 (most negative number)
;	Second dummy object:  MAP_OBJ = 0ffffffffh
;                             MAP_Z = 7fffffffh  (most postive number)
;
	move	@UNIV_ID,a4
	movi	BGHEAD_ACTIVE,a14
	callr	GET_FREE_LINK		; new link in a0
	LOCKON	Z
	move	a0,*a0(MAP_NEXT),L
	move	a0,*a0(MAP_PREV),L
	move	a0,*a14,L

	move	a0,a1
	callr	GET_FREE_LINK		; new one appended to original
	LOCKON	Z
	callr	APPLINK

	clr	a14
	move	a14,*a1(MAP_OBJ),L	; obj = 0 for first link
	dec	a14
	move	a14,*a0(MAP_OBJ),L	; obj = -1 for last link
	movi	80000000h,a14
	move	a14,*a1(MAP_Z),L	; most negative (1st link)
	dec	a14
	move	a14,*a0(MAP_Z),L	; most positive (last link)
	move	a4,*a1(MAP_ID)
	move	a4,*a0(MAP_ID)
*
*	transfer ROM table to RAM linked list
*
add_uni_hk:	 			;
	move	a9,a5			; original count
	srl	2,a9			; create in 4 ticks
	move	a9,a3			
	sll	2,a3			; (( orig>>2 ) <<2 )
	sub	a3,a5			; add remainder into 1st loop
	add	a9,a5			; a5 is local loop count
CrUni1:
	move	@UNIV_ID,a4
	movi	80000000h,a2		; stuff all objs with this
CrUni0:
	callr	GET_FREE_LINK		; new link in a0
	LOCKON	Z
	move	*a1(MAP_NEXT),a14,L	; START APPLINK
	move	a0,*a1(MAP_NEXT),L	
	move	a14,*a0(MAP_NEXT),L
	move	a0,*a14(MAP_PREV),L
	move	a1,*a0(MAP_PREV),L	; END APPLINK
	move	a0,a1			; save for next APPLINK
	move	a2,*a0(MAP_OBJ),L
	move	a4,*a0(MAP_ID)		; JUST universe ID, DAMAGE LEVEL IS ZERO
	move	*a8+,*a0+,L		; xfer IMG,X,Y,Z & flags
	move	*a8+,*a0+,L
	move	*a8+,a14,L
	sub	a11,a14			; adjust Y (for prev univ)
	move	a14,*a0+,L
	move	*a8+,a14,L
	add	a10,a14			; adjust Z (for prev univ)
	move	a14,*a0+,L
	move	*a8+,*a0+
	dsj	a5,CrUni0	

	mmtm	a12,a1,a3
	sleep	1
	mmfm	a12,a1,a3
	move	a9,a5
	sub	a9,a3
	jrnz	CrUni1

	RETP	


********************************************************
*
*	a0 = new link (0 if error)
*	b0,b1,b14 trashed
*
GET_FREE_LINK:
	move	@FREE_LINKS,a0,L
	move	a0,b0
	move	*b0(MAP_NEXT),b14,L
	cmp	b14,b0
	jreq	nofree
	move	*b0(MAP_PREV),b1,L
	move	b1,*b14(MAP_PREV),L
	move	b14,*b1(MAP_NEXT),L
	move	b14,@FREE_LINKS,L
	rets

nofree:
	clr	a0
	rets


********************************************************
*
*	UNLINK_LINK
*
*	General Purpose routine to remove a UNIV RAM LINK.
*	THIS ROUTINE DOES NOT PLACE THE LINK ON THE FREE LIST!
*
*	a0 = link to remove from its neighbors
*	trashes b0, b1 and b14
*
UNLINK_LINK:
	move	a0,b0
	move	*b0(MAP_NEXT),b14,L
	move	*b0(MAP_PREV),b1,L
	move	b1,*b14(MAP_PREV),L
	move	b14,*b1(MAP_NEXT),L
	rets	


************************************************************
*      Take a universe obj and remove its connection to
*                 the universe, making it a regular object
*
*	a8 = OBJECT BLOCK
*
BG_TO_FG:
	MOVE	*A8(OULINK),A0,L
	jrz	already_fg
	CLR	A14
	MOVE	A14,*A8(OULINK),L

********************************************************
*
*	a0 = link to return to Free Universe Link list
*

REMOVE_AND_FREE_LINK:

	.if	DEBUG
	MOVE	*A0(MAP_OBJ),A14,L
	JRN	RAFL_NO_OBJ		;BR=NO OBJECT ALLOCATED
	SRL	4,A14
	SLL	4,A14
	MOVE	*A14(OULINK),A14,L	;THE LINK SHOULD BE ZERO
	LOCKON	NZ
	.endif
RAFL_NO_OBJ:


	callr	UNLINK_LINK		
	move	@RAMREF0,a14,L		; are we removing RAMREF0?
	cmp	a0,a14
	jrne	noadj0
	move	*a0(MAP_NEXT),a14,L	; if so, point to next one
	move	a14,@RAMREF0,L
noadj0:
	move	@RAMREF1,a14,L		; are we removing RAMREF1?
	cmp	a0,a14
	jrne	RETURN_TO_FREE
	move	*a0(MAP_NEXT),a14,L	; if so, point to next one

	move	a14,@RAMREF1,L		; FALL THROUGH TO RETURN_TO_FREE

********************************************************
*
*	a0 = Universe link to return to list of free universe links
*	trashes a14
*	
RETURN_TO_FREE:
	PUSH	a1
;WFD start 5/23/1994
	CLR	A14
	NOT	A14
;	MOVI	-1,A14
	MOVE	A14,*A0(MAP_IMG),L	;FLAG ON FREE LIST	
;WFD end 5/23/1994
	move	@FREE_LINKS,a1,L
	callr	INSLINK			;
	move	a0,@FREE_LINKS,L
	PULLQ	a1
already_fg: 
	rets


********************************************************
*
*	a0 = universe link to be inserted into current universe list
*	trashes a1,b0,b1,b4,b5,b14,a14
*
INSERT_LINK:
	move	a0,b0
	move	@BGHEAD_ACTIVE,b1,L
	move	b1,b14
	move	*b0(MAP_Z),b4,L		; Z of new block

illoop:
	move	*b1(MAP_Z),b5,L		; Z of next block
	cmp	b5,b4
	jrlt	found_insert	
	move	*b1(MAP_NEXT),b1,L
	cmp	b1,b14			; have we looped to beginning?
	jrne	illoop			; (This should never happen)

found_insert:
	move	b1,a1
	callr	INSLINK			; new link goes before current.
;WHY?	move	*a0(MAP_PREV),a5,L
	
	move	@RAMREF0,b5,L
	cmp	b1,b5
	jrne	noupd0
	move	b0,@RAMREF0,L		; RAMREF0 becomes new one
noupd0:
	rets


*
*	a0 = link to insert
*	a1 = link to insert in front of
*	trashes a14
INSLINK:
	move	*a1(MAP_PREV),a14,L
	move	a0,*a1(MAP_PREV),L
	move	a14,*a0(MAP_PREV),L
	move	a0,*a14(MAP_NEXT),L
	move	a1,*a0(MAP_NEXT),L
	rets

*
*	a0 = link to insert
*	a1 = link to insert after
*	trashes a14
*
APPLINK:
	move	*a1(MAP_NEXT),a14,L
	move	a0,*a1(MAP_NEXT),L
	move	a14,*a0(MAP_NEXT),L
	move	a0,*a14(MAP_PREV),L
	move	a1,*a0(MAP_PREV),L
	rets


********************************************************
*
* This routine deletes all objects associated with universe links.
*	
*	It will not retain hit count in MAP_OBJ
*
RMV_OBJS_FROM_UNIVERSE:
	mmtm	sp,a0,a1,a2
	movi	80000000h,a1
	move	@BGHEAD_ACTIVE,a2,L
chknxt:
	move	*a2(MAP_NEXT),a2,L
	move	*a2(MAP_OBJ),a0,L
	jrz	endolist
	jrn	chknxt
	srl	4,a0
	sll	4,a0
	calla	ZAPOBJ
	move	a1,*a2(MAP_OBJ),L
	jruc	chknxt
endolist:
	mmfm	sp,a0,a1,a2		; link returned in a0
	rets



**************************************************************************
*								         *
* DELETE_UNIVERSE - DELETE ALL UNIVERSE LINKS AND OBJECTS		 *
*								         *
**************************************************************************

DELETE_UNIVERSE:
	mmtm	sp,a0,a1,a2
	movi	80000000h,a1
	move	@BGHEAD_ACTIVE,a2,L
DU_chknxt:
	move	*a2(MAP_NEXT),a2,L
	MOVE	A2,A0
	CALLR	REMOVE_AND_FREE_LINK
	move	*a2(MAP_OBJ),a0,L
	jrz	DU_endolist
	jrn	DU_chknxt
	srl	4,a0
	sll	4,a0
	calla	ZAPOBJ
	move	a1,*a2(MAP_OBJ),L
	jruc	DU_chknxt
DU_endolist:
	mmfm	sp,a0,a1,a2		; link returned in a0
	rets



*
*	Returns number of Links which make up the universe in a0
*	Returns number of Objects from universe links in a2
*
GET_UNIVERSE_SIZE:
	move	@BGHEAD_ACTIVE,a14,L
	clr	a0
	clr	a2
	move	a14,a1
grslp:
	move	*a1(MAP_NEXT),a1,L
	inc	a0
	move	*a1(MAP_OBJ),a3,L
	jrz	noobj
	jrn	noobj
	inc	a2
noobj:
	cmp	a1,a14
	jrne	grslp
	subk	2,a0		; dummy head and tail
CO_ABORT:
	rets


********************************************************
*
*	a7 = link
*	return: a0 = object
*
*	THRASHES ALMOST EVERYTHING!
*
CREATE_OBJ_FROM_LINK:
	MOVE	A7,B14

	ADDI	MAP_X,B14

	MMFM	B14,B0,B1,B2				;B2 = X WORLD
							;B1 = Y WORLD
;	MOVE	@ZBASE,B3,L
;	SUB	B3,B0					;B0 = Z WORLD

	MOVE	*A7(MAP_OBJ),A1,L		;GET CURRENT LIST FLAGS
	LOCKON	NN

	CALLA	GETOBJ
	JRZ	CO_ABORT			;BR=NO OBJECT BLOCK AVAILABLE
	MOVE	A0,A11

	CALLA	CLRODATA

	MOVE	A0,*A7(MAP_OBJ),L		;PUT IN LIST

	MOVE	*A7(MAP_IMG),A1,L			;A1  - OIMG/ANIM SCRIPT

;WFD start 5/23/1994
	JRZ	CO_BOGUS			;BR=BOGUS IMG
	JRNN	CO_GO				;BR=VALID IMG
CO_BOGUS
	CLR	A0				;BOGUS IMG
	RETS
CO_GO
;WFD end 5/23/1994

	MOVE	*A7(MAP_FLAGS),A3,W		;GET BLOCK FLAGS

	MOVE	A3,A5					;GET OID SUB-TYPE
	SLL	21,A5
	SRL	27,A5
	SLL	2,A5
	MOVE	A5,A6
	ORI	OID_UNIV,A6

	BTST	B_BF_PORTAL,a3
	jrz	CO_nxtchk			;BR=NOT A PORTAL
	movi	PORTAL_GUNVECT,a14
	jruc	CO_SETVECT
CO_nxtchk:
	BTST	B_BF_NOVECT,A3				;TEST NOVECTOR FLAG
	JRNZ	CO_NOVECT

	SLL	4,A5					;GET OFFSET INTO TABLE
	JRNZ	CO_GETVECT				;BR=GET TABLE VECTOR
CO_DUMVECT
	ANDNI	MASK_SUPP,A6		;CLEAR SUPP LIST
					; TO REDUCE TIME DURING COLLISION CHECK
	MOVI	DUMRETS,A14				;SET DUM GUN VECTOR
	JRUC	CO_SETVECT
CO_GETVECT
	MOVE	@WVT_PTR,A14,L
	ADD	A5,A14					;SET TABLE ADDRESS
	MOVE	*A14+,A5,L				;GET COLLISION VECTOR
	JRZ	CO_DUMVECT				;BR=DUM VECTOR
	MOVE	A5,*A0(OCVECT),L			;SET OCVECT
	MOVE	*A14,A14,L				;GET GUN VECTOR
CO_SETVECT
	MOVE	A14,*A0(OGUNVECT),L			;SET OGUNVECT
CO_NOVECT
	MOVE	A6,*A0(OID),W				;SET OID

	MOVE	A3,A5
	SLL	31,A5					;ANDI M_NOSCALE,A5
	SRL	31,A5
	ORI	M_OFSCRN,A5			;ADD DEFAULT FLAGS
	MOVE	A5,*A0(OFLAGS),W

	MOVE	A1,A5
	SRL	4,A1
	SLL	4,A1

	BTST	B_IF_DAM,A5
	JRZ	CO_NO_DAM			;BR=NO DAMAGE TABLE
*
*	HANDLE DAMAGE
*
	MOVE	*A1,A1,L			;GET FRAME OF DAMAGE SEQUENCE
	ANDI	M_IF_DANIM,A5
	OR	A1,A5
	SRL	4,A1
	SLL	4,A1
CO_NO_DAM
	BTST	B_BF_ENEMY,A3
	JRZ	CO_NOENEMY			;BR=NOT AN ENEMY GENERATOR
*
* 	HANDLE ENEMY
*
CO_ENEMY
	MOVE	A1,*A0(OENEMYANIM),L		;SAVE FOR LATER
	MOVE	@ENEMYDATA,A14,L
	MOVE	A0,*A14+,L			;STUFF ADDRESS
	MOVE	A14,B5				;SAVE FOR NEXT GUY
	JRUC	CO_GET_IMG
CO_NOENEMY
	BTST	B_IF_SEQ,A5
	JRZ	CO_NO_ANIM			;BR=AN IMG	
CO_ANIM
	BTST	B_IF_DANIM,A5
	JRNZ	CO_GET_IMG			;BR=SPECIAL DANIM CASE

	btst	B_BF_PORTAL,a3
	jrz	UV_SKP_FRMADJ
	move	a1,a14				; move script start to a14
	move	*a7(MAP_SPAREL1),a1,W		; delta
	add	a14,a1				; frame start in a1
	calla	STRTANIM_OFF
	jruc	CO_NORM_ANIM
UV_SKP_FRMADJ:

	CALLA	STRTANIM
CO_NORM_ANIM
	MOVE	@WAVEDISPS,A14,W		;SYNC ANIMS
	ANDI	15,A14				;MASK OUT LOW 4 BITS
	SUBK	16,A14				;GET TIME TIL NEXT 16TH COUNT
	NEG	A14
	MOVB	A14,*A0(AnimSlp)		
CO_GET_IMG
	MOVE	*A1,A1,L				;A1  - OIMG
CO_NO_ANIM
	MOVE	*A1(ICMAP),A0,L
	CALLA	GETFPAL
	JRNZ	CO_PAL_AVAIL			;BR=PALETTE NOT D'ARE
;	LOCKON
	CLR	A0
	MOVE	A0,A5
	CALLA	INC_PALCNT
CO_PAL_AVAIL
	MOVE	A0,A4					;A4  - OCONST|OPAL
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
	
	ANDI	M_FLIPV|M_FLIPH,A3		;MASK OUT NON-DMA FLAGS
	ADD	A3,A10				;ADD TO ICTRL
	ADDI	DMAWNZ,A10			;ADD DEFAULT PIXOP AND GO 
	SLL	16,A10					;A10 - OCTRL|OFSET

	MOVE	A11,*A0(OUANIOFF),L			;A11 - OANIOFF

	MOVI	01000100H,A3				;A3  - OSCALE
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
	MOVE	B5,@ENEMYDATA,L
	JAUC	INSOBJ

********************************************************
*
*	PushUniverse
*
*	When portaling into another universe, PushUniverse will save
*	all pertinent info about the current universe on the universe stack.
*	(It also increments UNIV_ID which gets stored with each link).
*
*	a5 = Y pos of portal zoom point
*       a6 = X pos of portal zoom point
*	a11 = SCROLL TABLE containing
*
* 	UNIV_SP -> a0	   +0	BGHEAD (ptr to RAMLIST)
*			  +20	YBASE  (to return to when exiting portal)
*			  +40	XBASE  (ditto)
*			  +60	YWORLD
*			  +80	ZBASE_HR  (ditto)
*                         +a0   Z of portal
*			  +c0	YHALF
*			  +e0	ZFAR
*			 +100	SKYCOLOR
*			 +110	GRNDCOLOR
*			 +120	X of portal   (point to zoom in on)
*			 +140	Y of portal   (point to zoom in on)
*			 +160	XSACCEL
*			 +180	YSACCEL
*			 +1a0	ZSACCEL
*			 +1c0	XSCROLL
*			 +1e0	YSCROLL
*			 +200	ZSCROLL
*			 +220	YREL_OFF
*			 +240	ZREL_OFF
*
PushUniverse:
	move	@UNIV_ID,a14
	inc	a14
	cmpk	MAX_UNI,a14	; can't have a UNIV ID of 5 (too big)
	jrge	NoCanDo		; 
	move	a14,@UNIV_ID

	move	@UNIV_SP,a0,L

	MOVE	@ZREL_OFF,A1,L
	MOVE	@YREL_OFF,A2,L

	movi	XSCROLL,a4
	mmfm	a4,a3,a7,a8
	mmtm	a0,A1,A2,a3,a7,a8

	movi	XSACCEL,a4
	mmfm	a4,a1,a2,a3
	mmtm	a0,a1,a2,a3,a5,a6

	move	@SKYCOLOR,a1
	move	@GROUNDCOLOR,a2
	sll	16,a2
	movx	a1,a2
	move	@ZFAR,a3,L
	move	@YHALF,a4
	mmtm	a0,a2,a3,a4

	move	@ZBASE_HR,a1,L
	move	@YWORLD,a2,L
	move	@XBASE,a3,L
	move	@YBASE,a4,L
	move	@BGHEAD_ACTIVE,a5,L
	mmtm	a0,a1,a2,a3,a4,a5

	

	subk	20h,a0			; placeholder for ZPORTAL
	move	a0,@UNIV_SP,L
	clrc
	rets

NoCanDo:
	setc		; can't
	rets

	.END
