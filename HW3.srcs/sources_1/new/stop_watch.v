`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// stop_watch s_watch_inst (.clk(), .rst(), .en(), .clk_8hz(), .clk_1hz(), .btn_pulse(), .sec0_out(), .sec1_out(), .min0_out(), .min1_out(), .hrs0_out(), .hrs1_out(), .led_out());
// en : 1 -> operate / 0 -> reset
// clk_8hz for led shift, clk_1hz for counting time
// btn[0] : start/stop, btn[1] : reset/lap time
// Maker : CHA 
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
    
    reg [3:0] sec0, min0, hrs0;
    reg [3:0] sec1, min1, hrs1;
    wire [3:0] sec0_b, min0_b, hrs0_b;
    wire [3:0] sec1_b, min1_b, hrs1_b;
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
    
    
    // small time stop watch
    wire clk_100hz;
    gen_counter_en #(.SIZE(60000)) gen_clock_en_inst1 (clk, clear, clk_100hz);
    
    wire sec1_en, min0_en, min1_en,
    hrs0_en, hrs1_en;
    reg hrs2_ed;
    
    always @ (posedge clk, posedge clear) begin
        if(clear) sec0 <= 0;
        else if (busy & clk_100hz & ~hrs2_ed) begin
            if(sec0 == 9) sec0 <= 0;
            else sec0 <= sec0 + 1;
        end
    end
    
    always @ (posedge clk, posedge clear) begin
        if(clear) sec1 <= 0;
        else if (busy & sec1_en) begin
            if(sec1 == 9) sec1 <= 0;
            else sec1 <= sec1 + 1;
        end
    end
    
    always @ (posedge clk, posedge clear) begin
        if(clear) min0 <= 0;
        else if (busy & min0_en) begin
            if (min0 == 9) min0 <= 0;
            else min0 <= min0 + 1;
        end
    end
    
    always @ (posedge clk, posedge clear) begin
        if(clear) min1 <= 0;
        else if (busy & min1_en) begin
            if (min1 == 5) min1 <= 0;
            else min1 <= min1 + 1;
        end
    end
    
    always @ (posedge clk, posedge clear) begin
        if(clear) hrs0 <= 0;
        else if (busy & hrs0_en) begin
            if (hrs0 == 9) hrs0 <= 0;
            else hrs0 <= hrs0 + 1;
        end
    end
    
    always @ (posedge clk, posedge clear) begin
        if(clear) hrs1 <= 0;
        else if (busy & hrs1_en) begin
            if (hrs1 == 5) hrs1 <= 0;
            else hrs1 <= hrs1 + 1;
        end
    end
    
    assign sec1_en = (sec0 == 9 && clk_100hz) ? 1'b1 : 1'b0;
    assign min0_en = (sec1 == 9 && sec1_en) ? 1'b1 : 1'b0;
    assign min1_en = (min0 == 9 && min0_en) ? 1'b1 : 1'b0;
    assign hrs0_en = (min1 == 5 && min1_en) ? 1'b1 : 1'b0;
    assign hrs1_en = (hrs0 == 9 && hrs0_en) ? 1'b1 : 1'b0;
    
    always @ (posedge clk, posedge clear) begin
        if (clear) hrs2_ed <= 0;
        else if (hrs1 == 6) hrs2_ed <= 1;
    end
    
    // big time stopwatch
    clock clock_inst_s1 (clk, clear, busy, clk_1hz, , , , sec0_b, sec1_b, min0_b, min1_b, hrs0_b, hrs1_b);
    
    
    assign sec0_out = (lap) ? sec0_out: 
                    (~hrs2_ed) ? sec0 : sec0_b;
    assign sec1_out = (lap) ? sec1_out: 
                    (~hrs2_ed) ? sec1 : sec1_b;
    assign min0_out = (lap) ? min0_out: 
                    (~hrs2_ed) ? min0 : min0_b;
    assign min1_out = (lap) ? min1_out: 
                    (~hrs2_ed) ? min1 : min1_b;
    assign hrs0_out = (lap) ? hrs0_out: 
                    (~hrs2_ed) ? hrs0 : hrs0_b;
    assign hrs1_out = (lap) ? hrs1_out: 
                    (~hrs2_ed) ? hrs1 : hrs1_b;
    
    
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
