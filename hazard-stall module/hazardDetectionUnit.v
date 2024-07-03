module hazardDetectionUnit (regWrite_ExMem, regWrite_MemWb, rdAddress_ExMem, rdAddress_MemWb, rsAddress_IfId, rtAddress_IfId, hazard);

input wire regWrite_ExMem;
input wire regWrite_MemWb;
input wire [4:0] rdAddress_ExMem;
input wire [4:0] rdAddress_MemWb;
input wire [4:0] rsAddress_IfId;
input wire [4:0] rtAddress_IfId;

output reg hazard;

always @* begin

    if (regWrite_ExMem && (rdAddress_ExMem != 0) && (rdAddress_ExMem == rsAddress_IfId))
        hazard <= 1;
    else if (regWrite_MemWb && (rdAddress_MemWb != 0) && (rdAddress_MemWb == rsAddress_IfId))
        hazard <= 1;
    else if (regWrite_ExMem && (rdAddress_ExMem != 0) && (rdAddress_ExMem == rtAddress_IfId))
        hazard <= 1;
    else if (regWrite_MemWb && (rdAddress_MemWb != 0) && (rdAddress_MemWb == rtAddress_IfId))
        hazard <= 1;
    else
        hazard <= 0;

end

endmodule
