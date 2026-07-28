
	.importzp	c_sp
	.importzp	_idx8, _idx16, _byte0, _byte1, _byte2, _byte3, _uint0, _ptr, arg0, arg1, tmp1, ptr1, ptr2
	.import		_mapBuffer, _cbm_k_clrch, _cbm_k_chkin, _cbm_k_basin, _cbm_open, _cbm_close, _mapHeight, _mapWidth, _mapId, _warps, _doors, _waitvsync, _formatwrite, _cclearxy
	.import		_disk_error, _map_error, pusha, pushax, draw_solid_box, goto, _isprint, _printchar, _cgetc, _bufferPrompt, cursor
	.export		_load_map_compressed, _delayFrames, _get_filename, _message, _readString
	.include	"c64.inc"

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

	lda     _disk_error
	ldx     _disk_error+1
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
    lda     _map_error
	ldx     _map_error+1
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
	and		#$1F
	sta		_tile
	tya
	lsr		a
	lsr		a
	lsr		a
	lsr		a
	lsr		a
	tay
	iny
	cpy		#$08
	bne		:+						; if 3 most significant bits are 111, grab actual length from next byte
	jsr		_cbm_k_basin
	tay
	inc		_compressed_index
	bne		:+
	inc		_compressed_index+1
	:
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

	; clear warps
	ldy		#$00
l0:	sta		_warps,y
	iny
	cpy		#8*5
	bne		l0

	; clear doors
	ldy		#$00
l1:	sta		_doors,y
	iny
	cpy		#8*2
	bne		l1

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
    lda		ptr_hi,y
    tax
    lda		ptr_lo,y
    rts

.endproc

; ---------------------------------------------------------------
; void message(const char *message)
; ---------------------------------------------------------------

.segment	"CODE"

.proc	_message: near

	sta		_ptr
	stx		_ptr+1
	ldy     #$01
	sty		CHARCOLOR

	ldx		#$14
	lda		#$1A
	sta		arg0
	lda		#$04
	sta		arg1
	lda		#' '
	jsr		draw_solid_box

	ldy     #$01
	ldx     #$14
	jsr     goto
	lda		_ptr
	ldx		_ptr+1
	jmp     _formatwrite

.endproc

; ---------------------------------------------------------------
; void __near__ readString (char size)
; ---------------------------------------------------------------

.segment	"CODE"

.proc	_readString: near

	char = _byte0
	size = _byte3

	; idx8 = 0;
	sta		size
	lda     #$00
	sta     _idx8

	; set up pointer
	lda     #<(_bufferPrompt)
	ldx     #>(_bufferPrompt)
	sta		_ptr
	stx		_ptr+1

	; if (size > 1)
	lda		size
	cmp		#$02
	bcs		:+
	rts
	:

	; cursor(1);
	lda     #$01
	sta		cursor

	; for (bufferPrompt[idx8] = '\0'; idx8 < size; )
	ldy		_idx8
	lda		#$00
	sta		(_ptr),y
for_loop:
	jsr     _cgetc
	sta     char

	; if(idx8)
	lda		_idx8
	beq		skip_index
	lda		char

	; if(byte0 == ENTER)
	cmp     #$0D		; ENTER
	bne		skip_enter

	lda		#$00
	jmp		end
skip_enter:

	; if(byte0 == '\b')
	cmp     #$14		; BACKSPACE
	bne		skip_back

	; bufferPrompt[--idx8] = '\0';
	dec		_idx8
	ldy		_idx8
	lda		#$00
	sta		(_ptr),y

	lda		CURS_Y
	sta		_byte2
	lda		CURS_X
	sta		_byte1

	; byte2 = byte1? byte2: byte2 - 1;
	lda		_byte1
	bne		:+
	dec		_byte2
	:

	; byte1 = byte1? byte1 - 1: (SCREEN_WIDTH - 1);
	lda		_byte1
	bne		:+
	lda		#XSIZE-1
	sta		_byte1
	jmp		end_byte
	:
	dec		_byte1
end_byte:

	ldx		_byte2
	ldy		_byte1
	jsr		goto

	lda		#' '
	jsr		_printchar

	ldx		_byte2
	ldy		_byte1
	jsr		goto

skip_back:
skip_index:

	; if ((char)isprint(byte0) && idx8 < (size - 1))
	lda		char
	jsr		_isprint
	beq		skip_printable

	ldy		size
	dey
	sty		tmp1
	lda		_idx8
	cmp		tmp1
	bcs		skip_printable
	; printchar(byte0);
	lda		char
	jsr		_printchar
	; bufferPrompt[idx8] = byte0;
	ldy		_idx8
	lda		char
	sta		(_ptr),y
	; bufferPrompt[++idx8] = '\0';
	inc		_idx8
	ldy		_idx8
	lda		#$00
	sta		(_ptr),y

skip_printable:
	jmp		for_loop
end:
	rts

.endproc
