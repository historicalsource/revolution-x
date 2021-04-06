	.MLIB	"GXMACS.LIB"
	.FILE	"GXSND.ASM"
	.TITLE	"<<< GENERATION X ---- SOUND PROCESSOR >>>"
	.WIDTH	132
	.OPTION	B,D,L,T
	.MNOLIST

**************************************************************************
*								         *
* 	COPYRIGHT (C) 1992 MIDWAY MANUFACTURING COMPANY.		 *
* 		       ALL RIGHTS RESERVED.				 *
*								         *
**************************************************************************

	.INCLUDE	"GX.INC"		;Game equates

***** Symbols in this file

	.DEF	LINT2_SERVICE, SOUND_RX, SEND_RAW_SOUND

***** Symbols in GXUART.ASM

	.REF	INITIALIZE_UART

***** Symbols in gxmenu.asm
	.ref	draw_volume_scale1


;	.BSS	UART_AVG,16
	.BSS	UART_UNAVAILABLE,16
	.BSS	SOUND_RX,16

	.TEXT

**************************************************************************
*								         *
* 		    Generation X - Sound Processor			 *
* 									 *
* The CHANNELS are defined as follows:					 *
* 									 *
* 		Channel #0	MUSIC	(She watch)			 *
* 		Channel #1	PLAYER 1				 *
* 		Channel #2	PLAYER 2				 *
* 		Channel #3	FX					 *
* 									 *
* 	Note: PLAYER 3 sounds will use an empty player 1 or 2		 *
* 		channel. If both channels are taken, they will		 *
* 		start to alternate between player channels.		 *
* 									 *
* Each channel is a seperate entity in terms of timing and priority.	 *
* It is the programmers responsibilty to ensure that the X-unit Channel	 *
* used for any given sound matches the track # used on the sound	 *
* board.								 *
* 									 *
* To INITIALIZE the sound board use:					 *
* 									 *
* 			SNDRES - Reset board with checksum dings	 *
* 			QSNDRST - Reset board with No dings		 *
* 									 *
* 			CLRSNDDB - Zeros the X-unit sound processor	 *
* 				   database.				 *
* 									 *
* To OPERATE the sound processor:					 *
* 									 *
* 			Call SNDPRC every 16msec from the Exec loop.	 *
* 									 *
* 									 *
* Each sound call defined with a script.				 *
* 									 *
* SOUND Script Format:							 *
* 									 *
* 	.word	PRIORITY, TIME, SOUND CODE, 0				 *
* 									 *
* 	The bits 12-15 of every word describe the word Command Type.	 *
* 									 *
* 	Command Types:							 *
* 									 *
* 	   0	= TIME - 0000 TTTT TTTT TTTT				 *
* 									 *
* 			Set 0000-0FFF x 16msec duration.		 *
* 	   .								 *
* 	   .								 *
* 	   .								 *
* 									 *
* 	   4	= SOUND - 0100 SSSS SSSS SSSS				 *
* 									 *
* 		  	Make SOUND and immediately process rest		 *
* 			of script.					 *
* 									 *
* 	   5	= SOUND - 0101 SSSS SSSS SSSS				 *
* 									 *
* 	   		Make Background SOUND and immediately		 *
* 			process rest of script.				 *
* 									 *
* 	   6	= SOUND - 0110 SSSS SSSS SSSS				 *
* 									 *
* 		  	Make SOUND on any open track and immediately	 *
* 			process rest of script.				 *
* 	   .								 *
* 	   .								 *
* 	   .								 *
* 									 *
* 	   8	= SOUND - 1000 SSSS SSSS SSSS				 *
* 									 *
* 		  	Make SOUND then wait for current TIME x 16 msec	 *
* 		  	before processing rest of script.		 *
* 									 *
* 	   9	= SOUND - 1001 SSSS SSSS SSSS				 *
* 									 *
* 		  	Make Background SOUND then wait for current	 *
* 		  	TIME x 16 msec before processing rest of script. *
* 									 *
* 	   A	= SOUND - 1010 SSSS SSSS SSSS				 *
* 									 *
* 		  	Make SOUND on any open track then wait for	 *
* 			current TIME x 16 msec before processing rest	 *
* 			of script.					 *
* 	   .								 *
* 	   .								 *
* 	   .								 *
* 									 *
* 	   D	= PRIORITY - Non-Interruptible Sound			 *
* 									 *
* 	  		   - 1101 NNNN PPPP PPPP			 *
* 									 *
* 			NNNN = CHANNEL #(0-F);				 *
* 			PP   = PRIORITY (00-FF), FF=HIGHEST.		 *
* 									 *
* 			Set current priority and channel.		 *
* 									 *
* 	   E	= PRIORITY - Interruptible by higher priority only.	 *
* 									 *
* 	  		   - 1110 NNNN PPPP PPPP			 *
* 									 *
* 			NNNN = CHANNEL #(0-F);				 *
* 			PP   = PRIORITY (00-FF), FF=HIGHEST.		 *
* 									 *
* 			Set current priority and channel.		 *
* 									 *
* 	   F	= PRIORITY - Normal, interruptible by equal or higher.	 *
* 									 *
* 	  		   - 1111 NNNN PPPP PPPP			 *
* 									 *
* 			NNNN = CHANNEL #(0-F);				 *
* 			PP   = PRIORITY (00-FF), FF=HIGHEST.		 *
* 									 *
* 			Set current priority and channel.		 *
* 									 *
* 	A given sound script can contain as many PRIORITY, TIME and	 *
* 	SOUND codes as it wants and in any order.  The requirement	 *
* 	is that the first three entries of any given script		 *
* 	are in the order PRIORITY, TIME, SOUND.				 *
* 									 *
* 	Example 1:							 *
* 									 *
* 	SND1:	.WORD	0F0D0H,0010H,08088H,0				 *
* 									 *
* 		Make sound 88H on channel zero with priority D0H	 *
* 		and not allow it to be interrupted for 10H x 16msec	 *
* 		except by a sound of equal or higher priority on	 *
* 		channel 0.						 *
* 									 *
* 									 *
* 	Example 2:							 *
* 									 *
* 	SND2:	.WORD	0F311H,0020H,08044H,08027H,0			 *
* 									 *
* 		Setup channel 3 for a priority of 11H to make		 *
* 		one sound 44h, wait 20H x 16 msec, then make		 *
* 		sound 27H for a duration of 20H x 16 msec. If		 *
* 		another sound comes in during this at equal		 *
* 		or higher priority, then the script is			 *
* 		cancelled.						 *
* 									 *
* 									 *
* To process a sound script use:					 *
* 									 *
* 			ONESND - Process script once.			 *
* 			SNDLD  - To process script more than once.	 *
*								         *
**************************************************************************

SNDPRI	.SET	0  	;UHW Priority (00=LOWEST, FF=HIGHEST)
SNDTIM	.SET	010h	;UHW Current Sound Duration 000-7FFF
SNDTMR	.SET	020h	;UHW Timer 
SNDST	.SET	030h	;UHL Address of Sound Script start
SNDPTR	.SET	050h	;UHL Ptr to current entry of script being processed
SNDREP	.SET	070h	;UHW Repeat count
SNDBGND	.EQU	080H	;UHW Current Background sound on this track
SNDBGACT .EQU	090H	;UHW Flag to indicate Background sound is playing
SNDOFFST .EQU	0A0H	;UHW Offset to add to physical sound # for correct track
SNDVOL	.EQU	0B0H	;UHL Volume of this sound, this includes channel code
SNDVOL_LEVEL .equ 0c0h	;UHW This is just the level word
SNDRES2	.EQU	0D0H	;UHL Reserved LONG
SNDRES3	.EQU	0F0H	;UHW Reserved WORD

*
*NOTE: IF YOU CHANGE SNDSIZ, MAKE SURE ANY CODE THAT USES IT AS A DIVISOR 
*	PERFORMS THE CORRECT OP. CURRENTLY IT IS A POWER OF 2 SO SRL IS USED.
*
SNDSIZ	.SET	100h
CHANNEL_MULT_SHIFT	.EQU	8	;Shift this many to mult/divide SNDSIZ

SL_CHANNEL	.EQU	21	;SHIFTS REQUIRED TO ISOLATE CHANNEL NUMBER
SR_CHANNEL	.EQU	29
M_CHANNEL	.EQU	700H	;Mask for channel bits

NCHAN		EQU	4	;DECLARE NUMBER OF ALLOWED CHANNELS

