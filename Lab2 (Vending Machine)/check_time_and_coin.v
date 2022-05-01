`include "vending_machine_def.v"

	

module check_time_and_coin( out_total, i_trigger_return ,i_input_coin,i_select_item,clk,reset_n,wait_time, item_price, coin_value);

	input [31:0]out_total;
	input [31:0] coin_value [`kNumCoins-1:0];
	input [31:0] item_price [`kNumItems-1:0];
	input i_trigger_return;
	input clk;
	input reset_n;
	input [`kNumCoins-1:0] i_input_coin;
	input [`kNumItems-1:0]	i_select_item;
	output reg [31:0] wait_time;
	// initiate values
	initial begin
		wait_time = 7'b1100100;
	end


	
	always @(i_input_coin, i_select_item) begin
		if(i_input_coin) begin
			wait_time = 7'b1100100;
		end
		else begin

		end
		if(i_select_item[3] && (out_total >= i_select_item[3] * item_price[3])) begin
			wait_time = 7'b1100100;
		end
		else begin

		end
		if(i_select_item[2] && (out_total >= i_select_item[2] * item_price[2])) begin
			wait_time = 7'b1100100;
		end
		else begin

		end
		if(i_select_item[1] && (out_total >= i_select_item[1] * item_price[1])) begin
			wait_time = 7'b1100100;
		end
		else begin

		end
		if(i_select_item[0] && (out_total >= i_select_item[0] * item_price[0])) begin
			wait_time = 7'b1100100;
		end
		else begin
			
		end
		
	end

	always @(posedge clk ) begin
		if (!reset_n) begin
			wait_time <= 7'b1100100;
		end
		else begin
			wait_time <= wait_time - 1'b1;
		end
	end
endmodule 