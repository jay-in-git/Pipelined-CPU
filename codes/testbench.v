`define CYCLE_TIME 50

module testbench;

reg                Clk;
reg                Start;
reg                Reset;
integer            i, j, outfile, outfile2, counter;
reg                flag;
reg        [26:0]  address;
reg        [24:0]  tag;
reg        [3:0]   index;

wire    [255:0]    mem_cpu_data; 
wire               mem_cpu_ack;     
wire    [255:0]    cpu_mem_data; 
wire    [31:0]     cpu_mem_addr;     
wire               cpu_mem_enable; 
wire               cpu_mem_write; 
parameter          num_cycles = 200;

always #(`CYCLE_TIME/2) Clk = ~Clk;    

CPU CPU(
    .clk_i  (Clk),
    .rst_i  (Reset),
    .start_i(Start),
    
    .mem_data_i(mem_cpu_data), 
    .mem_ack_i(mem_cpu_ack),     
    .mem_data_o(cpu_mem_data), 
    .mem_addr_o(cpu_mem_addr),     
    .mem_enable_o(cpu_mem_enable), 
    .mem_write_o(cpu_mem_write)
);

Data_Memory Data_Memory
(
    .clk_i    (Clk),
    .rst_i    (Reset),
    .addr_i   (cpu_mem_addr),
    .data_i   (cpu_mem_data),
    .enable_i (cpu_mem_enable),
    .write_i  (cpu_mem_write),
    .ack_o    (mem_cpu_ack),
    .data_o   (mem_cpu_data)
);
  
