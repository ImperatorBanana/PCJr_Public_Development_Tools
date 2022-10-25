rem *********************************
rem * Drive A contains a formated   *
rem * blank diskette with only this *
rem * batch file (SAMPLE2.BAT).     *
rem *                               *
rem * Drive B contains copy of your *
rem *  Assembler diskette.          *
rem *                               *
rem * If correct continue.          *
pause *******************************
copy b:masm.exe
copy b:cref.exe
copy b:trycom?m.asm
rem *********************************
rem * If you are using DOS 1.1,     *
rem * remove the Assembler diskette *
rem * from drive B and place your   *
rem * DOS diskette that has LINK.EXE*
rem * in drive B,                   *
rem * otherwise continue.           *
pause *******************************
copy b:link.exe
rem *********************************
rem * If you are using DOS 2. (or   *
rem * later), remove the Assembler  *
rem * diskette from drive B.        *
rem * otherwise continue.           *
pause *******************************
rem *********************************
rem * Place your DOS diskette that  *
rem * has COMMAND.COM in drive B.   *
pause *******************************
copy b:command.com
rem *********************************
rem * Place your DOS diskette that  *
rem * has EXE2BIN.EXE in drive B.   *
pause *******************************
copy b:exe2bin.exe
rem *********************************
rem * Remove DOS diskette           *
rem * from drive B.                 *
pause *******************************
dir
rem *********************************
rem * Directory of                  *
rem * Sample Session Diskette       *
pause *******************************
masm trycom1m,,,;
masm trycom2m,,,;
pause
dir trycom*
rem *********************************
rem * Directory of Sample Session   *
rem * files after the               *
rem * assembly process.             *
pause *******************************
cref trycom1m;
cref trycom2m;
pause
dir trycom*
rem *********************************
rem * Directory of Sample Session   *
rem * files after the               *
rem * assembly and cref process.    *
pause *******************************
del *.crf
rem *********************************
rem * The temporary .CRF files are  *
rem * not needed after running      *
rem * the CREF utility.             *
pause *******************************
link trycom1m+trycom2m,trycomm,trycomm/m;
rem *********************************
rem * The LINK message:             *
rem *  "Warning: No STACK segment"  *
rem *  "There was 1 error detected."*
rem * is expected because you are   *
rem * building a .COM file.         *
pause *******************************
dir trycom*
rem *********************************
rem * Directory of Sample Session   *
rem * files after the assembly,     *
rem * cref, and link process.       *
pause *******************************
del *.obj
rem *********************************
rem * The temporary .OBJ files are  *
rem * not needed after running      *
rem * the LINK utility.             *
pause *******************************
exe2bin trycomm trycomm.com
pause
dir trycom*
rem *********************************
rem * Directory of Sample Session   *
rem * files after the assembly,     *
rem * cref, link, and exe2bin       *
rem * process.                      *
pause *******************************
del trycomm.exe
rem *********************************
rem * The temporary .EXE file is not*
rem * needed after running the      *
rem * EXE2BIN utility.              *
pause *******************************
rem
rem *********************************
rem * Pressing any key after        *
rem * this pause executes the       *
rem * completed TRYCOMM.COM program.*
pause *******************************
trycomm
pause
rem *********************************
rem * This process demonstrated:    *
rem *   1. The use of a batch file. *
rem *   2. Sample of commands to    *
rem *      assemble, cref, link,    *
rem *      and exe2bin.             *
rem *   3. Produced a .COM style    *
rem *      program,  assembler      *
rem *      listing, cross reference,*
rem *      and link map.            *
rem *********************************
pause
rem *********************************
rem * Print or display              *
rem * the following files:          *
rem *                               *
rem *      produced by MASM         *
rem *   TRYCOM1M.LST   TRYCOM2M.LST *
rem *                               *
rem *      produced by CREF         *
rem *   TRYCOM1M.REF   TRYCOM2M.REF *
rem *                               *
rem *      produced by LINK         *
rem *   TRYCOMM.MAP                 *
pause *******************************
       *
rem *      produced by LINK         *
rem *   TRYCOMM.MAP                 *
pause **