`timescale 1ns / 1ps

module controller(input  logic [5:0] op, funct,
                  input  logic       zero,
                  output logic       memtoreg, memwrite,
                  output logic       pcsrc, alusrc,
                  output logic       regdst, regwrite,
                  output logic       jump,
                  output logic [2:0] alucontrol,
                  output logic       ImmExt);
    logic [2:0] aluop;
    logic       branch;
    logic       BranchBne;
    
    maindec md(op, memtoreg, memwrite, branch,
               alusrc, regdst, regwrite, aluop, jump, ImmExt, BranchBne);
    aludec  ad(funct, aluop, alucontrol);
    
    // 重点 pcsrc变了
    assign pcsrc = (branch & zero) | ((~zero) & BranchBne); 
endmodule
