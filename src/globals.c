#include "globals.h"

char camerax;
char cameray;
dir direction; // so apparently enums ARE optimized in newer builds of cc65, they don't use 16-bit ints unless needed

char playerName[10];
char playerx;
char playery;
char playerHealth;
char playerStamina;
char playerPower;
unsigned int playerExp;
unsigned int gold;
char species;

char mapId;
char mapWidth;
char mapHeight;
unsigned int mapLength;
char mapBuffer[1024]; // just enough for 32x32 tiles
warp warps;
door doors;

char frameCount;
char tempStack[STACK_SIZE];
