;
; this routine will be loaded onto the 1541's ram
; original code by Michael Steil (mist64/fastboot1541)
; thank you! you're so much smarter than me :P
;

.segment "DRVCODE"

VIA2_PRA := $1800
DOREAD := $D586

F_DATA_OUT := %0010
F_CLK_OUT  := %1000

current_buffer := $f9

buffer_0_track := $06
buffer_0_sector := $07

; VIA (I/O, $1800):
; 7 - ATN IN
; 6-5 - DEVICE JUMPER
; 4 - ATN ACK OUT
; 3 - CLOCK OUT (to computer)
; 2 - CLOCK IN (to drive)
; 1 - DATA OUT (to computer)
; 0 - DATA IN (to drive)

start:
    ; tell the computer our routine is running
    lda     #F_CLK_OUT
    sta     VIA2_PRA

    lda     #0
    sta     current_buffer ; set current buffer to $0300-$03ff
read_loop:
    cli
    jsr     DOREAD ; read sector
    sei

    ; we can use $f9 as the byte counter, since we'll return it to 0
    ; so it holds the correct buffer number "0" when we read the next sector
    ldx     #2
    stx     $f9

    ; we're grabbing the first two bytes because they contain the next t:s
    ; the rest we can just send to the computer, it doesn't have to know
    ; anything about how the data is structured in the disk
    lda     $0300
    sta     buffer_0_track
    lda     $0301
    sta     buffer_0_sector
send_buffer_loop:
    ldx     $f9
    lda     $0300,x

; first encode
    pha     ; save original
    lsr
    lsr
    lsr
    lsr     ; get high nybble
    tax     ; to X
    ldy     enc_tab,x ; super-encoded high nybble in Y
    pla
    and     #$0F ; lower nybble
    tax
    lda     enc_tab,x ; super-encoded low nybble in A
    
    ; i wanna buy myself some time to here's some stuff to waste cycles
    pha     ; 3 cycles
    pla     ; 4 cycles
	bit		$00 ; 3 cycles

    ldx     VIA2_PRA
    bmi     end ; checking for an exit signal from ATN
    ; this is not part of the handshake below because it takes too long and messes up the timing
    
    ; byte has been converted and is ready to send
    ldx     #0
    stx     VIA2_PRA ; DATA=0, CLK=0 -> we're ready to send!

    ; then wait for C64 to be ready
wait_c64:
    ldx     VIA2_PRA
    bne     wait_c64 ; needs all 0

    ; GO GO GO GO GO
    sta     VIA2_PRA
    asl
    and     #$0F
    sta     VIA2_PRA
    tya
    nop
    sta     VIA2_PRA
    asl
    and     #$0F
    sta     VIA2_PRA

    ; set clock line low (clk = 1)
    jsr     $E9AE

    inc     $f9
    bne     send_buffer_loop
    beq     read_loop
end:
    rts

enc_tab:
    .byte %1111, %0111, %1101, %0101, %1011, %0011, %1001, %0001
    .byte %1110, %0110, %1100, %0100, %1010, %0010, %1000, %0000
