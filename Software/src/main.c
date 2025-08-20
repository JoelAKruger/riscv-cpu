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

typedef struct 
{
    u8 DestMAC[6];
    u8 SourceMAC[6];
    u8 EtherType[2];
} ethernet_frame;

typedef struct __attribute__((packed))
{
    ethernet_frame EtherFrame;
    u16 HardwareType;
    u16 ProtocolType;
    u8 HardwareLength;
    u8 ProtocolLength;
    u16 Operation;
    u8 SenderHardwareAddress[6];
    u32 SenderProtocolAddress;
    u8 TargetHardwareAddress[6];
    u32 TargetProtocolAddress;
} address_resolution_protocol_frame;

_Static_assert(sizeof(address_resolution_protocol_frame) == 42, "");

/*
u32 CalculateEthernetChecksum(u8* Data, u32 Bytes)
{
    u32 CRCPoly = 0x04C11DB7;
    u32 CRC = 0xFFFFFFFF;
    while (Bytes--) 
    {
        CRC^= (*Data++) << 24;
        for (int I = 8; I >= 0; I--) 
        {
            CRC = (CRC & 0x80000000) ? (CRC << 1) ^ CRCPoly : CRC << 1;
        }
    }
    return ~CRC;
}
*/

void PrintEthernetFrame(ethernet_frame* Frame)
{
    printf("Dest MAC: ");
    for (int I = 5; I >= 6; I--)
    {
        printf("%x ", Frame->DestMAC[I]);
    }
    printf("\n");
    
    printf("Source MAC: ");
    for (int I = 5; I >= 0; I--)
    {
        printf("%x ", Frame->SourceMAC[I]);
    }
    printf("\n");
    
    printf("EtherType: ");
    for (int I = 2; I >= 0; I--)
    {
        printf("%x ", Frame->EtherType[I]);
    }
    printf("\n");
}

u8 MacAddress[6] = {0xDE, 0xAD, 0xBE, 0xEF, 0xFE, 0xED};
u8 BroadcastMAC[6] = {0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF};
u8 IPAddress[4] = {10, 0, 0, 20};

void HandleEthernetFrame(spi* SPI, u8* Data, u32 Bytes)
{
    ethernet_frame* Frame = (ethernet_frame*)Data;
    
    if (memcmp(Frame->DestMAC, BroadcastMAC, 6) == 0 ||
        memcmp(Frame->DestMAC, MacAddress, 6) == 0)
    {
        // Address Resolution Protocol
        if (Frame->EtherType[0] == 0x08 && Frame->EtherType[1] == 0x06)
        {
            if (Bytes >= sizeof(address_resolution_protocol_frame))
            {
                address_resolution_protocol_frame* ARP = (address_resolution_protocol_frame*)Frame;
                
                if (ARP->HardwareType == 0x0100 &&
                    ARP->ProtocolType == 0x0008 &&
                    ARP->HardwareLength == 6 &&
                    ARP->ProtocolLength == 4 && 
                    memcmp(&ARP->TargetProtocolAddress, IPAddress, 4))
                {
                    //ARP Request
                    if (ARP->Operation == 0x0100)
                    {
                        address_resolution_protocol_frame Response = {};
                        memcpy(Response.EtherFrame.DestMAC, Frame->SourceMAC, 6);
                        memcpy(Response.EtherFrame.SourceMAC, MacAddress, 6);
                        Response.EtherFrame.EtherType[0] = 0x08;
                        Response.EtherFrame.EtherType[1] = 0x06;
                        
                        Response.HardwareType = 0x0100;
                        Response.ProtocolType = 0x0008;
                        Response.HardwareLength = 6;
                        Response.ProtocolLength = 4;
                        Response.Operation = 0x0200;
                        Response.TargetProtocolAddress = ARP->SenderProtocolAddress;
                        memcpy(Response.TargetHardwareAddress, ARP->SenderHardwareAddress, 6);
                        memcpy(&Response.SenderProtocolAddress, IPAddress, 4);
                        memcpy(Response.SenderHardwareAddress, MacAddress, 6);
                        
                        W5100_Send(SPI, (u8*) &Response, sizeof(Response));
                        
                        printf("ARP request\n");
                    }
                    
                    //ARP Response
                    else if (ARP->Operation == 0x0200)
                    {
                        //TODO: add to cache
                    }
                }
            }
        }
    }
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
                HandleEthernetFrame(&SPI, ReceivedData, BytesReceived);
            }
        }
    }
    
}