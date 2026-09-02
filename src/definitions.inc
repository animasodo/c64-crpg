; ---------------------------------------------------------------
; list of generic definitions for the project
; ---------------------------------------------------------------

; *** directions ***
NORTH			:= 0
EAST			:= 1
SOUTH			:= 2
WEST			:= 3

UP              := 1
DOWN            := 2
LEFT            := 4
RIGHT           := 8

; *** screen things ***
FPS				:= 50
X_OFFSET        := 24
Y_OFFSET        := 50
HORIZONTAL_VIEW := $1A

; *** colors ***
BLACK			:= $00
WHITE			:= $01
RED				:= $02
CYAN			:= $03
VIOLET			:= $04
GREEN			:= $05
BLUE			:= $06
YELLOW			:= $07
ORANGE			:= $08
BROWN			:= $09
LIGHT_RED		:= $0A
DARK_GREY		:= $0B
MED_GREY		:= $0C
LIGHT_GREEN		:= $0D
LIGHT_BLUE		:= $0E
LIGHT_GREY		:= $0F

; *** disk operation stuff ***
LFN				:= $02
COMMAND			:= $0F
FLOPPY			:= $08
MANIFEST_AREA	:= $9000
VICII_BANK_AREA	:= $C000
SCREEN_AREA     := $C800
COLOR_AREA      := $D800

; *** vm stuff ***
; the kernal doesn't use these zp bytes, so we can use them for vm registers
r0              := $FB ; main register
r1              := $FC ; secondary register
vm_tmp          := $FD ; tmp register for the interpreter
ptr_idx         := $FE
; opcode definitions
END             := $00
LD_R0_VALUE     := $01
LD_R1_VALUE     := $02
LD_R0_R1        := $03
LD_R1_R0        := $04
ADD             := $05 ; add r1 to r0, result in r0
SUB             := $06 ; subtract r1 from r0, result in r0
LD_FLAGS_R0     := $07
LD_R0_FLAGS     := $08
LOAD_MAP        := $09 ; load map from disk, r0 = map id, two bytes follow: x, y
SET_TILE        := $0A ; set tile to value in r0, two bytes follow: x, y
