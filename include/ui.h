#ifndef UI_H
#define UI_H

#include "globals.h"

#define MULTICOLOR_0 0xd022
#define MULTICOLOR_1 0xd023

#define CASE 0xd018
#define BORDER_COLOR 0xd020
#define BG_COLOR 0xd021
#define SCREEN_WIDTH 40
#define SCREEN_HEIGHT 25
#define VIEWPORT_WIDTH 11
#define VIEWPORT_HEIGHT 9

#define BLACK 0x00
#define WHITE 0x01
#define RED 0x02
#define CYAN 0x03
#define PURPLE 0x04
#define GREEN 0x05
#define BLUE 0x06
#define YELLOW 0x07
#define ORANGE 0x08
#define BROWN 0x09
#define PINK 0x0A
#define DARK_GRAY 0x0B
#define GRAY 0x0C
#define LIGHT_GREEN 0x0D
#define LIGHT_PURPLE 0x0E
#define LIGHT_GRAY 0x0F

extern const char dirChar[4];

#define printDirection() (*(char*)(0xC800 + (40 * 0) + 37)) = dirChar[direction] // inlined 3 line assembly code

void drawBox(char x, char y, char length, char height);

void drawStats(void);

void drawMainUI(void);

void plotLine(char startx, char starty, char finalx, char finaly);

#endif