/*	MAIN linker command file					*/
-e SETUP			/* entry point of program		*/
-f 0xFFFF			/* fill unspecified memory with value	*/
-o GX.out			/* specify output file			*/
-m GX.map			/* map file				*/
-s				/* Kill the symbol table		*/

/*   KEEP .OBJs ALPHABETICAL!!  */

GX.OBJ			/* INITS AND INTS		*/
GXAERO.OBJ		/* AEROSMITH ROUTINES		*/
GXAERO2.OBJ		/* AEROSMITH ROUTINES		*/
GXAFUNC.OBJ		/* GENERAL ANIMATION FUNCTIONS  */
GXATT.OBJ		/* ATTRACT MODE			*/
GXATT2.OBJ		/* ATTRACT MODE			*/
GXBEEK1.OBJ		/* JUNGLE WAVE - beekeeper	*/
GXBEEK2.OBJ		/* JUNGLE WAVE - beekeeper	*/
GXBEEK3.OBJ		/* JUNGLE WAVE - beekeeper	*/
GXBGFX.OBJ		/* BACKGROUND EFFECT STUFF	*/
GXBILL.OBJ		/* BILL CODE			*/
GXBLOOD.OBJ		/* Blood effects 		*/
GXBONUS.OBJ		/* BONUS SCREEN 		*/
GXBUG.OBJ		/* JUNGLE BOSS BUG		*/
GXBUS.OBJ		/* SCHOOL BUS			*/
GXBZERK.OBJ		/* The Berzerker guy		*/
GXC.OBJ			/* IMAGE HANDLER		*/
GXCOG.OBJ		/* JACK THE COGHEAD		*/
GXCONTRL.OBJ		/* CONTROL ROUTINES		*/
GXD.OBJ			/* IMAGE HANDLER		*/
GXDESK.OBJ		/* The Mech-Desk		*/
GXENEMY.OBJ		/* ENEMY UTILITY ROUTINES	*/
GXFORK.OBJ		/* Fork lift enemy		*/
GXFSTAGE.OBJ		/* FINAL STAGE 			*/
GXHELGA.OBJ		/* Head mistress Helga  	*/
GXHELI.OBJ		/* HELICOPTER ROUTINES		*/
GXHELI2.OBJ		/* HELICOPTER ROUTINES PART 2	*/
GXJUNGLE.OBJ		/* JUNGLE WAVE			*/
GXKERRI.OBJ		/* Kerri Hoskins own file	*/
GXLA1.OBJ		/* LA UNIVERSE ROUTINES 1	*/
GXLA2.OBJ		/* LA UNIVERSE ROUTINES 2	*/
GXLA3.OBJ		/* LA UNIVERSE ROUTINES 3	*/
GXMONDOR.OBJ		/* MONDOR THE MAGNIFICENT	*/
GXMONDR2.OBJ		/* MONDOR THE MAGNIFICENT PT.2	*/
GXNINJA.OBJ		/* The Non-Ninja		*/
GXNONBOY.OBJ		/* NONBOY ROUTINES		*/
GXNOBOY2.OBJ		/* MORE NONBOY ROUTINES		*/
GXPERRY.OBJ		/* JOE PERRY ROUTINES		*/
GXPLAYER.OBJ		/* PLAYER UTILITY ROUTINES	*/
GXPOWER.OBJ		/* POWER UP STUFF		*/
GXSCROLL.OBJ		/* SCROLL ROUTINES		*/
GXSCROL2.OBJ		/* SCROLL ROUTINES ptII		*/
GXSCROL3.OBJ		/* SCROLL TABLES		*/
GXJSCROL.OBJ		/* SCROLL TABLE for jungle 	*/
GXSCORE.OBJ		/* SCORE AREA MAINTENANCE	*/
GXUNIFX.OBJ		/* UNIVERSE FX ROUTINES		*/
GXUNILNK.OBJ		/* UNIVERSE LINK ROUTINES	*/
GXUNIV.OBJ		/* UNIVERSE ROUTINES	 	*/
GXUNIV1.OBJ		/* UNIVERSE OBJECT ROUTINES 1	*/
GXUNIJAP.OBJ		/* Japan Universe		*/
GXUNIJP2.OBJ		/* Japan Pt. 2 			*/
GXUNISEQ.OBJ		/* UNIVERSE SEQUENCES		*/
GXWAVE.OBJ		/* WAVE TABLES			*/
GXWARREN.OBJ		/* WARREN CODE			*/
GXYJAK.OBJ		/* Yellow jacket		*/
GXUNZIP.OBJ             /* DECOMPRESSION  		*/
GXSYSTEM.RLO		/* LINK IN THE SYSTEM STUFF	*/
GXDIAG.RLO		/* LINK IN THE DIAGNOSTICS CODE */

MEMORY        			/* set up memory for sdb board */
{
 SCRATCH	: org = 0x2000c000,	len = 0x7f4000

 WAR_RAM    	: org = 0x20800000,   	len = 0x2000
 WAR_ROM    	: org = 0xFF800000,   	len = 0x2000

 CODE_RAM	: org = 0x20802000,	len = 0x7F7000
 CODE_ROM	: org = 0xFF802000,	len = 0x7DD000

 COLD_ROM	: org = 0xFFFDF000,	len = 0x20B80

 GSPOT		: org = 0x20FF9000,	len = 0x1000 	  /* reserved for GSPOT */
 TV		: org = 0x20FFA000,	len = 0x5bc0 	  /* reserved for toddview */

 CKSMAREA	: org = 0xFFFFFB80,	len = 0x80

 IROM		: org = 0xF8000000,	len = 0x7800000 

 TRAP_RAM	: org = 0x20FFFC00,	len = 0x400 
 TRAP_ROM	: org = 0xFFFFFC00,	len = 0x400 
}
/* These are Global constants that the program will use to load code	*/
/* You must change these to reflect the above code mappings.		*/
code_start = 0xFF800000;
code_end = 0xFFFDF000;
code_dest = 0x20800000;

vector_start = 0xFFFFFC00;
vector_end = 0;
vector_dest = 0x20FFFC00;


SECTIONS       /* linker sections directive */
 {
	VECTORS:	{}	load = TRAP_ROM, run = TRAP_RAM
	CKSUMS:		{}	> CKSMAREA
	IMAGES:		{}	> IROM
	GROUP:
	      {
		OFIXED: {}
	       .BSS: {}
	       .bss: {}
	      } > SCRATCH

	UNZIP:		{}	load = WAR_ROM, run = WAR_RAM

	GROUP:
	      {	
	       .text: {}
	       .TEXT: {}
	       .data: {}
	       .DATA: {}
	      }			load = CODE_ROM, run = CODE_RAM	

	COLDSTRT:	{}	> COLD_ROM

 }

