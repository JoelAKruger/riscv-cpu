module RISCV_No_VGA(
	input  		CLOCK_50,
   input[1:0]  KEY,
	input[9:0]  SW,
	output[9:0] LEDR,
	
	output[6:0] HEX0, 
	output[6:0] HEX1, 
	output[6:0] HEX2, 
	output[6:0] HEX3, 
	output[6:0] HEX4, 
	output[6:0] HEX5
);
	
	logic CPUClock;
	
	logic 		GPUClock;
	logic[31:0] GPUAddress;
	logic[7:0]  GPUData;
	
	logic[31:0] ProgramCounter;
	
	logic[5:0] 	SubCounter;
	logic[31:0] MicrosecondCounter;
	always_ff @(posedge CLOCK_50) begin
		SubCounter = SubCounter + 6'b1;
		
		if (SubCounter == 50) begin
			SubCounter = 0;
			MicrosecondCounter = MicrosecondCounter + 1;
		end
	end
	
	logic PLLCpuClock;
	cpu_clock CPUClockGen(
		.inclk0(CLOCK_50),
		.c0(PLLCpuClock)
	);
	
	
	logic[31:0] MemoryAddress, MemoryRead, MemoryWrite_LE;
	logic MemoryReadEnable, MemoryWriteEnable;
	logic[3:0] MemoryWriteByteEnable_LE;
	
	logic[31:0] DebugOut, DebugOut32;
	
	assign CPUClock = PLLCpuClock;
	
	logic[31:0] MemoryRead_BE;
	cpu CPU(
		.Clock(CPUClock),
		.Reset(SW[1]),
	
		.MemoryAddress(MemoryAddress),
		.MemoryReadEnable(MemoryReadEnable),
		.MemoryWriteEnable(MemoryWriteEnable),
		.MemoryWriteByteEnable(MemoryWriteByteEnable_LE),
	
		.MemoryRead(EndianSwap32(MemoryRead_BE)),
		.MemoryWrite(MemoryWrite_LE),
		
		.DebugOut32(DebugOut32),
		.DebugOut(DebugOut)
	);
	
	assign LEDR[9:0] = DebugOut[9:0];

	//a = cpu, b = gpu
	memory_single Memory(
		.address(MemoryAddress),
		.byteena(EndianSwap4(MemoryWriteByteEnable_LE)),
		.clock(CPUClock),
		.data(EndianSwap32(MemoryWrite_LE)),
		.wren(MemoryWriteEnable),
		.q(MemoryRead_BE)
	);
	
	hex_display Display(DebugOut32, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5);
		
endmodule
