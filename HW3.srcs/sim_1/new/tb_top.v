`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/11/10 12:02:06
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
reg clk = 1, reset_poweron;
reg [3:0] btn;
wire [7:0] seg_data, leds;
wire [5:0] seg_com;

always begin
    #5;
    clk = ~clk;
end

initial begin
    reset_poweron = 1;
    btn = 0;
    #8;
    reset_poweron = 0;
    btn[3] = 0;
    #500000;
    btn[3] = 1;
    #600000;
    btn[3] = 0;
    #60000;
    btn[2] = 1;
    #600000;
    $stop;


end



top dut (clk, reset_poweron, btn, seg_data, seg_com, leds);
endmodule
