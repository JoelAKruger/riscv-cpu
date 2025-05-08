`timescale 1ns / 1ps

module testbench;
	reg Clock;
	reg Reset;
	int CycleCount;
	 
	
	cpu CPU(
		.Clock(Clock),
		.Reset(Reset),
		
		.GPUClock(Clock),
		.GPUAddress(),
		.GPUData()
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
