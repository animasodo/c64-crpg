; ---------------------------------------------------------------
; draw_box_border
;   draw the border of a box
;
; in:  X = y position
;      Y = x position
;      arg0 = length
;      arg1 = height
; ---------------------------------------------------------------

    .autoimport	on
	.importzp	tmp1, tmp2, tmp3, tmp4, arg0, arg1
	.export		draw_box_border
	.include	"c64.inc"
	.include	"cbm_kernal.inc"
	.include	"macros.inc"

.segment	"CODE"

.proc	draw_box_border: near

	CORNER = $5C

	lda		CHARCOLOR
	sta		tmp4

	sty		tmp1
	stx		tmp2			; store x and y
	jsr		goto

	dec		arg0
	dec		arg0
	dec		arg1
	dec		arg1

	lda		#$07
	sta		CHARCOLOR
	lda		#CORNER
	jsr		setchar
	inc		CURS_X

	lda		#$0E
	sta		CHARCOLOR
	lda		arg0
	jsr		draw_hor

	lda		#$07
	sta		CHARCOLOR
	lda		#CORNER
	jsr		setchar
	jsr		advance_screen_ptr
	
	lda		#$0E
	sta		CHARCOLOR
	lda		arg1
	jsr		draw_ver

	ldy		tmp1
	ldx		tmp2
	jsr		goto

	jsr		advance_screen_ptr
	lda		#$0E
	sta		CHARCOLOR
	lda		arg1
	jsr		draw_ver

	lda		#$07
	sta		CHARCOLOR
	lda		#CORNER
	jsr		setchar
	inc		CURS_X

	lda		#$0E
	sta		CHARCOLOR
	lda		arg0
	jsr		draw_hor

	lda		#$07
	sta		CHARCOLOR
	lda		#CORNER
	jsr		setchar

	lda		tmp4
	sta		CHARCOLOR

	rts

.endproc