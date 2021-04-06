	.MLIB	"GXMACS.LIB"
	.FILE	"GXDRIVER.ASM"
	.TITLE	"<<< GENERATION X ---- COIL AND FLASH LAMP DRIVERS >>>"
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


***** from GXRAM.ASM
	.REF	GUNS_OFF

**************************************************************************
*								         *
* 		      COIL & LED DRIVER DESCRIPTION			 *
* 		      -----------------------------			 *
* 									 *
* 	Currently the system supports N_COILS coils and LEDs.		 *
* 	They are driven via the X-Unit coil latch.			 *
* 									 *
* 	You may fire a coil for 1 to 253 ticks.  The Routine		 *
* 	COIL_DRIVE handles this.  Sending a time of 255 (FFh)		 *
* 	turns the coil on until turned off.  A time of 254 (FEh)	 *
* 	turns the coil off.						 *
* 									 *
* 	The routine DRIVER_UPDATE must be called from the Display	 *
* 	interrupt every 16msecs.  Call before switches have		 *
* 	been scanned and after TIMER has been incremented. 		 *
* 									 *
* 	LEDs are treated the same as coils.				 *
* 									 *
* 									 *
* 	COIL & LED ASSIGNMENTS:						 *
* 									 *
* 		BIT 0	-	PLAYER 1 GUN COIL			 *
* 		BIT 1	-	PLAYER 2 GUN COIL			 *
* 		BIT 2	-	PLAYER 3 GUN COIL			 *
* 		BIT 3	-	Unused					 *
* 		BIT 4	-	PLAYER 1 LEDs				 *
* 		BIT 5	-	PLAYER 2 LEDs				 *
* 		BIT 6	-	PLAYER 3 LEDs				 *
* 		BIT 7	-	Unused					 *
* 									 *
* 	Rev. 3/5/94							 *
*								         *
**************************************************************************

N_COILS	.EQU	8
COIL_TIME	.EQU	0	;UHW Remaining coil time
COIL_TIME_OFF	.EQU	10H	;UHW Time coil has been off
COIL_SIZE	.EQU	20H	;Size of coil data area
COIL_MULT	.EQU	5	;Shift for multiply of index

COIL_LATCH	.EQU	AUX_PORT	;YEAH!

COIL_STROBE	.EQU	0400H	;STROBE FOR COIL LATCH
COIL_OFF_TIME	.EQU	0FEH	;TIME VALUE TO TURN A COIL OFF NOW
COIL_ON_TIME	.EQU	0FFH	;TIME VALUE TO KEEP A COIL ON

LED_MASK	.EQU	0F0H	;MASK FOR LED BITS
LED_START	.EQU	4

DEADMAN_TICKS .EQU	30	;Refresh "Dead man" at this tick interval

COILS_ON	.EQU	1	;If 1 then writes to the coil latch are allowed


*
* Coil RAM
*
	.BSS	COIL_RAM,N_COILS*COIL_SIZE	;STORAGE FOR COIL PROCESSING
	.BSS	COIL_END,0
	.BSS	COIL_COPY,16		;Copy of current COIL_LATCH
	.BSS	DEADMAN_UPDATE_COUNT,16	;"Dead man" circuit refresh count.
	.BSS	DRIVER_SWTEMP1,32	;Switch debounce storage for Driver
	.BSS	DRIVER_SWTEMP2,32	;Switch debounce storage for Driver

	.TEXT

**************************************************************************
*								         *
* 	DRIVER_CLR							 *
* 									 *
* 	Clear Coil and LED data base, and turn all coils and LEDs off.	 *
*								         *
**************************************************************************
DRIVER_CLR
	PUSH	A1
	PUSHST
	DINT				;Disable interrupts on writes

	MOVKM	DEADMAN_TICKS,@DEADMAN_UPDATE_COUNT,W

	MOVI	COIL_RAM,A1
	CLR	A14
