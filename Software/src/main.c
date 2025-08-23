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

u16 htons(u16 Value)
{
    return ((Value & 0xFF00) >> 8) | ((Value & 0x00FF) << 8);
}

u16 ntohs(u16 Value)
{
    return ((Value & 0xFF00) >> 8) | ((Value & 0x00FF) << 8);
}

typedef struct
{
    u8 Bytes[6];
} mac_address;

int MacAddressesAreEqual(mac_address* A, mac_address* B)
{
    return (memcmp(A, B, 6) == 0);
}

typedef struct
{
    mac_address MAC;
    u32 IP;
    u32 SubnetMask;
    
    spi* Backend;
} network_interface;

typedef struct __attribute__((packed))
{
    mac_address DestMAC;
    mac_address SourceMAC;
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
    mac_address SenderHardwareAddress;
    u32 SenderProtocolAddress;
    mac_address TargetHardwareAddress;
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

u16 CalculateInternetChecksum(u8* Data, u32 Length) {
    u32 Sum = 0;
    
    while (Length > 1) {
        Sum += (Data[0] << 8) | Data[1];
        Data += 2;
        Length -= 2;
    }
    
    if (Length == 1) {
        Sum += (Data[0] << 8);
    }
    
    while (Sum >> 16) {
        Sum = (Sum & 0xFFFF) + (Sum >> 16);
    }
    
    return ~Sum;
}

void PrintEthernetFrame(ethernet_frame* Frame)
{
    printf("Dest MAC: ");
    for (int I = 5; I >= 0; I--)
    {
        printf("%x ", Frame->DestMAC.Bytes[I]);
    }
    printf("\n");
    
    printf("Source MAC: ");
    for (int I = 5; I >= 0; I--)
    {
        printf("%x ", Frame->SourceMAC.Bytes[I]);
    }
    printf("\n");
    
    printf("EtherType: ");
    for (int I = 2; I >= 0; I--)
    {
        printf("%x ", Frame->EtherType[I]);
    }
    printf("\n");
}

void PrintMacAddress(mac_address* MAC)
{
    printf("MAC: ");
    for (int I = 5; I >= 0; I--)
    {
        printf("%x ", MAC->Bytes[I]);
    }
    printf("\n");
}

//mac_address MacAddress = {{0xDE, 0xAD, 0xBE, 0xEF, 0xFE, 0xED}};
mac_address BroadcastMAC = {{0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF}};
//u32 IPAddress = (10) | (0 << 8) | (0 << 16) | (20 << 24); //10.0.0.20
//u32 SubnetMask = 0xFFFFFF00; //255.255.255.0

void HandleARP(network_interface* Interface, ethernet_frame* Frame, u32 Bytes)
{
    if (Bytes < sizeof(address_resolution_protocol_frame))
    {
        printf("Invalid call to HandleARP\n");
        return;
    }
    
    address_resolution_protocol_frame* ARP = (address_resolution_protocol_frame*)Frame;
    
#if 0
    printf("HardwareType: %x\n", ARP->HardwareType);
    printf("ProtocolType: %x\n", ARP->ProtocolType);
    printf("HardwareLength: %x\n", ARP->HardwareLength);
    printf("ProtocolLength: %x\n", ARP->ProtocolLength);
    printf("TargetProtocolAddress: %x\n", ARP->TargetProtocolAddress);
#endif
    
    if (ARP->HardwareType == 0x0100 &&
        ARP->ProtocolType == 0x0008 &&
        ARP->HardwareLength == 6 &&
        ARP->ProtocolLength == 4 && 
        ARP->TargetProtocolAddress == Interface->IP)
    {
        //ARP Request
        if (ARP->Operation == 0x0100)
        {
            address_resolution_protocol_frame Response = {};
            Response.EtherFrame.DestMAC = Frame->SourceMAC;
            Response.EtherFrame.SourceMAC = Interface->MAC;
            Response.EtherFrame.EtherType[0] = 0x08;
            Response.EtherFrame.EtherType[1] = 0x06;
            
            Response.HardwareType = 0x0100;
            Response.ProtocolType = 0x0008;
            Response.HardwareLength = 6;
            Response.ProtocolLength = 4;
            Response.Operation = 0x0200;
            Response.TargetProtocolAddress = ARP->SenderProtocolAddress;
            Response.TargetHardwareAddress = ARP->SenderHardwareAddress;
            Response.SenderProtocolAddress = Interface->IP;
            Response.SenderHardwareAddress = Interface->MAC;
            
            W5100_Send(Interface->Backend, (u8*) &Response, sizeof(Response));
            
            printf("ARP request\n");
        }
        
        //ARP Response
        else if (ARP->Operation == 0x0200)
        {
            //TODO: add to cache
        }
    }
    else
    {
#if 0
        printf("ARP is not for me\n");
        printf("HardwareType: %x\n", ARP->HardwareType);
        printf("ProtocolType: %x\n", ARP->ProtocolType);
        printf("HardwareLength: %x\n", ARP->HardwareLength);
        printf("ProtocolLength: %x\n", ARP->ProtocolLength);
        printf("TargetProtocolAddress: %x\n", ARP->TargetProtocolAddress);
#endif
    }
}

typedef struct __attribute__((packed))
{
    u8 Type;
    u8 Code;
    u16 Checksum;
    u16 Identifier;
    u16 Sequence;
} icmp_header;

void HandleICMP(network_interface* Interface, ipv4_frame* IP, u32 FrameLength, u32 DataOffset, u32 DataLength)
{
    if (DataLength < sizeof(icmp_header))
    {
        return;
    }
    
    icmp_header* ICMP = (icmp_header*)((u32)IP + DataOffset);
    
    // Echo request
    if (ICMP->Type == 0x8 &&
        ICMP->Code == 0x0)
    {
        //Swap MAC address of ethernet header
        mac_address SourceMAC = IP->EtherFrame.SourceMAC;
        IP->EtherFrame.SourceMAC = IP->EtherFrame.DestMAC;
        IP->EtherFrame.DestMAC = SourceMAC;
        
        //Swap IP addresses of ipv4 header
        u32 SourceIP = IP->SourceAddress;
        IP->SourceAddress = IP->DestAddress;
        IP->DestAddress = (10) | (0 << 8) | (0 << 16) | (10 << 24); //SourceIP;
        
        ICMP->Type = 0; //echo reply
        ICMP->Checksum = 0;
        
        ICMP->Checksum = htons(CalculateInternetChecksum((u8*)ICMP, DataLength));
        
        W5100_Send(Interface->Backend, (u8*) IP, FrameLength);
    }
}

typedef struct __attribute__((packed))
{
    u16 SourcePort;
    u16 DestPort;
    u16 Length;
    u16 Checksum;
} udp_header;

void HandleUDP(network_interface* Interface, ipv4_frame* Frame, u32 FrameLength, u32 DataOffset, u32 DataLength)
{
#if 0
    printf("DataOffset = %d\n", DataOffset);
    printf("DataLength = %d\n", DataLength);
#endif
    
    if (DataLength < sizeof(udp_header))
    {
        return;
    }
    
    udp_header* UDP = (udp_header*)((u32)Frame + DataOffset);
    
    DataOffset += sizeof(udp_header);
    DataLength -= sizeof(udp_header);
    
    u8* Data = (u8*) ((u32)Frame + DataOffset);
    int Length = ntohs(UDP->Length) - sizeof(udp_header);
    
#if 0
    printf("Source port = %d\n", ntohs(UDP->SourcePort));
    printf("Dest port = %d\n", ntohs(UDP->DestPort));
    printf("Checksum = %d\n", ntohs(UDP->Checksum));
    printf("Length (excluding header) = %d\n", Length);
#endif
    
    if (Length > DataLength)
    {
        return;
    }
    
    for (int I = 0; I < Length; I++)
    {
        printf("%c", Data[I]);
    }
}


void HandleIPv4(network_interface* Interface, ethernet_frame* Frame, u32 FrameLength)
{
    if (FrameLength < sizeof(ipv4_frame))
    {
        return;
    }
    
    ipv4_frame* IP = (ipv4_frame*)Frame;
    
    int IPHeaderLength = sizeof(ipv4_frame) + 4 * (IP->InternetHeaderLength - 5);
    
    int DataLength = FrameLength - IPHeaderLength;
    
    if (DataLength < 0)
    {
        return;
    }
    
    if (IP->Version == 4 && 
        (IP->DestAddress == Interface->IP || IP->DestAddress == (Interface->IP | ~Interface->SubnetMask)))
    {
        switch (IP->Protocol)
        {
            //ICMP
            case 0x1:
            {
                //TODO: Use length from IP header
                HandleICMP(Interface, IP, FrameLength, IPHeaderLength, DataLength);
            } break;
            
            //UDP
            case 17:
            {
                HandleUDP(Interface, IP, FrameLength, IPHeaderLength, DataLength);
            }
        }
    }
}

void HandleEthernetFrame(network_interface* Interface, u8* Data, u32 Bytes)
{
    ethernet_frame* Frame = (ethernet_frame*)Data;
    u32 FrameLength = Bytes;
    
    if (MacAddressesAreEqual(&Frame->DestMAC, &BroadcastMAC) ||
        MacAddressesAreEqual(&Frame->DestMAC, &Interface->MAC))
    {
        // Address Resolution Protocol
        if (Frame->EtherType[0] == 0x08 && Frame->EtherType[1] == 0x06)
        {
            HandleARP(Interface, Frame, FrameLength);
        }
        
        // IPv4
        if (Frame->EtherType[0] == 0x08 && Frame->EtherType[1] == 0x00)
        {
            HandleIPv4(Interface, Frame, FrameLength);
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
    mac_address MAC;
    u32 IP;
    u32 SubnetMask;
    
    spi* Backend;
    
    network_interface Interface = {
        .MAC = {{0xDE, 0xAD, 0xBE, 0xEF, 0xFE, 0xED}},
        .IP = (10) | (0 << 8) | (0 << 16) | (20 << 24), //10.0.0.20
        .SubnetMask = 0xFFFFFF00, //255.255.255.0
        .Backend = &SPI
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
                HandleEthernetFrame(&Interface, ReceivedData, BytesReceived);
            }
        }
    }
    
}