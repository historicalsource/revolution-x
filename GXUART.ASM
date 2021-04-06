	.MLIB	"GXMACS.LIB"
	.FILE	"GXUART.ASM"
	.TITLE	"<<< GENERATION X ---- UART Support Code >>>"
	.WIDTH	132
	.OPTION	B,D,L,T
	.MNOLIST

**************************************************************************
*								         *
* 	Revision		By					 *
* 	--------		--					 *
* 									 *
* 	1.0 - 10/28/93		George Petro				 *
* 									 *
* 	COPYRIGHT (C) 1993 MIDWAY MANUFACTURING COMPANY.		 *
* 		       ALL RIGHTS RESERVED.				 *
*								         *
**************************************************************************

	.INCLUDE	"GX.INC"		;Game equates

***** Symbols in this module

	.DEF	INITIALIZE_UART

*
*Mode settings for the UART
*
MODE_MR1 .EQU	93H		;Mode - 8 bits, no parity, RX controls RTS
MODE_MR2 .EQU	17H		;Mode - 1 stop bit, CTS controls Tx
MODE_ACR .EQU	38H		;Mode - PWRDWN off, Clk = X1 ext
MODE_CSR .EQU	0CCH		;Mode - Baud rate 38.4k
MODE_IMR .EQU	04H		;Mode - Interrupt when RxRDY


	.BSS	UART_IMR_COPY,16	;Copy of UART interrupt mask reg
	.BSS	UNUSED_WORD,16

	.TEXT

**************************************************************************
*								         *
* 	INITIALIZE_UART							 *
* 									 *
* 	Initialize the Sound UART for all to use			 *
*								         *
**************************************************************************
INITIALIZE_UART
	PUSH	A0

	MOVI	UART,A0,L

	MOVIM	1AH,*A0(UART_CR),W	;Set CR - Reset MR pointer.

	MSECWT	3			;Modes take time

	MOVIM	20H,*A0(UART_CR),W	;Reset Rx.

	MSECWT	3			;Modes take time

	MOVIM	30H,*A0(UART_CR),W	;Reset Tx.

	MOVIM	MODE_MR1,*A0,W		;Set MR1 - 8 bits, no parity, RX controls RTS.

	MOVIM	MODE_MR2,*A0,W		;Set MR2 - 1 stop bit, CTS controls TX.

	MOVIM	MODE_ACR,*A0(UART_ACR),W	;Set ACR - PWRDWN off, Clk = X1 ext

	MOVIM	MODE_CSR,*A0(UART_CSR),W	;Set CSR - 38.4kBaud

	MOVIM	0A0H,*A0(UART_CR),W	;Assert RTSN - allows Rx to control RTS.

	MOVI	MODE_IMR,A14
	MOVE	A14,@UART_IMR_COPY,W
	MOVE	A14,*A0(UART_IMR),W	;Set proper interrupt mode
;	CLRM	*A0(UART_IMR),W		;Set IMR - Interrupts off for now

	.IF DEBUG

*Here we will test if the UART took what we sent it
	MOVIM	10H,*A0(UART_CR),W	;Set CR - Reset MR pointer.

	MSECWT	3

	MOVE	*A0,A14,W		;Check to see if MR1 was written to
	SLL	24,A14
	SRL	24,A14
	CMPI	MODE_MR1,A14		;If MR1 is correct than no lock
	JRNZ	$

	MOVE	*A0,A14,W		;Check to see if MR2 was written to
	SLL	24,A14
	SRL	24,A14
	CMPI	MODE_MR2,A14		;If MR2 is correct than no lock
	JRNZ	$

	.ENDIF 
;UART is good to go

	MOVIM	45H,*A0(UART_CR),W	;Enable Tx, Rx and clear error flags.

	PULLQ	A0
	RETS
