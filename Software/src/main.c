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
    

    
    screen_buffer Window = {
        .Width = 60,
        .Height = 60,
        .PixelsPerScanline = 320,
        .Pixels = (u8*)(0x20000 + 10 * 320 + 10)
    };

    DrawMandelbrot(&Screen);

	   console Console = {
        .Output = &Window,
        .Color = COLOR_WHITE,
        .ColorBg = COLOR_BLACK
    };
	
    ConsoleWrite(&Console, "Done");
}