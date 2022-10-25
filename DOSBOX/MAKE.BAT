echo off
rem Make Program, pass in name of main.asm arg as %1 ("main")
rem DOS 2.1 doesn't seem to support running executables
rem with relative paths so this is going to be fun
rem JRA = ROM Binary with Cartridge Header but Invalid Checksum
rem JRB = ROM Cartridge Binary with valid Checksum - can run on real hardware
rem JRC = Cartridge Binary with JRC Header,can run in DOSBOX(boot ROM\[name].JRC) 

rem If not using JRC you can rem or delete the ADDJRC line
rem if not burning ROM to cartridge

cd TOOLS\IBMMASM
echo on
MASM ..\..\SRC\%1.ASM %1.OBJ,%1.LST,%1.CRF
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
EXE2BIN %1.EXE
if ERRORLEVEL 1 GOTO QUIT
del %1.EXE
copy %1.BIN ..\COM\%1.COM
del %1.BIN
cd ..\BIN
ADDHEADR ..\COM\%1.COM ..\ROM\%1.JRA
CRC ..\ROM\%1.JRA ..\ROM\%1.JRB
del ..\ROM\%1.JRA
ADDJRC ..\ROM\%1.JRB ..\ROM\%1.JRC
rem del ..\ROM\%1.JRB

:QUIT
cd ..