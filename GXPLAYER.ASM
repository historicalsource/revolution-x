	.MLIB	"GXMACS.LIB"
	.FILE	"GXPLAYER.ASM"
	.TITLE	"<<< GENERATION X ---- PLAYER UTILITY ROUTINES >>>"
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

***** In THIS file

	.DEF	A_CK_FLSH_HIT, ANY_BOMBS, GET_PLAYER_EXTENTS
	.DEF	GET_PLAYER_WORLDX_EXTENTS, VALID_PLAYER, PLAYER_AWARD_GIRL
	.DEF	P_LED_ON, P_LED_OFF

*SYMBOLS IN GX.ASM
	.REF	GPLAYD, LAST_PRAISE, ARNOLD_SPEAK
*SYMBOLS IN GXSCORE.ASM
	.REF	SUBLIFE, FLASH_PSTATUS
*SYMBOLS IN GXGUN.ASM
	.REF	ENEMYP_COLL
***** from GXRAM.ASM
	.REF	BASE_HIT

	.TEXT

**************************************************************************
*								         *
* 	P_LED_ON							 *
* 									 *
* 	Turn players LED on.						 *
* 									 *
* 	A2 = Ptr to player data area					 *
*								         *
**************************************************************************
P_LED_ON
	PUSH	A0
	CALLA	GPLAYNUM
	SLL	3,A0
	ADDI	TAB_P_LEDS,A0
	MOVB	*A0,A0
	
	ADDI	[0FFH,0],A0
	CALLA	COIL_DRIVE

	PULLQ	A0
	RETS

**************************************************************************
*								         *
* 	P_LED_OFF							 *
* 									 *
* 	Turn players LED off.						 *
* 									 *
* 	A2 = Ptr to player data area					 *
*								         *
**************************************************************************
P_LED_OFF
	PUSH	A0
	CALLA	GPLAYNUM
	SLL	3,A0
	ADDI	TAB_P_LEDS,A0
	MOVB	*A0,A0
	
	ADDI	[0FEH,0],A0
	CALLA	COIL_DRIVE

	PULLQ	A0
	RETS

TAB_P_LEDS
	.BYTE	P1_LED, P2_LED, P3_LED, P3_LED

**************************************************************************
*								         *
* 	VALID_PLAYER							 *
* 									 *
* 	Check to see if player pointer is valid. Locks on a		 *
* 	non-valid player pointer.  Used for debug.			 *
* 									 *
* 	A2 = Ptr to player						 *
*								         *
**************************************************************************
VALID_PLAYER
	CMPI	P1DATA,A2
	JREQ	VP_X
	CMPI	P2DATA,A2
	JREQ	VP_X
	CMPI	P3DATA,A2
	LOCKON	NE
VP_X
   	RETS

**************************************************************************
*								         *
* 	PLAYER_AWARD_GIRL						 *
* 									 *
* 	Award a girl to the player for bonus.				 *
* 									 *
* 	A2 = Ptr to player						 *
*								         *
**************************************************************************
PLAYER_AWARD_GIRL
	MOVE	A2,A2
	JRZ	PAG_X			;BR = A non-player
	INCM	*A2(PGIRLS_SAVED),W	;Give him another
PAG_X
	RETS

**************************************************************************
*								         *
* 	GET_PLAYER_EXTENTS						 *
* 									 *
* 	Return the area of the screen, in screen coords, that		 *
* 	encompasses all of the active players hit boxes.		 *
* 									 *
* 	Returns:							 *
* 		A2 = UL [Y,X]						 *
* 		A3 = LR [Y,X]						 *
*								         *
**************************************************************************
GET_PLAYER_EXTENTS
	MMTM	SP,A4,A6
	MOVI	[SCRBOT,SCRRGT],A2	;Initialize the returns
	CLR	A3

	MOVI	P1DATA,A4
	MOVI	MAXPLAYERS,A6
