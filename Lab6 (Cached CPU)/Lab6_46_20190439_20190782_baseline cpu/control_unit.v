`include "opcodes.v" 

module control_unit(reset_n, bcond, opcode, func_code, clk, pc_write_cond, pc_write, i_or_d, mem_to_reg, ir_write,
pc_to_reg, pc_src, halt, wwd, reg_write, read_m1, read_m2, write_m2, alu_src, if_id_mux_con, jalr, id_ex_jalr, is_BJ_type_update);

	input [3:0] opcode;
	input [5:0] func_code;
	input clk;
	input reset_n;
	input bcond;
	input id_ex_jalr;

	output reg pc_write_cond, pc_write, i_or_d, read_m1, read_m2, write_m2, ir_write, pc_src, alu_src, jalr;
  	//additional control signals. pc_to_reg: to support JAL, JRL. halt: to support HLT. wwd: to support WWD. new_inst: new instruction start
	output reg pc_to_reg, halt, wwd, reg_write, is_BJ_type_update;
	output reg [1:0] mem_to_reg, if_id_mux_con;

	//TODO : implement control unit
	initial begin
		read_m1 = 1'b1;
		read_m2 = 1'b0;
		write_m2 = 1'b0;
		pc_write_cond = 1'b0; //branch then 1
		pc_write= 1'b0; //if pc_wirte == 1 then pc update, fetch and jump then 1
		i_or_d = 1'b0; //decide memory address 
		mem_to_reg = 2'b00;

		ir_write = 1'b0;
		pc_src = 1'b0; //if jump|branch then 1 
		alu_src = 1'b0;

		pc_to_reg = 1'b0;
		halt = 1'b0;
		wwd = 1'b0;
		jalr = 1'b0;

		reg_write = 1'b0; 
		if_id_mux_con = 2'b00;
		is_BJ_type_update = 1'b0;
	end

	always @(posedge clk) begin
		if (opcode == 4'd15) begin
			pc_write_cond <= 1'b0; //branch then 1
			pc_write<= 1'b1; //if pc_wirte == 1 then pc update, fetch and jump then 1

			read_m1 <= 1'b1;
			read_m2 <= 1'b0;
			write_m2 <= 1'b0;
			alu_src <= 1'b0;

			reg_write <= 1'b0;

			if(func_code == 6'd25) begin //JPR
				halt <= 1'b0;
				wwd <= 1'b0;
				mem_to_reg <= 2'b00;
				reg_write <= 1'b0;
				if_id_mux_con <= 2'b10;

				pc_src <= 1'b1;
				pc_to_reg <= 1'b0;
				jalr <= 1'b1;
				is_BJ_type_update <= 1'b0;
			end
			else if(func_code == 6'd26) begin //JRL
				halt <= 1'b0;
				wwd <= 1'b0;
				reg_write <= 1'b1;
				mem_to_reg <= 2'b10;
				if_id_mux_con <= 2'b10;
		
				pc_src <= 1'b1;
				pc_to_reg <= 1'b1;
				jalr <= 1'b1;
				is_BJ_type_update <= 1'b0;
			end
			else if(func_code == 6'd28) begin //WWD
				halt <= 1'b0;
				wwd <= 1'b1;
				mem_to_reg <= 2'b00;
				reg_write <= 1'b0;
				if_id_mux_con <= 2'b11;

				pc_src <= 1'b0;
				pc_to_reg <= 1'b0;
				jalr <= 1'b0;
				is_BJ_type_update <= 1'b0;
			end
			else if(func_code == 6'd29) begin //HLT
				halt <= 1'b1;
				wwd <= 1'b0;
				mem_to_reg <= 2'b00;
				reg_write <= 1'b0;
				if_id_mux_con <= 2'b11;

				pc_src <= 1'b0;
				pc_to_reg <= 1'b0;
				jalr <= 1'b0;
				is_BJ_type_update <= 1'b0;
			end
			else begin
				halt <= 1'b0;
				wwd <= 1'b0;
				mem_to_reg <= 2'b00;
				reg_write <= 1'b0;
				if_id_mux_con <= 2'b11;

				reg_write <= 1'b1;

				pc_src <= 1'b0;
				jalr <= 1'b0;
				is_BJ_type_update <= 1'b0;
			end
		end
		else if (opcode ==`ADI_OP || opcode ==`ORI_OP|| opcode ==`LHI_OP) begin //4, 5, 6
			read_m1 <= 1'b1;
			read_m2 <= 1'b0;
			write_m2 <= 1'b0;
			pc_write_cond <= 1'b0; //branch then 1
			pc_write<= 1'b1; //if pc_wirte == 1 then pc update, fetch and jump then 1
			mem_to_reg <= 2'b00;

			pc_src <= 1'b0; //if jump|branch then 1 
			alu_src <= 1'b1;
			if_id_mux_con <= 2'b11;

			pc_to_reg <= 1'b0;
			halt <= 1'b0;
			wwd <= 1'b0;
			jalr <= 1'b0;
			is_BJ_type_update <= 1'b0;

			reg_write <= 1'b1; 
		end
		else if (opcode == `LWD_OP) begin //7
			read_m1 <= 1'b1;
			read_m2 <= 1'b1;
			write_m2 <= 1'b0;
			pc_write_cond <= 1'b0; //branch then 1
			pc_write<= 1'b1; //if pc_wirte == 1 then pc update, fetch and jump then 1
			mem_to_reg <= 2'b01;
			reg_write <= 1'b1; 
			alu_src <= 1'b1;
			if_id_mux_con <= 2'b11;
			is_BJ_type_update <= 1'b0;
			pc_src <= 1'b0; //if jump|branch then 1 
			jalr <= 1'b0;

			pc_to_reg <= 1'b0;
			halt <= 1'b0;
			wwd <= 1'b0;
		end
		else if (opcode == `SWD_OP) begin
			read_m1 <= 1'b1;
			read_m2 <= 1'b0;
			write_m2 <= 1'b1;
			pc_write_cond <= 1'b0; //branch then 1
			pc_write<= 1'b1; //if pc_wirte == 1 then pc update, fetch and jump then 1
			mem_to_reg <= 2'b00;
			reg_write <= 1'b0; 
			alu_src <=1'b1;
			if_id_mux_con <= 2'b11;
			is_BJ_type_update <= 1'b0;
			pc_src <= 1'b0; //if jump|branch then 1 
			jalr <= 1'b0;

			pc_to_reg <= 1'b0;
			halt <= 1'b0;
			wwd <= 1'b0;
		end
		else if (opcode < 4) begin //bne, beq, bgz, blz
			read_m1 <= 1'b1;
			read_m2 <= 1'b0;
			write_m2 <= 1'b0;
			pc_write_cond <= 1'b1; //branch then 1
			pc_write<= 1'b0; //if pc_wirte == 1 then pc update, fetch and jump then 1
			mem_to_reg <= 2'b00;
			reg_write <= 1'b0; 
			is_BJ_type_update <= 1'b1;
			pc_src <= 1'b0; //if jump|branch then 1 
			if_id_mux_con <= 2'b01;
			jalr <= 1'b0;

			pc_to_reg <= 1'b0;
			halt <= 1'b0;
			wwd <= 1'b0;
			
		end
		else if(opcode == `JMP_OP || opcode == `JAL_OP) begin //9, 10
			if (opcode == `JAL_OP) begin
				reg_write <= 1'b1;
				mem_to_reg <= 2'b10;
				pc_to_reg <= 1'b1;
			end
			else begin
				reg_write <= 1'b0;
				mem_to_reg <= 2'b00;
				pc_to_reg <= 1'b0; 
			end
			jalr <= 1'b0;
			read_m1 <= 1'b1;
			read_m2 <= 1'b0;
			write_m2 <= 1'b0;
			pc_write_cond <= 1'b0; //branch then 1
			pc_write<= 1'b1; //if pc_wirte == 1 then pc update, fetch and jump then 1
			if_id_mux_con <= 2'b00;
			is_BJ_type_update <= 1'b1;
			pc_src <= 1'b1; //if jump|branch then 1 

			halt <= 1'b0;
			wwd <= 1'b0;
		end
		else if (opcode === 4'bz) begin
			read_m1 <= 1'b1;
			read_m2 <= 1'b0;
			write_m2 <= 1'b0;
			pc_write_cond <= 1'b0; //branch then 1
			pc_write<= 1'b0; //if pc_wirte == 1 then pc update, fetch and jump then 1
			i_or_d <= 1'b0; //decide memory address 
			mem_to_reg <= 2'b00;

			ir_write <= 1'b0;
			pc_src <= 1'b0; //if jump|branch then 1 
			alu_src <= 1'b0;
			is_BJ_type_update <= 1'b0;
			pc_to_reg <= 1'b0;
			halt <= 1'b0;
			wwd <= 1'b0;
			jalr <= 1'b0;

			reg_write <= 1'b0; 
			if_id_mux_con <= 2'b00;
		end
		else begin
			read_m1 <= read_m1;
			read_m2 <= read_m2;
			write_m2 <= write_m2;
			pc_write_cond <= pc_write_cond; //branch then 1
			pc_write<= pc_write; //if pc_wirte == 1 then pc update, fetch and jump then 1
			i_or_d <= i_or_d; //decide memory address 
			mem_to_reg <= mem_to_reg;
			is_BJ_type_update <= is_BJ_type_update;
			ir_write <= ir_write;
			pc_src <= pc_src; //if jump|branch then 1 
			alu_src <= alu_src;

			pc_to_reg <= pc_to_reg;
			halt <= halt;
			wwd <= wwd;
			jalr <= jalr;

			reg_write <= reg_write; 
			if_id_mux_con <= if_id_mux_con;
		end
   	end


endmodule
