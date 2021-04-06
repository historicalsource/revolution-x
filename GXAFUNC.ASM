	.MLIB	"GXMACS.LIB"
	.FILE	"GXAFUNC.ASM"
	.TITLE	"<<< GENERATION X --- GENERAL ANIMATION FUNCTIONS >>>"
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

*SYMBOLS IN THIS FILE
	.DEF	SetAnim, A_Set_Rel_Long, A_Anim_Rel_DSJ, SetAnim_AFARG
	.DEF	A_RAND_REL_BYTE,A_STAY_TIL_SY_LT,A_Set_LOOP_STRT
	.DEF	A_BRANCH_IF_FALSE,A_CLR_OZVEL,A_STAY_TIL_GRND_HIT
	.DEF	A_INIT_AnimSLP_Var, A_INC_Var_Word, A_OBJ_OFF_CHANGE_PAL
	.DEF	A_SET_REL_LONG_HEAD, A_AnimFrm_DSJ, A_DELETE_ZBOT
	.def	A_OZVAL_DELTA,A_CLR_OYVEL,A_STAY_TIL_WY_GT
	.DEF	A_WAIT_FOR_QUOTA, AU_DANIM, A_BRANCH_IF_TRUE
	.DEF	A_SET_RANDSLP,A_ADJ_RANDSLP,A_SET_SCALE	
	.DEF	A_AnimFrm_IF_TRUE, A_CREATEP_R, A_CREATEP_R8
	.DEF	A_STAY_TIL_OFFSCRN
	.DEF	A_AUDIT

*SYMBOLS IN GXENEMY.ASM
	.REF	DELETE_ENEMY

**** from GXD.ASM
	.REF	WORLD_GRNDOFF

	.TEXT

**************************************************************************
*								         *
* 	A_AUDIT								 *
* 									 *
* 	Anim func to click an audit counter.				 *
* 									 *
* 	AARG+,W = Counter number					 *
*								         *
**************************************************************************
A_AUDIT
	MOVE	@GAME_STATE,A14,W
	CMPI	INAMODE,A14
	JREQ	AA_X			;No auditing during Attract mode
	CALLA	GETAFARG_WORD
	JAUC	AUD1
AA_X
	RETS

**************************************************************************
*								         *
* 		Anim funcs for making Sounds				 *
*								         *
**************************************************************************

**************************************************************************
*								         *
* A_WAIT_FOR_QUOTA - WAIT FOR ENEMY_QUOTA TRUE, IF FALSE JUMP 		 *
* 									 *
* PASS:									 *
* A8      = OBJECT							 *
* AARG+,L = JUMP ADDRESS IF ENEMY_QUOTA FALSE				 *
* RETURN:								 *
* NUTIN'								 *
*								         *
**************************************************************************

A_WAIT_FOR_QUOTA
	MOVE	@ENEMY_QUOTA,A14,W
	JRZ	AWFQ_JUMP			;BR=NO QUOTA
	RETS
AWFQ_JUMP
	CALLA	GETAFARG_LONG
	MOVE	A0,*A8(AnimFrm),L
	RETS

**************************************************************************
*								         *
* A_DANIM - STOP A UNIVERSE ANIMATION AND SET IT TO RESTART ON AnimFrm   *
* 									 *
* PASS:									 *
* A8 = OBJECT								 *
* RETURN:								 *
* NUTIN'								 *
*								         *
**************************************************************************

AU_DANIM
	MOVE	*A8(OULINK),A0,L
	MOVE	*A0(MAP_IMG),A1,L
	SLL	28,A1				;GET FLAGS
	SRL	28,A1

	MOVE	*A8(AnimFrm),A14,L
	OR	A14,A1				
	ORI	M_IF_DANIM,A1
	MOVE	A1,*A0(MAP_IMG),L

	CALLA	PULL_ANIM

	RETS

**************************************************************************
*								         *
* A_DELETE_ZBOT - DELETE OBJECT IF OFF DA BOTTOM OF DA SCREEN OR OUT OF	 *
* 		  Z RANGE, BEYOND ZFAR OR BEFORE ZMAX_REAL		 *
* 									 *
* PASS:									 *
* A8 = OBJECT								 *
* RETURN:								 *
* NUTIN'								 *
*								         *
**************************************************************************
A_DELETE_ZBOT
	MOVE	*A8(OZVAL),A1,L
	MOVE	@ZBASE,A14,L
	SUB	A14,A1
	MOVE	@ZFAR,A14,L
	CMP	A14,A1
	JAGT	DELETE_OBJ			;BR=BEYOND ZFAR
	CMPI	ZMAX_REAL,A1		
	JALT	DELETE_OBJ			;BR=BEFORE ZMAX_REAL
	MOVE	*A8(OYVEL),A14,L
	JRN	ADZ_ABORT			;BR=WE'RE MOVIN' ON UP
	MOVE	*A8(ODAGY),A1,W
	MOVE	@(SCRNBR+16),A14,W
	CMP	A14,A1
	JAGT	DELETE_OBJ			;BR=OFF DA BOTTOM
ADZ_ABORT
	RETS

**************************************************************************
*								         *
* A_TOGGLE_OCTRL - TOGGLE BITS IN OCTRL					 *
*								         *
* PASS:								         *
* A8 = PTR TO OBJECT							 *
* AARG+,W = BITS TO TOGGLE						 *
*								         *
**************************************************************************

A_TOGGLE_OCTRL
	CALLA	GETAFARG_WORD
	MOVE	*A8(OCTRL),A1,W
	XOR	A0,A1
	MOVE	A1,*A8(OCTRL),W
	RETS

**************************************************************************
*								         *
* A_RAND_FLIP_OCTRL - FLIP BITS TO RANDOMLY SET IN OCTRL		 *
*								         *
* PASS:								         *
* A8 = PTR TO OBJECT							 *
* AARG+,W = FLIP BITS TO CHANGE						 *
*								         *
**************************************************************************

A_RAND_FLIP_OCTRL
	CALLA	GETAFARG_WORD
	MOVE	*A8(OCTRL),A1,W
	ANDN	A0,A1
	MOVE	@RAND,A14,W
	AND	A14,A0
	OR	A0,A1
	MOVE	A1,*A8(OCTRL),W
	RETS

**************************************************************************
*								         *
* A_SET_OCTRL - SET BITS IN OCTRL					 *
*								         *
* PASS:								         *
* A8 = PTR TO OBJECT							 *
* AARG+,W = BITS TO SET							 *
*								         *
**************************************************************************

A_SET_OCTRL
	CALLA	GETAFARG_WORD
	MOVE	*A8(OCTRL),A1,W
	OR	A0,A1
	MOVE	A1,*A8(OCTRL),W
	RETS

