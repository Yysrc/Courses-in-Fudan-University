`timescale 1ns / 1ps

// ��pcֵ+4,������һ��32λ��ַ
module adder(
    input  logic [31:0] a,
    input  logic [31:0] b,
    output logic [31:0] y );
    
assign y = a + b;
    
endmodule
