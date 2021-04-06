 	.MLIB	"GXMACS.LIB"
	.FILE	"GXENEMY.ASM"
	.TITLE	" <<< GENERATION X ---- ENEMY UTILITY ROUTINES >>>"
	.WIDTH	132    
	.OPTION	B,D,L
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
	.INCLUDE	"BGNDTBL.GLO"
	.INCLUDE	"GXENEMY.TBL"

***** Symbols in this file

	.DEF	A_ONETIME, GUN_FLASH_MULTI, PROC_SBOMB, PROC_SUPERGUN
	.DEF	EF1AST08, EFLASH_ANIM, EFLASH_SHORT_INIT

*SYMBOLS IN GXRAM.ASM
	.REF	ENEMY_COUNTS, DISPATCH_TABLE, BONUS_WAVE
	.REF	ENEMIES_LEFT, HOLD_ENEMY_DISPATCH
	.REF	ENEMIES_TOTAL, ENEMIES_P1, ENEMIES_P2, ENEMIES_P3
*SYMBOLS IN GX.ASM
	.REF	INC_PLAYER_TIMERS, WAVE_END
*SYMBOLS IN GXATT.ASM
	.REF	C_POSITION
*SYMBOLS IN GXPLAYER.ASM	
	.REF	A_CK_FLSH_HIT	
**** from GXBGFX.ASM
	.REF	PACK_SUPERGUN, PACK_LAZER, PACK_SHIELD

	.TEXT

**************************************************************************
*								         *
* CREATE_ENEMY - Routine to Create an ENEMY object.  Enemy init table	 *
* 		must be setup for a MULTI-PART object.			 *
* Returns:								 *
* 	 Z								 *
* 	   Create failed, A8 = 0					 *
* 	NZ								 *
* 	   Create successful, A8 = ptr to Head Object			 *
*								         *
**************************************************************************
CREATE_ENEMY
	CALLA	MULTIMAKE	;Fire up the object
	JRZ	CE_X		;BR = No object created
	PUSH	A8
CE_Clr_Loop
	CALLA	CLR_ODATA
	MOVE	*A8(OPARTS),A8,L
	JRNZ	CE_Clr_Loop
	PULLQ	A8	;***MUST USE PULLQ*** It sets the status for A8
CE_X
	RETS

**************************************************************************
*								         *
* INSERT_ENEMY - ROUTINE TO INSERT AN ENEMY OBJECT FOR THE FIRST	 *
* 		TIME. IT INCREMENTS THE PROPER COUNTERS AND JUNK.	 *
* 	NOTE - CALL THIS ONLY ONCE PER ENEMY OBJECT CREATED.		 *
* A8 = PTR TO ENEMY OBJECT TO INSERT					 *
*								         *
**************************************************************************
INSERT_ENEMY
	CALLR	INC_ENEMY_COUNT
	JAUC	INSERT_OBJ

**************************************************************************
*								         *
* DELETE_ENEMY - ROUTINE TO DELETE AN ENEMY.				 *
* 		RELEVANT STUFF IS HANDLED HERE.				 *
* A8 = PTR TO ENEMY TO DELETE						 *
*								         *
**************************************************************************
DELETE_ENEMY
	CALLA	COUNT_KILL
*
*ENTRY POINT TO DELETE AN ENEMY WITH NO KILL AUDITING
*USED FOR ENEMY CONTEXT SWITCHING.
DEL_ENEMY_NOAUD
	CALLA	DEC_ENEMY_COUNT
	CALLA	OBJPROC_KILL		;KILL ASSOCIATED PROCESS IF IT EXISTS
	CALLA	DELETE_OBJ
	RETS


EGFLASH_INIT
	.LONG	EF1AST08
	.word	DMAWNZ,M_DEAD,OM_ANIM
	.LONG	EGFLASH_ANIM

EGFLASH_ANIM
	LWLL	EF1AST08,1|AFunc,A_CK_FLSH_HIT+2,[1,0]
;	LW	EF1AST02,1
	LW	EF1AST04,1
;	LW	EF1AST06,1
	LW	EF1AST14,1
	LW	EF1AST04,1
;	LW	EF1AST12,1
;	LW	EF1AST15,1
	LWLL	EF1AST12,1|AFunc,A_Anim_DSJ+2,EGFLASH_ANIM
	LWL	1,1|AFunc,A_UNLINK_GFLASH

	
A_UNLINK_GFLASH:
	move	*a8(ODATA+40h),a0,L	; object of creator
	LOCKON	N
	clr	a14
	move	a14,*a0(ODATA+40h),L	; tell creator: flash is gone
	move	a14,*a8(ODATA+40h),L 
	jauc	DELETE_OBJ

**************************************************************************
*								         *
* EGUN_FLASH - ROUTINE TO CREATE A GENERIC ENEMY GUN FLASH. PLANE WILL	 *
* 		DETERMINE SIZE.						 *
* A4 = [Y,X] FIRING OFFSET.						 *
* a5 = iterations of gun flashing
* A8 = PTR TO OBJECT							 *
*								         *
* NOTE! This uses ODATA+40h to cross link flash with creator object!     *
*								         *
**************************************************************************
EGUN_FLASH
	MOVI	EGFLASH_INIT,b0
	CALLA	EASYMAKE
	JRZ	EGF_X	  			;NO OBJECTS AVAILABLE

	movb	a5,*a0(AnimLoop)
	move	a8,*a0(ODATA+40h),L	; link flash with creator
	move	a0,*a8(ODATA+40h),L	; link flash with creator
	move	a4,a3
	zext	a3
	sra	16,a4
	MOVE	*A8(OCTRL),A7,W	     	;ADJUST FIRING OFFSET IF NECESSARY
	BTST	B_FLIPH,A7
	JRZ	EGF_CHECKV
	NEG	A3
