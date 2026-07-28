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
#include "text.h"
#include "strings.h"
#include "general.h"
#include "globals.h"

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
    printxy(0, 24, "Loading...");

    loadCharset();
    clrscr();

    createPlayer();

    playerHealth = 34;
    playerStamina = 67;
    playerExp = 65535U;
    drawMainUI();

    load_map_compressed(0);

    setSpritePointer(0xCC00, 0);
    // the sprite pointer is located at (screen base + 1016)

    setSpriteMulticolorProperties(0b11111111);
    setSpriteColor(CYAN, 0);
    setSpriteMulticolor(WHITE, 0);
    setSpriteMulticolor(BLUE, 1);

    setSpriteVisibility(0b00000001);
    setSpriteX(X_OFFSET + 88, 0);
    setSpriteY(Y_OFFSET + 72, 0);

    loadSprite(0xCC00, lizard_sprite_0);
    loadSprite(0xCC40, lizard_sprite_1);
    loadSprite(0xCC80, lizard_sprite_0_walking);
    loadSprite(0xCCC0, lizard_sprite_1_walking);

    playerx = 9;
    playery = 5;
    setCameraSprite();

    drawmap();

    initIrq();

    while(1){
        cbm_k_scnkey();
        lastKey = cbm_k_getin();
        
        if((playerInput & 0x0F) != 0){
            walk();
        }

        switch(lastKey){
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
                ptr = ((mapWidth * byte1) + byte0) + (unsigned int)((char*)mapBuffer);
                asm("ldy #$00");
                asm("lda (_ptr),y");
                asm("sta _byte0");
                if(byte0 == 0x1F){
                    asm("lda #$03");
                    asm("sta (_ptr),y");
                    message(door_open);
                    drawmap();
                }else{
                    message(no_door);
                }
                break;
            case 'q':
                message(save_to);
                readString(2);
                if(bufferPrompt[0] != '8' && bufferPrompt[0] != '9'){
                    message(device_number_error);
                }else{
                    message(save_to_as);
                    readString(13);
                    saveData(strlower(bufferPrompt)); // not working correctly yet, just a test for now
                }
                break;
            case 'w':
                message(load_from);
                readString(2);
                if(bufferPrompt[0] != '8' && bufferPrompt[0] != '9'){
                    message(device_number_error);
                }else{
                    message(load_from_as);
                    readString(13);
                    // loadData(strlower(bufferPrompt)); // to be added
                }
                break;
            case 's':
                clear_viewport();
                setSpriteVisibility(0x00);
                
                textcolor(YELLOW);
                printxy(2, 2, "Storage");

                do{
                    lastKey = cgetc();
                }while(lastKey != 's');

                drawmap();
                setSpriteVisibility(0xFF);
                break;
        }
    }
}