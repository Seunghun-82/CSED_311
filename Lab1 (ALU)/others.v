module Others #(parameter data_width = 16) (
	input [data_width - 1 : 0] A, 
	input [data_width - 1 : 0] B, 
	input [3 : 0] FuncCode,
       	output reg [data_width - 1: 0] C,
       	output reg OverflowFlag);
// Do not use delay in your implementation.

// You can declare any variables as needed.
/*
	YOUR VARIABLE DECLARATION...
*/

initial begin
	C = 0;
	OverflowFlag = 0;
end   	

always @(*) begin
	if (FuncCode == 4'b 0010) begin
		assign C = A;
		assign OverflowFlag = 0;
	end

	else if(FuncCode == 4'b 1110) begin
		assign C = ~A + 'b1;
		assign OverflowFlag = 0;
	end
	
	else if(FuncCode == 4'b 1111) begin
		assign C = 16'h 0000;
		assign OverflowFlag = 0;

	end

	else begin
		assign C = 16'h 0000;
		assign OverflowFlag = 0;

	end

end
endmodule