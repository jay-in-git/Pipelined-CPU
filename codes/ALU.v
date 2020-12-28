`define ADD 4'b0010
`define SUB 4'b0110
`define MUL 4'b1001
`define AND 4'b0000
`define XOR 4'b1000
`define SLL 4'b1010
`define SRAI 4'b1111
`define NOOP 4'b1101

module ALU(
    data1_i,
    data2_i,
    ALUCtrl_i,
    data_o,
    Zero_o
);

input signed [31:0] data1_i, data2_i;
input [3:0] ALUCtrl_i;
output signed[31:0] data_o;
output Zero_o;
reg signed [31:0] data_reg;
reg IsZero; // Iszero = 1, Zero_o = 1, Iszero = 0, zero_o = 0;
always @ (data1_i or data2_i or ALUCtrl_i) begin
    case(ALUCtrl_i)
            `ADD: data_reg = data1_i + data2_i;
            `SUB: 
             begin 
                 data_reg = data1_i - data2_i;
                 IsZero = (data1_i == data2_i) ? 1 : 0;
             end 
            `MUL: data_reg = data1_i * data2_i;
            `AND: data_reg = data1_i & data2_i;
            `XOR: data_reg = data1_i ^ data2_i;
            `SLL: data_reg = data1_i << data2_i;
            `SRAI: data_reg = data1_i >>> (data2_i[4:0]);
    endcase 
end 
assign data_o = data_reg;
assign Zero_o = IsZero;
endmodule 
