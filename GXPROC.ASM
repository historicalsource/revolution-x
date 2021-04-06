	.MLIB	"GXMACS.LIB"
	.FILE	"GXPROC.ASM"
	.TITLE	"<<< GENERATION X -- MULTI-TASKING SYSTEM VER. 2.0 >>>"
	.WIDTH	132
	.OPTION	B,D,L,T
	.MNOLIST

**************************************************************************
*								         *
* 	COPYRIGHT (C) 1992 MIDWAY MANUFACTURING COMPANY.		 *
* 		       ALL RIGHTS RESERVED.				 *
*								         *
**************************************************************************

	.INCLUDE	"GX.INC"		;SYSTEM EQUATES

*
*GSP MULTI-TASKING SYSTEM
*VERSION 1.0 BY EUGENE P. JARVIS
*VERSION 2.0 BY GEORGE N. PETRO
*

* In this file
	.DEF	OBJPROC_KILL_MULTI

***** In GXCOIN.ASM 

	.REF	TIMEINT

***** In GXD.ASM

	.REF	INVELADD

*THE KIND OF RAM WE LIKE
	.BSS	ACTIVE,32	;regular process list
	.BSS	FREE,32		;FREE PROCESS POOL
	.BSS	PACTIVE,32	;priority process list
	.BSS	FREEZE,32	;REGULAR PROCESS FREEZE LIST
	.BSS	PFREEZE,32	;PRIORITY PROCESS FREEZE LIST
*
* The actual process list (make sure it is on a LONG word boundry)
*
	.BSS	PRCSTR,NPROC*PRCSIZ	;PROCESS STORE ALLOCATION
	.BSS	PRCLSTND,0

*GLOBAL PROC VARS
	.IF NOTFINAL
	.DEF	THISPROC, LASTPROC, THISWAKE	;FOR DEBUGGING
	.BSS	LASTPROC,32
	.BSS	THISPROC,32
	.BSS	THISWAKE,32
	.ENDIF

	.BSS	PRIORITY,16	;current execution list of multi-tasker
PRI_ACTIVE	.set	0	;checked with	JZ
PRI_PACTIVE	.set	1	;		JP
PRI_GOPACTIVE	.set	-1	;		JN

	.BSS	NXTPRC,32	;ptr to next process to be executed
				  ;when resuming from priority list
	.BSS	PFREECNT,16	;COUNT OF PROC FREE LIST
	.BSS	TIME,16		;TIME CTR
	.BSS	TIMER,16	;IRQ TIMER 16 MSEC.
	.BSS	LAST_TIMER,16	;TIMER VALUE AT END OF PROCESS DISPATCH

	.BSS	UNUSED_WORD1,16	;For alignment purposes

;	.REF	CkOFREE		;for debugging

 	.TEXT


**************************************************************************
*PROCESS DISPATCH
**************************************************************************
*PROCESS DISPATCH
PRCDSP:
	CALLA	YZSORT	   ;ALWAYS SORT THE DISPLAY LIST ONCE
	MOVE	@TIMER,A0
	JRZ	PRCDSP	   ;BR = WAIT FOR DIRQ, SORT TO KILL TIME
DOPRC:
	CLR	A14
	MOVE	A14,@INVELADD,W		;reset VELADD flag

	CALLA	TIMEINT			;MUST DO THIS BEFORE TIMER

;	CLR	A0
;	MOVE	A0,@TIMER

;	CALLA	DRIVER_UPDATE		;TIME THE COILS *** 8/27/92

 	MOVE	@PAUSE_GAME,A14,W	;ARE WE IN PAUSE MODE?
	JRNZ	NOSCALE
	CALLA	ANIMP			;ANIMATE STUFF
	CALLA	INFINITY_PLANES		;PROCESS THE INIFINITY PLANE POSs
;	CALLA	SCALE_MAMA		;UPDATE SCALES and compute SCREEN POS

NOSCALE	
;	CLR	A0
;	MOVE	A0,@TIMER
*
* Global Overload check 
*
	CLR	A0			;This is our overload flag

	MOVE	@CPUAVG,A14,W
	CMPI	200,A14			;Are we low on CPU time?
	JRLS	PD_OVERLOAD		;BR = Yes
	MOVE	@DMAAVG,A14,W
	CMPI	100,A14	     		;Are we low on DMA time?
	JRHI	PD_OVERLOAD_FLAG	;BR = No
	
PD_OVERLOAD
	MOVI	XSCROLL,A1		;when scrolling.
	MOVE	*A1+,A14,L		;Scrolling in X?
	JRNZ	PD_OVERLOADED		;BR = Yes
	MOVE	*A1+,A14,L		;Scrolling in Y?
	JRNZ	PD_OVERLOADED		;BR = Yes
	MOVE	*A1,A14,L		;Scrolling in Z?
	JRZ	PD_OVERLOAD_FLAG	;BR = No, we must not be overloaded
PD_OVERLOADED
	INC	A0			;Set that flag
