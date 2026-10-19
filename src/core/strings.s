
	.autoimport	on
    .export     health_str, stamina_str, power_str, exp_str, gold_str, storage_str
    .export     door_open, door_unlocked, no_door
	.export		save_to, load_from, save_to_as, load_from_as, device_number_error, disk_error, map_error
    .include    "definitions.inc"

.segment "RODATA"

; ui elements

health_str:
    .byte "Health:", NULL

stamina_str:
    .byte "Stamina:", NULL

power_str:
    .byte "Power", NULL

exp_str:
    .byte "Exp:", NULL

gold_str:
    .byte "Gold:", NULL

storage_str:
	.byte "Storage", NULL

; door messages

door_open:
    .byte "Door open!", NULL

door_unlocked:
    .byte "Door unlocked!", NULL

no_door:
    .byte "No door in this", NL, "direction.", NULL

; io messages

devices:
    .byte " (8,9) ", NULL

save_to:
    .byte "Save to", STR, <(devices), >(devices), NULL

load_from:
    .byte "Load from", STR, <(devices), >(devices), NULL

save_to_as:
    .byte "Save to ", CHR, <(buffer_prompt), >(buffer_prompt), " as?", NL, NULL

load_from_as:
    .byte "Load from ", CHR, <(buffer_prompt), >(buffer_prompt), " as?", NL, NULL

device_number_error:
    .byte "Not a valid device", NL, "number.", NULL

disk_error:
    .byte "Disk error.", NULL

map_error:
    .byte "Not a map.", NULL
