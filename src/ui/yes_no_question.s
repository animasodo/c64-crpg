; ---------------------------------------------------------------
; yes_no_question
;   waits for a 'y' or 'n' key press from the user and returns the result in A
;
; out: A = user's choice, $00 = no, anything else = yes
; ---------------------------------------------------------------

	.autoimport	on
	.importzp	ptr, arg0, arg1, tmp1
	.export		yes_no_question
	.include	"c64.inc"
	.include	"definitions.inc"

.segment	"CODE"

.proc	yes_no_question: near

    lda     #<(y_n)
    ldx     #>(y_n)
    jsr     print
wait_for_input:
	jsr     GETIN
    cmp     #'y'
    beq     yes
    cmp     #'n'
    beq     no
    jmp     wait_for_input
no:
    lda     #$00
yes:
    cmp     #$00 ; restore zero status in only two bytes
    rts

.endproc

.segment    "RODATA"
y_n:
    .byte " (y/n)", 0
