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

typedef struct __attribute__((packed))
{
    ethernet_frame EtherFrame;
    
    u8 InternetHeaderLength: 4;
    u8 Version : 4;
    u8 ECN : 2;
    u8 DSCP : 6;
    u16 TotalLength;
    u16 Identification;
    u16 FragmentOffset : 13;
    u8 Flags : 3;
    u8 TTL;
    u8 Protocol;
    u16 HeaderChecksum;
    u32 SourceAddress;
    u32 DestAddress;
    
} ipv4_frame;

_Static_assert(sizeof(ipv4_frame) == 34, "");

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
u32 IPAddress = (10) | (0 << 8) | (0 << 16) | (20 << 24); //10.0.0.20

void HandleARP(spi* SPI, ethernet_frame* Frame, u32 Bytes)
{
    if (Bytes < sizeof(address_resolution_protocol_frame))
    {
        return;
    }
    
    address_resolution_protocol_frame* ARP = (address_resolution_protocol_frame*)Frame;
    
    if (ARP->HardwareType == 0x0100 &&
        ARP->ProtocolType == 0x0008 &&
        ARP->HardwareLength == 6 &&
        ARP->ProtocolLength == 4 && 
        ARP->TargetProtocolAddress == IPAddress)
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
            Response.SenderProtocolAddress = IPAddress;
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

typedef struct __attribute__((packed))
{
    u8 Type;
    u8 Code;
    u16 Checksum;
} icmp_header;

typedef struct
{
    ethernet_frame EtherFrame;
    ipv4_frame IP;
    icmp_header ICMP;
} icmp_reply_frame;

_Static_assert(sizeof(icmp_reply_frame) == sizeof(ethernet_frame) + sizeof(ipv4_frame) + sizeof(icmp_header), "");

void HandleICMP(spi* SPI, ipv4_frame* IP, u8* Data, u32 DataLength)
{
    if (DataLength < sizeof(icmp_header))
    {
        return;
    }
    
    icmp_header* ICMP = (icmp_header*)Data;
    
    // Echo request
    if (ICMP->Type == 0x8 &&
        ICMP->Code == 0x0)
    {
        icmp_reply_frame Response = {};
        memcpy(Response.EtherFrame.DestMAC, IP->EtherFrame.SourceMAC, 6);
        memcpy(Response.EtherFrame.SourceMAC, MacAddress, 6);
        Response.EtherFrame.EtherType[0] = 0x08; //ipv4
        Response.EtherFrame.EtherType[1] = 0x00;
        
        Response.IP.Version = 4;
        Response.IP.InternetHeaderLength = 5;
        Response.IP.TotalLength = sizeof(Response.IP) + sizeof(Response.ICMP);
        Response.IP.TTL = 100;
        Response.IP.Protocol = 0x1; //icmp
        Response.IP.SourceAddress = IPAddress;
        Response.IP.DestAddress = IP->SourceAddress;
        
        Response.ICMP.Type = 0; //echo reply
        
        W5100_Send(SPI, (u8*) &Response, sizeof(Response));
        printf("Echo reply\n");
        
        u8* Data = (u8*)&Response;
        for (int I = 0; I < sizeof(Response); I++)
        {
            printf("%x ", Data[I]);
        }
    }
}

void HandleIPv4(spi* SPI, ethernet_frame* Frame, u32 FrameLength)
{
    if (FrameLength < sizeof(ipv4_frame))
    {
        return;
    }
    
    ipv4_frame* IP = (ipv4_frame*)Frame;
    
    u8* Data = (u8*)IP + sizeof(ipv4_frame);
    int DataLength = FrameLength - sizeof(ipv4_frame);
    
    if (DataLength < 0)
    {
        return;
    }
    
    if (IP->Version == 4 &&
        IP->DestAddress == IPAddress)
    {
        switch (IP->Protocol)
        {
            //ICMP
            case 0x1:
            {
                //TODO: Use length from IP header
                HandleICMP(SPI, IP, Data, DataLength);
            }
        }
    }
}

void HandleEthernetFrame(spi* SPI, u8* Data, u32 Bytes)
{
    ethernet_frame* Frame = (ethernet_frame*)Data;
    u32 FrameLength = Bytes;
    
    if (memcmp(Frame->DestMAC, BroadcastMAC, 6) == 0 ||
        memcmp(Frame->DestMAC, MacAddress, 6) == 0)
    {
        // Address Resolution Protocol
        if (Frame->EtherType[0] == 0x08 && Frame->EtherType[1] == 0x06)
        {
            HandleARP(SPI, Frame, FrameLength);
        }
        
        else if (Frame->EtherType[0] == 0x08 && Frame->EtherType[1] == 0x00)
        {
            HandleIPv4(SPI, Frame, FrameLength);
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