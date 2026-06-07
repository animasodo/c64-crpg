;
; char *get_filename(char id);
;

	.export		_get_filename

.include    "../build/maps/filenames.s"

.segment	"CODE"

.proc	_get_filename: near

    tay
    lda ptr_hi,y
    tax
    lda ptr_lo,y
    rts

.endproc
