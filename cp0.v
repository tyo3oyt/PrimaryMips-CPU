`timescale 1ns / 1ps
`include"My_defines.v"
module cp0(
input wire rst,
input wire clk,
input wire[4:0] raddr_i,
input wire[5:0] int_i,//六个外部硬件中断输入
input wire we_i,
input wire[4:0] waddr_i,
input wire[31:0] wdata_i,

input wire[31:0] excepttype_i,
input wire[31:0] current_inst_address_i,
input wire is_in_delayslot_i,

output reg[31:0] data_o,
output reg[31:0] count_o,
output reg[31:0] compare_o,
output reg[31:0] status_o,
output reg[31:0] cause_o,
output reg[31:0] epc_o,
output reg[31:0] config_o,
output reg[31:0] prid_o,
output reg timer_int_o
);
    
//write
always @ (posedge clk)
begin
    if(rst==`Enable)
    begin
        count_o<=`Zero;
        compare_o<=`Zero;
        status_o<=32'b00010000000000000000000000000000;
        cause_o<=`Zero;
        epc_o<=`Zero;
        config_o<=32'b00000000000000000100000000000000;
        prid_o<=32'b00000000010011000000000100000010;
        timer_int_o<=`Disable;
    end
    else begin
        count_o<=count_o+1;
        cause_o[15:10]<=int_i;
        if(compare_o!=`Zero&&count_o==compare_o)//定时中断
        begin
            timer_int_o<=`Enable;
        end
        if(we_i==`Enable)
        begin
            case(waddr_i)
                `cp0_count:
                begin
                    count_o<=wdata_i;
                end
                `cp0_compare:
                begin
                    compare_o<=wdata_i;
                    timer_int_o<=`Disable;
                end
                `cp0_status:
                begin
                    status_o<=wdata_i;
                end
                `cp0_epc:
                begin
                    epc_o<=wdata_i;
                end
                `cp0_cause:
                begin
                    //cause 寄存器只有IP[1:0]、IV、WP字段是可写的
                    cause_o[9:8]<=wdata_i[9:8];
                    cause_o[23]<=wdata_i[23];
                    cause_o[22]<=wdata_i[22];
                end
            default:begin
            end
            endcase
        end
        case(excepttype_i)
        32'h00000001:begin
            if(is_in_delayslot_i==1'b1)begin
                epc_o<=current_inst_address_i-4'h4;
                cause_o[31]<=1'b1;// BD,Branch Delayslot
            end
            else begin
                epc_o<=current_inst_address_i;
                cause_o[31]<=1'b0;
            end
            status_o[1]<=1'b1;//exl
            cause_o[6:2]<=5'b00000;
        end
        32'h00000008:begin
            if(status_o[1]==1'b0)begin
                if(is_in_delayslot_i==1'b1)begin
                    epc_o<=current_inst_address_i-4'h4;
                    cause_o[31]<=1'b1;// BD,Branch Delayslot
                end
                else begin
                    epc_o<=current_inst_address_i;
                    cause_o[31]<=1'b0;
                end
            end
            status_o[1]<=1'b1;
            cause_o[6:2]<=5'b01000;
        end
        32'h0000000a:begin
            if(status_o[1]==1'b0)begin
                if(is_in_delayslot_i==1'b1)begin
                    epc_o<=current_inst_address_i-4'h4;
                    cause_o[31]<=1'b1;// BD,Branch Delayslot
                end
                else begin
                    epc_o<=current_inst_address_i;
                    cause_o[31]<=1'b0;
                end
            end
            status_o[1]<=1'b1;
            cause_o[6:2]<=5'b01010;
        end
        32'h0000000d:begin
            if(status_o[1]==1'b0)begin
                if(is_in_delayslot_i==1'b1)begin
                    epc_o<=current_inst_address_i-4'h4;
                    cause_o[31]<=1'b1;// BD,Branch Delayslot
                end
                else begin
                    epc_o<=current_inst_address_i;
                    cause_o[31]<=1'b0;
                end
            end
            status_o[1]<=1'b1;
            cause_o[6:2]<=5'b01101;
        end
        32'h0000000c:begin
            if(status_o[1]==1'b0)begin
                if(is_in_delayslot_i==1'b1)begin
                    epc_o<=current_inst_address_i-4'h4;
                    cause_o[31]<=1'b1;// BD,Branch Delayslot
                end
                else begin
                    epc_o<=current_inst_address_i;
                    cause_o[31]<=1'b0;
                end
            end
            status_o[1]<=1'b1;
            cause_o[6:2]<=5'b01100;
        end
        32'h0000000e:begin
            status_o[1]<=1'b0;
        end
        default:begin
        end
        endcase
    end
end

//read reg
always @ (*)
begin
    if(rst==`Enable)
    begin
        data_o<=`Zero;
    end
    else begin
        case(raddr_i)
            `cp0_count:
            begin
                data_o<=count_o;
            end
            `cp0_compare:
            begin
                data_o<=compare_o;
            end
            `cp0_status:
            begin
                data_o<=status_o;
            end
            `cp0_cause:
            begin
                data_o<=cause_o;
            end
            `cp0_epc:
            begin
                data_o<=epc_o;
            end
            `cp0_prid:
            begin
                data_o<=prid_o;
            end
            `cp0_config:
            begin
                data_o<=config_o;
            end
        default:begin
        end
        endcase
    end
end
endmodule