GPE_LOOP
	MOVE	*A4(POBJ),A14,L
	JRZ	GPE_NEXT
	MOVE	*A4(PHITBOXUL),A14,L	;First check Upper Left
	CMPXY	A14,A2			;Check against what we've got
	JRXLE	GPE_CK_UL_U		;BR = Left boundry is already O.K.
	MOVX	A14,A2			;Give us the new Left
GPE_CK_UL_U
	JRYLE	GPE_CK_LR		;BR = Upper boundry is already O.K.
	MOVY	A14,A2			;Give us the new Upper
GPE_CK_LR
	MOVE	*A4(PHITBOXLR),A14,L	;Now check Lower Right
	CMPXY	A14,A3	   		
	JRXGE	GPE_CK_LR_L		;BR = Right boundry is already O.K.
	MOVX	A14,A3			;Set new Right
GPE_CK_LR_L
	JRYGE	GPE_NEXT		;BR = Lower boundry is already O.K.
	MOVY	A14,A3			;Set new Lower
GPE_NEXT
	ADDI	PDSIZE,A4
	DSJ	A6,GPE_LOOP
	MMFM	SP,A4,A6
	RETS

**************************************************************************
*								         *
* 	GET_PLAYER_WORLDX_EXTENTS					 *
* 									 *
* 	Return the X area of the screen, in WORLD coords, that		 *
* 	encompasses all of the active players hit boxes.		 *
* 									 *
* 	Returns:							 *
* 		A0 = LEFT WORLD X					 *
* 		A1 = RIGHT WORLD X					 *
*								         *
**************************************************************************

P1_LWX2		EQU	LEFT_WORLDX
P1_RWX2		EQU	LEFT_WORLDX+(RGHT_WORLDX-LEFT_WORLDX)/2
P2_LWX2		EQU	LEFT_WORLDX+(RGHT_WORLDX-LEFT_WORLDX)/2
P2_RWX2		EQU	RGHT_WORLDX	

P1_LWX3		EQU	LEFT_WORLDX
P1_RWX3		EQU	LEFT_WORLDX+(RGHT_WORLDX-LEFT_WORLDX)/3	
P2_LWX3		EQU	LEFT_WORLDX+(RGHT_WORLDX-LEFT_WORLDX)/3	
P2_RWX3		EQU	LEFT_WORLDX+(RGHT_WORLDX-LEFT_WORLDX)*2/3
P3_LWX3		EQU	LEFT_WORLDX+(RGHT_WORLDX-LEFT_WORLDX)*2/3
P3_RWX3		EQU	RGHT_WORLDX
	
GET_PLAYER_WORLDX_EXTENTS
	MMTM	SP,A2,A3,A4,A6,A7
	MOVI	RGHT_WORLDX,A0
	MOVI	LEFT_WORLDX,A1

	MOVI	P1DATA,A4
	MOVI	MAXPLAYERS,A6
	MOVE	@NPLAYERS,A6,W
	INC	A6
	MOVI	PLAYER3_WORLDX_TABLE,A7
	CMPK	3,A6
	JREQ	GPWXE_LOOP
	MOVI	PLAYER2_WORLDX_TABLE,A7
GPWXE_LOOP
	MOVE	*A7+,A2,L		;LEFT WORLD X
	MOVE	*A7+,A3,L		;RIGHT WORLD X
	MOVE	*A4(POBJ),A14,L
	JRZ	GPWXE_NEXT
	CMP	A0,A2
	JRGE	GPWXE_CK_R		;BR = Left boundry is already O.K.
	MOVE	A2,A0			;Give us the new Left
GPWXE_CK_R
	CMP	A1,A3
	JRLE	GPWXE_NEXT		;BR = Right boundry is already O.K.
	MOVE	A3,A1			;Set new Right
GPWXE_NEXT
	ADDI	PDSIZE,A4
	DSJ	A6,GPWXE_LOOP
	MMFM	SP,A2,A3,A4,A6,A7
	RETS

PLAYER2_WORLDX_TABLE
	.LONG	P1_LWX2, P1_RWX2, P2_LWX2, P2_RWX2

