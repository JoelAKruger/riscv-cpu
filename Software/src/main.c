#include "mycpu.c"
#include "graphics.c"
#include "w5100.c"

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

console* GlobalConsole;

#define printf(...) ConsoleWrite(GlobalConsole, __VA_ARGS__)

typedef struct {
    u8 DestMAC[6];
    u8 SourceMAC[6];
    u8 EtherType[2];
} ethernet_frame;

void HandleEthernetFrame(u8* Data, u32 Bytes)
{
    ethernet_frame* Frame = (ethernet_frame*) Data;
    
    printf("Dest MAC: ");
    for (int I = 0; I < 6; I++)
    {
        printf("%x ", Frame->DestMAC[I]);
    }
    printf("\n");
    
    printf("Source MAC: ");
    for (int I = 0; I < 6; I++)
    {
        printf("%x ", Frame->SourceMAC[I]);
    }
    printf("\n");
    
    printf("EtherType: ");
    for (int I = 0; I < 2; I++)
    {
        printf("%x ", Frame->EtherType[I]);
    }
    printf("\n");
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
    
    GlobalConsole = &Console;
    
	spi SPI = {
		.CS   = (u32*)0x40114,
		.SCLK = (u32*)0x4010c,
		.MOSI = (u32*)0x40110,
		.MISO = (u32*)0x40118
	};
    
    W5100_SetupMACRaw(&SPI);
    
    u8 ReceivedData[2048];
    
    while (1)
    {
        int DataReceived = W5100_DataReceived(&SPI);
        
        if (DataReceived)
        {
            int BytesReceived = W5100_Receive(&SPI, ReceivedData, sizeof(ReceivedData));
            
            if (BytesReceived != -1)
            {
                HandleEthernetFrame(ReceivedData, BytesReceived);
            }
        }
    }
    
}