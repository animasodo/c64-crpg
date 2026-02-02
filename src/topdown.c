#include <peekpoke.h>
#include <cbm.h>
#include "globals.h"
#include "drawmap.h"
#include "ui.h"
#include "sprites.h"
#include "io.h"

void setCameraSprite(void){
    if(playerx > 5) {
        camerax = playerx - 5;
        setSpriteX(X_OFFSET + 88, 0);
    }else{
        camerax = 0;
        setSpriteX((X_OFFSET + 8) + (playerx << 4), 0);
    }
    if(playery > 4) {
        cameray = playery - 4;
        setSpriteY(Y_OFFSET + 72, 0);
    }else{
        cameray = 0;
        setSpriteY((Y_OFFSET + 8) + (playery << 4), 0);
    }
}

char walk(void){
    unsigned int position = (playery * mapWidth) + playerx;
    char moved;
    switch(lastKey){
        case UP:
            if(mapBuffer[position - mapWidth] < 8){
                playery--;
                direction = NORTH;
                moved = 1;
            }
            break;
        case DOWN:
            if(mapBuffer[position + mapWidth] < 8){
                playery++;
                direction = SOUTH;
                moved = 1;
            }
            break;
        case LEFT:
            if(mapBuffer[position - 1] < 8){
                playerx--;
                direction = WEST;
                moved = 1;
            }
            break;
        case RIGHT:
            if(mapBuffer[position + 1] < 8){
                playerx++;
                direction = EAST;
                moved = 1;
            }
            break;
    }
    
    if(moved) {
        if(direction == NORTH || direction == EAST) { // set walking sprite
            setSpritePointer(0xCCC0, 0);
        } else {
            setSpritePointer(0xCC80, 0);
        }

        delayFrames(3);

        setCameraSprite();
        printDirection();
        drawmap();

        if(direction == NORTH || direction == EAST) { // set normal sprite
            setSpritePointer(0xCC40, 0);
        } else {
            setSpritePointer(0xCC00, 0);
        }

        return 0;
    }
    return 1;
}