PLAYER3_WORLDX_TABLE
	.LONG	P1_LWX3, P1_RWX3, P2_LWX3, P2_RWX3, P3_LWX3, P3_RWX3

**************************************************************************
*								         *
* 	ANY_BOMBS							 *
* 									 *
* 	This will tell you if any active players have any of their	 *
* 	special weapons left (i.e. Rockets, CDs, Shotguns)		 *
* 									 *
* 	Returns:							 *
* 		 Z = No specials to be found				 *
* 		NZ = Someone still has something			 *
*								         *
**************************************************************************
ANY_BOMBS
	MMTM	SP,A2,A3,A6

	CLR	A3			;Accumulate here

	MOVI	P1DATA,A2
	MOVI	MAXPLAYERS,A6		;This many players possible
AB_LOOP
	MOVE	*A2(POBJ),A14,L		;Is this player active?
	JRZ	AB_NEXT			;BR = No, then don't check

	ADDM	*A2(PBOMB1),A3,W	;Add his counts
	ADDM	*A2(PBOMB2),A3,W

AB_NEXT
	ADDI	PDSIZE,A2		;Next player
	DSJ	A6,AB_LOOP		;If there is one

	MOVE	A3,A3			;Tell us what you found

	MMFM	SP,A2,A3,A6
	RETS

**************************************************************************
*								         *
* PCURSOR_OFF - TURN THE PLAYERS CURSOR "OFF"				 *
* A2 = PTR TO PDATA							 *
*								         *
**************************************************************************
PCURSOR_OFF
	PUSH	A8
	MOVE	*A2(POBJ),A8,L
	JRZ	PO_X
	CALLA	OBJ_OFF	
PO_X
	PULLQ	A8
	RETS

**************************************************************************
*								         *
* SUB_ENERGY - SUBTRACT PLAYER ENERGY. SETS THE PDEAD FLAG IF IT	 *
* 		IS REQUIRED.						 *
* A0 = AMOUNT OF ENERGY TO SUBTRACT					 *
* A2 = PTR TO PLAYER							 *
*								         *
**************************************************************************
SUB_ENERGY
	MOVE	*A2(POBJ),A14,L		;IS HE EVEN ALIVE?
	JRZ	SE_X			;BR = NO
	CALLA	SUBLIFE
	JRNC	SE_X
	MOVKM	1,*A2(PDEAD),W		;DOINK THE PLAYER
SE_X
	RETS

**************************************************************************
*								         *
* DELAYED_PRAISE - ROUTINE TO CREATE A DELAYED PLAYER PRAISE		 *
*								         *
**************************************************************************
DELAYED_PRAISE
	MMTM	SP,A0,A1,A7
	CREATE	PID_IND,PRAISE_PROC
	MMFM	SP,A0,A1,A7
	RETS

**************************************************************************
*								         *
* PRAISE_PROC - PROCESS TO SLEEP THEN CALL PRAISE TO A PLAYER.		 *
*								         *
**************************************************************************
PRAISE_PROC
	SLEEP	60
	CALLR	PLAYER_PRAISE
	DIE

**************************************************************************
*								         *
* PLAYER_PRAISE - ROUTINE TO PRAISE THE PLAYER WITH ARNOLD SPEECH	 *
* 		AND FRIEND CHEERS.					 *
*								         *
**************************************************************************
PLAYER_PRAISE
	MMTM	SP,A0,A5,A9

	MOVE	@LAST_PRAISE,A14,L
	JRZ	PP_DOIT

	MOVE	@WAVETIME,A0,L
	SUB	A14,A0
	CMPI	200,A0				;BEEN THIS LONG SINCE LAST
	JRHI	PP_DOIT				;BR = YES
	JRUC	PP_X

PP_DOIT
	MOVE	@WAVETIME,@LAST_PRAISE,L	;WE'RE DOIN' IT NOW
	CLRM	@PRAISE_FLAG,W

	MOVE	@ARNOLD_SPEAK,A9,W

PCB_PRAISE_RESET
	MOVK	8,A5

