module sign_extend(instruction, clk, out_sign);
input [15:0] instruction;
input clk;
output reg [15:0] out_sign;


initial begin
	out_sign <= 0;
end

always@(instruction) begin
	if(instruction[15:12] == 4'b1010 && clk == 0) begin
		out_sign = instruction[11] ? {8'b1111, instruction[11:0]}:{8'b0000, instruction[11:0]};
	end
	else if(clk == 0) begin
		out_sign = instruction[7] ? {8'b11111111, instruction[7:0]}:{8'b00000000, instruction[7:0]};
	end
	else begin
		out_sign = out_sign;
	end
end

endmodule
