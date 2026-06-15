#ifndef _IO_H
#define _IO_H

#include "globals.h"

#define scrollScreen() asm("jmp $E8EA")
#define delaySeconds(s) delayFrames(s * FPS)

#define closeDevice() cbm_k_clrch(); cbm_close(LFN);
#define openFile(filename) if(cbm_open(LFN, FLOPPY, 2, filename) != 0){ messagef(diskErrorMessage); closeDevice(); }

extern char lastKey;
extern char bufferPrompt[];

void readString (char* buffer, char size);

void messagef(const char* format, ...); // formatted

void message(const char* message); // unformatted. just a wrapper for simplewrite, really

void saveData(char *filename);

void loadCharset(void);

// assembly functions

void load_map_compressed(char id);

void delayFrames(char count);

char *get_filename(char id);

#endif