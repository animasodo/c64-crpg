#include <peekpoke.h>
#include <cbm.h>
#include "globals.h"
#include "drawmap.h"
#include "ui.h"
#include "sprites.h"
#include "io.h"
#include "topdown.h"

const char *doorOpen = "Door open!";
const char *doorUnlocked = "Door unlocked!";
const char *noDoor = "No door here!";

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
