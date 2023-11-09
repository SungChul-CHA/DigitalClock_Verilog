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
    input clk_1hz,
    input [3:0] btn_pulse,
    output reg watch_flag,
    output reg lap_flag,
    output reg [3:0] sec0,
    output reg [2:0] sec1,
    output reg [3:0] min0,
    output reg [2:0] min1,
    output reg [3:0] hrs0,
    output reg [2:0] hrs1,
    output reg [7:0] led_out
    );
    
    wire start, reset, return, mode;
    assign {start, reset, return, mode} = btn_pulse;
    
    wire clear;
    assign clear = rst | clear;
    
    wire clk_8hz;
    clk_divider clk_divider_instW (clk, clk_8hz);
    
    reg leds;
    always @ (posedge clk, posedge clear) begin
        if (clear) leds <= 8'b11110000;
        else if (watch_flag) leds <= {leds[0], leds[7:1]};
        else leds <= leds;
    end
    
    
    always @ (*) begin
        if(~watch_flag & start) begin watch_flag = 1; led_en = 1; end
        else if (watch_flag & start) begin watch_flag <= 0; led_en = 0; begin
        else if (~watch_flag & ~lap_flag & reset) reset;
        else if (watch_flag & ~lap_flag & reset) show = 0; lap_flag = 1; 
        else if (lap_flag & reset) lap_flag = 0; show;
        else if (return) n_state = IDLE_ST;
        else if (mode) n_state = n_state;
    end
    
    clock clock_inst (clk, rst, watch_flag, clk_1hz, sec0[0], sec1[0], min0[0], min1[0], hrs0[0], hrs1[0]);
    
endmodule
