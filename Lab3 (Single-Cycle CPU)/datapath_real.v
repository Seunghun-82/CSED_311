module datapath_top_module ( alu_src, reg_write, mem_read, mem_to_reg, mem_write, clk, instruction, datapath_address_out,
datapath_data_out, inputReady, ackOutput, reset_n, branch, pc_value, jalr, jal, PctoReg, PCsrc1, PCsrc2, immediate, cpu_alu_output, b_cond); 
	output [15:0]datapath_data_out;
	output reg [15:0]datapath_address_out;
	output [15:0] immediate;
	output [15:0] cpu_alu_output;
	output b_cond;
	input [15:0] pc_value;
	input reset_n;
	input alu_src;
	input jalr;
	input jal;
	input PctoReg;
	input PCsrc1;
	input PCsrc2;

	input reg_write;
	input mem_read;
	input mem_to_reg;
	input mem_write;
	input clk;
	input [15:0] instruction;
	input inputReady;
	input ackOutput;
	input branch;
	//register_file wire
	wire [15:0] register_out_1, register_out_2;
	reg [1:0] register_read_1_index, register_read_2_index, register_write_reg_index;
	wire [15:0] register_write_data;
	
	initial begin
		register_read_1_index = 0;
		register_read_2_index = 0;
		register_write_reg_index = 0;
	end

	always @(instruction) begin
		if(!clk) begin
			if(instruction[15:12] == 15) begin
				if(instruction[5:0] == 26) begin
					register_write_reg_index <= 2;
				end
				else begin
					register_read_1_index <= instruction[11:10];
					register_read_2_index <= instruction[9:8];
					register_write_reg_index <= instruction[7:6];
				end
			end
			else if(instruction[15:12] == 10 ) begin
				register_write_reg_index <= 2;
			end
			else begin
				register_read_1_index <= instruction[11:10];
				register_read_2_index <= instruction[9:8];
				register_write_reg_index <= instruction[9:8];
			end
		end
		
	end
	

	
	//mux_2to_1 write_data_selection wire
	wire [15:0] write_data_selection_output_data;
	
	//sign_extend wire
	wire [15:0] sign_extend_out_wire;

	//mux_2to_1 ALU_src selection wire
	wire [15:0] alu_input_2;

	//alu wire
	wire [15:0] alu_output;
	wire bcond;

	//mux_2to_1 memory selection
	wire [15:0] memory_read_out;

	mux_2to_1_anytime write_data_selection(inputReady, PctoReg, memory_read_out, pc_value, write_data_selection_output_data);	

	register_file register( register_out_1, register_out_2, register_read_1_index, register_read_2_index, register_write_reg_index ,
	write_data_selection_output_data, reg_write, clk, inputReady, ackOutput, PctoReg);

	sign_extend sign_extend(instruction, clk, sign_extend_out_wire);

	mux_2to_1_anytime ALU_src_selection(inputReady, alu_src, register_out_2, sign_extend_out_wire, alu_input_2);

	alu alu_examine(register_out_1, alu_input_2, instruction, alu_output, clk, inputReady, bcond);

	mux_2to_1_anytime momory_read_data_selection(mem_to_reg, mem_to_reg, alu_output, instruction, memory_read_out);

	assign datapath_data_out = register_out_2;
	assign datapath_address_out = alu_output;
	assign b_cond = bcond;
	assign immediate = sign_extend_out_wire;
	assign cpu_alu_output = alu_output;

endmodule