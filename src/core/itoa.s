;
; taken from cc65's source code directly, and modified
;

        .autoimport     on
        .export         itoa, utoa, utoa_8, utoa_16, itoa_16, setup_itoa
        .import         __hextab
        .importzp       c_sp, sreg, ptr2, ptr3, tmp1

.rodata
specval:
        .byte   '-', '3', '2', '7', '6', '8', 0
.code

;
; itoa
;

itoa:
; We must handle $8000 in a special way, since it is the only negative
; number that has no positive 16-bit counterpart

        ldy     tmp1            ; get radix
        cpy     #10
        bne     utoa
        cmp     #$00
        bne     L2
        cpx     #$80
        bne     L2

        ldy     #6
L1:     lda     specval,y       ; copy -32768
        sta     (ptr2),y
        dey
        bpl     L1
        jmp     L10

; Check if the value is negative. If so, write a - sign and negate the
; number.

L2:     lda     sreg+1          ; get high byte
        bpl     utoa
        lda     #'-'
        ldy     #0
        sta     (ptr2),y        ; store sign
        inc     ptr2
        bne     L3
        inc     ptr2+1

L3:     lda     sreg
        eor     #$FF
        clc
        adc     #$01
        sta     sreg
        lda     sreg+1
        eor     #$FF
        adc     #$00
        sta     sreg+1

; Convert to string by dividing and push the result onto the stack

utoa:   lda     #$00
        pha                     ; sentinel

; Divide sreg/tmp1 -> sreg, remainder in a

L5:     ldy     #16             ; 16 bit
        lda     #0              ; remainder
L6:     asl     sreg
        rol     sreg+1
        rol     a
        cmp     tmp1
        bcc     L7
        sbc     tmp1
        inc     sreg
L7:     dey
        bne     L6

        tay                     ; get remainder into y
        lda     __hextab,y      ; get hex character
        pha                     ; save char value on stack

        lda     sreg
        ora     sreg+1
        bne     L5

; Get the characters from the stack into the string

        ldy     #0
L9:     pla
        sta     (ptr2),y
        beq     L10             ; jump if sentinel
        iny
        bne     L9              ; jump always

; Done! Return the target string

L10:    lda     ptr3
        ldx     ptr3+1
        rts

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

	lda		#<(itoa_buffer)
	ldx		#>(itoa_buffer)
	sta		ptr2
	stx		ptr2+1			; always the same buffer
	rts

itoa_16:
	clc
	ldy		#<(itoa_buffer)
	sty		ptr3
	ldy		#>(itoa_buffer)
	sty		ptr3+1			; to return the pointer, temporary stuff really

	jsr		setup_itoa

	jmp		itoa			; skip 3 bytes to avoid the popping, we're not using the stack

utoa_8:
	sec
	jmp		utoa_16+1
utoa_16:
	clc
	ldy		#<(itoa_buffer)
	sty		ptr3
	ldy		#>(itoa_buffer)
	sty		ptr3+1			; to return the pointer, temporary stuff really

	jsr		setup_itoa

	jmp		utoa