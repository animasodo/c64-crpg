#ifndef _TOPDOWN_H
#define _TOPDOWN_H

extern const char *doorOpen;
extern const char *doorUnlocked;
extern const char *noDoor;

char findDoor(char x, char y);

void setCameraSprite(void);

void walk(void);

#endif