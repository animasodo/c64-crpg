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
#include "get_filename.h"
#include "simplewrite.h"
#include "globals.h"

#define ENTER 13
#define F1 133
#define SCREEN_WIDTH 40
#define SCREEN_HEIGHT 25

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
    char out[7];

    cclearxy(1, 20, 26); // clear screen
    cclearxy(1, 21, 26);
    cclearxy(1, 22, 26);

    va_start(args, format);
    gotoxy(1, y);
    for(i = 0; ; i++){
        if(isprint(format[i])){
            if(format[i] == '%'){ // hrm? is this a data type?
                switch(format[++i]){
                    case 'd': // why yes it is!
                        cputs(itoa(va_arg(args, int), out, 10));
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

void saveData(char *filename){
    char testData[] = "\1test";

    openFile(filename);
    cbm_write(LFN, testData, 6); // testing data saving
    closeDevice();
}

void loadCharset(void){
    cbm_open(LFN, FLOPPY, 2, "chrset");
    cbm_read(LFN, (void*)0xC000, 2048);
    cbm_close(LFN);

    (*(char*)0xDD00U) = (*(char*)0xDD00U) & 0b11111100; // CIA 2 port A serial bus, change VIC-II bank to 3 (00)

    // the VIC-II, responsible for graphics, can only address 16KB, so everything needed at one time must fit inside that
    // from sta.c64.org:
    // %00, 0: Bank #3, 0xC000-0xFFFF, 49152-65535.
    // %01, 1: Bank #2, 0x8000-0xBFFF, 32768-49151.
    // %10, 2: Bank #1, 0x4000-0x7FFF, 16384-32767.
    // %11, 3: Bank #0, 0x0000-0x3FFF, 0-16383.

    (*(char*)0xD018U) = 0b00100000;
    // four most significant bits multiplied by 1024 are the address of screen character ram
    // in here it's set to 3, which gives us an offset of 2048
    // three middle bits multiplied by 2048 are the start of the charset
    
    (*(char*)0x0288) = 0xC8; // set cursor
}
