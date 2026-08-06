;
; taken from cc65's source code directly, and modified
;

        .autoimport     on
        .export         itoa, utoa, utoa_8, utoa_16, itoa_16, setup_itoa
        .importzp       sreg, ptr1

.segment	"RODATA"

	num_list:
		.byte '0', '1', '2', '3', '4', '5', '6', '7', '8', '9'

.segment	"CODE"

itoa:
; Check if the value is negative. If so, write a - sign and negate the
; number.
        lda     sreg+1          ; get high byte
        bpl     utoa
        lda     #'-'
        ldy     #0
        sta     (ptr1),y        ; store sign
        inc     ptr1
        bne     L3
        inc     ptr1+1

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

; Divide sreg/10 -> sreg, remainder in a

L5:     ldy     #16             ; 16 bit
        lda     #0              ; remainder
L6:     asl     sreg
        rol     sreg+1
        rol     a
        cmp     #10
        bcc     L7
        sbc     #10
        inc     sreg
L7:     dey
        bne     L6

        tay                     ; get remainder into y
        lda     num_list,y      ; get character
        pha                     ; save char value on stack

        lda     sreg
        ora     sreg+1
        bne     L5

; Get the characters from the stack into the string

        ldy     #0
L9:     pla
        sta     (ptr1),y
        beq     L10             ; jump if sentinel
        iny
        bne     L9              ; jump always

; Done! Return the target string

L10:    lda     #<(itoa_buffer)
        ldx     #>(itoa_buffer)
        rts

; ---------------------------------------------------------------
; itoa wrapper, keep variable pointer in A and X
; ---------------------------------------------------------------

.segment	"CODE"

setup_itoa:
	; get number in pointer
	ldy		#$00
	sta		ptr1
	stx		ptr1+1
	lda		(ptr1),y
	sta		sreg
	bcs		j0				; if carry set, set upper byte to 0, effectively making it 8 bits
	iny
	lda		(ptr1),y
	jmp		j1
j0:	lda		#$00
j1:	sta		sreg+1			; use pointer to get value and set sreg

	lda		#<(itoa_buffer)
	ldx		#>(itoa_buffer)
	sta		ptr1
	stx		ptr1+1			; always the same buffer
	rts

itoa_16:
	clc
	jsr		setup_itoa
	jmp		itoa			; skip 3 bytes to avoid the popping, we're not using the stack

utoa_8:
	sec
	jmp		sbyte
utoa_16:
	clc
sbyte:
	jsr		setup_itoa
	jmp		utoa