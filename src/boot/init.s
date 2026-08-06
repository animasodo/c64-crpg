
	.autoimport		on
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
	; switch basic rom off
	lda     $01
	and     #$F8
	ora     #$06            ; Enable Kernal+I/O, disable BASIC
	sta     $01

	; set colors
	lda		#WHITE
	sta		VIC_BG_COLOR1
	lda		#BROWN
	sta		VIC_BG_COLOR2
	lda		#BLACK
	sta		VIC_BORDERCOLOR
	sta		VIC_BG_COLOR0

	jsr     zerobss
	jsr		CLRSCR
	
	; load the character set
	ldx     #24
    ldy     #0
    jsr     goto

    lda     #<(loading)
    ldx     #>(loading)
    jsr     print

	read_seq chrset, 6, $C000, $0800 ; macro for reading the charset

    ; set VIC-II bank to 3
    lda     CIA2
    and     #%11111100
    sta     CIA2

    lda     #%00100000
    sta     VIC_VIDEO_ADR

    lda     #$C8
    sta     $0288

	jsr		CLRSCR

	; set multicolor character mode
	lda		VIC_CTRL2
	ora		#%00010000
	sta		VIC_CTRL2

	jmp     create_player

; ------------------------------------------------------------------------
; data
; ------------------------------------------------------------------------

.segment        "BSS"

zpsave: .res    zpspace

; ------------------------------------------------------------------------
; charset stuff
; ------------------------------------------------------------------------

.segment	"RODATA"

chrset:
    .byte $43, $48, $52, $53, $45, $54

loading:
    .byte "please wait", 0