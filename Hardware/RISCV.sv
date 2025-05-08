module RISCV(
	input  		CLOCK_50,
   input[1:0]  KEY,
	input[9:0]  SW,
	output[9:0] LEDR,
   output 		VGA_HS,
   output 		VGA_VS,
   output[3:0] VGA_R,
   output[3:0] VGA_G,
   output[3:0] VGA_B,
	
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
	
	cpu_clock CPUClockGen(
		.inclk0(CLOCK_50),
		.c0(CPUClock)
	);
	
	gpu_clock GPUClockGen(
		.inclk0(CLOCK_50),
		.c0(GPUClock)
	);
	
	cpu CPU(
		.Clock(CPUClock),
		.Reset(SW[1]),
	
		.GPUClock(GPUClock),
		.GPUAddress(GPUAddress),
		.GPUData(GPUData),
		
		.ProgramCounter(ProgramCounter)
	);
	
	//Graphics output
	logic[9:0] X, Y;
	color Color;
	
	assign GPUAddress = ((Y / 2) * 320 + (X / 2));
	assign Color = '{{GPUData[7:5], 1'b0}, {GPUData[4:2], 1'b0}, {GPUData[1:0], 2'b0}};
	
	vga_driver VGA(
		.clk(GPUClock), 
		.reset(SW[0]), 
		.hsync(VGA_HS), 
		.vsync(VGA_VS), 
		.r(VGA_R), 
		.g(VGA_G), 
		.b(VGA_B), 
		.x(X), 
		.y(Y), 
		.Color(Color)
	);
	
	hex_display(ProgramCounter, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5);
		
endmodule

module hex_display(
    input      [31:0] value,  // 32-bit input value
    output reg [6:0]  HEX0,   // Least significant hex display
    output reg [6:0]  HEX1,
    output reg [6:0]  HEX2,
    output reg [6:0]  HEX3,
    output reg [6:0]  HEX4,
    output reg [6:0]  HEX5
);
    
    function [6:0] hex_to_7seg;
        input [3:0] hex;
        case (hex)
            4'h0: hex_to_7seg = 7'b1000000;
            4'h1: hex_to_7seg = 7'b1111001;
            4'h2: hex_to_7seg = 7'b0100100;
            4'h3: hex_to_7seg = 7'b0110000;
            4'h4: hex_to_7seg = 7'b0011001;
            4'h5: hex_to_7seg = 7'b0010010;
            4'h6: hex_to_7seg = 7'b0000010;
            4'h7: hex_to_7seg = 7'b1111000;
            4'h8: hex_to_7seg = 7'b0000000;
            4'h9: hex_to_7seg = 7'b0010000;
            4'hA: hex_to_7seg = 7'b0001000;
            4'hB: hex_to_7seg = 7'b0000011;
            4'hC: hex_to_7seg = 7'b1000110;
            4'hD: hex_to_7seg = 7'b0100001;
            4'hE: hex_to_7seg = 7'b0000110;
            4'hF: hex_to_7seg = 7'b0001110;
        endcase
    endfunction
    
    always @(*) begin
        HEX0 = hex_to_7seg(value[3:0]);
        HEX1 = hex_to_7seg(value[7:4]);
        HEX2 = hex_to_7seg(value[11:8]);
        HEX3 = hex_to_7seg(value[15:12]);
        HEX4 = hex_to_7seg(value[19:16]);
        HEX5 = hex_to_7seg(value[23:20]);
    end
endmodule
