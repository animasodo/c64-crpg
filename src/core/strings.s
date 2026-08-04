
	.autoimport	on
    .export     health_str, stamina_str, power_str, exp_str, gold_str
    .export     door_open, door_unlocked, no_door
	.export		save_to, load_from, save_to_as, load_from_as, device_number_error, disk_error, map_error

    END = $00
    CLR = $01
    STR = $02
    INT = $03
    BYTE = $04
    CHR = $05
    NL = $0D

.segment "RODATA"

; ui elements

health_str:
    .byte "Health:", END

stamina_str:
    .byte "Stamina:", END

power_str:
    .byte "Power", END

exp_str:
    .byte "Exp:", END

gold_str:
    .byte "Gold:", END

; door messages

door_open:
    .byte "Door open!", END

door_unlocked:
    .byte "Door unlocked!", END

no_door:
    .byte "No door in this", NL, "direction.", END

; io messages

devices:
    .byte " (8,9) ", END

save_to:
    .byte "Save to", STR, <(devices), >(devices), END

load_from:
    .byte "Load from", STR, <(devices), >(devices), END

save_to_as:
    .byte "Save to ", CHR, <(buffer_prompt), >(buffer_prompt), " as?", NL, END

load_from_as:
    .byte "Load from ", CHR, <(buffer_prompt), >(buffer_prompt), " as?", NL, END

device_number_error:
    .byte "Not a valid device", NL, "number.", END

disk_error:
    .byte "Disk error.", END

map_error:
    .byte "Not a map.", END
