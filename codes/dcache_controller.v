module dcache_controller
(
    // System clock, reset and stall
    clk_i, 
    rst_i,
    
    // to Data Memory interface        
    mem_data_i, 
    mem_ack_i,     
    mem_data_o, 
    mem_addr_o,     
    mem_enable_o, 
    mem_write_o, 
    
    // to CPU interface    
    cpu_data_i, 
    cpu_addr_i,
    cpu_MemRead_i, 
    cpu_MemWrite_i, 
    cpu_data_o, 
    cpu_stall_o
);
//
// System clock, start
//
input                 clk_i; 
input                 rst_i;

//
// to Data_Memory interface        
//
input    [255:0]      mem_data_i;   // data from memory
input                 mem_ack_i;    // acknowledge for stall
    
output   [255:0]      mem_data_o;   // data to be written to memory 
output   [31:0]       mem_addr_o;   // address of data
output                mem_enable_o; // if only mem_enable -> read
output                mem_write_o;  // if mem_enable && mem_write -> write
    
//    
// to CPU interface            
//    
input    [31:0]       cpu_data_i;      // data to be written to cache
input    [31:0]       cpu_addr_i;      // address of data
input                 cpu_MemRead_i; 
input                 cpu_MemWrite_i; 

output   [31:0]       cpu_data_o;      // data to be transferred to CPU
output                cpu_stall_o;     // if cache miss, stall pipeline

//
// to SRAM interface
//
wire    [3:0]         cache_sram_index;     // block index, derived from address from CPU
wire                  cache_sram_enable;    // if only cache_sram_enable -> read
wire    [24:0]        cache_sram_tag;       // cache tags, {valid, dirty, tags}
wire    [255:0]       cache_sram_data;      // data to be written to sram
wire                  cache_sram_write;     // if cache_sram_enable && cache_sram_write -> write
wire    [24:0]        sram_cache_tag;       // cache tag returns from sram
wire    [255:0]       sram_cache_data;      // data returns from sram
wire                  sram_cache_hit;


// cache
wire                  sram_valid;
wire                  sram_dirty;

// controller
parameter             STATE_IDLE         = 3'h0,
                      STATE_READMISS     = 3'h1,
                      STATE_READMISSOK   = 3'h2,
                      STATE_WRITEBACK    = 3'h3,
                      STATE_MISS         = 3'h4;
reg     [2:0]         state;
reg                   mem_enable;
reg                   mem_write;
reg                   cache_write;
wire                  cache_dirty;
reg                   write_back;

// regs & wires
wire    [4:0]         cpu_offset;
wire    [3:0]         cpu_index;
wire    [22:0]        cpu_tag;
wire    [255:0]       r_hit_data;
wire    [21:0]        sram_tag;
wire                  hit;
reg     [255:0]       w_hit_data;
wire                  write_hit;
wire                  cpu_req;
reg     [31:0]        cpu_data;
reg                   cache_enable;

// to CPU interface
assign    cpu_req     = cpu_MemRead_i | cpu_MemWrite_i;  // whether CPU need to access cache or not
assign    cpu_tag     = cpu_addr_i[31:9];                // tags from CPU
assign    cpu_index   = cpu_addr_i[8:5];                 // block index from CPU
assign    cpu_offset  = cpu_addr_i[4:0];                 // byte offset from CPU
assign    cpu_stall_o = ~hit & cpu_req;                  // if CPU access cache but cache miss, stall
assign    cpu_data_o  = cpu_data;                        // assign data to be transferred to CPU to a reg

