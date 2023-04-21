`timescale 1ns / 1ps

module mips(input  logic        clk, reset,
            output logic [31:0] pc,
            input  logic [31:0] instr,
            output logic        memwrite,
            output logic [31:0] aluout, writedata,
            input  logic [31:0] readdata);
            
    logic        memtoreg, branch,
                 pcsrc, zero,
                 alustr, regdst, regwrite, jump;
    logic [2:0]  alucontrol;
    logic        ImmExt;
    
    controller c(instr[31:26], instr[5:0], zero,
                 memtoreg, memwrite, pcsrc,
                 alusrc, regdst, regwrite, jump,
                 alucontrol, ImmExt);
    datapath dp(clk, reset, memtoreg, pcsrc,
                alusrc, regdst, regwrite, jump,
                alucontrol,
                zero, pc, instr,
                aluout, writedata, readdata, ImmExt);
endmodule