**************************************************************************
*								         *
* A_SOUND - ANIM FUNC TO MAKE A SOUND CALL				 *
* A8 = PTR TO OBJECT							 *
* *A8(AnimFrm),L = PTR TO SOUND SCRIPT					 *
* NOTE: ANIM FUNCS DO NOT PUSH REGISTERS!				 *
*								         *
**************************************************************************
A_SOUND
	CALLA	GETAFARG_LONG
	JAUC	ONESND

**************************************************************************
*								         *
* A_SOUNDZ - ANIM FUNC TO MAKE A SOUND CALL BASED ON OBJECT Z		 *
* A8 = PTR TO OBJECT							 *
* *A8(AnimFrm),L = PTR TO SOUND SCRIPT					 *
* NOTE: ANIM FUNCS DO NOT PUSH REGISTERS!				 *
*								         *
**************************************************************************
A_SOUNDZ
	CALLA	GETAFARG_LONG
	JAUC	ONESND_Z

**************************************************************************
*								         *
* 	A_RAND_SOUNDZ							 *
* 									 *
* 	Anim func to have a random chance to make a Z position		 *
* 	dependant sound.						 *
* 									 *
* 	A8 = Ptr to object						 *
* 	AARG+,W = % chance of making sound				 *
* 	AARG+,L = Sound script						 *
*								         *
**************************************************************************
A_RAND_SOUNDZ
	CALLA	GETAFARG_WORD
	CALLA	RANDPER			;Do the % chance
	JAC	A_SOUNDZ		;BR = we hit it, do the sound
	RETS

**************************************************************************
*								         *
* 	A_TAB_SOUNDZ							 *
* 									 *
* 	Anim func to randomly pick from a table of sound calls		 *
* 	and make it as a Z position dependant sound.			 *
* 									 *
* 	A8 = Ptr to object						 *
* 	AARG+,L = Table of sound calls					 *
* 	AARG+,W	= # of sound calls in table				 *
*								         *
**************************************************************************
A_TAB_SOUNDZ
	CALLA	GETAFARG_LONG
	MOVE	A0,A1
	CALLA	GETAFARG_WORD
	CALLA	RAND0
	SLL	5,A0
	ADD	A0,A1
	MOVE	*A1,A0,L
	JAUC	ONESND_Z

**************************************************************************
*								         *
* A_PLAYER_SND - ANIM FUNC TO FIRE OFF A SOUND FOR A PARTICULAR		 *
* 		PLAYER.							 *
* AARG+,L = PTR TO SOUND TABLE						 *
*								         *
**************************************************************************
A_PLAYER_SND
	CALLA	GETAFARG_LONG
	JAUC	PLAYER_SND

**************************************************************************
*								         *
* 	A_PLAYER_SND_Z							 *
* 									 *
* 	Anim func to call PLAYER_SND_Z.					 *
* 									 *
* 	AARG+,L = Ptr to sound script					 *
*								         *
**************************************************************************
A_PLAYER_SND_Z
	CALLA	GETAFARG_LONG
	JAUC	PLAYER_SND_Z


**************************************************************************
*								         *
* 	A_BRANCH_IF_FALSE						 *
* 									 *
* 	Anim func to branch animation if a given byte value		 *
* 	is false.							 *
* 									 *
* 	AARG+,L = Address of byte value					 *
* 	AARG+,L = Branch						 *
*								         *
**************************************************************************
A_BRANCH_IF_FALSE
	CALLA	GETAFARG_LONG		;Get the ptr
	MOVB	*A0,A14			;Is it false?
	JAZ	SetAnim_AFARG		;BR = Yes
	RETS

**************************************************************************
*								         *
* 	A_BRANCH_IF_TRUE						 *
* 									 *
* 	Anim func to branch animation if a given byte value		 *
* 	is TRUE.							 *
* 									 *
* 	AARG+,L = Address of byte value					 *
* 	AARG+,L = Branch						 *
*								         *
**************************************************************************
A_BRANCH_IF_TRUE
	CALLA	GETAFARG_LONG		;Get the ptr
	MOVB	*A0,A14			;Is it TRUE?
	JANZ	SetAnim_AFARG		;BR = Yes
	RETS

**************************************************************************
*								         *
* 	A_AnimFrm_IF_TRUE						 *
* 									 *
* 	Anim func go to AnimFrm animation if a given byte value		 *
* 	is TRUE.							 *
* 									 *
* 	AARG+,L = Address of byte value					 *
* 	AARG+,L = Branch						 *
*								         *
**************************************************************************
A_AnimFrm_IF_TRUE
	CALLA	GETAFARG_LONG		;Get the ptr
	MOVB	*A0,A14			;Is it TRUE?
	JRZ	AAIF_DONE		;BR = NO
	CALLA	GETAFARG_LONG		;GET NEW AnimFrm
	MOVE	A0,*A8(AnimFrm),L
AAIF_DONE
	RETS


**************************************************************************
*								         *
* A_GOSUB - JUMP TO SUBROUTINE						 *
*	    NOTE: SUBROUTINES CANNOT BE NESTED!				 *
*								         *
* A8 = Ptr to object							 *
* AARG+,L = SUBROUTINE ADDRESS						 *
*								         *
**************************************************************************

A_GOSUB
	MOVE	*A8(AnimScr),*A8(AnimRetScr),L
	MOVE	*A8(AnimFrm),*A8(AnimRetFrm),L
	JAUC	A_AnimGo

**************************************************************************
*								         *
* A_RETURN - RETURN FROM SUBROUTINE					 *
*								         *
* A8 = Ptr to object							 *
*								         *
**************************************************************************
 
A_RETURN	
	MOVE	*A8(AnimRetScr),*A8(AnimScr),L
	MOVE	*A8(AnimRetFrm),*A8(AnimFrm),L
	RETS

**************************************************************************
*								         *
* 	A_CREATEP							 *
* 									 *
* 	Anim func to Create a process.					 *
* 									 *
* 	AARG+,W = Process I.D.						 *
* 	AARG+,L = Process Address					 *
* 	A8 - A11 are passed to the process				 *
*								         *
**************************************************************************
A_CREATEP
	CALLA	GETAFARG_WORD
	MOVE	A0,A1
	CALLA	GETAFARG_LONG
	MOVE	A0,A7
	JAUC	GETPRC

**************************************************************************
*								         *
* 	A_CREATEP_R							 *
* 									 *
* 	Anim func to Create a process and send some registers.		 *
* 									 *
* 	A8 = Object creating process, passed to new process.		 *
* 									 *
* 	AARG+,W = Process I.D.						 *
* 	AARG+,L = Process Address					 *
* 	AARG+,L = A9							 *
* 	AARG+,L = A10							 *
* 	AARG+,L = A11							 *
*								         *
**************************************************************************
A_CREATEP_R
	CALLA	GETAFARG_WORD
	MOVE	A0,A1
	CALLA	GETAFARG_LONG
	MOVE	A0,A7
	CALLA	GETAFARG_LONG
	MOVE	A0,A9
	CALLA	GETAFARG_LONG
	MOVE	A0,A10
	CALLA	GETAFARG_LONG
	MOVE	A0,A11
	JAUC	GETPRC

