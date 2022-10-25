	PAGE ,132			;
	TITLE TRYCOM1M - SAMPLE COM FILE MACRO ASSEMBLER ROUTINE

;		PROLOG - MODULE DESCRIPTION
;The purpose of this program is to demonstrate how to write an assembler application
;as an executable file of the type COM.

;This module is to be linked with TRYCOM2M to produce an .EXE file, which is then
;passed on to the EXE2BIN utility who reads in the .EXE file and produces a
;.COM file.  The .EXE file should be deleted immediately after EXE2BIN finishes

;sample commands to link and convert to .COM:
;	a:link b:trycom1m+b:trycom2m,b:trycomm,b:trycomm;
;	a:exe2bin b:trycomm b:trycomm.com

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
	SUBTTL EQUATES AND STRUCTURES
	PAGE
;			equates defining functions to be performed
;			by DOS and BIOS routines:
FSCROLL 	EQU	6		;BIOS function = scroll
FLOCATE 	EQU	2		;BIOS function = locate
FREAD_KEYBOARD	EQU	10		;DOS function = read keyboard
FDISPLAY	EQU	9		;DOS function = display msg on console

;			Other equates
MAXCHAR 	EQU	25		;size of user's response buffer
CR		EQU	13		;carriage return
LF		EQU	10		;line feed
EOM		EQU	'$'             ;end of message indicator

COLOR		EQU	7		;attribute, white on black background
ALL		EQU	0		;indicates entire screen on scroll
BLANK		EQU	" "             ;Character blank
SECONDS 	EQU	4		;number of seconds in pause function
TIMES		EQU	60		;Number of times to display response

;			Structure definitions
BUF_KEY        STRUC
BUF_SIZE	DB	?		;limit to max number of chars in response
BUF_RESP_SIZE	DB	?		;no. chars in actual response
BUF_TEXT	DB	MAXCHAR DUP (" ") ;response area to receive response
BUF_END 	DB	EOM		;message terminator
BUF_KEY        ENDS

	SUBTTL DEFINITIONS OF MACROS
	PAGE
DOSCALL MACRO	FUNCTION
;					specify function desired
	MOV	AH,FUNCTION
;					call DOS to perform the desired function
	INT	21H

	ENDM
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

BIOSCALL MACRO	FUNCTION
;					specify function desired
	MOV	AH,FUNCTION
;					call BIOS to perform the desired function
	INT	10H
;;(BIOS routine referenced is the screen display handler)

	ENDM
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

SCROLL	MACRO	POS1,POS2,ATTRIBUTE,ROWS
;;coordinates to be presented in row,col format as a single number, as:
;;row * 256 + col
;;
;;POS1=upper left coordinate
;;POS2=lower right coordinate
;;ATTRIBUTE=color descriptor of fill character
;;ROWS=how many rows to be scrolled (0=do entire screen)
;					upper left corner
	MOV	CX,POS1
;					botton right corner
	MOV	DX,POS2
;					pass how to color fill
	MOV	BH,ATTRIBUTE
;					do entire window
	MOV	AL,ROWS
;					request scroll function from bios
	BIOSCALL FSCROLL
	ENDM
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

LOCATE	MACRO	ROW,COL
;					move cursor to this row
	MOV	DH,ROW
;					 and to this col in this
	MOV	DL,COL
;					  screen number
	MOV	BH,0
;					move cursor
	BIOSCALL FLOCATE
	ENDM
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	PAGE
DISPLAY MACRO	MSG
;					point to message to be displayed
	MOV	DX,OFFSET MSG
;					put message to screen
	DOSCALL FDISPLAY
	ENDM
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

KEYBOARD MACRO	PARMS
;;PARMS=name of area containing buffer descriptor
;;first byte = max size of buffer area provided for response
;;second byte = set by BIOS to length of actual response
;;third byte = start of buffer area to receive response
;					pass descriptor of buffer to receive response
	MOV	DX,OFFSET PARMS
;					read keyboard via DOS
	DOSCALL FREAD_KEYBOARD
	ENDM
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	SUBTTL WORKING STORAGE AND DATA AREAS
	PAGE
CSEG	SEGMENT PARA PUBLIC 'CODE'
	ASSUME CS:CSEG,DS:CSEG,ES:CSEG,SS:CSEG

	EXTRN	CLS:NEAR		;subroutine to clear the screen
	EXTRN	PAUSE:NEAR		;subroutine to delay execution several seconds

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
AREA	BUF_KEY <MAXCHAR>		;generate keyboard response area using STRUC

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
	DISPLAY PROMPT			;Ask operator for his name
	KEYBOARD AREA			;using parm area created by STRUC, Read response
	CALL	CLS			;erase the prompt and his response

	MOV	AH,0			;Clear high byte
	MOV	AL,AREA.BUF_RESP_SIZE	;Get size of his response
	MOV	SI,AX			;put size into index
	MOV	AREA.BUF_TEXT[SI],BLANK ;Replace cr with blank
	MOV	CX,TIMES		;Set number of times to display name
SHOW_NAME:
	  DISPLAY AREA.BUF_TEXT 	;Display the response
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
	DISPLAY DOSPARM_CHARS		;Print the parms
	DISPLAY TRAILER 		;add the cr,lf
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