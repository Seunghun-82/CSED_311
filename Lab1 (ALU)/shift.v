module shift #(parameter data_width = 16) (
	input [data_width - 1 : 0] A, 
	input [data_width - 1 : 0] B, 
	input [3 : 0] FuncCode,
       	output reg [data_width - 1: 0] C,
       	output reg OverflowFlag);

reg signed [data_width - 1 : 0] A_copy;
assign A_copy = A;

always @(*) begin
	if(FuncCode == 4'b1010) begin
		C = A << 1;
		OverflowFlag = 1'b0;
	end
	else if(FuncCode == 4'b1011) begin
		C = A >> 1;
		OverflowFlag = 1'b0;
	end
	else if(FuncCode == 4'b1100) begin
		C = A <<< 1;
		OverflowFlag = 1'b0;
	end
	else if(FuncCode == 4'b1101) begin
		C = A_copy >>> 1;
		OverflowFlag = 1'b0;
	end
	else begin
		C = 16'h0000;
		OverflowFlag = 1'b0;
	end
end

endmodule