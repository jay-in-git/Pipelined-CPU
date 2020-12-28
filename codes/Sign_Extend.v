`define RTYPE 7'b0110011
`define ITYPE 7'b0010011
`define LW    7'b0000011
`define SW    7'b0100011
`define BEQ   7'b1100011

module Sign_Extend(
    data_i,
    data_o
);

input [31:0] data_i;
output [31:0] data_o;
reg [31:0] extension;
reg [11:0] tmp_extension;
always@(data_i) begin
    if(data_i[6:0] == `ITYPE) begin
        if(data_i[14:12] == 3'b000) begin // ADDI
            tmp_extension = data_i[31:20];
        end

        else if(data_i[14:12] == 3'b101) begin
            if(data_i[24] == 1'b1) 
                tmp_extension = {7'b1111111, data_i[24:20]};
            else 
                tmp_extension = {7'b0000000, data_i[24:20]};
        end
    end 
    else if(data_i[6:0] == `LW) 
        tmp_extension = data_i[31:20];
    else if(data_i[6:0] == `SW)
        tmp_extension = {data_i[31:25], data_i[11:7]};
    else if(data_i[6:0] == `BEQ)
        tmp_extension = {data_i[31], data_i[7], data_i[30:25], data_i[11:8]};

    if(tmp_extension[11] == 1'b1) begin
        extension = {20{1'b1}};
        extension = extension << 12;
    end
    else begin 
        extension = 0;
    end
    extension = extension + tmp_extension;
end

assign data_o = extension;
endmodule
