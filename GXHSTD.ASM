    	.MLIB	"GXMACS.LIB"
	.FILE	"GXHSTD.ASM"
	.TITLE	"<<< GENERATION X - HSTD ROUTINES >>>"
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
	.INCLUDE	"GXSTRING.H"
	.INCLUDE	"IMGTBL.GLO"
	.INCLUDE	"UNIVTBL.GLO"

*        IN THIS MODULE

	.DEF	RC_BYTE, RC_BYTEI, RC_WORD, RC_WORDI, RC_LONG, RC_LONGI
	.DEF	WC_BYTE, WC_BYTEI, WC_WORD, WC_WORDI, WC_LONG, WC_LONGI
	.DEF	INIT_TB, ALL_TAB, TOD_TAB, INIT_TAB
	.DEF	PT_ENTRY, VAL_TAB, ROM_PTRS, DEC_HSR, INIT_HSR
	.DEF	GET_HSC, ATT_HSTD, TRYADD
	.DEF	CLEAR_HSCOLORS, ON_HSTD, HS_ENTRY_SCRN, INITHIT
	.DEF	CHAR_PLOT, CHAR_SCORE, NEW_HISCORES
	.DEF	ENTRY_PTR, FETCH_SCORE

*SYMBOLS IN GX.ASM
	.REF	PLAYER, GPLAYD, WEND_SND_TAB, WIPEOUT
*SYMBOLS IN GXADJ.ASM
	.REF	BINBCD
*SYMBOLS IN GXCONTRL.ASM
	.REF	PLAYER_CURSOR
*SYMBOLS IN GXRAM.ASM
	.REF	SKYCOLOR, DO_CREDITS, GUNS_OFF
*SYMBOLS IN GXMISC.ASM
	.REF	SKYUP

* SYMBOLS IN GXSND.ASM
	.REF	SND_DIR_CHOSEN

* SYMBOLS IN GXLA1.ASM
         .REF    LA_OUTSIDE1_VECT_TABLE
* SYMBOLS IN GXBONUS.ASM
	.REF	INIT_ZERO_UNIVERSE
	.REF	BONUS_SET_X, NUMBER_RACKS
	.REF	JAKE_BOX
* SYMBOLS IN GX.ASM
	.REF	PLAYER_CLR

	.REF	ANY_BUT, WAIT_BUT, GET_CSTR
	.REF	CYCLE16

	.REF	INIT_ZERO_UNIVERSE

PBLK_STOR	.EQU	PDATA+0200H	;STORE AWAY THE PLAYER BLOCK IN A PROCESS
GRMUL		EQU	32
RDMUL		EQU	1024

	.BSS	LINE_STARTXY,32
	.BSS	INITIAL_1,8
	.BSS	INITIAL_2,8
	.BSS	INITIAL_3,8
	.BSS	DUMMY,8
	.BSS	SCORE_DATA,32
	.BSS	PIX_PAL,32
	.BSS	CHAR_POINTERS,32*33

	.BSS	CHAR_PLOT,64
	.BSS	CHAR_SCORE,32
	.BSS	CHAR_NUM,16
	.BSS	HOLDINITS,RHS_SIZE*4
	.BSS	ON_HSTD,16

	.BSS	COLPTR,32	   	;PALETTE PTRS
	.BSS	COLPTRF,32
	.BSS	NEW_SCORE,32	     	;SCORE PTR
	.BSS	HISCRFLAG,16		;HIGH SCORE TABLE FLAG
	.BSS	CHAR_VAL,16		;ASCII INITIAL VALUE
	.BSS	TOC,32			;TIME OUT COUNT
	.BSS	P1INITS,32		;PLAYER 1'S INITIAL STRING
	.BSS	P2INITS,32		;PLAYER 2'S INITIAL STRING		

	.BSS	NEW_HISCORES,16		;Flag to tell us someone just entered
	.BSS	UNUSED_WORD,16 		

	.BSS	GREEN_PAL,32
	.BSS	RED_PAL,32
	.BSS	YEL_PAL,32
	.BSS	BLUE_PAL,32
	.BSS	WHITE_PAL,32

	.TEXT
	.EVEN

**************************************************************************
*                                                                        *
*          HIGH SCORE TABLE DEFINITIONS                                  *
*                                                                        *
**************************************************************************

