module IO(
    input  logic        clk,
    input  logic        reset,
    input  logic        pRead,
    input  logic        pWrite,
    input  logic [1:0]  addr,
    input  logic [11:0] pWriteData,
    output logic [31:0] pReadData,
    input  logic        buttonL,
    input  logic        buttonR,
    input  logic [15:0] switch,
    output logic [11:0] led
    );
    
    logic [1:0]  status;
    logic [15:0] switch1;
    logic [11:0] led1;

    always_ff@(posedge clk) begin
        if(reset) 
            begin
                status  <= 2'b00;
                led1    <= 12'h00;
                switch1 <= 16'h00;
            end
        else 
            begin
                //按下 buttonR，开关已拨好，可输入新数据
                if(buttonR)
                    begin
                        status[1] <= 1;
                        switch1   <= switch;
                    end
                
                //按下 buttonL，led已准备好，可输出新数据
                if(buttonL)
                    begin
                        status[0] <= 1;
                        led       <= led1;
                    end
        
                //向输出端口输出
                if(pWrite & (addr == 2'b01))
                    begin
                        led1 <= pWriteData;
                        status[0] <= 0;
                    end
            end
    end
    
    
    always_comb
        if(pRead)
            // 11：数据输入端口（高）， 10：数据输入端口（低）
            // 01：数据输入端口（led），00：状态端口
            begin
                case(addr)
                    2'b11: pReadData = {24'b0, switch1[15:8]};
                    2'b10: pReadData = {24'b0, switch1[7:0]};
                    2'b00: pReadData = {24'b0, 6'b0, status};
                    default: pReadData = 32'b0;
                endcase
            end
        else
            pReadData = 32'b0;
            
endmodule