**************************************************************************
*								         *
* 	A_CREATEP_R8							 *
* 									 *
* 	Anim func to Create a process and send some registers.		 *
* 									 *
* 	A8 = Object creating process, passed to new process.		 *
* 									 *
* 	AARG+,W = Process I.D.						 *
* 	AARG+,L = Process Address					 *
* 	AARG+,L = A8							 *
* 	AARG+,L = A9							 *
* 	AARG+,L = A10							 *
* 	AARG+,L = A11							 *
*								         *
**************************************************************************
A_CREATEP_R8
	CALLA	GETAFARG_WORD
	MOVE	A0,A1
	CALLA	GETAFARG_LONG
	MOVE	A0,A7
	CALLA	GETAFARG_LONG
	MOVE	A0,A8
	CALLA	GETAFARG_LONG
	MOVE	A0,A9
	CALLA	GETAFARG_LONG
	MOVE	A0,A10
	CALLA	GETAFARG_LONG
	MOVE	A0,A11
	JAUC	GETPRC

**************************************************************************
*								         *
* A_Set_AnimLoop - Anim func to initialize the Animation Loop count.	 *
* A8 = Ptr to object							 *
* AARG+,W = Initial value						 *
*								         *
**************************************************************************
A_Set_AnimLoop
	calla	GETAFARG_WORD
	movb	A0,*A8(AnimLoop)
	rets

**************************************************************************
*								         *
* A_Anim_DSJ - Anim func to decrement AnimLoop count and branch		 *
* 		if not 0.						 *
* A8 = Ptr to object							 *
* AARG+,L = Branch if AnimLoop <> 0					 *
*								         *
**************************************************************************
A_Anim_DSJ	
	movb	*A8(AnimLoop),A14
	dec	A14
	movb	A14,*A8(AnimLoop)
	jrz	AAD_X
	calla	GETAFARG_LONG
	move	A0,A1
	jauc	SetAnim
AAD_X
	rets

**************************************************************************
*								         *
* A_AnimFrm_DSJ - Anim func to decrement AnimLoop count and branch	 *
* 		if not 0. THIS DOES NOT TRASH AnimScr!			 *
* A8 = Ptr to object							 *
* AARG+,L = Branch if AnimLoop <> 0					 *
*								         *
**************************************************************************
A_AnimFrm_DSJ	
	movb	*A8(AnimLoop),A14
	dec	A14
	movb	A14,*A8(AnimLoop)
	jrz	AAFD_X
	calla	GETAFARG_LONG
	MOVE	A0,*A8(AnimFrm),L
AAFD_X
	rets

**************************************************************************
*								         *
* 	A_Anim_Rel_DSJ							 *
* 									 *
* 	Anim func to decrement a byte sized variable relative to the	 *
* 	beginning of the object, and branches the animation if not 0.	 *
* 									 *
* 	A8 = Ptr to object						 *
* 	AARG+,W = Relative offset of byte loop counter			 *
* 	AARG+,L = Branch if loop counter <> 0				 *
*								         *
**************************************************************************
A_Anim_Rel_DSJ
	CALLA	GETAFARG_WORD		;Get the offset
	MOVE	A8,A1
	ADD	A0,A1			;And index into the object

	MOVB	*A1,A14
	DEC	A14   			;Decrement the loop counter
	MOVB	A14,*A1
	JRZ	AARD_X			;BR = loop counter = 0

	CALLA	GETAFARG_LONG		;Grab the branch address
	MOVE	A0,A1
	JAUC	SetAnim			;And stuff it
AARD_X
	RETS

**************************************************************************
*								         *
* A_Set_Rel_Byte - Anim func to set a given byte relative to the current *
* 		object to a given value.				 *
* 									 *
* AARG+,W = Offset in to object						 *
* AARG+,W = Value to store						 *
*								         *
**************************************************************************
A_Set_Rel_Byte
	CALLA	GETAFARG_WORD		;Get the offset
	MOVE	A8,A1
	ADD	A0,A1			;And index into the object
	CALLA	GETAFARG_WORD		;Get the value
	MOVB	A0,*A1			;And store it
	RETS

**************************************************************************
*								         *
* 	A_Set_Rel_Byte_Head						 *
* 									 *
* 	Anim func to set a given byte in the head object of a		 *
* 	multi-parter that is relative to the beginning of the		 *
* 	object block.							 *
* 									 *
* 	A8 = Ptr to any object in a multi-parter			 *
* 	AARG+,W = Offset in to object					 *
* 	AARG+,W = Value to store					 *
*								         *
**************************************************************************
A_Set_Rel_Byte_Head
	CALLA	GETAFARG_WORD		;Get the offset
	MOVE	A0,A1			;Save it here
	CALLA	GETAFARG_WORD		;Get the value to store
	CALLA	GET_HEAD_PART		;Grab the head part
	ADD	A8,A1			;Offset into object block
	MOVB	A0,*A1			;And store value
	RETS

**************************************************************************
*								         *
* 	A_RAND_REL_BYTE							 *
* 									 *
* 	Anim func to set a given byte relative to the current object	 *
* 	to a random value in the given range.				 *
* 									 *
* 	A8 = Ptr to object						 *
* 	AARG+,W = Lower bound of random value				 *
* 	AARG+,W = Upper bound of random value				 *
* 	AARG+,W = Offset into object					 *
*								         *
**************************************************************************
A_RAND_REL_BYTE
	CALLA	GETAFARG_LONG		;Get the random values
	MOVY	A0,A1
	SRA	16,A1			;Split 'em up
	ZEXT	A0
	CALLA	RANGERND		;And make it into something
	MOVE	A0,A2
	CALLA	GETAFARG_WORD		;Get the offset
	ADD	A8,A0
	MOVB	A2,*A0
	RETS

**************************************************************************
*								         *
* A_Set_Rel_Word - Anim func to set a given word relative to the current *
* 		object to a given value.				 *
* 									 *
* AARG+,W = Offset in to object						 *
* AARG+,W = Value to store						 *
*								         *
**************************************************************************
A_Set_Rel_Word
	CALLA	GETAFARG_WORD		;Get the offset
	MOVE	A8,A1
	ADD	A0,A1			;And index into the object
	CALLA	GETAFARG_WORD		;Get the value
	MOVE	A0,*A1,W		;And store it
	RETS