ALL_TAB
	.LONG	ALL_TIME_ORIGIN		;LOCATION OF TABLE
	.WORD	ALL_TIME_ENTRIES-1	;NUMBER IN THE TABLE (DON'T COUNT ZERO FILLER)
	.WORD	ALL_TIME_VISIBLE	;# VISIBLE (SHOW 20 ALL TIME)
	.WORD	ALL_TIME_SELECT		;BITS TO SELECT IT
	.LONG	ALL_TIME_ROM_TABLE	;ROM IMAGE OF TABLE
	.WORD	ALL_TIME_ENTRIES/5	;RESET TABLE IF 1/5 OR MORE BAD

TOD_TAB
	.LONG	TODAYS_ORIGIN		;LOCATION OF TABLE
	.WORD	TODAYS_ENTRIES-1	;NUMBER IN THE TABLE (DON'T COUNT ZERO FILLER)
	.WORD	TODAYS_VISIBLE		;# VISIBLE (SHOW 20 ALL TIME)
	.WORD	TODAYS_SELECT		;BITS TO SELECT IT
	.LONG	TODAYS_ROM_TABLE	;ROM IMAGE OF TABLE
	.WORD	TODAYS_ENTRIES/5	;RESET TABLE IF 1/5 OR MORE BAD

**************************************************************************
*                                                                        *
*          AUTO HIGH SCORE TABLE RESET HANDLING                          *
*                                                                        *
**************************************************************************
*                                                                        *
*          DEC_HSR                                                       *
*                                                                        *
*          THIS IS CALLED WITH EACH START OR CONTINUE FOR                *
*          A PLAYER.  IT REMOVES 1 FROM THE HSTD COUNTER UNLESS          *
*          ITS ALREADY SITTING AT ZERO.                                  *
*                                                                        *
**************************************************************************
DEC_HSR
	MMTM	SP,A0
	CALLR	GET_HSC			;THIS IS EASY...GET THE COUNTER
	JRZ	DECHX			;ITS ZERO....NO ACTION.
	DEC	A0			;REMOVE A TICK
	calla	CMOSUNLOCK
	CALLR	PUT_HSC			;PUT IT BACK JAK
	calla	CMOSLOCK
DECHX
	MMFM	SP,A0
	RETS

**************************************************************************
*                                                                        *
*          DELAY_HSRESET                                                 *
*                                                                        *
*          THIS IS CALLED WHEN A NEW ENTRY IS MADE IN THE ALL TIME       *
*          HIGH SCORE TABLE.  IF WE'RE CLOSE TO A HIGH SCORE             *
*          RESET, WE PUT IT OFF AWHILE SO HE CAN SHOW HIS FRIENDS        *
*          FOR A FEW DAYS.                                               *
*                                                                        *
**************************************************************************
HS_MIN   EQU     750             ;ALWAYS 750 PLAYS BEFORE REMOVING A FRESH
*                                ;NAME.
*XUNIT   NOBODY CALLS THIS
*
*
*DELAY_HSRESET
*         MMTM    SP,A0
*         CALLR   GET_HSC         ;THIS IS EASY...GET THE COUNTER
*         CMPI    HS_MIN,A0       ;IS IT TOO LOW
*         JRHS    DHX             ;NOPE...NO ACTION
*
*         MOVI    HS_MIN,A0       ;STOP THE RESET!
;	calla  CMOSUNLOCK
*         CALLR   PUT_HSC         ;THIS MANY PLAYS TILL RESET!
;	calla  CMOSLOCK
*DHX	MMFM    SP,A0
*	RETS

**************************************************************************
*                                                                        *
*          INIT_HSR                                                      *
*                                                                        *
*          THIS IS CALLED TO INITIALIZE THE HIGH SCORE RESET             *
*          COUNTER TO ITS ADJUSTED VALUE.                                *
*                                                                        *
**************************************************************************
INIT_HSR
	MMTM	SP,A0
	calla	CMOSUNLOCK
	MOVI	ADJHSRES,A0
	CALLA	GET_ADJ			;GET THE ADJUSTED VALUE
	CALLR	PUT_HSC			;SET IT TO THIS VALUE
	calla	CMOSLOCK
	MMFM	SP,A0
	RETS

**************************************************************************
*                                                                        *
*          PUT_HSC                                                       *
*                                                                        *
*          THIS IS CALLED TO SET THE HIGH SCORE RESET COUNTER            *
*          TO THE VALUE IN A0.                                           *
*                                                                        *
**************************************************************************
PUT_HSC
	MMTM	SP,A7,A0
	CALLR	HSR_PAGE		;HIGH SCORE PAGE

	MOVI	HRESET_COUNTER,A7	;POINT AT 
	CALLR	WC_LONGI		;WRITE OUR PARAMETER
	NOT	A0			;NEGATE IT.
	CALLR	WC_LONG			;AND WRITE IN SUBSEQUENT SPOT.
;XUNIT	CALLA	DEF_PAGE		;FLIP PAGE
	MMFM	SP,A7,A0		;AND RETURN
	RETS

**************************************************************************
*                                                                        *
*          GET_HSC                                                       *
*                                                                        *
*          THIS IS CALLED TO FETCH THE HIGH SCORE COUNTER IN A0.         *
*          IF IT IS INVALID, IT WILL IMMEDIATELY BE RESET TO THE         *
*          ADJUSTED VALUE AND THIS IS WHAT WILL BE RETURNED              *
*          IN A0.           .EQ. MEANS ITS AT ZERO!                      *
*                                                                        *
**************************************************************************
GET_HSC
	MMTM	SP,A7,A1
	CALLR	HSR_PAGE		;POINT PAGE AT HSR

	MOVI	HRESET_COUNTER,A7	;POINT AT 
	CALLR	RC_LONGI		;READ THE VALUE
	MOVE	A0,A1			;STASH IT
	CALLR	RC_LONG			;READ VERIFIER
	NOT	A0			;SEE IF ITS VALID
	CMP	A0,A1
	JRZ	GET_HSCX		;IT IS....RETURN IT.

	CALLR	INIT_HSR		;REFRESH IT WITH FACTORY VALUE
*
*	NOW RETURN THE FACTORY VALUE IN CASE IT DIDN'T TAKE
*
	MOVI	ADJHSRES,A0
	CALLA	GET_ADJ			;GET THE ADJUSTED VALUE

GET_HSCX
;XUNIT	CALLA	DEF_PAGE		;FLIP PAGE AWAY FROM US
	MOVE	A0,A0			;SET Z FLAG BASED ON COUNTER
	MMFM	SP,A7,A1
	RETS
HSR_PAGE
	MMTM	SP,A1
	MOVI	HSR_SELECT,A1
;XUNIT	CALLR	SET_PAGE
	MMFM	SP,A1
	RETS

**************************************************************************
*								         *
* 	CKHSTD								 *
* 									 *
* 	CHECK TO SEE IF EITHER SCORE WILL MAKE EITHER OF THE TABLES	 *
* 									 *
* 	ENTRY								 *
* 		A0	SCORE TO CHECK					 *
* 									 *
* 	EXIT								 *
* 		.EQ.	NO						 *
* 		.NE.	YES						 *
*								         *
**************************************************************************

ADD_ALL_TO_SHUFFLE
	MOVK	1,B1

	MOVI	P1DATA,A14
	MOVE	*A14(POBJ),A1,L
	JRZ	NO_INSERT_PLAYER_1

	MOVE	*A14(PSCORE),A0,L
	JRZ	NO_INSERT_PLAYER_1
	CALLA	BINBCD

	MOVE	A14,A8
	MOVI	INITIAL_1,A1
	CALLR	TRYADD
NO_INSERT_PLAYER_1
	MOVI	P2DATA,A14
	MOVE	*A14(POBJ),A1,L
	JRZ	NO_INSERT_PLAYER_2

	MOVE	*A14(PSCORE),A0,L
	JRZ	NO_INSERT_PLAYER_2
	CALLA	BINBCD

	MOVE	A14,A8
	MOVI	INITIAL_1,A1
	CALLR	TRYADD
NO_INSERT_PLAYER_2
	MOVI	P3DATA,A14
	MOVE	*A14(POBJ),A1,L
	JRZ	NO_INSERT_PLAYER_3

	MOVE	*A14(PSCORE),A0,L
	JRZ	NO_INSERT_PLAYER_3
	CALLA	BINBCD

	MOVE	A14,A8
	MOVI	INITIAL_1,A1
	CALLR	TRYADD
NO_INSERT_PLAYER_3
	RETS


COMPARE_AND_SHUFFLE
	MOVI	P1DATA,A14
	CALLA	COMPARE_PLAYER

	MOVI	P2DATA,A14
	CALLA	COMPARE_PLAYER

	MOVI	P3DATA,A14

COMPARE_PLAYER
	CLR	A0
	CLR	A2
	MOVE	*A14(POBJ),A1,L
	JRZ	WERE_NOT_IN
	MOVE	*A14(PSCORE),A0,L
	JRZ	WERE_NOT_IN
	CALLA	BINBCD
	MOVE	A0,B0
	MOVI	ALL_TAB,A8   		; CHECK ALL TIME TABLE FIRST, PLAYER 2
	CALLA	CHECK_SCORE
	JRZ	NOT_IN_ALL_TIME
	CMPI	8,A0
	JRLE	WERE_IN
NOT_IN_ALL_TIME
	MOVE	B0,A0
	MOVI	TOD_TAB,A8		; TODAY'S TABLE, PLAYER 2
	CALLA	CHECK_SCORE
	JRZ	WERE_NOT_IN
	CMPI	8,A0
	JRLE	WERE_IN
WERE_NOT_IN
	CLR	A2
	MOVE	A2,*A14(POBJ),L
WERE_IN
	RETS


**************************************************************************
*								         *
* 	TRYADD								 *
* 									 *
* 	WE THINK WE ARE IN ONE OF THE TABLES -- ADD ME			 *
* 									 *
* 	ENTRY								 *
* 		A0	SCORE						 *
* 		A1	POINTER TO INITIALS				 *
*		A8	POINTER TO THE PLAYER DATA AREA			 *
* 									 *
* 	EXIT								 *
* 		NOTHING							 *
*								         *
**************************************************************************
TRYADD:
	MMTM	SP,A8
	PUSH	A0
	MOVE	A8,A2
	CALLA	GPLAYNUM
	INC	A0			; 1 BASE THIS ONE
	MOVE	A0,A2			; WHAT TO STICK IN "HS_SCORE"
	PULL	A0
	MOVI	ALL_TAB,A8   		; CHECK ALL TIME TABLE FIRST
	CALLR	ADD_ENTRY
	MOVI	TOD_TAB,A8		; TODAY'S TABLE
	CALLR	ADD_ENTRY
	MMFM	SP,A8
	RETS	

**************************************************************************
*                                                                        *
*          CHECK_SCORE                                                   *
*                                                                        *
*          THIS IS CALLED WITH A SCORE IN A0 TO SEE IF IT                *
*          IS HIGH ENOUGH TO MAKE THE TABLE.                             *
*                                                                        * 
*          THIS ROUTINE CALLS FIND_TABLE_LEVEL WHICH RETURNS             *
*          THE POINT IN THE TABLE THAT THE PASSED SCORE WOULD            *
*          LAND.   THIS VALUE MUST BE LESS THAN OR EQUAL TO              *
*          THE "TB_VISIBLE" VALUE FOR THE TABLE.  THIS WOULD             *
*          MEAN THAT WE WANT TO GET THE PLAYER'S INITIALS.               *
*                                                                        *
*          A8 CONTAINS ROM POINTER FOR TABLE TO CHECK.                   *
*          RETURN A0 = 0 (AND .EQ.) IF SCORE ISN'T HIGH ENOUGH           *
*          AND A0 = POSITION IN TABLE IF SCORE MAKES IT.                 *
*                                                                        *
**************************************************************************
CHECK_SCORE
	MMTM	SP,A1,A3,A9,A10
	MOVE	A0,A3				;STASH SCORE IN A3
	CALLR	FIND_TABLE_LEVEL		;SEE WHERE WE LAND IN THIS TABLE
	JRZ	ANSWER_IN_A0			;ZERO.....GUY DIDN'T MAKE IT
	MOVE	*A8(TB_VISIBLE),A1,W		;GET THE NUMBER "VISIBLE"
	CMP	A1,A0				;A0 MUST BE LESS OR EQUAL
	JRLS	ANSWER_IN_A0			;NOT INVISIBLE...RETURN SUCCESS
	CLR	A0				;RETURN FAILURE
ANSWER_IN_A0
	MOVE	A0,A0				;SET EQ BIT ACCORDINGLY
	MMFM	SP,A1,A3,A9,A10
	RETS

**************************************************************************
*                                                                        *
*          ADD_ENTRY                                                     *
*                                                                        *
*          THIS IS CALLED AFTER "ENTER YOUR INITIALS" TO                 *
*          ADD AN ENTRY TO THE TABLE.  A0 CONTAINS THE                   *
*          SCORE OF THE PLAYER.  A1 CONTAINS A POINTER                   *
*          TO THE FETCHED INITIALS.   THE INITIALS ARE                   *
*          STORED AS CONSECUTIVE BYTES IN CONVENTIONAL                   *
*          (1 BYTE TAKES 1 BYTE SPACE) RAM.                              *
*                                                                        *
*          A8 contains a the table to store the entry in.                *
*	   A2 CONTAINS SOMETHING TO STICK IN "HS_COLOR"			 *
*                                                                        *
*          RETURN CARRY SET IF IT DIDN'T MAKE IT INTO REQUESTED TABLE    *
*                                                                        *
**************************************************************************
ADD_ENTRY
         MMTM    SP,A0,A1,A2,A3,A4,A7,A9,A10,A11
	MOVE	A2,A11
         CALLR   ROM_PTRS                  ;SETUP FOR THIS TABLE
         MOVE    A0,A4                     ;STASH THE SCORE A SEC.
         CLR     A2                        ;DONT WORRY ABOUT OTHER GUY AT THIS POINT
         CALLR   CHECK_SCORE               ;DOES THE REQUEST MAKE IT?
         SETC                              ;ANTICIPATE FAILURE
         JRZ     DIDNT_MAKE_IT             ;DON'T KNOW WHY I GOT THESE INITS.
*
*        A0 NOW HAS THE PLACE FOR THE NEW GUY.
*        MOVE THE ENTIRE TABLE DOWN 1 UNIT.
*
	 calla	CMOSUNLOCK
	MOVE	B1,B1
	JRZ	COPY_DONE

         MOVE    A10,A3                    ;LAST GUY IN TABLE IS DESTINATION
COPY_DOWN_LOOP
         MOVE    A3,A2                     ;GUY BEFORE HIM IS SOURCE
         DEC     A2                        ;A2 NOW HAS SOURCE
         CMP     A0,A2                     ;IS SOURCE LOWER THAN OUR SLOT? 
         JRLO    COPY_DONE                 ;IT IS...DON'T MOVE HIM.  

         CALLR   COPY_ENTRY                ;COPY A2 ENTRY TO A3
         DEC     A3                        ;MOVE DOWN TO ONE BEFORE
         JRUC    COPY_DOWN_LOOP

COPY_DONE
         CALLR   PUT_SCORE_FOR_ENTRY       ;SCORE IN A4 WRITTEN TO ENTRY A0
*
*        INITIAL POINTER IS IN A1
*        TABLE OFFSET IN A0
*
         CALLR   PT_ENTRY                  ;GET ENTRY POINTER IN A7
	MMTM	SP,A0,A7
	ADDI	HS_COL,A7
	MOVE	A11,A0
	CALLR	WC_WORD
	MMFM	SP,A0,A7
         ADDI    HS_INITS,A7               ;POINT AT FIRST INITIAL
         MOVI    NUM_INITS,A2              ;THIS IS NUMBER OF INITIALS
         MMTM    SP,A0                     ;SAVE A0

INIT_COPY_LOOP
         MOVB    *A1,A0                    ;GET AN INITIAL
         JRNZ    NOT_BLANK
         MOVI    SPACE,A0                  ;REPLACE BLANKS WITH SPACES
NOT_BLANK
         CALLR   WC_BYTEI       ;WRITE THE BYTE AND INCREMENT
         ADDI    BYTE_SIZE,A1              ;A1 TO NEXT BYTE PLEASE
         DSJ     A2,INIT_COPY_LOOP

	MMFM    SP,A0                     ;GET BACK ENTRY NUMBER
         CALLR   FORM_HS_CKSUM_AND_STORE   ;FOR CHECKSUM FOR THIS ENTRY AND STORE!
         CLRC                              ;RETURN SUCCESS!
	 calla	CMOSLOCK

DIDNT_MAKE_IT
	MMFM    SP,A0,A1,A2,A3,A4,A7,A9,A10,A11
	RETS

**************************************************************************
*                                                                        *
*          FIND_TABLE_LEVEL                                              *
*                                                                        *
*          THIS IS CALLED TO COMPARE THE SCORE IN A0 TO                  *
*          THE TABLE POINTED TO BY A8.                                   *
*                                                                        *
*          RETURN PHYSICALLY WHERE IT FITS IN A0, AND                    *
*          SET THE Z FLAG ACCORDINGLY                                    *
*                                                                        *
**************************************************************************
FIND_TABLE_LEVEL
         MMTM    SP,A1,A2,A3
         CALLR   ROM_PTRS                  ;SETUP FOR THIS TABLE
         CALLR   VAL_TAB                   ;FIX THE TABLE IN CASE ITS BROKEN.
         JRC     FTL_FAIL                  ;CAN'T VALIDATE..SAY SCORE DIDN'T MAKE IT

         MOVE    A0,A2                     ;KEEP SCORE IN A2
         MOVK    1,A0                      ;START AT 1 AND WORK UP.

CHECK_NEXT_SCORE
         CALLR   GET_HSCR       ;FETCH A0 ENTRY'S SCORE IN A1
         CMP     A1,A2                     ;HOW DO WE FARE AGAINST A1?
         JRGE    FOUND_THE_SPOT            ;WE FOUND THE SPOT
         INC     A0                        ;KEEP MOVING DOWN TILL WE FIT
         CMP     A10,A0                    ;ARE WE LOOKING AT THE LAST ONE?
         JRLS    CHECK_NEXT_SCORE

FTL_FAIL
         CLR     A0                        ;WE'RE NOT HIGH ENOUGH RETURN FAILURE

FOUND_THE_SPOT
         MOVE    A0,A0                     ;MAKE SURE YOU SET THE FLAGS
	MMFM    SP,A1,A2,A3
	RETS


**************************************************************************
*                                                                        *
*          GET_HSCR                                                      *
*                                                                        *
*          THIS IS CALLED TO FETCH THE SCORE FROM CMOS FOR               *
*          A GIVEN ENTRY.                                                *
*                                                                        *
*          ENTRY NUMBER PASSED IN A0.                                    *
*          SCORE RETURNED IN A1.                                         *
*                                                                        *
**************************************************************************
GET_HSCR
         MMTM    SP,A7,A0
         CALLR   PT_ENTRY                  ;POINT A7 AT ENTRY
         ADDI    HS_SCORE,A7               ;INDEX SCORE PART.
         CALLR   RC_LONG            ;FETCH THE LONG WORD INTO A0
         MOVE    A0,A1                     ;MOVE TO A1
	MMFM    SP,A7,A0
	RETS

**************************************************************************
*                                                                        *
*          PUT_SCORE_FOR_ENTRY                                           *
*                                                                        *
*          THIS IS CALLED TO WRITE OUT THE SCORE FOR A GIVEN ENTRY.      *
*          ENTRY SPECIFIED BY A0.                                        *
*          SCORE PASSED IN A4.                                           *
*                                                                        *
**************************************************************************
PUT_SCORE_FOR_ENTRY
         MMTM    SP,A7,A0
         CALLR   PT_ENTRY                  ;POINT A7 AT ENTRY
         ADDI    HS_SCORE,A7               ;INDEX SCORE PART.
         MOVE    A4,A0                     ;MOVE SCORE TO A0
         CALLR   WC_LONG           ;WRITE OUT THE LONG WORD 
	MMFM    SP,A7,A0
	RETS
	
**************************************************************************
*                                                                        *
*          LOW LEVEL HSTD PROCESSING                                     *
*                                                                        *
**************************************************************************
*
*        FOR HIGH SCORE ROUTINES
*
*        A8  = ROM POINTER FOR A GIVEN TABLE STATS
*        A9  = RAM POINTER FOR CMOS DATA
*        A10 = NUMBER OF ENTRIES IN THE TABLE
*
*        A0  = PARTICULAR ENTRY TO DEAL WITH
*                0 = FILL ENTRY (POINTER ROUTINES POINT HERE IF ERROR)
*                1 = HIGHEST SCORE IN TABLE
*                N = NTH SCORE
*
*        A1  = OUTPUT OF CHECKSUM ROUTINE  (BYTE)
*
*        A7  = POINTER TO CURRENT ENTRY
*
*        A4,A5,A6  SCRATCH
*
**************************************************************************
*                                                                        *
*          FORM_HS_CKSUM                                                 *
*                                                                        *
*          THIS IS CALLED TO FORM THE CHECKSUM FOR THE SCORE             *
*          NUMBER IN A0.  (RAM POINTER ASSUMED IN A9).                   *
*          CHECKSUM IS RETURNED IN A1.   THIS IS A *BYTE*.               *
*                                                                        *
*          CHECKSUM IS COMPUTED AS THE COMPLEMENT OF THE SIMPLE SUM      *
*          OF THE BYTES IN THE ENTRY.                                    *
*                                                                        *
*          THIS ROUTINE RETURNS WITH THE Z BIT SET (.EQ.) IF THE         *
*          CHECKSUM FOR THIS ENTRY MATCHES.                              *
*                                                                        *
**************************************************************************
FORM_HS_CKSUM
         MMTM    SP,A0,A4,A6,A7
         CALLR   PT_ENTRY                  ;A7 = POINTER TO CURRENT ENTRY
         MMTM    SP,A7                     ;SAVE POINTER TO ENTRY
         MOVI    HS_BYTES_TO_CHECK,A4      ;COUNT DOWN THE BYTES
         CLR     A1                        ;KEEP SUM IN A1
ADD_A_BYTE
         CALLR   RC_BYTEI        ;GET A BYTE INTO A0
         ADD     A0,A1                     ;ADD TO SUM
         DSJ     A4,ADD_A_BYTE             ;ONE MORE ADDED
         NOT     A1                        ;CHECKSUM IS NOW IN LOW BYTE
         ANDI    BYTE_MASK,A1                   ;MASK SO ITS COOL
	MMFM    SP,A7                     ;GET POINTER BACK
         ADDI    HS_CKBYTE,A7              ;POINT AT CHECKBYTE
         CALLR   RC_BYTE            ;READ IN THE BYTE
         CMP     A0,A1                     ;COMPARE WHAT'S THERE TO WHAT WE GOT
	MMFM    SP,A0,A4,A6,A7                  ;Z BIT RETURNS COMPARE
	RETS                              ;A1 RETURNS CKSUM

**************************************************************************
*                                                                        *
*          FORM_HS_CKSUM_AND_STORE                                       *
*                                                                        *
*          THIS IS USED TO SET THE CHECKSUM FOR THE CURRENT              *
*          ENTRY (A0) TO THE CORRECT VALUE.                              *
*                                                                        *
**************************************************************************
FORM_HS_CKSUM_AND_STORE
         MMTM    SP,A0,A7
         CALLR   FORM_HS_CKSUM             ;GET THE CKSUM IN A1, POINTER IN A7
         CALLR   PT_ENTRY                  ;POINT AT THE VALUE
         ADDI    HS_CKBYTE,A7              ;POINT AT CHECKBYTE
         MOVE    A1,A0                     ;GET CHECKBYTE TO A0
         CALLR   WC_BYTE           ;WRITE OUT THE BYTE
	MMFM    SP,A0,A7
	RETS

**************************************************************************
*                                                                        *
*          PT_ENTRY                                                      *
*                                                                        *
*          THIS IS CALLED TO POINT AT A GIVEN ENTRY OF                   *
*          THE HIGH SCORE TABLE.  THIS ROUTINE BASES                     *
*          ACTIVITY ON ROM POINTER IN A8.  IT FETCHES                    *
*          FRESH COPIES OF THE A9 RAM POINTER AND THE                    *
*          A10 ENTRY COUNTER.  IT RETURNS THE ENTRY                      *
*          POINTER IN A7.                                                *
*                                                                        *
*          A0 SPECIFIES WHICH ENTRY TO POINT AT                          *
*          A8,A9,A10 AND SYSCTRL ASSUMED SET PROPERLY                    *
*          A7 RETURNED POINTING TO THAT ENTRY                            *
*                                                                        *
**************************************************************************
PT_ENTRY
	CMP	A10,A0			;A10 IS MAX VALUE
	JRLS	POINTER_IN_RANGE

	.IF DEBUG
	JRUC	$			;HANG IN DEVELOPMENT
	.ENDIF

	MOVE	A9,A7			;RETURN ZERO OFFSET IN FIELD
	RETS

POINTER_IN_RANGE
	MOVI	HS_SIZE,A7		;SIZE OF ENTRY
	MPYU	A0,A7			;OFFSET OF ENTRY
	ADD	A9,A7			;ADD IN THE BASE
	RETS

**************************************************************************
*                                                                        *
*          ROM_PTRS                                                      *
*                                                                        *
*          THIS IS CALLED TO LOAD UP THE ROM STRUCTURE                   *
*          DATA INTO REGISTERS.                                          *
*                                                                        *
*          THIS ALSO SETS UP STATUS WORD TO SELECT THE CMOS              *
*          BANK SELECT FOR WHERE THE PARTICULAR TABLE RESIDES.           *
*                                                                        *
*          INPUT A8    = HSTD STRUCTURE ROM POINTER.                     *
*                                                                        *
*          OUTPUT  A9  = CMOS RAM POINTER TO BASE OF TABLE               *
*          OUTPUT  A10 = LAST ENTRY IN TABLE.  TABLE WILL                *
*                          HAVE A10+1 ENTRIES SINCE ENTRY                *
*                          0 IS A FILLER.                                *
*                                                                        *
**************************************************************************
ROM_PTRS
	MMTM	SP,A0,A1			;SCRATCH REGGIES
	MOVE	*A8(TB_POINTER),A9,L		;GET CMOS POINTER
	MOVE	*A8(TB_COUNT),A10,W		;GET NUMBER OF ENTRIES
	MOVE	*A8(TB_PAGE_BITS),A1		;GET OUR CMOS PAGE BITS

;XUNIT	CALLR	SET_PAGE

	MMFM	SP,A0,A1			;SCRATCH REGGIES
	RETS

**************************************************************************
*                                                                        *
*          SET_PAGE                                                      *
*                                                                        *
*          This is called to set the CMOS page to the bits               *
*          contained in A1.                                              *
*                                                                        *
**************************************************************************
;XUNIT START
*SET_PAGE
*	.IF TUNIT=0
*	MMTM	SP,A0,A1
*	ANDI	CMOS_PAGE_SELECT_BITS,A1	;KILL SIGN EXTEND..SAVE BITS
*	PUSHST					;SAVE INTERRUPT STATUS
*	DINT					;STOP INTERRUPTS
*	MOVE	@SYSCOPY,A0,W			;GET THE RAM COPY
*	ANDNI	CMOS_PAGE_SELECT_BITS,A0	;REMOVE THE CURRENT PAGE SELECT
*	OR	A1,A0				;ADD IN OUR BITS
*	MOVE	A0,@SYSCOPY,W			;PUT THEM BACK IN THE RAM COPY
*	MOVE	A0,@SYSCTRL,W			;NOW THE HARDWARE
*	POPST					;OK TO RE-START INTS
*	MMFM	SP,A0,A1
*	.ENDIF
*	RETS
;XUNIT END

**************************************************************************
*                                                                        *
*          INIT_TAB                                                      *
*                                                                        *
*          This entrypoint is called at power up to                      *
*          clear out "today's" high score table.  We do                  *
*          this job, and then we do the job on the                       *
*          all time table for high score reset if                        *
*          necessary.                                                    *
*                                                                        *
**************************************************************************
INIT_TAB
	MMTM	SP,A8,A0

	MOVI	TOD_TAB,A8
	CALLR	INIT_TB			;RESET TODAYS TABLE

	.IF	0
	CALLR	GET_HSC			;CHECK THE HIGH SCORE RESET COUNTER
	JRNZ	INIT_TAB1		;NOT ZERO...NO MORE ACTIVITY
*
*	ITS ZERO....SEE IF ITS TURNED OFF
*
	MOVI	ADJHSRES,A0
	CALLA	GET_ADJ			;GET THE ADJUSTED VALUE
	JRZ	INIT_TAB1		;ITS TURNED OFF...NO ACTION.
	.ENDIF

	MOVI	ALL_TAB,A8		;RESET THE ALL TIME TABLE
	CALLR	INIT_TB			;INIT THE ALL TIME TABLE

	CALLR	INIT_HSR		;RESET THE COUNTER TO ADJUSTED VALUE

INIT_TAB1
	MMFM	SP,A8,A0
	RETS

**************************************************************************
*                                                                        *
*          INIT_TB                                                       *
*                                                                        *
*          THIS IS CALLED TO SETUP A HIGH SCORE TABLE WITH               *
*          FACTORY ENTRIES.                                              *
*                                                                        *
*          A8 = ROM TABLE POINTER                                        *
*                                                                        *
**************************************************************************
INIT_TB
	MMTM	SP,A5,A6,A7,A0
	calla	CMOSUNLOCK
	CALLR	ROM_PTRS		;STUFF TABLE DATA
	MOVE	*A8(TB_FACTORY),A6,L	;GET THE FACTORY TABLE
	MOVE	A10,A5			;NUMBER OF VALID ENTRIES
	INC	A5			;1 MORE TO HOLD ZERO ENTRY
	MOVI	HS_SIZE_IN_BYTES,A1	;SIZE OF 1 ENTRY
	MPYU	A1,A5			;A7 HAS NUMBER OF WORDS TO MOVE
	MOVE	A9,A7			;CMOS POINTER IN A7

INIT_TB_1
	MOVB	*A6,A0			;GET A BYTE FROM ROM
	ADDI	BYTE_SIZE,A6		;KICK ROM POINTER
	CALLR	WC_BYTEI		;WRITE THE BYTE AND INCREMENT
	DSJS	A5,INIT_TB_1		;UNTIL THEY'RE ALL THERE.

	MOVE	A10,A0			;POINT AT LAST ENTRY
INIT_TB_2
	CALLR	FORM_HS_CKSUM_AND_STORE	;SET ITS CHECKSUM
	DEC	A0			;MOVE DOWN
	JRNN	INIT_TB_2		;SET EACH ONE INCLUDING ZERO
	calla	CMOSLOCK
	MMFM	SP,A5,A6,A7,A0
	RETS
         
**************************************************************************
*                                                                        *
*          KILL_TAB                                                      *
*                                                                        *
*          THIS IS CALLED TO SMASH A HIGH SCORE TABLE.                   *
*                                                                        *
**************************************************************************
*KILL_TAB
*         MMTM    SP,A5,A6,A7,A0
*         CALLR   ROM_PTRS             ;STUFF TABLE DATA
*         MOVE    A10,A0               ;POINT AT LAST ENTRY
*KILL_TAB_2
*
*         MMTM    SP,A0,A7
*         CALLR   FORM_HS_CKSUM             ;GET THE CKSUM IN A1, POINTER IN A7
*         CALLR   PT_ENTRY                  ;POINT AT THE VALUE
*         ADDI    HS_CKBYTE,A7              ;POINT AT CHECKBYTE
*         MOVE    A1,A0                     ;GET CHECKBYTE TO A0
*         INC     A0                        ;BAD CKSUM
*         CALLR   WC_BYTE                   ;WRITE OUT THE BYTE
*	MMFM    SP,A0,A7
*
*         DEC     A0                   ;MOVE DOWN
*         JRNN    KILL_TAB_2           ;SET EACH ONE INCLUDING ZERO
*	MMFM    SP,A5,A6,A7,A0
*	RETS
*         
**************************************************************************
*                                                                        *
*          COPY_ENTRY                                                    *
*                                                                        *
*          THIS IS CALLED TO COPY 1 ENTRY OF THE TABLE TO A              *
*          DIFFERENT LOCATION IN THE TABLE.                              *
*                                                                        *
*          A8,A9,A10,SYSCTRL ASSUMED TO BE SETUP ALREADY                 *
*          A2 = SOURCE ENTRY  (NUMBER)                                   *
*          A3 = DESTINATION ENTRY (NUMBER)                               *
*                                                                        *
**************************************************************************
COPY_ENTRY
         MMTM    SP,A0,A4,A5,A6,A7
         MOVI    HS_SIZE_IN_BYTES,A4      ;ENTRY SIZE IN BYTES
         MOVE    A2,A0                    ;FIRST POINT FOR A0
         CALLR   PT_ENTRY           
         MOVE    A7,A6                    ;A6 = SOURCE POINTER
         MOVE    A3,A0
         CALLR   PT_ENTRY                 ;A5 = DESTINATION
         MOVE    A7,A5
COPY_LOOP
*
*        IN THIS LOOP WE MOVE A BYTE AT A TIME.
*        SINCE THE WORD AND LONG DO THE SHIFTING AND
*        MASKING AND CALL MULTIPLE ROUTINES, THIS IS 
*        THE MOST EFFICIENT MODE OF OPERATION.
*
         MOVE    A6,A7                    ;SOURCE IN CMOS REGGIE
         CALLR   RC_BYTEI       ;FETCH A WORD
         MOVE    A7,A6
         MOVE    A5,A7                    ;DESTINATION
         CALLR   WC_BYTEI      ;WRITE IT
         MOVE    A7,A5                    ;BACK TO DEST REGGIE
         DSJ     A4,COPY_LOOP             ;UNTIL ALL WORDS ARE COPIED
	MMFM    SP,A0,A4,A5,A6,A7
	RETS

**************************************************************************
*                                                                        *
*          VAL_TAB                                                       *
*                                                                        *
*          THIS ROUTINE IS CALLED WHEN WE ARE INTERESTED IN              *
*          THE HSTD TABLE DATA.  A8 CONTAINS THE ROM POINTER             *
*          FOR THE TABLE.  FOR ANY ENTRIES THAT WE THROW                 *
*          OUT, WE MOVE THE REST OF THE TABLE UP, AND CREATE             *
*          A NEW ENTRY AT THE END OF THE TABLE.                          *
*                                                                        *
*          A2 = 0 ON OUTSIDE CALL.                                       *
*          A2 = 1 ON RECURSIVE CALL (THE CHECK AFTER RE-INIT)            *
*                                                                        *
*          THERE ARE 3 CHECKS MADE FOR EACH ENTRY:                       *
*                                                                        *
*          1)      IS CHECKSUM CORRECT.                                  *
*          2)      IS SCORE ALL NUMERIC                                  *
*          3)      ARE INITIALS ALL VALID ENTRIES.                       *
*                                                                        *
*        OUTPUT CC = TABLE OK                                            *
*               CS = PROBLEM THAT CAN'T BE RECTIFIED                     *
*                    (PROBABLY BAD RAM)                                  *
*                                                                        *
*               A2 = 0 ...table ok, or cleaned up                        *
*               A2 otherwise meanes table initialized                    *
*                                                                        *
**************************************************************************
VAL_TAB
	CLR	A2			;indicate first call in
	CALLR	DO_VALIDATE		;validate
	RETS

