; ---------------------------------------------------------------
; read_string
;   read a string from the user and drop in buffer_prompt
;
; in:  A = maximum size of the string, terminator included
; ---------------------------------------------------------------

	.autoimport	on
	.importzp	idx8, byte0, byte1, byte2, byte3, ptr, tmp1
	.export		read_string
	.include	"c64.inc"
	.include	"cbm_kernal.inc"
	.include	"definitions.inc"

.segment	"CODE"

.proc	read_string: near

	char = byte0
	size = byte3

	; idx8 = 0;
	sta		size
	lda     #$00
	sta     idx8

	; set up pointer
	lda     #<(buffer_prompt)
	ldx     #>(buffer_prompt)
	sta		ptr
	stx		ptr+1

	; if (size > 1)
	lda		size
	cmp		#$02
	bcs		:+
	rts
	:

	; cursor(1);
	lda     #$01
	sta		cursor

	; for (buffer_prompt[idx8] = '\0'; idx8 < size; )
	ldy		idx8
	lda		#$00
	sta		(ptr),y
for_loop:
	jsr     _cgetc
	sta     char

	; if(idx8)
	lda		idx8
	beq		skip_index
	lda		char

	; if(byte0 == ENTER)
	cmp     #$0D		; ENTER
	bne		skip_enter

	lda		#$00
	sta		cursor
	rts
skip_enter:

	; if(byte0 == '\b')
	cmp     #$14		; BACKSPACE
	bne		skip_back

	; buffer_prompt[--idx8] = '\0';
	dec		idx8
	ldy		idx8
	lda		#$00
	sta		(ptr),y

	lda		CURS_Y
	sta		byte2
	lda		CURS_X
	sta		byte1

	; byte2 = byte1? byte2: byte2 - 1;
	lda		byte1
	bne		:+
	dec		byte2
	:

	; byte1 = byte1? byte1 - 1: (SCREEN_WIDTH - 1);
	lda		byte1
	bne		:+
	lda		#XSIZE-1
	sta		byte1
	jmp		:++
	:
	dec		byte1
	:

	ldx		byte2
	ldy		byte1
	jsr		goto

	lda		#$20		; BLANK
	jsr		printchar

	ldx		byte2
	ldy		byte1
	jsr		goto

skip_back:
skip_index:

	; if ((char)isprint(byte0) && idx8 < (size - 1))
	lda		char
	jsr		_isprint
	beq		skip_printable

	ldy		size
	dey
	sty		tmp1
	lda		idx8
	cmp		tmp1
	bcs		skip_printable
	; printchar(byte0);
	lda		char
	jsr		printchar
	; buffer_prompt[idx8] = byte0;
	ldy		idx8
	lda		char
	sta		(ptr),y
	; buffer_prompt[++idx8] = '\0';
	inc		idx8
	ldy		idx8
	lda		#$00
	sta		(ptr),y

skip_printable:
	jmp		for_loop
end:
	rts

.endproc

