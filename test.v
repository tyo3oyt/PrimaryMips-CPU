`timescale 1ns/1ps
module test();
reg clock;
reg rst;
initial begin
clock = 1'b0;
forever #10 clock = ~clock;
end

initial begin
rst = 1'b1;
#195 rst  = 1'b0;
#3500 $stop;
end

sopc sopc0(
.rst(rst),
.clk(clock)
);

endmodule 