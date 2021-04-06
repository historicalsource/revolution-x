	.MLIB	"GXMACS.LIB"
	.FILE	"GXTEXT.ASM"
	.TITLE	"<<< GENERATION X ---- TEXT PROCESSING ROUTINES >>>"
	.WIDTH	132
	.OPTION	B,D,L
	.MNOLIST

	.globl	HEX_TO_ASCII_DEC

**************************************************************************
*								         *
* 	COPYRIGHT (C) 1992 MIDWAY MANUFACTURING COMPANY.		 *
* 		       ALL RIGHTS RESERVED.				 *
*								         *
**************************************************************************

*	GET THE SYSTEM STUFF
	.INCLUDE	"GX.INC"
	.INCLUDE	"GXSTRING.H"
	.INCLUDE	"IMGTBL.GLO"	;Image Equates and Globals
	.INCLUDE	"TEXT.TBL"

;		ASCII Character String Definition
;		---------------------------------
;
;     An ASCII string is n consecutive bytes terminated by a 0.
;
;     A string may contain:
;
;	1. Printable ASCII characters 20h - 7fh.
;
;	2. Command character denoted by a leading \.
;
;	3. Format specifier denoted by a leading %.
;
;     Command Characters:
;
;	A command character is identified by a preceding '\'. These
;	are used to embed command characters and the correct arguments
;	in the string.
;
;	Arguments follow the string definition in the order that they,
;	along with format arguments, appear in the string. 
;
;	To insert a single '\' into the string use '\\'.
;
;	Character		Argument	       		Size
;	---------     		--------			----
;	a			Sleep time to embed		.WORD
;	b			Print color to embed		.WORD
;	c			DMA control word to embed	.WORD
;	d			Font to embed			.LONG
;	e			[Y,X] Position to embed		.LONG
;	f			[DY,DX] Position delta to embed	.LONG
;	i			[Y,X] Spacing to embed		.LONG
;	n	    newline		-
;	p			Use new palette, by I.D.	.LONG
;	u			Turn underlining on
;	v			Turn underlining off
;
;	Inserting a '*' between the \ and the command character will
;	cause the argument to be indirected through the specified pointer.
;
;	Example:
;		.string "switch \*b color",0
;		.long	color_ptr
;	  The color that would be inserted is pointed to by color_ptr.	
;
;     Format Specifiers:	(Note: if a string contains format specifiers
;			       then you must call stringf before	
;			       passing it to the string routines.)	 
;
;		%[flags][width][{h|l|L}]type
;
;	flags - Used for justification of output and printing of
;		signs, blanks and hexadecimal prefixes
;
;		flag	Meaning					Default
;		----	-------					-------
;		+	Prefix the output value with a sign	Sign only for
;			+ or - if it is of signed type.		negatives
;		#	Prefix x,X with 0x,0X.			no prefix
;		,	Used with d,u to print commas		no commas		
;
;	width - A non-negative decimal integer controlling the
;		minimum number of characters printed. If width
;		is prefixed with a 0, zeros are added until the
;		minimum width is reached.
;
;	Prefix		Use
;	------		---
;	h		Used as a prefix with d,u,x,X and c to specify
;			that the argument is a short (byte).
;	l,L		Used as a prefix with d,u,x and X to specify
;			that the argument is a long.
;
;	If the % format character is followed by another % then no
;	format field is taken, rather a single % is written.
;
;	type	Size		Output Format	      	
;	----	----		-------------
;	b	word		Pointer to Binary Coded Decimal (bcd) integer
;	d	word		Pointer to Signed decimal integer
;	u	word		Pointer to Unsigned decimal integer
;	x	word		Pointer to Unsigned hex integer using 'abcdef'
;	X	word		Pointer to Unsigned hex integer using 'ABCDEF'
;	c	word		Pointer to Single character
;	p	long		Pointer to a null terminated string
;	s	long		Address of a null terminated string	
;
;	Arguments - Must follow the string specification in order.
;
;	Examples:
;	---------
;	  This will print the string verbatim,
;		.string	"Let's print a string",0
;	
;	  This will put 'count' at the beginning of the string.
;		.string "%d This is item number %d",0 
;		.long	count		;pointer to int count
;		.long	count		;pointer to int count
;
;	  This will print 'short_item' as a short and 'long_item' as a long.
;		.string "%hd This item is a long %ld",0
;		.long	short_item	;pointer to int count
;		.long	long_item	;pointer to long long_item
;
;	Note: Strings may be nested as deep as defined by NUMSFBUFS
;	      Also, these parameters have limits, i.e. width, it would	
;		not be wise to specify a width of 30 or greater, and so on.
;
;		Commas are not recognized on lead zero fills.

	.REF	DICT_LOOKUP

NUMSFBUFS EQU	5	;NUMBER OF BUFFERS FOR STRINGF
SFBUFSIZE EQU	50*16	;STRINGF BUFFERS ARE 99 CHARACTERS + TERMINATOR

	.BSS	STRNGRAM,30*16	;RAM FOR BUILDING OF STRINGS BY CONVERSION ROUTINES
	.BSS	STRINGF_RAM,NUMSFBUFS*SFBUFSIZE	;RESERVE STRINGF BUFFERS
	.BSS	SFINDEX,16	;INDEX OF NEXT USABLE STRINGF BUFFER
	.BSS	STRING1,32	;TEMP PTR FOR NESTED STRINGS, ANYONE CAN USE
	.BSS	STRING2,32
	.BSS	STRING3,32
	.BSS	STRING_UNDERLINE,16	; UNDERLINE FLAG

	.EVEN
	.TEXT

**************************************************************************
*								         *
* 	ANY OF THE FOLLOWING STRING PRINT ROUTINES REQUIRE		 *
* 	  THESE ARGUMENTS. PLUS ANY OTHERS SPECIFIED.			 *
* 									 *
* 	A0 = SLEEP TIME BETWEEN CHARACTERS				 *
* 	A4 = DMA CONTROL						 *
* 	A5 = [COLOR,PALETTE]						 *
* 	A8 = PTR TO STRING						 *
* 	A9 = [Y,X] SCREEN ADDRESS					 *
* 	A10 = [Y,X] SPACING						 *
* 	A11 = PTR TO FONT TABLE						 *
* 									 *
* 	B1  = [SOUND INDX, OID IF CHARACTERS ARE OBJECTS]		 *
* 	NOTES: 1- SOUND INDX applies only if string sleeps between	 *
* 		 characters. If value is 0 then no sound is made.	 *
* 		 Otherwise, value becomes index into TEXT_SOUND_TAB	 *
*	       2- If FIXED SPACING is selected, then the SPACING 	 * 	
*		  value is the only value added to advance position.	 *
* 									 *
* 	THEY ALL RETURN THESE VALUES INTACT, HOWEVER, ANY CHANGES	 *
* 	INCURRED FROM CONTROL BYTES WILL REMAIN.			 *
* 									 *
* 	ALSO RETURNED:							 *
*	A2 = Ptr to Master object of string. If string does not use	 *
*		objects, then A2 is not touched.			 *
* 	A8 = POINTS TO THE NEXT BYTE AFTER THE STRING TERMINATOR	 *
* 	A9 = NEXT CURSOR POSITION					 *
* 									 *
* 	NOTE: CALL ALL OF THEM WITH JSRP				 *
*	      Uses PTEMP1 in the process block				 *
*								         *
**************************************************************************
                                                                       
**************************************************************************
*                                                                        *
* PRINTF - FORMAT AND PRINT A STRING.					 *
* A1 = ROUTINE TO CALL FOR OUTPUT					 *
* A8 = PTR TO STRING							 *
* RETURNS:								 *
* A1 = INTACT								 *
* A8 = POINTING TO WORD AFTER THE LAST ARGUMENT OF THIS STRING		 *
* 									 *
* NOTE: CALL WITH JSRP							 *
*                                                                        *
**************************************************************************
PRINTF
	CALLR	STRINGF
	MMTM	A12,A1,A3	;SAVE ROUTINE AND NEXT STRING PTR
	JSRPR	A1
	MMFM	A12,A1,A8	;RESTORE ROUTINE AND NEXT STRING (A8)
	RETP

**************************************************************************
*                                                                        *
* STRLNRM - PRINT STRING WITH:						 *
* 		 LEFT JUSTIFY, NORMAL, NOT PUT ON THE OBJECT LIST 	 *
* TRASHES A4,B3 & B5							 *
*                                                                        *
**************************************************************************
STRLNRM
	MOVI	DMACNZ,A4
	MOVI	LEFT_JUSTIFY,B3
	MOVI	SCALE_1TO1,B5
	JRUC	STRINGER

**************************************************************************
*                                                                        *
* STRCNRM - PRINT STRING WITH:						 *
* 		 CENTER JUSTIFY, NORMAL, NOT PUT ON THE OBJECT LIST 	 *
* TRASHES A4,B3 & B5							 *
*                                                                        *
**************************************************************************
STRCNRM
	MOVI	DMACNZ,A4
	MOVI	CENTER_JUSTIFY,B3
	MOVI	SCALE_1TO1,B5
	JRUC	STRINGER

**************************************************************************
*                                                                        *
* STRRNRM - PRINT STRING WITH:						 *
* 		 RIGHT JUSTIFY, NORMAL, NOT PUT ON THE OBJECT LIST 	 *
* TRASHES A4,B3 & B5							 *
*                                                                        *
**************************************************************************
STRRNRM
	MOVI	DMACNZ,A4
	MOVI	RIGHT_JUSTIFY,B3
	MOVI	SCALE_1TO1,B5
	JRUC	STRINGER

**************************************************************************
*                                                                        *
* STRCNRM2 - PRINT STRING TO BOTH DISPLAY PAGES, WITH:			 *
* 		 CENTER JUSTIFY, NORMAL, NOT PUT ON THE OBJECT LIST 	 *
* TRASHES A4,B3 & B5							 *
*                                                                        *
**************************************************************************
STRCNRM2
	MOVI	DMACNZ,A4
	MOVI	M_TEXTDMA2|CENTER_JUSTIFY,B3
	MOVI	SCALE_1TO1,B5
	JRUC	STRINGER

**************************************************************************
*            			                                         *
* STRLNRM2 - PRINT STRING TO BOTH DISPLAY PAGES, WITH:	      		 *
* 		 LEFT JUSTIFY, NORMAL, NOT PUT ON THE OBJECT LIST 	 *
* TRASHES A4,B3 & B5							 *
*                                                                        *
**************************************************************************
STRLNRM2
	MOVI	DMACNZ,A4
	MOVI	M_TEXTDMA2|LEFT_JUSTIFY,B3
	MOVI	SCALE_1TO1,B5
	JRUC	STRINGER

**************************************************************************
*            			                                         *
* STRRNRM2 - PRINT STRING TO BOTH DISPLAY PAGES, WITH:	      		 *
* 		 RIGHT JUSTIFY, NORMAL, NOT PUT ON THE OBJECT LIST 	 *
* TRASHES A4,B3 & B5							 *
*                                                                        *
**************************************************************************
STRRNRM2
	MOVI	DMACNZ,A4
	MOVI	M_TEXTDMA2|RIGHT_JUSTIFY,B3
	MOVI	SCALE_1TO1,B5
	JRUC	STRINGER

**************************************************************************
*                                                                        *
* STRLNRMO - PRINT STRING WITH:						 *
* 		 LEFT JUSTIFY, NORMAL, INSERT ON OBJECT LIST	 	 *
* TRASHES A4,B3,B4 & B5							 *
*                                                                        *
**************************************************************************
STRLNRMO
	MOVI	DMACNZ,A4
	MOVI	M_TEXTOBJ|LEFT_JUSTIFY,B3
	MOVI	M_SCRNOBJ|M_NOSCALE,B4
	MOVI	SCALE_1TO1,B5
	JRUC	STRINGER

**************************************************************************
*                                                                        *
* STRLNRMOS - PRINT STRING WITH:						 *
* 		 LEFT JUSTIFY, NORMAL, INSERT ON OBJECT LIST	 	 *
*		 SHADOWS ON						*
* TRASHES A4,B3,B4 & B5							 *
*                                                                        *
**************************************************************************
STRLNRMOS
	MOVI	DMACNZ,A4
	MOVI	M_TEXTSHAD|M_TEXTOBJ|LEFT_JUSTIFY,B3
	MOVI	M_SCRNOBJ|M_NOSCALE,B4
	MOVI	SCALE_1TO1,B5
	JRUC	STRINGER

**************************************************************************
*                                                                        *
* STRLNRMOF - PRINT STRING WITH:						 *
* 		 LEFT JUSTIFY, NORMAL, INSERT ON OBJECT LIST	 	 *
*		 FIXED SPACING									*
* TRASHES A4,B3,B4 & B5							 *
*                                                                        *
**************************************************************************
STRLNRMOF
	MOVI	DMACNZ,A4
	MOVI	M_FIXEDSPC|M_TEXTOBJ|LEFT_JUSTIFY,B3
	MOVI	M_SCRNOBJ|M_NOSCALE,B4
	MOVI	SCALE_1TO1,B5
	JRUC	STRINGER

**************************************************************************
*                                                                        *
* STRCNRMOF - PRINT STRING WITH:						 *
* 		 CENTER JUSTIFY, NORMAL, INSERT ON OBJECT LIST	 	 *
*		 FIXED SPACING									*
* TRASHES A4,B3,B4 & B5							 *
*                                                                        *
**************************************************************************
STRCNRMOF
	MOVI	DMACNZ,A4
	MOVI	M_FIXEDSPC|M_TEXTOBJ|CENTER_JUSTIFY,B3
	MOVI	M_SCRNOBJ|M_NOSCALE,B4
	MOVI	SCALE_1TO1,B5
	JRUC	STRINGER


