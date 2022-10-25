	page	,132
	title	ibmasm - link with UTEST.PAS + IBMUTIL.LIB
mathcode segment byte public 'CODE'
	assume	CS:mathcode

	public	i4tom4, m4toi4, i8tom8, m8toi8
	public	i4toi8, i8toi4
	public	finput,foutput
	extrn	$i4_m4:near, $i8_m8:near, $m4_i4:near, $m8_i8:near
	extrn	$i4_i8:near, $i8_i4:near
	extrn	$i8_input:near, $i8_output:near

global	proc	far
i4tom4:
	mov	dx,offset $m4_i4
	jmp	short conv

i8tom8:
	mov	dx,offset $m8_i8
	jmp	short conv

m4toi4:
	mov	dx,offset $i4_m4
	jmp	short conv

m8toi8:
	mov	dx,offset $i8_m8
	jmp	short conv

i4toi8:
	mov	dx,offset $i8_i4
	jmp	short conv

i8toi4:
	mov	dx,offset $i4_i8

conv:
	MOV	CX,DS		;save DS
	POP	AX		;return offset
	POP	BX		;return segment
	POP	DI		;destin offset
	POP	ES		;destin segment
	POP	SI		;source offset
	POP	DS		;source segment
	PUSH	BX		;return segment
	PUSH	AX		;return offset
	PUSH	CX		;save DS
	CALL	dx		; call routine
	POP	DS		;restore DS
	RET			;finished

;------------------------------------------------------------------------------;
; Pascal interface to double precision decode.
; PROCEDURE finput( Loc: adrmem; Len: word; radix: word; Var r: finrec );
;
; finrec =
;  Record
;    realv: real8;
;    intgv: integer4;
;    cflag: word;
;  End;

finput:
	push	bp				; 1 word push.
	mov	bp,sp				; New frame.
	mov	di,[bp+06]			;  6(bp)   r	 - ddecrec.
	mov	bx,[bp+08]			;  8(bp)   radix - 0 .. z.
	mov	cx,[bp+10]			; 10(bp)   len	 -  number  of	bytes  in  input
						;	   numeral.
	mov	si,[bp+12]			; 12(bp)   loc -  ds  offset  of  numeral input.
	xor	ax,ax
	push	ds
	pop	es
	call	$I8_INPUT			; ascii -> ieee conversion
	mov	[di+8 ],AX			; Low  16 bits 32 bit integer.
	mov	[di+10],bx			; High 16 bits 32 bit integer.
	xor	ch,ch				; Clear flags in high byte.
	mov	[di+12],cx			; Flags
	pop	bp				; Restore previous frame.
	ret	8				; Clean up stack.

foutput:
	push	bp				; 1 word save.
	mov	bp,sp				; New frame.
	push	[bp+6]				; Offset of DencRec
	mov	si,[bp+8]			; Offset of real.
	push	ds
	pop	es				; set DS=ES
	call	$I8_OUTPUT			; floating output
	pop	di
	mov	[di],si 			; Return buffer.
	mov	[di+2],dx			; Store exponent.
	mov	[di+4],bl			; Store sign.
	pop	bp				; Restore previous frame.
	ret	4				; Clean up stack.
global	endp
mathcode ends
	END
