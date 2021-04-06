**************************************************************************
*								         *
* CALCULATE_HORIZON - CALCULATE THE CURRENT HORIZON LINE, BASED		 *
* 			ON THE CURRENT STATE OF THE WORLD.		 *
* RETURNS:								 *
* 	A1 = CURRENT HORIZON						 *
* NOTE: TRASHES A0							 *
*								         *
**************************************************************************
CHANGE_ZFAR:
	move	a0,@ZFAR,L	;  (must be WORLD referenced!)
	
	MOVK	1,A14			;FORCE UNIVERSE UPDATE
	MOVE	A14,@UNIVERR,W

	jruc	CALC_HORZ_FROM_Z
CALCULATE_HORIZON
	MOVE	@ZFAR,A0,L
CALC_HORZ_FROM_Z:
	MOVE	@YWORLD,A1,L
	MOVE	@YBASE,A14,L
	ADD	A14,A1
	divs	a0,a1
	MOVE	@YHALF,A14,W
	ADD	A14,A1
;	srl	1,a1
;	sll	1,a1		; HORIZON MUST BE EVEN (for SRT_CLR)
	move	a1,@HORIZON,W	;THE REAL DEAL
	srl	1,a1
	sll	1,a1		; HORIZON MUST BE EVEN (for SRT_CLR)
	CMPI	0FEH,A1
	JRLE	IH_OK
	MOVI	0FEH,A1	
IH_OK
	MOVE	A1,@SRT_HORIZON,W	;SPECIAL CROPPED VERSION FOR SRT_CLEAR
	RETS
