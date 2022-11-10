`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.09.2022 17:45:32
// Design Name: 
// Module Name: test_bench
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


module test_bench();
    reg [7:0]Data_Bus;
    reg Load_XMT_datareg;
    reg Byte_ready;
    reg T_byte;
    reg Clock;
    reg rst_b;
    wire Serial_out;
    Control_Unit MT(Load_XMT_DR,Load_XMT_shiftreg,start,shift,clear,Load_XMT_datareg,Byte_ready,T_byte,BC_It_BCmax,Clock,rst_b);
    Datapath_Unit UT(Serial_out,BC_It_BCmax,Data_Bus,Load_XMT_DR,Load_XMT_shiftreg,start,shift,clear,Clock,rst_b);
    initial
    begin
    rst_b=1'b0;
    Clock=1'b0;
    Load_XMT_datareg=1'b0;
    Byte_ready=1'b0;
    T_byte=1'b0;
    Data_Bus=8'b00000000;
    end
    initial
    begin
    #2 rst_b=1'b1;
    #3 Load_XMT_datareg=1'b1;
    #10 Byte_ready=1'b1;
    #4 Load_XMT_datareg=1'b0;
    #3 T_byte=1'b1;
    #8 Load_XMT_datareg=1'b1;
    #5 Load_XMT_datareg=1'b0;
    #23 T_byte=1'b0;
    #24 Byte_ready=1'b0;
    end
    always
    begin
    #1 Clock=~Clock;
    end
    initial
    begin
    #9 Data_Bus=8'b1010_0111;
    #70 $finish;
    end
endmodule
