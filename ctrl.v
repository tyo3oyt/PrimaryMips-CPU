`include"My_defines.v"
module ctrl(
input wire rst,
input wire stallreq_id,
input wire stallreq_ex,

input wire[31:0] excepttype_i,
input wire[31:0] cp0_epc_i,

output reg[5:0] stall,
output reg[31:0] new_pc,
output reg flush
);

always @ (*)
begin
	if(rst == 1'b1)begin
		stall<=6'b000000;
		flush<=1'b0;
		new_pc<=`Zero;
	end
	else if(excepttype_i!=`Zero)begin
		flush<=1'b1;
		stall<=6'b000000;
		case(excepttype_i)
			32'h00000001:begin
				new_pc<=32'h00000020;
			end
			32'h00000008:begin
				new_pc<=32'h00000040;
			end
			32'h0000000a:begin
				new_pc<=32'h00000040;
			end
			32'h0000000d:begin
				new_pc<=32'h00000040;
			end
			32'h0000000c:begin
				new_pc<=32'h00000040;
			end
			32'h0000000e:begin
				new_pc<=cp0_epc_i;
			end
			default:begin
			end
		endcase
	end
	else if(stallreq_ex==1'b1)begin
		stall<=6'b001111;
		flush<=1'b0;
	end
	else if(stallreq_id==1'b1)begin
		stall<=6'b000111;
		flush<=1'b0;
	end
	else begin
		stall<=6'b000000;
		flush<=1'b0;
		new_pc<=`Zero;
	end
end
endmodule