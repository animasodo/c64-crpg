;
; Ullrich von Bassewitz, 08.08.1998
;
; void _writev(char x, char y, char c, char len);
; void _writeh(char x, char y, char c, char len);
;
; modified from cvline.s and chline.s
;

        .export         _writev, _writeh
        .import         gotoxy, putchar, newline
        .import         popa
        .importzp       tmp1, tmp2
        .include        "c64.inc"

_writev:
        pha
        jsr     popa
        sta     tmp2
        jsr     gotoxy
        pla
        sta     tmp1
loopv:  lda     tmp2
        jsr     putchar         ; write
        jsr     newline         ; nl
        dec     tmp1
        bne     loopv
        rts

_writeh:
        pha
        jsr     popa
        sta     tmp2
        jsr     gotoxy
        pla
        sta     tmp1
looph:  lda     tmp2
        jsr     putchar         ; write
        inc     CURS_X          ; advance
        dec     tmp1
        bne     looph
        rts