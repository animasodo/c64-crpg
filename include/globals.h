#ifndef GLOBALS_H
#define GLOBALS_H

typedef enum {NORTH, EAST, SOUTH, WEST} dir;

#define UP 145
#define DOWN 17
#define LEFT 157
#define RIGHT 29

#define FPS 50

#define LFN 2
#define FLOPPY 8

#define STACK_SIZE 256

extern char playerName[10];
extern char playerx;
extern char playery;
extern char camerax;
extern char cameray;
extern dir direction;
extern char playerHealth;
extern char playerStamina;
extern char playerPower;
extern unsigned int playerExp;
extern unsigned int gold;

extern char species;

extern char mapWidth;
extern char mapHeight;
extern char mapBuffer[1024];

extern unsigned long timer;
extern char frameCount;
extern char tempStack[STACK_SIZE];

extern char byte0, byte1, byte2, byte3, byte4, byte5, byte6, byte7;
extern unsigned int uint0, uint1, uint2, uint3;
extern int int0, int1, int2, int3;

#pragma zpsym("byte0");
#pragma zpsym("byte1");
#pragma zpsym("byte2");
#pragma zpsym("byte3");
#pragma zpsym("byte4");
#pragma zpsym("byte5");
#pragma zpsym("byte6");
#pragma zpsym("byte7");
#pragma zpsym("uint0");
#pragma zpsym("uint1");
#pragma zpsym("uint2");
#pragma zpsym("uint3");
#pragma zpsym("int0");
#pragma zpsym("int1");
#pragma zpsym("int2");
#pragma zpsym("int3");

#endif