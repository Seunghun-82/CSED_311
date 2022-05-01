`include "opcodes.v"

module hazard_detect(IFID_IR, IDEX_rd, IDEX_M_mem_read, is_stall);

	input [`WORD_SIZE-1:0] IFID_IR;
	input [1:0] IDEX_rd;
	input IDEX_M_mem_read;
	
	output is_stall;

	//TODO: implement hazard detection unit
	reg use_rs1, use_rs2;
	reg check_bit;
	wire is_stall;

	initial begin
		use_rs1 = 0;
		use_rs2 = 0;
		check_bit = 0;
	end

	always @(*) begin
		if(IDEX_rd === 2'bz || IFID_IR === 16'bz) begin
		check_bit = 1;
		end
		else begin
			if(IFID_IR[15:12] == `JMP_OP || IFID_IR[15:12] == `JAL_OP ||(IFID_IR[15:12] == 15 && (IFID_IR[5:0] == 27 || IFID_IR[5:0] == 29))) begin
				use_rs1 = 0;
				use_rs2 = 0;
			end
			else if (IFID_IR[15:12] == `LHI_OP) begin
				use_rs1 = 0;
				use_rs2 = 1;
			end
			else if (
			(IFID_IR[15:12] == 15 && (IFID_IR[5:0] < 8 && 3 < IFID_IR[5:0] || IFID_IR[5:0] == 28 || IFID_IR[5:0] == 25|| IFID_IR[5:0] == 26)) 
					|| IFID_IR[15:12] == 2 || IFID_IR[15:12] == 3) begin
				use_rs1 = 1;
				use_rs2 = 0;
			end
			else begin
				use_rs1 = 1;
				use_rs2 = 1;
			end
		check_bit = 0;
		end
	end

		
	assign is_stall = check_bit ? 0 : (((IFID_IR[11:10] == IDEX_rd) && use_rs1) || ((IFID_IR[9:8] == IDEX_rd) && use_rs2)) && IDEX_M_mem_read;

endmodule