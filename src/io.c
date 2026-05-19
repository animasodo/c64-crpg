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

char *mapErrorMessage = "Map error.";

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

static void itoa16(int val, char *buf){
    unsigned int u = (val < 0) ? -val : val;
    char tmp[6], j, i = 0;

    do {
        tmp[i++] = '0' + (u % 10);
        u /= 10;
    } while (u);

    if (val < 0) tmp[i++] = '-';

    /* reverse into buf */
    for (j = 0; j < i; ++j) buf[j] = tmp[i - 1 - j];
    buf[i] = '\0';
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
                        itoa16(va_arg(args, int), out);
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

void loadMapCompressed(const char *filename){
    // map format structure:
    // 2 bytes: header (MP)
    // 1 byte: width
    // 1 byte: height
    // 2 bytes: compressed map size
    // rest of the file: map data
    // will add more stuff to it later
    
    cbm_open(LFN, FLOPPY, 2, filename);
    cbm_k_chkin(LFN); // set LFN 2 as active input channel

    if(cbm_k_basin() != 0x4D || cbm_k_basin() != 0x50){ // check header
        message(mapErrorMessage);
        cbm_k_clrch();
        cbm_close(LFN);
        return;
    }

    mapWidth = cbm_k_basin();
    mapHeight = cbm_k_basin();

    cbm_k_basin();
    cbm_k_basin(); // skipping this for now
    
    for(uint0 = 0; uint0 < sizeof(mapBuffer); ){
        byte0 = cbm_k_basin();

        byte1 = byte0 & 0x0F;
        byte2 = ((byte0 & 0xF0) >> 4) + 1;
        memset(&mapBuffer[uint0], byte1, byte2);
        uint0 += byte2;
    }

    cbm_k_clrch(); // clean up
    cbm_close(LFN);
}

void saveData(char *filename){
    char testData[] = "\1test";

    if(cbm_open(LFN, FLOPPY, 2, filename) != 0){
        message("Couldn't open for saving.");
        cbm_close(LFN);
        return;
    }

    cbm_write(LFN, testData, 6); // testing data saving
    cbm_k_clrch(); // clean up
    cbm_close(LFN);
}

void startTimer(void) {
    CIA2.ta_lo = 0xFF; // set initial timer values
    CIA2.ta_hi = 0xFF; // (Note that timers count down to 0).
    CIA2.tb_lo = 0xFF;
    CIA2.tb_hi = 0xFF;
    CIA2.crb = 0x51; // start timer B counting Timer A rollovers
    CIA2.cra = 0x11; // start timer A in continuous mode
}

void writeTimer(void) {
    CIA2.cra = 0x00; // stop timers
    CIA2.crb = 0x40;
    timer = (unsigned long)0xFFFFFFFF - *(unsigned long*)(&CIA2.ta_lo);
}