TITLE Invoke Int 18h for cartridge

; Program equates
int_18h							EQU 18h

CODESEG SEGMENT
	assume CS:CODESEG, DS:CODESEG, SS:CODESEG
ORG 100h
PROGRAM: ; Needed for COM to later terminate the program
START_FUNCTION PROC NEAR
	int		int_18h
	ret ; Return to DOS
START_FUNCTION ENDP
CODESEG ENDS
END PROGRAM

