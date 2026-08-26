; ---------------------------------------------------------------
; close_ts
;   close the disk for direct t/s access
; ---------------------------------------------------------------

    .autoimport	on
    .importzp   byte_in_sector
    .export		close_ts
    .include    "c64.inc"
    .include    "cbm_kernal.inc"
    .include    "definitions.inc"

.segment	"CODE"

.proc	close_ts: near

    jsr     CLRCHN
    ldx     #COMMAND
    jsr     CHKOUT
    jsr     CLRCHN

    lda     #COMMAND
	jsr     CLOSE
	lda     #LFN
	jsr     CLOSE
	jmp     CLRCHN

.endproc