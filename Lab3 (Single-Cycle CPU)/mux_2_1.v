
module mux_2to_1_anytime(inputReady, bit, first, second, output_data);
	input bit;
	input[15:0] first;
	input[15:0] second;
	input inputReady;
	output reg [15:0] output_data;
	
	initial begin
		output_data = 0;
	end
	
	always@(*) begin
		if(bit == 1 ) begin
			output_data <= second;
		end
		else begin
			output_data <= first;
		end
	end
endmodule