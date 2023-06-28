`timescale 1ns / 1ps

// Êý¾ÝÂ·¾¶
module datapath(
    input  logic        clk, reset,
    input  logic        pcen, regwrite,
    input  logic        alusrca, iord, memtoreg, regdst,
    input  logic [1:0]  alusrcb,
    input  logic [1:0]  pcsrc,
    input  logic [2:0]  alucontrol,
    output logic        zero,
    input  logic [31:0] instr,
    output logic [31:0] adr, writedata,
    input  logic [31:0] data,
    input  logic        immext );
    
    logic [4:0]  a1, a2, a3;
    logic [31:0] pc, nextpc, wd3, rd1, rd2;
    logic [31:0] a, b, srca, srcb, four, signimm, zeroimm, imm;
    logic [31:0] aluresult, aluout, pcjump;
    
    assign writedata = b;
    assign a1        = instr[25:21];
    assign a2        = instr[20:16];
    assign four      = 8'h0000_0004;
    assign pcjump    = {pc[31:28], (instr[25:0] << 2)};

    flopren#(32) f0(clk,reset,pcen,nextpc,pc);
    
    mux2#(32) m0(pc, aluout, iord, adr);
    mux2#(5)  m1(instr[20:16], instr[15:11], regdst, a3);
    mux2#(32) m2(aluout, data, memtoreg, wd3);
    
    regfile rf(clk, regwrite, a1, a2, a3, wd3, rd1, rd2);
    
    flopr#(32) f3(clk, reset, rd1, a);
    flopr#(32) f4(clk, reset, rd2, b);
    mux2 #(32) m3(pc, a, alusrca, srca);
    signext    sn(instr[15:0], signimm);
    zeronext   ze(instr[15:0], zeroimm); 
    mux2 #(32) extmux(signimm, zeroimm, immext, imm);
    mux4 #(32) m4(b, four, imm, (imm << 2), alusrcb, srcb);
    alu        alu(srca, srcb, alucontrol, aluresult, zero);
    flopr#(32) f5(clk, reset, aluresult, aluout);
    mux3 #(32) m5(aluresult, aluout, pcjump, pcsrc, nextpc);
    
endmodule

