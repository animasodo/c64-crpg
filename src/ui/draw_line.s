; ---------------------------------------------------------------
; draw_ver
;   draw a vertical line
; ---------------------------------------------------------------
; draw_hor
;   draw a horizontal line
; ---------------------------------------------------------------

	.autoimport	on
	.importzp	tmp3
	.export		draw_ver, draw_hor
	.include    "c64.inc"
	.include    "definitions.inc"
	.include    "macros.inc"

draw_ver:
	sta		tmp3
write_vertical_border:
	lda		#$5D
	jsr		setchar					; write
	jsr		advance_screen_ptr		; nl
	dec		tmp3
	bne		write_vertical_border
	rts

draw_hor:
	sta		tmp3
write_horizontal_border:
	lda		#$40
	jsr		setchar					; write
	inc		CURS_X					; advance
	dec		tmp3
	bne		write_horizontal_border
	rts