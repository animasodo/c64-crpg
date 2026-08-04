; ---------------------------------------------------------------
; draw_solid_box
;   draw a box with a solid box with a custom character
; 
; in:  A = character
;      X = y position
;      Y = x position
;      arg0 = length
;      arg1 = height
;      arg2 = color
; ---------------------------------------------------------------

    .autoimport	on
    .importzp   tmp1, tmp2, arg0, arg1, arg2
	.export		draw_solid_box
	.include    "c64.inc"
	.include    "definitions.inc"

.segment	"CODE"

.proc	draw_solid_box: near

	sta		tmp1			; store the character
	sty		tmp2			; store the first x position
	jsr		goto

	ldx		arg1
box_row_loop:
	ldy		tmp2
box_char_loop:
	lda		tmp1
	sta		(SCREEN_PTR),y
	lda		arg2
	sta		(CRAM_PTR),y
	iny
	cpy		arg0
	bne		box_char_loop

	dex
	jsr		advance_screen_ptr

	cpx		#$00
	bne		box_row_loop
	rts

.endproc