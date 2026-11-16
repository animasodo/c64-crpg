
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
	sta		$B000,y ; random address that is far enough and won't get overwritten
	iny
	cpy		#end_load_prg-load_prg_code
	bne		copy_loop

	; prepare the disk
	lda     #<$0334
    sta     ptr1
	lda     #>$0334
    sta     ptr1+1
    ; length
    lda     MANIFEST_AREA+3 ; i know the main program is the first asset in the manifest table
    sta     ptr2
    lda     MANIFEST_AREA+4
    sta     ptr2+1

	lda		MANIFEST_AREA+1
	ldx		MANIFEST_AREA+2
    jsr		open_disk
	jmp		$B000

load_prg_code:

block_loop:
    lda     ptr2
    ora     ptr2+1
    beq     success
get_rest_loop:

    ; wait till the byte is ready
:   bit     CIA2_PRA
	bvc     :- ; wait for CLK=0 (inverted read!)

    ; wait for the raster to be out of the unsafe zone so we can send the data
wait_raster:
	lda     VIC_HLINE
	cmp     #50
	bcc     wait_raster_end
	and 	#$07
	cmp 	#$02
	beq 	wait_raster
wait_raster_end:

	lda     #$00 ; CLK=0 DATA=0
	sta     CIA2_PRA ; we're ready, start sending!
	
    pha     ; 3 cycles
    pla     ; 4 cycles
	bit		$00 ; 3 cycles

	lda     CIA2_PRA ; get 2 bits into bits 6&7
	lsr 
	lsr     ; move down by 2 (bits 4&5)
	eor     CIA2_PRA ; get 2 more bits
	lsr 
	lsr     ; move everything down (bits 2-5)
	eor     CIA2_PRA; get 2 more bits
	lsr 
	lsr     ; move everything down (bits 0-5)
	eor     CIA2_PRA ; get last 2 bits, now 0-7 are populated

	ldy     #$20 ; CLK=0 DATA=1
	sty     CIA2_PRA ; not ready anymore

    ldy     #0
	sta     (ptr1),y

    inc     ptr1
    bne     :+
    inc     ptr1+1
    :
    lda     ptr2
    bne     :+
    dec     ptr2+1
    :
    dec     ptr2
    bne     :+
    :

	sec
	bcs		block_loop ; relative because i can't get the trampoline working right

success:
    lda     #$08 ; send ATN signal so that the drive goes back to normal
    sta     CIA2_PRA
    cli

    lda     #15
    jsr     CLOSE

	jmp		$0334 ; then, jump to the cassette buffer

end_load_prg:

loading:
	.byte "please wait", 0
