;
; writes string to the screen. supports color highlighting, integers, strings and characters
; void simplewritexy(char x, char y, const char *in);
; void simplewrite(const char *in);
;
; address is loaded into A(low) and X(high) when the function is called
;
	.importzp	tmp1, tmp2, tmp3, tmp4, ptr1, ptr2, sreg
	.import		newline, putchar, gotoxy, pushax, _itoa, _utoa, _itoa_buffer, setup_itoa, _itoa_16
	.export		_simplewrite, _simplewritexy
	.include	"c64.inc"

.segment "CODE"

	unsigned = tmp1
	init_pos = tmp4

_simplewritexy:
	pha
	txa
	pha
	jsr		gotoxy
	pla
	tax
	pla						; i don't have phx and plx instructions :(
        
_simplewrite:
	sta     ptr1
	stx     ptr1+1
	ldy     #$00			; set pointer

	lda     CURS_X
	sta     init_pos		; store initial position
loop:
	lda		#$00
	sta		unsigned

	lda     (ptr1),y
	bne     :+
	jmp     done			; null
	; all the way over here because it's closer so we can do a direct branch
	cmp     #$01			; if $01 then next byte is color
	beq		color
:	cmp     #$05			; if $05 then next two bytes are pointer to character
	beq		char
	cmp     #$0D			; new line
	beq     :+
	jmp		notnl
:	jsr     newline
	lda     init_pos
	sta     CURS_X
	iny
	jmp     loop
color:
	; read byte and set CHARCOLOR
	iny
	lda     (ptr1),y
	sta     CHARCOLOR
	iny
	jmp     loop
char:
	iny
	lda     (ptr1),y
	sta		ptr2
	iny
	lda		(ptr1),y
	sta		ptr2+1
	sty		tmp3
	ldy		#$00
	lda		(ptr2),y
	ldx		#$00
	ldy		tmp3
	jmp		j0
byte:
	sec
int:
	iny
	lda     (ptr1),y
	sta		ptr2
	iny
	lda		(ptr1),y
	tax
	lda		ptr2
	sty		tmp3
	jsr		setup_itoa
	jsr		_itoa_16
	ldy		tmp3
	sec						; set carry to indicate that we want to print an integer
string:
	; save pointer and position
	lda		init_pos
	pha
	lda		ptr1
	pha
	lda		ptr1+1
	pha

	; get the two bytes, save one byte in tmp1 and then come back to get it in the x register
	bcs		p2				; if carry set then we are printing an integer, so we need to get the pointer from ptr2
	iny
	lda		(ptr1),y
	sta		tmp1
	iny
	tya
	pha						; save index
	lda		(ptr1),y
	tax
	lda		tmp1
	jmp		np

p2:	tya
	pha
	lda		ptr2
	ldx		ptr2+1
np:	jsr		_simplewrite

	; restore the index, pointer and position
	pla
	tay
	pla
	sta		ptr1+1
	pla
	sta		ptr1
	pla
	sta		init_pos
	iny						; advance one last time

	jmp     loop
notnl:
	cmp     #$02			; if $02 then next two bytes are pointer to string
	clc
	beq		string
	clc
	cmp     #$03			; if $03 then next two bytes are pointer to integer
	beq		int
	clc
	cmp     #$04			; if $04 then next two bytes are pointer to byte
	beq		byte
j0:	cmp     #$80
	bcc     lw
	and     #$7F
	jmp     :+
lw:	and     #$3F
:	sty	 	tmp2
	jsr     putchar+2		; +2 as a test to skip the ora
	ldy		tmp2
	inc     CURS_X
	iny
	jmp     loop
done:
	rts
