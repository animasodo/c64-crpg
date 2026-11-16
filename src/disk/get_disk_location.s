; ---------------------------------------------------------------
; get_disk_location
;   retrieves the pointer to a map's location on disk
;
; in:  A = map id
;
; out: ptr2 = asset's size in bytes
;      next_track = asset's location on disk (track)
;      next_sector = asset's location on disk (sector)
; ---------------------------------------------------------------

    .importzp   ptr2
	.export		get_disk_location
    .include    "definitions.inc"

.segment	"CODE"

.proc	get_disk_location: near

    asl
    asl
    tax ; (ID << 2)

    lda     MANIFEST_AREA+3,x ; size (low)
    sta     ptr2
    lda     MANIFEST_AREA+4,x ; size (high)
    sta     ptr2+1
    lda     MANIFEST_AREA+1,x ; track
    pha
    lda     MANIFEST_AREA+2,x ; sector
    tax
    pla
    rts

.endproc

