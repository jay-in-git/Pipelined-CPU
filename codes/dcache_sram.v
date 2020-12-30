module dcache_sram
(
    clk_i,
    rst_i,
    addr_i,
    tag_i,
    data_i,
    enable_i,
    write_i,
    tag_o,
    data_o,
    hit_o
);

// I/O Interface from/to controller
input              clk_i;
input              rst_i;
input    [3:0]     addr_i;
input    [24:0]    tag_i;
input    [255:0]   data_i;
input              enable_i;
input              write_i;

output   [24:0]    tag_o;
output   [255:0]   data_o;
output             hit_o;


// Memory
reg      [24:0]    tag [0:15][0:1];    
reg      [255:0]   data[0:15][0:1];
integer            i, j;
reg      [1:0]     cache_index; // 00: first cache 01: second cache 10: none
reg                is_hit;
reg                LRU_cache_index[0:15];
reg      [255:0]   data_o_reg;
reg      [24:0]    tag_o_reg;

// Write Data      
// 1. Write hit
// 2. Read miss: Read from memory
always@(posedge clk_i or posedge rst_i) begin
    if (rst_i) begin
        for (i=0;i<16;i=i+1) begin
            for (j=0;j<2;j=j+1) begin
                tag[i][j] <= 25'b0;
                data[i][j] <= 256'b0;
            end
        end
    end
    //cache_index <= 2'b10;
    is_hit <= 1'b0;
    $display("0 %b\n", is_hit);
    //data_o_reg <= 25'b0;
    // if (enable_i) begin
    //     $display("fuckfuck\n");
    // end
    // if (write_i) begin
    //     $display("inin\n");
    // end
    if(enable_i && write_i) begin
        // Write hit
        if(tag[addr_i][0][24] == 1'b1 && (tag_i[22:0] == tag[addr_i][0][22:0])) begin // if is valid && tag are the same
            cache_index = 2'b0;
            is_hit = 1'b1;
            $display("1 %b\n", is_hit);
            LRU_cache_index[addr_i] = 1'b1;
        end 
        else if(tag[addr_i][1][24] == 1'b1 && (tag_i[22:0] == tag[addr_i][1][22:0])) begin
            cache_index = 2'b01;
            is_hit = 1'b1;
            $display("2 %b\n", is_hit);
            LRU_cache_index[addr_i] = 1'b0;
        end
        if(is_hit) begin
            tag[addr_i][cache_index][24:23] = 2'b11;
            data[addr_i][cache_index] = data_i;

            tag_o_reg = tag[addr_i][cache_index][24:0];
            data_o_reg = data[addr_i][cache_index];
            
        end
        // Write miss
        else begin
            is_hit = 1'b0;
            $display("3 %b\n", is_hit);
            tag[addr_i][LRU_cache_index[addr_i]][24:0] = {1'b1, 1'b1, tag_i[22:0]};
            data[addr_i][LRU_cache_index[addr_i]] = data_i;
            tag_o_reg = tag[addr_i][LRU_cache_index[addr_i]][24:0];
            data_o_reg = data[addr_i][LRU_cache_index[addr_i]];
            LRU_cache_index[addr_i] ^= 1'b1; // Change LRU index with xor operation.
        end 

        // TODO: Handle your write of 2-way associative cache + LRU here
    end
    else if(enable_i) begin
        if(tag[addr_i][0][24] == 1'b1 && (tag_i[22:0] == tag[addr_i][0][22:0])) begin
            is_hit <= 1'b1;
            $display("4 %b\n", is_hit);
            LRU_cache_index[addr_i] = 1'b1;
            cache_index = 1'b0;

        end
        else if(tag[addr_i][0][24] == 1'b1 && (tag_i[22:0] == tag[addr_i][1][22:0])) begin
            is_hit <= 1'b1;
            $display("5 %b\n", is_hit);
            LRU_cache_index[addr_i] = 1'b0;
            cache_index = 1'b1;
        end 
        if(!is_hit) begin
            tag[addr_i][LRU_cache_index[addr_i]] = tag_i;
            tag_o_reg = tag[addr_i][LRU_cache_index[addr_i]];
            LRU_cache_index[addr_i] ^= 1'b1;
        end 
        else begin
            tag_o_reg = tag[addr_i][cache_index];
            data_o_reg = data[addr_i][cache_index];
        end
    end 
end

// Read Data      
// TODO: tag_o=? data_o=? hit_o=?
assign hit_o = is_hit;
assign tag_o = tag_o_reg;
assign data_o = data_o_reg;

endmodule
