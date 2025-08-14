module register_file(
	input        Clock,
	input        Reset,
	
	input[4:0] 	 Index1,
	input[4:0] 	 Index2,
	
	input[4:0] 	 WriteIndex,
	input      	 WriteEnable,
	input[31:0]  WriteData,
	
	output[31:0] Output1,
	output[31:0] Output2
);

	reg[31:0] Registers[31:0];
	
	assign Output1 = Registers[Index1];
	assign Output2 = Registers[Index2];
	
	always_ff @(posedge Clock) begin
		if (Reset) begin
			Registers[0] = 0;
		end
	
		if (WriteEnable && WriteIndex != 0) begin
			Registers[WriteIndex] = WriteData;
		end
	end

endmodule

typedef enum logic[4:0] {
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
	ALU_LU,
	
	// Custom Op
	ALU_BITCOUNT
} alu_op;

module arithmetic_logic_unit(
	input alu_op Op,
	input[31:0]  Input1,
	input[31:0]  Input2,
	output reg[31:0] Result
);
	
	always_comb begin
		Result = 0;
	
		case (Op)
			ALU_NONE: Result = 0;
			ALU_ADD: Result = Input1 + Input2;
			ALU_SUB: Result = Input1 - Input2;
			ALU_OR:  Result = Input1 | Input2;
			ALU_XOR: Result = Input1 ^ Input2;
			ALU_AND: Result = Input1 & Input2;
			ALU_SLL: Result = Input1 << Input2;
			ALU_SRL: Result = Input1 >> Input2;
			ALU_SRA: Result = $signed(Input1) >>> Input2;
			ALU_IN2: Result = Input2;
			ALU_E:   Result = Input1 == Input2;
			ALU_NE:  Result = Input1 != Input2;
			ALU_GE:  Result = $signed(Input1) >= $signed(Input2);
			ALU_GEU: Result = Input1 >= Input2;
			ALU_L:   Result = $signed(Input1) < $signed(Input2);
			ALU_LU:  Result = Input1 < Input2;
			
			//Custom op
			ALU_BITCOUNT: begin
				Result = 0;
				for (int i = 0; i < 32; i++) begin
					Result = Result + Input1[i];
				end
			end
			
		endcase
	end

endmodule

