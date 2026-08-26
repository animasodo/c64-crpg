; ---------------------------------------------------------------
; load_from_ts
; a wip for now
; ---------------------------------------------------------------

	.autoimport		on
	.importzp		ptr1, ptr2, ptr3, tmp1, tmp2
	.export			load_from_ts
	.include		"c64.inc"
    .include		"cbm_kernal.inc"
    .include		"definitions.inc"
    .include        "manifest.inc"

.segment    "RODATA"

brcmd:
    .byte "u1:2 0", 0

databuf_name:
    .byte "#"                   ; opens the data channel as a direct-access buffer channel

.segment	"CODE"

    next_track = tmp1
    next_sector = tmp2

.proc load_from_ts: near
    sta     next_track
    stx     next_sector

	; open command channel
    lda     #COMMAND
    ldx     #FLOPPY
    ldy     #COMMAND
    jsr     SETLFS
    lda     #0
    jsr     SETNAM
    jsr     OPEN
    
    ; open data channel
    lda     #LFN
    ldx     #FLOPPY
    ldy     #LFN
    jsr     SETLFS
    lda     #1
    ldx     #<databuf_name
    ldy     #>databuf_name
    jsr     SETNAM
    jsr     OPEN

read_loop:
    ldx     #COMMAND
    jsr     CHKOUT              ; we're gonna send some stuff to the disk drive
    ldy     #0
    brcmd_loop:
        lda     brcmd,y
        beq     brcmd_done
        jsr     CHROUT
        iny
        bne     brcmd_loop
    brcmd_done:
    ldy     next_track
    jsr     int_chrout
    ldy     next_sector
    jsr     int_chrout

    jsr     CLRCHN

	ldx     #LFN
	jsr     CHKIN
	; bcs     fail_close

    ; get next track and sector
    jsr     CHRIN
    sta     next_track
    jsr     CHRIN
    sta     next_sector

    ldx     #254 ; X register is not used for CHRIN so it's safe to use
    read_block:
        lda     ptr2
        ora     ptr2+1
        beq     success

        jsr     CHRIN
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
        dex
        bne     read_block

    lda     next_track
    bne     read_loop ; while track is not 0, repeat

success:
    jsr     CLRCHN
    ldx     #COMMAND
    jsr     CHKOUT
    jsr     CLRCHN

    lda     #COMMAND
	jsr     CLOSE
	lda     #LFN
	jsr     CLOSE
	jmp     CLRCHN

.endproc

; small routine to convert an integer to PETSCII characters and pass it to CHROUT
; gee if only i could just PASS INTEGERS TO THE DISK DRIVE

; pass in the integer in Y register

int_chrout:
    lda     #' '
    jsr     CHROUT          ; print a space before the number
    tya
    ldx     #$00
div_loop:
    cmp     #10
    bcc     done           ; if we're over 10, we subtract 10
    sbc     #10
    inx
    jmp     div_loop
done:
    ; now X is tens and A is ones
    cpx     #0
    beq     skip_tens
    tay
    txa
    clc
    adc     #'0'
    jsr     CHROUT
    tya
skip_tens:
    clc
    adc     #'0'
    jmp     CHROUT
