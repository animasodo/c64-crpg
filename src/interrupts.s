
	.importzp	irqbyte0, irqbyte1, irqbyte2, irqbyte3
	.import		_frameCount, _tempStack, pushax, _set_irq, _playerInput
	.export		_irq, _initIrq
	.include    "c64.inc"

    FPS = 50
	IRQ_NOT_HANDLED = $00

; ---------------------------------------------------------------
; void __near__ initIrq (void)
; ---------------------------------------------------------------

.segment	"CODE"

.proc	_initIrq: near

.segment	"CODE"

	sei
	lda     #$00
	sta     _frameCount
	sta     VIC_HLINE			; set interrupt scanline to 0
	lda     VIC_IMR
	ora     #$01
	sta     VIC_IMR				; enable raster interrupt from VIC
	lda     #<(_irq)
	ldx     #>(_irq)
	jsr     pushax
	lda     #<(_tempStack)
	ldx     #>(_tempStack)
	jsr     pushax
	ldx     #$00
	lda     #$40				; might need or not need a stack, depends on what i do with the irq routine, idk we'll see
	jsr     _set_irq
	cli
	rts

.endproc

; irq routine

.segment	"CODE"

.proc	_irq: near

	input_temp = irqbyte0

	inc     _frameCount
	lda     _frameCount
	cmp     #FPS
	bne     :+
	lda     #$00
	sta     _frameCount
    :

	; read input for quick actions, we can read the kernel byte for less critical things
	ldy		#$FF
	sty		CIA1_DDRA			; sets port A to send
	iny
	sty		CIA1_DDRB			; sets port B to receive
	sty		input_temp			; might as well clear this variable

	; read space
	lda		#%01111111			; testing column 7 of the matrix
    sta		CIA1_PRA
	lda		CIA1_PRB
	and		#%00010000			; masking row 4 (space)

	bne		:+
	lda		#%00010000
	ora		input_temp
	sta		input_temp
	:

	; read right and down (; and /)
	lda		#%10111111			; testing column 6 of the matrix
    sta		CIA1_PRA
	lda		CIA1_PRB
	and		#%00000100			; masking row 2 (right)

	bne		:+
	lda		#%00001000
	ora		input_temp
	sta		input_temp
	:

	lda		CIA1_PRB
	and		#%10000000			; masking row 7 (down)

	bne		:+
	lda		#%00000010
	ora		input_temp
	sta		input_temp
	:

	; read up and left (@ and :)
	lda		#%11011111			; testing column 5 of the matrix
    sta		CIA1_PRA
	lda		CIA1_PRB
	and		#%01000000			; masking row 6 (up)

	bne		:+
	lda		#%00000001
	ora		input_temp
	sta		input_temp
	:

	lda		CIA1_PRB
	and		#%00100000			; masking row 5 (left)

	bne		:+
	lda		#%00000100
	ora		input_temp
	sta		input_temp
	:

	; read the second joystick
	sty		CIA1_DDRA			; sets port A to receive temporarily

	lda		CIA1_PRA
	and		#%00011111
	eor		#%00011111
	ora		input_temp
	sta		_playerInput		; finally sets the playerInput variable

	dey
	sty		CIA1_DDRA			; restore keyboard

	; player input layout
	; xxxF-RLDU
	; F = fire
	; RLDU = right left down up

	lda		#$01
    sta     VIC_IRR				; "acknowledge" interrupt to exit
	lda     #IRQ_NOT_HANDLED
    rts

.endproc