EGF_CHECKV
	BTST	B_FLIPV,A7
	JRZ	EGF_NOV				;BR=NO FLIP ADJUSTMENT			
	NEG	A4
EGF_NOV
	MOVE	*A8(OXVAL),A1,L
	sll	15,a3
	add	a3,a1
	move	a1,*a0(OXVAL),L

	MOVE	*A8(OYVAL),A2,L
	sll	15,a4
	add	a4,a2
	move	a2,*a0(OYVAL),L

	MOVE	*A8(OZVAL),A3,L
	dec	a3
	move	a3,*a0(OZVAL),L

	CALLA	INSOBJ
EGF_X:
	RETS


**************************************************************************
*								         *
* 	GUN_FLASH_MULTI							 *
* 									 *
* 	Create a Gun flash as part of a Multi-part object.		 *
* 									 *
* 	A3 = [Y,X] Screen firing offset					 *
* 	A8 = Ptr to object firing					 *
* 	B0 = Init table of gun flash					 *
* 									 *
* 	Returns:							 *
* 									 *
* 		Nothing							 *
* 									 *
* 	EGUN_FLASH_MULTI						 *
* 									 *
* 	Same as the above, but uses Generic gun flash image.		 *
* 	So you don't need to pass B0.					 *
*								         *
**************************************************************************
GUN_FLASH_MULTI
	MMTM	SP,A0,A1,A2,A3,A5,A8
	PUSH	B0
	JRUC	EFM_MAKE_IT
*
*Entrypoint: To make use the generic enemy gun flash image.  Same as
*		GUN_FLASH_MULTI except you don't need to send B0.
*
EGUN_FLASH_MULTI
	MMTM	SP,A0,A1,A2,A3,A5,A8
	PUSH	B0
	MOVI	EFLASH_INIT,B0
EFM_MAKE_IT
	CALLA	EASYMAKE
	JRZ	EFM_X			;BR = Creation failed, exit.

	MOVE	*A8(OCTRL),A7,W	     	;Adjust firing offset for flips
	BTST	B_FLIPH,A7
	JRZ	EFM_CHECKV		;BR = No Horiz flip adj.
	NEGX	A3
EFM_CHECKV
	BTST	B_FLIPV,A7
	JRZ	EFM_NOV			;BR = No Vert. flip adj.
	NEGY	A3
EFM_NOV
	MOVE	A3,*A0(OPARTSXY),L

	MOVE	*A8(OXVAL),A1,L
	MOVE	*A8(OYVAL),A2,L
	MOVE	*A8(OZVAL),A3,L

	MOVB	*A8(OZOFF),A5
	SUB	A5,A3	     		;This calculation will make the 
;	MOVB	*A0(OZOFF),A14		;OZOFF for the gun flash relative
	MOVK	1,A14
	NEG	A14			;(Hard code a -1 for now)
	ADD	A5,A14			;to the base ZVAL of the multi-parter.
	MOVB	A14,*A0(OZOFF)

	CALLA	SETOFFPU

	CALLA	INSPART

	MOVE	A0,A8
	MOVE	@RAND,A0,W
	ANDI	M_FLIPH|M_FLIPV,A0		;ISOLATE FLIP BITS ONLY
	MOVE	*A8(OCTRL),A14,W
	OR	A0,A14
	MOVE	A14,*A8(OCTRL),W
	MOVE	A8,A0

	CALLA	INSOBJ
EFM_X
	PULL	B0
	MMFM	SP,A0,A1,A2,A3,A5,A8
	RETS

;EFLASH_INIT
;	.LONG	EF1AST08,DUMCOLL
;	.WORD	OID_JUNK,DMAWNZ,M_DEAD|M_NOPARTANI|M_OPARTSXY,-1
;	.LONG	C_STRTANIM,EFLASH_ANIM

EFLASH_INIT
	.LONG	EF1AST08
	.word	DMAWNZ,M_DEAD|M_NOPARTANI|M_OPARTSXY,OM_ANIM
	.LONG	EFLASH_ANIM

EFLASH_SHORT_INIT
	.LONG	EF1AST04
	.word	DMAWNZ,M_DEAD|M_NOPARTANI|M_OPARTSXY,OM_ANIM
	.LONG	EFLASH_SHORT_ANIM

EFLASH_ANIM
	LW	1,1
	LW	EF1AST02,1
	LW	EF1AST04,1
	LW	EF1AST14,1
EFLASH_SHORT_ANIM
	LW	EF1AST04,1
	LW	EF1AST12,1
	LW	EF1AST15,1
	LW	EF1AST12,1
	LWL	1,1|AFunc,DELETE_OBJ

**************************************************************************
*								         *
* A_RAND_AnimFrm - ANIM FUNC TO PICK A RANDOM ANIMATION SCRIPT OF WHICH	 *
* 		THIS OBJECT WILL ANIMATE.				 *
* A8 = PTR TO OBJECT							 *
* AARG+,W	= NUMBER OF BRANCHES					 *
* AARG+,L = PTR TO TABLE OF BRANCHES					 *
*								         *
**************************************************************************
A_RAND_AnimFrm
	CALLA	GETAFARG_WORD
	CALLA	RAND0
	MOVE	A0,A5
	CALLA	GETAFARG_LONG	
	SLL	5,A5
	ADD	A0,A5
	MOVE	*A5(0),*A8(AnimFrm),L
	RETS

