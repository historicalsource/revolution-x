**************************************************************************
*								         *
* 			Mondor's Master Equate File			 *
*								         *
**************************************************************************

**************************************************************************
*								         *
* 	COPYRIGHT (C) 1993 MIDWAY MANUFACTURING COMPANY.		 *
* 		       ALL RIGHTS RESERVED.				 *
*								         *
**************************************************************************
*
*MONDOR OBJECT DATA DEFINITION
*

*Used by all parts, great and small
OHITS		EQU	ODATA		;UHL Rocket hits taken from player(s)
					;0-7:P1 HITS, 8-15:P2 HITS
					;16-23:P3 HITS, 24-31:P4 HITS

OMISSES		EQU	ODATA+020H	;UHB Number of consec. missed shots
ODAMAGE		EQU	ODATA+028H	;UHB Current damage level of object
OFLASHTIME	EQU	ODATA+030H	;UHB Time 'til unflash of object
OLASTANUM	EQU	ODATA+038H	;UHB Last animation number
OINVINCIBLE	EQU	ODATA+040H	;UHB I am invincible now!
O_BEING_DAMAGED	EQU	ODATA+048H	;UHB Currently being damaged.
OCHEWEDROCKET	EQU	ODATA+050H	;UHB Rocket flag (for explosion)
OROCKETHIT	EQU	ODATA+058H	;UHB Flag for rocket debounce
OCLRROCKETHIT	EQU	ODATA+060H	;UHB Time left 'til we clr OROCKETHIT
OCHUNK_HITS	EQU	ODATA+068H	;UHB Counter for hits to release chunks
OBULLET_HITS	EQU	ODATA+070H	;UHL Bullet hits taken from player(s)
					;0-7:P1 HITS, 8-15:P2 HITS
					;16-23:P3 HITS, 24-31:P4 HITS

*Used by the talking head only
OSCREAM_SND	EQU	ODATA+090H	;UHL Sound script used to scream
OSCREAM_SEV	EQU	ODATA+0B0H	;UHB Scream severity
OSCREAM		EQU	ODATA+0B8H	;UHB Scream level
OSCREAM_DUR	EQU	ODATA+0C0H	;UHB Duration of scream
OHEAD_IDLE	EQU	ODATA+0C8H	;UHB Idle timer for the head
OFB_PERC	EQU	ODATA+0D0H	;UHW % of not sending a FireBall

*Used by master parts of Mondor, Desk and FireBall
OXACCEL		EQU	ODATA+090H	;UHW X acceleration
*Used by the master parts of Mondor and Desk
OZACCEL		EQU	ODATA+0A0H	;UHW Z acceleration
OXBURN		EQU	ODATA+0B0H	;UHB X burn time for acceleration
OYBURN		EQU	ODATA+0B8H	;UHB Y burn time for acceleration
OZBURN		EQU	ODATA+0C0H	;UHB Z burn time for acceleration
OMOVE_TIMER	EQU	ODATA+0C8H	;UHB Timer until next move decision
OCENTER_FLAG	EQU	ODATA+0D0H	;UHB Go to center immediately
OCLRCENTER	EQU	ODATA+0D8H	;UHB Time left to clear center flag
OFFSCRN_TIME	EQU	ODATA+0E0H	;SHW Ticks totally offscreen
OPARTS_LOST	EQU	ODATA+0F0H	;UHB Total parts lost
OSHAKE_FIST	EQU	ODATA+0F8H	;UHB Flag to tell arms to shake fist
OTALK_WAIT	EQU	ODATA+100H	;UHW If non-zero, then don't talk
OPROJ_HIT	EQU	ODATA+110H	;UHB Projectile hit counter
OPROJ_CK_TIME	EQU	ODATA+118H	;UHB Time before checking projectile hit
ONOSET_ZVEL	EQU	ODATA+120H	;UHB If 1, then leave OZVEL alone
OCLRNOSETZVEL	EQU	ODATA+128H	;UHB Timer to clear above flag
OFDAM_GOING	EQU	ODATA+130H	;UHB Big damage is happening
OCLRFDAM	EQU	ODATA+138H	;UHB Timer to clear FDAM_GOING flag