DO_VALIDATE
	MMTM	SP,A0,A1,A3,A4,A5,A6,A7
	CALLR	ROM_PTRS		;SETUP FOR TABLE
	MOVI	1,A0			;ITERATE THROUGH THE ENTRIES
	CLR	A1			;COUNT ERRORS

CHECK_A0_ENTRY
	CALLR	CHECK_ENTRY		;IS THE ENTRY OK?
	JRNC	VT_1			;YEP.

	CALLR	REMOVE_ENTRY		;REMOVE THIS ENTRY
	INC	A1
	MOVE	*A8(TB_ERROR_COUNT),A3	;GET THRESHOLD
	CMP	A3,A1			;ARE WE THERE?
	JRLO	CHECK_A0_ENTRY		;NOPE...CHECK MOVE UP ENTRY AT A0
*
*	TABLE IS MESSED UP....RE-INITIALIZE IT PLEASE
*
	MOVE	A2,A2			;IS THIS RECURSIVE CHECK AFTER INIT?
	JRNZ	CANT_VALIDATE		;THEN RETURN FAILURE

	CALLR	INIT_TB			;INIT THIS TABLE PLEASE
	MOVK	1,A2			;INDICATE RECURSIVE CALL
	CALLR	DO_VALIDATE		;IS IT ALRIGHT NOW?
	MMFM	SP,A0,A1,A3,A4,A5,A6,A7
	RETS
*
*	LAST ENTRY WAS VALID...MOVE TO NEXT
*
VT_1
	INC	A0			;KICK IT
	CMP	A10,A0			;STILL IN TABLE?
	JRLS	CHECK_A0_ENTRY		;YEP....CHECK THIS ENTRY

	CLRC				;RETURN VALID!
	MMFM	SP,A0,A1,A3,A4,A5,A6,A7
	RETS

CANT_VALIDATE
	SETC				;RETURN FAILURE!
	MMFM	SP,A0,A1,A3,A4,A5,A6,A7
	RETS

**************************************************************************
*                                                                        *
*          CHECK_ENTRY                                                   *
*                                                                        *
*          THIS IS CALLED TO CHECK THE ENTRY INDICATED BY                *
*          A0.                                                           *
*                                                                        *
*          CC = OK                                                       *
*          CS = ENTRY BAD                                                *
*                                                                        *
**************************************************************************
CHECK_ENTRY
         MMTM    SP,A0,A1,A2,A3,A7

         CALLR   FORM_HS_CKSUM             ;CHECK OUT CKSUM FIRST
         JRNZ    CHECK_FAIL                ;BAD CHECKSUM....ITS BAD
*
*        CHECKSUM OK...CHECK SCORE
*
         CALLR   GET_HSCR       ;SCORE IN A1
         MOVE    A1,A3                     ;SAVE COPY OF SCORE

CHECK_DIGIT
         MOVE    A1,A2                     ;COPY FOR NEXT NIBBLE
         ANDI    0FH,A2                    ;MASK THE NIBBLE
         CMPI    9,A2
         JRHI    CHECK_FAIL                ;NIBBLE TOO HIGH
         SRL     4,A1                      ;SHIFT DOWN TO NEXT NIBBLE
         JRNZ    CHECK_DIGIT

         DEC     A0                        ;MAKE SURE WE ARE LOWER THAN PREVIOUS SCORE!
         JREQ    FIRST_ENT                 ;WE'RE THE 1ST IN THE TABLE

         CALLR   GET_HSCR       ;GET THE SCORE FOR THE GUY BEFORE US
         CMP     A1,A3                     ;OURS MUST BE LOWER OR SAME
         JRHI    CHECK_FAIL                ;OURS IS BIGGER....REMOVE US

