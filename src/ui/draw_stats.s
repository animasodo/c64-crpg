; ---------------------------------------------------------------
; draw_stats
; ---------------------------------------------------------------

	.autoimport	on
	.importzp	byte7
	.export		draw_stats
	.include	"c64.inc"
	.include	"cbm_kernal.inc"
	.include	"definitions.inc"

.segment	"CODE"

.proc	draw_stats: near

	ldy		CHARCOLOR
	lda		#$01
	sta		CHARCOLOR
	sty		byte7

	ldx		#3
	ldy		#30
	jsr		goto

	lda		#<(playerHealth)
	ldx		#>(playerHealth)
	jsr		utoa_8
	jsr		formatwrite

	ldx		#5
	ldy		#30
	jsr		goto

	lda		#<(playerStamina)
	ldx		#>(playerStamina)
	jsr		utoa_8
	jsr		formatwrite

	ldx		#7
	ldy		#30
	jsr		goto

	lda		#<(playerPower)
	ldx		#>(playerPower)
	jsr		utoa_8
	jsr		formatwrite

	ldx		#9
	ldy		#30
	jsr		goto

	lda		#<(playerExp)
	ldx		#>(playerExp)
	jsr		utoa_16
	jsr		formatwrite

	ldx		#11
	ldy		#30
	jsr		goto

	lda		#<(gold)
	ldx		#>(gold)
	jsr		utoa_16
	jsr		formatwrite

	lda		byte7
	sta		CHARCOLOR
	rts

.endproc