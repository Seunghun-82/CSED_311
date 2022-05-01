`include "vending_machine_def.v"
	

module calculate_current_state(i_trigger_return, clk, i_input_coin,i_select_item,item_price, coin_value, reset_n
,wait_time, o_return_coin ,o_available_item ,o_output_item, out_total);
	
	input clk;
	input i_trigger_return;
	input reset_n;
	input [`kNumCoins-1:0] i_input_coin;
	input [`kNumItems-1:0]	i_select_item;			
	input [31:0] item_price [`kNumItems-1:0];
	input [31:0] coin_value [`kNumCoins-1:0];	
	input [31:0] wait_time;
	output reg [`kNumItems-1:0] o_available_item,o_output_item, o_return_coin;
	output reg [31:0] out_total;
	wire signed [31:0] wait_time_sign;
	assign wait_time_sign = wait_time;
	
	initial begin
		out_total = 0;
		o_available_item = 4'b0000;
		o_output_item = 4'b0000;
		o_return_coin = 3'b000;
	end
	
	
	always @(i_input_coin, i_select_item) begin
		if(i_input_coin) begin
			out_total = out_total + i_input_coin[0] * coin_value[0] + i_input_coin[1] * coin_value[1] + i_input_coin[2] * coin_value[2];
		end
		else begin

		end
		if(i_select_item) begin
			if(i_select_item[3] && (out_total >= i_select_item[3] * item_price[3])) begin
				out_total = out_total - i_select_item[3] * item_price[3];
				o_output_item = 4'b1000;
			end	
			if(i_select_item[2] && (out_total >= i_select_item[2] * item_price[2])) begin
				out_total = out_total - i_select_item[2] * item_price[2];
				o_output_item = 4'b0100;
			end
			if(i_select_item[1] && (out_total >= i_select_item[1] * item_price[1])) begin
				out_total = out_total - i_select_item[1] * item_price[1];
				o_output_item = 4'b0010;
			end
			if(i_select_item[0] && (out_total >= i_select_item[0] * item_price[0])) begin
				out_total = out_total - i_select_item[0] * item_price[0];
				o_output_item = 4'b0001;
			end
			else begin
				
			end
		end
		else begin

		end
	end
	
	
	always @(*) begin
		if(out_total >= 2000) begin
			o_available_item = 4'b1111;
		end
		else if(out_total >= 1000) begin
			o_available_item = 4'b0111;
		end
		else if(out_total >= 500) begin
			o_available_item = 4'b0011;
		end
		else if(out_total >= 400) begin
			o_available_item = 4'b0001;
		end
		else begin
			o_available_item = 4'b0000;
		end

	end
	
	always @(*) begin
		if(wait_time_sign <= 0) begin
			//o_return_coin = 3'b000;
			if(out_total >= 1600) begin
				o_return_coin = 3'b111;
				out_total = out_total - 1600;
			end
			else if(out_total >= 1500) begin
				o_return_coin = 3'b110;
				out_total = out_total - 1500;
			end
			else if(out_total >= 1100) begin
				o_return_coin = 3'b101;
				out_total = out_total - 1100;
			end
			else if(out_total >= 1000) begin
				o_return_coin = 3'b100;
				out_total = out_total - 1000;
			end
			else if(out_total >= 600) begin
				o_return_coin = 3'b011;
				out_total = out_total - 600;
			end
			else if(out_total >= 500) begin
				o_return_coin = 3'b010;
				out_total = out_total - 500;
			end
			else if(out_total >= 100) begin
				o_return_coin = 3'b001;
				out_total = out_total - 100;
			end
			else begin
				o_return_coin = 3'b000;
			end
		end
		else begin

		end
	end


	always @(posedge clk ) begin
		if (!reset_n) begin
			o_available_item <= 4'b0000;
			o_output_item <= 4'b0000;
			out_total <= 0;
		end
		else if(i_trigger_return) begin
			if(out_total >= 1600) begin
				o_return_coin <= 3'b111;
				out_total <= out_total - 1600;
			end
			else if(out_total >= 1500) begin
				o_return_coin <= 3'b110;
				out_total <= out_total - 1500;
			end
			else if(out_total >= 1100) begin
				o_return_coin <= 3'b101;
				out_total <= out_total - 1100;
			end
			else if(out_total >= 1000) begin
				o_return_coin <= 3'b100;
				out_total <= out_total - 1000;
			end
			else if(out_total >= 600) begin
				o_return_coin <= 3'b011;
				out_total <= out_total - 600;
			end
			else if(out_total >= 500) begin
				o_return_coin <= 3'b010;
				out_total <= out_total - 500;
			end
			else if(out_total >= 100) begin
				o_return_coin <= 3'b001;
				out_total <= out_total - 100;
			end
			else begin
				o_return_coin <= 3'b000;
			end
		end	
		else begin
			o_output_item <= 4'b0000;
			
		end
	end
 
	


endmodule 