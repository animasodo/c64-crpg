; ---------------------------------------------------------------
; delay_frames
;   waits for a number of frames
;
; in:  Y = number of frames to wait
; ---------------------------------------------------------------

	.export		delay_frames
	.import		_waitvsync

.segment	"CODE"

.proc	delay_frames: near

loop:
	beq		exit_loop
	jsr		_waitvsync
	dey
	jmp		loop
exit_loop:
	rts

.endproc