**************************************************************************
*								         *
* COUNT_KILL - ROUTINE TO COUNT AN ENEMY KILL. IT WILL SET THE GLOBAL	 *
* 		FLAG ENEMY_QUOTA.					 *
* A8 = PTR TO ENEMY OBJECT WE ARE COUNTING				 *
*								         *
**************************************************************************
COUNT_KILL
	MMTM	SP,A0,A4
	MOVI	ENEMIES_LEFT,A4
	MOVE	*A8(OID),A0,W
	CALLR	DEC_COUNT
	JRNZ	CK_X
	CALLR	CK_ENEMIES_LEFT
	JRNZ	CK_X
	MOVKM	1,@ENEMY_QUOTA,W
CK_X
	MMFM	SP,A0,A4
	RETS

**************************************************************************
*								         *
* COUNT_PLAYER_KILL - ROUTINE TO ACCOUNT FOR A PLAYER KILLING AN ENEMY.	 *
* A2 = PLAYER DOING THE KILLING						 *
* A8 = PTR ENEMY WE ARE COUNTING					 *
*								         *
**************************************************************************
COUNT_PLAYER_KILL
	MOVE	A2,A2
	JRZ	CPK_XXX
	MMTM	SP,A0,A4
	CALLA	GPLAYNUM
	MOVE	A0,A4
	SLL	5,A4
	ADDI	PLAYER_KILL_TAB,A4
	MOVE	*A4,A4,L
	MOVE	*A8(OID),A0,W
	CALLR	INC_COUNT
	MMFM	SP,A0,A4
CPK_XXX
	RETS

PLAYER_KILL_TAB
	.LONG	ENEMIES_P1, ENEMIES_P2, ENEMIES_P3

**************************************************************************
*								         *
* 	LOAD_ENEMIES_LEFT						 *
* 									 *
* 	Load the number of enemies left to kill from a table.		 *
* 	If the number is greater than 5, then it is increased		 *
* 	by 50% for every player than the first one currently		 *
* 	playing.							 *
* 									 *
* 	A0 = Ptr to table						 *
* 									 *
* 	Returns:							 *
* 									 *
* 		A0 = Ptr to next					 *
*								         *
**************************************************************************
LOAD_ENEMIES_LEFT
	MMTM	SP,A1,A2,A3,A4,A6
	MOVK	N_ENEMIES,A6
	MOVI	ENEMIES_LEFT,A1

	MOVE	@CURPLYRS,A2,W		;Get our current player count
LEL_LP
	MOVE	*A0+,A3,W
	CMPK	5,A3
	JRLS	LEL_STORE		;BR = Too small to worry about
	MOVE	A2,A4			;Copy player count for decrements
	JRZ	LEL_STORE
	DEC	A4
	JRZ	LEL_STORE		;BR = One player only playing
	MOVE	A3,A14
	SRL	1,A14 			;Take 50%
LEL_LP2
	ADD	A14,A3			;Add it for this player
	DSJS	A4,LEL_LP2		;and any others
LEL_STORE
	MOVE	A3,*A1+,W		;Store value to the RAM table

;	MOVE	*A0+,*A1+,W

	DSJS	A6,LEL_LP
	CLRM	@ENEMY_QUOTA,W		;Quota no longer fulfilled
	MMFM	SP,A1,A2,A3,A4,A6
	RETS

**************************************************************************
*								         *
* CK_<ENEMY_ARRAY> - ROUTINE TO CHECK IF ALL VALUES IN <ENEMY_ARRAY>	 *
* 		   ARE ZERO.						 *
* RETURNS								 *
* 	 Z = ALL ARE ZERO						 *
* 	NZ = ALL ARE NOT ZERO						 *
* 									 *
* NOTE: TRASHES A14							 *
*								         *
**************************************************************************
CK_ENEMIES_LEFT
	MMTM	SP,A0,A1
	MOVI	ENEMIES_LEFT,A0
	JRUC	CEL_G
CK_ENEMY_COUNTS
	MMTM	SP,A0,A1
	MOVI	ENEMY_COUNTS,A0
	JRUC	CEL_G
*
*ENTRY POINT FOR ENEMY ARRAY CHECK
*A0 = ENEMY ARRAY TO CHECK
*
CEL_G
	MOVK	N_ENEMIES,A1
CEL_LP
	MOVE	*A0+,A14,W
	JRNZ	CEL_X
	DSJS	A1,CEL_LP
CEL_X
	MMFM	SP,A0,A1
	RETS

**************************************************************************
*								         *
* CLR_<ENEMY_ARRAY> - ROUTINE TO CLEAR ALL VALUES IN <ENEMY_ARRAY>.	 *
* RETURNS								 *
* 	NOTHING								 *
* NOTE: TRASHES A14							 *
*								         *
**************************************************************************
CLR_ENEMY_COUNTS
	MMTM	SP,A1,A2
	MOVI	ENEMY_COUNTS,A1
	MOVI	ENEMY_COUNTS+(N_ENEMIES*16),A2
	CALLA	CLRBLOCK
	MMFM	SP,A1,A2
	RETS

**************************************************************************
*								         *
* GET_ENEMY_COUNT - ROUTINE TO GET THE CURRENT COUNT FOR AN ENEMY	 *
* A0 = OID or PID OF ENEMY						 *
* RETURNS:								 *
* 	A0 = COUNT							 *
* 		STATUS REFLECT THE VALUE IN A0				 *
*								         *
**************************************************************************
GET_ENEMY_COUNT
	PUSH	A4
	MOVI	ENEMY_COUNTS,A4
	
