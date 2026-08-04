; ---------------------------------------------------------------
; save_seq
;   writes ptr2 bytes to a disk drive from ptr1
;   must call SETNAM + SETLFS beforehand
;
; in:  ptr1 = source address
;      ptr2 = number of bytes to write
;
; out: carry set on error
;      A holds the KERNAL error code
;      ptr1 = address just past the last byte written
;      ptr2 = 0 on success, bytes still unwritten on failure
; ---------------------------------------------------------------

	.autoimport		on
	.importzp		ptr1, ptr2
    .export			save_seq
	.include		"c64.inc"
    .include		"cbm_kernal.inc"
    .include		"definitions.inc"

.segment	"CODE"

.proc save_seq: near

	jsr     OPEN
	bcs     fail                ; OPEN itself failed, A already set

	ldx     #LFN
	jsr     CHKOUT
	bcs     fail_close

writeloop:
	lda     ptr2
	ora     ptr2+1
	beq     success             ; count hit zero -> done

	ldy     #$00
	lda     (ptr1),y
	jsr     CHROUT

	inc     ptr1
	bne     :+
	inc     ptr1+1
	:
	lda     ptr2
	bne     :+
	dec     ptr2+1
	:
	dec     ptr2

	jsr     READST
	beq     writeloop           ; 0 = still healthy, keep going

	; nonzero status mid-write -> disk full or similar. Treat
	; as failure even though we did write some bytes.
	lda     #$00
	sec
	bne     fail_close

success:
	clc

fail_close:
	php
	lda     #LFN
	jsr     CLOSE
	jsr     CLRCHN
	plp
fail:
	rts

.endproc
