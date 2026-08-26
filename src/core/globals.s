
	.export		playerName
	.export		playerx
	.export		playery
	.export		camerax
	.export		cameray
	.export		direction
	.export		playerHealth
	.export		playerStamina
	.export		playerPower
	.export		playerExp
	.export		gold
	.export		species
	.export		keys
	.export		inventory, item_id, item_quantity
	.export		mapId
	.export		mapWidth
	.export		mapHeight
	.export		mapBuffer
	.export		warps, warp_id, warp_src_x, warp_src_y, warp_dst_x, warp_dst_y
	.export		doors, door_x, door_y
	.export		itoa_buffer
	.export		frameCount
	.export		playerInput
	.export		lastKey
	.export		buffer_prompt
	.export		game_save, end_game_save

.segment	"BSS"

	game_save:

		playerName:
			.res	10,$00
		playerx:
			.res	1,$00
		playery:
			.res	1,$00
		camerax:
			.res	1,$00
		cameray:
			.res	1,$00
		direction:
			.res	1,$00
		playerHealth:
			.res	1,$00
		playerStamina:
			.res	1,$00
		playerPower:
			.res	1,$00
		playerExp:
			.res	2,$00
		gold:
			.res	2,$00
		species:
			.res	1,$00
		keys:
			.res	1,$00

		inventory:
			item_id:
				.res	8
			item_quantity:
				.res	8

		mapId:
			.res	1,$00

	end_game_save:

	mapWidth:
		.res	1,$00
	mapHeight:
		.res	1,$00
	mapBuffer:
		.res	4096,$00

	warps:
		warp_id:
			.res	8
		warp_src_x:
			.res	8
		warp_src_y:
			.res	8
		warp_dst_x:
			.res	8
		warp_dst_y:
			.res	8

	doors:
		door_x:
			.res	8
		door_y:
			.res	8

	itoa_buffer:
		.res	7,$00
	frameCount:
		.res	1,$00
	playerInput:
		.res	1,$00
	lastKey:
		.res	1,$00
	buffer_prompt:
		.res	20,$00

.segment	"ZEROPAGE" : zeropage

    .exportzp byte0, byte1, byte2, byte3, byte4, byte5, byte6, byte7
    .exportzp uint0, uint1, int0, int1
    .exportzp idx8, jdx8, idx16, jdx16
    .exportzp ptr
    .exportzp arg0, arg1, arg2, arg3
    .exportzp irqbyte0, irqbyte1, irqbyte2, irqbyte3

	; for "higher-level" subroutines
    byte0:     .res 1
    byte1:     .res 1
    byte2:     .res 1
    byte3:     .res 1
    byte4:     .res 1
    byte5:     .res 1
    byte6:     .res 1
    byte7:     .res 1

    uint0:     .res 2
    uint1:     .res 2
    int0:      .res 2
    int1:      .res 2

    idx8:      .res 1
    jdx8:      .res 1
    idx16:     .res 2
    jdx16:     .res 2

    ptr:       .res 2

    ; for argument passing purposes, when there aren't enough registers
    arg0:       .res 1
    arg1:       .res 1
    arg2:       .res 1
    arg3:       .res 1

    ; ONLY FOR IRQ ROUTINE PURPOSES
    irqbyte0:   .res 1
    irqbyte1:   .res 1
    irqbyte2:   .res 1
    irqbyte3:   .res 1

.segment	"RODATA"

	.export		dir_char

	dir_char:
		.byte	$61, $62, $63, $64
