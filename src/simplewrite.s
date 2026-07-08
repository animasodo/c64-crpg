;
; writes string to the screen in an extremely basic way
; void simplewritexy(char x, char y, const char *in);
; void simplewrite(const char *in);
;
; address is loaded into A(low) and X(high) when the function is called
;
	.importzp	tmp1, tmp2, ptr1
	.import		newline, putchar, gotoxy
	.export		_simplewrite, _simplewritexy
	.include	"c64.inc"

.segment "CODE"

_simplewritexy:
	pha
	txa
	pha
	jsr		gotoxy
	pla
	tax
	pla                     ; i don't have phx and plx instructions :(
        
_simplewrite:
	sta     ptr1
	stx     ptr1+1
	ldy     #$00
	sty     tmp2			; set pointer

	lda     CURS_X
	sta     tmp1			; store initial position
loop:   
	ldy     tmp2
	lda     (ptr1),y
	beq     done			; null
	cmp     #$0D			; new line
	bne     notnl
	jsr     newline
	lda     tmp1
	sta     CURS_X
	inc     tmp2
	jmp     loop
color:
	inc     tmp2
	ldy     tmp2
	lda     (ptr1),y
	sta     CHARCOLOR
	inc     tmp2
	jmp     loop
string:
	; save current pointer and temp variables
	lda		tmp1
	pha
	lda		ptr1
	pha
	lda		ptr1+1
	pha

	; get the two bytes, save one byte in tmp1 and then come back to get it in the x register
	inc	 	tmp2
	ldy		tmp2
	lda		(ptr1),y
	sta		tmp1
	inc		tmp2
	ldy		tmp2
	lda		tmp2
	pha
	lda		(ptr1),y
	tax
	lda		tmp1

	jsr		_simplewrite

	; restore the pointer and temp variables
	pla
	sta		tmp2
	pla
	sta		ptr1+1
	pla
	sta		ptr1
	pla
	sta		tmp1
	inc		tmp2			; advance one last time

	jmp     loop
notnl:
	cmp     #$3E			; if '>' then next byte is color
	beq		color
	cmp     #'$'			; if '$' then next two bytes are pointer to string
	beq		string
	cmp     #$80
	bcc     lw
	and     #$7F
	jmp     :+
lw:	and     #$3F
:	jsr     putchar
	inc     CURS_X
	inc     tmp2
	jmp     loop
done:
	rts
