
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
    jsr		open_disk

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

	jmp     block_loop

success:
    cli
    lda     #15
    jmp     CLOSE
