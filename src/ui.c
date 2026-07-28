#include <stdio.h>
#include <string.h>
#include <c64.h>
#include <conio.h>
#include <peekpoke.h>
#include <6502.h>
#include <ctype.h>
#include <stdlib.h>
#include "io.h"
#include "text.h"
#include "strings.h"
#include "globals.h"
#include "ui.h"

#define SCREEN_MEM 0xC800
#define COLOR_MEM 0xD800
#define SCREEN_WIDTH 40

const char dirChar[4] = {0x61, 0x62, 0x63, 0x64};
