`include "dmem.v"
`timescale 1ns/1ns

module dmem_tb();

reg clk;
reg [31:0] address;
reg [31:0] write_data;
reg mem_read;
reg mem_write;

wire [31:0] read_data;

Dmem dmem(clk, address, write_data, mem_read, mem_write, read_data);

always @* begin
    #5 clk <= !clk;
end

initial begin
    $dumpfile("dmem.vcd");
    $dumpvars(0, dmem_tb);

    clk = 0;

    #10;
    address = 0;
    write_data = 0;
    mem_read = 0;
    mem_write = 0;

    #10;
    address = 8;
    write_data = 45;
    mem_read = 1;
    mem_write = 1;

    #10;
    mem_write = 0;
    address = 9;

    #10;
    mem_read = 0;
    address = 8;

    #10;
    mem_read = 1;

    #10;
    $finish;
end

endmodule
