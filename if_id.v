`include"My_defines.v"
module pc_id(
input wire rst,
input wire clk,
input wire[31:0] if_pc,
input wire[31:0] pc_inst,
input wire[5:0] stall,
input wire flush,
output reg[31:0] id_pc,
output reg[31:0] id_inst
);

always @(posedge clk)
begin
	if(rst==`Enable)begin
		id_inst<=`Zero;
		id_pc<=`Zero;
	end//if reset,inst is do-nothing inst
	else if(flush == 1'b1)begin
		id_inst<=`Zero;
		id_pc<=`Zero;
	end
	else if(stall[1]==1'b1&&stall[2]==1'b0)begin
		id_inst<=`Zero;
		id_pc<=`Zero;
	end
	else if(stall[1]==1'b0)begin
		id_inst<=pc_inst;
		id_pc<=if_pc;
	end
end
endmodule
