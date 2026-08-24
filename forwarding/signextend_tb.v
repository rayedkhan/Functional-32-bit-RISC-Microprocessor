`include "signextend.v"
`timescale 1ns/1ns

module signextend_tb();

reg [15:0] in;

wire [31:0] out;

SignExtend signextend(in, out);

initial begin
    $dumpfile("signextend.vcd");
    $dumpvars(0, signextend_tb);

    in = 0;

    #10;
    in = -1;

    #10;
    $finish;
end

endmodule