FIRST_ENT
         INC     A0                        ;RESTORE THE ENTRY NUMBER
*
*        SCORE OK...CHECK INITIALS
*
         CALLR   PT_ENTRY                  ;POINT A7 AT ENTRY
         ADDI    HS_INITS,A7               ;POINT AT FIRST INITIAL
         MOVI    NUM_INITS,A2              ;THIS IS NUMBER OF INITIALS

NEXT_LETTER
         CALLR   RC_BYTEI        ;FETCH A BYTE

         CALLR   VERIFY_LETTER             ;SEE IF ITS VALID.
         JRC     CHECK_FAIL                ;NOT A LETTER...BYTE

         DSJ     A2,NEXT_LETTER

         CLRC                              ;RETURN PASS
	MMFM    SP,A0,A1,A2,A3,A7
	RETS

CHECK_FAIL
         SETC
	MMFM    SP,A0,A1,A2,A3,A7
	RETS


**************************************************************************
*                                                                        *
*          VERIFY_LETTER                                                 *
*                                                                        *
*          THIS IS CALLED FOR EACH INITIAL LETTER TO SEE                 *
*          IF ITS VALID.                                                 *
*                                                                        *
*          CC = VALID                                                    *
*          CS = NOT VALID                                                *
*                                                                        *
**************************************************************************

VERIFY_LETTER
         ANDI    BYTE_MASK,A0             ;KEEP JUST THE BYTE

         CMPI    SPACE,A0                    ;SPACE?
         JREQ    VERIFY_PASS                ;ITS OK.

* No fucking wonder it didn't work !
;         CMPI    LET_A,A0                    ;BETWEEN A-Z?
;         JRLO    VERIFY_FAIL
;
;         CMPI    LET_Z,A0
;         JRHI    VERIFY_FAIL

         CMPI    ASCII_START,A0                    ;BETWEEN A-Z?
         JRLO    VERIFY_FAIL

         CMPI    ASCII_END,A0
         JRHI    VERIFY_FAIL

VERIFY_PASS
         CLRC
         RETS

VERIFY_FAIL
         SETC
         RETS

**************************************************************************
*                                                                        *
*          REMOVE_ENTRY                                                  *
*                                                                        *
*          THIS IS CALLED TO REMOVE A BAD ENTRY FROM THE TABLE.          *
*          IT DELETES THE ENTRY INDICATED BY A0.                         *
*                                                                        *
*          IT BUBBLES THE REST OF THE TABLE UP 1 UNIT.                   *
*                                                                        *
*          IT THEN PUTS THE LOWEST SCORE FROM THE ROM TABLE              *
*          WITH INITIALS IN THAT ENTRY.                                  *
*                                                                        *
**************************************************************************
REMOVE_ENTRY
         MMTM    SP,A0,A1,A2,A6,A7
	 calla	CMOSUNLOCK
         MOVE    A0,A3                ;THIS IS DEST
         MOVE    A3,A2                ;SOURCE IS 1 BELOW

BUBBLE_ANOTHER
         INC     A2                   ;NOW WE'RE SET FOR A COPY...

         CMP     A10,A2               ;IS SOURCE OUT OF RANGE?
         JRHI    BUBBLE_DONE          ;YEP....WE'RE AT THE BOTTOM (A3)

         CALLR   COPY_ENTRY
         INC     A3
         JRUC    BUBBLE_ANOTHER

BUBBLE_DONE
         MOVE    A3,A0                ;THIS IS BOTTOM OF TABLE
         CALLR   PT_ENTRY             ;A7 POINTS AT CMOS BLOCK

         MOVE    *A8(TB_FACTORY),A6,L  ;GET FACTORY TABLE
         MOVI    HS_ROM_SIZE,A1        ;SIZE OF ENTRY
         MPYU    A10,A1                ;TIMES NUMBER OF VALID ENTRIES..POINTS AT LAST.
         ADD     A1,A6                 ;NOW WE POINT AT END OF ROM TABLE
         MOVI    HS_SIZE_IN_BYTES,A2   ;SIZE OF ENTRY

REPLACE_LOOP
         MOVB    *A6,A0             ;MOVE A ROM BYTE TO A0
         ADDI    BYTE_SIZE,A6
         CALLR   WC_BYTEI  ;WRITE THE WORD AND INCREMENT
         DSJ     A2,REPLACE_LOOP      ;UNTIL THEY'RE ALL THERE.

         MOVE    A10,A0               ;POINT AT "LAST" ENTRY
         CALLR   FORM_HS_CKSUM_AND_STORE   ;STORE THE CHECKBYTE
	 calla	CMOSLOCK
	MMFM    SP,A0,A1,A2,A6,A7         ;AND RETURN
	RETS

**************************************************************************
*                                                                        *
*          CMOS UTILITIES                                                *
*                                                                        *
**************************************************************************

**************************************************************************
*                                                                        *
*          FOR ALL OF THESE CMOS ROUTINES.                               *
*                                                                        *
*                  A7 = POINTER TO MEMORY                                *
*                  A0 = DATA TO/FROM MEMORY                              *
*                                                                        *
**************************************************************************
*
*        ****  IMPORTANT NOTE ON WORD AND LONG WORD PACKING  ****
*        ****  IMPORTANT NOTE ON WORD AND LONG WORD PACKING  ****
*        ****  IMPORTANT NOTE ON WORD AND LONG WORD PACKING  ****
*        ****  IMPORTANT NOTE ON WORD AND LONG WORD PACKING  ****
*        ****  IMPORTANT NOTE ON WORD AND LONG WORD PACKING  ****
*
*        NOTE THAT REQUESTS FOR WORDS RETURN THE 2 BYTES PACKED
*        INTO A WORD AS <1ST BYTE><2ND BYTE>.   THIS IS NOT
*        THE SAME WAY THAT THE GSP HANDLES A WORD POINTED AT
*        WITH A POINTER.
*
*        LONG WORDS WORK SIMILARLY:
*
*           MSB                                              LSB
*               <1ST BYTE> <2ND BYTE> <3RD BYTE> <4TH BYTE>
*
*        TOUGH LUCK INTEL HACKERS!
*
*
*        RC_BYTE
*        WC_BYTE
*
*        These 2 routines are the only routines that ever touch
*        CMOS ram.  This is done to localize the effect of
*        changes in the architecture.  All efforts to deal with
*        CMOS should come through these routines.  Locking
*        hardware will be easily added in the future (as well
*        as different memory mapping).
*
RC_BYTE
	MOVB	*A7,A0
	ANDI	BYTE_MASK,A0
	RETS

WC_BYTE
;XUNIT	.IF TUNIT
;XUNIT	MOVB	A0,@WP_UNLOCK	;UNLOCK CMOS FOR A ONE SHOT WRITE
;XUNIT	.ENDIF
	MOVB	A0,*A7		;WRITE OUT THE BYTE
	RETS			;AND RETURN

**************************************************************************
*								         *
* 	RC_BYTEI							 *
* 									 *
* 	READ BYTE POINTED TO BY A7...INCREMENT POINTER TO		 *
* 	"NEXT" BYTE.							 *
*								         *
**************************************************************************
RC_BYTEI
	CALLR	RC_BYTE
	ADDI	C_BYTE_SIZE,A7	;WORDS SEPARATE CMOS BYTES.
	MOVE	A0,A0		;RETURN FLAGS ACCORDINGLY
	RETS

RC_WORD
	MMTM	SP,A1,A7	;USE A1 TO COMBINE BYTES
	CALLR	RC_BYTEI	;GET A BYTE
	MOVE	A0,A1		;SAVE IN A1
	ANDI	BYTE_MASK,A1	;MASK ONLY BYTE
	SLL	8,A1		;SHIFT TO HIGH BYTE
	CALLR	RC_BYTE		;GET THE 2ND BYTE
	ANDI	BYTE_MASK,A0
	OR	A1,A0		;A0 HAS THE WORD
	MMFM	SP,A1,A7              
	RETS

RC_WORDI
	CALLR	RC_WORD
	ADDI	C_WORD_SIZE,A7	;LONG SEPARATE CMOS WORDS.
	MOVE	A0,A0		;RETURN FLAGS ACCORDINGLY
	RETS

RC_LONG
	MMTM	SP,A1,A7	;USE A1 TO COMBINE BYTES
	CALLR	RC_WORDI	;GET A WORD
	MOVE	A0,A1		;SAVE IN A1
	ANDI	WORD_MASK,A1	;MASK ONLY WORD
	SLL	16,A1		;SHIFT TO HIGH WORD
	CALLR	RC_WORD		;GET THE 2ND WORD
	ANDI	WORD_MASK,A0
	OR	A1,A0		;A0 HAS THE LONG WORD
	MMFM	SP,A1,A7              
	RETS

RC_LONGI
	CALLR	RC_LONG
	ADDI	C_LONG_SIZE,A7	;DOUBLE THE DISTANCE FOR BRAIN DAMIJ
	MOVE	A0,A0		;RETURN FLAGS ACCORDINGLY
	RETS

WC_BYTEI
	CALLR	WC_BYTE
	ADDI	C_BYTE_SIZE,A7
	RETS

WC_WORD
	MMTM	SP,A0,A1,A7
	MOVE	A0,A1		;MAKE COPY OF WORD
	SRL	8,A0		;GET HIGH BYTE IN A0
	CALLR	WC_BYTEI	;WRITE THE HIGH BYTE
	MOVE	A1,A0		;NOW GET THE LOW BYTE BACK
	CALLR	WC_BYTE		;WRITE IT
	MMFM	SP,A0,A1,A7	;AND RESTORE ALL WE TOUCHED
	RETS

WC_WORDI
	CALLR	WC_WORD
	ADDI	C_WORD_SIZE,A7
	RETS

WC_LONG
	MMTM	SP,A0,A1,A7
	MOVE	A0,A1		;MAKE COPY OF LONG
	SRL	16,A0		;GET HIGH WORD IN A0
	CALLR	WC_WORDI	;WRITE THE HIGH WORD
	MOVE	A1,A0		;NOW GET THE LOW WORD BACK
	CALLR	WC_WORD		;WRITE IT
	MMFM	SP,A0,A1,A7	;AND RESTORE ALL WE TOUCHED
	RETS

WC_LONGI
	CALLR	WC_LONG
	ADDI	C_LONG_SIZE,A7
	RETS

**************************************************************************
*								         *
* 	CLR_ISTR							 *
* 									 *
* 	CLEAR INITIAL DATA STRING     					 *
* 									 *
* 	ENTRY								 *
* 		A8, POINTER TO STRING					 *
* 									 *
* 	EXIT								 *
* 		NOTHING							 *
*								         *
**************************************************************************
CLR_ISTR
	MOVI	00202020H,A14			; SPACE SPACE SPACE NULL
	MOVE	A14,*A0,L		
	RETS


**************************************************************************
*								         *
* 	HS_ENTRY_SCRN							 *
* 									 *
* 	HIGH SCORE ENTRY SCREEN SETUP AND TIMER LOOP			 *
* 									 *
* 	ENTRY								 *
* 		NOTHING							 *
* 									 *
* 	EXIT								 *
* 		NOTHING							 *
*								         *
**************************************************************************
HS_ENTRY_SCRN

	MOVI	INGAMEOV,A0
	MOVE	A0,@GAME_STATE

	CLRM	@NEW_HISCORES,W			;No new ones yet

	MOVK	ADJHSON,A0
	CALLA	GET_ADJ
	JRZ	NO_HI_SCORE_INPUT

	MOVI	00202020H,A0
	MOVE	A0,@INITIAL_1,L
	MOVE	A0,@P1DATA+PBONUSCORE,L
	MOVE	A0,@P2DATA+PBONUSCORE,L
	MOVE	A0,@P3DATA+PBONUSCORE,L

	MOVE	A0,@P1DATA+POBJ,L
	MOVE	A0,@P2DATA+POBJ,L
	MOVE	A0,@P3DATA+POBJ,L

	CLR	A0
	MOVE	A0,@P1DATA+PBONUSOBJ,L
	MOVE	A0,@P2DATA+PBONUSOBJ,L
	MOVE	A0,@P3DATA+PBONUSOBJ,L
	MOVE	A0,@P1DATA+PBOMBTYPE
	MOVE	A0,@P2DATA+PBOMBTYPE
	MOVE	A0,@P3DATA+PBOMBTYPE

	MOVE	A0,@IRQSKYE
	MOVE	A0,@IRQGNDE

	CALLA	ADD_ALL_TO_SHUFFLE
	CALLR	COMPARE_AND_SHUFFLE
	MOVE	@P1DATA+POBJ,A1,L
	MOVE	@P2DATA+POBJ,A2,L
	MOVE	@P3DATA+POBJ,A3,L
 	OR	A1,A2
	OR	A2,A3
	JRZ	NO_HI_SCORE_INPUT

NO_CHEXX
	CALLA	CLEAR_ANIMS		;Clear all animations
	CALLA	KILL_DESTRUCTIBLES
	CALLA	MYOINIT			;initialize evreyfink
	CALLA	INIT_ZERO_UNIVERSE	;set up dummy universe
	CALLA	SCORAREA

	MOVE	@NPLAYERS,A10,W		;how many players are able to play
	DEC	A10
	SLL	5,A10
	MOVE	A10,@NUMBER_RACKS	;0 - 2 players ; 10h - 3 players

	MOVIM	SCRNST,@SCRNTL,L	
	MOVIM	SCRNEND,@SCRNBR,L
	MOVIM	-1,@GAMERASE,W		;AUTO ERASE OFF

	MOVKM	1,@GUN_ONE_SHOT,W

	CREATE	PID_CURSOR,PLAYER_CURSOR	;START THE CURSOR TRACKER

	SOUNDON				;TURN ON SOUND AND DISPLAY
	DISPON

	MOVKM	1,@NEW_HISCORES,W	;Got some new righteous ones

	MOVE	@DO_CREDITS,A14,W
	JRZ	HES_NORMAL		;BR = Not running credits

	SOUND1	SND_BGND1_OFF
	SOUND1	SND_BGND2_OFF
	SOUND1	SND_BGND3_OFF
	SOUND1	SND_CHAN1_OFF
	SOUND1	SND_CHAN2_OFF
	SOUND1	SND_CHAN3_OFF

	SOUND1	SND_HSTD_CONGRATS2
	JRUC	HES_GO

