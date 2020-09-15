`include"My_defines.v"
module inst_rom(
input wire[31:0] pc,
input wire  ce,
output reg[31:0] inst
);
reg[31:0] rom[0:131071];
initial $readmemh("inst_rom.data",rom);
always @(*)
begin
	if(ce==1'b0)
	begin
		inst<=32'h0;
	end
	else 
	begin
		inst<=rom[pc[18:2]];
	end
end
endmodule 

