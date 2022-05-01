`timescale 1ns/1ns
`define WORD_SIZE 16 

// TODO: implement your external_device module
module external_device (clk, reset_n, offset_counter, output_data, interrupt, counter, write_m2);

input clk;
input reset_n;
input [2:0] offset_counter;

output reg [63:0] output_data; // data to transfer
output reg interrupt;
output reg [2:0] counter;
output reg write_m2;

reg [`WORD_SIZE-1:0] data [0:`WORD_SIZE-1];
reg [`WORD_SIZE-1:0] wait_count;// num_clk to count cycles and trigger interrupt at appropriate cycle

initial begin
		data[16'd0] <= 16'h0001;
		data[16'd1] <= 16'h0002;
		data[16'd2] <= 16'h0003;
		data[16'd3] <= 16'h0004;
		data[16'd4] <= 16'h0005;
		data[16'd5] <= 16'h0006;
		data[16'd6] <= 16'h0007;
		data[16'd7] <= 16'h0008;
		data[16'd8] <= 16'h0009;
		data[16'd9] <= 16'h000a;
		data[16'd10] <= 16'h000b;
		data[16'd11] <= 16'h000c;
		wait_count <= 0;
		counter <=0 ;
		interrupt <= 0;
		output_data <= 64'bz;
		write_m2 <= 0;
end

always @(posedge clk) begin
	if(!reset_n) begin
		data[16'd0] <= 16'h0001;
		data[16'd1] <= 16'h0002;
		data[16'd2] <= 16'h0003;
		data[16'd3] <= 16'h0004;
		data[16'd4] <= 16'h0005;
		data[16'd5] <= 16'h0006;
		data[16'd6] <= 16'h0007;
		data[16'd7] <= 16'h0008;
		data[16'd8] <= 16'h0009;
		data[16'd9] <= 16'h000a;
		data[16'd10] <= 16'h000b;
		data[16'd11] <= 16'h000c;
		wait_count <= 0;
		interrupt <= 0;
	end
	else begin
		wait_count <= wait_count + 1;
		if(wait_count  == 2044) begin
			interrupt <= 1;
		end
		else begin 
			interrupt <= 0;
		end
	end
end

wire [3:0] offset;
assign offset = offset_counter * 4;

always @(posedge clk) begin
	if(!reset_n) begin
		counter <= 0;
	end
	else begin
		if(offset_counter == 4) begin
			output_data <= 64'bz;
			counter <= 0;
		end
		else if(counter == 0) begin
			counter <= 1;
		end
		else if(counter == 1) begin
			counter <= 2;
		end
		else if(counter == 2) begin
			counter <= 3;
		end
		else if(counter == 3) begin
			counter <= 4;
		end
		else if(counter == 4) begin
			counter <= 5;
			write_m2 <= 1;
			output_data [15:0]<= data[offset]; 
			output_data [31:16]<= data[offset + 1];
			output_data [47:32]<= data[offset + 2]; 
			output_data [63:48]<= data[offset + 3]; 
		end
		else if(counter == 5) begin
			write_m2 <= 0;
			counter <= 0;
		end
	end
end

endmodule


