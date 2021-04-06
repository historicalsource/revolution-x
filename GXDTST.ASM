 	.MLIB	"GXMACS.LIB"
	.FILE	"GXDTST.ASM"
	.TITLE	"<<< GENERATION X - DIAGNOSTIC TEST ROUTINES >>>"
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

**************************************************************************
*								         *
* 	DEFS AND REFS							 *
*								         *
**************************************************************************

	.DEF	POWERTST, DIAGCPUTEST, POWERCMOS, BURNIN, CHECKDIPFREE
	.DEF	READ_DIP

	.def	read_dip

	.DEF	dmatest_start, dmatest_end

	.IF	PRINTER
	.ELSE
	.DEF	SWITCHTEST, CONV_PLOT, DIPTEST, COLORBAR
	.ENDIF
*SYMBOLS IN GX.CMD
	.GLOBAL	code_start, code_end, code_dest, vector_start, vector_end
	.GLOBAL	vector_dest
*SYMBOLS IN GXDUTL.ASM
	.REF	CIRCLE, HVLINE, POINT, DSCRCLR, INITCOLR, DIAG_SRT_CLR
*SYMBOLS IN GX.ASM
	.REF	POWERRET, PCMOSRET, EXEC_LP, CLSCRACH 
	.REF	MAIN_INIT, INITDATA, IDATALEN
*SYMBOLS IN GXMENU.ASM
	.REF	ROM_NAME, CKTEST, BLASTMESS, TOP_BOX
	.ref	_cabinet_type
*SYMBOLS IN GXUART.ASM
	.REF	INITIALIZE_UART
*SYMBOLS IN GXSND.ASM
	.REF	SOUND_RX
	.REF	SEND_RAW_SOUND

	.if	NOPIC = 0
	.ref	_get_serial_number
	.endif

*SYMBOLS IN GXCMOS.ASM
	.REF	CMOS_VAL, FAC_SET, CLR_AUD, STORE_AUDIT, KILL_AUD, GET_AUD
	.REF	PUT_ADJ, F_ADC_S
*SYMBOLS IN GXHSTD.ASM
	.REF	INIT_TB, ALL_TAB, TOD_TAB, GET_HSC, INIT_HSR
	.REF	VAL_TAB, CPU_RET, CLEAR_HSCOLORS
*SYMBOLS IN GXMISC.ASM
	.REF	COLOR_START
*SYMBOLS IN GXADJ.ASM
	.REF	USA_1, USA_2, USA_3, USA_4, USA_ELECTITLE
	.REF	GERMAN_1, GERMAN_2, GERMAN_3, GERMAN_4, GERMAN_ELECTITLE
	.REF	FRENCH_1, FRENCH_2, FRENCH_3, FRENCH_4, FRENCH_ELECTITLE
	.REF	SET_COIN_ADJ, GET_CSPT, DIPCOINTAB, DIPCREDTAB

	.IF	PRINTER
	.REF	OFFTIME,PBADGUY
	.ENDIF

*DIAGNOSTIC SOUND EQUATES
;CMOS_ERROR_SND	.EQU	5EH
;CPU_ERROR_SND	.EQU	5EH
;DIP_SND		.EQU	83H
;SWITCH_SND	.EQU	82H
CMOS_ERROR_SND:
	.WORD	0D3FFH, 100, 063d8H, 0
CPU_ERROR_SND:
	.WORD	0D3FFH, 100, 063d8H, 0
DIP_SND:
	.WORD	0D3FFH, 100, 063d6H, 0
SWITCH_SND:
	.WORD	0D3FFH, 100, 063d6H, 0

**************************************************************************
*								         *
* 			SOME RAM FOR YOU				 *
*								         *
**************************************************************************
	.BSS	SWSET1,32		; FOR SWITCH TEST
	.BSS	SWSET2,32
	.BSS	SWPREV1,32
	.BSS	SWPREV2,32

	.BSS	DIPVAL,16
	.BSS	DIP1ST,16

	.BSS	CERRORS,32
	.BSS	CPASSES,32

	.BSS	CKSUM_WORK,64

	.globl	_pic_secure
	.bss	_pic_secure,16
	.bss	_pic_raw,128
	.bss	_pic_temp,64
;	.bss	_pad,16
	.bss	_rom_type,16

	.even
**************************************************************************
*								         *
* 	USEFUL MACROS							 *
*								         *
**************************************************************************
BUT_MAC	.MACRO  X,Y,RADIUS,COLOR,MASK,SHIFT,EXTEND
	.WORD	:X:	
	.WORD	:Y:
	.WORD	:RADIUS:
	.LONG	:COLOR:
	.LONG	:MASK:
	.WORD	:SHIFT:
	.WORD	:EXTEND:
        .ENDM

STR_MAC	.MACRO  X,Y,STRING,COLOR,DIR
	.WORD	:X:	
	.WORD	:Y:
	.LONG	:STRING:
	.WORD	:COLOR:
	.WORD	:DIR:
        .ENDM

SW_MAC	.MACRO  X,Y,STRING,COLOR,DIR,MASK
	.WORD	:X:	
	.WORD	:Y:
	.LONG	:STRING:
	.WORD	:COLOR:
	.WORD	:DIR:
	.LONG	:MASK:
        .ENDM

VECMAC	.MACRO	COLOR,X1,Y1,X2,Y2
	.WORD	:COLOR:
	.WORD	:X1:
	.WORD	:Y1:
	.WORD	:X2:
	.WORD	:Y2:
	.ENDM

DOTMAC	.MACRO	COLOR,X,Y
	.WORD	:COLOR:
	.WORD	:X:
	.WORD	:Y:
	.ENDM

RECTMAC	.MACRO	COLOR,X,Y,W,H
	.WORD	:W:
	.WORD	:H:
	.WORD	:X:
	.WORD	:Y:
	.WORD	:COLOR:
	.ENDM

CHIPMAC	.MACRO	NUM,X1,Y1,X2,Y2,X3,Y3,STRING,DIR,X4,Y4,STUFFED
	.WORD	:NUM:
	.WORD	:X1:
	.WORD	:Y1:
	.WORD	:X2:
	.WORD	:Y2:
	.WORD	:X3:
	.WORD	:Y3:
	.LONG	:STRING:
	.WORD	:DIR:
	.WORD	:X4:
	.WORD	:Y4:
	.WORD	:STUFFED:
	.ENDM


CMNUM		EQU	0
CMLOC		EQU	CMNUM+16
CMXLOC		EQU	CMLOC
CMYLOC		EQU	CMLOC+16
CMSIZE		EQU	CMLOC+32
CMXSIZE		EQU	CMSIZE
CMYSIZE		EQU	CMSIZE+16
CMOFFSET	EQU	CMSIZE+32
CMSTRING	EQU	CMOFFSET+32
CMDIR		EQU	CMSTRING+32
CMPINLOC	EQU	CMDIR+16
CMSTUFFED	EQU	CMPINLOC+32
CMEND		EQU	CMSTUFFED+16
	

**************************************************************************
*								         *
* RAM_CHIP: MACRO DEFINES A RAM CHIP RECORD.				 *
* 									 *
*       CHIP_NO    -- CHIP NUMBER					 *
*       WIDTH      -- CHIP CELL SIZE IN BITS (MUST BE > 0)		 *
*       INTERLEAVE -- DISTANCE BETWEEN ADJACENT CELLS ON CHIP (IN BITS)	 *
*       START_ADDR -- ADDRESS OF FIRST CELL ON CHIP			 *
*       END_ADDR   -- ADDRESS OF LAST CELL ON CHIP			 *
*								         *
**************************************************************************

RAM_CHIP .MACRO TAB_LINK,CHIP_NO, WIDTH, INTERLEAVE, START_ADDR, END_ADDR           

         .WORD  :WIDTH:
         .WORD  :INTERLEAVE:
         .WORD  :CHIP_NO:
         .LONG  :START_ADDR:
         .LONG  :END_ADDR:
	.LONG	:TAB_LINK:
         .ENDM

RAM_WDTH EQU 	000H                ; OFFSETS INTO RAM CHIP RECORD
RAM_ITLV EQU	010H
RAM_NMBR EQU 	020H
RAM_SADR EQU 	030H
RAM_EADR EQU 	050H
RAM_LINK	EQU	070H
RAM_SIZE EQU 	090H

ROM_CKSM	EQU	000H
ROM_WDTH	EQU	010H                ; OFFSETS INTO ROM CHIP RECORD
ROM_ITLV 	EQU	020H
ROM_NMBR 	EQU	030H
ROM_SADR 	EQU	040H
ROM_EADR 	EQU	060H
ROM_LINK	EQU	080H
ROM_SIZE 	EQU	0A0H

;****************************************************************************
;* ROM_CHIP: MACRO DEFINES A ROM CHIP RECORD.                               *
;*                                                                          *
;*       CHIP_NO    -- CHIP NUMBER                                          *
;*       WIDTH      -- CHIP CELL SIZE IN BITS (MUST BE > 0)                 *
;*       INTERLEAVE -- DISTANCE BETWEEN ADJACENT CELLS ON CHIP (IN BITS)    *
;*       START_ADDR -- ADDRESS OF FIRST CELL ON CHIP                        *
;*       END_ADDR   -- ADDRESS OF LAST CELL ON CHIP                         *
;*       CHECK_SUM  -- DATAIO CHECK SUM FOR CHIP                            *
;****************************************************************************

ROM_CHIP .MACRO TAB_LINK,CHIP_NO, WIDTH, INTERLEAVE, START_ADDR, END_ADDR, CHECK_SUM

	.WORD	:CHECK_SUM:
        .WORD  :WIDTH:
        .WORD  :INTERLEAVE:
        .WORD  :CHIP_NO:
        .LONG  :START_ADDR:
        .LONG  :END_ADDR:
	.LONG	:TAB_LINK:

         .ENDM

ROMBANK	.MACRO	LINK1, LINK2, LINK3, LINK4, START, END, SUM1, SUM2, SUM3, SUM4

	.LONG	:LINK1:		; 0
	.LONG	:LINK2:		; 32
	.LONG	:LINK3:		; 64
	.LONG	:LINK4:		; 96
	.LONG	:START:		; 128
	.LONG	:END:		; 160
	.WORD	:SUM1:		; 192
	.WORD	:SUM2:		; 208
	.WORD	:SUM3:		; 224
	.WORD	:SUM4:		; 240
	.WORD	0,0,0,0		; 256
	.ENDM			; 320


RANDOM_SEED EQU 5A5A5A5Ah              ; RAM TESTS: PSEUDO-RANDOM SEQUENCE
ZERO_EXTEND EQU 1Fh                    ; PARAMETERS
SIGN_EXTEND EQU 20h

	.sect	"COLDSTRT"
        .EVEN

; BIN2BCD Converts a hex number in a7 to BCD and puts it in A3
BIN2BCD:
	clr	a3
	movi	100000,a0
_bin2bcd_loop:
	sll	4,a3
	move	a7,a1
	divu	a0,a1
	or	a1,a3
	mpyu	a0,a1
	sub	a1,a7
	move	a0,a1
	movk	10,a0
	divu	a0,a1
	move	a1,a0
	jrnz	_bin2bcd_loop
;	or	a7,a3
	FRET	b6
	.if 0

BIN2BCD:
	clr	a3
	move	a7,a1
	movi	100000,a0
	divu	a0,a1
	move	a1,a3
	sll	4,a3
	mpyu	a0,a1
	sub	a1,a7

	move	a7,a1
	movi	10000,a0
	divu	a0,a1
	or	a1,a3
	sll	4,a3
	mpyu	a0,a1
	sub	a1,a7

	move	a7,a1
	movi	1000,a0
	divu	a0,a1
	or	a1,a3
	sll	4,a3
	mpyu	a0,a1
	sub	a1,a7

	move	a7,a1
	movi	100,a0
	divu	a0,a1
	or	a1,a3
	sll	4,a3
	mpyu	a0,a1
	sub	a1,a7

	move	a7,a1
	movi	10,a0
	divu	a0,a1
	or	a1,a3
	sll	4,a3
	mpyu	a0,a1
	sub	a1,a7

	or	a7,a3
	FRET	b6
	.endif


******************************************************************************
*                                                                            *
* _bcd2hex - Converts a 32 bit (8 digit) BCD Number to Hexidecimal           *
*                                                                            *
* ENTRY                                                                      *
*         A0 - BCD Number to be converted                                    *
*         B6 - Return Address                                                *
*                                                                            *
* EXIT                                                                       *
*         A2 - Converted Number (hex)                                        *
*                                                                            *
* USES                                                                       *
*         A1 - Multiplier                                                    *
*         A3 - Temporary                                                     *
*         A4 - Digit Counter                                                 *
*                                                                            *
* Written by:  Michael J. Lynch                                              *
*                                                                            *
******************************************************************************
_bcd2hex:
	clr	a2		; Start with 0
	movk	1,a1		; Starting Multiplier
	movk	8,a4		; Number of BCD digits to convert
_b2h_loop:			; Main BCD to hex conversion loop
	move	a0,a3		; Put BCD number in temporary register
	andi	0fh,a3		; get rid of bits not interested in
	mpyu	a1,a3		; multiply by current multiplier
	add	a3,a2		; Accumulate into final register
	srl	4,a0		; Shift to next BCD digit
	movk	10,a3		; Calculate next multiplier (mult = mult * 10)
	mpyu	a3,a1		; New Multiplier
	dsjs	a4,_b2h_loop	; Keep going until 8 BCD digits are done
	FRET	b6		; return

; Read PIC, decode information and stuff information into CMOS memory.
; This is the function called by security init when the correct access code
; is input.  The label for this function MUST be global.  The RETS at the
; end of this function returns us back to the POWERCMOS function.

	.globl	_read_pic_data
_read_pic_data:
	setf	16,0,0
	setf	32,0,1
	.if	NOPIC
	clr	a1
	move	a1,@_pic_secure
	rets
	.else
	FCALL	PICCHECK,b5
	move	a0,a0
	jrnz	gn_bad
	setf	8,0
	movk	16,a9		; Number of bytes of data to read
	movi	_pic_raw,a1	; address at which to store raw data from PIC
	clr	a8
	move	a8,@060C000E0h,1	; Send Request Serial Number Data Command
_rp_data_loop:
	movk	2,a8		; Tell PIC command is available
	setf	16,0
	move	a8,@060400000h,1
	movi	1000000,a2	; Wait for PIC to acknowledge 
_rp_ack_loop:
	move	a2,a2		; Check for command timeout
	jrz	gn_bad		; WOA PIC never acknowledged - ERROR!!!!
	move	a8,@WDOG_BONE,1
	move	@060400000h,a8,1
	subi	1,a2
	btst	1,a8		; Data available ?
	jrnz	_rp_ack_loop	; NO
	setf	8,0		; YES
	move	@060C000E0h,a0,1	; read data
	move	a0,*a1+		; write to temp holding area
	clrs	a8		; Acknowledge receipt of data
	setf	16,0
	move	a8,@060400000h,1
	movi	1000000,a2	; Wait for PIC n acknowlegde
_rp_nack_loop:
	move	a2,a2
	jrz	gn_bad
	move	a8,@WDOG_BONE,1
	move	@060400000h,a8,1
	subi	1,a2
	btst	1,a8
	jrz	_rp_nack_loop
	dsj	a9,_rp_data_loop
	clr	a4		; Holding Register for X
	clr	a5		; Holding Register for Y
	setf	8,0
	movi	_pic_raw,a10
	addi	060h,a10
	move	*a10+,a4	; Get X
	move	*a10,a5		; Get Y
	setf	24,0
	clr	a7		; Calculate B-3-5-9
	movi	_pic_raw,a10
	move	*a10,a7
	subi	15732,a7
	movi	581,a0
	divu	a0,a7
	sub	a4,a7		; B359 (binary)
	FCALL	BIN2BCD,b6	; B359 (bcd) a1 = B359
	setf	4,0
	srl	4,a3
	move	a3,a0
	andi	0fh,a0
	movi	_pic_temp,a10
	addi	014h,a10
	move	a0,*a10		; Stuff the 5
	srl	4,a3
	move	a3,a0
	andi	0fh,a0
	movi	_pic_temp,a10
	addk	0ch,a10
	move	a0,*a10		; Stuff the 3


	movi	_pic_raw,a10
	addi	018h,a10
	move	*a10,a7,1	; Calculate 2-A-0-8-6
	subi	7463513,a7
	movi	4223,a0
	divu	a0,a7
	sub	a5,a7
	sub	a5,a7
	sub	a4,a7		; 2A086 (binary)
	FCALL	BIN2BCD,b6	; 2A086 (bcd)
	move	a3,a0
	andi	0fh,a0
	movi	_pic_temp,a10
	addk	018h,a10
	move	a0,*a10		; Stuff the 6
	srl	4,a3
	move	a3,a0
	andi	0fh,a0
	movi	_pic_temp,a10
	addi	020h,a10
	move	a0,*a10		; Stuff the 8
	srl	4,a3
	move	a3,a0
	andi	0fh,a0
	movi	_pic_temp,a10
	move	a0,*a10		; Stuff the 0
	srl	8,a3
	move	a3,a0
	andi	0fh,a0
	movi	_pic_temp,a10
	addk	8,a10
	move	a0,*a10		; Stuff the 2


	setf	24,0		; Calcuate 1-7-4
	movi	038h,a10
	addi	_pic_raw,a10
	move	*a10,a7
	subi	127984,a7
	movi	7117,a0
	divu	a0,a7
	sub	a5,a7
	sub	a5,a7
	sub	a5,a7
	sub	a5,a7
	sub	a5,a7		; 174 (binary)
	FCALL	BIN2BCD,b6	; 174 (bcd) a1 = 174
	setf	4,0
	move	a3,a0
	andi	0fh,a0
	movi	_pic_temp,a10
	addk	010h,a10
	move	a0,*a10		; Stuff the 4
	srl	4,a3
	move	a3,a0
	andi	0fh,a0
	movi	_pic_temp,a10
	addk	01ch,a10
	move	a0,*a10		; Stuff the 7
	srl	4,a3
	move	a3,a0
	andi	0fh,a0
	movi	_pic_temp,a10
	addk	4,a10
	move	a0,*a10		; Stuff the 1

	setf	16,0
	movi	050h,a10
	addi	_pic_raw,a10
	move	*a10,a0		; This is a pointer to the date code
	movi	0A047FF60h,a1	; Pointer to where the date code is going
	movk	0Ch,a2		; Enable write to CMOS
	move	a2,@SYSCTRL0
	move	a0,*a1+,1
	srl	8,a0
	move	a0,*a1,1
	movk	08h,a2		; Turn OFF CMOS write enable
	move	a2,@SYSCTRL0

	setf	4,0
	movi	_pic_temp,a10
	addk	0ch,a10
	move	*a10+,a0	; Most Significant Digit (serial number)
	sll	4,a0
	move	*a10+,a1
	or	a1,a0
	sll	4,a0
	move	*a10+,a1
	or	a1,a0
	sll	4,a0
	move	*a10+,a1
	or	a1,a0
	sll	4,a0
	move	*a10+,a1
	or	a1,a0
	sll	4,a0
	move	*a10+,a1	; Least Significant Digit (serial number)
	or	a1,a0
	FCALL	_bcd2hex,b6	; Convert to hex
	movi	0A047FF00h,a1	; Pointer to where the serial number is going
	movk	0Ch,a3		; Enable write to CMOS
	move	a3,@SYSCTRL0,1
	move	a2,*a1(040H),1	; LSB of Serial Number -> CMOS
	srl	8,a2
	move	a2,*a1(020H),1	; Mid SB of Serial Number -> CMOS
	srl	8,a2
	move	a2,*a1,1	; MSB of Serial Number -> CMOS
	movk	08h,a2		; Turn OFF CMOS write enable
	move	a2,@SYSCTRL0,1
	
	
	setf	4,0
	movi	_pic_temp,a10
	move	*a10+,a0	; Most Significant Digit (game number)
	sll	4,a0
	move	*a10+,a1
	or	a1,a0
	sll	4,a0
	move	*a10+,a1	; Least Significant Digit (game number)
	or	a1,a0
	FCALL	_bcd2hex,b6	; Convert to hex

	clr	a1
	.if	DEVEL_PIC
	cmpi	528,a2
	.else
	cmpi	419,a2
	.endif
	jrz	gn_good
	cmpi	420,a2
	jrz	gn_good
gn_bad:
	movk	1,a1
gn_good:
	setf	16,0
	move	a1,@_pic_secure

	movi	0A047FFA0h,a1	; Pointer to where the game number is going
	movk	0Ch,a3		; Enable write to CMOS
	move	a3,@SYSCTRL0,1
	move	a2,*a1(020H),1	; LSB of Serial Number -> CMOS
	srl	8,a2
	move	a2,*a1,1	; MSB of Serial Number -> CMOS
	movk	08h,a2		; Turn OFF CMOS write enable
	move	a2,@SYSCTRL0,1


	clr	a0
	setf	8,0
	movi	16,a1
	movi	_pic_raw,a2
_stomp_temp:
	move	a0,*a2+
	dsjs	a1,_stomp_temp
	movi	8,a1
	movi	_pic_temp,a2
_stomp_temp1:
	move	a0,*a2+
	dsjs	a1,_stomp_temp1
	rets
	.endif

; This really doesn't do anything yet because the random number
; generator in the FPGA doesn't work (well at least not predictably)
_unlock:
	movk	3,a0
	move	a0,@060000000H,1
	movi	000005H,a0,1
	move	a0,@020000000H,1
	clr	a0
	move	a0,@060000000H,1
	movi	100000,a1
	movi	0a9586dbah,a2
_tloop:
	move	a8,@WDOG_BONE,1		; Fuck the dog
	move	a2,a3
	move	a2,a4
	sll	30,a4
	andi	1,a4
	sll	27,a3
	andi	1,a3
	xor	a3,a4
	srl	1,a2
	or	a4,a2
	btst	9,a2
	jrz	_read_real
	move	a2,a0
	ori	0f8000000h,a0
	move	*a0,a3,1
	jruc	_read_next
_read_real:
	movi	060000000h,a0
	move	*a0,a5,1
_read_next:
	dsjs	a1,_tloop	; Falls through to _unlock1 below

; Security unlock function.  Gets called from POWERCMOS before the game
; is allowed to run.  This function generates an address to jump to by taking
; the PSUEDO_ADDR value and xoring it with the key code (from CMOS).  If the
; key code is correct the jump takes you to the _unlocked label in POWERCMOS
; and the game runs.  If the key code is incorrect the jump takes the 34020
; to whatever address was generated.  The key code is read from the PIC and
; put into CMOS whenever the CMOS data is initialized.  The code can only be
; extracted from the PIC and put into the CMOS after the operator enters a
; software release specific access code.  This must be done at the factory.
; The access code is the thing we DO NOT want released except to Williams
; personnel on a NEED TO KNOW basis.
;
; The data for the KEY BYTES will be game specific and the data for the
; PSUEDO_ADDR will be software release specific.  In other words, the KEY
; BYTE data will only change from game to game but the PSUEDO_ADDR will
; change from software release to software release for that game.  Generation
; of the PSUEDO_ADDR will be performed by MJL.
;
; Although the KEY BYTES will not change from software release to software
; release for a particular game the access code to allow the number to be
; extracted from the PIC and written into the CMOS will change from software
; release to software release.  MJL will also be responsible for generation
; of access codes for software releases and supplying those codes to
; manufacturing. 
;
; The new access codes will not be needed in the field because the KEY BYTE
; data does not change from software release to software release.

	.globl	_utest

