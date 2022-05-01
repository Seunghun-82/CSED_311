`timescale 1ns/1ns
`define WORD_SIZE 16    // data and address word size

module cpu(clk, reset_n, read_m, write_m, address, data, num_inst, output_port, is_halted);
	input clk;
	input reset_n;
	
	output read_m;
	output write_m;
	output [`WORD_SIZE-1:0] address;

	inout [`WORD_SIZE-1:0] data;

	output [`WORD_SIZE-1:0] num_inst;		// number of instruction executed (for testing purpose)
	output reg [`WORD_SIZE-1:0] output_port;	// this will be used for a "WWD" instruction
	output is_halted;

	// TODO : implement multi-cycle CPU
	initial begin
		output_port = 16'h0000;
	end

	wire [15:0] pc_next, instruction_reg, pc, memory_address, memory_data;
	wire bcond, pc_write_cond, pc_write, i_or_d, mem_read, mem_write, ir_wirte, pc_to_reg, pc_src, halt, wwd, new_inst, reg_write;
	wire [1:0] alu_src_A, alu_src_B, alu_op, mem_to_reg;

	control_unit control_path(reset_n, pc_next, bcond, instruction_reg[15:12], instruction_reg[5:0], clk, pc_write_cond, pc_write, i_or_d, read_m, mem_to_reg, write_m, ir_write,
	pc_to_reg, pc_src, is_halted, wwd, new_inst, reg_write, alu_src_A, alu_src_B, alu_op, pc, num_inst);

	datapath_top_module data_path(reset_n, clk, pc, data, i_or_d, mem_read, mem_to_reg, mem_write,
	ir_write, pc_to_reg, pc_src, halt, wwd, new_inst, reg_write, alu_src_A, alu_src_B, alu_op, pc_next, bcond, memory_address, memory_data, instruction_reg); 

	wire [15:0] top_mux_out;

	mux2_1 top(i_or_d, pc, memory_address, top_mux_out);

	assign data = write_m ? memory_data : 16'bz;
	assign address = top_mux_out;
	always@(posedge clk) begin
		if(wwd) begin
			output_port <= memory_address;
		end
		else begin
			output_port <= output_port;
		end
	end
endmodule
