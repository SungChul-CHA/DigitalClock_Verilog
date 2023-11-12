`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// alarm alarm_inst (.clk(), .rst(), .setting(), .digit(), .btn_1s(), .btn_pulse(), .toggle_2hz(), .sec0_in(), .sec1_in(), .min0_in(), .min1_in(), .hrs0_in(), .hrs1_in(), .a_INT(), .isOn(), .sec0(), .sec1(), .min0(), .min1(), .hrs0(), .hrs1(), .led_out());
// setting 1 -> setting state / 0 -> alarm display
// btn_1s : alarm set / unset, btn_pulse : alarm off, btn_pulse[1] : up in setting state
// a_INT : set to high when alarm on
// isOn : set to high when alarm set
//  Maker : CHA
// 
//////////////////////////////////////////////////////////////////////////////////


module alarm(
    input clk,
    input rst,
    input setting,
    input [5:0] digit,
    input [1:0] btn_1s, 
    input [2:0] btn_pulse,
    input toggle_2hz,
    input [3:0] sec0_in,
    input [3:0] sec1_in,
    input [3:0] min0_in,
    input [3:0] min1_in,
    input [3:0] hrs0_in,
    input [3:0] hrs1_in,
    output reg a_INT,
    output reg isOn,
    output reg [3:0] sec0,
    output reg [3:0] sec1,
    output reg [3:0] min0,
    output reg [3:0] min1,
    output reg [3:0] hrs0,
    output reg [3:0] hrs1,
    output reg [7:0] led_out
    );
    
    // btn
    wire up;
    assign up = btn_pulse[1];


    // alarm on off
    always @ (posedge clk, posedge rst) begin
        if (rst) isOn <= 0;
        else if (~isOn && setting) isOn <= 1;
        else if (btn_1s) isOn <= ~isOn;
    end

    // alarm Interrupt
    always @ (posedge clk, posedge rst) begin
        if (rst | ~isOn) a_INT <= 0;
        else if (a_INT == 1 && btn_pulse) a_INT <= 0;
        else if (
            sec0_in == sec0 &
            sec1_in == sec1 &
            min0_in == min0 &
            min1_in == min1 &
            hrs0_in == hrs0 &
            hrs1_in == hrs1 & isOn
        ) a_INT <= 1;
    end
    
    
    // led_out
    always @ (posedge clk, posedge rst) begin
        if (rst) led_out <= 0;
        else if (~isOn | setting) led_out <= 0;
        else if (a_INT) led_out <= {8{toggle_2hz}};
        else led_out <= {{7{1'b0}}, isOn};
    end
    
    
    // time
    always @ (posedge clk, posedge rst) begin
        if(rst) sec0 <= 0;
        else if (digit == 6'b100000 & setting) begin
            if (up) begin
                if (sec0 == 9) sec0 <= 0;
                else sec0 <= sec0 + 1;
            end
        end
    end
    
    always @ (posedge clk, posedge rst) begin
        if(rst) sec1 <= 0;
        else if (digit == 6'b010000 & setting) begin
            if (up) begin
                if (sec1 == 5) sec1 <= 0;
                else sec1 <= sec1 + 1;
            end
        end
    end
    
    always @ (posedge clk, posedge rst) begin
        if(rst) min0 <= 0;
        else if (digit == 6'b001000 & setting) begin
            if (up) begin
                if (min0 == 9) min0 <= 0;
                else min0 <= min0 + 1;
            end
        end
    end
    
    always @ (posedge clk, posedge rst) begin
        if(rst) min1 <= 0;
        else if (digit == 6'b000100 & setting) begin
            if (up) begin
                if (min1 == 5) min1 <= 0;
                else min1 <= min1 + 1;
            end
        end
    end
    
    always @ (posedge clk, posedge rst) begin
        if(rst) hrs0 <= 0;
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
        else if (digit == 6'b000001 & setting) begin
            if (up) begin
                if (hrs1 == 2) hrs1 <= 0;
                else hrs1 <= hrs1 + 1;
            end
        end
    end
    
endmodule
