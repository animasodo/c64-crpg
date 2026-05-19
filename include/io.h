#ifndef _IO_H
#define _IO_H

#include "globals.h"

#define scrollScreen() asm("jmp $E8EA")
#define delaySeconds(s) delayFrames(s * FPS)

extern char lastKey;
extern char textIndex;
extern char bufferPrompt[];

void delayFrames(char count);

void readString (char* buffer, char size);

unsigned int prompt(void);

void message(const char* format, ...);

void loadMapCompressed(const char *filename);

void saveData(char *filename);

void startTimer(void);

void writeTimer(void);

#endif