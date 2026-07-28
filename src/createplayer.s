	
    .importzp		arg0, arg1, ptr1
	.import			draw_box_border, goto, _print, _printchar, _readString, pushax, strcpy, _bufferPrompt, _playerName, _cgetc
	.export         _createPlayer
	.include        "c64.inc"

.segment	"RODATA"

S0015:
	.byte	"(N)ew game or (L)oad game? ", 0
S0014:
	.byte	"Welcome to the CRPG demo!", 0
S0016:
	.byte	"Name of the player: ", 0

; ---------------------------------------------------------------
; void __near__ createPlayer (void)
; ---------------------------------------------------------------

.segment	"CODE"

.proc	_createPlayer: near

.segment	"CODE"

	ldx     #$00
	ldy     #$00
	lda     #$28
	sta     arg0
	lda     #$19
    sta     arg1
	jsr     draw_box_border

	lda     #$07
	sta     CHARCOLOR

	ldx     #$02
	ldy     #$02
	jsr     goto
	lda     #<(S0014)
	ldx     #>(S0014)
	jsr     _print

	ldx     #$04
	ldy     #$02
	jsr     goto
	lda     #<(S0015)
	ldx     #>(S0015)
	jsr     _print

	lda     #$01
	sta     CHARCOLOR

j0:	jsr     _cgetc
    cmp     #'n'
    beq     correct
    cmp     #'l'
    beq     correct
    jmp     j0

correct:
	jsr     _printchar

	lda     #$07
	sta     CHARCOLOR

	ldy     #$02
	ldx     #$06
	jsr     goto
	lda     #<(S0016)
	ldx     #>(S0016)
	jsr     _print

	lda     #$01
	sta     CHARCOLOR

	lda     #$09
	jsr     _readString

	lda     #<(_bufferPrompt)
	ldx     #>(_bufferPrompt)
	sta		ptr1
	stx		ptr1+1
	lda     #<(_playerName)
	ldx     #>(_playerName)
	jsr     strcpy

	rts

.endproc