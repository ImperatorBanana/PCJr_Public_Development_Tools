rem This is to assemble %1.ASM for the COM utilities
rem Note: this does not build the example cartridge "MAIN"
rem for that use make.bat main

echo %1.ASM
echo off

cd TOOLS\IBMMASM
echo on
MASM ..\..\ASRC\%1.ASM %1.obj,%1.LST,%1.CRF
if ERRORLEVEL 1 GOTO QUIT
del %1.LST
del %1.CRF
LINK %1.OBJ,%1.EXE,,,
if ERRORLEVEL 1 GOTO QUIT
del %1.OBJ
del %1.MAP
copy %1.EXE ..\.
del %1.EXE
cd ..
EXE2BIN.EXE %1.EXE
if ERRORLEVEL 1 GOTO QUIT
echo off
copy %1.BIN ..\BIN\%1.COM
del %1.BIN
del %1.EXE

:QUIT
cd ..

