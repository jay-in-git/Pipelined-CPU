`define AND 10'b0000000111
`define XOR 10'b0000000100
`define SLL 10'b0000000001
`define ADD 10'b0000000000
`define SUB 10'b0100000000
`define MUL 10'b0000001000
module ALU_Control(
    funct_i,
    ALUOp_i,
    ALUCtrl_o
);

input [9:0] funct_i;
input [1:0] ALUOp_i;
output [3:0] ALUCtrl_o;
reg [3:0] ALUCtrl;

always@(ALUOp_i or funct_i) begin
    if(ALUOp_i == 2'b10)  // R-type
        case(funct_i)
            `AND: ALUCtrl = 4'b0000;
            `XOR: ALUCtrl = 4'b1000;
            `SLL: ALUCtrl = 4'b1010;
            `ADD: ALUCtrl = 4'b0010;
            `SUB: ALUCtrl = 4'b0110;
            `MUL: ALUCtrl = 4'b1001;
        endcase
   else if(ALUOp_i == 2'b11) // I-type ADDI, SRAI
        case(funct_i[2:0]) // func3 bits
           3'b000: ALUCtrl = 4'b0010; // ADDI's ALUctrl is the same as ADD
           3'b101: ALUCtrl = 4'b1111; // SRAI
        endcase
    
   else if(ALUOp_i == 2'b00) // lw, sw
       case(funct_i[2:0]) // func3 bits
           3'b010: ALUCtrl = 4'b0010;
           3'b000: ALUCtrl = 4'b1011; // case NoOp
       endcase
   else if(ALUOp_i == 2'b01) // beq 
       case(funct_i[2:0]) // func3 bits
           3'b000:  ALUCtrl = 4'b0110;
           default: ALUCtrl = 4'b1011; // case NoOp
       endcase
end

assign ALUCtrl_o = ALUCtrl;
endmodule
