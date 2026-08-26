; ---------------------------------------------------------------
; load_from_ts
;   reads ptr2 bytes from a disk drive into ptr1
;
; in:  A = track to read from
;      X = sector to read from
;      ptr1 = destination address
;      ptr2 = number of bytes to read
; ---------------------------------------------------------------

	.autoimport		on
	.importzp		ptr1, ptr2, ptr3, next_track, next_sector
	.export			load_from_ts
	.include		"c64.inc"
    .include		"cbm_kernal.inc"
    .include		"definitions.inc"
    .include        "manifest.inc"

.segment	"CODE"

.proc load_from_ts: near
    sta     next_track
    stx     next_sector
	jsr     open_ts

read_loop:
    lda     ptr2
    ora     ptr2+1
    beq     success

    jsr     get_byte
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
    bne     read_loop

success:
    jmp     close_ts

.endproc
