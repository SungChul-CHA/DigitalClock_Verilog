`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// clk_divider #(.DIVISOR())) u (.clk_in(), .en(), .clk_out());
// clk_out = clk_in / DIVISOR
// Maker : CHA
//
//////////////////////////////////////////////////////////////////////////////////


module clk_divider(clk_in, en, clk_out);
input clk_in;
input en;
output reg clk_out = 1'b0;

reg[31:0] o=32'd0;
parameter DIVISOR = 32'd6000000;

always @(posedge clk_in) begin
    if(en == 1) begin
        o <= o + 1;
        if(o < DIVISOR) clk_out <= 1'b1;
        else clk_out <= 1'b0;
    end
    else o <= 0;
end

endmodule