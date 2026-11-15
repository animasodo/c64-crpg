
	.autoimport		on
	.export         __STARTUP__ : absolute = 1      ; Mark as startup

	.include        "zeropage.inc"
	.include        "c64.inc"
	.include        "cbm_kernal.inc"
	.include        "definitions.inc"
	.include        "macros.inc"
	.include        "manifest.inc"

; ------------------------------------------------------------------------
; loader
; ------------------------------------------------------------------------

.segment        "STARTUP"

	.byte	<start, >start ; start vector, it'll get triggered when the KERNAL tries to call CHROUT\
	.byte	$ED, $F6 ; KERNAL may still trigger this one

start:
	; turn screen off while we're still doing stuff because garbage is ugly
	lda		#%00001011
	sta		VIC_CTRL1
	lda		#$00
	jsr		SETMSG

	jsr		RESTOR ; restore the vectors

	; switch basic rom off
	lda     $01
	and     #$F8
	ora     #$06            ; Enable Kernal+I/O, disable BASIC
	sta     $01

	; set colors
	lda		#WHITE
	sta		VIC_BG_COLOR1
	sta		CHARCOLOR
	lda		#BROWN
	sta		VIC_BG_COLOR2
	lda		#BLACK
	sta		VIC_BORDERCOLOR
	sta		VIC_BG_COLOR0

	; first things first, upload our routine to the disk drive
	jsr		upload_to_drive

	; load chrset from track and sector
	; destination
	lda     #<VICII_BANK_AREA
    sta     ptr1
	lda     #>VICII_BANK_AREA
    sta     ptr1+1
    ; length
    lda     #<CHRSET_SIZE
    sta     ptr2
    lda     #>CHRSET_SIZE
    sta     ptr2+1

	lda		#CHRSET_TRACK
	ldx		#CHRSET_SECTOR
    jsr     load_from_ts

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

	; print a small "please wait" text in the meantime
	ldy     #$00
wait_loop:
	lda     loading,y
	beq		:+
	sta		SCREEN_AREA+((40*12)+14),y
	iny
	jmp     wait_loop

	; turn screen back on
:	lda		#%00011011
	sta		VIC_CTRL1

	; load manifest table
	; destination
	lda     #<MANIFEST_AREA
    sta     ptr1
	lda     #>MANIFEST_AREA
    sta     ptr1+1
    ; length
    lda     #<MANIFEST_SIZE
    sta     ptr2
    lda     #>MANIFEST_SIZE
    sta     ptr2+1

	lda		#MANIFEST_TRACK
	ldx		#MANIFEST_SECTOR
    jsr     load_from_ts

	; begin to copy load program to temporary spot
	ldy		#00
copy_loop:
	lda		load_prg_code,y
	sta		$0334,y ; cassette tape buffer, 192 bytes
	iny
	cpy		#end_load_prg-load_prg_code
	bne		copy_loop

	; prepare the disk
	ldx     #<(crpg)
	ldy     #>(crpg)
	lda     #4
	jsr     SETNAM
	ldx     FLOPPY
	ldy     #$00
	lda     #LFN
	jsr     SETLFS
	
	lda		#$00
	ldx		#<$033F
	ldy		#>$033F

	jmp		$0334 ; then, jump to the cassette buffer

load_prg_code: ; this code takes 3+3+2+3 = 11 bytes
	jsr		LOAD

	jsr		CLRCHN
	lda		#LFN
	jsr		CLOSE

	; no jump needed because the cpu continues where the program has loaded
end_load_prg:

.segment	"RODATA"

crpg:
    .byte "crpg"
loading:
	.byte "please wait", 0
