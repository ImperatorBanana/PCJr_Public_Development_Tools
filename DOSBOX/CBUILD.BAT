rem This is to compile and build %1.C 

echo Compiling %1.C
echo off

cd C:\CSRC
copy %1.C ..\TOOLS\IBMC

cd ..\TOOLS\IBMC
echo on
CC.EXE %1.C,%1.OBJ,%1.LST,%1.COD
if ERRORLEVEL 1 GOTO QUIT
CLINK.EXE %1.OBJ,%1.EXE,%1.MAP,,
echo off
copy %1.EXE ..\..\BIN
del %1.EXE
del %1.OBJ
del %1.C
del %1.COD
del %1.LST
del %1.MAP

:QUIT
cd ..\..