_unlock1:
	movi	CMOS_GN,a2
	move	*a2+,a0,1
	andi	0ffh,a0
	move	*a2,a1,1
	andi	0ffh,a1
	sll	8,a0
	or	a1,a0
	sll	6,a0
_utest:
	addi	0,a0,L		; I dare you to get rid of the ,L
	.if	SECURITY_LEVEL = 0
	jauc	_unlocked
	.else
	jump	a0
	.endif

; Security initialization function.  This function is called when the CMOS
; is initialized for the first time.  It's purpose is to prompt the user to
; enter a 32 bit code and then call the PIC read and decode function.  If the
; user enters an incorrect access code, the processor will go off to never
; never land.  This is designed to work this way in order to as much as
; possible hide the PIC read and decode function from any would be pirates.
; This code should only get called once while the board is still at GURNEE!!!
; Outside users should never be able to get to this function, but if they do
; they will need the access code for it to work right.  MJL will generate and
; supply the access codes.

SECURITY_INIT:
	.STRING	"SECURITY SYSTEM INITIALIZATION",0
	.EVEN
SECURITY_PROMPT
	.STRING	"ENTER ACCESS CODE",0
	.EVEN
SI_INST1
	.STRING	"USE VOL- LEFT/VOL+ RIGHT",0
	.EVEN
SI_INST2
	.STRING	"USE ENTER TO SELECT",0
	.EVEN
SI_INST3
	.STRING	"USE ESCAPE TO FINISH",0
	.EVEN
SI_0:
	.STRING	"0",0
	.EVEN
SI_1:
	.STRING	"1",0
	.EVEN
SI_2:
	.STRING	"2",0
	.EVEN
SI_3:
	.STRING	"3",0
	.EVEN
SI_4:
	.STRING	"4",0
	.EVEN
SI_5:
	.STRING	"5",0
	.EVEN
SI_6:
	.STRING	"6",0
	.EVEN
SI_7:
	.STRING	"7",0
	.EVEN
SI_8:
	.STRING	"8",0
	.EVEN
SI_9:
	.STRING	"9",0
	.EVEN
SI_A:
	.STRING	"A",0
	.EVEN
SI_B:
	.STRING	"B",0
	.EVEN
SI_C:
	.STRING	"C",0
	.EVEN
SI_D:
	.STRING	"D",0
	.EVEN
SI_E:
	.STRING	"E",0
	.EVEN
SI_F:
	.STRING	"F",0
	.EVEN


SI_TABLE
	.LONG	SI_0
	.LONG	SI_1
	.LONG	SI_2
	.LONG	SI_3
	.LONG	SI_4
	.LONG	SI_5
	.LONG	SI_6
	.LONG	SI_7
	.LONG	SI_8
	.LONG	SI_9
	.LONG	SI_A
	.LONG	SI_B
	.LONG	SI_C
	.LONG	SI_D
	.LONG	SI_E
	.LONG	SI_F
	.EVEN

_security_init:
	.if	SECURITY_LEVEL < 2
	jruc	_read_pic_data
	.else
	FCALL	DSCRCLR,b6
	movi	SECURITY_INIT,a0
	FCALL	STRINGCENTER,b6
	clr	a2
	movi	COLOR_RED,a3
	addi	[30,0],a1
	FCALL	STRING,b6
	movi	SECURITY_PROMPT,a0
	FCALL	STRINGCENTER,b6
	clr	a2
	movi	COLOR_YELLOW,a3
	addi	[50,0],a1
	FCALL	STRING,b6
	movi	SI_INST1,a0
	clr	a2
	movi	COLOR_WHITE,a3
	movi	[220,20],a1
	FCALL	STRING,b6
	movi	SI_INST2,a0
	movi	[230,20],a1
	FCALL	STRING,b6
	movi	SI_INST3,a0
	movi	[240,20],a1
	FCALL	STRING,b6
	movi	[180,80],a11		; Entered code location
	clr	a12			; JUMP ADDRESS
	clr	a8			; HILIGHTED SELECTION
_si_loop:
	clr	a9			; Temp counter
	movi	SI_TABLE,a10,1		; Choices
	movi	[100,115],a1
	clr	a2
_si_loop1:				; Plot choices - hilight current
	move	*a10+,a0,1
	cmp	a8,a9
	jrnz	_no_hilight
	movi	COLOR_GREEN,a3		; hilighted = GREEN
	jruc	_si_out
_no_hilight:
	movi	COLOR_WHITE,a3		; Unhilighted = WHITE
_si_out:
	FCALL	STRING,b6
	addk	1,a9
	addi	[0,3],a1
	cmpk	16,a9
	jrnz	_si_loop1
	movi	700000,a3
_si_button_debounce:			; Don't scan too fast!!
	move	a1,@WDOG_BONE,1
	dsjs	a3,_si_button_debounce
_si_wait_button:			; Wait for button down
	move	a1,@WDOG_BONE,1
	move	@COINS,a1,1
	not	a1
	andi	01850h,a1
	jrz	_si_wait_button
_si_button_wait:			; Wait for button up 
	move	a1,@WDOG_BONE,1
	move	@COINS,a2,1
	not	a2
	andi	01850h,a2
	jrnz	_si_button_wait	
	btst	11,a1			; Go right ?
	jrnz	_si_right		; YES
	btst	12,a1			; Go left ?
	jrnz	_si_left		; YES
	btst	4,a1			; Enter ?
	jrnz	_si_enter		; YES
	btst	6,a1			; Done ?
	jrz	_si_loop
	jruc	_si_done
_si_enter:
	sll	4,a12			; Make space for next
	or	a8,a12			; Put in result reg
	move	a8,a0			; Get pointer to value string
	sll	5,a0
	addi	SI_TABLE,a0
	move	*a0,a0,1
	clr	a2
	movi	COLOR_YELLOW,a3
	move	a11,a1
	FCALL	STRING,b6
	addi	[0,8],a11
	jruc	_si_loop		; wait for next input
_si_right:
	addk	1,a8
	cmpk	16,a8
	jrlt	_si_loop
	clr	a8
	jruc	_si_loop
_si_left:
	subk	1,a8
	jrnn	_si_loop
	movk	15,a8
	jruc	_si_loop
_si_done:
	xori	01BD953CEh,a12
	jump	a12			; If Good code get PIC data - put in CMOS
	.endif
	

;XUNIT START

FREAD_SW1_CNS:
	move	@SWITCH,a0
	move	@COINS,a14
	sll	16,a14
	movy	a14,a0
	FRET	b6

FREAD_SW2_DIP:
	move	@SWITCH2,a10
	move	@DIPSWITCH,a14
	sll	16,a14
	movy	a14,a10
	FRET	b6

;XUNIT END


**************************************************************************
*								         *
* 	POWERCMOS							 *
* 									 *
* 	CHECK THE CMOS AND DO A LOT OF OTHER STUFF -- SHOW THE		 *
* 	POWER UP MESSAGES						 *
* 									 *
* 	ENTRY								 *
* 		NOTHING							 *
* 									 *
* 	EXIT								 *
* 		NOTHING							 *
*								         *
**************************************************************************


; This MUST be global for security reasons
	.globl	_unlocked

SN_PROMPT:
	.STRING	"SERIAL NUMBER",0
	.EVEN
PROTO_SND_VER:
	.STRING "PROTO",0
	.EVEN
REL_SND_VER:
	.STRING "RELEASE",0
	.EVEN
SND_VER_PROMPT:
	.STRING	"SOUND SOFTWARE VERSION",0
	.EVEN
UART_TIMEOUT:
	.STRING	"SOUND VERSION INFORMATION FAILURE",0
	.EVEN

POWERCMOS:	
	DINT
	MOVI	SYSCINIT,A1
	MOVE	A1,@SYSCOPY
	MOVE	A1,@SYSCTRL0,L		; XUNIT
	srl	8,a1			; XUNIT
	move	a1,@SYSCTRL1,L		; XUNIT

	CLR	A14
	MOVE	A14,@DMAGOREG,L
	MOVE	A14,@DMAGOREG,L

*INITIALIZE IO REGISTERS
	MOVI	INITDATA,B0
	MOVI	VESYNC,B2
	MOVI	IDATALEN,B7
	BLMOVE	1,1			;TRANSFER I/O REGS

	movi	DPYSTRT0,a14	; XUNIT
	move	a14,@DPYST,L	; XUNIT

	CLR	A13			; USED TO DECIDE WHETHER PAUSE OR NOT
	FCALL	INITCOLR,B5		; FIX UP THE COLORS
	FCALL	DSCRCLR,B6		; MAKE SURE OF SCREEN
	MOVI	ROM_NAME,A0
	FCALL	STRINGCENTER,B6		; GET WIDTH OF STRING
	ADDI	[30,0],A1
	CLR	A2
	MOVI	COLOR_YELLOW,A3
	FCALL	STRING,B6

	.if	SECURITY_LEVEL < 2
	.if	NOPIC
	.else
	calla	_security_init
	.endif
	.else
	.endif

	CALLA	CMOS_VAL		; CHECKSUM AUDITS/ADJUSTMENTS
	JREQ	CMOSOK

	CALLA	FAC_SET			; BUMMER, BABY!  RESET TO FACTORY
	CALLA	BLASTMESS
	CALLA	CLR_AUD
	MOVI    ALL_TAB,A8           	; ALWAYS CLEAR OUT TODAYS TABLE
        CALLA   INIT_TB
	MOVI	TOD_TAB,A8
	CALLA	INIT_TB
        CALLA   INIT_HSR             	; RE-SET THE HIGH SCORE RESET COUNTER

	.if	SECURITY_LEVEL > 1
	calla	_security_init
	.endif

	MOVK	1,A13			; FLAG ERROR
	CALLA	CMOS_VAL		; TRY AGAIN
	JREQ	CMOSB1
	MOVI	CMOS_BAD,A0
	FCALL	STRINGCENTER,B6
	ADDI	[50,0],A1
	CLR	A2
	MOVI	COLOR_RED,A3
	FCALL	STRING,B6
	MOVI	CMOS_UNFAC,A0
	FCALL	STRINGCENTER,B6
	ADDI	[65,0],A1
	CLR	A2
	MOVI	COLOR_RED,A3
	FCALL	STRING,B6
	JRUC	CMOS1
CMOSB1
	MOVI	CMOS_FACRES,A0
	FCALL	STRINGCENTER,B6
	ADDI	[50,0],A1
	CLR	A2
	MOVI	COLOR_RED,A3
	FCALL	STRING,B6
	JRUC	CMOS1
CMOSOK
	MOVI	CMOS_OK,A0
	FCALL	STRINGCENTER,B6
	ADDI	[50,0],A1
	CLR	A2
	MOVI	COLOR_GREEN,A3
	FCALL	STRING,B6
CMOS1

; Security
; Jump to the unlock function - if security checks out a jump to _unlocked
; is performed.
	movi	SECURITY_CHECK,A0
	FCALL	STRINGCENTER,b6
	addi	[70,0],a1
	clr	a2
	movi	COLOR_YELLOW,a3
	FCALL	STRING,b6

	.if	NOPIC = 0
	.if	SECURITY_LEVEL > 0
	setf	16,0
	move	@_pic_secure,a2
	jrz	_pic_scheck_ok
	movi	SECURITY_LEVEL_0_FAIL,a0
	FCALL	STRINGCENTER,b6
	addi	[128,0],a1
	clr	a2
	movi	COLOR_RED,a3
	FCALL	STRING,b6
_pic_scheck_bad:
	move	a8,@WDOG_BONE,1
	jruc	_pic_scheck_bad
_pic_scheck_ok:
	movi	SN_PROMPT,a0
	FCALL	STRINGCENTER,b6
	addi	[128,0],a1
	clr	a2
	movi	COLOR_PURPLE,a3
	FCALL	STRING,b6
	calla	_get_serial_number
	move	a2,a7
	FCALL	BIN2BCD,b6
	sll	8,a3
	movk	6,a4
	movi	_pic_temp,a1
	setf	8,0
_sn_loop:
	move	a3,a2
	andi	0f0000000h,a2
	srl	28,a2
	ori	030h,a2
	move	a2,*a1+
	sll	4,a3
	dsjs	a4,_sn_loop
	clr	a2
	move	a2,*a1
	movi	_pic_temp,a0
	FCALL	STRINGCENTER,b6
	addi	[140,0],a1
	clr	a2
	movi	COLOR_GREEN,a3
	FCALL	STRING,b6
	.else
	setf	16,0
	clr	a2
	move	a2,@_pic_secure

	.endif
	.endif
	calla	INITIALIZE_UART
	clr	a2
	move	a2,@(UART+UART_IMR),1
	movi	10000,a2
_delay_loop:
	movb	a2,@WDOG_BONE
	dsjs	a2,_delay_loop
rx_data_dump_loop:
	move	@(UART+UART_CSR),a2,1
	btst	0,a2
	jrz	rx_empty
	movb	a2,@WDOG_BONE
	move	@(UART+UART_THR),a2,1
	movi	10000,a2
_rx_wait_shit:
	movb	a2,@WDOG_BONE
	dsjs	a2,_rx_wait_shit
	jruc	rx_data_dump_loop
rx_empty:
	movi	100000,a2
tx_wait1:
	move	@(UART+UART_CSR),a3
	btst	2,a3
	jrnz	tx_rdy
	movb	a2,@WDOG_BONE
	dsjs	a2,tx_wait1
	jruc	uart_timeout
tx_rdy:
	movk	3,a2
	move	a2,@(UART+UART_THR),1
	movi	100000,a2
tx_wait2:
	move	@(UART+UART_CSR),a3
	btst	2,a3
	jrnz	tx_rdy1
	movb	a2,@WDOG_BONE
	dsjs	a2,tx_wait2
	jruc	uart_timeout
tx_rdy1:
	movi	0e7h,a2
	move	a2,@(UART+UART_THR),1
	movi	1000000,a2
_rx_wait:
	move	@(UART+UART_CSR),a3,1
	btst	0,a3
	jrnz	rx_rdy
	movb	a2,@WDOG_BONE
	dsjs	a2,_rx_wait
	jruc	uart_timeout
rx_rdy:
	move	@(UART+UART_THR),a2,1
	andi	0ffh,a2
	move	a2,@_pic_temp
	movi	SND_VER_PROMPT,a0
	FCALL	STRINGCENTER,b6
	addi	[160,0],a1
	clr	a2
	movi	COLOR_PURPLE,a3
	FCALL	STRING,b6
	move	@_pic_temp,a0
	srl	4,a0
	andi	0fh,a0
	cmpk	0dh,a0
	jrnz	_rel_version
	movi	PROTO_SND_VER,a0
	jruc	_snd_version
_rel_version:
	movi	REL_SND_VER,a0
_snd_version:
	FCALL	STRINGCENTER,b6
	addi	[170,-8],a1
	clr	a2
	movi	COLOR_PURPLE,a3
	FCALL	STRING,B6
	move	a1,@CKSUM_WORK,1	; Save Position
	movi	SND_VER_PROMPT,a0
	FCALL	STRINGCENTER,b6
	addi	[160,0],a1
	clr	a2
	movi	COLOR_YELLOW,a3
	FCALL	STRING,B6
	move	@_pic_temp,a7
	andi	0fh,a7
	FCALL	BIN2BCD,b6
	sll	24,a3
	move	a3,a4
	andi	0f0h,a4
	jrnz	two_nums
	sll	4,a3
	movk	1,a4
	jruc	do_snd_sn
two_nums:
	movk	2,a4
do_snd_sn:
	movi	_pic_temp,a1
	setf	8,0
_snd_sn_loop:
	move	a3,a2
	andi	0f0000000h,a2
	srl	28,a2
	ori	030h,a2
	move	a2,*a1+
	sll	4,a3
	dsjs	a4,_snd_sn_loop
	clr	a2
	move	a2,*a1
	movi	_pic_temp,a0
	move	@CKSUM_WORK,a1,1
	addi	[0,8],a1
	clr	a2
	movi	COLOR_PURPLE,a3
	FCALL	STRING,b6
	jruc	_snd_done
uart_timeout:
	movi	UART_TIMEOUT,a0
	FCALL	STRINGCENTER,b6
	addi	[160,0],a1
	clr	a2
	movi	COLOR_RED,a3
	FCALL	STRING,B6
_snd_done:
	movi	1000000,a3
_sc_loop:
	move	a8,@WDOG_BONE,1
	dsjs	a3,_sc_loop

	.if	SECURITY_LEVEL > 1
	jauc	_unlock
	.endif

_unlocked:


	MOVI	AUDONTIME,A0
  	.IF	PRINTER
  	CALLA	GET_AUD
  	MOVE	A1,@OFFTIME,L		; SAVE THE LAST POWER TIME STUFF
  	.ENDIF
	CLR	A1
	CALLA	STORE_AUDIT
	MOVI	TOD_TAB,A8
	CALLA	INIT_TB			; LATER, ON TODAY'S TABLE
	MOVI	TOD_TAB,A8		; OK, VALIDATE IT
	CLR	A2			; FOR RECURSION
	CALLA	VAL_TAB
	JRNC	CTAGO
	MOVK	1,A13			; FLAG ERROR
	MOVI	CMOS_TBAD,A0
	FCALL	STRINGCENTER,B6
	ADDI	[77,0],A1
	CLR	A2
	MOVI	COLOR_RED,A3
	FCALL	STRING,B6
CTAGO
	MOVI	ALL_TAB,A8
	CALLA	VAL_TAB			; VALIDATE THE ALLTIME TABLE
	JRNC	CTA1
	MOVK	1,A13			; FLAG ERROR
	MOVI	CMOS_ABAD,A0
	FCALL	STRINGCENTER,B6
	ADDI	[89,0],A1
	CLR	A2
	MOVI	COLOR_RED,A3
	FCALL	STRING,B6
	JRUC	CMOS2
CTA1
	CALLA	CLEAR_HSCOLORS		; WIPE OUT ALL THE COLORATION
	MOVE	A2,A2
	JRNZ	CTA2			; IT GOT INITIALIZED
	CALLA	GET_HSC			; GET HIGHSCORE COUNTER
	JRNZ	CMOS2			; BR = NOT TIME YET
	MOVI	ADJHSRES,A0		; GET ADJUSTED VALUE
	CALLA	GET_ADJ
	JRZ	CMOS2			; TURNED OFF, NOTHING TO DO
	
	MOVI	ALL_TAB,A8
	CALLA	INIT_TB			; LATER ON ALLTIME TABLE
CTA2
	MOVI	CMOS_ALL,A0
	FCALL	STRINGCENTER,B6
	ADDI	[90,0],A1
	CLR	A2
	MOVI	COLOR_GREEN,A3
	FCALL	STRING,B6
	CALLA	INIT_HSR		; RESET THE HIGHSCORE COUNTER
;
;	BY HERE, THE CMOS SHOULD BE FIXED UP AS GOOD AS POSSIBLE -- NOTE
;	THAT IF CMOS IS BUSTED, THE GUY IS FUCKED FOR COINAGE
;
;	WITH SOME THOUGHT THAT MIGHT BE FIXABLE
;
CMOS2
	CALLR	read_dip
	ANDI	DPUSECMOS,A0
	JRNZ	CMOS3		 	; BR = USING CMOS COINAGE

*LOAD COINAGE FROM DIPSWITCH
	MOVI	CMOS_DIP,A0
	FCALL	STRINGCENTER,B6
	ADDI	[110,0],A1
	CLR	A2
	MOVI	COLOR_WHITE,A3
	FCALL	STRING,B6
	
	CALLR	read_dip
	MOVE	A0,A2
	ANDI	DPCOUNTRY,A0
	SRL	3,A0
	ADDI	DIPCOINTAB,A0
	MOVE	*A0,A1,L		; POINTER TO RIGHT COIN TABLE
	ANDI	DPCOINAGE,A2
	CMPI	DPCOINAGE,A2		; CHECK FOR FREEPLAY
	JRZ	CMOS21
	SLL	2,A2
	ADD	A2,A1
	MOVE	*A1,A1,W		; WHICH COIN TABLE TO USE
	MOVI	ADJPRICE,A0		; MASTER PRICING
	CALLA	PUT_ADJ			; STUFF IT IN CMOS
	MOVI	ADJFREPL,A0
	CLR	A1			; MAKE SURE NO FREEPLAY
	CALLA	PUT_ADJ
CMOS20
	MOVI	ADJ1ST6,A0		;MAKE THEM UNTOUCHED PLEASE
	MOVK	1,A1
	CALLA	PUT_ADJ

	CALLA	GET_CSPT
	CALLA	SET_COIN_ADJ		; SET THE ADJUSTMENTS UP IN CMOS

	CALLR	read_dip		;SET UP CREDITS TO START/CONTINUE
	MOVE	A0,A2
	ANDI	DPCREDITS,A2
	SRL	1,A2
	ADDI	DIPCREDTAB,A2
	MOVB	*A2,A1
	ADDK	8,A2
	MOVI	ADJCSTRT,A0
	CALLA	PUT_ADJ
	MOVB	*A2,A1
	MOVI	ADJCCONT,A0
	CALLA	PUT_ADJ
	CALLA   F_ADC_S			;CHECKSUM THE ADJUSTMENTS
	JRUC	CMOS4

CMOS21
	MOVI	ADJFREPL,A0
	MOVK	1,A1			; FREEPLAY, DUDE!
	CALLA	PUT_ADJ
	JRUC	CMOS20
CMOS3
;
;	USING CMOS HERE
;
	MOVI	CMOS_CMOS,A0
	FCALL	STRINGCENTER,B6
	ADDI	[110,0],A1
	CLR	A2
	MOVI	COLOR_WHITE,A3
	FCALL	STRING,B6
CMOS4	
;	CALLR	PLOTCOINAGE		; PLOT SOME COINAGE 
	FCALL	FREAD_SW1_CNS,B6		; READ SWITCH & COINS
	NOT	A0
	ANDI	00080000H,A0
	JRZ	CMOSRET
	MOVI	CMOS_TILT,A0
	FCALL	STRINGCENTER,B6
	ADDI	[205,0],A1
	CLR	A2
	MOVI	COLOR_RED,A3
	FCALL	STRING,B6
	MOVK	1,A13			; FLAG ERROR
CMOSRET
	MOVE	A13,A13
	JRZ	CTMP0
	MOVI	CMOS_ERROR_SND,A0
;	MOVE	A0,@SOUND,W
	MOVI	CMOS_WAIT,A0
	FCALL	STRINGCENTER,B6
	ADDI	[230,0],A1
	CLR	A2
	MOVI	COLOR_RED,A3
	FCALL	STRING,B6
	FCALL	FREAD_SW1_CNS,B6		;XUNIT  HANGOUT FOR A WHILE
	ANDI	00243030H,A0
	MOVE	A0,@SWSET1,L
CTMP1
	FCALL	FREAD_SW1_CNS,B6		; XUNIT GOTTA SEE IF TIME TO LEAVE
	MOVE	@SWSET1,A1,L
	ANDI	00243030H,A0
	CMP	A0,A1
	move	a0,@WDOG_BONE,1
	JREQ	CTMP1
	JRUC	CTMP2
CTMP0
	movi	280000H,a3
PC_END_WAIT			       		;Keep the dog away
	move	a1,@WDOG_BONE,1
	dsjs	a3,PC_END_WAIT			;Give time to read screen

;	PAUSE	200000H,B6
CTMP2
	JAUC	PCMOSRET


	.IF GERMAN
CMOS_FACRES
	.STRING	"CMOS FEHLER -- FABRIKDATENEINSTELLUNG",0
	.EVEN
CMOS_WAIT
	.STRING	"SPIELFORTSETZUNG MIT BELIEBIGEM KNOPF",0
	.EVEN
