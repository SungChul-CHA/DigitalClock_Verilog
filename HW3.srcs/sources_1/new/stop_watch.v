`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 
// 
//////////////////////////////////////////////////////////////////////////////////


module stop_watch(
    input clk,
    input rst,
    input en,
    input clk_8hz,
    input clk_1hz,
    input [1:0] btn_pulse,
    output [3:0] sec0_out,
    output [3:0] sec1_out,
    output [3:0] min0_out,
    output [3:0] min1_out,
    output [3:0] hrs0_out,
    output [3:0] hrs1_out,
    output reg [7:0] led_out
    );
    
    wire [3:0] sec0, min0, hrs0;
    wire [3:0] sec1, min1, hrs1;
    reg busy, lap;
    reg clear;
    reg [7:0] leds;
    
    wire start, reset;
    assign {reset, start} = btn_pulse;
    
    
    always @ (posedge clk, posedge rst) begin
        if (rst) clear <= rst;
        else if (~en | (~busy & ~lap & reset)) clear <= 1;
        else clear <= 0;
    end
    
    always @ (posedge clk, posedge clear) begin
        if (clear) busy <= 0;
        else if(~busy & start) busy <= 1;
        else if (busy & start) busy <= 0;
    end
    
    always @ (posedge clk, posedge clear) begin
        if (clear) lap <= 0;
        else if (busy & ~lap & reset) lap <= 1;
        else if (lap & reset) lap <= 0;
    end
    
    clock clock_inst_s (clk, clear, busy, clk_1hz, , , , sec0, sec1, min0, min1, hrs0, hrs1);
    
    assign sec0_out = (lap) ? sec0_out: sec0;
    assign sec1_out = (lap) ? sec1_out: sec1;
    assign min0_out = (lap) ? min0_out: min0;
    assign min1_out = (lap) ? min1_out: min1;
    assign hrs0_out = (lap) ? hrs0_out: hrs0;
    assign hrs1_out = (lap) ? hrs1_out: hrs1;
    
    always @ (posedge clk_8hz, posedge clear) begin
        if (clear) leds <= 8'b11110000;
        else if (busy & clk_8hz) leds <= {leds[0], leds[7:1]};
        else leds <= leds;
    end
    
    always @ (posedge clk, posedge clear) begin
        if (clear) led_out <= 0;
        else if (busy | lap) led_out <= leds;
        else led_out <= 0;
    end
    
endmodule
