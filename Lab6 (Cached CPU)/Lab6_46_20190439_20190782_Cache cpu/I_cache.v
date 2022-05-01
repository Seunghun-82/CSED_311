module I_cache(clk, reset_n, read_m, memory_address, instruction, data, hit, miss, mem_read_m, out_address, is_flush);

	input clk, reset_n, read_m;
	input [15:0] memory_address;
	input [63:0] instruction;
	output [15:0] data;
	output reg hit, miss;
	output reg mem_read_m;
	output reg [15:0] out_address;
	input is_flush;

	reg [16:0]miss_count;
	reg [16:0]evict_count;
	reg [16:0]hit_count;
	reg [63:0]cache_line[1:0][1:0];
	reg [12:0]cache_tag[1:0][1:0];
	reg cache_LRU[1:0][1:0];
	reg cache_valid[1:0][1:0];
	reg way;
	reg [2:0]counter;
	reg counter_signal;

	wire [15:0] index_start, index_end;

	initial begin
		miss_count = 0;
		evict_count = 0;
		hit_count = 0;

		cache_line[0][0] = 0;
		cache_line[0][1] = 0;
		cache_line[1][0] = 0;
		cache_line[1][1] = 0;
		cache_tag[0][0] = 0;
		cache_tag[0][1] = 0;
		cache_tag[1][0] = 0;
		cache_tag[1][1] = 0;
		cache_LRU[0][0] = 0;
		cache_LRU[0][1] = 0;
		cache_LRU[1][0] = 0;
		cache_LRU[1][1] = 0;
		cache_valid[0][0] = 0;
		cache_valid[0][1] = 0;
		cache_valid[1][0] = 0;
		cache_valid[1][1] = 0;
		counter = 0;
		hit = 0;
		miss = 0;
		way = 0;
		mem_read_m = 0;
		counter_signal = 0;
	end

	always @(posedge clk) begin
		if(hit) begin
			hit_count <= hit_count + 1;
		end
		else begin
			hit_count <= hit_count;
		end
	end

	always @(posedge clk) begin
		if(!reset_n) begin
			miss_count <= 0;
			evict_count <= 0;
			hit_count <= 0;

			cache_line[0][0] <= 0;
			cache_line[0][1] <= 0;
			cache_line[1][0] <= 0;
			cache_line[1][1] <= 0;
			cache_tag[0][0] <= 0;
			cache_tag[0][1] <= 0;
			cache_tag[1][0] <= 0;
			cache_tag[1][1] <= 0;
			cache_LRU[0][0] <= 1;
			cache_LRU[0][1] <= 1;
			cache_LRU[1][0] <= 1;
			cache_LRU[1][1] <= 1;
			cache_valid[0][0] <= 0;
			cache_valid[0][1] <= 0;
			cache_valid[1][0] <= 0;
			cache_valid[1][1] <= 0;
			counter <= 0;
			hit <= 0;
			miss <= 0;
			way <= 0;
			mem_read_m <= 0;
			counter_signal <= 0;
		end
		else begin
			if(counter_signal) begin
				if(counter == 0 || counter == 6) begin
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
					miss_count = miss_count + 1;
					if(cache_valid[memory_address[2]][way] == 1) begin
						evict_count <= evict_count + 1;
					end
					else begin
						evict_count <= evict_count;
					end
					cache_line[memory_address[2]][way]<= instruction;
					cache_valid[memory_address[2]][way] <= 1;
					cache_tag[memory_address[2]][way] <= memory_address[15:3];
					cache_LRU[memory_address[2]][way] <= 0;
					cache_LRU[memory_address[2]][!way] <= 1;
					counter <= 5;
					if(memory_address[15:2] === out_address[15:2]) begin
						hit <= 1;
						mem_read_m <= 0;
					end
					else begin
						hit <= 0;
						mem_read_m <= 1;
					end
				end
				else if(counter == 5) begin
					if(memory_address[15:2] === out_address[15:2]) begin
						counter <= 0;
						counter_signal <= 0;
					end
					else begin
						counter <= 6;
						counter_signal <= 1;
						out_address[15:2] <= memory_address[15:2];
						out_address[1:0] <= 2'b00;
					end
				end
			end
		end
	end

	always @(*) begin
		if(read_m && reset_n && (counter == 0)) begin		//read_m check
			if(cache_valid[memory_address[2]][0] || cache_valid[memory_address[2]][1]) begin	//memory_address[2] == set_index, value check
				//$display ("%d", memory_address);
				if(cache_tag[memory_address[2]][0] == memory_address[15:3]) begin		//Hit check and LRU update latest is 0 and oldest is 1
					hit = 1;
					miss = 0;
					way = 0;
					cache_LRU[memory_address[2]][0] = 0;
					cache_LRU[memory_address[2]][1] = 1;
					mem_read_m = 0;
				end
				else if (cache_tag[memory_address[2]][1] == memory_address[15:3] ) begin //memory_tag check and hit
					hit = 1;
					miss = 0;
					way = 1;
					cache_LRU[memory_address[2]][0] = 1;
					cache_LRU[memory_address[2]][1] = 0;
					mem_read_m = 0;
				end
				else begin						//cache miss
					hit = 0;
					miss = 1;
					mem_read_m = 1;
					way = cache_LRU[memory_address[2]][0] ? 0 : 1;
					out_address[15:2] = memory_address[15:2];
					out_address[1:0] = 2'b00;
					counter_signal = 1;
					counter = 0;
				end
			
			end
			else begin	//cold miss
				hit = 0;
				miss = 1;
				mem_read_m = 1;
				way = 0;
				cache_LRU[memory_address[2]][0] = 0;
				out_address[15:2] = memory_address[15:2];
				out_address[1:0] = 2'b00;
				cache_tag[memory_address[2]][0] = memory_address[15:3];
				counter_signal = 1;
				counter = 0;
			end
		end
	end

	wire [15:0] cache_word_mux;

	mux4_1 cache_word (memory_address[1:0], cache_line[memory_address[2]][way][15 : 0], cache_line[memory_address[2]][way][31 : 16],
		cache_line[memory_address[2]][way][47 : 32], cache_line[memory_address[2]][way][63 : 48], cache_word_mux);

	assign data = hit ? cache_word_mux : 16'bz;

endmodule