CMOS_BAD
	.STRING	"CMOS RAM U15 FEHLER",0
	.EVEN


	.ELSE
CMOS_FACRES
	.STRING	"CMOS INVALID -- FACTORY SETTINGS RESTORED",0
	.EVEN
CMOS_WAIT
	.STRING	"ERRORS DETECTED -- ANY BUTTON TO CONTINUE",0
	.EVEN
CMOS_BAD
	.STRING	"CMOS CHIP U15 BAD",0
	.EVEN


	.ENDIF

CMOS_TILT
	.STRING	"WARNING -- SLAM SWITCH CLOSED",0
	.EVEN
	     
CMOS_DIP
	.STRING	"USING DIPSWITCH COINAGE",0
	.EVEN

CMOS_CMOS
	.STRING	"USING CMOS COINAGE",0
	.EVEN

CMOS_UNFAC
	.STRING	"UNABLE TO RESTORE FACTORY SETTINGS",0
	.EVEN

CMOS_OK
	.STRING	"CMOS OK",0
	.EVEN

CMOS_ALL
	.STRING	"ALL TIME HIGH SCORES RESET",0
	.EVEN

CMOS_ABAD
	.STRING	"UNABLE TO RESET ALLTIME HIGHSCORE TABLE",0
	.EVEN
CMOS_TBAD
	.STRING	"UNABLE TO RESET DAILY HIGHSCORE TABLE",0
	.EVEN

; security check message
SECURITY_CHECK
	.if SECURITY_LEVEL = 0
	.STRING	"UNSECURED SYSTEM",0
	.else
	.mmsg	"SEC LEVEL 1"
	.STRING	"SECURITY CHECK",0
	.endif
	.EVEN

**************************************************************************
*								         *
* 	PLOTCOINAGE							 *
* 									 *
* 	PLOT OUT THE CURRENT COINAGE ON THE SCREEN			 *
* 									 *
* 	ENTRY								 *
* 		NOTHING							 *
* 									 *
* 	EXIT								 *
* 		NOTHING							 *
*								         *
**************************************************************************
****PLOTCOINAGE:
****	.IF	PRINTER
****	RETS
****	.ELSE
****	MOVI	ADJFREPL,A0
****	CALLA	GET_ADJ
****	JRNZ	PCFREE
****PC1
****	MOVI	ADJPRICE,A0
****	CALLA	GET_ADJ			; GET THE CURRENT PRICING
****        CALLA   GET_CSPT
****        MOVE    *A6(CS_LIST),A7,L  	
****        JRZ	PCNOHEAD		; NO HEADER, BELIEVE IT OR NOT
****	MOVI	[130,0],A8		; BASE ADDRESS FOR STRING
****PCNEXTHEAD
****        MOVE    *A7+,A0,L            	; PICKUP THE NEXT POINTER
****	JRZ	PCNOHEAD
****
****	FCALL	STRINGCENTER,B6
****	ADD	A8,A1
****	CLR	A2
****	MOVI	COLOR_YELLOW,A3
****	FCALL	STRING,B6
****	ADDI	[12,0],A8		; MOVE DOWN A LINE
****
****	JRUC	PCNEXTHEAD
****	JRUC	PCNOHEAD
****PCFREE
****	MOVI	DUCOIN7,A0
****	FCALL	STRINGCENTER,B6
****	ADDI	[130,0],A1
****	CLR	A2
****	MOVI	COLOR_YELLOW,A3
****	FCALL	STRING,B6
****PCNOHEAD
****	RETS
****	.ENDIF

**************************************************************************
*								         *
* 									 *
* 	CPU TESTING ROUTINES						 *
* 									 *
*								         *
**************************************************************************

**************************************************************************
*								         *
* 	BURNIN								 *
* 									 *
* 	FACTORY BURNIN TEST -- EXITS BY RESETING THE GAME		 *
* 									 *
* 	ENTRY								 *
* 		NOTHING							 *
* 									 *
* 	EXIT								 *
* 		NOTHING 						 *
* 									 *
* 	CALL								 *
* 		JAUC							 *
*								         *
**************************************************************************

BURNIN:
	DINT
	MOVI	AUDAUTO,A0		;ZERO OUT BURNIN AUDIT
	CALLA	KILL_AUD

BURNLOOP
	MOVI	SYSC_COLD,A0		;Grab cold start values
	MOVE	A0,@SYSCTRL0,L
	srl	8,a0
	MOVE	A0,@SYSCTRL1,L

	FCALL	CPUTEST,SP

	MOVI	SYSC_COLD,A0		;Grab cold start values
	MOVE	A0,@SYSCTRL0,L
	srl	8,a0
	MOVE	A0,@SYSCTRL1,L

; At this point all of the DRAM is trashed - SOOOOO reload the vector
; table and code

	MOVI	vector_start,B0
	MOVI	vector_dest,B2
	MOVI	vector_end,B7
	SUB	B0,B7
	BLMOVE	1,1			;TRANSFER VECTORS

	MOVI	code_start,B0
	MOVI	code_dest,B2
	MOVI	code_end,B7
	SUB	B0,B7
	BLMOVE	1,1			;TRANSFER CODE, ZZZZZZ

BURNSP:
	SETF	16,1,0
	SETF	32,1,1
	MOVI	STCKST,SP,L		;RESTORE THE STACK PTR

	MOVI	AUDAUTO,A0
	CALLA	AUD1			;ANOTHER ONE WORKED
	JRUC	BURNLOOP

**************************************************************************
*								         *
* 	DIAGCPUTEST							 *
* 									 *
* 	DIAGNOSTIC CALL FOR THE CPU TEST				 *
* 									 *
* 	ENTRY								 *
* 		NOTHING							 *
* 									 *
* 	EXIT								 *
* 		JUMPS TO *EXEC_LP* AFTER SETTING EVERYTHING UP		 *
* 									 *
* 	CALL								 *
* 		JAUC							 *
*								         *
**************************************************************************

DIAGCPUTEST:
	DINT

	MOVI	SYSCINIT&(~WRPROTHI),A0
	MOVB	A0,@SYSCOPY
	MOVE	A0,@SYSCTRL0,L		; XUNIT

	FCALL	CPUTEST,SP

; At this point all of the DRAM is trashed - SOOOOO reload the vector
; table and code

	MOVE	A1,@WDOG_BONE,L

	MOVI	vector_start,B0
	MOVI	vector_dest,B2
	MOVI	vector_end,B7
	SUB	B0,B7
	BLMOVE	1,1			;TRANSFER VECTORS

	MOVI	code_start,B0
	MOVI	code_dest,B2
	MOVI	code_end,B7
	SUB	B0,B7
	BLMOVE	1,1			;TRANSFER CODE, ZZZZZZ

	MOVE	A1,@WDOG_BONE,L

DIAGSP:
	jauc	_backtogame

; XUNIT NEED TO RUN THE FOLLOWING CODE OUT OF RAM IN CASE AN
; INTERRUPT OCCURS BEFORE WE JUMP BACK TO EXEC_LP
	.text
_backtogame:

	SETF	16,1,0			; WORD NO SIGN EXTEND
	SETF	32,1,1			; LONG WORD
	MOVI	STCKST,SP,L
	CALLA	CLSCRACH
	MOVI	SYSCINIT,A0
	MOVE	A0,@SYSCOPY,W
	MOVE	A0,@SYSCTRL0,L		; XUNIT
	srl	8,a0			; XUNIT
	MOVE	A0,@SYSCTRL1,L		; XUNIT

	CALLA	MAIN_INIT

	CALLA	COLOR_START		;FIRE UP THE COLORS

	EINT				; ENABLE INTERRUPTS AND WE'RE OFF
	DISPON				; ENABLE THE DISPLAY SYSTEM
	CREATE	PID_DIAG,CPU_RET
	MOVI	INDIAG,A0
	MOVE	A0,@GAME_STATE,W
	JAUC	EXEC_LP

	.sect	"COLDSTRT"

**************************************************************************
*								         *
* 	POWERCPUTEST							 *
* 									 *
* 	CHECK OUT THE CPU ON POWER ON					 *
* 									 *
* 	ENTRY								 *
* 		NOTHING							 *
* 									 *
* 	EXIT								 *
* 		JUMPS TO *PONTEST*					 *
* 									 *
* 	CALL								 *
* 		JAUC							 *
*								         *
**************************************************************************

POWERCPUTEST:
	DINT

;NO DIPSWITCHES AVAILABLE FOR THIS
;	MOVE	@DIPSWITCH,A0,L		; CHECK FOR POWER ON BYPASS
;	NOT	A0
;	ANDI	0400H,A0
;	JANZ	PONTEST

	FCALL	CPUTEST,SP
	JAUC	PONTEST


**************************************************************************
*								         *
* 	CPUTEST								 *
* 									 *
* 	THE ACTUAL CPU TEST STUFF					 *
* 									 *
* 	ENTRY								 *
* 		SP	RETURN ADDRESS					 *
* 									 *
* 	EXIT								 *
* 		WHO KNOWS						 *
* 									 *
* 	CALL								 *
* 		FCALL	CPUTEST,SP					 *
*								         *
**************************************************************************
CPUT_X	.EQU	25	;TEXT X POSITION
;CPUT_Y1	.EQU	128	;TEXT ROW 1 Y POSITION
;CPUT_Y2	.EQU	140	;TEXT ROW 2 Y POSITION
;CPUT_Y3	.EQU	152	;TEXT ROW 3 Y POSITION

CPUT_Y1	.EQU	64	;TEXT ROW 1 Y POSITION
CPUT_Y2	.EQU	76	;TEXT ROW 2 Y POSITION
CPUT_Y3	.EQU	88	;TEXT ROW 3 Y POSITION

CPUT_CLR .EQU	[CPUT_Y1,CPUT_X]	;CLEAR START
CPUT_CLRS .EQU	[CPUT_Y3-CPUT_Y1+15,200-CPUT_X]

CPUTEST:
	MOVB	A0,@WDOG_BONE		;HERE DOGGY DOGGY
	FCALL	INITCOLR,B5		;HEY! IT LOOKS BETTER THIS WAY
	FCALL	DSCRCLR,B6		;BLOW THE SCREEN OR IT LOOKS TOO UGLY

	CLR	B0
	MOVI	VRAMCHIPS,A14		;VERIFY BIT MAP
	FCALL	RAMCHECK,B5

;	ENABLE VIDEO PALETTE MAP ACCESS

	MOVI	PALCHIPS,A14		;VERIFY OBJECT PALETTE RAM
	FCALL	RAMCHECK,B5
	MOVE	B0,A12
	
;	DISABLE VIDEO PALETTE MAP ACCESS

	FCALL	INITCOLR,B5		;RELOAD THE COLORS
	FCALL	DSCRCLR,B6

	FCALL	CPUDRAW,B5		;SHOW THE CPU
	MOVI	CPU,A10			;WE GOT THIS FAR, CPU MUST BE OK
	MOVI	1,A11
	FCALL	CHIPOUT,B5

	MOVI	VRAMTAB,A9
	FCALL	CHIPTABLE,B5		;PLOT OUT THE CHIP TABLE

	MOVE	A12,A12
	JRZ	PSRAMCK
PBADRAM
	MOVI	RAMBADMESS,A0
	MOVI	[CPUT_Y1,CPUT_X],A1
	CLR	A2
	MOVI	COLOR_RED,A3
	FCALL	STRING,B6
	JRUC	PCPUBAD

PSRAMCK
	MOVI	SRAMCHECK,A0
	MOVI	[CPUT_Y1,CPUT_X],A1
	CLR	A2
	MOVI	COLOR_YELLOW,A3
	FCALL	STRING,B6

	CLR	B0
	MOVI	SRAMCHIPS,A14			;VERIFY SCRATCH RAMS
	FCALL	RAMCHECK,B5
	MOVE	B0,A12
	
	MOVI	CPUT_CLR,A0
	MOVI	CPUT_CLRS,A1
	MOVI	COLOR_BLACK,A2
	FCALL	RECTANGLE,B6

	MOVE	A12,A12
	JRNZ	PBADRAM

PROMCK
	MOVI	ROMCMESS,A0
	MOVI	[CPUT_Y1,CPUT_X],A1
	CLR	A2
	MOVI	COLOR_YELLOW,A3
	FCALL	STRING,B6

	MOVI	CPUEXIT1_MESS,A0
	MOVI	[CPUT_Y2,CPUT_X],A1
	CLR	A2
	MOVI	COLOR_YELLOW,A3
	FCALL	STRING,B6

	MOVI	CPUEXIT2_MESS,A0
	MOVI	[CPUT_Y3,CPUT_X],A1
	CLR	A2
	MOVI	COLOR_YELLOW,A3
	FCALL	STRING,B6

	CLR	B0			;KEEP THE STATS HERE

	movk	1,a0
	move	a0,@_rom_type,W

	movi	PROMBANKS,a0
	fcall	_rom_sums,b5

; TEST PURPOSES ONLY - Put back when Prog ROM checksums stabalize
	JRNZ	PROMABORT

	clr	a0
	move	a0,@_rom_type,W

	movi	IROMBANKS,a0
	fcall	_rom_sums,b5
; TEST PURPOSES ONLY - Take out when Prog ROM checksums stabalize
;	jruc	PDMACK
	JRZ	PDMACK

PROMABORT
	MOVE	B0,A12
	MOVI	CPUT_CLR,A0
	MOVI	CPUT_CLRS,A1
	MOVI	COLOR_BLACK,A2
	FCALL	RECTANGLE,B6
	MOVE	A12,A12
	JRNZ	PBADROM

*WE CHECK ON THE DMA HERE
PDMACK
; Before we can check the DMA we have to copy the DMA test from
; its load address to it's run address.  This is because when the DMA
; is active we loose access to ROM.
	movi	DMACHECK,a0		; run address of dma test
	movi	dmatest_start,a1	; load address of dma test
	movi	dmatest_end,a2		; calculate amount to move
	sub	a1,a2			
	srl	3,a2			; move it in bytes
	setf	8,0
_dmatm_loop:
	move	*a1+,*a0+,0
	dsjs	a2,_dmatm_loop

	MOVI	DMACMESS,A0
	MOVI	[CPUT_Y1,CPUT_X],A1
	CLR	A2
	MOVI	COLOR_YELLOW,A3
	FCALL	STRING,B6

	FCALL	DMACHECK,B5		;CHECK THE DMA
	MOVI	DMA,A10
	MOVE	A0,A11
	MOVE	A0,A12
	INC	A11			;GREEN/RED
	FCALL	CHIPOUT,B5

	MOVI	CPUT_CLR,A0
	MOVI	CPUT_CLRS,A1
	MOVI	COLOR_BLACK,A2
	FCALL	RECTANGLE,B6
	MOVE	A12,A12
	JRNZ	PBADDMA
PUARTCK
	MOVI	UARTMESS,A0
	MOVI	[CPUT_Y1,CPUT_X],A1
	CLR	A2
	MOVI	COLOR_YELLOW,A3
	FCALL	STRING,B6
	FCALL	UARTCHECK,B5
	MOVI	UART_CHIP,A10
	MOVE	A0,A11
	MOVE	A0,A12
	INC	A11
	FCALL	CHIPOUT,B5
	MOVI	CPUT_CLR,A0
	MOVI	CPUT_CLRS,A1
	MOVI	COLOR_BLACK,A2
	FCALL	RECTANGLE,B6
	MOVE	A12,A12
	JRNZ	PBADUART

PPICCK
	MOVI	PICMESS,A0
	MOVI	[CPUT_Y1,CPUT_X],A1
	CLR	A2
	MOVI	COLOR_YELLOW,A3
	FCALL	STRING,B6
	.if	NOPIC
	CLR	A0
	.else
	FCALL	PICCHECK,B5
	.endif
	MOVI	PIC,A10
	MOVE	A0,A11
	MOVE	A0,A12
	INC	A11
	FCALL	CHIPOUT,B5
	MOVI	CPUT_CLR,A0
	MOVI	CPUT_CLRS,A1
	MOVI	COLOR_BLACK,A2
	FCALL	RECTANGLE,B6
	MOVE	A12,A12
	JRZ	PCPUGOOD

PBADPIC
	MOVI	PICBADMESS,A0
	MOVI	[CPUT_Y1,CPUT_X],A1
	CLR	A2
	MOVI	COLOR_RED,A3
	FCALL	STRING,B6
_bad_pic_loop:
	move	a0,@WDOG_BONE,1
	jruc	_bad_pic_loop

PBADUART
	MOVI	UARTBADMESS,A0
	MOVI	[CPUT_Y1,CPUT_X],A1
	CLR	A2
	MOVI	COLOR_RED,A3
	FCALL	STRING,B6
	JRUC	PCPUBAD

PBADDMA
	MOVI	DMABADMESS,A0
	MOVI	[CPUT_Y1,CPUT_X],A1
	CLR	A2
	MOVI	COLOR_RED,A3
	FCALL	STRING,B6
	JRUC	PCPUBAD

PBADROM
	MOVI	CPUT_CLR,A0
	MOVI	CPUT_CLRS,A1
	MOVI	COLOR_BLACK,A2
	FCALL	RECTANGLE,B6
	MOVI	ROMBADMESS,A0
	MOVI	[CPUT_Y1,CPUT_X],A1
	CLR	A2
	MOVI	COLOR_RED,A3
	FCALL	STRING,B6

PCPUBAD
	MOVI	CPUPAUSE,A0
	MOVI	[CPUT_Y2,CPUT_X],A1
	CLR	A2
	MOVI	COLOR_RED,A3
	FCALL	STRING,B6

PCPUWAIT
        MOVB	B14,@WDOG_BONE

	MOVI	CPU_ERROR_SND,A0
;	MOVE	A0,@SOUND,W

	MOVE	A13,B5
	PAUSE	10000,B6
	FCALL	FREAD_SW1_CNS,B6		; XUNIT
	ANDI	00243030H,A0
	MOVE	A0,@SWSET1,L
	MOVI	-1,B0			; ASSUME DON'T TIMEOUT
	CMPI	DIAGSP,SP
	JRZ	PCPUTMP1
	CMPI	BURNSP,SP
	JRZ	PCPUTMP1
	MOVI	200000H,B0
PCPUTMP1
        MOVB	B14,@WDOG_BONE
	MOVE	B0,B0
	JRN	PCPUNOTIMEOUT
	DEC	B0
	JRZ	PCPURET			; TIMEOUT HERE
PCPUNOTIMEOUT
	FCALL	FREAD_SW1_CNS,B6		; XUNIT GOTTA SEE IF TIME TO LEAVE
	MOVE	@SWSET1,A1,L
	ANDI	00243030H,A0
	CMP	A0,A1
	JRNZ	PCPURET
	JRUC	PCPUTMP1
PCPUGOOD
	CLR	A0
	JRUC	PCPUREALRET
PCPURET
	MOVK	1,A0
PCPUREALRET
	MOVE	A0,A0
	FRET	SP

	.IF GERMAN
; UART & PIC Messages
UARTMESS
	.STRING	"U7 PRUEFEN",0
	.EVEN

UARTBADMESS
	.STRING	"U7 DEFEKT",0
	.EVEN

PICMESS
	.STRING	"U444 PRUEFEN",0
	.EVEN
PICBADMESS
	.STRING "U444 DEFEKT",0
	.EVEN


DMACMESS
	.STRING	"U76 PRUEFEN",0
	.EVEN
DMABADMESS
	.STRING	"U76 DEFEKT",0
	.EVEN

ROMCMESS
	.STRING	"ROMS PRUEFEN",0
	.EVEN
ROMBADMESS
	.STRING	"ROM DEFEKT",0
	.EVEN

RAMBADMESS
	.STRING	"RAM DEFEKT",0
	.EVEN

CPUGOOD
	.STRING	"CPU-PLATINE OK",0
	.EVEN

CPUWAIT1
CPUPAUSE
	.STRING	"BELIEBIGEN KNOPF DRUECKEN",0
	.EVEN

CPUEXIT1_MESS
	.STRING "HALTE START",0
	.EVEN
CPUEXIT2_MESS
	.STRING "ZUM VERLASSEN.",0
	.EVEN

	.ELSE

; UART & PIC Messages
UARTMESS
	.STRING	"CHECKING UART",0
	.EVEN
UARTBADMESS
	.STRING	"UART FAILURE",0
	.EVEN

PICMESS
	.STRING	"CHECKING CUSTOM U444",0
	.EVEN
PICBADMESS
	.STRING	"CUSTOM CHIP U444 BAD",0
	.EVEN

DMACMESS
	.STRING	"CHECKING CUSTOM",0
	.EVEN
DMABADMESS
	.STRING	"CUSTOM CHIP U76 BAD",0
	.EVEN

ROMCMESS
	.STRING	"CHECKING ROMS",0
	.EVEN
ROMBADMESS
	.STRING	"ROM CHIPS BAD",0
	.EVEN

RAMBADMESS
	.STRING	"RAM CHIPS BAD",0
	.EVEN

CPUGOOD
	.STRING	"CPU BOARD OK",0
	.EVEN

CPUWAIT1
CPUPAUSE
	.STRING	"PRESS ANY BUTTON",0
	.EVEN

CPUEXIT1_MESS
	.STRING "ESCAPE OR START",0
	.EVEN
CPUEXIT2_MESS
	.STRING "TO EXIT.",0
	.EVEN

	.ENDIF

**************************************************************************
*								         *
* 	CPUDRAW								 *
* 									 *
* 	PLOT THE CPU BOARD AND DRAW ALL THE CHIPS			 *
* 									 *
* 	ENTRY								 *
* 		B5	RETURN ADDRESS					 *
* 									 *
* 	EXIT								 *
* 		NOTHING							 *
*								         *
**************************************************************************

CPUDRAW:
	MOVI	CPU_VECS,A9		; POINT AT VECTOR TABLE
CPUDLP1
	MOVE	*A9+,A2,W		; GET COLOR
	JRZ	CPUD1
	MOVE	*A9+,A0,L		; START POINT
	MOVE	*A9+,A1,L		; END POINT
	FCALL	HVLINE,B6
	JRUC	CPUDLP1
CPUD1
	MOVE	B5,A13
	FCALL	CHIPPLOT,B5		; PLOT ALL THE CHIPS
	MOVI	BOARDSTRING,A0
	MOVI	[227,17],A1
	CLR	A2
	MOVI	COLOR_WHITE,A3
	FCALL	STRING,B6
	MOVI	BOARDSTRING2,A0
	MOVI	[239,19],A1
	FCALL	STRING,B6
	MOVE	A13,B5
	FRET	B5

BOARDSTRING	
	.STRING	"A-16744-40019",0
	.EVEN

BOARDSTRING2
	.STRING	"REVOLUTION X",0
	.EVEN

**************************************************************************
*								         *
* 	CHIPTABLE							 *
* 									 *
* 	UPDATE A LIST OF CHIPS, BASED ON THEIR VALUES IN A12		 *
* 									 *
* 	ENTRY								 *
* 		A9	POINTER TO TABLE				 *
* 		A12	LIST OF ON/OFF BITS				 *
* 		B5	RETURN ADDRESS					 *
* 									 *
* 	EXIT								 *
* 		NOTHING							 *
*								         *
**************************************************************************

CHIPTABLE:
	MOVE	B5,A14
CTABLOOP
	MOVE	*A9+,A10,L		; GET POINTER TO CHIP RECORD
	JRZ	CTABDONE
	MOVK	1,A11
	MOVE	*A10(CMNUM),A0,W	; GET THE BIT NUMBER
	BTST	A0,A12			; CHECK BIT NUMBER
	JRZ	CTABL2
	MOVK	2,A11
CTABL2
	FCALL	CHIPOUT,B5
	JRUC	CTABLOOP

