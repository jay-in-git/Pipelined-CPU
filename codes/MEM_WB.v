module MEM_WB(
    input clk_i,
    input RegWrite_i,
    input MemtoReg_i,
    input [31:0] ALUResult_i,
    input [31:0] ReadData_i,
    input [4:0] RDaddr_i,
    input MemStall_i,
    output RegWrite_o,
    output MemtoReg_o,
    output [31:0] ALUResult_o,
    output [31:0] ReadData_o,
    output [4:0] RDaddr_o
);

reg [31:0] ALUResult_o, ReadData_o;
reg [4:0] RDaddr_o;
reg RegWrite_o, MemtoReg_o;

always @(posedge clk_i) begin
    if (~MemStall_i) begin
        ALUResult_o <= ALUResult_i;
        ReadData_o <= ReadData_i;
        RDaddr_o <= RDaddr_i;
        RegWrite_o <= RegWrite_i;
        MemtoReg_o <= MemtoReg_i;
    end
end

endmodule