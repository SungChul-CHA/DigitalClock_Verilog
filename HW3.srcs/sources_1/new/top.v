module top (
    input clk,
    input reset_poweron,
    input [3:0] btn,
    output reg [7:0] seg_data,
    output [7:0] leds,
    output reg[5:0] seg_com
    );

    localparam IDLE_ST = 3'd0, WATCH_ST = 3'd1, 
    TIMER_ST = 3'd2, ALARM_ST = 3'd3, ADJUST_ST = 3'd4;
    
    wire clk_6mhz, clk_8hz, clk_1hz;
    
    wire [3:0] sec0 [3:0], min0 [3:0], hrs0 [3:0];
    wire [3:0] sec1 [3:0], min1 [3:0], hrs1 [3:0];
    
    reg [3:0] sec0_in, min0_in, hrs0_in;
    reg [3:0] sec1_in, min1_in, hrs1_in;
    
    wire [6:0] sec0_out, min0_out, hrs0_out;
    wire [6:0] sec1_out, min1_out, hrs1_out;
    
    reg clock_en, watch_en, timer_en, alarm_en, adjust_en;
    wire [3:0] enable = {alarm_en, timer_en, watch_en, clock_en};
    
    wire [3:0] btn_1s;
    wire [3:0] btn_pulse;
    
    wire seg_shift;
    wire locked, rst, INT;    
    
    
    clk_wiz_0 clk_inst (clk_6mhz, reset_poweron, locked, clk);
    gen_counter_en #(.SIZE(750000)) gen_clock_en_inst0 (clk_6mhz, rst, clk_8hz); 
    gen_counter_en #(.SIZE(6000000)) gen_clock_en_inst1 (clk_6mhz, rst, clk_1hz);
    
    assign rst = reset_poweron | (~locked); 
    
    debounce #(.BTN_WIDTH(4)) debounce_btn0_inst (clk_6mhz, rst, btn, btn_1s, btn_pulse);
    
    reg [3:0] c_state, n_state;
    wire [3:0] return;
    assign return = (c_state != ADJUST_ST) ? c_state : return;
    
    always @ (posedge clk, posedge rst) begin
        if (rst) c_state <= IDLE_ST;
        else c_state <= n_state;
    end
    
    always @ (c_state, INT, btn_1s, btn_pulse) begin
        case (c_state)
            IDLE_ST: begin
                if(INT) n_state = ALARM_ST;
                else if(|{btn_1s[3:0]}) n_state = ADJUST_ST;
                else if (btn_pulse[3]) n_state = WATCH_ST;
                else n_state = IDLE_ST;
            end
            WATCH_ST: begin
                if (INT) n_state = ALARM_ST;
                else if (btn_pulse[2]) n_state = IDLE_ST;
                else if (btn_pulse[3]) n_state = TIMER_ST;
                else n_state = WATCH_ST;
            end
            TIMER_ST: begin
                if (INT) n_state = ALARM_ST;
                else if (btn_1s[2]) n_state = ADJUST_ST;
                else if (btn_pulse[3]) n_state = ALARM_ST;
                else n_state = TIMER_ST;
            end
            ALARM_ST: begin
                if (btn_1s[2]) n_state = ADJUST_ST;
                else if (btn_pulse[3]) n_state = IDLE_ST;
                else n_state = ALARM_ST;
            end
            ADJUST_ST: begin
                if (INT) n_state = ALARM_ST;
                else if (btn_pulse[2]) n_state = return;
                else n_state = ADJUST_ST;
            end
            default: n_state = IDLE_ST;
        endcase
    end
    
    
    always @ (c_state) begin
        case (c_state)
            IDLE_ST: begin
                clock_en = 1; watch_en = 0; timer_en = 0;
                alarm_en = 0; adjust_en = 0;
            end
            WATCH_ST: begin
                clock_en = 0; watch_en = 1; timer_en = 0;
                alarm_en = 0; adjust_en = 0;
            end
            TIMER_ST: begin
                clock_en = 0; watch_en = 0; timer_en = 1;
                alarm_en = 0; adjust_en = 0;
            end
            ALARM_ST: begin
                clock_en = 0; watch_en = 0; timer_en = 0;
                alarm_en = 1; adjust_en = 0;
            end
            ADJUST_ST: begin
                clock_en = 0; watch_en = 0; timer_en = 0;
                alarm_en = 0; adjust_en = 1;
            end
            default: begin
                clock_en = 1; watch_en = 0; timer_en = 0;
                alarm_en = 0; adjust_en = 0;
            end
        endcase
    end
    
    
    
    clock clock_inst (clk_6mhz, rst, clock_en, clk_1hz, sec0[0], sec1[0], min0[0], min1[0], hrs0[0], hrs1[0]);
    stop_watch watch_inst (clk_6mhz, rst, watch_en, clk_8hz, clk_1hz, btn_pulse[1:0], sec0[1], sec1[1], min0[1], min1[1], hrs0[1], hrs1[1], leds);
//    timer timer_inst (clk_6mhz, rst, timer_en, clk_1hz, sec0, sec1, min0, min1, hrs0, hrs1, leds);
//    alarm alarm_inst (clk_6mhz, rst, alarm_en, sec0, sec1, min0, min1, hrs0, hrs1);

    
    
    
    always @ (*) begin
        case (enable)
            4'b0001: begin
                sec0_in = sec0[0];
                sec1_in = sec1[0];
                min0_in = min0[0];
                min1_in = min1[0];
                hrs0_in = hrs0[0];
                hrs1_in = hrs1[0];
            end
            4'b0010: begin
                sec0_in = sec0[1];
                sec1_in = sec1[1];
                min0_in = min0[1];
                min1_in = min1[1];
                hrs0_in = hrs0[1];
                hrs1_in = hrs1[1];
            end
            4'b0100: begin
                sec0_in = sec0[2];
                sec1_in = sec1[2];
                min0_in = min0[2];
                min1_in = min1[2];
                hrs0_in = hrs0[2];
                hrs1_in = hrs1[2];
            end
            4'b1000: begin
                sec0_in = sec0[3];
                sec1_in = sec1[3];
                min0_in = min0[3];
                min1_in = min1[3];
                hrs0_in = hrs0[3];
                hrs1_in = hrs1[3];
            end
        endcase
    end
    
    dec7 dec_sec0_inst (sec0_in, sec0_out); 
    dec7 dec_sec1_inst (sec1_in, sec1_out); 
    dec7 dec_min0_inst (min0_in, min0_out); 
    dec7 dec_min1_inst (min1_in, min1_out); 
    dec7 dec_hrs0_inst (hrs0_in, hrs0_out); 
    dec7 dec_hrs1_inst (hrs1_in, hrs1_out);

    
    gen_counter_en #(.SIZE(10000)) gen_clock_en_inst2 (clk_6mhz, rst, seg_shift);   // SIZE = 10000
    
    always @ (posedge clk_6mhz, posedge rst) begin
        if (rst) seg_com <= 6'b100000;
        else if (seg_shift) seg_com <= {seg_com[0], seg_com[5:1]};
    end

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