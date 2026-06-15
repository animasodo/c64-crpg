
    .importzp	c_sp
	.importzp	_idx8, _idx16, _byte0, _byte1, _byte2, _uint0, _ptr
	.import		_mapBuffer, _cbm_k_clrch, _cbm_k_chkin, _cbm_k_basin, _cbm_open, _cbm_close, _mapHeight, _mapWidth, _mapId, _warps, _doors, _waitvsync, _simplewrite, _gotoy, _cclearxy
    .import     _diskErrorMessage, _mapErrorMessage, pusha, pushax
	.export		_load_map_compressed, _delayFrames, _get_filename, _message
	.include    "c64.inc"

; ---------------------------------------------------------------
; void load_map_compressed(char id)
; ---------------------------------------------------------------

	LFN = $02
	FLOPPY = $08

	; header/entity codes
	M = $4D
	P = $50
	W = $57
	D = $44
	E = $45 ; eof

.segment	"CODE"

.proc	_load_map_compressed: near

    ; zeropage temporary variables
    _id = _byte0
    _compressed_length = _uint0
	_compressed_index = _idx16
	_tile = _byte1
	_length = _byte2

	_warp_index = _byte1
	_door_index = _byte2
	
    sta     _id
	lda     #LFN
	jsr     pusha
	lda     #FLOPPY
	jsr     pusha
	lda     #$02
	jsr     pusha
	lda		_id
	jsr     _get_filename
	jsr     _cbm_open
	bcc     disk_open

	lda     _diskErrorMessage
	ldx     _diskErrorMessage+1
	jsr     pushax
	ldy     #$02
    jsr     _message
	jmp     done
    
disk_open:
	lda     #LFN
	jsr     _cbm_k_chkin			; set LFN 2 as active input channel

	jsr     _cbm_k_basin
	cmp     #M
    bne     map_header_unsuccessful
    jsr     _cbm_k_basin
	cmp     #P
    bne     map_header_unsuccessful
    jmp     map_header_successful

map_header_unsuccessful:
    lda     _mapErrorMessage
	ldx     _mapErrorMessage+1
	jsr     pushax
	ldy     #$02
    jsr     _message
    jmp     done

map_header_successful:
    lda     _id
	sta     _mapId
	jsr     _cbm_k_basin
	sta     _mapWidth
	jsr     _cbm_k_basin
	sta     _mapHeight
	jsr     _cbm_k_basin
	sta     _compressed_length
	jsr     _cbm_k_basin
	sta     _compressed_length+1	; get compressed length

	lda     #$00
	sta     _compressed_index
	sta     _compressed_index+1

	lda		#<(_mapBuffer)
	ldx		#>(_mapBuffer)
	sta     _ptr
	stx     _ptr+1

while_loop:
	lda		_compressed_index+1
    cmp     _compressed_length+1
	bcc		:+
	bne		done_while
	lda		_compressed_index
	cmp		_compressed_length
	bcs		done_while
	:
	jsr		_cbm_k_basin
	tay
	and		#$0F
	sta		_tile
	tya
	lsr		a
	lsr		a
	lsr		a
	lsr		a
	tay
	iny
	sty		_length
	ldy		#$00
	lda		_tile

write_loop:
	cpy		_length
	beq		done_write
	sta		(_ptr),y
	iny
	jmp		write_loop

done_write:
	lda		_length
	clc
	adc		_ptr
	sta		_ptr
	bcc		:+
	inc		_ptr+1
	:
	inc		_compressed_index
	bne		:+
	inc		_compressed_index+1
	:
	jmp		while_loop

done_while:
	lda		#$00
	sta		_warp_index
	sta		_door_index

while_not_eof:
	jsr		_cbm_k_basin
	cmp		#E
	beq		done

	cmp		#W
	bne		:+
	ldy		_warp_index
	jsr		_cbm_k_basin
	sta		_warps,y
	jsr		_cbm_k_basin
	sta		_warps+8,y
	jsr		_cbm_k_basin
	sta		_warps+16,y
	jsr		_cbm_k_basin
	sta		_warps+24,y
	jsr		_cbm_k_basin
	sta		_warps+32,y
	inc		_warp_index
	:

	cmp		#D
	bne		:+
	ldy		_door_index
	jsr		_cbm_k_basin
	sta		_doors,y
	jsr		_cbm_k_basin
	sta		_doors+8,y
	inc		_door_index
	:

	jmp		while_not_eof

done:
	jsr		_cbm_k_clrch
	lda		#LFN
	jmp		_cbm_close

.endproc

; ---------------------------------------------------------------
; void delayFrames(char count)
; ---------------------------------------------------------------

.segment	"CODE"

.proc	_delayFrames: near

	tay
loop:
	beq		exit_loop
	jsr		_waitvsync
	dey
	jmp		loop
exit_loop:
	rts

.endproc

; ---------------------------------------------------------------
; char *get_filename(char id);
; ---------------------------------------------------------------

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

; ---------------------------------------------------------------
; void message(const char *message)
; ---------------------------------------------------------------

.segment	"CODE"

.proc	_message: near

.segment	"CODE"

	sta		_ptr
	stx		_ptr+1
	lda     #$01
	sta		CHARCOLOR
	jsr     pusha
	lda     #$14
	jsr     pusha
	lda     #$1A
	jsr     _cclearxy
	lda     #$01
	jsr     pusha
	lda     #$15
	jsr     pusha
	lda     #$1A
	jsr     _cclearxy
	lda     #$01
	jsr     pusha
	lda     #$16
	jsr     pusha
	lda     #$1A
	jsr     _cclearxy
	lda     #$01
	sta		CURS_X
	lda     #$14
	jsr     _gotoy
	lda		_ptr
	ldx		_ptr+1
	jmp     _simplewrite

.endproc