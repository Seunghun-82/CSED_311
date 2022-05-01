`include "opcodes.v"

module control_unit(reset_n, pc_nxt, bcond, opcode, func_code, clk, pc_write_cond, pc_write, i_or_d, mem_read, mem_to_reg, mem_write, ir_write,
pc_to_reg, pc_src, halt, wwd, new_inst, reg_write, alu_src_A, alu_src_B, alu_op, pc, num_inst);
	input [3:0] opcode;
	input [5:0] func_code;
	input clk;
	input reset_n;
	input [`WORD_SIZE-1:0] pc_nxt;
	input bcond;

	output reg [`WORD_SIZE-1:0 ]num_inst;
	output reg pc_write_cond, pc_write, i_or_d, mem_read, mem_write, ir_write, pc_src;
  	//additional control signals. pc_to_reg: to support JAL, JRL. halt: to support HLT. wwd: to support WWD. new_inst: new instruction start
	output reg pc_to_reg, halt, wwd, new_inst, reg_write;
	output reg [1:0] alu_op, alu_src_A, alu_src_B, mem_to_reg;
	output reg [`WORD_SIZE-1:0] pc;

   	//TODO: implement control unit

	reg [4:0] state;
	initial begin
		state <= 4'b1010;
		pc <= 0;
		num_inst <= 16'h0000;

		pc_write_cond <= 1'b0; //branch then 1
		pc_write<= 1'b0; //if pc_wirte == 1 then pc update, fetch and jump then 1
		i_or_d <= 1'b0;
		mem_read <= 1'b0;
		mem_to_reg <= 2'b00;
		mem_write <= 1'b0;
		ir_write <= 1'b0;
		pc_src <= 1'b0; //if jump|branch then 1 

		pc_to_reg <= 1'b0;
		halt <= 1'b0;
		wwd <= 1'b0;
		new_inst <= 1'b0;

		reg_write <= 1'b0; 
		alu_src_A <= 2'b00;
		alu_src_B <= 2'b00;

		alu_op <= 2'b00; //if branch then 1
	end

	always @(posedge clk) begin
		if(state == 0) begin
			alu_src_A <= 2'b00;
			alu_src_B <= 2'b10;

			ir_write <= 1'b0;
			pc_write <= 1'b0;
			mem_read <= 1'b0;
			if(opcode == 10 || (opcode == 15 && func_code == 26)) begin			
				alu_op <= 2'b11;
			end
			else begin
				alu_op <= 2'b00;
			end

			state <= 4'b0001;
		end
		else if(state == 1) begin
			if(opcode == 15 && func_code != 25 && func_code != 26) begin //R-type
				alu_src_A <= 2'b01;
				alu_src_B <= 2'b00;
				alu_op <= 2'b00;
				state <= 4'b0110;
				if(func_code == 28) begin //WWD
					wwd <= 1'b1;
				end
				else if(func_code == 29) begin //HLT
					halt <= 1'b1;
				end
				else begin
					wwd <= 1'b0;
					halt <= 1'b0;
				end
			end
			else if(opcode == 4 || opcode == 5 ||opcode == 6) begin
				alu_src_A <= 2'b01;
				alu_src_B <= 2'b10;
				alu_op <= 2'b00;
				state <= 4'b0110;
			end
			else if(opcode < 4) begin //branch
				alu_src_A <= 2'b01;
				alu_src_B <= 2'b00;
				alu_op <= 2'b01;
				pc_write_cond <= 1'b1;
				pc_src <= 1'b1;
				state <= 4'b1000;
			end
			else if(opcode == 7 || opcode == 8) begin //load or store
				state <= 4'b0010;
				alu_src_A <= 2'b01;
				alu_src_B <= 2'b10;
				alu_op <= 2'b00;
			end
			else begin//jump
				if(opcode == 10 || opcode == 15 && func_code == 26) begin			
					reg_write <= 1'b1;
					mem_to_reg <= 2'b10;
				end
				alu_src_A <= 2'b01;
				alu_src_B <= 2'b10;
				alu_op <= 2'b00;
				state <= 4'b1001;
			end
		end
		else if(state == 2) begin //mem add computation
			if(opcode == 7) begin
				mem_read <= 1'b1;
				i_or_d <= 1'b1;
				
				state <= 4'b0011;
			end
			else begin
				mem_write <= 1'b1;
				i_or_d <= 1'b1;

				state <= 4'b0101;
			end
		end
		else if(state == 3) begin //mem acces
			mem_read <= 1'b1;
			reg_write <= 1'b1;
			mem_to_reg <= 2'b01;
			
			state <= 4'b0100;
		end
		else if(state == 4) begin
			wwd <= 1'b0;
			halt <= 1'b0;
			reg_write <= 1'b0; 
			pc_write_cond <= 1'b0;

			mem_read <= 1'b1;
			alu_src_A <= 2'b00;
			alu_src_B <= 2'b01;
			i_or_d <= 1'b0;
			alu_op <= 2'b10;
			i_or_d <= 1'b0;
			ir_write <= 1'b1; //store instruction
			pc_write<= 1'b1;
			pc_src <= 1'b0;
			
			num_inst <= num_inst + 1;
			state <= 4'b0000;
		end
		else if(state == 5) begin
			wwd <= 1'b0;
			halt <= 1'b0;
			reg_write <= 1'b0; 
			pc_write_cond <= 1'b0;
			mem_write <= 1'b0;

			mem_read <= 1'b1;
			alu_src_A <= 2'b00;
			alu_src_B <= 2'b01;
			i_or_d <= 1'b0;
			alu_op <= 2'b10;
			i_or_d <= 1'b0;
			ir_write <= 1'b1; //store instruction
			pc_write<= 1'b1;
			pc_src <= 1'b0;

			num_inst <= num_inst + 1;
			state <= 4'b0000;
		end
		else if(state == 6) begin //R-type exe
			if(func_code == 28 || func_code == 29) begin
				reg_write <= reg_write;
				mem_to_reg <= mem_to_reg;
			end
			else begin
				reg_write <= 1'b1;
				mem_to_reg <= 2'b00;
			end
			state <= 4'b0111;
		end
		else if(state == 7) begin //R-type comp
			wwd <= 1'b0;
			halt <= 1'b0;
			reg_write <= 1'b0; 
			pc_write_cond <= 1'b0;

			mem_read <= 1'b1;
			alu_src_A <= 2'b00;
			alu_src_B <= 2'b01;
			i_or_d <= 1'b0;
			alu_op <= 2'b10;
			i_or_d <= 1'b0;
			ir_write <= 1'b1; //store instruction
			pc_write<= 1'b1;
			pc_src <= 1'b0;

			num_inst <= num_inst + 1;
			state <= 4'b0000;
		end
		else if(state == 8) begin //branch comp
			wwd <= 1'b0;
			halt <= 1'b0;
			reg_write <= 1'b0; 
			pc_write_cond <= 1'b0;

			mem_read <= 1'b1;
			alu_src_A <= 2'b00;
			alu_src_B <= 2'b01;
			i_or_d <= 1'b0;
			alu_op <= 2'b10;
			i_or_d <= 1'b0;
			ir_write <= 1'b1; //store instruction
			pc_write<= 1'b1;
			pc_src <= 1'b0;

			num_inst <= num_inst + 1;
			state <= 4'b0000;
		end
		else if(state == 9) begin
			if(opcode == 10 || opcode == 15 && func_code == 26) begin			
				reg_write <= 1'b0;
				mem_to_reg <= 2'b00;
			end
			pc_write <= 1'b1;
          		pc_src <= 1'b1;

           		state <= 4'b1011;
		end
		else if(state == 11) begin  //jump conp
			wwd <= 1'b0;
			halt <= 1'b0;
			reg_write <= 1'b0; 
			pc_write_cond <= 1'b0;

			mem_read <= 1'b1;
			alu_src_A <= 2'b00;
			alu_src_B <= 2'b01;
			i_or_d <= 1'b0;
			alu_op <= 2'b10;
			i_or_d <= 1'b0;
			ir_write <= 1'b1; //store instruction
			pc_write<= 1'b1;
			pc_src <= 1'b0;

			num_inst <= num_inst + 1;
			state <= 4'b0000;
		end

		else if(state == 10) begin
			if(reset_n) begin
				state <= 4'b0000;
				pc <= 0;
				num_inst <= 16'h0000;

				wwd <= 1'b0;
				halt <= 1'b0;
				reg_write <= 1'b0; 
				pc_write_cond <= 1'b0;
	
				mem_read <= 1'b1;
				alu_src_A <= 2'b00;
				alu_src_B <= 2'b01;
				alu_op <= 2'b00;
				i_or_d <= 1'b0;
				ir_write <= 1'b1; //store instruction
				pc_write<= 1'b1;
				pc_src <= 1'b0;
			end
		end
		else begin
			state <= state;
		end
	end
	
	always @(posedge clk) begin
		if(pc_write || (pc_write_cond && bcond)) begin
			pc <= pc_nxt;
		end
		else begin
			pc <= pc;
		end
		if(!reset_n) begin
			state <= 4'b1010;
			pc <= 0;
			num_inst <= 16'h0000;

			wwd <= 1'b0;
			halt <= 1'b0;
			reg_write <= 1'b0; 
			pc_write_cond <= 1'b0;

			mem_read <= 1'b0;
			alu_src_A <= 2'b00;
			alu_src_B <= 2'b00;
			i_or_d <= 1'b0;
			alu_op <= 2'b00;

			ir_write <= 1'b0; //store instruction
			pc_write<= 1'b0;
			pc_src <= 1'b0;
		end
	end 
endmodule		
		