**************************************************************************
*								         *
* 	A_Set_Rel_Word_Head						 *
* 									 *
* 	Anim func to set a given Word in the head object of a		 *
* 	multi-parter that is relative to the beginning of the		 *
* 	object block.							 *
* 									 *
* 	A8 = Ptr to any object in a multi-parter			 *
* 	AARG+,W = Offset in to object					 *
* 	AARG+,W = Value to store					 *
*								         *
**************************************************************************
A_Set_Rel_Word_Head
	CALLA	GETAFARG_WORD		;Get the offset
	MOVE	A0,A1			;Save it here
	CALLA	GETAFARG_WORD		;Get the value to store
	CALLA	GET_HEAD_PART		;Grab the head part
	ADD	A8,A1			;Offset into object block
	MOVE	A0,*A1,W		;And store value
	RETS

**************************************************************************
*								         *
* A_Set_Rel_Long - Anim func to set a given long word relative to the    *
* 		current object to a given value.			 *
* 									 *
* AARG+,W = Offset in to object						 *
* AARG+,L = Value to store						 *
*								         *
**************************************************************************
A_Set_Rel_Long
	CALLA	GETAFARG_WORD		;Get the offset
	MOVE	A8,A1
	ADD	A0,A1			;And index into the object
	CALLA	GETAFARG_LONG		;Get the value
	MOVE	A0,*A1,L		;And store it
	RETS

**************************************************************************
*								         *
* 	A_SET_REL_LONG_HEAD						 *
* 									 *
* 	Anim func to set a given Long in the head object of a		 *
* 	multi-parter that is relative to the beginning of the		 *
* 	object block.							 *
* 									 *
* 	A8 = Ptr to any object in a multi-parter			 *
* 	AARG+,W = Offset in to object					 *
* 	AARG+,L = Value to store					 *
*								         *
**************************************************************************
A_SET_REL_LONG_HEAD
	CALLA	GETAFARG_WORD		;Get the offset
	MOVE	A0,A1
	CALLA	GETAFARG_LONG		;Get the value
	CALLA	GET_HEAD_PART
	ADD	A8,A1			;Offset into object block
	MOVE	A0,*A1,L		;And store it
	RETS

**************************************************************************
*								         *
* A_Set_Var_Byte - Anim func to set a given variable of byte length	 *
* 		to a given value.					 *
* AARG+,L = Address of variable						 *
* AARG+,W = Value to store						 *
*								         *
**************************************************************************
A_Set_Var_Byte
	calla	GETAFARG_LONG
	move	A0,A1
	calla	GETAFARG_WORD
	movb	A0,*A1
	rets

**************************************************************************
*								         *
* A_Set_Var_Word - Anim func to set a given variable of word length	 *
* 		to a given value.					 *
* AARG+,L = Address of variable						 *
* AARG+,W = Value to store						 *
*								         *
**************************************************************************
A_Set_Var_Word
	calla	GETAFARG_LONG
	move	A0,A1
	calla	GETAFARG_WORD
	move	A0,*A1,W
	rets

**************************************************************************
*								         *
* A_RAND_FLIP - ANIM FUNC TO SET THE FLIPS OF AN OBJECT RANDOMLY.	 *
* A8 = PTR TO OBJECT							 *
*								         *
**************************************************************************
A_RAND_FLIP
	MOVE	@RAND,A0,W
	ANDI	M_FLIPH|M_FLIPV,A0		;ISOLATE FLIP BITS ONLY
	JAUC	SET_FLIP

**************************************************************************
*								         *
* A_RAND_HFLIP - ANIM FUNC TO SET THE HFLIP OF AN OBJECT RANDOMLY.	 *
* A8 = PTR TO OBJECT							 *
*								         *
**************************************************************************
A_RAND_HFLIP
	MOVE	@RAND,A0,W
	ANDI	M_FLIPH,A0			;ISOLATE FLIP BITS ONLY
	JAUC	SET_FLIP

**************************************************************************
*								         *
* A_SET_OYACCEL - ANIM FUNC TO SET THE OYACCEL FIELD OF AN OBJECT.	 *
* A8 = OBJECT								 *
* AARG+,W = NEW YACCEL							 *
*								         *
**************************************************************************
A_SET_OYACCEL
	CALLA	GETAFARG_WORD
	MOVE	A0,*A8(OYACCEL),W
	RETS

**************************************************************************
*								         *
* A_OBJ_ON_CHANGE_PAL - ANIM FUNC THAT DOES JUST WHAT IT SAYS.		 *
* A8 = OBJECT								 *
* AARG+,L = NEW PALETTE							 *
*								         *
**************************************************************************
A_OBJ_ON_CHANGE_PAL
	CALLA	OBJ_ON
	JAUC	A_CHANGE_PAL

**************************************************************************
*								         *
* 	A_OBJ_OFF_CHANGE_PAL						 *
* 									 *
* 	Anim func to turn object off and change it's palette.		 *
* 									 *
* 	A8 = Ptr to object						 *
* 	AARG+,L = New palette address					 *
*								         *
**************************************************************************
A_OBJ_OFF_CHANGE_PAL
	CALLA	OBJ_OFF
	JAUC	A_CHANGE_PAL

**************************************************************************
*								         *
* A_FLIP_BRANCH - ANIM FUNC TO BRANCH IF OBJECT IS FLIPPED.		 *
* A8 = PTR TO OBJECT							 *
*								         *
**************************************************************************
A_FLIP_BRANCH
	MOVE	*A8(OCTRL),A14,W	
	BTST	B_FLIPH,A14
	JREQ	AFB_X
SetAnim_AFARG
	CALLA	GETAFARG_LONG
	MOVE	A0,A1
SetAnim
	MOVE	A1,*A8(AnimFrm),L
	MOVE	A1,*A8(AnimScr),L
AFB_X
	RETS

**************************************************************************
*								         *
* A_PreFrag_Center - ANIM FUNC TO START A FRAGGER SHOW USING		 *
* 			PreFrag_Center.					 *
* AARG+,L = FRAGGER SCRIPT						 *
* AARG+,L = 16.16 Z Absolute Max Velocity				 *
* AARG+,L = 16.16 X and Y Absolute Max Velocity				 *
*								         *
**************************************************************************
A_PreFrag_Center
	calla	GETAFARG_LONG		;Get the script
	move	A0,A1			;Keep it here
	calla	GETAFARG_LONG		;Get the Z velocity
	move	A0,A3			;Pass it here
	calla	GETAFARG_LONG		;Get the X and Y velocity
	calla	PreFrag_Center		;BLOW RANDOMLY OUT OR UP
	move	A1,B14			;Right place at the right time
	CALLA	Fragger			;And get it goin' Boy
	MOVE	A8,*A0(FPDATA),L	;Pass pointer to parent
	RETS