P1_CHANNEL	.EQU	1	;Player 1 uses this channel to make sounds
P2_CHANNEL	.EQU	2	;Player 2 uses this channel to make sounds

CHANNEL_0_OFFCODE	.EQU	3E3H	;Kill code for Channel 0 only.
					;It is assumed that the kill codes
					;for the other tracks follow in seq.

	.IF USING_UART

VOLUME_BASE_CODE	.EQU	0AB55H	;Base code for setting track volume
TRACK_VOLUME_INC	.EQU	00100H	;Increment by this for next track

FULL_VOLUME	.EQU	00FFH	;This would be full volume

MASTER_VOLUME_CODE	.EQU	0AA55H	;Code for setting the master volume

	.ELSE

VOLUME_BASE_CODE	.EQU	055ABH	;Base code for setting track volume
TRACK_VOLUME_INC	.EQU	00001H	;Increment by this for next track

FULL_VOLUME	.EQU	0FF00H	;This would be full volume

MASTER_VOLUME_CODE	.EQU	055AAH	;Code for setting the master volume

	.ENDIF


FACTORY_VOLUME	.EQU	3FH	;This is the factory volume level.  It will
				;be set at powerup, for poweron tests.  As
				;soon as CMOS is validated, the volume will
				;be set according to the value stored.  If
				;CMOS is, for some reason, invalid then this
				;will be the default level.

FACTORY_MINVOL	.EQU	1FH	;This is the lowest volume allowed. It is 
				;factory adjustable.
MIN_VOLUME	.EQU	0	;Minimum allowable volume level
MAX_VOLUME	.EQU	255	;Maximum allowable volume level

VOLDN_SWITCH	.EQU	11	;Switch # of volume down
VOLUP_SWITCH	.EQU	12	;Switch # of volume up

B_NINTEQ	.EQU	12	;Bit position for NON-INTERRUPTIBLE by EQUAL
B_NINT		.EQU	13	;Bit position for NON-INTERRUPTIBLE bit

*THESE STROBE EQUATES ARE FOR THE SOUND CARD
RESETBIT	EQU	0100H	;THIS IS THE SOUND RESET BIT
SOUNDBIT	EQU	0200H	;THIS IS THE SOUND BOARD STROBE


	.BSS	SNDSTR,NCHAN*SNDSIZ	;RESERVE STORAGE AREA
	.BSS	SNDEND,0		;END OF SOUND PROCESSOR RAM

UART_QUEUE	EQU	0	;Using Queue interrupt method to Transmit

	.IF	UART_QUEUE

	.BSS	SOUNDQ,128*(6*8)	;Sound interrupt queue
	.BSS	SOUNDQ_END,0		;Ptr for end of sound queue
	.BSS	SOUNDQ_HD,32		;Sound queue Head ptr
	.BSS	SOUNDQ_TL,32		;Sound queue Tail ptr
	.BSS	SOUNDQ_MAX,32

	.ENDIF


P1_CHAN_RAM	.EQU	SNDSTR+P1_CHANNEL*SNDSIZ	;Ptr to P1 RAM
P2_CHAN_RAM	.EQU	SNDSTR+P2_CHANNEL*SNDSIZ	;Ptr to P2 RAM


**************************************************************************
*                                                                        *
* CLRSNDDB - CLEAR THE SOUND PROCESSOR DATA BASE			 *
*                                                                        *
**************************************************************************
CLRSNDDB
	MMTM	SP,A0,A1,A2
	MOVI	SNDSTR,A1	
	CLR	A0
CLRSDBL
	MOVE	A0,*A1+,W
	CMPI	SNDEND,A1
	JRLO	CLRSDBL

	MOVI	SNDSTR,A1
	MOVK	NCHAN,A0
	MOVI	VOLUME_BASE_CODE,A2
CSDB_VOL
	MOVE	A2,*A1(SNDVOL),W
	ADDI	SNDSIZ,A1
	ADDI	TRACK_VOLUME_INC,A2
	DSJS	A0,CSDB_VOL


	MMFM	SP,A0,A1,A2
	RETS

	.IF UART_QUEUE
**************************************************************************
*								         *
* 	CLR_SOUNDQ							 *
* 									 *
* 	Reset the sound queue.						 *
* 									 *
* 	Note: Trashes A14						 *
*								         *
**************************************************************************
CLR_SOUNDQ
	MOVIM	SOUNDQ,@SOUNDQ_HD,L
	MOVIM	SOUNDQ,@SOUNDQ_TL,L
	CLRM	@SOUNDQ_MAX,L
	RETS
	.ENDIF

**************************************************************************
*								         *
* ONESND - MAKE ONE SOUND						 *
* A0 = PTR TO SOUND SCRIPT (0 = NO SOUND, JUST RETURN)			 *
* RETURNS:								 *
* A0 = SAME								 *
* 	 Z = SOUND CALL WAS MADE SUCCESSFULLY				 *
* 	NZ = SOUND CALL WAS NOT MADE					 *
*								         *
**************************************************************************
ONESND:
	mmtm	SP,A1,A10
	MOVE	A0,A0		;DID HE CALL WITH A NULL?
	JRZ	ONESND_FAIL	;BR = YES
	.IF DEBUG
	MOVE	A0,A1
	SLL	28,A1
	SRL	28,A1
	JRNZ	$
	.ENDIF
	MOVK	1,A1
	movi	FULL_VOLUME,A10
	callr	SNDLD
ONESND_X:
	mmfm	SP,A1,A10
	rets
ONESND_FAIL
	CLRZ
	JRUC	ONESND_X

**************************************************************************
*								         *
* ONESND_Z - Make a sound using the GSP Sound Processor			 *
* 	 based on the current Z position of the object.			 *
* 									 *
* A0 = Ptr to Sound Script.						 *
* A8 = Ptr to object from which to reference Z position			 *
* Returns:								 *
* 	 Z = Sound call made successfully, A0 = Unchanged		 *
* 	NZ = Sound call not made, A0 = Unchanged			 *
*								         *
**************************************************************************
Z_DIV	.EQU	60000H/256

ONESND_Z:
	mmtm	SP,A1,A10

	MOVE	A0,A0		;DID HE CALL WITH A NULL?
	JRZ	OSZ_Fail	;BR = YES

	move	*A8(OZVAL),A1,L
	move	@ZBASE,A14,L
	sub	A14,A1			;Get world relative Z-position
;	SUBI	ZMAX_REAL,A1		;Get rid of anything that is not visible
	JRNN	OSZ_COOL
	CLR	A1
	JRUC	OSZ_DOIT
OSZ_COOL
	MOVI	Z_DIV,A14
	DIVU	A14,A1

;	.IF DEBUG
;	CMPI	255,A1			;Did we go out of bounds?
;	LOCKON	HI			;LOCK = Yes
;	.ENDIF
	CMPI	255,A1
	JRLS	OSZ_DOIT		;BR = This sound is inbounds
	MOVI	255,A1			;Artificial max
	
OSZ_DOIT

	.IF USING_UART

	MOVE	A1,A10
	NOT	A10
	SLL	24,A10
	SRL	24,A10
	SLL	8,A1
	ADD	A1,A10

	.ELSE

	MOVE	A1,A10
	NOT	A1
	SLL	8,A1
	ADD	A1,A10

	.ENDIF

 	movk	1,A1
	callr	SNDLD
OSZ_X
	mmfm	SP,A1,A10
	rets
OSZ_Fail
	CLRZ
	jruc	OSZ_X

**************************************************************************
*								         *
* PLAYER_SND - Pick the correct sound entry, of the given table, to	 *
* 	     use based on what is free at the moment.			 *
* 	     First entry of Table is the sound script for the		 *
* 	     first player channel...					 *
* 	     Sound will be made on any one of the free player		 *
* 	     channels.  If nothing is free, then see ya, would'nt	 *
* 	     wanna be ya.						 *
* 									 *
* A0 = Ptr to table of player sound call entries			 *
* Returns								 *
* 	 Z = Sound was made, A0 = Ptr to sound script used.		 *
* 	NZ = Sound not made, A0 = undefined				 *
*								         *
**************************************************************************
PLAYER_SND
	CALLR	PLAYER_SND_CORE
	JRNZ	PS_FAIL
	JRUC	ONESND
PS_FAIL
	RETS