CTABDONE
	MOVE	A14,B5
	FRET	B5
	
**************************************************************************
*								         *
* 	CHIPPLOT							 *
* 									 *
* 	PLOT OUT THE CHIP LIST						 *
* 									 *
* 	ENTRY								 *
* 		B5	RET VALUE					 *
* 									 *
* 	EXIT								 *
* 		NOTHING							 *
**************************************************************************

CHIPPLOT:
	MOVE	B5,A14
	MOVI	CPU_CHIPS,A10
CPPLOTLOOP
	CLR	A11
	MOVE	*A10,A0,L
	JRZ	CPPLOTDONE
	FCALL	CHIPOUT,B5
	ADDI	CMEND,A10
	JRUC	CPPLOTLOOP

CPPLOTDONE
	MOVE	A14,B5
	FRET	B5
	
**************************************************************************
*								         *
* 	CHIPOUT								 *
* 									 *
* 	ACTUALLY PLOT THE CHIP						 *
* 									 *
* 	ENTRY								 *
* 		A10	POINTS TO CHIP TO PLOT				 *
* 		A11	COLOR OF CHIP					 *
* 				00 = OUTLINE				 *
* 				01 = GREEN				 *
* 				02 = RED				 *
* 				03 = GREY				 *
* 									 *
* 	EXIT								 *
* 		A10	IS INTACT					 *
*								         *
**************************************************************************
		
CHIPOUT:
	MOVE	*A10(CMLOC),A5,L	; CHIP OUTLINE
	MOVE	A5,A6
	MOVE	A5,A7
	MOVE	A5,A8
	MOVE	*A10(CMXSIZE),A0,W
	ADD	A0,A6
	ADD	A0,A7
	MOVE	*A10(CMYSIZE),A0,W
	SLL	16,A0
	ADD	A0,A7
	ADD	A0,A8
	MOVE	A5,A0
	MOVE	A6,A1
	MOVI	COLOR_WHITE,A2
	FCALL	HVLINE,B6
	MOVE	A6,A0
	MOVE	A7,A1
	ADDI	[1,0],A1
	MOVI	COLOR_WHITE,A2
	FCALL	HVLINE,B6
	MOVE	A8,A0
	MOVE	A7,A1
	MOVI	COLOR_WHITE,A2
	FCALL	HVLINE,B6
	MOVE	A5,A0
	MOVE	A8,A1
	MOVI	COLOR_WHITE,A2
	FCALL	HVLINE,B6
	MOVE	*A10(CMSTUFFED),A0,W	; CHECK FOR STUFFED
	JRNZ	CONOSTUF
	MOVK	3,A11			; WANT IT GREY, DUDE

CONOSTUF
	MOVE	A11,A11			; CHECK FOR FILLING THE CHIP
	JRZ	CONOFILL
	MOVE	*A10(CMLOC),A0,L
	ADDI	00010001H,A0
	MOVE	*A10(CMSIZE),A1,L
	SUBI	00010001H,A1		; GET INTERNAL AREA
	MOVE	A11,A2
	SLL	4,A2
	ADDI	CHIPCOLORS,A2
	MOVE	*A2,A2,W		;XUNIT  GET ME A COLOR
	FCALL	RECTANGLE,B6
CONOFILL
	MOVE	*A10(CMPINLOC),A1,L	; PIN LOCATION
	MOVE	A5,A0
	ADDXY	A1,A0
	MOVI	COLOR_WHITE,A1
	FCALL	POINT,B6

	MOVE	*A10(CMSTRING),A0,L	; CHIP TEXT
	MOVE	A5,A1
	MOVE	*A10(CMOFFSET),A2,L
	ADD	A2,A1
	MOVE	*A10(CMDIR),A2,W
	MOVI	COLOR_BLACK,A3
	MOVI	020H,A5
	MOVE	A5,@0C0000190H,0	; TURN ON TRANSPARENCY
	MOVE	A11,A11			; CHECK FOR COLOR
	JRNZ	COBLACK
	CLR	A5
	MOVE	A5,@0C0000190H,0	; TURN ON TRANSPARENCY
	MOVI	COLOR_WHITE,A3
COBLACK
	FCALL	STRING,B6
	FRET	B5

CHIPCOLORS:
	.WORD	COLOR_BLACK
	.WORD	COLOR_GREEN
	.WORD	COLOR_RED
	.WORD	COLOR_GREY
	.WORD	COLOR_PURPLE

**************************************************************************
*								         *
* 	DMACHECK							 *
* 									 *
* 	CHECK THE DMA OUT						 *
* 									 *
* 	ENTRY								 *
* 		B5	RETURN ADDRESS					 *
* 									 *
* 	EXIT								 *
* 		A0	DMA STATUS					 *
* 				0 = GOOD				 *
* 				1 = BAD					 *
*								         *
**************************************************************************
	.text
	.label	dmatest_start
DMACHECK			; rewritten for XUNIT
        MOVB	B14,@WDOG_BONE
	CLR	A14
	MOVE	A14,@DMAGOREG,L
	MOVE	A14,@DMAGOREG,L
	movi	SYSC_COLD,a14
	ori	1,a14
	move	a14,@SYSCTRL1,L
	MOVi	DMACF4,A14		; XUNIT
	MOVE	A14,@DMACONFIG,L	;ADJUST WINDOW RIGHT/LEFT BORDER
	MOVI	[511,0],A14
	MOVE	A14,@DMAWINDOW,L		;OPEN LEFT TO RIGHT
	MOVI	DMAWIN|DMACF4,A14
	MOVE	A14,@DMACONFIG,W	;ADJUST WINDOW RIGHT/LEFT BORDER
	MOVI	[511,0],A14
	MOVE	A14,@DMAWINDOW,L		;FULL HEIGHT WINDOW
	MOVI	[100H,100H],A14
	MOVE	A14,@DMAXYSCL,L

	MOVI	[1,448],A14		;BLOW OUT TRADEMARK
	MOVE	A14,@DMAHVSIZE,L

	MOVI	IROM,A14		;DMA LOGO LOCATION
	MOVE	A14,@DMASAG,L

	MOVI	[257,0],A14
	MOVE	A14,@DMAHV,L		;OFFSCREEN PLOT

	MOVI	0505H,A14
	MOVE	A14,@DMACMAPCON,L	; CONST = 0, CMAP = 505h

	MOVI	[8003H,0],A14		;USE IMAGE ROM - WRITE ALWAYS
	MOVE	A14,@DMAOFFCTL,L 	;KICK OFF THE DMA

	MOVI	7FFFH,A14		;LOAD TIMEOUT COUNTER
DMACWAIT
        MOVE	B14,@WDOG_BONE
	MOVE	@DMAGOREG,A0,L		;DMA BUSY?
	JRNN	DMADONE			;BR = NO, TIME TO CHECK
	DSJS	A14,DMACWAIT
	JRUC	DMACBAD			;DMA TIMED OUT

DMADONE
	CLR	A0			;GET BACK TO A REAL PALETTE
	MOVE	A0,@DMACMAPCON,L
	MOVI	0101000H,A0		;LINEAR SCREEN LOCATION OF DATA
	MOVI	IROM,A1		;DMA LOGO LOCATION
	MOVI	448,A2			;NUMBER OF BYTES TO COMPARE
DMACLOOP	     
	MOVB	*A0,A3			;DESTINATION BYTE
	MOVB	*A1,A4			;SOURCE BYTE
	ADDK	8,A0
	ADDK	8,A1
	CMP	A3,A4
	JRNZ	DMACBAD			;BR = DATA ERROR
	DSJS	A2,DMACLOOP
*
*CHECK DATA IN OBJECT PALETTE
*
	MOVI	0901000H,A0		;LOCATION
	MOVI	224,A2			;NUMBER OF WORDS TO COMPARE
DMACLOOP2
	MOVE	*A0+,A3,W
	CMPI	0505H,A3
	JRNZ	DMACBAD
	DSJS	A2,DMACLOOP2
	CLR	A0
	JRUC	DMACRET
DMACBAD
	CLR	A0			;GET BACK TO A REAL PALETTE
	CLR	A14
	MOVE	A14,@DMAGOREG,L
	MOVE	A14,@DMAGOREG,L
	MOVE	A0,@DMAOFFCTL,L
	MOVE	A0,@DMACMAPCON,L
	MOVK	1,A0
DMACRET
	CLR	A14
	MOVE	A14,@DMAGOREG,L
	MOVE	A14,@DMAGOREG,L
	movi	SYSC_COLD,a14
	ori	1,a14
	move	a14,@SYSCTRL1,L

	MOVE	A0,A0
	FRET	B5
	.label	dmatest_end

	.sect	"COLDSTRT"
**************************************************************************
*                                                                        *
* PICCHECK                                                               *
*                                                                        *
* Checks to see if the PIC exists and is accessible                      *
*                                                                        *
* 	ENTRY								 *
* 		B5	RETURN ADDRESS					 *
* 									 *
* 	EXIT								 *
* 		A0	PIC STATUS					 *
* 				0 = GOOD				 *
* 				1 = BAD					 *
*								         *
**************************************************************************
	.if	NOPIC
	.else
PICCHECK
	setf	8,0
	movk	0fh,a8
        movb    a8,@060C000E0h
        movk    2,a8
        setf    16,0
	move	a8,@060400000h
	movi	100000,a9
_pic_loop1:
	move	a9,a9
	jrz	_pic_error
	move	a8,@WDOG_BONE,1
        move    @060400000h,a8
	subi	1,a9
        btst    1,a8
        jrnz    _pic_loop1
        setf    8,0
        move    @060C000E0h,a9
        clrs    a8
        setf    16,0
	move	a8,@060400000h
	movi	100000,a0
_pic_loop2:
	move	a0,a0
	jrz	_pic_error
	move	a8,@WDOG_BONE,1
        move    @060400000h,a8
	subi	1,a0
        btst    1,a8
        jrz     _pic_loop2
	cmpk	0fh,a9
	jrnz	_pic_error
	clr	a0
	jruc	_pic_done
_pic_error:
	movk	1,a0
_pic_done:
	FRET	b5
	.endif

**************************************************************************
*                                                                        *
* UARTCHECK                                                              *
*                                                                        *
* Checks to see if the UART is accessible and working                    *
*                                                                        *
* 	ENTRY								 *
* 		B5	RETURN ADDRESS					 *
* 									 *
* 	EXIT								 *
* 		A0	UART STATUS     				 *
* 				0 = GOOD				 *
* 				1 = BAD					 *
*								         *
**************************************************************************
UARTCHECK
_uart_data_test:
        MOVK    26,A8
        MOVE    A8,@080c00040h,1
        MOVI    48,A8
        MOVE    A8,@080c00040h,1
        MOVK    32,A8
        MOVE    A8,@080c00040h,1
        MOVK    19,A8
        MOVE    A8,@080c00000h,1
        MOVK    7,A8
        MOVE    A8,@080c00000h,1
        MOVI    102,A8
        MOVE    A8,@080c00020h,1
        MOVK    16,A8
        MOVE    A8,@080c00040h,1
        MOVE    @080c00000h,A9,1
        ANDI    255,A9
        CMPK    19,A9
        JRZ     _uartgood
        MOVK    1,A0
        FRET	b5
_uartgood:

_uart_local_loopback_test:
        MOVK    26,A8
	MOVE    A8,@080c00040h,1
        MOVI    48,A8
	MOVE    A8,@080c00040h,1
        MOVK    32,A8
        MOVE    A8,@080c00040h,1
        MOVK    19,A8
        MOVE    A8,@080c00000h,1
        MOVI    135,A8
        MOVE    A8,@080c00000h,1
        MOVI    102,A8
        MOVE    A8,@080c00020h,1
        MOVK    16,A8
        MOVE    A8,@080c00040h,1
        MOVI    80,A8
        MOVE    A8,@080c00040h,1
        MOVK    32,A8
        MOVE    A8,@080c00040h,1
        MOVI    69,A8
        MOVE    A8,@080c00040h,1
        CLRS    A9
_uart_llb1:
	move	a8,@060c000c0h,1
        MOVE    A9,@080c00060h,1
        MOVI    10000,A11
        SETF    16,0
        MOVE    @080c00020h,A8
        BTST    0,A8
        JRNZ    _uart_llb4
_uart_llb2:
	move	a8,@060c000c0h,1
        DSJ     A11,_uart_llb3
        MOVK    1,A0
        FRET	B5
_uart_llb3:
        SETF    16,0
        MOVE    @080c00020h,A8
        BTST    0,A8
        JRZ     _uart_llb2
_uart_llb4:
	move	a8,@060c000c0h,1
        MOVE    @080c00060h,A10,1
        ANDI    255,A10
        CMP     A9,A10
        JRZ     _uart_llb5
        MOVK    1,A0
        FRET	B5
_uart_llb5:
        ADDK    1,A9
        CMPI    256,A9
        JRLO    _uart_llb1
        CLRS    A0
	FRET	B5

**************************************************************************
*								         *
* 	POWERTST							 *
* 									 *
* 	POWERUP SELF TEST ROUTINES					 *
* 									 *
* 	ENTRY								 *
* 		NOTHING							 *
* 									 *
* 	EXIT								 *
* 		NOTHING							 *
*								         *
**************************************************************************

POWERTST
        DINT
        SETF	16, 0, 0
        SETF	32, 0, 1

	MOVB	B14,@WDOG_BONE		;THROW A BONE

;	HALT DMA AND ENABLE CACHE

        CLR	A14
        MOVE	A14,@DMAGOREG,L
        MOVE	A14,@DMAGOREG,L
        MOVE	A14,@CONTROL
	MOVE	A14,@DMACMAPCON,1

;	DISABLE VIDEO PALETTE RAMS, AUTOERASE AND ERROR LED

	MOVI	SYSC_COLD,A13
	MOVE	A13,@SYSCTRL0,L		; XUNIT
	srl	8,a13			; XUNIT
	MOVE	A13,@SYSCTRL1,L		; XUNIT
	MOVI	STCKST,SP,L

;	INITIALIZE IO REGISTERS

	MOVI	INITDATA,B0
	MOVI	VESYNC,B2
	MOVI	IDATALEN,B7
	BLMOVE	1,1			;TRANSFER I/O REGS

	movi	DPYSTRT0,a14	; XUNIT
	move	a14,@DPYST,L	; XUNIT

	JRUC	POWERCPUTEST

PONTEST
	MOVI	SYSCINIT&(~WRPROTHI),A0
	MOVE	A0,@SYSCOPY,W
	MOVE	A0,@SYSCTRL0,L		; XUNIT
	srl	8,a0			; XUNIT
	MOVE	A0,@SYSCTRL1,L		; XUNIT
	JAUC	POWERRET

DOG_COUNT	.EQU	8000H	;EVERY 32K
**************************************************************************
*								         *
* 	RAMCHECK							 *
* 									 *
* 	CHECK A BANK OF RAM, GIVEN A STARTING TABLE ADDRESS		 *
* 									 *
* 	ENTRY								 *
* 		A14	POINTER TO RAM TABLE				 *
* 		B5	RETURN ADDRESS					 *
* 									 *
* 	EXIT								 *
* 		B0	LIST OF ERRORS					 *
*								         *
**************************************************************************

	.ALIGN			;LET'S CACHE THIS BITCH

RAMCHECK:
	MOVB	B14,@WDOG_BONE		;THROW A BONE
        SETF 16, 0, 0
        SETF 32, 0, 1

;	SNAG NEXT CHIP RECORD

RAMLOOP:
	CLR	B2
	MOVE	*A14(RAM_SADR),A12,L	; STARTING ADDRESS
	MOVE	*A14(RAM_EADR),A13,L	; ENDING ADDRESS
	MOVE	*A14(RAM_ITLV),A11,W	; INTERLEAVE
	MOVE	*A14(RAM_WDTH),A10,W	; WIDTH

;	CELL COUNT

        SUB  A12, A13                   ; (END-START)/INTERLEAVE+1
        DIVU A11, A13
        INC  A13

;	SET FIELD SIZES

        MOVE A11, A9                    ; FS1 = INTERLEAVE
        ANDI ZERO_EXTEND, A9
        EXGF A9, 1

        MOVE A10, A9                    ; FS0 = WIDTH
        ANDI ZERO_EXTEND, A9
        EXGF A9, 0

;	FILL IN ASCENDING ORDER

        MOVE A13, A9                    ; XEROX COUNT
        MOVE A12, A8                    ; XEROX START

        MOVI RANDOM_SEED, A7, L
        CLR	A5
	MOVI	DOG_COUNT,B14

RAC1:
	SLA	1,A7			; GENERATE A PSEUDO
	JRV	RAC2			; RANDOM NUMBER
	ORI	2,A7
RAC2:
	MOVE	A7,A6
	ADDC	A5,A6

	MOVE	A6,*A8+,1		; WRITE
	DSJS	B14,RAC1_NODOG
	MOVB	B14,@WDOG_BONE		;THROW A BONE
	MOVI	DOG_COUNT,B14		;AND RELOAD COUNT
RAC1_NODOG
	DSJS	A9,RAC1

;	READBACK IN ASCENDING ORDER

        MOVE A13, A9                    ; XEROX COUNT
        MOVE A12, A8                    ; XEROX START

        MOVI RANDOM_SEED, A7, L
	MOVI	DOG_COUNT,B14

RAC3:   SLA  1, A7                      ; GENERATE A PSEUDO
        JRV  RAC4                       ; RANDOM NUMBER
        ORI  2, A7
RAC4:   MOVE A7, A6
        ADDC A5, A6

        MOVE *A8+, A4, 1                ; READ

        ZEXT  A6
        ZEXT  A4

        CMP A6, A4
        JRZ RAC5
;
;	GOT AN ERROR HERE
;
	SETF	16,0,0			; RESET FIELDS
	SETF	32,0,1
	MOVE	*A14(RAM_NMBR),A4,W	; GET BIT NUMBER TO SET
	MOVE	A4,B1
	MOVK	1,B2
	SLL	B1,B2
	OR	B2,B0			; SET THAT BIT
	JRUC	RAC6			; BREAK !!
RAC5
	DSJS	B14,RAC5_NODOG
	MOVB	B14,@WDOG_BONE		;THROW A BONE
	MOVI	DOG_COUNT,B14		;AND RELOAD COUNT
RAC5_NODOG
	DSJS	A9,RAC3

RAC6
	MOVB	B14,@WDOG_BONE		;THROW A BONE FOR GOOD MEASURE
	SETF	16,0,0			; RESET FIELDS
	SETF	32,0,1
;
;	B1 SHOULD BE ZERO IF THE CHIP IS COOL HERE
;
	MOVE	*A14(RAM_LINK),A10,L
	JRZ	RAMNOPLOT
	MOVK	1,A11
	MOVE	B2,B2
	JRZ	RAMPLOT
	MOVK	2,A11
RAMPLOT
	MOVE	B5,A9			; I HOPE THIS ONE IS SAFE!
	MOVE	B0,A13
	FCALL	CHIPOUT,B5
	MOVE	A13,B0
	MOVE	A9,B5

RAMNOPLOT
	ADDI	RAM_SIZE,A14		; ADVANCE TO NEXT GUY
	MOVE	*A14,A7,W
	JRNZ	RAMLOOP			; HERE WE GO AGAIN
	FRET	B5

**************************************************************************
*								         *
* 		   START OF DIAG CACHE SEGMENT				 *
*								         *
**************************************************************************

	.ALIGN			;LET'S CACHE THIS BITCH

	.IF	0
**************************************************************************
*								         *
* ROMCHECK - ROUTINE TO CHECKSUM THE PROGRAM AND IMAGE ROMS.		 *
* RETURNS								 *
* 	B0  = BITS SET FOR BAD ROMS.					 *
* 	 Z = TEST FINISHED.						 *
* 	NZ = TEST ABORTED BY USER.					 *
*								         *
**************************************************************************
ROMCHECK:
	MOVB	B14,@WDOG_BONE		;THROW A BONE
ROMLOOP	
	CLR	B2
	MOVE	*A14(ROM_CKSM),A13,L	; CHECK TO SEE IF ROM SOCKET THERE
	JRZ	ROMEMPTY
	CLR	A8			; CHECKSUM

	MOVI	DOG_COUNT,B14

	MOVE	*A14(ROM_SADR),A12,L	; STARTING ADDRESS
	MOVE	*A14(ROM_EADR),A13,L	; ENDING ADDRESS
	MOVE	*A14(ROM_ITLV),A11,W	; INTERLEAVE
;
;	SUM UP A GIVEN IMAGE ROM -- THE TUNIT WAY
;
	SUB	A12,A13			; (( EADDR - SADDR ) / INTERLEAVE) + 1
	DIVU	A11,A13
	INC	A13
RCILP
	MOVB	*A12,A7
	SLL	24,A7
	SRL	24,A7
	ADD	A11,A12
	ADD	A7,A8
	DSJS	B14,RCILP_NODOG
	MOVB	B14,@WDOG_BONE		;THROW A BONE
	MOVI	DOG_COUNT,B14		;AND RELOAD COUNT
RCILP_NODOG
	DSJS	A13,RCILP

	MOVE	*A14(ROM_WDTH),A10,W	; WIDTH
	JRNZ	ROMCKCK			;ACTUALLY A FLAG FOR IMAGE OR PROG

	MOVE	*A14(ROM_NMBR),A4,W	;WHICH PROGRAM ROM ARE WE CHECKING?
	cmpk	3,a4
	jrlt	PROGRAM_2
	move	@CHECKSUM3,A7,W
	jruc	ROM_COMPARE
PROGRAM_2
	cmpk	2,a4
	jrlt	PROGRAM_1
	move	@CHECKSUM2,A7,W
	jruc	ROM_COMPARE
PROGRAM_1
	cmpk	1,a4
	jrlt	PROGRAM_0
	move	@CHECKSUM1,A7,W
	jruc	ROM_COMPARE
PROGRAM_0
	MOVE	@CHECKSUM0,A7,W		;LOAD HARD CODED CHECKSUM

*LAND HERE FROM IMAGE CHECKSUM TO DETERMINE IF WE HIT IT
ROMCKCK
	MOVE	*A14(ROM_CKSM),A7,W
ROM_COMPARE
	ZEXT	A7
	ZEXT	A8
	CMP	A7,A8
	JRZ	ROMRELOOP
	MOVE	*A14(ROM_NMBR),A4,W	; GET BIT NUMBER TO SET
	MOVE	A4,B1
	MOVK	1,B2
	SLL	B1,B2
	OR	B2,B0			; SET THAT BIT
ROMRELOOP
	MOVB	B14,@WDOG_BONE		;THROW A BONE
	MOVE	*A14(ROM_LINK),A10,L
	JRZ	ROMNOPLOT
	MOVK	1,A11
	MOVE	B2,B2
	JRZ	ROMPLOT
	MOVK	2,A11
ROMPLOT
	MOVE	B5,A9			; I HOPE THIS ONE IS SAFE!
	MOVE	B0,A13
	FCALL	CHIPOUT,B5
	MOVE	A13,B0
	MOVE	A9,B5

ROMNOPLOT
	ADDI	ROM_SIZE,A14
*CHECKING FOR EARLY EXIT BY OPERATOR
	MOVE	@COINS,A13,W		; XUNIT
	MOVE	A13,A8
	ANDI	00000004H,A13		;CHECK PLAYER 1 START
	JRZ	ROMABORT		;BR = IT'S PRESSED
	ANDI	00000020H,A8		;CHECK PLAYER 2 START
	JRZ	ROMABORT		;BR = IT'S PRESSED
	JRUC	ROMLOOP			;BACK FOR THE NEXT
