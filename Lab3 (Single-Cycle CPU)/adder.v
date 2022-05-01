module alu (adder_input_1, adder_input_2, adder_output);

	input [15:0] adder_input_1;
	input [15:0] adder_input_2;
	output [15:0] adder_output;	
	wire signed [15:0] signed_adder_input_2;

	assign signed_adder_input_2 = adder_input_2; 

	assign adder_output = adder_input_1 + signed_adder_input_2;
	
endmodule