
    .importzp	c_sp
	.importzp	_idx8, _idx16, _byte0, _byte1, _ptr, tmp1, tmp2
	.import		popa, pusha, tosumula0, pushax
    .import     _doors, _playerx, _playery, _lastKey, _playerInput, _direction, _mapBuffer, _mapWidth, _warps, _drawmap, _dirChar, _load_map_compressed, _mapId, _delayFrames, _camerax, _cameray
	.export		_findDoor, _setCameraSprite, _walk
	.include    "c64.inc"

	UP = 1
	DOWN = 2
	LEFT = 4
	RIGHT = 8

	NORTH = 0
	EAST = 1
	SOUTH = 2
	WEST = 3

	X_OFFSET = 24
	Y_OFFSET = 50

; ---------------------------------------------------------------
; char findDoor(char x, char y);
; ---------------------------------------------------------------

.segment	"CODE"

.proc	_findDoor: near

    _doors_x = _doors
    _doors_y = _doors+8
	
	; i can probably repurpose this code for something like npcs
    sta     tmp1
    jsr     popa
    sta     tmp2
    ldy     #$00
loop:
    lda     _doors_x,y
    cmp     tmp2
    bne     skip
    lda     _doors_y,y
    cmp     tmp1
    bne     skip

    tya
    rts
skip:
    iny
    cpy     #$08
    bne     loop
    lda     #$FF
    rts

.endproc

; ---------------------------------------------------------------
; void __near__ setCameraSprite (void)
; ---------------------------------------------------------------

.segment	"CODE"

.proc	_setCameraSprite: near

	lda     _playerx
	sec
	sbc		#$06
	sta		_camerax

	; set sprite 0 x to X_OFFSET + 104
	lda     #X_OFFSET + 104
	sta     VIC_SPR0_X

	lda     _playery
	sec
	sbc		#$04
	sta		_cameray

	; set sprite 0 y to Y_OFFSET + 72
	lda     #Y_OFFSET + 72
	sta     VIC_SPR0_Y
	rts

.endproc

; ---------------------------------------------------------------
; void walk(void);
; ---------------------------------------------------------------

.segment	"CODE"

.proc	_walk: near

	_warps_id = _warps
	_warps_src_x = _warps+8
	_warps_src_y = _warps+16
	_warps_dst_x = _warps+24
	_warps_dst_y = _warps+32

    ; calculate position pointer
    ldx     #$00
	lda		_mapWidth
	jsr		pushax
	lda		_playery
	jsr		tosumula0
	clc
	adc     _playerx
	bcc     :+
	inx
	:
	clc
	adc	 	#<(_mapBuffer)
	sta    	_ptr
	txa
	adc     #>(_mapBuffer)
	sta     _ptr+1

    ; check key
	lda     _playerInput
    and     #UP
	beq		skip_up
	ldx		#NORTH
	stx		_direction

	lda		_ptr
	sec
	sbc		_mapWidth
	sta		_ptr
	lda		_ptr+1
	sbc		#$00
	sta		_ptr+1
	lda		(_ptr),y
	cmp		#$10
	bcs		end_up

; 	lda		_playerx
; 	jsr		pusha
; 	ldy		_playery
; 	dey
; 	tya
; 	jsr		_findDoor
; 	bpl		end_up

	dec		_playery
	jmp		continue

end_up:
	jmp		end_key
skip_up:
	lda     _playerInput
    and     #DOWN
	beq		skip_down
	ldx		#SOUTH
	stx		_direction

	lda		_ptr
	clc
	adc		_mapWidth
	sta		_ptr
	lda		_ptr+1
	adc		#$00
	sta		_ptr+1
	lda		(_ptr),y
	cmp		#$10
	bcs		end_down

; 	lda		_playerx
; 	jsr		pusha
; 	ldy		_playery
; 	iny
; 	tya
; 	jsr		_findDoor
; 	bpl		end_down

	inc		_playery
	jmp		continue

end_down:
	jmp		end_key
skip_down:
	lda     _playerInput
    and     #LEFT
	beq		skip_left
	ldx		#WEST
	stx		_direction

	lda		_ptr
	sec
	sbc		#$01
	sta		_ptr
	lda		_ptr+1
	sbc		#$00
	sta		_ptr+1
	lda		(_ptr),y
	cmp		#$10
	bcs		end_left

; 	ldy		_playerx
; 	dey
; 	tya
; 	jsr		pusha
; 	lda		_playery
; 	jsr		_findDoor
; 	bpl		end_left

	dec		_playerx
	jmp		continue

end_left:
	jmp		end_key
skip_left:
	lda     _playerInput
    and     #RIGHT
	beq		skip_right
	ldx		#EAST
	stx		_direction

	lda		_ptr
	clc
	adc		#$01
	sta		_ptr
	lda		_ptr+1
	adc		#$00
	sta		_ptr+1
	lda		(_ptr),y
	cmp		#$10
	bcs		end_right

; 	ldy		_playerx
; 	iny
; 	tya
; 	jsr		pusha
; 	lda		_playery
; 	jsr		_findDoor
; 	bpl		end_right

	inc		_playerx
	jmp		continue

end_right:
skip_right:
end_key:
	jmp		end_warp

continue:

	; set sprite direction
	lda		_direction
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

	lda		#$05
	jsr		_delayFrames

	ldy		#$00
warp_check:
	lda		_playerx
	cmp		_warps_src_x,y
	bne		skip_warp
	lda		_playery
	cmp		_warps_src_y,y
	bne		skip_warp

	lda		_mapId
	cmp		_warps_id,y
	beq		:+
	sty		_byte0
	jsr		_load_map_compressed
	ldy		_byte0
	:

	lda		_warps_dst_x,y
	sta		_playerx
	lda		_warps_dst_y,y
	sta		_playery
	jmp		end_warp
skip_warp:
	iny
	cpy		#$08
	bne		warp_check
end_warp:

	jsr		_setCameraSprite
	ldy		_direction
	lda		_dirChar,y
	sta		$C800 + (40 * 0) + 37
	jsr		_drawmap

	; set sprite direction
	lda		_direction
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
