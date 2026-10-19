; ---------------------------------------------------------------
; load_map_compressed
;   loads and decompresses a map file from disk into the map
;   buffer based on an ID.
;
; in:  A = map id
; ---------------------------------------------------------------

	.autoimport	on
	.importzp	idx16, byte0, byte1, byte2, byte3, uint0, ptr, arg0, arg1, tmp1, byte_in_sector, script_ptr, ptr3
	.export		load_map_compressed
	.include	"c64.inc"
	.include	"cbm_kernal.inc"
    .include	"definitions.inc"
    .include	"macros.inc"

	; header/entity codes
	M = $4D
	P = $50
	WARP = $57
	SCRIPT = $53

.segment	"CODE"

load_map_compressed:
    ; zeropage temporary variables
    id = byte0
    compressed_length = uint0
	compressed_index = idx16
	tile = byte1
	length = byte2

	warp_index = byte1

	script_index = byte2
	multiplied_script_count = byte3
	
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
:	sta		warps,y
	iny
	cpy		#8*5
	bne		:-

	; clear scripts
	ldy		#$00
:	sta		script_blob,y
	iny
	cpy		#32+1
	bne		:-

	sta		warp_index
	sta		script_index

	lda		#<(script_data)
	sta		script_ptr
	lda		#>(script_data)
	sta		script_ptr+1

entity_loop:
	jsr		get_byte

	cmp		#WARP
	bne		:+
	ldy		warp_index
	jsr		get_byte
	sta		warp_x,y
	jsr		get_byte
	sta		warp_y,y
	jsr		get_byte
	sta		warp_script,y
	inc		warp_index
	:

	cmp		#SCRIPT
	bne		entity_loop

	; copy the index and add table
	jsr		get_byte
	sta		script_count
	asl		a
	sta		multiplied_script_count
script_offset_loop:
	; we add the offsets and the data pointer so we get a regular pointer table for when we want to run scripts
	jsr		get_byte
	clc
	adc		#<(script_data)
	sta		ptr3
	php
	jsr		get_byte
	plp
	adc		#>(script_data)

	ldy		script_index
	sta		script_ptr_table+1,y
	lda		ptr3
	sta		script_ptr_table,y
	inc		script_index
	inc		script_index
	lda		script_index

	cmp		multiplied_script_count
	bne		script_offset_loop
script_data_loop: ; the actual scripts
	jsr		get_byte
	bcs		done
	ldy		#$00
	sta		(script_ptr),y
	jsr		inc_ptr
	jmp		script_data_loop

done:
	jmp     close_ts
