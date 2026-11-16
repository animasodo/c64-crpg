
	.autoimport		on
	.importzp		ptr1, ptr2, ptr3, tmp1, tmp2
	.export			load_from_ts
	.include		"c64.inc"
    .include		"cbm_kernal.inc"
    .include		"definitions.inc"
    .include        "manifest.inc"

    ATN_OUT := $08 ; bit 3
    DATA_OUT := $20 ; bit 5
    CLK_OUT  := $10 ; bit 4
    VIC_OUT  := $00 ; bits need to be on to keep VIC happy

    ; on the drive side
    track = $06
    sector = $07

.segment    "CODE"

load_from_ts:
    jsr     open_disk

block_loop:
    lda     ptr2
    ora     ptr2+1
    beq     success
get_rest_loop:
	
    jsr     receive_byte
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

	jmp     block_loop

success:
    lda     #VIC_OUT | ATN_OUT ; send ATN signal so that the drive goes back to normal
    sta     CIA2_PRA
    cli

    lda     #15
    jmp     CLOSE
