#ifndef GLOBALS_H
#define GLOBALS_H

typedef enum {NORTH, EAST, SOUTH, WEST} dir;

typedef struct {
    char id[8];
    char src_x[8];
    char src_y[8];
    char dst_x[8];
    char dst_y[8];
} warp;

typedef struct {
    char x[8];
    char y[8];
} door;

#define FPS 50

#define LFN 2
#define FLOPPY 8

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
extern char keys;

extern char mapId;
extern char mapWidth;
extern char mapHeight;
extern char mapBuffer[4096];
extern warp warps;
extern door doors;

extern char itoa_buffer[7];

extern char frameCount;
extern char playerInput;

extern char byte0, byte1, byte2, byte3, byte4, byte5, byte6, byte7, idx8, jdx8;
extern unsigned int uint0, uint1, uint2, uint3, idx16, jdx16, ptr;
extern int int0, int1;

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
#pragma zpsym("idx8");
#pragma zpsym("jdx8");
#pragma zpsym("idx16");
#pragma zpsym("jdx16");
#pragma zpsym("ptr");

#endif