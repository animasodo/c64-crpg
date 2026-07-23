#include <stdio.h>
#include <string.h>
#include <c64.h>
#include <conio.h>
#include <peekpoke.h>
#include <6502.h>
#include <ctype.h>
#include <stdlib.h>
#include "io.h"
#include "simplewrite.h"
#include "strings.h"
#include "globals.h"
#include "ui.h"

#define SCREEN_MEM 0xC800
#define COLOR_MEM 0xD800
#define SCREEN_WIDTH 40

const char dirChar[4] = {0x61, 0x62, 0x63, 0x64};

void drawMainUI(void){
    byte0 = textcolor(LIGHT_PURPLE);
    clrscr();
    drawBox(0, 0, 40, 25);
    chlinexy(1, 19, 27);
    cvlinexy(27, 1, 24);
    
    textcolor(YELLOW);
    cputcxy(27, 0, 0x9C);
    cputcxy(27, 24, 0x9C);
    cputcxy(0, 19, 0x9C);
    cputcxy(27, 19, 0x9C);

    cputsxy(29, 0, playerName);
    cputsxy(29, 2, "Health:");
    cputsxy(29, 4, "Stamina:");
    cputsxy(29, 6, "Power:");
    cputsxy(29, 8, "Exp:");
    cputsxy(29, 10, "Gold:");
    
    drawStats();
    (*(char*)(COLOR_MEM + (SCREEN_WIDTH * 0) + 37)) = RED;
    printDirection();
    textcolor(byte0);
}
