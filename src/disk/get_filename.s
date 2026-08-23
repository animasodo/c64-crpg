; ---------------------------------------------------------------
; get_filename
;   retrieves the pointer to a map's filename
;
; in:  Y = map id
;
; out: A, X = pointer to the map's filename, null terminated
; ---------------------------------------------------------------

	.export		get_filename

.include    "maps/filenames.s"

.segment	"CODE"

.proc	get_filename: near

    lda		ptr_hi,y
    tax
    lda		ptr_lo,y
    rts

.endproc

