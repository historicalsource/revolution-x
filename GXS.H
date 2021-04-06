**************************************************************************
*								         *
* 	       GENERATION X - CMOS RAM EQUATE FILE			 *
* 									 *
* 	COPYRIGHT (C) 1992 MIDWAY MANUFACTURING COMPANY.		 *
* 		       ALL RIGHTS RESERVED.				 *
*								         *
**************************************************************************

**************************************************************************
*								         *
* 	COINAGE STUFF							 *
*								         *
**************************************************************************

CHUTES		EQU	4		;MAXIMUM COIN CHUTES IN GAME.

L_COIN_BIT	EQU	1H
C_COIN_BIT	EQU	4H
R_COIN_BIT	EQU	2H
X_COIN_BIT	EQU	80H
SLAM_BIT	EQU	8H

MENU_PID	EQU	0AC1H		;GET_MENU SLAVE
MDUN_PID	EQU	0AC2H		;MENU SLAVE CHANGES TO THIS WHEN DONE

LONG_SIZE	EQU	32
WORD_SIZE	EQU	16
BYTE_SIZE	EQU	8

C_LONG_SIZE	EQU	128
C_WORD_SIZE	EQU	64
C_BYTE_SIZE	EQU	32
CMOS_1K		EQU	C_BYTE_SIZE*1024

BYTE_MASK	EQU	0FFH
BM		EQU	BYTE_MASK	;STINKY SHORT-HAND
WORD_MASK	EQU	0FFFFH

SX_MASK		EQU	0FFFFH
SY_MASK		EQU	0FFFF0000H

**************************************************************************
*                                                                        *
*          ASCII STUFF                                                   *
*                                                                        *
**************************************************************************

SPACE		EQU	20H
EX_PT		EQU	21H
LET_0		EQU	30H
LET_A		EQU	41H
LET_Z		EQU	5AH
UNDERSCORE	EQU	5FH
FONT_SPACE	EQU	7EH
FONT_RUB	EQU	FONT_SPACE+1
FONT_END	EQU	FONT_RUB+1
FONT_RQUOTE	EQU	FONT_END+1
FONT_EPOUND	EQU	FONT_RQUOTE+1
FONT_CR		EQU	FONT_EPOUND+1
ASCII_COMMA	EQU	2CH
RIGHT_PAREN	EQU	29H
ASCII_DQ	EQU	22H
ASCII_START	EQU	020H
ASCII_END	EQU	05AH

**************************************************************************
*                                                                        *
*          AUDIT STRUCTURE                                               *
*                                                                        *
**************************************************************************

AUD_DATA	EQU	0	;THE COUNTER IS 4 BYTES STARTING AT ZERO
AUD_CKSUM	EQU	AUD_DATA+(4*C_BYTE_SIZE)  ;CHECKSUM = 2 BYTES
AUD_SIZE	EQU	AUD_CKSUM+C_WORD_SIZE
AUD_BYTES_TO_CHECK EQU	(AUD_SIZE/C_BYTE_SIZE)-2  ;# TO ADD FOR CHECKSUM

N_AUDITS	EQU	75		;ALLOCATE AMPLE AUDIT SPACE


**************************************************************************
*                                                                        *
*          ADJUSTMENTS                                                   *
*                                                                        *
**************************************************************************
ADJ_SIZE	EQU	C_LONG_SIZE
N_ADJUSTS	EQU	40		;40 NORMAL ADJUSTMENTS


**************************************************************************
*                                                                        *
*                                                                        *
*          CMOS STUFF FOR HSTD..........MOVE THIS TO SPECIAL EQUATE FILE *
*          SOME DAY                                                      *
*                                                                        *
*                                                                        *
**************************************************************************
*
*        High Score table (CMOS) entry data structure
*
NUM_INITS	EQU	3		;INITIALS IN EACH ENTRY..THIS MUST BE ODD
*
HS_SCORE	EQU	0			;LONG WORD.....8 DIGIT SCORE
HS_COL		EQU	HS_SCORE+C_LONG_SIZE	;PALETTE TO PLOT IN
HS_INITS	EQU	HS_COL+C_WORD_SIZE	;BYTE FOR FIRST INITIAL
HS_CKBYTE	EQU	HS_INITS+(NUM_INITS*C_BYTE_SIZE) ;BYTE FOR CHECKSUM
HS_SIZE		EQU	HS_CKBYTE+C_BYTE_SIZE	;SIZE OF STRUCTURE
HS_BYTES_TO_CHECK EQU	(HS_SIZE/C_BYTE_SIZE)-1	;# TO ADD FOR CHECKSUM
HS_SIZE_IN_WORDS  EQU	HS_SIZE/C_WORD_SIZE	;SIZE OF ENTRY IN WORDS
HS_SIZE_IN_BYTES  EQU	HS_SIZE/C_BYTE_SIZE	;SIZE OF ENTRY IN BYTES
HS_ROM_SIZE	EQU	HS_SIZE/2		;address size of rom entry

