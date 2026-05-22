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
#include "charset.h"
#include "maze.h"
#include "sprites.h"
#include "topdown.h"
#include "interrupts.h"
#include "lizard_sprite.h"
#include "globals.h"

#ifdef __C64__
void c64Setup(void){
    char videoMode = PEEK(0xD016);
    loadCharset();
    POKE(MULTICOLOR_0, WHITE);
    POKE(MULTICOLOR_1, BROWN);
    POKE(0xD016, videoMode | 0x10);
    POKE(BORDER_COLOR, BLACK);
    POKE(BG_COLOR, BLACK);
    textcolor(WHITE);
    clrscr();
}
#endif

void createPlayer(void){
    c64Setup();

    drawBox(0, 0, 40, 25);
    textcolor(YELLOW);
    cputsxy(2, 2, "Welcome to the CRPG demo!");
    cputsxy(2, 4, "(N)ew game or (L)oad game? ");
    textcolor(WHITE);
    while(lastKey != 'n' && lastKey != 'l'){ // loading hasn't been implemented yet lolololol
        lastKey = cgetc();
    }
    cputc(lastKey);
    textcolor(YELLOW);
    cputsxy(2, 6, "Name of the player: ");
    textcolor(WHITE);
    readString(playerName, 10);
}

void dungeon(){
    char o, update;

    setSpriteVisibility(0b00000000);

    generateMap();

    direction = NORTH;
    playerx = 0;
    playery = 0;

    while(1){
        printDirection();
        if(!update || o) { // some stuff to see how many cycles rewritten functions take
            drawView();
        }
        update = 1;

        cbm_k_scnkey();
        lastKey = cbm_k_getin();
        
        switch(lastKey){
            case 's':
                message("Stats are not yet\nimplemented!");
                break;
        }

        switch(lastKey){
            case UP:
                update = advance();
                delayFrames(7);
                break;
            case DOWN:
                update = retreat();
                delayFrames(7);
                break;
            case LEFT:
                update = 0;
                if((direction - 1) < 0){
                    direction = 3;
                }else{ direction--; }
                delayFrames(10);
                break;
            case RIGHT:
                update = 0;
                if((direction + 1) > 3){
                    direction = 0;
                }else{ direction++; }
                delayFrames(10);
                break;
        }
    }
}

void main(void){
    c64Setup();
    createPlayer();
    drawMainUI();

    _randomize();
    
    loadMapCompressed("overworld");

    setSpritePointer(0xCC00, 0);
	// the sprite pointer is located at (screen base + 1016)

	setSpriteMulticolorProperties(0b00000001);
	setSpriteColor(CYAN, 0);
	setSpriteMulticolor(WHITE, 0, 0);
	setSpriteMulticolor(BLUE, 1, 0);

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

    initIrq();

    while(1){
        drawmap();
        
        cbm_k_scnkey();
        lastKey = cbm_k_getin();
        
        if(lastKey == UP || lastKey == DOWN || lastKey == LEFT || lastKey == RIGHT) {
            walk();
        }

        switch(lastKey){
            case 's':
                message("Stats are not yet\nimplemented!");
                break;
            case 'q':
                message("Save to (8,9)? ");
                readString(bufferPrompt, 3);
                if(bufferPrompt[0] != '8' && bufferPrompt[0] != '9'){
                    message("Not a valid\ndevice number.");
                }else{
                    message("Save in %c as?\n", bufferPrompt[0]);
                    readString(bufferPrompt, 14);
                    saveData(strlower(bufferPrompt)); // not working correctly yet, just a test for now
                }
                break;
            case 'w':
                message("Load from (8,9)? ");
                readString(bufferPrompt, 3);
                if(bufferPrompt[0] != '8' && bufferPrompt[0] != '9'){
                    message("Not a valid\ndevice number.");
                }else{
                    message("Load from %c as?\n", bufferPrompt[0]);
                    readString(bufferPrompt, 14);
                    // loadData(strlower(bufferPrompt)); // to be added
                }
                break;
            case 'e':
                dungeon(); // for testing rn
                break;
            case 'o':
                message("Push what? ");
                readString(bufferPrompt, 5);
                pushTraverse(atoi(bufferPrompt));
                break;
            case 'p':
                message("%d", popTraverse());
                break;
        }
    }
}