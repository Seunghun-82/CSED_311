`include "opcodes.v"       

module control_unit (instr, alu_src, reg_write, mem_read, mem_to_reg, mem_write, jalr, jal , branch, PctoReg, PCsrc1, PCsrc2,
pc_value_output, clk, immediate, alu_output, b_cond, reset_n, ackOutput, inputReady, ReadM, WriteM);
input [`WORD_SIZE-1:0] instr;
input clk;
input [15:0] immediate;
input [15:0] alu_output;
input b_cond;
input reset_n;
input ackOutput;
input inputReady;

output reg alu_src;
output reg reg_write;
output reg mem_read;
output reg mem_to_reg;
output reg mem_write;
output reg branch;
output reg jalr;
output reg jal;
output reg PctoReg;
output reg PCsrc1;
output reg PCsrc2;
output [15:0] pc_value_output;
output reg ReadM;
output reg WriteM;

reg [15:0]pc_value;
reg [3:0] opcode;
   // initiate values
   initial begin
      reg_write <= 1'b0;
      alu_src <= 1'b0;   
      mem_read <= 1'b0;
      mem_write <= 1'b0;
      mem_to_reg <= 1'b0;
      jalr <= 1'b0;
      jal <= 1'b0;
      branch <= 1'b0;
      PctoReg <= 1'b0;
      PCsrc1 <= 1'b0;
      PCsrc2 <= 1'b0;
      pc_value <= 1'b0;
      ReadM <= 1'b0;
      WriteM <= 1'b0;
   end
   always @(posedge inputReady) begin
      ReadM <= 0;
   end
   always @(posedge ackOutput) begin
      WriteM <= 0;
   end
   always @(negedge clk) begin
      ReadM <= 1;
   end
   always @(posedge clk) begin
      if(mem_read) begin
	ReadM <= 1;
      end
      else if(mem_write) begin
	WriteM <= 1;      end
   end

   //first out wire
   wire [15:0] first_out;
   adder pc_first(pc_value, 16'd1, first_out);
   //src2_out wire 
   wire [15:0] src2_out, pc_value_out;
   //immdiate wire
   wire [15:0] immediate_out;
   adder immdiate(first_out, immediate, immediate_out);

   always @(negedge clk) begin
      if(reset_n) begin
	pc_value <= pc_value_out;
      end
      else begin
	pc_value <= pc_value;
      end
   end
   
   //src1_out wire
   wire bcond_and_branch;
   wire is_it_jal;
   wire [15:0] src1_out;
   assign bcond_and_branch = b_cond & branch;
   assign is_it_jal = jal | bcond_and_branch;
   mux_2to_1_anytime src1(ReadM, is_it_jal, first_out, immediate_out, src1_out);

  
   mux_2to_1_anytime src2(ReadM, PCsrc2, src1_out, alu_output, pc_value_out);

   assign pc_value_output = pc_value;

   always @(instr) begin
     if(!clk) begin
      reg_write = 1'b0; //RegWrite
      alu_src = 1'b0;   //ALUsrc
      mem_read = 1'b0;  //MemRead
      mem_write = 1'b0; //MemWrite
      mem_to_reg = 1'b0;//MemtoReg
      jalr = 1'b0;
      jal = 1'b0;
      branch = 1'b0;
      PctoReg = 1'b0;
      PCsrc1 = 1'b0;
      PCsrc2 = 1'b0;
      opcode = instr[15:12];

      case(opcode)
      `ALU_OP:begin
         reg_write = 1'b1;
      end
      `ADI_OP:begin
         reg_write = 1'b1;
         alu_src = 1'b1;
      end
      `ORI_OP:begin
         reg_write = 1'b1;
         alu_src = 1'b1;
      end
      `LHI_OP:begin
         reg_write = 1'b1;
         alu_src = 1'b1;
         mem_read = 1'b1;
         mem_to_reg = 1'b0;
      end
      `LWD_OP:begin
         reg_write = 1'b1;
         alu_src = 1'b1;
         mem_read = 1'b1;
         mem_to_reg = 1'b1;
      end
      `SWD_OP:begin
         alu_src = 1'b1;
         mem_write = 1'b1;
      end
      `BNE_OP:begin
         alu_src = 1'b0;
         branch = 1'b1;
      end
      `BEQ_OP:begin
         alu_src = 1'b0;
         branch = 1'b1;
      end
      `BGZ_OP:begin
         alu_src = 1'b0;
         branch = 1'b1;
      end
      `BLZ_OP:begin
         alu_src = 1'b0;
         branch = 1'b1;
      end
      `JMP_OP:begin
         alu_src = 1'b1;
         jal = 1'b1;
         PCsrc1 = 1'b1;
	 PCsrc2 = 1'b1;
      end
      `JAL_OP:begin
         reg_write = 1'b1;
         alu_src = 1'b1;
         jal = 1'b1;
	 PctoReg = 1'b1;
	 PCsrc1 = 1'b1;
	 PCsrc2 = 1'b1;
      end
      `JPR_OP:begin
         jalr = 1'b1;
	 PCsrc2 = 1'b1;
      end
      `JRL_OP:begin
         reg_write = 1'b1;
         jalr = 1'b1;
	 PctoReg = 1'b1;
	 PCsrc1 = 1'b1;
	 PCsrc2 = 1'b1;
      end
      
      endcase
     end // if? end
   end


endmodule