module EX_MEM(
    clk_i,
    RegWrite_i,
    MemtoReg_i,
    MemRead_i,
    MemWrite_i,
    ALUResult_i,
    RS2data_i,
    RDaddr_i,
    RegWrite_o,
    MemtoReg_o,
    MemRead_o,
    MemWrite_o,
    ALUResult_o,
    RS2data_o,
    RDaddr_o
);

// Ports
input         clk_i;
input         RegWrite_i, MemtoReg_i, MemRead_i, MemWrite_i;
input  [31:0] ALUResult_i, RS2data_i;
input  [4:0]  RDaddr_i;
output        RegWrite_o, MemtoReg_o, MemRead_o, MemWrite_o;
output [31:0] ALUResult_o, RS2data_o;
output [4:0]  RDaddr_o;

// Registers
reg        RegWrite_o, MemtoReg_o, MemRead_o, MemWrite_o;
reg [31:0] ALUResult_o, RS2data_o;
reg [4:0]  RDaddr_o;

always @ (posedge clk_i) begin
    RegWrite_o  <= RegWrite_i;
    MemtoReg_o  <= MemtoReg_i;
    MemRead_o   <= MemRead_i;
    MemWrite_o  <= MemWrite_i;
    ALUResult_o <= ALUResult_i;
    RS2data_o   <= RS2data_i;
    RDaddr_o    <= RDaddr_i;
end

endmodule