DC_LP
	MOVE	A14,*A1+,L
	CMPI	COIL_END,A1
	JRLO	DC_LP

	NOT	A14
	MOVE	A14,@DRIVER_SWTEMP1,L
	MOVE	A14,@DRIVER_SWTEMP2,L	;Clear the switch debounce

	MOVI	0FF00H|LED_MASK,A1
	MOVE	A1,@COIL_COPY,W	

	POPST

	CLR	A1
	NOT	A1
	CALLR	COIL_OFF

	PULLQ	A1
	RETS

**************************************************************************
*								         *
* 	DRIVER_UPDATE							 *
* 									 *
* 	Update all Coil and LED timings.  This is called from the	 *
* 	display interrupt.  So anything that messes with the timing	 *
* 	RAM needs to shut interrupts down.				 *
* 									 *
* 	Player guns are driven from here directly, by reading the	 *
* 	debounced switches.  This will get rid of that nasty bog.	 *
* 									 *
* 	Note: Make sure this is called before SWSCAN			 *
* 									 *
* 	Note: Assume all A-file registers trashed.			 *
*								         *
**************************************************************************
DRIVER_UPDATE
;	MOVE	@LAST_TIMER,A4,W
;	CALLR	COIL_UPDATE

	MOVI	COIL_RAM,A2
	CLR	A1			;COIL BITS TO TURN OFF THIS PASS
	MOVK	1,A0			;Walking bit for turn off mask
	MOVI	N_COILS,A3		;TOTALLY PAULY

	CLR	A6			;Coil bits to turn on this pass

	MOVI	P1DATA,A4		;We will check player firing as we go
	MOVE	@NPLAYERS,A5,W

	MOVE	@SWITCH,A8,W
	MOVE	@SWITCH2,A14,W
	SLL	16,A14
	MOVY	A14,A8			;Current switch state

	MOVE	@DRIVER_SWTEMP1,A9,L	;Previous switches (t = n-1)
	MOVE	@DRIVER_SWTEMP2,A10,L	;Previous previous switches (t = n-2)
	MOVE	A9,@DRIVER_SWTEMP2,L	;New t = n-2
	MOVE	A8,@DRIVER_SWTEMP1,L	;New t = n-1

	MOVE	@GUN_ONE_SHOT,A14,W
	JRZ	DU_RAPID_GUNS		;BR = We are in rapid fire mode

	AND	A10,A9
	NOT	A9
	JRUC	DU_MAKE_DEBOUNCED

DU_RAPID_GUNS
	XOR	A10,A9
DU_MAKE_DEBOUNCED
	OR	A9,A8			;Anything that's zero is good

	MOVK	4,A9			;This is the first switch to test

	MOVE	@GAME_STATE,A14,W
	CMPI	INEPILOG,A14
	JREQ	DU_STATE_OK
	CMPI	INPLAY,A14
	JRNE	DU_NO_GUNS		;BR = Not in play, no guns

DU_STATE_OK
	MOVE	@PAUSE_GAME,A14,W	;GAME PAUSED?
	JRNZ	DU_NO_GUNS		;BR = Game is paused, no guns

	MOVE	@GUNS_OFF,A14,W
	JREQ	CU_LP			;BR = O.K. To fire guns

DU_NO_GUNS
	CLR	A5
	NOT	A5			;Force the gun trigger reads off

CU_LP
	MOVE	*A2(COIL_TIME),A14,W
	JRNZ	CU_CK_OFF		;BR = Coil on, see if time to turn off

	MOVE	A5,A5
	JRN	DU_NOT_PLAYER		;BR = This is not a valid player coil

	MOVE	*A4(POBJ),A14,L
	JRZ	DU_NOT_PLAYER		;BR = Player not playing

	BTST	A9,A8
	JRNZ	DU_NOT_PLAYER		;BR = Player's trigger is not pulled

	MOVE	*A2(COIL_TIME_OFF),A7,W
	INC	A7

	MOVE	*A4(PGUNOFFTIME),A14,W
	CMP	A14,A7
	JRLO	DU_MORE_TIME_OFF	;BR = Gun has not been off long enuff

	CLR	A7

	MOVKM	GUN_COIL_ON,*A2(COIL_TIME),W	;Time to drive the coil again

	OR	A0,A6			;Set bit to turn on

