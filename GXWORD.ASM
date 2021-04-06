	.MLIB	"GXMACS.LIB"
	.FILE	"GXWORD.ASM"
	.TITLE	" <<< AMUSEMENT PARK  -- WORD COMPRESSION >>>"
	.WIDTH	132
	.OPTION	B,D,L,T
	.MNOLIST

**************************************************************************
*								         *
* 	COPYRIGHT (C) 1992 MIDWAY MANUFACTURING COMPANY.		 *
* 		       ALL RIGHTS RESERVED.				 *
*								         *
**************************************************************************

	.INCLUDE	"GX.INC"		;System Equates
	.INCLUDE	"GXSTRING.H"	;STRING ROUTINES
	.INCLUDE	"GXDICT.H"	;DICTIONARY OF WORDS

**************************************************************************
*								         *
* 	DEFS AND REFS							 *
*								         *
**************************************************************************

	.DEF	DICT_LOOKUP
	
**************************************************************************
*								         *
* 	CODE START							 *
*								         *
**************************************************************************

	.TEXT
	.EVEN

**************************************************************************
*								         *
* 	DICT_LOOKUP							 *
* 									 *
* 	ENTRY								 *
* 		A0	WORD NUMBER					 *
* 									 *
* 	EXIT								 *
* 		A8	POINTER TO WORD STRING				 *
* 									 *
* 	CALL								 *
* 		CALL							 *
*								         *
**************************************************************************
DICT_LOOKUP:
	MMTM	SP,A0
	CLR	A8			; "ASSUME ZERO"
	SLL	25,A0
	SRL	25,A0			; MASK ALL BUT LOW 7
	CMPI	W_LASTWORD,A0
	JRHI	DICT_RET		; BR = NOT A REAL WORD
	SLL	5,A0
	ADDI	LOOKUP_TAB,A0
	MOVE	*A0,A8,L
DICT_RET
	MOVE	A8,A8
	MMFM	SP,A0
	RETS

**************************************************************************
*								         *
* 	WORD TABLE							 *
*								         *
**************************************************************************

LOOKUP_TAB:
	.LONG	W_000, W_001, W_002, W_003, W_004, W_005, W_006, W_007
	.LONG	W_008, W_009, W_010, W_011, W_012, W_013, W_014, W_015
	.LONG	W_016, W_017, W_018, W_019, W_020, W_021, W_022, W_023
	.LONG	W_024, W_025, W_026, W_027, W_028, W_029, W_030, W_031
	.LONG	W_032, W_033, W_034, W_035, W_036, W_037, W_038, W_039
	.LONG	W_040, W_041, W_042, W_043, W_044, W_045, W_046, W_047
	.LONG	W_048, W_049, W_050, W_051, W_052, W_053, W_054, W_055
	.LONG	W_056, W_057, W_058, W_059, W_060, W_061, W_062, W_063
	.LONG	W_064, W_065, W_066

W_000	.STRING	"FRANCE",0
W_001	.STRING	"GERMAN",0
W_002	.STRING	82H,0
W_003	.STRING	"CREDIT",0
W_004	.STRING	"GAME",0
W_005	.STRING	"ADJUSTMENT",0
W_006	.STRING	"CREDITS",0
W_007	.STRING	"PRICING",0
W_008	.STRING	"CUSTOM",0
W_009	.STRING	"FREE",0
W_010	.STRING	"PLAY",0
W_011	.STRING	"COIN",0
W_012	.STRING	"COINS",0
W_013	.STRING	"STANDARD",0
W_014	.STRING	"UNITS",0
W_015	.STRING	"CHUTE",0
W_016	.STRING "FACTORY SETTING",0
W_017	.STRING	"TIME",0
W_018	.STRING	"AUDITS",0
W_019	.STRING	"CLOSED",0
W_020	.STRING	"CLEAR",0
W_021	.STRING	"TEST",0
W_022	.STRING	"AVERAGE",0
W_023	.STRING	"FOURTH",0
W_024	.STRING	"SWITCH",0
W_025	.STRING	"BOARD",0
W_026	.STRING	"SLOT",0
W_027	.STRING	"TONE",0
W_028	.STRING	"GAMES",0
W_029	.STRING	"RETURN",0
W_030	.STRING	"RIGHT",0
W_031	.STRING	"PLAYS",0
W_032	.STRING	"HIGH",0
W_033	.STRING	"CONTINUES",0
W_034	.STRING	"COLLECTION",0
W_035	.STRING	"AUDIT",0
W_036	.STRING	"PRESS",0
W_037	.STRING	"SETTINGS",0
W_038	.STRING	"DIPSWITCH",0
W_039	.STRING	"BOOK",0
W_040	.STRING	"CENTER",0
W_041	.STRING	"SELECT",0
W_042	.STRING	"LEFT",0
W_043	.STRING	"START",0
W_044	.STRING	"PLAYER",0
W_045	.STRING	"SIMULTANEOUS",0
W_046	.STRING	"SCREEN",0
W_047	.STRING	"TOTAL",0
W_048	.STRING	"STARTS",0
W_049	.STRING	"SOUND",0
W_050	.STRING	"ADJUSTMENTS",0
W_051	.STRING	"ERROR",0
W_052	.STRING	"TOTALS",0
W_053	.STRING	"COIN COUNTERS",0
W_054	.STRING	"MESSAGE",0
W_055	.STRING	"BUTTON",0
W_056	.STRING	"CONTINUE",0
W_057	.STRING	"U.S.A.",0
W_058	.STRING "DOLLAR",0
W_059	.STRING "CENT",0
W_060	.STRING	"CENTS",0
W_061	.STRING "SCHILLING",0
W_062	.STRING	"MAXIMUM",0
W_063	.STRING	"MINIMUM",0
W_064	.STRING	"LIVES",0
W_065	.STRING	"EXTRA",0
W_066	.STRING	"SCORE",0

	.EVEN
