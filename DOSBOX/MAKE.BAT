
rem This is just to test assembling the test program

echo off
del LEFTOVER\*.*
del BIN\main.exe
cd SRC
echo on
C:\DOSBOX\TOOLS\IBMMASM\MASM main.asm main.obj,main.lst,main.crf
if ERRORLEVEL 1 GOTO QUIT
C:\DOSBOX\TOOLS\IBMMASM\LINK main.obj,main.exe,,,
if ERRORLEVEL 1 GOTO QUIT
C:\DOSBOX\TOOLS\EXE2BIN.EXE main.exe
if ERRORLEVEL 1 GOTO QUIT
echo off
copy MAIN.BIN ..\BIN\MAIN.COM
del MAIN.BIN
del MAIN.EXE
copy *.lst ..\LEFTOVER\.
del *.lst
copy *.crf ..\LEFTOVER\.
del *.crf
copy *.obj ..\LEFTOVER\.
del *.obj
copy *.map ..\LEFTOVER\.
del *.map
cd ..

cd BIN
echo on
CRC.EXE MAIN.COM
echo off
copy MAIN.JRB ..\ROM\.
del MAIN.JRB
cd ..

:QUIT