DU_MORE_TIME_OFF
	MOVE	A7,*A2(COIL_TIME_OFF),W
	JRUC	CU_NEXT

DU_NOT_PLAYER
	INCM	*A2(COIL_TIME_OFF),W	;Bump the off time
	JRUC	CU_NEXT
CU_CK_OFF
	CMPI	COIL_ON_TIME,A14
	JREQ	CU_NEXT			;BR = Coil on constantly

;	SUB	A4,A14			;DECREMENT THE TIMER
	DEC	A14
	JRGT	CU_STORE		;BR = Not time to turn off, yet.
	OR	A0,A1
	CLR	A14			;Clear for good measure
	MOVE	A14,*A2(COIL_TIME_OFF),W ;Clear off-time counter
CU_STORE
	MOVE	A14,*A2,W
CU_NEXT
	ADDI	COIL_SIZE,A2		;GET TO THE NEXT
	SLL	1,A0			;Next bit
	ADDI	PDSIZE,A4		;Next player data area
	DEC	A5			;One less player to check
	ADDK	8,A9			;This is our switch bit test
	DSJ	A3,CU_LP		;Do another

	MOVE	A6,A6
	JRNZ	DU_CHANGE_EM		;BR = Something to change

	MOVE	A1,A1
	JRZ	DU_CHECK_THE_DEAD	;BR = No coils turned off

DU_CHANGE_EM
	MOVI	COIL_STROBE,A3

	MOVE	A1,A2
	SLL	28,A1
	SRL	28,A1			;These are the coil bits
	SLL	24,A2			
	SRL	28,A2
	SLL	4,A2			;These are the LED bits

	MOVE	@COIL_COPY,A0,W
	ANDN	A1,A0			;Turn off the Coils this way
	OR	A2,A0			;Turn off the LEDs this way, Thanx Cary
	OR	A6,A0			;Turn on anything that needs it
	MOVE	A0,@COIL_COPY,W		;Keep a copy for us

	JRUC	DU_BANG_HARDWARE

DU_CHECK_THE_DEAD
	MOVE	@DEADMAN_UPDATE_COUNT,A14,W
	DEC	A14
	MOVE	A14,@DEADMAN_UPDATE_COUNT,W
	JRGT	DU_X			;BR = Not time to down a protective strobe

	MOVI	COIL_STROBE,A3
	MOVE	@COIL_COPY,A0,W

DU_BANG_HARDWARE
	OR	A3,A0
	.IF COILS_ON
	MOVE	A0,@COIL_LATCH,W
	.ENDIF

	MOVI	8,A14
	DSJS	A14,$			;GIVE STROBE TIME TO CATCH

	ANDN	A3,A0			;LOWER YOUR STROBE FOR ACTION
	.IF COILS_ON
	MOVE	A0,@COIL_LATCH,W
	.ENDIF

DU_ALIVE
	MOVKM	DEADMAN_TICKS,@DEADMAN_UPDATE_COUNT,W

DU_X
	RETS