**************************************************************************
*								         *
* GET_COUNT - ENTRYPOINT TO GET AN OBJECT COUNT FROM A SPECIFIC ARRAY.	 *
* 		INDEX IS GAINED BY GIVEN OID or PID.			 *
* A0 = OID or PID							 *
* A4 = PTR TO ARRAY							 *
* RETURNS:								 *
* 	A0 = COUNT							 *
* 		STATUS REFLECT THE VALUE IN A0				 *
* NOTE: PUSH A4 BEFORE JUMPING HERE					 *
*								         *
**************************************************************************
GET_COUNT
	SLL	25,A0
	SRL	23,A0
	ADD	A4,A0
	MOVE	*A0,A0,W
	PULL	A4
	RETS
	
**************************************************************************
*								         *
* GET_ACTIVE_ENEMIES - COMPUTES THE TOTAL NUMBER OF ACTIVE ENEMIES	 *
*                      EXCEPT ENEMY #15					 *
* PASS:									 *
* NUTIN'								 *
* RETURNS:								 *
* A14 = NUMBER OF ACTIVE ENEMIES					 *
* FLAGS REFLECT A14							 *
*								         *
**************************************************************************

GET_ACTIVE_ENEMIES
	MMTM	SP,A0,A1,A2
	CLR	A14    
	MOVK	14,A2	
	MOVI	ENEMY_COUNTS,A0
GAE_LUPE
	MOVE	*A0+,A1,W		;GET NUMBER
	ADD	A1,A14			;ADD TO TOTAL
	DSJ	A2,GAE_LUPE
	MMFM	SP,A0,A1,A2
	MOVE	A14,A14
	RETS
			   	
	
**************************************************************************
*								         *
* INC_ENEMY_COUNT - INCREMENT AN ENEMY COUNTER.				 *
* A8 = PTR TO ENEMY OBJECT						 *
*								         *
**************************************************************************
INC_ENEMY_COUNT
	MMTM	SP,A0,A4
	MOVI	ENEMY_COUNTS,A4
	MOVE	*A8(OID),A0,W
	CALLR	INC_COUNT
	MOVI	ENEMIES_TOTAL,A4
	CALLR	INC_COUNT
	MMFM	SP,A0,A4
	RETS

**************************************************************************
*								         *
* DEC_ENEMY_COUNT - DECREMENT AN ENEMY COUNTER.				 *
* A8 = PTR TO ENEMY OBJECT						 *
*								         *
**************************************************************************
DEC_ENEMY_COUNT
	MMTM	SP,A0,A4
	MOVI	ENEMY_COUNTS,A4
	MOVE	*A8(OID),A0,W
	CALLR	DEC_COUNT
	MMFM	SP,A0,A4
	RETS

**************************************************************************
*								         *
* INC_COUNT - ROUTINES TO PERFORM COUNTER OPERATIONS.			 *
* DEC_COUNT								 *
* ADD_COUNT								 *
* 									 *
* A0 = OID or PID OF THING WE ARE COUTING				 *
* A4 = PTR TO COUNTER ARRAY						 *
* RETURNS:								 *
* 	 Z = COUNTER IS NOW ZERO					 *
* 	NZ = COUNTER IS NOW OTHER THAN ZERO				 *
*								         *
**************************************************************************
INC_COUNT
	MMTM	SP,A0,A1
	MOVK	1,A1
	JRUC	ADD_COUNT
DEC_COUNT
	MMTM	SP,A0,A1
	MOVI	-1,A1
ADD_COUNT
	SLL	25,A0
	SRL	27,A0
	SLL	4,A0
	ADD	A4,A0
	MOVE	*A0,A14,W
	ADD	A1,A14
	JRGE	AC_OK
     	CLR	A14			;NO NEGS ALLOWED
AC_OK
	MOVE	A14,*A0,W
	MMFM	SP,A0,A1
	RETS

**************************************************************************
*                                                                        *
* MASTERDP - MASTER DISPATCH PROCESS.					 *
* 		INITIAL DISPATCH:					 *
* 			THESE PROCS ARE DISPATCHED ONE TIME AT WAVE STAR *
* 		POSITION DISPATCH:					 *
* 			BASED ON THE CURRENT WORLD POSITION THE		 *
* 			 POSITION TABLE IS USED TO DISPATCH THESE PROCS. *
* 		TIME DISPATCH:						 *
* 			DISPATCHES FROM THE TIME TABLE BASED ON THE	 *
* 			 ELAPSED WAVE TIME.				 *
* 		ENFORCER BAITERS:					 *
* 			A PROCESS IS CREATED THAT LOOPS ON THE ENFORCER	 *
* 			 TIME TAB. WHEN THE SPECIFIED ENFORCER TIME	 *
* 			 IS REACHED. ONCE THIS STARTS THE PROCESS	 *
* 			 LOOPS UNTIL WAVE END.				 *
* 									 *
**************************************************************************
MASSTIME .EQU	3	;MASTER DISPATCH SLEEP TIME CONSTANT

MASTERDP
	MOVE	@DISPATCH_TABLE,A2,L	;GET THE WAVE DISPATCH TABLE	
	JRZ	MASTBAIT		;BR = NO TABLE
*MASTER DISPATCH ENTRY FOR ARBITRARY DISPATCH TABLE
*A2 = PTR TO DISPATCH TABLE
MASTERG
	MOVI	PID_MASTERDP,A0
	CLR	A1
	NOT	A1
	CALLA	KILALL		;MAKE SURE NO OTHER DISPATCHERS ARE PRESENT
	MOVE	A2,A9
