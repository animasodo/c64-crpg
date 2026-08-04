
	.autoimport	on
	.importzp	tmp1
	.export		mul8x8
	.include    "c64.inc"

; ---------------------------------------------------------------
; mul8x8
;   multiply two 8 bit integers, return 16 bit integer
;   keep lowest number in x register for speed
;
; in:  A = multiplicand
;      X = multiplier
;
; out: A, X = 16-bit result
; ---------------------------------------------------------------

.segment	"CODE"

.proc	mul8x8: near

	cpx		#$00
	bne		j0
	lda		#$00
	rts

j0:	ldy		#$00
	sta		tmp1
l0:	dex
	beq		j1
	clc
	adc		tmp1
	bcc		l0
	iny
	jmp		l0
j1:	sty		tmp1
	ldx		tmp1
	rts

.endproc
