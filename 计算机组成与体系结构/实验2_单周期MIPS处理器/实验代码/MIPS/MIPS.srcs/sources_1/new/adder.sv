`timescale 1ns / 1ps

// 将pc值+4,跳到下一个32位地址
module adder(
    input  logic [31:0] a,
    input  logic [31:0] b,
    output logic [31:0] y );
    
assign y = a + b;
    
endmodule
