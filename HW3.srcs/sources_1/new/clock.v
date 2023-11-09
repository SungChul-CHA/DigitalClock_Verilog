`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/11/07 19:58:44
// Design Name: 
// Module Name: clock
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


module clock(
    input clk,
    input rst,
    input en,
    input [5:0] digit,
    input up,
    input down,
    output [3:0] sec0,
    output [3:0] sec1,
    output [3:0] min0,
    output [3:0] min1,
    output [3:0] hrs0,
    output [3:0] hrs1
    );
endmodule
