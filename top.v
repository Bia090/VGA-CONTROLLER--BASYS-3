`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.07.2025 10:18:02
// Design Name: 
// Module Name: top
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


module top(
        input clk,
        input reset,
        input btnU,  
        input btnD,  
 //      input btnL,  
 //      input btnR,  
        output Hsync,
        output Vsync,
        output [3:0] red,
        output [3:0] green,
        output [3:0] blue

 );
 
 wire clk_148MHz;
 
 clk clk_i(
  .clk (clk_148MHz),
  .reset (~reset),
  .Hsync (Hsync),
  .Vsync( Vsync),
   .btnU(btnU),
   .btnD(btnD),
// .btnL(btnL),
// .btnR(btnR),
  .red(red),
  .green(green),
  .blue(blue)
);

    design_1_wrapper design_1_wrapper_i (
       .clk_in1_0  (clk),
        .clk_out1_0  (clk_148MHz),
        .reset_0  (reset)
        );

//reg btn_prev;
//always @(clk or rst) secvential
//if(rst) btn_prev<=12'b0;else
//if(btn //(venit din cons*)
//      ) btn_prev <=1'b1;
//        btn_prev<=1'b0;
        
        

endmodule