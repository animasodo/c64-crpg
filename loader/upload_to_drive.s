;
; load our fast loading routine to the drive's memory
; it's located in track 18 sector 18
;

	.autoimport		on
	.export			upload_to_drive
	.include		"c64.inc"
    .include		"cbm_kernal.inc"
    .include		"definitions.inc"
    .include        "manifest.inc"

.segment	"CODE"

upload_to_drive:
    lda     #15
    sta     $b9   ; secondary address
    sta     $b8   ; logical file number
    ldx     #<cmd
    ldy     #>cmd
    lda     #cmd_end - cmd
    jsr     SETNAM
    jsr     OPEN
    lda     #15
    jsr     CLOSE
    rts

cmd:
    .byte   "m-e"
    .word   $0200 + cmd_code - cmd
cmd_code:
    lda     #18   ; track 18, sector 18
    sta     $08
    sta     $09
    lda     #1    ; buffer at $0400
    sta     $f9
    jmp     $d586 ; read sector
cmd_end:
