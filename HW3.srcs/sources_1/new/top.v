`timescale 1ns / 1ps

// Need to check before Generate Bitstream.
// 1. clk_wz_0   2. clock_en SIZE   3. seg_shift SIZE 
module top (
    input clk,
    input reset_poweron,
    input [3:0] btn, 
    output reg [7:0] seg_data, 
    output reg [5:0] seg_com,
    output [7:0] leds
    );
    
    wire clk_6mhz, clk_8hz, clk_1hz;
    wire [6:0] sec0_out, sec1_out, min0_out, min1_out, hrs0_out, hrs1_out; 
    wire [3:0] sec0_in, sec1_in, min0_in, min1_in, hrs0_in, hrs1_in;
    wire clock_en;
    reg [5:0] digit;
    wire [3:0] btn_1s;
    wire [3:0] btn_pulse; 
    wire locked, rst; 
    
    // clk
    //for speed control: SIZE=6000000(x1), SIZE=600000(x10), SIZE=6000(x1000), SIZE=60 (for simulation)
    assign clk_6mhz = clk;  //for Simulation only
//    clk_wiz_0 clk_inst (clk_6mhz, reset_poweron, locked, clk);
    gen_counter_en #(.SIZE(6000000)) gen_clock_en_inst0 (clk_6mhz, rst, clk_8hz);
    gen_counter_en #(.SIZE(600)) gen_clock_en_inst1 (clk_6mhz, rst, clk_1hz);

    //btn
    assign rst = reset_poweron | (~locked); 
    debounce #(.BTN_WIDTH(4)) debounce_btn0_inst (clk_6mhz, rst, btn, btn_1s, btn_pulse);

    localparam CLOCK_ST = 3'd0, SWATCH_ST = 3'd1,
    TIMER_ST = 3'd2, ALARM_ST = 3'd3, ADJUST_ST = 3'd4;
    
    reg [2:0] c_state, n_state;
    always @ (posedge clk, posedge rst) begin
        if(rst) c_state <= CLOCK_ST;
        else c_state <= n_state;
    end
    
    always @ (*) begin
        case (c_state)
            CLOCK_ST: if(btn[3]) n_state = SWATCH_ST; else n_state = CLOCK_ST;
            default: n_state = CLOCK_ST;
        endcase
    end
    
    reg [4:0] enable;
    always @ (*) begin
        case (c_state)
            CLOCK_ST: enable = 5'b00001;
            SWATCH_ST: enable = 5'b00010;
            TIMER_ST: enable = 5'b00100;
            ALARM_ST: enable = 5'b01000;
            ADJUST_ST: enable = 5'b10000;
            default: enable = 5'b00001;
        endcase
    end

    clock clock_inst (clk_6mhz, rst, enable[0], clk_1hz, sec0_in, sec1_in, min0_in, min1_in, hrs0_in, hrs1_in); 
    

    //7-seg decoder
    dec7 dec_sec0_inst (sec0_in, sec0_out); 
    dec7 dec_sec1_inst (sec1_in, sec1_out); 
    dec7 dec_min0_inst (min0_in, min0_out); 
    dec7 dec_min1_inst (min1_in, min1_out); 
    dec7 dec_hrs0_inst (hrs0_in, hrs0_out); 
    dec7 dec_hrs1_inst (hrs1_in, hrs1_out);

    // seg_com
    wire seg_shift;
    gen_counter_en #(.SIZE(1)) gen_clock_en_inst3 (clk_6mhz, rst, seg_shift);   // SIZE = 10000
    always @ (posedge clk_6mhz, posedge rst) begin
        if (rst) seg_com <= 6'b100000;
        else if (seg_shift) seg_com <= {seg_com[0], seg_com[5:1]};
    end

    // output
    always @ (seg_com) begin
        case (seg_com)
            6'b100000: seg_data = {sec0_out, 1'b1};
            6'b010000: seg_data = {sec1_out, 1'b0};
            6'b001000: seg_data = {min0_out, 1'b1};
            6'b000100: seg_data = {min1_out, 1'b0};
            6'b000010: seg_data = {hrs0_out, 1'b1};
            6'b000001: seg_data = {hrs1_out, 1'b0};
            default: seg_data = 8'b0; 
        endcase
    end

endmodule