**************************************************************************
*								         *
* A_PreFrag_Box - ANIM FUNC TO START A FRAGGER SHOW USING		 *
* 			PreFrag_Box.					 *
* AARG+,L = FRAGGER SCRIPT						 *
* AARG+,L = 16.16 Z Absolute Max Velocity				 *
* AARG+,L = 16.16 X and Y Absolute Max Velocity				 *
*								         *
**************************************************************************
A_PreFrag_Box
	calla	GETAFARG_LONG		;Get the script
	move	A0,A1			;Keep it here
	calla	GETAFARG_LONG		;Get the Z velocity
	move	A0,A3			;Pass it here
	calla	GETAFARG_LONG		;Get the X and Y velocity
	calla	PreFrag_Box		;BLOW RANDOMLY OUT OR UP
	move	A1,B14			;Right place at the right time
	CALLA	Fragger			;And get it goin' Boy
	MOVE	A8,*A0(FPDATA),L	;Pass pointer to parent
	RETS

**************************************************************************
*								         *
* A_PreFrag_Gun - ANIM FUNC TO START A FRAGGER SHOW USING PreFrag_Gun	 *
* 									 *
* *A8(OPLAYER),L = Ptr to player, if zero, no fragments are made.	 *
* AARG+,L = FRAGGER SCRIPT						 *
* AARG+,L = 16.16 Z Absolute Max Velocity				 *
* AARG+,L = 16.16 X and Y Absolute Max Velocity				 *
*								         *
**************************************************************************
A_PreFrag_Gun
	move	*A8(OPLAYER),A2,L	;Get the players data area
	jrnz	APG_Go			;BR = It's valid
      	rets
APG_Go
	calla	GETAFARG_LONG		;Get the script
	move	A0,A1			;Keep it here
	calla	GETAFARG_LONG		;Get the box
	move	A0,A4			;Pass it here
	calla	GETAFARG_LONG		;Get the Z velocity
	move	A0,A3			;Pass it here
	calla	GETAFARG_LONG		;Get the X and Y velocity
	calla	PreFrag_Gun		;BLOW RANDOMLY OUT OR UP
	move	A1,B14			;Right place at the right time
	JAUC	Fragger			;And get it goin' Boy

**************************************************************************
*								         *
* A_PreFrag_Rain - ANIM FUNC TO START A FRAGGER SHOW USING PreFrag_Rain	 *
* 									 *
* *A8(OPLAYER),L = Ptr to player, if zero, no fragments are made.	 *
* AARG+,L = FRAGGER SCRIPT						 *
* AARG+,L = 16.16 Z Absolute Max Velocity				 *
* AARG+,L = 16.16 X and Y Absolute Max Velocity				 *
*								         *
**************************************************************************
A_PreFrag_Rain
	calla	GETAFARG_LONG		;Get the script
	move	A0,A1			;Keep it here
	calla	GETAFARG_LONG		;Get the Z velocity
	move	A0,A3			;Pass it here
	calla	GETAFARG_LONG		;Get the X and Y velocity
	calla	PreFrag_Rain		;BLOW RANDOMLY OUT OR UP
	move	A1,B14			;Right place at the right time
	JAUC	Fragger			;And get it goin' Boy

**************************************************************************
*								         *
* A_PRINT_SCORE - ANIM FUNC TO SHOW A SCORE UPON A GIVEN OBJECT.	 *
* 		AND THEN AWARD THAT SCORE.				 *
* A8 = PTR TO OBJECT							 *
* *A8(OPLAYER),L = PLAYER GETTING SCORE					 *
* AARG+,L = SCORE							 *
*								         *
**************************************************************************
A_PRINT_SCORE
	CALLA	GETAFARG_LONG	
	MOVE	A0,A1
	MOVE	*A8(OPLAYER),A2,L
	JAUC	PRINT_SCORE

**************************************************************************
*								         *
* A_RAND_AnimSLP - ANIM FUNC TO SET A RANDOM AnimSLP VALUE IN THE	 *
* 		GIVEN RANGE						 *
* A8 = OBJECT TO SET							 *
* AARG+,W = LOWEST SLEEP						 *
* AARG+,W = HIGHEST SLEEP						 *
*								         *
**************************************************************************
A_RAND_AnimSLP
	CALLA	GETAFARG_LONG
	MOVY	A0,A1
	SRA	16,A1
	ZEXT	A0
	CALLA	RANGERND
	MOVB	A0,*A8(AnimSLP)
	RETS

**************************************************************************
*								         *
* A_SET_RANDSLP - ANIM FUNC TO SET parameters in ODATA for ADJUSTABLE	 *
* 				RANDOM SLEEPING				 *
* A8 = OBJECT TO SET							 *
* AARG+,W = LOWEST START SLEEP						 *
* AARG+,W = HIGHEST START SLEEP						 *
* AARG+,W = LOWEST END SLEEP						 *
* AARG+,W = HIGHEST END SLEEP						 *
* AARG+,W = DELTA EACH SLEEP						 *
* AARG+,W = DELTA EACH SLEEP						 *
*								         *
**************************************************************************
A_SET_RANDSLP
	CALLA	GETAFARG_LONG
	move	a0,*a8(ODATA+40h),L
	CALLA	GETAFARG_LONG
	move	a0,*a8(ODATA+60h),L
	CALLA	GETAFARG_LONG
	move	a0,*a8(ODATA+80h),L
	RETS

A_ADJ_RANDSLP
	move	*a8(ODATA+40h),a1
	move	*a8(ODATA+50h),a0
	move	a0,a2
	calla	RANGERND
	movb	a0,*a8(AnimSLP)

	move	a8,a6
	addi	ODATA+40h,a6
	callr	AdjRandSlp	; adjust min sleep
	move	a1,*a6		; new min stored

	move	a2,a1
	addk	16,a6
	callr	AdjRandSlp	; adjust max sleep
	move	a1,*a6		; new max stored

	rets

*
*	a6 = ptr to current value
*	a6(20h) = final value
*	a6(40h) = delta
*	a1 = current value
*
AdjRandSlp:
	move	*a6(20h),a4	; limit
	move	*a6(40h),a5	; delta
	jrn	ARSnegdelt
	add	a5,a1
	cmp	a4,a1
	jrle	newok
	jruc	newng

ARSnegdelt:
	add	a5,a1
	cmp	a4,a1
	jrge	newok
newng:
	move	a4,a1		; use min
newok:
	rets


**************************************************************************
*								         *
* A_SET_OZVEL - ANIM FUNC TO SET THE OZVEL FIELD OF AN OBJECT.		 *
* A8 = PTR TO OBJECT							 *
* AARG+,L = NEW OZVEL							 *
*								         *
* A_CLR_OZVEL - ANIM FUNC TO CLR THE OZVEL FIELD OF AN OBJECT.		 *
* A8 = PTR TO OBJECT							 *
*      NO ARGUMENT						         *
*								         *
**************************************************************************
A_SET_OZVEL
	CALLA	GETAFARG_LONG
	MOVE	A8,A7
	CALLA	GET_HEAD_PART
	MOVE	A0,*A8(OZVEL),L
	RETS

A_CLR_OZVEL
	CALLA	GET_HEAD_PART
	CLRM	*A8(OZVEL),L
	RETS

