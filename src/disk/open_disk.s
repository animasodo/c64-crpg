
	.autoimport		on
	.importzp		ptr1, ptr2, ptr3, tmp1, tmp2
	.export			open_disk
	.include		"c64.inc"
    .include		"cbm_kernal.inc"
    .include		"definitions.inc"
    .include        "manifest.inc"
    
    DATA_OUT := $20 ; bit 5
    VIC_OUT  := $00 ; bits need to be on to keep VIC happy

    ; on the drive side
    track = $06
    sector = $07

.segment    "CODE"

open_disk:
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
    
wait_for_disk_routine: ; we need to make sure our drive code is running before doing anything
	bit     CIA2_PRA
	bvs     wait_for_disk_routine

    rts

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
