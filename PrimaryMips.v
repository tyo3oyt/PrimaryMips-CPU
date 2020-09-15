module PrimaryMips(
input wire rst,
input wire clk,
input wire[31:0] rom_inst,
input wire[31:0] ram_data_i,
input wire[5:0] int_i,

output wire rom_ce,
output wire[31:0] rom_addr,
output wire[31:0] ram_addr_o,
output wire[31:0] ram_data_o,
output wire ram_we_o,
output wire[3:0] ram_sel_o,
output wire ram_ce_o,
output wire timer_int_o
);

//the instantiation and connection signals of 
//ench module must be witten together
wire[31:0] pc;
wire[5:0] stall_con;
wire branch_flag;
wire[31:0] branch_target_address;
wire flush;
wire[31:0] new_pc;
pc pc0(
	.rst(rst),
	.clk(clk),
	.stall(stall_con),
	.branch_flag_i(branch_flag),
	.branch_target_address_i(branch_target_address),
	.flush(flush),
	.new_pc(new_pc),

	.pc(pc),
	.ce(rom_ce)
);
assign rom_addr = pc;

wire[31:0] inst_con1;
wire[31:0] pc_if_id;
pc_id pc_id0(
	.rst(rst),
	.clk(clk),
	.if_pc(pc),
	.pc_inst(rom_inst),
	.stall(stall_con),
	.flush(flush),

	.id_pc(pc_if_id),
	.id_inst(inst_con1)
);

wire[31:0] reg1;
wire[31:0] reg2;
wire[6:0] alu;
wire en;
wire[4:0] addr;
wire[31:0] data_con1;
wire[31:0] data_con2;

wire en1,en2;
wire[4:0] addr1,addr2;
wire[31:0] data_reg;
wire en_reg;
wire[4:0] addr_reg;

wire[31:0] wdata_wb;
wire en_wb;
wire[4:0] addr_wb;
// output of mem module

wire[31:0] wdata;
wire en_mem;
wire[4:0] addr_mem;
wire stallreq_from_id;
wire stallreq_from_ex;
wire id_ex_to_id;
//output of ex module 
wire in_delayslot;
wire[31:0] addr_link;
wire next_in_delayslot;
wire[31:0] inst;
wire[6:0] op_type_ex;
wire[31:0] excepttype_from_id;
wire[31:0] current_inst_pc;
id id0(
	.rst(rst),
	.inst_i(inst_con1),
	.pc_i(pc_if_id),
	.data1_i(data_con1),
	.data2_i(data_con2),
	.ex_data_o(wdata),
	.ex_waddr_o(addr_mem),
	.ex_wif_o(en_mem),
	.mem_data_o(wdata_wb),
	.mem_waddr_o(addr_wb),
	.mem_wif_o(en_wb),	
	.is_in_delayslot_i(id_ex_to_id),
	.ex_op_type_i(op_type_ex),
	
	.op_type(alu),
	.data1_addr(addr1),
	.re1(en1),
	.data2_addr(addr2),
	.re2(en2),
	.wif(en),
    .waddr(addr),
	.data1_o(reg1),
	.data2_o(reg2),
    .next_inst_in_delayslot_o(next_in_delayslot),
	.branch_flag_o(branch_flag),
	.branch_target_address_o(branch_target_address),
    .link_addr_o(addr_link),
	.is_in_delayslot_o(in_delayslot),
    .stallreq(stallreq_from_id),
	.inst_o(inst),
	.excepttype_o(excepttype_from_id),
	.current_inst_address_o(current_inst_pc)
);

regfile regfile0(
	.rst(rst),
	.clk(clk),
	.en_rs(en1),
	.raddr1(addr1),
	.en_rt(en2),
	.raddr2(addr2),
	.wresult(data_reg),
	.wif(en_reg),
	.waddr(addr_reg),
	.rdata1(data_con1),
	.rdata2(data_con2)
);

wire[31:0] hi_mem_wb;
wire[31:0] lo_mem_wb;
wire whilo_mem_wb;

wire[31:0] hi_wb;
wire[31:0] lo_wb;
wire whilo_wb;

wire[31:0] hi_hilo_ex;
wire[31:0] lo_hilo_ex;

