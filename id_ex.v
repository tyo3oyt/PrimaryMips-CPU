`include"My_defines.v"
module id_ex(
input wire rst,
input wire clk,
input wire[6:0] op_type_id,
input wire[31:0] data1_id,
input wire[31:0] data2_id,
input wire wif_id,
input wire[4:0] waddr_id,
input wire[5:0] stall,
input wire[31:0] id_link_address,
input wire id_is_in_delayslot,
input wire next_inst_in_delayslot_i,
input wire[31:0] id_inst,
input wire flush,
input wire[31:0] id_excepttype,
input wire[31:0] id_current_inst_addr,


output reg[6:0] op_type_ex,
output reg[31:0] data1_ex,
output reg[31:0] data2_ex,
output reg wif_ex,
output reg[4:0] waddr_ex,

output reg[31:0] ex_link_address,
output reg ex_is_in_delayslot,
output reg is_in_delayslot_o,
output reg[31:0] ex_inst,
output reg[31:0] ex_excepttype,
output reg[31:0] ex_current_inst_addr
);
always @(posedge clk)
begin
	if(rst==1'b1)
	begin
		op_type_ex<=7'b0000000;
		data1_ex<=`Zero;
		data2_ex<=`Zero;
	    wif_ex<=1'b0;
		waddr_ex<=5'b00000;
		ex_link_address<=`Zero;
		ex_is_in_delayslot<=1'b0;
		is_in_delayslot_o<=1'b0;
		ex_excepttype<=`Zero;
		ex_current_inst_addr<=`Zero;
		
	end
	else if(flush==1'b1)begin
		op_type_ex<=7'b0000000;
		data1_ex<=`Zero;
		data2_ex<=`Zero;
	    wif_ex<=1'b0;
		waddr_ex<=5'b00000;
		ex_link_address<=`Zero;
		ex_is_in_delayslot<=1'b0;
		is_in_delayslot_o<=1'b0;
		ex_excepttype<=`Zero;
		ex_current_inst_addr<=`Zero;
	end
	else if(stall[2]==1'b1&&stall[3]==1'b0)begin
		op_type_ex<=7'b0000000;
		data1_ex<=`Zero;
		data2_ex<=`Zero;
	    wif_ex<=1'b0;
		waddr_ex<=5'b00000;
		ex_link_address<=`Zero;
		ex_is_in_delayslot<=1'b0;
	end
	else if(stall[2]==1'b0)begin
		op_type_ex<=op_type_id;
		data1_ex<=data1_id;
		data2_ex<=data2_id;
		wif_ex<=wif_id;
		waddr_ex<=waddr_id;
		ex_link_address<=id_link_address;
		ex_is_in_delayslot<=id_is_in_delayslot;
		is_in_delayslot_o<=next_inst_in_delayslot_i;
		ex_inst<=id_inst;
		ex_excepttype<=id_excepttype;
		ex_current_inst_addr<=id_current_inst_addr;
	end
end
endmodule