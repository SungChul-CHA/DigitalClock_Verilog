`timescale 1ns / 1ps

// Need to check before Generate Bitstream.
// 1. clk_wz_0   2. clock_en SIZE   3. seg_shift SIZE 
module top (
    input clk,
    input reset_poweron,
    input [3:0] btn, 
    output reg [7:0] seg_data, 
    output [5:0] seg_com,
    output [7:0] leds
    );
    
    wire clk_6mhz, clk_8hz, clk_1hz;
    wire [6:0] sec0_out, sec1_out, min0_out, min1_out, hrs0_out, hrs1_out; 
    // 0 : clock, 1 : stop watch, 2 : timer, 3 : alarm
    wire [3:0] sec0[3:0], sec1[3:0], min0[3:0], min1[3:0], hrs0[3:0], hrs1[3:0];
    wire [3:0] btn_1s;
    wire [3:0] btn_pulse; 
    wire left, up, reset, mode;
    wire seg_shift;
    wire locked, rst; 
    wire flag_2hz;
    
    reg [5:0] seg_com_s;
    reg [5:0] digit;
    reg [5:0] digit_s;
    reg [4:0] enable;
    reg [3:0] sec0_in, sec1_in, min0_in, min1_in, hrs0_in, hrs1_in;
    reg [2:0] c_state, n_state, l_state;
    reg [2:0] setting;
    
    localparam CLOCK_ST = 3'd0, SWATCH_ST = 3'd1,
    TIMER_ST = 3'd2, ALARM_ST = 3'd3, SETTING_ST = 3'd4;
    
    // clk
    //for speed control: SIZE=6000000(x1), SIZE=600000(x10), SIZE=6000(x1000), SIZE=60 (for simulation) / 8hz -> SIZE = 750000
//    assign clk_6mhz = clk;  //for Simulation only
    clk_wiz_0 clk_inst (clk_6mhz, reset_poweron, locked, clk);
    gen_counter_en #(.SIZE(750000)) gen_clock_en_inst0 (clk_6mhz, rst, clk_8hz);
    gen_counter_en #(.SIZE(6000000)) gen_clock_en_inst1 (clk_6mhz, rst, clk_1hz);
    
    gen_counter_en #(.SIZE(10000)) gen_clock_en_inst3 (clk_6mhz, rst, seg_shift);   // SIZE = 10000
    clk_divider #(.DIVISOR(3000000)) clk_divider_inst (clk_6mhz, |{setting}, flag_2hz);


    //btn
    assign rst = reset_poweron | (~locked); 
    assign {mode, reset, up, left} = btn_pulse;
    assign seg_com = (|{setting}) ? seg_com_s & ~digit_s : seg_com_s;

    // c_state
    always @ (posedge clk_6mhz, posedge rst) begin
        if(rst) c_state <= CLOCK_ST;
        else c_state <= n_state;
    end
    
    // l_state
    always @ (posedge clk_6mhz, posedge rst) begin
        if (rst) l_state <= 0;
        else if (c_state != SETTING_ST) l_state = c_state;
    end
    
    // digit_s ±ô¹ÚÀÓ
    always @ (posedge clk_6mhz, posedge rst) begin
        if (rst) digit_s <= 6'b100000;
        else if (flag_2hz) digit_s <= digit;
        else digit_s <= 0;
    end
    
    // seg_com ±ôºýÀÓ
    always @ (posedge clk_6mhz, posedge rst) begin
        if (rst) seg_com_s <= 6'b100000;
        else if (seg_shift) seg_com_s <= {seg_com_s[0], seg_com_s[5:1]};
    end
    
    // digit shift
    always @ (posedge clk_6mhz, posedge rst) begin
        if (rst) digit <= 6'b100000;
        else if (|{setting} & left) digit <= {digit[0], digit[5:1]};
    end
    
    // n_state
    always @ (c_state, btn_1s[2], mode, reset) begin
        case (c_state)
            CLOCK_ST: if(btn_1s[2]) n_state = SETTING_ST; else if(mode) n_state = SWATCH_ST; else n_state = CLOCK_ST;
            SWATCH_ST: if(reset) n_state = CLOCK_ST; else if (mode) n_state = TIMER_ST; else n_state = SWATCH_ST;
            TIMER_ST: if (btn_1s[2]) n_state = SETTING_ST; else if (mode) n_state = ALARM_ST; else n_state = TIMER_ST;
            ALARM_ST: if(btn_1s[2]) n_state = SETTING_ST; else if (mode) n_state = CLOCK_ST; else n_state = ALARM_ST;
            SETTING_ST: if(reset) n_state = l_state; else n_state = SETTING_ST;
            default: n_state = CLOCK_ST;
        endcase
    end
    
    // enable
    always @ (c_state) begin
        case (c_state)
            CLOCK_ST: enable = 4'b1001;
            SWATCH_ST: enable = 4'b1011;
            TIMER_ST: enable = 4'b1101;
            ALARM_ST: enable = 4'b1001;
            default: enable = 4'b0000;
        endcase
    end
    
    // setting
    always @ (c_state) begin
        if (c_state == SETTING_ST) 
            if (l_state == CLOCK_ST) setting = 3'b001;
            else if (l_state == TIMER_ST) setting = 3'b010;
            else if (l_state == ALARM_ST) setting = 3'b100;
            else setting = 0;
        else setting = 0;
    end
    
    // time_in
    always @ (*) begin
        case (c_state)
            CLOCK_ST: begin
                sec0_in = sec0[0];
                sec1_in = sec1[0];
                min0_in = min0[0];
                min1_in = min1[0];
                hrs0_in = hrs0[0];
                hrs1_in = hrs1[0];
            end
            SWATCH_ST: begin
                sec0_in = sec0[1];
                sec1_in = sec1[1];
                min0_in = min0[1];
                min1_in = min1[1];
                hrs0_in = hrs0[1];
                hrs1_in = hrs1[1];
            end
            TIMER_ST: begin
                sec0_in = sec0[2];
                sec1_in = sec1[2];
                min0_in = min0[2];
                min1_in = min1[2];
                hrs0_in = hrs0[2];
                hrs1_in = hrs1[2];
            end
            ALARM_ST: begin
                sec0_in = sec0[3];
                sec1_in = sec1[3];
                min0_in = min0[3];
                min1_in = min1[3];
                hrs0_in = hrs0[3];
                hrs1_in = hrs1[3];
            end
            SETTING_ST: begin
                if (setting[0] == 1) begin
                    sec0_in = sec0[0];
                    sec1_in = sec1[0];
                    min0_in = min0[0];
                    min1_in = min1[0];
                    hrs0_in = hrs0[0];
                    hrs1_in = hrs1[0];
                end
                else if (setting[1] == 1) begin
                    sec0_in = sec0[2];
                    sec1_in = sec1[2];
                    min0_in = min0[2];
                    min1_in = min1[2];
                    hrs0_in = hrs0[2];
                    hrs1_in = hrs1[2];
                end
                else if (setting[2] == 1) begin
                    sec0_in = sec0[3];
                    sec1_in = sec1[3];
                    min0_in = min0[3];
                    min1_in = min1[3];
                    hrs0_in = hrs0[3];
                    hrs1_in = hrs1[3];
                end
                else begin
                    sec0_in = 0;
                    sec1_in = 0;
                    min0_in = 0;
                    min1_in = 0;
                    hrs0_in = 0;
                    hrs1_in = 0;
                end
            end
            default : begin
                sec0_in = sec0_in;
                sec1_in = sec1_in;
                min0_in = min0_in;
                min1_in = min1_in;
                hrs0_in = hrs0_in;
                hrs1_in = hrs1_in;
            end
        endcase
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
    

    clock clock_inst (clk_6mhz, rst, enable[0], clk_1hz, digit, up & setting[0], sec0[0], sec1[0], min0[0], min1[0], hrs0[0], hrs1[0]);
    stop_watch swatch_inst (clk_6mhz, rst, enable[1], clk_8hz, clk_1hz, btn_pulse[1:0], sec0[1], sec1[1], min0[1], min1[1], hrs0[1], hrs1[1], leds);
//    timer timer_inst (clk_6mhz, rst, enable[2], clk_8hz, clk_1hz, btn_pulse[3:0], btn[);
    
    debounce #(.BTN_WIDTH(4)) debounce_btn0_inst (clk_6mhz, rst, btn, btn_1s, btn_pulse);
    
    //7-seg decoder
    dec7 dec_sec0_inst (sec0_in, sec0_out); 
    dec7 dec_sec1_inst (sec1_in, sec1_out); 
    dec7 dec_min0_inst (min0_in, min0_out); 
    dec7 dec_min1_inst (min1_in, min1_out); 
    dec7 dec_hrs0_inst (hrs0_in, hrs0_out); 
    dec7 dec_hrs1_inst (hrs1_in, hrs1_out);


endmodule