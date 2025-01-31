module CPU
(
    clk_i, 
    rst_i,
    start_i,
    mem_data_i, 
    mem_ack_i, 
    mem_data_o, 
    mem_addr_o,     
    mem_enable_o, 
    mem_write_o
);

// Ports
input               clk_i;
input               rst_i;
input               start_i;
input  wire[255:0]  mem_data_i;
input               mem_ack_i;
output wire[255:0]  mem_data_o;
output wire[31:0]   mem_addr_o;
output wire         mem_enable_o;
output wire         mem_write_o;        


MUX32 Mux_Branch(
    .data1_i    (Add_PC.data_o),
    .data2_i    (Adder_Branch.data_o),
    .select_i   (And_Branch.Result_o),
    .data_o     ()
);

// modules
Adder Add_PC(
    .data1_i   (PC.pc_o),
    .data2_i   (4),
    .data_o     ()
);

PC PC(
    .clk_i      (clk_i),
    .rst_i      (rst_i),
    .start_i    (start_i),
    .PCWrite_i  (Hazard_Detection_Unit.PCWrite_o),  // not determined
    .pc_i       (Mux_Branch.data_o),
    .stall_i (dcache.cpu_stall_o),
    .pc_o       ()
);

Instruction_Memory Instruction_Memory(
    .addr_i     (PC.pc_o), 
    .instr_o    ()
);


IF_ID IF_ID_Register(
    .clk_i      (clk_i),
    .instr_i    (Instruction_Memory.instr_o),
    .stall_i    (Hazard_Detection_Unit.Stall_o),
    .flush_i    (And_Branch.Result_o),
    .PC_i       (PC.pc_o),
    .MemStall_i (dcache.cpu_stall_o),
    .IF_ID_o    (),
    .PC_o       ()
);

Control Control(
    .Op_i       (IF_ID_Register.IF_ID_o[6:0]),
    .NoOp_i     (Hazard_Detection_Unit.NoOp_o),
    .ALUOp_o    (),
    .ALUSrc_o   (),
    .RegWrite_o (),
    .MemWrite_o (),
    .MemRead_o  (),
    .MemtoReg_o (),
    .Branch_o   ()
);

Hazard_Detection_Unit Hazard_Detection_Unit(
    .RS1addr_i   (IF_ID_Register.IF_ID_o[19:15]),
    .RS2addr_i   (IF_ID_Register.IF_ID_o[24:20]),
    .ID_EX_MemRead_i(ID_EX_Register.MemRead_o),
    .ID_EX_RDaddr_i (ID_EX_Register.RDaddr_o),
    .NoOp_o      (),
    .Stall_o     (),
    .PCWrite_o   ()   
);