PD_OVERLOAD_FLAG
	MOVE	A0,@OVERLOADED,W	;Make the flag global.

	movk	PRI_PACTIVE,A0		;will be executing priority list
	move	A0,@PRIORITY,W
	MOVI	ACTIVE,A13,L		;Reg process list
	move	A13,@NXTPRC,L
	MOVI	PACTIVE,A13,L		;priority process list
	JRUC	PRCD1

*
*PROCESS SLEEP
*TOS IS WAKEUP ADDR, A0 = SLEEP TIME
PRCSLP:
	move	*SP+,A7,L		       ;CALLING PC->A7
PRCLSP:
;	.IF DEBUG
;	calla	CkOFREE
;	.ENDIF

	move	A13,A1
	addi	PDATA,A1
	mmtm	A1,A7,A8,A9,A10,A11,A12 ;wakeup, regs, stack ptr
	move	A0,-*A1,W		;sleep

	.if DEBUG			;this is for DEBUG only
	MOVE	A13,A0
	ADDI	PSDATA,A0
	CMP	A0,A12
	JRLT	$			;Stick on Stack overflow
	ADDI	PRCSIZ-PSDATA,A0
	CMP	A0,A12
	JRGT	$			;Stick on Stack underflow
	.endif


PRCD1:
	.IF DEBUG
	MOVE	@THISPROC,@LASTPROC,L
	.ENDIF
	move	@PRIORITY,A0,W
	jrnn	SkPSwitch		;Check for PRI_GOPACTIVE

	;*** SWITCH TO PRIORITY PROCESS LIST ***
	move	A13,@NXTPRC,L
	movi	PACTIVE,A13,L
	movk	PRI_PACTIVE,A1
	move	A1,@PRIORITY,W
SkPSwitch

	;*** FIND NEXT PROCESS READY TO GO (PTIME <= 0) ***
	MOVE	@LAST_TIMER,A1,W		;DO IT BY TIMER
CkNxtP
	MOVE	*A13,A13,L
	JREQ	PRCDX
	MOVE	*A13(PTIME),A0,W
	SUB	A1,A0
****	DEC	A0
	MOVE	A0,*A13(PTIME),W
	JRP	CkNxtP		;NOT READY, LOOP FOR NEXT

*PROCESS IS READY FOR DISPATCH
PRCD2:
	move	A13,A1
	addi	40H,A1
	mmfm	A1,A7,A8,A9,A10,A11,A12	;wake, regs, stack ptr

	.if DEBUG			;this is for DEBUG only
	MOVE	A13,A0
	ADDI	PSDATA,A0
	CMP	A0,A12
	JRLT	$			;Stick on Stack overflow
	ADDI	PRCSIZ-PSDATA,A0
	CMP	A0,A12
	JRGT	$			;Stick on Stack underflow
	.endif
	
	.IF NOTFINAL
	MOVE	A13,@THISPROC,L
	MOVE	A7,@THISWAKE,L
	.ENDIF

	jump	A7			;fire off proc

*DONE WITH THE SCAN
PRCDX:
	move	@PRIORITY,A0,W		;Check for PRI_PACTIVE
	jrp	PRCCONT			;If finnishing priority, try regular

	.IF NOTFINAL
	CLR	A0
	MOVE	A0,@THISPROC,L
	.ENDIF

	MOVE	@TIMER,@LAST_TIMER,W	;HOW LONG WAS IT?
	CLR	A0
	MOVE	A0,@TIMER

	RETS		;GO BACK TO EXEC LOOP

PRCCONT:
	;*** RESUME REGULAR PROCESS LIST ***
	move	@NXTPRC,A13,L
	clr	A0			;PRI_ACTIVE
	move	A0,@PRIORITY,W
	jruc	PRCD1


*PROCESS SUICIDE
SUCIDE:
	.IF DEBUG
;	calla	CkOFREE
	callr	CkPlinks
         .ENDIF
	MOVI	ACTIVE,A1,L
SUCLP:
	MOVE	A1,A2       	;SAVE PREVIOUS
	MOVE	*A1,A1,L
	JRZ	PSUCIDE
	CMP	A1,A13		;CHECK FOR MATCH TO CURRENT PROCESS
	JRNE	SUCLP		;NOT FOUND KEEP LOOKING
	jruc	SucIt
PSUCIDE:
	MOVI	PACTIVE,A1,L
PSUCLP:
	MOVE	A1,A2       	;SAVE PREVIOUS
	MOVE	*A1,A1,L
	LOCKON	Z
	CMP	A1,A13		;CHECK FOR MATCH TO CURRENT PROCESS
	JRNE	PSUCLP		;NOT FOUND KEEP LOOKING

SucIt:
	;*** MOVE PROCESS TO FREE LIST ***
	MOVE	*A1,*A2,L	;LINK AROUND IN ACTIVE LIST
	.IF DEBUG
	move	A1,A0
	callr	CkFree
	.ENDIF
	move	@PFREECNT,A0,W	;inc count of free processes
	inc	A0
	move	A0,@PFREECNT,W
	MOVE	@FREE,A0,L	;GET FREE POINTER
	MOVE	A0,*A1,L	;LINK INTO FREE LIST AT START
	MOVE	A1,@FREE,L
	MOVE	A2,A13		;SET CURRENT PROCESS TO PREVIOUS
	JRUC	PRCD1 		;CONTINUE WITH DISPATCH