**************************************************************************
*								         *
* 	PLAYER_SND_Z							 *
* 									 *
* 	Same as PLAYER_SND except adjusts volume according to		 *
* 	Z position of given object.					 *
* 									 *
* 	A0 = Ptr to table of player sound call entries			 *
* 	A8 = Ptr to object from which to reference Z position		 *
* 									 *
* 	Returns:							 *
* 									 *
* 	 	Z = Sound was made, A0 = Ptr to sound script used.	 *
* 	       NZ = Sound not made, A0 = undefined			 *
*								         *
**************************************************************************
PLAYER_SND_Z
	CALLR	PLAYER_SND_CORE
	JRNZ	PSZ_FAIL
	JRUC	ONESND_Z
PSZ_FAIL
	RETS


*
*Routine to be used by PLAYER_SND routines, returns the correct
*sound script to play.
*
PLAYER_SND_CORE
	mmtm	SP,A1,A3,A4,A5,A6

	move	*A0,A14,L		
	move	*A14,A5,W		;Grab priority word for this sound

	sll	24,A5
	srl	24,A5			;Isolate the priority, we need it!

	movi	PLAYER_CHANNEL_TAB,A3	;We need this for the loop
*
*Scan for channel with the lowest priority that is less than or equal to the
* priority of the new sound to make.
*
	clr	A6
	move	*A3+,A4,L		;Get the channel RAM
PS_Free_Loop
	move	*A4(SNDPRI),A14,W	;Grab the priority running
	sll	24,A14			;Extract current PRIORITY
	srl	24,A14
	cmp	A14,A5			;Can we take this channel?
	jrlt	PS_Next_Chan		;BR = No
	move	A14,A5			;New lowest priority
	move	A4,A6			;And channel to take
PS_Next_Chan
	move	*A3+,A4,L		;Look for another
	jrnn	PS_Free_Loop		;BR = There is another to look for
	move	A6,A4
	jrnz	PS_Use_Channel
	CLRZ				;Flag this failure
	mmfm	SP,A1,A3,A4,A5,A6
	rets
*
*Channel RAM Address in A4
*
PS_Use_Channel
	.IF DEBUG
	cmpi	P1_CHAN_RAM,A4
	jreq	PUC_Debug_OK
	cmpi	P2_CHAN_RAM,A4
	jreq	PUC_Debug_OK
	jruc	$
PUC_Debug_OK
	.ENDIF
	
	subi	P1_CHAN_RAM,A4
	srl	CHANNEL_MULT_SHIFT-5,A4	;We now have a table index

	add	A4,A0
	move	*A0,A0,L		;Grab script address

	SETZ
	mmfm	SP,A1,A3,A4,A5,A6
	RETS


*
*Table of channel RAM for Player's. -1 indicates, no channel allocated.
*Once a -1 is hit, no more scanning occurs.
*
PLAYER_CHANNEL_TAB
	.LONG	P1_CHAN_RAM,P2_CHAN_RAM,-1,-1

**************************************************************************
*								         *
* SNDLD - SOUND LOADER							 *
* A0=SOUND TABLE ADDRESS						 *
* A1=REPEAT COUNT							 *
* A10=Volume level							 *
* RETURNS								 *
* 	 Z = SOUND WAS MADE						 *
* 	NZ = SOUND CALL DID NOT MAKE IT					 *
*								         *
**************************************************************************
*
*SOUND DESCRIPTION= PRIORITY,TIME,SOUND CODE,(PRIORITY),(TIME),(SOUND CODE),0
*SOUND ENDS IN ZERO
*PRIORITY WORD = 1111INNNPPPPPPPP; I=1=NON-INTERRUPTABLE
*NNN=CHANNEL #(0-7);
*PP=PRIORITY (00-FF), FF=HIGHEST.
*TIME WORD =TTTT (0000-7FFF X 16MS).
*SOUND WORD =8SSS SSS=SOUND CODE(000-FFF).
*SOUND WORD =4SSS SSS=SOUND CODE (ZERO TIME SOUND CODE)
*
SNDLD:
	MMTM	SP,A0,A1,A2,A3,A4,A5,A6,A7

	MOVE	@SOUNDSUP,A4,W		;Are all sounds currently suppressed?
	JRNZ	SNDLDX			;BR = Yes, make no sounds

	MOVE	@VOLUME_SET,A4,W	;Is the volume set correctly?
	JRZ	SNDLD_FAIL		;BR = No, then make no sounds

	MOVE	*A0,A3,W		;Get PRIORITY word
	MOVE	A3,A2

	SLL	SL_CHANNEL,A3		;Extract CHANNEL bits
	SRL	SR_CHANNEL,A3

	move	A3,A6			;Keep RAW channel number here

	sll	CHANNEL_MULT_SHIFT,A3	;And multiply to form index

	clr	A7			;Set default sound offset

	SEXT	A10			;Make sure A10 is col'correct

**************************************************************************
*								         *
* Use this code if SNDSIZE is not a power of 2				 *
* 	SRL	SR_CHANNEL,A3						 *
* 	MOVI	SNDSIZ,A5						 *
* 	MPYU	A3,A5							 *
* 	ADDI	SNDSTR,A5 		;Get RAM CHANNEL address.	 *
* 	MOVE	A5,A3							 *
*								         *
**************************************************************************

	addi	SNDSTR,A3 		;Get RAM CHANNEL address.

	move	*A3(SNDPRI),A5,W	;Get current PRIORITY
	jrz	SNDLD_Load_It		;BR = Nothing running 
	btst	B_NINT,A5		;Is sound NON-INTERRUPTABLE ?
	jreq	SNDLD_Ck_Bgnd		;BR = Yes, we cannot make our sound

	move	A5,A4
	move	A2,A14			;Extract new PRIORITY
	sll	24,A14
	srl	24,A14
	sll	24,A4			;Extract current PRIORITY
	srl	24,A4
	cmp	A14,A4			;New one Greater or Equal?
	jrhi	SNDLD_Ck_Bgnd		;BR = No, we cannot make new sound
	jrlo	SNDLD_Load_It		;BR = New sound is higher, do it

*Priorities are equal here
	move	*A3(SNDVOL_LEVEL),A14,W	;Who's got the Volume pumped
	cmp	A14,A10			;New sound or Current
	.IF USING_UART

	JRLO	SNDLD_Load_It		;BR = New, so load it
	JRHI	SNDLD_Ck_Bgnd		;BR = Current, so keep it

	.ELSE

	jrhi	SNDLD_Load_It		;BR = New, so load it
	jrlo	SNDLD_Ck_Bgnd		;BR = Current, so keep it

	.ENDIF

*Volumes and priorities are equal here
	btst	B_NINTEQ,A5		;Interruptible by Equal?		
	jreq	SNDLD_Ck_Bgnd		;BR = NON-INTERRUPTABLE BY EQUAL

*
*Direct load feature
*A0 = Ptr to beginning of sound script
*A2 = Correct priority word
*A3 = Ptr to channel RAM
*A7 = Sound offset for track skip
*A10 = Volume word (sign extended)
SNDLD_Load_It
	move	A0,A4
	move	A3,A0			;RAM CHANNEL address needs to be here
	move	A2,*A0(SNDPRI),W	;Store the new priority
	move	A4,*A0(SNDST),L 	;Store script start address
	addk	16,A4
	move	A4,*A0(SNDPTR),L	;Store current script position
	move	A1,*A0(SNDREP)		;Pass the repeat count
	move	A7,*A0(SNDOFFST),W	;Set the sound offset for track skip
	move	A10,*A0(SNDVOL_LEVEL),W	;Store the volume

	callr	SNDUPD			;Start the sound
	SETZ				;And return success
	jruc	SNDLDX
*
*We have failed the priority test, but let's see if there's a
*background sound at work here.
*A0 = Ptr to head of Script.
*A2 = Priority word of new script
*A3 = Ptr to Channel RAM address.
*A6 = Current channel #
*A10 = Volume word (sign extended)
SNDLD_Ck_Bgnd
	move	*A0(20h),A4,W		;Grab the first sound call
	move	A4,A5
	zext	A5
	srl	12,A5
	cmpk	5,A5
	jreq	SNDLD_Load_Bgnd
	cmpk	9,A5
	jrne	SNDLD_Ck_Skipper	;Return failure. The Z bit is clear.
SNDLD_Load_Bgnd
	move	A4,*A3(SNDBGND),W	;Store the Background sound
	CLRM	*A3(SNDBGACT),W		;Make sure we know it's in-active
	SETZ				;And we made it
	jruc	SNDLDX			;So get the fuck out