wire ex_cp0_we_wb;
wire[4:0] ex_cp0_waddr_wb;
wire[31:0] ex_cp0_data_wb;
wire ex_cp0_we_mem;
wire[4:0] ex_cp0_waddr_mem;
wire[31:0] ex_cp0_data_mem;


hilo_reg hilo_reg0(
    .rst(rst),
	.clk(clk),
	.wif(whilo_wb),
	.hi_i(hi_wb),
	.lo_i(lo_wb),

    .hi_o(hi_hilo_ex),
	.lo_o(lo_hilo_ex)
);

 wire[6:0] alu_ex;
 wire[31:0] reg1_ex;
 wire[31:0] reg2_ex;
 wire en_ex;
 wire[4:0] addr_ex;
 wire ex_in_delayslot;
 wire[31:0] address_link;
 wire[31:0] inst_id_ex;
 wire[31:0] excepttype_to_ex;
 wire[31:0] current_inst_pc_to_ex;

 id_ex id_ex0(
    .rst(rst),
	.clk(clk),
	.op_type_id(alu),
	.data1_id(reg1),
	.data2_id(reg2),
	.wif_id(en),
	.waddr_id(addr),
	.stall(stall_con),
	.id_link_address(addr_link),
	.id_is_in_delayslot(in_delayslot),
	.next_inst_in_delayslot_i(next_in_delayslot),
	.id_inst(inst),
	.flush(flush),
	.id_excepttype(excepttype_from_id),
	.id_current_inst_addr(current_inst_pc),
	
	.op_type_ex(alu_ex),
	.data1_ex(reg1_ex),
	.data2_ex(reg2_ex),
	.wif_ex(en_ex),
	.waddr_ex(addr_ex),
	.ex_link_address(address_link),
	.ex_is_in_delayslot(ex_in_delayslot),
	.is_in_delayslot_o(id_ex_to_id),
	.ex_inst(inst_id_ex),
	.ex_excepttype(excepttype_to_ex),
	.ex_current_inst_addr(current_inst_pc_to_ex)
 );
wire[31:0] hi_ex_mem;
wire[31:0] lo_ex_mem;
wire whilo_ex_mem;
wire sign;
wire[31:0] div_data1;
wire[31:0] div_data2;
wire start_con;
wire annul_con;
wire ready_con;
wire[63:0] result_con;

wire[31:0] mem_addr_ex;
wire[31:0] wdata_ex;



wire[31:0] data_from_cp0;
wire[4:0] reg_addr_to_cp0;
//link module cp0
wire cp0_reg_we_ex;
wire[4:0] cp0_reg_waddr_ex;
wire[31:0] cp0_reg_wdata_ex;
wire[31:0] excepttype_from_ex;
wire[31:0] current_inst_pc_from_ex;
wire is_in_delayslot_from_ex;
ex ex0(
    .rst(rst),
	.op_type_i(alu_ex),
	.data1_i(reg1_ex),
	.data2_i(reg2_ex),
	.wif_ex_i(en_ex),
	.waddr_ex_i(addr_ex),
	.hi_i(hi_hilo_ex),
	.lo_i(lo_hilo_ex),
	.mem_hi_i(hi_mem_wb),
	.mem_lo_i(lo_mem_wb),
	.mem_whilo_i(whilo_mem_wb),
	.wb_hi_i(hi_wb),
	.wb_lo_i(lo_wb),
	.wb_whilo_i(whilo_wb),
	.div_result_i(result_con),
	.div_ready_i(ready_con),
	.link_address_i(address_link),
	.is_in_delayslot_i(ex_in_delayslot),
	.inst_i(inst_id_ex),
	.mem_cp0_reg_we(ex_cp0_we_mem),
	.mem_cp0_reg_waddr(ex_cp0_waddr_mem),
	.mem_cp0_reg_data(ex_cp0_data_mem),
	.wb_cp0_reg_we(ex_cp0_we_wb),
	.wb_cp0_reg_waddr(ex_cp0_waddr_wb),
	.wb_cp0_reg_data(ex_cp0_data_wb),
	.cp0_reg_rdata_i(data_from_cp0),
	.excepttype_i(excepttype_to_ex),
	.current_inst_addr_i(current_inst_pc_to_ex),

	.cp0_reg_addr_o(reg_addr_to_cp0),
	.cp0_reg_we_o(cp0_reg_we_ex),
	.cp0_reg_waddr_o(cp0_reg_waddr_ex),
	.cp0_reg_data_o(cp0_reg_wdata_ex),
	.hi_o(hi_ex_mem),
	.lo_o(lo_ex_mem),
	.whilo_o(whilo_ex_mem),
	.result(wdata),
	.wif_ex_o(en_mem),
	.waddr_ex_o(addr_mem),
	.div_opdata1_o(div_data1),
	.div_opdata2_o(div_data2),
	.div_signed_o(sign),
	.div_start_o(start_con),
	.stallreq(stallreq_from_ex),
	.op_type_o(op_type_ex),
	.mem_addr_o(mem_addr_ex),
	.reg2_o(wdata_ex),
	.excepttype_o(excepttype_from_ex),
	.current_inst_addr_o(current_inst_pc_from_ex),
	.is_in_delayslot_o(is_in_delayslot_from_ex)
);

