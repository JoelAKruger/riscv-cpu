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

u8 W5100_Read8(spi* SPI, u16 Register)
{
    u8 Result = 0;
    u8 Data[3] = {0x0F,  (u8) (Register >> 8), (u8) Register };
    SPIWriteThenRead(SPI, Data, 3, &Result, 1);
    return Result;
}

u16 W5100_Read16(spi* SPI, u16 Register)
{
    u16 Result = (W5100_Read8(SPI, Register) << 8) | W5100_Read8(SPI, Register + 1);
    return Result;
}

void W5100_Write(spi* SPI, u16 Register, u8 Value)
{
    u8 Data[4] = {0xF0,  (u8) (Register >> 8), (u8) Register, Value};
    SPIWriteThenRead(SPI, Data, 4, 0, 0);
}

void W5100_Write16(spi* SPI, u16 Register, u16 Value)
{
    W5100_Write(SPI, Register, (u8)(Value >> 8));
    W5100_Write(SPI, Register + 1, (u8)Value);
}

int W5100_SetupMACRaw(spi* SPI)
{
    W5100_Write(SPI, 0x0000, 0x01);
    W5100_Write(SPI, 0x001A, 0x55);
    W5100_Write16(SPI, 0x0428, 0x6000 + 0x7FF);
    
    int Success = 0;
    
    for (int I = 0; I < 100; I++)
    {
        W5100_Write(SPI, 0x0400, 0x04);
        W5100_Write(SPI, 0x0401, 0x01);
        if (W5100_Read8(SPI, 0x0403) != 0x42)
        {
            W5100_Write(SPI, 0x0401, 0x10);
            continue;
        }
        Success = 1;
        break;
    }
    
    return Success;
}

int W5100_DataReceived(spi* SPI)
{
    return W5100_Read16(SPI, 0x0426);
}

void W5100_ReadBytes(spi* SPI, u8* Dest, u16 Source, u32 Bytes)
{
    for (u32 I = 0; I < Bytes; I++)
    {
        Dest[I] = W5100_Read8(SPI, Source++);
    }
}

int W5100_Receive(spi* SPI, u8* Buffer, u32 BufferSize)
{
    int RX_Mask = 0x7FF;
    int RX_Base = 0x6000;
    
    int Size = W5100_Read16(SPI, 0x0426);
    
    int Offset = W5100_Read16(SPI, 0x0428) & RX_Mask;
    
    u16 DataSize = 0;
    
    // If Data Size header is right before the end
    if (Offset == RX_Mask)
    {
        DataSize = (W5100_Read8(SPI, RX_Base + Offset) << 8) | W5100_Read8(SPI, RX_Base);
    }
    else
    {
        DataSize = W5100_Read16(SPI, RX_Base + Offset);
    }
    
    Offset = (Offset + 2) & RX_Mask;
    DataSize -= 2;
    
    if (DataSize > BufferSize)
    {
        printf("ERROR: Datasize = %x, Buffersize = %x\n", DataSize, BufferSize);
        return -1;
    }
    
    if ((Offset + DataSize) > (RX_Mask + 1))
    {
        int UpperBytes = (RX_Mask + 1) - Offset;
        W5100_ReadBytes(SPI, Buffer, RX_Base + Offset, UpperBytes);
        Buffer += UpperBytes;
        
        int RemainingBytes = DataSize - UpperBytes;
        W5100_ReadBytes(SPI, Buffer, RX_Base, RemainingBytes);
    }
    else
    {
        W5100_ReadBytes(SPI, Buffer, RX_Base + Offset, DataSize);
    }
    
    int ReadCount = W5100_Read16(SPI, 0x0428) + DataSize + 2;
    W5100_Write16(SPI, 0x0428, ReadCount);
    
    W5100_Write(SPI, 0x0401, 0x40);
    
    return DataSize;
}
