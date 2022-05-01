`timescale 1ns/1ns
`define WORD_SIZE 16    // data and address word size

module cpu(clk, reset_n, read_m1, address1, data1, read_m2, write_m2, address2, data2, num_inst, output_port, is_halted);

	input clk;
	input reset_n;

	output read_m1;
	output [`WORD_SIZE-1:0] address1;
	output read_m2;
	output write_m2;
	output [`WORD_SIZE-1:0] address2;

	input [`WORD_SIZE-1:0] data1;
	inout [`WORD_SIZE-1:0] data2;

	output [`WORD_SIZE-1:0] num_inst;
	output [`WORD_SIZE-1:0] output_port;
	output is_halted;

	reg [`WORD_SIZE-1:0]pc_value;
	//TODO: implement pipelined CPU

	wire [`WORD_SIZE-1:0] control_unit_instruction;
	wire bcond;

	wire pc_write_cond, pc_write, i_or_d, read_m1, con_read_m2, con_write_m2, ir_write, pc_src, is_BJ_type, update_need, is_flush, check_predict;
	wire pc_to_reg, halt, wwd, reg_write, alu_src, is_stall, jalr, id_ex_jalr, is_BJ_type_update, id_ex_is_BJ_type_update, b_j_check, jalr_check;
	wire [1:0] mem_to_reg, if_id_mux_con;
	wire [15:0] pc_value_next, if_id_pc_next;
	wire [15:0] control_unit_data, pc_value_alu_out, actual_next_PC, actual_PC, next_PC, if_id_pc_reg, id_ex_pc_reg;
	adder PC(pc_value, 16'h0001, pc_value_next);

	initial begin
		pc_value = 16'h0000;
	end

	control_unit CONTROL(reset_n, bcond, control_unit_data[15:12], control_unit_data[5:0], clk, pc_write_cond, pc_write, i_or_d, mem_to_reg, ir_write,
	pc_to_reg, pc_src, halt, wwd, reg_write, read_m1, con_read_m2, con_write_m2, alu_src, if_id_mux_con, jalr, id_ex_jalr, is_BJ_type_update);

	datapath DATA(clk, reset_n, read_m1, address1, data1, read_m2, write_m2, address2, data2, num_inst, output_port, is_halted, pc_value_next,
	pc_write_cond, i_or_d, mem_to_reg, ir_write, pc_to_reg, pc_src, halt, wwd, reg_write, con_read_m2, con_write_m2, control_unit_instruction,
	alu_src, bcond, if_id_mux_con, if_id_pc_next, is_stall, jalr, id_ex_jalr, pc_value_alu_out, is_BJ_type_update,
	id_ex_is_BJ_type_update, b_j_check, jalr_check, if_id_pc_reg, id_ex_pc_reg);

	branch_predictor PREDICTOR(data1, reset_n, pc_value, is_flush, is_BJ_type, actual_next_PC, actual_PC - 1 , next_PC, update_need, check_predict);

	assign is_BJ_type = ((data1[15:12] < 4) || (data1[15:12] == 9 || data1[15:12] == 10)
		|| (data1[15:12] == 15 && (data1[5:0] == 25 || data1[5:0] == 26)));
	assign update_need = pc_src && (!jalr) || bcond || id_ex_jalr;
	assign is_flush = (id_ex_jalr && !(jalr_check)) || (!(b_j_check) && is_BJ_type_update) || is_stall;
	
	assign check_predict = pc_write_cond;
	assign actual_next_PC = id_ex_jalr ? pc_value_alu_out : if_id_pc_next;
	assign actual_PC = id_ex_jalr ? id_ex_pc_reg : if_id_pc_reg;

	always @(posedge clk) begin
		if(!reset_n) begin
			pc_value <= pc_value;
		end
		else begin
			if((id_ex_jalr && !(jalr_check))) begin
				pc_value <= pc_value_alu_out;
			end
			else if((!(b_j_check) && is_BJ_type_update)) begin
				pc_value <= if_id_pc_next;
			end
			else begin
				pc_value <= next_PC;
			end
		end
	end

/*
	always @(posedge clk) begin
		if(!reset_n) begin
			pc_value <= pc_value;
		end
		else if(id_ex_jalr) begin
			pc_value <= pc_value_alu_out;
		end
		else begin
			if(is_stall) begin
				pc_value <= pc_value;
			end
			else begin
				if(pc_src || (pc_write_cond && bcond)) begin
					pc_value <= if_id_pc_next;
				end
				else begin
					pc_value <= pc_value_next;
				end
			end
		end
	end
*/
 //always not taken pc_value update	
	assign control_unit_data =  (is_stall) ? control_unit_instruction : (((id_ex_jalr && !(jalr_check)) || (!(b_j_check) && is_BJ_type_update)) ? 16'bz : data1);
	assign address1 = pc_value;

endmodule




