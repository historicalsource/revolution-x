/*	MAIN linker command file					*/
-e SETUP			/* entry point of program		*/
-f 0xFFFF			/* fill unspecified memory with value	*/
-o GXDIAG.rlo			/* specify output file			*/
-m GXDIAG.map			/* map file				*/
-r				/* relocatable file			*/

GXMENU.OBJ		/* MENU PROCESSING			*/
GXDTST.OBJ		/* DIAGNOSTIC ROUTINES			*/
GXDUTL.OBJ		/* DIAG UTILITIES			*/
GXCMOS.OBJ		/* RANDOM ROUTINES			*/
GXHSTD.OBJ		/* HIGHSCORE TABLE			*/
GXCOIN.OBJ		/* COINAGE HANDLING ROUTINES		*/
GXWORD.OBJ		/* WORD SUBSTITUTIONS FOR STRINGS	*/
GXSYSFNT.OBJ		/* SYSTEM FONT IN PROGRAM ROM		*/
/*GXPRNT.OBJ*/		/* DEBUG PRINTER			*/
GXADJ.OBJ		/* GAME ADJUSTMENTS, LINK THIS LAST!!!	*/

MEMORY        			/* set up memory for sdb board */
{
 SCRATCH	: org = 0x2000c000,	len = 0x7f4000
 SEG1		: org = 0x20800000,	len = 0x1800 
 SEG2		: org = 0x20801800,	len = 0x800 
 SEG3		: org = 0x20802000,	len = 0x1000
 SEG5		: org = 0x20803000,	len = 0x800
 SEG4		: org = 0x20803800,	len = 0x800 
 WBDSEG6      	: org = 0x20804000,   	len = 0x2000
 DIAGSEG7      	: org = 0x20806000,   	len = 0x800
 ROM		: org = 0x20806800,	len = 0x7f2800 
 GSPOT		: org = 0x20FF9000,	len = 0x1000 	  /* reserved for GSPOT */
 TV		: org = 0x20FFA000,	len = 0x5b80 	  /* reserved for toddview */
 CKSMAREA	: org = 0x20FFFB80,	len = 0x80
 IROM		: org = 0xF8000000,	len = 0x7800000 
 TRAP31		: org = 0xFFFFFC00,	len = 0x400 
}

SECTIONS       /* linker sections directive */
 {
	VECTORS:  {} 	> TRAP31
	CKSUMS: {}	> CKSMAREA
	IMAGES:   {}    > IROM
	GROUP:
	      {
		OFIXED: {}
	       .BSS: {}
	       .bss: {}
	      } > SCRATCH

	GROUP:
	      {	
	       .text: {}
	       .TEXT: {}
	       .data: {}
	       .DATA: {}
	      } > ROM	

	CACHE1:   {}    > SEG1
	CACHE2:   {}    > SEG2
	CACHE3:   {}    > SEG3
	CACHE4:   {}    > SEG4
	CACHE5:   {}    > SEG5
	UNZIP:    {}    > WBDSEG6
	DCACHE:   {}	> DIAGSEG7
 }
