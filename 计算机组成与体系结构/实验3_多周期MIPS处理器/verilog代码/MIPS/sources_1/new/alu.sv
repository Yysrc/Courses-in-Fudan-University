module alu(
    input  logic [31:0] srca, srcb,
    input  logic [2:0]  alucontrol,
    output logic [31:0] aluout,
    output logic        zero
    );
    
    always_comb
    case(alucontrol)
        3'b000: aluout = srca + srcb;
        3'b001: aluout = srca - srcb;
        3'b010: aluout = srca & srcb;
        3'b011: aluout = srca | srcb;
        
        3'b100:
            begin
                if(srca < srcb) aluout = { {31{1'b0}},1'b1 };
                else            aluout = {  32{1'b0}  };
            end
        3'b101: ;
        default: aluout = { 32{1'b0} };
        
    endcase
    
    assign zero = ~( |aluout );
    
endmodule

