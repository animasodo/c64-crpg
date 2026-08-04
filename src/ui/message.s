; ---------------------------------------------------------------
; message
;   writes a formatted message in the bottom box
;
; in:  A, X = pointer to the formatted string
; ---------------------------------------------------------------

	.autoimport	on
	.importzp	ptr, arg0, arg1, tmp1
	.export		message
	.include	"c64.inc"
	.include	"definitions.inc"

.segment	"CODE"

.proc	message: near

	sta		ptr
	stx		ptr+1
	ldy     #$01
	sty		CHARCOLOR

	ldx		#$14
	lda		#$1A
	sta		arg0
	lda		#$04
	sta		arg1
	lda		#' '
	jsr		draw_solid_box

	ldy     #$01
	ldx     #$14
	jsr     goto
	lda		ptr
	ldx		ptr+1
	jmp     formatwrite

.endproc

