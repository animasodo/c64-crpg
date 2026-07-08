;
; test strings
;

	.export		_test_string0, test_string1

    NL = $0D

.segment "RODATA"

_test_string0:
    .byte "Hello, >", 4, "world>", 1, "!", NL, "This is a $", <(test_string1), >(test_string1), "!", 0

test_string1:
    .byte "test", 0