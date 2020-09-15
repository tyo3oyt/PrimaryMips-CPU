`include"My_defines.v"
module regfile(
input wire rst,
input wire clk,
input wire en_rs,//1 is enable
input wire[4:0] raddr1,
input wire en_rt,//1 is enable
input wire[4:0] raddr2,

input wire[31:0] wresult,
input wire wif,
input wire[4:0] waddr,//sequential logic

output reg[31:0] rdata1,
output reg[31:0] rdata2
);

reg[31:0] regheap[0:31];

always @(*)
begin
	if(rst==1'b1)
	begin
		rdata1<=`Zero;
	end
	else if(raddr1==5'h0)
	begin
		rdata1<=`Zero;
	end
	else if(raddr1==waddr&&en_rs==1'b1&&wif==1'b1)
	begin
		rdata1<=wresult;
	end
	else if(en_rs==1'b1)
	begin
		rdata1<=regheap[raddr1];
	end
	else if(en_rs==1'b0)
	begin
		rdata1<=`Zero;
	end
	else begin
	 rdata1<=`Zero;
	end
end

always @(*)
begin
	if(rst==1'b1)
	begin
		rdata2<=`Zero;
	end
	else if(raddr2==5'h0)//if read $0(zero)
	begin
		rdata2<=`Zero;
	end
	else if(raddr2==waddr&&en_rt==1'b1&&wif==1'b1)
	begin
		rdata2 <= wresult;
	end
	else if(en_rt==1'b1)
	begin
		rdata2<=regheap[raddr2];
	end
	else if(en_rt==1'b0)
	begin
		rdata2<=`Zero;
	end
	else begin
	 rdata2<=`Zero;
	end
end

always @(posedge clk)
begin
	if(wif==1'b1&&rst==1'b0)
	begin
		regheap[waddr]<=wresult;//write reg
	end
	else
	begin
	end
end

endmodule