Shifter Shifter_Branch(
    .Src_i       (Sign_Extend.data_o),
    .ShiftNum_i  (5'b00001),
    .Result_o    ()
);

Adder Adder_Branch(
    .data1_i    (Shifter_Branch.Result_o),
    .data2_i    (IF_ID_Register.PC_o),
    .data_o    ()
);

AND And_Branch(
    .Src1_i      (Control.Branch_o),
    .Src2_i      (EQ_Branch.Result_o),
    .Result_o    ()
);

Registers Registers(
    .clk_i      (clk_i),
    .RS1addr_i  (IF_ID_Register.IF_ID_o[19:15]),
    .RS2addr_i  (IF_ID_Register.IF_ID_o[24:20]),
    .RDaddr_i   (MEM_WB_Register.RDaddr_o), 
    .RDdata_i   (MUX_RegSrc.data_o),
    .RegWrite_i (MEM_WB_Register.RegWrite_o), 
    .RS1data_o  (), 
    .RS2data_o  () 
);

EQ EQ_Branch(
    .Src1_i      (Registers.RS1data_o),
    .Src2_i      (Registers.RS2data_o),
    .Result_o    ()
);

Sign_Extend Sign_Extend(
    .data_i     (IF_ID_Register.IF_ID_o[31:0]),
    .data_o     ()
);

ID_EX ID_EX_Register(
    .clk_i      (clk_i),
    .RegWrite_i (Control.RegWrite_o),
    .MemtoReg_i (Control.MemtoReg_o),
    .MemRead_i  (Control.MemRead_o),
    .MemWrite_i (Control.MemWrite_o),
    .ALUOp_i    (Control.ALUOp_o),
    .ALUSrc_i   (Control.ALUSrc_o),
    .RS1data_i  (Registers.RS1data_o),
    .RS2data_i  (Registers.RS2data_o),
    .Imm_i      (Sign_Extend.data_o),
    .Func10_i   ({IF_ID_Register.IF_ID_o[31:25], IF_ID_Register.IF_ID_o[14:12]}),
    .RS1addr_i  (IF_ID_Register.IF_ID_o[19:15]),
    .RS2addr_i  (IF_ID_Register.IF_ID_o[24:20]),
    .RDaddr_i   (IF_ID_Register.IF_ID_o[11:7]),
    .MemStall_i (dcache.cpu_stall_o),
    .RegWrite_o (),
    .MemtoReg_o (),
    .MemRead_o  (),
    .MemWrite_o (),
    .ALUOp_o    (),
    .ALUSrc_o   (),
    .RS1data_o  (),
    .RS2data_o  (),
    .Imm_o      (),
    .Func10_o   (),
    .RS1addr_o  (),
    .RS2addr_o  (),
    .RDaddr_o   ()
);

MUX64 MUX_Forward_RS1(
    .data1_i    (ID_EX_Register.RS1data_o), 
    .data2_i    (MUX_RegSrc.data_o),
    .data3_i    (EX_MEM_Register.ALUResult_o),
    .data4_i    (),
    .select_i   (Forwarding_Unit.ForwardA_o),
    .data_o     ()
);

MUX64 MUX_Forward_RS2(
    .data1_i    (ID_EX_Register.RS2data_o), 
    .data2_i    (MUX_RegSrc.data_o),
    .data3_i    (EX_MEM_Register.ALUResult_o),
    .data4_i    (),
    .select_i   (Forwarding_Unit.ForwardB_o),
    .data_o     ()
);

MUX32 MUX_ALUSrc2(
    .data1_i    (MUX_Forward_RS2.data_o),
    .data2_i    (ID_EX_Register.Imm_o),
    .select_i   (ID_EX_Register.ALUSrc_o),
    .data_o     ()
);

ALU ALU(
    .data1_i    (MUX_Forward_RS1.data_o),
    .data2_i    (MUX_ALUSrc2.data_o),
    .ALUCtrl_i  (ALU_Control.ALUCtrl_o),
    .data_o     (),
    .Zero_o     ()
);

ALU_Control ALU_Control(
    .funct_i    (ID_EX_Register.Func10_o),
    .ALUOp_i    (ID_EX_Register.ALUOp_o),
    .ALUCtrl_o  ()
);

Forwarding_Unit Forwarding_Unit(
    .clk_i               (clk_i),
    .ID_EX_Rs1_i         (ID_EX_Register.RS1addr_o),
    .ID_EX_Rs2_i         (ID_EX_Register.RS2addr_o), 
    .EX_MEM_RegWrite_i   (EX_MEM_Register.RegWrite_o),
    .EX_MEM_Rd_i         (EX_MEM_Register.RDaddr_o), 
    .MEM_WB_Rd_i         (MEM_WB_Register.RDaddr_o),
    .MEM_WB_RegWrite_i   (MEM_WB_Register.RegWrite_o),
    .ForwardA_o          (),
    .ForwardB_o          ()
);

EX_MEM EX_MEM_Register(
    .clk_i       (clk_i),
    .RegWrite_i  (ID_EX_Register.RegWrite_o),
    .MemtoReg_i  (ID_EX_Register.MemtoReg_o),
    .MemRead_i   (ID_EX_Register.MemRead_o),
    .MemWrite_i  (ID_EX_Register.MemWrite_o),
    .ALUResult_i (ALU.data_o),
    .RS2data_i   (MUX_Forward_RS2.data_o),
    .RDaddr_i    (ID_EX_Register.RDaddr_o),
    .MemStall_i  (dcache.cpu_stall_o),
    .RegWrite_o  (),
    .MemtoReg_o  (),
    .MemRead_o   (),
    .MemWrite_o  (),
    .ALUResult_o (),
    .RS2data_o   (),
    .RDaddr_o    ()
);

// Change this into dcache_sram and connect enable_i
dcache_controller dcache(
    // System clock, reset and stall
    .clk_i           (clk_i), 
    .rst_i           (rst_i),
    // to Data Memory interface        
    .mem_data_i      (mem_data_i), 
    .mem_ack_i       (mem_ack_i),     
    .mem_data_o      (mem_data_o), 
    .mem_addr_o      (mem_addr_o),     
    .mem_enable_o    (mem_enable_o), 
    .mem_write_o     (mem_write_o), 
    // to CPU interface    
    .cpu_data_i      (EX_MEM_Register.RS2data_o),
    .cpu_addr_i      (EX_MEM_Register.ALUResult_o),
    .cpu_MemRead_i   (EX_MEM_Register.MemRead_o),
    .cpu_MemWrite_i  (EX_MEM_Register.MemWrite_o),
    .cpu_data_o      (), 
    .cpu_stall_o     ()
);

MEM_WB MEM_WB_Register(
    .clk_i       (clk_i),
    .RegWrite_i  (EX_MEM_Register.RegWrite_o),
    .MemtoReg_i  (EX_MEM_Register.MemtoReg_o),
    .ALUResult_i (EX_MEM_Register.ALUResult_o),
    .ReadData_i  (dcache.cpu_data_o),
    .RDaddr_i    (EX_MEM_Register.RDaddr_o),
    .MemStall_i  (dcache.cpu_stall_o),
    .RegWrite_o  (),
    .MemtoReg_o  (),
    .ALUResult_o (),
    .ReadData_o  (),
    .RDaddr_o    ()
);

MUX32 MUX_RegSrc(
    .data1_i    (MEM_WB_Register.ALUResult_o),
    .data2_i    (MEM_WB_Register.ReadData_o),
    .select_i   (MEM_WB_Register.MemtoReg_o),
    .data_o     ()
);


endmodule

