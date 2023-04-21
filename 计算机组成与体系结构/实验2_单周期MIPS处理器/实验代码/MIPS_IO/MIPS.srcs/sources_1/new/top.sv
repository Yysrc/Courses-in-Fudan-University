`timescale 1ns / 1ps

 module Top(
    input  logic        CLK100MHZ, 
    input  logic        BTNC,       //reset
    input  logic        BTNL,       
    input  logic        BTNR,
    input  logic [15:0] SW,
    output logic [7:0]  AN,
    output logic [6:0]  A2G);
    
    logic [31:0] pc, instr;
    iMemory imem(.a(pc[7:2]),
                 .rd(instr)  );
    
    logic        Write;
    logic [31:0] dataAdr, writeData, readData;

    MIPS mips(.clk(CLK100MHZ), 
              .reset(BTNC), 
              .pc(pc), 
              .instr(instr), 
              .memwrite(Write), 
              .aluout(dataAdr), 
              .writedata(writeData), 
              .readdata(readData)    );
              
    dMemoryDecoder dmd(.clk(CLK100MHZ), 
                       .writeEn(Write), 
                       .addr(dataAdr[7:0]),     //aluout 后8位
                       .writeData(writeData),   //写内存
                       .readData(readData),     //读内存
                       .reset(BTNC), 
                       .btnL(BTNL), 
                       .btnR(BTNR), 
                       .switch(SW), 
                       .an(AN), 
                       .a2g(A2G)    );
 
endmodule
