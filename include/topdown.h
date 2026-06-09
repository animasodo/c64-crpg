#ifndef _TOPDOWN_H
#define _TOPDOWN_H

extern char *doorOpen;
extern char *doorUnlocked;
extern char *noDoor;

char findDoor(char x, char y);

void setCameraSprite(void);

char walk(void);

#endif