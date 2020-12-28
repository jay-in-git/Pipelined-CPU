module Hazard_Detection_Unit(
    RS1addr_i,
    RS2addr_i,
    ID_EX_MemRead_i,
    ID_EX_RDaddr_i,
    NoOp_o,
    Stall_o,
    PCWrite_o
);

// ports
input  [4:0] RS1addr_i, RS2addr_i, ID_EX_RDaddr_i;
input        ID_EX_MemRead_i;
output       NoOp_o, Stall_o, PCWrite_o; 

// wires and registers
reg NoOp_o, Stall_o, PCWrite_o;

always @ (RS1addr_i or RS2addr_i or ID_EX_RDaddr_i or ID_EX_MemRead_i) begin
    // load-use data hazard
    if (ID_EX_MemRead_i == 1'b1 && (ID_EX_RDaddr_i == RS1addr_i || ID_EX_RDaddr_i == RS2addr_i)) 
        begin
            NoOp_o    <= 1'b1;
            Stall_o   <= 1'b1;
            PCWrite_o <= 1'b0;
        end        
    else begin
            PCWrite_o <= 1'b1;
            NoOp_o    <= 1'b0;
            Stall_o   <= 1'b0;
    end 
       
end

endmodule
