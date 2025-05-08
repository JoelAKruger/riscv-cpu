#include "mycpu.c"
#include "graphics.c"

int __errno;

void main(void)
{
	screen_buffer Screen = {
		.Width = 320,
		.Height = 240,
		.PixelsPerScanline = 320,
		.Pixels = (u8*)0x20000
	};
    
    console Console = {
        .Output = &Screen,
        .Color = COLOR_WHITE,
        .ColorBg = COLOR_BLACK
    };
    
    screen_buffer Window = {
        .Width = 60,
        .Height = 60,
        .PixelsPerScanline = 320,
        .Pixels = (u8*)(0x20000 + 90 * 320 + 130)
    };
    
    ClearConsole(&Console);
    
    DrawMandelbrot(&Screen);
}