
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

    ; on the computer side
    next_track = tmp1
    next_sector = tmp2

    ; on the drive side
    track = $06
    sector = $07

.segment    "CODE"

load_from_ts:

    ; modify command to pass track and sector to drive
    sta     t+1
    stx     s+1

    lda     #15
	sta     $b9
	sta     $b8
	ldx     #<memory_execute
	ldy     #>memory_execute
	lda     #memory_execute_end - memory_execute
	jsr     SETNAM
	jsr     OPEN

    sei
	lda     #VIC_OUT | DATA_OUT ; CLK=0 DATA=1
	sta     CIA2_PRA ; we're not ready to receive

wait_for_disk_routine:
	bit     CIA2_PRA
	bvs     wait_for_disk_routine
    ; we need to make sure our drive code is running before doing anything

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

memory_execute:
	.byte   "m-e"
	.word   $0205
execute_cmd:
t:  lda     #00
    sta     track
s:  lda     #00
    sta     sector
    jmp     $0402
memory_execute_end: