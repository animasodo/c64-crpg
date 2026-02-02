#ifndef _SPRITES_H
#define _SPRITES_H

#define X_OFFSET 24
#define Y_OFFSET 50

#define loadSprite(address, sprite) memcpy((void*)address, sprite, 63)

#define setSpritePointer(pointer, index) POKE(0xCBF8 + index, (pointer - 0xC000) / 64)
#define setSpriteX(x, index) POKE(0xD000 + (index * 2), x)
#define setSpriteY(y, index) POKE(0xD001 + (index * 2), y)

#define setSpriteColor(color, index) POKE(0xD027 + index, color)
/*Color is, well, the color. Multicolor is either 0 or 1. Index is the sprite index.*/
#define setSpriteMulticolor(color, multicolor, index) POKE((0xD025 + multicolor) + (index * 2), color)

/*Lowest bit is sprite 0 and highest bit is sprite 7.*/
#define setSpriteVisibility(value) POKE(0xD015, value)
/*Lowest bit is sprite 0 and highest bit is sprite 7.*/
#define setSpriteMulticolorProperties(value) POKE(0xD01C, value)

#endif