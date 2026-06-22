#include <stdio.h>
#include <string.h>
#include <c64.h>
#include <conio.h>
#include <peekpoke.h>
#include <6502.h>
#include <ctype.h>
#include <stdlib.h>
#include "io.h"
#include "ui.h"
#include "drawmap.h"
#include "sprites.h"
#include "topdown.h"
#include "interrupts.h"
#include "simplewrite.h"
#include "globals.h"

const char *deviceNotValid = "Not a valid\ndevice number.";

void createPlayer(void){
    drawBox(0, 0, 40, 25);
    textcolor(YELLOW);
    simplewritexy(2, 2, "Welcome to the CRPG demo!");
    simplewritexy(2, 4, "(N)ew game or (L)oad game? ");
    textcolor(WHITE);
    while(lastKey != 'n' && lastKey != 'l'){ // loading hasn't been implemented yet lolololol
        lastKey = cgetc();
    }
    cputc(lastKey);
    textcolor(YELLOW);
    simplewritexy(2, 6, "Name of the player: ");
    textcolor(WHITE);
    readString(playerName, 10);
}

void main(void){
    // init
    byte0 = PEEK(0xD016);
    clrscr();
    POKE(MULTICOLOR_0, WHITE);
    POKE(MULTICOLOR_1, BROWN);
    POKE(BORDER_COLOR, BLACK);
    POKE(BG_COLOR, BLACK);
    textcolor(WHITE);
    POKE(0xD016, byte0 | 0x10); // set multicolor character mode
    cputsxy(0, 24, "Loading...");

    loadCharset();
    clrscr();

    createPlayer();
    drawMainUI();
    
    load_map_compressed(0);

    setSpritePointer(0xCC00, 0);
	// the sprite pointer is located at (screen base + 1016)

	setSpriteMulticolorProperties(0b11111111);
	setSpriteColor(CYAN, 0);
	setSpriteMulticolor(WHITE, 0);
	setSpriteMulticolor(BLUE, 1);

	setSpritePointer(0xCD00, 6);
	setSpriteColor(YELLOW, 6);

	setSpritePointer(0xCD00, 7);
	setSpriteColor(YELLOW, 7);

	setSpriteVisibility(0b00000001);
	setSpriteX(X_OFFSET + 88, 0);
	setSpriteY(Y_OFFSET + 72, 0);

    loadSprite(0xCC00, lizard_sprite_0);
    loadSprite(0xCC40, lizard_sprite_1);
    loadSprite(0xCC80, lizard_sprite_0_walking);
    loadSprite(0xCCC0, lizard_sprite_1_walking);
    loadSprite(0xCD00, door_sprite);

    playerx = 9;
    playery = 5;
    setCameraSprite();

    drawmap();

    initIrq();

    while(1){
        cbm_k_scnkey();
        lastKey = cbm_k_getin();
        
        if(lastKey == UP || lastKey == DOWN || lastKey == LEFT || lastKey == RIGHT) {
            walk();
        }

        switch(lastKey){
            case 's':
                message("Stats are not yet\nimplemented!");
                break;
            case 'o':
                byte0 = playerx;
                byte1 = playery;
                switch(direction){
                    case NORTH:
                        byte1 -= 1;
                        break;
                    case EAST:
                        byte0 += 1;
                        break;
                    case SOUTH:
                        byte1 += 1;
                        break;
                    case WEST:
                        byte0 -= 1;
                        break;
                }
                if((byte2 = findDoor(byte0, byte1)) != 255){ // could replace this with a bmi if i rewrote it in assembly
                    doors.x[byte2] = 0;
                    doors.y[byte2] = 0;
                    message(doorOpen);
                    drawmap();
                }else{
                    message(noDoor);
                }
                break;
            case 'q':
                message("Save to (8,9)? ");
                readString(bufferPrompt, 3);
                if(bufferPrompt[0] != '8' && bufferPrompt[0] != '9'){
                    message(deviceNotValid);
                }else{
                    messagef("Save in %c as?\n", bufferPrompt[0]);
                    readString(bufferPrompt, 14);
                    saveData(strlower(bufferPrompt)); // not working correctly yet, just a test for now
                }
                break;
            case 'w':
                message("Load from (8,9)? ");
                readString(bufferPrompt, 3);
                if(bufferPrompt[0] != '8' && bufferPrompt[0] != '9'){
                    message(deviceNotValid);
                }else{
                    messagef("Load from %c as?\n", bufferPrompt[0]);
                    readString(bufferPrompt, 14);
                    // loadData(strlower(bufferPrompt)); // to be added
                }
                break;
        }
    }
}