*HERE ON OPERATOR ABORT
ROMABORT
	CLRZ
ROMEMPTY
	FRET	B5

	.ENDIF

******************************************************************************
*                                                                            *
* _ROM_SUMS                                                                  *
*                                                                            *
* Calculates and checks the checksums of a bank of 4 Image or Program ROMS.  *
* The function calculates 16 bit checksums for each of 4 Images or Program   *
* ROMS and checks the calculated checksums against those stored in the code. *
*                                                                            *
* ENTRY                                                                      *
*       A0 - Pointer to ROMBANK Structure                                    *
*                                                                            *
* EXIT                                                                       *
*       A  - Result Flags                                                    *
*            Bit    Value     Meaning                                        *
*             0       0       ROM with data bits 0  - 7  OK                  *
*                     1       ROM with data bits 0  - 7  FAILED              *
*             1       0       ROM with data bits 8  - 15 OK                  *
*                     1       ROM with data bits 8  - 15 FAILED              *
*             2       0       ROM with data bits 16 - 23 OK                  *
*                     1       ROM with data bits 16 - 23 FAILED              *
*             3       0       ROM with data bits 24 - 31 OK                  *
*                     1       ROM with data bits 24 - 31 FAILED              *
*                                                                            *
* USES                                                                       *
*       A1, A2, A4, A3, A5, A6, A7, A8, A9, A10, A11, A12, A13, B5           *
*                                                                            *
******************************************************************************
_rom_sums:
	clr	a13			; Set flag to say test PASSED
_rom_loop:
	movk	4,a4
_rom_spec_loop:
	movk	4,a11
	move	*a0+,a10,1
	move	sp,a12
	movi	020001000h,sp
	mmtm	sp,a0,a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13
	move	b5,a12
	FCALL	CHIPOUT,b5
	move	a12,b5
	mmfm	sp,a0,a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13
	move	a12,sp
	dsjs	a4,_rom_spec_loop
	subi	128,a0

	move	a0,@WDOG_BONE,1
	setf	16,0
	move	*a0(128),a8,1		; Get start address of bank
	move	*a0(160),a9,1		; End address of bank
	sub	a8,a9			; Calc bank length (long words)
	srl	5,a9
	movi	CKSUM_WORK,a1
	clr	a2
	move	a2,*a1,0		; zero out current value
	move	a2,*a1(16),0		; zero out current value
	move	a2,*a1(32),0		; zero out current value
	move	a2,*a1(48),0		; zero out current value
_calc_sums:				; For each ROM calculate checksum
	btst	18,a8
	jrz	_calc_nodoggy
	move	a8,a4
	srl	7,a4
	andi	7fffh,a4
_wait_blank:
	move	@0c0000030h,a2
_wb_loop:
	move	@0c00001d0h,a10
	cmp	a2,a10
	jrgt	_wb_loop
	move	a4,@0A08000C0h,1
	move	a0,@WDOG_BONE,1
_calc_nodoggy:
	move	@COINS,a11,1
	not	a11
	andi	0664h,a11
	jrnz	_rom_sum_abort
	move	*a8+,a5,1		; read data from rom
	movk	4,a2
_calc_sum:				; Add values for each ROM
	move	a5,a6			; value read -> a6
	andi	0ffh,a6			; mask off bits not interested in
	move	*a1,a7,0		; read current value
	add	a6,a7			; add read value to current value
	move	a7,*a1+,0		; store back in save area
	srl	8,a5			; get next rom vale
	dsjs	a2,_calc_sum		; do until 4 bytes are done
	subi	64,a1			; set pointer back to start of save area
	dsj	a9,_calc_sums		; do until all data read from roms

	move	@_rom_type,a3
	jrz	_image_roms
	movi	CHECKSUM0,a3
	jruc	_cksum_ptr_set
_image_roms:
	move	a0,a3			; generate pointer to checksums
	addi	192,a3
_cksum_ptr_set:

	movk	4,a4
_check_sums:				; check stored checksums against calculated checksums
	move	a0,@WDOG_BONE,1
	movk	1,a11			; set flag to say rom is OK
	move	*a0+,a10,1		; set pointer to table for this rom
	move	*a1+,a8,0		; get calculated checksum for this rom
	move	*a3+,a9,0		; get stored checksum for this rom
	cmp	a8,a9			; are they the same ?
	jrz	_cksum_ok		; YES - FARM OUT!!!
	movk	2,a11			; NOPE - BUMMER DUDE - Tell CHIPOUT
	ori	080000000h,a13		; set bit for caller bit 0 = LSB, 3 = MSB
_cksum_ok:
	srl	1,a13
	move	sp,a12
	movi	020001000h,sp
	mmtm	sp,a0,a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13
	move	b5,a12
	FCALL	CHIPOUT,b5		; Draw the friggin' thing
	move	a12,b5
	mmfm	sp,a0,a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13
	move	a12,sp
	dsjs	a4,_check_sums		; Do until all 4 roms checked
	addi	192,a0
	move	*a0,a1,1
	jrnz	_rom_loop
_rom_sums_done:
	move	a13,a13
	jrz	_rsd_1
	movk	1,b0
_rsd_1:
	move	a13,a13
	FRET	b5
_rom_sum_abort:
	movk	1,a13
	clr	b0
	jruc	_rsd_1

	.IF	PRINTER
	.ELSE

**************************************************************************
*								         *
* 	MONITOR STUFF							 *
*								         *
**************************************************************************

CONV_PLOT:
	MOVI	MON_RECS,A9
CPRLP1
	MOVE	*A9+,A2,W		; GET COLOR
	JRZ	CPRDONE
	MOVE	*A9+,A0,L		; START POINT
	MOVE	*A9+,A1,L		; DIMENSIONS
	FCALL	RECTANGLE,B6
	JRUC	CPRLP1
CPRDONE
	MOVI	MON_VECS,A9		; POINT AT VECTOR TABLE
CPVLP1
	MOVE	*A9+,A2,W		; GET COLOR
	JRZ	CPVDONE
	MOVE	*A9+,A0,L		; START POINT
	MOVE	*A9+,A1,L		; END POINT
	FCALL	HVLINE,B6
	JRUC	CPVLP1
CPVDONE
	MOVI	MON_DOTS,A9		; POINT AT DOT TABLE
CPDLP1
	MOVE	*A9+,A1,W		; GET COLOR
	JRZ	CPDDONE
	MOVE	*A9+,A0,L		; GET THE POINT
	FCALL	POINT,B6
	JRUC	CPDLP1
CPDDONE
	RETS


**************************************************************************
*								         *
* 	COLORBAR							 *
*								         *
**************************************************************************
COLORBAR:
;       =========================
;       | SET PALETTE 0 FOR     |
;       | COLOR BARS.           |
;       =========================

	MOVI	INTENSITIES_START,A0,L
	MOVI	COLRAM+(5*PALSIZE),A1,L	;START UP A LITTLE BIT

	MOVK	16,A2		;5 BITS/COLOR
        MOVK  	1,A6		;1 PALETTE(S) TO COVER 8 BARS
CB2
	MOVK	8,A7		;8 BARS/PALETTE
CB3
	MOVE	*A0+,A3		;STARTING COLOR
	MOVE	*A0+,A4		;COLOR DECREMENT
	MOVE	A2,A5
CB4
	MOVE	A3,*A1+,L	; XUNIT
	SUB	A4,A3
	DSJS	A5,CB4
	DSJS	A7,CB3

	ADDI	16*PALSIZE/NUMPAL,A1
        DSJS 	A6,CB2

;       =========================
;       | DISPLAY COLOR BARS    |
;       =========================

	CLR	A14
	MOVE	A14,@DMAGOREG,L		;HALT THE DMA
	MOVI	[0,0101H],A14		;PALETTE INCREMENT
	MOVI	[0,0505H],A8		;START AT THIS PALETTE

	MOVI	COLOR_BARS,A3,L		;COLOR BAR TABLE
	MOVI	[16,0],A13,L		;POSITION INCRMENT
	MOVI	01010101H,A12		; XUNIT
	MOVK	16,A11			;# INTENSITIES / BAR
	MOVK	1,A6			;THIS MANY GROUPS OF 8 BARS
	CLR	A2			;STARTING COLOR
CB5
	MOVK	8,A7			;THIS MANY BARS PER PALETTE
CB6
	MOVE	*A3+,A1,L
	JRZ	CB8
	MOVE	A8,@DMACMAPCON,L		;STUFF PALETTE
	MOVE	*A3+,A0,L
	ADDK	16,A3
	MOVE	A11,A10
CB7
	FCALL	RECTANGLE,B6
	ADD	A13,A0
	ADD	A12,A2
	DSJS	A10,CB7
	DSJ	A7,CB6			;NEXT BAR PLEASE
	ADD	A14,A8			;NEXT BAR & PALETTE PLEASE
	DSJ	A6,CB5
CB8
	CLR	A14
	MOVE	A14,@DMACMAPCON,L
	RETS


INTENSITIES_START:

        .WORD 03E0H                ; GREEN
        .WORD 0040H                ; BUMP GREEN

        .WORD 7C00H                ; RED
        .WORD 0800H                ; BUMP RED

        .WORD 001FH                ; BLUE
        .WORD 0002H                ; BUMP BLUE

        .WORD 0000H                ; BLACK
        .WORD 0000H                ; BUMP BLACK

        .WORD 7FFFH                ; WHITE
        .WORD 0842H                ; BUMP WHITE

        .WORD 7FE0H                ; YELLOW
        .WORD 0840H                ; BUMP YELLOW

        .WORD 7C1FH                ; PURPLE
        .WORD 0802H                ; BUMP PURPLE

        .WORD 03FFH                ; CYAN
        .WORD 0042H                ; BUMP CYAN

	.LONG	0


**************************************************************************
*								         *
* 	DIPTEST								 *
* 									 *
* 	DIP SWITCH TESTING						 *
*								         *
**************************************************************************

DIPTEST:
	MOVKM	1,@DIAG_DFLAG,W
	MOVKM	1,@DIP1ST,W		;YES THIS IS THE FIRST TIME THROUGH
DT_PLOT
	CALLA	DIAG_SRT_CLR
	MOVI	DIP_BOXES,A9
DTVLP1
	MOVE	*A9+,A1,L
	JRZ	DSWDONE
	MOVE	*A9+,A0,L
	MOVE	*A9+,A2,W
	FCALL	RECTANGLE,B6
	JRUC	DTVLP1
DSWDONE
	MOVI	DIP_VECS,A9
DLINES
	MOVE	*A9+,A2,W
	JRZ	DTVDONE
	MOVE	*A9+,A0,L
	MOVE	*A9+,A1,L
	FCALL	HVLINE,B6
	JRUC	DLINES
DTVDONE
	MOVI	DIP_STRS,A9
	CALLR	STR_PLOT
	CALLR	DIPPLOT
	CALLR	DIPSTATE

	MOVE	@DIP1ST,A14,W
	JRNZ	DTL_SKIP_SND


	calla	read_dip
	btst	15,a0
	jrnz	DTL_SKIP_SND

	MOVI	DIP_SND,A0
	calla	ONESND

DTL_SKIP_SND
	CLRM	@DIP1ST,W
_up_wait:
	PAUSE	10000,B6
	FCALL	FREAD_SW1_CNS,B6		; XUNIT
	FCALL	FREAD_SW2_DIP,B6
	ori	0ffff0000h,a10
	and	a10,a0
	ANDI	00401010H,A0
	cmpi	00401010h,a0
	jrnz	_up_wait
	MOVE	A0,@SWSET1,L
DTLOOP
	PAUSE	100000,b6
	CALLA	CKTEST			; EMERGENCY EXIT
	FCALL	FREAD_SW1_CNS,B6		; XUNIT GOTTA SEE IF TIME TO LEAVE
	FCALL	FREAD_SW2_DIP,B6
	ori	0ffff0000h,a10
	and	a10,a0
	MOVE	@SWSET1,A1,L
	ANDI	00401010H,A0
	CMP	A0,A1
	JRNZ	DT_X

	CALLR	read_dip
	MOVE	@DIPVAL,A1,W
	ANDI	0FFFFH,A1		;FUCKING SIGN EXTEND
	CMP	A0,A1
	JRZ	DTLOOP			;BR = NO CHANGE
	MOVE	A0,@DIPVAL,W		;SAVE THE OLD
	JRUC	DT_PLOT			;PLOT THE NEW SWITCH STUFF
DT_X
_up_wait1:
	PAUSE	100000,B6
	FCALL	FREAD_SW1_CNS,b6
	FCALL	FREAD_SW2_DIP,b6
	ori	0ffff0000h,a10
	and	a10,a0
	andi	00401010H,a0
	cmpi	00401010h,a0
	jrnz	_up_wait1
	pause	100000,b6
	CLRM	@DIAG_DFLAG,W

	RETS

**************************************************************************
*								         *
* 	DIPSTATE							 *
* 									 *
* 	PLOT OUT THE STATES OF ALL THE DIP SWITCHES			 *
* 									 *
* 	ENTRY								 *
* 		NOTHING							 *
* 									 *
* 	EXIT								 *
* 		NOTHING							 *
*								         *
**************************************************************************
DIPSTATE
	CALLR	read_dip
	MOVE	A0,A10			;LET'S KEEP A COPY 

	CLR	A2
	MOVI	COLOR_WHITE,A3

	MOVI	DMIRROR_0,A1
	ANDI	DPMIRROR,A0		;MIRROR?
	JRZ	SD1
	MOVI	DMIRROR_1,A1
SD1
	MOVE	A1,A0
	MOVI	[82,75],A1
	FCALL	STRING,B6

	MOVI	DUSECMOS_0,A1
	MOVE	A10,A0
	ANDI	DPUSECMOS,A0
	JRZ	DS1
	MOVI	DUSECMOS_1,A1
DS1
	MOVE	A1,A0
	MOVI	[94,75],A1
	FCALL	STRING,B6

*PLOT CURRENT COINAGE
	MOVI	COLOR_WHITE,A3
	MOVI	[112,75],A1
	MOVI	DCOINAGE,A0
	FCALL	STRING,B6
	MOVE	A10,A0
	ANDI	DPCOUNTRY,A0
	SRL	SR_DPCOUNTRY,A0
	SLL	5,A0
DCC_CZ
	ADDI	DCOINTAB,A0
	MOVE	*A0,A1,L		; POINTER TO RIGHT COIN TABLE
	MOVE	A10,A0
	ANDI	DPCOINAGE,A0
	SRL	SR_DPCOINAGE,A0
	SLL	5,A0
	ADD	A0,A1
	MOVE	*A1,A0,L		; NOW POINTING AT MESSAGE
	CLR	A2
	MOVI	[124,75],A1
	FCALL	STRING,B6

*PLOT CREDITS TO START, CREDITS TO CONTINUE
	MOVI	DCREDITS,A0
	MOVI	[144,75],A1
	FCALL	STRING,B6

	MOVI	DTOSTART,A0
	MOVI	[155,88],A1
	FCALL	STRING,B6

	MOVI	DTOCONTINUE,A0
	MOVI	[166,88],A1
	FCALL	STRING,B6

	MOVE	A10,A7
	ANDI	DPCREDITS,A7
	SRL	SR_DPCREDITS,A7
	SLL	6,A7
	ADDI	DCREDTAB,A7
	MOVE	*A7+,A0,L
	MOVI	[155,75],A1
	FCALL	STRING,B6
	MOVE	*A7+,A0,L
	MOVI	[166,75],A1
	FCALL	STRING,B6

*PLOT COUNTRY SELECTION
	MOVE	A10,A0
	ANDI	DPCOUNTRY,A0
	SRL	SR_DPCOUNTRY,A0
	SLL	5,A0
	ADDI	DCOUNTRY_TAB,A0
	MOVE	*A0,A0,L
	MOVI	[88,285],A1
	FCALL	STRING,B6
;	MOVI	DUNUSED,A0
;	MOVI	[106,285],A1
;	FCALL	STRING,B6
	move	a10,a0
	andi	0400h,a0
	srl	5,a0
	addi	DPUTAB,a0
	move	*a0,a0,L
	movi	[106,285],a1
	FCALL	STRING,b6
;


	MOVI	DCOUNTER_0,A1
	MOVE	A10,A0
	ANDI	DPCOUNTER,A0		; COUNTER
	JRZ	SD2
	MOVI	DCOUNTER_1,A1
SD2
	MOVE	A1,A0
	MOVI	[118,285],A1
	FCALL	STRING,B6

	MOVE	A10,A0
	ANDI	DPPLAYERS,A0
	SRL	SR_DPPLAYERS,A0
	andi	1,a0
	SLL	5,A0
	ADDI	DPLAYER_TAB,A0
	MOVE	*A0,A0,L
;	MOVI	[136,285],A1
	MOVI	[129,285],A1
	FCALL	STRING,B6

	move	a10,a0
	andi	02000h,a0
	srl	8,a0
	addi	DUPGRADE_TAB,a0
	move	*a0,a0,L
	movi	[141,285],a1
	FCALL	STRING,b6

	MOVI	DFREEZE_0,A0
	MOVI	[154,285],A1
	FCALL	STRING,B6

	MOVI	DTEST_0,A0
	MOVI	[166,285],A1
	FCALL	STRING,B6

	RETS				

	.ENDIF

**************************************************************************
*								         *
* 	CHECKDIPFREE							 *
* 									 *
* 	CHECK TO SEE IF EITHER OF THE COIN SLOTS IS ON FREE PLAY,	 *
* 	AND IF SO RETURN Z, OTHERWISE DON'T				 *
* 									 *
* 	ENTRY								 *
* 		NOTHING							 *
* 									 *
* 	EXIT								 *
* 		.EQ.	YES, FREEPLAY					 *
*								         *
**************************************************************************

CHECKDIPFREE:
	PUSH	A0
	CALLR	read_dip
	ANDI	DPCOINAGE,A0
	CMPI	DPCOINAGE,A0
CDFRET
	PULL	A0
	RETS

	.IF	PRINTER
	.ELSE

**************************************************************************
*								         *
* 	DIPPLOT								 *
* 									 *
* 	PLOT OUT THE DIP SWITCHES					 *
* 									 *
* 	ENTRY								 *
* 		NOTHING							 *
* 									 *
* 	EXIT								 *
* 		NOTHING							 *
*								         *
**************************************************************************

DIPPLOT:
	CALLR	read_dip
	CLR	A2
DIPLOOP
	MOVE	A2,A3
	SLL	5,A3
	ADDI	DIPYTAB,A3
	MOVE	*A3,A3,L
	SLL	16,A3			; GOT THE Y LOC

	CLR	A5
	CMPI	8,A2			;Is this switch in the Second bank?
	JRLO	DIPL2			;BR = No
	MOVI	210,A5			;Second bank, change X plot position
DIPL2
	MOVX	A5,A3

	BTST	A2,A0			; CHECK IF BIT IS SET
	JRNZ	DIPON
	MOVI	DP_OFF,A1
	ADDI	29,A3
	MOVI	COLOR_GREY,A4
	JRUC	DIPSTR

DIPON
	MOVI	DP_ON,A1
	ADDI	32,A3
	MOVI	COLOR_WHITE,A4

DIPSTR
	MMTM	SP,A0,A2
	SETF	16,0
	MOVE	@0C0000190H,A0
	ORI	020H,A0
	MOVE	A0,@0C0000190H
	MOVE	A1,A0			; SET STRING
	MOVE	A3,A1			; SET LOCATION
	MOVE	A4,A3
	CLR	A2			; HORIZONTAL
	FCALL	STRING,B6
	SETF	16,0
	MOVE	@0C0000190H,A0
	ANDNI	020H,A0
	MOVE	A0,@0C0000190H
	MMFM	SP,A0,A2
	INC	A2
	CMPI	16,A2
	JRLO	DIPLOOP
	RETS


DIPYTAB
;	.LONG	39,51,63,75,87,99,111,123
;	.LONG	39,51,63,75,87,99,111,123
	.LONG	82,94,106,118,130,142,154,166
	.LONG	82,94,106,118,130,142,154,166

	.ENDIF

**************************************************************************
*								         *
* 	READ_DIP							 *
* 									 *
* 	READ IN BOTH DIP SWITCHES					 *
* 									 *
* 	ENTRY								 *
* 		NOTHING							 *
* 									 *
* 	EXIT								 *
* 		A0	DIP SWITCH					 *
*								         *
**************************************************************************
	.text
	.globl	READ_DIP

READ_DIP:
	MOVE	@DIPSWITCH,A0,W		; READ IT IN
	NOT	A0			; INVERT IT FOR TRUE BITS
	RETS


	.sect	"COLDSTRT"
	.globl	read_dip
read_dip:
	move	@DIPSWITCH,a0,W
	not	a0
	rets

**************************************************************************
*								         *
* 	SWITCHTEST							 *
* 									 *
* 	DRAW OUT THE REVOLUTION X SWITCHES - A PRETTY PICTURE            *
* 									 *
* 	ENTRY								 *
* 		NOTHING							 *
* 									 *
* 	EXIT								 *
* 		NOTHING							 *
*								         *
**************************************************************************

	.IF	PRINTER
	.ELSE
SWITCHTEST:
	MOVKM	1,@DIAG_DFLAG,W
	CLR	A12			; THE HOLD ME REGISTER
	MOVE	A12,@SWSET1,L
	MOVE	A12,@SWSET2,L
	MOVE	A12,@SWPREV1,L
	MOVE	A12,@SWPREV2,L
	callr	read_dip
	andi	01000h,a0
	jrz	swtest_3play
	movi	BUT_TABLE1,a9
	jruc	swtest
swtest_3play:
	MOVI	BUT_TABLE,A9
swtest:
	CLR	A10
	CALLR	BUT_PLOT		; PLOT SOME BUTTONS
	callr	read_dip
	andi	01000h,a0
	jrz	swtest_3play1
	movi	STR_TABLE1,a9
	jruc	swtest1
swtest_3play1:
	MOVI	STR_TABLE,A9
swtest1:
	CALLR	STR_PLOT		; PLOT THE STRINGS
	MOVI	00AA0005H,A0
	MOVI	00AA018BH,A1
	MOVI	COLOR_WHITE,A2
	FCALL	HVLINE,B6		; DRAW LITTLE WHITE LINE
SDLOOP
	FCALL	FREAD_SW1_CNS,B6	; XUNIT GRAB ME A SWITCH REGISTER
	NOT	A0
	MOVE	A0,A10
;	ANDI	DONEMASK,A0
;	CMPI	DONEMASK,A0,L		; CHECK FOR DONE
	move	@_cabinet_type,a11,1
	jrnz	sd_t2
	XORI	DONEMASK,a0
	JRNZ	SDGO
	jruc	SDDONE
sd_t2:
	andi	DONEMASK_T2,a0
	cmpi	DONEMASK_T2,a0
	jrnz	SDGO
SDDONE:
	CLRM	@DIAG_DFLAG,W
	RETS
SDGO
	andi	00040010h,a0
	cmpi	00040010h,a0
	jrz	SDDONE
	MOVE	@SWSET1,A11,L
	CMP	A11,A10			; CHECK FOR CHANGES
	JRZ	SDCK2
	MOVE	A10,@SWSET1,L
	FCALL	FREAD_SW2_DIP,B6	; XUNIT 
	NOT	A10
	ANDI	0FFH,A10
	MOVE	A10,@SWSET2,L
	JRUC	SDPROC
SDCK2
	FCALL	FREAD_SW2_DIP,B6	; XUNIT 
	NOT	A10
	ANDI	0FFH,A10
	MOVE	@SWSET2,A11,L
	CMP	A11,A10
	JRZ	SDLOOP
	MOVE	A10,@SWSET2,L
