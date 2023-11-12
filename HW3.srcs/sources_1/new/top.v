`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// LED on the right : alarm set
// btn 0 ~ 4 -> SW0 ~ SW5. btn4 : reset hole module
// Clock Mode : btn0, btn1, btn3 : next state , btn2 : setting state. 
// Stop Watch Mode : btn0 : start/stop, btn1 : reset/lap time, btn2 : move to Clock state, btn3 : next state
// Timer Mode : btn0 : start/stop, btn1 : reset, btn2 : setting state, btn3 : next state
// Alarm Mode : btn0 : alarm off, btn1 : alarm cancel, btn2 : setting state, btn3 : next state
// Setting Mode : btn0 : move cursor to left, btn1 : increase time, btn2, btn3 : return to last state
// Maker : CHA
// 
//////////////////////////////////////////////////////////////////////////////////


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
    
    // need for operation
    wire clk_6mhz, clk_8hz, clk_1hz, toggle_2hz;
    wire locked, rst;
    
    // need for button
    wire [3:0] btn_1s;
    wire [3:0] btn_pulse; 
    wire left, up, reset, mode;
    
    // need for output
    // leds
    wire [7:0] led_s, led_t, led_a;
    wire alarm_on;
    // time data
    wire [6:0] sec0_out, sec1_out, min0_out, min1_out, hrs0_out, hrs1_out; 
    reg [3:0] sec0_in, sec1_in, min0_in, min1_in, hrs0_in, hrs1_in;
    wire [3:0] sec0[3:0], sec1[3:0], min0[3:0], min1[3:0], hrs0[3:0], hrs1[3:0];
    // segment data
    wire seg_shift;
    reg [5:0] seg_com_s;
    reg [5:0] digit;
    reg [5:0] digit_s;

    
     // need for state
    // 0 : clock, 1 : stop watch, 2 : timer, 3 : alarm
    reg [2:0] c_state, n_state, l_state;
    reg [2:0] enable;
    reg [2:0] setting;
    wire a_INT, t_INT;
    
    
    // state parameter
    localparam CLOCK_ST = 3'd0, SWATCH_ST = 3'd1,
    TIMER_ST = 3'd2, ALARM_ST = 3'd3, SETTING_ST = 3'd4;
    
    // clk
    //for speed control: SIZE=6000000(x1), SIZE=600000(x10), SIZE=6000(x1000), SIZE=60 (for simulation) / 8hz -> SIZE = 750000
//    assign clk_6mhz = clk;  //for Simulation only
    clk_wiz_0 clk_inst (clk_6mhz, reset_poweron, locked, clk);                      // generate 6mhz clk -> operate clk
    gen_counter_en #(.SIZE(750000)) gen_clock_en_inst0 (clk_6mhz, rst, clk_8hz);    // generate 8hz clk -> led shift clk
    gen_counter_en #(.SIZE(6000000)) gen_clock_en_inst1 (clk_6mhz, rst, clk_1hz);   // generate 1hz clk -> time clk
    clk_divider #(.DIVISOR(3000000)) clk_divider_inst (clk_6mhz,1'b1, toggle_2hz);  // generate toggle signal in 2hz -> blinking
    
    
    //btn
    debounce #(.BTN_WIDTH(4)) debounce_btn0_inst (clk_6mhz, rst, btn, btn_1s, btn_pulse); // btn_1s : generate a pulse after 1sec
    assign rst = reset_poweron | (~locked);                                         // btn4(SW4) : rst whole module
    assign {mode, reset, up, left} = btn_pulse;                                     // btn[3:0](SW3 ~ SW0) : mode, reset, up, left
    
    
    // led out
    assign leds = (c_state == SWATCH_ST) ? led_s :                                  // s : stop watch, t : timer, LSB(right one) : alarm set or cancel signal
                (c_state == TIMER_ST) ?  led_t :
                (c_state == ALARM_ST) ? led_a : {{7{1'b0}}, alarm_on};


    // time output
    always @ (seg_com) begin                                                        // show time in proper digit
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
    
    //7-seg decoder
    dec7 dec_sec0_inst (sec0_in, sec0_out);                                         // decode 4bit unsigned integer to 6bit segment data 
    dec7 dec_sec1_inst (sec1_in, sec1_out); 
    dec7 dec_min0_inst (min0_in, min0_out); 
    dec7 dec_min1_inst (min1_in, min1_out); 
    dec7 dec_hrs0_inst (hrs0_in, hrs0_out); 
    dec7 dec_hrs1_inst (hrs1_in, hrs1_out);
    
    // time_in
    always @ (*) begin                                                              // choose time data to input to dec7 
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
   
   
    // segment
    // SIZE = 10000
    gen_counter_en #(.SIZE(10000)) gen_clock_en_inst3 (clk_6mhz, rst, seg_shift);   // generate 600hz clk -> seg_com shift clk      
   
    // seg_com                
    assign seg_com = (setting) ? seg_com_s & ~digit_s :
                    (a_INT | t_INT) ? seg_com_s & {8{toggle_2hz}} : seg_com_s;      // time on cursor blink every 0.5s in setting mode
    
    always @ (posedge clk_6mhz, posedge rst) begin                                  // seg_com_s : shift to left in 600hz
        if (rst) seg_com_s <= 6'b100000;
        else if (seg_shift) seg_com_s <= {seg_com_s[0], seg_com_s[5:1]};
    end
    
    // digit
    always @ (posedge clk_6mhz, posedge rst) begin                                  // move cursor to left
        if (rst) digit <= 6'b100000;
        else if (setting && left) digit <= {digit[0], digit[5:1]};
    end
    
    // digit_s ±ô¹ÚÀÓ
    always @ (posedge clk_6mhz, posedge rst) begin                                  // toggle a bit on cursor in 2hz
        if (rst) digit_s <= 6'b100000;
        else if (toggle_2hz) digit_s <= digit;
        else digit_s <= 0;
    end
    
    
    // c_state
    always @ (posedge clk_6mhz, posedge rst) begin
        if(rst) c_state <= CLOCK_ST;
        else c_state <= n_state;
    end

    // n_state
    always @ (c_state, btn_1s[2], btn_pulse, a_INT) begin                                                  
        case (c_state)
            CLOCK_ST: begin
                if (a_INT) n_state = ALARM_ST;  
                else if (t_INT) n_state = TIMER_ST; 
                else if(btn_1s[2]) n_state = SETTING_ST; 
                else if(left | up | mode) n_state = SWATCH_ST; 
                else n_state = CLOCK_ST;
            end
            SWATCH_ST: begin
                if (a_INT) n_state = ALARM_ST; 
                else if(reset) n_state = CLOCK_ST; 
                else if (mode) n_state = TIMER_ST; 
                else n_state = SWATCH_ST;
            end
            TIMER_ST: begin
                if (a_INT) n_state = ALARM_ST; 
                else if (btn_1s[2]) n_state = SETTING_ST; 
                else if (mode) n_state = ALARM_ST; 
                else n_state = TIMER_ST;
            end
            ALARM_ST: begin
                if (t_INT) n_state = TIMER_ST; 
                else if(btn_1s[2]) n_state = SETTING_ST; 
                else if (mode) n_state = CLOCK_ST; 
                else n_state = ALARM_ST;
            end
            SETTING_ST: begin
                if (a_INT) n_state = ALARM_ST; 
                else if (t_INT) n_state = TIMER_ST; 
                else if(reset | mode) n_state = l_state; 
                else n_state = SETTING_ST;
            end
            default: n_state = CLOCK_ST;
        endcase
    end
    
    // l_state
    always @ (posedge clk_6mhz, posedge rst) begin
        if (rst) l_state <= 0;
        else if (c_state != SETTING_ST) l_state <= c_state;
    end
    
    
    // enable                                                                                  
    always @ (c_state) begin                                            // clock : always, stop watch : in SWATCH_ST, timer : in TIMER_ST
        case (c_state)
            CLOCK_ST: enable = 3'b101;                                 
            SWATCH_ST: enable = 3'b111;                                // enable[2] : Timer 
            TIMER_ST: enable = 3'b101;                                 // enable[1] : Stop Watch
            ALARM_ST: enable = 3'b101;                                 // enable[0] : Clock
            default: enable = 3'b101;
        endcase
    end
    
    // setting
    always @ (c_state) begin                                            // setting[2] : Alarm
        if (c_state == SETTING_ST)                                      // setting[1] : Timer
            if (l_state == CLOCK_ST) setting = 3'b001;                  // setting[0] : clock
            else if (l_state == TIMER_ST) setting = 3'b010;
            else if (l_state == ALARM_ST) setting = 3'b100;
            else setting = 0;
        else setting = 0;
    end
    
    
    // instantiation
    clock clock_inst (clk_6mhz, rst, enable[0] & ~setting[0], clk_1hz, setting[0], digit, up, sec0[0], sec1[0], min0[0], min1[0], hrs0[0], hrs1[0]);    
    stop_watch swatch_inst (clk_6mhz, rst, enable[1], clk_8hz, clk_1hz, btn_pulse[1:0], sec0[1], sec1[1], min0[1], min1[1], hrs0[1], hrs1[1], led_s);
    timer timer_inst (clk_6mhz, rst, enable[2], clk_8hz, clk_1hz, setting[1], digit, btn_pulse[2:0], toggle_2hz, t_INT, sec0[2], sec1[2], min0[2], min1[2], hrs0[2], hrs1[2], led_t);
    alarm alarm_inst (clk_6mhz, rst, setting[2], digit, btn_1s[1:0], btn_pulse[2:0], toggle_2hz, sec0[0], sec1[0], min0[0], min1[0], hrs0[0], hrs1[0], a_INT, alarm_on, sec0[3], sec1[3], min0[3], min1[3], hrs0[3], hrs1[3], led_a);

endmodule