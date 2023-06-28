module mux7seg(
    input  logic        clk,
    input  logic        reset,
    input  logic [31:0] digit,
    output logic [6:0]  a2g,
    output logic [7:0]  an   );
    
    logic [4:0]  digit1;
    logic [2:0]  s;
    logic [19:0] clkdiv;
    
    assign s = clkdiv[19:17];
    
    
    //∑¬’Ê”√
    assign an = 8'b1111_1110;
    assign digit1 = {1'b0, digit[3:0]};
    
    
//    always_comb
//        begin
//            case(s)
//                0: digit1 = {1'b0, digit[3:0]};
//                1: digit1 = {1'b0, digit[7:4]};
//                2: digit1 = {1'b0, digit[11:8]};
//                3: digit1 =  5'h10;
//                4: digit1 = {1'b0, digit[19:16]};
//                5: digit1 = {1'b0, digit[23:20]};
//                6: digit1 = {1'b0, digit[27:24]};
//                7: digit1 = {1'b0, digit[31:28]};
//            endcase
//        end
            
    always_comb
        case(s)
            0: an = 8'b1111_1110;
            1: an = 8'b1111_1101;
            2: an = 8'b1111_1011;
            3: an = 8'b1111_0111;
            4: an = 8'b1110_1111;
            5: an = 8'b1101_1111;
            6: an = 8'b1011_1111;
            7: an = 8'b0111_1111;
        endcase
      
    always @(posedge clk, posedge reset)
        if(reset == 1) clkdiv <= 0;
        else           clkdiv <= clkdiv + 1;
    
    Hex7Seg s7 (.data(digit1),
                .a2g(a2g) );

endmodule