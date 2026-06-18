;
; void drawmap(void);
; takes about two frames to update the map
;

	.importzp	c_sp
	.importzp	tmp1, _idx8, _jdx8, _byte0, _byte1, _byte2, _byte3, _byte4, _byte5, _byte6, _byte7, _ptr
	.import		_camerax, _cameray, _mapBuffer, _mapWidth, _gotoy, aslax4, newline, putchar, _doors, tosumula0, pushax, _waitvsync
	.export		_drawmap
	.include    "c64.inc"

	HEIGHT = $09
	WIDTH = $0D
	X_OFFSET = $18
	Y_OFFSET = $32

.segment "RODATA"

; graphics data
topleft_chr:
        .byte $E0, $E8, $E5, $E4, $E7, $E9, $E8, $E2, $E2, $E1
topright_chr:
        .byte $E0, $E8, $E5, $E4, $E7, $E9, $E8, $E3, $E3, $E1
botleft_chr:
        .byte $E0, $E8, $E6, $E4, $E7, $EA, $E8, $E2, $E3, $E1
botright_chr:
        .byte $E0, $E8, $E6, $E4, $E7, $EB, $E8, $E3, $E2, $E1
color:
        .byte $0D, $07, $0D, $0C, $08, $03, $07, $0E, $0E, $02

.segment	"CODE"

.proc	_drawmap: near

	; zeropage temporary variables
	_x = _idx8
	_y = _jdx8
	_oldColor = _byte0
	_xCursor = _byte1
	_yCursor = _byte2

	_rowSkip = _byte3

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
	
	lda     #$01
	sta     CURS_X
	jsr		_gotoy				; set initial cursor position
	lda		CHARCOLOR
	sta     _oldColor
	lda     #$00
	sta     _y

	sei							; avoid weird behavior from irq

	; calculate main pointer
	ldx     #$00
	lda		_mapWidth
	jsr		pushax
	lda		_cameray
	jsr		tosumula0			; multiplication to allow any width
	clc
	adc     _camerax
	bcc     :+
	inx
	:
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
	jmp		sprite_section
	:
	
	lda     #WIDTH
	sta     _x

	lda		#$00
	sta		tmp1
xloop:
	ldy     tmp1
	lda     (_ptr),y        	; get the tile
draw_tile:
	tax
    lda     color,x
    sta     CHARCOLOR
    lda     topleft_chr,x
    ldy     CURS_X
    sta     (SCREEN_PTR),y
	lda		CHARCOLOR
	sta     (CRAM_PTR),y

	iny
    lda     topright_chr,x 		; load top right
    sta     (SCREEN_PTR),y
	lda		CHARCOLOR
	sta     (CRAM_PTR),y

	; next line
    tya
	clc
	adc		#XSIZE
	tay

    lda     botright_chr,x 		; load bottom right
    sta     (SCREEN_PTR),y
	lda		CHARCOLOR
	sta     (CRAM_PTR),y
	
	dey
    lda     botleft_chr,x  		; load bottom left
	sta     (SCREEN_PTR),y
	lda		CHARCOLOR
	sta     (CRAM_PTR),y

	inc     CURS_X
	inc     CURS_X
	
	inc		tmp1
	dec     _x
	bne     xloop
xloop_done:
	lda     #$01
	sta     CURS_X
	inc     _y

	; go to the next row
	clc
	lda		_ptr
	adc		_mapWidth
	sta		_ptr
	bcc		:+
	inc		_ptr+1
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
	
sprite_section:
	lda		#$00
	sta		_visibilityMask
	sta		_doorSpriteCounter
	sta		_doorIndex
door_check_loop:
	lda     _doorIndex
	cmp     #$08
	bne		:+
	jmp		door_loop_done
	:

	tay
	lda		_doors_x,y
	beq		skip_door			; skip if doors.x[_doorIndex] == 0
	lda		_doors_y,y
	beq		skip_door			; skip if doors.y[_doorIndex] == 0

	lda		_doorSpriteCounter
	cmp		#$02
	bcs		door_loop_done		; end if no more sprites can be allocated
	
	lda		_cameray
	clc
	adc		#HEIGHT
	sta		tmp1
	lda		_doors_y,y
	cmp		tmp1
	bcs		skip_door
	cmp		_cameray
	bcc		skip_door

	lda		_camerax
	clc
	adc		#WIDTH
	sta		tmp1
	lda		_doors_x,y
	cmp		tmp1
	bcs		skip_door
	cmp		_camerax
	bcc		skip_door

	; set sprite x
	lda     _doorSpriteCounter
    asl     a
	tax

	lda		_doors_x,y
	sec
	sbc		_camerax
	asl		a
	asl		a
	asl		a
	asl		a
	clc
	adc		#X_OFFSET+8
	sta		$D00C,x

	; set sprite y
	lda		_doors_y,y
	sec
	sbc		_cameray
	asl		a
	asl		a
	asl		a
	asl		a
	clc
	adc		#Y_OFFSET+8
	sta		$D00D,x

	; set temp visibility
	lda		#%01000000
	ldy		_doorSpriteCounter
	beq     :+
	asl     a					; %10000000 for sprite 7
	:
	ora     _visibilityMask
	sta     _visibilityMask

	inc		_doorSpriteCounter
skip_door:
	inc		_doorIndex
	jmp		door_check_loop
	
door_loop_done:
	lda		$D015
	and		#%00111111
	ora		_visibilityMask
	sta		$D015

end:
	cli							; restore interrupt
	lda     _oldColor			; set color and cursor to old values
	sta		CHARCOLOR
	lda     _xCursor
	sta     CURS_X
	lda     _yCursor
	jmp		_gotoy

.endproc
