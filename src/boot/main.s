
	.autoimport	on
	.importzp	tmp1, tmp2, tmp3, tmp4, ptr1, ptr2, ptr3, ptr4
	.macpack	longbranch
	.forceimport	__STARTUP__
	.importzp	byte0, byte1, ptr
	.export		main
	.include	"definitions.inc"
	.include	"macros.inc"
	.include	"c64.inc"

.segment	"RODATA"

S0019:
	.byte	"Storage", 0

; this is the main() function mostly unmodified
; it will get chopped up later on

.segment	"CODE"

.proc	main: near

	jsr     draw_main_ui

	lda     #$00
	jsr     load_map_compressed

	set_sprite_pointer $CC00, 0
	set_sprite_multicolor $FF
	set_sprite_multicolor_color WHITE, 0
	set_sprite_multicolor_color BLUE, 1
	set_sprite_color CYAN, 0
	set_sprite_visibility %00000001
	set_sprite_x X_OFFSET+88, 0
	set_sprite_y X_OFFSET+72, 0

	; copy character sprites
	ldy     #$3E
:	lda     lizard_sprite_0,y
	sta     $CC00,y
	dey
	bpl     :-

	ldy     #$3E
:	lda     lizard_sprite_1,y
	sta     $CC40,y
	dey
	bpl     :-

	ldy     #$3E
:	lda     lizard_sprite_0_walking,y
	sta     $CC80,y
	dey
	bpl     :-

	ldy     #$3E
:	lda     lizard_sprite_1_walking,y
	sta     $CCC0,y
	dey
	bpl     :-

	lda     #$09
	sta     playerx
	lda     #$05
	sta     playery
	jsr     set_camera_sprite
	jsr     drawmap
	jsr     init_irq

game_loop:
	jsr     SCNKEY
	jsr     GETIN
	sta     lastKey

	lda     playerInput	; if player has pressed a direction (walk)
	and     #$0F
	beq     :+
	jsr     walk

	; check keyboard inputs
:	lda     lastKey
	cmp     #'o'
	beq     open
	cmp     #'q'
	jeq     save
	cmp     #'s'
	jeq     storage
	cmp     #'w'
	jeq     load
	jmp     game_loop

open:
	lda     playerx
	sta     byte0
	lda     playery
	sta     byte1
	lda     direction
	beq     north
	cmp     #$01
	beq     east
	cmp     #$02
	beq     south
	cmp     #$03
	beq     west
	jmp     L002E
north:
	dec     byte1
	jmp     L002E
east:
	inc     byte0
	jmp     L002E
south:
	inc     byte1
	jmp     L002E
west:
	dec     byte0
L002E:
	lda     mapWidth
	ldx     byte1
	jsr     mul8x8
	clc
	adc     byte0
	bcc     :+
	inx
	:
	sta     ptr1
	stx     ptr1+1
	lda     #<(mapBuffer)
	clc
	adc     ptr1
	sta     ptr
	lda     #>(mapBuffer)
	adc     ptr1+1
	sta     ptr+1
	ldy     #$00
	lda     (ptr),y
	cmp     #$1F
	bne     L0014
	lda     #$03
	sta     (ptr),y
	lda     #<(door_open)
	ldx     #>(door_open)
	jsr     message
	jsr     drawmap
	jmp     game_loop
L0014:	lda     #<(no_door)
	ldx     #>(no_door)
	jsr     message
	jmp     game_loop

save:	lda     #<(save_to)
	ldx     #>(save_to)
	jsr     message
	lda     #$02
	jsr     read_string
	lda     buffer_prompt
	cmp     #$38
	beq     L0017
	cmp     #$39
	beq     L0017
	lda     #<(device_number_error)
	ldx     #>(device_number_error)
	jsr     message
	jmp     game_loop
L0017:	jsr     save_data
	jmp     game_loop

load:
	lda     #<(load_from)
	ldx     #>(load_from)
	jsr     message
	lda     #$02
	jsr     read_string
	lda     buffer_prompt
	cmp     #$38
	jeq     game_loop
	cmp     #$39
	jeq     game_loop
	lda     #<(device_number_error)
	ldx     #>(device_number_error)
	jsr     message
	jmp     game_loop

storage:
	jsr     clear_viewport
	lda     #$00
	sta     $D015
	lda     #$07
	sta		CHARCOLOR
	ldx		#$02
	ldy     #$02
	jsr		goto
	lda     #<(S0019)
	ldx     #>(S0019)
	jsr     print
L0023:
	jsr     _cgetc
	sta     lastKey
	cmp     #'s'
	bne     L0023
	jsr     drawmap
	set_sprite_visibility $FF

	jmp     game_loop

.endproc

