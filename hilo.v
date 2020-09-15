`include"My_defines.v"
module hilo_reg(
input wire rst,
input wire clk,
input wire wif,
input wire[31:0] hi_i,
input wire[31:0] lo_i,

output reg[31:0] hi_o,
output reg[31:0] lo_o
);
always @ (posedge clk)
begin
	if(rst==`Enable)
	begin
		hi_o<=`Zero;
		lo_o<=`Zero;
	end
	else if(wif==`Enable)
	begin
		hi_o<=hi_i;
		lo_o<=lo_i;
	end
end
endmodule 