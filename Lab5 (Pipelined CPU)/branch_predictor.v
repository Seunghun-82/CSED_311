`include "opcodes.v" 

module branch_predictor(data1, reset_n, PC, is_flush, is_BJ_type, actual_next_PC, actual_PC, next_PC, update_need, check_predict);

	input [15:0]data1;
	input reset_n;
	input [`WORD_SIZE-1:0] PC;
	input is_BJ_type;
	input [`WORD_SIZE-1:0] actual_next_PC; //computed actual next PC from branch resolve stage
	input [`WORD_SIZE-1:0] actual_PC; // PC from branch resolve stage
	input update_need;
	input is_flush;
	input check_predict;

	output reg [`WORD_SIZE-1:0] next_PC;
	
	//TODO: implement branch predictor

	reg [11:0]BTB_tag[`WORD_SIZE - 1: 0];
	reg [1:0] BTB_2_bit;
	reg [`WORD_SIZE - 1:0] BTB_next_pc[`WORD_SIZE - 1: 0];

	initial begin
		BTB_tag[0] = 12'bz;
		BTB_tag[1] = 12'bz;
		BTB_tag[2] = 12'bz;
		BTB_tag[3] = 12'bz;
		BTB_tag[4] = 12'bz;
		BTB_tag[5] = 12'bz;
		BTB_tag[6] = 12'bz;
		BTB_tag[7] = 12'bz;
		BTB_tag[8] = 12'bz;
		BTB_tag[9] = 12'bz;
		BTB_tag[10] = 12'bz;
		BTB_tag[11] = 12'bz;
		BTB_tag[12] = 12'bz;
		BTB_tag[13] = 12'bz;
		BTB_tag[14] = 12'bz;
		BTB_tag[15] = 12'bz;

		BTB_2_bit = 2'b00;
	end

	always @(*) begin
		if(is_flush) begin
			next_PC = PC;
		end
		else if(is_BJ_type == 1) begin
			if(BTB_tag[PC[3:0]] === PC[15:4] && data1[15:12] < 4) begin // hit and branch
				if(BTB_2_bit[1]) begin
					next_PC = BTB_next_pc[PC[3:0]];
				end
				else begin
					next_PC = PC + 1;
					BTB_next_pc[PC[3:0]] = PC + 1;
				end
			end
			else if(BTB_tag[PC[3:0]] === PC[15:4]) begin // hit and jump
				next_PC = BTB_next_pc[PC[3:0]];
			end
			else begin // miss
				next_PC = PC + 1;
				BTB_tag[PC[3:0]] = PC[15:4];
				BTB_next_pc[PC[3:0]] = PC + 1;
			end
		end
		else begin
			next_PC = PC + 1;
		end
	end

	always @(*) begin
		if(check_predict) begin // branch
			if(update_need) begin
				if(BTB_2_bit == 3) begin
					BTB_2_bit = 3;
				end
				else if(BTB_2_bit == 2) begin
					BTB_2_bit = 3;
				end
				else if(BTB_2_bit == 1) begin
					BTB_2_bit = 3;
				end
				else begin
					BTB_2_bit = 1;
				end
				BTB_next_pc[actual_PC[3:0]] = actual_next_PC;
			end
			else begin
				if(BTB_2_bit == 3) begin
					BTB_2_bit = 2;
				end
				else if(BTB_2_bit == 2) begin
					BTB_2_bit = 0;
				end
				else if(BTB_2_bit == 1) begin
					BTB_2_bit = 0;
				end
				else begin
					BTB_2_bit = 0;
				end
			end
		end
		else if(update_need) begin
			BTB_next_pc[actual_PC[3:0]] = actual_next_PC;
		end
		else begin // branch else
			BTB_2_bit = BTB_2_bit;
		end
	end

endmodule

