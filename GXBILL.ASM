 	.MLIB	"GXMACS.LIB"
	.FILE	"GXBILL.ASM"
	.TITLE	" <<< GENERATION X -- BILL ROUTINES >>>"
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
	.INCLUDE	"IMGTBL.GLO"

	.REF	DUXNOFADE

	.BSS	TRACKEE,32
	.bss	filler,16	; to keep long word aligned
	.BSS	DSSON,16

	.text

**************************************************************************
*								         *
* DOZER_SCROLL_CONTROL							 *
*								         *
**************************************************************************

DOZER_SCROLL_CONTROL
	CLR	A14
	MOVE	A14,@DSSON,W
DSS_LUPE
	SLEEP	1

	MOVE	@DSSON,A14,W
	JRZ	DSS_LUPE

	CLR	A3
	CLR	A4
	CLR	A5

	CALLA	READ_SW1_SW2
	BTST	P1BOMB,A0
	JRNZ	DSS_CHK_R	
	MOVI	-010000H,A3
DSS_CHK_R
	BTST	P1TRIGGER,A0
	JRNZ	DSS_CHK_I
	BTST	P2TRIGGER,A0
	JRNZ	DSS_CHK_D
	MOVI	010000H,A4
	JRUC	DSS_CHK_I
DSS_CHK_D
	BTST	P2BOMB,A0
	JRNZ	DSS_GO_R
	MOVI	-010000H,A4
	JRUC	DSS_CHK_I
DSS_GO_R
	MOVI	010000H,A3
DSS_CHK_I
	BTST	P3BOMB,A0
	JRNZ	DSS_CHK_O
	MOVI	0100H << ZFRAC,A5
DSS_CHK_O
	BTST	P3TRIGGER,A0
	JRNZ	DSS_SET
	MOVI	-0100H << ZFRAC,A5	
DSS_SET
	MOVE	A3,@XSCROLL,L
	MOVE	A4,@YSCROLL,L
	MOVE	A5,@ZSCROLL,L

	JRUC	DSS_LUPE

**************************************************************************
*								         *
* OBJECT_TRACKER_PROC							 *
*								         *
**************************************************************************

OBJECT_TRACKER_PROC
	CLR	A8
	MOVE	A8,@TRACKEE,L
	MOVE	A8,@XSCROLL,L
	MOVE	A8,@YSCROLL,L
	MOVE	A8,@ZSCROLL,L
OTP_LUPE
	MOVE	@TRACKEE,A8,L
	JRZ	OTP_NAP
	MOVE	*A8(OCTRL),A14,W
	JRNN	OBJECT_TRACKER_PROC
	MOVE	*A8(OXVAL),A1,L
	MOVE	@XBASE,A14,L
	SUB	A14,A1
	SRA	2,A1
	MOVE	A1,@XSCROLL,L
	MOVE	*A8(OYVAL),A2,L
	MOVE	@YBASE,A14,L
	ADD	A14,A2
	NEG	A2
	SRA	2,A2
	MOVE	A2,@YSCROLL,L
OTP_NAP
	SLEEP	4
	JRUC	OTP_LUPE
	
	.end
