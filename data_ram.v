`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/05/11 22:53:13
// Design Name: 
// Module Name: data_ram
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module data_ram(
input wire clk,
input wire ce,
input wire we,
input wire[31:0] addr,
input wire[3:0] sel,
input wire[31:0] data_i,
output reg[31:0] data_o
 );
reg[7:0] data_mem0[0:131070];
reg[7:0] data_mem1[0:131070];
reg[7:0] data_mem2[0:131070];
reg[7:0] data_mem3[0:131070];

always @ (posedge clk) 
begin
    if(ce==`Disable)
    begin
        data_o<=`Zero;
    end
    else if(we==`Enable)begin
        if(sel[3]==1'b1)begin
            data_mem3[addr[18:2]]<=data_i[31:24];
        end
        if(sel[2]==1'b1)begin
            data_mem2[addr[18:2]]<=data_i[23:16];
        end
        if(sel[1]==1'b1)begin
            data_mem1[addr[18:2]]<=data_i[15:8];
        end
        if(sel[0]==1'b1)begin
            data_mem0[addr[18:2]]<=data_i[7:0];
        end
    end
end

always @ (*)
begin
    if(ce==`Disable)begin
        data_o<=`Zero;
    end
    else if (we==`Disable)
    begin
        data_o<={data_mem3[addr[18:2]],data_mem2[addr[18:2]],
        data_mem1[addr[18:2]],data_mem0[addr[18:2]]};
    end
    else begin
        data_o<=`Zero;
    end
end
endmodule
