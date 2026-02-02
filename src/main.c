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
#include "map.h"
#include "maze.h"
#include "maze_data.h"
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
    char c, o, update;

    direction = NORTH;
    playerx = 1;
    playery = 3;

    while(1){
        printDirection();
        if(!update || o) drawView();
        update = 1;
        
        if(keyMode){ // direct mode
            c = cgetc();
            switch(c){
                case 's':
                    message("Stats are not yet\nimplemented!");
                    break;
        }
        }else{ // command mode
            // c = prompt(text);
            // o = parse(text);
            switch(o){
                case 1:
                    message("What exactly?");
                    break;
                case 2:
                    message("There's no door or\nchest nearby.");
                    break;
                case 3:
                    message("Enter where?");
                    break;
            }
        }
        switch(c){
            case UP:
                update = advance();
                break;
            case DOWN:
                update = retreat();
                break;
            case LEFT:
                update = 0;
                if((direction - 1) < 0){
                    direction = 3;
                }else{ direction--; }
                break;
            case RIGHT:
                update = 0;
                if((direction + 1) > 3){
                    direction = 0;
                }else{ direction++; }
                break;
            case 133:
                keyMode = keyMode? 0 : 1;
                break;
        }
    }
}

void main(void){
    char parseOut;

    c64Setup();
    createPlayer();
    drawMainUI();

    loadMapCompressed(OVERWORLD, OVERWORLD_WIDTH, OVERWORLD_HEIGHT);

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
        }else if(lastKey == CH_F1){
            if(keyMode){
                keyMode = 0;
                cursor(1);
            }else{
                keyMode = 1;
                cursor(0);
                cclearxy(3, 23, 20);
                gotox(3);
                textIndex = 0;
            }
        }

        if(keyMode){ // direct mode
            switch(lastKey){
                case 's':
                    message("Stats are not yet\nimplemented!");
                    break;
        }
        }else{ // command mode
            gotoxy(3 + textIndex, 23);
            parseOut = prompt();
            switch(parseOut){
                case 1:
                    message("What exactly?");
                    break;
                case 2:
                    message("There's no door or\nchest nearby.");
                    break;
                case 3:
                    // message("Enter where?");
                    dungeon();
                    break;
                case 8:
                    message("This is not\nimplemented just yet.");
                    break;
            }
        }
    }
}