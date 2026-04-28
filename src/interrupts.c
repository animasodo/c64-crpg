#include <peekpoke.h>
#include <cbm.h>
#include <6502.h>
#include "interrupts.h"
#include "drawmap.h"
#include "globals.h"

void initIrq(void) {
    frameCount = 0;
    SEI();
    POKE(0xD012, 0); // raster
    POKE(0xD01A, PEEK(0xD01A) | 1); // enable raster interrupt
    set_irq(&irqRoutine, tempStack, STACK_SIZE);
    CLI();
}

unsigned char irqRoutine(void) {
    if(++frameCount == FPS) frameCount = 0;
    asm("inc $D019");
    return IRQ_NOT_HANDLED; // let the kernal do its job
}