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
	output[6:0] HEX5,
	
	inout[12:0]	GPIO,
	inout[15:0] ARDUINO_IO
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
	
	gpu_clock GPUClockGen(
		.inclk0(CLOCK_50),
		.c0(GPUClock)
	);
	
	logic[31:0] MemoryAddress, MemoryRead, MemoryWrite;
	logic MemoryWriteEnable, MemoryReadEnable;
	logic[3:0] MemoryWriteByteEnable;
	
	logic[31:0] DebugOut, DebugOut32;
	
	assign CPUClock = PLLCpuClock;
	
	cpu CPU(
		.Clock(CPUClock),
		.Reset(SW[1]),
	
		.MemoryAddress(MemoryAddress),
		.MemoryReadEnable(MemoryReadEnable),
		.MemoryWriteEnable(MemoryWriteEnable),
		.MemoryWriteByteEnable(MemoryWriteByteEnable),
	
		.MemoryRead(MemoryRead),
		.MemoryWrite(MemoryWrite),
		
		.DebugOut32(DebugOut32),
		.DebugOut(DebugOut)
	);
	
	assign LEDR[9:0] = DebugOut[9:0];
	
	//Graphics output
	logic[9:0] X, Y;
	color Color;
	
	logic[31:0] GraphicsAddress;
	assign GraphicsAddress = 32'h8000 + ((Y / 2) * 320 + (X / 2));
	
	logic[1:0]  GraphicsAddressOffset;
	always_ff @(posedge GPUClock) begin
		GraphicsAddressOffset = GraphicsAddress[1:0];
	end
	
	logic[31:0] GPUData32;
	
	always_comb begin
		case (GraphicsAddressOffset)
			2'b00: GPUData = GPUData32[7:0];
			2'b01: GPUData = GPUData32[15:8];
			2'b10: GPUData = GPUData32[23:16];
			2'b11: GPUData = GPUData32[31:24];
		endcase
	end
	
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
	
	//Main Memory
	//a = cpu, b = gpu
	main_memory MainMemory (
		.Clock(CPUClock),
		.Address(MemoryAddress),
		.WriteEnable(MemoryWriteEnable),
		.WriteByteEnable(MemoryWriteByteEnable),
		.MemoryWrite(MemoryWrite),
		.MemoryRead(MemoryRead),
		
		.GClock(GPUClock),
		.GAddress(GraphicsAddress[31:2]),
		.GData(GPUData32)
	);
	
	pio_input #(.PIO_ADDRESS(32'h40000)) KeyA (
		 .Clock(CPUClock),
		 .Address(MemoryAddress),
		 .MemoryRead(MemoryRead),
		 .Value(~KEY[0])
	);
	
	pio_input #(.PIO_ADDRESS(32'h40004)) KeyB (
		 .Clock(CPUClock),
		 .Address(MemoryAddress),
		 .MemoryRead(MemoryRead),
		 .Value(~KEY[1])
	);
	
	pio_input #(.PIO_ADDRESS(32'h40100)) Timer (
		 .Clock(CPUClock),
		 .Address(MemoryAddress),
		 .MemoryRead(MemoryRead),
		 .Value(MicrosecondCounter)
	);
	
	pio_input #(.PIO_ADDRESS(32'h40104)) VSync (
		 .Clock(CPUClock),
		 .Address(MemoryAddress),
		 .MemoryRead(MemoryRead),
		 .Value(VGA_VS)
	);
	
	pio_output #(.PIO_ADDRESS(32'h40108)) Out (
		 .Clock(CPUClock),
		 .Address(MemoryAddress),
		 .MemoryWrite(MemoryWrite),
		 .Q(GPIO[0])
	);
	
	pio_output #(.PIO_ADDRESS(32'h4010C)) Sck (
		 .Clock(CPUClock),
		 .Address(MemoryAddress),
		 .MemoryWrite(MemoryWrite),
		 .Q(ARDUINO_IO[13])
	);
	
	pio_output #(.PIO_ADDRESS(32'h40110)) Mosi (
		 .Clock(CPUClock),
		 .Address(MemoryAddress),
		 .MemoryWrite(MemoryWrite),
		 .Q(ARDUINO_IO[11])
	);
	
	pio_output #(.PIO_ADDRESS(32'h40114)) Ss (
		 .Clock(CPUClock),
		 .Address(MemoryAddress),
		 .MemoryWrite(MemoryWrite),
		 .Q(ARDUINO_IO[10])
	);
	
	pio_input #(.PIO_ADDRESS(32'h40118)) Miso (
		 .Clock(CPUClock),
		 .Address(MemoryAddress),
		 .MemoryRead(MemoryRead),
		 .Value(ARDUINO_IO[12])
	);
	
	hex_display Display(DebugOut32, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5);
		
endmodule

module pio_input #(
    parameter logic [31:0] PIO_ADDRESS
) 
(
    input  logic        Clock,
    input  logic [31:0] Address,
    output logic [31:0] MemoryRead,
    input  logic [31:0] Value
);

    logic [31:0] LatchedAddress;

    always_ff @(posedge Clock) begin
        LatchedAddress <= Address;
    end

    always_comb begin
        if (LatchedAddress == (PIO_ADDRESS / 4)) begin
            MemoryRead = Value;
        end else begin
            MemoryRead = {32{1'bz}};
        end
    end

endmodule

module pio_output #(
    parameter logic [31:0] PIO_ADDRESS
) 
(
    input  logic        Clock,
    input  logic [31:0] Address,
    input  logic [31:0] MemoryWrite,
    output logic Q
);

    always_ff @(posedge Clock) begin
        if (Address == (PIO_ADDRESS / 4)) begin
				Q = MemoryWrite[0];
		  end
    end

endmodule
	
module main_memory (
	input Clock,
	input[31:0] Address,
	input WriteEnable,
	input[3:0] WriteByteEnable,
	input[31:0] MemoryWrite,
	output[31:0] MemoryRead,
	
	input GClock,
	input[31:0] GAddress,
	output[31:0] GData
);
	logic[31:0] MemoryRead_BE, GMemoryRead_BE;
	
	logic[31:0] LatchedAddress;
	always_ff @(posedge Clock) begin
		LatchedAddress = Address;
	end
	
	memory Memory(
		.address_a(Address),
		.address_b(GAddress),
		.byteena_a(EndianSwap4(WriteByteEnable)),
		.clock_a(Clock),
		.clock_b(GClock),
		.data_a(EndianSwap32(MemoryWrite)),
		.data_b(0),
		.wren_a(WriteEnable & (Address < 40960)),
		.wren_b(0),
		.q_a(MemoryRead_BE),
		.q_b(GMemoryRead_BE)
	);
	
	always_comb begin
		if (LatchedAddress < 40960) begin
			MemoryRead = EndianSwap32(MemoryRead_BE);
		end else begin
			MemoryRead = {32{1'bz}};
		end
	end

	assign GData = EndianSwap32(GMemoryRead_BE);
	
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
