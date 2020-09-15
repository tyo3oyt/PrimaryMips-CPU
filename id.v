`include"My_defines.v"
module id(
input wire rst,
input wire[31:0] inst_i,
input wire[31:0] pc_i,
input wire[31:0] data1_i,//op data 1
input wire[31:0] data2_i,//op data 2
//data risk
input wire[31:0] ex_data_o,
input wire[4:0] ex_waddr_o,
input wire ex_wif_o,//from ex module 
input wire[31:0] mem_data_o,
input wire[4:0] mem_waddr_o,
input wire mem_wif_o,//from mem module

input wire is_in_delayslot_i,

input wire[6:0] ex_op_type_i,

output reg[6:0] op_type,
output reg[4:0] data1_addr,//address of op data 1
output reg re1,
output reg[4:0] data2_addr,//address of op data 1
output reg re2,//1 is enable 
output reg wif,//1 symbol need to write regfile
output reg[4:0] waddr,//the address of result need to write regfile 
output reg[31:0] data1_o,
output reg[31:0] data2_o,//the op data transfer to next module

output reg next_inst_in_delayslot_o,
output reg branch_flag_o,
output reg[31:0] branch_target_address_o,
output reg[31:0] link_addr_o,
output reg is_in_delayslot_o,
output wire stallreq,
output wire[31:0] inst_o,
output wire[31:0] excepttype_o,
output wire[31:0] current_inst_address_o
);
wire[5:0] op_code=inst_i[31:26];
wire[6:0] op_funct=inst_i[5:0];
wire[4:0] op_branch=inst_i[20:16];
reg instvalid;
reg[31:0] imm;

reg excepttype_is_syscall;
reg excepttype_is_eret;
assign excepttype_o={19'b0,excepttype_is_eret,2'b0,instvalid,excepttype_is_syscall,8'b0};
assign current_inst_address_o=pc_i;

reg stallreq_for_reg1_loadrelate;
reg stallreq_for_reg2_loadrelate;
wire pre_inst_is_load;

wire[31:0] pc_plus_8;
wire[31:0] pc_plus_4;
wire[31:0] imm_sll2_signedext;
assign pc_plus_8=pc_i+8;
assign pc_plus_4=pc_i+4;
assign imm_sll2_signedext={{14{inst_i[15]}},inst_i[15:0],2'b00};
assign inst_o=inst_i;
assign pre_inst_is_load=((ex_op_type_i==`Op_Lb)||(ex_op_type_i==`Op_Lbu)||
    (ex_op_type_i==`Op_Lh)||(ex_op_type_i==`Op_Lhu)
    ||(ex_op_type_i==`Op_Lw))?1'b1:1'b0;
    
always @ (*) begin
    stallreq_for_reg1_loadrelate<=`Disable;
    if(rst == `Enable)begin
        data1_o<=`Zero;
    end
    else if(pre_inst_is_load == 1'b1&&ex_waddr_o==data1_addr
    &&re1==1'b1)begin
        stallreq_for_reg1_loadrelate <= `Enable;
    end
end

always @ (*) begin
    stallreq_for_reg2_loadrelate<=`Disable;
    if(rst == `Enable)begin
        data2_o<=`Zero;
    end
    else if(pre_inst_is_load == 1'b1&&ex_waddr_o==data2_addr
    &&re2==1'b1)begin
        stallreq_for_reg2_loadrelate <= `Enable;
    end
end

assign stallreq=stallreq_for_reg2_loadrelate|stallreq_for_reg1_loadrelate;

