
	.autoimport	on
    .export     item_name_hi, item_name_lo
    .include    "definitions.inc"

.segment "RODATA"

    ; pointer table
    item_name_lo:
        .byte <nothing, <potion
    item_name_hi:
        .byte >nothing, >potion

    ; item names
    nothing:
        .byte NULL

    potion: ; placeholder for now
        .byte "Potion", NULL
