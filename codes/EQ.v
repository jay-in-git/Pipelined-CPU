module EQ(
    input [31:0] Src1_i,
    input [31:0] Src2_i,
    output Result_o
);

assign Result_o = (Src1_i == Src2_i) ? 1: 0;

endmodule