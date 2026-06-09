#include <peekpoke.h>
#include <cbm.h>
#include "globals.h"
#include "drawmap.h"
#include "ui.h"
#include "sprites.h"
#include "io.h"
#include "get_filename.h"

#define position uint0

char *doorOpen = "Door open!";
char *doorUnlocked = "Door unlocked!";
char *noDoor = "No door here!";

char findDoor(char x, char y){
    for(byte2 = 0; byte2 < 8; byte2++){
        if(doors.x[byte2] == x && doors.y[byte2] == y){
            return byte2;
        }
    }
    return 255; // for now this will do
}

void setCameraSprite(void){
    if(playerx > 6 && playerx < (mapWidth - 7)) {
        camerax = playerx - 6;
        setSpriteX(X_OFFSET + 104, 0);
    }else if(playerx >= (mapWidth - 7)){
        camerax = (mapWidth - 13);
        setSpriteX((X_OFFSET + 8) + ((playerx - (mapWidth - 13)) << 4), 0);
    }else{
        camerax = 0;
        setSpriteX((X_OFFSET + 8) + (playerx << 4), 0);
    }

    if(playery > 4 && playery < (mapHeight - 5)) {
        cameray = playery - 4;
        setSpriteY(Y_OFFSET + 72, 0);
    }else if(playery >= (mapHeight - 5)){
        cameray = (mapHeight - 9);
        setSpriteY((Y_OFFSET + 8) + ((playery - (mapHeight - 9)) << 4), 0);
    }else{
        cameray = 0;
        setSpriteY((Y_OFFSET + 8) + (playery << 4), 0);
    }
}

char walk(void){
    position = (playery * mapWidth) + playerx;

    switch(lastKey){
        case UP:
            direction = NORTH;
            if(mapBuffer[position - mapWidth] < 8 && findDoor(playerx, playery - 1) == 255){
                playery--;
                byte0 = 1;
            }
            break;
        case DOWN:
            direction = SOUTH;
            if(mapBuffer[position + mapWidth] < 8 && findDoor(playerx, playery + 1) == 255){
                playery++;
                byte0 = 1;
            }
            break;
        case LEFT:
            direction = WEST;
            if(mapBuffer[position - 1] < 8 && findDoor(playerx - 1, playery) == 255){
                playerx--;
                byte0 = 1;
            }
            break;
        case RIGHT:
            direction = EAST;
            if(mapBuffer[position + 1] < 8 && findDoor(playerx + 1, playery) == 255){
                playerx++;
                byte0 = 1;
            }
            break;
    }

    if(byte0) {
        if(direction == NORTH || direction == EAST) { // set walking sprite
            setSpritePointer(0xCCC0, 0);
        } else {
            setSpritePointer(0xCC80, 0);
        }

        delayFrames(3);

        for(byte1 = 0; byte1 < 8; byte1++){
            if(playerx == warps.src_x[byte1] && playery == warps.src_y[byte1]){
                if(mapId != warps.id[byte1]){
                    loadMapCompressed(warps.id[byte1]);
                }
                playerx = warps.dst_x[byte1];
                playery = warps.dst_y[byte1];
                break;
            }
        }

        setCameraSprite();
        printDirection();
        drawmap();
        
        byte3 = 0; // sprite visibility mask
        byte4 = 0; // door sprite counter
        for(byte2 = 0; byte2 < 8; byte2++){
            if(doors.x[byte2] != 0 && doors.y[byte2] != 0 &&
                (doors.x[byte2] >= camerax && doors.x[byte2] < camerax + VIEWPORT_WIDTH) &&
                (doors.y[byte2] >= cameray && doors.y[byte2] < cameray + VIEWPORT_HEIGHT)){
                if(byte4 < 2){
                    // door is visible, display sprite
                    byte5 = 6 + byte4; // use sprites 6 or 7
                    setSpriteX((X_OFFSET + 8) + ((doors.x[byte2] - camerax) << 4), byte5);
                    setSpriteY((Y_OFFSET + 8) + ((doors.y[byte2] - cameray) << 4), byte5);
                    byte3 |= (1 << byte5); // set visibility bit for this sprite
                    byte4++; // increment door counter
                }
            }
        }
        setSpriteVisibility(0b00000001 | byte3); // sprite 0 (player) + visible doors

        if(direction == NORTH || direction == EAST) { // set normal sprite
            setSpritePointer(0xCC40, 0);
        } else {
            setSpritePointer(0xCC00, 0);
        }

        return 0;
    }
    return 1;
}