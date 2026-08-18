`include "regfile.v"
`timescale 1ns/1ns

module regfile_tb();

reg clk;
reg [4:0] rs_address;
reg [4:0] rt_address;
reg [4:0] rd_address;
reg [31:0] rd_value;
reg reg_write;

wire [31:0] rs_value;
wire [31:0] rt_value;

RegisterFile regfile(clk, rs_address, rt_address, rd_address, rd_value, reg_write, rs_value, rt_value);

always @* begin
    #5 clk <= !clk;
end

initial begin
    $dumpfile("regfile.vcd");
    $dumpvars(0, regfile_tb);

    clk = 0;
    rs_address = 0;
    rt_address = 0;
    rd_address = 0;
    rd_value = 0;
    reg_write = 0;

    #10;
    rd_address = 1;
    rd_value = 5;
    reg_write = 1;

    #10;
    rs_address = 1;
    rd_address = 31;
    rd_value = 7;

    #10;
    rt_address = 31;
    reg_write = 0;

    #10;

    #10;
    $finish;
end

endmodule