PCB_TRY_PRAISE_AGAIN
	MOVK	NUM_PRAISES,A0		;Do a little praising
	CALLA	RAND0

	BTST	A0,A9			;Have we praised this yet?
	JRZ	PCB_PRAISE_OK		;BR = No

	DSJS	A5,PCB_TRY_PRAISE_AGAIN
*
* Here we have failed to randomly praise, we'll just select
*
	MOVK	NUM_PRAISES,A5
	CLR	A0			;Walk down praise list until we get one
PCB_WALK_PRAISE
	BTST	A0,A9			;Is this a good one?
	JRZ	PCB_PRAISE_OK		;BR = Yes, then use it
	INC	A0			;Next
	DSJS	A5,PCB_WALK_PRAISE

* We've done them all, so start over

	CLR	A9
	JRUC	PCB_PRAISE_RESET

PCB_PRAISE_OK
	BSET	A0,A9			;Flag this as praised

	MOVE	A9,@ARNOLD_SPEAK,W

PCB_DO_PRAISE
	SLL	5,A0
	ADDI	PRAISE_TABLE,A0
	MOVE	*A0,A0,L		;Grab the proper phrase
	CALLA	ONESND			;And sound it

PP_X
	MMFM	SP,A0,A5,A9
	RETS

*SPEECH CALLS FOR ACKNOWLEDGMENT OF COOL ACTIONS
NUM_PRAISES	.EQU	7

PRAISE_TABLE
	.LONG	SND_PP1, SND_PP2, SND_PP3, SND_PP4, SND_PP5, SND_PP6, SND_PP7

SND_PP1
	.WORD	0F3D0H,41,08818H,0	;"Awesome"
SND_PP2
	.WORD	0F3D0H,58,08817H,0	;"Way to go"
SND_PP3
	.WORD	0F3D0H,54,08816H,0	;"Yeah!"
SND_PP4
	.WORD	0F3D0H,56,0881AH,0	;"Alright!"
SND_PP5
	.WORD	0F3D0H,69,08812H,0	;"Good shot"
SND_PP6
	.WORD	0F3D0H,67,08813H,0	;"Nice shot"
SND_PP7
	.WORD	0F3D0H,61,08814H,0	;"Great shot"


**************************************************************************
*								         *
* POID_TO_PDATA - ROUTINE TO RETURN THE CORRECT PLAYER DATA AREA	 *
* 		GIVEN AN OID.						 *
* A0 = OID TO CONVERT							 *
* RETURNS								 *
* 	A2 = PLAYER DATA, IF BOGUS, THEN A2 = 0 AND Z SET.		 *
*								         *
**************************************************************************
POID_TO_PDATA
	PUSH	A0
	SLL	SL_POID,A0
	SRL	SR_POID,A0
	DEC	A0
	JRNN	PTP_CALL
	PULLQ	A0
	CLR	A2
	RETS
PTP_CALL
	CALLA	GPLAYD
	PULLQ	A0
	RETS

**************************************************************************
*								         *
* GET_POID - GET THE CORRECT PLAYER OID BASED ON PLAYER DATA PTR.	 *
* A2 = PTR TO PLAYER DATA AREA (IF NULL, OID_JUNK IS PASSED BACK)	 *
* RETURNS:								 *
* 	A0 = OID							 *
*								         *
**************************************************************************
GET_POID
	MOVE	A2,A2			;DID WE GET VALIDITY?
	JRNZ	GP_IS_COOL		;BR = YES
	MOVI	OID_JUNK,A0		;JUST PASS BACK THE JUNKSTER
	RETS
GP_IS_COOL
	CALLA	GPLAYNUM
	SLL	4,A0
	ADDI	PLAYER_OID_TAB,A0
	MOVE	*A0,A0,W
	RETS

*
*TABLE OF PLAYER OIDs
*
PLAYER_OID_TAB
	.WORD	OID_P1,OID_P2,OID_P3