HES_NORMAL
	SOUND1	SND_ALLOFF
	SLEEP	1
	SOUND1	SND_HSTD_CONGRATS

HES_GO
	MOVI	HSE_MESS,A8
	CALLA	LM_SETUP
	JSRP	PRINTF

	MOVI	A_Z1,A8
	CALLA	LM_SETUP
	JSRP	PRINTF

	CALLR	MAKE_SINGLE

	CREATE	PID_IND,TIMER_PROC

	MOVI	P1DATA,A10
	CREATE	PID_ATT,SET_UP_FOR_INPUT	;set up plyr1 for input
	MOVI	P2DATA,A10
	CREATE	PID_ATT,SET_UP_FOR_INPUT	;set up plyr2 for input
	MOVI	P3DATA,A10
	CREATE	PID_ATT,SET_UP_FOR_INPUT	;set up plyr3 for input

	SLEEP	2

	CLRM	@GUNS_OFF,W

ARE_WE_STILL_INPUTING
	SLEEP	10
	MOVE	@TOC,A1,L
	JRZ	NO_HI_SCORE_INPUT
	INC	A1
	JRNZ	ARE_WE_STILL_INPUTING

	SLEEP	30

NO_HI_SCORE_INPUT
	RETP

MAKE_SINGLE
	MOVI	CONV_ASCII,A10
	MOVE	*A10+,A1
	MOVE	A1,*A2(OVAR9)
	MOVI	CHAR_POINTERS,A3
	MOVE	A2,*A3+,L
MAKE_SINGLE_2
	MOVE	*A2(OPARTS),A8,L
	JRZ	FINISHED_LETS
	MOVE	A8,*A3+,L
	MOVE	*A10+,A1
	MOVE	A1,*A8(OVAR9)
	MOVI	MAKE_LETTER_EXPLODE,A1
	MOVE	A1,*A8(OGUNVECT),L
	MOVE	*A8(OFLAGS),A1
	ORI	M_NOPIXSCAN,A1
	MOVE	A1,*A8(OFLAGS)
	PUSH	A3
	CALLA	PULL_PART
	PULLQ	A3
	JRUC	MAKE_SINGLE_2
FINISHED_LETS
	RETS

SND_HSTD_CONGRATS
	.WORD	0F3FDH,95,84edH,1,083e8H,0	;"Can I have your autograph?"
SND_HSTD_CONGRATS2
	.WORD	0F3FDH,95,84edH,0		;"Can I have your autograph?"


TAB_HS_ENTERED
	.LONG	SND_ENTERED1, SND_ENTERED2, SND_ENTERED3, SND_ENTERED4
	.LONG	SND_ENTERED5

SND_ENTERED1
	.WORD	0E3FBH,49,0A53FH,0		;"Uh Huh"
SND_ENTERED2
	.WORD	0E3FBH,47,0A533H,0		;"Thank You"
SND_ENTERED3
	.WORD	0E3FBH,69,0A542H,0		;"Ooo Baby"
SND_ENTERED4
	.WORD	0E3FBH,82,0A545H,0		;"You're good"
SND_ENTERED5
	.WORD	0E3FBH,82,0A54BH,0		;"My Hero"

CONV_ASCII
	.WORD	65,66,67,68,69,70,71,72,73,74,75,76,77
	.WORD	78,79,80,81,82,83,84,85,86,87,88,89,90
	.WORD	42,33,63,62,32,1,0

SCORE_COL_TAB
	.WORD	COLOR_RED,COLOR_YELLOW,COLOR_BLUE

SCORE_COL_TAB2
	.WORD	COLOR_RED,COLOR_BLUE

SET_UP_FOR_INPUT
	CLR	A0
	MOVE	A0,*A10(PCHAR_COUNT)
	MOVE	A10,*A13(PBLK_STOR),L	;grab plyr block data address
	MOVE	*A10(POBJ),A1,L
	JRZ	THIS_GUY_NOT_INPUTTING
	MOVE	A10,A2
	CALLA	PLAYER

	MOVE	*A10(PSCORE),A1,L
	MOVE	A1,@SCORE_DATA,L
	MOVE	A10,A2

	MOVI	PUT_SCORE_MESS,A8
	CALLA	LM_SETUP

	CALLA	GPLAYNUM

	MOVI	SCORE_COL_TAB,A14
	MOVE	@NUMBER_RACKS,A3
	JRNZ	NO_CLEVER_SCORE_COL
	MOVI	SCORE_COL_TAB2,A14
NO_CLEVER_SCORE_COL
	SLL	4,A0
	ADD	A14,A0
	MOVE	*A0,A0
	SLL	16,A0
	MOVY	A0,A5
	CLR	A0

	CALLA	BONUS_SET_X
	JSRP	PRINTF

	MOVI	INIT_FORM,A8
	CALLA	LM_SETUP
	CALLA	BONUS_SET_X
	JSRP	PRINTF

WAIT_UNTIL_FINISHED
	SLEEP	1
	MOVE	*A13(PBLK_STOR),A10,L	;grab plyr block data address
	MOVE	*A10(PCHAR_COUNT),A1
	CMPI	4,A1
	JRNE	WAIT_UNTIL_FINISHED

	CREATE	PID_JUNK,FLASH_I_BOX

	MOVE	*A10(PBONUSCORE),A1,L
	MOVE	A1,@INITIAL_1,L
	MOVE	*A10(PSCORE),A0,L
	CALLA	BINBCD
	MOVE	A10,A8
	MOVI	INITIAL_1,A1
	CLR	B1
	CALLA	TRYADD

	MOVE	*A10(PPID),A0,W
	MOVI	M_INDESTRUCT|MASK_PLAYER,A1
	CALLA	KILALL			;KILL THE PLAYER PROCESSES

	MOVE	*A10(POBJ),A0,L
	CALLA	DELOBJ			;REMOVE THE SHIT
	CLR	A0
	MOVE	A0,*A10(PEBAROBJ),L

	MOVE	A10,A2
	CALLA	PLAYER_CLR		;CLEAR OUT PLAYER GAME DATA

	SLEEP	20

THIS_GUY_NOT_INPUTTING
	MOVE	*A13(PBLK_STOR),A10,L	;grab plyr block data address
	MOVK	4,A0
	MOVE	A0,*A10(PCHAR_COUNT)
	DIE

FLASH_I_BOX
;	SOUND1	SND_DIR_CHOSEN		;sound it !

	RANDENT	TAB_HS_ENTERED,5,5,L	;Random sound to make
	CALLA	ONESND

	MOVE	*A10(PBONUSOBJ),A8,L
	JRZ	NO_FLASH_IT
	MOVI	COLOR_WHITE,A7
	MOVK	4,A4
	CALLA	JAKE_BOX
	MOVE	A6,A8
	MOVK	4,A9
FLASH_IT_AGAIN
	SLEEP	3
	MOVE	*A8(OFLAGS),A1
	ORI	M_NODISP,A1
	MOVE	A1,*A8(OFLAGS)
	SLEEP	5
	MOVE	*A8(OFLAGS),A1
	ANDI	0FFFFH-M_NODISP,A1
	MOVE	A1,*A8(OFLAGS)
	DSJS	A9,FLASH_IT_AGAIN
	CALLA	DELETE_OBJ

NO_FLASH_IT
	DIE

**********************

;WORD	ONE PIXEL
;WORD	FILLER
;LONG	YACCEL
;LONG	XVEL
;LONG	YVEL
;LONG	XPOS
;LONG	YPOS

	.BSS	LET_BIT_TABLE,((32*6)*280*3)

INITHIT
	SUBI	HS_YMIN,A9
	SUBI	HS_XMIN,A11
	MOVI	CHAR_XBOX,A7
	DIVU	A7,A11
	MOVI	CHAR_YBOX,A7
	DIVU	A7,A9
	CMPK	3,A9
	JRLO	NO_Y_DIV_WORRY
	MOVK	2,A9
NO_Y_DIV_WORRY
	MOVK	11,A1
	MPYU	A9,A1
	ADD	A11,A1
	SLL	5,A1
	ADDI	CHAR_POINTERS,A1
	MOVE	*A1,A8,L

MAKE_LETTER_EXPLODE

	MOVE	*A2(PBOMBTYPE),A14
	CMPI	3,A14
	JREQ	NO_RESET_TIMER
	INC	A14
	MOVE	A14,*A2(PBOMBTYPE)

	MOVK	30,A14			  ;INIT TIMER TO 30 SECONDS
	MOVE	A14,@TOC,L
NO_RESET_TIMER

	PUSH	A8
	MOVE	*A2(PPID),A0
	SLL	8,A0
	ORI	23,A0
	CALLA	EXISTP_ALL
	JRNZ	LETTER_STILL_EXPLODING

	MOVE	*A8(OFLAGS),A1
	ANDI	M_NODISP,A1
	JRNZ	LETTER_STILL_EXPLODING

	MOVE	*A8(OVAR9),A1
	JRNZ	NOT_HIT_END
	MOVK	4,A1
	MOVE	A1,*A2(PCHAR_COUNT)
	JRUC	YES_HIT_END
NOT_HIT_END
	DEC	A1
	JRNZ	NOT_HIT_DELETE
	MOVI	32,A1
	MOVE	*A2(PCHAR_COUNT),A3
	JRZ	STAY_WITH_IT
	DEC	A3
STAY_WITH_IT
	MOVE	A3,*A2(PCHAR_COUNT)
	SLL	3,A3
	MOVE	A2,A4
	ADDI	PBONUSCORE,A4
	ADD	A3,A4
	MOVB	A1,*A4
	JRUC	YES_HIT_END

NOT_HIT_DELETE
	INC	A1
	MOVE	*A2(PCHAR_COUNT),A3
	CMPI	3,A3
	JRLT	NO_OVERFLOW_PROB
	DEC	A3
NO_OVERFLOW_PROB
	SLL	3,A3
	MOVE	A2,A4
	ADDI	PBONUSCORE,A4
	ADD	A3,A4
	MOVB	A1,*A4
	SRL	3,A3
	INC	A3
	MOVE	A3,*A2(PCHAR_COUNT)

YES_HIT_END
	CALLA	GPLAYNUM		;GET THE PLAYERS NUMBER
	MOVI	(32*6)*280,A9
	MPYU	A0,A9
	ADDI	LET_BIT_TABLE,A9
	MOVE	*A8(OPAL),A1
	MOVE	A1,@PIX_PAL
	MOVE	A2,A10
	MOVE	*A2(PPID),A1
	SLL	8,A1
	ORI	23,A1
	MOVI	EXPLODE_LETTER,A7
	CALLA	GETPRC

	MOVE	*A2(PBONUSOBJ),A8,L
	JRZ	NO_INITIALS_TO_KILL
	CALLA	DELETE_OBJ
NO_INITIALS_TO_KILL
	PUSH	A2
	MOVE	A2,*A13(PBLK_STOR),L
	MOVE	*A2(PBONUSCORE),A1,L
	CLR	A2
	CMPI	0202020H,A1
	JREQ	NO_PRINT_ANYTHING
	MOVE	A1,@INITIAL_1,L
	MOVI	P_IFORM,A8
	CALLA	LM_SETUP
	CALLA	BONUS_SET_X
	JSRP	PRINTF
NO_PRINT_ANYTHING
	PULLQ	A10
	MOVE	A2,*A10(PBONUSOBJ),L
	MOVE	A10,A2

LETTER_STILL_EXPLODING
	PULLQ	A0
	RETS

WHICH_GLASS
	.LONG	GLASS_1
	.LONG	GLASS_2
	.LONG	GLASS_3

GLASS_1
	.word	0F180h,10H,43C0h		;Kill track 3
	.WORD	0
GLASS_2
	.word	0F280h,10H,43C1h		;Kill track 3
	.WORD	0
GLASS_3
	.word	0F380h,10H,43C2h		;Kill track 3
	.WORD	0

EXPLODE_LETTER
	SLEEP	16
	MOVE	A10,A2
	CALLA	GPLAYNUM
	SLL	5,A0
	ADDI	WHICH_GLASS,A0
	MOVE	*A0,A0,L
	CALLA ONESND

	PUSH	A9
	MOVE	*A8(ODAG),A3,L

	MOVE	@NO_MIRROR,A7,W		;Are we mirroring
	JRNZ	NO_FLIP_PIX_DAG
	MOVI	400,A7
	MOVE	A3,A1
	SUB	A1,A7
	MOVE	*A8(OSIZEX),A1
	SUB	A1,A7
	MOVX	A7,A3

NO_FLIP_PIX_DAG
	MOVX	A3,A7
	SLL	16,A7
	SRL	16,A3
	SLL	16,A3

	MOVE	A8,B0
	MOVE	*A8(OIMG),A8,L
	MOVE	*A8(ISAG),A8,L
	MOVE	A9,A2
	MOVI	010000H,A5
	MOVI	01F00H,A1
	MOVE	*B0(OSIZEY),B1
	MOVE	B1,A11
	CLR	A9
NEXT_Y_PIXELS
	MOVE	A7,A4
	MOVE	*B0(OSIZEX),B1
	MOVE	B1,A10
NEXT_X_PIXELS
	CALLR	GET_PIXEL
	DSJS	A10,NEXT_X_PIXELS
	ADD	A5,A3
	DSJS	A11,NEXT_Y_PIXELS

	PULLQ	A10
	CREATEP	PID_JUNK,ADD_PIXEL_VEL
	MOVE	B0,A8
	MOVE	*A8(OFLAGS),A1
	ORI	M_NODISP,A1
	MOVE	A1,*A8(OFLAGS)
	SLEEP	30
	MOVE	*A8(OFLAGS),A1
	ANDI	0FFFFH-M_NODISP,A1
	MOVE	A1,*A8(OFLAGS)

	MOVI	0D0DH,A1			;black, then kill object
	MOVE	A1,*A8(OCONST)
	SLEEP	2
	MOVI	0C0CH,A1			;black, then kill object
	MOVE	A1,*A8(OCONST)
	SLEEP	2
	MOVI	0B0BH,A1			;black, then kill object
	MOVE	A1,*A8(OCONST)
	SLEEP	2
	MOVI	0A0AH,A1			;black, then kill object
	MOVE	A1,*A8(OCONST)
	SLEEP	2
	MOVI	0909H,A1			;black, then kill object
	MOVE	A1,*A8(OCONST)
	SLEEP	2
	MOVI	0202H,A1			;black, then kill object
	MOVE	A1,*A8(OCONST)

	DIE