*Used by the talking head only
OTALK_SND	EQU	ODATA+140H	;UHL sound to make for this sequence
OGUN_BLOWN	EQU	ODATA+160H	;UHB Tell Mondor a gun is gone
OMOMMY_FLAG	EQU	ODATA+168H	;UHB Set if Mondor used the Mommy line

*Used by the arms only
OSHOTS_TAKEN	EQU	ODATA+168H	;UHB Number of shot fired with this gun

*Used by all destructible Mondor parts
OPART_BLOW_FUNC	EQU	ODATA+170H	;UHL Function to call to blow part

*Used by all destructible desk parts
OPART_FINAL_CONT EQU	ODATA+170H	;UHL Continuation for final damage animation

*Used by the master part of Mondor only
ONOARM_TIME	EQU	ODATA+190H	;UHW Ticks with no arms
OARM_WAIT	EQU	ODATA+1A0H	;UHW If non-zero, then no arm action
OLEGS_GONE	EQU	ODATA+1B0H	;UHB This many legs are missing
OARMS_GONE	EQU	ODATA+1B8H	;UHB This many arms are missing
OSPITTING_FIRE	EQU	ODATA+1C0H	;UHB Mondor is currently spitting fire
OTHROWING_BOMB	EQU	ODATA+1C8H	;UHB Mondor is currently throwing a bomb

*Used by Desk master part only
ONOGAT_TIME	EQU	ODATA+190H	;UHW Ticks with no guns
OGAT_WAIT	EQU	ODATA+1A0H	;UHW If non-zero, then no gun action
OGATS_GONE	EQU	ODATA+1B0H	;UHB This many guns are missing
OFIRING_MISSLE	EQU	ODATA+1B8H	;UHB Desk is currently firing a missle
OMISSLE_PERC	EQU	ODATA+1C0H	;UHW % of pausing before firing missle
OMISSLE_WAIT	EQU	ODATA+1D0H	;UHW Wait this much time before next missle bay opens
OMISSLE_VULNER	EQU	ODATA+1E0H	;UHB All missle launchers vulnerable
OMLAUNCH_GONE	EQU	ODATA+1E8H	;UHB This many missle launchers gone

*Used by the talking head only
OBABBLE_BITS	EQU	ODATA+190H	;UHW Flag bits for babbling
OLAST_CURPLYRS	EQU	ODATA+1A0H	;UHB Last CURPLYRS value
OTALK_FLAG	EQU	ODATA+1A8H	;UHB Talk if set, index for phrase
OTALK_SCRIPT	EQU	ODATA+1B0H	;UHL Current talk script ptr
OCUR_SCREAM	EQU	ODATA+1D0H	;UHL Current scream sound
OCUR_SCREAM_SEV	EQU	ODATA+1F0H	;UHB Current scream severity
ONUM_DONE	EQU	ODATA+1F8H	;UHB Number of players when saying "You are done"

*Used by the arms and gatling guns only
ONO_GET		EQU	ODATA+190H	;UHB If true, then don't grab gun
ORAPIDCNT	EQU	ODATA+198H	;UHB Current Rapid Fire count
OSHOOTCNT	EQU	ODATA+1A0H	;UHB Count since last attack
OBURSTCNT	EQU	ODATA+1A8H	;UHB Counter for Rapid fire bursts
OBARREL		EQU	ODATA+1B0H	;UHB Barrel toggle flag
OGUN_IN_HAND	EQU	ODATA+1B8H	;UHB Flag to tell us when he has a gun

*Used by projectiles only
OPROJECT_PARENT	EQU	ODATA+0190H	;UHL Ptr to the object that spawned us
OPROJECT_TIME	EQU	ODATA+01B0H	;UHB Travel time for projectile

*Used by the thrusters only
OTHRUSTER_SND	EQU	ODATA+0190H	;UHL Sound to make for thruster
OTHRUSTER_SNDOFF EQU	ODATA+01B0H	;UHL Sound to turn thruster off

*Used by missle desk missle launcher parts only
OMISSLES_FIRED	EQU	ODATA+190H	;UHB Missles fired last bay opening
OFREAK_CNT	EQU	ODATA+198H	;UHB Freak-out count for shoulders

*Used by Josh the desk driver only
OJOSH_IDLE	EQU	ODATA+0C8H	;UHB Idle timer for the Joshster
OJOSH_ACTION	EQU	ODATA+0D0H	;UHB Action for Josh to do now

