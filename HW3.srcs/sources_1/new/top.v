module top (
    input clk,
    input reset_poweron,
    input [4:0] btn,
    output reg [7:0] seg_data,
    output [7:0] leds,
    output reg[5:0] seg_com
    );

    localparam IDLE_ST = 3'd0, WATCH_ST = 3'd1, 
    TIMER_ST = 3'd2, ALARM_ST = 3'd3, ADJUST_ST = 3'd4;
    
    wire INT = 1'b0;    
    
    clk_wiz_0 clk_inst (clk_6mhz, reset_poweron, locked, clk);
    
    assign rst = reset_poweron | (~locked); 
    
    wire [4:0] btn_1s;
    wire [4:0] btn_pulse;
    debounce #(.BTN_WIDTH(5)) debounce_btn0_inst (clk_6mhz, rst, btn, btn_1s, btn_pulse);
    
    
    
    
    reg [3:0] c_state, n_state, return;
    always @ (posedge clk, posedge rst) begin
        if (rst) c_state <= IDLE_ST;
        else c_state <= n_state;
    end
    
    always @ (*) begin
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
    
    
    
    


    dec7 dec_sec0_inst (sec0, sec0_out); 
    dec7 dec_sec1_inst (sec1, sec1_out); 
    dec7 dec_min0_inst (min0, min0_out); 
    dec7 dec_min1_inst (min1, min1_out); 
    dec7 dec_hrs0_inst (hrs0, hrs0_out); 
    dec7 dec_hrs1_inst (hrs1, hrs1_out);

//    wire seg_shift;
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