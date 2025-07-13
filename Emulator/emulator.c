#define UNICODE
#include <Windows.h>
#include <stdio.h>
#include <assert.h>
#include <stdint.h>
#include <stdbool.h>

LRESULT CALLBACK WindowProc(HWND Window, UINT Message, WPARAM wParam, LPARAM lParam);

typedef int8_t i8;
typedef uint8_t u8;
typedef int16_t i16;
typedef uint16_t u16;
typedef int32_t i32;
typedef uint32_t u32;

typedef struct 
{
    uint8_t* Memory;
    u32 MemorySize;

    u32 Regs[32];
    u32 PC;
} emulator;

typedef enum {
	ALU_NONE,
	ALU_ADD,
	ALU_SUB,
	ALU_OR,
	ALU_XOR,
	ALU_AND,
	ALU_SLL,
	ALU_SRL,
	ALU_SRA,
	ALU_IN2,
	ALU_E,
	ALU_NE,
	ALU_GE,
	ALU_GEU,
	ALU_L,
	ALU_LU
} alu_op;

typedef enum {
	WRITEBACK_ALU_RESULT,
	WRITEBACK_MEMORY_READ,
	WRITEBACK_PC_PLUS_4
} writeback_source;

typedef enum {
	PC_SRC_PC_PLUS_4,
	PC_SRC_PC_PLUS_IMM,
	PC_SRC_PC_PLUS_JAL_IMM,
	PC_SRC_ALU_RESULT,
	PC_SRC_BRANCH // AluResult[0] ? PC + Imm : PC + 4
} pc_source;

typedef enum {
	IMM_NONE,
	IMM_I20,
	IMM_UI20,
	IMM_I12,
	IMM_U12,
	IMM_U5,
	IMM_I12_UNPACKED
} immediate_type;

typedef enum {
	STORE_NONE,
	STORE_8,
	STORE_16,
	STORE_32
} store_type;

typedef enum {
	LOAD_NONE,
	LOAD_I8,
	LOAD_I16,
	LOAD_I32,
	LOAD_U8,
	LOAD_U16
} load_type;

typedef struct {
    bool                RegWrite;
    bool                AluInput1IsPC;
    bool                AluInput2IsImmediate;
    immediate_type      ImmediateType;
    bool                MemWrite;
    writeback_source    WBSrc;
    store_type          StoreType;
    load_type           LoadType;
    alu_op              AluOp;
    pc_source           PCSrc;
} cpu_control;

u32 DoALUOp(alu_op Op, u32 Input1, u32 Input2)
{
    u32 Result = 0;

    switch (Op)
    {
        case ALU_NONE: Result = 0; break;
		case ALU_ADD: Result = Input1 + Input2; break;
		case ALU_SUB: Result = Input1 - Input2; break;
		case ALU_OR:  Result = Input1 | Input2; break;
		case ALU_XOR: Result = Input1 ^ Input2; break;
		case ALU_AND: Result = Input1 & Input2; break;
		case ALU_SLL: Result = Input1 << Input2; break;
		case ALU_SRL: Result = Input1 >> Input2; break;
		case ALU_SRA: Result = ((i32)Input1) >> Input2; break;
		case ALU_IN2: Result = Input2; break;
		case ALU_E:   Result = Input1 == Input2; break;
		case ALU_NE:  Result = Input1 != Input2; break;
		case ALU_GE:  Result = (i32)Input1 >= (i32)Input2; break;
		case ALU_GEU: Result = Input1 >= Input2; break;
		case ALU_L:   Result = (i32)Input1 < (i32)Input2; break;
		case ALU_LU:  Result = Input1 < Input2; break;
    }

    return Result;
}

