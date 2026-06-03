#ifndef _IO_H
#define _IO_H

#include "globals.h"

#define scrollScreen() asm("jmp $E8EA")
#define delaySeconds(s) delayFrames(s * FPS)

#define closeDevice() cbm_k_clrch(); cbm_close(LFN);
#define openFile(filename) if(cbm_open(LFN, FLOPPY, 2, filename) != 0){ message(diskErrorMessage); closeDevice(); }

extern char lastKey;
extern char textIndex;
extern char bufferPrompt[];

void delayFrames(char count);

void readString (char* buffer, char size);

void message(const char* format, ...);

void loadMapCompressed(char *filename);

void saveData(char *filename);

void loadCharset(void);

#endif