SDPROC
	callr	read_dip
	andi	01000h,a0
	jrz	swtest_3play2
	movi	BUT_TABLE1,a9
	jruc	swtest2
swtest_3play2:
	MOVI	BUT_TABLE,A9
swtest2:
	CALLR	BUT_PLOT
	MOVE	@SWPREV1,A1,L
	NOT	A1
	MOVE	@SWSET1,A2,L
	NOT	A2
	OR	A2,A1
	CMP	A1,A2
	JRNZ	SDSOUND
	MOVE	@SWPREV2,A1,L
	NOT	A1
	MOVE	@SWSET2,A2,L
	NOT	A2
	OR	A2,A1
	CMP	A1,A2
	JRZ	SDNOSOUND
SDSOUND
	MOVI	SWITCH_SND,A0
	calla	ONESND
SDNOSOUND
	MOVE	@SWSET1,@SWPREV1,L
	MOVE	@SWSET2,@SWPREV2,L
	JRUC	SDLOOP

**************************************************************************
*								         *
* 	BUT_PLOT							 *
* 									 *
* 	PLOT A BUTTON TABLE ON THE SCREEN				 *
* 									 *
* 	ENTRY								 *
* 		A9	POINTS TO BUTTON TABLE LIST			 *
* 		A10	SETTINGS OF THE SWITCH REGISTER			 *
* 									 *
* 	EXIT								 *
* 		NOTHING							 *
*								         *
**************************************************************************
BUT_PLOT:
	MOVE	*A9+,A1,L		; XY LOC
	JRZ	BPDONE
	MOVE	*A9+,A0,W		; RADIUS
	MOVE	*A9+,A6,L		; COLOR
	MOVE	*A9+,A11,L		; GET MASK
	ADDK	16,A9			; SHIFT COUNT
	MOVE	*A9+,A8,W		; JAMMA EXTEND-O-BIT
	JRZ	BPLOW
	MOVE	@SWSET2,A10,L
	JRUC	BPAND
BPLOW
	MOVE	@SWSET1,A10,L
BPAND
	AND	A10,A11			; MASK OFF SOMETHING USEFUL
	JRZ	BPHOLLOW
	SUBK	2,A0
	ADDI	CFILL,A6		; MASK IN THE FILL BITS
	JRUC	BPCIRC
BPHOLLOW
	MMTM	SP,A0,A1,A6
	SUBK	2,A0
	MOVI	COLOR_BLACK,A6
	ADDI	CFILL,A6
	FCALL	CIRCLE,B6
	MMFM	SP,A0,A1,A6
BPCIRC
	FCALL	CIRCLE,B6
	JRUC	BUT_PLOT
BPDONE
	RETS

**************************************************************************
*								         *
* SWITCHSTR_PLOT - CHECK SWITCHES AND PLOT CORRESPONDING STRING.	 *
* A9 = POINTS TO SWITCH STRING TABLE LIST				 *
* A10 = SETTINGS OF THE SWITCH REGISTER					 *
*								         *
**************************************************************************
SWITCHSTR_PLOT:
	MOVE	*A9+,A1,L		;XY LOC
	JRZ	SSTR_DONE
	MOVE	*A9+,A0,L		;STRING PTR
	MOVE	*A9+,A3,W		;COLOR
	MOVE	*A9+,A2,W		;DIRECTION
	MOVE	*A9+,A11,L		;GET MASK
	MOVE	@SWSET1,A10,L
	AND	A10,A11			;CHECK JUST OUR SWITCH
	JRNZ	SSTR_PLOT
	MOVI	COLOR_BLACK,A3
SSTR_PLOT
	FCALL	STRING,B6
	JRUC	SWITCHSTR_PLOT
SSTR_DONE
	RETS

	.ENDIF

**************************************************************************
*								         *
* 	STR_PLOT							 *
* 									 *
* 	PLOT A STRING TABLE ON THE SCREEN				 *
* 									 *
* 	ENTRY								 *
* 		A9	POINTS TO STRING TABLE LIST			 *
*								         *
**************************************************************************

STR_PLOT:
	MOVE	*A9+,A1,L		; XY LOC
	JRZ	STDONE
	MOVE	*A9+,A0,L		; STRING PTR
	MOVE	*A9+,A3,W		; COLOR
	MOVE	*A9+,A2,W		; DIRECTION
	FCALL	STRING,B6
	JRUC	STR_PLOT
STDONE
	RETS

CFILL	EQU	0FFFF0000H

;
;	FORMAT
;
;	X,Y,RADIUS,COLOR,MASK,SHIFT COUNT ( FOR JOYSTICK STUFF ), EXTENDBIT
;

COLOR_P1	EQU	COLOR_RED
COLOR_P2	EQU	COLOR_YELLOW
COLOR_P3	EQU	COLOR_BLUE

**************************************************************************
*								         *
* 	Y-UNIT DEFS							 *
*								         *
**************************************************************************

	.IF	PRINTER
	.ELSE

BUT_TABLE:
	BUT_MAC	200,186,10,COLOR_GREEN,00080000H,0,0	; SLAM
	BUT_MAC	200,209,10,COLOR_GREEN,00100000H,0,0	; TEST
	BUT_MAC 30,186,10,COLOR_GREEN,00010000H,0,0	; COIN LEFT
	BUT_MAC	30,209,10,COLOR_GREEN,00020000H,0,0	; COIN RIGHT
	BUT_MAC	115,186,10,COLOR_GREEN,00800000H,0,0	; COIN CENTER
	BUT_MAC	115,209,10,COLOR_GREEN,01000000H,0,0	; XUNIT FOURTH COIN
	BUT_MAC	30,232,10,COLOR_GREEN,00400000H,0,0	; SERVICE CREDIT

; PLAYER BUTTONS AND OTHER BUTTONS
	BUT_MAC	70,60,15,COLOR_P1,00040000H,0,0    	;P1 START
	BUT_MAC	195,60,15,COLOR_P2,00200000H,0,0	;P2 START
	BUT_MAC	70, 130,10,COLOR_P1,00000010H,0,0	;P1 TRIGGER
	BUT_MAC	70, 95,10,COLOR_P1,00000020H,0,0    	;P1 BOMB
	BUT_MAC	195,130,10,COLOR_P2,00001000H,0,0	;P2 TRIGGER
	BUT_MAC	195,95,10,COLOR_P2,00002000H,0,0	;P2 BOMB
	BUT_MAC	285,186,10,COLOR_GREEN,10000000H,0,0	;Volume Up
	BUT_MAC 285,209,10,COLOR_GREEN,08000000H,0,0	;Volume Down
	BUT_MAC	130,232,10,COLOR_GREEN,20000000H,0,0	;COIN INTERLOCK
	BUT_MAC	230,232,10,COLOR_GREEN,80000000H,0,0	;Bill Validator
	BUT_MAC	320,60,15,COLOR_P3,02000000H,0,0    	;P3 START
	BUT_MAC	320,130,10,COLOR_P3,00000010H,0,1	;P3 TRIGGER
	BUT_MAC	320,95,10,COLOR_P3,00000020H,0,1    	;P3 BOMB
	.LONG	0


BUT_TABLE1:
	BUT_MAC	200,186,10,COLOR_GREEN,00080000H,0,0	; SLAM
	BUT_MAC	200,209,10,COLOR_GREEN,00100000H,0,0	; TEST
	BUT_MAC 30,186,10,COLOR_GREEN,00010000H,0,0	; COIN LEFT
	BUT_MAC	30,209,10,COLOR_GREEN,00020000H,0,0	; COIN RIGHT
	BUT_MAC	115,186,10,COLOR_GREEN,00800000H,0,0	; COIN CENTER
	BUT_MAC	115,209,10,COLOR_GREEN,01000000H,0,0	; XUNIT FOURTH COIN
	BUT_MAC	30,232,10,COLOR_GREEN,00400000H,0,0	; SERVICE CREDIT

; PLAYER BUTTONS AND OTHER BUTTONS
	BUT_MAC	35, 60,10,COLOR_P1,00040000H,0,0    	;P1 START
	BUT_MAC	105,60,10,COLOR_P1,00040000H,0,0    	;P1 START
	BUT_MAC	70, 130,10,COLOR_P1,00000010H,0,0	;P1 TRIGGER
	BUT_MAC	70, 95,10,COLOR_P1,00000020H,0,0    	;P1 BOMB
	BUT_MAC	285,186,10,COLOR_GREEN,10000000H,0,0	;Volume Up
	BUT_MAC 285,209,10,COLOR_GREEN,08000000H,0,0	;Volume Down
	BUT_MAC	130,232,10,COLOR_GREEN,20000000H,0,0	;COIN INTERLOCK
	BUT_MAC	230,232,10,COLOR_GREEN,80000000H,0,0	;Bill Validator
	BUT_MAC	285,60,10,COLOR_P3,00200000H,0,0    	;P2 START
	BUT_MAC	355,60,10,COLOR_P3,00200000H,0,0    	;P2 START
	BUT_MAC	320,130,10,COLOR_P3,00001000H,0,0	;P2 TRIGGER
	BUT_MAC	320,95,10,COLOR_P3,00002000H,0,0    	;P2 BOMB
	.LONG	0
DONEMASK_T2	EQU	00040010H			; P1 START + P1 TRIGGER
DONEMASK	EQU	00500000H			; TEST + ESCAPE


;SWITCHSTR_TAB
;	SW_MAC	10, 30,P1START,COLOR_P1,0,00040000H    	;P1 START
;	SW_MAC	240,30,P2START,COLOR_P2,0,00200000H	;P2 START
;	SW_MAC	10, 50,P1_TRIGGER,COLOR_P1,0,00000010H	;P1 TRIGGER
;	SW_MAC	10, 70,P1_BOMB,COLOR_P1,0,00000020H    	;P1 BOMB
;	SW_MAC	240,50,P2_TRIGGER,COLOR_P2,0,00001000H	;P2 TRIGGER
;	SW_MAC	240,70,P2_BOMB,COLOR_P2,0,00002000H	;P2 BOMB
;	.LONG	0

STR_TABLE:
	STR_MAC	88,5,SWITCH_TITLE,COLOR_WHITE,0		;TITLE
; Player switch titles
	STR_MAC 45,27,PLAY1_MESS,COLOR_RED,0
	STR_MAC	170,27,PLAY2_MESS,COLOR_YELLOW,0
	STR_MAC	295,27,PLAY3_MESS,COLOR_BLUE,0
	STR_MAC	212,182,SLAM,COLOR_GREEN,0			;SLAM
	STR_MAC	212,205,TEST,COLOR_GREEN,0			;TEST SWITCH
	STR_MAC	42,182,LEFTSLOT,COLOR_GREEN,0		;LEFT COIN
	STR_MAC	42,205,RIGHTSLOT,COLOR_GREEN,0		;RIGHT COIN
	STR_MAC	127,182,CENTER,COLOR_GREEN,0		;CENTER COIN
	STR_MAC	127,205,FOURTH,COLOR_GREEN,0		;COIN MIDDLE
	.IF GERMAN
	STR_MAC	25,150,EXITMESS1,COLOR_WHITE,0		;EXIT MESSAGE 1
	STR_MAC	185,160,EXITMESS2,COLOR_WHITE,0		;EXIT MESSAGE 2
	.ELSE
	STR_MAC	25,150,EXITMESS1,COLOR_WHITE,0		;EXIT MESSAGE 1
	STR_MAC	185,160,EXITMESS2,COLOR_WHITE,0		;EXIT MESSAGE 2
	.ENDIF
	STR_MAC	88,56,START_MESS,COLOR_P1,0		; Player 1 Start
	STR_MAC	213,56,START_MESS,COLOR_P2,0    		; Player 2 Start
	STR_MAC	82,126,TRIGGER_MESS,COLOR_P1,0    		; Player 1 Trigger
	STR_MAC	82,91,BOMB_MESS,COLOR_P1,0   		; Player 1 Bomb
	STR_MAC	207,126,TRIGGER_MESS,COLOR_P2,0    		; Player 2 Trigger
	STR_MAC	207,91,BOMB_MESS,COLOR_P2,0 		; Player 2 Bomb
	STR_MAC	297,182,VUP_MESS,COLOR_GREEN,0		; Volume Up
	STR_MAC	297,205,VDOWN_MESS,COLOR_GREEN,0	; Volume Down
	STR_MAC	42,223,SERVICE_MESS,COLOR_GREEN,0	; Service Credit
	STR_MAC	42,233,SERVICE_MESS1,COLOR_GREEN,0	; Service Credit
	STR_MAC	142,223,INTERLOCK_MESS,COLOR_GREEN,0	; Interlock
	STR_MAC	142,233,INTERLOCK_MESS1,COLOR_GREEN,0	; Interlock
	STR_MAC	242,223,BILL_VALID_MESS,COLOR_GREEN,0	; Bill Validator
	STR_MAC	242,233,BILL_VALID_MESS1,COLOR_GREEN,0	; Bill Validator
	STR_MAC	338,56,START_MESS,COLOR_P3,0     		; Player 3 Start
	STR_MAC	332,126,TRIGGER_MESS,COLOR_P3,0 		; Player 3 Trigger
	STR_MAC	332,91,BOMB_MESS,COLOR_P3,0    		; Player 3 Bomb
	.LONG	0


STR_TABLE1:
	STR_MAC	88,5,SWITCH_TITLE,COLOR_WHITE,0		;TITLE
; Player switch titles
	STR_MAC 45,27,PLAY1_MESS,COLOR_RED,0
	STR_MAC	295,27,PLAY2_MESS,COLOR_BLUE,0
	STR_MAC	212,182,SLAM,COLOR_GREEN,0			;SLAM
	STR_MAC	212,205,TEST,COLOR_GREEN,0			;TEST SWITCH
	STR_MAC	42,182,LEFTSLOT,COLOR_GREEN,0		;LEFT COIN
	STR_MAC	42,205,RIGHTSLOT,COLOR_GREEN,0		;RIGHT COIN
	STR_MAC	127,182,CENTER,COLOR_GREEN,0		;CENTER COIN
	STR_MAC	127,205,FOURTH,COLOR_GREEN,0		;COIN MIDDLE
	.IF GERMAN
	STR_MAC	25,150,EXITMESS1,COLOR_WHITE,0		;EXIT MESSAGE 1
	STR_MAC	185,160,EXITMESS2,COLOR_WHITE,0		;EXIT MESSAGE 2
	.ELSE
	STR_MAC	25,150,EXITMESS1,COLOR_WHITE,0		;EXIT MESSAGE 1
	STR_MAC	185,160,EXITMESS2,COLOR_WHITE,0		;EXIT MESSAGE 2
	.ENDIF
	STR_MAC	16,41,START_MESS,COLOR_P1,0		; Player 1 Start
	STR_MAC	86,41,START_MESS,COLOR_P1,0		; Player 1 Start
	STR_MAC	82,126,TRIGGER_MESS,COLOR_P1,0    		; Player 1 Trigger
	STR_MAC	82,91,BOMB_MESS,COLOR_P1,0   		; Player 1 Bomb
	STR_MAC	297,182,VUP_MESS,COLOR_GREEN,0		; Volume Up
	STR_MAC	297,205,VDOWN_MESS,COLOR_GREEN,0	; Volume Down
	STR_MAC	42,223,SERVICE_MESS,COLOR_GREEN,0	; Service Credit
	STR_MAC	42,233,SERVICE_MESS1,COLOR_GREEN,0	; Service Credit
	STR_MAC	142,223,INTERLOCK_MESS,COLOR_GREEN,0	; Interlock
	STR_MAC	142,233,INTERLOCK_MESS1,COLOR_GREEN,0	; Interlock
	STR_MAC	242,223,BILL_VALID_MESS,COLOR_GREEN,0	; Bill Validator
	STR_MAC	242,233,BILL_VALID_MESS1,COLOR_GREEN,0	; Bill Validator
	STR_MAC	266,41,START_MESS,COLOR_P3,0		; Player 3 Start
	STR_MAC	336,41,START_MESS,COLOR_P3,0     		; Player 3 Start
	STR_MAC	332,126,TRIGGER_MESS,COLOR_P3,0 		; Player 3 Trigger
	STR_MAC	332,91,BOMB_MESS,COLOR_P3,0    		; Player 3 Bomb
	.LONG	0

	.IF GERMAN

SWITCH_TITLE
	.STRING	"REVOLUTION X - KONTAKT-TEST",0
EXITMESS1
	.STRING	"ENTER UND ESCAPE OR SPIELER 1 START UND TRIGGER",0
	.EVEN
EXITMESS2
	.STRING "ZUM VERLASSEN",0	
	.EVEN
LEFTSLOT
	.STRING "LINK.",0
	.EVEN
RIGHTSLOT
	.STRING	"RECHT.",0
	.EVEN
SERVICE1
	.STRING	"SERVICE",0
	.EVEN
SERVICE2
	.STRING	"KREDIT",0
	.EVEN

	.ELSE

SWITCH_TITLE
	.STRING	"REVOLUTION X - SWITCH TEST",0
EXITMESS1
	.STRING	"ENTER AND ESCAPE OR PLAYER 1 START AND TRIGGER",0
	.EVEN
EXITMESS2
	.STRING "TO EXIT",0	
	.EVEN
LEFTSLOT
	.STRING "COIN 1",0
	.EVEN
RIGHTSLOT
	.STRING	"COIN 2",0
	.EVEN
;SERVICE1
;	.STRING	"SERVICE",0
;	.EVEN
;SERVICE2
;	.STRING	"CREDIT",0
;	.EVEN
VUP_MESS
	.STRING "VOL UP",0
	.EVEN
VDOWN_MESS
	.STRING	"VOL DOWN",0
	.EVEN
SERVICE_MESS
	.STRING	"SERVICE",0
	.EVEN
SERVICE_MESS1
	.STRING	"CREDIT",0
	.EVEN
INTERLOCK_MESS
	.STRING	"COINDOOR",0
	.EVEN
INTERLOCK_MESS1
	.STRING	"INTERLOCK",0
	.EVEN
BILL_VALID_MESS
	.STRING	"BILL",0
BILL_VALID_MESS1
	.STRING	"VALIDATOR",0
	.EVEN

	.ENDIF

STSTART
	.STRING	"STARTS",0
	.EVEN

PLAY1_MESS
	.STRING	"PLAYER 1",0
	.EVEN
PLAY2_MESS
	.STRING	"PLAYER 2",0
	.EVEN
PLAY3_MESS
	.STRING	"PLAYER 3",0
	.EVEN

;P1START
START_MESS
	.STRING	"START",0
	.EVEN
;P2START
;	.STRING	"START",0
;	.EVEN
;P3START
;	.STRING	"START",0
;	.EVEN
;P1_TRIGGER
TRIGGER_MESS
	.STRING	"TRIGGER",0
	.EVEN
;P2_TRIGGER
;	.STRING	"TRIGGER",0
;	.EVEN
;P3_TRIGGER
;	.STRING	"TRIGGER",0
;	.EVEN
;P1_BOMB
BOMB_MESS
	.STRING	"BOMB",0
	.EVEN
;P2_BOMB
;	.STRING	"BOMB",0
;	.EVEN
;P3_BOMB
;	.STRING	"BOMB",0
;	.EVEN

;COINMESS1
;	.STRING	"COIN1",0
;	.EVEN
;COINMESS2
;	.STRING	"COIN2",0	
;	.EVEN

CENTER
	.STRING	"COIN 3",0
	.EVEN
FOURTH
	.STRING	"COIN 4",0
	.EVEN

SLAM
	.STRING	"SLAM",0
	.EVEN
TEST
	.STRING	"TEST",0
	.EVEN
;VIDEO
;	.STRING	"VIDEO FREEZE",0
;	.EVEN
	.ENDIF


	.IF	PRINTER
	.ELSE
**************************************************************************
*								         *
* 	MONITOR TEST DATA AREA						 *
*								         *
**************************************************************************

MON_VECS:
	VECMAC	COLOR_WHITE,004,004,396,004
	VECMAC	COLOR_WHITE,004,004,004,250
	VECMAC	COLOR_WHITE,004,250,396,250
	VECMAC	COLOR_WHITE,396,250,396,004
	VECMAC	COLOR_WHITE,060,005,060,250
	VECMAC	COLOR_WHITE,115,005,115,250
	VECMAC	COLOR_WHITE,170,005,170,250
	VECMAC	COLOR_WHITE,225,005,225,250
	VECMAC	COLOR_WHITE,280,005,280,250
	VECMAC	COLOR_WHITE,335,005,335,250
	VECMAC	COLOR_WHITE,005,54,396,54
	VECMAC	COLOR_WHITE,005,103,396,103
	VECMAC	COLOR_WHITE,005,152,396,152
	VECMAC	COLOR_WHITE,005,201,396,201
	.LONG	0

MON_RECS:
	VECMAC	COLOR_RED,182,000,030,005	; TOP
	VECMAC	COLOR_GREEN,182,005,030,006
	VECMAC	COLOR_RED,182,250,030,005	; BOTTOM
	VECMAC	COLOR_GREEN,182,244,030,006
	VECMAC	COLOR_RED,000,117,005,020	; LEFT
	VECMAC	COLOR_GREEN,005,117,006,020
	VECMAC	COLOR_RED,396,117,005,020	; RIGHT
	VECMAC	COLOR_GREEN,390,117,006,020
	.LONG	0

MON_DOTS:
	DOTMAC	COLOR_WHITE,032,029
	DOTMAC	COLOR_WHITE,087,029
	DOTMAC	COLOR_WHITE,142,029
	DOTMAC	COLOR_WHITE,197,029
	DOTMAC	COLOR_WHITE,252,029
	DOTMAC	COLOR_WHITE,307,029
	DOTMAC	COLOR_WHITE,362,029

	DOTMAC	COLOR_WHITE,032,078
	DOTMAC	COLOR_WHITE,087,078
	DOTMAC	COLOR_WHITE,142,078
	DOTMAC	COLOR_WHITE,197,078
	DOTMAC	COLOR_WHITE,252,078
	DOTMAC	COLOR_WHITE,307,078
	DOTMAC	COLOR_WHITE,362,078

	DOTMAC	COLOR_WHITE,032,127
	DOTMAC	COLOR_WHITE,087,127
	DOTMAC	COLOR_WHITE,142,127
	DOTMAC	COLOR_WHITE,197,127
	DOTMAC	COLOR_WHITE,252,127
	DOTMAC	COLOR_WHITE,307,127
	DOTMAC	COLOR_WHITE,362,127

	DOTMAC	COLOR_WHITE,032,176
	DOTMAC	COLOR_WHITE,087,176
	DOTMAC	COLOR_WHITE,142,176
	DOTMAC	COLOR_WHITE,197,176
	DOTMAC	COLOR_WHITE,252,176
	DOTMAC	COLOR_WHITE,307,176
	DOTMAC	COLOR_WHITE,362,176

	DOTMAC	COLOR_WHITE,032,225
	DOTMAC	COLOR_WHITE,087,225
	DOTMAC	COLOR_WHITE,142,225
	DOTMAC	COLOR_WHITE,197,225
	DOTMAC	COLOR_WHITE,252,225
	DOTMAC	COLOR_WHITE,307,225
	DOTMAC	COLOR_WHITE,362,225
	.LONG	0

PRIMARY_COLORS:

	RECTMAC	COLOR_RED,0,0,395,255
	RECTMAC	COLOR_GREEN,0,0,395,255
	RECTMAC	COLOR_BLUE,0,0,395,255
	.LONG	0

COLOR_BARS:

