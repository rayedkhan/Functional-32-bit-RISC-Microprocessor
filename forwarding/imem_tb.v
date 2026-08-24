`include "imem.v"
`timescale 1ns/1ns

module imem_tb();

reg [31:0] address;

wire [31:0] read_data;

Imem imem(address, read_data);

initial begin
    $dumpfile("imem.vcd");
    $dumpvars(0, imem_tb);

    address = 0;

    #10;
    address = 4;

    #10;
    address = 8;

    #10;
    address = 12;

    #10;
    $finish;
end

endmodule
