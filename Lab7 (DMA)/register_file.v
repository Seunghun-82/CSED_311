`include "opcodes.v" 

module register_file (read_out1, read_out2, read1, read2, dest, write_data, pc_to_reg, reg_write, clk, reset_n);

	input clk, reset_n;
	input [1:0] read1;
	input [1:0] read2;
	input [1:0] dest;
	input reg_write;
	input [`WORD_SIZE-1:0] write_data;
	input pc_to_reg;

	output reg [15:0] read_out1;
	output reg [15:0] read_out2;
	reg [15:0]register[3 : 0];
	
	initial begin
		register[0] = 0;
		register[1] = 0;
		register[2] = 0;
		register[3] = 0;
	end

	assign read_out1 = register[read1];
	assign read_out2 = register[read2];
	
	always@(negedge clk) begin
		if(reg_write == 1) begin
		register[dest] <= write_data;
		end
/*
		else if(pc_to_reg) begin
		register[dest] <= write_data;
		end
*/
		else begin
		register[dest] <= register[dest];
		end
	end
	//TODO: implement register file

endmodule
