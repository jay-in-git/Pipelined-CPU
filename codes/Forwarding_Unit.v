module Forwarding_Unit(
   input clk_i,
   input [4:0] ID_EX_Rs1_i,
   input [4:0] ID_EX_Rs2_i, 
   input EX_MEM_RegWrite_i,
   input [4:0] EX_MEM_Rd_i, 
   input [4:0] MEM_WB_Rd_i,
   input MEM_WB_RegWrite_i,
   output [1:0] ForwardA_o,
   output [1:0] ForwardB_o
);
reg [1:0] ForwardA_o, ForwardB_o;

always @(MEM_WB_RegWrite_i or MEM_WB_Rd_i or ID_EX_Rs1_i or ID_EX_Rs2_i or EX_MEM_RegWrite_i or EX_MEM_Rd_i) begin
    ForwardA_o = 2'b00;
    ForwardB_o = 2'b00;
    if(MEM_WB_RegWrite_i == 1'b1 && (MEM_WB_Rd_i != 0) && (MEM_WB_Rd_i == ID_EX_Rs1_i)) 
        ForwardA_o = 2'b01;
    if(MEM_WB_RegWrite_i == 1'b1 && (MEM_WB_Rd_i != 0) && (MEM_WB_Rd_i == ID_EX_Rs2_i)) 
        ForwardB_o = 2'b01;
    if(EX_MEM_RegWrite_i == 1'b1 && (EX_MEM_Rd_i != 0) && (EX_MEM_Rd_i == ID_EX_Rs1_i)) 
        ForwardA_o = 2'b10;
    if(EX_MEM_RegWrite_i == 1'b1 && (EX_MEM_Rd_i != 0) && (EX_MEM_Rd_i == ID_EX_Rs2_i)) 
        ForwardB_o = 2'b10;
end
endmodule
