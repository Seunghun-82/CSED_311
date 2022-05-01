
module forwarding_unit (id_ex_rs1_value, id_ex_rs1_index, id_ex_instruction, id_ex_rs2_value, id_ex_rs2_index, ex_mem_rd_index, ex_mem_reg_write, mem_wb_rd_index, mem_wb_reg_write, rs1_selection, rs2_selection);

	input [15:0] id_ex_rs1_value, id_ex_rs2_value, id_ex_instruction;
	input [1:0] id_ex_rs1_index, id_ex_rs2_index, ex_mem_rd_index, mem_wb_rd_index;
	input ex_mem_reg_write, mem_wb_reg_write;
	
	output reg [1:0] rs1_selection, rs2_selection;

	always @(*) begin
		if((id_ex_rs1_index == ex_mem_rd_index) && ex_mem_reg_write) begin
			rs1_selection = 2'b00;
		end
		else if((id_ex_rs1_index == mem_wb_rd_index) && mem_wb_reg_write) begin
			rs1_selection = 2'b01;
		end
		else begin
			rs1_selection = 2'b10;
		end
		
		if(((id_ex_instruction[15:12] == 15) && (id_ex_instruction[5:0] == 26)) || id_ex_instruction[15:12] == 10) begin
			rs2_selection = 2'b11;
		end 
		else if((id_ex_rs2_index == ex_mem_rd_index) && ex_mem_reg_write) begin
			rs2_selection = 2'b00;
		end
		else if((id_ex_rs2_index == mem_wb_rd_index) && mem_wb_reg_write) begin
			rs2_selection = 2'b01;
		end
		else begin
			rs2_selection = 2'b10;
		end

	end
	
	//TODO: implement alu 
	

endmodule