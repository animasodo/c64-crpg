
	.autoimport	on
	.importzp	ptr
	.export		walk
	.include    "c64.inc"
	.include    "definitions.inc"
	.include    "macros.inc"

.segment	"CODE"

.proc	walk: near

    ; calculate position pointer
	lda		mapWidth
	ldx		playery
	jsr		mul8x8
	clc
	adc     playerx
	bcc     :+
	inx
	:
	clc
	adc	 	#<(mapBuffer)
	sta    	ptr
	txa
	adc     #>(mapBuffer)
	sta     ptr+1

	ldy		#$00

    ; check key
	lda     playerInput
    and     #UP
	beq		skip_up
	ldx		#NORTH
	stx		direction

	lda		ptr
	sec
	sbc		mapWidth
	sta		ptr
	lda		ptr+1
	sbc		#$00
	sta		ptr+1
	lda		(ptr),y
	cmp		#$10
	bcs		end_up

; 	ldx		playerx
; 	ldy		playery
; 	dey
; 	jsr		find_door
; 	bpl		end_up

	dec		playery
	jmp		continue

end_up:
	jmp		end_key
skip_up:
	lda     playerInput
    and     #DOWN
	beq		skip_down
	ldx		#SOUTH
	stx		direction

	lda		ptr
	clc
	adc		mapWidth
	sta		ptr
	lda		ptr+1
	adc		#$00
	sta		ptr+1
	lda		(ptr),y
	cmp		#$10
	bcs		end_down

; 	ldx		playerx
; 	ldy		playery
; 	iny
; 	jsr		find_door
; 	bpl		end_down

	inc		playery
	jmp		continue

end_down:
	jmp		end_key
skip_down:
	lda     playerInput
    and     #LEFT
	beq		skip_left
	ldx		#WEST
	stx		direction

	lda		ptr
	sec
	sbc		#$01
	sta		ptr
	lda		ptr+1
	sbc		#$00
	sta		ptr+1
	lda		(ptr),y
	cmp		#$10
	bcs		end_left

; 	ldx		playerx
; 	dex
; 	ldy		playery
; 	jsr		find_door
; 	bpl		end_left

	dec		playerx
	jmp		continue

end_left:
	jmp		end_key
skip_left:
	lda     playerInput
    and     #RIGHT
	beq		skip_right
	ldx		#EAST
	stx		direction

	lda		ptr
	clc
	adc		#$01
	sta		ptr
	lda		ptr+1
	adc		#$00
	sta		ptr+1
	lda		(ptr),y
	cmp		#$10
	bcs		end_right

; 	ldx		playerx
; 	inx
; 	ldy		playery
; 	jsr		find_door
; 	bpl		end_right

	inc		playerx
	jmp		continue

end_right:
skip_right:
end_key:
	jmp		end_warp

continue:

	; set sprite direction
	lda		direction
	cmp		#NORTH
	beq		:+
	cmp		#EAST
	beq		:+
	; SOUTH/WEST
	; POKE(0xCBF8 + index, (pointer - 0xC000) / 64)
	lda		#($CC80 - $C000) / 64
	sta		$CBF8 + 0
	jmp		skip_sprite_1
	:
	; NORTH/EAST
	; POKE(0xCBF8 + index, (pointer - 0xC000) / 64)
	lda		#($CCC0 - $C000) / 64
	sta		$CBF8 + 0
skip_sprite_1:

	ldy		#$05
	jsr		delay_frames

	ldy		#$00
warp_check:
	lda		playerx
	cmp		warp_src_x,y
	bne		skip_warp
	lda		playery
	cmp		warp_src_y,y
	bne		skip_warp

	lda		warp_dst_x,y
	sta		playerx
	lda		warp_dst_y,y
	sta		playery

	lda		warp_id,y
	cmp		mapId
	beq		:+
	tay
	jsr		load_map_compressed
	:

	jmp		end_warp
skip_warp:
	iny
	cpy		#$08
	bne		warp_check
end_warp:

	jsr		set_camera_sprite
	show_direction
	jsr		drawmap

	; set sprite direction
	lda		direction
	cmp		#NORTH
	beq		:+
	cmp		#EAST
	beq		:+
	; SOUTH/WEST
	; POKE(0xCBF8 + index, (pointer - 0xC000) / 64)
	lda		#($CC00 - $C000) / 64
	sta		$CBF8 + 0
	jmp		skip_sprite_2
	:
	; NORTH/EAST
	; POKE(0xCBF8 + index, (pointer - 0xC000) / 64)
	lda		#($CC40 - $C000) / 64
	sta		$CBF8 + 0
skip_sprite_2:

	rts

.endproc