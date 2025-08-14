`timescale 1ns / 1ps

function automatic logic [31:0] EndianSwap32(logic [31:0] In);
    logic [31:0] Out;
    Out[31:24] = In[7:0];
	 Out[23:16] = In[15:8];
	 Out[15:8]  = In[23:16];
	 Out[7:0]   = In[31:24];
    return Out;
endfunction

function automatic logic [3:0] EndianSwap4(logic [3:0] In);
    logic [3:0] Out;
	 Out = {In[0], In[1], In[2], In[3]};
    return Out;
endfunction

module testbench;
	reg Clock;
	reg Reset;
	int CycleCount;
	
	logic[31:0] MemoryAddress, MemoryRead_BE, MemoryWrite_LE, ProgramCounter;
	logic MemoryReadEnable, MemoryWriteEnable;
	logic[3:0] MemoryWriteByteEnable_LE;
	
	cpu CPU(
		.Clock(Clock),
		.Reset(Reset),
	
		.MemoryAddress(MemoryAddress),
		.MemoryReadEnable(MemoryReadEnable),
		.MemoryWriteEnable(MemoryWriteEnable),
		.MemoryWriteByteEnable(MemoryWriteByteEnable_LE),
	
		.MemoryRead(EndianSwap32(MemoryRead_BE)),
		.MemoryWrite(MemoryWrite_LE)
	);
	
	memory Memory(
		.address_a(MemoryAddress),
		.address_b(0),
		.byteena_a(EndianSwap4(MemoryWriteByteEnable_LE)),
		.clock_a(Clock),
		.clock_b(0),
		.data_a(EndianSwap32(MemoryWrite_LE)),
		.data_b(0),
		.wren_a(MemoryWriteEnable),
		.wren_b(0),
		.q_a(MemoryRead_BE),
		.q_b()
	);
	
	always begin
		Clock = 0;
		#5
		Clock = 1;
		#5;
	end
	
	initial begin
		Reset = 1;
		#10
		Reset = 0;
	end
	
	initial begin
		Clock = 0;
		CycleCount = 0;
	end

	always @(posedge Clock) begin
		CycleCount = CycleCount + 1;
		if (CycleCount == 2000000) $stop();
	end
endmodule
