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
char keys;

char mapId;
char mapWidth;
char mapHeight;
unsigned int mapLength;
char mapBuffer[4096]; // 4 kilobytes oughta be enough for anybody!
warp warps;
door doors;

char itoa_buffer[7]; // 6 digits + null

char frameCount;
char playerInput;
