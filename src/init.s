;
; copied from the default crt0.s routine from cc65 and modified
;

        .export         __STARTUP__ : absolute = 1      ; Mark as startup

        .import         donelib
        .import         zerobss, _main
        .import         BSOUT
        .import         __MAIN_START__, __MAIN_SIZE__   ; Linker generated

        .include        "zeropage.inc"
        .include        "c64.inc"


; ------------------------------------------------------------------------
; Startup code

.segment        "STARTUP"

Start:

	; switch basic rom off
	lda     $01
	and     #$F8
	ora     #$06            ; Enable Kernal+I/O, disable BASIC
	sta     $01

	jsr     init

	jsr     zerobss			; gotta initialize variables properly some other way
	; for now, it stays

	; finally, jumps to the main program
	jmp     _main

; ------------------------------------------------------------------------

.segment        "ONCE"

init:

	ldx     #zpspace-1
L1:	lda     c_sp,x
	sta     zpsave,x
	dex
	bpl     L1

; set up the C stack. temporary. omae wa mou shindeiru
	lda     #<(__MAIN_START__ + __MAIN_SIZE__)
	ldx     #>(__MAIN_START__ + __MAIN_SIZE__)
	sta     c_sp
	stx     c_sp+1

	lda     #14
	jmp     BSOUT	; not sure what BSOUT does

; ------------------------------------------------------------------------
; Data

.segment        "INIT"

zpsave: .res    zpspace