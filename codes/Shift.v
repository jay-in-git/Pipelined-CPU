module Shifter(
    input [31:0] Src_i,
    input [4:0] ShiftNum_i,
    output [31:0] Result_o
);

assign Result_o = Src_i << ShiftNum_i;

endmodule