**************************************************************************
*                                                                        *
* STRCNRMO - PRINT STRING WITH:						 *
* 		 CENTER JUSTIFY, NORMAL, INSERT ON OBJECT LIST	 	 *
* TRASHES A4,B3,B4 & B5							 *
*                                                                        *
**************************************************************************
STRCNRMO
	MOVI	DMACNZ,A4
	MOVI	M_TEXTOBJ|CENTER_JUSTIFY,B3
	MOVI	M_SCRNOBJ|M_NOSCALE,B4
	MOVI	SCALE_1TO1,B5
	JRUC	STRINGER

**************************************************************************
*                                                                        *
* STRRNRMO - PRINT STRING WITH:						 *
* 		 RIGHT JUSTIFY, NORMAL, INSERT ON THE OBJECT LIST 	 *
* TRASHES A4,B3,B4 & B5							 *
*                                                                        *
**************************************************************************
STRRNRMO
	MOVI	DMACNZ,A4
	MOVI	M_TEXTOBJ|RIGHT_JUSTIFY,B3
	MOVI	M_SCRNOBJ|M_NOSCALE,B4
	MOVI	SCALE_1TO1,B5
	JRUC	STRINGER

**************************************************************************
*                                                                        *
* STRRNRMOF - PRINT STRING WITH:						 *
* 		 RIGHT JUSTIFY, NORMAL, INSERT ON THE OBJECT LIST 	 *
* TRASHES A4,B3,B4 & B5							 *
*                                                                        *
**************************************************************************
STRRNRMOF
	MOVI	DMACNZ,A4
	MOVI	M_FIXEDSPC|M_TEXTOBJ|RIGHT_JUSTIFY,B3
	MOVI	M_SCRNOBJ|M_NOSCALE,B4
	MOVI	SCALE_1TO1,B5
	JRUC	STRINGER

**************************************************************************
*								         *
* STRLNC - PRINT STRING WITH:						 *
* 		 LEFT JUSTIFY, NORMAL, NOT PUT ON THE OBJECT LIST	 *
* 		 NO CONSTANT SUBSTITUTE					 *
* TRASHES A4,B3 & B5							 *
*								         *
**************************************************************************
STRLNC:
	MOVI	DMAWNZ,A4
	MOVI	LEFT_JUSTIFY,B3
	MOVI	SCALE_1TO1,B5
	JRUC	STRINGER

**************************************************************************
*                                                                        *
* STRCNC - PRINT STRING WITH:						 *
* 		 CENTER JUSTIFY, NORMAL, NOT PUT ON THE OBJECT LIST 	 *
* 		 NO CONSTANT SUBSTITUTE					 *
* TRASHES A4,B3 & B5							 *
*                                                                        *
**************************************************************************
STRCNC:
	MOVI	DMAWNZ,A4
	MOVI	CENTER_JUSTIFY,B3
	MOVI	SCALE_1TO1,B5
	JRUC	STRINGER

**************************************************************************
*                                                                        *
* STRRNC - PRINT STRING WITH:						 *
* 		 RIGHT JUSTIFY, NORMAL, NOT PUT ON THE OBJECT LIST 	 *
* 		 NO CONSTANT SUBSTITUTE					 *
* TRASHES A4,B3 & B5							 *
*                                                                        *
**************************************************************************
STRRNC:
	MOVI	DMAWNZ,A4
	MOVI	RIGHT_JUSTIFY,B3
	MOVI	SCALE_1TO1,B5
	JRUC	STRINGER

**************************************************************************
*                                                                        *
* STRLNCF - PRINT STRING WITH:						 *
* 		 RIGHT JUSTIFY, NORMAL, NOT PUT ON THE OBJECT LIST 	 *
* 		 NO CONSTANT SUBSTITUTE, FIXED SPACING			 *
* TRASHES A4,B3 & B5							 *
*                                                                        *
**************************************************************************
STRLNCF:
	MOVI	DMAWNZ,A4
	MOVI	M_FIXEDSPC|LEFT_JUSTIFY,B3
	MOVI	SCALE_1TO1,B5
	JRUC	STRINGER

**************************************************************************
*                                                                        *
* STRRNCF - PRINT STRING WITH:						 *
* 		 RIGHT JUSTIFY, NORMAL, NOT PUT ON THE OBJECT LIST 	 *
* 		 NO CONSTANT SUBSTITUTE, FIXED SPACING			 *
* TRASHES A4,B3 & B5							 *
*                                                                        *
**************************************************************************
STRRNCF:
	MOVI	DMAWNZ,A4
	MOVI	M_FIXEDSPC|RIGHT_JUSTIFY,B3
	MOVI	SCALE_1TO1,B5
	JRUC	STRINGER

**************************************************************************
*                                                                        *
* STRLNCOF - PRINT STRING WITH:						 *
* 		 LEFT JUSTIFY, NORMAL, INSERT ON OBJECT LIST	 	 *
* 		 NO CONSTANT SUBSTITUTE, FIXED SPACING			 *
* TRASHES A4,B3,B4 & B5							 *
*                                                                        *
**************************************************************************
STRLNCOF
	MOVI	DMAWNZ,A4
	MOVI	M_FIXEDSPC|M_TEXTOBJ|LEFT_JUSTIFY,B3
	MOVI	M_SCRNOBJ|M_NOSCALE,B4
	MOVI	SCALE_1TO1,B5
	JRUC	STRINGER

**************************************************************************
*                                                                        *
* STRRNCOF - PRINT STRING WITH:						 *
* 		 RIGHT JUSTIFY, NORMAL, INSERT ON OBJECT LIST	 	 *
* 		 NO CONSTANT SUBSTITUTE, FIXED SPACING			 *
* TRASHES A4,B3,B4 & B5							 *
*                                                                        *
**************************************************************************
STRRNCOF
	MOVI	DMAWNZ,A4
	MOVI	M_FIXEDSPC|M_TEXTOBJ|RIGHT_JUSTIFY,B3
	MOVI	M_SCRNOBJ|M_NOSCALE,B4
	MOVI	SCALE_1TO1,B5
	JRUC	STRINGER

**************************************************************************
*                                                                        *
* STRCNCOF - PRINT STRING WITH:						 *
* 		 CENTER JUSTIFY, NORMAL, INSERT ON OBJECT LIST	 	 *
* 		 NO CONSTANT SUBSTITUTE, FIXED SPACING			 *
* TRASHES A4,B3,B4 & B5							 *
*                                                                        *
**************************************************************************
STRCNCOF
	MOVI	DMAWNZ,A4
	MOVI	M_FIXEDSPC|M_TEXTOBJ|CENTER_JUSTIFY,B3
	MOVI	M_SCRNOBJ|M_NOSCALE,B4
	MOVI	SCALE_1TO1,B5
	JRUC	STRINGER

**************************************************************************
*                                                                        *
* STRLNCO - PRINT STRING WITH:						 *
* 		 LEFT JUSTIFY, NORMAL, INSERT ON OBJECT LIST	 	 *
* 		 NO CONSTANT SUBSTITUTE					 *
* TRASHES A4,B3,B4 & B5							 *
*                                                                        *
**************************************************************************
STRLNCO
	MOVI	DMAWNZ,A4
	MOVI	M_TEXTOBJ|LEFT_JUSTIFY,B3
	MOVI	M_SCRNOBJ|M_NOSCALE,B4
	MOVI	SCALE_1TO1,B5
	JRUC	STRINGER

**************************************************************************
*                                                                        *
* STRCNCO - PRINT STRING WITH:						 *
* 		 CENTER JUSTIFY, NORMAL, INSERT ON OBJECT LIST	 	 *
* 		 NO CONSTANT SUBSTITUTE					 *
* TRASHES A4,B3,B4 & B5							 *
*                                                                        *
**************************************************************************
STRCNCO:
	MOVI	DMAWNZ,A4
	MOVI	M_TEXTOBJ|CENTER_JUSTIFY,B3
	MOVI	M_SCRNOBJ|M_NOSCALE,B4
	MOVI	SCALE_1TO1,B5
	JRUC	STRINGER

**************************************************************************
*								         *
* 	SHADOW ROUTINES -- IDENTICAL TO ABOVE EXCEPT YOU HAVE TO TACK	 *
* 	AN "S" ON THE END OF THE ROUTINE NAME				 *
*								         *
**************************************************************************
STRLNRMS
	MOVI	DMACNZ,A4
	MOVI	M_TEXTSHAD|LEFT_JUSTIFY,B3
	MOVI	SCALE_1TO1,B5
	JRUC	STRINGER

STRCNRMS
	MOVI	DMACNZ,A4
	MOVI	M_TEXTSHAD|CENTER_JUSTIFY,B3
	MOVI	SCALE_1TO1,B5
	JRUC	STRINGER

STRCNRMS2
	MOVI	DMACNZ,A4
	MOVI	M_TEXTSHAD|M_TEXTDMA2|CENTER_JUSTIFY,B3
	MOVI	SCALE_1TO1,B5
	JRUC	STRINGER

STRRNRMS
	MOVI	DMACNZ,A4
	MOVI	M_TEXTSHAD|RIGHT_JUSTIFY,B3
	MOVI	SCALE_1TO1,B5
	JRUC	STRINGER

STRCNRMOS
	MOVI	DMACNZ,A4
	MOVI	M_TEXTOBJ|M_TEXTSHAD|CENTER_JUSTIFY,B3
	MOVI	M_SCRNOBJ|M_NOSCALE,B4
	MOVI	SCALE_1TO1,B5
	JRUC	STRINGER

STRRNRMOS
	MOVI	DMACNZ,A4
	MOVI	M_TEXTOBJ|M_TEXTSHAD|RIGHT_JUSTIFY,B3
	MOVI	M_SCRNOBJ|M_NOSCALE,B4
	MOVI	SCALE_1TO1,B5
	JRUC	STRINGER

**************************************************************************
*								         *
* 	Arbitrary SCALE routines - Same as above but the caller sends	 *
* 		the scale in B5.					 *
*								         *
**************************************************************************
STRCNRMOS_SCALE
	MOVI	DMACNZ,A4
	MOVI	M_TEXTOBJ|M_TEXTSHAD|CENTER_JUSTIFY,B3
	MOVI	M_SCRNOBJ|M_NOSCALE,B4
	JRUC	STRINGER

STRLNRMOS_SCALE
	MOVI	DMACNZ,A4
	MOVI	M_TEXTOBJ|M_TEXTSHAD|LEFT_JUSTIFY,B3
	MOVI	M_SCRNOBJ|M_NOSCALE,B4
	JRUC	STRINGER

STRRNRMOS_SCALE
	MOVI	DMACNZ,A4
	MOVI	M_TEXTOBJ|M_TEXTSHAD|RIGHT_JUSTIFY,B3
	MOVI	M_SCRNOBJ|M_NOSCALE,B4
	JRUC	STRINGER

