;
; this was originally a function compiled by cc65, but it's been further optimized by hand
; it takes about three to four frames to update the map
;
; void drawMap(void){
;     char x, y;
;     char xViewport = 1, yViewport = 1;
;     char oldColor = textcolor(WHITE);
;     char xCursor = wherex(), yCursor = wherey();
;     for(y = 0; y < HEIGHT; y++){
;         unsigned int i = ((y + cameray) << 5) + camerax;
;         for(x = WIDTH; x != 0; x--){ // bit faster due to architecture
;			  gotoxy(xViewport, yViewport);
;             drawtile(mapBuffer[i++]);
;             xViewport += 2;
;         }
;         xViewport = 1;
;         yViewport += 2;
;     }
;     textcolor(oldColor);
;     gotoxy(xCursor, yCursor);
; }
;

	.importzp	c_sp
	.importzp	tmp1, _idx8, _jdx8, _byte0, _byte1, _byte2, _byte3, _byte4, _byte5, _ptr
	.import		_camerax, _cameray, _mapBuffer, _gotoy, aslax4, newline, putchar, _doors
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
	_yViewport = _byte0
	_oldColor = _byte1
	_xCursor = _byte2
	_yCursor = _byte3

	_visibilityMask = _byte4
	_doorSpriteCounter = _byte5
	_doorIndex = _idx8
	_doors_x = _doors
	_doors_y = _doors+8

	lda     CURS_X
	sta     _xCursor
	lda     CURS_Y
	sta     _yCursor
	
	lda     #$01
	sta     CURS_X
	sta     _yViewport
	lda		CHARCOLOR
	sta     _oldColor
	lda     #$00
	sta     _y					; init stuff
	sei							; avoid interruptions that do weird stuff
yloop:
	lda     _y
	cmp     #HEIGHT
	bcs     sprite_section

	ldx     #$00				; beginning of index calculation
	lda     _y
	clc
	adc     _cameray
	bcc     L000B
	inx
L000B:
	jsr     aslax4
	stx     tmp1
	asl     a
	rol     tmp1
	ldx     tmp1
	clc
	adc     _camerax
	bcc     L000C
	inx
L000C:
	clc
	adc	 	#<(_mapBuffer)
	sta    	_ptr
	txa
	adc     #>(_mapBuffer)
	sta     _ptr+1
	
	lda     #WIDTH
	sta     _x
xloop:
	lda     _yViewport
	jsr		_gotoy				; set the cursor position

	ldy     #$00
	lda     (_ptr),y        	; get the tile
	inc     _ptr
	bne     drawtile
	inc     _ptr+1
drawtile:
	; handmade tile drawing function (drawtile)
	tax                    		; move tile to x register
    lda     color,x        		; load color
    sta     CHARCOLOR      		; change color
    lda     topleft_chr,x  		; load top left
    jsr     putchar        		; output character
    inc     CURS_X         		; move cursor to right
    lda     topright_chr,x 		; load top right
    jsr     putchar        		; output character
    jsr     newline        		; move to next line
    lda     botright_chr,x 		; load bottom right
    jsr     putchar        		; output character
    dec     CURS_X         		; move cursor to left
    lda     botleft_chr,x  		; load bottom left
    jsr     putchar        		; output character

	inc     CURS_X
	inc     CURS_X
	
	dec     _x
	bne     xloop
L000F:
	lda     #$01
	sta     CURS_X
	inc     _yViewport
	inc     _yViewport
	inc     _y
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