;        RECTMAC	COLOR_BLACK,   0, 0, 49, 16
;        RECTMAC	COLOR_BLACK,  49, 0, 49, 16
;        RECTMAC	COLOR_BLACK,  98, 0, 49, 16
;        RECTMAC	COLOR_BLACK, 147, 0, 49, 16
;        RECTMAC	COLOR_BLACK, 196, 0, 49, 16        
;        RECTMAC	COLOR_BLACK, 245, 0, 49, 16
;        RECTMAC	COLOR_BLACK, 294, 0, 49, 16
;        RECTMAC	COLOR_BLACK, 343, 0, 49, 16
        RECTMAC	COLOR_BLACK,   0, 0, 50, 16
        RECTMAC	COLOR_BLACK,  50, 0, 50, 16
        RECTMAC	COLOR_BLACK, 100, 0, 50, 16
        RECTMAC	COLOR_BLACK, 150, 0, 50, 16
        RECTMAC	COLOR_BLACK, 200, 0, 50, 16        
        RECTMAC	COLOR_BLACK, 250, 0, 50, 16
        RECTMAC	COLOR_BLACK, 300, 0, 50, 16
        RECTMAC	COLOR_BLACK, 350, 0, 50, 16
				     
	.LONG	0




**************************************************************************
*								         *
* 	DIP SWITCH DISPLAY STUFF					 *
*								         *
**************************************************************************

;DIP_VECS:
;	VECMAC	COLOR_RED,20,32,60,32		; DS1
;	VECMAC	COLOR_RED,20,32,20,138
;	VECMAC	COLOR_RED,20,138,60,138	
;	VECMAC	COLOR_RED,60,32,60,138
;
;	VECMAC	COLOR_RED,230,32,270,32	; DS2
;	VECMAC	COLOR_RED,230,32,230,138
;	VECMAC	COLOR_RED,230,138,270,138	
;	VECMAC	COLOR_RED,270,32,270,138
;
;	VECMAC	COLOR_WHITE,63,42,73,42
;
;	VECMAC	COLOR_WHITE,63,54,73,54
;
;	VECMAC	COLOR_WHITE,63,66,68,66
;	VECMAC	COLOR_WHITE,63,90,68,90
;	VECMAC	COLOR_WHITE,68,66,68,90
;	VECMAC	COLOR_WHITE,68,78,73,78
;
;	VECMAC	COLOR_WHITE,63,102,68,102
;	VECMAC	COLOR_WHITE,63,126,68,126
;	VECMAC	COLOR_WHITE,68,102,68,126
;	VECMAC	COLOR_WHITE,68,114,73,114
;
;	VECMAC	COLOR_WHITE,273,42,278,42	;COUNTRY
;	VECMAC	COLOR_WHITE,273,54,278,54
;	VECMAC	COLOR_WHITE,278,42,278,54
;	VECMAC	COLOR_WHITE,278,48,283,48
;	
;	VECMAC	COLOR_WHITE,273,66,283,66	;UNUSED
;	VECMAC	COLOR_WHITE,273,78,283,78	;# OF COIN COUNTERS
;
;	VECMAC	COLOR_WHITE,273,90,278,90	;# OF PLAYERS
;	VECMAC	COLOR_WHITE,273,102,278,102
;	VECMAC	COLOR_WHITE,278,90,278,102
;	VECMAC	COLOR_WHITE,278,96,283,96
;
;	VECMAC	COLOR_WHITE,273,114,283,114	;VIDEO FREEZE
;	VECMAC	COLOR_WHITE,273,126,283,126	;TEST SWITCH
DIP_BOXES:
	RECTMAC	COLOR_RED,20,75,40,106
	RECTMAC	COLOR_RED,230,75,40,106
	.LONG	0
DIP_VECS:
	VECMAC	COLOR_WHITE,63,85,73,85

	VECMAC	COLOR_WHITE,63,96,73,96

	VECMAC	COLOR_WHITE,63,109,68,109
	VECMAC	COLOR_WHITE,63,133,68,133
	VECMAC	COLOR_WHITE,68,109,68,133
	VECMAC	COLOR_WHITE,68,121,73,121

	VECMAC	COLOR_WHITE,63,145,68,145
	VECMAC	COLOR_WHITE,63,169,68,169
	VECMAC	COLOR_WHITE,68,145,68,169
	VECMAC	COLOR_WHITE,68,157,73,157

	VECMAC	COLOR_WHITE,273,85,278,85	;COUNTRY
	VECMAC	COLOR_WHITE,273,97,278,97
	VECMAC	COLOR_WHITE,278,85,278,97
	VECMAC	COLOR_WHITE,278,91,283,91
	
	VECMAC	COLOR_WHITE,273,109,283,109	;UNUSED
	VECMAC	COLOR_WHITE,273,121,283,121	;# OF COIN COUNTERS

;	VECMAC	COLOR_WHITE,273,133,278,133	;# OF PLAYERS
;	VECMAC	COLOR_WHITE,273,145,278,145
;	VECMAC	COLOR_WHITE,278,133,278,145
;	VECMAC	COLOR_WHITE,278,139,283,139
	VECMAC	COLOR_WHITE,273,133,283,133	;# OF PLAYERS
	VECMAC	COLOR_WHITE,273,145,283,145

	VECMAC	COLOR_WHITE,273,157,283,157	;VIDEO FREEZE
	VECMAC	COLOR_WHITE,273,169,283,169	;TEST SWITCH
	.LONG	0

DIP_STRS:
;	STR_MAC	124,8,DP_TITLE,COLOR_GREEN,0
;   	STR_MAC	30,20,DP_DS1,COLOR_WHITE,0
;	STR_MAC	240,20,DP_DS2,COLOR_WHITE,0
;	STR_MAC	7,39,DP_DSN1,COLOR_WHITE,0
;	STR_MAC	7,51,DP_DSN2,COLOR_WHITE,0
;	STR_MAC	7,63,DP_DSN3,COLOR_WHITE,0
;	STR_MAC	7,75,DP_DSN4,COLOR_WHITE,0
;	STR_MAC	7,87,DP_DSN5,COLOR_WHITE,0
;	STR_MAC	7,99,DP_DSN6,COLOR_WHITE,0
;	STR_MAC	7,111,DP_DSN7,COLOR_WHITE,0
;	STR_MAC	7,123,DP_DSN8,COLOR_WHITE,0
;
;	STR_MAC	217,39,DP_DSN1,COLOR_WHITE,0
;	STR_MAC	217,51,DP_DSN2,COLOR_WHITE,0
;	STR_MAC	217,63,DP_DSN3,COLOR_WHITE,0
;	STR_MAC	217,75,DP_DSN4,COLOR_WHITE,0
;	STR_MAC	217,87,DP_DSN5,COLOR_WHITE,0
;	STR_MAC	217,99,DP_DSN6,COLOR_WHITE,0
;	STR_MAC	217,111,DP_DSN7,COLOR_WHITE,0
;	STR_MAC	217,123,DP_DSN8,COLOR_WHITE,0
;
;	STR_MAC	100,150,DP_INS1,COLOR_WHITE,0
	STR_MAC	124,8,DP_TITLE,COLOR_GREEN,0
   	STR_MAC	26,63,DP_DS1,COLOR_YELLOW,0
	STR_MAC	236,63,DP_DS2,COLOR_YELLOW,0
	STR_MAC	7,82,DP_DSN1,COLOR_YELLOW,0
	STR_MAC	7,94,DP_DSN2,COLOR_YELLOW,0
	STR_MAC	7,106,DP_DSN3,COLOR_YELLOW,0
	STR_MAC	7,118,DP_DSN4,COLOR_YELLOW,0
	STR_MAC	7,130,DP_DSN5,COLOR_YELLOW,0
	STR_MAC	7,142,DP_DSN6,COLOR_YELLOW,0
	STR_MAC	7,154,DP_DSN7,COLOR_YELLOW,0
	STR_MAC	7,166,DP_DSN8,COLOR_YELLOW,0

	STR_MAC	217,82,DP_DSN1,COLOR_YELLOW,0
	STR_MAC	217,94,DP_DSN2,COLOR_YELLOW,0
	STR_MAC	217,106,DP_DSN3,COLOR_YELLOW,0
	STR_MAC	217,118,DP_DSN4,COLOR_YELLOW,0
	STR_MAC	217,130,DP_DSN5,COLOR_YELLOW,0
	STR_MAC	217,142,DP_DSN6,COLOR_YELLOW,0
	STR_MAC	217,154,DP_DSN7,COLOR_YELLOW,0
	STR_MAC	217,166,DP_DSN8,COLOR_YELLOW,0

	STR_MAC	75,236,DP_INS1,COLOR_WHITE,0

	.LONG	0

DP_DS1:
	.STRING	"U105",0
	.EVEN
DP_DS2:
	.STRING	"U108",0
	.EVEN

DP_DSN1
	.STRING	"1",0
	.EVEN
DP_DSN2
	.STRING	"2",0
	.EVEN
DP_DSN3
	.STRING	"3",0
	.EVEN
DP_DSN4
	.STRING	"4",0
	.EVEN
DP_DSN5
	.STRING	"5",0
	.EVEN
DP_DSN6
	.STRING	"6",0
	.EVEN	 
DP_DSN7
	.STRING	"7",0
	.EVEN
DP_DSN8
	.STRING	"8",0
	.EVEN

DUSECMOS_1:
	.STRING	"CMOS COINAGE",0
	.EVEN

DUSECMOS_0:
	.STRING	"DIPSWITCH COINAGE",0
	.EVEN

DMIRROR_0
	.STRING	"MIRROR DISPLAY",0
	.EVEN

DMIRROR_1
	.STRING	"NORMAL DISPLAY",0
	.EVEN

DCOUNTER_0
	.STRING	"ONE COUNTER",0
	.EVEN

DCOUNTER_1
	.STRING	"TWO COUNTERS",0
	.EVEN

DCOINAGE
	.STRING	"COINAGE",0
	.EVEN

DCOUNTRY_0
	.STRING	"USA",0
	.EVEN
DCOUNTRY_2
	.STRING	"FRENCH",0
	.EVEN


DFREEZE_0
	.STRING	"VIDEO FREEZE",0
	.EVEN

DREVX_CAB:
	.STRING	"REV X CABINET",0
	.EVEN

DT2_CAB:
	.STRING	"T2 RETROFIT",0
	.EVEN

DPLAYER_TAB
	.LONG	DPLAYER_0, DPLAYER_1, DPLAYER_2, DPLAYER_3

DUPGRADE_TAB:
	.LONG	DREVX_CAB, DT2_CAB

	.IF GERMAN
DCOUNTRY_1
	.STRING	"DEUTSCH",0
	.EVEN

DCOUNTRY_TAB
	.LONG	DCOUNTRY_1, DCOUNTRY_0, DCOUNTRY_2, DCOUNTRY_3

DCREDITS
	.STRING	"KREDITE...",0
	.EVEN
DTOSTART
	.STRING	"BEI SPIELBEGINN",0
	.EVEN
DTOCONTINUE
	.STRING	"ZUR SPIELFORTSET.",0
	.EVEN

DTEST_0
	.STRING	"TEST",0
	.EVEN

DPLAYER_0
	.STRING	"3 SPIELER",0
	.EVEN
DPLAYER_1
	.STRING	"2 SPIELER",0
	.EVEN
DPLAYER_2
	.STRING	"1 SPIELER",0
	.EVEN
DPLAYER_3
	.STRING	"1 SPIELER",0
	.EVEN

DUCOIN7
	.STRING	"FREISPIEL",0
	.EVEN

DCOINTAB
	.LONG	DGCOINTAB, DUCOINTAB, DFCOINTAB, DUCOINTAB

DP_TITLE
	.STRING	"DIP-SCHALTER-TEST",0
	.EVEN

DP_INS1
	.STRING	"BELIEBIGEN KNOPF DRUECKEN",0
	.EVEN

DP_ON
	.STRING	"EIN",0
	.EVEN
DP_OFF
	.STRING	"AUS",0

	.ELSE
DCOUNTRY_1
	.STRING	"GERMAN",0
	.EVEN

DCOUNTRY_TAB
	.LONG	DCOUNTRY_0, DCOUNTRY_1, DCOUNTRY_2, DCOUNTRY_3

DCREDITS
	.STRING	"CREDITS...",0
	.EVEN
DTOSTART
	.STRING	"TO START",0
	.EVEN
DTOCONTINUE
	.STRING	"TO CONTINUE",0
	.EVEN

DTEST_0
	.STRING	"TEST SWITCH",0
	.EVEN

DPLAYER_0
	.STRING	"3 PLAYER",0
	.EVEN
DPLAYER_1
	.STRING	"2 PLAYER",0
	.EVEN
DPLAYER_2
	.STRING	"1 PLAYER",0
	.EVEN
DPLAYER_3
	.STRING	"1 PLAYER",0
	.EVEN

DUCOIN7
	.STRING	"FREEPLAY",0
	.EVEN

DCOINTAB
	.LONG	DUCOINTAB, DGCOINTAB, DFCOINTAB, DUCOINTAB

DP_TITLE
	.STRING	"DIPSWITCH SETTINGS",0
	.EVEN

DP_INS1
	.STRING	"PRESS ESCAPE OR TRIGGER TO EXIT",0
	.EVEN

DP_ON
	.STRING	"ON",0
	.EVEN
DP_OFF
	.STRING	"OFF",0

	.ENDIF

SECURITY_LEVEL_0_FAIL:
	.STRING	"LEVEL 0 SECURITY CHECK FAILURE",0
	.EVEN


DUNUSED
DGCOIN4
DCOUNTRY_3 
	.STRING	"UNUSED",0
	.EVEN

PUTESTRUN:
	.STRING	"NO VALIDATOR",0
	.EVEN

PUTESTBYPASS:
	.STRING	"VALIDATOR INST.",0
	.EVEN

DPUTAB
	.LONG	PUTESTRUN, PUTESTBYPASS

DUCOINTAB
	.LONG	USA_1,USA_2,USA_3,USA_4,USA_ELECTITLE,DGCOIN4
	.LONG	DGCOIN4,DUCOIN7

DGCOINTAB
	.LONG	GERMAN_1,GERMAN_2,GERMAN_3,GERMAN_4,GERMAN_ELECTITLE
	.LONG	DGCOIN4,DGCOIN4,DUCOIN7

DFCOINTAB
	.LONG	FRENCH_1,FRENCH_2,FRENCH_3,FRENCH_4,FRENCH_ELECTITLE
	.LONG	DGCOIN4,DGCOIN4,DUCOIN7

DCREDTAB
	.LONG	DP_DSN2,DP_DSN2
	.LONG	DP_DSN2,DP_DSN1
	.LONG	DP_DSN1,DP_DSN1
	.LONG	DP_DSN3,DP_DSN1
	.LONG	DP_DSN4,DP_DSN1
	.LONG	DP_DSN3,DP_DSN2
	.LONG	DP_DSN4,DP_DSN2
	.LONG	DP_DSN3,DP_DSN3

	.ENDIF

**************************************************************************
*								         *
* 	CPU BOARD INFORMATION						 *
*								         *
**************************************************************************

CPU_VECS:		       
	VECMAC	COLOR_WHITE,5,10,390,10		; BOARD OUTLINE
	VECMAC	COLOR_WHITE,390,10,390,254
	VECMAC	COLOR_WHITE,5,253,390,253
	VECMAC	COLOR_WHITE,5,10,5,100
	VECMAC	COLOR_WHITE,5,100,15,100
	VECMAC	COLOR_WHITE,15,100,15,115
	VECMAC	COLOR_WHITE,5,115,15,115
	VECMAC	COLOR_WHITE,5,115,5,135
	VECMAC	COLOR_WHITE,5,135,15,135
	VECMAC	COLOR_WHITE,15,135,15,138
	VECMAC	COLOR_WHITE,5,138,15,138
	VECMAC	COLOR_WHITE,5,138,5,215
	VECMAC	COLOR_WHITE,5,215,15,215
	VECMAC	COLOR_WHITE,15,215,15,230
	VECMAC	COLOR_WHITE,5,230,15,230
	VECMAC	COLOR_WHITE,5,230,5,254
	.LONG	0

CPUXBASE	EQU	5
CPUYBASE	EQU	5


CPU_CHIPS:
;CRAM1	CHIPMAC	0,125,25,20,45,7,11,CNAMEA8,1,2,2,1	; COLOR RAM
;CRAM2	CHIPMAC	1,125,75,20,45,7,11,CNAMEC8,1,2,2,1	; COLOR RAM

; XUNIT COLOR RAMS
CRAM1	CHIPMAC	0,50,151,30,13,4,3,CNAMEU67,0,28,2,1	; COLOR RAM
CRAM2	CHIPMAC	1,50,166,30,13,4,3,CNAMEU77,0,28,2,1	; COLOR RAM


;VRAM1	CHIPMAC	2,190,25,15,38,6,2,CNAMEA11,1,2,2,1	; BANK 1 VIDEO RAM
;VRAM2	CHIPMAC	3,207,25,15,38,6,2,CNAMEA12,1,2,2,1	;   (PALETTE)
;VRAM3	CHIPMAC	4,224,25,15,38,6,2,CNAMEA13,1,2,2,1
;VRAM4	CHIPMAC	5,241,25,15,38,6,2,CNAMEA14,1,2,2,1

;VRAM5	CHIPMAC	6,190,71,15,38,6,2,CNAMEB11,1,2,2,1	; BANK 2 VIDEO RAM
;VRAM6	CHIPMAC	7,207,71,15,38,6,2,CNAMEB12,1,2,2,1	;   (PIXEL)
;VRAM7	CHIPMAC	8,224,71,15,38,6,2,CNAMEB13,1,2,2,1
;VRAM8	CHIPMAC	9,241,71,15,38,6,2,CNAMEB14,1,2,2,1

; VRAM - XUNIT
VRAM1	CHIPMAC	2,90,201,30,11,4,2,CNAMEU99,0,28,2,1	; BANK 1 VIDEO RAM
VRAM2	CHIPMAC	3,90,188,30,11,4,2,CNAMEU96,0,28,2,1	;   (PIXEL)
VRAM3	CHIPMAC	4,90,175,30,11,4,2,CNAMEU87,0,28,2,1
VRAM4	CHIPMAC	5,90,162,30,11,4,2,CNAMEU79,0,28,2,1

VRAM5	CHIPMAC	6,90,149,30,11,4,2,CNAMEU69,0,28,2,1	; BANK 2 VIDEO RAM
VRAM6	CHIPMAC	7,90,136,30,11,4,2,CNAMEU62,0,28,2,1	;   (PALETTE)
VRAM7	CHIPMAC	8,90,123,30,11,4,2,CNAMEU48,0,28,2,1
VRAM8	CHIPMAC	9,90,110,30,11,4,2,CNAMEU38,0,28,2,1



;CPU	CHIPMAC	0,330,60,35,35,4,13,CNAMEB21,0,3,3,1	; CPU
; CPU - XUNIT
CPU	CHIPMAC	0,297,45,35,35,7,13,CNAMEU19,0,32,32,1	; CPU

;DMA	CHIPMAC	0,201,120,38,38,6,16,CNAMEE13,0,3,3,1	; DMA
; DMA - XUNIT
DMA	CHIPMAC	0,165,161,26,26,2,9,CNAMEU76,0,23,23,1	; DMA


;PROM1	CHIPMAC	1,155,210,20,40,7,3,CNAMEJ12,1,2,2,1	; PROGRAM ROM 1
;PROM2	CHIPMAC	0,155,167,20,40,7,3,CNAMEG12,1,2,2,1	; PROGRAM ROM 2

; PROGRAM ROMS - XUNIT

PROM1	CHIPMAC	0,213,128,40,13,10,3,CNAMEU51,0,38,2,1	; PROGRAM ROM 1
PROM2	CHIPMAC	1,255,128,40,13,10,3,CNAMEU52,0,38,2,1	; PROGRAM ROM 2
PROM3	CHIPMAC	2,297,128,40,13,10,3,CNAMEU53,0,38,2,1	; PROGRAM ROM 2
PROM4	CHIPMAC	3,339,128,40,13,10,3,CNAMEU54,0,38,2,1	; PROGRAM ROM 2


;IROM1	CHIPMAC	1,195,167,20,40,7,3,CNAMEG14,1,2,2,1	; IMAGE ROM
;IROM2	CHIPMAC	2,217,167,20,40,7,3,CNAMEG16,1,2,2,1	; IMAGE ROM
;IROM3	CHIPMAC	3,239,167,20,40,7,3,CNAMEG17,1,2,2,1	; IMAGE ROM
;IROM4	CHIPMAC	4,261,167,20,40,7,3,CNAMEG18,1,2,2,1	; IMAGE ROM
;
;IROM5	CHIPMAC	5,283,167,20,40,7,3,CNAMEG19,1,2,2,1	; IMAGE ROM
;IROM6	CHIPMAC	6,305,167,20,40,7,3,CNAMEG20,1,2,2,1	; IMAGE ROM
;IROM7	CHIPMAC	7,327,167,20,40,7,3,CNAMEG22,1,2,2,1	; IMAGE ROM
;IROM8	CHIPMAC	8,349,167,20,40,7,3,CNAMEG23,1,2,2,1	; IMAGE ROM
;
;IROM9	CHIPMAC	9,195,210,20,40,7,3,CNAMEJ14,1,2,2,1	; IMAGE ROM
;IROM10	CHIPMAC	10,217,210,20,40,7,3,CNAMEJ16,1,2,2,1	; IMAGE ROM
;IROM11	CHIPMAC	11,239,210,20,40,7,3,CNAMEJ17,1,2,2,1	; IMAGE ROM
;IROM12	CHIPMAC	12,261,210,20,40,7,3,CNAMEJ18,1,2,2,1	; IMAGE ROM
;
;IROM13	CHIPMAC	13,283,210,20,40,7,3,CNAMEJ19,1,2,2,1	; IMAGE ROM
;IROM14	CHIPMAC	14,305,210,20,40,7,3,CNAMEJ20,1,2,2,1	; IMAGE ROM
;IROM15	CHIPMAC	15,327,210,20,40,7,3,CNAMEJ22,1,2,2,1	; IMAGE ROM
;IROM16	CHIPMAC	16,349,210,20,40,7,3,CNAMEJ23,1,2,2,1	; IMAGE ROM

; IROM DATA - XUNIT

IROM1	CHIPMAC	 1,213,233,40,13,6,3,CNAMEU120,0,38,2,1	; IMAGE ROM
IROM2	CHIPMAC	 2,255,233,40,13,6,3,CNAMEU121,0,38,2,1	; IMAGE ROM
IROM3	CHIPMAC	 3,297,233,40,13,6,3,CNAMEU122,0,38,2,1	; IMAGE ROM
IROM4	CHIPMAC	 4,339,233,40,13,6,3,CNAMEU123,0,38,2,1	; IMAGE ROM

IROM5	CHIPMAC	 5,213,218,40,13,6,3,CNAMEU110,0,38,2,1	; IMAGE ROM
IROM6	CHIPMAC	 6,255,218,40,13,6,3,CNAMEU111,0,38,2,1	; IMAGE ROM
IROM7	CHIPMAC	 7,297,218,40,13,6,3,CNAMEU112,0,38,2,1	; IMAGE ROM
IROM8	CHIPMAC	 8,339,218,40,13,6,3,CNAMEU113,0,38,2,1	; IMAGE ROM

IROM9	CHIPMAC	 9,213,203,40,13,6,3,CNAMEU101,0,38,2,1	; IMAGE ROM
IROM10	CHIPMAC	10,255,203,40,13,6,3,CNAMEU102,0,38,2,1	; IMAGE ROM
IROM11	CHIPMAC	11,297,203,40,13,6,3,CNAMEU103,0,38,2,1	; IMAGE ROM
IROM12	CHIPMAC	12,339,203,40,13,6,3,CNAMEU104,0,38,2,1	; IMAGE ROM