*
*This is not a Bgnd sound, so let's see if we can skip tracks.
*A0 = Ptr to head of Script
*A2 = Priority word of new script
*A3 = Ptr to channel RAM address.
*A5 = Upper nybble of priority word.
*A6 = Current channel #
*A10 = Volume word (sign extended)
SNDLD_Ck_Skipper
	cmpk	6,A5			;Check if this is a track skipping sound
	jreq	SNDLD_Skip_Tracks
	cmpk	0Ah,A5
	jrne	SNDLDX			;Return failure. The Z bit is clear.
SNDLD_Skip_Tracks
	movi	SNDSTR+SNDSIZ,A3	;Time to search for unused channel.
	movk	1,A7		 	;Start with channel 1. 0 is for music.
	move	A2,A5
	sll	24,A5
	srl	24,A5			;Grab the priority of the new sound
SST_Loop
	cmp	A6,A7			;Same channel we just tried?
	jreq	SST_Next

	move	*A3(SNDPRI),A4,W	;Check out the channel
	jrz	SST_LOAD		;BR = This one is open

	btst	B_NINT,A4		;Is sound NON-INTERRUPTABLE ?
	jreq	SST_Next		;BR = Yes, we cannot take this track

	MOVE	A4,A14			;We need to strip just the priority
	sll	24,A14
	srl	24,A14			;Zero priority sound?
	cmp	A14,A5			;Can this sound take it?
	JRHI	SST_LOAD		;BR = Yes, go right ahead, take it.
	JRLO	SST_Next		;BR = No, uh uh, sans

*Priorities are equal here
	move	*A3(SNDVOL_LEVEL),A14,W	;Who's got the Volume pumped
	cmp	A14,A10			;New sound or Current
	.IF USING_UART

	JRLO	SST_LOAD		;BR = New, so load it
	JRHI	SST_Next		;BR = Current, so keep it

	.ELSE

	jrhi	SST_LOAD		;BR = New, so load it
	jrlo	SST_Next		;BR = Current, so keep it

	.ENDIF

*Volumes and priorities are equal here
	btst	B_NINTEQ,A4		;Interruptible by Equal?		
	jreq	SST_Next		;BR = NON-INTERRUPTABLE BY EQUAL

*We found a channel to skip to.	
SST_LOAD
	sub	A6,A7			;Calculate the proper sound offset
	andni	M_CHANNEL,A2
	sll	SR_CHANNEL-SL_CHANNEL,A6
	add	A6,A2			;Make us look pretty for the rest
	jruc	SNDLD_Load_It

SST_Next
	addi	SNDSIZ,A3
	addk	1,A7			;Get next channel
	cmpk	NCHAN,A7		;Are we out of them?
	jrlo	SST_Loop		;BR = No, get next
SNDLD_FAIL
	CLRZ				;Return failure
SNDLDX:
	MMFM	SP,A0,A1,A2,A3,A4,A5,A6,A7
	RETS

**************************************************************************
*								         *
* SNDPRC - Sound processor loop.  Called every 16 msec. to update	 *
* 		each sound channel.					 *
*								         *
**************************************************************************
SNDPRC:	
	MOVI	SNDSTR,A0
	MOVK	NCHAN,A1
SNDLP0:
	MOVE	*A0(SNDTMR),A2 	;CHECK TIMER
	JREQ	SNDPLP		;EQUAL, INACTIVE CHANNEL
	DEC	A2
	MOVE	A2,*A0(SNDTMR)	;DEC TIME
	JRNE	SNDPLP		;NO TIMEOUT
	CALLR	SNDUPD		;UPDATE SOUND
SNDPLP:
	ADDI	SNDSIZ,A0
	DSJS	A1,SNDLP0
	RETS

*
*UPDATE SOUND
*A0=POINTER TO SOUND CHANNEL RAM
*
SNDUPD:
SNDUP0:
        MOVE	*A0(SNDPTR),A2,L	;GET POINTER TO ROM TABLE
SNDUP1:	
	MOVE	*A2+,A3			;GET NEXT ROM TABLE ENTRY
	JREQ	SNDUP5			;END OF SOUND

	move	A3,A4
	zext	A4
	srl	12,A4			;Get just the definition label
	sll	5,A4
	addi	SNDUPD_Jump_Tab,A4
	move	*A4,A4,L
	jump	A4	
*
*Do priority word
*
Snd_Upd_Priority
	move	A3,*A0(SNDPRI)		;Store the new priority
	jruc	SNDUP1			;Go get the next word
*
*Do a "No Time" Background sound
*
Snd_Upd_Sound_Notime_Bgnd
	callr	Load_Bgnd_Snd
	jruc	Snd_Upd_Sound_Notime_Finish
*	
*Do a "No Time" sound
*
Snd_Upd_Sound_Notime
	clrm	*A0(SNDBGACT),W		;Clear the background sound
Snd_Upd_Sound_Notime_Finish
	move	*A0(SNDOFFST),A14,W
	add	A14,A3			;Offset the sound for channel skip
	move	*A0(SNDVOL),A5,L	;Get the volume code
	callr	SNDSND			;Send the sound code
	jruc	SNDUP1			;And immediately process rest
*
*Do a Normal Timed Background sound
*
Snd_Upd_Sound_Bgnd
	callr	Load_Bgnd_Snd
	jruc	Snd_Upd_Sound_Finish
*
*Do a normal Timed sound
*
Snd_Upd_Sound
	clrm	*A0(SNDBGACT),W		;Clear the background sound
Snd_Upd_Sound_Finish
	move	*A0(SNDOFFST),A14,W
	add	A14,A3			;Offset the sound for channel skip
	move	*A0(SNDVOL),A5,L	;Get the volume code
	callr	SNDSND			;Send the sound code
	move	*A0(SNDTIM),*A0(SNDTMR)	;Update the timer
	move	A2,*A0(SNDPTR),L	;Store the script ptr
	rets				;And time it
*
*Store a new TIMER value
*
Snd_Upd_Time
	move	A3,*A0(SNDTIM)	
	move	A3,*A0(SNDTMR)		;Set TIMER value
	jruc	SNDUP1			;And go get next

*CHECK FOR REPEATERS
SNDUP5:
	MOVE	*A0(SNDREP),A3	;CHECK REPEAT COUNT
	DEC	A3
	MOVE	A3,*A0(SNDREP)
	JREQ	SNDUP6		;ALL OVER
	MOVE	*A0(SNDST),*A0(SNDPTR)
	JRUC	SNDUP0		;START SOUND OVER
*Sound is over, clear channel and attempt to restart the Background sound
SNDUP6:
	clr	A14
	move	A14,*A0(SNDPRI),L	;Clear the Priority
	move	A14,*A0(SNDST),L	;Clear the Script ptr
	MOVE	A14,*A0(SNDTMR),W	;Clear the timer just in case
	move	*A0(SNDBGACT),A14,W	;Is the sound already running?
	jrnz	SNDUPX			;BR = Yes, do nothing
	move	*A0(SNDBGND),A3,W	;Get the sound
	jrz	SNDUPX			;Br = There isn't one
	callr	Load_Bgnd_Snd		;Load it
	MOVE	*A0(SNDVOL),A5,L	;get the volume code
	callr	SNDSND			;And make it
SNDUPX:
	rets

**************************************************************************
*								         *
* Load_Bgnd_Snd - Load a new background sound on a given channel.	 *
* 	     	Meant for use with SNDUPD and SNDLD only.		 *
* A0 = Ptr to channel RAM						 *
* A3 = Sound code							 *
* Returns								 *
* 	A3 = Sound code in bits 0-11, rest are cleared			 *
*								         *
**************************************************************************
Load_Bgnd_Snd
	move	A0,A14
	subi	SNDSTR,A14
	srl	CHANNEL_MULT_SHIFT,A14	;Divide to get channel number
	addi	CHANNEL_0_OFFCODE,A14
	sll	20,A3			;Strip off unnecessary bits.
	srl	20,A3
	jrz	LBS_Bgnd_Off		;BR = This is the all off code.
	cmp	A14,A3			;Is this the channel off code?
	jrne	LBS_Bgnd_Stuff		;BR = No.
LBS_Bgnd_Off
	clr	A14		   	;Clear the sound.
	move	A14,*A0(SNDBGND),W	
	move	A14,*A0(SNDBGACT),W
	jruc	LBS_X
LBS_Bgnd_Stuff
	move	A3,*A0(SNDBGND),W	;Store the Background sound
	MOVKM	1,*A0(SNDBGACT),W	;Make sure we know it's active
LBS_X
	MOVIM	FULL_VOLUME,*A0(SNDVOL_LEVEL),W	;Reset to full volume
	rets

