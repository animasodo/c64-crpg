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

    .importzp   ptr2, ptr3, next_track, next_sector
	.export		get_disk_location
    .include    "definitions.inc"

.segment	"CODE"

.proc	get_disk_location: near

    asl
    asl
    tax ; (ID << 2)

    lda     MANIFEST_AREA+1,x ; track
    sta     next_track
    lda     MANIFEST_AREA+2,x ; sector
    sta     next_sector
    lda     MANIFEST_AREA+3,x ; size (low)
    sta     ptr2
    lda     MANIFEST_AREA+4,x ; size (high)
    sta     ptr2+1
    rts

.endproc

