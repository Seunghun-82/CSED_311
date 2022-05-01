`include "opcodes.v"

module alu_control_unit(funct, opcode, clk, funcCode, branchType);
	input clk;
	input [5:0] funct;
	input [3:0] opcode;

	output reg [3:0] funcCode;
	output reg [1:0] branchType;
	
	initial begin
		funcCode[3:0] = 4'b0000;
		branchType[1:0] = 2'b00;
	end

	always@(*) begin
		if(opcode == 4'b0000 || opcode == 4'b0001 || opcode == 4'b0010 || opcode == 4'b0011) begin
			branchType = opcode[1:0];
			funcCode = 4'd9; //branch funcCode == 9
		end
		else if(opcode == 4'd15) begin
			if(funct == 6'd0) begin
				funcCode = 4'd0; // ADD
			end
			else if(funct == 6'd1) begin
				funcCode = 4'd1; // SUB
			end
			else if(funct == 6'd2) begin
				funcCode = 4'd2; // AND
			end
			else if(funct == 6'd3) begin
				funcCode = 4'd3; // ORR
			end
			else if(funct == 6'd4) begin
				funcCode = 4'd4; // NOT
			end
			else if(funct == 6'd5) begin
				funcCode = 4'd5; // TCP
			end
			else if(funct == 6'd6) begin
				funcCode = 4'd6; // SHL
			end
			else if(funct == 6'd7) begin
				funcCode = 4'd7; // SHR
			end
			else if(funct == 6'd25) begin
				funcCode = 4'd12; // JPR
			end
			else if(funct == 6'd26) begin
				funcCode = 4'd13; // JRL
			end
			else if(funct == 6'd28) begin
				funcCode = 4'd14; // WWD
				end
			else if(funct == 6'd29) begin
				funcCode = 4'd15; // HLT
			end
		end
		else if(opcode == 4'd4) begin
			funcCode = 4'd0; //ADI
		end
		else if(opcode == 4'd5) begin
			funcCode = 4'd3; //ORI
		end
		else if(opcode == 4'd6) begin
			funcCode = 4'd8; //LHI
		end
		else if(opcode == 4'd7) begin
			funcCode = 4'd0; //LWD
		end
		else if(opcode == 4'd8) begin
			funcCode = 4'd0; //SWD
		end
		else if(opcode == 4'd9) begin
			funcCode = 4'd10; //JMP
		end
		else if(opcode == 4'd10) begin
			funcCode = 4'd11; //JAL
		end
		else begin
			funcCode = funcCode;
			branchType = branchType;
		end
	end
	
   //TODO: implement ALU control unit
  
endmodule