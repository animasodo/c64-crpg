#include <stdio.h>
#include <conio.h>
#include <ctype.h>
#include <stdlib.h>
#include <string.h>
#include <peekpoke.h>
#include <cbm.h>
#include <c64.h>
#include "io.h"
#include "ui.h"
#include "globals.h"

#define ENTER 13
#define F1 133
#define SCREEN_WIDTH 40
#define SCREEN_HEIGHT 25

#define MAP_DATA 0
#define SAVE_DATA 1

char lastKey, textIndex;
char bufferPrompt[20];

char *diskErrorMessage = "Disk error.";
char *mapErrorMessage = "Not a map.";

void delayFrames(char count) {
    while (count--) {
        waitvsync();
    }
}

void readString (char* buffer, char size){
    char i = 0;
    unsigned char w, x, y;
    char c;

    if (buffer && size > 1) {   // if buffer is not null and size is bigger than 1
        screensize (&w, &y);
        --w;
        cursor (1);
        for (buffer[i] = '\0', --size; i < size; ) {
            c = cgetc ();
            if(c == ENTER && i){    // if enter pressed and i not null
                asm("jsr $E87C"); // do new line
                cputs ("\r");
                break;
            }
            if(c == '\b' && i) {    // if backspace pressed and i not null
                /* Remove the character */
                buffer[--i] = '\0';
                /* Logic to account for line wrapping */
                y = wherey ();
                x = wherex ();
                y = x? y: y - 1;    // account for cursor being at 0
                x = x? x - 1: w;
                /* Clear the character */
                gotoxy (x, y);
                cputc (' ');
                gotoxy (x, y);
            // Handle regular characters
            } else if ((char)isprint (c) && i < (size - 1)) {   // if character printable
                cputc (c);              // type character
                buffer[i] = c;          // set i in string to character
                buffer[++i] = '\0';
            }
        }
    }
}

void message(const char* format, ...){
    va_list args;
    char i, y = 20;
    char out[8];

    cclearxy(1, 20, 22); // clear screen
    cclearxy(1, 21, 22);
    cclearxy(1, 22, 22);

    va_start(args, format);
    gotoxy(1, y);
    for(i = 0; ; i++){
        if(isprint(format[i])){
            if(format[i] == '%'){ // hrm? is this a data type?
                switch(format[++i]){
                    case 'd': // why yes it is!
                        itoa(va_arg(args, int), out, 10);
                        cputs(out);
                        break;
                    case 'c':
                        cputc(va_arg(args, char));
                        break;
                    case '%':
                        cputc('%');
                        break;
                }
            }else{
                cputc(format[i]);
            }
        }else if(format[i] == '\n'){
            gotoxy(1, ++y);
        }else if(format[i] == 0){ // null detected. abort! abort!
            break;
        }
    }
    va_end(args);
}

void loadMapCompressed(char *filename){
    openFile(filename);
    cbm_k_chkin(LFN); // set LFN 2 as active input channel

    if(cbm_k_basin() != 0x4D || cbm_k_basin() != 0x50){ // check header
        message(mapErrorMessage);
        closeDevice();
        return;
    }

    mapWidth = cbm_k_basin();
    mapHeight = cbm_k_basin();

    cbm_k_basin();
    asm("sta _uint1");
    cbm_k_basin();
    asm("sta _uint1+1"); // get compressed length
    
    idx16 = 0; // uncompressed index
    jdx16 = 0; // compressed index

    while(jdx16 < uint1){ // get map data
        byte0 = cbm_k_basin(); // byte0: byte

        byte1 = byte0 & 0x0F; // byte1: tile
        byte2 = ((byte0 & 0xF0) >> 4) + 1; // byte2: length
        memset(&mapBuffer[idx16], byte1, byte2);
        idx16 += byte2;
        jdx16++;
    }

    closeDevice();
}

void saveData(char *filename){
    char testData[] = "\1test";

    openFile(filename);
    cbm_write(LFN, testData, 6); // testing data saving
    closeDevice();
}