div div0(
	.clk(clk),
	.rst(rst),
	.signed_div_i(sign),
	.opdata1_i(div_data1),
	.opdata2_i(div_data2),
	.start_i(start_con),
	.annul_i(flush),
	
	.result_o(result_con),
	.ready_o(ready_con)
);
wire[31:0] wdata_mem;
wire en_mem1;
wire[4:0] addr_mem1;

wire[31:0] hi_con_mem;
wire[31:0] lo_con_mem;
wire  whilo_con_mem;

wire[6:0] op_type_mem;
wire[31:0] mem_addr_mem;
wire[31:0] wdata_ex_mem;

wire cp0_reg_we_ex_mem;
wire[4:0] cp0_reg_waddr_ex_mem;
wire[31:0] cp0_reg_wdata_ex_mem;
wire[31:0] excepttype_to_mem;
wire[31:0] current_inst_pc_to_mem;
wire is_in_delayslot_to_mem;

ex_mem  ex_mem0(
	.rst(rst), 
	.clk(clk),
	.ex_result(wdata),
	.ex_wif(en_mem), 
	.ex_waddr(addr_mem),
	.ex_hi(hi_ex_mem),
	.ex_lo(lo_ex_mem),
	.ex_whilo(whilo_ex_mem),
	.stall(stall_con),
	.ex_op_type(op_type_ex),
	.ex_mem_addr(mem_addr_ex),
	.ex_reg2(wdata_ex),
	.ex_cp0_reg_we(cp0_reg_we_ex),
	.ex_cp0_reg_waddr(cp0_reg_waddr_ex),
	.ex_cp0_reg_wdata(cp0_reg_wdata_ex),
	.flush(flush),
	.ex_excepttype(excepttype_from_ex),
	.ex_current_inst_address(current_inst_pc_from_ex),
	.ex_is_in_delayslot(is_in_delayslot_from_ex),

	.mem_result(wdata_mem),
	.mem_wif(en_mem1),
	.mem_waddr(addr_mem1),
	.mem_whilo(whilo_con_mem),
	.mem_hi(hi_con_mem),
	.mem_lo(lo_con_mem),
	.mem_op_type(op_type_mem),
	.mem_mem_addr(mem_addr_mem),
	.mem_reg2(wdata_ex_mem),
	.mem_cp0_reg_we(cp0_reg_we_ex_mem),
	.mem_cp0_reg_waddr(cp0_reg_waddr_ex_mem),
	.mem_cp0_reg_wdata(cp0_reg_wdata_ex_mem),
	.mem_excepttype(excepttype_to_mem),
	.mem_is_in_delayslot(is_in_delayslot_to_mem),
	.mem_current_inst_address(current_inst_pc_to_mem)
);

