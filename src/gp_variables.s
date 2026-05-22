
; some general purpose zp variables

.segment "GPZP" : zeropage

    .exportzp _byte0, _byte1, _byte2, _byte3, _byte4, _byte5, _byte6, _byte7
    .exportzp _uint0, _uint1, _uint0, _uint3, _int0, _int1, _int2, _int3
    .exportzp _idx8, _jdx8, _idx16, _jdx16
    .exportzp _ptr

    _byte0:     .res 1
    _byte1:     .res 1
    _byte2:     .res 1
    _byte3:     .res 1
    _byte4:     .res 1
    _byte5:     .res 1
    _byte6:     .res 1
    _byte7:     .res 1

    _uint0:     .res 2
    _uint1:     .res 2
    _uint2:     .res 2
    _uint3:     .res 2
    _int0:      .res 2
    _int1:      .res 2
    _int2:      .res 2
    _int3:      .res 2

    _idx8:      .res 1
    _jdx8:      .res 1
    _idx16:     .res 2
    _jdx16:     .res 2

    _ptr:       .res 2