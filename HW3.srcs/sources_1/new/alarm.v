`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 
// 
//////////////////////////////////////////////////////////////////////////////////


module alarm(
    input clk,
    input rst,
    input en,
    input setting,
    input [5:0] digit,
    input [2:0] btn_pulse,
    input toggle_2hz,
    input [3:0] sec0_in,
    input [3:0] sec1_in,
    input [3:0] min0_in,
    input [3:0] min1_in,
    input [3:0] hrs0_in,
    input [3:0] hrs1_in,
    output reg INT,
    output reg [3:0] sec0,
    output reg [3:0] sec1,
    output reg [3:0] min0,
    output reg [3:0] min1,
    output reg [3:0] hrs0,
    output reg [3:0] hrs1,
    output reg [7:0] led_out
    );
    
    wire up;
    reg busy;
    assign up = btn_pulse[1];
    

    always @ (posedge clk, posedge rst) begin
        if (rst | ~en) led_out <= 0;
        else if (setting) led_out <= 0;
        else if (busy) led_out <= toggle_2hz;
    end
    
    
    
    always @ (posedge clk, posedge rst) begin
        if (rst | ~en) INT <= 0;
        else if (
            sec0_in == sec0 &
            sec1_in == sec1 &
            min0_in == min0 &
            min1_in == min1 &
            hrs0_in == hrs0 &
            hrs1_in == hrs1 & en
        ) INT <= 1;
    end
    
    
    always @(posedge clk, posedge rst) begin
        if (rst | ~en) busy <= 0;
        else if (INT) busy <= 1;
        else if (busy && btn_pulse) busy = 0;
    end
    
    always @ (posedge clk, posedge rst) begin
        if(rst) sec0 <= 0;
        else if (digit == 6'b100000 & setting)
            if (up) begin
                if (sec0 == 9) sec0 <= 0;
                else sec0 <= sec0 + 1;
            end
    end
    
    always @ (posedge clk, posedge rst) begin
        if(rst) sec1 <= 0;
        else if (digit == 6'b010000 & setting)
            if (up) begin
                if (sec1 == 5) sec1 <= 0;
                else sec1 <= sec1 + 1;
            end
    end
    
    always @ (posedge clk, posedge rst) begin
        if(rst) min0 <= 0;
        else if (digit == 6'b001000 & setting)
            if (up) begin
                if (min0 == 9) min0 <= 0;
                else min0 <= min0 + 1;
            end
    end
    
    always @ (posedge clk, posedge rst) begin
        if(rst) min1 <= 0;
        else if (digit == 6'b000100 & setting)
            if (up) begin
                if (min1 == 5) min1 <= 0;
                else min1 <= min1 + 1;
            end
    end
    
    always @ (posedge clk, posedge rst) begin
        if(rst) hrs0 <= 0;
        else if (digit == 6'b000010 & setting)
            if (up) begin
                if (hrs1 != 2 & hrs0 == 9) hrs0 <= 0;
                else if (hrs1 == 2 & hrs0 == 3) hrs0 <= 0;
                else hrs0 <= hrs0 + 1;
            end
    end
    
    always @ (posedge clk, posedge rst) begin
        if(rst) hrs1 <= 0;
        else if (digit == 6'b000001 & setting)
            if (up) begin
                if (hrs1 == 2) hrs1 <= 0;
                else hrs1 <= hrs1 + 1;
            end
    end
    
endmodule
