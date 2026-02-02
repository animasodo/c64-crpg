;
; Ullrich von Bassewitz, 08.08.1998
;
; void cvblock(char x, char y, char len);
; void chblock(char x, char y, char len);
;
; modified from cvline.s and chline.s
;

        .export         _cvblock, _chblock
        .import         gotoxy, putchar, newline
        .importzp       tmp1
        .include        "c64.inc"

_cvblock:
        pha                     ; save length
        jsr     gotoxy          ; call and pop x and y
        pla                     ; restore length
        sta     tmp1
loopv:  lda     #$7A            ; block character
        jsr     putchar         ; write
        jsr     newline         ; nl
        dec     tmp1
        bne     loopv
        rts

_chblock:
        pha                     ; save length
        jsr     gotoxy          ; call and pop x and y
        pla                     ; restore length
        sta     tmp1
looph:  lda     #$7A            ; block character
        jsr     putchar         ; write
        inc     CURS_X          ; advance
        dec     tmp1
        bne     looph
        rts