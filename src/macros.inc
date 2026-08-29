; ---------------------------------------------------------------
; macros.inc
;   this is a general list of macros, use with caution as
;   they can take up a lot of space compared to subroutines.
; ---------------------------------------------------------------

	.autoimport	on
	
.macro prepare_disk name, name_length

	.ifblank name
	.else
		ldx     #<(name)
		ldy     #>(name)
	.endif
	.ifblank name_length
		jsr     setnam_term
	.else
		lda     #name_length
		jsr     SETNAM
	.endif

	ldx     #FLOPPY
	ldy     #$02
	lda     #LFN
	jsr     SETLFS

.endmacro

.macro read_seq name, name_length, destination, length

	prepare_disk name, name_length

    lda     #<destination
    sta     ptr1
	lda     #>destination
    sta     ptr1+1
    ; length
    lda     #<length
    sta     ptr2
    lda     #>length
    sta     ptr2+1

    jsr     load_seq

.endmacro

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