always @(*)
begin
	if(rst==1'b1)
	begin
		op_type <=`Op_Nop;//define a do-nothing inst
		waddr<=5'b00000;
		wif<=1'b0;
		instvalid<=1'b1;
		re1<=1'b0;
		re2<=1'b0;
		data1_addr<=5'b00000;
		data2_addr<=5'b00000;
		imm<=32'h0;
		link_addr_o<=`Zero;
		branch_target_address_o<=`Zero;
		branch_flag_o<=`Disable;
		next_inst_in_delayslot_o<=`Disable;
	end
	else begin
		op_type <=`Op_Nop;
		waddr<=inst_i[15:11];//rd
		wif<=1'b0;
		instvalid<=1'b1;//enable
		re1<=1'b0;
		re2<=1'b0;
		data1_addr<=inst_i[25:21];//rs
		data2_addr<=inst_i[20:16];//rt
		imm<=`Zero;
		link_addr_o<=`Zero;
		branch_target_address_o<=`Zero;
		branch_flag_o<=`Disable;
		next_inst_in_delayslot_o<=`Disable;
		excepttype_is_eret<=1'b0;
		excepttype_is_syscall<=1'b0;
		instvalid<=1'b0;
		case(op_code)
			6'b001101://ori
			begin
				op_type<=`Op_Ori;
				wif<=1'b1;
				waddr<=inst_i[20:16];
				re1<=1'b1;
				re2<=1'b0;
				imm<={16'h0,inst_i[15:0]};
				instvalid<=1'b1;
			end
			6'b000000://R type inst: (and,nor,or,xor,sllv,add,addu,sub,subu,slt,sltu)
			begin
				case(op_funct)
					6'b000000://sll
					begin
                            op_type<=`Op_Sll;
                            wif<=1'b1;
                            waddr<=inst_i[15:11];
                            re1<=1'b0;
                            re2<=1'b1;
                            imm<={27'h0,inst_i[10:6]};//sa
                            instvalid<=1'b1;
					end
					6'b000010://srl
					begin
						op_type<=`Op_Srl;
						wif<=1'b1;
						waddr<=inst_i[15:11];
						re1<=1'b0;
						re2<=1'b1;
						imm<={27'h0,inst_i[10:6]};//sa
						instvalid<=1'b1;
					end
					6'b000011://sra
					begin
						op_type<=`Op_Sra;
						wif<=1'b1;
						waddr<=inst_i[15:11];
						re1<=1'b0;
						re2<=1'b1;
						imm<={27'h0,inst_i[10:6]};
						instvalid<=1'b1;
					end
					6'b000100://sllv
					begin
						op_type<=`Op_Sllv;
						wif<=1'b1;
						waddr<=inst_i[15:11];
						re1<=1'b1;
						re2<=1'b1;
						instvalid<=1'b1;
					end
					6'b000110://srlv
					begin
						op_type<=`Op_Srlv;
						wif<=1'b1;
						waddr<=inst_i[15:11];
						re1<=1'b1;
						re2<=1'b1;
						instvalid<=1'b1;
					end
					6'b000111://srav
					begin
						op_type<=`Op_Srav;
						wif<=1'b1;
						waddr<=inst_i[15:11];
						re1<=1'b1;
						re2<=1'b1;
						instvalid<=1'b1;
					end
					6'b001000://jr
					begin
					   wif<=1'b0;
					   op_type<=`Op_Jr;
					   re1<=1'b1;
					   re2<=1'b0;
					   link_addr_o<=`Zero;
					   branch_target_address_o<=data1_o;
					   branch_flag_o<=`Enable;
					   next_inst_in_delayslot_o<=1'b1;
					   instvalid<=1'b1;
					end
					6'b001001://jalr
					begin
					   wif<=1'b1;
					   waddr<=inst_i[15:11];
					   op_type<=`Op_Jalr;
					   re1<=1'b1;
					   re2<=1'b0;
					   link_addr_o<=pc_plus_8;
					   branch_target_address_o<=data1_o;
					   branch_flag_o<=`Enable;
					   next_inst_in_delayslot_o<=1'b1;
					   instvalid<=1'b1;
					end
					6'b010000://mfhi
					begin
						op_type<=`Op_Mfhi;
						wif<=1'b1;
						re1<=1'b0;
						re2<=1'b0;
						instvalid<=1'b1;
					end
					6'b010001://mthi
					begin
						op_type<=`Op_Mthi;
						wif<=1'b0;
						re1<=1'b1;
						re2<=1'b0;
						instvalid<=1'b1;
					end
					6'b010010://mflo
					begin
						op_type<=`Op_Mflo;
						wif<=1'b1;
						re1<=1'b0;
						re2<=1'b0;
						instvalid<=1'b1;
					end
					6'b010011://mtlo
					begin
						op_type<=`Op_Mtlo;
						wif<=1'b0;
						re1<=1'b1;
						re2<=1'b0;
						instvalid<=1'b1;
					end
					6'b011000://mult
					begin
						op_type<=`Op_Mult;
						wif<=1'b0;
						re1<=1'b1;
						re2<=1'b1;
						instvalid<=1'b1;
					end
					6'b011001://multu
					begin
						op_type<=`Op_Multu;
						wif<=1'b0;
						re1<=1'b1;
						re2<=1'b1;
						instvalid<=1'b1;
					end
					6'b011010://div
					begin
					   op_type<=`Op_Div;
					   wif<=1'b0;
					   re1<=1'b1;
					   re2<=1'b1;
					   instvalid<=1'b1;
					end
					6'b011011://divu
					begin
					   op_type<=`Op_Divu;
					   wif<=1'b0;
					   re1<=1'b1;
					   re2<=1'b1;
					   instvalid<=1'b1;
					end
					6'b100000://add
					begin
						op_type<=`Op_Add;
						wif<=1'b1;
						re1<=1'b1;
						re2<=1'b1;
						instvalid<=1'b1;
					end
					6'b100001://addu
					begin
						op_type<=`Op_Addu;
						wif<=1'b1;
						re1<=1'b1;
						re2<=1'b1;
						instvalid<=1'b1;
					end
					6'b100010://sub
					begin
						op_type<=`Op_Sub;
						wif<=1'b1;
						re1<=1'b1;
						re2<=1'b1;
						instvalid<=1'b1;
					end
					6'b100011://subu
					begin
						op_type<=`Op_Subu;
						wif<=1'b1;
						re1<=1'b1;
						re2<=1'b1;
						instvalid<=1'b1;
					end
					6'b100100://and
					begin
						op_type<=`Op_And;
						wif<=1'b1;
						re1<=1'b1;
						re2<=1'b1;
						instvalid<=1'b1;
					end
					6'b100111://nor
					begin
						op_type<=`Op_Nor;
						wif<=1'b1;
						re1<=1'b1;
						re2<=1'b1;
						instvalid<=1'b1;
					end
					6'b100101://or
					begin
						op_type<=`Op_Or;
						wif<=1'b1;
						re1<=1'b1;
						re2<=1'b1;
						instvalid<=1'b1;
					end
					6'b100110://xor
					begin
						op_type<=`Op_Xor;
						wif<=1'b1;
						re1<=1'b1;
						re2<=1'b1;
						instvalid<=1'b1;
					end
					6'b101010://slt
					begin
						op_type<=`Op_Slt;
						wif<=1'b1;
						re1<=1'b1;
						re2<=1'b1;
						instvalid<=1'b1;
					end
					6'b101011://sltu
					begin
						op_type<=`Op_Sltu;
						wif<=1'b1;
						re1<=1'b1;
						re2<=1'b1;
						instvalid<=1'b1;
					end
					6'b110100:begin//teq
						op_type<=`Op_Teq;
						wif<=1'b0;
						re1<=1'b1;
						re2<=1'b1;
						instvalid<=1'b1;
					end
					6'b110000:begin//tge
						op_type<=`Op_Tge;
						wif<=1'b0;
						re1<=1'b1;
						re2<=1'b1;
						instvalid<=1'b1;
					end
					6'b110001:begin//tgeu
						op_type<=`Op_Tgeu;
						wif<=1'b0;
						re1<=1'b1;
						re2<=1'b1;
						instvalid<=1'b1;
					end
					6'b110010:begin//tlt
						op_type<=`Op_Tlt;
						wif<=1'b0;
						re1<=1'b1;
						re2<=1'b1;
						instvalid<=1'b1;
					end
					6'b110011:begin//tltu
						op_type<=`Op_Tltu;
						wif<=1'b0;
						re1<=1'b1;
						re2<=1'b1;
						instvalid<=1'b1;
					end
					6'b110110:begin//tne
						op_type<=`Op_Tne;
						wif<=1'b0;
						re1<=1'b1;
						re2<=1'b1;
						instvalid<=1'b1;
					end
					6'b001100:begin//syscall
						op_type<=`Op_Syscall;
						wif<=1'b0;
						re1<=1'b0;
						re2<=1'b0;
						instvalid<=1'b1;
						excepttype_is_syscall<=1'b1;
					end
					default:begin
					end
				endcase
			end
			6'b000001:begin
                case(op_branch)
                    5'b00000://bltz
                    begin
                        wif<=1'b0;
                        op_type<=`Op_Blez;
                        re1<=1'b1;
                        re2<=1'b0;
                        instvalid<=1'b1;
                        if(data1_o[31]==1'b1)begin
                            branch_target_address_o<=pc_plus_4+imm_sll2_signedext;
                            branch_flag_o<=1'b1;
                            next_inst_in_delayslot_o<=1'b1;
                        end
                        else begin
                            branch_target_address_o<=`Zero;
                            branch_flag_o<=1'b0;
                            next_inst_in_delayslot_o<=1'b0;
                        end
                    end
                    5'b00001://bgez
                    begin
                        wif<=1'b0;
                        op_type<=`Op_Bgez;
                        re1<=1'b1;
                        re2<=1'b0;
                        instvalid<=1'b1;
                        if(data1_o[31]==1'b0)begin
                            branch_target_address_o<=pc_plus_4+imm_sll2_signedext;
                            branch_flag_o<=1'b1;
                            next_inst_in_delayslot_o<=1'b1;
                        end
                        else begin
                            branch_target_address_o<=`Zero;
                            branch_flag_o<=1'b0;
                            next_inst_in_delayslot_o<=1'b0;
                        end
                    end
                    5'b10000://bltzal
                    begin
                        wif<=1'b1;
                        op_type<=`Op_Bltzal;
                        re1<=1'b1;
                        re2<=1'b0;
                        waddr<=5'b11111;
                        link_addr_o<=pc_plus_8;
                        instvalid<=1'b1;
                        if(data1_o[31]==1'b1)begin
                            branch_target_address_o<=pc_plus_4+imm_sll2_signedext;
                            branch_flag_o<=1'b1;
                            next_inst_in_delayslot_o<=1'b1;
                        end
                        else begin
                            branch_target_address_o<=`Zero;
                            branch_flag_o<=1'b0;
                            next_inst_in_delayslot_o<=1'b0;
                        end
                    end
                    5'b10001://bgezal
                    begin
                        wif<=1'b1;
                        op_type<=`Op_Bgezal;
                        re1<=1'b1;
                        re2<=1'b0;
                        link_addr_o<=pc_plus_8;
                        waddr<=5'b11111;
                        instvalid<=1'b1;
                        if(data1_o[31]==1'b0)begin
                            branch_target_address_o<=pc_plus_4+imm_sll2_signedext;
                            branch_flag_o<=1'b1;
                            next_inst_in_delayslot_o<=1'b1;
                        end
                        else begin
                            branch_target_address_o<=`Zero;
                            branch_flag_o<=1'b0;
                            next_inst_in_delayslot_o<=1'b0;
                        end
                    end
					5'b01100:begin//teqi
						wif<=1'b0;
						op_type<=`Op_Teqi;
						re1<=1'b1;
						re2<=1'b0;
						imm<={{16{inst_i[15]}},inst_i[15:0]};
						instvalid<=1'b1;
					end
					5'b01000:begin//tgei
						wif<=1'b0;
						op_type<=`Op_Tgei;
						re1<=1'b1;
						re2<=1'b0;
						imm<={{16{inst_i[15]}},inst_i[15:0]};
						instvalid<=1'b1;
					end
					5'b01001:begin//tgeiu
						wif<=1'b0;
						op_type<=`Op_Tgeiu;
						re1<=1'b1;
						re2<=1'b0;
						imm<={{16{inst_i[15]}},inst_i[15:0]};
						instvalid<=1'b1;
					end
					5'b01010:begin//tlti
						wif<=1'b0;
						op_type<=`Op_Tlti;
						re1<=1'b1;
						re2<=1'b0;
						imm<={{16{inst_i[15]}},inst_i[15:0]};
						instvalid<=1'b1;
					end
					5'b01011:begin//tltiu
						wif<=1'b0;
						op_type<=`Op_Tltiu;
						re1<=1'b1;
						re2<=1'b0;
						imm<={{16{inst_i[15]}},inst_i[15:0]};
						instvalid<=1'b1;
					end
					5'b01110:begin//tnei
						wif<=1'b0;
						op_type<=`Op_Tnei;
						re1<=1'b1;
						re2<=1'b0;
						imm<={{16{inst_i[15]}},inst_i[15:0]};
						instvalid<=1'b1;
					end
                    default:begin
                    end
                endcase
			end
			6'b000010://J
			begin
			    wif<=1'b0;
			    op_type<=`Op_J;
			    re1<=1'b0;
			    re2<=1'b0;
			    link_addr_o<=`Zero;
			    branch_flag_o<=1'b1;
			    branch_target_address_o<={pc_plus_4[31:28],inst_i[25:0],2'b00};
			    next_inst_in_delayslot_o<=1'b1;
			    instvalid<=1'b1;
			end
			6'b000011://jal
			begin
			    wif<=1'b1;
			    op_type<=`Op_Jal;
			    re1<=1'b0;
			    re2<=1'b0;
			    waddr<=5'b11111;
			    link_addr_o<=pc_plus_8;
			    branch_flag_o<=1'b1;
			    branch_target_address_o<={pc_plus_4[31:28],inst_i[25:0],2'b00};
			    next_inst_in_delayslot_o<=1'b1;
			    instvalid<=1'b1;
			end
			6'b000100://beq
			begin
                wif<=1'b0;
                op_type<=`Op_Beq;
                re1<=1'b1;
                re2<=1'b1;
                instvalid<=1'b1;
                if(data1_o==data2_o)begin
                    branch_target_address_o<=pc_plus_4+imm_sll2_signedext;
                    branch_flag_o<=1'b1;
                    next_inst_in_delayslot_o<=1'b1;
                end
                else begin
                    branch_target_address_o<=`Zero;
                    branch_flag_o<=1'b0;
                    next_inst_in_delayslot_o<=1'b0;
                end
			end
			6'b000101://bne
			begin
		        wif<=1'b0;
                op_type<=`Op_Bne;
                re1<=1'b1;
                re2<=1'b1;
                instvalid<=1'b1;
                if(data1_o!=data2_o)begin
                    branch_target_address_o<=pc_plus_4+imm_sll2_signedext;
                    branch_flag_o<=1'b1;
                    next_inst_in_delayslot_o<=1'b1;
                end
                else begin
                    branch_target_address_o<=`Zero;
                    branch_flag_o<=1'b0;
                    next_inst_in_delayslot_o<=1'b0;
                end
			end
			6'b000111://bgtz
			begin
			    wif<=1'b0;
                op_type<=`Op_Bgtz;
                re1<=1'b1;
                re2<=1'b0;
                instvalid<=1'b1;
                if((data1_o[31]==1'b0)&&(data1_o!=`Zero))begin
                    branch_target_address_o<=pc_plus_4+imm_sll2_signedext;
                    branch_flag_o<=1'b1;
                    next_inst_in_delayslot_o<=1'b1;
                end
                else begin
                    branch_target_address_o<=`Zero;
                    branch_flag_o<=1'b0;
                    next_inst_in_delayslot_o<=1'b0;
                end
			end
			6'b000110://blez
			begin
			    wif<=1'b0;
                op_type<=`Op_Blez;
                re1<=1'b1;
                re2<=1'b0;
                instvalid<=1'b1;
                if((data1_o[31]==1'b1)||(data1_o==`Zero))begin
                    branch_target_address_o<=pc_plus_4+imm_sll2_signedext;
                    branch_flag_o<=1'b1;
                    next_inst_in_delayslot_o<=1'b1;
                end
                else begin
                    branch_target_address_o<=`Zero;
                    branch_flag_o<=1'b0;
                    next_inst_in_delayslot_o<=1'b0;
                end
			end
			6'b001000://addi
			begin
				op_type<=`Op_Addi;
				wif<=1'b1;
				re1<=1'b1;
				re2<=1'b0;
				waddr<=inst_i[20:16];
				instvalid<=1'b1;
				imm<={{16{inst_i[15]}},inst_i[15:0]};
			end
			6'b001001://addiu
			begin
				op_type<=`Op_Addiu;
				wif<=1'b1;
				re1<=1'b1;
				re2<=1'b0;
				waddr<=inst_i[20:16];
				instvalid<=1'b1;
				imm<={{16{inst_i[15]}},inst_i[15:0]};
			end
			6'b001010://slti
			begin
				op_type<=`Op_Slti;
				wif<=1'b1;
				re1<=1'b1;
				re2<=1'b0;
				waddr<=inst_i[20:16];
				instvalid<=1'b1;
				imm<={{16{inst_i[15]}},inst_i[15:0]};
			end
			6'b001011://sltiu
			begin
				op_type<=`Op_Sltiu;
				wif<=1'b1;
				re1<=1'b1;
				re2<=1'b0;
				waddr<=inst_i[20:16];
				instvalid<=1'b1;
				imm<={{16{inst_i[15]}},inst_i[15:0]};
			end
			6'b001100://andi
			begin
				op_type<=`Op_Andi;
				wif<=1'b1;
				waddr<=inst_i[20:16];
				re1<=1'b1;
				re2<=1'b0;
				imm<={16'h0,inst_i[15:0]};
				instvalid<=1'b1;
			end
			6'b001111://Lui
			begin
				op_type<=`Op_Lui;
				wif<=1'b1;
				waddr<=inst_i[20:16];
				re1<=1'b0;
				re2<=1'b0;
				imm<={inst_i[15:0],16'h0};//sesult
				instvalid<=1'b1;
			end
			6'b001110://xori
			begin
				op_type<=`Op_Xori;
				wif<=1'b1;
				waddr<=inst_i[20:16];
				re1<=1'b1;
				re2<=1'b0;
				imm<={16'h0,inst_i[15:0]};
				instvalid<=1'b1;
			end
			6'b011100://special 2
			begin
				case(op_funct)
				6'b000010://mul
				begin
					op_type<=`Op_Mul;
					re1<=1'b1;
					re2<=1'b1;
					wif<=1'b1;
					waddr<=inst_i[15:11];
					instvalid<=1'b1;
				end
				default:begin
				end
				endcase
			end
			6'b100000://lb
			begin
			    op_type<=`Op_Lb;
			    re1<=1'b1;
			    re2<=1'b0;
			    wif<=1'b1;
			    waddr<=inst_i[20:16];
			    instvalid<=1'b1;
			   
			end
			6'b100100://lbu
			begin
			    op_type<=`Op_Lbu;
			    re1<=1'b1;
			    re2<=1'b0;
			    wif<=1'b1;
			    waddr<=inst_i[20:16];
			    instvalid<=1'b1;
			end
			6'b100001://lh
			begin
			    op_type<=`Op_Lh;
			    re1<=1'b1;
			    re2<=1'b0;
			    wif<=1'b1;
			    waddr<=inst_i[20:16];
			    instvalid<=1'b1;
			end
			6'b100101://lhu
			begin
			    op_type<=`Op_Lhu;
			    re1<=1'b1;
			    re2<=1'b0;
			    wif<=1'b1;
			    waddr<=inst_i[20:16];
			    instvalid<=1'b1;
			end
			6'b100011://lw
			begin
			    op_type<=`Op_Lw;
			    re1<=1'b1;
			    re2<=1'b0;
			    wif<=1'b1;
			    waddr<=inst_i[20:16];
			    instvalid<=1'b1;
			end
			6'b101000://sb
			begin
			    op_type<=`Op_Sb;
			    re1<=1'b1;
			    re2<=1'b1;
			    wif<=1'b0;
			    instvalid<=1'b1;
			end
			6'b101001://sh
			begin
			    op_type<=`Op_Sh;
			    re1<=1'b1;
			    re2<=1'b1;
			    wif<=1'b0;
			    instvalid<=1'b1;
			end
			6'b101011://sw
			begin
			    op_type<=`Op_Sw;
			    re1<=1'b1;
			    re2<=1'b1;
			    wif<=1'b0;
			    instvalid<=1'b1;
			end
			default:
			begin
			end
			
		endcase
	end
	if(inst_i[31:21]==11'b01000000000&&inst_i[10:0]==11'b00000000000)begin
		op_type<=`Op_Mfc0;//move from cp0
		wif<=1'b1;
		waddr<=inst_i[20:16];
		instvalid<=1'b1;
		re1<=1'b0;
		re2<=1'b0;
	end
	else if(inst_i[31:21]==11'b01000000100&&inst_i[10:0]==11'b00000000000)begin
		op_type<=`Op_Mtc0;//move to cp0
		wif<=1'b0;
		re1<=1'b1;
		data1_addr<=inst_i[20:16];
		re2<=1'b0;
		instvalid<=1'b1;
	end
	else if(inst_i==`inst_eret)begin
		wif<=1'b0;
		op_type<=`Op_Eret;
		re1<=1'b0;
		re2<=1'b0;
		instvalid<=1'b1;
		excepttype_is_eret<=1'b1;
	end
end


always @(*)
begin
    if(rst==`Enable)begin
        is_in_delayslot_o<=1'b0;
    end
    else begin
        is_in_delayslot_o<=is_in_delayslot_i;
    end
end

always @(*)
begin
	if(rst==1'b1)begin
		data1_o<=`Zero;
	end
	else if(re1==1'b1&&data1_addr==ex_waddr_o&&ex_wif_o==1'b1)begin
		data1_o<=ex_data_o;
	end
	else if(re1==1'b1&&data1_addr==mem_waddr_o&&mem_wif_o==1'b1)begin
		data1_o<=mem_data_o;
	end
	else if(re1==1'b1)begin
		data1_o<=data1_i;
	end
	else if(re1==1'b0)begin
		data1_o<=imm;
	end
	else begin
		data1_o<=`Zero;
	end
end

always @(*)
begin
	if(rst==1'b1)begin
		data2_o<=`Zero;
	end
	else if(re2==1'b1&&data2_addr==ex_waddr_o&&ex_wif_o==1'b1)begin
		data2_o<=ex_data_o;
	end
	else if(re2==1'b1&&data2_addr==mem_waddr_o&&mem_wif_o==1'b1)begin
		data2_o<=mem_data_o;
	end
	else if(re2==1'b1)begin
		data2_o<=data2_i;
	end
	else if(re2==1'b0)begin
		data2_o<=imm;
	end
	else begin
		data2_o<=`Zero;
	end
end
endmodule 