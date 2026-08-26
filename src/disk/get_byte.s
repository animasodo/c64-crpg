; ---------------------------------------------------------------
; get_byte
;   gets a byte from the current input channel
;
; out:  A = byte read
; ---------------------------------------------------------------

    .export		get_byte, byte_in_sector, databuf_name, next_track, next_sector
    .include    "c64.inc"
    .include    "cbm_kernal.inc"
    .include    "definitions.inc"

.segment    "RODATA"

brcmd:
    .byte "u1:2 0", 0
databuf_name:
    .byte "#" ; opens the data channel as a direct-access buffer channel

.segment	"CODE"

.proc	get_byte: near

    lda     byte_in_sector
    beq     get_byte_read ; if byte_in_sector is 0, we need to read a new t/s
    dec     byte_in_sector
    jmp     CHRIN

get_byte_read:
    ldx     #COMMAND
    jsr     CHKOUT ; we're gonna send some stuff to the disk drive
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
    
    lda     #254 ; 254 bytes per sector
    sta     byte_in_sector
    jsr     CHRIN
    sta     next_track
    jsr     CHRIN
    sta     next_sector
    jmp     CHRIN

.endproc

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

.segment    "ZEROPAGE" : zeropage
    byte_in_sector:     .res 1
    next_track:         .res 1
    next_sector:        .res 1