*
*Jump table for SNDUPD
*
SNDUPD_Jump_Tab
	.long	Snd_Upd_Time		;0 = New TIMER
	.long	Snd_Upd_Sound		;1 = Not defined
	.long	Snd_Upd_Sound		;2 = Not defined
	.long	Snd_Upd_Sound		;3 = Not defined
	.long	Snd_Upd_Sound_Notime	;4 = "No Time" sound
	.long	Snd_Upd_Sound_Notime_Bgnd ;5 = "No Time" Background sound
	.long	Snd_Upd_Sound_Notime	;6 = "No Time" sound
	.long	Snd_Upd_Sound		;7 = Not defined
	.long	Snd_Upd_Sound		;8 = Timed sound
	.long	Snd_Upd_Sound_Bgnd	;9 = Timed Background sound
	.long	Snd_Upd_Sound		;A = Timed sound
	.long	Snd_Upd_Sound		;B = Not defined
	.long	Snd_Upd_Sound		;C = Not defined
	.long	Snd_Upd_Priority	;D = New Priority - NON-INTERRUPTIBLE
	.long	Snd_Upd_Priority	;E = New Priority - NON-INT by EQUAL
	.long	Snd_Upd_Priority	;F = Set new Priority


**************************************************************************
*								         *
* 	SNDSND								 *
* 									 *
* 	Send a code to the sound board. This is the lowest level,	 *
* 	so everybody should use this routine to send.			 *
* 									 *
* 	A3 = Sound Code in bits 0-11					 *
* 	A5 = Volume level [Level,Track code]				 *
* 									 *
* 	Returns:							 *
* 		Nothing							 *
* 									 *
* 	Note: Trashes A14						 *
* 	      Bytes are swapped in A5 to make things faster		 *
*								         *
**************************************************************************
	.align
SNDSND:
	.IF (USING_UART & UART_QUEUE)

	MMTM	SP,A0,A3

	GETST	A0
	DINT				;No fucky with queue now

	MOVE	@SOUNDQ_HD,A14,L
	MOVE	A5,*A14+,L		;Bytes 0 - 3 on the queue

	SLL	20,A3			;Strip useless bits
	RL	4,A3
	MOVB	A3,*A14			;Byte 4 on the queue
	ADDK	8,A14
	RL	8,A3
	MOVB	A3,*A14			;Byte 5 on the queue
	ADDK	8,A14

	CMPI	SOUNDQ_END,A14		;Did we overflow?
	JRLO	NO_SOUNDQ_OVERFLOWa	;BR = No
	MOVI	SOUNDQ_END,A14		;Default on end in case

NO_SOUNDQ_OVERFLOWa

	MOVE	A14,@SOUNDQ_HD,L	;Stuff the ptr back again

	MOVKM	1,@UART+UART_IMR,W	;Ensure that the interrupt is enabled

	PUTST	A0

	MMFM	SP,A0,A3

	.ELSE

	MMTM	SP,A0,A3,A4

	MOVX	A5,A4
	CALLR	SEND_RAW_SOUND
	MOVY	A5,A4
	SRL	16,A4
	CALLR	SEND_RAW_SOUND
	MOVE	A3,A4

	SLL	20,A4			;Strip off unnecessary bits.
	RL	4,A4
	MOVE	A4,A3
	SRL	16,A3
	ADD	A3,A4
	CALLR	SEND_RAW_SOUND

	MMFM	SP,A0,A3,A4

	.ENDIF

	RETS

**************************************************************************
*								         *
* 	SEND_RAW_SOUND							 *
* 									 *
* 	Send a sound code to the sound board at the most basic level.	 *
* 									 *
* 	A4 = 16 bit sound code to send.					 *
* 									 *
* 	Note: Trashes A0,A4,A6,A14					 *
* 	      Bytes are swapped in A4 if using the UART			 *
*								         *
**************************************************************************
SEND_RAW_SOUND

	.IF (USING_UART & UART_QUEUE)

	PUSH	A0
	GETST	A0
	DINT				;No fucky with queue now

	MOVE	@SOUNDQ_HD,A14,L
	MOVE	A4,*A14+,W		;Bytes 0 - 1 on the queue

	CMPI	SOUNDQ_END,A14		;Did we overflow?
	JRLO	NO_SOUNDQ_OVERFLOWb	;BR = No
	MOVI	SOUNDQ_END,A14		;Default on end in case

NO_SOUNDQ_OVERFLOWb

	MOVE	A14,@SOUNDQ_HD,L	;Stuff the ptr back again

	MOVKM	1,@UART+UART_IMR,W	;Ensure that the interrupt is enabled

	PUTST	A0
	PULLQ	A0

	.ELSEIF	USING_UART

;	MMTM	SP,A2,A3

	MOVE	@UART_UNAVAILABLE,A14,W
	JRNZ	SRS_Tx_SKIP

	PUSH	A5

	MOVI	UART,A0

	MOVI	20000,A5		;Load time-out value
SRS_Tx_WAIT
	MOVE	*A0(UART_IMR),A14,W	;Read ISR register from UART
	BTST	0,A14			;Is it ready to transmit?
	JRNZ	SRS_Tx_FIRST
	DSJS	A5,SRS_Tx_WAIT		;Click down another for timeout

	MOVKM	1,@UART_UNAVAILABLE,W	;UART went south

SRS_Tx_FIRST
	MOVE	A4,*A0(UART_THR),W	;Send the High byte first

;	MOVE	@HCOUNT,A2,W

	MOVI	20000,A5		;Load time-out value
SRS_Tx_WAIT2
	MOVE	*A0(UART_IMR),A14,W	;Read ISR register from UART
	BTST	0,A14			;Is it ready to transmit?
	JRNZ	SRS_Tx_SECOND
	DSJS	A5,SRS_Tx_WAIT2		;Click down another for timeout

	MOVKM	1,@UART_UNAVAILABLE,W	;UART went south

SRS_Tx_SECOND

;	MOVE	@HCOUNT,A14,W

;	SUB	A2,A14
;	JRGE	SRS_TIMING_OK

;	ADDI	1F9H,A14

;SRS_TIMING_OK

;	srl	3,A14
;	move	@UART_AVG,A3,W
;	move	A3,A2
;	srl	3,A2
;	sub	A2,A3
;	add	A3,A14
;	move	A14,@UART_AVG,W

	RL	24,A4
	MOVE	A4,*A0(UART_THR),W	;Then send the Low byte

	PULLQ	A5

SRS_Tx_SKIP
;	MMFM	SP,A2,A3

	.ELSE

	MOVE	A4,A0			;Keep copy for second byte to send.

	SLL	16,A0			;Strip off unnecessary bits.
	SRL	24,A0			;High byte gets sent first.

	ADDI	0FF00H&~SOUNDBIT,A0	;Send HIGH byte.
	MOVE	A0,@SOUND,W

	MOVI	(8*MICRO_SECOND)/2,A14	;Line delay
	DSJS	A14,$

	ORI	SOUNDBIT,A0		;Pull up strobe to complete the send.
	MOVE	A0,@SOUND,W

	MOVI	(8*MICRO_SECOND)/2,A14	;Line delay
	DSJS	A14,$

	SLL	24,A4			;Strip off shit
	SRL	24,A4			;Keep the low byte.

	ADDI	0FF00H&~SOUNDBIT,A4	;Send the LOW byte.
	MOVE	A4,@SOUND,W

	MOVI	(8*MICRO_SECOND)/2,A14	;Line delay
	DSJS	A14,$

	ORI	SOUNDBIT,A4		;Strobe up, and we're done.
	MOVE	A4,@SOUND,W

	MOVI	(8*MICRO_SECOND)/2,A14	;Line delay
	DSJS	A14,$

	.ENDIF

	RETS

**************************************************************************
*								         *
* 	LINT2_SERVICE							 *
* 									 *
* 	Interrupt service for all of the user of LINT2.			 *
* 									 *
* 	As of 10/28/93 the only thing serviced is the sound UART.	 *
*								         *
**************************************************************************
LINT2_SERVICE
	MMTM	SP,A0,A1

	MOVE	@UART+UART_IMR,A0,W
	BTST	2,A0
	JRZ	L2_X			;BR = Not a receive interrupt

	MOVE	@UART+UART_THR,@SOUND_RX,W
	
	.IF UART_QUEUE
	JRUC	L2_X

	MOVE	@SOUNDQ_TL,A0,L		;Grab some tail

	MOVB	*A0,A1			;Get the byte to Tx
	MOVE	A1,@UART+UART_THR,W	;And send it
	ADDK	8,A0			;Increment ptr
	MOVE	A0,@SOUNDQ_TL,L		;Update Q tail ptr

	MOVE	@SOUNDQ_HD,A1,L		;Did we catch up?
	SUB	A0,A1			
	JRNE	L2_X			;BR = No, more bytes to send

	MOVE	A1,@UART+UART_IMR,W	;Clear the interrupt

	MOVI	SOUNDQ,A0
	MOVE	A0,@SOUNDQ_HD,L		;And reset the queue
	MOVE	A0,@SOUNDQ_TL,L
	.ENDIF
