; ---------------------------------------------------------------
; set_camera_sprite
;   set the position of the camera and the sprite
; ---------------------------------------------------------------

	.autoimport	on
	.export		set_camera_sprite
	.include    "c64.inc"
	.include    "definitions.inc"

.segment	"CODE"

.proc	set_camera_sprite: near

	lda     playerx
	sec
	sbc		#$06
	sta		camerax

	; set sprite 0 x to X_OFFSET + 104
	lda     #X_OFFSET + 104
	sta     VIC_SPR0_X

	lda     playery
	sec
	sbc		#$04
	sta		cameray

	; set sprite 0 y to Y_OFFSET + 72
	lda     #Y_OFFSET + 72
	sta     VIC_SPR0_Y
	rts

.endproc
