module MuxFwd
#(parameter WIDTH = 32)
(flag, in1, in2, in3, out);

input wire [1:0] flag;
input wire [WIDTH-1:0] in1;
input wire [WIDTH-1:0] in2;
input wire [WIDTH-1:0] in3;

output reg [WIDTH-1:0] out;

always @* begin
    case (flag)
        0 : begin
            out <= in1;
        end
        1 : begin
            out <= in2;
        end
        2 : begin
            out <= in3;
        end
        3 : begin
            out <= 0;
        end
    endcase
end

endmodule
