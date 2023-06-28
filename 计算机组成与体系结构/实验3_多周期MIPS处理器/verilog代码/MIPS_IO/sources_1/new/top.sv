`timescale 1ns / 1ps

 module Top(
    input  logic        CLK100MHZ, 
    input  logic        BTNC,       //reset
    input  logic        BTNL,       
    input  logic        BTNR,
    input  logic [15:0] SW,
    output logic [7:0]  AN,
    output logic [6:0]  A2G);
    
    logic        Write;
    logic [31:0] Adr, writeData, readData;

    MIPS mips(.clk(CLK100MHZ), 
              .reset(BTNC), 
              .readdata(readData),
              .memwrite(Write), 
              .adr(Adr), 
              .writedata(writeData) );
              
    MemoryDecoder md(  .clk(CLK100MHZ), 
                       .writeEn(Write), 
                       .addr(Adr[7:0]),     //aluout 后8位
                       .writeData(writeData),   //写内存
                       .readData(readData),     //读内存
                       .reset(BTNC), 
                       .btnL(BTNL), 
                       .btnR(BTNR), 
                       .switch(SW), 
                       .an(AN), 
                       .a2g(A2G)    );
 
endmodule

