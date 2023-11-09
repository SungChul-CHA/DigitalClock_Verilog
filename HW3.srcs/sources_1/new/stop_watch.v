`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/11/09 19:21:08
// Design Name: 
// Module Name: stop_watch
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


module stop_watch(
    input clk,
    input rst,
    input en,
    input [3:0] btn_pulse,
    output watch_flag,
    output lap_flag,
    output reg [3:0] sec0,
    output reg [2:0] sec1,
    output reg [3:0] min0,
    output reg [2:0] min1,
    output reg [3:0] hrs0,
    output reg [2:0] hrs1
    );
    
endmodule
