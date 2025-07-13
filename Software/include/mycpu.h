#pragma once
#include <stdint.h>
#include <stdarg.h>

typedef uint8_t  u8;
typedef int8_t   i8;
typedef uint16_t u16;
typedef int16_t  i16;
typedef uint32_t u32;
typedef int32_t  i32;
typedef uint64_t u64;
typedef int64_t  i64;
typedef float  f32;
typedef double f64;

typedef struct
{
    int Width, Height;
    int PixelsPerScanline;
	u8* Pixels;
} screen_buffer;

typedef struct
{
    screen_buffer* Output;
    u8 Color;
    u8 ColorBg;
    
    int AtX, AtY;
} console;

#define CONSOLE_CHAR_WIDTH 8
#define CONSOLE_CHAR_HEIGHT 16

enum
{
	COLOR_BLACK = 0b00000000,
	COLOR_RED   = 0b11100000,
	COLOR_GREEN = 0b00011100,
	COLOR_BLUE  = 0b00000011,
	COLOR_WHITE = 0b11111111,
    COLOR_DARKBLUE = 0b00000010,
    COLOR_DARKGREEN = 0b00010000,
    COLOR_GREY = 0b10010010,
    COLOR_DARKYELLOW = 0b10010000
};

typedef struct
{
    u16 Magic;
    u8 Mode;
    u8 CharSize;
    
    u8 Data[]; //Flexible array member
}  pc_screen_font_v1;
