`timescale 1ns / 100ps

module testbench( );
    logic        clk;
    logic        reset;
    logic [31:0] writedata, dataadr;
    logic        memwrite;
    
    top dut(clk, reset, writedata, dataadr, memwrite);
    
    //初始化
    initial begin
        reset <= 1; #22; reset <= 0; 
    end 
    
    //时钟周期
    always begin
        clk <= 1; #5; clk <= 0; #5;
    end
    
    //对最后一条语句进行监视
    always@(negedge clk) begin
        if(memwrite) begin
            if(dataadr === 84 & writedata === 7) begin
                $display("Simulation Succeeded");
                $stop;
            end
            else if (dataadr !== 80) begin
                $display("Simulation Failed");
                $stop;
            end
        end
    end
    
endmodule
