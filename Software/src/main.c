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

void set_output(int value) {
    *(volatile int*) 0x40108 = value;
}

void SPIWriteThenRead(spi* SPI, u8* WriteData, u32 WriteByteCount, u8* ReadData, u32 ReadByteCount)
{
    // Assert chip select (active low)
    *SPI->CS = 0;
    
    // Write phase
    for (u32 i = 0; i < WriteByteCount; i++)
    {
        u8 data = WriteData[i];
        
        // Send 8 bits, MSB first
        for (int bit = 7; bit >= 0; bit--)
        {
            // Set MOSI
            *SPI->MOSI = (data >> bit) & 1;
            
            // Clock pulse
            *SPI->SCLK = 1;
            // Small delay for timing (may need adjustment based on hardware)
            for (volatile int d = 0; d < 10; d++);
            *SPI->SCLK = 0;
        }
    }
    
    // Read phase
    for (u32 i = 0; i < ReadByteCount; i++)
    {
        u8 data = 0;
        
        // Read 8 bits, MSB first
        for (int bit = 7; bit >= 0; bit--)
        {
            // Clock pulse
            *SPI->SCLK = 1;
            // Small delay for timing (may need adjustment based on hardware)
            for (volatile int d = 0; d < 10; d++);
            
            // Read MISO
            data |= (*SPI->MISO & 1) << bit;
            
            *SPI->SCLK = 0;
        }
        
        ReadData[i] = data;
    }
    
    // Deassert chip select
    *SPI->CS = 1;
}

u8 W5100_Read(spi* SPI, u32 Register)
{
    u8 Result = 0;
    u8 Data[3] = {0x0F,  (u8) (Register >> 8), (u8) Register };
    SPIWriteThenRead(SPI, Data, 3, &Result, 1);
    return Result;
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
		.Output  = &Screen,
		.Color   = COLOR_WHITE,
		.ColorBg = COLOR_BLACK
	};
    
	spi SPI = {
		.CS   = (u32*)0x40114,
		.SCLK = (u32*)0x4010c,
		.MOSI = (u32*)0x40110,
		.MISO = (u32*)0x40118
	};
    
    u8 Data[] = { 'A' };
    
	while (1)
	{
        u32 Data = W5100_Read(&SPI, 0x0018);
        ConsoleWrite(&Console, "%x\n", Data);
    }
    
}