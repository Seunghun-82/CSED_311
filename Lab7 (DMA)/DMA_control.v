module DMA_control (clk, address, data_length, clk_counter, BG, BR, interrupt, counter);
	
	input clk;
	input [15:0] address;
	input [3:0] data_length;
	input [2:0] clk_counter;
	input BG;
	output reg BR;
	output reg interrupt;
	output reg [2:0]counter; 
	reg interrupt_control;

	initial begin
		counter <= 4;
		BR <= 0;
		interrupt <= 0;
		interrupt_control <= 0;
	end

	always @ (posedge clk) begin
		if(BG) begin
			if(clk_counter === 5) begin
				counter <= counter + 1;
			end		
		end

		if(counter == 3) begin
			counter <= 5;
		end

	end 

	always @(*) begin
		if(address === 16'bz) begin
			BR = 0;
		end
		else if(counter == 3) begin
			BR = 0;
			interrupt = 1;
		end
		else if(counter == 5) begin
			interrupt = 0;
		end
		else begin
			BR = 1;
		end
		if(BG) begin
			if(counter == 4) begin
				counter = 0;
			end
		end
	end

endmodule