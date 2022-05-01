`include "opcodes.v"

`define NumBits 16

module alu (A, B, func_code, branch_type, C, overflow_flag, bcond, clk);
	input [`NumBits-1:0] A; //input data A
	input [`NumBits-1:0] B; //input data B
	input [3:0] func_code; //function code for the operation
	input [1:0] branch_type; //branch type for bne, beq, bgz, blz
	input clk;
	output reg [`NumBits-1:0] C; //output data C
	output reg overflow_flag;
	output reg bcond; //1 if branch condition met, else 0

	wire signed [15:0] A_singed;
	wire signed [15:0] B_singed;
	assign A_singed = A;
	assign B_singed = B;
	
	always@(*) begin
		if(func_code == 4'd0) begin
			C = A + B;
			overflow_flag = ((A[15] & B[15] & (~C[15])) | ((~A[15]) & (~B[15]) & C[15]));
		end
		else if(func_code == 4'd1) begin
			C = A - B;
			overflow_flag = ((A[15] & (~B[15]) & (~C[15])) | ((~A[15]) & B[15] & C[15]));
		end
		else if(func_code == 4'd2) begin
			C = A & B;
		end
		else if(func_code == 4'd3) begin
			C = A | B;
		end
		else if(func_code == 4'd4) begin
			C = ~(A);
		end
		else if(func_code == 4'd5) begin
			C = ~(A) + 1;
		end
		else if(func_code == 4'd6) begin
			C = A << 1;
		end
		else if(func_code == 4'd7) begin
			C = A_singed >>> 1;
		end
		else if(func_code == 4'd8) begin
			C = B << 8 ;
		end
		else if(func_code == 4'd9) begin // branch
			if(branch_type == 0) begin
				bcond = (A_singed != B_singed);
			end
			else if(branch_type == 1) begin
				bcond = (A_singed == B_singed);
			end
			else if(branch_type == 2) begin
				bcond = (A_singed > 0);
			end
			else begin
				bcond = (A_singed < 0);
			end
		end
		else if(func_code == 4'd10) begin
			C = B;
		end
		else if(func_code == 4'd11) begin
			C = B;
		end
		else if(func_code == 4'd12) begin
			C = A;
		end
		else if(func_code == 4'd13) begin
			C = A;
		end
		else if(func_code == 4'd14) begin
			C = A;
		end
		else if(func_code == 4'd15) begin
			C = C;
		end
	end
	
   //TODO: implement ALU
   
endmodule