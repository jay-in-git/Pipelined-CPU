module Hit
(
    tag_i, 
    tag1_i,
    tag2_i,
    cache_index_o,
    hit_o
);
input   [24:0]    tag_i, tag1_i, tag2_i;

output  [1:0]     cache_index_o;
output            hit_o;

assign cache_index_o = (tag1_i[24] == 1'b1 && tag_i[22:0] == tag1_i[22:0]) ? 2'b0  : 
                       (tag2_i[24] == 1'b1 && tag_i[22:0] == tag2_i[22:0]) ? 2'b01 :
                                                                             2'b10; 
assign hit_o = (cache_index_o == 2'b10) ? 0 : 1;
endmodule