**************************************************************************
*								         *
* START_INVINCIBILITY - ROUTINE TO START THE PLAYER INVINCIBILITY PROCES *
* A2 = PTR TO THE PLAYER DATA AREA					 *
* A10 = INVINCIBILITY TIME						 *
* NOTE: TRASHES A14							 *
*								         *
**************************************************************************
START_INVINCIBILITY
	MOVE	*A2(PINVINCIBLE),A14,W	;GET CURRENT INVINCIBLE TIME
	ADD	A10,A14
	CMPI	1000,A14		;HAS IT TOPPED OUT?
	JRLS	SI_NOTOP		;BR = NO
	MOVI	1000,A14		;LEVEL IT OFF
SI_NOTOP
	MOVE	A14,*A2(PINVINCIBLE),W
	RETS

**************************************************************************
*								         *
* A_CK_FLSH_HIT - ANIM FUNC TO CHECK IF A GUN FLASH HIT A PLAYER.	 *
* A8 = PTR TO GUN FLASH							 *
* AARG+,L = [INT,FRAC] ENERGY POINTS TO SUBTRACT			 *
*								         *
**************************************************************************
A_CK_FLSH_HIT
	CALLA	GETAFARG_LONG
	MOVE	A0,A5

**************************************************************************
*								         *
* CK_GFLASH_HIT - ROUTINE TO CHECK IF A GUN FLASH HIT ANY PLAYER.	 *
* A5 = # OF ENERGY POINTS TO SUBTRACT [INT,FRAC]			 *
* A8 = PTR TO ENEMY OBJECT						 *
* RETURNS:								 *
* A2 = PDATA OF PLAYER HIT						 *
* 	 Z = NO HIT SCORED						 *
* 		C = No hit because shot was offscreen or blocked	 *
* 	       NC = No hit because he plain missed			 *
* 	NZ = HIT SCORED							 *
* NOTE: TRASHES A14							 *
*								         *
**************************************************************************
CK_GFLASH_HIT
	MMTM	SP,A1,A3,A6,A7

	CLR	A6			;CLEAR HIT COUNTER

	MOVE	*A8(OXVAL),A3,L
	MOVE	*A8(OYVAL),A7,L
	MOVE	*A8(OZVAL),A2,L		;Z UNIVERSE

	jruc	CPH_hook

**************************************************************************
*								         *
* 	A_CK_PHIT							 *
* 									 *
* 	Anim func to check if an enemy object hit a player		 *
* 									 *
* 	A8 = Ptr to enemy object					 *
* 	AARG+,L = [Y,X] screen firing offset				 *
* 	AARG+,L = Hit point amount to add to BASE_HIT			 *
*								         *
**************************************************************************
A_CK_PHIT
	CALLA	GETAFARG_LONG
	MOVE	A0,A3
	CALLA	GETAFARG_LONG
	MOVE	@BASE_HIT,A5,W
	SLL	4,A5

;	MOVE	A0,A5
	ADD	A0,A5

	JRUC	CK_PLAYER_HIT

**************************************************************************
*								         *
* CK_PLAYER_HIT - ROUTINE TO CHECK IF AN ENEMY OBJECT HIT ANY PLAYER.	 *
* A3 = [Y,X] SCREEN FIRING OFFSET (IF ZERO, DAG MUST BE SET)		 *
* A5 = # OF ENERGY POINTS TO SUBTRACT [INT,FRAC]			 *
* A8 = PTR TO ENEMY OBJECT						 *
* RETURNS:								 *
* A2 = PDATA OF PLAYER HIT						 *
* 	 Z = NO HIT SCORED						 *
* 		C = No hit because shot was offscreen or blocked	 *
* 	       NC = No hit because he plain missed			 *
* 	NZ = HIT SCORED							 *
* NOTE: TRASHES A14							 *
*								         *
**************************************************************************
CK_PLAYER_HIT
	MMTM	SP,A1,A3,A6,A7

	CLR	A6			;CLEAR HIT COUNTER

	MOVE	A3,A7
	JRNZ	CPH_TRANSLATE		;BR=OFFSET NON-ZERO, TRANSLATE
	MOVE	*A8(ODAG),A3,L		;NO TRANSLATION NECESSARY, USE DAG		
	MOVE	*A8(OANIOFF),A14,L
	ADDXY	A14,A3			;DA POINT TO CHECK
	JRUC	CPH_DOIT
