; ---------------------------------------------------------------
; find_door
;   scan the door list and return its number if one has been found
;   otherwise, return $FF
;
; in:  X = x coordinate to scan
;      Y = y coordinate to scan
;
; out: A = index of door if found, $FF if not
; ---------------------------------------------------------------
; 
; 	.autoimport	on
; 	.importzp	tmp1, tmp2
; 	.export		find_door
; 	.include    "c64.inc"
; 	.include    "definitions.inc"
; 
; .segment	"CODE"
; 
; .proc	find_door: near
; 	
; 	; i can probably repurpose this code for something like npcs
;     sty     tmp1
;     stx     tmp2
;     ldy     #$00
; loop:
;     lda     door_x,y
;     cmp     tmp2
;     bne     skip
;     lda     door_y,y
;     cmp     tmp1
;     bne     skip
; 
;     tya
;     rts
; skip:
;     iny
;     cpy     #$08
;     bne     loop
;     lda     #$FF
;     rts
; 
; .endproc