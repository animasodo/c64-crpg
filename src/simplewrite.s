;
; writes string to the screen in an extremely basic way
; void simplewrite(const char *in);
;
; address is loaded into A(low) and X(high) when the function is called
;
	.importzp	tmp1, tmp2, tmp3, tmp4, ptr1
	.import		newline, putchar
	.export		_simplewrite
	.include    "c64.inc"

.segment "CODE"

_simplewrite:
        sta     ptr1
        stx     ptr1+1
        ldy     #$00
        sty     tmp2        ; set pointer

        lda     CURS_X
        sta     tmp1        ; store initial position
loop:   
        ldy     tmp2
        lda     (ptr1),y
        cmp     #$00        ; stop
        beq     done
        cmp     #$0D        ; nl
        bne     notnl
        jsr     newline
        lda     tmp1
        sta     CURS_X
        inc     tmp2
        jmp     loop
notnl:
        jsr     putchar
        inc     CURS_X
        inc     tmp2
        jmp     loop
done:   rts