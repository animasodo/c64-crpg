; ---------------------------------------------------------------
; clear_viewport
;   clears the viewport inside the game UI
; ---------------------------------------------------------------

    .autoimport	on
	.importzp	arg0, arg1, arg2
	.export		clear_viewport
	.include    "c64.inc"

.segment	"CODE"

.proc	clear_viewport: near

	lda		#$1B
	sta		arg0
	lda		#$12
	sta		arg1
	lda		#$00
	sta		arg2
	lda		#' '
	ldx		#$01
	ldy		#$01
	jmp		draw_solid_box

.endproc