; ---------------------------------------------------------------
; message_wait
;   prints a "continue" icon and waits for a spacebar press from the user
; ---------------------------------------------------------------

	.autoimport	on
	.importzp	ptr, arg0, arg1, tmp1
	.export		message_wait
	.include	"c64.inc"
	.include	"definitions.inc"

.segment	"CODE"

.proc	message_wait: near

    lda     #$5C
    jsr     printchar
wait_for_input:
	jsr     GETIN
    cmp     #' '
    beq     pressed
    jmp     wait_for_input
pressed:
    rts

.endproc
