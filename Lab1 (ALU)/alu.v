module ALU #(parameter data_width = 16) (
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

// TODO: You should implement the functionality of ALU!
// (HINT: Use 'always @(...) begin ... end')
/*
	YOUR ALU FUNCTIONALITY IMPLEMENTATION...
*/

	wire [data_width - 1 : 0] A_module_wire;
	wire [data_width - 1 : 0] B_module_wire;
	wire [3 : 0] FuncCode_wire;

	wire [data_width - 1 : 0] C_module_wire[3 : 0];
	wire OverflowFlag_wire[3 : 0];
	
	assign A_module_wire = A;
	assign B_module_wire = B;
	assign FuncCode_wire = FuncCode;

	bitwise lab1_1 ( A_module_wire, B_module_wire, FuncCode_wire, C_module_wire[0], OverflowFlag_wire[0]);
	shift lab1_2 ( A_module_wire, B_module_wire, FuncCode_wire, C_module_wire[1], OverflowFlag_wire[1]);
	ADD_SUB lab1_3 ( A_module_wire, B_module_wire, FuncCode_wire, C_module_wire[2], OverflowFlag_wire[2]);
	Others lab_4 ( A_module_wire, B_module_wire, FuncCode_wire, C_module_wire[3], OverflowFlag_wire[3]);

	assign C = C_module_wire[0] | C_module_wire[1] | C_module_wire[2] | C_module_wire[3];
	assign OverflowFlag = OverflowFlag_wire[0] | OverflowFlag_wire[1] | OverflowFlag_wire[2] | OverflowFlag_wire[3];

endmodule

