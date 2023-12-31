`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// clock clock_inst (.clk(), .rst(), .en(), .clk_1hz(), .setting(), .digit(), .up(), .sec0(), .sec1(), .min0(), .min1(), .hrs0(), .hrs1());
// en : 1 -> counting, en : 0 -> hold the time
// setting : 0 -> clock state / 1 -> setting state 
// digit : cursor 
// maker : CHA
// 
//////////////////////////////////////////////////////////////////////////////////


module clock(
    input clk,
    input rst,
    input en,
    input clk_1hz,
    input setting,
    input [5:0] digit,
    input up,
    output reg [3:0] sec0,
    output reg [3:0] sec1,
    output reg [3:0] min0,
    output reg [3:0] min1,
    output reg [3:0] hrs0,
    output reg [3:0] hrs1
    );
    
    wire sec1_en, min0_en, min1_en,
    hrs0_en, hrs1_en;
    
    always @ (posedge clk, posedge rst) begin
        if(rst) sec0 <= 0;
        else if (en & clk_1hz) begin
            if(sec0 == 9) sec0 <= 0;
            else sec0 <= sec0 + 1;
        end
        else if (digit == 6'b100000 & setting) begin
            if (up) begin
                if (sec0 == 9) sec0 <= 0;
                else sec0 <= sec0 + 1;
            end
        end
    end
    
    always @ (posedge clk, posedge rst) begin
        if(rst) sec1 <= 0;
        else if (en & sec1_en) begin
            if(sec1 == 5) sec1 <= 0;
            else sec1 <= sec1 + 1;
        end
        else if (digit == 6'b010000 & setting) begin
            if (up) begin
                if (sec1 == 5) sec1 <= 0;
                else sec1 <= sec1 + 1;
            end
        end
    end
    
    always @ (posedge clk, posedge rst) begin
        if(rst) min0 <= 0;
        else if (en & min0_en) begin
            if (min0 == 9) min0 <= 0;
            else min0 <= min0 + 1;
        end
        else if (digit == 6'b001000 & setting) begin
            if (up) begin
                if (min0 == 9) min0 <= 0;
                else min0 <= min0 + 1;
            end
        end
    end
    
    always @ (posedge clk, posedge rst) begin
        if(rst) min1 <= 0;
        else if (en & min1_en) begin
            if (min1 == 5) min1 <= 0;
            else min1 <= min1 + 1;
        end
        else if (digit == 6'b000100 & setting) begin
            if (up) begin
                if (min1 == 5) min1 <= 0;
                else min1 <= min1 + 1;
            end
        end
    end
    
    always @ (posedge clk, posedge rst) begin
        if(rst) hrs0 <= 0;
        else if (en & hrs0_en) begin
            if (hrs0 == 9 | (hrs1 == 2 & hrs0 == 3)) hrs0 <= 0;
            else hrs0 <= hrs0 + 1;
        end
        else if (digit == 6'b000010 & setting) begin
            if (up) begin
                if (hrs1 != 2 & hrs0 == 9) hrs0 <= 0;
                else if (hrs1 == 2 & hrs0 == 3) hrs0 <= 0;
                else hrs0 <= hrs0 + 1;
            end
        end
    end
    
    always @ (posedge clk, posedge rst) begin
        if(rst) hrs1 <= 0;
        else if (en & hrs1_en) begin
            if (hrs1 == 2) hrs1 <= 0;
            else hrs1 <= hrs1 + 1;
        end
        else if (digit == 6'b000001 & setting) begin
            if (up) begin
                if (hrs1 == 2) hrs1 <= 0;
                else hrs1 <= hrs1 + 1;
            end
        end
    end
    
    assign sec1_en = (sec0 == 9 && clk_1hz) ? 1'b1 : 1'b0;
    assign min0_en = (sec1 == 5 && sec1_en) ? 1'b1 : 1'b0;
    assign min1_en = (min0 == 9 && min0_en) ? 1'b1 : 1'b0;
    assign hrs0_en = (min1 == 5 && min1_en) ? 1'b1 : 1'b0;
    assign hrs1_en = ((hrs0 == 9 | (hrs1 == 2 & hrs0 == 3)) && hrs0_en) ? 1'b1 : 1'b0;
     
endmodule