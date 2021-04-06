**************************************************************************
*																							    *
* 							GX GUNS AND PROJECTILES										 *
* 										EQUATE FILE											 *
*																							    *
**************************************************************************


**************************************************************************
*																							    *
* ROCKET, MIRV AND SHOTGUN OBJECT DATA AREA										 *
*																							    *
**************************************************************************

*STRUCT ROCKET+OBJ
RL_TARGET_OBJ	.EQU	ODATA		;UHL Ptr to Target Sight Object
RL_LAUNCH_TIME	.EQU	ODATA+20H	;UHL WAVEIRQS AT TIME OF LAUNCH

RL_GROUND_Z	.EQU	ODATA+040H	;UHL Z @ IMPACT WITH GROUND
RL_GROUND_X	.EQU	ODATA+060H	;UHL Z @ IMPACT WITH GROUND

;RL_TARGET_PLANE .EQU	ODATA+40H	;UHB PLANE WE WILL BLOW UP ON		
;RL_BGND_FLAG	.EQU	ODATA+48H	;UHB SET IF BACKGROUND TARGETED
;RL_BGND_Z	.EQU	ODATA+50H	;UHW LOW 16 BITS OF LOCKED OBJECT Z

RL_DURATION	.EQU	ODATA+80H	;UHW TIME IN TICKS TILL EXPLODE
RL_TYPE		.EQU	ODATA+90H	;UHB ROCKET TYPE
RL_SHOTGUN	.EQU	ODATA+98H	;UHB SHOTGUN FLAG

RL_INTENDED_OBJ	.EQU	ODATA+0A0H	;UHL Ptr to Object rocket is intended
					;	to hit.

;RL_DURATION	.EQU	ODATA+60H	;UHW TIME IN TICKS TILL EXPLODE
;RL_MIRV	.EQU	ODATA+70H	;UHB ROCKET MIRV FLAG
;RL_SHOTGUN	.EQU	ODATA+78H	;UHB SHOTGUN FLAG
*ENDSTRUCT						

**************************************************************************
*																							    *
* SIGHT TARGET STUFF																		 *
*																							    *
**************************************************************************

SIGHT_TARGET_OBJ	.EQU	ODATA	   ;UHL
SIGHT_ROCKET_OBJ	.EQU	ODATA+020H ;UHL
SIGHT_Y_OFFSET		.EQU	ODATA+040H ;UHL
SIGHT_X_OFFSET		.EQU	ODATA+060H ;UHL


**************************************************************************
*																							    *
* ROCKET TYPES																				 *
*																							    *
**************************************************************************

RTYPE_ROCKET	EQU	0
RTYPE_CD	EQU	1
RTYPE_LD	EQU	2