GET_PIXEL
	MOVE	*A8,A6	;GET PIXEL
	INC	A8
	SLL	31,A6
	SRL	31,A6
	MOVE	A6,*A2+,L

	MOVE	A1,*A2+,L  ;YACCEL

	MOVI	018000H,A0
	CALLA	SRAND
	SLL	1,A0
	MOVE	A0,*A2+,L  ;XVEL

	MOVI	21000H,A0
	CALLA	SRAND
	SLL	1,A0
	MOVE	A0,*A2+,L  ;YVEL

	MOVE	A4,*A2+,L  ;XPOS
	MOVE	A3,*A2+,L  ;YPOS
	ADD	A5,A4 
	INC	A9
	RETS

PIXEL_COL_OFF
	.WORD	13,13
	.WORD	12,12
	.WORD	11,11
	.WORD	10,10
	.WORD	9,9
	.WORD	2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
	.WORD	2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
	.WORD	2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
	.WORD	2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
	.WORD	2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2

ADD_PIXEL_VEL
	MOVI	40,A11
ADD_PIXEL_VEL2
	DEC	A11
	JRNZ	CONT_PIXEL_VEL
	DIE
CONT_PIXEL_VEL
	MOVE	A11,A6
	SLL	4,A6
	ADDI	PIXEL_COL_OFF,A6
	MOVE	*A6,A6
	MOVE	A6,B6

	MMTM	SP,A9,A10
	movi	DMAGOREG,B1

	MOVE	@PIX_PAL,@DMACMAPCON,L
	MOVE	*B1,B2,L		;WAIT FOR DMA TO CATCH UP

	MOVE	A10,A6
	MOVI	3*32,A7

	MOVI	512*8,B3
	SETCDP

	CLR	B4
	MOVI	8,A8
	MOVE	A8,@PSIZE
	MOVE	@PAGEADDR,A10,L

	MOVI	[252,0],A14

NEXT_PIXEL_VEL

	MMFM	A6,A0,A1,A2,A3,A4,A5

	MOVE	A5,A5
	JRZ	NO_PLOT_ANYTHING
	MOVE	B6,A5

	ADD	A4,A2	;DO YACCEL
	JRZ	NO_PLOT_ANYTHING

	ADD	A2,A0	;Y
	CMP	A14,A0
	JRLE	NO_WORRY_ABOUT_Y_BOUNCE
	CALLR	DO_BOUNCE
NO_WORRY_ABOUT_Y_BOUNCE

	ADD	A3,A1	;X

	MMTM	A6,A0,A1,A2

	SRL	16,A1
	MOVX	A1,A0
	ADDXY	A10,A0

	CVXYL	A0,A1
	MOVB	A5,*A1
	ADD	A7,A6
NO_PLOT_ANYTHING

	DSJS	A9,NEXT_PIXEL_VEL
	MMFM	SP,A9,A10

	SLOOP	1,ADD_PIXEL_VEL2

DO_BOUNCE
	SUB	A2,A0
	NEG	A2
	PUSH	A1
	MOVE	A2,A1
	SRA	1,A1
	SUB	A1,A2
	PULLQ	A1
	MOVE	A2,B0
	ABS	B0
	SRL	16,B0
	JRNZ	NO_WORRY_ABOUT_Y_BOUNCE2
	CLR	A2
	MOVE	A2,*A6(20H-0C0H),L
	MOVE	A2,*A6(60H-0C0H),L
NO_WORRY_ABOUT_Y_BOUNCE2
	RETS
********************************

A_Z1
	MESS_MAC RD20FONT,17,25,100,COLOR_PWHITE,STRLNRMOF,OID_P1MOTEXT
	.STRING   "A B C D E F G H ",C_REG," J K"
	.STRING "\nL M N O P Q R S T U V" 
	.STRING "\nW X Y Z * ! ? - _ ",C_TM," ",C_COPY,0
	.EVEN

PUT_SCORE_MESS
	MESS_MAC RD20FONT,2,62+5,230,COLOR_PLF,STRCNRMO,OID_P1MOTEXT
	.STRING	"%,ld",0
	.LONG	SCORE_DATA
	.EVEN

**************************************************************************
*								         *
* 	TIMER_PROC							 *
* 									 *
* 	TIMER PROCESS							 *
* 									 *
* 	ENTRY								 *
* 		NOTHING							 *
* 									 *
* 	EXIT								 *
* 		NOTHING							 *
*								         *
**************************************************************************

TIMER_PROC
	MOVK	30,A14			  ;INIT TIMER TO 30 SECONDS
TICK	MOVE	A14,@TOC,L
	MOVI	TIMER_MESS,A8
	JSRP	LM_PRINTF		  ;DISPLAY TIME LEFT
	MOVE	A2,A8
	SLEEP	60			  ;1 SECOND DELAY
	CALLA	DELETE_OBJ
	MOVE	@P1DATA+PCHAR_COUNT,A0
	MOVE	@P2DATA+PCHAR_COUNT,A1
	MOVE	@P3DATA+PCHAR_COUNT,A2
	AND	A1,A2
	AND	A2,A0
	CMPI	4,A0			  ;CHECK IF PLAYER 2 IS DONE
	JRNE	MOTIME			  ;BR = NO
	MOVI	-1,A14 		  ;YES, BOTH ARE DONE
	JRUC	TDONE			  ;ZERO TIME LEFT
MOTIME	MOVE	@TOC,A14,L		  ;DECREMENT TIME LEFT
	DEC	A14
	JRNZ 	TICK			  ;NEXT LOOP THINGY

	MOVE	@P1DATA+PBONUSCORE,A1,L
	MOVE	A1,@INITIAL_1,L
	MOVE	@P1DATA+PSCORE,A0,L
	CALLA	BINBCD
	MOVI	P1DATA,A8
	MOVI	INITIAL_1,A1
	CLR	B1
	CALLA	TRYADD

	MOVE	@P2DATA+PBONUSCORE,A1,L
	MOVE	A1,@INITIAL_1,L
	MOVE	@P2DATA+PSCORE,A0,L
	CALLA	BINBCD
	MOVI	P2DATA,A8
	MOVI	INITIAL_1,A1
	CLR	B1
	CALLA	TRYADD

	MOVE	@P3DATA+PBONUSCORE,A1,L
	MOVE	A1,@INITIAL_1,L
	MOVE	@P3DATA+PSCORE,A0,L
	CALLA	BINBCD
	MOVI	P3DATA,A8
	MOVI	INITIAL_1,A1
	CLR	B1
	CALLA	TRYADD
	MOVI	-1,A14
TDONE	MOVE	A14,@TOC,L		  ;SAVE ZERO 
	DIE				  ;GOODBYE

**************************************************************************
*								         *
* 	ATT_HSTD							 *
* 									 *
* 	ATTRACT MODE HIGH-SCORE TABLE PAGE				 *
* 									 *
* 	ENTRY								 *
* 		NOTHING							 *
* 									 *
* 	EXIT								 *
* 		NOTHING							 *
*								         *
**************************************************************************
ATT_HSTD:
	CALLA	WIPEOUT
	CLRM	@SCRNTL,L
	MOVKM	3,@GAMERASE,W
	DISPON
	CLR	A0
	CALLA	FADEBLAK
	SLEEP	1

	MOVKM	1,@BLACKOUT,W
	CALLA	INIT_LINKED_LIST	;Initialize the Background links

	MOVI	-010000H,A0
	SLL	ZFRAC,A0
	MOVE	A0,@ZBASE_HR,L
	MOVI	19C000H,A0
	MOVE	A0,@XBASE,L
	CLR	A0
	MOVE	A0,@YBASE,L

	MOVI	LA_OUTSIDE1_VECT_TABLE,A14
	MOVE	A14,@WVT_PTR,L				;STUFF WAVE VECTOR TABLE PTR

	MOVI	GXEVLOB3,A0
	JSRP	START_UNIVERSE
	SLEEP	4

	CLR	A10
	MOVE	A10,@BLACKOUT
	CLR	A0
	CALLA	FADEIN_HALF_3
	SLEEP	16
	CALLA	FADEFULL_TEXT
	SLEEP	3

	MOVK	1,A0
	MOVE	A0,@ON_HSTD,W		; FLAG THE HSTD PAGE
	
	MOVI	TOD_TAB,A8
	CALLR	VAL_TAB			; CHECK TO SEE IF WE HAVE A TABLE
	JRC	ATTOUTTAHERE
	MOVI	ALL_TAB,A8
	CALLR	VAL_TAB
	JRC	ATTOUTTAHERE

	CLR	A0			   ;CLEAR PLAYER 1 AND 2 CHARACTER
	CALLA	GPLAYD			   ;POSITIONS FOR PULSING PROCESSES
	CLR	A1
	MOVB	A1,*A2(PCHAR_COUNT)

	MOVK	1,A0
	CALLA	GPLAYD
	MOVB	A1,*A2(PCHAR_COUNT)


	MOVI	GREEN_TO_BLACK,A0
	CALLA	GETFPAL
	MOVE	A0,@GREEN_PAL
	MOVI	RED_TO_BLACK,A0
	CALLA	GETFPAL
	MOVE	A0,@RED_PAL
	MOVI	YEL_TO_BLACK,A0
	CALLA	GETFPAL
	MOVE	A0,@YEL_PAL
	MOVI	BLUE_TO_BLACK,A0
	CALLA	GETFPAL
	MOVE	A0,@BLUE_PAL
	MOVI	WHITE_TO_BLACK,A0
	CALLA	GETFPAL
	MOVE	A0,@WHITE_PAL

	SLEEP	3

	MOVK	2,A5				; LOOP TWICE 
TABLELP 
	MOVE	A5,*A13(PDATA+080H),L

	MOVE	*A13(PDATA+080H),A5,L	; CHECK FOR FIRST TIME

	SLEEP	2

	MOVE	*A13(PDATA+080H),A5,L	; CHECK FOR FIRST TIME
	CMPI	1,A5
	JREQ	TJMP0

	MOVI	TODAY_MESS,A8		; 2ND TIME, TODAYS
;	MOVI	ALL_MESS,A8		; FIRST TIME, ALL TIME
	JSRP	LM_PRINTF
	JRUC	CJMP

TJMP0
	MOVI	ALL_MESS,A8		; FIRST TIME, ALL TIME
;	MOVI	TODAY_MESS,A8		; 2ND TIME, TODAYS
	JSRP	LM_PRINTF
CJMP

	MOVI	CREDIT_TEXT,A8		; DISPLAY NUMBER OF CREDITS
	CALLA	LM_SETUP
	CALLA	GET_CSTR	  	; GET THE CREDIT STRING
	JSRP	PRINTF			; PRINT THE SCORE THING

	MOVE	*A13(PDATA+080H),A5,L	; CHECK FOR 2ND TIME
	CMPI	2,A5
	JREQ	TJMP1

	MOVI	COLOR_WHITE,A5
	MOVE	A5,@COLPTRF,L
	MOVI	ALL_TAB,A8

;	MOVI	COLOR_GREEN,A5
;	MOVE	A5,@COLPTRF,L
;	MOVI	TOD_TAB,A8
	MOVE	A8,*A13(PDATA+0A0H),L	; STORE TABLE
	JSRP	PLOT_TABLE
	JRUC	FJMP

TJMP1 
;	MOVI	COLOR_WHITE,A5
;	MOVE	A5,@COLPTRF,L
;	MOVI	ALL_TAB,A8
	MOVI	COLOR_GREEN,A5
	MOVE	A5,@COLPTRF,L
	MOVI	TOD_TAB,A8

	MOVE	A8,*A13(PDATA+0A0H),L	; SAVE TABLE
	JSRP	PLOT_TABLE

FJMP
	MOVK	1,A5		        ; TWICE FOR FADE CYCLE LOOP
FCLP	MOVE	A5,*A13(PDATA+0E0H),L
	
	MOVK	10,A5			; 10 ENTERIES TO PULSE
FADELP	
	MOVE	A5,*A13(PDATA+060H),L
	MOVE	A5,A0
	SUBK	11,A0
	NEG	A0			; CALC ENTRY NUMBER
	MOVE	*A13(PDATA+0A0H),A8,L	; LOAD TABLE 
	MOVE	A5,A9

	JSRP	PLOT_ENTRY		; PLOT TABLE ENTRY (FOR PULSING) 

	SLEEP	22

	MOVE	*A13(PDATA+060H),A5,L
	DEC	A5
	CMPI	2,A5
	JRNE	FADELP
	SLEEP	10
	MOVE	*A13(PDATA+0E0H),A5,L	; NEXT CYCLE OF PULSING THE TABLE
	DSJ	A5,FCLP
	MOVI	OID_TEXT,A0			;kill all hiscore text
	CALLA	KILOBJ_ALL

	MOVE	*A13(PDATA+080H),A5,L
	DSJ	A5,TABLELP		; DO THE OTHER TABLE (TODAYS BEST)

ATTOUTTAHERE
	CLR	A0
	MOVE	A0,@ON_HSTD,W	     	; DISABLE FLAG
	MOVK	1,A0
	MOVE	A0,@INGAMEOV,W		; ENABLE FLAG

	CLR	A10
	CLR	A0
	CALLA	FADE_HALF2BLAK

	MOVI	TEXTPAL,A0
	CALLA	FADEOUT_PALF
	SLEEP	16
	RETP

ARE_WE_NEW_HS
	PUSH	A0
	MOVE	A0,@CHAR_NUM,W
	CALLR	FETCH_SCORE	    	; GET THE SCORE
	MOVE	A1,@CHAR_SCORE,L
	CALLR	ENTRY_PTR	    	; POINT TO THE RIGHT ENTRY
	ADDI	HS_COL,A7
	CALLR	RC_WORD			; GET COLOR STUFF
	MOVE	A0,A1
	PULLQ	A0
	RETS

CREDIT_TEXT:
	MESS_MAC RD7FONT,1,198,246,COLOR_PRED,STRCNRMOS,0
	.EVEN