*INTIAL DISPATCH LOOP
MASTINIL
	MOVE	*A9,A14,W		;GET THE NEXT I.D.
	JRZ	MASTPT			;BR = DONE WITH INITIAL STUFF
	CALLR	DO_DISPATCH_ENTRY
	JRUC	MASTINIL

MASTPT
	MOVE	A9,A2
	ADDK	16,A2
;	MOVE	*A2+,A9,L		;GET THE TIME TABLE
;	MOVE	*A2+,A11,W
;	MOVE	A11,@BAITER_TIME,W
	MOVE	A2,A9
	CLR	A11			;CLEAR LOCAL TIMER

;MASTDPTM
;	MOVE	A9,A9
;	JRZ	MASTBAIT		;BR = NO TIME TABLE, SKIP
	MOVE	A9,*A13(PDATA),L
	MOVE	A11,A10
*
*TIME DISPATCH LOOP
*
MASTDPL:
	MOVE	*A9,A1,W		;LOOP THE TABLE?
	JRZ	MAST_RESET		;BR = YES, GO AND RESET HEAD
	CMPI	0FFFFFFFFH,A1
	JREQ	MAST_END
	CMPI	0FFFFFFFEH,A1
	JREQ	MAST_NEW_TAB
	CMPI	0FFFFFFFDH,A1
	JREQ	MAST_JUMP_TAB
	ADD	A10,A1			;ADD LOOP TIMER OFFSET TO BASE
	CMP	A11,A1
	JRGT	MASTTDSP
	ADDK	16,A9
	CALLR	DO_DISPATCH_ENTRY
MASTTDSP	
	CALLR	MASTTINC
MASTPLAYLP:
	SLEEP	MASSTIME
	MOVE	@HOLD_ENEMY_DISPATCH,A14,W
	JRNZ	MASTPLAYLP
	MOVE	@ENEMY_QUOTA,A14,W
	JRNZ	MDP_QUOTA_FILLED
	MOVE	@GAME_STATE,A0,W
	CMPI	INAMODE,A0
	JREQ	MASTDPL
	CMPI	INPLAY,A0
	JRNE	MASTPLAYLP	;BR = WAIT, WE ARE NOT PLAYING
	JRUC	MASTDPL
*
*RESET THE TIME TABLE AND DISPATCH AGAIN
MAST_RESET
	MOVE	@BONUS_WAVE,A0,W	;IS THIS A BONUS WAVE?
	JRNE	MASTBAIT		;BR = YES, THEN NO LOOPING
	MOVE	*A13(PDATA),A9,L
	MOVE	A11,A10
	JRUC	MASTTDSP
*
*START NEW TIME TABLE HERE
MAST_NEW_TAB
	MOVE	@BONUS_WAVE,A0,W	;IS THIS A BONUS WAVE?
	JRNE	MASTBAIT		;BR = YES, THEN NO LOOPING
	ADDK	16,A9
	MOVE	*A9+,A9,L		;GET THE NEW TABLE
	MOVE	A9,*A13(PDATA),L	;STORE FOR LOOPS
	MOVE	A11,A10
	JRUC	MASTTDSP
*
*JUMP TO A NEW TABLE ADDRESS
MAST_JUMP_TAB
	ADDK	16,A9
	MOVE	*A9+,A9,L		;GET THE NEW TABLE
	JRUC	MASTTDSP
*
*COME HERE TO END THE DISPATCH
MAST_END
	CLR	A9			;CLEAR TIME TABLE PTR FOR FLAG
	JRUC	MASTBAIT		;NOW SIT AND WAIT FOR END

*HANG HERE AND INCREMENT TIMERS
MASTBAIT
	CALLR	MASTTINC
MASTBAITLP:
	SLEEP	MASSTIME
	MOVE	@HOLD_ENEMY_DISPATCH,A14,W
	JRNZ	MASTBAITLP
	MOVE	@ENEMY_QUOTA,A14,W
	JRNZ	MDP_QUOTA_FILLED
	MOVE	@GAME_STATE,A0,W
	CMPI	INAMODE,A0
	JREQ	MASTBAIT
	CMPI	INPLAY,A0
	JRNE	MASTBAITLP
	JRUC	MASTBAIT
*
*MASTTINC - MASTER DISPATCH TIMER INCREMENT SUBROUTINE
MASTTINC
	ADDK	MASSTIME,A11		;ADD THE MASTER DISPATCH SLEEP TIME
	MOVK	MASSTIME,A0
	ALLPLYR	INC_PLAYER_TIMERS
	RETS

*
*JUMP HERE WHEN ENEMY QUOTA HAS BEEN FILLED. IT WILL DETERMINE WHAT
*TO DO FROM HERE.
*
MDP_QUOTA_FILLED
****	JSRP	ENEMY_WAIT		;FIRST WAIT ON ENEMIES TO LEAVE
****	MOVE	@ENEMY_QUOTA,A14,W
****	CMPI	2,A14
****	JAEQ	WAVE_END_QUICK

	MOVE	@WAVE_PAUSE,A14,W	
	JAZ	WAVE_END		;BR = MOVE ON
	SLEEP	1			;DON'T ADVANCE TO NEXT WAVE YET
	JRUC	MDP_QUOTA_FILLED

**************************************************************************
*								         *
* 	ENEMY_WAIT							 *
* 									 *
* 	Process subroutine to wait for all current enemies to		 *
* 	depart.  Suspends enemy dispatching for safety			 *
* 									 *
* 	Note: Call with JSRP						 *
*								         *
**************************************************************************
ENEMY_WAIT
	PUSHP	A11
	MOVKM	1,@HOLD_ENEMY_DISPATCH,W	;Suspend operations
	MOVI	2000,A11		;This is the safety time-out
