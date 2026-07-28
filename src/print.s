;
; replacement routine for cputs, might be faster
;

	.importzp		tmp1, tmp4, ptr1
	.import			gotoxy
	.export         _printcharxy, _printchar, _printxy, _print, advance_screen_ptr, setchar
	.include        "c64.inc"

.segment "CODE"

	init_pos = tmp4

_printcharxy:
	pha
	jsr		gotoxy
	pla
_printchar:
	jsr		modifychar
	inc		CURS_X
	rts

_printxy:
	pha
	txa
	pha
	jsr		gotoxy
	pla
	tax
	pla
_print:
	sta     ptr1
	stx     ptr1+1
	ldy     #$00			; set pointer

	lda     CURS_X
	sta     init_pos		; store initial position
loop:
	lda     (ptr1),y		; limit is 256 characters but it'll be fine i think, if not i can always add the y register to the pointer
	beq		done			; null
	cmp		#$0D			; new line
	bne		notnl

	ldx		init_pos
	stx		CURS_X
	jsr		advance_screen_ptr

	iny
	jmp     loop
notnl:
	sty	 	tmp1
	jsr     modifychar
	ldy		tmp1
	inc     CURS_X
	iny
	jmp     loop
done:
	rts

advance_screen_ptr:
	clc
	lda     #XSIZE
	adc     SCREEN_PTR
	sta     SCREEN_PTR
	bcc     L4
	inc     SCREEN_PTR+1
	clc
L4:	lda     #XSIZE
	adc     CRAM_PTR
	sta     CRAM_PTR
	bcc     L5
	inc     CRAM_PTR+1
L5:	inc     CURS_Y
	rts

modifychar:
	cmp     #$80
	bcc     :+
	and     #$7F
	jmp     setchar
:	and     #$3F

setchar:
	ldy     CURS_X
	sta     (SCREEN_PTR),y  ; Set char
	lda     CHARCOLOR
	sta     (CRAM_PTR),y    ; Set color
	rts