**************************************************************************
*								         *
* A_SET_OXVEL - ANIM FUNC TO SET THE X VELOCITY OF AN OBJECT. IF	 *
* 		OBJECT IS FLIPPED, THE VALUE IS NEGATED.		 *
* A8 = PTR TO OBJECT							 *
* AARG+,L = OXVEL							 *
*								         *
**************************************************************************
A_SET_OXVEL
	CALLA	GETAFARG_LONG	
	MOVE	*A8(OCTRL),A14,W	
	BTST	B_FLIPH,A14
	JRZ	ASO_NOW
	NEG	A0
ASO_NOW
	MOVE	A0,*A8(OXVEL),L			
	RETS

**************************************************************************
*								         *
* A_CLR_OXVEL - ANIM FUNC TO CLR THE OXVEL FIELD OF AN OBJECT.		 *
* A8 = PTR TO OBJECT							 *
*								         *
**************************************************************************
A_CLR_OXVEL
	CALLA	GET_HEAD_PART
	CLRM	*A8(OXVEL),L
	RETS

**************************************************************************
*								         *
* A_SET_OYVEL - ANIM FUNC TO SET THE Y VELOCITY OF AN OBJECT. IF	 *
* 		OBJECT IS FLIPPED, THE VALUE IS NEGATED.		 *
* A8 = PTR TO OBJECT							 *
* AARG+,L = OYVEL							 *
*								         *
**************************************************************************
A_SET_OYVEL
	CALLA	GETAFARG_LONG	
	MOVE	*A8(OCTRL),A14,W	
	BTST	B_FLIPV,A14
	JRZ	ASOY_NOW
	NEG	A0
ASOY_NOW
	MOVE	A0,*A8(OYVEL),L			
	RETS

A_CLR_OYVEL
	CALLA	GET_HEAD_PART
	CLRM	*A8(OYVEL),L
	RETS

**************************************************************************
*								         *
* A_STRT_ANIM - ANIM FUNC TO START ANOTHER ANIMATION.			 *
* A8 = PTR TO OBJECT TO START						 *
* AARG+,L = PTR TO ANIM SCRIPT						 *
*								         *
**************************************************************************
A_STRT_ANIM
	CALLA	GETAFARG_LONG
	MOVE	A0,A1
	JAUC	STRT_ANIM

**************************************************************************
*								         *
* A_TOGGLE_FLPS - ANIM FUNC TO TOGGLE THE GIVEN FLIP BITS.		 *
* A8 = PTR TO OBJECT.							 *
* AARG+,W = FLIP BITS TO TOGGLE						 *
*								         *
**************************************************************************
A_TOGGLE_FLPS
	CALLA	GETAFARG_WORD
	JAUC	TOGGLE_FLPS

**************************************************************************
*								         *
* A_TOGGLE_FLIP - ANIM FUNC TO TOGGLE THE GIVEN FLIP BITS OF A		 *
* 		SINGLE OBJECT.						 *
* A8 = PTR TO OBJECT							 *
* AARG+,W = FLIP BITS TO TOGGLE						 *
*								         *
**************************************************************************
A_TOGGLE_FLIP
	CALLA	GETAFARG_WORD
	JAUC	TOGGLE_FLIP

**************************************************************************
*								         *
* A_DEL_DAMAGE - ANIM FUNC TO DELETE THE DAMAGE FOR A GIVEN PART.	 *
* A8 = PTR TO PART							 *
* AARG+,W = OID OF DAMAGE						 *
*								         *
**************************************************************************
A_DEL_OID_DAMAGE
;I DID THIS SO ROUTINE CAN ALSO BE CALLED BY NON-ANI ROUTINES
	MMTM	SP,A0,A1,A6,A8
	movi	OID_DAMAGE,A0
	CALLR	GotDamId
	MMFM	SP,A0,A1,A6,A8
	RETS

A_DEL_DAMAGE
	CALLA	GETAFARG_WORD
GotDamId
	MOVB	*A8(OPARTID),A1
	CALLA	GET_HEAD_PART
ADD_LP
	MOVE	*A8(OID),A14,W
	CMP	A0,A14
	JRNE	ADD_NXT
	MOVB	*A8(DAMAGE_PARTID),A14
	CMP	A1,A14
	JRNE	ADD_NXT
	MOVE	*A8(OPARTS),A6,L
	CALLA	DELETE_OBJ
	MOVE	A6,A8
	JRNZ	ADD_LP
	RETS
ADD_NXT
	MOVE	*A8(OPARTS),A8,L
	JRNZ	ADD_LP
	RETS



**************************************************************************
*								         *
* A_OFF_DELETE_OBJ - ANIM FUNC TO SIMPLY DELETE AN OBJECT IF IT		 *
* 		    IS OFF SCREEN.					 *
* A8 = PTR TO OBJECT.							 *
*								         *
**************************************************************************
A_OFF_DELETE_OBJ
	CALLA	GET_HEAD_PART
	CALLA	SCRTST
	JANE	DELETE_OBJ
	RETS
	

**************************************************************************
*								         *
* A_OFF_KILL_OBJ - ANIM FUNC TO DELETE AN OBJECT and KILL ANY PROC IT IS *
*                       LINKED TO IF IT IS OFF SCREEN. 			 *
* A8 = PTR TO OBJECT.							 *
*								         *
**************************************************************************
A_OFF_KILL_OBJ
	CALLA	SCRTST
	JRZ	nokill
	calla	DELETE_OBJ_PROC
nokill:
	RETS
	


**************************************************************************
*								         *
* 	A_ONSCREEN							 *
* 									 *
* 	Anim func to branch animation script if object is currently	 *
* 	ON screen.  Uses the B_OFSCRN bit set by VELADD.		 *
* 									 *
* 	NOTE: This should be changed so that if calling with the	 *
* 		master part, the check is done over all parts.		 *
* 									 *
* 	A8 = Ptr to object.						 *
* 	AARG+,L = Animation branch address				 *
*								         *
**************************************************************************
A_ONSCREEN
	CALLA	GETAFARG_LONG
	MOVB	*A8(OFLAGS),A14		;Are we onscreen?
	JRN	AO_NOBRANCH		;BR = No
;	CALLA	SCRTST
;	JRNE	AO_NOBRANCH
	MOVE	A0,A1
	JAUC	STRT_ANIM
AO_NOBRANCH
	RETS


**************************************************************************
*								         *
* 	A_OFFSCREEN							 *
* 									 *
* 	Anim func to branch animation script if object is currently	 *
* 	OFF screen.  Uses the B_OFSCRN bit set by VELADD.		 *
* 									 *
* 	NOTE: This should be changed so that if calling with the	 *
* 		master part, the check is done over all parts.		 *
* 									 *
* 	A8 = Ptr to object.						 *
* 	AARG+,L = Animation branch address				 *
*								         *
**************************************************************************
A_OFFSCREEN
	CALLA	GETAFARG_LONG

