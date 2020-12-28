`define RTYPE 7'b0110011
`define BEQ   7'b1100011
`define ITYPE 7'b0010011
`define LW    7'b0000011
`define SW    7'b0100011

module Control
(
    Op_i,
    NoOp_i,
    ALUOp_o,
    ALUSrc_o,
    RegWrite_o,
    MemWrite_o,
    MemRead_o, 
    MemtoReg_o,
    Branch_o
);

// ports
input   [6:0]   Op_i;
input           NoOp_i;
output  [1:0]   ALUOp_o;
output          ALUSrc_o, RegWrite_o, MemWrite_o, MemRead_o, MemtoReg_o, Branch_o;

// wires and regs
reg [1:0] ALUOp_o;
reg       ALUSrc_o, RegWrite_o, MemWrite_o, MemRead_o, MemtoReg_o, Branch_o;

// main function
always @ (Op_i or NoOp_i) begin
    // Stall
    if(NoOp_i)
        begin
            case(Op_i)
                `BEQ:    ALUOp_o = 2'b00;
                default: ALUOp_o = 2'b01;
            endcase
            ALUSrc_o   = 0; 
            RegWrite_o = 0;
            MemWrite_o = 0;
            MemRead_o  = 0;
            MemtoReg_o = 0;
            Branch_o   = 0;
        end
    // Normal case
    else
        begin
            // ALUOp
            ALUOp_o    <= (Op_i == `RTYPE) ? 2'b10 : // R-type
                          (Op_i == `ITYPE) ? 2'b11 : // SRAI, ADDI
                          (Op_i == `BEQ) ? 2'b01 : // beq
                          2'b00; // lw sw

            // ALUSrc
            ALUSrc_o   <= (Op_i == `RTYPE || Op_i == `BEQ) ? 0 : 1;

            // RegWrite
            RegWrite_o <= (Op_i == `BEQ || Op_i == `SW) ? 0 : 1; 

            // MemWrite
            MemWrite_o <= (Op_i == `SW) ? 1 : 0;

            // MemRead 
            MemRead_o  <= (Op_i == `LW) ? 1 : 0;

            // MemtoReg
            MemtoReg_o <= (Op_i == `LW) ? 1 : 0;

            // Branch
            Branch_o   <= (Op_i == `BEQ)? 1 : 0;
        end
end

endmodule
