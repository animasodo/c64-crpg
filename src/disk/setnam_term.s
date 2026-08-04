; ---------------------------------------------------------------
; setnam_term
;   get the length of a null-terminated string and run SETNAM
;
; in:  X, Y = string pointer
; ---------------------------------------------------------------

	.autoimport		on
	.importzp		ptr1
	.export         setnam_term
	.include        "c64.inc"
    .include        "cbm_kernal.inc"
    .include        "definitions.inc"

.segment	"CODE"

.proc setnam_term: near

	stx     ptr1
	sty     ptr1+1
	ldy     #$FF
l0:	iny
	lda     (ptr1),y
	bne     l0

	tya
	ldy     ptr1+1
	jmp     SETNAM

.endproc