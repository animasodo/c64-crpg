
	.importzp	tmp1, tmp2, tmp3, tmp4, arg0, arg1, arg2, sreg, ptr2, ptr3, _byte7
	.import		newline, putchar, popa, _itoa, _utoa, _itoa_buffer, _simplewrite
	.import		_playerHealth, _playerStamina, _playerPower, _playerExp, _gold
	.export		_clear_viewport, _drawBox, _utoa_8, _utoa_16, _itoa_16, setup_itoa, _drawStats
	.include    "c64.inc"
	.include    "cbm_kernal.inc"

; ---------------------------------------------------------------
; void clear_viewport(void);
; ---------------------------------------------------------------

.segment	"CODE"

.proc	_clear_viewport: near

	lda		#$1B
	sta		arg0
	lda		#$12
	sta		arg1
	lda		#$00
	sta		arg2
	lda		#' '
	ldx		#$01
	ldy		#$01
	jmp		draw_solid_box

.endproc

; ---------------------------------------------------------------
; draw_solid_box: draw a box with a solid box with a custom character
; accumulator = character
; x register = y
; y register = x
; arg0 = length
; arg1 = height
; arg2 = color
; ---------------------------------------------------------------

.segment	"CODE"

.proc	draw_solid_box: near

	sta		tmp1			; store the character
	stx		tmp2			; store the first x position
	clc
	jsr		PLOT
	jsr		UPDCRAMPTR

	ldx		arg1
l0:
	ldy     tmp2
l1:
	lda		tmp1
    sta		(SCREEN_PTR),y
	lda		arg2
	sta		(CRAM_PTR),y
	iny
	cpy		arg0
	bne		l1

	dex
	; increase pointer
	lda		SCREEN_PTR
	clc
	adc		#XSIZE
	sta		SCREEN_PTR
	lda		SCREEN_PTR+1
	adc		#$00
	sta		SCREEN_PTR+1

	cpx		#$00
	bne		l0
	rts

.endproc

; code for the border, will fix it up in a sec

writev:
        sta     tmp3
loopv:  lda     #$5D
        jsr     putchar         ; write
        jsr     newline         ; nl
        dec     tmp3
        bne     loopv
        rts

writeh:
        sta     tmp3
looph:  lda     #$40
        jsr     putchar         ; write
        inc     CURS_X          ; advance
        dec     tmp3
        bne     looph
        rts

; ---------------------------------------------------------------
; draw_box_border: draw the border of a box
; x register = x
; y register = y
; arg0 = length
; arg1 = height
; ---------------------------------------------------------------

.segment	"CODE"

.proc	draw_box_border: near

	CORNER = $5C

	lda		CHARCOLOR
	sta		tmp4

	sty		tmp1
	stx		tmp2			; store x and y
	jsr		goto

	dec		arg0
	dec		arg0
	dec		arg1
	dec		arg1

	lda		#$07
	sta		CHARCOLOR
	lda		#CORNER
	jsr		putchar
	inc		CURS_X

	lda		#$0E
	sta		CHARCOLOR
	lda		arg0
	jsr		writeh

	lda		#$07
	sta		CHARCOLOR
	lda		#CORNER
	jsr		putchar
	jsr		newline
	
	lda		#$0E
	sta		CHARCOLOR
	lda		arg1
	jsr		writev

	ldy		tmp1
	ldx		tmp2
	jsr		goto

	jsr		newline
	lda		#$0E
	sta		CHARCOLOR
	lda		arg1
	jsr		writev

	lda		#$07
	sta		CHARCOLOR
	lda		#CORNER
	jsr		putchar
	inc		CURS_X

	lda		#$0E
	sta		CHARCOLOR
	lda		arg0
	jsr		writeh

	lda		#$07
	sta		CHARCOLOR
	lda		#CORNER
	jsr		putchar

	lda		tmp4
	sta		CHARCOLOR

	rts

.endproc

; ---------------------------------------------------------------
; void drawBox(char x, char y, char length, char height);
; wrapper function for where i'm still using C
; ---------------------------------------------------------------

.segment	"CODE"

.proc	_drawBox: near

	sta		arg1
	jsr		popa
	sta		arg0
	jsr		popa
	sta		tmp1
	jsr		popa
	tax
	ldy		tmp1
	jmp		draw_box_border

.endproc

; ---------------------------------------------------------------
; itoa wrapper, keep variable pointer in A and X
; ---------------------------------------------------------------

.segment	"CODE"

setup_itoa:
	ldy		#$00
	sta		ptr2
	stx		ptr2+1
	lda		(ptr2),y
	sta		sreg
	bcs		j0				; if carry set, set upper byte to 0, effectively making it 8 bits
	iny
	lda		(ptr2),y
	jmp		j1
j0:	lda		#$00
j1:	sta		sreg+1			; use pointer to get value and set sreg

	lda		#$0A
	sta		tmp1			; radix is always 10

	lda		#<(_itoa_buffer)
	ldx		#>(_itoa_buffer)
	sta		ptr2
	stx		ptr2+1			; always the same buffer
	rts

_itoa_16:
	clc
	ldy		#<(_itoa_buffer)
	sty		ptr3
	ldy		#>(_itoa_buffer)
	sty		ptr3+1			; to return the pointer, temporary stuff really

	jsr		setup_itoa

	jmp		_itoa+3			; skip 3 bytes to avoid the popping, we're not using the stack

_utoa_8:
	sec
	jmp		_utoa_16+1
_utoa_16:
	clc
	ldy		#<(_itoa_buffer)
	sty		ptr3
	ldy		#>(_itoa_buffer)
	sty		ptr3+1			; to return the pointer, temporary stuff really

	jsr		setup_itoa

	jmp		_utoa+3

; ---------------------------------------------------------------
; goto
; row in X, column in Y
; ---------------------------------------------------------------

.segment	"CODE"

.proc	goto: near

	clc
	jsr		PLOT
	jmp		UPDCRAMPTR

.endproc

; ---------------------------------------------------------------
; void drawStats(void);
; ---------------------------------------------------------------

.segment	"CODE"

.proc	_drawStats: near

	ldy		CHARCOLOR
	lda		#$01
	sta		CHARCOLOR
	sty		_byte7

	ldx		#3
	ldy		#30
	jsr		goto

	lda		#<(_playerHealth)
	ldx		#>(_playerHealth)
	jsr		_utoa_8
	jsr		_simplewrite

	ldx		#5
	ldy		#30
	jsr		goto

	lda		#<(_playerStamina)
	ldx		#>(_playerStamina)
	jsr		_utoa_8
	jsr		_simplewrite

	ldx		#7
	ldy		#30
	jsr		goto

	lda		#<(_playerPower)
	ldx		#>(_playerPower)
	jsr		_utoa_8
	jsr		_simplewrite

	ldx		#9
	ldy		#30
	jsr		goto

	lda		#<(_playerExp)
	ldx		#>(_playerExp)
	jsr		_utoa_16
	jsr		_simplewrite

	ldx		#11
	ldy		#30
	jsr		goto

	lda		#<(_gold)
	ldx		#>(_gold)
	jsr		_utoa_16
	jsr		_simplewrite

	lda		_byte7
	sta		CHARCOLOR
	rts

.endproc
