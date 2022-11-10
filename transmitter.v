`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.09.2022 15:54:38
// Design Name: 
// Module Name: transmitter
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



module transmitter(Serial_out, Data_Bus, Byte_ready, Load_XMT_datareg, T_byte, Clock, reset); 
    parameter word_size = 8;                 //size of data word 
    parameter one_count = 3;                //number of states 
    parameter state_count = one_count;     //number of bits in state register 
    parameter size_bit_count = 3;            //size of bit counter 
    parameter idle = 3'b001; 
    parameter waiting = 3'b010; 
    parameter sending = 3'b100; 
    parameter all_ones = 9'b1_1111_1111;      //word + extra bit 
    output serial_out;                       //serial output to data channel 
    input [word_size - 1:0] Data_Bus;       //data bus containing data word 
    input Byte_ready;                     //used by host to signal ready 
    input Load_XMT_datareg;             //used to load the data register 
    input T_byte;               //used to signal the start of transmission 
    input Clock;                 //bit clock of the transmitter 
    input reset_;                //resets internal registers 
    reg [word_size - 1:0] XMT_datareg;          //transmit data register 
    reg [word_size:0] XMT_shftreg;              //transmit shift register 
    reg Load_XMT_shfteg; //flag to load 
    reg [state_count - 1:0] state, next_state; //state machine controller 
    reg [size_bit_count:0] bit_count; //counts the bits that are transmitted 
    reg clear; //clears bit_count after last bit is sent 
    reg shift; //causes shift of data in XMT_shftreg 
    reg start; //signals start of transmission 
    assign Serial_out = XMT_shftreg[0]; //LSB of shift register 
    always@(state or Byte_ready or bit_count or T_byte) 
        begin: Output_and_next_state 
                Load_XMT_shftreg = 0; 
                clear = 0; 
                shift = 0; 
                start = 0; 
                next_state = state; 
    case(state)
        idle: if(Byte_ready == 1) 
                begin 
                Load_XMT_shftreg = 1; 
                next_state = waiting; 
                end 
        waiting: if(T_byte == 1)
                    begin 
                    start = 1; 
                    next_state = sending; 
                    end 
        sending: if(bit_count != word_size + 1) 
                    shift = 1; 
                  else 
                  begin 
                  clear = 1; 
                  next_state = idle; 
                  end 
        default: next_state = idle; 
    endcase 
    end 
    
    always@(posedge Clock or negedge reset_) 
    begin: State_Transitions 
        if(reset_ == 0) state <= idle; 
        else state <= next_state; 
        end 
        
        
    always@(posedge Clock or negedge reset_) 
        begin: Register_Transfers 
        
        if(reset_ == 0) begin 
        XMT_shftreg <= all_ones; 
        bit_count <= 0; 
        end 
        
        else 
        begin 
        if(Load_XMT_datareg == 1) 
        XMT_datareg <= Data_Bus; //get the data bus 
        if(Load_XMT_shftreg == 1) 
        XMT_shftreg <= {XMT_datareg, 1'b1}; //load shift reg 
        if(start == 1) 
        XMT_shftreg[0] <= 0; //signal start of transmission 
        if(clear == 1) bit_count <= 0; 
        else if(shift == 1) bit_count <= bit_count + 1; 
        if(shift ==1) XMT_shftreg <= {1'b1, XMT_shftreg[word_size:1]}; //shift right, fill with 1's 
        end 
    end 
 endmodule   
