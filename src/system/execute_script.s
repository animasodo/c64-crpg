; ---------------------------------------------------------------
; execute_script
;   read a script and execute it
;
; in:  A = script index
; ---------------------------------------------------------------

    .autoimport on
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
    beq     done
    cmp     #LD_R0
    jeq     ld_r0_value
    cmp     #LD_R1
    jeq     ld_r1_value
    cmp     #LD_R0_R1
    jeq     ld_r0_r1
    cmp     #LD_R1_R0
    jeq     ld_r1_r0
    cmp     #LOAD_MAP
    jeq     load_map
    cmp     #MESSAGE
    jeq     display_message

next_ops:
    jsr     inc_ptr
    jmp     read_next
done:
    rts

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
    clc
    lda     r0
    adc     r1
    sta     r0
    jmp     next_ops

sub:
    sec
    lda     r0
    sbc     r1
    sta     r0
    jmp     next_ops

ld_flags_r0: ; this command is three bytes long, the first byte is the command, the second byte is the index of the flag byte to use, and the third byte is the index of the flag bit to store it in
    jsr     inc_ptr
    lda     (script_ptr),y ; read byte index
    tax
    jsr     inc_ptr
    lda     r0
    beq     clear_flag
    ; r0 is not zero, set flag
    lda     flags,x
    ora     (script_ptr),y
    sta     flags,x
    jmp     next_ops
clear_flag:
    lda     flags,x
    eor     (script_ptr),y
    sta     flags,x
    jmp     next_ops

ld_r0_flags:
    jsr     inc_ptr
    lda     (script_ptr),y
    tax
    lda     flags,x
    sta     r0
    jsr     inc_ptr
    lda     (script_ptr),y
    ora     r0
    sta     r0
    jmp     next_ops

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

display_message:
    jsr     inc_ptr
    lda     script_ptr
    ldx     script_ptr+1
    jsr     message
    tya
    jsr     add_ptr
    jmp     next_ops

add_ptr:
    clc
    adc     script_ptr
    sta     script_ptr
    adc     script_ptr+1
    sta     script_ptr+1
    rts

inc_ptr:
    inc     script_ptr
    bne     :+
    inc     script_ptr+1
:   rts
