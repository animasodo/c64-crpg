; ---------------------------------------------------------------
; goto
;   wrapper for PLOT and UPDCRAMPTR
;
; in:  X = y position
;      Y = x position
; ---------------------------------------------------------------

	.export		goto
	.include    "cbm_kernal.inc"

.segment	"CODE"

.proc	goto: near

	clc
	jsr		PLOT
	jmp		UPDCRAMPTR

.endproc