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

char mapWidth;
char mapHeight;
unsigned int mapLength;
char mapBuffer[1024]; // just enough for 32x32 tiles

unsigned long timer;
char frameCount;
char tempStack[STACK_SIZE];

const unsigned int yScreenArray[] = {0, 40, 80, 120, 160, 200, 240, 280, 320, 360, 400, 440, 480, 520, 560, 600, 640, 680, 720, 760, 800, 840, 880, 920, 960};