BLACK2HALF
	.word	0,8,16,24,32,40,48,56,64
	.word	72,80,0FFFFH,88,96,104,112,120,128,0FFFFH

**************************************************************************
*								         *
* 	STRCMP								 *
* 									 *
* 	COMPARE TWO STRINGS						 *
* 									 *
* 	ENTRY								 *
* 		A0 AND A8	DA STRINGS				 *
* 									 *
* 	EXIT								 *
* 		Z = 1 (SET), STRINGS EQUAL				 *
*		Z = 0 (CLR), NOT EQUAL 				         *
**************************************************************************

STRCMP	MMTM	SP,A1,A2,A9
	MOVK	3,A2
NEXTCMP	MOVB	*A0,A1
	MOVB	*A8,A9
	CMP	A1,A9
	JRNE	CMPDONE
	ADDK	8,A0
	ADDK	8,A8
	DSJ	A2,NEXTCMP
	SETZ
CMPDONE MMFM	SP,A1,A2,A9
	RETS	
	
**************************************************************************
*								         *
* 	PLOT_TABLE							 *
* 									 *
* 	PLOT OUT A TABLE AT A GIVEN SET OF TABLE LOCS			 *
* 									 *
* 	ENTRY								 *
* 		A8	POINTER TO CMOS TABLE				 *
* 									 *
* 	EXIT								 *
* 		NOTHING							 *
*								         *
**************************************************************************

ZIP_ACROSS	.EQU	25
PLOT_TABLE:
	MOVK	1,A0			; START AT TABLE ENTRY 1
	MOVI	(26+HSTDY)*65536+106,A9	; INITIAL SCRN LOCATION
PTLOOP
	MOVE	A9,*A13(PDATA+060H),L	; SAVE SCRN LOCATION
	CMPI	9,A0
	JREQ	PTDONE			; NO MORE TO PLOT
	MOVE	A0,*A13(PDATA),L	; SAVE ENTRY NUMBER
	MOVE	A8,*A13(PDATA+040H),L	; SAVE PTR TO TABLE

	MOVE	@COLPTRF,@COLPTR,L
	JSRP	PLOT_ENTRY		; PLOT IT

	MOVE	*A13(PDATA),A0,L	; RESTORE ENTRY NUMBER
	MOVE	*A13(PDATA+040H),A8,L	; RESTORE PTR TO TABLE
	PUSHP	A0
	SLEEP	ZIP_ACROSS+10
	PULLP	A0
NOFIRST	INC	A0			; NEXT ENTRY
	MOVE	*A13(PDATA+060H),A9,L	
	ADDI	26*65536,A9		; NEXT SCRN LOCATION
	JRUC	PTLOOP
PTDONE
	RETP

**************************************************************************
*								         *
* 	PLOT_ENTRY							 *
* 									 *
* 	PLOT A HIGHSCORE TABLE ENTRY					 *
* 									 *
* 	ENTRY								 *
* 		A0	ENTRY						 *
* 		A8	POINTER TO CMOS TABLE TO USE			 *
* 		A9	LOCATION ON SCREEN				 *
* 									 *
* 	EXIT								 *
* 		NOTHING							 *
* 									 *
* NOTE: TRASHES A8,A9,A10,A11						 *
*								         *
**************************************************************************
PLOT_ENTRY:
	MOVE	A0,@CHAR_NUM,W
	CALLR	FETCH_SCORE	    	; GET THE SCORE
	MOVE	A1,@CHAR_SCORE,L
	CALLR	ENTRY_PTR	    	; POINT TO THE RIGHT ENTRY
	MOVI	2020H,A0
	MOVE	A0,@CHAR_PLOT,L	    	; SPACES
	MOVI	2000H,A0
	MOVE	A0,@CHAR_PLOT+32,L  	; SPACE AND A ZERO TERMINATE
	MOVE	A7,A1		    	; SAVE IT AROUND
	ADDI	HS_INITS,A7	    	; GET TO THE INITIALS
	CALLR	RC_BYTEI
	MOVB	A0,@CHAR_PLOT
	CALLR	RC_BYTEI
	MOVB	A0,@CHAR_PLOT+8
	CALLR	RC_BYTEI
	MOVB	A0,@CHAR_PLOT+16

	MOVE	A1,A7
	ADDI	HS_COL,A7
	CALLR	RC_WORD			; GET COLOR STUFF

	MOVE	A0,A0
	JRZ	PELITTLE

	MOVI	COLOR_RED,A14
	DEC	A0
	JRZ	PRINT_COL_SET

	MOVI	COLOR_YELLOW,A14

	MOVE	@NPLAYERS,A10,W		;how many players are able to play
	CMPI	1,A10
	JREQ	SET_COLOR_AS_BLUE

	DEC	A0
	JRZ	PRINT_COL_SET

SET_COLOR_AS_BLUE
	MOVI	COLOR_BLUE,A14

PRINT_COL_SET
	MOVE	A14,@COLPTR,L

