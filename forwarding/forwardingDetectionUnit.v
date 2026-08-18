module forwardingDetectionUnit (regWrite_ExMem, regWrite_MemWb, rsAddress_IdEx, rtAddress_IdEx, rdAddress_ExMem, rdAddress_MemWb, 
                                forwardA, forwardB);

input wire regWrite_ExMem;
input wire regWrite_MemWb;
input wire [4:0] rsAddress_IdEx;
input wire [4:0] rtAddress_IdEx;
input wire [4:0] rdAddress_ExMem;
input wire [4:0] rdAddress_MemWb;

output reg[1:0] forwardA;
output reg[1:0] forwardB;

always @* begin

    if (regWrite_ExMem && (rdAddress_ExMem != 0) && (rdAddress_ExMem == rsAddress_IdEx)) 
        forwardA <= 2'b10;
    else if (regWrite_MemWb && (rdAddress_MemWb != 0) && (rdAddress_MemWb == rsAddress_IdEx)) 
        forwardA <= 2'b01;
    else 
        forwardA <= 2'b00;

end

always @* begin

    if (regWrite_ExMem && (rdAddress_ExMem != 0) && (rdAddress_ExMem == rtAddress_IdEx)) 
        forwardB <= 2'b10;
    else if (regWrite_MemWb && (rdAddress_MemWb != 0) && (rdAddress_MemWb == rtAddress_IdEx)) 
        forwardB <= 2'b01;
    else 
        forwardB <= 2'b00;

end


endmodule
