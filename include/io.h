#ifndef _IO_H
#define _IO_H

#include "globals.h"

#define scrollScreen() asm("jmp $E8EA")

extern char lastKey;
extern char keyMode;
extern char textIndex;

void delayFrames(char count);

void readString (char* buffer, char size);

unsigned int prompt(void);

void message(const char* format, ...);

unsigned int parse(void);

void loadMapCompressed(const char *in, char width, char height);

void startTimer(void);

void writeTimer();

#endif