**************************************************************************


**************************************************************************
*PROCESS LIST INITIALIZE
*A13 RETURNED POINTING TO ACTIVE LIST (CRPROC)
PINIT:
	MMTM	SP,A0,A1,A2,A3	;SAVE REG
	MOVI	NPROC,A3,W	;# OF PROCESSES TO INIT
	move	A3,@PFREECNT,W
	CLR     A0
	MOVE	A0,@ACTIVE,L	;NULL ACTIVE LIST
	MOVE	A0,@PACTIVE,L	;NULL PRIORITY ACTIVE LIST
	MOVE	A0,@FREEZE,L 	;NULL THE FREEZE LISTS
	MOVE	A0,@PFREEZE,L
	MOVK	1,A1
	MOVE	A1,@LAST_TIMER,W	;MAKE SURE IT KICKS OFF
	MOVI	PRCSTR,A1,L
	MOVE	A1,@FREE,L	;SETUP FREE LIST
PINITL:
	MOVE	A1,A2
	ADDI	PRCSIZ,A1,W
	MOVE	A1,*A2,L	;LINK EM UP
	DSJS	A3,PINITL	;CONTINUE FOR NPROC
    	MOVE	A0,*A2,L	;ZERO LAST LINK
	MOVI	ACTIVE,A13,L	;INIT CURRENT PROCESS
	MMFM	SP,A0,A1,A2,A3	;RESTORE REGS
	RETS
**************************************************************************

**************************************************************************
*CREATE A PROCESS
*A1=ID,A7=PC,A8,A9,A10,A11 PASSED PARAMETERS
*A13=CURRENT PROCESS
*A0 IS RETURNED POINTING TO CREATED PROCESS
GETPPRC:
	MMTM	SP,A2,A13
	move	@PRIORITY,A0,W
	jrp	GetIt		;executing priority list
	movi	PACTIVE,A13
	jruc	GetIt
GETPRC:
	MMTM	SP,A2,A13
	move	@PRIORITY,A0,W
	jrz	GetIt		;executing reg list
	jrn	GetIt		;executing reg list
	movi	ACTIVE,A13
GetIt:
 	MOVE	@FREE,A0,L
	JREQ	GETPX		;NONE AVAILABLE
	move	@PFREECNT,A2,W	;dec count of free processes
	dec	A2
	move	A2,@PFREECNT,W
	.IF	DEBUG
	jrn	$		;WANT
	.ENDIF
	MOVE	*A0,A2,L
	MOVE	A2,@FREE,L	;REMOVE FROM FREE LIST
	MOVE	*A13,*A0,L	;LINK INTO ACTIVE LIST AFTER CURRENT PROCESS
	MOVE	A0,*A13,L	;CRPROC>>NEW PROC
	MOVE	A1,*A0(PROCID)
	MOVE	A0,A2
	ADDI	PDATA,A2
	MMTM	A2,A7,A8,A9,A10,A11
	move	A0,A2
	addi	PRCSIZ,A2
	MOVE	A2,*A0(PSPTR),L	;PUT IN STACK POINTER
	MOVK	1,A2		;INIT SLEEP TIME
	MOVE	A2,*A0(PTIME)
	CLR	A2
	MOVE	A2,*A0(PCOMM),W	;CLEAR THE COMMUNICATION LINE ON INIT
	move	A0,A0		;set non-zero flag
GETPX:
	MMFM	SP,A2,A13
	RETS
**************************************************************************

**************************************************************************
* XFERPROC - TRANSFER CONTROL OF AN EXISTING PROCESS
* A0 = PTR OF PROCESS TO BE XFER'D
* A1 = NEW I.D.
* A7 = WAKE UP
* A8 - A11 = PASSED TO THE XFER'D PROC
XFERPROC
	mmtm	SP,A2,A12
	MOVE	A0,A2
	ADDI	PDATA,A2
	move	A0,A12			;RESET PROCESS STACK POINTER
	addi	PRCSIZ,A12
	MMTM	A2,A7,A8,A9,A10,A11,A12	;STUFF wake, regs, p stack ptr
	movk	1,A12
	move	A12,-*A2,W		;WAKE UP AS SOON AS POSSIBLE
	move	A1,-*A2,W		;ID
	mmfm	SP,A2,A12
	RETS
**************************************************************************

**************************************************************************
*								         *
* PROC_INT - INTERRUPT A PROCESS TO ANOTHER ROUTINE THAT WILL RETP BACK. *
* A0 = PTR OF PROCESS TO BE XFER'D					 *
* A7 = WAKE UP								 *
*								         *
**************************************************************************
PROC_INT
	mmtm	SP,A1,A2
	move	*A0(PWAKE),A2,L
	move	A7,*A0(PWAKE),L		;set new wake up
	MOVE	*A0(PSPTR),A1,L		;GET THE STACK POINTER
	move	A2,-*A1,L		;Push old wake up
	MOVE	A1,*A0(PSPTR),L		;RESET THE STACK POINTER
	MOVK	1,A1
	MOVE	A1,*A0(PTIME),W		;WAKE UP AS SOON AS POSSIBLE
	mmfm	SP,A1,A2
	RETS

