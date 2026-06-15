;
; writes string to the screen in an extremely basic way
; void simplewritexy(char x, char y, const char *in);
; void simplewrite(const char *in);
;
; address is loaded into A(low) and X(high) when the function is called
;
	.importzp	tmp1, tmp2, ptr1
	.import		newline, putchar, gotoxy
	.export		_simplewrite, _simplewritexy
	.include        "c64.inc"

.segment "CODE"

_simplewritexy:
        pha
        txa
        pha
        jsr     gotoxy
        pla
        tax
        pla                     ; i don't have phx and plx instructions :(
        
_simplewrite:
        sta     ptr1
        stx     ptr1+1
        ldy     #$00
        sty     tmp2            ; set pointer

        lda     CURS_X
        sta     tmp1            ; store initial position
loop:   
        ldy     tmp2
        lda     (ptr1),y
        beq     done            ; null
        cmp     #$0D            ; new line
        bne     notnl
        jsr     newline
        lda     tmp1
        sta     CURS_X
        inc     tmp2
        jmp     loop
notnl:
        cmp     #$80
        bcc     lower
        and     #$7F
        jmp     :+
lower:  and     #$3F
:       jsr     putchar
        inc     CURS_X
        inc     tmp2
        jmp     loop
done:   rts