initial begin
    $dumpfile("CPU.vcd");
    $dumpvars;
    counter = 0;

    Clk = 0;
    Reset = 1;
    Start = 0;
    
    #(`CYCLE_TIME/4) 
    Reset = 0;
    Start = 1;
    
    // initialize instruction memory (1KB)
    for (i=0; i<255; i=i+1) begin
        CPU.Instruction_Memory.memory[i] = 32'b0;
    end
    
        
    // initialize cache memory    (1KB)
    for (j=0; j<2; j=j+1) begin
        for(i=0; i<16; i=i+1) begin
            CPU.dcache.dcache_sram.tag[i][j] = 25'b0;
            CPU.dcache.dcache_sram.data[i][j] = 256'b0;
        end
    end
    // [D-CacheInitialization] DO NOT REMOVE THIS FLAG !!!
    CPU.dcache.state = 3'h0;
    CPU.dcache.mem_enable = 1'b0;
    CPU.dcache.mem_write = 1'b0;
    CPU.dcache.cache_write = 1'b0;
    CPU.dcache.write_back = 1'b0;
    CPU.dcache.w_hit_data = 256'b0;
    CPU.dcache.cpu_data = 32'b0;

    for (i = 0; i < 16; i = i + 1) begin
        CPU.dcache.dcache_sram.tag[i][0] = 25'b0;
        CPU.dcache.dcache_sram.tag[i][1] = 25'b0;
        CPU.dcache.dcache_sram.data[i][0] = 256'b0;
        CPU.dcache.dcache_sram.data[i][1] = 256'b0;
        CPU.dcache.dcache_sram.LRU_cache_index[i] = 1'b0;
    end
    //CPU.dcache.dcache_sram.cache_index = 2'b10; // 00: first cache 01: second cache 10: none


    // initialize Register File
    for (i=0; i<32; i=i+1) begin
        CPU.Registers.register[i] = 32'b0;
    end
    // [RegisterInitialization] DO NOT REMOVE THIS FLAG !!!
    CPU.IF_ID_Register.IF_ID_o = 32'b0;
    CPU.IF_ID_Register.PC_o = 32'b0;

    CPU.ID_EX_Register.RegWrite_o = 1'b0;
    CPU.ID_EX_Register.MemtoReg_o = 1'b0;
    CPU.ID_EX_Register.MemRead_o = 1'b0;
    CPU.ID_EX_Register.MemWrite_o = 1'b0;
    CPU.ID_EX_Register.ALUOp_o = 1'b0;
    CPU.ID_EX_Register.ALUSrc_o = 1'b0;
    CPU.ID_EX_Register.RS1data_o = 32'b0;
    CPU.ID_EX_Register.RS2data_o = 32'b0;
    CPU.ID_EX_Register.Imm_o = 32'b0;
    CPU.ID_EX_Register.Func10_o = 10'b0;
    CPU.ID_EX_Register.RS1addr_o = 5'b0;
    CPU.ID_EX_Register.RS2addr_o = 5'b0;
    CPU.ID_EX_Register.RDaddr_o = 5'b0;

    CPU.EX_MEM_Register.RegWrite_o = 1'b0;
    CPU.EX_MEM_Register.MemtoReg_o = 1'b0;
    CPU.EX_MEM_Register.MemRead_o = 1'b0;
    CPU.EX_MEM_Register.MemWrite_o = 1'b0;
    CPU.EX_MEM_Register.ALUResult_o = 32'b0;
    CPU.EX_MEM_Register.RS2data_o = 32'b0;
    CPU.EX_MEM_Register.RDaddr_o = 5'b0;

    CPU.MEM_WB_Register.ALUResult_o = 32'b0;
    CPU.MEM_WB_Register.ReadData_o = 32'b0;
    CPU.MEM_WB_Register.RDaddr_o = 5'b0;
    CPU.MEM_WB_Register.RegWrite_o = 1'b0;
    CPU.MEM_WB_Register.MemtoReg_o = 1'b0;

    CPU.Hazard_Detection_Unit.NoOp_o = 1'b0;
    CPU.Hazard_Detection_Unit.Stall_o = 1'b0;
    CPU.Hazard_Detection_Unit.PCWrite_o = 1'b1;

    CPU.Control.ALUOp_o = 2'b0;
    CPU.Control.ALUSrc_o = 1'b0;
    CPU.Control.RegWrite_o = 1'b0;
    CPU.Control.MemWrite_o = 1'b0;
    CPU.Control.MemRead_o = 1'b0;
    CPU.Control.MemtoReg_o = 1'b0;
    CPU.Control.Branch_o = 1'b0;

    CPU.ALU_Control.ALUCtrl = 4'b1011;

    CPU.Forwarding_Unit.ForwardA_o = 2'b00;
    CPU.Forwarding_Unit.ForwardB_o = 2'b00;

    CPU.Sign_Extend.extension = 32'b0;
    CPU.Sign_Extend.tmp_extension = 12'b0;

    CPU.ALU.data_reg = 32'b0;
    CPU.ALU.IsZero = 1'b0;
    
    // Load instructions into instruction memory
    // Make sure you change back to "instruction.txt" before submission
    $readmemb("../testdata_public/instruction_3.txt", CPU.Instruction_Memory.memory);
    
    // Open output file
    // Make sure you change back to "output.txt" before submission
    outfile = $fopen("output.txt") | 1;
    // Make sure you change back to "cache.txt" before submission
    outfile2 = $fopen("cache.txt") | 1;
    
    
    // initialize data memory    (16KB)
    for (i=0; i<512; i=i+1) begin
        Data_Memory.memory[i] = 256'b0;
    end
    Data_Memory.memory[0] = 256'h0000_1111_2222_3333_4444_5555_6666_7777_8888_9999_AAAA_BBBB_CCCC_DDDD_EEEE_FFFF;
    Data_Memory.memory[1] = 256'h8888_9999_AAAA_BBBB_CCCC_DDDD_EEEE_FFFF_7777_6666_5555_4444_3333_2222_1111_0000;
    Data_Memory.memory[2] = 256'hECFA_ECFA_ECFA_ECFA_ECFA_ECFA_ECFA_ECFA_ECFA_ECFA_ECFA_ECFA_ECFA_ECFA_ECFA_ECFA;
    Data_Memory.memory[16] = 256'h0123_4567_89AB_CDEF_FEDC_BA98_7654_3210_0123_4567_89AB_CDEF_FEDC_BA98_7654_3210;
    Data_Memory.memory[17] = 256'h0000_0110_0220_0330_0440_0550_0660_0770_0880_0990_0AA0_0BB0_0CC0_0DD0_0EE0_0FF0;
    Data_Memory.memory[32] = 256'h0000_1001_2002_3003_4004_5005_6006_7007_8008_9009_A00A_B00B_C00C_D00D_E00E_F00F;
    // [D-MemoryInitialization] DO NOT REMOVE THIS FLAG !!!
    Data_Memory.data = 256'b0;
    Data_Memory.count = 4'b0;
    Data_Memory.state = 1'h0;

