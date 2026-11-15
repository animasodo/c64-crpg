
	.autoimport		on
	.importzp		ptr1, ptr2, ptr3, tmp1, tmp2
	.export			receive_byte
	.include		"c64.inc"
    .include		"cbm_kernal.inc"
    .include		"definitions.inc"
    .include        "manifest.inc"

DATA_OUT := $20 ; bit 5
CLK_OUT  := $10 ; bit 4
VIC_OUT  := $00 ; bits need to be on to keep VIC happy

.segment    "CODE"

receive_byte:
    ; wait till the byte is ready
:   bit     CIA2_PRA
	bvc     :- ; wait for CLK=0 (inverted read!)

    ; wait for the raster to be out of the unsafe zone so we can send the data
wait_raster:
	lda     VIC_HLINE
	cmp     #50
	bcc     wait_raster_end
	and 	#$07
	cmp 	#$02
	beq 	wait_raster
wait_raster_end:

	lda     #VIC_OUT ; CLK=0 DATA=0
	sta     CIA2_PRA ; we're ready, start sending!
	
    pha     ; 3 cycles
    pla     ; 4 cycles
	bit		$00 ; 3 cycles

	lda     CIA2_PRA ; get 2 bits into bits 6&7
	lsr 
	lsr     ; move down by 2 (bits 4&5)
	eor     CIA2_PRA ; get 2 more bits
	lsr 
	lsr     ; move everything down (bits 2-5)
	eor     CIA2_PRA; get 2 more bits
	lsr 
	lsr     ; move everything down (bits 0-5)
	eor     CIA2_PRA ; get last 2 bits, now 0-7 are populated

	ldy     #VIC_OUT | DATA_OUT ; CLK=0 DATA=1
	sty     CIA2_PRA ; not ready anymore

    rts