;	MOVB	*A8(OFLAGS),A14		;Are we offscreen?
;	JRNN	AOFF_NOBRANCH		;BR = No

	CALLA	SCRTST
	JREQ	AOFF_NOBRANCH		;BR = Not offscreen

	MOVE	A0,A1
	JAUC	STRT_ANIM
AOFF_NOBRANCH
	RETS

**************************************************************************
*								         *
* A_INIT_AnimSLP - Anim Func to initialize the AnimSLP field of		 *
* 		a given object.						 *
* A8 = Ptr to Object							 *
* AARG+,W = Initial Value						 *
*								         *
**************************************************************************
A_INIT_AnimSLP
	CALLA	GETAFARG_WORD
	MOVB	A0,*A8(AnimSLP)
	RETS

**************************************************************************
*								         *
* A_INIT_AnimSLP_Var - Anim Func to initialize the AnimSLP field of	 *
* 		a given object with the contents of a RAM word.		 *
* A8 = Ptr to Object							 *
* AARG+,L = Word containing AnimSLP					 *
*								         *
**************************************************************************
A_INIT_AnimSLP_Var:
	CALLA	GETAFARG_LONG
	move	*a0,a0
	andi	7fh,a0
	jrnz	val_ok
	inc	a0		; make sure it's not 0
val_ok:
	MOVB	A0,*A8(AnimSLP)
	RETS

**************************************************************************
*								         *
* A_INC_AnimSLP - ANIM FUNC TO INCREMENT THE AnimSLP FIELD OF		 *
* 		A GIVEN OBJECT BY 1.					 *
* A8 = PTR TO OBJECT							 *
* AARG+,W = MAX AnimSLP VALUE						 *
*								         *
**************************************************************************
A_INC_AnimSLP
	CALLA	GETAFARG_WORD
	MOVB	*A8(AnimSLP),A14
	INC	A14
	CMP	A0,A14
	JRLS	AIA_STUFF
	MOVE	A0,A14
AIA_STUFF
	MOVB	A14,*A8(AnimSLP)
	RETS

**************************************************************************
*								         *
* A_OFFOPP - ANIM FUNC TO BRANCH IF OBJECT IS OFF OF THE OPPOSITE	 *
* 		SIDE OF THE SCREEN.					 *
* A8 = PTR TO ANY PART.							 *
* AARG+,L = BRANCH							 *
*								         *
**************************************************************************
A_OFFOPP
	CALLA	GETAFARG_LONG		;GET THE BRANCH FIRST JUST IN CASE
	MOVE	A0,A1
	CALLA	GET_HEAD_PART
	CALLA	SCRTST			;OFF SCREEN YET?
	JREQ	AOO_X			;BR = NO
	MOVE	@SCRNTL+16,A2,W
	MOVI	M_FLIPH,A0	
	MOVE	*A8(OCTRL),A4,W		
	MOVE	*A8(ODAG),A3,W
	CMP	A2,A3
	JRLT	AOO_LEFT
*HE'S OFF THE RIGHT SIDE OF THE SCREEN NOW.
	BTST	B_FLIPH,A4		;IS HE FACING LEFT?
	JRZ	SetAnim			;BR = NO, THEN HE'S OPPOSITE
	RETS
*HE'S OFF THE LEFT SIDE OF THE SCREEN NOW.
AOO_LEFT
	BTST	B_FLIPH,A4		;IS HE FACING RIGHT?
	JRNZ	SetAnim			;BR = NO
AOO_X
	RETS

**************************************************************************
*								         *
* 	USE DEL ROUTINES FOR ENEMIES ONLY, THEY WILL TRY TO DEC		 *
* 	ENEMY COUNTS WHEN DELETING.					 *
*								         *
**************************************************************************

**************************************************************************
*								         *
* 	A_OFFOPP_DEL							 *
* 									 *
* 	Anim func to delete an enemy if it is off of the opposite side	 *
* 	of the screen.  This assumes that the unflipped version is	 *
* 	facing right.  Delete will handle all necessary enemy		 *
* 	accounting.							 *
* 									 *
* 	A8 = Ptr to any part						 *
*								         *
**************************************************************************
A_OFFOPP_DEL
	CALLA	GET_HEAD_PART
	CALLA	SCRTST
	JREQ	AOD_X			;BR = Not offscreen yet

	MOVE	@SCRNTL+16,A1,W		;Now let's see which side
	MOVE	*A8(OCTRL),A4,W		
	MOVE	*A8(ODAG),A3,W
	CMP	A1,A3
	JRLT	AOD_LEFT
*
* He's off of the right side of the screen
*
	BTST	B_FLIPH,A4		;Is he currently facing left?
	JAZ	DELETE_ENEMY		;BR = No, then he's gone
	RETS
*
* He's off of the left side of the screen
*
AOD_LEFT
	BTST	B_FLIPH,A4		;Is he currently facing right?
	JANZ	DELETE_ENEMY		;BR = No, then he's gone
AOD_X
	RETS

**************************************************************************
*								         *
* A_OFFSCRN_DEL - ANIM FUNC TO DELETE AN OBJ IF ITS OFSCRN BIT IS SET	 *
* 	                 						 *
* A8 = PTR TO AN OBJ							 *
*								         *
**************************************************************************
A_OFFSCRN_DEL
	move	*a8(OPART1),a0,L	; multi?
	jrnz	aof_multi
	move	*a8(OFLAGS),a14
	btst	B_OFSCRN,a14
	janz	DELETE_OBJ_PROC
aofX:
	RETS

aof_multi:
	move	*a0(OFLAGS),a14
	btst	B_OFSCRN,a14
	jrz	aofX			; don't delete if any part onscreen
	move	*a0(OPARTS),a0,L
	jrnz	aof_multi
	move	*a8(OPART1),a8,L	; multi?
	jauc	DELETE_OBJ_PROC

**************************************************************************
*								         *
* A_STAY_TIL_ZW_LT  - STAY HERE UNTIL Z WORLD < some value		 *
* 	param 1 = Z world value						 *
*								         *
*  	  This parameter can be an immediate value supplied		 *
*  	  in the animation OR						 *
*  	  you can supply an ADDRESS in the animation and the 		 *
*  	  desired Z will be taken from that address!			 *					     
*								         *
**************************************************************************
A_STAY_TIL_ZW_LT:
	CALLA	GETAFARG_LONG	; target Z (or RAM address) in a0
	cmpi	10000000h,a0
	jrlt	assume_val
	move	*a0,a0,L	; if address, get target Z
assume_val:
	move	*a8(OZVAL),a1,L
	move	@ZBASE,a14,L
	sub	a14,a1		; current Z in a1
	cmp	a0,a1		
	jrlt	ALIZGX		; if current < target, move on
	move	*a8(AnimFrm),a14,L	; otherwise, stay here
	subi	70h,a14
	move	a14,*a8(AnimFrm),L
