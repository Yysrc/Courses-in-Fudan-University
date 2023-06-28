`timescale 1ns / 1ps

module MIPS(input  logic        clk, reset,
            input  logic [31:0] readdata,
            output logic        memwrite,
            output logic [31:0] adr, writedata);
            
    logic        zero, pcen, irwrite, regwrite, alusrca;
    logic        iord, memtoreg, regdst, immext;
    logic [1:0]  alusrcb;
    logic [1:0]  pcsrc;
    logic [2:0]  alucontrol;
    logic [31:0] instr, data;
    
    flopr  #(32) f1(clk, reset, readdata, data);
    flopren#(32) f2(clk, reset, irwrite, readdata, instr);
    
    controller c(clk, reset,
                 instr[31:26], instr[5:0], 
                 zero, pcen,
                 memwrite, irwrite,
                 regwrite, alusrca, iord, memtoreg, 
                 regdst, alusrcb, pcsrc, alucontrol, immext);
                 
    datapath dp(clk, reset,
                pcen, regwrite, 
                alusrca, iord, memtoreg, regdst,
                alusrcb, pcsrc, alucontrol, zero, 
                instr, adr, writedata, data, immext);
endmodule
