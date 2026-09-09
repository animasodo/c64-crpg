; ---------------------------------------------------------------
; retrieve_script
;   retrieves a script from the script blob
;
; in:  A = script index
;
; out: script_ptr = pointer to script
; ---------------------------------------------------------------

    .autoimport on
    .importzp   script_ptr
	.export		retrieve_script

.segment	"CODE"

.proc	retrieve_script: near

	asl     a
    tax
    lda     script_ptr_table,x          ; low byte
    sta     script_ptr
    lda     script_ptr_table+1,x        ; high byte
    sta     script_ptr+1
    rts

.endproc
