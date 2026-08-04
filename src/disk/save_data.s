; ---------------------------------------------------------------
; save_data (WIP, not functional right now)
;   writes a game save to a disk with a 'book of records' file
; ---------------------------------------------------------------

	.importzp	ptr1, ptr2
	.export		save_data
	.include	"c64.inc"
	.include	"cbm_kernal.inc"
	.include	"definitions.inc"
	.include	"macros.inc"

.segment	"RODATA"

test_data:
	.byte "test_data", 0

test_name:
	.byte "records,s,w"

.segment	"CODE"

.proc	save_data: near

    prepare_disk test_name, 11

	ldx		#LFN
	jsr		CHKOUT
	bcs		disk_ok

	lda     disk_error
	ldx     disk_error+1
    jsr     message
	rts

disk_ok:
	; source
	lda     #<test_data
    sta     ptr1
	lda     #>test_data
    sta     ptr1+1
    ; length
    lda     #<$0005
    sta     ptr2
    lda     #>$0005
    sta     ptr2+1

	jmp     save_seq

.endproc
