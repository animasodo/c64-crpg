; ---------------------------------------------------------------
; print
;   writes simple unformatted string to the screen
;
; in:  A, X = pointer to the string
; ---------------------------------------------------------------

; cut down version of the normal print function because i just need to show a small text while the game loads

	.autoimport		on
	.importzp		tmp1, ptr1
	.export         print
	.include        "c64.inc"

.segment "CODE"

print:
	sta     ptr1
	stx     ptr1+1
	ldy     #$00			; set pointer

loop:
	lda     (ptr1),y		; limit is 256 characters but it'll be fine i think, if not i can always add the y register to the pointer
	beq		done			; null
	sty	 	tmp1
	
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

	ldy		tmp1
	inc     CURS_X
	iny
	jmp     loop
done:
	rts

