; ---------------------------------------------------------------
; execute_script
;   read a script and execute it
;
; in:  A = script index
; ---------------------------------------------------------------

    .autoimport on
    .importzp   ptr1
    .exportzp   script_ptr
	.export		execute_script, inc_ptr
    .macpack	longbranch
    .include    "definitions.inc"

.segment    "ZEROPAGE" : zeropage
    script_ptr: .res 2

.segment	"CODE"

execute_script:
    jsr     retrieve_script
read_next:
    ldy     #$00
    lda     (script_ptr),y

    cmp     #END
    bne     :+
    rts
:   cmp     #LD_R0
    jeq     ld_r0_value
    cmp     #LD_R1
    jeq     ld_r1_value
    cmp     #LD_R0_R1
    jeq     ld_r0_r1
    cmp     #LD_R1_R0
    jeq     ld_r1_r0
    cmp     #ADD
    jeq     add
    cmp     #SUB
    jeq     sub
    cmp     #SET_FLAG
    jeq     set_flag
    cmp     #LD_FLAG
    jeq     ld_flag
    cmp     #BRANCH_EQ
    jeq     branch_eq
    cmp     #BRANCH_NE
    jeq     branch_ne
    cmp     #BRANCH_LT
    jeq     branch_lt
    cmp     #BRANCH_GT
    jeq     branch_gt
    cmp     #BRANCH
    jeq     always_branch
    cmp     #LOAD_MAP
    jeq     load_map
    cmp     #SET_TILE
    jeq     set_tile
    cmp     #MESSAGE
    jeq     display_message
    cmp     #YNQ
    jeq     yesno
    cmp     #WSP
    jeq     waitspace
next_ops:
    jsr     inc_ptr
    jmp     read_next

ld_r0_value:
    jsr     inc_ptr
    lda     (script_ptr),y
    sta     r0
    jmp     next_ops

ld_r1_value:
    jsr     inc_ptr
    lda     (script_ptr),y
    sta     r1
    jmp     next_ops

ld_r0_r1:
    lda     r1
    sta     r0
    jmp     next_ops

ld_r1_r0:
    lda     r0
    sta     r1
    jmp     next_ops

add:
    lda     r0
    clc
    adc     r1
    sta     r0
    jmp     next_ops

sub:
    lda     r0
    sec
    sbc     r1
    sta     r0
    jmp     next_ops

set_flag: ; this instruction is three bytes long, the first byte is the instruction, the second byte is the index of the flag byte to use, and the third byte is the mask
    jsr     take_flag_args
    lda     r0
    beq     clear_flag
    ; r0 is not zero, set flag
    lda     flags,x
    and     (script_ptr),y
    sta     flags,x
    jmp     next_ops
clear_flag:
    lda     flags,x
    eor     (script_ptr),y
    and     flags,x
    sta     flags,x
    jmp     next_ops

ld_flag:
    jsr     take_flag_args
    lda     (script_ptr),y
    ora     flags,x
    sta     r0
    jmp     next_ops

branch_eq:
    lda     r0
    cmp     r1
    beq     always_branch
    jsr     inc_ptr
    jmp     next_ops

branch_ne:
    lda     r0
    cmp     r1
    bne     always_branch
    jsr     inc_ptr
    jmp     next_ops

branch_lt:
    lda     r0
    cmp     r1
    bcc     always_branch
    jsr     inc_ptr
    jmp     next_ops

branch_gt:
    lda     r0
    cmp     r1
    beq     :+
    bcs     always_branch
:   jsr     inc_ptr
    jmp     next_ops

always_branch:
    jsr     inc_ptr
    lda     (script_ptr),y
    pha
    jsr     add_ptr
    pla
    bpl     :+
    dec     script_ptr+1
:   jmp     next_ops

load_map:
    jsr     inc_ptr
    lda     (script_ptr),y
    sta     playerx
    jsr     inc_ptr
    lda     (script_ptr),y
    sta     playery
    lda     r0
    cmp     mapId
    beq     :+
    jsr     load_map_compressed
:   jmp     next_ops

set_tile:
    jsr     inc_ptr
    lda     (script_ptr),y
    ldx     mapWidth
    jsr     mul8x8 ; multiply y and the map width

    jsr     inc_ptr
    ldy     #$00
    clc
    adc     (script_ptr),y ; add x
    bcc     :+
    inx
:   clc
    adc     #<(mapBuffer)
    sta     ptr1
    txa
    adc     #>(mapBuffer)
    sta     ptr1+1

    ldy     #$00
    lda     r0
    sta     (ptr1),y
    jmp     next_ops

display_message:
    jsr     inc_ptr
    lda     script_ptr
    ldx     script_ptr+1
    jsr     message
    tya
    jsr     add_ptr
    jmp     next_ops

yesno:
    jsr     yes_no_question
    sta     r0
    jmp     next_ops

waitspace:
    jsr     message_wait
    jmp     next_ops

; subroutines

take_flag_args:
    jsr     inc_ptr
    lda     (script_ptr),y ; read byte index
    tax
    jsr     inc_ptr
    rts

add_ptr:
    clc
    adc     script_ptr
    sta     script_ptr
    lda     #$00
    adc     script_ptr+1
    sta     script_ptr+1
    rts

inc_ptr:
    inc     script_ptr
    bne     :+
    inc     script_ptr+1
:   rts
