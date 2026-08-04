; ---------------------------------------------------------------
; draw_main_ui
;   draw the main game ui
; ---------------------------------------------------------------

	.autoimport	on
	.importzp	tmp1, tmp2, tmp3, tmp4, arg0, arg1, arg2, sreg, ptr2, ptr3, byte0, byte7
	.export		draw_main_ui
	.include	"c64.inc"
	.include	"cbm_kernal.inc"
	.include	"macros.inc"

.segment	"CODE"

.proc	draw_main_ui: near

	lda		CHARCOLOR
	sta		byte0

	jsr     CLRSCR

	ldy		#0
	ldx		#0
	lda     #40
	sta		arg0
	lda     #25
	sta		arg1
	jsr     draw_box_border

	ldy		#27
	ldx		#0
	lda     #13
	sta		arg0
	lda     #25
	sta		arg1
	jsr     draw_box_border

	ldy		#0
	ldx		#19
	lda     #28
	sta		arg0
	lda     #6
	sta		arg1
	jsr     draw_box_border

	lda     #$07
	sta     CHARCOLOR

	ldy		#29
	ldx		#0
	jsr		goto
	lda     #<(playerName)
	ldx     #>(playerName)
	jsr     print

	ldy		#29
	ldx		#2
	jsr		goto
	lda     #<(health_str)
	ldx     #>(health_str)
	jsr     print

	ldy		#29
	ldx		#4
	jsr		goto
	lda     #<(stamina_str)
	ldx     #>(stamina_str)
	jsr     print

	ldy		#29
	ldx		#6
	jsr		goto
	lda     #<(power_str)
	ldx     #>(power_str)
	jsr     print

	ldy		#29
	ldx		#8
	jsr		goto
	lda     #<(exp_str)
	ldx     #>(exp_str)
	jsr     print

	ldy		#29
	ldx		#10
	jsr		goto
	lda     #<(gold_str)
	ldx     #>(gold_str)
	jsr     print

	jsr     draw_stats

	lda     #$02
	sta     $D825

	show_direction

	lda     byte0
	sta		CHARCOLOR
	rts

.endproc
