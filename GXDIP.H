**************************************************************************
*																							    *
* 	         GENERATION X - DIPSWITCH EQUATE FILE								 *
* 																								 *
* 	COPYRIGHT (C) 1993 MIDWAY MANUFACTURING COMPANY.							 *
* 		       ALL RIGHTS RESERVED.													 *
* 																								 *
* 																								 *
*																							    *
**************************************************************************
;
;	DIP SWITCH
;
DPMIRROR		EQU	0001H		;MIRROR DISPLAY SWITCH
DPMIRROR_RAW	.EQU	0001H		;RAW POSITION FROM PORT (Steve & John fixed it!)

DPUSECMOS	EQU	0002H		;USE CMOS MASK

DPCOINAGE	EQU	001CH		;COINAGE MASK
SR_DPCOINAGE	EQU	2		;shift count to Right justify COINAGE bits

DPCREDITS	EQU	00E0H		;CREDITS TO START/CONTINUE MASK
SR_DPCREDITS	EQU	5		;shift count to Right justify CREDITS bits

DPCOUNTRY	EQU	0300H		;COUNTRY MASK
SR_DPCOUNTRY	EQU	8		;shift count to Right justify COUNTRY bits

DPVALIDATOR	EQU	0400H		;Bill validator enable

DPCOUNTER	EQU	0800H		;NUMBER OF COIN COUNTERS

DPPLAYERS	EQU	1000H		;NUMBER OF HARDWARE PLAYERS 
SR_DPPLAYERS	EQU	12		;shift count to Right justify PLAYERS bits

DPKIT		EQU	2000H		;Kit switch

DPFREEZE		EQU	4000H		;FREEZE SWITCH
DPTEST		EQU	8000H		;TEST SWITCH

;
;	0 = OFF
;	1 = ON
;
;	THANKS TO MARK LOFFREDO FOR REAMING ME OVER AND REVERSING THE
;	DIP SWITCHES
;
;	DPMIRROR ( DS1 - 1 )
;
;	0 	= VIDEO SCREEN VIEWED THROUGH A MIRROR (IN CABINET)
;	1 	= VIDEO SCREEN VIEWED NORMALLY (FOR TEST BENCH)
;
;	DPUSECMOS ( DS1 - 2 )
;
;	0 	= DIP SWITCH COINAGE USED
;	1	= CMOS COINAGE USED
;
;	DPRIGHTSLOT ( DS1 - 5 4 3 ) 
;
;	000 	= 1 COIN / 1 CREDIT
;	001	= 2 COIN / 1 CREDIT 
;	010	= 3 COIN / 1 CREDIT
;	011	= 4 COIN / 1 CREDIT
;	100	= 1 COIN / 2 CREDIT
;	101	= 1 COIN / 3 CREDIT
;	110	= 1 COIN / 4 CREDIT
;	111	= FREEPLAY
;
;	DPUNUSED ( DS1 - 6 )
;
;	DPUNUSED ( DS1 - 7 )
;
;	DPUNUSED ( DS1 - 8 )
;
;	DPCOUNTRY ( DS2 - 2 1 )
;
;	00	= USA
;	01	= GERMAN
;	10	= FRENCH
;	11	= OUTERSPACE
;
;	DPUNUSED ( DS2 - 3 )
;
;	DPCOUNTER ( DS2 - 4 )
;
;	0	= 1 COUNTER 
;	1	= 2 COUNTERS
;
;	DPPLAYERS ( DS2 - 6 5 )
;
;	00	= GAME CONFIGURED FOR 3 PLAYERS
;	01	= GAME CONFIGURED FOR 2 PLAYERS
;	10	= GAME CONFIGURED FOR 1 PLAYER
;	11	= GAME CONFIGURED FOR 1 PLAYER
;
;	DPFREEZE ( DS2 - 7 )
;
;	0	= DON'T FREEZE SCREEN
;	1	= FREEZE SCREEN ( NOTE : MUST HAVE A TRANSITION TO WORK )
;
;	DPTEST ( DS2 - 8 )
;
;	0	= NORMAL NON-TEST
;	1	= TEST MODE
;
