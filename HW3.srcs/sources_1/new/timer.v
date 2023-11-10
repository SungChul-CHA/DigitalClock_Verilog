`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 
// 
//////////////////////////////////////////////////////////////////////////////////


module timer(
    input clk,
    input rst,
    input en,
    input clk_8hz,
    input clk_1hz,
    input [3:0] btn_pulse,
    input setting,
    output sec0,
    output sec1,
    output min0,
    output min1,
    output hrs0,
    output hrs1,
    output [7:0] leds
    );
    
endmodule
