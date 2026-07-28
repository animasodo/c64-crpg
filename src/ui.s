
	.importzp	tmp1, tmp2, tmp3, tmp4, arg0, arg1, arg2, sreg, ptr2, ptr3, _byte0, _byte7
	.import		advance_screen_ptr, setchar, popa, _itoa, _utoa, _itoa_buffer, _formatwrite, _print
	.import		_playerName, _playerHealth, _playerStamina, _playerPower, _playerExp, _gold, _dirChar, _direction, _clrscr
	.import		health_str, stamina_str, power_str, exp_str, gold_str
	.export		_clear_viewport, _drawBox, _utoa_8, _utoa_16, _itoa_16, setup_itoa, _drawStats, goto, draw_solid_box, _drawMainUI, draw_box_border
	.include	"c64.inc"
	.include	"cbm_kernal.inc"

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
	sty		tmp2			; store the first x position
	jsr		goto

	ldx		arg1
box_row_loop:
	ldy		tmp2
box_char_loop:
	lda		tmp1
	sta		(SCREEN_PTR),y
	lda		arg2
	sta		(CRAM_PTR),y
	iny
	cpy		arg0
	bne		box_char_loop

	dex
	jsr		advance_screen_ptr

	cpx		#$00
	bne		box_row_loop
	rts

.endproc

; code for the border, will fix it up in a sec

writev:
	sta		tmp3
write_vertical_border:
	lda		#$5D
	jsr		setchar					; write
	jsr		advance_screen_ptr		; nl
	dec		tmp3
	bne		write_vertical_border
	rts

writeh:
	sta		tmp3
write_horizontal_border:
	lda		#$40
	jsr		setchar					; write
	inc		CURS_X					; advance
	dec		tmp3
	bne		write_horizontal_border
	rts

; ---------------------------------------------------------------
; draw_box_border: draw the border of a box
; x register = y
; y register = x
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
	jsr		setchar
	inc		CURS_X

	lda		#$0E
	sta		CHARCOLOR
	lda		arg0
	jsr		writeh

	lda		#$07
	sta		CHARCOLOR
	lda		#CORNER
	jsr		setchar
	jsr		advance_screen_ptr
	
	lda		#$0E
	sta		CHARCOLOR
	lda		arg1
	jsr		writev

	ldy		tmp1
	ldx		tmp2
	jsr		goto

	jsr		advance_screen_ptr
	lda		#$0E
	sta		CHARCOLOR
	lda		arg1
	jsr		writev

	lda		#$07
	sta		CHARCOLOR
	lda		#CORNER
	jsr		setchar
	inc		CURS_X

	lda		#$0E
	sta		CHARCOLOR
	lda		arg0
	jsr		writeh

	lda		#$07
	sta		CHARCOLOR
	lda		#CORNER
	jsr		setchar

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
	tay
	ldx		tmp1
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
	jsr		_formatwrite

	ldx		#5
	ldy		#30
	jsr		goto

	lda		#<(_playerStamina)
	ldx		#>(_playerStamina)
	jsr		_utoa_8
	jsr		_formatwrite

	ldx		#7
	ldy		#30
	jsr		goto

	lda		#<(_playerPower)
	ldx		#>(_playerPower)
	jsr		_utoa_8
	jsr		_formatwrite

	ldx		#9
	ldy		#30
	jsr		goto

	lda		#<(_playerExp)
	ldx		#>(_playerExp)
	jsr		_utoa_16
	jsr		_formatwrite

	ldx		#11
	ldy		#30
	jsr		goto

	lda		#<(_gold)
	ldx		#>(_gold)
	jsr		_utoa_16
	jsr		_formatwrite

	lda		_byte7
	sta		CHARCOLOR
	rts

.endproc

; ---------------------------------------------------------------
; void drawMainUI(void)
; ---------------------------------------------------------------

.segment	"CODE"

.proc	_drawMainUI: near

	lda		CHARCOLOR
	sta		_byte0

	jsr     _clrscr

	ldy		#0
	ldx		#0
	lda     #40
	sta		arg0
	lda     #25
	sta		arg1
	jsr     draw_box_border

	ldy		#27
	ldx		#0
	lda     #13
	sta		arg0
	lda     #25
	sta		arg1
	jsr     draw_box_border

	ldy		#0
	ldx		#19
	lda     #28
	sta		arg0
	lda     #6
	sta		arg1
	jsr     draw_box_border

	lda     #$07
	sta     CHARCOLOR

	ldy		#29
	ldx		#0
	jsr		goto
	lda     #<(_playerName)
	ldx     #>(_playerName)
	jsr     _print

	ldy		#29
	ldx		#2
	jsr		goto
	lda     #<(health_str)
	ldx     #>(health_str)
	jsr     _print

	ldy		#29
	ldx		#4
	jsr		goto
	lda     #<(stamina_str)
	ldx     #>(stamina_str)
	jsr     _print

	ldy		#29
	ldx		#6
	jsr		goto
	lda     #<(power_str)
	ldx     #>(power_str)
	jsr     _print

	ldy		#29
	ldx		#8
	jsr		goto
	lda     #<(exp_str)
	ldx     #>(exp_str)
	jsr     _print

	ldy		#29
	ldx		#10
	jsr		goto
	lda     #<(gold_str)
	ldx     #>(gold_str)
	jsr     _print

	jsr     _drawStats

	lda     #$02
	sta     $D825

	ldy     _direction
	lda		_dirChar,y
	sta     $C825

	lda     _byte0
	sta		CHARCOLOR
	rts

.endproc
