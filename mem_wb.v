`include"My_defines.v"
module mem_wb(
input wire rst,
input wire clk,
input wire[31:0] mem_result,
input wire mem_wif,
input wire[4:0] mem_waddr,

input wire[31:0] mem_hi,
input wire[31:0] mem_lo,
input wire mem_whilo,
input wire[5:0] stall,

input wire mem_cp0_reg_we,
input wire[4:0] mem_cp0_reg_waddr,
input wire[31:0] mem_cp0_reg_wdata,

input wire flush,

output reg[31:0] wb_result,
output reg wb_wif,
output reg[4:0] wb_waddr,

output reg[31:0] wb_hi,
output reg[31:0] wb_lo,
output reg wb_whilo,

output reg wb_cp0_reg_we,
output reg[4:0] wb_cp0_reg_waddr,
output reg[31:0] wb_cp0_reg_wdata
);
always @(posedge clk)
begin
	if(rst==1'b1)
	begin
		wb_result<=`Zero;
		wb_wif<=1'b0;
		wb_waddr<=5'b00000;
		wb_hi<=32'b0;
		wb_lo<=32'b0;
		wb_whilo<=1'b0;
		wb_cp0_reg_we<=1'b0;
		wb_cp0_reg_waddr<=5'b00000;
		wb_cp0_reg_wdata<=`Zero;
	end
	else if(flush == 1'b1)begin
		wb_result<=`Zero;
		wb_wif<=1'b0;
		wb_waddr<=5'b00000;
		wb_hi<=32'b0;
		wb_lo<=32'b0;
		wb_whilo<=1'b0;
		wb_cp0_reg_we<=1'b0;
		wb_cp0_reg_waddr<=5'b00000;
		wb_cp0_reg_wdata<=`Zero;
	end
	else if(stall[4]==1'b1&&stall[5]==1'b0)begin
		wb_result<=`Zero;
		wb_wif<=1'b0;
		wb_waddr<=5'b00000;
		wb_hi<=32'b0;
		wb_lo<=32'b0;
		wb_whilo<=1'b0;
		wb_cp0_reg_we<=1'b0;
		wb_cp0_reg_waddr<=5'b00000;
		wb_cp0_reg_wdata<=`Zero;
	end
	else if(stall[4]==1'b0)begin
		wb_result<=mem_result;
		wb_waddr<=mem_waddr;
		wb_wif<=mem_wif;
		wb_hi<=mem_hi;
		wb_lo<=mem_lo;
		wb_whilo<=mem_whilo;
		wb_cp0_reg_we<=mem_cp0_reg_we;
		wb_cp0_reg_waddr<=mem_cp0_reg_waddr;
		wb_cp0_reg_wdata<=mem_cp0_reg_wdata;
	end
end

endmodule 