; ---------------------------------------------------------------
; scroll_text
;   scrolls the message text
; ---------------------------------------------------------------

	.autoimport	on
	.importzp	ptr1, ptr2
	.export		scroll_text
	.include	"c64.inc"
	.include	"definitions.inc"

.segment	"CODE"

.proc	scroll_text: near

    lda     #<(SCREEN_AREA + (40 * 20) + 1)
    sta     lower_ptr
    lda     #>(SCREEN_AREA + (40 * 20) + 1)
    sta     lower_ptr+1
    lda     #<(SCREEN_AREA + (40 * 21) + 1)
    sta     upper_ptr
    lda     #>(SCREEN_AREA + (40 * 21) + 1)
    sta     upper_ptr+1
    jsr     scroll_up ; first pass for characters

    ; clear the last line before we scroll up the colors
    ldy     #$00
    lda     #' '
clear_last_line_loop:
    sta     (lower_ptr),y
    iny
    cpy     #HORIZONTAL_VIEW
    bne     clear_last_line_loop

    lda     #<(COLOR_AREA + (40 * 20) + 1)
    sta     lower_ptr
    lda     #>(COLOR_AREA + (40 * 20) + 1)
    sta     lower_ptr+1
    lda     #<(COLOR_AREA + (40 * 21) + 1)
    sta     upper_ptr
    lda     #>(COLOR_AREA + (40 * 21) + 1)
    sta     upper_ptr+1
    jmp     scroll_up ; second pass for colors

scroll_up:
    ldx     #$03
outer_loop:
    ldy     #$00
inner_loop:
    lda     (upper_ptr),y
    sta     (lower_ptr),y
    iny
    cpy     #HORIZONTAL_VIEW
    bne     inner_loop

    lda     lower_ptr
    clc
    adc     #XSIZE
    sta     lower_ptr
    bcc     :+
    inc     lower_ptr+1
    :

    lda     upper_ptr
    clc
    adc     #XSIZE
    sta     upper_ptr
    bcc     :+
    inc     upper_ptr+1
    :

    dex
    bne     outer_loop
    rts

.endproc

.segment    "ZEROPAGE" : zeropage
    upper_ptr: .res 2
    lower_ptr: .res 2