wire[31:0] excepttype_from_mem;
wire[31:0] current_inst_pc_from_mem;
wire is_in_delayslot_from_mem;
wire[31:0] latest_epc;
wire[31:0] status_from_cp0;
wire[31:0] cause_from_cp0;
wire[31:0] epc_from_cp0;
mem mem0(
	.rst(rst),
	.result_i(wdata_mem),
	.wif_i(en_mem1),
	.waddr_i(addr_mem1),
	.hi_i(hi_con_mem),
	.lo_i(lo_con_mem),
	.whilo_i(whilo_con_mem),
	.op_type_i(op_type_mem),
	.mem_addr_i(mem_addr_mem),
	.reg2_i(wdata_ex_mem),
	.mem_data_i(ram_data_i),
	.cp0_reg_we_i(cp0_reg_we_ex_mem),
	.cp0_reg_waddr_i(cp0_reg_waddr_ex_mem),
	.cp0_reg_wdata_i(cp0_reg_wdata_ex_mem),
	.excepttype_i(excepttype_to_mem),
	.is_in_delayslot_i(is_in_delayslot_to_mem),
	.current_inst_address_i(current_inst_pc_to_mem),
	.cp0_status_i(status_from_cp0),
	.cp0_cause_i(cause_from_cp0),
	.cp0_epc_i(epc_from_cp0),
	.wb_cp0_reg_we(ex_cp0_we_wb),
	.wb_cp0_reg_write_addr(ex_cp0_waddr_wb),
	.wb_cp0_reg_data(ex_cp0_data_wb),

	.result_o(wdata_wb),
	.wif_o(en_wb),
	.waddr_o(addr_wb),
	.hi_o(hi_mem_wb),
	.lo_o(lo_mem_wb),
	.whilo_o(whilo_mem_wb),
	.mem_addr_o(ram_addr_o),
	.mem_we_o(ram_we_o),
	.mem_sel_o(ram_sel_o),
	.mem_data_o(ram_data_o),
	.mem_ce_o(ram_ce_o),
	.cp0_reg_we_o(ex_cp0_we_mem),
	.cp0_reg_waddr_o(ex_cp0_waddr_mem),
	.cp0_reg_wdata_o(ex_cp0_data_mem),
	.excepttype_o(excepttype_from_mem),
	.cp0_epc_o(latest_epc),
	.is_in_delayslot_o(is_in_delayslot_from_mem),
	.current_inst_address_o(current_inst_pc_from_mem)
);

ctrl ctrl0(
	.rst(rst),
	.stallreq_id(stallreq_from_id),
	.stallreq_ex(stallreq_from_ex),
	.excepttype_i(excepttype_from_mem),
	.cp0_epc_i(latest_epc),

	.stall(stall_con),
	.new_pc(new_pc),
	.flush(flush)
);

cp0 cp0_demo(
	.rst(rst),
	.clk(clk),
	.raddr_i(reg_addr_to_cp0),
	.int_i(int_i),
	.we_i(ex_cp0_we_wb),
	.waddr_i(ex_cp0_waddr_wb),
	.wdata_i(ex_cp0_data_wb),
	.excepttype_i(excepttype_from_mem),
	.current_inst_address_i(current_inst_pc_from_mem),
	.is_in_delayslot_i(is_in_delayslot_from_mem),

	.status_o(status_from_cp0),
	.cause_o(cause_from_cp0),
	.epc_o(epc_from_cp0),
	.data_o(data_from_cp0),
	.timer_int_o(timer_int_o)
);
mem_wb mem_wb0(
	.rst(rst),
	.clk(clk),
	.mem_result(wdata_wb),
	.mem_wif(en_wb),
	.mem_waddr(addr_wb),
	.mem_hi(hi_mem_wb),
	.mem_lo(lo_mem_wb),
	.mem_whilo(whilo_mem_wb),
	.stall(stall_con),
	.mem_cp0_reg_we(ex_cp0_we_mem),
	.mem_cp0_reg_waddr(ex_cp0_waddr_mem),
	.mem_cp0_reg_wdata(ex_cp0_data_mem),
	.flush(flush),
	
	.wb_result(data_reg),
	.wb_wif(en_reg),
	.wb_waddr(addr_reg),
	.wb_hi(hi_wb),
	.wb_lo(lo_wb),
	.wb_whilo(whilo_wb),
	.wb_cp0_reg_we(ex_cp0_we_wb),
	.wb_cp0_reg_waddr(ex_cp0_waddr_wb),
	.wb_cp0_reg_wdata(ex_cp0_data_wb)
);
endmodule