#include "mycpu.c"
#include "graphics.c"

int __errno;

u32 BitCount(u32 Arg) {
    int Result;
    asm volatile ( ".insn r CUSTOM_0, 0, 0, %0, %1, x0" 
                  : "=r" (Result) : "r" (Arg) : );
    return Result;
}

int get_high_precision_timer() {
    return *(volatile int*) 0x40100;
}

void main(void)
{
	screen_buffer Screen = {
		.Width = 320,
		.Height = 240,
		.PixelsPerScanline = 320,
		.Pixels = (u8*)0x8000
	};

	console Console = {
		.Output = &Screen,
		.Color = COLOR_WHITE,
		.ColorBg = COLOR_BLACK
	};

	while (1)
	{
	ConsoleWrite(&Console, "Time: %d\n", get_high_precision_timer());
    	}

	DrawMandelbrot(&Screen);
}