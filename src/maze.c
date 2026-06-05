#include <conio.h>
#include <string.h>
#include <c64.h>
#include "writeline.h"
#include "simplewrite.h"
#include "maze_data.h"
#include "ui.h"
#include "io.h"
#include "globals.h"

#define SCREEN_MEM 0xC800
#define COLOR_MEM 0xD800
#define SCREEN_WIDTH 40
#define BLOCK_TILE_CHR 0x7A
#define BLOCK_TILE_SCR 0xBA
#define position uint0

// the code will assume the maze size is always 16x16, as it fits inside a one byte array

// better way to draw squares. it really is that simple lol
void drawSquare(char x, char y, char len, char finaly, char c, char color) {
    byte0 = textcolor(color);
    for (; y <= finaly; y++) {
        writeh(x, y, c, len);
    }
    textcolor(byte0);
}

void drawLeftFour(void){
    // tiles
    (*(char*)(SCREEN_MEM + (SCREEN_WIDTH * 9) + 8)) = BLOCK_TILE_CHR;
    (*(char*)(SCREEN_MEM + (SCREEN_WIDTH * 10) + 8)) = BLOCK_TILE_CHR;
    // color
    (*(char*)(COLOR_MEM + (SCREEN_WIDTH * 9) + 8)) = BLUE;
    (*(char*)(COLOR_MEM + (SCREEN_WIDTH * 10) + 8)) = BLUE;
}

void drawRightFour(void){
    // tiles
    (*(char*)(SCREEN_MEM + (SCREEN_WIDTH * 9) + 15)) = BLOCK_TILE_CHR;
    (*(char*)(SCREEN_MEM + (SCREEN_WIDTH * 10) + 15)) = BLOCK_TILE_CHR;
    // color
    (*(char*)(COLOR_MEM + (SCREEN_WIDTH * 9) + 15)) = BLUE;
    (*(char*)(COLOR_MEM + (SCREEN_WIDTH * 10) + 15)) = BLUE;
}

void drawLeftThree(void){
    // tiles
    (*(char*)(SCREEN_MEM + (SCREEN_WIDTH * 9) + 8)) = BLOCK_TILE_CHR;
    (*(char*)(SCREEN_MEM + (SCREEN_WIDTH * 10) + 8)) = BLOCK_TILE_CHR;

    (*(char*)(SCREEN_MEM + (SCREEN_WIDTH * 8) + 7)) = BLOCK_TILE_CHR;
    (*(char*)(SCREEN_MEM + (SCREEN_WIDTH * 9) + 7)) = BLOCK_TILE_CHR;
    (*(char*)(SCREEN_MEM + (SCREEN_WIDTH * 10) + 7)) = BLOCK_TILE_CHR;
    (*(char*)(SCREEN_MEM + (SCREEN_WIDTH * 11) + 7)) = BLOCK_TILE_CHR; // oh mein gott
    (*(char*)(SCREEN_MEM + (SCREEN_WIDTH * 8) + 6)) = BLOCK_TILE_CHR;
    (*(char*)(SCREEN_MEM + (SCREEN_WIDTH * 9) + 6)) = BLOCK_TILE_CHR;
    (*(char*)(SCREEN_MEM + (SCREEN_WIDTH * 10) + 6)) = BLOCK_TILE_CHR;
    (*(char*)(SCREEN_MEM + (SCREEN_WIDTH * 11) + 6)) = BLOCK_TILE_CHR;

    (*(char*)(SCREEN_MEM + (SCREEN_WIDTH * 8) + 8)) = 0x7F;
    (*(char*)(SCREEN_MEM + (SCREEN_WIDTH * 11) + 8)) = 0x7B;

    // color
    (*(char*)(COLOR_MEM + (SCREEN_WIDTH * 8) + 7)) = CYAN;
    (*(char*)(COLOR_MEM + (SCREEN_WIDTH * 9) + 7)) = CYAN;
    (*(char*)(COLOR_MEM + (SCREEN_WIDTH * 10) + 7)) = CYAN;
    (*(char*)(COLOR_MEM + (SCREEN_WIDTH * 11) + 7)) = CYAN;
    (*(char*)(COLOR_MEM + (SCREEN_WIDTH * 8) + 6)) = CYAN;
    (*(char*)(COLOR_MEM + (SCREEN_WIDTH * 9) + 6)) = CYAN;
    (*(char*)(COLOR_MEM + (SCREEN_WIDTH * 10) + 6)) = CYAN;
    (*(char*)(COLOR_MEM + (SCREEN_WIDTH * 11) + 6)) = CYAN;

    (*(char*)(COLOR_MEM + (SCREEN_WIDTH * 9) + 8)) = BLUE;
    (*(char*)(COLOR_MEM + (SCREEN_WIDTH * 10) + 8)) = BLUE;
    (*(char*)(COLOR_MEM + (SCREEN_WIDTH * 8) + 8)) = BLUE;
    (*(char*)(COLOR_MEM + (SCREEN_WIDTH * 11) + 8)) = BLUE;
}

