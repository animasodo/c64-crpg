;
; test strings
;

    .import     _playerHealth, _bufferPrompt
	.export		_save_to, _load_from, _save_to_as, _load_from_as

    END = $00
    CLR = $01
    STR = $02
    INT = $03
    CHR = $05
    NL = $0D

.segment "RODATA"

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