end
  
always@(posedge Clk) begin
    if(counter == num_cycles) begin    // store cache to memory
        $fdisplay(outfile, "Flush Cache! \n");
        for (j=0; j<2; j=j+1) begin
            for (i=0; i<16; i=i+1) begin
                tag = CPU.dcache.dcache_sram.tag[i][j];
                index = i;
                address = {tag[22:0], index};
                if (tag[24])
                    Data_Memory.memory[address] = CPU.dcache.dcache_sram.data[i][j];
            end 
        end
    end
    if(counter > num_cycles) begin    // stop after num_cycles cycles
        $finish;
    end
        
    // print PC
    // delete state
    $fdisplay(outfile, "controller: state = %b, index = %b, tag out = %b, hit = %b\ndcache: tag00 = %b, tag01 = %b, is_hit = %b\n", CPU.dcache.state, CPU.dcache.cache_sram_index, CPU.dcache.cache_sram_tag, CPU.dcache.hit, CPU.dcache.dcache_sram.tag[0][0], CPU.dcache.dcache_sram.tag[0][1], CPU.dcache.dcache_sram.is_hit);
    $fdisplay(outfile, "dcache: tag10 = %b, tag11 = %b\n", CPU.dcache.dcache_sram.tag[1][0], CPU.dcache.dcache_sram.tag[1][1]);
    // for (i = 0; i < 16; i = i + 1) begin
    //     $fdisplay(outfile, "set %0d, tag = %b\n    data = %h\n", i, CPU.dcache.dcache_sram.tag[i][0], CPU.dcache.dcache_sram.data[i][0]);
    //     $fdisplay(outfile, "set %0d, tag = %b\n    data = %h\n", i, CPU.dcache.dcache_sram.tag[i][1], CPU.dcache.dcache_sram.data[i][1]);
    // end

    $fdisplay(outfile, "cycle = %0d, Start = %b\nPC = %d", counter, Start, CPU.PC.pc_o);
    
    // print Registers
    // DO NOT CHANGE THE OUTPUT FORMAT
    $fdisplay(outfile, "Registers");
    $fdisplay(outfile, "x0 = %h, x8  = %h, x16 = %h, x24 = %h", CPU.Registers.register[0], CPU.Registers.register[8] , CPU.Registers.register[16], CPU.Registers.register[24]);
    $fdisplay(outfile, "x1 = %h, x9  = %h, x17 = %h, x25 = %h", CPU.Registers.register[1], CPU.Registers.register[9] , CPU.Registers.register[17], CPU.Registers.register[25]);
    $fdisplay(outfile, "x2 = %h, x10 = %h, x18 = %h, x26 = %h", CPU.Registers.register[2], CPU.Registers.register[10], CPU.Registers.register[18], CPU.Registers.register[26]);
    $fdisplay(outfile, "x3 = %h, x11 = %h, x19 = %h, x27 = %h", CPU.Registers.register[3], CPU.Registers.register[11], CPU.Registers.register[19], CPU.Registers.register[27]);
    $fdisplay(outfile, "x4 = %h, x12 = %h, x20 = %h, x28 = %h", CPU.Registers.register[4], CPU.Registers.register[12], CPU.Registers.register[20], CPU.Registers.register[28]);
    $fdisplay(outfile, "x5 = %h, x13 = %h, x21 = %h, x29 = %h", CPU.Registers.register[5], CPU.Registers.register[13], CPU.Registers.register[21], CPU.Registers.register[29]);
    $fdisplay(outfile, "x6 = %h, x14 = %h, x22 = %h, x30 = %h", CPU.Registers.register[6], CPU.Registers.register[14], CPU.Registers.register[22], CPU.Registers.register[30]);
    $fdisplay(outfile, "x7 = %h, x15 = %h, x23 = %h, x31 = %h", CPU.Registers.register[7], CPU.Registers.register[15], CPU.Registers.register[23], CPU.Registers.register[31]);

    // print Data Memory
    // DO NOT CHANGE THE OUTPUT FORMAT
    $fdisplay(outfile, "Data Memory: 0x0000 = %h", Data_Memory.memory[0]);
    $fdisplay(outfile, "Data Memory: 0x0020 = %h", Data_Memory.memory[1]);
    $fdisplay(outfile, "Data Memory: 0x0040 = %h", Data_Memory.memory[2]);
    $fdisplay(outfile, "Data Memory: 0x0200 = %h", Data_Memory.memory[16]);
    $fdisplay(outfile, "Data Memory: 0x0220 = %h", Data_Memory.memory[17]);
    $fdisplay(outfile, "Data Memory: 0x0240 = %h", Data_Memory.memory[18]);
    $fdisplay(outfile, "Data Memory: 0x0400 = %h", Data_Memory.memory[32]);
    $fdisplay(outfile, "Data Memory: 0x0420 = %h", Data_Memory.memory[33]);
    $fdisplay(outfile, "Data Memory: 0x0440 = %h", Data_Memory.memory[34]);
    
    $fdisplay(outfile, "\n");
    
    // print Data Cache Status
    // DO NOT CHANGE THE OUTPUT FORMAT
    if(CPU.dcache.cpu_stall_o && CPU.dcache.state==0) begin
        if(CPU.dcache.sram_dirty) begin
            if(CPU.dcache.cpu_MemWrite_i) 
                $fdisplay(outfile2, "Cycle: %d, Write Miss, Address: %h, Write Data: %h (Write Back!)", counter, CPU.dcache.cpu_addr_i, CPU.dcache.cpu_data_i);
            else if(CPU.dcache.cpu_MemRead_i) 
                $fdisplay(outfile2, "Cycle: %d, Read Miss , Address: %h, Read Data : %h (Write Back!)", counter, CPU.dcache.cpu_addr_i, CPU.dcache.cpu_data_o);
        end
        else begin
            if(CPU.dcache.cpu_MemWrite_i) 
                $fdisplay(outfile2, "Cycle: %d, Write Miss, Address: %h, Write Data: %h", counter, CPU.dcache.cpu_addr_i, CPU.dcache.cpu_data_i);
            else if(CPU.dcache.cpu_MemRead_i) 
                $fdisplay(outfile2, "Cycle: %d, Read Miss , Address: %h, Read Data : %h", counter, CPU.dcache.cpu_addr_i, CPU.dcache.cpu_data_o);
        end
        flag = 1'b1;
    end
    else if(!CPU.dcache.cpu_stall_o) begin
        if(!flag) begin
            if(CPU.dcache.cpu_MemWrite_i) 
                $fdisplay(outfile2, "Cycle: %d, Write Hit , Address: %h, Write Data: %h", counter, CPU.dcache.cpu_addr_i, CPU.dcache.cpu_data_i);
            else if(CPU.dcache.cpu_MemRead_i) 
                $fdisplay(outfile2, "Cycle: %d, Read Hit  , Address: %h, Read Data : %h", counter, CPU.dcache.cpu_addr_i, CPU.dcache.cpu_data_o);
        end
        flag = 1'b0;
    end
        
    
    counter = counter + 1;
end

  
endmodule