CPH_TRANSLATE
	SEXT	A3,W
	SLL	15,A3			;X WORLD OFFSET
	SRA	16,A7
	SLL	15,A7			;Y WORLD OFFSET
	MOVE	*A8(OCTRL),A14,W	;ADJUST FIRING OFFSET IF NECESSARY
	BTST	B_FLIPH,A14
	JREQ	CPH_CKV			;BR=NO HORIZONTAL FLIP 
	NEG	A3
CPH_CKV
	BTST	B_FLIPV,A14
	JREQ	CPH_OFF			;BR=NO VERTICAL FLIP
	NEG	A7
CPH_OFF
	MOVE	*A8(OXVAL),A14,L
	ADD	A14,A3			;X UNIVERSE
	MOVE	*A8(OYVAL),A14,L
	ADD	A14,A7			;Y UNIVERSE
	MOVE	*A8(OZVAL),A2,L		;Z UNIVERSE
CPH_hook:					
	UTOSXY	A2,A3,A7		;UNIVERSE X,Y TO SCREEN X,Y TRANSLATION
	SLL	16,A7
	ZEXT	A3,W
	ADDXY	A7,A3			;A3 IN [Y,X] FORMAT
CPH_DOIT
	calla	ENEMYP_COLL		;SEE IF HIS SHOT IS BLOCKED
	jrnz	CPH_Block_X		;BR = 'twas blocked

	movi	[50,50],A2		;This is our out of range buffer

	move	@SCRNTL,A7,L
	subxy	A2,A7			;Bufferin
	cmpxy	A7,A3			;Out of range?
	jrxlt	CPH_Block_X		;BR = Yes, to the left
	jrylt	CPH_Block_X		;BR = Yes, on top
	move	@SCRNBR,A7,L
	addxy	A2,A7			;Bufferin
	cmpxy	A7,A3			;Out of range?
	jrxgt	CPH_Block_X		;BR = Yes, to the right
	jrygt	CPH_Block_X		;BR = Yes, below

	MOVE	@GAME_STATE,A7,W
	CMPI	INPLAY,A7		;ARE WE PLAYING?
	JRNE	CPH_X			;BR = NO
	
	MOVE	@NPLAYERS,A7,W
	MOVI	P1DATA,A2
CPH_PLAYER_LP
	CALLR	CHECK_HIT
	JRZ	CPH_NXT_PLAYER
*ENEMY SCORED A HIT
	JRNC	CPH_PLAYER_HIT		;BR = PLAYER NOT OUT OF LIFE
	MOVKM	1,*A2(PDEAD),W		;MARK THE PLAYER DEAD, NOW!
CPH_PLAYER_HIT
	INC	A6			;SHOW THE HIT
CPH_NXT_PLAYER
	ADDI	PDSIZE,A2
	DEC	A7
	JRNN	CPH_PLAYER_LP
CPH_X
	MOVE	A6,A6			;SET STATUS
	clrc				;Shot not blocked or offscreen
	MMFM	SP,A1,A3,A6,A7
	RETS
*Exit point if shot was blocked or offscreen
CPH_Block_X
	move	A6,A6
	setc				;Shot was blocked or offscreen
	mmfm	SP,A1,A3,A6,A7
	rets

**************************************************************************
*								         *
* PLAYER_HIT - ROUTINE TO HIT THE PLAYER FOR SOME ENERGY.		 *
* A2 = PTR TO PLAYER DATA AREA						 *
* A5 = ENERGY TO SUBTRACT [INT,FRAC]					 *
*								         *
**************************************************************************
PLAYER_HIT
	MOVE	A2,A2			;IS IT COOL
	JRZ	PH_X
	MOVE	*A2(POBJ),A14,L		;IS THE PLAYER ALIVE?
	JRZ	PH_X			;BR = NO
	CALLR	DO_HIT
	JRZ	PH_X			;BR = No hit scored
	JRNC	PH_X			;BR = Player not dead yet
	MOVKM	1,*A2(PDEAD),W		;MARK THE PLAYER DEAD, NOW!