cpu_control DoCPUControl(u32 Instruction)
{
    u32 Opcode = (Instruction >> 2) & 0x1F;
    u32 Operation = (Instruction >> 12) & 0x7;

    cpu_control Result = {0};

    switch (Opcode)
    {
        case 0b01101: //Load upper immediate
        {
            Result.RegWrite = 1;
            Result.AluInput2IsImmediate = 1;
            Result.ImmediateType = IMM_UI20;
            Result.AluOp = ALU_IN2;
        } break;

        case 0b00101: //Add upper immediate to pc
        {
			Result.RegWrite = 1;
			Result.AluInput1IsPC = 1;
			Result.AluInput2IsImmediate = 1;
			Result.ImmediateType = IMM_UI20;
			Result.AluOp = ALU_ADD;
        } break;

        case 0b00100: //Alu operation with immediate
        {
            Result.RegWrite = 1;
            Result.AluInput2IsImmediate = 1;
        
            switch (Operation)
            {
                case 0b000: //Add immediate
                {
                    Result.ImmediateType = IMM_I12;
                    Result.AluOp = ALU_ADD;
                } break;
                case 0b010: //Set less than immediate
                {
                    Result.ImmediateType = IMM_I12;
                    Result.AluOp = ALU_L;
                } break;
                case 0b011: //Set less than immediate unsigned
                {
                    Result.ImmediateType = IMM_I12;
                    Result.AluOp = ALU_LU;
                } break;
                case 0b100: //Xor immediate
                {
                    Result.ImmediateType = IMM_I12;
                    Result.AluOp = ALU_XOR;
                } break;
                case 0b110: //Or immediate
                {
                    Result.ImmediateType = IMM_I12;
                    Result.AluOp = ALU_OR;
                } break;
                case 0b111: //And immediate
                {
                    Result.ImmediateType = IMM_I12;
                    Result.AluOp = ALU_AND;
                } break;
                case 0b001: //Shift left immediate
                {
                    Result.ImmediateType = IMM_U5;
                    Result.AluOp = ALU_SLL;
                } break;
                case 0b101: //Shift right immediate
                {
                    Result.ImmediateType = IMM_U5;
                    Result.AluOp = (Instruction & (1 << 30)) ? ALU_SRA : ALU_SRL;
                } break;
            }
        } break;
			
        case 0b01100: //Alu operation
        {
            Result.RegWrite = 1;
            switch (Operation)
            {
                case 0b000: Result.AluOp = (Instruction & (1 << 30)) ? ALU_SUB : ALU_ADD; break;
                case 0b001: Result.AluOp = ALU_SLL; break;
                case 0b010: Result.AluOp = ALU_L; break;
                case 0b011: Result.AluOp = ALU_LU; break;
                case 0b100: Result.AluOp = ALU_XOR; break;
                case 0b101: Result.AluOp = (Instruction & (1 << 30)) ? ALU_SRA : ALU_SRL; break;
                case 0b110: Result.AluOp = ALU_OR; break;
                case 0b111: Result.AluOp = ALU_AND; break;
            }
        } break;
        
        case 0b00000: //Load
        {
            Result.RegWrite = 1;
            Result.AluInput2IsImmediate = 1;
            Result.ImmediateType = IMM_I12;
            Result.WBSrc = WRITEBACK_MEMORY_READ;
            Result.AluOp = ALU_ADD;
            switch (Operation)
            {
                case 0b000: Result.LoadType = LOAD_I8; break;
                case 0b001: Result.LoadType = LOAD_I16; break;
                case 0b010: Result.LoadType = LOAD_I32; break;
                case 0b100: Result.LoadType = LOAD_U8; break;
                case 0b101: Result.LoadType = LOAD_U16; break;
            }
        } break;
        
        case 0b01000: //Store
        {
            Result.AluInput2IsImmediate = 1;
            Result.ImmediateType = IMM_I12_UNPACKED;
            Result.MemWrite = 1;
            Result.AluOp = ALU_ADD;
            switch (Operation)
            {
                case 0b000: Result.StoreType = STORE_8; break;
                case 0b001: Result.StoreType = STORE_16; break;
                case 0b010: Result.StoreType = STORE_32; break;
            }
        } break;
    
        case 0b11011: //Jump and link immediate
        {
            Result.RegWrite = 1;
            Result.WBSrc = WRITEBACK_PC_PLUS_4;
            Result.PCSrc = PC_SRC_PC_PLUS_JAL_IMM;
        } break;
        
        case 0b11001: //Jump and link register
        {
            Result.RegWrite = 1;
            Result.AluInput2IsImmediate = 1;
            Result.ImmediateType = IMM_I12;
            Result.WBSrc = WRITEBACK_PC_PLUS_4;
            Result.AluOp = ALU_ADD;
            Result.PCSrc = PC_SRC_ALU_RESULT;
        } break;
        
        case 0b11000: //Branch
        {
            Result.PCSrc = PC_SRC_BRANCH;
            switch (Operation)
            {
                case 0b000: Result.AluOp = ALU_E; break;
                case 0b001: Result.AluOp = ALU_NE; break;
                case 0b100: Result.AluOp = ALU_L; break;
                case 0b101: Result.AluOp = ALU_GE; break;
                case 0b110: Result.AluOp = ALU_LU; break;
                case 0b111: Result.AluOp = ALU_GEU; break;
            }
        } break;
    }

    return Result;
}

