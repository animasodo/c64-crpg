; ---------------------------------------------------------------
; load_from_ts
; a wip for now
; ---------------------------------------------------------------

	.autoimport		on
	.importzp		ptr1, ptr2, ptr3
	.export			load_from_ts
	.include		"c64.inc"
    .include		"cbm_kernal.inc"
    .include		"definitions.inc"

.segment    "RODATA"

brcmd:
    .byte "u1:2 0 ", 0

databuf_name:
    .byte "#"               ; opens the data channel as a direct-access buffer channel

.segment	"CODE"

.proc load_from_ts: near

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

    lda     #17                 ; track
    jsr     convert_string
    jsr     CHROUT
    tya
    jsr     CHROUT
    lda     #' '
    jsr     CHROUT
    lda     #0                  ; sector
    jsr     convert_string
    jsr     CHROUT
    tya
    jsr     CHROUT

    jsr     CLRCHN              ; close command channel

	ldx     #LFN
	jsr     CHKIN
	bcs     fail_close

    ; get next track and sector
    jsr     CHRIN
    sta     ptr3
    jsr     CHRIN
    sta     ptr3+1

	ldy     #0              ; Y was left at brcmd's length after CHROUT loop - must reset before reading
readloop:
	jsr     CHRIN
    sta     (ptr1),y
    iny
    bne     readloop

    jsr     CLRCHN

success:
	clc

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

; small routine to convert an integer to convert the track/sector to PETSCII characters
; spits them out as A = ones and X = tens

convert_string:
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
    tax
    tya
    jmp     add_ones
skip_tens:
    ldx     #' '
add_ones:
    clc
    adc     #'0'
    tay
    txa
    rts