EW_LP
	SLEEP	1
	CALLR	CK_ENEMY_COUNTS
	JRZ	EW_X
	MOVKM	1,@HOLD_ENEMY_DISPATCH,W	;Just in case someone got cute
	DSJS	A11,EW_LP
EW_X
	CLRM	@HOLD_ENEMY_DISPATCH,W		;Return to normal
	PULLP	A11
	RETP

**************************************************************************
*								         *
* DO_DISPATCH_ENTRY - ROUTINE TO PROCESS A DISPATCH TABLE ENTRY.	 *
* A9 = PTR TO TABLE ENTRY (DEFINED IN DISPATCH TABLE SECTION)		 *
* RETURNS:								 *
* 	A9 = PTR TO NEXT TABLE ENTRY					 *
*								         *
**************************************************************************
DO_DISPATCH_ENTRY
	MMTM	SP,A0,A1,A2,A7,A8,A10,A11
	MOVE	*A9+,A1,W			;GET THE PROCESS I.D.
	MOVE	A9,A2				;KEEP AND INC. A9
	MMFM	A2,A7,A8,A9,A10,A11		;LOAD ALL THE PARAMETERS
	CALLA	GETPRC				;FIRE OFF A PROCESS
	MOVE	A2,A9				;AND POINT A9 AT NEXT
	MMFM	SP,A0,A1,A2,A7,A8,A10,A11
	RETS

**************************************************************************
*								         *
*         ****  DISPATCH NOTES DISPATCH NOTES DISPATCH NOTES  ****	 *
* 									 *
* 	NOTE 1:	DISPATCH TYPE PROCESSES SHOULD STORE			 *
* 		THE VALUE AT SUBWAVE UPON CREATION.			 *
* 		IF THAT VALUE DIFFERS FROM THE CURRENT			 *
* 		SUBWAVE VALUE, THEN KILL YOURSELF.			 *
* 		THINGS COULD GET NASTILY OVERLOADED			 *
* 		QUICK FAST IN A HURRY!					 *
* 									 *
* 	NOTE 2: DISPATCHERS SHOULD NOT MAKE ANY DISPATCHES		 *
* 		IF THE VARIABLE DISPATCH_DELAY IS <> 0.			 *
* 									 *
*         ****  DISPATCH NOTES DISPATCH NOTES DISPATCH NOTES  ****	 *
*								         *
**************************************************************************
DPATCH_SUBWAVE	.EQU	PDATA	;UHW SUBWAVE VALUE AT TIME 'O CREATION

**************************************************************************
*								         *
* GRUNT_DISPATCH - PROCESS TO DISPATCH GRUNTS.				 *
* 		 A10 WILL BE USED TO DETERMINE CURRENT # OF ACTIVE	 *
* 			ENEMY TYPE.					 *
* 		 SPAWNED PROCESS WILL GET I.D. OF THE PROCESS.		 *
* A8 = NUMBER TO START							 *
* A9 = NUMBER ALLOWED CONCURRENTLY					 *
* A10 = OID OF GRUNT							 *
* A11 = ADDRESS OF PROCESS						 *
*								         *
**************************************************************************
GRUNT_DISPATCH
	MOVE	*A13(PROCID),A1,W
	MOVE	@SUBWAVE,A14,W
	MOVE	A14,*A13(DPATCH_SUBWAVE),W
	MOVE	@CURPLYRS,A14,W
	CMPI	2,A14				;HOW MANY PLAYERS WE GOT?
	JRLO	GD_LP				;BR = NOT ENOUGH TO INC DISP
	MOVE	@ENEMY_QUOTA,A14,W		;TOTAL ENEMY QUOTA FILLED
	JRNZ	GD_LP				;BR = YES, NO QUOTA ADDITIONS

	MOVE	A10,A0
	ANDI	MASK_ID,A0
	SLL	4,A0
	ADDI	ENEMIES_LEFT,A0
	MOVE	*A0,A14,W			;GET THE CURRENT ENEMY QUOTA
	JRZ	GD_LP				;NO MORE OF THIS ENEMY PLEASE

	MOVE	A8,A2
	SRA	1,A2				
	ADD	A2,A8				;INCREASE ENEMY COUNT 50%
	ADD	A2,A14
	MOVE	A14,*A0,W
****	CALLA	COUNT_PROCESSES			;HOW MANY OF THIS DISPATCHER?
****	CMPI	6,A0
****	JRHS	GD_DIE				;BR = ONLY 5 ALLOWED
GD_LP
	MOVE	@DISPATCH_DELAY,A14,W
	JRNZ	GRUNT_D_WAIT
	MOVE	A10,A0
	CALLR	GET_ENEMY_COUNT			;HOW MANY ENEMIES?
	CMP	A9,A0
	JRHS	GRUNT_D_WAIT			;BR = TOO MANY, WAIT AWHILE
	MOVE	*A13(PROCID),A1,W
	MOVE	A11,A7
	CALLA	GETPRC
GRUNT_D_SLEEP
	MOVI	30,A0
	MOVI	10,A1
	CALLA	RANGRAND
	SLEEPR	A0
	MOVE	*A13(DPATCH_SUBWAVE),A0,W
	MOVE	@SUBWAVE,A1,W
	CMP	A0,A1				;SAME REALM OF BEING?
	JRNE	GD_DIE				;BR = NO, DELETE ME BOY
	DSJ	A8,GD_LP
