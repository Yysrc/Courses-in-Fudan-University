`timescale 1ns / 1ps

// 异步复位触发器
// 时钟上升沿到来，若有复位信号，pc 置 0，否则置pcnext

module flopr #(parameter WIDTH = 8) (
    input  logic clk, reset,
    input  logic [WIDTH-1:0] d,
    output logic [WIDTH-1:0] q );
    
always_ff@(posedge clk, posedge reset)
    if(reset)   q <= 0;
    else        q <= d;
    
endmodule
