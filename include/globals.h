#ifndef GLOBALS_H
#define GLOBALS_H

typedef enum {NORTH, EAST, SOUTH, WEST} dir;

typedef struct {
    char width;
    char height;
    char data[];
} Map;

#define UP 145
#define DOWN 17
#define LEFT 157
#define RIGHT 29

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
extern unsigned int mapLength;
extern char mapBuffer[1024];

extern unsigned long timer;
extern char frameCount;
extern char tempStack[STACK_SIZE];

extern const unsigned int yScreenArray[];

#endif