**************************************************************************
*								         *
* COIL_DRIVE - ROUTINE TO TURN ON A COIL FOR THE GIVEN AMOUNT OF TICKS	 *
* A0 = [ON TIME, COIL #]						 *
*								         *
**************************************************************************
COIL_DRIVE
	MMTM	SP,A0,A1,A2
	MOVY	A0,A2
	ZEXT	A0
	.IF DEBUG
	CMPK	N_COILS,A0		;IS THIS A VALID COIL #
	JRHS	$			;BR = NO
	.ENDIF
	CLR	A1
	BSET	A0,A1
	SRL	16,A2
	CMPI	COIL_OFF_TIME,A2	;FORCE THE COIL OFF?
	JRNE	CD_ON			;BR = NO
     	CALLR	COIL_OFF
	CLR	A2
	JRUC	CD_STORE
CD_ON
	CALLR	COIL_ON
CD_STORE
	SLL	COIL_MULT,A0		;Get timing structure for this coil
	ADDI	COIL_RAM,A0
	PUSHST
	DINT
	MOVE	A2,*A0(COIL_TIME),W	;SET THE TIME
	CLR	A2
	MOVE	A2,*A0(COIL_TIME_OFF),W	;Reset off time
	POPST
CD_X
	MMFM	SP,A0,A1,A2
	RETS

**************************************************************************
*								         *
* COIL_ON - TURN COIL(S) ON.  COPY OF COIL LATCH STORED			 *
* 	      AT LOCATION COIL_COPY.					 *
* A1 = COIL BITS TO TURN ON						 *
*								         *
**************************************************************************
COIL_ON
	MMTM	SP,A0,A2,A3

*THESE EXTRA STEPS ARE TO CORRECT THE CARY MEDNICK BRAIN DAMAGE.
*THE LEDs EXIST IN THE HIGH FOUR BITS OF THE COIL LATCH. BUT
*THEIR LOGIC IS NEGATIVE!
	MOVE	A1,A2
	SLL	28,A1
	SRL	28,A1			;KEEP ONLY THE COILS
	SLL	24,A2
	SRL	28,A2
	SLL	4,A2			;ISOLATE THE LEDs

	MOVI	COIL_STROBE,A3

	PUSHST
	DINT				;Away with the interrupts

	MOVE	@COIL_COPY,A0,W
	OR	A1,A0			;ADD THE COILS WE NEED
	ANDN	A2,A0			;NOW THE LEDs
	OR	A3,A0			;MAKE SURE STROBE IS UP
	MOVE	A0,@COIL_COPY,W
	.IF COILS_ON
	MOVE	A0,@COIL_LATCH,W	;HIT COILS
	.ENDIF

	MOVI	8,A14
	DSJS	A14,$			;GIVE STROBE TIME TO CATCH

	ANDN	A3,A0			;FALLING EDGE TRIGGERS THE EVENT
	.IF COILS_ON
	MOVE	A0,@COIL_LATCH,W
	.ENDIF
	POPST

	MMFM	SP,A0,A2,A3
	RETS

**************************************************************************
*								         *
* COIL_OFF - TURN COIL(S) OFF.  COPY OF COIL LATCH STORED		 *
* 	      AT LOCATION COIL_COPY.					 *
* A1 = COIL BITS TO TURN OFF						 *
*								         *
**************************************************************************
COIL_OFF
	MMTM	SP,A0,A2,A3

	MOVE	A1,A2
	SLL	28,A1
	SRL	28,A1			;KEEP ONLY THE COILS
	SLL	24,A2			;ROUTING CARY BRAIN DAMAGE
	SRL	28,A2
	SLL	4,A2			;ISOLATE THE LEDs

	MOVI	COIL_STROBE,A3

	PUSHST
	DINT  				;Off Oh Mighty interrupts

	MOVE	@COIL_COPY,A0,W
	ANDN	A1,A0			;Off with the coils
	OR	A2,A0			;Off with the LEDs
	MOVE	A0,@COIL_COPY,W

	OR	A3,A0			;Strobe high

	.IF COILS_ON
	MOVE	A0,@COIL_LATCH,W	;HIT COILS
	.ENDIF

	MOVI	8,A14
	DSJS	A14,$			;GIVE STROBE TIME TO CATCH

	ANDN	A3,A0			;Strobe low

	.IF COILS_ON
	MOVE	A0,@COIL_LATCH,W
	.ENDIF

	POPST

	MMFM	SP,A0,A2,A3
	RETS


	.END
