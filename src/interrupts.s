
	.import		_frameCount, _tempStack, pushax, _set_irq
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

	inc     _frameCount
	lda     _frameCount
	cmp     #FPS
	bne     :+
	lda     #$00
	sta     _frameCount
    :
    inc     VIC_IRR				; "acknowledge" interrupt to exit
	lda     #IRQ_NOT_HANDLED
    rts

.endproc