void drawRightThree(void){
    // tiles
    (*(char*)(SCREEN_MEM + (SCREEN_WIDTH * 9) + 15)) = BLOCK_TILE_CHR;
    (*(char*)(SCREEN_MEM + (SCREEN_WIDTH * 10) + 15)) = BLOCK_TILE_CHR;

    (*(char*)(SCREEN_MEM + (SCREEN_WIDTH * 8) + 16)) = BLOCK_TILE_CHR;
    (*(char*)(SCREEN_MEM + (SCREEN_WIDTH * 9) + 16)) = BLOCK_TILE_CHR;
    (*(char*)(SCREEN_MEM + (SCREEN_WIDTH * 10) + 16)) = BLOCK_TILE_CHR;
    (*(char*)(SCREEN_MEM + (SCREEN_WIDTH * 11) + 16)) = BLOCK_TILE_CHR;
    (*(char*)(SCREEN_MEM + (SCREEN_WIDTH * 8) + 17)) = BLOCK_TILE_CHR;
    (*(char*)(SCREEN_MEM + (SCREEN_WIDTH * 9) + 17)) = BLOCK_TILE_CHR;
    (*(char*)(SCREEN_MEM + (SCREEN_WIDTH * 10) + 17)) = BLOCK_TILE_CHR;
    (*(char*)(SCREEN_MEM + (SCREEN_WIDTH * 11) + 17)) = BLOCK_TILE_CHR;

    (*(char*)(SCREEN_MEM + (SCREEN_WIDTH * 8) + 15)) = 0x7E;
    (*(char*)(SCREEN_MEM + (SCREEN_WIDTH * 11) + 15)) = 0x7C;

    // color
    (*(char*)(COLOR_MEM + (SCREEN_WIDTH * 8) + 16)) = CYAN;
    (*(char*)(COLOR_MEM + (SCREEN_WIDTH * 9) + 16)) = CYAN;
    (*(char*)(COLOR_MEM + (SCREEN_WIDTH * 10) + 16)) = CYAN;
    (*(char*)(COLOR_MEM + (SCREEN_WIDTH * 11) + 16)) = CYAN;
    (*(char*)(COLOR_MEM + (SCREEN_WIDTH * 8) + 17)) = CYAN;
    (*(char*)(COLOR_MEM + (SCREEN_WIDTH * 9) + 17)) = CYAN;
    (*(char*)(COLOR_MEM + (SCREEN_WIDTH * 10) + 17)) = CYAN;
    (*(char*)(COLOR_MEM + (SCREEN_WIDTH * 11) + 17)) = CYAN;

    (*(char*)(COLOR_MEM + (SCREEN_WIDTH * 9) + 15)) = BLUE;
    (*(char*)(COLOR_MEM + (SCREEN_WIDTH * 10) + 15)) = BLUE;
    (*(char*)(COLOR_MEM + (SCREEN_WIDTH * 8) + 15)) = BLUE;
    (*(char*)(COLOR_MEM + (SCREEN_WIDTH * 11) + 15)) = BLUE;
}

