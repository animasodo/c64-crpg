;
; void drawmap(void);
; takes about two frames to update the map
;

	.importzp	c_sp
	.importzp	tmp1, _idx8, _jdx8, _byte0, _byte1, _byte2, _byte3, _byte4, _byte5, _byte6, _byte7, _ptr
	.import		_camerax, _cameray, _mapBuffer, _mapWidth, _mapHeight, advance_screen_ptr, setchar, _doors, pushax, _waitvsync, mul8x8, goto
	.export		_drawmap
	.include	"c64.inc"
	.include	"cbm_kernal.inc"

	HEIGHT = $09
	WIDTH = $0D
	X_OFFSET = $18
	Y_OFFSET = $32

.segment "RODATA"

; graphics data
topleft_chr:
	.byte	$B0, $B8, $B5, $B4, $B7, $B9, $B8, $B2, $B2, $B1, $B1, $B1, $B1, $B9, $B9, $BC
	.byte	$B2, $B1, $B1, $B1, $B1, $B1, $B1, $B1, $B1, $B1, $B1, $B1, $B1, $B1, $B1, $D0
topright_chr:
	.byte	$B0, $B8, $B5, $B4, $B7, $B9, $B8, $B3, $B3, $B1, $B1, $B1, $B1, $B9, $B9, $BD
	.byte	$B3, $B1, $B1, $B1, $B1, $B1, $B1, $B1, $B1, $B1, $B1, $B1, $B1, $B1, $B1, $D1
botleft_chr:
	.byte	$B0, $B8, $B6, $B4, $B7, $BA, $B8, $B2, $B3, $B1, $B1, $B1, $B1, $B9, $BA, $BE
	.byte	$B3, $B1, $B1, $B1, $B1, $B1, $B1, $B1, $B1, $B1, $B1, $B1, $B1, $B1, $B1, $D2
botright_chr:
	.byte	$B0, $B8, $B6, $B4, $B7, $BB, $B8, $B3, $B2, $B1, $B1, $B1, $B1, $B9, $BB, $BF
	.byte	$B2, $B1, $B1, $B1, $B1, $B1, $B1, $B1, $B1, $B1, $B1, $B1, $B1, $B1, $B1, $D3
color:
	.byte	$0D, $07, $0D, $0C, $08, $03, $07, $0E, $0E, $02, $02, $02, $02, $00, $03, $03
	.byte	$0E, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $0F

.segment	"CODE"

.proc	_drawmap: near

	; zeropage temporary variables
	_x = _idx8
	_y = _jdx8
	_xCursor = _byte1
	_yCursor = _byte2

	_temp_color = _byte2
	_rowOOB = _byte3

	_visibilityMask = _byte4
	_doorSpriteCounter = _byte5
	_doorIndex = _idx8
	_doors_x = _doors
	_doors_y = _doors+8

	; init stuff
	lda     CURS_X
	sta     _xCursor
	lda     CURS_Y
	sta     _yCursor
	
	ldx		#$01
	ldy		#$01
	jsr		goto

	lda     #$00
	sta     _y

	sei							; avoid weird behavior from irq

	; calculate main pointer
	; ptr = _mapBuffer + (max(_cameray, 0) * _mapWidth)
	lda		_cameray
	bpl		:+
	lda		#$00
	:
	sta		_byte3				; the pointer gets corrupted if the camera y is under 0, so we clamp it

	lda		_mapWidth
	ldx		_byte3
	jsr		mul8x8				; multiplication to allow any width
	clc
	adc	 	#<(_mapBuffer)
	sta    	_ptr
	txa
	adc     #>(_mapBuffer)
	sta     _ptr+1

yloop:
	lda     _y
	cmp     #HEIGHT
	bcc     :+
	jmp		yloop_done
	:

	; check if row is out of bounds
	lda     _cameray
	clc
	adc     _y				; abs_y = cameray + y (signed)
	bmi     row_oob			; abs_y < 0
	cmp     _mapHeight		; abs_y >= mapHeight
	bcs     row_oob
	lda     #$00
	jmp     row_bounds_done
row_oob:
	lda     #$01
row_bounds_done:
	sta     _rowOOB
	
	lda     #WIDTH
	sta     _x

	lda     #$00
	sta     tmp1
xloop:
	; if row out of bounds
	lda		_rowOOB
	bne		use_border

	; check if column is out of bounds
	lda     _camerax
	clc
	adc     tmp1			; abs_x = camerax + x (signed)
	bmi     use_border		; abs_x < 0
	cmp     _mapWidth		; abs_y >= mapWidth
	bcs     use_border
	tay                     ; we use abs_x as the index
	lda     (_ptr),y
	jmp     draw_tile