*Used by the mech-desk seat backs only
OSUB_SCRIPT	EQU	ODATA+190H	;UHL Current subtitle script ptr
OSUB_SND	EQU	ODATA+1B0H	;UHL Current sound that matches subtitle
OSUB_DURATION	EQU	ODATA+1D0H	;UHW Time left for this subtitle


*
*Some Mondor init equates
*
NUM_MONDOR_PARTS	.EQU	21

NUM_BODY_PARTS		.EQU	7	;Legs, Arms, Head, Chest

NUM_TORSO_PARTS		.EQU	2	;Number of pieces making up the Torso

*
*SOME MORE MONDOR EQUATES
*
MONDOR_FLASH_COLOR	.EQU	0101H
CRAFT_FLASH_COLOR	.EQU	0303H
MAX_DAMAGE_LEVEL	.EQU	3
;CHUNK_HITS		.EQU	5
BULLET_HITS		.EQU	15

NOARMS_PISSED		.EQU	600	;This many ticks with no arms = PISSED!

*Mondor's limits
MONDOR_ZMAX	.EQU	0E000H
MONDOR_ZMIN	.EQU	7000H
MONDOR_XMAX	.EQU	55H
MONDOR_XMIN	.EQU	-55H
MONDOR_YMAX	.EQU	-10H
MONDOR_YMIN	.EQU	-18H

*Mondor's limits when forced to center
MONDOR_ZMAX_C	.EQU	0B000H
MONDOR_ZMIN_C	.EQU	09000H
MONDOR_XMAX_C	.EQU	10
MONDOR_XMIN_C	.EQU	-10
MONDOR_YMAX_C	.EQU	-10H
MONDOR_YMIN_C	.EQU	-18H


MIN_FIRE_Z	.EQU	0A000H		;Mondor will not breath fire unless back this far
MIN_FIRE_Z_2	.EQU	06400H		;When Mondor has no arms

*Mondor's rail has these qualities
SLED_ZACCEL	.EQU	100H
SLED_ZACCEL_SRA	.EQU	8
SLED_XYACCEL	.EQU	4000H
SLED_XYACCEL_SRA .EQU	14

SLED_ZBRAKE	.EQU	100H
SLED_ZBRAKE_SRA	.EQU	8

SLED_XYBRAKE	.EQU	4000H
SLED_XYBRAKE_SRA .EQU	14

SLED_ZHOVER	.EQU	40H
SLED_XYHOVER	.EQU	800H

*TALKING SCRIPT EQUATES
TNUM_TAKE 	.EQU	1
TNUM_SUSHI	.EQU	2
TNUM_RIP	.EQU	3
TNUM_LAUGH	.EQU	4
TNUM_CMON	.EQU	5
TNUM_PRAY	.EQU	6
TNUM_NIGHT	.EQU	7
TNUM_DEVOUR	.EQU	8
TNUM_NOTHING	.EQU	9
TNUM_FLESH	.EQU	10
TNUM_BOOM	.EQU	11
TNUM_GUTS	.EQU	12
TNUM_COWARD	.EQU	13
TNUM_MOMMY	.EQU	14
TNUM_MONDOR	.EQU	15
TNUM_DONE	.EQU	16
TNUM_WORSE	.EQU	17
TNUM_GETUP	.EQU	18
TNUM_MORE	.EQU	19

*
*SOME MECH-DESK EQUATES
*
DESK_FLASH_COLOR	.EQU	3F3FH
MAX_DESK_DAMAGE_LEVEL	.EQU	1
DESK_BULLET_HITS	.EQU	15		;This many bullets = 1 rocket

NOGATS_PISSED		.EQU	600	;This many ticks with no gats = PISSED!

*Desk's limits
DESK_ZMAX	.EQU	11000H
DESK_ZMIN	.EQU	9000H
DESK_XMAX	.EQU	35H
DESK_XMIN	.EQU	-35H
DESK_YMAX	.EQU	0
DESK_YMIN	.EQU	-10H

*Desk's limits when forced to center
DESK_ZMAX_C	.EQU	0B000H
DESK_ZMIN_C	.EQU	09000H
DESK_XMAX_C	.EQU	10
DESK_XMIN_C	.EQU	-10
DESK_YMAX_C	.EQU	0
DESK_YMIN_C	.EQU	-20H