L2_X
	MMFM	SP,A0,A1

	RETI

**************************************************************************
*								         *
* 	SNDRES								 *
* 									 *
* 	Full sound board reset.  Checksum dings are reported.		 *
* 									 *
* 	Must be called with process system initialized or 		 *
* 	the board volume will not be set correctly and this		 *
* 	could be dangerous.						 *
* 									 *
* NOTE: TRASHES A14							 *
*								         *
**************************************************************************
SNDRES:
	MMTM	SP,A0,A1,A7,A8,A13

	.IF USING_UART

	GETST	A0
	DINT

	ORIM	SND_RESET<<8,@SYSCOPY,W	;Tug on sound board reset line
	SRL	8,A14
	MOVE	A14,@SYSCTRL1,W		;And really assert it here

	PUTST	A0

	MSECWT	10			;Wait for sound board to catch it

	GETST	A0
	DINT

	ANDNIM	SND_RESET<<8,@SYSCOPY,W	;Release the reset line
	SRL	8,A14
	MOVE	A14,@SYSCTRL1,W		;And really release it here

	PUTST	A0

	.ELSE

	GETST	A14
	DINT
	MOVE	@SOUND_COPY,A0,W
	ANDNI	RESETBIT,A0
	MOVE	A0,@SOUND_COPY,W
	MOVE	A0,@SOUND,W
	PUTST	A14

	MOVI	(10*MICRO_SECOND)/2,A0	;WAIT FOR SOUND BOARD TO CATCH

	DSJS	A0,$	

	GETST	A14
	DINT
	MOVE	@SOUND_COPY,A0,W
	ORI	RESETBIT|SOUNDBIT,A0
	MOVE	A0,@SOUND_COPY,W
	MOVE	A0,@SOUND,W
	PUTST	A14

	MOVI	(1*MICRO_SECOND)/2,A0	;SETTLE TIME
	DSJS	A0,$

	.ENDIF

	MOVI	10*60,A8		;Delay this much before resetting
	CREATE	PID_VOLRESET,PROC_RESET_VOLUME

	CLRM	@VOLUME_SET,W		;Mark the volume as not being set
	MOVE	A14,@SOUND_RX,W

	.IF UART_QUEUE

	CALLR	CLR_SOUNDQ		;Clear out the sound queue

	.ENDIF

	.IF USING_UART

	CALLA	INITIALIZE_UART		;Initialize the UART

	.ENDIF

	MOVI	PID_TFADE,A0
	CALLA	KILLPROC_ALL		;Kill the track fader if it exists

	MMFM	SP,A0,A1,A7,A8,A13

	JRUC	CLRSNDDB		;Blow out the data base


**************************************************************************
*                                                                        *
* QSNDRST - QUIET SOUND RESET, NO DIAGNOSTIC DONGERS			 *
*                                                                        *
**************************************************************************
QSNDRST
	MMTM	SP,A0,A3,A4,A5
	CALLR	SNDRES		;RESET THE BOARD

	MSECWT	50000		;The dong takes so long

	.IF USING_UART

	CLR	A4
	MOVE	A4,@UART_UNAVAILABLE,W	;Default to UART available

	MOVI	20000,A5		;Load time-out value

	MOVI	UART,A0
QS_Tx_WAIT
	MOVE	*A0(UART_IMR),A14,W	;Read ISR register from UART
	BTST	0,A14			;Is it ready to transmit?
	JRNZ	QS_Tx_BYTE1		;BR = Yes
	DSJS	A5,QS_Tx_WAIT		;Click down another for timeout

	MOVKM	1,@UART_UNAVAILABLE,W	;The UART is fucked

QS_Tx_BYTE1
	MOVE	A4,*A0(UART_THR),W	;Send the High byte first

	.ELSE
	
	MOVIM	SOUNDBIT|RESETBIT,@SOUND,W

	MOVI	(1*MICRO_SECOND)/2,A14	;DIVIDE BY 2 FOR 2 CYCLE DSJS IN CACHE
	DSJS	A14,$

	MOVIM	RESETBIT,@SOUND,W

	MOVI	(1*MICRO_SECOND)/2,A14	;DIVIDE BY 2 FOR 2 CYCLE DSJS IN CACHE
	DSJS	A14,$

	MOVIM	SOUNDBIT|RESETBIT,@SOUND,W

	MOVI	(1*MICRO_SECOND)/2,A14	;DIVIDE BY 2 FOR 2 CYCLE DSJS IN CACHE
	DSJS	A14,$

	.ENDIF

	MOVI	PID_VOLRESET,A0
	CALLA	KILLPROC_ALL

	MSECWT	10000			;Wait for the freaky sound reset

	CALLR	SET_VOLUME

;	CALLA	EXISTP_ALL		;Get the delayed volume set routine

;	LOCKON	Z			;This should not happen

;	MOVK	1,A14
;	MOVE	A14,*A0(PA8),L		;Make it set the volume immeadiately
;	MOVE	A14,*A0(PTIME),W	;Wake it up quick

	MMFM	SP,A0,A3,A4,A5
	RETS

**************************************************************************
*								         *
* 	DEBUG_SNDRST							 *
* 									 *
* 	Routine to be used by Toddview only.  Just sends an		 *
* 	off code to the sound board.  It's best not to call		 *
* 	any normal game routines from here.  If you do, beware		 *
* 	when setting a breakpoint in those routines.			 *
*								         *
**************************************************************************
DEBUG_SNDRST

	.IF USING_UART

	MMTM	SP,A0,A4,A5

	CLR	A4

	MOVI	20000,A5		;Load time-out value

	MOVI	UART,A0
DS_Tx_WAIT
	MOVE	*A0(UART_IMR),A14,W	;Read ISR register from UART
	BTST	0,A14			;Is it ready to transmit?
	JRNZ	DS_Tx_BYTE1		;BR = Yes
	DSJS	A5,DS_Tx_WAIT		;Click down another for timeout

DS_Tx_BYTE1
	MOVE	A4,*A0(UART_THR),W	;Send the High byte first

	MOVI	20000,A5		;Reload time-out value

DS_Tx_WAIT2
	MOVE	*A0(UART_IMR),A14,W	;Read ISR register from UART
	BTST	0,A14			;Is it ready to transmit?
	JRNZ	DS_Tx_BYTE2		;BR = Yes
	DSJS	A5,DS_Tx_WAIT2

DS_Tx_BYTE2
	MOVE	A4,*A0(UART_THR),W	;Then send the Low byte

	MMFM	SP,A0,A4,A5

	.ELSE

	PUSH	A3

	movi	0FF00H&~SOUNDBIT,A3	;Send HIGH byte.
	MOVE	A3,@SOUND,W

	MOVI	(8*MICRO_SECOND)/2,A14	;Line delay
	DSJS	A14,$

	ORI	SOUNDBIT,A3		;Pull up strobe to complete the send.
	MOVE	A3,@SOUND,W

	MOVI	(8*MICRO_SECOND)/2,A14	;Line delay
	DSJS	A14,$

	andni	SOUNDBIT,A3		;Send LOW byte.
	MOVE	A3,@SOUND,W

	MOVI	(8*MICRO_SECOND)/2,A14	;Line delay
	DSJS	A14,$

	ori	SOUNDBIT,A3		;Strobe up, and we're done.
	MOVE	A3,@SOUND,W

	MOVI	(8*MICRO_SECOND)/2,A14	;Line delay
	DSJS	A14,$

	PULLQ	A3

	.ENDIF

	RETS