GD_DIE
	DIE					;WE DONE JACK!

GRUNT_D_WAIT
	MOVI	30,A0
	MOVI	10,A1
	CALLA	RANGRAND
	SLEEPR	A0
	MOVE	*A13(DPATCH_SUBWAVE),A0,W
	MOVE	@SUBWAVE,A1,W
	CMP	A0,A1				;SAME REALM OF BEING?
	JRNE	GD_DIE				;BR = NO, DELETE ME BOY
	JRUC	GD_LP

**************************************************************************
*								         *
* PROC_CALL - PROCESS TO CALL A ROUTINE AND DIE.			 *
* A11 = ADDRESS OF ROUTINE						 *
*								         *
**************************************************************************
PROC_CALL
	CALL	A11
	DIE

**************************************************************************
*								         *
* ABSOLUTE_DISPATCH - PROCESS TO DISPATCH AN ABSOLUTE NUMBER OF GRUNTS	 *
* 		 A10 WILL BE USED TO DETERMINE CURRENT # OF ACTIVE	 *
* 			ENEMY TYPE.					 *
* 		 SPAWNED PROCESS WILL GET I.D. OF THE PROCESS.		 *
* 		 NO INCREASED ENEMY COUNTS WILL OCCUR DUE TO		 *
* 		 NUMBER OF CONSECUTIVE PLAYERS, AS IN GRUNT_DISPATCH	 *
* A8 = NUMBER TO START							 *
* A9 = NUMBER ALLOWED CONCURRENTLY					 *
* A10 = OID OF GRUNT							 *
* A11 = ADDRESS OF PROCESS						 *
*								         *
**************************************************************************
ABSOLUTE_DISPATCH
	MOVE	*A13(PROCID),A1,W
	MOVE	@SUBWAVE,A14,W
	MOVE	A14,*A13(DPATCH_SUBWAVE),W
	JRUC	GD_LP				;JUST DISP IT!

**************************************************************************
*								         *
* PROC_ONETIME_DISPATCH - PROCESS TO DO A ONE TIME DISPATCH.		 *
* 			IF ACTIVE ENEMIES ARE MAXED THEN		 *
* 			THE DISPATCH IS IGNORED. DON'T BASE		 *
* 			ANY WAVE COMPLETIONS ON THIS DISPATCH.		 *
* A8 = NUMBER TO START							 *
* A9 = NUMBER ALLOWED CONCURRENTLY					 *
* A10 = OID OF GRUNT							 *
* A11 = ADDRESS OF PROCESS						 *
*								         *
**************************************************************************
PROC_ONETIME_DISPATCH
	MOVE	*A13(PROCID),A1,W
	MOVE	A11,A7
	CALLR	ONETIME_DISPATCH
	DIE

**************************************************************************
*								         *
* ONETIME_DISPATCH - ROUTINE TO DO A ONE TIME DISPATCH OF ENEMIES.	 *
* 		   IF MAX NUMBER ALLOWED IS EXCEEDED, THE REST		 *
* 		   ARE THROWN OUT, SO DON'T BASE ANY WAVE COMPLETION	 *
* 		   STUFF ON THESE DISPATCHES.				 *
* 									 *
* 		 A10 WILL BE USED TO DETERMINE CURRENT # OF ACTIVE	 *
* 			ENEMY TYPE.					 *
* A1 = PID OF PROCESS							 *
* A7 = ADDRESS OF PROCESS						 *
* A8 = NUMBER TO START							 *
* A9 = NUMBER ALLOWED CONCURRENTLY					 *
* A10 = OID OF GRUNT							 *
*								         *
**************************************************************************
ONETIME_DISPATCH
	MMTM	SP,A0,A6,A8
	MOVE	A10,A0
	CALLR	GET_ENEMY_COUNT			;HOW MANY ENEMIES?
	CMP	A9,A0
	JRHS	OTD_X				;BR = TOO MANY, NO CAN DO
	MOVE	A0,A6				;KEEP FOR LATER
OTD_LP
	CALLA	GETPRC
	INC	A6
	CMP	A9,A6
	JRHS	OTD_X				;BR = TOO MANY, NO CAN DO
	DSJS	A8,OTD_LP
OTD_X
	MMFM	SP,A0,A6,A8
	RETS

**************************************************************************
*								         *
* A_ONETIME - ANIM FUNC TO DO A ONE TIME ENEMY DISPATCH.		 *
* A8 = OBJECT DISPATCHING						 *
* AARG+,W = NUMBER TO START						 *
* AARG+,W = NUMBER ALLOWED						 *
* AARG+,W = PID OF PROCESS						 *
* AARG+,W = OID OF ENEMY						 *
* AARG+,L = ADDRESS OF PROCESS						 *
*								         *
**************************************************************************
A_ONETIME
	CALLA	GETAFARG_LONG	
	MOVE	A0,A9
	CALLA	GETAFARG_LONG	
	MOVE	A0,A10
	CLR	A1
	MOVX	A0,A1
	SRL	16,A10
	CALLA	GETAFARG_LONG	
	MOVE	A0,A7
	CLR	A8
	MOVX	A9,A8
	SRL	16,A9
	JAUC	ONETIME_DISPATCH

**************************************************************************
*								         *
* HEADS_UP_FLAG - DISPATCHER PROCESS TO TURN THE HEADS UP DISPLAYS ON/OF *
* A11 = VALUE TO STUFF IN HUP_OFF					 *
*								         *
**************************************************************************
HEADS_UP_FLAG
	MOVE	A11,@HUP_OFF,W
	DIE