RHS_VALID	EQU	0
RHS_SCORE	EQU	RHS_VALID+WORD_SIZE
RHS_COL		EQU	RHS_SCORE+LONG_SIZE
RHS_INITS	EQU	RHS_COL+WORD_SIZE
RHS_CKBYTE	EQU	RHS_INITS+(NUM_INITS*BYTE_SIZE)
RHS_SIZE	EQU	RHS_CKBYTE+BYTE_SIZE

**************************************************************************
*                                                                        *
*         A HIGH SCORE TABLE IS DEFINED IN ROM BY THE FOLLOWING          *
*         STRUCTURE (THERE ARE AT LEAST 2 TABLES....ALL TIME             *
*         AND "TODAYS")                                                  *
*                                                                        *
**************************************************************************
TB_POINTER	EQU	0			;LONG-POINTER TO BEGINNING OF TABLE
TB_COUNT	EQU	TB_POINTER+LONG_SIZE	;WORD....# IN THE TABLE.
TB_VISIBLE	EQU	TB_COUNT+WORD_SIZE	;WORD....NUMBER DISPLAYED
TB_PAGE_BITS	EQU	TB_VISIBLE+WORD_SIZE	;WORD....STATUS WORD FOR CMOS PAGE
TB_FACTORY	EQU	TB_PAGE_BITS+WORD_SIZE	;LONG....ROM STARTUP TABLE
TB_ERROR_COUNT	EQU	TB_FACTORY+LONG_SIZE	;WORD....NUM ERRORS TO RE-INIT
*
;XUNIT (defined in gxsys.h)   CMOS		EQU	1400000H		;BASE OF CMOS
CMOS_PAGE_SELECT_BITS EQU 0C0H	;BITS 6 AND 7 OF SYSCTRL SELECT CMOS PAGE
CMOS_PAGE_SELECT_UNIT EQU 040H	;4 PAGES USE MULTIPLES OF THIS


**************************************************************************
*                                                                        *
*          CMOS ALLOCATION FOR ???XUNIT???                                     *
*                                                                        *
**************************************************************************
*
*	32K x 8
*
*	ALL IS PROTECTED, YOU MAY UNPROTECT FOR ONE WRITE ONLY
*		HSTD TODAY	- 1K
*		HSTD ALL TIME	- 1K
*		AUDITS		- 2K
*		ADJUSTMENTS	- 1K
*		ERROR DUMP DATA	- 2K
*
TODAYS_ORIGIN	EQU	CMOS
TODAYS_SELECT	EQU	CMOS_PAGE_SELECT_UNIT*0
TODAYS_VISIBLE	EQU	10
TODAYS_CMOSMEM	EQU	CMOS_1K			;TOTAL CMOS FOR TODAY'S HSTD

ALL_TIME_ORIGIN	EQU	TODAYS_ORIGIN+TODAYS_CMOSMEM
ALL_TIME_SELECT	EQU	CMOS_PAGE_SELECT_UNIT*2
ALL_TIME_VISIBLE EQU	10
ALL_TIME_CMOSMEM EQU	CMOS_1K			;TOTAL CMOS FOR ALL TIME HSTD

*
*        AUDIT PAGE AUDIT DATA AND CREDITS
*
AUDITORG	EQU	ALL_TIME_ORIGIN+ALL_TIME_CMOSMEM ;AUDITS LIVE HERE
CREDITS		EQU	AUDITORG+(N_AUDITS*AUD_SIZE)	;BYTE FOR CREDITS
CUNITS		EQU	CREDITS+C_BYTE_SIZE		;WORD
BUNITS		EQU	CUNITS+C_WORD_SIZE		;WORD
MINUNITS	EQU	BUNITS+C_WORD_SIZE		;WORD
COIN_CKSUM	EQU	MINUNITS+C_WORD_SIZE		;BYTE
HSR_C		EQU	COIN_CKSUM+C_BYTE_SIZE		;LONG = HIGH SCORE RESET COUNTER
AUDIT_CMOSMEM	EQU	2*CMOS_1K			;TOTAL CMOS FOR AUDITS
*
*	NEXT TWO ARE ASSUMED TO BE BACK TO BACK
*
HRESET_COUNTER	EQU	HSR_C+C_LONG_SIZE		;LONG = HIGH SCORE RESET COUNTER
HRESET_VERIFY	EQU	HRESET_COUNTER+C_LONG_SIZE	;LONG = 2ND COPY INVERTED.

COIN_CKSUM_START EQU	CREDITS
COIN_CKSUM_SIZE  EQU	COIN_CKSUM-COIN_CKSUM_START	;SIZE OF REGION TO CHECK
COIN_CKSUM_BYTES EQU	COIN_CKSUM_SIZE/C_BYTE_SIZE	;NUMBER OF BYTES TO ADD

