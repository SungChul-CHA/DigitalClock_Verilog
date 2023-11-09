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
    
    wire clk_6mhz;
    wire [6:0] sec0_seg, sec1_seg, min0_seg, min1_seg, hrs0_seg, hrs1_seg;
    wire [3:0] sec0 [3:0], min0 [3:0], hrs0 [3:0];
    wire [2:0] sec1 [3:0], min1 [3:0], hrs1 [3:0];
    wire clock_en, watch_en, timer_en, alarm_en;
    reg [5:0] digit;
    wire left, up, reset, mode;
    wire [2:0] l_btn;
    wire [3:0] btn_out;
    wire [3:0] btn_pulse;
    wire locked, rst, seg_shift;
    reg [2:0] c_state, n_state;

    clk_wiz_0 clk_inst (clk_6mhz, reset_poweron, locked, clk);
    assign rst = reset_poweron | (~locked);
    
    always @ (posedge clk_6mhz, posedge rst) begin
        if (rst) c_state <= IDLE_ST;
        else c_state <= n_state;
    end
    
    always @ (*) begin
        case (c_state)
            IDLE_ST: begin 
                if(mode) n_state = WATCH_ST;
                else if (l_btn[0] | l_btn[1] | l_btn[2]) n_state = ADJUST_ST;
                else n_state = IDLE_ST;
            end
            WATCH_ST: begin
                n_state = TIMER_ST;
            end
            TIMER_ST: n_state = IDLE_ST;
            default: n_state = IDLE_ST;
        endcase
    
    end
    
    gen_counter_en #(.SIZE(6000000)) gen_clock_en_inst (clk_6mhz, rst, clock_en);
    clock clock_inst (clk_6mhz, rst, clock_en, sec0[0], sec1[0], min0[0], min1[0], hrs0[0], hrs1[0]);
    
    stop_watch stop_watch_inst(clk_6mhz, rst, clock_en, btn_pulse, watch, lap, sec0[1], sec1[1], min0[1], min1[1], hrs0[1], hrs1[1]);
    
    debounce #(.BTN_WIDTH(4)) debounce_btn0_inst (clk_6mhz, rst, btn, btn_out, btn_pulse);
    assign {left, up, reset, mode} = btn_pulse;

    clk_divider #(.DIVISOR(6000000)) clk_divider_inst0 (clk_6mhz, btn_out[0], l_btn[0]);
    clk_divider #(.DIVISOR(6000000)) clk_divider_inst1 (clk_6mhz, btn_out[1], l_btn[1]);
    clk_divider #(.DIVISOR(6000000)) clk_divider_inst2 (clk_6mhz, btn_out[2], l_btn[2]);
    
    dec7 dec_sec0_inst (sec0[0], sec0_out); 
    dec7 dec_sec1_inst (sec1[0], sec1_out); 
    dec7 dec_min0_inst (min0[0], min0_out); 
    dec7 dec_min1_inst (min1[0], min1_out); 
    dec7 dec_hrs0_inst (hrs0[0], hrs0_out); 
    dec7 dec_hrs1_inst (hrs1[0], hrs1_out);
    
    
    gen_counter_en #(.SIZE(10000)) gen_clock_en_inst1 (clk_6mhz, rst, seg_shift);   // SIZE = 10000
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