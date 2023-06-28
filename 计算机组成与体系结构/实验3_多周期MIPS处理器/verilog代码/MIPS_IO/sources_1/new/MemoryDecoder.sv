`timescale 1ns / 1ps

`timescale 1ns / 1ps

module MemoryDecoder(
    input  logic        clk,
    input  logic        writeEn,
    input  logic [7:0]  addr,
    input  logic [31:0] writeData,
    output logic [31:0] readData,
    
    input  logic        reset,
    input  logic        btnL, 
    input  logic        btnR,
    input  logic [15:0] switch,
    output logic [7:0]  an,
    output logic [6:0]  a2g );
    
    logic [31:0] ReadData1;
    logic [31:0] ReadData2;
    
    logic [11:0] led;
    
    //�Ƿ�� IO ����addr[7] == 1 ˵����io�ӿڿռ䣩
    assign pRead    = (addr[7] == 1'b1) ? 1 : 0;
    
    //�Ƿ��� IO д
    assign pWrite   = (addr[7] == 1'b1) ? writeEn : 0;
    
    //д�����ݴ洢���Ŀ���
    assign we       = (addr[7] == 1'b0) ? writeEn : 0;
    
    assign readData = (addr[7] == 1'b0) ? ReadData1 : ReadData2;
    
    mem     mem (clk, writeEn, {24'b0, addr}, writeData, ReadData1);
    
    IO      io   ( clk,
                   reset, 
                   pRead, 
                   pWrite, 
                   addr[3:2], 
                   writeData[11:0], 
                   ReadData2, 
                   btnL, 
                   btnR, 
                   switch, 
                   led        );
                   
    mux7seg m7seg(clk, reset, {switch, 4'b0, led}, a2g, an);
endmodule