void drawLeftTwo(void){
    drawSquare(6, 7, 2, 12, BLOCK_TILE_CHR, CYAN);
    drawSquare(3, 6, 3, 13, BLOCK_TILE_CHR, CYAN);
    (*(char*)(SCREEN_MEM + (SCREEN_WIDTH * 6) + 6)) = 0x7F;
    (*(char*)(SCREEN_MEM + (SCREEN_WIDTH * 7) + 7)) = 0x7F;
    (*(char*)(SCREEN_MEM + (SCREEN_WIDTH * 13) + 6)) = 0x7B; // what the florp
    (*(char*)(SCREEN_MEM + (SCREEN_WIDTH * 12) + 7)) = 0x7B;
}

void drawRightTwo(void){
    drawSquare(16, 7, 2, 12, BLOCK_TILE_CHR, CYAN);
    drawSquare(18, 6, 3, 13, BLOCK_TILE_CHR, CYAN);
    (*(char*)(SCREEN_MEM + (SCREEN_WIDTH * 6) + 17)) = 0x7E;
    (*(char*)(SCREEN_MEM + (SCREEN_WIDTH * 7) + 16)) = 0x7E;
    (*(char*)(SCREEN_MEM + (SCREEN_WIDTH * 12) + 16)) = 0x7C;
    (*(char*)(SCREEN_MEM + (SCREEN_WIDTH * 13) + 17)) = 0x7C;
}

void drawLeftOne(void){
    drawSquare(3, 5, 3, 14, BLOCK_TILE_CHR, CYAN);
    drawSquare(1, 3, 2, 16, BLOCK_TILE_CHR, WHITE);
    (*(char*)(SCREEN_MEM + (SCREEN_WIDTH * 4) + 3)) = BLOCK_TILE_CHR;
    (*(char*)(SCREEN_MEM + (SCREEN_WIDTH * 15) + 3)) = BLOCK_TILE_CHR;

    (*(char*)(SCREEN_MEM + (SCREEN_WIDTH * 3) + 3)) = 0x7F;
    (*(char*)(SCREEN_MEM + (SCREEN_WIDTH * 4) + 4)) = 0x7F;
    (*(char*)(SCREEN_MEM + (SCREEN_WIDTH * 5) + 5)) = 0x7F;
    (*(char*)(SCREEN_MEM + (SCREEN_WIDTH * 16) + 3)) = 0x7B;
    (*(char*)(SCREEN_MEM + (SCREEN_WIDTH * 15) + 4)) = 0x7B;
    (*(char*)(SCREEN_MEM + (SCREEN_WIDTH * 14) + 5)) = 0x7B;
}

void drawRightOne(void){
    drawSquare(18, 5, 3, 14, BLOCK_TILE_CHR, CYAN);
    drawSquare(21, 3, 2, 16, BLOCK_TILE_CHR, WHITE);
    (*(char*)(SCREEN_MEM + (SCREEN_WIDTH * 4) + 20)) = BLOCK_TILE_CHR;
    (*(char*)(SCREEN_MEM + (SCREEN_WIDTH * 15) + 20)) = BLOCK_TILE_CHR;

    (*(char*)(SCREEN_MEM + (SCREEN_WIDTH * 3) + 20)) = 0x7E;
    (*(char*)(SCREEN_MEM + (SCREEN_WIDTH * 4) + 19)) = 0x7E;
    (*(char*)(SCREEN_MEM + (SCREEN_WIDTH * 5) + 18)) = 0x7E;
    (*(char*)(SCREEN_MEM + (SCREEN_WIDTH * 16) + 20)) = 0x7C;
    (*(char*)(SCREEN_MEM + (SCREEN_WIDTH * 15) + 19)) = 0x7C;
    (*(char*)(SCREEN_MEM + (SCREEN_WIDTH * 14) + 18)) = 0x7C;
}

