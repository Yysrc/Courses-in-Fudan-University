`timescale 1ns / 1ps

// �첽��λ������
// ʱ�������ص��������и�λ�źţ�pc �� 0��������pcnext

module flopr #(parameter WIDTH = 8) (
    input  logic clk, reset,
    input  logic [WIDTH-1:0] d,
    output logic [WIDTH-1:0] q );
    
always_ff@(posedge clk, posedge reset)
    if(reset)   q <= 0;
    else        q <= d;
    
endmodule