// to SRAM interface
assign    sram_valid = sram_cache_tag[24];
assign    sram_dirty = sram_cache_tag[23];      
assign    sram_tag   = sram_cache_tag[22:0];
assign    cache_sram_index  = cpu_index;
assign    cache_sram_enable = cache_enable;                     // cache is needed only if CPU issue a request
assign    cache_sram_write  = cache_write | write_hit;          // cache_write: replace a block, write_hit: write data from CPU to cache
assign    cache_sram_tag    = {1'b1, cache_dirty, cpu_tag};     // set valid bit to 1,
assign    cache_sram_data   = (hit) ? w_hit_data : mem_data_i;  // data to be written to cache
                                                                // miss -> replace a block from memory
                                                                // hit -> write a block with data from CPU
// to Data_Memory interface
assign    mem_enable_o = mem_enable;        // memory is needed only if cache miss
assign    mem_addr_o   = (write_back) ? {sram_tag, cpu_index, 5'b0} : {cpu_tag, cpu_index, 5'b0}; // write_back: address from cache
assign    mem_data_o   = sram_cache_data;   // block to be written to memory
assign    mem_write_o  = mem_write;         // if only memory_enable -> read, if memory_enable && memory_write -> write

assign    write_hit    = hit & cpu_MemWrite_i;
assign    cache_dirty  = write_hit;         // if write hits -> data is only written to cache -> set dirty bit to 1

// TODO: add your code here!  (r_hit_data=...?)
assign    r_hit_data   = (hit) ? sram_cache_data : mem_data_i;  // if not hit, data is from memory, if hits, data is from cache

// read data :  256-bit to 32-bit
always@(cpu_offset or r_hit_data) begin
    // TODO: add your code here! (cpu_data=...?)
    cpu_data = r_hit_data[cpu_offset * 8 +: 32]; 
end


// write data :  32-bit to 256-bit
always@(cpu_offset or r_hit_data or cpu_data_i) begin
    // TODO: add your code here! (w_hit_data=...?)
    w_hit_data = r_hit_data;
    w_hit_data[cpu_offset * 8 +: 32] = cpu_data_i;
end


// controller 
always@(posedge clk_i or posedge rst_i) begin
    if(rst_i) begin
        state       = STATE_IDLE;
        mem_enable  = 1'b0;
        mem_write   = 1'b0;
        cache_write = 1'b0; 
        write_back  = 1'b0;
        cache_enable = 1'b0;
    end
    else begin
        case(state)        
            STATE_IDLE: begin
                if(cpu_req && !hit) begin      // wait for request
                    cache_enable = 1;
                    state = STATE_MISS;
                end
                else begin
                    state = STATE_IDLE;
                end
            end
            STATE_MISS: begin
                if(sram_dirty) begin       
                    // gotta replace a block  
                    // write back if dirty
                    // TODO: add your code here! 
                    write_back  = 1;
                    mem_enable  = 1;
                    mem_write   = 1; 
                    cache_write = 0;
                    cache_enable = 0;
                    state = STATE_WRITEBACK;
                end
                else begin
                    // write allocate: write miss = read miss + write hit; read miss = read miss + read hit
                    // TODO: add your code here! 
                    write_back  = 0;
                    mem_enable  = 1;
                    mem_write   = 0;
                    cache_write = 0;
                    cache_enable = 0;
                    state = STATE_READMISS;
                end
            end
            STATE_READMISS: begin
                if(mem_ack_i) begin
                    // wait for data memory acknowledge
                    // TODO: add your code here! 
                    write_back  = 0;
                    mem_enable  = 0;
                    mem_write   = 0;
                    cache_write = 1;
                    cache_enable = 1;
                    state = STATE_READMISSOK;
                end
                else begin
                    state = STATE_READMISS;
                end
            end
            STATE_READMISSOK: begin
                // wait for data memory acknowledge
                // TODO: add your code here! 
                cache_write = 0;
                cache_enable = 1;
                state       = STATE_IDLE;
            end
            STATE_WRITEBACK: begin
                if(mem_ack_i) begin
                    // wait for data memory acknowledge
                    // TODO: add your code here! 
                    write_back  = 0;
                    mem_enable  = 1;
                    mem_write   = 0;
                    cache_write = 0;
                    cache_enable = 0;
                    state = STATE_READMISS;
                end
                else begin
                    state = STATE_WRITEBACK;
                end
            end
        endcase
    end
end

//
// SRAM (cache memory part)
//
dcache_sram dcache_sram
(
    .clk_i      (clk_i),
    .rst_i      (rst_i),
    .addr_i     (cache_sram_index),
    .tag_i      (cache_sram_tag),
    .data_i     (cache_sram_data),
    .enable_i   (cache_sram_enable),
    .write_i    (cache_sram_write),
    .tag_o      (sram_cache_tag),
    .data_o     (sram_cache_data),
    .hit_o      (hit)
);

endmodule
