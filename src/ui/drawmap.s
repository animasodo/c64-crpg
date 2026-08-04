; ---------------------------------------------------------------
; drawmap
;   draws the map on screen
; ---------------------------------------------------------------

	.autoimport	on
	.importzp	tmp1, idx8, jdx8, byte0, byte1, byte2, byte3, byte4, byte5, byte6, byte7, ptr
	.export		drawmap
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

.proc	drawmap: near

	; zeropage temporary variables
	x_index = idx8
	y_index = jdx8
	xCursor = byte1
	yCursor = byte2

	temp_color = byte2
	row_OOB = byte3

	visibility_mask = byte4
	door_sprite_counter = byte5
	door_index = idx8

	; init stuff
	lda     CURS_X
	sta     xCursor
	lda     CURS_Y
	sta     yCursor
	
	ldx		#$01
	ldy		#$01
	jsr		goto

	lda     #$00
	sta     y_index

	sei							; avoid weird behavior from irq

	; calculate main pointer
	; ptr = _mapBuffer + (max(_cameray, 0) * _mapWidth)
	lda		cameray
	bpl		:+
	lda		#$00
	:
	sta		byte3				; the pointer gets corrupted if the camera y is under 0, so we clamp it

	lda		mapWidth
	ldx		byte3
	jsr		mul8x8				; multiplication to allow any width
	clc
	adc	 	#<(mapBuffer)
	sta    	ptr
	txa
	adc     #>(mapBuffer)
	sta     ptr+1

yloop:
	lda     y_index
	cmp     #HEIGHT
	bcc     :+
	jmp		yloop_done
	:

	; check if row is out of bounds
	lda     cameray
	clc
	adc     y_index				; abs_y = cameray + y (signed)
	bmi     row_oob			; abs_y < 0
	cmp     mapHeight		; abs_y >= mapHeight
	bcs     row_oob
	lda     #$00
	jmp     row_bounds_done
row_oob:
	lda     #$01
row_bounds_done:
	sta     row_OOB
	
	lda     #WIDTH
	sta     x_index

	lda     #$00
	sta     tmp1
xloop:
	; if row out of bounds
	lda		row_OOB
	bne		use_border

	; check if column is out of bounds
	lda     camerax
	clc
	adc     tmp1			; abs_x = camerax + x (signed)
	bmi     use_border		; abs_x < 0
	cmp     mapWidth		; abs_y >= mapWidth
	bcs     use_border
	tay                     ; we use abs_x as the index
	lda     (ptr),y
	jmp     draw_tile
use_border:					; out of bounds
	lda     mapBuffer		; take the first tile of the map

draw_tile:
	tax
    lda     color,x
    sta     temp_color
    lda     topleft_chr,x
    ldy     CURS_X
    sta     (SCREEN_PTR),y
	lda		temp_color
	sta     (CRAM_PTR),y

	iny
    lda     topright_chr,x 		; load top right
    sta     (SCREEN_PTR),y
	lda		temp_color
	sta     (CRAM_PTR),y

	; next line
    tya
	clc
	adc		#XSIZE
	tay

    lda     botright_chr,x 		; load bottom right
    sta     (SCREEN_PTR),y
	lda		temp_color
	sta     (CRAM_PTR),y
	
	dey
    lda     botleft_chr,x  		; load bottom left
	sta     (SCREEN_PTR),y
	lda		temp_color
	sta     (CRAM_PTR),y

	inc     CURS_X
	inc     CURS_X
	
	inc		tmp1
	dec		x_index
	bne     xloop
xloop_done:
	lda     #$01
	sta     CURS_X
	inc     y_index

	lda     row_OOB
	bne     :+
	lda     ptr			; advance pointer when no longer out of bounds
	clc
	adc     mapWidth
	sta     ptr
	bcc     :+
	inc     ptr+1
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
; 	sta		visibility_mask
; 	sta		door_sprite_counter
; 	sta		door_index
; door_check_loop:
; 	lda     door_index
; 	cmp     #$08
; 	bne		:+
; 	jmp		door_loop_done
; 	:
; 
; 	tay
; 	lda		_doors_x,y
; 	beq		skip_door			; skip if doors.x[door_index] == 0
; 	lda		_doors_y,y
; 	beq		skip_door			; skip if doors.y[door_index] == 0
; 
; 	lda		door_sprite_counter
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
; 	lda     door_sprite_counter
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
; 	ldy		door_sprite_counter
; 	beq     :+
; 	asl     a					; %10000000 for sprite 7
; 	:
; 	ora     visibility_mask
; 	sta     visibility_mask
; 
; 	inc		door_sprite_counter
; skip_door:
; 	inc		door_index
; 	jmp		door_check_loop
; 	
; door_loop_done:
; 	lda		$D015
; 	and		#%00111111
; 	ora		visibility_mask
; 	sta		$D015

end:
	cli							; restore interrupt
	ldx		yCursor
	ldy		xCursor
	jmp		goto

.endproc
