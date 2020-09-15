`include"My_defines.v"
module ex(
input wire rst,
input wire[6:0] op_type_i,
input wire[31:0] data1_i,
input wire[31:0] data2_i,
input wire wif_ex_i,
input wire[4:0] waddr_ex_i,

input wire[31:0] hi_i,
input wire[31:0] lo_i,

input wire[31:0] mem_hi_i,
input wire[31:0] mem_lo_i,
input wire mem_whilo_i,

input wire[31:0] wb_hi_i,
input wire[31:0] wb_lo_i,
input wire wb_whilo_i,

input wire[63:0] div_result_i,
input wire div_ready_i,

input wire[31:0] link_address_i,
input wire is_in_delayslot_i,

input wire[31:0] inst_i,

input wire mem_cp0_reg_we,
input wire[4:0] mem_cp0_reg_waddr,
input wire[31:0] mem_cp0_reg_data,

input wire wb_cp0_reg_we,
input wire[4:0] wb_cp0_reg_waddr,
input wire[31:0] wb_cp0_reg_data,

input wire[31:0] cp0_reg_rdata_i,
input wire[31:0] excepttype_i,
input wire[31:0] current_inst_addr_i,

output reg[4:0] cp0_reg_addr_o,

output reg cp0_reg_we_o,
output reg[4:0] cp0_reg_waddr_o,
output reg[31:0] cp0_reg_data_o,

output reg[31:0] hi_o,
output reg[31:0] lo_o,
output reg whilo_o,

output reg[31:0] result,
output reg wif_ex_o,
output reg[4:0] waddr_ex_o,

output reg[31:0] div_opdata1_o,//divisor
output reg[31:0] div_opdata2_o,//dividend
output reg div_signed_o,
output reg div_start_o,
output reg stallreq,
output wire[6:0] op_type_o,
output wire[31:0] mem_addr_o,
output wire[31:0] reg2_o,
output wire[31:0] excepttype_o,
output wire[31:0] current_inst_addr_o,
output wire is_in_delayslot_o
);
wire[2:0] aluop = op_type_i[6:4];
wire[3:0] aluop_sel = op_type_i[3:0];

reg[31:0] HI;
reg[31:0] LO;
reg[31:0] logicout;
reg[31:0] shiftres;
reg[31:0] moveres;
reg[31:0] arithmeticres;
reg[63:0] mulres;
reg stallreq_for_div;

wire ov_sum;//overflow
wire data1_eq_data2;
wire data1_lt_data2;
wire[31:0] data2_mux;
wire[31:0] data1_not;
wire[31:0] result_sum;
wire[31:0] opdata1_mult;
wire[31:0] opdata2_mult;
wire[63:0] hilo_temp;

reg trapassert;
reg ovassert;

assign excepttype_o={excepttype_i[31:12],ovassert,trapassert,excepttype_i[9:8],8'h00};
assign is_in_delayslot_o=is_in_delayslot_i;
assign current_inst_addr_o=current_inst_addr_i;

assign data2_mux=(op_type_i==`Op_Sub||
	op_type_i==`Op_Subu||
	op_type_i==`Op_Slt||
	op_type_i==`Op_Slti||
	op_type_i==`Op_Tlt||
	op_type_i==`Op_Tlti||
	op_type_i==`Op_Tge||
	op_type_i==`Op_Tgei)? (~data2_i+1):data2_i;
	
assign result_sum = data1_i+data2_mux;

assign ov_sum =((!data1_i[31]&&!data2_mux[31])&&result_sum[31])||
	((data1_i[31]&&data2_mux[31])&&!result[31]);

assign data1_lt_data2=(op_type_i==`Op_Slt||op_type_i==`Op_Slti||op_type_i==`Op_Tlt||op_type_i==`Op_Tlti||op_type_i==`Op_Tge||op_type_i==`Op_Tgei)?
	((data1_i[31]&&!data2_i[31])||
	((!data1_i[31]&&!data2_i[31])&&result_sum[31])||(
	(data1_i[31]&&data2_i[31])&&result_sum)):(data1_i<data2_i);
//data1是否小于data2

assign data1_not = ~data1_i;

assign op_type_o=op_type_i;
assign mem_addr_o=data1_i+{{16{inst_i[15]}},inst_i[15:0]};// store address
assign reg2_o=data2_i;

always @(*)begin
	if(rst==1'b1)begin
		trapassert<=1'b0;
	end
	else begin
		trapassert<=1'b0;
		case(op_type_i)
			`Op_Teq,`Op_Teqi:begin
				if(data1_i==data2_i)begin
					trapassert<=1'b1;
				end
			end
			`Op_Tge,`Op_Tgei,`Op_Tgeiu,`Op_Tgeu:begin
				if(data1_lt_data2==1'b0)begin
					trapassert<=1'b1;
				end
			end
			`Op_Tlt,`Op_Tlti,`Op_Tltu,`Op_Tltiu:begin
				if(data1_lt_data2==1'b1)begin
					trapassert<=1'b1;
				end
			end
			`Op_Tne,`Op_Tnei:begin
				if(data1_i!=data2_i)begin
					trapassert<=1'b1;
				end
			end
			default:begin
				trapassert<=1'b0;
			end
		endcase
	end
end

always @(*)
begin
	if(rst==1'b1)
	begin
		HI<=32'b0;
		LO<=32'b0;
	end
	else if(mem_whilo_i==1'b1)
	begin
		HI<=mem_hi_i;
		LO<=mem_lo_i;
	end
	else if(wb_whilo_i==1'b1)
	begin
		HI<=wb_hi_i;
		LO<=wb_lo_i;
	end
	else begin
		HI<=hi_i;
		LO<=lo_i;
	end
end
//to earn the latest value of hi and lo

always @(*)
begin
    wif_ex_o<=wif_ex_i;
	waddr_ex_o<=waddr_ex_i;
	if(rst==1'b1)
	begin
		logicout<=32'h00000000;
	end
	else 
	begin
        case(op_type_i)
        `Op_And,`Op_Andi: //and,andi
        begin
            logicout<=data1_i&data2_i;
        end
        `Op_Lui: //lui
        begin
            logicout<=data1_i;
        end
        `Op_Nor://nor
        begin
            logicout<=~(data1_i|data2_i);
        end
        `Op_Or,`Op_Ori://or,ori
        begin
            logicout<=data1_i|data2_i;
        end
        `Op_Xor,`Op_Xori://xor,xori
        begin
            logicout<=data1_i^data2_i;
        end
        default:begin
        end
        endcase
	end
end

always @(*)
begin
    if(rst==`Enable)begin
        stallreq_for_div<=1'b0;
        div_opdata1_o<=`Zero;
        div_opdata2_o<=`Zero;
        div_signed_o<=1'b0;
    end
    else begin
        stallreq_for_div<=1'b0;
        div_opdata1_o<=`Zero;
        div_opdata2_o<=`Zero;
        div_signed_o<=1'b0;
        case(op_type_i)
            `Op_Div:
            if(div_ready_i==1'b0)begin
                div_opdata1_o<=data1_i;
                div_opdata2_o<=data2_i;
                div_signed_o<=1'b1;
                div_start_o<=`DivStart;
                stallreq_for_div<=1'b1;
            end
            else if(div_ready_i==1'b1)begin
                div_opdata1_o<=data1_i;
                div_opdata2_o<=data2_i;
                div_signed_o<=1'b1;
                div_start_o<=`DivStop;
                stallreq_for_div<=1'b0;
            end
            else begin
                div_opdata1_o<=`Zero;
                div_opdata2_o<=`Zero;
                div_signed_o<=1'b0;
                div_start_o<=`DivStop;
                stallreq_for_div<=1'b0;
            end
            
            `Op_Divu:
            if(div_ready_i==1'b0)begin
                div_opdata1_o<=data1_i;
                div_opdata2_o<=data2_i;
                div_signed_o<=1'b0;
                div_start_o<=`DivStart;
                stallreq_for_div<=1'b1;
            end
            else if(div_ready_i==1'b1)begin
                div_opdata1_o<=data1_i;
                div_opdata2_o<=data2_i;
                div_signed_o<=1'b0;
                div_start_o<=`DivStop;
                stallreq_for_div<=1'b0;
            end
            else begin
                div_opdata1_o<=`Zero;
                div_opdata2_o<=`Zero;
                div_signed_o<=1'b0;
                div_start_o<=`DivStop;
                stallreq_for_div<=1'b0;
            end
        
        default:begin
        end
        endcase
    end
end

always @(*)begin
    stallreq<=stallreq_for_div;
end

always @ (*)
begin
	if(rst==1'b1)
	begin
		shiftres<=32'h00000000;
	end
	else
	begin
		case(op_type_i)
		`Op_Sllv,`Op_Sll://sllv.sll
        begin
            shiftres<=data2_i<<data1_i;
        end
        `Op_Srav,`Op_Sra://srav,sra
        begin
            shiftres<= ({{31{data2_i[31]}},1'b0}<<(~data1_i[4:0]) )|( data2_i >> data1_i[4:0]);
        end
        `Op_Srlv,`Op_Srl://srlv,srl
        begin
            shiftres<=data2_i>>data1_i;
        end
		default:begin
		end
		endcase
	end
end

always @ (*)
begin
	if(rst==1'b1)begin
		arithmeticres<=32'h00000000;
	end
	else begin
		case(op_type_i)
		`Op_Add,`Op_Addi,`Op_Addiu,`Op_Addu:
		begin
			arithmeticres<=result_sum;
		end
		`Op_Sub,`Op_Subu:
		begin
			arithmeticres<=result_sum;
		end
		`Op_Slt,`Op_Slti,`Op_Sltu,`Op_Sltiu:
		begin
			arithmeticres<=data1_lt_data2;
		end
		default:begin
		    arithmeticres<=`Zero;
		end
		endcase
	end
end

always @ (*)
begin	
	if(rst==1'b1)
	begin
		moveres<=32'h00000000;
	end
	else
	begin
		case(op_type_i)
		`Op_Mfhi://mfhi
		begin
			moveres<=HI;
		end
	   `Op_Mflo://mflo
		begin
		   moveres<=LO;
		end
		`Op_Mfc0:
		begin
			cp0_reg_addr_o<=inst_i[15:11];
			moveres<=cp0_reg_rdata_i; 
			if(mem_cp0_reg_we==1'b1&&mem_cp0_reg_waddr==inst_i[15:11])begin
				moveres<=mem_cp0_reg_data;
			end
			else if(wb_cp0_reg_we==1'b1&&wb_cp0_reg_waddr==inst_i[15:11])begin
				moveres<=wb_cp0_reg_data;
			end
		end
		default:begin
		end
		endcase
	end
end

assign opdata1_mult=((op_type_i==`Op_Mul||
	op_type_i==`Op_Mult)&&data1_i[31])?(~data1_i+1):data1_i;
assign opdata2_mult=((op_type_i==`Op_Mul||
	op_type_i==`Op_Mult)&&data2_i[31])?(~data2_i+1):data2_i;
assign hilo_temp = opdata1_mult*opdata2_mult;

always @ (*)
begin
	if(rst==1'b1)
	begin
		mulres<=64'h00000000;
	end
	else if(op_type_i==`Op_Mul||op_type_i==`Op_Mult)
	begin
		if(data1_i[31]^data2_i[31]==1'b1)begin
		  mulres<=~hilo_temp+1;
		end
		else begin
		  mulres<=hilo_temp;
		end
	end
	else begin
	   mulres<=hilo_temp;
	end
end

always @ (*)
begin
	wif_ex_o<=wif_ex_i;
	waddr_ex_o<=waddr_ex_i;
	if((op_type_i==`Op_Add||op_type_i==`Op_Addi||op_type_i==`Op_Sub)
	&&ov_sum==1'b1)begin
	   wif_ex_o<=1'b0;
	   ovassert<=1'b1;
	end
	else begin
       wif_ex_o<=wif_ex_i;
	   ovassert<=1'b0;
	end
    case(aluop)
    3'b001://logic
    begin
        result<=logicout;
    end
    3'b010://shiftres
    begin
        result<=shiftres;
    end
    3'b100,3'b111://moveres
    begin
        result<=moveres;
    end
    3'b011:
    begin
        result<=link_address_i;
    end
    3'b000://mul 
    begin
        if(op_type_i==`Op_Mul)result<=mulres[31:0];
        else begin
        result<=arithmeticres;
        end
    end
    default:begin
        result<=32'h00000000;
    end
    endcase
end

always @ (*)
begin
	if(rst==1'b1)
	begin
		whilo_o<=1'b0;
		hi_o<=32'b0;
		lo_o<=32'b0;
	end
	else if(op_type_i==`Op_Div||op_type_i==`Op_Div)begin
	   whilo_o<=1'b1;
	   hi_o<=div_result_i[63:32];
	   lo_o<=div_result_i[31:0];
	end
	else if(op_type_i==`Op_Mult||op_type_i==`Op_Multu)
	begin
	   whilo_o<=1'b1;
	   hi_o<=mulres[63:32];
	   lo_o<=mulres[31:0];
	end
	else if(op_type_i==`Op_Mthi)
	begin
		whilo_o<=1'b1;
		hi_o<=data1_i;
		lo_o<=LO;
	end
	else if(op_type_i==`Op_Mtlo)
	begin
		whilo_o<=1'b1;
		hi_o<=HI;
		lo_o<=data1_i;
	end
	else begin
		whilo_o<=1'b0;
		hi_o<=32'b0;
		lo_o<=32'b0;
	end
end

always @(*)begin
	if(rst==`Enable)begin
		cp0_reg_waddr_o<=5'b00000;
		cp0_reg_we_o<=1'b0;
		cp0_reg_data_o<=`Zero;
	end
	else if(op_type_i==`Op_Mtc0)begin
		cp0_reg_waddr_o<=inst_i[15:11];
		cp0_reg_we_o<=1'b1;
		cp0_reg_data_o<=data1_i;
	end
	else begin
		cp0_reg_waddr_o<=5'b00000;
		cp0_reg_we_o<=1'b0;
		cp0_reg_data_o<=`Zero;
	end
end
endmodule 