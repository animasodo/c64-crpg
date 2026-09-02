; ---------------------------------------------------------------
; load_map_compressed
;   loads and decompresses a map file from disk into the map
;   buffer based on an ID.
;
; in:  A = map id
; ---------------------------------------------------------------

	.autoimport	on
	.importzp	idx8, idx16, byte0, byte1, byte2, byte3, uint0, ptr, arg0, arg1, tmp1, ptr1, ptr2, byte_in_sector
	.export		load_map_compressed
	.include	"c64.inc"
	.include	"cbm_kernal.inc"
    .include	"definitions.inc"
    .include	"macros.inc"

	; header/entity codes
	M = $4D
	P = $50
	W = $57
	D = $44
	E = $45 ; eof

.segment	"CODE"

.proc	load_map_compressed: near

    ; zeropage temporary variables
    id = byte0
    compressed_length = uint0
	compressed_index = idx16
	tile = byte1
	length = byte2

	warp_index = byte1
	door_index = byte2
	
    sta     id
	jsr     get_disk_location
	jsr     open_ts

	jsr     get_byte
	cmp     #M
    bne     map_header_unsuccessful
    jsr     get_byte
	cmp     #P
    beq     map_header_successful

map_header_unsuccessful:
    lda     map_error
	ldx     map_error+1
    jsr     message
    jmp     done

map_header_successful:
    lda     id
	sta     mapId
	jsr     get_byte
	sta     mapWidth
	jsr     get_byte
	sta     mapHeight
	jsr     get_byte
	sta     compressed_length
	jsr     get_byte
	sta     compressed_length+1	; get compressed length

	lda     #$00
	sta     compressed_index
	sta     compressed_index+1

	lda		#<(mapBuffer)
	ldx		#>(mapBuffer)
	sta     ptr
	stx     ptr+1

while_loop:
	lda		compressed_index+1
    cmp     compressed_length+1
	bcc		:+
	bne		done_while
	lda		compressed_index
	cmp		compressed_length
	bcs		done_while
	:
	jsr		get_byte
	tay
	and		#$1F
	sta		tile
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
	jsr		get_byte
	tay
	inc		compressed_index
	bne		:+
	inc		compressed_index+1
	:
	sty		length
	ldy		#$00
	lda		tile

write_loop:
	cpy		length
	beq		done_write
	sta		(ptr),y
	iny
	jmp		write_loop

done_write:
	lda		length
	clc
	adc		ptr
	sta		ptr
	bcc		:+
	inc		ptr+1
	:
	inc		compressed_index
	bne		:+
	inc		compressed_index+1
	:
	jmp		while_loop

done_while:
	lda		#$00

	; clear warps
	ldy		#$00
l0:	sta		warps,y
	iny
	cpy		#8*5
	bne		l0

	; clear doors
; 	ldy		#$00
; l1:	sta		doors,y
; 	iny
; 	cpy		#8*2
; 	bne		l1

	sta		warp_index
	sta		door_index

while_not_eof:
	jsr		get_byte
	cmp		#E
	beq		done

	cmp		#W
	bne		:+
	ldy		warp_index
	jsr		get_byte
	sta		warp_id,y
	jsr		get_byte
	sta		warp_src_x,y
	jsr		get_byte
	sta		warp_src_y,y
	jsr		get_byte
	sta		warp_dst_x,y
	jsr		get_byte
	sta		warp_dst_y,y
	inc		warp_index
	:

	cmp		#'s'
	bne		:+
	jsr		get_byte
	sta		script_x
	jsr		get_byte
	sta		script_y
	ldy		#$00
	script_loop:
		jsr		get_byte
		sta		script,y
		beq		end_script
		iny
		jmp		script_loop
	end_script:
	:

	; cmp		#D
	; bne		:+
	; ldy		door_index
	; jsr		get_byte
	; sta		door_x,y
	; jsr		get_byte
	; sta		door_y,y
	; inc		door_index
	; :

	jmp		while_not_eof

done:
	jmp     close_ts

.endproc