**************************************************************************
*								         *
* STRINGER - OUTPUT A TEXT STRING, THIS IS A PROCESS SUBROUTINE!	 *
* B1 = [SOUND INDX, OID IF CHARS ARE OBJECTS]				 *
* 	SEE NOTE ABOVE							 *
* B3 = FLAGS - INSERT:JUSTIFY						 *
* 	JUSTIFY = 0 LEFT JUSTIFY					 *
* 		  1 CENTER JUSTIFY					 *
* 		  2 RIGHT JUSTIFY					 *
*	FLAGS:								 *
*	BIT 13:	1=Fixed spacing (i.e. cursor adv constant # of pix).	 *
*		0=Natural spacing (i.e. cursor adv based on char size).	 *
*	BIT 14:	1=DMA characters on both display pages, if applicable.	 *
* 	BIT 15: 1=Shadow the characters				 	 *
* 	BIT 16: 0=Just DMA once.		 			 *
*		1=Create string as OBJECTS.				 *
*	BIT 17: 0=Insert objects on list, if applicable.		 *
*		1=Do NOT insert objects, if applicable.			 *
* B4 = OBJECT OFLAGS (ONLY APPLICABLE TO TEXT CREATED AS OBJECTS)	 *
* B5 = [Y,X] SCALE FACTOR						 *
* 									 *
* NOTE: CALL WITH JSRP							 *
*	Uses PTEMP1 in the process block				 *
*								         *
**************************************************************************
STRINGER
	CLR	B0
	MOVE	B0,@STRING_UNDERLINE,W	; CLEAR OUT UNDERLINING

	CLR	A14
	MOVE	A14,*A13(PTEMP1),L	;Storage for MULTI-PART string obj

	CALLR	WHITE_SPACE	;Calculate the White space for this font
	CALLR	SCALE_SPACING	;Scale the spacing values
	CALLR	SHADOW_OFFSET	;Calculate the Shadow offset, returned in B6

	MOVE	A9,A3		;KEEP INITIAL POSITION FOR NEWLINES

	CALLR	JUSTIFY		;JUSTIFY THE POSITION CORRECTLY

STRING_NEXT_CHAR
	MOVB	*A8,A7		;GET A CHARACTER
	SLL	24,A7
	SRL	24,A7		;MAKE SURE WE'RE POSITIVE
	JREQ	STRINGRX	;BR = STRING BE GONE BROTHA
	ADDK	8,A8		;NEXT BYTE
	CLR	B0		; NOT A SPACE, YET

	CMPI	' ',A7
	JRHI	STRNCHAR	;BR = IT'S KOSH BABY 
	JRLO	STRING_CONTROL	;AHHHH SO VEE HAF CONTROLLL

	CLR	A7
	MOVE	A9,B2		;SAVE IT AWAY
	BTST	B_FIXEDSPC,B3	;CHECK FOR FIXED SPACING   
	JRNZ	NOFSPC0		;BR = Spacing is fixed.

	MOVX	A6,A7		;ADD X SPACE
	ADDXY	A7,A9		;AND ADD IT IN
NOFSPC0
	ADDXY	A10,A9		;ADD SPACING

	MOVE	@STRING_UNDERLINE,A14		;CHECK FOR UNDERLINE
	JRZ	STRING_NEXT_CHAR	;BR =  NOPE -- DO NOTHING
	MOVE	B2,B0	
	MOVE	A9,B2
	MOVE	B0,A9		; SWAP THE LOCATIONS
	MOVK	1,B0
	MOVI	'A',A7		; SET TO AN 'A' FOR APPEARANCES
	JRUC	STRNCHAR	; PROCESS IT

*
*Deal with the given Control Character.  See T_CONTROL_CHARACTERS for options.
*
STRING_CONTROL
	DEC	A7
	SLL	5,A7
	ADDI	T_CONTROL_CHARACTERS,A7
	MOVE	*A7,A7,L
	CALL	A7
	JRUC	STRING_NEXT_CHAR

*OUTPUT A CHARACTER
STRNCHAR:
	MMTM	SP,A0,A2,A3,A4,A5,A6,A10

	MOVE	A11,A1		;ESCAPE TO THE OTHER SIDE

	SUBI	21H,A7		;GET A BASE
	SLL	5,A7
	ADD	A7,A1
	MOVE	*A1,A1,L	;LOAD THE ADDRESS OF THE IMAGE HEADER
	MOVE	*A1(ISIZE),A2,L
	SWAP	A4,A5
	CALLA	GANIOF
	SWAP	A4,A5
	
	BTST	B_TEXTOBJ,B3	;Should we create an Object or just DMA
	JREQ	STRNQDMA	;BR = just DMA

*CREATE THE CHARACTER AS AN OBJECT, HERE

	CALLA	GETOBJ
	JREQ	STRNGDUN		;BR = No object, terminate the string

	PUSH	A8

	MOVE	A1,*A0(OIMG),L
	MOVE	A2,*A0(OUSIZE),L
	MOVE	*A1(ISAG),*A0(OSAG),L
	MOVE	A5,*A0(OPAL),L

	MOVE	A9,A14
	SRL	16,A6
	MOVY	A7,A6
	SUBXY	A6,A14			;ADJUST FOR ANIMATION POINT
		
	MOVE	A14,*A0(ODAG),L		;STUFF 'DA DAG
	MOVE	A14,*A0(OXPOS),W
	SRL	16,A14
	MOVE	A14,*A0(OYPOS),W

	MOVE	A4,A6
	MOVE	*A1(ICTRL),A14,W	;GET BPP AND COMPRESSION
	OR	A14,A6
	SLL	16,A6
	MOVE	A6,*A0(OFSET),L		;STUFF OFFSET AND CONTROL

	MOVE	A0,B14
	MOVE	B5,*B14(OSCALE),L
	MOVE	B1,*B14(OID),W
	MOVE	B4,*B14(OFLAGS),W
	MOVE	B5,A0
	CALLA	GET_SCALED_SIZE
	MOVE	B14,A0
	MOVE	A6,*A0(OSIZE),L

	CALLA	INC_PALCNT		;CLICK UP ONE MORE FOR THIS GUY

	MOVIM	TEXTZVAL,*A0(OZVAL),L	

	MOVE	*A13(PTEMP1),A8,L	;Do we have a head Object yet?
	JRNZ	STRN_OBJ_GOT_HEAD	;BR = Yeah, we've got some head	
	MOVE	A0,A8
	MOVE	A0,*A13(PTEMP1),L
	JRUC	STRNG_OBJ_CK_INSERT
STRN_OBJ_GOT_HEAD
	CALLA	INSPART			;Just another Brick in the Wall
STRNG_OBJ_CK_INSERT

	MOVE	B0,B0
	JRNZ	STRN_NO_INS_OBJECT

	BTST	B_NOINSERT,B3		;Should we insert the character?
	JRNZ	STRN_NO_INS_OBJECT	;BR = No.

	CALLA	INSOBJ			;STUFF THIS SHEEEEEEET

STRN_NO_INS_OBJECT

*
*UNDERLINE CHECK
*
	MOVE	@STRING_UNDERLINE,A14,W
	JRZ	STR_NO_UNDERLINE_OBJECT

	CMPI	RD7FONT,A11		; ONLY UNDERLINES 7 POINT
	JRNZ	STR_NO_UNDERLINE_OBJECT

	PUSH	A0
	CALLA	GETOBJ
	JRZ	STR_OBJ_UNDERLINE_DONE
	MOVE	*SP,A8,L

	CALLA	COPY_OBJ		; DUPE THE OLD OBJECT

	CALLA	INC_PALCNT		;CLICK UP ONE MORE FOR THIS GUY

	MOVE	A0,A8

	MOVI	FONT8UNDERLINE,A1
	MOVI	DMACAL,A4		; CONSTANT
	CALLA	ANI			; PRESTO

	MOVE	*A8(OXPOS),A14,W
	SUBK	1,A14
	MOVE	A14,*A8(OXPOS),W

	MOVE	*A13(PTEMP1),A8,L
	CALLA	INSPART			;Make us part of the master

	MOVE	B0,B0			; CHECK TO SEE IF IT IS A SPACE
	JRNZ	STR_OBJ_UNDERLINE_DONE

	BTST	B_NOINSERT,B3		;Should we insert the underline?
	JRNZ	STR_OBJ_UNDERLINE_DONE	;BR = No.
	CALLA	INSOBJ			; GET IT UP
STR_OBJ_UNDERLINE_DONE
	PULLQ	A0
STR_NO_UNDERLINE_OBJECT

;
;	CHECK FOR SHADOWING
;

	BTST	B_TEXTSHAD,B3
	JRZ	STR_NO_SHADOW_OBJECT

	PUSH	A0
	CALLA	GETOBJ
	JRNE	STRN_GOT_SHADOW_OBJECT	;BR = We got our stuff baby
	PULLQ	A0			;Pull back off for sanity
	JRUC	STR_NO_SHADOW_OBJECT	;And get the hell out
STRN_GOT_SHADOW_OBJECT
	PULLQ	A8

	CALLA	COPY_OBJ		; DUPE THE OLD OBJECT

	MOVE	B6,A8			;Get shadow offset
	SEXT	A8			;X part only
	MOVE	*A0(OXPOS),A14,W
	ADD	A8,A14
	MOVE	A14,*A0(OXPOS),W

	MOVE	B6,A8			;Get shadow offset
	SRA	16,A8			;Y part only
	MOVE	*A0(OYPOS),A14,W	;STUFF POSITIONS
	ADD	A8,A14
 	MOVE	A14,*A0(OYPOS),W	;STUFF POSITIONS

	MOVI	TEXTZVAL+1,A14		;JUST UNDER THE REAL THING
	MOVE	A14,*A0(OZVAL),L	;PUT IT UNDER REGULAR STUFF

	MOVE	A5,A8
	MOVI	COLOR_PBLACK,A5
	CALLA	INC_PALCNT		;MARK THE PALETTE AS TAKEN
	MOVE	A5,*A0(OPAL),L
	MOVE	A8,A5

	MOVE	*A13(PTEMP1),A8,L
	CALLA	INSPART			;Make us part of the master
	BTST	B_NOINSERT,B3		;Should we insert the shadow?
	JRNZ	STR_OBJ_SHADOW_NOINSERT	;BR = No.
	CALLA	INSOBJ
STR_OBJ_SHADOW_NOINSERT

*
*This is the end of the whole Object mess.  Must pull our shit here.
*
STR_NO_SHADOW_OBJECT:
	PULLQ	A8
	JRUC	STRNGDUN

*SIMPLY DMA THE SUCKER, HERE
*A1 = Ptr to ROM image header
*A2 = ISIZE of object
STRNQDMA
	MOVE	B5,A0		;SET SCALE
	SWAP	A4,A5
	MOVE	A9,A3
	SRL	16,A6
	MOVY	A7,A6
	SUBXY	A6,A3		;ANIMATION PNT ADJUSTED DAG

	MOVE	*A1(ICTRL),A14,W	;GET BPP AND COMPRESSION
	OR	A14,A5
	SLL	16,A5

	MOVE	A1,A10
	MOVE	A4,A1		;CONSTANT:PALETTE
	MOVE	*A10(ISAG),A4,L	;SAG ME

	BTST	B_TEXTSHAD,B3
	JRZ	NO_DMA_SHADOW

	MMTM	SP,A1,A3
	MOVI	COLOR_PBLACK,A1		;Make it BLACK from the Fixed palette

	MOVE	B6,A14
	ADDXY	A14,A3			;Add the shadowing offset

	BTST	B_TEXTDMA2,B3		;DMA TWICE?
	JREQ	STRNQDS_1		;BR = NO
	CALLA	QDMAN2
	JRUC	STRNQDS_DONE
STRNQDS_1
	CALLA	QDMAN
STRNQDS_DONE
	MMFM	SP,A1,A3
NO_DMA_SHADOW
	MOVE	B0,B0			; CHECK FOR SPACE
	JRNZ	DMA_SPACE
	BTST	B_TEXTDMA2,B3		;DMA TWICE?
	JREQ	STRNQD_1		;BR = NO
	CALLA	QDMAN2
	JRUC	DMA_SPACE
STRNQD_1
	CALLA	QDMAN
DMA_SPACE

*Do an Underline check here
*A1 = Ptr to ROM image header
*A2 = ISIZE of object
	MOVE	@STRING_UNDERLINE,A14,W
	JRZ	NO_DMA_UNDERLINE
	PUSH	A1
	MOVI	FONT8UNDERLINE,A1
	MOVI	DMACAL,A5
	MOVE	A9,A3
	MOVE	*A1(ICTRL),A14,W	;GET BPP AND COMPRESSION
	OR	A14,A5
	SLL	16,A5
	CALLA	GANIOF
	MOVE	*A1(ISAG),A4,L
	PULLQ	A1
	SRL	16,A6
	MOVY	A7,A6
	SUBXY	A6,A3		;ANIMATION PNT ADJUSTED DAG
	SUBK	1,A3		; SHIFT OVER 1 MORE
	CALLA	QDMAN
NO_DMA_UNDERLINE
	MOVE	A1,A5
	MOVE	A10,A1
STRNGDUN
	MOVE	B0,B0		; CHECK TO SEE IF CHAR IS A SPACE
	JRZ	STRNG_DUN_NO_SPACE

	MOVE	B2,A9		; SETUP THE NEW SPACING
	MMFM	SP,A2,A3,A4,A5,A6,A10
	JRUC	STRNG_BYPASS_1

*A2 = ISIZE of object
STRNG_DUN_NO_SPACE
	CLR	A1
	MOVX	A2,A1
	BTST	B_FIXEDSPC,B3	; CHECK FOR FIXED SPACING   
	JRNZ	NOFSPC1		; BR = NO FIXED SPACING

	MOVE	B5,A14		;GET X-SCALE FACTOR
	SEXT	A14
	SLL	8,A1
	DIVU	A14,A1		;Scale the X factor

	ADDXY	A1,A9		;GET TO THE OTHER SIDE OF THE CHARACTER
NOFSPC1
	MMFM	SP,A2,A3,A4,A5,A6,A10
	ADDXY	A10,A9		;ADD IN SPACING
STRNG_BYPASS_1
	MOVE	*SP+,A0,L
	JREQ	STRING_NEXT_CHAR	;BR = NO SLEEP
*HOARDING THE NUTS UNTIL THE LONG LONG WINTER IS OVER.
	MMTM	A12,A0,A3,A4,A5,A6
	MOVE	B1,B14
	SRL	16,B14		;SHALL WE MAKE A BEEP SOUND?
	JRZ	STRNG_NO_SOUND	;BR = NO
	MOVE	A0,A3
	MOVE	B14,A0		;FLAG BECOMES INDEX
	DEC	A0
	SLL	5,A0
	ADDI	TEXT_SOUND_TAB,A0
	MOVE	*A0,A0,L
;	CALLA	ONESND
	MOVE	A3,A0
STRNG_NO_SOUND
	MOVE	A12,B14
	MMTM	B14,B1,B3,B4,B5,B6
	MOVE	B14,A12
	CALLA	PRCSLP
	MOVE	A12,B14
	MMFM	B14,B1,B3,B4,B5,B6
	MOVE	B14,A12
	MMFM	A12,A0,A3,A4,A5,A6

	JRUC	STRING_NEXT_CHAR
STRINGRX
	ADDK	8,A8			;GET TO THE NEXT BYTE
	MOVE	A5,A6
	SRL	16,A6			;RETURN THE COLOR CORRECTLY
	MOVE	*A13(PTEMP1),A14,L	;Get master object ptr
	JRZ	STRINGER_RET		;BR= There are no objects
	MOVE	A14,A2
STRINGER_RET
	RETP

**************************************************************************
*								         *
* Look-Up table for Control Character functions				 *
*								         *
**************************************************************************
T_CONTROL_CHARACTERS
	.LONG	CONTROL_NEW_SLEEP
	.LONG	CONTROL_NEW_PCOLOR
	.LONG	CONTROL_NEW_CONTROL
	.LONG	CONTROL_NEW_FONT
	.LONG	CONTROL_NEW_XY
	.LONG	CONTROL_NEW_SPACING
	.LONG	CONTROL_ADD_DYDX
	.LONG	CONTROL_NEW_PALETTE
	.LONG	CONTROL_ASCII_TAB
	.LONG	CONTROL_UNDERLINE_ON
	.LONG	CONTROL_UNDERLINE_OFF
	.LONG	CONTROL_NULL
	.LONG	CONTROL_ASCII_CR

**************************************************************************
*								         *
* Control Character functions.						 *
* 	These are meant to be called directly from STRINGER.		 *
* 	If you call them from elsewhere, make sure you are aware	 *
* 	of the registers that may get trashed.				 *
*								         *
**************************************************************************
CONTROL_NEW_SLEEP
	MOVE	*A8+,A0,W	;NEW SLEEP TIME
CONTROL_NULL
	RETS
CONTROL_NEW_PCOLOR
	MOVE	*A8+,A1,W	;NEW PRINT COLOR
	SLL	16,A1
	MOVY	A1,A5		;THE CORRECT POSITION PLEASE
	RETS
CONTROL_NEW_CONTROL
	MOVE	*A8+,A4,W	;NEW DMA FLAGS
	RETS	
CONTROL_NEW_FONT		;NOTE: This gets called from JUSTIFY
	MOVE	*A8+,A11,L	;NEW FONT
	CALLR	WHITE_SPACE	;Re-Calculate the White space for font (A6)
	CALLR	SHADOW_OFFSET	;Also the shadowing stuff	       (B6)
	RETS
CONTROL_NEW_XY
	MOVE	*A8+,A9,L	;NEW POSITION
	RETS
CONTROL_NEW_SPACING		;NOTE: This gets called from JUSTIFY
	MOVE	*A8+,A10,L	;NEW SPACING
	CALLR	SCALE_SPACING
	RETS
CONTROL_ADD_DYDX
	MMTM	SP,A0,A2,A6
	MOVE	*A8+,A2,L	;GET DELTAS
	MOVE	B5,A0	
	CALLA	GET_SCALED_SIZE
	ADDXY	A6,A9		;AND ADD THEM
	MMFM	SP,A0,A2,A6
	RETS
CONTROL_NEW_PALETTE
	MOVE	A0,A1
	MOVE	*A8+,A0,L	;GET PALETTE I.D.
	CALLA	FINDPAL		;FIND IT'S SPOT		
	MOVX	A0,A5
	MOVE	A1,A0
	RETS
CONTROL_ASCII_TAB
	RETS
CONTROL_UNDERLINE_ON
	MOVK	1,B0
	MOVE	B0,@STRING_UNDERLINE,W
	RETS	
CONTROL_UNDERLINE_OFF
	CLR	B0
	MOVE	B0,@STRING_UNDERLINE,W
	RETS
CONTROL_ASCII_CR
	MOVE	A3,A9		;GET BACK TO WHERE YOU ONCE BELONGED
	CLR	A7
	MOVY	A6,A7
	ADDXY	A7,A9		;NEXT LINE DOWN
	MOVE	A9,A3		;STORE THIS POSITION
	CALLR	JUSTIFY		;AND REJUSTIFY YOUR POSITION
	RETS

**************************************************************************
*                                                                        *
* 	END OF PRINT ROUTINES.						 *
*                                                                        *
**************************************************************************

**************************************************************************
*                                                                        *
* 	PRINT FORMAT AND UTILITY ROUTINES				 *
*                                                                        *
**************************************************************************
*
*NULL STRING FOR DUMMIES
*
DUMSTRNG .WORD	0
*
*EQUATES FOR STRINGF
B_LJUSTIFY	EQU	0		;LEFT JUSTIFY WITHIN FIELD
B_CJUSTIFY	EQU	1		;CENTER JUSTIFY WITHIN FIELD
B_PSIGN		EQU	2		;PRINT SIGN IF SIGNED
B_COMMAS	EQU	3		;PRINT COMMAS
B_PHEX		EQU	4		;PRINT HEX PREFIX
B_ZPRINT	EQU	5		;FILL UNUSED WIDTH WITH ZEROS
B_SIGNED	EQU	6		;THIS VALUE IS OF SIGNED TYPE
B_CAP		EQU	7		;USE CAPITAL LETTERS FOR HEX DIGITS
*
*SIZE EQUATES
TYPE_SHORT	EQU	8
TYPE_INT	EQU	16
TYPE_LONG	EQU	32
**************************************************************************
*                                                                        *
* STRINGF - STRING FORMAT ROUTINE.					 *
* 	  SEE "ASCII Character String Definition" AT THE TOP OF FILE.	 *
* A8 = PTR TO STRING TO FORMAT.						 *
* RETURNS:								 *
* A3 = PTR TO .EVEN WORD AFTER THE LAST ARGUMENT OF THE STRING		 *
* A8 = PTR TO FORMATTED STRING						 *
* NOTE: TRASHES A14							 *
*                                                                        *
**************************************************************************
STRINGF:
	CLRM	@SFINDEX,W	;CLEAR THE STRING BUILD MEMORY INDEX
STRINGF_RECURSE:		;RECURSION ENTRY POINT
	MMTM	SP,A0,A1,A2,A4,A5,A6,A7
	MOVE	@SFINDEX,A7,W	;GET THE INDEX OF THE NEXT BUFFER TO USE
	CMPI	NUMSFBUFS,A7
	JRLO	SFALLOC		;MORE BUFFERS TO BE HAD
	MOVI	DUMSTRNG,A8	;POINT TO A NULL STRING WHEN OUT OF MAMMARY
	JRUC	STRINGFX
*ALLOCATE A BUFFER IN WHICH TO BUILD THE STRING
SFALLOC
	INCM	@SFINDEX,W	;INCREMENT THE INDEX FOR NEXT MAM GRAB
	MOVI	SFBUFSIZE,A0
	MPYU	A0,A7		;OFFSET TO NEW ARRAY	
	ADDI	STRINGF_RAM,A7	;ADD OFFSET, A7 POINTS TO OUR BUILD SPACE
	MOVE	A7,A5		;STORE PTR TO BOS HERE
	MOVE	A8,A6
SFARGLP:
	MOVB	*A6,A0		;FIND THE ARGUMENT LIST
	ADDK	8,A6		;AND PNT A6 AT IT
	MOVE	A0,A0
	JRNZ	SFARGLP		;SEARCHING FOR NULL TERMINATOR
	ADDK    0FH,A6		;DO OUR OWN .EVEN TO MATCH ASSEMBLER
	SRL	4,A6
	SLL	4,A6		;MASK FRACTIONAL WORD
SFBUILDLP:
	CALLR	GETCHAR
	JRNC	SFBUILDCH	;WE RECIEVED A NORMAL CHARACTER
	MOVB	A0,*A7		;PASS THE CONTROL
	ADDK	8,A7
SFBUILDARG:
	MOVE	A1,A1
	JRZ	SFBUILDLP	;FINISHED
	MOVB	*A8,*A7
	ADDK	8,A8
	ADDK	8,A7		;TRANSFER ARGS
	DEC	A1		;DEC ARG COUNT
	JRUC	SFBUILDARG
SFBUILDCH:
	BTST	7,A0		; CHECK THE HIGH BIT
	JRZ	SFVALIDCH
	MOVE	A8,A1		; SAVE IT AWAY
	CALLA	DICT_LOOKUP	; LOOKUP THE WORD IN A0
	JRNZ	SFA8TOA7	; IF THERE IS SOMETHING, USE IT	
	MOVE	A1,A8		; IF BAD RETURN
SFVALIDCH
	CMPI	'%',A0
	JRNE	SFCONTROL	;NOT A FORMAT CHARACTER, HOW ABOUT CONTROL
*PARSE STRINGF FORMAT SPECIFIER HERE
	CALLR	GETCHARI	;NO SPECIAL CHARACTERS ALLOWED IN FORMAT
	CMPI	'%',A0
	JREQ	SFXFER		;JUST PRINT A PERCENT SIGN

	CALLR	FFLAGS		;GET THE FORMAT FLAGS IF THERE ARE ANY
	CALLR	FWIDTH		;GET FORMAT WIDTH NEXT
	CALLR	FTYPE		;GET THE FORMAT TYPE
SFTYPE_LP:
	CMPI	's',A0		;SEE IF IT'S A STRING
	JRNE	SFTYPE0
	MOVE	A8,A1		;STORE A8
	MOVE	*A6+,A8,L	;GET THE ADDRESS OF THE STRING(ALWAYS LONG)
	CALLR	STRINGF_RECURSE
	JRUC	SFA8TOA7	;TRANSFER THE NEW #	
SFTYPE0:
	CMPI	'p',A0		;SEE IF IT'S A POINTER TO A STRING
	JRNE	SFTYPE1
	MOVE	A8,A1		;STORE A8
	MOVE	*A6+,A8,L	;GET THE PTR TO THE STRING(IT'S ALWAYS LONG)
	MOVE	*A8,A8,L	;NOW GET THE ADDRESS
	CALLR	STRINGF_RECURSE
	JRUC	SFA8TOA7	;TRANSFER THE NEW #	
SFTYPE1:
	MOVE	A8,A1		;SAVE A8
	CALLR	GETARGI
	CMPI	'b',A0
	JRNE	SFTYPE5		;BCD
	CALLR	BCD_TO_ASCII_DEC	;CONVERT
	JRUC	SFA8TOA7
SFTYPE5:
	CMPI	'd',A0		;SIGNED DECIMAL
	JRNE	SFTYPE6
	BSET	B_SIGNED,A4
	CMPI	TYPE_INT,A2	;SIGN EXTEND LITTLE BROTHER
	JRNE	SFTYPE5A
	SEXT	A8
	JRUC	SFTYPE5B
SFTYPE5A:
	CMPI	TYPE_SHORT,A2	;AND THE YOUNGEST
	JRNE	SFTYPE5B
	SLL	24,A8	
	SRA	24,A8
SFTYPE5B:
	CALLR	HEX_TO_ASCII_DEC	;CONVERT
	JRUC	SFA8TOA7
SFTYPE6:
	CMPI	'u',A0		;UNSIGNED DECIMAL
	JRNE	SFTYPE7
	CALLR	HEX_TO_ASCII_DEC
	JRUC	SFA8TOA7
SFTYPE7:
	CMPI	'x',A0 		;UNSIGNED HEXADECIMAL WITH 'abcdef'
	JRNE	SFTYPE8
	CALLR	HEX_TO_ASCII_HEX
	JRUC	SFA8TOA7
SFTYPE8:
	CMPI	'X',A0		;UNSIGNED HEXADECIMAL WITH 'ABCDEF'
	JRNE	SFTYPE9
	BSET	B_CAP,A4
	CALLR	HEX_TO_ASCII_HEX
	JRUC	SFA8TOA7
SFTYPE9:
	CMPI	'c',A0		;SINGLE CHARACTER
	JRNE	SFTYPE10
	MOVB	A8,*A7
	ADDK	8,A7
	MOVE	A1,A8
	JRUC	SFBUILDLP
SFTYPE10:
*ADD NEW type SPECIFIERS HERE
	JRUC	SFBUILDLP
*TRANSFER NEW FORMAT STRING TO THE STRING WE ARE BUILDING
SFA8TOA7:
	MOVB	*A8,A0
	JRZ	SFA8A7DONE
	ADDK	8,A8	
	MOVB	A0,*A7	
	ADDK	8,A7
	JRUC	SFA8TOA7
SFA8A7DONE:
	MOVE	A1,A8
	JRUC	SFBUILDLP
*
*CHECK FOR A CONTROL CHARACTER
SFCONTROL:
	CMPI	'\',A0
	JRNE	SFXFER		;JUST ANOTHER CHARACTER
	CALLR	GETCHARI	;NOW GET THE CONTROL CHARACTER
	CMPI	'\',A0
	JREQ	SFXFER		;OH! HE WANTS TO PRINT THIS
	CLR	A3		;ASSUME NO INDIRECTION
	CMPI	'*',A0		;IS THERE INDIRECTION HERE?
	JRNE	SFCONTROL_IMM	;BR = NO
	MOVK	1,A3		;CONTROL INDIRECT FLAG
	CALLR	GETCHARI	;THIS TIME GET THE CONTROL CHARACTER FOR REAL!

SFCONTROL_IMM:
	CMPI	'a',A0
	JRNE	SFC1
	MOVI	NEW_SLEEP,A0	;NEW SLEEP TIME
	MOVI	TYPE_INT,A2
	CALLR	PUTCARG		;GET THE CONTROL ARG
	JRUC	SFBUILDLP
SFC1:
	CMPI	'b',A0
	JRNE	SFC2
	MOVI	NEW_PCOLOR,A0	;NEW PRINT COLOR
	MOVI	TYPE_INT,A2
	CALLR	PUTCARG		;GET THE CONTROL ARG
	JRUC	SFBUILDLP
SFC2:
	CMPI	'c',A0
	JRNE	SFC3
	MOVI	NEW_CONTROL,A0	;NEW DMA CONTROL WORD
	MOVI	TYPE_INT,A2
	CALLR	PUTCARG		;GET THE CONTROL ARG
	JRUC	SFBUILDLP
SFC3:
	CMPI	'd',A0
	JRNE	SFC4
	MOVI	NEW_FONT,A0	;NEW FONT
	MOVI	TYPE_LONG,A2
	CALLR	PUTCARG		;GET THE CONTROL ARG
	JRUC	SFBUILDLP
SFC4:
	CMPI	'e',A0
	JRNE	SFC5
	MOVI	NEW_XY,A0	;NEW [Y,X] CURSOR POSITION
	MOVI	TYPE_LONG,A2
	CALLR	PUTCARG		;GET THE CONTROL ARG
	JRUC	SFBUILDLP
SFC5:
	CMPI	'i',A0
	JRNE	SFC6
	MOVI	NEW_SPACING,A0	;NEW SPACING
	MOVI	TYPE_LONG,A2
	CALLR	PUTCARG		;GET THE CONTROL ARG
	JRUC	SFBUILDLP
SFC6:
	CMPI	'n',A0
	JRNE	SFC7
	MOVI	ASCII_CR,A0	;NEWLINE
	JRUC	SFXFER
SFC7:
	CMPI	'f',A0
	JRNE	SFC8
	MOVI	ADD_DYDX,A0	;ADD [DY,DX]
	MOVI	TYPE_LONG,A2
	CALLR	PUTCARG		;GET THE CONTROL ARG
	JRUC	SFBUILDLP
SFC8:
	CMPI	'p',A0
	JRNE	SFC9
	MOVI	NEW_PALETTE,A0	;USE A NEW PALETTE
	MOVI	TYPE_LONG,A2
	CALLR	PUTCARG		;GET THE CONTROL ARG
	JRUC	SFBUILDLP
SFC9:
	CMPI	'u',A0		; UNDERLINING ACTIVATED?
	JRNE	SFC10
	MOVI	UNDERLINE_ON,A0
	JRUC	SFXFER
SFC10:
	CMPI	'v',A0		; UNDERLINING DE-ACTIVATED?
	JRNE	SFC11
	MOVI	UNDERLINE_OFF,A0
	JRUC	SFXFER
SFC11:
*ADD NEW CONTROL CHARACTERS HERE
	JRUC	SFBUILDLP
SFXFER:
	MOVB	A0,*A7
	ADDK	8,A7
	MOVE	A0,A0
	JRNZ	SFBUILDLP	;ADD ON ANOTHER CHARACTER
*STRING IS DONE
	MOVE	A5,A8		;PASS BACK THE PTR TO THE NEW
	DECM	@SFINDEX,W	;FREE THIS BUFFER
STRINGFX
	MOVE	A6,A3		;RETURN END
	MMFM	SP,A0,A1,A2,A4,A5,A6,A7
	RETS

**************************************************************************
*                                                                        *
* JUSTIFY - JUSTIFY THE STRING STARTING POINT FROM THE GIVEN POSITION	 *
* 	  BASED ON THE JUSTIFICATION BYTE				 *
* A8 = PTR TO STRING							 *
* A9 = STRING POSITION							 *
* B3 = JUSTIFICATION BYTE						 *
* 		0 = LEFT						 *
* 		1 = CENTER						 *
* 		2 = RIGHT						 *
* B5 = [Y,X] Scale factor for string.					 *
* RETURNS:								 *
* A9 = JUSTIFIED STARTING POSITION					 *
*                                                                        *
**************************************************************************
JUSTIFY:
	PUSH	A7
	CLR	A7
	MOVE	B3,A7
	SLL	30,A7
	SRL	30,A7		; MASK OFF THE SHADOW BIT
	DEC	A7
	JRN	JUSTIFYX	;NORMAL LEFT JUSTIFY
	JREQ	JUSTIFYC	;CENTER JUSTIFY
*RIGHT JUSTIFY
	CALLR	STRING_LENGTH	;GET THE STRING LENGTH
	JRUC	JUSTIFYA
*CENTER JUSTIFY
JUSTIFYC:
	CALLR	STRING_LENGTH
	SRL	1,A7		;STRNGLEN/2
JUSTIFYA:
	SUBXY	A7,A9		;ADJUST STRING STARTING POSITION
JUSTIFYX:
	PULL	A7
	RETS

**************************************************************************
*								         *
* SCALE_SPACING - Take the current spacing value for the font and	 *
* 		scale it according to the current scale factor.		 *
* A10 = Current [Y,X] spacing.						 *
* B5 = [Y,X] Scale factor for font.					 *
* RETURNS:								 *
* A10 = Scaled spacing							 *
*								         *
**************************************************************************
SCALE_SPACING:
	MMTM	SP,A0,A2,A6
	MOVE	B5,A0			;Transfer values to the proper regs
	MOVE	A10,A2
	CALLA	GET_SCALED_SIZE		;Convert the spacing
	MOVE	A6,A10			;And put it in the right place.
	MMFM	SP,A0,A2,A6
	RETS

**************************************************************************
*								         *
* WHITE_SPACE - Calculate the White space lengths for the given font.	 *
* 		Also handles Y spacing between lines.			 *
* A11 = Ptr to current font table.					 *
* B5 = [Y,X] Scale factor for font.					 *
* RETURNS:								 *
* A6 = [Y,X] White space values						 *
*								         *
**************************************************************************
WHITE_SPACE:
	MMTM	SP,A0,A2
	MOVI	'H' - 21H,A6	;USE 'H' FOR SPACE AND NEWLINE STUFF
	SLL	5,A6
	ADD	A11,A6
	MOVE	*A6,A6,L	;LOAD THE ADDRESS OF THE IMAGE HEADER
	MOVE	*A6(ISIZE),A2,L	;GET THE VISIBLE SIZE OF 'H'
	MOVE	B5,A0		;We need the factor
	CALLA	GET_SCALED_SIZE
	MOVY	A6,A2
	ZEXT	A6
	SRL	1,A6		;(X SIZE OF 'H')/2 = X SPACING
	MOVY	A2,A6
	SRL	17,A2
	SLL	16,A2
	ADDXY	A2,A6		;(Y SIZE OF 'H') + (Y SIZE OF 'H')/2 = Y SPACE
	MMFM	SP,A0,A2
	RETS


**************************************************************************
*								         *
* SHADOW_OFFSET - Calculate the offset used for placing the shadow	 *
* 		image.							 *
* 									 *
* A6 = Scaled [Y,X] White space characters				 *
* A11 = Ptr to current font table.					 *
* B5 = [Y,X] scale factor						 *
* Returns:								 *
* 	B6 = [Y,X] shadow offset					 *
*								         *
**************************************************************************
SHADOW_OFFSET
	MMTM	SP,A0,A2,A6
	MOVI	[2,2],A2
	SEXT	A6
	CMPI	3,A6			;Is this a small font?
	JRGT	SOFF_NORM		;BR = Not that small.
	SUBI	[1,1],A2		;Reduce shadow offset, so it looks good
SOFF_NORM
	MOVE	B5,A0
	CALLA	GET_SCALED_SIZE

	SUBXY	A2,A6
	HALFXY	A6
	ADDXY	A2,A6

	CMPI	[1,1],A6		;Sanity check
	JRGE	SOFF_OK			;BR = We are sane
       	MOVI	[1,1],A6		;Default to smallest visible difference
SOFF_OK
	MOVE	A6,B6

	MMFM	SP,A0,A2,A6
	RETS
	

**************************************************************************
*                                                                        *
* FFLAGS - PARSE THE FORMAT flags (IF THERE ARE ANY).			 *
* 	 SETS THE APPROPRIATE BITS IN THE FLAG REGISTER.		 *
* A0 = CURRENT CHARACTER FROM STRING					 *
* A8 = PTR TO STRING AFTER *A0						 *
* RETURNS:								 *
* A0 = NEXT CHARACTER AFTER flags OR SAME IF NO flags PRESENT		 *
* A4 = FLAG REGISTER WITH APPROPRIATE BITS SET OR CLEARED		 *
* A8 = PTR TO NEXT CHARACTER     					 *
* NOTE: TRASHES A14							 *
*                                                                        *
**************************************************************************
FFLAGS:
	CLR	A4		;CLEAR FLAG REGISTER TO START
FFLAG_LP:
	CMPI	'-',A0		;CHECK FOR LEFT JUSTIFY FLAG
	JRNE	FFLAGP1
	BSET	B_LJUSTIFY,A4
	BCLR	B_CJUSTIFY,A4
	JRUC	FFLAG_NXT
FFLAGP1:
	CMPI	'^',A0		;CHECK FOR CENTER JUSTIFY FLAG
	JRNE	FFLAGP2
	BSET	B_CJUSTIFY,A4
	BCLR	B_LJUSTIFY,A4
	JRUC	FFLAG_NXT
FFLAGP2:
	CMPI	'+',A0		;CHECK FOR PRINT SIGN FLAG
	JRNE	FFLAGP3
	BSET	B_PSIGN,A4
	JRUC	FFLAG_NXT
FFLAGP3:
	CMPI	',',A0		;CHECK FOR COMMA FLAG
	JRNE	FFLAGP4
	BSET	B_COMMAS,A4
	JRUC	FFLAG_NXT
FFLAGP4:
	CMPI	'#',A0		;CHECK FOR HEX PREFIX FLAG
	JRNE	FFLAGP5
	BSET	B_PHEX,A4
	JRUC	FFLAG_NXT
FFLAGP5:
*ADD NEW FLAGS HERE
	JRUC	FFLAGX
FFLAG_NXT:
	CALLR	GETCHARI
	JRUC	FFLAG_LP
FFLAGX
	RETS

**************************************************************************
*                                                                        *
* FWIDTH - GRAB THE FORMAT width FROM THE CURRENT STRING (IF PRESENT).	 *
* 	 SETS ZPRINT FLAG IS FLAG REGISTER IF NECESSARY			 *
* A0 = CURRENT CHARACTER FROM STRING					 *
* A4 = FLAG REGISTER							 *
* A8 = PTR TO STRING AFTER *A0						 *
* RETURNS:								 *
* A0 = NEXT CHARACTER AFTER width OR SAME IF NO width PRESENT		 *
* A3 = width , 0 = NO width SPECIFIED					 *
* A4 = FLAG REGISTER WITH ZPRINT FLAG SET IF NECESSARY			 *
* A8 = PTR TO NEXT CHARACTER          					 *
*                                                                        *
**************************************************************************
FWIDTH:
	PUSH	A1
	MOVK	10,A1		;DECIMAL MULTIPLIER
	CLR	A3		;FIELD width WILL BE HERE
	CMPI	'0',A0		;CHECK FOR LEADING ZERO PRINT FLAG
	JRNE	FWIDTH_LP
	BSET	B_ZPRINT,A4
	CALLR	GETCHARI	;GET THE NEXT
FWIDTH_LP:
	CMPI	'0',A0
	JRLT	FWIDTHX		;NOT A NUMBER
	CMPI	'9',A0
	JRGT	FWIDTHX		;NOT A NUMBER
	SUBI	'0',A0		;ASCII TO DECIMAL
	MPYU	A1,A3		;UP IT BY 10
	ADD	A0,A3		;AND ADD IN THE NEW
	CALLR	GETCHARI
	JRUC	FWIDTH_LP
FWIDTHX
	PULL	A1
	RETS

**************************************************************************
*                                                                        *
* FTYPE - RETURN THE FORMAT TYPE, I.E. SHORT, INT OR LONG.		 *
* A0 = PTR TO CURRENT CHARACTER TO CHECK				 *
* A8 = PTR TO STRING THAT IS BEING FORMATTED				 *
* RETURNS:								 *
* A0 = NEXT CHARACTER TO PROCESS AFTER type OR SAME IF NO TYPE SPECIFIED *
* A8 = PTR TO NEXT CHARACTER						 *
* DEFAULT RETURN IS INT							 *
*                                                                        *
**************************************************************************
FTYPE:
	MOVK	TYPE_INT,A2
FTYPE_LP:
	CMPI	'h',A0			;CHECK FOR TYPE SHORT
	JRNE	FTYPEP1
	MOVK	TYPE_SHORT,A2
	JRUC	FTYPE_NXT
FTYPEP1:
	CMPI	'l',A0			;CHECK FOR TYPE LONG
	JRNE	FTYPEP2
	MOVK	TYPE_LONG,A2
	JRUC	FTYPE_NXT
FTYPEP2:
	CMPI	'L',A0			;CHECK FOR TYPE LONG
	JRNE	FTYPEP3
	MOVK	TYPE_LONG,A2
	JRUC	FTYPE_NXT
FTYPEP3:
*ADD NEW TYPE HERE
	JRUC	FTYPEX
FTYPE_NXT:
	CALLR	GETCHARI
	JRUC	FTYPE_LP
FTYPEX
	RETS

**************************************************************************
*                                                                        *
* GETCHAR - GET NEXT CHARACTER FROM A STRING.				 *
* 	  MASKS THE HIGH 24 BITS OF THE LONG WORD.			 *
* A8 = PTR STRING							 *
* RETURNS:								 *
* 	C = CONTROL BYTE, ARGS FOLLOW, A1 = # OF BYTE ARGUMENTS		 *
*      NC = NORMAL CHARACTER OR TERMINATOR.				 *	
*	Z = BYTE IS A TERMINATOR					 *
* A0 = CHARACTER							 *
* A8 = PTR TO NEXT							 *
*                                                                        *
**************************************************************************
GETCHAR:
	MOVB	*A8,A0
	SLL	24,A0
	SRL	24,A0		;MAKE SURE THIS NUMBER IS POSITIVE
	ADDK	8,A8		;POINT TO NEXT CHARACTER
	CMPI	0,A0
	JREQ	GETCHARX	;TERMINATOR
	CMPI	' ',A0
	JRNC	GETCHARX	;SAME AS JRHS
	MOVE	A0,A1	
	DEC	A1
	SLL	3,A1
	ADDI	CONTROL_TAB,A1
	MOVB	*A1,A1		;GET NUMBER OF BYTES
	SETC	
GETCHARX:
	MOVE	A0,A0
	RETS

*
*NUMBER OF ARGUMENT BYTES FOR CONTROL CHARACTER (1-1F)
CONTROL_TAB
	.BYTE	2,2,2,4,4,4,4,4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.EVEN

**************************************************************************
*                                                                        *
* GETCHARI - GET NEXT CHARACTER, SKIP COMMAND BYTES AND ARGUMENTS.	 *
* 	   USED WITH STRGNLEN, FFLAGS, FWIDTH, FTYPE, ETC.		 *
* A8 = PTR TO STRING							 *
* RETURNS:								 *
*  Z = CHARACTER IS A TERMINATOR					 *
* A0 = CHARACTER OR TERMINATOR						 *
* A8 = PTR TO NEXT							 *
*                                                                        *
**************************************************************************
GETCHARI:
	PUSH	A1
GETCHARI_LP:
	CALLR	GETCHAR	
	JRNC	GETCHARIX		;VALID CHARACTER OR TERMINATOR
	SLL	3,A1
	ADD	A1,A8			;SKIP ARGS
	JRUC	GETCHARI_LP
GETCHARIX:
	PULL	A1	
	RETS

**************************************************************************
*                                                                        *
* GETARGI - GET NEXT ARGUMENT INDIRECT IN THE ARGUMENT LIST.		 *
*	    NEXT ARG IS A LONG PTR TO ARGUMENT TYPE.			 *
* A2 = ARGUMENT TYPE, I.E. SHORT, INT OR LONG				 *
* A6 = PTR TO ARGUMENT							 *
* RETURNS:								 *
* A6 = PTR TO NEXT ARGUMENT						 *
* A8 = UNSIGNED ARGUMENT						 *
*                                                                        *
**************************************************************************
GETARGI:
	MOVE	*A6+,A8,L	;GET THE POINTER
	CMPI	TYPE_INT,A2	;GET THE VALUE FOR PRINTING NOW		
	JRNE	GETARG1	
	MOVE	*A8,A8,W	;AH AND INT
	ZEXT	A8
	JRUC	GETARGX
GETARG1:
	CMPI	TYPE_LONG,A2
	JRNE	GETARG2
	MOVE	*A8,A8,L	;IT'S VERY LONG
	JRUC	GETARGX
GETARG2:
	MOVB	*A8,A8		;ARE YOU SMALL? SMALL! HAH! LIKE FRENCH BREAD!
	SLL	24,A8
	SRL	24,A8		;ZEXTB A8
GETARGX:
	RETS

**************************************************************************
*								         *
* PUTCARG - GET THE CONTROL ARGUMENT FROM THE ARG LIST AND TRANSFER	 *
* 	CURRENT STRING UNDER CONSTRUCTION. FIRST IT WILL TRANSFER	 *
* 	THE CONTROL BYTE.						 *
* A0 = CONTROL BYTE							 *
* A2 = ARG TYPE								 *
* A3 = INDIRECTION FLAG, IF <> 0 THEN INDIRECT ARGUMENT			 *
* A7 = PTR TO LIST UNDER CONSTRUCTION					 *
* RETURNS:								 *
* A7 NEXT BYTE IN STRING						 *
* A0 & A2 PRESERVED							 *
* A3 IS TRASHED IF ARGUMENT IS INDIRECT					 *
*								         *
**************************************************************************
PUTCARG:
	MOVB	A0,*A7
	ADDK	8,A7
	MOVE	A3,A3		;SHOULD WE HANDLE INDIRECTION
	JRNE	PUTCARGI	;BR = YES
*GET ARGUMENT IMMEADIATELY
	CMPI	TYPE_INT,A2
	JRNE	PUTCLARG
	MOVE	*A6+,*A7+,W
	JRUC	PUTCARGX
PUTCLARG:
	MOVE	*A6+,*A7+,L	;ARGUMENT IS LONG
PUTCARGX:	
	RETS
*GET ARGUMENT VIA INDIRECTION
PUTCARGI:
	MOVE	*A6+,A3,L	;GET POINTER
	CMPI	TYPE_INT,A2
	JRNE	PUTCLARGI
	MOVE	*A3+,*A7+,W
	JRUC	PUTCARGX
PUTCLARGI:
	MOVE	*A3+,*A7+,L
	JRUC	PUTCARGX

**************************************************************************
*                                                                        *
* STRNGLEN - RETURNS THE LENGTH, IN PIXELS, OF A GIVEN STRING		 *
* A8 = PTR TO STRING							 *
* A10 = [Y,X] SPACING OF STRING						 *
* A11 = PTR TO FONT TABLE						 *
* RETURNS:								 *
* A7 = LENGTH OF STRING							 *
* Z BIT SET IF LENGTH IS ZERO						 *
*                                                                        *
**************************************************************************
STRNGLEN
	MMTM	SP,B3,B5
	CLR	B3
	MOVI	SCALE_1TO1,B5
	CALLR	STRING_LENGTH
	MMFM	SP,B3,B5
	RETS

**************************************************************************
*								         *
* STRING_LENGTH - RETURNS THE LENGTH, IN PIXELS, OF A GIVEN STRING	 *
* 		THIS VERSION USES FLAGS TO DETERMINE IF WE ARE		 *
* 		UNDER FIXED SPACING CONSTRAINTS.			 *
* A8 = PTR TO STRING							 *
* A10 = [Y,X] SPACING OF STRING						 *
* A11 = PTR TO FONT TABLE						 *
* B3 = IF BIT 13 SET THEN A10 X COMPONENT IS FIXED SPACING VALUE	 *
* B5 = [Y,X] Scale factor for string.					 *
* RETURNS:								 *
* A7 = LENGTH OF STRING							 *
* Z BIT SET IF LENGTH IS ZERO						 *
*								         *
**************************************************************************
STRING_LENGTH
	MMTM	SP,A0,A1,A2,A6,A8,A10,A11
	PUSH	B6

	CLR	A7			;Clear our length counter
	CLR	A2			;We'll store our remaining space here

	CALLR	WHITE_SPACE		;Need to know the white space values

STRNLEN:				
	CALLR	GETCHAR			;Pull the next character
	JRZ	STRNLENX		;END O' STRING. FOR REAL!
	JRNC	STRNLEN0		;REAL CHARACTER

SL_CONTROL_CHARACTER
	CMPI	ASCII_CR,A0
	JREQ	STRNLENX		;O.K. THAT'S IT!

	CMPI	NEW_SPACING,A0		
	JREQ	SL_CALL_CONTROL		;BR = We need to heed the spacing
	CMPI	NEW_FONT,A0
	JRNE	SL_SKIP_ARGS		;BR = Not NEW FONT, so just skip

SL_CALL_CONTROL
	DEC	A0
	SLL	5,A0
	ADDI	T_CONTROL_CHARACTERS,A0
	MOVE	*A0,A0,L
	CALL	A0			;Call the proper Control Function.

	JRUC	STRNLEN

SL_SKIP_ARGS
	SLL	3,A1
	ADD	A1,A8	  		;SKIP ARGS
	JRUC	STRNLEN
*This is where we process a real character
STRNLEN0:
	BTST	B_FIXEDSPC,B3		;FIXED SPACING?
	JRZ	SL_SPACE_CHARACTER_SIZE	;BR = no
	ADDXY	A10,A7			;Add the fixed value
	JRUC	STRNLEN

SL_SPACE_CHARACTER_SIZE
	CMPI	' ',A0 			;LOOK FOR A SPACE, MAN
	JRNE	STRNLEN1		;BR= Not a space
	ADDXY	A6,A7			;ADD A SPACE
	CLR	A2			;Trailing spaces are the callers wish
	JRUC	STRNLEN
STRNLEN1:
	SUBI	21H,A0			;GET A BASE
	SLL	5,A0
	ADD	A11,A0			;A0 = PTR TO CORRECT CHARACTER HEADER
	MOVE	*A0,A0,L
	MOVE	*A0(ISIZE),A1,W		;GET THE ACTUAL X LENGTH
	MOVE	B5,A14			;GET X-SCALE FACTOR
	SEXT	A14
	SLL	8,A1
	DIVU	A14,A1			;Calculate the real deal
	ADDXY	A1,A7			;ADD DIGIT LENGTH
	ADDXY	A10,A7			;ADD SPACE LENGTH
	MOVE	A10,A2			;We'll subtract this if string end

	CALLR	GETCHAR			;Pull the next character
	JRC	SL_CONTROL_CHARACTER	;It seems we have a control character
	JRNZ	SL_SPACE_CHARACTER_SIZE

STRNLENX
	SUBXY	A2,A7			;Get rid of any extra space
	SLL	16,A7			;Mask any shit we may have picked up
	SRL	16,A7			;And pass return value in A7

	PULL	B6
	MMFM	SP,A0,A1,A2,A6,A8,A10,A11
	RETS

**************************************************************************
*                                                                        *
* HEXTOASC - CONVERTS A 32 BIT HEX # TO AN ASCII STRING TERMINATED	 *
* 	   BY 0 WITH COMMAS.						 *
* A8 = HEX #								 *
* RETURNS:								 *
* A8 PTR TO THE STRING							 *
*                                                                        *
**************************************************************************
HEXTOASC
	MMTM	SP,A3,A4,A14
	CLR	A3
	CLR	A4
	BSET	B_COMMAS,A4
	CALLR	HEX_TO_ASCII_DEC
	MMFM	SP,A3,A4,A14
	RETS

**************************************************************************
*                                                                        *
* HEX_TO_ASCII_DEC - FORMAT A HEXADECIMAL # TO AN DECIMAL ASCII STRING.	 *
* 	     	     USES THE flags AND width IN A4 AND A3.		 *
* A3 = width, MINIMUM # OF CHARACTERS TO OUTPUT				 *
* A4 = flags, USES: B_COMMAS - PUT COMMAS IN THE NUMBER			 *
* 		    B_ZPRINT - IF width IS NOT REACHED, FILL WITH 0's	 *
* 			       NOT SPACES.				 *
*		    B_SIGNED - PASSED NUMBER IS SIGNED			 *
*		    B_PSIGN  - PRINT SIGN IF NUMBER IS OF SIGNED TYPE    *
* A8 = HEXADECIMAL #							 *
* RETURNS:								 *
* A8 = PTR TO STRING							 *
* A3 & A4 PRESERVED							 *
*                                                                        *
**************************************************************************
HEX_TO_ASCII_DEC:
	MMTM	SP,A1,A2,A3,A5,A9
	CLR	A5			;CLR NEGATIVE FLAG
	BTST	B_SIGNED,A4
	JREQ	HEXTNOS			;NOT A SIGNED NUMBER
	MOVE	A8,A8
	JRNN	HEXTNOS			;NOT A NEGATIVE NUMBER
	NEG	A8
	INC	A5
HEXTNOS:
	CLR	A1
	CLR	A2			;COMMA COUNT
	MOVE	A1,-*SP,W		;HERE'S THE NULL TERMINATOR
        MOVK	10,A1			;DIVISOR FOR DECIMAL
	MOVE	A8,A9
HEXTASC2
	CLR	A8
	DIVU	A1,A8
	ADDI	'0',A9			;MAKE THE REMAINDER ASCII
	MOVE	A9,-*SP,W		;SAVE HERE
	DEC	A3			;DECREMENT THE WIDTH
	MOVE	A8,A9
	JRZ	HEXTASC3		;BR = DONE!

	BTST	B_COMMAS,A4
	JREQ	HEXTASC2		;BR = DON'T WORRY ABOUT COMMAS

	INC	A2
	CMPI	3,A2			;COMMA CHECK 	
	JRLO	HEXTASC2		;BR = NO COMMA

	.IF GERMAN
	MOVI	'.',A2
	.ELSE
	MOVI	',',A2
	.ENDIF

	MOVE	A2,-*SP,W		;STUFF A COMMA
	CLR	A2
	JRUC	HEXTASC2
HEXTASC3
	MOVE	A3,A3
	JRZ	HEXTASC3A		;WIDTH HAS BEEN FULFILLED
	JRN	HEXTASC3A		;THANX TI
	BTST	B_ZPRINT,A4
	JRNE	HEXTASC30		;YES, FILL width WITH ZEROS
	MOVI	' ',A2
	JRUC	HEXTASC31
HEXTASC30:
	MOVI	'0',A2
HEXTASC31:
	MOVE	A2,-*SP,W		;STUFF THE LEADER
	DSJS	A3,HEXTASC31
HEXTASC3A:
	BTST	B_SIGNED,A4
	JREQ	HEXTASC3D		;THIS IS NOT A SIGNED NUMBER
	MOVE	A5,A5
	JRNZ	HEXTASC3B		;NUMBER IS NEGATIVE
	BTST	B_PSIGN,A4
	JREQ	HEXTASC3D		;DOESN'T WANT THE SIGN PRINTED
	MOVI	'+',A2	
	JRUC	HEXTASC3C
HEXTASC3B:
	MOVI	'-',A2
HEXTASC3C:
	MOVE	A2,-*SP,W		;STUFF THE SIGN
HEXTASC3D
	MOVI	STRNGRAM,A1		;STORE HERE FOR BLOW OUT        
	MOVE	A1,A8
HEXTASC4
	MOVE	*SP+,A9,W
	MOVB	A9,*A1
	ADDK	8,A1
	MOVE	A9,A9
	JRNZ	HEXTASC4
	MMFM	SP,A1,A2,A3,A5,A9
	RETS

**************************************************************************
*                                                                        *
* HTOHXASC - CONVERT A 32 BIT HEXADECIMAL # TO A NULL TERMINATED	 *
* 	   HEXADECIMAL ASCII STRING. USES 'ABCDEF' AND NO Ox PREFIX	 *
* 	   OR COMMAS.							 *
* A8 = HEX #								 *
* RETURNS:								 *
* A8 = PTR TO ASCII HEX STRING						 *
*                                                                        *
**************************************************************************
HTOHXASC
	MMTM	SP,A3,A4,A14
	CLR	A3
	CLR	A4
	BSET	B_CAP,A4	
	CALLR	HEX_TO_ASCII_HEX
	MMFM	SP,A3,A4,A14
	RETS
	
**************************************************************************
*                                                                        *
* HEX_TO_ASCII_HEX - CONVERTS A 32 BIT HEX # TO A NULL TERMINATED	 *
* 		   ASCII STRING.					 *
* A3 = width, MINIMUM # OF CHARACTERS CONVERTED				 *
* A4 = flags, USES: B_COMMAS - PUT COMMAS IN THE NUMBER			 *
* 		  B_ZPRINT - IF width IS NOT REACHED, FILL WITH 0's	 *
* 			     NOT SPACES.				 *
* 		  B_CAP	   - USE 'ABCDEF'				 *
* 		  B_PHEX   - PREFIX WITH HEX SPECIFIER 0x OR 0X		 *
* A8 = HEX #								 *
* RETURNS:								 *
* A8 PTR TO THE STRING							 *
* A3 & A4 ARE PRESERVED							 *
*                                                                        *
**************************************************************************
HEX_TO_ASCII_HEX
	MMTM	SP,A1,A2,A3,A9
	CLR	A1
	CLR	A2			;COMMA COUNT
	MOVE	A1,-*SP,W		;HERE'S THE NULL TERMINATOR
	MOVK	16,A1			;DIVISOR FOR HEX
	MOVE	A8,A9
HEXTASCH2
	CLR	A8
	DIVU	A1,A8
	ADDI	'0',A9			;MAKE THE REMAINDER ASCII
	CMPI    '9',A9			;IS IT IN A-F RANGE?
	JRLS    HHH1
	BTST	B_CAP,A4		;ARE WE IN CAPITAL MODE
	JRNE	HHH0			;YES
	ADDI	'a' - ':',A9		;MAKE alpha!
	JRUC	HHH1
HHH0:
	ADDI    'A' - ':',A9		;MAKE ALPHA!
HHH1:
	DEC	A3			;DECREMENT THE WIDTH
	MOVE	A9,-*SP,W		;SAVE HERE
	MOVE	A8,A9
	JRZ	HEXTASCH3		;BR = DONE!
	INC	A2
	CMPI	3,A2			;COMMA CHECK 	
	JRLO	HEXTASCH2		;BR = NO COMMA
*
*        SEE IF WE'RE DOING COMMAS
*
	BTST	B_COMMAS,A4		;COMMAS?
	JREQ	HEXTASCH2		;NOPE....IGNORE!

	.IF GERMAN
	MOVI	'.',A2
	.ELSE
	MOVI	',',A2
	.ENDIF

	MOVE	A2,-*SP,W		;STUFF A COMMA
	CLR	A2
	JRUC	HEXTASCH2
HEXTASCH3:
	MOVE	A3,A3
	JRZ	HEXTASCH3A		;WIDTH HAS BEEN FULFILLED
	JRN	HEXTASCH3A		;THANX TI
	BTST	B_ZPRINT,A4
	JRNE	HEXTASCH30		;YES, FILL width WITH ZEROS
	MOVI	' ',A2
	JRUC	HEXTASCH31
HEXTASCH30:
	MOVI	'0',A2
HEXTASCH31:
	MOVE	A2,-*SP,W		;STUFF THE LEADER
	DSJS	A3,HEXTASCH31
HEXTASCH3A:
*CHECK FOR 0x PREFIX
	BTST	B_PHEX,A4
	JREQ	HEXTASCH3D		;NO PREFIX NECESSARY
	BTST	B_CAP,A4
	JRNE	HEXTASCH3B		;PRINT A CAPITAL X
	MOVI	'x',A2
	JRUC	HEXTASCH3C
HEXTASCH3B:
	MOVI	'X',A2
HEXTASCH3C:
	MOVE	A2,-*SP,W
	MOVI	'0',A2
	MOVE	A2,-*SP,W
HEXTASCH3D:
*DUMP THE STRING AND PASS IT BACK
	MOVI	STRNGRAM,A1		;STORE HERE FOR BLOW OUT        
	MOVE	A1,A8
HEXTASCH4:
	MOVE	*SP+,A9,W
	MOVB	A9,*A1
	ADDK	8,A1
	MOVE	A9,A9
	JRNZ	HEXTASCH4
	MMFM	SP,A1,A2,A3,A9
	RETS

**************************************************************************
*                                                                        *
* BCDTOASC - CONVERT A 32 BIT HEXADECIMAL # TO A NULL TERMINATED	 *
* 	   HEXADECIMAL ASCII STRING. COMMAS AND LEAD ZERO BLANKING	 *
* 	   ARE ASSERTED.						 *
* A8 = BCD #								 *
* RETURNS:								 *
* A8 = PTR TO ASCII HEX STRING						 *
*                                                                        *
**************************************************************************
BCDTOASC
	MMTM	SP,A3,A4,A14
	CLR	A3
	CLR	A4
	BSET	B_COMMAS,A4	
	CALLR	BCD_TO_ASCII_DEC
	MMFM	SP,A3,A4,A14
	RETS

**************************************************************************
*                                                                        *
* BCD_TO_ASCII_DEC - CONVERTS A BCD NUMBER INTO A NULL TERMINATED	 *
* 		   ASCII DECIMAL STRING.				 *
* A3 = width, MINIMUM # OF CHARACTERS CONTAINED IN THE STRING		 *
* A4 = flags, USES: B_COMMAS - PUT COMMAS IN THE NUMBER			 *
* 		  B_ZPRINT - IF width IS NOT REACHED, FILL WITH 0's	 *
* 			     NOT SPACES.				 *
* A8 = BCD #								 *
* RETURNS:								 *
* A8 PTR TO THE STRING							 *
* A3 & A4 ARE PRESERVED							 *
*                                                                        *
**************************************************************************
BCD_TO_ASCII_DEC:
	MMTM	SP,A1,A2,A3,A5,A9
	MOVE	A8,A1
	MOVK	1,A2
	MOVE	A2,A5		;DIGIT COUNT
	SRL	4,A1		;WE WILL ALWAYS PRINT THE FIRST DUDE
BCDZLP:
	MOVE	A1,A9	
	SRL	4,A1		;SLIDE DIGIT OFF THE END
	INC	A2		;KNOCK UP ANOTHER DIGIT
	SLL	28,A9
	SRL	28,A9
	JREQ	BCDZ		;IT'S A ZERO
	MOVE	A2,A5		;UPDATE VALID DIGIT COUNT
BCDZ:
	CMPI	8,A2
	JRLO	BCDZLP		;MORE DIGITS TO CHECK
*O.K. LET'S STRING THIS BITCH
	CLR	A2			;COMMA COUNT
	MOVE	A2,-*SP,W		;HERE'S THE NULL TERMINATOR
BCDCLP:
	MOVE	A8,A9
	SRL	4,A8			;SHIT THIS DIGIT
	SLL	28,A9
	SRL	28,A9			;ISOLATE
	ADDI	'0',A9			;MAKE ASCII
	CMPI	'9',A9
	JRLS	BCDISNUM		;IT'S A VALID NUMBER.
	MOVI	' ',A9			;SUBSTITUTE A SPACE FOR ERROR
BCDISNUM:
	MOVE	A9,-*SP,W		;PUSH ON MY MAN
	DEC	A3			;DECREMENT width
	DEC	A5			;DIGIT COUNT
	JRZ	BCDDONE			;WE HAVE FINISHED
*COMMA SHIT
	INC	A2
	CMPI	3,A2			;COMMA CHECK 	
	JRLO	BCDCLP			;BR = NO COMMA
	BTST	B_COMMAS,A4		;PRINT COMMAS?
	JREQ	BCDCLP			;NOPE....IGNORE!

	.IF GERMAN
	MOVI	'.',A2
	.ELSE
	MOVI	',',A2
	.ENDIF

	MOVE	A2,-*SP,W		;STUFF A COMMA
	CLR	A2
	JRUC	BCDCLP
BCDDONE:
	MOVE	A3,A3
	JRZ	BCDXFER			;WIDTH HAS BEEN FULFILLED
	JRN	BCDXFER 		;THANX TI
	BTST	B_ZPRINT,A4
	JRNE	BCDZP1			;YES, FILL width WITH ZEROS
	MOVI	' ',A2
	JRUC	BCDZP2
BCDZP1:
	MOVI	'0',A2
BCDZP2:
	MOVE	A2,-*SP,W		;STUFF THE LEADER
	DSJS	A3,BCDZP2
BCDXFER:
*DUMP THE STRING AND PASS IT BACK
	MOVI	STRNGRAM,A1		;STORE HERE FOR BLOW OUT        
	MOVE	A1,A8
BCDXFER_LP:
	MOVE	*SP+,A9,W
	MOVB	A9,*A1
	ADDK	8,A1
	MOVE	A9,A9
	JRNZ	BCDXFER_LP

	MMFM	SP,A1,A2,A3,A5,A9
	RETS

**************************************************************************
*                                                                        *
*          L_MESS                                                        *
*                                                                        *
*          A8 POINTS AT MESS_MAC FOLLOWED BY MESSAGE TEXT.               *
*             POP ALL REGGIES LEAVING A8 POINTING AT TEXT.               *
*             AND JUMP TO THE TEXT PROCESSOR!                            *
*                                                                        *
*          THE MMFM POPS THE ROUTINE TO CALL INTO A1.                    *
*                                                                        *
*          YOU ***MUST*** USE JSRP TO GET HERE.                          *
*                                                                        *
**************************************************************************
L_MESS_LOOP
	ADDI	8,A8			;PUSH BEYOND THIS BYTE
L_MESS
	ADDI	0FH,A8			;IF IT ENDS IN OTHER THAN ZERO..
*					;KICK TO NEXT WORD (I.E. .EVEN)
	SRL	4,A8
	SLL	4,A8			;MASK FRACTIONAL WORD

	MMFM	A8,A0,A1,A5,A9,A10,A11	;LOAD UP REGGIES FROM A8.
	MOVE	A0,B1			;STORE THE OID
	CLR	A0			;MAKE SURE WE DON'T SLEEP

****	JSRPR	A1			;JSRP TO THE ROUTINE
	JSRP	PRINTF

	MOVB	*A8,A0			;CHECK NEXT BYTE 0=DONE...1=MORE.
	JRNZ	L_MESS_LOOP
	RETP
         
**************************************************************************
*                                                                        *
*          LM_SETUP                                                      *
*                                                                        *
*          THIS IS CALLED TO SETUP THE WORLD FOR A STRING                *
*          OPERATION, BUT NOT PHYSICALLY MAKE THE CALL.                  *
*                                                                        *
*          THIS ALLOWS TWEAKING OF REGGIES BEFORE THE CALL.              *
*                                                                        *
*          LM_FINIS                                                     *
*                                                                        *
*          THIS IS CALLED ONCE THE MODIFICATIONS ARE MADE!               *
*                                                                        *
*                                                                        *
**************************************************************************
LM_SETUP
	MMFM	A8,A0,A1,A5,A9,A10,A11		;LOAD UP REGGIES FROM A8.
	MOVE	A0,B1
	CLR	A0				;NO SLEEPING
	RETS
LM_FINIS
	JUMP	A1				;THIS RUNS ROUTINE AND

**************************************************************************
*								         *
* LM_PRINTF - THIS ROUTINE COMBINES LM_SETUP WITH PRINTF, USE IF YOU	 *
* 		DON'T NEED TO TWEAK THE REGISTERS			 *
* A8 = MESS_MAC FOLLOWED BY STRING.					 *
* NOTE: CALL WITH JSRP							 *
*								         *
**************************************************************************
LM_PRINTF:
	CALLR	LM_SETUP
	JRUC	PRINTF

**************************************************************************
*                                                                        *
* CLRTEXT - CLEAR ALL TEXT ON THE OBJECT LIST.				 *
*                                                                        *
**************************************************************************
CLRTEXT
	MMTM	SP,A0,A1
	MOVI	OID_TEXT,A0
	CALLA	KILOBJ_ALL
	MMFM	SP,A0,A1
	RETS
	
**************************************************************************
*								         *
* PROC_TEXT - DISPATCH PROCESS TO MAKE TEXT APPEAR ON THE SCREEN.	 *
* 		TEXT WILL BE DELETED AFTER DURATION.			 *
* NOTE: CREATE WITH PID_INDE SO THAT IS WILL RUN DURING BUYIN.		 *
* A8 = PTR TO STRING							 *
* A10 = DURATION							 *
* A11 = OID OF TEXT							 *
*								         *
**************************************************************************
PROC_TEXT
	MMTM	A12,A10,A11
	JSRP	LM_PRINTF
	MMFM	A12,A10,A11
PT_WAIT_LP
	SLEEP	1
	MOVE	@BUYNOW,A14,W
	JRNZ	PT_DEL_NOW
	DSJS	A10,PT_WAIT_LP
PT_DEL_NOW
	MOVE	A11,A0
	CALLA	KILOBJ_ALL
	DIE

	.DATA


**************************************************************************
*                                                                        *
* 	FONT TABLES STARTING AT ASCII $21				 *
*                                                                        *
**************************************************************************
*
*5 POINT FONT.
*
RD5FONT
	.LONG  FONT5EXC,FONT5APOS,FONT5EXC,FONT5EXC,FONT5EXC,FONT5EXC
	.LONG  FONT5APOS,FONT5EXC,FONT5EXC,FONT5EXC,FONT5EXC
	.LONG  FONT5EXC,FONT5MIN,FONT5PER,FONT5SLA,FONT50,FONT51
	.LONG  FONT52,FONT53,FONT54,FONT55,FONT56,FONT57,FONT58,FONT59
	.LONG  FONT5COLON,FONT5EXC,FONT5EXC,FONT5EXC,FONT5EXC
	.LONG  FONT5EXC,FONT5EXC
	.LONG  FONT5A,FONT5B,FONT5C,FONT5D,FONT5E,FONT5F,FONT5G,FONT5H
	.LONG  FONT5I,FONT5J,FONT5K,FONT5L,FONT5M,FONT5N,FONT5O,FONT5P
	.LONG  FONT5Q,FONT5R,FONT5S,FONT5T,FONT5U,FONT5V,FONT5W,FONT5X
	.LONG  FONT5Y,FONT5Z
	.LONG  FONT5GERA,FONT5GERB,FONT5GERO,FONT5GERU,FONT5GERA,FONT5GERB
	.LONG  FONT5A,FONT5B,FONT5C,FONT5D,FONT5E,FONT5F,FONT5G,FONT5H
	.LONG  FONT5I,FONT5J,FONT5K,FONT5L,FONT5M,FONT5N,FONT5O,FONT5P
	.LONG  FONT5Q,FONT5R,FONT5S,FONT5T,FONT5U,FONT5V,FONT5W,FONT5X
	.LONG  FONT5Y,FONT5Z
	.LONG  FONT5GERO,FONT5GERU,FONT5TM,FONT5REG,FONT5COPY

*
*7 POINT FONT.
*
RD7FONT
	.LONG  FONT8EXC,FONT8APOS,FONT8NUM,FONT8DOLL,FONT8PERC,FONT8AND
	.LONG  FONT8APOS,FONT8LPAREN,FONT8RPAREN,FONT8ASTR,FONT8PLUS
	.LONG  FONT8COM,FONT8MIN,FONT8PER,FONT8SLA
	.LONG  FONT80,FONT81,FONT82,FONT83,FONT84,FONT85,FONT86,FONT87,FONT88
	.LONG  FONT89
	.LONG  FONT8COL,FONT8SMCOL,FONT8EXC,FONT8EQL,FONT8EXC,FONT8QUEST
	.LONG  FONT8EXC
	.LONG  FONT8A,FONT8B,FONT8C,FONT8D,FONT8E,FONT8F,FONT8G,FONT8H,FONT8I
	.LONG  FONT8J,FONT8K,FONT8L,FONT8M,FONT8N,FONT8O,FONT8P,FONT8Q,FONT8R
	.LONG  FONT8S,FONT8T,FONT8U,FONT8V,FONT8W,FONT8X,FONT8Y,FONT8Z
	.LONG  FONT8GERA,FONT8GERB,FONT8GERO,FONT8GERU,FONT8GERA,FONT8GERB
	.LONG  FONT8A,FONT8B,FONT8C,FONT8D,FONT8E,FONT8F,FONT8G,FONT8H,FONT8I
	.LONG  FONT8J,FONT8K,FONT8L,FONT8M,FONT8N,FONT8O,FONT8P,FONT8Q,FONT8R
	.LONG  FONT8S,FONT8T,FONT8U,FONT8V,FONT8W,FONT8X,FONT8Y,FONT8Z
	.LONG  FONT8GERO,FONT8GERU,FONT8TM,FONT8REG,FONT8COPY

*
*11 POINT FONT. Loads is missing (3/11/94)
*
RD11FONT
	.LONG  FONT11exclamtio,FONT11dash,FONT11dash,FONT11money,FONT11percent
	.LONG  FONT11also,FONT11apost,FONT11parenth1,FONT11parenth2,FONT11asterisk
	.LONG  FONT11dash,FONT11comma,FONT11dash,FONT11period,FONT11slash
	.LONG  FONT110,FONT111,FONT112,FONT113,FONT114,FONT115,FONT116
	.LONG  FONT117,FONT118,FONT119
	.LONG  FONT11colon,FONT11semicolon,FONT11dash,FONT11dash,FONT11dash
	.LONG  FONT11question,FONT11percent
	.LONG  FONT11A,FONT11B,FONT11C,FONT11D,FONT11E,FONT11F,FONT11G,FONT11H
	.LONG  FONT11I,FONT11J,FONT11K,FONT11L,FONT11M,FONT11N,FONT11O,FONT11P
	.LONG  FONT11Q,FONT11R,FONT11S,FONT11T,FONT11U,FONT11V,FONT11W,FONT11X
	.LONG  FONT11Y,FONT11Z
	.LONG  FONT11dash,FONT11dash,FONT11dash,FONT11dash
	.LONG  FONT11dash,FONT11apost
	.LONG  FONT11a,FONT11b,FONT11c,FONT11d,FONT11e,FONT11f,FONT11g,FONT11h
	.LONG  FONT11i,FONT11j,FONT11k,FONT11l,FONT11m,FONT11n,FONT11o,FONT11p
	.LONG  FONT11q,FONT11r,FONT11s,FONT11t,FONT11u,FONT11v,FONT11w,FONT11x
	.LONG  FONT11y,FONT11z
	.LONG  FONT11dash,FONT11dash,FONT5TM,FONT5REG,FONT5COPY
	.LONG  FONT11dash,FONT11dash,FONT11dash,FONT11dash,FONT11dash
	.LONG  FONT11dash

*
*15 POINT FONT. @ is missing (10/20/88)
*
RD15FONT

	.LONG  FONT15exclamati,FONT15dash,FONT15dash,FONT15money,FONT15percent
	.LONG  FONT15and,FONT15apost,FONT15parenth1,FONT15parenth2,FONT15asterisk
	.LONG  FONT15dash,FONT15comma,FONT15dash,FONT15period,FONT15slash
	.LONG  FONT150,FONT151,FONT152,FONT153,FONT154,FONT155,FONT156
	.LONG  FONT157,FONT158,FONT159
	.LONG  FONT15colon,FONT15semicolon,FONT15dash,FONT15equal,FONT15GREATER
	.LONG  FONT15question,FONT15percent
	.LONG  FONT15A,FONT15B,FONT15C,FONT15D,FONT15E,FONT15F,FONT15G,FONT15H
	.LONG  FONT15I,FONT15J,FONT15K,FONT15L,FONT15M,FONT15N,FONT15O,FONT15P
	.LONG  FONT15Q,FONT15R,FONT15S,FONT15T,FONT15U,FONT15V,FONT15W,FONT15X
	.LONG  FONT15Y,FONT15Z
	.LONG  FONT15dash,FONT15dash,FONT15dash,FONT15dash
	.LONG  FONT15dash,FONT15apost
	.LONG  FONT15a,FONT15b,FONT15c,FONT15d,FONT15e,FONT15f,FONT15g,FONT15h
	.LONG  FONT15i,FONT15j,FONT15k,FONT15l,FONT15m,FONT15n,FONT15o,FONT15p
	.LONG  FONT15q,FONT15r,FONT15s,FONT15t,FONT15u,FONT15v,FONT15w,FONT15x
	.LONG  FONT15y,FONT15z
	.LONG  FONT15dash,FONT15dash,FONT5TM,FONT5REG,FONT5COPY
	.LONG  FONT15dash,FONT15dash,FONT15dash,FONT15dash,FONT15dash
	.LONG  FONT15dash

;	.LONG  FONT15EXC,FONT15QUOTE,FONT15POUND,FONT15DOLL,FONT15PCT
;	.LONG  FONT15AND,FONT15SQUOTE,FONT15LPAREN,FONT15RPAREN,FONT15ASTERIX
;	.LONG  FONT15PLUS,FONT15COMMA,FONT15MINUS,FONT15PER,FONT15SLASH
;	.LONG  FONT150,FONT151,FONT152,FONT153,FONT154,FONT155,FONT156
;	.LONG  FONT157,FONT158,FONT159
;	.LONG  FONT15COLON,FONT15SEMI,FONT15LESS,FONT15EQUAL,FONT15GREATER
;	.LONG  FONT15QUEST,FONT15EXC
;	.LONG  FONT15A,FONT15B,FONT15C,FONT15D,FONT15E,FONT15F,FONT15G,FONT15H
;	.LONG  FONT15I,FONT15J,FONT15K,FONT15L,FONT15M,FONT15N,FONT15O,FONT15P
;	.LONG  FONT15Q,FONT15R,FONT15S,FONT15T,FONT15U,FONT15V,FONT15W,FONT15X
;	.LONG  FONT15Y,FONT15Z
;	.LONG  FONT15GERA,FONT15GERB,FONT15GERO,FONT15GERU
;	.LONG  FONT15GERa,FONT15GERB	
;	.LONG  FONT15a,FONT15b,FONT15c,FONT15d,FONT15e,FONT15f,FONT15g,FONT15h
;	.LONG  FONT15i,FONT15j,FONT15k,FONT15l,FONT15m,FONT15n,FONT15o,FONT15p
;	.LONG  FONT15q,FONT15r,FONT15s,FONT15t,FONT15u,FONT15v,FONT15w,FONT15x
;	.LONG  FONT15y,FONT15z
;	.LONG  FONT15GERo,FONT15GERu,FONT15TM,FONT15REG,FONT15COPY
;     	.LONG  FONT15SP,FONT15RUB,FONT15END,FONT15RQUOTE,FONT15ENGPOUND
;	.LONG  FONT15CR
;


*
*20 POINT FONT. Much is missing (10/25/89)
*
RD20FONT
	.LONG  FONT20exclamati,FONT20dash,FONT20dash,FONT20money,FONT20percent
	.LONG  FONT20and,FONT20apost,FONT20parenth1,FONT20parenth2,FONT20asterisk
	.LONG  FONT20dash,FONT20comma,FONT20dash,FONT20period,FONT20slash
	.LONG  FONT200,FONT201,FONT202,FONT203,FONT204,FONT205,FONT206
	.LONG  FONT207,FONT208,FONT209
	.LONG  FONT20colon,FONT20semicolon,FONT20dash,FONT20equal,FONT20dash
	.LONG  FONT20question,FONT20percent
	.LONG  FONT20A,FONT20B,FONT20C,FONT20D,FONT20E,FONT20F,FONT20G,FONT20H
	.LONG  FONT20I,FONT20J,FONT20K,FONT20L,FONT20M,FONT20N,FONT20O,FONT20P
	.LONG  FONT20Q,FONT20R,FONT20S,FONT20T,FONT20U,FONT20V,FONT20W,FONT20X
	.LONG  FONT20Y,FONT20Z
	.LONG  FONT20dash,FONT20dash,FONT20dash,FONT20dash
	.LONG  FONT20underscor,FONT20apost	
	.LONG  FONT20a,FONT20b,FONT20c,FONT20d,FONT20e,FONT20f,FONT20g,FONT20h
	.LONG  FONT20i,FONT20j,FONT20k,FONT20l,FONT20m,FONT20n,FONT20o,FONT20p
	.LONG  FONT20q,FONT20r,FONT20s,FONT20t,FONT20u,FONT20v,FONT20w,FONT20x
	.LONG  FONT20y,FONT20z
	.LONG  FONT20dash,FONT20dash,FONT20arrow,FONT20Ibig,FONT20end
	.LONG  FONT20dash,FONT20dash,FONT20dash,FONT20dash,FONT20dash
	.LONG  FONT20dash


;	.LONG  FONT20EXC,FONT20QUOTE,FONT20POUND,FONT20DOLL,FONT20PCT
;	.LONG  FONT20AND,FONT20SQUOTE,FONT20LPAREN,FONT20RPAREN,FONT20ASTERIX
;	.LONG  FONT20PLUS,FONT20COM,FONT20MIN,FONT20PER,FONT20SLA
;	.LONG  FONT200,FONT201,FONT202,FONT203,FONT204,FONT205,FONT206
;	.LONG  FONT207,FONT208,FONT209
;	.LONG  FONT20COL,FONT20SEMI,FONT20EXC,FONT20EQUAL,FONT20EXC
;	.LONG  FONT20QUEST,FONT20AT
;	.LONG  FONT20A,FONT20B,FONT20C,FONT20D,FONT20E,FONT20F,FONT20G
;	.LONG  FONT20H,FONT20I,FONT20J,FONT20K,FONT20L,FONT20M,FONT20N
;	.LONG  FONT20O,FONT20P,FONT20Q,FONT20R,FONT20S,FONT20T,FONT20U
;	.LONG  FONT20V,FONT20W,FONT20X,FONT20Y,FONT20Z
;	.LONG  T2FONT20GERA,T2FONT20GERB,T2FONT20GERO,T2FONT20GERU
;	.LONG  T2FONT20GERA,T2FONT20GERB
;	.LONG  FONT20A,FONT20B,FONT20C,FONT20D,FONT20E,FONT20F,FONT20G
;	.LONG  FONT20H,FONT20I,FONT20J,FONT20K,FONT20L,FONT20M,FONT20N
;	.LONG  FONT20O,FONT20P,FONT20Q,FONT20R,FONT20S,FONT20T,FONT20U
;	.LONG  FONT20V,FONT20W,FONT20X,FONT20Y,FONT20Z
;	.LONG  T2FONT20GERO,T2FONT20GERU,FONT20TM,FONT20REG,FONT20COPY


**************************************************************************
*								         *
* 		  SPECIAL CHARACTER DEFINITIONS				 *
*								         *
**************************************************************************
FONT8BLK:
	.WORD	4,4,2,-2
	.LONG	IROM

FONT8UNDERLINE:
	.WORD	6,1,0,-9
	.LONG	IROM	

	.IF GERMAN
SUFFIX_S:
	.STRING	"E"
	.ELSE
SUFFIX_S:
	.STRING	"S"
	.ENDIF

SUFFIX_NULL:
	.BYTE	0
	.EVEN

**************************************************************************
*								         *
* 		SOUND TABLE FOR BEEPS AND CLICKS THAT ARE		 *
* 		ATTACHED TO CHARACTER OUTPUT.				 *
*								         *
**************************************************************************
TEXT_SOUND_TAB
	.LONG	TEXT_TTY_SND, TEXT_TTY1_SND

TEXT_TTY_SND
	.WORD	0F2E0H,1,080CCH,0	;MOST OBNOXIOUS TTY SOUND
TEXT_TTY1_SND
	.WORD	0F2E0H,1,080EBH,0	;TOLERABLE TTY CLICK
	
TEXTPAL:
	.word	 45
	.word	00H,07C00H,06739H,01FH,035ADH,077A0H,0741AH,03A0H
	.word	00H,06739H,04E73H,035ADH,01CE7H,00H,00H,01523H
	.word	01543H,01963H,01984H,01DA4H,01DC3H,01DC4H,021C3H,021C4H
	.word	01DE3H,01DE4H,021E3H,021E4H,02205H,02625H,02645H,02A66H
	.word	02A86H,02EA6H,02EC7H,032E7H,03307H,03727H,03748H,03B47H
	.word	03B48H,03767H,03768H,03B67H,03B68H

	.END



