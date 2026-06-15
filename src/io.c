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
#include "simplewrite.h"
#include "globals.h"

#define ENTER 13
#define F1 133
#define SCREEN_WIDTH 40
#define SCREEN_HEIGHT 25

char lastKey;
char bufferPrompt[20];

char *diskErrorMessage = "Disk error.";
char *mapErrorMessage = "Not a map.";

void readString (char* buffer, char size){
    idx8 = 0;

    if (buffer && size > 1) {   // if buffer is not null and size is bigger than 1
        cursor (1);
        for (buffer[idx8] = '\0', --size; idx8 < size; ) {
            byte0 = cgetc ();
            if(byte0 == ENTER && idx8){    // if enter pressed and idx8 not null
                asm("jsr $E87C"); // do new line
                cputs ("\r");
                break;
            }
            if(byte0 == '\b' && idx8) {    // if backspace pressed and idx8 not null
                /* Remove the character */
                buffer[--idx8] = '\0';
                /* Logic to account for line wrapping */
                byte3 = wherey ();
                byte2 = wherex ();
                byte3 = byte2? byte3: byte3 - 1;    // account for cursor being at 0
                byte2 = byte2? byte2 - 1: (SCREEN_WIDTH - 1);
                /* Clear the character */
                gotoxy (byte2, byte3);
                cputc (' ');
                gotoxy (byte2, byte3);
            // Handle regular characters
            } else if ((char)isprint (byte0) && idx8 < (size - 1)) {   // if character printable
                cputc (byte0);              // type character
                buffer[idx8] = byte0;          // set idx8 in string to character
                buffer[++idx8] = '\0';
            }
        }
    }
}

void messagef(const char* format, ...){
    va_list args;
    jdx8 = 20;

    textcolor(WHITE);
    cclearxy(1, 20, 26); // clear screen
    cclearxy(1, 21, 26);
    cclearxy(1, 22, 26);

    va_start(args, format);
    gotoxy(1, jdx8);
    for(idx8 = 0; ; idx8++){
        if(isprint(format[idx8])){
            if(format[idx8] == '%'){ // hrm? is this a data type?
                switch(format[++idx8]){
                    case 'd': // why yes it is!
                        cputs(itoa(va_arg(args, int), (char*)byte0, 10));
                        break;
                    case 'c':
                        cputc(va_arg(args, char));
                        break;
                    case '%':
                        cputc('%');
                        break;
                }
            }else{
                cputc(format[idx8]);
            }
        }else if(format[idx8] == '\n'){
            gotoxy(1, ++jdx8);
        }else if(format[idx8] == 0){ // null detected. abort! abort!
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
