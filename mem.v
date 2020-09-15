`include"My_defines.v"
module mem(
input wire rst,
input wire[31:0] result_i,
input wire wif_i,
input wire[4:0] waddr_i,

input wire[31:0] hi_i,
input wire[31:0] lo_i,
input wire whilo_i,

input wire[6:0] op_type_i,
input wire[31:0] mem_addr_i,
input wire[31:0] reg2_i,
input wire[31:0] mem_data_i,//data from data_ram

input wire cp0_reg_we_i,
input wire[4:0] cp0_reg_waddr_i,
input wire[31:0] cp0_reg_wdata_i,

input wire[31:0] excepttype_i,
input wire is_in_delayslot_i,
input wire[31:0] current_inst_address_i,
input wire[31:0] cp0_status_i,
input wire[31:0] cp0_cause_i,
input wire[31:0] cp0_epc_i,
input wire wb_cp0_reg_we,
input wire[4:0] wb_cp0_reg_write_addr,
input wire[31:0] wb_cp0_reg_data,

output reg[31:0] result_o,
output reg wif_o,
output reg[4:0]  waddr_o,

output reg[31:0] hi_o,
output reg[31:0] lo_o,
output reg whilo_o,

output reg[31:0] mem_addr_o,
output wire mem_we_o,
output reg[3:0] mem_sel_o,//choose byte
output reg[31:0] mem_data_o,
output reg mem_ce_o,//enable or disable

output reg cp0_reg_we_o,
output reg[4:0] cp0_reg_waddr_o,
output reg[31:0] cp0_reg_wdata_o,

output reg[31:0] excepttype_o,
output wire[31:0] cp0_epc_o,
output wire is_in_delayslot_o,
output wire[31:0] current_inst_address_o
);
reg mem_we;
assign mem_we_o=mem_we&(~(|excepttype_o));
assign is_in_delayslot_o=is_in_delayslot_i;
assign current_inst_address_o=current_inst_address_i;
reg[31:0] cp0_status;
reg[31:0] cp0_cause;
reg[31:0] cp0_epc;

always @(*)
begin
	if(rst==1'b1)
	begin
		result_o<=`Zero;
		wif_o<=1'b0;
		waddr_o<=5'b00000;
		hi_o<=32'b0;
		lo_o<=32'b0;
		whilo_o<=1'b0;
		mem_addr_o<=`Zero;
		mem_we<=`Disable;
		mem_sel_o<=4'b0000;
		mem_data_o<=`Zero;
		mem_ce_o<=`Disable;
		cp0_reg_we_o<=1'b0;
		cp0_reg_waddr_o<=5'b00000;
		cp0_reg_wdata_o<=`Zero;
	end
	else 
	begin
		result_o<=result_i;
		wif_o<=wif_i;
		waddr_o<=waddr_i;
		hi_o<=hi_i;
		lo_o<=lo_i;
		whilo_o<=whilo_i;
		mem_we<=`Disable;
		mem_addr_o<=`Zero;
		mem_sel_o<=4'b1111;// if load word then mem_sel_o=4'b1111
		mem_ce_o<=`Disable;
		cp0_reg_we_o<=cp0_reg_we_i;
		cp0_reg_waddr_o<=cp0_reg_waddr_i;
		cp0_reg_wdata_o<=cp0_reg_wdata_i;
		case(op_type_i)
		`Op_Lb:
		begin
		    mem_addr_o<=mem_addr_i;
		    mem_we<=`Disable;
		    mem_ce_o<=`Enable;
		    case(mem_addr_i[1:0])
		    2'b00:
		    begin
		        mem_sel_o<=4'b1000;
		        result_o<={{24{mem_data_i[31]}},mem_data_i[31:24]};
		    end
		    2'b01:
		    begin
		        mem_sel_o<=4'b0100;
		        result_o<={{24{mem_data_i[23]}},mem_data_i[23:16]};
		    end
		    2'b10:
		    begin
		        mem_sel_o<=4'b0010;
		        result_o<={{24{mem_data_i[15]}},mem_data_i[15:8]};
		    end
		    2'b11:
		    begin
		        mem_sel_o<=4'b0001;
		        result_o<={{24{mem_data_i[7]}},mem_data_i[7:0]};
		    end
		    default:begin
		        result_o<=`Zero;
		    end
		    endcase
		end
		`Op_Lbu:
		begin
		    mem_addr_o<=mem_addr_i;
		    mem_we<=`Disable;
		    mem_ce_o<=`Enable;
		    case(mem_addr_i[1:0])
		    2'b00:
		    begin
		        mem_sel_o<=4'b1000;
		        result_o<={{24{1'b0}},mem_data_i[31:24]};
		    end
		    2'b01:
		    begin
		        mem_sel_o<=4'b0100;
		        result_o<={{24{1'b0}},mem_data_i[23:16]};
		    end
		    2'b10:
		    begin
		        mem_sel_o<=4'b0010;
		        result_o<={{24{1'b0}},mem_data_i[15:8]};
		    end
		    2'b11:
		    begin
		        mem_sel_o<=4'b0001;
		        result_o<={{24{1'b0}},mem_data_i[7:0]};
		    end
		    default:begin
		       result_o<=`Zero;
		    end
		    endcase
		end
		`Op_Lh:
		begin
		    mem_addr_o<=mem_addr_i;
		    mem_we<=`Disable;
		    mem_ce_o<=`Enable;
		    case(mem_addr_i[1:0])
		    2'b00:
		    begin
		        result_o<={{16{mem_data_i[31]}},mem_data_i[31:16]};
		        mem_sel_o<=4'b1100;
		    end
		    2'b10:
		    begin
		        result_o<={{16{mem_data_i[15]}},mem_data_i[15:0]};
		        mem_sel_o<=4'b0011;
		    end
		    default:begin
		        result_o<=`Zero;
		    end
		    endcase
		end
		`Op_Lhu:
		begin
		    mem_addr_o<=mem_addr_i;
		    mem_we<=`Disable;
		    mem_ce_o<=`Enable;
		    case(mem_addr_i[1:0])
		    2'b00:
		    begin
		        result_o<={{16{1'b0}},mem_data_i[31:16]};
		        mem_sel_o<=4'b1100;
		    end
		    2'b10:
		    begin
		        result_o<={{16{1'b0}},mem_data_i[15:0]};
		        mem_sel_o<=4'b0011;
		    end
		    default:begin
		        result_o<=`Zero;
		    end
		    endcase
		end
		`Op_Lw:
		begin
		    mem_addr_o<=mem_addr_i;
		    mem_we<=`Disable;
		    result_o<=mem_data_i;
		    mem_sel_o<=4'b1111;
		    mem_ce_o<=`Enable;
		end
		`Op_Sb:
		begin
		    mem_addr_o<=mem_addr_i;
		    mem_we<=`Enable;
		    mem_ce_o<=`Enable;
		    mem_data_o<={reg2_i[7:0],reg2_i[7:0],reg2_i[7:0],reg2_i[7:0]};
		    case(mem_addr_i[1:0])
		    2'b00:
		    begin
		        mem_sel_o<=4'b1000;
		    end
		    2'b01:
		    begin
		        mem_sel_o<=4'b0100;
		    end
		    2'b10:
		    begin
		        mem_sel_o<=4'b0010;
		    end
		    2'b11:
		    begin
		        mem_sel_o<=4'b0001;
		    end
		    default:begin
		        mem_sel_o<=4'b0000;
		    end
		    endcase
		end
		`Op_Sh:
		begin
	        mem_addr_o<=mem_addr_i;
	        mem_we<=`Enable;
	        mem_ce_o<=`Enable;
	        mem_data_o<={reg2_i[15:0],reg2_i[15:0]};
	        case(mem_addr_i[1:0])
	        2'b00:
	        begin
	            mem_sel_o<=4'b1100;
	        end
	        2'b10:
	        begin
	            mem_sel_o<=4'b0011;
	        end
	        default:begin
	            mem_sel_o<=4'b0000;
	        end
	        endcase
		end
		`Op_Sw:
		begin
		    mem_addr_o<=mem_addr_i;
		    mem_we<=`Enable;
		    mem_ce_o<=`Enable;
		    mem_data_o<=reg2_i;
		    mem_sel_o<=4'b1111;
		end
		default:
		begin 
		end
		endcase
	end
