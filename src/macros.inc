; ---------------------------------------------------------------
; macros.inc
;   this is a general list of macros, use with caution as
;   they can take up a lot of space compared to subroutines.
; ---------------------------------------------------------------

	.autoimport	on

.macro set_sprite_pointer address, index

	lda     #((address-$C000)/64)
	sta     $CBF8+index

.endmacro

.macro set_sprite_multicolor value

	lda     #value
	sta     VIC_SPR_MCOLOR

.endmacro

.macro set_sprite_multicolor_color color, index

	lda     #color
	sta     VIC_SPR_MCOLOR0+index

.endmacro

.macro set_sprite_color color, index

	lda     #color
	sta     VIC_SPR0_COLOR+index

.endmacro

.macro set_sprite_visibility value

	lda     #value
	sta     VIC_SPR_ENA

.endmacro

.macro set_sprite_x value, index

	lda     #value
	sta     VIC_SPR0_X+(index*2)

.endmacro

.macro set_sprite_y value, index

	lda     #value
	sta     VIC_SPR0_Y+(index*2)

.endmacro

.macro show_direction

	ldy     direction
	lda		dir_char,y
	sta     SCREEN_AREA + (40 * 0) + 37

.endmacro
