module Register_stall #(parameter WIDTH = 32) (clk, write, in, out);

input wire clk;
input wire write;
input wire [WIDTH - 1 : 0] in;
output reg [WIDTH - 1 : 0] out = 0;

always @(posedge clk) begin
    if (write) out <= in;
end

endmodule
