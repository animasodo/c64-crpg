#ifndef _MAZE_H
#define _MAZE_H

extern char *mazeStack;
extern char mazeStackTop;

void pushTraverse(char value);
char popTraverse(void);

void generateMap(void);

void drawView(void);

char advance(void);

char retreat(void);

#endif