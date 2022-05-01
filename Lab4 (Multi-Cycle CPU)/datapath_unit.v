module datapath_top_module (reset_n, clk, pc_value, mem_in_data, i_or_d, mem_read, mem_to_reg, mem_write,
ir_write, pc_to_reg, pc_src, halt, wwd, new_inst, reg_write, alu_src_A, alu_src_B, alu_op, pc_next, bcond, memory_address, memory_data, instruction_reg); 
	input reset_n;
	input clk;
	input [15:0] pc_value;
	input [15:0] mem_in_data;
	input i_or_d, mem_read, mem_write, ir_write, pc_to_reg, pc_src, halt, wwd, new_inst, reg_write;
	input [1:0] alu_op, alu_src_A, alu_src_B, mem_to_reg;
	output [15:0] pc_next, memory_address, memory_data;
	output bcond;
	output reg [15:0] instruction_reg;

	reg [15:0] ALU_OUT;	

	always @(posedge clk) begin
		if(ir_write) begin
			instruction_reg <= mem_in_data;
		end
		else begin
			instruction_reg <= instruction_reg;
		end
	end

	//register_file wire
	wire [15:0] register_out_1, register_out_2;
	reg [1:0] register_read_1_index, register_read_2_index, register_write_reg_index;
	wire [15:0] register_write_data;
	
	initial begin
		register_read_1_index <= 0;
		register_read_2_index <= 0;
		register_write_reg_index <= 0;
		ALU_OUT <= 0;
		instruction_reg <= 0;
	end

	always @(posedge clk) begin
		if(instruction_reg[15:12] == 15) begin
			if(instruction_reg[5:0] == 26) begin
					register_write_reg_index <= 2;
			end
			else begin
				register_read_1_index <= instruction_reg[11:10];
				register_read_2_index <= instruction_reg[9:8];
				register_write_reg_index <= instruction_reg[7:6];
			end
		end
		else if(instruction_reg[15:12] == 10) begin
			register_write_reg_index <= 2;
		end
		else begin
			register_read_1_index <= instruction_reg[11:10];
			register_read_2_index <= instruction_reg[9:8];
			register_write_reg_index <= instruction_reg[9:8];
		end
	end

	wire [15:0] out_mux_data;

	mux4_1 data(mem_to_reg, ALU_OUT, mem_in_data, pc_value, 16'h0000, out_mux_data);

	wire [15:0] register_out1, register_out2;
	
	register_file register(register_out1, register_out2, register_read_1_index, register_read_2_index, register_write_reg_index, out_mux_data, reg_write, pc_to_reg, clk); 

	wire [15:0] out_sign;	

	sign_extend sign_extend(instruction_reg, out_sign);

	wire [15:0] out_mux_A, out_mux_B;

	mux2_1 mux_A(alu_src_A[0], pc_value, register_out1 , out_mux_A);

	mux4_1 mux_B(alu_src_B, register_out2, 16'h0001, out_sign, 16'h0000, out_mux_B);

	wire [3:0] funcCode;
	wire [1:0] branchType;

	alu_control_unit alu_control_unit(instruction_reg[5:0], instruction_reg[15:12], alu_op, clk, funcCode, branchType);

	wire [15:0] C;
	wire overflow_flag, bcond;

	alu ALU(out_mux_A, out_mux_B, funcCode, branchType, C, overflow_flag, bcond, clk);
	always @(posedge clk) begin
		if(alu_op != 2'b01 || alu_op != 2'b11) begin
			ALU_OUT <= C;
		end
		else begin
			ALU_OUT <= ALU_OUT;
		end
	end

	wire [15:0] mux_pc;

	mux2_1 pc(pc_src, C, ALU_OUT, pc_next);

	assign memory_address = ALU_OUT;
	assign memory_data = register_out2;

endmodule