;
; this was originally a function compiled by cc65, but it's been further optimized by hand
; it takes about three to four frames to update the map
;
; void drawMap(void){
;     char x, y;
;     char xViewport = 1, yViewport = 1;
;     char oldColor = textcolor(WHITE);
;     char xCursor = wherex(), yCursor = wherey();
;     for(y = 0; y < 9; y++){
;         unsigned int i = ((y + cameray) << 5) + camerax;
;         for(x = 0; x < 11; x++){
;			  gotoxy(xViewport, yViewport);
;             drawtile(mapBuffer[i++]);
;             xViewport += 2;
;         }
;         xViewport = 1;
;         yViewport += 2;
;     }
;     textcolor(oldColor);
;     gotoxy(xCursor, yCursor);
; }
;

	.importzp	c_sp
	.importzp	tmp1, tmp2, tmp3, tmp4, ptr1, ptr2
	.macpack	longbranch
	.import		_camerax, _cameray, _mapBuffer, _gotoy, aslax4, newline, putchar
	.export		_drawmap
	.include    "c64.inc"

.segment "RODATA"

; graphics data
topleft_chr:
        .byte $E0, $E8, $E5, $E4, $E7, $E9, $E8, $E2, $E2, $E1
topright_chr:
        .byte $E0, $E8, $E5, $E4, $E7, $E9, $E8, $E3, $E3, $E1
botleft_chr:
        .byte $E0, $E8, $E6, $E4, $E7, $EA, $E8, $E2, $E3, $E1
botright_chr:
        .byte $E0, $E8, $E6, $E4, $E7, $EB, $E8, $E3, $E2, $E1
color:
        .byte $0D, $07, $0D, $0C, $08, $03, $07, $0E, $0E, $02

.segment	"CODE"

.proc	_drawmap: near

.segment	"CODE"

	; for context, tmp2 is xViewport, tmp3 is x and tmp4 is y. ptr2 is i
	; they've been moved to zeropage

	lda     #$01
	sta     tmp2
	sta     _yViewport
	ldx		CHARCOLOR
	stx     _oldColor
	lda     CURS_X
	sta     _xCursor
	lda     CURS_Y
	sta     _yCursor
	lda     #$00
	sta     tmp4				; init stuff
yloop:
	lda     tmp4
	cmp     #$09
	jcs     L0010

	ldx     #$00				; beginning of index calculation
	lda     tmp4
	clc
	adc     _cameray
	bcc     L000B
	inx
L000B:
	jsr     aslax4
	stx     tmp1
	asl     a
	rol     tmp1
	ldx     tmp1
	clc
	adc     _camerax
	bcc     L000C
	inx
L000C:
	sta     ptr2
	stx     ptr2+1
	lda     #$00
	sta     tmp3
	sei							; avoid interruptions that do weird stuff
L000E:
	lda     tmp3				; for(x = 0; x < 11; x++)
	cmp     #$0B
	bcs     L000F

	lda     tmp2
	sta     CURS_X
	lda     _yViewport
	jsr		_gotoy				; set the cursor position

	lda     ptr2
	sta     ptr1
	lda     ptr2+1
	clc
	adc     #>(_mapBuffer)
	sta     ptr1+1
	ldy     #<(_mapBuffer)
	lda     (ptr1),y			; get the tile
	inc     ptr2
	bne     L000A
	inc     ptr2+1
L000A:
	; handmade tile drawing function (drawtile)
	tax                    		; move tile to x register
    lda     color,x        		; load color
    sta     CHARCOLOR      		; change color
    lda     topleft_chr,x  		; load top left
    jsr     putchar        		; output character
    inc     CURS_X         		; move cursor to right
    lda     topright_chr,x 		; load top right
    jsr     putchar        		; output character
    jsr     newline        		; move to next line
    lda     botright_chr,x 		; load bottom right
    jsr     putchar        		; output character
    dec     CURS_X         		; move cursor to left
    lda     botleft_chr,x  		; load bottom left
    jsr     putchar        		; output character

	lda     #$02
	clc
	adc     tmp2
	sta     tmp2
	inc     tmp3
	jmp     L000E
L000F:
	lda     #$01
	sta     tmp2
	lda     #$02
	clc
	adc     _yViewport
	sta     _yViewport
	inc     tmp4
	jmp     yloop
L0010:
	cli							; restore interrupt
	lda     _oldColor			; set color and cursor to old values
	sta		CHARCOLOR
	lda     _xCursor
	sta     CURS_X
	lda     _yCursor
	jmp		_gotoy

.segment	"BSS"

_yViewport:
	.res	1,$00
_oldColor:
	.res	1,$00
_xCursor:
	.res	1,$00
_yCursor:
	.res	1,$00

.endproc

