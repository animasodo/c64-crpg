
	.autoimport	on
	.importzp	irqbyte0
	.export		init_irq
	.include    "c64.inc"
	.include    "definitions.inc"

.segment	"CODE"

.proc	init_irq: near

	sei

	lda		#$7F
    sta		CIA1_ICR			; kill timer interrupt
	lda		CIA1_ICR			; clear flags or something idk

	lda		#$FF
    sta		VIC_IRR				; clear interrupts by writing 1 to all bits ($D019)

	lda     #$00
	sta     frameCount
	sta     VIC_HLINE			; set interrupt scanline to 0 ($D012)
	; if we want to do a line after 255, we have to write to bit 7 of $D011

	lda     VIC_IMR
	ora     #$01
	sta     VIC_IMR				; enable raster interrupt from VIC ($D01A)

	lda     #<(irq)
	sta		IRQVec
	lda     #>(irq)
	sta		IRQVec+1			; set vector to irq routine

	cli
	rts

.endproc

; irq routine

.segment	"CODE"

.proc	irq: near

	input_temp = irqbyte0

	inc     frameCount
	lda     frameCount
	cmp     #FPS
	bne     :+
	lda     #$00
	sta     frameCount
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
	sta		playerInput		; finally sets the playerInput variable

	dey
	sty		CIA1_DDRA			; restore keyboard

	; player input layout
	; xxxF-RLDU
	; F = fire
	; RLDU = right left down up

	lda		#$01
    sta     VIC_IRR				; "acknowledge" interrupt to exit

	jmp		$EA31				; jump to kernel irq routine
	; EA81 was the WRONG kernal pointer, dummy

.endproc
