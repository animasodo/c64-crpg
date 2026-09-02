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

	ldy     #$01
	ldx     #$17
	jsr     goto
	jsr		scroll_text

	lda		#CYAN
	sta		CHARCOLOR
	lda		#'*'
	jsr		printchar
	lda		#WHITE
	sta		CHARCOLOR

	lda		ptr
	ldx		ptr+1
	jmp     formatwrite

.endproc