u32 SignExtend(u32 Value, int From)
{
    int Shift = 32 - From;
    return (u32)(((i32)(Value << Shift)) >> Shift);
}

u32 GenerateImmediate(u32 Instruction, immediate_type Type)
{
    u32 Imm20 = (Instruction >> 12);
    u32 Imm12 = (Instruction >> 20);

    u32 Output = 0;
    switch (Type)
    {
        case IMM_NONE:          Output = 0; break;
        case IMM_I20:           Output = SignExtend(Imm20, 20); break;
        case IMM_UI20:          Output = (Imm20 << 12); break;
        case IMM_I12:           Output = SignExtend(Imm12, 12); break;
        case IMM_U12:           Output = Imm12; break;
        case IMM_U5:            Output = (Instruction >> 20) & 0x1F; break;
        case IMM_I12_UNPACKED:  Output = SignExtend(((Instruction >> 25) & 0x7F) << 5 | ((Instruction >> 7) & 0x1F), 12); break;
    }

    return Output;
}

u32 ReadInstructionFromMemory(emulator* Emulator)
{
    assert(Emulator->PC < Emulator->MemorySize);

    u32 Result = *(u32*)(Emulator->Memory + Emulator->PC);
    return Result;
}

void StoreInMemory(emulator* Emulator, store_type StoreType, u32 CPUDataAddress, u32 CPUDataIn)
{
    assert(CPUDataAddress < Emulator->MemorySize);

    switch (StoreType)
    {
        case STORE_NONE: break;
        case STORE_8:
        {
            Emulator->Memory[CPUDataAddress] = CPUDataIn;
        } break;
        case STORE_16:
        {
            assert((CPUDataAddress & 0x1) == 0);
            *(u16*)(Emulator->Memory + CPUDataAddress) = CPUDataIn;
        } break;
        case STORE_32:
        {
            assert((CPUDataAddress & 0x3) == 0);
            *(u32*)(Emulator->Memory + CPUDataAddress) = CPUDataIn;
        } break;
    }
}

#define BUTTON_A 0x100000
#define BUTTON_B 0x100004
#define TIMER    0x100100

u32 GetTimerValue() {
    static LARGE_INTEGER Frequency;
    static LARGE_INTEGER Start;
    static int Initialised;

    if (!Initialised) {
        QueryPerformanceFrequency(&Frequency);
        QueryPerformanceCounter(&Start);
        Initialised = 1;
    }

    LARGE_INTEGER Now;
    QueryPerformanceCounter(&Now);

    LONGLONG elapsed = Now.QuadPart - Start.QuadPart;
    // Convert to microseconds
    return (u32)((elapsed * 1000000) / Frequency.QuadPart);
}

u32 LoadFromMemory(emulator* Emulator, load_type LoadType, u32 CPUDataAddress)
{
    
    u32 CPUDataOutput = 0;

    if (CPUDataAddress < Emulator->MemorySize)
    {
        switch (LoadType)
        {
            case LOAD_NONE: break;
            case LOAD_U8:
            {
                CPUDataOutput = Emulator->Memory[CPUDataAddress];
            } break;
            case LOAD_U16:
            {
                assert((CPUDataAddress & 0x1) == 0);
                CPUDataOutput = *(u16*)(Emulator->Memory + CPUDataAddress);
            } break;
            case LOAD_I32:
            {
                assert((CPUDataAddress & 0x3) == 0);
                CPUDataOutput = *(i32*)(Emulator->Memory + CPUDataAddress);
            } break;
            case LOAD_I8:
            {
                CPUDataOutput = (u32)(i32) * (i8*)(Emulator->Memory + CPUDataAddress);
            } break;
            case LOAD_I16:
            {
                assert((CPUDataAddress & 0x1) == 0);
                CPUDataOutput = (u32)(i32) * (i16*)(Emulator->Memory + CPUDataAddress);
            } break;
        }
    }
    else if (CPUDataAddress == BUTTON_A)
    {
        CPUDataOutput = ((GetKeyState(VK_LEFT) & 0x8000) != 0) ||
                        ((GetKeyState('A') & 0x8000) != 0);
    }
    else if (CPUDataAddress == BUTTON_B)
    {
        CPUDataOutput = ((GetKeyState(VK_RIGHT) & 0x8000) != 0) ||
                        ((GetKeyState('D') & 0x8000) != 0);;
    }
    else if (CPUDataAddress == 0x100100)
    {
        assert(LoadType == LOAD_I32); //This is not actually necessary
        CPUDataOutput = GetTimerValue();
    }
    else
    {
        assert(0);
    }

    return CPUDataOutput;
}

