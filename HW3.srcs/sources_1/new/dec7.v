`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// dec7 u (.dec_in(), .dec_out());
// 7-segment Decoder (input [3:0] counter, output [6:0] data)
// MSB 부터 시계방향, LSB는 가운데
// Maker : CHA
// 
//////////////////////////////////////////////////////////////////////////////////


module dec7(
    input [3:0] dec_in,
    output [6:0] dec_out
    );
    reg [6:0] dec_out;
    always @ (dec_in) begin
        case (dec_in)
            4'b0000: dec_out = 7'b1111110;
            4'b0001: dec_out = 7'b0110000;
            4'b0010: dec_out = 7'b1101101;
            4'b0011: dec_out = 7'b1111001;
            4'b0100: dec_out = 7'b0110011;
            4'b0101: dec_out = 7'b1011011;
            4'b0110: dec_out = 7'b1011111;
            4'b0111: dec_out = 7'b1110010;
            4'b1000: dec_out = 7'b1111111;
            4'b1001: dec_out = 7'b1111011;
            default: dec_out = 7'b0000000; 
        endcase
    end
    
endmodule
