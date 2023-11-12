`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// timer timer_inst (.clk(), .rst(), .en(), .clk_8hz(), .clk_1hz(), .setting(), .digit(), .btn_pulse(), .toggle(), .sec0(), .sec1(), .min0(), .min1(), .hrs0(), .hrs1(), .led_out());
// en : 1 -> counting / 0 -> reset
// clk_8hz for led shift, clk_1hz for time count, toggle : 2hz toggle signal for led blink
// setting 0 -> count. setting 1 -> setting state
// setting 0 -> btn_pulse[0] : start/stop, btn_pulse[1] : reset
// setting 1 -> btn_pulse[0] : cursor left, btn_pulse[1] : increase time
// Maker : CHA
// 
//////////////////////////////////////////////////////////////////////////////////


// To do : t_INT ¹ÛÀ¸·Î »©°í INT ¶ß¸é ½Ã°èµµ ±ôºıÀÌ°Ô 
module timer(
    input clk,
    input rst,
    input en,
    input clk_8hz,
    input clk_1hz,
    input setting,
    input [5:0] digit,
    input [2:0] btn_pulse,
    input toggle,  
    output reg [3:0] sec0,
    output reg [3:0] sec1,
    output reg [3:0] min0,
    output reg [3:0] min1,
    output reg [3:0] hrs0,
    output reg [3:0] hrs1,
    output reg [7:0] led_out
    );
    
    wire start, up_reset;
    reg busy, clear, t_INT;
    reg [7:0] leds;
    wire sec1_en, min0_en, min1_en,
    hrs0_en, hrs1_en;
    wire hrs1_ed, hrs0_ed, min1_ed, min0_ed, sec1_ed, isFinish;
    
    // btn
    assign start = btn_pulse[0];
    assign up_reset = btn_pulse[1];
    
    // clear
    always @ (posedge clk, posedge rst) begin
        if (rst) clear <= 1;
        else if (~en | (up_reset & ~setting)) clear <= 1;
        else clear <= 0;
    end
    
    // Timer Inturrupt
    always @ (posedge clk, posedge clear) begin
        if (clear) t_INT <= 0;
        else if (t_INT && btn_pulse) t_INT <= 0;
        else if (isFinish & busy) t_INT <= 1;
    end
    
    // ÇöÀç ½Ã°£ÀÌ 00:00:00ÀÌ ¾Æ´Ï°í timer °¡ ¸ØÃçÀÖÀ» ¶§ start ´©¸£¸é 1
    // timer µ¿ÀÛ Áß start ´©¸£¸é 0, setting ¶ß¸é 0
    always @ (posedge clk, posedge clear) begin
        if (clear) busy <= 0;
        else if(~busy & start & ~setting & ~isFinish) busy <= 1;
        else if ((busy & start) | setting) busy <= 0;
    end
    
    // led toggle when timer finish
    always @ (posedge clk, posedge clear) begin
        if (clear) leds <= 8'b11110000;
        else if (t_INT) leds <= {8{toggle}};
        else if (busy & clk_8hz) leds <= {leds[0], leds[7:1]};
        else leds <= leds;
    end

    always @ (posedge clk, posedge clear) begin
        if (clear) led_out <= 8'b11110000;
        else if (setting) led_out <= 0;
        else led_out <= leds;
    end
    
    // busy°¡ ¶ß¸é down counter, settingÀÌ ¶ß¸é 1 up
    always @ (posedge clk, posedge clear) begin
        if(clear) sec0 <= 0;
        else if (busy & clk_1hz & ~isFinish)
            if(sec0 == 0) sec0 <= 9;
            else sec0 <= sec0 - 1;
        else if (digit == 6'b100000 & setting)
            if (up_reset) begin
                if (sec0 == 9) sec0 <= 0;
                else sec0 <= sec0 + 1;
            end
    end
    
    always @ (posedge clk, posedge clear) begin
        if(clear) sec1 <= 0;
        else if (busy & sec1_en & ~isFinish)
            if(sec1 == 0) sec1 <= 5;
            else sec1 <= sec1 - 1;
        else if (digit == 6'b010000 & setting)
            if (up_reset) begin
                if (sec1 == 5) sec1 <= 0;
                else sec1 <= sec1 + 1;
            end
    end
    
    always @ (posedge clk, posedge clear) begin
        if(clear) min0 <= 0;
        else if (busy & min0_en & ~isFinish)
            if (min0 == 0) min0 <= 9;
            else min0 <= min0 - 1;
        else if (digit == 6'b001000 & setting)
            if (up_reset) begin
                if (min0 == 9) min0 <= 0;
                else min0 <= min0 + 1;
            end
    end
    
    always @ (posedge clk, posedge clear) begin
        if(clear) min1 <= 0;
        else if (busy & min1_en & ~isFinish)
            if (min1 == 0) min1 <= 5;
            else min1 <= min1 - 1;
        else if (digit == 6'b000100 & setting)
            if (up_reset) begin
                if (min1 == 5) min1 <= 0;
                else min1 <= min1 + 1;
            end
    end
    
    always @ (posedge clk, posedge clear) begin
        if(clear) hrs0 <= 0;
        else if (busy & hrs0_en & ~isFinish)
            if (hrs0 == 0) hrs0 <= 9;
            else hrs0 <= hrs0 - 1;
        else if (digit == 6'b000010 & setting)
            if (up_reset) begin
                if (hrs0 == 9) hrs0 <= 0;
                else hrs0 <= hrs0 + 1;
            end
    end
    
    always @ (posedge clk, posedge clear) begin
        if(clear) hrs1 <= 0;
        else if (busy & hrs1_en & ~isFinish) begin
            if (hrs1 == 0) hrs1 <= 0;
            else hrs1 <= hrs1 - 1;
        end
        else if (digit == 6'b000001 & setting)
            if (up_reset) begin
                if (hrs1 == 9) hrs1 <= 0;
                else hrs1 <= hrs1 + 1;
            end
    end
    
    assign sec1_en = (sec0 == 0 && clk_1hz) ? 1'b1 : 1'b0;
    assign min0_en = (sec1 == 0 && sec1_en) ? 1'b1 : 1'b0;
    assign min1_en = (min0 == 0 && min0_en) ? 1'b1 : 1'b0;
    assign hrs0_en = (min1 == 0 && min1_en) ? 1'b1 : 1'b0;
    assign hrs1_en = (hrs0 == 0 && hrs0_en) ? 1'b1 : 1'b0;  
    
    assign hrs1_ed = (hrs1 == 0) ? 1'b1 : 1'b0;
    assign hrs0_ed = (hrs0 == 0 & hrs1_ed) ? 1'b1 : 1'b0;
    assign min1_ed = (min1 == 0 & hrs0_ed) ? 1'b1 : 1'b0;
    assign min0_ed = (min0 == 0 & min1_ed) ? 1'b1 : 1'b0;
    assign sec1_ed = (sec1 == 0 & min0_ed) ? 1'b1 : 1'b0;
    assign isFinish = (sec0 == 0 & sec1_ed) ? 1'b1 : 1'b0;
    
endmodule