AUDIT_SELECT	EQU	CMOS_PAGE_SELECT_UNIT*1
HSR_SELECT	EQU	AUDIT_SELECT		;HIGH SCORE RESET COUNTER
COIN_SELECT	EQU	AUDIT_SELECT		;COINS AND CREDITS
*
ADJUST_SELECT	EQU	CMOS_PAGE_SELECT_UNIT*1
*
*
*	CUSTOM MESSAGE DEFINITIONS
*
CMESS_CHARS	EQU	18				;25 CHARS/LINE OF CUSTOM MESSAGE
CMESS_LINES	EQU	3				;3 LINES
CMESS_LINE_SIZE	EQU	CMESS_CHARS*C_BYTE_SIZE
CMESS_SIZE	EQU	CMESS_LINES*CMESS_LINE_SIZE

VALID_VALUE	EQU	0EABCH			;STORED AT "VALID_CUSTOM" IF OK!

NAME_REV_SIZE	EQU	30			;NAME AND REV DATA

ADJUSTORG	EQU	AUDITORG+AUDIT_CMOSMEM	;FIRST ADJUSTMENT HERE
CUSTOM_MESSAGE	EQU	ADJUSTORG+(N_ADJUSTS*ADJ_SIZE)
VALID_CUSTOM	EQU	CUSTOM_MESSAGE+CMESS_SIZE	;WORD = EABC IF OK.
END_CK_REGION	EQU	VALID_CUSTOM+C_WORD_SIZE
ADJ_AREA_SIZE	EQU	END_CK_REGION-ADJUSTORG		;ADJUSTS+CUSTOM MESSAGE
ADJ_CKSUM	EQU	END_CK_REGION			;WORD CHECK FOR ADJUSTS
ADJ_BYTES_TO_CHECK EQU	ADJ_AREA_SIZE/C_BYTE_SIZE	;NUMBER OF BYTES IN CHECKSUM.
NAME_REV	EQU	ADJ_CKSUM+C_WORD_SIZE
END_ADJ		EQU	NAME_REV+(NAME_REV_SIZE*C_BYTE_SIZE)
ADJUST_CMOSMEM	EQU	CMOS_1K				;TOTAL CMOS FOR ADJUSTMENTS

DUMP_ORG	EQU	ADJUSTORG+ADJUST_CMOSMEM
DUMP_SELECT	EQU	CMOS_PAGE_SELECT_UNIT*3
DUMP_PTR	EQU	DUMP_ORG		;WORD....NUMBER OF ENTRIES!
DUMP_DATA	EQU	DUMP_PTR+C_WORD_SIZE	;DUMPS GO HERE!
DUMP_CMOSMEM	EQU	2*CMOS_1K		;TOTAL CMOS FOR DUMPS
DUMP_END	EQU	DUMP_ORG+DUMP_CMOSMEM

CMOS_SECURITY_INFO	EQU	0A047FF00H
CMOS_SN			EQU	CMOS_SECURITY_INFO
CMOS_DATE		EQU	CMOS_SECURITY_INFO+60H
CMOS_GN			EQU	CMOS_SECURITY_INFO+0A0H

**************************************************************************
*                                                                        *
*          COLOR STUFF -- PALETTE 0                                      *
*                                                                        *
**************************************************************************
TEXT_PAL	EQU	0404H			;FIXED TEXT PALETTE NUMBER
COLOR_RED	EQU	0101H
COLOR_WHITE	EQU	0202H
COLOR_BLUE	EQU	0303H
COLOR_GREY	EQU	0404H
COLOR_YELLOW	EQU	0505H
COLOR_PURPLE	EQU	0606H
COLOR_GREEN	EQU	0707H
COLOR_BLACK	EQU	0808H
COLOR_RGB	EQU	3B3BH
COLOR_DECAY	EQU	3C3CH
COLOR_BPR	EQU	3B3BH
COLOR_LF	EQU	3D3DH
*COLOR + PALETTE [COLOR,PALETTE]
COLOR_PRED	EQU	COLOR_RED*10000H+TEXT_PAL
COLOR_PWHITE	EQU	COLOR_WHITE*10000H+TEXT_PAL
COLOR_PBLUE	EQU	COLOR_BLUE*10000H+TEXT_PAL
COLOR_PGREY	EQU	COLOR_GREY*10000H+TEXT_PAL
COLOR_PYELLOW	EQU	COLOR_YELLOW*10000H+TEXT_PAL
COLOR_PPURPLE	EQU	COLOR_PURPLE*10000H+TEXT_PAL
COLOR_PGREEN	EQU	COLOR_GREEN*10000H+TEXT_PAL
COLOR_PBLACK	EQU	COLOR_BLACK*10000H+TEXT_PAL
COLOR_PRGB	EQU	COLOR_RGB*10000H+0000H
COLOR_PBPR	EQU	COLOR_BPR*10000H+0000H
COLOR_PDECAY	EQU	COLOR_DECAY*10000H+0000H
COLOR_PLF	EQU	COLOR_LF*10000H+0000H

