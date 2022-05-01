`include "opcodes.v" 	   

module cpu (readM, writeM, address, data, ackOutput, inputReady, reset_n, clk);
	output readM;									
	output writeM;								
	output [`WORD_SIZE-1:0] address;	
	inout [`WORD_SIZE-1:0] data;		
	input ackOutput;								
	input inputReady;								
	input reset_n;									
	input clk;				

	wire alu_src, reg_write, mem_read, mem_to_reg, mem_write, branch;
	reg [`WORD_SIZE-1:0] data_in;
	wire [15:0]datapath_data_out;
	wire [15:0] datapath_address_out;

	reg [`WORD_SIZE-1:0]reg_instruction;
	initial begin
		reg_instruction = 0;
	end

	always@(posedge inputReady) begin
		if(!clk) begin
			reg_instruction <= data;
		end
		else begin
			if(inputReady) begin
				reg_instruction <= data;
			end
		end
	end
	
	wire jalr, jal, PctoReg, PCsrc1, PCsrc2, b_cond, ReadM, WriteM;
	wire [15:0] pc_value, immediate, alu_output;
	
	control_unit control(reg_instruction, alu_src, reg_write, mem_read, mem_to_reg, mem_write, jalr, jal, branch, PctoReg, PCsrc1, PCsrc2,
	pc_value, clk, immediate, alu_output, b_cond, reset_n, ackOutput, inputReady, ReadM, WriteM);


	datapath_top_module datapath( alu_src, reg_write, mem_read, mem_to_reg, mem_write, clk, reg_instruction,
	datapath_address_out, datapath_data_out, inputReady, ackOutput, reset_n, branch, pc_value, jalr, jal, PctoReg, PCsrc1, PCsrc2, immediate, alu_output, b_cond);

	assign data = writeM ? datapath_data_out : 16'bz;
	assign address = (!clk) ? pc_value : datapath_address_out;
	assign readM = ReadM;
	assign writeM = WriteM;
																																  
endmodule							  																		  