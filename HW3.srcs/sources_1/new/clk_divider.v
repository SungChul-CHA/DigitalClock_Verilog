`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/11/07 17:17:22
// Design Name: 
// Module Name: clk_divider
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module clk_divider(
    input clk_in,
    output clk_out
    );
    reg [31:0] count = 32'd0;
    reg clk_out;
    parameter DIVISOR = 32'd6000000/8;
    
    always @ (posedge clk_in) begin
        if(count == DIVISOR/2-1) begin
            count <= 0;
            clk_out <= ~clk_out;
        end
        else count <= count + 1;
    end
    
endmodule
