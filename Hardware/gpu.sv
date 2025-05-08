typedef struct {
	logic[3:0] r, g, b;
} color;

module vga_driver (
    input clk,
    input reset,
    output hsync,
    output vsync,
	 
	 output[3:0] r,
	 output[3:0] g,
	 output[3:0] b,
	 
    output[9:0] x, 
	 output[9:0] y,
	 input color Color
);

	// VGA 640x480 @ 60Hz timing parameters
	parameter H_PIXELS = 640;
	parameter H_FP = 16;
	parameter H_PW = 96;
	parameter H_BP = 48;
	parameter H_TOTAL = H_PIXELS + H_FP + H_PW + H_BP;

	parameter V_PIXELS = 480;
	parameter V_FP = 10;
	parameter V_PW = 2;
	parameter V_BP = 33;
	parameter V_TOTAL = V_PIXELS + V_FP + V_PW + V_BP;

	// Registers for counters
	reg [10:0] h_count = 0;
	reg [10:0] v_count = 0;

	always @(posedge clk) begin
		 if (reset) begin
			  h_count <= 0;
			  v_count <= 0;
		 end else begin
			  if (h_count < H_TOTAL - 1)
					h_count <= h_count + 1;
			  else begin
					h_count <= 0;
					if (v_count < V_TOTAL - 1)
						 v_count <= v_count + 1;
					else
						 v_count <= 0;
			  end
		 end
	end

	// Generate sync signals
	assign hsync = (h_count < (H_PIXELS + H_FP)) || (h_count >= (H_PIXELS + H_FP + H_PW));
	assign vsync = (v_count < (V_PIXELS + V_FP)) || (v_count >= (V_PIXELS + V_FP + V_PW));

	assign x = (h_count < H_PIXELS) ? h_count : 0;
	assign y = (v_count < V_PIXELS) ? v_count : 0;
	
	assign r = (h_count < H_PIXELS && v_count < V_PIXELS) ? Color.r : 0;
	assign g = (h_count < H_PIXELS && v_count < V_PIXELS) ? Color.g : 0;
	assign b = (h_count < H_PIXELS && v_count < V_PIXELS) ? Color.b : 0;
	
endmodule