#include <stdio.h>
#include <string.h>
#include <c64.h>
#include <conio.h>
#include <peekpoke.h>
#include <6502.h>
#include <ctype.h>
#include <stdlib.h>
#include "io.h"
#include "globals.h"

#include "ui.h"

#define SCREEN_MEM 0xC800
#define COLOR_MEM 0xD800
#define SCREEN_WIDTH 40
#define BLOCK_TILE_CHR 0x7A
#define BLOCK_TILE_SCR 0xBA

const char dirChar[4] = {'N', 'E', 'S', 'W'};

void drawBox(char x, char y, char length, char height){
    byte0 = (x + length) - 1, byte1 = (y + height) - 1, byte2 = textcolor(LIGHT_PURPLE);
    chlinexy(x, y, length);
    cvlinexy(x, y, height);
    chlinexy(x, byte1, length);
    cvlinexy(byte0, y, height);

    byte2 = textcolor(YELLOW);
    cputcxy(x, y, 0x9C); // top left
    cputcxy(byte0, y, 0x9C); // top right
    cputcxy(x, byte1, 0x9C); // bottom left
    cputcxy(byte0, byte1, 0x9C); // bottom right
    textcolor(byte2);
}

void drawStats(void){
    byte7 = textcolor(WHITE);
    cputsxy(30, 3, utoa(playerHealth, (char*)byte0, 10));
    cputsxy(30, 5, utoa(playerStamina, (char*)byte0, 10));
    cputsxy(30, 7, utoa(playerPower, (char*)byte0, 10));
    cputsxy(30, 9, utoa(playerExp, (char*)byte0, 10));
    cputsxy(30, 11, utoa(gold, (char*)byte0, 10));
    textcolor(byte7);
}

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
