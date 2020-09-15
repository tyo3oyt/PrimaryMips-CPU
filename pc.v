`include"My_defines.v"
module pc(
input wire rst,
input wire clk,
input wire[5:0] stall,
input wire branch_flag_i,
input wire[31:0] branch_target_address_i,
input wire flush,//流水线清除信�?
input wire[31:0] new_pc,
output reg[31:0] pc,
output reg ce
);
always @(posedge clk)
begin
	if(rst==`Enable)begin
	ce<=1'b0;
	end
	else begin
	ce <=1'b1;
	end
end

always @(posedge clk)
begin
	if(ce==1'h0)begin
		pc<=32'h00000000;
	end
	else begin
		if(flush==1'b1)begin
			pc<=new_pc;
		end
		else if(stall[0]==1'b0)begin
	    	if(branch_flag_i==`Enable)begin
	       		pc<=branch_target_address_i;
	   		end
			else begin
				pc<= pc+4'h4;
			end
		end
	end
end
endmodule 
