	PAGE ,132			;
	TITLE TRYCOM1S- SAMPLE COM FILE SMALL ASSEMBLER ROUTINE

;		PROLOG - MODULE DESCRIPTION
;The purpose of this program is to demonstrate how to write an assembler application
;as an executable file of the type COM.

;This module is to be linked with the TRYCOM2S module to produce an .EXE file, which is
;then passed on to the EXE2BIN utility who reads in the .EXE file and produces a
;.COM file.  The .EXE file should be deleted immediately after EXE2BIN finishes

;sample commands to link and convert to .COM:
;	a:link b:trycom1s+trycom2s,b:trycoms,b:trycoms;
;	a:exe2bin b:trycoms b:trycoms.com

;		FUNCTIONS PERFORMED
;clear the screen
;put the cursor into the top left position
;display any parms that may have been entered on the DOS command line
;clear the screen again
;put the cursor into the top left position
;display a message prompt that asks for the operator's name
;wait for the user to respond to the prompt
;read the response
;clear the screen again
;display the response (user's name) several times on the screen
;return to DOS.
	SUBTTL EQUATES
	PAGE
;			equates defining functions to be performed
;			by DOS and BIOS routines:
FREAD_KEYBOARD	EQU	10		;DOS function = read keyboard
FDISPLAY	EQU	9		;DOS function = display msg on console

;			Other equates
MAXCHAR 	EQU	25		;size of user's response buffer
CR		EQU	13		;carriage return
LF		EQU	10		;line feed
EOM		EQU	'$'             ;end of message indicator

BLANK		EQU	" "             ;Character blank
TIMES		EQU	60		;Number of times to display response

	SUBTTL WORKING STORAGE AND DATA AREAS
	PAGE
CSEG	SEGMENT PARA PUBLIC 'CODE'
	ASSUME CS:CSEG,DS:CSEG,ES:CSEG,SS:CSEG

	EXTRN	CLS:NEAR		;SUBROUTINE TO CLEAR THE SCREEN
	EXTRN	PAUSE:NEAR		;SUBROUTINE TO DELAY FOR FEW SECONDS

; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;According to the rules for COM file interface with DOS,
;at entry, all four segment registers all point to this one common segment.
;The program segment prefix (PSP) is considered to be the first 256 bytes
;of this one segment.  The PSP is built by the loader of DOS just prior to
;execution.  Its areas are addressable just like any other part of this segment.

;The stack segment in a COM file is not separate, but is a part of the one
;segment.  The loader will set SP (stack pointer) to the high end of this 64K
;segment, or to the top of available RAM memory, if that should come first.
;A zero word is already on the stack, pushed there by the loader.

;Because there is no separate segment whose type is 'STACK', the LINK will
;display a warning message indicating that there was no stack segment.	When
;Linking a COM style application, this message is expected and normal and may
;quite safely be ignored.
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	ORG	80H			;look at a field within the PSP
DOSPARM_LEN	DB	?		;one byte length of parms on DOS command
DOSPARM_CHARS	DB	127 DUP (?)	;text of parms on DOS command line

	ORG	100H			;start at the end of the PSP
;In a COM file, the entry point must be at 100h in the one segment.
;The END statement must identify this near label as being the entry point from DOS.
ENTPT:	JMP	SHORT	START		;skip over the data areas

; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;			Keyboard param list definition
AREA		LABEL	BYTE		;Name of the entire parm list
BUF_SIZE	DB	MAXCHAR 	;limit to max number of chars in response
BUF_RESP_SIZE	DB	?		;no. chars in actual response
BUF_TEXT	DB	MAXCHAR DUP(" ") ;response area to receive response
BUF_END 	DB	EOM		;message terminator
;			End of keyboard param list definition
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

PROMPT	DB	'What is your name?'
TRAILER DB	CR,LF,EOM
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	SUBTTL	EXECUTABLE APPLICATION CODE
	PAGE
START	PROC	NEAR			;start of the code area
;For COM files, code must be in NEAR procedures.  Because this is a COM file, no further
;initialization required; the seg regs are already set, the stack pointer is already set,
;and a return offset of zero is already on the stack.  We can start here and now with the
;code of the application.
	CALL	CLS			;Clear the screen, cursor to top left

	MOV	AL,DOSPARM_LEN		;Get the number of chars of parms
	MOV	AH,0			;Clear high byte
	CMP	AH,AL			;If any parms were entered on the DOS command line
	JE	NO_PARMS		;count of zero says no parms entered
;					Non-zero count says parms were entered
	  CALL	PARM_HANDLER		;get the parms from DOS command line
NO_PARMS:
;					Ask operator for his name
	MOV	DX,OFFSET PROMPT
	MOV	AH,FDISPLAY
	INT	21H

;					using parm area, Read response
	MOV	DX,OFFSET AREA
;					read keyboard via DOS
	MOV	AH,FREAD_KEYBOARD
	INT	21H

	CALL	CLS			;erase the prompt and his response

	MOV	AH,0			;Clear high byte
	MOV	AL,BUF_RESP_SIZE	;Get size of his response
	MOV	SI,AX			;put size into index
	MOV	BUF_TEXT[SI],BLANK	;Replace cr with blank
	MOV	CX,TIMES		;Set number of times to display name
SHOW_NAME:
;					Display the response
	  MOV	DX,OFFSET BUF_TEXT
	  MOV	AH,FDISPLAY
	  INT	21H

	LOOP	SHOW_NAME		;Go show the name again
;For the RET to execute properly, the stack must have been restored to the point
;where only the return offset is left on the stack, as was the condition of the
;stack when the application got control from DOS.  Any values pushed onto the stack
;must have been popped off by the application before performing this return.
	RET				;return to offset zero in PSP
;					 where is found the INT 20H that
;					 will return to DOS.
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;Because the PSP is a part of this segment, the application could have issued the INT 20H
;directly, (or the INT 27H directly, if it wished to remain resident).
START	ENDP
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	SUBTTL	PARAMETER HANDLER SUBROUTINE
	PAGE
PARM_HANDLER	PROC	NEAR
	MOV   SI,AX
	MOV   DOSPARM_CHARS[SI],EOM	;Replace CR on parms with msg terminator
;					Print the parms
	MOV   DX,OFFSET DOSPARM_CHARS
	MOV   AH,FDISPLAY
	INT   21H

;					add the cr,lf
	MOV   DX,OFFSET TRAILER
	MOV   AH,FDISPLAY
	INT   21H

	CALL  PAUSE			;wait for several seconds

	CALL  CLS			;Clear the screen again

	RET				;return to main routine
PARM_HANDLER	ENDP
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
CSEG	ENDS
;Because this module is the main module, that is, it contains the entry point
;from DOS, this END statement must identify the entry point label.  No other
;module linked with this one can have a label on their END statements.	Because
;this is a COM file, the entry label identified here must be at 100H.
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	END	ENTPT
