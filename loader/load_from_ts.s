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

.segment    "RODATA"

brcmd:
    .byte "u1:2 0 ", 0

databuf_name:
    .byte "#"                   ; opens the data channel as a direct-access buffer channel

.segment	"CODE"

    next_track = tmp1
    next_sector = tmp2

.proc load_from_ts: near

    lda     #8
    sta     next_track
    lda     #0
    sta     next_sector

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
    lda     next_track          ; track
    jsr     int_chrout
    lda     next_sector         ; sector
    jsr     int_chrout

    jsr     CLRCHN

	ldx     #LFN
	jsr     CHKIN
	bcs     fail_close

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

fail_close:
	php
    lda     #COMMAND
	jsr     CLOSE
	lda     #LFN
	jsr     CLOSE
	jsr     CLRCHN
	plp
fail:
	rts

.endproc

; small routine to convert an integer to PETSCII characters and pass it to CHROUT
; gee if only i could just PASS INTEGERS TO THE DISK DRIVE

int_chrout:
    ldx     #$00
div_loop:
    cmp     #10
    bcc     done           ; if we're over 10, we subtract 10
    sbc     #10
    inx
    jmp     div_loop
done:
    ; now X is tens and A is ones
    tay
    cpx     #0
    beq     skip_tens
    txa
    clc
    adc     #'0'
    jsr     CHROUT
    tya
    jmp     add_ones
skip_tens:
    lda     #' '
    jsr     CHROUT
add_ones:
    tya
    clc
    adc     #'0'
    jmp     CHROUT
