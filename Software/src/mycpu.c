#include "mycpu.h"

u8 VGAFontBytes[] __attribute__((aligned(4)))  = 
#include "zap-vga16.psf_Array.h"

static void 
memset(void* Dest_, int Value, u32 Count)
{
	u8* Dest = (u8*)Dest_;
	for (u32 I = 0; I < Count; I++)
	{
		Dest[I] = (u8)Value;
	}
}

static void
ClearScreen(screen_buffer Screen, u8 Color)
{
    int Index = 0;
    for (int Y = 0; Y < Screen.Height; Y++)
    {
        for (int X = 0; X < Screen.Width; X++)
        {
            Screen.Pixels[Index++] = Color;
        }
    }
}

static void
SetPixel(screen_buffer Screen, u32 X, u32 Y, u8 Color)
{
    if (X < Screen.Width && Y < Screen.Height)
    {
	    Screen.Pixels[Y * Screen.PixelsPerScanline + X] = Color;
    }
}

static void
DrawChar(screen_buffer Screen, u32 X, u32 Y, u8 Color, char C)
{
    pc_screen_font_v1* Font = (pc_screen_font_v1*) VGAFontBytes;
    
    u8* Row = Font->Data + C * Font->CharSize;
    
    for (int I = 0; I < Font->CharSize; I++)
    {
        for (int J = 0; J < 8; J++)
        {
            if (*Row & (0x80 >> J))
            {
                SetPixel(Screen, X + J, Y + I, Color);
            }
        }
        Row++;
    }
}

int Max(int A, int B)
{
    if (A > B)
    {
        return A;
    }
    return B;
}

int Min(int A, int B)
{
    if (A < B)
    {
        return A;
    }
    return B;
}

static void
DrawRectangle(screen_buffer Screen, int X, int Y, int W, int H, u8 Color)
{
    int Left = Max(0, X);
    int Right = Min(Screen.Width, X + W);
    int Top = Max(0, Y);
    int Bottom = Min(Screen.Height, Y + H);
    
    u8* Row = Screen.Pixels + Top * Screen.PixelsPerScanline;
    for (int I = Top; I < Bottom; I++)
    {
        for (int J = Left; J < Right; J++)
        {
            Row[J] = Color;
        }
        Row += Screen.PixelsPerScanline;
    }
}

static u32
StringLength(char* Text)
{
    u32 Count = 0;
    while (*Text++)
    {
        Count++;
    }
    return Count;
}

static void
DrawText(screen_buffer Screen, u32 X, u32 Y, u8 Color, char* Text)
{
    int Length = StringLength(Text);
    for (int I = 0; I < Length; I++)
    {
        DrawChar(Screen, X, Y, Color, Text[I]);
        X += 8;
    }
}

static void
ClearConsole(console* Console)
{
    ClearScreen(*Console->Output, Console->ColorBg);
}

static void
ConsoleScrollDown(console* Console)
{
    //Copy pixels
    int RowCount = Console->Output->Height - CONSOLE_CHAR_HEIGHT;
    
    u8* SrcRow  = Console->Output->Pixels + CONSOLE_CHAR_HEIGHT * Console->Output->PixelsPerScanline;
    u8* DestRow = Console->Output->Pixels;
    
    for (int Row = 0; Row < RowCount; Row++)
    {
        for (int X = 0; X < Console->Output->Width; X++)
        {
            DestRow[X] = SrcRow[X];
        }
        
        SrcRow += Console->Output->PixelsPerScanline;
        DestRow += Console->Output->PixelsPerScanline;
    }
    
    //Clear bottom
    for (int Row = 0; Row < CONSOLE_CHAR_HEIGHT; Row++)
    {
        for (int X = 0; X < Console->Output->Width; X++)
        {
            DestRow[X] = Console->ColorBg;
        }
        DestRow += Console->Output->PixelsPerScanline;
    }
    
    Console->AtY -= CONSOLE_CHAR_HEIGHT;
}

static void
ConsoleWriteChar(console* Console, char C)
{
    switch (C)
    {
        case '\n':
        {
            Console->AtY += CONSOLE_CHAR_HEIGHT;
            Console->AtX = 0;
            
            if (Console->AtY >= Console->Output->Height)
            {
                ConsoleScrollDown(Console);
            }
            
            
        } break;
        
        case '\r':
        {
            Console->AtX = 0;
        } break;
        
        default:
        {
            DrawChar(*Console->Output, Console->AtX, Console->AtY, Console->Color, C);
            Console->AtX += CONSOLE_CHAR_WIDTH;
            if (Console->AtX >= Console->Output->Width)
            {
                ConsoleWriteChar(Console, '\n');
            }
        }
    }
}

static void 
ConsoleWriteIntInternal(console* Console, int I, int Base)
{
    char* Digits = "0123456789ABCDEF";
    if (I != 0)
    {
        int Rem = I % Base;
        ConsoleWriteIntInternal(Console, I / Base, Base);
        ConsoleWriteChar(Console, Digits[Rem]);
    }
}

static void
ConsoleWriteInt(console* Console, int I, int Base)
{
    if (I == 0)
    {
        ConsoleWriteChar(Console, '0');
    }
    else
    {
        ConsoleWriteIntInternal(Console, I, Base);
    }
}

static void
ConsoleWriteString(console* Console, char* String)
{
    for (int I = 0; String[I]; I++)
    {
        ConsoleWriteChar(Console, String[I]);
    }
}

static void
ConsoleWrite(console* Console, char* Format, ...)
{
    va_list Args;
    va_start(Args, Format);
    
    while (*Format)
    {
        if (*Format == '%')
        {
            Format++;
            switch (*Format)
            {
                case 's':
                {
                    ConsoleWriteString(Console, va_arg(Args, char*));
                } break;
                case 'd': case 'i':
                {
                    ConsoleWriteInt(Console, va_arg(Args, int), 10);
                } break;
                case 'x':
                {
                    ConsoleWriteInt(Console, va_arg(Args, int), 16);
                } break;
                case 'c':
                {
                    ConsoleWriteChar(Console, (char) va_arg(Args, int));
                } break;
                case 0:
                {
                    return;
                } 
            }
        }
        else
        {
            ConsoleWriteChar(Console, *Format);
        }
        Format++;
    }
}


void DrawMandelbrot(screen_buffer* Buffer)
{
    int MaxIter = 64;
    
    float MinRe = -2.0f, MaxRe = 1.0f;
    float MinIm = -1.0f, MaxIm = 1.0f;
    
    float ReFactor = (MaxRe - MinRe) / (Buffer->Width);
    float ImFactor = (MaxIm - MinIm) / (Buffer->Height);
    
    for (int Y = 0; Y < Buffer->Height; Y++)
    {
        for (int X = 0; X < Buffer->Width; X++)
        {
            float cRe = MinRe + X * ReFactor;
            float cIm = MinIm + Y * ImFactor;
            
            float zRe = 0.0f, zIm = 0.0f;
            int Iter;
            for (Iter = 0; Iter < MaxIter; Iter++)
            {
                float zRe2 = zRe * zRe;
                float zIm2 = zIm * zIm;
                
                if (zRe2 + zIm2 > 4.0f) break;  // Escape condition
                
                float NewRe = zRe2 - zIm2 + cRe;
                float NewIm = 2.0f * zRe * zIm + cIm;
                
                zRe = NewRe;
                zIm = NewIm;
            }
            
            u8 Color = (Iter * 4) / MaxIter;
            Buffer->Pixels[Y * Buffer->PixelsPerScanline + X] = Color;
        }
    }
}
