module sopc(
input wire rst,
input wire clk
);
wire[31:0] inst_addr;
wire[31:0] inst;
wire rom_ce;
wire[31:0] ldata;
wire[31:0] wdata;
wire we_con;
wire ce_con;
wire[3:0] sel_con;
wire[31:0] addr_con;
wire[5:0] int;
wire timer_int;
assign int={5'b00000,timer_int};
PrimaryMips PrimaryMips0(
	.rst(rst),
	.clk(clk),
	.rom_inst(inst),
	.ram_data_i(ldata),
	.int_i(int),
	
	.rom_ce(rom_ce),
	.rom_addr(inst_addr),
	.ram_addr_o(addr_con),
	.ram_data_o(wdata),
    .ram_we_o(we_con),
    .ram_sel_o(sel_con),
    .ram_ce_o(ce_con),
    .timer_int_o(timer_int)
);
inst_rom inst_rom0(
	.pc(inst_addr),
	.ce(rom_ce),
	.inst(inst)
);
data_ram data_ram0(
   .clk(clk),
   .ce(ce_con),
   .we(we_con),
   .addr(addr_con),
   .sel(sel_con),
   .data_i(wdata),
   .data_o(ldata)
);
endmodule 