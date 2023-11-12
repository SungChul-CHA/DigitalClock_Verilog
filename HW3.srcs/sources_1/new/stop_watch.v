`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// stop_watch s_watch_inst (.clk(), .rst(), .en(), .clk_8hz(), .clk_1hz(), .btn_pulse(), .sec0_out(), .sec1_out(), .min0_out(), .min1_out(), .hrs0_out(), .hrs1_out(), .led_out());
// en : 1 -> operate / 0 -> reset
// clk_8hz for led shift, clk_1hz for counting time
// btn[0] : start/stop, btn[1] : reset/lap time
// Maker : CHA 
//
//////////////////////////////////////////////////////////////////////////////////


// To do : 1시간 전까지는 milli sec 보여주다가 59:59:99 지마면 hh:mm:ss 로
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
    
    // clear
    always @ (posedge clk, posedge rst) begin
        if (rst) clear <= rst;
        else if (~en | (~busy & ~lap & reset)) clear <= 1;
        else clear <= 0;
    end
    
    // busy : stop watch counting time
    always @ (posedge clk, posedge clear) begin
        if (clear) busy <= 0;
        else if(~busy & start) busy <= 1;
        else if (busy & start) busy <= 0;
    end
    
    // lap : stop watch counting in background
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
    
    // leds : shift
    always @ (posedge clk, posedge clear) begin
        if (clear) leds <= 8'b11110000;
        else if (busy & clk_8hz) leds <= {leds[0], leds[7:1]};
        else leds <= leds;
    end
    
    // led off when stop wath is not working
    always @ (posedge clk, posedge clear) begin
        if (clear) led_out <= 0;
        else if (busy | lap) led_out <= leds;
    end
    
endmodule