**************************************************************************
*								         *
* CkPlinks - DEBUG ONLY FUNCTION TO CHECK IF ANY FOREGROUND OBJECTS	 *
* 	   OPLINK FIELD MATCHES A13.					 *
*								         *
**************************************************************************
	.IF DEBUG
CkPlinks:
	mmtm	SP,A0,A1,A2
	movi	FGLIST,A0
	MOVE	A0,A2
CkPlink:
	move	*A0,A0,L
	cmp	A0,A2
	jreq	PlinkX
	move	*A0(OPLINK),A1,L
	cmp	A13,A1
	jreq	$
	jruc	CkPlink
PlinkX:
	mmfm	SP,A0,A1,A2
	rets

	.ENDIF

**************************************************************************
	.IF DEBUG
CkFree:
;* CALLED W/ PROC TO BE FREED IN A0 - IF PROC ON FREE LIST HANG
	PUSH	A1
	movi	FREE,A1,L
FreeCkLp:
	move	*A1,A1,L
	jrz	FreeCkX
	cmp	A1,A0
	jrne	FreeCkLp
	;*** GOT PROCESS TO BE FREED ON FREE LIST, LOG IT
	jruc	$

FreeCkX:
	PULLQ	A1
	rets
	.ENDIF
**************************************************************************

**************************************************************************
*KILL PROCESS
*A0 POINTS TO PROCESS TO KILL
*IF PROCESS NOT PRESENT, CAUSES ERROR
*TO KILL YOURSELF SUCIDE MUST BE USED,
*IF YOU ATTEMPT TO KILL YOURSELF IT WILL JUST RETURN
KILL:
        CMP	A0,A13		;KILLING YOURSELF?
	JREQ	KILLXXX		;BR = YES, JUST ESCAPE
	MMTM	SP,A1,A2
	.IF DEBUG
	move	A13,A1
	move	A0,A13
	callr	CkPlinks
	callr	CkFree
	move	A1,A13
	.ENDIF

	MOVI	ACTIVE,A1,L
	callr	KILLP
	jrnz	KILLX
	MOVI	PACTIVE,A1,L
	callr	KILLP
	jrnz	KILLX
	MOVI	FREEZE,A1,L
	callr	KILLP
	jrnz	KILLX
	MOVI	PFREEZE,A1,L
	callr	KILLP
	jrnz	KILLX
	;*** CANT FIND TO KILL, LOG AN ERROR ***
	.IF DEBUG
	jruc	$
	.ENDIF
KILLX
	MMFM	SP,A1,A2
KILLXXX
	RETS

KILLP:
	MOVE	A1,A2       	;SAVE PREVIOUS
	MOVE	*A1,A1,L
	JRZ	KILLPX
	CMP	A1,A0
	JRNE	KILLP		;NOT FOUND KEEP LOOKING

	;*** KILL IT ***
	MOVE	*A0,*A2,L	;LINK AROUND IN ACTIVE LIST
	MOVE	@FREE,A1,L	;LINK INTO FREE LIST AT START
	MOVE	A1,*A0,L
	MOVE	A0,@FREE,L

	move	@NXTPRC,A1,L
	cmp	A1,A0
	jrne	SkNewNxt
	movi	ACTIVE,A1
	move	A1,@NXTPRC,L
SkNewNxt:

	move	@PFREECNT,A2,W	;inc count of free processes
	inc	A2
	move	A2,@PFREECNT,W	;also clears Z bit
KILLPX:
	rets
**************************************************************************


**************************************************************************
*								         *
* KILLPROC_ALL - KILL ALL OF THE PROCESSES WITH GIVEN I.D.		 *
* 		EXCEPT CALLING PROCESS.					 *
* A0 = PROCESS I.D. TO KILL						 *
*								         *
**************************************************************************
KILLPROC_ALL
	PUSH	A1
	CLR	A1
	NOT	A1
	CALLR	KILALL
	PULLQ	A1
	RETS

**********************************************************************
*KILL A CLASS OF PROCESSES
*A0=PROCID (16 BITS) ,A1=MASK (16 BITS)
*MASK BITS OF ZERO ARE DONT CARES
*WILL NOT KILL CALLING PROCESS (A13)
KILALL:
	MMTM	SP,A0,A2,A3,A5
	SEXT	A0		;SAFETY OP
	AND	A1,A0		;FORM MATCH
	MOVI	ACTIVE,A2,L
	callr	KILALP
	MOVI	PACTIVE,A2,L
	callr	KILALP
	MOVI	FREEZE,A2,L
	callr	KILALP
	MOVI	PFREEZE,A2,L
	callr	KILALP
	movi	ACTIVE,A0
	move	A0,@NXTPRC,L
	MMFM	SP,A0,A2,A3,A5
	RETS

