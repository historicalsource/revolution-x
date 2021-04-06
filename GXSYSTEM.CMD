/*	MAIN linker command file					*/
-e SETUP			/* entry point of program		*/
-f 0xFFFF			/* fill unspecified memory with value	*/
-o GXSYSTEM.rlo			/* specify output file			*/
-m GXSYSTEM.map			/* map file				*/
-r				/* relocatable file			*/

GXRAM.OBJ		/* RAM ALLOCATONS 		*/
GXUTIL.OBJ		/* UTILITIES			*/
GXPALL.OBJ		/* PALETTE ROUTINES		*/
GXPROC.OBJ		/* MULTI-TASKER			*/
GXSND.OBJ		/* SOUND PROCESSOR		*/
GXUART.OBJ		/* UART HANDLER			*/
GXTRIG.OBJ		/* SIN, COS FUNCS		*/
GXTEXT.OBJ		/* TEXT PROCESSING ROUTINES	*/
GXMISC.OBJ		/* MISCELLANEOUS ROUTINES	*/
GXDRIVER.OBJ		/* COIL AND FLASH LAMPS		*/
GXFADE.OBJ		/* TODD'S PALETTE FADER		*/
GXCOLL.OBJ		/* SUPPLEMENTAL COLLISIONS	*/
GXBGDATA.OBJ		/* BACKGROUND GENERATOR		*/
GXBGND.OBJ		/* BACKGROUND GENERATOR		*/
GXTV.OBJ		/* TODDVIEW HOOKS		*/
IMGPAL.OBJ		/* PALETTE DATA			*/
IMGTBL.OBJ		/* GLOBAL IMAGE HEADERS		*/
BGNDTBL.OBJ		/* BACKGROUND TABLES		*/
BGNDPAL.OBJ		/* BACKGROUND PALETTES		*/
UNI00.OBJ		/* UNIVERSE TABLE		*/
UNI01.OBJ		/* UNIVERSE TABLE		*/
UNI02.OBJ		/* UNIVERSE TABLE		*/
UNI03.OBJ		/* UNIVERSE TABLE		*/
UNI04.OBJ		/* UNIVERSE TABLE		*/
UNI05.OBJ		/* UNIVERSE TABLE		*/
UNI06.OBJ		/* UNIVERSE TABLE	 	*/
UNI07.OBJ		/* UNIVERSE TABLE	 	*/

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
 TV		: org = 0x20FFA000,	len = 0x5bc0 	  /* reserved for toddview */
 CKSMAREA	: org = 0x20FFFBC0,	len = 0x40
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