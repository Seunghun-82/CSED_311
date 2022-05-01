module D_cache(clk, reset_n, read_m, write_m, memory_address, inout_data, memory_store_data, hit, miss,
mem_read_m, mem_write_m, out_address, caching_data);

	input clk, reset_n, read_m, write_m;
	input [15:0] memory_address;		//alu_output to use memory address
	inout [63:0] inout_data;		//miss? ?? data ? ?? load ??? ? //???? ?? data evict? ??(dirty bit? 1? ?)
	input [15:0] memory_store_data;		//cache? memory? store? data
		
	output reg hit, miss;			
	output reg mem_read_m, mem_write_m;
	output reg [15:0] out_address;		//miss? ?? ???, ??? memory ???
	output reg [15:0] caching_data;		//load? ?? cache?? ?? ?

	reg [16:0]miss_count;
	reg [16:0]evict_count;
	reg [16:0]hit_count;
	reg [63:0]cache_line[1:0][1:0];
	reg [12:0]cache_tag[1:0][1:0];
	reg [15:0]evict_pc[1:0][1:0];
	reg cache_LRU[1:0][1:0];
	reg cache_valid[1:0][1:0];
	reg dirty_bit[1:0][1:0];
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
		cache_tag[0][0] <= 13'h1fff;
		cache_tag[0][1] <= 13'h1fff;
		cache_tag[1][0] <= 13'h1fff;
		cache_tag[1][1] <= 13'h1fff;
		cache_LRU[0][0] = 0;
		cache_LRU[0][1] = 0;
		cache_LRU[1][0] = 0;
		cache_LRU[1][1] = 0;
		cache_valid[0][0] = 0;
		cache_valid[0][1] = 0;
		cache_valid[1][0] = 0;
		cache_valid[1][1] = 0;
		dirty_bit[0][0] = 0;
		dirty_bit[0][1] = 0;
		dirty_bit[1][0] = 0;
		dirty_bit[1][1] = 0;
		evict_pc[0][0] = 0;
		evict_pc[0][1] = 0;
		evict_pc[1][0] = 0;
		evict_pc[1][1] = 0;
		counter = 0;
		hit = 0;
		miss = 0;
		way = 0;
		mem_read_m = 0;
		counter_signal = 0;
		mem_write_m = 0;
		out_address = 0;
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
			cache_tag[0][0] <= 13'h1fff;
			cache_tag[0][1] <= 13'h1fff;
			cache_tag[1][0] <= 13'h1fff;
			cache_tag[1][1] <= 13'h1fff;
			cache_LRU[0][0] <= 1;
			cache_LRU[0][1] <= 1;
			cache_LRU[1][0] <= 1;
			cache_LRU[1][1] <= 1;
			cache_valid[0][0] <= 0;
			cache_valid[0][1] <= 0;
			cache_valid[1][0] <= 0;
			cache_valid[1][1] <= 0;
			dirty_bit[0][0] <= 0;
			dirty_bit[0][1] <= 0;
			dirty_bit[1][0] <= 0;
			dirty_bit[1][1] <= 0;
			evict_pc[0][0] = 0;
			evict_pc[0][1] = 0;
			evict_pc[1][0] = 0;
			evict_pc[1][1] = 0;
			counter <= 0;
			hit <= 0;
			miss <= 0;
			way <= 0;
			mem_read_m <= 0;
			mem_write_m <= 0;
			counter_signal <= 0;
			out_address <= 0; 
		end
		else begin
			if(counter_signal && (dirty_bit[memory_address[2]][way] == 0)) begin
				if(counter == 0) begin
					cache_line[memory_address[2]][way] <= inout_data;
					evict_pc[memory_address[2]][way] <= {memory_address[15:2], 2'b00};
					counter <= 1;
					mem_read_m <= 0;
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
					if(read_m == 1) begin
						hit <= 1;
					end
					miss <= 0;
				end
				else if(counter == 5) begin
					if(write_m == 1) begin
						if(memory_address[1:0] == 0) begin
							cache_line[memory_address[2]][way][15 : 0] <= memory_store_data;
						end
						else if(memory_address[1:0] == 1) begin
							cache_line[memory_address[2]][way][31 : 16] <= memory_store_data;						end
						else if(memory_address[1:0] == 2) begin
							cache_line[memory_address[2]][way][47 : 32] <= memory_store_data;						end
						else if(memory_address[1:0] == 3) begin
							cache_line[memory_address[2]][way][63 : 48] <= memory_store_data;						end
						dirty_bit[memory_address[2]][way] <= 1;
					end
					else if (read_m == 1) begin
						dirty_bit[memory_address[2]][way] <= 0;
					end
					counter <= 0;
					counter_signal <= 0;
				end
			end
			else if(counter_signal && (dirty_bit[memory_address[2]][way] == 1)) begin
				if(counter == 0) begin
					counter <= 1;
					mem_write_m <= 0;
					mem_read_m <= 1;
				end
				else if(counter == 1) begin
					cache_line[memory_address[2]][way] <= inout_data;
					evict_pc[memory_address[2]][way] <= {memory_address[15:2], 2'b00};
					mem_read_m <= 0;
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
					if(read_m == 1) begin
						hit <= 1;
					end
					miss <= 0;
				end
				else if(counter == 5) begin
					if(write_m == 1) begin
						if(memory_address[1:0] == 0) begin
							cache_line[memory_address[2]][way][15 : 0] <= memory_store_data;
						end
						else if(memory_address[1:0] == 1) begin
							cache_line[memory_address[2]][way][31 : 16] <= memory_store_data;						end
						else if(memory_address[1:0] == 2) begin
							cache_line[memory_address[2]][way][47 : 32] <= memory_store_data;						end
						else if(memory_address[1:0] == 3) begin
							cache_line[memory_address[2]][way][63 : 48] <= memory_store_data;						end
						dirty_bit[memory_address[2]][way] <= 1;
					end
					else if (read_m == 1) begin
						dirty_bit[memory_address[2]][way] <= 0;
					end
					counter <= 0;
					counter_signal <= 0;
				end
			end
		end
	end

	always @(*) begin
		if(read_m && reset_n) begin		//read_m check
			if(cache_valid[memory_address[2]][0] || cache_valid[memory_address[2]][1]) begin	//memory_address[2] == set_index, value check
				//$display ("%d", memory_address);
				if(cache_tag[memory_address[2]][0] == memory_address[15:3]) begin		//Hit check and LRU update latest is 0 and oldest is 1
					hit = 1;
					miss = 0;
					way = 0;
					cache_LRU[memory_address[2]][0] = 0;
					cache_LRU[memory_address[2]][1] = 1;
					mem_read_m = 0;
					counter = 0;
					counter_signal = 0;
					hit_count = hit_count + 1;
				end
				else if (cache_tag[memory_address[2]][1] == memory_address[15:3] ) begin //memory_tag check and hit
					hit = 1;
					miss = 0;
					way = 1;
					cache_LRU[memory_address[2]][0] = 1;
					cache_LRU[memory_address[2]][1] = 0;
					mem_read_m = 0;
					counter = 0;
					counter_signal = 0;
					hit_count = hit_count + 1;
				end
				else begin						//cache miss
					hit = 0;
					miss = 1;
					mem_read_m = 1;
					miss_count = miss_count + 1;
					way = cache_LRU[memory_address[2]][0] ? 0 : 1;
					if(cache_valid[memory_address[2]][way] == 1) begin
						evict_count = evict_count + 1;
						if(dirty_bit[memory_address[2]][way] == 1) begin
							mem_write_m = 1;
						end
						else begin
							mem_write_m = 0;
						end
					end
					else begin
						if(dirty_bit[memory_address[2]][way] == 1) begin
							mem_write_m = 1;
						end
						else begin
							mem_write_m = 0;
						end
					end
					cache_valid[memory_address[2]][way] = 1;
					cache_tag[memory_address[2]][way] = memory_address[15:3];
					cache_LRU[memory_address[2]][way] = 0;
					cache_LRU[memory_address[2]][!way] = 1;
					counter_signal = 1;
				end
			
			end
			else begin	//cold miss
				miss_count = miss_count + 1;
				hit = 0;
				miss = 1;
				mem_read_m = 1;
				way = 0;
				cache_LRU[memory_address[2]][0] = 0;
				cache_valid[memory_address[2]][0] = 1;
				cache_tag[memory_address[2]][0] = memory_address[15:3];
				counter_signal = 1;
			end
		end
		else if(write_m && reset_n) begin		//read_m check
			if(cache_valid[memory_address[2]][0] || cache_valid[memory_address[2]][1]) begin	//memory_address[2] == set_index, value check
				//$display ("%d", memory_address);
				if(cache_tag[memory_address[2]][0] == memory_address[15:3]) begin		//Hit check and LRU update latest is 0 and oldest is 1
					hit = 1;
					miss = 0;
					way = 0;
					cache_LRU[memory_address[2]][0] = 0;
					cache_LRU[memory_address[2]][1] = 1;
					mem_read_m = 0;
					dirty_bit[memory_address[2]][way] = 1;
					hit_count = hit_count + 1;
					if(memory_address[1:0] == 0) begin
						cache_line[memory_address[2]][way][15 : 0] = memory_store_data;
					end
					else if(memory_address[1:0] == 1) begin
						cache_line[memory_address[2]][way][31 : 16] = memory_store_data;					end
					else if(memory_address[1:0] == 2) begin
						cache_line[memory_address[2]][way][47 : 32] = memory_store_data;					end
					else if(memory_address[1:0] == 3) begin
						cache_line[memory_address[2]][way][63 : 48] = memory_store_data;					end
				end
				else if (cache_tag[memory_address[2]][1] == memory_address[15:3] ) begin //memory_tag check and hit
					hit = 1;
					miss = 0;
					way = 1;
					cache_LRU[memory_address[2]][0] = 1;
					cache_LRU[memory_address[2]][1] = 0;
					mem_read_m = 0;
					dirty_bit[memory_address[2]][way] = 1;
					hit_count = hit_count + 1;
					if(memory_address[1:0] == 0) begin
						cache_line[memory_address[2]][way][15 : 0] = memory_store_data;
					end
					else if(memory_address[1:0] == 1) begin
						cache_line[memory_address[2]][way][31 : 16] = memory_store_data;					end
					else if(memory_address[1:0] == 2) begin
						cache_line[memory_address[2]][way][47 : 32] = memory_store_data;					end
					else if(memory_address[1:0] == 3) begin
						cache_line[memory_address[2]][way][63 : 48] = memory_store_data;					end

				end
				else begin						//cache miss
					hit = 0;
					miss = 1;
					way = cache_LRU[memory_address[2]][0] ? 0 : 1;
					if(cache_valid[memory_address[2]][way] == 0) begin
						mem_write_m = 0;
					end
					else begin
						if(dirty_bit[memory_address[2]][way] == 1) begin
							mem_write_m = 1;
						end
						else begin
							mem_write_m = 0;
						end
						evict_count = evict_count + 1;
					end
					miss_count = miss_count + 1;
					cache_valid[memory_address[2]][way] = 1;
					cache_tag[memory_address[2]][way] = memory_address[15:3];
					cache_LRU[memory_address[2]][way] = 0;
					cache_LRU[memory_address[2]][!way] = 1;
					counter_signal = 1;
				end
			
			end
			else begin	//cold miss
				miss_count = miss_count + 1;
				hit = 0;
				miss = 1;
				mem_write_m = 0;
				way = 0;
				cache_LRU[memory_address[2]][0] = 0;
				cache_valid[memory_address[2]][0] = 1;
				cache_tag[memory_address[2]][0] = memory_address[15:3];
				counter_signal = 1;
			end
		end
	end

	wire [15:0] cache_word_mux;

	mux4_1 cache_word (memory_address[1:0], cache_line[memory_address[2]][way][15 : 0], cache_line[memory_address[2]][way][31 : 16],
		cache_line[memory_address[2]][way][47 : 32], cache_line[memory_address[2]][way][63 : 48], cache_word_mux);

	assign out_address = (mem_read_m || mem_write_m) ? {memory_address[15:2], 2'b00} : evict_pc[memory_address[2]][way];
	assign inout_data = mem_write_m ? cache_line[memory_address[2]][way] : 64'bz;
	assign caching_data = (hit && read_m) ? cache_word_mux : 16'bz;

endmodule