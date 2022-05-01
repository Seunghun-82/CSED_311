module bitwise #(parameter data_width = 16) (
	input [data_width - 1 : 0] A, 
	input [data_width - 1 : 0] B, 
	input [3 : 0] FuncCode,
       	output reg [data_width - 1: 0] C,
       	output reg OverflowFlag);
always @(*) begin
	if(FuncCode == 4'b0011) begin
		C = ~A;
		OverflowFlag = 1'b0;
	end
	else if(FuncCode == 4'b0100) begin
		C = A & B;
		OverflowFlag = 1'b0;
	end
	else if(FuncCode == 4'b0101) begin
		C = A | B;
		OverflowFlag = 1'b0;
	end
	else if(FuncCode == 4'b0110) begin
		C = ~(A & B);
		OverflowFlag = 1'b0;
	end
	else if(FuncCode == 4'b0111) begin
		C = ~(A | B);
		OverflowFlag = 1'b0;
	end
	else if(FuncCode == 4'b1000) begin
		C = (A ^ B);
		OverflowFlag = 1'b0;
	end
	else if(FuncCode == 4'b1001) begin
		C = ~(A ^ B);
		OverflowFlag = 1'b0;
	end
	else begin
		C = 16'h0000;
		OverflowFlag = 1'b0;
	end
end

endmodule