use_border:					; out of bounds
	lda     _mapBuffer		; take the first tile of the map

draw_tile:
	tax
    lda     color,x
    sta     _temp_color
    lda     topleft_chr,x
    ldy     CURS_X
    sta     (SCREEN_PTR),y
	lda		_temp_color
	sta     (CRAM_PTR),y

	iny
    lda     topright_chr,x 		; load top right
    sta     (SCREEN_PTR),y
	lda		_temp_color
	sta     (CRAM_PTR),y

	; next line
    tya
	clc
	adc		#XSIZE
	tay

    lda     botright_chr,x 		; load bottom right
    sta     (SCREEN_PTR),y
	lda		_temp_color
	sta     (CRAM_PTR),y
	
	dey
    lda     botleft_chr,x  		; load bottom left
	sta     (SCREEN_PTR),y
	lda		_temp_color
	sta     (CRAM_PTR),y

	inc     CURS_X
	inc     CURS_X
	
	inc		tmp1
	dec		_x
	bne     xloop
xloop_done:
	lda     #$01
	sta     CURS_X
	inc     _y

	lda     _rowOOB
	bne     :+
	lda     _ptr			; advance pointer when no longer out of bounds
	clc
	adc     _mapWidth
	sta     _ptr
	bcc     :+
	inc     _ptr+1
	:

	; this might be faster than a goto????
	lda		#XSIZE*2 ;80
	clc
	adc		SCREEN_PTR
	sta		SCREEN_PTR
	bcc		:+
	inc		SCREEN_PTR+1
	:

	lda		#XSIZE*2 ;80
	clc
	adc		CRAM_PTR 
	sta		CRAM_PTR 
	bcc		:+
	inc		CRAM_PTR+1
	:

	jmp     yloop
	
yloop_done:

	; i will likely repurpose all this code for npcs in the future

; 	lda		#$00
; 	sta		_visibilityMask
; 	sta		_doorSpriteCounter
; 	sta		_doorIndex
; door_check_loop:
; 	lda     _doorIndex
; 	cmp     #$08
; 	bne		:+
; 	jmp		door_loop_done
; 	:
; 
; 	tay
; 	lda		_doors_x,y
; 	beq		skip_door			; skip if doors.x[_doorIndex] == 0
; 	lda		_doors_y,y
; 	beq		skip_door			; skip if doors.y[_doorIndex] == 0
; 
; 	lda		_doorSpriteCounter
; 	cmp		#$02
; 	bcs		door_loop_done		; end if no more sprites can be allocated
; 	
; 	lda		_cameray
; 	clc
; 	adc		#HEIGHT
; 	sta		tmp1
; 	lda		_doors_y,y
; 	cmp		tmp1
; 	bcs		skip_door
; 	cmp		_cameray
; 	bcc		skip_door
; 
; 	lda		_camerax
; 	clc
; 	adc		#WIDTH
; 	sta		tmp1
; 	lda		_doors_x,y
; 	cmp		tmp1
; 	bcs		skip_door
; 	cmp		_camerax
; 	bcc		skip_door
; 
; 	; set sprite x
; 	lda     _doorSpriteCounter
;     asl     a
; 	tax
; 
; 	lda		_doors_x,y
; 	sec
; 	sbc		_camerax
; 	asl		a
; 	asl		a
; 	asl		a
; 	asl		a
; 	clc
; 	adc		#X_OFFSET+8
; 	sta		$D00C,x
; 
; 	; set sprite y
; 	lda		_doors_y,y
; 	sec
; 	sbc		_cameray
; 	asl		a
; 	asl		a
; 	asl		a
; 	asl		a
; 	clc
; 	adc		#Y_OFFSET+8
; 	sta		$D00D,x
; 
; 	; set temp visibility
; 	lda		#%01000000
; 	ldy		_doorSpriteCounter
; 	beq     :+
; 	asl     a					; %10000000 for sprite 7
; 	:
; 	ora     _visibilityMask
; 	sta     _visibilityMask
; 
; 	inc		_doorSpriteCounter
; skip_door:
; 	inc		_doorIndex
; 	jmp		door_check_loop
; 	
; door_loop_done:
; 	lda		$D015
; 	and		#%00111111
; 	ora		_visibilityMask
; 	sta		$D015

end:
	cli							; restore interrupt
	ldx		_yCursor
	ldy		_xCursor
	jmp		goto

.endproc
