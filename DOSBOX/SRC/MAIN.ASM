TITLE Template for building COM OR ROM Program with immediate entry
;; Edit
; Edit MAIN.ASM file
;
;
;; BUILD Instructions
; Mount DOSBOX folder as C:\ in DOSBOX 
;				Configure machine=pcjr
; Or copy folder to PCJr 
;              May need to edit batch files for drive letter
;
;  To build COM file: C:\BUILDC.BAT
;    To run COM file: C:\COM\COM.COM
;  To built ROM file: C:\BUILDR.BAT
;    If JRC header needed, C:\TOOLS\ADDJRC.EXE C:\ROM\ROM.JRB C:\ROM\ROM.JRC
;      To Run in DOSBOX, DOSBOX command: "boot C:\ROM\ROM.JRC"
;    If real cartridge, burn C:\ROM\ROM.JRB to 8K ROM and run as normal (no JRC)
;    If running PCJr Save Cart V1 (using ram-only)
;      C:\TOOLS\SAVECART.EXE ROM.JRB - Write to cartridge
;      C:\TOOLS\CARTINIT.COM - Execute cart init command to load int18h vector
;      C:\TOOLS\CARTBOOT.COM - Invoke int18h to boot cart
;         From within cart, ctrl+alt+delete to return to DOS
;      Note: *Technically* if you SAVECART and then power cycle the command it will work
;      However, if you run any other DOS command, DOS corrupts the AA55 bytes when it
;        checks to see if the command you requested lives in the cartridge space,
;        hence the CARTINIT/CARTBOOT workaround. This was an unanticipated behavior
;        PCJr Save Cart V2 will be designed to avoid this)


interrupt_vector_ram_segment	EQU 0000h
	int18						EQU 18h
		int18_offset			EQU int18 * 4
		int18_segment			EQU int18_offset + 2
stack_ram_segment				EQU 0030h
bios_ram_data_segment			EQU 0040h
dos_ram_data_segment			EQU	0050h
game_ram_data_segment			EQU 0060h ; - to 07FFh segment

video_ram_page2_segment			EQU 0800h ;(Alias to 6)
video_ram_page1_segment			EQU 0C00h ;(Alias to 7)

video_ram_write_segment			EQU	0B800h
option_rom_segment				EQU 0C000h - 1
bios_rom_segment				EQU 0F000h

CODESEG SEGMENT
	assume CS:CODESEG, DS:CODESEG, SS:CODESEG
ORG 000h
CODEBEGIN = $

db "THIS WILL BE DELETED$"
HEADER: ; PC Jr Cartridge Header
	cartridgeid			dw		0AA55h
	cartridgelength		db		0/512	;; TODO 		
	db ?,?,? ;jmp					ROM_CHECK_ENTRY			;; ENTRY POINT
	headerend			db		00h
db "0123456789ABCDE$" ; Will be cartridge name
db "COMPANY / GROUP$"
db "PRIMARY AUTHOR $"
db "THIS WAS DELETED$"

ORG 100h
PROGRAM: ; Needed for COM to later terminate the program
jmp ROM_CHECK_ENTRY 
db "ROMC$" 
jmp INT18_ENTRY 
db "IN18$"
	
ROM_CHECK_ENTRY PROC FAR ;; ROM_CHECK_ENTRY from cart must be far but from com must be near
	mov		al,'S' ; S for success!
	mov		ah,0Eh ; BIOS Print TTY Character
	int		10h ; BIOS Video Interrupt
		;; Conditional Return
	mov		ax,cs
	cmp		ax,option_rom_segment
	ja		ROM_CHECK_CART_EXIT
ROM_CHECK_DOS_EXIT:
	mov		ax,(04Ch SHL 8) OR 00 ; DOS Exit 0
	int		21h
ROM_CHECK_CART_EXIT:
	jmp short ROM_CHECK_CART_EXIT ; CART Return
ROM_CHECK_ENTRY ENDP

INT18_ENTRY PROC FAR
	iret ;; Not Setup or Used
INT18_ENTRY ENDP

;; Ensure there are 2 free bytes for CRC on a 512 boundary
IF (($-CODEBEGIN+2) MOD 512) ;If the current length + the footer is not on a 512 boundary
	ORG ($-CODEBEGIN) + (512) - (($-CODEBEGIN) MOD 512) - 2 ; Increase the current location to the next 512 boundary - the footer
ENDIF
db 0FFh,0FFh

CODESEG ENDS
END PROGRAM
