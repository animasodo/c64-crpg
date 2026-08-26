
	.autoimport		on
	.importzp		arg0, arg1, ptr1
	.export         __STARTUP__ : absolute = 1      ; Mark as startup

	.include        "zeropage.inc"
	.include        "c64.inc"
	.include        "cbm_kernal.inc"
	.include        "definitions.inc"
	.include        "macros.inc"

; ------------------------------------------------------------------------
; startup code
; ------------------------------------------------------------------------

.segment        "STARTUP"

start:
	jsr		CLRSCR
	
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
	jsr     print

	ldx     #$04
	ldy     #$02
	jsr     goto
	lda     #<(S0015)
	ldx     #>(S0015)
	jsr     print

	lda     #$01
	sta     CHARCOLOR

j0:	jsr     _cgetc
    cmp     #'n'
    beq     correct
    cmp     #'l'
    beq     correct
    jmp     j0

correct:
	jsr     printchar

	lda     #$07
	sta     CHARCOLOR

	ldy     #$02
	ldx     #$06
	jsr     goto
	lda     #<(S0016)
	ldx     #>(S0016)
	jsr     print

	lda     #$01
	sta     CHARCOLOR

	lda     #$09
	jsr     read_string

	lda     #<(buffer_prompt)
	ldx     #>(buffer_prompt)
	sta		ptr1
	stx		ptr1+1
	lda     #<(playerName)
	ldx     #>(playerName)
	jsr     strcpy

	jmp		main

.segment	"RODATA"

S0015:
	.byte	"(N)ew game or (L)oad game? ", 0
S0014:
	.byte	"Welcome to the CRPG demo!", 0
S0016:
	.byte	"Name of the player: ", 0