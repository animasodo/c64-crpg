#include <conio.h>
#include <string.h>
#include <c64.h>
#include "writeblock.h"
#include "maze_data.h"
#include "ui.h"
#include "globals.h"

#define SCREEN_MEM 0xC800
#define COLOR_MEM 0xD800
#define SCREEN_WIDTH 40
#define BLOCK_TILE_CHR 0x7A
#define BLOCK_TILE_SCR 0xBA

// the code will assume the maze size is always 16x16, as it fits inside a one byte array

// very unoptimal way to draw the walls
// will replace with proper graphics at some point
void drawSquare(char x, char y, char len, char finaly, char c, char color) {
    char i;
    for (; y <= finaly; y++) {
        char *scr = (char *)(SCREEN_MEM + yScreenArray[y] + x);
        char *clr = (char *)(COLOR_MEM + yScreenArray[y] + x);
        for (i = 0; i < len; i++) {
            scr[i] = c;
            clr[i] = color;
        }
    }
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
    (*(char*)(COLOR_MEM + (SCREEN_WIDTH * 9) + 8)) = BLUE;
    (*(char*)(COLOR_MEM + (SCREEN_WIDTH * 10) + 8)) = BLUE;

    (*(char*)(COLOR_MEM + (SCREEN_WIDTH * 8) + 7)) = CYAN;
    (*(char*)(COLOR_MEM + (SCREEN_WIDTH * 9) + 7)) = CYAN;
    (*(char*)(COLOR_MEM + (SCREEN_WIDTH * 10) + 7)) = CYAN;
    (*(char*)(COLOR_MEM + (SCREEN_WIDTH * 11) + 7)) = CYAN;
    (*(char*)(COLOR_MEM + (SCREEN_WIDTH * 8) + 6)) = CYAN;
    (*(char*)(COLOR_MEM + (SCREEN_WIDTH * 9) + 6)) = CYAN;
    (*(char*)(COLOR_MEM + (SCREEN_WIDTH * 10) + 6)) = CYAN;
    (*(char*)(COLOR_MEM + (SCREEN_WIDTH * 11) + 6)) = CYAN;

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
    (*(char*)(COLOR_MEM + (SCREEN_WIDTH * 9) + 15)) = BLUE;
    (*(char*)(COLOR_MEM + (SCREEN_WIDTH * 10) + 15)) = BLUE;

    (*(char*)(COLOR_MEM + (SCREEN_WIDTH * 8) + 16)) = CYAN;
    (*(char*)(COLOR_MEM + (SCREEN_WIDTH * 9) + 16)) = CYAN;
    (*(char*)(COLOR_MEM + (SCREEN_WIDTH * 10) + 16)) = CYAN;
    (*(char*)(COLOR_MEM + (SCREEN_WIDTH * 11) + 16)) = CYAN;
    (*(char*)(COLOR_MEM + (SCREEN_WIDTH * 8) + 17)) = CYAN;
    (*(char*)(COLOR_MEM + (SCREEN_WIDTH * 9) + 17)) = CYAN;
    (*(char*)(COLOR_MEM + (SCREEN_WIDTH * 10) + 17)) = CYAN;
    (*(char*)(COLOR_MEM + (SCREEN_WIDTH * 11) + 17)) = CYAN;

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

    // (*(char*)(SCREEN_MEM + (SCREEN_WIDTH * 4) + 5)) = ' ';
    // (*(char*)(SCREEN_MEM + (SCREEN_WIDTH * 15) + 5)) = ' ';
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

    // (*(char*)(SCREEN_MEM + (SCREEN_WIDTH * 4) + 18)) = ' ';
    // (*(char*)(SCREEN_MEM + (SCREEN_WIDTH * 15) + 18)) = ' ';
}

void drawLeft(void){
    // drawSquare(1, 2, 2, 17, BLOCK_TILE_CHR, WHITE);
    cvblock(1, 2, 16);
    cvblock(2, 3, 14);
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
    // drawSquare(21, 2, 2, 17, BLOCK_TILE_CHR, WHITE);
    cvblock(22, 2, 16);
    cvblock(21, 3, 14);
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
    char playerpos = (playery << 4) + playerx; // we can do a shift left since the width of the map is always 16
    char left[5], right[5], front[4];
    char wall_left[5], wall_right[5], wall_front[4];
    char i;
    switch(direction){
        case NORTH:
            front[0] = playerpos - 16;
            front[1] = playerpos - 32;
            front[2] = playerpos - 48;
            front[3] = playerpos - 64;
            left[0] = playerpos - 1;
            left[1] = playerpos - 17;
            left[2] = playerpos - 33;
            left[3] = playerpos - 49;
            left[4] = playerpos - 65;
            right[0] = playerpos + 1;
            right[1] = playerpos - 15;
            right[2] = playerpos - 31;
            right[3] = playerpos - 47;
            right[4] = playerpos - 63;
            break;
        case EAST:
            front[0] = playerpos + 1;
            front[1] = playerpos + 2;
            front[2] = playerpos + 3;
            front[3] = playerpos + 4;
            left[0] = playerpos - 16;
            left[1] = playerpos - 15;
            left[2] = playerpos - 14;
            left[3] = playerpos - 13;
            left[4] = playerpos - 12;
            right[0] = playerpos + 16;
            right[1] = playerpos + 17;
            right[2] = playerpos + 18;
            right[3] = playerpos + 19;
            right[4] = playerpos + 20;
            break;
        case SOUTH:
            front[0] = playerpos + 16;
            front[1] = playerpos + 32;
            front[2] = playerpos + 48;
            front[3] = playerpos + 64;
            left[0] = playerpos + 1;
            left[1] = playerpos + 17;
            left[2] = playerpos + 33;
            left[3] = playerpos + 49;
            left[4] = playerpos + 65;
            right[0] = playerpos - 1;
            right[1] = playerpos + 15;
            right[2] = playerpos + 31;
            right[3] = playerpos + 47;
            right[4] = playerpos + 63;
            break;
        case WEST:
            front[0] = playerpos - 1;
            front[1] = playerpos - 2;
            front[2] = playerpos - 3;
            front[3] = playerpos - 4;
            left[0] = playerpos + 16;
            left[1] = playerpos + 15;
            left[2] = playerpos + 14;
            left[3] = playerpos + 13;
            left[4] = playerpos + 12;
            right[0] = playerpos - 16;
            right[1] = playerpos - 17;
            right[2] = playerpos - 18;
            right[3] = playerpos - 19;
            right[4] = playerpos - 20;
            break;
    }

    // Precompute wall presence and boundaries
    for (i = 0; i < 5; i++) {
        wall_left[i] = (test_maze_data[left[i]] == 1)
            || (direction == NORTH && playerx == 0)
            || (direction == EAST && playery == 0)
            || (direction == SOUTH && playerx == 15)
            || (direction == WEST && playery == 15);
        wall_right[i] = (test_maze_data[right[i]] == 1)
            || (direction == NORTH && playerx == 15)
            || (direction == EAST && playery == 15)
            || (direction == SOUTH && playerx == 0)
            || (direction == WEST && playery == 0);
    }
    for (i = 0; i < 4; i++) {
        wall_front[i] = (test_maze_data[front[i]] == 1)
            || (direction == NORTH && playery == i)
            || (direction == EAST && playerx == 15 - i)
            || (direction == SOUTH && playery == 15 - i)
            || (direction == WEST && playerx == i);
    }

    drawSquare(1, 1, 22, 18, ' ', CYAN);

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
    char position = (playery << 4) + playerx;
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
    char position = (playery << 4) + playerx;
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