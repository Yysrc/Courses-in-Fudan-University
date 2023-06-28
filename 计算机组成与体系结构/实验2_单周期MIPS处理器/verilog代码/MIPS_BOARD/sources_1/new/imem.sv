`timescale 1ns / 1ps

//Ö¸Áî´æ´¢Æ÷
module iMemory(input  logic [5:0]  a,
            output logic [31:0] rd);
            
    logic  [31:0] RAM[63:0];
    
    initial
        begin
           $readmemh("TestIO.dat", RAM);
        end
    
    assign rd = RAM[a];
endmodule
