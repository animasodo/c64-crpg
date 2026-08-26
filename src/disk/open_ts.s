; ---------------------------------------------------------------
; open_ts
;   open the disk for direct t/s access
; ---------------------------------------------------------------

    .autoimport	on
    .importzp   byte_in_sector
    .export		open_ts
    .include    "c64.inc"
    .include    "cbm_kernal.inc"
    .include    "definitions.inc"

.segment	"CODE"

.proc	open_ts: near

    ; open command channel
    lda     #COMMAND
    ldx     #FLOPPY
    ldy     #COMMAND
    jsr     SETLFS
    lda     #0
    sta		byte_in_sector ; also set this
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
    jmp     OPEN

.endproc