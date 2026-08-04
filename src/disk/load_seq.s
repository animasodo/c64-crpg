; ---------------------------------------------------------------
; load_seq
;   reads ptr2 bytes from a disk drive into ptr1
;   must call SETNAM + SETLFS beforehand
;
; in:  ptr1 = destination address
;      ptr2 = number of bytes to read
;
; out: carry set on error
;      A holds the KERNAL error code if carry set
;      ptr1 = address just past the last byte written
;      ptr2 = 0 on success, bytes still remaining on failure
; ---------------------------------------------------------------

	.autoimport		on
	.importzp		ptr1, ptr2
	.export			load_seq
	.include		"c64.inc"
    .include		"cbm_kernal.inc"
    .include		"definitions.inc"

.segment	"CODE"

.proc load_seq: near

	jsr     OPEN
	bcs     fail                ; OPEN itself failed, A already set

	ldx     #LFN
	jsr     CHKIN
	bcs     fail_close

readloop:
	lda     ptr2
	ora     ptr2+1
	beq     success             ; count hit zero -> done

	jsr     CHRIN
	ldy     #$00
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

	jsr     READST
	beq     readloop            ; 0 = still healthy, keep going

	; nonzero status: EOF or a real error. If we still have
	; bytes left to read at this point, treat it as a failure.
	lda     #$00                ; generic "short read" code
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
