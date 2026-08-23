
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
	; jsr     zerobss
	jsr		CLRSCR

	; set multicolor character mode
	lda		VIC_CTRL2
	ora		#%00010000
	sta		VIC_CTRL2

	jmp     create_player