IROM13	CHIPMAC	13,213,188,40,13,10,3,CNAMEU91,0,38,2,1	; IMAGE ROM
IROM14	CHIPMAC	14,255,188,40,13,10,3,CNAMEU92,0,38,2,1	; IMAGE ROM
IROM15	CHIPMAC	15,297,188,40,13,10,3,CNAMEU93,0,38,2,1	; IMAGE ROM
IROM16	CHIPMAC	16,339,188,40,13,10,3,CNAMEU94,0,38,2,1	; IMAGE ROM

IROM17	CHIPMAC	17,213,173,40,13,10,3,CNAMEU81,0,38,2,1	; IMAGE ROM
IROM18	CHIPMAC	18,255,173,40,13,10,3,CNAMEU82,0,38,2,1	; IMAGE ROM
IROM19	CHIPMAC	19,297,173,40,13,10,3,CNAMEU83,0,38,2,1	; IMAGE ROM
IROM20	CHIPMAC	20,339,173,40,13,10,3,CNAMEU84,0,38,2,1	; IMAGE ROM

IROM21	CHIPMAC	21,213,158,40,13,10,3,CNAMEU71,0,38,2,1	; IMAGE ROM
IROM22	CHIPMAC	22,255,158,40,13,10,3,CNAMEU72,0,38,2,1	; IMAGE ROM
IROM23	CHIPMAC	23,297,158,40,13,10,3,CNAMEU73,0,38,2,1	; IMAGE ROM
IROM24	CHIPMAC	24,339,158,40,13,10,3,CNAMEU74,0,38,2,1	; IMAGE ROM

IROM25	CHIPMAC	25,213,143,40,13,10,3,CNAMEU63,0,38,2,1	; IMAGE ROM
IROM26	CHIPMAC	26,255,143,40,13,10,3,CNAMEU64,0,38,2,1	; IMAGE ROM
IROM27	CHIPMAC	27,297,143,40,13,10,3,CNAMEU65,0,38,2,1	; IMAGE ROM
IROM28	CHIPMAC	28,339,143,40,13,10,3,CNAMEU66,0,38,2,1	; IMAGE ROM


; PIC - XUNIT

PIC	CHIPMAC 1,45,13,35,13,4,3,CNAMEU444,0,32,2,1	; PIC

; UART - XUNIT

UART_CHIP	CHIPMAC	1,9,35,35,11,14,2,CNAMEU7,0,32,2,1	; UART



;SRAM1	CHIPMAC	0,50,210,13,33,4,4,CNAMEJ4,1,2,2,1	; SCRATCH PAD
;SRAM2	CHIPMAC	1,67,210,13,33,4,4,CNAMEJ5,1,2,2,1	; SCRATCH PAD
;SRAM3	CHIPMAC	2,84,210,13,33,4,4,CNAMEJ6,1,2,2,1	; SCRATCH PAD
;SRAM4	CHIPMAC	3,101,210,13,33,4,4,CNAMEJ7,1,2,2,1	; SCRATCH PAD

; XUNIT SRAM
SRAM1	CHIPMAC	0,218,21,30,11,8,2,CNAMEU6, 0,28,2,1	; SCRATCH PAD
SRAM2	CHIPMAC	1,218,34,30,11,5,2,CNAMEU11,0,28,2,1	; SCRATCH PAD
SRAM3	CHIPMAC	2,218,47,30,11,4,2,CNAMEU18,0,28,2,1	; SCRATCH PAD
SRAM4	CHIPMAC	3,218,60,30,11,4,2,CNAMEU25,0,28,2,1	; SCRATCH PAD

	.LONG	0

VRAMTAB	.LONG	CRAM1,CRAM2
	.LONG	VRAM1,VRAM2,VRAM3,VRAM4,VRAM5,VRAM6
	.LONG	VRAM7,VRAM8
	.LONG	0
PROMTAB	.LONG	PROM1,PROM2
	.LONG	0
IROMTAB	.LONG	IROM1,IROM2,IROM3,IROM4
	.LONG	IROM5,IROM6,IROM7,IROM8
	.LONG	IROM9,IROM10,IROM11,IROM12
	.LONG	IROM13,IROM14,IROM15,IROM16
	.LONG	0
SRAMTAB	.LONG	SRAM1,SRAM2,SRAM3,SRAM4
	.LONG	0
	
;CNAMEA8
;	.STRING	"UA8",0
;	.EVEN
CNAMEU67
	.STRING	"U67",0
	.EVEN
;CNAMEA11	
;	.STRING	"UA11",0
;	.EVEN
;CNAMEA12	
;	.STRING	"UA12",0
;	.EVEN
;CNAMEA13	
;	.STRING	"UA13",0
;	.EVEN
;CNAMEA14	
;	.STRING	"UA14",0
;	.EVEN
CNAMEU99
	.STRING	"U99",0
	.EVEN
CNAMEU96
	.STRING	"U96",0
	.EVEN
CNAMEU87
	.STRING	"U87",0
	.EVEN
CNAMEU79
	.STRING	"U79",0
	.EVEN
CNAMEU69
	.STRING	"U69",0
	.EVEN
CNAMEU62
	.STRING	"U62",0
	.EVEN
CNAMEU48
	.STRING	"U48",0
	.EVEN
CNAMEU38
	.STRING	"U38",0
	.EVEN
;CNAMEC8
;	.STRING	"UC8",0
;	.EVEN
CNAMEU77
	.STRING	"U77",0
	.EVEN
;CNAMEB11
;	.STRING	"UB11",0
;	.EVEN
;CNAMEB12
;	.STRING	"UB12",0
;	.EVEN
;CNAMEB13
;	.STRING	"UB13",0
;	.EVEN
;CNAMEB14
;	.STRING	"UB14",0
;	.EVEN
;CNAMEB21
;	.STRING	"UB21",0
;	.EVEN

CNAMEU19
	.STRING	"U19",0
	.EVEN

CNAME49
	.STRING	"U15",0
	.EVEN
;CNAMEJ4
;	.STRING	"UJ4",0
;	.EVEN
;CNAMEJ5
;	.STRING	"UJ5",0
;	.EVEN
;CNAMEJ6
;	.STRING	"UJ6",0
;	.EVEN
;CNAMEJ7
;	.STRING	"UJ7",0
;	.EVEN
CNAMEU6
	.STRING	"U6",0
	.EVEN
CNAMEU11
	.STRING	"U11",0
	.EVEN
CNAMEU18
	.STRING	"U18",0
	.EVEN
CNAMEU25
	.STRING	"U25",0
	.EVEN
;CNAMEG12	
;	.STRING	"UG12",0
;	.EVEN
CNAMEG14
	.STRING	"UG14",0
	.EVEN
CNAMEG16	
	.STRING	"UG16",0
	.EVEN
CNAMEG17
	.STRING	"UG17",0
	.EVEN
CNAMEG18	
	.STRING	"UG18",0
	.EVEN
CNAMEG19	
	.STRING	"UG19",0
	.EVEN
CNAMEG20	
	.STRING	"UG20",0
	.EVEN
CNAMEG22	
	.STRING	"UG22",0
	.EVEN
CNAMEG23	
	.STRING	"UG23",0
	.EVEN
;CNAMEE13
;	.STRING	"UE13",0
;	.EVEN
CNAMEU76
	.STRING	"U76",0
	.EVEN

;CNAMEJ12
;	.STRING	"UJ12",0
;	.EVEN
;CNAMEJ14
;       	.STRING	"UJ14",0
;	.EVEN
;CNAMEJ16
;	.STRING	"UJ16",0
;	.EVEN
;CNAMEJ17
;	.STRING	"UJ17",0
;	.EVEN
;CNAMEJ18
;	.STRING	"UJ18",0
;	.EVEN
;CNAMEJ19
;	.STRING	"UJ19",0
;	.EVEN
;CNAMEJ20
;	.STRING	"UJ20",0
;	.EVEN
;CNAMEJ22
;	.STRING	"UJ22",0
;	.EVEN
;CNAMEJ23
;	.STRING	"UJ23",0
;	.EVEN

; IROM CHIP NAMES
CNAMEU120
	.STRING	"U120",0
	.EVEN
CNAMEU121
	.STRING	"U121",0
	.EVEN
CNAMEU122
	.STRING	"U122",0
	.EVEN
CNAMEU123
	.STRING	"U123",0
	.EVEN
CNAMEU110
	.STRING	"U110",0
	.EVEN
CNAMEU111
	.STRING	"U111",0
	.EVEN
CNAMEU112
	.STRING	"U112",0
	.EVEN
CNAMEU113
	.STRING	"U113",0
	.EVEN
CNAMEU101
	.STRING	"U101",0
	.EVEN
CNAMEU102
	.STRING	"U102",0
	.EVEN
CNAMEU103
	.STRING	"U103",0
	.EVEN
CNAMEU104
	.STRING	"U104",0
	.EVEN
CNAMEU91
	.STRING	"U91",0
	.EVEN
CNAMEU92
	.STRING	"U92",0
	.EVEN
CNAMEU93
	.STRING	"U93",0
	.EVEN
CNAMEU94
	.STRING	"U94",0
	.EVEN
CNAMEU81
	.STRING	"U81",0
	.EVEN
CNAMEU82
	.STRING	"U82",0
	.EVEN
CNAMEU83
	.STRING	"U83",0
	.EVEN
CNAMEU84
	.STRING	"U84",0
	.EVEN
CNAMEU71
	.STRING	"U71",0
	.EVEN
CNAMEU72
	.STRING	"U72",0
	.EVEN
CNAMEU73
	.STRING	"U73",0
	.EVEN
CNAMEU74
	.STRING	"U74",0
	.EVEN
CNAMEU63
	.STRING	"U63",0
	.EVEN
CNAMEU64
	.STRING	"U64",0
	.EVEN
CNAMEU65
	.STRING	"U65",0
	.EVEN
CNAMEU66
	.STRING	"U66",0
	.EVEN

; PROGRAM ROM NAMES
CNAMEU51
	.STRING	"U51",0
	.EVEN
CNAMEU52
	.STRING	"U52",0
	.EVEN
CNAMEU53
	.STRING	"U53",0
	.EVEN
CNAMEU54
	.STRING	"U54",0
	.EVEN


CNAME115
	.STRING	"U115",0
	.EVEN
CNAMEU444
	.STRING	"U444",0
	.EVEN
CNAMEU7
	.STRING	"U7",0
	.EVEN


**************************************************************************
*								         *
* 	RAM CHIP DATA							 *
*								         *
**************************************************************************

;
;	MAKE SURE THESE TABLES CORRESPOND WITH THE STUFF ABOVE
;

VRAMCHIPS:
;	COLOR RAMS

;	RAM_CHIP 0,0, 8, 16, 1800000H, 187FFF0H		; UA8  (  0 - 3  )
;	RAM_CHIP 0,1, 8, 16, 1800008H, 187FFF8H		; UC8  (  8 - 11 )
; COLOR RAMS - XUNIT
	RAM_CHIP 0,0, 8 , 32, 0A0800000H, 0A08FFFE0H 	; UA8  (  0 - 3  )
	RAM_CHIP 0,1, 16, 32, 0A0800000H, 0A08FFFE0H 	; UC8  (  8 - 11 )


;	VIDEO RAMS
;	RAM_CHIP $MACRO TAB_LINK,CHIP_NO, WIDTH, INTERLEAVE, START_ADDR, END_ADDR 		

	RAM_CHIP 0, 2, 8, 32, 0000018H, 03FFFF8H	; UB11 ( 24 - 27 )
	RAM_CHIP 0, 3, 8, 32, 0000010H, 03FFFF0H	; UB13 ( 16 - 19 )
	RAM_CHIP 0, 4, 8, 32, 0000008H, 03FFFE8H	; UB12 (  8 - 11 )
	RAM_CHIP 0, 5, 8, 32, 0000000H, 03FFFE0H	; UB14 (  0 - 3  )

PALCHIPS:
;	VIDEO PALETTE RAMS
;	RAM_CHIP $MACRO TAB_LINK,CHIP_NO, WIDTH, INTERLEAVE, START_ADDR, END_ADDR 		

	RAM_CHIP 0, 6, 8, 32, 0800018H, 0BFFFF8H   	; UA11 (  24 - 27 )
	RAM_CHIP 0, 8, 8, 32, 0800010H, 0BFFFF0H   	; UA13 (  16 - 19  )
	RAM_CHIP 0, 7, 8, 32, 0800008H, 0BFFFE8H   	; UA12 (  8 - 11 )
	RAM_CHIP 0, 9, 8, 32, 0800000H, 0BFFFE0H   	; UA14 (  0 - 3  )

	.LONG	0

;	SCRATCH RAMS

SRAMCHECK
	.STRING	"CHECKING SCRATCH RAMS",0
	.EVEN

SRAMCHIPS			    ;  ???XUNIT???   needs to change
;	RAM_CHIP SRAM4,3, 4, 16, 1000004H, 13FFFF4H	; UJ7 (  4 - 7  )
;	RAM_CHIP SRAM3,2, 4, 16, 1000000H, 13FFFF0H	; UJ6 (  0 - 3  )
;	RAM_CHIP SRAM2,1, 4, 16, 1000008H, 13FFFF8H	; UJ5 (  8 - 11 )
;	RAM_CHIP SRAM1,0, 4, 16, 100000CH, 13FFFFCH	; UJ4 ( 12 - 15 )

; SRAM - XUNIT 
	RAM_CHIP SRAM2,1, 16, 32, 20000010H, 207FFFF0H	; U11 (16 - 31)
	RAM_CHIP SRAM4,3, 16, 32, 20000000H, 207FFFE0H	; U25 (0 - 15)
	RAM_CHIP SRAM1,0, 16, 32, 20800010H, 20FFFFF0H	; U6 (16 - 31)
	RAM_CHIP SRAM3,2, 16, 32, 20800000H, 20FFFFE0H	; U18 (0 - 15)

	.LONG	0

;PROMCHIPS		 	    ;  ???XUNIT???   needs to change
;	ROM_CHIP PROM1,0,0,16, 0FF800000H, 0FFFFFFF0H, 0FFFFH	; UJ12
;	ROM_CHIP PROM2,1,0,16, 0FF800008H, 0FFFFFFF8H, 0FFFFH	; UG12
; PROM CHIPS FOR XUNIT
PROMBANKS
	ROMBANK PROM1, PROM2, PROM3, PROM4, 0ff000000h,000000000h,0ffffh,0ffffh,0ffffh,0ffffh
;	ROMBANK PROM1, PROM2, PROM3, PROM4, 0ff800000h,0fffffb80h,0ffffh,0ffffh,0ffffh,0ffffh

	.LONG	0

	.SECT	"CKSUMS"

PROG_CKSUM0	.EQU	0FFFFH		;Checksum for the FF.00 bank
PROG_CKSUM1	.EQU	0FFFFH		;Checksum for the FF.01 bank
PROG_CKSUM2	.EQU	0FFFFH		;Checksum for the FF.02 bank
PROG_CKSUM3	.EQU	0FFFFH		;Checksum for the FF.03 bank

CHECKSUM0
	.WORD	PROG_CKSUM0	;U51 CHECKSUM
CHECKSUM1
	.WORD	PROG_CKSUM1	;U52 CHECKSUM
CHECKSUM2
	.WORD	PROG_CKSUM2	;U53 CHECKSUM
CHECKSUM3
	.WORD	PROG_CKSUM3	;U54 CHECKSUM

* CHECKSUM PATCHES
	.WORD	~PROG_CKSUM0	;1'S COMPLEMENT OF THE U51 CHECKSUM
	.WORD	~PROG_CKSUM1	;1'S COMPLEMENT OF THE U52 CHECKSUM
	.WORD	~PROG_CKSUM2	;1'S COMPLEMENT OF THE U53 CHECKSUM
	.WORD	~PROG_CKSUM3	;1'S COMPLEMENT OF THE U54 CHECKSUM

;	.TEXT
	.sect	"COLDSTRT"

**************************************************************************
*								         *
* 		     IMAGE ROM CHECKSUM TABLES				 *
* 									 *
* 		NOTE: COMMENT OUT ANY UNSTUFFED PARTS THAT		 *
* 			EXIST BEFORE THE .LONG 0 TERMINATOR!		 *
*								         *
**************************************************************************
;	ROM_CHIP $MACRO TAB_LINK,CHIP_NO, WIDTH, INTERLEAVE, START_ADDR, END_ADDR, CHECK_SUM
;IROMCHIPS
;	.EVEN
;	ROM_CHIP IROM1,  1, 8,32,  2000000H, 2FFFFE0H, 0FFFFH	; UG14
;	ROM_CHIP IROM9,  9, 8,32,  2000008H, 2FFFFE8H, 0FFFFH	; UJ14
;	ROM_CHIP IROM5,  5, 8,32,  2000010H, 2FFFFF0H, 0FFFFH	; UG19 
;	ROM_CHIP IROM13,13, 8,32,  2000018H, 2FFFFF8H, 0FFFFH	; UJ19 
;
;	ROM_CHIP IROM2,  2, 8,32,  3000000H, 3FFFFE0H, 0FFFFH	; UG16
;	ROM_CHIP IROM10,10, 8,32,  3000008H, 3FFFFE8H, 0FFFFH	; UJ16
;	ROM_CHIP IROM6,  6, 8,32,  3000010H, 3FFFFF0H, 0FFFFH	; UG20
;	ROM_CHIP IROM14,14, 8,32,  3000018H, 3FFFFF8H, 0FFFFH	; UJ20
;
;	ROM_CHIP IROM3,  3, 8,32,  4000000H, 4FFFFE0H, 0FFFFH	; UG17
;	ROM_CHIP IROM11,11, 8,32,  4000008H, 4FFFFE8H, 0FFFFH	; UJ17
;	ROM_CHIP IROM7,  7, 8,32,  4000010H, 4FFFFF0H, 0FFFFH	; UG22
;	ROM_CHIP IROM15,15, 8,32,  4000018H, 4FFFFF8H, 0FFFFH	; UJ22
;
;	ROM_CHIP IROM4,  4, 8,32,  5000000H, 5FFFFE0H, 0FFFFH	; UG18
;	ROM_CHIP IROM12,12, 8,32,  5000008H, 5FFFFE8H, 0FFFFH	; UJ18
;	ROM_CHIP IROM8,  8, 8,32,  5000010H, 5FFFFF0H, 0FFFFH	; UG23
;	ROM_CHIP IROM16,16, 8,32,  5000018H, 5FFFFF8H, 0FFFFH	; UJ23
;
;	.LONG	0		; FORCE IT TO STOP HERE


; IROMS - XUNIT  
IROMBANKS
	.even
	ROMBANK IROM1,	IROM2, IROM3, IROM4, 0f8000000h,0f9000000h,04586h,062f4h,0c85eh,00f4fh
	ROMBANK IROM5,	IROM6, IROM7, IROM8, 0f9000000h,0fa000000h,0c5d7h,0b2a2h,0707ch,02dc2h
	ROMBANK IROM9,	IROM10,IROM11,IROM12,0fa000000h,0fb000000h,0033eh,0b3e8h,0e220h,0139dh
	ROMBANK IROM13,IROM14,IROM15,IROM16,0fb000000h,0fc000000h,01ec9h,04f74h,02ea6h,040d0h
	ROMBANK IROM17,IROM18,IROM19,IROM20,0fc000000h,0fd000000h,01a76h,0bab6h,0c1c1h,06a71h
	ROMBANK IROM21,IROM22,IROM23,IROM24,0fd000000h,0fe000000h,0e25ch,0fbd9h,074fbh,07cc3h
	ROMBANK IROM25,IROM26,IROM27,IROM28,0fe000000h,0ff000000h,09aa9h,0ea50h,0598ah,05444h
	.long	0

IROMCHIPS
	.EVEN
;	ROM_CHIP IROM1,  1, 8,32,  0F8000000H, 0F8FFFFE0H, 05773H	; U120
;	ROM_CHIP IROM2,  2, 8,32,  0F8000008H, 0F8FFFFE8H, 05880H	; U121
;	ROM_CHIP IROM3,  3, 8,32,  0F8000010H, 0F8FFFFF0H, 092C8H	; U122
;	ROM_CHIP IROM4,  4, 8,32,  0F8000018H, 0F8FFFFF8H, 07D46H	; U123
;		        
;	ROM_CHIP IROM5,  5, 8,32,  0F9000000H, 0F9FFFFE0H, 056DFH	; U110
;	ROM_CHIP IROM6,  6, 8,32,  0F9000008H, 0F9FFFFE8H, 0FFF6H	; U111
;	ROM_CHIP IROM7,  7, 8,32,  0F9000010H, 0F9FFFFF0H, 075DFH	; U112
;	ROM_CHIP IROM8,  8, 8,32,  0F9000018H, 0F9FFFFF8H, 0E43BH	; U113
;
;	ROM_CHIP IROM9,  9, 8,32,  0FA000000H, 0FAFFFFE0H, 0929FH	; U101
;	ROM_CHIP IROM10,10, 8,32,  0FA000008H, 0FAFFFFE8H, 07629H	; U102
;	ROM_CHIP IROM11,11, 8,32,  0FA000010H, 0FAFFFFF0H, 04753H	; U103
;	ROM_CHIP IROM12,12, 8,32,  0FA000018H, 0FAFFFFF8H, 07801H	; U104
;
;	ROM_CHIP IROM13,13, 8,32,  0FB000000H, 0FBFFFFE0H, 0CBBDH	; U91
;	ROM_CHIP IROM14,14, 8,32,  0FB000008H, 0FBFFFFE8H, 0DAF4H	; U92
;	ROM_CHIP IROM15,15, 8,32,  0FB000010H, 0FBFFFFF0H, 0E5E1H	; U93
;	ROM_CHIP IROM16,16, 8,32,  0FB000018H, 0FBFFFFF8H, 0BDA4H	; U94
;
;	ROM_CHIP IROM17,17, 8,32,  0FC000000H, 0FCFFFFE0H, 0EE88H	; U81
;	ROM_CHIP IROM18,18, 8,32,  0FC000008H, 0FCFFFFE8H, 07E7EH	; U82
;	ROM_CHIP IROM19,19, 8,32,  0FC000010H, 0FCFFFFF0H, 01B8CH	; U83
;	ROM_CHIP IROM20,20, 8,32,  0FC000018H, 0FCFFFFF8H, 0D46FH	; U84
;
;	ROM_CHIP IROM21,21, 8,32,  0FD000000H, 0FDFFFFE0H, 0A34BH	; U71
;	ROM_CHIP IROM22,22, 8,32,  0FD000008H, 0FDFFFFE8H, 06ABEH	; U72
;	ROM_CHIP IROM23,23, 8,32,  0FD000010H, 0FDFFFFF0H, 0DDFEH	; U73
;	ROM_CHIP IROM24,24, 8,32,  0FD000018H, 0FDFFFFF8H, 0249AH	; U74
;
;	ROM_CHIP IROM25,25, 8,32,  0FE000000H, 0FEFFFFE0H, 0C1B3H	; U63
;	ROM_CHIP IROM26,26, 8,32,  0FE000008H, 0FEFFFFE8H, 0FAA6H	; U64
;	ROM_CHIP IROM27,27, 8,32,  0FE000010H, 0FEFFFFF0H, 0B509H	; U65
;	ROM_CHIP IROM28,28, 8,32,  0FE000018H, 0FEFFFFF8H, 0D467H	; U66

	.LONG	0		; FORCE IT TO STOP HERE

	.END