PELITTLE
	CLR	A14			; CLEAR NO DELAY FLAG
	MOVE	A14,*A13(PDATA+0C0H),L	; STORE NO DELAY FLAG
	CMPI	10,A9			; CHECK FOR SINGLE SCORE OR TABLE
	JRHI	PNORM			; BR = TABLE (DON'T NEED LOCATION)
	INC	A14			; SET NO DELAY FLAG
	MOVE	A14,*A13(PDATA+0C0H),L	; STORE NO DELAY FLAG
	MOVI	(26+HSTDY)*65536+106,A6	; CALC SCRN LOCATION
	SUBI	11,A9
	NEG	A9
	DEC	A9
	MOVI	26*65536,A8
	MPYU	A8,A9
	ADD	A6,A9
PNORM	MOVE	A9,A6			; SAVE SCRN LOCATION
	PUSHP	A9
	PUSHP	A9
	MOVI	HSTD_NUM,A8	    	; DISPLAY ENTRY NUMBER
	CALLA	LM_SETUP
	ADDI	8,A6			; MINOR ADJUSTMENT ON LOCATION
	MOVE	A6,A9			; SET LOCATION
	CLR	A0			; SET FOR NO SLEEP
	MOVE	*A13(PDATA+0C0H),A14,L	; GET NO DELAY FLAG
	CMPI	1,A14			; CLEAR DELAY?
	JRNE	PF0			; BR = NO
	JSRP	START_HI_FLASH
	JRUC	PF0A
PF0	JSRP	PRINTF
	CALLR	SETUP_RESET_AND_MOVE
PF0A
	PULLP	A6			; RESTORE 
	MOVI	HSTD_MESS,A8		; DISPLAY ENTRY INITIALS
	CALLA	LM_SETUP

	CALLA	READ_SW1_SW2
	BTST	P1BOMB,A0
	JRNZ	NOER
	BTST	P2TRIGGER,A0
	JRNZ	NOER

	MOVE	A8,A9
	MOVI	ERSTR,A0
	MOVI	CHAR_PLOT,A8
	CALLR	STRCMP
	JRZ	DOER
	MOVI	ROSTR,A0
	MOVI	CHAR_PLOT,A8
	CALLR	STRCMP
	JRZ	DORO
	MOVE	A9,A8
	JRUC	NOER
DOER	MOVI	ER_STR,A8
	JRUC	NOER
DORO	MOVI	RO_STR,A8
NOER	MOVE	A6,A9			; SET LOCATION
	CLR	A0			; SET FOR NO SLEEP
	MOVE	*A13(PDATA+0C0H),A14,L
	CMPI	1,A14  			; CLEAR DELAY?
	JRNE	PF1			; BR = NO
	JSRP	START_HI_FLASH
	JRUC	PF1A
PF1	JSRP	PRINTF
	CALLR	RESET_AND_MOVE
PF1A
	PULLP	A6			; RESTORE
	ADDI	215,A6			; ANOTHER MINOR ADJUSTMENT ON LOC
	MOVI	HSTD_SCORE,A8		; DISPLAY ENTRY SCORE
	CALLA	LM_SETUP
	MOVE	A6,A9			; SET LOCATION
	CLR	A0			; SET FOR NO SLEEP
	MOVE	*A13(PDATA+0C0H),A14,L
	CMPI	1,A14  			; CLEAR DELAY?
	JRNE	PF2			; BR = NO
	JSRP	START_HI_FLASH
	JRUC	PF2A
PF2	JSRP	PRINTF
	MOVE	*A13(PDATA+0C0H),A14,L
	CALLR	RESET_AND_MOVE
PF2A
PERET
	RETP

CONVERT_COL_TO_PAL
	.LONG	0,RED_PAL,WHITE_PAL,BLUE_PAL
	.LONG	0,YEL_PAL,0,GREEN_PAL

START_HI_FLASH
	MMTM	A12,A0,A1,A2,A3,A4,A5,A7,A8,A9
	CLR	A2
	JSRP	PRINTF
	MOVE	A2,A5
	JRZ	NO_NEED_TO_PULSE

	MOVI	080000H,A0
	MOVE	A5,A8
MOVE_NEW_BEHIND_OLD
	MOVE	A0,*A8(OZVAL),L
	MOVE	*A8(OPARTS),A8,L
	JRNZ	MOVE_NEW_BEHIND_OLD

	MOVE	A5,A8
	PUSHP	A5
COMP_EACH_LET
	MOVE	*A8(OXPOS),A3
	MOVE	*A8(OYPOS),A4
	MOVI	FGLIST,A0
	MOVE	A0,A9
COMP_NEXT_LET
	MOVE	*A0,A0,L
	CMP	A0,A9
	JREQ	COULDNT_FIND_IT
	CMP	A0,A8
	JREQ	COMP_NEXT_LET
	MOVE	*A0(OXPOS),A1
	MOVE	*A0(OYPOS),A2
	CMP	A1,A3
	JRNE	COMP_NEXT_LET
	CMP	A2,A4
	JRNE	COMP_NEXT_LET

	PUSH	A8
	MOVE	A0,A8

	MOVE	*A8(OPAL),*A8(OVAR6),L
	MOVE	*A8(OCONST),A0
	SRL	8,A0
	SLL	5,A0
	ADDI	CONVERT_COL_TO_PAL,A0
	MOVE	*A0,A1,L
	MOVE	*A1(0),*A8(OPAL)

	MOVI	0F0FH,A0
	MOVE	A0,*A8(OCONST)
	MOVK	15,A9

	CREATE	PID_JUNK,WAIT_AND_RESET_PAL

	PULLQ	A8

	SLEEP	1

COULDNT_FIND_IT
	MOVE	*A8(OPARTS),A8,L
	JRNZ	COMP_EACH_LET
	PULLP	A5
	MOVE	A5,A8
	CALLA	DELETE_OBJ
NO_NEED_TO_PULSE
	MMFM	A12,A0,A1,A2,A3,A4,A5,A7,A8,A9
	RETP

WAIT_AND_RESET_PAL
	SLEEP	2
	CLR	A0
	MOVE	A9,A0
	SLL	8,A0
	OR	A9,A0
	MOVE	A0,*A8(OCONST)
	DSJS	A9,WAIT_AND_RESET_PAL
	MOVE	*A8(OVAR6),*A8(OPAL),L
	DIE


SETUP_RESET_AND_MOVE
	MOVE	A2,A2
	JRZ	FINISHED_TEXT
	MOVE	*A2(OXPOS),A1
	MOVE	A1,@LINE_STARTXY
RESET_AND_MOVE
	MOVE	A2,A8
	CALLR	ZIP_TEXT_ACROSS
RESET_AND_MOVE_2
	MOVE	*A2(OPARTS),A8,L
	JRZ	FINISHED_TEXT
	CALLA	PULL_PART
	CALLR	ZIP_TEXT_ACROSS
	JRUC	RESET_AND_MOVE_2
FINISHED_TEXT
	RETS

ZIP_TEXT_ACROSS
	MOVE	*A8(OXPOS),A1
	MOVE	A1,*A8(OVAR9)

	MOVE	@LINE_STARTXY,A3
	MOVE	A3,A5
	SUB	A5,A1
	SLL	16,A1
	MOVI	ZIP_ACROSS,A5
	DIVU	A5,A1
	MOVE	A1,*A8(OXVEL),L

	MOVE	A3,*A8(OXPOS)
	MOVE	A3,*A8(ODAG)

	CREATE	PID_JUNK,MOVE_TEXT_ACROSS
	RETS

MOVE_TEXT_ACROSS
	SLEEP	ZIP_ACROSS
	CLR	A0
	MOVE	A0,*A8(OXVEL),L
	MOVE	*A8(OVAR9),*A8(OXPOS)
	DIE


FLASHTABLE
	.WORD	0101H, 0606H, 0101H, 0606H

FLASHPAL
	.LONG	TEXTPAL, TEXTPAL, TEXTPAL, TEXTPAL

COLTABLE
	.LONG	TEXTPAL, TEXTPAL, TEXTPAL, TEXTPAL

**************************************************************************
*								         *
* 	FETCH_SCORE							 *
* 									 *
* 	GET THE SCORE FOR A GIVEN ENTRY IN THE HIGHSCORE TABLE		 *
* 									 *
* 	ENTRY								 *
* 		A0	ENTRY NUMBER					 *
* 		A8	TABLE TO GET SCORE FROM				 *
* 									 *
* 	EXIT								 *
* 		A1	SCORE						 *
*								         *
**************************************************************************
FETCH_SCORE:
	MMTM	SP,A9,A10
	CALLA	ROM_PTRS		;GET SYSTEM READY TO ACCESS THIS ONE
	CALLA	GET_HSCR		;NOW FETCH THE SCORE IN A1.
	MMFM	SP,A9,A10
	RETS

**************************************************************************
*								         *
* 	ENTRY_PTR							 *
* 									 *
* 	SET A7 TO POINT TO A GIVEN SCORE ENTRY				 *
* 									 *
* 	ENTRY								 *
* 		A0	ENTRY NUMBER					 *
* 		A8	TABLE TO GET SCORE ENTRY FROM			 *
* 									 *
* 	EXIT								 *
* 		A7	POINTER TO TABLE ENTRY				 *
*								         *
**************************************************************************
ENTRY_PTR:
	MMTM	SP,A9,A10
	CALLA	ROM_PTRS		;SETUP STUFF
	CALLA	PT_ENTRY		;POINT A7 AT ENTRY
	MMFM	SP,A9,A10
	RETS

**************************************************************************
*								         *
* CLEAR_HSCOLORS - CLEAR OUT THE PLAYER COLOR INDICATOR ON ALL OF THE	 *
* 		 CURRENT HIGH SCORES.					 *
*								         *
**************************************************************************
CLEAR_HSCOLORS
	MMTM	SP,A0,A1,A7,A8
	calla	CMOSUNLOCK
	MOVI	TOD_TAB,A8
	MOVK	10,A0
CTL1
	CALLR	ENTRY_PTR
	PUSH	A0
	CLR	A0
	ADDI	HS_COL,A7
	CALLR	WC_WORD
	PULL	A0
	PUSH	A8
	CALLA	ROM_PTRS
	CALLR	FORM_HS_CKSUM_AND_STORE
	PULL	A8
	DSJS	A0,CTL1

	MOVI	ALL_TAB,A8
	MOVK	20,A0
CTL2
	CALLR	ENTRY_PTR
	PUSH	A0
	CLR	A0
	ADDI	HS_COL,A7
	CALLR	WC_WORD
	PULL	A0
	PUSH	A8
	CALLA	ROM_PTRS
	CALLR	FORM_HS_CKSUM_AND_STORE
	PULL	A8
	DSJS	A0,CTL2
	calla	CMOSLOCK
	MMFM	SP,A0,A1,A7,A8
	RETS

*****************************************************************************
*****************************************************************************
*****
*****    DEFAULT ROM HSTD TABLES AND TABLE DEFINITIONS
*****
*****************************************************************************
*****************************************************************************

TB_POINTER       EQU     0                      ;LONG-POINTER TO BEGINNING OF TABLE
TB_COUNT         EQU     TB_POINTER+LONG_SIZE   ;WORD....# IN THE TABLE.
TB_VISIBLE       EQU     TB_COUNT+WORD_SIZE ;WORD....NUMBER DISPLAYED
TB_PAGE_BITS     EQU     TB_VISIBLE+WORD_SIZE     ;WORD....STATUS WORD FOR CMOS PAGE
TB_FACTORY       EQU     TB_PAGE_BITS+WORD_SIZE   ;LONG....ROM STARTUP TABLE
TB_ERROR_COUNT   EQU     TB_FACTORY+LONG_SIZE     ;WORD....NUM ERRORS TO RE-INIT
*

SCR_M    .MACRO  SCRM1,SCRM2,SCRM3,SCRM4
         .BYTE   :SCRM1:
         .BYTE   :SCRM2:
         .BYTE   :SCRM3:
         .BYTE   :SCRM4:
         .ENDM

INIT_M   .MACRO  IM1,IM2,IM3
         .BYTE   :IM1:
         .BYTE   :IM2:
         .BYTE   :IM3:
         .BYTE   0               ;CHECKBYTE
         .ENDM

ALL_TIME_ROM_TABLE:
         SCR_M   01H,50H,00H,00H
	.WORD	0
         INIT_M  'G','N','P'
ROM_ENTRY_SIZE      EQU     $-ALL_TIME_ROM_TABLE
         SCR_M   01H,00H,00H,00H
	.WORD	0
         INIT_M  'S','V','T'           ;1	STEVEN
         SCR_M   00H,95H,00H,00H
	.WORD	0
         INIT_M  'A','J','P'           ;2	JOE
         SCR_M   00H,90H,00H,00H
	.WORD	0
         INIT_M  'B','E','W'           ;3	BRAD
         SCR_M   00H,85H,00H,00H
	.WORD	0
         INIT_M  'T','W','H'           ;4       TOM
         SCR_M   00H,80H,00H,00H
	.WORD	0
         INIT_M  'J','M','K'           ;5	JOEY
         SCR_M   00H,75H,00H,00H
	.WORD	0
         INIT_M  'T','J','C'           ;6	TIM
         SCR_M   00H,70H,00H,00H
	.WORD	0
         INIT_M  'K','A','G'           ;7	KEITH GARDE
         SCR_M   00H,65H,00H,00H
	.WORD	0
         INIT_M  'R','A','F'           ;8	ROB
         SCR_M   00H,60H,00H,00H
	.WORD	0
         INIT_M  'D','A','S'           ;9	DANNY SIMON
         SCR_M   00H,55H,00H,00H
	.WORD	0
         INIT_M  'E','D','M'           ;10	ED MARSH
         SCR_M   00H,50H,00H,00H
	.WORD	0
         INIT_M  'A','G','F'           ;11	ANDRES FALK
         SCR_M   00H,50H,00H,00H
	.WORD	0
         INIT_M  'E','J','B'           ;12
         SCR_M   00H,50H,00H,00H
	.WORD	0
         INIT_M  'A','K','N'           ;13
         SCR_M   00H,50H,00H,00H
	.WORD	0
         INIT_M  'L','E','B'           ;14
         SCR_M   00H,50H,00H,00H
	.WORD	0
         INIT_M  'C','L','B'           ;15
         SCR_M   00H,50H,00H,00H
	.WORD	0
         INIT_M  'D','U','X'           ;16	NOSTALGIA
         SCR_M   00H,50H,00H,00H
	.WORD	0
         INIT_M  'N','D','N'           ;17
         SCR_M   00H,50H,00H,00H
	.WORD	0
         INIT_M  'S','S','R'           ;18
         SCR_M   00H,50H,00H,00H
	.WORD	0
         INIT_M  'M','R',' '           ;19
         SCR_M   00H,50H,00H,00H
	.WORD	0
         INIT_M  'B','I','G'           ;20
         SCR_M   00H,50H,00H,00H
	.WORD	0
         INIT_M  'L','E','P'
         SCR_M   00H,50H,00H,00H
	.WORD	0
         INIT_M  'M','D','R'
         SCR_M   00H,50H,00H,00H
	.WORD	0
         INIT_M  'B','A','C'
         SCR_M   00H,50H,00H,00H
	.WORD	0
         INIT_M  'W',' ','R'
         SCR_M   00H,50H,00H,00H
	.WORD	0
         INIT_M  'M','P','T'
         SCR_M   00H,50H,00H,00H
	.WORD	0
         INIT_M  'S','U','E'
         SCR_M   00H,50H,00H,00H
	.WORD	0
         INIT_M  'M','O','M'
         SCR_M   00H,50H,00H,00H
	.WORD	0
         INIT_M  'D','A','D'
         SCR_M   00H,50H,00H,00H
	.WORD	0
         INIT_M  'S','F','D'
         SCR_M   00H,50H,00H,00H
	.WORD	0
         INIT_M  'A','K','D'
ALL_TIME_ENTRIES     EQU     ($-ALL_TIME_ROM_TABLE)/ROM_ENTRY_SIZE

TODAYS_ROM_TABLE:
         SCR_M   00H,31H,08H,65H
	.WORD	0
         INIT_M  'G','N','P'
         SCR_M   00H,31H,08H,65H
	.WORD	0
         INIT_M  'G','N','P'			;GEORGE
         SCR_M   00H,30H,00H,00H
	.WORD	0
         INIT_M  'J','E','H'			;JACK
         SCR_M   00H,28H,00H,00H
	.WORD	0
         INIT_M  'D','O','Z'			;DOZER
         SCR_M   00H,26H,00H,00H
	.WORD	0
         INIT_M  'W','B','D'			;WARREN
         SCR_M   00H,24H,00H,00H
	.WORD	0
         INIT_M  'S','A','B'			;STEVE
         SCR_M   00H,22H,00H,00H
	.WORD	0
         INIT_M  'M','A','M'			;MARTY
         SCR_M   00H,20H,00H,00H
	.WORD	0
         INIT_M  'J','C','V'			;JOHN
         SCR_M   00H,18H,00H,00H
	.WORD	0
         INIT_M  'J','M','S'			;JAKE
         SCR_M   00H,16H,00H,00H
	.WORD	0
         INIT_M  'C','P','G'			;GRANNER
         SCR_M   00H,14H,00H,00H
	.WORD	0
         INIT_M  'J','R','N'			;NEWCOMER
TODAYS_ENTRIES     EQU     ($-TODAYS_ROM_TABLE)/ROM_ENTRY_SIZE

**************************************************************************
*								         *
* 	STUFF FOR ATT_HSTD						 *
*								         *
**************************************************************************

HSTDY	EQU	(SKYTOPOF/2)

INIT_FORM:
	MESS_MAC RD20FONT,20,62+5,205,COLOR_PWHITE,STRCNRMOF,OID_P1MOTEXT
	.STRING	"___",0
	.EVEN
	
INIT_TABLE:
	MESS_MAC RD15FONT,1,56,155,COLOR_PRED,STRCNCO,OID_INIT
STRLOC:	.STRING "%c",0
	.LONG	CHAR_VAL
	.EVEN

	.IF GERMAN

HSE_MESS:
	MESS_MAC RD15FONT,16,200,20,COLOR_PRED,STRCNCOF,OID_TEXT
	.STRING	"TRAGE DEINE INITIALEN EIN",0
	.EVEN

TODAY_MESS:
	MESS_MAC RD15FONT,3,200,HSTDY,COLOR_PLF,STRCNRMOS,OID_TEXT
	.STRING	"TAGES-HIGH SCORE",0
	.EVEN

ALL_MESS:
	MESS_MAC RD15FONT,3,200,HSTDY,COLOR_PLF,STRCNRMOS,OID_TEXT
	.STRING	"BISHERIGER HIGH SCORE",0
	.EVEN

	.ELSE

HSE_MESS:
	MESS_MAC RD20FONT,10,190,60,COLOR_PRED,STRCNRMO,OID_TEXT
	.STRING	"ENTER YOUR INITIALS",0
	.EVEN

TODAY_MESS:
	MESS_MAC RD20FONT,2,200,HSTDY,COLOR_PLF,STRCNRMOS,OID_TEXT
	.STRING	"TODAY'S REVOLUTIONARIES",0
	.EVEN

ALL_MESS:
	MESS_MAC RD20FONT,2,200,HSTDY,COLOR_PLF,STRCNRMOS,OID_TEXT	
	.STRING	"ALL TIME REVOLUTIONARIES",0
	.EVEN

	.ENDIF

HSTD_NUM:
	MESS_MAC RD20FONT,13,200,95+HSTDY,COLOR_PBLUE,STRRNRMOF,20000H|OID_TEXT
	.STRING	"\*b%d) ",0
	.LONG	COLPTR
	.LONG	CHAR_NUM
	.EVEN

HSTD_MESS:
	MESS_MAC RD20FONT,19,200,95+HSTDY,COLOR_PRED,STRLNRMOF,20000H|OID_TEXT
	.STRING	"\*b%s",0
	.LONG	COLPTR
	.LONG	CHAR_PLOT
ER_STR	.STRING	"\*b%sER",0
	.LONG	COLPTR
	.LONG	CHAR_PLOT
RO_STR	.STRING	"\*b%sRO",0
	.LONG	COLPTR
	.LONG	CHAR_PLOT
	.EVEN

ERSTR	.STRING "DOZ"
ROSTR	.STRING "PET"

HSTD_SCORE:
	MESS_MAC RD20FONT,12,200,95+HSTDY,COLOR_PYELLOW,STRRNRMOF,20000h|OID_TEXT
	.STRING	"\*b%,lb",0
	.LONG	COLPTR
	.LONG	CHAR_SCORE
	.EVEN

P_IFORM:
	MESS_MAC RD20FONT,20,62+8,200,COLOR_PLF,STRCNRMOF,OID_P1TEXT
	.STRING "%s",0
	.LONG	INITIAL_1		
	.EVEN

TIMER_MESS:
	MESS_MAC RD15FONT,3,200,37,COLOR_PRED,STRCNCO,OID_BTIME
	.STRING "%d",0
	.LONG	TOC
	.EVEN

GREEN_TO_BLACK
	.WORD	16
	.WORD	31*GRMUL,29*GRMUL,27*GRMUL,25*GRMUL
	.WORD	23*GRMUL,21*GRMUL,19*GRMUL,17*GRMUL
	.WORD	15*GRMUL,13*GRMUL,11*GRMUL,9*GRMUL
	.WORD	7*GRMUL,5*GRMUL,3*GRMUL,1*GRMUL

RED_TO_BLACK
	.WORD	16
	.WORD	31*RDMUL,29*RDMUL,27*RDMUL,25*RDMUL
	.WORD	23*RDMUL,21*RDMUL,19*RDMUL,17*RDMUL
	.WORD	15*RDMUL,13*RDMUL,11*RDMUL,9*RDMUL
	.WORD	7*RDMUL,5*RDMUL,3*RDMUL,1*RDMUL

YEL_TO_BLACK
	.WORD	16
	.WORD	(31*GRMUL)+(31*RDMUL),(29*GRMUL)+(29*RDMUL),(27*GRMUL)+(27*RDMUL),(25*GRMUL)+(25*RDMUL)
	.WORD	(23*GRMUL)+(23*RDMUL),(21*GRMUL)+(21*RDMUL),(19*GRMUL)+(19*RDMUL),(17*GRMUL)+(17*RDMUL)
	.WORD	(15*GRMUL)+(15*RDMUL),(13*GRMUL)+(13*RDMUL),(11*GRMUL)+(11*RDMUL),(9*GRMUL)+(9*RDMUL)
	.WORD	(7*GRMUL)+(7*RDMUL),(5*GRMUL)+(5*RDMUL),(3*GRMUL)+(3*RDMUL),(1*GRMUL)+(1*RDMUL)

BLUE_TO_BLACK
	.WORD	16
	.WORD	31,29,27,25
	.WORD	23,21,19,17
	.WORD	15,13,11,9
	.WORD	7,5,3,1

WHITE_TO_BLACK
	.WORD	16
	.WORD	31+(31*GRMUL)+(31*RDMUL),29+(29*GRMUL)+(29*RDMUL),27+(27*GRMUL)+(27*RDMUL),25+(25*GRMUL)+(25*RDMUL)
	.WORD	23+(23*GRMUL)+(23*RDMUL),21+(21*GRMUL)+(21*RDMUL),19+(19*GRMUL)+(19*RDMUL),17+(17*GRMUL)+(17*RDMUL)
	.WORD	15+(15*GRMUL)+(15*RDMUL),13+(13*GRMUL)+(13*RDMUL),11+(11*GRMUL)+(11*RDMUL),9+(9*GRMUL)+(9*RDMUL)
	.WORD	7+(7*GRMUL)+(7*RDMUL),5+(5*GRMUL)+(5*RDMUL),3+(3*GRMUL)+(3*RDMUL),1+(1*GRMUL)+(1*RDMUL)


	.END