KILALP:
	MOVE	A2,A3		;SAVE PREVIOUS
	MOVE	*A2,A2,L	;GET NEXT
	JREQ	KILALX		;ALL DONE
	MOVE	*A2(PROCID),A14
	AND	A1,A14		;CAN DONT CARE BITS
	CMP	A0,A14		;MATCH?
	JRNE	KILALP		;NO

	CMP	A2,A13		;CURRENT PROCESS?
	JREQ	KILALP		;YES DONT KILL

	MOVE	*A2,*A3,L	;LINK AROUND IN ACTIVE LIST
	MOVE	@FREE,A5,L	;LINK INTO FREE LIST AT START
	MOVE	A5,*A2,L
	MOVE	A2,@FREE,L	;POINT FREE TO CELL
	move	@PFREECNT,A2,W	;inc count of free processes
	inc	A2
	move	A2,@PFREECNT,W
	MOVE	A3,A2
	JRUC	KILALP		;KILL THE REST
KILALX:
	rets
**********************************************************************

**************************************************************************
*								         *
* FREEZE_PROC - FREEZE A SINGLE PROCESS.				 *
* A0 = PTR TO PROCESS TO FREEZE						 *
*								         *
**************************************************************************
FREEZE_PROC:
        CMP	A0,A13		;FREEZING YOURSELF?
	JREQ	FP_XXX		;BR = YES, CAN'T DO THIS!

	MMTM	SP,A1,A2,A5
	MOVI	ACTIVE,A1,L
	MOVI	FREEZE,A5,L
	CALLR	FP_LP
	JRNZ	FP_X
	MOVI	PACTIVE,A1,L
	MOVI	PFREEZE,A5,L
	CALLR	FP_LP
	JRNZ	FP_X
	;*** CANT FIND TO FREEZE, LOG AN ERROR ***
	.IF DEBUG
	JRUC	$
	.ENDIF
FP_X
	MMFM	SP,A1,A2,A5
FP_XXX
	RETS

**************************************************************************
*								         *
* THAW_PROC - THAW A SINGLE PROCESS.					 *
* A0 = PTR TO PROCESS TO FREEZE						 *
*								         *
**************************************************************************
THAW_PROC:
        CMP	A0,A13		;FREEZING YOURSELF?
	JREQ	TP_XXX		;BR = YES, CAN'T DO THIS!

	MMTM	SP,A1,A2,A5
	MOVI	FREEZE,A1,L
	MOVI	ACTIVE,A5,L
	CALLR	FP_LP
	JRNZ	TP_X
	MOVI	PFREEZE,A1,L
	MOVI	PACTIVE,A5,L
	CALLR	FP_LP
	JRNZ	TP_X
	;*** CANT FIND TO THAW, LOG AN ERROR ***
	.IF DEBUG
	JRUC	$
	.ENDIF
TP_X
	MMFM	SP,A1,A2,A5
TP_XXX
	RETS

*COMMON SUB LOOP FOR FREEZE AND THAW OF SINGLE PROCESS
FP_LP:
	MOVE	A1,A2       	;SAVE PREVIOUS
	MOVE	*A1,A1,L
	JRZ	FP_LP_X
	CMP	A1,A0
	JRNE	FP_LP		;NOT FOUND KEEP LOOKING
	;*** FREEZE/THAW IT ***
	MOVE	*A0,*A2,L	;LINK AROUND IN CURRENT LIST
	MOVE	*A5,*A0,L	;LINK INTO SUPPLIED LIST
	MOVE	A0,*A5,L	;AND NOW MAKE ONE HAPPY FAMILY
	MOVE	A0,A0		;FLAG SUCCESS
FP_LP_X:
      	RETS

