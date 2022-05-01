`include "opcodes.v"

`define	NumBits	16

module alu (alu_input_1, alu_input_2, instruction, alu_output, clk, inputReady, branch_bit);
	
	input clk;
	input [15:0] alu_input_1;
	input [15:0] alu_input_2;
	input [15:0] instruction;
	input inputReady;
	output reg [15:0] alu_output;	
	output reg branch_bit;

	initial begin
		alu_output = 0;
		branch_bit = 0;
	end
	wire signed [15:0] signed_input_1;
	wire signed [15:0] signed_input_2;
	assign signed_input_1 = alu_input_1;
	assign signed_input_2 = alu_input_2;
	
	always @(negedge inputReady) begin
		branch_bit = 0;
		if(instruction[15:12] == 4'b1111) begin
			case(instruction[5:0])
			0: alu_output <= alu_input_1 + alu_input_2;
			1: alu_output <= alu_input_1 - alu_input_2;
			2: alu_output <= alu_input_1 & alu_input_2;
			3: alu_output <= alu_input_1 | alu_input_2;
			4: alu_output <= ~(alu_input_1);
			5: alu_output <= ~(alu_input_1) + 1;
			6: alu_output <= alu_input_1 << 1;
			7: alu_output <= signed_input_1 >>> 1;
			25: alu_output <= alu_input_1;
			26: alu_output <= alu_input_1;
			endcase
		end
		else if(instruction[15:12] == 4'd4 || instruction[15:12] == 4'd5 || instruction[15:12] == 4'd6 ||
			instruction[15:12] == 4'd7 || instruction[15:12] == 4'd8 ) begin
			case(instruction[15:12])
			4: alu_output <= alu_input_1 + signed_input_2;
			5: alu_output <= alu_input_1 | signed_input_2;
			6: alu_output <= alu_input_2 << 8;
			7: alu_output <= alu_input_1 + signed_input_2;
			8: alu_output <= alu_input_1 + signed_input_2;
			endcase	
		end
		else if(instruction[15:12] == 4'd0 || instruction[15:12] == 4'd1 || instruction[15:12] == 4'd2 || instruction[15:12] == 4'd3) begin
			case(instruction[15:12])
			0: branch_bit = (alu_input_1 != alu_input_2);
			1: branch_bit = (alu_input_1 == alu_input_2);
			2: branch_bit = (alu_input_1 > 0);
			3: branch_bit = (alu_input_1 < 0);
			endcase
		end
		else if(instruction[15:12] == 4'd9 || instruction[15:12] == 4'd10 ) begin
			case(instruction[15:12])
			9: alu_output = signed_input_2;
			10: alu_output = alu_input_2;
			endcase
		end
	end	

endmodule