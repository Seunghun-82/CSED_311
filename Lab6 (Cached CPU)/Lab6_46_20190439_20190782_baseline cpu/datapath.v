`include "opcodes.v"

module datapath(clk, reset_n, read_m1, address1, data1, read_m2, write_m2, address2, data2, num_inst, output_port, is_halted,
pc_value, pc_write_cond, i_or_d, mem_to_reg, ir_write, pc_to_reg, pc_src, halt, wwd, reg_write, con_read_m2, con_write_m2, if_id_instruction_reg,
alu_src, bcond, if_id_mux_con, if_id_pc_next, is_stall, jalr, id_ex_jalr, pc_value_alu_out, is_BJ_type_update, id_ex_is_BJ_type_update,
b_j_check, jalr_check, if_id_pc_reg, id_ex_pc_reg, mem_stall);

	input clk;
	input reset_n;

	output read_m1;
	output [`WORD_SIZE-1:0] address1;
	output read_m2;
	output write_m2;
	output [`WORD_SIZE-1:0] address2, pc_value_alu_out;
	output [15:0] if_id_pc_next;

	input [`WORD_SIZE-1:0] data1;
	inout [`WORD_SIZE-1:0] data2;
	input [`WORD_SIZE-1:0] pc_value;
	input jalr;

	output b_j_check, jalr_check;
	output reg bcond, id_ex_jalr, id_ex_is_BJ_type_update;
	output reg [`WORD_SIZE-1:0] num_inst;
	output reg [`WORD_SIZE-1:0] output_port;
	output reg [15:0]if_id_instruction_reg;
	output is_halted;
	output mem_stall;
	output is_stall;

	input i_or_d, ir_write, pc_src, is_BJ_type_update;
	input pc_to_reg, halt, wwd, reg_write, con_read_m2, con_write_m2, alu_src, pc_write_cond;
	input [1:0] mem_to_reg, if_id_mux_con;

	wire [15:0] id_ex_alu_output;
	output reg [15:0]if_id_pc_reg, id_ex_pc_reg;
	reg [15:0]mem_wb_instruction, ex_mem_pc_reg, mem_wb_pc_reg;
	reg id_ex_pc_to_reg, ex_mem_pc_to_reg, mem_wb_pc_to_reg;
	reg if_id_F, id_ex_F;

	reg [15:0] id_ex_reg1, id_ex_reg2, id_ex_instruction, ex_mem_alu_value, id_ex_sign_out;
	reg [1:0] id_ex_reg_index1, id_ex_reg_index2, id_ex_rd_index; 
	reg [1:0] ex_mem_rd_index;
	reg id_ex_write_m2, id_ex_read_m2, id_ex_reg_write, id_ex_halt, id_ex_wwd, id_ex_alu_src, id_ex_S, ex_mem_jalr ;
	reg ex_mem_write_m2, ex_mem_read_m2, ex_mem_reg_write, ex_mem_halt, ex_mem_wwd, ex_mem_S, ex_mem_F;
	reg mem_wb_write_m2, mem_wb_read_m2, mem_wb_halt, mem_wb_wwd, mem_wb_S, mem_wb_F;
	reg mem_counter;

	initial begin
		num_inst = -3;
		mem_counter = 0;
	end

	always @(posedge clk) begin
		if(is_stall || mem_counter) begin
			if_id_pc_reg <= if_id_pc_reg;
			if_id_instruction_reg <= if_id_instruction_reg;

		end
		else if(id_ex_jalr && !(jalr_check)) begin
			if_id_pc_reg <= if_id_pc_reg;
			if_id_instruction_reg <= 16'bz;

		end
		else if(is_BJ_type_update && !(b_j_check)) begin
			if_id_pc_reg <= if_id_pc_reg;
			if_id_instruction_reg <= 16'bz;

		end

		else begin
			if_id_pc_reg <= pc_value;      //reg pc? ?? ?? ?
        		if_id_instruction_reg<= data1;      //instruction ????? ? 

		end
	end

	wire [15:0]sign_out; //sign_output	

	sign_extend SIGN (if_id_instruction_reg, sign_out); 

	wire [15:0] read_out1, read_out2, write_data;
	reg [1:0] register_read_1_index, register_read_2_index, register_write_reg_index;
	reg [1:0] mem_wb_rd_index;

	always @(*) begin
		if(if_id_instruction_reg[15:12] == 15) begin
			if(if_id_instruction_reg[5:0] == 26) begin
					register_write_reg_index = 2;
					register_read_1_index = if_id_instruction_reg[11:10];
			end
			else begin
				register_read_1_index = if_id_instruction_reg[11:10];
				register_read_2_index = if_id_instruction_reg[9:8];
				register_write_reg_index = if_id_instruction_reg[7:6];
			end
		end
		else if(if_id_instruction_reg[15:12] == 10) begin
			register_write_reg_index = 2;
		end
		else begin
			register_read_1_index = if_id_instruction_reg[11:10];
			register_read_2_index = if_id_instruction_reg[9:8];
			register_write_reg_index = if_id_instruction_reg[9:8];
		end
	end

	wire [15:0] mem_wb_mux_out, write_back_data, branch_rs1_out, branch_rs2_out;	
	reg mem_wb_reg_write;

	wire [1:0] branch_rs1_selection, branch_rs2_selection;

	mux2_1 REGISTER_IN (mem_wb_pc_to_reg, mem_wb_mux_out, mem_wb_pc_reg, write_back_data);

	register_file REGISTER (read_out1, read_out2, register_read_1_index, register_read_2_index, mem_wb_rd_index, write_back_data, pc_to_reg, mem_wb_reg_write, clk, reset_n); // WRITE register index ?? ??????
	
	forwarding_unit branch_forwarding(16'bz, register_read_1_index, if_id_instruction_reg, 16'bz, register_read_2_index,
	id_ex_rd_index, id_ex_reg_write, ex_mem_rd_index, ex_mem_reg_write, branch_rs1_selection, branch_rs2_selection);

	mux4_1 branch_rs1_mux (branch_rs1_selection, id_ex_alu_output, ex_mem_alu_value, read_out1, 16'bz, branch_rs1_out);

	mux4_1 branch_rs2_mux (branch_rs2_selection, id_ex_alu_output, ex_mem_alu_value, read_out2, 16'bz, branch_rs2_out); 

	wire signed [15:0] signed_read_out1;
	assign signed_read_out1 = branch_rs1_out;
	always @(*) begin
		if(if_id_instruction_reg[15:12] == 0) begin
			if(branch_rs1_out != branch_rs2_out) begin
				bcond = 1'b1;
			end
			else begin
				bcond = 1'b0;
			end
		end
		else if(if_id_instruction_reg[15:12] == 1) begin
			if(branch_rs1_out == branch_rs2_out) begin
				bcond = 1'b1;
			end
			else begin
				bcond = 1'b0;
			end
		end
		else if(if_id_instruction_reg[15:12] == 2) begin
			if(signed_read_out1 > 0) begin
				bcond = 1'b1;
			end
			else begin
				bcond = 1'b0;
			end
		end
		else if(if_id_instruction_reg[15:12] == 3) begin
			if(signed_read_out1 < 0) begin
				bcond = 1'b1;
			end
			else begin
				bcond = 1'b0;
			end
		end
		else begin
			bcond = 1'b0;
		end
	end

	wire [15:0] if_id_adder_out, if_id_pc_mux_out;

	adder if_id_adder (sign_out, if_id_pc_reg, if_id_adder_out);

	mux4_1 if_id_pc_mux (if_id_mux_con, sign_out, if_id_adder_out,  16'bz, 16'bz, if_id_pc_mux_out);

	assign b_j_check = pc_write_cond ? (bcond ? if_id_pc_mux_out == pc_value - 1 : if_id_pc_reg === if_id_pc_mux_out):((pc_value -1) === if_id_pc_mux_out);

	assign if_id_pc_next = (pc_write_cond && !(bcond) && (if_id_pc_reg != if_id_pc_mux_out)) ? if_id_pc_reg : if_id_pc_mux_out;

	always @(posedge clk) begin
		if(mem_counter == 1) begin
			id_ex_is_BJ_type_update <= id_ex_is_BJ_type_update;
			id_ex_jalr <= id_ex_jalr;
			id_ex_pc_to_reg <= id_ex_pc_to_reg;
			id_ex_pc_reg <= id_ex_pc_reg;
			id_ex_S <= id_ex_S;
			id_ex_reg1 <= id_ex_reg1;
			id_ex_reg2 <= id_ex_reg2;
			id_ex_sign_out <= id_ex_sign_out;
			id_ex_reg_index1 <= id_ex_reg_index1;
			id_ex_reg_index2 <= id_ex_reg_index2;
			id_ex_rd_index <= id_ex_rd_index;
			id_ex_write_m2 <= id_ex_write_m2;
			id_ex_read_m2 <= id_ex_read_m2;
			id_ex_reg_write <= id_ex_reg_write;
			id_ex_halt <= id_ex_halt;
			id_ex_wwd <= id_ex_wwd;
			id_ex_alu_src <= id_ex_alu_src;
			id_ex_instruction <= id_ex_instruction;
			id_ex_F <= id_ex_F;
		end
		else begin
			if(is_stall) begin
				id_ex_write_m2 <= 1'b0;
				id_ex_read_m2 <= 1'b0;
				id_ex_reg_write <= 1'b0;
				id_ex_halt <= 1'b0;
				id_ex_wwd <= 1'b0;
				id_ex_alu_src <= 1'b0;
				id_ex_instruction <= 16'bz;
				end
			else if(id_ex_jalr && !(jalr_check)) begin
				id_ex_write_m2 <= 1'b0;
				id_ex_read_m2 <= 1'b0;
				id_ex_reg_write <= 1'b0;
				id_ex_halt <= 1'b0;
				id_ex_wwd <= 1'b0;
				id_ex_alu_src <= 1'b0;
				id_ex_instruction <= 16'bz;
				id_ex_F <= 1'b1;
			end
			else if (if_id_instruction_reg === 16'bz) begin
				id_ex_write_m2 <= 1'b0;
				id_ex_read_m2 <= 1'b0;
				id_ex_reg_write <= 1'b0;
				id_ex_halt <= 1'b0;
				id_ex_wwd <= 1'b0;
				id_ex_alu_src <= 1'b0;
				id_ex_instruction <= 16'bz;
				id_ex_F <= 1'b0;
			end
			else begin
				id_ex_write_m2 <= con_write_m2;
				id_ex_read_m2 <= con_read_m2;
				id_ex_reg_write <= reg_write;
				id_ex_halt <= halt;
				id_ex_wwd <= wwd;
				id_ex_alu_src <= alu_src;
				id_ex_instruction <= if_id_instruction_reg;
				id_ex_F <= (is_BJ_type_update && !(b_j_check)) || (id_ex_jalr && !(jalr_check));
			end
		id_ex_is_BJ_type_update <= is_BJ_type_update;
		id_ex_jalr <= jalr;
		id_ex_pc_to_reg <= pc_to_reg;
		id_ex_pc_reg <= if_id_pc_reg;
		id_ex_S <= is_stall;
		id_ex_reg1 <= read_out1;
		id_ex_reg2 <= read_out2;
		id_ex_sign_out <= sign_out;
		id_ex_reg_index1 <= register_read_1_index;
		id_ex_reg_index2 <= register_read_2_index;
		id_ex_rd_index <= register_write_reg_index;
		end
	end

	hazard_detect HAZARD (if_id_instruction_reg, id_ex_rd_index, id_ex_read_m2, is_stall);

	wire [15:0]id_ex_alu_mux1_out, id_ex_alu_mux2_out;	
	wire [1:0] rs1_selection, rs2_selection;
	forwarding_unit FORWARDING(id_ex_reg1, id_ex_reg_index1, id_ex_instruction , id_ex_reg2, id_ex_reg_index2, ex_mem_rd_index, ex_mem_reg_write, mem_wb_rd_index, mem_wb_reg_write, rs1_selection, rs2_selection);

	wire[15:0] id_ex_mux_out;

	mux4_1 id_ex_alu_input1_mux (rs1_selection, ex_mem_alu_value, mem_wb_mux_out, id_ex_reg1, 16'h0000, id_ex_alu_mux1_out);
	mux4_1 id_ex_alu_input2_mux (rs2_selection, ex_mem_alu_value, mem_wb_mux_out, id_ex_reg2, id_ex_pc_reg, id_ex_alu_mux2_out);

	mux2_1 if_id_mux (id_ex_alu_src, id_ex_alu_mux2_out, id_ex_sign_out, id_ex_mux_out);

	wire [3:0] id_ex_funcCode;
	wire [1:0] id_ex_branchType; 	

	alu_control_unit ALU_CONTROL(id_ex_instruction[5:0], id_ex_instruction[15:12], clk, id_ex_funcCode, id_ex_branchType);

	wire id_ex_overflow, id_ex_bcond;
	alu id_ex_main_alu (id_ex_alu_mux1_out, id_ex_mux_out, id_ex_funcCode, id_ex_branchType, id_ex_alu_output, id_ex_overflow, id_ex_bcond);

	assign jalr_check = ((if_id_pc_reg - 1) === id_ex_alu_output);
	assign pc_value_alu_out = id_ex_alu_output;

	reg [15:0] ex_mem_reg2, ex_mem_instruction;

	always @(posedge clk) begin
		if(mem_counter == 1) begin
			ex_mem_alu_value <= ex_mem_alu_value;
			ex_mem_reg2 <= ex_mem_reg2;
			ex_mem_instruction <= ex_mem_instruction;
			ex_mem_rd_index <= ex_mem_rd_index;
			ex_mem_write_m2 <= ex_mem_write_m2;
			ex_mem_read_m2 <= ex_mem_read_m2;
			ex_mem_reg_write <= ex_mem_reg_write;
			ex_mem_halt <= ex_mem_halt;
			ex_mem_wwd <= ex_mem_wwd;
			ex_mem_S <= ex_mem_S;
			ex_mem_pc_reg <= ex_mem_pc_reg;
			ex_mem_pc_to_reg <= ex_mem_pc_to_reg;
			ex_mem_jalr <= ex_mem_jalr;
			ex_mem_F <= ex_mem_F;
			mem_counter <= 0;
		end
		else begin
			if(id_ex_jalr && !(jalr_check)) begin
				ex_mem_F <= 1'b1;
			end
			else begin
				ex_mem_F <= id_ex_F;
			end
			if(id_ex_read_m2 || id_ex_write_m2) begin
				mem_counter <= 1;
			end
			else begin
				mem_counter <= 0;
			end
			ex_mem_alu_value <= id_ex_alu_output;
			ex_mem_reg2 <= id_ex_alu_mux2_out;
			ex_mem_instruction <= id_ex_instruction;
			ex_mem_rd_index <= id_ex_rd_index;
			ex_mem_write_m2 <= id_ex_write_m2;
			ex_mem_read_m2 <= id_ex_read_m2;
			ex_mem_reg_write <= id_ex_reg_write;
			ex_mem_halt <= id_ex_halt;
			ex_mem_wwd <= id_ex_wwd;
			ex_mem_S <= id_ex_S;
			ex_mem_pc_reg <= id_ex_pc_reg;
			ex_mem_pc_to_reg <= id_ex_pc_to_reg;
			ex_mem_jalr <= id_ex_jalr;
		end
	end

	assign address2 = ex_mem_alu_value;
	assign data2 = ex_mem_write_m2 ? ex_mem_reg2 : 16'bz;

	reg [15:0] mem_wb_memory_value, mem_wb_alu_value; 

	always @(posedge clk) begin
		if(mem_counter == 1) begin
			mem_wb_memory_value <= 16'bz;
			mem_wb_alu_value <= 16'bz;
			mem_wb_instruction <= 16'bz;
			mem_wb_rd_index <= 0;
			mem_wb_write_m2 <= 0;
			mem_wb_read_m2 <= 0;
			mem_wb_reg_write <= 0;
			mem_wb_halt <= 0;
			mem_wb_wwd <= 0;
			mem_wb_S <= 0;
			mem_wb_F <= 0;
			mem_wb_pc_reg <= 16'bz;
			mem_wb_pc_to_reg <= 16'bz;
		end
		else begin
			mem_wb_memory_value <= data2;
			mem_wb_alu_value <= ex_mem_alu_value;
			mem_wb_instruction <= ex_mem_instruction;
			mem_wb_rd_index <= ex_mem_rd_index;
			mem_wb_write_m2 <= ex_mem_write_m2;
			mem_wb_read_m2 <= ex_mem_read_m2;
			mem_wb_reg_write <= ex_mem_reg_write;
			mem_wb_halt <= ex_mem_halt;
			mem_wb_wwd <= ex_mem_wwd;
			mem_wb_S <= ex_mem_S;
			mem_wb_F <= ex_mem_F;
			mem_wb_pc_reg <= ex_mem_pc_reg;
			mem_wb_pc_to_reg <= ex_mem_pc_to_reg;
		end
	end

	always @(posedge clk) begin
		if(ex_mem_instruction === 16'bz || mem_counter) begin
			num_inst <= num_inst;
		end
		else begin
			if(ex_mem_S) begin
				num_inst <= num_inst;
			end
			else begin
				num_inst <= num_inst + 1;
			end
		end
	end

	assign output_port = mem_wb_wwd ? mem_wb_alu_value : 16'bz;
	assign is_halted = mem_wb_halt;
	assign read_m2 = ex_mem_read_m2;
	assign write_m2 = ex_mem_write_m2;
	assign mem_stall = id_ex_write_m2 || id_ex_read_m2;
	mux2_1 mem_wb_mux(mem_wb_read_m2, mem_wb_alu_value, mem_wb_memory_value , mem_wb_mux_out);

	//TODO: implement datapath of pipelined CPU

endmodule


