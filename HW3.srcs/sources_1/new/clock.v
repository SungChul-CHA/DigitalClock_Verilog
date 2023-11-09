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
    output reg [3:0] sec0,
    output reg [3:0] sec1,
    output reg [3:0] min0,
    output reg [3:0] min1,
    output reg [3:0] hrs0,
    output reg [3:0] hrs1
    );
    
    wire sec1_en, min0_en, min1_en,
    hrs0_en, hrs1_en, hrs2_rs;
    
    always @ (posedge clk, posedge rst) begin
        if(rst) sec0 <= 0;
        else if (en) begin
            if (sec0 == 9) sec0 <= 0;
            else sec0 <= sec0 + 1;
        end    
    end
    
    always @ (posedge clk, posedge rst) begin
        if(rst) sec1 <= 0;
        else if (sec1_en)
            if(sec1 == 5) sec1 <= 0;
            else sec1 <= sec1 + 1;
    end
    
    always @ (posedge clk, posedge rst) begin
        if(rst) min0 <= 0;
        else if (min0_en)
            if (min0 == 9) min0 <= 0;
            else min0 <= min0 + 1;
    end
    
    always @ (posedge clk, posedge rst) begin
        if(rst) min1 <= 0;
        else if (min1_en)
            if (min1 == 5) min1 <= 0;
            else min1 <= min1 + 1;
    end
    
    always @ (posedge clk, posedge rst) begin
        if(rst) hrs0 <= 0;
        else if (hrs0_en)
            if (hrs0 == 9 | (hrs1 == 2 & hrs0 == 3)) hrs0 <= 0;
            else hrs0 <= hrs0 + 1;
    end
    
    always @ (posedge clk, posedge rst) begin
        if(rst) hrs1 <= 0;
        else if (hrs1_en) begin
            if (hrs1 == 2) hrs1 <= 0;
            else hrs1 <= hrs1 + 1;
        end
    end

    assign sec1_en = (sec0 == 9 && en) ? 1'b1 : 1'b0;
    assign min0_en = (sec1 == 5 && sec1_en) ? 1'b1 : 1'b0;
    assign min1_en = (min0 == 9 && min0_en) ? 1'b1 : 1'b0;
    assign hrs0_en = (min1 == 5 && min1_en) ? 1'b1 : 1'b0;
    assign hrs1_en = ((hrs0 == 9 | (hrs1 == 2 & hrs0 == 3)) && hrs0_en) ? 1'b1 : 1'b0;
    assign hrs2_rs = (hrs1 == 2 & hrs0 == 3 && hrs1_en) ? 1'b1 : 1'b0;  // hrs2_rs °ËÁõ ¾ÈµÊ
     
endmodule