**************************************************************************
*								         *
* PROC_ENEMY_QUOTA - PROCESS TO SET THE ENEMY QUOTA, TO END THE WAVE	 *
* 		  AS SOON AS POSSIBLE.					 *
*								         *
**************************************************************************
PROC_ENEMY_QUOTA
	MOVKM	1,@ENEMY_QUOTA,W
	DIE

**************************************************************************
*								         *
* 	PROC_SND							 *
* 									 *
* 	Process to fire off a sound call after some delay.		 *
* 									 *
* 	A10 = Delay (in ticks)						 *
* 	A11 = Sound script						 *
*								         *
**************************************************************************
PROC_SND
	MOVE	A10,A10
	JRZ	PS_GO
     	SLEEPR	A10
PS_GO
	MOVE	A11,A0
	CALLA	ONESND
	DIE

**************************************************************************
*								         *
* 	PROC_SBOMB							 *
* 									 *
* 	Process to start a drop in package with a smart bomb in it.	 *
* 									 *
* 	A8  = Interval (If more than one)				 *
* 	A9  = [Initial sleep,# to drop]					 *
* 	A10 = Minimum Z of drop						 *
* 	A11 = Minimum Z of drop						 *
*								         *
**************************************************************************
PROC_SBOMB
	MOVI	PACK_SBOMB,A1
	JRUC	PROC_SINGLE_PACK

**************************************************************************
*								         *
* 	PROC_SUPERGUN							 *
* 									 *
* 	Process to start a drop in package with a SuperGun in it.	 *
* 									 *
* 	A8  = Interval (If more than one)				 *
* 	A9  = [Initial sleep,# to drop]					 *
* 	A10 = Minimum Z of drop						 *
* 	A11 = Minimum Z of drop						 *
*								         *
**************************************************************************
PROC_SUPERGUN
	MOVI	PACK_SUPERGUN,A1
	JRUC	PROC_SINGLE_PACK

*
* A1 = Routine to call for pack drop
*
PROC_SINGLE_PACK
	MOVE	A1,*A13(PDATA+10H),L

	MOVE	*A13(PROCID),A0,W
	CALLA	KILLPROC_ALL

	MOVE	@SUBWAVE,A14,W
	MOVE	A14,*A13(PDATA),W

	MOVE	A9,A0
	ZEXT	A9
	SLA	16,A0
	JRZ	PSP_LP			;BR = No initial sleep
	SLEEPR	A0

	MOVE	*A13(PDATA),A1,W
	MOVE	@SUBWAVE,A14,W
	CMP	A1,A14
	JRHI	PSP_DIE			;BR = We lost it during our initial sleep

PSP_LP
	CLR	A3
	NOT	A3
	MOVE	*A13(PDATA+10H),A14,L
	CALL	A14
	SLEEPR	A8
	MOVE	*A13(PDATA),A1,W
	MOVE	@SUBWAVE,A14,W
	CMP	A1,A14
	JRHI	PSP_DIE
	DSJS	A9,PSP_LP
PSP_DIE
	DIE

**************************************************************************
*								         *
* PROC_DROP_PACK - PROCESS TO START DROPPING PACKAGES AT RANDOM		 *
*		   INTERVALS						 *
*								         *
* PASS:									 *
* A8  = MAXIMUM ADDITIONAL TIME INTERVAL				 *
* A9  = MINIMUM TIME BETWEEN PACKAGES					 *
* A10 = MINIMUM Z OF DROP						 *
* A11 = MAXIMUM Z OF DROP						 *
*								         *
* RETURNS:								 *
* NUTIN'								 *
*								         *
**************************************************************************
PROC_DROP_PACK
	MOVE	*A13(PROCID),A0,W
;	MOVI	PID_POWERUPD0,A0
	CALLA	KILLPROC_ALL
PROC_DROP_PACK_LUPE
	SLEEPR	A9			;SLEEP AT LEAST THIS AMOUNT
	MOVE	A8,A0
	CALLA	RANDU
	SLEEPR	A0			;GO BACK TO SLEEP			 	
	MOVI	-1,A3			;DROP OVER FULL SCREEN

	MOVK	8,A6			;Max number of attempts
PDP_AGAIN
	MOVK	NUM_PACKS,A0
	CALLA	RAND0			;PICK A RANDOM TABLE ENTRY
	MOVE	A0,A5
	SLL	6,A5
	ADDI	PACK_TABLE,A5
	MOVE	*A5+,A0,L
	JRZ	PDP_ALWAYS		;BR = Do this always
	CALLA	RANDPER
	JRC	PDP_ALWAYS		;BR = It's time has come
	DSJS	A6,PDP_AGAIN	   	;BR = We have another chance
	JRUC	PROC_DROP_PACK_LUPE	;Just bail on this one

PDP_ALWAYS
	MOVE	*A5,A0,L
	CALL	A0			;DO IT!
	JRUC	PROC_DROP_PACK_LUPE

NUM_PACKS	.EQU	5
*
* Table for dropping of weapons packs
*	.LONG	% chance if picked (0 = always), Routine to call
*
PACK_TABLE
	.LONG	0, PACK_CD
	.LONG	0, PACK_PROCK
	.LONG	300, PACK_SUPERGUN
	.LONG	200, PACK_LAZER
	.LONG	300, PACK_SHIELD

**************************************************************************
*								         *
* DUMMY_PROC - DO NUTIN'						 *
*								         *
**************************************************************************

DUMMY_PROC
	DIE ;DIE, MY DARLING 



	.END
