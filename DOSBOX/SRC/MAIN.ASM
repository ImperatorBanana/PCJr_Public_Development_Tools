;; Sumary: This is a starting shell for writing a PCJr IPL Cartridge
;  Note: Since we don't define the stack MASM will throw a warning
;  Build steps:
;		1.) MASM to assemble to an exe
;		2.) EXE2BIN.EXE to convert to COM/Binary
;		3.) Externally calculate the CRC bytes
;		4.) Write to PCJr ROM chip

;; BIOS System Start Call, used to hand final control to cartridge
int18_offset					EQU	018h * 004h 
int18_segment					EQU	int18_offset + 002h
int21_offset					EQU	021h * 004h ;; Would be DOS INT 21 service
int21_segment					EQU	int21_offset + 002h

;; BIOS Service Interrupt CONSTANTS
int_video						EQU	10h
	svc_video_mode					EQU	00h
	svc_video_set_cursor_pos		EQU	02h	
	svc_video_write_char_tty		EQU	0Eh
	svc_video_get_current_mode		EQU	0Fh
int_dos_21						EQU 21h
	svc_dos_print_str				EQU 09h

;; CART Equates
cart_rom_len					EQU	2000h

;; Memory map
;0000:00 - 0030:00 - Interrupt Vector table
interrupt_vector_table_segment	EQU	0000h
;0030:00 - 0040:00 - Stack
	val_top_of_stack					EQU 0100h
;0040:00 - 0050:00 - BIOS Data
;0050:00 - 0800:00 - System RAM
system_ram_segment				EQU	0050h
;0800:00 - 0C00:00 - Video Page 2 (Alias to 6)
;0C00:00 - 1000:00 - Video Page 3 (Alias to 7)
;------------------------------
;B800:00 - BC00:00 - Video RAM (Alias to one of the two video pages)
video_ram_segment				EQU	0B800h
;D000:00 - D800:00 - CART ROM
;E000:00 - E800:00 - CART RAM (Read)
;E800:00 - F000:00 - CART RAM (Write)
;F000:00 - 		   - BIOS
bios_rom_segment				EQU	0F000h

;; Program Equates

CARTSEG segment
assume CS:CARTSEG, DS:CARTSEG 

ORG	0000h

HEADER: ; PC Jr Cartridge Header
	cartridgeid			dw		0AA55h
	cartridgelength		db		cart_rom_len/512	;; TODO - can the assembler calculate this 		
	jmp					INIT					;; ENTRY POINT
	headerend			db		00h
;; INIT Function
INIT PROC FAR
	; The BIOS pushes DX (the current ROM block being checked for signatures) to the stack
	; and then does a call (far) (which pushes the segment and offset before jumping)
	; Assumes your init didn't push additional data to the stack
	mov		bp,sp ; Set the base pointer
	mov		ax,bios_rom_segment ;
	mov		[bp+4],ax ; Set the "current ROM block" to be after the end of the cartridge
	
	; Set up the interrupt vector to boot into the cartridge
	mov		ax,interrupt_vector_table_segment
	mov		es,ax ; Set ES to 0000h (the interrupt vector segment)
	mov		ax,cs
	mov		es:int18_segment,ax ; Move the current Code Segment to the Interrupt Vector 2nd 2 bytes
	mov		ax,offset MAIN
	mov		es:int18_offset,ax ; Move the Main Offset to the Interrupt Vector 1st 2 bytes
	ret
INIT ENDP

;; Utilities
UTIL_PRINT_NEWLINE MACRO ;; Print \r\n
	mov		ax,(svc_video_write_char_tty SHL 8) OR 0Dh ; \r
	int		int_video
	mov		ax,(svc_video_write_char_tty SHL 8) OR 0Ah ; \n
	int		int_video
ENDM

LOAD_DOS_INT21H MACRO
	mov		ax,interrupt_vector_table_segment
	mov		es,ax ; Set ES to 0000h (the interrupt vector segment)
	mov		ax,cs
	mov		es:int21_segment,ax ; Move the current Code Segment to the Interrupt Vector 2nd 2 bytes
	mov		ax,offset DOS_INT_21
	mov		es:int21_offset,ax ; Move the DOS_INT_21 Offset to the Interrupt Vector 1st 2 bytes
ENDM

DOS_INT_21 PROC FAR ; Need to load this vector
	sti ; re-enable interrupts
	cmp		ah,09h ; Check if service 9
	jne		short DOS_INT_21_END ; If not, exit
DOS_INT21_SVC_9:
	push	ax
	push	bx ; Save user regs
	
	mov		ah,svc_video_get_current_mode
	int		int_video ; Set's BH
	
	xchg	si,dx ; Can't use DX to index, swap with SI
DOS_INT21_LOOP:
	mov		al,[si] ; Read next character
	cmp		al,'$' ; Compare to terminator
	je		short DOS_INT_21_CLEANUP ; Leave if terminator

	mov		ah,svc_video_write_char_tty ; Else Print the character
	int		int_video
	
	inc		si ; increment to the next one
	jmp		short DOS_INT21_LOOP ; loop again
DOS_INT_21_CLEANUP:
	xchg	si,dx ; Swap SI back
	
	pop		bx ; Restore user regs
	pop		ax
DOS_INT_21_END:
	iret
DOS_INT_21 ENDP

;; MAIN Function
MAIN:
	mov		ax,val_top_of_stack ; Top of the stack
	mov		sp,ax ;; Reset the stack pointer
	sti		;; Re-enable interrupts to stop disk drive from spinning indefinitely
	
	LOAD_DOS_INT21H ; Load DOS INT21H
	
	mov		ax,cs
	mov		ds,ax ;; Set DS == CS
	mov		ax,system_ram_segment
	mov		es,ax ;; Set ES == System Ram Segment

	mov		dx,offset HELLO_WORLD
	mov		ah,svc_dos_print_str
	int		int_dos_21
	UTIL_PRINT_NEWLINE
GAMELOOP:	; Fall into Gameloop
	jmp		GAMELOOP

DATA:
HELLO_WORLD db 'Hola Mundo!$'

ORG	cart_rom_len - 16; 15(name) + 2(chksum) ;; TODO - can the assembler calculate this
FOOTER: ; PCJr Cartridge Footer
	;;								"123456789ABCDE"
	cart_name					db	"Start Project$" ; 
	cart_chksum					dw	0000h ;; TODO - can the assembler calculate this?

CARTSEG ENDS
END ; End program
