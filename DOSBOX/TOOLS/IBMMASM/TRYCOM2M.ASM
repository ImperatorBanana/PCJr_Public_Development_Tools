	PAGE ,132			;
	TITLE TRYCOM2M - SAMPLE COM FILE MACRO ASSEMBLER SUBROUTINE

;This module is to be linked with the OBJ from TRYCOM1S module.
;It contains two subroutines:
;	CLS - Clear the screen, put cursor at top left corner
;	PAUSE - Delay execution for several seconds
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;			equates defining functions to be performed
;			by DOS and BIOS routines:
FSCROLL 	EQU	6		;BIOS function = scroll
FLOCATE 	EQU	2		;BIOS function = locate

;			Other equates
COLOR		EQU	7		;attribute, white on black background
ALL		EQU	0		;indicates entire screen on scroll
SECONDS 	EQU	4		;number of seconds in pause function

	SUBTTL DEFINITIONS OF MACROS
	PAGE
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

CSEG	SEGMENT BYTE PUBLIC 'CODE'
	ASSUME CS:CSEG,DS:CSEG,ES:CSEG,SS:CSEG

;Because this module is to be linked with another module, together to be executed as a
;.COM file, all code generated must be for the one common segment.  This segment name
;must be the same as the segment name used in the main module, and the same class name.
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	SUBTTL	CLEAR SCREEN SUBROUTINE
	PAGE
	PUBLIC	CLS			;Identify subroutine to LINK
CLS	PROC	NEAR			;Clear the screen, cursor to top left
;					from top left corner at (0,0) to bottom right at
	SCROLL	0,24*256+79,COLOR,ALL	;ROW=24, COL=79 (ZERO relative)
	LOCATE	0,0			;Cursor to top left at (0,0)
	RET				;return to main routine
CLS	ENDP
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	SUBTTL PAUSE FOR FEW SECONDS SUBROUTINE
	PAGE
	PUBLIC	PAUSE			;Identify subroutine to LINK
PAUSE	PROC	NEAR			;Delay process for some seconds
	MOV	CX,SECONDS * 4		;Outer loop counter
;	do until outer counter is decremented to zero
OUTER:
	  PUSH	  CX			;Save outer loop counter
	  MOV	  CX,0FFFFH		;Set inner loop counter
;	  do until inner counter is decremented to zero
INNER:
	  LOOP	  INNER 		;Waste about 1/4 second
	  POP	  CX			;Restore outer loop counter
	LOOP	OUTER			;Go again
	RET				;Return to main routine
PAUSE	ENDP
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
CSEG	ENDS
;Because this module is Not the main module, that is, it does Not contains the entry point
;from DOS, this END statement must Not identify the entry point label.
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	END
