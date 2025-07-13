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

typedef enum logic[3:0] {
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
		endcase
	end

endmodule

`define SignExtend(Value, From) {{(32 - From){Value[From-1]}}, Value}

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
		
		endcase
	end

endmodule

module immediate_generator(
	input[31:0]          Instruction,
	input immediate_type Type,
	output reg[31:0]         Output
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

module memory_controller(
	input            CPUClock,
	input				  CPUReset,
	input[31:0]  	  CPUInstructionAddress,
	input[31:0]      CPUDataAddress,
	input[31:0]      CPUDataIn,
	input        	  CPUDataWriteEnable,
	
	output[31:0] CPUInstructionOutput,
	output reg[31:0] CPUDataOutput,
	
	input store_type StoreType,
	input load_type  LoadType,
	
	input            GPUClock,
	input[31:0]      GPUAddress,
	output reg[7:0]  GPUData,
	
	input[1:0]       InputDevices,
	input[31:0]      Counter
);

	logic[1:0]  CPUDataAddressOffset;
	assign      CPUDataAddressOffset = CPUDataAddress[1:0];

	logic[31:0] DataIn;
	logic[3:0]  ByteEnable;
	
	logic[31:0] CPUInstructionOutput_BigEndian;
	logic[31:0] CPUInstDataOut;
	logic[31:0] RawCPUDataOutput;
	logic[31:0] RawCPUDataOutput_BigEndian;
	logic[31:0] GPUDataOut;
	
	memory_type MemoryType;
	assign MemoryType = memory_type'(CPUDataAddress[18:17]); //0 -> main memory, 1 -> graphics memory
	
	always_comb begin
		RawCPUDataOutput = 0;
		
		case (MemoryType)
			MEMORY_MAIN: begin
				RawCPUDataOutput = EndianSwap(RawCPUDataOutput_MainMemory_BigEndian);
			end
			MEMORY_GRAPHICS: begin
				RawCPUDataOutput = EndianSwap(RawCPUDataOutput_Graphics_BigEndian);
			end
			MEMORY_IO: begin
				case (CPUDataAddress[16:2])
					0: begin
						RawCPUDataOutput = InputDevices[0];
					end
					1: begin 
						RawCPUDataOutput = InputDevices[1];
					end
					64: begin
						RawCPUDataOutput = Counter;
					end
				endcase
			end
		endcase
	end
	
	assign CPUInstructionOutput = EndianSwap(CPUInstructionOutput_BigEndian);
	
	logic[7:0] DataOut8;
	assign DataOut8 = (RawCPUDataOutput >> (CPUDataAddressOffset * 8)) & 8'hFF;
	
	logic[15:0] DataOut16;
	assign DataOut16 = (RawCPUDataOutput >> (CPUDataAddressOffset * 8)) & 16'hFFFF;
	

	
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
	
	logic  MainMemoryWriteEnable;
	assign MainMemoryWriteEnable = (MemoryType == MEMORY_MAIN) & CPUDataWriteEnable;
	
	logic[31:0] RawCPUDataOutput_MainMemory_BigEndian;
	
	//a = instructions, b = data
	main_memory MainMemory(
		.address_a(CPUInstructionAddress[15:2]),
		.address_b(CPUDataAddress[15:2]),
		.byteena_b(ByteEnable),
		.clock_a(CPUClock),
		.clock_b(~CPUClock),
		.data_a(0),
		.data_b(EndianSwap(DataIn)),
		.wren_a(1'b0),
		.wren_b(MainMemoryWriteEnable),
		.q_a(CPUInstructionOutput_BigEndian),
		.q_b(RawCPUDataOutput_MainMemory_BigEndian)
	);
	
	logic  GraphicsMemoryWriteEnable;
	assign GraphicsMemoryWriteEnable = (MemoryType == MEMORY_GRAPHICS) & CPUDataWriteEnable;
		
	logic[31:0] RawCPUDataOutput_Graphics_BigEndian;
	logic[31:0] RawGPUDataOutput_BigEndian;
	
	//a = cpu access, b = gpu access
	graphics_memory GraphicsMemory(
		.address_a(CPUDataAddress[16:2]),
		.address_b(GPUAddress[16:2]),
		.byteena_a(ByteEnable),
		.clock_a(~CPUClock),
		.clock_b(GPUClock),
		.data_a(EndianSwap(DataIn)),
		.data_b(0),
		.wren_a(GraphicsMemoryWriteEnable),
		.wren_b(1'b0),
		.q_a(RawCPUDataOutput_Graphics_BigEndian),
		.q_b(RawGPUDataOutput_BigEndian)
	);
	
	logic[1:0] GraphicsOffset;
	
	always_ff @(posedge GPUClock) begin
		GraphicsOffset <= GPUAddress[1:0];
	end
	
	always_comb begin
		case (GraphicsOffset)
			2'b00: GPUData = RawGPUDataOutput_BigEndian[31:24];
			2'b01: GPUData = RawGPUDataOutput_BigEndian[23:16];
			2'b10: GPUData = RawGPUDataOutput_BigEndian[15:8];
			2'b11: GPUData = RawGPUDataOutput_BigEndian[7:0];
		endcase
	end	

endmodule

function automatic logic [31:0] EndianSwap(logic [31:0] In);
    logic [31:0] Out;
    Out[31:24] = In[7:0];
	 Out[23:16] = In[15:8];
	 Out[15:8]  = In[23:16];
	 Out[7:0]   = In[31:24];
    return Out;
endfunction

module cpu(
	input 		Clock,
	input       Reset,
	
	input       GPUClock,
	input[31:0] GPUAddress,
	output[7:0] GPUData,
	
	input[1:0]   InputDevices,
	output[31:0] ProgramCounter,
	input[31:0]  Counter
);

	reg[31:0] PC;
	reg[31:0] NextPC;
	logic[31:0] Instruction;	
	
	assign ProgramCounter = PC;
	
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
	
	// Data Signals
	logic[31:0] Reg1, Reg2;
	logic[31:0] Immediate;
	
	logic[31:0] AluResult;
	logic[31:0] MemoryRead;
	logic[31:0] Writeback;
	
	register_file Registers(
		.Clock(Clock),
		.Reset(Reset),
		.Index1(Instruction[19:15]),
		.Index2(Instruction[24:20]),
		.WriteIndex(Instruction[11:7]),
		.WriteEnable(RegWrite),
		.WriteData(Writeback),
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
	
	memory_controller Memory(
		.CPUClock(Clock),
		.CPUReset(Reset),
		.CPUInstructionAddress(NextPC),
		.CPUDataAddress(AluResult),
		.CPUDataIn(Reg2),
		.CPUDataWriteEnable(MemWrite),
		
		.CPUInstructionOutput(Instruction),
		.CPUDataOutput(MemoryRead),
		
		.StoreType(StoreType),
		.LoadType(LoadType),
	
		.GPUClock(GPUClock),
		.GPUAddress(GPUAddress),
		.GPUData(GPUData),
		
		.InputDevices(InputDevices),
		.Counter(Counter)
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
	
	always_comb begin
		Writeback = 0;
		case (WBSrc)
			WRITEBACK_ALU_RESULT:  Writeback = AluResult;
			WRITEBACK_MEMORY_READ: Writeback = MemoryRead;
			WRITEBACK_PC_PLUS_4:   Writeback = PC + 4;
		endcase
	end
	
	//TODO: Use sign extend
	logic[31:0] BranchImmediate;
	assign BranchImmediate = {{20{Instruction[31]}}, Instruction[7], Instruction[30:25], Instruction[11:8], 1'b0};
	
	logic[31:0] JumpAndLinkImmediate;
	assign JumpAndLinkImmediate = {{12{Instruction[31]}}, Instruction[19:12], Instruction[20], Instruction[30:21], 1'b0};
	
	always_comb begin
		case (PCSrc)
			PC_SRC_PC_PLUS_4:   		NextPC = PC + 4;
			PC_SRC_PC_PLUS_IMM: 		NextPC = PC + BranchImmediate;
			PC_SRC_PC_PLUS_JAL_IMM: NextPC = PC + JumpAndLinkImmediate;
			PC_SRC_ALU_RESULT:  		NextPC = AluResult;
			PC_SRC_BRANCH:      		NextPC = AluResult[0] ? PC + BranchImmediate : PC + 4;
		endcase
		NextPC[1:0] = 2'b00;
	end
	
	always_ff @(posedge Clock) begin
		PC = Reset ? 0 : NextPC;
	end
	
endmodule