`define SignExtend(value, width) {{(32-(width)){value[(width)-1]}}, value}

typedef enum logic[1:0] {
	WRITEBACK_ALU_RESULT,
	WRITEBACK_MEMORY_READ,
	WRITEBACK_PC_PLUS_4
} writeback_source;

typedef enum logic[2:0] {
	PC_SRC_PC_PLUS_4,
	PC_SRC_PC_PLUS_IMM,
	PC_SRC_PC_PLUS_JAL_IMM,
	PC_SRC_ALU_RESULT,
	PC_SRC_BRANCH // AluResult[0] ? PC + Imm : PC + 4
} pc_source;

typedef enum logic[2:0] {
	IMM_NONE,
	IMM_I20,
	IMM_UI20,
	IMM_I12,
	IMM_U12,
	IMM_U5,
	IMM_I12_UNPACKED
} immediate_type;

typedef enum logic[1:0] {
	STORE_NONE,
	STORE_8,
	STORE_16,
	STORE_32
} store_type;

typedef enum logic[2:0] {
	LOAD_NONE,
	LOAD_I8,
	LOAD_I16,
	LOAD_I32,
	LOAD_U8,
	LOAD_U16
} load_type;

typedef enum logic[1:0] {
	MEMORY_MAIN 	 = 2'b00,
	MEMORY_GRAPHICS = 2'b01,
	MEMORY_IO 		 = 2'b10
} memory_type;

typedef enum logic[0:0] {
	STATE_FETCH,
	STATE_EXECUTE
} cpu_state;

module cpu_control (
	input[31:0]   			   Instruction,
	
	output reg              RegWrite,
	output reg 				   AluInput1IsPC,
	output reg				   AluInput2IsImmediate,
	output immediate_type   ImmediateType,
	output reg				   MemWrite,
	output writeback_source WBSrc,
	output store_type       StoreType,
	output load_type        LoadType,
	output alu_op           AluOp,
	output pc_source        PCSrc
);

	logic[4:0] Opcode; 
	logic[2:0] Operation;
	assign Opcode = Instruction[6:2];
	assign Operation = Instruction[14:12];
	
	always_comb begin
		RegWrite = 0;
		AluInput1IsPC = 0;
		AluInput2IsImmediate = 0;
		ImmediateType = IMM_NONE;
		MemWrite = 0;
		WBSrc = WRITEBACK_ALU_RESULT;
		StoreType = STORE_NONE;
		LoadType = LOAD_NONE;
		AluOp = ALU_NONE;
		PCSrc = PC_SRC_PC_PLUS_4;
		
		
		case (Opcode)
			5'b01101: begin //Load upper immediate
				RegWrite = 1;
				AluInput2IsImmediate = 1;
				ImmediateType = IMM_UI20;
				AluOp = ALU_IN2;
			end
			
			5'b00101: begin //Add upper immediate to pc
				RegWrite = 1;
				AluInput1IsPC = 1;
				AluInput2IsImmediate = 1;
				ImmediateType = IMM_UI20;
				AluOp = ALU_ADD;
			end
		
			5'b00100: begin //Alu operation with immediate
				RegWrite = 1;
				AluInput2IsImmediate = 1;
			
				case (Operation)
					3'b000: begin //Add immediate
						ImmediateType = IMM_I12;
						AluOp = ALU_ADD;
					end
					3'b010: begin //Set less than immediate
						ImmediateType = IMM_I12;
						AluOp = ALU_L;
					end
					3'b011: begin //Set less than immediate unsigned
						ImmediateType = IMM_I12;
						AluOp = ALU_LU;
					end
					3'b100: begin //Xor immediate
						ImmediateType = IMM_I12;
						AluOp = ALU_XOR;
					end
					3'b110: begin //Or immediate
						ImmediateType = IMM_I12;
						AluOp = ALU_OR;
					end
					3'b111: begin //And immediate
						ImmediateType = IMM_I12;
						AluOp = ALU_AND;
					end
					3'b001: begin //Shift left immediate
						ImmediateType = IMM_U5;
						AluOp = ALU_SLL;
					end
					3'b101: begin //Shift right immediate
						ImmediateType = IMM_U5;
						AluOp = Instruction[30] ? ALU_SRA : ALU_SRL;
					end
				endcase
			end
			
			5'b01100: begin //Alu operation
				RegWrite = 1;
				case (Operation)
					3'b000: AluOp = Instruction[30] ? ALU_SUB : ALU_ADD;
					3'b001: AluOp = ALU_SLL;
					3'b010: AluOp = ALU_L;
					3'b011: AluOp = ALU_LU;
					3'b100: AluOp = ALU_XOR;
					3'b101: AluOp = Instruction[30] ? ALU_SRA : ALU_SRL;
					3'b110: AluOp = ALU_OR;
					3'b111: AluOp = ALU_AND;
				endcase
			end
			
			5'b00000: begin //Load
				RegWrite = 1;
				AluInput2IsImmediate = 1;
				ImmediateType = IMM_I12;
				WBSrc = WRITEBACK_MEMORY_READ;
				AluOp = ALU_ADD;
				case (Operation)
					3'b000: LoadType = LOAD_I8;
					3'b001: LoadType = LOAD_I16;
					3'b010: LoadType = LOAD_I32;
					3'b100: LoadType = LOAD_U8;
					3'b101: LoadType = LOAD_U16;
				endcase
			end
			
			5'b01000: begin //Store
				AluInput2IsImmediate = 1;
				ImmediateType = IMM_I12_UNPACKED;
				MemWrite = 1;
				AluOp = ALU_ADD;
				case (Operation)
					3'b000: StoreType = STORE_8;
					3'b001: StoreType = STORE_16;
					3'b010: StoreType = STORE_32;
				endcase
			end
		
			5'b11011: begin //Jump and link immediate
				RegWrite = 1;
				WBSrc = WRITEBACK_PC_PLUS_4;
				PCSrc = PC_SRC_PC_PLUS_JAL_IMM;
			end
			
			5'b11001: begin //Jump and link register
				RegWrite = 1;
				AluInput2IsImmediate = 1;
				ImmediateType = IMM_I12;
				WBSrc = WRITEBACK_PC_PLUS_4;
				AluOp = ALU_ADD;
				PCSrc = PC_SRC_ALU_RESULT;
			end
			
			5'b11000: begin //Branch
				PCSrc = PC_SRC_BRANCH;
				case (Operation)
					3'b000: AluOp = ALU_E;
					3'b001: AluOp = ALU_NE;
					3'b100: AluOp = ALU_L;
					3'b101: AluOp = ALU_GE;
					3'b110: AluOp = ALU_LU;
					3'b111: AluOp = ALU_GEU;
				endcase
			end
		
			//Custom instructions
			5'b00010: begin // Custom0
            RegWrite = 1;
            AluOp = ALU_BITCOUNT;
			end
		endcase
	end

endmodule

module immediate_generator(
	input[31:0]          Instruction,
	input immediate_type Type,
	output reg[31:0]     Output
);

	logic[19:0] Imm20;
	logic[11:0] Imm12;	
	assign Imm20 = Instruction[31:12];
	assign Imm12 = Instruction[31:20];

	always_comb begin
		Output = 0;
		case (Type)
			IMM_I20:          Output = `SignExtend(Imm20, 20);
			IMM_UI20:         Output = {Instruction[31:12], 12'b0};
			IMM_I12:          Output = `SignExtend(Imm12, 12);
			IMM_U12:          Output = Instruction[31:20];
			IMM_U5:           Output = Instruction[24:20];
			IMM_I12_UNPACKED: Output = {{20{Instruction[31]}}, Instruction[31:25], Instruction[11:7]};
		endcase
	end

endmodule

function [3:0] GetByteEnable (
    store_type StoreType,
    input [1:0] Offset
);

    begin
        case (StoreType)
            STORE_8: begin
                case (Offset)
                    2'd0: GetByteEnable = 4'b0001;
                    2'd1: GetByteEnable = 4'b0010;
                    2'd2: GetByteEnable = 4'b0100;
                    2'd3: GetByteEnable = 4'b1000;
                    default: GetByteEnable = 4'b0000;
                endcase
            end
             STORE_16: begin
                case (Offset)
                    2'd0: GetByteEnable = 4'b0011;
                    2'd2: GetByteEnable = 4'b1100;
                    default: GetByteEnable = 4'b0000;
                endcase
            end
            STORE_32: GetByteEnable = 4'b1111;
            default: GetByteEnable = 4'b0000;
        endcase
    end
endfunction

function[31:0] DoMemoryRead(
	load_type   LoadType,
	input[31:0] Data,
	input[1:0]  Offset
);
	DoMemoryRead = {32{1'bx}};
	case (LoadType)
		LOAD_U8: begin
			case (Offset)
				0: DoMemoryRead = Data[7:0];
				1: DoMemoryRead = Data[15:8];
				2: DoMemoryRead = Data[23:16];
				3: DoMemoryRead = Data[31:24];
			endcase
		end
		LOAD_U16: begin
			case (Offset)
				0: DoMemoryRead = Data[15:0];
				1: DoMemoryRead = Data[31:0];
			endcase
		end
		LOAD_I32: begin
			DoMemoryRead = Data[31:0];
		end
		LOAD_I8: begin
			case (Offset)
				0: DoMemoryRead = {{24{Data[7]}}, Data[7:0]};
				1: DoMemoryRead = {{24{Data[15]}}, Data[15:8]};
				2: DoMemoryRead = {{24{Data[23]}}, Data[23:16]};
				3: DoMemoryRead = {{24{Data[31]}}, Data[31:24]};
			endcase
		end
		LOAD_I16: begin
			case (Offset)
				0: DoMemoryRead = {{16{Data[15]}}, Data[15:0]};
				1: DoMemoryRead = {{16{Data[31]}}, Data[31:16]};
			endcase
		end			
	endcase
endfunction

function automatic logic [31:0] GetMemoryWrite (
    input logic [31:0] Data,
    input logic [1:0]  Offset,
    input store_type   StoreType
);
    case (StoreType)
        STORE_8:  GetMemoryWrite = (Data & 32'hFF) << (Offset * 8);
        STORE_16: GetMemoryWrite = (Data & 32'hFFFF) << (Offset * 8);
        STORE_32: GetMemoryWrite = Data;
        default:  GetMemoryWrite = 32'b0;
    endcase
endfunction

/*
	always_comb begin
		DataIn = 0;
		ByteEnable = 0; //The storage is big-endian
		case (StoreType)
			STORE_8: begin
				if (CPUDataAddressOffset == 0) begin
					ByteEnable = 4'b1000;
					DataIn = {24'b0, CPUDataIn[7:0]};
				end
				if (CPUDataAddressOffset == 1) begin
					ByteEnable = 4'b0100;
					DataIn = {16'b0, CPUDataIn[7:0], 8'b0};
				end
				if (CPUDataAddressOffset == 2) begin
					ByteEnable = 4'b0010;
					DataIn = {8'b0, CPUDataIn[7:0], 16'b0};
				end
				if (CPUDataAddressOffset == 3) begin
					ByteEnable = 4'b0001;
					DataIn = {CPUDataIn[7:0], 24'b0};
				end
			end
			STORE_16: begin
				if (CPUDataAddressOffset == 0) begin
					ByteEnable = 4'b1100;
					DataIn = {16'b0, CPUDataIn[15:0]};
				end
				if (CPUDataAddressOffset == 2) begin
					ByteEnable = 4'b0011;
					DataIn = {CPUDataIn[15:0], 16'b0};
				end
			end
			STORE_32: begin
				ByteEnable = 4'b1111;
				DataIn = CPUDataIn;
			end
		endcase
		
		CPUDataOutput = 0;
		case (LoadType)
			LOAD_U8: begin
				CPUDataOutput = DataOut8;
			end
			LOAD_U16: begin
				CPUDataOutput = DataOut16;
			end
			LOAD_I32: begin
				CPUDataOutput = RawCPUDataOutput;
			end
			LOAD_I8: begin
				CPUDataOutput = `SignExtend(DataOut8, 8);
			end
			LOAD_I16: begin
				CPUDataOutput = `SignExtend(DataOut16, 16);
			end			
		endcase
	end
*/

function automatic logic [31:0] EndianSwap(logic [31:0] In);
    logic [31:0] Out;
    Out[31:24] = In[7:0];
	 Out[23:16] = In[15:8];
	 Out[15:8]  = In[23:16];
	 Out[7:0]   = In[31:24];
    return Out;
endfunction

module cpu(
	input 		 		 Clock,
	input        		 Reset,
	
	output logic[31:0] MemoryAddress,
	output logic 		 MemoryReadEnable,
	output logic 		 MemoryWriteEnable,
	output logic[3:0]  MemoryWriteByteEnable,
	
	input[31:0]  		 MemoryRead,
	output logic[31:0] MemoryWrite,
	
	output logic[31:0] DebugOut32,
	output logic[31:0] DebugOut
);
   cpu_state   State;
	reg[31:0] PC;
	

	
	// Data Signals
	logic[31:0] AluResult;
	logic[31:0] Reg1, Reg2;
	logic[31:0] Immediate;
	
	// Control Signals
	logic            RegWrite;
	logic 			  AluInput1IsPC;
	logic 	  	     AluInput2IsImmediate;
	immediate_type   ImmediateType;
	logic 			  MemWrite;
	writeback_source WBSrc;
	store_type       StoreType;
	load_type        LoadType;
	alu_op           AluOp;
	pc_source        PCSrc;
	logic[31:0]      WriteBack;
	
	//Change state
	always_ff @(posedge Clock) begin
		if (Reset) begin
			State <= STATE_FETCH;
		end else begin
			case (State)
				STATE_FETCH: State = STATE_EXECUTE;
				STATE_EXECUTE: State = STATE_FETCH;
			endcase
		end
	end
	
	//Memory
	always_comb begin
		case (State)
			STATE_FETCH: begin
				MemoryAddress = PC[31:2];
				MemoryReadEnable = 1'b1;
				MemoryWriteEnable = 1'b0;
				MemoryWriteByteEnable = 4'b0;
				MemoryWrite = 0;
			end
			STATE_EXECUTE: begin
				MemoryAddress = AluResult[31:2];
				MemoryReadEnable = (LoadType != LOAD_NONE);
				MemoryWriteEnable = (StoreType != STORE_NONE);
				MemoryWriteByteEnable = GetByteEnable(StoreType, AluResult[1:0]);
				MemoryWrite = GetMemoryWrite(Reg2, AluResult[1:0], StoreType);
				
				if (LoadType == LOAD_NONE && StoreType == STORE_NONE) begin
					MemoryAddress = 0;
				end
			end
		endcase
	end
	
	//Read instruction
	reg[31:0] NextPC;
	
	logic RegWriteEnable;
	//TODO: This can probably be more general
	assign RegWriteEnable = RegWrite & (((WBSrc != WRITEBACK_MEMORY_READ) & (State == STATE_EXECUTE)) | ((WBSrc == WRITEBACK_MEMORY_READ) & (State == STATE_FETCH)));
	
	//Store current instruction
	logic[31:0] InstructionLatch;
	always @(posedge Clock) begin
		if (State == STATE_EXECUTE) begin
			InstructionLatch = MemoryRead;
		end
	end
	
	logic[31:0] Instruction;
	always_comb begin
		Instruction = (State == STATE_EXECUTE) ? MemoryRead : InstructionLatch;
	end
	
	register_file Registers(
		.Clock(Clock),
		.Reset(Reset),
		.Index1(Instruction[19:15]),
		.Index2(Instruction[24:20]),
		.WriteIndex(Instruction[11:7]),
		.WriteEnable(RegWriteEnable),
		.WriteData(WriteBack),
		.Output1(Reg1),
		.Output2(Reg2)
	);
	
	immediate_generator Imm(
		.Instruction(Instruction),
		.Type(ImmediateType),
		.Output(Immediate)
	);
	
	arithmetic_logic_unit ALU(
		.Op(AluOp),
		.Input1(AluInput1IsPC ? PC : Reg1),
		.Input2(AluInput2IsImmediate ? Immediate : Reg2),
		.Result(AluResult)
	);
	
	cpu_control Control(
		Instruction,
		RegWrite,
		AluInput1IsPC,
		AluInput2IsImmediate,
		ImmediateType,
		MemWrite,
		WBSrc,
		StoreType,
		LoadType,
		AluOp,
		PCSrc
	);
	
	//Do writeback
	always_comb begin
		case (WBSrc)
			WRITEBACK_ALU_RESULT:  WriteBack = AluResult;
			WRITEBACK_MEMORY_READ: WriteBack = DoMemoryRead(LoadType, MemoryRead, AluResult[1:0]);
			WRITEBACK_PC_PLUS_4:   WriteBack = PC + 4;
			default:               WriteBack = 0;
		endcase
	end
	
	//TODO: Use sign extend
	logic[31:0] BranchImmediate;
	assign BranchImmediate = {{20{Instruction[31]}}, Instruction[7], Instruction[30:25], Instruction[11:8], 1'b0};
	
	logic[31:0] JumpAndLinkImmediate;
	assign JumpAndLinkImmediate = {{12{Instruction[31]}}, Instruction[19:12], Instruction[20], Instruction[30:21], 1'b0};
	
	pc_src_select PCSelect(
		State,
		PC,
		BranchImmediate,
		JumpAndLinkImmediate,
		AluResult,
		PCSrc,
		NextPC
	);
	
	always_ff @(posedge Clock) begin
		if (Reset) begin
			PC = 0;
		end else if (State == STATE_EXECUTE) begin
			PC <= NextPC;
		end
	end
	
	assign DebugOut32 = PC;
	
	//                   [9:7]        [6:3]                   [2]                [1]             [0]                      
	assign DebugOut = {LoadType, MemoryWriteByteEnable, MemoryWriteEnable, MemoryReadEnable, State};
	
endmodule

module pc_src_select(
	input cpu_state      State,
	input[31:0] 			PC,
	input[31:0]          BranchImmediate,
	input[31:0]          JumpAndLinkImmediate,
	input[31:0]          AluResult,
	
	input pc_source      PCSrc,
	output logic[31:0] 	NextPC
);

    always_comb begin
			case (PCSrc)
				PC_SRC_PC_PLUS_4:   		NextPC = PC + 4;
				PC_SRC_PC_PLUS_IMM: 		NextPC = PC + BranchImmediate;
				PC_SRC_PC_PLUS_JAL_IMM: NextPC = PC + JumpAndLinkImmediate;
				PC_SRC_ALU_RESULT:  		NextPC = AluResult;
				PC_SRC_BRANCH:      		NextPC = AluResult[0] ? PC + BranchImmediate : PC + 4;
				default:                NextPC = 0;
			endcase
	end

endmodule