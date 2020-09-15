`include"My_defines.v"
module ex_mem(
input wire rst,
input wire clk,
input wire[31:0] ex_result,
input wire ex_wif,
input wire[4:0] ex_waddr,

input wire[31:0] ex_hi,
input wire[31:0] ex_lo,
input wire ex_whilo,
input wire[5:0] stall,

input wire[6:0] ex_op_type,
input wire[31:0] ex_mem_addr,
input wire[31:0] ex_reg2,

input wire ex_cp0_reg_we,
input wire[4:0] ex_cp0_reg_waddr,
input wire[31:0] ex_cp0_reg_wdata,

input wire flush,
input wire[31:0] ex_excepttype,
input wire[31:0] ex_current_inst_address,
input wire ex_is_in_delayslot,

output reg[31:0] mem_result,
output reg mem_wif,
output reg[4:0] mem_waddr,

output reg mem_whilo,
output reg[31:0] mem_hi,
output reg[31:0] mem_lo,

output reg[6:0] mem_op_type,
output reg[31:0] mem_mem_addr,
output reg[31:0] mem_reg2,

output reg mem_cp0_reg_we,
output reg[4:0] mem_cp0_reg_waddr,
output reg[31:0] mem_cp0_reg_wdata,

output reg[31:0] mem_excepttype,
output reg mem_is_in_delayslot,
output reg[31:0] mem_current_inst_address
);
always @(posedge clk)
begin
	if(rst==1'b1)
	begin
		mem_result<=32'h0;
		mem_wif<=1'b0;
		mem_waddr<=5'b00000;
		mem_hi<=32'b0;
		mem_lo<=32'b0;
		mem_whilo<=1'b0;
		mem_cp0_reg_we<=1'b0;
		mem_cp0_reg_waddr<=5'b00000;
		mem_cp0_reg_wdata<=`Zero;
		mem_excepttype<=`Zero;
		mem_is_in_delayslot<=1'b0;
		mem_current_inst_address<=`Zero;
	end
	else if(flush == 1'b1)begin
		mem_result<=32'h0;
		mem_wif<=1'b0;
		mem_waddr<=5'b00000;
		mem_hi<=32'b0;
		mem_lo<=32'b0;
		mem_whilo<=1'b0;
		mem_cp0_reg_we<=1'b0;
		mem_cp0_reg_waddr<=5'b00000;
		mem_cp0_reg_wdata<=`Zero;
		mem_excepttype<=`Zero;
		mem_is_in_delayslot<=1'b0;
		mem_current_inst_address<=`Zero;
	end
	else if(stall[3]==1'b1&&stall[4]==1'b0)begin
		mem_result<=32'h0;
		mem_wif<=1'b0;
		mem_waddr<=5'b00000;
		mem_hi<=32'b0;
		mem_lo<=32'b0;
		mem_whilo<=1'b0;
		mem_cp0_reg_we<=1'b0;
		mem_cp0_reg_waddr<=5'b00000;
		mem_cp0_reg_wdata<=`Zero;
	end
	else if(stall[3]==1'b0)begin
		mem_result<=ex_result;
		mem_wif<=ex_wif;
		mem_waddr<=ex_waddr;
		mem_hi<=ex_hi;
		mem_lo<=ex_lo;
		mem_whilo<=ex_whilo;
		mem_op_type<=ex_op_type;
		mem_mem_addr<=ex_mem_addr;
		mem_reg2<=ex_reg2;
		mem_cp0_reg_we<=ex_cp0_reg_we;
		mem_cp0_reg_waddr<=ex_cp0_reg_waddr;
		mem_cp0_reg_wdata<=ex_cp0_reg_wdata;
		mem_excepttype<=ex_excepttype;
		mem_is_in_delayslot<=ex_is_in_delayslot;
		mem_current_inst_address<=ex_current_inst_address;
	end
end
endmodule 