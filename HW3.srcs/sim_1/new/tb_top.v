`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/11/09 11:37:23
// Design Name: 
// Module Name: tb_top
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


module tb_top;
reg clk, reset_poweron;
reg [3:0] btn;
wire [7:0] seg_data;
wire [5:0] seg_com;


always begin
    #5;
    clk = ~clk;
end

initial begin
    reset_poweron = 1;
    clk = 1;
    #12;
    reset_poweron = 0;
end

top dut (clk, reset_poweron, btn, seg_data, seg_com);

endmodule