void drawLeft(void){
    writev(1, 2, BLOCK_TILE_CHR, 16);
    writev(2, 3, BLOCK_TILE_CHR, 14);
    (*(char*)(SCREEN_MEM + (SCREEN_WIDTH * 1) + 1)) = 0x7F;
    (*(char*)(SCREEN_MEM + (SCREEN_WIDTH * 2) + 2)) = 0x7F;
    (*(char*)(SCREEN_MEM + (SCREEN_WIDTH * 18) + 1)) = 0x7B;
    (*(char*)(SCREEN_MEM + (SCREEN_WIDTH * 17) + 2)) = 0x7B;
    (*(char*)(COLOR_MEM + (SCREEN_WIDTH * 1) + 1)) = WHITE;
    (*(char*)(COLOR_MEM + (SCREEN_WIDTH * 2) + 2)) = WHITE;
    (*(char*)(COLOR_MEM + (SCREEN_WIDTH * 18) + 1)) = WHITE;
    (*(char*)(COLOR_MEM + (SCREEN_WIDTH * 17) + 2)) = WHITE;
}

void drawRight(void){
    writev(22, 2, BLOCK_TILE_CHR, 16);
    writev(21, 3, BLOCK_TILE_CHR, 14);
    (*(char*)(SCREEN_MEM + (SCREEN_WIDTH * 1) + 22)) = 0x7E;
    (*(char*)(SCREEN_MEM + (SCREEN_WIDTH * 2) + 21)) = 0x7E;
    (*(char*)(SCREEN_MEM + (SCREEN_WIDTH * 18) + 22)) = 0x7C;
    (*(char*)(SCREEN_MEM + (SCREEN_WIDTH * 17) + 21)) = 0x7C;
    (*(char*)(COLOR_MEM + (SCREEN_WIDTH * 1) + 22)) = WHITE;
    (*(char*)(COLOR_MEM + (SCREEN_WIDTH * 2) + 21)) = WHITE;
    (*(char*)(COLOR_MEM + (SCREEN_WIDTH * 18) + 22)) = WHITE;
    (*(char*)(COLOR_MEM + (SCREEN_WIDTH * 17) + 21)) = WHITE;
}

