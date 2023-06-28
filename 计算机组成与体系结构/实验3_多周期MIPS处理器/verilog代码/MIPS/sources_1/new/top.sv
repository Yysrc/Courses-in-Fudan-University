`timescale 1ns / 1ps

module top(input  logic        clk, reset,
           output logic [31:0] writedata, adr,
           output logic        memwrite);

    logic [31:0] readdata;

    mips mips(clk, reset, readdata, memwrite, adr, writedata);
    mem  mem (clk, memwrite, adr, writedata, readdata);

endmodule