**************************************************************************
*								         *
* IS_SOUND - CHECK SOUND DATA BASE TO SEE IF THE GIVEN SOUND SCRIPT	 *
* 		IS CURRENTLY BEING PROCESSED. (I.E. ANOTHER SOUND	 *
* 		HAS OR HAS NOT TAKEN OVER.)				 *
* A0 = PTR TO SOUND SCRIPT						 *
* RETURNS								 *
* 	 Z = SAME SCRIPT						 *
* 	NZ = SCRIPT NO LONGER ACTIVE					 *								         *
**************************************************************************
IS_SOUND		
*Note: Change this thing if SNDSIZ is not a power of 2
****	PUSH	A3
	MOVE	*A0,A14,W	;GET CHANNEL/PRIORITY WORD

	SLL	SL_CHANNEL,A14		;Extract Channel bits
	SRL	SR_CHANNEL,A14
	sll	CHANNEL_MULT_SHIFT,A14	;And multiply to form index

	ADDI	SNDSTR,A14 	;GET THE CORRECT RAM CHANNEL ADDRESS
	MOVE	*A14(SNDST),A14,L

****	SRL	SR_CHANNEL,A14	;EXTRACT CHANNEL BITS
****	MOVI	SNDSIZ,A3
****	MPYU	A14,A3
****	ADDI	SNDSTR,A3 	;GET THE CORRECT RAM CHANNEL ADDRESS
****	MOVE	*A3(SNDST),A14,L

	CMP	A0,A14		;SAME SCRIPT ACTIVE?

****	PULL	A3
	RETS

**************************************************************************
*                                                                        *
* CKSNDPRI - CHECK SOUND CHANNEL FOR EXISTANCE OF A GIVEN SOUND PRIORITY *
* A0 = CHANNEL #							 *
* A1 = SOUND PRIORITY							 *
* RETURNS:								 *
* CARRY CLEAR = PRIORITY NOT ACTIVE					 *
* CARRY SET = PRIORITY ACTIVE						 *
*                                                                        *
**************************************************************************
CKSNDPRI
	MOVE	A0,A14
	SLL	CHANNEL_MULT_SHIFT,A14	;Multiply by channel size
	ADDI	SNDSTR,A14		;OFFSET TO CORRECT CHANNEL AREA
	MOVB	*A14,A14
	SLL	24,A14
	SRL	24,A14
	CMP	A14,A1
	JRNE	CKSPRI1			;BR = PRIORITY NOT ACTIVE
	SETC
	RETS
CKSPRI1
	CLRC
	RETS


**************************************************************************
*								         *
* 		Software volume control code				 *
*								         *
**************************************************************************

**************************************************************************
*								         *
* 	PROC_SET_VOLUME							 *
* 									 *
* 		Process to set the volume after a 2 second delay.	 *
* 		This is used in conjunction with SNDRES so that		 *
* 		the dings may be heard. It would be wise not to		 *
* 		make a sound call that results in output until this	 *
* 		process has set the volume.				 *
* 									 *
* 	A8 = Sleep time before reset.					 *
*								         *
**************************************************************************
PROC_RESET_VOLUME
	SLEEPR	A8
	CALLR	SET_VOLUME
	DIE

**************************************************************************
*								         *
* 	SET_VOLUME							 *
* 									 *
* 	Set the sound board volume based on the value stored in		 *
* 	CMOS RAM.  If the value is corrupt, then the value		 *
* 	FACTORY_VOLUME is used.						 *
*								         *
**************************************************************************
SET_VOLUME
	MMTM	SP,A0,A1,A4
	ADJUST	ADJVOLUME		;Get the current volume
	MOVE	A0,A1
	ADJUST	ADJMINVOL		;Get the minimum volume allowed
	CMP	A0,A1			;Are we lower than the minimum?
	JRHS	SV_OK			;BR = No, we are O.K.
     	MOVE	A0,A1			;Otherwise, set minimum.
SV_OK
	MOVI	MASTER_VOLUME_CODE,A4	
	CALLR	SEND_RAW_SOUND		;Yo! Master volume is on it's way.

	.IF USING_UART

	MOVE	A1,A4
	NOT	A1			;I have a complement for you
	SLL	8,A1
	ADD	A1,A4			;Put 'em together for the send

	.ELSE

	MOVE	A1,A4
	SLL	8,A4
	NOT	A1			;I have a complement for you
	SLL	24,A1
	SRL	24,A1
	ADD	A1,A4			;Put 'em together for the send
	
	.ENDIF

	CALLR	SEND_RAW_SOUND		;Behold the master!

	MOVKM	1,@VOLUME_SET,W		;The volume has been set

	MMFM	SP,A0,A1,A4
	RETS


**************************************************************************
*								         *
* 	SWITCH_VOLUME_UP						 *
* 									 *
* 	Switch triggered process to increase the sound board volume.	 *
*								         *
**************************************************************************
SWITCH_VOLUME_UP
	MOVK	1,A8			;Increment
	MOVK	VOLUP_SWITCH,A10
	JRUC	SWITCH_VOLUME_CONTROL

**************************************************************************
*								         *
* 	SWITCH_VOLUME_DOWN						 *
* 									 *
* 	Switch triggered process to decrease the sound board volume.	 *
*								         *
**************************************************************************
SWITCH_VOLUME_DOWN
	MOVI	-1,A8			;Decrement
	MOVK	VOLDN_SWITCH,A10

**************************************************************************
*								         *
* 	SWITCH_VOLUME_CONTROL						 *
* 									 *
* 	Process to adjust volume					 *
* 									 *
* 	A8 = Change value						 *
* 	A10 = Switch number to check					 *
*								         *
**************************************************************************
SWITCH_VOLUME_CONTROL	
	MOVE	@GAME_STATE,A14,W
	CMPI	INDIAG,A14
	JAEQ	SUCIDE

	MOVI	PID_VOLUME,A0
	CALLA	EXISTP_ALL		;Does this thing already exist?
	JRNZ	SVC_RESET_AND_DIE	;BR = Yes, so bail on this one.

	MOVI	PID_VOLUME_DISP,A0
	CALLA	KILLPROC_ALL		;Kill display deleter

	MOVKM	1,@SUPRESS_PAGE_FLIP,W	;Shut down all writes to DPYST
	MOVIM	DPYSTRT3,@DPYST,L	;Rock on to the volume page

SVC_CLICK
	ADJUST	ADJMINVOL
	MOVE	A0,A4			;Grab the minimum volume allowed

	ADJUST	ADJVOLUME		;Get the current volume.
	ADD	A8,A0			;Adjust it the right way.

	CMP	A4,A0
	JRGE	SVC_CK_MAX		;BR = we are not a adjusted minimum

	MOVE	A4,A0	 		;Force minimum	

SVC_CK_MAX
	CMPI	MAX_VOLUME,A0		;Are we too high? (Too high? Is this possible?)
	JRLE	SVC_NEW_VOL		;BR = No, take another hit

	MOVI	MAX_VOLUME,A0		;Cut that sucka off

SVC_NEW_VOL
	MOVE	A0,A1
	MOVI	ADJVOLUME,A0
	CALLA	PUT_ADJ			;Store the new volume in CMOS
	CALLA	F_ADC_S			;And checksum it.
	CALLR	SET_VOLUME		;And set it.

	MOVE	@DISPLAYON,A7,W
	CLR	A14
	MOVE	A14,@DISPLAYON,W
	CALLA	DMAQWAIT       		;WAIT ON DMA
	CLR	A14
	MOVE	A14,@CMAPSEL,W 		;SELECT COLOR MAP 0

	MMTM	SP,B11,B12,B13		;Protect DMA Queue regs

	calla	draw_volume_scale1

	MMFM	SP,B11,B12,B13		;Restore DMA Queue regs

	MOVE	A7,@DISPLAYON,W		;and let display system run

SVC_WAIT
	SLEEP	1
	MOVE	@COINS,A14,W
	BTST	A10,A14			;Still holding the volume switch?
	JRNZ	SVC_BAIL		;BR = No, then let's bail
	JRUC	SVC_CLICK		;Click the volume again
SVC_BAIL
	MOVIM	PID_VOLUME_DISP,*A13(PROCID),W
	SLEEP	25
	CLRM	@SUPRESS_PAGE_FLIP,W	;Restore writes to DPYST
	DIE

SVC_RESET_AND_DIE

	SLEEP	5
	CLR	A0
	BSET	A10,A0
	ORM	A0,@SW2TEMP1,L
	ORM	A0,@SW2TEMP2,L		;Clear the debounce RAM to re-trigger
	DIE

**************************************************************************
*								         *
* SET_TRACK_VOLUME - SET THE VOLUME FOR A TRACK				 *
* 									 *
* PASS:									 *
* A0 = TRACK								 *
* A1 = VOLUME (0-255)							 *
*								         *
**************************************************************************

