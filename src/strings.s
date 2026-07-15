;
; test strings
;

    .import     _bufferPrompt
	.export		_save_to, _load_from, _save_to_as, _load_from_as, _device_number_error, _disk_error, _map_error

    END = $00
    CLR = $01
    STR = $02
    INT = $03
    CHR = $05
    NL = $0D

.segment "RODATA"

; io messages

devices:
    .byte "(8,9)", END

_save_to:
    .byte "Save to ", STR, <(devices), >(devices), " ", END

_load_from:
    .byte "Load from ", STR, <(devices), >(devices), " ", END

_save_to_as:
    .byte "Save to ", CHR, <(_bufferPrompt), >(_bufferPrompt), " as?", NL, END

_load_from_as:
    .byte "Load from ", CHR, <(_bufferPrompt), >(_bufferPrompt), " as?", NL, END

_device_number_error:
    .byte "Not a valid device", NL, "number.", END

_disk_error:
    .byte "Disk error.", END

_map_error:
    .byte "Not a map.", END