u32 GetNextPC(emulator* Emulator, u32 Instruction, pc_source PCSrc, u32 AluResult)
{
    u32 NextPC = 0;
    u32 PC = Emulator->PC;

    u32 BranchImmediate = SignExtend(
        ((Instruction >> 31) & 0x1) << 12 |
        ((Instruction >> 7)  & 0x1) << 11 |
        ((Instruction >> 25) & 0x3F) << 5 |
        ((Instruction >> 8)  & 0xF) << 1,
        13
    );

    u32 JumpAndLinkImmediate = SignExtend(
        ((Instruction >> 31) & 0x1) << 20 |
        ((Instruction >> 12) & 0xFF) << 12 |
        ((Instruction >> 20) & 0x1) << 11 |
        ((Instruction >> 21) & 0x3FF) << 1,
        21
    );

    switch (PCSrc)
    {
        case PC_SRC_PC_PLUS_4:   		NextPC = PC + 4; break;
        case PC_SRC_PC_PLUS_IMM: 		NextPC = PC + BranchImmediate; break;
        case PC_SRC_PC_PLUS_JAL_IMM:    NextPC = PC + JumpAndLinkImmediate; break;
        case PC_SRC_ALU_RESULT:  		NextPC = AluResult; break;
        case PC_SRC_BRANCH:      		NextPC = (AluResult & 0x1) ? PC + BranchImmediate : PC + 4; break;
	}
    return NextPC;
}

u32 ReadRegister(emulator* Emulator, int RegisterIndex)
{
    assert(RegisterIndex < 32);

    u32 Result = 0;

    if (RegisterIndex > 0)
    {
        Result = Emulator->Regs[RegisterIndex];
    }

    return Result;
}

void WriteRegister(emulator* Emulator, int RegisterIndex, u32 Value)
{
    assert(RegisterIndex < 32);

    if (RegisterIndex > 0)
    {
        Emulator->Regs[RegisterIndex] = Value; 
    }
}

unsigned long RunEmulator(void* Emulator_)
{
    emulator* Emulator = (emulator*)Emulator_;
    while (true)
    {
        u32 Instruction = ReadInstructionFromMemory(Emulator);
        //printf("PC = %x, Instruction = %x\n", Emulator->PC, Instruction);
        cpu_control Control = DoCPUControl(Instruction);

        u32 Reg1 = ReadRegister(Emulator, (Instruction >> 15) & 0x1F);
        u32 Reg2 = ReadRegister(Emulator, (Instruction >> 20) & 0x1F);

        u32 Immediate = GenerateImmediate(Instruction, Control.ImmediateType);

        u32 AluInput1 = Control.AluInput1IsPC ? Emulator->PC : Reg1;
        u32 AluInput2 = Control.AluInput2IsImmediate ? Immediate : Reg2;
        u32 AluResult = DoALUOp(Control.AluOp, AluInput1, AluInput2);

        if (Control.MemWrite)
        {
            StoreInMemory(Emulator, Control.StoreType, AluResult, Reg2);
        }

        u32 MemoryRead = 0;
        if (Control.LoadType != LOAD_NONE)
        {
            MemoryRead = LoadFromMemory(Emulator, Control.LoadType, AluResult);
        }

        if (Control.RegWrite)
        {
            u32 Writeback = 0;
            switch (Control.WBSrc)
            {
                case WRITEBACK_ALU_RESULT:   Writeback = AluResult; break;
                case WRITEBACK_MEMORY_READ:  Writeback = MemoryRead; break;
                case WRITEBACK_PC_PLUS_4:    Writeback = Emulator->PC + 4; break;
            }

            WriteRegister(Emulator, (Instruction >> 7) & 0x1F, Writeback);
        }

        Emulator->PC = GetNextPC(Emulator, Instruction, Control.PCSrc, AluResult);
    }
}

HANDLE LoadEmulator(emulator* Emulator, char* BinaryPath)
{
    HANDLE KernelFile = CreateFileA(BinaryPath, GENERIC_READ, 0, 0, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);
    assert(KernelFile != INVALID_HANDLE_VALUE);

    DWORD KernelSize = GetFileSize(KernelFile, 0);
    DWORD MemorySize = 0x40000;
    void* Base = VirtualAlloc(0, MemorySize, MEM_COMMIT|MEM_RESERVE, PAGE_EXECUTE_READWRITE);

    assert(KernelSize < 0x6000);

    DWORD BytesRead;
    ReadFile(KernelFile, Base, KernelSize, &BytesRead, 0);

    assert(BytesRead == KernelSize);

    Emulator->Memory = Base;
    Emulator->MemorySize = MemorySize;

    HANDLE Thread = CreateThread(0, 0, RunEmulator, (void*)Emulator, 0, 0);

    CloseHandle(KernelFile);

    return Thread;
}

