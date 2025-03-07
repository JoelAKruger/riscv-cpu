#include "mycpu.h"

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
    
    ClearConsole(&Console);
    for (int I = 0; ; I++)
    {
        ConsoleWrite(&Console, "Hello %d\n", I);
    }
}