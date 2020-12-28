module ID_EX(
    input clk_i,
    input RegWrite_i,
    input MemtoReg_i,
    input MemRead_i,
    input MemWrite_i,
    input [1:0] ALUOp_i,
    input ALUSrc_i,
    input [31:0] RS1data_i,
    input [31:0] RS2data_i,
    input [31:0] Imm_i,
    input [9:0] Func10_i,
    input [4:0] RS1addr_i,
    input [4:0] RS2addr_i,
    input [4:0] RDaddr_i,
    output RegWrite_o,
    output MemtoReg_o,
    output MemRead_o,
    output MemWrite_o,
    output [1:0] ALUOp_o,
    output ALUSrc_o,
    output [31:0] RS1data_o,
    output [31:0] RS2data_o,
    output [31:0] Imm_o,
    output [9:0] Func10_o,
    output [4:0] RS1addr_o,    
    output [4:0] RS2addr_o,
    output [4:0] RDaddr_o
);

reg RegWrite_o, MemtoReg_o, MemRead_o, MemWrite_o, ALUOp_o, ALUSrc_o;
reg [31:0] RS1data_o, RS2data_o, Imm_o;
reg [9:0] Func10_o;
reg [4:0] RS1addr_o, RS2addr_o, RDaddr_o;

initial begin
    RDaddr_o = 5'b00001;
end

always @(posedge clk_i) begin
    RegWrite_o <= RegWrite_i;
    MemtoReg_o <= MemtoReg_i;
    MemRead_o <= MemRead_i;
    MemWrite_o <= MemWrite_i;
    ALUOp_o <= ALUOp_i;
    ALUSrc_o <= ALUSrc_i;
    Func10_o <= Func10_i;
    RS1data_o <= RS1data_i;
    RS2data_o <= RS2data_i;
    Imm_o <= Imm_i;
    RS1addr_o <= RS1addr_i;
    RS2addr_o <= RS2addr_i;
    RDaddr_o <= RDaddr_i;
end

endmodule