**************************************************************************
*								         *
* FREEZE_PROCS - TAKE SELECT PROCESSES AND PUT THEM ON THE FREEZE LIST.	 *
* A0 = I.D. TO FREEZE							 *
* A1 = I.D. MASK (0 = DON'T CARE BITS)					 *
*								         *
**************************************************************************
FREEZE_PROCS
	MMTM	SP,A0,A2,A3,A5
	SEXT	A0		;SAFETY OP
	AND	A1,A0		;FORM MATCH
	MOVI	ACTIVE,A2	;SEARCH THE ACTIVE LIST
	MOVI	FREEZE,A5		;AND PUT THEM ON THIS FREEZE LIST
	CALLR	IP_LP
	MOVI	PACTIVE,A2
	MOVI	PFREEZE,A5
	CALLR	IP_LP
	MMFM	SP,A0,A2,A3,A5
	RETS

**************************************************************************
*								         *
* THAW_PROCS - REMOVE SELECT PROCESSES FROM THE FREEZE LIST.		 *
* A0 = I.D. TO THAW							 *
* A1 = I.D. MASK (0 = DON'T CARE BITS)					 *
*								         *
**************************************************************************
THAW_PROCS
	MMTM	SP,A0,A2,A3,A5
	SEXT	A0		;SAFETY OP
	AND	A1,A0		;FORM MATCH
	MOVI	FREEZE,A2		;SEARCH THE FREEZE LIST
	MOVI	ACTIVE,A5	;AND PUT THEM ON THIS ACTIVE LIST
	CALLR	IP_LP
	MOVI	PFREEZE,A2	;SEARCH THE PRIORITY FREEZE LIST
	MOVI	PACTIVE,A5	;AND PUT THEM ON THE PRIORITY ACTIVE LIST
	CALLR	IP_LP
	MMFM	SP,A0,A2,A3,A5
	RETS

*COMMON SUB LOOP FOR FREEZE AND THAW OF A PROCESS CLASS
IP_LP:
	MOVE	A2,A3		;SAVE PREVIOUS
	MOVE	*A2,A2,L	;GET NEXT
	JREQ	IP_X		;ALL DONE
	MOVE	*A2(PROCID),A14,W
	AND	A1,A14		;CAN DONT CARE BITS
	CMP	A0,A14		;MATCH?
	JRNE	IP_LP		;NO

	CMP	A2,A13		;IS THIS US?
	JREQ	IP_LP		;YES, WE CANNOT GO FREEZE

	MOVE	*A2,*A3,L	;LINK AROUND IN ACTIVE LIST
	MOVE	*A5,*A2,L	;LINK INTO FREEZE LIST HEAD
	MOVE	A2,*A5,L	;NEW FREEZE LIST START
	MOVE	A3,A2
	JRUC	IP_LP		;KILL THE REST
IP_X:
	RETS

**************************************************************************
*								         *
* EXISTP_ALL - CHECK FOR THE EXISTANCE OF A PROCESS OF A GIVEN PROCESS	 *
* 		I.D. OTHER THAN THE CALLING PROCESS.			 *
* A0 = PROCESS I.D.							 *
* RETURNS:								 *
* 	 Z = NO PROCESSES FOUND						 *
* 		A0 = 0							 *
* 	NZ = MATCHING PROCESS FOUND					 *
* 		A0 = PTR TO PROCESS					 *
*								         *
**************************************************************************
EXISTP_ALL
	PUSH	A1
	CLR	A1
	NOT	A1
	CALLR	EXISTP
	PULL	A1
	RETS

**************************************************************************
*FIND IF AT LEAST ONE PROCESS, OTHER THAN CALLING PROCESS,
*EXISTS.
*A0=PROCID (16 BITS) ,A1=MASK (16 BITS)
*MASK BITS OF ZERO ARE DONT CARES
*RETURNS:
* Z BIT SET = NO MATCH, A0 = 0
* Z BIT CLR = MATCH,	A0 = PTR TO PROCESS
*
EXISTP:	;*** CHECK BOTH LISTS ***
	MMTM	SP,A1,A2,A4
	SEXT	A0		;SAFETY OP
	AND	A1,A0		;FORM MATCH
	MOVI	ACTIVE,A2,L
	callr	EXNXT
	jrnz	FOUNDP
	MOVI	PACTIVE,A2,L
	callr	EXNXT
	JRNZ	FOUNDP
	MOVI	FREEZE,A2,L
	callr	EXNXT
	jrnz	FOUNDP
	MOVI	PFREEZE,A2,L
	callr	EXNXT
FOUNDP:
	MOVE	A2,A0
	MMFM	SP,A1,A2,A4
	RETS


PEXISTP: ;*** CHECK PRIORITY LIST ***
	MMTM	SP,A1,A2,A4
	AND	A1,A0		;FORM MATCH
	MOVI	PACTIVE,A2,L
	callr	EXNXT
	MOVE	A2,A0
	MMFM	SP,A1,A2,A4
	RETS


EXNXT:
	MOVE	*A2,A2,L	;GET NEXT
	JREQ	EXSC		;ALL DONE
	MOVE	*A2(PROCID),A4
	AND	A1,A4		;CAN DONT CARE BITS
	CMP	A0,A4		;MATCH?
	JRNE	EXNXT		;NO

	CMP	A2,A13		;CURRENT PROCESS?
	JREQ	EXNXT		;YES, THEN WE DON'T CARE
EXSC
	RETS
**************************************************************************


**************************************************************************
*								         *
* COUNT_PROCESSES - COUNT THE NUMBER OF PROCESSES OF A GIVEN I.D.	 *
* 		CURRENTLY ACTIVE  (BOTH LISTS).				 *
* COUNT_PACTIVE	- JUST PRIORITY					         *
* COUNT_ACTIVE	- JUST REGULAR					         *
* 		INCLUDES CALLING PROCESS IN COUNT, IF IT MATCHES.	 *
* A1 = PROCESS I.D. TO COUNT						 *
* RETURNS:								 *
* 	A0 = COUNT							 *
* 	Z BIT REFLECTS VALUE IN A0					 *
*								         *
**************************************************************************
COUNT_PROCESSES
	MMTM	SP,A2,A6
	MOVI	ACTIVE,A2
	CALLR	COUNT_PRCLIST
	MOVE	A0,A6
	MOVI	PACTIVE,A2
	CALLR	COUNT_PRCLIST
	ADD	A0,A6
	MOVI	FREEZE,A2
	CALLR	COUNT_PRCLIST
	ADD	A0,A6
	MOVI	PFREEZE,A2
	CALLR	COUNT_PRCLIST
	ADD	A6,A0
	MMFM	SP,A2,A6
	RETS

COUNT_PRCLIST
	CLR	A0		;CLEAR COUNT
	MOVE	A2,A2
	JRZ	CP_X		;BR = EMPTY
CP_LOOP
	MOVE	*A2(PROCID),A14,W
	CMP	A1,A14		;SHALL WE COUNT THIS ONE?
	JRNE	CP_NEXT		;BR = NO
	INC	A0		;TALLY ANOTHER
CP_NEXT
	MOVE	*A2,A2,L	;GET NEXT
	JRNE	CP_LOOP		;BR = DEFINITELY MORE TO DO
	MOVE	A0,A0
CP_X
	RETS


**************************************************************************
*GET A PRESERVED REGISTER FROM A SLEEPING PROCESS
*A0 = PTR TO SLEEPER
GETA11	move	*A0(PA11),A11,L
	RETS
GETA10	move	*A0(PA10),A10,L
	RETS
GETA9	move	*A0(PA9),A9,L
	RETS
GETA8	move	*A0(PA8),A8,L
	RETS
GETWAKE	move	*A0(PWAKE),A7,L
	RETS

GETREGS
	move	*A0(PA11),A11,L
	move	*A0(PA10),A10,L
	move	*A0(PA9),A9,L
	move	*A0(PA8),A8,L
	RETS

PUTA11	move	A11,*A0(PA11),L
	RETS
PUTA10	move	A10,*A0(PA10),L
	RETS
PUTA9	move	A9,*A0(PA9),L
	RETS
PUTA8	move	A8,*A0(PA8),L
	RETS

;*** PUTWAKE - FAST XFERPROC THAT DOESN'T CHANGE REGS (A8-A11) OF PROC ***
PUTWAKE	PUSH	A2
	move   	A7,*A0(PWAKE),L
	move	A0,A2
	addi	PRCSIZ,A2
	move	A2,*A0(PSPTR),L	;RESET PROCESS STACK POINTER
	clr	A2
	move	A2,*A0(PTIME),W
	PULLQ	A2
	RETS

PUTREGS
	move	A11,*A0(PA11),L
	move	A10,*A0(PA10),L
	move	A9,*A0(PA9),L
	move	A8,*A0(PA8),L
	RETS
**************************************************************************


**************************************************************************
*GET A LONG WORD FROM THE STACK OF A SLEEPING PROCESS
*A0 = PTR TO SLEEPING PROC
*A1 = OFFSET OF WORD FROM STACK POINTER
*A2 = CURRENT STACK PTR
*RETURN(S)
*A1 = LONG WORD
****GETSLW	PUSH	A2
****	MOVE	*A0(PSPTR),A2,L		;GET THE STACK POINTER
****	ADD	A1,A2			;ADD THE OFFSET
****	MOVE	*A2,A1,L		;MOVE IN THE LONG WORD
****	PULLQ	A2
****	RETS

*PUT A LONG WORD INTO THE STACK OF A SLEEPING PROCESS
*A0 = PTR TO SLEEPING PROC
*A1 = INDEX INTO STACK
*A2 = VALUE TO PUT
****PUTSLW	PUSH	A3
****	MOVE	*A0(PSPTR),A3,L		;GET THE STACK POINTER
****	ADD	A1,A3			;ADD THE OFFSET
****	MOVE	A2,*A3,L
****	PULLQ	A3
****	RETS

;*** CLEARS SLEEP TIME OF PROCESS IN A0 ***
WAKEUP:	PUSH	A1
	clr	A1
	move	A1,*A0(PTIME),W
	PULLQ	A1
	rets

**************************************************************************
*								         *
* OBJPROC_KILL - KILL PROCESS CONTROLLING AN OBJECT.			 *
* A8 = PTR TO OBJECT							 *
* NOTE: IF NO PROCESS IS ASSOCIATED, NOTHING IS DONE.			 *
*       YOU MUST USE SUCIDE IF YOU ARE THE CONTROLLING PROCESS.		 *
*								         *
**************************************************************************
OBJPROC_KILL:
	PUSH	A0
	MOVE	*A8(OPLINK),A0,L
	JRZ	OBJPROC_NOK
	CLRM	*A8(OPLINK),L		;WASTE THE OPLINK
	CALLR	KILL
OBJPROC_NOK:
	PULLQ	A0
	RETS

**************************************************************************
*								         *
* 	OBJPROC_KILL_MULTI						 *
* 									 *
* 	Kill controlling processes of all objects of a			 *
* 	multi-parter.							 *
* 									 *
* 	A8 = Ptr to part to start with.					 *
*								         *
**************************************************************************
OBJPROC_KILL_MULTI
	PUSH	A8
OKM_LOOP
	CALLR	OBJPROC_KILL
	MOVE	*A8(OPARTS),A8,L
	JRNZ	OKM_LOOP
	PULLQ	A8
	RETS

**************************************************************************
*                                                                        *
* OBJPROC_XFER - TRANSFER OBJECT CONTROL PROCESS TO NEW PROCESS		 *
* A1 = NEW PROC I.D.							 *
* A7 = NEW PROC ADDRESS							 *
* A8 = PTR TO OBJECT							 *
*                                                                        *
**************************************************************************
OBJPROC_XFER:
	PUSH	A0
	MOVE	*A8(OPLINK),A0,L
	JRZ	OBJPROC_XFERX
	CALLR	PUTWAKE
	MOVE	A1,*A0(PROCID),W
OBJPROC_XFERX:
	PULLQ	A0
	RETS

**************************************************************************
*								         *
* OBJPROC_INT - INTERRUPT THE PROCESS ASSOCIATED WITH THE GIVEN		 *
* 		OBJECT TRANFERRING EXECUTION TO A NEW ADDRESS.		 *
* 		THE CURRENT WAKEUP ADDRESS WILL BE PUSHED ONTO		 *
* 		THE PROCESS STACK SUITABLE FOR RETP.			 *
* A7 = PROCESS INTERRUPT VECTOR						 *
* A8 = PTR TO OBJECT							 *
* RETURNS:								 *
* 	 Z = NO PROCESS FOUND						 *
* 	NZ = INTERRUPT SUCCESSFULL					 *
*								         *
**************************************************************************
OBJPROC_INT:
	PUSH	A0
	MOVE	*A8(OPLINK),A0,L
	JRZ	OBJPROC_INT_X
	CALLR	PROC_INT
OBJPROC_INT_X
	PULL	A0
	RETS

**************************************************************************
*								         *
* SEND_COMM - SEND COMMUNICATION TO THIS PROCESS (VIA PCOMM).		 *
* A1 = SEND WORD							 *
* A11 = PTR TO RECEIVING PROCESS (IF = 0 THEN NO ACTION)		 *
* A13 = PTR TO SENDING PROCESS						 *
*								         *
**************************************************************************
SEND_COMM:
	MOVE	A11,A11	
	JRZ	SEND_COMM_X
	MOVE	A1,*A11(PCOMM),W
SEND_COMM_X:
	RETS

**************************************************************************
*								         *
* COMM_WAIT - WAIT FOR A COMMUNICATION FROM A PROCESS (VIA PCOMM).	 *
* A2 = WORD TO WAIT FOR							 *
* A3 = TIME OUT (IN TICKS)						 *
* A13 = PTR TO PROCESS WAITING FOR DATA					 *
* RETURNS:								 *
* 	 Z = COMMUNICATION RECIEVED					 *
* 	NZ = TIME OUT							 *
* NOTE: CALL WITH JSRP							 *
*								         *
**************************************************************************
COMM_WAIT:
	MMTM	A12,A8,A9
	MOVE	A2,A8
	MOVE	A3,A9
COMM_WAIT_LP:
	SLEEP	1
	MOVE	*A13(PCOMM),A2,W
	CMP	A2,A8
	JREQ	COMM_WAIT_X
	DSJS	A9,COMM_WAIT_LP
	CLRZ
COMM_WAIT_X:
	MMFM	A12,A8,A9
	RETP

**************************************************************************
*								         *
* COMM_WAIT_REMOTE - WAIT FOR A COMMUNICATION FROM A REMOTE PROCESS	 *
*			(VIA PCOMM).					 *
* A2 = WORD TO WAIT FOR							 *
* A3 = TIME OUT (IN TICKS)						 *
* A11 = PTR TO REMOTE PROCESS 						 *
* RETURNS:								 *
* 	 Z = COMMUNICATION RECIEVED					 *
* 	NZ = TIME OUT							 *
* NOTE: CALL WITH JSRP							 *
*								         *
**************************************************************************
COMM_WAIT_REMOTE:
	MMTM	A12,A8,A9
	MOVE	A2,A8
	MOVE	A3,A9
CWR_LP:
	SLEEP	1
	MOVE	*A11(PCOMM),A2,W
	CMP	A2,A8
	JREQ	CWR_X
	DSJS	A9,CWR_LP
	CLRZ
CWR_X:
	MMFM	A12,A8,A9
	RETP

**************************************************************************
*								         *
* SEND_COMM_WAIT - SEND COMMUNICATION AND WAIT FOR A REPLY.		 *
* A1 = DATA TO SEND							 *
* A2 = DATA TO WAIT FOR							 *
* A3 = TIME OUT ON WAIT							 *
* A11 = PTR TO RECEIVING PROCESS 					 *
* A13 = PTR TO SENDING PROCESS						 *
* RETURNS								 *
* 	 Z = DATA SENT, REPLY RECEIVED					 *
* 	NZ = TIME OUT ERROR						 *
* NOTE: CALL WITH JSRP							 *
*								         *
**************************************************************************
SEND_COMM_WAIT:
	CALLR	SEND_COMM
	JSRP	COMM_WAIT
	RETP

	.END