int WINAPI wWinMain(HINSTANCE Instance, HINSTANCE _, LPWSTR CommandLine, int ShowCode)
{
    WNDCLASS WindowClass = {0};
	WindowClass.lpfnWndProc = WindowProc;
	WindowClass.hInstance = Instance;
	WindowClass.hCursor = LoadCursor(0, IDC_ARROW);
	WindowClass.lpszClassName = L"MainWindow";
	WindowClass.style = CS_OWNDC;
    
	if (!RegisterClass(&WindowClass))
	{
		return -1;
	}
	
    int BufferWidth = 1280, BufferHeight = 960;
	RECT ClientRect = { 0, 0, BufferWidth, BufferHeight };
	AdjustWindowRect(&ClientRect, WS_OVERLAPPEDWINDOW, FALSE);
	
	HWND Window = CreateWindow(WindowClass.lpszClassName,
                               L"RISC-V Sim",
                               WS_OVERLAPPEDWINDOW,
                               CW_USEDEFAULT, CW_USEDEFAULT, 
                               ClientRect.right - ClientRect.left, ClientRect.bottom - ClientRect.top,
                               0, 0, Instance, 0);
    
	ShowWindow(Window, ShowCode);
	
    BITMAPINFO* BitmapInfo = 0;
    int BitmapInfoSize = sizeof(BitmapInfo->bmiHeader) + 256 * sizeof(BitmapInfo->bmiColors[0]);
    BitmapInfo = malloc(BitmapInfoSize);
    ZeroMemory(BitmapInfo, BitmapInfoSize);

    BitmapInfo->bmiHeader.biSize = sizeof(BitmapInfo->bmiHeader);
    BitmapInfo->bmiHeader.biWidth = 320;
    BitmapInfo->bmiHeader.biHeight = -240;  // Negative for top-down DIB
    BitmapInfo->bmiHeader.biPlanes = 1;
    BitmapInfo->bmiHeader.biBitCount = 8;   // 8-bit indexed color
    BitmapInfo->bmiHeader.biCompression = BI_RGB;

    // Fill out 256-entry 3-3-2 palette
    for (int i = 0; i < 256; ++i)
    {
        uint8_t r = (i >> 5) & 0x07;
        uint8_t g = (i >> 2) & 0x07;
        uint8_t b = (i >> 0) & 0x03;

        BitmapInfo->bmiColors[i].rgbRed = ((float)r * 255) / 7;
        BitmapInfo->bmiColors[i].rgbGreen = ((float)g * 255) / 7;
        BitmapInfo->bmiColors[i].rgbBlue = ((float)b * 255) / 3;
        BitmapInfo->bmiColors[i].rgbReserved = 0;
    }

    emulator Emulator = { 0 };
    HANDLE EmulatorThread = LoadEmulator(&Emulator, "main.bin");

    void* Bits = Emulator.Memory + 0x20000;

    HDC WindowDC = GetDC(Window);

    while (1)
    {
        LARGE_INTEGER StartCount;
        QueryPerformanceCounter(&StartCount);

        MSG Message;
        while (PeekMessage(&Message, 0, 0, 0, PM_REMOVE))
        {
            if (Message.message == WM_QUIT)
            {
                TerminateThread(EmulatorThread, 0);
                return 0;
            }

            TranslateMessage(&Message);
            DispatchMessage(&Message);
        }

        GetClientRect(Window, &ClientRect);

        int ScanlinesCopied = StretchDIBits(WindowDC,
            0, 0, ClientRect.right, ClientRect.bottom,
            0, 0, 320, 240,
            Bits, BitmapInfo, DIB_RGB_COLORS, SRCCOPY);

        int x = 3;
    }
}


LRESULT CALLBACK WindowProc(HWND Window, UINT Message, WPARAM wParam, LPARAM lParam)
{
    switch (Message)
    {
        case WM_DESTROY:
        {
            PostQuitMessage(0);
            return 0;
        }
        
        default:
        {
            return DefWindowProc(Window, Message, wParam, lParam);
        }
    }	
    return 0;
}