void drawView(void){
    char left[5], right[5], front[4];
    char wall_left[5], wall_right[5], wall_front[4];
    
    position = (playery << 4) + playerx; // we can do a shift left since the width of the map is always 16
    switch(direction){
        case NORTH:
            front[0] = position - 16;
            front[1] = position - 32;
            front[2] = position - 48;
            front[3] = position - 64;
            left[0] = position - 1;
            left[1] = position - 17;
            left[2] = position - 33;
            left[3] = position - 49;
            left[4] = position - 65;
            right[0] = position + 1;
            right[1] = position - 15;
            right[2] = position - 31;
            right[3] = position - 47;
            right[4] = position - 63;
            break;
        case EAST:
            front[0] = position + 1;
            front[1] = position + 2;
            front[2] = position + 3;
            front[3] = position + 4;
            left[0] = position - 16;
            left[1] = position - 15;
            left[2] = position - 14;
            left[3] = position - 13;
            left[4] = position - 12;
            right[0] = position + 16;
            right[1] = position + 17;
            right[2] = position + 18;
            right[3] = position + 19;
            right[4] = position + 20;
            break;
        case SOUTH:
            front[0] = position + 16;
            front[1] = position + 32;
            front[2] = position + 48;
            front[3] = position + 64;
            left[0] = position + 1;
            left[1] = position + 17;
            left[2] = position + 33;
            left[3] = position + 49;
            left[4] = position + 65;
            right[0] = position - 1;
            right[1] = position + 15;
            right[2] = position + 31;
            right[3] = position + 47;
            right[4] = position + 63;
            break;
        case WEST:
            front[0] = position - 1;
            front[1] = position - 2;
            front[2] = position - 3;
            front[3] = position - 4;
            left[0] = position + 16;
            left[1] = position + 15;
            left[2] = position + 14;
            left[3] = position + 13;
            left[4] = position + 12;
            right[0] = position - 16;
            right[1] = position - 17;
            right[2] = position - 18;
            right[3] = position - 19;
            right[4] = position - 20;
            break;
    }

    // Precompute wall presence and boundaries
    for (idx8 = 0; idx8 < 5; idx8++) {
        wall_left[idx8] = (test_maze_data[left[idx8]] == 1)
            || (direction == NORTH && playerx == 0)
            || (direction == EAST && playery == 0)
            || (direction == SOUTH && playerx == 15)
            || (direction == WEST && playery == 15);
        wall_right[idx8] = (test_maze_data[right[idx8]] == 1)
            || (direction == NORTH && playerx == 15)
            || (direction == EAST && playery == 15)
            || (direction == SOUTH && playerx == 0)
            || (direction == WEST && playery == 0);
    }
    for (idx8 = 0; idx8 < 4; idx8++) {
        wall_front[idx8] = (test_maze_data[front[idx8]] == 1)
            || (direction == NORTH && playery == idx8)
            || (direction == EAST && playerx == 15 - idx8)
            || (direction == SOUTH && playery == 15 - idx8)
            || (direction == WEST && playerx == idx8);
    }

    drawSquare(1, 1, 22, 18, ' ', CYAN);
    
    writeh(1, 2, 0x6E, 22);
    writeh(1, 5, 0x6E, 22);
    writeh(1, 7, 0x6E, 22);
    writeh(1, 8, 0x6E, 22);
    writeh(1, 11, 0x6D, 22);
    writeh(1, 12, 0x6D, 22);
    writeh(1, 14, 0x6D, 22);
    writeh(1, 17, 0x6D, 22);
    // someone remind me to optimize this

    if (wall_left[0]) drawLeft();
    if (wall_right[0]) drawRight();

    if (wall_left[1]) drawLeftOne();
    if (wall_right[1]) drawRightOne();
    if (wall_front[0]) {
        drawSquare(3, 3, 18, 16, BLOCK_TILE_CHR, WHITE);
        return;
    }

    if (wall_left[2]) drawLeftTwo();
    if (wall_right[2]) drawRightTwo();
    if (wall_front[1]) {
        drawSquare(6, 6, 12, 13, BLOCK_TILE_CHR, CYAN);
        return;
    }

    if (wall_left[3]) drawLeftThree();
    if (wall_right[3]) drawRightThree();
    if (wall_front[2]) {
        drawSquare(8, 8, 8, 11, BLOCK_TILE_CHR, CYAN);
        return;
    }

    if (wall_left[4]) drawLeftFour();
    if (wall_right[4]) drawRightFour();
    if (wall_front[3]) {
        drawSquare(9, 9, 6, 10, BLOCK_TILE_CHR, BLUE);
        return;
    }
}

char advance(void){
    position = (playery << 4) + playerx;
    switch(direction){
        case NORTH:
            if(test_maze_data[position - 16] != 1 && playery != 0){ --playery; return 0;} break;
        case EAST:
            if(test_maze_data[position + 1] != 1 && playerx != 15){ ++playerx; return 0;} break;
        case SOUTH:
            if(test_maze_data[position + 16] != 1 && playery != 15){ ++playery; return 0;} break;
        case WEST:
            if(test_maze_data[position - 1] != 1 && playerx != 0){ --playerx; return 0;} break;
    }
    return 1;
}

char retreat(void){
    position = (playery << 4) + playerx;
    switch(direction){
        case NORTH:
            if(test_maze_data[position + 16] != 1 && playery != 15){ ++playery; return 0;} break;
        case EAST:
            if(test_maze_data[position - 1] != 1 && playerx != 0){ --playerx; return 0;} break;
        case SOUTH:
            if(test_maze_data[position - 16] != 1 && playery != 0){ --playery; return 0;} break;
        case WEST:
            if(test_maze_data[position + 1] != 1 && playerx != 15){ ++playerx; return 0;} break;
    }
    return 1;
}