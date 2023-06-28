`timescale 1ns / 1ps

module controller(input logic       clk, reset,
                  input  logic [5:0] op, funct,
                  input  logic       zero,
                  output logic       pcen,
                  output logic       memwrite, irwrite, regwrite,
                  output logic       alusrca, iord, memtoreg, regdst,
                  output logic [1:0] alusrcb, pcsrc,
                  output logic [2:0] alucontrol,
                  output logic       immext);
    logic [2:0] aluop;
    logic       branch;
    logic       branchbne;
    logic       pcwrite;
    
    maindec md(clk, reset,
               op, pcwrite, memwrite, irwrite, regwrite,
               alusrca, branch, iord, memtoreg, regdst,
               alusrcb, pcsrc, aluop, branchbne, immext);
    aludec  ad(funct, aluop, alucontrol);
    
    // pcen
    assign pcen = (branch & zero) | ((~zero) & branchbne) | pcwrite; 
endmodule