PH_X
	RETS

**************************************************************************
*								         *
* DO_HIT - ROUTINE TO SCORE A PLAYER HIT NO MATTER WHAT!		 *
* A2 = PTR TO PLAYER DATA AREA						 *
* A5 = ENERGY TO SUBTRACT [INT,FRAC]					 *
* RETURNS								 *
* 	 Z	= NO HIT SCORED						 *
* 	NZ & NC = SCORED A PLAYER HIT AND PLAYER IS STILL ALIVE		 *
* 	NZ &  C = SCORED A PLAYER HIT AND PLAYER IS NOW DEAD		 *
* NOTE: MAKE SURE PLAYER IS ALIVE WHEN CALLING THIS ON HIM		 *
*								         *
**************************************************************************
DO_HIT
	PUSH	A0
	JRUC	CHECK_HIT_G

**************************************************************************
*								         *
* CHECK_HIT - ROUTINE TO DETERMINE IF A PLAYER HAS RECIEVED A HIT.	 *
* A2 = PTR TO PLAYER DATA AREA						 *
* A3 = POINT TO CHECK							 *
* A5 = ENERGY TO SUBTRACT [INT,FRAC]					 *
* RETURNS								 *
* 	 Z	= NO HIT SCORED						 *
* 	NZ & NC = SCORED A PLAYER HIT AND PLAYER IS STILL ALIVE		 *
* 	NZ &  C = SCORED A PLAYER HIT AND PLAYER IS NOW DEAD		 *
*								         *
**************************************************************************
CHECK_HIT
	PUSH	A0
	MOVE	*A2(POBJ),A0,L		;IS THE PLAYER ALIVE?
	JRZ	CH_X			;BR = NO
	MOVE	*A2(PHITBOXUL),A0,L
	CMPXY	A0,A3
	JRXLT	CH_FL
	JRYLT	CH_FL
	MOVE	*A2(PHITBOXLR),A0,L
	CMPXY	A0,A3
	JRXGT	CH_FL
	JRYGT	CH_FL

;	CALLA	ENEMYP_COLL		;SEE IF HIS SHOT IS BLOCKED
;	JRNZ	CH_FL

CHECK_HIT_G
	MOVE	*A2(PINVINCIBLE),A0,W	;IS THIS PLAYER INVINCIBLE?
	JRNZ	CH_FL			;BR = YES, NO FLASH
	MOVE	A5,A5			;Is no energy being taken?
	JRZ	CH_NOFLASH		;BR = Correct, do not flash
;	JRNZ	CH_NOFLASH		;BR = YES, NO FLASH

	CALLA	FLASH_PSTATUS		

;	CALLA	GPLAYNUM		;GET THE PLAYERS NUMBER
;	SLL	5,A0
;	ADDI	FLASH_TAB,A0
;	MOVE	*A0,A0,L		;GET HIS TABLE OF FLASH LAMPS
;	MOVB	*A2(PLASTFLASH),A14
;	INC	A14			;THIS IS THE NEXT FLASHER TO GO
;	CMPI	N_PFLASHERS,A14
;	JRLO	CH_FLASHIT		;BR = STILL IN RANGE.
;	CLR	A14			;RESET TO ZERO FLASHER
;CH_FLASHIT
;	MOVB	A14,*A2(PLASTFLASH)
;	SLL	5,A14
;	ADD	A14,A0
;	MOVE	*A0,A0,L		;PULL FLASHER FROM TABLE
;	CALLA	FLASH_LAMP		;AND DO IT
;
CH_NOFLASH

	MOVE	A5,A0

	CALLA	SUBLIFE

	CLRZ				;FLAG THE TAG
	JRUC	CH_X
CH_FL
	SETZ
CH_X
	PULL	A0
	RETS

	.END