SET_TRACK_VOLUME
	MMTM	SP,A0,A4

	.if	DEBUG
	
	CMPK	NCHAN-1,A0
	LOCKON	HI	

	CMPI	FULL_VOLUME,A1
	LOCKON	HI

	.endif

	MOVE	A0,A4
	SLL	8,A4				;CONVERT TRACK TO OFFSET
	ADDI	VOLUME_BASE_CODE,A4		;OFFSET FROM TRACK VOLUME 0
	CALLA	SEND_RAW_SOUND			;SELECT TRACK VOLUME

	MOVE	A1,A4
	NOT	A4
	SLL	8,A4				;NOT(VOLUME) << 8
	OR	A1,A4				
	CALLA	SEND_RAW_SOUND			;SEND VOLUME + NOT(VOLUME)
	
	MMFM	SP,A0,A4
	RETS

**************************************************************************
*								         *
* SET_TRACK_VOLUME_Z - SET THE VOLUME FOR A TRACK BASED ON AN OBJECT'S Z *
* 									 *
* PASS:									 *
* A0 = TRACK								 *
* A8 = OBJECT								 *
*								         *
**************************************************************************

SET_TRACK_VOLUME_Z
	MMTM	SP,A0,A4

	.if	DEBUG
	
	CMPK	NCHAN-1,A0
	LOCKON	HI	

	.endif

	MOVE	A0,A4
	SLL	8,A4				;CONVERT TRACK TO OFFSET
	ADDI	VOLUME_BASE_CODE,A4		;OFFSET FROM TRACK VOLUME 0
	CALLA	SEND_RAW_SOUND			;SELECT TRACK VOLUME

	move	*A8(OZVAL),A1,L
	move	@ZBASE,A14,L
	sub	A14,A1			;Get world relative Z-position
;	SUBI	ZMAX_REAL,A1		;Get rid of anything that is not visible
	JRNN	STFZ_COOL
	CLR	A1
	JRUC	STFZ_DOIT
STFZ_COOL
	MOVI	Z_DIV,A14
	DIVU	A14,A1

	.IF DEBUG
	CMPI	FULL_VOLUME,A1		;Did we go out of bounds?
	LOCKON	HI			;LOCK = Yes
	.ENDIF
	
STFZ_DOIT
	MOVE	A1,A4
	SLL	8,A1				;NOT(VOLUME) << 8
	NOT	A4
	SLL	24,A4
	SRL	24,A4
	OR	A1,A4
	CALLA	SEND_RAW_SOUND			;SEND NOT(VOLUME) << 8 + VOLUME
	MMFM	SP,A0,A4
	RETS

**************************************************************************
*								         *
* VOLUME_AT_Z - COMPUTE VOLUME AT AN OBJECT'S Z				 *
* 									 *
* PASS:									 *
* A8 = OBJECT								 *
*								         *
* RETURN:								 *
* A1 = VOLUME								 *
*								         *
**************************************************************************

VOLUME_AT_Z
	move	*A8(OZVAL),A1,L
	move	@ZBASE,A14,L
	sub	A14,A1			;Get world relative Z-position
;	SUBI	ZMAX_REAL,A1		;Get rid of anything that is not visible
	JRNN	VAZ_COOL
	CLR	A1
	JRUC	VAZ_NOT
VAZ_COOL
	MOVI	Z_DIV,A14
	DIVU	A14,A1

	.IF DEBUG
	CMPI	FULL_VOLUME,A1		;Did we go out of bounds?
	LOCKON	HI			;LOCK = Yes
	.ENDIF
VAZ_NOT
	NOT	A1
	SLL	24,A1
	SRL	24,A1
	RETS
	

**************************************************************************
*								         *
* TRACK_FADE_PROC - FADE A TRACK FROM STARTING TO FINAL VOLUME		 *
* 		    NOTE: IF THE FINAL VOLUME IS ZERO, THEN THE SOUND	 *
* 			  IS KILLED!					 *
* 									 *
* PASS:									 *
* A8  = INITIAL SLEEP BEFORE FADE					 *
* A9  = [FINAL VOLUME, STARTING VOLUME]					 *
* A10 = TRACK								 *
* A11 = FADE TIME							 *
*								         *
**************************************************************************

TRACK_FADE_PROC
	MOVE	A8,A8
	JRZ	TFP_GO			;BR=NO INITIAL SLEEP
      	SLEEPR	A8
TFP_GO
	MOVE	A9,A8
	ZEXT	A8,W
	SRL	16,A9

	PUSHP	A9			;SAVE FINAL VOLUME

	SUB	A8,A9			;TOTAL VOLUME DELTA
	SLL	16,A8			;WE NEED 16 BIT FRACTIONS
	SLL	16,A9
	DIVS	A11,A9			;INCREMENTAL VOLUME DELTA
TFP_FADE
	MOVE	A10,A0
	MOVE	A8,A1
	SRL	16,A1			;THROW AWAY FRACTION
	CALLR	SET_TRACK_VOLUME

	ADD	A9,A8			;GET NEXT VOLUME
	DEC	A11
	JRZ	TFP_DONE		;BR=WE'RE DONE
	SLEEP	1
	JRUC	TFP_FADE
TFP_DONE
	PULLPQ	A1
	JRNZ	TFP_FINAL		;BR=WE HAVE A FINAL NON-ZERO VOLUME

;	SLL	5,A10			;KILL THE TRACK ON FINAL ZERO VOLUME!
;	ADDI	CHAN_OFF_TABLE,A10
;	MOVE	*A10,A0,L

	SLL	6,A10			;KILL THE TRACK ON FINAL ZERO VOLUME!
	ADDI	SND_CHAN0_OFF,A10
	MOVE	A10,A0
	CALLA	ONESND			

	DIE
TFP_FINAL
	MOVE	A10,A0			;SET FINAL VOLUME
	CALLR	SET_TRACK_VOLUME

	DIE

;CHAN_OFF_TABLE
;	.LONG	SND_CHAN0_OFF,SND_CHAN1_OFF,SND_CHAN2_OFF,SND_CHAN3_OFF


**************************************************************************
*								         *
* TRACK_FADE_IN_FULL_PROC - FADE A TRACK FROM NO TO FULL VOLUME		 *
* 									 *
* PASS:									 *
* A8  = INITIAL SLEEP BEFORE FADE					 *
* A10 = TRACK								 *
* A11 = FADE TIME							 *
*								         *
**************************************************************************

TRACK_FADE_IN_FULL_PROC
	MOVI	[FULL_VOLUME,0],A9
	JRUC	TRACK_FADE_PROC

**************************************************************************
*								         *
* TRACK_FADE_OUT_FULL_PROC - FADE A TRACK FROM FULL TO NO VOLUME AND	 *
*			      KILL THE SOUND!				 *
* 									 *
* PASS:									 *
* A8  = INITIAL SLEEP BEFORE FADE					 *
* A10 = TRACK								 *
* A11 = FADE TIME							 *
*								         *
**************************************************************************

TRACK_FADE_OUT_FULL_PROC
	MOVI	[0,FULL_VOLUME],A9
	JRUC	TRACK_FADE_PROC

**************************************************************************
*                                                                        *
* 		POPULAR SOUND CALLS 					 *
*                                                                        *
**************************************************************************
*
*HIGH PRIORITY OFF CODES, NOTHING SHOULD BEAT THESE
SND_ALLOFF
	 .WORD	0F0FFH,1,08000H,0		;MUSIC AND EFFECTS OFF
SND_MUSICOFF
	.WORD	0F0FFH,1,083E3H,0		;TURN JUST MUSIC OFF
SND_MUSITOFF
	.WORD	0F0FFH,1,083E3H,0		;MUSIC TRANSITION OFF

SND_BGND0_OFF
	.word	0F000h,1,53E3h,0		;Kill background track 0
SND_BGND1_OFF
	.word	0F100h,1,53E4h,0		;Kill background track 1
SND_BGND2_OFF
	.word	0F200h,1,53E5h,0		;Kill background track 2
SND_BGND3_OFF
	.word	0F300h,1,53E6h,0		;Kill background track 3

;THE FOLLOWING WILL NOT KILL BACKGROUND SOUNDS:
SND_CHAN0_OFF
	.word	0F0FFh,1,43E3h,0		;Kill track 0
SND_CHAN1_OFF
	.word	0F1FFh,1,43E4h,0		;Kill track 1
SND_CHAN2_OFF
	.word	0F2FFh,1,43E5h,0		;Kill track 2
SND_CHAN3_OFF
	.word	0F3FFh,1,43E6h,0		;Kill track 3

	.END
