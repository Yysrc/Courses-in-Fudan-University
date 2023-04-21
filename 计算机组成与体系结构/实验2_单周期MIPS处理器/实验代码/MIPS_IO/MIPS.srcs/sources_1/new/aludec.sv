module aludec(input  logic [5:0] funct,
              input  logic [2:0] aluop,
              output logic [2:0] alucontrol);
    
    always_ff @(*)
        case (aluop)
            3'b000: alucontrol <= 3'b000;  //addu(for lw/sw/addi)
            3'b001: alucontrol <= 3'b001;  //subu(for beq/bne)
            3'b010:                        //R_Type
                case(funct)
                    6'b100000: alucontrol <= 3'b000; //ADD
                    6'b100010: alucontrol <= 3'b001; //SUB
                    6'b100100: alucontrol <= 3'b010; //AND
                    6'b100101: alucontrol <= 3'b011; //OR
                    6'b101010: alucontrol <= 3'b100; //SLT
                    6'b000000: alucontrol <= 3'b101; //SLL(NOP
                endcase
                
            3'b011: alucontrol <= 3'b011;  //or(for ori)
            3'b100: alucontrol <= 3'b010;  //and(for andi)
            3'b101: alucontrol <= 3'b100;  //slt(for slti)
            
                
            default:   alucontrol <= 3'bxxx; 
        endcase
endmodule