end

always @(*)begin
	if(rst==1'b1)begin
		cp0_status<=`Zero;
	end
	else if(wb_cp0_reg_we==1'b1&&wb_cp0_reg_write_addr==`cp0_status)begin
		cp0_status<=wb_cp0_reg_data;
	end
	else begin
		cp0_status<=cp0_status_i;
	end
end

always @(*)begin
	if(rst==1'b1)begin
		cp0_epc<=`Zero;
	end
	else if(wb_cp0_reg_we==1'b1&&wb_cp0_reg_write_addr==`cp0_epc)begin
		cp0_epc<=wb_cp0_reg_data;
	end
	else begin
		cp0_epc<=cp0_epc_i;
	end
end
assign cp0_epc_o=cp0_epc;
always @(*)begin
	if(rst==1'b1)begin
		cp0_cause<=`Zero;
	end
	else if(wb_cp0_reg_we==1'b1&&wb_cp0_reg_write_addr==`cp0_status)begin
		cp0_cause[9:8] <= wb_cp0_reg_data[9:8];
		cp0_cause[22]<=wb_cp0_reg_data[22];
		cp0_cause[23]<=wb_cp0_reg_data[23];
	end
	else begin
		cp0_cause<=cp0_cause_i;
	end
end


//exception
//31_____13___12______11______10__________9____________8______7_________0
//|保留字段|  eret |   ov  |  trap | inst_invalid |  syscall  | 外部中断 |
//final exception type
always @(*)begin
	if(rst==1'b1)begin
		excepttype_o<=`Zero;
	end
	else begin
		excepttype_o<=`Zero;
		if(current_inst_address_i!=`Zero)begin
			if((cp0_status[1]==1'b0)&&(cp0_status[0]==1'b1)&&((cp0_cause[15:8] & cp0_status[15:8] )!=8'b00000000))begin
				excepttype_o<=32'h00000001;//interrupt
			end
			else if(excepttype_i[8]==1'b1)begin
				excepttype_o<=32'h00000008;//syscall
			end
			else if(excepttype_i[9]==1'b0)begin
				excepttype_o<=32'h0000000a;//inst_invalid
			end
			else if(excepttype_i[10]==1'b1)begin
				excepttype_o<=32'h0000000d;//trap
			end
			else if(excepttype_i[11]==1'b1)begin
				excepttype_o<=32'h0000000c;//ov
			end
			else if(excepttype_i[12]==1'b1)begin
				excepttype_o<=32'h0000000e;//eret
			end
		end
	end
end
endmodule 