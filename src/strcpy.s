; ---------------------------------------------------------------
; strcpy
; have source already in ptr1 and destiny in A and X
; ---------------------------------------------------------------

	.importzp       ptr1, ptr2
	.export         strcpy

strcpy:
	sta     ptr2
	stx     ptr2+1
	ldy     #$00

l0:	lda     (ptr1),y
	sta     (ptr2),y
	beq     ex
	iny
	jmp		l0

ex:	lda     ptr2
	rts
