#include <stdio.h>
#include <string.h>
#include <c64.h>
#include <conio.h>
#include <peekpoke.h>
#include <6502.h>
#include <ctype.h>
#include <stdlib.h>
#include "io.h"
#include "charset.h"
#include "globals.h"

#include "ui.h"

#define SCREEN_MEM 0xC800
#define COLOR_MEM 0xD800
#define SCREEN_WIDTH 40
#define BLOCK_TILE_CHR 0x7A
#define BLOCK_TILE_SCR 0xBA

const char dirChar[4] = {'N', 'E', 'S', 'W'};

void drawBox(char x, char y, char length, char height){
    char xl = (x + length) - 1, yh = (y + height) - 1, oldColor = textcolor(LIGHT_PURPLE);
    chlinexy(x, y, length);
    cvlinexy(x, y, height);
    chlinexy(x, yh, length);
    cvlinexy(xl, y, height);

    oldColor = textcolor(YELLOW);
    cputcxy(x, y, 0x9C); // top left
    cputcxy(xl, y, 0x9C); // top right
    cputcxy(x, yh, 0x9C); // bottom left
    cputcxy(xl, yh, 0x9C); // bottom right
    textcolor(oldColor);
}

void drawStats(void){
    cputsxy(25, 0, playerName);
    cputsxy(24, 2, "Health:");
    cputsxy(24, 3, "Stamina:");
    cputsxy(24, 4, "Power:");
    cputsxy(24, 5, "Exp:");
    cputsxy(24, 6, "Gold:");
}

void drawMainUI(void){
    char oldColor = textcolor(LIGHT_PURPLE);
    clrscr();
    drawBox(0, 0, 40, 25);
    chlinexy(1, 19, 23);
    cvlinexy(23, 1, 24);
    
    textcolor(YELLOW);
    cputcxy(23, 0, 0x9C);
    cputcxy(23, 24, 0x9C);
    cputcxy(0, 19, 0x9C);
    cputcxy(23, 19, 0x9C);
    
    drawStats();
    (*(char*)(COLOR_MEM + (SCREEN_WIDTH * 0) + 37)) = YELLOW;
    printDirection();
    textcolor(RED);
    textcolor(oldColor);

    (*(char*)(COLOR_MEM + (SCREEN_WIDTH * 23) + 1)) = WHITE;
    (*(char*)(SCREEN_MEM + (SCREEN_WIDTH * 23) + 1)) = 0x1C; // pound
}