ALIZGX:
	rets


**************************************************************************
*								         *
* A_STAY_TIL_GRND_HIT - ANIM FUNC TO STAY PUT UNTIL OBJECT HITS GRND	 *
*		 (Then cancel YVEL and YACCEL and place at ground)	 *
*								         *
* A8 = PTR TO OBJECT							 *
*								         *
**************************************************************************
A_STAY_TIL_GRND_HIT:
	move	@YWORLD,a1,L
	MOVE	@WORLD_GRNDOFF,A14,L
	ADD	A14,A1
	move	*a8(OYVAL),a14,L
	cmp	a1,a14
	jrlt	not_theryet
;	move	a1,*a8(OYVAL),L
	clr	a14
	move	a14,*a8(OYACCEL),W
	move	a14,*a8(OYVEL),L
	CALLA	SET_ONGRND
	rets
not_theryet:
	move	*a8(AnimFrm),a14,L
	subi	50h,a14,L
	move	a14,*a8(AnimFrm),L
	rets



	.DEF	A_STAY_TIL_YVEL_POS

A_STAY_TIL_YVEL_POS:
	move	*a8(OYVEL),a14,L
	jrn	not_theryet
	rets


**************************************************************************
*								         *
* A_STAY_TIL_ONSCRN - ANIM FUNC TO STAY PUT UNTIL OBJECT IS ON SCREEN  	 *
*			 (This uses SCRTST to check)		         *
*								         *
* A8 = PTR TO OBJECT							 *
*								         *
**************************************************************************
A_STAY_TIL_ONSCRN
	move	*a8(OFLAGS),a14		;
    	btst	B_OFSCRN,a14		;
	jrz	ASTOX			;
	move	*a8(AnimFrm),a14,L	; otherwise, stay here
	subi	50h,a14
	move	a14,*a8(AnimFrm),L
ASTOX:
	RETS

**************************************************************************
*								         *
* 	A_STAY_TIL_OFFSCRN						 *
* 									 *
* 	Anim func to stay put until offscreen.				 *
* 									 *
* 	A8 = Ptr to head part						 *
*								         *
**************************************************************************
A_STAY_TIL_OFFSCRN
	CALLA	SCRTST
	JRNE	ASTOF_X		;BR = Offscreen now
	SUBIM	50H,*A8(AnimFrm),L
ASTOF_X
	RETS

**************************************************************************
*								         *
* A_STAY_TIL_WY_EQ  - STAY HERE UNTIL WORLD Y == some value
* 	param 1 = world y value
*								         *
**************************************************************************
A_STAY_TIL_WY_GT:
	CALLA	GETAFARG_WORD	; target Y in a0
	sll	16,a0
	move	@YBASE,a14,L
	sub	a14,a0
	move	*a8(OYVAL),a1,L
	cmp	a0,a1		
	jrgt	ASTWY0
	jruc	stick

A_STAY_TIL_WY_LT:
	CALLA	GETAFARG_WORD	; target Y in a0
	sll	16,a0
	move	@YBASE,a14,L
	sub	a14,a0
	move	*a8(OYVAL),a1,L
	cmp	a0,a1		
	jrlt	ASTWY0		; if current < target, move on
stick:
	move	*a8(AnimFrm),a14,L	; otherwise, stay here
	subi	60h,a14
	move	a14,*a8(AnimFrm),L
	rets

ASTWY0:
	CLRM	*a8(OYVEL),L
	move	a14,*a8(OYACCEL),W
ASTWYlp:
	move	a0,*a8(OYVAL),L
	move	*a8(OPARTS),a8,L
	jrnz	ASTWYlp

	rets


**************************************************************************
*								         *
* A_STAY_TIL_SY_LT  - STAY HERE UNTIL SCREEN Y < some value
* 	param 1 = screen y value
*								         *
**************************************************************************
A_STAY_TIL_SY_LT:
	CALLA	GETAFARG_WORD	; target Y in a0
	move	*a8(ODAGY),a1
	cmp	a0,a1		
	jrlt	ASTSYX		; if current < target, move on
	move	*a8(AnimFrm),a14,L	; otherwise, stay here
	subi	60h,a14
	move	a14,*a8(AnimFrm),L
ASTSYX:
	rets


**************************************************************************
*								         *
* A_RAND_OXVEL - ANIM FUNC TO SET THE X VELOCITY OF AN OBJECT. IF	 *
* 		OBJECT IS FLIPPED, THE VALUE IS NEGATED.		 *
* A8 = PTR TO OBJECT							 *
* AARG+,L = OXVEL							 *
*								         *
**************************************************************************
A_RAND_OXVEL
	CALLA	GETAFARG_LONG		; min
	move	a0,a1
	CALLA	GETAFARG_LONG		; max
	calla	RANGRAND
	MOVE	*A8(OCTRL),A14,W	
	BTST	B_FLIPH,A14
	JRZ	ARXV
	NEG	A0
ARXV:
	MOVE	A0,*A8(OXVEL),L			
	RETS

**************************************************************************
*								         *
* A_Set_LOOP_STRT - ANIM FUNC TO MAKE THE NEXT FRAME THE START OF THE    *
*                   SCRIPT SO THAT YOU LOOP BACK TO THIS POINT AT THE    *
*                   END.						 *
* A8 = PTR TO OBJECT							 *
*								         *
**************************************************************************
A_Set_LOOP_STRT
	CLRB	*a8(AnimLoop)	       
	move	*a8(AnimFrm),*a8(AnimScr),L
	rets


**************************************************************************
*								         *
* A_INC_Var_Word - ANIM FUNC TO INCREMENT a word variable 		 *
*								         *
* AARG+,L = Address of variable						 *
*								         *
**************************************************************************
A_INC_Var_Word:
	calla	GETAFARG_LONG		; address of word
	move	*a0,a14
	inc	a14
	move	a14,*a0
	rets


**************************************************************************
*								         *
* A_OZVAL_DELTA - ANIM FUNC TO change an objects ZVAL			 *
*								         *
* AARG+,W = Delta							 *
*								         *
**************************************************************************
A_OZVAL_DELTA:
	calla	GETAFARG_WORD		; delta (sign-extended)
	move	*a8(OZVAL),a14,L
	add	a0,a14
	move	a14,*a8(OZVAL),L
	rets


**************************************************************************
*								         *
* A_SET_SCALE - ANIM FUNC TO set the scale of a manually scaled object	 *
*								         *
* AARG+,W = Scale							 *
*								         *
**************************************************************************
A_SET_SCALE:
	move	*a8(OFLAGS),a14
	btst	B_MANSCALE,a14
	jrz	ASS_abt			; not manually scaled, abort
	calla	GETAFARG_WORD		; new scale
	move	a0,a5
	calla	SET_SCALE_MANUAL
ASS_abt:
	rets



	.end
