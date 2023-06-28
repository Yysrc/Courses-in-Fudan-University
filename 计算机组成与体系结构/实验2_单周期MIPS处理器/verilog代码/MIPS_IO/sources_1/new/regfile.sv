`timescale 1ns / 1ps

//寄存器文件
module regfile(
    input logic         clk,
    input logic         regWriteEn,
    input logic  [4:0]  RsAddr, 
    input logic  [4:0]  RtAddr,
    input logic  [4:0]  regWriteAddr,
    input logic  [31:0] regWriteData,
    output logic [31:0] RsData,
    output logic [31:0] RtData
    );
    
logic [31:0] rf[31:0]; //32个32位寄存器

//写入使能有效时写入数据
always_ff@(posedge clk)
    if(regWriteEn) rf[regWriteAddr] <= regWriteData;
    
assign RsData = (RsAddr != 0) ? rf[RsAddr] : 0;
assign RtData = (RtAddr != 0) ? rf[RtAddr] : 0;

endmodule


